# Ticketera interna (`internal_ticket`) — contexto funcional y de datos

Este documento describe **cómo funciona el módulo y de dónde salen los datos**, pensado
para construir un reporte sobre tickets desde otro repositorio (consultas de solo lectura
contra esta base de datos). No describe código ni implementación, solo reglas de negocio
y estructura de datos.

## 1. Qué es

Un módulo de tickets internos entre áreas de la institución (no tickets de soporte al
estudiante). Un área (ej. Coordinación, Secretaría, Caja, Admisiones) recibe tickets,
los asigna a sus miembros, los trabaja y los puede transferir a otra área o devolver a
quien lo creó. Opcionalmente un ticket puede estar asociado a un estudiante puntual.

## 2. Tablas del módulo

### `internal_ticket` — el ticket en sí (tabla principal)

| Campo | Significado |
|---|---|
| `ticket_id` | PK, también es el "número de ticket" visible al usuario |
| `description` | Descripción del ticket |
| `tag_id` | Etiqueta opcional (`internal_ticket_tag`) |
| `student_id` | Estudiante asociado, opcional (`std_student`) |
| `role_id` | Área **actual** dueña del ticket (ver sección 3) |
| `branch_id` | Sede actual, solo aplica si el área actual depende de sede |
| `assigned_user_id` | Usuario al que está asignado hoy (NULL = sin asignar, en el "bolsón" del área) |
| `status_id` | Estado actual (`internal_ticket_status_type`) |
| `create_role_id` | Área de **origen** (snapshot fijo: no cambia aunque el ticket se transfiera). Es el destino cuando el ticket se devuelve |
| `create_branch_id` | Sede de origen (snapshot fijo) |
| `create_user_id` | Usuario que creó el ticket (snapshot fijo). También destino al devolver |
| `return_comment` | Comentario obligatorio al devolver el ticket a su origen |
| `finish_comment` | Comentario obligatorio al finalizar el ticket; se borra automáticamente si el ticket deja de estar Finalizado (por reasignación, reapertura, etc.) |
| `last_sent_by_user_id` / `last_sent_at` | Quién y cuándo fue la última transferencia del ticket |
| `create_date` | Fecha de creación — **es la fecha base para calcular vencimiento**, nunca cambia |
| `update_date` | Se actualiza en cada modificación del ticket — la bandeja ordena por esta columna |

### `internal_ticket_area` — catálogo de áreas

Es la única fuente de verdad de "qué roles del sistema son un área de la ticketera".

| Campo | Significado |
|---|---|
| `area_id` | PK |
| `role_id` | Rol del sistema (`usr_role`) que representa a esta área. Es lo que se guarda en `internal_ticket.role_id` |
| `name` | Nombre visible del área |
| `admin_role_id` | Rol que administra (ve todo, no solo lo pendiente/propio) esta área. Puede ser distinto del rol dueño |
| `requires_branch` | Si el área depende de sede (ej. Coordinador, Secretarias: una instancia por sede/campus) |
| `can_create_any_area` | Si esta área puede crear tickets dirigidos a OTRA área |
| `can_transfer_any_area` | Si esta área puede transferir sus tickets a OTRA área (no solo reasignar internamente) |
| `can_create_own_area` | Si esta área puede crear tickets para sí misma (históricamente siempre permitido) |
| `status_code` | `A` activa / `I` inactiva (borrado lógico) |

### `internal_ticket_status_type` — catálogo de estados

| Campo | Significado |
|---|---|
| `status_id` | PK, es lo que se guarda en `internal_ticket.status_id` |
| `code` | Código fijo interno (no editable) — ver sección 4. Estados personalizados creados desde Configuración tienen `code` NULL |
| `name` | Nombre visible, editable desde Configuración |
| `status_code` | `A` activo / `I` inactivo. Los estados de sistema (con `code`) nunca se pueden inactivar ni borrar |

### `internal_ticket_tag` — etiquetas

| Campo | Significado |
|---|---|
| `tag_id` | PK |
| `role_id` | Área dueña de la etiqueta. **NULL = etiqueta global**, visible y usable por todas las áreas |
| `name` | Nombre de la etiqueta |
| `status_code` | `A`/`I` |

### `internal_ticket_setting` — configuración general (1 fila por empresa/`enterprise_id`)

| Campo | Significado |
|---|---|
| `enterprise_id` | Empresa (multi-tenant) |
| `setup` | JSON en texto. Hoy solo contiene `expiration_days`: días desde `create_date` para considerar vencido un ticket. `NULL` o ausente = vencimiento desactivado |

## 3. Relación con tablas externas al módulo

- `internal_ticket.role_id` / `create_role_id` → `usr_role.role_id`: el "área" en este módulo
  **es un rol del sistema de permisos**, no una tabla propia de organigrama. `internal_ticket_area`
  es la capa que decide qué roles participan como área de ticketera.
- `internal_ticket.branch_id` / `create_branch_id` → `std_branch.branch_id`: sede/campus.
- `internal_ticket.assigned_user_id` / `create_user_id` / `last_sent_by_user_id` → `usr_user.user_id`.
- `internal_ticket.student_id` → `std_student.student_id`: estudiante opcional asociado al
  ticket (nombre, carné, DPI, y `setup` en JSON con email/celular/teléfono fijo).
- La pertenencia de un usuario a un área con sede se resuelve vía la suscripción de
  roles del usuario (`usr_role_suscription`) cruzada con la sede del usuario (`std_user.branch_id`),
  **no** hay una tabla propia de "miembros de área" en este módulo.

## 4. Estados del ticket (catálogo de sistema)

