USE [BHP1-RO]
GO

Drop Function [bhp].[fn_GetMashTypName];
go

/****** Object:  UserDefinedFunction [bhp].[fn_GetMashTypName]    Script Date: 3/4/2020 10:55:00 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

create function [bhp].[fn_GetMashTypName](@id int)
returns nvarchar(200)
as
begin
	Declare @rtrnVal nvarchar(200);
	Select @rtrnVal = [Name] From [bhp].MashTypeMstr Where (RowID=@id);
	Return Isnull(@rtrnVal,(Select [Name] FROM [bhp].MashTypeMstr Where (RowID = 0)));
end
GO


