/****************************************************************************************************
Apex Class Name : Core_OpportunityContactRoleHandler_Test
Version         : 1.0 
Created Date    : 12 March 2024
Function        : Test class for Opportunity Contact Role handler
Modifications:
*****************************************************************************************************/
@isTest
public class Core_OpportunityContactRoleHandler_Test {
    @testSetup
    static void setupData(){
        list<Core_Trigger_Executions__c> trigList = new list<Core_Trigger_Executions__c>();
        Core_Trigger_Executions__c triggerEntry = new Core_Trigger_Executions__c(Name='lockPCCOpportunity', Core_Object__c='Opportunity',
                                                                                 Core_Class_Name__c='Core_OpportunityLineItemHandler',Core_Trigger_Events__c='before update, before insert', 
                                                                                 Core_Active__c=true, Core_Description__c='for PCC Lock');
        trigList.add(triggerEntry);
        insert trigList;
        
        Account acct = new Account(Name = 'Test Account1', Industry = 'Agriculture', Core_Sub_Industry__c = 'Forestry', 
                                   BillingStreet = '123 Fake St',BillingCity = 'Springfield', BillingState = 'IL', BillingCountry = 'USA',
                                   BillingPostalCode = '12345', Core_Sales_Groups__c='EMEA Sales Group');
        insert acct;
        list<opportunity> oppList = new list<opportunity>();
        Id DealOppRecTypeId = [select Id from RecordType where DeveloperName = 'Core_Deal_Opportunity' limit 1][0].Id;
        Opportunity oppty = new Opportunity(Name = 'PCC Opportunity', RecordTypeId = DealOppRecTypeId,
                                            AccountId = acct.Id, OwnerId= UserInfo.getUserId(),Core_Coverage_Type_Nm__c = 'Deal Registration',
                                            StageName = 'Qualify', CloseDate = System.Date.today().addYears(1), Core_Opportunity_Coverage_Nm__c ='Partner-Led Opportunity');
        oppList.add(oppty);
        Opportunity oppty1 = new Opportunity(Name = 'Intel Opportunity', RecordTypeId = DealOppRecTypeId, Core_Opportunity_Coverage_Nm__c ='Intel-Led Opportunity',
                                            AccountId = acct.Id, OwnerId= UserInfo.getUserId(), StageName = 'Qualify', CloseDate = System.Date.today().addYears(1));
        
        oppList.add(oppty1);
        insert oppList;
        
        Contact cont = new Contact();
        cont.FirstName = 'Test';
        cont.LastName  = 'Contact';
        cont.AccountId = acct.id;
        cont.MailingCountry = 'IND';
        cont.Email = 'testingPCC123@example.com';
        insert cont;
    }
    static testMethod void checkPCCLockOnOpptyInsert_Test(){
        
        Opportunity opp = [select id, name from Opportunity where name = 'PCC Opportunity'];
        Contact con = [select id,name from Contact where name = 'Test Contact'];
        List<OpportunityContactRole> ocrList = new List<OpportunityContactRole>();
        OpportunityContactRole ocr = new OpportunityContactRole();
        ocr.ContactId = con.Id;
        ocr.OpportunityId = opp.Id;
        ocr.IsPrimary = TRUE;
        ocr.Role = 'Business Decision Maker';
        ocrList.add(ocr);
        test.startTest();
        insert ocrList;
        
        Core_CRM_Utility.oppLockValidationPerformed = false;
        ocrList[0].IsPrimary = False;
        update ocrList;
        
        test.stopTest();
        
        //Core_CRM_Utility.oppLockValidationPerformed = false;
        Core_OpportunityContactRoleHandler.checkPCCLockOnOppty(ocrList);
    }
    
    static testMethod void checkRestrictionPrimaryContactRole_Test() {  
        Core_Trigger_Executions__c triggerEntry1 = new Core_Trigger_Executions__c(Name='checkPrimaryContactRole', Core_Object__c='Opportunity',
                                                                                 Core_Class_Name__c='Core_OpportunityLineItemHandler',Core_Trigger_Events__c='before update, before insert', 
                                                                                 Core_Active__c=true, Core_Description__c='for PCC Lock');
        insert triggerEntry1;
        Opportunity opp = [select id, name from Opportunity where name = 'Intel Opportunity'];
        Contact con = [select id,name from Contact where name = 'Test Contact'];
        List<OpportunityContactRole> ocrList = new List<OpportunityContactRole>();
        OpportunityContactRole ocr = new OpportunityContactRole();
        ocr.ContactId = con.Id;
        ocr.OpportunityId = opp.Id;
        ocr.IsPrimary = TRUE;
        ocr.Role = 'Technical Decision Maker';
        ocrList.add(ocr);
        test.startTest();
        insert ocrList;
        ocrList[0].IsPrimary = False;
        update ocrList;
        ocrList[0].IsPrimary = True;
        update ocrList;
        test.stopTest();
    }
}