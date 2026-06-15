-- ============================================
-- MEDICARE PLUS HEALTHCARE INFORMATION SYSTEM
-- VIEWS FOR REPORTING & ANALYSIS
-- ============================================
USE MediCarePlusDB
GO

-- ============================================
-- Comprehensive Appointment Overview
-- Purpose: Complete appointment details with patient, doctor, status
-- ============================================
CREATE VIEW vw_AppointmentOverview
AS
SELECT 
    a.AppointmentID,
    a.AppointmentDate,
    a.Reason,
    p.PatientID,
    p.FirstName + ' ' + p.LastName AS PatientName,
    p.Gender AS PatientGender,
    DATEDIFF(YEAR, p.DateOfBirth, GETDATE()) AS PatientAge,
    p.PhoneNumber AS PatientPhone,
    p.Email AS PatientEmail,
    d.DoctorID,
    d.FirstName + ' ' + d.LastName AS DoctorName,
    d.Specialization,
    dep.DepartmentName,
    aps.AppointmentStatusName AS Status,
    CASE 
        WHEN a.AppointmentDate > GETDATE() THEN 'Upcoming'
        WHEN a.AppointmentDate <= GETDATE() THEN 'Past'
        ELSE 'Unknown'
    END AS AppointmentTiming
FROM Appointment a
JOIN Patient p ON a.PatientID = p.PatientID
JOIN Doctor d ON a.DoctorID = d.DoctorID
JOIN Department dep ON d.DepartmentID = dep.DepartmentID
JOIN AppointmentStatus aps ON a.AppointmentStatusID = aps.AppointmentStatusID
GO



-- ============================================
-- Patient Medical History
-- Purpose: Complete medical history per patient
-- ============================================
CREATE VIEW vw_PatientMedicalHistory
AS
SELECT 
    p.PatientID,
    p.FirstName + ' ' + p.LastName AS PatientName,
    p.DateOfBirth,
    DATEDIFF(YEAR, p.DateOfBirth, GETDATE()) AS Age,
    p.Gender,
    a.AppointmentID,
    a.AppointmentDate,
    a.Reason AS VisitReason,
    diag.DiagnosisCode,
    diag.DiagnosisName,
    mr.Observation,
    mr.ClinicalNotes,
    mr.RecordDate,
    aps.AppointmentStatusName
FROM Patient p
LEFT JOIN Appointment a ON p.PatientID = a.PatientID
LEFT JOIN MedicalRecord mr ON a.AppointmentID = mr.AppointmentID
LEFT JOIN Diagnosis diag ON mr.DiagnosisID = diag.DiagnosisID
LEFT JOIN AppointmentStatus aps ON a.AppointmentStatusID = aps.AppointmentStatusID
WHERE a.AppointmentStatusID = 2  -- Completed only
GO

-- ============================================
-- Billing Overview
-- Purpose: Complete billing details with payment status
-- ============================================
CREATE VIEW vw_BillingOverview
AS
SELECT 
    b.BillingID,
    b.BillingDate,
    b.TotalAmount,
    p.PatientID,
    p.FirstName + ' ' + p.LastName AS PatientName,
    a.AppointmentID,
    a.AppointmentDate,
    a.Reason AS VisitReason,
    d.FirstName + ' ' + d.LastName AS DoctorName,
    dep.DepartmentName,
    pm.MethodName AS PaymentMethod,
    ps.StatusName AS PaymentStatus,
    CASE 
        WHEN ps.StatusName = 'Completed' THEN 'Settled'
        WHEN ps.StatusName IN ('Pending', 'Insurance Pending', 'Partially Paid') THEN 'Unsettled'
        WHEN ps.StatusName = 'Failed' THEN 'Problematic'
        WHEN ps.StatusName = 'Refunded' THEN 'Returned'
        ELSE 'Unknown'
    END AS PaymentCategory
FROM Billing b
JOIN Patient p ON b.PatientID = p.PatientID
JOIN Appointment a ON b.AppointmentID = a.AppointmentID
JOIN Doctor d ON a.DoctorID = d.DoctorID
JOIN Department dep ON d.DepartmentID = dep.DepartmentID
JOIN PaymentMethod pm ON b.PaymentMethodID = pm.PaymentMethodID
JOIN PaymentStatus ps ON b.PaymentStatusID = ps.PaymentStatusID
GO


-- ============================================
-- Treatment Summary
-- Purpose: All treatments performed with costs
-- ============================================
CREATE VIEW vw_TreatmentSummary
AS
SELECT 
    at.AppointmentTreatmentID,
    a.AppointmentID,
    a.AppointmentDate,
    p.PatientID,
    p.FirstName + ' ' + p.LastName AS PatientName,
    d.DoctorID,
    d.FirstName + ' ' + d.LastName AS DoctorName,
    dep.DepartmentName,
    t.TreatmentID,
    t.TreatmentName,
    t.TreatmentCode,
    at.Quantity,
    at.ActualCost,
    (at.ActualCost / at.Quantity) AS UnitCost
