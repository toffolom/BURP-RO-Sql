use [BHP1-RO]
go

if object_id(N'[bhp].GenRecipeCreatorMesg',N'P') is not null
begin
	drop proc [bhp].GenRecipeCreatorMesg;
	print 'proc:: [bhp].GenRecipeCreatorMesg dropped!!!';
end
go

create proc [bhp].GenRecipeCreatorMesg (
	@rid int, -- a recipe id value from RecipeJrnlMstr tbl
	@evnttype varchar(10), -- must be one of 'add','chg','del'
	@sessid varchar(256),
	@mesg xml output
)
with encryption
as
begin
	Declare @CustID bigint;
	Declare @CustNm nvarchar(256);
	Declare @name varchar(256);
	Declare @isDraft bit;
	Declare @Lang varchar(20);
	Declare @SessSrc xml;
	Declare @uid nvarchar(256);
	Declare @ts varchar(50);

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
		</b:Recipe_Evnt>
		into (/b:Burp_Belch/b:Payload)[1]');

	set @mesg.modify('
		declare namespace b="http://burp.net/recipe/evnts";
		insert attribute type {''creator''}
		into (/b:Burp_Belch/b:Payload)[1]
	');

	-- now get values to stuff in

	Select 
		@name = M.[Name],
		@isDraft = ISNULL(M.isDraft, 1),
		@CustID = M.fk_CreatedBy,
		@CustNm = C.[Name],
		@uid = C.[BHPUid],
		@ts = [di].fn_Timestamp(M.EnteredOn)
	From [bhp].RecipeJrnlMstr M Inner Join [di].vw_CustomerMstr C On (M.fk_CreatedBy = C.RowID)
	Where (M.RowID = @rid);

	-- stuff in values...
	set @mesg.modify('
		declare namespace b="http://burp.net/recipe/evnts";
		insert (
			<b:Creator_Info custid=''{sql:variable("@CustID")}'' uid=''{sql:variable("@uid")}''>{sql:variable("@CustNm")}</b:Creator_Info>
		)
		as last into (/b:Burp_Belch/b:Payload/b:Recipe_Evnt)[1]
	');

	set @mesg.modify('
		declare namespace b="http://burp.net/recipe/evnts";
		insert (
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
exec @rc = [bhp].GenRecipeCreatorMesg @rid=9, @evnttype='add', @SessID=N'00000000-0000-0000-0000-000000000000', @mesg = @m output;
with xmlnamespaces('http://burp.net/recipe/evnts' as b, default 'http://burp.net/recipe/evnts')
select @rc [@rc], @m [the message];

*/