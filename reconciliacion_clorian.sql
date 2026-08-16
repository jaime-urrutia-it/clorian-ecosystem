-- =====================================================================
-- CLORIAN 2.0 — Business Operations: Conciliación Booking-Payment-Ticket
-- =====================================================================
-- Autor: Jaime Urrutia
-- Objetivo: pasar de "sincronizar tickets de soporte con Jira" (ITSM)
-- a "controlar un proceso de negocio Order-to-Cash" (Business Ops/SSC).
--
-- Regla de negocio (la defines TÚ, no la base de datos):
--   Toda reserva confirmada debe tener:
--     1) el importe cobrado (payments - refunds) igual al total reservado
--     2) el importe de tickets emitidos igual al total reservado
--   Si no se cumple, es una EXCEPCIÓN que debe resolverse en 48h (SLA).
-- =====================================================================


-- ---------------------------------------------------------------------
-- VISTA 1: three-way match (Booking vs Payment vs Ticket)
-- Compara lo reservado, lo cobrado (neto de reembolsos) y lo entregado.
-- ---------------------------------------------------------------------
CREATE OR REPLACE VIEW v_booking_reconciliation AS
SELECT
    b.booking_id,
    b.customer_id,
    b.booking_date,
    b.total_price                                                    AS importe_reservado,
    COALESCE(p.pagado, 0)                                             AS importe_cobrado,
    COALESCE(r.reembolsado, 0)                                        AS importe_reembolsado,
    COALESCE(p.pagado, 0) - COALESCE(r.reembolsado, 0)                AS importe_neto_cobrado,
    COALESCE(t.num_tickets, 0)                                        AS tickets_emitidos,
    COALESCE(t.importe_tickets, 0)                                    AS importe_entregado,
    b.total_price - (COALESCE(p.pagado, 0) - COALESCE(r.reembolsado, 0)) AS gap_cobro,
    b.total_price - COALESCE(t.importe_tickets, 0)                    AS gap_entrega,
    TIMESTAMPDIFF(HOUR, b.booking_date, NOW())                        AS horas_desde_reserva
FROM bookings b
LEFT JOIN (
    SELECT booking_id, SUM(amount) AS pagado
    FROM payments
    WHERE status = 'completed'
    GROUP BY booking_id
) p ON p.booking_id = b.booking_id
LEFT JOIN (
    SELECT booking_id, SUM(amount) AS reembolsado
    FROM refunds
    WHERE status = 'completed'
    GROUP BY booking_id
) r ON r.booking_id = b.booking_id
LEFT JOIN (
    SELECT booking_id, COUNT(*) AS num_tickets, SUM(price) AS importe_tickets
    FROM tickets
    GROUP BY booking_id
) t ON t.booking_id = b.booking_id
WHERE b.status = 'confirmed';


-- ---------------------------------------------------------------------
-- VISTA 2: clasificación por severidad + estado de SLA
-- Solo muestra reservas con gap real (excluye las que cuadran, gap=0).
-- Severidad = la mayor de las dos desviaciones (cobro o entrega),
-- ponderada también por cuánto tiempo lleva abierta la excepción.
-- ---------------------------------------------------------------------
CREATE OR REPLACE VIEW v_booking_exceptions AS
SELECT
    v.*,
    GREATEST(ABS(gap_cobro), ABS(gap_entrega)) AS gap_max,
    CASE
        WHEN GREATEST(ABS(gap_cobro), ABS(gap_entrega)) >= 200 OR horas_desde_reserva > 48 THEN 'CRITICA'
        WHEN GREATEST(ABS(gap_cobro), ABS(gap_entrega)) >= 50  OR horas_desde_reserva > 24 THEN 'ALTA'
        ELSE 'MEDIA'
    END AS severidad,
    CASE
        WHEN horas_desde_reserva > 48 THEN 'SLA INCUMPLIDO'
        ELSE 'DENTRO DE SLA'
    END AS estado_sla
FROM v_booking_reconciliation v
WHERE GREATEST(ABS(gap_cobro), ABS(gap_entrega)) > 0.01
ORDER BY gap_max DESC;


-- ---------------------------------------------------------------------
-- CONSULTA 3a: resumen ejecutivo por severidad (para stakeholder)
-- Esto es lo que enseñas en pantalla, NO la vista completa de excepciones.
-- ---------------------------------------------------------------------
SELECT
    severidad,
    COUNT(*)                            AS num_excepciones,
    ROUND(SUM(gap_max), 2)              AS importe_en_riesgo_eur,
    ROUND(AVG(horas_desde_reserva), 1)  AS horas_media_abierta,
    SUM(CASE WHEN estado_sla = 'SLA INCUMPLIDO' THEN 1 ELSE 0 END) AS incumplimientos_sla
FROM v_booking_exceptions
GROUP BY severidad
ORDER BY FIELD(severidad, 'CRITICA', 'ALTA', 'MEDIA');


-- ---------------------------------------------------------------------
-- CONSULTA 3b: tendencia semana actual vs semana anterior
-- Responde la pregunta que hará cualquier stakeholder: "¿vamos mejor o
-- peor que la semana pasada?"
-- ---------------------------------------------------------------------
SELECT
    CASE
        WHEN booking_date >= CURDATE() - INTERVAL 7 DAY  THEN 'Esta semana'
        WHEN booking_date >= CURDATE() - INTERVAL 14 DAY THEN 'Semana anterior'
    END AS periodo,
    COUNT(*)                                                   AS excepciones,
    ROUND(SUM(GREATEST(ABS(gap_cobro), ABS(gap_entrega))), 2)  AS importe_en_riesgo_eur
FROM v_booking_reconciliation
WHERE booking_date >= CURDATE() - INTERVAL 14 DAY
  AND GREATEST(ABS(gap_cobro), ABS(gap_entrega)) > 0.01
GROUP BY periodo;


-- ---------------------------------------------------------------------
-- CONSULTA 3c: top 5 excepciones críticas (el detalle que respalda el
-- resumen, por si el stakeholder pregunta "¿cuáles en concreto?")
-- ---------------------------------------------------------------------
SELECT
    booking_id,
    booking_date,
    importe_reservado,
    gap_cobro,
    gap_entrega,
    severidad,
    estado_sla,
    horas_desde_reserva
FROM v_booking_exceptions
WHERE severidad = 'CRITICA'
ORDER BY gap_max DESC
LIMIT 5;
