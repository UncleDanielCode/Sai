CREATE OR ALTER PROCEDURE reportes.GET_FacturasAuditadas
    @Accion         NVARCHAR(20) = NULL,      -- 'Creación', 'Modificación', 'Eliminación'
    @ClienteNombre  NVARCHAR(100) = NULL,
    @UsuarioNombre  NVARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        af.AuditoriaId,
        af.FechaHora,
        af.Accion,
        af.FacturaId,
        f.Fecha AS FechaFactura,
        f.Total,
        f.Estado,
        c.ClienteId,
        c.Nombre AS ClienteNombre,
        u.UsuarioId,
        u.Nombre AS UsuarioNombre,
        af.ValorAnterior,
        af.ValorNuevo,
        af.Contexto
    FROM auditoria.AuditoriaFacturas af
    INNER JOIN dominio.Facturas     f ON f.FacturaId  = af.FacturaId
    INNER JOIN dominio.Clientes     c ON c.ClienteId  = f.ClienteId
    INNER JOIN dominio.Usuarios     u ON u.UsuarioId  = af.UsuarioId
    WHERE (@Accion IS NULL OR af.Accion = @Accion)
      AND (@ClienteNombre IS NULL OR c.Nombre LIKE '%' + @ClienteNombre + '%')
      AND (@UsuarioNombre IS NULL OR u.Nombre LIKE '%' + @UsuarioNombre + '%')
    ORDER BY af.FechaHora DESC;
END;
GO

CREATE OR ALTER PROCEDURE reportes.GET_HistoricoClientes
    @ClienteNombre  NVARCHAR(100) = NULL,
    @Periodo        DATE           = NULL     -- opcional, formato YYYY-MM-DD
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        hc.ClienteId,
        c.Nombre AS ClienteNombre,
        hc.Periodo,
        hc.TotalFacturado,
        hc.CantidadFacturas
    FROM reportes.HistoricoCliente hc
    INNER JOIN dominio.Clientes    c ON c.ClienteId = hc.ClienteId
    WHERE (@ClienteNombre IS NULL OR c.Nombre LIKE '%' + @ClienteNombre + '%')
      AND (@Periodo IS NULL OR hc.Periodo = @Periodo)
    ORDER BY hc.Periodo DESC;
END;
GO

CREATE OR ALTER PROCEDURE reportes.GET_HistoricoUsuarios
    @UsuarioNombre  NVARCHAR(100) = NULL,
    @Periodo        DATE           = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        hu.UsuarioId,
        u.Nombre AS UsuarioNombre,
        hu.Periodo,
        hu.CantidadFacturas
    FROM reportes.HistoricoUsuario hu
    INNER JOIN dominio.Usuarios    u ON u.UsuarioId = hu.UsuarioId
    WHERE (@UsuarioNombre IS NULL OR u.Nombre LIKE '%' + @UsuarioNombre + '%')
      AND (@Periodo IS NULL OR hu.Periodo = @Periodo)
    ORDER BY hu.Periodo DESC;
END;
GO

-- Todas las acciones realizadas por el usuario "Juan"
EXEC reportes.GET_FacturasAuditadas @UsuarioNombre = 'Laura Sánchez';

-- Histórico de cliente "Bravo"
EXEC reportes.GET_HistoricoClientes @ClienteNombre = 'Bravo';

-- Facturación de usuarios en abril 2025
EXEC reportes.GET_HistoricoUsuarios @Periodo = '2025-04-01';
