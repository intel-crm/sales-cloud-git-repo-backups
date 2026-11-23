@isTest
public class Core_OpportunityPartnerHandler_Test {
    
    private static final List<String> partnerTypes = new List<String>{'LOEM','ODM','OEM','Reseller'};
        
    private static final List<String> existingPartnerNames = new List<String>{
        'Existing Partner 0','Existing Partner 1','Existing Partner 2','Existing Partner 3',
        'Existing Partner 4','Existing Partner 5','Existing Partner 6'};
    private static final Integer numExistingPartners = 7;
    
    private static final List<String> existingPartnerNew = new List<String>{
        'Existing Partner 11','Existing Partner 12','Existing Partner 13','Existing Partner 14',
        'Existing Partner 15','Existing Partner 16','Existing Partner 17'};
            
    private static final List<String> newPartnerNames = new List<String>{
        'New Partner 00','New Partner 01','New Partner 02','New Partner 03','New Partner 04',
        'New Partner 05','New Partner 06','New Partner 07','New Partner 08','New Partner 09',
        'New Partner 10','New Partner 11','New Partner 12','New Partner 13','New Partner 14',
        'New Partner 15','New Partner 16','New Partner 17','New Partner 18','New Partner 19'};
    private static final Integer numNewPartners = 20;
    
    private static final Integer numOpportunities = 5;
    
    static testMethod void testInsertForSingleOpp() {
        
        // Get the test data that's already set up
        List<Opportunity> opps = [select Id from Opportunity where Name like 'Test Opportunity %' order by Name];
        List<Account> newPartnerAccts = [select Id from Account where Name like 'New Partner %' order by Name];
        
        // SINGLE OPPORTUNITY TEST        
        List<Core_Opportunity_Partner__c> newOppPartners = new List<Core_Opportunity_Partner__c>();
        newOppPartners.add(new Core_Opportunity_Partner__c(Core_Opportunity__c=opps[0].Id, Core_Partner__c=newPartnerAccts[0].Id,
                                                           Core_Partner_Type__c='LOEM', Core_Partner_Role__c='testing'));
        newOppPartners.add(new Core_Opportunity_Partner__c(Core_Opportunity__c=opps[0].Id, Core_Partner__c=newPartnerAccts[1].Id,
                                                           Core_Partner_Type__c='ODM', Core_Partner_Role__c='testing'));
        newOppPartners.add(new Core_Opportunity_Partner__c(Core_Opportunity__c=opps[0].Id, Core_Partner__c=newPartnerAccts[2].Id,
                                                           Core_Partner_Type__c='ODM', Core_Partner_Role__c='testing'));
        newOppPartners.add(new Core_Opportunity_Partner__c(Core_Opportunity__c=opps[0].Id, Core_Partner__c=newPartnerAccts[3].Id,
                                                           Core_Partner_Type__c='Reseller', Core_Partner_Role__c='testing'));
        newOppPartners.add(new Core_Opportunity_Partner__c(Core_Opportunity__c=opps[0].Id, Core_Partner__c=newPartnerAccts[4].Id,
                                                           Core_Partner_Type__c='Reseller', Core_Partner_Role__c='testing'));
        
        Test.startTest();
        insert newOppPartners;
        Database.executeBatch(new Core_OpportunityPartnerBatchUpdate());
        Test.stopTest();
        
        List<Core_Opportunity_Facts__c> oppFacts = [select Id, Core_Opportunity_ID__c, Core_LOEM__c,
                                                    Core_ODM__c, Core_OEM__c, Core_Reseller__c from Core_Opportunity_Facts__c
                                                    where Core_Opportunity_ID__c = :opps[0].Id];
        
        System.assertEquals(newPartnerNames[0] + ';',
                            oppFacts[0].Core_LOEM__c);
        System.assertEquals(existingPartnerNames[0] + ';' + newPartnerNames[1] + ';' + newPartnerNames[2] + ';',
                            oppFacts[0].Core_ODM__c);
        System.assertEquals(existingPartnerNames[1] + ';' + existingPartnerNames[2] + ';',
                            oppFacts[0].Core_OEM__c);
        System.assertEquals(newPartnerNames[3] + ';' + newPartnerNames[4] + ';',
                            oppFacts[0].Core_Reseller__c);
        
    }
    
