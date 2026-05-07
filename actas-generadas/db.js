models.crs_record.belongsTo(models.crs_assignation_section, { foreignKey: "section_id" });
models.crs_record.belongsTo(models.std_branch, { foreignKey: "branch_id" });
models.crs_record.belongsTo(models.crs_course, { foreignKey: "course_id" });
models.crs_record.belongsTo(models.pfs_professor, { foreignKey: "professor_id" });
models.crs_record.belongsTo(models.std_career, { foreignKey: "career_id" });
models.crs_record.belongsTo(models.std_studying_time, { foreignKey: "studying_time_id" });
models.crs_assignation_section.belongsTo(models.std_studying_cycle, { foreignKey: "studying_cycle_id" });
models.crs_assignation_section.belongsTo(models.crs_assignation_season, { foreignKey: "season_id" });
models.crs_assignation_section.belongsTo(models.std_branch, { foreignKey: "branch_id" });
models.crs_assignation_section.belongsTo(models.crs_assignation_classroom, { foreignKey: "classroom_id" });
models.crs_assignation_season.belongsTo(models.std_period, { foreignKey: "period_id" });
models.crs_assignation_classroom.belongsTo(models.std_branch, { foreignKey: "branch_id" });

var seasonFilter = ":season_id";
var branchFilter = ":branch_id";
var careerFilter = ":career_id";
var cycleFilter = ":studying_cycle_id";
var studyingTimeFilter = ":studying_time_id";
var professorFilter = ":professor_id";
var typeFilter = ":record_type";
var statusFilter = ":record_status";
var dateFromFilter = ":date_from";
var dateToFilter = ":date_to";
var classroomFilter = ":classroom_name";

function parseJson(value, fallback) {
  try {
    if (typeof value === "string") return JSON.parse(value);
    if (value !== null && value !== undefined) return value;
  } catch (error) {}
  return fallback;
}

function stripAccents(value) {
  return String(value || "")
    .normalize("NFD")
    .replace(/[\u0300-\u036f]/g, "")
    .toLowerCase()
    .trim()
    .replace(/\s+/g, " ");
}

function isNumericValue(value) {
  if (value === null || value === undefined || value === "") return false;
  if (typeof value === "string" && value.trim() === "") return false;
  return !isNaN(Number(value));
}

function normalizeRecordType(recordType) {
  var clean = stripAccents(recordType);
  if (!clean) return "";
  if (clean === "final") return "Fase Final";
  if (clean === "fase final") return "Fase Final";
  if (clean === "fase 1") return "Fase 1";
  if (clean === "fase 2") return "Fase 2";
  if (clean === "recuperacion 1" || clean === "recuperacion1") return "Recuperacion 1";
  if (clean === "recuperacion 2" || clean === "recuperacion2") return "Recuperacion 2";
  if (clean === "fase extraordinario 1") return "Fase Extraordinario 1";
  if (clean === "fase extraordinario 2") return "Fase Extraordinario 2";
  if (clean === "practico") return "Práctico";
  return String(recordType || "").trim();
}

function getValidationPhase(recordType) {
  var normalized = normalizeRecordType(recordType);
  if (normalized === "Fase Extraordinario 1") return "Fase 1";
  if (normalized === "Fase Extraordinario 2") return "Fase 2";
  return normalized;
}

function getActaStageMeta(recordStages, phaseName) {
  var stages = Array.isArray(recordStages) ? recordStages : [];
  var normalizedPhase = stripAccents(phaseName);

  for (var i = 0; i < stages.length; i++) {
    var stage = stages[i] || {};
    if (stripAccents(stage.name) === normalizedPhase) {
      return stage;
    }
  }

  return null;
}

function getStageValue(studentStages, stageName) {
  var stages = Array.isArray(studentStages) ? studentStages : [];
  var normalizedTarget = stripAccents(stageName);

  for (var i = 0; i < stages.length; i++) {
    var item = stages[i] || {};
    if (stripAccents(item.name) === normalizedTarget) {
      return item.value;
    }
  }

  return undefined;
}

function isNSPValue(value) {
  return stripAccents(value) === "nsp";
}

