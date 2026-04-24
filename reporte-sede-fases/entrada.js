{
    data: function() {
        return {
            api_url: "https://api_modul.uregional.net",
            branch: undefined,
            period: undefined,
            course_type: "all"
        }
    },
    methods: {},
    created: function() {},
    mounted: function() {
        let _v = this;

        let token = vm.$session.get("token");
        let headers = null;
        if (token) {
            headers = {
                headers: {
                    "x-access-token": token
                }
            };
        }

        window.jQuery(_v.$refs.form).addClass("loading");

        // Tipo de curso
        let courseTypes = [
            { value: "all", name: "Ambos" },
            { value: "regular", name: "Regular" },
            { value: "practical", name: "Práctico" }
        ];
        window.jQuery(_v.$refs.course_type_dropdown).dropdown({
            onChange: function(value) {
                _v.course_type = value;
            }
        }).dropdown("setup menu", {
            values: courseTypes
        });

        // Valor por defecto
        window.jQuery(_v.$refs.course_type_dropdown).dropdown("set selected", "all");

        // 1. Cargar Configuración de Sedes y Periodos
        _v.$http.post(`${_v.api_url}/student_configuration/do-get-configuration`, {}, headers).then(rspnse => {
            if (rspnse.status == 200) {
                let rsp = rspnse.data;
                if (!rsp.success) console.error(rsp.error);
                else {
                    // Sedes
                    let branches = rsp.data.std_branches ? rsp.data.std_branches.map(b => {
                        return {
                            value: b.branch_id,
                            name: b.name
                        };
                    }) : [];
                    
                    // Periodos
                    let periods = rsp.data.std_periods ? rsp.data.std_periods.map(b => {
                        return {
                            value: b.period_id,
                            name: b.name
                        };
                    }) : [];

                    window.jQuery(_v.$refs.branch_dropdown).dropdown({
                        onChange: function(value) {
                            _v.branch = value;
                        }
                    }).dropdown("setup menu", {
                        values: branches
                    });

                    window.jQuery(_v.$refs.period_dropdown).dropdown({
                        onChange: function(value) {
                            _v.period = value;
                        }
                    }).dropdown("setup menu", {
                        values: periods
                    });
                }
            } else {
                console.error(rspnse);
            }
        }).catch(err => {
            console.error(err);
        }).finally(() => {
            window.jQuery(_v.$refs.form).removeClass("loading");
        });
    }
}