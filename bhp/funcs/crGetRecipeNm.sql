USE [BHP1-RO]
GO

/****** Object:  UserDefinedFunction [bhp].[fn_GetRecipeName]    Script Date: 3/3/2020 1:29:54 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[fn_GetRecipeName]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [bhp].[fn_GetRecipeName]
GO

/****** Object:  UserDefinedFunction [bhp].[fn_GetRecipeName]    Script Date: 3/3/2020 1:29:54 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE function [bhp].[fn_GetRecipeName](@id int)
returns nvarchar(256)
as
begin
	Declare @rtrnVal nvarchar(256);
	Select @rtrnVal = [Name] From [bhp].RecipeJrnlMstr Where (RowID=@id);
	Return Isnull(@rtrnVal,(Select [Name] FROM [bhp].RecipeJrnlMstr Where (RowID = 0)));
end


GO


