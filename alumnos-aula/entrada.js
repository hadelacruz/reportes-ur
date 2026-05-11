({
	data: function() {
		return {
			api_url: "https://api_modul.uregional.net",
			user_branch: undefined,
			branch: undefined,
			studying_cycle: undefined,
			professor: undefined,
			course: undefined,
			period: undefined,
			studying_time: undefined,
			clsrmName: "",
			sectionCode: ""
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

		Promise.all([
			_v.$http.post(`${_v.api_url}/course/course/do-get-list-all`, {}, headers),
			_v.$http.post(`${_v.api_url}/professor/professor/do-get-all-list`, {}, headers),
			_v.$http.post(`${_v.api_url}/student_configuration/do-get-configuration`, {}, headers)
		]).then(responses => {
			const courseResponse = responses[0];
			const professorResponse = responses[1];
			const configResponse = responses[2];

			if (courseResponse.status === 200 && professorResponse.status === 200 && configResponse.status === 200) {
				const coursePayload = courseResponse.data;
				const professorPayload = professorResponse.data;
				const configPayload = configResponse.data;

				if (!coursePayload.success) console.error(coursePayload.error);
				if (!professorPayload.success) console.error(professorPayload.error);
				if (!configPayload.success) console.error(configPayload.error);

				const courses = coursePayload.data ? coursePayload.data.map(item => ({
					value: item.course_id,
					name: item.name
				})) : [];

				const professors = professorPayload.data ? professorPayload.data.map(item => {
					let professorSetup = {};
					try {
						professorSetup = typeof item.setup === "string" ? JSON.parse(item.setup) : (item.setup || {});
					} catch (error) {
						professorSetup = {};
					}

					return {
						value: item.professor_id,
						name: ((professorSetup.name || "") + " " + (professorSetup.lastname || "")).trim() || "Sin catedrático"
					};
				}) : [];

				const branches = configPayload.data.std_branches ? configPayload.data.std_branches.map(item => ({
					value: item.branch_id,
					name: item.name
				})) : [];

				const periods = configPayload.data.std_periods ? configPayload.data.std_periods.map(item => ({
					value: item.period_id,
					name: item.name
				})) : [];

				const studyingTimes = configPayload.data.std_studying_times ? configPayload.data.std_studying_times.map(item => ({
					value: item.studying_time_id,
					name: item.name
				})) : [];

				const studyingCycles = configPayload.data.std_studying_cycles ? configPayload.data.std_studying_cycles.map(item => ({
					value: item.studying_cycle_id,
					name: item.name
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

					try { _v.branch = _v.user_branch; } catch (error) { console.error(error); }
				}

				window.jQuery(_v.$refs.studying_cycle_dropdown).dropdown({
					onChange: function(value) {
						_v.studying_cycle = value;
					}
				}).dropdown("setup menu", {
					values: studyingCycles
				});

				window.jQuery(_v.$refs.professor_dropdown).dropdown({
					onChange: function(value) {
						_v.professor = value;
					}
				}).dropdown("setup menu", {
					values: professors
				});

				window.jQuery(_v.$refs.course_dropdown).dropdown({
					onChange: function(value) {
						_v.course = value;
					}
				}).dropdown("setup menu", {
					values: courses
				});

				window.jQuery(_v.$refs.studying_time_dropdown).dropdown({
					onChange: function(value) {
						_v.studying_time = value;
					}
				}).dropdown("setup menu", {
					values: studyingTimes
				});

				window.jQuery(_v.$refs.period_dropdown).dropdown({
					onChange: function(value) {
						_v.period = value;
					}
				}).dropdown("setup menu", {
					values: periods
				});
			} else {
				console.error(courseResponse, professorResponse, configResponse);
			}
		}).catch(error => {
			console.error(error);
		}).finally(() => {
			window.jQuery(_v.$refs.form).removeClass("loading");
		});
	}
})
