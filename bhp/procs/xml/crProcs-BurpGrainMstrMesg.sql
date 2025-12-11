use [BHP1-RO]
go

if object_id(N'[bhp].GenBurpGrainMstrMesg',N'P') is not null
begin
	drop proc [bhp].GenBurpGrainMstrMesg;
	print 'proc:: [bhp].GenBurpGrainMstrMesg dropped!!!';
end
go

create proc [bhp].GenBurpGrainMstrMesg (
	@id int, -- a rowid value
	@evnttype varchar(10), -- must be one of 'add','chg','del'
	@sessid varchar(256),
	@mesg xml output
)
with encryption
as
begin
	Declare @nm varchar(256);
	declare @fk_MfrID int;
	Declare @MfrNm nvarchar(300);
	Declare @fk_TypeID int;
	Declare @TypNm varchar(50);
	Declare @fk_CountryID int;
	Declare @countryNm varchar(200);
	Declare @countryAbbr varchar(4);
	Declare @PkgNm nvarchar(200);
	Declare @Lang varchar(20);
	Declare @fk_ColorUOM int;
	Declare @ColorUOM varchar(200);
	Declare @degLStart numeric(8,2);
	Declare @degLEnd numeric(8,2);
	Declare @SRM numeric(8,2);
	Declare @aka1 nvarchar(256);
	Declare @aka2 nvarchar(256);
	Declare @aka3 nvarchar(256);
	Declare @rowsz int;
	Declare @isMod bit;
	Declare @isUndr bit;
	Declare @potGravBeg numeric(5,4);
	Declare @potGravEnd numeric(5,4);
	Declare @potGravUOMID int;
	Declare @PotGravUOM varchar(50);
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
		<b:Grain_Evnt type=''{sql:variable("@evnttype")}''>
		<b:Mstr_Info/>
		</b:Grain_Evnt>
		into (/b:Burp_Belch/b:Payload)[1]');
	
	set @mesg.modify('
		declare namespace b="http://burp.net/recipe/evnts";
		insert attribute type {''grain''}
		into (/b:Burp_Belch/b:Payload)[1]
	');

	-- now get values to stuff in
	Select 
		@nm=M.[Name],
		@fk_MfrID = M.fk_GrainMfr,
		@MfrNm = Case M.fk_GrainMfr WHen 0 Then Space(0) Else MFR.Name End,
		@fk_TypeID = M.fk_GrainType,
		@TypNm = Case M.fk_GrainType When 0 then SPACE(0) Else M.GrainType End,
		@fk_CountryID = 
			Case M.fk_CountryID
			WHen 0 Then Coalesce(MFR.fk_Country,M.fk_CountryID)
			Else M.fk_CountryID
		End,
		@countryNm = 
			Case M.fk_CountryID
			when 0 THen (Select Name from [di].Countries Where RowID=MFR.fk_Country)
			Else (select Name from [di].Countries Where RowID=M.fk_CountryID)
		End,
		@countryAbbr = 
			Case M.fk_CountryID
			When 0 THen (Select Abbrev from [di].Countries WHere RowID=MFR.fk_Country)
			Else (Select Abbrev from [di].Countries Where RowID=M.fk_CountryID)
		End,
		@degLStart = ISNULL(M.degLStart, 0.0),
		@degLEnd = ISNULL(M.degLEnd, 0.0),
		@fk_ColorUOM = [bhp].fn_GetUOMIdByNm('L'),
		@ColorUOM = [bhp].fn_GetUOM([bhp].fn_GetUOMIdByNm('L')),
		@SRM = ISNULL(M.SRM, 0),
		@rowsz = ISNULL(M.RowSize, 0),
		@aka1 = Case M.KnownAs1 When 'not set' then SPACE(0) When 'n/a' Then SPaCE(0) Else ISNULL(M.KnownAs1, SPACE(0)) End,
		@aka2 = Case M.KnownAs2 When 'not set' then SPACE(0) When 'n/a' Then SPaCE(0) Else ISNULL(M.KnownAs2, SPACE(0)) End,
		@aka3 = Case M.KnownAs3 When 'not set' then SPACE(0) When 'n/a' Then SPaCE(0) Else ISNULL(M.KnownAs3, SPACE(0)) End,
		@isMod = ISNULL(M.IsModified, 0),
		@isUndr = ISNULL(M.isUnderModified, 0),
		@potGravBeg = ISNULL(M.PotentialGravityBeg, 0.0),
		@potGravEnd = ISNULL(M.PotentialGravityEnd, 0.0),
		@potGravUOMID = [bhp].fn_GetUOMIdByNm('gravity'),
		@PotGravUOM = [bhp].fn_GetUOM([bhp].fn_GetUOMIdByNm('gravity')),
		@lang=N'en_us',
		@notes = [di].fn_ToXMLNote(M.Comment)
	From [bhp].GrainMstr As M
	Inner Join [bhp].GrainManufacturers MFR on (M.fk_GrainMfr= MFR.RowID)
	--Left Join [bhp].Countries C on (MFR.fk_Country = C.RowID)
	Where (M.RowID = @id);

	-- stuff in values...
	set @mesg.modify('
		declare namespace b="http://burp.net/recipe/evnts";
		insert (
			<b:Name>{sql:variable("@nm")}</b:Name>,
			<b:MfrInfo id=''{sql:variable("@fk_MfrID")}''>{sql:variable("@MfrNm")}</b:MfrInfo>,
			<b:TypeInfo id=''{sql:variable("@fk_TypeID")}''>{sql:variable("@TypNm")}</b:TypeInfo>,
			<b:Color_Range>
				<b:Start>{sql:variable("@degLStart")}</b:Start>
				<b:End>{sql:variable("@degLEnd")}</b:End>
				<b:UOM id=''{sql:variable("@fk_ColorUOM")}''>{sql:variable("@ColorUOM")}</b:UOM>
			</b:Color_Range>,
			<b:SRM>{sql:variable("@SRM")}</b:SRM>,
			<b:RowSize>{sql:variable("@RowSz")}</b:RowSize>,
			<b:AKA1>{sql:variable("@aka1")}</b:AKA1>,
			<b:AKA2>{sql:variable("@aka2")}</b:AKA2>,
			<b:AKA3>{sql:variable("@aka3")}</b:AKA3>,
			<b:IsModified>{sql:variable("@isMod")}</b:IsModified>,
			<b:IsUnderModified>{sql:variable("@isUndr")}</b:IsUnderModified>,
			<b:CountryOfOrigin id=''{sql:variable("@fk_CountryID")}'' abbr=''{sql:variable("@countryAbbr")}''>{sql:variable("@countryNm")}</b:CountryOfOrigin>,
			<b:PotentialGravity>
				<b:Beg>{sql:variable("@potGravBeg")}</b:Beg>
				<b:End>{sql:variable("@potGravEnd")}</b:End>
				<b:UOM id=''{sql:variable("@potGravUOMID")}''>{sql:variable("@potGravUOM")}</b:UOM>
			</b:PotentialGravity>
		)
		into (/b:Burp_Belch/b:Payload/b:Grain_Evnt/b:Mstr_Info)[1]
	');

	-- stuff in any note/comment....
	set @mesg.modify('
		declare namespace b="http://burp.net/recipe/evnts";
		insert sql:variable("@notes") as last into (/b:Burp_Belch/b:Payload/b:Grain_Evnt/b:Mstr_Info)[1]
	');

	-- set the attributes on node <Info>...id (aka: rowid) and lang
	set @mesg.modify('
		declare namespace b="http://burp.net/recipe/evnts";
		insert (
			attribute id {sql:variable("@id")},
			attribute lang {sql:variable("@Lang")}
		)
		into (/b:Burp_Belch/b:Payload/b:Grain_Evnt/b:Mstr_Info)[1]
	');

	Return 0;
end
go


/*

declare @m xml;
declare @rc int;
exec @rc = [bhp].GenBurpGrainMstrMesg @id=4, @evnttype='add', @SessID=N'00000000-0000-0000-0000-000000000000', @mesg = @m output;

with xmlnamespaces('http://burp.net/recipe/evnts' as b)
select @rc [@rc], @m [the message];

*/