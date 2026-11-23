/*
Developed By : Shwetali Alase
Purpose      : To Explore Copado CLI.
*/
@isTest
public class AccountFetchNameTest {
    
    public static testMethod void unitTest(){
        
        //Will cover AccountFetchName test
        Account acc=new Account();
        acc.Name='TestAccount';
        Acc.BillingCity = 'Pune';
        acc.BillingCountry = 'ABW' ;
        acc.BillingStreet = '123 fb street';
        Insert acc;
        acc=[SELECT id,Name FROM Account WHERE id=: acc.Id];
        System.assertEquals(acc.Name, 'TestAccount','Names are same');
        AccountFetchName.fetchAccounts();
    }
}