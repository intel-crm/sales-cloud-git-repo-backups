@isTest
public class Pricing_PerformanceMetrics_Mock_Test {
    @isTest
    static void test_showQuoteLineDetail(){
        //using a mock library to create a mock object.
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        
        //using the mock object to generate mock selector class of interface of the selector class.
        Pricing_QuoteLines_Selector quotelinesSelectorMock = (Pricing_QuoteLines_Selector) mocks.mock(Pricing_QuoteLines_Selector.class);
        
        //using an id generator supported by fflib library to get only the id which is required by our method 
        //which leverages the work of creating an entire record for the purpose of only using the id.
        Id quotelinesId = fflib_IDGenerator.generate(Schema.SBQQ__QuoteLine__c.SObjectType);
        
        SBQQ__Quoteline__c qli = new SBQQ__QuoteLine__c();
        qli.Pricing_Program_Type_Nm__c= 'test';
        
        
        
        
        //starting the stub where we will tell the mock class that when this selector query is called from
        //controller method the record created above should be returned.
        mocks.startStubbing();
        
        //next line is mandatory for all selector stubbing since in the fflib_Application there is mockSobject map which 
        //maps the sobject to the mock class created.
        mocks.when(quotelinesSelectorMock.sObjectType()).thenReturn(Schema.SBQQ__Quoteline__c.SObjectType);
        
        //here we are defining the return record which the query should return when the same argument is passed from the 
        //controller class on test execution.
        mocks.when(quotelinesSelectorMock.selectByQuoteLineIds((Set<Id>) fflib_Match.anyObject())).thenReturn(new List<SBQQ__Quoteline__c>{qli});
        
        //stoping the stub.
        mocks.stopStubbing();
        
        //calling setMock method to map the sobject with the mock class generated using ApexMocks.
        Pricing_IQR_Application.Selector.setMock(quotelinesSelectorMock);
        
        //doing the test by calling the method with the id generated earlier.
        Test.startTest();
        Pricing_PerformanceMetrics_Mock.showQuoteLineDetail(quotelinesId);
        
        
        Test.stopTest();
        
        // using verify method which works same as the assert
        // here it check that the selector method is called how many times.        
        ((Pricing_QuoteLines_Selector) mocks.verify(quotelinesSelectorMock,1)).selectByQuoteLineIds((Set<Id>) fflib_Match.anyObject());
        //System.assert(returnedQuoteLines.size()==1);
        System.debug('Number of Queries used in this apex code so far: ' + Limits.getQueries());
    }
    @isTest
    static void test_deletePerformanceMetrics(){
        //using a mock library to create a mock object.
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork uowMock = new fflib_SObjectMocks.SObjectUnitOfWork(mocks);
        
        //using the mock object to generate mock selector class of interface of the selector class.
        Pricing_Performance_Metric_Selector performancemetricsSelectorMock = (Pricing_Performance_Metric_Selector) mocks.mock(Pricing_Performance_Metric_Selector.class);
        
        
        //using an id generator supported by fflib library to get only the id which is required by our method 
        //which leverages the work of creating an entire record for the purpose of only using the id.
         Id pmId = fflib_IDGenerator.generate(Schema.Pricing_Performance_Metric__c.SObjectType);
        
         Pricing_Performance_Metric__c perm = new Pricing_Performance_Metric__c();
         perm.Id = pmId;
        
        
        
        
        
        //starting the stub where we will tell the mock class that when this selector query is called from
        //controller method the record created above should be returned.
        mocks.startStubbing();
        
        //next line is mandatory for all selector stubbing since in the fflib_Application there is mockSobject map which 
        //maps the sobject to the mock class created.
        mocks.when(performancemetricsSelectorMock.sObjectType()).thenReturn(Schema.Pricing_Performance_Metric__c.SObjectType);
        
        //here we are defining the return record which the query should return when the same argument is passed from the 
        //controller class on test execution.
        mocks.when(performancemetricsSelectorMock.selectByrecordIds((Id) fflib_Match.anyObject())).thenReturn(new list<Pricing_Performance_Metric__c>{perm});
        
        //stoping the stub.
        mocks.stopStubbing();
        
        //calling setMock method to map the sobject with the mock class generated using ApexMocks.
        Pricing_IQR_Application.Selector.setMock(performancemetricsSelectorMock);
        Pricing_IQR_Application.unitOfWork.setMock(uowMock);
        
        //doing the test by calling the method with the id generated earlier.
        Test.startTest();
        Pricing_PerformanceMetrics_Mock.deletePerformanceMetrics(pmId);
        
        
        Test.stopTest();
        
        // using verify method which works same as the assert
        // here it check that the selector method is called how many times.        
        ((Pricing_Performance_Metric_Selector) mocks.verify(performancemetricsSelectorMock,1)).selectByrecordIds((Id) fflib_Match.anyObject());
        //System.assert(returnedQuoteLines.size()==1);
        System.debug('Number of Queries used in this apex code so far: ' + Limits.getQueries());
    }
     @isTest
    static void test_savePerformanceMetrics(){
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork uowMock = new fflib_SObjectMocks.SObjectUnitOfWork(mocks);
        Id quotelinesId = fflib_IDGenerator.generate(Schema.SBQQ__QuoteLine__c.SObjectType);
        Id pmId = fflib_IDGenerator.generate(Schema.Pricing_Performance_Metric__c.SObjectType); 
        Pricing_Performance_Metric__c obj = new Pricing_Performance_Metric__c();
                obj.Pricing_Quote_Line__c = quotelinesId;
                obj.Pricing_Performance_Metric_Nm__c = 'tet';
                obj.Pricing_Weighting_Pct__c = 111;
                obj.Pricing_Comp_SKU_Performance_Nbr__c = 123;
                obj.Pricing_Intel_SKU_Performance_Nbr__c = 1234;
                obj.Pricing_Other_Nm__c = 'test';
        Pricing_Performance_Metric__c obj1 = new Pricing_Performance_Metric__c();
                obj1.Pricing_Quote_Line__c = quotelinesId;
                obj1.Pricing_Performance_Metric_Nm__c = 'tet';
                obj1.Pricing_Weighting_Pct__c = 111;
                obj1.Pricing_Comp_SKU_Performance_Nbr__c = 123;
                obj1.Pricing_Intel_SKU_Performance_Nbr__c = 1234;
                obj1.Pricing_Other_Nm__c = 'test';
                obj1.Id = pmId;
        
                
        
        
        Pricing_IQR_Application.unitOfWork.setMock(uowMock);
        
        Test.startTest();
        Pricing_PerformanceMetrics_Mock.savePerformanceMetrics(new list<Pricing_Performance_Metric__c>{obj},quotelinesId);
        Pricing_PerformanceMetrics_Mock.savePerformanceMetrics(new list<Pricing_Performance_Metric__c>{obj1},quotelinesId);
        Test.stopTest();
        
        System.debug('Number of Queries used in this apex code so far: ' + Limits.getQueries());
        System.debug('Number of Queries used in this apex code so far: ' + Limits.getDmlStatements());
        
    }
    @isTest
    static void test_isReadOnlyPageLayout(){
        //using a mock library to create a mock object.
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        
        //using the mock object to generate mock selector class of interface of the selector class.
        Pricing_QuoteLines_Selector quotelinesSelectorMock = (Pricing_QuoteLines_Selector) mocks.mock(Pricing_QuoteLines_Selector.class);
        Pricing_PermissionSetAssignment_Selector permissionsetassignmentSelectorMock = (Pricing_PermissionSetAssignment_Selector) mocks.mock(Pricing_PermissionSetAssignment_Selector.class);
        
        //using an id generator supported by fflib library to get only the id which is required by our method 
        //which leverages the work of creating an entire record for the purpose of only using the id.
        Id quotelinesId = fflib_IDGenerator.generate(Schema.SBQQ__QuoteLine__c.SObjectType);
        SBQQ__QuoteLine__c quoteline = new SBQQ__QuoteLine__c();
         quoteLine.Pricing_Status_Nm__c = 'tet';
         quoteLine.Pricing_Integration_Status_Nm__c = 'abcd';
         quoteLine.Pricing_Deal_RFQ_Status_Nm__c = 'test';

        
        
        
        
        
        
        
        
        //calling setMock method to map the sobject with the mock class generated using ApexMocks.
        
        //starting the stub where we will tell the mock class that when this selector query is called from
        //controller method the record created above should be returned.
        mocks.startStubbing();
        
        //next line is mandatory for all selector stubbing since in the fflib_Application there is mockSobject map which 
        //maps the sobject to the mock class created.
        mocks.when(quotelinesSelectorMock.sObjectType()).thenReturn(Schema.SBQQ__QuoteLine__c.SObjectType);
        mocks.when(permissionsetassignmentSelectorMock.sObjectType()).thenReturn(Schema.PermissionSetAssignment.SObjectType);
        
        //here we are defining the return record which the query should return when the same argument is passed from the 
        //controller class on test execution.
        mocks.when(quotelinesSelectorMock.selectByQuoteLineIds((Set<Id>) fflib_Match.anyObject())).thenReturn(new List<SBQQ__QuoteLine__c>{quoteline});
        mocks.when(permissionsetassignmentSelectorMock.selectbyUserId((Id) fflib_Match.anyObject())).thenReturn(null);
        mocks.stopStubbing();
        //stoping the stub.
        Pricing_IQR_Application.Selector.setMock(quotelinesSelectorMock);
        Pricing_IQR_Application.Selector.setMock(permissionsetassignmentSelectorMock);
        
        //doing the test by calling the method with the id generated earlier.
        Test.startTest();
        Pricing_PerformanceMetrics_Mock.isReadOnlyPageLayout(quotelinesId);
        
        
        Test.stopTest();
        
        // using verify method which works same as the assert
        // here it check that the selector method is called how many times.        
        ((Pricing_QuoteLines_Selector) mocks.verify(quotelinesSelectorMock,1)).selectByQuoteLineIds((Set<Id>) fflib_Match.anyObject());
        ((Pricing_PermissionSetAssignment_Selector) mocks.verify(permissionsetassignmentSelectorMock,1)).selectbyUserId((Id) fflib_Match.anyObject());
        //System.assert(returnedQuoteLines.size()==1);
        System.debug('Number of Queries used in this apex code so far: ' + Limits.getQueries());
    }
    @isTest
    static void test_getPerformanceMetrics(){
        //using a mock library to create a mock object.
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        
        //using the mock object to generate mock selector class of interface of the selector class.
        Pricing_Performance_Metric_Selector performancemetricSelectorMock = (Pricing_Performance_Metric_Selector) mocks.mock(Pricing_Performance_Metric_Selector.class);
       
        
        //using an id generator supported by fflib library to get only the id which is required by our method 
        //which leverages the work of creating an entire record for the purpose of only using the id.
        Id quotelinesId = fflib_IDGenerator.generate(Schema.Pricing_Performance_Metric__c.SObjectType);
        
        //starting the stub where we will tell the mock class that when this selector query is called from
        //controller method the record created above should be returned.
        mocks.startStubbing();
        
        //next line is mandatory for all selector stubbing since in the fflib_Application there is mockSobject map which 
        //maps the sobject to the mock class created.
        mocks.when(performancemetricSelectorMock.sObjectType()).thenReturn(Schema.Pricing_Performance_Metric__c.SObjectType);
        
        
        //here we are defining the return record which the query should return when the same argument is passed from the 
        //controller class on test execution.
       mocks.when(performancemetricSelectorMock.selectByQuoteLineIds((Id) fflib_Match.anyObject())).thenReturn(null);
        
        mocks.stopStubbing();
        //stoping the stub.
        Pricing_IQR_Application.Selector.setMock(performancemetricSelectorMock);
        
        
        //doing the test by calling the method with the id generated earlier.
        Test.startTest();
        Pricing_PerformanceMetrics_Mock.getPerformanceMetrics(quotelinesId);
        
        
        Test.stopTest();
        
        // using verify method which works same as the assert
        // here it check that the selector method is called how many times.        
        ((Pricing_Performance_Metric_Selector) mocks.verify(performancemetricSelectorMock,1)).selectByQuoteLineIds((Id) fflib_Match.anyObject());
        
        //System.assert(returnedQuoteLines.size()==1);
        System.debug('Number of Queries used in this apex code so far: ' + Limits.getQueries());
    }
    @isTest
    static void test_isCreateable(){
        //using a mock library to create a mock object.
        fflib_ApexMocks mocks = new fflib_ApexMocks();
   
        //doing the test by calling the method with the id generated earlier.
        Test.startTest();
        Pricing_PerformanceMetrics_Mock.isCreateable();
        Test.stopTest();
        //System.assert(returnedQuoteLines.size()==1);
        System.debug('Number of Queries used in this apex code so far: ' + Limits.getQueries());
    }
    @isTest
    static void test_isUpdateable(){
        //using a mock library to create a mock object.
        fflib_ApexMocks mocks = new fflib_ApexMocks();
   
        //doing the test by calling the method with the id generated earlier.
        Test.startTest();
        Pricing_PerformanceMetrics_Mock.isUpdateable();
        Test.stopTest();
        //System.assert(returnedQuoteLines.size()==1);
        System.debug('Number of Queries used in this apex code so far: ' + Limits.getQueries());
    }
    @isTest
    static void test_isDeletable(){
        //using a mock library to create a mock object.
        fflib_ApexMocks mocks = new fflib_ApexMocks();
   
        //doing the test by calling the method with the id generated earlier.
        Test.startTest();
        Pricing_PerformanceMetrics_Mock.isDeletable();
        Test.stopTest();
        //System.assert(returnedQuoteLines.size()==1);
        System.debug('Number of Queries used in this apex code so far: ' + Limits.getQueries());
    }
      @isTest
    static void test_getPickListValues(){
        //using a mock library to create a mock object.
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        //doing the test by calling the method with the id generated earlier.
        Test.startTest();
        Pricing_PerformanceMetrics_Mock.getPickListValues('Pricing_Performance_Metric__c','Pricing_Performance_Metric_Nm__c');
        Test.stopTest();
        
        
        //System.assert(returnedQuoteLines.size()==1);
        System.debug('Number of Queries used in this apex code so far: ' + Limits.getQueries());
    }

}