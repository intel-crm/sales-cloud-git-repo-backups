@isTest
public class Pricing_QuoteLineController_Mock_Test {
    
    @isTest
    static void test_getQuotelines(){
        //using a mock library to create a mock object.
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        
        //using the mock object to generate mock selector class of interface of the selector class.
        Pricing_QuoteLines_Selector quoteLineSelectorMock = (Pricing_QuoteLines_Selector) mocks.mock(Pricing_QuoteLines_Selector.class);
        Pricing_Quote_Selector quoteSelectorMock = (Pricing_Quote_Selector) mocks.mock(Pricing_Quote_Selector.class);
        Pricing_PermissionSetAssignment_Selector psaSelectorMock = (Pricing_PermissionSetAssignment_Selector) mocks.mock(Pricing_PermissionSetAssignment_Selector.class);
        //using an id generator supported by fflib library to get only the id which is required by our method 
        //which leverages the work of creating an entire record for the purpose of only using the id.
        Id quoteId = fflib_IDGenerator.generate(Schema.SBQQ__Quote__c.SObjectType);
        Id compProductId = fflib_IDGenerator.generate(Schema.Pricing_Competitor_Product__c.SObjectType);
        
        //creating a list of record which will be returned when the method from the controller will be called.
        //there will be no need o insert the record since we will be using stub.
        SBQQ__QuoteLine__c testQuoteLine =new SBQQ__QuoteLine__c();
        testQuoteLine.id =  fflib_IDGenerator.generate(Schema.SBQQ__QuoteLine__c.SObjectType);
        
        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        //starting the stub where we will tell the mock class that when this selector query is called from
        //controller method the record created above should be returned.
        mocks.startStubbing();
        
        //next line is mandatory for all selector stubbing since in the fflib_Application there is mockSobject map which 
        //maps the sobject to the mock class created.
        mocks.when(quoteLineSelectorMock.sObjectType()).thenReturn(Schema.SBQQ__QuoteLine__c.SObjectType);
        mocks.when(quoteSelectorMock.sObjectType()).thenReturn(Schema.SBQQ__Quote__c.SObjectType);
        mocks.when(psaSelectorMock.sObjectType()).thenReturn(Schema.PermissionSetAssignment.SObjectType);
        
        //here we are defining the return record which the query should return when the same argument is passed from the 
        //controller class on test execution.
        mocks.when(quoteLineSelectorMock.selectByIdAndStatus((Id) fflib_Match.anyObject(),(String) fflib_Match.anyObject())).thenReturn(new List<SBQQ__QuoteLine__c>{testQuoteLine});
        mocks.when(quoteLineSelectorMock.selectByQuoteLineIds(new Set<Id>{testQuoteLine.id})).thenReturn(new List<SBQQ__QuoteLine__c>{testQuoteLine});
        mocks.when(quoteSelectorMock.selectByIds(new Set<Id>{quoteId})).thenReturn(new List<SBQQ__Quote__c>{quote});
        mocks.when(psaSelectorMock.selectByName((Id) fflib_Match.anyObject(),(Set<String>) fflib_Match.anyObject())).thenReturn(false);
        //stoping the stub.
        mocks.stopStubbing();
        
        //calling setMock method to map the sobject with the mock class generated using ApexMocks.
        Pricing_IQR_Application.Selector.setMock(quoteLineSelectorMock);
        Pricing_IQR_Application.Selector.setMock(quoteSelectorMock);
        Pricing_IQR_Application.Selector.setMock(psaSelectorMock);
        
        //doing the test by calling the method with the id generated earlier.
        Test.startTest();
        List < SBQQ__QuoteLine__c > returnedQuoteLines = Pricing_QuoteLineController_Mock.getQuoteLines(quoteId); 
        Pricing_QuoteLineController_Mock.getQuoteLine(testQuoteLine.id);
        Pricing_QuoteLineController_Mock.getProductName(testQuoteLine.id);
        Pricing_QuoteLineController_Mock.getQuote(quoteId);
        Pricing_QuoteLineController_Mock.isOEMField();
        Test.stopTest();
        
        // using verify method which works same as the assert
        // here it check that the selector method is called how many times.        
        ((Pricing_QuoteLines_Selector) mocks.verify(quoteLineSelectorMock,1)).selectByIdAndStatus((Id) fflib_Match.anyObject(),(String) fflib_Match.anyObject());
        System.assert(returnedQuoteLines.size()==1);
        System.debug('Number of Queries used in this apex code so far: ' + Limits.getQueries());
    }
    
