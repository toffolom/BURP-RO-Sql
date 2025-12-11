use [BHP1-RO]
go

if object_id(N'bhp.vw_AllowedHopDropTimerStages',N'V') is not null
begin
	drop view bhp.vw_AllowedHopDropTimerStages;
	print 'table:: ''bhp.vw_AllowedHopDropTimerStages'' dropped!!!';
end
go

if object_id(N'bhp.AllowedHopDropTimerStages',N'U') is not null
begin
	drop table bhp.AllowedHopDropTimerStages;
	print 'table:: ''bhp.AllowedHopDropTimerStages'' dropped!!!';
end
go

Create Table bhp.AllowedHopDropTimerStages (
	RowID int identity(1,1) not null,
	Fk_StageID int not null,
	Stages as (bhp.fn_GetStageName(Fk_StageID)),
	Comment nvarchar(2000) null,
	Constraint PK_AllowedHopDropTimerStages_RowID Primary Key NonClustered (RowID),
	Constraint FK_AllowedHopDropTimerStages_Fk_StagesID foreign key (Fk_StageID)
		References bhp.StageTypes (RowID)

)
go

Alter table bhp.AllowedHopDropTimerStages add
Constraint DF_AllowedHopDropTimerStages_Comment Default(N'no comment given...') For [Comment];
go

set identity_insert bhp.AllowedHopDropTimerStages On;
insert into bhp.AllowedHopDropTimerStages (RowID, Fk_StageID, Comment) Values (0,0,'DO NOT REMOVE!!!');
set identity_insert bhp.AllowedHopDropTimerStages Off;
go

insert into bhp.AllowedHopDropTimerStages(Fk_StageID)
select RowID
from bhp.StageTypes Where AllowedInHopSched=1 And (Name like 'boil%' or Name like '1st wort%' or Name like 'kettle%')
go

Create Trigger bhp.AllowedHopDropTimerStages_Del_99 on bhp.AllowedHopDropTimerStages
for delete
as
begin
	If Exists (Select * from deleted where RowID = 0)
	Begin
		Raiserror(N'Row ''zero'' cannot be removed!!!',16,1);
		Rollback Transaction;
		Return
	End
end
go


Create View bhp.vw_AllowedHopDropTimerStages (
	RowID, Fk_StageID, Name, Comment
)
with schemabinding
as
	select RowID, Fk_StageID, Stages, ISNULL(Comment,N'No comment given...')
	from bhp.AllowedHopDropTimerStages
	where RowID > 0;
go

