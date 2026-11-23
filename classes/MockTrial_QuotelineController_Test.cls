@isTest
public class MockTrial_QuotelineController_Test {
    
    @isTest
    static void test_getQuotelines(){
        //using a mock library to create a mock object.
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork uowMock = new fflib_SObjectMocks.SObjectUnitOfWork(mocks);
        
        //using the mock object to generate mock selector class of interface of the selector class.
        SEL_QuoteLines quoteLineSelectorMock = (SEL_QuoteLines) mocks.mock(SEL_QuoteLines.class);
        
        //using an id generator supported by fflib library to get only the id which is required by our method 
        //which leverages the work of creating an entire record for the purpose of only using the id.
        Id quoteId = fflib_IDGenerator.generate(Schema.SBQQ__Quote__c.SObjectType);
        Id compProductId = fflib_IDGenerator.generate(Schema.Pricing_Competitor_Product__c.SObjectType);
        
        //creating a list of record which will be returned when the method from the controller will be called.
        //there will be no need o insert the record since we will be using stub.
        SBQQ__QuoteLine__c testQuoteLine = (SBQQ__QuoteLine__c) new BLD_QuoteLines()
            .quote(quoteId)
            .otherProduct(compProductId)
            .pricingQuoteLineNumber('Q-001')
            .pricingIntegrationStatus('Pending')
            .pricingErrorMessage('Test')
            .mock();
        
        //starting the stub where we will tell the mock class that when this selector query is called from
        //controller method the record created above should be returned.
        mocks.startStubbing();
        
        //next line is mandatory for all selector stubbing since in the fflib_Application there is mockSobject map which 
        //maps the sobject to the mock class created.
        mocks.when(quoteLineSelectorMock.sObjectType()).thenReturn(Schema.SBQQ__QuoteLine__c.SObjectType);
        
        //here we are defining the return record which the query should return when the same argument is passed from the 
        //controller class on test execution.
        mocks.when(quoteLineSelectorMock.selectByQuoteIdAndNegativePricingStatus((Set<Id>) fflib_Match.anyObject(),(Set<String>) fflib_Match.anyObject())).thenReturn(new List<SBQQ__QuoteLine__c>{testQuoteLine});
        
        //stoping the stub.
        mocks.stopStubbing();
        
        //calling setMock method to map the sobject with the mock class generated using ApexMocks.
        Application.Selector.setMock(quoteLineSelectorMock);
        Application.unitOfWork.setMock(uowMock);
        
        //doing the test by calling the method with the id generated earlier.
        Test.startTest();
        List < SBQQ__QuoteLine__c > returnedQuoteLines = MockTrial_Pricing_QuoteLineController.getQuoteLines(quoteId); 
        Test.stopTest();
        
        // using verify method which works same as the assert
        // here it check that the selector method is called how many times.        
        ((SEL_QuoteLines) mocks.verify(quoteLineSelectorMock,1)).selectByQuoteIdAndNegativePricingStatus((Set<Id>) fflib_Match.anyObject(),(Set<String>) fflib_Match.anyObject());
        System.assert(returnedQuoteLines.size()==1);
        System.debug('Number of Queries used in this apex code so far: ' + Limits.getQueries());
    }
    
