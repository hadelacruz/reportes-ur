{
    data: function() {
        return {
            result: [],
            loading: true,
        }
    },
    methods: {},
    created: function() {},
    mounted: function() {
        let vm = this;
        // console.log("vm", vm)
        if (vm.result) {
            // console.log("res", vm.result)
            vm.loading = false
            //----------------------Tabla1 Gestiones---------------------------------------------------------------
            if (window.jQuery.fn.DataTable.isDataTable(vm.$refs.logs_table)) {
                window
                    .jQuery(vm.$refs.logs_table)
                    .DataTable()
                    .destroy();
            }
            window
                .jQuery(vm.$refs.logs_table)
                .find("tbody")
                .empty();

            let columns = [{
                    //Nombre estudiante
                    data: function(row) {
                        return row.std_student.name;
                    },
                }, {
                    //carne
                    data: function(row) {
                        return row.std_student.student_id_card;
                    },
                }, {
                    //tipificacion
                    data: function(row) {
                        return row.std_log_type.name;
                    },
                }, {
                    //comentario
                    data: function(row) {
                        let setup = JSON.parse(row.setup)
                        return setup.comment ? setup.comment : "No tiene comentario";
                    },
                }, {
                    //fecha de promesa de pago
                    data: function(row) {
                        let setup = JSON.parse(row.setup)
                        return setup.payment_promise_date ? setup.payment_promise_date : "No tiene fecha de promesa de pago";
                    },
                }, { //monto
                    data: function(row) {
                        let setup = JSON.parse(row.setup)
                        return setup.amount ? setup.amount : "No tiene monto";
                    },
                },
                { //fecha y hora de creacion
                    data: function(row) {
                        let date = new Date(row.create_date);
                        return date.toLocaleString("es-ES");
                    },
                },
                {
                    data: function(row) {
                        return row.usr_user ? row.usr_user.name : "No tiene Usuario creador.";
                    }
                },
            ]

            let tbl = window.jQuery(vm.$refs.logs_table).DataTable({
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