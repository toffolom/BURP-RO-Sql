USE [BHP1-RO]
GO

/****** Object:  UserDefinedFunction [bhp].[fn_GetSpargeType]    Script Date: 3/4/2020 10:57:38 AM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[fn_GetSpargeType]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [bhp].[fn_GetSpargeType]
GO

/****** Object:  UserDefinedFunction [bhp].[fn_GetSpargeType]    Script Date: 3/4/2020 10:57:38 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


create function [bhp].[fn_GetSpargeType](@id int)
returns varchar(50)
as
begin
	Declare @rtrnVal varchar(50);
	Select @rtrnVal = [Name] From [bhp].SpargeTypes Where (RowID=@id);
	Return Isnull(@rtrnVal,(Select [Name] FROM [bhp].SpargeTypes Where (RowID = 0)));
end
GO


