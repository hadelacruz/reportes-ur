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
                const dropoutLabel = row.student_status_code === "B" ? "BAJA" : row.student_status_code === "D" ? "DESHABILITADO" : "";

                function regularStageInfo(stageName) {
                    if (isPracticalCourse) return {
                        tiene: "NA",
                        nota: "",
                        examen: ""
                    };
                    if (isDropout) return {
                        tiene: "Si",
                        nota: dropoutLabel,
                        examen: dropoutLabel
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
                    if (isDropout) return {
                        tiene: "Si",
                        nota: dropoutLabel
                    };

                    const stageBlocks = blocksByStage.get(stageName) || [];
                    const firstNumeric = stageBlocks.find(x => hasNumericScore(x && x.score));

                    if (firstNumeric) {
                        return {
                            tiene: "Si",
                            nota: firstNumeric.score
                        };
                    }

                    return {
                        tiene: "No",
                        nota: ""
                    };
                }

                function recoveryStageInfo(stageName) {
                    if (isPracticalCourse) return {
                        tiene: "NA",
                        nota: ""
                    };

                    const stageBlocks = blocksByStage.get(stageName) || [];
                    const isAssignedToRecovery = stageBlocks.length > 0;

                    if (!isAssignedToRecovery) {
                        return {
                            tiene: "NA",
                            nota: ""
                        };
                    }

                    const firstNumeric = stageBlocks.find(x => hasNumericScore(x && x.score));

                    if (firstNumeric) {
                        return {
                            tiene: "Si",
                            nota: firstNumeric.score
                        };
                    }

                    const hasNSP = stageBlocks.some(x => x && x.name === "NSP" && x.nsp === true);
                    if (hasNSP) {
                        return {
                            tiene: "Si",
                            nota: "NSP"
                        };
                    }

                    return {
                        tiene: "No",
                        nota: ""
                    };
                }

                const f1 = regularStageInfo("Fase 1");
                const f2 = regularStageInfo("Fase 2");
                const fF = regularStageInfo("Fase Final");
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
                    fase2_tiene: f2.tiene,
                    fase2_nota: f2.nota,
                    fase2_examen: f2.examen,
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