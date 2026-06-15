
-- ============================================
-- Description: Centralized Healthcare Information Management System
-- Normalization: 3NF
-- ============================================

-- ============================================
-- DATABASE CREATION
-- ============================================
CREATE DATABASE MediCarePlusDB
GO

USE MediCarePlusDB
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ============================================
-- REFERENCE/LOOKUP TABLES
-- ============================================

-- Departments
CREATE TABLE Department (
    DepartmentID    INT IDENTITY(1,1),
    DepartmentName  NVARCHAR(50)    NOT NULL UNIQUE,
    Description     NVARCHAR(255)   NOT NULL,
    
    CONSTRAINT PK_Department PRIMARY KEY CLUSTERED (DepartmentID ASC)
)
GO

-- Diagnosis Lookup (ICD-10 Codes)
CREATE TABLE Diagnosis (
    DiagnosisID     INT IDENTITY(1,1),
    DiagnosisCode   NVARCHAR(10)    NOT NULL UNIQUE,
    DiagnosisName   NVARCHAR(200)   NOT NULL,
    Description     NVARCHAR(500)   NOT NULL,
    
    CONSTRAINT PK_Diagnosis PRIMARY KEY CLUSTERED (DiagnosisID ASC)
)
GO

-- Appointment Status
CREATE TABLE AppointmentStatus (
    AppointmentStatusID     INT IDENTITY(1,1),
    AppointmentStatusName   NVARCHAR(50)    NOT NULL UNIQUE,
    Description             NVARCHAR(255)   NOT NULL,
    
    CONSTRAINT PK_AppointmentStatus PRIMARY KEY CLUSTERED (AppointmentStatusID ASC)
)
GO

-- Payment Methods
CREATE TABLE PaymentMethod (
    PaymentMethodID INT IDENTITY(1,1),
    MethodName      NVARCHAR(50)    NOT NULL UNIQUE,
    Description     NVARCHAR(255)   NOT NULL,
    
    CONSTRAINT PK_PaymentMethod PRIMARY KEY CLUSTERED (PaymentMethodID ASC)
)
GO

-- Payment Status
CREATE TABLE PaymentStatus (
    PaymentStatusID INT IDENTITY(1,1),
    StatusName      NVARCHAR(50)    NOT NULL UNIQUE,
    Description     NVARCHAR(255)   NOT NULL,
    
    CONSTRAINT PK_PaymentStatus PRIMARY KEY CLUSTERED (PaymentStatusID ASC)
)
GO

-- ============================================
-- CORE ENTITY TABLES
-- ============================================

-- Patients
CREATE TABLE Patient (
    PatientID           INT IDENTITY(1,1),
    FirstName           NVARCHAR(50)    NOT NULL,
    LastName            NVARCHAR(50)    NOT NULL,
    DateOfBirth         DATE            NOT NULL,
    Gender              NVARCHAR(10)    NOT NULL,
    PhoneNumber         NVARCHAR(15)    NOT NULL,
    Email               NVARCHAR(100)   NOT NULL,
    Address             NVARCHAR(255)   NOT NULL,
    RegistrationDate    DATE            NOT NULL,
    Status              NVARCHAR(20)    NOT NULL,
    
    CONSTRAINT PK_Patient PRIMARY KEY CLUSTERED (PatientID ASC),
    CONSTRAINT UQ_Patient_Email UNIQUE (Email),
    CONSTRAINT CK_Patient_Gender CHECK (Gender IN ('Male', 'Female', 'Other')),
    CONSTRAINT CK_Patient_Status CHECK (Status IN ('Active', 'Inactive'))
)
GO

-- Doctors
CREATE TABLE Doctor (
    DoctorID        INT IDENTITY(1,1),
    FirstName       NVARCHAR(50)    NOT NULL,
    LastName        NVARCHAR(50)    NOT NULL,
    Specialization  NVARCHAR(100)   NOT NULL,
    LicenseNumber   NVARCHAR(50)    NOT NULL,
    DepartmentID    INT             NOT NULL,
    Email           NVARCHAR(100)   NOT NULL,
    PhoneNumber     NVARCHAR(15)    NOT NULL,
    HireDate        DATE            NOT NULL,
    DoctorStatus    NVARCHAR(20)    NOT NULL,
    
    CONSTRAINT PK_Doctor PRIMARY KEY CLUSTERED (DoctorID ASC),
    CONSTRAINT UQ_Doctor_License UNIQUE (LicenseNumber),
    CONSTRAINT UQ_Doctor_Email UNIQUE (Email),
    CONSTRAINT FK_Doctor_Department FOREIGN KEY (DepartmentID) 
        REFERENCES Department(DepartmentID),
    CONSTRAINT CK_Doctor_Status CHECK (DoctorStatus IN ('Active', 'Inactive', 'OnLeave'))
)
GO

-- Treatments
CREATE TABLE Treatment (
    TreatmentID     INT IDENTITY(1,1),
    TreatmentName   NVARCHAR(100)   NOT NULL,
    TreatmentCode   NVARCHAR(20)    NOT NULL,
    Description     NVARCHAR(500)   NOT NULL,
    StandardCost    DECIMAL(10,2)   NOT NULL,
    DepartmentID    INT             NOT NULL,
    
    CONSTRAINT PK_Treatment PRIMARY KEY CLUSTERED (TreatmentID ASC),
    CONSTRAINT UQ_Treatment_Code UNIQUE (TreatmentCode),
    CONSTRAINT FK_Treatment_Department FOREIGN KEY (DepartmentID) 
        REFERENCES Department(DepartmentID),
    CONSTRAINT CK_Treatment_Cost CHECK (StandardCost > 0)
)
GO