    static testMethod void testInsertForMultipleOpps() {
        
        // Get the test data that's already set up
        List<Opportunity> opps = [select Id from Opportunity where Name like 'Test Opportunity %' order by Name];
        List<Account> newPartnerAccts = [select Id from Account where Name like 'New Partner %' order by Name];
        
        // MULTIPLE OPPORTUNITY TEST
        List<Core_Opportunity_Partner__c> newOppPartners = new List<Core_Opportunity_Partner__c>();
        for (Integer i=0; i<5; i++)
            for (Integer j=0; j<20; j++)
                newOppPartners.add(new Core_Opportunity_Partner__c(Core_Opportunity__c=opps[i].Id, Core_Partner__c=newPartnerAccts[j].Id,
                                                                   Core_Partner_Type__c=partnerTypes[Math.mod(j,4)], Core_Partner_Role__c='testing'));
        
        Test.startTest();
        insert newOppPartners;
        Test.stopTest();
                
        // If we make it here, we can assume it worked in bulk. Correctness of the field values is covered elsewhere.
        // We just need to check to make sure we have as many Opportunity Facts records as we expect.
        Integer numFacts = [select count() from Core_Opportunity_Facts__c LIMIT 10];
        System.assertEquals(5, numFacts);
    }
    
    static testMethod void testUpdate() {
        
        // Get the test data that's already set up
        List<Opportunity> opps = [select Id from Opportunity where Name like 'Test Opportunity %' order by Name];
        List<Account> existingPartnerAccts = [select Id from Account where Name like 'Existing Partner %' order by Name];
        List<Core_Opportunity_Partner__c> existingOppPartners =
            [select Id, Core_Partner__c from Core_Opportunity_Partner__c
             where Core_Partner__r.Name like 'Existing Partner %' order by Name];
        
        // UPDATE TEST
        existingOppPartners[0].Core_Partner__c = existingPartnerAccts[6].Id;
        existingOppPartners[0].Core_Partner_Type__c = 'LOEM';
        existingOppPartners[1].Core_Partner__c = existingPartnerAccts[5].Id;
        existingOppPartners[1].Core_Partner_Type__c = 'LOEM';
        existingOppPartners[2].Core_Partner__c = existingPartnerAccts[4].Id;
        existingOppPartners[3].Core_Partner__c = existingPartnerAccts[3].Id;
        existingOppPartners[4].Core_Partner__c = existingPartnerAccts[2].Id;
        existingOppPartners[5].Core_Partner__c = existingPartnerAccts[1].Id;
        existingOppPartners[6].Core_Partner__c = existingPartnerAccts[0].Id;
        existingOppPartners[6].Core_Partner_Type__c = 'LOEM';
        
        Test.startTest();
        update existingOppPartners;
        Test.stopTest();
        
        List<Core_Opportunity_Facts__c> oppFacts = [select Id, Core_Opportunity_ID__c, Core_LOEM__c,
                                                    Core_ODM__c, Core_OEM__c, Core_Reseller__c from Core_Opportunity_Facts__c
                                                    where Core_Opportunity_ID__c = :opps[0].Id];
        
        System.assertEquals(existingPartnerNames[6] + ';' + existingPartnerNames[5] + ';', oppFacts[0].Core_LOEM__c);
        System.assertEquals(null, oppFacts[0].Core_ODM__c);
        System.assertEquals(existingPartnerNames[4] + ';', oppFacts[0].Core_OEM__c);
        System.assertEquals(null, oppFacts[0].Core_Reseller__c);
        
        oppFacts = [select Id, Core_Opportunity_ID__c, Core_LOEM__c, Core_ODM__c, Core_OEM__c, Core_Reseller__c
                    from Core_Opportunity_Facts__c where Core_Opportunity_ID__c = :opps[1].Id];
        
        System.assertEquals(existingPartnerNames[0] + ';', oppFacts[0].Core_LOEM__c);
        System.assertEquals(null, oppFacts[0].Core_ODM__c);
        System.assertEquals(existingPartnerNames[3] + ';', oppFacts[0].Core_OEM__c);
        System.assertEquals(existingPartnerNames[2] + ';' + existingPartnerNames[1] + ';', oppFacts[0].Core_Reseller__c);
        
    }
    
