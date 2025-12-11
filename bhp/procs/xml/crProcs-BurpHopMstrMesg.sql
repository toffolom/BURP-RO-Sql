use [BHP1-RO]
go

if object_id(N'[bhp].GenBurpHopMstrMesg',N'P') is not null
begin
	drop proc [bhp].GenBurpHopMstrMesg;
	print 'proc:: [bhp].GenBurpHopMstrMesg dropped!!!';
end
go

create proc [bhp].GenBurpHopMstrMesg (
	@id int, -- a rowid value
	@evnttype varchar(10), -- must be one of 'add','chg','del'
	@SessID varchar(256),
	@mesg xml output
)
with encryption
as
begin
	Declare @nm nvarchar(100);
	Declare @aka nvarchar(100);
	declare @fk_MfrID int;
	Declare @MfrNm nvarchar(300);
	Declare @fk_CountryID int;
	Declare @countryNm varchar(200);
	Declare @countryAbbr varchar(4);
	Declare @Lang varchar(20);
	Declare @aal numeric(5,2); -- alpha acid
	Declare @aah numeric(5,2);
	Declare @bal numeric(5,2); -- beta acid
	Declare @bah numeric(5,2);
	--Declare @IBU numeric(5,2);
	Declare @aka1 nvarchar(100);
	Declare @aka2 nvarchar(100);
	Declare @aka3 nvarchar(100);
	Declare @aka4 nvarchar(100);
	Declare @aka5 nvarchar(100);
	Declare @aka1_id int;
	Declare @aka2_id int;
	Declare @aka3_id int;
	Declare @aka4_id int;
	Declare @aka5_id int;
	Declare @isPellet bit;
	Declare @isFlower bit;
	Declare @isOil bit;
	Declare @isHome bit;
	Declare @isExtract bit;
	Declare @notes xml;
	Declare @aaUOM_Id int;
	Declare @aaUOM_Nm varchar(50);
	Declare @betaUOM_Id int;
	Declare @betaUOM_Nm varchar(50);
	Declare @purposeID int;
	Declare @purposeDesc varchar(50);
	Declare @SessSrc xml;
	Declare @Sub1MfrID int;
	Declare @Sub2MfrID int;
	Declare @Sub3MfrID int;
	Declare @Sub4MfrID int;
	Declare @Sub5MfrID int;
	Declare @Sub1MfrNm nvarchar(300);
	Declare @Sub2MfrNm nvarchar(300);
	Declare @Sub3MfrNm nvarchar(300);
	Declare @Sub4MfrNm nvarchar(300);
	Declare @Sub5MfrNm nvarchar(300);


	-- create our stub root node.
	Begin Try
		Exec [bhp].GenBurpBelchRootNode @SessID=@SessID, @Mesg=@Mesg output;
	End Try
	Begin Catch
		Return -1;
	End Catch

	-- now adding our appropriate nodes for this message...
	set @mesg.modify('
		declare namespace b="http://burp.net/recipe/evnts";
		insert 
		<b:HopInfo_Evnt type=''{sql:variable("@evnttype")}''>
		<b:Mstr_Info/>
		</b:HopInfo_Evnt>
		into (/b:Burp_Belch/b:Payload)[1]');

	set @mesg.modify('
		declare namespace b="http://burp.net/recipe/evnts";
		insert attribute type {''hop''}
		into (/b:Burp_Belch/b:Payload)[1]
	');

	-- now get values to stuff in
	Select 
		@nm=H.[Name],
		@aka = case H.AKA When 'not set' then SPACE(0) Else ISNULL(H.AKA, SPACE(0)) End,
		@fk_MfrID = H.fk_HopMfrID,
		@MfrNm = Case H.fk_HopMfrID WHen 0 Then Space(0) Else H.HopMfrNm End,
		@fk_CountryID = H.fk_CountryID,
		@countryNm = Case ISNULL(H.fk_CountryID,0) When 0 Then SPACE(0) Else C.Name End,
		@countryAbbr = Case ISNULL(H.fk_CountryID,0) When 0 Then Space(0) Else C.Abbrev End,
		@aal = ISNULL(H.AlphaAcidLow, 0.0),
		@aah = ISNULL(H.AlphaAcidHigh, 0.0),
		@bal = ISNULL(H.BetaAcidLow, 0.0),
		@bah = ISNULL(H.BetaAcidHigh, 0.0),
		@aaUOM_Id = [bhp].fn_GetUOMIdByNm('AA'),
		@aaUOM_Nm = [bhp].fn_GetUOM([bhp].fn_GetUOMIdByNm('AA')),
		@betaUOM_Id = [bhp].fn_GetUOMIdByNm('beta'),
		@betaUOM_Nm = [bhp].fn_GetUOM([bhp].fn_GetUOMIdByNm('beta')),
		@isPellet = ISNULL(H.Pellet, 0),
		@isFlower = ISNULL(H.Flower, 0),
		@isOil = ISNULL(H.isOil, 0),
		@isExtract = ISNULL(H.isExtract, 0),
		@isHome = ISNULL(H.HomeGrwn, 0),
		--@IBU = ISNULL(H.IBU, 0),
		@aka1_id = ISNULL(H.PSub1,0),
		@aka2_id = ISNULL(H.PSub2,0),
		@aka3_id = ISNULL(H.PSub3,0),
		@aka4_id = ISNULL(H.PSub4,0),
		@aka5_id = ISNULL(H.PSub5,0),
		@aka1 = Case ISNULL(H.PSub1,0) When 0 then SPACE(0) Else ISNULL(H.PSub1Nm, SPACE(0)) End,
		@aka2 = Case ISNULL(H.PSub2,0) When 0 then SPACE(0) Else ISNULL(H.PSub2Nm, SPACE(0)) End,
		@aka3 = Case ISNULL(H.PSub3,0) When 0 then SPACE(0) Else ISNULL(H.PSub3Nm, SPACE(0)) End,
		@aka4 = Case ISNULL(H.PSub4,0) When 0 then SPACE(0) Else ISNULL(H.PSub4Nm, SPACE(0)) End,
		@aka5 = Case ISNULL(H.PSub5,0) When 0 then SPACE(0) Else ISNULL(H.PSub5Nm, SPACE(0)) End,
		@lang = ISNULL(H.[Lang], N'en_us'),
		@purposeID = ISNULL(H.fk_HopPurposeID,0),
		@purposeDesc = [bhp].fn_GetHopPurposeStr(case when H.fk_HopPurposeID is null then 0 else H.fk_HopPurposeID end),
		@notes = [di].fn_ToXMLNote(H.Commentary),
		@Sub1MfrID = case ISNULL(H.PSub1,0) 
			When 0 then 0
			else
				(
				Select Top (1) M1.RowID 
				from [bhp].HopManufacturers M1 
				Inner Join [bhp].HopTypesV2 H1 On (H1.RowID = H.PSub1)
				Where (M1.RowID = H1.fk_HopMfrID)
				)
			end,
		@Sub1MfrNm = case ISNULL(H.PSub1,0) 
			When 0 then SPACE(0)
			else
				(
				Select Top (1) M1.[Name] 
				from [bhp].HopManufacturers M1 
				Inner Join [bhp].HopTypesV2 H1 On (H1.RowID = H.PSub1)
				Where (M1.RowID = H1.fk_HopMfrID)
				)
			end,
		@Sub2MfrID = case ISNULL(H.PSub2,0) 
			When 0 then 0
			else
				(
				Select Top (1) M2.RowID 
				from [bhp].HopManufacturers M2 
				Inner Join [bhp].HopTypesV2 H2 On (H2.RowID = H.PSub2)
				Where (M2.RowID = H2.fk_HopMfrID)
				)
			end,
		@Sub2MfrNm = case ISNULL(H.PSub2,0) 
			When 0 then SPACE(0)
			else
				(
				Select Top (1) M2.[Name] 
				from [bhp].HopManufacturers M2 
				Inner Join [bhp].HopTypesV2 H2 On (H2.RowID = H.PSub2)
				Where (M2.RowID = H2.fk_HopMfrID)
				)
			end,
		@Sub3MfrID = case ISNULL(H.PSub3,0) 
			When 0 then 0
			else
				(
				Select Top (1) M3.RowID 
				from [bhp].HopManufacturers M3 
				Inner Join [bhp].HopTypesV2 H3 On (H3.RowID = H.PSub3)
				Where (M3.RowID = H3.fk_HopMfrID)
				)
			end,
		@Sub3MfrNm = case ISNULL(H.PSub3,0) 
			When 0 then SPACE(0)
			else
				(
				Select Top (1) M3.[Name] 
				from [bhp].HopManufacturers M3 
				Inner Join [bhp].HopTypesV2 H3 On (H3.RowID = H.PSub3)
				Where (M3.RowID = H3.fk_HopMfrID)
				)
			end,
		@Sub4MfrID = case ISNULL(H.PSub4,0) 
			When 0 then 0
			else
				(
				Select Top (1) M4.RowID 
				from [bhp].HopManufacturers M4 
				Inner Join [bhp].HopTypesV2 H4 On (H4.RowID = H.PSub4)
				Where (M4.RowID = H4.fk_HopMfrID)
				)
			end,
		@Sub4MfrNm = case ISNULL(H.PSub4,0) 
			When 0 then SPACE(0)
			else
				(
				Select Top (1) M4.[Name] 
				from [bhp].HopManufacturers M4 
				Inner Join [bhp].HopTypesV2 H4 On (H4.RowID = H.PSub4)
				Where (M4.RowID = H4.fk_HopMfrID)
				)
			end,
		@Sub5MfrID = case ISNULL(H.PSub5,0) 
			When 0 then 0
			else
				(
				Select Top (1) M5.RowID 
				from [bhp].HopManufacturers M5 
				Inner Join [bhp].HopTypesV2 H5 On (H5.RowID = H.PSub5)
				Where (M5.RowID = H5.fk_HopMfrID)
				)
			end,
		@Sub5MfrNm = case ISNULL(H.PSub5,0) 
			When 0 then SPACE(0)
			else
				(
				Select Top (1) M5.[Name]
				from [bhp].HopManufacturers M5 
				Inner Join [bhp].HopTypesV2 H5 On (H5.RowID = H.PSub5)
				Where (M5.RowID = H5.fk_HopMfrID)
				)
			end
	From [bhp].HopTypesV2 As H
	Left Join [di].Countries C on (ISNULL(H.fk_CountryID,0) = C.RowID)
	Where (H.RowID = @id);

	-- stuff in values...
	set @mesg.modify('
		declare namespace b="http://burp.net/recipe/evnts";
		insert (
			<b:Name>{sql:variable("@nm")}</b:Name>,
			<b:AKA>{sql:variable("@aka")}</b:AKA>,
			<b:MfrInfo id=''{sql:variable("@fk_MfrID")}''>{sql:variable("@MfrNm")}</b:MfrInfo>,
			<b:AlphaAcidInfo>
			<b:Low>{sql:variable("@aal")}</b:Low>
			<b:High>{sql:variable("@aah")}</b:High>
			<b:UOM id=''{sql:variable("@aaUOM_Id")}''>{sql:variable("@aaUOM_Nm")}</b:UOM>
			</b:AlphaAcidInfo>,
			<b:BetaAcidInfo>
			<b:Low>{sql:variable("@bal")}</b:Low>
			<b:High>{sql:variable("@bah")}</b:High>
			<b:UOM id=''{sql:variable("@betaUOM_Id")}''>{sql:variable("@betaUOM_Nm")}</b:UOM>
			</b:BetaAcidInfo>,
			<b:IsPellet>{sql:variable("@isPellet")}</b:IsPellet>,
			<b:IsFlower>{sql:variable("@isFlower")}</b:IsFlower>,
			<b:IsOil>{sql:variable("@IsOil")}</b:IsOil>,
			<b:IsExtract>{sql:variable("@IsExtract")}</b:IsExtract>,
			<b:IsHomeGrown>{sql:variable("@isHome")}</b:IsHomeGrown>,
			<b:Substitute1>
				<b:Mstr_Info id=''{sql:variable("@aka1_id")}'' lang=''{sql:variable("@Lang")}''>
					<b:Name>{sql:variable("@aka1")}</b:Name>
					<b:MfrInfo id=''{sql:variable("@Sub1MfrID")}''>{sql:variable("@Sub1MfrNm")}</b:MfrInfo>
				</b:Mstr_Info>
			</b:Substitute1>,
			<b:Substitute2>
				<b:Mstr_Info id=''{sql:variable("@aka2_id")}'' lang=''{sql:variable("@Lang")}''>
					<b:Name>{sql:variable("@aka2")}</b:Name>
					<b:MfrInfo id=''{sql:variable("@Sub2MfrID")}''>{sql:variable("@Sub2MfrNm")}</b:MfrInfo>
				</b:Mstr_Info>
			</b:Substitute2>,
			<b:Substitute3>
				<b:Mstr_Info id=''{sql:variable("@aka3_id")}'' lang=''{sql:variable("@Lang")}''>
					<b:Name>{sql:variable("@aka3")}</b:Name>
					<b:MfrInfo id=''{sql:variable("@Sub3MfrID")}''>{sql:variable("@Sub3MfrNm")}</b:MfrInfo>
				</b:Mstr_Info>
			</b:Substitute3>,
			<b:Substitute4>
				<b:Mstr_Info id=''{sql:variable("@aka4_id")}'' lang=''{sql:variable("@Lang")}''>
					<b:Name>{sql:variable("@aka4")}</b:Name>
					<b:MfrInfo id=''{sql:variable("@Sub4MfrID")}''>{sql:variable("@Sub4MfrNm")}</b:MfrInfo>
				</b:Mstr_Info>
			</b:Substitute4>,
			<b:Substitute5>
				<b:Mstr_Info id=''{sql:variable("@aka5_id")}'' lang=''{sql:variable("@Lang")}''>
					<b:Name>{sql:variable("@aka5")}</b:Name>
					<b:MfrInfo id=''{sql:variable("@Sub5MfrID")}''>{sql:variable("@Sub5MfrNm")}</b:MfrInfo>
				</b:Mstr_Info>
			</b:Substitute5>,
			<b:CountryOfOrigin id=''{sql:variable("@fk_CountryID")}'' abbr=''{sql:variable("@countryAbbr")}''>{sql:variable("@countryNm")}</b:CountryOfOrigin>,
			<b:Purpose id=''{sql:variable("@purposeID")}''>{sql:variable("@purposeDesc")}</b:Purpose>
		)
		into (/b:Burp_Belch/b:Payload/b:HopInfo_Evnt/b:Mstr_Info)[1]
	');

	-- stuff in any note/comment....
	set @mesg.modify('
		declare namespace b="http://burp.net/recipe/evnts";
		insert sql:variable("@notes") as last into (/b:Burp_Belch/b:Payload/b:HopInfo_Evnt/b:Mstr_Info)[1]
	');

	-- set the attributes on node <Info>...id (aka: rowid) and lang
	set @mesg.modify('
		declare namespace b="http://burp.net/recipe/evnts";
		insert (
			attribute id {sql:variable("@id")},
			attribute lang {sql:variable("@Lang")}
		)
		into (/b:Burp_Belch/b:Payload/b:HopInfo_Evnt/b:Mstr_Info)[1]
	');

	Return 0;
end
go


/*

declare @m xml;
declare @rc int;
exec @rc = [bhp].GenBurpHopMstrMesg @id=31, @SessID='00000000-0000-0000-0000-000000000000', @evnttype='add', @mesg = @m output;

with xmlnamespaces('http://burp.net/recipe/evnts' as b)
select @rc [@rc], @m [the message];

*/