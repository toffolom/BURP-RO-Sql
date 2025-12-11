use master
go

drop database [BHP1-RO];
go

Create Database [BHP1-RO]
go

ALTER AUTHORIZATION ON DATABASE::[BHP1-RO] TO [sa];
go

ALTER DATABASE [BHP1-RO] SET AUTO_CLOSE ON WITH NO_WAIT
GO
ALTER DATABASE [BHP1-RO] SET AUTO_SHRINK ON WITH NO_WAIT
GO
ALTER DATABASE [BHP1-RO] SET RECOVERY SIMPLE WITH NO_WAIT
GO

use [BHP1-RO];
go

create schema [di];
go
create schema [bhp1];
go

create user [sticky] without login;
go

alter role [db_owner] add member [sticky];
go

checkpoint;