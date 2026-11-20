/*********************************************************************************************************************
Apex Class Name  : PRM_SBRCallOut_Test
Version          : 1.0
Created Date     : Dec 2023
Function         : Test class

Modification Log :
* Developer                 Date                    Description
* --------------------------------------------------------------------------------------------------------------------
* Shraddha More           26 Nov 2023              test class of PRM_SBRCallOut
*********************************************************************************************************************/
@isTest
public class PRM_SBRCallOut_Test {
    
     @testSetup
    //test data creation
    static void setupDataCreation(){
        ChannelProgram ipaProgram = new ChannelProgram();
        ipaProgram.Name='Intel Partner Alliance';
        ipaProgram.PRM_programCode__c='IPA';
        insert ipaProgram;
        
        PRM_Registration_Request__c rr5 = PRM_TestUtility.getPRMRegistrationRequest();
        rr5.PRM_First_Name__c = 'Kenneth';
        rr5.PRM_Last_Name__c = 'Hollingsworth';
        rr5.PRM_Email_ID__c = 'kenneth.hollingsworth@mailinator.com';
        rr5.PRM_Preferred_Language__c='ENG';
        rr5.PRM_Company_Email_Domain__c='intel.com';
        rr5.PRM_Address_Line_1__c='4th Floor,ITPL Main Road';
        rr5.PRM_Address_Line_2__c='Bengaluru,India'; 
        rr5.PRM_City__c='Las Vegas';
        rr5.PRM_Contact_Login_ID__c = 'user222@outlook.com';
        rr5.PRM_Enterprise_ID__c = '76567';
        rr5.PRM_Profession__c = 'PROFESSOR';
        rr5.PRM_Person_Phone_Number__c = '9999999999';
        rr5.PRM_Subscriptions__c = 'CSP_Sub';
        rr5.RecordTypeId = PRM_IPA_Constants.ACCOUNT_CREATE_REQUEST_RT;
        rr5.PRM_Partner_Role__c = 'Manufacturer';
        rr5.PRM_Channel_Program__c = ipaProgram.Id;
        rr5.PRM_Account_Name__c = 'CHP';
        rr5.PRM_Account_URL__c = 'www.CHP.com';
        rr5.PRM_Country__c = 'GBR';
        rr5.PRM_State_Province__c = 'ENG';
        insert rr5;
    }
    