function isSDEValue(value) {
  return stripAccents(value) === "sde";
}

function isValidStudentForActa(studentEntry, recordType, recordStages) {
  if (!studentEntry) return false;

  var normalizedType = normalizeRecordType(recordType);
  var phase = getValidationPhase(recordType);
  var studentStages = Array.isArray(studentEntry.stages) ? studentEntry.stages : [];
  if (!studentStages.length) return false;

  if (phase === "Práctico") {
    var practicalStages = ["Seminario", "Plan Práctico", "Desarrollo", "Informe Final", "Consolidado"];
    for (var p = 0; p < practicalStages.length; p++) {
      var practicalValue = getStageValue(studentStages, practicalStages[p]);
      if (isNumericValue(practicalValue)) return true;
    }
    return false;
  }

  if (phase === "Recuperacion 1" || phase === "Recuperacion 2") {
    // Para actas de recuperación, el valor se coloca en "Fase Final - Examen"
    // Validar que Fase Final - Examen tenga valor numérico
    var finalExamValue = getStageValue(studentStages, "Fase Final - Examen");
    return isNumericValue(finalExamValue);
  }

  if (normalizedType === "Fase Extraordinario 1") {
    // Extraordinario 1 sustituye únicamente el examen de Fase 1
    var fase1ExamValue = getStageValue(studentStages, "Fase 1 - Examen");
    return isNumericValue(fase1ExamValue);
  }

  if (normalizedType === "Fase Extraordinario 2") {
    // Extraordinario 2 sustituye únicamente el examen de Fase 2
    var fase2ExamValue = getStageValue(studentStages, "Fase 2 - Examen");
    return isNumericValue(fase2ExamValue);
  }

  if (phase === "Fase 1" || phase === "Fase 2" || phase === "Fase Final") {
    var zoneValue = getStageValue(studentStages, phase + " - Zona");
    var examValue = getStageValue(studentStages, phase + " - Examen");

    var hasZone = isNumericValue(zoneValue);
    var hasExam = isNumericValue(examValue);
    var hasNSP = isNSPValue(examValue);
    var hasSDE = isSDEValue(examValue);
    var stageMeta = getActaStageMeta(recordStages, phase);

    if (phase === "Fase Final" && stageMeta && stageMeta.sde === true) {
      return true;
    }

    if (phase === "Fase Final" && hasSDE) {
      return true;
    }

    return hasZone && (hasExam || hasNSP);
  }

  return false;
}

function formatDate(value) {
  if (!value) return "N/A";
  var date = new Date(value);
  if (isNaN(date.getTime())) return "N/A";
  var day = date.getDate().toString().padStart(2, "0");
  var month = (date.getMonth() + 1).toString().padStart(2, "0");
  return day + "/" + month + "/" + date.getFullYear();
}

var recordWhere = { record_type: { [models.Sequelize.Op.ne]: null } };
var sectionWhere = { enterprise_id: req.user.enterprise_id };

if (seasonFilter !== "") {
  var seasonArr = seasonFilter.split(",");
  sectionWhere.season_id = seasonArr.length === 1 ? seasonArr[0] : { [models.Sequelize.Op.in]: seasonArr };
}

if (cycleFilter !== "") {
  var cycleArr = cycleFilter.split(",");
  sectionWhere.studying_cycle_id = cycleArr.length === 1 ? cycleArr[0] : { [models.Sequelize.Op.in]: cycleArr };
}

if (careerFilter !== "") {
  var careerArr = careerFilter.split(",");
  recordWhere.career_id = careerArr.length === 1 ? careerArr[0] : { [models.Sequelize.Op.in]: careerArr };
}

if (professorFilter !== "") {
  var professorArr = professorFilter.split(",");
  recordWhere.professor_id = professorArr.length === 1 ? professorArr[0] : { [models.Sequelize.Op.in]: professorArr };
}

if (studyingTimeFilter !== "") {
  var studyingTimeArr = studyingTimeFilter.split(",");
  recordWhere.studying_time_id = studyingTimeArr.length === 1 ? studyingTimeArr[0] : { [models.Sequelize.Op.in]: studyingTimeArr };
}

