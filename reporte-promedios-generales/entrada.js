{
    data: function() {
        return {
            api_url: "https://api_modul.uregional.net",
            user_branch: undefined,
            branch: undefined,
            career: undefined,
            period: undefined,
            studying_time: undefined,
            studying_cycle: undefined,
            professor: undefined,
            course: undefined,
            studnt: undefined,
            student_uuid: undefined,
            clsrmName: "",
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

        const searchInput = window.jQuery(_v.$refs.search).find('input.prompt');
        searchInput.on('input', function() {
            if (this.value.trim() === "") {
                _v.studnt = null;
                _v.student_uuid = null;
            }
        });

        window.jQuery(_v.$refs.form).addClass("loading");
        _v.$http.post(`${_v.api_url}/course/course/do-get-list-all`, {}, headers).then(rspnse => {
            if (rspnse.status == 200) {
                let rsp = rspnse.data;
                if (!rsp.success) console.error(rsp.error);
                else {

                    let courses = rsp.data ? rsp.data.map(b => {
                        return {
                            value: b.course_id,
                            name: b.name
                        };
                    }) : [];

                    window.jQuery(_v.$refs.course_dropdown).dropdown({
                        onChange: function(value) {
                            _v.course = value;
                        }
                    }).dropdown("setup menu", {
                        values: courses
                    });
                }
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

        _v.$http.post(`${_v.api_url}/student_configuration/do-get-configuration`, {}, headers).then(rspnse => {
            if (rspnse.status == 200) {
                let rsp = rspnse.data;
                if (!rsp.success) console.error(rsp.error);
                else {
                    //si hay rsp.data.std_branches, entonces branches es el mapeo de eso
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

                    let studying_times = rsp.data.std_studying_times ? rsp.data.std_studying_times.map(b => {
                        return {
                            value: b.studying_time_id,
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

                    window.jQuery(_v.$refs.carreer_dropdown).dropdown({
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

                    window.jQuery(_v.$refs.studying_time_dropdown).dropdown({
                        onChange: function(value) {
                            _v.studying_time = value;
                        }
                    }).dropdown("setup menu", {
                        values: studying_times
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