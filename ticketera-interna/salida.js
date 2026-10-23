({
	data: function() {
		return {
			result: {
				expiration_days: 0,
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
				buttons: settings.buttons || ["copy", "csv", "excel", "pdf", "print"]
			};

			if (settings.createdRow) config.createdRow = settings.createdRow;
			if (settings.order) config.order = settings.order;

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
			const payload = data && typeof data === "object" && !Array.isArray(data) ? data : {};
			const detail = Array.isArray(payload.detail) ? payload.detail : [];

			// La bandera se pinta con un label solo al mostrarse en pantalla; para
			// ordenar, buscar y exportar (csv/excel/pdf) se usa el texto "Sí"/"No".
			const expiredRender = function(value, type) {
				if (type !== "display") return value;
				return value === "Sí"
					? "<span class=\"ui red mini label\">Vencido</span>"
					: "<span class=\"ui green mini basic label\">En tiempo</span>";
			};

			vm.buildDataTable(vm.$refs.detail_table, detail, [
				{ title: "Fecha de creación", data: "Fecha de creación", defaultContent: "" },
				{ title: "Descripción", data: "Descripción", defaultContent: "" },
				{ title: "Etiqueta", data: "Etiqueta", defaultContent: "" },
				{ title: "Estado", data: "Estado", defaultContent: "" },
				{ title: "Vencido", data: "Vencido", defaultContent: "", render: expiredRender },
				{ title: "Días de antigüedad", data: "Días de antigüedad", defaultContent: 0 },
				{ title: "Área", data: "Área", defaultContent: "" },
				{ title: "Sede", data: "Sede", defaultContent: "" },
				{ title: "Asignado a", data: "Asignado a", defaultContent: "" },
				{ title: "Área de origen", data: "Área de origen", defaultContent: "" },
				{ title: "Sede de origen", data: "Sede de origen", defaultContent: "" },
				{ title: "Creado por", data: "Creado por", defaultContent: "" },
				{ title: "Carné", data: "Carné", defaultContent: "" },
				{ title: "Estudiante", data: "Estudiante", defaultContent: "" },
				{ title: "Comentario de finalización", data: "Comentario de finalización", defaultContent: "" },
				{ title: "Comentario de devolución", data: "Comentario de devolución", defaultContent: "" },
				{ title: "Última transferencia por", data: "Última transferencia por", defaultContent: "" },
				{ title: "Fecha de última transferencia", data: "Fecha de última transferencia", defaultContent: "" }
			], {
				// 18 columnas no caben en un PDF legible.
				buttons: ["copy", "csv", "excel", "print"],
				// Más recientes primero (la fecha tiene formato ordenable AAAA-MM-DD).
				order: [[0, "desc"]],
				createdRow: function(row, rowData) {
					if (rowData.Vencido === "Sí") window.jQuery(row).addClass("negative");
				}
			});

			vm.loading = false;
		}
	},
	mounted: function() {
		if (this.result) {
			this.buildTables(this.result);
		}
	}
})