FROM AppointmentTreatment at
JOIN Appointment a ON at.AppointmentID = a.AppointmentID
JOIN Patient p ON a.PatientID = p.PatientID
JOIN Doctor d ON a.DoctorID = d.DoctorID
JOIN Department dep ON d.DepartmentID = dep.DepartmentID
JOIN Treatment t ON at.TreatmentID = t.TreatmentID
GO



-- ============================================
-- Prescription Overview
-- Purpose: All prescriptions with patient and doctor details
-- ============================================
CREATE VIEW vw_PrescriptionOverview
AS
SELECT 
    pr.PrescriptionID,
    pr.MedicationName,
    pr.Dosage,
    pr.Frequency,
    pr.StartDate,
    pr.EndDate,
    DATEDIFF(DAY, pr.StartDate, pr.EndDate) AS DurationDays,
    CASE 
        WHEN pr.EndDate >= GETDATE() THEN 'Active'
        ELSE 'Completed'
    END AS PrescriptionStatus,
    p.PatientID,
    p.FirstName + ' ' + p.LastName AS PatientName,
    d.FirstName + ' ' + d.LastName AS DoctorName,
    diag.DiagnosisName,
    mr.RecordDate AS DiagnosisDate,
    a.AppointmentDate
FROM Prescription pr
JOIN MedicalRecord mr ON pr.MedicalRecordID = mr.MedicalRecordID
JOIN Appointment a ON mr.AppointmentID = a.AppointmentID
JOIN Patient p ON a.PatientID = p.PatientID
JOIN Doctor d ON a.DoctorID = d.DoctorID
JOIN Diagnosis diag ON mr.DiagnosisID = diag.DiagnosisID
GO

-- ============================================
-- Doctor Performance Summary
-- Purpose: Doctor workload and performance metrics
-- ============================================
CREATE VIEW vw_DoctorPerformance
AS
SELECT 
    d.DoctorID,
    d.FirstName + ' ' + d.LastName AS DoctorName,
    d.Specialization,
    dep.DepartmentName,
    d.HireDate,
    DATEDIFF(YEAR, d.HireDate, GETDATE()) AS YearsOfService,
    d.DoctorStatus,
    COUNT(DISTINCT a.AppointmentID) AS TotalAppointments,
    SUM(CASE WHEN a.AppointmentStatusID = 2 THEN 1 ELSE 0 END) AS CompletedAppointments,
    SUM(CASE WHEN a.AppointmentStatusID = 3 THEN 1 ELSE 0 END) AS CancelledAppointments,
    SUM(CASE WHEN a.AppointmentStatusID = 4 THEN 1 ELSE 0 END) AS NoShows,
    CAST(
        CASE 
            WHEN COUNT(DISTINCT a.AppointmentID) > 0 
            THEN (SUM(CASE WHEN a.AppointmentStatusID = 2 THEN 1.0 ELSE 0 END) / COUNT(DISTINCT a.AppointmentID)) * 100
            ELSE 0 
        END AS DECIMAL(5,1)
    ) AS CompletionRate,
    COUNT(DISTINCT a.PatientID) AS UniquePatients,
    ISNULL(SUM(b.TotalAmount), 0) AS TotalRevenueGenerated
FROM Doctor d
JOIN Department dep ON d.DepartmentID = dep.DepartmentID
LEFT JOIN Appointment a ON d.DoctorID = a.DoctorID
LEFT JOIN Billing b ON a.AppointmentID = b.AppointmentID
GROUP BY 
    d.DoctorID, d.FirstName, d.LastName, d.Specialization, 
    dep.DepartmentName, d.HireDate, d.DoctorStatus
GO


-- ============================================
-- Department Analytics
-- Purpose: Department-level statistics
-- ============================================
CREATE VIEW vw_DepartmentAnalytics
AS
SELECT 
    dep.DepartmentID,
    dep.DepartmentName,
    COUNT(DISTINCT d.DoctorID) AS TotalDoctors,
    COUNT(DISTINCT a.AppointmentID) AS TotalAppointments,
    COUNT(DISTINCT CASE WHEN a.AppointmentStatusID = 2 THEN a.AppointmentID END) AS CompletedAppointments,
    COUNT(DISTINCT mr.MedicalRecordID) AS MedicalRecords,
    COUNT(DISTINCT pr.PrescriptionID) AS PrescriptionsIssued,
    ISNULL(SUM(b.TotalAmount), 0) AS TotalRevenue,
    ISNULL(AVG(b.TotalAmount), 0) AS AverageBillAmount,
    COUNT(DISTINCT t.TreatmentID) AS UniqueTreatmentsOffered
