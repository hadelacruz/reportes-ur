{
    data: function() {
        return {
            result: [], // array recibido desde entrada.js
            loading: true,
        }
    },
    watch: {
        // Cuando entrada.js reciba los resultados y altere esto, se relanza DataTable
        result: function(newVal) {
            this.buildTable(newVal);
        }
    },
    methods: {
        buildTable: function(dataArray) {
            let vm = this;
            if(!dataArray || !Array.isArray(dataArray) || dataArray.length === 0){
                if (window.jQuery.fn.DataTable.isDataTable(vm.$refs.notes_table)) {
                    window.jQuery(vm.$refs.notes_table).DataTable().destroy();
                }
                window.jQuery(vm.$refs.notes_table).empty();
                vm.loading = false;
                return;
            }

            const PRACTICAL_STAGES = new Set(["Seminario", "Plan Práctico", "Desarrollo", "Informe Final", "Consolidado"]);
            const META_COLUMNS = ["Sede", "Periodo"];

            // Orden de columnas: meta -> regulares -> prácticas
            const allKeys = Object.keys(dataArray[0]);
            const metaKeys = META_COLUMNS.filter(k => allKeys.includes(k));
            const stageKeys = allKeys.filter(k => !META_COLUMNS.includes(k));
            const regularStageKeys = stageKeys.filter(k => !PRACTICAL_STAGES.has(k));
            const practicalStageKeys = stageKeys.filter(k => PRACTICAL_STAGES.has(k));
            const orderedKeys = [...metaKeys, ...regularStageKeys, ...practicalStageKeys];

            const tableColumns = orderedKeys.map(k => {
                return {
                    data: k,
                    defaultContent: META_COLUMNS.includes(k) ? "" : "0.00%"
                };
            });

            if (window.jQuery.fn.DataTable.isDataTable(vm.$refs.notes_table)) {
                window.jQuery(vm.$refs.notes_table).DataTable().destroy();
            }
            window.jQuery(vm.$refs.notes_table).empty(); // Destruye DOM interno viejo

            // Header agrupado (2 niveles): metadata + fases regulares/prácticas
            let headerHtml = "<thead class=\"ui inverted grey table\">";
            headerHtml += "<tr>";
            metaKeys.forEach(k => {
                headerHtml += `<th rowspan=\"2\" class=\"text-center\" style=\"text-align:center !important; vertical-align:middle !important;\">${k.toUpperCase()}</th>`;
            });
            if (regularStageKeys.length > 0) {
                headerHtml += `<th colspan=\"${regularStageKeys.length}\" class=\"text-center\" style=\"text-align:center !important; vertical-align:middle !important;\">CURSOS REGULARES</th>`;
            }
            if (practicalStageKeys.length > 0) {
                headerHtml += `<th colspan=\"${practicalStageKeys.length}\" class=\"text-center\" style=\"text-align:center !important; vertical-align:middle !important;\">CURSOS PRÁCTICOS</th>`;
            }
            headerHtml += "</tr>";

            headerHtml += "<tr>";
            regularStageKeys.forEach(k => {
                headerHtml += `<th class=\"text-center\" style=\"text-align:center !important; vertical-align:middle !important;\">${k.toUpperCase()}</th>`;
            });
            practicalStageKeys.forEach(k => {
                headerHtml += `<th class=\"text-center\" style=\"text-align:center !important; vertical-align:middle !important;\">${k.toUpperCase()}</th>`;
            });
            headerHtml += "</tr>";
            headerHtml += "</thead>";

            window.jQuery(vm.$refs.notes_table).append(headerHtml);

            // Iniciar de nuevo el data table con columnas y datos en caliente
            window.jQuery(vm.$refs.notes_table).DataTable({
                data: dataArray,
                columns: tableColumns,
                columnDefs: [
                    { targets: "_all", className: "text-center" }
                ],
                orderCellsTop: true,
                headerCallback: function(thead) {
                    window.jQuery(thead).find("th").css({
                        "text-align": "center",
                        "vertical-align": "middle"
                    });
                },
                language: {
                    url: "//cdn.datatables.net/plug-ins/1.10.21/i18n/Spanish.json"
                },
                paging: true,
                searching: true,
                ordering: true,
                dom: 'Bfrtip',
                buttons: [
                    'copy', 'csv', 'excel', 'pdf', 'print'
                ]
            });
            
            vm.loading = false;
        }
    },
    mounted: function() {
        window.jQuery(".ui.tabular.menu .item").tab();
        
        // Si Modul ya inyectó la data antes de montar el componente, construimos la tabla de inmediato
        if (this.result && this.result.length > 0) {
            this.buildTable(this.result);
        }
    }
}