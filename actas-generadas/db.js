// Relaciones para consultar desde crs_score en lugar de crs_record
models.crs_score.belongsTo(models.std_student, { foreignKey: "student_id" });
models.crs_score.belongsTo(models.crs_assignation_section, { foreignKey: "section_id" });
models.crs_assignation_section.belongsTo(models.std_branch, { foreignKey: "branch_id" });
models.crs_assignation_section.belongsTo(models.crs_course, { foreignKey: "course_id" });
models.crs_assignation_section.belongsTo(models.crs_assignation_season, { foreignKey: "season_id" });
models.crs_assignation_section.belongsTo(models.crs_assignation_classroom, { foreignKey: "classroom_id" });
models.crs_assignation_section.belongsTo(models.std_studying_cycle, { foreignKey: "studying_cycle_id" });
models.crs_assignation_season.belongsTo(models.std_period, { foreignKey: "period_id" });
models.crs_course.belongsTo(models.pfs_professor, { foreignKey: "professor_id" });
models.crs_assignation_classroom.belongsTo(models.std_branch, { foreignKey: "branch_id" });
models.std_student.belongsTo(models.std_career, { foreignKey: "career_id" });
models.std_student.belongsTo(models.std_studying_time, { foreignKey: "studying_time_id" });

var seasonFilter = ":season_id";
var branchFilter = ":branch_id";
var careerFilter = ":career_id";
var cycleFilter = ":studying_cycle_id";
var timeFilter = ":studying_time_id";
var professorFilter = ":professor_id";
var typeFilter = ":record_type";  // Nota: en actas-generadas esto se llama "Fase" en la UI
var statusFilter = ":record_status";
var dateFromFilter = ":date_from";
var dateToFilter = ":date_to";
var classroomFilter = ":classroom_name";

var scoreWhere = {};
var sectionWhere = { enterprise_id: req.user.enterprise_id };

if (seasonFilter !== "") {
  var arr = seasonFilter.split(",");
  sectionWhere.season_id = arr.length === 1 ? arr[0] : { [models.Sequelize.Op.in]: arr };
}
if (cycleFilter !== "") {
  var arr = cycleFilter.split(",");
  sectionWhere.studying_cycle_id = arr.length === 1 ? arr[0] : { [models.Sequelize.Op.in]: arr };
}

var classroomInclude = {
  model: models.crs_assignation_classroom,
  attributes: ["name", "classroom_id"]
};
if (classroomFilter !== "") {
  classroomInclude.required = true;
  classroomInclude.where = { name: { [models.Sequelize.Op.like]: "%" + classroomFilter + "%" } };
}

