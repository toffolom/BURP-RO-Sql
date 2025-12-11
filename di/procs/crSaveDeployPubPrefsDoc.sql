use [BHP1-RO]
go

if object_id(N'[di].[SavePublicationPrefsDoc]',N'P') is not null
begin
	Drop Proc [di].[SavePublicationPrefsDoc];
	print 'Proc:: di.SavePublicationPrefsDoc dropped!!!';
end
go

if object_id(N'[di].[GetDeploymentPublicationPrefs]',N'P') is not null
begin
	Drop Proc [di].[GetDeploymentPublicationPrefs];
	print 'Proc:: di.GetDeploymentPublicationPrefs dropped!!!';
end
go

if object_id(N'[di].[SetDeploymentPublicationPref]',N'P') is not null
begin
	Drop Proc [di].[SetDeploymentPublicationPref];
	print 'Proc:: di.SetDeploymentPublicationPref dropped!!!';
end
go

/* this is the xml doc we're writting into table di.DeploymentPublications
<?xml version="1.0" encoding="utf-16"?>
<b:Deployment_PubPrefs ver="1.0" ts="2021-01-04 15:50:29" did="3b126d15-8799-48d7-863f-5c552855ab45" name="Smeltania" xmlns:b="http://burp.net/deployment/pub/prefs/evnts">
  <b:Payload uid="075df7d3-073c-4e59-a2fc-a391b4d5d383">
    <b:Preferences>
      <b:Setting send="false">AgingSched</b:Setting>
      <b:Setting send="false">MashSched</b:Setting>
      <b:Setting send="false">HopSched</b:Setting>
      <b:Setting send="true">AHAStyle</b:Setting>
      <b:Setting send="true">HopTimerStage</b:Setting>
      <b:Setting send="true">TagWord</b:Setting>
      <b:Setting send="true">Color</b:Setting>
      <b:Setting send="true">Country</b:Setting>
      <b:Setting send="true">Env</b:Setting>
      <b:Setting send="true">Mfr</b:Setting>
      <b:Setting send="true">Extract</b:Setting>
      <b:Setting send="true">Grain</b:Setting>
      <b:Setting send="true">GrainType</b:Setting>
      <b:Setting send="true">Hop</b:Setting>
      <b:Setting send="true">HopPurpose</b:Setting>
      <b:Setting send="true">Yeast</b:Setting>
      <b:Setting send="true">YeastType</b:Setting>
      <b:Setting send="true">Package</b:Setting>
      <b:Setting send="true">Flocculation</b:Setting>
      <b:Setting send="true">Ingredient</b:Setting>
      <b:Setting send="true">WtrProfile</b:Setting>
      <b:Setting send="true">GCWord</b:Setting>
      <b:Setting send="true">UOM</b:Setting>
      <b:Setting send="true">Stage</b:Setting>
      <b:Setting send="true">Sparge</b:Setting>
      <b:Setting send="true">Lang</b:Setting>
      <b:Setting send="true">MashType</b:Setting>
    </b:Preferences>
  </b:Payload>
</b:Deployment_PubPrefs>

*/

create proc di.[GetDeploymentPublicationPrefs] (
	@SessID varchar(256)
)
with encryption
as
begin
	Declare @rc int;
	Declare @mesg nvarchar(2000);
	Declare @status bit;
	Declare @xdoc xml;

	Exec @rc = [di].[IsSessStale] @SessID=@SessID, @Status=@Status output, @Mesgs=@Mesg output, @UpdLst=1;

	If (@rc != 0 or @status != 0)
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66006; -- this nbr represents users is not logged in.
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	Select * from di.vw_DeploymentPublications Order By [Name];

	Return @@ERROR;
end
go

