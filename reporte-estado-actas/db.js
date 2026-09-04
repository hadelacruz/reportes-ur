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

    // Sede/carrera/catedrático/curso se resuelven igual que en
    // /course/record/do-get-season-list-all (via aula/sección), para que el
    // conteo calce con el módulo courses_records.
    models.crs_record.belongsTo(models.crs_assignation_section, { foreignKey: "section_id" });
    models.crs_assignation_section.belongsTo(models.crs_assignation_classroom, { foreignKey: "classroom_id" });
    models.crs_assignation_classroom.belongsTo(models.std_branch, { foreignKey: "branch_id" });
    models.crs_assignation_classroom.belongsTo(models.std_studying_cycle, { foreignKey: "studying_cycle_id" });
    models.crs_assignation_classroom.hasMany(models.crs_assignation_classroom_career, { foreignKey: "classroom_id" });
    models.crs_assignation_classroom_career.belongsTo(models.std_career, { foreignKey: "career_id" });
    models.crs_assignation_section.belongsTo(models.pfs_professor, { foreignKey: "professor_id" });
    models.crs_assignation_section.belongsTo(models.crs_course, { foreignKey: "course_id" });
    models.crs_assignation_section.belongsTo(models.crs_assignation_season, { foreignKey: "season_id" });
    models.crs_assignation_season.belongsTo(models.std_period, { foreignKey: "period_id" });

    // Lo único que se filtra directo sobre el acta: su propio tipo y
    // correlativo. El estado se evalúa después, sobre la última corrección.
    const recordWhere = {};
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
            "rejection_reason",
            "section_id",
            // Estos 4 no se usan para filtrar/mostrar sede-carrera-catedrático
            // (eso viene del aula/sección), pero SÍ hacen falta para saber
            // qué es "la misma acta corregida" vs. "otro grupo distinto":
            // un acta se genera una vez por cada combinación única de
            // (sede, carrera, jornada, catedrático) entre los estudiantes de
            // la sección (ver groupBy en record_modal/IndexNetworth.vue), y
            // /course/record/do-print numera las correcciones filtrando
            // exactamente por esas mismas columnas + section_id + record_type.
            "branch_id",
            "career_id",
            "professor_id",
            "studying_time_id"
        ],
        include: [
            {
                model: models.crs_assignation_section,
                attributes: ["section_id"],
                required: true,
                include: [
                    {
                        model: models.crs_assignation_classroom,
                        attributes: ["name"],
                        where: {
                            ...(branch_id ? { branch_id: { [models.Sequelize.Op.in]: branch_id } } : {}),
                            ...(studying_cycle_id ? { studying_cycle_id: { [models.Sequelize.Op.in]: studying_cycle_id } } : {})
                        },
                        include: [
                            { model: models.std_branch, attributes: ["name"] },
                            { model: models.std_studying_cycle, attributes: ["name"] },
                            {
                                model: models.crs_assignation_classroom_career,
                                required: !!career_id,
                                where: career_id
                                    ? { career_id: { [models.Sequelize.Op.in]: career_id } }
                                    : undefined,
                                include: [
                                    { model: models.std_career, attributes: ["career_id", "name"] }
                                ]
                            }
                        ]
                    },
                    {
                        model: models.pfs_professor,
                        required: !!professor_id,
                        where: professor_id
                            ? { professor_id: { [models.Sequelize.Op.in]: professor_id } }
                            : undefined,
                        attributes: ["setup"]
                    },
                    {
                        model: models.crs_course,
                        attributes: ["name"]
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

// Identidad de una acta = section_id + record_type + branch_id + career_id +
// professor_id + studying_time_id (mismo criterio que usa
// /course/record/do-print para numerar correcciones). Ojo: esto NO es lo
// mismo que "section_id + record_type" a secas, porque una sección puede
// generar varias actas EN PARALELO (una por cada grupo de estudiantes con
// distinta sede/carrera/jornada de inscripción) que no son correcciones
// entre sí, sino actas distintas.
function resolveLatestCorrections(rows) {
    const latestByKey = {};

    for (const row of rows) {
        const key = [
            row.section_id,
            row.record_type,
            row.branch_id,
            row.career_id,
            row.professor_id,
            row.studying_time_id
        ].join("_");
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
            const section = r.crs_assignation_section || {};
            const season = section.crs_assignation_season || {};
            const classroom = section.crs_assignation_classroom || {};
            const professorSetup = section.pfs_professor && section.pfs_professor.setup
                ? JSON.parse(section.pfs_professor.setup)
                : null;
            const careers = classroom.crs_assignation_classroom_careers || [];

            return {
                uuid: r.uuid,
                record_code: r.record_code,
                record_type: r.record_type,
                record_correction_number: r.record_correction_number,
                create_date: r.create_date,
                is_verified: !!r.is_verified,
                is_rejected: !!r.is_rejected,
                comment: r.rejection_reason || null,
                branch: classroom.std_branch ? classroom.std_branch.name : null,
                career: careers.length
                    ? careers.map((c) => (c.std_career ? c.std_career.name : null)).filter(Boolean).join(", ")
                    : null,
                course: section.crs_course ? section.crs_course.name : null,
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
