use [BHP1-RO]
go

if object_id(N'[bhp].GenBurpStageTypeMesg',N'P') is not null
begin
	drop proc [bhp].GenBurpStageTypeMesg;
	print 'proc:: [bhp].GenBurpStageTypeMesg dropped!!!';
end
go

create proc [bhp].GenBurpStageTypeMesg (
	@id int, -- a rowid value mash types master table ([bhp].MashTypeMstr)
	@evnttype varchar(10), -- must be one of 'add','chg','del'
	@SessID varchar(256),
	@mesg xml output
)
with encryption, execute as 'sticky'
as
begin
	Declare @sql nvarchar(max);
	Declare @nm nvarchar(100);
	Declare @aka1 nvarchar(100);
	Declare @aka2 nvarchar(100);
	Declare @aka3 nvarchar(100);
	Declare @allowInHop bit;
	Declare @allowInYeast bit;
	Declare @allowInMash bit;
	Declare @allowInAging bit;
	Declare @Lang varchar(20);
	Declare @notes xml; -- holds any notes/comments. eg: <Notes><Note nbr='int'>string</Note><Notes>...
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
		<b:Stage_Evnt type=''{sql:variable("@evnttype")}''>
		<b:Info/>
		</b:Stage_Evnt>
		into (/b:Burp_Belch/b:Payload)[1]');

	set @mesg.modify('
		declare namespace b="http://burp.net/recipe/evnts";
		insert attribute type {''stage''}
		into (/b:Burp_Belch/b:Payload)[1]
	');

	-- now get values to stuff in
	set @sql = N'
Select 
	@outnm=M.[Name],
	@outaka1=ISNULL(M.[AKA1],SPACE(0)),
	@outaka2=ISNULL(M.[AKA2],SPACE(0)),
	@outaka3=ISNULL(M.[AKA3],SPACE(0)),
	@outAllowInHop=ISNULL(M.[AllowedInHopSched],0),
	@outAllowInYeast=ISNULL(M.[AllowedInYeastSched],0),
	@outAllowInMash=ISNULL(M.[AllowedInMashSched],0),
	@outAllowInAging=ISNULL(M.[AllowedInAgingSched],0),
	@outnotes=[di].fn_ToXMLNote(M.[Comment]),
	@outLang=N''en_us''
From [bhp].StageTypes As M
Where (M.RowID = @InRowID);
';

	exec [dbo].sp_ExecuteSql
		@Stmt=@sql,
		@Params = N'@InRowID int, 
				@outnm nvarchar(100) output, 
				@outaka1 nvarchar(100) output, 
				@outaka2 nvarchar(100) output, 
				@outaka3 nvarchar(100) output, 
				@outAllowInHop bit output,
				@outAllowInYeast bit output,
				@outAllowInMash bit output,
				@outAllowInAging bit output,
				@outnotes xml output,
				@outlang varchar(20) output',
		@InRowID = @id,
		@outnm = @nm output,
		@outaka1 = @aka1 output,
		@outaka2 = @aka2 output,
		@outaka3 = @aka3 output,
		@outAllowInHop = @allowInHop output,
		@outAllowInYeast = @allowInYeast output,
		@outAllowInMash = @allowInMash output,
		@outAllowInAging = @allowInAging output,
		@outLang = @lang output,
		@outnotes = @notes output;

	-- stuff in values...
	set @mesg.modify('
		declare namespace b="http://burp.net/recipe/evnts";
		insert (
			<b:Name>{sql:variable("@nm")}</b:Name>,
			<b:AKA1>{sql:variable("@aka1")}</b:AKA1>,
			<b:AKA2>{sql:variable("@aka2")}</b:AKA2>,
			<b:AKA3>{sql:variable("@aka3")}</b:AKA3>,
			<b:AllowInHopSched>{sql:variable("@allowInHop")}</b:AllowInHopSched>,
			<b:AllowInYeastSched>{sql:variable("@allowInYeast")}</b:AllowInYeastSched>,
			<b:AllowInMashSched>{sql:variable("@allowInMash")}</b:AllowInMashSched>,
			<b:AllowInAgingSched>{sql:variable("@allowInAging")}</b:AllowInAgingSched>
		)
		into (/b:Burp_Belch/b:Payload/b:Stage_Evnt/b:Info)[1]
	');

	-- stuff in any note/comment....
	set @mesg.modify('
		declare namespace b="http://burp.net/recipe/evnts";
		insert sql:variable("@notes") as last into (/b:Burp_Belch/b:Payload/b:Stage_Evnt/b:Info)[1]
	');

	-- set the attributes on node <Info>...id (aka: rowid) and lang
	set @mesg.modify('
		declare namespace b="http://burp.net/recipe/evnts";
		insert (
			attribute id {sql:variable("@id")},
			attribute lang {sql:variable("@Lang")}
		)
		into (/b:Burp_Belch/b:Payload/b:Stage_Evnt/b:Info)[1]
	');

	Return 0;
end
go


/*

declare @m xml;
declare @rc int;
exec @rc = [bhp].GenBurpStageTypeMesg @id=25, @SessID='00000000-0000-0000-0000-000000000000', @evnttype='add', @mesg = @m output;

with xmlnamespaces('http://burp.net/recipe/evnts' as b, default 'http://burp.net/recipe/evnts')
select @rc [@rc], @m [the message];

*/