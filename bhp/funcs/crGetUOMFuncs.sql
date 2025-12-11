use [BHP1-RO]
go

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[fn_GetUOM]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
	drop function [bhp].[fn_GetUOM];
	print 'function:: [bhp].[fn_GetUOM] dropped!!!';
end
go

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[fn_GetUOMIdByNm]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
	drop function [bhp].[fn_GetUOMIdByNm];
	print 'function:: [bhp].[fn_GetUOMIdByNm] dropped!!!';
end
go

/****** Object:  UserDefinedFunction [bhp].[fn_GetUOM]    Script Date: 2/25/2020 11:31:26 AM ******/
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

create function [bhp].[fn_GetUOM](@id int)
returns varchar(50)
with encryption
as
begin
	Declare @rtrnVal varchar(50);
	Select @rtrnVal = UOM From [bhp].[UOMTypes] Where (RowID=@id);
	Return Isnull(@rtrnVal,'n/a');
end
GO

create function [bhp].fn_GetUOMIdByNm(@nm varchar(50))
returns int
with encryption
as
Begin
	Declare @id int;
	Select Top (1) @id = RowID From [bhp].UOMTypes WHere (UOM = @nm) or (Name = @nm);
	return ISNULL(@id,0);
end
go

