-- ============================================
-- MEDICARE PLUS HEALTHCARE INFORMATION SYSTEM
-- ETL PROCESS - POPULATE DATA WAREHOUSE
-- ============================================
USE MediCarePlusDB
GO

-- ============================================
-- POPULATE DimDate
-- ============================================

DECLARE @StartDate DATE
DECLARE @EndDate DATE

-- Auto-detect from actual appointment data
SELECT @StartDate = CAST(MIN(AppointmentDate) AS DATE) FROM Appointment
SELECT @EndDate = CAST(MAX(AppointmentDate) AS DATE) FROM Appointment

-- Expand to full years (Jan 1 of first year to Dec 31 of last year)
SET @StartDate = DATEFROMPARTS(YEAR(@StartDate), 1, 1)
SET @EndDate = DATEFROMPARTS(YEAR(@EndDate), 12, 31)


DECLARE @CurrentDate DATE = @StartDate

WHILE @CurrentDate <= @EndDate
BEGIN
    INSERT INTO DimDate (DateKey, FullDate, DayOfWeek, DayOfMonth, MonthNumber, MonthName, Quarter, Year, IsWeekend)
    VALUES (
        CAST(CONVERT(NVARCHAR(8), @CurrentDate, 112) AS INT),   -- DateKey (YYYYMMDD)
        @CurrentDate,                                            -- FullDate
        DATENAME(WEEKDAY, @CurrentDate),                        -- DayOfWeek
        DAY(@CurrentDate),                                       -- DayOfMonth
        MONTH(@CurrentDate),                                     -- MonthNumber
        DATENAME(MONTH, @CurrentDate),                          -- MonthName
        DATEPART(QUARTER, @CurrentDate),                        -- Quarter
        YEAR(@CurrentDate),                                      -- Year
        CASE WHEN DATENAME(WEEKDAY, @CurrentDate) IN ('Saturday', 'Sunday') THEN 1 ELSE 0 END  -- IsWeekend
    )
    SET @CurrentDate = DATEADD(DAY, 1, @CurrentDate)
END
GO

-- ============================================
-- POPULATE DimPatient
-- ============================================

INSERT INTO DimPatient (PatientID, FirstName, LastName, FullName, DateOfBirth, Age, AgeGroup, Gender, City, RegistrationDate, PatientStatus)
SELECT 
    PatientID,
    FirstName,
    LastName,
    FirstName + ' ' + LastName AS FullName,
    DateOfBirth,
    DATEDIFF(YEAR, DateOfBirth, GETDATE()) AS Age,
    CASE 
        WHEN DATEDIFF(YEAR, DateOfBirth, GETDATE()) < 18 THEN 'Pediatric'
        WHEN DATEDIFF(YEAR, DateOfBirth, GETDATE()) BETWEEN 18 AND 35 THEN 'Young Adult'
        WHEN DATEDIFF(YEAR, DateOfBirth, GETDATE()) BETWEEN 36 AND 55 THEN 'Middle Aged'
        WHEN DATEDIFF(YEAR, DateOfBirth, GETDATE()) BETWEEN 56 AND 75 THEN 'Senior'
        ELSE 'Elderly'
    END AS AgeGroup,
    Gender,
    RIGHT(Address, CHARINDEX(',', REVERSE(Address)) - 1) AS City,
    RegistrationDate,
    Status AS PatientStatus
FROM Patient
GO

-- ============================================
-- POPULATE DimDoctor
-- ============================================

INSERT INTO DimDoctor (DoctorID, FirstName, LastName, FullName, Specialization, DepartmentID, DepartmentName, LicenseNumber, HireDate, DoctorStatus)
SELECT 
    d.DoctorID,
    d.FirstName,
    d.LastName,
    d.FirstName + ' ' + d.LastName AS FullName,
    d.Specialization,
    d.DepartmentID,
    dep.DepartmentName,
    d.LicenseNumber,
    d.HireDate,
    d.DoctorStatus
FROM Doctor d
JOIN Department dep ON d.DepartmentID = dep.DepartmentID
GO

-- ============================================
-- POPULATE DimDepartment
-- ============================================

INSERT INTO DimDepartment (DepartmentID, DepartmentName, Description)
SELECT DepartmentID, DepartmentName, Description
FROM Department
GO

-- ============================================
-- POPULATE DimDiagnosis
-- ============================================

INSERT INTO DimDiagnosis (DiagnosisID, DiagnosisCode, DiagnosisName, Description)
SELECT DiagnosisID, DiagnosisCode, DiagnosisName, Description
FROM Diagnosis
GO

-- ============================================
-- POPULATE DimPaymentStatus
-- ============================================

INSERT INTO DimPaymentStatus (PaymentStatusID, StatusName, Description)
SELECT PaymentStatusID, StatusName, Description
FROM PaymentStatus
GO

-- ============================================
-- POPULATE DimPaymentMethod
-- ============================================

INSERT INTO DimPaymentMethod (PaymentMethodID, MethodName, Description)
SELECT PaymentMethodID, MethodName, Description
FROM PaymentMethod
GO