    @isTest static void testSBRCallout() {
       /* Account acc = [SELECT id,Name,Core_Business_Party_Id__c,BillingCountryCode,BillingStateCode,BillingCountry,BillingCity,BillingPostalCode,
                       BillingStreet,Owner.Name,Core_MDM_Website__c,RecordType.Name,Core_Customer_Aggregation_Type__c,Core_Unified_Global_Customer__c,
                       Core_Sales_Groups__c,Core_Unified_Global_Customer__r.Name, Core_Unified_Intermediate_Customer__c, Unified_Hierarchy_View__c,
                       ParentId, BillingState, Core_Requested_Name__c, Parent.Core_Customer_Aggregation_Type__c,Core_User_Defined_Website__c,
                       Core_Unified_Intermediate_Customer_2__c  FROM Account WHERE Name = 'CHP'];*/

        ChannelProgram cp1 = [Select Id from ChannelProgram where Name = 'Intel Partner Alliance' LIMIT 1];

        
        Profile communityUsrProfile = [SELECT id FROM Profile WHERE Name='IT Admin'];

        
        User partnerUser = new User(FirstName='MrTest',LastName='User',alias='t2user',Email='test.diqhwqi@deloitte.com',
                                    UserName='test2udwvgsr@xyz.com',ProfileId=communityUsrProfile.Id,
                                    emailencodingkey='UTF-8', languagelocalekey='en_US', localesidkey='en_US',timezonesidkey='Europe/London');//, UserRoleId = r.id);
        
        insert partnerUser;
        
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
        //acc.Core_Sales_Groups__c = 'Global Solutions & Services Sales Group';
        //acc.Core_Unified_Intermediate_Customer__c = null;
        acc.Unified_Hierarchy_View__c = '';
        acc.ParentId = null;
        acc.Core_Requested_Name__c = 'CHP';
        acc.Core_User_Defined_Website__c = 'www.CHP.com';
        acc.Website = 'www.CHP.com';
        //acc.Core_Unified_Intermediate_Customer_2__c = null;
        acc.OwnerId = partnerUser.Id;
        
        insert acc;
        Map<String,String> parentAccMap = new Map<String,String>();
        map<string,boolean> mapOfAccWithBlokedStatus=new Map<String,Boolean>();
        mapOfAccWithBlokedStatus.put(acc.id,true);
        List<PRM_AdminRegistrationDuplicateDetails.matchingAccWrapper> wrpList = new List<PRM_AdminRegistrationDuplicateDetails.matchingAccWrapper>();
        List<PRM_AdminRegistrationDuplicateDetails.matchingAccWrapper> wrpList1 = new List<PRM_AdminRegistrationDuplicateDetails.matchingAccWrapper>();
        PRM_AdminRegistrationDuplicateDetails.matchingAccWrapper wrp = new PRM_AdminRegistrationDuplicateDetails.matchingAccWrapper();
        wrp = PRM_AdminRegistrationDuplicateDetails.setMatchingAccWrapper(acc,parentAccMap,mapOfAccWithBlokedStatus);
        wrpList.add(wrp);

        PRM_Registration_Request__c newRequest = PRM_TestUtility.getPRMRegistrationRequest();
        newRequest.PRM_Status__c ='New';
        newRequest.PRM_CIM_ID__c='';
        newRequest.PRM_EmailVerifiedDateTime__c=null;
        newRequest.PRM_EV_Token__c = 'gwiur#@98321327';
        newRequest.PRM_Email_ID__c = 'testuseasdr@gmail.com';
        newRequest.PRM_Channel_Program__c = cp1.id;
        newRequest.PRM_Legal_Agreements__c = 'IPA_TANDC';
        newRequest.PRM_Partner_Relationship__c = '';
        newRequest.PRM_Preferred_Language__c = '';
        newRequest.PRM_Partner_Type__c =null;
        newRequest.recordTypeId = PRM_IPA_Constants.ACCOUNT_CREATE_REQUEST_RT;
        newRequest.PRM_Salesforce_ID__c = null;
        newRequest.PRM_Contact_Login_ID__c = 'testuser@gmail.com';
        newRequest.PRM_Profile_Response__c = 'test pr';
        newRequest.PRM_EmailVerifiedDateTime__c=system.now();
        newRequest.PRM_Email_Verification_Criteria__c = System.Label.PRM_Pending;
        newRequest.PRM_City__c = 'qwerty';
        newRequest.PRM_Contact_Country__c = 'us';
        newRequest.PRM_Account_Name__c = 'CHP';
        newRequest.PRM_Account_URL__c = 'www.CHP.com';
        newRequest.PRM_Country__c = 'GBR';
        newRequest.PRM_State_Province__c = 'ENG';
        
        List<PRM_CIMSearchResults__c> sbrList = new List<PRM_CIMSearchResults__c>();

        Test.startTest();
        insert newRequest;
        /*PRM_CIMSearchResults__c sbr = new PRM_CIMSearchResults__c();
        sbr.PRM_Account_Nm__c = 'CHP';
        sbr.PRM_Account_Id__c = acc.Id;
        sbr.PRM_RegReq_Id__c = newRequest.Id;
        sbr.PRM_Source__c = 'Reltio SBR';
        sbr.PRM_AddressLine1_Txt__c = 'Test';
        insert sbr;
        sbrList.add(sbr);*/
        
        PRM_SBRCallOut.sbrCallOut(newRequest, true, 'United Kingdom', 'England');
        PRM_SBRCallOut.insertSBRResults(wrpList, false, newRequest.Id);
        PRM_SBRCallOut.insertSBRResults(wrpList, true, newRequest.Id);
        PRM_SBRCallOut.insertSBRResults(wrpList1, false, newRequest.Id);
        //PRM_SBRCallOut.insertSBRList(sbrList);
        Test.stopTest();
        
        List<PRM_CIMSearchResults__c> sbrList1 = new List<PRM_CIMSearchResults__c>();
        sbrList1 = [SELECT Id, PRM_Account_Id__c, PRM_RegReq_Id__c FROM PRM_CIMSearchResults__c WHERE PRM_RegReq_Id__c =:newRequest.Id];
        system.assertEquals(1,sbrList1.size());
    }
    
