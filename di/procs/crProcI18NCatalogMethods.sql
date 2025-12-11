USE [BHP1-RO]
GO

/****** Object:  StoredProcedure [di].[GetI18NCatalog]    Script Date: 03/15/2011 15:59:54 ******/
IF OBJECT_ID(N'[di].[GetI18NCatalog]',N'P') IS NOT NULL
BEGIN
DROP PROCEDURE [di].[GetI18NCatalog];
Print 'Proc:: [di].GetI18NCatalog dropped!!!';
END
GO

/****** Object:  StoredProcedure [di].[AddI18NCatalogEntry]    Script Date: 03/15/2011 15:59:54 ******/
IF OBJECT_ID(N'[di].[AddI18NCatalogEntry]',N'P') IS NOT NULL
BEGIN
DROP PROCEDURE [di].[AddI18NCatalogEntry];
Print 'Proc:: [di].AddI18NCatalogEntry dropped!!!';
END
GO

/****** Object:  StoredProcedure [di].[ChgI18NCatalogEntry]    Script Date: 03/15/2011 15:59:54 ******/
IF OBJECT_ID(N'[di].[ChgI18NCatalogEntry]',N'P') IS NOT NULL
BEGIN
DROP PROCEDURE [di].[ChgI18NCatalogEntry];
Print 'Proc:: [di].ChgI18NCatalogEntry dropped!!!';
END
GO

/****** Object:  StoredProcedure [di].[DelI18NCatalogEntry]    Script Date: 03/15/2011 15:59:54 ******/
IF OBJECT_ID(N'[di].[DelI18NCatalogEntry]',N'P') IS NOT NULL
BEGIN
DROP PROCEDURE [di].[DelI18NCatalogEntry];
Print 'Proc:: [di].DelI18NCatalogEntry dropped!!!';
END
GO

create proc [di].GetI18NCatalog (
	@SessID varchar(256)
)
with encryption
as
begin
	--Set NoCount On;
	
	Declare @rc int;
	Declare @mesg nvarchar(2000);
	Declare @status bit;

	Exec @rc = [di].[IsSessStale] @SessID=@SessID, @status=@status output, @Mesgs=@mesg output, @UpdLst=1;

	If (@rc != 0 or @status != 0)
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66006; -- this nbr represents users is not logged in.
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End
	
	SELECT 
		[RowId]
		,[Nbr]
		,[Mesg_en_us]
		,ISNULL([SupercededByMsgNbr],0) As [SupercededByMsgNbr]
		,[Mesg_en_ca]
		,[Mesg_en_gb]
		,[Mesg_fr_fr]
		,[Mesg_de_de]
	FROM [di].[I18NMessageCatV2] Where (RowID > 0) Order By Nbr;
	
	Return @@ERROR;
end
go

print 'Proc:: [di].GetI18NCatalog created...';
go

/*
** use this guid for testing...
** '00000000-0000-0000-0000-000000000000'
*/
Create Proc [di].AddI18NCatalogEntry (
	@SessID varchar(256),
	@Nbr int,
	@Super int,
	@EnUs nvarchar(2000),
	@EnCa nvarchar(2000) = null,
	@EnGb nvarchar(2000) = null,
	@FrFr nvarchar(2000) = null,
	@DeDe nvarchar(2000) = null,
	@RowID int output, -- the rowid gen'd after the insert.
	@UpdMode bit = 1 -- if rec already there...update it?
)
with encryption
as
begin
	Declare @rc int;
	Declare @mesg nvarchar(2000);
	Declare @buff varchar(2000); -- general purpose buffer...
	Declare @deployMsg xml; -- holds a deployment belch message.
	Declare @sessMsg xml; -- hold session src node.
	Declare @i18nmsg xml; -- holds customer info node
	Declare @tbl Table ([id] int);
	Declare @status bit;
	
	Exec @rc = [di].[IsSessStale] @SessID=@SessID, @status=@status output, @Mesgs=@mesg output, @UpdLst=1;

	If (@rc != 0 or @status != 0)
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66006; -- this nbr represents users is not logged in.
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	If Exists (Select * from [di].I18NMessageCatV2 Where ([Nbr]=@Nbr) And @UpdMode=1)
	Begin
		Update [di].I18NMessageCatV2
		Set
			SupercededByMsgNbr = ISNULL(@Super,0),
			Mesg_en_us = @EnUs,
			Mesg_en_ca = [di].fn_IsNull(@EnCa),
			Mesg_en_gb = [di].fn_IsNull(@EnGb),
			Mesg_fr_fr = [di].fn_IsNull(@FrFr),
			Mesg_de_de = [di].fn_IsNull(@DeDe)
		Output inserted.RowID into @Tbl([ID])
		Where (Nbr=@nbr And RowID > 0);
		Select @RowID = [ID] from @tbl;
		Set @Rc = @@ERROR;
	End
	
	If Not Exists (Select * from [di].I18NMessageCatV2 WHere (Nbr=@Nbr))
	Begin
		Insert Into [di].I18NMessageCatV2 (
			[Nbr]
			,[Mesg_en_us]
			,[SupercededByMsgNbr]
			,[Mesg_en_ca]
			,[Mesg_en_gb]
			,[Mesg_fr_fr]
			,[Mesg_de_de]
		)
		Output Inserted.RowID Into @tbl([ID])
		Values 
		(
			@Nbr, 
			[di].fn_IsNull(@EnUs), 
			ISNULL(@Super,0), 
			[di].fn_IsNull(@EnCa), 
			[di].fn_IsNull(@EnGb), 
			[di].fn_IsNull(@FrFr), 
			[di].fn_IsNull(@DeDe)
		);
	
		Select @RowID = [ID] from @tbl;
		Set @rc = @@ERROR;
	End

	Return @rc;
