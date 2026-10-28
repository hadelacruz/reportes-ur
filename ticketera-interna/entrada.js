({
	data: function() {
		return {
			api_url: "https://api_modul.uregional.net",
			// Endpoints de la ticketera. do-get-areas es el catálogo completo
			// (config); do-get-all-areas y do-get-my-areas están filtrados por
			// permisos del usuario y no sirven para un reporte global.
			ticket_endpoints: {
				areas: "/internal-ticket/do-get-areas",
				statuses: "/internal-ticket/do-get-status-types",
				tags: "/internal-ticket/do-get-tags",
				members: "/internal-ticket/do-get-area-members"
			},
			area_users: [],
			user_branch: undefined,
			start_date: "",
			end_date: "",
			studnt: undefined,
			role: undefined,
			create_role: undefined,
			branch: undefined,
			status: undefined,
			user: undefined,
			create_user: undefined,
			tag: undefined,
			ticket_id: "",
			expiration: ""
		}
	},
	methods: {
		// Usuario asignado: si hay áreas elegidas solo se listan los miembros de
		// esas áreas; "Sin asignar" (el bolsón) siempre está disponible.
		refreshUserDropdown: function() {
			let _v = this;
			const selectedRoles = _v.role ? String(_v.role).split(",") : [];

			const members = _v.area_users.filter(item => {
				return selectedRoles.length === 0 || selectedRoles.indexOf(String(item.role_id)) !== -1;
			});

			// Un usuario con varios roles de área llega repetido; se deja uno solo.
			const seen = {};
			const values = [{ value: "none", name: "Sin asignar" }];
			members.forEach(item => {
				if (seen[item.user_id]) return;
				seen[item.user_id] = true;
				values.push({ value: item.user_id, name: item.name });
			});

			window.jQuery(_v.$refs.user_dropdown).dropdown("clear").dropdown("setup menu", {
				values: values
			});
		}
	},
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

		// Convierte la respuesta de un catálogo en [{ value, name }]; si el
		// endpoint falla, el dropdown queda vacío y el error en consola.
		// La respuesta puede venir como arreglo o como objeto que contiene el
		// arreglo (p. ej. { areas: [...] }); se toma el primer arreglo que haya.
		function toList(data) {
			if (Array.isArray(data)) return data;
			if (data && typeof data === "object") {
				const found = Object.keys(data).map(key => data[key]).filter(Array.isArray)[0];
				if (found) return found;
			}
			return [];
		}

		function loadCatalog(path, body) {
			return _v.$http.post(`${_v.api_url}${path}`, body || {}, headers).then(rspnse => {
				if (rspnse.status === 200) {
					const rsp = rspnse.data;
					if (!rsp.success) {
						console.error("[ticketera]", path, rsp.error);
						return [];
					}
					const list = toList(rsp.data);
					// Diagnóstico: si el catálogo llega vacío, deja ver la respuesta cruda.
					if (list.length === 0) console.warn("[ticketera] catálogo vacío", path, rsp.data);
					return list;
				}
				console.error("[ticketera]", path, rspnse);
				return [];
			}).catch(err => {
				console.error("[ticketera]", path, err);
				return [];
			});
		}

		// Cada dropdown se arma por separado: si uno falla, los demás siguen.
		function setupDropdown(ref, values, onChange, options) {
			try {
				window.jQuery(ref).dropdown(Object.assign({
					fullTextSearch: true,
					onChange: onChange
				}, options || {})).dropdown("setup menu", {
					values: values
				});
			} catch (error) {
				console.error("[ticketera] dropdown", error);
			}
		}

		window.jQuery(_v.$refs.form).addClass("loading");

		// Los miembros se piden por área (el endpoint es por área) y cada uno
		// queda marcado con el role_id del área, que es lo que usa la cascada.
		function loadMembers(areaItems) {
			return Promise.all(areaItems.map(area => {
				if (area.role_id == null) return [];
				return loadCatalog(_v.ticket_endpoints.members, { role_id: area.role_id, area_id: area.area_id }).then(items => {
					return items.map(item => ({
						user_id: item.user_id,
						name: item.name || item.username || (item.usr_user && item.usr_user.name) || ("Usuario " + item.user_id),
						role_id: area.role_id
					}));
				});
			})).then(lists => [].concat.apply([], lists));
		}

		// Etiquetas: el endpoint puede devolver solo las globales o las del área
		// pedida, así que se consulta sin filtro y una vez por área, y se juntan
		// sin repetir (no importa de qué área sea ni si no tiene área).
		function loadTags(areaItems) {
			const requests = [loadCatalog(_v.ticket_endpoints.tags)].concat(areaItems.filter(area => area.role_id != null).map(area => {
				return loadCatalog(_v.ticket_endpoints.tags, { role_id: area.role_id, area_id: area.area_id });
			}));
			return Promise.all(requests).then(lists => {
				const seen = {};
				return [].concat.apply([], lists).filter(item => {
					if (item.tag_id == null || seen[item.tag_id]) return false;
					seen[item.tag_id] = true;
					return true;
				});
			});
		}

		Promise.all([
			_v.$http.post(`${_v.api_url}/student_configuration/do-get-configuration`, {}, headers),
			loadCatalog(_v.ticket_endpoints.areas),
			loadCatalog(_v.ticket_endpoints.statuses)
		]).then(responses => {
			return Promise.all([loadMembers(responses[1]), loadTags(responses[1])]).then(extra => responses.concat(extra));
		}).then(responses => {
			const configResponse = responses[0];
			// Áreas repetidas (una por sede) se reducen a una por role_id.
			const seenAreas = {};
			const areas = responses[1].filter(item => {
				if (item.role_id == null || seenAreas[item.role_id]) return false;
				seenAreas[item.role_id] = true;
				return true;
			}).map(item => ({ value: item.role_id, name: item.name }));
			const statuses = responses[2].map(item => ({ value: item.status_id, name: item.name }));
			const tags = responses[4].map(item => ({ value: item.tag_id, name: item.name }))
				.sort((a, b) => String(a.name).localeCompare(String(b.name), "es"));
			_v.area_users = responses[3];

			let branches = [];
			if (configResponse.status === 200 && configResponse.data.success) {
				const configData = configResponse.data.data || {};
				branches = configData.std_branches ? configData.std_branches.map(item => ({
					value: item.branch_id,
					name: item.name
				})) : [];
			} else {
				console.error(configResponse);
			}

			// Las áreas con sede aparecen una sola vez: el filtro es por rol y la
			// sede se filtra aparte.
			setupDropdown(_v.$refs.role_dropdown, areas, function(value) {
				_v.role = value;
				_v.refreshUserDropdown();
			});
			setupDropdown(_v.$refs.create_role_dropdown, areas, function(value) {
				_v.create_role = value;
			});
			setupDropdown(_v.$refs.status_dropdown, statuses, function(value) {
				_v.status = value;
			});
			setupDropdown(_v.$refs.tag_dropdown, tags, function(value) {
				_v.tag = value;
			});

			setupDropdown(_v.$refs.branch_dropdown, branches, function(value) {
				_v.branch = value;
			});
			if (_v.user_branch) {
				window.jQuery(_v.$refs.branch_dropdown)
					.addClass("disabled")
					.dropdown("set selected", _v.user_branch);

				try { _v.branch = _v.user_branch; } catch (error) { console.error(error); }
			}

			setupDropdown(_v.$refs.user_dropdown, [], function(value) {
				_v.user = value;
			});
			_v.refreshUserDropdown();

			// "Creado por" usa el mismo universo de usuarios con rol de área.
			const creators = [];
			const seen = {};
			_v.area_users.forEach(item => {
				if (seen[item.user_id]) return;
				seen[item.user_id] = true;
				creators.push({ value: item.user_id, name: item.name });
			});
			setupDropdown(_v.$refs.create_user_dropdown, creators, function(value) {
				_v.create_user = value;
			});
		}).catch(error => {
			console.error(error);
		}).finally(() => {
			window.jQuery(_v.$refs.form).removeClass("loading");
		});

		window.jQuery(_v.$refs.expiration_dropdown).dropdown({
			onChange: function(value) {
				_v.expiration = value;
			}
		});

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
							// La búsqueda ya acepta nombre o carné; en la lista se
							// muestran juntos como "Nombre - Carné".
							_response.results.push({
								title: r.student_id_card ? (r.name + " - " + r.student_id_card) : r.name,
								customer: r
							});
						});
						return _response;
					}
				}
			},
			onSelect(result) {
				_v.$http.post(`${_v.api_url}/student/do-get`, {
					u: result.customer.uuid
				}, headers).then(response => {
					if (response && response.data) {
						if (response.data.success) _v.studnt = response.data.data;
						else console.error(response.data.error);
					} else console.log("no response received");
				}).catch(err => {
					console.error(err);
				});
			}
		});

		// Rango de fecha de creación (se envía en UTC; db.js lo corrige a UTC-6).
		window.jQuery(_v.$refs.rangestart).calendar({
			type: "date",
			today: true,
			endCalendar: window.jQuery(_v.$refs.rangeend),
			onChange: function(value) {
				if (value) {
					const utcDate = new Date(Date.UTC(value.getFullYear(), value.getMonth(), value.getDate(), 0, 0, 0, 0));
					_v.start_date = utcDate.toISOString();
				} else _v.start_date = "";
			}
		});

		window.jQuery(_v.$refs.rangeend).calendar({
			type: "date",
			today: true,
			startCalendar: window.jQuery(_v.$refs.rangestart),
			onChange: function(value) {
				if (value) {
					const utcDate = new Date(Date.UTC(value.getFullYear(), value.getMonth(), value.getDate(), 23, 59, 59, 999));
					_v.end_date = utcDate.toISOString();
				} else _v.end_date = "";
			}
		});
	}
})
