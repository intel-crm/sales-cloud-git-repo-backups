/****************************************************************************************************
Apex Class Name : PSG_UploadDpaAlnTest
Version         : 1.0 
Created Date    : 02/15/2021
Function        : Test class for PSG_UploadDpaAln.
Modifications   :
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Adarsh Parashar            02/15/2021                Created
*****************************************************************************************************/
@isTest
public class PSG_UploadDpaAlnTest {
    @testSetup
    public static void setUpData(){
        SBQQ.TriggerControl.disable();
        List<User> lstUsers2 = PSG_Test_Utility.createAdminUser();
        if(!lstUsers2.isEmpty()){
            system.runAs(lstUsers2[0]){                
                Account acc = PSG_Test_Utility.createAccount();
                Contact con = PSG_Test_Utility.createContact(acc.Id);
                User partnerUser = PSG_Test_Utility.createPartnerUser(acc.Id);
                List<SBQQ__Quote__c> lstquote = PSG_Test_Utility.createQuote(acc.Id, partnerUser.ContactId, 1);
                if(lstquote[0] != null){
                    pricebook2 pb = [Select id from pricebook2 limit 1];
                    lstquote[0].core_cpq_price_book_nm__c = pb.Id;
                    Update lstquote[0];
                    System.assert(lstquote[0].Id!=null,'Quote created');
                    PSG_Test_Utility.createQuoteLines(lstquote[0].Id, 3);
                    List<core_cpq_dpa_aln__c> alnList = new List<core_cpq_dpa_aln__c>(); 
                    core_cpq_dpa_aln__c aln = new core_cpq_dpa_aln__c();
                    core_cpq_dpa_aln__c aln1 = new core_cpq_dpa_aln__c();
                    List<core_cpq_dpa_aln__c> dpaList = new List<core_cpq_dpa_aln__c>(); 
                    core_cpq_dpa_aln__c dpa = new core_cpq_dpa_aln__c();
                    aln.RecordTypeId = Schema.SObjectType.core_cpq_dpa_aln__c.getRecordTypeInfosByDeveloperName().get('PSG_ALN').getRecordTypeId();
                    aln.core_cpq_active_quote__c = lstquote[0].Id;
                    aln.core_cpq_record_type_identifier__c = 'ALN';
                    aln.core_cpq_status_txt__c = 'Approved';
                    aln.core_cpq_ship_end_date_dt__c = System.today();
                    aln.core_cpq_change_flag__c = 'N';
                    alnList.add(aln);
                    aln1.RecordTypeId = Schema.SObjectType.core_cpq_dpa_aln__c.getRecordTypeInfosByDeveloperName().get('PSG_ALN').getRecordTypeId();
                    aln1.core_cpq_active_quote__c = lstquote[0].Id;
                    aln1.core_cpq_record_type_identifier__c = 'ALN';
                    aln1.core_cpq_status_txt__c = 'Submitted';
                    aln1.core_cpq_ship_end_date_dt__c = System.today();
                    aln1.core_cpq_change_flag__c = 'N';
                    alnList.add(aln1);
                    dpa.RecordTypeId = Schema.SObjectType.core_cpq_dpa_aln__c.getRecordTypeInfosByDeveloperName().get('PSG_DPA').getRecordTypeId();
                    dpa.core_cpq_active_quote__c = lstquote[0].Id;
                    dpa.core_cpq_record_type_identifier__c = 'DPA';
                    dpa.core_cpq_status_txt__c = 'Approved';
                    dpa.core_cpq_ship_end_date_dt__c = System.today();
                    dpa.core_cpq_change_flag__c = 'N';
                    dpaList.add(dpa);
                    Test.startTest();
                    insert alnList;
                    Test.stopTest();
                    insert dpaList;
                }
            }
        }
    }
    @isTest
    static void testValidateRecord(){
        SBQQ.TriggerControl.disable();
        List<core_cpq_dpa_aln__c> dpaAln = [Select Id,Name from core_cpq_dpa_aln__c LIMIT 3];
        String cis = '123,123,';
        List<String> success =  new List<String>();
        for(core_cpq_dpa_aln__c str : dpaAln){
            cis += str.Name+',';
            success.add(str.Name);
        }
        cis += ''+dpaAln[0].Name;
        Test.startTest();
        PSG_UploadDpaAln.validateRecord('ALN',cis,'Expire',null);
        Test.stopTest();
        //Test.setMock(HttpCalloutMock.class, new PSG_Integration_DPA_MockTest());
        //if(!Test.isRunningTest){
        	//PSG_UploadDpaAln.submitRecToSAP(success);    
        //}
    }
    @isTest
    private static void testValidateQuoteRecord(){
        SBQQ.TriggerControl.disable();
        List<SBQQ__Quote__c> quoteRec = [Select Id,Name from SBQQ__Quote__c];
        String quoteName = 'Q-123,abc';
        for(SBQQ__Quote__c quote : quoteRec){
            quoteName += quote.Name+',';
        }
        Test.startTest();
        PSG_UploadDpaAln.validateQuoteRecord(quoteName,'revise');
        Test.stopTest();
    }
}