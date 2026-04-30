// Dentro de tu función (la que actualmente tiene ese bloque con resolve/reject)
const Op = models.Sequelize.Op;

// 1) Construir condición base igual que antes, pero usando Op.in
let condition = {};
//condition.branch_id = br.branch_id;
if (req.body.d.period)          condition.period_id         = req.body.d.period.split(",");
if (req.body.d.studying_time)   condition.studying_time_id   = req.body.d.studying_time.split(",");
if (req.body.d.studying_cycle)  condition.studying_cycle_id  = req.body.d.studying_cycle.split(",");
if (req.body.d.professor)       condition.professor_id       = req.body.d.professor.split(",");
if (req.body.d.course)          condition.course_id          = req.body.d.course.split(",");
if (req.body.d.branch)          condition.branch_id          = req.body.d.branch.split(",");

models.crs_record_setting.findOne({
    where: {
        enterprise_id: req.user.enterprise_id
    }
}).then((conf) => {
    let setting = JSON.parse(conf.setup);
    let dias = setting.days;

    // ---- ASOCIACIONES (igual que antes, idealmente moverlas a la definición de modelos) ----
    models.crs_assignation_preinscription.belongsTo(models.std_inscription, {
        foreignKey: "inscription_id"
    });
    models.crs_assignation_preinscription.belongsTo(models.std_branch, {
        foreignKey: "branch_id"
    });

    //Sede
    models.crs_assignation_section.belongsTo(models.std_branch, {
        foreignKey: "branch_id"
    });
    //Ciclo de estudio
    models.crs_assignation_section.belongsTo(models.std_studying_cycle, {
        foreignKey: "studying_cycle_id"
    });
    //periodo
    models.crs_assignation_section.belongsTo(models.crs_assignation_season, {
        foreignKey: "season_id"
    });
    models.crs_assignation_season.belongsTo(models.std_period, {
        foreignKey: "period_id"
    });
    //curso
    models.crs_assignation_section.belongsTo(models.crs_course, {
        foreignKey: "course_id"
    });
    //codigo y nombre del docente
    models.crs_assignation_section.belongsTo(models.pfs_professor, {
        foreignKey: "professor_id"
    });
    models.crs_assignation_section.belongsTo(models.crs_assignation_classroom, {
        foreignKey: "classroom_id"
    });
    models.crs_assignation_classroom.hasMany(models.crs_assignation_classroom_career, {
        foreignKey: "classroom_id"
    });
    models.crs_assignation_classroom_career.belongsTo(models.std_career, {
        foreignKey: "career_id"
    });
    models.crs_assignation_classroom.hasMany(models.crs_assignation_classroom_studying_time, {
        foreignKey: "classroom_id"
    });
    models.crs_assignation_classroom_studying_time.belongsTo(models.std_studying_time, {
        foreignKey: "studying_time_id"
    });
    models.crs_assignation_section.hasMany(models.crs_assignation_preinscription, {
        foreignKey: "taken_by_section_id",
        targetKey: "section_id"
    });
    models.crs_assignation_preinscription.hasOne(models.crs_assignation_student, {
        foreignKey: "preinscription_id"
    });

    // ---- AQUÍ VIENE LA OPTIMIZACIÓN: dos queries en paralelo ----

    const prePromise = models.crs_assignation_preinscription.findAll({
        attributes: ["preinscription_id", "student_id"],
        include: [
            {
                model: models.std_branch,
                attributes: ["name", "branch_id"],
                where: condition.branch_id ? {
                    branch_id: condition.branch_id
                } : {}
            },
            {
                model: models.std_inscription,
                attributes: ["inscription_id"],
                where: condition.period_id ? {
                    period_id: condition.period_id
                } : {}
            }
        ]
    });

    const secPromise = models.crs_assignation_section.findAll({
        attributes: ["section_id", "setup"],
        include: [
            {
                model: models.std_branch,
                attributes: ["name", "branch_id"],
                where: condition.branch_id ? {
                    branch_id: condition.branch_id
                } : {}
            },
            {
                model: models.std_studying_cycle,
                attributes: ["name"],
                where: condition.studying_cycle_id ? {
                    studying_cycle_id: condition.studying_cycle_id
                } : {}
            },
            {
                model: models.crs_assignation_season,
                attributes: ["name"],
                include: [{
                    model: models.std_period,
                    attributes: ["period_id", "name"],
                }],
                where: condition.period_id ? {
                    period_id: condition.period_id
                } : {},
            },
            {
                model: models.crs_course,
                attributes: ["name"],
                where: condition.course_id ? {
                    course_id: condition.course_id
                } : {}
            },
            {
                model: models.pfs_professor,
                attributes: ["setup", "professor_id"],
                where: condition.professor_id ? {
                    professor_id: condition.professor_id
                } : {}
            },
            {
                model: models.crs_assignation_classroom,
                attributes: ["name"],
                include: [
                    {
                        model: models.crs_assignation_classroom_career,
                        include: [{
                            model: models.std_career,
                            attributes: ["name", "career_id"]
                        }]
                    },
                    {
                        model: models.crs_assignation_classroom_studying_time,
                        include: [{
                            model: models.std_studying_time,
                            attributes: ["name", "studying_time_id"]
                        }]
                    }
                ]
            },
            {
                model: models.crs_assignation_preinscription,
                include: [{
                    model: models.crs_assignation_student,
                    attributes: ["section_id", "student_id"],
                }]
            }
        ]
        // Aquí también podrías poner limit / offset si se vuelve muy grande
    });

    // Ejecutar ambas en paralelo
    return Promise.all([prePromise, secPromise])
        .then(([pre, sec]) => {
            resolve({
                dias,
                pre,
                sec
            });
        });

}).catch(err => {
    reject(err);
});
