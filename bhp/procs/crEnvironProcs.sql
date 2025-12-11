use [BHP1-RO]
go

begin try
	drop proc [bhp].GetEnvironment;
	print 'proc:: [bhp].GetEnvironment dropped!!!';
end try
begin catch
	print 'proc:: [bhp].GetEnvironment doesn''t exist...no prob!!!';
end catch
go


begin try
	drop proc [bhp].AddEnvironment;
	print 'proc:: [bhp].AddEnvironment dropped!!!';
end try
begin catch
	print 'proc:: [bhp].AddEnvironment doesn''t exist...no prob!!!';
end catch
go

begin try
	drop proc [bhp].ChgEnvironment;
	print 'proc:: [bhp].ChgEnvironment dropped!!!';
end try
begin catch
	print 'proc:: [bhp].ChgEnvironment doesn''t exist...no prob!!!';
end catch
go

begin try
	drop proc [bhp].DelEnvironment;
	print 'proc:: [bhp].DelEnvironment dropped!!!';
end try
begin catch
	print 'proc:: [bhp].DelEnvironment doesn''t exist...no prob!!!';
end catch
go

Create Proc [bhp].GetEnvironment (
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

	Select RowID, VarNm, ISNULL(VarVal,'') As VarVal, ISNULL(Notes,N'<Notes><Note nbr=''0''>no notes given...</Note></Notes>') As Notes
	From [di].Environment;

	Return @@ERROR;
end
go

Create Proc [bhp].AddEnvironment (
	@SessID varchar(256),
	@VarNm nvarchar(200),
	@VarVal nvarchar(1000),
	@Notes nvarchar(4000) = N'no comments given...',
	@NuRowID int output
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

	Insert into [di].Environment (VarNm, VarVal, Notes)
	Select @VarNm, ISNULL(@VarVal,'') As VarVal, ISNULL(@Notes,N'<Notes><Note nbr=''0''>no notes given...</Note></Notes>');

	Set @NuRowID = SCOPE_IDENTITY();
	return @@ERROR;
end
go

Create Proc [bhp].ChgEnvironment (
	@SessID varchar(256),
	@RowID int,
	@VarVal nvarchar(4000),
	@Note nvarchar(1000) = N'no comments given...'
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

	Update [di].Environment
		Set VarVal = @VarVal, Notes = ISNULL(@Note, Notes)
	Where (RowID = @RowID);

	Return @@ERROR;
end
go

Create Proc [bhp].DelEnvironment (
	@SessID varchar(256),
	@RowID int
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
	
	Delete Top (1) [di].Environment Where (RowID = @RowID);

	Return @@ERROR;
end
go