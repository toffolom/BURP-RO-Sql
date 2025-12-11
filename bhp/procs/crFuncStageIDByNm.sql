use [BHP1-RO]
go

drop function [bhp].fn_GetStageIDByNm;
go

create function [bhp].fn_GetStageIDByNm(@nm varchar(50))
returns int
with encryption
as
Begin
	Declare @id int;

	Select Top (1) @id = RowID From [bhp].StageTypes WHere (Name = @nm) or (AKA1 = @nm) or (AKA2 = @nm) or (AKA3 = @nm);

	return ISNULL(@id,0);
end
go

--grant execute on [bhp].fn_GetStageIDByNm to [public]
--go