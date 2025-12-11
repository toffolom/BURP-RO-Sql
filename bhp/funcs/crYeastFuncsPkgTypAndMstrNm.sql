USE [BHP1-RO]
GO

/****** Object:  UserDefinedFunction [bhp].[fn_YeastNm]    Script Date: 2/26/2020 2:49:48 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[fn_YeastNm]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [bhp].[fn_YeastNm]
GO

/****** Object:  UserDefinedFunction [bhp].[fn_GetYeastTypNm]    Script Date: 2/26/2020 2:49:48 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[fn_GetYeastTypNm]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [bhp].[fn_GetYeastTypNm]
GO

/****** Object:  UserDefinedFunction [bhp].[fn_GetYeastMfrNm]    Script Date: 2/26/2020 2:49:48 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[fn_GetYeastMfrNm]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [bhp].[fn_GetYeastMfrNm]
GO

/****** Object:  UserDefinedFunction [bhp].[fn_GetYeastMfrNm]    Script Date: 2/26/2020 2:49:48 PM ******/
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO



create function [bhp].[fn_GetYeastMfrNm](@id int)
returns nvarchar(300)
--with encryption
as
begin
	Declare @rtrnVal nvarchar(300);
	Select @rtrnVal = [Name] From [bhp].[YeastManufacturers] Where (RowID=@id);
	Return Isnull(@rtrnVal,(Select [Name] FROM [bhp].[YeastManufacturers] Where (RowID = 0)));
end

GO

/****** Object:  UserDefinedFunction [bhp].[fn_GetYeastTypNm]    Script Date: 2/26/2020 2:49:48 PM ******/
create function [bhp].[fn_GetYeastTypNm](@id int)
returns varchar(50)
--with encryption
as
begin
	Declare @rtrnVal varchar(50);
	Select @rtrnVal = [Name] From [bhp].[YeastTypes] Where (RowID=@id);
	Return Isnull(@rtrnVal,(Select [Name] FROM [bhp].[YeastTypes] Where (RowID = 0)));
end
GO

/****** Object:  UserDefinedFunction [bhp].[fn_YeastNm]    Script Date: 2/26/2020 2:49:48 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

create function [bhp].[fn_YeastNm] (@rowid int)
returns nvarchar(300)
--with Encryption
as
begin
	Declare @str nvarchar(300);
	
	Select @str = Name From [bhp].YeastMstr Where (RowID = @rowid);

	Return Coalesce(@str,N'n/a');
end
GO


