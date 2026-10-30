let condition = {
    setting_id: 1
};

console.log(req.body.d.type);

let branchIds = null;
//condition.branch_id = br.branch_id;
if (req.body.d.period) condition.period_id = req.body.d.period.split(",");
if (req.body.d.professor) condition.professor_id = req.body.d.professor.split(",");
if (req.body.d.course) condition.course_id = req.body.d.course.split(",");
if (req.body.d.branch) branchIds = req.body.d.branch.split(",");


let _tType = req.body.d.type;

condition = { tType: _tType }

models.std_portal_professor_evaluation.belongsTo(models.std_period, {
    foreignKey: "period_id"
});
models.std_portal_professor_evaluation.belongsTo(models.pfs_professor, {
    foreignKey: "professor_id"
});
models.std_portal_professor_evaluation.belongsTo(models.crs_course, {
    foreignKey: "course_id"
});

models.std_portal_professor_evaluation.belongsTo(models.usr_user, {
    foreignKey: "user_id"
})



models.std_portal_professor_evaluation.findAll({
    where: condition,
    include: [{
        model: models.std_period,
        attributes: ["period_id", "name"]
    }, {
        model: models.pfs_professor,
        attributes: ["professor_id", "setup"],
        ...(branchIds && {
            where: models.sequelize.where(
                models.sequelize.fn('JSON_EXTRACT', models.sequelize.col('setup'), '$.reception_branch'), {
                    [models.Sequelize.Op.in]: branchIds
                }
            )
        })
    }, {
        model: models.crs_course,
        attributes: ["course_id", "name"]
    },
    {
        model: models.usr_user,
        attributes: ["user_id", "name"]
    }
    ]
}).then(answers => {
    resolve(answers);
}).catch(err => {
    reject(err);
});