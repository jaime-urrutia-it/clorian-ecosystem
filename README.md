

```markdown
# 🔄 Clorian Ecosystem — De ITSM a Business Operations

**Arquitectura de integración MySQL ↔ Jira Cloud con capa de control Order-to-Cash**

MVP funcional que demuestra automatización de flujos ITSM y control de procesos de negocio, aplicable a entornos de SSC y Business Operations.

![Java](https://img.shields.io/badge/Java-17%2B-blue)
![Jira](https://img.shields.io/badge/Jira-Cloud%2FServer-0052CC.svg)
![MySQL](https://img.shields.io/badge/MySQL-5.7+-4479A1.svg)
![License](https://img.shields.io/badge/License-MIT-yellow.svg)

---

## 🎯 Propósito del Ecosistema

Este ecosistema documenta una evolución profesional en dos actos:

- **Clorian 1.0 (ITSM):** coordinación operativa mediante sincronización bidireccional de incidencias entre MySQL y Jira Cloud, aplicando principios de ITIL v4.
- **Clorian 2.0 (Business Operations):** control del proceso Order-to-Cash sobre la misma capa de datos, detectando excepciones financieras, clasificándolas por severidad y aplicando SLA de 48h.

Más allá de la integración técnica, el proyecto ilustra cómo la automatización de flujos operativos entre sistemas desconectados reduce latencia, elimina errores manuales y proporciona trazabilidad completa — competencias transferibles a entornos de operaciones de negocio.

### Caso de Uso Empresarial

**Clorian 1.0:** Sincronización automática entre:
- Base de datos de operaciones (MySQL) → Tickets de soporte internos
- Jira Cloud/Server → Gestión ágil de incidencias técnicas

**Clorian 2.0:** Control de conciliación Order-to-Cash:
- Three-way match: Booking vs Payment vs Ticket
- Clasificación por severidad (CRÍTICA / ALTA / MEDIA)
- SLA de resolución de 48h para excepciones financieras

**Resultado:** Trazabilidad completa entre departamentos operativos y equipos técnicos, con evolución materializada en Clorian 2.0 hacia conciliación O2C y gestión de excepciones.

---

## 🏗️ Arquitectura del Sistema

```
┌─────────────────────────────────────────────────────────────────┐
│                    SINCRONIZACIÓN BIDIRECCIONAL                  │
└─────────────────────────────────────────────────────────────────┘

┌──────────────────────┐      ┌──────────────────────┐
│   MYSQL SERVER       │      │   JIRA CLOUD         │
│   (clorian_db)       │      │   (Proyecto KAN)     │
│                      │      │                      │
│  • SupportTickets    │◄─────│  • Issues            │
│  • Customers         │  (2) │  • Workflows         │
│                      │      │  • Estados           │
└──────────┬───────────┘      └──────────▲───────────┘
           │                            │
          (1)               (2) Webhook (tiempo real)
           │                            │
           ▼                            │
