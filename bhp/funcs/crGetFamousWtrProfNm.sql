use [BHP1-RO]
go

drop function [bhp].fn_GetFamousWtrProfNm;
go

create function [bhp].fn_GetFamousWtrProfNm(@id int)
returns varchar(200)
with encryption
as
begin
	Declare @nm varchar(200);
	Select @nm = [Name] From [bhp].FamousWaterProfiles Where (RowID = @id);
	return coalesce(@nm, (Select [Name] From [bhp].FamousWaterProfiles Where (RowID = @id)));
end
go

checkpoint
go