    @isTest static void testSBRCalloutRefresh() {
        Id accountRecordTypeIntel = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
        
        Account acc = new Account();
        acc.RecordTypeId = accountRecordTypeIntel;
        acc.Core_IPA_Partner_Role__c = 'Service Provider';
        acc.Core_Account_Type__c = 'Distributor';
        acc.Industry = '';
        acc.Core_Account_Type__c = 'Cloud Service Provider (CSP)';
        acc.BillingCity = 'test data';
        acc.BillingState = 'ENG';
        acc.BillingCountry = 'GBR';
        acc.BillingStreet = '4th Floor test, ITPL, Brookfield';
        acc.BillingPostalCode = '566666';
        acc.Core_MDM_Website__c = 'www.CHP.com';
        acc.Name = 'CHP';
        acc.Core_Business_Party_Id__c = '65432';
        acc.BillingCountryCode = 'GBR';
        acc.BillingStateCode = 'ENG';
        acc.Core_Customer_Aggregation_Type__c = null;
        //acc.Core_Unified_Global_Customer__c = null;
        //acc.Core_Sales_Groups__c = 'Global Solutions & Services Sales Group';
        //acc.Core_Unified_Intermediate_Customer__c = null;
        acc.Unified_Hierarchy_View__c = '';
        acc.ParentId = null;
        acc.Core_Requested_Name__c = 'CHP';
        acc.Core_User_Defined_Website__c = 'www.CHP.com';
        acc.Website = 'www.CHP.com';
        //acc.Core_Unified_Intermediate_Customer_2__c = null;
        insert acc;
        
        Map<String,String> parentAccMap = new Map<String,String>();
        map<string,boolean> mapOfAccWithBlokedStatus=new Map<String,Boolean>();
        mapOfAccWithBlokedStatus.put(acc.id,true);
        List<PRM_AdminRegistrationDuplicateDetails.matchingAccWrapper> wrpList = new List<PRM_AdminRegistrationDuplicateDetails.matchingAccWrapper>();
        PRM_AdminRegistrationDuplicateDetails.matchingAccWrapper wrp = new PRM_AdminRegistrationDuplicateDetails.matchingAccWrapper();
        wrp = PRM_AdminRegistrationDuplicateDetails.setMatchingAccWrapper(acc,parentAccMap,mapOfAccWithBlokedStatus);
        wrpList.add(wrp);
        PRM_Registration_Request__c newRequest = PRM_TestUtility.getPRMRegistrationRequest();
        newRequest.PRM_Status__c ='New';
        newRequest.PRM_CIM_ID__c='';
        newRequest.PRM_EmailVerifiedDateTime__c=null;
        newRequest.PRM_EV_Token__c = 'gwiur#@98321327';
        newRequest.PRM_Email_ID__c = 'testuseasdrrr@gmail.com';
        newRequest.PRM_Legal_Agreements__c = 'IPA_TANDC';
        newRequest.PRM_Partner_Relationship__c = '';
        newRequest.PRM_Preferred_Language__c = '';
        newRequest.PRM_Partner_Type__c =null;
        newRequest.recordTypeId = PRM_IPA_Constants.ACCOUNT_CREATE_REQUEST_RT;
        newRequest.PRM_Salesforce_ID__c = null;
        newRequest.PRM_Contact_Login_ID__c = 'testuser@gmail.com';
        newRequest.PRM_Profile_Response__c = 'test pr';
        newRequest.PRM_EmailVerifiedDateTime__c=system.now();
        newRequest.PRM_Email_Verification_Criteria__c = System.Label.PRM_Pending;
        newRequest.PRM_City__c = 'qwerty';
        newRequest.PRM_Contact_Country__c = 'us';
        newRequest.PRM_Account_Name__c = 'CHP';
        newRequest.PRM_Account_URL__c = 'www.CHP.com';
        newRequest.PRM_Country__c = 'GBR';
        newRequest.PRM_State_Province__c = 'ENG';
        insert newRequest;
     
        Test.startTest();
        PRM_SBRCallOut.insertSBRResults(wrpList, true, newRequest.Id);
        Test.stopTest();
        
        List<PRM_CIMSearchResults__c> sbrList1 = new List<PRM_CIMSearchResults__c>();
        sbrList1 = [SELECT Id, PRM_Account_Id__c, PRM_RegReq_Id__c FROM PRM_CIMSearchResults__c WHERE PRM_RegReq_Id__c =:newRequest.Id];
        system.assertEquals(1,sbrList1.size());
    }

}