use [BHP1-RO]
go

if object_id(N'[bhp].GenBurpYeastMstrMesg',N'P') is not null
begin
	drop proc [bhp].GenBurpYeastMstrMesg;
	print 'proc:: [bhp].GenBurpYeastMstrMesg dropped!!!';
end
go

create proc [bhp].GenBurpYeastMstrMesg (
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
	Declare @fk_TypeID int;
	Declare @TypNm varchar(50);
	Declare @fk_PkgID int;
	Declare @fk_CountryID int;
	Declare @fk_FlocID int;
	Declare @flocNm varchar(40);
	Declare @countryNm varchar(200);
	Declare @countryAbbr varchar(4);
	Declare @PkgNm nvarchar(200);
	Declare @Lang varchar(20);
	Declare @Atten varchar(50);
	Declare @FermTempBeg tinyint;
	Declare @FermTempEnd tinyint;
	Declare @fk_FermTemp int;
	Declare @FermTempUOM varchar(50);
	Declare @aka1 nvarchar(256);
	Declare @aka2 nvarchar(256);
	Declare @aka3 nvarchar(256);
	Declare @psub1 int;
	Declare @psub1Nm nvarchar(300);
	Declare @psub2 int;
	Declare @psub2Nm nvarchar(300);
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
		<b:Yeast_Evnt type=''{sql:variable("@evnttype")}''>
		<b:Mstr_Info/>
		</b:Yeast_Evnt>
		into (/b:Burp_Belch/b:Payload)[1]');

	set @mesg.modify('
		declare namespace b="http://burp.net/recipe/evnts";
		insert attribute type {''yeast''}
		into (/b:Burp_Belch/b:Payload)[1]
	');

	-- now get values to stuff in
	Select 
		@nm=M.[Name],
		@fk_MfrID = M.fk_YeastMfr,
		@MfrNm = Case M.fk_YeastMfr WHen 0 Then Space(0) Else M.MfrNm End,
		@fk_TypeID = M.fk_YeastType,
		@TypNm = Case M.fk_YeastType When 0 then SPACE(0) Else M.YeastTypName End,
		@fk_PkgID = M.fk_YeastPkgTyp,
		@PkgNm = Case M.fk_YeastPkgTyp when 0 Then SPACE(0) Else M.PkgDescr End,
		@fk_CountryID = M.fk_CountryID,
		@countryNm = Case M.fk_CountryID WHen 0 then SPACE(0) Else C.Name End,
		@countryAbbr = Case ISNULL(M.fk_CountryID,0) When 0 Then Space(0) Else C.Abbrev End,
		@Atten = ISNULL(M.Attenuation, SPACE(0)),
		@FermTempBeg = ISNULL(M.FermTempBeg, 0),
		@FermTempEnd = ISNULL(M.FermTempEnd, 0),
		@fk_FermTemp = ISNULL(M.fk_FermTempUOM, [bhp].fn_GetUOMIdByNm('F')),
		@FermTempUOM = ISNULL(M.FermTempUOM, [bhp].fn_GetUOM([bhp].fn_GetUOMIdByNm('F'))),
		@aka1 = Case M.KnownAs1 When 'not set' then SPACE(0) When 'n/a' Then SPaCE(0) Else ISNULL(M.KnownAs1, SPACE(0)) End,
		@aka2 = Case M.KnownAs2 When 'not set' then SPACE(0) When 'n/a' Then SPaCE(0) Else ISNULL(M.KnownAs2, SPACE(0)) End,
		@aka3 = Case M.KnownAs3 When 'not set' then SPACE(0) When 'n/a' Then SPaCE(0) Else ISNULL(M.KnownAs3, SPACE(0)) End,
		@psub1 = M.PSub1,
		@psub1Nm = Case M.PSub1 WHen 0 Then SPACE(0) Else M.PSubNm1 End,
		@psub2 = M.PSub2,
		@psub2Nm = Case M.PSub2 When 0 THen SPACE(0) Else M.PSubNm2 End,
		@lang=ISNULL(M.[Lang],'en_us'),
		@notes = [di].fn_ToXMLNote(M.Notes),
		@fk_FlocID = fk_FlocculationType,
		@flocNm = F.[Name]
	From [bhp].YeastMstr As M
	Inner Join [di].Countries C on (M.fk_CountryID = C.RowID)
	Inner join [bhp].YeastFlocculationTypes F on (M.fk_FlocculationType = F.RowID)
	Where (M.RowID = @id);

	-- stuff in values...
	set @mesg.modify('
		declare namespace b="http://burp.net/recipe/evnts";
		insert (
			<b:Name>{sql:variable("@nm")}</b:Name>,
			<b:MfrInfo id=''{sql:variable("@fk_MfrID")}''>{sql:variable("@MfrNm")}</b:MfrInfo>,
			<b:TypeInfo id=''{sql:variable("@fk_TypeID")}''>{sql:variable("@TypNm")}</b:TypeInfo>,
			<b:PkgInfo id=''{sql:variable("@fk_PkgID")}''>{sql:variable("@PkgNm")}</b:PkgInfo>,
			<b:Flocculation id=''{sql:variable("@fk_FlocID")}''>{sql:variable("@FlocNm")}</b:Flocculation>,
			<b:Attenuation>{sql:variable("@Atten")}</b:Attenuation>,
			<b:Fermentation_TempRange>
			<b:Beg>{sql:variable("@FermTempBeg")}</b:Beg>
			<b:End>{sql:variable("@FermTempEnd")}</b:End>
			<b:UOM id=''{sql:variable("@fk_FermTemp")}''>{sql:variable("@FermTempUOM")}</b:UOM>
			</b:Fermentation_TempRange>,
			<b:AKA1>{sql:variable("@aka1")}</b:AKA1>,
			<b:AKA2>{sql:variable("@aka2")}</b:AKA2>,
			<b:AKA3>{sql:variable("@aka3")}</b:AKA3>,
			<b:Substitution1 id=''{sql:variable("@PSub1")}''>{sql:variable("@psub1Nm")}</b:Substitution1>,
			<b:Substitution2 id=''{sql:variable("@PSub2")}''>{sql:variable("@psub2Nm")}</b:Substitution2>,
			<b:CountryOfOrigin id=''{sql:variable("@fk_CountryID")}'' abbr=''{sql:variable("@countryAbbr")}''>{sql:variable("@countryNm")}</b:CountryOfOrigin>
		)
		into (/b:Burp_Belch/b:Payload/b:Yeast_Evnt/b:Mstr_Info)[1]
	');

	-- stuff in any note/comment....
	set @mesg.modify('
		declare namespace b="http://burp.net/recipe/evnts";
		insert sql:variable("@notes") as last into (/b:Burp_Belch/b:Payload/b:Yeast_Evnt/b:Mstr_Info)[1]
	');

	-- set the attributes on node <Info>...id (aka: rowid) and lang
	set @mesg.modify('
		declare namespace b="http://burp.net/recipe/evnts";
		insert (
			attribute id {sql:variable("@id")},
			attribute lang {sql:variable("@Lang")}
		)
		into (/b:Burp_Belch/b:Payload/b:Yeast_Evnt/b:Mstr_Info)[1]
	');

	Return 0;
end
go


/*

declare @m xml;
declare @rc int;
exec @rc = [bhp].GenBurpYeastMstrMesg @id=24, @SessID='00000000-0000-0000-0000-000000000000', @evnttype='add', @mesg = @m output;

with xmlnamespaces('http://burp.net/recipe/evnts' as b)
select @rc [@rc], @m [the message], @m.query('/b:Burp_Belch/b:Payload/b:Yeast_Evnt/b:Mstr_Info') As MstrInfo

*/