Create Proc di.SetDeploymentPublicationPref (
	@SessID varchar(256),
	@PrefName varchar(200),
	@Enabled bit,
	@ValidTill datetime = null,
	@Force bit = 0
)
with encryption
as
begin
Declare @rc int;
	Declare @mesg nvarchar(2000);
	Declare @status bit;
	Declare @xdoc xml;

	Exec @rc = [di].[IsSessStale] @SessID=@SessID, @Status=@Status output, @Mesgs=@Mesg output, @UpdLst=1;

	If (@rc != 0 or @status != 0)
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66006; -- this nbr represents users is not logged in.
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	If (@Enabled = 0)
	Begin
		Delete [di].[DeploymentPublications] Where (PrefName = @PrefName);
	End
	Else
	Begin
		If (@Force = 1)
		Begin
			Delete [di].[DeploymentPublications] Where (PrefName = @PrefName);
		End

		If Not Exists (Select 1 from [di].[DeploymentPublications] Where PrefName=@PrefName)
		Begin
			Insert into [di].[DeploymentPublications] (Fk_PrefMstrID, ValidFrom, ValidTill)
			Select RowID, GETDATE(), ISNULL(@ValidTill,DATEADD(YEAR,1000,GETDATE()))
			From [di].[DeploymentPrefsMstr] Where Name=@PrefName;
		End
	End

	Return @@ERROR;
end
go

Create proc di.SavePublicationPrefsDoc (
	@SessID varchar(256),
	@doc nvarchar(max), -- the xml doc created by client
	@CleanOutPending bit = 0  -- if you want to remove any pending publication(s) that are now no longer valid to publish if have change preference setting.
)
with encryption, execute as 'sticky'
as
begin
	Declare @rc int;
	Declare @mesg nvarchar(2000);
	Declare @status bit;
	Declare @xdoc xml;
	Declare @Old Table ([PrefID] smallint);

	Exec @rc = [di].[IsSessStale] @SessID=@SessID, @Status=@Status output, @Mesgs=@Mesg output, @UpdLst=1;

	If (@rc != 0 or @status != 0)
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66006; -- this nbr represents users is not logged in.
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	Set @xdoc = convert(xml, @doc);

	Delete [di].[DeploymentPublications]
	Output deleted.Fk_PrefMstrID Into @Old;

	-- now add in latest preferences from the doc just received...only load nodes with 'allowed=true'!!!
	with xmlnamespaces('http://burp.net/deployment/pub/prefs/evnts' as b, default 'http://burp.net/deployment/pub/prefs/evnts')
	insert into di.DeploymentPublications(Fk_PrefMstrID,SendChgOp)
	select 
		M.RowID,
		ISNULL(D.P.value('(@changes)[1]','bit'),0)
	from @xdoc.nodes('(/b:Deployment_PubPrefs/b:Payload/b:Preferences/b:Setting)') As D(P)
	inner join di.DeploymentPrefsMstr M On (M.[Name] = D.p.value('(.)[1]','varchar(200)'))
	where D.p.value('(@send)[1]','bit') = 1 Or D.P.value('(@manditory)[1]','bit') = 1;

	Set @rc = @@ERROR;

	/*
	** Remove any publications that have not been published/collected by the HUB yet.
	** That is, rm rows that we're written to the publication log before this publication
	** setting change, and those recs where valid publications, but might not be NOW,
	** because of a setting change.
	*/
	If (@CleanOutPending = 1)
	Begin
		
		Delete bwp.BWP_Cli_Log
		From bwp.BWP_Cli_Log L
		Inner Join 
		( -- get any prefs removed from latest pref setting update...then remove from pending log!!!
			Select Distinct [PrefID] 
			From @Old 
			Where PrefID Not In (Select Fk_PrefMstrID From di.DeploymentPublications WHere Fk_PrefMstrID > 0)
		) As XX
		On (L.Fk_Type = XX.PrefID)
		Where (L.Fk_Type > 0);

		Set @rc = @@ERROR;

	End

	Return @rc;
end
go

