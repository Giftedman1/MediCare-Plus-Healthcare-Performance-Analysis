-- ============================================
-- MEDICARE PLUS - SAMPLE DATA GENERATION
-- ============================================
USE MediCarePlusDB
GO

-- ============================================
-- INSERT INTO LOOKUP TABLES 
-- ============================================

-- Appointment Statuses
INSERT INTO AppointmentStatus (AppointmentStatusName, Description)
VALUES 
    ('Scheduled', 'Appointment has been booked but not yet attended'),
    ('Completed', 'Patient attended the appointment'),
    ('Cancelled', 'Appointment was cancelled before the scheduled time'),
    ('No-Show', 'Patient did not attend without prior notice'),
    ('Rescheduled', 'Appointment was moved to a different date/time')
GO

-- Payment Methods
INSERT INTO PaymentMethod (MethodName, Description)
VALUES 
    ('Cash', 'Physical currency payment'),
    ('Credit Card', 'Payment via credit card'),
    ('Debit Card', 'Payment via debit card'),
    ('Insurance', 'Covered by health insurance provider'),
    ('Bank Transfer', 'Electronic funds transfer'),
    ('Mobile Payment', 'Payment via mobile payment platforms')
GO

-- Payment Statuses
INSERT INTO PaymentStatus (StatusName, Description)
VALUES 
    ('Pending', 'Payment has not been made yet'),
    ('Completed', 'Payment has been successfully processed'),
    ('Failed', 'Payment transaction failed'),
    ('Refunded', 'Payment has been refunded to the patient'),
    ('Partially Paid', 'A portion of the total amount has been paid'),
    ('Insurance Pending', 'Awaiting insurance company claim processing')
GO

-- ============================================
-- 2. INSERT DEPARTMENTS
-- ============================================
INSERT INTO Department (DepartmentName, Description)
VALUES 
    ('Cardiology', 'Heart and cardiovascular system treatment'),
    ('Pediatrics', 'Medical care for infants, children, and adolescents'),
    ('Radiology', 'Medical imaging and diagnostic procedures'),
    ('Orthopedics', 'Musculoskeletal system treatment'),
    ('Neurology', 'Brain and nervous system disorders'),
    ('Dermatology', 'Skin conditions and treatments'),
    ('Oncology', 'Cancer diagnosis and treatment'),
    ('Gastroenterology', 'Digestive system disorders'),
    ('Pulmonology', 'Respiratory system and lung diseases'),
    ('Ophthalmology', 'Eye and vision care'),
    ('Endocrinology', 'Hormone and metabolic disorders'),
    ('Psychiatry', 'Mental health diagnosis and treatment'),
    ('Urology', 'Urinary tract and male reproductive system'),
    ('ENT', 'Ear, nose, and throat disorders'),
    ('Emergency Medicine', 'Acute illness and injury care')
GO

