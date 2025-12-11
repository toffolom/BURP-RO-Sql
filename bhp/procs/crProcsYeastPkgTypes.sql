USE [BHP1-RO]
GO

/****** Object:  StoredProcedure [bhp].[GetYeastPackagingTypes]    Script Date: 03/15/2011 15:59:54 ******/
IF OBJECT_ID(N'[bhp].[GetYeastPackagingTypes]',N'P') IS NOT NULL
BEGIN
DROP PROCEDURE [bhp].[GetYeastPackagingTypes];
Print 'Proc:: [bhp].GetYeastPackagingTypes dropped!!!';
END
GO

/****** Object:  StoredProcedure [bhp].[AddYeastPkgType]    Script Date: 03/15/2011 15:59:54 ******/
IF OBJECT_ID(N'[bhp].[AddYeastPkgType]',N'P') IS NOT NULL
BEGIN
DROP PROCEDURE [bhp].[AddYeastPkgType];
Print 'Proc:: [bhp].AddYeastPkgType dropped!!!';
END
GO

/****** Object:  StoredProcedure [bhp].[ChgYeastPkgType]    Script Date: 03/15/2011 15:59:54 ******/
IF OBJECT_ID(N'[bhp].[ChgYeastPkgType]',N'P') IS NOT NULL
BEGIN
DROP PROCEDURE [bhp].[ChgYeastPkgType];
Print 'Proc:: [bhp].ChgYeastPkgType dropped!!!';
END
GO

/****** Object:  StoredProcedure [bhp].[ChgYeastPkgType]    Script Date: 03/15/2011 15:59:54 ******/
IF OBJECT_ID(N'[bhp].[DelYeastPkgType]',N'P') IS NOT NULL
BEGIN
DROP PROCEDURE [bhp].[DelYeastPkgType];
Print 'Proc:: [bhp].DelYeastPkgType dropped!!!';
END
GO

/*
** use this guid for testing...
** '00000000-0000-0000-0000-000000000000'
*/
create proc [bhp].GetYeastPackagingTypes (
	@SessID varchar(256)
)
with encryption
as
begin
	--set nocount on;
	
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
		RowID, ISNULL(Name,'not set') AS Name, 
		ISNULL(Lang,'en_us') As Lang, ISNULL(Notes, 'not set') Notes
	FROM [bhp].YeastPackagingTypes
	WHERE  (RowID > 0)
	ORDER BY Name;
	
	Return 0;
end
go

print 'Proc:: [bhp].GetYeastPackagingTypes created...';
go

/*
** use this guid for testing...
** '00000000-0000-0000-0000-000000000000'
*/
Create Proc [bhp].AddYeastPkgType (
	@SessID varchar(256),
	@Name nvarchar(300), -- name of grain manuf
	@Notes nvarchar(500) = N'no comment given...', -- any notes you want to add w/record
	@Lang varchar(20) = 'en_us', -- language...dflt is 'en_us'
	@BCastMode bit = 1,
	@RowID int output -- generated rowid value
)
with encryption
as
begin
	Declare @rc int;
	Declare @mesg nvarchar(2000);
	Declare @status bit;
	Declare @xml xml;
	Declare @evntNm nvarchar(100) = N'Package';
	
	Exec @rc = [di].[IsSessStale] @SessID=@SessID, @status=@status output, @Mesgs=@mesg output, @UpdLst=1;

	If (@rc != 0 or @status != 0)
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66006; -- this nbr represents users is not logged in.
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End
	
	If ([di].[fn_IsNull](@Lang) Is Null)
		Select @Lang = Lang from [di].SessionMstr Where SessID = convert(uniqueidentifier,@SessID);
	
	Insert Into [bhp].YeastPackagingTypes(
		[Name]
		,[Notes]
		,[Lang]
	)
	Select
		[di].[fn_IsNull](@Name),
		@Notes,
		@Lang;
	
	Set @RowID = Scope_Identity();

	If (@BCastMode = 1 And Exists (Select 1 from [di].[vw_DeploymentPublications] Where [Name]=@evntNm))
	Begin
		exec @rc = [bhp].GenBurpYeastPkgInfoMesg @pkgID=@RowID, @evnttype='add', @SessID = @SessID, @mesg = @xml output;
		exec [bhp].[PostToBWPRouter] @inMsg=@xml, @msgNm=@evntNm;
	End
	
	Return @@Error;
End
go

Print 'Proc:: [bhp].AddYeastPkgType created...';
go

