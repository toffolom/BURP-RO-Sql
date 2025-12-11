USE [BHP1-RO]
GO

/****** Object:  View [di].[vw_CustomerMstr]    Script Date: 3/5/2020 3:11:07 PM ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[di].[vw_CustomerMstr]'))
DROP VIEW [di].[vw_CustomerMstr]
GO

/****** Object:  View [di].[vw_CustomerMstr]    Script Date: 3/5/2020 3:11:07 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO







CREATE View [di].[vw_CustomerMstr]
with schemabinding
as
Select
	C.[RowID]
	,C.[Name]
	,C.[BHPUid]
	,C.[BHPPwd]
	,C.[Hint]
	,ISNULL(C.[TotBlogs],0) As TotBlogs
	,ISNULL(C.[TotRecipes],0) As TotRecipes
	,ISNULL(C.[RoleBitMask],0) As RoleBitMask
	,C.[RoleBitMaskAsStr]
	,C.[AllowMultiSession]
	,C.[AllowLogin]
	,ISNULL(C.[DfltLang],'en_us') As DfltLang
	,ISNULL(C.[fk_LastBeerDrank],0) As fk_LastBeerDrank
	,ISNULL(C.[DisplayAs],C.[Name]) As DisplayAs
	,isnull(C.[EnteredOn],convert(datetime, 0)) As EnteredOn
	,isnull(C.[Verified],0) As Verified
	,ISNULL(C.AllowNotices,1) As AllowNotices
	,ISNULL(C.DenyBroadcast,0) As DenyBroadcast
	,D.DeploymentID
	,D.RowID As DeploymentRowID
	,D.Name As DeploymentName
  FROM [di].[CustMstr] C
  Inner Join [di].Deployments D
  On (C.fk_DeployInfo = D.RowID); -- With (NOLOCK);
 
  
GO


