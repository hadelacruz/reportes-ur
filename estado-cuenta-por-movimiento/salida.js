{
    data: function() {
        return {
            students: [],
            loading: true
        };
    },
    methods: {
        uniqueId: function(prefix) {
            return prefix + '_' + Math.random().toString(36).substr(2, 9);
        },
        groupBy: function(array, key) {
            return array.reduce(function(rv, x) {
                (rv[key(x)] = rv[key(x)] || []).push(x);
                return rv;
            }, {});
        },
        getMovements: function(student) {
            let movements = [];
            // ✅ CORREGIDO: Cambiar std_accounts por std_account
            if (student.std_student && student.std_student.std_account) {
                // Si es un array (hasMany), iteramos sobre él
                let accounts = Array.isArray(student.std_student.std_account) 
                    ? student.std_student.std_account 
                    : [student.std_student.std_account];
                
                for (let account of accounts) {
                    if (account.acc_account) {
                        let acct = account.acc_account;
                        // Verificamos si std_account_movements existe y es un array
                        if (acct.std_account_movements) {
                            let movementsArray = Array.isArray(acct.std_account_movements)
                                ? acct.std_account_movements
                                : [acct.std_account_movements];
                            
                            for (let movement of movementsArray) {
                                movements.push({
                                    name: movement.std_account_movement_type 
                                        ? movement.std_account_movement_type.name 
                                        : 'Sin nombre',
                                    movement_id: movement.movement_id,
                                    amount: parseFloat(movement.amount) || 0,
                                    paid: parseFloat(movement.paid) || 0,
                                    expire_date: movement.expire_date
                                });
                            }
                        }
                    }
                }
            }
            return movements;
        },
        movement_grouped: function() {
            let t = this;
            let grouped = t.groupBy(t.students, function(std) {
                return std.std_student ? std.std_student.name : 'Sin nombre';
            });
            return grouped;
        },
        generateTableRows: function() {
            let vm = this;
            let rows = [];

            for (let student of vm.students) {
                let movements = vm.getMovements(student);

                // Si no hay movimientos, creamos una fila con datos vacíos
                if (movements.length === 0) {
                    let rowId = vm.uniqueId('movement');
                    let row = {
                        id: rowId,
                        branch: student.std_branch ? student.std_branch.name : 'N/A',
                        career: student.std_career ? student.std_career.name : 'N/A',
                        period: student.std_period ? student.std_period.name : 'N/A',
                        semester: student.std_studying_cycle ? student.std_studying_cycle.name : 'N/A',
                        studentIdCard: student.std_student ? student.std_student.student_id_card : 'N/A',
                        studentName: student.std_student ? student.std_student.name : 'N/A',
                        studyingTime: student.std_studying_time ? student.std_studying_time.name : 'N/A',
                        movement_id: 'N/A',
                        movementName: 'Sin movimientos',
                        amount: 0,
                        paid: 0,
                        expire: 'N/A',
                        courses: student.crs_assignation_preinscriptions ? student.crs_assignation_preinscriptions.length : 0
                    };
                    rows.push(row);
                } else {
                    for (let movement of movements) {
                        let rowId = vm.uniqueId('movement');
                        let row = {
                            id: rowId,
                            branch: student.std_branch ? student.std_branch.name : 'N/A',
                            career: student.std_career ? student.std_career.name : 'N/A',
                            period: student.std_period ? student.std_period.name : 'N/A',
                            semester: student.std_studying_cycle ? student.std_studying_cycle.name : 'N/A',
                            studentIdCard: student.std_student ? student.std_student.student_id_card : 'N/A',
                            studentName: student.std_student ? student.std_student.name : 'N/A',
                            studyingTime: student.std_studying_time ? student.std_studying_time.name : 'N/A',
                            movement_id: movement.movement_id,
                            movementName: movement.name,
                            amount: movement.amount,
                            paid: movement.paid,
                            expire: movement.expire_date,
                            courses: student.crs_assignation_preinscriptions ? student.crs_assignation_preinscriptions.length : 0
                        };

                        rows.push(row);
                    }
                }
            }

            return rows;
        }
    },
    mounted: function() {
        let vm = this;
        console.log("this", vm);
        if (!vm.result) {
            vm.loading = false;
            window.jQuery(".ui.tabular.menu .item").tab();
            return;
        }

        // Esperamos un tick para que Vue pinte el dimmer de "Cargando..."
        // antes de bloquear el hilo con el armado de la tabla (DataTable).
        vm.$nextTick(() => {
            vm.students = vm.result;
            console.log("students", vm.students);

            // Verificamos la estructura de los datos
            if (vm.students.length > 0) {
                console.log("Primer estudiante:", JSON.stringify(vm.students[0], null, 2));
                console.log("Movimientos del primer estudiante:", vm.getMovements(vm.students[0]));
            }

            if (window.jQuery.fn.DataTable.isDataTable(vm.$refs.student_table)) {
                window.jQuery(vm.$refs.student_table).DataTable().destroy();
            }
            window.jQuery(vm.$refs.student_table).find("tbody").empty();

            let columns = [
                //sede
                {
                    data: 'branch'
                },
                //carrera
                {
                    data: 'career'
                },
                //periodo
                {
                    data: 'period'
                },
                //Semestre
                {
                    data: 'semester'
                },
                //carne
                {
                    data: 'studentIdCard'
                },
                //estudiante
                {
                    data: 'studentName'
                },
                //jornada
                {
                    data: 'studyingTime'
                },
                //ID
                {
                    data: 'movement_id'
                },
                //cant cursos
                {
                    data: 'courses'
                },
                //Movimiento
                {
                    data: 'movementName'
                },
                //monto
                {
                    data: 'amount'
                },
                //pagado
                {
                    data: 'paid'
                },
                //adeudo
                {
                    data: function(row) {
                        return (row.amount - row.paid).toFixed(2);
                    }
                },
                { //Fecha de expiración
                    data: 'expire'
                }
            ];

            let tbl = window.jQuery(vm.$refs.student_table).DataTable({
                pageLength: 50,
                autoWidth: true,
                ordering: true,
                scrollCollapse: true,
                data: vm.generateTableRows(),
                language: {
                    url: "//cdn.datatables.net/plug-ins/1.10.21/i18n/Spanish.json"
                },
                columns: columns,
                createdRow: function(row, data) {
                    // Puedes agregar estilos o clases aquí si es necesario
                    if (data.amount - data.paid > 0) {
                        // Resaltar filas con adeudo
                        window.jQuery(row).css('background-color', '#fff3cd');
                    }
                },
                dom: "lBfrtip",
                buttons: [
                    'csv', 'excel', 'print'
                ]
            });

            // Opcional: refrescar la tabla después de un tiempo
            setTimeout(function() {
                tbl.draw();
            }, 100);

            vm.loading = false;
            window.jQuery(".ui.tabular.menu .item").tab();
        });
    }
}