    @isTest
    static void test_getAvailableUserActions(){
        //using a mock library to create a mock object.
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork uowMock = new fflib_SObjectMocks.SObjectUnitOfWork(mocks);
        
        //using the mock object to generate mock selector class of interface of the selector class.
        SEL_QuoteLines selectorMock1 = (SEL_QuoteLines) mocks.mock(SEL_QuoteLines.class);
        SEL_PermissionSetAssignment selectorMock2 = (SEL_PermissionSetAssignment) mocks.mock(SEL_PermissionSetAssignment.class);        
        
        //creating a list of record which will be returned when the method from the controller will be called.
        //there will be no need o insert the record since we will be using stub.
        List<SBQQ__Quote__c> quotes = new List<SBQQ__Quote__c>{
            (SBQQ__Quote__c) new BLD_Quotes()
                .quoteStatus('Draft')
                .ownerId(UserInfo.getUserId())
                .createdById(UserInfo.getUserId())
                .mock(),
                (SBQQ__Quote__c) new BLD_Quotes()
                .quoteStatus('Draft')
                .ownerId(UserInfo.getUserId())
                .createdById(UserInfo.getUserId())
                .mock()
                };
                    List<SBQQ__QuoteLine__c> quotelines = new List<SBQQ__QuoteLine__c>{
                        (SBQQ__QuoteLine__c) new BLD_QuoteLines()
                            .quote(quotes[0].id)
                            .quotelineStatus('Draft')
                            .pricingSalesRep(UserInfo.getUserId())
                            .createdById(UserInfo.getUserId())
                            .pricingPrimaryContact(UserInfo.getUserId())
                            .pricingChangeRequest(false)
                            .mock(),
                            (SBQQ__QuoteLine__c) new BLD_QuoteLines()
                            .quote(quotes[0].id)
                            .quotelineStatus('Pending Intel Field Review')
                            .pricingSalesRep(UserInfo.getUserId())
                            .createdById(UserInfo.getUserId())
                            .pricingPrimaryContact(UserInfo.getUserId())
                            .pricingChangeRequest(false)
                            .mock(),
                            (SBQQ__QuoteLine__c) new BLD_QuoteLines()
                            .quote(quotes[0].id)
                            .quotelineStatus('Pending Further Intel Review')
                            .pricingSalesRep(UserInfo.getUserId())
                            .createdById(UserInfo.getUserId())
                            .pricingPrimaryContact(UserInfo.getUserId())
                            .pricingChangeRequest(false)
                            .mock(),
                            (SBQQ__QuoteLine__c) new BLD_QuoteLines()
                            .quote(quotes[0].id)
                            .quotelineStatus('Approved')
                            .pricingSalesRep(UserInfo.getUserId())
                            .createdById(UserInfo.getUserId())
                            .pricingPrimaryContact(UserInfo.getUserId())
                            .pricingChangeRequest(false)
                            .pricingIntegrationStatus('Pending')
                            .pricingDealStatus('Pending')
                            .pricingDealId('Test001')
                            .mock(),
                            (SBQQ__QuoteLine__c) new BLD_QuoteLines()
                            .quote(quotes[0].id)
                            .quotelineStatus('Won')
                            .pricingSalesRep(UserInfo.getUserId())
                            .createdById(UserInfo.getUserId())
                            .pricingPrimaryContact(UserInfo.getUserId())
                            .pricingChangeRequest(false)
                            .mock(),
                            (SBQQ__QuoteLine__c) new BLD_QuoteLines()
                            .quote(quotes[0].id)
                            .quotelineStatus('Lost')
                            .pricingSalesRep(UserInfo.getUserId())
                            .createdById(UserInfo.getUserId())
                            .pricingPrimaryContact(UserInfo.getUserId())
                            .pricingChangeRequest(false)
                            .pricingApprovedEndDate(System.today()+3)
                            .mock()
                            };
                                //starting the stub where we will tell the mock class that when this selector query is called from
                                //controller method the record created above should be returned.
                                mocks.startStubbing();
        //next line is mandatory for all selector stubbing since in the fflib_Application there is mockSobject map which 
        //maps the sobject to the mock class created.
        mocks.when(selectorMock1.sObjectType()).thenReturn(Schema.SBQQ__QuoteLine__c.SObjectType);
        //here we are defining the return record which the query should return when the same argument is passed from the 
        //controller class on test execution
        mocks.when(selectorMock1.selectById(new Set<Id>{quotelines[0].id})).thenReturn(new List<SBQQ__QuoteLine__c>{quotelines[0]});
        mocks.when(selectorMock1.selectById(new Set<Id>{quotelines[0].id})).thenReturn(new List<SBQQ__QuoteLine__c>{quotelines[0]});
        mocks.when(selectorMock1.selectById(new Set<Id>{quotelines[1].id})).thenReturn(new List<SBQQ__QuoteLine__c>{quotelines[1]});
        mocks.when(selectorMock1.selectById(new Set<Id>{quotelines[1].id})).thenReturn(new List<SBQQ__QuoteLine__c>{quotelines[1]});
        mocks.when(selectorMock1.selectById(new Set<Id>{quotelines[2].id})).thenReturn(new List<SBQQ__QuoteLine__c>{quotelines[2]});
        mocks.when(selectorMock1.selectById(new Set<Id>{quotelines[2].id})).thenReturn(new List<SBQQ__QuoteLine__c>{quotelines[2]});
        mocks.when(selectorMock1.selectById(new Set<Id>{quotelines[3].id})).thenReturn(new List<SBQQ__QuoteLine__c>{quotelines[3]});
        mocks.when(selectorMock1.selectById(new Set<Id>{quotelines[3].id})).thenReturn(new List<SBQQ__QuoteLine__c>{quotelines[3]});
        mocks.when(selectorMock1.selectById(new Set<Id>{quotelines[4].id})).thenReturn(new List<SBQQ__QuoteLine__c>{quotelines[4]});
        mocks.when(selectorMock1.selectById(new Set<Id>{quotelines[4].id})).thenReturn(new List<SBQQ__QuoteLine__c>{quotelines[4]});
        mocks.when(selectorMock1.selectById(new Set<Id>{quotelines[5].id})).thenReturn(new List<SBQQ__QuoteLine__c>{quotelines[5]});
        mocks.when(selectorMock1.selectById(new Set<Id>{quotelines[5].id})).thenReturn(new List<SBQQ__QuoteLine__c>{quotelines[5]});
        mocks.when(selectorMock2.sObjectType()).thenReturn(Schema.PermissionSetAssignment.SObjectType);
        mocks.when(selectorMock2.selectByName(UserInfo.getUserId(),new Set < String > {'Pricing_Tender_IT_Specialist', 'Pricing_Tender_Partner_Administrator', 'Pricing_Tender_Regional_Pricing_Manager', 'Tender_Account_Executive', 'Tender_Partner', 'Tender_Partner_Drafter_Access', 'Tender_Partner_Drafter_Limited_Access', 'Tender_User'})).thenReturn(true);
        mocks.when(selectorMock2.selectByName(UserInfo.getUserId(),new Set < String > {Label.Pricing_Tender_PermissionSets_TenderUser})).thenReturn(true);
        mocks.when(selectorMock2.selectByName(UserInfo.getUserId(),new Set < String > {Label.Pricing_Tender_PermissionSets_PricingTenderRegionalPricingManager})).thenReturn(true);
        mocks.when(selectorMock2.selectByName(UserInfo.getUserId(),new Set < String > {'Pricing_Tender_Partner_Administrator', 'Tender_Partner', 'Tender_Partner_Drafter_Access'})).thenReturn(true);
        mocks.when(selectorMock2.selectByName(UserInfo.getUserId(),new Set < String > {'Pricing_Tender_Partner_Administrator', 'Tender_Partner', 'Tender_Partner_Drafter_Access', 'Tender_Partner_Drafter_Limited_Access', 'Tender_User'})).thenReturn(true);
        mocks.stopStubbing();
        //calling setMock method to map the sobject with the mock class generated using ApexMocks.
        Application.Selector.setMock(selectorMock1);
        Application.Selector.setMock(selectorMock2);
        
        System.Test.startTest();
        MockTrial_Pricing_QuoteLineController.getAvailableUserActions(quotelines[0].id);
        MockTrial_Pricing_QuoteLineController.getAvailableUserActions(quotelines[1].id);
        MockTrial_Pricing_QuoteLineController.getAvailableUserActions(quotelines[2].id); 
        MockTrial_Pricing_QuoteLineController.getAvailableUserActions(quotelines[3].id); 
        MockTrial_Pricing_QuoteLineController.getAvailableUserActions(quotelines[4].id); 
        MockTrial_Pricing_QuoteLineController.getAvailableUserActions(quotelines[5].id); 
        System.Test.stopTest();
        // using verify method which works same as the assert
        // here it check that the selector method is called how many times.     
        ((SEL_QuoteLines) mocks.verify(selectorMock1,2)).selectById(new Set<Id>{quotelines[1].id});
        ((SEL_PermissionSetAssignment) mocks.verify(selectorMock2,8)).selectByName(UserInfo.getUserId(),new Set < String > {'Pricing_Tender_IT_Specialist', 'Pricing_Tender_Partner_Administrator', 'Pricing_Tender_Regional_Pricing_Manager', 'Tender_Account_Executive', 'Tender_Partner', 'Tender_Partner_Drafter_Access', 'Tender_Partner_Drafter_Limited_Access', 'Tender_User'});
        ((SEL_PermissionSetAssignment) mocks.verify(selectorMock2,4)).selectByName(UserInfo.getUserId(),new Set < String > {Label.Pricing_Tender_PermissionSets_PricingTenderRegionalPricingManager});
        ((SEL_PermissionSetAssignment) mocks.verify(selectorMock2,1)).selectByName(UserInfo.getUserId(),new Set < String > {'Pricing_Tender_Partner_Administrator', 'Tender_Partner', 'Tender_Partner_Drafter_Access', 'Tender_Partner_Drafter_Limited_Access', 'Tender_User'});
        ((SEL_PermissionSetAssignment) mocks.verify(selectorMock2,1)).selectByName(UserInfo.getUserId(),new Set < String > {'Tender_User'});
        ((SEL_PermissionSetAssignment) mocks.verify(selectorMock2,2)).selectByName(UserInfo.getUserId(),new Set < String > {'Pricing_Tender_Partner_Administrator', 'Tender_Partner', 'Tender_Partner_Drafter_Access'});
        System.debug('Number of Queries used in this apex code so far: ' + Limits.getQueries());
    }
    
