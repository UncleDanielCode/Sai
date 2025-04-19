-- ==================================================
-- 1. CREAR ESQUEMAS
-- ==================================================
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'dominio')
    EXEC('CREATE SCHEMA dominio');
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'auditoria')
    EXEC('CREATE SCHEMA auditoria');
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'reportes')
    EXEC('CREATE SCHEMA reportes');


-- ==================================================
-- 2. CATÁLOGO DE ESTADOS PARA VARIAS TABLAS
-- ==================================================
CREATE TABLE dominio.DetalleEstados (
    Tabla       NVARCHAR(100)   NOT NULL,      -- nombre de la tabla que usa este estado
    Estado      CHAR(2)         NOT NULL,      -- código de estado, p.ej. 'AC','IN','PE','PG','AN'
    Descripcion NVARCHAR(100)   NOT NULL,      -- texto explicativo
    CONSTRAINT PK_DetalleEstados PRIMARY KEY (Tabla, Estado)
);


-- ==================================================
-- 3. TABLAS DE DOMINIO
-- ==================================================

-- 3.1. Usuarios
CREATE TABLE dominio.Usuarios (
    UsuarioId           INT            IDENTITY(1,1) PRIMARY KEY,
    Nombre              NVARCHAR(100)  NOT NULL,
    Rol                 NVARCHAR(50)   NOT NULL,
    Email               NVARCHAR(255)  NOT NULL UNIQUE,

    -- Auditoría / soft‑delete
    Activo              BIT            NOT NULL DEFAULT 1,  
    IdUsuarioCrea       INT            NOT NULL,
    FechaCrea           DATETIME2(3)   NOT NULL DEFAULT SYSUTCDATETIME(),
    IdUsuarioModifica   INT            NULL,
    FechaModifica       DATETIME2(3)   NULL,

    -- Estado de negocio ('AC'=activo, 'IN'=inactivo)
    Estado              CHAR(2)        NOT NULL DEFAULT 'AC'
);
ALTER TABLE dominio.Usuarios
    ADD CONSTRAINT FK_Usuarios_Creador    FOREIGN KEY (IdUsuarioCrea)     REFERENCES dominio.Usuarios(UsuarioId),
        CONSTRAINT FK_Usuarios_Modificador FOREIGN KEY (IdUsuarioModifica) REFERENCES dominio.Usuarios(UsuarioId);


-- 3.2. Clientes
CREATE TABLE dominio.Clientes (
    ClienteId           INT            IDENTITY(1,1) PRIMARY KEY,
    Nombre              NVARCHAR(100)  NOT NULL,
    Email               NVARCHAR(255)  NULL,
    Telefono            NVARCHAR(50)   NULL,
    Direccion           NVARCHAR(255)  NULL,

    -- Auditoría / soft‑delete
    Activo              BIT            NOT NULL DEFAULT 1,
    IdUsuarioCrea       INT            NOT NULL,
    FechaCrea           DATETIME2(3)   NOT NULL DEFAULT SYSUTCDATETIME(),
    IdUsuarioModifica   INT            NULL,
    FechaModifica       DATETIME2(3)   NULL,

    -- Estado de negocio ('AC'=activo, 'IN'=inactivo)
    Estado              CHAR(2)        NOT NULL DEFAULT 'AC'
);
ALTER TABLE dominio.Clientes
    ADD CONSTRAINT FK_Clientes_Creador    FOREIGN KEY (IdUsuarioCrea)     REFERENCES dominio.Usuarios(UsuarioId),
        CONSTRAINT FK_Clientes_Modificador FOREIGN KEY (IdUsuarioModifica) REFERENCES dominio.Usuarios(UsuarioId);


-- 3.3. Facturas
CREATE TABLE dominio.Facturas (
    FacturaId           INT            IDENTITY(1,1) PRIMARY KEY,
    ClienteId           INT            NOT NULL
                                REFERENCES dominio.Clientes(ClienteId),
    Fecha               DATETIME2(3)   NOT NULL DEFAULT SYSUTCDATETIME(),
    Total               DECIMAL(18,2)  NOT NULL,

    -- Auditoría / soft‑delete
    Activo              BIT            NOT NULL DEFAULT 1,
    IdUsuarioCrea       INT            NOT NULL,
    FechaCrea           DATETIME2(3)   NOT NULL DEFAULT SYSUTCDATETIME(),
    IdUsuarioModifica   INT            NULL,
    FechaModifica       DATETIME2(3)   NULL,

    -- Estado de factura ('PE'=pendiente, 'PG'=pagada, 'AN'=anulada, etc.)
    Estado              CHAR(2)        NOT NULL DEFAULT 'PE'
);
ALTER TABLE dominio.Facturas
    ADD CONSTRAINT FK_Facturas_Creador    FOREIGN KEY (IdUsuarioCrea)     REFERENCES dominio.Usuarios(UsuarioId),
        CONSTRAINT FK_Facturas_Modificador FOREIGN KEY (IdUsuarioModifica) REFERENCES dominio.Usuarios(UsuarioId);


-- ==================================================
-- 4. TABLA DE AUDITORÍA DE FACTURAS
-- ==================================================
CREATE TABLE auditoria.AuditoriaFacturas (
    AuditoriaId     INT            IDENTITY(1,1) PRIMARY KEY,
    FacturaId       INT            NOT NULL
                                REFERENCES dominio.Facturas(FacturaId),
    UsuarioId       INT            NOT NULL
                                REFERENCES dominio.Usuarios(UsuarioId),
    Accion          NVARCHAR(20)   NOT NULL,         -- 'Creación','Modificación','Eliminación'
    FechaHora       DATETIME2(3)   NOT NULL DEFAULT SYSUTCDATETIME(),
    Campo           NVARCHAR(128)  NULL,             -- nombre del campo modificado
    ValorAnterior   NVARCHAR(MAX)  NULL,
    ValorNuevo      NVARCHAR(MAX)  NULL,
    Contexto        NVARCHAR(256)  NULL              -- p.ej. IP, host, motivo, etc.
);


-- ==================================================
-- 5. TABLAS PARA REPORTES RÁPIDOS
-- ==================================================

-- 5.1. Histórico de facturación por cliente
CREATE TABLE reportes.HistoricoCliente (
    ClienteId        INT            NOT NULL,
    Periodo          DATE           NOT NULL,       -- ej. '2025-04-01' para abril 2025
    TotalFacturado   DECIMAL(18,2)  NOT NULL,
    CantidadFacturas INT            NOT NULL,
    CONSTRAINT PK_HistoricoCliente PRIMARY KEY (ClienteId, Periodo)
);

-- 5.2. Histórico de facturación por usuario
CREATE TABLE reportes.HistoricoUsuario (
    UsuarioId        INT            NOT NULL,
    Periodo          DATE           NOT NULL,
    CantidadFacturas INT            NOT NULL,
    CONSTRAINT PK_HistoricoUsuario PRIMARY KEY (UsuarioId, Periodo)
);
