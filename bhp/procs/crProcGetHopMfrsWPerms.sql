USE [BHP1-RO]
GO

/****** Object:  StoredProcedure [bhp].[GetHopManufs]    Script Date: 03/15/2011 15:59:54 ******/
IF OBJECT_ID(N'[bhp].[GetHopManufs]',N'P') IS NOT NULL
BEGIN
DROP PROCEDURE [bhp].[GetHopManufs];
Print 'Proc:: [bhp].GetHopManufs dropped!!!';
END
GO

/****** Object:  StoredProcedure [bhp].[AddHopManuf]    Script Date: 03/15/2011 15:59:54 ******/
IF OBJECT_ID(N'[bhp].[AddHopManuf]',N'P') IS NOT NULL
BEGIN
DROP PROCEDURE [bhp].[AddHopManuf];
Print 'Proc:: [bhp].AddHopManuf dropped!!!';
END
GO

/****** Object:  StoredProcedure [bhp].[ChgHopManuf]    Script Date: 03/15/2011 15:59:54 ******/
IF OBJECT_ID(N'[bhp].[ChgHopManuf]',N'P') IS NOT NULL
BEGIN
DROP PROCEDURE [bhp].[ChgHopManuf];
Print 'Proc:: [bhp].ChgHopManuf dropped!!!';
END
GO

/****** Object:  StoredProcedure [bhp].[ChgHopManuf]    Script Date: 03/15/2011 15:59:54 ******/
IF OBJECT_ID(N'[bhp].[DelHopManuf]',N'P') IS NOT NULL
BEGIN
DROP PROCEDURE [bhp].[DelHopManuf];
Print 'Proc:: [bhp].DelHopManuf dropped!!!';
END
GO

