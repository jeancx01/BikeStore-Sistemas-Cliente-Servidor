/* ============================================================
   BIKESTORE - BASE DE DATOS
   Proyecto Final Sistemas Cliente Servidor
   SQL Server
   ============================================================ */

USE master;
GO

-- Crear la base únicamente si todavía no existe
IF DB_ID(N'BikeStoreDB') IS NULL
BEGIN
    EXEC('CREATE DATABASE BikeStoreDB');
END;
GO

USE BikeStoreDB;
GO


/* ============================================================
   TABLA: CATEGORIA
   ============================================================ */

IF OBJECT_ID(N'dbo.Categoria', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Categoria
    (
        IdCategoria INT IDENTITY(1,1) PRIMARY KEY,
        Nombre NVARCHAR(100) NOT NULL UNIQUE,
        Descripcion NVARCHAR(250) NULL,
        Activo BIT NOT NULL DEFAULT 1
    );
END;
GO


/* ============================================================
   TABLA: BICICLETA
   ============================================================ */

IF OBJECT_ID(N'dbo.Bicicleta', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Bicicleta
    (
        IdBicicleta INT IDENTITY(1,1) PRIMARY KEY,
        IdCategoria INT NOT NULL,
        Marca NVARCHAR(100) NOT NULL,
        Modelo NVARCHAR(100) NOT NULL,
        Precio DECIMAL(10,2) NOT NULL,
        Stock INT NOT NULL DEFAULT 0,
        Estado NVARCHAR(20) NOT NULL DEFAULT N'Disponible',

        CONSTRAINT FK_Bicicleta_Categoria
            FOREIGN KEY (IdCategoria)
            REFERENCES dbo.Categoria(IdCategoria),

        CONSTRAINT CK_Bicicleta_Precio
            CHECK (Precio >= 0),

        CONSTRAINT CK_Bicicleta_Stock
            CHECK (Stock >= 0),

        CONSTRAINT CK_Bicicleta_Estado
            CHECK
            (
                Estado IN
                (
                    N'Disponible',
                    N'Bajo stock',
                    N'Agotado',
                    N'Inactivo'
                )
            )
    );
END;
GO


/* ============================================================
   TABLA: CLIENTE
   ============================================================ */

IF OBJECT_ID(N'dbo.Cliente', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Cliente
    (
        IdCliente INT IDENTITY(1,1) PRIMARY KEY,
        Cedula NVARCHAR(20) NOT NULL UNIQUE,
        Nombres NVARCHAR(100) NOT NULL,
        Apellidos NVARCHAR(100) NOT NULL,
        Telefono NVARCHAR(20) NULL,
        Correo NVARCHAR(150) NULL
    );
END;
GO


/* ============================================================
   TABLA: VENTA
   ============================================================ */

IF OBJECT_ID(N'dbo.Venta', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Venta
    (
        IdVenta INT IDENTITY(1,1) PRIMARY KEY,
        Fecha DATETIME2 NOT NULL DEFAULT GETDATE(),
        IdCliente INT NOT NULL,
        Subtotal DECIMAL(12,2) NOT NULL DEFAULT 0,
        IVA DECIMAL(12,2) NOT NULL DEFAULT 0,
        Total DECIMAL(12,2) NOT NULL DEFAULT 0,

        CONSTRAINT FK_Venta_Cliente
            FOREIGN KEY (IdCliente)
            REFERENCES dbo.Cliente(IdCliente),

        CONSTRAINT CK_Venta_Subtotal
            CHECK (Subtotal >= 0),

        CONSTRAINT CK_Venta_IVA
            CHECK (IVA >= 0),

        CONSTRAINT CK_Venta_Total
            CHECK (Total >= 0)
    );
END;
GO


/* ============================================================
   TABLA: DETALLE VENTA
   ============================================================ */

IF OBJECT_ID(N'dbo.DetalleVenta', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.DetalleVenta
    (
        IdDetalle INT IDENTITY(1,1) PRIMARY KEY,
        IdVenta INT NOT NULL,
        IdBicicleta INT NOT NULL,
        Cantidad INT NOT NULL,
        Precio DECIMAL(10,2) NOT NULL,
        Subtotal DECIMAL(12,2) NOT NULL,

        CONSTRAINT FK_DetalleVenta_Venta
            FOREIGN KEY (IdVenta)
            REFERENCES dbo.Venta(IdVenta),

        CONSTRAINT FK_DetalleVenta_Bicicleta
            FOREIGN KEY (IdBicicleta)
            REFERENCES dbo.Bicicleta(IdBicicleta),

        CONSTRAINT CK_DetalleVenta_Cantidad
            CHECK (Cantidad > 0),

        CONSTRAINT CK_DetalleVenta_Precio
            CHECK (Precio >= 0),

        CONSTRAINT CK_DetalleVenta_Subtotal
            CHECK (Subtotal >= 0)
    );
END;
GO


/* ============================================================
   DATOS DE PRUEBA - CATEGORIAS
   ============================================================ */

IF NOT EXISTS (SELECT 1 FROM dbo.Categoria WHERE Nombre = N'Montaña')
    INSERT INTO dbo.Categoria
        (Nombre, Descripcion, Activo)
    VALUES
        (N'Montaña',
         N'Bicicletas diseñadas para terrenos irregulares y montaña.',
         1);

IF NOT EXISTS (SELECT 1 FROM dbo.Categoria WHERE Nombre = N'Ruta')
    INSERT INTO dbo.Categoria
        (Nombre, Descripcion, Activo)
    VALUES
        (N'Ruta',
         N'Bicicletas ligeras diseñadas para carretera.',
         1);

IF NOT EXISTS (SELECT 1 FROM dbo.Categoria WHERE Nombre = N'BMX')
    INSERT INTO dbo.Categoria
        (Nombre, Descripcion, Activo)
    VALUES
        (N'BMX',
         N'Bicicletas para trucos, saltos y circuitos BMX.',
         1);

IF NOT EXISTS (SELECT 1 FROM dbo.Categoria WHERE Nombre = N'Eléctricas')
    INSERT INTO dbo.Categoria
        (Nombre, Descripcion, Activo)
    VALUES
        (N'Eléctricas',
         N'Bicicletas con asistencia mediante motor eléctrico.',
         1);

IF NOT EXISTS (SELECT 1 FROM dbo.Categoria WHERE Nombre = N'Infantiles')
    INSERT INTO dbo.Categoria
        (Nombre, Descripcion, Activo)
    VALUES
        (N'Infantiles',
         N'Bicicletas diseñadas para niños.',
         1);
GO


/* ============================================================
   DATOS DE PRUEBA - BICICLETAS
   ============================================================ */

IF NOT EXISTS
(
    SELECT 1
    FROM dbo.Bicicleta
    WHERE Marca = N'Trek'
      AND Modelo = N'Marlin 5'
)
BEGIN
    INSERT INTO dbo.Bicicleta
        (IdCategoria, Marca, Modelo, Precio, Stock, Estado)
    VALUES
    (
        (SELECT IdCategoria
         FROM dbo.Categoria
         WHERE Nombre = N'Montaña'),

        N'Trek',
        N'Marlin 5',
        1250.00,
        8,
        N'Disponible'
    );
END;


IF NOT EXISTS
(
    SELECT 1
    FROM dbo.Bicicleta
    WHERE Marca = N'Specialized'
      AND Modelo = N'Allez Elite'
)
BEGIN
    INSERT INTO dbo.Bicicleta
        (IdCategoria, Marca, Modelo, Precio, Stock, Estado)
    VALUES
    (
        (SELECT IdCategoria
         FROM dbo.Categoria
         WHERE Nombre = N'Ruta'),

        N'Specialized',
        N'Allez Elite',
        2450.00,
        5,
        N'Disponible'
    );
END;


IF NOT EXISTS
(
    SELECT 1
    FROM dbo.Bicicleta
    WHERE Marca = N'GT'
      AND Modelo = N'Performer 20'
)
BEGIN
    INSERT INTO dbo.Bicicleta
        (IdCategoria, Marca, Modelo, Precio, Stock, Estado)
    VALUES
    (
        (SELECT IdCategoria
         FROM dbo.Categoria
         WHERE Nombre = N'BMX'),

        N'GT',
        N'Performer 20',
        850.00,
        0,
        N'Agotado'
    );
END;


IF NOT EXISTS
(
    SELECT 1
    FROM dbo.Bicicleta
    WHERE Marca = N'Scott'
      AND Modelo = N'E-Strike 20'
)
BEGIN
    INSERT INTO dbo.Bicicleta
        (IdCategoria, Marca, Modelo, Precio, Stock, Estado)
    VALUES
    (
        (SELECT IdCategoria
         FROM dbo.Categoria
         WHERE Nombre = N'Eléctricas'),

        N'Scott',
        N'E-Strike 20',
        4950.00,
        3,
        N'Bajo stock'
    );
END;


IF NOT EXISTS
(
    SELECT 1
    FROM dbo.Bicicleta
    WHERE Marca = N'Giant'
      AND Modelo = N'Animator 24'
)
BEGIN
    INSERT INTO dbo.Bicicleta
        (IdCategoria, Marca, Modelo, Precio, Stock, Estado)
    VALUES
    (
        (SELECT IdCategoria
         FROM dbo.Categoria
         WHERE Nombre = N'Infantiles'),

        N'Giant',
        N'Animator 24',
        620.00,
        7,
        N'Disponible'
    );
END;
GO


/* ============================================================
   DATOS DE PRUEBA - CLIENTES
   ============================================================ */

IF NOT EXISTS
(
    SELECT 1 FROM dbo.Cliente
    WHERE Cedula = N'0100000001'
)
BEGIN
    INSERT INTO dbo.Cliente
        (Cedula, Nombres, Apellidos, Telefono, Correo)
    VALUES
        (N'0100000001',
         N'Juan',
         N'Pérez',
         N'0981111111',
         N'juan.perez@email.com');
END;


IF NOT EXISTS
(
    SELECT 1 FROM dbo.Cliente
    WHERE Cedula = N'0100000002'
)
BEGIN
    INSERT INTO dbo.Cliente
        (Cedula, Nombres, Apellidos, Telefono, Correo)
    VALUES
        (N'0100000002',
         N'María',
         N'González',
         N'0982222222',
         N'maria.gonzalez@email.com');
END;


IF NOT EXISTS
(
    SELECT 1 FROM dbo.Cliente
    WHERE Cedula = N'0100000003'
)
BEGIN
    INSERT INTO dbo.Cliente
        (Cedula, Nombres, Apellidos, Telefono, Correo)
    VALUES
        (N'0100000003',
         N'Carlos',
         N'Ramírez',
         N'0983333333',
         N'carlos.ramirez@email.com');
END;


IF NOT EXISTS
(
    SELECT 1 FROM dbo.Cliente
    WHERE Cedula = N'0100000004'
)
BEGIN
    INSERT INTO dbo.Cliente
        (Cedula, Nombres, Apellidos, Telefono, Correo)
    VALUES
        (N'0100000004',
         N'Laura',
         N'Medina',
         N'0984444444',
         N'laura.medina@email.com');
END;


IF NOT EXISTS
(
    SELECT 1 FROM dbo.Cliente
    WHERE Cedula = N'0100000005'
)
BEGIN
    INSERT INTO dbo.Cliente
        (Cedula, Nombres, Apellidos, Telefono, Correo)
    VALUES
        (N'0100000005',
         N'Andrés',
         N'Vargas',
         N'0985555555',
         N'andres.vargas@email.com');
END;
GO


/* ============================================================
   COMPROBACION
   ============================================================ */

SELECT * FROM dbo.Categoria;
SELECT * FROM dbo.Bicicleta;
SELECT * FROM dbo.Cliente;
GO