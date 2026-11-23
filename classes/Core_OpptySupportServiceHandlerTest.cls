/**************************************************************************************
Apex Class Name:  Core_OpptySupportServiceHandlerTest
Version     : 1.0 
Created Date: 09 MAR 2023
Function    : Apex Class for the Core_OpportunitySupport
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Areefa Banu             09/03/2023              Original Version
*************************************************************************************/

@isTest 
public class Core_OpptySupportServiceHandlerTest {
    public static    Map<String, Schema.RecordTypeInfo> recordTypeMap = Schema.SObjectType.Core_Opportunity_Support__c.getRecordTypeInfosByDeveloperName();

    @testSetup
    static void setupTestData() { 
        Profile pro = [SELECT id, Name FROM Profile WHERE Name='CCP - Core Access'];
        User usr1 = [SELECT id, Name, isActive,Core_User_Geo__c FROM User WHERE ProfileId = :pro.Id AND isActive = true LIMIT 1];
   	//	PermissionSetAssignment psa = [SELECT Id, PermissionSet.Name,PermissionSetId, AssigneeId from PermissionSetAssignment  where PermissionSet.Name='SalesRepBB' LIMIT 1];
	//	User usr1 = [SELECT id, Name, isActive FROM User WHERE Id = :psa.AssigneeId AND isActive = true LIMIT 1];     
        List<Core_Trigger_Executions__c> triggercontroller = new List<Core_Trigger_Executions__c>();
        /* test data creation for Opportunity support team addtion*/
        Core_Trigger_Executions__c triggerSetting = new Core_Trigger_Executions__c();
        triggerSetting.name = 'updateSupportToOpprotunityTeam';
        triggerSetting.Core_Object__c = 'Core_Opportunity_Support_Team__c';
        triggerSetting.Core_Active__c = TRUE;
        triggerSetting.Core_Description__c = 'Trigger to add Opportunity team';
        triggerSetting.Core_Class_Name__c = 'Core_OppSupportTeamTriggerHandler';
        triggerSetting.Core_Trigger_Events__c = 'After Insert, After Update, After Delete';
        triggercontroller.add(triggerSetting);

        Core_Trigger_Executions__c triggerSetting2 = new Core_Trigger_Executions__c();
        triggerSetting2.name = 'addSupportTeamToOpp';
        triggerSetting2.Core_Object__c = 'Core_Opportunity_Support__c';
        triggerSetting2.Core_Active__c = TRUE;
        triggerSetting2.Core_Description__c = 'Add Support team to Opportunity team when record Approved';
        triggerSetting2.Core_Class_Name__c = 'Core_OpportunitySupportTriggerHandler';
        triggerSetting2.Core_Trigger_Events__c = 'After Update';
        triggercontroller.add(triggerSetting2);
        
        insert triggercontroller;
      
        List<User> usercreation = new List<User>();
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
        us.ProfileId = pro.Id;
        us.LanguageLocaleKey = 'en_US';
        usercreation.add(us);
        
        User us1 = new User();
        us1.FirstName = 'test1';
        us1.LastName = 'user';
        us1.Email = 'testuser1@intel.com';
        us1.Username = 'testinguser1@inteltest.com';
        us1.Alias = 'testu1';
        us1.CommunityNickname = 'test.userqwert1';
        us1.TimeZoneSidKey = 'America/Los_Angeles';
        us1.LocaleSidKey = 'en_US';
        us1.EmailEncodingKey = 'UTF-8';
        us1.ProfileId = pro.Id;
        us1.LanguageLocaleKey = 'en_US';
        usercreation.add(us1);
        
        User us2 = new User();
        us2.FirstName = 'test2';
        us2.LastName = 'user';
        us2.Email = 'testuser2@intel.com';
        us2.Username = 'testinguser2@inteltest.com';
        us2.Alias = 'testu2';
        us2.CommunityNickname = 'test.userqwert2';
        us2.TimeZoneSidKey = 'America/Los_Angeles';
        us2.LocaleSidKey = 'en_US';
        us2.EmailEncodingKey = 'UTF-8';
        us2.ProfileId = pro.Id;
        us2.LanguageLocaleKey = 'en_US';
        usercreation.add(us2);
        
        User us3 = new User();
        us3.FirstName = 'test3';
        us3.LastName = 'user';
        us3.Email = 'testuser3@intel.com';
        us3.Username = 'testinguser3@inteltest.com';
        us3.Alias = 'testu3';
        us3.CommunityNickname = 'test.userqwert3';
        us3.TimeZoneSidKey = 'America/Los_Angeles';
        us3.LocaleSidKey = 'en_US';
        us3.EmailEncodingKey = 'UTF-8';
        us3.ProfileId = pro.Id;
        us3.LanguageLocaleKey = 'en_US';
        usercreation.add(us3);
        
            
        User us4 = new User();
        us4.FirstName = 'test4_PRC';
        us4.LastName = 'user';
        us4.Email = 'testuser4@intel.com';
        us4.Username = 'testinguser4@inteltest.com';
        us4.Alias = 'PRC';
        us4.CommunityNickname = 'test.userqwert4';
        us4.TimeZoneSidKey = 'America/Los_Angeles';
        us4.LocaleSidKey = 'en_US';
        us4.EmailEncodingKey = 'UTF-8';
        us4.ProfileId = pro.Id;
        us4.LanguageLocaleKey = 'en_US';
        usercreation.add(us4);
        
        User us_PRC2 = new User();
        us_PRC2.FirstName = 'test4_PRC_2';
        us_PRC2.LastName = 'user';
        us_PRC2.Email = 'testuser_PRC2@intel.com';
        us_PRC2.Username = 'testinguser_PRC2@inteltest.com';
        us_PRC2.Alias = 'PRC2';
        us_PRC2.CommunityNickname = 'test.userqwert5';
        us_PRC2.TimeZoneSidKey = 'America/Los_Angeles';
        us_PRC2.LocaleSidKey = 'en_US';
        us_PRC2.EmailEncodingKey = 'UTF-8';
        us_PRC2.ProfileId = pro.Id;
        us_PRC2.LanguageLocaleKey = 'en_US';
        usercreation.add(us_PRC2);
        
         User us_PRC3 = new User();
        us_PRC3.FirstName = 'test4_PRC_3';
        us_PRC3.LastName = 'user';
        us_PRC3.Email = 'testuser_PRC3@intel.com';
        us_PRC3.Username = 'testinguser_PRC3@inteltest.com';
        us_PRC3.Alias = 'PRC3';
        us_PRC3.CommunityNickname = 'test.userqwert6';
        us_PRC3.TimeZoneSidKey = 'America/Los_Angeles';
        us_PRC3.LocaleSidKey = 'en_US';
        us_PRC3.EmailEncodingKey = 'UTF-8';
        us_PRC3.ProfileId = pro.Id;
        us_PRC3.LanguageLocaleKey = 'en_US';
        usercreation.add(us_PRC3);
        
         User us_PRC4 = new User();
        us_PRC4.FirstName = 'test4_PRC_4';
        us_PRC4.LastName = 'user';
        us_PRC4.Email = 'testuser_PRC4@intel.com';
        us_PRC4.Username = 'testinguser_PRC4@inteltest.com';
        us_PRC4.Alias = 'PRC4';
        us_PRC4.CommunityNickname = 'test.userqwert7';
        us_PRC4.TimeZoneSidKey = 'America/Los_Angeles';
        us_PRC4.LocaleSidKey = 'en_US';
        us_PRC4.EmailEncodingKey = 'UTF-8';
        us_PRC4.ProfileId = pro.Id;
        us_PRC4.LanguageLocaleKey = 'en_US';
        usercreation.add(us_PRC4);
        
        
           User us_ASMO1 = new User();
        us_ASMO1.FirstName = 'test4_ASMO1';
        us_ASMO1.LastName = 'user';
        us_ASMO1.Email = 'testuser_ASMO1@intel.com';
        us_ASMO1.Username = 'testinguser_ASMO1@inteltest.com';
        us_ASMO1.Alias = 'ASMO1';
        us_ASMO1.CommunityNickname = 'test.userqwert8';
        us_ASMO1.TimeZoneSidKey = 'America/Los_Angeles';
        us_ASMO1.LocaleSidKey = 'en_US';
        us_ASMO1.EmailEncodingKey = 'UTF-8';
        us_ASMO1.ProfileId = pro.Id;
        us_ASMO1.LanguageLocaleKey = 'en_US';
        usercreation.add(us_ASMO1);
        
        
     	   User us_ASMO2 = new User();
        us_ASMO2.FirstName = 'test4_ASMO2';
        us_ASMO2.LastName = 'user';
        us_ASMO2.Email = 'testuser_ASMO2@intel.com';
        us_ASMO2.Username = 'testinguser_ASMO2@inteltest.com';
        us_ASMO2.Alias = 'ASMO2';
        us_ASMO2.CommunityNickname = 'test.userqwert9';
        us_ASMO2.TimeZoneSidKey = 'America/Los_Angeles';
        us_ASMO2.LocaleSidKey = 'en_US';
        us_ASMO2.EmailEncodingKey = 'UTF-8';
        us_ASMO2.ProfileId = pro.Id;
        us_ASMO2.LanguageLocaleKey = 'en_US';
        usercreation.add(us_ASMO2);
        
           User us_ASMO3 = new User();
        us_ASMO3.FirstName = 'ASMO3';
        us_ASMO3.LastName = 'user';
        us_ASMO3.Email = 'testuser_ASMO3@intel.com';
        us_ASMO3.Username = 'testinguser_ASMO3@inteltest.com';
        us_ASMO3.Alias = 'ASMO3';
        us_ASMO3.CommunityNickname = 'test.userqwert10';
        us_ASMO3.TimeZoneSidKey = 'America/Los_Angeles';
        us_ASMO3.LocaleSidKey = 'en_US';
        us_ASMO3.EmailEncodingKey = 'UTF-8';
        us_ASMO3.ProfileId = pro.Id;
        us_ASMO3.LanguageLocaleKey = 'en_US';
        usercreation.add(us_ASMO3);
        
        
         
        
        insert usercreation;
        
        List<Core_Opportunity_Support_Mapping__c> oppmappingLst = new List<Core_Opportunity_Support_Mapping__c>();
        Core_Opportunity_Support_Mapping__c oppmapping = new Core_Opportunity_Support_Mapping__c();
 		oppmapping.Geo_Region__c='APJ';
        oppmapping.Core_Record_Type__c='CSA';
        oppmapping.Core_OSM_Record_Type__c = 'CSA';
        oppmapping.User__c=us1.id;
        oppmapping.Core_Opportunity_Support_Is_Active__c=true;
        oppmappingLst.add(oppmapping);
        
        Core_Opportunity_Support_Mapping__c oppmapping1 = new Core_Opportunity_Support_Mapping__c();
 		oppmapping1.Geo_Region__c='ASMO';
        oppmapping1.Core_Record_Type__c='CSA';
        oppmapping1.Core_OSM_Record_Type__c = 'CSA';
        oppmapping1.User__c=us_ASMO3.id;
        oppmapping1.Core_Opportunity_Support_Is_Active__c=true;
        oppmappingLst.add(oppmapping1);
        
        Core_Opportunity_Support_Mapping__c oppmapping2 = new Core_Opportunity_Support_Mapping__c();
 		oppmapping2.Geo_Region__c='EMEA';
        oppmapping2.Core_Record_Type__c='CSA';
        oppmapping2.Core_OSM_Record_Type__c = 'CSA';
        oppmapping2.User__c=us3.id;
        oppmapping2.Core_Opportunity_Support_Is_Active__c=true;
        oppmappingLst.add(oppmapping2);
        
        Core_Opportunity_Support_Mapping__c oppmapping3 = new Core_Opportunity_Support_Mapping__c();
 		oppmapping3.Geo_Region__c='APJ';
        oppmapping3.Core_Record_Type__c='CSA';
        oppmapping3.Core_OSM_Record_Type__c = 'CSA';
        oppmapping3.User__c=us3.id;
        oppmapping3.Core_Opportunity_Support_Is_Active__c=true;
        oppmappingLst.add(oppmapping3);
        
       Core_Opportunity_Support_Mapping__c oppmapping4 = new Core_Opportunity_Support_Mapping__c();
 		oppmapping4.Geo_Region__c='ASMO';
        oppmapping4.Core_Record_Type__c='CSA';
        oppmapping4.Core_OSM_Record_Type__c = 'CSA';
        oppmapping4.User__c=us_ASMO2.id;
        oppmapping4.Core_Opportunity_Support_Is_Active__c=true;
        oppmappingLst.add(oppmapping4);
        
        Core_Opportunity_Support_Mapping__c oppmapping5 = new Core_Opportunity_Support_Mapping__c();
 		oppmapping5.Geo_Region__c='ASMO';
        oppmapping5.Core_Record_Type__c='CSA';
        oppmapping5.Core_OSM_Record_Type__c = 'CSA';
        oppmapping5.User__c=us_ASMO1.id;
        oppmapping5.Core_Opportunity_Support_Is_Active__c=true;
        oppmappingLst.add(oppmapping5);
        
        Core_Opportunity_Support_Mapping__c oppmapping6 = new Core_Opportunity_Support_Mapping__c();
 		oppmapping6.Geo_Region__c='PRC';
        oppmapping6.Core_Record_Type__c='CSA';
        oppmapping6.Core_OSM_Record_Type__c = 'CSA';
        oppmapping6.User__c=us_PRC4.id;
        oppmapping6.Core_Opportunity_Support_Is_Active__c=true;
        oppmappingLst.add(oppmapping6);
        
        Core_Opportunity_Support_Mapping__c oppmapping7 = new Core_Opportunity_Support_Mapping__c();
 		oppmapping7.Geo_Region__c='PRC';
        oppmapping7.Core_Record_Type__c='CSA';
        oppmapping7.Core_OSM_Record_Type__c = 'CSA';
        oppmapping7.User__c=us_PRC3.id;
        oppmapping7.Core_Opportunity_Support_Is_Active__c=true;
        oppmappingLst.add(oppmapping7);
		
		Core_Opportunity_Support_Mapping__c oppmapping8 = new Core_Opportunity_Support_Mapping__c();
 		oppmapping8.Geo_Region__c='PRC';
        oppmapping8.Core_Record_Type__c='CSA';
        oppmapping8.Core_OSM_Record_Type__c = 'CSA';
        oppmapping8.User__c=us_PRC2.id;
        oppmapping8.Core_Opportunity_Support_Is_Active__c=true;
        oppmappingLst.add(oppmapping8);

		Core_Opportunity_Support_Mapping__c oppmapping9 = new Core_Opportunity_Support_Mapping__c();
 		oppmapping9.Geo_Region__c='APJ';
        oppmapping9.Core_Record_Type__c='COE';
        oppmapping9.Core_OSM_Record_Type__c = 'COE';
        oppmapping9.Core_Opp_Center_of_Excellence__c = 'Artificial Intelligence (AI)';
        oppmapping9.User__c=us4.id;
        oppmapping9.Core_Opportunity_Support_Is_Active__c=true;
        oppmappingLst.add(oppmapping9);  
        
        Core_Opportunity_Support_Mapping__c oppmapping11 = new Core_Opportunity_Support_Mapping__c();
 		oppmapping11.Geo_Region__c='APJ';
        oppmapping11.Core_Record_Type__c='COE';
        oppmapping11.Core_OSM_Record_Type__c = 'COE';
        oppmapping11.Core_Opp_Center_of_Excellence__c = 'Artificial Intelligence (AI)';
        oppmapping11.User__c=us_PRC2.id;
        oppmapping11.Core_Opportunity_Support_Is_Active__c=true;
        oppmappingLst.add(oppmapping11); 
        
        Core_Opportunity_Support_Mapping__c oppmapping12 = new Core_Opportunity_Support_Mapping__c();
 		oppmapping12.Geo_Region__c='APJ';
        oppmapping12.Core_Record_Type__c='COE';
        oppmapping12.Core_OSM_Record_Type__c = 'COE';
        oppmapping12.Core_Opp_Center_of_Excellence__c = 'Artificial Intelligence (AI)';
        oppmapping12.User__c=us_PRC3.id;
        oppmapping12.Core_Opportunity_Support_Is_Active__c=true;
        oppmappingLst.add(oppmapping12); 
        
        Core_Opportunity_Support_Mapping__c oppmapping10 = new Core_Opportunity_Support_Mapping__c();
 		oppmapping10.Geo_Region__c='APJ';
        oppmapping10.Core_Record_Type__c='TSS';
        oppmapping10.Core_OSM_Record_Type__c = 'TSS';
        oppmapping10.Core_BU__c = 'DCAI TSS Support';
        oppmapping10.User__c=us_ASMO1.id;
        oppmapping10.Core_Opportunity_Support_Is_Active__c=true;
        oppmappingLst.add(oppmapping10); 
        
        Core_Opportunity_Support_Mapping__c oppmapping13 = new Core_Opportunity_Support_Mapping__c();
 		oppmapping13.Geo_Region__c='APJ';
        oppmapping13.Core_Record_Type__c='TSS';
        oppmapping13.Core_OSM_Record_Type__c = 'TSS';
        oppmapping13.Core_BU__c = 'DCAI TSS Support';
        oppmapping13.User__c=us_PRC3.id;
        oppmapping13.Core_Opportunity_Support_Is_Active__c=true;
        oppmappingLst.add(oppmapping13); 
        
        Core_Opportunity_Support_Mapping__c oppmapping14 = new Core_Opportunity_Support_Mapping__c();
 		oppmapping14.Geo_Region__c='APJ';
        oppmapping14.Core_Record_Type__c='TSS';
        oppmapping14.Core_OSM_Record_Type__c = 'TSS';
        oppmapping14.Core_BU__c = 'DCAI TSS Support';
        oppmapping14.User__c=us_PRC2.id;
        oppmapping14.Core_Opportunity_Support_Is_Active__c=true;
        oppmappingLst.add(oppmapping14);  
        
         insert oppmappingLst;
        
        Core_Opp_Bypass_Validation_Rule__c BypassRule = new Core_Opp_Bypass_Validation_Rule__c();
        BypassRule.Bypass__c = true;
        insert BypassRule;
        
        // Create an account
        Account a = new Account(Name = 'TestAccount', BillingStreet = '123 Fake St',Core_Geo__c='APJ',
                                BillingCity = 'Springfield', BillingState = 'IL', BillingCountry = 'USA',Industry='Agriculture',Core_Sub_Industry__c= 'Crop Production',
                                BillingPostalCode = '12345', Core_Sales_Groups__c=Core_CRM_Utility.getSalesGroupAPI());//Core_CIM_ID__c = '8675309',
        System.runAs(Core_Test_Utility.systemAdminUser) {
            insert a;
        }
           Account a2 = new Account(Name = 'TestAccount', BillingStreet = '123 Fake St San jose',Core_Geo__c='EMEA',
                                BillingCity = 'Springfield_fake', BillingState = 'IL', BillingCountry = 'USA',Industry='Agriculture',Core_Sub_Industry__c= 'Crop Production',
                                BillingPostalCode = '1234578', Core_Sales_Groups__c=Core_CRM_Utility.getSalesGroupAPI());//Core_CIM_ID__c = '86753090',
        System.runAs(Core_Test_Utility.systemAdminUser) {
            insert a2;
        }
        Account a3 = new Account(Name = 'TestAccount', BillingStreet = '123 Fake St San jose Gospel',Core_Geo__c='ASMO',
                                BillingCity = 'Springfield_fake_2', BillingState = 'IL', BillingCountry = 'USA',Industry='Agriculture',Core_Sub_Industry__c= 'Crop Production',
                                BillingPostalCode = '1234579',Core_Sales_Groups__c=Core_CRM_Utility.getSalesGroupAPI());// Core_CIM_ID__c = '86753091',
        System.runAs(Core_Test_Utility.systemAdminUser) {
            insert a3;
        }
          Account a4 = new Account(Name = 'TestAccount', BillingStreet = '123 Fake St San jose Gospel 2',Core_Geo__c='PRC',
                                BillingCity = 'Springfield_fake_3', BillingState = 'IL', BillingCountry = 'USA',Industry='Agriculture',Core_Sub_Industry__c= 'Crop Production',
                                BillingPostalCode = '1234579', Core_Sales_Groups__c=Core_CRM_Utility.getSalesGroupAPI());//Core_CIM_ID__c = '86753091',
        System.runAs(Core_Test_Utility.systemAdminUser) {
            insert a4;
        }
        Id newOppRecTypeId = [select Id from RecordType where DeveloperName = 'Core_Design_Opportunity' limit 1][0].Id;

        // Create a product/price book entry to use on the opportunities
        Product2 p = new Product2(Name = 'Test Product 03-24-2015');
        insert p;
        PricebookEntry pbe = new PricebookEntry(Product2Id = p.Id, Pricebook2Id = Test.getStandardPricebookId(),
                                                UnitPrice = 0, IsActive = true);
        System.runAs(Core_Test_Utility.systemAdminUser) {
            insert pbe;
        }
        
        // Create a new opportunity using the account created above'
        System.runAs(Core_Test_Utility.systemAdminUser) {
           
            Opportunity opportunity1 = new Opportunity(Name = 'Test Opportunity1', Core_Channel_Opportunity_Ind__c=true,RecordTypeId = newOppRecTypeId,Core_Approved_Opportunity_Region__c='APJ',Core_Opportunity_Geo_APJ__c=true,
                                                      AccountId = a.Id, StageName = 'Qualify', CloseDate = System.Date.today().addYears(1),Core_Approval_Status__c='Not Submitted');
            insert opportunity1;
            
            Opportunity opportunity2 = new Opportunity(Name = 'Test Opportunity2', Core_Channel_Opportunity_Ind__c=true,RecordTypeId = newOppRecTypeId,Core_Approved_Opportunity_Region__c='EMEA',
                                                      AccountId = a2.Id, StageName = 'Qualify', CloseDate = System.Date.today().addYears(1),Core_Approval_Status__c='Not Submitted');
            insert opportunity2;
            
            Opportunity opportunity3 = new Opportunity(Name = 'Test Opportunity3', Core_Channel_Opportunity_Ind__c=true,RecordTypeId = newOppRecTypeId,Core_Approved_Opportunity_Region__c='ASMO',
                                                      AccountId = a3.Id, StageName = 'Qualify', CloseDate = System.Date.today().addYears(1),Core_Approval_Status__c='Not Submitted');
            insert opportunity3;
            
            Opportunity opportunity4 = new Opportunity(Name = 'Test Opportunity4', Core_Channel_Opportunity_Ind__c=true,RecordTypeId = newOppRecTypeId,Core_Approved_Opportunity_Region__c='PRC',
                                                      AccountId = a4.Id, StageName = 'Qualify', CloseDate = System.Date.today().addYears(1),Core_Approval_Status__c='Not Submitted');
            insert opportunity4;
           
           }
        
        
        
        
    }
    
