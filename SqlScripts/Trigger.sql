
USE MediCarePlusDB
GO
-- ============================================
-- TRIGGER: Automatic Billing Payment Status Updates
-- Purpose: When payment marked as Completed, record the date
-- ============================================
CREATE TRIGGER trg_UpdatePaymentDate
ON Billing
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    IF UPDATE(PaymentStatusID)
    BEGIN
        UPDATE b
        SET BillingDate = GETDATE()
        FROM Billing b
        JOIN inserted i ON b.BillingID = i.BillingID
        JOIN deleted d ON i.BillingID = d.BillingID
        WHERE i.PaymentStatusID = 2      -- Now Completed
        AND d.PaymentStatusID != 2        -- Was NOT Completed before
    END
END
GO