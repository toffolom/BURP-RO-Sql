USE [BHP1-RO]
GO

/****** Object:  StoredProcedure [bhp].[GetYeastManufs]    Script Date: 03/15/2011 15:59:54 ******/
IF OBJECT_ID(N'[bhp].[GetYeastManufs]',N'P') IS NOT NULL
BEGIN
DROP PROCEDURE [bhp].[GetYeastManufs];
Print 'Proc:: [bhp].GetYeastManufs dropped!!!';
END
GO

/****** Object:  StoredProcedure [bhp].[AddYeastManuf]    Script Date: 03/15/2011 15:59:54 ******/
IF OBJECT_ID(N'[bhp].[AddYeastManuf]',N'P') IS NOT NULL
BEGIN
DROP PROCEDURE [bhp].[AddYeastManuf];
Print 'Proc:: [bhp].AddYeastManuf dropped!!!';
END
GO

/****** Object:  StoredProcedure [bhp].[ChgYeastManuf]    Script Date: 03/15/2011 15:59:54 ******/
IF OBJECT_ID(N'[bhp].[ChgYeastManuf]',N'P') IS NOT NULL
BEGIN
DROP PROCEDURE [bhp].[ChgYeastManuf];
Print 'Proc:: [bhp].ChgYeastManuf dropped!!!';
END
GO

/****** Object:  StoredProcedure [bhp].[ChgYeastManuf]    Script Date: 03/15/2011 15:59:54 ******/
IF OBJECT_ID(N'[bhp].[DelYeastManuf]',N'P') IS NOT NULL
BEGIN
DROP PROCEDURE [bhp].[DelYeastManuf];
Print 'Proc:: [bhp].DelYeastManuf dropped!!!';
END
GO

/*
** use this guid for testing...
** '00000000-0000-0000-0000-000000000000'
*/
create proc [bhp].GetYeastManufs (
	@SessID varchar(256)
)
with encryption
as
begin
	
	Declare @rc int;
	Declare @mesg nvarchar(2000);
	Declare @status bit;
	
	Exec @rc = [di].[IsSessStale] @SessID=@SessID, @Status=@Status output, @Mesgs=@Mesg output, @UpdLst=1;

	If (@rc != 0 or @status != 0)
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66006; -- this nbr represents users is not logged in.
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End
	
	SELECT 
		YM.RowID, ISNULL(YM.Name,'not set') AS Name, 
		Case When YM.fk_VolDiscUOM IS NULL Then (Select Top (1) RowID from [bhp].vw_VolumnUOM Where (UOM='oz')) Else YM.fk_VolDiscUOM End As fk_VolDiscUOM, 
		VolDiscUOM As UOMDescr,
		Convert(Int, Case When YM.MinOrderQty Is Null Then -99 Else YM.MinOrderQty End) As MinOrderQty,
		ISNULL(Phylum,'not set') As Phylum,
		YM.W3C, YM.EnteredOn, YM.EnteredBy, ISNULL(Lang,'en_us') As Lang,
		YM.fk_Country, C.Name As CountryName
	FROM [bhp].YeastManufacturers AS YM 
	Inner Join [di].Countries C On (YM.fk_Country = C.RowID)
	--WHERE  (YM.RowID > 0)
	ORDER BY YM.Name;
	
	Return 0;
end
go

print 'Proc:: [bhp].GetYeastManufs created...';
go

