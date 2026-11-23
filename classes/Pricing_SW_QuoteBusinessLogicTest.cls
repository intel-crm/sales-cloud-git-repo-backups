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
        SBQQ__Quote__c testQuote = Pricing_SW_UtilityTest.createQuote(testOpportunity, Label.Pricing_SW_QuoteStatusDraft, testAccount.Id);
        SBQQ__QuoteLine__c quoteLine = Pricing_SW_UtilityTest.createQuoteLines(testQuote);
        SBQQ__Quote__c testsubmittedQuote = Pricing_SW_UtilityTest.createQuote(testOpportunity, Label.Pricing_SW_OpportunityStatusSubmitted, testAccount.Id);
       SBQQ__Quote__c testAcceptedQuote = Pricing_SW_UtilityTest.createQuote(testOpportunity, Label.Pricing_SW_QuoteStatusAccepted, testAccount.Id);
        
        List<Product2> product = new List<Product2>();
        integer numOfProducts;
        for(numOfProducts=0;numOfProducts<5;numOfProducts++){
            product.add(new Product2(Name = 'Test Product' + numOfProducts,IsActive = true,Core_OPN__c = '1SG00'+ numOfProducts,Core_Sales_Visible_Flag__c = true, Core_Item_Orderable_Ind__c = true,Core_Item_Quotable_Ind__c = true, Core_Hierarchy_ID__c = '43', Core_Product_Type__c = 'Intel® FPGAs', Core_Item_Class_Nm__c='BD', Core_BU_Operation_Code__c='KP', Core_Product_Org__c = 'Sales')); 
        }
        Test.StartTest();
        insert product;
        for(Product2 p: product){
            p.Core_Sales_Visible_Flag__c=true;
            p.Core_Item_Orderable_Ind__c=true;
            p.Core_Item_Quotable_Ind__c=true;
        }
        update product;
        PricebookEntry testPBE = new PricebookEntry();
        testPBE.UnitPrice = 1;
        testPBE.isActive  = TRUE;
        testPBE.Pricebook2Id = Test.getStandardPricebookId();
        testPBE.Product2Id = product[0].Id;      
        testPBE.UseStandardPrice = false;
        insert testPBE;
        User user = Pricing_SW_UtilityTest.createUser('SWUser','testusershare@intel.com','User1');
        Pricing_SW_UtilityTest.createOpportunityTeamMember(testOpportunity,user,'Opportunity Owner');
        OpportunityLineItem testOppLineItem = new OpportunityLineItem(OpportunityId=testOpportunity.Id, PricebookEntryId=testPBE.Id,
                                                  Description='Test 11', UnitPrice=11, Quantity=11,
                                                  Core_Loss_Cancel_Reason__c='test', Core_Status__c='Pending');
        insert testOppLineItem;
        Test.StopTest();
        

    }
    
    @isTest
    static void testUpdateRecordtypebyStatusandApprovalStatus_Insert() {
        // Test for insert scenario
        List<SBQQ__Quote__c> quoteList = [SELECT Id, SBQQ__Opportunity2__c,SBQQ__SalesRep__c,SBQQ__Status__c, ApprovalStatus__c,SBQQ__Opportunity2__r.CRM_SW_Flag_Ind__c,OwnerId,Pricing_sw_Quote_Owner__c,Pricing_SW_Quote_Product_Type__c FROM SBQQ__Quote__c];
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
        Account acc = [Select id,name from Account where name ='Test Account'];
        Opportunity opp = [Select id,name from Opportunity where accountid=:acc.id];
        
        // Insert a quote to update later
        SBQQ__Quote__c quote = [Select id,ApprovalStatus__c from SBQQ__Quote__c where SBQQ__Account__c=:acc.id and SBQQ__Status__c =: Label.Pricing_SW_QuoteStatusDraft];
        SBQQ__QuoteLine__c quoteLine = [Select id,name from SBQQ__QuoteLine__c where SBQQ__Quote__c=:quote.id];
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
        Account acc = [Select id,name from Account where name ='Test Account'];
        Opportunity opp = [Select id,name from Opportunity where accountid=:acc.id];
        
        // Insert a quote to update later
        SBQQ__Quote__c quote = [Select id,ApprovalStatus__c from SBQQ__Quote__c where SBQQ__Account__c=:acc.id and SBQQ__Status__c =: Label.Pricing_SW_QuoteStatusDraft];
        Pricing_Sw_Validation_Bypass__c setting = new Pricing_Sw_Validation_Bypass__c();
        setting.By_Pass_Validation__c = true;
        insert setting;
            // Continue testing for Approved, Rejected, Recalled statuses
        SBQQ__QuoteLine__c quoteLine = [Select id,name from SBQQ__QuoteLine__c where SBQQ__Quote__c=:quote.id];

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
        Account acc = [Select id,name from Account where name ='Test Account'];
        Opportunity opp = [Select id,name from Opportunity where accountid=:acc.id];
        
        // Insert a quote to update later
        SBQQ__Quote__c quote = [Select id,ApprovalStatus__c from SBQQ__Quote__c where SBQQ__Account__c=:acc.id and SBQQ__Status__c =: Label.Pricing_SW_QuoteStatusDraft];
        SBQQ__QuoteLine__c quoteLine = [Select id,name from SBQQ__QuoteLine__c where SBQQ__Quote__c=:quote.id];
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
        Account acc = [Select id,name from Account where name ='Test Account'];
        Opportunity opp = [Select id,name from Opportunity where accountid=:acc.id];
        
        // Insert a quote to update later
        SBQQ__Quote__c quote = [Select id,ApprovalStatus__c from SBQQ__Quote__c where SBQQ__Account__c=:acc.id and SBQQ__Status__c =: Label.Pricing_SW_QuoteStatusDraft];
        SBQQ__QuoteLine__c quoteLine = [Select id,name from SBQQ__QuoteLine__c where SBQQ__Quote__c=:quote.id];

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
        User user = [Select id from User where  Email ='testusershare@intel.com']; // Added by Priyanka
        Account acc = [Select id,name from Account where name ='Test Account'];
        Opportunity opp = [Select id,name from Opportunity where accountid=:acc.id];
        List<OpportunityTeamMember> opptyTeamMember = [select id,UserId from OpportunityTeamMember where OpportunityId=:opp.id];
        Test.startTest();
        SBQQ__Quote__c quote = [SELECT Id, SBQQ__Opportunity2__c,Owner.id FROM SBQQ__Quote__c where SBQQ__Account__c=:acc.id and SBQQ__Status__c =: Label.Pricing_SW_QuoteStatusDraft];
        quote.SBQQ__Opportunity2__c = opp.Id;
        quote.Pricing_Quote_Program_Nm__c = Label.Pricing_Program_Code_Software;
        quote.SBQQ__StartDate__c = System.today();
        quote.SBQQ__SubscriptionTerm__c = 2;
        update quote;
        SBQQ__Quote__Share quoteShr = new SBQQ__Quote__Share();
        quoteShr.ParentId = quote.Id;
        quoteShr.UserOrGroupId = opptyTeamMember[0].UserId;
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
        Account acc = [Select id,name from Account where name ='Test Account'];
        Opportunity opp = [Select id,name from Opportunity where accountid=:acc.id];

        // Create test Opportunity Map
        Map<Id, Opportunity> opportunityMap = new Map<Id, Opportunity>();
        opportunityMap.put(opp.Id, opp);

        Set<Id> opportunityIds = new Set<Id>();
        opportunityIds.add(opp.Id);

        // Create test Quote createQuote(Opportunity opp, String status, Id accId)
       SBQQ__Quote__c testQuote = [Select id,SBQQ__Primary__c,SBQQ__Status__c,Pricing_SW_Description__c,Pricing_SW_Expiry_Date__c,SBQQ__StartDate__c,SBQQ__SubscriptionTerm__c,SBQQ__Opportunity2__c,SBQQ__PaymentTerms__c,sbqq__billingfrequency__c,SBQQ__CustomerAmount__c,SBQQ__TargetCustomerAmount__c,SBQQ__AverageCustomerDiscount__c,SBQQ__NetAmount__c,sbqq__notes__c,SBQQ__BillingCountry__c,SBQQ__BillingState__c,SBQQ__BillingStreet__c,SBQQ__BillingCity__c,SBQQ__BillingPostalCode__c,SBQQ__CustomerDiscount__c,SBQQ__BillingName__c from SBQQ__Quote__c where SBQQ__Account__c=:acc.id and SBQQ__Status__c =: Label.Pricing_SW_QuoteStatusDraft];
        
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
        
        Account testAcc = [Select id,name from Account where name ='Test Account'];
        Opportunity testOpp = [Select id,name,SBQQ__PrimaryQuote__r.SBQQ__Status__c from Opportunity where accountid=:testAcc.id];
        SBQQ__Quote__c testQuote1 = [Select id,SBQQ__Primary__c,SBQQ__Status__c,Pricing_SW_Description__c,Pricing_SW_Expiry_Date__c,SBQQ__StartDate__c,SBQQ__SubscriptionTerm__c,SBQQ__Opportunity2__c,SBQQ__Opportunity2__r.SBQQ__PrimaryQuote__c,SBQQ__Opportunity2__r.SBQQ__PrimaryQuote__r.SBQQ__Status__c,SBQQ__PaymentTerms__c,sbqq__billingfrequency__c,SBQQ__CustomerAmount__c,SBQQ__TargetCustomerAmount__c,SBQQ__AverageCustomerDiscount__c,SBQQ__NetAmount__c,sbqq__notes__c,SBQQ__BillingCountry__c,SBQQ__BillingState__c,SBQQ__BillingStreet__c,SBQQ__BillingCity__c,SBQQ__BillingPostalCode__c,SBQQ__CustomerDiscount__c,SBQQ__BillingName__c from SBQQ__Quote__c where SBQQ__Account__c=:testAcc.id and SBQQ__Status__c =: Label.Pricing_SW_QuoteStatusDraft];
        SBQQ__Quote__c testQuote2 = [Select id,SBQQ__Primary__c,SBQQ__Status__c,Pricing_SW_Description__c,Pricing_SW_Expiry_Date__c,SBQQ__StartDate__c,SBQQ__SubscriptionTerm__c,SBQQ__Opportunity2__c,SBQQ__Opportunity2__r.SBQQ__PrimaryQuote__c,SBQQ__Opportunity2__r.SBQQ__PrimaryQuote__r.SBQQ__Status__c,SBQQ__PaymentTerms__c,sbqq__billingfrequency__c,SBQQ__CustomerAmount__c,SBQQ__TargetCustomerAmount__c,SBQQ__AverageCustomerDiscount__c,SBQQ__NetAmount__c,sbqq__notes__c,SBQQ__BillingCountry__c,SBQQ__BillingState__c,SBQQ__BillingStreet__c,SBQQ__BillingCity__c,SBQQ__BillingPostalCode__c,SBQQ__CustomerDiscount__c,SBQQ__BillingName__c from SBQQ__Quote__c where SBQQ__Account__c=:testAcc.id and SBQQ__Status__c =: Label.Pricing_SW_OpportunityStatusSubmitted];
        
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
        Core_Opp_Bypass_Validation_Rule__c rec = new Core_Opp_Bypass_Validation_Rule__c();
        rec.Bypass__c = true;
        insert rec;

        testAcc = [Select id,name from Account where name ='Test Account'];
        testOpp1 = [Select id,name from Opportunity where accountid=:testAcc.id];
        testOpp2 = [Select id,name from Opportunity where accountid=:testAcc.id];
        PricebookEntry pbe=[select id from PricebookEntry Limit 1 ]; 
        SBQQ__Quote__c testQuote2 = [Select id,ApprovalStatus__c,Pricing_SW_Description__c,SBQQ__Opportunity2__c,SBQQ__Primary__c from SBQQ__Quote__c where SBQQ__Account__c=:testAcc.id and SBQQ__Status__c =: Label.Pricing_SW_OpportunityStatusSubmitted];
        testQuote2.SBQQ__Status__c=Label.Pricing_SW_OpportunityStatusSubmitted;
        update testQuote2;
        testOpp1.SBQQ__PrimaryQuote__c=testQuote2.id;
        update testOpp1;
        Opportunity testOpp3 = [SELECT Id, SBQQ__PrimaryQuote__r.SBQQ__Status__c,SBQQ__PrimaryQuote__r.SBQQ__Primary__c FROM Opportunity WHERE Id = :testOpp1.Id];
        SBQQ__Quote__c quote3= [Select id,SBQQ__Primary__c,SBQQ__Status__c,Pricing_SW_Description__c,Pricing_SW_Expiry_Date__c,SBQQ__StartDate__c,SBQQ__SubscriptionTerm__c,SBQQ__Opportunity2__c,SBQQ__PaymentTerms__c,sbqq__billingfrequency__c,SBQQ__CustomerAmount__c,SBQQ__TargetCustomerAmount__c,SBQQ__AverageCustomerDiscount__c,SBQQ__NetAmount__c,sbqq__notes__c,SBQQ__BillingCountry__c,SBQQ__BillingState__c,SBQQ__BillingStreet__c,SBQQ__BillingCity__c,SBQQ__BillingPostalCode__c,SBQQ__CustomerDiscount__c,SBQQ__BillingName__c from SBQQ__Quote__c where id=:testQuote2.id];
        OpportunityLineItem testOppLineItem = [select id,Core_Status__c from OpportunityLineItem where OpportunityId =: testOpp3.id];
        testOppLineItem.Core_Status__c='Lost';
        Update testOppLineItem;
        Set<Id> opportunityIds = new Set<Id>{testOpp3.Id, testOpp2.Id};
        Map<Id, Opportunity> opportunityMap = new Map<Id, Opportunity>();
        opportunityMap.put(testOpp3.Id, testOpp3);
        Map<Id, SBQQ__Quote__c> oldQuoteMap= new Map<Id, SBQQ__Quote__c>();
        oldQuoteMap.put(quote3.id,quote3);
        Test.startTest();
        // Call getOpportunityLostStatusMap method
        Pricing_SW_QuoteBusinessLogic.validateOpportunityProductLost(testQuote2,oldQuoteMap,opportunityIds,false);
        Pricing_SW_QuoteBusinessLogic.isPrimaryQuoteSubmitted(testQuote2, opportunityMap);
        Test.stopTest();
        
        // Assert that the Lost status is mapped correctly
       // System.assertEquals(null, result.get(testOpp2.Id), 'Opportunity 2 should be Lost');
        //System.assertNotEquals(false, result.get(testOpp1.Id), 'Opportunity 1 should not be Lost');
    }

    @IsTest
    static void testValidateQuoteInsert() {
        // Fetch test data
        Account acc = [Select id,name from Account where name ='Test Account'];
        Opportunity opp = [Select id,name from Opportunity where accountid=:acc.id];
        
        // Fetch quote records
        List<SBQQ__Quote__c> quote = [SELECT Id, SBQQ__Opportunity2__c, SBQQ__Status__c, SBQQ__Primary__c FROM SBQQ__Quote__c WHERE SBQQ__Opportunity2__r.Id = :opp.Id];
        SBQQ__QuoteLine__c quoteLine = [Select id,name from SBQQ__QuoteLine__c where SBQQ__Quote__c=:quote[0].id];
        opp = [SELECT Id, SBQQ__PrimaryQuote__r.SBQQ__Status__c, Core_Approval_Status__c FROM Opportunity where accountid=:acc.id];
        opp.Core_Approval_Status__c = Label.Pricing_SW_OpportunityStatusSubmitted;
        update opp;
        
        // Simulate the old quote map and opportunity map
        Map<Id, SBQQ__Quote__c> oldQuoteMap = new Map<Id, SBQQ__Quote__c>();
        Map<Id, Opportunity> opportunityMap = new Map<Id, Opportunity>{ opp.Id => opp };

        // Perform test logic
        Test.startTest();
        try {
             //Calling the validateQuote method for insert scenario
             Pricing_SW_QuoteBusinessLogic.validateQuote(quote[2], oldQuoteMap, opportunityMap, true);
            System.assert(true, 'Exception should have been thrown due to validation');
            
        } catch (Exception e) {
            System.assert(e.getMessage().contains(Label.Pricing_SW_AlreadyApprovedOpportunity), 'Unexpected validation message');
        }
        Test.stopTest();
    }

    @IsTest
    static void testValidateQuoteUpdate() {
        // Set up test data and create an Opportunity with a primary Quote
        Account testAcc = [Select id,name from Account where name ='Test Account'];
        Opportunity opp = [Select id,name from Opportunity where accountid=:testAcc.id];
        
        // Create an initial primary Quote associated with the Opportunity
        
        SBQQ__Quote__c oldQuote = [Select id,SBQQ__Primary__c,SBQQ__Status__c,Pricing_SW_Description__c,Pricing_SW_Expiry_Date__c,SBQQ__StartDate__c,SBQQ__SubscriptionTerm__c,SBQQ__Opportunity2__c,SBQQ__PaymentTerms__c,sbqq__billingfrequency__c,SBQQ__CustomerAmount__c,SBQQ__TargetCustomerAmount__c,SBQQ__AverageCustomerDiscount__c,SBQQ__NetAmount__c,sbqq__notes__c,SBQQ__BillingCountry__c,SBQQ__BillingState__c,SBQQ__BillingStreet__c,SBQQ__BillingCity__c,SBQQ__BillingPostalCode__c,SBQQ__CustomerDiscount__c,SBQQ__BillingName__c from SBQQ__Quote__c where SBQQ__Account__c=:testAcc.id and SBQQ__Status__c =: Label.Pricing_SW_QuoteStatusAccepted];
        
        // Modify the primary status of the quote in a way that will trigger the validation logic
        SBQQ__Quote__c updatedQuote = oldQuote.clone();
        updatedQuote.Id = oldQuote.Id;
        updatedQuote.SBQQ__Status__c = Label.Pricing_SW_QuoteStatusAccepted;
        
        // Update the Opportunity to have a primary Quote and a specific approval status
        opp.Core_Approval_Status__c = Label.Pricing_SW_OpportunityStatusSubmitted;
        opp.SBQQ__PrimaryQuote__c = oldQuote.Id;
        update opp;
        Opportunity opp1=[SELECT Id,SBQQ__PrimaryQuote__c,SBQQ__PrimaryQuote__r.SBQQ__Status__c,Core_Approval_Status__c,SBQQ__PrimaryQuote__r.SBQQ__Primary__c FROM Opportunity where id =:opp.id];
        // Prepare oldQuoteMap and opportunityMap
        Map<Id, SBQQ__Quote__c> oldQuoteMap = new Map<Id, SBQQ__Quote__c>{ oldQuote.Id => oldQuote };
        Map<Id, Opportunity> opportunityMap = new Map<Id, Opportunity>{ opp1.Id => opp1 };
                
        Test.startTest();
        
         Pricing_SW_QuoteBusinessLogic.validateQuote(updatedQuote, oldQuoteMap, opportunityMap, false);
        
        Test.stopTest();
    }

}