    @isTest
    static void test_getAvailableUserActions(){
        //using a mock library to create a mock object.
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        
        //using the mock object to generate mock selector class of interface of the selector class.
        Pricing_QuoteLines_Selector qliSelector = (Pricing_QuoteLines_Selector) mocks.mock(Pricing_QuoteLines_Selector.class);
        Pricing_PermissionSetAssignment_Selector psaSelector = (Pricing_PermissionSetAssignment_Selector) mocks.mock(Pricing_PermissionSetAssignment_Selector.class);        
        Pricing_User_Selector usrSelector = (Pricing_User_Selector) mocks.mock(Pricing_User_Selector.class);
        Pricing_QLIWonLossRestriction_Selector restSelector = (Pricing_QLIWonLossRestriction_Selector) mocks.mock(Pricing_QLIWonLossRestriction_Selector.class);
        Pricing_ProcessInstanceWorkitem_Selector piwSelector = (Pricing_ProcessInstanceWorkitem_Selector) mocks.mock(Pricing_ProcessInstanceWorkitem_Selector.class);
        
        //creating a list of record which will be returned when the method from the controller will be called.
        //there will be no need o insert the record since we will be using stub.
        SBQQ__Quote__c quotes = new SBQQ__Quote__c();
        quotes.SBQQ__Status__c = 'Draft';
        quotes.OwnerId = UserInfo.getUserId();
        quotes.CreatedById = UserInfo.getUserId();
        quotes.SBQQ__Account__c = fflib_IDGenerator.generate(Schema.Account.SObjectType);
        quotes.id = fflib_IDGenerator.generate(Schema.SBQQ__Quote__c.SObjectType);
        
        List<SBQQ__QuoteLine__c> quotelines = new List<SBQQ__QuoteLine__c>();
        SBQQ__QuoteLine__c qli1 = new SBQQ__QuoteLine__c();
        qli1.SBQQ__Quote__r = quotes;
        qli1.Pricing_Status_Nm__c = 'Draft';
        qli1.Pricing_Sales_Rep__c = UserInfo.getUserId();
        qli1.CreatedById = UserInfo.getUserId();
        qli1.Pricing_Primary_Contact_Nm__c = UserInfo.getUserId();
        qli1.Pricing_Change_Request_cb__c = false;
        qli1.id = fflib_IDGenerator.generate(Schema.SBQQ__QuoteLine__c.SObjectType);
        quotelines.add(qli1);
        
        SBQQ__QuoteLine__c qli2 = new SBQQ__QuoteLine__c();
        qli2.SBQQ__Quote__r = quotes;
        qli2.Pricing_Status_Nm__c = 'Pending Intel Field Review';
        qli2.Pricing_Sales_Rep__c = UserInfo.getUserId();
        qli2.CreatedById = UserInfo.getUserId();
        qli2.Pricing_Primary_Contact_Nm__c = UserInfo.getUserId();
        qli2.Pricing_Change_Request_cb__c = false;
        qli2.id = fflib_IDGenerator.generate(Schema.SBQQ__QuoteLine__c.SObjectType);
        quotelines.add(qli2);
        
        SBQQ__QuoteLine__c qli3 = new SBQQ__QuoteLine__c();
        qli3.SBQQ__Quote__r = quotes;
        qli3.Pricing_Status_Nm__c = 'Pending Further Intel Review';
        qli3.Pricing_Sales_Rep__c = UserInfo.getUserId();
        qli3.CreatedById = UserInfo.getUserId();
        qli3.Pricing_Primary_Contact_Nm__c = UserInfo.getUserId();
        qli3.Pricing_Change_Request_cb__c = false;
        qli3.id = fflib_IDGenerator.generate(Schema.SBQQ__QuoteLine__c.SObjectType);
        quotelines.add(qli3);
        
        SBQQ__QuoteLine__c qli4 = new SBQQ__QuoteLine__c();
        qli4.SBQQ__Quote__r = quotes;
        qli4.Pricing_Status_Nm__c = 'Approved';
        qli4.Pricing_Sales_Rep__c = UserInfo.getUserId();
        qli4.CreatedById = UserInfo.getUserId();
        qli4.Pricing_Primary_Contact_Nm__c = UserInfo.getUserId();
        qli4.Pricing_Change_Request_cb__c = false;
        qli4.Pricing_Integration_Status_Nm__c = 'Pending';
        qli4.Pricing_Deal_RFQ_Status_Nm__c = 'Pending';
        qli4.Pricing_Deal_RFQ_Id__c = 'Test001';
        qli4.id = fflib_IDGenerator.generate(Schema.SBQQ__QuoteLine__c.SObjectType);
        quotelines.add(qli4);
        
        SBQQ__QuoteLine__c qli5 = new SBQQ__QuoteLine__c();
        qli5.SBQQ__Quote__r = quotes;
        qli5.Pricing_Status_Nm__c = 'Won';
        qli5.Pricing_Sales_Rep__c = UserInfo.getUserId();
        qli5.CreatedById = UserInfo.getUserId();
        qli5.Pricing_Primary_Contact_Nm__c = UserInfo.getUserId();
        qli5.Pricing_Change_Request_cb__c = false;
        qli5.id = fflib_IDGenerator.generate(Schema.SBQQ__QuoteLine__c.SObjectType);
        quotelines.add(qli5);
        
        SBQQ__QuoteLine__c qli6 = new SBQQ__QuoteLine__c();
        qli6.SBQQ__Quote__r = quotes;
        qli6.Pricing_Status_Nm__c = 'Lost';
        qli6.Pricing_Sales_Rep__c = UserInfo.getUserId();
        qli6.CreatedById = UserInfo.getUserId();
        qli6.Pricing_Primary_Contact_Nm__c = UserInfo.getUserId();
        qli6.Pricing_Change_Request_cb__c = false;
        qli6.Pricing_Approved_End_Date_Dt__c = System.today()+3;
        qli6.id = fflib_IDGenerator.generate(Schema.SBQQ__QuoteLine__c.SObjectType);
        quotelines.add(qli6);
        
        SBQQ__QuoteLine__c qli7 = new SBQQ__QuoteLine__c();
        qli7.SBQQ__Quote__r = quotes;
        qli7.Pricing_Status_Nm__c = 'Pending Further Intel Review';
        qli7.Pricing_Sales_Rep__c = UserInfo.getUserId();
        qli7.CreatedById = UserInfo.getUserId();
        qli7.Pricing_Primary_Contact_Nm__c = UserInfo.getUserId();
        qli7.Pricing_Change_Request_cb__c = false;
        qli7.Pricing_Approved_End_Date_Dt__c = System.today()+3;
        qli7.Pricing_Integration_Status_Nm__c = Label.Pricing_Tender_MyDeal_Integration_Status_Error;
        qli7.Pricing_Deal_RFQ_Status_Nm__c = '';
        qli4.Pricing_Deal_RFQ_Id__c = '';
        qli7.id = fflib_IDGenerator.generate(Schema.SBQQ__QuoteLine__c.SObjectType);
        quotelines.add(qli7);
        
        List<User> usrLst = new List<User>();
        
        //starting the stub where we will tell the mock class that when this selector query is called from
        //controller method the record created above should be returned.
        mocks.startStubbing();
        //next line is mandatory for all selector stubbing since in the fflib_Application there is mockSobject map which 
        //maps the sobject to the mock class created.
        mocks.when(qliSelector.sObjectType()).thenReturn(Schema.SBQQ__QuoteLine__c.SObjectType);
        //here we are defining the return record which the query should return when the same argument is passed from the 
        //controller class on test execution
        mocks.when(qliSelector.selectByQuoteLineIds(new Set<Id>{quotelines[0].id})).thenReturn(new List<SBQQ__QuoteLine__c>{quotelines[0]});
        //mocks.when(qliSelector.selectByQuoteLineIds(new Set<Id>{quotelines[0].id})).thenReturn(new List<SBQQ__QuoteLine__c>{quotelines[0]});
        mocks.when(qliSelector.selectByQuoteLineIds(new Set<Id>{quotelines[1].id})).thenReturn(new List<SBQQ__QuoteLine__c>{quotelines[1]});
        //mocks.when(qliSelector.selectByQuoteLineIds(new Set<Id>{quotelines[1].id})).thenReturn(new List<SBQQ__QuoteLine__c>{quotelines[1]});
        mocks.when(qliSelector.selectByQuoteLineIds(new Set<Id>{quotelines[2].id})).thenReturn(new List<SBQQ__QuoteLine__c>{quotelines[2]});
        // mocks.when(qliSelector.selectByQuoteLineIds(new Set<Id>{quotelines[2].id})).thenReturn(new List<SBQQ__QuoteLine__c>{quotelines[2]});
        mocks.when(qliSelector.selectByQuoteLineIds(new Set<Id>{quotelines[3].id})).thenReturn(new List<SBQQ__QuoteLine__c>{quotelines[3]});
        // mocks.when(qliSelector.selectByQuoteLineIds(new Set<Id>{quotelines[3].id})).thenReturn(new List<SBQQ__QuoteLine__c>{quotelines[3]});
        mocks.when(qliSelector.selectByQuoteLineIds(new Set<Id>{quotelines[4].id})).thenReturn(new List<SBQQ__QuoteLine__c>{quotelines[4]});
        //mocks.when(qliSelector.selectByQuoteLineIds(new Set<Id>{quotelines[4].id})).thenReturn(new List<SBQQ__QuoteLine__c>{quotelines[4]});
        mocks.when(qliSelector.selectByQuoteLineIds(new Set<Id>{quotelines[5].id})).thenReturn(new List<SBQQ__QuoteLine__c>{quotelines[5]});
        //mocks.when(qliSelector.selectByQuoteLineIds(new Set<Id>{quotelines[5].id})).thenReturn(new List<SBQQ__QuoteLine__c>{quotelines[5]});
        mocks.when(qliSelector.selectByQuoteLineIds(new Set<Id>{quotelines[6].id})).thenReturn(new List<SBQQ__QuoteLine__c>{quotelines[6]});
        mocks.when(psaSelector.sObjectType()).thenReturn(Schema.PermissionSetAssignment.SObjectType);
        mocks.when(psaSelector.selectByName(UserInfo.getUserId(),new Set < String > {'Pricing_Tender_IT_Specialist', 'Pricing_Tender_Partner_Administrator', 'Pricing_Tender_Regional_Pricing_Manager', 'Tender_Account_Executive', 'Tender_Partner', 'Tender_Partner_Drafter_Access', 'Tender_Partner_Drafter_Limited_Access', 'Tender_User'})).thenReturn(true);
        mocks.when(psaSelector.selectByName(UserInfo.getUserId(),new Set < String > {Label.Pricing_Tender_PermissionSets_TenderUser})).thenReturn(true);
        mocks.when(psaSelector.selectByName(UserInfo.getUserId(),new Set < String > {Label.Pricing_Tender_PermissionSets_PricingTenderRegionalPricingManager})).thenReturn(true);
        mocks.when(psaSelector.selectByName(UserInfo.getUserId(),new Set < String > {'Pricing_Tender_Partner_Administrator', 'Tender_Partner', 'Tender_Partner_Drafter_Access'})).thenReturn(true);
        mocks.when(psaSelector.selectByName(UserInfo.getUserId(),new Set < String > {'Pricing_Tender_Partner_Administrator', 'Tender_Partner', 'Tender_Partner_Drafter_Access', 'Tender_Partner_Drafter_Limited_Access', 'Tender_User'})).thenReturn(true);
        mocks.when(usrSelector.sObjectType()).thenReturn(Schema.User.SObjectType);
        mocks.when(usrSelector.selectbyUserId((Id) fflib_Match.anyObject())).thenReturn(usrLst);
        mocks.when(restSelector.sObjectType()).thenReturn(Schema.Pricing_QuoteLine_WonLoss_Restriction__mdt.SObjectType);
        mocks.when(restSelector.selectByAccountIds((Id) fflib_Match.anyObject())).thenReturn(1);
        mocks.when(piwSelector.sObjectType()).thenReturn(Schema.ProcessInstanceWorkitem.SObjectType);
        mocks.when(piwSelector.selectbyQliIdandStatus(quotelines[1].id,'Pending')).thenReturn(new List<ProcessInstanceWorkitem>());
        mocks.stopStubbing();
        //c0alling setMock method to map the sobject with the mock class generated using ApexMocks.
        Pricing_IQR_Application.Selector.setMock(qliSelector);
        Pricing_IQR_Application.Selector.setMock(psaSelector);
        Pricing_IQR_Application.Selector.setMock(usrSelector);
        Pricing_IQR_Application.Selector.setMock(restSelector);
        Pricing_IQR_Application.Selector.setMock(piwSelector);
        
        System.Test.startTest();
        Pricing_QuoteLineController_Mock.getAvailableUserActions(quotelines[0].id);
        Pricing_QuoteLineController_Mock.getAvailableUserActions(quotelines[1].id);
        Pricing_QuoteLineController_Mock.getAvailableUserActions(quotelines[2].id); 
        Pricing_QuoteLineController_Mock.getAvailableUserActions(quotelines[3].id); 
        Pricing_QuoteLineController_Mock.getAvailableUserActions(quotelines[4].id); 
        Pricing_QuoteLineController_Mock.getAvailableUserActions(quotelines[5].id);
        Pricing_QuoteLineController_Mock.getAvailableUserActions(quotelines[6].id);
        System.Test.stopTest();
        // using verify method which works same as the assert
        // here it check that the selector method is called how many times.     
        ((Pricing_QuoteLines_Selector) mocks.verify(qliSelector,2)).selectByQuoteLineIds(new Set<Id>{quotelines[1].id});
        ((Pricing_PermissionSetAssignment_Selector) mocks.verify(psaSelector,8)).selectByName(UserInfo.getUserId(),new Set < String > {'Pricing_Tender_IT_Specialist', 'Pricing_Tender_Partner_Administrator', 'Pricing_Tender_Regional_Pricing_Manager', 'Tender_Account_Executive', 'Tender_Partner', 'Tender_Partner_Drafter_Access', 'Tender_Partner_Drafter_Limited_Access', 'Tender_User'});
        ((Pricing_User_Selector) mocks.verify(usrSelector,7)).selectbyUserId((Id) fflib_Match.anyObject());
        System.debug('Number of Queries used in this apex code so far: ' + Limits.getQueries());
    }    
    
