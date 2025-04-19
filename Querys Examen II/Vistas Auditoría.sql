-- ==================================================
-- 1. VISTA: Auditoría completa de facturas
-- ==================================================
CREATE OR ALTER VIEW reportes.vw_AuditoriaFacturas AS
SELECT
    af.AuditoriaId,
    af.FechaHora,
    af.Accion,
    af.FacturaId,
    f.ClienteId,
    c.Nombre       AS ClienteNombre,
    af.UsuarioId,
    u.Nombre       AS UsuarioNombre,
    af.Campo,
    af.ValorAnterior,
    af.ValorNuevo,
    af.Contexto
FROM auditoria.AuditoriaFacturas AS af
INNER JOIN dominio.Facturas        AS f ON af.FacturaId = f.FacturaId
INNER JOIN dominio.Clientes        AS c ON f.ClienteId  = c.ClienteId
INNER JOIN dominio.Usuarios        AS u ON af.UsuarioId = u.UsuarioId;
GO

-- ==================================================
-- 2. VISTA: Histórico de facturación por cliente
-- ==================================================
CREATE OR ALTER VIEW reportes.vw_HistoricoCliente AS
SELECT
    rc.ClienteId,
    c.Nombre       AS ClienteNombre,
    rc.Periodo,
    rc.TotalFacturado,
    rc.CantidadFacturas
FROM reportes.HistoricoCliente AS rc
INNER JOIN dominio.Clientes      AS c ON rc.ClienteId = c.ClienteId;
GO

-- ==================================================
-- 3. VISTA: Histórico de facturación por usuario
-- ==================================================
CREATE OR ALTER VIEW reportes.vw_HistoricoUsuario AS
SELECT
    ru.UsuarioId,
    u.Nombre       AS UsuarioNombre,
    ru.Periodo,
    ru.CantidadFacturas
FROM reportes.HistoricoUsuario AS ru
INNER JOIN dominio.Usuarios     AS u ON ru.UsuarioId = u.UsuarioId;
GO
