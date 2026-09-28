({
	data: function() {
		return {
			api_url: "https://api_modul.uregional.net",
			user_branch: undefined,
			branch: undefined,
			period: undefined,
			professor: undefined
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
			_v.$http.post(`${_v.api_url}/professor/professor/do-get-all-list`, {}, headers),
			_v.$http.post(`${_v.api_url}/student_configuration/do-get-configuration`, {}, headers)
		]).then(responses => {
			const professorResponse = responses[0];
			const configResponse = responses[1];

			if (professorResponse.status === 200 && configResponse.status === 200) {
				const professorPayload = professorResponse.data;
				const configPayload = configResponse.data;

				if (!professorPayload.success) console.error(professorPayload.error);
				if (!configPayload.success) console.error(configPayload.error);

				const professors = professorPayload.data ? professorPayload.data.map(item => {
					let professorSetup = {};
					try {
						professorSetup = typeof item.setup === "string" ? JSON.parse(item.setup) : (item.setup || {});
					} catch (error) {
						professorSetup = {};
					}

					const fullName = ((professorSetup.name || "") + " " + (professorSetup.lastname || "")).trim() || "Sin catedrático";
					const nit = professorSetup.nit || "Sin NIT";

					return {
						value: item.professor_id,
						// El texto visible incluye NIT y nombre para que la búsqueda del
						// dropdown (que filtra sobre este texto) sirva para ambos criterios.
						name: `${fullName} — NIT: ${nit}`
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

				window.jQuery(_v.$refs.professor_dropdown).dropdown({
					// El texto visible es "Nombre — NIT: xxxx"; con fullTextSearch en
					// false (el default) Semantic UI solo busca por texto que EMPIEZA
					// igual, así que "Antonio" (segundo nombre) o el NIT (al final del
					// texto) nunca hacían match. fullTextSearch busca en cualquier parte.
					fullTextSearch: true,
					onChange: function(value) {
						_v.professor = value;
					}
				}).dropdown("setup menu", {
					values: professors
				});

				window.jQuery(_v.$refs.period_dropdown).dropdown({
					onChange: function(value) {
						_v.period = value;
					}
				}).dropdown("setup menu", {
					values: periods
				});
			} else {
				console.error(professorResponse, configResponse);
			}
		}).catch(error => {
			console.error(error);
		}).finally(() => {
			window.jQuery(_v.$refs.form).removeClass("loading");
		});
	}
})
