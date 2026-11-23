/**************************************************************************************
Apex Class Name:  Core_OpptySupportServiceHandlerTest : cloned version only for devsls testing . plz dont migrate. original test class to migrate is Core_OpptySupportServiceHandlerTest
Version     : 1.0 
Created Date: 09 MAR 2023
Function    : Test Class for the Core_OpptySupportServiceHandlerTest
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Areefa Banu             09/03/2023              Original Version
*************************************************************************************/

@isTest 
public class Core_OpportunitySupport_Test {
    @testSetup
    static void setupTestData() { 
        Profile pro = [SELECT id, Name FROM Profile WHERE Name='CCP - Core Access'];
        //User usr1 = [SELECT id, Name, isActive,Core_User_Geo__c FROM User WHERE ProfileId = :pro.Id AND isActive = true LIMIT 1];
        PermissionSetAssignment psa = [SELECT Id, PermissionSet.Name,PermissionSetId, AssigneeId from PermissionSetAssignment  where PermissionSet.Name='Core_CRM_Special_Access' and Assignee.IsActive = true LIMIT 1];
		User usr = [SELECT id, Name, isActive FROM User WHERE Id = :psa.AssigneeId AND isActive = true LIMIT 1];
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
        
        insert usercreation;
        
        List<Core_Opportunity_Support_Mapping__c> oppmappingLst = new List<Core_Opportunity_Support_Mapping__c>();
        Core_Opportunity_Support_Mapping__c oppmapping = new Core_Opportunity_Support_Mapping__c();
 		oppmapping.Geo_Region__c='APJ';
        oppmapping.Core_Record_Type__c='CSA';
        oppmapping.User__c=us1.id;
        oppmapping.Core_Opportunity_Support_Is_Active__c=true;
        oppmappingLst.add(oppmapping);
        
        Core_Opportunity_Support_Mapping__c oppmapping1 = new Core_Opportunity_Support_Mapping__c();
 		oppmapping1.Geo_Region__c='ASMO';
        oppmapping1.Core_Record_Type__c='CSA';
        oppmapping1.User__c=us2.id;
        oppmapping1.Core_Opportunity_Support_Is_Active__c=true;
        oppmappingLst.add(oppmapping1);
        
        Core_Opportunity_Support_Mapping__c oppmapping2 = new Core_Opportunity_Support_Mapping__c();
 		oppmapping2.Geo_Region__c='EMEA';
        oppmapping2.Core_Record_Type__c='CSA';
        oppmapping2.User__c=us3.id;
        oppmapping2.Core_Opportunity_Support_Is_Active__c=true;
        oppmappingLst.add(oppmapping2);
        
        Core_Opportunity_Support_Mapping__c oppmapping3 = new Core_Opportunity_Support_Mapping__c();
 		oppmapping3.Geo_Region__c='APJ';
        oppmapping3.Core_Record_Type__c='CSA';
        oppmapping3.User__c=us3.id;
        oppmapping3.Core_Opportunity_Support_Is_Active__c=true;
        oppmappingLst.add(oppmapping3);
        Core_Opportunity_Support_Mapping__c oppmapping4 = new Core_Opportunity_Support_Mapping__c();
 		oppmapping4.Core_Record_Type__c='MS';
        oppmapping4.User__c=us3.id;
        oppmapping4.Core_Opportunity_Support_Is_Active__c=true;
        oppmappingLst.add(oppmapping4);
        
        insert oppmappingLst;
        
        Core_Opp_Bypass_Validation_Rule__c BypassRule = new Core_Opp_Bypass_Validation_Rule__c();
        BypassRule.Bypass__c = true;
        insert BypassRule;
        
        // Create an account
        Account a = Core_Test_Utility.createAccount(1)[0];
            //new Account(Name = 'TestAccount', BillingStreet = '123 Fake St',Core_Geo__c='APJ', BillingCity = 'Springfield', BillingState = 'IL', BillingCountry = 'USA',Industry='Agriculture',Core_Sub_Industry__c= 'Crop Production', BillingPostalCode = '12345', Core_CIM_ID__c = '8675309',Core_Sales_Groups__c='Americas Partner Holding');
        a.Core_Geo__c='APJ';
        System.runAs(Core_Test_Utility.systemAdminUser) {
            insert a;
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
            system.debug('a--' +a);
           
            Opportunity opportunity1 = new Opportunity(Name = 'Test Opportunity1', Core_Channel_Opportunity_Ind__c=true,RecordTypeId = newOppRecTypeId,Core_Approved_Opportunity_Region__c='APJ',Core_Opportunity_Geo_APJ__c=true,
                                                      AccountId = a.Id, StageName = 'Qualify', CloseDate = System.Date.today().addYears(1),Core_Approval_Status__c='Not Submitted');
            insert opportunity1;
           
           }
        
        
        
        
    }
    
