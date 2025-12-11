USE [BHP1-RO]
GO

/****** Object:  StoredProcedure [bhp].[GetExtractManufs]    Script Date: 03/15/2011 15:59:54 ******/
IF OBJECT_ID(N'[bhp].[GetExtractManufs]',N'P') IS NOT NULL
BEGIN
DROP PROCEDURE [bhp].[GetExtractManufs];
Print 'Proc:: [bhp].GetExtractManufs dropped!!!';
END
GO

/****** Object:  StoredProcedure [bhp].[AddExtractManuf]    Script Date: 03/15/2011 15:59:54 ******/
IF OBJECT_ID(N'[bhp].[AddExtractManuf]',N'P') IS NOT NULL
BEGIN
DROP PROCEDURE [bhp].[AddExtractManuf];
Print 'Proc:: [bhp].AddExtractManuf dropped!!!';
END
GO

/****** Object:  StoredProcedure [bhp].[ChgExtractManuf]    Script Date: 03/15/2011 15:59:54 ******/
IF OBJECT_ID(N'[bhp].[ChgExtractManuf]',N'P') IS NOT NULL
BEGIN
DROP PROCEDURE [bhp].[ChgExtractManuf];
Print 'Proc:: [bhp].ChgExtractManuf dropped!!!';
END
GO

/****** Object:  StoredProcedure [bhp].[ChgExtractManuf]    Script Date: 03/15/2011 15:59:54 ******/
IF OBJECT_ID(N'[bhp].[DelExtractManuf]',N'P') IS NOT NULL
BEGIN
DROP PROCEDURE [bhp].[DelExtractManuf];
Print 'Proc:: [bhp].DelExtractManuf dropped!!!';
END
GO

/*
** use this guid for testing...
** '00000000-0000-0000-0000-000000000000'
*/
create proc [bhp].GetExtractManufs (
	@SessID varchar(256)
)
with encryption
as
begin
	Set Nocount on;
	
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
	
	SELECT 
		EX.RowID, 
		ISNULL(EX.Name,'not set') AS Name, 
		Case When EX.fk_VolDiscUOM IS NULL Then [bhp].[fn_GetUOMIdByNm]('oz') Else EX.fk_VolDiscUOM End As fk_VolDiscUOM, 
		VolDiscUOM As UOMDescr,
		Convert(Int, Case When EX.MinOrderQty Is Null Then -99 Else EX.MinOrderQty End) As MinOrderQty,
		EX.W3C, 
		EX.EnteredOn, 
		EX.EnteredBy, 
		ISNULL(Lang,'en_us') As Lang,
		EX.fk_Country, 
		C.Name As CountryName
	FROM [bhp].ExtractManufacturers AS EX 
	Inner Join [di].Countries C On (EX.fk_Country = C.RowID)
	--WHERE  (EX.RowID > 0)
	ORDER BY EX.Name;
	
	Return 0;
end
go

print 'Proc:: [bhp].GetExtractManufs created...';
go

