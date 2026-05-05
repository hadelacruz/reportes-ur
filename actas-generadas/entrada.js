{
  data: function() {
    return {
      season_id: "",
      branch_id: "",
      career_id: "",
      studying_cycle_id: "",
      studying_time_id: "",
      professor_id: "",
      record_type: "",
      record_status: "",
      classroom_name: "",
      date_from: "",
      date_to: ""
    }
  },
  methods: {},
  created: function() {},
  mounted: function() {
    var _v = this;
    var token = vm.$session.get("token");
    var apiHost = window.apihost || "http://localhost:3100";
    var headers = null;
    if (token) {
      headers = { headers: { "x-access-token": token } };
    }
    _v.$http.post(apiHost + "/course/record/do-get-seasons", {}, headers).then(function(rspnse) {
      if (rspnse && rspnse.data && rspnse.data.success) {
        var vals = rspnse.data.data.map(function(s) {
          return { value: s.season_id, name: s.name };
        });
        window.jQuery(_v.$refs.season_dropdown).dropdown({
          onChange: function(value) { _v.season_id = value; }
        }).dropdown("setup menu", { values: vals });
      }
    }).catch(function(err) { console.error("seasons", err); });
    _v.$http.post(apiHost + "/course/assignation/do-get-dropdowns", {}, headers).then(function(rspnse) {
      if (rspnse && rspnse.data && rspnse.data.success) {
        var data = rspnse.data.data;
        if (data.branches) {
          var brVals = data.branches.map(function(b) {
            return { value: b.branch_id, name: b.name };
          });
          window.jQuery(_v.$refs.branch_dropdown).dropdown({
            onChange: function(value) { _v.branch_id = value; }
          }).dropdown("setup menu", { values: brVals });
        }
        if (data.careers) {
          var crVals = data.careers.map(function(c) {
            return { value: c.career_id, name: c.name };
          });
          window.jQuery(_v.$refs.career_dropdown).dropdown({
            onChange: function(value) { _v.career_id = value; }
          }).dropdown("setup menu", { values: crVals });
        }
        if (data.cycles) {
          var cyVals = data.cycles.map(function(c) {
            return { value: c.studying_cycle_id, name: c.name };
          });
          window.jQuery(_v.$refs.cycle_dropdown).dropdown({
            onChange: function(value) { _v.studying_cycle_id = value; }
          }).dropdown("setup menu", { values: cyVals });
        }
        if (data.times) {
          var tmVals = data.times.map(function(t) {
            return { value: t.studying_time_id, name: t.name };
          });
          window.jQuery(_v.$refs.time_dropdown).dropdown({
            onChange: function(value) { _v.studying_time_id = value; }
          }).dropdown("setup menu", { values: tmVals });
        }
        if (data.professors) {
          var pfVals = data.professors.map(function(p) {
            var name = "Sin nombre";
            if (p.setup) {
              var n = ((p.setup.name || "") + " " + (p.setup.lastname || "")).trim();
              if (n) name = n;
            }
            return { value: p.professor_id, name: name };
          });
          pfVals.sort(function(a, b) { return a.name.localeCompare(b.name); });
          window.jQuery(_v.$refs.professor_dropdown).dropdown({
            onChange: function(value) { _v.professor_id = value; }
          }).dropdown("setup menu", { values: pfVals });
        }
      }
    }).catch(function(err) { console.error("dropdowns", err); });
    var types = [
      { value: "Fase 1", name: "Fase 1" },
      { value: "Fase 2", name: "Fase 2" },
      { value: "Fase Final", name: "Fase Final" },
      { value: "Fase Extraordinario 1", name: "Extraordinario 1" },
      { value: "Fase Extraordinario 2", name: "Extraordinario 2" },
      { value: "Recuperacion 1", name: "Recuperacion 1" },
      { value: "Recuperacion 2", name: "Recuperacion 2" }
    ];
    window.jQuery(_v.$refs.type_dropdown).dropdown({
      onChange: function(value) { _v.record_type = value; }
    }).dropdown("setup menu", { values: types });
    var statuses = [
      { value: "all", name: "Ambos" },
      { value: "con_nota", name: "Con Nota" },
      { value: "nsp", name: "NSP" }
    ];
    window.jQuery(_v.$refs.status_dropdown).dropdown({
      onChange: function(value) { _v.record_status = value; }
    }).dropdown("setup menu", { values: statuses });
  }
}
