@isTest 
public class PSG_BatchPridECPInactive_Test {
    /*@isTest
    private static void testBatchECPInactivePrids(){
        SBQQ.TriggerControl.disable();
        List<User> lstUsers = PSG_Test_Utility.createAdminUser();
        Account acc = PSG_Test_Utility.createDirectAccount();
        Account acc4 = PSG_Test_Utility.createAccount();
        acc4.Core_Direct_Pricing_Parent_Id__c=acc.id;
        acc4.Core_Direct_Legal_Parent_Id__c=acc.id;
        update acc4;
        Account acc2 = PSG_Test_Utility.createAccount();
        Contact con = PSG_Test_Utility.createContact(acc2.Id);
        System.runAs(lstUsers[0]){
            List<SBQQ__Quote__c> lstquote = PSG_Test_Utility.createQuote(acc4.Id, con.Id, 1);
            system.assert(!lstquote.isEMpty() , 'Quote Created');
            Test.startTest();
            if(lstquote[0] != null){
                    pricebook2 pb = [Select id from pricebook2 limit 1];
                    lstquote[0].core_cpq_price_book_nm__c = pb.Id;
                    Update lstquote[0];
                	System.assert(lstquote[0].Id!=null,'Quote updation successfull');
                	List<SBQQ__QuoteLine__c> quoteLineList = PSG_Test_Utility.createQuoteLines(lstquote[0].Id,1);
                	List<price_prid__c> pridList = PSG_Test_Utility.createPrid(acc4.Id,lstquote[0].Id,quoteLineList[0].Id,quoteLineList[0].core_cpq_product_nm__c);
                	pridList[0].core_cpq_cps_cb__c = false;
                	pridList[0].core_cpq_sap_ecp_nm__c = acc.Id;
                	update pridList;
                	lstquote[0].SBQQ__Status__c = 'Approved';
                	lstquote[0].core_cpq_active_cb__c = true;
                	lstquote[0].core_cpq_quote_type_nm__c = 'Design Win';
                }
            update lstquote;
            acc.Core_Direct_Account_Active_Ind__c = false;
            update acc;
        }
        Database.executeBatch(new PSG_BatchPridECPInactive(), 1);
        Test.stopTest();
    }*/
}