/*
** use this guid for testing...
** '00000000-0000-0000-0000-000000000000'
*/
create proc [bhp].GetHopManufs (
	@SessID varchar(256)
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
	
	SELECT 
		HM.RowID, 
		HM.Name,
		ISNULL(HM.fk_VolDiscUOM, 0) As fk_VolDiscUOM, 
		UOMDescr,
		convert(numeric(18,4), ISNULL(HM.MinOrderQty,0.0)) As MinOrderQty,
		HM.W3C, 
		HM.EnteredOn, 
		HM.EnteredBy, 
		HM.Lang,
		HM.fk_Country,
		C.Name As CountryName
	FROM [bhp].HopManufacturers AS HM
	Inner Join [di].Countries C On (HM.fk_Country = C.RowID)
	--WHERE  (HM.RowID > 0)
	ORDER BY HM.Name;
	
	Return 0;
end
go

print 'Proc:: [bhp].GetHopManufs created...';
go

/*
** use this guid for testing...
** '00000000-0000-0000-0000-000000000000'
*/
Create Proc [bhp].AddHopManuf (
	@SessID varchar(256),
	@Name nvarchar(300),
	@VolDiscUOMID int = 0,
	@MinOrder numeric(18,4) = 0,
	@WebSite nvarchar(2000) = 'http://',
	@Lang varchar(20) = 'en_us',
	@fk_Country int = 0,
	@RowID int output,
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

	if exists (Select 1 from [bhp].HopManufacturers Where (Name=@Name))
	begin
		Set @rc = 66099; -- this nbr a duplicate mfr name...
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	end
	
	If ([di].[fn_IsNull](@Lang) Is Null)
		Select @Lang = Lang from [di].SessionMstr Where SessID = convert(uniqueidentifier,@SessID);
	
	Insert Into [bhp].HopManufacturers (
		[Name]
		,[fk_VolDiscUOM]
		,[MinOrderQty]
		,[W3C]
		,[Lang]
		,[fk_Country]
	)
	Select
		[di].[fn_IsNull](@Name),
		ISNULL(@VolDiscUOMID,0),
		ISNULL(@MinOrder,0),
		ISNULL([di].[fn_IsNull](@WebSite),'http://'),
		ISNULL(@Lang,'en_us'),
		ISNULL(@fk_Country, 0);
	
	Set @RowID = Scope_Identity();

	If (@BCastMode = 1 And Exists (Select 1 from [di].[vw_DeploymentPublications] Where [Name]=@evntNm))
	begin
		exec [bhp].GenBurpMfrInfoMesg @mfrid=@RowID, @mfrType='hop', @evnttype='add', @SessID=@SessID, @mesg = @xml output;
		exec [bhp].[PostToBWPRouter] @inMsg=@xml, @MsgNm=@EvntNm;
	end
	
	Return @@Error;
End
go

Print 'Proc:: [bhp].AddHopManuf created...';
go

/*
** use this guid for testing...
** '00000000-0000-0000-0000-000000000000'
*/
Create Proc [bhp].DelHopManuf (
	@SessID varchar(256),
	@RowID int,
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
	
	If Exists (Select * from [bhp].HopTypesV2 Where (fk_HopMfrID = @RowID))
	Begin
		-- should write and audit record here...someone trying use a non-monetary uom value
		Set @rc = 66017; -- this nbr represents a hop manuf has hops in the system and cannot be removed.
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End
	
	If (@BCastMode = 1 And Exists (Select 1 from [di].[vw_DeploymentPublications] Where [Name]=@evntNm))
		exec [bhp].GenBurpMfrInfoMesg @mfrid=@RowID, @mfrType='hop', @evnttype='del', @SessID=@SessID, @mesg = @xml output;
	
	Delete Top (1) [bhp].HopManufacturers Where (RowID = @RowID);

	If (@BCastMode = 1 And Exists (Select 1 from [di].[vw_DeploymentPublications] Where [Name]=@evntNm))
		exec [bhp].[PostToBWPRouter] @inMsg=@xml, @MsgNm=@EvntNm;
	
	Return @@Error;
	
End
go

Print 'Proc:: [bhp].DelHopManuf created...';
go

/*
** use this guid for testing...
** '00000000-0000-0000-0000-000000000000'
*/
Create Proc [bhp].ChgHopManuf (
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
	
	If ((@RowID Is Not Null) And (Not Exists (Select * from [bhp].HopManufacturers Where RowID = @RowID And RowID > 0)))
	Begin
		-- should write and audit record here...someone trying to change an unknown hop type!?
		Set @rc = 66013; -- this nbr represents an uknown hop manuf id
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

	if exists (Select 1 from [bhp].HopManufacturers Where (Name=@Name And RowID != @RowID))
	begin
		Set @rc = 66099; -- this nbr a duplicate mfr name...
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	end

	Update Top (1) [bhp].HopManufacturers
		Set
			Name = @Name,
			fk_VolDiscUOM = ISNULL(@VolDiscUOMID,0),
			MinOrderQty = ISNULL(@MinOrder,0),
			W3C = ISNULL(@WebSite,'http://'),
			Lang = ISNULL(@Lang,'en_us'),
			fk_Country = ISNULL(@fk_Country, 0)
	Output Deleted.Name into @OldInfo(Name)
	Where (RowID = @RowID);
	
	If (@BCastMode = 1 And Exists (Select 1 from [di].[vw_DeploymentPublications] Where [Name]=@evntNm))
	begin
		exec [bhp].GenBurpMfrInfoMesg @mfrid=@RowID, @mfrType='hop', @evnttype='chg', @SessID=@SessID, @mesg = @xml output;
		
		select @oldnm = Name from @oldinfo;

		set @xml.modify('
			declare namespace b="http://burp.net/recipe/evnts";
			insert attribute old {sql:variable("@oldNm")}
			into (/b:Burp_Belch/b:Payload/b:Manuf_Evnt/b:Info/b:Name)[1]
		');
		
		exec [bhp].[PostToBWPRouter] @inMsg=@xml, @MsgNm=@EvntNm;
	end

	Return @rc;
End
go

Print 'Proc:: [bhp].ChgHopManuf created...';
go

checkpoint
go