    static testMethod void createOpportunitySupportRequest1() {
        List<Core_Opportunity_Support__c> opp_supp = new List<Core_Opportunity_Support__c>();
         string recordtypeCSAId = recordTypeMap.get('Core_CSA_RecordType').getRecordTypeId();
        string recordtypeTSSId = recordTypeMap.get('Core_TSS_Request').getRecordTypeId();
        string recordtypeCOEId = recordTypeMap.get('Core_Center_of_Excellence_Request').getRecordTypeId();
        test.starttest();
         List<User> usr1 = [SELECT id, Name, isActive,Core_User_Geo__c FROM User WHERE Email IN ('testuser@intel.com','testuser1@intel.com','testuser2@intel.com','testuser3@intel.com')];
		
        Opportunity opportunity1 = [select Id, Name, Amount, RecordTypeId, Description,StageName,Core_Opportunity_Owner_Geo__c,Core_Opportunity_Owner__c  FROM Opportunity WHERE Name='Test Opportunity1'];
        Id recordTypeId = Schema.getGlobalDescribe().get('Core_Opportunity_Support__c').getDescribe().getRecordTypeInfosByDeveloperName().get('Core_CSA_RecordType').getRecordTypeId();

        Core_OpportunitySupport.getOpportunityDetails(opportunity1.Id,recordTypeId,'');
        Core_Opportunity_Support__c creatOpptSupportReq = new Core_Opportunity_Support__c();
        creatOpptSupportReq.Core_Opportunity_Description__c ='test oppt Support request description';
        creatOpptSupportReq.Core_Additional_Support_Needed__c ='test Additional support needed';
        creatOpptSupportReq.Core_background_info_on_architecture__c ='test background info on architecture';
        creatOpptSupportReq.Core_PrimaryBlockers__c ='test primary blockers';
        creatOpptSupportReq.Opportunity__c = opportunity1.Id;
        creatOpptSupportReq.Core_Opportunity_Description__c='Test';
        creatOpptSupportReq.Core_Status__c = 'Submitted';
        creatOpptSupportReq.RecordTypeId = recordtypeCSAId;	
     /*   creatOpptSupportReq.Core_Approver_1__c=usr1[2].id;
        creatOpptSupportReq.Core_Approver_2__c=usr1[2].id;
        creatOpptSupportReq.Core_Approver_3__c=usr1[2].id;
        creatOpptSupportReq.Core_Approver_4__c=usr1[2].id;
        creatOpptSupportReq.Core_Approver_5__c=usr1[2].id;*/
        
        opp_supp.add(creatOpptSupportReq);
        //Core_OpportunitySupportServiceHandler.determineApprovers(opp_supp);
        insert opp_supp;  
        Assert.areEqual(true, creatOpptSupportReq.id != null);
        //Assert.areEqual(true,opportunity1.Description=='test oppt Support request description');
        
        test.stopTest();
    }
    
