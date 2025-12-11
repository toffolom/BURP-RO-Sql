use [BHP1-RO]
go

if object_id(N'di.SaveSubscriptionPrefsDoc',N'P') is not null
begin
	Drop Proc di.SaveSubscriptionPrefsDoc;
	Print 'proc:: di.SaveSubscriptionPrefsDoc dropped!!!';
end
go

/*
** recv the xml doc and shred it up and write into table di.DeploymentSubscriptions
** to do this we join into the di.DeploymentPrefsMstr tbl and we ONLY write into
** di.DeploymentSubscriptions items from the xml doc that are marked 'allowed=true'.
** NOTE: the node <Setting> text value is matched into di.DeploymentPrefsMstr!!!
** 
** Here is doc we're processing...
<?xml version="1.0" encoding="utf-16"?>
<b:Deployment_SubPrefs ver="1.0" ts="2022-03-30 17:06:19" did="3b126d15-8799-48d7-863f-5c552855ab45" name="Smeltania Brewing Comp." xmlns:b="http://burp.net/deployment/subscription/evnts">
  <b:Payload uid="cf18e19e-26d1-400c-ad08-12ca6a950bff">
    <b:Preferences>
      <b:Setting allowed="false" entry_type="ELEMENT">AgingSched</b:Setting>
      <b:Setting allowed="false" entry_type="ELEMENT">MashSched</b:Setting>
      <b:Setting allowed="false" entry_type="ELEMENT">HopSched</b:Setting>
      <b:Setting allowed="false" changes="true" entry_type="ELEMENT">AHAStyle</b:Setting>
      <b:Setting allowed="true" entry_type="ELEMENT">HopTimerStage</b:Setting>
      <b:Setting allowed="false" changes="true" entry_type="ELEMENT">TagWord</b:Setting>
      <b:Setting allowed="false" changes="true" entry_type="ELEMENT">Color</b:Setting>
      <b:Setting allowed="false" changes="true" entry_type="ELEMENT">Country</b:Setting>
      <b:Setting allowed="true" changes="true" entry_type="ELEMENT" manditory="true">Env</b:Setting>
      <b:Setting allowed="false" changes="true" entry_type="ELEMENT">Mfr</b:Setting>
      <b:Setting allowed="false" changes="true" entry_type="ELEMENT">Extract</b:Setting>
      <b:Setting allowed="false" changes="true" entry_type="ELEMENT">Grain</b:Setting>
      <b:Setting allowed="false" changes="true" entry_type="ELEMENT">GrainType</b:Setting>
      <b:Setting allowed="false" changes="true" entry_type="ELEMENT">Hop</b:Setting>
      <b:Setting allowed="false" changes="true" entry_type="ELEMENT">HopPurpose</b:Setting>
      <b:Setting allowed="false" changes="true" entry_type="ELEMENT">Yeast</b:Setting>
      <b:Setting allowed="false" changes="true" entry_type="ELEMENT">YeastType</b:Setting>
      <b:Setting allowed="false" changes="true" entry_type="ELEMENT">Package</b:Setting>
      <b:Setting allowed="false" changes="true" entry_type="ELEMENT">Flocculation</b:Setting>
      <b:Setting allowed="false" changes="true" entry_type="ELEMENT">Ingredient</b:Setting>
      <b:Setting allowed="false" changes="true" entry_type="ELEMENT">WtrProfile</b:Setting>
      <b:Setting allowed="true" changes="true" entry_type="ELEMENT" manditory="true">GCWord</b:Setting>
      <b:Setting allowed="false" changes="true" entry_type="ELEMENT">UOM</b:Setting>
      <b:Setting allowed="false" changes="true" entry_type="ELEMENT">Stage</b:Setting>
      <b:Setting allowed="false" changes="true" entry_type="ELEMENT">Sparge</b:Setting>
      <b:Setting allowed="true" changes="true" entry_type="ELEMENT" manditory="true">Lang</b:Setting>
      <b:Setting allowed="false" changes="true" entry_type="ELEMENT">MashType</b:Setting>
      <b:Setting allowed="false" entry_type="ELEMENT">CustmerRecipe</b:Setting>
      <b:Setting allowed="false" entry_type="ELEMENT">RecipeAdjunct</b:Setting>
      <b:Setting allowed="false" entry_type="ELEMENT">RecipeGrains</b:Setting>
      <b:Setting allowed="false" entry_type="ELEMENT">RecipeHops</b:Setting>
      <b:Setting allowed="false" entry_type="ELEMENT">RecipeTargets</b:Setting>
      <b:Setting allowed="false" entry_type="ELEMENT">RecipeWater</b:Setting>
      <b:Setting allowed="false" entry_type="ELEMENT">RecipeYeast</b:Setting>
    </b:Preferences>
  </b:Payload>
</b:Deployment_SubPrefs>
*/
Create proc di.SaveSubscriptionPrefsDoc (
	@SessID varchar(256),
	@doc nvarchar(max), -- the xml doc created by client
	@CleanOutPending bit = 0
)
with encryption, execute as 'sticky'
as
begin
	Declare @rc int;
	Declare @mesg nvarchar(2000);
	Declare @status bit;
	Declare @xdoc xml;
	Declare @old Table ([PrefID] smallint);

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

	Delete [di].[DeploymentSubscriptions]
	Output Deleted.Fk_PrefMstrID Into @old;

	-- now add in latest preferences from the doc just received...only load nodes with 'allowed=true'!!!
	with xmlnamespaces('http://burp.net/deployment/subscription/evnts' as b, default 'http://burp.net/deployment/subscription/evnts')
	insert into di.DeploymentSubscriptions (Fk_PrefMstrID, AllowChgOp)
	select 
		M.RowID, 
		ISNULL(D.p.value('(@changes)[1]','bit'),0)
	from @xdoc.nodes('(/b:Deployment_SubPrefs/b:Payload/b:Preferences/b:Setting)') As D(P)
	inner join di.DeploymentPrefsMstr M On (M.[Name] = D.p.value('(.)[1]','varchar(200)'))
	where D.p.value('(@allowed)[1]','bit') = 1 or D.P.value('(@manditory)[1]','bit') = 1;

	If (@CleanOutPending = 1)
	Begin
		Delete bhp.SubscriptionEvntPostings
		From bhp.SubscriptionEvntPostings L
		Inner Join 
		( -- get any prefs removed from latest pref setting update...then remove from pending log!!!
			Select Distinct [PrefID] 
			From @Old 
			Where PrefID Not In (Select Fk_PrefMstrID From di.DeploymentSubscriptions WHere Fk_PrefMstrID > 0)
		) As XX
		On (L.Fk_PrefsMstrID = XX.PrefID)
		Where (L.Fk_PrefsMstrID > 0);

		Set @rc = @@ERROR;

	End

	Set @rc = @@ERROR;

	Return @rc;