    @istest
    static void test_deleteRecord(){
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork uowMock = new fflib_SObjectMocks.SObjectUnitOfWork(mocks);
        
        Pricing_QuoteLines_Selector quoteLineSelectorMock = (Pricing_QuoteLines_Selector) mocks.mock(Pricing_QuoteLines_Selector.class);
        Pricing_Quote_Line_Status_Age_Selector tptSelectorMock = (Pricing_Quote_Line_Status_Age_Selector) mocks.mock(Pricing_Quote_Line_Status_Age_Selector.class);
        
        SBQQ__QuoteLine__c qli = new SBQQ__QuoteLine__c();
        qli.id = fflib_IDGenerator.generate(Schema.SBQQ__QuoteLine__c.SObjectType);
        
        Pricing_Quote_Line_Status_Age__c tpt = new Pricing_Quote_Line_Status_Age__c();
        tpt.id = fflib_IDGenerator.generate(Schema.Pricing_Quote_Line_Status_Age__c.SObjectType);
        tpt.Pricing_TPT_Quote_Line_Number__c = qli.id;
        
        mocks.startStubbing();
        
        mocks.when(quoteLineSelectorMock.sObjectType()).thenReturn(Schema.SBQQ__QuoteLine__c.SObjectType);
        mocks.when(tptSelectorMock.sObjectType()).thenReturn(Schema.Pricing_Quote_Line_Status_Age__c.SObjectType);
        mocks.when(quoteLineSelectorMock.selectByQuoteLineIds(new Set<Id>{qli.id})).thenReturn(new List<SBQQ__QuoteLine__c>{qli});
        mocks.when(tptSelectorMock.selectbyQliId(qli.id)).thenReturn(new List<Pricing_Quote_Line_Status_Age__c>{tpt});
        
        mocks.stopStubbing();
        
        Pricing_IQR_Application.unitOfWork.setMock(uowMock);
        Pricing_IQR_Application.Selector.setMock(quoteLineSelectorMock);
        Pricing_IQR_Application.Selector.setMock(tptSelectorMock);
        
        Test.startTest();
        Pricing_QuoteLineController_Mock.deleteRecord(qli.id);
        Pricing_QuoteLineController_Mock.cancelRecord(qli.id);
        Test.stopTest();
        
        System.debug('Number of Queries used in this apex code so far: ' + Limits.getQueries());
        System.debug('Number of Queries used in this apex code so far: ' + Limits.getDmlStatements());
    }
    
    @istest
    static void test_isPartnerUser(){
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        
        Pricing_PermissionSetAssignment_Selector psaSelector = (Pricing_PermissionSetAssignment_Selector) mocks.mock(Pricing_PermissionSetAssignment_Selector.class);
        
        Set < String > extPersona = new Set < String > {Label.Pricing_Tender_PermissionSets_TenderPartner};
            extPersona.add(Label.Pricing_Tender_PermissionSets_PricingTenderPartnerAdministrator);
        extPersona.add(Label.Pricing_Tender_PermissionSets_TenderDrafter);
        extPersona.add(Label.Pricing_Tender_PermissionSets_TenderDrafterLimited); 
        
        mocks.startStubbing();
        
        mocks.when(psaSelector.sObjectType()).thenReturn(Schema.PermissionSetAssignment.SObjectType);
        mocks.when(psaSelector.selectByName(UserInfo.getUserId(),extPersona)).thenReturn(true);
        
        mocks.stopStubbing();
        
        Pricing_IQR_Application.Selector.setMock(psaSelector);
        
        Test.startTest();
        Pricing_QuoteLineController_Mock.isPartnerUser();
        Test.stopTest();
        
        System.debug('Number of Queries used in this apex code so far: ' + Limits.getQueries());
        System.debug('Number of Queries used in this apex code so far: ' + Limits.getDmlStatements());
    }
    
    @isTest
    static void test_recordApprovalFSEApprove(){
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork uowMock = new fflib_SObjectMocks.SObjectUnitOfWork(mocks);
        
        Pricing_QuoteLines_Selector qliSelector = (Pricing_QuoteLines_Selector) mocks.mock(Pricing_QuoteLines_Selector.class);
        Pricing_PermissionSetAssignment_Selector psaSelector = (Pricing_PermissionSetAssignment_Selector) mocks.mock(Pricing_PermissionSetAssignment_Selector.class);        
        Pricing_User_Selector usrSelector = (Pricing_User_Selector) mocks.mock(Pricing_User_Selector.class);
        
        List<User> usrLst = new List<User>();
        User usr = new User();
        usr.Id = fflib_IDGenerator.generate(Schema.User.SObjectType);
        usr.ContactId = fflib_IDGenerator.generate(Schema.Contact.SObjectType);
        usrLst.add(usr);
        
        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        quote.id = fflib_IDGenerator.generate(Schema.SBQQ__Quote__c.SObjectType);
        quote.SBQQ__PrimaryContact__c = usrLst[0].ContactId;
        
        SBQQ__QuoteLine__c qli = new SBQQ__QuoteLine__c();
        qli.SBQQ__Quote__r = quote;
        qli.Pricing_Status_Nm__c = 'Pending Intel Field Review';
        qli.Pricing_Sales_Rep__c = usrLst[0].id;
        qli.CreatedById = UserInfo.getUserId();
        qli.Pricing_Primary_Contact_Nm__c = usrLst[0].id;
        qli.Pricing_Change_Request_cb__c = false;
        qli.id = fflib_IDGenerator.generate(Schema.SBQQ__QuoteLine__c.SObjectType);
        
        mocks.startStubbing();
        
        mocks.when(qliSelector.sObjectType()).thenReturn(Schema.SBQQ__QuoteLine__c.SObjectType);
        mocks.when(qliSelector.selectByQuoteLineIds(new Set<Id>{qli.id})).thenReturn(new List<SBQQ__QuoteLine__c>{qli});
        
        mocks.when(psaSelector.sObjectType()).thenReturn(Schema.PermissionSetAssignment.SObjectType);
        mocks.when(psaSelector.selectByName(UserInfo.getUserId(),new Set < String > {Label.Pricing_Tender_PermissionSets_TenderUser})).thenReturn(true);
        
        mocks.when(usrSelector.sObjectType()).thenReturn(Schema.User.SObjectType);
        mocks.when(usrSelector.selectbyContactId((Id) fflib_Match.anyObject())).thenReturn(usrLst);
        mocks.stopStubbing();
        
        Pricing_IQR_Application.unitOfWork.setMock(uowMock);
        Pricing_IQR_Application.Selector.setMock(qliSelector);
        Pricing_IQR_Application.Selector.setMock(psaSelector);
        Pricing_IQR_Application.Selector.setMock(usrSelector);
        
        System.Test.startTest();
        Pricing_QuoteLineController_Mock.recordApproval(qli.id ,'comments', Label.Pricing_Tender_QuoteLine_Action_Approve, qli, null, null);
        System.Test.stopTest();
        
        System.debug('Number of Queries used in this apex code so far: ' + Limits.getQueries());
    }
    
    @isTest
    static void test_recordApprovalFSERevisionOEM(){
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork uowMock = new fflib_SObjectMocks.SObjectUnitOfWork(mocks);
        
        Pricing_QuoteLines_Selector qliSelector = (Pricing_QuoteLines_Selector) mocks.mock(Pricing_QuoteLines_Selector.class);
        Pricing_PermissionSetAssignment_Selector psaSelector = (Pricing_PermissionSetAssignment_Selector) mocks.mock(Pricing_PermissionSetAssignment_Selector.class);        
        Pricing_User_Selector usrSelector = (Pricing_User_Selector) mocks.mock(Pricing_User_Selector.class);
        
        List<User> usrLst = new List<User>();
        User usr = new User();
        usr.Id = fflib_IDGenerator.generate(Schema.User.SObjectType);
        usr.ContactId = fflib_IDGenerator.generate(Schema.Contact.SObjectType);
        usrLst.add(usr);
        
        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        quote.id = fflib_IDGenerator.generate(Schema.SBQQ__Quote__c.SObjectType);
        quote.SBQQ__PrimaryContact__c = usrLst[0].ContactId;
        
        SBQQ__QuoteLine__c qli = new SBQQ__QuoteLine__c();
        qli.SBQQ__Quote__r = quote;
        qli.Pricing_Status_Nm__c = 'Pending Intel Field Review';
        qli.Pricing_Sales_Rep__c = usrLst[0].id;
        qli.CreatedById = UserInfo.getUserId();
        qli.Pricing_Primary_Contact_Nm__c = usrLst[0].id;
        qli.Pricing_Change_Request_cb__c = false;
        qli.id = fflib_IDGenerator.generate(Schema.SBQQ__QuoteLine__c.SObjectType);
        
        mocks.startStubbing();
        
        mocks.when(qliSelector.sObjectType()).thenReturn(Schema.SBQQ__QuoteLine__c.SObjectType);
        mocks.when(qliSelector.selectByQuoteLineIds(new Set<Id>{qli.id})).thenReturn(new List<SBQQ__QuoteLine__c>{qli});
        
        mocks.when(psaSelector.sObjectType()).thenReturn(Schema.PermissionSetAssignment.SObjectType);
        mocks.when(psaSelector.selectByName(UserInfo.getUserId(),new Set < String > {Label.Pricing_Tender_PermissionSets_TenderUser})).thenReturn(true);
        
        mocks.when(usrSelector.sObjectType()).thenReturn(Schema.User.SObjectType);
        mocks.when(usrSelector.selectbyContactId((Id) fflib_Match.anyObject())).thenReturn(usrLst);
        mocks.stopStubbing();
        
        Pricing_IQR_Application.unitOfWork.setMock(uowMock);
        Pricing_IQR_Application.Selector.setMock(qliSelector);
        Pricing_IQR_Application.Selector.setMock(psaSelector);
        Pricing_IQR_Application.Selector.setMock(usrSelector);
        
        System.Test.startTest();
        Pricing_QuoteLineController_Mock.recordApproval(qli.id ,'comments', Label.Pricing_Tender_QuoteLine_Action_RevisionRequiredbyOEM, qli, 'revision', true);
        System.Test.stopTest();
        
        System.debug('Number of Queries used in this apex code so far: ' + Limits.getQueries());
    }
    
