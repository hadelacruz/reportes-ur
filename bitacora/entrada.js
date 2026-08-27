//acá codigo original
{
    data: function() {
        return {
            api_url: "https://api_modul.uregional.net",
            log_type: undefined,
            studnt: undefined,
            student_uuid: undefined,
            creationdate: undefined,
            branch: undefined,
            user: undefined,
            start_date: "",
            end_date: "",
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

        window.jQuery(_v.$refs.search).search({
            apiSettings: {
                action: "search student",
                beforeXHR: function(xhr) {
                    let token = _v.$session.get("token");
                    if (token) {
                        xhr.setRequestHeader("x-access-token", token);
                    }

                    return xhr;
                },
                onResponse: function(response) {
                    if (!response.success) console.log(response.error);
                    else {
                        var _response = {
                            results: []
                        };
                        response.data.map(r => {
                            _response.results.push({
                                title: r.name,
                                description: r.create_date,
                                customer: r
                            });
                        });
                        return _response;
                    }
                }
            },
            onSelect(result) {
                let token = _v.$session.get("token");
                let headers = null;
                if (token) {
                    headers = {
                        headers: {
                            "x-access-token": token
                        }
                    };
                }
                _v.$http.post(`${_v.api_url}/student/do-get`, {
                        u: result.customer.uuid
                    }, headers)
                    .then(response => {
                        if (response && response.data) {
                            if (response.data.success) {

                                _v.studnt = response.data.data;
                                _v.student_uuid = _v.studnt.uuid;
                                console.log(_v.studnt.uuid);
                            } else console.error(response.data.error)
                        } else console.log("no response received")
                    })
                    .catch(err => {
                        console.error(err);
                    });
            }
        });

        window.jQuery(_v.$refs.form).addClass("loading");
        
        _v.$http.post(`${_v.api_url}/student_configuration/do-get-configuration`, {}, headers).then(rspnse => {
            if (rspnse.status == 200) {
                let rsp = rspnse.data;
                if (!rsp.success) console.error(rsp.error);
                else {
                    // console.log("ksjdhask", rsp.data);
                    let branches = rsp.data.std_branches ? rsp.data.std_branches.map(b => {
                        return {
                            value: b.branch_id,
                            name: b.name
                        };
                    }) : [];

                    let users = rsp.data.std_users ? rsp.data.std_users.map(b => {
                        return {
                            value: b.user_id,
                            name: b.name
                        };
                    }) : [];

                    window.jQuery(_v.$refs.branch_dropdown).dropdown({
                        fullTextSearch: "exact",
                        onChange: function(value) {
                            _v.branch = value;
                        }
                    }).dropdown("setup menu", {
                        values: branches
                    });

                    window.jQuery(_v.$refs.user_dropdown).dropdown({
                        fullTextSearch: "exact",
                        onChange: function(value) {
                            _v.user = value;
                        }
                    }).dropdown("setup menu", {
                        values: users
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

        _v.$http.post(`${_v.api_url}/student_log_type/do-get-list`, {}, headers).then(rspnse => {
            if (rspnse.status == 200) {
                let rsp = rspnse.data;
                if (!rsp.success) console.error(rsp.error);
                else {

                    let log_types = rsp.data ? rsp.data.map(b => {
                        return {
                            value: b.type_id,
                            name: b.name
                        };
                    }) : [];

                    window.jQuery(_v.$refs.log_type_dropdown).dropdown({
                        onChange: function(value) {
                            _v.log_type = value;
                        }
                    }).dropdown("setup menu", {
                        values: log_types
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
        
        window.jQuery(this.$refs.creationdate).calendar({
            type: 'date',
            today: true,
            onChange: function(value) {
                _v.creationdate = value;
            }
        });
        
        // Calendario de fecha inicial
        window.jQuery(this.$refs.rangestart).calendar({
            type: "date",
            today: true,
            endCalendar: window.jQuery(this.$refs.rangeend),
            onChange: function(value) {
                // _v.start_date = value;
                if (value) {
                    // Ajustar a UTC 00:00:00
                    const utcDate = new Date(Date.UTC(value.getFullYear(), value.getMonth(), value.getDate(), 0, 0, 0, 0));
                    _v.start_date = utcDate.toISOString();
                }
            }
        });

        // Calendario de fecha final
        window.jQuery(this.$refs.rangeend).calendar({
            type: "date",
            today: true,
            startCalendar: window.jQuery(this.$refs.rangestart),
            onChange: function(value) {
                // _v.end_date = value;
                if (value) {
                    // Ajustar a UTC 23:59:59
                    const utcDate = new Date(Date.UTC(value.getFullYear(), value.getMonth(), value.getDate(), 23, 59, 59, 999));
                    _v.end_date = utcDate.toISOString();
                }
            }
        });
    }
}