use [BHP1-RO]
go

if object_id(N'bwp.fn_GetBelchEvntPayldAction','FN') is not null
begin
	Drop function bwp.fn_GetBelchEvntPayldAction;
	print 'Func:: bwp.fn_GetBelchEvntPayldAction dropped!!!';
end
go

Create Function bwp.fn_GetBelchEvntPayldAction (
	@info xml
)
returns varchar(20) -- either 'add','chg' or 'del'
as
begin
	Declare @rtrn varchar(20);
	if (@info.exist('declare namespace p="http://burp.net/recipe/evnts";/p:Burp_Belch/p:Payload/p:Tag_Evnt') = 1)
		Set @rtrn = @info.value('declare namespace p="http://burp.net/recipe/evnts";(/p:Burp_Belch/p:Payload/p:Tag_Evnt/@type)[1]','varchar(20)');
	else if (@info.exist('declare namespace p="http://burp.net/recipe/evnts";/p:Burp_Belch/p:Payload/p:UOM_Evnt') = 1)
		Set @rtrn = @info.value('declare namespace p="http://burp.net/recipe/evnts";(/p:Burp_Belch/p:Payload/p:UOM_Evnt/@type)[1]','varchar(20)');
	else if (@info.exist('declare namespace p="http://burp.net/recipe/evnts";/p:Burp_Belch/p:Payload/p:Stage_Evnt') = 1)
		Set @rtrn = @info.value('declare namespace p="http://burp.net/recipe/evnts";(/p:Burp_Belch/p:Payload/p:Stage_Evnt/@type)[1]','varchar(20)');
	else if (@info.exist('declare namespace p="http://burp.net/recipe/evnts";/p:Burp_Belch/p:Payload/p:HopInfo_Evnt') = 1)
		Set @rtrn = @info.value('declare namespace p="http://burp.net/recipe/evnts";(/p:Burp_Belch/p:Payload/p:HopInfo_Evnt/@type)[1]','varchar(20)');
	else if (@info.exist('declare namespace p="http://burp.net/recipe/evnts";/p:Burp_Belch/p:Payload/p:Yeast_Evnt') = 1)
		Set @rtrn = @info.value('declare namespace p="http://burp.net/recipe/evnts";(/p:Burp_Belch/p:Payload/p:Yeast_Evnt/@type)[1]','varchar(20)');
	else if (@info.exist('declare namespace p="http://burp.net/recipe/evnts";/p:Burp_Belch/p:Payload/p:Grain_Evnt') = 1)
		Set @rtrn = @info.value('declare namespace p="http://burp.net/recipe/evnts";(/p:Burp_Belch/p:Payload/p:Grain_Evnt/@type)[1]','varchar(20)');
	else if (@info.exist('declare namespace p="http://burp.net/recipe/evnts";/p:Burp_Belch/p:Payload/p:Extract_Evnt') = 1)
		Set @rtrn = @info.value('declare namespace p="http://burp.net/recipe/evnts";(/p:Burp_Belch/p:Payload/p:Extract_Evnt/@type)[1]','varchar(20)');
	else if (@info.exist('declare namespace p="http://burp.net/recipe/evnts";/p:Burp_Belch/p:Payload/p:HopSched_Evnt') = 1)
		Set @rtrn = @info.value('declare namespace p="http://burp.net/recipe/evnts";(/p:Burp_Belch/p:Payload/p:HopSched_Evnt/@type)[1]','varchar(20)');
	else if (@info.exist('declare namespace p="http://burp.net/recipe/evnts";/p:Burp_Belch/p:Payload/p:AgingSched_Evnt') = 1)
		Set @rtrn = @info.value('declare namespace p="http://burp.net/recipe/evnts";(/p:Burp_Belch/p:Payload/p:AgingSched_Evnt/@type)[1]','varchar(20)');
	else if (@info.exist('declare namespace p="http://burp.net/recipe/evnts";/p:Burp_Belch/p:Payload/p:MashSched_Evnt') = 1)
		Set @rtrn = @info.value('declare namespace p="http://burp.net/recipe/evnts";(/p:Burp_Belch/p:Payload/p:MashSched_Evnt/@type)[1]','varchar(20)');
	else if (@info.exist('declare namespace p="http://burp.net/recipe/evnts";/p:Burp_Belch/p:Payload/p:Manuf_Evnt') = 1)
		Set @rtrn = @info.value('declare namespace p="http://burp.net/recipe/evnts";(/p:Burp_Belch/p:Payload/p:Manuf_Evnt/@type)[1]','varchar(20)');
	else if (@info.exist('declare namespace p="http://burp.net/recipe/evnts";/p:Burp_Belch/p:Payload/p:Recipe_Evnt') = 1)
		Set @rtrn = @info.value('declare namespace p="http://burp.net/recipe/evnts";(/p:Burp_Belch/p:Payload/p:Recipe_Evnt/@type)[1]','varchar(20)');


	return ISNULL(@rtrn,'err');
end
go

/*
declare @x xml;
Set @x = '<Burp_Belch xmlns="http://burp.net/recipe/evnts" ver="1.0" ts="2021-05-05 14:56:54" did="3B126D15-8799-48D7-863F-5C552855AB45"><Session_Src xmlns="http://burp.net/recipe/evnts" uid="604d2b30-82df-4957-a3d0-ba456367806c"><Cust custid="1001" uid="mighty@fi.net">mighty</Cust></Session_Src><Payload uid="2740D92B-730F-4938-8881-D496B0899F8A" type="uom"><UOM_Evnt type="chg"><Info id="3" lang="en_us"><Name>12oz bottle</Name><Abbr old="12oz btl">12oz btl</Abbr><IsTime>false</IsTime><IsVol>false</IsVol><IsTemp>false</IsTemp><IsContainer>true</IsContainer><IsColor>false</IsColor><IsBitter>false</IsBitter><IsWeight>false</IsWeight><IsMonetary>false</IsMonetary><MinVal>n/a</MinVal><MaxVal>n/a</MaxVal><Notes xmlns="http://burp.net/recipe/evnts"><Note nbr="1">no comment given...</Note></Notes></Info></UOM_Evnt></Payload></Burp_Belch>';
select bwp.fn_GetBelchEvntPayldAction(@x);

Set @x = '<Burp_Belch xmlns="http://burp.net/recipe/evnts" ver="1.0" ts="2021-08-26 17:03:28" did="3B126D15-8799-48D7-863F-5C552855AB45"><Session_Src xmlns="http://burp.net/recipe/evnts" uid="c3f9381a-900e-42f6-902c-87d5c1965ec2"><Cust custid="1001" uid="mighty@fi.net">mighty</Cust></Session_Src><Payload type="grain" uid="310599B8-CC76-4AA9-9584-E86AA35BDDCA"><Recipe_Evnt type="add" recipe_id="17"><Info><Creator custid="1001" uid="mighty@fi.net">mighty</Creator><Name>Ricochet</Name><IsDraft>true</IsDraft><CreatedOn>2021-08-26 17:02:30</CreatedOn></Info><Grains><Grain recid="30"><MfrInfo id="3">Weyermann</MfrInfo><Name id="58">Wheat (Red) Malt</Name><TypeInfo id="3">Wheat</TypeInfo><Qty><Amt>2</Amt><UOM id="9">lb</UOM></Qty><Stage id="9">mashing</Stage><Notes xmlns="http://burp.net/recipe/evnts"><Note nbr="1">no comment given...</Note></Notes></Grain></Grains></Recipe_Evnt></Payload></Burp_Belch>';
select bwp.fn_GetBelchEvntPayldAction(@x);
*/