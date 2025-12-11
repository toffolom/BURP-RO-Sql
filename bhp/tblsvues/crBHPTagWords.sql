use [BHP1-RO]
go

if object_id(N'[bhp].BHPTagWords',N'U') is not null
begin
	drop table [bhp].BHPTagWords;
	print 'table:: [bhp].BHPTagWords dropped!!!';
end
go

Create Table [bhp].BHPTagWords (
	RowID bigint not null identity(1,1),
	[Name] nvarchar(100) not null,
	[Lang] nvarchar(20) not null,
	EnteredOn datetime null,
	Constraint PK_BHPTagWords_RowID primary key nonclustered(RowID)
);
go
print 'table:: [bhp].BHPTagWords created...';
go

create unique clustered index IDX_BHPTagWords_Name on [bhp].BHPTagWords ([Name]);
print 'uniq index created on BHPTagWords tbl...';
go

alter table [bhp].BHPTagWords add
constraint DF_BHPTagWords_Lang default(N'en_us') for [Lang],
constraint DF_BHPTagWords_EnteredOn default(getdate()) for EnteredOn;
print 'added default contraints to BHPTagWords tbl...';
go

