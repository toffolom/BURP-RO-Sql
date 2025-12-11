USE [BHP1-RO]
GO

/****** Object:  StoredProcedure [bhp].[GetYeastTypes]    Script Date: 03/15/2011 15:59:54 ******/
IF OBJECT_ID(N'[bhp].[GetYeastTypes]',N'P') IS NOT NULL
BEGIN
DROP PROCEDURE [bhp].[GetYeastTypes];
Print 'Proc:: [bhp].GetYeastTypes dropped!!!';
END
GO

/****** Object:  StoredProcedure [bhp].[AddYeastType]    Script Date: 03/15/2011 15:59:54 ******/
IF OBJECT_ID(N'[bhp].[AddYeastType]',N'P') IS NOT NULL
BEGIN
DROP PROCEDURE [bhp].[AddYeastType];
Print 'Proc:: [bhp].AddYeastType dropped!!!';
END
GO

/****** Object:  StoredProcedure [bhp].[ChgYeastType]    Script Date: 03/15/2011 15:59:54 ******/
IF OBJECT_ID(N'[bhp].[ChgYeastType]',N'P') IS NOT NULL
BEGIN
DROP PROCEDURE [bhp].[ChgYeastType];
Print 'Proc:: [bhp].ChgYeastType dropped!!!';
END
GO

/****** Object:  StoredProcedure [bhp].[ChgYeastType]    Script Date: 03/15/2011 15:59:54 ******/
IF OBJECT_ID(N'[bhp].[DelYeastType]',N'P') IS NOT NULL
BEGIN
DROP PROCEDURE [bhp].[DelYeastType];
Print 'Proc:: [bhp].DelYeastType dropped!!!';
END
GO

/*
** use this guid for testing...
** '00000000-0000-0000-0000-000000000000'
*/
create proc [bhp].GetYeastTypes (
	@SessID varchar(256)
)
with encryption
as
begin
	--set nocount on;
	
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
		RowID, Name, ISNULL(Phylum,'not set') As Phylum, ISNULL(Lang,'en_us') As Lang
	FROM [bhp].YeastTypes
	WHERE  (RowID > 0)
	ORDER BY Name;
	
	Return 0;
end
go

print 'Proc:: [bhp].GetYeastTypes created...';
go

