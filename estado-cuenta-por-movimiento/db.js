console.log(req.body);

let condition = {};
let condMovement = {};
if (req.body.d.branch) condition.branch_id = req.body.d.branch.split(",");
if (req.body.d.career) condition.career_id = req.body.d.career.split(",");
if (req.body.d.semester) condition.studying_cycle_id = req.body.d.semester.split(",");
if (req.body.d.period) {
    condition.period_id = req.body.d.period.split(",");
    // Solo agregamos al movimiento si es necesario, pero con cuidado
    condMovement.period_id = req.body.d.period.split(",");
}
if (req.body.d.movement_type) {
    condMovement.type_id = req.body.d.movement_type.split(",");
}

//---------------------------------
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
models.std_inscription.belongsTo(models.std_studying_cycle, {
    foreignKey: "studying_cycle_id"
});
models.std_inscription.belongsTo(models.std_student, {
    foreignKey: "student_id"
});

//---------------------------------
models.std_student.hasMany(models.std_account, {
    foreignKey: "student_id",
    targetKey: "student_id"
});
models.std_account.belongsTo(models.acc_account, {
    foreignKey: "account_id"
});
models.acc_account.hasMany(models.std_account_movement, {
    foreignKey: "account_id"
});

//para tipo de movimiento
models.std_account_movement.belongsTo(models.std_account_movement_type, {
    foreignKey: "type_id"
});

//preinscripciones
models.std_inscription.hasMany(models.crs_assignation_preinscription, {
    foreignKey: "inscription_id"
});

//----------------------------------
// Solo agregamos esta condición si es necesario
let whereFields = models.Sequelize.where(
    models.Sequelize.col(
        "std_student->std_account->acc_account->std_account_movements.period_id"
    ),
    "=",
    models.Sequelize.col(
        "std_inscription.period_id"
    )
);

// Mantenemos las condiciones existentes y agregamos el where
condMovement = {
    ...condMovement,
    where: whereFields
};

//---------------------------------
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
            model: models.std_studying_time,
            attributes: ["name"],
            required: true
        },
        {
            model: models.std_studying_cycle,
            attributes: ["name"],
            required: true
        },
        {
            model: models.crs_assignation_preinscription,
            attributes: ["course_id", "inscription_id"],
            required: true
        },
        {
            model: models.std_student,
            attributes: ["student_id_card", "name", "setup"],
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
                        attributes: ["movement_id", "amount", "paid", "expire_date"],
                        required: true,
                        where: condMovement,
                        include: [{
                            model: models.std_account_movement_type,
                            attributes: ["name"],
                            required: true
                        }]
                    }]
                }]
            }]
        },
    ],
}).then(inscriptions => {
    resolve(inscriptions);
}).catch(err => {
    reject(err);
});