({
	data: function() {
		return {
			api_url: "https://api_modul.uregional.net",
			branch: undefined,
			student_card: "",
			professor: undefined,
			period: undefined,
			clsrmName: ""
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

		_v.$http.post(`${_v.api_url}/student_configuration/do-get-configuration`, {}, headers).then(rspnse => {
			if (rspnse.status == 200) {
				let rsp = rspnse.data;
				if (!rsp.success) console.error(rsp.error);
				else {
					let branches = rsp.data.std_branches ? rsp.data.std_branches.map(b => ({
						value: b.branch_id,
						name: b.name
					})) : [];

					let periods = rsp.data.std_periods ? rsp.data.std_periods.map(b => ({
						value: b.period_id,
						name: b.name
					})) : [];

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
		});

		_v.$http.post(`${_v.api_url}/professor/professor/do-get-all-list`, {}, headers).then(rspnse => {
			if (rspnse.status == 200) {
				let rsp = rspnse.data;
				if (!rsp.success) console.error(rsp.error);
				else {
					let professors = rsp.data ? rsp.data.map(b => ({
						value: b.professor_id,
						name: b.setup.name + " " + b.setup.lastname
					})) : [];

					window.jQuery(_v.$refs.professor_dropdown).dropdown({
						onChange: function(value) {
							_v.professor = value;
						}
					}).dropdown("setup menu", {
						values: professors
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
})
