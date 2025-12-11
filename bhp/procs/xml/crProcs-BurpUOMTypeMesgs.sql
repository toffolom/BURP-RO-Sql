use [BHP1-RO]
go

if object_id(N'[bhp].GenBurpUOMTypeMesg',N'P') is not null
begin
	drop proc [bhp].GenBurpUOMTypeMesg;
	print 'proc:: [bhp].GenBurpUOMTypeMesg dropped!!!';
end
go

create proc [bhp].GenBurpUOMTypeMesg (
	@id int, -- a rowid value mash types master table ([bhp].MashTypeMstr)
	@evnttype varchar(10), -- must be one of 'add','chg','del'
	@SessID varchar(256),
	@mesg xml output
)
with encryption, execute as 'sticky'
as
begin
	Declare @sql nvarchar(max);
	Declare @nm nvarchar(100);
	Declare @abbr nvarchar(50);
	Declare @isTime bit;
	Declare @isVol bit;
	Declare @isTemp bit;
	Declare @isCon bit;
	Declare @isColor bit;
	Declare @isBitter bit;
	Declare @isWeight bit;
	Declare @isMoney bit;
	Declare @minVal varchar(50);
	Declare @maxVal varchar(50);
	Declare @Lang varchar(20);
	Declare @notes xml; -- holds any notes/comments. eg: <Notes><Note nbr='int'>string</Note><Notes>...
	Declare @SessSrc xml;


	-- create our stub root node.
	Begin Try
		Exec [bhp].GenBurpBelchRootNode @SessID=@SessID, @Mesg=@Mesg output;
	End Try
	Begin Catch
		Return -1;
	End Catch

	-- prime up the rest...
	set @mesg.modify('
		declare namespace b="http://burp.net/recipe/evnts";
		insert 
		<b:UOM_Evnt type=''{sql:variable("@evnttype")}''>
		<b:Info/>
		</b:UOM_Evnt>
		into (/b:Burp_Belch/b:Payload)[1]');

	set @mesg.modify('
		declare namespace b="http://burp.net/recipe/evnts";
		insert attribute type {''uom''}
		into (/b:Burp_Belch/b:Payload)[1]
	');

	-- now get values to stuff in
	set @sql = N'
Select 
	@outnm=M.[Name],
	@outabbr=ISNULL(M.[UOM], M.[Name]),
	@outIsTime=ISNULL(M.[AllowedAsTimeMeasure],0),
	@outIsVol=ISNULL(M.[AllowedAsVolumnMeasure],0),
	@outIsTemp=ISNULL(M.[AllowedAsTemperature],0),
	@outIsCon=ISNULL(M.[AllowedAsContainer],0),
	@outIsColor=ISNULL(M.[AllowedAsColorMeasure],0),
	@outIsBitter=ISNULL(M.[AllowedAsBitterMeasure],0),
	@outIsWeight=ISNULL(M.[AllowedAsWeightMeasure],0),
	@outIsMoney=ISNULL(M.[AllowedAsMonetary],0),
	@outnotes=[di].fn_ToXMLNote(M.[Comment]),
	@outMinVal=ISNULL(M.[MinVal],''n/a''),
	@outMaxVal=ISNULL(M.[MaxVal],''n/a''),
	@outLang=N''en_us''
From [bhp].UOMTypes As M
Where (M.RowID = @InRowID);
';

	exec [dbo].sp_ExecuteSql
		@Stmt=@sql,
		@Params = N'@InRowID int, 
				@outnm nvarchar(100) output, 
				@outabbr nvarchar(50) output, 
				@outIsTime bit output,
				@outIsVol bit output,
				@outIsTemp bit output,
				@outIsCon bit output,
				@outIsColor bit output,
				@outIsBitter bit output,
				@outIsWeight bit output,
				@outIsMoney bit output,
				@outnotes xml output,
				@outlang varchar(20) output,
				@outMinVal varchar(50) output,
				@outMaxVal varchar(50) output',
		@InRowID = @id,
		@outnm = @nm output,
		@outabbr = @abbr output,
		@outIsTime = @isTime output,
		@outIsVol = @isVol output,
		@outIsTemp = @isTemp output,
		@outIsCon = @isCon output,
		@outIsColor = @isColor output,
		@outIsBitter = @isBitter output,
		@outIsWeight = @isWeight output,
		@outIsMoney = @isMoney output,
		@outLang = @lang output,
		@outnotes = @notes output,
		@outMinVal = @minVal output,
		@outMaxVal = @maxVal output;

	-- stuff in values...
	set @mesg.modify('
		declare namespace b="http://burp.net/recipe/evnts";
		insert (
			<b:Name>{sql:variable("@nm")}</b:Name>,
			<b:Abbr>{sql:variable("@abbr")}</b:Abbr>,
			<b:IsTime>{sql:variable("@isTime")}</b:IsTime>,
			<b:IsVol>{sql:variable("@isVol")}</b:IsVol>,
			<b:IsTemp>{sql:variable("@isTemp")}</b:IsTemp>,
			<b:IsContainer>{sql:variable("@isCon")}</b:IsContainer>,
			<b:IsColor>{sql:variable("@isColor")}</b:IsColor>,
			<b:IsBitter>{sql:variable("@isBitter")}</b:IsBitter>,
			<b:IsWeight>{sql:variable("@isWeight")}</b:IsWeight>,
			<b:IsMonetary>{sql:variable("@isMoney")}</b:IsMonetary>,
			<b:MinVal>{sql:variable("@minVal")}</b:MinVal>,
			<b:MaxVal>{sql:variable("@maxVal")}</b:MaxVal>
		)
		into (/b:Burp_Belch/b:Payload/b:UOM_Evnt/b:Info)[1]
	');

	-- stuff in any note/comment....
	set @mesg.modify('
		declare namespace b="http://burp.net/recipe/evnts";
		insert sql:variable("@notes") as last into (/b:Burp_Belch/b:Payload/b:UOM_Evnt/b:Info)[1]
	');

	-- set the attributes on node <Info>...id (aka: rowid) and lang
	set @mesg.modify('
		declare namespace b="http://burp.net/recipe/evnts";
		insert (
			attribute id {sql:variable("@id")},
			attribute lang {sql:variable("@Lang")}
		)
		into (/b:Burp_Belch/b:Payload/b:UOM_Evnt/b:Info)[1]
	');

	Return 0;
end
go


/*
--set ansi_nulls on;
--set quoted_identifier on;
declare @m xml;
declare @rc int;
exec @rc = [bhp].GenBurpUOMTypeMesg @id=56, @SessID='00000000-0000-0000-0000-000000000000', @evnttype='add', @mesg = @m output;

with xmlnamespaces('http://burp.net/recipe/evnts' as b, default 'http://burp.net/recipe/evnts')
select @rc [@rc], @m [the message];

*/