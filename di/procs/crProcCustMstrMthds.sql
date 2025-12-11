

/****** Object:  StoredProcedure [di].[GetCustMstrs]    Script Date: 03/15/2011 15:59:54 ******/
IF OBJECT_ID(N'[di].[GetCustMstrs]',N'P') IS NOT NULL
BEGIN
DROP PROCEDURE [di].[GetCustMstrs];
Print 'Proc:: [di].GetCustMstrs dropped!!!';
END
GO

/****** Object:  StoredProcedure [di].[AddCustMstrRec]    Script Date: 03/15/2011 15:59:54 ******/
IF OBJECT_ID(N'[di].[AddCustMstrRec]',N'P') IS NOT NULL
BEGIN
DROP PROCEDURE [di].[AddCustMstrRec];
Print 'Proc:: [di].AddCustMstrRec dropped!!!';
END
GO

/****** Object:  StoredProcedure [di].[ChgCustMstrRec]    Script Date: 03/15/2011 15:59:54 ******/
IF OBJECT_ID(N'[di].[ChgCustMstrRec]',N'P') IS NOT NULL
BEGIN
DROP PROCEDURE [di].[ChgCustMstrRec];
Print 'Proc:: [di].ChgCustMstrRec dropped!!!';
END
GO

/****** Object:  StoredProcedure [di].[DelCustMstrRec]    Script Date: 03/15/2011 15:59:54 ******/
IF OBJECT_ID(N'[di].[DelCustMstrRec]',N'P') IS NOT NULL
BEGIN
DROP PROCEDURE [di].[DelCustMstrRec];
Print 'Proc:: [di].DelCustMstrRec dropped!!!';
END
GO

/****** Object:  StoredProcedure [di].[DelCustMstrs]    Script Date: 03/15/2011 15:59:54 ******/
IF OBJECT_ID(N'[di].[DelCustMstrs]',N'P') IS NOT NULL
BEGIN
DROP PROCEDURE [di].DelCustMstrs;
Print 'Proc:: [di].DelCustMstrs dropped!!!';
END
GO


create proc [di].GetCustMstrs (
	@SessID varchar(256),
	@CustID bigint = null -- if passed in we're look'n for specific cust rec!!!
)
with encryption, execute as 'sticky'
as
begin
	--Set NoCount On;
	
	Declare @rc int;
	Declare @mesg nvarchar(2000);
	Declare @sql nvarchar(max);
	Declare @SessRowID bigint;

	if (1=0) -- for visual studio dataset designer
	begin
		SELECT
			Cast(Null As bigint) As [RowID]
			,Cast(Null As nvarchar(200)) As [Name]
			,Cast(Null As nvarchar(256)) As [BHPUid]
			,Cast(Null As nvarchar(50)) As [BHPPwd]
			,Cast(Null As nvarchar(2000)) As [Hint]
			,Cast(Null As int) As [TotBlogs]
			,Cast(Null As int) As [TotRecipes]
			,Cast(Null As int) As [RoleBitMask]
			,Cast(Null As varchar(200)) As [RoleBitMaskAsStr]
			,Cast(Null As bit) As [AllowMultiSession]
			,Cast(Null As varchar(50)) As [DfltLang]
			,Cast(Null As int) As [fk_LastBeerDrank]
			,Cast(Null As nvarchar(200)) As [DisplayAs]
			,Cast(Null As datetime) As [EnteredOn]
			,Cast(Null As bit) As [AllowLogin]
			,cast(null as bit) As [Verified]
			,cast(null as int)  As [LangID]
			,cast(null as int) DeploymentID
		set fmtonly off;
		return 0;
	end

	If Not Exists (Select * from [di].SessionMstr Where SessID = @SessID)
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66006; -- this nbr represents users is not logged in.
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	Select @SessRowID=[RowID] from [di].SessionMstr Where (SessID=@SessID);

	Set @CustID = Coalesce(@CustID,0);
	
	--Raiserror('[di].GetCustMstrs:: @SessID:[%s] @CustID:[%I64d]...',0,1,@SessID,@CustID);
	
	Set @Sql = N'