-- ============================================
-- TRANSACTIONAL TABLES
-- ============================================

-- Appointments
CREATE TABLE Appointment (
    AppointmentID           INT IDENTITY(1,1),
    PatientID               INT             NOT NULL,
    DoctorID                INT             NOT NULL,
    AppointmentDate         DATETIME        NOT NULL,
    Reason                  NVARCHAR(500)   NOT NULL,
    AppointmentStatusID     INT             NOT NULL,
    
    CONSTRAINT PK_Appointment PRIMARY KEY CLUSTERED (AppointmentID ASC),
    CONSTRAINT FK_Appointment_Patient FOREIGN KEY (PatientID) 
        REFERENCES Patient(PatientID),
    CONSTRAINT FK_Appointment_Doctor FOREIGN KEY (DoctorID) 
        REFERENCES Doctor(DoctorID),
    CONSTRAINT FK_Appointment_Status FOREIGN KEY (AppointmentStatusID) 
        REFERENCES AppointmentStatus(AppointmentStatusID),
    CONSTRAINT UQ_Doctor_AppointmentTime UNIQUE (DoctorID, AppointmentDate)
)
GO

-- Medical Records
CREATE TABLE MedicalRecord (
    MedicalRecordID INT IDENTITY(1,1),
    AppointmentID   INT             NOT NULL,
    DiagnosisID     INT             NOT NULL,
    Observation     NVARCHAR(MAX)   NOT NULL,
    ClinicalNotes   NVARCHAR(MAX)   NOT NULL,
    RecordDate      DATE            NOT NULL,
    
    CONSTRAINT PK_MedicalRecord PRIMARY KEY CLUSTERED (MedicalRecordID ASC),
    CONSTRAINT FK_MedicalRecord_Appointment FOREIGN KEY (AppointmentID) 
        REFERENCES Appointment(AppointmentID),
    CONSTRAINT FK_MedicalRecord_Diagnosis FOREIGN KEY (DiagnosisID) 
        REFERENCES Diagnosis(DiagnosisID)
)
GO

-- Appointment Treatments (Junction Table)
CREATE TABLE AppointmentTreatment (
    AppointmentTreatmentID  INT IDENTITY(1,1),
    AppointmentID           INT             NOT NULL,
    TreatmentID             INT             NOT NULL,
    Quantity                INT             NOT NULL DEFAULT 1,
    ActualCost              DECIMAL(10,2)   NOT NULL,
    Notes                   NVARCHAR(255)   NULL,
    
    CONSTRAINT PK_AppointmentTreatment PRIMARY KEY CLUSTERED (AppointmentTreatmentID ASC),
    CONSTRAINT FK_ApptTreatment_Appointment FOREIGN KEY (AppointmentID) 
        REFERENCES Appointment(AppointmentID),
    CONSTRAINT FK_ApptTreatment_Treatment FOREIGN KEY (TreatmentID) 
        REFERENCES Treatment(TreatmentID),
    CONSTRAINT CK_ApptTreatment_Quantity CHECK (Quantity > 0),
    CONSTRAINT CK_ApptTreatment_Cost CHECK (ActualCost > 0)
)
GO

-- Prescriptions
CREATE TABLE Prescription (
    PrescriptionID      INT IDENTITY(1,1),
    MedicalRecordID     INT             NOT NULL,
    MedicationName      NVARCHAR(100)   NOT NULL,
    Dosage              NVARCHAR(50)    NOT NULL,
    Frequency           NVARCHAR(50)    NOT NULL,
    StartDate           DATE            NOT NULL,
    EndDate             DATE            NOT NULL,
    
    CONSTRAINT PK_Prescription PRIMARY KEY CLUSTERED (PrescriptionID ASC),
    CONSTRAINT FK_Prescription_MedicalRecord FOREIGN KEY (MedicalRecordID) 
        REFERENCES MedicalRecord(MedicalRecordID),
    CONSTRAINT CK_Prescription_Dates CHECK (EndDate >= StartDate)
)
GO

-- Billing
CREATE TABLE Billing (
    BillingID           INT IDENTITY(1,1),
    PatientID           INT             NOT NULL,
    AppointmentID       INT             NOT NULL,
    TotalAmount         DECIMAL(10,2)   NOT NULL,
    BillingDate         DATE            NOT NULL,
    PaymentMethodID     INT             NOT NULL,
    PaymentStatusID     INT             NOT NULL,
    
    CONSTRAINT PK_Billing PRIMARY KEY CLUSTERED (BillingID ASC),
    CONSTRAINT FK_Billing_Patient FOREIGN KEY (PatientID) 
        REFERENCES Patient(PatientID),
    CONSTRAINT FK_Billing_Appointment FOREIGN KEY (AppointmentID) 
        REFERENCES Appointment(AppointmentID),
    CONSTRAINT FK_Billing_PaymentMethod FOREIGN KEY (PaymentMethodID) 
        REFERENCES PaymentMethod(PaymentMethodID),
    CONSTRAINT FK_Billing_PaymentStatus FOREIGN KEY (PaymentStatusID) 
        REFERENCES PaymentStatus(PaymentStatusID),
    CONSTRAINT UQ_Billing_Appointment UNIQUE (AppointmentID),
    CONSTRAINT CK_Billing_Amount CHECK (TotalAmount > 0)
)
GO

