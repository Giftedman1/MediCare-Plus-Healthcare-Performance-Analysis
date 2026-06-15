-- ============================================
-- MEDICARE PLUS HEALTHCARE INFORMATION SYSTEM
-- STORED PROCEDURES
-- ============================================
USE MediCarePlusDB
GO

-- ============================================
-- Search Doctors by Name, Specialization, or Department
-- ============================================
CREATE PROCEDURE sp_SearchDoctors
    @SearchTerm     NVARCHAR(100) = NULL,
    @DepartmentID   INT = NULL,
    @Status         NVARCHAR(20) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        d.DoctorID,
        d.FirstName + ' ' + d.LastName AS DoctorName,
        d.Specialization,
        d.LicenseNumber,
        dep.DepartmentName,
        d.Email,
        d.PhoneNumber,
        d.HireDate,
        d.DoctorStatus,
        (SELECT COUNT(*) FROM Appointment a WHERE a.DoctorID = d.DoctorID) AS TotalAppointments
    FROM Doctor d
    JOIN Department dep ON d.DepartmentID = dep.DepartmentID
    WHERE 
        (@SearchTerm IS NULL OR 
         d.FirstName LIKE '%' + @SearchTerm + '%' OR 
         d.LastName LIKE '%' + @SearchTerm + '%' OR 
         d.Specialization LIKE '%' + @SearchTerm + '%')
        AND (@DepartmentID IS NULL OR d.DepartmentID = @DepartmentID)
        AND (@Status IS NULL OR d.DoctorStatus = @Status)
    ORDER BY d.LastName, d.FirstName
END
GO

-- ============================================
-- Get Appointments by Patient
-- ============================================
CREATE PROCEDURE sp_GetPatientAppointments
    @PatientID      INT = NULL,
    @PatientName    NVARCHAR(100) = NULL,
    @StatusID       INT = NULL,
    @FromDate       DATE = NULL,
    @ToDate         DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        a.AppointmentID,
        a.AppointmentDate,
        a.Reason,
        p.PatientID,
        p.FirstName + ' ' + p.LastName AS PatientName,
        d.FirstName + ' ' + d.LastName AS DoctorName,
        d.Specialization,
        dep.DepartmentName,
        aps.AppointmentStatusName AS Status
    FROM Appointment a
    JOIN Patient p ON a.PatientID = p.PatientID
    JOIN Doctor d ON a.DoctorID = d.DoctorID
    JOIN Department dep ON d.DepartmentID = dep.DepartmentID
    JOIN AppointmentStatus aps ON a.AppointmentStatusID = aps.AppointmentStatusID
    WHERE 
        (@PatientID IS NULL OR a.PatientID = @PatientID)
        AND (@PatientName IS NULL OR 
             p.FirstName LIKE '%' + @PatientName + '%' OR 
             p.LastName LIKE '%' + @PatientName + '%')
        AND (@StatusID IS NULL OR a.AppointmentStatusID = @StatusID)
        AND (@FromDate IS NULL OR CAST(a.AppointmentDate AS DATE) >= @FromDate)
        AND (@ToDate IS NULL OR CAST(a.AppointmentDate AS DATE) <= @ToDate)
    ORDER BY a.AppointmentDate DESC
END
GO

-- ============================================
-- Get Appointments by Doctor
-- ============================================
CREATE PROCEDURE sp_GetDoctorAppointments
    @DoctorID       INT,
    @FromDate       DATE = NULL,
    @ToDate         DATE = NULL,
    @StatusID       INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        a.AppointmentID,
        a.AppointmentDate,
        a.Reason,
        p.PatientID,
        p.FirstName + ' ' + p.LastName AS PatientName,
        p.PhoneNumber AS PatientPhone,
        aps.AppointmentStatusName AS Status,
        CASE 
            WHEN a.AppointmentDate > GETDATE() THEN 'Upcoming'
            ELSE 'Past'
        END AS Timing
    FROM Appointment a
    JOIN Patient p ON a.PatientID = p.PatientID
    JOIN AppointmentStatus aps ON a.AppointmentStatusID = aps.AppointmentStatusID
    WHERE 
        a.DoctorID = @DoctorID
        AND (@FromDate IS NULL OR CAST(a.AppointmentDate AS DATE) >= @FromDate)
        AND (@ToDate IS NULL OR CAST(a.AppointmentDate AS DATE) <= @ToDate)
        AND (@StatusID IS NULL OR a.AppointmentStatusID = @StatusID)
    ORDER BY a.AppointmentDate