SELECT
	C.[RowID]
	,C.[Name]
	,C.[BHPUid]
	,C.[BHPPwd]
	,C.[Hint]
	,ISNULL(C.[TotBlogs],0) As TotBlogs
	,ISNULL(C.[TotRecipes],0) As TotRecipes
	,ISNULL(C.[RoleBitMask],0) As RoleBitMask
	,C.[RoleBitMaskAsStr]
	,ISNULL(C.[AllowMultiSession],0) As [AllowMultiSession]
	,C.[DfltLang]
	,ISNULL(C.[fk_LastBeerDrank],0) As [fk_LastBeerDrank]
	,C.[DisplayAs]
	,C.[EnteredOn]
	,ISNULL(C.[AllowLogin],0) As [AllowLogin]
	,ISNULL(C.[Verified],0) As [Verified]
	,C.fk_LangID As [LangID]
	,C.fk_DeployInfo As DeploymentID
FROM [di].[CustMstr] As C
Inner Join [di].SessionMstr S On (C.fk_DeployInfo = S.fk_DeployInfo And S.RowID=@InSess)
' + 
case @CustID 
when 0 Then 'WHere (C.RowID > @InCustID);'
else 'Where (C.RowID = @InCustID);'
end;

	--Raiserror(N'%s',0,1,@Sql);

	Exec @rc = sp_ExecuteSql @Stmt=@Sql, @Params=N'@InCustID bigint, @InSess int',@InCustID=@CustID,@InSess=@SessRowID
	With Result Sets (
		(
			[RowID] bigint
			,[Name] nvarchar(200)
			,[BHPUid] nvarchar(256)
			,[BHPPwd] nvarchar(50)
			,[Hint] nvarchar(2000) null
			,[TotBlogs] int null
			,[TotRecipes] int null
			,[RoleBitMask] int null
			,[RoleBitMaskAsStr] varchar(200) null
			,[AllowMultiSession] bit null
			,[DfltLang] varchar(50) null
			,[fk_LastBeerDrank] int null
			,[DisplayAs] nvarchar(200) null
			,[EnteredOn] datetime null
			,[AllowLogin] bit null
			,[Verified] bit null
			,[LangID] int null
			,[DeploymentID] varchar(256) null
		)
	);
	
	Return ISNULL(@Rc, @@ERROR);
end
go

print 'Proc:: [di].GetCustMstrs created...';
go

/*
declare @u sysname;
set @u = 'BHPApp';
execute as user = @u; --'BHPApp';
exec [di].[GetCustMstrs] @SessID='00000000-0000-0000-0000-000000000000', @CustID=1001;
revert;

*/



Create Proc [di].AddCustMstrRec (
	@SessID varchar(256),
	@Name nvarchar(200),
	@DisplayAs nvarchar(200) = null,
	@BHPUid nvarchar(256),
	@BHPPswd nvarchar(50),
	@Hint nvarchar(2000) = null,
	@Roles int,
	@LangID int = null,
	@AllowMulti bit = 0,
	@AllowLogin bit = 1,
	@RowID bigint output -- the rowid gen'd after the insert.
)
with encryption
as
begin
	--Set NoCount On;
	
	Declare @rc int;
	Declare @mesg nvarchar(2000);
	Declare @Tbl Table ([ID] bigint);
	
	If Not Exists (Select * from [di].SessionMstr Where SessID = @SessID)
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66006; -- this nbr represents users is not logged in.
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	-- make sure that the 'new' bhpuid value is unique!!!
	if Exists (select 1 from [di].CustMstr Where BHPUid=@BHPUid And fk_DeployInfo=0)
	begin
		-- should write and audit record here...
		Set @rc = 66102; -- this nbr represents users is not logged in.
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1,@BHPUid);
		Return @rc;
	end
	
	Insert Into [di].CustMstr (
		[Name]
		,[BHPUid]
		,[BHPPwd]
		,[Hint]
		,[TotBlogs]
		,[TotRecipes]
		,[RoleBitMask]
		,[AllowMultiSession]
		,[fk_LangID]
		,[fk_LastBeerDrank]
		,[DisplayAs]
		,[AllowLogin]
		,[Verified]
		,[fk_DeployInfo]
		,[EncPswd]
	)
	Output Inserted.RowID Into @Tbl([ID])
	Values 
	(
		@Name,
		@BHPUid,
		@BHPPswd,
		@Hint,
		0,
		0,
		@Roles,
		@AllowMulti,
		ISNULL(@LangID,(select top (1) RowID from [di].Languages Where [Lang]='en_us')),
		0,
		Coalesce(@DisplayAs, @Name, ''),
		ISNULL(@AllowLogin,0), -- initially can't login till verified!!!
		0, -- initially not verified!!!
		0,
		HASHBYTES('SHA1', @BHPPswd)
	);
	
	-- add the customers BHPUID value to the customer targets table...as a preliminary entry so subscriptions have
	-- a target for delivery.
	-- TODO: maybe this should be an 'environment' check...if environ var 'auto add customer target upon new customer creation'
	insert into [di].CustTargetInfo (Fk_CustID, Fk_DeployInfo, TargetType, [Target])
	select [ID], 0, 'email', @BHPUid
	From @Tbl;

	Select @RowID=[ID] from @Tbl;

	Return @@ERROR;
