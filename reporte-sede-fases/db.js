async function getCompletionReport() {
    try {
        const REGULAR_BASE_STAGES = ["Fase 1", "Fase 2", "Fase Final"];
        const PRACTICAL_BASE_STAGES = ["Seminario", "Plan Práctico", "Desarrollo", "Informe Final", "Consolidado"];
        const PRACTICAL_STAGE_SET = new Set(PRACTICAL_BASE_STAGES);

        function normalizeStageName(stage) {
            if (!stage || typeof stage !== "string") return stage;
            const clean = stage.trim();

            // Variantes comunes observadas en BD / UI
            if (/^plan practico$/i.test(clean) || /^plan pr[aá]ctico$/i.test(clean)) return "Plan Práctico";
            if (/^recuperaci[oó]n\s*1$/i.test(clean)) return "Recuperacion1";
            if (/^recuperaci[oó]n\s*2$/i.test(clean)) return "Recuperacion2";

            return clean;
        }

        let inscCondition = {};

        // 1. Recibir filtros que Modul mandó automáticamente desde tu entrada.js
        if (req.body.d.period) inscCondition.period_id = req.body.d.period.split(",");
        if (req.body.d.branch) inscCondition.branch_id = req.body.d.branch.split(",");
        
        const requestedCourseType = (req.body.d.course_type || "all").toString().toLowerCase();
        const Op = (models.Sequelize && models.Sequelize.Op) || (models.sequelize && models.sequelize.Op);
        const useCursorPagination = !!(Op && Op.gt);

        // Relaciones basadas en ejemplo2
        models.crs_assignation_preinscription.belongsTo(models.std_student, { foreignKey: "student_id" });
        models.crs_assignation_preinscription.belongsTo(models.crs_assignation_section, { foreignKey: "taken_by_section_id", targetKey: "section_id" });
        models.crs_assignation_preinscription.belongsTo(models.std_branch, { foreignKey: "branch_id" });
        
        models.crs_assignation_section.belongsTo(models.crs_assignation_season, { foreignKey: "season_id" });
        models.crs_assignation_section.belongsTo(models.crs_course, { foreignKey: "course_id" });
        models.crs_assignation_season.belongsTo(models.std_period, { foreignKey: "period_id" });

        const BATCH_SIZE = 1000;
        let offset = 0;
        let lastPreinscriptionId = 0;
        const branchesStats = {};
        const sectionCache = new Map(); // section_id => { isPractical: boolean|null, baseStages: Set<string> }

        while(true) {
            const preinscriptionQuery = {
                attributes: ["preinscription_id", "student_id", "taken_by_section_id", "branch_id"],
                include: [
                    {
                        model: models.std_student,
                        attributes: ["name", "status_code"],
                        required: false
                    },
                    {
                        model: models.std_branch,
                        attributes: ["name"], 
                        required: true,
                        where: req.body.d.branch ? { branch_id: req.body.d.branch.split(",") } : {}
                    },
                    {
                        model: models.crs_assignation_section,
                        attributes: ["section_id", "season_id", "course_id"],
                        required: true,
                        include: [
                            {
                                model: models.crs_assignation_season,
                                attributes: ["season_id", "period_id"],
                                required: true,
                                include: [
                                    {
                                        model: models.std_period,
                                        attributes: ["name"], 
                                        required: true,
                                        where: req.body.d.period ? { period_id: req.body.d.period.split(",") } : {}
                                    }
                                ]
                            },
                            {
                                model: models.crs_course,
                                attributes: ["course_id", "setup"],
                                required: false
                            }
                        ]
                    }
                ],
                limit: BATCH_SIZE,
                order: [['preinscription_id', 'ASC']]
            };

            if (useCursorPagination) {
                preinscriptionQuery.where = { preinscription_id: { [Op.gt]: lastPreinscriptionId } };
            } else {
                preinscriptionQuery.offset = offset;
            }

            const preinscriptions = await models.crs_assignation_preinscription.findAll(preinscriptionQuery);

            if (!preinscriptions || preinscriptions.length === 0) {
                break;
            }

            if (useCursorPagination) {
                lastPreinscriptionId = preinscriptions[preinscriptions.length - 1].preinscription_id;
            }

            const studentIds = [...new Set(preinscriptions.map(p => p.student_id))];
            const sectionIds = [...new Set(preinscriptions.map(p => p.taken_by_section_id))];
            const uncachedSectionIds = sectionIds.filter(id => !sectionCache.has(id));
            const uncachedSectionsSet = new Set(uncachedSectionIds);

            const scores = await models.crs_score.findAll({
                where: {
                    student_id: studentIds,
                    section_id: sectionIds
                },
                attributes: ["student_id", "section_id", "setup"]
            });

            const scoresMap = new Map();

            // Identificar tipo de curso y fases base solo para secciones nuevas (cacheable entre lotes)
            preinscriptions.forEach(pre => {
                const section = pre.crs_assignation_section;
                if (!section || !section.section_id || !uncachedSectionsSet.has(section.section_id)) return;
                if (sectionCache.has(section.section_id)) return;

                const course = section.crs_course;
                let isPractical = null;

                if (course && course.setup) {
                    try {
                        const parsedSetup = typeof course.setup === "string" ? JSON.parse(course.setup) : course.setup;
                        if (parsedSetup && typeof parsedSetup.is_practical === "boolean") {
                            isPractical = parsedSetup.is_practical;
                        }
                    } catch (e) {
                        isPractical = null;
                    }
                }

                let baseStages = new Set();
                if (isPractical === true) {
                    baseStages = new Set(PRACTICAL_BASE_STAGES);
                } else if (isPractical === false) {
                    baseStages = new Set(REGULAR_BASE_STAGES);
                }

                sectionCache.set(section.section_id, { isPractical: isPractical, baseStages: baseStages });
            });

            scores.forEach(s => {
                scoresMap.set(`${s.student_id}_${s.section_id}`, s);
            });

            // Descubrimiento estable de fases por sección solo para secciones nuevas
            if (uncachedSectionIds.length > 0) {
                const sectionScores = await models.crs_score.findAll({
                    where: {
                        section_id: uncachedSectionIds
                    },
                    attributes: ["section_id", "setup"]
                });

                sectionScores.forEach(s => {
                    const sectionMeta = sectionCache.get(s.section_id);
                    if (!sectionMeta) return;

                    let sSetup = [];
                    try { sSetup = typeof s.setup === "string" ? JSON.parse(s.setup) : s.setup; } catch(e){}
                    if (Array.isArray(sSetup)) {
                        sSetup.forEach(item => {
                            const normalizedStage = normalizeStageName(item.stage);
                            if (!normalizedStage) return;

                            const isConditional = /recuperacion|extraordinario|retrasada|suficiencia/i.test(normalizedStage);
                            const sectionKind = sectionMeta.isPractical;

                            if (sectionKind === true && !PRACTICAL_STAGE_SET.has(normalizedStage)) return;
                            if (sectionKind === false && PRACTICAL_STAGE_SET.has(normalizedStage)) return;

                            if (!isConditional) {
                                sectionMeta.baseStages.add(normalizedStage);
                            }
                        });
                    }
                });
            }

            preinscriptions.forEach(pre => {
                const section = pre.crs_assignation_section;
                const season = section ? section.crs_assignation_season : null;
                const period = season ? season.std_period : null;
                const student = pre.std_student;

                if (!pre.std_branch || !period) return;
                
                const branchName = pre.std_branch.name;
                const branchId = pre.branch_id;
                const periodName = period.name;
                const periodId = season.period_id;

                const agroupKey = `${branchId}_${periodId}`;

                if (!branchesStats[agroupKey]) {
                    branchesStats[agroupKey] = { 
                        sede: branchName, 
                        periodo: periodName, 
                        fases_esperadas: {}, 
                        fases_ingresadas: {} 
                    };
                }

                const sectionMeta = sectionCache.get(pre.taken_by_section_id) || { isPractical: null, baseStages: new Set() };
                const scoreRecord = scoresMap.get(`${pre.student_id}_${pre.taken_by_section_id}`);
                let scoreSetups = [];
                
                if (scoreRecord && scoreRecord.setup) {
                    try {
                        scoreSetups = typeof scoreRecord.setup === "string" ? JSON.parse(scoreRecord.setup) : scoreRecord.setup;
                    } catch (e) {
                        scoreSetups = [];
                    }
                }

                let expectedStages = new Set();
                let recordedStages = new Set();

                // 1. El estudiante SIEMPRE es esperado en las fases regulares de su curso (asegura cuadrar los totales con ejemplo2)
                sectionMeta.baseStages.forEach(stg => expectedStages.add(stg));

                // 2. Analizamos el JSON propio del estudiante para agregar fases condicionales y saber si hay nota ingresada
                let isStudentDropout = false;
                if (student) {
                    // 'B' es Baja, 'D' es Deshabilitado (Fallecido). 'S' (Suspendido) SÍ se debe calificar, por lo que no es dropout.
                    if (student.status_code === 'B' || student.status_code === 'D') {
                        isStudentDropout = true;
                    }
                }

                if (Array.isArray(scoreSetups)) {
                    const sectionKind = sectionMeta.isPractical;
                    const stageBlocksByStage = new Map();

                    scoreSetups.forEach(item => {
                        const stageName = normalizeStageName(item.stage);
                        if (!stageName) return;
                        if (!stageBlocksByStage.has(stageName)) {
                            stageBlocksByStage.set(stageName, []);
                        }
                        stageBlocksByStage.get(stageName).push(item);
                    });

                    stageBlocksByStage.forEach((stageBlocks, stageName) => {
                        if (!stageName) return;
                        if (sectionKind === true && !PRACTICAL_STAGE_SET.has(stageName)) return;
                        if (sectionKind === false && PRACTICAL_STAGE_SET.has(stageName)) return;
                        
                        expectedStages.add(stageName);

                        // Un alumno dado de baja también puede tener enable/enabled = false a nivel JSON
                        const isDisabledJSON = stageBlocks.some(x => x.enable === false || x.enabled === false || x.active === false);
                        const isDropoutPhase = isStudentDropout || isDisabledJSON;

                        // Verificamos si tiene calificación (emulamos la función faseInfo del ejemplo2)
                        let zone = null;
                        let exam = null;
                        let nsp = null;
                        let sde = null;

                        stageBlocks.forEach(x => {
                            if (x.name === "Zona") zone = x;
                            else if (x.name === "Examen") exam = x;
                            else if (x.name === "NSP") nsp = x;
                            else if (x.name === "SDE") sde = x;
                        });

                        let hasNote = false;

                        if (zone || exam || nsp || sde) {
                            // Fase regular (Fase 1, Fase 2, Fase Final)
                            const hasNSP = !!(nsp && nsp.nsp === true);
                            const hasSDE = !!(sde && sde.sde === true);
                            const hasZone = !!(zone && zone.score !== undefined && zone.score !== null && String(zone.score).trim() !== "");
                            const hasExam = !!(exam && exam.score !== undefined && exam.score !== null && String(exam.score).trim() !== "");

                            // Reglas exactas de completitud de fase regular:
                            // 1. Fase Final: Si tiene SDE (Sin Derecho a Examen), el sistema bloquea, por lo que cuenta como completada automáticamente sin depender del catedrático.
                            // 2. Para TODAS (Fase 1, 2 y Fase Final sin SDE): OBLIGATORIAMENTE debe tener nota numérica de Zona Y (nota numérica de Examen O marca de NSP).
                            if (stageName === 'Fase Final' && hasSDE) {
                                hasNote = true;
                            } else if (hasZone && (hasExam || hasNSP)) {
                                hasNote = true;
                            } else {
                                hasNote = false;
                            }
                        } else {
                            // Cursos prácticos (Seminario, Desarrollo, etc..) o condicionales (Recuperacion) 
                            // que no tienen Zona/Examen/NSP separadas, solo validamos si existe un score válido
                            hasNote = stageBlocks.some(x => x.score !== undefined && x.score !== null && String(x.score).trim() !== "");
                        }

                        // Si la fase tiene nota, o el alumno se dio de baja general/JSON (isDropoutPhase = verdadero), ya no está pendiente
                        if (hasNote || isDropoutPhase) {
                            recordedStages.add(stageName);
                        }
                    });
                }

                // 3. Respaldo definitivo: Si el alumno es desertor total, cuenta como calificado forzosamente en las fases esperadas
                if (isStudentDropout) {
                    expectedStages.forEach(stg => recordedStages.add(stg));
                }

                // Sumamos a los denominadores (Alumnos esperados para tener nota en esta fase)
                expectedStages.forEach(stage => {
                    if (!branchesStats[agroupKey].fases_esperadas[stage]) {
                        branchesStats[agroupKey].fases_esperadas[stage] = 0;
                    }
                    branchesStats[agroupKey].fases_esperadas[stage] += 1;
                });

                // Sumamos a los numeradores (Alumnos que efectivamente ya tienen nota en esta fase)
                recordedStages.forEach(stage => {
                    if (!branchesStats[agroupKey].fases_ingresadas[stage]) {
                        branchesStats[agroupKey].fases_ingresadas[stage] = 0;
                    }
                    branchesStats[agroupKey].fases_ingresadas[stage] += 1;
                });
            });
            
            if (!useCursorPagination) {
                offset += BATCH_SIZE;
            }
        }

        const finalResult = Object.values(branchesStats).map(branch => {
            const row = {
                Sede: branch.sede,
                Periodo: branch.periodo
            };
            
            const stagesToEvaluate = Object.keys(branch.fases_esperadas);
            const filteredStages = stagesToEvaluate.filter(stage => {
                const isPracticalStage = PRACTICAL_STAGE_SET.has(normalizeStageName(stage));
                if (requestedCourseType === "practical") return isPracticalStage;
                if (requestedCourseType === "regular") return !isPracticalStage;
                return true;
            });

            filteredStages.forEach(stage => {
                const esperados = branch.fases_esperadas[stage] || 0; // Denominador (Ej: Sólo 100 fueron a recuperación)
                const ingresados = branch.fases_ingresadas[stage] || 0; // Numerador (Ej: Se ha ingresado nota a 80 de esos 100)
                
                let porcentaje = 0;
                if (esperados > 0) {
                    porcentaje = (ingresados / esperados) * 100;
                }
                
                row[stage] = porcentaje.toFixed(2) + "% <br><small>(hay " + ingresados + " de " + esperados + ")</small>"; 

            });

            return row;
        });

        resolve(finalResult); 

    } catch (error) {
        console.error("Error al generar reporte:", error);
        reject(error); 
    }
}

getCompletionReport();