    @isTest
    static void test_recordApprovalFSERevisionRPM(){
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork uowMock = new fflib_SObjectMocks.SObjectUnitOfWork(mocks);
        
        Pricing_QuoteLines_Selector qliSelector = (Pricing_QuoteLines_Selector) mocks.mock(Pricing_QuoteLines_Selector.class);
        Pricing_PermissionSetAssignment_Selector psaSelector = (Pricing_PermissionSetAssignment_Selector) mocks.mock(Pricing_PermissionSetAssignment_Selector.class);        
        Pricing_User_Selector usrSelector = (Pricing_User_Selector) mocks.mock(Pricing_User_Selector.class);
        
        List<User> usrLst = new List<User>();
        User usr = new User();
        usr.Id = fflib_IDGenerator.generate(Schema.User.SObjectType);
        usr.ContactId = fflib_IDGenerator.generate(Schema.Contact.SObjectType);
        usrLst.add(usr);
        
        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        quote.id = fflib_IDGenerator.generate(Schema.SBQQ__Quote__c.SObjectType);
        quote.SBQQ__PrimaryContact__c = usrLst[0].ContactId;
        
        SBQQ__QuoteLine__c qli = new SBQQ__QuoteLine__c();
        qli.SBQQ__Quote__r = quote;
        qli.Pricing_Status_Nm__c = 'Pending Intel Field Review';
        qli.Pricing_Sales_Rep__c = usrLst[0].id;
        qli.CreatedById = UserInfo.getUserId();
        qli.Pricing_Primary_Contact_Nm__c = usrLst[0].id;
        qli.Pricing_Change_Request_cb__c = false;
        qli.id = fflib_IDGenerator.generate(Schema.SBQQ__QuoteLine__c.SObjectType);
        
        mocks.startStubbing();
        
        mocks.when(qliSelector.sObjectType()).thenReturn(Schema.SBQQ__QuoteLine__c.SObjectType);
        mocks.when(qliSelector.selectByQuoteLineIds(new Set<Id>{qli.id})).thenReturn(new List<SBQQ__QuoteLine__c>{qli});
        
        mocks.when(psaSelector.sObjectType()).thenReturn(Schema.PermissionSetAssignment.SObjectType);
        mocks.when(psaSelector.selectByName(UserInfo.getUserId(),new Set < String > {Label.Pricing_Tender_PermissionSets_TenderUser})).thenReturn(true);
        
        mocks.when(usrSelector.sObjectType()).thenReturn(Schema.User.SObjectType);
        mocks.when(usrSelector.selectbyContactId((Id) fflib_Match.anyObject())).thenReturn(usrLst);
        mocks.stopStubbing();
        
        Pricing_IQR_Application.unitOfWork.setMock(uowMock);
        Pricing_IQR_Application.Selector.setMock(qliSelector);
        Pricing_IQR_Application.Selector.setMock(psaSelector);
        Pricing_IQR_Application.Selector.setMock(usrSelector);
        
        System.Test.startTest();
        Pricing_QuoteLineController_Mock.recordApproval(qli.id ,'comments', Label.Pricing_Tender_QuoteLine_Action_RevisionRequiredbyField, qli,'revision', true);
        System.Test.stopTest();
        
        System.debug('Number of Queries used in this apex code so far: ' + Limits.getQueries());
    }
    
    @isTest
    static void test_recordApprovalFSEReject(){
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork uowMock = new fflib_SObjectMocks.SObjectUnitOfWork(mocks);
        
        Pricing_QuoteLines_Selector qliSelector = (Pricing_QuoteLines_Selector) mocks.mock(Pricing_QuoteLines_Selector.class);
        Pricing_PermissionSetAssignment_Selector psaSelector = (Pricing_PermissionSetAssignment_Selector) mocks.mock(Pricing_PermissionSetAssignment_Selector.class);        
        Pricing_User_Selector usrSelector = (Pricing_User_Selector) mocks.mock(Pricing_User_Selector.class);
        
        List<User> usrLst = new List<User>();
        User usr = new User();
        usr.Id = fflib_IDGenerator.generate(Schema.User.SObjectType);
        usr.ContactId = fflib_IDGenerator.generate(Schema.Contact.SObjectType);
        usrLst.add(usr);
        
        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        quote.id = fflib_IDGenerator.generate(Schema.SBQQ__Quote__c.SObjectType);
        quote.SBQQ__PrimaryContact__c = usrLst[0].ContactId;
        
        SBQQ__QuoteLine__c qli = new SBQQ__QuoteLine__c();
        qli.SBQQ__Quote__r = quote;
        qli.Pricing_Status_Nm__c = 'Pending Intel Field Review';
        qli.Pricing_Sales_Rep__c = usrLst[0].id;
        qli.CreatedById = UserInfo.getUserId();
        qli.Pricing_Primary_Contact_Nm__c = usrLst[0].id;
        qli.Pricing_Change_Request_cb__c = false;
        qli.id = fflib_IDGenerator.generate(Schema.SBQQ__QuoteLine__c.SObjectType);
        
        mocks.startStubbing();
        
        mocks.when(qliSelector.sObjectType()).thenReturn(Schema.SBQQ__QuoteLine__c.SObjectType);
        mocks.when(qliSelector.selectByQuoteLineIds(new Set<Id>{qli.id})).thenReturn(new List<SBQQ__QuoteLine__c>{qli});
        
        mocks.when(psaSelector.sObjectType()).thenReturn(Schema.PermissionSetAssignment.SObjectType);
        mocks.when(psaSelector.selectByName(UserInfo.getUserId(),new Set < String > {Label.Pricing_Tender_PermissionSets_TenderUser})).thenReturn(true);
        
        mocks.when(usrSelector.sObjectType()).thenReturn(Schema.User.SObjectType);
        mocks.when(usrSelector.selectbyContactId((Id) fflib_Match.anyObject())).thenReturn(usrLst);
        mocks.stopStubbing();
        
        Pricing_IQR_Application.unitOfWork.setMock(uowMock);
        Pricing_IQR_Application.Selector.setMock(qliSelector);
        Pricing_IQR_Application.Selector.setMock(psaSelector);
        Pricing_IQR_Application.Selector.setMock(usrSelector);
        
        System.Test.startTest();
        Pricing_QuoteLineController_Mock.recordApproval(qli.id ,'comments', Label.Pricing_Tender_QuoteLine_Action_Reject, qli, null, null);
        System.Test.stopTest();
        
        System.debug('Number of Queries used in this apex code so far: ' + Limits.getQueries());
    }
    
    @isTest
    static void test_recordApprovalRPMApprove(){
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork uowMock = new fflib_SObjectMocks.SObjectUnitOfWork(mocks);
        
        Pricing_QuoteLines_Selector qliSelector = (Pricing_QuoteLines_Selector) mocks.mock(Pricing_QuoteLines_Selector.class);
        Pricing_PermissionSetAssignment_Selector psaSelector = (Pricing_PermissionSetAssignment_Selector) mocks.mock(Pricing_PermissionSetAssignment_Selector.class);        
        Pricing_User_Selector usrSelector = (Pricing_User_Selector) mocks.mock(Pricing_User_Selector.class);
        
        List<User> usrLst = new List<User>();
        User usr = new User();
        usr.ContactId = fflib_IDGenerator.generate(Schema.Contact.SObjectType);
        usrLst.add(usr);
        
        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        quote.id = fflib_IDGenerator.generate(Schema.SBQQ__Quote__c.SObjectType);
        quote.SBQQ__PrimaryContact__c = usrLst[0].ContactId;
        
        SBQQ__QuoteLine__c qli5 = new SBQQ__QuoteLine__c();
        qli5.SBQQ__Quote__r = quote;
        qli5.Pricing_Status_Nm__c = 'Won';
        qli5.Pricing_Sales_Rep__c = usrLst[0].id;
        qli5.CreatedById = UserInfo.getUserId();
        qli5.Pricing_Primary_Contact_Nm__c = usrLst[0].id;
        qli5.Pricing_Change_Request_cb__c = false;
        qli5.id = fflib_IDGenerator.generate(Schema.SBQQ__QuoteLine__c.SObjectType);
        
        SBQQ__QuoteLine__c qli = new SBQQ__QuoteLine__c();
        qli.SBQQ__Quote__r = quote;
        qli.Pricing_Status_Nm__c = 'Pending Further Intel Review';
        qli.Pricing_Sales_Rep__c = usrLst[0].id;
        qli.CreatedById = UserInfo.getUserId();
        qli.Pricing_Primary_Contact_Nm__c = usrLst[0].id;
        qli.Pricing_Change_Request_cb__c = true;
        qli.Pricing_Reference_Quote_Line_Nbr__c = qli5.id;
        qli.id = fflib_IDGenerator.generate(Schema.SBQQ__QuoteLine__c.SObjectType);
        
        mocks.startStubbing();
        
        mocks.when(qliSelector.sObjectType()).thenReturn(Schema.SBQQ__QuoteLine__c.SObjectType);
        mocks.when(qliSelector.selectByQuoteLineIds(new Set<Id>{qli.id})).thenReturn(new List<SBQQ__QuoteLine__c>{qli});
        mocks.when(qliSelector.selectByQuoteLineIds(new Set<Id>{qli5.id})).thenReturn(new List<SBQQ__QuoteLine__c>{qli5});
        
        mocks.when(psaSelector.sObjectType()).thenReturn(Schema.PermissionSetAssignment.SObjectType);
        mocks.when(psaSelector.selectByName(UserInfo.getUserId(),new Set < String > {Label.Pricing_Tender_PermissionSets_TenderUser})).thenReturn(false);
        
        mocks.when(usrSelector.sObjectType()).thenReturn(Schema.User.SObjectType);
        mocks.when(usrSelector.selectbyContactId((Id) fflib_Match.anyObject())).thenReturn(usrLst);
        mocks.stopStubbing();
        
        Pricing_IQR_Application.unitOfWork.setMock(uowMock);
        Pricing_IQR_Application.Selector.setMock(qliSelector);
        Pricing_IQR_Application.Selector.setMock(psaSelector);
        Pricing_IQR_Application.Selector.setMock(usrSelector);
        
        System.Test.startTest();
        Pricing_QuoteLineController_Mock.recordApproval(qli.id ,'comments', Label.Pricing_Tender_QuoteLine_Action_Approve, qli, null, null);
        System.Test.stopTest();
        
        System.debug('Number of Queries used in this apex code so far: ' + Limits.getQueries());
    }
    
