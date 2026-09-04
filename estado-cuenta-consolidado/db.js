console.log(req.body);

let condition = {};
let condMovement = {};
if (req.body.d.branch) condition.branch_id = req.body.d.branch.split(",");
if (req.body.d.career) condition.career_id = req.body.d.career.split(",");
if (req.body.d.period) {
    condition.period_id = condMovement.period_id = req.body.d.period.split(",");
}
if (req.body.d.movement_type) {
    condMovement.type_id = req.body.d.movement_type.split(",");
}


models.std_inscription.belongsTo(models.std_branch, {
    foreignKey: "branch_id"
});
models.std_inscription.belongsTo(models.std_career, {
    foreignKey: "career_id"
});
models.std_inscription.belongsTo(models.std_period, {
    foreignKey: "period_id"
});
models.std_inscription.belongsTo(models.std_studying_time, {
    foreignKey: "studying_time_id"
});
models.std_inscription.belongsTo(models.std_student, {
    foreignKey: "student_id"
});

//ERROR POR ACA-------------
models.std_student.belongsTo(models.std_account, {
    foreignKey: "student_id",
    targetKey: "student_id"
});
models.std_account.belongsTo(models.acc_account, {
    foreignKey: "account_id",
    targetKey: "account_id"
});
models.acc_account.hasMany(models.std_account_movement, {
    foreignKey: "account_id",
    targetKey: "account_id"
});
/*
models.std_student.hasMany(models.std_account, {
    foreignKey: "student_id"
});
models.std_account.belongsTo(models.acc_account, {
    foreignKey: "account_id",
    targetKey: "account_id"
});
models.std_account_movement.belongsTo(models.acc_account, {
    foreignKey: "account_id"
});
*/
let whereFields = models.Sequelize.where(
    models.Sequelize.col(
        "std_student->std_account->acc_account->std_account_movements.period_id",
    ),
    "=",
    models.Sequelize.col(
        "std_inscription.period_id",
    ),
);

condMovement.where = whereFields;

models.std_inscription.findAll({
    where: condition,
    attributes: ["create_date"],
    include: [{
            model: models.std_branch,
            attributes: ["name"],
            required: true
        },
        {
            model: models.std_career,
            attributes: ["name"],
            required: true
        },
        {
            model: models.std_period,
            attributes: ["name"],
            required: true
        },
        {
            model: models.std_student,
            attributes: ["student_id_card", "name", "setup","dpi"],
            required: true,
            where: {
                name: {
                    [models.Sequelize.Op.notLike]: ''
                }
            },
            include: [{
                model: models.std_account,
                required: true,
                include: [{
                    model: models.acc_account,
                    required: true,
                    include: [{
                        model: models.std_account_movement,
                        attributes: ["amount", "paid"],
                        required: true,
                        where: condMovement
                    }]
                }]
            }]


        },
    ],
}).then(inscriptions => {
    resolve(inscriptions)
}).catch(err => {
    reject(err)
})