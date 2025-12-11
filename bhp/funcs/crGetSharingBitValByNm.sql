USE [BHP1-RO]
GO

/****** Object:  UserDefinedFunction [bhp].[fn_GetSharingBitValByNm]    Script Date: 3/5/2020 2:51:21 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[fn_GetSharingBitValByNm]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [bhp].[fn_GetSharingBitValByNm]
GO

/****** Object:  UserDefinedFunction [bhp].[fn_GetSharingBitValByNm]    Script Date: 3/5/2020 2:51:21 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


create function [bhp].[fn_GetSharingBitValByNm](@nm varchar(50))
returns smallint
--with encryption
as
Begin
	Declare @id smallint;

	Select Top (1) @id = BitVal From [bhp].SharingTypes WHere (Descr = @nm);

	return ISNULL(@id,0);
end
GO


