(async function () {
	try {
		const Op = models.Sequelize.Op;
		const enterpriseId = req.user.enterprise_id;

		const d = req.body.d || {};

		function splitIn(v) {
			if (!v) return null;
			const arr = String(v).split(",").map(function(x) { return x.trim(); }).filter(Boolean);
			return arr.length ? arr : null;
		}

		function parseSetup(raw) {
			if (!raw) return null;
			try {
				return typeof raw === "string" ? JSON.parse(raw) : raw;
			} catch (error) {
				return null;
			}
		}

		// La ticketera no guarda enterprise_id en el ticket: el "área" es un rol
		// del sistema, así que la empresa se resuelve por usr_role.enterprise_id.
		const roles = await models.usr_role.findAll({
			attributes: ["role_id", "name"],
			where: { enterprise_id: enterpriseId }
		});
		const roleIds = roles.map(function(r) { return r.role_id; });
		const roleNameById = new Map(roles.map(function(r) { return [String(r.role_id), r.name]; }));

		const where = { role_id: { [Op.in]: roleIds } };

		// Rango de fecha de creación. Mismo manejo que bitácora: la entrada manda
		// el día en UTC 00:00 / 23:59:59 y se corre +6 h para quedar en hora de
		// Guatemala (UTC-6).
		if (d.start_date || d.end_date) {
			const range = {};
			if (d.start_date) {
				const start = new Date(d.start_date);
				start.setHours(start.getHours() + 6);
				range[Op.gte] = start;
			}
			if (d.end_date) {
				const end = new Date(d.end_date);
				end.setHours(end.getHours() + 6);
				range[Op.lte] = end;
			}
			where.create_date = range;
		}

		// Área actual: se cruza con las áreas de la empresa para que un role_id
		// ajeno nunca amplíe el alcance del reporte.
		const roleFilter = splitIn(d.role);
		if (roleFilter) where.role_id = { [Op.in]: roleFilter.filter(function(id) { return roleIds.map(String).indexOf(id) !== -1; }) };

		const createRoleFilter = splitIn(d.create_role);
		if (createRoleFilter) where.create_role_id = { [Op.in]: createRoleFilter };

		const branchFilter = splitIn(d.branch);
		if (branchFilter) where.branch_id = { [Op.in]: branchFilter };

		const statusFilter = splitIn(d.status);
		if (statusFilter) where.status_id = { [Op.in]: statusFilter };

		const tagFilter = splitIn(d.tag);
		if (tagFilter) where.tag_id = { [Op.in]: tagFilter };

		// No. de ticket: acepta uno o varios números separados por coma o espacio.
		// Si se escribió algo sin ningún número válido, no debe devolver todo.
		if (d.ticket_id != null && String(d.ticket_id).trim() !== "") {
			const ticketIds = String(d.ticket_id).split(/[\s,;]+/).filter(function(x) { return /^\d+$/.test(x); });
			where.ticket_id = { [Op.in]: ticketIds };
		}

		const createUserFilter = splitIn(d.create_user);
		if (createUserFilter) where.create_user_id = { [Op.in]: createUserFilter };

		// Usuario asignado: el valor "none" representa "Sin asignar" (el bolsón del
		// área, assigned_user_id NULL) y puede combinarse con usuarios puntuales.
		const userFilter = splitIn(d.user);
		if (userFilter) {
			const ids = userFilter.filter(function(id) { return id !== "none"; });
			const conditions = [];
			if (ids.length) conditions.push({ assigned_user_id: { [Op.in]: ids } });
			if (userFilter.indexOf("none") !== -1) conditions.push({ assigned_user_id: null });
			where[Op.and] = (where[Op.and] || []).concat([{ [Op.or]: conditions }]);
		}

		if (d.studnt && d.studnt.student_id) where.student_id = d.studnt.student_id;

		models.internal_ticket.belongsTo(models.std_student, { foreignKey: "student_id" });

		const tickets = await models.internal_ticket.findAll({
			where: where,
			include: [
				{ model: models.std_student, attributes: ["student_id", "student_id_card", "name"], required: false }
			],
			order: [["ticket_id", "ASC"]]
		});

		// Catálogos y usuarios se resuelven aparte (sin FK en el modelo) para no
		// armar un JOIN de 3 veces usr_user contra la misma tabla.
		const userIds = new Set();
		tickets.forEach(function(t) {
			[t.assigned_user_id, t.create_user_id, t.last_sent_by_user_id].forEach(function(id) {
				if (id) userIds.add(id);
			});
		});

		const [users, branches, statuses, tags, areas, setting] = await Promise.all([
			userIds.size
				? models.usr_user.findAll({ attributes: ["user_id", "name"], where: { user_id: { [Op.in]: Array.from(userIds) } } })
				: Promise.resolve([]),
			models.std_branch.findAll({ attributes: ["branch_id", "name"] }),
			models.internal_ticket_status_type.findAll({ attributes: ["status_id", "code", "name"] }),
			models.internal_ticket_tag.findAll({ attributes: ["tag_id", "name"] }),
			models.internal_ticket_area.findAll({ attributes: ["role_id", "name"] }),
			models.internal_ticket_setting.findOne({ attributes: ["setup"], where: { enterprise_id: enterpriseId } })
		]);

		const userName = new Map(users.map(function(u) { return [String(u.user_id), u.name]; }));
		const branchName = new Map(branches.map(function(b) { return [String(b.branch_id), b.name]; }));
		const statusById = new Map(statuses.map(function(s) { return [String(s.status_id), s]; }));
		const tagName = new Map(tags.map(function(t) { return [String(t.tag_id), t.name]; }));
		// El nombre visible del área vive en internal_ticket_area; el del rol es
		// solo respaldo (p. ej. un área dada de baja que aún tiene tickets).
		const areaName = new Map(areas.map(function(a) { return [String(a.role_id), a.name]; }));

		function nameOfArea(roleId) {
			if (!roleId) return "Sin área";
			return areaName.get(String(roleId)) || roleNameById.get(String(roleId)) || "Sin área";
		}

		// expiration_days NULL/0/ausente = vencimiento desactivado para la empresa.
		const settingJson = parseSetup(setting && setting.setup) || {};
		const expirationDays = Number(settingJson.expiration_days) > 0 ? Number(settingJson.expiration_days) : 0;

		// "Vencido" no existe en la BD: se calcula al vuelo contra create_date, en
		// días calendario de Guatemala (igual que DATEDIFF(NOW(), create_date)).
		const GT_OFFSET_MS = 6 * 60 * 60 * 1000;
		function gtDay(date) {
			const shifted = new Date(new Date(date).getTime() - GT_OFFSET_MS);
			return Date.UTC(shifted.getUTCFullYear(), shifted.getUTCMonth(), shifted.getUTCDate());
		}
		function fmt(date) {
			if (!date) return "";
			const s = new Date(new Date(date).getTime() - GT_OFFSET_MS);
			const p = function(n) { return String(n).padStart(2, "0"); };
			return s.getUTCFullYear() + "-" + p(s.getUTCMonth() + 1) + "-" + p(s.getUTCDate()) + " " + p(s.getUTCHours()) + ":" + p(s.getUTCMinutes());
		}
		const today = gtDay(new Date());

		let detail = tickets.map(function(t) {
			const status = statusById.get(String(t.status_id));
			const statusCode = status ? status.code : null;
			const ageDays = Math.floor((today - gtDay(t.create_date)) / 86400000);
			const isFinished = statusCode === "FINISHED";
			const expired = !isFinished && expirationDays > 0 && ageDays >= expirationDays;
			const student = t.std_student;

			const areaLabel = nameOfArea(t.role_id);
			const branchLabel = t.branch_id ? (branchName.get(String(t.branch_id)) || "") : "";
			const createBranchLabel = t.create_branch_id ? (branchName.get(String(t.create_branch_id)) || "") : "";

			return {
				"No. Ticket": t.ticket_id,
				"Fecha de creación": fmt(t.create_date),
				Descripción: t.description || "",
				Etiqueta: t.tag_id ? (tagName.get(String(t.tag_id)) || "") : "",
				"Última actualización": fmt(t.update_date),
				Estado: status ? status.name : "Sin estado",
				Vencido: expired ? "Sí" : "No",
				"Días de antigüedad": ageDays,
				Área: areaLabel,
				Sede: branchLabel,
				"Asignado a": t.assigned_user_id ? (userName.get(String(t.assigned_user_id)) || "Usuario desconocido") : "Sin asignar",
				"Área de origen": nameOfArea(t.create_role_id),
				"Sede de origen": createBranchLabel,
				"Creado por": t.create_user_id ? (userName.get(String(t.create_user_id)) || "Usuario desconocido") : "",
				Carné: student ? student.student_id_card : "",
				Estudiante: student ? student.name : "Sin estudiante",
				"Comentario de finalización": t.finish_comment || "",
				"Comentario de devolución": t.return_comment || "",
				"Última transferencia por": t.last_sent_by_user_id ? (userName.get(String(t.last_sent_by_user_id)) || "") : "",
				"Fecha de última transferencia": fmt(t.last_sent_at)
			};
		});

		// Vencimiento se filtra al final porque no es un campo de la BD.
		if (d.expiration === "expired") detail = detail.filter(function(r) { return r.Vencido === "Sí"; });
		else if (d.expiration === "not_expired") detail = detail.filter(function(r) { return r.Vencido === "No"; });

		resolve({
			expiration_days: expirationDays,
			detail
		});
	} catch (error) {
		console.error("Error al generar el reporte de ticketera interna:", error);
		reject(error);
	}
})();
