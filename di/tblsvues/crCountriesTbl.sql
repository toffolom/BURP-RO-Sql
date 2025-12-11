use [BHP1-RO]
go

begin try
	Drop Table [di].Countries;
	print 'table:: [di].Countries dropped!!!';
end try
begin catch
	Print 'table:: [di].Countries doesn''t exist...';
end catch
go

begin try
	Drop View [di].vw_Countries;
	print 'view:: [di].vw_Countries dropped!!!';
end try
begin catch
	Print 'view:: [di].vw_Countries doesn''t exist...';
end catch
go

Create Table [di].Countries (
	RowID int identity(1,1),
	Name varchar(200),
	Abbrev varchar(4) null,
	Constraint PK_Countries_RowID Primary Key NonClustered(RowID)
)
go

set identity_insert [di].Countries On;
insert into [di].Countries (RowID, Name, Abbrev) Values (0,'pls select...','pls');
set identity_insert [di].Countries Off;
go

insert into [di].Countries (Name, Abbrev)
values 
	('United States', 'US'),
	('United Kingdom', 'UK'),
	('Germany','DE'),
	('Belguim', 'BE'),
	('Czechoslovakia','CZ'),
	('Cananda','CA'),
	('Netherlands', 'NZ'),
	('Poland', 'PO'),
	('Australia','AU'),
	('New Zealand','NZ'),
	('Slovenia','SI'),
	('France','FR');

go



create trigger [di].Countries_Del_99 on [di].Countries
with encryption
for delete
as
begin
	If Exists (Select * from deleted where RowID = 0)
	Begin
		Raiserror(N'ERROR: zero row cannot be removed...aborting!!!',16,1);
		Rollback Transaction;
	End
end
go

Create View [di].vw_Countries (
	RowID, [Name], [Abbreviation]
)
--with encryption
as
	select RowID, Name, Abbrev from [di].Countries;
go