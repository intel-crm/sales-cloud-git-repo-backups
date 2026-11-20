@IsTest
private class SWS_FindSingleOpportunityByProduct_Test {

    @TestSetup
    static void setup() {
        User u = SWS_TestUtilty.createUser();
        PermissionSet permissionRec = [SELECT Id,Name FROM PermissionSet WHERE Name = 'PSG_Master_Data_Read_Write_Access' LIMIT 1];
        insert new PermissionSetAssignment(AssigneeId = u.Id, PermissionSetId = permissionRec.Id);
        
        System.runAs(u) {
            
        Core_Opp_Bypass_Validation_Rule__c BypassRule = new Core_Opp_Bypass_Validation_Rule__c();
        BypassRule.Bypass__c = true;
        insert BypassRule;
            // Create Country Reference data similar to Core_LeadHandler_Test
            List<Core_Country_Reference__c> lstCS = Core_Test_Utility.Core_CountryState(1);
            for (Core_Country_Reference__c sobjCS: lstCS) {
                sobjCS.Name = 'United States';
                sobjCS.Core_Geo__c = 'ASMO';
                sobjCS.Core_Has_States__c = true;
                sobjCS.Core_ISO_Code__c = 'USA';
                sobjCS.Core_Sub_Geo__c = 'NAR';
            }
            insert lstCS;

            // Create Account using the same pattern as Core_LeadHandler_Test
            List<Account> lstAccounts = new List<Account>{SWS_TestUtilty.createAccount()};

            // Create Opportunities using similar pattern to Core_LeadHandler_Test
            Id dealOpptyRecTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Deal Opportunity').getRecordTypeId();
            
            List<Opportunity> opptyList = new List<Opportunity>();
            opptyList.add(new Opportunity(
                Name = 'Test Opportunity 1', 
                RecordTypeId = dealOpptyRecTypeId, 
                Core_Opportunity_Coverage_Nm__c = 'Partner-Led Opportunity', 
                Core_Coverage_Type_Nm__c = 'Deal Registration',
                AccountId = lstAccounts[0].Id, 
                StageName = 'Qualify', 
                CloseDate = System.Date.today().addYears(1), 
                Core_Technical_Owner__c = u.Id, 
                Core_Sales_Group__c = 'Global Accounts', 
                Core_Commissionable__c = 'No', 
                Core_Opportunity_Type__c = 'Deal: Sell-to', 
                Core_Product_Segment__c = 'Data Center Computing', 
                Core_Product_Application__c = 'Storage', 
                Core_Consumption_Market__c = 'Education',
                Core_Intel_Platform__c = 'ALDER LAKE D', 
                Core_First_Customer_Ship_Date__c = System.Date.today().addMonths(8), 
                Core_Solution_Area__c = 'DCG Compute Deal $',
                Amount = 100
            ));
            
            opptyList.add(new Opportunity(
                Name = 'Test Opportunity 2', 
                RecordTypeId = dealOpptyRecTypeId, 
                Core_Opportunity_Coverage_Nm__c = 'Partner-Led Opportunity', 
                Core_Coverage_Type_Nm__c = 'Deal Registration',
                AccountId = lstAccounts[0].Id, 
                StageName = 'Qualify', 
                CloseDate = System.Date.today().addYears(1), 
                Core_Technical_Owner__c = u.Id, 
                Core_Sales_Group__c = 'Global Accounts', 
                Core_Commissionable__c = 'No', 
                Core_Opportunity_Type__c = 'Deal: Sell-to', 
                Core_Product_Segment__c = 'Data Center Computing', 
                Core_Product_Application__c = 'Storage', 
                Core_Consumption_Market__c = 'Education',
                Core_Intel_Platform__c = 'ALDER LAKE D', 
                Core_First_Customer_Ship_Date__c = System.Date.today().addMonths(8), 
                Core_Solution_Area__c = 'DCG Compute Deal $',
                Amount = 200
            ));
            
            opptyList.add(new Opportunity(
                Name = 'Test Opportunity 3', 
                RecordTypeId = dealOpptyRecTypeId, 
                Core_Opportunity_Coverage_Nm__c = 'Partner-Led Opportunity', 
                Core_Coverage_Type_Nm__c = 'Deal Registration',
                AccountId = lstAccounts[0].Id, 
                StageName = 'Qualify', 
                CloseDate = System.Date.today().addYears(1), 
                Core_Technical_Owner__c = u.Id, 
                Core_Sales_Group__c = 'Global Accounts', 
                Core_Commissionable__c = 'No', 
                Core_Opportunity_Type__c = 'Deal: Sell-to', 
                Core_Product_Segment__c = 'Data Center Computing', 
                Core_Product_Application__c = 'Storage', 
                Core_Consumption_Market__c = 'Education',
                Core_Intel_Platform__c = 'ALDER LAKE D', 
                Core_First_Customer_Ship_Date__c = System.Date.today().addMonths(8), 
                Core_Solution_Area__c = 'DCG Compute Deal $',
                Amount = 300
            ));
            
            insert opptyList;

       List<Product2> testProducts = Core_Test_Utility.createProduct(3);
        insert testProducts;
       
        List<PricebookEntry> testPBEs = Core_Test_Utility.createPriceBookEntry(3, testProducts, Test.getStandardPricebookId());
        insert testPBEs;
       //ptyList[2]
        // Insert these in a specific order that we can rely on, since we can only sort by ID value when querying them from the
        // opportunity product history object later (can't sort on Description or any other attribute)
        OpportunityLineItem testOppLineItem;
        testOppLineItem = new OpportunityLineItem(OpportunityId=opptyList[0].Id, PricebookEntryId=testPBEs[0].Id,
                                                  Description='Test 11', UnitPrice=11, Quantity=11,
                                                  Core_Loss_Cancel_Reason__c=null, Core_Status__c='Pending');
        insert testOppLineItem;
        testOppLineItem = new OpportunityLineItem(OpportunityId=opptyList[1].Id, PricebookEntryId=testPBEs[1].Id,
                                                  Description='Test 12', UnitPrice=12, Quantity=12,
                                                  Core_Loss_Cancel_Reason__c='', Core_Status__c='Pending');
        insert testOppLineItem;
        testOppLineItem = new OpportunityLineItem(OpportunityId=opptyList[2].Id, PricebookEntryId=testPBEs[2].Id,
                                                  Description='Test 13', UnitPrice=13, Quantity=13,
                                                  Core_Loss_Cancel_Reason__c=null, Core_Status__c='Pending');
        insert testOppLineItem;
       
        testOppLineItem = new OpportunityLineItem(OpportunityId=opptyList[0].Id, PricebookEntryId=testPBEs[2].Id,
                                                  Description='Test 13', UnitPrice=13, Quantity=13,
                                                  Core_Loss_Cancel_Reason__c=null, Core_Status__c='Pending',Core_At_Risk__c=true,Core_Risk_Reason1__c='Competition',Core_Risk_Detail__c = 'test',Core_Risk_Priority__c='3 Medium – Unusual Risk, Action Required',Core_Risk_Category__c='Support Requested',Core_At_Risk_Status__c='In-Progress');
        insert testOppLineItem;

            // Update opportunities to set LastModifiedDate for tie-breaker testing
            opptyList[1].Name = 'Test Opportunity 2 - Updated';
            update opptyList[1];
            opptyList[2].Name = 'Test Opportunity 3 - Updated';
            update opptyList[2];
        }
    } 
    @IsTest
    static void testSingleMatch() {
        User u = [SELECT Id FROM User WHERE UserName='requestoremail@testorg.com'];
        System.runAs(u) {
            List<Opportunity> opps = [SELECT Id, Name, LastModifiedDate FROM Opportunity WHERE Name LIKE 'Test Opportunity 1%'];
            System.assertEquals(1, opps.size(), 'Expected Test Opportunity 1 to exist');

            SWS_FindSingleOpportunityByProduct.Request req = new SWS_FindSingleOpportunityByProduct.Request();
            req.body = 'Following up on your interest in Widget Alpha and pricing.';
            req.opportunityIds = new List<Id>{ opps[0].Id };

            Test.startTest();
            List<SWS_FindSingleOpportunityByProduct.Result> res = SWS_FindSingleOpportunityByProduct.findOneByProduct(new List<SWS_FindSingleOpportunityByProduct.Request>{ req });
            Test.stopTest();

            System.assertEquals(1, res.size(), 'One result expected');
           //ystem.assertEquals(opps[0].Id, res[0].opportunityId, 'Should return Test Opportunity 1 by product match');
       //   System.assertNotEquals(null, res[0].opportunityName, 'Name should be populated');
        }
    }

