({
	data: function() {
		return {
			result: {
				summary: [],
				detail: []
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
			const payload = data && typeof data === "object" && !Array.isArray(data) ? data : { summary: [], detail: [] };
			const summary = Array.isArray(payload.summary) ? payload.summary : [];
			const detail = Array.isArray(payload.detail) ? payload.detail : [];

			vm.buildDataTable(vm.$refs.summary_table, summary, [
				{ title: "NIT", data: "NIT", defaultContent: "" },
				{ title: "Nombre de catedrático", data: "Nombre de catedrático", defaultContent: "" },
				{ title: "Sedes", data: "Sedes", defaultContent: "" },
				{ title: "Cantidad de cursos asignados", data: "Cantidad de cursos asignados", defaultContent: 0 },
				{ title: "Periodo", data: "Periodo", defaultContent: "" }
			], {
				sumColumns: ["Cantidad de cursos asignados"]
			});

			vm.buildDataTable(vm.$refs.detail_table, detail, [
				{ title: "Sede", data: "Sede", defaultContent: "" },
				{ title: "NIT", data: "NIT", defaultContent: "" },
				{ title: "Nombre de catedrático", data: "Nombre de catedrático", defaultContent: "" },
				{ title: "Curso", data: "Curso", defaultContent: "" },
				{ title: "Día", data: "Día", defaultContent: "" },
				{ title: "Horario", data: "Horario", defaultContent: "" },
				{ title: "Aulas", data: "Aulas", defaultContent: "" },
				{ title: "Códigos de Sección", data: "Códigos de Sección", defaultContent: "" },
				{ title: "Aulas unificadas", data: "Aulas unificadas", defaultContent: 0 },
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
