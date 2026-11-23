@isTest (seeAllData=true)
private class Core_OppChildViewController_Test {

    // 
    // Test a fully-populated Solution Group with fully-populated Opportunities
    // 
    static testMethod void testSolutionGroupWithOpps() {
        
        //-----------------------------------------------------------------
        // Data setup
        Test.startTest();
        // Need to use System.runAs to avoid MIXED_DML_OPERATION error
        System.runAs(new User(Id = UserInfo.getUserId())) {
        
            // Add a couple of users to be added as team members later
            User user1 = new User(UserName='test.user1@intel.com.crm.testSolutionGroupWithOpps', LastName='User', Email='test.user1@intel.com',
                                  Alias='tclass1', TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US', EmailEncodingKey='UTF-8',
                                  ProfileId=[select Id from Profile where Name='Standard User' limit 1][0].Id, LanguageLocaleKey='en_US',
                                  Core_Employee_Type_Code__c='Blue Badge');
            User user2 = new User(UserName='test.user2@intel.com.crm.testSolutionGroupWithOpps', LastName='User', Email='test.user2@intel.com',
                                  Alias='tclass2', TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US', EmailEncodingKey='UTF-8',
                                  ProfileId=[select Id from Profile where Name='Standard User' limit 1][0].Id, LanguageLocaleKey='en_US',
                                  Core_Employee_Type_Code__c='Blue Badge');
            insert user1;
            insert user2;
        
            Account acct = new Account(Name='Test Account from test method',Core_Sales_Groups__c='CCG Sales Group', BillingStreet='a', BillingCity='a', BillingState='MI', BillingCountry='USA');
            insert acct;
            
            // Solution Group with Opportunities
            Opportunity solutionGroup = new Opportunity(
                Name = 'Test Solution Group with Opportunities from test method',
                AccountId = acct.Id,
                StageName = 'Qualifying',
                CloseDate = System.Date.today().addYears(1),
                RecordTypeId = [select Id from RecordType where DeveloperName = 'Core_Solution_Group' limit 1][0].Id);
            insert solutionGroup;
            
            // Attach a bunch of Opportunities to it
            List<Opportunity> opps = new List<Opportunity>();
            Id oppRecTypeId = [select Id from RecordType where DeveloperName = 'Core_Opportunity' limit 1][0].Id;
            for (Integer i=0; i<10; i++) {
                opps.add(new Opportunity(Name = 'Test Opportunity ' + i + ' from test method',
                                         AccountId = acct.Id,
                                         StageName = 'Qualifying',
                                         CloseDate = System.Date.today().addYears(1),
                                         Core_Solution_Group__c = solutionGroup.Id,
                                         RecordTypeId = oppRecTypeId));
            }
            // And one Opportunity we'll add after the fact
            opps.add(new Opportunity(Name = 'Test Opportunity 11 from test method',
                                     AccountId = acct.Id,
                                     StageName = 'Qualifying',
                                     CloseDate = System.Date.today().addYears(1),
                                     RecordTypeId = oppRecTypeId));
            
            insert opps;
            
            Id existingOppId = opps[10].Id;
            
            // Opportunity product line items
            Product2 prod = new Product2(Name='Test Product');
            insert prod;
            
            PricebookEntry bookEntry = new PricebookEntry(Product2Id=prod.Id,
                                                          Pricebook2Id=Test.getStandardPricebookId(),
                                                          Unitprice=10,
                                                          IsActive=true);
            insert bookEntry;
            
            List<OpportunityLineItem> oppProducts = new List<OpportunityLineItem>();
            for (Opportunity opp : opps) {
                for (Integer i=0; i<10; i++) {
                    oppProducts.add(new OpportunityLineItem(OpportunityId=opp.Id, PricebookEntryId=bookEntry.Id, Quantity=5, TotalPrice=50));
                }
            }
            //insert oppProducts;
            
            // Team members
            List<OpportunityTeamMember> oppTeams = new List<OpportunityTeamMember>();
            for (Opportunity opp : opps) {
                oppTeams.add(new OpportunityTeamMember(OpportunityId=opp.Id, UserId=user1.Id, TeamMemberRole='Technical Role'));
                oppTeams.add(new OpportunityTeamMember(OpportunityId=opp.Id, UserId=user2.Id, TeamMemberRole='Technical Role'));
            }
            insert oppTeams;
            
            //-----------------------------------------------------------------
            // Testing
            
            // Instantiate our controller and call our methods
            PageReference oppChildViewPage = Page.Core_OppChildView;
            Test.setCurrentPage(oppChildViewPage);
            ApexPages.currentPage().getParameters().put('Id', solutionGroup.id);
            Core_OppChildViewController oppChildViewController =
                new Core_OppChildViewController(new ApexPages.StandardController(solutionGroup));
            
            System.assert(oppChildViewController.getChildOpps().size() > 0);        // Should return a non-empty list
            System.assertEquals(oppChildViewController.newOpp(), null);     // Action method shouldn't return anything
            System.assert(oppChildViewController.getNewOppUrl().length() > 0);  // Should return a non-empty string
            
            // Now try adding an Opportunity after the fact
            oppChildViewController.solutionGroup.Core_Solution_Group__c = existingOppId;
            System.assertNotEquals(oppChildViewController.save(), null);    // Saving it should return non-null PageReference
        }
        Test.stopTest();
    }
    
    // 
    // Test a Solution Group with no Opportunities
    // 
    static testMethod void testSolutionGroupWithNoOpps() {
        
        //-----------------------------------------------------------------
        // Data setup
        
        Account acct = new Account(Name='Test Account', Core_Sales_Groups__c='CCG Sales Group', BillingStreet='a', BillingCity='a', BillingState='MI', BillingCountry='USA');
        insert acct;
        
        // Master Opportunity with No Subs
        Opportunity solutionGroupNoSubs = new Opportunity(
            Name = 'Test Solution Group with no Opportunities from test method',
            AccountId = acct.Id,
            StageName = 'Qualifying',
            CloseDate = System.Date.today().addYears(1),
            RecordTypeId = [select Id from RecordType where DeveloperName = 'Core_Solution_Group' limit 1][0].Id);
        insert solutionGroupNoSubs;
        
        //-----------------------------------------------------------------
        // Testing
        
        // Instantiate our controller and call our methods
        PageReference oppChildViewPage = Page.Core_OppChildView;
        Test.setCurrentPage(oppChildViewPage);
        
        ApexPages.currentPage().getParameters().put('Id', solutionGroupNoSubs.id);
        Core_OppChildViewController oppChildViewController =
            new Core_OppChildViewController(new ApexPages.StandardController(solutionGroupNoSubs));
        
        System.assertEquals(oppChildViewController.getChildOpps(), null);       // Should return an empty list
        System.assertEquals(oppChildViewController.newOpp(), null);     // Action method shouldn't return anything
        System.assert(oppChildViewController.getNewOppUrl().length() > 0);  // Should return a non-empty string
    }

}