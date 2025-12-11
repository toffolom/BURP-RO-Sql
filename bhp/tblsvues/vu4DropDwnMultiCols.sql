USE [BHP1-RO]
GO

/****** Object:  View [bhp].[vw_RecipeBldrYeast4MultiColDropDwn]    Script Date: 3/4/2020 2:23:23 PM ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[bhp].[vw_RecipeBldrYeast4MultiColDropDwn]'))
DROP VIEW [bhp].[vw_RecipeBldrYeast4MultiColDropDwn]
GO

/****** Object:  View [bhp].[vw_RecipeBldrHops4MultiColDropDwn]    Script Date: 3/4/2020 2:23:23 PM ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[bhp].[vw_RecipeBldrHops4MultiColDropDwn]'))
DROP VIEW [bhp].[vw_RecipeBldrHops4MultiColDropDwn]
GO

/****** Object:  View [bhp].[vw_RecipeBldrGrain4StdDropDwn]    Script Date: 3/4/2020 2:23:23 PM ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[bhp].[vw_RecipeBldrGrain4StdDropDwn]'))
DROP VIEW [bhp].[vw_RecipeBldrGrain4StdDropDwn]
GO

/****** Object:  View [bhp].[vw_RecipeBldrGrain4MultiColDropDwn]    Script Date: 3/4/2020 2:23:23 PM ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[bhp].[vw_RecipeBldrGrain4MultiColDropDwn]'))
DROP VIEW [bhp].[vw_RecipeBldrGrain4MultiColDropDwn]
GO

/****** Object:  View [bhp].[vw_RecipeBldrExtract4MultiColDropDwn]    Script Date: 3/4/2020 2:23:23 PM ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[bhp].[vw_RecipeBldrExtract4MultiColDropDwn]'))
DROP VIEW [bhp].[vw_RecipeBldrExtract4MultiColDropDwn]
GO

/****** Object:  View [bhp].[vw_BurpHops4MultiColDropDwn]    Script Date: 3/4/2020 2:23:23 PM ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[bhp].[vw_BurpHops4MultiColDropDwn]'))
DROP VIEW [bhp].[vw_BurpHops4MultiColDropDwn]
GO

/****** Object:  View [bhp].[vw_BurpHops4MultiColDropDwn]    Script Date: 3/4/2020 2:23:23 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO







CREATE view [bhp].[vw_BurpHops4MultiColDropDwn] (
	RowID, Name, MfrID, MfrNm, Purpose, AlphaAcidLow, AlphaAcidHigh, BetaAcidLow, BetaAcidHigh, Pellet, Flower, --RowSize,  
	[Substitue 1], [Substitue 2], [Substitue 3], fk_CountryID, CountryName, Commentary
)
--with schemabinding
as
select 
	H.RowID,
	H.Name, 
	fk_HopMfrID,
	HopMfrNm,
	H.HopPurpose,
	H.AlphaAcidLow, 
	H.AlphaAcidHigh, 
	H.BetaAcidLow, 
	H.BetaAcidHigh, 
	ISNULL(H.Pellet, 0),
	ISNULL(H.Flower, 0),
	--H.Rowsz,  
	case PSub1 WHen 0 then 'no sub' Else [bhp].fn_GetHopNameV2(PSub1) End,
	case PSub2 WHen 0 then 'no sub' Else [bhp].fn_GetHopNameV2(PSub2) End,
	case PSub3 WHen 0 then 'no sub' Else [bhp].fn_GetHopNameV2(PSub3) End,
	H.fk_CountryID,
	case H.fk_CountryID when 0 then 'country undef...' else [bhp].fn_GetCountryNm(H.fk_CountryID) end,
	--PSub4,
	--case PSub4 WHen 0 then 'Not Set' Else [bhp].fn_GetHopNameV2(PSub4) End,
	--PSub5,
	--case PSub5 WHen 0 then 'Not Set' Else [bhp].fn_GetHopNameV2(PSub5) End,
	ISNULL(H.Commentary,'n/a')
FROM [bhp].[HopTypesV2] H; --Where (H.RowID > 0);
--inner join BHP1.[bhp].UOMTypes U
--on (H.fk_OpCostUOM = U.RowID And H.RowID > 0);



GO

/****** Object:  View [bhp].[vw_RecipeBldrExtract4MultiColDropDwn]    Script Date: 3/4/2020 2:23:23 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE view [bhp].[vw_RecipeBldrExtract4MultiColDropDwn] (
	[RowID]
	,[Name]
	,[fk_ExtractMfr]
	,[MfrNm]
	,[Details]
	,[Notes]
)
--with encryption
as
	select 
		0,'pls select...',0,'pls select...','0.00-0.00L','no comment given...'
	union 
	select 
		[RowID]
		,[Name]
		,[fk_ExtractMfrID]
		,[ExtractMfrNm]
		,ISNULL(Convert(varchar, BegColorAmt),'0.00') + '-' + ISNULL(convert(varchar, EndColorAmt),'0.00') + ColorUOM +
			';' + ISNULL(Convert(varchar, BegBitternessAmt),'0') + '-' + ISNULL(convert(varchar, EndBitternessAmt),'0') + BitternessUOM
		,ISNULL([Comment],N'no comment given...')
	from [bhp].ExtractMstr EM Where (RowID > 0);
GO

/****** Object:  View [bhp].[vw_RecipeBldrGrain4MultiColDropDwn]    Script Date: 3/4/2020 2:23:23 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO








CREATE view [bhp].[vw_RecipeBldrGrain4MultiColDropDwn] (
RowID,[Name],Lovibond,SRM,fk_GrainType,GrainType,RowSize,fk_GrainMfr,GrainMfr,Country,IsMod,IsUndrMod,PARange
)
with schemabinding
as
SELECT
	[RowID]
	,[Name]
	,'[' + convert(varchar,ISNULL([degLStart],0)) + '-' + convert(varchar,ISNULL([degLEnd],0)) + ']L' As LoviRange
	,convert(varchar,ISNULL([SRM],0)) + ' SRM' As SRM
	,[fk_GrainType]
	,[GrainType]
	,ISNULL([RowSize],0)
	,fk_GrainMfr
	,case [fk_GrainMfr]
	when 0 then 'n/a'
	else
		(Select Top (1) Name from [bhp].GrainManufacturers Where (RowID = fk_GrainMfr))
	end As [GrainMfr]
	,Case fk_CountryID
	When 0 then 'country'
	else
	(Select Top (1) Name From [di].Countries Where (RowID=fk_CountryID)) 
	End As Country
	,'modified->' + case [isModified] when 1 then 'yes' else 'no' end As IsModified
	,'undrMod->' + case [isUnderModified] when 1 then 'yes' else 'no' end as UndrModified
	,'[' + convert(varchar,ISNULL([PotentialGravityBeg],0)) + '-' + convert(varchar,ISNULL([PotentialGravityEnd],0)) +']PA' As PARange
  FROM [bhp].[GrainMstr]
GO

/****** Object:  View [bhp].[vw_RecipeBldrGrain4StdDropDwn]    Script Date: 3/4/2020 2:23:23 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE view [bhp].[vw_RecipeBldrGrain4StdDropDwn] (
	RowID,[Name]
)
with schemabinding
as
SELECT
	[RowID]
	,convert(varchar(2000),[Name] + '->' +
	'[' + convert(varchar,ISNULL([degLStart],0)) + '-' + convert(varchar,ISNULL([degLEnd],0)) + ']L,' +
	convert(varchar,ISNULL([SRM],0)) + ' SRM,' + 
	'typ:[' + [GrainType] + '],' +
	'rowsz:[' +convert(varchar,ISNULL([RowSize],0)) + '],' +
	'mfr:[' + case [fk_GrainMfr]
	when 0 then 'n/a'
	else
		(Select Top (1) Name from [bhp].GrainManufacturers Where (RowID = fk_GrainMfr))
	end + '],' +
	'cntry:[' + 
	case fk_countryID when 0 then 'not set' else (select top (1) Name from [di].Countries Where RowID=fk_CountryID) End + '],' +
	'modified:[' + case [isModified] when 1 then 'y' else 'n' end + '],' +
	'undrMod:[' + case [isUnderModified] when 1 then 'y' else 'n' end + '],' +
	'[' + convert(varchar,ISNULL([PotentialGravityBeg],0)) + '-' + convert(varchar,ISNULL([PotentialGravityEnd],0)) +']PA')
  FROM [bhp].[GrainMstr]
GO

/****** Object:  View [bhp].[vw_RecipeBldrHops4MultiColDropDwn]    Script Date: 3/4/2020 2:23:23 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE view [bhp].[vw_RecipeBldrHops4MultiColDropDwn] (
	RowID, MfrID, Mfr, Name, Purpose, AA, Beta, Comments
)
 
as
	SELECT 
		[RowID]
		,[fk_HopMfrID]
		,[HopMfrNm]
		,[Name]
		,[HopPurpose]
		,'[' + convert(varchar,ISNULL([AlphaAcidLow],0)) + '-' + convert(varchar,ISNULL([AlphaAcidHigh],0)) + '] AA'
		,'[' + convert(varchar,ISNULL([BetaAcidLow],0)) + '-' + convert(varchar,ISNULL([BetaAcidHigh],0)) + '] Beta'
		,ISNULL([Commentary],N'no comments given...')
	FROM [bhp].[HopTypesV2];
GO

/****** Object:  View [bhp].[vw_RecipeBldrYeast4MultiColDropDwn]    Script Date: 3/4/2020 2:23:23 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


create view [bhp].[vw_RecipeBldrYeast4MultiColDropDwn] (
	[RowID]
	,[Name]
	,[fk_YeastMfr]
	,[MfrNm]
	,[fk_YeastType]
	,[YeastTypName]
	,[fk_YeastPkgTyp]
	,[Flocculation]
	,[Attenuation]
	,[FermTemps]
	,[fk_FermTempUOM]
	,[FermTempUOM]
	,[Notes]
)
--with encryption
as
	select 
		0,'pls select...',0,'pls select...',0,'pls select...',0,'n/a','n/a','[0-0]F',0,'F','pls select...'
	union 
	select 
		[RowID]
		,[Name]
		,[fk_YeastMfr]
		,[MfrNm]
		,[fk_YeastType]
		,[YeastTypName]
		,[fk_YeastPkgTyp]
		,[Flocculation]
		,[Attenuation]
		,'[' + convert(varchar,ISNULL(FermTempBeg,0)) + '-' + convert(varchar,ISNULL(FermTempEnd,0)) + ']' + FermTempUOM
		,[fk_FermTempUOM]
		,[FermTempUOM]
		,[Notes]
	from [bhp].YeastMstr YM Where (RowID > 0);
GO


