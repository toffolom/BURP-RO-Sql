USE [BHP1-RO]
GO

/****** Object:  UserDefinedFunction [di].[fn_GetCustLoginNm]    Script Date: 11/8/2018 3:35:12 PM ******/
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


create function [di].[fn_GetCustLoginNm](@id int)
returns nvarchar(256)
as
begin
	Declare @rtrnVal nvarchar(256);
	Select @rtrnVal = BHPUid From [di].[CustMstr] With (NoLock) Where (RowID=@id);
	Return Isnull(@rtrnVal,'unknwn@burp.net');
end

GO


