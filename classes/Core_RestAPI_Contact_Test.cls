/****************************************************************************************************************************************
* Class Name  : Core_RestAPI_Contact_Test
* Version     : 1.0 
* Created Date: 6 Nov 2017
* Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Team: PopcornApps         11/13/2017              This class is for testing the business use cases. This single will take care of testing all the versions of contacts API
*****************************************************************************************************************************************/
@isTest public class Core_RestAPI_Contact_Test {
    
    private static final String v1_0 = 'v1.0';
    private static User commUser1  = null;
    private static User commUser3_NoCases  = null;
    private static User adminUser  = null;
    
    //Setup the data required for tesing the use cases
    @testSetup public static void setupData(){
        
        adminUser = [Select Id FROM User where Profile.Name = 'System Administrator' AND isActive = true Limit 1];
        Test.startTest();
        System.runAs(adminUser){
            String accName = 'RestApiUnitTest';
            Integer noOfAccounts = 1;
            Integer noOfIPSContacts = 3;
            Integer noOfNonIPSContacts = 1;
            Integer noOfCommUsers = 3;
            String communityProfileName = 'IPS External Customer';
            Integer noOfAssets = 2; //Not needed for this testing
            Core_RestAPI_TestUtilities.getCustomerUsersWithAccountsAndContacts(accName, noOfAccounts, noOfIPSContacts, noOfNonIPSContacts,noOfCommUsers, communityProfileName, noOfAssets);
        }
        List<User> allCommUsers = [Select Name, ContactId FROM User WHERE ContactId IN (Select Id FROM Contact) ];
        List<Contact> allIPSContacts = [Select Name, Core_IPS_Active__c FROM Contact] ;
        List<Account> allAccounts = [Select Name FROM Account];
        Contact nonIpsContact = [Select Name, Core_IPS_Active__c FROM Contact where Core_IPS_Active__c = false Limit 1] ;
        System.debug(' Core_RestAPI_Cases_Test \n Account '+allAccounts+'\n IPS Contacts '+allIPSContacts +'\n Non Contact '+nonIpsContact + ' \n All CommUsers '+allCommUsers);
        
        commUser1 = allCommUsers[0];
        Test.stopTest();
    }
    
    
    //Pass the version the method returns the request based on the version number 
    private static RestRequest doGet_getCases_VersionRequest(String version, boolean includeFilter){
        RestRequest request = (RestRequest)System.jSON.deserialize(Core_RestAPI_TestUtilities.REQUEST_TEMPLATE, RestRequest.class);
        request.httpMethod = 'GET';
        if(v1_0.equals(version)){
            request.requestUri ='/v1.0/contacts'; 
            request.resourcePath ='/services/apexrest/v1.0/contacts';
        }
        return request;
    }
    
    private static void doGet_getContacts_Asserts_Positive(Core_RestAPI_Response apiResponse, RestResponse objResponse, String strVersion) {
        
        //expand if statement when multiple versions share the same asserts
        If(strVersion == v1_0) {  
            System.assertEquals('200', apiResponse.Code, ' RestAPIResponse Success code 200');
            System.assertNotEquals(null, apiResponse);
            System.assertEquals(true, apiResponse.isSuccess);
            System.assertNotEquals(null, apiResponse.successContent);
            System.assertEquals(null, apiResponse.errorContent);
            
            RestRequest request = RestContext.request;
            System.debug(apiResponse.successContent.size()+' ++++++++request++++++++ '+request.requestURI);
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
    private static void doGet_getContacts_Asserts_Negative(Core_RestAPI_Response apiResponse, RestResponse objResponse, String strVersion) {
        //Consolidate asserts so that each test method does not have to copy/paste the logic
        //expand if statement when multiple versions share the same asserts
        If(strVersion == v1_0) {  
            System.assertEquals('200', apiResponse.Code, ' RestAPIResponse Success code 200');
            System.assertNotEquals(null, apiResponse);
            System.assertEquals(true, apiResponse.isSuccess);
            System.assertNotEquals(null, apiResponse.successContent);
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
    
    
    /************************************************************************************************************************************
* Test Method for GET contacts starts from here
*****************************************************************************************************************************************/
    
    //Test doGet method
    @isTest public static void test_doGet_getContacts_v1_0(){
        RestContext.request = doGet_getCases_VersionRequest(v1_0, false);
        commUser1  = [Select Name FROM User WHERE Name = 'CommUser0 RestApiUnitTest0'];
        System.debug(' \n\n Running test method test_doGet_getCases_v1_0 as  '+commUser1);  
        System.runAs(commUser1){
            Core_RestAPI_Response apiResponse = Core_RestAPI_ContactsV1.doGet();
            System.debug(' test_doGet_getCases_v1_0 positive >>>> '+apiResponse.successContent); 
            doGet_getContacts_Asserts_Positive(apiResponse,null ,v1_0);
        }
        
        //Negative testing User has no casess and verify the user never gets other contacts cases from his account
        commUser3_NoCases  = [Select Name FROM User WHERE Name = 'CommUser2 RestApiUnitTest0'];
        System.debug(' Running test as  '+commUser1);  
        System.runAs(commUser3_NoCases){
            Core_RestAPI_Response apiResponse = Core_RestAPI_ContactsV1.doGet();
            System.debug(' test_doGet_getCases_v1_0 Negative>>>> '+apiResponse.successContent); 
            doGet_getContacts_Asserts_Negative(apiResponse, null , v1_0);
        } 
    }
    
    
    
    
    
}