/*
** use this guid for testing...
** '00000000-0000-0000-0000-000000000000'
*/
Create Proc [bhp].AddYeastManuf (
	@SessID varchar(256),
	@Name nvarchar(300), -- name of grain manuf
	@VolDiscUOMID int = 0, -- volumn discount uom
	@MinOrder numeric(18,4) = 0, -- min order for vol discount
	@WebSite nvarchar(2000) = 'http://', -- manuf website
	@Phylum nvarchar(100) = Null, -- phylum name
	@Lang varchar(20) = 'en_us', -- language...dflt is 'en_us'
	@fk_Country int = 0,
	@RowID int output, -- generated rowid value
	@BCastMode bit = 1
)
with encryption
as
begin
	
	Declare @rc int;
	Declare @mesg nvarchar(2000);
	Declare @status bit;
	Declare @xml xml;
	Declare @EvntNm nvarchar(100) = N'Mfr';
	
	Exec @rc = [di].[IsSessStale] @SessID=@SessID, @Status=@Status output, @Mesgs=@Mesg output, @UpdLst=1;

	If (@rc != 0 or @status != 0)
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66006; -- this nbr represents users is not logged in.
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End
	
	If ((@VolDiscUOMID Is Not Null) And (Not Exists (Select * from [bhp].vw_VolumnUOM Where RowID = @VolDiscUOMID)))
	Begin
		-- should write and audit record here...someone trying use a non-monetary uom value
		Set @rc = 66015; -- this nbr represents a non-volume or weight uom error.
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	if exists (Select 1 from [bhp].YeastManufacturers Where (Name=@Name))
	begin
		Set @rc = 66099; -- this nbr a duplicate grain mfr name
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	end
	
	If ([di].[fn_IsNull](@Lang) Is Null)
		Select @Lang = Lang from [di].SessionMstr Where SessID = convert(uniqueidentifier,@SessID);
		

	Insert Into [bhp].YeastManufacturers (
		[Name]
		,[fk_VolDiscUOM]
		,[MinOrderQty]
		,[W3C]
		,[Phylum]
		,[Lang]
		,[fk_Country]
	)
	Select
		[di].[fn_IsNull](@Name),
		ISNULL(@VolDiscUOMID, 0),
		ISNULL(@MinOrder, 0),
		ISNULL([di].[fn_IsNull](@WebSite),'http://'),
		ISNULL([di].[fn_IsNull](@phylum),'not set'),
		ISNULL(@Lang,'en_us'),
		ISNULL(@fk_Country, 0);
	
	Set @RowID = Scope_Identity();

	If (@BCastMode = 1 And Exists (Select 1 from [di].[vw_DeploymentPublications] Where [Name]=@evntNm))
	begin
		exec [bhp].GenBurpMfrInfoMesg @mfrid=@RowID, @mfrType='yeast', @evnttype='add', @SessID=@SessID, @mesg = @xml output;
		exec [bhp].[PostToBWPRouter] @inMsg=@xml, @MsgNm=@EvntNm;
	end
	
	Return @@Error;
End
go

Print 'Proc:: [bhp].AddYeastManuf created...';
go