-- ============================================
-- INSERT DOCTORS (50 doctors)
-- Using explicit INSERT with no loops or variables
-- ============================================
INSERT INTO Doctor (FirstName, LastName, Specialization, LicenseNumber, DepartmentID, Email, PhoneNumber, HireDate, DoctorStatus)
VALUES
('James', 'Smith', 'Interventional Cardiologist', 'LIC-00001-C1A2', 1, 'james.smith@medicareplus.com', '+1-555-0101', '2018-03-15', 'Active'),
('Sarah', 'Johnson', 'Electrophysiologist', 'LIC-00002-C3B4', 1, 'sarah.johnson@medicareplus.com', '+1-555-0102', '2019-07-22', 'Active'),
('Michael', 'Williams', 'Cardiac Surgeon', 'LIC-00003-C5C6', 1, 'michael.williams@medicareplus.com', '+1-555-0103', '2016-01-10', 'Active'),
('Emily', 'Brown', 'General Pediatrician', 'LIC-00004-P7D8', 2, 'emily.brown@medicareplus.com', '+1-555-0104', '2020-05-18', 'Active'),
('David', 'Jones', 'Pediatric Neurologist', 'LIC-00005-P9E0', 2, 'david.jones@medicareplus.com', '+1-555-0105', '2017-11-30', 'Active'),
('Jessica', 'Garcia', 'Neonatologist', 'LIC-00006-P1F2', 2, 'jessica.garcia@medicareplus.com', '+1-555-0106', '2021-02-14', 'OnLeave'),
('Robert', 'Miller', 'Diagnostic Radiologist', 'LIC-00007-R3G4', 3, 'robert.miller@medicareplus.com', '+1-555-0107', '2015-09-05', 'Active'),
('Jennifer', 'Davis', 'Interventional Radiologist', 'LIC-00008-R5H6', 3, 'jennifer.davis@medicareplus.com', '+1-555-0108', '2019-04-20', 'Active'),
('William', 'Rodriguez', 'Nuclear Medicine Specialist', 'LIC-00009-R7I8', 3, 'william.rodriguez@medicareplus.com', '+1-555-0109', '2022-01-08', 'Active'),
('Amanda', 'Martinez', 'Orthopedic Surgeon', 'LIC-00010-O9J0', 4, 'amanda.martinez@medicareplus.com', '+1-555-0110', '2016-08-12', 'Active'),
('Richard', 'Hernandez', 'Sports Medicine Specialist', 'LIC-00011-O1K2', 4, 'richard.hernandez@medicareplus.com', '+1-555-0111', '2020-10-25', 'Active'),
('Melissa', 'Lopez', 'Spine Surgeon', 'LIC-00012-O3L4', 4, 'melissa.lopez@medicareplus.com', '+1-555-0112', '2018-06-30', 'Active'),
('Joseph', 'Gonzalez', 'Neurologist', 'LIC-00013-N5M6', 5, 'joseph.gonzalez@medicareplus.com', '+1-555-0113', '2017-03-18', 'Active'),
('Stephanie', 'Wilson', 'Neurosurgeon', 'LIC-00014-N7N8', 5, 'stephanie.wilson@medicareplus.com', '+1-555-0114', '2015-12-05', 'Active'),
('Thomas', 'Anderson', 'Stroke Specialist', 'LIC-00015-N9O0', 5, 'thomas.anderson@medicareplus.com', '+1-555-0115', '2021-07-14', 'Active'),
('Nicole', 'Thomas', 'General Dermatologist', 'LIC-00016-D1P2', 6, 'nicole.thomas@medicareplus.com', '+1-555-0116', '2019-01-20', 'Active'),
('Christopher', 'Taylor', 'Cosmetic Dermatologist', 'LIC-00017-D3Q4', 6, 'christopher.taylor@medicareplus.com', '+1-555-0117', '2020-04-08', 'Active'),
('Elizabeth', 'Moore', 'Medical Oncologist', 'LIC-00018-O5R6', 7, 'elizabeth.moore@medicareplus.com', '+1-555-0118', '2016-05-22', 'Active'),
('Daniel', 'Jackson', 'Radiation Oncologist', 'LIC-00019-O7S8', 7, 'daniel.jackson@medicareplus.com', '+1-555-0119', '2018-09-15', 'Active'),
('Michelle', 'Martin', 'Surgical Oncologist', 'LIC-00020-O9T0', 7, 'michelle.martin@medicareplus.com', '+1-555-0120', '2017-12-01', 'Active'),
('Matthew', 'Lee', 'Gastroenterologist', 'LIC-00021-G1U2', 8, 'matthew.lee@medicareplus.com', '+1-555-0121', '2020-02-28', 'Active'),
('Kimberly', 'Perez', 'Hepatologist', 'LIC-00022-G3V4', 8, 'kimberly.perez@medicareplus.com', '+1-555-0122', '2019-06-10', 'Active'),
('Anthony', 'Thompson', 'Colorectal Surgeon', 'LIC-00023-G5W6', 8, 'anthony.thompson@medicareplus.com', '+1-555-0123', '2018-11-20', 'Inactive'),
('Lauren', 'White', 'Pulmonologist', 'LIC-00024-P7X8', 9, 'lauren.white@medicareplus.com', '+1-555-0124', '2021-03-05', 'Active'),
('Mark', 'Harris', 'Respiratory Therapist', 'LIC-00025-P9Y0', 9, 'mark.harris@medicareplus.com', '+1-555-0125', '2017-08-18', 'Active'),
('Ashley', 'Sanchez', 'Sleep Medicine Specialist', 'LIC-00026-P1Z2', 9, 'ashley.sanchez@medicareplus.com', '+1-555-0126', '2022-04-30', 'Active'),
('Donald', 'Clark', 'Ophthalmologist', 'LIC-00027-O3A4', 10, 'donald.clark@medicareplus.com', '+1-555-0127', '2016-10-12', 'Active'),
('Rachel', 'Ramirez', 'Optometrist', 'LIC-00028-O5B6', 10, 'rachel.ramirez@medicareplus.com', '+1-555-0128', '2019-12-05', 'Active'),
('Steven', 'Lewis', 'Retinal Specialist', 'LIC-00029-O7C8', 10, 'steven.lewis@medicareplus.com', '+1-555-0129', '2018-05-25', 'Active'),
('Megan', 'Robinson', 'Endocrinologist', 'LIC-00030-E9D0', 11, 'megan.robinson@medicareplus.com', '+1-555-0130', '2020-07-15', 'Active'),
('Paul', 'Walker', 'Diabetologist', 'LIC-00031-E1E2', 11, 'paul.walker@medicareplus.com', '+1-555-0131', '2017-01-30', 'Active'),
('Hannah', 'Young', 'Thyroid Specialist', 'LIC-00032-E3F4', 11, 'hannah.young@medicareplus.com', '+1-555-0132', '2021-09-20', 'OnLeave'),
('Andrew', 'Allen', 'General Psychiatrist', 'LIC-00033-P5G6', 12, 'andrew.allen@medicareplus.com', '+1-555-0133', '2018-04-10', 'Active'),
('Olivia', 'King', 'Child Psychiatrist', 'LIC-00034-P7H8', 12, 'olivia.king@medicareplus.com', '+1-555-0134', '2019-11-28', 'Active'),
('Joshua', 'Wright', 'Addiction Psychiatrist', 'LIC-00035-P9I0', 12, 'joshua.wright@medicareplus.com', '+1-555-0135', '2022-02-14', 'Active'),
('Samantha', 'Scott', 'Urologist', 'LIC-00036-U1J2', 13, 'samantha.scott@medicareplus.com', '+1-555-0136', '2017-06-05', 'Active'),
('Kenneth', 'Torres', 'Urologic Surgeon', 'LIC-00037-U3K4', 13, 'kenneth.torres@medicareplus.com', '+1-555-0137', '2016-03-22', 'Active'),
('Victoria', 'Nguyen', 'Andrologist', 'LIC-00038-U5L6', 13, 'victoria.nguyen@medicareplus.com', '+1-555-0138', '2020-08-30', 'Active'),
('Kevin', 'Hill', 'Otolaryngologist', 'LIC-00039-E7M8', 14, 'kevin.hill@medicareplus.com', '+1-555-0139', '2018-12-15', 'Active'),
('Grace', 'Flores', 'Audiologist', 'LIC-00040-E9N0', 14, 'grace.flores@medicareplus.com', '+1-555-0140', '2021-05-10', 'Active'),
('Brian', 'Green', 'Head and Neck Surgeon', 'LIC-00041-E1O2', 14, 'brian.green@medicareplus.com', '+1-555-0141', '2019-07-25', 'Active'),
('George', 'Adams', 'Emergency Physician', 'LIC-00042-E3P4', 15, 'george.adams@medicareplus.com', '+1-555-0142', '2017-10-01', 'Active'),
('Sophia', 'Nelson', 'Trauma Surgeon', 'LIC-00043-E5Q6', 15, 'sophia.nelson@medicareplus.com', '+1-555-0143', '2015-08-18', 'Active'),
('Timothy', 'Baker', 'Critical Care Specialist', 'LIC-00044-E7R8', 15, 'timothy.baker@medicareplus.com', '+1-555-0144', '2020-01-05', 'Active'),
('Isabella', 'Hall', 'General Cardiologist', 'LIC-00045-C9S0', 1, 'isabella.hall@medicareplus.com', '+1-555-0145', '2021-11-15', 'Active'),
('Ronald', 'Rivera', 'Pediatric Cardiologist', 'LIC-00046-P1T2', 2, 'ronald.rivera@medicareplus.com', '+1-555-0146', '2019-03-20', 'Active'),
('Mia', 'Campbell', 'Orthopedic Surgeon', 'LIC-00047-O3U4', 4, 'mia.campbell@medicareplus.com', '+1-555-0147', '2022-06-10', 'Active'),
('Jason', 'Mitchell', 'Neurologist', 'LIC-00048-N5V6', 5, 'jason.mitchell@medicareplus.com', '+1-555-0148', '2018-09-05', 'Active'),
('Charlotte', 'Carter', 'Dermatologist', 'LIC-00049-D7W8', 6, 'charlotte.carter@medicareplus.com', '+1-555-0149', '2020-12-01', 'Active'),
('Edward', 'Roberts', 'Emergency Physician', 'LIC-00050-E9X0', 15, 'edward.roberts@medicareplus.com', '+1-555-0150', '2017-04-18', 'Active')
GO