    @isTest
    static void test_recordApprovalRPMRevisionOEM(){
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork uowMock = new fflib_SObjectMocks.SObjectUnitOfWork(mocks);
        
        Pricing_QuoteLines_Selector qliSelector = (Pricing_QuoteLines_Selector) mocks.mock(Pricing_QuoteLines_Selector.class);
        Pricing_PermissionSetAssignment_Selector psaSelector = (Pricing_PermissionSetAssignment_Selector) mocks.mock(Pricing_PermissionSetAssignment_Selector.class);        
        Pricing_User_Selector usrSelector = (Pricing_User_Selector) mocks.mock(Pricing_User_Selector.class);
        
        List<User> usrLst = new List<User>();
        User usr = new User();
        usr.ContactId = fflib_IDGenerator.generate(Schema.Contact.SObjectType);
        usrLst.add(usr);
        
        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        quote.id = fflib_IDGenerator.generate(Schema.SBQQ__Quote__c.SObjectType);
        quote.SBQQ__PrimaryContact__c = usrLst[0].ContactId;
        
        SBQQ__QuoteLine__c qli5 = new SBQQ__QuoteLine__c();
        qli5.SBQQ__Quote__r = quote;
        qli5.Pricing_Status_Nm__c = 'Won';
        qli5.Pricing_Sales_Rep__c = usrLst[0].id;
        qli5.CreatedById = UserInfo.getUserId();
        qli5.Pricing_Primary_Contact_Nm__c = usrLst[0].id;
        qli5.Pricing_Change_Request_cb__c = false;
        qli5.id = fflib_IDGenerator.generate(Schema.SBQQ__QuoteLine__c.SObjectType);
        
        SBQQ__QuoteLine__c qli = new SBQQ__QuoteLine__c();
        qli.SBQQ__Quote__r = quote;
        qli.Pricing_Status_Nm__c = 'Pending Further Intel Review';
        qli.Pricing_Sales_Rep__c = usrLst[0].id;
        qli.CreatedById = UserInfo.getUserId();
        qli.Pricing_Primary_Contact_Nm__c = usrLst[0].id;
        qli.Pricing_Change_Request_cb__c = true;
        qli.Pricing_Reference_Quote_Line_Nbr__c = qli5.id;
        qli.id = fflib_IDGenerator.generate(Schema.SBQQ__QuoteLine__c.SObjectType);
        
        mocks.startStubbing();
        
        mocks.when(qliSelector.sObjectType()).thenReturn(Schema.SBQQ__QuoteLine__c.SObjectType);
        mocks.when(qliSelector.selectByQuoteLineIds(new Set<Id>{qli.id})).thenReturn(new List<SBQQ__QuoteLine__c>{qli});
        mocks.when(qliSelector.selectByQuoteLineIds(new Set<Id>{qli5.id})).thenReturn(new List<SBQQ__QuoteLine__c>{qli5});
        
        mocks.when(psaSelector.sObjectType()).thenReturn(Schema.PermissionSetAssignment.SObjectType);
        mocks.when(psaSelector.selectByName(UserInfo.getUserId(),new Set < String > {Label.Pricing_Tender_PermissionSets_TenderUser})).thenReturn(false);
        
        mocks.when(usrSelector.sObjectType()).thenReturn(Schema.User.SObjectType);
        mocks.when(usrSelector.selectbyContactId((Id) fflib_Match.anyObject())).thenReturn(usrLst);
        mocks.stopStubbing();
        
        Pricing_IQR_Application.unitOfWork.setMock(uowMock);
        Pricing_IQR_Application.Selector.setMock(qliSelector);
        Pricing_IQR_Application.Selector.setMock(psaSelector);
        Pricing_IQR_Application.Selector.setMock(usrSelector);
        
        System.Test.startTest();
        Pricing_QuoteLineController_Mock.recordApproval(qli.id ,'comments', Label.Pricing_Tender_QuoteLine_Action_RevisionRequiredbyOEM, qli, 'revision', true);
        System.Test.stopTest();
        
        System.debug('Number of Queries used in this apex code so far: ' + Limits.getQueries());
    }
    
    @isTest
    static void test_recordApprovalRPMRevisionFSE(){
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork uowMock = new fflib_SObjectMocks.SObjectUnitOfWork(mocks);
        
        Pricing_QuoteLines_Selector qliSelector = (Pricing_QuoteLines_Selector) mocks.mock(Pricing_QuoteLines_Selector.class);
        Pricing_PermissionSetAssignment_Selector psaSelector = (Pricing_PermissionSetAssignment_Selector) mocks.mock(Pricing_PermissionSetAssignment_Selector.class);        
        Pricing_User_Selector usrSelector = (Pricing_User_Selector) mocks.mock(Pricing_User_Selector.class);
        
        List<User> usrLst = new List<User>();
        User usr = new User();
        usr.ContactId = fflib_IDGenerator.generate(Schema.Contact.SObjectType);
        usrLst.add(usr);
        
        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        quote.id = fflib_IDGenerator.generate(Schema.SBQQ__Quote__c.SObjectType);
        quote.SBQQ__PrimaryContact__c = usrLst[0].ContactId;
        
        SBQQ__QuoteLine__c qli5 = new SBQQ__QuoteLine__c();
        qli5.SBQQ__Quote__r = quote;
        qli5.Pricing_Status_Nm__c = 'Won';
        qli5.Pricing_Sales_Rep__c = usrLst[0].id;
        qli5.CreatedById = UserInfo.getUserId();
        qli5.Pricing_Primary_Contact_Nm__c = usrLst[0].id;
        qli5.Pricing_Change_Request_cb__c = false;
        qli5.id = fflib_IDGenerator.generate(Schema.SBQQ__QuoteLine__c.SObjectType);
        
        SBQQ__QuoteLine__c qli = new SBQQ__QuoteLine__c();
        qli.SBQQ__Quote__r = quote;
        qli.Pricing_Status_Nm__c = 'Pending Further Intel Review';
        qli.Pricing_Sales_Rep__c = usrLst[0].id;
        qli.CreatedById = UserInfo.getUserId();
        qli.Pricing_Primary_Contact_Nm__c = usrLst[0].id;
        qli.Pricing_Change_Request_cb__c = true;
        qli.Pricing_Reference_Quote_Line_Nbr__c = qli5.id;
        qli.id = fflib_IDGenerator.generate(Schema.SBQQ__QuoteLine__c.SObjectType);
        
        mocks.startStubbing();
        
        mocks.when(qliSelector.sObjectType()).thenReturn(Schema.SBQQ__QuoteLine__c.SObjectType);
        mocks.when(qliSelector.selectByQuoteLineIds(new Set<Id>{qli.id})).thenReturn(new List<SBQQ__QuoteLine__c>{qli});
        mocks.when(qliSelector.selectByQuoteLineIds(new Set<Id>{qli5.id})).thenReturn(new List<SBQQ__QuoteLine__c>{qli5});
        
        mocks.when(psaSelector.sObjectType()).thenReturn(Schema.PermissionSetAssignment.SObjectType);
        mocks.when(psaSelector.selectByName(UserInfo.getUserId(),new Set < String > {Label.Pricing_Tender_PermissionSets_TenderUser})).thenReturn(false);
        
        mocks.when(usrSelector.sObjectType()).thenReturn(Schema.User.SObjectType);
        mocks.when(usrSelector.selectbyContactId((Id) fflib_Match.anyObject())).thenReturn(usrLst);
        mocks.stopStubbing();
        
        Pricing_IQR_Application.unitOfWork.setMock(uowMock);
        Pricing_IQR_Application.Selector.setMock(qliSelector);
        Pricing_IQR_Application.Selector.setMock(psaSelector);
        Pricing_IQR_Application.Selector.setMock(usrSelector);
        
        System.Test.startTest();
        Pricing_QuoteLineController_Mock.recordApproval(qli.id ,'comments', Label.Pricing_Tender_QuoteLine_Action_RevisionRequiredbyField, qli,'revision', true);        System.Test.stopTest();
        
        System.debug('Number of Queries used in this apex code so far: ' + Limits.getQueries());
    }
    
