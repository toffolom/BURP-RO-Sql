use [BHP1-RO]
go

if Object_ID(N'[di].IsSessStale',N'P') Is Not Null
Begin
	Drop Proc [di].IsSessStale;
	Print 'Proc:: [di].IsSessStale dropped!!!';
End
Go

Create Proc [di].IsSessStale (
	@SessID varchar(256),
	@AutoClose bit = 1, -- if session is too old auto close it...(1) = 'yes'...
	@OvrMinutes int = null, -- if provided will override registered value set in environment for a stale session (in minutes)
	@Status bit output, -- (1) it's closed/stale, (0) - it's okay to use
	@Mesgs nvarchar(2000) output, -- if any messages are generated...rtrn them
	@UpdLst bit = 0 -- if we want the lastActiveOn timestamp refreshed
)
with encryption, execute as 'sticky'
as
Begin
	Set NoCount On;

	Declare @Diff int;
	Declare @MaxIdleTimeout int;
	--Declare @LstActTS datetime;
	Declare @rc int;
	Declare @xml xml;
	Declare @RowID int;

	Set @rc = 0;
	Set @xml = N'<Messages/>';

	Select @RowID = RowID From [di].SessionMstr Where (SessID = convert(uniqueidentifier, @SessID));
	
	-- make sure we have a entry in table (user is logged in).
	If (@RowID IS NULL)
	Begin
		-- should write and audit record here...a non-existant session!? WTF!!!!
		Set @rc = 66006; -- this nbr represents users is not logged in.
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesgs output;
		Set @Status = 1;
		Set @xml.modify('
insert <Item>{sql:variable("@Mesgs")}</Item>
as last into (/Messages)[1]
');
		Set @xml.modify('
insert attribute nbr {sql:variable("@rc")}
into (/Messages/Item[count(/Messages/Item)])[1]
');
		Set @Mesgs = convert(nvarchar(2000), @xml);

		Return @rc;
	End

	-- if session is zero session...then just return 'ok'...(0)...
	If (@RowID = 0)
	Begin
		Set @Status = 0;
		Set @Mesgs = N'<Messages><Item nbr=''0''>OK</Item></Messages>';
		Return 0;
	End

	-- make sure session isn't already closed!!!
	If Exists (Select * from [di].SessionMstr Where (RowID = @RowID And ClosedOn != convert(datetime, 0)))
	Begin
		-- should write and audit record here...a closed session!!!
		Set @rc = 66062; -- this nbr represents that the session used here is closed!!!
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesgs output;
		Set @Status = 1;
		Set @xml.modify('
insert <Item>{sql:variable("@Mesgs")}</Item>
as last into (/Messages)[1]
');
		Set @xml.modify('
insert attribute nbr {sql:variable("@rc")}
into (/Messages/Item[count(/Messages/Item)])[1]
');
		Set @Mesgs = convert(nvarchar(2000), @xml);
		Return @rc;
	End

	Exec [di].getEnv @VarNm=N'idle session timeout (minutes)', @VarVal = @MaxIdleTimeout output, @DfltVal='20';

	If (@OvrMinutes Is Not Null)
	Begin
		Set @MaxIdleTimeout = @OvrMinutes;
		Print 'session idle timeout overridden...';
	End

	Select Top (1) @Diff = ABS(DATEDIFF(MINUTE,ISNULL(LastActiveOn,0), getdate()))
	From [di].SessionMstr Where (RowID = @RowID);

	If (@Diff > @MaxIdleTimeout)
	Begin
		
		Exec [di].getEnv @VarNm=N'idle session timeout errno', @VarVal=@rc output, @DfltVal='66060';
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesgs output;

		Set @Status = 1;

		If (@AutoClose = 1)
		Begin
			Update [di].SessionMstr
				Set ClosedOn = getdate()
			Where (RowID = @RowID);

			Set @xml.modify('
insert <Item>Session:[{sql:variable("@SessID")}] closed due to inactivity...</Item>
as last into (/Messages)[1]
');
			Set @xml.modify('
insert attribute nbr {sql:variable("@rc")}
into (/Messages/Item[count(/Messages/Item)])[1]
');

			Set @Mesgs = convert(nvarchar(2000), @xml);
		End

	End
	Else -- everything is okay...
	Begin
		Set @Status = 0;
		Set @rc = 0;
		Set @Mesgs = N'<Messages><Item nbr=''0''>OK</Item></Messages>';

		if (@UpdLst = 1)
			Update [di].SessionMstr Set LastActiveOn = getdate() Where (RowID = @RowID);
	End

	Return ISNULL(@rc, 0);

End
Go