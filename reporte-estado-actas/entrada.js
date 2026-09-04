{
    data: function() {
        return {
            api_url: "https://api_modul.uregional.net",
            user_branch: undefined,
            branch: undefined,
            period: undefined,
            career: undefined,
            professor: undefined,
            studying_cycle: undefined,
            record_type: undefined,
            record_status: "",
            record_code: "",
        }
    },
    methods: {},
    created: function() {
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
        _v.$http.post(`${_v.api_url}/course/season/do-get-user-branch`, {}, headers).then(rspnse => {
            if (rspnse.status == 200) {
                let rsp = rspnse.data;
                if (!rsp.success) console.error(rsp.error);
                else {
                    if (rsp.data) _v.user_branch = rsp.data.branch_id;
                }
            }
        });
    },
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

        window.jQuery(_v.$refs.record_type_dropdown).dropdown({
            onChange: function(value) {
                _v.record_type = value;
            }
        });

        window.jQuery(_v.$refs.status_dropdown).dropdown({
            onChange: function(value) {
                _v.record_status = value;
            }
        });

        _v.$http.post(`${_v.api_url}/professor/professor/do-get-all-list`, {}, headers).then(rspnse => {
            if (rspnse.status == 200) {
                let rsp = rspnse.data;
                if (!rsp.success) console.error(rsp.error);
                else {

                    let professors = rsp.data ? rsp.data.map(b => {
                        return {
                            value: b.professor_id,
                            name: b.setup.name + " " + b.setup.lastname
                        };
                    }) : [];

                    window.jQuery(_v.$refs.professor_dropdown).dropdown({
                        onChange: function(value) {
                            _v.professor = value;
                        }
                    }).dropdown("setup menu", {
                        values: professors
                    });
                }
            }
        });

        window.jQuery(_v.$refs.form).addClass("loading");
        _v.$http.post(`${_v.api_url}/student_configuration/do-get-configuration`, {}, headers).then(rspnse => {
            if (rspnse.status == 200) {
                let rsp = rspnse.data;
                if (!rsp.success) console.error(rsp.error);
                else {
                    let branches = rsp.data.std_branches ? rsp.data.std_branches.map(b => {
                        return {
                            value: b.branch_id,
                            name: b.name
                        };
                    }) : [];
                    let carreers = rsp.data.std_careers ? rsp.data.std_careers.map(b => {
                        return {
                            value: b.career_id,
                            name: b.name
                        };
                    }) : [];

                    let periods = rsp.data.std_periods ? rsp.data.std_periods.map(b => {
                        return {
                            value: b.period_id,
                            name: b.name
                        };
                    }) : [];

                    let studying_cycles = rsp.data.std_studying_cycles ? rsp.data.std_studying_cycles.map(b => {
                        return {
                            value: b.studying_cycle_id,
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
                    if (_v.user_branch) {
                        window.jQuery(_v.$refs.branch_dropdown).addClass("disabled").dropdown("set selected", _v.user_branch);
                    }

                    window.jQuery(_v.$refs.career_dropdown).dropdown({
                        onChange: function(value) {
                            _v.career = value;
                        }
                    }).dropdown("setup menu", {
                        values: carreers
                    });

                    window.jQuery(_v.$refs.period_dropdown).dropdown({
                        onChange: function(value) {
                            _v.period = value;
                        }
                    }).dropdown("setup menu", {
                        values: periods
                    });

                    window.jQuery(_v.$refs.studying_cycle_dropdown).dropdown({
                        onChange: function(value) {
                            _v.studying_cycle = value;
                        }
                    }).dropdown("setup menu", {
                        values: studying_cycles
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
