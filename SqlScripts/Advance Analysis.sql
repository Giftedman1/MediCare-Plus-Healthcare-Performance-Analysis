-- ============================================
-- MEDICARE PLUS HEALTHCARE INFORMATION SYSTEM
-- ANALYSIS
-- ============================================
USE MediCarePlusDB
GO

-- ============================================
-- TOP PERFORMING DOCTORS
-- ============================================

SELECT 
    DoctorName,
    Department,
    TotalPatients,
    CompletedVisits,
    TotalRevenue,
    AvgRevenuePerVisit,
    DoctorRank
FROM (
    SELECT 
        d.FirstName + ' ' + d.LastName AS DoctorName,
        dep.DepartmentName AS Department,
        COUNT(DISTINCT a.PatientID) AS TotalPatients,
        SUM(CASE WHEN a.AppointmentStatusID = 2 THEN 1 ELSE 0 END) AS CompletedVisits,
        ISNULL(SUM(b.TotalAmount), 0) AS TotalRevenue,
        ISNULL(AVG(b.TotalAmount), 0) AS AvgRevenuePerVisit,
        RANK() OVER (ORDER BY ISNULL(SUM(b.TotalAmount), 0) DESC) AS DoctorRank
    FROM Doctor d 
    JOIN Department dep ON d.DepartmentID = dep.DepartmentID
    LEFT JOIN Appointment a ON d.DoctorID = a.DoctorID
    LEFT JOIN Billing b ON a.AppointmentID = b.AppointmentID
    -- WHERE d.DoctorStatus = 'Active' (If on_leave doctor is excluded)
    GROUP BY d.DoctorID, d.FirstName, d.LastName, dep.DepartmentName
) AS RankedDoctors
WHERE DoctorRank <= 10
ORDER BY DoctorRank
GO

-- ============================================
-- MOST FREQUENT DIAGNOSES
-- ============================================

WITH DiagnosisCounts AS (
    SELECT 
        diag.DiagnosisName,
        COUNT(mr.MedicalRecordID) AS DiagnosisCount,
        COUNT(DISTINCT a.PatientID) AS UniquePatients
    FROM MedicalRecord mr
    JOIN Diagnosis diag ON mr.DiagnosisID = diag.DiagnosisID
    JOIN Appointment a ON mr.AppointmentID = a.AppointmentID
    WHERE a.AppointmentStatusID = 2
    GROUP BY diag.DiagnosisName
)
SELECT 
    DiagnosisName,
    DiagnosisCount,
    UniquePatients,
    RANK() OVER (ORDER BY DiagnosisCount DESC) AS FrequencyRank
FROM DiagnosisCounts
ORDER BY DiagnosisCount DESC
GO

-- ============================================
-- MONTHLY REVENUE TRENDS
-- ============================================

WITH MonthlyRevenue AS (
    SELECT 
        YEAR(b.BillingDate) AS Year,
        MONTH(b.BillingDate) AS MonthNum,
        DATENAME(MONTH, b.BillingDate) AS MonthName,
        SUM(b.TotalAmount) AS MonthlyRevenue,
        COUNT(b.BillingID) AS BillCount
    FROM Billing b
    GROUP BY YEAR(b.BillingDate), MONTH(b.BillingDate), DATENAME(MONTH, b.BillingDate)
)
SELECT 
    Year,
    MonthName,
    MonthlyRevenue,
    BillCount,
    AVG(MonthlyRevenue) OVER (PARTITION BY Year) AS YearlyAverage,
    MonthlyRevenue - LAG(MonthlyRevenue) OVER (ORDER BY Year, MonthNum) AS ChangeFromPrevious,
    SUM(MonthlyRevenue) OVER (ORDER BY Year, MonthNum) AS RunningTotal
FROM MonthlyRevenue
ORDER BY Year, MonthNum
GO

-- ============================================
-- APPOINTMENT CANCELLATION RATES
-- ============================================

WITH AppointmentStats AS (
    SELECT 
        dep.DepartmentName,
        COUNT(a.AppointmentID) AS TotalAppointments,
        SUM(CASE WHEN a.AppointmentStatusID = 3 THEN 1 ELSE 0 END) AS Cancelled,
        SUM(CASE WHEN a.AppointmentStatusID = 4 THEN 1 ELSE 0 END) AS NoShows,
        SUM(CASE WHEN a.AppointmentStatusID = 2 THEN 1 ELSE 0 END) AS Completed
    FROM Appointment a
    JOIN Doctor d ON a.DoctorID = d.DoctorID
    JOIN Department dep ON d.DepartmentID = dep.DepartmentID
    GROUP BY dep.DepartmentName
)
SELECT 
    DepartmentName,
    TotalAppointments,
    Completed,
    Cancelled,
    NoShows,
    CAST(CAST(Cancelled AS DECIMAL) / NULLIF(TotalAppointments, 0) * 100 AS DECIMAL(5,1)) AS CancellationRate,
    CAST(CAST(NoShows AS DECIMAL) / NULLIF(TotalAppointments, 0) * 100 AS DECIMAL(5,1)) AS NoShowRate,
    DENSE_RANK() OVER (ORDER BY CAST(CAST(Cancelled AS DECIMAL) / NULLIF(TotalAppointments, 0) * 100 AS DECIMAL(5,1)) DESC) AS RiskRank
FROM AppointmentStats
ORDER BY CancellationRate DESC
GO


-- ============================================
-- DEPARTMENT PERFORMANCE COMPARISON
-- ============================================

WITH DeptMetrics AS (
    SELECT 
        dep.DepartmentName,
        COUNT(DISTINCT d.DoctorID) AS DoctorCount,
        COUNT(DISTINCT a.AppointmentID) AS TotalAppointments,
        COUNT(DISTINCT CASE WHEN a.AppointmentStatusID = 2 THEN a.AppointmentID END) AS CompletedVisits,
        ISNULL(SUM(b.TotalAmount), 0) AS TotalRevenue,
        ISNULL(AVG(b.TotalAmount), 0) AS AvgBillAmount,
        COUNT(DISTINCT at.TreatmentID) AS TreatmentsPerformed
    FROM Department dep
    LEFT JOIN Doctor d ON dep.DepartmentID = d.DepartmentID
    LEFT JOIN Appointment a ON d.DoctorID = a.DoctorID
    LEFT JOIN Billing b ON a.AppointmentID = b.AppointmentID AND b.PaymentStatusID = 2
    LEFT JOIN AppointmentTreatment at ON a.AppointmentID = at.AppointmentID
    GROUP BY dep.DepartmentName
)
SELECT 
    DepartmentName,
    DoctorCount,
    TotalAppointments,
    CompletedVisits,
    TotalRevenue,
    AvgBillAmount,
    TreatmentsPerformed,
    CASE 
        WHEN DoctorCount > 0 THEN TotalAppointments / DoctorCount 
        ELSE 0 
    END AS AppointmentsPerDoctor,
    RANK() OVER (ORDER BY TotalRevenue DESC) AS RevenueRank
FROM DeptMetrics
ORDER BY TotalRevenue DESC
GO