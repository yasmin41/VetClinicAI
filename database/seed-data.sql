-- ============================================
-- VetClinicAI - Sample Data
-- Description: Initial sample records for testing
-- Contains fictional customer information only
-- ============================================
USE [VetClinicAI];
GO

SET XACT_ABORT ON;
GO

BEGIN TRY
    BEGIN TRANSACTION;

    -- Prevent inserting duplicate sample customers
    IF EXISTS (SELECT 1 FROM dbo.Customers WHERE FullName IN (N'Sara', N'Ahmad'))
        THROW 51000, 'Sample customers already exist. Seed was not applied.', 1;

    INSERT INTO dbo.Customers (FullName, PhoneNumber)
    VALUES (N'Sara', NULL), (N'Ahmad', NULL);

    DECLARE @SaraId INT = (SELECT CustomerId FROM dbo.Customers WHERE FullName = N'Sara');
    DECLARE @AhmadId INT = (SELECT CustomerId FROM dbo.Customers WHERE FullName = N'Ahmad');

    INSERT INTO dbo.Pets (CustomerId, PetName, Species, Breed, DateOfBirth)
    VALUES
        (@SaraId, N'Loza', N'Cat', NULL, NULL),
        (@SaraId, N'Nana', N'Cat', NULL, NULL),
        (@AhmadId, N'Max', N'Dog', NULL, NULL);

    DECLARE @LozaId INT = (SELECT PetId FROM dbo.Pets WHERE CustomerId = @SaraId AND PetName = N'Loza');
    DECLARE @NanaId INT = (SELECT PetId FROM dbo.Pets WHERE CustomerId = @SaraId AND PetName = N'Nana');
    DECLARE @MaxId INT = (SELECT PetId FROM dbo.Pets WHERE CustomerId = @AhmadId AND PetName = N'Max');
    DECLARE @Today DATE = CAST(GETDATE() AS DATE);

    -- Reminder test cases: +2 and +7 days qualify; +14 does not.
    INSERT INTO dbo.Vaccinations (PetId, VaccineName, LastVaccinationDate, NextDueDate)
    VALUES
        (@LozaId, N'Rabies', DATEADD(DAY, -365, @Today), DATEADD(DAY, 2, @Today)),
        (@NanaId, N'FVRCP', DATEADD(DAY, -365, @Today), DATEADD(DAY, 7, @Today)),
        (@MaxId, N'DHPP', DATEADD(DAY, -365, @Today), DATEADD(DAY, 14, @Today));

    INSERT INTO dbo.Appointments (PetId, AppointmentDate, Reason, Status)
    VALUES (@LozaId, DATEADD(DAY, 2, CAST(@Today AS DATETIME2)), N'Vaccination follow-up', 'Pending');

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH;
GO

SELECT c.FullName AS CustomerName, p.PetName, v.VaccineName,
       v.NextDueDate, DATEDIFF(DAY, CAST(GETDATE() AS DATE), v.NextDueDate) AS DaysUntilDue
FROM dbo.Vaccinations AS v
JOIN dbo.Pets AS p ON p.PetId = v.PetId
JOIN dbo.Customers AS c ON c.CustomerId = p.CustomerId
ORDER BY v.NextDueDate;
GO
