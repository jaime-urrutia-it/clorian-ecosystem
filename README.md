# 🔄 Clorian Ecosystem - Arquitectura de Sincronización Bidireccional ITSM

> **Arquitectura enterprise para sincronización MySQL ↔ Jira Cloud**  
> Desarrollado como parte de un proyecto de recualificación técnica en ITSM (IT Service Management)

[![Java](https://img.shields.io/badge/Java-17+-blue.svg)](https://www.java.com)
[![Spring Boot](https://img.shields.io/badge/Spring%20Boot-3.3.3-brightgreen.svg)](https://spring.io/projects/spring-boot)
[![Jira](https://img.shields.io/badge/Jira-Cloud%2FServer-0052CC.svg)](https://www.atlassian.com/software/jira)
[![MySQL](https://img.shields.io/badge/MySQL-5.7+-4479A1.svg)](https://www.mysql.com)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

---

## 🎯 Propósito del Ecosistema

Este ecosistema demuestra una **arquitectura de integración bidireccional** entre un sistema de gestión de tickets (Jira) y una base de datos MySQL, aplicando principios de **ITIL v4** para la gestión de incidencias.

### **Caso de Uso Empresarial**
Sincronización automática entre:
- **Base de datos de clientes** (MySQL) → Tickets de soporte internos
- **Jira Cloud/Server** → Gestión ágil de incidencias técnicas

**Resultado**: Trazabilidad completa entre el departamento de soporte técnico y el equipo de desarrollo/operaciones.

---

## 🏗️ Arquitectura del Sistema
```
┌─────────────────────────────────────────────────────────────────┐
│ SINCRONIZACIÓN BIDIRECCIONAL │
└─────────────────────────────────────────────────────────────────┘
┌──────────────────────┐ ┌──────────────────────┐
│ MYSQL SERVER │ │ JIRA CLOUD │
│ (clorian_db) │ │ (Proyecto KAN) │
│ │ │ │
│ • SupportTickets │◄───────(2)───────────────│ • Issues │
│ • Customers │ Webhook (Tiempo real) │ • Workflows │
│ │ │ • Estados │
└──────────┬───────────┘ └──────────▲───────────┘
│ │
│(1) │
│ │
▼ │
┌──────────────────────┐ ┌──────────┴───────────┐
│ CLORIAN DB │ │ JIRA WEBHOOK │
│ CONNECTOR │ │ RECEIVER │
│ (Emisor) │ │ (Receptor) │
│ │ │ │
│ • Polling cada 30s │ │ • HTTP POST endpoint │
│ • MySQL → Jira │ │ • Jira → MySQL │
│ • Creación de issues │ │ • Actualización │
│ • Sync de estados │ │ inmediata │
│ │ │ │
│ [Ver Repo] │ │ [Ver Repo] │
└──────────────────────┘ └──────────────────────┘
```
### **Componentes del Ecosistema**

| Componente | Rol | Dirección | Método | Latencia |
|------------|-----|-----------|--------|----------|
| **[Clorian DB Connector]** | Emisor | MySQL → Jira | REST API + Polling | ~30 segundos |
| **[Jira Webhook Receiver]** | Receptor | Jira → MySQL | HTTP Webhook | < 1 segundo (tiempo real) |

---

## 🚀 Flujo de Trabajo Completo

### **1. Creación de Ticket (MySQL → Jira)**

Usuario crea ticket en MySQL
↓
Clorian DB Connector detecta (polling 30s)
↓
Crea issue automático en Jira
↓
Actualiza jira_issue_key en MySQL

### **2. Actualización de Estado (Jira → MySQL)**

Usuario cambia estado en Jira
↓
Jira dispara webhook HTTP POST
↓
Jira Webhook Receiver procesa
↓
Actualiza status en MySQL inmediatamente

### **3. Prevención de Ciclos Infinitos**

✓ Campo last_sync_status evita bucles
✓ Comparación de estados antes de sincronizar
✓ Idempotencia garantizada

---

## 📦 Proyectos Individuales

### 🔵 Clorian DB Connector (Emisor)
**Responsabilidad**: Enviar datos desde MySQL hacia Jira

- ✅ Detección de nuevos tickets de soporte (`status='Open'`)
- ✅ Creación automática de issues en Jira vía REST API
- ✅ Sincronización de estados cada 30s (polling)
- ✅ Mapeo de prioridades y campos personalizados

**Stack Técnico**: Java 17+, JDBC, HTTP Client, org.json

🔗 **[Ver documentación completa →](https://github.com/jaime-urrutia-it/clorian-db-connector)**

---

### 🟢 Jira Webhook Receiver (Receptor)
**Responsabilidad**: Recibir actualizaciones de Jira en tiempo real

- ✅ Endpoint HTTP `/api/jira-webhook` (Spring Boot)
- ✅ Procesamiento asíncrono (respuesta < 100ms)
- ✅ Actualización inmediata de MySQL
- ✅ Soporte para eventos: `issue_created`, `issue_updated`

**Stack Técnico**: Spring Boot 3.3.3, Maven, MySQL Connector/J

🔗 **[Ver documentación completa →](https://github.com/jaime-urrutia-it/jira-webhook-receiver)**

---

## 🎓 Contexto del Proyecto

### **Propósito Educativo**
Este ecosistema fue desarrollado como parte de un **proyecto de recualificación técnica** hacia roles de:
- IT Service Coordinator
- Customer Success Technical
- Technical Account Manager

### **Competencias Demostradas**
✅ **Arquitecturas de integración** enterprise (Java/MySQL/Jira)  
✅ **Aplicación de ITIL v4** a flujos reales de incidencia  
✅ **Coordinación negocio-tecnología** mediante automatización  
✅ **Aprendizaje estructurado** con IA asistida + validación manual  

---

## 🎬 Demo Visual

> **Próximamente**: Video demostrativo de la sincronización bidireccional en acción

[![Demo Video Placeholder](https://img.shields.io/badge/🎬_Demo-Próximamente-red?style=for-the-badge)]()

**Lo que verás en el video**:
1. Creación de ticket en MySQL → Aparición automática en Jira (~30s)
2. Cambio de estado en Jira → Actualización inmediata en MySQL (<1s)
3. Logs de ambos servicios en tiempo real
4. Consultas SQL de verificación

---

## 📊 Métricas Técnicas

| Métrica | Valor |
|---------|-------|
| **Latencia Emisor** | ~30 segundos (polling configurable) |
| **Latencia Receptor** | < 1 segundo (webhook tiempo real) |
| **Trazabilidad** | 100% de tickets sincronizados |
| **Prevención de Bucles** | Implementada vía `last_sync_status` |
| **Disponibilidad** | 24/7 (servicios standalone) |

---

## 🛠 Instalación Rápida

### Prerrequisitos
```bash
• Java JDK 17+
• MySQL Server 5.7+
• Jira Cloud/Server (con permisos de admin)
• Maven 3.8+

# 1. Clonar ambos proyectos
git clone https://github.com/jaime-urrutia-it/clorian-db-connector.git
git clone https://github.com/jaime-urrutia-it/jira-webhook-receiver.git

# 2. Configurar base de datos (ver READMEs individuales)
mysql -u root -p < schema.sql

# 3. Compilar
cd clorian-db-connector && mvn clean package
cd ../jira-webhook-receiver && mvn clean package

# 4. Ejecutar (en terminales separadas)
java -jar clorian-db-connector/target/ClorianDBConnector-1.0.0.jar
java -jar jira-webhook-receiver/target/JiraWebhookReceiver-1.0.0.jar

# 5. Configurar webhook en Jira (ver documentación)
# URL: http://localhost:8080/api/jira-webhook

📖 Para instrucciones detalladas, consulta los READMEs de cada proyecto.

🔐 Consideraciones de Seguridad Implementadas

✅ PreparedStatement (prevención SQL Injection)
✅ Conexiones JDBC con try-with-resources
✅ Credenciales externalizables (variables de entorno)

Recomendadas para Producción

⚠️ Validación de firma HMAC-SHA256 en webhooks
⚠️ HTTPS obligatorio (certificado SSL)
⚠️ Whitelist de IPs de Atlassian
⚠️ Autenticación Basic/Bearer token
⚠️ Rate limiting (prevención DoS)

## ⚠️ Limitaciones Conocidas del MVP (Agosto 2026)

Este proyecto es un MVP de demostración, no un sistema de producción. Las siguientes limitaciones están documentadas intencionalmente como parte del roadmap de maduración:

| Limitación | Impacto | Plan de mitigación |
|---|---|---|
| Endpoint webhook sin autenticación HMAC | Cualquiera podría enviar payloads falsos | Implementar validación HMAC-SHA256 (ver Roadmap) |
| Procesamiento asíncrono con `new Thread()` sin pool | Riesgo bajo carga alta | Migrar a `ExecutorService` con pool controlado |
| UPSERT recursivo en receptor | Posible `StackOverflowError` bajo condiciones extremas | Refactorizar a bucle iterativo |
| Polling cada 30s en modo standalone | Carga innecesaria sobre API de Jira | Aumentar intervalo o migrar a webhook-only |
| Logging por consola (`System.out`) | Sin rotación ni niveles | Migrar a SLF4J + Logback |

**Nota sobre el alcance:** Estas limitaciones están documentadas porque un entorno SSC/Business Operations valora tanto el control de un sistema como la honestidad sobre su estado. La decisión de abordarlas (o aceptarlas como riesgo controlado en un entorno de bajo volumen) corresponde al equipo de operaciones que adopte el proyecto.

📈 Roadmap

Versión 2.0 (Planificada)
API REST propia para gestión de sincronización
Encriptación de credenciales (JKS - Java KeyStore)
Soporte para PostgreSQL además de MySQL
Dockerización oficial (Dockerfile + Docker Compose)
Dashboard web de monitoreo (Spring Boot + Thymeleaf)
Cola de mensajes (RabbitMQ/ActiveMQ)
Logging profesional (SLF4J + Logback)

🤝 Contribución

Este es un proyecto educativo abierto. Si encuentras bugs o tienes sugerencias:
Abre un issue en el repositorio correspondiente
Especifica si es para Emisor o Receptor
Incluye logs relevantes y pasos para reproducir

📄 Licencia
Distribuido bajo licencia MIT. Ver LICENSE para más detalles.

👤 Autor
Jaime (Yago) Urrutia

🔗 GitHub

📧 yurrutiavila@gmail.com

📍 Barcelona, España

Búsqueda activa de oportunidades como:
✅ IT Service Coordinator
✅ Customer Success Technical
✅ Technical Account Manager (Junior)
Idiomas: Español (nativo) • Francés (C1) • Inglés (C1) • Catalán (nativo)

🔗 Enlaces de Interés

📋 Portfolio Completo https://yagourrutia.com/
💼 LinkedIn https://www.linkedin.com/in/jaime-yago-urrutia-multilingue/
📄 CV Actualizado (próximamente)

¿Te ha sido útil este proyecto?
⭐ Dale una estrella • 🍴 Fork • 📢 Compartir
Desarrollado con 💙 como parte de un proceso de aprendizaje estructurado en arquitecturas ITSM

