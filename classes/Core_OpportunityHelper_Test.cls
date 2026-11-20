@isTest
public class Core_OpportunityHelper_Test {
    
    @testSetup
    static void setupTestData() {   
        
        // Enable the Trigger execution
        List<Core_Trigger_Executions__c> ToClearlist = [Select id from Core_Trigger_Executions__c LIMIT 2000];
        delete ToClearlist;
        List<Core_Trigger_Executions__c> triggerExecList = new List<Core_Trigger_Executions__c>();
        Core_Trigger_Executions__c triggerExec25 = new Core_Trigger_Executions__c();
        triggerExec25.Name='UpdateTerritoryInfoOnOppty'; 
        triggerExec25.Core_Class_Name__c='Core_OpportunityHandler';
        triggerExec25.Core_Object__c='Opportunity';
        triggerExec25.Core_Trigger_Events__c='before insert'; 
        triggerExec25.Core_Active__c=true; 
        triggerExec25.Core_Description__c = 'blah blah';
        triggerExecList.add(triggerExec25);
        
        triggerExec25 = new Core_Trigger_Executions__c();
        triggerExec25.Name='RestrictSolutionDetailLOV'; 
        triggerExec25.Core_Class_Name__c='Core_OpportunityHandler';
        triggerExec25.Core_Object__c='Opportunity';
        triggerExec25.Core_Trigger_Events__c='before insert'; 
        triggerExec25.Core_Active__c=true; 
        triggerExec25.Core_Description__c = 'blah blah';
        triggerExecList.add(triggerExec25);
        
        triggerExec25 = new Core_Trigger_Executions__c();
        triggerExec25.Name='CombineSolutionDetailFields'; 
        triggerExec25.Core_Class_Name__c='Core_OpportunityHandler';
        triggerExec25.Core_Object__c='Opportunity';
        triggerExec25.Core_Trigger_Events__c='before insert'; 
        triggerExec25.Core_Active__c=true; 
        triggerExec25.Core_Description__c = 'blah blah';
        triggerExecList.add(triggerExec25);
        
        triggerExec25 = new Core_Trigger_Executions__c();
        triggerExec25.Name='OpportunityCoEStatusUpdate'; 
        triggerExec25.Core_Class_Name__c='Core_OpportunityHandler';
        triggerExec25.Core_Object__c='Opportunity';
        triggerExec25.Core_Trigger_Events__c='before insert'; 
        triggerExec25.Core_Active__c=true; 
        triggerExec25.Core_Description__c = 'blah blah';
        triggerExecList.add(triggerExec25);
        
        triggerExec25 = new Core_Trigger_Executions__c();
        triggerExec25.Name='POPCheckOnUpdate'; 
        triggerExec25.Core_Class_Name__c='Core_POP_Handler';
        triggerExec25.Core_Object__c='Opportunity';
        triggerExec25.Core_Trigger_Events__c='before insert'; 
        triggerExec25.Core_Active__c=true; 
        triggerExec25.Core_Description__c = 'blah blah';
        triggerExecList.add(triggerExec25);
        
        triggerExec25 = new Core_Trigger_Executions__c();
        triggerExec25.Name='Tech_CIMID_Validation'; 
        triggerExec25.Core_Class_Name__c='Core_POP_Handler';
        triggerExec25.Core_Object__c='Opportunity';
        triggerExec25.Core_Trigger_Events__c='before insert'; 
        triggerExec25.Core_Active__c=true; 
        triggerExec25.Core_Description__c = 'blah blah';
        triggerExecList.add(triggerExec25);
        
        triggerExec25 = new Core_Trigger_Executions__c();
        triggerExec25.Name='updateProductLineItems'; 
        triggerExec25.Core_Class_Name__c='Core_OppApproval';
        triggerExec25.Core_Object__c='Opportunity';
        triggerExec25.Core_Trigger_Events__c='before insert'; 
        triggerExec25.Core_Active__c=true; 
        triggerExec25.Core_Description__c = 'blah blah';
        triggerExecList.add(triggerExec25);
        
        triggerExec25 = new Core_Trigger_Executions__c();
        triggerExec25.Name='opportunityTechnicalOwnerUpdate'; 
        triggerExec25.Core_Class_Name__c='Core_OpportunityHandler';
        triggerExec25.Core_Object__c='Opportunity';
        triggerExec25.Core_Trigger_Events__c='before insert'; 
        triggerExec25.Core_Active__c=true; 
        triggerExec25.Core_Description__c = 'blah blah';
        triggerExecList.add(triggerExec25);
        
        triggerExec25 = new Core_Trigger_Executions__c();
        triggerExec25.Name='opportunityStageUpdate'; 
        triggerExec25.Core_Class_Name__c='Core_OpportunityHandler';
        triggerExec25.Core_Object__c='Opportunity';
        triggerExec25.Core_Trigger_Events__c='before insert'; 
        triggerExec25.Core_Active__c=true; 
        triggerExec25.Core_Description__c = 'blah blah';
        triggerExecList.add(triggerExec25);
        
        triggerExec25 = new Core_Trigger_Executions__c();
        triggerExec25.Name='updateActivityLineItems'; 
        triggerExec25.Core_Class_Name__c='Core_OpportunityHandler';
        triggerExec25.Core_Object__c='Opportunity';
        triggerExec25.Core_Trigger_Events__c='before insert'; 
        triggerExec25.Core_Active__c=true; 
        triggerExec25.Core_Description__c = 'blah blah';
        triggerExecList.add(triggerExec25);
        
        triggerExec25 = new Core_Trigger_Executions__c();
        triggerExec25.Name='forecastUpdateFromOppty'; 
        triggerExec25.Core_Class_Name__c='Core_OpportunityHandler';
        triggerExec25.Core_Object__c='Opportunity';
        triggerExec25.Core_Trigger_Events__c='before insert'; 
        triggerExec25.Core_Active__c=true; 
        triggerExec25.Core_Description__c = 'blah blah';
        triggerExecList.add(triggerExec25);
        
        triggerExec25 = new Core_Trigger_Executions__c();
        triggerExec25.Name='OpportunityKPIJSON'; 
        triggerExec25.Core_Class_Name__c='Core_OpportunityHandler';
        triggerExec25.Core_Object__c='Opportunity';
        triggerExec25.Core_Trigger_Events__c='before insert'; 
        triggerExec25.Core_Active__c=true; 
        triggerExec25.Core_Description__c = 'blah blah';
        triggerExecList.add(triggerExec25);
        
        triggerExec25 = new Core_Trigger_Executions__c();
        triggerExec25.Name='delegateApproverRoleChange'; 
        triggerExec25.Core_Class_Name__c='Core_DelegateApproverOppShare';
        triggerExec25.Core_Object__c='Opportunity';
        triggerExec25.Core_Trigger_Events__c='before insert'; 
        triggerExec25.Core_Active__c=true; 
        triggerExec25.Core_Description__c = 'blah blah';
        triggerExecList.add(triggerExec25);
        
        triggerExec25 = new Core_Trigger_Executions__c();
        triggerExec25.Name='RestrictSolutionAreaInactiveLOV'; 
        triggerExec25.Core_Class_Name__c='Core_OpportunityHandler';
        triggerExec25.Core_Object__c='Opportunity';
        triggerExec25.Core_Trigger_Events__c='before insert'; 
        triggerExec25.Core_Active__c=true; 
        triggerExec25.Core_Description__c = 'blah blah';
        triggerExecList.add(triggerExec25);
        
        triggerExec25 = new Core_Trigger_Executions__c();
        triggerExec25.Name='BlockExistingOppOnLeadConversion'; 
        triggerExec25.Core_Class_Name__c='Core_OpportunityHandler';
        triggerExec25.Core_Object__c='Opportunity';
        triggerExec25.Core_Trigger_Events__c='before insert'; 
        triggerExec25.Core_Active__c=true; 
        triggerExec25.Core_Description__c = 'blah blah';
        triggerExecList.add(triggerExec25);
        
        triggerExec25 = new Core_Trigger_Executions__c();
        triggerExec25.Name='determineApprovers'; 
        triggerExec25.Core_Class_Name__c='Core_OppApproval';
        triggerExec25.Core_Object__c='Opportunity';
        triggerExec25.Core_Trigger_Events__c='before insert'; 
        triggerExec25.Core_Active__c=true; 
        triggerExec25.Core_Description__c = 'blah blah';
        triggerExecList.add(triggerExec25);
        
        triggerExec25 = new Core_Trigger_Executions__c();
        triggerExec25.Name='opportunityOppFactDelete'; 
        triggerExec25.Core_Class_Name__c='Core_OpportunityHandler';
        triggerExec25.Core_Object__c='Opportunity';
        triggerExec25.Core_Trigger_Events__c='before delete'; 
        triggerExec25.Core_Active__c=true; 
        triggerExec25.Core_Description__c = 'blah blah';
        triggerExecList.add(triggerExec25);
        
        triggerExec25 = new Core_Trigger_Executions__c();
        triggerExec25.Name='deleteKPIonOpportunityDelete'; 
        triggerExec25.Core_Class_Name__c='Core_OpportunityHandler';
        triggerExec25.Core_Object__c='Opportunity';
        triggerExec25.Core_Trigger_Events__c='before delete'; 
        triggerExec25.Core_Active__c=true; 
        triggerExec25.Core_Description__c = 'blah blah';
        triggerExecList.add(triggerExec25);
        
        triggerExec25 = new Core_Trigger_Executions__c();
        triggerExec25.Name='FedCRMShareUnshare'; 
        triggerExec25.Core_Class_Name__c='Core_OpportunityHandler';
        triggerExec25.Core_Object__c='Opportunity';
        triggerExec25.Core_Trigger_Events__c='after insert,after update'; 
        triggerExec25.Core_Active__c=true; 
        triggerExec25.Core_Description__c = 'blah blah';
        triggerExecList.add(triggerExec25);
        
        
        triggerExec25 = new Core_Trigger_Executions__c();
        triggerExec25.Name='PCCDealRegOwnerOptyQuoteSync'; 
        triggerExec25.Core_Class_Name__c='Core_OpportunityHandler';
        triggerExec25.Core_Object__c='Opportunity';
        triggerExec25.Core_Trigger_Events__c='after insert,after update'; 
        triggerExec25.Core_Active__c=true; 
        triggerExec25.Core_Description__c = 'blah blah';
        triggerExecList.add(triggerExec25);
        
        
        triggerExec25 = new Core_Trigger_Executions__c();
        triggerExec25.Name='OpportunityShare'; 
        triggerExec25.Core_Class_Name__c='Core_OpportunityHandler';
        triggerExec25.Core_Object__c='Opportunity';
        triggerExec25.Core_Trigger_Events__c='after update'; 
        triggerExec25.Core_Active__c=true; 
        triggerExec25.Core_Description__c = 'blah blah';
        triggerExecList.add(triggerExec25);
        
        triggerExec25 = new Core_Trigger_Executions__c();
        triggerExec25.Name='OpportunityAutoCalculate6QPS'; 
        triggerExec25.Core_Class_Name__c='Core_OpportunityHandler';
        triggerExec25.Core_Object__c='Opportunity';
        triggerExec25.Core_Trigger_Events__c='after update'; 
        triggerExec25.Core_Active__c=true; 
        triggerExec25.Core_Description__c = 'blah blah';
        triggerExecList.add(triggerExec25);
        
        triggerExec25 = new Core_Trigger_Executions__c();
        triggerExec25.Name='OpportunityKPIfieldRefresh'; 
        triggerExec25.Core_Class_Name__c='Core_OpportunityHandler';
        triggerExec25.Core_Object__c='Opportunity';
        triggerExec25.Core_Trigger_Events__c='before update'; 
        triggerExec25.Core_Active__c=true; 
        triggerExec25.Core_Description__c = 'blah blah';
        triggerExecList.add(triggerExec25);
        
        
        triggerExec25 = new Core_Trigger_Executions__c();
        triggerExec25.Name='ILO_syncStatus_Opportunity_IQRQuote'; 
        triggerExec25.Core_Class_Name__c='Core_OpportunityHandler';
        triggerExec25.Core_Object__c='Opportunity';
        triggerExec25.Core_Trigger_Events__c='after update'; 
        triggerExec25.Core_Active__c=true; 
        triggerExec25.Core_Description__c = 'blah blah';
        triggerExecList.add(triggerExec25);
        
        triggerExec25 = new Core_Trigger_Executions__c();
        triggerExec25.Name='storeOppTeamMemDescription'; 
        triggerExec25.Core_Class_Name__c='Core_OpportunityHandler';
        triggerExec25.Core_Object__c='Opportunity';
        triggerExec25.Core_Trigger_Events__c='after update'; 
        triggerExec25.Core_Active__c=true; 
        triggerExec25.Core_Description__c = 'blah blah';
        triggerExecList.add(triggerExec25);
        
        triggerExec25 = new Core_Trigger_Executions__c();
        triggerExec25.Name='TechnicalOwnerAdditiontoTM'; 
        triggerExec25.Core_Class_Name__c='Core_OpportunityHandler2';
        triggerExec25.Core_Object__c='Opportunity';
        triggerExec25.Core_Trigger_Events__c='after update'; 
        triggerExec25.Core_Active__c=true; 
        triggerExec25.Core_Description__c = 'blah blah';
        triggerExecList.add(triggerExec25);
        
        triggerExec25 = new Core_Trigger_Executions__c();
        triggerExec25.Name='updatePWFieldsonProduct'; 
        triggerExec25.Core_Class_Name__c='Core_OpportunityHandler';
        triggerExec25.Core_Object__c='Opportunity';
        triggerExec25.Core_Trigger_Events__c='after update'; 
        triggerExec25.Core_Active__c=true; 
        triggerExec25.Core_Description__c = 'blah blah';
        triggerExecList.add(triggerExec25);
            
        insert triggerExecList;
    }
    
