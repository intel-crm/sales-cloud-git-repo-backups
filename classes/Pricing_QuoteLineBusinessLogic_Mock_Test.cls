@isTest
public class Pricing_QuoteLineBusinessLogic_Mock_Test {
    
    @isTest
    static void test_validateChangeRequestEditRPM(){
        
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        
        Pricing_PermissionSetAssignment_Selector psaSelectorMock = (Pricing_PermissionSetAssignment_Selector) mocks.mock(Pricing_PermissionSetAssignment_Selector.class);
        
        PermissionSet ps = new PermissionSet();
        ps.Name = Label.Pricing_Tender_PermissionSets_PricingTenderRegionalPricingManager;
        
        PermissionSetAssignment psa = new PermissionSetAssignment();
        psa.PermissionSet = ps;
        
        SBQQ__QuoteLine__c testQuoteLine1 =new SBQQ__QuoteLine__c();
        testQuoteLine1.id =  fflib_IDGenerator.generate(Schema.SBQQ__QuoteLine__c.SObjectType);
        testQuoteLine1.Pricing_Change_Request_cb__c = true;
        testQuoteLine1.Pricing_Approved_Start_Date_Dup_Dt__c = Date.parse('12/30/2022');
        
        SBQQ__QuoteLine__c testQuoteLine2 =new SBQQ__QuoteLine__c();
        testQuoteLine2.id =  fflib_IDGenerator.generate(Schema.SBQQ__QuoteLine__c.SObjectType);
        testQuoteLine2.Pricing_Approved_Start_Date_Dup_Dt__c = Date.parse('12/31/2022');
        
        mocks.startStubbing();
        
        mocks.when(psaSelectorMock.sObjectType()).thenReturn(Schema.PermissionSetAssignment.SObjectType);
        
        mocks.when(psaSelectorMock.selectbyUserId(UserInfo.getUserId())).thenReturn(new List<PermissionSetAssignment>{psa});
        
        mocks.stopStubbing();
        
        Pricing_IQR_Application.Selector.setMock(psaSelectorMock);
        
        Test.startTest();
        Pricing_QuoteLineBusinessLogic_Mock.validateChangeRequestEdit(new List<SBQQ__QuoteLine__c>{testQuoteLine1},true,new Map < id, SBQQ__QuoteLine__c >{testQuoteLine1.id => testQuoteLine2});
        Test.stopTest();
        
        ((Pricing_PermissionSetAssignment_Selector) mocks.verify(psaSelectorMock,1)).selectbyUserId(UserInfo.getUserId());
        System.debug('Number of Queries used in this apex code so far: ' + Limits.getQueries());
    }
    
    @isTest
    static void test_validateChangeRequestEditFSE(){
        
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        
        Pricing_PermissionSetAssignment_Selector psaSelectorMock = (Pricing_PermissionSetAssignment_Selector) mocks.mock(Pricing_PermissionSetAssignment_Selector.class);
        
        PermissionSet ps = new PermissionSet();
        ps.Name = Label.Pricing_Tender_PermissionSets_TenderUser;
        
        PermissionSetAssignment psa = new PermissionSetAssignment();
        psa.PermissionSet = ps;
        
        SBQQ__QuoteLine__c testQuoteLine1 =new SBQQ__QuoteLine__c();
        testQuoteLine1.id =  fflib_IDGenerator.generate(Schema.SBQQ__QuoteLine__c.SObjectType);
        testQuoteLine1.Pricing_Change_Request_cb__c = true;
        testQuoteLine1.Pricing_Approved_Start_Date_Dt__c = Date.parse('12/30/2022');
        
        SBQQ__QuoteLine__c testQuoteLine2 =new SBQQ__QuoteLine__c();
        testQuoteLine2.id =  fflib_IDGenerator.generate(Schema.SBQQ__QuoteLine__c.SObjectType);
        testQuoteLine2.Pricing_Approved_Start_Date_Dt__c = Date.parse('12/31/2022');
        
        mocks.startStubbing();
        
        mocks.when(psaSelectorMock.sObjectType()).thenReturn(Schema.PermissionSetAssignment.SObjectType);
        
        mocks.when(psaSelectorMock.selectbyUserId(UserInfo.getUserId())).thenReturn(new List<PermissionSetAssignment>{psa});
        
        mocks.stopStubbing();
        
        Pricing_IQR_Application.Selector.setMock(psaSelectorMock);
        
        Test.startTest();
        Pricing_QuoteLineBusinessLogic_Mock.validateChangeRequestEdit(new List<SBQQ__QuoteLine__c>{testQuoteLine1},true,new Map < id, SBQQ__QuoteLine__c >{testQuoteLine1.id => testQuoteLine2});
        Test.stopTest();
        
        ((Pricing_PermissionSetAssignment_Selector) mocks.verify(psaSelectorMock,1)).selectbyUserId(UserInfo.getUserId());
        System.debug('Number of Queries used in this apex code so far: ' + Limits.getQueries());
    }
    
    @isTest
    static void test_updateQuoteLineDetails(){
        
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork uowMock = new fflib_SObjectMocks.SObjectUnitOfWork(mocks);
        
        Pricing_Quote_Selector quoteSelectorMock = (Pricing_Quote_Selector) mocks.mock(Pricing_Quote_Selector.class);
        Pricing_PermissionSetAssignment_Selector psaSelectorMock = (Pricing_PermissionSetAssignment_Selector) mocks.mock(Pricing_PermissionSetAssignment_Selector.class);
        Pricing_Comments_Selector cmntSelectorMock = (Pricing_Comments_Selector) mocks.mock(Pricing_Comments_Selector.class);
        Pricing_QuoteLines_Selector qliSelectorMock = (Pricing_QuoteLines_Selector) mocks.mock(Pricing_QuoteLines_Selector.class);
        Pricing_ProcessInstanceWorkitem_Selector pwiSelectorMock = (Pricing_ProcessInstanceWorkitem_Selector) mocks.mock(Pricing_ProcessInstanceWorkitem_Selector.class);
        Pricing_Period_Selector periodSelectorMock = (Pricing_Period_Selector) mocks.mock(Pricing_Period_Selector.class);
        
        Map < ID, Schema.RecordTypeInfo > rtMap = Schema.SObjectType.SBQQ__QuoteLine__c.getRecordTypeInfosById();
        List<Id> recIds = new List<Id>();
        recIds.addAll(rtMap.keySet());
        
        Pricing_UnifiedEndCustomerCountryMapping__c uniEc = new Pricing_UnifiedEndCustomerCountryMapping__c();
        uniEc.Pricing_Compliance_Watch_List__c = 'EC;';
        uniEc.id = fflib_IDGenerator.generate(Schema.Pricing_UnifiedEndCustomerCountryMapping__c.SObjectType);
        
        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        quote.id = fflib_IDGenerator.generate(Schema.SBQQ__Quote__c.SObjectType);
        quote.Pricing_Unified_Global_End_Customer_Nm__c = uniEc.id;
        quote.Pricing_Unified_Global_End_Customer_Nm__r = uniEC;
        
        SBQQ__QuoteLine__c testQuoteLine1 =new SBQQ__QuoteLine__c();
        testQuoteLine1.SBQQ__Quote__c = quote.id;
        testQuoteLine1.SBQQ__Quote__r = quote;
        testQuoteLine1.id =  fflib_IDGenerator.generate(Schema.SBQQ__QuoteLine__c.SObjectType);
        testQuoteLine1.Pricing_Change_Request_cb__c = true;
        testQuoteLine1.Pricing_Approved_Start_Date_Dt__c = Date.parse('12/30/2022');
        testQuoteLine1.RecordTypeId = recIds[0];
        testQuoteLine1.Pricing_Status_Nm__c = Label.Pricing_Tender_QuoteLine_Status_PendingIntelFieldReview;
        testQuoteLine1.Pricing_Market_Segment_Nm__c = Label.Pricing_Tender_QuoteLine_Market_Segment_Embedded;
        testQuoteLine1.Pricing_Market_Segment_values_Nm__c = 'test';
        
        SBQQ__QuoteLine__c testQuoteLine2 =new SBQQ__QuoteLine__c();
        testQuoteLine2.SBQQ__Quote__c = testQuoteLine1.SBQQ__Quote__c;
        testQuoteLine2.Pricing_Status_Nm__c = Label.Pricing_Tender_QuoteLine_Status_PendingIntelFieldReview;
        testQuoteLine2.id =  fflib_IDGenerator.generate(Schema.SBQQ__QuoteLine__c.SObjectType);
        testQuoteLine2.Pricing_Approved_Start_Date_Dt__c = Date.parse('12/31/2022');
        testQuoteLine2.Pricing_Market_Segment_values_Nm__c = 'test1;';
        
        ProcessInstance pi = new ProcessInstance();
        pi.TargetObjectId = testQuoteLine1.id;
        
        ProcessInstanceWorkitem pwi = new ProcessInstanceWorkitem();
        pwi.ProcessInstance = pi;
        pwi.OriginalActorId = fflib_IDGenerator.generate(Schema.User.SObjectType);
        
        mocks.startStubbing();
        
        mocks.when(psaSelectorMock.sObjectType()).thenReturn(Schema.PermissionSetAssignment.SObjectType);
        mocks.when(quoteSelectorMock.sObjectType()).thenReturn(Schema.SBQQ__Quote__c.SObjectType);
        mocks.when(cmntSelectorMock.sObjectType()).thenReturn(Schema.Pricing_Comments__c.SObjectType);
        mocks.when(qliSelectorMock.sObjectType()).thenReturn(Schema.SBQQ__QuoteLine__c.SObjectType);
        mocks.when(pwiSelectorMock.sObjectType()).thenReturn(Schema.ProcessInstanceWorkitem.SObjectType);
        
        mocks.when(psaSelectorMock.selectbyName(UserInfo.getUserId(),new Set < String > {Label.Pricing_Tender_PermissionSets_PricingTenderRegionalPricingManager})).thenReturn(true);
        mocks.when(quoteSelectorMock.selectByIds(new Set<Id>{testQuoteLine1.SBQQ__Quote__c})).thenReturn(new List<SBQQ__Quote__c>{quote});
        mocks.when(cmntSelectorMock.selectByIdsAndReq((Set<Id>) fflib_Match.anyObject(),(Id) fflib_Match.anyObject())).thenReturn(new List<Pricing_Comments__c>());
        mocks.when(qliSelectorMock.selectByIdsAndPM(new Set<Id>{testQuoteLine1.id})).thenReturn(new List<SBQQ__QuoteLine__c>{testQuoteLine1});
        mocks.when(qliSelectorMock.selectByRefQlis(new Set<Id>{testQuoteLine1.id})).thenReturn(new List<SBQQ__QuoteLine__c>{testQuoteLine1});
        mocks.when(qliSelectorMock.selectByRefQLIIdsAndStatus((Set<Id>) fflib_Match.anyObject(),(String) fflib_Match.anyObject())).thenReturn(new List<SBQQ__QuoteLine__c>{testQuoteLine1});
        mocks.when(qliSelectorMock.selectByIdAndProduct((Set<Id>) fflib_Match.anyObject())).thenReturn(new List<SBQQ__QuoteLine__c>{testQuoteLine1});
        mocks.when(qliSelectorMock.selectByQuoteLineIds((Set<Id>) fflib_Match.anyObject())).thenReturn(new List<SBQQ__QuoteLine__c>{testQuoteLine1});
        mocks.when(pwiSelectorMock.selectbyQliIdsandStatus(new Set<Id>{testQuoteLine1.id},'Pending')).thenReturn(new List<ProcessInstanceWorkitem>{pwi});
        
        mocks.stopStubbing();
        
        Pricing_IQR_Application.unitOfWork.setMock(uowMock);
        Pricing_IQR_Application.Selector.setMock(psaSelectorMock);
        Pricing_IQR_Application.Selector.setMock(quoteSelectorMock);
        Pricing_IQR_Application.Selector.setMock(cmntSelectorMock);
        Pricing_IQR_Application.Selector.setMock(qliSelectorMock);
        Pricing_IQR_Application.Selector.setMock(pwiSelectorMock);
        
        Test.startTest();
        Pricing_QuoteLineBusinessLogic_Mock.updateQuoteLineDetails(new List<SBQQ__QuoteLine__c>{testQuoteLine1},false,new Map < id, SBQQ__QuoteLine__c >{testQuoteLine1.id => testQuoteLine2});
        Pricing_QuoteLineBusinessLogic_Mock.updateQuoteLineDetails(new List<SBQQ__QuoteLine__c>{testQuoteLine1},true,new Map < id, SBQQ__QuoteLine__c >{testQuoteLine1.id => testQuoteLine2});
        Test.stopTest();
        
        System.debug('Number of Queries used in this apex code so far: ' + Limits.getQueries());
    }
    
