/***************************************************************************************************
Class Name:  Core_IPS_CaseUtility_Test
Class Type: Test Class 
Version     : 1.0 
Created Date: 03 Nov 2015
Function    : This class contains test coverage for Core_IPS_CaseUtility class
Input Parameters: None 
Output Parameters: None
Description:   This class contains unit test scenarios for Core_IPS_CaseUtility class
Used in     : None
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Syed Moosa Nazir TN       11/04/2015                Created
****************************************************************************************************/   
@isTest
public class Core_IPS_CaseUtility_V1_Test{
    //Instance variables that are commonly used in multiple test methods
    static List<User> ListOfUser = new List<User> ();
    static String productId = null;
    static String SubCatId = null;
    static boolean isAgent = null;
    static List<Core_IPS_Assigned_Environment_Variables__c> ListOfEnvDetailsOperational = new List<Core_IPS_Assigned_Environment_Variables__c> ();
    /***************************************************************************************************
    Method Name:  getRecords
    Method Type: Void Method
    Version     : 1.0 
    Created Date: 03 Nov 2015
    Description:  Common Test data used in multiple test methods
    Scenario Type:  
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Syed Moosa Nazir TN       11/04/2015                Created
    ****************************************************************************************************/
    static void getRecords(){
        // Query Profiles
        Map<String,ID> profiles = new Map<String,ID>();
        List<Profile> ProfileList = [select id, name from Profile where name = 'System Administrator'];
        for(Profile prf : ProfileList){
            profiles.put(prf.name, prf.id);
        }
        // Create Users
        ListOfUser = TestUtilities.getListOfUser(1);
        for(User Usr : ListOfUser){
            Usr.ProfileID =  profiles.get('System Administrator');
        }
        insert ListOfUser;
        System.assertEquals(ListOfUser.get(0).profileid, profiles.get('System Administrator'));     
    }
  
 //Added by Geetha 
 static testmethod void parentAccount(){
        getRecords();
        string selectedProject = null;
        Set<String> customerUserTypes = new Set<String> { 'PowerPartner', 'PowerCustomerSuccess'};
       
            Account accountRecord = new Account(
            Name = 'Dell Products',
            Core_Account_Type__c = 'Distributor',
            Core_Sales_Segment__c = 'Compute',
            Industry = 'Banking',
            BillingCity = 'Delhi',
            BillingCountry = 'USA',
            billingState = 'AK',
            billingStreet = 'Bratislava 1',
            Core_IPS_Active__c = true
        );
        insert accountRecord;
        Contact contactRecord = new Contact(
            FirstName = 'Ding Dong', 
            Lastname = 'Dell3',
            Email = 'Contact1Dell@gmail.com',
            Accountid = accountRecord.id,
            //Core_IPS_Intel_Support_Owner__c=u1.id,
            Core_IPS_Active__c = true,
            MailingCountry = 'India'
        );
        insert contactRecord;
         
     	//Added by Sowmya -21/10/2024 - TWC745-6800 - Fix test coverage for all failed classes 
        Profile p =   [select Id,name from Profile where Name = 'IPS External Customer' limit 1];
       	user u1 = new User(
        //UserRoleId = ur.Id,
        profileId = p.id,
        username = 'newUser100@yahoo.com',
        email = 'newUser100@g.com',
        emailencodingkey = 'UTF-8',
        localesidkey = 'en_US',
        languagelocalekey = 'en_US',
        timezonesidkey = 'America/Los_Angeles',
        alias='nuser',
        lastname='lastname',
        contactId = contactRecord.id
        );
      contactRecord.Core_IPS_Intel_Support_Owner__c = u1.Id;
      Update contactRecord;
      System.runAs (u1) {
       //Sowmya End -21/10/2024 - TWC745-6800 - Fix test coverage for all failed classes 
          
          Core_IPS_Project__c cipspro=new Core_IPS_Project__c();
         insert cipspro;
        
            Core_IPS_Account__c  ipsAccount = new Core_IPS_Account__c();
            ipsAccount.Core_Account__c=accountRecord.id;
            ipsAccount.Core_IPS_Project__c=cipspro.id;
            insert ipsAccount;
            
            Core_IPS_Project_Member__c proMember = new Core_IPS_Project_Member__c();
            proMember.Core_IPS_Contact__c = contactRecord.id;
            proMember.Core_IPS_Project__c = cipspro.id;
            
            insert proMember;
            
          /*  
            UserRole ur = [Select PortalType, PortalAccountId From UserRole where PortalType =:'CustomerPortal' limit 1];
            //Profile p = [select Id,name from Profile where name = 'System Administrator' limit 1];
            Profile p = [select Id,name from Profile where UserType in :customerUserTypes limit 1];
            
            String orgId = UserInfo.getOrganizationId();
            String dateString =  String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
            String uniqueName = orgId + dateString ;
            
            User newUser = new User(
            UserRoleId = ur.Id,
            ProfileId = p.id,
            email = uniqueName + '@test' + orgId + '.org',
            Username = uniqueName + '@test' + orgId + '.org',
            emailencodingkey = 'UTF-8',
            localesidkey = 'en_US',
            languagelocalekey = 'en_US',
            timezonesidkey = 'America/Los_Angeles',
            alias='nuser',
            lastname='lastname',
            contactId = contactRecord.id
            );
            insert newUser;*/
            
            Test.startTest();
            //Core_IPS_CaseUtility.IssueSubCategories IssueSubCategoriesWrapper = new Core_IPS_CaseUtility.IssueSubCategories(CoreProdIssCategory_CaseCat,CoreSupportedProd);
            //Core_IPS_CaseUtility.getIPSParentAccountList(cipspro.id);
           // List<SelectOption> getIPSParentAccountList=Core_IPS_CaseUtility_dup.getIPSParentAccountList(cipspro.id);
            Test.stopTest();
        }   
    }
    
    
}