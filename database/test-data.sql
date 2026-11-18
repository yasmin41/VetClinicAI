
USE [VetClinicAI];
GO

BEGIN TRANSACTION;

DECLARE @CustomerId INT;
DECLARE @PetId INT;

-- Create a test customer
INSERT INTO dbo.Customers (FullName, PhoneNumber)
VALUES (N'Test Customer', NULL);

SET @CustomerId = SCOPE_IDENTITY();

-- Test 1: Luna - Due in 3 days
INSERT INTO dbo.Pets (CustomerId, PetName, Species)
VALUES (@CustomerId, N'Luna', N'Cat');

SET @PetId = SCOPE_IDENTITY();

INSERT INTO dbo.Vaccinations
    (PetId, VaccineName, NextDueDate)
VALUES
    (@PetId, N'Rabies', DATEADD(DAY, 3, CAST(GETDATE() AS DATE)));

-- Test 2: Rocky - Due in 6 days
INSERT INTO dbo.Pets (CustomerId, PetName, Species)
VALUES (@CustomerId, N'Rocky', N'Dog');

SET @PetId = SCOPE_IDENTITY();

INSERT INTO dbo.Vaccinations
    (PetId, VaccineName, NextDueDate)
VALUES
    (@PetId, N'DHPP', DATEADD(DAY, 6, CAST(GETDATE() AS DATE)));

-- Test 3: Bella - Due in 15 days
INSERT INTO dbo.Pets (CustomerId, PetName, Species)
VALUES (@CustomerId, N'Bella', N'Cat');

SET @PetId = SCOPE_IDENTITY();

INSERT INTO dbo.Vaccinations
    (PetId, VaccineName, NextDueDate)
VALUES
    (@PetId, N'FVRCP', DATEADD(DAY, 15, CAST(GETDATE() AS DATE)));

COMMIT TRANSACTION;

-- Verify test records
SELECT
    p.PetName,
    v.VaccineName,
    v.NextDueDate,
    DATEDIFF(DAY, CAST(GETDATE() AS DATE), v.NextDueDate) AS DaysUntilDue
FROM dbo.Pets p
JOIN dbo.Vaccinations v ON p.PetId = v.PetId
JOIN dbo.Customers c ON p.CustomerId = c.CustomerId
WHERE c.FullName = N'Test Customer'
ORDER BY v.NextDueDate;