-- ============================================
-- INSERT PATIENTS (6,000 patients)
-- Using WHILE loop but guaranteed gap-free
-- ============================================
DECLARE @PatientCount INT = 1
DECLARE @P_FirstName NVARCHAR(50)
DECLARE @P_LastName NVARCHAR(50)
DECLARE @DateOfBirth DATE
DECLARE @Gender NVARCHAR(10)
DECLARE @P_Phone NVARCHAR(15)
DECLARE @P_Email NVARCHAR(100)
DECLARE @Address NVARCHAR(255)
DECLARE @RegDate DATE
DECLARE @Status NVARCHAR(20)

WHILE @PatientCount <= 6000
BEGIN
    -- First name (cycling through 100 names)
    SET @P_FirstName = CASE ((@PatientCount - 1) % 100)
        WHEN 0 THEN 'Emma' WHEN 1 THEN 'Liam' WHEN 2 THEN 'Olivia' WHEN 3 THEN 'Noah'
        WHEN 4 THEN 'Ava' WHEN 5 THEN 'Ethan' WHEN 6 THEN 'Sophia' WHEN 7 THEN 'Mason'
        WHEN 8 THEN 'Isabella' WHEN 9 THEN 'Lucas' WHEN 10 THEN 'Mia' WHEN 11 THEN 'Logan'
        WHEN 12 THEN 'Charlotte' WHEN 13 THEN 'Alexander' WHEN 14 THEN 'Amelia' WHEN 15 THEN 'James'
        WHEN 16 THEN 'Harper' WHEN 17 THEN 'Benjamin' WHEN 18 THEN 'Evelyn' WHEN 19 THEN 'Elijah'
        WHEN 20 THEN 'Abigail' WHEN 21 THEN 'William' WHEN 22 THEN 'Ella' WHEN 23 THEN 'Michael'
        WHEN 24 THEN 'Scarlett' WHEN 25 THEN 'Daniel' WHEN 26 THEN 'Grace' WHEN 27 THEN 'Henry'
        WHEN 28 THEN 'Chloe' WHEN 29 THEN 'Jackson' WHEN 30 THEN 'Victoria' WHEN 31 THEN 'Sebastian'
        WHEN 32 THEN 'Riley' WHEN 33 THEN 'Aiden' WHEN 34 THEN 'Aria' WHEN 35 THEN 'Matthew'
        WHEN 36 THEN 'Lily' WHEN 37 THEN 'Samuel' WHEN 38 THEN 'Zoey' WHEN 39 THEN 'David'
        WHEN 40 THEN 'Hannah' WHEN 41 THEN 'Joseph' WHEN 42 THEN 'Layla' WHEN 43 THEN 'Carter'
        WHEN 44 THEN 'Nora' WHEN 45 THEN 'Owen' WHEN 46 THEN 'Scarlet' WHEN 47 THEN 'Wyatt'
        WHEN 48 THEN 'Addison' WHEN 49 THEN 'John' WHEN 50 THEN 'Aubrey' WHEN 51 THEN 'Dylan'
        WHEN 52 THEN 'Ellie' WHEN 53 THEN 'Luke' WHEN 54 THEN 'Stella' WHEN 55 THEN 'Gabriel'
        WHEN 56 THEN 'Natalie' WHEN 57 THEN 'Isaac' WHEN 58 THEN 'Zoe' WHEN 59 THEN 'Anthony'
        WHEN 60 THEN 'Leah' WHEN 61 THEN 'Jaxon' WHEN 62 THEN 'Hazel' WHEN 63 THEN 'Lincoln'
        WHEN 64 THEN 'Violet' WHEN 65 THEN 'Christopher' WHEN 66 THEN 'Aurora' WHEN 67 THEN 'Joshua'
        WHEN 68 THEN 'Savannah' WHEN 69 THEN 'Andrew' WHEN 70 THEN 'Audrey' WHEN 71 THEN 'Theodore'
        WHEN 72 THEN 'Brooklyn' WHEN 73 THEN 'Caleb' WHEN 74 THEN 'Bella' WHEN 75 THEN 'Ryan'
        WHEN 76 THEN 'Claire' WHEN 77 THEN 'Nathan' WHEN 78 THEN 'Skylar' WHEN 79 THEN 'Thomas'
        WHEN 80 THEN 'Lucy' WHEN 81 THEN 'Leo' WHEN 82 THEN 'Paisley' WHEN 83 THEN 'Isaiah'
        WHEN 84 THEN 'Everly' WHEN 85 THEN 'Charles' WHEN 86 THEN 'Anna' WHEN 87 THEN 'Josiah'
        WHEN 88 THEN 'Caroline' WHEN 89 THEN 'Hudson' WHEN 90 THEN 'Nova' WHEN 91 THEN 'Christian'
        WHEN 92 THEN 'Genesis' WHEN 93 THEN 'Hunter' WHEN 94 THEN 'Emilia' WHEN 95 THEN 'Connor'
        WHEN 96 THEN 'Kennedy' WHEN 97 THEN 'Eli' WHEN 98 THEN 'Samantha' WHEN 99 THEN 'Ezra'
    END
    
    -- Last name (cycling through 100 names)
    SET @P_LastName = CASE ((@PatientCount - 1) % 100)
        WHEN 0 THEN 'Smith' WHEN 1 THEN 'Johnson' WHEN 2 THEN 'Williams' WHEN 3 THEN 'Brown'
        WHEN 4 THEN 'Jones' WHEN 5 THEN 'Garcia' WHEN 6 THEN 'Miller' WHEN 7 THEN 'Davis'
        WHEN 8 THEN 'Rodriguez' WHEN 9 THEN 'Martinez' WHEN 10 THEN 'Hernandez' WHEN 11 THEN 'Lopez'
        WHEN 12 THEN 'Gonzalez' WHEN 13 THEN 'Wilson' WHEN 14 THEN 'Anderson' WHEN 15 THEN 'Thomas'
        WHEN 16 THEN 'Taylor' WHEN 17 THEN 'Moore' WHEN 18 THEN 'Jackson' WHEN 19 THEN 'Martin'
        WHEN 20 THEN 'Lee' WHEN 21 THEN 'Perez' WHEN 22 THEN 'Thompson' WHEN 23 THEN 'White'
        WHEN 24 THEN 'Harris' WHEN 25 THEN 'Sanchez' WHEN 26 THEN 'Clark' WHEN 27 THEN 'Ramirez'
        WHEN 28 THEN 'Lewis' WHEN 29 THEN 'Robinson' WHEN 30 THEN 'Walker' WHEN 31 THEN 'Young'
        WHEN 32 THEN 'Allen' WHEN 33 THEN 'King' WHEN 34 THEN 'Wright' WHEN 35 THEN 'Scott'
        WHEN 36 THEN 'Torres' WHEN 37 THEN 'Nguyen' WHEN 38 THEN 'Hill' WHEN 39 THEN 'Flores'
        WHEN 40 THEN 'Green' WHEN 41 THEN 'Adams' WHEN 42 THEN 'Nelson' WHEN 43 THEN 'Baker'
        WHEN 44 THEN 'Hall' WHEN 45 THEN 'Rivera' WHEN 46 THEN 'Campbell' WHEN 47 THEN 'Mitchell'
        WHEN 48 THEN 'Carter' WHEN 49 THEN 'Roberts' WHEN 50 THEN 'Gomez' WHEN 51 THEN 'Phillips'
        WHEN 52 THEN 'Evans' WHEN 53 THEN 'Turner' WHEN 54 THEN 'Diaz' WHEN 55 THEN 'Parker'
        WHEN 56 THEN 'Cruz' WHEN 57 THEN 'Edwards' WHEN 58 THEN 'Collins' WHEN 59 THEN 'Reyes'
        WHEN 60 THEN 'Stewart' WHEN 61 THEN 'Morris' WHEN 62 THEN 'Morales' WHEN 63 THEN 'Murphy'
        WHEN 64 THEN 'Cook' WHEN 65 THEN 'Rogers' WHEN 66 THEN 'Gutierrez' WHEN 67 THEN 'Ortiz'
        WHEN 68 THEN 'Morgan' WHEN 69 THEN 'Cooper' WHEN 70 THEN 'Peterson' WHEN 71 THEN 'Bailey'
        WHEN 72 THEN 'Reed' WHEN 73 THEN 'Kelly' WHEN 74 THEN 'Howard' WHEN 75 THEN 'Ramos'
        WHEN 76 THEN 'Kim' WHEN 77 THEN 'Cox' WHEN 78 THEN 'Ward' WHEN 79 THEN 'Richardson'
        WHEN 80 THEN 'Watson' WHEN 81 THEN 'Brooks' WHEN 82 THEN 'Chavez' WHEN 83 THEN 'Wood'
        WHEN 84 THEN 'James' WHEN 85 THEN 'Bennett' WHEN 86 THEN 'Gray' WHEN 87 THEN 'Mendoza'
        WHEN 88 THEN 'Ruiz' WHEN 89 THEN 'Hughes' WHEN 90 THEN 'Price' WHEN 91 THEN 'Alvarez'
        WHEN 92 THEN 'Castillo' WHEN 93 THEN 'Sanders' WHEN 94 THEN 'Patel' WHEN 95 THEN 'Myers'
        WHEN 96 THEN 'Long' WHEN 97 THEN 'Ross' WHEN 98 THEN 'Foster' WHEN 99 THEN 'Jimenez'
    END
    
    -- Date of birth: age 1-90 (deterministic based on counter)
    SET @DateOfBirth = DATEADD(DAY, -((@PatientCount % 32850) + 365), '2025-01-01')
    
    -- Gender
    SET @Gender = CASE 
        WHEN @PatientCount % 100 < 48 THEN 'Male'
        WHEN @PatientCount % 100 < 98 THEN 'Female'
        ELSE 'Other'
    END
    
    -- Phone (unique per patient)
    SET @P_Phone = '+1-' + 
        RIGHT('000' + CAST((@PatientCount * 7) % 1000 AS NVARCHAR), 3) + '-' + 
        RIGHT('0000' + CAST((@PatientCount * 13) % 10000 AS NVARCHAR), 4)
    
    -- Email (unique per patient)
    SET @P_Email = LOWER(@P_FirstName + '.' + @P_LastName + CAST(@PatientCount AS NVARCHAR) + '@email.com')
    
    -- Address
    SET @Address = CAST((@PatientCount % 9999) + 1 AS NVARCHAR) + ' ' + 
        CASE (@PatientCount % 25)
            WHEN 0 THEN 'Oak Street' WHEN 1 THEN 'Maple Avenue' WHEN 2 THEN 'Cedar Lane'
            WHEN 3 THEN 'Pine Road' WHEN 4 THEN 'Elm Street' WHEN 5 THEN 'Birch Boulevard'
            WHEN 6 THEN 'Willow Way' WHEN 7 THEN 'Ash Drive' WHEN 8 THEN 'Cherry Lane'
            WHEN 9 THEN 'Walnut Avenue' WHEN 10 THEN 'Main Street' WHEN 11 THEN 'Park Avenue'
            WHEN 12 THEN 'Lake Road' WHEN 13 THEN 'Hill Street' WHEN 14 THEN 'Forest Drive'
            WHEN 15 THEN 'River Road' WHEN 16 THEN 'Spring Lane' WHEN 17 THEN 'Meadow Drive'
            WHEN 18 THEN 'Valley View' WHEN 19 THEN 'Sunset Boulevard' WHEN 20 THEN 'Garden Way'
            WHEN 21 THEN 'Highland Avenue' WHEN 22 THEN 'Church Street' WHEN 23 THEN 'Market Street'
            WHEN 24 THEN 'Washington Avenue'
        END + ', ' + 
        CASE (@PatientCount % 25)
            WHEN 0 THEN 'New York' WHEN 1 THEN 'Los Angeles' WHEN 2 THEN 'Chicago'
            WHEN 3 THEN 'Houston' WHEN 4 THEN 'Phoenix' WHEN 5 THEN 'Philadelphia'
            WHEN 6 THEN 'San Antonio' WHEN 7 THEN 'San Diego' WHEN 8 THEN 'Dallas'
            WHEN 9 THEN 'San Jose' WHEN 10 THEN 'Austin' WHEN 11 THEN 'Jacksonville'
            WHEN 12 THEN 'Fort Worth' WHEN 13 THEN 'Columbus' WHEN 14 THEN 'Charlotte'
            WHEN 15 THEN 'Indianapolis' WHEN 16 THEN 'San Francisco' WHEN 17 THEN 'Seattle'
            WHEN 18 THEN 'Denver' WHEN 19 THEN 'Boston' WHEN 20 THEN 'Nashville'
            WHEN 21 THEN 'Portland' WHEN 22 THEN 'Memphis' WHEN 23 THEN 'Louisville'
            WHEN 24 THEN 'Baltimore'
        END
    
    -- Registration date (2018-2025)
    SET @RegDate = DATEADD(DAY, @PatientCount % 2555, '2018-01-01')
    
    -- Status (90% Active)
    SET @Status = CASE WHEN @PatientCount % 100 < 90 THEN 'Active' ELSE 'Inactive' END
    
    INSERT INTO Patient (FirstName, LastName, DateOfBirth, Gender, PhoneNumber, Email, Address, RegistrationDate, Status)
    VALUES (@P_FirstName, @P_LastName, @DateOfBirth, @Gender, @P_Phone, @P_Email, @Address, @RegDate, @Status)
    
    SET @PatientCount = @PatientCount + 1
