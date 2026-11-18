-- ============================================
-- VetClinicAI - Database schema
-- Source: SSMS-generated script, 2026-11-18
-- Run in SSMS on a SQL Server instance where you have CREATE DATABASE permission.
-- Designed for a fresh VetClinicAI database. Does not modify an existing schema.
-- ============================================

USE [master];
GO

IF DB_ID(N'VetClinicAI') IS NOT NULL
BEGIN
    RAISERROR('Database VetClinicAI already exists. No schema changes will be run.', 16, 1);
    SET NOEXEC ON;
END;
GO

CREATE DATABASE [VetClinicAI];
GO
USE [VetClinicAI];
GO

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

--Customers
CREATE TABLE dbo.Customers
(
    CustomerId INT IDENTITY(1,1) NOT NULL,
    FullName NVARCHAR(100) NOT NULL,
    PhoneNumber VARCHAR(20) NULL,
    CreatedAt DATETIME2(7) NOT NULL,
    CONSTRAINT PK_Customers PRIMARY KEY CLUSTERED (CustomerId)
);
GO

--Pets
CREATE TABLE dbo.Pets
(
    PetId INT IDENTITY(1,1) NOT NULL,
    CustomerId INT NOT NULL,
    PetName NVARCHAR(100) NOT NULL,
    Species NVARCHAR(50) NOT NULL,
    Breed NVARCHAR(100) NULL,
    DateOfBirth DATE NULL,
    CreatedAt DATETIME2(7) NOT NULL,
    CONSTRAINT PK_Pets PRIMARY KEY CLUSTERED (PetId),
    CONSTRAINT FK_Pets_Customers FOREIGN KEY (CustomerId) REFERENCES dbo.Customers(CustomerId)
);
GO

--Vaccinations
CREATE TABLE dbo.Vaccinations
(
    VaccinationId INT IDENTITY(1,1) NOT NULL,
    PetId INT NOT NULL,
    VaccineName NVARCHAR(100) NOT NULL,
    LastVaccinationDate DATE NULL,
    NextDueDate DATE NOT NULL,
    CreatedAt DATETIME2(7) NOT NULL,
    CONSTRAINT PK_Vaccinations PRIMARY KEY CLUSTERED (VaccinationId),
    CONSTRAINT FK_Vaccinations_Pets FOREIGN KEY (PetId) REFERENCES dbo.Pets(PetId),
    CONSTRAINT CK_Vaccinations_Dates CHECK (LastVaccinationDate IS NULL OR NextDueDate > LastVaccinationDate)
);
GO

--Appointments
CREATE TABLE dbo.Appointments
(
    AppointmentId INT IDENTITY(1,1) NOT NULL,
    PetId INT NOT NULL,
    AppointmentDate DATETIME2(7) NOT NULL,
    Reason NVARCHAR(255) NULL,
    Status VARCHAR(20) NOT NULL,
    CreatedAt DATETIME2(7) NOT NULL,
    CONSTRAINT PK_Appointments PRIMARY KEY CLUSTERED (AppointmentId),
    CONSTRAINT FK_Appointments_Pets FOREIGN KEY (PetId) REFERENCES dbo.Pets(PetId),
    CONSTRAINT CK_Appointments_Status CHECK (Status IN ('Completed','Cancelled','Confirmed','Pending'))
);
GO

-- Defaults (kept separate to preserve original constraint names)
ALTER TABLE dbo.Customers ADD CONSTRAINT DF_Customers_CreatedAt DEFAULT (SYSUTCDATETIME()) FOR CreatedAt;
GO
ALTER TABLE dbo.Pets ADD CONSTRAINT DF_Pets_CreatedAt DEFAULT (SYSUTCDATETIME()) FOR CreatedAt;
GO
ALTER TABLE dbo.Vaccinations ADD CONSTRAINT DF_Vaccinations_CreatedAt DEFAULT (SYSUTCDATETIME()) FOR CreatedAt;
GO
ALTER TABLE dbo.Appointments ADD CONSTRAINT DF_Appointments_Status DEFAULT ('Pending') FOR Status;
GO
ALTER TABLE dbo.Appointments ADD CONSTRAINT DF_Appointments_CreatedAt DEFAULT (SYSUTCDATETIME()) FOR CreatedAt;
GO

-- Indexes from the original database schema
CREATE NONCLUSTERED INDEX IX_Appointments_PetId ON dbo.Appointments(PetId);
GO
CREATE UNIQUE NONCLUSTERED INDEX UX_Customers_PhoneNumber ON dbo.Customers(PhoneNumber)
WHERE PhoneNumber IS NOT NULL;
GO
CREATE NONCLUSTERED INDEX IX_Pets_CustomerId ON dbo.Pets(CustomerId);
GO
CREATE NONCLUSTERED INDEX IX_Vaccinations_NextDueDate ON dbo.Vaccinations(NextDueDate);
GO

-- Verification (no rows are inserted by this script)
SELECT DB_NAME() AS CurrentDatabase,
       (SELECT COUNT(*) FROM sys.tables WHERE schema_id = SCHEMA_ID('dbo')
        AND name IN ('Customers','Pets','Vaccinations','Appointments')) AS ExpectedTablesFound;
GO

-- Restore query execution if the guard above disabled it.
SET NOEXEC OFF;
GO
