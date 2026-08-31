({
	data: function() {
		return {
			result: {
				details: [],
				bySection: [],
				byClassroom: [],
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
			buildDataTable: function(tableRef, dataArray, columns, options) {
				const settings = options || {};
				const sumColumns = Array.isArray(settings.sumColumns) ? settings.sumColumns : [];

				if (window.jQuery.fn.DataTable.isDataTable(tableRef)) {
					window.jQuery(tableRef).DataTable().destroy();
				}

				window.jQuery(tableRef).empty();
				let markup = "<thead class=\"ui inverted grey table\"><tr>" + columns.map(column => `<th>${column.title}</th>`).join("") + "</tr></thead><tbody></tbody>";
				if (sumColumns.length > 0) {
					markup += "<tfoot><tr>" + columns.map(() => "<th></th>").join("") + "</tr></tfoot>";
				}
				window.jQuery(tableRef).append(markup);

				const config = {
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
				};

				if (sumColumns.length > 0) {
					config.footerCallback = function() {
						const api = this.api();
						const rows = api.rows({ search: "applied" }).data().toArray();
						columns.forEach(function(column, index) {
							if (index === 0) {
								window.jQuery(api.column(index).footer()).html("TOTAL");
								return;
							}
							if (sumColumns.indexOf(column.data) === -1) {
								window.jQuery(api.column(index).footer()).html("");
								return;
							}
							const total = rows.reduce(function(accumulated, row) {
								const value = Number(row[column.data]);
								return accumulated + (isNaN(value) ? 0 : value);
							}, 0);
							window.jQuery(api.column(index).footer()).html(total);
						});
					};
				}

				window.jQuery(tableRef).DataTable(config);
			},
			buildTables: function(data) {
				let vm = this;
				const payload = data && typeof data === "object" && !Array.isArray(data) ? data : { details: Array.isArray(data) ? data : [], bySection: Array.isArray(data) ? data : [], byClassroom: Array.isArray(data) ? data : [] };
				const details = Array.isArray(payload.details) ? payload.details : [];
				const bySection = Array.isArray(payload.bySection) ? payload.bySection : [];
				const byClassroom = Array.isArray(payload.byClassroom) ? payload.byClassroom : [];
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

				vm.buildDataTable(vm.$refs.summary_table, bySection, [
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
					{ title: "Horario", data: "Horario", defaultContent: "" },
					{ title: "Periodo", data: "Periodo", defaultContent: "" }
				]);

				vm.buildDataTable(vm.$refs.resumen_table, byClassroom, [
					{ title: "Sede", data: "Sede", defaultContent: "" },
					{ title: "Carreras", data: "Carreras", defaultContent: "" },
					{ title: "Ciclo", data: "Ciclo de estudio", defaultContent: "" },
					{ title: "Jornada", data: "Jornada", defaultContent: "" },
					{ title: "Aula", data: "Aula", defaultContent: "" },
					{ title: "Cursos", data: "Cursos", defaultContent: "" },
					{ title: "Activos", data: "Activos", defaultContent: 0 },
					{ title: "Suspendidos", data: "Suspendidos", defaultContent: 0 },
					{ title: "De Baja", data: "De Baja", defaultContent: 0 },
					{ title: "Fallecidos", data: "Fallecidos", defaultContent: 0 },
					{ title: "Total General", data: "Total General", defaultContent: 0 },
					{ title: "Alumnos con más de 2 cursos con NSP", data: "Alumnos con NSP>3", defaultContent: 0 },
					{ title: "Activos sin NSP", data: "Activos sin NSP", defaultContent: 0 },
					{ title: "Periodo", data: "Periodo", defaultContent: "" }
				]);

				const bySectionLessThan10 = bySection.filter(item => item["Total General"] < 10);

				vm.buildDataTable(vm.$refs.secciones_menos_10_table, bySectionLessThan10, [
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

				vm.buildDataTable(vm.$refs.resumen_general_table, summary, [
					{ title: "Sede", data: "Sede", defaultContent: "" },
					{ title: "Periodo", data: "Periodo", defaultContent: "" },
					{ title: "Asignados", data: "Asignados", defaultContent: 0 },
					{ title: "No asignados (vista grupos)", data: "No asignados (vista grupos)", defaultContent: 0 },
					{ title: "No asignados (vista de cursos extra)", data: "No asignados (vista de cursos extra)", defaultContent: 0 },
					{ title: "TOTAL", data: "TOTAL", defaultContent: 0 }
				], {
					sumColumns: [
						"Asignados",
						"No asignados (vista grupos)",
						"No asignados (vista de cursos extra)",
						"TOTAL"
					]
				});

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
