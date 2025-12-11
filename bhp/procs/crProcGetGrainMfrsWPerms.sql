USE [BHP1-RO]
GO

/****** Object:  StoredProcedure [bhp].[GetGrainManufs]    Script Date: 03/15/2011 15:59:54 ******/
IF OBJECT_ID(N'[bhp].[GetGrainManufs]',N'P') IS NOT NULL
BEGIN
DROP PROCEDURE [bhp].[GetGrainManufs];
Print 'Proc:: [bhp].GetGrainManufs dropped!!!';
END
GO

/****** Object:  StoredProcedure [bhp].[AddGrainManuf]    Script Date: 03/15/2011 15:59:54 ******/
IF OBJECT_ID(N'[bhp].[AddGrainManuf]',N'P') IS NOT NULL
BEGIN
DROP PROCEDURE [bhp].[AddGrainManuf];
Print 'Proc:: [bhp].AddGrainManuf dropped!!!';
END
GO

/****** Object:  StoredProcedure [bhp].[ChgGrainManuf]    Script Date: 03/15/2011 15:59:54 ******/
IF OBJECT_ID(N'[bhp].[ChgGrainManuf]',N'P') IS NOT NULL
BEGIN
DROP PROCEDURE [bhp].[ChgGrainManuf];
Print 'Proc:: [bhp].ChgGrainManuf dropped!!!';
END
GO

/****** Object:  StoredProcedure [bhp].[ChgGrainManuf]    Script Date: 03/15/2011 15:59:54 ******/
IF OBJECT_ID(N'[bhp].[DelGrainManuf]',N'P') IS NOT NULL
BEGIN
DROP PROCEDURE [bhp].[DelGrainManuf];
Print 'Proc:: [bhp].DelGrainManuf dropped!!!';
END
GO

/*
** use this guid for testing...
** '00000000-0000-0000-0000-000000000000'
*/
create proc [bhp].GetGrainManufs (
	@SessID varchar(256)
)
with encryption
as
begin
	
	Declare @rc int;
	Declare @mesg nvarchar(2000);
	Declare @SessStatus bit;
	
	exec @rc = [di].IsSessStale @SessID=@SessID, @Status=@SessStatus output, @Mesgs=@Mesg output, @UpdLst=1;

	if (@rc != 0 or @SessStatus != 0)
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66006; -- this nbr represents users is not logged in.
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End
	
	SELECT 
		GM.RowID, 
		GM.Name, 
		ISNULL(GM.fk_VolDiscUOM,0) As fk_VolDiscUOM,
		ISNULL(GM.MinOrderQty,0) As MinOrderQty,
		GM.W3C, 
		GM.EnteredOn, 
		GM.EnteredBy, 
		N'en_us' As Lang,
		GM.fk_Country,
		C.Name as CountryName
	FROM [bhp].GrainManufacturers AS GM
	Inner Join [di].Countries C On (GM.fk_Country = C.RowID)
	--WHERE  (GM.RowID > 0)
	ORDER BY GM.Name;
	
	Return 0;
end
go

print 'Proc:: [bhp].GetGrainManufs created...';
go

