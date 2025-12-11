use [BHP1-RO]
go

If Object_ID(N'[bhp].GetBoundYeasts',N'P') IS NOT NULL
Begin
	Drop Proc [bhp].GetBoundYeasts;
	Print 'Proc:: [bhp].GetBoundYeasts Dropped!!!';
End
Go

/*
** This proc will dynamically crawl the referencial integrity constraints installed and return a list of values that are currently used, or bound, to referenced table/cols.
*/
/*
** use this guid for testing...
** '00000000-0000-0000-0000-000000000000'
*/
Create Proc [bhp].GetBoundYeasts (
	@SessID varchar(256),
	@IncludeUnBound bit = 0 -- set to (1) if you want to include in result set Stage's that are not bound, or not in use yet...
)
with encryption, execute as 'sticky'
as
Begin
	declare @sql nvarchar(max);
	Declare @rc int;
	Declare @mesg nvarchar(2000);
	Declare @status bit;

	If (1=0)
	Begin
		Select
			cast(null as int) As RowID,
			cast(null as nvarchar(256)) As [Name],
			cast(null as int) As TotRefs;
		Set FmtOnly Off;
		Return 0;
	End

	Exec @rc = [di].[IsSessStale] @SessID=@SessID, @Status=@Status output, @Mesgs=@Mesg output, @UpdLst=1;

	If (@rc != 0 or @status != 0)
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66006; -- this nbr represents users is not logged in.
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	Select @sql = ISNULL(@sql + char(10) + N'UNION ALL' + char(10),'') + N'select U.RowID, U.Name from [bhp].YeastMstr U Inner Join [bhp].' + OBJECT_NAME(fkc.parent_object_id) + N' As X On (U.RowID = X.' + c.[Name] + N' And U.RowID > 0)'
	From sys.foreign_key_columns fkc
	Inner join sys.columns c on (fkc.parent_object_id = c.object_id and c.column_id = fkc.parent_column_id)
	Where fkc.referenced_object_id = OBJECT_ID(N'[bhp].YeastMstr',N'U')
	Order By fkc.parent_object_id;

	If (@IncludeUnBound = 0)
	Begin

		select @sql = N'select XX.RowID, XX.Name, Count(*) As TotRefs from (' + char(10) + @sql + char(10) + N') As XX Group By XX.RowID, XX.Name Order By Name;'

	End
	Else
	Begin
		Select @sql = N'
Set NoCount on;
Select XX.RowID, XX.Name, Count(*) As TotRefs
Into #Foo
From (' + char(10) + @sql + char(10) + N') As XX Group By XX.RowID, XX.Name;

select RowID, Name, TotRefs from #Foo
union all
select Y.RowID, Y.Name, 0 As TotRefs
From [bhp].YeastMstr Y Left Join #Foo F On (Y.RowID = F.RowID)
WHere (F.RowID IS NULL And Y.RowID > 0)
Order By 2;

';
	End
	--print @sql;
	Exec @rc = [dbo].sp_ExecuteSql @Stmt=@Sql;

	Return @rc;
End
go