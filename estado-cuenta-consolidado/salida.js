{
    data: function() {
        return {
            students: [],
            loading: true
        }
    },
    mounted: function() {
        let vm = this;
        if (!vm.result) {
            vm.loading = false;
            window.jQuery(".ui.tabular.menu .item").tab();
            return;
        }

        // Esperamos un tick para que Vue pinte el dimmer de "Cargando..."
        // antes de bloquear el hilo con el armado de la tabla (DataTable).
        vm.$nextTick(() => {
            vm.students = result;
            console.log(vm.students);
            if (window.jQuery.fn.DataTable.isDataTable(vm.$refs.student_table)) {
                window
                    .jQuery(vm.$refs.student_table)
                    .DataTable()
                    .destroy();
            }

            window
                .jQuery(vm.$refs.student_table)
                .find("tbody")
                .empty();

            let columns = [{
                    data: function(row) {
                        return row.std_branch.name;
                    },
                },
                {
                    data: function(row) {
                        return row.std_career.name;
                    },
                },
                {
                    data: function(row) {
                        return row.std_period.name;
                    },
                },
                {
                    data: function(row) {
                        return row.std_student.student_id_card;
                    },
                },
                {
                    data: function(row) {
                        return row.std_student.name;
                    },
                },
                {
                    data: function(row) {

                        let setup = JSON.parse(row.std_student.setup);
                        //return "Ceular=" + setup.cellphone + "Telefono Residencial: " + setup.residential_phone;
                        return setup.cellphone;
                    },
                },
                {
                    data: function(row) {

                        let setup = JSON.parse(row.std_student.setup);
                        //return "Ceular=" + setup.cellphone + "Telefono Residencial: " + setup.residential_phone;
                        return setup.email;
                    },
                },
                { //DPI
                    data: function(row) {
                        return row.std_student.dpi;
                    }
                },
                {
                    data: function(row) {

                        let setup = JSON.parse(row.std_student.setup);
                        //return "Ceular=" + setup.cellphone + "Telefono Residencial: " + setup.residential_phone;
                        return setup.residential_phone;
                    },
                },
                //domicilio
                {
                    data: function(row) {

                        let setup = JSON.parse(row.std_student.setup);
                        //return "Ceular=" + setup.cellphone + "Telefono Residencial: " + setup.residential_phone;
                        return setup.residential_address;
                    },
                },
                //Monto

                {
                    data: function(row) {
                        // Monto total (suma de todos los amounts)
                        if (row.std_student.std_account) {
                            let targetAccount = row.std_student.std_account;
                            if (targetAccount && targetAccount.acc_account && targetAccount.acc_account.std_account_movements) {
                                let totalAmount = targetAccount.acc_account.std_account_movements.reduce((prev, curr) => {
                                    return prev + Number(curr.amount);
                                }, 0);
                                return totalAmount.toFixed(2);
                            } else {
                                return "0.00";
                            }
                        } else {
                            return "0.00";
                        }
                    },
                },
                //Pagado
                {
                    data: function(row) {
                        // Pagado total (suma de todos los paid)
                        if (row.std_student.std_account) {
                            let targetAccount = row.std_student.std_account;
                            if (targetAccount && targetAccount.acc_account && targetAccount.acc_account.std_account_movements) {
                                let totalPaid = targetAccount.acc_account.std_account_movements.reduce((prev, curr) => {
                                    return prev + Number(curr.paid);
                                }, 0);
                                return totalPaid.toFixed(2);
                            } else {
                                return "0.00";
                            }
                        } else {
                            return "0.00";
                        }
                    },
                },
                //Descuentos
                {
                    data: function(row) {
                        // Descuento = Monto - Pagado
                        if (row.std_student.std_account) {
                            let targetAccount = row.std_student.std_account;
                            if (targetAccount && targetAccount.acc_account && targetAccount.acc_account.std_account_movements) {
                                let totalAmount = targetAccount.acc_account.std_account_movements.reduce((prev, curr) => {
                                    return prev + Number(curr.amount);
                                }, 0);
                                let totalPaid = targetAccount.acc_account.std_account_movements.reduce((prev, curr) => {
                                    return prev + Number(curr.paid);
                                }, 0);
                                let discount = totalAmount - totalPaid;
                                return discount.toFixed(2);
                            } else {
                                return "0.00";
                            }
                        } else {
                            return "0.00";
                        }
                    },
                }




            ];

            let tbl = window.jQuery(vm.$refs.student_table).DataTable({
                pageLength: 50,
                autoWidth: true,
                ordering: true,
                scrollCollapse: true,
                data: vm.students,
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

            tbl.on("page.dt", function() {

            });

            vm.loading = false;
            window.jQuery(".ui.tabular.menu .item").tab();
        });
    }
}