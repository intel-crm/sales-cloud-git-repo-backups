@isTest
public class Core_OpportunityReminderSchdl_Test {
    
    static List<Account> accountList;
    static Opportunity opp;
    static Opportunity opp1;
    
    @testSetup
    static void setupTest() {
        
        Core_Opp_Bypass_Validation_Rule__c rec = new Core_Opp_Bypass_Validation_Rule__c();
        rec.Bypass__c = true;
        insert rec;
        
        List<User> users = new List<User>();
        
        users.add(new User(UserName='test.user1.testOppApproverByManager@intel.com.crm', LastName='User', Email='test.user1@intel.com',
                           Alias='tclass1', TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US', EmailEncodingKey='UTF-8',
                           ProfileId=[select Id from Profile where Name='Standard User' limit 1][0].Id, LanguageLocaleKey='en_US'));
        
        users.add(new User(UserName='test.user2.testOppApproverByManager@intel.com.crm', LastName='User', Email='test.user2@intel.com',
                           Alias='tclass2', TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US', EmailEncodingKey='UTF-8',
                           ProfileId=[select Id from Profile where Name='Standard User' limit 1][0].Id, LanguageLocaleKey='en_US'));
        
        users.add(new User(UserName='test.user3.testOppApproverByManager@intel.com.crm', LastName='User', Email='test.user3@intel.com',
                           Alias='tclass3', TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US', EmailEncodingKey='UTF-8',
                           ProfileId=[select Id from Profile where Name='Standard User' limit 1][0].Id, LanguageLocaleKey='en_US'));
        
        users.add(new User(UserName='test.user4.testOppApproverByManager@intel.com.crm', LastName='User', Email='test.user4@intel.com',
                           Alias='tclass4', TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US', EmailEncodingKey='UTF-8',
                           ProfileId=[select Id from Profile where Name='Standard User' limit 1][0].Id, LanguageLocaleKey='en_US'));
        
        insert users;
        
        users[0].ManagerId = users[1].Id;
        users[2].ManagerId = users[3].Id;
        
        System.runAs(Core_Test_Utility.systemAdminUser) {
            update users;
        }
        
        
        
        accountList = Core_Test_Utility.createAccount(1);
        accountList[0].Name = 'Dell';
        accountList[0].Core_Sales_Groups__c = Core_CRM_Utility.getSalesGroupAPI();
        accountList[0].Industry = 'Agriculture';
        accountList[0].Core_Sub_Industry__c = 'Forestry';
        insert accountList;
        
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
        
        
        List<Opportunity> listOpportunity = Core_Test_Utility.createOpportunity(2);
        Id oppDealID = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Deal Opportunity').getRecordTypeId();
        Id oppDesignID = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Design Opportunity').getRecordTypeId();
        opp = listOpportunity[0];    
        opp.AccountId = accountList[0].Id;
        opp.Core_Commissionable__c='Yes'; 
        opp.RecordTypeId = oppDealID;
        opp.StageName = 'Qualify';    
        opp.Core_Opportunity_Type__c='Deal: Sell-to';
        opp.Core_Solution_Area__c = 'CCG Commercial Deal $';
        opp.Core_Lead_Conversion_Flag__c = false;
        opp.OwnerId = users[0].Id;
        opp.Core_Technical_Owner__c = users[2].Id;
        
        ////
        opp1 = listOpportunity[1];    
        opp1.AccountId = accountList[0].Id;
        opp1.Core_Commissionable__c='Yes';
        opp1.RecordTypeId = oppDesignID;
        opp1.StageName = 'Qualify';     
        opp1.Core_Opportunity_Type__c='Design: Original';
        opp1.Core_Solution_Area__c = 'CCG Commercial Deal $';
        opp1.Core_Lead_Conversion_Flag__c = false;
        opp1.Core_Intel_Platform__c = 'ALDER LAKE M';
        opp1.Core_First_Customer_Ship_Date__c = date.newInstance(2022, 08, 07);
        //opp1.Core_Technical_Owner__c = Core_Test_Utility.systemAdminUser.id;
        opp1.OwnerId = users[0].Id;
        opp1.Core_Technical_Owner__c = users[2].Id;
        
        System.runAs(Core_Test_Utility.systemAdminUser){
            insert opp;
            insert opp1;
        }
        List<Product2> testProducts = Core_Test_Utility.createProduct(3);
        insert testProducts;
        
        List<PricebookEntry> testPBEs = Core_Test_Utility.createPriceBookEntry(3, testProducts, Test.getStandardPricebookId());
        insert testPBEs;
        
        // Insert these in a specific order that we can rely on, since we can only sort by ID value when querying them from the
        // opportunity product history object later (can't sort on Description or any other attribute)
        OpportunityLineItem testOppLineItem;
        testOppLineItem = new OpportunityLineItem(OpportunityId=opp.Id, PricebookEntryId=testPBEs[0].Id,
                                                  Description='Test 11', UnitPrice=11, Quantity=11,
                                                  Core_Loss_Cancel_Reason__c=null, Core_Status__c='Pending');
        insert testOppLineItem;
        
    }
    
    
    static testMethod void validateReminderSchdl(){
        try{
            Date twelveDaysAgo = System.today().addDays(-12);
            //Date fifteenDaysAgo = System.today().addDays(-15);   
            Opportunity opp = [select id,StageName,CoE_Status__c,RecordTypeId,RecordType.DeveloperName,Core_Primary_Customer_Contact__c,Core_Date_Submitted_for_Approval__c  
                               from opportunity where name LIKE '%Test%' limit 1];
            
            OpportunityLineItem oli = [select id, core_status__c, Core_Write_In_Product_Flag__c from OpportunityLineItem where opportunityid = :opp.id];
            oli.Core_Write_In_Product_Flag__c = true;
            oli.Core_Status__c = 'Win Submitted';
            oli.Quantity = 1;
            oli.UnitPrice = 100;
            
            
            update oli;
            
            opp.Core_Primary_Customer_Contact__c=false;
            opp.CoE_Status__c='New';
            opp.StageName = 'Design';
            opp.Core_Date_Submitted_for_Approval__c = twelveDaysAgo;
            opp.core_approval_status__c = 'Submitted';
            
            update opp;
            update oli;
            
            
            Test.startTest();
            String sch = '0 57 * * * ?';
            //Core_OpportunityReminderSchdl testSch = new Core_OpportunityReminderSchdl();
            String jobId =System.schedule('Core_OpportunityReminderSchdl', sch, new Core_OpportunityReminderSchdl() );
            CronTrigger ct = [Select ID,CronExpression, TimesTriggered, NextFireTime from CronTrigger where Id =:jobId];
            System.assertEquals(sch,ct.CronExpression);
            System.assertEquals(0,ct.TimesTriggered);
            Test.stopTest();
            
        }catch(Exception ex){
            PMP_Utility.logError(ex, 'Core_OpportunityReminderSchdl_Test.validateReminderSchdl');
        }   
    }
    
