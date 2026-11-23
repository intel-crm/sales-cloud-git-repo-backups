/****************************************************************************************************
Apex Class Name : PSG_SendSAPRequestFutureClass_Test
Version         : 1.0 
Created Date    : 08/13/2021
Function        : Test class for PSG_SendSAPRequestFutureClass.
Modifications   :
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Hari Kiran K              08/13/2021                Created
*****************************************************************************************************/
@isTest
public class PSG_SendSAPRequestFutureClass_Test {
	/*@TestSetup
    private static void createTestData(){
        List<User> sosUserList = PSG_Test_Utility.createSOSUser();
        System.runAs(sosUserList[0]){
            SBQQ.TriggerControl.disable();
            Account acc1 = PSG_Test_Utility.createDirectAccount();
            Account acc = PSG_Test_Utility.createAccount();
            Contact con = PSG_Test_Utility.createContact(acc.Id);
            User partnerUser = PSG_Test_Utility.createPartnerUser(acc.Id);
            List<SBQQ__Quote__c> lstquote = PSG_Test_Utility.createQuote(acc.Id, partnerUser.ContactId, 2);
            System.assert(!lstquote.isEmpty(), 'Quotes inserted');
            Test.startTest();
            List<SBQQ__QuoteLine__c> lstquotelines=PSG_Test_Utility.createQuoteLines(lstquote[0].Id, 1);
            lstquotelines[0].core_cpq_dollar_change_flag_cb__c=true;
            lstquotelines[0].core_cpq_quote_line_type_txt__c='AVP';
            lstquotelines[0].core_cpq_active_Pricing__c=false;
            lstquotelines[0].core_cpq_active_Pricing__c=false;
            update lstquotelines[0];
            Test.stopTest();
            List<core_cpq_dpa_aln__c> lstdpa = PSG_Test_Utility.createDPARecord(lstquote[0],acc1.Id);
            lstdpa[0].core_cpq_record_type_identifier__c='DPA';
            lstdpa[0].core_cpq_status_txt__c='Approved';
            lstdpa[0].core_cpq_change_flag__c='H';
            lstdpa[0].core_cpq_ship_end_date_dt__c=System.today();
            update lstdpa[0];
            List<core_cpq_dpa_aln__c> lstdpa1 = PSG_Test_Utility.createDPARecord(lstquote[0],acc1.Id);
            lstdpa1[0].core_cpq_record_type_identifier__c='DPA';
            lstdpa1[0].core_cpq_status_txt__c='Approved';
            update lstdpa1[0];
            List<core_cpq_dpa_aln_line__c> lstdpaLines=new List<core_cpq_dpa_aln_line__c>();
            if(lstdpa[0] != null){
                lstdpaLines= PSG_Test_Utility.createDPALines(lstdpa[0].Id, 1);
            }  
        }
    }
    
    @isTest
    private static void testFutureMethod(){
        List<core_cpq_dpa_aln__c> dpa=[Select Id from core_cpq_dpa_aln__c Limit 2];
        System.assert(!dpa.isEmpty(), 'DPA Retrieved');
        //Test.setMock(HttpCalloutMock.class, new PSG_Integration_DPA_MockTest());
        Test.startTest();
        PSG_SendSAPRequestFutureClass.bulkSAPRequestFuture(new Set<Id>{dpa[0].Id,dpa[1].Id});
        Test.stopTest();
    }*/
}