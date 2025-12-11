use [BHP1-RO]
go

if object_id(N'[di].TouchSession',N'P') Is not null
begin
	drop proc [di].TouchSession;
	print 'proc:: ''[di].TouchSession'' dropped!!!';
end
go

/*
** This proc used to update the session entry...basically called anytime some activity is performed by the user session
*/
Create Proc [di].[TouchSession] (
	@SessID uniqueidentifier -- our session id value to touch
) 
with encryption, execute as 'sticky'
as
begin
	--Set NoCount On;
	--Declare @burpMsg xml;
	Declare @tries tinyint;
	--Declare @err int;

	Set @tries = 1;

	while (@tries <= 3)
	Begin
		Begin Transaction;
		Begin Try
			-- kick the lastactiveon ts...only if its current value is less than the curr time...
			Update Top (1) [di].[SessionMstr] 
				Set [LastActiveOn] = getdate() 
			Where ([SessID] = @SessID And [LastActiveOn] < getdate());

			-- post a ssb msg that a session has been touched!!!
			--exec [di].GenBurpSessionMesg @sessID=@sessid, @type='touch', @mesg=@burpMsg output;
			--exec [di].SendBurpRepoMesg @msg=@burpMsg;
			
			Commit;
			Break;
		End Try
		Begin Catch
			Rollback;
			Set @tries = @tries + 1;
		End Catch

	End -- endof while
	
	Return @@ERROR;
end
go

--If Exists (Select * from sys.certificates where name = 'RecipeRepoCert')
--Begin
--	Begin Try
--		ADD SIGNATURE TO OBJECT::[TouchSession]
--		BY CERTIFICATE [RecipeRepoCert]
--		WITH PASSWORD = '';

--		print 'signature added to proc using cert:[RecipeRepoCert]...';
--	End Try
--	Begin Catch
--		declare @e nvarchar(1028)
--		set @e = ERROR_MESSAGE();
--		raiserror('%s',0,1,@e);
--	End Catch
--End
--go

checkpoint
