/****************************************************************************************************************************************
* Class Name  : Core_RestAPI_AttachmentV1_Hnd_Test 
* Version     : 1.0 
* Created Date: 5 Jan 2018
* Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Hayata Takeshita          11/13/2017              This class is for testing Core_RestAPI_AttachmentV1_Handler methods with all the
*                                                   combination of inputs and it is not intended for business cases scenarios.
*No GUid update
*****************************************************************************************************************************************/
@isTest(SeeAllData = false)
public class Core_RestAPI_AttachmentV1_Hnd_Test {
    private static User commUser  = null;
    private static User adminUser  = null;
    private static String requestTemplate = Core_RestAPI_TestUtilities.REQUEST_TEMPLATE;
    private static Core_RestAPI_AttachmentV1_Wrapper requestParams = new Core_RestAPI_AttachmentV1_Wrapper();
    private static final Integer MAX_FILENAME_LENGTH = 100;
    private static final Integer MAX_FILE_DESCRIPTION_LENGTH = 1200;
    private static final Integer MAX_CASENUMBER_LENGTH = 8;

    @testSetup public static void setupData(){
     
        Core_IPS_APIGEE_Custom_Settings__c sObjRecSystemCred = new Core_IPS_APIGEE_Custom_Settings__c();
        sObjRecSystemCred.Name = 'Core_IPS_SFT_Move';
         sObjRecSystemCred.MyIntel_Integration_Class_Name__c = 'Core_IPS_SFT_Move';
        sObjRecSystemCred.MyIntel_Client_Id__c = '07e04e4c-dd0b-4b24-9c46-6056a8225308';
        sObjRecSystemCred.MyIntel_Client_Secret__c = 'XnK1KXtLthP4.778QgL-2fTS~OahSiL_qc';
        sObjRecSystemCred.MyIntel_Endpoint_URL__c = 'https://apis-stage.intel.com/filetransfer/sft-enterprise/file-management/v1/files?action=movefile    ';    
        sObjRecSystemCred.MyIntel_GrantType__c = 'client_credentials';  
        sObjRecSystemCred.MyIntel_Token_Endpoint_URL__c = 'https://apis-stage.intel.com/v1/auth/token';
  insert sObjRecSystemCred;
        //*--Start --US-US1018637-- 01-05-2021 -- Farooq -- change from old callout to APIGEE--*/
        Core_Trigger_Executions__c settings = new Core_Trigger_Executions__c();
        settings.Name = 'enableIPSCaseBackendRouting';
        settings.Core_Class_Name__c = 'Core_IPS_CasePromotion_Handler';
        settings.Core_Object__c = 'Case';
        settings.Core_Active__c = true;
        settings.Core_Trigger_Events__c = 'before insert, before update';
        settings.Core_Description__c = 'test';
        insert settings;

        settings = new Core_Trigger_Executions__c();
        settings.Name = 'InsertCaseCommentForAttach';
        settings.Core_Class_Name__c = 'Core_IPS_Case_Attachments_Handler';
        settings.Core_Description__c = 'ABC';
        settings.Core_Object__c = 'Core_IPS_Case_Comments__c';
        settings.Core_Trigger_Events__c = 'After Insert, After update';
        settings.Core_Active__c = false;
        insert settings;
        
        settings = new Core_Trigger_Executions__c();
        settings.Name = 'UpdateCaseComntDscptnForAttach';
        settings.Core_Class_Name__c = 'Core_IPS_Case_Attachments_Handler';
        settings.Core_Description__c = 'ABC';
        settings.Core_Object__c = 'Core_IPS_Case_Comments__c';
        settings.Core_Trigger_Events__c = 'After Insert, After update';
        settings.Core_Active__c = true;
        insert settings;
        
        Core_IPS_Labels__c labels = new Core_IPS_Labels__c ();
        labels.name= 'COMPLETE';
        labels.value__c='COMPLETE';
        insert labels;
        
        Core_IPS_Labels__c labels1 = new Core_IPS_Labels__c ();
        labels1.name= 'PUBLIC_TO_CUSTOMERS';
        labels1.value__c='Public to Customers';
        insert labels1;
        
        Core_IPS_Labels__c labels2 = new Core_IPS_Labels__c ();
        labels2.name= 'Data Migration Profile Id';
        labels2.value__c='00eo0000000f7Gd';
        insert labels2;             
        
        Core_IPS_Labels__c labels3 = new Core_IPS_Labels__c ();
        labels3.name= 'PRIVATE_TO_INTEL';
        labels3.value__c='Private to Intel';
        insert labels3;
        
        Core_IPS_Labels__c labels4 = new Core_IPS_Labels__c ();
        labels4.name= 'PRIVATE_TO_AGENTS';
        labels4.value__c='Private to Agents';
        insert labels4;
        
        Core_IPS_Labels__c labels5 = new Core_IPS_Labels__c ();
        labels5.name= 'FAE';
        labels5.value__c='FAE';
        insert labels5;
        
        Core_IPS_Labels__c labels6 = new Core_IPS_Labels__c ();
        labels6.name= 'Agent';
        labels6.value__c='Agent';
        insert labels6;
        
        Core_IPS_Labels__c labels7 = new Core_IPS_Labels__c ();
        labels7.name= 'Customer';
        labels7.value__c='Customer';
        insert labels7;
        
        Core_IPS_Labels__c labels8 = new Core_IPS_Labels__c ();
        labels8.name= 'Backend Integration';
        labels8.value__c='Backend Integration';
        insert labels8;
        
        Core_IPS_Labels__c labels9 = new Core_IPS_Labels__c ();
        labels9.name= 'Data Migration';
        labels9.value__c='Data Migration';
        insert labels9;
        
        adminUser = [Select Id FROM User where Profile.Name = 'System Administrator' AND isActive = true Limit 1];
        
//        Test.startTest();
        TestUtilities.getCustomerUsersWithAccountsAndContacts('RestApiUnitTest', 1, 1,0,1,'IPS External Customer', 0);

        commUser = [Select Name, ContactId, Contact.AccountId FROM User WHERE ContactId IN (Select Id FROM Contact) ];

        List<Account> lAcc = [SELECT Id, Core_IPS_SFT_Partner_Path__c FROM Account];
        for(Account oAcc : lAcc){
            oAcc.Core_IPS_SFT_Partner_Path__c = 'folder';
        }
        update lAcc;
        
        System.runAs(commUser){
            List<case> caseList = TestUtilities.getListOfCases(1);
            List<Product2> productList = TestUtilities.getListOfProduct(1);
            Integer i;
            Insert productList;
            for( i=0;i<caseList.size();i++){
                Case objCase = caseList[i];
                objCase.OwnerId = commUser.Id;
                objCase.ContactId = commUser.ContactId;
                objCase.ProductId = productList[i].Id;
                objCase.Core_IPS_Customer_Visible__c = true;
            } 

            insert caseList;
            System.assertEquals(1, caseList.size());
        }
//        Test.stopTest();
        
    }

