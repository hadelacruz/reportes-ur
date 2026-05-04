({
	data: function() {
		return {
			api_url: "https://api_modul.uregional.net",
			user_branch: undefined,
			branch: undefined,
			period: undefined,
			clsrmName: ""
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
			if (rspnse.status === 200) {
				let rsp = rspnse.data;
				if (!rsp.success) console.error(rsp.error);
				else if (rsp.data) {
					_v.user_branch = rsp.data.branch_id;
				}
			}
		}).catch(err => {
			console.error(err);
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

		window.jQuery(_v.$refs.form).addClass("loading");

		_v.$http.post(`${_v.api_url}/student_configuration/do-get-configuration`, {}, headers).then(rspnse => {
			if (rspnse.status === 200) {
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

					if (_v.user_branch) {
						window.jQuery(_v.$refs.branch_dropdown)
							.addClass("disabled")
							.dropdown("set selected", _v.user_branch);

						try { _v.branch = _v.user_branch; } catch (e) { console.error(e); }
					}

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
})