/*
** use this guid for testing...
** '00000000-0000-0000-0000-000000000000'
*/
Create Proc [bhp].DelYeastManuf (
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
	Declare @EvntNm nvarchar(100) = N'Mfr';
	
	Exec @rc = [di].[IsSessStale] @SessID=@SessID, @Status=@Status output, @Mesgs=@Mesg output, @UpdLst=1;

	If (@rc != 0 or @status != 0)
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66006; -- this nbr represents users is not logged in.
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End
	
	If Exists (Select * from [bhp].YeastMstr Where (fk_YeastMfr = @RowID))
	Begin
		-- should write and audit record here...someone trying use a non-monetary uom value
		Set @rc = 66024; -- this nbr represents a Yeast manuf has Yeasts in the system and cannot be removed.
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	If (@BCastMode = 1 And Exists (Select 1 from [di].[vw_DeploymentPublications] Where [Name]=@evntNm))
		exec [bhp].GenBurpMfrInfoMesg @mfrid=@RowID, @mfrType='yeast', @evnttype='del', @SessID=@SessID, @mesg = @xml output;
	
	Delete Top (1) [bhp].YeastManufacturers Where (RowID = @RowID);
	
	If (@BCastMode = 1 And Exists (Select 1 from [di].[vw_DeploymentPublications] Where [Name]=@evntNm))
		exec [bhp].[PostToBWPRouter] @inMsg=@xml, @MsgNm=@EvntNm;
	
	Return @@Error;
	
End
go

Print 'Proc:: [bhp].DelYeastManuf created...';
go

/*
** use this guid for testing...
** '00000000-0000-0000-0000-000000000000'
*/
Create Proc [bhp].ChgYeastManuf (
	@SessID varchar(256),
	@RowID int,
	@Name nvarchar(300),
	@VolDiscUOMID int = 0,
	@MinOrder numeric(18,4) = 0,
	@WebSite nvarchar(2000) = 'http://',
	@Phylum nvarchar(100) = Null,
	@Lang varchar(20) = 'en_us',
	@fk_Country int = 0,
	@BCastMode bit = 1
)
with encryption
as
begin
	
	Declare @rc int;
	Declare @mesg nvarchar(2000);
	Declare @status bit;
	Declare @xml xml;
	Declare @old table ([Name] nvarchar(256));
	Declare @oldNm nvarchar(256);
	Declare @EvntNm nvarchar(100) = N'Mfr';
	
	Set @rc = 0;
	
	If (@RowID Is Null)
	Begin
		Raiserror('Parameter:[@RowID] must be provided...aborting!!!',16,1);
		Return -1;
	End
	
	If ((@RowID Is Not Null) And (Not Exists (Select * from [bhp].YeastManufacturers Where RowID = @RowID And RowID > 0)))
	Begin
		-- should write and audit record here...someone trying to change an unknown Yeast type!?
		Set @rc = 66036; -- this nbr represents an unknown Yeast manuf id
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End
	
	Exec @rc = [di].[IsSessStale] @SessID=@SessID, @Status=@Status output, @Mesgs=@Mesg output, @UpdLst=1;

	If (@rc != 0 or @status != 0)
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66006; -- this nbr represents users is not logged in.
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End
	
	If ((@VolDiscUOMID Is Not Null) And (Not Exists (Select * from [bhp].vw_VolumnUOM Where RowID = @VolDiscUOMID)))
	Begin
		-- should write and audit record here...someone trying use a non-monetary uom value
		Set @rc = 66015; -- this nbr represents a non-volume or weight uom error.
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	if exists (Select 1 from [bhp].YeastManufacturers Where (Name=@Name And RowID != @Rowid))
	begin
		Set @rc = 66099; -- this nbr a duplicate mfr name...
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	end

	/*
	** launch the actual update now....
	*/
	Update Top (1) [bhp].YeastManufacturers
		Set
			Name = @Name,
			fk_VolDiscUOM = ISNULL(@VolDiscUOMID,0),
			MinOrderQty = ISNULL(@MinOrder,0),
			W3C = ISNULL(@WebSite,'http://'),
			Phylum = @Phylum,
			Lang = ISNULL(@Lang,'en_us'),
			fk_Country = ISNULL(@fk_Country, 0)
	Output Deleted.Name into @Old(Name)
	Where (RowID = @RowID);

	If (@BCastMode = 1 And Exists (Select 1 from [di].[vw_DeploymentPublications] Where [Name]=@evntNm))
	begin
		exec [bhp].GenBurpMfrInfoMesg @mfrid=@RowID, @mfrType='yeast', @evnttype='chg', @SessID=@SessID, @mesg = @xml output;
		
		Select @oldNm = [Name] from @old;
		
		set @xml.modify('
			declare namespace b="http://burp.net/recipe/evnts";
			insert attribute old {sql:variable("@oldNm")}
			into (/b:Burp_Belch/b:Payload/b:Manuf_Evnt/b:Info/b:Name)[1]
		');

		exec [bhp].[PostToBWPRouter] @inMsg=@xml, @MsgNm=@EvntNm;
	end
	
	Return @@ERROR;
End
go

Print 'Proc:: [bhp].ChgYeastManuf created...';
go

checkpoint
go