┌──────────────────────┐      ┌──────────┴───────────┐
│  CLORIAN DB          │      │  JIRA WEBHOOK        │
│  CONNECTOR           │      │  RECEIVER            │
│                      │      │                      │
│  • Polling cada 30s  │      │  • HTTP POST endpoint│
│  • MySQL → Jira      │      │  • Jira → MySQL      │
│  • Creación de issues│      │  • Actualización     │
│  • Sync de estados   │      │    inmediata         │
└──────────────────────┘      └──────────────────────┘
   [Clorian DB Connector](https://github.com/jaime-urrutia-it/clorian-db-connector)
   [Jira Webhook Receiver](https://github.com/jaime-urrutia-it/jira-webhook-receiver)
```

### Componentes del Ecosistema

| Componente | Rol | Dirección | Método | Latencia | Stack Técnico |
|---|---|---|---|---|---|
| [Clorian DB Connector](https://github.com/jaime-urrutia-it/clorian-db-connector) | Emisor | MySQL → Jira | REST API + Polling | ~30s (Standalone) / Creación única (Integrado) | Java 17+, JDBC, HttpClient, org.json |
| [Jira Webhook Receiver](https://github.com/jaime-urrutia-it/jira-webhook-receiver) | Receptor | Jira → MySQL | HTTP Webhook | < 1 segundo (tiempo real) | Spring Boot 3.3.3, Maven, MySQL Connector/J |

---

## 🚀 Flujo de Trabajo Completo

### 1. Creación de Ticket (MySQL → Jira)

```
Usuario crea ticket en MySQL
↓
Clorian DB Connector detecta (polling 30s)
↓
Crea issue en Jira
↓
Actualiza jira_issue_key en MySQL
```

### 2. Actualización de Estado (Jira → MySQL)

```
Usuario cambia estado en Jira
↓
Jira dispara webhook HTTP POST
↓
Jira Webhook Receiver procesa
↓
Actualiza status en MySQL inmediatamente
```

### 3. Prevención de Ciclos Infinitos

✓ Campo `last_sync_status` evita bucles
✓ Comparación de estados antes de sincronizar
✓ Idempotencia garantizada por comparación `status` vs `last_sync_status`

---

## 📦 Proyectos Individuales

### 🔵 Clorian DB Connector (Emisor)

**Responsabilidad:** Enviar datos desde MySQL hacia Jira

✅ Detección de nuevos tickets de soporte (`status='Open'`)
✅ Creación automática de issues en Jira vía REST API
✅ Sincronización de estados cada 30s (polling)
✅ Mapeo de prioridades y campos personalizados

**Stack Técnico:** Java 17+, JDBC, HTTP Client, org.json

🔗 [Ver documentación completa →](https://github.com/jaime-urrutia-it/clorian-db-connector)

---

### 🟢 Jira Webhook Receiver (Receptor)

**Responsabilidad:** Recibir actualizaciones de Jira en tiempo real

✅ Endpoint HTTP `/api/jira-webhook` (Spring Boot)
✅ Procesamiento asíncrono (respuesta < 100ms)
✅ Actualización inmediata de MySQL
✅ Soporte para eventos: `issue_created`, `issue_updated`

**Stack Técnico:** Spring Boot 3.3.3, Maven, MySQL Connector/J

🔗 [Ver documentación completa →](https://github.com/jaime-urrutia-it/jira-webhook-receiver)

---

## 🎓 Contexto del Proyecto

### Propósito

Este ecosistema documenta una evolución profesional en dos actos:
- **Clorian 1.0:** coordinación operativa ITSM (sincronización de incidencias)
- **Clorian 2.0:** control de procesos de negocio (conciliación O2C)

Aplicable a roles de:
- Business Operations Analyst (operativo/junior)
- SSC Operations Coordinator
- IT Service Coordinator
- Customer Service Multilingüe (SSC)

### Competencias Demostradas

✅ **Automatización de procesos operativos:** Integración bidireccional entre sistemas de negocio para eliminar trabajo manual y reducir latencia de respuesta

✅ **Arquitecturas de integración enterprise:** Diseño de sistemas emisor/receptor con prevención de ciclos y tolerancia a fallos

✅ **Coordinación negocio-tecnología:** Capacidad de traducir necesidades operativas (trazabilidad, sincronización, alertas) en soluciones técnicas funcionales

✅ **Aplicación de ITIL v4:** Gestión de incidencias con flujo completo (detección → creación → resolución → cierre)

✅ **Control de procesos de negocio:** Three-way match, clasificación por severidad, SLA de resolución (Clorian 2.0)

---

## 🎬 Demo Visual

### Demo Clorian 1.0 (ITSM)

Próximamente: Video demostrativo de la sincronización bidireccional en acción

![Demo](https://img.shields.io/badge/🎬_Demo-Próximamente-red?style=for-the-badge)

**Lo que verás en el video:**
- Creación de ticket en MySQL → Aparición automática en Jira (~30s)
- Cambio de estado en Jira → Actualización inmediata en MySQL (<1s)
- Logs de ambos servicios en tiempo real
- Consultas SQL de verificación

---

### Demo Clorian 2.0 (Business Operations)

Próximamente: Video demostrativo del control de conciliación O2C

![Demo](https://img.shields.io/badge/🎬_Demo-Próximamente-red?style=for-the-badge)

**Lo que verás en el video:**
- Regla de negocio: three-way match Booking–Payment–Ticket
- Vista de excepciones clasificadas por severidad (CRÍTICA / ALTA / MEDIA)
- Resumen ejecutivo para stakeholder (4 KPIs de control)
- Aplicación de SLA 48h sobre excepciones financieras

---

## 📊 Métricas Técnicas

| Métrica | Modo Standalone | Modo Integrado |
|---|---|---|
| Latencia emisor (MySQL → Jira) | ~30s (polling) | ~30s (solo creación de tickets nuevos) |
| Latencia receptor (Jira → MySQL) | N/A (no aplica) | < 1s (webhook tiempo real) |
| Trazabilidad | 100% | 100% |
| Prevención de bucles | Implementada vía `last_sync_status` | Implementada vía `last_sync_status` |
| Carga sobre Jira API | Alta (polling constante de estados) | Baja (solo creación de issues) |

---

## 🛠️ Instalación Rápida

### Requisitos previos

- Java JDK 17+
- MySQL Server 5.7+
- Jira Cloud/Server (con permisos de admin)
- Maven 3.8+ (solo para Webhook Receiver)

### 1. Clonar ambos proyectos

```bash
git clone https://github.com/jaime-urrutia-it/clorian-db-connector.git
git clone https://github.com/jaime-urrutia-it/jira-webhook-receiver.git
```

### 2. Configurar base de datos

```sql
-- Esquema compartido por ambos componentes
CREATE TABLE Customers (
    customer_id INT PRIMARY KEY,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    email VARCHAR(255)
);

CREATE TABLE SupportTickets (
    support_ticket_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT,
    subject VARCHAR(255) NOT NULL,
    description TEXT,
    priority ENUM('High', 'Medium', 'Low') DEFAULT 'Medium',
    status ENUM('Open', 'In Progress', 'Waiting for Customer', 'Resolved', 'Closed') DEFAULT 'Open',
    jira_issue_key VARCHAR(50) UNIQUE,
    last_sync_status VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)
);

CREATE INDEX idx_jira_key ON SupportTickets(jira_issue_key);
CREATE INDEX idx_status_sync ON SupportTickets(status, last_sync_status);
```

**Nota:** `jira_issue_key` usa `VARCHAR(50)` para acomodar claves de Jira con prefijos de proyecto largos.

### 3. Compilar y ejecutar

**Clorian DB Connector (compilación manual con javac):**

```bash
cd clorian-db-connector
# Descargar mysql-connector-java-8.x.jar y colocarlo en lib/
javac -cp "lib/*:." -d out src/module-info.java $(find src -name "*.java")
java -cp "lib/*:out" com.clorian.db.MainTest
```

**Jira Webhook Receiver (compilación Maven):**

```bash
cd jira-webhook-receiver
mvn clean package
java -jar target/JiraWebhookReceiver-1.0.0.jar
```

### 4. Configurar webhook en Jira

Jira → Configuración del Sistema → WebHooks
URL: `http://<ip-servidor>:8080/api/jira-webhook`
Eventos: Issue → updated

---

## 🗺️ Mapeo de Estados (Referencia Única)

Esta tabla es la referencia autorizada para ambos componentes. Cualquier modificación debe aplicarse de forma coordinada.

| Estado Jira (Español) | Estado Jira (Inglés) | Estado MySQL | ID Transición Jira |
|---|---|---|---|
| Tareas por hacer | To Do | Open | 11 |
| En curso | In Progress | In Progress | 21 |
| Esperando por el cliente | Waiting for Customer | Waiting for Customer | 31 |
| Resuelta | Resolved | Resolved | 41 |
| Cerrada | Closed | Closed | 51 |

---

## 🔐 Seguridad

### Estado actual

✅ `PreparedStatement` en toda la capa de datos (prevención de SQL Injection)
✅ Conexiones JDBC con try-with-resources (gestión correcta de recursos)
✅ Credenciales configurables (ver READMEs individuales para instrucción de externalización)

### Mejoras recomendadas para producción

⚠️ Validación de firma HMAC-SHA256 en webhooks (Jira envía header `X-Hub-Signature`)
⚠️ HTTPS obligatorio con certificado SSL válido
⚠️ Whitelist de IPs de Atlassian en el endpoint del webhook receptor
⚠️ Externalización completa de credenciales mediante variables de entorno o vault de secrets
⚠️ Rate limiting para prevención de DoS en el endpoint público

---

### ⚠️ Limitaciones Conocidas del MVP (Agosto 2026)

Este proyecto es un MVP de demostración, no un sistema de producción. Las siguientes limitaciones están documentadas intencionalmente como parte del roadmap de maduración:

| Limitación | Impacto | Plan de mitigación |
|---|---|---|
| Endpoint webhook sin autenticación HMAC | Cualquiera podría enviar payloads falsos | Implementar validación HMAC-SHA256 (ver Roadmap) |
| Procesamiento asíncrono con `new Thread()` sin pool | Riesgo bajo carga alta | Migrar a `ExecutorService` con pool controlado |
| UPSERT recursivo en receptor | Posible `StackOverflowError` bajo condiciones extremas | Refactorizar a bucle iterativo |
| Polling cada 30s en modo standalone | Carga innecesaria sobre API de Jira | Aumentar intervalo o migrar a webhook-only |
| Logging por consola (`System.out`) | Sin rotación ni niveles | Migrar a SLF4J + Logback |

**Nota sobre el alcance:** Estas limitaciones están documentadas porque un entorno SSC/Business Operations valora tanto el control de un sistema como la honestidad sobre su estado. La decisión de abordarlas (o aceptarlas como riesgo controlado en un entorno de bajo volumen) corresponde al equipo de operaciones que adopte el proyecto.

---

## 📊 Clorian 2.0 — Capa de Business Operations (Control O2C)

Clorian 1.0 sincroniza incidencias entre MySQL y Jira (ITSM). Clorian 2.0 reutiliza la capa de negocio de esa misma base de datos (bookings, payments, tickets, refunds) para controlar el proceso Order-to-Cash: detectar excepciones, priorizarlas por severidad y reportarlas a stakeholder.

### Regla de negocio (el control)

> Toda reserva confirmada debe tener el importe cobrado (payments − refunds) y el importe entregado en tickets iguales al total reservado. Cualquier desviación es una excepción con SLA de resolución de 48 horas.

### Artefacto: [`reconciliacion_clorian.sql`](reconciliacion_clorian.sql)

| Componente | Qué controla |
|---|---|
| `v_booking_reconciliation` | Three-way match Booking–Payment–Ticket: reservado vs cobrado (neto de reembolsos) vs entregado |
| `v_booking_exceptions` | Clasifica cada excepción por severidad (CRÍTICA / ALTA / MEDIA) y estado de SLA |
| Consulta 3a | Resumen ejecutivo por severidad: nº de excepciones, € en riesgo, incumplimientos de SLA |
| Consulta 3b | Tendencia semanal: ¿vamos mejor o peor que la semana anterior? |
| Consulta 3c | Top 5 excepciones críticas: el detalle que respalda el resumen |

### Qué aporta esta capa

- **Three-way match** aplicado a Order-to-Cash: técnica de control estándar en SSC / Business Operations.
- **Priorización por severidad y SLA**: la misma lógica de TMO/FCR de la operativa bancaria regulada, aplicada a discrepancias de cobro y entrega.
- **Reporte orientado a stakeholder**: cuatro números que permiten decidir por dónde empezar, en lugar de un volcado de datos.

🎬 Vídeo en producción: se publicará como segunda entrada del proyecto Clorian en el portfolio (yagourrutia.com).

---

## 📈 Roadmap

### ✅ Clorian 2.0 — Completado

- [x] Módulo de conciliación O2C: implementado en [`reconciliacion_clorian.sql`](reconciliacion_clorian.sql)

### 🔜 Próximas mejoras (Versión 2.1+)

**Pista de Negocio (Prioridad estratégica)**

- [ ] Dashboard de KPIs de servicio (SLA, tiempo medio de resolución, volúmenes por estado)
- [ ] Gestor de excepciones financieras con alertas automáticas
- [ ] Reportes operativos exportables (CSV/PDF) con datos de sincronización
- [ ] Integración con ERPs (SAP, Oracle) para ampliar el alcance operacional

**Pista Técnica**

- [ ] Externalización completa de credenciales (variables de entorno / vault)
- [ ] Validación de firma HMAC-SHA256 en webhooks
- [ ] Dockerización oficial (Dockerfile + Docker Compose)
- [ ] Migración completa del DB Connector a Spring Boot
- [ ] Cola de mensajes (RabbitMQ/ActiveMQ) para desacoplar recepción de procesamiento
- [ ] API REST propia para gestión de sincronización (start/stop/status)
- [ ] Soporte para PostgreSQL
- [ ] Logging profesional (SLF4J + Logback) en ambos componentes

---

## 🤝 Contribución

Este es un proyecto abierto. Si encuentras bugs o tienes sugerencias:

1. Abre un issue en el repositorio correspondiente
2. Especifica si es para el Emisor o el Receptor
3. Incluye logs relevantes y pasos para reproducir

---

## 📄 Licencia

Distribuido bajo licencia MIT. Ver [LICENSE](LICENSE) para más detalles.

---

## 👤 Autor

**Jaime (Yago) Urrutia**

[GitHub](https://github.com/jaime-urrutia-it) | [Portfolio](https://yagourrutia.com) | [LinkedIn](https://www.linkedin.com/in/jaime-yago-urrutia-multilingue/)

Barcelona, España

---

### 🔎 Búsqueda activa de oportunidades como:

✅ Business Operations Analyst (operativo/junior)
✅ SSC Operations Coordinator
✅ IT Service Coordinator
✅ Customer Service Multilingüe (SSC)

**Idiomas:** Español (nativo) • Catalán (nativo) • Francés (C1) • Inglés (C1)

---

## 🔗 Enlaces de Interés

📋 Portfolio Completo: https://yagourrutia.com/
💼 LinkedIn: https://www.linkedin.com/in/jaime-yago-urrutia-multilingue/
📄 CV Actualizado: (próximamente)

---

¿Te ha sido útil este proyecto?

⭐ Dale una estrella • 🍴 Fork • 📢 Compartir

Desarrollado con 💙 como parte de un proceso de aprendizaje estructurado en arquitecturas de integración y control de procesos de negocio.

---

**Versión:** 1.0.0 | **Última actualización:** Agosto 2026
```

---

## 📝 Mensaje de commit sugerido

**Título:**
```
docs(ecosystem): integrar Clorian 2.0 y alinear transición ITSM → SSC
```

**Descripción:**
```
Reescritura integral del README para reflejar la evolución técnica y profesional del proyecto:

- Añade sección "Clorian 2.0 — Capa de Business Operations (Control O2C)" con regla de negocio, three-way match y SLA 48h.
- Actualiza el framing del ecosistema: de arquitectura puramente ITSM a control de procesos de negocio (SSC/Business Ops).
- Marca como completado [x] el módulo de conciliación O2C en el Roadmap.
- Actualiza los roles objetivo en "Búsqueda activa" (Business Operations Analyst, SSC Operations Coordinator).
- Añade sección "Demo Visual" para el próximo vídeo de Clorian 2.0.
- Alinea la narrativa del ecosistema con el Profile README y el titular de LinkedIn.
```

---

## 🎯 Resultado esperado tras el commit

Con este README publicado, el ecosistema Clorian cuenta la historia completa: **misma infraestructura, dos madureces**. Un reclutador que llegue desde LinkedIn, desde tu Profile README, o directamente al repositorio verá la evolución profesional documentada y coherente con tu posicionamiento actual. El arco narrativo ITSM → SSC/Business Operations queda cerrado.