    static testMethod void createOpportunitySupportRequest1() {
        List<Core_Opportunity_Support__c> opp_supp = new List<Core_Opportunity_Support__c>();
        test.starttest();
         List<User> usr1 = [SELECT id, Name, isActive,Core_User_Geo__c FROM User WHERE Email IN ('testuser@intel.com','testuser1@intel.com','testuser2@intel.com','testuser3@intel.com')];
		
        Opportunity opportunity1 = [select Id, Name, Amount, RecordTypeId, Description,StageName,Core_Opportunity_Owner_Geo__c,Core_Opportunity_Owner__c  FROM Opportunity WHERE Name='Test Opportunity1'];
        system.debug('opportunity1:::'+opportunity1);
     Id recordTypeId = Schema.getGlobalDescribe().get('Core_Opportunity_Support__c').getDescribe().getRecordTypeInfosByDeveloperName().get('Core_CSA_RecordType').getRecordTypeId();

              //  Id recordTypeId = Schema.getGlobalDescribe().get('Core_Opportunity_Support__c').getDescribe().getRecordTypeInfosByDeveloperName().get('Marketing_Support').getRecordTypeId();
        Core_OpportunitySupport.getOpportunityDetails(opportunity1.Id,recordTypeId, '');
        Core_Opportunity_Support__c creatOpptSupportReq = new Core_Opportunity_Support__c();
        creatOpptSupportReq.Core_Opportunity_Description__c ='test oppt Support request description';
        creatOpptSupportReq.Core_Additional_Support_Needed__c ='test Additional support needed';
        creatOpptSupportReq.Core_background_info_on_architecture__c ='test background info on architecture';
        creatOpptSupportReq.Core_PrimaryBlockers__c ='test primary blockers';
        creatOpptSupportReq.Opportunity__c = opportunity1.Id;
        creatOpptSupportReq.RecordTypeId = recordTypeId;
        
        system.debug('line 164'+creatOpptSupportReq.Core_Region__c);
         system.debug('line 166'+opportunity1.Core_Opportunity_Owner_Geo__c);
     	/*creatOpptSupportReq.Core_Approver_1__c=usr1[2].id;
        creatOpptSupportReq.Core_Approver_2__c=usr1[2].id;
        creatOpptSupportReq.Core_Approver_3__c=usr1[2].id;
        creatOpptSupportReq.Core_Approver_4__c=usr1[2].id;
        creatOpptSupportReq.Core_Approver_5__c=usr1[2].id;*/
        
        opp_supp.add(creatOpptSupportReq);
        //Core_OpportunitySupportServiceHandler.determineApprovers(opp_supp);
        //
         System.runAs(Core_Test_Utility.systemAdminUser) {
        insert opp_supp;  
         }
        system.debug('Line 71'+creatOpptSupportReq.Core_Region__c);
        System.assert(true, creatOpptSupportReq.id != null);
        System.assert(true,opportunity1.Description=='test oppt Support request description');
        
        test.stopTest();
    }
    
