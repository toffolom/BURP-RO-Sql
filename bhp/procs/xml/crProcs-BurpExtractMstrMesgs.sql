use [BHP1-RO]
go

if object_id(N'[bhp].GenBurpExtractMstrMesg',N'P') is not null
begin
	drop proc [bhp].GenBurpExtractMstrMesg;
	print 'proc:: [bhp].GenBurpExtractMstrMesg dropped!!!';
end
go

create proc [bhp].GenBurpExtractMstrMesg (
	@id int, -- a rowid value
	@evnttype varchar(10), -- must be one of 'add','chg','del'
	@SessID varchar(256),
	@mesg xml output
)
with encryption
as
begin

	Declare @nm varchar(256);
	declare @fk_MfrID int;
	Declare @MfrNm nvarchar(300);
	Declare @fk_SolidUOM int;
	Declare @SolidUOM varchar(50);
	Declare @SolidBegAmt numeric(5,2);
	Declare @SolidEndAmt numeric(5,2);
	Declare @fk_ColorUOM int;
	Declare @ColorUOM varchar(50);
	Declare @ColorBegAmt numeric(6,2);
	Declare @ColorEndAmt numeric(6,2);
	Declare @fk_BitterUOM int;
	Declare @BitterUOM varchar(50);
	Declare @BitterBegAmt numeric(6,2);
	Declare @BitterEndAmt numeric(6,2);
	Declare @IsHopped bit;
	Declare @fk_HopUOM int;
	Declare @HopUOM varchar(50);
	Declare @hopAmt numeric(6,2);
	Declare @isDiastic bit;
	Declare @Lang varchar(20);
	Declare @aka1 nvarchar(245);
	Declare @aka2 nvarchar(245);
	Declare @aka3 nvarchar(245);
	Declare @notes xml;
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
		<b:Extract_Evnt type=''{sql:variable("@evnttype")}''>
		<b:Mstr_Info/>
		</b:Extract_Evnt>
		into (/b:Burp_Belch/b:Payload)[1]');

	set @mesg.modify('
		declare namespace b="http://burp.net/recipe/evnts";
		insert attribute type {''extract''}
		into (/b:Burp_Belch/b:Payload)[1]
	');

	-- now get values to stuff in
	Select 
		@nm=M.[Name],
		@fk_MfrID = M.fk_ExtractMfrID,
		@MfrNm = Case M.fk_ExtractMfrID WHen 0 Then Space(0) Else M.ExtractMfrNm End,
		@fk_SolidUOM = ISNULL(M.fk_SolidUOM,0),
		@SolidUOM = U3.UOM,
		@SolidBegAmt = ISNULL(M.BegSolidsAmt,0),
		@SolidEndAmt = ISNULL(M.EndSolidsAmt,0),
		@fk_ColorUOM = ISNULL(M.fk_ColorUOM,0),
		@ColorUOM = U2.UOM,
		@ColorBegAmt = ISNULL(M.BegColorAmt,0),
		@ColorEndAmt = ISNULL(M.EndColorAmt,0),
		@fk_BitterUOM = ISNULL(M.fk_BitternessUOM,0),
		@BitterUOM = U1.UOM,
		@BitterBegAmt = ISNULL(M.BegBitternessAmt,0),
		@BitterEndAmt = ISNULL(M.EndBitternessAmt,0),
		@aka1 = M.KnownAs1,
		@aka2 = M.KnownAs2,
		@aka3 = M.KnownAs3,
		@lang='en_us',
		@notes = [di].fn_ToXMLNote(M.Comment),
		@IsHopped = ISNULL(M.IsHopped,0),
		@isDiastic = ISNULL(M.IsDiastatic,0),
		@fk_HopUOM = ISNULL(M.fk_HopUOM,0),
		@hopAmt = ISNULL(M.HopAmt,0),
		@HopUOM = U4.UOM
	From [bhp].ExtractMstr As M
	Inner Join [bhp].UOMTypes U1 On (ISNULL(M.fk_BitternessUOM,0) = U1.RowID)
	Inner Join [bhp].UOMTypes U2 on (ISNULL(M.fk_ColorUOM,0) = U2.RowID)
	Inner Join [bhp].UOMTypes U3 On (ISNULL(M.fk_SolidUOM,0) = U3.RowID)
	Inner Join [bhp].UOMTypes U4 On (ISNULL(M.fk_HopUOM,0) = U4.RowID)
	Where (M.RowID = @id);

	set @aka1 = [di].fn_IsNull(@aka1);
	set @aka2 = [di].fn_IsNull(@aka2);
	set @aka3 = [di].fn_IsNull(@aka3);

	-- stuff in values...
	set @mesg.modify('
		declare namespace b="http://burp.net/recipe/evnts";
		insert (
			<b:Name>{sql:variable("@nm")}</b:Name>,
			<b:MfrInfo id=''{sql:variable("@fk_MfrID")}''>{sql:variable("@MfrNm")}</b:MfrInfo>,
			<b:Solid_Range>
				<b:Beg>{sql:variable("@SolidBegAmt")}</b:Beg>
				<b:End>{sql:variable("@SolidEndAmt")}</b:End>
				<b:UOM id=''{sql:variable("@fk_SolidUOM")}''>{sql:variable("@SolidUOM")}</b:UOM>
			</b:Solid_Range>,
			<b:Color_Range>
				<b:Beg>{sql:variable("@ColorBegAmt")}</b:Beg>
				<b:End>{sql:variable("@ColorEndAmt")}</b:End>
				<b:UOM id=''{sql:variable("@fk_ColorUOM")}''>{sql:variable("@ColorUOM")}</b:UOM>
			</b:Color_Range>,
			<b:Bitterness_Range>
				<b:Beg>{sql:variable("@BitterBegAmt")}</b:Beg>
				<b:End>{sql:variable("@BitterEndAmt")}</b:End>
				<b:UOM id=''{sql:variable("@fk_BitterUOM")}''>{sql:variable("@BitterUOM")}</b:UOM>
			</b:Bitterness_Range>,
			<b:AKA1>{sql:variable("@aka1")}</b:AKA1>,
			<b:AKA2>{sql:variable("@aka2")}</b:AKA2>,
			<b:AKA3>{sql:variable("@aka3")}</b:AKA3>,
			<b:Hop_Info ishopped=''{sql:variable("@isHopped")}''>
				<b:Amt>{sql:variable("@HopAmt")}</b:Amt>
				<b:UOM id=''{sql:variable("@fk_HopUOM")}''>{sql:variable("@HopUOM")}</b:UOM>
			</b:Hop_Info>,
			<b:IsDiastic>{sql:variable("@isDiastic")}</b:IsDiastic>
		)
		into (/b:Burp_Belch/b:Payload/b:Extract_Evnt/b:Mstr_Info)[1]
	');

	--if (@IsHopped = 1)
	--begin
	--	set @mesg.modify('
	--		declare namespace b="http://burp.net/recipe/evnts";
	--		insert (
	--			<b:Amt>{sql:variable("@HopAmt")}</b:Amt>,
	--			<b:UOM id=''{sql:variable("@fk_HopUOM")}''>{sql:variable("@HopUOM")}</b:UOM>
	--		) into (/b:Burp_Belch/b:Payload/b:Extract_Evnt/b:Mstr_Info/b:Hop_Info)[1]
	--	');
	--end

	-- stuff in any note/comment....
	set @mesg.modify('
		declare namespace b="http://burp.net/recipe/evnts";
		insert sql:variable("@notes") as last into (/b:Burp_Belch/b:Payload/b:Extract_Evnt/b:Mstr_Info)[1]
	');

	-- set the attributes on node <Info>...id (aka: rowid) and lang
	set @mesg.modify('
		declare namespace b="http://burp.net/recipe/evnts";
		insert (
			attribute id {sql:variable("@id")},
			attribute lang {sql:variable("@Lang")}
		)
		into (/b:Burp_Belch/b:Payload/b:Extract_Evnt/b:Mstr_Info)[1]
	');

	Return 0;
end
go


/*

declare @m xml;
declare @rc int;
exec @rc = [bhp].GenBurpExtractMstrMesg @id=2, @SessID='00000000-0000-0000-0000-000000000000', @evnttype='add', @mesg = @m output;

with xmlnamespaces('http://burp.net/recipe/evnts' as b)
select @rc [@rc], @m [the message];

*/