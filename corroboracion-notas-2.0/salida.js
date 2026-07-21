{
    data: function() {
        return {
            result: {},
            loading: true,
        }
    },
    methods: {},
    created: function() {},
    mounted: function() {
        let vm = this;
        // console.log("vm", vm);
        if (vm.result) {
            console.log("res", vm.result);
            // vm.result = vm.result.map(row => {
            //     // 1) parsear el string JSON
            //     let scores = [];
            //     try {
            //         scores = typeof row.score === "string" ?
            //             JSON.parse(row.score) :
            //             row.score;
            //     } catch (e) {
            //         /* si falla, lo dejamos vacío */
            //         scores = [];
            //     }

            //     // helper que devuelve { hasNote: Boolean, nota: String|Number }
            //     function faseInfo(stageName) {
            //         const s = scores.filter(x => x.stage === stageName);
            //         const zone = s.find(x => x.name === "Zona");
            //         const exam = s.find(x => x.name === "Examen");
            //         const nsp = s.find(x => x.name === "NSP");
            //         const hasNSP = !!(nsp && nsp.nsp === true);
            //         const hasZone = !!(zone && zone.score != null && zone.score !== "");
            //         const hasExam = !!(exam && exam.score != null && exam.score !== "");

            //         let info = {
            //             hasNote: false,
            //             nota: ""
            //         };

            //         if (hasNSP && hasZone) {
            //             // caso 1: hay NSP pero también Zona → Nota = "NSP"
            //             info.hasNote = true;
            //             info.nota = "NSP";
            //         } else if (!hasNSP && hasZone && hasExam) {
            //             // caso 2: sin NSP, con Zona y Examen → suma
            //             info.hasNote = true;
            //             info.nota = Number(zone.score) + Number(exam.score);
            //         } else if (!hasZone && hasNSP) {
            //             // caso 3: sólo NSP → no tiene nota pero mostramos "NSP"
            //             info.hasNote = false;
            //             info.nota = "NSP";
            //         } else if (hasZone || hasExam) {
            //             // fallback: si sólo hay Zona o sólo Examen
            //             info.hasNote = true;
            //             info.nota = (hasZone ? Number(zone.score) : 0) +
            //                 (hasExam ? Number(exam.score) : 0);
            //         }

            //         return info;
            //     }

            //     // obtenemos los 3 objetos
            //     const f1 = faseInfo("Fase 1");
            //     const f2 = faseInfo("Fase 2");
            //     const fF = faseInfo("Fase Final");

            //     // devolvemos row enriquecido
            //     return Object.assign(row, {
            //         fase1_tiene: f1.hasNote ? "Si" : "No",
            //         fase1_nota: f1.nota,
            //         fase2_tiene: f2.hasNote ? "Si" : "No",
            //         fase2_nota: f2.nota,
            //         faseFinal_tiene: fF.hasNote ? "Si" : "No",
            //         faseFinal_nota: fF.nota,
            //     });
            // });

            vm.result = vm.result.map(row => {
                const PRACTICAL_STAGES = ["Seminario", "Plan Práctico", "Desarrollo", "Informe Final", "Consolidado"];
                const PRACTICAL_SET = new Set(PRACTICAL_STAGES);

                function normalizeStageName(stage) {
                    if (!stage || typeof stage !== "string") return "";
                    const clean = stage.trim();
                    if (/^fase\s*1$/i.test(clean)) return "Fase 1";
                    if (/^fase\s*2$/i.test(clean)) return "Fase 2";
                    if (/^fase\s*final$/i.test(clean)) return "Fase Final";
                    if (/^plan practico$/i.test(clean) || /^plan pr[aá]ctico$/i.test(clean)) return "Plan Práctico";
                    if (/^recuperaci[oó]n\s*1$/i.test(clean)) return "Recuperacion1";
                    if (/^recuperaci[oó]n\s*2$/i.test(clean)) return "Recuperacion2";
                    return clean;
                }

                function hasNumericScore(value) {
                    if (value === null || value === undefined) return false;
                    const str = String(value).trim();
                    if (str === "") return false;
                    return !Number.isNaN(Number(str));
                }

                function parseScoreSetup(setup) {
                    if (!setup) return [];
                    try {
                        const parsed = typeof setup === "string" ? JSON.parse(setup) : setup;
                        return Array.isArray(parsed) ? parsed : [];
                    } catch (e) {
                        return [];
                    }
                }

                const scores = parseScoreSetup(row.score);
                const blocksByStage = new Map();
                scores.forEach(item => {
                    const stg = normalizeStageName(item && item.stage);
                    if (!stg) return;
                    if (!blocksByStage.has(stg)) {
                        blocksByStage.set(stg, []);
                    }
                    blocksByStage.get(stg).push(item);
                });

                let isPracticalCourse = row.course_type === "practical";
                if (row.course_type !== "practical" && row.course_type !== "regular") {
                    const seenPracticalStage = Array.from(blocksByStage.keys()).some(stg => PRACTICAL_SET.has(stg));
                    isPracticalCourse = seenPracticalStage;
                }

                const isDropout = row.student_status_code === "B" || row.student_status_code === "D";

                function regularStageInfo(stageName) {
                    if (isPracticalCourse) return {
                        tiene: "NA",
                        nota: "",
                        examen: ""
                    };

                    const stageBlocks = blocksByStage.get(stageName) || [];
                    const zone = stageBlocks.find(x => x.name === "Zona");
                    const exam = stageBlocks.find(x => x.name === "Examen");
                    const nsp = stageBlocks.find(x => x.name === "NSP");
                    const sde = stageBlocks.find(x => x.name === "SDE");

                    const hasZone = !!(zone && hasNumericScore(zone.score));
                    const hasExam = !!(exam && hasNumericScore(exam.score));
                    const hasNSP = !!(nsp && nsp.nsp === true);
                    const hasSDE = !!(sde && sde.sde === true);

                    const zoneValue = hasZone ? zone.score : "";
                    const examValue = hasExam ? exam.score : (hasNSP ? "NSP" : (hasSDE ? "SDE" : ""));

                    if (stageName === "Fase Final" && hasSDE) {
                        return {
                            tiene: "Si",
                            nota: zoneValue,
                            examen: "SDE"
                        };
                    }

                    if (hasZone && hasNSP) {
                        return {
                            tiene: "Si",
                            nota: zoneValue,
                            examen: "NSP"
                        };
                    }

                    if (hasZone && hasExam) {
                        return {
                            tiene: "Si",
                            nota: zoneValue,
                            examen: examValue
                        };
                    }

                    // Bajas (B) y fallecidos (D) cuentan siempre como nota ingresada,
                    // mostrando las notas que tengan registradas
                    if (isDropout) return {
                        tiene: "Si",
                        nota: zoneValue,
                        examen: examValue
                    };

                    return {
                        tiene: "No",
                        nota: zoneValue,
                        examen: examValue
                    };
                }

                function singleNumericStageInfo(stageName, appliesToPractical) {
                    const applies = appliesToPractical ? isPracticalCourse : !isPracticalCourse;
                    if (!applies) return {
                        tiene: "NA",
                        nota: ""
                    };

                    const stageBlocks = blocksByStage.get(stageName) || [];
                    const firstNumeric = stageBlocks.find(x => hasNumericScore(x && x.score));

                    if (firstNumeric) {
                        return {
                            tiene: "Si",
                            nota: firstNumeric.score
                        };
                    }

                    // Bajas y fallecidos cuentan siempre como nota ingresada
                    if (isDropout) return {
                        tiene: "Si",
                        nota: ""
                    };

                    return {
                        tiene: "No",
                        nota: ""
                    };
                }

                function sumZonaExamen(stageName) {
                    const blocks = blocksByStage.get(stageName) || [];
                    let total = 0;
                    blocks.forEach(x => {
                        if (x && (x.name === "Zona" || x.name === "Examen") && hasNumericScore(x.score)) {
                            total += Number(x.score);
                        }
                    });
                    return total;
                }

                // La asignación a recuperaciones se decide SOLO con la regla del 61;
                // la existencia del stage en el setup no implica que el alumno la
                // necesite, porque el módulo puede dejar stages creados y vacíos al
                // editar notas (p. ej. R2 habilitada cuando R1 iba baja y luego
                // corregida). El stage solo aporta el resultado (nota o NSP) cuando
                // la regla dice que la recuperación sí aplica.
                function recoveryStageInfo(stageName) {
                    if (isPracticalCourse) return {
                        tiene: "NA",
                        nota: ""
                    };

                    if (isDropout) return {
                        tiene: "NA",
                        nota: ""
                    };

                    const ffBlocks = blocksByStage.get("Fase Final") || [];
                    const ffNSP = ffBlocks.some(x => x && x.name === "NSP" && x.nsp === true);
                    const ffSDE = ffBlocks.some(x => x && x.name === "SDE" && x.sde === true);
                    const ffExam = ffBlocks.find(x => x && x.name === "Examen");
                    const ffClosed = ffBlocks.some(x => x && x.name === "is_closed" && x.is_closed === true);
                    const ffResolved = ffClosed || ffNSP || ffSDE || !!(ffExam && hasNumericScore(ffExam.score));

                    // Sin Fase Final resuelta no se sabe si irá a recuperación;
                    // con SDE no tiene derecho a recuperación
                    if (!ffResolved || ffSDE) return {
                        tiene: "NA",
                        nota: ""
                    };

                    const baseTotal = sumZonaExamen("Fase 1") + sumZonaExamen("Fase 2") + sumZonaExamen("Fase Final");
                    if (baseTotal >= 61) return {
                        tiene: "NA",
                        nota: ""
                    };

                    // Resultado registrado de una recuperación: nota numérica o NSP
                    // (en recuperaciones el flag nsp viene en el propio item)
                    function recoveryResult(recoveryName) {
                        const blocks = blocksByStage.get(recoveryName) || [];
                        const numeric = blocks.find(x => x && hasNumericScore(x.score));
                        if (numeric) return { done: true, nsp: false, score: Number(numeric.score) };
                        if (blocks.some(x => x && x.nsp === true)) return { done: true, nsp: true, score: 0 };
                        return { done: false, nsp: false, score: 0 };
                    }

                    const r1 = recoveryResult("Recuperacion1");

                    if (stageName === "Recuperacion1") {
                        if (r1.done) return {
                            tiene: "Si",
                            nota: r1.nsp ? "NSP" : r1.score
                        };
                        return {
                            tiene: "No",
                            nota: ""
                        };
                    }

                    // Recuperacion2: aplica solo si R1 ya tiene resultado y el total,
                    // con la nota de R1 sustituyendo el bloque de Fase Final (sobre 40),
                    // sigue sin llegar a 61
                    if (!r1.done) return {
                        tiene: "NA",
                        nota: ""
                    };

                    const totalConR1 = sumZonaExamen("Fase 1") + sumZonaExamen("Fase 2") + r1.score;
                    if (totalConR1 >= 61) return {
                        tiene: "NA",
                        nota: ""
                    };

                    const r2 = recoveryResult("Recuperacion2");
                    if (r2.done) return {
                        tiene: "Si",
                        nota: r2.nsp ? "NSP" : r2.score
                    };
                    return {
                        tiene: "No",
                        nota: ""
                    };
                }

                // El extraordinario no existe como stage propio en crs_score.setup:
                // aplica cuando la fase base (Fase 1 / Fase 2) tiene NSP=true. Se
                // considera con nota si el Examen de la fase base fue sobrescrito
                // con la nota del extraordinario, o si trae extransp=true (el alumno
                // tampoco se presentó al extraordinario y se cerró como NSP).
                function extraordinaryStageInfo(baseStageName) {
                    if (isPracticalCourse) return {
                        tiene: "NA",
                        nota: ""
                    };

                    const isDropout = row.student_status_code === "B" || row.student_status_code === "D";
                    if (isDropout) return {
                        tiene: "NA",
                        nota: ""
                    };

                    const stageBlocks = blocksByStage.get(baseStageName) || [];
                    const nsp = stageBlocks.find(x => x.name === "NSP");
                    const exam = stageBlocks.find(x => x.name === "Examen");

                    const hasNSP = !!(nsp && nsp.nsp === true);
                    if (!hasNSP) return {
                        tiene: "NA",
                        nota: ""
                    };

                    const hasExam = !!(exam && hasNumericScore(exam.score));
                    const hasExtransp = !!(nsp && (nsp.extransp === true || nsp.extransp === "true"));

                    if (hasExam) return {
                        tiene: "Si",
                        nota: exam.score
                    };

                    if (hasExtransp) return {
                        tiene: "Si",
                        nota: "NSP"
                    };

                    return {
                        tiene: "No",
                        nota: ""
                    };
                }

                const f1 = regularStageInfo("Fase 1");
                const f2 = regularStageInfo("Fase 2");
                const fF = regularStageInfo("Fase Final");
                const e1 = extraordinaryStageInfo("Fase 1");
                const e2 = extraordinaryStageInfo("Fase 2");
                const r1 = recoveryStageInfo("Recuperacion1");
                const r2 = recoveryStageInfo("Recuperacion2");

                const sem = singleNumericStageInfo("Seminario", true);
                const plan = singleNumericStageInfo("Plan Práctico", true);
                const des = singleNumericStageInfo("Desarrollo", true);
                const inf = singleNumericStageInfo("Informe Final", true);
                const con = singleNumericStageInfo("Consolidado", true);

                return Object.assign(row, {
                    course_type_label: isPracticalCourse ? "Práctico" : "Regular",

                    fase1_tiene: f1.tiene,
                    fase1_nota: f1.nota,
                    fase1_examen: f1.examen,
                    extraordinario1_tiene: e1.tiene,
                    extraordinario1_nota: e1.nota,
                    fase2_tiene: f2.tiene,
                    fase2_nota: f2.nota,
                    fase2_examen: f2.examen,
                    extraordinario2_tiene: e2.tiene,
                    extraordinario2_nota: e2.nota,
                    faseFinal_tiene: fF.tiene,
                    faseFinal_nota: fF.nota,
                    faseFinal_examen: fF.examen,

                    recuperacion1_tiene: r1.tiene,
                    recuperacion1_nota: r1.nota,
                    recuperacion2_tiene: r2.tiene,
                    recuperacion2_nota: r2.nota,

                    seminario_tiene: sem.tiene,
                    seminario_nota: sem.nota,
                    planPractico_tiene: plan.tiene,
                    planPractico_nota: plan.nota,
                    desarrollo_tiene: des.tiene,
                    desarrollo_nota: des.nota,
                    informeFinal_tiene: inf.tiene,
                    informeFinal_nota: inf.nota,
                    consolidado_tiene: con.tiene,
                    consolidado_nota: con.nota,
                });
            });
            console.log("res2", vm.result);
            vm.loading = false;

            if (window.jQuery.fn.DataTable.isDataTable(vm.$refs.notes_table)) {
                window
                    .jQuery(vm.$refs.notes_table)
                    .DataTable()
                    .destroy();
            }
            window
                .jQuery(vm.$refs.notes_table)
                .find("tbody")
                .empty();

            let columns = [{
                    //Nombre estudiante
                    data: function(row) {
                        return row.student_name;
                    },
                }, {
                    //carne
                    data: function(row) {
                        return row.student_id_card;
                    },
                }, {
                    //aula
                    data: function(row) {
                        return row.classroom;
                    },
                }, {
                    //carrera
                    data: function(row) {
                        return row.career;
                    },
                }, {
                    // Columna "cursos"
                    data: function(row) {
                        return row.course;
                    },
                }, {
                    //NIT docente
                    data: function(row) {
                        return row.professor_nit;
                    },
                }, { //nombre docente
                    data: function(row) {
                        return row.professor;
                    },
                }, {
                    //Sede
                    data: function(row) {
                        return row.branch;
                    },
                }, {
                    //Jornada
                    data: function(row) {
                        return row.studying_time;
                    },
                },
                // { //Codigo de docente
                //     data: function(row) {
                //         if (row.crs_assignation_section) {
                //             let setup = JSON.parse(row.crs_assignation_section.pfs_professor.setup);
                //             return setup.professor_code;
                //         }
                //         return "No tiene profesor asignado."
                //     },
                // },
                {
                    //ciclo de estudio
                    data: function(row) {
                        return row.studying_cycle;
                    },
                },
                // {
                //     //horario
                //     data: function(row) {
                //         if (row.crs_assignation_section) {
                //             let setup = JSON.parse(row.crs_assignation_section.setup);
                //             // return "schedule="
                //             return setup.schedule;
                //         }
                //         return "No tiene horario asignado."
                //     },
                // }, 
                // {
                //     //dia
                //     data: function(row) {
                //         if (row.crs_assignation_section) {
                //             let setup = JSON.parse(row.crs_assignation_section.setup);
                //             let day = setup.day_index;
                //             for (const d of vm.result.dias) {
                //                 if (d.day_index == day) {
                //                     return d.name;
                //                 }
                //             }
                //         }
                //         return "No tiene día asignado."
                //     },
                // }, 
                {
                    //periodo
                    data: function(row) {
                        return row.period;
                    },
                },
                {
                    //tipo de curso
                    data: function(row) {
                        return row.course_type_label;
                    },
                },
                {
                    // "Fase 1: Tiene notas?"
                    data: "fase1_tiene"
                },
                {
                    // "Fase 1: Nota"
                    data: "fase1_nota"
                },
                {
                    // "Fase 1: Examen"
                    data: "fase1_examen"
                },
                {
                    // "Extraordinario 1: Tiene notas?"
                    data: "extraordinario1_tiene"
                },
                {
                    // "Extraordinario 1: Nota"
                    data: "extraordinario1_nota"
                },
                {
                    // "Fase 2: Tiene notas?"
                    data: "fase2_tiene"
                },
                {
                    // "Fase 2: Nota"
                    data: "fase2_nota"
                },
                {
                    // "Fase 2: Examen"
                    data: "fase2_examen"
                },
                {
                    // "Extraordinario 2: Tiene notas?"
                    data: "extraordinario2_tiene"
                },
                {
                    // "Extraordinario 2: Nota"
                    data: "extraordinario2_nota"
                },
                {
                    // "Fase Final: Tiene notas?"
                    data: "faseFinal_tiene"
                },
                {
                    // "Fase Final: Nota"
                    data: "faseFinal_nota"
                },
                {
                    // "Fase Final: Examen"
                    data: "faseFinal_examen"
                },
                {
                    // "Recuperacion1: Tiene notas?"
                    data: "recuperacion1_tiene"
                },
                {
                    // "Recuperacion1: Nota"
                    data: "recuperacion1_nota"
                },
                {
                    // "Recuperacion2: Tiene notas?"
                    data: "recuperacion2_tiene"
                },
                {
                    // "Recuperacion2: Nota"
                    data: "recuperacion2_nota"
                },
                {
                    // "Seminario: Tiene notas?"
                    data: "seminario_tiene"
                },
                {
                    // "Seminario: Nota"
                    data: "seminario_nota"
                },
                {
                    // "Plan Practico: Tiene notas?"
                    data: "planPractico_tiene"
                },
                {
                    // "Plan Practico: Nota"
                    data: "planPractico_nota"
                },
                {
                    // "Desarrollo: Tiene notas?"
                    data: "desarrollo_tiene"
                },
                {
                    // "Desarrollo: Nota"
                    data: "desarrollo_nota"
                },
                {
                    // "Informe Final: Tiene notas?"
                    data: "informeFinal_tiene"
                },
                {
                    // "Informe Final: Nota"
                    data: "informeFinal_nota"
                },
                {
                    // "Consolidado: Tiene notas?"
                    data: "consolidado_tiene"
                },
                {
                    // "Consolidado: Nota"
                    data: "consolidado_nota"
                }
            ]

            let tbl = window.jQuery(vm.$refs.notes_table).DataTable({
                pageLength: 50,
                autoWidth: true,
                ordering: true,
                scrollCollapse: true,
                data: vm.result,
                language: {
                    url: "//cdn.datatables.net/plug-ins/1.10.21/i18n/Spanish.json"
                },
                columns: columns,
                createdRow: function(row, data) {

                },
                dom: "lBfrtip",
                buttons: [
                    'csv', 'excel', 'print'
                ]
            });
        }
        window.jQuery(".ui.tabular.menu .item").tab();
    }
}