/*
** use this guid for testing...
** '00000000-0000-0000-0000-000000000000'
*/
Create Proc [bhp].AddYeastType (
	@SessID varchar(256),
	@Name nvarchar(300), -- name of grain manuf
	@Phylum nvarchar(500) = Null, -- the phylum we belong in
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
	Declare @evntNm nvarchar(100) = N'YeastType';
		
	Exec @rc = [di].[IsSessStale] @SessID=@SessID, @Status=@Status output, @Mesgs=@Mesg output, @UpdLst=1;

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
	
	Insert Into [bhp].YeastTypes(
		[Name]
		,[Phylum]
		,[Lang]
	)
	Select
		[di].[fn_IsNull](@Name),
		@Phylum,
		@Lang;
	
	Set @RowID = Scope_Identity();

	If (@BCastMode = 1 And Exists (Select 1 from [di].[vw_DeploymentPublications] Where [Name]=@evntNm))
	Begin
		exec @rc = [bhp].GenBurpYeastTypeMesg @id=@rowid, @evnttype='add', @SessID=@SessID, @mesg = @xml output;
		exec [bhp].[PostToBWPRouter] @inMsg = @xml, @msgNm=@evntNm;
	End
	
	Return @@Error;
End
go

Print 'Proc:: [bhp].AddYeastType created...';
go

/*
** use this guid for testing...
** '00000000-0000-0000-0000-000000000000'
*/
Create Proc [bhp].DelYeastType (
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
	Declare @evntNm nvarchar(100) = N'YeastType';
	
	Exec @rc = [di].[IsSessStale] @SessID=@SessID, @Status=@Status output, @Mesgs=@Mesg output, @UpdLst=1;

	If (@rc != 0 or @status != 0)
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66006; -- this nbr represents users is not logged in.
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End
	
	If Exists (Select * from [bhp].YeastMstr Where (fk_YeastType = @RowID))
	Begin
		-- should write and audit record here...someone trying use a non-monetary uom value
		Set @rc = 66039; -- this nbr represents a Yeast Type has Yeasts in the system and cannot be removed.
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End
	
	If (@BCastMode = 1 And Exists (Select 1 from [di].[vw_DeploymentPublications] Where [Name]=@evntNm))
		exec @rc = [bhp].GenBurpYeastTypeMesg @id=@rowid, @evnttype='del', @SessID=@SessID, @mesg = @xml output;
	
	Delete Top (1) [bhp].YeastTypes Where (RowID = @RowID);
	
	If (@BCastMode = 1 And Exists (Select 1 from [di].[vw_DeploymentPublications] Where [Name]=@evntNm))
		exec [bhp].[PostToBWPRouter] @inMsg = @xml, @msgNm=@evntNm;
	
	Return @@Error;
	
End
go

Print 'Proc:: [bhp].DelYeastType created...';
go

/*
** use this guid for testing...
** '00000000-0000-0000-0000-000000000000'

exec [bhp].ChgYeastType '00000000-0000-0000-0000-000000000000', 7, 'Wilder', 'Kloeckera & Candida generation -x', 'en_us'

*/
Create Proc [bhp].ChgYeastType (
	@SessID varchar(256),
	@RowID int,
	@Name nvarchar(256),
	@Phylum nvarchar(256) = Null,
	@Lang varchar(20) = 'en_us',
	@BCastMode bit = 1
)
with encryption
as
begin
	Declare @rc int;
	Declare @mesg nvarchar(2000);
	Declare @status bit;
	Declare @xml xml;
	Declare @oldinfo Table (
		[Name] nvarchar(256)
	);
	Declare @old nvarchar(256);
	Declare @evntNm nvarchar(100) = N'YeastType';
	

	Exec @rc = [di].[IsSessStale] @SessID=@SessID, @Status=@Status output, @Mesgs=@Mesg output, @UpdLst=1;

	If (@rc != 0 or @status != 0)
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
	
	If ((@RowID Is Not Null) And (Not Exists (Select * from [bhp].YeastTypes Where RowID = @RowID And RowID > 0)))
	Begin
		-- should write and audit record here...someone trying to change an unknown Yeast type!?
		Set @rc = 66040; -- this nbr represents an unknown Yeast Type id
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End
	

	
	/*
	** launch the actual update now....
	*/
	Update Top (1) [bhp].YeastTypes
		Set
			Name = ISNULL(@Name,(select top (1) Name from [bhp].YeastTypes Where (RowID=@RowID))),
			Phylum = ISNULL(@Phylum,(select top (1) Phylum from [bhp].YeastTypes Where (RowID=@RowID))),
			Lang = ISNULL(@Lang,(select top (1) Lang from [bhp].YeastTypes Where (RowID=@RowID)))
	Output Deleted.[Name] Into @oldinfo([Name])
	Where (RowID = @RowID);

	If (@BCastMode = 1 And Exists (Select 1 from [di].[vw_DeploymentPublications] Where [Name]=@evntNm))
	Begin
		Select @old = [Name] from @oldinfo;
	
		exec @rc = [bhp].GenBurpYeastTypeMesg @id=@rowid, @evnttype='chg', @SessID=@SessID, @mesg = @xml output;

		-- stuff the old name value into doc as attribute 'old'
		set @xml.modify('
			declare namespace b="http://burp.net/recipe/evnts";
			insert (
				attribute old {sql:variable("@old")}
			)
			into (/b:Burp_Belch/b:Payload/b:Yeast_Evnt/b:Type_Info/b:Name)[1]
		');

		exec [bhp].[PostToBWPRouter] @inMsg = @xml, @msgNm=@evntNm;
	End
	
	Return @@ERROR;
End
go

Print 'Proc:: [bhp].ChgYeastType created...';
go

checkpoint
go
