-- ============================================
-- MEDICARE PLUS HEALTHCARE INFORMATION SYSTEM
-- DATABASE SECURITY & ACCESS CONTROL
-- ============================================

-- ============================================
-- LOGINS
-- ============================================
USE master
GO

-- server-level logins
CREATE LOGIN MediCare_Admin WITH PASSWORD = 'Admin@MediCare2025!'
CREATE LOGIN Dr_Smith WITH PASSWORD = 'Doctor@MediCare2025!'
CREATE LOGIN Receptionist_Jones WITH PASSWORD = 'Reception@MediCare2025!'
CREATE LOGIN Pharmacist_Lee WITH PASSWORD = 'Pharma@MediCare2025!'
GO

-- ============================================
-- DATABASE FOR USERS
-- ============================================
USE MediCarePlusDB
GO

-- Create database users mapped to logins
CREATE USER MediCare_Admin FOR LOGIN MediCare_Admin
CREATE USER Dr_Smith FOR LOGIN Dr_Smith
CREATE USER Receptionist_Jones FOR LOGIN Receptionist_Jones
CREATE USER Pharmacist_Lee FOR LOGIN Pharmacist_Lee
GO

-- ============================================
-- DATABASE FOR ROLES
-- ============================================

-- Admin Role (Full access to all data)
CREATE ROLE Healthcare_Admin
GO

-- Doctor Role (Patient data, appointments, medical records)
CREATE ROLE Healthcare_Doctor
GO

-- Receptionist Role (Appointments, patient registration, billing)
CREATE ROLE Healthcare_Receptionist
GO

-- Pharmacist Role
CREATE ROLE Healthcare_Pharmacist
GO

-- ============================================
-- ASSIGN USERS TO ROLES
-- ============================================

-- Admin user
ALTER ROLE Healthcare_Admin ADD MEMBER MediCare_Admin

-- Doctor user
ALTER ROLE Healthcare_Doctor ADD MEMBER Dr_Smith

-- Receptionist user
ALTER ROLE Healthcare_Receptionist ADD MEMBER Receptionist_Jones
GO

-- Pharmacist user
ALTER ROLE Healthcare_Pharmacist ADD MEMBER Pharmacist_Lee
GO

-- ============================================
-- GRANT PERMISSIONS - ADMIN ROLE
-- Full access to all tables and operations
-- ============================================

-- Admin gets full control
GRANT SELECT, INSERT, UPDATE, DELETE ON Patient TO Healthcare_Admin
GRANT SELECT, INSERT, UPDATE, DELETE ON Doctor TO Healthcare_Admin
GRANT SELECT, INSERT, UPDATE, DELETE ON Department TO Healthcare_Admin
GRANT SELECT, INSERT, UPDATE, DELETE ON Appointment TO Healthcare_Admin
GRANT SELECT, INSERT, UPDATE, DELETE ON AppointmentStatus TO Healthcare_Admin
GRANT SELECT, INSERT, UPDATE, DELETE ON MedicalRecord TO Healthcare_Admin
GRANT SELECT, INSERT, UPDATE, DELETE ON Diagnosis TO Healthcare_Admin
GRANT SELECT, INSERT, UPDATE, DELETE ON Prescription TO Healthcare_Admin
GRANT SELECT, INSERT, UPDATE, DELETE ON Billing TO Healthcare_Admin
GRANT SELECT, INSERT, UPDATE, DELETE ON PaymentMethod TO Healthcare_Admin
GRANT SELECT, INSERT, UPDATE, DELETE ON PaymentStatus TO Healthcare_Admin
GRANT SELECT, INSERT, UPDATE, DELETE ON Treatment TO Healthcare_Admin
GRANT SELECT, INSERT, UPDATE, DELETE ON AppointmentTreatment TO Healthcare_Admin

-- Admin can execute all stored procedures
GRANT EXECUTE ON SCHEMA::dbo TO Healthcare_Admin

-- ============================================
-- GRANT PERMISSIONS - DOCTOR ROLE
-- Can view patient data, appointments, medical records
-- Can insert/update medical records and prescriptions
-- CANNOT see billing/financial data
-- ============================================