    @isTest
    static void test_updateQuoteLineDetails2(){
        
        Core_Trigger_Executions__c triggerEntry2 = new Core_Trigger_Executions__c();
        triggerEntry2.name = 'pricingSendOutboundMessagesIQR';
        triggerEntry2.Core_Object__c = 'Descriptive Feature';
        triggerEntry2.Core_Trigger_Events__c = 'After insert';
        triggerEntry2.Core_Active__c = TRUE;
        triggerEntry2.Core_Description__c = 'This is test description';
        triggerEntry2.Core_Class_Name__c = 'Test Class';
        insert triggerEntry2;
        
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork uowMock = new fflib_SObjectMocks.SObjectUnitOfWork(mocks);
        
        Pricing_Quote_Selector quoteSelectorMock = (Pricing_Quote_Selector) mocks.mock(Pricing_Quote_Selector.class);
        Pricing_PermissionSetAssignment_Selector psaSelectorMock = (Pricing_PermissionSetAssignment_Selector) mocks.mock(Pricing_PermissionSetAssignment_Selector.class);
        Pricing_Comments_Selector cmntSelectorMock = (Pricing_Comments_Selector) mocks.mock(Pricing_Comments_Selector.class);
        Pricing_QuoteLines_Selector qliSelectorMock = (Pricing_QuoteLines_Selector) mocks.mock(Pricing_QuoteLines_Selector.class);
        Pricing_ProcessInstanceWorkitem_Selector pwiSelectorMock = (Pricing_ProcessInstanceWorkitem_Selector) mocks.mock(Pricing_ProcessInstanceWorkitem_Selector.class);
        
        Pricing_UnifiedEndCustomerCountryMapping__c uniEc = new Pricing_UnifiedEndCustomerCountryMapping__c();
        uniEc.Pricing_Compliance_Watch_List__c = 'EC;';
        uniEc.id = fflib_IDGenerator.generate(Schema.Pricing_UnifiedEndCustomerCountryMapping__c.SObjectType);
        
        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        quote.id = fflib_IDGenerator.generate(Schema.SBQQ__Quote__c.SObjectType);
        quote.Pricing_Unified_Global_End_Customer_Nm__c = uniEc.id;
        quote.Pricing_Unified_Global_End_Customer_Nm__r = uniEC;
        
        Product2 prod = new Product2();
        prod.Name = Label.Pricing_Tender_Write_In_Product;
        
        SBQQ__QUoteLine__c qli = new SBQQ__QuoteLine__c();
        qli.SBQQ__Quote__c = quote.id;
        qli.SBQQ__Quote__r = quote;
        qli.Pricing_Status_Nm__c = Label.Pricing_Tender_QuoteLine_Action_Won;
        qli.id =  fflib_IDGenerator.generate(Schema.SBQQ__QuoteLine__c.SObjectType);
        
        SBQQ__QuoteLine__c testQuoteLine1 =new SBQQ__QuoteLine__c();
        testQuoteLine1.SBQQ__Quote__c = quote.id;
        testQuoteLine1.SBQQ__Quote__r = quote;
        testQuoteLine1.SBQQ__Product__r = prod;
        testQuoteLine1.id =  fflib_IDGenerator.generate(Schema.SBQQ__QuoteLine__c.SObjectType);
        testQuoteLine1.Pricing_Change_Request_cb__c = true;
        testQuoteLine1.Pricing_Approved_Start_Date_Dt__c = Date.parse('12/30/2022');
        testQuoteLine1.Pricing_Status_Nm__c = Label.Pricing_Tender_QuoteLine_Status_Approved;
        testQuoteLine1.Pricing_Market_Segment_Nm__c = Label.Pricing_Tender_QuoteLine_Market_Segment_Embedded;
        testQuoteLine1.Pricing_Market_Segment_values_Nm__c = 'test';
        testQuoteLine1.Pricing_Quote_Line_Won_Lost_Status__c = Label.Pricing_Tender_QuoteLine_Status_Won;
        testQuoteLine1.Pricing_Update_Status_to_Rejected_cb__c = true;
        testQuoteLine1.Pricing_Reference_Quote_Line_Nbr__c = qli.id;
        testQuoteLine1.Pricing_Reference_Quote_Line_Nbr__r = qli;
        
        SBQQ__QuoteLine__c testQuoteLine2 = new SBQQ__QuoteLine__c();
        testQuoteLine2.SBQQ__Quote__c = quote.id;
        testQuoteLine2.SBQQ__Quote__r = quote;
        testQuoteLine2.Pricing_Status_Nm__c = Label.Pricing_Tender_QuoteLine_Status_PendingFurtherIntelReview;
        testQuoteLine2.id =  fflib_IDGenerator.generate(Schema.SBQQ__QuoteLine__c.SObjectType);
        testQuoteLine2.Pricing_Approved_Start_Date_Dt__c = Date.parse('12/31/2022');
        testQuoteLine2.Pricing_Market_Segment_values_Nm__c = 'test1;';
        testQuoteLine2.Pricing_Update_Status_to_Rejected_cb__c = false;
        
        ProcessInstance pi = new ProcessInstance();
        pi.TargetObjectId = testQuoteLine1.id;
        
        ProcessInstanceWorkitem pwi = new ProcessInstanceWorkitem();
        pwi.ProcessInstance = pi;
        pwi.OriginalActorId = fflib_IDGenerator.generate(Schema.User.SObjectType);
        
        mocks.startStubbing();
        
        mocks.when(psaSelectorMock.sObjectType()).thenReturn(Schema.PermissionSetAssignment.SObjectType);
        mocks.when(quoteSelectorMock.sObjectType()).thenReturn(Schema.SBQQ__Quote__c.SObjectType);
        mocks.when(cmntSelectorMock.sObjectType()).thenReturn(Schema.Pricing_Comments__c.SObjectType);
        mocks.when(qliSelectorMock.sObjectType()).thenReturn(Schema.SBQQ__QuoteLine__c.SObjectType);
        mocks.when(pwiSelectorMock.sObjectType()).thenReturn(Schema.ProcessInstanceWorkitem.SObjectType);
        
        mocks.when(psaSelectorMock.selectbyName(UserInfo.getUserId(),new Set < String > {Label.Pricing_Tender_PermissionSets_PricingTenderRegionalPricingManager})).thenReturn(true);
        mocks.when(quoteSelectorMock.selectByIds(new Set<Id>{testQuoteLine1.SBQQ__Quote__c})).thenReturn(new List<SBQQ__Quote__c>{quote});
        mocks.when(cmntSelectorMock.selectByIdsAndReq((Set<Id>) fflib_Match.anyObject(),(Id) fflib_Match.anyObject())).thenReturn(new List<Pricing_Comments__c>());
        mocks.when(qliSelectorMock.selectByIdsAndPM(new Set<Id>{testQuoteLine1.id})).thenReturn(new List<SBQQ__QuoteLine__c>{testQuoteLine1});
        mocks.when(qliSelectorMock.selectByRefQlis(new Set<Id>{testQuoteLine1.id})).thenReturn(new List<SBQQ__QuoteLine__c>{testQuoteLine1});
        mocks.when(qliSelectorMock.selectByRefQLIIdsAndStatus((Set<Id>) fflib_Match.anyObject(),(String) fflib_Match.anyObject())).thenReturn(new List<SBQQ__QuoteLine__c>{testQuoteLine1});
        mocks.when(qliSelectorMock.selectByQuoteLineIds((Set<Id>) fflib_Match.anyObject())).thenReturn(new List<SBQQ__QuoteLine__c>{testQuoteLine1});
        mocks.when(qliSelectorMock.selectByIdAndProduct((Set<Id>) fflib_Match.anyObject())).thenReturn(new List<SBQQ__QuoteLine__c>{testQuoteLine1});
        mocks.when(pwiSelectorMock.selectbyQliIdsandStatus(new Set<Id>{testQuoteLine1.id},'Pending')).thenReturn(new List<ProcessInstanceWorkitem>{pwi});
        
        mocks.stopStubbing();
        
        Pricing_IQR_Application.unitOfWork.setMock(uowMock);
        Pricing_IQR_Application.Selector.setMock(psaSelectorMock);
        Pricing_IQR_Application.Selector.setMock(quoteSelectorMock);
        Pricing_IQR_Application.Selector.setMock(cmntSelectorMock);
        Pricing_IQR_Application.Selector.setMock(qliSelectorMock);
        Pricing_IQR_Application.Selector.setMock(pwiSelectorMock);
        
        Test.startTest();
        Pricing_QuoteTeam_Trigger_Handler.hasQuoteLineResubmission = false;
        Pricing_QuoteLineBusinessLogic_Mock.updateQuoteLineDetails(new List<SBQQ__QuoteLine__c>{testQuoteLine1},false,new Map < id, SBQQ__QuoteLine__c >{testQuoteLine1.id => testQuoteLine2});
        Test.stopTest();
        
        System.debug('Number of Queries used in this apex code so far: ' + Limits.getQueries());
    }
    