END
GO

-- ============================================
-- INSERT APPOINTMENTS (10,000 appointments)
-- Guaranteed gap-free with unique doctor-time combinations
-- ============================================
DECLARE @ApptCount INT = 1
DECLARE @PatientID INT
DECLARE @DoctorID INT
DECLARE @AppointmentDate DATETIME
DECLARE @Reason NVARCHAR(500)
DECLARE @StatusID INT

WHILE @ApptCount <= 10000
BEGIN
    -- PatientID cycles 1-5000
    SET @PatientID = ((@ApptCount - 1) % 5000) + 1
    
    -- DoctorID cycles 1-50
    SET @DoctorID = ((@ApptCount - 1) % 50) + 1
    
    -- Appointment date: spread across 2023-2025
    -- Each appointment is 2 hours apart to avoid conflicts
    DECLARE @BaseDate DATETIME = '2023-01-01 08:00:00'
    DECLARE @HoursOffset INT = @ApptCount * 2  -- 2-hour gaps
    SET @AppointmentDate = DATEADD(HOUR, @HoursOffset, @BaseDate)
    
    -- Make sure we don't exceed 2025
    IF YEAR(@AppointmentDate) > 2025
        SET @AppointmentDate = DATEADD(HOUR, @HoursOffset, '2023-01-01 08:00:00')
    
    -- Reason
    SET @Reason = CASE (@ApptCount % 60)
        WHEN 0 THEN 'Routine check-up' WHEN 1 THEN 'Follow-up visit'
        WHEN 2 THEN 'Chest pain' WHEN 3 THEN 'Headache'
        WHEN 4 THEN 'Back pain' WHEN 5 THEN 'Skin rash'
        WHEN 6 THEN 'Annual physical' WHEN 7 THEN 'Vaccination'
        WHEN 8 THEN 'Blood pressure check' WHEN 9 THEN 'Diabetes management'
        WHEN 10 THEN 'Allergic reaction' WHEN 11 THEN 'Joint pain'
        WHEN 12 THEN 'Vision problems' WHEN 13 THEN 'Hearing issues'
        WHEN 14 THEN 'Stomach pain' WHEN 15 THEN 'Anxiety consultation'
        WHEN 16 THEN 'Sleep problems' WHEN 17 THEN 'Weight management'
        WHEN 18 THEN 'Prenatal check' WHEN 19 THEN 'Post-surgery follow-up'
        WHEN 20 THEN 'Lab results review' WHEN 21 THEN 'Prescription renewal'
        WHEN 22 THEN 'Sports injury' WHEN 23 THEN 'Breathing difficulties'
        WHEN 24 THEN 'Chronic fatigue' WHEN 25 THEN 'Thyroid consultation'
        WHEN 26 THEN 'Cancer screening' WHEN 27 THEN 'Heart palpitations'
        WHEN 28 THEN 'Migraine' WHEN 29 THEN 'Arthritis management'
        WHEN 30 THEN 'Dermatology consultation' WHEN 31 THEN 'Pediatric wellness'
        WHEN 32 THEN 'Geriatric assessment' WHEN 33 THEN 'Mental health therapy'
        WHEN 34 THEN 'Physical therapy' WHEN 35 THEN 'Occupational therapy'
        WHEN 36 THEN 'Speech therapy' WHEN 37 THEN 'Nutrition counseling'
        WHEN 38 THEN 'Smoking cessation' WHEN 39 THEN 'Allergy testing'
        WHEN 40 THEN 'Bone density scan' WHEN 41 THEN 'MRI follow-up'
        WHEN 42 THEN 'CT scan review' WHEN 43 THEN 'Ultrasound'
        WHEN 44 THEN 'X-ray review' WHEN 45 THEN 'Cardiac stress test'
        WHEN 46 THEN 'Pulmonary function test' WHEN 47 THEN 'Endoscopy follow-up'
        WHEN 48 THEN 'Colonoscopy screening' WHEN 49 THEN 'Mammogram'
        WHEN 50 THEN 'Prostate exam' WHEN 51 THEN 'Eye examination'
        WHEN 52 THEN 'Dental referral' WHEN 53 THEN 'ENT consultation'
        WHEN 54 THEN 'Urology consultation' WHEN 55 THEN 'Neurology evaluation'
        WHEN 56 THEN 'Orthopedic assessment' WHEN 57 THEN 'Rheumatology consult'
        WHEN 58 THEN 'Infectious disease follow-up' WHEN 59 THEN 'Pain management'
    END
    
    -- Status (weighted distribution)
    SET @StatusID = CASE 
        WHEN @ApptCount % 100 < 60 THEN 2  -- Completed
        WHEN @ApptCount % 100 < 75 THEN 1  -- Scheduled
        WHEN @ApptCount % 100 < 88 THEN 3  -- Cancelled
        WHEN @ApptCount % 100 < 96 THEN 4  -- No-Show
        ELSE 5                              -- Rescheduled
    END
    
    -- Insert directly (no duplicates because we spread them 2 hours apart)
    INSERT INTO Appointment (PatientID, DoctorID, AppointmentDate, Reason, AppointmentStatusID)
    VALUES (@PatientID, @DoctorID, @AppointmentDate, @Reason, @StatusID)
    
    SET @ApptCount = @ApptCount + 1
