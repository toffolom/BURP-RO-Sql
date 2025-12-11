USE [BHP1-RO]
GO

/****** Object:  StoredProcedure [bhp].[GetGrainTypes]    Script Date: 03/15/2011 15:59:54 ******/
IF OBJECT_ID(N'[bhp].[GetGrainTypes]',N'P') IS NOT NULL
BEGIN
DROP PROCEDURE [bhp].[GetGrainTypes];
Print 'Proc:: [bhp].GetGrainTypes dropped!!!';
END
GO

/****** Object:  StoredProcedure [bhp].[AddGrainTypes]    Script Date: 03/15/2011 15:59:54 ******/
IF OBJECT_ID(N'[bhp].[AddGrainTypes]',N'P') IS NOT NULL
BEGIN
DROP PROCEDURE [bhp].[AddGrainTypes];
Print 'Proc:: [bhp].AddGrainTypes dropped!!!';
END
GO

/****** Object:  StoredProcedure [bhp].[ChgGrainTypes]    Script Date: 03/15/2011 15:59:54 ******/
IF OBJECT_ID(N'[bhp].[ChgGrainTypes]',N'P') IS NOT NULL
BEGIN
DROP PROCEDURE [bhp].[ChgGrainTypes];
Print 'Proc:: [bhp].ChgGrainTypes dropped!!!';
END
GO

/****** Object:  StoredProcedure [bhp].[ChgGrainTypes]    Script Date: 03/15/2011 15:59:54 ******/
IF OBJECT_ID(N'[bhp].[DelGrainTypes]',N'P') IS NOT NULL
BEGIN
DROP PROCEDURE [bhp].[DelGrainTypes];
Print 'Proc:: [bhp].DelGrainTypes dropped!!!';
END
GO

