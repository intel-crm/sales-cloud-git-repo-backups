/*************************************************************************************************************************************
Apex Class Name     : PRM_AccountRequestEvent_Test 
Created Date        : Dec 2023
Modification Log    :
* Developer                 Date                    Description
* --------------------------------------------------------------------------------------------------------------------------
* Shraddha                Dec - 2023           Test class for Trigger on ACM_Account_Request_Event__e
***************************************************************************************************************************************/
@isTest
public class PRM_AccountRequestEvent_Test {
    
    @testSetup static void setupmethod() {
        Account_Create_Request__c req = new Account_Create_Request__c();
        req.Account_Name__c = 'Sample Account';
        req.Rejected_Reason__c = 'Test Rejected';
        req.Process_Type__c = 'Partner';
        req.Requestor_Name__c = UserInfo.getName();
        req.Requestor_Email__c = UserInfo.getUserEmail()+'.invalid';
        req.State__c = 'New';
        req.Core_Account_Reference_Source_Name__c = 'Partner'; 
        //req.Address__City__s = 'Test';
        //req.Address__CountryCode__s = 'IND'; 
        //req.Address__Street__s = 'Test';
        insert req;
    }
    
    @isTest
    public static void subscribeEventTest() {
        
        Account_Create_Request__c req = [Select Id, Account_Name__c from Account_Create_Request__c where Account_Name__c = 'Sample Account'];
        
        PRM_Registration_Request__c regReq = PRM_TestUtility.getPRMRegistrationRequest();
        regReq.PRM_Account_Request_Queue__c = req.Id;
        regReq.PRM_Status__c = 'Pending';
        regReq.PRM_Review_Note_txt__c = 'Test';
        insert regReq;
        
        Approval.ProcessSubmitRequest apReq = new Approval.ProcessSubmitRequest();
        apReq.setComments('Submitting for approval.');
        apReq.setObjectId(regReq.Id);
        
        // Submit the request for approval
        Approval.ProcessResult result = Approval.process(apReq);
        
        ACM_Account_Request_Event__e testEvent = new ACM_Account_Request_Event__e();
        testEvent.Message__c =  '{"Status":"Approved","RequestId":"'+ req.Id +'","RejectionReason":"","AccountReferenceSourceName":"Partner","AccountId":"001o000000OTBhPAAX","Account":{"SecondaryAddress":{"TypeCode":"Shipping","CountryName":"Albania","CountryCode":"ALB"},"RequestedAccountRejectionReason":"","RequestedAccountRejectionNotes":"","RecordType":"Intel Account","PrimaryAddress":{"TypeCode":"Billing","CountryName":"Albania","CountryCode":"ALB"},"MasteredSimplifiedAccountName":"UCDAutomation_AandE_1699353227703","MasteredBusinessPhysicalAddress":{"CountryName":"Albania"},"CustomerProcessEngagement":[{"Name":"Sales CRM","Code":"SLS_CRM"}],"CustomerAggregationType":{"Name":"Unified Intermediate Customer","Code":"UNFD_INTRMD_CUST"},"BusinessPartyIdentifier":"1001425297","AccountName":"Google EMEA","AccountId":"001o000000OTBhPAAX"}}';
        Test.startTest();
        Database.saveResult sr = EventBus.publish(testEvent);
        Test.stopTest();
        system.assertEquals(regReq.PRM_Review_Note_txt__c, 'Test');
    }
    
    @isTest
    public static void rejectEventTest() {
        Account_Create_Request__c req = [Select Id, Account_Name__c from Account_Create_Request__c where Account_Name__c = 'Sample Account'];
        
        PRM_Registration_Request__c regReq = PRM_TestUtility.getPRMRegistrationRequest();
        regReq.PRM_Account_Request_Queue__c = req.Id;
        regReq.PRM_Status__c = 'Pending';
        regReq.PRM_Review_Note_txt__c = 'Test';
        insert regReq;
        
        ACM_Account_Request_Event__e testEvent = new ACM_Account_Request_Event__e();
        testEvent.Message__c =  '{"Status":"Rejected","RequestId":"'+ req.Id +'","AccountReferenceSourceName":"Partner","RejectionReason":"Test","AccountId":"001D300000o57OlIAI","Account":{"SecondaryAddress":{"TypeCode":"Shipping","CountryName":"Albania","CountryCode":"ALB"},"RequestedAccountRejectionReason":"","RequestedAccountRejectionNotes":"","RecordType":"Rejected Account","PrimaryAddress":{"TypeCode":"Billing","CountryName":"Albania","CountryCode":"ALB"},"MasteredSimplifiedAccountName":"UCDAutomation_AandE_1699581320849","MasteredBusinessPhysicalAddress":{"CountryName":"Albania"},"CustomerProcessEngagement":[{"Name":"Sales CRM","Code":"SLS_CRM"}],"CustomerAggregationType":{"Name":"Unified Intermediate Customer","Code":"UNFD_INTRMD_CUST"},"BusinessPartyIdentifier":"1001426399","AccountName":"UCDAutomation_AandE_1699581320849","AccountId":"001D300000o57OlIAI"}}';
        Test.startTest();
        Database.saveResult sr = EventBus.publish(testEvent);
        Test.stopTest();        
        system.assertEquals(regReq.PRM_Review_Note_txt__c, 'Test');
    }
    
