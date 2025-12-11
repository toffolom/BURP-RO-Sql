use [BHP1-RO]
go

if object_id(N'[bhp].GenRecipeExtractMesg',N'P') is not null
begin
	drop proc [bhp].GenRecipeExtractMesg;
	print 'proc:: [bhp].GenRecipeExtractMesg dropped!!!';
end
go

create proc [bhp].GenRecipeExtractMesg (
	@rid int, -- a recipe id value from RecipeJrnlMstr tbl
	@eid int, -- Extract id
	@evnttype varchar(10), -- must be one of 'add','chg','del'
	@sessid varchar(256),
	@mesg xml output
)
with encryption
as
begin
	declare @fk_MfrID int;
	Declare @MfrNm nvarchar(300);
	Declare @fk_TypeID int;
	Declare @TypNm varchar(50);
	Declare @fk_ExtractUOMID int;
	Declare @ExtractUOM varchar(50);
	Declare @Qty numeric(10,4);
	Declare @StageID int;
	Declare @StageNm varchar(50);
	Declare @notes xml;
	Declare @name varchar(256);
	Declare @ExtractNm varchar(256);
	Declare @isDraft bit;
	Declare @SessSrc xml;
	Declare @ts varchar(50);
	Declare @rowid int;
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
		insert (
			attribute type {''extract''},
			<b:Recipe_Evnt type=''{sql:variable("@evnttype")}'' recipe_id=''{sql:variable("@rid")}''>
			<b:Info/>
			<b:Extracts/>
			</b:Recipe_Evnt>
		)
		into (/b:Burp_Belch/b:Payload)[1]');

	-- now get values to stuff in
	Select
		@rowid = RG.RowID,
		@name = M.[Name],
		@isDraft = ISNULL(M.isDraft, 1),
		@ExtractNm=E.[Name],
		@fk_MfrID = E.fk_ExtractMfrID,
		@MfrNm = Case E.fk_ExtractMfrID WHen 0 Then 'no mfr specified' Else MFR.Name End,
		@fk_ExtractUOMID = RG.fk_QtyOrAmtUOM,
		@ExtractUOM = U.UOM,
		@Qty = RG.QtyOrAmt,
		@StageID = RG.fk_Stage,
		@StageNm = [bhp].fn_GetStageName(RG.fk_stage),
		@notes = [di].fn_ToXMLNote(RG.Comment),
		@ts = [di].fn_Timestamp(M.EnteredOn),
		@custID = C.RowID,
		@custUID = C.BHPUid,
		@custNm = C.[Name]
	From [bhp].RecipeJrnlMstr M 
	Inner Join [di].vw_CustomerMstr C On (M.fk_CreatedBy = C.RowID)
	Inner Join [bhp].RecipeExtracts RG on (RG.fk_RecipeJrnlMstrID = M.RowID)
	Inner Join [bhp].ExtractMstr E on (RG.fk_ExtractMstrID = E.RowID)
	Inner Join [bhp].ExtractManufacturers MFR on (E.fk_ExtractMfrID = MFR.RowID)
	Inner Join [bhp].UOMTypes U On (RG.fk_QtyOrAmtUOM = U.RowID)
	Where (M.RowID = @rid And E.RowID = @eid);

	-- stuff in values...
	set @mesg.modify('
		declare namespace b="http://burp.net/recipe/evnts";
		insert (
			<b:Extract recid=''{sql:variable("@rowid")}''>
			<b:MfrInfo id=''{sql:variable("@fk_MfrID")}''>{sql:variable("@MfrNm")}</b:MfrInfo>
			<b:Name id=''{sql:variable("@eid")}''>{sql:variable("@ExtractNm")}</b:Name>
			<b:Qty>
				<b:Amt>{sql:variable("@Qty")}</b:Amt>
				<b:UOM id=''{sql:variable("@fk_ExtractUOMID")}''>{sql:variable("@ExtractUOM")}</b:UOM>
			</b:Qty>
			<b:Stage id=''{sql:variable("@StageID")}''>{sql:variable("@StageNm")}</b:Stage>
			</b:Extract>
		)
		into (/b:Burp_Belch/b:Payload/b:Recipe_Evnt/b:Extracts)[1]
	');

	-- stuff in any note/comment....
	set @mesg.modify('
		declare namespace b="http://burp.net/recipe/evnts";
		insert sql:variable("@notes") as last into (/b:Burp_Belch/b:Payload/b:Recipe_Evnt/b:Extracts/b:Extract)[1]
	');

	-- add some node(s) to <Info>...
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

	Return 0;
end
go


/*

declare @m xml;
declare @rc int;
exec @rc = [bhp].GenRecipeExtractMesg @rid=9, @eid=5, @evnttype='add', @SessID=N'00000000-0000-0000-0000-000000000000', @mesg = @m output;

with xmlnamespaces('http://burp.net/recipe/evnts' as b, default 'http://burp.net/recipe/evnts')
select @rc [@rc], @m [the message];

*/