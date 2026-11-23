/****************************************************************************************************
Apex Class Name : PSG_SendBulkSAPRequestBatch_Test
Version         : 1.0 
Created Date    : 08/13/2021
Function        : Test class for PSG_SendBulkSAPRequestBatch.
Modifications   :
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Hari Kiran K              08/13/2021                Created
*****************************************************************************************************/
@isTest
public class PSG_SendBulkSAPRequestBatch_Test {
	@TestSetup
    private static void createTestData(){
        List<User> sosUserList = PSG_Test_Utility.createSOSUser();
        System.runAs(sosUserList[0]){
            Account acc1 = PSG_Test_Utility.createDirectAccount();
            Account acc = PSG_Test_Utility.createAccount();
            Contact con = PSG_Test_Utility.createContact(acc.Id);
            User partnerUser = PSG_Test_Utility.createPartnerUser(acc.Id);
            List<SBQQ__Quote__c> lstquote = PSG_Test_Utility.createQuote(acc.Id, partnerUser.ContactId, 2);
            Test.startTest();
            List<SBQQ__QuoteLine__c> lstquotelines=PSG_Test_Utility.createQuoteLines(lstquote[0].Id, 1);
            Test.stopTest();
            List<core_cpq_dpa_aln__c> lstdpa = PSG_Test_Utility.createDPARecord(lstquote[0],acc1.Id);
            lstdpa[0].core_cpq_record_type_identifier__c='DPA';
            lstdpa[0].core_cpq_status_txt__c='Approved';
            lstdpa[0].core_cpq_change_flag__c='H';
            lstdpa[0].core_cpq_ship_end_date_dt__c=System.today();
            lstdpa[0].core_cpq_update_from_batch_cb__c=true;
            update lstdpa[0];
            System.assert(!lstdpa.isEmpty(), 'DPA Inserted');
            List<core_cpq_dpa_aln__c> lstdpa1 = PSG_Test_Utility.createDPARecord(lstquote[0],acc1.Id);
            lstdpa1[0].core_cpq_record_type_identifier__c='DPA';
            lstdpa1[0].core_cpq_status_txt__c='Approved';
            lstdpa[0].core_cpq_update_from_batch_cb__c=true;
            update lstdpa1[0];
        }
    }
    
    @isTest
    private static void testFutureMethod(){
        String dpaNo=[Select id,name from core_cpq_dpa_aln__c LIMIT 1].Name;
        Test.setMock(HttpCalloutMock.class, new PSG_Integration_DPA_MockTest());
        Test.startTest();
		String jobId=Database.executeBatch(new PSG_SendBulkSAPRequestBatch()); 
        PSG_SendBulkSAPRequestBatch job=new PSG_SendBulkSAPRequestBatch();
        job.cisNoList=new List<String>{dpaNo};
            String jobId1=Database.executeBatch(job); 
        Test.stopTest();
        System.assert(jobId != null, 'batch Scheduled');
    }
}