    static testMethod void validateReminderSchdl2(){
        try{
            //Date twelveDaysAgo = System.today().addDays(-12);
            Date eighteenDaysAgo = System.today().addDays(-18);   
            Opportunity opp = [select id,StageName,CoE_Status__c,RecordTypeId,RecordType.DeveloperName,Core_Primary_Customer_Contact__c,Core_Date_Submitted_for_Approval__c  
                               from opportunity where name LIKE '%Test%' limit 1];
            
            OpportunityLineItem oli = [select id, core_status__c, Core_Write_In_Product_Flag__c from OpportunityLineItem where opportunityid = :opp.id];
            oli.Core_Write_In_Product_Flag__c = true;
            oli.Core_Status__c = 'Win Submitted';
            oli.Quantity = 1;
            oli.UnitPrice = 100;
            
            
            update oli;
            
            opp.Core_Primary_Customer_Contact__c=false;
            opp.CoE_Status__c='New';
            opp.StageName = 'Design';
            opp.Core_Date_Submitted_for_Approval__c = eighteenDaysAgo;
            opp.core_approval_status__c = 'Submitted';
            
            update opp;
            update oli;
            
            
            Test.startTest();
            String sch = '0 57 * * * ?';
            //Core_OpportunityReminderSchdl testSch = new Core_OpportunityReminderSchdl();
            String jobId =System.schedule('Core_OpportunityReminderSchdl', sch, new Core_OpportunityReminderSchdl() );
            CronTrigger ct = [Select ID,CronExpression, TimesTriggered, NextFireTime from CronTrigger where Id =:jobId];
            System.assertEquals(sch,ct.CronExpression);
            System.assertEquals(0,ct.TimesTriggered);
            Test.stopTest();
            
            
        }catch(Exception ex){
            PMP_Utility.logError(ex, 'Core_OpportunityReminderSchdl_Test.validateReminderSchdl2');
        }   
    }
}