-- ============================================
-- POPULATE DimAppointmentStatus
-- ============================================
INSERT INTO DimAppointmentStatus (AppointmentStatusID, AppointmentStatusName, Description)
SELECT AppointmentStatusID, AppointmentStatusName, Description
FROM AppointmentStatus
GO

-- ============================================
-- POPULATE DimTreatment
-- ============================================

INSERT INTO DimTreatment (TreatmentID, TreatmentName, TreatmentCode, Description, StandardCost, DepartmentID, DepartmentName)
SELECT 
    t.TreatmentID,
    t.TreatmentName,
    t.TreatmentCode,
    t.Description,
    t.StandardCost,
    t.DepartmentID,
    dep.DepartmentName
FROM Treatment t
JOIN Department dep ON t.DepartmentID = dep.DepartmentID
GO

-- ============================================
-- POPULATE FactAppointments
-- ============================================
INSERT INTO FactAppointments (AppointmentID, PatientKey, DoctorKey, DepartmentKey, AppointmentDateKey, DiagnosisKey, AppointmentStatusKey, IsCompleted, IsCancelled, IsNoShow)
SELECT 
    a.AppointmentID,
    dp.PatientKey,
    dd.DoctorKey,
    ddep.DepartmentKey,
    CAST(CONVERT(NVARCHAR(8), a.AppointmentDate, 112) AS INT),
    ddiag.DiagnosisKey,
    das.AppointmentStatusKey,
    CASE WHEN a.AppointmentStatusID = 2 THEN 1 ELSE 0 END,
    CASE WHEN a.AppointmentStatusID = 3 THEN 1 ELSE 0 END,
    CASE WHEN a.AppointmentStatusID = 4 THEN 1 ELSE 0 END
FROM Appointment a
JOIN DimPatient dp ON a.PatientID = dp.PatientID
JOIN DimDoctor dd ON a.DoctorID = dd.DoctorID
JOIN Doctor d ON a.DoctorID = d.DoctorID
JOIN DimDepartment ddep ON d.DepartmentID = ddep.DepartmentID
LEFT JOIN MedicalRecord mr ON a.AppointmentID = mr.AppointmentID
LEFT JOIN DimDiagnosis ddiag ON mr.DiagnosisID = ddiag.DiagnosisID
JOIN DimAppointmentStatus das ON a.AppointmentStatusID = das.AppointmentStatusID
GO

-- ============================================
-- POPULATE FactBilling
-- ============================================

INSERT INTO FactBilling (BillingID, PatientKey, DoctorKey, DepartmentKey, BillingDateKey, PaymentStatusKey, PaymentMethodKey, TotalAmount, IsPaid, IsOutstanding)
SELECT 
    b.BillingID,
    dp.PatientKey,
    dd.DoctorKey,
    ddep.DepartmentKey,
    CAST(CONVERT(NVARCHAR(8), b.BillingDate, 112) AS INT),
    dps.PaymentStatusKey,
    dpm.PaymentMethodKey,
    b.TotalAmount,
    CASE WHEN ps.StatusName = 'Completed' THEN 1 ELSE 0 END AS IsPaid,
    CASE WHEN ps.StatusName IN ('Pending', 'Insurance Pending', 'Partially Paid') THEN 1 ELSE 0 END AS IsOutstanding
FROM Billing b
JOIN DimPatient dp ON b.PatientID = dp.PatientID
JOIN Appointment a ON b.AppointmentID = a.AppointmentID
JOIN DimDoctor dd ON a.DoctorID = dd.DoctorID
JOIN Doctor d ON a.DoctorID = d.DoctorID
JOIN DimDepartment ddep ON d.DepartmentID = ddep.DepartmentID
JOIN PaymentStatus ps ON b.PaymentStatusID = ps.PaymentStatusID
JOIN DimPaymentStatus dps ON b.PaymentStatusID = dps.PaymentStatusID
JOIN DimPaymentMethod dpm ON b.PaymentMethodID = dpm.PaymentMethodID
GO

-- ============================================
-- POPULATE FactTreatments
-- ============================================

INSERT INTO FactTreatments (AppointmentTreatmentID, PatientKey, DoctorKey, DepartmentKey, TreatmentKey, AppointmentDateKey, Quantity, ActualCost, TotalCost)
SELECT 
    at.AppointmentTreatmentID,
    dp.PatientKey,
    dd.DoctorKey,
    ddep.DepartmentKey,
    dt.TreatmentKey,
    CAST(CONVERT(NVARCHAR(8), a.AppointmentDate, 112) AS INT),
    at.Quantity,
    at.ActualCost,
    (at.Quantity * at.ActualCost) AS TotalCost
FROM AppointmentTreatment at
JOIN Appointment a ON at.AppointmentID = a.AppointmentID
JOIN DimPatient dp ON a.PatientID = dp.PatientID
JOIN DimDoctor dd ON a.DoctorID = dd.DoctorID
JOIN Doctor d ON a.DoctorID = d.DoctorID
JOIN DimDepartment ddep ON d.DepartmentID = ddep.DepartmentID
JOIN DimTreatment dt ON at.TreatmentID = dt.TreatmentID
GO