    @isTest
    static void test_recordApprovalRPMRevisionFSEException(){
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork uowMock = new fflib_SObjectMocks.SObjectUnitOfWork(mocks);
        
        Pricing_QuoteLines_Selector qliSelector = (Pricing_QuoteLines_Selector) mocks.mock(Pricing_QuoteLines_Selector.class);
        Pricing_PermissionSetAssignment_Selector psaSelector = (Pricing_PermissionSetAssignment_Selector) mocks.mock(Pricing_PermissionSetAssignment_Selector.class);        
        Pricing_User_Selector usrSelector = (Pricing_User_Selector) mocks.mock(Pricing_User_Selector.class);
        
        List<User> usrLst = new List<User>();
        User usr = new User();
        usr.ContactId = fflib_IDGenerator.generate(Schema.Contact.SObjectType);
        usrLst.add(usr);
        
        SBQQ__QuoteLine__c qli5 = new SBQQ__QuoteLine__c();
        qli5.SBQQ__Quote__c = fflib_IDGenerator.generate(Schema.SBQQ__Quote__c.SObjectType);
        qli5.Pricing_Status_Nm__c = 'Won';
        qli5.Pricing_Sales_Rep_Approver__c = usrLst[0].id;
        qli5.CreatedById = UserInfo.getUserId();
        qli5.Pricing_Primary_Contact_Nm__c = usrLst[0].id;
        qli5.Pricing_Change_Request_cb__c = false;
        qli5.id = fflib_IDGenerator.generate(Schema.SBQQ__QuoteLine__c.SObjectType);
        
        SBQQ__QuoteLine__c qli = new SBQQ__QuoteLine__c();
        qli.SBQQ__Quote__c = fflib_IDGenerator.generate(Schema.SBQQ__Quote__c.SObjectType);
        qli.Pricing_Status_Nm__c = 'Pending Further Intel Review';
        qli.Pricing_Sales_Rep__c = usrLst[0].id;
        qli.CreatedById = UserInfo.getUserId();
        qli.Pricing_Primary_Contact_Nm__c = usrLst[0].id;
        qli.Pricing_Change_Request_cb__c = true;
        qli.Pricing_Reference_Quote_Line_Nbr__c = qli5.id;
        qli.id = fflib_IDGenerator.generate(Schema.SBQQ__QuoteLine__c.SObjectType);
        
        mocks.startStubbing();
        
        mocks.when(qliSelector.sObjectType()).thenReturn(Schema.SBQQ__QuoteLine__c.SObjectType);
        mocks.when(qliSelector.selectByQuoteLineIds(new Set<Id>{qli.id})).thenReturn(new List<SBQQ__QuoteLine__c>{qli});
        mocks.when(qliSelector.selectByQuoteLineIds(new Set<Id>{qli5.id})).thenReturn(new List<SBQQ__QuoteLine__c>{qli5});
        
        mocks.when(psaSelector.sObjectType()).thenReturn(Schema.PermissionSetAssignment.SObjectType);
        mocks.when(psaSelector.selectByName(UserInfo.getUserId(),new Set < String > {Label.Pricing_Tender_PermissionSets_TenderUser})).thenReturn(false);
        
        mocks.when(usrSelector.sObjectType()).thenReturn(Schema.User.SObjectType);
        mocks.when(usrSelector.selectbyContactId((Id) fflib_Match.anyObject())).thenReturn(null);
        mocks.stopStubbing();
        
        Pricing_IQR_Application.unitOfWork.setMock(uowMock);
        Pricing_IQR_Application.Selector.setMock(qliSelector);
        Pricing_IQR_Application.Selector.setMock(psaSelector);
        Pricing_IQR_Application.Selector.setMock(usrSelector);
        
        System.Test.startTest();
        Pricing_QuoteLineController_Mock.recordApproval(qli.id ,'comments', Label.Pricing_Tender_QuoteLine_Action_RevisionRequiredbyOEM, qli,'revision', true);        
        System.Test.stopTest();
        
        System.debug('Number of Queries used in this apex code so far: ' + Limits.getQueries());
    }
    
    @isTest
    static void test_recordApprovalRPMReject(){
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork uowMock = new fflib_SObjectMocks.SObjectUnitOfWork(mocks);
        
        Pricing_QuoteLines_Selector qliSelector = (Pricing_QuoteLines_Selector) mocks.mock(Pricing_QuoteLines_Selector.class);
        Pricing_PermissionSetAssignment_Selector psaSelector = (Pricing_PermissionSetAssignment_Selector) mocks.mock(Pricing_PermissionSetAssignment_Selector.class);        
        Pricing_User_Selector usrSelector = (Pricing_User_Selector) mocks.mock(Pricing_User_Selector.class);
        
        List<User> usrLst = new List<User>();
        User usr = new User();
        usr.ContactId = fflib_IDGenerator.generate(Schema.Contact.SObjectType);
        usrLst.add(usr);
        
        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        quote.id = fflib_IDGenerator.generate(Schema.SBQQ__Quote__c.SObjectType);
        quote.SBQQ__PrimaryContact__c = usrLst[0].ContactId;
        
        SBQQ__QuoteLine__c qli5 = new SBQQ__QuoteLine__c();
        qli5.SBQQ__Quote__r = quote;
        qli5.Pricing_Status_Nm__c = 'Won';
        qli5.Pricing_Sales_Rep__c = usrLst[0].id;
        qli5.CreatedById = UserInfo.getUserId();
        qli5.Pricing_Primary_Contact_Nm__c = usrLst[0].id;
        qli5.Pricing_Change_Request_cb__c = false;
        qli5.id = fflib_IDGenerator.generate(Schema.SBQQ__QuoteLine__c.SObjectType);
        
        SBQQ__QuoteLine__c qli = new SBQQ__QuoteLine__c();
        qli.SBQQ__Quote__r = quote;
        qli.Pricing_Status_Nm__c = 'Pending Further Intel Review';
        qli.Pricing_Sales_Rep__c = usrLst[0].id;
        qli.CreatedById = UserInfo.getUserId();
        qli.Pricing_Primary_Contact_Nm__c = usrLst[0].id;
        qli.Pricing_Change_Request_cb__c = true;
        qli.Pricing_Reference_Quote_Line_Nbr__c = qli5.id;
        qli.id = fflib_IDGenerator.generate(Schema.SBQQ__QuoteLine__c.SObjectType);
        
        mocks.startStubbing();
        
        mocks.when(qliSelector.sObjectType()).thenReturn(Schema.SBQQ__QuoteLine__c.SObjectType);
        mocks.when(qliSelector.selectByQuoteLineIds(new Set<Id>{qli.id})).thenReturn(new List<SBQQ__QuoteLine__c>{qli});
        mocks.when(qliSelector.selectByQuoteLineIds(new Set<Id>{qli5.id})).thenReturn(new List<SBQQ__QuoteLine__c>{qli5});
        
        mocks.when(psaSelector.sObjectType()).thenReturn(Schema.PermissionSetAssignment.SObjectType);
        mocks.when(psaSelector.selectByName(UserInfo.getUserId(),new Set < String > {Label.Pricing_Tender_PermissionSets_TenderUser})).thenReturn(false);
        
        mocks.when(usrSelector.sObjectType()).thenReturn(Schema.User.SObjectType);
        mocks.when(usrSelector.selectbyContactId((Id) fflib_Match.anyObject())).thenReturn(usrLst);
        mocks.stopStubbing();
        
        Pricing_IQR_Application.unitOfWork.setMock(uowMock);
        Pricing_IQR_Application.Selector.setMock(qliSelector);
        Pricing_IQR_Application.Selector.setMock(psaSelector);
        Pricing_IQR_Application.Selector.setMock(usrSelector);
        
        System.Test.startTest();
        Pricing_QuoteLineController_Mock.recordApproval(qli.id ,'comments', Label.Pricing_Tender_QuoteLine_Action_Reject, qli, null, null);
        System.Test.stopTest();
        
        System.debug('Number of Queries used in this apex code so far: ' + Limits.getQueries());
    }
    
    @isTest
    static void test_reportingURLValueInt(){
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork uowMock = new fflib_SObjectMocks.SObjectUnitOfWork(mocks);
        
        Pricing_Quote_Selector quoteSelector = (Pricing_Quote_Selector) mocks.mock(Pricing_Quote_Selector.class);
        Pricing_PermissionSetAssignment_Selector psaSelector = (Pricing_PermissionSetAssignment_Selector) mocks.mock(Pricing_PermissionSetAssignment_Selector.class);        
        
        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        quote.id = fflib_IDGenerator.generate(Schema.SBQQ__Quote__c.SObjectType);
        //quote.name = 'Q-0001';
        quote.Pricing_Program_Type_Nm__c = 'Data Center';
        
        Set < String > internalPSWithoutRPM = new Set < String > ();
        Set < String > internalPSWithRPM = new Set < String > ();
        if(Label.Pricing_Tender_PermissionSets_AllInternal != null) {
            internalPSWithoutRPM.addAll(new List < String > ((Label.Pricing_Tender_PermissionSets_AllInternal).split(':')));
            internalPSWithoutRPM.remove(Label.Pricing_Tender_PermissionSets_PricingTenderRegionalPricingManager);
            internalPSWithRPM = new Set < String > {
                Label.Pricing_Tender_PermissionSets_PricingTenderRegionalPricingManager
                    };
                        }
        Set < String > externalPS = new Set < String > ();
        if(Label.Pricing_Tender_PermissionSets_AllExternal != null) {
            externalPS.addAll(new List < String > ((Label.Pricing_Tender_PermissionSets_AllExternal).split(':')));
        }
        
        mocks.startStubbing();
        
        mocks.when(quoteSelector.sObjectType()).thenReturn(Schema.SBQQ__Quote__c.SObjectType);
        mocks.when(quoteSelector.selectByIds(new Set<Id>{quote.id})).thenReturn(new List<SBQQ__Quote__c>{quote});
        
        mocks.when(psaSelector.sObjectType()).thenReturn(Schema.PermissionSetAssignment.SObjectType);
        mocks.when(psaSelector.selectByName(UserInfo.getUserId(),internalPSWithoutRPM)).thenReturn(true);
        mocks.when(psaSelector.selectByName(UserInfo.getUserId(),internalPSWithRPM)).thenReturn(false);
        mocks.when(psaSelector.selectByName(UserInfo.getUserId(),externalPS)).thenReturn(false);
        mocks.stopStubbing();
        
        Pricing_IQR_Application.Selector.setMock(quoteSelector);
        Pricing_IQR_Application.Selector.setMock(psaSelector);
        
        System.Test.startTest();
        Pricing_QuoteLineController_Mock.reportingURLValue(quote.id);
        System.Test.stopTest();
        
        System.debug('Number of Queries used in this apex code so far: ' + Limits.getQueries());
    }
    
