CREATE OR ALTER TRIGGER dominio.tr_HistoricoCliente
ON dominio.Facturas
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    -- Tabla temporal para consolidar cambios
    DECLARE @Cambios TABLE (
        ClienteId INT,
        Periodo   DATE
    );

    -- INSERTED (nuevos registros)
    INSERT INTO @Cambios (ClienteId, Periodo)
    SELECT ClienteId, CAST(Fecha AS DATE)
    FROM inserted;

    -- DELETED (registros antiguos modificados o eliminados)
    INSERT INTO @Cambios (ClienteId, Periodo)
    SELECT ClienteId, CAST(Fecha AS DATE)
    FROM deleted;

    -- Eliminar duplicados
    WITH CambiosUnicos AS (
        SELECT DISTINCT ClienteId, Periodo FROM @Cambios
    )
    MERGE reportes.HistoricoCliente AS target
    USING (
        SELECT 
            f.ClienteId,
            CAST(f.Fecha AS DATE) AS Periodo,
            SUM(f.Total) AS TotalFacturado,
            COUNT(*) AS CantidadFacturas
        FROM dominio.Facturas f
        INNER JOIN CambiosUnicos cu ON cu.ClienteId = f.ClienteId AND CAST(f.Fecha AS DATE) = cu.Periodo
        WHERE f.Activo = 1
        GROUP BY f.ClienteId, CAST(f.Fecha AS DATE)
    ) AS source
    ON target.ClienteId = source.ClienteId AND target.Periodo = source.Periodo
    WHEN MATCHED THEN
        UPDATE SET 
            TotalFacturado = source.TotalFacturado,
            CantidadFacturas = source.CantidadFacturas
    WHEN NOT MATCHED BY TARGET THEN
        INSERT (ClienteId, Periodo, TotalFacturado, CantidadFacturas)
        VALUES (source.ClienteId, source.Periodo, source.TotalFacturado, source.CantidadFacturas)
    WHEN NOT MATCHED BY SOURCE AND target.ClienteId IN (SELECT ClienteId FROM CambiosUnicos) THEN
        DELETE;
END;
GO

CREATE OR ALTER TRIGGER dominio.tr_HistoricoUsuario
ON dominio.Facturas
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Cambios TABLE (
        UsuarioId INT,
        Periodo   DATE
    );

    -- INSERTED
    INSERT INTO @Cambios (UsuarioId, Periodo)
    SELECT IdUsuarioCrea, CAST(Fecha AS DATE)
    FROM inserted;

    -- DELETED
    INSERT INTO @Cambios (UsuarioId, Periodo)
    SELECT IdUsuarioCrea, CAST(Fecha AS DATE)
    FROM deleted;

    WITH CambiosUnicos AS (
        SELECT DISTINCT UsuarioId, Periodo FROM @Cambios
    )
    MERGE reportes.HistoricoUsuario AS target
    USING (
        SELECT 
            f.IdUsuarioCrea AS UsuarioId,
            CAST(f.Fecha AS DATE) AS Periodo,
            COUNT(*) AS CantidadFacturas
        FROM dominio.Facturas f
        INNER JOIN CambiosUnicos cu ON cu.UsuarioId = f.IdUsuarioCrea AND CAST(f.Fecha AS DATE) = cu.Periodo
        WHERE f.Activo = 1
        GROUP BY f.IdUsuarioCrea, CAST(f.Fecha AS DATE)
    ) AS source
    ON target.UsuarioId = source.UsuarioId AND target.Periodo = source.Periodo
    WHEN MATCHED THEN
        UPDATE SET 
            CantidadFacturas = source.CantidadFacturas
    WHEN NOT MATCHED BY TARGET THEN
        INSERT (UsuarioId, Periodo, CantidadFacturas)
        VALUES (source.UsuarioId, source.Periodo, source.CantidadFacturas)
    WHEN NOT MATCHED BY SOURCE AND target.UsuarioId IN (SELECT UsuarioId FROM CambiosUnicos) THEN
        DELETE;
END;
GO