/*
** use this guid for testing...
** '00000000-0000-0000-0000-000000000000'
*/
Create Proc [bhp].AddGrainManuf (
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
	Declare @SessStatus bit;
	Declare @EvntNm nvarchar(100) = N'Mfr';
	
	exec @rc = [di].IsSessStale @SessID=@SessID, @Status=@SessStatus output, @Mesgs=@Mesg output, @UpdLst=1;

	if (@rc != 0 or @SessStatus != 0)
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

	if exists (Select 1 from [bhp].GrainManufacturers Where (Name=@Name))
	begin
		Set @rc = 66099; -- this nbr a duplicate grain mfr name
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	end
	
	If ([di].[fn_IsNull](@Lang) Is Null)
		Select @Lang = Lang from [di].SessionMstr Where SessID = convert(uniqueidentifier,@SessID);
		
	Insert Into [bhp].GrainManufacturers (
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
		exec [bhp].GenBurpMfrInfoMesg @mfrid=@RowID, @mfrType='grain', @evnttype='add', @SessID=@SessID, @mesg = @xml output;
		Exec [bhp].[PostToBWPRouter] @inmsg = @xml, @msgNm=@EvntNm;
	end
	
	Return @@Error;
End
go

Print 'Proc:: [bhp].AddGrainManuf created...';
go

/*
** use this guid for testing...
** '00000000-0000-0000-0000-000000000000'
*/
Create Proc [bhp].DelGrainManuf (
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
	Declare @SessStatus bit;
	Declare @EvntNm nvarchar(100) = N'Mfr';
	
	exec @rc = [di].IsSessStale @SessID=@SessID, @Status=@SessStatus output, @Mesgs=@Mesg output, @UpdLst=1;

	if (@rc != 0 or @SessStatus != 0)
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66006; -- this nbr represents users is not logged in.
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End
	
	If Exists (Select * from [bhp].GrainMstr Where (fk_GrainMfr = @RowID))
	Begin
		-- should write and audit record here...someone trying use a non-monetary uom value
		Set @rc = 66025; -- this nbr represents a Grain manuf has Grains in the system and cannot be removed.
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End
	
	If (@BCastMode = 1 And Exists (Select 1 from [di].[vw_DeploymentPublications] Where [Name]=@evntNm))
		exec [bhp].GenBurpMfrInfoMesg @mfrid=@RowID, @mfrType='grain', @evnttype='del', @SessID=@SessID, @mesg = @xml output;
	
	Delete Top (1) [bhp].GrainManufacturers Where (RowID = @RowID);
	
	If (@BCastMode = 1 And Exists (Select 1 from [di].[vw_DeploymentPublications] Where [Name]=@evntNm))
		Exec [bhp].[PostToBWPRouter] @inmsg = @xml, @msgNm=@EvntNm;
	
	Return @@Error;
	
End
go

Print 'Proc:: [bhp].DelGrainManuf created...';
go

/*
** use this guid for testing...
** '00000000-0000-0000-0000-000000000000'
*/
Create Proc [bhp].ChgGrainManuf (
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
	Declare @SessStatus bit;
	Declare @EvntNm nvarchar(100) = N'Mfr';
	
	exec @rc = [di].IsSessStale @SessID=@SessID, @Status=@SessStatus output, @Mesgs=@Mesg output, @UpdLst=1;

	if (@rc != 0 or @SessStatus != 0)
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66006; -- this nbr represents users is not logged in.
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	If (@RowID Is Null)
	Begin
		Raiserror('Parameter:[@RowID] must be provided...aborting!!!',16,1);
		Return -1;
	End
	
	If ((@RowID Is Not Null) And (Not Exists (Select * from [bhp].GrainManufacturers Where RowID = @RowID And RowID > 0)))
	Begin
		-- should write and audit record here...someone trying to change an unknown Grain type!?
		Set @rc = 66026; -- this nbr represents an unknown Grain manuf id
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

	if exists (Select 1 from [bhp].GrainManufacturers Where (Name=@Name And RowID != @Rowid))
	begin
		Set @rc = 66099; -- this nbr a duplicate grain mfr name
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	end

	/*
	** launch the actual update now....
	*/
	Update Top (1) [bhp].GrainManufacturers
		Set
			Name = @Name,
			fk_VolDiscUOM = ISNULL(@VolDiscUOMID,0),
			MinOrderQty = ISNULL(@MinOrder,0),
			W3C = ISNULL(@WebSite,'http://'),
			Lang = ISNULL(@Lang,'en_us'),
			fk_Country = ISNULL(@fk_Country,0)
	Output Deleted.Name into @oldinfo([Name])
	Where (RowID = @RowID);

	If (@BCastMode = 1 And Exists (Select 1 from [di].[vw_DeploymentPublications] Where [Name]=@evntNm))
	begin
		exec [bhp].GenBurpMfrInfoMesg @mfrid=@RowID, @mfrType='grain', @evnttype='chg', @SessID=@SessID, @mesg = @xml output;
		
		Select @oldnm = [Name] from @oldinfo;
		
		set @xml.modify('
			declare namespace b="http://burp.net/recipe/evnts";
			insert attribute old {sql:variable("@oldnm")}
			into (/b:Burp_Belch/b:Payload/b:Manuf_Evnt/b:Info/b:Name)[1]
		');

		Exec [bhp].[PostToBWPRouter] @inmsg = @xml, @msgNm=@EvntNm;
	end
	
	Return @@ERROR;
End
go

Print 'Proc:: [bhp].ChgGrainManuf created...';
go

checkpoint
go