    private static String createLongString(String strSegment, Integer numTimes) {
        String strString = '';
        for(Integer i = 0; i < numTimes; i++) {
            strString += strSegment;
        }
        
        return strString;
    }
    
    private static void setCaseNumberInRequest(boolean blGoodData) {
        commUser = [Select Name FROM User WHERE ContactId IN (Select Id FROM Contact)];
        Case objCase = [Select CaseNumber FROM Case where OwnerId =: commUser.Id Limit 1];
        RestRequest requestObj = (RestRequest)System.jSON.deserialize(requestTemplate, RestRequest.class);
        String strCaseNum = '';
        
        if(blGoodData == true) {
            requestParams.filename = 'filename';
            requestParams.fileDescription = 'filedescription';
            strCaseNum = objCase.CaseNumber;
        } else {
            requestParams.filename = createLongString('q', MAX_FILENAME_LENGTH + 1);
            requestParams.fileDescription = createLongString('q', MAX_FILE_DESCRIPTION_LENGTH + 1);
            strCaseNum = createLongString('q', MAX_CASENUMBER_LENGTH + 1);
        }
        
        requestObj.resourcePath ='/services/apexrest/v1.0/cases/'+strCaseNum+'/attachments';
        requestObj.requestUri ='/v1.0/cases/'+strCaseNum+'/attachments';

        requestObj.httpMethod = 'POST';
        RestContext.request = requestObj;
    }    
    
    //This method test the handler methods: createAttachment & processrequest
    @isTest public static void test_createAttachment_Positive(){
        setCaseNumberInRequest(true);
        Test.setMock(HttpCalloutMock.class, new Core_RESTAPI_MoveFileMock_Test());

        Test.startTest();
        System.runAs(commUser) {
            Core_RestAPI_AttachmentV1_Handler handler = new Core_RestAPI_AttachmentV1_Handler(System.now(), 'Core_RestAPI_AttachmentV1', requestParams); 
            Core_RestAPI_Response response = handler.createAttachment();  
            System.assertNotEquals(null, response);
            System.assertEquals(true, response.isSuccess);
        }
        Test.stopTest();
    }

