(async function () {
  try {
    const Op = models.Sequelize.Op;

    const d = req.body.d || {};
    const clsrmName = d.clsrmName;
    const requestedCourseType = (d.course_type || "all").toString().toLowerCase();

    const wherePre = {};
    const whereSection = {};
    const whereSectionSeason = {};

    if (d.branch) {
      wherePre.branch_id = { [Op.in]: d.branch.split(",") };
    }
    if (d.period) {
      whereSectionSeason.period_id = { [Op.in]: d.period.split(",") };
    }
    if (d.course) {
      whereSection.course_id = { [Op.in]: d.course.split(",") };
    }

    models.crs_assignation_preinscription.belongsTo(models.crs_assignation_section, {
      foreignKey: "taken_by_section_id",
      targetKey: "section_id"
    });
    models.crs_assignation_preinscription.belongsTo(models.std_student, { foreignKey: "student_id" });
    models.crs_assignation_preinscription.belongsTo(models.std_branch, { foreignKey: "branch_id" });
    models.crs_assignation_preinscription.belongsTo(models.std_career, { foreignKey: "career_id" });
    models.crs_assignation_preinscription.belongsTo(models.std_studying_cycle, { foreignKey: "studying_cycle_id" });
    models.crs_assignation_preinscription.belongsTo(models.std_studying_time, { foreignKey: "studying_time_id" });
    models.crs_assignation_section.belongsTo(models.crs_course, { foreignKey: "course_id" });
    models.crs_assignation_section.belongsTo(models.crs_assignation_season, { foreignKey: "season_id" });
    models.crs_assignation_season.belongsTo(models.std_period, { foreignKey: "period_id" });
    models.crs_assignation_classroom.belongsTo(models.std_branch, { foreignKey: "branch_id" });

    const classroomInclude = {
      model: models.crs_assignation_classroom,
      attributes: ["name", "branch_id"],
      required: !!(clsrmName && clsrmName.trim() !== ""),
      include: [
        { model: models.std_branch, attributes: ["name"], required: false }
      ]
    };

    if (clsrmName && clsrmName.trim() !== "") {
      classroomInclude.where = { name: { [Op.like]: "%" + clsrmName + "%" } };
    }

    // Single efficient query without problematic pagination
    const preinscriptions = await models.crs_assignation_preinscription.findAll({
      where: wherePre,
      attributes: [
        "preinscription_id",
        "student_id",
        "taken_by_section_id",
        "branch_id",
        "career_id",
        "studying_cycle_id",
        "studying_time_id"
      ],
      include: [
        {
          model: models.std_student,
          attributes: ["name", "student_id_card", "status_code"],
          required: false
        },
        { model: models.std_branch, attributes: ["name"], required: false },
        { model: models.std_career, attributes: ["name"], required: false },
        { model: models.std_studying_cycle, attributes: ["name"], required: false },
        { model: models.std_studying_time, attributes: ["name"], required: false },
        {
          model: models.crs_assignation_section,
          attributes: ["section_id", "name", "course_id", "season_id"],
          required: true,
          where: whereSection,
          include: [
            { model: models.crs_course, attributes: ["name", "setup"], required: false },
            {
              model: models.crs_assignation_season,
              attributes: ["season_id", "period_id"],
              required: true,
              where: whereSectionSeason,
              include: [{ model: models.std_period, attributes: ["name"], required: false }]
            },
            classroomInclude
          ]
        }
      ]
    });

    const sectionIds = [...new Set(preinscriptions.map(p => p.taken_by_section_id).filter(Boolean))];
    const studentIds = [...new Set(preinscriptions.map(p => p.student_id).filter(Boolean))];

    const scores = sectionIds.length && studentIds.length
      ? await models.crs_score.findAll({
          where: {
            section_id: { [Op.in]: sectionIds },
            student_id: { [Op.in]: studentIds }
          },
          attributes: ["section_id", "setup", "student_id"]
        })
      : [];

    const scoreMap = new Map();
    scores.forEach(score => {
      scoreMap.set(score.section_id + "-" + score.student_id, score);
    });

    const result = preinscriptions.map(pre => {
      const section = pre.crs_assignation_section;
      const student = pre.std_student;
      const course = section && section.crs_course;
      const score = section ? scoreMap.get(section.section_id + "-" + pre.student_id) : null;
      const classroom = section && section.crs_assignation_classroom;

      let courseSetup = null;
      if (course && course.setup) {
        try {
          courseSetup = typeof course.setup === "string" ? JSON.parse(course.setup) : course.setup;
        } catch (error) {
          courseSetup = null;
        }
      }

      const sectionSeason = section && section.crs_assignation_season;
      const sectionPeriod = sectionSeason && sectionSeason.std_period;

      // Resolver sede: prioridad a classroom.branch_id (intersede), fallback a preinscription.branch_id
      const branchId = classroom && classroom.branch_id ? classroom.branch_id : pre.branch_id;
      const branchName = (classroom && classroom.std_branch && classroom.std_branch.name) 
        || (pre.std_branch && pre.std_branch.name) 
        || "No definida";

      const row = {
        preinscription_id: pre.preinscription_id,
        student_id: pre.student_id,
        student_name: (student && student.name) || "Sin nombre",
        student_id_card: (student && student.student_id_card) || "Sin carné",
        student_status_code: (student && student.status_code) || null,
        course: (course && course.name) || "Sin curso",
        course_setup: courseSetup,
        course_type: courseSetup && courseSetup.is_practical === true ? "practical" : "regular",
        section: (section && section.name) || "Sin sección",
        classroom: (classroom && classroom.name) || "Sin aula",
        score: (score && score.setup) || null,
        branch_id: branchId,
        branch: branchName,
        career: (pre.std_career && pre.std_career.name) || null,
        studying_cycle: (pre.std_studying_cycle && pre.std_studying_cycle.name) || null,
        studying_time: (pre.std_studying_time && pre.std_studying_time.name) || null,
        period: (sectionPeriod && sectionPeriod.name) || null
      };

      if (requestedCourseType === "practical" && row.course_type !== "practical") {
        return null;
      }
      if (requestedCourseType === "regular" && row.course_type !== "regular") {
        return null;
      }

      return row;
    }).filter(row => row !== null);

    resolve(result);
  } catch (error) {
    console.error("Error al obtener preinscripciones para reporte de sedes:", error);
    reject(error);
  }
})();