async function getPreinscriptionsForStudents(studentIds, filters) {
    const {
        condition,
        inscCondition,
        sctnCondition
    } = filters;

    const classroomInclude = {
        model: models.crs_assignation_classroom,
        attributes: ["name"]
    };

    // El período/sede/carrera/ciclo/jornada se resuelven por la INSCRIPCIÓN del alumno
    // (fuente confiable y lo que muestra el reporte), no por la temporada/preinscripción,
    // porque la season de una preinscripción puede no coincidir con el período real.
    let whereInsc = {
        ...inscCondition,
        student_id: studentIds
    };

    let whereScore = {
        student_id: studentIds
    };

    // ¿Se pidió algún filtro de contexto del alumno? Si es así, se filtra por inscripción.
    const hasInscriptionFilter = !!(
        inscCondition.period_id ||
        inscCondition.branch_id ||
        inscCondition.career_id
    );

    models.std_inscription.belongsTo(models.std_period, {
        foreignKey: "period_id"
    });
    models.std_inscription.belongsTo(models.std_career, {
        foreignKey: "career_id"
    });
    models.std_inscription.belongsTo(models.std_studying_cycle, {
        foreignKey: "studying_cycle_id"
    });
    models.std_inscription.belongsTo(models.std_studying_time, {
        foreignKey: "studying_time_id"
    });
    models.std_inscription.belongsTo(models.std_branch, {
        foreignKey: "branch_id"
    });

    // 1) Inscripciones que cumplen los filtros de contexto (también alimentan el display).
    const inscriptions = await models.std_inscription.findAll({
        where: whereInsc,
        attributes: ["inscription_id", "student_id", "career_id", "branch_id", "studying_cycle_id", "studying_time_id"],
        include: [{
                model: models.std_career,
                attributes: ["name"]
            },
            {
                model: models.std_period,
                attributes: ["name"]
            },
            {
                model: models.std_branch,
                attributes: ["name"]
            },
            {
                model: models.std_studying_cycle,
                attributes: ["name"]
            },
            {
                model: models.std_studying_time,
                attributes: ["name"]
            }
        ],
        order: [
            ["create_date", "DESC"]
        ]
    });

    // 2) Preinscripciones del alumno. Cuando hay filtro de contexto, se restringen a las
    //    inscripciones que lo cumplen (mismo criterio que se muestra en el reporte).
    const inscriptionIds = inscriptions.map(i => i.inscription_id);

    let wherePre = {
        student_id: studentIds
    };
    if (hasInscriptionFilter) {
        wherePre.inscription_id = inscriptionIds;
    }

    models.crs_assignation_preinscription.belongsTo(models.crs_assignation_section, {
        foreignKey: "taken_by_section_id",
        targetKey: "section_id"
    });
    models.crs_assignation_preinscription.belongsTo(models.std_student, {
        foreignKey: "student_id"
    });
    models.crs_assignation_section.belongsTo(models.crs_course, {
        foreignKey: "course_id"
    });
    //aula
    models.crs_assignation_section.belongsTo(models.pfs_professor, {
            foreignKey: "professor_id"
        });
    models.crs_assignation_section.belongsTo(models.crs_assignation_classroom, {
        foreignKey: "classroom_id"
    });
    models.crs_assignation_preinscription.belongsTo(models.crs_assignation_season, {
        foreignKey: "season_id"
    });

    const preinscriptions = await models.crs_assignation_preinscription.findAll({
        where: wherePre,
        attributes: ["preinscription_id", "course_id", "student_id", "inscription_id", "taken_by_section_id"],
        include: [{
            model: models.crs_assignation_season,
            attributes: ["season_id", "period_id"],
            required: true
        }, {
            model: models.std_student,
            attributes: ["name", "student_id_card"],
            required: false
        }, {
            model: models.crs_assignation_section,
            attributes: ["section_id", "name", "course_id"],
            where: sctnCondition,
            required: true,
            include: [{
                    model: models.crs_course,
                    attributes: ["name"],
                    required: false
                },
                {
                    model: models.pfs_professor,
                    attributes: ["setup", "professor_id"],
                },
                {
                    ...classroomInclude,
                    required: false
                }
            ]
        }]
    });

    const scores = await models.crs_score.findAll({
        where: whereScore,
        attributes: ["section_id", "setup", "student_id"]
    });

    return preinscriptions.map(pre => {
        const inscription = inscriptions.find(insc => insc.student_id === pre.student_id && insc.inscription_id === pre.inscription_id);
        const section = pre.crs_assignation_section;
        const score = scores.find(s => s.section_id === section?.section_id && s.student_id === pre.student_id);
        const student = pre.std_student;
        let professorSetup = null;
        if (section.pfs_professor) {
            professorSetup = JSON.parse(section.pfs_professor.setup);
        }

        return {
            preinscription_id: pre.preinscription_id,
            student_id: pre.student_id,
            student_name: student?.name || "Sin nombre",
            student_id_card: student?.student_id_card || "Sin carné",
            professor: professorSetup ? professorSetup.name + " " + professorSetup.lastname : "No tiene.",
            course: section?.crs_course?.name || "Sin curso",
            section: section?.name || "Sin sección",
            classroom: section?.crs_assignation_classroom?.name || "Sin aula",
            score: score?.setup || null,
            branch: inscription?.std_branch?.name || "No definida",
            career: inscription?.std_career?.name || null,
            studying_cycle: inscription?.std_studying_cycle?.name || null,
            studying_time: inscription?.std_studying_time?.name || null,
            period: inscription?.std_period?.name || null,
        };
    });
}

async function getStudentPreinscriptions(req, res) {
    try {
        const BATCH_SIZE = 500;
        let offset = 0;
        let finalResult = [];

        let condition = {};
        let stdCondition = {};
        let inscCondition = {};
        let sctnCondition = {};

        if (req.body.d.period) inscCondition.period_id = req.body.d.period.split(",");
        if (req.body.d.branch) inscCondition.branch_id = condition.branch_id = req.body.d.branch.split(",");
        if (req.body.d.career) inscCondition.career_id = condition.career_id = req.body.d.career.split(",");

        // Select único de alumnos: busca por nombre/apellido o carné y permite selección
        // múltiple, se filtra por el uuid (columna real y única en std_student).
        if (req.body.d.studentUuids) {
            stdCondition.uuid = req.body.d.studentUuids.split(",");
        }

        // Obtener todos los estudiantes que cumplen con los filtros
        while (true) {
            const students = await models.std_student.findAll({
                where: stdCondition,
                attributes: ["student_id"],
                offset,
                limit: BATCH_SIZE
            });

            if (students.length === 0) break;

            const studentIds = students.map(s => s.student_id);

            const batchResult = await getPreinscriptionsForStudents(studentIds, {
                condition,
                inscCondition,
                sctnCondition
            });

            finalResult.push(...batchResult);

            offset += BATCH_SIZE;
        }

        resolve(finalResult);
    } catch (error) {
        console.error("Error al obtener preinscripciones:", error);
        res.status(500).json({
            error: "Error al obtener preinscripciones."
        });
    }
}

getStudentPreinscriptions(req, res);
