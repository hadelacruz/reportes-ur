
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
                // 1) parsear el JSON sólo si viene algo; si no, dejamos scores = []
                let scores = [];
                if (row.score) {
                    try {
                        scores = typeof row.score === "string" ?
                            JSON.parse(row.score) :
                            Array.isArray(row.score) ?
                            row.score : [];
                    } catch (e) {
                        scores = [];
                    }
                }

                // 2) helper que devuelve { hasNote, nota }
                function faseInfo(stageName) {
                    // si no hay ningún registro, devolvemos vacío
                    if (!Array.isArray(scores) || scores.length === 0) {
                        return {
                            hasNote: false,
                            nota: ""
                        };
                    }
                    const s = scores.filter(x => x.stage === stageName);
                    const zone = s.find(x => x.name === "Zona");
                    const exam = s.find(x => x.name === "Examen");
                    const nsp = s.find(x => x.name === "NSP");
                    const sde = s.find(x => x.name === "SDE");

                    const hasNSP = !!(nsp && nsp.nsp === true);
                    const hasSDE = !!(sde && sde.sde === true);
                    const hasZone = !!(zone && zone.score != null && zone.score !== "");
                    const hasExam = !!(exam && exam.score != null && exam.score !== "");

                    let info = {
                        hasNote: false,
                        nota: "0"
                    };

                    if (hasNSP && hasZone) {
                        info.hasNote = true;
                        info.nota = "NSP";
                    } else if (!hasNSP && hasZone && hasExam) {
                        info.hasNote = true;
                        info.nota = Number(zone.score) + Number(exam.score);
                    } else if (!hasZone && hasNSP) {
                        info.hasNote = false;
                        info.nota = "NSP";
                    } else if (hasZone || hasExam) {
                        info.hasNote = true;
                        info.nota = (hasZone ? Number(zone.score) : 0) +
                            (hasExam ? Number(exam.score) : 0);
                    } else if (hasSDE && !hasZone && !hasExam) {
                        info.hasNote = true;
                        info.nota = "SDE";
                    }

                    return info;
                }

                // 3) obtenemos la info de cada fase
                const f1 = faseInfo("Fase 1");
                const f2 = faseInfo("Fase 2");
                const fF = faseInfo("Fase Final");

                // 4) devolvemos row enriquecido
                return Object.assign(row, {
                    fase1_tiene: f1.hasNote ? "Si" : "No",
                    fase1_nota: f1.nota,
                    fase2_tiene: f2.hasNote ? "Si" : "No",
                    fase2_nota: f2.nota,
                    faseFinal_tiene: fF.hasNote ? "Si" : "No",
                    faseFinal_nota: fF.nota,
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
                    // "Fase 1: Tiene notas?"
                    data: "fase1_tiene"
                },
                {
                    // "Fase 1: Nota"
                    data: "fase1_nota"
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
                    // "Fase Final: Tiene notas?"
                    data: "faseFinal_tiene"
                },
                {
                    // "Fase Final: Nota"
                    data: "faseFinal_nota"
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