-- ============================================
-- MEDICARE PLUS HEALTHCARE INFORMATION SYSTEM
-- DATA WAREHOUSE - STAR SCHEMA
--============================================
USE MediCarePlusDB
GO

-- ============================================
-- DIMENSION TABLES
-- ============================================

-- DimDate - Date Dimension
CREATE TABLE DimDate (
    DateKey             INT PRIMARY KEY,
    FullDate            DATE NOT NULL,
    DayOfWeek           NVARCHAR(10) NOT NULL,
    DayOfMonth          INT NOT NULL,
    MonthNumber         INT NOT NULL,
    MonthName           NVARCHAR(10) NOT NULL,
    Quarter             INT NOT NULL,
    Year                INT NOT NULL,
    IsWeekend           BIT NOT NULL
)
GO

-- DimPatient - Patient Dimension
CREATE TABLE DimPatient (
    PatientKey          INT IDENTITY(1,1) PRIMARY KEY,
    PatientID           INT NOT NULL,
    FirstName           NVARCHAR(50) NOT NULL,
    LastName            NVARCHAR(50) NOT NULL,
    FullName            NVARCHAR(101) NOT NULL,
    DateOfBirth         DATE NOT NULL,
    Age                 INT NOT NULL,
    AgeGroup            NVARCHAR(20) NOT NULL,
    Gender              NVARCHAR(10) NOT NULL,
    City                NVARCHAR(50) NULL,
    RegistrationDate    DATE NOT NULL,
    PatientStatus       NVARCHAR(20) NOT NULL
)
GO

-- DimDoctor - Doctor Dimension
CREATE TABLE DimDoctor (
    DoctorKey           INT IDENTITY(1,1) PRIMARY KEY,
    DoctorID            INT NOT NULL,
    FirstName           NVARCHAR(50) NOT NULL,
    LastName            NVARCHAR(50) NOT NULL,
    FullName            NVARCHAR(101) NOT NULL,
    Specialization      NVARCHAR(100) NOT NULL,
    DepartmentID        INT NOT NULL,
    DepartmentName      NVARCHAR(50) NOT NULL,
    LicenseNumber       NVARCHAR(50) NOT NULL,
    HireDate            DATE NOT NULL,
    DoctorStatus        NVARCHAR(20) NOT NULL
)
GO

-- DimDepartment - Department Dimension
CREATE TABLE DimDepartment (
    DepartmentKey       INT IDENTITY(1,1) PRIMARY KEY,
    DepartmentID        INT NOT NULL,
    DepartmentName      NVARCHAR(50) NOT NULL,
    Description         NVARCHAR(255) NOT NULL
)
GO

-- DimDiagnosis - Diagnosis Dimension
CREATE TABLE DimDiagnosis (
    DiagnosisKey        INT IDENTITY(1,1) PRIMARY KEY,
    DiagnosisID         INT NOT NULL,
    DiagnosisCode       NVARCHAR(10) NOT NULL,
    DiagnosisName       NVARCHAR(200) NOT NULL,
    Description         NVARCHAR(500) NOT NULL
)
GO

-- DimPaymentStatus - Payment Status Dimension
CREATE TABLE DimPaymentStatus (
    PaymentStatusKey    INT IDENTITY(1,1) PRIMARY KEY,
    PaymentStatusID     INT NOT NULL,
    StatusName          NVARCHAR(50) NOT NULL,
    Description         NVARCHAR(255) NOT NULL
)
GO

-- DimPaymentMethod - Payment Method Dimension
CREATE TABLE DimPaymentMethod (
    PaymentMethodKey    INT IDENTITY(1,1) PRIMARY KEY,
    PaymentMethodID     INT NOT NULL,
    MethodName          NVARCHAR(50) NOT NULL,
    Description         NVARCHAR(255) NOT NULL
)
GO

-- DimTreatment - Treatment Dimension
CREATE TABLE DimTreatment (
    TreatmentKey        INT IDENTITY(1,1) PRIMARY KEY,
    TreatmentID         INT NOT NULL,
    TreatmentName       NVARCHAR(100) NOT NULL,
    TreatmentCode       NVARCHAR(20) NOT NULL,
    Description         NVARCHAR(500) NOT NULL,
    StandardCost        DECIMAL(10,2) NOT NULL,
    DepartmentID        INT NOT NULL,
    DepartmentName      NVARCHAR(50) NOT NULL
)
GO

-- DimAppointmentStatus - Appointment Status Dimension
CREATE TABLE DimAppointmentStatus (
    AppointmentStatusKey    INT IDENTITY(1,1) PRIMARY KEY,
    AppointmentStatusID     INT NOT NULL,
    AppointmentStatusName   NVARCHAR(50)    NOT NULL,
    Description             NVARCHAR(255)   NOT NULL
)
GO