/*
declare @x nvarchar(max) = N'<?xml version="1.0" encoding="utf-16"?>
<b:Deployment_PubPrefs ver="1.0" ts="2022-03-28 08:56:02" did="3b126d15-8799-48d7-863f-5c552855ab45" name="Smeltania Brewing Comp." xmlns:b="http://burp.net/deployment/pub/prefs/evnts">
  <b:Payload uid="67d3715b-07ae-418a-89f4-6d0c52f0bb13">
    <b:Preferences>
      <b:Setting send="false" entry_type="SEGMENT">AgingSched</b:Setting>
      <b:Setting send="false" entry_type="SEGMENT">MashSched</b:Setting>
      <b:Setting send="false" entry_type="SEGMENT">HopSched</b:Setting>
      <b:Setting send="true" changes="true" entry_type="ELEMENT">AHAStyle</b:Setting>
      <b:Setting send="true" entry_type="ELEMENT">HopTimerStage</b:Setting>
      <b:Setting send="true" changes="true" entry_type="ELEMENT">TagWord</b:Setting>
      <b:Setting send="true" entry_type="ELEMENT">Color</b:Setting>
      <b:Setting send="true" entry_type="ELEMENT">Country</b:Setting>
      <b:Setting send="false" entry_type="ELEMENT" manditory="true">Env</b:Setting>
      <b:Setting send="true" entry_type="ELEMENT">Mfr</b:Setting>
      <b:Setting send="false" entry_type="ELEMENT">Extract</b:Setting>
      <b:Setting send="false" entry_type="ELEMENT">Grain</b:Setting>
      <b:Setting send="false" entry_type="ELEMENT">GrainType</b:Setting>
      <b:Setting send="false" entry_type="ELEMENT">Hop</b:Setting>
      <b:Setting send="false" entry_type="ELEMENT">HopPurpose</b:Setting>
      <b:Setting send="false" entry_type="ELEMENT">Yeast</b:Setting>
      <b:Setting send="false" entry_type="ELEMENT">YeastType</b:Setting>
      <b:Setting send="false" entry_type="ELEMENT">Package</b:Setting>
      <b:Setting send="false" entry_type="ELEMENT">Flocculation</b:Setting>
      <b:Setting send="false" entry_type="ELEMENT">Ingredient</b:Setting>
      <b:Setting send="false" entry_type="ELEMENT">WtrProfile</b:Setting>
      <b:Setting send="false" entry_type="ELEMENT" manditory="true">GCWord</b:Setting>
      <b:Setting send="true" entry_type="ELEMENT">UOM</b:Setting>
      <b:Setting send="true" entry_type="ELEMENT">Stage</b:Setting>
      <b:Setting send="false" entry_type="ELEMENT">Sparge</b:Setting>
      <b:Setting send="false" entry_type="ELEMENT" manditory="true">Lang</b:Setting>
      <b:Setting send="false" entry_type="ELEMENT">MashType</b:Setting>
      <b:Setting send="false" entry_type="SEGMENT">CustmerRecipe</b:Setting>
      <b:Setting send="false" entry_type="SEGMENT">RecipeAdjunct</b:Setting>
      <b:Setting send="false" entry_type="SEGMENT">RecipeGrains</b:Setting>
      <b:Setting send="false" entry_type="SEGMENT">RecipeHops</b:Setting>
      <b:Setting send="false" entry_type="SEGMENT">RecipeTargets</b:Setting>
      <b:Setting send="false" entry_type="SEGMENT">RecipeWater</b:Setting>
      <b:Setting send="false" entry_type="SEGMENT">RecipeYeast</b:Setting>
    </b:Preferences>
  </b:Payload>
</b:Deployment_PubPrefs>
';

Exec [BHP1-RO].[di].[SavePublicationPrefsDoc] @SessID='00000000-0000-0000-0000-000000000000',@doc=@x;
select * from [di].[vw_DeploymentPublications] order by [Name];
go

*/