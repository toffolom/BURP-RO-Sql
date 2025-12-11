use [BHP1-RO]
go

if object_id('[bhp].[PostToBWPRouter]',N'P') is not null
begin
	drop proc [bhp].[PostToBWPRouter];
	print 'proc:: [bhp].[PostToBWPRouter] dropped!!!';
end
go

if object_id('[bhp].[AddBWPRouterMesg]',N'P') is not null
begin
	drop proc [bhp].[AddBWPRouterMesg];
	print 'proc:: [bhp].[AddBWPRouterMesg] dropped!!!';
end
go

if object_id('[bhp].[vw_PendingPublicationStats]',N'V') is not null
begin
	drop view [bhp].[vw_PendingPublicationStats];
	print 'table:: [bhp].[vw_PendingPublicationStats] dropped!!!';
end
go

if object_id('[bwp].[BWP_Cli_Log]',N'U') is not null
begin
	drop table [bwp].[BWP_Cli_Log];
	print 'table:: [bwp].[BWP_Cli_Log] dropped!!!';
end
go

if object_id('[di].[DeploymentPrefsMstr]',N'U') is not null
begin
	drop table [di].[DeploymentPrefsMstr];
	print 'table:: [di].[DeploymentPrefsMstr] dropped!!!';
end
go

if object_id('[di].[fn_GetPrefName]') is not null
begin
	drop function [di].[fn_GetPrefName];
	print 'function:: ''[di].[fn_GetPrefName] dropped!!!';
end
go

if exists (Select * from sys.schemas where name = 'bwp')
begin
	drop schema [bwp];
	print 'schema:: ''bwp'' dropped!!!';
end
go

if exists (Select * from sys.database_principals where name = 'bwp-cli')
begin
	drop user [bwp-cli];
	print 'user:: ''bwp-cli'' dropped!!!';
end
go

create user [bwp-cli] without login;
go

create schema [bwp] authorization [bwp-cli];
go

alter user [bwp-cli] with default_schema = [bwp];
go

Create Table [di].DeploymentPrefsMstr (
	RowID smallint identity(1,1)
		Constraint PK_DeployPrefsMstr_RowID Primary Key NonClustered,
	Name varchar(200) not null,
	Manditory bit not null,
	Notes nvarchar(2000) null,
	EnteredOn datetime null,
	UpdatedOn datetime null
);
go

Alter table [di].DeploymentPrefsMstr add
constraint DF_DeployPrefsMstr_Notes default(N'no comments given...') for [Notes],
constraint DF_DeployPrefsMstr_EnteredOn default(getdate()) for [EnteredOn],
constraint DF_DeployPrefsMstr_UpdatedOn default(0) for [UpdatedOn],
constraint DF_DeployPrefsMstr_Manditory default(0) for [Manditory];
go

set identity_insert [di].[DeploymentPrefsMstr] on;
insert [di].DeploymentPrefsMstr(RowID, [Name], Notes) values (0,'Undef','DO NOT REMOVE!!!');
set identity_insert [di].DeploymentPrefsMstr off;
go