END
GO

-- ============================================
-- INSERT MEDICAL RECORDS
-- ONLY for completed appointments (StatusID = 2)
-- ============================================
DECLARE @MRCount INT = 1
DECLARE @AppointmentID INT
DECLARE @Diagnosis NVARCHAR(MAX)
DECLARE @Observation NVARCHAR(MAX)
DECLARE @ClinicalNotes NVARCHAR(MAX)
DECLARE @RecordDate DATE

DECLARE MedRecCursor CURSOR FOR
    SELECT AppointmentID, CAST(AppointmentDate AS DATE)
    FROM Appointment 
    WHERE AppointmentStatusID = 2  -- Only completed
    ORDER BY AppointmentID

OPEN MedRecCursor
FETCH NEXT FROM MedRecCursor INTO @AppointmentID, @RecordDate

WHILE @@FETCH_STATUS = 0
BEGIN
    -- Diagnosis (cycles through 20 conditions)
    SET @Diagnosis = CASE (@MRCount % 20)
        WHEN 0 THEN 'Essential hypertension'
        WHEN 1 THEN 'Type 2 diabetes mellitus'
        WHEN 2 THEN 'Acute upper respiratory infection'
        WHEN 3 THEN 'Generalized anxiety disorder'
        WHEN 4 THEN 'Major depressive disorder'
        WHEN 5 THEN 'Gastroesophageal reflux disease'
        WHEN 6 THEN 'Acute bronchitis'
        WHEN 7 THEN 'Allergic rhinitis'
        WHEN 8 THEN 'Migraine without aura'
        WHEN 9 THEN 'Lower back pain'
        WHEN 10 THEN 'Vitamin D deficiency'
        WHEN 11 THEN 'Iron deficiency anemia'
        WHEN 12 THEN 'Hypothyroidism'
        WHEN 13 THEN 'Atopic dermatitis'
        WHEN 14 THEN 'Osteoarthritis'
        WHEN 15 THEN 'Insomnia'
        WHEN 16 THEN 'Asthma'
        WHEN 17 THEN 'Urinary tract infection'
        WHEN 18 THEN 'Conjunctivitis'
        WHEN 19 THEN 'Sinusitis'
    END
    
    -- Observation (cycles through 10)
    SET @Observation = CASE (@MRCount % 10)
        WHEN 0 THEN 'Patient presents with mild symptoms. Vitals normal. No acute distress noted.'
        WHEN 1 THEN 'Moderate symptoms reported. Blood pressure slightly elevated. Recommended follow-up.'
        WHEN 2 THEN 'Patient stable. Responding well to current treatment plan. Continue monitoring.'
        WHEN 3 THEN 'Acute condition identified. Immediate treatment initiated. Patient advised rest.'
        WHEN 4 THEN 'Chronic condition being managed. Lab results within acceptable ranges.'
        WHEN 5 THEN 'New symptoms reported. Additional testing recommended for differential diagnosis.'
        WHEN 6 THEN 'Improvement noted since last visit. Patient reports better quality of life.'
        WHEN 7 THEN 'Condition deteriorated. Treatment plan adjusted. Close monitoring required.'
        WHEN 8 THEN 'Routine examination findings within normal limits. Preventive care discussed.'
        WHEN 9 THEN 'Complex presentation requiring multidisciplinary consultation. Referrals made.'
    END
    
    -- Clinical notes
    SET @ClinicalNotes = 'Patient arrived on time. History reviewed. Physical examination performed. ' +
        'Vital signs: BP ' + CAST(110 + (@MRCount % 40) AS NVARCHAR) + '/' + 
        CAST(70 + (@MRCount % 30) AS NVARCHAR) + 
        ', HR ' + CAST(60 + (@MRCount % 40) AS NVARCHAR) + 
        ' bpm, Temp 98.' + CAST((@MRCount % 10) AS NVARCHAR) + 
        '°F. Assessment and plan discussed with patient. Follow-up scheduled as needed.'
    
    INSERT INTO MedicalRecord (AppointmentID, Diagnosis, Observation, ClinicalNotes, RecordDate)
    VALUES (@AppointmentID, @Diagnosis, @Observation, @ClinicalNotes, @RecordDate)
    
    SET @MRCount = @MRCount + 1
    FETCH NEXT FROM MedRecCursor INTO @AppointmentID, @RecordDate