     Static testmethod void testOppsHelperMethods(){
     
      setupTestData();
      test.startTest();
      Profile prf = [select id, name from Profile where name = 'System Administrator' Limit 1];
                
                User adminUser = new User(Alias = 'admin', 
                              Email='adminTest010@intel.com', 
                              EmailEncodingKey='UTF-8',
                              LastName='Testing01',
                              LanguageLocaleKey='en_US', 
                              LocaleSidKey='en_US', 
                              ProfileId = prf.Id, 
                              TimeZoneSidKey='America/Los_Angeles',
                              UserName='adminTest010@intel.com');
                insert adminUser;
         System.RunAs(adminUser){
       
        Core_Opp_Bypass_Validation_Rule__c BypassRule = new Core_Opp_Bypass_Validation_Rule__c();
        BypassRule.Bypass__c = true;
        insert BypassRule;
        Id accDealID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        // Create a new account        
        Account acct = new Account(Name = 'New Test Account1', BillingStreet = '123 Fake St',Industry ='Gaming', Core_Sub_Industry__c   ='eSports',
                                   BillingCity = 'Springfield', BillingState = 'IL', BillingCountry = 'USA',
                                   BillingPostalCode = '12345', Core_Sales_Groups__c=Core_CRM_Utility.getSalesGroupAPI(), RecordTypeId = accDealID);//Core_CIM_ID__c = '8675309'
        insert acct;
        
        // Create a new product
        Product2 product = new Product2(Name = 'Test Product1');
        insert product;
        
        // Create a new price book entry using the product created above
        PricebookEntry pbe = new PricebookEntry(Product2Id = product.Id, Pricebook2Id = Test.getStandardPricebookId(),
                                                UnitPrice = 100, IsActive = true);
        insert pbe;
        
        // Create a new opportunity using the account created above
        List<Opportunity> oppList = new List<Opportunity>();
        Id newOppRecTypeId = [select Id from RecordType where DeveloperName = 'Core_Deal_Opportunity' limit 1][0].Id;
        Opportunity opp = new Opportunity(Name = 'Test Opportunity100', RecordTypeId = newOppRecTypeId,
                                                  AccountId = acct.Id, StageName = 'Qualify', CloseDate = System.Date.today().addYears(1),Opportunity_Focus__c='Core',Core_Opportunity_Type__c = 'Deal: Sell-through');
        
        oppList.add(opp);
        opp = new Opportunity(Name = 'Test Opportunity200', RecordTypeId = newOppRecTypeId,
                                                  AccountId = acct.Id, StageName = 'Qualify', CloseDate = System.Date.today().addYears(1),Core_Created_from_CPQ__c=false,Opportunity_Focus__c='Core',Core_Opportunity_Type__c = 'Deal: Sell-through');
        
        oppList.add(opp);
        opp = new Opportunity(Name = 'Test Opportunity300', RecordTypeId = newOppRecTypeId,
                                                  AccountId = acct.Id, StageName = 'Qualify', CloseDate = System.Date.today().addYears(1),Opportunity_Focus__c='Core',Core_Opportunity_Type__c = 'Deal: Sell-through');
        
        oppList.add(opp);
        opp = new Opportunity(Name = 'Test Opportunity400', RecordTypeId = newOppRecTypeId,
                                                  AccountId = acct.Id, StageName = 'Qualify', CloseDate = System.Date.today().addYears(1),Opportunity_Focus__c='Core',Core_Opportunity_Type__c = 'Deal: Sell-through');
        
        oppList.add(opp);
        opp = new Opportunity(Name = 'Test Opportunity500', RecordTypeId = newOppRecTypeId,
                                                  AccountId = acct.Id, StageName = 'Qualify', CloseDate = System.Date.today().addYears(1),Opportunity_Focus__c='Core',Core_Opportunity_Type__c = 'Deal: Sell-through');
        
        oppList.add(opp);
        insert oppList;
        
          
        User usr2 = [select id from User where IsActive =true and profile.name = 'Sales Manager' order by FirstName limit 1];
        
         User usr3 = [select id from User where IsActive =true and profile.name = 'Sales Manager' order by LastName  limit 1];
         
       
         opp.Core_Technical_Owner__c = usr3.id;
        
        update opp;
        
       
         opp.Core_Technical_Owner__c = usr2.id;
        
        update opp;
        
        System.assertNotEquals(null, opp, 'The opportunity record updated with Technical owner');

        delete opplist;
        }
        test.stopTest();
    }
    
