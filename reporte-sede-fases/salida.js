{
    data: function() {
        return {
            result: [],
            loading: true,
        }
    },
    watch: {
        result: function(newVal) {
            this.buildTable(newVal);
        }
    },
    methods: {
        buildTable: function(dataArray) {
            let vm = this;

            function renderEmptyTable() {
                if (window.jQuery.fn.DataTable.isDataTable(vm.$refs.notes_table)) {
                    window.jQuery(vm.$refs.notes_table).DataTable().destroy();
                }

                window.jQuery(vm.$refs.notes_table).empty();
                window.jQuery(vm.$refs.notes_table).append(
                    '<thead class="ui inverted grey table">' +
                    '<tr>' +
                    '<th class="text-center" style="text-align:center !important; vertical-align:middle !important;">SEDE</th>' +
                    '<th class="text-center" style="text-align:center !important; vertical-align:middle !important;">PERIODO</th>' +
                    '</tr>' +
                    '</thead><tbody></tbody>'
                );

                window.jQuery(vm.$refs.notes_table).DataTable({
                    data: [],
                    columns: [
                        { data: "Sede", defaultContent: "" },
                        { data: "Periodo", defaultContent: "" }
                    ],
                    columnDefs: [{ targets: "_all", className: "text-center" }],
                    language: {
                        url: "//cdn.datatables.net/plug-ins/1.10.21/i18n/Spanish.json"
                    },
                    paging: true,
                    searching: true,
                    ordering: true,
                    dom: "Bfrtip",
                    buttons: ["copy", "csv", "excel", "pdf", "print"]
                });
            }

            if (!dataArray || !Array.isArray(dataArray) || dataArray.length === 0) {
                renderEmptyTable();
                vm.loading = false;
                return;
            }

            const REGULAR_STAGE_ORDER = ["Fase 1", "Extraordinaria 1", "Fase 2", "Extraordinaria 2", "Fase Final", "Recuperacion1", "Recuperacion2"];
            const PRACTICAL_STAGES = new Set(["Seminario", "Plan Práctico", "Desarrollo", "Informe Final", "Consolidado"]);
            const META_COLUMNS = ["Sede", "Periodo"];

            function normalizeStageName(stage) {
                if (!stage || typeof stage !== "string") return "";
                const clean = stage.trim();
                if (/^fase\s*1$/i.test(clean)) return "Fase 1";
                if (/^fase\s*2$/i.test(clean)) return "Fase 2";
                if (/^fase\s*final$/i.test(clean)) return "Fase Final";
                if (/^plan practico$/i.test(clean) || /^plan pr[aá]ctico$/i.test(clean)) return "Plan Práctico";
                if (/^recuperaci[oó]n\s*1$/i.test(clean)) return "Recuperacion1";
                if (/^recuperaci[oó]n\s*2$/i.test(clean)) return "Recuperacion2";
                return clean;
            }

            function hasNumericScore(value) {
                if (value === null || value === undefined) return false;
                const str = String(value).trim();
                if (str === "") return false;
                return !Number.isNaN(Number(str));
            }

            function hasAnyScore(value) {
                return value !== null && value !== undefined && String(value).trim() !== "";
            }

            function parseScoreSetup(setup) {
                if (!setup) return [];
                try {
                    const parsed = typeof setup === "string" ? JSON.parse(setup) : setup;
                    return Array.isArray(parsed) ? parsed : [];
                } catch (error) {
                    return [];
                }
            }

            function isPracticalCourse(row, blocksByStage) {
                if (row.course_type === "practical") return true;
                if (row.course_type === "regular") return false;
                return Array.from(blocksByStage.keys()).some(stage => PRACTICAL_STAGES.has(stage));
            }

            function regularStageInfo(blocksByStage, stageName, isPractical, isDropout, dropoutLabel) {
                if (isPractical) {
                    return { tiene: "NA", nota: "", examen: "" };
                }
                if (isDropout) {
                    return { tiene: "Si", nota: dropoutLabel, examen: dropoutLabel };
                }

                const stageBlocks = blocksByStage.get(stageName) || [];
                const zone = stageBlocks.find(x => x.name === "Zona");
                const exam = stageBlocks.find(x => x.name === "Examen");
                const nsp = stageBlocks.find(x => x.name === "NSP");
                const sde = stageBlocks.find(x => x.name === "SDE");

                const hasZone = !!(zone && hasNumericScore(zone.score));
                const hasExam = !!(exam && hasNumericScore(exam.score));
                const hasNSP = !!(nsp && nsp.nsp === true);
                const hasSDE = !!(sde && sde.sde === true);

                const zoneValue = hasZone ? zone.score : "";
                const examValue = hasExam ? exam.score : (hasNSP ? "NSP" : (hasSDE ? "SDE" : ""));

                if (stageName === "Fase Final" && hasSDE) {
                    return { tiene: "Si", nota: zoneValue, examen: "SDE" };
                }

                if (hasZone && hasNSP) {
                    return { tiene: "Si", nota: zoneValue, examen: "NSP" };
                }

                if (hasZone && hasExam) {
                    return { tiene: "Si", nota: zoneValue, examen: examValue };
                }

                return { tiene: "No", nota: zoneValue, examen: examValue };
            }

            function singleStageInfo(blocksByStage, stageName, isPractical, appliesToPractical, isDropout, dropoutLabel) {
                const applies = appliesToPractical ? isPractical : !isPractical;
                if (!applies) return { tiene: "NA", nota: "" };
                if (isDropout) return { tiene: "Si", nota: dropoutLabel };

                const stageBlocks = blocksByStage.get(stageName) || [];
                const firstValue = stageBlocks.find(x => hasAnyScore(x && x.score));

                if (firstValue) {
                    return { tiene: "Si", nota: firstValue.score };
                }

                return { tiene: "No", nota: "" };
            }

            // La extraordinaria no existe como stage propio en crs_score.setup:
            // aplica cuando la fase base (Fase 1 / Fase 2) tiene NSP=true, y se
            // considera ingresada si el Examen de la fase base fue sobrescrito con
            // nota o si el item NSP trae extransp=true (cerrada sin nota).
            function extraordinaryStageInfo(blocksByStage, baseStageName, isPractical, isDropout) {
                if (isPractical) return { tiene: "NA", nota: "" };
                if (isDropout) return { tiene: "NA", nota: "" };

                const stageBlocks = blocksByStage.get(baseStageName) || [];
                const nsp = stageBlocks.find(x => x.name === "NSP");
                const exam = stageBlocks.find(x => x.name === "Examen");

                const hasNSP = !!(nsp && nsp.nsp === true);
                if (!hasNSP) return { tiene: "NA", nota: "" };

                const hasExam = !!(exam && hasNumericScore(exam.score));
                const hasExtransp = !!(nsp && (nsp.extransp === true || nsp.extransp === "true"));

                if (hasExam) return { tiene: "Si", nota: exam.score };
                if (hasExtransp) return { tiene: "Si", nota: "EXTRANSP" };

                return { tiene: "No", nota: "" };
            }

            function sumZonaExamen(blocksByStage, stageName) {
                const blocks = blocksByStage.get(stageName) || [];
                let total = 0;
                blocks.forEach(x => {
                    if (x && (x.name === "Zona" || x.name === "Examen") && hasNumericScore(x.score)) {
                        total += Number(x.score);
                    }
                });
                return total;
            }

            // El stage de recuperación solo se crea en crs_score.setup cuando el
            // catedrático ingresa un valor. Para los pendientes (sin stage aún) la
            // asignación se calcula con la regla del 61: va a Recuperacion1 si con
            // Fase Final resuelta la suma Zona+Examen de las 3 fases no llega a 61
            // (un NSP solo aporta 0 a la suma; si aun así llega a 61, ganó y no va).
            // Va a Recuperacion2 si Recuperacion1 quedó en NSP o su nota (sustituye
            // al bloque de Fase Final, sobre 40) sigue sin llegar a 61.
            function recoveryStageInfo(blocksByStage, stageName, isPractical, isDropout) {
                if (isPractical) return { tiene: "NA", nota: "" };

                const stageBlocks = blocksByStage.get(stageName) || [];

                // El stage ya existe en el setup: el alumno está asignado
                if (stageBlocks.length > 0) {
                    const firstValue = stageBlocks.find(x => hasAnyScore(x && x.score));
                    if (firstValue) {
                        return { tiene: "Si", nota: firstValue.score };
                    }

                    // En recuperaciones el flag nsp viene en el propio item
                    // (name = "Recuperacion1/2"), no en un item aparte name="NSP"
                    const hasNSP = stageBlocks.some(x => x && x.nsp === true);
                    if (hasNSP) {
                        return { tiene: "Si", nota: "NSP" };
                    }

                    if (isDropout) return { tiene: "NA", nota: "" };
                    return { tiene: "No", nota: "" };
                }

                // El stage aún no existe: determinar si el alumno debería estar
                // asignado (pendiente sin ningún valor ingresado)
                if (isDropout) return { tiene: "NA", nota: "" };

                const ffBlocks = blocksByStage.get("Fase Final") || [];
                const ffNSP = ffBlocks.some(x => x && x.name === "NSP" && x.nsp === true);
                const ffSDE = ffBlocks.some(x => x && x.name === "SDE" && x.sde === true);
                const ffExam = ffBlocks.find(x => x && x.name === "Examen");
                const ffClosed = ffBlocks.some(x => x && x.name === "is_closed" && x.is_closed === true);
                const ffResolved = ffClosed || ffNSP || ffSDE || !!(ffExam && hasNumericScore(ffExam.score));

                // Sin Fase Final resuelta no se sabe si irá a recuperación;
                // con SDE no tiene derecho a recuperación
                if (!ffResolved || ffSDE) return { tiene: "NA", nota: "" };

                const baseTotal = sumZonaExamen(blocksByStage, "Fase 1")
                    + sumZonaExamen(blocksByStage, "Fase 2")
                    + sumZonaExamen(blocksByStage, "Fase Final");
                const needsRecovery1 = baseTotal < 61;

                if (stageName === "Recuperacion1") {
                    return needsRecovery1 ? { tiene: "No", nota: "" } : { tiene: "NA", nota: "" };
                }

                // Recuperacion2: solo se sabe cuando Recuperacion1 ya tiene resultado
                if (!needsRecovery1) return { tiene: "NA", nota: "" };

                const r1Blocks = blocksByStage.get("Recuperacion1") || [];
                const r1Numeric = r1Blocks.find(x => x && hasNumericScore(x.score));
                const r1NSP = r1Blocks.some(x => x && x.nsp === true);

                if (r1NSP && !r1Numeric) return { tiene: "No", nota: "" };
                if (r1Numeric) {
                    // La nota de recuperación sustituye el bloque completo de Fase Final
                    const totalConR1 = sumZonaExamen(blocksByStage, "Fase 1")
                        + sumZonaExamen(blocksByStage, "Fase 2")
                        + Number(r1Numeric.score);
                    return totalConR1 < 61 ? { tiene: "No", nota: "" } : { tiene: "NA", nota: "" };
                }

                // Recuperacion1 sigue pendiente: aún no se sabe si necesitará la 2
                return { tiene: "NA", nota: "" };
            }

            function orderByPreference(keys, preferenceOrder) {
                const preferenceIndex = new Map(preferenceOrder.map((key, index) => [key, index]));
                return [...keys].sort((left, right) => {
                    const leftIndex = preferenceIndex.has(left) ? preferenceIndex.get(left) : Number.POSITIVE_INFINITY;
                    const rightIndex = preferenceIndex.has(right) ? preferenceIndex.get(right) : Number.POSITIVE_INFINITY;

                    if (leftIndex !== rightIndex) return leftIndex - rightIndex;
                    return left.localeCompare(right, "es");
                });
            }

            const rowsWithTotals = dataArray.map(row => {
                const scores = parseScoreSetup(row.score);
                const blocksByStage = new Map();
                scores.forEach(item => {
                    const stageName = normalizeStageName(item && item.stage);
                    if (!stageName) return;
                    if (!blocksByStage.has(stageName)) {
                        blocksByStage.set(stageName, []);
                    }
                    blocksByStage.get(stageName).push(item);
                });

                const isPractical = isPracticalCourse(row, blocksByStage);
                const isDropout = row.student_status_code === "B" || row.student_status_code === "D";
                const dropoutLabel = row.student_status_code === "B" ? "BAJA" : row.student_status_code === "D" ? "DESHABILITADO" : "";

                const stageInfo = {
                    "Fase 1": regularStageInfo(blocksByStage, "Fase 1", isPractical, isDropout, dropoutLabel),
                    "Extraordinaria 1": extraordinaryStageInfo(blocksByStage, "Fase 1", isPractical, isDropout),
                    "Fase 2": regularStageInfo(blocksByStage, "Fase 2", isPractical, isDropout, dropoutLabel),
                    "Extraordinaria 2": extraordinaryStageInfo(blocksByStage, "Fase 2", isPractical, isDropout),
                    "Fase Final": regularStageInfo(blocksByStage, "Fase Final", isPractical, isDropout, dropoutLabel),
                    "Recuperacion1": recoveryStageInfo(blocksByStage, "Recuperacion1", isPractical, isDropout),
                    "Recuperacion2": recoveryStageInfo(blocksByStage, "Recuperacion2", isPractical, isDropout),
                    "Seminario": singleStageInfo(blocksByStage, "Seminario", isPractical, true, isDropout, dropoutLabel),
                    "Plan Práctico": singleStageInfo(blocksByStage, "Plan Práctico", isPractical, true, isDropout, dropoutLabel),
                    "Desarrollo": singleStageInfo(blocksByStage, "Desarrollo", isPractical, true, isDropout, dropoutLabel),
                    "Informe Final": singleStageInfo(blocksByStage, "Informe Final", isPractical, true, isDropout, dropoutLabel),
                    "Consolidado": singleStageInfo(blocksByStage, "Consolidado", isPractical, true, isDropout, dropoutLabel)
                };

                return Object.assign({}, row, {
                    course_type_label: isPractical ? "Práctico" : "Regular",
                    stage_info: stageInfo
                });
            });

            const grouped = new Map();
            rowsWithTotals.forEach(row => {
                const groupKey = (row.branch || "No definida") + "||" + (row.period || "Sin periodo");
                if (!grouped.has(groupKey)) {
                    grouped.set(groupKey, {
                        Sede: row.branch || "No definida",
                        Periodo: row.period || "Sin periodo",
                        fases_esperadas: {},
                        fases_ingresadas: {}
                    });
                }

                const bucket = grouped.get(groupKey);
                const stageInfo = row.stage_info || {};
                const stages = Object.keys(stageInfo);

                stages.forEach(stageName => {
                    const info = stageInfo[stageName];
                    if (!info) return;

                    const isPracticalStage = PRACTICAL_STAGES.has(stageName);
                    const expectedKey = stageName;

                    // skip stages that don't apply to this course type
                    if (row.course_type_label === "Práctico" && !isPracticalStage) return;
                    if (row.course_type_label === "Regular" && isPracticalStage) return;

                    // Do not count stages marked as NA (e.g., recovery not assigned)
                    if (info.tiene === "NA") return;

                    if (!bucket.fases_esperadas[expectedKey]) bucket.fases_esperadas[expectedKey] = 0;
                    if (!bucket.fases_ingresadas[expectedKey]) bucket.fases_ingresadas[expectedKey] = 0;

                    bucket.fases_esperadas[expectedKey] += 1;
                    if (info.tiene === "Si") {
                        bucket.fases_ingresadas[expectedKey] += 1;
                    }
                });
            });

            const finalRows = Array.from(grouped.values()).map(group => {
                const row = {
                    Sede: group.Sede,
                    Periodo: group.Periodo
                };

                const stages = Object.keys(group.fases_esperadas);
                const regularStages = orderByPreference(stages.filter(stage => !PRACTICAL_STAGES.has(stage)), REGULAR_STAGE_ORDER);
                const practicalStages = orderByPreference(stages.filter(stage => PRACTICAL_STAGES.has(stage)), Array.from(PRACTICAL_STAGES));

                [...regularStages, ...practicalStages].forEach(stage => {
                    const esperados = group.fases_esperadas[stage] || 0;
                    const ingresados = group.fases_ingresadas[stage] || 0;
                    // Truncar (no redondear) para que 100.00% solo aparezca cuando esten todas las notas
                    const porcentaje = esperados > 0 ? Math.floor((ingresados / esperados) * 10000) / 100 : 0;
                    row[stage] = porcentaje.toFixed(2) + "% <br><small>(hay " + ingresados + " de " + esperados + ")</small>";
                });

                return row;
            });

            if (finalRows.length === 0) {
                renderEmptyTable();
                vm.loading = false;
                return;
            }

            const allKeys = new Set();
            finalRows.forEach(row => Object.keys(row).forEach(key => allKeys.add(key)));
            const metaKeys = META_COLUMNS.filter(key => allKeys.has(key));
            const stageKeys = Array.from(allKeys).filter(key => !META_COLUMNS.includes(key));
            const regularStageKeys = orderByPreference(stageKeys.filter(key => !PRACTICAL_STAGES.has(key)), REGULAR_STAGE_ORDER);
            const practicalStageKeys = orderByPreference(stageKeys.filter(key => PRACTICAL_STAGES.has(key)), Array.from(PRACTICAL_STAGES));
            const orderedKeys = [...metaKeys, ...regularStageKeys, ...practicalStageKeys];

            const tableColumns = orderedKeys.map(key => ({
                data: key,
                defaultContent: META_COLUMNS.includes(key) ? "" : "0.00%"
            }));

            if (window.jQuery.fn.DataTable.isDataTable(vm.$refs.notes_table)) {
                window.jQuery(vm.$refs.notes_table).DataTable().destroy();
            }
            window.jQuery(vm.$refs.notes_table).empty();

            let headerHtml = "<thead class=\"ui inverted grey table\">";
            headerHtml += "<tr>";
            metaKeys.forEach(key => {
                headerHtml += `<th rowspan="2" class="text-center" style="text-align:center !important; vertical-align:middle !important;">${key.toUpperCase()}</th>`;
            });
            if (regularStageKeys.length > 0) {
                headerHtml += `<th colspan="${regularStageKeys.length}" class="text-center" style="text-align:center !important; vertical-align:middle !important;">CURSOS REGULARES</th>`;
            }
            if (practicalStageKeys.length > 0) {
                headerHtml += `<th colspan="${practicalStageKeys.length}" class="text-center" style="text-align:center !important; vertical-align:middle !important;">CURSOS PRÁCTICOS</th>`;
            }
            headerHtml += "</tr><tr>";
            regularStageKeys.forEach(key => {
                headerHtml += `<th class="text-center" style="text-align:center !important; vertical-align:middle !important;">${key.toUpperCase()}</th>`;
            });
            practicalStageKeys.forEach(key => {
                headerHtml += `<th class="text-center" style="text-align:center !important; vertical-align:middle !important;">${key.toUpperCase()}</th>`;
            });
            headerHtml += "</tr></thead>";

            window.jQuery(vm.$refs.notes_table).append(headerHtml);

            window.jQuery(vm.$refs.notes_table).DataTable({
                data: finalRows,
                columns: tableColumns,
                columnDefs: [{ targets: "_all", className: "text-center" }],
                orderCellsTop: true,
                headerCallback: function(thead) {
                    window.jQuery(thead).find("th").css({
                        "text-align": "center",
                        "vertical-align": "middle"
                    });
                },
                language: {
                    url: "//cdn.datatables.net/plug-ins/1.10.21/i18n/Spanish.json"
                },
                paging: true,
                searching: true,
                ordering: true,
                dom: "Bfrtip",
                buttons: ["copy", "csv", "excel", "pdf", "print"]
            });

            vm.loading = false;
        }
    },
    mounted: function() {
        window.jQuery(".ui.tabular.menu .item").tab();

        // Build table on mount even for empty results to avoid infinite loader.
        if (Array.isArray(this.result)) {
            this.buildTable(this.result);
            return;
        }

        this.buildTable([]);
    }
}