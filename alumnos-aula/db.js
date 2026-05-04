(async function () {
	try {
		const Op = models.Sequelize.Op;

		const d = req.body.d || {};
		const clsrmName = (d.clsrmName || "").trim();

		const whereSection = {};
		const whereSectionSeason = {};
		const classroomWhere = {};
		let classroomRequired = !!clsrmName;

		if (d.branch) {
			classroomWhere.branch_id = { [Op.in]: d.branch.split(",") };
			classroomRequired = true;
		}

		if (clsrmName) {
			classroomWhere.name = { [Op.like]: "%" + clsrmName + "%" };
		}

		if (d.period) {
			whereSectionSeason.period_id = { [Op.in]: d.period.split(",") };
		}

		models.crs_assignation_preinscription.belongsTo(models.crs_assignation_section, {
			foreignKey: "taken_by_section_id",
			targetKey: "section_id"
		});
		models.crs_assignation_preinscription.belongsTo(models.std_student, { foreignKey: "student_id" });
		models.crs_assignation_section.belongsTo(models.crs_assignation_classroom, { foreignKey: "classroom_id" });
		models.crs_assignation_section.belongsTo(models.crs_assignation_season, { foreignKey: "season_id" });
		models.crs_assignation_section.belongsTo(models.crs_course, { foreignKey: "course_id" });
		models.crs_assignation_season.belongsTo(models.std_period, { foreignKey: "period_id" });
		models.crs_assignation_classroom.belongsTo(models.std_branch, { foreignKey: "branch_id" });

		const preinscriptions = await models.crs_assignation_preinscription.findAll({
			attributes: ["student_id", "taken_by_section_id"],
			include: [
				{
					model: models.crs_assignation_section,
					attributes: ["section_id", "name", "season_id", "classroom_id", "course_id"],
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
						}
					]
				}
			],
			where: {}
		});

		const grouped = new Map();

		preinscriptions.forEach(pre => {
			const section = pre.crs_assignation_section;
			const classroom = section && section.crs_assignation_classroom;
			const course = section && section.crs_course;
			const season = section && section.crs_assignation_season;
			const period = season && season.std_period;
			if (!classroom || !course || !period) return;

			const classroomId = classroom.classroom_id || null;
			const classroomName = classroom.name || "Sin aula";
			const courseId = course.course_id || null;
			const courseName = course.name || "Sin curso";
			const branchId = classroom.branch_id || null;
			const branchName = (classroom.std_branch && classroom.std_branch.name) || "No definida";
			const periodId = season.period_id || null;
			const periodName = period.name || "Sin periodo";

			const groupKey = [classroomId || "", courseId || "", branchId || "", periodId || ""].join("|");

			if (!grouped.has(groupKey)) {
				grouped.set(groupKey, {
					Aula: classroomName,
					Curso: courseName,
					Sede: branchName,
					Periodo: periodName,
					studentIds: new Set()
				});
			}

			grouped.get(groupKey).studentIds.add(pre.student_id);
		});

		const result = Array.from(grouped.values()).map(item => ({
			Aula: item.Aula,
			Curso: item.Curso,
			Sede: item.Sede,
			Periodo: item.Periodo,
			"Total alumnos": item.studentIds.size
		})).sort((left, right) => {
			const sedeCompare = String(left.Sede).localeCompare(String(right.Sede), "es");
			if (sedeCompare !== 0) return sedeCompare;
			const aulaCompare = String(left.Aula).localeCompare(String(right.Aula), "es");
			if (aulaCompare !== 0) return aulaCompare;
			const cursoCompare = String(left.Curso).localeCompare(String(right.Curso), "es");
			if (cursoCompare !== 0) return cursoCompare;
			return String(left.Periodo).localeCompare(String(right.Periodo), "es");
		});

		resolve(result);
	} catch (error) {
		console.error("Error al obtener alumnos por aula:", error);
		reject(error);
	}
})();
