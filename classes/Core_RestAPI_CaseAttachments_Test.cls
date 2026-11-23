/****************************************************************************************************************************************
* Class Name  : Core_RestAPI_CaseAttachments_Test 
* Version     : 1.0 
* Created Date: 4 Jan 2018
* Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Team: PopcornApps         1/4/2018              This class is for testing the business use cases.
*****************************************************************************************************************************************/
@isTest 
public class Core_RestAPI_CaseAttachments_Test {
    private static final String v1_0 = 'v1.0';
    private static User commUser1  = null;
    private static User commUser2  = null;
    private static User commUser3_NoCases  = null;
    private static User adminUser  = null;
    
    //Case object for api assertion for getAttachment service
    private static Case caseObj = null;
     //Setup the data required for tesing the use cases
    @testSetup public static void setupData(){
    
          Core_RestAPI_TestUtilities.setUpCustomSettingCaseAttachment();
          
        adminUser = [Select Id, email, Profile.Id  FROM User where Profile.Name = 'System Administrator' AND isActive = true Limit 1];
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
            
            Core_IPS_Case_Attachments__c attachments = new Core_IPS_Case_Attachments__c();
            attachments.Core_Case__c = caseList[1].id;
            attachments.Core_IPS_Attachment_Visibility__c = 'Public to Customers';
            attachments.Core_File_Description__c='Test-Description';
            attachments.Core_File_Name__c='Test-File';
            attachments.Core_FileUploadedBy__c =userInfo.getUserID();
            attachments.Core_File_URL__c ='www.test.com';
            attachments.Core_Upload_Status__c= 'COMPLETE';
            Insert attachments;
            
            Test.StopTest();
       }   
   }       
   //Pass the version the method returns the request based on the version number 
    private static RestRequest doGet_getCaseAttachments_VersionRequest(String version, String caseNbr){
        RestRequest request = (RestRequest)System.jSON.deserialize(Core_RestAPI_TestUtilities.REQUEST_TEMPLATE, RestRequest.class);
        request.httpMethod = 'GET';
        if(v1_0.equals(version)){
            request.requestUri ='/v1.0/cases/'+caseNbr+'/attachments'; 
            request.resourcePath ='/services/apexrest/v1.0/cases/'+caseNbr+'/attachments';
        }
        return request;
    }  
    private static void doGet_getCaseAttachments_Asserts_Positive(Core_RestAPI_Response apiResponse, RestResponse objResponse, String strVersion) {
        //Consolidate asserts so that each test method does not have to copy/paste the logic
        
        //expand if statement when multiple versions share the same asserts
        If(strVersion == v1_0) {  
            System.assertEquals('200', apiResponse.Code, ' RestAPIResponse Success code 200');
            System.assertNotEquals(null, apiResponse);
            System.assertEquals(true, apiResponse.isSuccess);
            System.assertNotEquals(null, apiResponse.successContent);
            System.assertEquals(null, apiResponse.errorContent);
            
            RestRequest request = RestContext.request;
            System.debug(apiResponse.successContent.size()+' ++++++++request++++++++ '+request.requestURI);
            System.assertEquals(1, apiResponse.successContent.size(), 'All External active attachments retrieved');
            
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
    //This method is for asserting negative test cases    
    private static void doGet_getCaseAttachments_Asserts_Negative(Core_RestAPI_Response apiResponse, RestResponse objResponse, String strVersion) {
        //Consolidate asserts so that each test method does not have to copy/paste the logic
        //expand if statement when multiple versions share the same asserts
        If(strVersion == v1_0) {  
            System.assertEquals('200', apiResponse.Code, ' RestAPIResponse Success code 200');
            System.assertNotEquals(null, apiResponse);
            System.assertEquals(false, apiResponse.isSuccess);
            System.assertEquals(null, apiResponse.successContent);
            System.assertEquals(0, apiResponse.successContent.size(), 'No External attachments');
            System.assertEquals(null, apiResponse.errorContent);
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
      //****************************************************************************************************************************************
    //Test Method starts from here
    //*****************************************************************************************************************************************/
    
    //Test doGet method
    @isTest public static void test_doGet_getAttachments_v1_0_Positive(){
        commUser1  = [Select Name, ContactId FROM User WHERE Name = 'CommUser0 RestApiUnitTest0'];
        System.debug(' \n\n Running test method test_doGet_getAttachments_v1_0 as  '+commUser1);  
        Case caseObj = [Select Id, CaseNumber FROM Case where ContactId =:commUser1.ContactId  Limit 1];
        RestContext.request = doGet_getCaseAttachments_VersionRequest(v1_0, caseObj.CaseNumber);
        System.runAs(commUser1){
            Core_RestAPI_Response apiResponse = Core_RestAPI_CaseAttachmentsV1.doGet();
            System.debug(' test_doGet_getAttachments_v1_0_Positive test_doGet >>>> '+apiResponse); 
            doGet_getCaseAttachments_Asserts_Positive(apiResponse,null ,v1_0);
        }  
    }
    
    @isTest public static void test_doGet_getAttachments_v1_0_Negative(){
        //Negative Case 2
        commUser2  = [Select Name FROM User WHERE Name = 'CommUser1 RestApiUnitTest0'];
        RestContext.request = doGet_getCaseAttachments_VersionRequest(v1_0, 'InvalidCaseNumber');
        System.runAs(commUser2){
            Core_RestAPI_Response apiResponse = Core_RestAPI_CaseAttachmentsV1.doGet();
            System.debug(' test_doGet_getAttachments_v1_0_Negative test_doGet >>>> '+apiResponse); 
            System.assertEquals(false, apiResponse.isSuccess);
        }  
    }
    
}