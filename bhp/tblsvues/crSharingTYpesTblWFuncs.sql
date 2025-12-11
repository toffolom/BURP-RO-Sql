use [BHP1-RO]
go

Drop Table [bhp].SharingTypes;
go

drop function [bhp].[fn_SharingTypesMaskToStr];
go

/****** Object:  Table [bhp].[DMZTypes]    Script Date: 1/12/2017 3:32:28 PM ******/
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO

CREATE TABLE [bhp].[SharingTypes](
	[BitVal] [smallint] NOT NULL,
	[Descr] [varchar](40) NOT NULL,
	[Notes] [nvarchar](1000) Null,
	AllowInSchedModes bit null,
	Constraint PK_SharingTypes_BitVBal PRIMARY KEY NONCLUSTERED 
(
	[BitVal] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = OFF, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

alter table [bhp].[SharingTypes] add
constraint [DF_SharingTypes_Notes] DEFAULT ('<Notes><Note nbr=''0''/>pls add a note</Notes>') for [Notes],
Constraint [DF_SharingTYpes_AllowInSched] Default(0) for [AllowInSchedModes];
go

Create Trigger [bhp].[SharingTypes_Del_99] on [bhp].[SharingTypes]
with encryption
for delete
as
begin
	if Exists (Select * from deleted where BitVal = 0)
	Begin
		Raiserror('BitVal ''zero'' cannot be removed...aborting!!!',16,1);
		Rollback Tran;
	End
end
go

insert into [bhp].[SharingTypes] (BitVal, [Descr], Notes, AllowInSchedModes)
values (0, 'Private', N'<Notes><Note nbr=''1''>no sharing allowed!!!</Note><Note nbr=''2''>this is the default for new recipes...</Note></Notes>',1),
( 1, 'Brewers', N'<Notes><Note nbr=''1''>allow sharing w/other brewerys...</Note></Notes>',1),
( 2, 'Admins', N'<Notes><Note nbr=''1''>allow sharing w/administrator(s) of system...</Note></Notes>',1),
( 4, 'Suppliers', N'<Notes><Note nbr=''1''>allow sharing w/brewery supplier(s)...</Note></Notes>',0),
( 8, 'Auctioneers', N'<Notes><Note nbr=''1''>allow sharing w/auctioneer(s) of brewery...</Note></Notes>',0),
( 16, 'Move To Production', N'<Notes><Note nbr=''1''>allow recipe to be produced by the brewery...</Note></Notes>',0),
( 32, 'End Users', N'<Notes><Note nbr=''1''>allow sharing w/anyone...</Note></Notes>',1),
(64, 'In Production',N'<Notes><Note nbr=''1''>recipe has been shared w/production...could be in production...but produciton has it!!!</Note></Notes>',0),
(128,'Allow Followers',N'<Notes><Note nbr=''1''>indicates the recipe creator/owner will allow people to follow this recipe as it matures</Note></Notes>',1),
(256,'Internal',N'<Notes><Note nbr=''1''>indicates you''ll share it internally within the deployment your hosted in ONLY</Note></Notes>',1),
(512,'Breweries',N'<Notes><Note nbr=''1''>indicates you are willing to share this recipe with OTHER deployments</Note></Notes>',1),
(1024,'Allow Clone',N'<Notes><Note nbr=''1''>indicates that this recipe can be cloned</Note></Notes>',1)
go

Create function [bhp].[fn_SharingTypesMaskToStr] (@mask int)
returns varchar(200)
with encryption
as
begin
	Declare @i int;
	Declare @str varchar(200);
	Declare @nm varchar(40);
	Set @i = 0;
	While Exists (Select 1 from [bhp].SharingTypes Where (BitVal > @i))
	Begin
		Select Top (1) @i = BitVal, @nm = [Descr]
		From [bhp].SharingTypes 
		Where (BitVal > @i) Order by BitVal;
		
		If ((@mask & @i) = @i)
			set @str = coalesce(@str + ',','') + @nm;
	End
	Return Coalesce(@str,(select [Descr] from [bhp].SharingTypes where BitVal = 0));
end
go

checkpoint