    static testMethod void testDelete() {
        
        // Get the test data that's already set up
        List<Opportunity> opps = [select Id from Opportunity where Name like 'Test Opportunity %' order by Name];
        List<Core_Opportunity_Partner__c> existingOppPartners =
            [select Id, Core_Partner__r.Name from Core_Opportunity_Partner__c
             where Core_Partner__r.Name like 'Existing Partner %' order by Name];
        
        // DELETE TEST
        List<Core_Opportunity_Partner__c> oppPartnersToDelete = new List<Core_Opportunity_Partner__c>();
        oppPartnersToDelete.add(existingOppPartners[1]);
        oppPartnersToDelete.add(existingOppPartners[3]);
        oppPartnersToDelete.add(existingOppPartners[4]);
        oppPartnersToDelete.add(existingOppPartners[6]);
        
        Test.startTest();
        delete oppPartnersToDelete;
        Test.stopTest();
        
        List<Core_Opportunity_Facts__c> oppFacts = [select Id, Core_Opportunity_ID__c, Core_LOEM__c,
                                                    Core_ODM__c, Core_OEM__c, Core_Reseller__c from Core_Opportunity_Facts__c
                                                    where Core_Opportunity_ID__c = :opps[0].Id];
        
        System.assertEquals(existingPartnerNames[0] + ';', oppFacts[0].Core_ODM__c);
        System.assertEquals(existingPartnerNames[2] + ';', oppFacts[0].Core_OEM__c);
        
        oppFacts = [select Id, Core_Opportunity_ID__c, Core_LOEM__c, Core_ODM__c, Core_OEM__c, Core_Reseller__c
                    from Core_Opportunity_Facts__c where Core_Opportunity_ID__c = :opps[1].Id];
        
        System.assertEquals(null, oppFacts[0].Core_OEM__c);
        System.assertEquals(existingPartnerNames[5] + ';', oppFacts[0].Core_Reseller__c);
    }