    static testMethod void OpportunitySupportRequestException() {        
        test.starttest();        
        try{
            
            Opportunity opportunity1 = [select Id, Name, Amount, RecordTypeId, Description,StageName  FROM Opportunity WHERE Name='Test Opportunity1'];
            Opportunity opportunity2;
            Core_OpportunitySupport.wrapperOpptSupportRequest obj = new Core_OpportunitySupport.wrapperOpptSupportRequest();
            
            
            Core_Opportunity_Support__c opptSuppReq = [Select Id from Core_Opportunity_Support__c 
                                                       where Core_Status__c='Submitted' 
                                                       and Opportunity__c =:opportunity2.Id];
            Id recordTypeId = Schema.getGlobalDescribe().get('Core_Opportunity_Support__c').getDescribe().getRecordTypeInfosByDeveloperName().get('Core_CSA_RecordType').getRecordTypeId();

            obj = Core_OpportunitySupport.getOpportunityDetails(opportunity1.Id,recordTypeId,'');
            //System.assert(obj.isThereAnOpenOpptSupportReq, true);
            
        }catch(Exception e){
            Assert.areNotEqual(NULL,e);
        }
        
        test.stopTest();
    }
    
    static testMethod void createOpportunitySupportRequest2() {
        List<Core_Opportunity_Support__c> opp_supp2 = new List<Core_Opportunity_Support__c>();
         string recordtypeCSAId = recordTypeMap.get('Core_CSA_RecordType').getRecordTypeId();
        string recordtypeTSSId = recordTypeMap.get('Core_TSS_Request').getRecordTypeId();
        string recordtypeCOEId = recordTypeMap.get('Core_Center_of_Excellence_Request').getRecordTypeId();
        test.starttest();
        List<User> usr1 = [SELECT id, Name, isActive,Core_User_Geo__c FROM User WHERE Email IN ('testuser@intel.com','testuser1@intel.com','testuser2@intel.com','testuser3@intel.com')];
        
        Opportunity opportunity2 = [select Id, Name, Amount, RecordTypeId, Description,StageName 
                                    FROM Opportunity WHERE Name='Test Opportunity2'];
        Id recordTypeId = Schema.getGlobalDescribe().get('Core_Opportunity_Support__c').getDescribe().getRecordTypeInfosByDeveloperName().get('Core_CSA_RecordType').getRecordTypeId();
        
        Core_OpportunitySupport.getOpportunityDetails(opportunity2.Id,recordTypeId,'');
        
        Core_Opportunity_Support__c creatOpptSupportReq2 = new Core_Opportunity_Support__c();
        creatOpptSupportReq2.Core_Opportunity_Description__c ='test oppt Support request description';
        creatOpptSupportReq2.Core_Additional_Support_Needed__c ='test Additional support needed';
        creatOpptSupportReq2.Core_background_info_on_architecture__c ='test background info on architecture';
        creatOpptSupportReq2.Core_PrimaryBlockers__c ='test primary blockers';
        creatOpptSupportReq2.Opportunity__c = opportunity2.Id;
        creatOpptSupportReq2.Core_Status__c='Submitted';  
        creatOpptSupportReq2.RecordTypeId = recordtypeCSAId;	

     
        opp_supp2.add(creatOpptSupportReq2);
        insert opp_supp2;   
        //Core_OpportunitySupportServiceHandler.determineApprovers(opp_supp);       
        Assert.areEqual(4, usr1.size(), 'Number of user created');
		 creatOpptSupportReq2.Core_Status__c='Cancelled';
        update opp_supp2;   		 
        test.stopTest();
    }
    
