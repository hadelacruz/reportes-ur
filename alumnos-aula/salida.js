({
	data: function() {
		return {
			result: {
				details: [],
				summary: []
			},
			loading: true,
		}
	},
	watch: {
		result: function(newVal) {
			this.buildTables(newVal);
		}
	},
	methods: {
			buildDataTable: function(tableRef, dataArray, columns) {
				if (window.jQuery.fn.DataTable.isDataTable(tableRef)) {
					window.jQuery(tableRef).DataTable().destroy();
				}

				window.jQuery(tableRef).empty();
				window.jQuery(tableRef).append("<thead class=\"ui inverted grey table\"><tr>" + columns.map(column => `<th>${column.title}</th>`).join("") + "</tr></thead><tbody></tbody>");

				window.jQuery(tableRef).DataTable({
					data: Array.isArray(dataArray) ? dataArray : [],
					columns: columns,
					columnDefs: [{ targets: "_all", className: "text-center" }],
					language: {
						url: "//cdn.datatables.net/plug-ins/1.10.21/i18n/Spanish.json"
					},
					pageLength: 50,
					paging: true,
					searching: true,
					ordering: true,
					dom: "lBfrtip",
					buttons: ["copy", "csv", "excel", "pdf", "print"]
				});
			},
			buildTables: function(data) {
				let vm = this;
				const payload = data && typeof data === "object" && !Array.isArray(data) ? data : { details: Array.isArray(data) ? data : [], summary: Array.isArray(data) ? data : [] };
				const details = Array.isArray(payload.details) ? payload.details : [];
				const summary = Array.isArray(payload.summary) ? payload.summary : [];

				vm.buildDataTable(vm.$refs.detail_table, details, [
					{ title: "Sede", data: "Sede", defaultContent: "" },
					{ title: "Codigo de Sección", data: "Codigo de Sección", defaultContent: "" },
					{ title: "Aula", data: "Aula", defaultContent: "" },
					{ title: "Carné", data: "Carné", defaultContent: "" },
					{ title: "Nombre del alumno", data: "Nombre del alumno", defaultContent: "" },
					{ title: "Carrera", data: "Carrera", defaultContent: "" },
					{ title: "Curso", data: "Curso", defaultContent: "" },
					{ title: "Codigo Catedratico", data: "Codigo Catedratico", defaultContent: "" },
					{ title: "Catedrático", data: "Nombre de catedrático", defaultContent: "" },
					{ title: "Ciclo de estudio", data: "Ciclo de estudio", defaultContent: "" },
					{ title: "Jornada", data: "Jornada", defaultContent: "" },
					{ title: "Periodo", data: "Periodo", defaultContent: "" }
				]);

				vm.buildDataTable(vm.$refs.summary_table, summary, [
					{ title: "Sede", data: "Sede", defaultContent: "" },
					{ title: "Codigo de Sección", data: "Codigo de Sección", defaultContent: "" },
					{ title: "Aula", data: "Aula", defaultContent: "" },
					{ title: "Carrera", data: "Carrera", defaultContent: "" },
					{ title: "Curso", data: "Curso", defaultContent: "" },
					{ title: "Activos", data: "Activos", defaultContent: 0 },
					{ title: "Suspendidos", data: "Suspendidos", defaultContent: 0 },
					{ title: "De baja", data: "De baja", defaultContent: 0 },
					{ title: "Fallecido", data: "Fallecido", defaultContent: 0 },
					{ title: "Total General", data: "Total General", defaultContent: 0 },
					{ title: "Codigo Catedratico", data: "Codigo Catedratico", defaultContent: "" },
					{ title: "Catedrático", data: "Nombre de catedrático", defaultContent: "" },
					{ title: "Ciclo de estudio", data: "Ciclo de estudio", defaultContent: "" },
					{ title: "Jornada", data: "Jornada", defaultContent: "" },
					{ title: "Periodo", data: "Periodo", defaultContent: "" }
				]);
				
				vm.loading = false;
		}
	},
	mounted: function() {
		window.jQuery(".ui.tabular.menu .item").tab();
		if (this.result) {
			this.buildTables(this.result);
		}
	}
})
