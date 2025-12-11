use [BHP1-RO]
go

if object_id(N'[bhp].GenRecipeTrgtsMesg',N'P') is not null
begin
	drop proc [bhp].GenRecipeTrgtsMesg;
	print 'proc:: [bhp].GenRecipeTrgtsMesg dropped!!!';
end
go

create proc [bhp].GenRecipeTrgtsMesg (
	@rid int, -- a recipe id value from RecipeJrnlMstr tbl
	@evnttype varchar(10), -- must be one of 'add','chg','del'
	@sessid varchar(256),
	@mesg xml output
)
with encryption
as
begin
	Declare @OG numeric(4,3);
	Declare @FG numeric(4,3);
	Declare @ABV numeric(3,1);
	Declare @Density numeric(6,3);
	Declare @DensityUOMID int;
	Declare @DensityUOM varchar(50);
	Declare @Color int;
	Declare @ColorUOMID int;
	Declare @ColorUOM varchar(50);
	Declare @IBU int;
	Declare @IBUUOMID int;
	Declare @IBUUOM varchar(50);
	Declare @BatchQty numeric(6,2);
	Declare @BatchQtyUOMID int;
	Declare @BatchQtyUOM varchar(50);
	Declare @BoilQty numeric(6,2);
	Declare @BoilQtyUOMID int;
	Declare @BoilQtyUOM varchar(50);
	Declare @name varchar(256);
	Declare @isDraft bit;
	Declare @ts varchar(50);
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
		<b:Targets/>
		</b:Recipe_Evnt>
		into (/b:Burp_Belch/b:Payload)[1]');

	set @mesg.modify('
		declare namespace b="http://burp.net/recipe/evnts";
		insert attribute type {''targets''}
		into (/b:Burp_Belch/b:Payload)[1]
	');

	-- now get values to stuff in

	Select 
		@name = M.[Name],
		@isDraft = ISNULL(M.isDraft, 1),
		@BatchQty = M.BatchQty,
		@BatchQtyUOMID = M.fk_BatchUOM,
		@BatchQtyUOM = M.BatchUOM,
		@BoilQty = M.TargetBoilSize,
		@BoilQtyUOMID = M.fk_BoilSizeUOM,
		@BoilQtyUOM = M.BoilSizeUOM,
		@OG = M.TargetOG,
		@FG = M.TargetFG,
		@ABV = M.TargetABV,
		@Density = M.TargetDensity,
		@DensityUOMID = M.fk_TargetDensityUOM,
		@DensityUOM = M.TargetDensityUOM,
		@Color = M.TargetColor,
		@ColorUOMID = M.fk_TargetColorUOM,
		@ColorUOM = M.TargetColorUOM,
		@IBU = M.TargetBitterness,
		@IBUUOMID = M.fk_TargetBitternessUOM,
		@IBUUOM = M.TargetBitternessUOM,
		@ts = [di].fn_Timestamp(M.EnteredOn),
		@custID = C.RowID,
		@custUID = C.BHPUid,
		@custNm = C.[Name]
		--@notes=[bhp].fn_ToXMLNote([Notes]),
		--@Lang=N'en_us'
	From [bhp].RecipeJrnlMstr M Inner Join [di].vw_CustomerMstr C On (fk_CreatedBy = C.RowID)
	Where (M.RowID = @rid);

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
			<b:BatchQty>
				<b:Amt>{sql:variable("@BatchQty")}</b:Amt>
				<b:UOM id=''{sql:variable("@BatchQtyUOMID")}''>{sql:variable("@BatchQtyUOM")}</b:UOM>
			</b:BatchQty>,
			<b:BoilQty>
				<b:Amt>{sql:variable("@BoilQty")}</b:Amt>
				<b:UOM id=''{sql:variable("@BoilQtyUOMID")}''>{sql:variable("@BoilQtyUOM")}</b:UOM>
			</b:BoilQty>,
			<b:OG>{sql:variable("@OG")}</b:OG>,
			<b:FG>{sql:variable("@FG")}</b:FG>,
			<b:ABV>{sql:variable("@ABV")}</b:ABV>,
			<b:PreBoil>
				<b:Amt>{sql:variable("@Density")}</b:Amt>
				<b:UOM id=''{sql:variable("@DensityUOMID")}''>{sql:variable("@DensityUOM")}</b:UOM>
			</b:PreBoil>,
			<b:Color>
				<b:Amt>{sql:variable("@Color")}</b:Amt>
				<b:UOM id=''{sql:variable("@ColorUOMID")}''>{sql:variable("@ColorUOM")}</b:UOM>
			</b:Color>,
			<b:Bitterness>
				<b:Amt>{sql:variable("@IBU")}</b:Amt>
				<b:UOM id=''{sql:variable("@IBUUOMID")}''>{sql:variable("@IBUUOM")}</b:UOM>
			</b:Bitterness>
		)
		into (/b:Burp_Belch/b:Payload/b:Recipe_Evnt/b:Targets)[1]
	');

	Return 0;
end
go


/*

declare @m xml;
declare @rc int;
exec @rc = [bhp].GenRecipeTrgtsMesg @rid=9, @evnttype='add', @SessID=N'00000000-0000-0000-0000-000000000000', @mesg = @m output;

with xmlnamespaces('http://burp.net/recipe/evnts' as b, default 'http://burp.net/recipe/evnts')
select @rc [@rc], @m [the message];

*/