@isTest
public class PSG_RequestDPATest {
    /*@isTest
    private static void createDPALNTest(){
        //created an admin user
    	List<User> adminUserlst = PSG_Test_Utility.createAdminUser();
        //run as an admin user
        System.runAs(adminUserlst[0]){
            SBQQ.TriggerControl.disable();
            Account acc = PSG_Test_Utility.createAccount();
            Contact con = PSG_Test_Utility.createContact(acc.Id);
            User partnerUser = PSG_Test_Utility.createPartnerUser(acc.Id);
            //created the Quote records
            List<SBQQ__Quote__c> lstquote = PSG_Test_Utility.createQuote(acc.Id, partnerUser.ContactId, 1);
            lstquote[0].Pricing_Quote_Program_Nm__c = 'Tender';
            update lstquote[0];
            Map<String,SBQQ__Quote__c> quoteMap = new Map<String,SBQQ__Quote__c>();
            quoteMap.put(lstquote[0].id,lstquote[0]);
            //created the QuoteLine records
            List<SBQQ__QuoteLine__c> lstquoteLines= PSG_Test_Utility.createQuoteLines(lstquote[0].id,1);
            Map<String,SBQQ__QuoteLine__c> quoteLineMap = new Map<String,SBQQ__QuoteLine__c>();
            quoteLineMap.put(lstquoteLines[0].id,lstquoteLines[0]);
            Test.startTest();
            //calls the createDPA method with the created data as parameter
            Id DPA_record=PSG_RequestDPA.createDPA(lstquoteLines,quoteLineMap,quoteMap);
            //calls the createALN method with the created data as parameter
            Id ALN_record=PSG_RequestDPA.createALN(lstquoteLines,quoteLineMap,quoteMap);
            List<core_cpq_dpa_aln__c> dpa = [select id from core_cpq_dpa_aln__c where core_cpq_record_type_identifier__c = 'DPA' limit 1];
            System.assertEquals(DPA_record,dpa[0].Id);
            Test.stopTest();
        }
    }*/

}