-- SELECT permissions (read-only access)
GRANT SELECT ON Patient TO Healthcare_Doctor
GRANT SELECT ON Doctor TO Healthcare_Doctor
GRANT SELECT ON Department TO Healthcare_Doctor
GRANT SELECT ON Appointment TO Healthcare_Doctor
GRANT SELECT ON AppointmentStatus TO Healthcare_Doctor
GRANT SELECT ON Diagnosis TO Healthcare_Doctor
GRANT SELECT ON Treatment TO Healthcare_Doctor

-- INSERT and UPDATE on medical records
GRANT SELECT, INSERT, UPDATE ON MedicalRecord TO Healthcare_Doctor
GRANT SELECT, INSERT, UPDATE ON Prescription TO Healthcare_Doctor
GRANT SELECT, INSERT ON AppointmentTreatment TO Healthcare_Doctor

-- Doctors can update appointment status (mark as completed)
GRANT UPDATE ON Appointment TO Healthcare_Doctor

-- Doctors can execute relevant stored procedures
GRANT EXECUTE ON sp_SearchDoctors TO Healthcare_Doctor
GRANT EXECUTE ON sp_GetPatientAppointments TO Healthcare_Doctor
GRANT EXECUTE ON sp_GetDoctorAppointments TO Healthcare_Doctor
GRANT EXECUTE ON sp_UpdateAppointmentStatus TO Healthcare_Doctor
GRANT EXECUTE ON sp_AddMedicalRecordWithPrescription TO Healthcare_Doctor

-- DENY access to billing/financial data
DENY SELECT ON Billing TO Healthcare_Doctor
DENY SELECT ON PaymentMethod TO Healthcare_Doctor
DENY SELECT ON PaymentStatus TO Healthcare_Doctor

-- ============================================
-- GRANT PERMISSIONS - RECEPTIONIST ROLE
-- Can manage appointments and patient registration
-- Can view billing for payment processing
-- CANNOT access medical records but can view prescriptions for billing purposes
-- ============================================

-- SELECT permissions
GRANT SELECT ON Patient TO Healthcare_Receptionist
GRANT SELECT ON Doctor TO Healthcare_Receptionist
GRANT SELECT ON Department TO Healthcare_Receptionist
GRANT SELECT ON AppointmentStatus TO Healthcare_Receptionist
GRANT SELECT ON PaymentMethod TO Healthcare_Receptionist
GRANT SELECT ON PaymentStatus TO Healthcare_Receptionist
GRANT SELECT ON Prescription TO Healthcare_Receptionist       

-- INSERT and UPDATE on appointments and patients
GRANT SELECT, INSERT, UPDATE ON Appointment TO Healthcare_Receptionist
GRANT INSERT, UPDATE ON Patient TO Healthcare_Receptionist

-- Billing access (view and insert only)
GRANT SELECT, INSERT ON Billing TO Healthcare_Receptionist

-- Execute relevant stored procedures
GRANT EXECUTE ON sp_SearchDoctors TO Healthcare_Receptionist
GRANT EXECUTE ON sp_GetPatientAppointments TO Healthcare_Receptionist
GRANT EXECUTE ON sp_ScheduleAppointment TO Healthcare_Receptionist
GRANT EXECUTE ON sp_UpdateAppointmentStatus TO Healthcare_Receptionist
GRANT EXECUTE ON sp_GetPatientBilling TO Healthcare_Receptionist

-- DENY access to medical data (except prescription for billing)
DENY SELECT ON MedicalRecord TO Healthcare_Receptionist
DENY SELECT ON Diagnosis TO Healthcare_Receptionist
DENY SELECT ON Treatment TO Healthcare_Receptionist
DENY SELECT ON AppointmentTreatment TO Healthcare_Receptionist
DENY INSERT, UPDATE, DELETE ON Prescription TO Healthcare_Receptionist 
GO

-- ============================================
-- GRANT PERMISSIONS - PHARMACIST ROLE
-- ============================================

-- View patient information (contact for clarifications)
GRANT SELECT ON Patient TO Healthcare_Pharmacist