End
go

Print 'Proc:: [di].AddI18NCatalogEntry created...';
go

Create Proc [di].DelI18NCatalogEntry (
	@SessID varchar(256),
	@Nbr int -- catalog entry we're removing
)
with encryption
as
begin
	
	Declare @rc int;
	Declare @mesg nvarchar(2000);
	Declare @deployMsg xml; -- holds a deployment belch message.
	Declare @sessMsg xml; -- hold session src node.
	Declare @i18nmsg xml; -- holds customer info node
	Declare @status bit;

	
	Exec @rc = [di].[IsSessStale] @SessID=@SessID, @status=@status output, @Mesgs=@mesg output, @UpdLst=1;

	If (@rc != 0 or @status != 0)
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66006; -- this nbr represents users is not logged in.
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	Delete [di].I18NMessageCatV2 Where (Nbr = @Nbr And RowID > 0);

	Set @rc = @@ERROR;

	Return @rc;
	
End
go

Print 'Proc:: [di].DelI18NCatalogEntry created...';
go


Create Proc [di].ChgI18NCatalogEntry (
	@SessID varchar(256),
	@Nbr int,
	@Super int = null,
	@EnUs nvarchar(2000),
	@EnCa nvarchar(2000) = null,
	@EnGb nvarchar(2000) = null,
	@FrFr nvarchar(2000) = null,
	@DeDe nvarchar(2000) = null,
	@AddMode bit = 1 -- if not present should we add the rec!?
)
with encryption
as
begin
	--Set NoCount On;
	
	Declare @rows int;
	Declare @rc int;
	Declare @mesg nvarchar(2000);
	Declare @buff varchar(2000); -- general purpose buffer...
	Declare @deployMsg xml; -- holds a deployment belch message.
	Declare @sessMsg xml; -- hold session src node.
	Declare @i18nmsg xml; -- holds customer info node
	Declare @status bit;
	--Declare @deployID varchar(256); -- deployment id from session.
	--Declare @sendmode varchar(40);

	Set @AddMode = ISNULL(@AddMode,1);
	
	If (@Nbr Is Null)
	Begin
		Raiserror('Parameter:[@Nbr] must be provided...aborting!!!',16,1);
		Return -1;
	End

	If (@AddMode=0) And Not Exists (Select 1 from [di].I18NMessageCatV2 Where Nbr = @Nbr And RowID > 0)
	Begin
		-- should write and audit record here...someone trying to change an unknown hop type!?
		Set @rc = 66095; -- this nbr represents an uknown i18n record
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End
	
	Exec @rc = [di].[IsSessStale] @SessID=@SessID, @status=@status output, @Mesgs=@mesg output, @UpdLst=1;

	If (@rc != 0 or @status != 0)
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66006; -- this nbr represents users is not logged in.
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	Update Top (1) [di].I18NMessageCatV2
	Set
		SupercededByMsgNbr = ISNULL(@Super,0),
		Mesg_en_us = @EnUs,
		Mesg_en_ca = @EnCa,
		Mesg_en_gb = @EnGb,
		Mesg_fr_fr = @FrFr,
		Mesg_de_de = @DeDe
	Where (Nbr=@Nbr And RowID > 0);

	Set @rows = @@ROWCOUNT;
	Set @Rc = @@Error;

	If (@rows = 0 And @AddMode = 1) -- attempt to add the rec...update didn't affect anything!!!
	Begin
		Insert Into [di].I18NMessageCatV2 (
			[Nbr]
			,[Mesg_en_us]
			,[SupercededByMsgNbr]
			,[Mesg_en_ca]
			,[Mesg_en_gb]
			,[Mesg_fr_fr]
			,[Mesg_de_de]
		)
		Values 
		(
			@Nbr, 
			[di].fn_IsNull(@EnUs), 
			ISNULL(@Super,0), 
			[di].fn_IsNull(@EnCa), 
			[di].fn_IsNull(@EnGb), 
			[di].fn_IsNull(@FrFr), 
			[di].fn_IsNull(@DeDe)
		);
	
		Set @rc = @@ERROR;
	End

	Return @rc;
End
go

Print 'Proc:: [di].ChgI18NCatalogEntry created...';
go

revoke execute on [di].GetI18NCatalog to [Public];
revoke execute on [di].AddI18NCatalogEntry to [Public];
revoke execute on [di].DelI18NCatalogEntry to [Public];
revoke execute on [di].ChgI18NCatalogEntry to [Public];
go

checkpoint