use [BHP1-RO]
go


if object_id(N'[di].DeploymentPrefsMstr',N'U') is not null
begin
	drop table [di].DeploymentPrefsMstr;
	print 'table:: [di].DeploymentPrefsMstr dropped!!!';
end
go


Create Table [di].DeploymentPrefsMstr (
	RowID smallint identity(1,1)
		Constraint PK_DeployPrefsMstr_RowID Primary Key NonClustered,
	Name varchar(200) not null,
	Manditory bit not null,
	Notes nvarchar(2000) null,
	EnteredOn datetime null,
	UpdatedOn datetime null,
	Domain varchar(20) not null
		Constraint DF_DeploymentPrefsMstr_Domain Default('element'),
		Constraint CHK_DeploymentPrefsMstr_Domain Check([Domain] in ('element','segment','undef'))
);
go

Alter table [di].DeploymentPrefsMstr add
constraint DF_DeployPrefsMstr_Notes default(N'no comments given...') for [Notes],
constraint DF_DeployPrefsMstr_EnteredOn default(getdate()) for [EnteredOn],
constraint DF_DeployPrefsMstr_UpdatedOn default(0) for [UpdatedOn],
constraint DF_DeployPrefsMstr_Manditory default(0) for [Manditory];
go

set identity_insert [di].DeploymentPrefsMstr on;
insert [di].DeploymentPrefsMstr(RowID, [Name], Notes, [Domain]) values (0,'Undef','DO NOT REMOVE!!!','undef');
set identity_insert [di].DeploymentPrefsMstr off;
go

insert into [di].DeploymentPrefsMstr ([Name], Manditory, Notes, [Domain])
values ('AgingSched', 0, N'deployment wants to recv/send aging schedule information','segment'),
('HopSched', 0, N'wants to recv/send hop schedules...','segment'),
('MashSched', 0, N'wants to recv/send mash schedules...','segment'),
('AHAStyle', 0, N'wants to recv/send aha style values...','element'),
('HopTimerStage', 0, N'willing to recv/send hop timer stage values','element'),
('TagWord', 0, N'wants to recv/send tag word values','element'),
('Color', 0, N'wants to recv/send color values...','element'),
('Country', 0, N'wants to recv/send country values...','element'),
('Env', 1, N'willing to recv/send environment table values...NOTE: NO OVERRIDE...must be delivered to subscriber!!!','element'),
('Mfr', 0, N'willing to recv/send manufacturer values...','element'),
('Extract', 0, N'willing to recv/send extract values...','element'),
('Grain', 0, N'willing to recv/send grain settings...','element'),
('GrainType', 0, N'willing to recv/send grain type settings.','element'),
('Hop', 0, N'wants to recv/send hop value settings...','element'),
('HopPurpose', 0, N'willing to recv/send hop purpose values...','element'),
('Yeast', 0, N'willing to recv/send yeast settings/values...','element'),
('YeastType', 0, N'willing to recv/send yeast type information','element'),
('Package', 0, N'willing to recv/send yeast packaging information.','element'),
('Flocculation', 0, N'willing to recv/send yeast flocculation ratings.','element'),
('Ingredient', 0, N'willing to recv/send ingredient word.','element'),
('WtrProfile', 0, N'willing to recv/send water profile settings...','element'),
('GCWord', 1, N'willing to recv/send g.carlin words!!!','element'),
('UOM', 0, N'willing to recv/send unit-of-measure settings/values','element'),
('Stage', 0, N'willing to recv/send community stage values.','element'),
('Lang', 1, N'willing to recv/send system language settings.','element'),
('MashType', 0, N'willing to recv/send community mashing type settings/values...','element'),
('CustomerRecipe',0,'a customer created a recipe message...','segment'),
('RecipeTargets',0,'a recipe target(s) info message.','segment'),
('RecipeGrains',0,'a recipe grain bill message.','segment'),
('RecipeYeasts',0,'a recipe yeasts message.','segment'),
('RecipeHops',0,'recipe hop schedule message.','segment'),
('RecipeAdjunct',0,'adjuncts for a recipe message','segment'),
('RecipeWater',0,'a water profile message for a recipe','segment')
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
go