FROM Department dep
LEFT JOIN Doctor d ON dep.DepartmentID = d.DepartmentID
LEFT JOIN Appointment a ON d.DoctorID = a.DoctorID
LEFT JOIN MedicalRecord mr ON a.AppointmentID = mr.AppointmentID
LEFT JOIN Prescription pr ON mr.MedicalRecordID = pr.MedicalRecordID
LEFT JOIN Billing b ON a.AppointmentID = b.AppointmentID
LEFT JOIN Treatment t ON dep.DepartmentID = t.DepartmentID
GROUP BY dep.DepartmentID, dep.DepartmentName
GO

-- ============================================
-- Revenue Summary
-- Purpose: Financial overview for reporting
-- ============================================
CREATE VIEW vw_RevenueSummary
AS
SELECT 
    YEAR(b.BillingDate) AS Year,
    MONTH(b.BillingDate) AS Month,
    DATENAME(MONTH, b.BillingDate) AS MonthName,
    COUNT(*) AS TotalBills,
    SUM(b.TotalAmount) AS TotalRevenue,
    AVG(b.TotalAmount) AS AverageBill,
    SUM(CASE WHEN ps.StatusName = 'Completed' THEN b.TotalAmount ELSE 0 END) AS CollectedRevenue,
    SUM(CASE WHEN ps.StatusName IN ('Pending', 'Insurance Pending', 'Partially Paid') THEN b.TotalAmount ELSE 0 END) AS OutstandingRevenue,
    CAST(
        SUM(CASE WHEN ps.StatusName = 'Completed' THEN b.TotalAmount ELSE 0 END) / 
        NULLIF(SUM(b.TotalAmount), 0) * 100 
    AS DECIMAL(5,1)) AS CollectionRate
FROM Billing b
JOIN PaymentStatus ps ON b.PaymentStatusID = ps.PaymentStatusID
GROUP BY YEAR(b.BillingDate), MONTH(b.BillingDate), DATENAME(MONTH, b.BillingDate)
GO

-- ============================================
-- Patient Demographics
-- Purpose: Patient population analysis
-- ============================================
CREATE VIEW vw_PatientDemographics
AS
SELECT 
    PatientID,
    FirstName + ' ' + LastName AS PatientName,
    Gender,
    DATEDIFF(YEAR, DateOfBirth, GETDATE()) AS Age,
    CASE 
        WHEN DATEDIFF(YEAR, DateOfBirth, GETDATE()) < 18 THEN 'Pediatric'
        WHEN DATEDIFF(YEAR, DateOfBirth, GETDATE()) BETWEEN 18 AND 35 THEN 'Young Adult'
        WHEN DATEDIFF(YEAR, DateOfBirth, GETDATE()) BETWEEN 36 AND 55 THEN 'Middle Aged'
        WHEN DATEDIFF(YEAR, DateOfBirth, GETDATE()) BETWEEN 56 AND 75 THEN 'Senior'
        ELSE 'Elderly'
    END AS AgeGroup,
    DateOfBirth,
    YEAR(RegistrationDate) AS RegistrationYear,
    Status,
    Address
FROM Patient
GO

-- ============================================
-- Appointment Analytics
-- Purpose: Appointment trends and patterns
-- ============================================
CREATE VIEW vw_AppointmentAnalytics
AS
SELECT 
    YEAR(a.AppointmentDate) AS Year,
    MONTH(a.AppointmentDate) AS Month,
    DATENAME(MONTH, a.AppointmentDate) AS MonthName,
    DATENAME(WEEKDAY, a.AppointmentDate) AS DayOfWeek,
    DATEPART(HOUR, a.AppointmentDate) AS HourOfDay,
    aps.AppointmentStatusName,
    dep.DepartmentName,
    COUNT(*) AS AppointmentCount
FROM Appointment a
JOIN AppointmentStatus aps ON a.AppointmentStatusID = aps.AppointmentStatusID
JOIN Doctor d ON a.DoctorID = d.DoctorID
JOIN Department dep ON d.DepartmentID = dep.DepartmentID
GROUP BY 
    YEAR(a.AppointmentDate), MONTH(a.AppointmentDate), 
    DATENAME(MONTH, a.AppointmentDate), DATENAME(WEEKDAY, a.AppointmentDate),
    DATEPART(HOUR, a.AppointmentDate), aps.AppointmentStatusName, dep.DepartmentName
GO