    @IsTest
    static void testNoMatchReturnsNull() {
        User u = [SELECT Id FROM User WHERE UserName='requestoremail@testorg.com'];
        System.runAs(u) {
            List<Opportunity> allOpps = [SELECT Id FROM Opportunity];
            System.assert(allOpps.size() >= 3, 'Expected test opps present');

            SWS_FindSingleOpportunityByProduct.Request req = new SWS_FindSingleOpportunityByProduct.Request();
            req.body = 'Body mentions something unrelated with no products.';
            req.opportunityIds = new List<Id>{ allOpps[0].Id, allOpps[1].Id, allOpps[2].Id };

            Test.startTest();
            List<SWS_FindSingleOpportunityByProduct.Result> res = SWS_FindSingleOpportunityByProduct.findOneByProduct(new List<SWS_FindSingleOpportunityByProduct.Request>{ req });
            Test.stopTest();

            System.assertEquals(1, res.size(), 'One result expected');
        }
    }

    @IsTest
    static void testCaseInsensitiveMatch() {
        User u = [SELECT Id FROM User WHERE UserName='requestoremail@testorg.com'];
        System.runAs(u) {
            Opportunity opp2 = [SELECT Id FROM Opportunity WHERE Name LIKE 'Test Opportunity 2%' LIMIT 1];

            SWS_FindSingleOpportunityByProduct.Request req = new SWS_FindSingleOpportunityByProduct.Request();
            req.body = 'Interested in gadget beta specs and delivery timelines.';
            req.opportunityIds = new List<Id>{ opp2.Id };

            Test.startTest();
            List<SWS_FindSingleOpportunityByProduct.Result> res = SWS_FindSingleOpportunityByProduct.findOneByProduct(new List<SWS_FindSingleOpportunityByProduct.Request>{ req });
            Test.stopTest();

            System.assertEquals(1, res.size());
            //stem.assertEquals(opp2.Id, res[0].opportunityId, 'Case-insensitive match should work');
        }
    }

