/****************************************************************************************************************************************
* Class Name  : Core_RestAPI_CaseAttachV1_Handler_Test 
* Version     : 1.0 
* Created Date: 9 Jan 2018
* Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Team: PopcornApps         1/9/2018              This class is for testing Core_RestAPI_CaseAttachmentV1_Handler methods with all the combination of inputs and it is not intended for business cases scenarios.
*****************************************************************************************************************************************/
@isTest 
public class Core_RestAPI_CaseAttachV1_Handler_Test {
private static final String v1_0 = 'v1.0';
    private static User commUser1  = null;
    private static User commUser2  = null;
    private static User commUser3_NoCases  = null;
    private static User adminUser  = null;
    
    //Case object for api assertion for getAttachment service
    private static Case caseObj = null;
    private static String requestTemplate = Core_RestAPI_TestUtilities.REQUEST_TEMPLATE ;
    
    static{
        RestRequest requestObj = (RestRequest)System.jSON.deserialize(requestTemplate, RestRequest.class);
        requestObj.resourcePath ='/services/apexrest/v1.0/cases/*/attachments';
        requestObj.requestUri ='/v1.0/cases/*/attachments';
        requestObj.httpMethod = 'GET';
        RestContext.request = requestObj;
        System.debug(' RestContext.request '+RestContext.request);
        
    }
     //Setup the data required for tesing the use cases
    @testSetup public static void setupData(){
        
        Core_RestAPI_TestUtilities.setUpCustomSettingCaseAttachment();
        adminUser = [Select Id, email, Profile.id  FROM User where Profile.Name = 'System Administrator' AND isActive = true Limit 1];
        System.debug(' >>> '+adminUser);
        List<Profile> dataMigProfList = [Select Id FROM Profile where Name ='IPS Data Migration']; 
        List<Core_IPS_Labels__c> settings = new List<Core_IPS_Labels__c>();
        Core_IPS_Labels__c custSetng = new Core_IPS_Labels__c();
        settings.add(new Core_IPS_Labels__c(Name = 'Data Migration Profile Id', Value__c = adminUser.Profile.id));
        settings.add(new Core_IPS_Labels__c(Name = 'COMPLETE', Value__c = 'COMPLETE'));
        settings.add(new Core_IPS_Labels__c(Name = 'Agent', Value__c = 'Agent'));
        settings.add(new Core_IPS_Labels__c(Name = 'PUBLIC_TO_CUSTOMERS', Value__c = 'Public to Customers'));
        insert settings;
         
        System.runAs(adminUser){
            String accName = 'RestApiUnitTest';
            Integer noOfAccounts = 1;
            Integer noOfIPSContacts = 3;
            Integer noOfNonIPSContacts = 1;
            Integer noOfCommUsers = 3;
            String communityProfileName = 'IPS External Customer';
            Integer noOfAssets = 0; //Not needed for this testing
            TestUtilities.getCustomerUsersWithAccountsAndContacts(accName, noOfAccounts, noOfIPSContacts, noOfNonIPSContacts,noOfCommUsers, communityProfileName, noOfAssets);
        }
        List<User> allCommUsers = [Select Name, ContactId, Contact.AccountId FROM User WHERE ContactId IN (Select Id FROM Contact) ];
        List<Contact> allIPSContacts = [Select Name, Core_IPS_Active__c FROM Contact] ;
        List<Account> allAccounts = [Select Name FROM Account];
        Contact nonIpsContact = [Select Name, Core_IPS_Active__c FROM Contact where Core_IPS_Active__c = false Limit 1] ;
        
        System.debug(' Core_RestAPI_CaseAttachments_Test \n Account '+allAccounts+'\n IPS Contacts '+allIPSContacts +'\n Non Contact '+nonIpsContact + ' \n All CommUsers '+allCommUsers);
        
        commUser1 = allCommUsers[0];
        commUser2 = allCommUsers[1];
        System.debug(' \n allCommUsers  '+allCommUsers);
        
        
        System.runAs(adminUser){
            Test.startTest();
            List<Case> caseList = TestUtilities.getListOfCases(3);
            //Assign 5 cases for admin User with blank contact id
            Case adminCase = caseList[0];
            adminCase.OwnerId = adminUser.Id;
            adminCase.ContactId = null;
            
            Case commUser1Case = caseList[1];
            commUser1Case.OwnerId = commUser1.Id;
            commUser1Case.ContactId = commUser1.ContactId;
            commUser1Case.AccountId = commUser1.Contact.AccountId;
            
            Case commUser2Case = caseList[2];
            commUser2Case.OwnerId = commUser2.Id;
            commUser2Case.ContactId = commUser2.ContactId;
            commUser2Case.AccountId = commUser2.Contact.AccountId;
            
            insert caseList; 
            
            List<Core_IPS_Case_Attachments__c> lstattachments = new List<Core_IPS_Case_Attachments__c>();
            for(Integer i=0;i<10;i++){
               Core_IPS_Case_Attachments__c objAttach = new Core_IPS_Case_Attachments__c(); 
               objAttach.Core_Case__c = caseList[1].id;
               objAttach.Core_IPS_Attachment_Visibility__c = 'Public to Customers';
               objAttach.Core_File_Description__c='Test-Description';
               objAttach.Core_File_Name__c='Test-File';
               objAttach.Core_FileUploadedBy__c =userInfo.getUserID();
               objAttach.Core_File_URL__c ='www.test.com';
               objAttach.Core_Upload_Status__c= 'COMPLETE';
               lstattachments.add(objAttach);
            }
            
            Insert lstattachments;
            
            caseObj = [Select CaseNumber FROM Case where OwnerId =: commUser1.Id Limit 1];
            System.debug('caseObj.CaseNumber --->'+caseObj.CaseNumber);
            RestRequest requestObj = (RestRequest)System.jSON.deserialize(requestTemplate, RestRequest.class);
            requestObj.resourcePath ='/services/apexrest/v1.0/cases/'+caseObj.CaseNumber+'/attachments';
            requestObj.requestUri ='/v1.0/cases/'+caseObj.CaseNumber+'/attachments';
            requestObj.httpMethod = 'GET';
            RestContext.request = requestObj;
            System.debug(' RestContext.request '+RestContext.request);
            
            Core_RestAPI_CaseAttachmentV1_Handler handler = new Core_RestAPI_CaseAttachmentV1_Handler(System.now(), 'Core_RestAPI_CaseAttachmentsV1'); 
            Core_RestAPI_Response finalResponse = null;
            handler.response.successContent = null;
            Boolean exceptionThrown = true;
            try{
                finalResponse = handler.getCaseAttachments();    
            }catch(Exception e){
                exceptionThrown = false;   
            }
            Test.StopTest();
       }   
   }       
   //This method test the handler methods: getCaseAttachemnts & processrequest
    @isTest public static void test_getCaseAttachemnts_Positive(){
        Core_RestAPI_CaseAttachmentV1_Handler handler = new Core_RestAPI_CaseAttachmentV1_Handler(System.now(), 'Core_RestAPI_CaseAttachmentsV1'); 
        Core_RestAPI_Response response = handler.getCaseAttachments();  
        System.assertNotEquals(null, response);
        System.debug(' >>> response '+response);

    }
     //Test error case: 
    //1. For any kind of exception handler should not throw raw exception.
    //2. Handler should return the response for any kind of exception
    @isTest public static void test_getCaseAttachemnts_Negative(){
        
        Core_RestAPI_CaseAttachmentV1_Handler handler = new Core_RestAPI_CaseAttachmentV1_Handler(System.now(), 'Core_RestAPI_CaseAttachmentsV1'); 
        Core_RestAPI_Response finalResponse = null;
        handler.response.successContent = null;
        Boolean exceptionThrown = true;
        try{
            finalResponse = handler.getCaseAttachments();    
        }catch(Exception e){
            exceptionThrown = false;   
        }
        System.assertNotEquals(null, finalResponse);
        System.assertEquals(true, exceptionThrown);
    }
     //Test method - tests the positive cases for the method doValidations.
    //NOTE: for now there is no logic in doValidations and the method will be revisited when code gets added to doValidations method
    @isTest public static void test_doValidations_Positive(){
        Core_RestAPI_CaseAttachmentV1_Handler handler = new Core_RestAPI_CaseAttachmentV1_Handler(System.now(), 'Core_RestAPI_CaseAttachmentsV1'); 
        handler.doValidations();
    }
    //Test method - tests the negative cases for the method doValidations, method should not throw any excepctoin with invalid inputs
    //NOTE: for now there is no logic in doValidations and the method will be revisited when code gets added to doValidations method
    @isTest public static void test_doValidations_Negative(){
        Boolean exceptionThrown = false;
        try{
            Core_RestAPI_CaseAttachmentV1_Handler handler = new Core_RestAPI_CaseAttachmentV1_Handler(System.now(), 'Core_RestAPI_CaseAttachmentsV1'); 
            handler.doValidations();
        }catch(Exception e){
            exceptionThrown = false;   
        }        
        System.assertEquals(false, exceptionThrown);
    }
}