    @isTest
    public static void reuseEventTest() {
        Account_Create_Request__c req = [Select Id, Account_Name__c from Account_Create_Request__c where Account_Name__c = 'Sample Account'];
        
        PRM_Registration_Request__c regReq = PRM_TestUtility.getPRMRegistrationRequest();
        regReq.PRM_Account_Request_Queue__c = req.Id;
        regReq.PRM_Status__c = 'Pending';
        regReq.PRM_Review_Note_txt__c = 'Test';
        insert regReq;
        
        ACM_Account_Request_Event__e testEvent = new ACM_Account_Request_Event__e();
        testEvent.Message__c =  '{"Status":"Rejected","RequestId":"'+ req.Id +'","AccountReferenceSourceName":"Partner","RejectionReason":"Reuse Account: ABC","AccountId":"001D300000o57OlIAI","Account":{"SecondaryAddress":{"TypeCode":"Shipping","CountryName":"Albania","CountryCode":"ALB"},"RequestedAccountRejectionReason":"","RequestedAccountRejectionNotes":"","RecordType":"Intel Account","PrimaryAddress":{"TypeCode":"Billing","CountryName":"Albania","CountryCode":"ALB"},"MasteredSimplifiedAccountName":"UCDAutomation_AandE_1699581320849","MasteredBusinessPhysicalAddress":{"CountryName":"Albania"},"CustomerProcessEngagement":[{"Name":"Sales CRM","Code":"SLS_CRM"}],"CustomerAggregationType":{"Name":"Unified Intermediate Customer","Code":"UNFD_INTRMD_CUST"},"BusinessPartyIdentifier":"1001426399","AccountName":"UCDAutomation_AandE_1699581320849","AccountId":"001D300000o57OlIAI"}}';
        Test.startTest();
        Database.saveResult sr = EventBus.publish(testEvent);
        Test.stopTest();
        system.assertEquals(regReq.PRM_Review_Note_txt__c, 'Test');
    }
    