END
GO

-- ============================================
-- Schedule New Appointment
-- Purpose: Book appointment only if slot is actually available
-- Ignores cancelled appointments when checking availability
-- ============================================
CREATE PROCEDURE sp_ScheduleAppointment
    @PatientID          INT,
    @DoctorID           INT,
    @AppointmentDate    DATETIME,
    @Reason             NVARCHAR(500)
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        -- Check if patient exists
        IF NOT EXISTS (SELECT 1 FROM Patient WHERE PatientID = @PatientID)
        BEGIN
            RAISERROR('Patient does not exist.', 16, 1)
            RETURN
        END
        
        -- Check if doctor exists and is active
        IF NOT EXISTS (SELECT 1 FROM Doctor WHERE DoctorID = @DoctorID AND DoctorStatus = 'Active')
        BEGIN
            RAISERROR('Doctor does not exist or is not active.', 16, 1)
            RETURN
        END
        
        -- Check if slot is actually available (ignore cancelled)
        IF EXISTS (
            SELECT 1 FROM Appointment 
            WHERE DoctorID = @DoctorID 
            AND AppointmentDate = @AppointmentDate
            AND AppointmentStatusID IN (1, 2,4, 5)  -- Scheduled, Completed,No-Show or Rescheduled
        )
        BEGIN
            RAISERROR('Doctor is already booked at this time. Please choose a different slot.', 16, 1)
            RETURN
        END
        
        -- Insert appointment
        INSERT INTO Appointment (PatientID, DoctorID, AppointmentDate, Reason, AppointmentStatusID)
        VALUES (@PatientID, @DoctorID, @AppointmentDate, @Reason, 1) -- Status: Scheduled
        
        SELECT 
            SCOPE_IDENTITY() AS NewAppointmentID,
            'Appointment scheduled successfully.' AS Message
            
    END TRY
    BEGIN CATCH
        SELECT 
            ERROR_NUMBER() AS ErrorNumber,
            ERROR_MESSAGE() AS ErrorMessage
    END CATCH
END
GO


-- ============================================
-- Update Appointment Status
-- ============================================
CREATE PROCEDURE sp_UpdateAppointmentStatus
    @AppointmentID      INT,
    @NewStatusID        INT,
    @Notes              NVARCHAR(500) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        -- Check if appointment exists
        IF NOT EXISTS (SELECT 1 FROM Appointment WHERE AppointmentID = @AppointmentID)
        BEGIN
            RAISERROR('Appointment does not exist.', 16, 1)
            RETURN
        END
        
        -- Check if status is valid
        IF NOT EXISTS (SELECT 1 FROM AppointmentStatus WHERE AppointmentStatusID = @NewStatusID)
        BEGIN
            RAISERROR('Invalid appointment status.', 16, 1)
            RETURN
        END
        
        -- Get current status
        DECLARE @CurrentStatusID INT
        DECLARE @OldStatusName NVARCHAR(50)
        DECLARE @NewStatusName NVARCHAR(50)
        
        SELECT @CurrentStatusID = AppointmentStatusID FROM Appointment WHERE AppointmentID = @AppointmentID
        SELECT @OldStatusName = AppointmentStatusName FROM AppointmentStatus WHERE AppointmentStatusID = @CurrentStatusID
        SELECT @NewStatusName = AppointmentStatusName FROM AppointmentStatus WHERE AppointmentStatusID = @NewStatusID
        
        -- Prevent invalid transitions
        IF @CurrentStatusID = 2 AND @NewStatusID IN (3, 4) -- Can't cancel/no-show after completed
        BEGIN
            RAISERROR('Cannot change status from Completed to Cancelled or No-Show.', 16, 1)
            RETURN
        END
        
        -- Update status
        UPDATE Appointment
        SET AppointmentStatusID = @NewStatusID
        WHERE AppointmentID = @AppointmentID
        
        SELECT 
            @AppointmentID AS AppointmentID,
            @OldStatusName AS PreviousStatus,
            @NewStatusName AS NewStatus,
            'Status updated successfully.' AS Message
            
    END TRY
    BEGIN CATCH
        SELECT 
            ERROR_NUMBER() AS ErrorNumber,
            ERROR_MESSAGE() AS ErrorMessage
    END CATCH
END
GO