END

CLOSE MedRecCursor
DEALLOCATE MedRecCursor
GO

-- ============================================
-- INSERT PRESCRIPTIONS
-- Only for ~70% of medical records
-- ============================================
DECLARE @PrescCount INT = 1
DECLARE @MedicalRecordID INT
DECLARE @MedicationName NVARCHAR(100)
DECLARE @Dosage NVARCHAR(50)
DECLARE @Frequency NVARCHAR(50)
DECLARE @StartDate DATE
DECLARE @EndDate DATE

DECLARE PrescCursor CURSOR FOR
    SELECT MedicalRecordID, RecordDate
    FROM MedicalRecord
    ORDER BY MedicalRecordID

OPEN PrescCursor
FETCH NEXT FROM PrescCursor INTO @MedicalRecordID, @StartDate

WHILE @@FETCH_STATUS = 0
BEGIN
    -- Only insert prescription for ~70% of records (skip every 3rd out of 10)
    IF @PrescCount % 10 <= 7
    BEGIN
        SET @MedicationName = CASE (@PrescCount % 20)
            WHEN 0 THEN 'Lisinopril' WHEN 1 THEN 'Metformin' WHEN 2 THEN 'Amlodipine'
            WHEN 3 THEN 'Omeprazole' WHEN 4 THEN 'Levothyroxine' WHEN 5 THEN 'Metoprolol'
            WHEN 6 THEN 'Simvastatin' WHEN 7 THEN 'Albuterol' WHEN 8 THEN 'Gabapentin'
            WHEN 9 THEN 'Hydrochlorothiazide' WHEN 10 THEN 'Sertraline' WHEN 11 THEN 'Amoxicillin'
            WHEN 12 THEN 'Ibuprofen' WHEN 13 THEN 'Acetaminophen' WHEN 14 THEN 'Azithromycin'
            WHEN 15 THEN 'Prednisone' WHEN 16 THEN 'Fluoxetine' WHEN 17 THEN 'Cetirizine'
            WHEN 18 THEN 'Montelukast' WHEN 19 THEN 'Atorvastatin'
        END
        
        SET @Dosage = CASE (@PrescCount % 5)
            WHEN 0 THEN '5mg' WHEN 1 THEN '10mg' WHEN 2 THEN '25mg'
            WHEN 3 THEN '50mg' WHEN 4 THEN '100mg'
        END
        
        SET @Frequency = CASE (@PrescCount % 5)
            WHEN 0 THEN 'Once daily' WHEN 1 THEN 'Twice daily'
            WHEN 2 THEN 'Three times daily' WHEN 3 THEN 'Every 4-6 hours as needed'
            WHEN 4 THEN 'Once weekly'
        END
        
        -- Duration: 7-90 days
        SET @EndDate = DATEADD(DAY, 7 + (@PrescCount % 84), @StartDate)
        
        INSERT INTO Prescription (MedicalRecordID, MedicationName, Dosage, Frequency, StartDate, EndDate)
        VALUES (@MedicalRecordID, @MedicationName, @Dosage, @Frequency, @StartDate, @EndDate)
    END
    
    SET @PrescCount = @PrescCount + 1
    FETCH NEXT FROM PrescCursor INTO @MedicalRecordID, @StartDate