insert into [di].DeploymentPrefsMstr ([Name], Manditory, Notes)
values ('AgingSched', 0, N'deployment wants to recv/send aging schedule information'),
('HopSched', 0, N'wants to recv/send hop schedules...'),
('MashSched', 0, N'wants to recv/send mash schedules...'),
('AHAStyle', 0, N'wants to recv/send aha style values...'),
('HopTimerStage', 0, N'willing to recv/send hop timer stage values'),
('TagWord', 0, N'wants to recv/send tag word values'),
('Color', 0, N'wants to recv/send color values...'),
('Country', 0, N'wants to recv/send country values...'),
('Env', 1, N'willing to recv/send environment table values...NOTE: NO OVERRIDE...must be delivered to subscriber!!!'),
('Mfr', 0, N'willing to recv/send manufacturer values...'),
('Extract', 0, N'willing to recv/send extract values...'),
('Grain', 0, N'willing to recv/send grain settings...'),
('GrainType', 0, N'willing to recv/send grain type settings.'),
('Hop', 0, N'wants to recv/send hop value settings...'),
('HopPurpose', 0, N'willing to recv/send hop purpose values...'),
('Yeast', 0, N'willing to recv/send yeast settings/values...'),
('YeastType', 0, N'willing to recv/send yeast type information'),
('Package', 0, N'willing to recv/send yeast packaging information.'),
('Flocculation', 0, N'willing to recv/send yeast flocculation ratings.'),
('Ingredient', 0, N'willing to recv/send ingredient word.'),
('WtrProfile', 0, N'willing to recv/send water profile settings...'),
('GCWord', 1, N'willing to recv/send g.carlin words!!!'),
('UOM', 0, N'willing to recv/send unit-of-measure settings/values'),
('Stage', 0, N'willing to recv/send community stage values.'),
('Lang', 1, N'willing to recv/send system language settings.'),
('MashType', 0, N'willing to recv/send community mashing type settings/values...'),
('CustomerRecipe',0,'a customer created a recipe message...'),
('RecipeTargets',0,'a recipe target(s) info message.'),
('RecipeGrains',0,'a recipe grain bill message.'),
('RecipeYeasts',0,'a recipe yeasts message.'),
('RecipeHops',0,'recipe hop schedule message.'),
('RecipeAdjunct',0,'adjuncts for a recipe message'),
('RecipeWater',0,'a water profile message for a recipe')
go

Create Unique Clustered Index IDX_DeployPrefsMstr_Name on [di].DeploymentPrefsMstr ( [Name] )
go

Create Trigger [di].Trig_DeploymentPrefsMstr_Del_99 on [di].DeploymentPrefsMstr
with encryption
for delete
as
begin
	if exists (select 1 from deleted where RowID=0)
	Begin
		Raiserror(N'Row ''zero'' cannot be removed...aborting!!!',16,1);
		Rollback Transaction;
	End
end
go

Create Trigger [di].Trig_DeploymentPrefsMstr_Upd_99 on [di].DeploymentPrefsMstr
with encryption
for update
as
begin
	update [di].DeploymentPrefsMstr
		Set UpdatedOn = getdate()
	from [di].DeploymentPrefsMstr M
	inner join inserted i on (M.RowID = i.RowID);
end
go

grant select on [di].[DeploymentPrefsMstr] to [bwp-cli];
grant select on [di].[Deployments] to [bwp-cli];
grant execute on [di].[fn_IsNull] to [bwp-cli];
go

create function di.fn_GetPrefName(@id smallint)
returns varchar(200)
with encryption
as
begin
	declare @n varchar(200);
	select @n = [Name] from [di].[DeploymentPrefsMstr] where RowID=@id;
	return ISNULL(@n,(Select [Name] from [di].[DeploymentPrefsMstr] where rowid=0));
end
go

create table [bwp].[BWP_Cli_Log] (
	RowID bigint identity(1,1) not null,
	Mesg nvarchar(max) not null,
	Fk_Type smallint not null,
	TypeName as ([di].[fn_GetPrefName](fk_Type)),
	PickedOn datetime null,
	EnteredOn datetime null,
	SendTo nvarchar(100) null,
Constraint [PK_bwp_cli_log_RowId] Primary Key NonClustered (RowID),
Constraint FK_bwp_Cli_Log_Fk_Type Foreign Key (Fk_Type)
	References [di].[DeploymentPrefsMstr] (RowID)
);
go



alter table [bwp].[BWP_Cli_Log] add
Constraint DF_bwp_cli_log_EnteredOn Default(getdate()) for [EnteredOn],
Constraint DF_bwp_cli_log_SendTo Default (N'router') for [SendTo],
Constraint DF_bwp_cli_log_Fk_type Default(0) for [Fk_Type]
go

