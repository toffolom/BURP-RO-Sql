DECLARE	@return_value int,
		@RowID int,
		@guid varchar(256);

Set @guid = newid();

EXEC	@return_value = [bwp].[AddGlblDeploymentRec]
		@SessID = N'00000000-0000-0000-0000-000000000000',
		@DeployGUID = @guid,
		@Name = N'Test deploy (global) #455',
		@IgnoreAll=1,
		@RowID = @RowID OUTPUT

SELECT	@RowID as N'@RowID'

SELECT	'Return Value' = @return_value

GO

select * from bwp.GlblDeploymentsInfo;
select * from bwp.IgnorePublications
