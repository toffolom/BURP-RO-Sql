use [BHP1-RO]
go

if object_id(N'[bhp].GenRecipeWaterProfileMesg',N'P') is not null
begin
	drop proc [bhp].GenRecipeWaterProfileMesg;
	print 'proc:: [bhp].GenRecipeWaterProfileMesg dropped!!!';
end
go

create proc [bhp].GenRecipeWaterProfileMesg (
	@rid int, -- a recipe id value from RecipeJrnlMstr tbl
	@evnttype varchar(10), -- must be one of 'add','chg','del'
	@sessid varchar(256),
	@mesg xml output
)
with encryption
as
begin
	Declare @Notes xml;
	Declare @name varchar(256);
	Declare @isDraft bit;
	Declare @Lang varchar(20);
	Declare @SessSrc xml;
	Declare @ts varchar(50);
	Declare @CustID bigint;
	Declare @CustNm nvarchar(200);
	Declare @CustUID varchar(256);
	Declare @profileID int;
	Declare @calcium numeric(4,1);
	Declare @calciumUOM varchar(50);
	Declare @magnesium numeric(4,1);
	Declare @magnesiumUOM varchar(50);
	Declare @sodium numeric(4,1);
	Declare @sodiumUOM varchar(50);
	Declare @sulfate numeric(4,1);
	Declare @sulfateUOM varchar(50);
	Declare @chloride numeric(4,1);
	Declare @chlorideUOM varchar(50);
	Declare @Bicarb numeric(4,1);
	Declare @BicarbUOM varchar(50);
	Declare @ph numeric(3,1);
	Declare @phUOM varchar(50);
	Declare @famousProfileID int;
	Declare @famousNm varchar(200);

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
		<b:Recipe_Evnt type=''{sql:variable("@evnttype")}'' recipe_id=''{sql:variable("@rid")}''>
		<b:Info/>
		<b:Profile_Info/>
		</b:Recipe_Evnt>
		into (/b:Burp_Belch/b:Payload)[1]');

	set @mesg.modify('
		declare namespace b="http://burp.net/recipe/evnts";
		insert attribute type {''water profile''}
		into (/b:Burp_Belch/b:Payload)[1]
	');

	-- now get values to stuff in

	Select 
		@name = M.[Name],
		@isDraft = ISNULL(M.isDraft, 1),
		@Lang = ISNULL(A.Lang,'en_us'),
		@ts = [di].fn_Timestamp(M.EnteredOn),
		@CustID = M.fk_CreatedBy,
		@CustNm = C.[Name],
		@CustUID = C.[BHPUid],
		@ProfileID = W.[RowID],
		@calcium = ISNULL(W.Calcium,0.0),
		@calciumUOM = W.CalcUOM,
		@magnesium = ISNULL(W.Magnesium,0.0),
		@magnesiumUOM = W.MagUOM,
		@sodium = ISNULL(W.Sodium,0.0),
		@sodiumUOM = W.SodUOM,
		@sulfate = ISNULL(W.Sulfate,0.0),
		@sulfateUOM = W.SulfUOM,
		@chloride = ISNULL(W.Chloride,0.0),
		@chlorideUOM = W.ChlorUOM,
		@Bicarb = ISNULL(W.Bicarbonate,0.0),
		@BicarbUOM = W.BicarUOM,
		@ph = ISNULL(W.Ph,0.0),
		@phUOM = W.PhUOM,
		@famousProfileID = W.fk_InitilizedByFamousWtrID,
		@famousNm = F.[Name],
		@notes=[di].fn_ToXMLNote(W.[Comments])
	From [bhp].RecipeJrnlMstr M Inner Join [bhp].AHABeerStyle A on (M.fk_BeerStyle = A.RowID)
	Inner Join [di].vw_CustomerMstr C On (M.fk_CreatedBy = C.RowID)
	Inner Join [bhp].RecipeWaterProfile W On (W.fk_RecipeJrnlMstrID = M.RowID)
	Inner Join [bhp].FamousWaterProfiles F On (W.fk_InitilizedByFamousWtrID = F.RowID)
	Where (M.RowID = @rid);

	-- stuff in recipe info bits...
	set @mesg.modify('
		declare namespace b="http://burp.net/recipe/evnts";
		insert (
			<b:Creator custid=''{sql:variable("@CustID")}'' uid=''{sql:variable("@CustUID")}''>
				{sql:variable("@CustNm")}
			</b:Creator>,
			<b:Name>{sql:variable("@name")}</b:Name>,
			<b:IsDraft>{sql:variable("@isDraft")}</b:IsDraft>,
			<b:CreatedOn>{sql:variable("@ts")}</b:CreatedOn>
		) into (/b:Burp_Belch/b:Payload/b:Recipe_Evnt/b:Info)[1]
	');

	-- stuff in profile values...
	set @mesg.modify('
		declare namespace b="http://burp.net/recipe/evnts";
		insert (
			attribute id {sql:variable("@profileID")},
			<b:Calcium>
				<b:UOM name=''{sql:variable("@calciumUOM")}''/>
				<b:Amt>{sql:variable("@calcium")}</b:Amt>
			</b:Calcium>,
			<b:Magnesium>
				<b:UOM name=''{sql:variable("@magnesiumUOM")}''/>
				<b:Amt>{sql:variable("@magnesium")}</b:Amt>
			</b:Magnesium>,
			<b:Sodium>
				<b:UOM name=''{sql:variable("@sodiumUOM")}''/>
				<b:Amt>{sql:variable("@sodium")}</b:Amt>
			</b:Sodium>,
			<b:Sulfate>
				<b:UOM name=''{sql:variable("@sulfateUOM")}''/>
				<b:Amt>{sql:variable("@sulfate")}</b:Amt>
			</b:Sulfate>,
			<b:Chloride>
				<b:UOM name=''{sql:variable("@chlorideUOM")}''/>
				<b:Amt>{sql:variable("@chloride")}</b:Amt>
			</b:Chloride>,
			<b:Bicarbonate>
				<b:UOM name=''{sql:variable("@bicarbUOM")}''/>
				<b:Amt>{sql:variable("@bicarb")}</b:Amt>
			</b:Bicarbonate>,
			<b:Ph>
				<b:UOM name=''{sql:variable("@phUOM")}''/>
				<b:Amt>{sql:variable("@ph")}</b:Amt>
			</b:Ph>,
			<b:Initialized_From id=''{sql:variable("@famousProfileID")}''>
				<b:Name>{sql:variable("@famousNm")}</b:Name>
			</b:Initialized_From>
		)
		into(/b:Burp_Belch/b:Payload/b:Recipe_Evnt/b:Profile_Info)[1]
	');

	-- stuff in any note/comment....
	set @mesg.modify('
		declare namespace b="http://burp.net/recipe/evnts";
		insert sql:variable("@notes") into (/b:Burp_Belch/b:Payload/b:Recipe_Evnt/b:Profile_Info)[1]
	');

	Return 0;
end
go


/*
use BHP1
go

declare @m xml;
declare @rc int;
exec @rc = [bhp].GenRecipeWaterProfileMesg @rid=9, @evnttype='add', @SessID=N'00000000-0000-0000-0000-000000000000', @mesg = @m output;

with xmlnamespaces('http://burp.net/recipe/evnts' as b, default 'http://burp.net/recipe/evnts')
select @rc [@rc], @m [the message];

*/