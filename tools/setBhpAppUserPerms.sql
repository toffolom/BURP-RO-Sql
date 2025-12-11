use [BHP1-RO]
go

declare @id int;
declare @sql nvarchar(max);
set @id = 0;
while exists (select * from sys.views where object_id > @id And is_ms_shipped = 0 and SCHEMA_NAME(schema_id) in ('bhp','di','bwp'))
begin
	select Top (1) @id = object_id,
		@sql = N'grant select on [' + schema_name(schema_id) + '].['+name+'] to [BHPApp];'
	from sys.views where object_id > @id and is_ms_shipped = 0 and SCHEMA_NAME(schema_id) in ('bhp','di','bwp')
	order by object_id;
	Raiserror(N'sending sql -> ''%s'' now...',0,1,@sql);
	exec sp_ExecuteSql @sql;
end
go

grant select on [di].[Languages] to [BHPApp];
go

declare @id int;
declare @sql nvarchar(max);
set @id = 0;
while exists (select * from sys.procedures where object_id > @id And is_ms_shipped = 0 and SCHEMA_NAME(schema_id) in ('bhp','di','bwp'))
begin
	select Top (1) @id = object_id,
		@sql = N'grant execute on [' + schema_name(schema_id) + '].['+name+'] to [BHPApp];'
	from sys.procedures where object_id > @id and is_ms_shipped = 0 and SCHEMA_NAME(schema_id) in ('bhp','di','bwp')
	order by object_id;
	Raiserror(N'sending sql -> ''%s'' now...',0,1,@sql);
	exec sp_ExecuteSql @sql;
end
go

--grant execute on [bhp].[CloneRecipeV1] to [BHPApp];
revoke execute on [bwp].PostSubscriptionEvnt to [BHPApp];
revoke execute on [bhp].[PostToBWPRouter] to [BHPApp];
revoke execute on [bwp].[AddGlblDeploymentRec] to [BHPApp];
revoke execute on [bwp].[ClrGlblDeploymentRecs] to [BHPApp];
revoke execute on [bwp].[DelGlblDeploymentRec] to [BHPApp];
revoke execute on [bwp].[GetPublicationMesgs] to [BHPApp];
revoke execute on bwp.[GetDeploymentPublicationSettings] to [BHPApp];
revoke execute on bwp.[GetDeploymentSubscriptionSettings] to [BHPApp];
go
--revoke execute on [bwp].[GetPublicationMesgs] to [BHPApp];
--go

--declare @id int;
--declare @sql nvarchar(max);
--set @id = 0;
--while exists (select * from sys.objects where type in (N'FN', N'IF', N'TF', N'FS', N'FT') and is_ms_shipped = 0 and object_id > @id)
--begin
--	select Top (1) @id = object_id,
--		@sql = N'grant execute on [' + schema_name(schema_id) + '].['+name+'] to [BHPApp];'
--	from sys.objects where type in (N'FN', N'IF', N'TF', N'FS', N'FT') and is_ms_shipped = 0 and object_id > @id order by object_id;
--	Raiserror(N'sending sql -> ''%s'' now...',0,1,@sql);
--	exec sp_ExecuteSql @sql;
--end
--go


select quotename(schema_name(o.schema_id)) + '.' + quotename(Object_name(p.major_id)) [obj], o.type_desc, p.* 
from sys.database_permissions  p
inner join sys.objects o on (p.major_id = o.object_id)
where p.grantee_principal_id = DATABASE_PRINCIPAL_ID('BHPApp')
order by schema_name(o.schema_id),object_name(p.major_id), type_desc;

select schema_name(o.schema_id) + '.' + Object_name(sm.object_id) [obj], isnull(dp.name,'dbo') [ExecsAs], sm.*
from sys.sql_modules sm 
left join sys.database_principals dp on (sm.execute_as_principal_id = dp.principal_id)
inner join sys.objects o on (sm.object_id = o.object_id)
where sm.execute_as_principal_id is not null
order by schema_name(o.schema_id) + '.' + object_name(sm.object_id);
go

