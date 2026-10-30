{
    data: function() {
        return {
            result: [],
            loading: true,
            api_url: "https://api_modul.uregional.net",
            table: null,
            questionColumns: []
        }
    },
    methods: {
        buildProfessorCourseSummaryOld(raw) {


            // raw = array de objetos tal como viene del backend
            const byProfCourse = {};
            const questionMeta = {}; // question_uuid -> { uuid, title, section_index, order }

            raw.forEach(row => {
                // Parsear setup del profesor (para nombre)



                let profName = '';
                try {
                    if (row.pfs_professor && row.pfs_professor.setup) {
                        const setup = JSON.parse(row.pfs_professor.setup);
                        profName = `${setup.name || ''} ${setup.lastname || ''}`.trim();
                    }
                } catch (e) {
                    console.error('Error parseando setup de profesor', e);
                }
                if (!profName && row.pfs_professor) {
                    profName = `${row.pfs_professor.name}`;
                }

                // Periodo
                const periodName = row.std_period && row.std_period.name ?
                    row.std_period.name :
                    '';

                // Nombre del curso
                const courseId = row.course_id;
                const courseName = row.crs_course && row.crs_course.name ?
                    row.crs_course.name :
                    `${courseName}`;

                // Parsear answers
                let answers = [];
                try {
                    if (row.answers) {
                        const parsed = JSON.parse(row.answers);
                        answers = parsed.answers || [];
                    }
                } catch (e) {
                    console.error('Error parseando answers', e);
                }

                // Filtrar solo preguntas tipo likert con value_int numérico
                const likertAnswers = answers.filter(a =>
                    a.type === 'likert' &&
                    typeof a.value_int === 'number'
                );

                if (!likertAnswers.length) return; // nada que promediar

                // Clave = periodo + profesor + curso
                const key = `${periodName}-${row.professor_id}-${courseId}`;

                if (!byProfCourse[key]) {
                    byProfCourse[key] = {
                        period: periodName,
                        professor_name: profName,
                        course_name: courseName,
                        totalScore: 0,
                        answerCount: 0,
                        evaluationCount: 0,
                        questions: {} // question_uuid -> { sum, count }
                    };
                }

                const group = byProfCourse[key];

                // Acumular por cada respuesta likert
                likertAnswers.forEach(a => {
                    const qid = a.question_uuid;

                    // Metadata global de la pregunta
                    if (!questionMeta[qid]) {
                        questionMeta[qid] = {
                            uuid: qid,
                            title: a.title || qid,
                            section_index: typeof a.section_index === 'number' ? a.section_index : 0,
                            order: typeof a.order === 'number' ? a.order : 0
                        };
                    }

                    if (!group.questions[qid]) {
                        group.questions[qid] = {
                            sum: 0,
                            count: 0
                        };
                    }

                    group.questions[qid].sum += a.value_int;
                    group.questions[qid].count += 1;

                    // Totales globales del grupo (para promedio general)
                    group.totalScore += a.value_int;
                    group.answerCount += 1;
                });

                // Cada row = una evaluación (un estudiante) => contar cantidad de evaluaciones
                group.evaluationCount += 1;
            });

            // Ordenar preguntas por sección y orden
            const questions = Object.values(questionMeta).sort((a, b) => {
                if (a.section_index !== b.section_index) {
                    return a.section_index - b.section_index;
                }
                if (a.order !== b.order) {
                    return a.order - b.order;
                }
                return a.title.localeCompare(b.title);
            });

            // Construir filas finales
            const rows = Object.values(byProfCourse).map(group => {
                const avgGeneral = group.answerCount ?
                    (group.totalScore / group.answerCount) :
                    null;

                const rowOut = {
                    period: group.period,
                    professor_name: group.professor_name,
                    course_name: group.course_name,
                    evaluationCount: group.evaluationCount,
                    averageScore: avgGeneral !== null ? avgGeneral.toFixed(2) : ''
                };

                // Para cada pregunta, crear columna q_<uuid> con su promedio
                questions.forEach(q => {
                    const stat = group.questions[q.uuid];
                    let qAvg = '';
                    if (stat && stat.count) {
                        qAvg = (stat.sum / stat.count).toFixed(2);
                    }
                    rowOut['q_' + q.uuid] = qAvg;
                });

                return rowOut;
            });

            return {
                rows,
                questions
            };
        },

        buildProfessorCourseSummary(raw) {

            // raw = array de objetos tal como viene del backend
            const byProfCourse = {};
            const questionMeta = {}; // question_uuid -> { uuid, title, section_index, order }

            raw.forEach(row => {
                // Determinar si es coordinator o no
                const isCoordinator = row.tType === 'student_coordinator' || row.tType === 'self_coordinator';

                let evaluatorName = '';
                let evaluatorId = '';

                if (isCoordinator) {
                    // Para coordinator: usar usr_user
                    evaluatorId = row.usr_user?.user_id || '';
                    try {
                        if (row.usr_user && row.usr_user.setup) {
                            const setup = JSON.parse(row.usr_user.setup);
                            evaluatorName = `${setup.name || ''} ${setup.lastname || ''}`.trim();
                        }
                    } catch (e) {
                        console.error('Error parseando setup de usuario coordinador', e);
                    }
                    if (!evaluatorName && row.usr_user) {
                        evaluatorName = `${row.usr_user.name}`;
                    }
                } else {
                    // Comportamiento original: para profesor
                    evaluatorId = row.professor_id;
                    try {
                        if (row.pfs_professor && row.pfs_professor.setup) {
                            const setup = JSON.parse(row.pfs_professor.setup);
                            evaluatorName = `${setup.name || ''} ${setup.lastname || ''}`.trim();
                        }
                    } catch (e) {
                        console.error('Error parseando setup de profesor', e);
                    }
                    if (!evaluatorName && row.pfs_professor) {
                        evaluatorName = `${row.pfs_professor.name}`;
                    }
                }

                // Periodo
                const periodName = row.std_period && row.std_period.name ?
                    row.std_period.name :
                    '';

                // Nombre del curso
                const courseId = row.course_id;
                const courseName = row.crs_course && row.crs_course.name ?
                    row.crs_course.name :
                    ``;

                // Parsear answers
                let answers = [];
                try {
                    if (row.answers) {
                        const parsed = JSON.parse(row.answers);
                        answers = parsed.answers || [];
                    }
                } catch (e) {
                    console.error('Error parseando answers', e);
                }

                // Filtrar solo preguntas tipo likert con value_int numérico
                const likertAnswers = answers.filter(a =>
                    a.type === 'likert' &&
                    typeof a.value_int === 'number'
                );

                if (!likertAnswers.length) return; // nada que promediar

                // Clave = periodo + evaluador + curso
                const key = `${periodName}-${evaluatorId}-${courseId}`;

                if (!byProfCourse[key]) {
                    byProfCourse[key] = {
                        period: periodName,
                        evaluator_name: evaluatorName,
                        evaluator_id: evaluatorId,
                        evaluator_type: isCoordinator ? 'coordinador' : 'profesor',
                        course_name: courseName,
                        totalScore: 0,
                        answerCount: 0,
                        evaluationCount: 0,
                        questions: {} // question_uuid -> { sum, count }
                    };
                }

                const group = byProfCourse[key];

                // Acumular por cada respuesta likert
                likertAnswers.forEach(a => {
                    const qid = a.question_uuid;

                    // Metadata global de la pregunta
                    if (!questionMeta[qid]) {
                        questionMeta[qid] = {
                            uuid: qid,
                            title: a.title || qid,
                            section_index: typeof a.section_index === 'number' ? a.section_index : 0,
                            order: typeof a.order === 'number' ? a.order : 0
                        };
                    }

                    if (!group.questions[qid]) {
                        group.questions[qid] = {
                            sum: 0,
                            count: 0
                        };
                    }

                    group.questions[qid].sum += a.value_int;
                    group.questions[qid].count += 1;

                    // Totales globales del grupo (para promedio general)
                    group.totalScore += a.value_int;
                    group.answerCount += 1;
                });

                // Cada row = una evaluación (un estudiante) => contar cantidad de evaluaciones
                group.evaluationCount += 1;
            });

            // Ordenar preguntas por sección y orden
            const questions = Object.values(questionMeta).sort((a, b) => {
                if (a.section_index !== b.section_index) {
                    return a.section_index - b.section_index;
                }
                if (a.order !== b.order) {
                    return a.order - b.order;
                }
                return a.title.localeCompare(b.title);
            });

            // Construir filas finales
            const rows = Object.values(byProfCourse).map(group => {
                const avgGeneral = group.answerCount ?
                    (group.totalScore / group.answerCount) :
                    null;

                const rowOut = {
                    period: group.period,
                    evaluator_name: group.evaluator_name,
                    evaluator_type: group.evaluator_type,
                    course_name: group.course_name,
                    evaluationCount: group.evaluationCount,
                    averageScore: avgGeneral !== null ? avgGeneral.toFixed(2) : ''
                };

                // Para cada pregunta, crear columna q_<uuid> con su promedio
                questions.forEach(q => {
                    const stat = group.questions[q.uuid];
                    let qAvg = '';
                    if (stat && stat.count) {
                        qAvg = (stat.sum / stat.count).toFixed(2);
                    }
                    rowOut['q_' + q.uuid] = qAvg;
                });

                return rowOut;
            });

            return {
                rows,
                questions
            };
        },

        initDataTable() {
            const vm = this;
            const {
                rows,
                questions
            } = vm.buildProfessorCourseSummary(vm.result);
            vm.questionColumns = questions;

            // Columnas base
            const baseColumns = [{
                    data: 'period',
                    title: 'Periodo'
                },
                {
                    data: 'evaluator_name',
                    title: 'Nombre de Evaluado'
                },
                {
                    data:  'course_name',
                    title: 'Curso'
                },
                {
                    data: 'evaluationCount',
                    title: '# Evaluaciones'
                }
            ];

            // Columnas dinámicas por pregunta
            const questionColumns = vm.questionColumns.map((q, idx) => ({
                data: 'q_' + q.uuid,
                // Si el título es muy largo, podrías usar `P${idx+1}` y mostrar el título completo en tooltip
                title: q.title
            }));

            // Columna final de promedio general
            const finalColumns = baseColumns
                .concat(questionColumns)
                .concat([{
                    data: 'averageScore',
                    title: 'Promedio general'
                }]);

            const $table = window.jQuery(vm.$refs.table);

            // Asegurar que el thead tenga el número correcto de columnas
            const $theadRow = $table.find('thead tr');
            $theadRow.empty();
            finalColumns.forEach(col => {
                $theadRow.append(`<th>${col.title}</th>`);
            });

            if (vm.table) {
                // Si ya existe la tabla, solo recargamos datos
                vm.table.clear();
                vm.table.rows.add(rows).draw();
                return;
            }

            vm.table = $table.DataTable({
                pageLength: 50,
                autoWidth: true,
                ordering: true,
                scrollCollapse: true,
                data: rows,
                columns: finalColumns,
                language: {
                    url: "//cdn.datatables.net/plug-ins/1.10.21/i18n/Spanish.json"
                },
                dom: "lBfrtip",
                buttons: ['csv', 'excel', 'print']
            });

            vm.table.on("page.dt", function() {
                // por si quieres hacer algo en cambio de página
            });
        }
    },
    created: function() {},
    mounted: function() {
        let vm = this;
        if (vm.result) {
            console.log(vm.result);
            vm.loading = false;
            if (vm.result && vm.result.length) {
                vm.initDataTable();
            }
        }
    },
    watch: {
        // Por si cambias los filtros y recargas result desde afuera
        result(newVal) {
            if (newVal && newVal.length) {
                this.initDataTable();
            } else if (this.table) {
                this.table.clear().draw();
            }
        }
    }
}