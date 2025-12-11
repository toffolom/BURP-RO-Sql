use [BHP1-RO]
go

If Object_ID(N'di.vw_DeploymentPrefsMstr',N'V') Is Not Null
Begin
	Drop View di.vw_DeploymentPrefsMstr;
	Print 'view:: di.vw_DeploymentPrefsMstr dropped!!!';
End
Go

Create View di.vw_DeploymentPrefsMstr 
with encryption
as
	Select
		[RowID]
		,[Name]
		,[Manditory]
		,[Notes]
		,[EnteredOn]
		,[UpdatedOn]
		,[Domain]
	FROM [di].[DeploymentPrefsMstr];
go

print 'view:: di.vw_DeploymentPrefsMstr created...';
go