Estos 5 estados son indispensables para el flujo (identificados por `code`, estable; el
`name` se puede renombrar desde Configuración):

| `code` | Nombre por defecto | Significado |
|---|---|---|
| `PENDING` | Pendiente | Sin asignar, en el "bolsón" del área. Nunca tiene `assigned_user_id` |
| `ASSIGNED` | Asignado | Asignado a un usuario puntual del área |
| `IN_PROGRESS` | En proceso | Estado de trabajo intermedio, elegido a mano |
| `FINISHED` | Finalizado | Cerrado. Requiere `finish_comment`. Un ticket Finalizado **nunca está vencido** |
| `RETURNED` | Devuelto | El ticket fue devuelto a quien lo creó originalmente (ver sección 6) |

Además, desde Configuración se pueden crear estados **custom** adicionales (`code` NULL,
solo para pasos de trabajo intermedios tipo "En proceso"/"Finalizado" personalizados;
estos sí se pueden inactivar o borrar si no están en uso). `PENDING`, `ASSIGNED` y
`RETURNED` nunca se pueden elegir a mano desde un cambio de estado libre: tienen su
propia acción dedicada (asignar / devolver al bolsón / devolver al origen), porque esas
acciones además mueven `assigned_user_id`, `role_id`, etc.

## 5. Qué es un ticket "vencido"

**No es un campo de la base de datos** — se calcula al vuelo en cada consulta, nunca se
guarda ni se recalcula por un job:

- Vencido = `(ahora - create_date) >= expiration_days` (días de la configuración general
  de la empresa, `internal_ticket_setting`).
- Si `expiration_days` es NULL/0 (vencimiento desactivado para esa empresa), ningún
  ticket vence nunca.
- Un ticket en estado `FINISHED` **nunca** se considera vencido, sin importar su edad.
- Si un ticket Finalizado se reabre (pasa a otro estado), vuelve a poder vencerse de
  inmediato usando su `create_date` original (que nunca cambia, ni siquiera al
  transferirse entre áreas).
- La "antigüedad" para el vencimiento siempre se mide desde `create_date` (fecha de
  creación original), **no** desde `update_date` ni desde la última transferencia.

Para un reporte: un ticket vencido = estado actual distinto de `FINISHED` **y**
`DATEDIFF(NOW(), create_date) >= expiration_days` de la empresa correspondiente (si esa
empresa tiene `expiration_days` configurado; si no, no aplica).

## 6. Ciclo de vida / flujo de un ticket

1. **Creación**: alguien de un área origen crea un ticket dirigido a su propia área o a
   otra área (si el área origen tiene permiso `can_create_any_area`/`can_create_own_area`).
   - Si el área destino depende de sede y hay **exactamente un** usuario con ese rol en
     esa sede, el ticket se **asigna automáticamente** a esa persona (`ASSIGNED`).
   - Si hay 0 o 2+ candidatos, o el área no depende de sede, queda `PENDING` en el
     bolsón del área (visible para todos los miembros de esa área/sede).
2. **Asignación** (`ASSIGNED`): un miembro se autoasigna un ticket pendiente, o el
   administrador del área lo asigna a otro miembro.
3. **Trabajo**: quien tiene el ticket asignado (o el administrador del área, o un
   superusuario) puede:
   - Cambiarlo a un estado de trabajo (`IN_PROGRESS`, `FINISHED` u otro custom).
   - **Transferirlo** a otra área o a otro usuario de la misma área (misma lógica de
     auto-asignación si el destino tiene exactamente un candidato por sede).
   - **Devolverlo al bolsón** de su propia área (deshace una autoasignación: vuelve a
     `PENDING`, sin usuario asignado).
   - **Devolverlo al origen** (`RETURNED`): regresa siempre al área y usuario que
     **crearon originalmente** el ticket (`create_role_id`/`create_user_id`), sin
     importar cuántas transferencias haya tenido entre medio. Requiere comentario
     (`return_comment`).
4. **Finalización** (`FINISHED`): requiere comentario de cierre (`finish_comment`). Deja
   de contar como pendiente y de poder vencerse.
5. Si un ticket Finalizado se reasigna o se le cambia el estado, el `finish_comment` se
   borra automáticamente (ya no aplica).
6. **Eliminación**: borrado físico (no hay histórico/soft-delete de tickets eliminados).
   Reservado a administradores de área o superusuario; dos roles puntuales (Coordinador y
   Secretarias, que administran por sede, no por área) nunca pueden eliminar tickets.

## 7. Vistas/agrupaciones de tickets (para pensar el reporte)

Son filtros de consulta, no estados ni tablas distintas:

- **Bandeja de área**: tickets donde `role_id` = área, visibles para sus miembros. Un
  miembro normal (no administrador del área) solo ve lo pendiente sin asignar + lo
  asignado a él mismo; el administrador del área ve todo.
- **Mis tickets**: tickets con `assigned_user_id` = el usuario.
- **Creados por mi área**: tracking de solo lectura por `create_role_id`/`create_branch_id`
  (origen fijo), sin importar en qué área esté el ticket *ahora*.
- **Bandeja de módulo**: vista global sin restricción de área/sede, solo para superusuario.

## 8. Multi-tenant / alcance


Las etiquetas, estados y áreas filtran implícitamente por `enterprise_id` a través del
rol (`usr_role.enterprise_id`); la configuración general (`expiration_days`) es explícita
por `enterprise_id` en `internal_ticket_setting`. Al construir un reporte que cruce varias
empresas, hay que tener en cuenta que el umbral de vencimiento puede ser distinto (o estar
desactivado) por empresa.
