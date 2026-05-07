(async function () {
	try {
		const Op = models.Sequelize.Op;
		const d = req.body.d || {};

		const branchFilter = String(d.branch || "").trim();
		const studentCardFilter = String(d.student_card || d.student_id_card || "").trim();
		const professorFilter = String(d.professor || "").trim();
		const periodFilter = String(d.period || "").trim();
		const classroomFilter = String(d.clsrmName || d.classroom || "").trim();

		const whereStudent = {};
		const whereSection = {};
		const whereSeason = {};
		const classroomWhere = {};
		let classroomRequired = false;

		if (studentCardFilter !== "") {
			whereStudent.student_id_card = { [Op.eq]: studentCardFilter };
		}

		if (professorFilter !== "") {
			whereSection.professor_id = { [Op.in]: professorFilter.split(",") };
		}

		if (periodFilter !== "") {
			whereSeason.period_id = { [Op.in]: periodFilter.split(",") };
		}

		if (classroomFilter !== "") {
			classroomWhere.name = { [Op.eq]: classroomFilter };
			classroomRequired = true;
		}

		models.crs_assignation_student.belongsTo(models.std_student, { foreignKey: "student_id" });
		models.crs_assignation_student.belongsTo(models.crs_assignation_section, { foreignKey: "section_id", targetKey: "section_id" });
		models.crs_assignation_section.belongsTo(models.crs_course, { foreignKey: "course_id" });
		models.crs_assignation_section.belongsTo(models.pfs_professor, { foreignKey: "professor_id" });
		models.crs_assignation_section.belongsTo(models.crs_assignation_season, { foreignKey: "season_id" });
		models.crs_assignation_section.belongsTo(models.std_branch, { foreignKey: "branch_id" });
		models.crs_assignation_section.belongsTo(models.crs_assignation_classroom, { foreignKey: "classroom_id" });
		models.crs_assignation_season.belongsTo(models.std_period, { foreignKey: "period_id" });
		models.crs_assignation_classroom.belongsTo(models.std_branch, { foreignKey: "branch_id" });

		function parseScoreSetup(setup) {
			if (!setup) return [];
			try {
				const parsed = typeof setup === "string" ? JSON.parse(setup) : setup;
				return Array.isArray(parsed) ? parsed : [];
			} catch (error) {
				return [];
			}
		}

		function stripAccents(value) {
			return String(value || "")
				.normalize("NFD")
				.replace(/[\u0300-\u036f]/g, "")
				.toLowerCase()
				.trim()
				.replace(/\s+/g, "");
		}

		function normalizeStageName(stage) {
			const clean = stripAccents(stage);
			if (!clean) return "";
			if (/recuperacion1/.test(clean)) return "Recuperacion1";
			if (/recuperacion2/.test(clean)) return "Recuperacion2";
			if (/extraordinario1/.test(clean)) return "Extraordinario1";
			if (/extraordinario2/.test(clean)) return "Extraordinario2";
			return clean;
		}

		function hasNumericScore(value) {
			if (value === null || value === undefined) return false;
			const str = String(value).trim();
			if (str === "") return false;
			return !Number.isNaN(Number(str));
		}

		function getSpecialStageValue(scoreSetup, stageKey) {
			const stageItems = scoreSetup.filter(item => normalizeStageName(item && item.stage) === stageKey);
			if (stageItems.length === 0) return "NA";

			const numericItem = stageItems.find(item => hasNumericScore(item && item.score));
			if (numericItem) return String(numericItem.score).trim();

			const nspItem = stageItems.find(item => item && (item.nsp === true || normalizeStageName(item.name) === "nsp"));
			if (nspItem) return "NSP";

			const sdeItem = stageItems.find(item => item && (item.sde === true || normalizeStageName(item.name) === "sde"));
			if (sdeItem) return "SDE";

			const rawItem = stageItems.find(item => item && item.score !== null && item.score !== undefined && String(item.score).trim() !== "");
			if (rawItem) return String(rawItem.score).trim();

			return "NA";
		}

		function parseProfessorName(setup) {
			if (!setup) return "N/A";
			try {
				const parsed = typeof setup === "string" ? JSON.parse(setup) : setup;
				const name = ((parsed.name || "") + " " + (parsed.lastname || "")).trim();
				return name || "N/A";
			} catch (error) {
				return "N/A";
			}
		}

		const assignations = await models.crs_assignation_student.findAll({
			attributes: ["assignation_id", "section_id", "student_id"],
			include: [
				{
					model: models.std_student,
					attributes: ["name", "student_id_card", "status_code"],
					required: true,
					where: whereStudent
				},
				{
					model: models.crs_assignation_section,
					attributes: ["section_id", "name", "branch_id", "course_id", "season_id", "professor_id", "classroom_id"],
					required: true,
					where: whereSection,
					include: [
						{ model: models.crs_course, attributes: ["name", "course_id"], required: false },
						{ model: models.pfs_professor, attributes: ["setup", "professor_id"], required: false },
						{
							model: models.crs_assignation_season,
							attributes: ["season_id", "period_id"],
							required: true,
							where: whereSeason,
							include: [{ model: models.std_period, attributes: ["name", "period_id"], required: false }]
						},
						{
							model: models.crs_assignation_classroom,
							attributes: ["name", "classroom_id", "branch_id"],
							required: classroomRequired,
							where: classroomWhere,
							include: [{ model: models.std_branch, attributes: ["name", "branch_id"], required: false }]
						},
						{ model: models.std_branch, attributes: ["name", "branch_id"], required: false }
					]
				}
			]
		});

		const sectionIds = [...new Set(assignations.map(row => row.section_id).filter(Boolean))];
		const studentIds = [...new Set(assignations.map(row => row.student_id).filter(Boolean))];

		const scores = sectionIds.length > 0 && studentIds.length > 0
			? await models.crs_score.findAll({
					where: {
						section_id: { [Op.in]: sectionIds },
						student_id: { [Op.in]: studentIds }
					},
					attributes: ["section_id", "student_id", "setup"]
				})
			: [];

		const scoreMap = new Map();
		scores.forEach(score => {
			scoreMap.set(score.section_id + "-" + score.student_id, score);
		});

		let result = assignations.map(row => {
			const student = row.std_student || {};
			const section = row.crs_assignation_section || {};
			const course = section.crs_course || {};
			const professor = section.pfs_professor || {};
			const season = section.crs_assignation_season || {};
			const period = season.std_period || {};
			const classroom = section.crs_assignation_classroom || {};
			const classroomBranch = classroom.std_branch || {};
			const sectionBranch = section.std_branch || {};
			const scoreRecord = scoreMap.get(row.section_id + "-" + row.student_id);
			const scoreSetup = parseScoreSetup(scoreRecord && scoreRecord.setup);

			const sedeName = classroomBranch.name || sectionBranch.name || "N/A";
			const sedeBranchId = classroom.branch_id || section.branch_id || null;

			return {
				sede: sedeName,
				sede_branch_id: sedeBranchId,
				carne: student.student_id_card || "N/A",
				alumno: student.name || "N/A",
				curso: course.name || "N/A",
				profesor: parseProfessorName(professor.setup),
				aula: classroom.name || "N/A",
				periodo: period.name || "N/A",
				extraordinario_1: getSpecialStageValue(scoreSetup, "Extraordinario1"),
				extraordinario_2: getSpecialStageValue(scoreSetup, "Extraordinario2"),
				recuperacion_1: getSpecialStageValue(scoreSetup, "Recuperacion1"),
				recuperacion_2: getSpecialStageValue(scoreSetup, "Recuperacion2")
			};
		});

		if (branchFilter !== "") {
			const branchIds = branchFilter.split(",").map(value => String(value).trim()).filter(Boolean);
			result = result.filter(row => branchIds.indexOf(String(row.sede_branch_id)) !== -1);
		}

		resolve(result);
	} catch (error) {
		console.error("Error en alumnos-pagar-examen:", error);
		reject(error);
	}
})();
