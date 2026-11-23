/**************************************************************************************
Apex Class Name : Core_PartnerLeadRoutingHandler_Test
Version     : 1.0 
Created Date: 27th May, 2022
Description : Test class for Core_PartnerLeadRoutingHandler
* Modification Log :
* Developer                 Date                  
* -----------------------------------------------------------------------------------
* Megha Kumari            27/05/2022               
*************************************************************************************/

@isTest
public class Core_PartnerLeadRoutingHandler_Test {
    
    @testSetup 
    public static void setup(){
        Test.startTest();
        
        List<Core_Trigger_Executions__c> triggerExecList = new List<Core_Trigger_Executions__c>();
        Core_Trigger_Executions__c triggerSetting= new  Core_Trigger_Executions__c ();
        triggerSetting.name = 'reprocessPartnerLeadSharing';
        triggerSetting.Core_Object__c = 'Core_Partner_Queue_Mapping__c';
        triggerSetting.Core_Active__c = TRUE;
        triggerSetting.Core_Description__c = 'This is test description';
        triggerSetting.Core_Class_Name__c = 'Core_PartnerQueueMappingTriggerHandler';
        triggerSetting.Core_Trigger_Events__c = 'After Insert, After Update';
        triggerExecList.add(triggerSetting);
        
        Core_Trigger_Executions__c triggerSetting1= new  Core_Trigger_Executions__c ();
        triggerSetting1.name = 'updateStorefrontNameAndId';
        triggerSetting1.Core_Object__c = 'Core_Partner_Queue_Mapping__c';
        triggerSetting1.Core_Active__c = TRUE;
        triggerSetting1.Core_Description__c = 'This is test description';
        triggerSetting1.Core_Class_Name__c = 'Core_PartnerQueueMappingTriggerHandler';
        triggerSetting1.Core_Trigger_Events__c = 'After Insert, After Update';
        triggerExecList.add(triggerSetting1);
        
        insert triggerExecList;
        
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'IT Admin' LIMIT 1];
        
        User us = new User();
        us.FirstName = 'test';
        us.LastName = 'user';
        us.Email = 'testuser@intel.com';
        us.Username = 'testinguser@inteltest.com';
        us.Alias = 'testu';
        us.CommunityNickname = 'test.userqwert';
        us.TimeZoneSidKey = 'America/Los_Angeles';
        us.LocaleSidKey = 'en_US';
        us.EmailEncodingKey = 'UTF-8';
        us.ProfileId = profileId.Id;
        us.LanguageLocaleKey = 'en_US';
        insert us;
        
        List<Account> accList = new List<Account>();
        String AccPartnerRecType = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId();
        Account partnerRec = new Account();
        partnerRec.Name='Test Parent Account1';
        partnerRec.RecordTypeId=AccPartnerRecType;
        partnerRec.Core_IPA_Partner_Segment__c = 'Client Computing;Data Center';
        partnerRec.Core_Account_Type__c='Cloud Service Provider (CSP)';
        partnerRec.BillingCountryCode='USA';
        partnerRec.BIllingStateCode='AL';
        partnerRec.BillingCity='Alabama123';
        partnerRec.BillingStreet='test';
        partnerRec.BillingPostalCode='123445';
        accList.add(partnerRec);
        insert accList;
        
        Core_Account_Group_Member__c Acmem= new Core_Account_Group_Member__c();
        Acmem.Core_Partner_Account_Id__c=partnerRec.id;
        Acmem.Core_MDA_Ind__c=true;
        Insert Acmem;
        String partnerRecTypeId = Schema.SObjectType.Core_Partner_Queue_Mapping__c.getRecordTypeInfosByName().get(Label.Core_Partner_Queue_Mapping_RecordTypeId).getRecordTypeId();
        List<Core_Partner_Queue_Mapping__c> partQueueMapList = new List<Core_Partner_Queue_Mapping__c>();
        Core_Partner_Queue_Mapping__c partQueueMap = new Core_Partner_Queue_Mapping__c();
        partQueueMap.RecordTypeId=partnerRecTypeId;
        partQueueMap.Core_Queue_Name__c = 'test Queue 1';
        partQueueMap.Core_Partner_Name__c = partnerRec.Name;
        partQueueMap.PMP_MDA_BizOrg_Id__c = partnerRec.Id;
        partQueueMap.Core_Active__c=true;         
        partQueueMapList.add(partQueueMap);
        
        Core_Partner_Queue_Mapping__c partQueueMap1 = new Core_Partner_Queue_Mapping__c();
        partQueueMap1.RecordTypeId=partnerRecTypeId;
        partQueueMap1.Core_Queue_Name__c = 'test Queue 2';
        partQueueMap1.Core_Partner_Name__c = 'partnerQueueMap';
        partQueueMap1.PMP_MDA_BizOrg_Id__c = partnerRec.Id;
        partQueueMap1.Core_Active__c=true;
        partQueueMapList.add(partQueueMap1);
        insert partQueueMapList;
        PMP_Company__c marketingProfileInfo = new PMP_Company__c();
        marketingProfileInfo.Name = partnerRec.Name;
        marketingProfileInfo.PMP_Account_Id__c = partnerRec.Id;
        insert marketingProfileInfo;
        PMP_Company__c marketingProfile = [select Id, PMP_Marketing_Profile_Id__c from PMP_Company__c where Id =: marketingProfileInfo.Id];
        
