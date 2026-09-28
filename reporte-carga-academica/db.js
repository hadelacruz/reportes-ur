(async function () {
	try {
		const Op = models.Sequelize.Op;

		const d = req.body.d || {};

		const whereSection = { professor_id: { [Op.ne]: null } };
		const whereSeason = {};
		const classroomWhere = {};

		if (d.branch) classroomWhere.branch_id = { [Op.in]: d.branch.split(",") };
		if (d.period) whereSeason.period_id = { [Op.in]: d.period.split(",") };
		if (d.professor) whereSection.professor_id = { [Op.in]: d.professor.split(",") };

		models.crs_assignation_section.belongsTo(models.crs_assignation_season, { foreignKey: "season_id" });
		models.crs_assignation_section.belongsTo(models.crs_assignation_classroom, { foreignKey: "classroom_id" });
		models.crs_assignation_section.belongsTo(models.crs_course, { foreignKey: "course_id" });
		models.crs_assignation_section.belongsTo(models.pfs_professor, { foreignKey: "professor_id" });
		models.crs_assignation_season.belongsTo(models.std_period, { foreignKey: "period_id" });
		models.crs_assignation_classroom.belongsTo(models.std_branch, { foreignKey: "branch_id" });

		const sections = await models.crs_assignation_section.findAll({
			attributes: ["section_id", "name", "season_id", "classroom_id", "course_id", "professor_id", "setup"],
			where: whereSection,
			include: [
				{
					model: models.crs_assignation_season,
					attributes: ["season_id", "period_id"],
					required: true,
					where: whereSeason,
					include: [
						{ model: models.std_period, attributes: ["name"], required: false }
					]
				},
				{
					model: models.crs_assignation_classroom,
					attributes: ["classroom_id", "name", "branch_id"],
					required: true,
					where: Object.keys(classroomWhere).length > 0 ? classroomWhere : undefined,
					include: [
						{ model: models.std_branch, attributes: ["name"], required: false }
					]
				},
				{ model: models.crs_course, attributes: ["course_id", "name"], required: false },
				{ model: models.pfs_professor, attributes: ["professor_id", "setup"], required: true }
			]
		});

		function parseSetup(raw) {
			if (!raw) return null;
			try {
				return typeof raw === "string" ? JSON.parse(raw) : raw;
			} catch (error) {
				return null;
			}
		}

		// day_index no tiene tabla propia en la BD (viaja dentro del setup de la
		// sección como entero); se traduce con este mapa solo para que la pestaña
		// de detalle sea legible, nunca se usa para decidir si dos secciones son
		// la misma clase (para eso ya alcanza con el texto de "schedule").
		const dayNames = { "0": "Domingo", "1": "Lunes", "2": "Martes", "3": "Miércoles", "4": "Jueves", "5": "Viernes", "6": "Sábado", "7": "Domingo" };

		// Regla de negocio: dos (o más) secciones del MISMO catedrático cuentan como
		// UN solo curso asignado cuando comparten sede, periodo, curso y horario
		// (día + franja horaria), sin importar en cuántas aulas o secciones estén
		// repartidas. Si cambia el horario (o cualquiera de los otros campos),
		// se cuentan como cursos distintos, aunque el nombre del curso se repita.
		const groups = new Map();

		sections.forEach(function(section) {
			const season = section.crs_assignation_season;
			const period = season && season.std_period;
			const classroom = section.crs_assignation_classroom;
			const branch = classroom && classroom.std_branch;
			const course = section.crs_course;
			const professor = section.pfs_professor;

			if (!season || !classroom || !professor) return;

			const sectionSetup = parseSetup(section.setup) || {};
			const professorSetup = parseSetup(professor.setup) || {};

			const branchId = classroom.branch_id || null;
			const branchName = (branch && branch.name) || "Sin sede";
			const periodId = season.period_id || null;
			const periodName = (period && period.name) || "Sin periodo";
			const courseId = section.course_id || null;
			const courseName = (course && course.name) || "Sin curso";
			const professorId = section.professor_id;
			const professorName = ((professorSetup.name || "") + " " + (professorSetup.lastname || "")).trim() || "Sin catedrático";
			const professorNit = professorSetup.nit || "N/A";
			const dayIndex = (sectionSetup.day_index != null && sectionSetup.day_index !== "") ? String(sectionSetup.day_index) : "N/A";
			const dayName = dayIndex === "N/A" ? "N/A" : (dayNames[dayIndex] || ("Día " + dayIndex));
			const horario = sectionSetup.schedule || "N/A";
			const codigoSeccion = sectionSetup.code || section.name || "N/A";
			const classroomName = classroom.name || "Sin aula";

			const groupKey = [branchId || "", periodId || "", courseId || "", professorId, dayIndex, horario].join("|");

			if (!groups.has(groupKey)) {
				groups.set(groupKey, {
					Sede: branchName,
					Periodo: periodName,
					Curso: courseName,
					nit: professorNit,
					professorName: professorName,
					professorId: professorId,
					periodId: periodId,
					Dia: dayName,
					Horario: horario,
					aulas: new Set(),
					secciones: new Set()
				});
			}

			const group = groups.get(groupKey);
			group.aulas.add(classroomName);
			group.secciones.add(codigoSeccion);
		});

		const detail = Array.from(groups.values()).map(function(g) {
			return {
				Sede: g.Sede,
				Periodo: g.Periodo,
				NIT: g.nit,
				"Nombre de catedrático": g.professorName,
				Curso: g.Curso,
				Día: g.Dia,
				Horario: g.Horario,
				Aulas: Array.from(g.aulas).sort((a, b) => String(a).localeCompare(String(b), "es")).join(", "),
				"Códigos de Sección": Array.from(g.secciones).sort((a, b) => String(a).localeCompare(String(b), "es")).join(", "),
				"Aulas unificadas": g.aulas.size
			};
		}).sort(function(a, b) {
			const sedeCompare = String(a.Sede).localeCompare(String(b.Sede), "es");
			if (sedeCompare !== 0) return sedeCompare;
			const catCompare = String(a["Nombre de catedrático"]).localeCompare(String(b["Nombre de catedrático"]), "es");
			if (catCompare !== 0) return catCompare;
			return String(a.Curso).localeCompare(String(b.Curso), "es");
		});

		const summaryMap = new Map();
		groups.forEach(function(g) {
			const key = g.professorId + "|" + g.periodId;
			if (!summaryMap.has(key)) {
				summaryMap.set(key, {
					nit: g.nit,
					professorName: g.professorName,
					Periodo: g.Periodo,
					sedes: new Set(),
					cantidad: 0
				});
			}
			const item = summaryMap.get(key);
			item.sedes.add(g.Sede);
			item.cantidad += 1;
		});

		const summary = Array.from(summaryMap.values()).map(function(item) {
			return {
				NIT: item.nit,
				"Nombre de catedrático": item.professorName,
				Sedes: Array.from(item.sedes).sort((a, b) => String(a).localeCompare(String(b), "es")).join(", "),
				"Cantidad de cursos asignados": item.cantidad,
				Periodo: item.Periodo
			};
		}).sort(function(a, b) {
			const catCompare = String(a["Nombre de catedrático"]).localeCompare(String(b["Nombre de catedrático"]), "es");
			if (catCompare !== 0) return catCompare;
			return String(a.Periodo).localeCompare(String(b.Periodo), "es");
		});

		resolve({
			summary,
			detail
		});
	} catch (error) {
		console.error("Error al calcular la carga académica:", error);
		reject(error);
	}
})();
