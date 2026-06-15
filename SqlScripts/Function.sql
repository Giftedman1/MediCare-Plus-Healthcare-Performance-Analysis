-- ============================================
-- MEDICARE PLUS HEALTHCARE INFORMATION SYSTEM
-- USER-DEFINED FUNCTIONS
-- ============================================
USE MediCarePlusDB
GO

-- ============================================
-- Calculate Patient Age
-- Purpose: Returns age in years from date of birth
-- ============================================
CREATE FUNCTION fn_CalculateAge (@DateOfBirth DATE)
RETURNS INT
AS
BEGIN
    DECLARE @Age INT
    
    SET @Age = DATEDIFF(YEAR, @DateOfBirth, GETDATE()) - 
        CASE 
            WHEN DATEADD(YEAR, DATEDIFF(YEAR, @DateOfBirth, GETDATE()), @DateOfBirth) > GETDATE() 
            THEN 1 
            ELSE 0 
        END
    
    RETURN @Age
END
GO

-- ============================================
-- Get Patient Full Name
-- Purpose: Returns concatenated first and last name
-- ============================================
CREATE FUNCTION fn_GetPatientFullName (@PatientID INT)
RETURNS NVARCHAR(101)
AS
BEGIN
    DECLARE @FullName NVARCHAR(101)
    
    SELECT @FullName = FirstName + ' ' + LastName
    FROM Patient
    WHERE PatientID = @PatientID
    
    RETURN @FullName
END
GO

-- ============================================
-- Get Doctor Full Name
-- Purpose: Returns concatenated doctor name
-- ============================================
CREATE FUNCTION fn_GetDoctorFullName (@DoctorID INT)
RETURNS NVARCHAR(101)
AS
BEGIN
    DECLARE @FullName NVARCHAR(101)
    
    SELECT @FullName = FirstName + ' ' + LastName
    FROM Doctor
    WHERE DoctorID = @DoctorID
    
    RETURN @FullName
END
GO

-- ============================================
-- Calculate Appointment Duration
-- Purpose: Estimates visit duration based on treatments
-- ============================================
CREATE FUNCTION fn_GetAppointmentDuration (@AppointmentID INT)
RETURNS INT
AS
BEGIN
    DECLARE @TotalMinutes INT
    
    -- Base consultation: 30 minutes
    -- Each treatment: 20 minutes
    SELECT @TotalMinutes = 30 + (COUNT(*) * 20)
    FROM AppointmentTreatment
    WHERE AppointmentID = @AppointmentID
    
    RETURN ISNULL(@TotalMinutes, 30)
END
GO

-- ============================================
-- Calculate Prescription Days Remaining
-- Purpose: Days left on a prescription
-- ============================================
CREATE FUNCTION fn_PrescriptionDaysRemaining (@PrescriptionID INT)
RETURNS INT
AS
BEGIN
    DECLARE @DaysRemaining INT
    
    SELECT @DaysRemaining = DATEDIFF(DAY, GETDATE(), EndDate)
    FROM Prescription
    WHERE PrescriptionID = @PrescriptionID
    
    RETURN CASE WHEN @DaysRemaining < 0 THEN 0 ELSE @DaysRemaining END
END
GO

-- ============================================
-- Get Outstanding Balance
-- Purpose: Total unpaid amount for a patient
-- ============================================
CREATE FUNCTION fn_GetOutstandingBalance (@PatientID INT)
RETURNS DECIMAL(10,2)
AS
BEGIN
    DECLARE @Balance DECIMAL(10,2)
    
    SELECT @Balance = ISNULL(SUM(TotalAmount), 0)
    FROM Billing b
    JOIN PaymentStatus ps ON b.PaymentStatusID = ps.PaymentStatusID
    WHERE b.PatientID = @PatientID
    AND ps.StatusName IN ('Pending', 'Insurance Pending', 'Partially Paid')
    
    RETURN ISNULL(@Balance, 0)
END
GO

-- ============================================
-- Get Appointment Count by Patient
-- Purpose: Total appointments for a patient
-- ============================================
CREATE FUNCTION fn_GetPatientAppointmentCount (@PatientID INT)
RETURNS INT
AS
BEGIN
    DECLARE @Count INT
    
    SELECT @Count = COUNT(*) FROM Appointment WHERE PatientID = @PatientID
    
    RETURN ISNULL(@Count, 0)
END
GO

-- ============================================
-- Get Doctor Completion Rate
-- Purpose: Percentage of completed appointments
-- ============================================
CREATE FUNCTION fn_GetDoctorCompletionRate (@DoctorID INT)
RETURNS DECIMAL(5,1)
AS
BEGIN
    DECLARE @Total INT
    DECLARE @Completed INT
    DECLARE @Rate DECIMAL(5,1)
    
    SELECT @Total = COUNT(*) FROM Appointment WHERE DoctorID = @DoctorID
    SELECT @Completed = COUNT(*) FROM Appointment WHERE DoctorID = @DoctorID AND AppointmentStatusID = 2
    
    IF @Total > 0
        SET @Rate = CAST(@Completed AS DECIMAL) / CAST(@Total AS DECIMAL) * 100
    ELSE
        SET @Rate = 0
    
    RETURN @Rate
