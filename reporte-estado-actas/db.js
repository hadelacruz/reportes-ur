function splitIn(v) {
    if (!v) return null;
    const arr = String(v)
        .split(",")
        .map((x) => x.trim())
        .filter(Boolean);
    return arr.length ? arr : null;
}

async function getRecordsStatusData(filters) {
    const {
        branch_id,
        period_id,
        career_id,
        professor_id,
        studying_cycle_id,
        record_type,
        record_code,
        enterprise_id
    } = filters;

    // Sede/carrera/catedrático/curso se toman directo de crs_record: son
    // obligatorios ahí y quedan grabados con el contexto real al momento de
    // generar el acta. No se resuelven vía aula/sección porque esa relación
    // puede tener datos incompletos (aulas sin branch_id) y perdería actas
    // reales. Aula y ciclo de estudio sí dependen de la sección/aula, porque
    // crs_record no los guarda.
    models.crs_record.belongsTo(models.std_branch, { foreignKey: "branch_id" });
    models.crs_record.belongsTo(models.std_career, { foreignKey: "career_id" });
    models.crs_record.belongsTo(models.crs_course, { foreignKey: "course_id" });
    models.crs_record.belongsTo(models.pfs_professor, { foreignKey: "professor_id" });
    models.crs_record.belongsTo(models.crs_assignation_section, { foreignKey: "section_id" });
    models.crs_assignation_section.belongsTo(models.crs_assignation_classroom, { foreignKey: "classroom_id" });
    models.crs_assignation_classroom.belongsTo(models.std_studying_cycle, { foreignKey: "studying_cycle_id" });
    models.crs_assignation_section.belongsTo(models.crs_assignation_season, { foreignKey: "season_id" });
    models.crs_assignation_season.belongsTo(models.std_period, { foreignKey: "period_id" });

    const recordWhere = {};
    if (branch_id) recordWhere.branch_id = { [models.Sequelize.Op.in]: branch_id };
    if (career_id) recordWhere.career_id = { [models.Sequelize.Op.in]: career_id };
    if (professor_id) recordWhere.professor_id = { [models.Sequelize.Op.in]: professor_id };
    if (record_type) recordWhere.record_type = { [models.Sequelize.Op.in]: record_type };
    if (record_code) recordWhere.record_code = record_code;

    const records = await models.crs_record.findAll({
        where: recordWhere,
        attributes: [
            "uuid",
            "record_code",
            "record_type",
            "record_correction_number",
            "create_date",
            "is_verified",
            "is_rejected",
            "section_id"
        ],
        include: [
            { model: models.std_branch, attributes: ["name"] },
            { model: models.std_career, attributes: ["name"] },
            { model: models.crs_course, attributes: ["name"] },
            { model: models.pfs_professor, attributes: ["setup"] },
            {
                model: models.crs_assignation_section,
                attributes: ["section_id"],
                required: true,
                include: [
                    {
                        model: models.crs_assignation_classroom,
                        attributes: ["name"],
                        required: !!studying_cycle_id,
                        where: studying_cycle_id
                            ? { studying_cycle_id: { [models.Sequelize.Op.in]: studying_cycle_id } }
                            : undefined,
                        include: [
                            { model: models.std_studying_cycle, attributes: ["name"] }
                        ]
                    },
                    {
                        model: models.crs_assignation_season,
                        attributes: ["season_id"],
                        required: true,
                        where: {
                            enterprise_id,
                            ...(period_id ? { period_id: { [models.Sequelize.Op.in]: period_id } } : {})
                        },
                        include: [
                            { model: models.std_period, attributes: ["name"] }
                        ]
                    }
                ]
            }
        ],
        order: [
            ["record_correction_number", "DESC"],
            ["create_date", "DESC"]
        ]
    });

    return records.map((r) => r.toJSON());
}

// Una misma acta puede tener varias correcciones (mismas filas con distinto
// record_correction_number). La identidad de una acta es section_id +
// record_type (mismo criterio que usa /course/record/do-print para numerar
// las correcciones). Aquí nos quedamos solo con la última.
function resolveLatestCorrections(rows) {
    const latestByKey = {};

    for (const row of rows) {
        const key = `${row.section_id}_${row.record_type}`;
        const current = latestByKey[key];

        if (!current) {
            latestByKey[key] = row;
            continue;
        }

        const currentCorrection = current.record_correction_number || 0;
        const rowCorrection = row.record_correction_number || 0;

        if (
            rowCorrection > currentCorrection ||
            (rowCorrection === currentCorrection &&
                new Date(row.create_date) > new Date(current.create_date))
        ) {
            latestByKey[key] = row;
        }
    }

    return Object.values(latestByKey);
}

async function getRecordsStatusReport(req, res) {
    try {
        const d = req.body.d || {};
        const enterprise_id = req.user.enterprise_id;

        const record_type = splitIn(d.record_type);
        if (record_type && record_type.includes("final")) {
            record_type.push("Fase Final");
        }

        const rows = await getRecordsStatusData({
            branch_id: splitIn(d.branch),
            period_id: splitIn(d.period),
            career_id: splitIn(d.career),
            professor_id: splitIn(d.professor),
            studying_cycle_id: splitIn(d.studying_cycle),
            record_type: record_type,
            record_code: d.record_code || null,
            enterprise_id: enterprise_id
        });

        let latest = resolveLatestCorrections(rows);

        const record_status = d.record_status || null;
        if (record_status === "verified") {
            latest = latest.filter((r) => !!r.is_verified);
        } else if (record_status === "rejected") {
            latest = latest.filter((r) => !!r.is_rejected);
        } else if (record_status === "pending") {
            latest = latest.filter((r) => !r.is_verified && !r.is_rejected);
        }

        const result = latest.map((r) => {
            const professorSetup = r.pfs_professor && r.pfs_professor.setup
                ? JSON.parse(r.pfs_professor.setup)
                : null;
            const section = r.crs_assignation_section || {};
            const season = section.crs_assignation_season || {};
            const classroom = section.crs_assignation_classroom || {};

            return {
                uuid: r.uuid,
                record_code: r.record_code,
                record_type: r.record_type,
                record_correction_number: r.record_correction_number,
                create_date: r.create_date,
                is_verified: !!r.is_verified,
                is_rejected: !!r.is_rejected,
                branch: r.std_branch ? r.std_branch.name : null,
                career: r.std_career ? r.std_career.name : null,
                course: r.crs_course ? r.crs_course.name : null,
                classroom: classroom.name || null,
                professor: professorSetup
                    ? `${professorSetup.name} ${professorSetup.lastname}`
                    : null,
                studying_cycle: classroom.std_studying_cycle ? classroom.std_studying_cycle.name : null,
                period: season.std_period ? season.std_period.name : null
            };
        });

        resolve(result);
    } catch (error) {
        console.error("Error en reporte de estado de actas:", error);
        reject(error);
    }
}

getRecordsStatusReport(req, res);
