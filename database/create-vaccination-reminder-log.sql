
USE [VetClinicAI];
GO

GRANT SELECT, INSERT
ON OBJECT::dbo.VaccinationReminderLog
TO [vetclinic_n8n_user];
GO

-- Verify permissions
SELECT
    USER_NAME(grantee_principal_id) AS DatabaseUser,
    permission_name AS PermissionName,
    state_desc AS PermissionState
FROM sys.database_permissions
WHERE major_id = OBJECT_ID(N'dbo.VaccinationReminderLog')
  AND grantee_principal_id =
      DATABASE_PRINCIPAL_ID(N'vetclinic_n8n_user');