    @testSetup
    static void setupTestData() {
        Id newAccountRecTypeId = [select Id from RecordType where DeveloperName = 'Mastered_Account' and sobjecttype = 'Account' limit 1][0].Id;
        // Account & partner account test data
        Account acct = new Account(Name = 'Test Account', BillingStreet = '123 Fake St',
                                   BillingCity = 'Springfield', BillingState = 'IL', BillingCountry = 'USA',Industry='Agriculture',Core_Sub_Industry__c= 'Crop Production',
                                   BillingPostalCode = '12345', RecordTypeId =  newAccountRecTypeId,
                                   //Core_CIM_ID__c = '8675309',
                                   Core_Sales_Groups__c='Americas US Sales Group');
        insert acct;
        
        List<Account> existingPartnerAccts = new List<Account>();
        for (Integer i=0; i < numExistingPartners; i++)
            existingPartnerAccts.add(new Account(Name=existingPartnerNames[i], BillingStreet = '123 Fake St',
                                   BillingCity = 'Springfield', BillingState = 'IL', BillingCountry = 'USA',Industry='Agriculture',Core_Sub_Industry__c= 'Crop Production',
                                   BillingPostalCode = '12345', RecordTypeId =  newAccountRecTypeId,
                                  // Core_CIM_ID__c = '8675309',
                                   Core_Sales_Groups__c='Americas US Sales Group'));
        insert existingPartnerAccts;
        
        List<Account> newPartnerAccts = new List<Account>();
        for (Integer i=0; i < numNewPartners; i++)
            newPartnerAccts.add(new Account(Name=newPartnerNames[i], BillingStreet = '123 Fake St',
                                   BillingCity = 'Springfield', BillingState = 'IL', BillingCountry = 'USA',Industry='Agriculture',Core_Sub_Industry__c= 'Crop Production',
                                   BillingPostalCode = '12345', RecordTypeId =  newAccountRecTypeId,
                                   //Core_CIM_ID__c = '8675309',
                                   Core_Sales_Groups__c='Americas US Sales Group'));
        insert newPartnerAccts;
        
        // Existing Opportunity Facts data
        List<Core_Opportunity_Facts__c> oppFacts = new List<Core_Opportunity_Facts__c>();
        oppFacts.add(new Core_Opportunity_Facts__c(Core_LOEM__c=null, Core_ODM__c=existingPartnerNames[0] + ';',
                                                   Core_OEM__c=existingPartnerNames[1] + ';' + existingPartnerNames[2] + ';', Core_Reseller__c=null));
        oppFacts.add(new Core_Opportunity_Facts__c(Core_LOEM__c=null, Core_ODM__c=null,
                                                   Core_OEM__c=existingPartnerNames[3] + ';', Core_Reseller__c=existingPartnerNames[4] + ';' +
                                                   existingPartnerNames[5] + ';' + existingPartnerNames[6] + ';'));
        insert oppFacts;
        
        // Opportunity test data
        List<Opportunity> opps = new List<Opportunity>();
          Id newOppRecTypeId = [select Id from RecordType where DeveloperName = 'Core_New_Opportunity' limit 1][0].Id;
        for (Integer i=0; i < 2; i++)
            opps.add(new Opportunity(Name='Test Opportunity '+i, RecordTypeId = newOppRecTypeId, AccountId=acct.Id, StageName='Develop', CloseDate=System.Today().addDays(24),
                                     Core_Opportunity_Facts_ID__c=oppFacts[i].Id));
        for (Integer i=2; i < numOpportunities; i++)
            opps.add(new Opportunity(Name='Test Opportunity '+i, RecordTypeId = newOppRecTypeId, AccountId=acct.Id, StageName='Develop', CloseDate=System.Today().addDays(24),
                                     Core_Opportunity_Facts_ID__c=null));
        insert opps;
        
        // Now that we have opportunities, update the Opportunity Facts records with their IDs
        oppFacts[0].Core_Opportunity_ID__c = (String) opps[0].Id;
        oppFacts[1].Core_Opportunity_ID__c = (String) opps[1].Id;
        update oppFacts;
        
        // Add our existing partners into the system
        List<Core_Opportunity_Partner__c> existingOppPartners = new List<Core_Opportunity_Partner__c>();
        existingOppPartners.add(new Core_Opportunity_Partner__c(Core_Opportunity__c=opps[0].Id, Core_Partner__c=existingPartnerAccts[0].Id,
                                                                Core_Partner_Type__c='ODM', Core_Partner_Role__c='testing'));
        existingOppPartners.add(new Core_Opportunity_Partner__c(Core_Opportunity__c=opps[0].Id, Core_Partner__c=existingPartnerAccts[1].Id,
                                                                Core_Partner_Type__c='OEM', Core_Partner_Role__c='testing'));
        existingOppPartners.add(new Core_Opportunity_Partner__c(Core_Opportunity__c=opps[0].Id, Core_Partner__c=existingPartnerAccts[2].Id,
                                                                Core_Partner_Type__c='OEM', Core_Partner_Role__c='testing'));
        existingOppPartners.add(new Core_Opportunity_Partner__c(Core_Opportunity__c=opps[1].Id, Core_Partner__c=existingPartnerAccts[3].Id,
                                                                Core_Partner_Type__c='OEM', Core_Partner_Role__c='testing'));
        existingOppPartners.add(new Core_Opportunity_Partner__c(Core_Opportunity__c=opps[1].Id, Core_Partner__c=existingPartnerAccts[4].Id,
                                                                Core_Partner_Type__c='Reseller', Core_Partner_Role__c='testing'));
        existingOppPartners.add(new Core_Opportunity_Partner__c(Core_Opportunity__c=opps[1].Id, Core_Partner__c=existingPartnerAccts[5].Id,
                                                                Core_Partner_Type__c='Reseller', Core_Partner_Role__c='testing'));
        existingOppPartners.add(new Core_Opportunity_Partner__c(Core_Opportunity__c=opps[1].Id, Core_Partner__c=existingPartnerAccts[6].Id,
                                                                Core_Partner_Type__c='Reseller', Core_Partner_Role__c='testing'));
        insert existingOppPartners;
        
        // Now enable the actual Trigger execution
        Core_Trigger_Executions__c triggerExec = new Core_Trigger_Executions__c(
            Name='opportunityPartnerFactsUpdate', Core_Class_Name__c='Core_OpportunityPartnerHandler', Core_Object__c='Core_Opportunity_Partner__c',
            Core_Trigger_Events__c='after insert, after update, after delete', Core_Active__c=true, Core_Description__c = 'blah blah');
        insert triggerExec;
        Core_Trigger_Executions__c triggerExec1 = new Core_Trigger_Executions__c(
            Name='OppPartnerJSON', Core_Class_Name__c='Core_OpportunityPartnerHandler', Core_Object__c='Core_Opportunity_Partner__c',
            Core_Trigger_Events__c='after insert, after update, after delete', Core_Active__c=true, Core_Description__c = 'blah blah');
        insert triggerExec1;
        
        Core_OpportunityPartnerHandler.createOppPartnerJSONInsert(existingOppPartners);
    }
    
