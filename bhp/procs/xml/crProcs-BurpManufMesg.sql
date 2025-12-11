use [BHP1-RO]
go

if object_id(N'[bhp].GenBurpMfrInfoMesg',N'P') is not null
begin
	drop proc [bhp].GenBurpMfrInfoMesg;
	print 'proc:: [bhp].GenBurpMfrInfoMesg dropped!!!';
end
go

create proc [bhp].GenBurpMfrInfoMesg (
	@mfrid int, -- a rowid value from one of the mfr tables
	@mfrtype varchar(20), -- must be either 'hop','grain','yeast' or 'extract'!!!
	@evnttype varchar(10), -- must be one of 'add','chg','del'
	@SessID varchar(256),
	@mesg xml output
)
with encryption, execute as 'sticky'
as
begin
	Declare @sql nvarchar(max);
	Declare @tblnm sysname;
	Declare @found bit;
	Declare @nm varchar(300);
	declare @w3c nvarchar(2000);
	Declare @countryid int;
	declare @abbr varchar(40);
	declare @countrynm varchar(200);
	Declare @Lang varchar(20);
	Declare @colNm sysname; -- some of the manuf tbls might have a comments/notes column...
	Declare @notes xml; -- holds any notes/comments. eg: <Notes><Note nbr='int'>string</Note><Notes>...
	Declare @SessSrc xml;


	if (@mfrtype not in ('hop','grain','yeast','extract'))
	begin
		Raiserror(N'unknown value for param:[@mfrtype]!? Must be:[''hop'',''grain'',''yeast'',''extract'']...',16,1);
		Return -1;
	end

	Set @tblnm = 
	case left(@mfrtype,1)
	when 'h' then '[bhp].[HopManufacturers]'
	when 'y' then '[bhp].[YeastManufacturers]'
	when 'g' then '[bhp].[GrainManufacturers]'
	when 'e' then '[bhp].[ExtractManufacturers]'
	end

	Set @sql = N'
set @outfound=0;
if exists (select 1 from ' + @tblnm + ' where (RowID=@InRowID))
	set @outfound=1;
';

	exec [dbo].sp_ExecuteSql @Stmt=@sql, @Params=N'@InRowID int, @outfound bit output', @InRowID=@mfrid, @outfound=@found output;

	if (@found = 0)
	begin
		Raiserror(N'Unable to find manuf type:[%s] w/id:[%d]...aborting!!!',16,1,@mfrtype,@mfrid);
		Return -1;
	end

	Set @sql = N'
Select @outColNm=[Name] from sys.columns where object_id(@inTblNm,N''U'') = object_id and ([name] like ''comment%'' or name like ''note%'')
';

	Exec [dbo].sp_ExecuteSql @Stmt=@Sql, @Params=N'@inTblNm sysname, @outColNm sysname output', @inTblNm=@TblNm, @outColNm=@colNm output;

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
		<b:Manuf_Evnt type=''{sql:variable("@evnttype")}''>
		<b:Info/>
		</b:Manuf_Evnt>
		into (/b:Burp_Belch/b:Payload)[1]');

	set @mesg.modify('
		declare namespace b="http://burp.net/recipe/evnts";
		insert attribute type {''manuf_info''}
		into (/b:Burp_Belch/b:Payload)[1]
	');

	-- now get values to stuff in
	set @sql = N'
Select 
	@outnm=M.[Name],
	@outw3c=ISNULL(M.[W3C],''http://''),
	@outlang=ISNULL(M.[Lang],''en_us''),
	@outcountryid=M.[fk_Country],
	@outcountrynm=C.[Name],
	@outabbr=ISNULL(C.[Abbrev],''n/a''),
	@outnotes=[di].fn_ToXMLNote(' + case when @colNm is null then '''no comment given...''' else 'M.' + @colNm end + ')
From ' + @tblnm + ' As M
Inner Join [di].Countries C On (M.fk_Country = C.RowID)
Where (M.RowID = @InRowID);
';

	exec [dbo].sp_ExecuteSql
		@Stmt=@sql,
		@Params = N'@InRowID int, 
				@outnm varchar(300) output, 
				@outw3c nvarchar(2000) output, 
				@outlang varchar(40) output, 
				@outcountryid int output,
				@outcountrynm varchar(200) output,
				@outabbr varchar(30) output,
				@outnotes xml output',
		@InRowID = @mfrid,
		@outnm = @nm output,
		@outw3c = @w3c output,
		@outlang = @Lang output,
		@outcountryid = @countryid output,
		@outcountrynm = @countrynm output,
		@outabbr = @abbr output,
		@outnotes = @notes output;

	-- stuff in values...
	set @mesg.modify('
		declare namespace b="http://burp.net/recipe/evnts";
		insert (
			<b:Name>{sql:variable("@nm")}</b:Name>,
			<b:Country id=''{sql:variable("@countryid")}'' abbr=''{sql:variable("@abbr")}''>{sql:variable("@countrynm")}</b:Country>,
			<b:W3C>{sql:variable("@w3c")}</b:W3C>
		)
		into (/b:Burp_Belch/b:Payload/b:Manuf_Evnt/b:Info)[1]
	');
	-- stuff in any note/comment....
	set @mesg.modify('
		declare namespace b="http://burp.net/recipe/evnts";
		insert sql:variable("@notes") as last into (/b:Burp_Belch/b:Payload/b:Manuf_Evnt/b:Info)[1]
	');

	-- set the attributes on node <Info>...id (aka: rowid) and lang
	set @mesg.modify('
		declare namespace b="http://burp.net/recipe/evnts";
		insert (
			attribute id {sql:variable("@mfrid")},
			attribute lang {sql:variable("@Lang")},
			attribute type {sql:variable("@mfrtype")}
		)
		into (/b:Burp_Belch/b:Payload/b:Manuf_Evnt/b:Info)[1]
	');

	Return 0;
end
go


/*

declare @m xml;
declare @rc int;
exec @rc = [bhp].GenBurpMfrInfoMesg @SessID='00000000-0000-0000-0000-000000000000', @mfrid=2, @mfrtype='grain', @evnttype='add', @mesg = @m output;

with xmlnamespaces('http://burp.net/recipe/evnts' as b, default 'http://burp.net/recipe/evnts')
select @rc [@rc], @m [the message];

*/