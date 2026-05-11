(async function () {
	try {
		const Op = models.Sequelize.Op;

		const d = req.body.d || {};
		const clsrmName = (d.clsrmName || "").trim();
		const sectionCode = (d.sectionCode || "").trim();

		const wherePre = {};
		const whereSection = {};
		const whereSectionSeason = {};
		const classroomWhere = {};
		let classroomRequired = !!clsrmName;

		if (d.branch) {
			classroomWhere.branch_id = { [Op.in]: d.branch.split(",") };
			classroomRequired = true;
		}

		if (clsrmName) {
			classroomWhere.name = clsrmName;
		}

		if (d.period) {
			whereSectionSeason.period_id = { [Op.in]: d.period.split(",") };
		}

		if (d.studying_cycle) {
			wherePre.studying_cycle_id = { [Op.in]: d.studying_cycle.split(",") };
		}

		if (d.course) {
			whereSection.course_id = { [Op.in]: d.course.split(",") };
		}

		if (d.professor) {
			whereSection.professor_id = { [Op.in]: d.professor.split(",") };
		}

		if (d.studying_time) {
			wherePre.studying_time_id = { [Op.in]: d.studying_time.split(",") };
		}

		models.crs_assignation_preinscription.belongsTo(models.crs_assignation_section, {
			foreignKey: "taken_by_section_id",
			targetKey: "section_id"
		});
		models.crs_assignation_preinscription.belongsTo(models.std_student, { foreignKey: "student_id" });
		models.crs_assignation_preinscription.belongsTo(models.std_career, { foreignKey: "career_id" });
		models.crs_assignation_preinscription.belongsTo(models.std_studying_cycle, { foreignKey: "studying_cycle_id" });
		models.crs_assignation_preinscription.belongsTo(models.std_studying_time, { foreignKey: "studying_time_id" });
		models.crs_assignation_section.belongsTo(models.crs_assignation_classroom, { foreignKey: "classroom_id" });
		models.crs_assignation_section.belongsTo(models.crs_assignation_season, { foreignKey: "season_id" });
		models.crs_assignation_section.belongsTo(models.crs_course, { foreignKey: "course_id" });
		models.crs_assignation_section.belongsTo(models.pfs_professor, { foreignKey: "professor_id" });
		models.crs_assignation_season.belongsTo(models.std_period, { foreignKey: "period_id" });
		models.crs_assignation_classroom.belongsTo(models.std_branch, { foreignKey: "branch_id" });

		const preinscriptions = await models.crs_assignation_preinscription.findAll({
			attributes: ["student_id", "taken_by_section_id", "career_id", "studying_cycle_id", "studying_time_id"],
			include: [
				{ model: models.std_student, attributes: ["name", "student_id_card"], required: false },
				{ model: models.std_career, attributes: ["name"], required: false },
				{ model: models.std_studying_cycle, attributes: ["name"], required: false },
				{ model: models.std_studying_time, attributes: ["name"], required: false },
				{
					model: models.crs_assignation_section,
					attributes: ["section_id", "name", "season_id", "classroom_id", "course_id", "professor_id", "setup"],
					required: true,
					where: whereSection,
					include: [
						{
							model: models.crs_assignation_season,
							attributes: ["season_id", "period_id"],
							required: true,
							where: whereSectionSeason,
							include: [
								{ model: models.std_period, attributes: ["name"], required: false }
							]
						},
						{
							model: models.crs_assignation_classroom,
							attributes: ["classroom_id", "name", "branch_id"],
							required: classroomRequired,
							where: Object.keys(classroomWhere).length > 0 ? classroomWhere : undefined,
							include: [
								{ model: models.std_branch, attributes: ["name"], required: false }
							]
						},
						{
							model: models.crs_course,
							attributes: ["course_id", "name"],
							required: false
						},
						{
							model: models.pfs_professor,
							attributes: ["setup"],
							required: false
						}
					]
				}
			],
			where: wherePre
		});

		const details = [];
		const grouped = new Map();

		preinscriptions.forEach(pre => {
			const section = pre.crs_assignation_section;
			const classroom = section && section.crs_assignation_classroom;
			const course = section && section.crs_course;
			const season = section && section.crs_assignation_season;
			const period = season && season.std_period;
			const student = pre.std_student;
			const career = pre.std_career;
			const studyingCycle = pre.std_studying_cycle;
			const studyingTime = pre.std_studying_time;
			const professor = section && section.pfs_professor;
			
			if (!classroom || !course || !period || !student) return;

			let sectionSetup = null;
			if (section && section.setup) {
				try {
					sectionSetup = typeof section.setup === "string" ? JSON.parse(section.setup) : section.setup;
				} catch (error) {
					sectionSetup = null;
				}
			}
			const codigoSeccionActual = (sectionSetup && sectionSetup.code) || "N/A";

			if (sectionCode && codigoSeccionActual !== sectionCode) return;

			const classroomId = classroom.classroom_id || null;
			const classroomName = classroom.name || "Sin aula";
			const courseId = course.course_id || null;
			const courseName = course.name || "Sin curso";
			const branchId = classroom.branch_id || null;
			const branchName = (classroom.std_branch && classroom.std_branch.name) || "No definida";
			const periodId = season.period_id || null;
			const periodName = period.name || "Sin periodo";
			const careerName = (career && career.name) || "Sin carrera";
			const careerId = pre.career_id || null;
			const studyingCycleName = (studyingCycle && studyingCycle.name) || "Sin ciclo de estudio";
			const studyingTimeName = (studyingTime && studyingTime.name) || "Sin jornada";
			const studentName = student.name || "Sin nombre";
			const studentCard = student.student_id_card || "";
			let professorSetup = null;
			if (professor && professor.setup) {
				try {
					professorSetup = typeof professor.setup === "string" ? JSON.parse(professor.setup) : professor.setup;
				} catch (error) {
					professorSetup = null;
				}
			}
			const professorName = professorSetup
				? ((professorSetup.name || "") + " " + (professorSetup.lastname || "")).trim() || "Sin catedrático"
				: "Sin catedrático";
			const profesorCode = (professorSetup && professorSetup.professor_code) || "N/A";

			const codigoSeccion = codigoSeccionActual;

			const groupKey = [classroomId || "", careerId || "", courseId || "", branchId || "", periodId || ""].join("|");

			details.push({
				Sede: branchName,
				"Nombre del alumno": studentName,
				Carné: studentCard,
				Aula: classroomName,
				"Codigo de Sección": codigoSeccion,
				Curso: courseName,
				Carrera: careerName,
				"Codigo Catedratico": profesorCode,
				"Nombre de catedrático": professorName,
				"Ciclo de estudio": studyingCycleName,
				Jornada: studyingTimeName,
				Periodo: periodName
			});

			if (!grouped.has(groupKey)) {
				grouped.set(groupKey, {
					Aula: classroomName,
					Curso: courseName,
					Carrera: careerName,
					Sede: branchName,
					"Codigo de Sección": codigoSeccion,
					Periodo: periodName,
					"Codigo Catedratico": profesorCode,
					"Nombre de catedrático": professorName,
					"Ciclo de estudio": studyingCycleName,
					Jornada: studyingTimeName,
					studentIds: new Set()
				});
			}

			grouped.get(groupKey).studentIds.add(pre.student_id);
		});

		details.sort((left, right) => {
			const sedeCompare = String(left.Sede).localeCompare(String(right.Sede), "es");
			if (sedeCompare !== 0) return sedeCompare;
			const aulaCompare = String(left.Aula).localeCompare(String(right.Aula), "es");
			if (aulaCompare !== 0) return aulaCompare;
			const alumnoCompare = String(left["Nombre del alumno"]).localeCompare(String(right["Nombre del alumno"]), "es");
			if (alumnoCompare !== 0) return alumnoCompare;
			return String(left.Periodo).localeCompare(String(right.Periodo), "es");
		});

		const summary = Array.from(grouped.values()).map(item => ({
			Aula: item.Aula,
			Carrera: item.Carrera,
			Curso: item.Curso,
			Sede: item.Sede,
			"Codigo de Sección": item["Codigo de Sección"],
			"Total alumnos": item.studentIds.size,
			"Codigo Catedratico": item["Codigo Catedratico"],
			"Nombre de catedrático": item["Nombre de catedrático"],
			"Ciclo de estudio": item["Ciclo de estudio"],
			Jornada: item.Jornada,
			Periodo: item.Periodo
		})).sort((left, right) => {
			const sedeCompare = String(left.Sede).localeCompare(String(right.Sede), "es");
			if (sedeCompare !== 0) return sedeCompare;
			const aulaCompare = String(left.Aula).localeCompare(String(right.Aula), "es");
			if (aulaCompare !== 0) return aulaCompare;
			const carreraCompare = String(left.Carrera || "").localeCompare(String(right.Carrera || ""), "es");
			if (carreraCompare !== 0) return carreraCompare;
			const cursoCompare = String(left.Curso).localeCompare(String(right.Curso), "es");
			if (cursoCompare !== 0) return cursoCompare;
			return String(left.Periodo).localeCompare(String(right.Periodo), "es");
		});

		resolve({
			details,
			summary
		});
	} catch (error) {
		console.error("Error al obtener alumnos por aula:", error);
		reject(error);
	}
})();