    static testmethod void testautoPopulateBillingStartDate(){
        
        /*List<SBQQ__QuoteLine__c> quoteLineList = [SELECT Id, Name, SBQQ__Quote__r.SBQQ__Account__r.Name, Pricing_Billing_Start_Date_Dt__c FROM SBQQ__QuoteLine__c LIMIT 1];
        update quoteLineList;*/
        User adminUser = [Select id from User where Email='qlBusinessLogicAdmin@intel.com'];

        Pricing_UnifiedEndCustomerCountryMapping__c uniEc = new Pricing_UnifiedEndCustomerCountryMapping__c();
        uniEc.Pricing_Compliance_Watch_List__c = 'EC;';
        uniEc.id = fflib_IDGenerator.generate(Schema.Pricing_UnifiedEndCustomerCountryMapping__c.SObjectType);
        
        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        quote.id = fflib_IDGenerator.generate(Schema.SBQQ__Quote__c.SObjectType);
        quote.Pricing_Unified_Global_End_Customer_Nm__c = uniEc.id;
        quote.Pricing_Unified_Global_End_Customer_Nm__r = uniEC;

        SBQQ__QuoteLine__c testQuoteLine2 = new SBQQ__QuoteLine__c();
        testQuoteLine2.SBQQ__Quote__c = quote.id;
        testQuoteLine2.SBQQ__Quote__r = quote;
        testQuoteLine2.Pricing_Billing_Start_Date_Dt__c = system.today();
        System.runAs(adminUser){
            insert testQuoteLine2;
        }

        Set<Id> lstQLids = new Set<Id>();
        lstQLids.add(testQuoteLine2.Id);
        Test.startTest();
        QuoteLineBusinessLogic.autoPopulateBillingStartDate(lstQLids);
        Test.stopTest();
    }

    @isTest
    static void test_updateQuoteLineDetails3(){
        
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork uowMock = new fflib_SObjectMocks.SObjectUnitOfWork(mocks);
        
        Pricing_Quote_Selector quoteSelectorMock = (Pricing_Quote_Selector) mocks.mock(Pricing_Quote_Selector.class);
        Pricing_PermissionSetAssignment_Selector psaSelectorMock = (Pricing_PermissionSetAssignment_Selector) mocks.mock(Pricing_PermissionSetAssignment_Selector.class);
        Pricing_Comments_Selector cmntSelectorMock = (Pricing_Comments_Selector) mocks.mock(Pricing_Comments_Selector.class);
        Pricing_QuoteLines_Selector qliSelectorMock = (Pricing_QuoteLines_Selector) mocks.mock(Pricing_QuoteLines_Selector.class);
        Pricing_ProcessInstanceWorkitem_Selector pwiSelectorMock = (Pricing_ProcessInstanceWorkitem_Selector) mocks.mock(Pricing_ProcessInstanceWorkitem_Selector.class);
        
        Pricing_UnifiedEndCustomerCountryMapping__c uniEc = new Pricing_UnifiedEndCustomerCountryMapping__c();
        uniEc.Pricing_Compliance_Watch_List__c = 'EC;';
        uniEc.id = fflib_IDGenerator.generate(Schema.Pricing_UnifiedEndCustomerCountryMapping__c.SObjectType);
        
        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        quote.id = fflib_IDGenerator.generate(Schema.SBQQ__Quote__c.SObjectType);
        quote.Pricing_Unified_Global_End_Customer_Nm__c = uniEc.id;
        quote.Pricing_Unified_Global_End_Customer_Nm__r = uniEC;
        
        SBQQ__QuoteLine__c testQuoteLine1 =new SBQQ__QuoteLine__c();
        testQuoteLine1.SBQQ__Quote__c = quote.id;
        testQuoteLine1.SBQQ__Quote__r = quote;
        testQuoteLine1.id =  fflib_IDGenerator.generate(Schema.SBQQ__QuoteLine__c.SObjectType);
        testQuoteLine1.Pricing_Change_Request_cb__c = true;
        testQuoteLine1.Pricing_Approved_Start_Date_Dt__c = Date.parse('12/30/2022');
        testQuoteLine1.Pricing_Status_Nm__c = Label.Pricing_Tender_QuoteLine_Status_PendingIntelFieldReview;
        testQuoteLine1.Pricing_Market_Segment_Nm__c = Label.Pricing_Tender_QuoteLine_Market_Segment_Embedded;
        testQuoteLine1.Pricing_Market_Segment_values_Nm__c = 'test';
        testQuoteLine1.Pricing_Quote_Line_Won_Lost_Status__c = Label.Pricing_Tender_QuoteLine_Status_Won;
        testQuoteLine1.Pricing_Update_Status_to_Rejected_cb__c = true;
        
        SBQQ__QuoteLine__c testQuoteLine2 =new SBQQ__QuoteLine__c();
        testQuoteLine2.SBQQ__Quote__c = quote.id;
        testQuoteLine2.SBQQ__Quote__r = quote;
        testQuoteLine2.Pricing_Status_Nm__c = Label.Pricing_Tender_QuoteLine_Status_PendingFurtherIntelReview;
        testQuoteLine2.id =  fflib_IDGenerator.generate(Schema.SBQQ__QuoteLine__c.SObjectType);
        testQuoteLine2.Pricing_Approved_Start_Date_Dt__c = Date.parse('12/31/2022');
        testQuoteLine2.Pricing_Market_Segment_values_Nm__c = 'test1;';
        testQuoteLine2.Pricing_Update_Status_to_Rejected_cb__c = false;
        
        ProcessInstance pi = new ProcessInstance();
        pi.TargetObjectId = testQuoteLine1.id;
        
        ProcessInstanceWorkitem pwi = new ProcessInstanceWorkitem();
        pwi.ProcessInstance = pi;
        pwi.OriginalActorId = fflib_IDGenerator.generate(Schema.User.SObjectType);
        
        mocks.startStubbing();
        
        mocks.when(psaSelectorMock.sObjectType()).thenReturn(Schema.PermissionSetAssignment.SObjectType);
        mocks.when(quoteSelectorMock.sObjectType()).thenReturn(Schema.SBQQ__Quote__c.SObjectType);
        mocks.when(cmntSelectorMock.sObjectType()).thenReturn(Schema.Pricing_Comments__c.SObjectType);
        mocks.when(qliSelectorMock.sObjectType()).thenReturn(Schema.SBQQ__QuoteLine__c.SObjectType);
        mocks.when(pwiSelectorMock.sObjectType()).thenReturn(Schema.ProcessInstanceWorkitem.SObjectType);
        
        mocks.when(psaSelectorMock.selectbyName(UserInfo.getUserId(),new Set < String > {Label.Pricing_Tender_PermissionSets_PricingTenderRegionalPricingManager})).thenReturn(true);
        mocks.when(quoteSelectorMock.selectByIds(new Set<Id>{testQuoteLine1.SBQQ__Quote__c})).thenReturn(new List<SBQQ__Quote__c>{quote});
        mocks.when(cmntSelectorMock.selectByIdsAndReq((Set<Id>) fflib_Match.anyObject(),(Id) fflib_Match.anyObject())).thenReturn(new List<Pricing_Comments__c>());
        mocks.when(qliSelectorMock.selectByIdsAndPM(new Set<Id>{testQuoteLine1.id})).thenReturn(new List<SBQQ__QuoteLine__c>{testQuoteLine1});
        mocks.when(qliSelectorMock.selectByRefQlis(new Set<Id>{testQuoteLine1.id})).thenReturn(new List<SBQQ__QuoteLine__c>{testQuoteLine1});
        mocks.when(qliSelectorMock.selectByQuoteLineIds((Set<Id>) fflib_Match.anyObject())).thenReturn(new List<SBQQ__QuoteLine__c>{testQuoteLine1});
        mocks.when(qliSelectorMock.selectByRefQLIIdsAndStatus((Set<Id>) fflib_Match.anyObject(),(String) fflib_Match.anyObject())).thenReturn(new List<SBQQ__QuoteLine__c>{testQuoteLine1});
        mocks.when(qliSelectorMock.selectByIdAndProduct((Set<Id>) fflib_Match.anyObject())).thenReturn(new List<SBQQ__QuoteLine__c>{testQuoteLine1});
        mocks.when(pwiSelectorMock.selectbyQliIdsandStatus(new Set<Id>{testQuoteLine1.id},'Pending')).thenReturn(new List<ProcessInstanceWorkitem>{pwi});
        
        mocks.stopStubbing();
        
        Pricing_IQR_Application.unitOfWork.setMock(uowMock);
        Pricing_IQR_Application.Selector.setMock(psaSelectorMock);
        Pricing_IQR_Application.Selector.setMock(quoteSelectorMock);
        Pricing_IQR_Application.Selector.setMock(cmntSelectorMock);
        Pricing_IQR_Application.Selector.setMock(qliSelectorMock);
        Pricing_IQR_Application.Selector.setMock(pwiSelectorMock);
        
        Test.startTest();
        Pricing_QuoteTeam_Trigger_Handler.hasQuoteLineResubmission = false;
        Pricing_QuoteLineBusinessLogic_Mock.updateQuoteLineDetails(new List<SBQQ__QuoteLine__c>{testQuoteLine1},false,new Map < id, SBQQ__QuoteLine__c >{testQuoteLine1.id => testQuoteLine2});
        Test.stopTest();
        
        System.debug('Number of Queries used in this apex code so far: ' + Limits.getQueries());
    }
    
