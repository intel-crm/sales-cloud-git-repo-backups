/**
 * @description       : test class for CommentsController
 * @author            : Rakshitha BR
 * @group             : Gravity
 * @last modified on  : 03-28-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public class Pricing_CommentsController_Mock_Test {
    @isTest
    static void test_getQuotelines(){
        //using a mock library to create a mock object.
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        
        //using the mock object to generate mock selector class of interface of the selector class.
        Pricing_Comments_Selector commentsSelectorMock = (Pricing_Comments_Selector) mocks.mock(Pricing_Comments_Selector.class);
        
        //using an id generator supported by fflib library to get only the id which is required by our method 
        //which leverages the work of creating an entire record for the purpose of only using the id.
        Id quoteId = fflib_IDGenerator.generate(Schema.SBQQ__Quote__c.SObjectType);
        
        Pricing_Comments__c cmnt = new Pricing_Comments__c();
        cmnt.Pricing_Quote__c = quoteId;
        
        //starting the stub where we will tell the mock class that when this selector query is called from
        //controller method the record created above should be returned.
        mocks.startStubbing();
        
        //next line is mandatory for all selector stubbing since in the fflib_Application there is mockSobject map which 
        //maps the sobject to the mock class created.
        mocks.when(commentsSelectorMock.sObjectType()).thenReturn(Schema.Pricing_Comments__c.SObjectType);
        
        //here we are defining the return record which the query should return when the same argument is passed from the 
        //controller class on test execution.
        mocks.when(commentsSelectorMock.selectByIdandRecordType((Id) fflib_Match.anyObject(),(Id) fflib_Match.anyObject())).thenReturn(new List<Pricing_Comments__c>{cmnt});
        
        //stoping the stub.
        mocks.stopStubbing();
        
        //calling setMock method to map the sobject with the mock class generated using ApexMocks.
        Pricing_IQR_Application.Selector.setMock(commentsSelectorMock);
        
        //doing the test by calling the method with the id generated earlier.
        Test.startTest();
        Pricing_CommentsController_Mock.getTenderComments(quoteId);
        Pricing_CommentsController_Mock.getPricingManagerComments(quoteId);
        
        Test.stopTest();
        
        // using verify method which works same as the assert
        // here it check that the selector method is called how many times.        
        ((Pricing_Comments_Selector) mocks.verify(commentsSelectorMock,2)).selectByIdandRecordType((Id) fflib_Match.anyObject(),(Id) fflib_Match.anyObject());
        //System.assert(returnedQuoteLines.size()==1);
        System.debug('Number of Queries used in this apex code so far: ' + Limits.getQueries());
    }
    @isTest
    static void test_DocumentStatus(){
        //using a mock library to create a mock object.
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        
        //using the mock object to generate mock selector class of interface of the selector class.
        Pricing_Document_Selector documentSelectorMock = (Pricing_Document_Selector) mocks.mock(Pricing_Document_Selector.class);
        Pricing_ContentDocumentLink_Selector documentlinkSelectorMock  = (Pricing_ContentDocumentLink_Selector) mocks.mock(Pricing_ContentDocumentLink_Selector.class);
        
        //using an id generator supported by fflib library to get only the id which is required by our method 
        //which leverages the work of creating an entire record for the purpose of only using the id.
        Id quoteId = fflib_IDGenerator.generate(Schema.SBQQ__Quote__c.SObjectType);
        
        Pricing_Document__c doct = new Pricing_Document__c();
        doct.Pricing_Quote_Id__c = quoteId;
        doct.Name = 'test';
        doct.Id = fflib_IDGenerator.generate(Schema.Pricing_Document__c.SObjectType);
        
        
        
        
        //starting the stub where we will tell the mock class that when this selector query is called from
        //controller method the record created above should be returned.
        mocks.startStubbing();
        
        //next line is mandatory for all selector stubbing since in the fflib_Application there is mockSobject map which 
        //maps the sobject to the mock class created.
        mocks.when(documentSelectorMock.sObjectType()).thenReturn(Schema.Pricing_Document__c.SObjectType);
        mocks.when(documentlinkSelectorMock.sObjectType()).thenReturn(Schema.ContentDocumentLink.SObjectType);
        
        //here we are defining the return record which the query should return when the same argument is passed from the 
        //controller class on test execution.
        mocks.when(documentSelectorMock.selectByquoteId((Id) fflib_Match.anyObject())).thenReturn(new List<Pricing_Document__c>{doct});
        mocks.when(documentlinkSelectorMock.selectByRecordType((Id) fflib_Match.anyObject())).thenReturn(1);
        
        //stoping the stub.
        mocks.stopStubbing();
        
        //calling setMock method to map the sobject with the mock class generated using ApexMocks.
        Pricing_IQR_Application.Selector.setMock(documentSelectorMock);
        Pricing_IQR_Application.Selector.setMock(documentlinkSelectorMock);
        
        
        //doing the test by calling the method with the id generated earlier.
        Test.startTest();
        Pricing_CommentsController_Mock.getDocumentShare(quoteId);
        Test.stopTest();
        
        // using verify method which works same as the assert
        // here it check that the selector method is called how many times.        
        ((Pricing_Document_Selector) mocks.verify(documentSelectorMock,1)).selectByquoteId((Id) fflib_Match.anyObject());
        //System.assert(returnedQuoteLines.size()==1);
        System.debug('Number of Queries used in this apex code so far: ' + Limits.getQueries());
    }
    @isTest
    static void test_QuoteStatus(){
        //using a mock library to create a mock object.
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        
        //using the mock object to generate mock selector class of interface of the selector class.
        Pricing_Quote_Selector quoteSelectorMock = (Pricing_Quote_Selector) mocks.mock(Pricing_Quote_Selector.class);
        
        
        //using an id generator supported by fflib library to get only the id which is required by our method 
        //which leverages the work of creating an entire record for the purpose of only using the id.
        
        
        SBQQ__Quote__c qot = new SBQQ__Quote__c();
        
        qot.SBQQ__Status__c = 'tet';
        qot.Id = fflib_IDGenerator.generate(Schema.SBQQ__Quote__c.SObjectType);
        
        
        
        
        //starting the stub where we will tell the mock class that when this selector query is called from
        //controller method the record created above should be returned.
        mocks.startStubbing();
        
        //next line is mandatory for all selector stubbing since in the fflib_Application there is mockSobject map which 
        //maps the sobject to the mock class created.
        mocks.when(quoteSelectorMock.sObjectType()).thenReturn(Schema.SBQQ__Quote__c.SObjectType);
        
        
        //here we are defining the return record which the query should return when the same argument is passed from the 
        //controller class on test execution.
        mocks.when(quoteSelectorMock.selectByIds((set<Id>) fflib_Match.anyObject())).thenReturn(new List<SBQQ__Quote__c>{qot});
        
        
        //stoping the stub.
        mocks.stopStubbing();
        
        //calling setMock method to map the sobject with the mock class generated using ApexMocks.
        Pricing_IQR_Application.Selector.setMock(quoteSelectorMock);
        
        
        
        //doing the test by calling the method with the id generated earlier.
        Test.startTest();
        Pricing_CommentsController_Mock.getQuoteStatus(qot.Id);
        Test.stopTest();
        
        // using verify method which works same as the assert
        // here it check that the selector method is called how many times.        
        ((Pricing_Quote_Selector) mocks.verify(quoteSelectorMock,1)).selectByIds((set<Id>) fflib_Match.anyObject());
        //System.assert(returnedQuoteLines.size()==1);
        System.debug('Number of Queries used in this apex code so far: ' + Limits.getQueries());
    }
    @isTest
    static void test_PermissionSetAssignmentStatus(){
        //using a mock library to create a mock object.
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        
        //using the mock object to generate mock selector class of interface of the selector class.
        Pricing_PermissionSetAssignment_Selector permissionsetassignmentSelectorMock = (Pricing_PermissionSetAssignment_Selector) mocks.mock(Pricing_PermissionSetAssignment_Selector.class);
        
        
        //using an id generator supported by fflib library to get only the id which is required by our method 
        //which leverages the work of creating an entire record for the purpose of only using the id.
        
        
        
        
        
        
        
        //starting the stub where we will tell the mock class that when this selector query is called from
        //controller method the record created above should be returned.
        mocks.startStubbing();
        
        //next line is mandatory for all selector stubbing since in the fflib_Application there is mockSobject map which 
        //maps the sobject to the mock class created.
        mocks.when(permissionsetassignmentSelectorMock.sObjectType()).thenReturn(Schema.PermissionSetAssignment.SObjectType);
        
        
        //here we are defining the return record which the query should return when the same argument is passed from the 
        //controller class on test execution.
        mocks.when(permissionsetassignmentSelectorMock.selectByName((Id) fflib_Match.anyObject(),(set<string>) fflib_Match.anyObject())).thenReturn(true);
        
        
        //stoping the stub.
        mocks.stopStubbing();
        
        //calling setMock method to map the sobject with the mock class generated using ApexMocks.
        Pricing_IQR_Application.Selector.setMock(permissionsetassignmentSelectorMock);
        
        
        
        //doing the test by calling the method with the id generated earlier.
        Test.startTest();
        Pricing_CommentsController_Mock.isPricingManager();
        Test.stopTest();
        
        // using verify method which works same as the assert
        // here it check that the selector method is called how many times.        
        ((Pricing_PermissionSetAssignment_Selector) mocks.verify(permissionsetassignmentSelectorMock,1)).selectByName((Id) fflib_Match.anyObject(),(set<string>) fflib_Match.anyObject());
        //System.assert(returnedQuoteLines.size()==1);
        System.debug('Number of Queries used in this apex code so far: ' + Limits.getQueries());
    }
    @isTest
    static void test_UserStatus(){
        //using a mock library to create a mock object.
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        
        //using the mock object to generate mock selector class of interface of the selector class.
        Pricing_User_Selector userSelectorMock = (Pricing_User_Selector) mocks.mock(Pricing_User_Selector.class);
        
        
        //using an id generator supported by fflib library to get only the id which is required by our method 
        //which leverages the work of creating an entire record for the purpose of only using the id.
        
        
        
        
        
        
        
        //starting the stub where we will tell the mock class that when this selector query is called from
        //controller method the record created above should be returned.
        mocks.startStubbing();
        
        //next line is mandatory for all selector stubbing since in the fflib_Application there is mockSobject map which 
        //maps the sobject to the mock class created.
        mocks.when(userSelectorMock.sObjectType()).thenReturn(Schema.User.SObjectType);
        
        
        //here we are defining the return record which the query should return when the same argument is passed from the 
        //controller class on test execution.
        mocks.when(userSelectorMock.selectById((Id) fflib_Match.anyObject())).thenReturn(true);
        
        
        //stoping the stub.
        mocks.stopStubbing();
        
        //calling setMock method to map the sobject with the mock class generated using ApexMocks.
        Pricing_IQR_Application.Selector.setMock(userSelectorMock);
        
        
        
        //doing the test by calling the method with the id generated earlier.
        Test.startTest();
        Pricing_CommentsController_Mock.isReadOnlyUser();
        Test.stopTest();
        
        // using verify method which works same as the assert
        // here it check that the selector method is called how many times.        
        ((Pricing_User_Selector) mocks.verify(userSelectorMock,1)).selectById((Id) fflib_Match.anyObject());
        //System.assert(returnedQuoteLines.size()==1);
        System.debug('Number of Queries used in this apex code so far: ' + Limits.getQueries());
    }
    
    @isTest
    static void test_updateTenderComments(){
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork uowMock = new fflib_SObjectMocks.SObjectUnitOfWork(mocks);
        
        Id cmntId = fflib_IDGenerator.generate(Schema.Pricing_Comments__c.SObjectType);
        Pricing_Comments__c cmnt = new Pricing_Comments__c();
        cmnt.Id = cmntId;
        cmnt.Pricing_Question__c = 'Pricing Manager Comment';
        cmnt.Pricing_Answer__c = 'Test';
        cmnt.Pricing_Quote__c = fflib_IDGenerator.generate(Schema.SBQQ__Quote__c.SObjectType);   
        
        Pricing_IQR_Application.unitOfWork.setMock(uowMock);
        
        Test.startTest();
        Pricing_CommentsController_Mock.updateTenderComments(new List<Pricing_Comments__c>{cmnt});
        Test.stopTest();
        
        System.debug('Number of Queries used in this apex code so far: ' + Limits.getQueries());
        System.debug('Number of Queries used in this apex code so far: ' + Limits.getDmlStatements());
        
    }
     @isTest
    static void test_createTenderComments(){
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork uowMock = new fflib_SObjectMocks.SObjectUnitOfWork(mocks);
        
        
        Pricing_IQR_Application.unitOfWork.setMock(uowMock);
        
        Test.startTest();
        Pricing_CommentsController_Mock.createTenderComments('test',fflib_IDGenerator.generate(Schema.SBQQ__Quote__c.SObjectType));
        Test.stopTest();
        
        System.debug('Number of Queries used in this apex code so far: ' + Limits.getQueries());
        System.debug('Number of Queries used in this apex code so far: ' + Limits.getDmlStatements());
        
    }
    @isTest
    static void test_updateCommentThroughId(){
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork uowMock = new fflib_SObjectMocks.SObjectUnitOfWork(mocks);
        
        
        Pricing_IQR_Application.unitOfWork.setMock(uowMock);
        
        Test.startTest();
        Pricing_CommentsController_Mock.updateCommentThroughId(fflib_IDGenerator.generate(Schema.Pricing_Comments__c.SObjectType),'test');
        Test.stopTest();
        
        System.debug('Number of Queries used in this apex code so far: ' + Limits.getQueries());
        System.debug('Number of Queries used in this apex code so far: ' + Limits.getDmlStatements());
        
    }


    
}