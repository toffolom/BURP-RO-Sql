use [BHP1-RO]
go

If Object_ID(N'[bhp].GetBoundUOMs',N'P') IS NOT NULL
Begin
	Drop Proc [bhp].GetBoundUOMs;
	Print 'Proc:: [bhp].GetBoundUOMs Dropped!!!';
End
Go

/*
** This proc will dynamically crawl the referencial integrity constraints installed and return a list of values that are currently used, or bound, to referenced table/cols.
*/
Create Proc [bhp].GetBoundUOMs (
	@SessID varchar(256),
	@IncludeUnBound bit = 0 -- set to (1) if you want to include in result set uom's that are not bound, or in use yet...
)
with encryption, execute as 'sticky'
as
Begin
	declare @sql nvarchar(max);
	Declare @rc int;
	Declare @mesg nvarchar(2000);
	Declare @status bit;

	--Set NoCount On;

	if (1=0)
	begin
		select 
			cast(null as int) as RowID, 
			cast(null as nvarchar(100)) as [Name], 
			cast(null as varchar(50)) as UOM, 
			cast(null as int) as TotRefs
		Set fmtonly off;
		return;
	end

	Exec @rc = [di].[IsSessStale] @SessID=@SessID, @status=@status output, @Mesgs=@mesg output, @UpdLst=1;

	If (@rc != 0 or @status != 0)
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66006; -- this nbr represents users is not logged in.
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	Select @sql = ISNULL(@sql + char(10) + N'UNION ALL' + char(10),'') + N'select U.RowID, U.Name, U.UOM from [bhp].vw_UOMTypes U Inner Join [bhp].' + OBJECT_NAME(fkc.parent_object_id) + N' As X On (U.RowID = X.' + c.[Name] + N' And U.RowID > 0)'
	From sys.foreign_key_columns fkc
	Inner join sys.columns c on (fkc.parent_object_id = c.object_id and c.column_id = fkc.parent_column_id)
	Where fkc.referenced_object_id = OBJECT_ID(N'[bhp].UOMTypes',N'U')
	Order By fkc.parent_object_id;

	If (@IncludeUnBound = 0)
	Begin

		select @sql = N'
select XX.RowID, XX.Name, XX.UOM, Count(*) As TotRefs from 
(
' + @sql + N'
) As XX Group By XX.RowID, XX.Name, XX.UOM Order By Name;'

	End
	Else
	Begin
		Select @sql = N'
Set NoCount on;
Select XX.RowID, XX.Name, XX.UOM, Count(*) As TotRefs
Into #Foo
From (' + char(10) + @sql + char(10) + N') As XX Group By XX.RowID, XX.Name, XX.UOM;

select RowID, Name, UOM, TotRefs from #Foo
union all
select RowID, Name, UOM, 0 As TotRefs
from [bhp].UOMTypes Where (RowID Not In (Select RowID from #Foo) and RowID > 0)
Order By 2;

';
	End
	--raiserror('%s',0,1,@sql);
	Exec @rc = [dbo].sp_ExecuteSql @Stmt=@Sql;

	Return @rc;
End
go