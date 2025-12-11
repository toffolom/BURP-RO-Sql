create master key encryption by password = 'sdlfkjdsfijowrut[0e4w9ujo;iadfjnv;oiahero;ig ae;orij;oaerjgl';
go

if exists (select * from sys.external_data_sources where name='HubEvntConsumer')
begin
	Drop External Data Source HubEvntConsumer;
	Print 'External Data Source:: ''HubEvntConsumer'' dropped!!!';
end
go


if exists (select * from sys.database_credentials where name = 'HubPosterCreds')
begin
	Drop Database Scoped credential HubPosterCreds;
	Print 'Database Scoped Credentials:: ''HubPosterCreds'' dropped!!!';
end
go

Create Database scoped credential HubPosterCreds with identity = 'deployEvntPoster', secret = '2Post4U!!00';
go

CREATE EXTERNAL DATA SOURCE HubEvntConsumer
WITH
(
TYPE=RDBMS,
LOCATION='tcp:burprouter.southcentralus.cloudapp.azure.com,7777',
DATABASE_NAME='HUB',
--CONNECTION_OPTIONS = 'Connect Timeout=3',
CREDENTIAL= HubPosterCreds
);
go

exec sys.sp_execute_remote @data_source_name=N'HubEvntConsumer',
	@Stmt=N'exec sp_who2; --exec bhp.RecvPubEventFromDeployment @did=@inDid @payld=@inPayld',
	@Params=N'@inDid varchar(256), @inPayld nvarchar(max)',
	@inDid='00000000-0000-0000-0000-000000000000',
	@InPayld=N'<Payload/>';
--go

select * from sys.database_credentials;
select * from sys.external_data_sources;