    @isTest
    static void test_reportingURLValueExt(){
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork uowMock = new fflib_SObjectMocks.SObjectUnitOfWork(mocks);
        
        Pricing_Quote_Selector quoteSelector = (Pricing_Quote_Selector) mocks.mock(Pricing_Quote_Selector.class);
        Pricing_PermissionSetAssignment_Selector psaSelector = (Pricing_PermissionSetAssignment_Selector) mocks.mock(Pricing_PermissionSetAssignment_Selector.class);        
        
        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        quote.id = fflib_IDGenerator.generate(Schema.SBQQ__Quote__c.SObjectType);
        //quote.name = 'Q-0001';
        quote.Pricing_Program_Type_Nm__c = 'Data Center';
        
        Set < String > internalPSWithoutRPM = new Set < String > ();
        Set < String > internalPSWithRPM = new Set < String > ();
        if(Label.Pricing_Tender_PermissionSets_AllInternal != null) {
            internalPSWithoutRPM.addAll(new List < String > ((Label.Pricing_Tender_PermissionSets_AllInternal).split(':')));
            internalPSWithoutRPM.remove(Label.Pricing_Tender_PermissionSets_PricingTenderRegionalPricingManager);
            internalPSWithRPM = new Set < String > {
                Label.Pricing_Tender_PermissionSets_PricingTenderRegionalPricingManager
                    };
                        }
        Set < String > externalPS = new Set < String > ();
        if(Label.Pricing_Tender_PermissionSets_AllExternal != null) {
            externalPS.addAll(new List < String > ((Label.Pricing_Tender_PermissionSets_AllExternal).split(':')));
        }
        
        mocks.startStubbing();
        
        mocks.when(quoteSelector.sObjectType()).thenReturn(Schema.SBQQ__Quote__c.SObjectType);
        mocks.when(quoteSelector.selectByIds(new Set<Id>{quote.id})).thenReturn(new List<SBQQ__Quote__c>{quote});
        
        mocks.when(psaSelector.sObjectType()).thenReturn(Schema.PermissionSetAssignment.SObjectType);
        mocks.when(psaSelector.selectByName(UserInfo.getUserId(),internalPSWithoutRPM)).thenReturn(false);
        mocks.when(psaSelector.selectByName(UserInfo.getUserId(),internalPSWithRPM)).thenReturn(false);
        mocks.when(psaSelector.selectByName(UserInfo.getUserId(),externalPS)).thenReturn(true);
        mocks.stopStubbing();
        
        Pricing_IQR_Application.Selector.setMock(quoteSelector);
        Pricing_IQR_Application.Selector.setMock(psaSelector);
        
        System.Test.startTest();
        Pricing_QuoteLineController_Mock.reportingURLValue(quote.id);
        System.Test.stopTest();
        
        System.debug('Number of Queries used in this apex code so far: ' + Limits.getQueries());
    }
    
    @isTest
    static void test_insertOutboun(){
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        
        Pricing_QuoteLines_Selector qliSelector = (Pricing_QuoteLines_Selector) mocks.mock(Pricing_QuoteLines_Selector.class);
        Pricing_User_Selector usrSelector = (Pricing_User_Selector) mocks.mock(Pricing_User_Selector.class);
        
        List<User> usrLst = new List<User>();
        User usr = new User();
        usr.Core_WWID__c = '123456';
        usrLst.add(usr);
        
        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        quote.id = fflib_IDGenerator.generate(Schema.SBQQ__Quote__c.SObjectType);
        quote.SBQQ__PrimaryContact__c = usrLst[0].ContactId;
        
        SBQQ__QuoteLine__c qli = new SBQQ__QuoteLine__c();
        qli.SBQQ__Quote__r = quote;
        qli.Pricing_Status_Nm__c = 'Pending Further Intel Review';
        qli.Pricing_Sales_Rep__c = usrLst[0].id;
        qli.CreatedById = UserInfo.getUserId();
        qli.Pricing_Primary_Contact_Nm__c = usrLst[0].id;
        qli.Pricing_Change_Request_cb__c = true;
        qli.id = fflib_IDGenerator.generate(Schema.SBQQ__QuoteLine__c.SObjectType);
        
        mocks.startStubbing();
        mocks.when(qliSelector.sObjectType()).thenReturn(Schema.SBQQ__QuoteLine__c.SObjectType);
        mocks.when(qliSelector.selectByIdAndPM(qli.id)).thenReturn(new List<SBQQ__QuoteLine__c>{qli});
        mocks.when(qliSelector.overLapQuery((Map<Id,SBQQ__QuoteLine__c>) fflib_Match.anyObject(),(Id) fflib_Match.anyObject())).thenReturn(new List<SBQQ__QuoteLine__c>());
        
        mocks.when(usrSelector.sObjectType()).thenReturn(Schema.User.SObjectType);
        mocks.when(usrSelector.selectbyUserId((Id) fflib_Match.anyObject())).thenReturn(usrLst);
        mocks.stopStubbing();
        
        Pricing_IQR_Application.Selector.setMock(qliSelector);
        Pricing_IQR_Application.Selector.setMock(usrSelector);
        
        System.Test.startTest();
        Pricing_QuoteLineController_Mock.insertOutbound(qli.id ,'comments');
        System.Test.stopTest();
        
        System.debug('Number of Queries used in this apex code so far: ' + Limits.getQueries());
    }
    
    @isTest
    static void test_isOverLapDealQL(){
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        
        Pricing_QuoteLines_Selector qliSelector = (Pricing_QuoteLines_Selector) mocks.mock(Pricing_QuoteLines_Selector.class);
        Pricing_User_Selector usrSelector = (Pricing_User_Selector) mocks.mock(Pricing_User_Selector.class);
        
        List<User> usrLst = new List<User>();
        User usr = new User();
        usr.Core_WWID__c = '123456';
        usrLst.add(usr);
        
        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        quote.id = fflib_IDGenerator.generate(Schema.SBQQ__Quote__c.SObjectType);
        quote.SBQQ__PrimaryContact__c = usrLst[0].ContactId;
        quote.Pricing_Customer_Nm__c = 'test';
        
        Formula.recalculateFormulas(new List<SBQQ__Quote__c>{quote});
        
        SBQQ__QuoteLine__c qli = new SBQQ__QuoteLine__c();
        qli.SBQQ__Quote__r = quote;
        qli.Pricing_Status_Nm__c = 'Pending Further Intel Review';
        qli.Pricing_Sales_Rep__c = usrLst[0].id;
        qli.CreatedById = UserInfo.getUserId();
        qli.Pricing_Primary_Contact_Nm__c = usrLst[0].id;
        qli.Pricing_Change_Request_cb__c = true;
        qli.id = fflib_IDGenerator.generate(Schema.SBQQ__QuoteLine__c.SObjectType);
        
        mocks.startStubbing();
        mocks.when(qliSelector.sObjectType()).thenReturn(Schema.SBQQ__QuoteLine__c.SObjectType);
        mocks.when(qliSelector.selectByIdAndPM(qli.id)).thenReturn(new List<SBQQ__QuoteLine__c>{qli});
        mocks.when(qliSelector.overLapQuery((Map<Id,SBQQ__QuoteLine__c>) fflib_Match.anyObject(),(Id) fflib_Match.anyObject() )).thenReturn(new List<SBQQ__QuoteLine__c>{qli});
        
        mocks.when(usrSelector.sObjectType()).thenReturn(Schema.User.SObjectType);
        mocks.when(usrSelector.selectbyUserId((Id) fflib_Match.anyObject())).thenReturn(usrLst);
        mocks.stopStubbing();
        
        Pricing_IQR_Application.Selector.setMock(qliSelector);
        Pricing_IQR_Application.Selector.setMock(usrSelector);
        
        System.Test.startTest();
        Pricing_QuoteLineController_Mock.insertOutbound(qli.id ,'comments');
        System.Test.stopTest();
        
        System.debug('Number of Queries used in this apex code so far: ' + Limits.getQueries());
    }
    
