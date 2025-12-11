USE	 [BHP1-RO]
go
if object_id('[bwp].[GetPublicationMesgs]',N'P') is not null
begin
	drop proc [bwp].[GetPublicationMesgs];
	print 'proc:: [bwp].[GetPublicationMesgs] dropped!!!';
end
go

Create proc [bwp].[GetPublicationMesgs] (
	@maxMsgs int = 0,
	@recipient nvarchar(100) = 'router',
	@incUnDefs bit = 0, -- set to '1' to include fk_Type=0 entries (undefined).
	@peek bit = 0 -- set this to (1) if you only want to see what is pending...no updating of PickedOn!!!
)
with encryption, execute as 'bwp-cli'
as
begin
	Declare @undefs smallint = 0
	Declare @Tbl Table(
		Msg_Type_Name nvarchar(100),
		SendTo nvarchar(100),
		Msg nvarchar(max),
		EnteredOn Datetime not null
	);

	If (1=0) -- being called w/fmt-only set 'on'.
	Begin

		Select 
			Cast(Null As UniqueIdentifier) As DeploymentID, 
			Cast(Null As nvarchar(100)) As Msg_Type_Name, 
			Cast(Null As nvarchar(100)) As SendTo, 
			Cast(Null As Datetime) As EnteredOn, 
			Cast(Null As nvarchar(max)) As Msg;

		Set FMTONLY OFF;
		Return 0;
	End

	Set @undefs = ISNULL(@undefs,0);
	If @incUnDefs = 1
		Set @undefs = -1;

	if (ISNULL(@MaxMsgs,0) <= 0)
	begin
		If (@peek = 1)
		Begin
			Insert into @Tbl(Msg,Msg_Type_Name,SendTo,EnteredOn)
			Select 
				LL.Mesg, LL.TypeName, LL.SendTo, LL.EnteredOn
			From [bwp].[BWP_Cli_Log] LL
			Where LL.SendTo = ISNULL(di.fn_IsNull(@recipient),'router')
			And LL.PickedOn IS NULL 
			And LL.Fk_Type > @undefs;
		End
		Else
		Begin
			Update [bwp].[BWP_Cli_Log]
				Set PickedOn = GETDATE()
			Output Inserted.Mesg, M.Name, inserted.SendTo, inserted.EnteredOn
			Into @Tbl(Msg,Msg_Type_Name,SendTo,EnteredOn)
			From (
				select Top 100 Percent RowID 
				from [bwp].[BWP_Cli_Log]
				where PickedOn IS NULL And Fk_Type > @undefs
				order by EnteredOn
			) As L
			Inner Join [bwp].[BWP_Cli_Log] LL On (LL.RowID = L.RowID)
			Inner Join [di].[DeploymentPrefsMstr] M On (LL.Fk_Type = M.RowID)
			Where LL.SendTo = ISNULL(di.fn_IsNull(@recipient),'router');
		End
	end
	else
	begin
		If (@peek = 1)
		Begin
			Insert into @Tbl(Msg,Msg_Type_Name,SendTo,EnteredOn)
			Select Top (@maxMsgs)
				LL.Mesg, LL.TypeName, LL.SendTo, LL.EnteredOn
			From [bwp].[BWP_Cli_Log] LL
			Where LL.SendTo = ISNULL(di.fn_IsNull(@recipient),'router')
			And LL.PickedOn IS NULL 
			And LL.Fk_Type > @undefs
			Order By LL.EnteredOn;
		End
		Else
		Begin
			Update [bwp].[BWP_Cli_Log]
				Set PickedOn = GETDATE()
			Output Inserted.Mesg, M.Name, inserted.SendTo, inserted.EnteredOn
			Into @Tbl(Msg,Msg_Type_Name,SendTo,EnteredOn)
			From (
				select Top (@maxMsgs) RowID 
				from [bwp].[BWP_Cli_Log] 
				where PickedOn IS NULL And Fk_Type > @undefs
				order by EnteredOn
			) As L
			Inner Join [bwp].[BWP_Cli_Log] LL On (LL.RowID = L.RowID)
			Inner Join [di].[DeploymentPrefsMstr] M On (LL.Fk_Type = M.RowID)
			Where LL.SendTo = ISNULL(di.fn_IsNull(@recipient),'router');
		End
	end

	Select XX.DeploymentID, Msg_Type_Name, SendTo, EnteredOn, Msg
	From @Tbl
	Cross Apply (
		Select DeploymentID from di.Deployments Where RowID = 0
	) As XX
	Order By EnteredOn;

	Return @@Error;
End
go

--grant execute on bwp.[GetPublicationMesgs] to [bwp-cli];
--go

checkpoint
go