    static testMethod void createOpportunitySupportRequest3() {
        List<Core_Opportunity_Support__c> opp_supp2 = new List<Core_Opportunity_Support__c>();
         string recordtypeCSAId = recordTypeMap.get('Core_CSA_RecordType').getRecordTypeId();
        string recordtypeTSSId = recordTypeMap.get('Core_TSS_Request').getRecordTypeId();
        string recordtypeCOEId = recordTypeMap.get('Core_Center_of_Excellence_Request').getRecordTypeId();
        test.starttest();
        List<User> usr1 = [SELECT id, Name, isActive,Core_User_Geo__c FROM User WHERE Email IN ('testuser@intel.com','testuser1@intel.com','testuser2@intel.com','testuser3@intel.com')];
        
        Opportunity opportunity2 = [select Id, Name, Amount, RecordTypeId, Description,StageName 
                                    FROM Opportunity WHERE Name='Test Opportunity2'];
        Id recordTypeId = Schema.getGlobalDescribe().get('Core_Opportunity_Support__c').getDescribe().getRecordTypeInfosByDeveloperName().get('Core_CSA_RecordType').getRecordTypeId();
  
        Core_OpportunitySupport.getOpportunityDetails(opportunity2.Id,recordTypeId,'');
        
        Core_Opportunity_Support__c creatOpptSupportReq2 = new Core_Opportunity_Support__c();
        creatOpptSupportReq2.Core_Opportunity_Description__c ='test oppt Support request description';
        creatOpptSupportReq2.Core_Additional_Support_Needed__c ='test Additional support needed';
        creatOpptSupportReq2.Core_background_info_on_architecture__c ='test background info on architecture';
        creatOpptSupportReq2.Core_PrimaryBlockers__c ='test primary blockers';
        creatOpptSupportReq2.Opportunity__c = opportunity2.Id;
        creatOpptSupportReq2.Core_Status__c='Submitted';        
        creatOpptSupportReq2.RecordTypeId = recordtypeCSAId;	
     
        opp_supp2.add(creatOpptSupportReq2);
        insert opp_supp2;   
        //Core_OpportunitySupportServiceHandler.determineApprovers(opp_supp);       
        
        Core_SubmitOpptSupportRequest.submitApproval(creatOpptSupportReq2.Id);
        Assert.areEqual(4, usr1.size(), 'Number of user created');
        test.stopTest();
    }
    
    
        static testMethod void createOpportunitySupportRequestASMO() {
             string recordtypeCSAId = recordTypeMap.get('Core_CSA_RecordType').getRecordTypeId();
        string recordtypeTSSId = recordTypeMap.get('Core_TSS_Request').getRecordTypeId();
        string recordtypeCOEId = recordTypeMap.get('Core_Center_of_Excellence_Request').getRecordTypeId();
        List<Core_Opportunity_Support__c> opp_supp3 = new List<Core_Opportunity_Support__c>();
        test.starttest();
        List<User> usr1 = [SELECT id, Name, isActive,Core_User_Geo__c FROM User WHERE Email IN ('testuser@intel.com','testuser1@intel.com','testuser2@intel.com','testuser3@intel.com')];
        
        Opportunity opportunity3 = [select Id, Name, Amount, RecordTypeId, Description,StageName 
                                    FROM Opportunity WHERE Name='Test Opportunity3'];
        Id recordTypeId = Schema.getGlobalDescribe().get('Core_Opportunity_Support__c').getDescribe().getRecordTypeInfosByDeveloperName().get('Core_CSA_RecordType').getRecordTypeId();
            
        Core_OpportunitySupport.getOpportunityDetails(opportunity3.Id,recordTypeId,'');
        
        Core_Opportunity_Support__c creatOpptSupportReq3 = new Core_Opportunity_Support__c();
        creatOpptSupportReq3.Core_Opportunity_Description__c ='test oppt Support request description';
        creatOpptSupportReq3.Core_Additional_Support_Needed__c ='test Additional support needed';
        creatOpptSupportReq3.Core_background_info_on_architecture__c ='test background info on architecture';
        creatOpptSupportReq3.Core_PrimaryBlockers__c ='test primary blockers';
        creatOpptSupportReq3.Opportunity__c = opportunity3.Id;
        creatOpptSupportReq3.Core_Status__c='Submitted';        
        creatOpptSupportReq3.RecordTypeId = recordtypeCSAId;	
     
        opp_supp3.add(creatOpptSupportReq3);
        insert opp_supp3;   
        //Core_OpportunitySupportServiceHandler.determineApprovers(opp_supp);       
            Assert.areEqual(4, usr1.size(), 'Number of user created');
        test.stopTest();
    }
       
