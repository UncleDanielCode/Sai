-- ==================================================
-- TRIGGER: Auditoría de CREACIÓN de facturas
-- ==================================================
CREATE OR ALTER TRIGGER dominio.tr_Facturas_Insert
ON dominio.Facturas
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO auditoria.AuditoriaFacturas
        (FacturaId, UsuarioId, Accion, Campo, ValorAnterior, ValorNuevo, Contexto)
    SELECT
        i.FacturaId,
        -- Si no hay UserId en SESSION_CONTEXT, usamos el que haya dejado el SP en IdUsuarioCrea
        COALESCE(
          TRY_CAST(SESSION_CONTEXT(N'UsuarioId') AS INT),
          i.IdUsuarioCrea
        ) AS UsuarioId,
        'Creación',
        NULL,
        NULL,
        j.JsonNuevo,
        HOST_NAME() + ' | ' + APP_NAME()
    FROM inserted AS i
    CROSS APPLY (
        SELECT
            i.FacturaId,
            i.ClienteId,
            i.Fecha,
            i.Total,
            i.Activo,
            i.Estado,
            i.IdUsuarioCrea,
            i.FechaCrea,
            i.IdUsuarioModifica,
            i.FechaModifica
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
    ) AS j(JsonNuevo);
END;
GO

-- ==================================================
-- TRIGGER: Auditoría de MODIFICACIÓN de facturas
-- ==================================================
CREATE OR ALTER TRIGGER dominio.tr_Facturas_Update
ON dominio.Facturas
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO auditoria.AuditoriaFacturas
        (FacturaId, UsuarioId, Accion, Campo, ValorAnterior, ValorNuevo, Contexto)
    SELECT
        i.FacturaId,
        -- Prefiere el UserId de SESSION_CONTEXT, si no toma el IdUsuarioModifica o, de último recurso, el IdUsuarioCrea
        COALESCE(
          TRY_CAST(SESSION_CONTEXT(N'UsuarioId') AS INT),
          i.IdUsuarioModifica,
          i.IdUsuarioCrea
        ) AS UsuarioId,
        'Modificación',
        NULL,
        prev.JsonAnterior,
        curr.JsonNuevo,
        HOST_NAME() + ' | ' + APP_NAME()
    FROM inserted AS i
    INNER JOIN deleted  AS d
        ON d.FacturaId = i.FacturaId
    CROSS APPLY (
        SELECT
            d.FacturaId,
            d.ClienteId,
            d.Fecha,
            d.Total,
            d.Activo,
            d.Estado,
            d.IdUsuarioCrea,
            d.FechaCrea,
            d.IdUsuarioModifica,
            d.FechaModifica
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
    ) AS prev(JsonAnterior)
    CROSS APPLY (
        SELECT
            i.FacturaId,
            i.ClienteId,
            i.Fecha,
            i.Total,
            i.Activo,
            i.Estado,
            i.IdUsuarioCrea,
            i.FechaCrea,
            i.IdUsuarioModifica,
            i.FechaModifica
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
    ) AS curr(JsonNuevo);
END;
GO

-- ==================================================
-- TRIGGER: Auditoría de ELIMINACIÓN de facturas
-- ==================================================
CREATE OR ALTER TRIGGER dominio.tr_Facturas_Delete
ON dominio.Facturas
AFTER DELETE
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO auditoria.AuditoriaFacturas
        (FacturaId, UsuarioId, Accion, Campo, ValorAnterior, ValorNuevo, Contexto)
    SELECT
        d.FacturaId,
        -- Al eliminar, puede no haber IdUsuarioModifica, así que tratamos igual
        COALESCE(
          TRY_CAST(SESSION_CONTEXT(N'UsuarioId') AS INT),
          d.IdUsuarioModifica,
          d.IdUsuarioCrea
        ) AS UsuarioId,
        'Eliminación',
        NULL,
        j.JsonAnterior,
        NULL,
        HOST_NAME() + ' | ' + APP_NAME()
    FROM deleted AS d
    CROSS APPLY (
        SELECT
            d.FacturaId,
            d.ClienteId,
            d.Fecha,
            d.Total,
            d.Activo,
            d.Estado,
            d.IdUsuarioCrea,
            d.FechaCrea,
            d.IdUsuarioModifica,
            d.FechaModifica
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
    ) AS j(JsonAnterior);
END;
GO
