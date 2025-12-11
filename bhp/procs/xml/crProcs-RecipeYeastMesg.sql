use [BHP1-RO]
go

if object_id(N'[bhp].GenRecipeYeastMesg',N'P') is not null
begin
	drop proc [bhp].GenRecipeYeastMesg;
	print 'proc:: [bhp].GenRecipeYeastMesg dropped!!!';
end
go

create proc [bhp].GenRecipeYeastMesg (
	@rid int, -- a recipe id value from RecipeJrnlMstr tbl
	@yid int, -- Yeast id
	@evnttype varchar(10), -- must be one of 'add','chg','del'
	@sessid varchar(256),
	@mesg xml output
)
with encryption
as
begin
	Declare @fk_YeastUOMID int;
	Declare @YeastUOM varchar(50);
	Declare @Qty numeric(10,4);
	Declare @StageID int;
	Declare @StageNm varchar(50);
	Declare @notes xml;
	Declare @name varchar(256);
	Declare @YeastNm varchar(256);
	Declare @isDraft bit;
	Declare @ts varchar(50);
	Declare @SessSrc xml;
	Declare @MfrID int;
	Declare @MfrNm nvarchar(300);
	Declare @TypNm varchar(256);
	Declare @rowid int; -- the rowid from RecipeYeasts tbl
	Declare @custID bigint;
	Declare @custUID nvarchar(256);
	Declare @custNm nvarchar(200);

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
		<b:Yeasts/>
		</b:Recipe_Evnt>
		into (/b:Burp_Belch/b:Payload)[1]');

	set @mesg.modify('
		declare namespace b="http://burp.net/recipe/evnts";
		insert attribute type {''yeast''}
		into (/b:Burp_Belch/b:Payload)[1]
	');

	-- now get values to stuff in

	Select
		@rowid = RY.RowID,
		@name = M.[Name],
		@isDraft = ISNULL(M.isDraft, 1),
		@YeastNm=Y.[Name],
		@fk_YeastUOMID = RY.fk_YeastUOM,
		@YeastUOM = RY.YeastUOM,
		@Qty = ISNULL(RY.QtyOrAmount, 0),
		@StageID = RY.fk_Stage,
		@StageNm = RY.StageNm,
		@MfrID = MFR.[RowID],
		@MfrNm = MFR.[Name],
		@notes = [di].fn_ToXMLNote(RY.Comment),
		@ts = [di].fn_Timestamp(M.EnteredOn),
		@custID = C.RowID,
		@custUID = C.BHPUid,
		@custNm = C.[Name],
		@TypNm = T.Name
	From [bhp].RecipeJrnlMstr M 
	Inner Join [di].vw_CustomerMstr C On (M.fk_CreatedBy = C.RowID)
	Inner Join [bhp].RecipeYeasts RY on (RY.fk_RecipeJrnlMstrID = M.RowID)
	Inner Join [bhp].YeastMstr Y on (RY.fk_YeastMstrID = Y.RowID)
	Inner Join [bhp].YeastManufacturers MFR On (Y.fk_YeastMfr = MFR.RowID)
	Inner Join [bhp].YeastTypes T On (Y.fk_YeastType = T.RowID)
	Where (M.RowID = @rid And Y.RowID = @yid);

	set @mesg.modify('
		declare namespace b="http://burp.net/recipe/evnts";
		insert (
			<b:Creator custid=''{sql:variable("@custID")}'' uid=''{sql:variable("@custUID")}''>
				{sql:variable("@custNm")}
			</b:Creator>,
			<b:Name>{sql:variable("@name")}</b:Name>,
			<b:IsDraft>{sql:variable("@isDraft")}</b:IsDraft>,
			<b:CreatedOn>{sql:variable("@ts")}</b:CreatedOn>
		) into (/b:Burp_Belch/b:Payload/b:Recipe_Evnt/b:Info)[1]
	');

	-- stuff in values...
	set @mesg.modify('
		declare namespace b="http://burp.net/recipe/evnts";
		insert (
			<b:Yeast recid=''{sql:variable("@rowid")}''>
				<b:MfrInfo id=''{sql:variable("@MfrID")}''>{sql:variable("@MfrNm")}</b:MfrInfo>
				<b:Name id=''{sql:variable("@yid")}'' type=''{sql:variable("@TypNm")}''>{sql:variable("@YeastNm")}</b:Name>
				<b:Qty>
					<b:Amt>{sql:variable("@Qty")}</b:Amt>
					<b:UOM id=''{sql:variable("@fk_YeastUOMID")}''>{sql:variable("@YeastUOM")}</b:UOM>
				</b:Qty>
				<b:Stage id=''{sql:variable("@StageID")}''>{sql:variable("@StageNm")}</b:Stage>
			</b:Yeast>
		)
		into (/b:Burp_Belch/b:Payload/b:Recipe_Evnt/b:Yeasts)[1]
	');

	-- stuff in any note/comment....
	set @mesg.modify('
		declare namespace b="http://burp.net/recipe/evnts";
		insert sql:variable("@notes") as last into (/b:Burp_Belch/b:Payload/b:Recipe_Evnt/b:Yeasts/b:Yeast)[1]
	');

	Return 0;
end
go


/*

declare @m xml;
declare @rc int;
exec @rc = [bhp].GenRecipeYeastMesg @rid=9, @yid=21, @evnttype='add', @SessID=N'00000000-0000-0000-0000-000000000000', @mesg = @m output;

with xmlnamespaces('http://burp.net/recipe/evnts' as b, default 'http://burp.net/recipe/evnts')
select @rc [@rc], @m [the message];

*/