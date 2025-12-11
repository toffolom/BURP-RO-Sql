-- ==============================================
-- Create dml trigger template Azure SQL Database 
-- ==============================================
-- Drop the dml trigger if it already exists
IF EXISTS(
  SELECT *
    FROM sys.triggers
   WHERE name = N'Environment_Trig_Ins_99'
     AND parent_class_desc = N'OBJECT_OR_COLUMN'
)
	DROP TRIGGER bhp.Environment_Trig_Ins_99
GO

CREATE TRIGGER bhp.Environment_Trig_Ins_99 
   ON  bhp.Environment 
   AFTER INSERT
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    Raiserror(N'Insert not allowed in this Environ table...use [di].[Environment] instead!!!',16,1);
	Rollback Transaction;

END
GO