    @isTest
    static void test_updateQuoteLineDetails4(){
        
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork uowMock = new fflib_SObjectMocks.SObjectUnitOfWork(mocks);
        
        Pricing_Quote_Selector quoteSelectorMock = (Pricing_Quote_Selector) mocks.mock(Pricing_Quote_Selector.class);
        Pricing_PermissionSetAssignment_Selector psaSelectorMock = (Pricing_PermissionSetAssignment_Selector) mocks.mock(Pricing_PermissionSetAssignment_Selector.class);
        Pricing_Comments_Selector cmntSelectorMock = (Pricing_Comments_Selector) mocks.mock(Pricing_Comments_Selector.class);
        Pricing_QuoteLines_Selector qliSelectorMock = (Pricing_QuoteLines_Selector) mocks.mock(Pricing_QuoteLines_Selector.class);
        Pricing_ProcessInstanceWorkitem_Selector pwiSelectorMock = (Pricing_ProcessInstanceWorkitem_Selector) mocks.mock(Pricing_ProcessInstanceWorkitem_Selector.class);
        
        Pricing_UnifiedEndCustomerCountryMapping__c uniEc = new Pricing_UnifiedEndCustomerCountryMapping__c();
        uniEc.Pricing_Compliance_Watch_List__c = 'EC;';
        uniEc.id = fflib_IDGenerator.generate(Schema.Pricing_UnifiedEndCustomerCountryMapping__c.SObjectType);
        
        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        quote.id = fflib_IDGenerator.generate(Schema.SBQQ__Quote__c.SObjectType);
        quote.Pricing_Unified_Global_End_Customer_Nm__c = uniEc.id;
        quote.Pricing_Unified_Global_End_Customer_Nm__r = uniEC;
        
        Product2 prod = new Product2();
        prod.Name = Label.Pricing_Tender_Write_In_Product;

        SBQQ__QuoteLine__c testQuoteLine1 =new SBQQ__QuoteLine__c();
        testQuoteLine1.SBQQ__Quote__c = quote.id;
        testQuoteLine1.SBQQ__Quote__r = quote;
        testQuoteLine1.SBQQ__Product__r = prod;
        testQuoteLine1.id =  fflib_IDGenerator.generate(Schema.SBQQ__QuoteLine__c.SObjectType);
        testQuoteLine1.Pricing_Change_Request_cb__c = true;
        testQuoteLine1.Pricing_Approved_Start_Date_Dt__c = Date.parse('12/30/2022');
        testQuoteLine1.Pricing_Status_Nm__c = Label.Pricing_Tender_QuoteLine_Status_PendingFurtherIntelReview;
        testQuoteLine1.Pricing_Market_Segment_Nm__c = Label.Pricing_Tender_QuoteLine_Market_Segment_Embedded;
        testQuoteLine1.Pricing_Market_Segment_values_Nm__c = 'test';
        testQuoteLine1.Pricing_Quote_Line_Won_Lost_Status__c = Label.Pricing_Tender_QuoteLine_Status_Won;
        testQuoteLine1.Pricing_Update_Status_to_Rejected_cb__c = true;
        testQuoteLine1.Pricing_Ready_for_Review_cb__c = true;
        testQuoteLine1.Pricing_Previous_Status_Nm__c = 'Pending';
        testQuoteLine1.Pricing_Quote_Line_Status_Number__c = 20;
         testQuoteLine1.Pricing_Program_Type_Nm__c = Label.Pricing_Tender_SSD_Quote;
        
        SBQQ__QuoteLine__c testQuoteLine2 = new SBQQ__QuoteLine__c();
        testQuoteLine2.SBQQ__Quote__c = quote.id;
        testQuoteLine2.SBQQ__Quote__r = quote;
        testQuoteLine2.Pricing_Status_Nm__c = Label.Pricing_Tender_QuoteLine_Status_PendingIntelFieldReview ;
        testQuoteLine2.id =  fflib_IDGenerator.generate(Schema.SBQQ__QuoteLine__c.SObjectType);
        testQuoteLine2.Pricing_Approved_Start_Date_Dt__c = Date.parse('12/31/2022');
        testQuoteLine2.Pricing_Market_Segment_values_Nm__c = 'test1;';
        testQuoteLine2.Pricing_Update_Status_to_Rejected_cb__c = false;
        testQuoteLine2.Pricing_Ready_for_Review_cb__c = false;
        testQuoteLine2.Pricing_Quote_Line_Status_Number__c = 45;
        
        Pricing_Comments__c cmnt = new Pricing_Comments__c();
        cmnt.Pricing_Quote__c = quote.id;
        
        ProcessInstance pi = new ProcessInstance();
        pi.TargetObjectId = testQuoteLine1.id;
        
        ProcessInstanceWorkitem pwi = new ProcessInstanceWorkitem();
        pwi.ProcessInstance = pi;
        pwi.OriginalActorId = fflib_IDGenerator.generate(Schema.User.SObjectType);
        
        mocks.startStubbing();
        
        mocks.when(psaSelectorMock.sObjectType()).thenReturn(Schema.PermissionSetAssignment.SObjectType);
        mocks.when(quoteSelectorMock.sObjectType()).thenReturn(Schema.SBQQ__Quote__c.SObjectType);
        mocks.when(cmntSelectorMock.sObjectType()).thenReturn(Schema.Pricing_Comments__c.SObjectType);
        mocks.when(qliSelectorMock.sObjectType()).thenReturn(Schema.SBQQ__QuoteLine__c.SObjectType);
        mocks.when(pwiSelectorMock.sObjectType()).thenReturn(Schema.ProcessInstanceWorkitem.SObjectType);
        
        mocks.when(psaSelectorMock.selectbyName(UserInfo.getUserId(),new Set < String > {Label.Pricing_Tender_PermissionSets_PricingTenderRegionalPricingManager})).thenReturn(true);
        mocks.when(quoteSelectorMock.selectByIds(new Set<Id>{testQuoteLine1.SBQQ__Quote__c})).thenReturn(new List<SBQQ__Quote__c>{quote});
        mocks.when(cmntSelectorMock.selectByIdsAndReq((Set<Id>) fflib_Match.anyObject(),(Id) fflib_Match.anyObject())).thenReturn(new List<Pricing_Comments__c>{cmnt});
        mocks.when(qliSelectorMock.selectByIdsAndPM(new Set<Id>{testQuoteLine1.id})).thenReturn(new List<SBQQ__QuoteLine__c>{testQuoteLine1});
        mocks.when(qliSelectorMock.selectByRefQlis(new Set<Id>{testQuoteLine1.id})).thenReturn(new List<SBQQ__QuoteLine__c>{testQuoteLine1});
        mocks.when(qliSelectorMock.selectByQuoteLineIds((Set<Id>) fflib_Match.anyObject())).thenReturn(new List<SBQQ__QuoteLine__c>{testQuoteLine1});
        mocks.when(qliSelectorMock.selectByRefQLIIdsAndStatus((Set<Id>) fflib_Match.anyObject(),(String) fflib_Match.anyObject())).thenReturn(new List<SBQQ__QuoteLine__c>{testQuoteLine1});
        mocks.when(qliSelectorMock.selectByIdAndProduct((Set<Id>) fflib_Match.anyObject())).thenReturn(new List<SBQQ__QuoteLine__c>{testQuoteLine1});
        mocks.when(pwiSelectorMock.selectbyQliIdsandStatus(new Set<Id>{testQuoteLine1.id},'Pending')).thenReturn(new List<ProcessInstanceWorkitem>{pwi});
        
        mocks.stopStubbing();
        
        Pricing_IQR_Application.unitOfWork.setMock(uowMock);
        Pricing_IQR_Application.Selector.setMock(psaSelectorMock);
        Pricing_IQR_Application.Selector.setMock(quoteSelectorMock);
        Pricing_IQR_Application.Selector.setMock(cmntSelectorMock);
        Pricing_IQR_Application.Selector.setMock(qliSelectorMock);
        Pricing_IQR_Application.Selector.setMock(pwiSelectorMock);
        
        Test.startTest();
        Pricing_QuoteTeam_Trigger_Handler.hasQuoteLineResubmission = false;
        Pricing_QuoteLineBusinessLogic_Mock.updateQuoteLineDetails(new List<SBQQ__QuoteLine__c>{testQuoteLine1},false,new Map < id, SBQQ__QuoteLine__c >{testQuoteLine1.id => testQuoteLine2});
        Test.stopTest();
        
        System.debug('Number of Queries used in this apex code so far: ' + Limits.getQueries());
    }
    