    static testMethod void checkPCCOpptyLock_test(){
        Id newAccountRecTypeId = [select Id from RecordType where DeveloperName = 'Mastered_Account' and sobjecttype = 'Account' limit 1][0].Id;
        // Account & partner account test data
		Account acct = new Account(Name = 'Test Account1', Industry = 'Agriculture', Core_Sub_Industry__c = 'Forestry', RecordTypeId = newAccountRecTypeId,
                                   BillingStreet = '123 Fake St',BillingCity = 'Springfield', BillingState = 'IL', BillingCountry = 'USA',
                                   BillingPostalCode = '12345', Core_Sales_Groups__c='PRC Sales Group');
            insert acct;
        
        List<Account> existingPartnerAccts = new List<Account>();
        for (Integer i=0; i < 7; i++)
            existingPartnerAccts.add(new Account(Name=existingPartnerNew[i], BillingStreet = '123 Fake St',
                                   BillingCity = 'Springfield', BillingState = 'IL', BillingCountry = 'USA',Industry='Agriculture',Core_Sub_Industry__c= 'Crop Production',
                                   BillingPostalCode = '12345', RecordTypeId = newAccountRecTypeId,
                                  // Core_CIM_ID__c = '8675309',
                                   Core_Sales_Groups__c='PRC Sales Group'));
        insert existingPartnerAccts;
        
        // Existing Opportunity Facts data
        List<Core_Opportunity_Facts__c> oppFacts = new List<Core_Opportunity_Facts__c>();
        oppFacts.add(new Core_Opportunity_Facts__c(Core_LOEM__c=null, Core_ODM__c=existingPartnerNew[0] + ';',
                                                   Core_OEM__c=existingPartnerNew[1] + ';' + existingPartnerNew[2] + ';', Core_Reseller__c=null));
        oppFacts.add(new Core_Opportunity_Facts__c(Core_LOEM__c=null, Core_ODM__c=null,
                                                   Core_OEM__c=existingPartnerNew[3] + ';', Core_Reseller__c=existingPartnerNew[4] + ';' +
                                                   existingPartnerNew[5] + ';' + existingPartnerNew[6] + ';'));
        insert oppFacts;
        
        // Opportunity test data
        List<Opportunity> opps = new List<Opportunity>();
		
		Id DealOppRecTypeId = [select Id from RecordType where DeveloperName = 'Core_Deal_Opportunity' limit 1][0].Id;

        for (Integer i=0; i < 2; i++)
            opps.add(new Opportunity(Name = 'PCC Opportunity'+i, RecordTypeId = DealOppRecTypeId,
                                          AccountId = acct.Id, OwnerId= UserInfo.getUserId(),Core_Coverage_Type_Nm__c = 'Deal Registration',
                                          StageName = 'Qualify', CloseDate = System.Date.today().addYears(1), Core_Opportunity_Coverage_Nm__c ='Partner-Led Opportunity',
                                     Core_Opportunity_Facts_ID__c=oppFacts[i].Id));
        for (Integer i=2; i < 5; i++)
            opps.add(new Opportunity(Name = 'PCC Opportunity'+i, RecordTypeId = DealOppRecTypeId,
                                          AccountId = acct.Id, OwnerId= UserInfo.getUserId(),Core_Coverage_Type_Nm__c = 'Deal Registration',
                                          StageName = 'Qualify', CloseDate = System.Date.today().addYears(1), Core_Opportunity_Coverage_Nm__c ='Partner-Led Opportunity',
                                     Core_Opportunity_Facts_ID__c=null));
        insert opps;
        
        // Now that we have opportunities, update the Opportunity Facts records with their IDs
        oppFacts[0].Core_Opportunity_ID__c = (String) opps[0].Id;
        oppFacts[1].Core_Opportunity_ID__c = (String) opps[1].Id;
        update oppFacts;
        
        // Add our existing partners into the system
        List<Core_Opportunity_Partner__c> existingOppPartners = new List<Core_Opportunity_Partner__c>();
        existingOppPartners.add(new Core_Opportunity_Partner__c(Core_Opportunity__c=opps[0].Id, Core_Partner__c=existingPartnerAccts[0].Id,
                                                                Core_Partner_Type__c='ODM', Core_Partner_Role__c='testing'));
        existingOppPartners.add(new Core_Opportunity_Partner__c(Core_Opportunity__c=opps[0].Id, Core_Partner__c=existingPartnerAccts[1].Id,
                                                                Core_Partner_Type__c='OEM', Core_Partner_Role__c='testing'));
        existingOppPartners.add(new Core_Opportunity_Partner__c(Core_Opportunity__c=opps[0].Id, Core_Partner__c=existingPartnerAccts[2].Id,
                                                                Core_Partner_Type__c='OEM', Core_Partner_Role__c='testing'));
        existingOppPartners.add(new Core_Opportunity_Partner__c(Core_Opportunity__c=opps[1].Id, Core_Partner__c=existingPartnerAccts[3].Id,
                                                                Core_Partner_Type__c='OEM', Core_Partner_Role__c='testing'));
        existingOppPartners.add(new Core_Opportunity_Partner__c(Core_Opportunity__c=opps[1].Id, Core_Partner__c=existingPartnerAccts[4].Id,
                                                                Core_Partner_Type__c='Reseller', Core_Partner_Role__c='testing'));
        existingOppPartners.add(new Core_Opportunity_Partner__c(Core_Opportunity__c=opps[1].Id, Core_Partner__c=existingPartnerAccts[5].Id,
                                                                Core_Partner_Type__c='Reseller', Core_Partner_Role__c='testing'));
        existingOppPartners.add(new Core_Opportunity_Partner__c(Core_Opportunity__c=opps[1].Id, Core_Partner__c=existingPartnerAccts[6].Id,
                                                                Core_Partner_Type__c='Reseller', Core_Partner_Role__c='testing'));
        insert existingOppPartners;
        
        // Now enable the actual Trigger execution
        Core_Trigger_Executions__c triggerEntry = new Core_Trigger_Executions__c(Name='lockPCCOpportunity', Core_Object__c='Opportunity',
					Core_Class_Name__c='Core_OpportunityLineItemHandler',Core_Trigger_Events__c='before update, before insert', 
                    Core_Active__c=true, Core_Description__c='for PCC Lock');
        	insert triggerEntry;
        
        Core_OpportunityPartnerHandler.checkPCCOpptyLock(existingOppPartners);
    }
    
    
}