END

CLOSE PrescCursor
DEALLOCATE PrescCursor
GO

-- ============================================
-- INSERT Into BILLING
-- ONLY for completed appointments
-- ============================================
DECLARE @BillCount INT = 1
DECLARE @B_PatientID INT
DECLARE @B_AppointmentID INT
DECLARE @TotalAmount DECIMAL(10,2)
DECLARE @BillingDate DATE
DECLARE @PaymentMethodID INT
DECLARE @PaymentStatusID INT

DECLARE BillCursor CURSOR FOR
    SELECT AppointmentID, PatientID, CAST(AppointmentDate AS DATE)
    FROM Appointment
    WHERE AppointmentStatusID = 2  -- Only completed
    ORDER BY AppointmentID

OPEN BillCursor
FETCH NEXT FROM BillCursor INTO @B_AppointmentID, @B_PatientID, @BillingDate

WHILE @@FETCH_STATUS = 0
BEGIN
    -- Amount: $75 - $1575
    SET @TotalAmount = CAST(75.00 + ((@BillCount * 7.5) % 1500) AS DECIMAL(10,2))
    
    -- Payment method (1-6)
    SET @PaymentMethodID = (@BillCount % 6) + 1
    
    -- Payment status distribution
    SET @PaymentStatusID = CASE 
        WHEN @BillCount % 100 < 60 THEN 2  -- Completed
        WHEN @BillCount % 100 < 75 THEN 1  -- Pending
        WHEN @BillCount % 100 < 85 THEN 6  -- Insurance Pending
        WHEN @BillCount % 100 < 95 THEN 5  -- Partially Paid
        WHEN @BillCount % 100 < 98 THEN 4  -- Refunded
        ELSE 3                              -- Failed
    END
    
    INSERT INTO Billing (PatientID, AppointmentID, TotalAmount, BillingDate, PaymentMethodID, PaymentStatusID)
    VALUES (@B_PatientID, @B_AppointmentID, @TotalAmount, @BillingDate, @PaymentMethodID, @PaymentStatusID)
    
    SET @BillCount = @BillCount + 1
    FETCH NEXT FROM BillCursor INTO @B_AppointmentID, @B_PatientID, @BillingDate
END

CLOSE BillCursor
DEALLOCATE BillCursor
GO


-- ============================================
-- Insert Into Diagnoses
-- ============================================
INSERT INTO Diagnosis (DiagnosisCode, DiagnosisName, Description)
VALUES 
('I10', 'Essential hypertension', 'High blood pressure with no identifiable cause'),
('E11', 'Type 2 diabetes mellitus', 'Chronic condition affecting glucose metabolism'),
('J06', 'Acute upper respiratory infection', 'Common cold or upper respiratory tract infection'),
('F41', 'Generalized anxiety disorder', 'Excessive anxiety and worry about various events'),
('F32', 'Major depressive disorder', 'Persistent feeling of sadness and loss of interest'),
('K21', 'Gastroesophageal reflux disease', 'Stomach acid frequently flows back into esophagus'),
('J20', 'Acute bronchitis', 'Inflammation of the bronchial tubes'),
('J30', 'Allergic rhinitis', 'Allergic reaction causing sneezing, congestion, itchy eyes'),
('G43', 'Migraine without aura', 'Recurring headache of moderate to severe intensity'),
('M54', 'Lower back pain', 'Pain in the lumbar region of the spine'),
('E55', 'Vitamin D deficiency', 'Insufficient vitamin D levels in the body'),
('D50', 'Iron deficiency anemia', 'Anemia caused by lack of iron'),
('E03', 'Hypothyroidism', 'Underactive thyroid gland'),
('L20', 'Atopic dermatitis', 'Chronic itchy skin condition (eczema)'),
('M15', 'Osteoarthritis', 'Degenerative joint disease'),
('G47', 'Insomnia', 'Persistent difficulty falling or staying asleep'),
('J45', 'Asthma', 'Chronic inflammatory disease of the airways'),
('N39', 'Urinary tract infection', 'Infection in any part of the urinary system'),
('H10', 'Conjunctivitis', 'Inflammation of the conjunctiva (pink eye)'),
('J01', 'Sinusitis', 'Inflammation of the sinus cavities')
GO