    @isTest
    static void test_updateQuoteLineDetails5(){
        
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork uowMock = new fflib_SObjectMocks.SObjectUnitOfWork(mocks);
        
        Pricing_Quote_Selector quoteSelectorMock = (Pricing_Quote_Selector) mocks.mock(Pricing_Quote_Selector.class);
        Pricing_PermissionSetAssignment_Selector psaSelectorMock = (Pricing_PermissionSetAssignment_Selector) mocks.mock(Pricing_PermissionSetAssignment_Selector.class);
        Pricing_Comments_Selector cmntSelectorMock = (Pricing_Comments_Selector) mocks.mock(Pricing_Comments_Selector.class);
        Pricing_QuoteLines_Selector qliSelectorMock = (Pricing_QuoteLines_Selector) mocks.mock(Pricing_QuoteLines_Selector.class);
        Pricing_ProcessInstanceWorkitem_Selector pwiSelectorMock = (Pricing_ProcessInstanceWorkitem_Selector) mocks.mock(Pricing_ProcessInstanceWorkitem_Selector.class);
        
        Pricing_UnifiedEndCustomerCountryMapping__c uniEc = new Pricing_UnifiedEndCustomerCountryMapping__c();
        uniEc.Pricing_Compliance_Watch_List__c = 'EC;';
        uniEc.id = fflib_IDGenerator.generate(Schema.Pricing_UnifiedEndCustomerCountryMapping__c.SObjectType);
        
        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        quote.id = fflib_IDGenerator.generate(Schema.SBQQ__Quote__c.SObjectType);
        quote.Pricing_Unified_Global_End_Customer_Nm__c = uniEc.id;
        quote.Pricing_Unified_Global_End_Customer_Nm__r = uniEC;
        
        Product2 prod = new Product2();
        prod.Name = Label.Pricing_Tender_Write_In_Product;

        SBQQ__QuoteLine__c testQuoteLine1 =new SBQQ__QuoteLine__c();
        testQuoteLine1.SBQQ__Quote__c = quote.id;
        testQuoteLine1.SBQQ__Quote__r = quote;
        testQuoteLine1.SBQQ__Product__r = prod;
        testQuoteLine1.id =  fflib_IDGenerator.generate(Schema.SBQQ__QuoteLine__c.SObjectType);
        testQuoteLine1.Pricing_Change_Request_cb__c = false;
        testQuoteLine1.Pricing_Approved_Start_Date_Dt__c = Date.parse('12/30/2022');
        testQuoteLine1.Pricing_Status_Nm__c = Label.Pricing_Tender_QuoteLine_Status_PendingFurtherIntelReview;
        testQuoteLine1.Pricing_Market_Segment_Nm__c = Label.Pricing_Tender_QuoteLine_Market_Segment_Embedded;
        testQuoteLine1.Pricing_Market_Segment_values_Nm__c = 'test';
        testQuoteLine1.Pricing_Quote_Line_Won_Lost_Status__c = Label.Pricing_Tender_QuoteLine_Status_Won;
        testQuoteLine1.Pricing_Update_Status_to_Rejected_cb__c = true;
        testQuoteLine1.Pricing_Ready_for_Review_cb__c = true;
        testQuoteLine1.Pricing_Previous_Status_Nm__c = 'Pending';
        testQuoteLine1.Pricing_Quote_Line_Status_Number__c = 20;
         testQuoteLine1.Pricing_Program_Type_Nm__c = Label.Pricing_Tender_SSD_Quote;
        
        SBQQ__QuoteLine__c testQuoteLine2 = new SBQQ__QuoteLine__c();
        testQuoteLine2.SBQQ__Quote__c = quote.id;
        testQuoteLine2.SBQQ__Quote__r = quote;
        testQuoteLine2.Pricing_Status_Nm__c = Label.Pricing_Tender_QuoteLine_Status_PendingIntelFieldReview ;
        testQuoteLine2.id =  fflib_IDGenerator.generate(Schema.SBQQ__QuoteLine__c.SObjectType);
        testQuoteLine2.Pricing_Approved_Start_Date_Dt__c = Date.parse('12/31/2022');
        testQuoteLine2.Pricing_Market_Segment_values_Nm__c = 'test1;';
        testQuoteLine2.Pricing_Update_Status_to_Rejected_cb__c = false;
        testQuoteLine2.Pricing_Ready_for_Review_cb__c = false;
        testQuoteLine2.Pricing_Quote_Line_Status_Number__c = 45;
        
        Pricing_Comments__c cmnt = new Pricing_Comments__c();
        cmnt.Pricing_Quote__c = quote.id;
        
        ProcessInstance pi = new ProcessInstance();
        pi.TargetObjectId = testQuoteLine1.id;
        
        ProcessInstanceWorkitem pwi = new ProcessInstanceWorkitem();
        pwi.ProcessInstance = pi;
        pwi.OriginalActorId = fflib_IDGenerator.generate(Schema.User.SObjectType);
        
        mocks.startStubbing();
        
        mocks.when(psaSelectorMock.sObjectType()).thenReturn(Schema.PermissionSetAssignment.SObjectType);
        mocks.when(quoteSelectorMock.sObjectType()).thenReturn(Schema.SBQQ__Quote__c.SObjectType);
        mocks.when(cmntSelectorMock.sObjectType()).thenReturn(Schema.Pricing_Comments__c.SObjectType);
        mocks.when(qliSelectorMock.sObjectType()).thenReturn(Schema.SBQQ__QuoteLine__c.SObjectType);
        mocks.when(pwiSelectorMock.sObjectType()).thenReturn(Schema.ProcessInstanceWorkitem.SObjectType);
        
        mocks.when(psaSelectorMock.selectbyName(UserInfo.getUserId(),new Set < String > {Label.Pricing_Tender_PermissionSets_PricingTenderRegionalPricingManager})).thenReturn(true);
        mocks.when(quoteSelectorMock.selectByIds(new Set<Id>{testQuoteLine1.SBQQ__Quote__c})).thenReturn(new List<SBQQ__Quote__c>{quote});
        mocks.when(cmntSelectorMock.selectByIdsAndReq((Set<Id>) fflib_Match.anyObject(),(Id) fflib_Match.anyObject())).thenReturn(new List<Pricing_Comments__c>{cmnt});
        mocks.when(qliSelectorMock.selectByIdsAndPM(new Set<Id>{testQuoteLine1.id})).thenReturn(new List<SBQQ__QuoteLine__c>{testQuoteLine1});
        mocks.when(qliSelectorMock.selectByRefQlis(new Set<Id>{testQuoteLine1.id})).thenReturn(new List<SBQQ__QuoteLine__c>{testQuoteLine1});
        mocks.when(qliSelectorMock.selectByQuoteLineIds((Set<Id>) fflib_Match.anyObject())).thenReturn(new List<SBQQ__QuoteLine__c>{testQuoteLine1});
        mocks.when(qliSelectorMock.selectByRefQLIIdsAndStatus((Set<Id>) fflib_Match.anyObject(),(String) fflib_Match.anyObject())).thenReturn(new List<SBQQ__QuoteLine__c>{testQuoteLine1});
        mocks.when(qliSelectorMock.selectByIdAndProduct((Set<Id>) fflib_Match.anyObject())).thenReturn(new List<SBQQ__QuoteLine__c>{testQuoteLine1});
        mocks.when(pwiSelectorMock.selectbyQliIdsandStatus(new Set<Id>{testQuoteLine1.id},'Pending')).thenReturn(new List<ProcessInstanceWorkitem>{pwi});
        
        mocks.stopStubbing();
        
        Pricing_IQR_Application.unitOfWork.setMock(uowMock);
        Pricing_IQR_Application.Selector.setMock(psaSelectorMock);
        Pricing_IQR_Application.Selector.setMock(quoteSelectorMock);
        Pricing_IQR_Application.Selector.setMock(cmntSelectorMock);
        Pricing_IQR_Application.Selector.setMock(qliSelectorMock);
        Pricing_IQR_Application.Selector.setMock(pwiSelectorMock);
        
        Test.startTest();
        Pricing_QuoteTeam_Trigger_Handler.hasQuoteLineResubmission = false;
        Pricing_QuoteLineBusinessLogic_Mock.updateQuoteLineDetails(new List<SBQQ__QuoteLine__c>{testQuoteLine1},false,new Map < id, SBQQ__QuoteLine__c >{testQuoteLine1.id => testQuoteLine2});
        Test.stopTest();
        
        System.debug('Number of Queries used in this apex code so far: ' + Limits.getQueries());
    }
    
    
    @isTest
    static void test_updateQuoteLineNumber(){
        
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork uowMock = new fflib_SObjectMocks.SObjectUnitOfWork(mocks);
        
        Pricing_Quote_Selector quoteSelectorMock = (Pricing_Quote_Selector) mocks.mock(Pricing_Quote_Selector.class);
        Pricing_QuoteLines_Selector qliSelectorMock = (Pricing_QuoteLines_Selector) mocks.mock(Pricing_QuoteLines_Selector.class);
        
        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        quote.id = fflib_IDGenerator.generate(Schema.SBQQ__Quote__c.SObjectType);
        
        SBQQ__QuoteLine__c testQuoteLine =new SBQQ__QuoteLine__c();
        testQuoteLine.SBQQ__Quote__c = quote.id;
        testQuoteLine.SBQQ__Quote__r = quote;
        testQuoteLine.id =  fflib_IDGenerator.generate(Schema.SBQQ__QuoteLine__c.SObjectType);
        
        SBQQ__QuoteLine__c testQuoteLine1 =new SBQQ__QuoteLine__c();
        testQuoteLine1.SBQQ__Quote__c = quote.id;
        testQuoteLine1.SBQQ__Quote__r = quote;
        testQuoteLine1.id =  fflib_IDGenerator.generate(Schema.SBQQ__QuoteLine__c.SObjectType);
        testQuoteLine1.Pricing_Quote_Line_Number__c =  'test-001-001';
        
        mocks.startStubbing();
        
        mocks.when(quoteSelectorMock.sObjectType()).thenReturn(Schema.SBQQ__Quote__c.SObjectType);
        mocks.when(qliSelectorMock.sObjectType()).thenReturn(Schema.SBQQ__QuoteLine__c.SObjectType);
        
        mocks.when(quoteSelectorMock.selectByIds(new Set<Id>{quote.id})).thenReturn(new List<SBQQ__Quote__c>{quote});
        mocks.when(qliSelectorMock.selectByQuoteIdAndRefQlisNull(new Set<Id>{quote.id})).thenReturn(new List<SBQQ__QuoteLine__c>{testQuoteLine1});
        
        mocks.stopStubbing();
        
        Pricing_IQR_Application.unitOfWork.setMock(uowMock);
        Pricing_IQR_Application.Selector.setMock(quoteSelectorMock);
        Pricing_IQR_Application.Selector.setMock(qliSelectorMock);
        
        Test.startTest();
        Pricing_QuoteLineBusinessLogic_Mock.updateQuoteLineNumber(new List<SBQQ__QuoteLine__c>{testQuoteLine});
        Test.stopTest();
        
        System.debug('Number of Queries used in this apex code so far: ' + Limits.getQueries());
    }
    
    @isTest
    static void test_updateQuoteLineNumber2(){
        
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork uowMock = new fflib_SObjectMocks.SObjectUnitOfWork(mocks);
        
        Pricing_Quote_Selector quoteSelectorMock = (Pricing_Quote_Selector) mocks.mock(Pricing_Quote_Selector.class);
        Pricing_QuoteLines_Selector qliSelectorMock = (Pricing_QuoteLines_Selector) mocks.mock(Pricing_QuoteLines_Selector.class);
        
        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        quote.id = fflib_IDGenerator.generate(Schema.SBQQ__Quote__c.SObjectType);
        
        SBQQ__QuoteLine__c testQuoteLine =new SBQQ__QuoteLine__c();
        testQuoteLine.SBQQ__Quote__c = quote.id;
        testQuoteLine.SBQQ__Quote__r = quote;
        testQuoteLine.id =  fflib_IDGenerator.generate(Schema.SBQQ__QuoteLine__c.SObjectType);
        
        mocks.startStubbing();
        
        mocks.when(quoteSelectorMock.sObjectType()).thenReturn(Schema.SBQQ__Quote__c.SObjectType);
        mocks.when(qliSelectorMock.sObjectType()).thenReturn(Schema.SBQQ__QuoteLine__c.SObjectType);
        
        mocks.when(quoteSelectorMock.selectByIds(new Set<Id>{quote.id})).thenReturn(new List<SBQQ__Quote__c>{quote});
        mocks.when(qliSelectorMock.selectByQuoteIdAndRefQlisNull(new Set<Id>{quote.id})).thenReturn(new List<SBQQ__QuoteLine__c>{testQuoteLine});
        
        mocks.stopStubbing();
        
        Pricing_IQR_Application.unitOfWork.setMock(uowMock);
        Pricing_IQR_Application.Selector.setMock(quoteSelectorMock);
        Pricing_IQR_Application.Selector.setMock(qliSelectorMock);
        
        Test.startTest();
        Pricing_QuoteLineBusinessLogic_Mock.updateQuoteLineNumber(new List<SBQQ__QuoteLine__c>{testQuoteLine});
        Test.stopTest();
        
        System.debug('Number of Queries used in this apex code so far: ' + Limits.getQueries());
    }
    
