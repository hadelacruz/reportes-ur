(async function () {
  try {
    const d = req.body.d || {};
    const clsrmName = d.clsrmName;
    const requestedCourseType = (d.course_type || "all").toString().toLowerCase();

    const wherePre = {};
    const whereSection = {};
    const whereSectionSeason = {};

    if (d.branch) {
      wherePre.branch_id = { [models.Sequelize.Op.in]: d.branch.split(",") };
    }
    if (d.period) {
      whereSectionSeason.period_id = { [models.Sequelize.Op.in]: d.period.split(",") };
    }
    if (d.course) {
      whereSection.course_id = { [models.Sequelize.Op.in]: d.course.split(",") };
    }

    models.crs_assignation_preinscription.belongsTo(models.crs_assignation_section, {
      foreignKey: "taken_by_section_id",
      targetKey: "section_id"
    });
    models.crs_assignation_preinscription.belongsTo(models.std_student, { foreignKey: "student_id" });
    models.crs_assignation_preinscription.belongsTo(models.std_branch, { foreignKey: "branch_id" });
    models.crs_assignation_section.belongsTo(models.crs_course, { foreignKey: "course_id" });
    models.crs_assignation_section.belongsTo(models.crs_assignation_season, { foreignKey: "season_id" });
    models.crs_assignation_season.belongsTo(models.std_period, { foreignKey: "period_id" });

    const classroomInclude = {
      model: models.crs_assignation_classroom,
      attributes: ["name"],
      required: !!(clsrmName && clsrmName.trim() !== "")
    };

    if (clsrmName && clsrmName.trim() !== "") {
      classroomInclude.where = { name: { [models.Sequelize.Op.like]: "%" + clsrmName + "%" } };
    }

    const BATCH_SIZE = 1000;
    let offset = 0;
    let lastPreinscriptionId = 0;
    const useCursorPagination = !!(models.Sequelize && models.Sequelize.Op && models.Sequelize.Op.gt);
    const result = [];

    while (true) {
      const preinscriptionQuery = {
        where: Object.assign({}, wherePre),
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
        ],
        limit: BATCH_SIZE,
        order: [["preinscription_id", "ASC"]]
      };

      if (useCursorPagination) {
        preinscriptionQuery.where.preinscription_id = { [models.Sequelize.Op.gt]: lastPreinscriptionId };
      } else {
        preinscriptionQuery.offset = offset;
      }

      const preinscriptions = await models.crs_assignation_preinscription.findAll(preinscriptionQuery);
      if (!preinscriptions || preinscriptions.length === 0) break;

      if (useCursorPagination) {
        lastPreinscriptionId = preinscriptions[preinscriptions.length - 1].preinscription_id;
      } else {
        offset += BATCH_SIZE;
      }

      const sectionIds = [...new Set(preinscriptions.map(p => p.taken_by_section_id).filter(Boolean))];
      const studentIds = [...new Set(preinscriptions.map(p => p.student_id).filter(Boolean))];

      const scores = sectionIds.length && studentIds.length
        ? await models.crs_score.findAll({
            where: {
              section_id: { [models.Sequelize.Op.in]: sectionIds },
              student_id: { [models.Sequelize.Op.in]: studentIds }
            },
            attributes: ["section_id", "setup", "student_id"]
          })
        : [];

      const scoreMap = new Map();
      scores.forEach(score => {
        scoreMap.set(score.section_id + "-" + score.student_id, score);
      });

      preinscriptions.forEach(pre => {
        const section = pre.crs_assignation_section;
        const student = pre.std_student;
        const course = section && section.crs_course;
        const score = section ? scoreMap.get(section.section_id + "-" + pre.student_id) : null;

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
          classroom: (section && section.crs_assignation_classroom && section.crs_assignation_classroom.name) || "Sin aula",
          score: (score && score.setup) || null,
          branch: (pre.std_branch && pre.std_branch.name) || "No definida",
          career: (pre.std_career && pre.std_career.name) || null,
          studying_cycle: (pre.std_studying_cycle && pre.std_studying_cycle.name) || null,
          studying_time: (pre.std_studying_time && pre.std_studying_time.name) || null,
          period: (sectionPeriod && sectionPeriod.name) || null
        };

        if (requestedCourseType === "practical" && row.course_type !== "practical") {
          return;
        }
        if (requestedCourseType === "regular" && row.course_type !== "regular") {
          return;
        }

        result.push(row);
      });
    }

    resolve(result);
  } catch (error) {
    console.error("Error al obtener preinscripciones para reporte de sedes:", error);
    reject(error);
  }
})();