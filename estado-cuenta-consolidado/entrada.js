{
    data: function() {
        return {
            api_url: "https://api_modul.uregional.net",
            branch: undefined,
            career: undefined,
            period: undefined,
            movement_type: undefined
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

                    let times = rsp.data.std_studying_times ? rsp.data.std_studying_times.map(b => {
                        return {
                            value: b.std_studying_time_id,
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

                    window.jQuery(_v.$refs.carreer_dropdown).dropdown({
                        onChange: function(value) {
                            _v.career = value;
                        }
                    }).dropdown("setup menu", {
                        values: carreers
                    });

                    window.jQuery(_v.$refs.time_dropdown).dropdown({
                        onChange: function(value) {
                            _v.time = value;
                        }
                    }).dropdown("setup menu", {
                        values: times
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
            /*let vls = rspnse.data.data.map(u => {
                return { value: u.user_id, name: u.username };
            });*/

        }).catch(err => {
            console.error(err);
        });

        /**
         * Movement types
         */
        _v.$http.post(`${_v.api_url}/account_movement_type/do-get-list`, {}, headers).then(rspnse => {
            if (rspnse.status == 200) {
                let rsp = rspnse.data;
                if (!rsp.success) console.error(rsp.error);
                else {
                    let dta = rsp.data;
                    console.log("movement types", dta);

                    let movements = dta.map(b => {
                        return {
                            value: b.type_id,
                            name: b.name
                        };
                    });

                    window.jQuery(_v.$refs.movement_dropdown).dropdown({
                        onChange: function(value) {
                            _v.movement_type = value;
                        }
                    }).dropdown("setup menu", {
                        values: movements
                    });
                }
            } else {
                console.error(rspnse);
            }

        }).catch(err => {
            console.error(err);
        });
    }
}