    @isTest
    static void test_updateQuoteStatus(){
        
        Core_Trigger_Executions__c triggerEntry2 = new Core_Trigger_Executions__c();
        triggerEntry2.name = 'pricingSendOutboundMessagesIQR';
        triggerEntry2.Core_Object__c = 'Descriptive Feature';
        triggerEntry2.Core_Trigger_Events__c = 'After insert';
        triggerEntry2.Core_Active__c = TRUE;
        triggerEntry2.Core_Description__c = 'This is test description';
        triggerEntry2.Core_Class_Name__c = 'Test Class';
        insert triggerEntry2;
        
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork uowMock = new fflib_SObjectMocks.SObjectUnitOfWork(mocks);
        
        Pricing_QuoteLines_Selector qliSelectorMock = (Pricing_QuoteLines_Selector) mocks.mock(Pricing_QuoteLines_Selector.class);
        
        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        quote.id = fflib_IDGenerator.generate(Schema.SBQQ__Quote__c.SObjectType);
        
        SBQQ__QuoteLine__c testQuoteLine2 =new SBQQ__QuoteLine__c();
        testQuoteLine2.SBQQ__Quote__c = quote.id;
        testQuoteLine2.SBQQ__Quote__r = quote;
        testQuoteLine2.Pricing_Status_Nm__c = Label.Pricing_Tender_QuoteLine_Status_PendingIntelFieldReview;
        testQuoteLine2.id =  fflib_IDGenerator.generate(Schema.SBQQ__QuoteLine__c.SObjectType);
        testQuoteLine2.Pricing_Approved_Start_Date_Dt__c = Date.parse('12/31/2022');
        testQuoteLine2.Pricing_Market_Segment_values_Nm__c = 'test1;';
        testQuoteLine2.Pricing_Integration_Status_Nm__c = Label.Pricing_Tender_MyDeal_Integration_Status_Complete;
        
        
        SBQQ__QuoteLine__c testQuoteLine1 =new SBQQ__QuoteLine__c();
        testQuoteLine1.SBQQ__Quote__c = quote.id;
        testQuoteLine1.SBQQ__Quote__r = quote;
        testQuoteLine1.id =  fflib_IDGenerator.generate(Schema.SBQQ__QuoteLine__c.SObjectType);
        testQuoteLine1.Pricing_Change_Request_cb__c = true;
        testQuoteLine1.Pricing_Approved_Start_Date_Dt__c = Date.parse('12/30/2022');
        testQuoteLine1.Pricing_Status_Nm__c = Label.Pricing_Tender_QuoteLine_Status_Approved;
        testQuoteLine1.Pricing_Market_Segment_Nm__c = Label.Pricing_Tender_QuoteLine_Market_Segment_Embedded;
        testQuoteLine1.Pricing_Market_Segment_values_Nm__c = 'test';
        testQuoteLine1.Pricing_Quote_Line_Won_Lost_Status__c = Label.Pricing_Tender_QuoteLine_Status_Won;
        testQuoteLine1.Pricing_Reference_Quote_Line_Nbr__c = testQuoteLine1.id;
        
        
        
        mocks.startStubbing();
        
        mocks.when(qliSelectorMock.sObjectType()).thenReturn(Schema.SBQQ__QuoteLine__c.SObjectType);
        mocks.when(qliSelectorMock.selectByQuoteLineIds((Set<Id>) fflib_Match.anyObject())).thenReturn(new List<SBQQ__QuoteLine__c>{testQuoteLine1});
        
        mocks.stopStubbing();
        
        Pricing_IQR_Application.unitOfWork.setMock(uowMock);
        Pricing_IQR_Application.Selector.setMock(qliSelectorMock);
        
        Test.startTest();
        Pricing_QuoteLineBusinessLogic_Mock.updateQuoteStatus(new List<SBQQ__QuoteLine__c>{testQuoteLine1},new Map < id, SBQQ__QuoteLine__c >{testQuoteLine1.id => testQuoteLine2});
        Test.stopTest();
        
        System.debug('Number of Queries used in this apex code so far: ' + Limits.getQueries());
    }
    
    @isTest
    static void test_updateQuoteStatus2(){
        
        Core_Trigger_Executions__c triggerEntry2 = new Core_Trigger_Executions__c();
        triggerEntry2.name = 'pricingSendOutboundMessagesIQR';
        triggerEntry2.Core_Object__c = 'Descriptive Feature';
        triggerEntry2.Core_Trigger_Events__c = 'After insert';
        triggerEntry2.Core_Active__c = TRUE;
        triggerEntry2.Core_Description__c = 'This is test description';
        triggerEntry2.Core_Class_Name__c = 'Test Class';
        insert triggerEntry2;
        
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork uowMock = new fflib_SObjectMocks.SObjectUnitOfWork(mocks);
        
        Pricing_QuoteLines_Selector qliSelectorMock = (Pricing_QuoteLines_Selector) mocks.mock(Pricing_QuoteLines_Selector.class);
        
        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        quote.id = fflib_IDGenerator.generate(Schema.SBQQ__Quote__c.SObjectType);
        
        SBQQ__QuoteLine__c testQuoteLine2 =new SBQQ__QuoteLine__c();
        testQuoteLine2.SBQQ__Quote__c = quote.id;
        testQuoteLine2.SBQQ__Quote__r = quote;
        testQuoteLine2.Pricing_Status_Nm__c = Label.Pricing_Tender_QuoteLine_Status_PendingFurtherIntelReview;
        testQuoteLine2.id =  fflib_IDGenerator.generate(Schema.SBQQ__QuoteLine__c.SObjectType);
        testQuoteLine2.Pricing_Approved_Start_Date_Dt__c = Date.parse('12/31/2022');
        testQuoteLine2.Pricing_Market_Segment_values_Nm__c = 'test1;';
        testQuoteLine2.Pricing_Integration_Status_Nm__c = Label.Pricing_Tender_MyDeal_Integration_Status_Complete;
        testQuoteLine2.Pricing_Previous_Status_Nm__c = 'Pending';
        
        SBQQ__QuoteLine__c testQuoteLine1 =new SBQQ__QuoteLine__c();
        testQuoteLine1.SBQQ__Quote__c = quote.id;
        testQuoteLine1.SBQQ__Quote__r = quote;
        testQuoteLine1.id =  fflib_IDGenerator.generate(Schema.SBQQ__QuoteLine__c.SObjectType);
        testQuoteLine1.Pricing_Change_Request_cb__c = true;
        testQuoteLine1.Pricing_Approved_Start_Date_Dt__c = Date.parse('12/30/2022');
        testQuoteLine1.Pricing_Status_Nm__c = Label.Pricing_Tender_QuoteLine_Status_Rejected;
        testQuoteLine1.Pricing_Market_Segment_Nm__c = Label.Pricing_Tender_QuoteLine_Market_Segment_Embedded;
        testQuoteLine1.Pricing_Market_Segment_values_Nm__c = 'test';
        testQuoteLine1.Pricing_Quote_Line_Won_Lost_Status__c = Label.Pricing_Tender_QuoteLine_Status_Won;
        testQuoteLine1.Pricing_Reference_Quote_Line_Nbr__c = testQuoteLine2.id;
        testQuoteLine1.Pricing_Previous_Status_Nm__c = 'Rejected';
        
        
        mocks.startStubbing();
        
        mocks.when(qliSelectorMock.sObjectType()).thenReturn(Schema.SBQQ__QuoteLine__c.SObjectType);
        mocks.when(qliSelectorMock.selectByQuoteLineIds((Set<Id>) fflib_Match.anyObject())).thenReturn(new List<SBQQ__QuoteLine__c>{testQuoteLine1});
        
        mocks.stopStubbing();
        
        Pricing_IQR_Application.unitOfWork.setMock(uowMock);
        Pricing_IQR_Application.Selector.setMock(qliSelectorMock);
        
        Test.startTest();
        Pricing_QuoteLineBusinessLogic_Mock.updateQuoteStatus(new List<SBQQ__QuoteLine__c>{testQuoteLine1},new Map < id, SBQQ__QuoteLine__c >{testQuoteLine1.id => testQuoteLine2});
        Test.stopTest();
        
        System.debug('Number of Queries used in this apex code so far: ' + Limits.getQueries());
    }
    
    @isTest
    static void test_validateQLEditWithPFIRNotRPM(){
        
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork uowMock = new fflib_SObjectMocks.SObjectUnitOfWork(mocks);
        
        Pricing_PermissionSetAssignment_Selector psaSelectorMock = (Pricing_PermissionSetAssignment_Selector) mocks.mock(Pricing_PermissionSetAssignment_Selector.class);
        
        PermissionSet ps = new PermissionSet();
        ps.Name = Label.Pricing_Tender_PermissionSets_TenderUser;
        
        PermissionSetAssignment psa = new PermissionSetAssignment();
        psa.PermissionSet = ps;
        
        SBQQ__QuoteLine__c testQuoteLine1 =new SBQQ__QuoteLine__c();
        testQuoteLine1.SBQQ__Quote__c = fflib_IDGenerator.generate(Schema.SBQQ__Quote__c.SObjectType);
        testQuoteLine1.id =  fflib_IDGenerator.generate(Schema.SBQQ__QuoteLine__c.SObjectType);
        testQuoteLine1.Pricing_Status_Nm__c = Label.Pricing_Tender_QuoteLine_Status_PendingFurtherIntelReview;
        
        SBQQ__QuoteLine__c testQuoteLine2 =new SBQQ__QuoteLine__c();
        testQuoteLine2.SBQQ__Quote__c = testQuoteLine1.SBQQ__Quote__c;
        testQuoteLine2.Pricing_Status_Nm__c = Label.Pricing_Tender_QuoteLine_Status_PendingFurtherIntelReview;
        testQuoteLine2.id =  fflib_IDGenerator.generate(Schema.SBQQ__QuoteLine__c.SObjectType);
        
        
        mocks.startStubbing();
        
        mocks.when(psaSelectorMock.sObjectType()).thenReturn(Schema.PermissionSetAssignment.SObjectType);
        mocks.when(psaSelectorMock.selectbyUserId(UserInfo.getUserId())).thenReturn(new List<PermissionSetAssignment>{psa});
        
        mocks.stopStubbing();
        
        Pricing_IQR_Application.unitOfWork.setMock(uowMock);
        Pricing_IQR_Application.Selector.setMock(psaSelectorMock);
        
        Test.startTest();
        Pricing_QuoteLineBusinessLogic_Mock.validateQLEditWithPFIRNotRPM(new List<SBQQ__QuoteLine__c>{testQuoteLine1},new Map < id, SBQQ__QuoteLine__c >{testQuoteLine1.id => testQuoteLine2});
        Test.stopTest();
        
        System.debug('Number of Queries used in this apex code so far: ' + Limits.getQueries());
    }
    