/*
** use this guid for testing...
** '00000000-0000-0000-0000-000000000000'
*/
Create Proc [bhp].AddExtractManuf (
	@SessID varchar(256),
	@Name nvarchar(300), -- name of grain manuf
	@VolDiscUOMID int = 0, -- volumn discount uom
	@MinOrder numeric(18,4) = 0, -- min order for vol discount
	@WebSite nvarchar(2000) = 'http://', -- manuf website
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
	Declare @xml xml;
	Declare @EvntNm nvarchar(100) = N'Mfr';
	
	If Not Exists (Select * from [di].SessionMstr Where SessID = convert(uniqueidentifier,@SessID))
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

	if exists (Select 1 from [bhp].ExtractManufacturers Where (Name=@Name))
	begin
		Set @rc = 66099; -- this nbr a duplicate mfr name...
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	end
	
	If ([di].[fn_IsNull](@Lang) Is Null)
		Select @Lang = Lang from [di].SessionMstr Where SessID = convert(uniqueidentifier,@SessID);
		
	
	Insert Into [bhp].ExtractManufacturers (
		[Name]
		,[fk_VolDiscUOM]
		,[MinOrderQty]
		,[W3C]
		,[Lang]
		,[fk_Country]
	)
	Select
		[di].[fn_IsNull](@Name),
		ISNULL(@VolDiscUOMID, 0),
		ISNULL(@MinOrder, 0),
		ISNULL([di].[fn_IsNull](@WebSite),'http://'),
		ISNULL(@Lang,'en_us'),
		ISNULL(@fk_Country, 0);
	
	Set @RowID = Scope_Identity();

	If (@BCastMode = 1 And Exists (Select 1 from [di].[vw_DeploymentPublications] Where [Name]=@evntNm))
	begin
		exec [bhp].GenBurpMfrInfoMesg @mfrid=@RowID, @mfrType='extract', @evnttype='add', @SessID=@SessID, @mesg = @xml output;
		exec [bhp].[PostToBWPRouter] @inMsg=@xml, @msgNm=@EvntNm;
	end
	
	Return @@Error;
End
go

Print 'Proc:: [bhp].AddExtractManuf created...';
go

/*
** use this guid for testing...
** '00000000-0000-0000-0000-000000000000'
*/
Create Proc [bhp].DelExtractManuf (
	@SessID varchar(256),
	@RowID int, -- unique identifier of row to delete (primary key value).
	@BCastMode bit = 1
)
with encryption
as
begin
	
	Declare @rc int;
	Declare @mesg nvarchar(2000);
	Declare @xml xml;
	Declare @EvntNm nvarchar(100) = N'Mfr';
	
	If Not Exists (Select * from [di].SessionMstr Where SessID = convert(uniqueidentifier,@SessID))
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66006; -- this nbr represents users is not logged in.
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End
	
	If Exists (Select * from [bhp].ExtractMstr Where (fk_ExtractMfrID = @RowID))
	Begin
		-- should write and audit record here...someone trying use a non-monetary uom value
		Set @rc = 66091; -- this nbr represents a Extract manuf has Extracts in the system and cannot be removed.
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	If (@BCastMode = 1 And Exists (Select 1 from [di].[vw_DeploymentPublications] Where [Name]=@evntNm))
		exec [bhp].GenBurpMfrInfoMesg @mfrid=@RowID, @mfrType='extract', @evnttype='del', @SessID=@SessID, @mesg = @xml output;
	
	Delete Top (1) [bhp].ExtractManufacturers Where (RowID = @RowID);
	
	If (@BCastMode = 1 And Exists (Select 1 from [di].[vw_DeploymentPublications] Where [Name]=@evntNm))
		exec [bhp].[PostToBWPRouter] @inMsg=@xml, @msgNm=@EvntNm;
	
	Return @@Error;
	
End
go

Print 'Proc:: [bhp].DelExtractManuf created...';
go

/*
** use this guid for testing...
** '00000000-0000-0000-0000-000000000000'
*/
Create Proc [bhp].ChgExtractManuf (
	@SessID varchar(256),
	@RowID int,
	@Name nvarchar(300),
	@VolDiscUOMID int = 0,
	@MinOrder numeric(18,4) = 0,
	@WebSite nvarchar(2000) = 'http://',
	@Lang varchar(20) = 'en_us',
	@fk_Country int = 0,
	@BCastMode bit = 1
)
with encryption
as
begin
	
	Declare @rc int;
	Declare @mesg nvarchar(2000);
	Declare @xml xml;
	Declare @oldinfo Table (Name nvarchar(300));
	Declare @oldnm nvarchar(300);
	Declare @EvntNm nvarchar(100) = N'Mfr';
	
	Set @rc = 0;
	
	If (@RowID Is Null)
	Begin
		Raiserror('Parameter:[@RowID] must be provided...aborting!!!',16,1);
		Return -1;
	End
	
	If ((@RowID Is Not Null) And (Not Exists (Select * from [bhp].ExtractManufacturers Where RowID = @RowID And RowID > 0)))
	Begin
		-- should write and audit record here...someone trying to change an unknown Extract type!?
		Set @rc = 66036; -- this nbr represents an unknown Extract manuf id
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
	
	If ((@VolDiscUOMID Is Not Null) And (Not Exists (Select * from [bhp].vw_VolumnUOM Where RowID = @VolDiscUOMID)))
	Begin
		-- should write and audit record here...someone trying use a non-monetary uom value
		Set @rc = 66015; -- this nbr represents a non-volume or weight uom error.
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	if exists (Select 1 from [bhp].ExtractManufacturers Where (Name=@Name And RowID != @RowID))
	begin
		Set @rc = 66099; -- this nbr a duplicate mfr name...
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	end

	/*
	** launch the actual update now....
	*/
	Update Top (1) [bhp].ExtractManufacturers
		Set
			Name = @Name,
			fk_VolDiscUOM = ISNULL(@VolDiscUOMID,0),
			MinOrderQty = ISNULL(@MinOrder,0),
			W3C = ISNULL([di].[fn_IsNull](@WebSite),'http://'),
			Lang = ISNULL(@Lang,'en_us'),
			fk_Country = ISNULL(@fk_Country,0)
	Output Deleted.Name into @oldinfo
	Where (RowID = @RowID);
	
	If (@BCastMode = 1 And Exists (Select 1 from [di].[vw_DeploymentPublications] Where [Name]=@evntNm))if (@BCastMode = 1)
	begin
		Select @oldnm = Name from @oldinfo;

		exec [bhp].GenBurpMfrInfoMesg @mfrid=@RowID, @mfrType='extract', @evnttype='chg', @SessID=@SessID, @mesg = @xml output;
		
		set @xml.modify('
			declare namespace b="http://burp.net/recipe/evnts";
			insert attribute old {sql:variable("@oldNm")}
			into (/b:Burp_Belch/b:Payload/b:Manuf_Evnt/b:Info/b:Name)[1]
		');

		exec [bhp].[PostToBWPRouter] @inMsg=@xml, @msgNm=@EvntNm;
	end

	Return @@ERROR;
End
go

Print 'Proc:: [bhp].ChgExtractManuf created...';
go

checkpoint
go

