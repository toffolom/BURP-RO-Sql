use [BHP1-RO]
go

/****** Object:  UserDefinedFunction [bhp].[fn_GetExtractName]    Script Date: 04/08/2011 13:31:55 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[fn_GetExtractName]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
Begin
	DROP FUNCTION [bhp].fn_GetExtractName
	Print 'Function::[bhp].[fn_GetExtractName] dropped...';
End
GO

create function [bhp].[fn_GetExtractName](@id int)
returns nvarchar(200)
with encryption
as
begin
	Declare @rtrnVal nvarchar(200);
	Select @rtrnVal = [Name] From [bhp].ExtractMstr With (NoLock) Where (RowID=@id);
	Return IsNull(@RtrnVal,(Select [Name] FROM [bhp].ExtractMstr Where (RowID = 0)));
end
GO