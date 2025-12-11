USE [BHP1-RO]
GO

/****** Object:  UserDefinedFunction [di].[EndOfDay]    Script Date: 2/19/2020 11:22:20 AM ******/
SET ANSI_NULLS OFF
SET QUOTED_IDENTIFIER OFF
GO

/****** Object:  UserDefinedFunction [di].[fn_IsNull]    Script Date: 03/22/2011 16:27:06 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[di].[fn_IsNull]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [di].[fn_IsNull]
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[di].[EndOfDay]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [di].[EndOfDay];
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[di].[fn_CalcABV]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [di].[fn_CalcABV];
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[di].[StartOfDay]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [di].[StartOfDay];
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[di].[fn_ISTRUE]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [di].[fn_ISTRUE];
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[di].[fn_Timestamp]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [di].[fn_Timestamp];
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[di].[fn_ToXMLNote]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [di].[fn_ToXMLNote];
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[di].[fn_ISBrewer]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [di].[fn_ISBrewer];
GO

create function [di].fn_ISBrewer(@id bigint)
returns bit
with encryption
as
begin
	Declare @b bit;
	Set @b = 0;
	If Exists (
		Select * from [di].CustMstr C 
		Inner Join [di].RoleMstr R
		On (LEFT(R.Name,6) = 'Brewer')
		Where C.RowID = @id And ((C.RoleBitMask & R.BitVal) = R.BitVal))
	Begin
		Set @b = 1;
	End

	return @b;
end
go


create FUNCTION [di].[fn_IsNull] (@InBuff NVarchar(4000))
RETURNS NVARCHAR(4000)
with encryption
AS  
BEGIN 
	DECLARE @OutBuff NVARCHAR(4000);

	If (@InBuff Is Null or datalength(@Inbuff) is Null or @Inbuff = '') Return Null;

	SET @OutBuff = Rtrim(Ltrim(@InBuff));

	If (@OutBuff = '' or ascii(@outbuff) > 127)
		Set @OutBuff = Null;
	
	RETURN @OutBuff;
END
go

CREATE FUNCTION [di].[EndOfDay] (@now datetime)
RETURNS DATETIME AS  
BEGIN 
RETURN convert(datetime, convert(varchar,year(@now)) + '-' + convert(varchar,month(@now)) + '-' + convert(varchar,day(@now)) + ' 23:59:59.997')
END
GO

create function [di].[fn_CalcABV](@OG numeric(4,3), @FG numeric(4,3))
returns numeric(3,1)
--with encryption
as
begin
	Declare @out numeric(3,1);
	Set @out = 0;
	If (isnull(@OG,0) <= 0 or isnull(@fg,0) <=0)
		Goto Done;
	--Set @out = (((@OG * 1000) - (@FG * 1000)) / 7.46);
	--Set @out = case when @out > 0 then @out + 0.5 else 0.0 end
	Set @out = ((@OG - @FG) * 131.25);
Done:
	Return @out;
end
GO

CREATE FUNCTION [di].[fn_ISTRUE] (@BUFF VARCHAR(40))
RETURNS BIT
AS  
BEGIN 
	DECLARE @ABIT BIT;
	SET @ABIT = 
		CASE LEFT(@BUFF,1)
		WHEN '1' THEN 1 -- '1'
		WHEN 'T' THEN 1 -- 'true'
		WHEN 'Y' THEN 1 -- 'yes'
		WHEN 'O' THEN Case Left(@Buff,2) When 'OF' Then 0 Else 1 End -- 'on' or 'okay'...
		END;
	RETURN COALESCE(@ABIT,0);
END
GO

CREATE FUNCTION [di].[fn_Timestamp] (@TS DATETIME)  
RETURNS VARCHAR(24)
AS  
BEGIN 
	--
	-- This func returns a date/time string of 'YYYY-mm-DD HH:MM:SS'
	--
	DECLARE @BUFF VARCHAR(24)
	SELECT @BUFF = CONVERT(VARCHAR, @TS, 120)
	RETURN @BUFF
END
GO

CREATE Function [di].[fn_ToXMLNote](@in nvarchar(4000))
returns xml
as
begin

	Set Ansi_Nulls On;
	Set Quoted_Identifier On;

	Declare @isEmpty bit;
	Declare @n nvarchar(4000);
	Declare @outX xml;
	Declare @tmpX xml;
	Declare @nbr int;

	If @in is null
	Begin
		return N'<Notes xmlns="http://burp.net/recipe/evnts"><Note nbr=''0''/></Notes>';
	End
	
	set @nbr = 0;
	
	-- check for all empty varient cases
	set @isEmpty = 
		case @in
		when N'<Notes/>' Then 1
		when N'<Notes><Note nbr=''0''></Note></Notes>' Then 1
		when N'<Notes><Note/></Notes>' then 1
		when N'<Notes><Note></Note></Notes>' then 1
		when N'<Note/>' then 1
		when N'<Note></Note>' then 1
		when N'<Note nbr=''0''/>' then 1
		when N'<Note nbr=''0''></Note>' then 1
		end;

	If (@isEmpty = 1)
	Begin
		return N'<Notes xmlns="http://burp.net/recipe/evnts"><Note nbr=''0''/></Notes>';
	End

	set @outX = TRY_CONVERT(xml, @in);
	

	if (@outX is not null) -- it converted to xml...but if the @in is just a string that'll convert...we need to chk that
	begin
		if @outX.exist('/Note') = 1 -- they only passed in '<Note>...</Note>' for @in
		begin
			select @n = @outX.value('(.)[1]','nvarchar(4000)');
			Set @outX = N'<Notes xmlns="http://burp.net/recipe/evnts"/>';
			Set @outX.modify('
				declare namespace b="http://burp.net/recipe/evnts";
				insert <b:Note nbr=''1''>{sql:variable("@n")}</b:Note>
				into (/b:Notes)[1]
			');
		end
		else if @outX.exist('/Notes/Note') = 0 -- just a non-xml string passed in...
		Begin
			If TRY_CONVERT(XML, N'<Notes><Note nbr=''1''>' + @in + N'</Note></Notes>') IS NULL
			Begin
				Set @outX = N'<Notes xmlns="http://burp.net/recipe/evnts"/>';
				Set @outX.modify('
					declare namespace b="http://burp.net/recipe/evnts";
					insert <b:Note nbr=''1''>{sql:variable("@in")}</b:Note>
					into (/b:Notes)[1]
				');
			End
			Else -- its will convert to xml
			Begin
				Set @outX = TRY_CONVERT(XML, N'<Notes xmlns="http://burp.net/recipe/evnts"><Note nbr=''1''>' + @in + N'</Note></Notes>');
			End
		End
		Else If @outX.exist('/Notes/Note') = 1
		Begin
			Set @tmpX = N'<Notes xmlns="http://burp.net/recipe/evnts"/>';
			set @n = '';
			while exists (select * from @outX.nodes('/Notes/Note') as x(n) where x.n.value('(.)[1]','nvarchar(2000)') > @n)
			begin

				select top (1) @n = x.n.value('(.)[1]','nvarchar(2000)'), @nbr = @nbr + 1
				from @outX.nodes('/Notes/Note') as x(n)
				where x.n.value('(.)[1]','nvarchar(2000)') > @n
				order by x.n.value('(.)[1]','nvarchar(2000)');

				set @tmpX.modify('
					declare namespace b="http://burp.net/recipe/evnts";
					insert <b:Note nbr=''{sql:variable("@nbr")}''>{sql:variable("@n")}</b:Note> as last into (/b:Notes)[1]
				');

			end
			Set @outX = @tmpX;
		End
	end
	else -- @in will NOT convert...stuff it in and let the xml dml wrap it up w/appropriate protection...
	begin
		Set @outX = N'<Notes xmlns="http://burp.net/recipe/evnts"/>';
		Set @outX.modify('
			declare namespace b="http://burp.net/recipe/evnts";
			insert <b:Note nbr=''1''>{sql:variable("@in")}</b:Note>
			into (/b:Notes)[1]
		');
	end

	return ISNULL(@outX, N'<Notes  xmlns="http://burp.net/recipe/evnts"><Note nbr=''0''/></Notes>');
end
GO

CREATE FUNCTION [di].[StartOfDay] (@now datetime)
RETURNS DATETIME AS  
BEGIN 
RETURN Convert(datetime,Floor(Convert(Float,@Now)));
--convert(varchar,year(@now)) + '-' + convert(varchar,month(@now)) + '-' + convert(varchar,day(@now)) + ' 00:00:00')
END
GO


