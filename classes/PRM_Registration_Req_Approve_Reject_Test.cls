/*********************************************************************************************************************
Class Name  : PRM_RegistrationApprovalMail_Test
Version       : 1.0
Created Date  : Feb 2022
Function      : Test Class for 'PRM_Registration_Req_Approve_Reject'
*********************************************************************************************************************/
@isTest
public class PRM_Registration_Req_Approve_Reject_Test {
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
        
        Account account01 = PRM_TestUtility.getAccount();
        account01.AccountNumber = '435710';
        account01.RecordTypeId = accountRecordTypeIntel;
        account01.Name='New Account01';
        account01.Core_Account_Type__c ='Distributor';
        account01.Industry='Agriculture';
        account01.BillingCity='New Delhi';
        account01.BillingCountryCode='IND';
        account01.BillingStreet='4th Floor,New Road 01';
        account01.BillingPostalCode='110037';
        account01.BillingStateCode='KA';
        account01.Core_IPA_Partner_Role__c = 'Distributor';
        account01.Core_IPA_Badge_Tier__c = 'Partner';
        insert account01;
        
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
        contact.MailingCountry='India';
        insert contact;
        
        ChannelProgram channelPrg = new ChannelProgram();
        channelPrg.name='Intel Partner Alliance';
        channelPrg.PRM_programCode__c='IPA';
        channelPrg.PRM_inactind__c=true;
        insert channelPrg;  
        
