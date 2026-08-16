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

```text
┌─────────────────────────────────────────────────────────────────┐
│                    SINCRONIZACIÓN BIDIRECCIONAL                 │
└─────────────────────────────────────────────────────────────────┘

┌──────────────────────┐      ┌──────────────────────┐
│   MYSQL SERVER       │      │   JIRA CLOUD         │
│   (clorian_db)       │      │   (Proyecto KAN)     │
│                      │      │                      │
│  • SupportTickets    │◄─────│  • Issues            │
│  • Customers         │  (2) │  • Workflows         │
│                      │      │  • Estados           │
└─────────────────────┘      └──────────▲───────────┘
           │                             │
          (1)                (2) Webhook (tiempo real)
           │                             │
           ▼                             │
┌──────────────────────┐      ┌──────────┴───────────┐
│  CLORIAN DB          │      │  JIRA WEBHOOK        │
│  CONNECTOR           │      │  RECEIVER            │
│                      │      │                      │
│  • Polling cada 30s  │      │  • HTTP POST endpoint│
│  • MySQL → Jira      │      │  • Jira → MySQL      │
│  • Creación de issues│      │  • Actualización     │
│  • Sync de estados   │      │    inmediata         │
└──────────────────────┘      └──────────────────────┘
```

[Clorian DB Connector](https://github.com/jaime-urrutia-it/clorian-db-connector) · [Jira Webhook Receiver](https://github.com/jaime-urrutia-it/jira-webhook-receiver)

### Componentes del Ecosistema

| Componente | Rol | Dirección | Método | Latencia | Stack Técnico |
|---|---|---|---|---|---|
| [Clorian DB Connector](https://github.com/jaime-urrutia-it/clorian-db-connector) | Emisor | MySQL → Jira | REST API + Polling | ~30s (Standalone) / Creación única (Integrado) | Java 17+, JDBC, HttpClient, org.json |
| [Jira Webhook Receiver](https://github.com/jaime-urrutia-it/jira-webhook-receiver) | Receptor | Jira → MySQL | HTTP Webhook | < 1 segundo (tiempo real) | Spring Boot 3.3.3, Maven, MySQL Connector/J |

---

## 🚀 Flujo de Trabajo Completo

### 1. Creación de Ticket (MySQL → Jira)

```text
Usuario crea ticket en MySQL
↓
Clorian DB Connector detecta (polling 30s)
↓
Crea issue en Jira
↓
Actualiza jira_issue_key en MySQL
```

### 2. Actualización de Estado (Jira → MySQL)

```text
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