/*
** use this guid for testing...
** '00000000-0000-0000-0000-000000000000'
*/
Create Proc [bhp].DelYeastPkgType (
	@SessID varchar(256),
	@RowID int, -- unique identifier of row to delete (primary key value).
	@BCastMode bit = 1
)
with encryption
as
begin
	
	Declare @rc int;
	Declare @mesg nvarchar(2000);
	Declare @status bit;
	Declare @xml xml;
	Declare @evntNm nvarchar(100) = N'Package';
	
	Exec @rc = [di].[IsSessStale] @SessID=@SessID, @status=@status output, @Mesgs=@mesg output, @UpdLst=1;

	If (@rc != 0 or @status != 0)
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66006; -- this nbr represents users is not logged in.
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End
	
	If Exists (Select * from [bhp].YeastMstr Where (fk_YeastPkgTyp = @RowID))
	Begin
		-- should write and audit record here...someone trying use a non-monetary uom value
		Set @rc = 66037; -- this nbr represents a Yeast manuf has Yeasts in the system and cannot be removed.
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		
		Raiserror(@Mesg,16,1);
		Return @rc;
	End
	
	If (@BCastMode = 1 And Exists (Select 1 from [di].[vw_DeploymentPublications] Where [Name]=@evntNm))
		exec @rc = [bhp].GenBurpYeastPkgInfoMesg @pkgID=@RowID, @evnttype='del', @SessID = @SessID, @mesg = @xml output;
	
	Delete Top (1) [bhp].YeastPackagingTypes Where (RowID = @RowID);

	If (@BCastMode = 1 And Exists (Select 1 from [di].[vw_DeploymentPublications] Where [Name]=@evntNm))
		exec [bhp].[PostToBWPRouter] @inMsg=@xml, @msgNm=@evntNm;
	
	Return @@Error;
	
End
go

Print 'Proc:: [bhp].DelYeastPkgType created...';
go

/*
** use this guid for testing...
** '00000000-0000-0000-0000-000000000000'
*/
Create Proc [bhp].ChgYeastPkgType (
	@SessID varchar(256),
	@RowID int,
	@Name nvarchar(300),
	@Note nvarchar(500) = Null,
	@Lang varchar(20) = 'en_us',
	@BCastMode bit = 1
)
with encryption
as
begin
	
	Declare @rc int;
	Declare @mesg nvarchar(2000);
	Declare @status bit;
	Declare @Sql nvarchar(max);
	Declare @xml xml;
	Declare @oldinfo Table ([Name] nvarchar(200));
	Declare @old nvarchar(200);
	Declare @evntNm nvarchar(100) = N'Package';
	
	If (@RowID Is Null)
	Begin
		Raiserror('Parameter:[@RowID] must be provided...aborting!!!',16,1);
		Return -1;
	End
	
	If ((@RowID Is Not Null) And (Not Exists (Select * from [bhp].YeastPackagingTypes Where RowID = @RowID And RowID > 0)))
	Begin
		-- should write and audit record here...someone trying to change an unknown Yeast type!?
		Set @rc = 66038; -- this nbr represents an unknown Yeast pkg id
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
	
	/*
	** launch the actual update now....
	*/
	Update Top (1) [bhp].YeastPackagingTypes
		Set
			Name = ISNULL(@Name,(select top (1) Name from [bhp].YeastPackagingTypes Where (RowID=@RowID))),
			Notes = ISNULL(@Note,(select top (1) Notes from [bhp].YeastPackagingTypes Where (RowID=@RowID))),
			Lang = ISNULL(@Lang,(select top (1) Lang from [bhp].YeastPackagingTypes Where (RowID=@RowID)))
	Output Deleted.Name into @oldinfo(Name)
	Where (RowID = @RowID);

	If (@BCastMode = 1 And Exists (Select 1 from [di].[vw_DeploymentPublications] Where [Name]=@evntNm))
	Begin
		Select @old = Name from @oldinfo;
	
		exec @rc = [bhp].GenBurpYeastPkgInfoMesg @pkgID=@RowID, @evnttype='chg', @SessID = @SessID, @mesg = @xml output;

		set @xml.modify('
			declare namespace b="http://burp.net/recipe/evnts";
			insert (
				attribute old {sql:variable("@old")}
			)
			into (/b:Burp_Belch/b:Payload/b:Yeast_Evnt/b:Pkg_Info/b:Name)[1]
		');

		exec [bhp].[PostToBWPRouter] @inMsg=@xml, @msgNm=@evntNm;
	End
	
	Return @@ERROR;
End
go

Print 'Proc:: [bhp].ChgYeastPkgType created...';
go

checkpoint