    @isTest
    static void testUOW(){
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork uowMock = new fflib_SObjectMocks.SObjectUnitOfWork(mocks);
        
        SEL_Account selectorMock1 = (SEL_Account) mocks.mock(SEL_Account.class);
        
        Account acc = new Account(id=fflib_IDGenerator.generate(Schema.Account.SObjectType),
                                  Name='MockTrial Account');
        Id conid1 = fflib_IDGenerator.generate(Schema.Contact.SObjectType);
        Id conid2 = fflib_IDGenerator.generate(Schema.Contact.SObjectType);    
        
        List<Account> accountRecord = (List<Account>) fflib_ApexMocksUtils.makeRelationship(
           List<Account>.class,
              new List<Account>{
                         acc
                   },
           Contact.AccountId,
               new List<List<Contact>>{
                   new List<Contact>{
            new Contact(id=conid1,
                        AccountId=acc.id,
                        FirstName='MockTrial',
                        LastName='Contact'),
                new Contact(id=conid2,
                            AccountId=acc.id,
                            FirstName='MockTrial',
                            LastName='Contact2')
                }
                }
           );
         mocks.startStubbing();
         mocks.when(selectorMock1.sObjectType()).thenReturn(Schema.Account.SObjectType);
         mocks.when(selectorMock1.selectByAccountAndContact()).thenReturn(accountRecord);
         mocks.stopStubbing();
        
         Application.unitOfWork.setMock(uowMock);
         Application.Selector.setMock(selectorMock1);
        
         Test.startTest();
         MockTrial_Pricing_QuoteLineController.updateACCandCon();
         Test.stopTest();
                    
         ((SEL_Account) mocks.verify(selectorMock1,1)).selectByAccountAndContact();
        System.debug('Number of Queries used in this apex code so far: ' + Limits.getQueries());
        System.debug('Number of Queries used in this apex code so far: ' + Limits.getDmlStatements());
         
    }
    
}