    static testMethod void OpportunitySupportRequestException() {        
        test.starttest();        
        try{
            
            Opportunity opportunity1 = [select Id, Name, Amount, RecordTypeId, Description,StageName  FROM Opportunity WHERE Name='Test Opportunity1'];
            system.debug('opportunity1:::'+opportunity1);
            Opportunity opportunity2;
            Core_OpportunitySupport.wrapperOpptSupportRequest obj = new Core_OpportunitySupport.wrapperOpptSupportRequest();
            
            system.debug('obj.isThereAnOpenOpptSupportReq'+obj.isThereAnOpenOpptSupportReq);
            Id recordTypeId = Schema.getGlobalDescribe().get('Core_Opportunity_Support__c').getDescribe().getRecordTypeInfosByDeveloperName().get('Core_CSA_RecordType').getRecordTypeId();

            Core_Opportunity_Support__c opptSuppReq = [Select Id from Core_Opportunity_Support__c 
                                                       where Core_Status__c='Submitted' 
                                                       and Opportunity__c =:opportunity2.Id];
            system.debug('opptSuppReq123'+opptSuppReq);
            obj = Core_OpportunitySupport.getOpportunityDetails(opportunity1.Id,recordTypeId,'');
            system.debug('obj123'+obj);
            //System.assert(obj.isThereAnOpenOpptSupportReq, true);
            
        }catch(Exception e){
            System.assertNotEquals(NULL,e);
            System.debug('Exception occured' +e.getMessage());
        }
        
        test.stopTest();
    }
    
    static testMethod void createOpportunitySupportRequest2() {
        List<Core_Opportunity_Support__c> opp_supp = new List<Core_Opportunity_Support__c>();
        test.starttest();
        List<User> usr1 = [SELECT id, Name, isActive,Core_User_Geo__c FROM User WHERE Email IN ('testuser@intel.com','testuser1@intel.com','testuser2@intel.com','testuser3@intel.com')];
        
        Opportunity opportunity1 = [select Id, Name, Amount, RecordTypeId, Description,StageName FROM Opportunity WHERE Name='Test Opportunity1'];
        system.debug('opportunity1:::'+opportunity1);
        Id recordTypeId = Schema.getGlobalDescribe().get('Core_Opportunity_Support__c').getDescribe().getRecordTypeInfosByDeveloperName().get('Core_CSA_RecordType').getRecordTypeId();

        Core_OpportunitySupport.getOpportunityDetails(opportunity1.Id,recordTypeId,'');
        
        Core_Opportunity_Support__c creatOpptSupportReq = new Core_Opportunity_Support__c();
        creatOpptSupportReq.Core_Opportunity_Description__c ='test oppt Support request description';
        creatOpptSupportReq.Core_Additional_Support_Needed__c ='test Additional support needed';
        creatOpptSupportReq.Core_background_info_on_architecture__c ='test background info on architecture';
        creatOpptSupportReq.Core_PrimaryBlockers__c ='test primary blockers';
        creatOpptSupportReq.Opportunity__c = opportunity1.Id;
        creatOpptSupportReq.Core_Status__c='Submitted';        
        creatOpptSupportReq.Core_Approver_1__c=usr1[2].id;
        creatOpptSupportReq.Core_Approver_2__c=usr1[2].id;
        creatOpptSupportReq.Core_Approver_3__c=usr1[2].id;
        creatOpptSupportReq.Core_Approver_4__c=usr1[2].id;
        creatOpptSupportReq.Core_Approver_5__c=usr1[2].id;
        creatOpptSupportReq.Core_Approver_6__c=usr1[2].id;
        creatOpptSupportReq.Core_Approver_7__c=usr1[2].id;
        creatOpptSupportReq.Core_Approver_8__c=usr1[2].id;
        creatOpptSupportReq.Core_Approver_9__c=usr1[2].id;
        creatOpptSupportReq.Core_Approver_10__c=usr1[2].id;
        creatOpptSupportReq.RecordTypeId=recordTypeId;
        
        Core_Opportunity_Support__c creatOpptSupportReq1 = new Core_Opportunity_Support__c();
        creatOpptSupportReq1.Core_Opportunity_Description__c ='test oppt Support request description1';
        creatOpptSupportReq1.Core_Additional_Support_Needed__c ='test Additional support needed1';
        creatOpptSupportReq1.Core_background_info_on_architecture__c ='test background info on architecture1';
        creatOpptSupportReq1.Core_PrimaryBlockers__c ='test primary blockers1';
        creatOpptSupportReq1.Opportunity__c = opportunity1.Id;
        creatOpptSupportReq1.Core_Status__c='Submitted';  
        //creatOpptSupportReq1.Core_Status__c='Approved';
        creatOpptSupportReq1.Core_Approver_1__c=usr1[2].id;
        creatOpptSupportReq1.Core_Approver_2__c=usr1[2].id;
        creatOpptSupportReq1.Core_Approver_3__c=usr1[2].id;
        creatOpptSupportReq1.Core_Approver_4__c=usr1[2].id;
        creatOpptSupportReq1.Core_Approver_5__c=usr1[2].id; 
        creatOpptSupportReq1.Core_Approver_6__c=usr1[2].id;
        creatOpptSupportReq1.Core_Approver_7__c=usr1[2].id;
        creatOpptSupportReq1.Core_Approver_8__c=usr1[2].id;
        creatOpptSupportReq1.Core_Approver_9__c=usr1[2].id;
        creatOpptSupportReq1.Core_Approver_10__c=usr1[2].id; 
        creatOpptSupportReq1.RecordTypeId=recordTypeId;
        opp_supp.add(creatOpptSupportReq);
        opp_supp.add(creatOpptSupportReq1);
        system.debug('before insert opp_supp'+opp_supp);
        insert opp_supp;   
        system.debug('After insert opp_supp'+opp_supp);
        //Core_OpportunitySupportServiceHandler.determineApprovers(opp_supp);       
        system.debug('creatOpptSupportReq::-'+creatOpptSupportReq);
        test.stopTest();
    }
    
