USE [BHP1-RO]
GO

/****** Object:  UserDefinedFunction [bhp].[fn_GetMashSchedName]    Script Date: 3/4/2020 10:59:32 AM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[fn_GetMashSchedName]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [bhp].[fn_GetMashSchedName]
GO

/****** Object:  UserDefinedFunction [bhp].[fn_GetMashSchedName]    Script Date: 3/4/2020 10:59:32 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


create function [bhp].[fn_GetMashSchedName](@id int)
returns nvarchar(200)
as
begin
	Declare @rtrnVal nvarchar(200);
	Select @rtrnVal = [Name] From [bhp].MashSchedMstr With (NoLock) Where (RowID=@id);
	Return IsNull(@RtrnVal,(Select [Name] FROM [bhp].MashSchedMstr Where (RowID = 0)));
end
GO