    @isTest
    static void test_PopulateQLStatusAgeRecord(){
        
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork uowMock = new fflib_SObjectMocks.SObjectUnitOfWork(mocks);
        
        SBQQ__QuoteLine__c testQuoteLine1 =new SBQQ__QuoteLine__c();
        testQuoteLine1.SBQQ__Quote__c = fflib_IDGenerator.generate(Schema.SBQQ__Quote__c.SObjectType);
        testQuoteLine1.id =  fflib_IDGenerator.generate(Schema.SBQQ__QuoteLine__c.SObjectType);
        testQuoteLine1.Pricing_Status_Nm__c = Label.Pricing_Tender_QuoteLine_Status_Draft;
        
        SBQQ__QuoteLine__c testQuoteLine2 =new SBQQ__QuoteLine__c();
        testQuoteLine2.SBQQ__Quote__c = testQuoteLine1.SBQQ__Quote__c;
        testQuoteLine2.Pricing_Status_Nm__c = Label.Pricing_Tender_QuoteLine_Status_PendingFurtherIntelReview;
        testQuoteLine2.id =  fflib_IDGenerator.generate(Schema.SBQQ__QuoteLine__c.SObjectType);
        
        Pricing_IQR_Application.unitOfWork.setMock(uowMock);
        
        Test.startTest();
        Pricing_QuoteLineBusinessLogic_Mock.PopulateQLStatusAgeRecord(new List<SBQQ__QuoteLine__c>{testQuoteLine1},new Map < id, SBQQ__QuoteLine__c >{testQuoteLine1.id => testQuoteLine2},true,false,null,null,null,null);
        Pricing_QuoteLineBusinessLogic_Mock.PopulateQLStatusAgeRecord(new List<SBQQ__QuoteLine__c>{testQuoteLine1},new Map < id, SBQQ__QuoteLine__c >{testQuoteLine1.id => testQuoteLine2},false,false,null,null,null,null);
        Test.stopTest();
        
        System.debug('Number of Queries used in this apex code so far: ' + Limits.getQueries());
    }
    
    @isTest
    static void test_CreateQuoteLineStatusAgeRecord(){
        
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork uowMock = new fflib_SObjectMocks.SObjectUnitOfWork(mocks);
        
        SBQQ__QuoteLine__c testQuoteLine1 =new SBQQ__QuoteLine__c();
        testQuoteLine1.SBQQ__Quote__c = fflib_IDGenerator.generate(Schema.SBQQ__Quote__c.SObjectType);
        testQuoteLine1.id =  fflib_IDGenerator.generate(Schema.SBQQ__QuoteLine__c.SObjectType);
        testQuoteLine1.Pricing_Status_Nm__c = Label.Pricing_Tender_QuoteLine_Status_Draft;
        
        Pricing_IQR_Application.unitOfWork.setMock(uowMock);
        
        Test.startTest();
        Pricing_QuoteLineBusinessLogic_Mock.CreateQuoteLineStatusAgeRecord(new List<SBQQ__QuoteLine__c>{testQuoteLine1},true);
        Test.stopTest();
        
        System.debug('Number of Queries used in this apex code so far: ' + Limits.getQueries());
    }
    
    @isTest
    static void test_UpdateQuoteLineStatusAgeRecord(){
        
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork uowMock = new fflib_SObjectMocks.SObjectUnitOfWork(mocks);
        
        Pricing_QuoteLines_Selector qliSelectorMock = (Pricing_QuoteLines_Selector) mocks.mock(Pricing_QuoteLines_Selector.class);
        Pricing_Quote_Line_Status_Age_Selector tptSelectorMock = (Pricing_Quote_Line_Status_Age_Selector) mocks.mock(Pricing_Quote_Line_Status_Age_Selector.class);
        Pricing_PermissionSetAssignment_Selector psaSelectorMock = (Pricing_PermissionSetAssignment_Selector) mocks.mock(Pricing_PermissionSetAssignment_Selector.class);
        
        PermissionSet ps = new PermissionSet();
        ps.Name = Label.Pricing_Tender_Permission_Set_IT_Specialist;
        
        PermissionSetAssignment psa = new PermissionSetAssignment();
        psa.PermissionSet = ps;
        
        SBQQ__QuoteLine__c testQuoteLine1 =new SBQQ__QuoteLine__c();
        testQuoteLine1.SBQQ__Quote__c = fflib_IDGenerator.generate(Schema.SBQQ__Quote__c.SObjectType);
        testQuoteLine1.id =  fflib_IDGenerator.generate(Schema.SBQQ__QuoteLine__c.SObjectType);
        testQuoteLine1.Pricing_Status_Nm__c = Label.Pricing_Tender_QuoteLine_Status_Draft;
        testQuoteLine1.Pricing_Original_Submitted_Date_dt__c = System.today();
        testQuoteLine1.Pricing_Last_Approved_Date_dt__c = System.today();
        testQuoteLine1.Pricing_Last_Submitted_Date_dt__c = System.today();
        
        SBQQ__QuoteLine__c testQuoteLine2 =new SBQQ__QuoteLine__c();
        testQuoteLine2.SBQQ__Quote__c = testQuoteLine1.SBQQ__Quote__c;
        testQuoteLine2.Pricing_Status_Nm__c = Label.Pricing_Tender_QuoteLine_Status_PendingFurtherIntelReview;
        testQuoteLine2.id =  fflib_IDGenerator.generate(Schema.SBQQ__QuoteLine__c.SObjectType);
        
        Pricing_Quote_Line_Status_Age__c tpt = new Pricing_Quote_Line_Status_Age__c();
        tpt.id = fflib_IDGenerator.generate(Schema.Pricing_Quote_Line_Status_Age__c.SObjectType);
        tpt.Pricing_TPT_Set_Time__c = System.today();
        tpt.Pricing_TPT_Role_Aggregate_cb__c = true;
        tpt.Pricing_TPT_User_Role__c = 'IT Specialist';
        tpt.Pricing_TPT_Aggregate_Role_Time__c =  1;
        tpt.Pricing_TPT_Status_Time__c =  1;
        tpt.Pricing_TPT_Quote_Line_Number__c =  testQuoteLine1.id;
        tpt.Pricing_TPT_Status_From__c =  'test';
        tpt.Pricing_TPT_Change_Request_QuoteLine_cb__c =  true;
   
        mocks.startStubbing();
        
        mocks.when(qliSelectorMock.sObjectType()).thenReturn(Schema.SBQQ__QuoteLine__c.SObjectType);
        mocks.when(tptSelectorMock.sObjectType()).thenReturn(Schema.Pricing_Quote_Line_Status_Age__c.SObjectType);
        mocks.when(psaSelectorMock.sObjectType()).thenReturn(Schema.PermissionSetAssignment.SObjectType);
        mocks.when(qliSelectorMock.selectByQuoteLineIds((Set<Id>) fflib_Match.anyObject())).thenReturn(new List<SBQQ__QuoteLine__c>{testQuoteLine1});
        mocks.when(tptSelectorMock.selectbyQliIdandRole((Set<Id>) fflib_Match.anyObject(),(String) fflib_Match.anyObject())).thenReturn(new List<Pricing_Quote_Line_Status_Age__c>{tpt});
        mocks.when(psaSelectorMock.selectByPSName((Id) fflib_Match.anyObject(),(Set<String>) fflib_Match.anyObject())).thenReturn(new List<PermissionSetAssignment>{psa});
        
        mocks.stopStubbing();
        
        Pricing_IQR_Application.unitOfWork.setMock(uowMock);
        Pricing_IQR_Application.Selector.setMock(qliSelectorMock);
        Pricing_IQR_Application.Selector.setMock(tptSelectorMock);
        Pricing_IQR_Application.Selector.setMock(psaSelectorMock);
        
        Test.startTest();
        Pricing_QuoteLineBusinessLogic_Mock.UpdateQuoteLineStatusAgeRecord(new List<SBQQ__QuoteLine__c>{testQuoteLine1},new Map < id, SBQQ__QuoteLine__c >{testQuoteLine1.id => testQuoteLine2},true,false,null,null,null,null);
        Test.stopTest();
        
        System.debug('Number of Queries used in this apex code so far: ' + Limits.getQueries());
    }
    