    @isTest
    public static void createWrapper() {
        Id accountRecordTypeIntel = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
        
        Account acc = new Account();
        acc.RecordTypeId = accountRecordTypeIntel;
        acc.Core_IPA_Partner_Role__c = 'Service Provider';
        acc.Core_Account_Type__c = 'Distributor';
        acc.Industry = '';
        acc.Core_Account_Type__c = 'Cloud Service Provider (CSP)';
        acc.BillingCity = 'test';
        acc.BillingState = 'ENG';
        acc.BillingCountry = 'GBR';
        acc.BillingStreet = '4th Floor, ITPL, Brookfield';
        acc.BillingPostalCode = '560037';
        acc.Core_MDM_Website__c = 'www.CHP.com';
        acc.Name = 'CHP';
        acc.Core_Business_Party_Id__c = '65432';
        acc.BillingCountryCode = 'GBR';
        acc.BillingStateCode = 'ENG';
        acc.Core_Customer_Aggregation_Type__c = null;
        //acc.Core_Unified_Global_Customer__c = null;
        //acc.Core_Unified_Intermediate_Customer__c = null;
        acc.Unified_Hierarchy_View__c = '';
        acc.ParentId = null;
        acc.Core_Requested_Name__c = 'CHP';
        acc.Core_User_Defined_Website__c = 'www.CHP.com';
        acc.Website = 'www.CHP.com';
        //acc.Core_Unified_Intermediate_Customer_2__c = null;    
        insert acc;
        
        account acc1 = new account();
        acc1.RecordTypeId = accountRecordTypeIntel;
        acc1.Core_IPA_Partner_Role__c = 'Service Provider';
        acc1.Core_account_Type__c = 'Distributor';
        acc1.Industry = '';
        acc1.Core_account_Type__c = 'Cloud Service Provider (CSP)';
        acc1.BillingCity = 'test';
        acc1.BillingState = 'ENG';
        acc1.BillingCountry = 'GBR';
        acc1.BillingStreet = '4th Floor, ITPL, Brookfield';
        acc1.BillingPostalCode = '560037';
        acc1.Core_MDM_Website__c = 'www.CHP.com';
        acc1.Name = 'Test Account';
        acc1.Core_Business_Party_Id__c = '65432';
        acc1.BillingCountryCode = 'GBR';
        acc1.BillingStateCode = 'ENG';
        acc1.Core_Customer_Aggregation_Type__c = null;
        //acc1.Core_Unified_Global_Customer__c = null;
        //acc1.Core_Unified_Intermediate_Customer__c = null;
        acc1.Unified_Hierarchy_View__c = '';
        acc1.ParentId = acc.Id;
        acc1.Core_Requested_Name__c = 'CHP';
        acc1.Core_User_Defined_Website__c = 'www.CHP.com';
        acc1.Website = 'www.CHP.com';
        //acc1.Core_Unified_Intermediate_Customer_2__c = null;
        insert acc1;
        
        Map<Id,Account> parentAccountById = new Map<Id,Account>();
        parentAccountById.put(acc.Id, acc);
        
        //do the mapping here
        PRM_UCD_ResponseWrapper.AccountAddress address = new PRM_UCD_ResponseWrapper.AccountAddress();
        address.TypeCode = 'GRE';
        address.CountryCode = 'GRE';
        address.CountryName = 'United Kingdom';
        
        List<PRM_UCD_ResponseWrapper.CustomerProcessEngagement> cpeList = new List<PRM_UCD_ResponseWrapper.CustomerProcessEngagement>();
        PRM_UCD_ResponseWrapper.CustomerProcessEngagement cpe = new PRM_UCD_ResponseWrapper.CustomerProcessEngagement('GRE', 'United Kingdom');
        cpeList.add(cpe);
        
        List<PRM_UCD_ResponseWrapper.ComplianceWatchList> cwList = new List<PRM_UCD_ResponseWrapper.ComplianceWatchList>();
        PRM_UCD_ResponseWrapper.ComplianceWatchList cw = new PRM_UCD_ResponseWrapper.ComplianceWatchList('GRE', 'United Kingdom');
        cwList.add(cw);
        
        PRM_UCD_ResponseWrapper.MasteredBusinessPhysicalAddress phyAdd = new PRM_UCD_ResponseWrapper.MasteredBusinessPhysicalAddress('GRE', 'United Kingdom');
        
        PRM_UCD_ResponseWrapper.CustomerAggregationType aggType = new PRM_UCD_ResponseWrapper.CustomerAggregationType('GRE', 'United Kingdom');
        
        PRM_UCD_ResponseWrapper.AccountResponseModel responseModel = new PRM_UCD_ResponseWrapper.AccountResponseModel();
        String objectName = 'Account';
        responseModel.accountId = acc1.Id;
        responseModel.accountName = acc1.Name != null ? acc1.Name:'';
        responseModel.SurvivorAccountId = acc1.Core_Survivor_Account_Id__c != null ? acc1.Core_Survivor_Account_Id__c : null;
        responseModel.businessPartyIdentifier = acc1.Core_Business_Party_Id__c != null ? acc1.Core_Business_Party_Id__c:'';
        responseModel.masteredSimplifiedAccountName = acc1.Core_Data_Simplified_Account_Nm__c != null ? acc1.Core_Data_Simplified_Account_Nm__c : '';
        //responseModel.dataSimplifiedAccountName = account.Core_Data_Simplified_Account_Nm__c != null ? account.Core_Data_Simplified_Account_Nm__c : '';
        responseModel.recordType = Schema.getGlobalDescribe().get(objectName).getDescribe().getRecordTypeInfosById().get(acc1.RecordTypeId).getName();
        responseModel.requestedAccountRejectionReason = acc1.Core_Account_Request_Rejection_Reason__c != null ? UCD_ACM_Utils.getPicklistLabel(objectName,'Core_Account_Request_Rejection_Reason__c',acc1.Core_Account_Request_Rejection_Reason__c) : '';
        responseModel.requestedAccountRejectionNotes = acc1.Core_Account_Request_Rejection_Notes__c != null ? acc1.Core_Account_Request_Rejection_Notes__c : '';
        responseModel.primaryAddress = address;
        responseModel.secondaryAddress = address;
        responseModel.masteredBusinessPhysicalAddress = phyAdd;
        responseModel.customerAggregationType = aggType;
        responseModel.CustomerProcessEngagement = cpeList;
		responseModel.ComplianceWatchList = cwList;
        // Create Parent Account Refrence
        PRM_UCD_ResponseWrapper.AccountResponseModel responseModelForParent = new PRM_UCD_ResponseWrapper.AccountResponseModel();
        responseModelForParent.accountId = acc1.parentId;
        responseModelForParent.accountName = parentAccountById.get(acc1.parentId).Name != null?parentAccountById.get(acc1.parentId).Name:'';
        responseModelForParent.businessPartyIdentifier = parentAccountById.get(acc1.parentId).Core_Business_Party_Id__c != null?parentAccountById.get(acc1.parentId).Core_Business_Party_Id__c:'';
        responseModelForParent.MasteredSimplifiedAccountName = parentAccountById.get(acc1.parentId).Core_Data_Simplified_Account_Nm__c != null?parentAccountById.get(acc1.parentId).Core_Data_Simplified_Account_Nm__c:'';
        responseModel.parentAccount = responseModelForParent;
        
        system.assertEquals(acc1.Website, 'www.CHP.com');
        
    }
}