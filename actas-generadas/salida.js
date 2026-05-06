{
  data: function() { return { loading: false } },
  methods: {
    totalActas: function() {
      if (!this.result || !this.result.length) return 0;
      return this.result.reduce(function(s, r) { return s + r.cant_actas; }, 0);
    },
    totalAlumnosValidos: function() {
      if (!this.result || !this.result.length) return 0;
      return this.result.reduce(function(s, r) { return s + r.cant_alumnos; }, 0);
    },
    totalAlumnos: function() {
      if (!this.result || !this.result.length) return 0;
      return this.result.reduce(function(s, r) { return s + (r.cant_alumnos_total || 0); }, 0);
    }
  },
  created: function() {},
  mounted: function() {
    var _v = this;
    var reportName = "Actas Generadas por Fases";
    if (_v.result && _v.result.length > 0) {
      if (window.jQuery.fn.DataTable.isDataTable(_v.$refs.table)) {
        window.jQuery(_v.$refs.table).DataTable().destroy();
      }
      setTimeout(function() {
        window.jQuery(_v.$refs.table).DataTable({
          dom: "lBfrtip",
          buttons: [
            { extend: "copy", title: reportName },
            { extend: "csv", title: reportName, filename: reportName },
            { extend: "excel", title: reportName, filename: reportName },
            { extend: "pdf", title: reportName, filename: reportName },
            { extend: "print", title: reportName }
          ]
        });
      }, 300);
    }
  }
}
