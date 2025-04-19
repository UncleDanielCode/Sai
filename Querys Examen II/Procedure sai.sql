-- ================================================
-- 1. SP PARA USUARIOS
-- ================================================
CREATE OR ALTER PROCEDURE dominio.SET_Usuario
(
    @Id                 INT             = NULL,      -- Si es NULL, inserta; si no, actualiza
    @Nombre             NVARCHAR(100)   = NULL,
    @Rol                NVARCHAR(50)    = NULL,
    @Email              NVARCHAR(255)   = NULL,
    @Estado             CHAR(2)         = NULL,      -- p.ej. 'AC'/'IN'
    @Activo             BIT             = NULL,      -- p.ej. 1=vigente, 0=borrado lógico
    @IdUsuarioCrea      INT                             -- quien crea o modifica
)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        -- Inserción
        IF @Id IS NULL
        BEGIN
            INSERT INTO dominio.Usuarios
                (Nombre, Rol, Email, Estado, Activo, IdUsuarioCrea, FechaCrea)
            VALUES
                (@Nombre,
                 @Rol,
                 @Email,
                 ISNULL(@Estado, 'AC'),
                 ISNULL(@Activo, 1),
                 @IdUsuarioCrea,
                 GETDATE()
                );
            DECLARE @NewId INT = SCOPE_IDENTITY();
            SELECT @NewId AS Id, 'Inserted' AS Result;
            RETURN;
        END

        -- Actualización
        IF EXISTS (SELECT 1 FROM dominio.Usuarios WHERE UsuarioId = @Id)
        BEGIN
            UPDATE dominio.Usuarios
            SET 
                Nombre            = ISNULL(@Nombre, Nombre),
                Rol               = ISNULL(@Rol, Rol),
                Email             = ISNULL(@Email, Email),
                Estado            = ISNULL(@Estado, Estado),
                Activo            = ISNULL(@Activo, Activo),
                IdUsuarioModifica = @IdUsuarioCrea,
                FechaModifica     = GETDATE()
            WHERE UsuarioId = @Id;
            
            SELECT @Id AS Id, 'Updated' AS Result;
            RETURN;
        END

        -- No existe
        SELECT 0 AS Id, 'Not Found' AS Result;
    END TRY
    BEGIN CATCH
        DECLARE 
            @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE(),
            @ErrorSeverity INT         = ERROR_SEVERITY(),
            @ErrorState    INT         = ERROR_STATE();
        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END;
GO


-- ================================================
-- 2. SP PARA CLIENTES
-- ================================================
CREATE OR ALTER PROCEDURE dominio.SET_Cliente
(
    @Id                 INT             = NULL,      -- Si es NULL, inserta; si no, actualiza
    @Nombre             NVARCHAR(100)   = NULL,
    @Email              NVARCHAR(255)   = NULL,
    @Telefono           NVARCHAR(50)    = NULL,
    @Direccion          NVARCHAR(255)   = NULL,
    @Estado             CHAR(2)         = NULL,      -- p.ej. 'AC'/'IN'
    @Activo             BIT             = NULL,      -- p.ej. 1=vigente, 0=borrado lógico
    @IdUsuarioCrea      INT                             -- quien crea o modifica
)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        -- Inserción
        IF @Id IS NULL
        BEGIN
            INSERT INTO dominio.Clientes
                (Nombre, Email, Telefono, Direccion, Estado, Activo, IdUsuarioCrea, FechaCrea)
            VALUES
                (@Nombre,
                 @Email,
                 @Telefono,
                 @Direccion,
                 ISNULL(@Estado, 'AC'),
                 ISNULL(@Activo, 1),
                 @IdUsuarioCrea,
                 GETDATE()
                );
            DECLARE @NewId INT = SCOPE_IDENTITY();
            SELECT @NewId AS Id, 'Inserted' AS Result;
            RETURN;
        END

        -- Actualización
        IF EXISTS (SELECT 1 FROM dominio.Clientes WHERE ClienteId = @Id)
        BEGIN
            UPDATE dominio.Clientes
            SET 
                Nombre            = ISNULL(@Nombre, Nombre),
                Email             = ISNULL(@Email, Email),
                Telefono          = ISNULL(@Telefono, Telefono),
                Direccion         = ISNULL(@Direccion, Direccion),
                Estado            = ISNULL(@Estado, Estado),
                Activo            = ISNULL(@Activo, Activo),
                IdUsuarioModifica = @IdUsuarioCrea,
                FechaModifica     = GETDATE()
            WHERE ClienteId = @Id;
            
            SELECT @Id AS Id, 'Updated' AS Result;
            RETURN;
        END

        -- No existe
        SELECT 0 AS Id, 'Not Found' AS Result;
    END TRY
    BEGIN CATCH
        DECLARE 
            @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE(),
            @ErrorSeverity INT         = ERROR_SEVERITY(),
            @ErrorState    INT         = ERROR_STATE();
        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END;