    @isTest
    static void test_UpdateQuoteLineStatusAgeRecord2(){
        
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork uowMock = new fflib_SObjectMocks.SObjectUnitOfWork(mocks);
        
        Pricing_QuoteLines_Selector qliSelectorMock = (Pricing_QuoteLines_Selector) mocks.mock(Pricing_QuoteLines_Selector.class);
        Pricing_Quote_Line_Status_Age_Selector tptSelectorMock = (Pricing_Quote_Line_Status_Age_Selector) mocks.mock(Pricing_Quote_Line_Status_Age_Selector.class);
        Pricing_PermissionSetAssignment_Selector psaSelectorMock = (Pricing_PermissionSetAssignment_Selector) mocks.mock(Pricing_PermissionSetAssignment_Selector.class);
        
        PermissionSet ps = new PermissionSet();
        ps.Name = Label.Pricing_Tender_Permission_Set_IT_Specialist;
        
        PermissionSetAssignment psa = new PermissionSetAssignment();
        psa.PermissionSet = ps;
        
        SBQQ__QuoteLine__c testQuoteLine1 =new SBQQ__QuoteLine__c();
        testQuoteLine1.SBQQ__Quote__c = fflib_IDGenerator.generate(Schema.SBQQ__Quote__c.SObjectType);
        testQuoteLine1.id =  fflib_IDGenerator.generate(Schema.SBQQ__QuoteLine__c.SObjectType);
        testQuoteLine1.Pricing_Status_Nm__c = Label.Pricing_Tender_QuoteLine_Status_Draft;
        testQuoteLine1.Pricing_Original_Submitted_Date_dt__c = System.today();
        testQuoteLine1.Pricing_Last_Submitted_Date_dt__c = System.today();
        
        SBQQ__QuoteLine__c testQuoteLine2 =new SBQQ__QuoteLine__c();
        testQuoteLine2.SBQQ__Quote__c = testQuoteLine1.SBQQ__Quote__c;
        testQuoteLine2.Pricing_Status_Nm__c = Label.Pricing_Tender_QuoteLine_Status_PendingFurtherIntelReview;
        testQuoteLine2.id =  fflib_IDGenerator.generate(Schema.SBQQ__QuoteLine__c.SObjectType);
        
        Pricing_Quote_Line_Status_Age__c tpt = new Pricing_Quote_Line_Status_Age__c();
        tpt.id = fflib_IDGenerator.generate(Schema.Pricing_Quote_Line_Status_Age__c.SObjectType);
        tpt.Pricing_TPT_Set_Time__c = System.today();
        tpt.Pricing_TPT_Change_Time__c = System.today()+7;
   
        mocks.startStubbing();
        
        mocks.when(qliSelectorMock.sObjectType()).thenReturn(Schema.SBQQ__QuoteLine__c.SObjectType);
        mocks.when(tptSelectorMock.sObjectType()).thenReturn(Schema.Pricing_Quote_Line_Status_Age__c.SObjectType);
        mocks.when(psaSelectorMock.sObjectType()).thenReturn(Schema.PermissionSetAssignment.SObjectType);
        mocks.when(qliSelectorMock.selectByQuoteLineIds((Set<Id>) fflib_Match.anyObject())).thenReturn(new List<SBQQ__QuoteLine__c>{testQuoteLine1});
        mocks.when(tptSelectorMock.selectbyQliIdandRole((Set<Id>) fflib_Match.anyObject(),(String) fflib_Match.anyObject())).thenReturn(new List<Pricing_Quote_Line_Status_Age__c>{tpt});
        mocks.when(psaSelectorMock.selectByPSName((Id) fflib_Match.anyObject(),(Set<String>) fflib_Match.anyObject())).thenReturn(new List<PermissionSetAssignment>{psa});
        
        mocks.stopStubbing();
        
        Pricing_IQR_Application.unitOfWork.setMock(uowMock);
        Pricing_IQR_Application.Selector.setMock(qliSelectorMock);
        Pricing_IQR_Application.Selector.setMock(tptSelectorMock);
        Pricing_IQR_Application.Selector.setMock(psaSelectorMock);
        
        Test.startTest();
        Pricing_QuoteLineBusinessLogic_Mock.UpdateQuoteLineStatusAgeRecord(new List<SBQQ__QuoteLine__c>{testQuoteLine1},new Map < id, SBQQ__QuoteLine__c >{testQuoteLine1.id => testQuoteLine2},true,true,null,null,null,Label.Pricing_Tender_QuoteLine_Status_Approved);
        Test.stopTest();
        
        System.debug('Number of Queries used in this apex code so far: ' + Limits.getQueries());
    }
    
    @isTest
    static void test_validateProductMismatch(){
        
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork uowMock = new fflib_SObjectMocks.SObjectUnitOfWork(mocks);
        
        Pricing_Dynamic_Data_Table_Selector dataSelectorMock = (Pricing_Dynamic_Data_Table_Selector) mocks.mock(Pricing_Dynamic_Data_Table_Selector.class);
        Pricing_Product_Selector prodSelectorMock = (Pricing_Product_Selector) mocks.mock(Pricing_Product_Selector.class);
        
        Product2 prod = new Product2();
        prod.id =  fflib_IDGenerator.generate(Schema.Product2.SObjectType);
        prod.Name = 'Test';
        
        SBQQ__QuoteLine__c testQuoteLine1 =new SBQQ__QuoteLine__c();
        testQuoteLine1.SBQQ__Quote__c = fflib_IDGenerator.generate(Schema.SBQQ__Quote__c.SObjectType);
        testQuoteLine1.id =  fflib_IDGenerator.generate(Schema.SBQQ__QuoteLine__c.SObjectType);
        testQuoteLine1.Pricing_Product_Nm__c = prod.id;
        testQuoteLine1.Pricing_Product_Nm__r = prod;
        testQuoteLine1.Pricing_Program_Type_Nm__c = Label.Pricing_Tender_Small_Volume_Quote;
        
        SBQQ__QuoteLine__c testQuoteLine2 =new SBQQ__QuoteLine__c();
        testQuoteLine2.SBQQ__Quote__c = testQuoteLine1.SBQQ__Quote__c;
        testQuoteLine2.Pricing_Status_Nm__c = Label.Pricing_Tender_QuoteLine_Status_PendingFurtherIntelReview;
        testQuoteLine2.id =  fflib_IDGenerator.generate(Schema.SBQQ__QuoteLine__c.SObjectType);
        testQuoteLine1.Pricing_Product_Nm__c = prod.id;
        testQuoteLine1.Pricing_Product_Nm__r = prod;
        
        Pricing_Dynamic_Data_Table__mdt data = new Pricing_Dynamic_Data_Table__mdt();
        data.Pricing_Query__c = 'test';
        data.Pricing_Where_Clause__c = 'test';
        data.Pricing_Record_Type__c = Label.Pricing_Tender_Small_Volume_Quote;
   
        mocks.startStubbing();
        
        mocks.when(dataSelectorMock.sObjectType()).thenReturn(Schema.Pricing_Dynamic_Data_Table__mdt.SObjectType);
        mocks.when(prodSelectorMock.sObjectType()).thenReturn(Schema.Product2.SObjectType);
        mocks.when(dataSelectorMock.selectByType((Set<String>) fflib_Match.anyObject())).thenReturn(new List<Pricing_Dynamic_Data_Table__mdt>{data});
        mocks.when(prodSelectorMock.selectByText((String) fflib_Match.anyObject())).thenReturn(new List<Product2>{prod});
        
        mocks.stopStubbing();
        
        Pricing_IQR_Application.unitOfWork.setMock(uowMock);
        Pricing_IQR_Application.Selector.setMock(dataSelectorMock);
        Pricing_IQR_Application.Selector.setMock(prodSelectorMock);
        
        Test.startTest();
        Pricing_QuoteLineBusinessLogic_Mock.validateProductMismatch(new List<SBQQ__QuoteLine__c>{testQuoteLine1},true,new Map < id, SBQQ__QuoteLine__c >{testQuoteLine1.id => testQuoteLine2});
        Test.stopTest();
        
        System.debug('Number of Queries used in this apex code so far: ' + Limits.getQueries());
    }
    
    @isTest
    static void test_generateQuoteLetter(){
        
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork uowMock = new fflib_SObjectMocks.SObjectUnitOfWork(mocks);
        
        Pricing_Quote_Selector quoteSelectorMock = (Pricing_Quote_Selector) mocks.mock(Pricing_Quote_Selector.class);
        
        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        quote.id = fflib_IDGenerator.generate(Schema.SBQQ__Quote__c.SObjectType);
        
        SBQQ__QuoteLine__c testQuoteLine1 =new SBQQ__QuoteLine__c();
        testQuoteLine1.SBQQ__Quote__c = quote.id;
        testQuoteLine1.id =  fflib_IDGenerator.generate(Schema.SBQQ__QuoteLine__c.SObjectType);
        testQuoteLine1.Pricing_Status_Nm__c = Label.Pricing_Tender_QuoteLine_Status_Approved;
        
        SBQQ__QuoteLine__c testQuoteLine2 =new SBQQ__QuoteLine__c();
        testQuoteLine2.SBQQ__Quote__c = testQuoteLine1.SBQQ__Quote__c;
        testQuoteLine2.Pricing_Status_Nm__c = Label.Pricing_Tender_QuoteLine_Status_PendingFurtherIntelReview;
        testQuoteLine2.id = testQuoteLine1.id;
        
        Pricing_Dynamic_Data_Table__mdt data = new Pricing_Dynamic_Data_Table__mdt();
        data.Pricing_Query__c = 'test';
        data.Pricing_Where_Clause__c = 'test';
        data.Pricing_Record_Type__c = Label.Pricing_Tender_Small_Volume_Quote;
   
        mocks.startStubbing();
        
        mocks.when(quoteSelectorMock.sObjectType()).thenReturn(Schema.SBQQ__Quote__c.SObjectType);
        mocks.when(quoteSelectorMock.selectByQuoteLetter((Set<Id>) fflib_Match.anyObject())).thenReturn(new List<SBQQ__Quote__c>{quote});
        
        mocks.stopStubbing();
        
        Pricing_IQR_Application.unitOfWork.setMock(uowMock);
        Pricing_IQR_Application.Selector.setMock(quoteSelectorMock);
        
        Test.startTest();
        Pricing_QuoteLineBusinessLogic_Mock.generateQuoteLetter(new List<SBQQ__QuoteLine__c>{testQuoteLine1},new Map < id, SBQQ__QuoteLine__c >{testQuoteLine1.id => testQuoteLine2});
        Test.stopTest();
        
        System.debug('Number of Queries used in this apex code so far: ' + Limits.getQueries());
    }
    
    @isTest
    static void test_updateQuoteLineRecords(){
        
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork uowMock = new fflib_SObjectMocks.SObjectUnitOfWork(mocks);
        
        Pricing_Quote_Selector quoteSelectorMock = (Pricing_Quote_Selector) mocks.mock(Pricing_Quote_Selector.class);
        
        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        quote.id = fflib_IDGenerator.generate(Schema.SBQQ__Quote__c.SObjectType);
        
        SBQQ__QuoteLine__c testQuoteLine1 =new SBQQ__QuoteLine__c();
        testQuoteLine1.SBQQ__Quote__c = quote.id;
        testQuoteLine1.id =  fflib_IDGenerator.generate(Schema.SBQQ__QuoteLine__c.SObjectType);
        testQuoteLine1.Pricing_Status_Nm__c = Label.Pricing_Tender_QuoteLine_Status_Approved;
   
        mocks.startStubbing();
        
        mocks.when(quoteSelectorMock.sObjectType()).thenReturn(Schema.SBQQ__Quote__c.SObjectType);
        mocks.when(quoteSelectorMock.selectByIds((Set<Id>) fflib_Match.anyObject())).thenReturn(new List<SBQQ__Quote__c>{quote});
        
        mocks.stopStubbing();
        
        Pricing_IQR_Application.unitOfWork.setMock(uowMock);
        Pricing_IQR_Application.Selector.setMock(quoteSelectorMock);
        
        Test.startTest();
        Pricing_QuoteLineBusinessLogic_Mock.updateQuoteLineRecords(new List<List<SBQQ__QuoteLine__c>>{new List<SBQQ__QuoteLine__c>{testQuoteLine1}});
        Test.stopTest();
        
        System.debug('Number of Queries used in this apex code so far: ' + Limits.getQueries());
    }
    
    @isTest
    static void test_calculateStatusAge(){
        
        Test.startTest();
        Pricing_QuoteLineBusinessLogic_Mock.calculateStatusAge(System.today(),System.today()+7);
        Test.stopTest();
    }
}