        PMP_Partner_Offering__c offering = new PMP_Partner_Offering__c();
        offering.Name='Offering Test';
        offering.PMP_Partner_Offering_Tag_Line_Txt__c='test tagline';
        offering.PMP_Business_Segment_Nm__c = 'IoT;Server';
        offering.PMP_Company_Id__c = marketingProfile.Id;
        insert Offering;
        PMP_Partner_Offering__c offeringRecord = [select Id, Name, PMP_Offering_Id__c, PMP_Partner_Offering_Tag_Line_Txt__c from PMP_Partner_Offering__c where Id =: Offering.Id];
        Test.stopTest();
    }
    
    @isTest
    public static void  insertUtility() 
    {
        Test.startTest();
        Core_Partner_Queue_Mapping__c partQueueMap = [SELECT Core_Partner_Name__c FROM Core_Partner_Queue_Mapping__c WHERE Core_Queue_Name__c = 'test Queue 1'];
        partQueueMap.Core_Partner_Name__c ='testABC';
        update partQueueMap;
        Test.stopTest();        
    }
    
    @isTest
    public static void  insertUtilityTest() 
    {
        Test.startTest();       
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'IT Admin' LIMIT 1];
        List<Account> accList = new List<Account>();
        String AccPartnerRecType = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId();
        Account partnerRec = [SELECT Id,Name FROM Account WHERE Name = 'Test Parent Account1'];
        Core_Partner_Queue_Mapping__c partQueueMap = [SELECT Id FROM Core_Partner_Queue_Mapping__c WHERE Core_Queue_Name__c = 'test Queue 1'];
        Core_Partner_Queue_Mapping__c partQueueMap1 = [SELECT Id FROM Core_Partner_Queue_Mapping__c WHERE Core_Queue_Name__c = 'test Queue 2'];
        List<Core_Partner_Queue_Mapping__c> partQueueMapList = new List<Core_Partner_Queue_Mapping__c>();  
        PMP_Company__c marketingProfile = [select Id, PMP_Marketing_Profile_Id__c from PMP_Company__c where Name =:partnerRec.Name];
        PMP_Partner_Offering__c offeringRecord = [select Id, Name, PMP_Offering_Id__c, PMP_Partner_Offering_Tag_Line_Txt__c from PMP_Partner_Offering__c where Name='Offering Test'];
        
        PMP_Company__c company = new PMP_Company__c();
        company.Name='company1';
        company.PMP_IPA_Badge_Tier_Txt__c='Gold';
        company.PMP_Partner_Country_Txt__c = 'India';
        company.PMP_Company_Lifecycle_Status_Nm__c ='Draft';
        company.PMP_Is_Published_Ind__c = true;
        company.PMP_Partner_Benefit_Type__c = 'Solutions Marketplace Enhanced';
        insert company;
        
        PMP_OPID_MPI_Rel__c NewOpid = new PMP_OPID_MPI_Rel__c();
        NewOpid.PMP_Marketing_Profile_Id__c = company.id;
        NewOpid.PMP_One_Partner_ID__c = partnerRec.id;
        NewOpid.Is_Active__c = true;
        insert NewOpid;
        
        partQueueMap.Core_Partner_Name__c ='testABC';
        update partQueueMap;
        Test.stopTest();
    }
    
    @isTest(SeeAllData=false) 
    public static void batchTest(){
        User u = [SELECT Id FROM User WHERE Email = 'testuser@intel.com'];
        Account partnerRec = [SELECT Id,Name FROM Account WHERE Name = 'Test Parent Account1'];
        Core_Partner_Queue_Mapping__c partQueueMap = [SELECT Id FROM Core_Partner_Queue_Mapping__c WHERE Core_Queue_Name__c = 'test Queue 1'];
        Core_Partner_Queue_Mapping__c partQueueMap1 = [SELECT Id FROM Core_Partner_Queue_Mapping__c WHERE Core_Queue_Name__c = 'test Queue 2'];
        List<Core_Partner_Queue_Mapping__c> partQueueMapList = new List<Core_Partner_Queue_Mapping__c>();  
        PMP_Company__c marketingProfile = [select Id, PMP_Marketing_Profile_Id__c from PMP_Company__c where Name =:partnerRec.Name];
        PMP_Partner_Offering__c offeringRecord = [select Id, Name, PMP_Offering_Id__c, PMP_Partner_Offering_Tag_Line_Txt__c from PMP_Partner_Offering__c where Name='Offering Test'];
        RecordType r1 = [Select Id from recordType where Name='Partner Lead'];
        List<Lead> lstLeads = new List<Lead>();
        Lead lead1 = new Lead();
        lead1.RecordTypeId = r1.Id;
        lead1.FirstName = 'Test1';
        lead1.LastName = 'Test12';
        lead1.email = 'gerald.reinartz=intel.com@example.com';
        lead1.Phone = '123 4567';
        lead1.Company = 'Test1';
        lead1.CountryCode = 'USA';
        lead1.LeadSource = 'Partner Program';
        lead1.Status='PRL';
        lead1.Core_Lead_Status__c='New';
        lead1.Core_Lead_State__c='Unclaimed';
        lead1.Core_Rejection_Comments__c ='Test'; 
        lead1.Core_Is_Lead_Shared__c=false;
        lead1.Core_MPI_Id__c='tyrr546432etF';
        lead1.PMP_MDA_BizOrg_Id__c = marketingProfile.PMP_Marketing_Profile_Id__c;
        lead1.Core_Partner_Name__c = partnerRec.Name;
        lead1.PMP_MktProfile_BizSegment__c = 'Data Center;Client Computing';
        lead1.OwnerId=label.Core_Partner_Invalid_Queue_Id;
        lstLeads.add(lead1);
        insert lstLeads;
        System.runAs(u){
            Test.startTest();
            Database.executeBatch(new Core_Batch_ReprocessPartnerLeadShare(),200);
            Test.stopTest();   
        }
    }
}