-- View doctor information (verify prescribing doctor)
GRANT SELECT ON Doctor TO Healthcare_Pharmacist

-- View diagnoses (understand what they're treating)
GRANT SELECT ON Diagnosis TO Healthcare_Pharmacist

-- View medical records (context for prescriptions)
GRANT SELECT ON MedicalRecord TO Healthcare_Pharmacist

-- View and update prescriptions (dispense medications)
GRANT SELECT, UPDATE ON Prescription TO Healthcare_Pharmacist

-- View billing status (confirm payment before dispensing)
GRANT SELECT ON Billing TO Healthcare_Pharmacist
GRANT SELECT ON PaymentStatus TO Healthcare_Pharmacist

-- View appointments (verify patient visit)
GRANT SELECT ON Appointment TO Healthcare_Pharmacist
GRANT SELECT ON AppointmentStatus TO Healthcare_Pharmacist

-- Execute relevant stored procedures
GRANT EXECUTE ON sp_GetPatientAppointments TO Healthcare_Pharmacist

-- ============================================
-- RESTRICTIONS - PHARMACIST ROLE
-- ============================================

-- Cannot create prescriptions (only doctors prescribe)
DENY INSERT, DELETE ON Prescription TO Healthcare_Pharmacist

-- Cannot modify medical records
DENY INSERT, UPDATE, DELETE ON MedicalRecord TO Healthcare_Pharmacist

-- Cannot modify billing
DENY INSERT, UPDATE, DELETE ON Billing TO Healthcare_Pharmacist

-- Cannot modify patient data
DENY INSERT, UPDATE, DELETE ON Patient TO Healthcare_Pharmacist

-- Cannot access payment methods
DENY SELECT ON PaymentMethod TO Healthcare_Pharmacist

-- Cannot access treatments catalog
DENY SELECT ON Treatment TO Healthcare_Pharmacist
DENY SELECT ON AppointmentTreatment TO Healthcare_Pharmacist


-- ============================================
-- AUDIT LOGGING
-- Track who accesses sensitive data
-- ============================================

-- Create audit table
CREATE TABLE SecurityAudit (
    AuditID INT IDENTITY(1,1) PRIMARY KEY,
    Username NVARCHAR(100),
    ActionType NVARCHAR(50),
    ObjectName NVARCHAR(100),
    ActionDate DATETIME DEFAULT GETDATE(),
    IPAddress NVARCHAR(50)
)
GO

-- ============================================
-- AUDIT TRIGGERS
-- ============================================

-- Audit MedicalRecord access (INSERT, UPDATE, DELETE only)
CREATE TRIGGER trg_Audit_MedicalRecord
ON MedicalRecord
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    INSERT INTO SecurityAudit (Username, ActionType, ObjectName)
    VALUES (SYSTEM_USER, 'MODIFIED', 'MedicalRecord')
END
GO

-- Audit Billing access
CREATE TRIGGER trg_Audit_Billing
ON Billing
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    INSERT INTO SecurityAudit (Username, ActionType, ObjectName)
    VALUES (SYSTEM_USER, 'MODIFIED', 'Billing')
END
GO

-- Audit Patient contact modifications
CREATE TRIGGER trg_Audit_PatientContact
ON Patient
AFTER INSERT, UPDATE
AS
BEGIN
    IF UPDATE(PhoneNumber) OR UPDATE(Email)
    BEGIN
        INSERT INTO SecurityAudit (Username, ActionType, ObjectName)
        VALUES (SYSTEM_USER, 'CONTACT_UPDATED', 'Patient')
    END
END
GO

-- ===========================================
-- VERIFY PERMISSIONS
-- ============================================

-- Check role members
SELECT 
    r.name AS RoleName,
    m.name AS MemberName
FROM sys.database_role_members rm
JOIN sys.database_principals r ON rm.role_principal_id = r.principal_id
JOIN sys.database_principals m ON rm.member_principal_id = m.principal_id
JOIN sys.database_principals u ON m.principal_id = u.principal_id
WHERE r.name IN ('Healthcare_Admin', 'Healthcare_Doctor', 'Healthcare_Receptionist', 'Healthcare_Pharmacist')
GO