-- ============================================
-- Delete/Cancel Appointment
-- ============================================
CREATE PROCEDURE sp_DeleteAppointment
    @AppointmentID  INT,
    @Reason         NVARCHAR(500) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        -- Check if appointment exists
        IF NOT EXISTS (SELECT 1 FROM Appointment WHERE AppointmentID = @AppointmentID)
        BEGIN
            RAISERROR('Appointment does not exist.', 16, 1)
            RETURN
        END
        
        -- Check if appointment has billing
        IF EXISTS (SELECT 1 FROM Billing WHERE AppointmentID = @AppointmentID)
        BEGIN
            RAISERROR('Cannot delete appointment with existing billing record. Cancel the appointment instead.', 16, 1)
            RETURN
        END
        
        -- Check if appointment has medical records
        IF EXISTS (SELECT 1 FROM MedicalRecord WHERE AppointmentID = @AppointmentID)
        BEGIN
            RAISERROR('Cannot delete appointment with existing medical records.', 16, 1)
            RETURN
        END
        
        -- Delete appointment treatments first
        DELETE FROM AppointmentTreatment WHERE AppointmentID = @AppointmentID
        
        -- Delete appointment
        DELETE FROM Appointment WHERE AppointmentID = @AppointmentID
        
        SELECT 
            @AppointmentID AS DeletedAppointmentID,
            'Appointment deleted successfully.' AS Message
            
    END TRY
    BEGIN CATCH
        SELECT 
            ERROR_NUMBER() AS ErrorNumber,
            ERROR_MESSAGE() AS ErrorMessage
    END CATCH
END
GO

-- ============================================
-- Get Patient Billing History
-- ============================================
CREATE PROCEDURE sp_GetPatientBilling
    @PatientID          INT,
    @PaymentStatusID    INT = NULL,
    @FromDate           DATE = NULL,
    @ToDate             DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        b.BillingID,
        b.BillingDate,
        b.TotalAmount,
        a.AppointmentDate,
        a.Reason,
        d.FirstName + ' ' + d.LastName AS DoctorName,
        dep.DepartmentName,
        pm.MethodName AS PaymentMethod,
        ps.StatusName AS PaymentStatus,
        CASE 
            WHEN ps.StatusName = 'Completed' THEN b.TotalAmount
            ELSE 0
        END AS AmountPaid,
        CASE 
            WHEN ps.StatusName IN ('Pending', 'Insurance Pending', 'Partially Paid') 
            THEN b.TotalAmount
            ELSE 0
        END AS AmountOutstanding
    FROM Billing b
    JOIN Appointment a ON b.AppointmentID = a.AppointmentID
    JOIN Doctor d ON a.DoctorID = d.DoctorID
    JOIN Department dep ON d.DepartmentID = dep.DepartmentID
    JOIN PaymentMethod pm ON b.PaymentMethodID = pm.PaymentMethodID
    JOIN PaymentStatus ps ON b.PaymentStatusID = ps.PaymentStatusID
    WHERE 
        b.PatientID = @PatientID
        AND (@PaymentStatusID IS NULL OR b.PaymentStatusID = @PaymentStatusID)
        AND (@FromDate IS NULL OR b.BillingDate >= @FromDate)
        AND (@ToDate IS NULL OR b.BillingDate <= @ToDate)
    ORDER BY b.BillingDate DESC
END
GO

-- ============================================
-- Department Workload Report
-- ============================================
CREATE PROCEDURE sp_DepartmentWorkload
    @FromDate   DATE = NULL,
    @ToDate     DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        dep.DepartmentID,
        dep.DepartmentName,
        COUNT(DISTINCT d.DoctorID) AS ActiveDoctors,
        COUNT(DISTINCT a.AppointmentID) AS TotalAppointments,
        SUM(CASE WHEN a.AppointmentStatusID = 2 THEN 1 ELSE 0 END) AS Completed,
        SUM(CASE WHEN a.AppointmentStatusID = 3 THEN 1 ELSE 0 END) AS Cancelled,
        SUM(CASE WHEN a.AppointmentStatusID = 4 THEN 1 ELSE 0 END) AS NoShows,
        CAST(
            CASE WHEN COUNT(DISTINCT a.AppointmentID) > 0 
            THEN SUM(CASE WHEN a.AppointmentStatusID = 2 THEN 1.0 ELSE 0 END) / COUNT(DISTINCT a.AppointmentID) * 100
            ELSE 0 END 
        AS DECIMAL(5,1)) AS CompletionRate,
        ISNULL(SUM(b.TotalAmount), 0) AS TotalRevenue
    FROM Department dep
    LEFT JOIN Doctor d ON dep.DepartmentID = d.DepartmentID AND d.DoctorStatus = 'Active'
    LEFT JOIN Appointment a ON d.DoctorID = a.DoctorID
        AND (@FromDate IS NULL OR CAST(a.AppointmentDate AS DATE) >= @FromDate)
        AND (@ToDate IS NULL OR CAST(a.AppointmentDate AS DATE) <= @ToDate)
    LEFT JOIN Billing b ON a.AppointmentID = b.AppointmentID
    GROUP BY dep.DepartmentID, dep.DepartmentName
    ORDER BY TotalAppointments DESC
