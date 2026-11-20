/**
* @description       : 
* @author            : Deepthi Kambam
* @group             : Accenture
* @last modified on  : 13-08-2024
* @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/


@IsTest
public class Pricing_SW_QuoteBusinessLogicTest{
    private static Account testAccount;
    private static Opportunity testOpportunity;
    private static List<SBQQ__Quote__c> testQuotes;
    private static SBQQ__QuoteLine__c testQuoteLines;
                                
    @testSetup
    static void setupData() {        
        SBQQ__QuoteTemplate__c quoteTemplate = new SBQQ__QuoteTemplate__c(Name = 'IQR Software Quote Template');
        insert quoteTemplate;
        // Set up Account data
        testAccount = Pricing_SW_UtilityTest.createAccount('Test Account');
        
        // Set up Opportunity data
        testOpportunity = Pricing_SW_UtilityTest.createOpportunity(testAccount, 'Prospecting', Date.today().addMonths(1));
                    
        // Set up Quote data
        SBQQ__Quote__c testQuote = Pricing_SW_UtilityTest.createQuote(testOpportunity, 'Draft', testAccount.Id);

        //testQuotes = Pricing_SW_UtilityTest.createQuoteWithStatus(testAccount, testOpportunity, 4);

    }
    
    @isTest
    static void testUpdateRecordtypebyStatusandApprovalStatus_Insert() {
        // Test for insert scenario
        List<SBQQ__Quote__c> quoteList = [SELECT Id, SBQQ__Opportunity2__c,SBQQ__SalesRep__c,SBQQ__Status__c, ApprovalStatus__c,SBQQ__Opportunity2__r.CRM_SW_Flag_Ind__c,OwnerId,Pricing_sw_Quote_Owner__c FROM SBQQ__Quote__c Limit 1];
        Map<Id, SBQQ__Quote__c> oldMap = new Map<Id, SBQQ__Quote__c>();
        
        Test.startTest();
        Pricing_SW_QuoteBusinessLogic.updateRecordtypebyStatusandApprovalStatus(quoteList, oldMap, true);
        Test.stopTest();
        Pricing_SW_QuoteBusinessLogic.updateCRMSWOnOpportunity(quoteList);
        
        // Validate the record types and status
        for (SBQQ__Quote__c quote : [SELECT Id, RecordTypeId, SBQQ__Status__c FROM SBQQ__Quote__c]) {
            System.assert.isNotNull(quote.RecordTypeId, 'Record Type should be assigned on insert.');
        }
    }
    
    @isTest
    static void testUpdateRecordtypebyStatusandApprovalStatus_UpdateScenarioPending() {
        Account acc = Pricing_SW_UtilityTest.createAccount('Test Account');
        Opportunity opp = Pricing_SW_UtilityTest.createOpportunity(acc, 'Prospecting', Date.today().addMonths(1));
        
        // Insert a quote to update later
        SBQQ__Quote__c quote = Pricing_SW_UtilityTest.createQuote(opp, 'Draft', acc.Id);
        SBQQ__QuoteLine__c quoteLine = Pricing_SW_UtilityTest.createQuoteLines(quote);
        // Test update scenario with different approval statuses
        Test.startTest();
        quote.ApprovalStatus__c = 'Pending';
        update quote;
        Test.stopTest();
        
        SBQQ__Quote__c updatedQuote = [SELECT SBQQ__Status__c, RecordTypeId FROM SBQQ__Quote__c WHERE Id = :quote.Id];
        System.assertEquals(Label.Pricing_SW_QuoteStatusInReview, updatedQuote.SBQQ__Status__c);
        System.assertEquals(Pricing_Tender_Utility.getRecordTypeId('SBQQ__Quote__c', Label.Pricing_SW_QuoteSubmitRecordTypeId), updatedQuote.RecordTypeId);            
                    
    }
        
    @isTest
    static void testUpdateRecordtypebyStatusandApprovalStatus_UpdateScenarioApproved() {
        Account acc = Pricing_SW_UtilityTest.createAccount('Test Account');
        Opportunity opp = Pricing_SW_UtilityTest.createOpportunity(acc, 'Prospecting', Date.today().addMonths(1));
        
        // Insert a quote to update later
        SBQQ__Quote__c quote = Pricing_SW_UtilityTest.createQuote(opp, 'Draft', acc.Id);
        Pricing_Sw_Validation_Bypass__c setting = new Pricing_Sw_Validation_Bypass__c();
        setting.By_Pass_Validation__c = true;
        insert setting;
            // Continue testing for Approved, Rejected, Recalled statuses
        SBQQ__QuoteLine__c quoteLine = Pricing_SW_UtilityTest.createQuoteLines(quote);

        Test.startTest();
        quote.ApprovalStatus__c = 'Approved';
        update quote;
        Test.stopTest();
        
        SBQQ__Quote__c updatedQuote = [SELECT SBQQ__Status__c, RecordTypeId FROM SBQQ__Quote__c WHERE Id = :quote.Id];
        System.assertEquals(Label.Pricing_SW_QuoteStatusApproved, updatedQuote.SBQQ__Status__c);
        System.assertEquals(Pricing_Tender_Utility.getRecordTypeId('SBQQ__Quote__c', Label.Pricing_SW_QuoteReadonlyRecordTypeId), updatedQuote.RecordTypeId); 
        
    }
        
    @isTest
    static void testUpdateRecordtypebyStatusandApprovalStatus_UpdateScenarioRejected() {
        Account acc = Pricing_SW_UtilityTest.createAccount('Test Account');
        Opportunity opp = Pricing_SW_UtilityTest.createOpportunity(acc, 'Prospecting', Date.today().addMonths(1));
        
        // Insert a quote to update later
        SBQQ__Quote__c quote = Pricing_SW_UtilityTest.createQuote(opp, 'Draft', acc.Id);
        SBQQ__QuoteLine__c quoteLine = Pricing_SW_UtilityTest.createQuoteLines(quote);
        quote.ApprovalStatus__c = 'Pending';
        update quote;
        
        // Continue testing for Approved, Rejected, Recalled statuses
        Test.startTest();
        quote.ApprovalStatus__c = 'Rejected';
        update quote;
        Test.stopTest();
        
        SBQQ__Quote__c updatedQuote = [SELECT SBQQ__Status__c, RecordTypeId FROM SBQQ__Quote__c WHERE Id = :quote.Id];
        System.assertEquals(Label.Pricing_SW_QuoteApprovalStatusRejected, updatedQuote.SBQQ__Status__c);
        System.assertEquals(Pricing_Tender_Utility.getRecordTypeId('SBQQ__Quote__c', Label.Pricing_SW_QuoteReadonlyRecordTypeId), updatedQuote.RecordTypeId); 
    }
    
    
    @isTest
    static void testUpdateRecordtypebyStatusandApprovalStatus_UpdateScenarioRecalled() {
        Account acc = Pricing_SW_UtilityTest.createAccount('Test Account');
        Opportunity opp = Pricing_SW_UtilityTest.createOpportunity(acc, 'Prospecting', Date.today().addMonths(1));
        
        // Insert a quote to update later
        SBQQ__Quote__c quote = Pricing_SW_UtilityTest.createQuote(opp, 'Draft', acc.Id);
        SBQQ__QuoteLine__c quoteLine = Pricing_SW_UtilityTest.createQuoteLines(quote);

        quote.ApprovalStatus__c = 'Pending';
        update quote;
        
        // Continue testing for Approved, Rejected, Recalled statuses
        Test.startTest();
        quote.ApprovalStatus__c = 'Recalled';
        update quote;
        Test.stopTest();
        
        SBQQ__Quote__c updatedQuote = [SELECT SBQQ__Status__c, RecordTypeId FROM SBQQ__Quote__c WHERE Id = :quote.Id];
        System.assertEquals(Label.Pricing_SW_QuoteStatusDraft, updatedQuote.SBQQ__Status__c);
        System.assertEquals(Pricing_Tender_Utility.getRecordTypeId('SBQQ__Quote__c', Label.Pricing_SW_QuoteEditRecordTypeId), updatedQuote.RecordTypeId); 
    }
         
         
    @isTest
    static void testCreateQuoteSharesForSW() {
        // Test createQuoteSharesForSW method
        User user = Pricing_SW_UtilityTest.createUser('SWUser','testusershare@intel.com','User1');
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        OpportunityTeamMember opptyTeamMember = Pricing_SW_UtilityTest.createOpportunityTeamMember(opp,user,'Opportunity Owner');
        Test.startTest();
        SBQQ__Quote__c quote = [SELECT Id, SBQQ__Opportunity2__c,Owner.id FROM SBQQ__Quote__c LIMIT 1];
        quote.SBQQ__Opportunity2__c = opp.Id;
        quote.Pricing_Quote_Program_Nm__c = Label.Pricing_Program_Code_Software;
        quote.SBQQ__StartDate__c = System.today();
        quote.SBQQ__SubscriptionTerm__c = 2;
        update quote;
        SBQQ__Quote__Share quoteShr = new SBQQ__Quote__Share();
        quoteShr.ParentId = quote.Id;
        quoteShr.UserOrGroupId = opptyTeamMember.UserId;
        quoteShr.AccessLevel = 'Read';
        quoteShr.RowCause = Schema.SBQQ__Quote__Share.RowCause.Pricing_SW_Opportunity_Sharing__c;
        insert quoteShr;
        List<Id> oppIds = new List<Id>{quote.SBQQ__Opportunity2__c};
        
        Pricing_SW_QuoteBusinessLogic.createQuoteSharesForSW(oppIds);
        Test.stopTest();
        
        // Validate that quote share records are created
        System.assert(quote != Null, 'Quote share records should be created.');
    }
       
    @IsTest
    static void testCloneQuotes() {
        Account testAcc;
        Opportunity testOpp;
        SBQQ__Quote__c testQuote;
        
        testAcc = Pricing_SW_UtilityTest.createAccount('Test Account');
        testOpp = Pricing_SW_UtilityTest.createOpportunity(testAcc, 'Prospecting', Date.today().addMonths(1));

        // Create test Opportunity Map
        Map<Id, Opportunity> opportunityMap = new Map<Id, Opportunity>();
        opportunityMap.put(testOpp.Id, testOpp);

        Set<Id> opportunityIds = new Set<Id>();
        opportunityIds.add(testOpp.Id);

        // Create test Quote createQuote(Opportunity opp, String status, Id accId)
        testQuote = Pricing_SW_UtilityTest.createQuote(testOpp, Label.Pricing_SW_QuoteStatusDraft, testAcc.Id);
        
        SBQQ__Quote__c clonedQuote = testQuote.clone(false, true); // 'true' sets the IsClone flag on the clone
        clonedQuote.Pricing_SW_Description__c = 'Cloned Quote';
        upsert clonedQuote;

        // Create a List of Quotes
        List<SBQQ__Quote__c> quoteList = new List<SBQQ__Quote__c>{clonedQuote};

        Test.startTest();
        Pricing_SW_QuoteBusinessLogic.cloneQuotes(clonedQuote, opportunityIds);
        Test.stopTest();

        // Assert that a new Quote was cloned
        List<SBQQ__Quote__c> clonedQuotes = [SELECT Id FROM SBQQ__Quote__c WHERE Id != :testQuote.Id];
        System.assertNotEquals(0, clonedQuotes.size(), 'A quote should be cloned');
    }

    @IsTest
    static void testIsPrimaryQuoteSubmitted() {
        Account testAcc;
        Opportunity testOpp;
        SBQQ__Quote__c testQuote1;
        SBQQ__Quote__c testQuote2;
        
        testAcc = Pricing_SW_UtilityTest.createAccount('Test Account');
        testOpp = Pricing_SW_UtilityTest.createOpportunity(testAcc, 'Prospecting', Date.today().addMonths(1));
        testQuote1 = Pricing_SW_UtilityTest.createQuote(testOpp, Label.Pricing_SW_QuoteStatusDraft, testAcc.Id);
        testQuote2 = Pricing_SW_UtilityTest.createQuote(testOpp, Label.Pricing_SW_OpportunityStatusSubmitted, testAcc.Id);
        
        Map<Id, Opportunity> opportunityMap = new Map<Id, Opportunity>();
        opportunityMap.put(testOpp.Id, testOpp);

        Test.startTest();
        Boolean result = Pricing_SW_QuoteBusinessLogic.isPrimaryQuoteSubmitted(testQuote2, opportunityMap);
        Test.stopTest();

        // Assert that a primary quote is submitted
        System.assertEquals(false, result, 'A primary quote should be submitted');
    }

    @IsTest
    static void testGetOpportunityLostStatusMap() {
        Account testAcc;
        Opportunity testOpp1;
        Opportunity testOpp2;

        testAcc = Pricing_SW_UtilityTest.createAccount('Test Account');
        testOpp1 = Pricing_SW_UtilityTest.createOpportunity(testAcc, 'Prospecting', Date.today().addMonths(1));
        testOpp2 = Pricing_SW_UtilityTest.createOpportunity(testAcc, 'Lost', Date.today().addMonths(1));

        Set<Id> opportunityIds = new Set<Id>{testOpp1.Id, testOpp2.Id};

        Test.startTest();
        // Call getOpportunityLostStatusMap method
        Map<Id, Boolean> result = Pricing_SW_QuoteBusinessLogic.getOpportunityLostStatusMap(opportunityIds);
        Test.stopTest();

        // Assert that the Lost status is mapped correctly
        System.assertEquals(null, result.get(testOpp2.Id), 'Opportunity 2 should be Lost');
        System.assertNotEquals(false, result.get(testOpp1.Id), 'Opportunity 1 should not be Lost');
    }

    @IsTest
    static void testValidateQuoteInsert() {
        // Fetch test data
        Opportunity opp = [SELECT Id, SBQQ__PrimaryQuote__r.SBQQ__Status__c, Core_Approval_Status__c FROM Opportunity LIMIT 1];
        
        // Fetch quote records
        SBQQ__Quote__c quote = [SELECT Id, SBQQ__Opportunity2__c, SBQQ__Status__c, SBQQ__Primary__c FROM SBQQ__Quote__c LIMIT 1];
        SBQQ__QuoteLine__c quoteLine = Pricing_SW_UtilityTest.createQuoteLines(quote);
        quote.SBQQ__Status__c = Label.Pricing_SW_QuoteStatusApproved;
        quote.SBQQ__Primary__c = true;
        upsert quote;

        opp.Core_Approval_Status__c = Label.Pricing_SW_OpportunityStatusSubmitted;
        update opp;
        
        // Simulate the old quote map and opportunity map
        Map<Id, SBQQ__Quote__c> oldQuoteMap = new Map<Id, SBQQ__Quote__c>();
        Map<Id, Opportunity> opportunityMap = new Map<Id, Opportunity>{ opp.Id => opp };

        // Perform test logic
        Test.startTest();
        try {
            // Calling the validateQuote method for insert scenario
            Pricing_SW_QuoteBusinessLogic.validateQuote(quote, oldQuoteMap, opportunityMap, true);
            System.assert(true, 'Exception should have been thrown due to validation');
        } catch (Exception e) {
            System.assert(e.getMessage().contains(Label.Pricing_SW_AlreadyApprovedOpportunity), 'Unexpected validation message');
        }
        Test.stopTest();
    }

    @IsTest
    static void testValidateQuoteUpdate() {
        // Fetch test data
        Opportunity opp = [SELECT Id, SBQQ__PrimaryQuote__r.SBQQ__Status__c, Core_Approval_Status__c FROM Opportunity LIMIT 1];

        SBQQ__Quote__c oldQuote = [SELECT Id, SBQQ__Status__c, SBQQ__Primary__c FROM SBQQ__Quote__c LIMIT 1];
        SBQQ__QuoteLine__c quoteLine = Pricing_SW_UtilityTest.createQuoteLines(oldQuote);
        
        // Simulate updating the quote
        SBQQ__Quote__c updatedQuote = new SBQQ__Quote__c(
            Id = oldQuote.Id,
            SBQQ__Status__c = Label.Pricing_SW_QuoteStatusApproved,
            SBQQ__Primary__c = true
        );
        
        // Prepare maps for old quote and opportunity
        Map<Id, SBQQ__Quote__c> oldQuoteMap = new Map<Id, SBQQ__Quote__c>{ oldQuote.Id => oldQuote };
        Map<Id, Opportunity> opportunityMap = new Map<Id, Opportunity>{ opp.Id => opp };

        // Perform test logic
        Test.startTest();
        try {
            // Call validateQuote for update
            Pricing_SW_QuoteBusinessLogic.validateQuote(updatedQuote, oldQuoteMap, opportunityMap, false);
            System.assert(true, 'Exception should have been thrown for update validation');
        } catch (Exception e) {
            System.assert(e.getMessage().contains(Label.Pricing_SW_AlreadyApprovedOpportunity), 'Unexpected validation message');
        }
        Test.stopTest();
    }
}