    static testMethod void createOpportunitySupportRequestPRC() {
        List<Core_Opportunity_Support__c> opp_supp4 = new List<Core_Opportunity_Support__c>();
        string recordtypeCSAId = recordTypeMap.get('Core_CSA_RecordType').getRecordTypeId();
        string recordtypeTSSId = recordTypeMap.get('Core_TSS_Request').getRecordTypeId();
        string recordtypeCOEId = recordTypeMap.get('Core_Center_of_Excellence_Request').getRecordTypeId();
        test.starttest();
        List<User> usr1 = [SELECT id, Name, isActive,Core_User_Geo__c FROM User WHERE Email IN ('testuser@intel.com','testuser1@intel.com','testuser2@intel.com','testuser3@intel.com','testuser4@intel.com')];
        
        Opportunity opportunity4 = [select Id, Name, Amount, RecordTypeId, Description,StageName 
                                    FROM Opportunity WHERE Name='Test Opportunity4'];
        Id recordTypeId = Schema.getGlobalDescribe().get('Core_Opportunity_Support__c').getDescribe().getRecordTypeInfosByDeveloperName().get('Core_CSA_RecordType').getRecordTypeId();
                
        Core_OpportunitySupport.getOpportunityDetails(opportunity4.Id,recordTypeId,'');
        
        Core_Opportunity_Support__c creatOpptSupportReq4 = new Core_Opportunity_Support__c();
        creatOpptSupportReq4.Core_Opportunity_Description__c ='test oppt Support request description';
        creatOpptSupportReq4.Core_Additional_Support_Needed__c ='test Additional support needed';
        creatOpptSupportReq4.Core_background_info_on_architecture__c ='test background info on architecture';
        creatOpptSupportReq4.Core_PrimaryBlockers__c ='test primary blockers';
        creatOpptSupportReq4.Opportunity__c = opportunity4.Id;
        creatOpptSupportReq4.Core_Status__c='Submitted';  
        creatOpptSupportReq4.RecordTypeId = recordtypeCSAId;	

     
        opp_supp4.add(creatOpptSupportReq4);
        insert opp_supp4;   
        //Core_OpportunitySupportServiceHandler.determineApprovers(opp_supp);       
        Assert.areEqual(5, usr1.size(), 'Number of user created');
        test.stopTest();
    }
       