    //Test error case: 
    //1. For any kind of exception handler should not throw raw exception.
    //2. Handler should return the response for any kind of exception
    @isTest public static void test_createAttachment_Negative() {
        setCaseNumberInRequest(true);
        Boolean exceptionThrown = true;

        Core_RESTAPI_MoveFileMock_Test mock = new Core_RESTAPI_MoveFileMock_Test();
        mock.returnError = true;
            
        Test.setMock(HttpCalloutMock.class, mock);

        Test.startTest();
        System.runAs(commUser) {
            Core_RestAPI_AttachmentV1_Handler handler = new Core_RestAPI_AttachmentV1_Handler(System.now(), 'Core_RestAPI_AttachmentV1', requestParams); 
            Core_RestAPI_Response response = null;
            
            try {
                response = handler.createAttachment();
            } catch (Exception e) {
                exceptionThrown = false;
            }
            System.assertNotEquals(null, Response);
            System.assertEquals(true, exceptionThrown, 'Handler not thrown any exception if false');
        }
        Test.stopTest();
    }

    @isTest public static void test_getAccountIdOfUser() {
        setCaseNumberInRequest(true);

        System.runAs(commUser) {
            Core_RestAPI_AttachmentV1_Handler handler = new Core_RestAPI_AttachmentV1_Handler(System.now(), null, requestParams); 
            handler.getAccountIdOfUser();
        }
    }
    
    //Test method - tests the positive cases for the method doValidations.
    //NOTE: for now there is no logic in doValidations and the method will be revisited when code gets added to doValidations method
    @isTest public static void test_doValidations_Positive(){
        setCaseNumberInRequest(true);

        System.runAs(commUser) {
            Core_RestAPI_AttachmentV1_Handler handler = new Core_RestAPI_AttachmentV1_Handler(System.now(), 'Core_RestAPI_AttachmentV1', requestParams);
            handler.doValidations();
        }
    }
    
    //Test method - tests the negative cases for the method doValidations, method should not throw any excepctoin with invalid inputs
    @isTest public static void test_doValidations_Negative_1(){
        Boolean exceptionThrown = false;
//        try{
            setCaseNumberInRequest(false);
            
            System.runAs(commUser) {
                Core_RestAPI_AttachmentV1_Handler handler = new Core_RestAPI_AttachmentV1_Handler(System.now(), 'Core_RestAPI_AttachmentV1', requestParams); 
                handler.doValidations();
            } 
//        } catch(Exception e) {
//            exceptionThrown = false;   
//        }        
        System.assertEquals(false, exceptionThrown);
    }

    //Test method - tests the negative cases for the method doValidations, method should not throw any excepctoin with invalid inputs
    @isTest public static void test_doValidations_Negative_2(){
        Boolean exceptionThrown = false;
        try{
            setCaseNumberInRequest(true);
            List<Account> lAcc = [SELECT Id, Core_IPS_SFT_Partner_Path__c FROM Account];
            for(Account oAcc : lAcc){
                oAcc.Core_IPS_SFT_Partner_Path__c = '';
            }
            update lAcc;

            Case objCase = [Select Id, Status, Core_Sub_Status__c FROM Case where OwnerId =: commUser.Id Limit 1];
            objCase.Status = 'Closed';
            objCase.Core_Sub_Status__c = 'GEC Hold';
            update objCase;
            
            System.runAs(commUser) {
                Core_RestAPI_AttachmentV1_Handler handler = new Core_RestAPI_AttachmentV1_Handler(System.now(), 'Core_RestAPI_AttachmentV1', requestParams); 
                handler.doValidations();
            } 
        }catch(Exception e){
            exceptionThrown = false;   
        }        
        System.assertEquals(false, exceptionThrown);
    }
    
    @isTest public static void test_fileSizeToString() {
        System.assertEquals('1 Bytes', Core_RestAPI_AttachmentV1_Handler.fileSizeToString(1));
        System.assertEquals('1.00 KB', Core_RestAPI_AttachmentV1_Handler.fileSizeToString(1024 + 1));
        System.assertEquals('1.00 MB', Core_RestAPI_AttachmentV1_Handler.fileSizeToString(1024*1024 + 1));
        System.assertEquals('1.00 GB', Core_RestAPI_AttachmentV1_Handler.fileSizeToString(1024*1024*1024 + 1));
    }
}