Create View bhp.[vw_PendingPublicationStats] (
	PublicationType, SendingTo, NbrOfMessages
)
with encryption
as
	Select TOP 100 Percent
		L.TypeName, L.SendTo, Count(*)
	From bwp.BWP_Cli_Log L
	WHere PickedOn IS NULL
	Group By L.TypeName, L.SendTo
	Order By L.TypeName;

go

/*
** this proc is buried inside all the gui proc(s) that sit inside all the datasets
** so when the gui persists whatever, via proc(s), then this proc is called
** and writes the generated xml message built by ea. gui proc into a table
** that is polled by a gui thread, which extracts the messages in BWP_Cli_Log table
** and sends them over to the bwp websocket server who inturn routes it to 
** our router client. Why? cause this sql instance is hosted (Paas) and we don't have
** access to the underlying actual os to setup any SSB communication to the bwp router.
** NOTE: this explanation is not 100 accurate...i may pull the log directly from
**		the router instance instead of using the websocket server to propagate...tbd!!!
*/
Create Proc [bhp].[PostToBWPRouter] (
	@inMsg xml,
	@msgNm nvarchar(100),
	@recipient nvarchar(100) = N'router'
)
with encryption, execute as 'bwp-cli'
as
begin
	Declare @id smallint;
	select @id = RowID from [di].[DeploymentPrefsMstr] Where Name = @msgNm;

	Insert into [bwp].[BWP_Cli_Log] (Mesg, SendTo, Fk_Type) 
	Values(convert(nvarchar(max),@inMsg), ISNULL(@recipient,N'router'), ISNULL(@id,0));

	Return @@Error;
end
go

/*
** this is identical to the PostToBWPRouter proc...except it is intended
** to be called by the GUI.  THerefore it must accept the SessID!!!
*/
Create Proc [bhp].[AddBWPRouterMesg] (
	@SessID varchar(256),
	@inMsg nvarchar(max),
	@msgNm nvarchar(100),
	@recipient nvarchar(100) = N'router'
)
with encryption, execute as 'bwp-cli'
as
begin
	Declare @id smallint;
	Declare @rc int;
	Declare @I18NMsg nvarchar(2000);
	Declare @SessStatus bit;

	exec @rc = [di].IsSessStale @SessID=@SessID, @Status=@SessStatus output, @Mesgs=@I18NMsg output, @UpdLst=1;

	if (@rc != 0 or @SessStatus != 0)
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66006; -- this nbr represents users is not logged in.
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@I18NMsg output;
		Raiserror(@I18NMsg,16,1);
		Return @rc;
	End

	select @id = RowID from [di].[DeploymentPrefsMstr] Where Name = @msgNm;

	Insert into [bwp].[BWP_Cli_Log] (Mesg, SendTo, Fk_Type) 
	Values(@inMsg, ISNULL(@recipient,N'router'), ISNULL(@id,0));

	Return @@Error;
end
go

grant execute on [bhp].[AddBWPRouterMesg] to [bwp-cli];
grant execute on [bhp].[PostToBWPRouter] to [bwp-cli];
go

delete [di].[Deployments] where Name = 'BWP Router' or Name = 'BWP Websocket Server';
go
insert into [di].[Deployments](Name, Fk_DeploymentType, Descr, DeployedOn, DeploymentID, Fk_OwnerInfoID, Notes, Verified)
values ('BWP Router',0,'this is the bwp router in the cloud',0,'90909090-0000-0000-0000-909090909090',0,'this is the platform router',1),
('BWP Websocket Server',0,'this is the bwp websocket server in the cloud',0,'10101010-1010-0000-1010-000000000000',0,'this is the platform websocket server',1)
go


select *, USER_NAME(principal_id) from sys.schemas
select * from sys.database_principals;
select * from di.Deployments
select * from di.DeploymentPrefsMstr
go