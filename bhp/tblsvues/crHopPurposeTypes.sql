USE [BHP1-RO]
GO

/****** Object:  Table [bhp].[HopPurposeTypes]    Script Date: 2/27/2020 1:13:27 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[HopPurposeTypes]') AND type in (N'U'))
DROP TABLE [bhp].[HopPurposeTypes]
GO

/****** Object:  UserDefinedFunction [dbo].[fn_GetHopNameV2]    Script Date: 6/19/2018 12:06:19 PM ******/
DROP FUNCTION [dbo].fn_GetHopPurposeStr
GO

/****** Object:  Table [bhp].[HopPurposeTypes]    Script Date: 2/27/2020 1:13:27 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [bhp].[HopPurposeTypes](
	[BitVal] [tinyint] NOT NULL,
	[Descr] [varchar](40) NULL,
	[Notes] [nvarchar](1000) NULL,
 CONSTRAINT [PK_HopPurposeTypes_BitVal] PRIMARY KEY NONCLUSTERED 
(
	[BitVal] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

Create Trigger [bhp].HopPurposeTypes_Del_99 on [bhp].[HopPurposeTypes]
--with encryption
after delete
as
begin
	Raiserror(N'Hop Purpose row(s) cannot be removed!!!',16,1);
	Rollback Transaction;
end
go

insert into [bhp].[HopPurposeTypes] (BitVal, Descr, Notes)
values (0, 'Undef',N'<Notes><Note nbr=''1''>DO NOT REMOVE!!!</Note><Notes>'),
(1, 'Aroma',N'<Notes><Note nbr=''1''>hop is used primarily for adding a/an aroma to beer</Note></Notes>'),
(2, 'Bittering',N'<Notes><Note nbr=''1''>hop is used primarily for bittering purposes in beer</Note></Notes>'),
(3, 'Dual',N'<Notes><Note nbr=''1''>hop can be used for either aroma or bittering purposes/reasons...</Note></Notes>');
go

create function [bhp].fn_GetHopPurposeStr(@val tinyint)
returns varchar(100)
with encryption
as
begin
	Declare @str varchar(100);
	Select @str = [Descr] From [bhp].HopPurposeTypes Where (BitVal = @val);
	Return ISNULL(@Str, 'Undef');
end
go