END
GO

-- ============================================
-- Get Patient Age Group
-- Purpose: Categorize patient by age group
-- ============================================
CREATE FUNCTION fn_GetPatientAgeGroup (@PatientID INT)
RETURNS NVARCHAR(20)
AS
BEGIN
    DECLARE @Age INT
    DECLARE @AgeGroup NVARCHAR(20)
    DECLARE @DOB DATE
    
    SELECT @DOB = DateOfBirth FROM Patient WHERE PatientID = @PatientID
    SET @Age = dbo.fn_CalculateAge(@DOB)
    
    SET @AgeGroup = 
        CASE 
            WHEN @Age < 18 THEN 'Pediatric'
            WHEN @Age BETWEEN 18 AND 35 THEN 'Young Adult'
            WHEN @Age BETWEEN 36 AND 55 THEN 'Middle Aged'
            WHEN @Age BETWEEN 56 AND 75 THEN 'Senior'
            ELSE 'Elderly'
        END
    
    RETURN @AgeGroup
END
GO

-- ============================================
-- Get Appointments by Date Range 
-- Purpose: Returns a table of appointments in range
-- ============================================
CREATE FUNCTION fn_GetAppointmentsByDateRange (@FromDate DATE, @ToDate DATE)
RETURNS TABLE
AS
RETURN (
    SELECT 
        a.AppointmentID,
        a.AppointmentDate,
        a.Reason,
        dbo.fn_GetPatientFullName(a.PatientID) AS PatientName,
        dbo.fn_GetDoctorFullName(a.DoctorID) AS DoctorName,
        aps.AppointmentStatusName AS Status
    FROM Appointment a
    JOIN AppointmentStatus aps ON a.AppointmentStatusID = aps.AppointmentStatusID
    WHERE CAST(a.AppointmentDate AS DATE) BETWEEN @FromDate AND @ToDate
)
GO

-- ============================================
-- Get Patient Medical Summary
-- Purpose: Returns complete medical summary for a patient
-- ============================================
CREATE FUNCTION fn_GetPatientMedicalSummary (@PatientID INT)
RETURNS TABLE
AS
RETURN (
    SELECT 
        a.AppointmentDate,
        dep.DepartmentName,
        dbo.fn_GetDoctorFullName(a.DoctorID) AS DoctorName,
        diag.DiagnosisName,
        mr.Observation,
        STRING_AGG(ISNULL(t.TreatmentName, 'None'), ', ') AS Treatments,
        STRING_AGG(ISNULL(pr.MedicationName, 'None'), ', ') AS Medications
    FROM Appointment a
    JOIN Doctor doc ON a.DoctorID = doc.DoctorID
    JOIN Department dep ON doc.DepartmentID = dep.DepartmentID
    JOIN MedicalRecord mr ON a.AppointmentID = mr.AppointmentID
    JOIN Diagnosis diag ON mr.DiagnosisID = diag.DiagnosisID
    LEFT JOIN AppointmentTreatment at ON a.AppointmentID = at.AppointmentID
    LEFT JOIN Treatment t ON at.TreatmentID = t.TreatmentID
    LEFT JOIN Prescription pr ON mr.MedicalRecordID = pr.MedicalRecordID
    WHERE a.PatientID = @PatientID AND a.AppointmentStatusID = 2
    GROUP BY a.AppointmentDate, dep.DepartmentName, a.DoctorID, diag.DiagnosisName, mr.Observation
)
GO

-- ============================================
-- Get Department Revenue
-- Purpose: Returns revenue breakdown by department
-- ============================================
CREATE FUNCTION fn_GetDepartmentRevenue (@Year INT)
RETURNS TABLE
AS
RETURN (
    SELECT 
        dep.DepartmentID,
        dep.DepartmentName,
        ISNULL(SUM(b.TotalAmount), 0) AS TotalRevenue,
        COUNT(DISTINCT b.BillingID) AS TotalBills,
        ISNULL(AVG(b.TotalAmount), 0) AS AverageBill
    FROM Department dep
    LEFT JOIN Doctor d ON dep.DepartmentID = d.DepartmentID
    LEFT JOIN Appointment a ON d.DoctorID = a.DoctorID
    LEFT JOIN Billing b ON a.AppointmentID = b.AppointmentID
        AND YEAR(b.BillingDate) = @Year
    GROUP BY dep.DepartmentID, dep.DepartmentName
)
GO