-- ============================================
-- Insert Into Treatment Types
-- ============================================
INSERT INTO Treatment (TreatmentName, TreatmentCode, Description, StandardCost, DepartmentID)
VALUES 
-- Cardiology
('Electrocardiogram (EKG)', '93000', 'Heart rhythm and electrical activity test', 150.00, 1),
('Stress Test', '93015', 'Cardiovascular stress test on treadmill', 450.00, 1),
('Echocardiogram', '93306', 'Ultrasound of the heart', 750.00, 1),
-- Pediatrics
('Well-Child Visit', '99382', 'Routine pediatric checkup', 120.00, 2),
('Vaccination', '90471', 'Immunization administration', 85.00, 2),
-- Radiology
('Chest X-Ray', '71045', 'Radiological examination of chest', 200.00, 3),
('CT Scan Head', '70450', 'Computed tomography of head', 850.00, 3),
('MRI Lumbar Spine', '72148', 'Magnetic resonance imaging of lower spine', 1200.00, 3),
('Ultrasound Abdomen', '76700', 'Ultrasound examination of abdomen', 350.00, 3),
-- Orthopedics
('Joint Injection', '20610', 'Therapeutic injection into joint', 180.00, 4),
('Cast Application', '29075', 'Application of cast for fracture', 250.00, 4),
('Physical Therapy Session', '97110', 'Therapeutic exercises session', 110.00, 4),
-- Neurology
('EEG', '95816', 'Electroencephalogram - brain wave test', 500.00, 5),
('Nerve Conduction Study', '95904', 'Nerve and muscle function test', 350.00, 5),
-- Dermatology
('Skin Biopsy', '11100', 'Skin tissue sample for diagnosis', 280.00, 6),
('Cryotherapy', '17000', 'Freezing treatment for skin lesions', 130.00, 6),
-- Oncology
('Chemotherapy Session', '96413', 'Chemotherapy drug administration', 1500.00, 7),
('Radiation Therapy', '77412', 'Radiation treatment session', 2000.00, 7),
-- Gastroenterology
('Colonoscopy', '45378', 'Endoscopic examination of colon', 950.00, 8),
('Upper Endoscopy', '43235', 'Endoscopic examination of upper GI tract', 800.00, 8),
-- Pulmonology
('Pulmonary Function Test', '94010', 'Lung capacity and function test', 300.00, 9),
-- Ophthalmology
('Eye Exam Comprehensive', '92014', 'Complete eye health examination', 175.00, 10),
('Cataract Surgery', '66984', 'Surgical removal of cataract', 2500.00, 10),
-- Endocrinology
('Thyroid Ultrasound', '76536', 'Ultrasound of thyroid gland', 250.00, 11),
('Glucose Tolerance Test', '82951', 'Blood sugar metabolism test', 90.00, 11),
-- Psychiatry
('Psychotherapy Session', '90837', '60-minute individual therapy session', 200.00, 12),
-- Urology
('Urinalysis', '81001', 'Urine analysis and culture', 45.00, 13),
('Kidney Stone Removal', '52317', 'Lithotripsy for kidney stones', 3500.00, 13),
-- ENT
('Hearing Test', '92557', 'Comprehensive audiometry evaluation', 130.00, 14),
('Tonsillectomy', '42826', 'Surgical removal of tonsils', 1800.00, 14),
-- Emergency
('Emergency Room Visit', '99284', 'Emergency department comprehensive visit', 850.00, 15),
('Laceration Repair', '12001', 'Suturing of simple wound', 300.00, 15),
('IV Fluid Administration', '96360', 'Intravenous fluid therapy', 150.00, 15)
GO

-- ============================================
-- Generate Appointment-Treatment Data
-- For completed appointments, assign 1-3 random treatments
-- ============================================
DECLARE @ApptTreatmentCount INT = 1
DECLARE @AppointmentID INT
DECLARE @TreatmentID INT
DECLARE @Quantity INT
DECLARE @ActualCost DECIMAL(10,2)
DECLARE @DepartmentID INT
DECLARE @DoctorID INT

DECLARE ApptTreatCursor CURSOR FOR
    SELECT a.AppointmentID, d.DepartmentID
    FROM Appointment a
    JOIN Doctor doc ON a.DoctorID = doc.DoctorID
    JOIN Department d ON doc.DepartmentID = d.DepartmentID
    WHERE a.AppointmentStatusID = 2  -- Only completed appointments
    ORDER BY a.AppointmentID

OPEN ApptTreatCursor
FETCH NEXT FROM ApptTreatCursor INTO @AppointmentID, @DepartmentID

WHILE @@FETCH_STATUS = 0
BEGIN
    -- Each appointment gets 1-3 treatments
    DECLARE @NumTreatments INT = (@ApptTreatmentCount % 3) + 1
    DECLARE @TreatCounter INT = 1
    
    WHILE @TreatCounter <= @NumTreatments
    BEGIN
        -- Get a treatment, preferring department-specific ones but sometimes cross-department
        IF @TreatCounter = 1
            -- Primary treatment: from the doctor's department
            SELECT TOP 1 @TreatmentID = TreatmentID, @ActualCost = StandardCost
            FROM Treatment
            WHERE DepartmentID = @DepartmentID
            ORDER BY NEWID()
        ELSE
            -- Additional treatments: from any department
            SELECT TOP 1 @TreatmentID = TreatmentID, @ActualCost = StandardCost
            FROM Treatment
            ORDER BY NEWID()
        
        -- Quantity: usually 1, sometimes more
        SET @Quantity = CASE 
            WHEN @ApptTreatmentCount % 10 < 8 THEN 1
            ELSE (@ApptTreatmentCount % 3) + 1
        END
        
        SET @ActualCost = @ActualCost * @Quantity
        
        INSERT INTO AppointmentTreatment (AppointmentID, TreatmentID, Quantity, ActualCost, Notes)
        VALUES (@AppointmentID, @TreatmentID, @Quantity, @ActualCost, NULL)
        
        SET @TreatCounter = @TreatCounter + 1
    END
    
    SET @ApptTreatmentCount = @ApptTreatmentCount + 1
    FETCH NEXT FROM ApptTreatCursor INTO @AppointmentID, @DepartmentID
END

CLOSE ApptTreatCursor
DEALLOCATE ApptTreatCursor
GO

-- ============================================
-- Update Billing based on actual treatments
-- ============================================
UPDATE Billing
SET TotalAmount = (
    SELECT ISNULL(SUM(at.ActualCost), 0) + 100.00  -- Treatment costs + $100 consultation fee
    FROM AppointmentTreatment at
    WHERE at.AppointmentID = Billing.AppointmentID
)
WHERE EXISTS (
    SELECT 1 FROM AppointmentTreatment at 
    WHERE at.AppointmentID = Billing.AppointmentID
)
GO

-- Verify some bills now match treatments
PRINT 'Sample bills with treatment breakdown:'
SELECT TOP 5 
    b.BillingID,
    b.TotalAmount AS BillTotal,
    (SELECT SUM(at.ActualCost) FROM AppointmentTreatment at WHERE at.AppointmentID = b.AppointmentID) AS TreatmentCost,
    b.TotalAmount - (SELECT ISNULL(SUM(at.ActualCost), 0) FROM AppointmentTreatment at WHERE at.AppointmentID = b.AppointmentID) AS ConsultationFee
FROM Billing b
ORDER BY b.BillingID
GO