         Core_CustomMetadata_Object__c headerRec = new Core_CustomMetadata_Object__c();
        headerRec.Program__c = 'IPA';
        headerRec.DeveloperName__c = 'DeveloperName';
        headerRec.Field_1_Text_Area_Long__c ='Domains__c';
        headerRec.Field_1__c = 'Country_Code__c';
        headerRec.MasterLabel__c = 'MasterLabel';
        headerRec.Metadata_Name__c = 'Country_Level_Domain_Bypass';
        insert headerRec;
        Core_CustomMetadata_Object__c indRec = new Core_CustomMetadata_Object__c();
        indRec.Program__c = 'IPA';
        indRec.DeveloperName__c = 'India';
        indRec.Field_1_Text_Area_Long__c ='gmail.com;hotmail.com';
        indRec.Field_1__c = 'IND';
        indRec.MasterLabel__c = 'India';
        indRec.Metadata_Name__c = 'Country_Level_Domain_Bypass';
        indRec.Header_row__c = headerRec.id;
        insert indRec;

    }

   /* @isTest
    public static void testRegReqApprove(){
        Account account = [Select id from Account limit 1];
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
        prmRegRequest.PRM_Country__c = 'US';
        prmRegRequest.RecordTypeId = Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Account_Create_Request).getRecordTypeId();
        insert prmRegRequest;
        PRM_Registration_Req_Approve_Reject.approvalWrapper apWrp = new PRM_Registration_Req_Approve_Reject.approvalWrapper();
        apWrp = PRM_Registration_Req_Approve_Reject.fetchApprovalRecord(prmRegRequest.id);
    String approvalId  = apWrp.workItemId;
        try{
            PRM_Registration_Req_Approve_Reject.fetchApprovalRecord(null);
        }catch(exception ex){
            system.debug(ex);
        }
        PRM_Registration_Req_Approve_Reject.regreqApproveRejectNew(prmRegRequest.id,approvalId,'Approved', 'Approved');
        PRM_Registration_Req_Approve_Reject.regreqApproveRejectNew(prmRegRequest.id,'a611A000000Aa77AAA','Approved', 'Approved');
        PRM_Registration_Req_Approve_Reject.getCountryCode('US');
        Test.stopTest();
        System.assert(prmRegRequest != null);
    }*/

    @isTest
    public static void testRegReqReject(){
        Test.startTest();
        Account account = [Select id from Account limit 1];
        ChannelProgram channelPrg = [Select id from ChannelProgram limit 1];
        PRM_Registration_Request__c prmRegRequest1 = new PRM_Registration_Request__c();
        prmRegRequest1.Name = 'checkuser';
        prmRegRequest1.PRM_Salesforce_ID__c = account.Id;
        prmRegRequest1.PRM_Channel_Program__c =channelPrg.Id;
        prmRegRequest1.PRM_Partner_Role__c='Distributor';
        prmRegRequest1.PRM_First_Name__c='Check';
        prmRegRequest1.PRM_Last_Name__c='User';
        prmRegRequest1.PRM_Email_ID__c='checkuser@mailinator.com';
        //prmRegRequest1.PRM_Job_Function__c='Branch Manager';
        prmRegRequest1.PRM_Contact_Country__c='US';
        prmRegRequest1.PRM_Legal_Agreements__c='IPA_TANDC';
        prmRegRequest1.PRM_Status__c = 'Rejected';
        prmRegRequest1.PRM_Country__c = 'US';
        prmRegRequest1.RecordTypeId = Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Account_Create_Request).getRecordTypeId();
        insert prmRegRequest1;
        PRM_Registration_Req_Approve_Reject.approvalWrapper apWrp = new PRM_Registration_Req_Approve_Reject.approvalWrapper();
        apWrp = PRM_Registration_Req_Approve_Reject.fetchApprovalRecord(prmRegRequest1.id);
    String approvalId  = apWrp.workItemId;
        try{
        PRM_Registration_Req_Approve_Reject.regreqApproveRejectNew(prmRegRequest1.id,approvalId, 'Rejected', 'Duplicate');
        }catch(Exception e){
            System.debug('error occured');
        }
        //PRM_Registration_Req_Approve_Reject.ResponseWrap();
        System.assert(prmRegRequest1 != null);
        Test.stopTest();
        PRM_Registration_Req_Approve_Reject.validateData(prmRegRequest1.id);
        PRM_Registration_Req_Approve_Reject.createLogEntry('test','test','test');
        
    }
      @isTest
    public static void testRegReqApprovefail(){
        Account account = [Select id from Account limit 1];
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
        prmRegRequest.PRM_Country__c = 'USA';
        prmRegRequest.RecordTypeId = Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Account_Create_Request).getRecordTypeId();
        insert prmRegRequest;
        
        PRM_Registration_Req_Approve_Reject.approvalWrapper apWrp = new PRM_Registration_Req_Approve_Reject.approvalWrapper();
        apWrp = PRM_Registration_Req_Approve_Reject.fetchApprovalRecord(prmRegRequest.id);
    String approvalId  = apWrp.workItemId;
        
        account.Core_Deactivated__c = true;
        account.Core_Deactivation_Reason__c = 'Account created in error';
        update account; 
        PRM_Registration_Req_Approve_Reject.regreqApproveRejectNew(prmRegRequest.id,approvalId,'Approved', 'Approved');
        PRM_Registration_Req_Approve_Reject.validateData(prmRegRequest.id);
        prmRegRequest.PRM_Salesforce_ID__c = null;
        PRM_Registration_Req_Approve_Reject.createLogEntry('test','test','test');
        PRM_Registration_Req_Approve_Reject.getCountryCode('US');
        Test.stopTest();
        System.assert(prmRegRequest != null);
    }
    
    @isTest
    public static void testRegReqApproveSBRFlow(){
        ChannelProgram channelPrg = [Select id from ChannelProgram limit 1];
        Test.startTest();
        PRM_Registration_Request__c prmRegRequest = new PRM_Registration_Request__c();
        prmRegRequest.Name = 'checkuser';
        prmRegRequest.PRM_Salesforce_ID__c = null;
        prmRegRequest.PRM_Channel_Program__c =channelPrg.Id;
        prmRegRequest.PRM_Partner_Role__c='Distributor';
        prmRegRequest.PRM_First_Name__c='Check';
        prmRegRequest.PRM_Last_Name__c='User';
        prmRegRequest.PRM_Email_ID__c='checkuser@mailinator.com';
        prmRegRequest.PRM_Contact_Country__c='US';
        prmRegRequest.PRM_Legal_Agreements__c='IPA_TANDC';
        prmRegRequest.PRM_Status__c = 'New';
        prmRegRequest.PRM_TriggerProcess__c = false;
        prmRegRequest.PRM_Auto_Approve__c = false;
        prmRegRequest.PRM_Country__c = 'USA';
        prmRegRequest.RecordTypeId = Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Account_Create_Request).getRecordTypeId();
        insert prmRegRequest;
        
        PRM_Registration_Req_Approve_Reject.approvalWrapper apWrp = new PRM_Registration_Req_Approve_Reject.approvalWrapper();
        apWrp = PRM_Registration_Req_Approve_Reject.fetchApprovalRecord(prmRegRequest.id);
    String approvalId  = apWrp.workItemId;
        try{
            PRM_Registration_Req_Approve_Reject.regreqApproveRejectNew(prmRegRequest.id,approvalId,'Approved', 'Approved');
        }catch(exception ex){
            System.debug('Exception occured');
        }
        Test.stopTest();
        System.assert(prmRegRequest != null);
    }

}