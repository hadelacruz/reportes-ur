({
	data: function() {
		return {
			result: [],
			loading: true
		};
	},
	watch: {
		result: function(newVal) {
			this.loading = true;
			this.$nextTick(() => {
				this.renderTable(newVal);
			});
		}
	},
	methods: {
		renderTable: function(dataArray) {
			let vm = this;
			vm.loading = true;

			if (window.jQuery.fn.DataTable.isDataTable(vm.$refs.notes_table)) {
				window.jQuery(vm.$refs.notes_table).DataTable().destroy();
			}
			window.jQuery(vm.$refs.notes_table).find("tbody").empty();

			if (!dataArray || !Array.isArray(dataArray) || dataArray.length === 0) {
				vm.loading = false;
				return;
			}

			const columns = [
				{ data: "sede", defaultContent: "N/A" },
				{ data: "carne", defaultContent: "N/A" },
				{ data: "alumno", defaultContent: "N/A" },
				{ data: "curso", defaultContent: "N/A" },
				{ data: "profesor", defaultContent: "N/A" },
				{ data: "aula", defaultContent: "N/A" },
				{ data: "periodo", defaultContent: "N/A" },
				{ data: "extraordinario_1", defaultContent: "NA" },
				{ data: "extraordinario_2", defaultContent: "NA" },
				{ data: "recuperacion_1", defaultContent: "NA" },
				{ data: "recuperacion_2", defaultContent: "NA" }
			];

			window.jQuery(vm.$refs.notes_table).DataTable({
				data: dataArray,
				columns: columns,
				columnDefs: [
					{ targets: "_all", className: "text-center" }
				],
				language: {
					url: "//cdn.datatables.net/plug-ins/1.10.21/i18n/Spanish.json"
				},
				pageLength: 50,
				paging: true,
				searching: true,
				ordering: true,
				dom: 'lBfrtip',
				buttons: [
					'copy', 'csv', 'excel', 'pdf', 'print'
				]
			});

			vm.loading = false;
		}
	},
	mounted: function() {
		if (this.result && Array.isArray(this.result) && this.result.length > 0) {
			this.loading = true;
			this.$nextTick(() => {
				this.renderTable(this.result);
			});
		} else {
			this.loading = false;
		}
	}
})