GO
-- ================================================
-- 3. SP PARA Factura
-- ================================================
CREATE OR ALTER PROCEDURE dominio.SET_Factura
(
    @Id               INT             = NULL,      -- NULL = insert, otherwise update
    @ClienteId        INT             = NULL,
    @Total            DECIMAL(18,2)   = NULL,
    @Estado           CHAR(2)         = NULL,      -- p.ej. 'PE','PG','AN'
    @Activo           BIT             = NULL,      -- 1=vigente, 0=borrado lógico
    @IdUsuarioCrea    INT                          -- quien crea o modifica
)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        -------------------------------------------------
        -- Validaciones generales
        -------------------------------------------------
        -- Para INSERT: ClienteId y Total son obligatorios
        IF @Id IS NULL
            AND (@ClienteId IS NULL OR @Total IS NULL)
        BEGIN
            RAISERROR('Para inserción, ClienteId y Total son requeridos.',16,1);
            RETURN;
        END

        -- Validar que el cliente exista (si se pasó)
        IF @ClienteId IS NOT NULL
            AND NOT EXISTS (SELECT 1 FROM dominio.Clientes WHERE ClienteId = @ClienteId)
        BEGIN
            RAISERROR('ClienteId %d no encontrado.',16,1,@ClienteId);
            RETURN;
        END

        -- Validar que el usuario exista
        IF NOT EXISTS (SELECT 1 FROM dominio.Usuarios WHERE UsuarioId = @IdUsuarioCrea)
        BEGIN
            RAISERROR('UsuarioId %d no encontrado.',16,1,@IdUsuarioCrea);
            RETURN;
        END

        -- Validar código de Estado en catálogo
        IF @Estado IS NOT NULL
            AND NOT EXISTS (
                SELECT 1
                FROM dominio.DetalleEstados
                WHERE Tabla  = 'Facturas'
                  AND Estado = @Estado
            )
        BEGIN
            RAISERROR('Código de Estado ''%s'' no válido para Facturas.',16,1,@Estado);
            RETURN;
        END

        -------------------------------------------------
        -- Inserción
        -------------------------------------------------
        IF @Id IS NULL
        BEGIN
            INSERT INTO dominio.Facturas
                (ClienteId, Fecha, Total, Estado, Activo, IdUsuarioCrea, FechaCrea)
            VALUES
                (
                    @ClienteId,
                    SYSUTCDATETIME(),
                    @Total,
                    ISNULL(@Estado, 'PE'),
                    ISNULL(@Activo, 1),
                    @IdUsuarioCrea,
                    SYSUTCDATETIME()
                );

            DECLARE @NewId INT = SCOPE_IDENTITY();
            SELECT @NewId AS Id, 'Inserted' AS Result;
            RETURN;
        END

        -------------------------------------------------
        -- Actualización
        -------------------------------------------------
        IF EXISTS (SELECT 1 FROM dominio.Facturas WHERE FacturaId = @Id)
        BEGIN
            UPDATE dominio.Facturas
            SET
                ClienteId        = ISNULL(@ClienteId, ClienteId),
                Total            = ISNULL(@Total, Total),
                Estado           = ISNULL(@Estado, Estado),
                Activo           = ISNULL(@Activo, Activo),
                IdUsuarioModifica= @IdUsuarioCrea,
                FechaModifica    = SYSUTCDATETIME()
            WHERE FacturaId = @Id;

            SELECT @Id AS Id, 'Updated' AS Result;
            RETURN;
        END

        -------------------------------------------------
        -- No encontrado
        -------------------------------------------------
        SELECT 0 AS Id, 'Not Found' AS Result;
    END TRY
    BEGIN CATCH
        DECLARE 
            @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE(),
            @ErrorSeverity INT         = ERROR_SEVERITY(),
            @ErrorState    INT         = ERROR_STATE();
        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END;
GO