if (dateFromFilter !== "" && dateToFilter !== "") {
  recordWhere.create_date = {
    [models.Sequelize.Op.between]: [dateFromFilter + " 00:00:00", dateToFilter + " 23:59:59"]
  };
} else if (dateFromFilter !== "") {
  recordWhere.create_date = { [models.Sequelize.Op.gte]: dateFromFilter + " 00:00:00" };
} else if (dateToFilter !== "") {
  recordWhere.create_date = { [models.Sequelize.Op.lte]: dateToFilter + " 23:59:59" };
}

var classroomInclude = {
  model: models.crs_assignation_classroom,
  attributes: ["name", "classroom_id", "branch_id"],
  include: [
    { model: models.std_branch, attributes: ["name", "branch_id"] }
  ]
};
if (classroomFilter !== "") {
  classroomInclude.required = true;
  classroomInclude.where = { name: { [models.Sequelize.Op.like]: "%" + classroomFilter + "%" } };
}
if (branchFilter !== "") {
  var branchArrWhere = branchFilter.split(",");
  classroomInclude.required = true;
  classroomInclude.where = classroomInclude.where || {};
  classroomInclude.where.branch_id = branchArrWhere.length === 1 ? branchArrWhere[0] : { [models.Sequelize.Op.in]: branchArrWhere };
}