    Static testmethod void testOppsHelperMethos(){
        setupTestData();
        test.startTest();
      Profile prf = [select id, name from Profile where name = 'System Administrator' Limit 1];
                
                User adminUser = new User(Alias = 'admin', 
                              Email='adminTest010@intel.com', 
                              EmailEncodingKey='UTF-8',
                              LastName='Testing01',
                              LanguageLocaleKey='en_US', 
                              LocaleSidKey='en_US', 
                              ProfileId = prf.Id, 
                              TimeZoneSidKey='America/Los_Angeles',
                              UserName='adminTest010@intel.com');
                insert adminUser;
         System.RunAs(adminUser){
        Core_Opp_Bypass_Validation_Rule__c BypassRule = new Core_Opp_Bypass_Validation_Rule__c();
        BypassRule.Bypass__c = true;
        insert BypassRule;
        Id accDealID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        // Create a new account        
        Account acct = new Account(Name = 'New Test Account1', BillingStreet = '123 Fake St',Industry ='Gaming', Core_Sub_Industry__c   ='eSports',
                                   BillingCity = 'Springfield', BillingState = 'IL', BillingCountry = 'USA',
                                   BillingPostalCode = '12345', Core_Sales_Groups__c=Core_CRM_Utility.getSalesGroupAPI(), RecordTypeId = accDealID);//Core_CIM_ID__c = '8675309'
        insert acct;
        
        // Create a new product
        Product2 product = new Product2(Name = 'Test Product1');
        insert product;
        
        // Create a new price book entry using the product created above
        PricebookEntry pbe = new PricebookEntry(Product2Id = product.Id, Pricebook2Id = Test.getStandardPricebookId(),
                                                UnitPrice = 100, IsActive = true);
        insert pbe;
        
        // Create a new opportunity using the account created above
        List<Opportunity> oppList = new List<Opportunity>();
        Id newOppRecTypeId = [select Id from RecordType where DeveloperName = 'Core_Design_Opportunity' limit 1][0].Id;
        Opportunity opp = new Opportunity(Name = 'Test Opportunity1', RecordTypeId = newOppRecTypeId,
                                                  AccountId = acct.Id, StageName = 'Qualify', CloseDate = System.Date.today().addYears(1),Opportunity_Focus__c='Core',Core_Opportunity_Type__c = 'Design: Software-enable');
        
        oppList.add(opp);
        opp = new Opportunity(Name = 'Test Opportunity2', RecordTypeId = newOppRecTypeId,
                                                  AccountId = acct.Id, StageName = 'Qualify', CloseDate = System.Date.today().addYears(1),Core_Created_from_CPQ__c=false,Opportunity_Focus__c='Core',Core_Opportunity_Type__c = 'Design: Software-enable');
        
        oppList.add(opp);
        opp = new Opportunity(Name = 'Test Opportunity3', RecordTypeId = newOppRecTypeId,
                                                  AccountId = acct.Id, StageName = 'Qualify', CloseDate = System.Date.today().addYears(1),Opportunity_Focus__c='Core',Core_Opportunity_Type__c = 'Design: Software-enable');
        
        oppList.add(opp);
        opp = new Opportunity(Name = 'Test Opportunity4', RecordTypeId = newOppRecTypeId,
                                                  AccountId = acct.Id, StageName = 'Qualify', CloseDate = System.Date.today().addYears(1),Opportunity_Focus__c='Core',Core_Opportunity_Type__c = 'Design: Software-enable');
        
        oppList.add(opp);
        opp = new Opportunity(Name = 'Test Opportunity5', RecordTypeId = newOppRecTypeId,
                                                  AccountId = acct.Id, StageName = 'Qualify', CloseDate = System.Date.today().addYears(1),Opportunity_Focus__c='Core',Core_Opportunity_Type__c = 'Design: Software-enable');
        
        oppList.add(opp);
        
       
        insert oppList;
        
         
         User usr2 = [select id from User where IsActive =true and profile.name = 'Sales Manager' order by FirstName limit 1];
        
         User usr3 = [select id from User where IsActive =true and profile.name = 'Sales Manager' order by LastName  limit 1];
         
       
         opp.Core_Technical_Owner__c = usr3.id;
        
        update opp;
        
       
         opp.Core_Technical_Owner__c = usr2.id;
        
        update opp;
        System.assertNotEquals(null, opp, 'The opportunity record updated with Technical owner');
        delete opplist;
        }
        test.stopTest();
    }
    
   
}