    static testMethod void testOppTeamShare() {
        List<Core_Opportunity_Support__c> opp_supp = new List<Core_Opportunity_Support__c>();
        Opportunity opportunity1 = [select Id, Name, Amount, Core_Approved_Opportunity_Region__c, RecordTypeId, Description,StageName 
                                    FROM Opportunity WHERE Name='Test Opportunity1'];
        opportunity1.Core_Approved_Opportunity_Region__c = 'APJ';
        update opportunity1;
        List<User> usr1 = [SELECT id, Name, isActive,Core_User_Geo__c FROM User WHERE Email IN ('testuser@intel.com','testuser1@intel.com','testuser2@intel.com','testuser3@intel.com')];
		
        Core_Opportunity_Support__c creatOpptSupportReq = new Core_Opportunity_Support__c();
        creatOpptSupportReq.Core_Opportunity_Description__c ='test oppt Support request description';
        creatOpptSupportReq.Core_Additional_Support_Needed__c ='test Additional support needed';
        creatOpptSupportReq.Core_background_info_on_architecture__c ='test background info on architecture';
        creatOpptSupportReq.Core_PrimaryBlockers__c ='test primary blockers';
        creatOpptSupportReq.Opportunity__c = opportunity1.Id;      
        
        insert creatOpptSupportReq;
        
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
            system.debug(pInstanceWorkitemsId);
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
        Core_Opportunity_Support_Team__c addTeamMem1 = new Core_Opportunity_Support_Team__c();
        addTeamMem1.Core_Opportunity_Support__c = creatOpptSupportReq.id;
        addTeamMem1.Core_Opportunity_Support_Team_Member__c = usr1[1].id;
        insert addTeamMem1;
        //change user name
        addTeamMem.Core_Opportunity_Support_Team_Member__c = usr1[2].id;
        //update addTeamMem; 
        updateUser.add(addTeamMem);
        addTeamMem1.Core_Opportunity_Support_Team_Member__c = usr1[3].id;
        updateUser.add(addTeamMem1);
        update updateUser;
        //Core_OppSupTeamAccOrRej.checkUserformOppteam(usr1[3].id);
        //Core_OppSupTeamAccOrRej.updateStatusOppRequestTeam('Accepted',addTeamMem1.id,'',updateUser[0]);
        try{
            addTeamMem.Core_Opportunity_Support_Team_Member__c = usr1[2].id;
            update addTeamMem;
        }catch (Exception e) {
            system.debug('creating exception adding same user'+e);
        }
        try{
            //Core_OppSupTeamAccOrRej.updateStatusOppRequestTeam('Accepte',addTeamMem1.id,'comments',updateUser[0]);
        }catch(Exception e){
            system.debug('creating exception while Accepted or Deined request'+e);
        }
        // delete user from Opportunity support team
        delete addTeamMem1;
        test.stopTest();
    }
    
}