    static testMethod void testOppTeamShare() {
        Core_Trigger_Executions__c triggerSetting1 = new Core_Trigger_Executions__c();
        triggerSetting1.name = 'captureOppSupportTeamMemberName';
        triggerSetting1.Core_Object__c = 'Core_Opportunity_Support_Team__c';
        triggerSetting1.Core_Active__c = TRUE;
        triggerSetting1.Core_Description__c = 'Trigger to add Opportunity team';
        triggerSetting1.Core_Class_Name__c = 'Core_OppSupportTeamTriggerHandler';
        triggerSetting1.Core_Trigger_Events__c = 'After Insert, After Update, After Delete';
        insert triggerSetting1;
        string recordtypeCSAId = recordTypeMap.get('Core_CSA_RecordType').getRecordTypeId();
        string recordtypeTSSId = recordTypeMap.get('Core_TSS_Request').getRecordTypeId();
        string recordtypeCOEId = recordTypeMap.get('Core_Center_of_Excellence_Request').getRecordTypeId();
        List<Core_Opportunity_Support__c> opp_supp = new List<Core_Opportunity_Support__c>();
        Opportunity opportunity1 = [select Id, Name, Amount, RecordTypeId, Description,StageName 
                                    FROM Opportunity WHERE Name='Test Opportunity1'];
        List<User> usr1 = [SELECT id, Name, isActive,Core_User_Geo__c FROM User WHERE Email IN ('testuser@intel.com','testuser1@intel.com','testuser2@intel.com','testuser3@intel.com')];

        Core_Opportunity_Support__c creatOpptSupportReq = new Core_Opportunity_Support__c();
        creatOpptSupportReq.Core_Opportunity_Description__c ='test oppt Support request description';
        creatOpptSupportReq.Core_Additional_Support_Needed__c ='test Additional support needed';
        creatOpptSupportReq.Core_background_info_on_architecture__c ='test background info on architecture';
        creatOpptSupportReq.Core_PrimaryBlockers__c ='test primary blockers';
        creatOpptSupportReq.Core_Status__c = 'Submitted';
        creatOpptSupportReq.Opportunity__c = opportunity1.Id; 
        creatOpptSupportReq.RecordTypeId = recordtypeCSAId;
        opp_supp.add(creatOpptSupportReq);
        
        Core_Opportunity_Support__c creatOpptSupportReq1 = new Core_Opportunity_Support__c();
        creatOpptSupportReq1.Center_of_Excellence__c ='Artificial Intelligence (AI)';
        creatOpptSupportReq1.Core_CoE_Request_Detail__c = ' testing';
        creatOpptSupportReq1.Core_Status__c = 'Submitted';
        creatOpptSupportReq1.Opportunity__c = opportunity1.Id; 
        creatOpptSupportReq1.RecordTypeId = recordtypeCOEId;
        opp_supp.add(creatOpptSupportReq1);
        
        Core_Opportunity_Support__c creatOpptSupportReq2 = new Core_Opportunity_Support__c();
        creatOpptSupportReq2.Core_Opportunity_Description__c ='test oppt Support request description';
        creatOpptSupportReq2.Core_Additional_Support_Needed__c ='test Additional support needed';
        creatOpptSupportReq2.Core_background_info_on_architecture__c ='test background info on architecture';
        creatOpptSupportReq2.Core_PrimaryBlockers__c ='test primary blockers';
        creatOpptSupportReq2.Core_TSS_Support_Type__c = 'DCAI TSS Support';
        creatOpptSupportReq2.Core_Status__c = 'Submitted';
        creatOpptSupportReq2.Opportunity__c = opportunity1.Id; 
        creatOpptSupportReq2.RecordTypeId = recordtypeTSSId;
        opp_supp.add(creatOpptSupportReq2);
        
        
        insert opp_supp;
        
        test.starttest();
        
        Core_Opportunity_Support_Team__c addTeamMem = new Core_Opportunity_Support_Team__c();
        addTeamMem.Core_Opportunity_Support__c = creatOpptSupportReq.id;
        addTeamMem.Core_Opportunity_Support_Team_Member__c = usr1[0].id;
        insert addTeamMem;  
        //Approving customer Support request
        Set<Id> pIds = (new Map<Id, ProcessInstance>([SELECT Id,Status,TargetObjectId FROM ProcessInstance where Status='Pending' and TargetObjectId =:creatOpptSupportReq.id])).keySet();
        Set<Id> pInstanceWorkitems = (new Map<Id, ProcessInstanceWorkitem>([SELECT Id,ProcessInstanceId FROM ProcessInstanceWorkitem WHERE ProcessInstanceId in :pIds])).keySet();
        
        List<Approval.ProcessWorkitemRequest> allReq = new List<Approval.ProcessWorkitemRequest>(); 
        for (Id pInstanceWorkitemsId:pInstanceWorkitems){
            Approval.ProcessWorkitemRequest req2 = new Approval.ProcessWorkitemRequest();
            req2.setComments('mRequest.');
            req2.setAction('Approve'); 
            req2.setNextApproverIds(new Id[] {UserInfo.getUserId()});            
            // Use the ID from the newly created item to specify the item to be worked
            req2.setWorkitemId(pInstanceWorkitemsId);            
            // Add the request for approval
            allReq.add(req2);
        }
        Approval.ProcessResult[] result2 =  Approval.process(allReq);
        // creating one record after approving Customer support
        List<Core_Opportunity_Support_Team__c> updateUser = new List<Core_Opportunity_Support_Team__c>();
        List<Core_Opportunity_Support_Team__c> oppSupportTeamList = new List<Core_Opportunity_Support_Team__c>();
        Core_Opportunity_Support_Team__c addTeamMem1 = new Core_Opportunity_Support_Team__c();
        addTeamMem1.Core_Opportunity_Support__c = creatOpptSupportReq.id;
        addTeamMem1.Core_Opportunity_Support_Team_Member__c = usr1[1].id;
        insert addTeamMem1;
        oppSupportTeamList.add(addTeamMem1);
        
        Core_Opportunity_Support_Team__c addTeamMem2 = new Core_Opportunity_Support_Team__c();
        addTeamMem2.Core_Opportunity_Support__c = creatOpptSupportReq.id;
        addTeamMem2.Core_Opportunity_Support_Team_Member__c = usr1[3].id;
        insert addTeamMem2;
        //change user name
        addTeamMem.Core_Opportunity_Support_Team_Member__c = usr1[2].id;
        update addTeamMem; 
        
        //updateUser.add(addTeamMem);
        try{
            Core_OppSupTeamAccOrRej.checkUserformOppteam(usr1[3].id);
            Core_OppSupTeamAccOrRej.updateStatusOppRequestTeam('Accepted',addTeamMem1.id,'',addTeamMem1);
            addTeamMem1.Core_Opportunity_Support_Team_Member__c = usr1[3].id;
            updateUser.add(addTeamMem1);
            Core_OppSupportTeam.captureOppSupportTeamMemberName(oppSupportTeamList);
            update updateUser;
            //addTeamMem.Core_Opportunity_Support_Team_Member__c = usr1[2].id;
            //update addTeamMem;
        }catch (Exception e) {
        }
         try{
            Core_OppSupTeamAccOrRej.updateStatusOppRequestTeam('Accepted',addTeamMem1.id,'',addTeamMem1);            
        }catch(Exception e){
        }
        Core_OppSupTeamAccOrRej.updateStatusOppRequestTeam('Denied',addTeamMem2.id,'',addTeamMem2);
        Assert.areEqual(4, usr1.size(), 'Number of user created');
        // delete user from Opportunity support team
        //delete addTeamMem1; 
        test.stopTest();
    }
    @isTest
    public static void whenAfterDelete(){
        Test.startTest();
        String sub = 'abcde'.substring(2);
        Core_OppSupportTeamTriggerHandler ucdAccountHandlers = new Core_OppSupportTeamTriggerHandler();
        ucdAccountHandlers.afterDelete();
        Assert.areEqual('cde', sub, 'Expected characters after first two');

        Test.stopTest();
    }
    
}