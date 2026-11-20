/****************************************************************************************************************************************
* Class Name  : Core_RestAPI_Attachment_Test
* Version     : 1.0 
* Created Date: 11 Jan 2018
* Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Hayata Takeshita         01/11/2018              This class is for testing the business use cases. This single will take care of testing all the versions of cases API
*****************************************************************************************************************************************/
@isTest(SeeAllData = false)
public class Core_RestAPI_Attachment_Test {
    private static final String v1_0 = 'v1.0';
    private static User commUser1  = null;
    private static User adminUser  = null;

    private static Case caseObj = null;
    private static Core_RestAPI_AttachmentV1_Wrapper requestParams = new Core_RestAPI_AttachmentV1_Wrapper();

    @testSetup public static void setupData(){
        Core_System_Credentials__c sObjRecSystemCred = new Core_System_Credentials__c();
        sObjRecSystemCred.Name = 'Core_SFT_MoveFile';
        sObjRecSystemCred.Core_UserName__c = 'xxxx';
        sObjRecSystemCred.Core_Password__c = 'xxxx';
        sObjRecSystemCred.Core_End_Point_URL__c = 'xxxx';
        insert sObjRecSystemCred;

        Core_Trigger_Executions__c settings = new Core_Trigger_Executions__c();
        settings.Name = 'enableIPSCaseBackendRouting';
        settings.Core_Class_Name__c = 'Core_IPS_CasePromotion_Handler';
        settings.Core_Object__c = 'Case';
        settings.Core_Active__c = false;
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
        System.runAs(adminUser){
            Core_RestAPI_TestUtilities.getCustomerUsersWithAccountsAndContacts('RestApiUnitTest', 1, 1,0,1,'IPS External Customer', 0);
        }
        
        
        commUser1 = [Select Name FROM User WHERE ContactId IN (Select Id FROM Contact) ];
        
        System.runAs(adminUser){
            List<Account> lAcc = [SELECT Id, Core_IPS_SFT_Partner_Path__c FROM Account];
            for(Account oAcc : lAcc){
                oAcc.Core_IPS_SFT_Partner_Path__c = 'folder';
            }
            update lAcc;
            
            List<Case> caseList = Core_RestAPI_TestUtilities.getListOfCases(1);
            for(Integer i =0;i<caseList.size()/2;i++){
                Case c = caseList[i];
                c.OwnerId = adminUser.Id;
                c.Core_IPS_Customer_Visible__c = true;
            }
            for(Integer i =caseList.size()/2;i<caseList.size();i++){
                Case c = caseList[i];
                c.OwnerId = commUser1.Id;
                c.Core_IPS_Customer_Visible__c = true;
            }
            insert caseList;
        }
//        Test.stopTest();
    }
    
    //Pass the version the method returns the request based on the version number 
    private static RestRequest doGet_createAttachment_VersionRequest(String version,  String caseNbr){
        RestRequest request = (RestRequest)System.jSON.deserialize(Core_RestAPI_TestUtilities.REQUEST_TEMPLATE, RestRequest.class);
        
        request.httpMethod = 'POST';
        if(v1_0.equals(version)){
            caseObj = [Select CaseNumber FROM Case where OwnerId =: commUser1.Id Limit 1];
        	request.requestUri ='/v1.0/cases/'+caseNbr+'/attachments'; 
            request.resourcePath ='/services/apexrest/v1.0/cases/'+caseNbr+'/attachments';

	        requestParams.filename = 'filename';
	        requestParams.fileDescription = 'filedescription';
	    }
        return request;
    }
    
    private static void doGet_createAttachment_Asserts(Core_RestAPI_Response apiResponse, RestResponse objResponse, String strVersion) {
        //Consolidate asserts so that each test method does not have to copy/paste the logic
        
        //expand if statement when multiple versions share the same asserts
        If(strVersion == v1_0) {  
            System.assertEquals('200', apiResponse.Code, ' RestAPIResponse Success code 200');
            System.assertNotEquals(null, apiResponse);
            System.assertNotEquals(null, apiResponse.successContent);
            System.assertEquals(true, apiResponse.isSuccess);
            //Assert all sharing cases are retrieved
            System.assertEquals(1, apiResponse.successContent.size(), 'Case Found');
        }
        
        //Common Asserts for all versions
        //Verify the transaction log is created
        if(LABEL.Core_RestAPI_Transaction_Switch == 'ON'){
            try{
                Core_RestAPI_Transaction_Entry__c log = [Select Id FROM Core_RestAPI_Transaction_Entry__c Limit 1];    
                System.assertNotEquals(null, log);
            }catch(Exception e){
                //Fail if log entry is not found when 
                System.assert(false);
            }
        }
    }      
     //Test doPost method
	@isTest public static void test_doPost_createAttachment_v1_0_Positive() {
        commUser1  = [Select Name, ContactId FROM User WHERE Name = 'CommUser0 RestApiUnitTest0'];
        Case caseObj = [Select Id, CaseNumber FROM Case where ContactId =:commUser1.ContactId  Limit 1];
        RestContext.request = doGet_createAttachment_VersionRequest(v1_0, caseObj.CaseNumber);

        Test.setMock(HttpCalloutMock.class, new Core_RESTAPI_MoveFileMock_Test());
        
       	Test.startTest();
        System.runAs(commUser1){
            Core_RestAPI_Response apiResponse = Core_RestAPI_CaseAttachmentsV1.doPost(requestParams);
            doGet_createAttachment_Asserts(apiResponse, null, v1_0);
        }
        Test.stopTest();
    }
    
     //Test doPost method
    @isTest public static void test_doPost_createAttachment_v1_0_Negative() {
        commUser1  = [Select Name, ContactId FROM User WHERE Name = 'CommUser0 RestApiUnitTest0'];
        //Negative test case
        commUser1  = [Select Name, ContactId FROM User WHERE Name = 'CommUser0 RestApiUnitTest0'];
        RestContext.request = doGet_createAttachment_VersionRequest(v1_0, 'invalidCasenumber');
        
        Test.setMock(HttpCalloutMock.class, new Core_RESTAPI_MoveFileMock_Test());

       	Test.startTest();
        System.runAs(commUser1){
            Core_RestAPI_Response apiResponse = Core_RestAPI_CaseAttachmentsV1.doPost(requestParams);
        }
        Test.stopTest();
    }
}