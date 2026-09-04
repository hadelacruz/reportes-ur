{
    data: function() {
        return {
            result: [],
            loading: true,
            totals: {
                total: 0,
                verified: 0,
                rejected: 0,
                pending: 0,
            },
        }
    },
    methods: {},
    created: function() {},
    mounted: function() {
        let vm = this;

        if (!Array.isArray(vm.result)) vm.result = [];

        vm.totals = vm.result.reduce(function(acc, row) {
            acc.total += 1;
            if (row.is_verified) acc.verified += 1;
            else if (row.is_rejected) acc.rejected += 1;
            else acc.pending += 1;
            return acc;
        }, { total: 0, verified: 0, rejected: 0, pending: 0 });

        vm.loading = false;

        if (window.jQuery.fn.DataTable.isDataTable(vm.$refs.records_table)) {
            window
                .jQuery(vm.$refs.records_table)
                .DataTable()
                .destroy();
        }
        window
            .jQuery(vm.$refs.records_table)
            .find("tbody")
            .empty();

        let columns = [
            {
                // Correlativo
                data: function(row) {
                    return row.record_code || "Sin correlativo";
                },
            }, {
                // Sede
                data: function(row) {
                    return row.branch || "Sin sede";
                },
            }, {
                // Periodo
                data: function(row) {
                    return row.period || "Sin periodo";
                },
            }, {
                // Tipo de acta
                data: function(row) {
                    return row.record_type || "Sin tipo";
                },
            }, {
                // Curso
                data: function(row) {
                    return row.course || "Sin curso";
                },
            }, {
                // Aula
                data: function(row) {
                    return row.classroom || "Sin aula";
                },
            }, {
                // Carrera
                data: function(row) {
                    return row.career || "Sin carrera";
                },
            }, {
                // Catedrático
                data: function(row) {
                    return row.professor || "Sin catedrático";
                },
            }, {
                // Ciclo
                data: function(row) {
                    return row.studying_cycle || "Sin ciclo";
                },
            }, {
                // Estado
                data: function(row) {
                    if (row.is_verified) return '<span class="ui green horizontal label">Verificada</span>';
                    if (row.is_rejected) return '<span class="ui red horizontal label">Rechazada</span>';
                    return '<span class="ui yellow horizontal label">Sin revisión</span>';
                },
            },
        ]

        let tbl = window.jQuery(vm.$refs.records_table).DataTable({
            pageLength: 50,
            autoWidth: true,
            ordering: true,
            scrollCollapse: true,
            data: vm.result,
            language: {
                url: "//cdn.datatables.net/plug-ins/1.10.21/i18n/Spanish.json"
            },
            columns: columns,
            dom: "lBfrtip",
            buttons: [
                'csv', 'excel', 'print'
            ]
        });

        window.jQuery(".ui.tabular.menu .item").tab();
    }
}
