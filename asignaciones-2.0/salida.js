 {
      data: function() {
          return {
              preinscriptions: [],
              result: [],
              classrooms: [],
              branchTotals: [],
              loading: true,
              selected_professor: {},
              branch: '',
              sections: [],
              selectedRow: null,
              api_url: "https://api_modul.uregional.net",
              professorConflictColors: {},
          }
      },
      methods: {
          countStudentsByBranch: function(data) {
              const branchCounts = {};
              const seenStudentIds = new Set();

              data.forEach(section => {
                  const branchName = section.std_branch.name;

                  section.crs_assignation_preinscriptions.forEach(preinscription => {
                      const studentId = preinscription.student_id;
                      const assignationStudents = preinscription.crs_assignation_students;
                      const hasAssignation = Array.isArray(assignationStudents)
                          ? assignationStudents.length > 0
                          : !!preinscription.crs_assignation_student;

                      if (hasAssignation && !seenStudentIds.has(studentId)) {
                          seenStudentIds.add(studentId);

                          if (branchCounts[branchName]) {
                              branchCounts[branchName] += 1;
                          } else {
                              branchCounts[branchName] = 1;
                          }
                      }
                  });
              });

              return branchCounts;
          },
          groupByBranch: function(preinscriptions) {
              const branchGroups = {};
              const seenStudentIds = new Set();

              preinscriptions.forEach(item => {
                  const branchName = item.std_branch.name;
                  const studentId = item.student_id;

                  if (!seenStudentIds.has(studentId)) {
                      seenStudentIds.add(studentId);
                      if (branchGroups[branchName]) {
                          branchGroups[branchName] += 1;
                      } else {
                          branchGroups[branchName] = 1;
                      }
                  }
              });

              const result = Object.keys(branchGroups).map(branch => {
                  return {
                      branch: branch,
                      totalStudents: branchGroups[branch]
                  };
              });

              return result;
          },
          handleRowClick: function(data) {
              let _v = this;
              let setup = JSON.parse(data.pfs_professor.setup);
              _v.selected_professor = setup;
              _v.selectedRow = data;
              _v.branch = data.std_branch.name;
              _v.$http.post(`${_v.api_url}/apis/uregional_report/get-professor-sections`, {
                  i: data.pfs_professor.professor_id,
                  b: data.std_branch.branch_id,
                  s: data.section_id
              }).then(rspnse => {
                  if (rspnse.status == 200) {
                      let rsp = rspnse.data;
                      if (!rsp.success) console.error(rsp.error);
                      else {
                          let data = rsp.data;
                          _v.sections = data;
                          setTimeout(function() {
                              window.jQuery(_v.$refs.detail_modal).modal("show");
                              window.jQuery(_v.$refs.tabss).find(".item").tab();

                              _v.sections.forEach((section, idx) => {
                                  let tableRef = `students_table_${idx}`;
                                  if (window.jQuery.fn.DataTable.isDataTable(_v.$refs[tableRef])) {
                                      window.jQuery(_v.$refs[tableRef]).DataTable().destroy();
                                  }
                                  window.jQuery(_v.$refs[tableRef]).DataTable({
                                      data: section.crs_assignation_preinscriptions.map(itm => ({
                                          branch: _v.branch,
                                          career: itm.std_career.name,
                                          student_id_card: itm.std_student.student_id_card,
                                          student_name: itm.std_student.name
                                      })),
                                      pageLength: 50,
                                      autoWidth: true,
                                      ordering: true,
                                      scrollCollapse: true,
                                      language: {
                                          url: "//cdn.datatables.net/plug-ins/1.10.21/i18n/Spanish.json"
                                      },
                                      dom: "lBfrtip",
                                      buttons: [{
                                          extend: 'csv',
                                          text: 'CSV',
                                          action: function(e, dt, button, config) {
                                              _v.exportCurrentStudentsTableToExcel(idx);
                                          }
                                      }, {
                                          extend: 'excel',
                                          text: 'Excel',
                                          action: function(e, dt, button, config) {
                                              _v.exportCurrentStudentsTableToExcel(idx);
                                          }
                                      }, 'print'],
                                      columns: [{
                                          title: "Sede",
                                          data: "branch"
                                      }, {
                                          title: "Carrera",
                                          data: "career"
                                      }, {
                                          title: "Carné",
                                          data: "student_id_card"
                                      }, {
                                          title: "Nombre",
                                          data: "student_name"
                                      }]
                                  });
                              });
                          }, 200);
                      }
                  } else {
                      console.error(rspnse);
                  }
              }).catch(err => {
                  console.error(err);
              });
          },
          exportCurrentStudentsTableToExcel: function(tableIndex) {
              let tableRef = this.$refs[`students_table_${tableIndex}`];
              let table = window.jQuery(tableRef).DataTable();

              let headers = table.columns().header().toArray().map(header => header.innerText);
              let data = table.rows({
                  search: 'applied'
              }).data().toArray();

              let ws_data = [];
              ws_data.push(headers);
              ws_data = ws_data.concat(data.map(row => [row.branch, row.career, row.student_id_card, row.student_name]));

              let wb = XLSX.utils.book_new();
              let ws = XLSX.utils.aoa_to_sheet(ws_data);
              XLSX.utils.book_append_sheet(wb, ws, `Estudiantes Seccion ${tableIndex + 1}`);
              XLSX.writeFile(wb, `estudiantes_seccion_${tableIndex + 1}.xlsx`);
          },
          countAssignedStudents: function(row) {
              let count = 0;
              if (row.crs_assignation_preinscriptions && Array.isArray(row.crs_assignation_preinscriptions)) {
                  row.crs_assignation_preinscriptions.forEach(pre => {
                      if (Array.isArray(pre.crs_assignation_students)) {
                          count += pre.crs_assignation_students.length;
                      } else if (pre.crs_assignation_student) {
                          count += 1;
                      }
                  });
              }
              return count;
          },
          generateRandomPastelColor: function() {
              const r = Math.floor(Math.random() * 100) + 155;
              const g = Math.floor(Math.random() * 100) + 155;
              const b = Math.floor(Math.random() * 100) + 155;

              const toHex = (c) => {
                  const hex = c.toString(16);
                  return hex.length === 1 ? "0" + hex : hex;
              };

              return `#${toHex(r)}${toHex(g)}${toHex(b)}`;
          },
          assignConflictColors: function(data) {
              const professorSchedules = {};
              const conflictedProfessors = new Set();

              data.forEach(row => {
                  let professorCode = row.pfs_professor ? JSON.parse(row.pfs_professor.setup).professor_code : '';
                  let setup = JSON.parse(row.setup);
                  let dayIndex = setup.day_index;
                  let schedule = setup.schedule;
                  let classroomName = row.crs_assignation_classroom ? row.crs_assignation_classroom.name : null;

                  if (professorCode && dayIndex !== undefined && schedule) {

                      const currentSchedule = {
                          day_index: dayIndex,
                          schedule: schedule,
                          section_id: row.section_id,
                          name: classroomName
                      };

                      if (!professorSchedules[professorCode]) {
                          professorSchedules[professorCode] = [];
                      }

                      professorSchedules[professorCode].forEach(existingSchedule => {
                          const sameDay = currentSchedule.day_index === existingSchedule.day_index;
                          const sameTime = currentSchedule.schedule === existingSchedule.schedule;
                          const differentSection = currentSchedule.section_id !== existingSchedule.section_id;
                          const sameClassroom = currentSchedule.name === existingSchedule.name;

                          if (sameDay && sameTime && differentSection && !sameClassroom) {
                              conflictedProfessors.add(professorCode);
                          }
                      });

                      professorSchedules[professorCode].push(currentSchedule);
                  }
              });

              conflictedProfessors.forEach(professorCode => {
                  if (!this.professorConflictColors[professorCode]) {
                      this.professorConflictColors[professorCode] = this.generateRandomPastelColor();
                  }
              });
          }
      },
      created: function() {},
      mounted: function() {
          let vm = this;
          if (vm.result) {
              let studentsByBranch = vm.countStudentsByBranch(vm.result.sec);
              vm.branchTotals = vm.groupByBranch(vm.result.pre);
              vm.branchTotals.forEach((bt) => {
                  const branchName = bt.branch;
                  if (studentsByBranch[branchName] !== undefined) {
                      bt.assignedStudents = studentsByBranch[branchName];
                  } else {
                      bt.assignedStudents = 0;
                  }
              });

              vm.loading = false;

              if (window.jQuery.fn.DataTable.isDataTable(vm.$refs.asignation_table)) {
                  window
                      .jQuery(vm.$refs.asignation_table)
                      .DataTable()
                      .destroy();
              }

              window
                  .jQuery(vm.$refs.asignation_table)
                  .find("tbody")
                  .empty();

              let columns = [{
                  data: function(row) {
                      return row.std_branch.name;
                  },
              }, {
                  data: function(row) {
                      return row.crs_assignation_classroom ? row.crs_assignation_classroom.name : "No tiene";
                  },
              }, {
                  data: function(row) {
                      if (!window.__debugAlumnos) {
                          window.__debugAlumnos = true;
                          console.log("DEBUG row completo:", row);
                          if (row.crs_assignation_preinscriptions && row.crs_assignation_preinscriptions[0]) {
                              console.log("DEBUG preinscription[0] keys:", Object.keys(row.crs_assignation_preinscriptions[0]));
                              console.log("DEBUG preinscription[0]:", row.crs_assignation_preinscriptions[0]);
                          } else {
                              console.log("DEBUG no hay preinscriptions en row");
                          }
                      }
                      return vm.countAssignedStudents(row).toString();
                  },
              }, {
                  data: function(row) {
                      if (row.crs_assignation_classroom && row.crs_assignation_classroom.crs_assignation_classroom_careers) {
                          const careers = row.crs_assignation_classroom.crs_assignation_classroom_careers;
                          const careerNames = careers
                              .map(career => career.std_career ? career.std_career.name : null)
                              .filter(name => name !== null);

                          return careerNames.length > 0 ? careerNames.join(", ") : "No tiene";
                      }
                      return "No tiene";
                  },
              }, {
                  data: function(row) {
                      return row.crs_course ? row.crs_course.name : "No tiene";
                  },
              }, {
                  data: function(row) {
                      let setup = JSON.parse(row.pfs_professor.setup);
                      return setup.professor_code;
                  },
              }, {
                  data: function(row) {
                      let setup = JSON.parse(row.pfs_professor.setup);
                      return setup.name + " " + setup.lastname;
                  },
              }, {
                  data: function(row) {
                      return row.std_studying_cycle ? row.std_studying_cycle.name : "No tiene";
                  },
              }, {
                  data: function(row) {
                      let setup = JSON.parse(row.setup);
                      return setup.schedule;
                  },
              }, {
                  data: function(row) {
                      let setup = JSON.parse(row.setup);
                      let day = setup.day_index;
                      for (const d of vm.result.dias) {
                          if (d.day_index == day) {
                              return d.name;
                          }
                      }
                  },
              }, {
                  data: function(row) {
                      return row.crs_assignation_season ? row.crs_assignation_season.name : "No tiene";
                  },
              }, {
                  data: function(row) {
                      let setup = JSON.parse(row.setup);
                      return setup.code;
                  },
              }];

              if (window.jQuery.fn.DataTable.isDataTable(vm.$refs.resumen_table)) {
                  window
                      .jQuery(vm.$refs.resumen_table)
                      .DataTable()
                      .destroy();
              }

              window
                  .jQuery(vm.$refs.resumen_table)
                  .find("tbody")
                  .empty();

              let columns2 = [{
                  data: function(row) {
                      return row.branch;
                  }
              }, {
                  data: function(row) {
                      return row.assignedStudents;
                  }
              }, {
                  data: function(row) {
                      return row.totalStudents - row.assignedStudents;
                  }
              }, {
                  data: function(row) {
                      return row.totalStudents;
                  }
              }];

              let processedData = [];
              let seenKeys = new Set();

              vm.result.sec.forEach(row => {
                  let setup = JSON.parse(row.setup);
                  let professorCode = row.pfs_professor ? JSON.parse(row.pfs_professor.setup).professor_code : '';
                  let courseName = row.crs_course ? row.crs_course.name : 'No tiene';
                  let schedule = setup.schedule;
                  let dayIndex = setup.day_index;

                  let uniqueKey = `${professorCode}_${courseName}_${schedule}_${dayIndex}`;

                  if (!seenKeys.has(uniqueKey)) {
                      seenKeys.add(uniqueKey);

                      if (setup.theory && setup.practice && (setup.careers || "").includes("Licenciatura en Nutrición")) {
                          let theoryRow = {
                              ...row,
                              crs_course: {
                                  name: `${courseName} - Teoría`
                              },
                              setup: JSON.stringify({
                                  ...setup,
                                  schedule: setup.theory.schedule,
                                  day_index: setup.theory.day_index
                              })
                          };

                          let practiceRow = {
                              ...row,
                              crs_course: {
                                  name: `${courseName} - Práctica`
                              },
                              setup: JSON.stringify({
                                  ...setup,
                                  schedule: setup.practice.schedule,
                                  day_index: setup.practice.day_index
                              })
                          };

                          processedData.push(theoryRow, practiceRow);
                      } else {
                          processedData.push(row);
                      }
                  }
              });

              let tbl = window.jQuery(vm.$refs.asignation_table).DataTable({
                  pageLength: 50,
                  autoWidth: true,
                  ordering: true,
                  scrollCollapse: true,
                  data: processedData,
                  language: {
                      url: "//cdn.datatables.net/plug-ins/1.10.21/i18n/Spanish.json"
                  },
                  columns: columns,
                  createdRow: function(row, data) {
                  },
                  dom: "lBfrtip",
                  buttons: [
                      'csv',
                      {
                          text: 'Excel',
                          action: function(e, dt, button, config) {
                              const wb = new ExcelJS.Workbook();
                              const ws = wb.addWorksheet("Asignaciones");

                              const headers = dt.columns().header().toArray().map(th => th.innerText);
                              ws.addRow(headers);

                              const tableData = dt.rows({
                                  search: 'applied'
                              }).data().toArray();

                              tableData.forEach(rowData => {
                                  const cellValues = [
                                      rowData.std_branch.name,
                                      rowData.crs_assignation_classroom ? rowData.crs_assignation_classroom.name : "No tiene",
                                      vm.countAssignedStudents(rowData).toString(),
                                      (function() {
                                          if (rowData.crs_assignation_classroom &&
  rowData.crs_assignation_classroom.crs_assignation_classroom_careers) {
                                              const careers = rowData.crs_assignation_classroom.crs_assignation_classroom_careers;
                                              return careers
                                                  .map(c => c.std_career ? c.std_career.name : null)
                                                  .filter(n => n)
                                                  .join(", ") || "No tiene";
                                          }
                                          return "No tiene";
                                      })(),
                                      rowData.crs_course ? rowData.crs_course.name : "No tiene",
                                      JSON.parse(rowData.pfs_professor.setup).professor_code,
                                      JSON.parse(rowData.pfs_professor.setup).name + " " +
  JSON.parse(rowData.pfs_professor.setup).lastname,
                                      rowData.std_studying_cycle ? rowData.std_studying_cycle.name : "No tiene",
                                      JSON.parse(rowData.setup).schedule,
                                      (vm.result.dias.find(d => d.day_index == JSON.parse(rowData.setup).day_index) || {}).name ||
  '',
                                      rowData.crs_assignation_season ? rowData.crs_assignation_season.name : "No tiene",
                                      JSON.parse(rowData.setup).code
                                  ];

                                  const newRow = ws.addRow(cellValues);

                                  const professorCode = JSON.parse(rowData.pfs_professor.setup).professor_code;
                                  const hex = vm.professorConflictColors[professorCode];
                                  if (hex) {
                                      const argb = "FF" + hex.substring(1).toUpperCase();
                                      newRow.eachCell(cell => {
                                          cell.fill = {
                                              type: 'pattern',
                                              pattern: 'solid',
                                              fgColor: {
                                                  argb: argb
                                              }
                                          };
                                      });
                                  }
                              });

                              wb.xlsx.writeBuffer().then(data => {
                                  const blob = new Blob([data], {
                                      type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
                                  });
                                  let link = document.createElement('a');
                                  link.href = URL.createObjectURL(blob);
                                  link.download = 'Carga_Academica_Asignaciones.xlsx';
                                  document.body.appendChild(link);
                                  link.click();
                                  document.body.removeChild(link);
                              }).catch(function(error) {
                                  console.error('Error al generar el archivo Excel:', error);
                              });
                          }
                      },
                      'print'
                  ]
              });

              window.jQuery(vm.$refs.asignation_table).on('click', 'tbody tr', function() {
                  var data = tbl.row(this).data();
                  vm.handleRowClick(data);
              });

              tbl.on("page.dt", function() {
              });

              let tb2 = window.jQuery(vm.$refs.resumen_table).DataTable({
                  pageLength: 50,
                  autoWidth: true,
                  ordering: true,
                  scrollCollapse: true,
                  data: vm.branchTotals,
                  language: {
                      url: "//cdn.datatables.net/plug-ins/1.10.21/i18n/Spanish.json"
                  },
                  columns: columns2,
                  createdRow: function(row, data) {
                  },
                  dom: "lBfrtip",
                  buttons: [
                      'csv', 'excel', 'print'
                  ]
              });

              tb2.on("page.dt", function() {
              });
          }
          window.jQuery(".ui.tabular.menu .item").tab();
      }
  }