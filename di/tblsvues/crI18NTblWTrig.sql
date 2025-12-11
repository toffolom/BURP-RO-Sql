--USE [BHP1-RO]
--GO

ALTER TABLE [di].[I18NMessageCatV2] DROP CONSTRAINT [DF_I18NMesgCatV2_Superceded]
GO

/****** Object:  Table [di].[I18NMessageCatV2]    Script Date: 10/11/2018 2:22:29 PM ******/
DROP TABLE [di].[I18NMessageCatV2]
GO

/****** Object:  Table [di].[I18NMessageCatV2]    Script Date: 10/11/2018 2:22:29 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [di].[I18NMessageCatV2](
	[RowId] [int] IDENTITY(1,1) NOT NULL,
	[Nbr] [int] NOT NULL,
	[Mesg_en_us] [nvarchar](2000) NOT NULL,
	[Mesg_en_ca] [nvarchar](2000) NULL,
	[Mesg_en_gb] [nvarchar](2000) NULL,
	[Mesg_fr_fr] [nvarchar](2000) NULL,
	[Mesg_de_de] [nvarchar](2000) NULL,
	[SupercededByMsgNbr] [int] NULL,
 CONSTRAINT [PK_I18NMesgCatV2_RowID] PRIMARY KEY NONCLUSTERED 
(
	[RowId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [di].[I18NMessageCatV2] ADD  CONSTRAINT [DF_I18NMesgCatV2_Superceded]  DEFAULT ((0)) FOR [SupercededByMsgNbr]
GO

set identity_Insert [di].I18NMessageCatV2 on;
insert into [di].I18NMessageCatV2(RowId, Nbr, Mesg_en_us, SupercededByMsgNbr)
values (0, 0, 'dummy - DO NOT REMOVE!!!', 0);
set identity_Insert [di].I18NMessageCatV2 off;
go

/****** Object:  Index [IDX_I18NMsgCatV2_Nbr]    Script Date: 10/11/2018 2:22:47 PM ******/
CREATE CLUSTERED INDEX [IDX_I18NMsgCatV2_Nbr] ON [di].[I18NMessageCatV2]
(
	[Nbr] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

create trigger [di].I18NMessageCatV2_Del_99 on [di].I18NMessageCatV2 
with encryption
for delete
as
begin
	if exists (select * from deleted where RowID = 0)
	begin
		Raiserror(N'Row ''zero'' cannot be deleted...aborting!!!',16,1);
		Rollback Transaction;
	end
end
go

create Trigger [di].I18NMesgCatV2_Ins_01 on [di].I18NMessageCatV2
with encryption
for insert
as
begin
	If Not Exists (Select * 
		from inserted I
		Inner Join [di].I18NMessageCatV2 C On (ISNULL(I.SupercededByMsgNbr,0) = C.Nbr)
	)
	Begin
		Raiserror(N'Supercession Nbr doesn''t exist!!! Aborting...',16,1);
		Rollback Transaction;
	End
end
go

create Trigger [di].I18NMesgCatV2_Upd_01 on [di].I18NMessageCatV2
with encryption
for update
as
begin
	If Update(SupercededByMsgNbr)
	Begin
		If Not Exists (Select * 
			from inserted I
			Inner Join [di].I18NMessageCatV2 C On (ISNULL(I.SupercededByMsgNbr,0) = C.Nbr)
		)
		Begin
			Raiserror(N'Supercession Nbr doesn''t exist!!! Aborting...',16,1);
			Rollback Transaction;
		End
	End
end
go

/*
alter Trigger I18NMesgCatV2_Del_PublishMesg on [di].I18NMessageCatV2
with encryption
for delete
as
begin
	Declare @root xml;
	Declare @frag xml;
	Declare @send varchar(40);
	Declare @deployguid varchar(256);
	Declare @rowid int;

	Select @rowid = [RowID] from deleted;

	Exec [di].getEnv @VarNm='publish i18n catalog changes mode', @VarVal=@send output, @dfltVal='yes';

	if ([di].fn_ISTRUE(@send) = 1)
	begin

		Select @deployguid = DeploymentID From [di].Deployments Where RowID = 0;
		Exec [di].GenDeployRootNodeMesg @evnttype='del',@deployid=@deployguid,@mesg=@root output;
		Exec [di].GenI18NCatlgMesg @SessID='00000000-0000-0000-0000-000000000000',@RowID=@RowID, @Mesg=@frag output;
		set @root.modify('
			declare namespace b="http://burp.net/deployment/evnts";
			insert sql:variable("@frag")
			as last into (/b:Burp_Deployment/b:Payload)[1]
		');
		Exec [di].SendDeploymentMesg @msg=@root;
	end
end
go
*/
