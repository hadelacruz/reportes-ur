({
	data: function() {
		return {
			result: [],
			loading: true,
		}
	},
	watch: {
		result: function(newVal) {
			this.buildTable(newVal);
		}
	},
	methods: {
		buildTable: function(dataArray) {
			let vm = this;

			if (window.jQuery.fn.DataTable.isDataTable(vm.$refs.notes_table)) {
				window.jQuery(vm.$refs.notes_table).DataTable().destroy();
			}

			window.jQuery(vm.$refs.notes_table).empty();
			window.jQuery(vm.$refs.notes_table).append(
				'<thead class="ui inverted grey table">' +
				'<tr>' +
				'<th>Sede</th>' +
				'<th>Aula</th>' +
				'<th>Curso</th>' +
				'<th>Periodo</th>' +
				'<th>Total alumnos</th>' +
				'</tr>' +
				'</thead><tbody></tbody>'
			);

			window.jQuery(vm.$refs.notes_table).DataTable({
				data: Array.isArray(dataArray) ? dataArray : [],
				columns: [
					{ data: "Sede", defaultContent: "" },
					{ data: "Aula", defaultContent: "" },
					{ data: "Curso", defaultContent: "" },
					{ data: "Periodo", defaultContent: "" },
					{ data: "Total alumnos", defaultContent: 0 }
				],
				columnDefs: [{ targets: "_all", className: "text-center" }],
				language: {
					url: "//cdn.datatables.net/plug-ins/1.10.21/i18n/Spanish.json"
				},
				paging: true,
				searching: true,
				ordering: true,
				dom: "Bfrtip",
				buttons: ["copy", "csv", "excel", "pdf", "print"]
			});

			vm.loading = false;
		}
	},
	mounted: function() {
		window.jQuery(".ui.tabular.menu .item").tab();
		if (this.result && this.result.length >= 0) {
			this.buildTable(this.result);
		}
	}
})