/*
** use this guid for testing...
** '00000000-0000-0000-0000-000000000000'
*/
create proc [bhp].GetGrainTypes (
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
		GT.RowID, 
		ISNULL(GT.Name,'not set') AS Name, 
		GT.EnteredOn, 
		GT.EnteredBy, 
		ISNULL(Lang,'en_us') As Lang
	FROM [bhp].GrainTypes AS GT 
	WHERE  (GT.RowID > 0)
	ORDER BY GT.Name;
	
	Return 0;
end
go

print 'Proc:: [bhp].GetGrainTypes created...';
go

/*
** use this guid for testing...
** '00000000-0000-0000-0000-000000000000'
*/
Create Proc [bhp].AddGrainTypes (
	@SessID varchar(256),
	@Name nvarchar(300) = Null, -- name of grain manuf
	@Lang varchar(20) = 'en_us', -- language...dflt is 'en_us'
	@BCastMode bit = 1,
	@RowID int output -- generated rowid value
)
with encryption
as
begin
	Declare @rc int;
	Declare @mesg nvarchar(2000);
	Declare @xml xml;
	Declare @SessStatus bit;
	Declare @EvntNm nvarchar(100) = N'GrainType';
	
	exec @rc = [di].IsSessStale @SessID=@SessID, @Status=@SessStatus output, @Mesgs=@Mesg output, @UpdLst=1;

	if (@rc != 0 or @SessStatus != 0)
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66006; -- this nbr represents users is not logged in.
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End
	
	Insert Into [bhp].GrainTypes (Name,Lang) 
	Select
		[di].[fn_IsNull](@Name), 
		Case When @Lang IS NULL THEN (Select Top (1) Lang from [di].SessionMstr Where SessID = convert(uniqueidentifier,@SessID)) Else @Lang End;
	
	Set @RowID = Scope_Identity();

	If (@BCastMode = 1 And Exists (Select 1 from [di].[vw_DeploymentPublications] Where [Name]=@evntNm))
	Begin
		exec @rc = [bhp].GenBurpGrainTypeMesg @id=@RowID, @evnttype='add', @SessID = @SessID, @mesg = @xml output;
		Exec [bhp].[PostToBWPRouter] @inmsg = @xml, @msgNm=@EvntNm;
	End
	
	Return @@Error;
End
go

Print 'Proc:: [bhp].AddGrainTypes created...';
go

/*
** use this guid for testing...
** '00000000-0000-0000-0000-000000000000'
*/
Create Proc [bhp].DelGrainTypes (
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
	Declare @EvntNm nvarchar(100) = N'GrainType';
	
	exec @rc = [di].IsSessStale @SessID=@SessID, @Status=@SessStatus output, @Mesgs=@Mesg output, @UpdLst=1;

	if (@rc != 0 or @SessStatus != 0)
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?s
		Set @rc = 66006; -- this nbr represents users is not logged in.
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End
	
	If Exists (Select * from [bhp].GrainMstr Where (fk_GrainType = @RowID))
	Begin
		-- should write and audit record here...someone trying use a non-monetary uom value
		Set @rc = 66027; -- this nbr represents a Grain Type is referenced within the Grain Master table....
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	If (@BCastMode = 1 And Exists (Select 1 from [di].[vw_DeploymentPublications] Where [Name]=@evntNm))
		exec @rc = [bhp].GenBurpGrainTypeMesg @id=@RowID, @evnttype='del', @SessID = @SessID, @mesg = @xml output;

	Delete Top (1) [bhp].GrainTypes Where (RowID = @RowID);
	
	If (@BCastMode = 1 And Exists (Select 1 from [di].[vw_DeploymentPublications] Where [Name]=@evntNm))
		Exec [bhp].[PostToBWPRouter] @inmsg = @xml, @msgNm=@EvntNm;
	
	Return @@Error;
	
End
go

Print 'Proc:: [bhp].DelGrainTypes created...';
go

/*
** use this guid for testing...
** '00000000-0000-0000-0000-000000000000'
*/
Create Proc [bhp].ChgGrainTypes (
	@SessID varchar(256),
	@RowID int,
	@Name nvarchar(300),
	@Lang varchar(20),
	@BCastMode bit = 1
)
with encryption
as
begin
	Declare @rc int;
	Declare @mesg nvarchar(2000);
	Declare @xml xml;
	Declare @SessStatus bit;
	Declare @oldinfo Table (Name nvarchar(300));
	Declare @oldnm nvarchar(300);
	Declare @EvntNm nvarchar(100) = N'GrainType';
	
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
	
	If ((@RowID Is Not Null) And (Not Exists (Select * from [bhp].GrainTypes Where RowID = @RowID And RowID > 0)))
	Begin
		-- should write and audit record here...someone trying to change an unknown Grain type!?
		Set @rc = 66028; -- this nbr represents an unknown Grain Type id value...
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End
		
	/*
	** launch the actual update now....
	*/
	Update [bhp].GrainTypes
		Set
			[Name] = @Name,
			[Lang] = ISNULL(@Lang,(select top (1) Lang from [di].[vw_SessionInfo] Where (SessionID=@SessID)))
	Output Deleted.[Name] into @oldinfo([Name])
	Where (RowID = @RowID);
	
	If (@BCastMode = 1 And Exists (Select 1 from [di].[vw_DeploymentPublications] Where [Name]=@evntNm))
	Begin
		Select @oldnm = [Name] From @oldinfo;

		exec @rc = [bhp].GenBurpGrainTypeMesg @id=@RowID, @evnttype='chg', @SessID = @SessID, @mesg = @xml output;

		set @xml.modify('
			declare namespace b="http://burp.net/recipe/evnts";
			insert attribute old {sql:variable("@oldnm")}
			into (/b:Burp_Belch/b:Payload/b:Grain_Evnt/b:Type_Info/b:Name)[1]
		');

		Exec [bhp].[PostToBWPRouter] @inmsg = @xml, @msgNm=@EvntNm;
	End
	
	Return @@ERROR;
End
go

Print 'Proc:: [bhp].ChgGrainTypes created...';
go

checkpoint
go

