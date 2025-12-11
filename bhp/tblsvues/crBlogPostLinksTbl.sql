use [BHP1-RO]
go

begin try
	drop table [bhp].BlogPostLinks;
	print N'table:: [bhp].BlogPostLinks dropped!!!';
end try
begin catch
	print N'table:: [bhp].BlogPostLinks doesn''t exist...no prob!!!';
end catch
go

Create Table [bhp].BlogPostLinks (
	[RowID] int identity(1,1),
	fk_BlogPostID bigint,
	[Link] varchar(1000),
	[LinkTyp] varchar(8) null,
	[IsGoodLink] bit null,
	[LinkIsBlocked] bit null,
	[Comments] nvarchar(2000) null,
	Constraint PK_BlogPostLinks_RowID Primary Key Nonclustered(RowID)
)
go

alter table [bhp].BlogPostLinks add constraint CHK_BlogPostLinks_LinkTyp Check([LinkTyp] in ('uri','mail','unknwn',null));
go

alter table [bhp].BlogPostLinks Add Constraint DF_BlogPostLinks_IsGoodLink Default(0) For [IsGoodLink];
go

alter table [bhp].BlogPostLinks Add Constraint DF_BlogPostLinks_LinkIsBlocked Default(0) For [LinkIsBlocked];
go

alter table [bhp].BlogPostLinks Add Constraint FK_BlogPostLinks_RecipeBlogPosts Foreign Key (fk_BlogPostID) 
References [bhp].RecipeBlogPosts (RowID);
go
