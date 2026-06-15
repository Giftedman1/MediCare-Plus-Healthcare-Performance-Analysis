-- ============================================
-- INDEXES & PERFORMANCE OPTIMIZATION
-- ============================================
USE MediCarePlusDB
GO

-- =====================================================
-- APPOINTMENT INDEXES
-- =====================================================

-- Index for patient appointment searches by patient ID
CREATE NONCLUSTERED INDEX IX_Appointment_PatientID
ON Appointment(PatientID)
GO

-- Index for doctor appointment searches by doctor ID
CREATE NONCLUSTERED INDEX IX_Appointment_DoctorID
ON Appointment(DoctorID)
GO

-- Index for appointment status filtering by status ID
CREATE NONCLUSTERED INDEX IX_Appointment_StatusID
ON Appointment(AppointmentStatusID)
GO

-- Index for appointment date analytics and ETL
CREATE NONCLUSTERED INDEX IX_Appointment_Date
ON Appointment(AppointmentDate)
GO

-- =====================================================
-- MEDICAL RECORD INDEXES
-- =====================================================

-- Index for retrieving medical records by appointment
CREATE NONCLUSTERED INDEX IX_MedicalRecord_AppointmentID
ON MedicalRecord(AppointmentID)
GO

-- =====================================================
-- PRESCRIPTION INDEXES
-- =====================================================

-- Index for prescription lookups by medical record
CREATE NONCLUSTERED INDEX IX_Prescription_MedicalRecordID
ON Prescription(MedicalRecordID)
GO

-- =====================================================
-- BILLING INDEXES
-- =====================================================

-- Index for patient billing history
CREATE NONCLUSTERED INDEX IX_Billing_PatientID
ON Billing(PatientID)
GO

-- Index for billing searches by appointment
CREATE NONCLUSTERED INDEX IX_Billing_AppointmentID
ON Billing(AppointmentID)
GO

-- Index for payment status reporting
CREATE NONCLUSTERED INDEX IX_Billing_PaymentStatusID
ON Billing(PaymentStatusID)
GO

-- Index for billing date analysis and ETL
CREATE NONCLUSTERED INDEX IX_Billing_BillingDate
ON Billing(BillingDate)
GO

-- =====================================================
-- DOCTOR INDEXES
-- =====================================================

-- Index for department-based doctor searches
CREATE NONCLUSTERED INDEX IX_Doctor_DepartmentID
ON Doctor(DepartmentID)
GO

-- Index for specialization searches
CREATE NONCLUSTERED INDEX IX_Doctor_Specialization
ON Doctor(Specialization)
GO

-- =====================================================
-- PATIENT INDEXES
-- =====================================================

-- Index for patient last name searches
CREATE NONCLUSTERED INDEX IX_Patient_LastName
ON Patient(LastName)
GO

-- Index for patient registration date analysis
CREATE NONCLUSTERED INDEX IX_Patient_RegistrationDate
ON Patient(RegistrationDate)
GO

-- ============================================
-- SHOW ALL INDEXES
-- ============================================

SELECT 
    t.name AS TableName,
    COUNT(i.index_id) AS IndexCount,
    STRING_AGG(i.name, ', ') AS IndexNames
FROM sys.indexes i
JOIN sys.tables t ON i.object_id = t.object_id
WHERE i.name IS NOT NULL
GROUP BY t.name
ORDER BY t.name
GO

-- ============================================
-- PERFORMANCE TEST QUERIES
-- ============================================

-- Test 1: Appointment Search

SET STATISTICS TIME ON
SET STATISTICS IO ON

SELECT 
    a.AppointmentID,
    p.FirstName + ' ' + p.LastName AS PatientName,
    d.FirstName + ' ' + d.LastName AS DoctorName,
    a.AppointmentDate,
    aps.AppointmentStatusName
FROM Appointment a
JOIN Patient p ON a.PatientID = p.PatientID
JOIN Doctor d ON a.DoctorID = d.DoctorID
JOIN AppointmentStatus aps ON a.AppointmentStatusID = aps.AppointmentStatusID
WHERE a.AppointmentDate BETWEEN '2024-01-01' AND '2024-06-30'
ORDER BY a.AppointmentDate DESC

SET STATISTICS TIME OFF
SET STATISTICS IO OFF
GO

-- Test 2: Doctor Performance by Revenue

SET STATISTICS TIME ON
SET STATISTICS IO ON

SELECT TOP 10
    d.FirstName + ' ' + d.LastName AS DoctorName,
    dep.DepartmentName,
    COUNT(a.AppointmentID) AS TotalVisits,
    ISNULL(SUM(b.TotalAmount), 0) AS TotalRevenue
FROM Doctor d
JOIN Department dep ON d.DepartmentID = dep.DepartmentID
LEFT JOIN Appointment a ON d.DoctorID = a.DoctorID AND a.AppointmentStatusID = 2
LEFT JOIN Billing b ON a.AppointmentID = b.AppointmentID
GROUP BY d.DoctorID, d.FirstName, d.LastName, dep.DepartmentName
ORDER BY TotalRevenue DESC

SET STATISTICS TIME OFF
SET STATISTICS IO OFF
GO

-- Test 3: Outstanding Payments by Patient

SET STATISTICS TIME ON
SET STATISTICS IO ON

SELECT 
    p.FirstName + ' ' + p.LastName AS PatientName,
    COUNT(b.BillingID) AS UnpaidBills,
    SUM(b.TotalAmount) AS TotalOutstanding
FROM Patient p
JOIN Billing b ON p.PatientID = b.PatientID
JOIN PaymentStatus ps ON b.PaymentStatusID = ps.PaymentStatusID
WHERE ps.StatusName IN ('Pending', 'Insurance Pending', 'Partially Paid')
GROUP BY p.PatientID, p.FirstName, p.LastName
HAVING SUM(b.TotalAmount) > 500
ORDER BY TotalOutstanding DESC

SET STATISTICS TIME OFF
SET STATISTICS IO OFF
GO

-- ============================================
-- UPDATE STATISTICS
-- ============================================
EXEC sp_updatestats
GO