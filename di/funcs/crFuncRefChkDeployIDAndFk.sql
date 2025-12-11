/*
** swith this over to 'use DI' to install in DI!!!
*/
Use [BHP1-RO]
go

drop function [di].fn_RefChk_fk_DeployInfo;
go

drop function [di].fn_RefChk_fk_DeploymentID;
go

drop function [di].fn_GetDeployName;
go

create function [di].fn_RefChk_fk_DeployInfo(@id int)
returns bit
with encryption
as
begin
	declare @b bit;
	set @b=0;
	if exists (select * from [di].Deployments Where [RowID] = @id)
		set @b=1;
	return @b;
end
go

create function [di].fn_RefChk_fk_DeploymentID(@id varchar(256))
returns bit
with encryption
as
begin
	declare @b bit;
	set @b=0;
	if exists (select * from [di].Deployments Where [DeploymentID] = @id)
		set @b=1;
	return @b;
end
go

create function [di].fn_GetDeployName(@id int)
returns varchar(200)
with encryption
as
begin
	declare @nm varchar(200);
	select @nm=[Name] from [di].Deployments Where [RowID] = @id;
	return ISNULL(@nm, (select [name] from [di].Deployments Where RowID=-1));
end
go