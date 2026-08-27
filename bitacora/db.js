let condition = {};
//condition.branch_id = br.branch_id;
if (req.body.d.log_type) condition.type_id = req.body.d.log_type.split(",");
if (req.body.d.studnt) condition.student_id = req.body.d.studnt.student_id;
if (req.body.d.creationdate) {
    const creationDate = new Date(req.body.d.creationdate);
    const startOfDay = new Date(creationDate.setUTCHours(0, 0, 0, 0)); // Inicio del día
    const endOfDay = new Date(creationDate.setUTCHours(23, 59, 59, 999)); // Fin del día
    condition.create_date = { [models.Sequelize.Op.gte]: startOfDay, [models.Sequelize.Op.lt]: endOfDay };
}
// Rango de fechas (inicio y fin)
if (req.body.d.start_date && req.body.d.end_date) {
    let startDate = new Date(req.body.d.start_date);
    let endDate = new Date(req.body.d.end_date);
    startDate.setHours(startDate.getHours() + 6);
    endDate.setHours(endDate.getHours() + 6);

    condition.create_date = {
        [models.Sequelize.Op.between]: [startDate, endDate]
    };
}

// Si solo viene una fecha de inicio
if (req.body.d.start_date && !req.body.d.end_date) {
    let startDate = new Date(req.body.d.start_date);
    startDate.setHours(startDate.getHours() + 6);
    condition.create_date = {
        [models.Sequelize.Op.gte]: startDate
    };
}

// Si solo viene una fecha de fin
if (!req.body.d.start_date && req.body.d.end_date) {
    let endDate = new Date(req.body.d.end_date);
    endDate.setHours(endDate.getHours() + 6);
    condition.create_date = {
        [models.Sequelize.Op.lte]: endDate
    };
}

let branch
// if (req.body.d.branch) condition.branch_id = req.body.d.branch.split(",");
if (req.body.d.user) condition.create_user_id = req.body.d.user.split(",");


models.std_log.belongsTo(models.std_log_type, {
    foreignKey: "type_id",
});
models.std_log_type.hasMany(models.std_log, {
    foreignKey: "type_id",
});
models.std_log.belongsTo(models.std_student, {
    foreignKey: "student_id",
});
models.std_log.belongsTo(models.std_student, {
    foreignKey: "student_id",
});
models.std_log.belongsTo(models.usr_user, {
    foreignKey: "create_user_id",
    targetKey: "user_id",
});

models.std_log.findAll({
    where: condition,
    include: [{
            model: models.std_student
        },
        {
            model: models.std_log_type,
            // where: condition.type_id ? {
            //     type_id: condition.type_id
            // } : {},
        },
        {
            model: models.usr_user
        }
    ]
}).then(logs => {
    resolve(logs);
}).catch(err => {
    reject(err);
});