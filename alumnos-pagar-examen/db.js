(async function () {
	try {
		const Op = models.Sequelize.Op;
		const d = req.body.d || {};

		// Punteo mínimo de aprobación: define quién debe llevar recuperación
		const PASSING_SCORE = 61;

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

		function normalizeItemName(value) {
			return stripAccents(value).replace(/[^a-z0-9]/g, "");
		}

		function normalizeStageName(stage) {
			const clean = stripAccents(stage);
			if (!clean) return "";
			if (/recuperacion1/.test(clean)) return "Recuperacion1";
			if (/recuperacion2/.test(clean)) return "Recuperacion2";
			if (/extraordinario1/.test(clean)) return "Extraordinario1";
			if (/extraordinario2/.test(clean)) return "Extraordinario2";
			if (/^fase1$/.test(clean) || /^fase\s*1$/.test(clean)) return "Fase 1";
			if (/^fase2$/.test(clean) || /^fase\s*2$/.test(clean)) return "Fase 2";
			return clean;
		}

		function isTruthy(value) {
			return value === true || value === "true" || value === 1 || value === "1";
		}

		function getStageItems(scoreSetup, stageLabel) {
			const normalizedStage = normalizeStageName(stageLabel);
			return scoreSetup.filter(item => normalizeStageName(item && item.stage) === normalizedStage);
		}

		function getStageItemByName(stageItems, targetName) {
			const normalizedTarget = normalizeItemName(targetName);
			return stageItems.find(item => normalizeItemName(item && item.name) === normalizedTarget);
		}

		function hasNumericScore(value) {
			if (value === null || value === undefined) return false;
			const str = String(value).trim();
			if (str === "") return false;
			return !Number.isNaN(Number(str));
		}

		function sumZonaExamen(scoreSetup, stageLabel) {
			const stageItems = getStageItems(scoreSetup, stageLabel);
			let total = 0;
			stageItems.forEach(item => {
				const itemName = normalizeItemName(item && item.name);
				if ((itemName === "zona" || itemName === "examen") && hasNumericScore(item.score)) {
					total += Number(item.score);
				}
			});
			return total;
		}

		// Resultado ya registrado de una recuperación: nota numérica o NSP
		// (en recuperaciones el flag nsp viene en el propio item, no en uno aparte)
		function getRecoveryResult(scoreSetup, recoveryStage) {
			const stageItems = getStageItems(scoreSetup, recoveryStage);
			const numericItem = stageItems.find(item => hasNumericScore(item && item.score));
			if (numericItem) {
				return { done: true, value: String(numericItem.score).trim(), score: Number(numericItem.score) };
			}
			if (stageItems.some(item => item && isTruthy(item.nsp))) {
				return { done: true, value: "NSP", score: 0 };
			}
			return { done: false, value: "", score: 0 };
		}

		// La asignación a recuperaciones se decide con la regla del punteo mínimo:
		// la existencia del stage en el setup no implica que el alumno la necesite,
		// porque el módulo puede dejar stages creados y vacíos al editar notas.
		// El stage solo aporta el resultado cuando la regla dice que sí aplica.
		function getRecoveryStageValue(scoreSetup, recoveryStage) {
			const finalItems = getStageItems(scoreSetup, "Fase Final");
			const finalNspItem = getStageItemByName(finalItems, "NSP");
			const finalSdeItem = getStageItemByName(finalItems, "SDE");
			const finalExamItem = getStageItemByName(finalItems, "Examen");
			const finalClosedItem = getStageItemByName(finalItems, "is_closed");

			const finalNSP = !!(finalNspItem && isTruthy(finalNspItem.nsp));
			const finalSDE = !!(finalSdeItem && isTruthy(finalSdeItem.sde));
			const finalClosed = !!(finalClosedItem && isTruthy(finalClosedItem.is_closed));
			const finalResolved = finalClosed || finalNSP || finalSDE || !!(finalExamItem && hasNumericScore(finalExamItem.score));

			// Sin Fase Final resuelta no se sabe si irá a recuperación;
			// con SDE no tiene derecho a recuperación
			if (!finalResolved || finalSDE) return "NA";

			const baseTotal = sumZonaExamen(scoreSetup, "Fase 1")
				+ sumZonaExamen(scoreSetup, "Fase 2")
				+ sumZonaExamen(scoreSetup, "Fase Final");
			if (baseTotal >= PASSING_SCORE) return "NA";

			const firstRecovery = getRecoveryResult(scoreSetup, "Recuperacion1");

			if (recoveryStage === "Recuperacion1") {
				return firstRecovery.done ? firstRecovery.value : "PENDIENTE";
			}

			// Recuperacion2 aplica solo si Recuperacion1 ya tiene resultado y el
			// total, con esa nota sustituyendo el bloque de Fase Final, sigue bajo
			// el punteo mínimo
			if (!firstRecovery.done) return "NA";

			const totalWithFirstRecovery = sumZonaExamen(scoreSetup, "Fase 1")
				+ sumZonaExamen(scoreSetup, "Fase 2")
				+ firstRecovery.score;
			if (totalWithFirstRecovery >= PASSING_SCORE) return "NA";

			const secondRecovery = getRecoveryResult(scoreSetup, "Recuperacion2");
			return secondRecovery.done ? secondRecovery.value : "PENDIENTE";
		}

		function getExtraordinaryStageValue(scoreSetup, phaseLabel) {
			const phaseItems = getStageItems(scoreSetup, phaseLabel);
			if (phaseItems.length === 0) return "NA";

			const nspItem = getStageItemByName(phaseItems, "NSP");
			const examItem = getStageItemByName(phaseItems, "Examen");
			const sdeItem = getStageItemByName(phaseItems, "SDE");

			const extraordinaryNsp = nspItem && isTruthy(nspItem.nsp);
			const examScore = examItem && examItem.score;

			if (extraordinaryNsp) {
				// La nota del extraordinario sobrescribe el Examen de la fase base
				if (hasNumericScore(examScore)) return String(examScore).trim();
				if (sdeItem && isTruthy(sdeItem.sde)) return "SDE";
				// extransp: el alumno tampoco se presentó al extraordinario y ya se cerró
				if (isTruthy(nspItem.extransp)) return "NSP";
				// Aplica al extraordinario y todavía no tiene nada registrado
				return "PENDIENTE";
			}

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

		function parseProfessorNit(setup) {
			if (!setup) return "N/A";
			try {
				const parsed = typeof setup === "string" ? JSON.parse(setup) : setup;
				return String(parsed.nit || "").trim() || "N/A";
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
			if (student.status_code === "D" || student.status_code === "B") {
				return null;
			}

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
				profesor_nit: parseProfessorNit(professor.setup),
				profesor: parseProfessorName(professor.setup),
				aula: classroom.name || "N/A",
				periodo: period.name || "N/A",
				extraordinario_1: getExtraordinaryStageValue(scoreSetup, "Fase 1"),
				extraordinario_2: getExtraordinaryStageValue(scoreSetup, "Fase 2"),
				recuperacion_1: getRecoveryStageValue(scoreSetup, "Recuperacion1"),
				recuperacion_2: getRecoveryStageValue(scoreSetup, "Recuperacion2")
			};
		}).filter(Boolean);

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
