@isTest
public class PSG_BatchQuoteECPInactive_Test {
    /*@isTest
    private static void testBatchECPInactiveQuotes(){
        List<User> lstUsers = PSG_Test_Utility.createAdminUser();
        Account acc = PSG_Test_Utility.createDirectAccount();
        Account acc4 = PSG_Test_Utility.createAccount();
        acc4.Core_Direct_Pricing_Parent_Id__c=acc.id;
        acc4.Core_Direct_Legal_Parent_Id__c=acc.id;
        update acc4;
        Account acc2 = PSG_Test_Utility.createAccount();
        Contact con = PSG_Test_Utility.createContact(acc2.Id);
        Test.startTest();
        System.runAs(lstUsers[0]){
            List<SBQQ__Quote__c> lstquote = PSG_Test_Utility.createQuote(acc4.Id, con.Id, 1);
            system.assert(!lstquote.isEMpty() , 'Quote Created');
            if(lstquote[0] != null){
                    pricebook2 pb = [Select id from pricebook2 limit 1];
                    lstquote[0].core_cpq_price_book_nm__c = pb.Id;
                    Update lstquote[0];
                    System.assert(lstquote[0].Id!=null,'Quote updation successfull');
                	lstquote[0].SBQQ__Status__c = 'Approved';
                	lstquote[0].core_cpq_active_cb__c = true;
                	lstquote[0].core_cpq_quote_type_nm__c = 'Design Win';
                }
            update lstquote;
            acc.Core_Direct_Account_Active_Ind__c = false;
            update acc;
        }
        Database.executeBatch(new PSG_BatchQuoteECPInactive(), 1);
        System.schedule('TestJob', '0 0 20 1/1 * ? *', new PSG_BatchForDelegation());
        try{
            PSG_BatchQuoteECPInactive test1 = new PSG_BatchQuoteECPInactive();
        	test1.execute(null , null);
        }
        catch(Exception e){
            PSG_Utility.logError(e);
        }
        Test.stopTest();
        
    }*/
}