/****************************************************************************************************************************************
* Class Name  : Core_RestAPI_InterestedParties_Test 
* Version     : 1.0 
* Created Date: 6 Nov 2017
* Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Team: PopcornApps         11/13/2017              This class is for testing the business use cases. This single will take care of tesing all the versions of cases API
*****************************************************************************************************************************************/
@isTest public class Core_RestAPI_InterestedParties_Test {
    private static final String v1_0 = 'v1.0';
    private static User commUser1  = null;
    private static User commUser2  = null;
    private static User commUser3_NoCases  = null;
    private static User adminUser  = null;
    
    //Case object for api assertion for getDetail service
    private static Case caseObj = null;
    
    //Setup the data required for tesing the use cases
    @testSetup public static void setupData(){
        
        adminUser = [Select Id, email  FROM User where Profile.Name = 'System Administrator' AND isActive = true Limit 1];
        
        System.runAs(adminUser){
            String accName = 'RestApiUnitTest';
            Integer noOfAccounts = 1;
            Integer noOfIPSContacts = 3;
            Integer noOfNonIPSContacts = 1;
            Integer noOfCommUsers = 3;
            String communityProfileName = 'IPS External Customer';
            Integer noOfAssets = 0; //Not needed for this testing
            Core_RestAPI_TestUtilities.getCustomerUsersWithAccountsAndContacts(accName, noOfAccounts, noOfIPSContacts, noOfNonIPSContacts,noOfCommUsers, communityProfileName, noOfAssets);
        }
        List<User> allCommUsers = [Select Name, ContactId, Contact.AccountId FROM User WHERE ContactId IN (Select Id FROM Contact) ];
        List<Contact> allIPSContacts = [Select Name, Core_IPS_Active__c FROM Contact] ;
        List<Account> allAccounts = [Select Name FROM Account];
        Contact nonIpsContact = [Select Name, Core_IPS_Active__c FROM Contact where Core_IPS_Active__c = false Limit 1] ;
        
        
        commUser1 = allCommUsers[0];
        commUser2 = allCommUsers[1];
        
        
        System.runAs(adminUser){
            Test.startTest();
            List<Case> caseList = Core_RestAPI_TestUtilities.getListOfCases(3);
            //Assign 5 cases for admin User with blank contact id
            Case adminCase = caseList[0];
            adminCase.OwnerId = adminUser.Id;
            adminCase.ContactId = null;
            
            Case commUser1Case = caseList[1];
            commUser1Case.OwnerId = commUser1.Id;
            commUser1Case.ContactId = commUser1.ContactId;
            commUser1Case.AccountId = commUser1.Contact.AccountId;
            commUser1Case.Core_IPS_Customer_Visible__c = true;
            Case commUser2Case = caseList[2];
            commUser2Case.OwnerId = commUser2.Id;
            commUser2Case.ContactId = commUser2.ContactId;
            commUser2Case.AccountId = commUser2.Contact.AccountId;
            
            insert caseList;
            
            //Insert interested parties to the case
            List<Core_IPS_Case_Interested_Party__c> intPartyList = Core_RestAPI_TestUtilities.getInternalInterestedParties(4, 'External');
            List<Core_IPS_Case_Interested_Party__c> extPartyList = Core_RestAPI_TestUtilities.getInternalInterestedParties(2, 'Internal');
            for(Core_IPS_Case_Interested_Party__c ip : intPartyList){
                //Added cases to commUser1
                ip.Case__c = caseList[1].Id;
                ip.User__c = adminUser.Id;
            }
            for(Core_IPS_Case_Interested_Party__c ip : extPartyList){
                //Added cases to commUser2
                ip.Case__c = caseList[2].Id;
                ip.LastModifiedById = adminUser.Id;
                ip.User__c = adminUser.Id;
            }
            insert intPartyList;
            insert extPartyList;
            Test.stopTest();
        }
       
        
    }
    
    
    //Pass the version the method returns the request based on the version number 
    private static RestRequest doGet_getInterestedParties_VersionRequest(String version, String caseNbr){
        RestRequest request = (RestRequest)System.jSON.deserialize(Core_RestAPI_TestUtilities.REQUEST_TEMPLATE, RestRequest.class);
        request.httpMethod = 'GET';
        if(v1_0.equals(version)){
            request.requestUri ='/v1.0/cases/'+caseNbr+'/interestedparties'; 
            request.resourcePath ='/services/apexrest/v1.0/cases/'+caseNbr+'/interestedparties';
        }
        return request;
    }
    
    
    private static void doGet_getInterestedParties_Asserts_Positive(Core_RestAPI_Response apiResponse, RestResponse objResponse, String strVersion) {
        //Consolidate asserts so that each test method does not have to copy/paste the logic
        
        //expand if statement when multiple versions share the same asserts
        If(strVersion == v1_0) {  
            System.assertEquals('200', apiResponse.Code, ' RestAPIResponse Success code 200');
            System.assertNotEquals(null, apiResponse);
            System.assertEquals(true, apiResponse.isSuccess);
            System.assertNotEquals(null, apiResponse.successContent);
            System.assertEquals(null, apiResponse.errorContent);
            
            RestRequest request = RestContext.request;
            System.assertEquals(apiResponse.successContent.size() != null, true);
            
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
    private static void doGet_getInterestedParties_Asserts_Negative(Core_RestAPI_Response apiResponse, RestResponse objResponse, String strVersion) {
        //Consolidate asserts so that each test method does not have to copy/paste the logic
        //expand if statement when multiple versions share the same asserts
        If(strVersion == v1_0) {  
            System.assertEquals('200', apiResponse.Code, ' RestAPIResponse Success code 200');
            System.assertNotEquals(null, apiResponse);
            System.assertEquals(false, apiResponse.isSuccess);
            System.assertEquals(null, apiResponse.successContent);
            System.assertEquals(0, apiResponse.successContent.size(), 'No External interested parties');
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
    @isTest public static void test_doGet_getInterestedParties_v1_0_Positive(){
        commUser1  = [Select Name, ContactId FROM User WHERE Name = 'CommUser0 RestApiUnitTest0'];
        Case caseObj = [Select Id, CaseNumber FROM Case where ContactId =:commUser1.ContactId  Limit 1];
        RestContext.request = doGet_getInterestedParties_VersionRequest(v1_0, caseObj.CaseNumber);
        System.runAs(commUser1){
            Core_RestAPI_Response apiResponse = Core_RestApi_InterestedPartiesV1.doGet();
            doGet_getInterestedParties_Asserts_Positive(apiResponse,null ,v1_0);
        }  
    }
    
    @isTest public static void test_doGet_getInterestedParties_v1_0_Negative(){
        //Negative Case 2
        commUser2  = [Select Name FROM User WHERE Name = 'CommUser1 RestApiUnitTest0'];
        RestContext.request = doGet_getInterestedParties_VersionRequest(v1_0, 'InvalidCaseNumber');
        System.runAs(commUser2){
            Core_RestAPI_Response apiResponse = Core_RestApi_InterestedPartiesV1.doGet();
            System.assertEquals(false, apiResponse.isSuccess);
        }  
    }
    
    
}