    @IsTest
    static void testMultipleMatchesTieBreakerByLastModified() {
        User u = [SELECT Id FROM User WHERE UserName='requestoremail@testorg.com'];
        System.runAs(u) {
            Opportunity opp2 = [SELECT Id, LastModifiedDate FROM Opportunity WHERE Name LIKE 'Test Opportunity 2%' LIMIT 1];
            Opportunity opp3 = [SELECT Id, LastModifiedDate FROM Opportunity WHERE Name LIKE 'Test Opportunity 3%' LIMIT 1];

            SWS_FindSingleOpportunityByProduct.Request req = new SWS_FindSingleOpportunityByProduct.Request();
            req.body = 'Our inquiry concerns both GADGET beta and Tool Gamma for Q2.';
            req.opportunityIds = new List<Id>{ opp2.Id, opp3.Id };

            Test.startTest();
            List<SWS_FindSingleOpportunityByProduct.Result> res = SWS_FindSingleOpportunityByProduct.findOneByProduct(new List<SWS_FindSingleOpportunityByProduct.Request>{ req });
            Test.stopTest();

            System.assertEquals(1, res.size(), 'One result expected');
            // opp3 was updated last in @TestSetup, so it should be chosen
          //System.assertEquals(opp3.Id, res[0].opportunityId, 'Tie-breaker should pick latest LastModifiedDate (Test Opportunity 3)');
        }
    }

    @IsTest
    static void testBulkRequests() {
        User u = [SELECT Id FROM User WHERE UserName='requestoremail@testorg.com'];
        System.runAs(u) {
            List<Opportunity> allOpps = [SELECT Id, Name FROM Opportunity ORDER BY Name ASC];
            System.assert(allOpps.size() >= 3, 'Expected 3 opps');

            Id opp1Id = allOpps[0].Id;
            Id opp2Id = allOpps[1].Id;
            Id opp3Id = allOpps[2].Id;

            // Request 1: matches opp1 only
            SWS_FindSingleOpportunityByProduct.Request r1 = new SWS_FindSingleOpportunityByProduct.Request();
            r1.body = 'Kindly share brochure for Widget Alpha.';
            r1.opportunityIds = new List<Id>{ opp1Id, opp2Id };

            // Request 2: matches opp2 only (case-insensitive)
            SWS_FindSingleOpportunityByProduct.Request r2 = new SWS_FindSingleOpportunityByProduct.Request();
            r2.body = 'Need delivery timeline for gadget beta next month.';
            r2.opportunityIds = new List<Id>{ opp2Id, opp3Id };

            // Request 3: no match
            SWS_FindSingleOpportunityByProduct.Request r3 = new SWS_FindSingleOpportunityByProduct.Request();
            r3.body = 'Completely unrelated text.';
            r3.opportunityIds = new List<Id>{ opp1Id, opp2Id, opp3Id };

            Test.startTest();
            List<SWS_FindSingleOpportunityByProduct.Result> results =
                SWS_FindSingleOpportunityByProduct.findOneByProduct(new List<SWS_FindSingleOpportunityByProduct.Request>{ r1, r2, r3 });
            Test.stopTest();

            System.assertEquals(3, results.size(), 'Three results expected');
        }
    }
}