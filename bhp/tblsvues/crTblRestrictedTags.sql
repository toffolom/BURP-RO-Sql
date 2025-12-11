use [BHP1-RO]
go

if object_id(N'[bhp].GCTagWords',N'U') is not null
begin
	drop table [bhp].GCTagWords;
	print 'table:: [bhp].GCTagWords dropped!!!';
end
go

/*
** this table contains George Carlin words that are NOT ALLOWED for tagging
** your ingredient/adjunct(s).  Tags are used for searching purposes...and i don't want someone
** search for recipes using these words!!!
*/
create table [bhp].GCTagWords (
	RowID int identity(0,1) not null,
	Tag nvarchar(100) not null,
	Reason nvarchar(1000) null,
	EnteredOn datetime null,
	EnteredBy sysname null,
	Constraint PK_GCTagWords_RowID primary key nonclustered(RowID)
);
go

Create Unique Clustered Index IDX_GCTagWords_Tag on [bhp].GCTagWords ([Tag]);
go

alter table [bhp].GCTagWords add
constraint DF_GCTagWords_Reason default(N'n/a') for [Reason],
constraint DF_GCTagWords_EnteredOn default(getdate()) for EnteredOn,
Constraint DF_GCTagWords_EnteredBy default(suser_sname()) for EnteredBy;
go

insert into [bhp].GCTagWords (Tag, Reason) 
values(N'pls select...','DO NOT REMOVE!!!');
go

Create trigger [bhp].GCTagWords_Del_99 on [bhp].GCTagWords
with encryption
for delete
as
begin
	if exists (Select 1 from deleted where RowID = 0)
	begin
		Raiserror(N'primary key value ''0'' cannot be removed!!!',16,1);
		Rollback Transaction;
	end
end
go

Create Trigger [bhp].GCTagWords_Ins_99 on [bhp].GCTagWords
with encryption
for insert
as
begin
	set nocount on;
	Update [bhp].GCTagWords
		set EnteredOn=getdate(), EnteredBy=suser_sname()
	from [bhp].GCTagWords R Inner Join inserted I 
	on (R.RowID = I.RowID)
	Where (ISNULL(R.EnteredOn,0) = 0 or [di].fn_IsNull(R.EnteredBy) is null);
end
go


Create Trigger [bhp].GCTagWords_Ins_Reason on [bhp].GCTagWords
with encryption
for insert
as
begin
	set nocount on;
	Update [bhp].GCTagWords
		set Reason=N'n/a'
	from [bhp].GCTagWords R Inner Join inserted I 
	on (R.RowID = I.RowID)
	Where ([di].fn_IsNull(R.Reason) is null);
end
go

insert into [bhp].GCTagWords (Tag, Reason)
values('shit','not appropriate descriptor'),
('piss','not appropriate descriptor'),
('dick','not appropriate descriptor'),
('suck', null),
('cunt',null),
('ass',null),
('asshole',null),
('motherfucker','definitely not appropriate'),
('jew',null),
('jewbag',null),
('pussy',null),
('fag',null),
('boegger',null),
('bitch','not appropriate'),
('whore',null),
('fagget',null),
('lesbian',null),
('ugly',null),
('fuckit',null),
('asswipe',null),
('dickhead',null),
('shithead',null),
('dumbshit',null),
('nigger','not appropriate'),
('spook','not appropriate'),
('clit','not appropriate'),
('tit','not appropriate'),
('tits','not appropriate'),
('pecker','not appropriate'),
('peckerhead','not appropriate'),
('fuckn',null),
('fucking','not appropriate'),
('fuck', 'not appropriate descriptor'),
('fucker','not appropriate'),
('fuckity',null),
('http',null),
('https',null),
('http:',null),
('https:',null),
('http://',null),
('https://',null),
('mailto:',null),
('ftp:',null),
('sftp:',null),
('ftps:',null)
go