End
go

Print 'Proc:: [di].AddCustMstrRec created...';
go


Create Proc [di].DelCustMstrRec (
	@SessID varchar(256),
	@RowID bigint, -- customer we're removing...
	@CleanAll bit = 0 -- if set to (1)...we'll cleanup all tables that might contain info assoc w/this customer!!!
)
with encryption
as
begin
	Declare @rc int;
	Declare @mesg nvarchar(2000);
	
	If Not Exists (Select * from [di].SessionMstr Where SessID = convert(uniqueidentifier,@SessID))
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66006; -- this nbr represents users is not logged in.
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	Delete [di].CustTargetInfo Where Fk_CustID=@RowID And Fk_DeployInfo=0;
	
	Delete [di].CustMstr Where (RowID = @RowID And RowID > 0 And fk_DeployInfo = 0);

	Set @rc = @@ERROR;

	Return @rc;
	
End
go

Print 'Proc:: [di].DelCustMstrRec created...';
go


Create Proc [di].ChgCustMstrRec (
	@SessID varchar(256),
	@RowID bigint,
	@Name nvarchar(200),
	@DisplayAs nvarchar(200) = null,
	@BHPUid nvarchar(256),
	@BHPPswd nvarchar(50),
	@Hint nvarchar(2000) = null,
	@Roles int,
	@LangID int = null,
	@AllowMulti bit = 0,
	@AllowLogin bit = 1
)
with encryption
as
begin
	Declare @rc int;
	Declare @mesg nvarchar(2000);

	Set @rc = 0;
	
	If (@RowID Is Null)
	Begin
		Raiserror('Parameter:[@CustID] must be provided...aborting!!!',16,1);
		Return -1;
	End

	If Not Exists (Select 1 from [di].CustMstr Where RowID = @RowID And RowID > 0)
	Begin
		-- should write and audit record here...someone trying to change an unknown hop type!?
		Set @rc = 66057; -- this nbr represents an uknown customer record
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End
	
	If Not Exists (Select * from [di].SessionMstr Where SessID = convert(uniqueidentifier,@SessID))
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66006; -- this nbr represents users is not logged in.
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	-- make sure that the change to the bhpuid value is unique!!!
	if Exists (select 1 from [di].CustMstr Where BHPUid=@BHPUid And RowID != @RowID)
	begin
		-- should write and audit record here...
		Set @rc = 66102; -- this nbr represents users is not logged in.
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1,@BHPUid);
		Return @rc;
	end
	
	Update Top (1) [di].CustMstr
	Set
		[Name] = @Name,
		DisplayAs = @DisplayAs,
		[Hint] = @Hint,
		RoleBitMask = @Roles,
		fk_LangID = ISNULL(@LangID, (select top (1) RowID from [di].Languages Where [Lang] = 'en_us')),
		BHPPwd = @BHPPswd,
		BHPUid = @BHPUid,
		EncPswd = HASHBYTES('SHA1', @BHPPswd)
	Where (RowID=@RowID And RowID > 0 And fk_DeployInfo = 0);

	Set @Rc = @@Error;

	Return @rc;
End
go

Print 'Proc:: [di].ChgCustMstrRec created...';
go

revoke execute on [di].GetCustMstrs to [Public];
revoke execute on [di].AddCustMstrRec to [Public];
revoke execute on [di].DelCustMstrRec to [Public];
revoke execute on [di].ChgCustMstrRec to [Public];
go

checkpoint
go

print 'run script to grant [BHPApp] user permissions!!!'