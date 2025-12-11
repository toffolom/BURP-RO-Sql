USE [BHP1-RO]
GO

/****** Object:  UserDefinedFunction [bhp].[fn_GetGrainName]    Script Date: 3/3/2020 12:16:51 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[fn_GetGrainName]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [bhp].[fn_GetGrainName]
GO

/****** Object:  UserDefinedFunction [bhp].[fn_GetGrainName]    Script Date: 3/3/2020 12:16:51 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





create function [bhp].[fn_GetGrainName](@id int)
returns nvarchar(256)
with encryption
as
begin
	Declare @rtrnVal nvarchar(256);
	Select @rtrnVal = [Name] From [bhp].[GrainMstr] With (NoLock) Where (RowID=@id);
	Return Isnull(@rtrnVal,(Select [Name] FROM [bhp].[GrainMstr] With (NoLock) Where (RowID = 0)));
end

GO


