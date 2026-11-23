/**************************************************************************************************************************************
Class Name      : PRM_Unlocking_RegReqRecords_Test
Version         : 1.0
Created Date    : Dec 2018
Created By      : Anupam Agarwal
Function        : Test Class for 'PRM_Unlocking_RegRecords'

Modification Log :
* Developer                 Date                    Description
* ----------------------------------------------------------------------------------------------
* Anupam Agarwal            31/12/2018              This class is used as the test class for the PRM_Unlocking_RegRecords class.

***************************************************************************************************************************************/
@isTest
public class PRM_Unlocking_RegReqRecords_Test {
    //Test data creation
    
    static testmethod void setupDataCreation()
    {
        Id addContactRequestRT = Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Add_Contact_Request).getRecordTypeId();
        Id addMembershipRequestRT = Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Add_Membership_Request).getRecordTypeId();
        Id accountRecordTypeIntel = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
        Id accountCreateRequestRT = Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Account_Create_Request).getRecordTypeId(); 
        
        Account acc = PRM_TestUtility.getAccount();
        acc.RecordTypeId = accountRecordTypeIntel;
        acc.BillingCity='Bengaluru';
        acc.BillingCountry='India';
        acc.BillingStreet='4th Floor,ITPL,Brookfield';
        acc.BillingPostalCode='560037';
        insert(acc);
        
        Account a = PRM_TestUtility.getAccount();
        a.RecordTypeId = accountRecordTypeIntel;
        a.Name='New Account';
        a.Core_Account_Type__c ='Distributor';
        a.Industry='Agriculture';
        //a.Company_Domain__c='intel.com';
        a.BillingCity='Delhi';
        a.BillingCountry='India';
        a.BillingStreet='4th Floor,New Road';
        a.BillingPostalCode='110037';
        insert(a);
        
        ChannelProgram cprogram = new ChannelProgram();
        cprogram.Name='Intel Partner Alliance';
        cprogram.PRM_programCode__c='IPA';
        insert(cprogram);
        
        ChannelProgram cp = new ChannelProgram();
        cp.Name='New Partner Program';
        cp.PRM_programCode__c='NPP';
        insert(cp);
        
        PRM_AccountChannelMembership__c  accChannelMembership = PRM_TestUtility.getMembership();
        accChannelMembership.PRM_Account_Id__c = a.Id;
        accChannelMembership.PRM_Channel_Program_Id__c = cp.Id;
        accChannelMembership.PRM_Partner_Role__c='Seller';
        insert(accChannelMembership);
        
        PRM_AccountChannelMembership__c  acm = PRM_TestUtility.getMembership();
        acm.PRM_Account_Id__c = acc.Id;
        acm.PRM_Channel_Program_Id__c = cprogram.Id;
        insert(acm);
        
        List<PRM_Registration_Request__c> rr = new List<PRM_Registration_Request__c>();
        PRM_Registration_Request__c firstNewRequest = PRM_TestUtility.getPRMRegistrationRequest();
        firstNewRequest.Name = 'First approval Scnerio';
        firstNewRequest.RecordTypeId=accountCreateRequestRT;
        firstNewRequest.PRM_DeDup_Criteria__c='SUCCESS';
        firstNewRequest.PRM_Email_Verification_Criteria__c='SUCCESS';
        firstNewRequest.PRM_Legal_Agreement_Criteria__c='';
        firstNewRequest.PRM_CIM_ID__c=null;
        firstNewRequest.PRM_Salesforce_ID__c=null;
        firstNewRequest.PRM_Channel_Program__c=cprogram.Id;
        firstNewRequest.PRM_Partner_Relationship__c = System.Label.PRM_Primary_Contact;
        //firstNewRequest.PRM_Job_Function__c = 'BR-MGR';
        firstNewRequest.PRM_Profession__c = 'Consultant';
        firstNewRequest.PRM_Partner_Type__c = 'Cloud Service Provider (CSP)';
        firstNewRequest.PRM_EmailVerifiedDateTime__c=System.Today();
        insert firstNewRequest;
        rr.add(firstNewRequest);
        
        
        
        PRM_Registration_Request__c secondNewRequest = PRM_TestUtility.getPRMRegistrationRequest();
        secondNewRequest.Name = 'First approval Scnerio';
        secondNewRequest.RecordTypeId=accountCreateRequestRT;
        secondNewRequest.PRM_DeDup_Criteria__c='';
        secondNewRequest.PRM_Email_Verification_Criteria__c='';
        secondNewRequest.PRM_Legal_Agreement_Criteria__c='';
        secondNewRequest.PRM_CIM_ID__c=null;
        secondNewRequest.PRM_Salesforce_ID__c=null;
        secondNewRequest.PRM_Channel_Program__c=cprogram.Id;
        secondNewRequest.PRM_Partner_Relationship__c = System.Label.PRM_Primary_Contact;
        //secondNewRequest.PRM_Job_Function__c = 'BR-MGR';
        secondNewRequest.PRM_Profession__c = 'Consultant';
        secondNewRequest.PRM_Partner_Type__c = 'Cloud Service Provider (CSP)';
        secondNewRequest.PRM_EmailVerifiedDateTime__c=System.Today();
        secondNewRequest.PRM_isLocked__c=True;
        insert secondNewRequest;
        rr.add(secondNewRequest);

        database.insert(rr,False);
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setComments('Submitting request for approval.');
        req1.setObjectId(secondNewRequest.id);
        //Approval.ProcessResult result = Approval.process(req1);
        //System.debug('result'+result);
        PRM_Unlocking_RegRecords.unlockRecords(rr);
        System.assertEquals(secondNewRequest.Name, 'First approval Scnerio', 'Value does not match');
        //Subscription__c subOfFirstRequest = new Subscription__c();  
        //subOfFirstRequest.Name='Firstsub';
        //subOfFirstRequest.PRM_RegistrationRequest__c=firstNewRequest.Id;
        //insert subOfFirstRequest;
        
        //Subscription__c subOfSecondRequest = new Subscription__c();  
       // subOfSecondRequest.Name='Secondsub';
        //subOfSecondRequest.PRM_RegistrationRequest__c=secondNewRequest.Id;
        //insert subOfSecondRequest;
        //System.assertEquals(firstNewRequest.Name, 'First approval Scnerio', 'Value does not match');
        //Approval.ProcessSubmitRequest app = new Approval.ProcessSubmitRequest();
        //app.setObjectId(firstNewRequest.id);
        //Approval.ProcessResult result = Approval.process(app); 
        
    } 
}