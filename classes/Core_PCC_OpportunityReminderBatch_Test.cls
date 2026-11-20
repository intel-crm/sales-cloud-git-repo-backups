@isTest
public class Core_PCC_OpportunityReminderBatch_Test {
    
    @testSetup
    static void setupTest() {
        
        Core_Opp_Bypass_Validation_Rule__c rec = new Core_Opp_Bypass_Validation_Rule__c();
        rec.Bypass__c = true;
        insert rec;
        
        List<User> users = new List<User>();
        
        users.add(new User(UserName='test.user1.testOppApproverByManager@intel.com.crm', LastName='User', Email='test.user1@intel.com',
        Alias='tclass1', TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US', EmailEncodingKey='UTF-8',
        ProfileId=[select Id from Profile where Name='Sales Rep-BB' limit 1][0].Id, LanguageLocaleKey='en_US', Isactive = true));
        
        users.add(new User(UserName='test.user2.testOppApproverByManager@intel.com.crm', LastName='User', Email='jahnavix.chowdary@intel.com',
        Alias='tclass2', TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US', EmailEncodingKey='UTF-8',
        ProfileId=[select Id from Profile where Name='Standard User' limit 1][0].Id, LanguageLocaleKey='en_US', Isactive = true));
        
        users.add(new User(UserName='test.user3.testOppApproverByManager@intel.com.crm', LastName='User', Email='test.user3@intel.com',
        Alias='tclass3', TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US', EmailEncodingKey='UTF-8',
        ProfileId=[select Id from Profile where Name='Standard User' limit 1][0].Id, LanguageLocaleKey='en_US', Isactive = true));
        
        users.add(new User(UserName='test.user4.testOppApproverByManager@intel.com.crm', LastName='User', Email='test.user4@intel.com',
        Alias='tclass4', TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US', EmailEncodingKey='UTF-8',
        ProfileId=[select Id from Profile where Name='Sales Rep-BB' limit 1][0].Id, LanguageLocaleKey='en_US', Isactive = true));
        
        insert users;
        
        users[0].ManagerId = users[1].Id;
        users[2].ManagerId = users[3].Id;       
        System.runAs(Core_Test_Utility.systemAdminUser) {
            update users;
        }
   
        List<Account> accountList = new List <Account>();
        accountList = Core_Test_Utility.createAccount(1);
        accountList[0].Name = 'Dell';
        accountList[0].Core_Sales_Groups__c = Core_CRM_Utility.getSalesGroupAPI();
        accountList[0].Industry = 'Agriculture';
        accountList[0].Core_Sub_Industry__c = 'Forestry';
        insert accountList;
        
        List<Opportunity> listOpportunity = Core_Test_Utility.createOpportunity(1);
        Id oppDealID = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Deal Opportunity').getRecordTypeId();
      
        Opportunity opp = new Opportunity();
        opp = listOpportunity[0];    
        opp.AccountId = accountList[0].Id;
        opp.Core_Commissionable__c='Yes'; 
        opp.RecordTypeId = oppDealID;
        //opp.StageName = 'Qualify';    
        opp.Core_Opportunity_Coverage_Nm__c= 'Partner-Led Opportunity';
        opp.Core_Coverage_Type_Nm__c= 'Deal Registration';
        opp.Core_Opportunity_Type__c='Deal: Sell-to';
        opp.Core_Solution_Area__c = 'CCG Commercial Deal $';
        opp.Core_Lead_Conversion_Flag__c = false;
        opp.OwnerId = users[1].Id;
        opp.CloseDate = System.today().addDays(30); 
        opp.Core_Technical_Owner__c = users[1].Id;
        
        
        System.runAs(Core_Test_Utility.systemAdminUser){
            insert opp;    
        }
        
        List<Product2> testProducts = Core_Test_Utility.createProduct(1);
        insert testProducts;
        
        List<PricebookEntry> testPBEs = Core_Test_Utility.createPriceBookEntry(1, testProducts, Test.getStandardPricebookId());
        insert testPBEs;
        
        OpportunityLineItem testOppLineItem;
        testOppLineItem = new OpportunityLineItem(OpportunityId=opp.Id, PricebookEntryId=testPBEs[0].Id,
                                                  Description='Test 11', UnitPrice=11, Quantity=11,
                                                  Core_Loss_Cancel_Reason__c=null, Core_Status__c='Pending');
        insert testOppLineItem;
        
    }
    
   
    static testMethod void validateReminderSchdl(){
        try{
            Date todayPlus30 = System.today().addDays(30); 
            Opportunity opp = [select Id, Name, Core_Technical_Owner__c, OwnerId, Owner.Email , Core_Technical_Owner__r.Email,Opportunity.Core_Opportunity_Coverage_Nm__c FROM Opportunity 
                                         WHERE Core_Opportunity_Coverage_Nm__c = 'Partner-Led Opportunity' AND Core_Coverage_Type_Nm__c = 'Deal Registration' AND CloseDate = :todayPlus30 limit 1];
            
            System.assertEquals('Partner-Led Opportunity',opp.Core_Opportunity_Coverage_Nm__c);
            
            Test.startTest();
            Core_PCC_OpportunityReminderBatch batchInstance = new Core_PCC_OpportunityReminderBatch();
            Database.executeBatch(new Core_PCC_OpportunityReminderBatch(),20);
           
            Test.stopTest();
            
            }catch(Exception ex){
            System.debug('Exception in test::'+ex);
        }   
    }
}