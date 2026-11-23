/*
Developed By : Shwetali Alase
Purpose      : To Explore Copado CLI.
*/
public  with sharing class AccountFetchName {
    //Will Fetch account names 
    public static void fetchAccounts(){
        
  final list<Account> isd = [Select id from Account where Name = 'Test Account' ];
    }
}