models.crs_record.findAll({
  where: recordWhere,
  attributes: [
    "record_id",
    "branch_id",
    "career_id",
    "course_id",
    "professor_id",
    "studying_time_id",
    "section_id",
    "stages",
    "create_date",
    "create_user_id",
    "uuid",
    "detail",
    "group",
    "exam_date",
    "record_type",
    "record_code",
    "record_correction_number",
    "is_verified",
    "is_rejected",
    "rejection_reason"
  ],
  include: [
    {
      model: models.crs_assignation_section,
      required: true,
      where: sectionWhere,
      attributes: ["section_id", "name", "season_id", "course_id", "branch_id", "studying_cycle_id", "classroom_id"],
      include: [
        { model: models.std_studying_cycle, attributes: ["name", "studying_cycle_id"] },
        {
          model: models.crs_assignation_season,
          attributes: ["name", "season_id", "period_id"],
          include: [
            { model: models.std_period, attributes: ["name"], required: false }
          ]
        },
        { model: models.std_branch, attributes: ["name", "branch_id"] },
        classroomInclude
      ]
    },
    { model: models.std_branch, attributes: ["name", "branch_id"] },
    { model: models.std_career, attributes: ["name", "career_id"] },
    { model: models.crs_course, attributes: ["name", "course_id"] },
    { model: models.pfs_professor, attributes: ["setup", "professor_id"] },
    { model: models.std_studying_time, attributes: ["name", "studying_time_id"] }
  ]
}).then(function(records) {
  var jsonRecords = records.map(function(r) { return r.toJSON(); });

  var normalizedTypeFilters = [];
  if (typeFilter !== "") {
    typeFilter.split(",").forEach(function(value) {
      var normalized = normalizeRecordType(value);
      if (normalized && normalizedTypeFilters.indexOf(normalized) === -1) {
        normalizedTypeFilters.push(normalized);
      }
    });
  }

  var dedupMap = {};
  jsonRecords.forEach(function(record) {
    var normalizedTypeForDedup = normalizeRecordType(record.record_type);
    var dedupTypeKey = normalizedTypeForDedup || String(record.record_type || "").trim();
    var dedupKey = record.section_id + "|" + dedupTypeKey;
    var currentRank = Number(record.record_correction_number || 0);
    var currentDate = record.create_date ? new Date(record.create_date).getTime() : 0;

    if (!dedupMap[dedupKey]) {
      dedupMap[dedupKey] = record;
      return;
    }

    var existing = dedupMap[dedupKey];
    var existingRank = Number(existing.record_correction_number || 0);
    var existingDate = existing.create_date ? new Date(existing.create_date).getTime() : 0;

    if (
      currentRank > existingRank ||
      (currentRank === existingRank && currentDate > existingDate) ||
      (currentRank === existingRank && currentDate === existingDate && record.record_id > existing.record_id)
    ) {
      dedupMap[dedupKey] = record;
    }
  });

  var dedupRecords = Object.keys(dedupMap).map(function(key) {
    return dedupMap[key];
  });

  var rows = [];

  dedupRecords.forEach(function(record) {
    var normalizedType = normalizeRecordType(record.record_type);
    if (normalizedTypeFilters.length > 0 && normalizedTypeFilters.indexOf(normalizedType) === -1) {
      return;
    }

    var detail = parseJson(record.detail, []);
    var stages = parseJson(record.stages, []);
    var students = Array.isArray(detail) ? detail : [];
    var totalAlumnos = students.length;
    var totalAlumnosValidos = 0;

    students.forEach(function(studentEntry) {
      if (isValidStudentForActa(studentEntry, record.record_type, stages)) {
        totalAlumnosValidos++;
      }
    });

    var se_paga = totalAlumnosValidos > 0 ? "Sí" : "No";

    var section = record.crs_assignation_section || {};
    var career = record.std_career || {};
    var course = record.crs_course || section.crs_course || {};
    var professor = record.pfs_professor || {};
    var studyingTime = record.std_studying_time || {};
    var season = section.crs_assignation_season || {};
    var period = season.std_period || {};
    var classroom = section.crs_assignation_classroom || {};

    var docente = "N/A";
    var nit = "";
    if (professor.setup) {
      try {
        var pSetup = typeof professor.setup === "string" ? JSON.parse(professor.setup) : professor.setup;
        docente = ((pSetup.name || "") + " " + (pSetup.lastname || "")).trim() || "N/A";
        nit = pSetup.nit || "";
      } catch (error) {}
    }

    var classroomBranch = classroom.std_branch || {};
    var sectionBranch = section.std_branch || {};
    var recordBranch = record.std_branch || {};
    var sede = classroomBranch.name || sectionBranch.name || recordBranch.name || "N/A";
    var sede_branch_id = classroom.branch_id || section.branch_id || record.branch_id || null;
    var carreraName = career.name || "N/A";
    var ciclo = section.std_studying_cycle ? section.std_studying_cycle.name : "N/A";
    var jornada = studyingTime.name || "N/A";
    var curso = course.name || "N/A";
    var seccion = section.name || "N/A";
    var aula = classroom.name || seccion;
    var periodo = period.name || season.name || "N/A";

    rows.push({
      sede: sede,
      sede_branch_id: sede_branch_id,
      carrera: carreraName,
      ciclo: ciclo,
      jornada: jornada,
      curso: curso,
      fase: normalizedType || record.record_type || "N/A",
      seccion: seccion,
      aula: aula,
      periodo: periodo,
      docente: docente,
      nit: nit,
      fecha_fmt: formatDate(record.create_date),
      se_paga: se_paga,
      cant_actas: 1,
      cant_alumnos: totalAlumnosValidos,
      cant_alumnos_total: totalAlumnos,
      record_type_normalized: normalizedType,
      record_id: record.record_id
    });
  });

  if (statusFilter === "con_nota") {
    rows = rows.filter(function(row) {
      return row.se_paga === "Sí";
    });
  } else if (statusFilter === "nsp") {
    rows = rows.filter(function(row) {
      return row.se_paga === "No";
    });
  }

  if (branchFilter !== "") {
    var branchArr = branchFilter.split(",");
    rows = rows.filter(function(row) {
      return branchArr.indexOf(String(row.sede_branch_id)) !== -1;
    });
  }

  rows.sort(function(a, b) {
    if (a.sede !== b.sede) return String(a.sede).localeCompare(String(b.sede));
    if (a.carrera !== b.carrera) return String(a.carrera).localeCompare(String(b.carrera));
    if (a.curso !== b.curso) return String(a.curso).localeCompare(String(b.curso));
    if (a.fase !== b.fase) return String(a.fase).localeCompare(String(b.fase));
    return Number(b.record_id || 0) - Number(a.record_id || 0);
  });

  rows = rows.map(function(row) {
    delete row.record_type_normalized;
    delete row.record_id;
    return row;
  });

  resolve(rows);
}).catch(function(err) {
  console.error("Error en actas-generadas:", err);
  reject(err);
});