-- ============================================
-- FACT TABLES
-- ============================================

-- FactAppointments - Appointment Analytics
CREATE TABLE FactAppointments (
    AppointmentFactID       INT IDENTITY(1,1) PRIMARY KEY,
    AppointmentID           INT NOT NULL,
    PatientKey              INT NOT NULL,
    DoctorKey               INT NOT NULL,
    DepartmentKey           INT NOT NULL,
    AppointmentDateKey      INT NOT NULL,
    DiagnosisKey            INT NULL,
    AppointmentStatusKey    INT NOT NULL,
    IsCompleted             BIT NOT NULL,
    IsCancelled             BIT NOT NULL,
    IsNoShow                BIT NOT NULL,
    CONSTRAINT FK_FactAppt_Patient FOREIGN KEY (PatientKey) REFERENCES DimPatient(PatientKey),
    CONSTRAINT FK_FactAppt_Doctor FOREIGN KEY (DoctorKey) REFERENCES DimDoctor(DoctorKey),
    CONSTRAINT FK_FactAppt_Department FOREIGN KEY (DepartmentKey) REFERENCES DimDepartment(DepartmentKey),
    CONSTRAINT FK_FactAppt_Date FOREIGN KEY (AppointmentDateKey) REFERENCES DimDate(DateKey),
    CONSTRAINT FK_FactAppt_Diagnosis FOREIGN KEY (DiagnosisKey) REFERENCES DimDiagnosis(DiagnosisKey),
    CONSTRAINT FK_FactAppt_ApptStatus FOREIGN KEY (AppointmentStatusKey) REFERENCES DimAppointmentStatus(AppointmentStatusKey)
)
GO

-- FactBilling - Revenue Analytics
CREATE TABLE FactBilling (
    BillingFactID       INT IDENTITY(1,1) PRIMARY KEY,
    BillingID           INT NOT NULL,
    PatientKey          INT NOT NULL,
    DoctorKey           INT NOT NULL,
    DepartmentKey       INT NOT NULL,
    BillingDateKey      INT NOT NULL,
    PaymentStatusKey    INT NOT NULL,
    PaymentMethodKey    INT NOT NULL,
    TotalAmount         DECIMAL(10,2) NOT NULL,
    IsPaid              BIT NOT NULL,
    IsOutstanding       BIT NOT NULL,
    CONSTRAINT FK_FactBill_Patient FOREIGN KEY (PatientKey) REFERENCES DimPatient(PatientKey),
    CONSTRAINT FK_FactBill_Doctor FOREIGN KEY (DoctorKey) REFERENCES DimDoctor(DoctorKey),
    CONSTRAINT FK_FactBill_Department FOREIGN KEY (DepartmentKey) REFERENCES DimDepartment(DepartmentKey),
    CONSTRAINT FK_FactBill_Date FOREIGN KEY (BillingDateKey) REFERENCES DimDate(DateKey),
    CONSTRAINT FK_FactBill_PayStatus FOREIGN KEY (PaymentStatusKey) REFERENCES DimPaymentStatus(PaymentStatusKey),
    CONSTRAINT FK_FactBill_PayMethod FOREIGN KEY (PaymentMethodKey) REFERENCES DimPaymentMethod(PaymentMethodKey)
)
GO

-- FactTreatments - Treatment Analytics
CREATE TABLE FactTreatments (
    TreatmentFactID     INT IDENTITY(1,1) PRIMARY KEY,
    AppointmentTreatmentID INT NOT NULL,
    PatientKey          INT NOT NULL,
    DoctorKey           INT NOT NULL,
    DepartmentKey       INT NOT NULL,
    TreatmentKey        INT NOT NULL,
    AppointmentDateKey  INT NOT NULL,
    Quantity            INT NOT NULL,
    ActualCost          DECIMAL(10,2) NOT NULL,
    TotalCost           DECIMAL(10,2) NOT NULL,
    CONSTRAINT FK_FactTreat_Patient FOREIGN KEY (PatientKey) REFERENCES DimPatient(PatientKey),
    CONSTRAINT FK_FactTreat_Doctor FOREIGN KEY (DoctorKey) REFERENCES DimDoctor(DoctorKey),
    CONSTRAINT FK_FactTreat_Department FOREIGN KEY (DepartmentKey) REFERENCES DimDepartment(DepartmentKey),
    CONSTRAINT FK_FactTreat_Treatment FOREIGN KEY (TreatmentKey) REFERENCES DimTreatment(TreatmentKey),
    CONSTRAINT FK_FactTreat_Date FOREIGN KEY (AppointmentDateKey) REFERENCES DimDate(DateKey)
)
GO