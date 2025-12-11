USE [BHP1-RO]
GO

/****** Object:  UserDefinedFunction [bhp].[fn_GetHopNameV2]    Script Date: 2/27/2020 1:49:57 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[fn_GetHopNameV2]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [bhp].[fn_GetHopNameV2]
GO

/****** Object:  UserDefinedFunction [bhp].[fn_GetHopNameV2]    Script Date: 2/27/2020 1:49:57 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE function [bhp].[fn_GetHopNameV2](@id int)
returns varchar(100)
with encryption
as
begin
	Declare @rtrnVal varchar(100);
	Select @rtrnVal = [Name] From [bhp].[HopTypesV2] Where (RowID=@id);
	Return Isnull(@rtrnVal,(Select [Name] FROM [bhp].[HopTypesV2] With (NoLock) Where (RowID = 0)));
end
GO


