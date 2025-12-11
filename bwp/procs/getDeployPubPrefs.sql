use [BHP1-RO]
go

if object_id(N'[bwp].[GetPublicationPrefs]',N'P') is not null
begin
	Drop Proc [bwp].[GetPublicationPrefs];
	print 'Proc:: bwp.GetPublicationPrefs dropped!!!';
end
go

create proc bwp.[GetPublicationPrefs]
with encryption
as
begin
	Declare @rc int;
	Declare @mesg nvarchar(2000);
	Declare @status bit;

	Select * from di.vw_DeploymentPublications Order By [Name];

	Return @@ERROR;
end
go