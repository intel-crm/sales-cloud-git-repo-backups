@isTest
public with sharing class ProcessProfileResponseBatchTest {
    @TestSetup
    static void setupData(){
        Id accountRecordTypeIntel = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
       //Id contactRecordType = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Contact).getRecordTypeId();
        
        Account account = PRM_TestUtility.getAccount();
        account.AccountNumber = '435710';
        account.RecordTypeId = accountRecordTypeIntel;
        account.Name='New Account';
        account.Core_Account_Type__c ='Distributor';
        account.Industry='Agriculture';
        account.BillingCity='New Delhi';
        account.BillingCountryCode='IND';
        account.BillingStreet='4th Floor,New Road';
        account.BillingPostalCode='110037';
        account.BillingStateCode='KA';
        account.Core_IPA_Partner_Role__c = 'Distributor';
        account.Core_IPA_Badge_Tier__c = 'Partner';
        insert account;
        
        Contact contact = PRM_TestUtility.getContact();
        contact.AccountId = account.Id;
        contact.Email='user.check@maildrop.cc';
        contact.Core_Preferred_Language__c = 'ENG';
        contact.Core_eRPM_Language_Code__c = 'ENG';
        //contact.RecordTypeId = contactRecordType;
        contact.Core_Do_Not_Contact__c = false;
        //contact.Core_IPA_Partner_Role__c = 'Distributor';
        contact.Core_IPA_PartnerRole__c = 'Distributor';
        contact.Core_Login_Id__c = 'abc';
	contact.mailingcountry='India';
        insert contact;
        
        ChannelProgram channelPrg = new ChannelProgram();
        channelPrg.name='Intel Partner Alliance';
        channelPrg.PRM_programCode__c='IPA';
        channelPrg.PRM_inactind__c=true;
        insert channelPrg;  
    }

    @isTest
    public static void testRegReqApprove(){
        Account account = [Select id from Account limit 1];
        Contact contact = [Select id from Contact limit 1];
        ChannelProgram channelPrg = [Select id from ChannelProgram limit 1];
        Test.startTest();
        PRM_Registration_Request__c prmRegRequest = new PRM_Registration_Request__c();
        prmRegRequest.Name = 'checkuser';
        prmRegRequest.PRM_Salesforce_ID__c = account.Id;
        prmRegRequest.PRM_Channel_Program__c =channelPrg.Id;
        prmRegRequest.PRM_Partner_Role__c='Distributor';
        prmRegRequest.PRM_First_Name__c='Check';
        prmRegRequest.PRM_Last_Name__c='User';
        prmRegRequest.PRM_Email_ID__c='checkuser@mailinator.com';
        //prmRegRequest.PRM_Job_Function__c='Branch Manager';
        prmRegRequest.PRM_Contact_Country__c='US';
        prmRegRequest.PRM_Legal_Agreements__c='IPA_TANDC';
        prmRegRequest.PRM_Status__c = 'New';
        prmRegRequest.PRM_TriggerProcess__c = false;
        prmRegRequest.PRM_Auto_Approve__c = false;
        prmRegRequest.Sync_Profile_Response__c = true;
        prmRegRequest.PRM_New_Account__c=account.id;
        prmRegRequest.PRM_Matching_Contact__c=contact.id;
        prmRegRequest.PRM_Profile_Response__c='[\"{QuestionCode : project_budget | ResponseCode :pro_bud_2L_to_5L | ResponseValue : $200,000 - $500,000}\"]';
        prmRegRequest.RecordTypeId = Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Account_Create_Request).getRecordTypeId();
        insert prmRegRequest;
 
        PRM_Registration_Req_Approve_Reject.approvalWrapper apWrp = new PRM_Registration_Req_Approve_Reject.approvalWrapper();
        apWrp = PRM_Registration_Req_Approve_Reject.fetchApprovalRecord(prmRegRequest.id);
		String approvalId  = apWrp.workItemId;
        PRM_Registration_Req_Approve_Reject.regreqApproveRejectNew(prmRegRequest.id,approvalId,'Approved', 'Approved');
        Database.executebatch(new ProcessProfileResponseBatch(), 1);
        //ProcessProfileResponseBatch.processProfileResponseBatchSchedular(10);
        Test.stopTest();
        //Database.executebatch(new ProcessProfileResponseBatch(), 1);
        ER_ErrorUtility.CustomException custEx = new ER_ErrorUtility.CustomException();
        custEx.Message = 'Test ErrorLog';
        custEx.StackTraceString = 'Testing';
        custEx.LineNumber = 101;                
        custEx.TypeName = 'ER_ErrorUtility';
        ProcessProfileResponseBatch.createLogEntry('Test',prmRegRequest.id,custEx,'MEDIUM');
        ProcessProfileResponseBatch.processProfileResponseBatchSchedular(10);
    }

 

}