end
go

/*

declare @x nvarchar(max);
set @x = N'<?xml version="1.0" encoding="utf-16"?>
<b:Deployment_SubPrefs ver="1.0" ts="2022-03-30 17:06:19" did="3b126d15-8799-48d7-863f-5c552855ab45" name="Smeltania Brewing Comp." xmlns:b="http://burp.net/deployment/subscription/evnts">
  <b:Payload uid="cf18e19e-26d1-400c-ad08-12ca6a950bff">
    <b:Preferences>
      <b:Setting allowed="false" entry_type="ELEMENT">AgingSched</b:Setting>
      <b:Setting allowed="false" entry_type="ELEMENT">MashSched</b:Setting>
      <b:Setting allowed="false" entry_type="ELEMENT">HopSched</b:Setting>
      <b:Setting allowed="false" changes="true" entry_type="ELEMENT">AHAStyle</b:Setting>
      <b:Setting allowed="true" entry_type="ELEMENT">HopTimerStage</b:Setting>
      <b:Setting allowed="false" changes="true" entry_type="ELEMENT">TagWord</b:Setting>
      <b:Setting allowed="false" changes="true" entry_type="ELEMENT">Color</b:Setting>
      <b:Setting allowed="false" changes="true" entry_type="ELEMENT">Country</b:Setting>
      <b:Setting allowed="true" changes="true" entry_type="ELEMENT" manditory="true">Env</b:Setting>
      <b:Setting allowed="false" changes="true" entry_type="ELEMENT">Mfr</b:Setting>
      <b:Setting allowed="false" changes="true" entry_type="ELEMENT">Extract</b:Setting>
      <b:Setting allowed="false" changes="true" entry_type="ELEMENT">Grain</b:Setting>
      <b:Setting allowed="false" changes="true" entry_type="ELEMENT">GrainType</b:Setting>
      <b:Setting allowed="false" changes="true" entry_type="ELEMENT">Hop</b:Setting>
      <b:Setting allowed="false" changes="true" entry_type="ELEMENT">HopPurpose</b:Setting>
      <b:Setting allowed="false" changes="true" entry_type="ELEMENT">Yeast</b:Setting>
      <b:Setting allowed="false" changes="true" entry_type="ELEMENT">YeastType</b:Setting>
      <b:Setting allowed="false" changes="true" entry_type="ELEMENT">Package</b:Setting>
      <b:Setting allowed="false" changes="true" entry_type="ELEMENT">Flocculation</b:Setting>
      <b:Setting allowed="false" changes="true" entry_type="ELEMENT">Ingredient</b:Setting>
      <b:Setting allowed="false" changes="true" entry_type="ELEMENT">WtrProfile</b:Setting>
      <b:Setting allowed="true" changes="true" entry_type="ELEMENT" manditory="true">GCWord</b:Setting>
      <b:Setting allowed="false" changes="true" entry_type="ELEMENT">UOM</b:Setting>
      <b:Setting allowed="false" changes="true" entry_type="ELEMENT">Stage</b:Setting>
      <b:Setting allowed="false" changes="true" entry_type="ELEMENT">Sparge</b:Setting>
      <b:Setting allowed="true" changes="true" entry_type="ELEMENT" manditory="true">Lang</b:Setting>
      <b:Setting allowed="false" changes="true" entry_type="ELEMENT">MashType</b:Setting>
      <b:Setting allowed="false" entry_type="ELEMENT">CustmerRecipe</b:Setting>
      <b:Setting allowed="false" entry_type="ELEMENT">RecipeAdjunct</b:Setting>
      <b:Setting allowed="false" entry_type="ELEMENT">RecipeGrains</b:Setting>
      <b:Setting allowed="false" entry_type="ELEMENT">RecipeHops</b:Setting>
      <b:Setting allowed="false" entry_type="ELEMENT">RecipeTargets</b:Setting>
      <b:Setting allowed="false" entry_type="ELEMENT">RecipeWater</b:Setting>
      <b:Setting allowed="false" entry_type="ELEMENT">RecipeYeast</b:Setting>
    </b:Preferences>
  </b:Payload>
</b:Deployment_SubPrefs>
';
exec [BHP1-RO].[di].SaveSubscriptionPrefsDoc @SessID='00000000-0000-0000-0000-000000000000',@doc=@x;

select * from di.vw_DeploymentSubscriptions;
go
*/
