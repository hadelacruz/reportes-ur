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

		if (d.career) {
			wherePre.career_id = { [Op.in]: d.career.split(",") };
		}

		function normalizeStudentStatusCode(value) {
			return String(value || "").trim().toUpperCase();
		}

		function normalizeStageName(stage) {
			const name = String(stage || "").trim().toLowerCase();
			if (name === "fase 1") return "Fase 1";
			if (name === "fase 2") return "Fase 2";
			if (name === "fase final") return "Fase Final";
			return "";
		}

		function parseScoreSetup(value) {
			if (!value) return [];
			if (Array.isArray(value)) return value;
			if (typeof value === "string") {
				try {
					const parsed = JSON.parse(value);
					return Array.isArray(parsed) ? parsed : [];
				} catch (error) {
					return [];
				}
			}
			return [];
		}

		function getStageRows(scoreSetup, stageName) {
			return scoreSetup.filter(function(item) {
				return normalizeStageName(item && item.stage) === stageName;
			});
		}

		function hasEnabledStage(stageRows) {
			if (!Array.isArray(stageRows) || stageRows.length === 0) return false;
			return stageRows.some(function(row) {
				if (!row || typeof row !== "object") return false;
				if (row.enable === false || row.enabled === false || row.active === false) return false;
				return true;
			});
		}

		function hasNSP(stageRows) {
			if (!Array.isArray(stageRows) || stageRows.length === 0) return false;
			const nspRow = stageRows.find(function(row) {
				return row && row.name === "NSP";
			});
			if (nspRow && nspRow.nsp === true) return true;

			const examRow = stageRows.find(function(row) {
				return row && row.name === "Examen";
			});
			return !!(examRow && String(examRow.score || "").trim().toUpperCase() === "NSP");
		}

		function hasNSPInTwoMainStages(scoreSetup) {
			const stages = ["Fase 1", "Fase 2"];
			return stages.every(function(stageName) {
				const rows = getStageRows(scoreSetup, stageName);
				if (!hasEnabledStage(rows)) return false;
				return hasNSP(rows);
			});
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
		models.crs_assignation_classroom.hasMany(models.crs_assignation_classroom_studying_time, { foreignKey: "classroom_id" });
		models.crs_assignation_classroom_studying_time.belongsTo(models.std_studying_time, { foreignKey: "studying_time_id" });

		const preinscriptions = await models.crs_assignation_preinscription.findAll({
			attributes: ["student_id", "taken_by_section_id", "career_id", "studying_cycle_id", "studying_time_id"],
			include: [
				{ model: models.std_student, attributes: ["name", "student_id_card", "status_code"], required: false },
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

		const sectionIds = [...new Set(preinscriptions.map(pre => pre.taken_by_section_id).filter(Boolean))];
		const studentIds = [...new Set(preinscriptions.map(pre => pre.student_id).filter(Boolean))];

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
		scores.forEach(function(score) {
			scoreMap.set(score.section_id + "-" + score.student_id, score);
		});

		const classroomIds = [...new Set(preinscriptions.map(pre => {
			const section = pre.crs_assignation_section;
			return section && section.crs_assignation_classroom && section.crs_assignation_classroom.classroom_id;
		}).filter(Boolean))];

		const classroomStudyingTimes = classroomIds.length > 0
			? await models.crs_assignation_classroom_studying_time.findAll({
				where: { classroom_id: { [Op.in]: classroomIds } },
				attributes: ["classroom_id", "studying_time_id"],
				include: [
					{ model: models.std_studying_time, attributes: ["name"], required: false }
				]
			})
			: [];

		const classroomJornadaMap = new Map();
		classroomStudyingTimes.forEach(function(cst) {
			const jornadaName = (cst.std_studying_time && cst.std_studying_time.name) || "";
			if (!classroomJornadaMap.has(cst.classroom_id)) {
				classroomJornadaMap.set(cst.classroom_id, []);
			}
			if (jornadaName) classroomJornadaMap.get(cst.classroom_id).push(jornadaName);
		});

		const details = [];
		const grouped = new Map();
		const aulaGrouped = new Map();
		const nspRiskCoursesByAulaStudent = new Map();

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
			const studyingCycleName = (studyingCycle && studyingCycle.name) || "Sin ciclo de estudio";
			const studyingTimeName = (studyingTime && studyingTime.name) || "Sin jornada";
			const studentName = student.name || "Sin nombre";
			const studentCard = student.student_id_card || "";
			const studentStatusCode = normalizeStudentStatusCode(student.status_code);
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
			const professorId = (section && section.professor_id) || null;
			const hasProfessor = professorId !== null && professorId !== undefined && professorId !== "";
			const dayIndexValue = (sectionSetup && sectionSetup.day_index != null && sectionSetup.day_index !== "") ? sectionSetup.day_index : "N/A";
			const horarioName = (sectionSetup && sectionSetup.schedule) || "N/A";

			// La regla de negocio trata como la MISMA sección a las secciones que
			// comparten profesor, día, horario y curso (dentro de la misma sede y
			// periodo), aunque estén repartidas en aulas distintas (aulas hermanas).
			// Por eso "Aula" y "Codigo de Sección" ya no forman parte de la clave.
			// Si NO tienen profesor asignado (pendiente) no se unifican: cada aula
			// queda separada, porque no hay catedrático que confirme que es la
			// misma clase.
			const groupKey = hasProfessor
				? [branchId || "", periodId || "", courseId || "", professorId, dayIndexValue, horarioName].join("|")
				: [branchId || "", periodId || "", courseId || "", "sin-catedratico", classroomId || "", dayIndexValue, horarioName].join("|");
			const aulaGroupKey = [classroomId || "", branchId || "", periodId || ""].join("|");

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
					Curso: courseName,
					Sede: branchName,
					Periodo: periodName,
					"Codigo Catedratico": profesorCode,
					"Nombre de catedrático": professorName,
					"Ciclo de estudio": studyingCycleName,
					Jornada: studyingTimeName,
					Horario: horarioName,
					aulas: new Set(),
					sectionCodes: new Set(),
					careers: new Set(),
					studentIds: new Set(),
					totalGeneral: 0,
					activos: 0,
					suspendidos: 0,
					baja: 0,
					fallecido: 0
				});
			}

			const groupItem = grouped.get(groupKey);
			groupItem.totalGeneral += 1;
			if (studentStatusCode === "A") groupItem.activos += 1;
			if (studentStatusCode === "S") groupItem.suspendidos += 1;
			if (studentStatusCode === "B") groupItem.baja += 1;
			if (studentStatusCode === "D") groupItem.fallecido += 1;
			groupItem.aulas.add(classroomName);
			groupItem.sectionCodes.add(codigoSeccion);
			groupItem.careers.add(careerName);
			groupItem.studentIds.add(pre.student_id);

			if (!aulaGrouped.has(aulaGroupKey)) {
				aulaGrouped.set(aulaGroupKey, {
					aulaGroupKey: aulaGroupKey,
					classroomId: classroomId,
					Aula: classroomName,
					Sede: branchName,
					Periodo: periodName,
					cycles: new Set(),
					careers: new Set(),
					courses: new Set(),
					studentIds: new Set(),
					activos: 0,
					suspendidos: 0,
					baja: 0,
					fallecido: 0,
					totalGeneral: 0
				});
			}

			const aulaItem = aulaGrouped.get(aulaGroupKey);
			if (!aulaItem.studentIds.has(pre.student_id)) {
				aulaItem.studentIds.add(pre.student_id);
				aulaItem.totalGeneral += 1;
				if (studentStatusCode === "A") aulaItem.activos += 1;
				if (studentStatusCode === "S") aulaItem.suspendidos += 1;
				if (studentStatusCode === "B") aulaItem.baja += 1;
				if (studentStatusCode === "D") aulaItem.fallecido += 1;
			}
			aulaItem.careers.add(careerName);
			aulaItem.courses.add(courseName);
			aulaItem.cycles.add(studyingCycleName);

			if (studentStatusCode === "A") {
				const scoreRecord = scoreMap.get((section.section_id || "") + "-" + pre.student_id);
				const scoreSetup = parseScoreSetup(scoreRecord && scoreRecord.setup);
				if (hasNSPInTwoMainStages(scoreSetup)) {
					const studentAulaKey = aulaGroupKey + "|" + pre.student_id;
					if (!nspRiskCoursesByAulaStudent.has(studentAulaKey)) {
						nspRiskCoursesByAulaStudent.set(studentAulaKey, new Set());
					}
					nspRiskCoursesByAulaStudent.get(studentAulaKey).add(courseId || section.section_id || "N/A");
				}
			}
		});

		const riskStudentsByAula = new Map();
		nspRiskCoursesByAulaStudent.forEach(function(coursesSet, studentAulaKey) {
			if (!coursesSet || coursesSet.size < 3) return;
			const parts = studentAulaKey.split("|");
			const studentId = parts.pop();
			const aulaKey = parts.join("|");
			if (!riskStudentsByAula.has(aulaKey)) {
				riskStudentsByAula.set(aulaKey, new Set());
			}
			riskStudentsByAula.get(aulaKey).add(studentId);
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

		const bySection = Array.from(grouped.values()).map(item => ({
			Aula: Array.from(item.aulas).sort((left, right) => String(left).localeCompare(String(right), "es")).join(", "),
			Carrera: Array.from(item.careers).sort((left, right) => String(left).localeCompare(String(right), "es")).join(", "),
			Curso: item.Curso,
			Sede: item.Sede,
			"Codigo de Sección": Array.from(item.sectionCodes).sort((left, right) => String(left).localeCompare(String(right), "es")).join(", "),
			Activos: item.activos,
			Suspendidos: item.suspendidos,
			"De baja": item.baja,
			Fallecido: item.fallecido,
			"Total General": item.totalGeneral,
			"Codigo Catedratico": item["Codigo Catedratico"],
			"Nombre de catedrático": item["Nombre de catedrático"],
			"Ciclo de estudio": item["Ciclo de estudio"],
			Jornada: item.Jornada,
			Horario: item.Horario,
			Periodo: item.Periodo,
			// Marca las filas armadas a partir de 2+ aulas hermanas (mismo profesor,
			// día, horario y curso), para resaltarlas en la tabla del front.
			_unified: item.aulas.size > 1
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

		const byClassroom = Array.from(aulaGrouped.values()).map(item => {
			const activosConNSP = (riskStudentsByAula.get(item.aulaGroupKey) || new Set()).size;
			const activosSinNSP = item.activos - activosConNSP;
			const jornadaNames = classroomJornadaMap.get(item.classroomId) || [];
			const jornadaLabel = [...new Set(jornadaNames)].sort((a, b) => a.localeCompare(b, "es")).join(", ") || "Sin jornada";
			return {
			Sede: item.Sede,
			Aula: item.Aula,
			Jornada: jornadaLabel,
			"Ciclo de estudio": Array.from(item.cycles).sort((left, right) => String(left).localeCompare(String(right), "es")).join(", "),
			"Alumnos con NSP>3": activosConNSP,
			"Activos sin NSP": activosSinNSP,
			Carreras: Array.from(item.careers).sort((left, right) => String(left).localeCompare(String(right), "es")).join(", "),
			Cursos: Array.from(item.courses).sort((left, right) => String(left).localeCompare(String(right), "es")).join(", "),
			Activos: item.activos,
			Suspendidos: item.suspendidos,
			"De Baja": item.baja,
			Fallecidos: item.fallecido,
			"Total General": item.totalGeneral,
			Periodo: item.Periodo
		};
		}).sort((left, right) => {
			const sedeCompare = String(left.Sede).localeCompare(String(right.Sede), "es");
			if (sedeCompare !== 0) return sedeCompare;
			const aulaCompare = String(left.Aula).localeCompare(String(right.Aula), "es");
			if (aulaCompare !== 0) return aulaCompare;
			return String(left.Periodo).localeCompare(String(right.Periodo), "es");
		});

		// ===== Pestaña Resumen =====
		// Universo independiente de las secciones: arranca en std_inscription (sede + periodo),
		// descarta alumnos de baja/fallecidos y carreras de traslado. El estado de asignacion
		// se lee en crs_assignation_preinscription, donde taken_by_section_id NULL = pendiente.
		// El periodo de cada preinscripcion se toma de su inscripcion (nunca de la season).
		// Solo se honran los filtros que existen a nivel de inscripcion (sede, periodo, carrera,
		// jornada, ciclo). Los filtros de aula, curso, catedratico y codigo de seccion se ignoran
		// aqui porque un alumno pendiente todavia no tiene seccion asignada.
		models.std_inscription.belongsTo(models.std_student, { foreignKey: "student_id" });
		models.std_inscription.belongsTo(models.std_career, { foreignKey: "career_id" });

		function chunkArray(items, size) {
			const chunks = [];
			for (let index = 0; index < items.length; index += size) {
				chunks.push(items.slice(index, index + size));
			}
			return chunks;
		}

		const whereInscription = {};
		if (d.branch) whereInscription.branch_id = { [Op.in]: d.branch.split(",") };
		if (d.period) whereInscription.period_id = { [Op.in]: d.period.split(",") };
		if (d.career) whereInscription.career_id = { [Op.in]: d.career.split(",") };
		if (d.studying_time) whereInscription.studying_time_id = { [Op.in]: d.studying_time.split(",") };
		if (d.studying_cycle) whereInscription.studying_cycle_id = { [Op.in]: d.studying_cycle.split(",") };

		const inscriptionRows = await models.std_inscription.findAll({
			attributes: ["inscription_id", "student_id", "branch_id", "period_id", "studying_cycle_id"],
			where: whereInscription,
			include: [
				{
					model: models.std_student,
					attributes: [],
					required: true,
					where: {
						[Op.or]: [
							{ status_code: { [Op.notIn]: ["B", "D"] } },
							{ status_code: null }
						]
					}
				},
				{
					model: models.std_career,
					attributes: [],
					required: true,
					where: { name: { [Op.notLike]: "%(Traslado)%" } }
				}
			],
			raw: true
		});

		const inscriptionById = new Map();
		inscriptionRows.forEach(function(row) {
			inscriptionById.set(String(row.inscription_id), row);
		});

		// El periodo lo manda la inscripcion, no la season de la preinscripcion: al filtrar por
		// inscription_id el recorte de periodo y sede queda garantizado por el propio universo.
		const summaryInscriptionIds = inscriptionRows.map(function(row) { return row.inscription_id; }).filter(Boolean);

		let summaryPreinscriptions = [];
		if (summaryInscriptionIds.length > 0) {
			const preinscriptionChunks = await Promise.all(chunkArray(summaryInscriptionIds, 5000).map(function(inscriptionChunk) {
				return models.crs_assignation_preinscription.findAll({
					attributes: ["inscription_id", "studying_cycle_id", "taken_by_section_id"],
					where: {
						inscription_id: { [Op.in]: inscriptionChunk }
					},
					raw: true
				});
			}));
			summaryPreinscriptions = [].concat.apply([], preinscriptionChunks);
		}

		const summaryGroups = new Map();

		function getSummaryGroup(branchId, periodId) {
			const key = String(branchId || "") + "|" + String(periodId || "");
			if (!summaryGroups.has(key)) {
				summaryGroups.set(key, {
					branchId: branchId,
					periodId: periodId,
					asignados: new Set(),
					pendientesNormal: new Set(),
					prePendientesExtra: 0
				});
			}
			return summaryGroups.get(key);
		}

		// Se registra el grupo desde la inscripcion para que una sede/periodo del universo
		// aparezca en la tabla aunque todavia no tenga ninguna preinscripcion cargada.
		inscriptionRows.forEach(function(row) {
			getSummaryGroup(row.branch_id, row.period_id);
		});

		summaryPreinscriptions.forEach(function(pre) {
			const inscription = inscriptionById.get(String(pre.inscription_id));
			if (!inscription) return;

			const group = getSummaryGroup(inscription.branch_id, inscription.period_id);
			const studentKey = String(inscription.student_id);

			if (pre.taken_by_section_id) {
				group.asignados.add(studentKey);
				return;
			}

			const preCycleId = pre.studying_cycle_id;
			const inscriptionCycleId = inscription.studying_cycle_id;
			const isExtraCourse = preCycleId !== null && preCycleId !== undefined
				&& inscriptionCycleId !== null && inscriptionCycleId !== undefined
				&& String(preCycleId) !== String(inscriptionCycleId);

			if (isExtraCourse) {
				group.prePendientesExtra += 1;
			} else {
				group.pendientesNormal.add(studentKey);
			}
		});

		const summaryBranchIds = [...new Set(inscriptionRows.map(function(row) { return row.branch_id; }).filter(Boolean))];
		const summaryPeriodIds = [...new Set(inscriptionRows.map(function(row) { return row.period_id; }).filter(Boolean))];

		const [summaryBranches, summaryPeriods] = await Promise.all([
			summaryBranchIds.length > 0
				? models.std_branch.findAll({ attributes: ["branch_id", "name"], where: { branch_id: { [Op.in]: summaryBranchIds } }, raw: true })
				: [],
			summaryPeriodIds.length > 0
				? models.std_period.findAll({ attributes: ["period_id", "name"], where: { period_id: { [Op.in]: summaryPeriodIds } }, raw: true })
				: []
		]);

		const summaryBranchNames = new Map();
		summaryBranches.forEach(function(branch) { summaryBranchNames.set(String(branch.branch_id), branch.name); });

		const summaryPeriodNames = new Map();
		summaryPeriods.forEach(function(period) { summaryPeriodNames.set(String(period.period_id), period.name); });

		// Asignados y vista de grupos van a nivel de alumno distinto; la vista de cursos extra
		// va a nivel de curso, porque el front emite una card por cada par (alumno, curso extra).
		// Un mismo alumno puede sumar en varias columnas, por eso el TOTAL no es la cantidad
		// de alumnos distintos.
		const summary = Array.from(summaryGroups.values()).map(function(group) {
			const asignados = group.asignados.size;
			const pendientesNormal = group.pendientesNormal.size;
			const pendientesExtra = group.prePendientesExtra;
			return {
				Sede: summaryBranchNames.get(String(group.branchId)) || "No definida",
				Periodo: summaryPeriodNames.get(String(group.periodId)) || "Sin periodo",
				Asignados: asignados,
				"No asignados (vista grupos)": pendientesNormal,
				"No asignados (vista de cursos extra)": pendientesExtra,
				TOTAL: asignados + pendientesNormal + pendientesExtra
			};
		}).sort(function(left, right) {
			const sedeCompare = String(left.Sede).localeCompare(String(right.Sede), "es");
			if (sedeCompare !== 0) return sedeCompare;
			return String(left.Periodo).localeCompare(String(right.Periodo), "es");
		});

		resolve({
			details,
			bySection,
			byClassroom,
			summary
		});
	} catch (error) {
		console.error("Error al obtener alumnos por aula:", error);
		reject(error);
	}
})();