    @istest
    static void test_deleteIQRQuote(){
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork uowMock = new fflib_SObjectMocks.SObjectUnitOfWork(mocks);
        
        Pricing_Quote_Selector quoteSelectorMock = (Pricing_Quote_Selector) mocks.mock(Pricing_Quote_Selector.class);
        Pricing_Quote_Line_Status_Age_Selector tptSelectorMock = (Pricing_Quote_Line_Status_Age_Selector) mocks.mock(Pricing_Quote_Line_Status_Age_Selector.class);
        Pricing_PermissionSetAssignment_Selector psaSelectorMock = (Pricing_PermissionSetAssignment_Selector) mocks.mock(Pricing_PermissionSetAssignment_Selector.class);
        Pricing_Comments_Selector cmntSelectorMock = (Pricing_Comments_Selector) mocks.mock(Pricing_Comments_Selector.class);
        Pricing_Document_Selector docSelectorMock = (Pricing_Document_Selector) mocks.mock(Pricing_Document_Selector.class);
        Pricing_Quote_Team_Selector qtmSelectorMock = (Pricing_Quote_Team_Selector) mocks.mock(Pricing_Quote_Team_Selector.class);
        
        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        quote.id = fflib_IDGenerator.generate(Schema.SBQQ__Quote__c.SObjectType);
        
        Pricing_Quote_Team__c qtm = new Pricing_Quote_Team__c();
        qtm.id = fflib_IDGenerator.generate(Schema.Pricing_Quote_Team__c.SObjectType);
        
        Pricing_Quote_Line_Status_Age__c tpt = new Pricing_Quote_Line_Status_Age__c();
        tpt.id = fflib_IDGenerator.generate(Schema.Pricing_Quote_Line_Status_Age__c.SObjectType);
        
        Pricing_Document__c doc = new Pricing_Document__c();
        doc.id = fflib_IDGenerator.generate(Schema.Pricing_Document__c.SObjectType);
        
        Pricing_Comments__c cmnt = new Pricing_Comments__c();
        cmnt.id = fflib_IDGenerator.generate(Schema.Pricing_Comments__c.SObjectType);
        
        mocks.startStubbing();
        
        mocks.when(quoteSelectorMock.sObjectType()).thenReturn(Schema.SBQQ__Quote__c.SObjectType);
        mocks.when(tptSelectorMock.sObjectType()).thenReturn(Schema.Pricing_Quote_Line_Status_Age__c.SObjectType);
        mocks.when(docSelectorMock.sObjectType()).thenReturn(Schema.Pricing_Document__c.SObjectType);
        mocks.when(psaSelectorMock.sObjectType()).thenReturn(Schema.PermissionSetAssignment.SObjectType);
        mocks.when(cmntSelectorMock.sObjectType()).thenReturn(Schema.Pricing_Comments__c.SObjectType);
        mocks.when(qtmSelectorMock.sObjectType()).thenReturn(Schema.Pricing_Quote_Team__c.SObjectType);
        mocks.when(quoteSelectorMock.selectByIds(new Set<Id>{quote.id})).thenReturn(new List<SBQQ__Quote__c>{quote});
        mocks.when(docSelectorMock.selectByquoteId(quote.id)).thenReturn(new List<Pricing_Document__c>{doc});
        mocks.when(qtmSelectorMock.selectbyQuoteId(quote.id)).thenReturn(new List<Pricing_Quote_Team__c>{qtm});
        mocks.when(cmntSelectorMock.selectByQuoteId(quote.id)).thenReturn(new List<Pricing_Comments__c>{cmnt});
        mocks.when(psaSelectorMock.getCountbyName(Userinfo.getUserId(),new Set<String>{Label.Pricing_Tender_PermissionSets_PricingTenderPartnerAdministrator})).thenReturn(1);
        mocks.when(tptSelectorMock.selectbyQuoteId(quote.id)).thenReturn(new List<Pricing_Quote_Line_Status_Age__c>{tpt});
        
        mocks.stopStubbing();
        
        Pricing_IQR_Application.unitOfWork.setMock(uowMock);
        Pricing_IQR_Application.Selector.setMock(quoteSelectorMock);
        Pricing_IQR_Application.Selector.setMock(tptSelectorMock);
        Pricing_IQR_Application.Selector.setMock(cmntSelectorMock);
        Pricing_IQR_Application.Selector.setMock(qtmSelectorMock);
        Pricing_IQR_Application.Selector.setMock(docSelectorMock);
        Pricing_IQR_Application.Selector.setMock(psaSelectorMock);
        
        Test.startTest();
        Pricing_QuoteLineController_Mock.deleteIQRQuote(quote.id);
        Test.stopTest();
        
        System.debug('Number of Queries used in this apex code so far: ' + Limits.getQueries());
        System.debug('Number of Queries used in this apex code so far: ' + Limits.getDmlStatements());
    }
    
    @istest
    static void test_isNotUnifiedQuoteLine(){
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        
        Pricing_QuoteLines_Selector qliSelector = (Pricing_QuoteLines_Selector) mocks.mock(Pricing_QuoteLines_Selector.class);
        
        Pricing_UnifiedEndCustomerCountryMapping__c uniEc = new Pricing_UnifiedEndCustomerCountryMapping__c();
        uniEc.Pricing_Compliance_Watch_List__c = 'EC';
        uniEc.id = fflib_IDGenerator.generate(Schema.Pricing_UnifiedEndCustomerCountryMapping__c.SObjectType);
        
        Formula.recalculateFormulas(new List<Pricing_UnifiedEndCustomerCountryMapping__c>{uniEc});
        
        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        quote.id = fflib_IDGenerator.generate(Schema.SBQQ__Quote__c.SObjectType);
        quote.Pricing_Unified_Global_End_Customer_Nm__c = uniEc.id;
        quote.Pricing_Unified_Global_End_Customer_Nm__r = uniEC;
        
        Formula.recalculateFormulas(new List<SBQQ__Quote__c>{quote});
        
        SBQQ__QuoteLine__c qli = new SBQQ__QuoteLine__c();
        qli.SBQQ__Quote__r = quote;
        qli.id = fflib_IDGenerator.generate(Schema.SBQQ__QuoteLine__c.SObjectType);
        
        mocks.startStubbing();
        
        mocks.when(qliSelector.sObjectType()).thenReturn(Schema.SBQQ__QuoteLine__c.SObjectType);
        mocks.when(qliSelector.selectByRefQLIIdAndStatus(qli.id,Label.Pricing_Tender_QuoteLine_Status_Rejected)).thenReturn(new List<SBQQ__QuoteLine__c>());
        mocks.when(qliSelector.selectByIdAndProduct(new Set<Id>{qli.id})).thenReturn(new List<SBQQ__QuoteLine__c>{qli});
        
        mocks.stopStubbing();
        
        Pricing_IQR_Application.Selector.setMock(qliSelector);
        
        Test.startTest();
        Pricing_QuoteLineController_Mock.isNotUnifiedQuoteLine(qli.id);
        Test.stopTest();
        
        System.debug('Number of Queries used in this apex code so far: ' + Limits.getQueries());
        System.debug('Number of Queries used in this apex code so far: ' + Limits.getDmlStatements());
    }
    
    @istest
    static void test_searchProductsSOQL(){
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        
        Pricing_Dynamic_Data_Table_Selector dataSelector = (Pricing_Dynamic_Data_Table_Selector) mocks.mock(Pricing_Dynamic_Data_Table_Selector.class);
        Pricing_Product_Selector prodSelector = (Pricing_Product_Selector) mocks.mock(Pricing_Product_Selector.class);
        
        Pricing_Dynamic_Data_Table__mdt dataTable = new Pricing_Dynamic_Data_Table__mdt();
        dataTable.Pricing_Query__c = 'test';
        dataTable.Pricing_Where_Clause__c = 'test' ;
        dataTable.Pricing_SearchColumn_Field__c = 'test' ;
        
        mocks.startStubbing();
        
        mocks.when(dataSelector.sObjectType()).thenReturn(Schema.Pricing_Dynamic_Data_Table__mdt.SObjectType);
        mocks.when(dataSelector.selectByType(new Set<String>{'test'})).thenReturn(new List<Pricing_Dynamic_Data_Table__mdt>{dataTable});
        
        mocks.when(prodSelector.sObjectType()).thenReturn(Schema.Product2.SObjectType);
        mocks.when(prodSelector.selectByText((String) fflib_Match.anyObject())).thenReturn(new List<Product2>());
        
        mocks.stopStubbing();
        
        Pricing_IQR_Application.Selector.setMock(dataSelector);
        Pricing_IQR_Application.Selector.setMock(prodSelector);
        
        Test.startTest();
        Pricing_QuoteLineController_Mock.searchProductsSOQL('test','test');
        Test.stopTest();
        
        System.debug('Number of Queries used in this apex code so far: ' + Limits.getQueries());
        System.debug('Number of Queries used in this apex code so far: ' + Limits.getDmlStatements());
    }    
    
    @istest
    static void test_getDataTableColumns(){
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        
        Pricing_Dynamic_Data_Table_Selector dataSelector = (Pricing_Dynamic_Data_Table_Selector) mocks.mock(Pricing_Dynamic_Data_Table_Selector.class);
        
        Pricing_Dynamic_Data_Table__mdt dataTable = new Pricing_Dynamic_Data_Table__mdt();
        dataTable.Pricing_Field_Label__c = 'test,';
        dataTable.Pricing_Field_Value__c = 'test,' ;
        dataTable.Pricing_Record_Type__c = 'test,' ;
        
        mocks.startStubbing();
        
        mocks.when(dataSelector.sObjectType()).thenReturn(Schema.Pricing_Dynamic_Data_Table__mdt.SObjectType);
        mocks.when(dataSelector.selectByLabel()).thenReturn(new List<Pricing_Dynamic_Data_Table__mdt>{dataTable});
        
        mocks.stopStubbing();
        
        Pricing_IQR_Application.Selector.setMock(dataSelector);
        
        Test.startTest();
        Pricing_QuoteLineController_Mock.getDataTableColumns();
        Test.stopTest();
        
        System.debug('Number of Queries used in this apex code so far: ' + Limits.getQueries());
    } 
    
     @istest
    static void test_auraMethods(){
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        
        Pricing_PermissionSetAssignment_Selector psaSelector = (Pricing_PermissionSetAssignment_Selector) mocks.mock(Pricing_PermissionSetAssignment_Selector.class);
        Pricing_DocumentSelector docSelector = (Pricing_DocumentSelector) mocks.mock(Pricing_DocumentSelector.class);
        
        mocks.startStubbing();
        
        mocks.when(psaSelector.sObjectType()).thenReturn(Schema.PermissionSetAssignment.SObjectType);
        mocks.when(psaSelector.selectByName(Userinfo.getUserId(),new set<string>{Label.Pricing_Tender_PermissionSets_PricingTenderRegionalPricingManager,Label.Pricing_Tender_PermissionSets_PricingDivisionalTenderPricingManager,Label.Pricing_Tender_PermissionSets_TenderReadOnly})).thenReturn(true);
        
        mocks.when(docSelector.sObjectType()).thenReturn(Schema.Document.SObjectType);
        mocks.when(docSelector.selectByName('test')).thenReturn(new List<Document>());
        
        mocks.stopStubbing();
        
        Pricing_IQR_Application.Selector.setMock(psaSelector);
        Pricing_IQR_Application.Selector.setMock(docSelector);
        
        Test.startTest();
        Pricing_QuoteLineController_Mock.isPricingManager();
        Pricing_QuoteLineController_Mock.listValues('SBQQ__QuoteLine__c');
        Pricing_QuoteLineController_Mock.getRecordTypeId('test');
        Pricing_QuoteLineController_Mock.getDocumentId('test');
        Test.stopTest();
        
        System.debug('Number of Queries used in this apex code so far: ' + Limits.getQueries());
    }
}