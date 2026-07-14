
  (async function () {
    try {
      const Op = models.Sequelize.Op;

      const d = req.body.d || {};
      const clsrmName = d.clsrmName;

      const wherePre = {};
      const whereSection = {};
      const whereSectionSeason = {};
      const classroomWhere = {};
      let classroomRequired = !!(clsrmName && clsrmName.trim() !== "");

      if (d.studnt && d.studnt.student_id) {
        wherePre.student_id = d.studnt.student_id;
      }
      if (d.branch) {
        classroomWhere.branch_id = { [Op.in]: d.branch.split(",") };
        classroomRequired = true;
      }
      if (d.studying_time) {
        wherePre.studying_time_id = { [Op.in]: d.studying_time.split(",") };
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
      // periodo SOBRE la season de la SECCION (no la de la preinscripcion)
      if (d.period) {
        whereSectionSeason.period_id = { [Op.in]: d.period.split(",") };
      }

      // asociaciones (Sequelize las ignora si ya existen)
      models.crs_assignation_preinscription.belongsTo(models.crs_assignation_section, {
        foreignKey: "taken_by_section_id",
        targetKey: "section_id"
      });
      models.crs_assignation_preinscription.belongsTo(models.std_student, { foreignKey: "student_id" });
      models.crs_assignation_preinscription.belongsTo(models.std_branch, { foreignKey: "branch_id" });
      models.crs_assignation_preinscription.belongsTo(models.std_career, { foreignKey: "career_id" });
      models.crs_assignation_preinscription.belongsTo(models.std_studying_cycle, { foreignKey: "studying_cycle_id"
   });
      models.crs_assignation_preinscription.belongsTo(models.std_studying_time, { foreignKey: "studying_time_id"
  });

      models.crs_assignation_section.belongsTo(models.crs_course, { foreignKey: "course_id" });
      models.crs_assignation_section.belongsTo(models.pfs_professor, { foreignKey: "professor_id" });
      models.crs_assignation_section.belongsTo(models.crs_assignation_classroom, { foreignKey: "classroom_id" });
      models.crs_assignation_section.belongsTo(models.crs_assignation_season, { foreignKey: "season_id" });

      models.crs_assignation_season.belongsTo(models.std_period, { foreignKey: "period_id" });
      models.crs_assignation_classroom.belongsTo(models.std_branch, { foreignKey: "branch_id" });

      const classroomInclude = {
        model: models.crs_assignation_classroom,
        attributes: ["name", "branch_id"],
        required: classroomRequired,
        include: [
          { model: models.std_branch, attributes: ["name"], required: false }
        ]
      };
      if (clsrmName && clsrmName.trim() !== "") {
        classroomWhere.name = { [Op.like]: "%" + clsrmName + "%" };
      }
      if (Object.keys(classroomWhere).length > 0) {
        classroomInclude.where = classroomWhere;
      }

      const result = [];

      const preinscriptions = await models.crs_assignation_preinscription.findAll({
        where: wherePre,
        attributes: [
          "preinscription_id",
          "course_id",
          "student_id",
          "inscription_id",
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
              { model: models.pfs_professor, attributes: ["setup", "professor_id"], required: false },
              {
                model: models.crs_assignation_season,
                attributes: ["season_id", "period_id"],
                required: true,
                where: whereSectionSeason,
                include: [
                  { model: models.std_period, attributes: ["name"], required: false }
                ]
              },
              classroomInclude
            ]
          }
        ]
      });

      if (preinscriptions && preinscriptions.length > 0) {
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
        scores.forEach(s => {
          scoreMap.set(s.section_id + "-" + s.student_id, s);
        });

        preinscriptions.forEach(pre => {
          const section = pre.crs_assignation_section;
          const student = pre.std_student;
          const course = section && section.crs_course;
          const score = section
            ? scoreMap.get(section.section_id + "-" + pre.student_id)
            : null;
          const classroom = section && section.crs_assignation_classroom;

          let professorSetup = null;
          if (section && section.pfs_professor && section.pfs_professor.setup) {
            try {
              professorSetup = JSON.parse(section.pfs_professor.setup);
            } catch (e) { professorSetup = null; }
          }

          const sectionSeason = section && section.crs_assignation_season;
          const sectionPeriod = sectionSeason && sectionSeason.std_period;
          let courseSetup = null;
          if (course && course.setup) {
            try {
              courseSetup = typeof course.setup === "string" ? JSON.parse(course.setup) : course.setup;
            } catch (e) {
              courseSetup = null;
            }
          }
          const isPractical = !!(courseSetup && courseSetup.is_practical === true);

          // Resolver sede: prioridad a classroom.branch_id (intersede), fallback a preinscription.branch_id
          const branchId = classroom && classroom.branch_id ? classroom.branch_id : pre.branch_id;
          const branchName = (classroom && classroom.std_branch && classroom.std_branch.name) 
            || (pre.std_branch && pre.std_branch.name) 
            || "No definida";

          result.push({
            preinscription_id: pre.preinscription_id,
            student_id: pre.student_id,
            student_name: (student && student.name) || "Sin nombre",
            student_id_card: (student && student.student_id_card) || "Sin carné",
            student_status_code: (student && student.status_code) || null,
            professor_nit: (professorSetup && professorSetup.nit) || "",
            professor: professorSetup
              ? ((professorSetup.name || "") + " " + (professorSetup.lastname || "")).trim()
              : "No tiene.",
            course: (course && course.name) || "Sin curso",
            course_setup: courseSetup,
            course_type: isPractical ? "practical" : "regular",
            section: (section && section.name) || "Sin sección",
            classroom: (classroom && classroom.name) || "Sin aula",
            score: (score && score.setup) || null,
            branch_id: branchId,
            branch: branchName,
            career: (pre.std_career && pre.std_career.name) || null,
            studying_cycle: (pre.std_studying_cycle && pre.std_studying_cycle.name) || null,
            studying_time: (pre.std_studying_time && pre.std_studying_time.name) || null,
            period: (sectionPeriod && sectionPeriod.name) || null
          });
        });
      }

      resolve(result);
    } catch (error) {
      console.error("Error al obtener preinscripciones:", error);
      reject(error);
    }
  })();