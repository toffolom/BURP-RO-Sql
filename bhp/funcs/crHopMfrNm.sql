use [BHP1-RO]
go

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[fn_HopMfrNm]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
begin
	print 'function: [bhp].fn_HopMfrNm dropped...';
	DROP FUNCTION [bhp].[fn_HopMfrNm]
end
GO

create function [bhp].[fn_HopMfrNm] (@rowid int)
returns nvarchar(300)
with Encryption
as
begin
	Declare @str nvarchar(300);
	Select @str = Name From [bhp].HopManufacturers Where (RowID = @rowid);
	Return Coalesce(@str,(Select Name From [bhp].HopManufacturers Where (RowID = 0)));
end
go

