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

            vm.result = vm.result
                .map(row => {
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

                    // Sumar Zonas y Exámenes de TODAS las fases
                    const totalScore = scores
                        .filter(s => (s.name === "Zona" || s.name === "Examen") && !isNaN(Number(s.score)))
                        .reduce((acc, s) => acc + Number(s.score), 0);

                    // if (totalScore >= 85) {
                    return Object.assign(row, {
                        total_nota: totalScore
                    });
                    // } else {
                    //     return null;
                    // }
                })
                .filter(row => row !== null);

            // Paso 2: Agrupar por carrera + período + estudiante
            // (todos los cursos del estudiante en esa carrera y período van a un solo promedio,
            //  aunque estén repartidos en varias aulas)
            let agrupado = {};
            for (let row of vm.result) {
                let key = `${row.career}_${row.period}_${row.student_id}`;
                if (!agrupado[key]) {
                    agrupado[key] = {
                        student_id: row.student_id,
                        student_name: row.student_name,
                        student_id_card: row.student_id_card,
                        branch: row.branch,
                        career: row.career,
                        studying_cycle: row.studying_cycle,
                        studying_time: row.studying_time,
                        period: row.period,
                        total: 0,
                        count: 0
                    };
                }

                agrupado[key].total += row.total_nota;
                agrupado[key].count += 1;
            }

            // Paso 3: Calcular el promedio de todos los cursos del estudiante
            // (los cursos sin nota cuentan como 0)
            vm.result = Object.values(agrupado).map(entry => {
                return {
                    ...entry,
                    avg_nota: entry.count > 0 ? entry.total / entry.count : 0
                };
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
                    //carrera
                    data: function(row) {
                        return row.career;
                    },
                },
                // {
                //     // Columna "cursos"
                //     data: function(row) {
                //         return row.course;
                //     },
                // }, { //nombre docente
                //     data: function(row) {
                //         return row.professor;
                //     },
                // }, 
                {
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
                {
                    //ciclo de estudio
                    data: function(row) {
                        return row.studying_cycle;
                    },
                },
                {
                    //periodo
                    data: function(row) {
                        return row.period;
                    },
                },
                {
                    //nota total
                    data: function(row) {
                        return row.avg_nota.toFixed(2);
                    },
                },
            ]

            let tbl = window.jQuery(vm.$refs.notes_table).DataTable({
                pageLength: 50,
                autoWidth: true,
                ordering: true,
                order: [
                    [7, "desc"]
                ],
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