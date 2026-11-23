/****************************************************************************************************************************************
* Class Name  : Core_RestAPI_ContactV1_Handler_Test
* Version     : 1.0 
* Created Date: 6/5/2018 
* Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Team: PopcornApps         6/5/2018              This class is for testing Core_RestAPI_ContactV1_Handler methods with all the combination of inputs.
*****************************************************************************************************************************************/
@isTest 
public class Core_RestAPI_ContactV1_Handler_Test{
    
    private static User commUser1  = null;
    private static User adminUser  = null;
    private static User portalUser  = null;
    //Preparing data to be proceeded for contact list API
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
        List<User> allCommUsers = [Select Name, ContactId,accountId FROM User WHERE ContactId IN (Select Id FROM Contact) ];
        List<Contact> allIPSContacts = [Select Name, Core_IPS_Active__c FROM Contact] ;
        List<Account> allAccounts = [Select Name FROM Account];
        Contact nonIpsContact = [Select Name, Core_IPS_Active__c FROM Contact where Core_IPS_Active__c = false Limit 1] ;
        System.debug(' Core_RestAPI_Cases_Test \n Account '+allAccounts+'\n IPS Contacts '+allIPSContacts +'\n Non Contact '+nonIpsContact + ' \n All CommUsers '+allCommUsers);
        
        commUser1 = allCommUsers[0];
        System.debug(' \n commUser1  '+commUser1);
        Test.stopTest();
    }
    
    //This method test the handler methods: getProducts & processrequest
    @isTest public static void test_getContacts_Positive(){
        
        RestRequest requestObj = (RestRequest)System.jSON.deserialize(Core_RestAPI_TestUtilities.REQUEST_TEMPLATE, RestRequest.class);
        requestObj.resourcePath ='/services/apexrest/v1.0/contacts';
        requestObj.requestUri ='/v1.0/contacts';
        requestObj.httpMethod = 'GET';
        RestContext.request = requestObj;
        Core_RestAPI_ContactV1_Handler handler = new Core_RestAPI_ContactV1_Handler(System.now(), 'Core_RestAPI_ContactsV1'); 
        Core_RestAPI_Response response = handler.getContacts();
        System.assertNotEquals(null, response);
        System.assertEquals(response.code, '200');
        
        commUser1  = [Select Name FROM User WHERE Name = 'CommUser0 RestApiUnitTest0'];
        System.runAs(commUser1){
            Core_RestAPI_ContactV1_Handler handler1 = new Core_RestAPI_ContactV1_Handler(System.now(), 'Core_RestAPI_ContactsV1'); 
            Core_RestAPI_Response response1 = handler1.getContacts();
        }
    }
    
    
}