// Consultar crs_score con sus secciones asociadas
models.crs_score.findAll({
  where: scoreWhere,
  attributes: ["score_id", "student_id", "section_id", "setup"],
  include: [
    {
      model: models.std_student,
      attributes: ["name", "status_code"],
      required: false
    },
    {
      model: models.crs_assignation_section,
      required: true,
      where: sectionWhere,
      attributes: ["section_id", "name", "course_id", "season_id", "branch_id", "studying_cycle_id", "classroom_id", "professor_id", "career_id"],
      include: [
        { 
          model: models.std_studying_cycle, 
          attributes: ["name", "studying_cycle_id"] 
        },
        { 
          model: models.crs_assignation_season, 
          attributes: ["name", "season_id"],
          include: [
            { model: models.std_period, attributes: ["name"], required: false }
          ]
        },
        { 
          model: models.std_branch, 
          attributes: ["name", "branch_id"] 
        },
        classroomInclude,
        {
          model: models.crs_course,
          attributes: ["name", "course_id", "professor_id", "setup"],
          required: false
        }
      ]
    }
  ]
}).then(function(scores) {
  var jsonScores = scores.map(function(r) { return r.toJSON(); });

  // Helper functions
  function hasNumericScore(value) {
    if (value === null || value === undefined || value === "") return false;
    if (typeof value === "string" && value.trim() === "") return false;
    if (isNaN(Number(value))) return false;
    return true;
  }

  function normalizeStageName(stage) {
    var clean = String(stage || "").trim().toLowerCase();
    if (clean === "fase 1") return "Fase 1";
    if (clean === "fase 2") return "Fase 2";
    if (clean === "fase final") return "Fase Final";
    if (/^recuperaci[oó]n\s*1$/.test(clean) || clean === "recuperacion1") return "Recuperacion1";
    if (/^recuperaci[oó]n\s*2$/.test(clean) || clean === "recuperacion2") return "Recuperacion2";
    if (/^seminario$/i.test(clean)) return "Seminario";
    if (/^plan pr[aá]ctico$/i.test(clean)) return "Plan Práctico";
    if (/^desarrollo$/i.test(clean)) return "Desarrollo";
    if (/^informe final$/i.test(clean)) return "Informe Final";
    if (/^consolidado$/i.test(clean)) return "Consolidado";
    return stage || "";
  }

  function getBlocksByStage(setupArray, stageName) {
    if (!setupArray || !Array.isArray(setupArray)) return [];
    var normalized = normalizeStageName(stageName);
    return setupArray.filter(function(item) {
      return normalizeStageName(item && item.stage) === normalized;
    });
  }

  function isValidNoteInPhase(setupArray, phaseName) {
    if (!setupArray || !Array.isArray(setupArray)) return false;

    var normalizedPhase = normalizeStageName(phaseName);
    var stageBlocks = getBlocksByStage(setupArray, normalizedPhase);

    if (!stageBlocks.length) return false;

    // Recuperaciones: necesitan un solo score numérico
    if (normalizedPhase === "Recuperacion1" || normalizedPhase === "Recuperacion2") {
      return stageBlocks.some(function(block) {
        return hasNumericScore(block && block.score);
      });
    }

    // Fases regulares: buscan Zona, Examen, NSP, SDE
    var zona = stageBlocks.find(function(b) { return b && b.name === "Zona"; });
    var examen = stageBlocks.find(function(b) { return b && b.name === "Examen"; });
    var nsp = stageBlocks.find(function(b) { return b && b.name === "NSP"; });
    var sde = stageBlocks.find(function(b) { return b && b.name === "SDE"; });

    var hasZone = !!(zona && hasNumericScore(zona.score));
    var hasExam = !!(examen && hasNumericScore(examen.score));
    var hasNSP = !!(nsp && nsp.nsp === true);
    var hasSDE = !!(sde && sde.sde === true);

    // Reglas de validación
    if (normalizedPhase === "Fase 1" || normalizedPhase === "Fase 2") {
      return hasZone && (hasExam || hasNSP);
    }

    if (normalizedPhase === "Fase Final") {
      if (hasSDE) return true;
      return hasZone && (hasExam || hasNSP);
    }

    // Cursos prácticos: necesitan un score válido
    if (normalizedPhase === "Seminario" || normalizedPhase === "Plan Práctico" || 
        normalizedPhase === "Desarrollo" || normalizedPhase === "Informe Final" || 
        normalizedPhase === "Consolidado") {
      return stageBlocks.some(function(block) {
        return hasNumericScore(block && block.score);
      });
    }

    return false;
  }

  // Agrupar scores por section_id + phase (extraída del JSON setup)
  var groupMap = {};
  var phasesPerSection = {};

  jsonScores.forEach(function(scoreRecord) {
    if (!scoreRecord.crs_assignation_section || !scoreRecord.setup) return;

    var setupArray = [];
    try {
      setupArray = typeof scoreRecord.setup === "string" ? JSON.parse(scoreRecord.setup) : scoreRecord.setup;
    } catch(e) {
      setupArray = [];
    }

    if (!Array.isArray(setupArray)) return;

    // Extraer todas las fases presentes en este score
    var phasesInThisScore = new Set();
    setupArray.forEach(function(item) {
      if (item && item.stage) {
        var normalized = normalizeStageName(item.stage);
        if (normalized) phasesInThisScore.add(normalized);
      }
    });

    // Para cada fase, crear un grupo section_id + phase
    phasesInThisScore.forEach(function(phase) {
      var groupKey = scoreRecord.section_id + "-" + phase;

      if (!groupMap[groupKey]) {
        groupMap[groupKey] = {
          students: [],
          section_id: scoreRecord.section_id,
          phase: phase,
          section: scoreRecord.crs_assignation_section
        };
      }

      groupMap[groupKey].students.push({
        student_id: scoreRecord.student_id,
        student: scoreRecord.std_student,
        setup: setupArray
      });

      // Track phases per section
      var sectionKey = scoreRecord.section_id;
      if (!phasesPerSection[sectionKey]) {
        phasesPerSection[sectionKey] = new Set();
      }
      phasesPerSection[sectionKey].add(phase);
    });
  });

  var rows = [];

  Object.keys(groupMap).forEach(function(groupKey) {
    var group = groupMap[groupKey];
    var section = group.section;
    var phase = group.phase;

    if (!section) return;

    // Contar estudiantes válidos y totales
    var totalAlumnos = group.students.length;
    var totalAlumnosValidos = 0;

    group.students.forEach(function(studentData) {
      if (isValidNoteInPhase(studentData.setup, phase)) {
        totalAlumnosValidos++;
      }
    });

    var hayValidNote = totalAlumnosValidos > 0;
    var se_paga = hayValidNote ? "Sí" : "No";

    // Extraer información de la sección
    var sede = section.std_branch ? section.std_branch.name : "N/A";
    var sede_branch_id = section.branch_id;
    var carrera = section.career_id ? "N/A" : "N/A";  // TODO: obtener de std_career si está disponible
    var ciclo = section.std_studying_cycle ? section.std_studying_cycle.name : "N/A";
    var periodo = (section.crs_assignation_season && section.crs_assignation_season.name) 
      ? section.crs_assignation_season.name : "N/A";
    var curso = section.crs_course ? section.crs_course.name : "N/A";
    var seccion = section.name || "N/A";
    var aula = (section.crs_assignation_classroom && section.crs_assignation_classroom.name) 
      ? section.crs_assignation_classroom.name : seccion;

    // Docente info
    var docente = "N/A";
    var nit = "";
    if (section.crs_course && section.crs_course.professor_id) {
      // TODO: si tienes profesor disponible, extraerlo aquí
      docente = section.crs_course.professor_id || "N/A";
    }

    var jornada = "N/A";  // TODO: obtener de studying_time si está disponible

    rows.push({
      sede: sede,
      sede_branch_id: sede_branch_id,
      carrera: carrera,
      ciclo: ciclo,
      jornada: jornada,
      curso: curso,
      fase: phase,
      seccion: seccion,
      aula: aula,
      periodo: periodo,
      docente: docente,
      nit: nit,
      fecha_fmt: "N/A",  // TODO: obtener de crs_score si existe fecha
      se_paga: se_paga,
      cant_actas: 1,
      cant_alumnos: totalAlumnosValidos,
      cant_alumnos_total: totalAlumnos
    });
  });

  // Filtros post-processing
  if (statusFilter === "nsp" || statusFilter === "con_nota") {
    rows = rows.filter(function(row) { return row.cant_alumnos > 0; });
  }

  if (branchFilter !== "") {
    var branchArr = branchFilter.split(",");
    rows = rows.filter(function(row) {
      return branchArr.indexOf(String(row.sede_branch_id)) !== -1;
    });
  }

  resolve(rows);
}).catch(function(err) {
  console.error("Error en actas-generadas:", err);
  reject(err);
});
