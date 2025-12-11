USE [BHP1-RO]
GO

/****** Object:  UserDefinedFunction [bhp].[fn_getAHACatName]    Script Date: 2/25/2020 12:00:14 PM ******/
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[fn_getAHACatName]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
	Drop Function [bhp].fn_GetAHACatName;
	print 'function:: [bhp].[fn_GetAHACatName] dropped!!!';
End
Go

create function [bhp].[fn_getAHACatName](@id int)
returns nvarchar(200)
with encryption
as
begin
	Declare @rtrnVal nvarchar(200);
	Select @rtrnVal = CategoryName FROM [bhp].AHABeerStyle Where (RowID = @ID);
	Return Isnull(@rtrnVal,(Select CategoryName From [bhp].AHABeerStyle Where (RowID=0)));
end
GO