END
GO

-- ============================================
-- Top Performing Doctors
-- ============================================
CREATE PROCEDURE sp_TopDoctors
    @TopN       INT = 10,
    @FromDate   DATE = NULL,
    @ToDate     DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT TOP (@TopN)
        d.DoctorID,
        d.FirstName + ' ' + d.LastName AS DoctorName,
        d.Specialization,
        dep.DepartmentName,
        COUNT(DISTINCT a.AppointmentID) AS TotalAppointments,
        SUM(CASE WHEN a.AppointmentStatusID = 2 THEN 1 ELSE 0 END) AS CompletedAppointments,
        COUNT(DISTINCT a.PatientID) AS UniquePatients,
        ISNULL(SUM(b.TotalAmount), 0) AS TotalRevenue,
        CAST(
            CASE WHEN COUNT(DISTINCT a.AppointmentID) > 0 
            THEN SUM(CASE WHEN a.AppointmentStatusID = 2 THEN 1.0 ELSE 0 END) / COUNT(DISTINCT a.AppointmentID) * 100
            ELSE 0 END 
        AS DECIMAL(5,1)) AS CompletionRate
    FROM Doctor d
    JOIN Department dep ON d.DepartmentID = dep.DepartmentID
    LEFT JOIN Appointment a ON d.DoctorID = a.DoctorID
        AND (@FromDate IS NULL OR CAST(a.AppointmentDate AS DATE) >= @FromDate)
        AND (@ToDate IS NULL OR CAST(a.AppointmentDate AS DATE) <= @ToDate)
    LEFT JOIN Billing b ON a.AppointmentID = b.AppointmentID AND a.AppointmentStatusID = 2
    WHERE d.DoctorStatus = 'Active'
    GROUP BY d.DoctorID, d.FirstName, d.LastName, d.Specialization, dep.DepartmentName
    ORDER BY TotalRevenue DESC
END
GO

-- ============================================
-- Add Medical Record with Prescription
-- ============================================
CREATE PROCEDURE sp_AddMedicalRecordWithPrescription
    @AppointmentID      INT,
    @DiagnosisID        INT,
    @Observation        NVARCHAR(MAX),
    @ClinicalNotes      NVARCHAR(MAX),
    @MedicationName     NVARCHAR(100) = NULL,
    @Dosage             NVARCHAR(50) = NULL,
    @Frequency          NVARCHAR(50) = NULL,
    @StartDate          DATE = NULL,
    @EndDate            DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        DECLARE @MedicalRecordID INT
        
        -- Insert medical record
        INSERT INTO MedicalRecord (AppointmentID, DiagnosisID, Observation, ClinicalNotes, RecordDate)
        VALUES (@AppointmentID, @DiagnosisID, @Observation, @ClinicalNotes, GETDATE())
        
        SET @MedicalRecordID = SCOPE_IDENTITY()
        
        -- Insert prescription if medication provided
        IF @MedicationName IS NOT NULL
        BEGIN
            INSERT INTO Prescription (MedicalRecordID, MedicationName, Dosage, Frequency, StartDate, EndDate)
            VALUES (@MedicalRecordID, @MedicationName, @Dosage, @Frequency, @StartDate, @EndDate)
        END
        
        -- Update appointment status to Completed
        UPDATE Appointment
        SET AppointmentStatusID = 2
        WHERE AppointmentID = @AppointmentID
        
        SELECT 
            @MedicalRecordID AS NewMedicalRecordID,
            'Medical record and prescription added successfully.' AS Message
            
    END TRY
    BEGIN CATCH
        SELECT 
            ERROR_NUMBER() AS ErrorNumber,
            ERROR_MESSAGE() AS ErrorMessage
    END CATCH
END
GO
