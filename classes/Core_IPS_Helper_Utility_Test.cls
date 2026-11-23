/***************************************************************************************************
Class Name:  Core_IPS_Helper_Utility_Test
Class Type: Test Class 
Version     : 1.0 
Created Date: 03 Nov 2015
Function    : This class contains test coverage for Core_IPS_Helper_Utility class
Input Parameters: None 
Output Parameters: None
Description:   This class contains unit test scenarios for Core_IPS_Helper_Utility class
Used in     : None
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Jayaprakash T              11/03/2015              Created
****************************************************************************************************/   
@isTest
public class Core_IPS_Helper_Utility_Test{
    //Instance variables that are commonly used in multiple test methods
    static List<User> ListOfUser = new List<User> ();
    static UserRole portalRole = new UserRole();
    /***************************************************************************************************
    Method Name:  getRecords()
    Method Type: void
    Version     : 1.0 
    Created Date: 05 Nov 2015
    Description:  Common Test data used for all test methods
    Scenario Type:  
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Syed Moosa Nazir TN       11/05/2015              Created
    * Deepak Jetty              03/02/2016              Modified
    ****************************************************************************************************/
    static void getRecords (){
        // Query Profiles
        Map<String,ID> profiles = new Map<String,ID>();
        List<Profile> ProfileList = [select id, name from Profile where name = 'System Administrator'];
        for(Profile prf : ProfileList){
            profiles.put(prf.name, prf.id);
        }
        //Create Role
        UserRole role = new UserRole();
        role.name='CEO';
        insert role;
        // Create Users
        ListOfUser = TestUtilities.getListOfUser(1);
        List<Core_IPS_Error_Code__c> ListofIpsErrorCodes = TestUtilities.getListOfIpsErrorCodes();
        for(User Usr : ListOfUser){
            Usr.ProfileID =  profiles.get('System Administrator');
            Usr.UserRoleID = role.id;
        }
        insert ListOfUser;
        System.assertEquals(ListOfUser.get(0).profileid, profiles.get('System Administrator'));
        // Custom Setting - Ips Lables
        
        List<Core_IPS_Labels__c> ListofIpsLables = TestUtilities.getIPSLabel();
        System.runAs(ListOfUser[0]){
            insert ListofIpsLables;
            insert ListofIpsErrorCodes;
        }
        //portalRole =TestUtilities.getCustomerUserRole();
        System.Assert(ListofIpsLables[0].Id != null, 'Records not created');
        //Custom Setting - Ips Error Codes
        
        
        System.Assert(ListofIpsErrorCodes[0].Id != null, 'Records not created');
    }

    /***************************************************************************************************
    Method Name:  getCasesByAccount_PositiveTest
    Method Type: Test Method
    Version     : 1.0 
    Created Date: 03 Nov 2015
    Description:  
    Scenario Type:  Positive
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Jayaprakash       12/27/2015                Created
    ****************************************************************************************************/
    static testmethod void getCasesByAccount_PositiveTest(){
        getRecords();
        // Create Accounts
        List<Account>  ListOfAccounts = TestUtilities.getListOfAccounts(1);
        System.runAs(listofuser[0]){
        insert ListOfAccounts;
        }
        List<id> acctIdlist = new List<Id>();
        acctIdList.add(listofaccounts[0].id);
        System.assert(ListOfAccounts[0].Id != null, 'Record not created');
        // Create Case
        List<Case> ListOfCases = TestUtilities.getListOfCases(1);
        for(Case CaseRec : ListOfCases){
            CaseRec.accountId = ListOfAccounts.get(0).Id;
        }
        system.runAs(ListofUser[0]){
        insert ListOfCases;
        }
        System.assert(ListOfCases[0].Id != null, 'Record not created');
        System.runAs(ListOfUser.get(0)){
            Test.startTest();
            List<Case> caseList = Core_IPS_Helper_Utility.getCasesByAccount(acctIdList);
            System.assertEquals(caseList.size(), 1);
            Test.stopTest();
        }
    }
    
    /***************************************************************************************************
    Method Name:  getCasesByProject_PositiveTest
    Method Type: Test Method
    Version     : 1.0 
    Created Date: 03 Nov 2015
    Description:  
    Scenario Type:  Positive
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Jayaprakash       12/27/2015                Created
    ****************************************************************************************************/
    static testmethod void getCasesByProject_PositiveTest(){
        getRecords();
        // Create Accounts
        List<Core_IPS_Project__c>  ListOfprojects = TestUtilities.getListOfIpsProjects(1);
        System.runAs(listofuser[0]){
        insert ListOfprojects;
        }
        Set<id> projIdList= new Set<Id>();
        projIdList.add(ListOfprojects[0].id);
        System.assert(ListOfprojects[0].Id != null, 'Record not created');
        // Create Case
        List<Case> ListOfCases = TestUtilities.getListOfCases(1);
        for(Case CaseRec : ListOfCases){
            CaseRec.Core_IPS_Project_Case__c = ListOfprojects.get(0).Id;
        }
        system.runAs(ListofUser[0]){
        insert ListOfCases;
        }
        System.assert(ListOfCases[0].Id != null, 'Record not created');
        System.runAs(ListOfUser.get(0)){
            Test.startTest();
            List<Case> caseList = Core_IPS_Helper_Utility.getCasesByProject(projIdList);
            System.assertEquals(caseList.size(), 1);
            Test.stopTest();
        }
    }    
    
    /***************************************************************************************************
    Method Name:  listCasesByAccount_PositiveTest
    Method Type: Test Method
    Version     : 1.0 
    Created Date: 03 Nov 2015
    Description:  
    Scenario Type:  Positive
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Syed Moosa Nazir TN       11/04/2015                Created
    ****************************************************************************************************/
    static testmethod void listCasesByAccount(){
        getRecords();
        // Create Accounts
        List<Account>  ListOfAccounts = TestUtilities.getListOfAccounts(1);
        System.runAs(listofuser[0]){
        insert ListOfAccounts;
        }
        System.assert(ListOfAccounts[0].Id != null, 'Record not created');
        // Create Case
        List<Case> ListOfCases = TestUtilities.getListOfCases(10);
        for(Case CaseRec : ListOfCases){
            CaseRec.accountId = ListOfAccounts.get(0).Id;
        }
        system.runAs(ListofUser[0]){
        insert ListOfCases;
        }
        System.assert(ListOfCases[0].Id != null, 'Record not created');
        System.runAs(ListOfUser[0]){
            Test.startTest();
            Map<Id,List<Id>> casesByAccount = Core_IPS_Helper_Utility.listCasesByAccount(ListOfCases);
            System.assert(!(casesByAccount.isEmpty()), 'listCasesByAccount method does not return the records');
            Test.stopTest();
        }
    }
    /***************************************************************************************************
    Method Name:  listCasesByAccount_NegativeTest
    Method Type: Test Method
    Version     : 1.0 
    Created Date: 03 Nov 2015
    Description:  
    Scenario Type:  Negative
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Syed Moosa Nazir TN       11/04/2015                Created
    ****************************************************************************************************/
    static testmethod void listCasesByAccount_NegativeTest(){
        getRecords();
        List<Case> ListOfCases = new List<Case> ();
        System.runAs(ListOfUser.get(0)){
            Test.startTest();
            Map<Id,List<Id>> casesByAccount = Core_IPS_Helper_Utility.listCasesByAccount(ListOfCases);
            System.assert(casesByAccount.isEmpty(), 'listCasesByAccount method returns the records');
            Test.stopTest();
        }
    }
    /***************************************************************************************************
    Method Name:  getFAEsByProject_PositiveTest
    Method Type: Test Method
    Version     : 1.0 
    Created Date: 03 Nov 2015
    Description:  getFAEsByProject invokes "ListAccountsByProject" and "getFAEsByAccount" utility methods.
    "getIPSCustomerUsersByProject" Tested in this method.
    Scenario Type:  Positive
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Syed Moosa Nazir TN       11/04/2015                Created
    ****************************************************************************************************/
    static testmethod void getFAEsByProject_PositiveTest(){
        getRecords();
        // Profile Query
        Profile SalesRepBbProfile = [select Id, name from Profile where name = 'Sales Rep-BB'];
        // Create User
        List<User> ListOfUsr = TestUtilities.getListOfUser(1);
        for(User Usr : ListOfUsr){
            Usr.UserName = 'getFAEsByProject@intel.com';
            Usr.ProfileID = SalesRepBbProfile.id;
        }
        insert ListOfUsr;
        System.Assert(ListOfUsr[0].Id != null, 'Record not created');
        // Create Accounts
        List<Account> ListOfAccounts = TestUtilities.getListOfAccounts(1);
        System.runAs(Listofuser[0]){
        insert ListOfAccounts;
        }
        
        System.assert(ListOfAccounts[0].Id != null, 'Record not created');
        for(Account Acc : ListOfAccounts){
            Acc.Ownerid = ListOfUsr.get(0).id;
        }
        System.runAs(Listofuser[0]){
        update ListOfAccounts;
        }
        System.assertEquals(ListOfAccounts[0].Ownerid, ListOfUsr.get(0).id);
        List<AccountShare> ListOfAccountShare = [select UserOrGroupId,rowcause,CaseAccessLevel from AccountShare where AccountId =:ListOfAccounts];
        for(AccountShare Share : ListOfAccountShare){
            Share.CaseAccessLevel = 'Edit';
        }
        List<Core_IPS_Project__c> ListOfIpsProjects = TestUtilities.getListOfIpsProjects(1);
         System.runAs(Listofuser[0]){
        insert ListOfIpsProjects;
         }
        List<Core_IPS_Account__c> ListOfIpsAccounts = TestUtilities.getListOfIpsAccounts(200);
        for(Core_IPS_Account__c IpsAcc : ListOfIpsAccounts){
            IpsAcc.Core_Account__c = ListOfAccounts.get(0).Id;
            IpsAcc.Core_IPS_Project__c = ListOfIpsProjects.get(0).Id;
        }
        System.runAs(Listofuser[0]){
        update ListOfAccountShare;
        
        insert ListOfIpsAccounts;
        }
        System.assertEquals(ListOfAccountShare[0].CaseAccessLevel, 'Edit');
        // Create Ips Project
        
        
        System.assert(ListOfIpsProjects[0].Id != null, 'Record not created');
        // Create Ips Account
        
        
        System.assert(ListOfIpsAccounts[0].Id != null, 'Record not created');
        Set<ID> SetOfProjId = new Set<ID> ();
        for(Core_IPS_Project__c Prj : ListOfIpsProjects){
            SetOfProjId.add(Prj.Id);
        }
        System.runAs(ListOfUser.get(0)){
            Test.startTest();
            Map<Id,Set<Id>> faesByProject = Core_IPS_Helper_Utility.getFAEsByProject(SetOfProjId);
            System.assert(!(faesByProject.isEmpty()), 'faesByProject method does not return the records');
            Map<Id,Set<Id>> projIdUserIdsMap = Core_IPS_Helper_Utility.getIPSCustomerUsersByProject(SetOfProjId);
            System.assert(!(projIdUserIdsMap.isEmpty()), 'getIPSCustomerUsersByProject method does not return the records');
            Test.stopTest();
        }
    }   
    /***************************************************************************************************
    Method Name:  getFAEsByProject_NegativeTest
    Method Type: Test Method
    Version     : 1.0 
    Created Date: 03 Nov 2015
    Description: 
    Scenario Type:  Negative
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Syed Moosa Nazir TN       11/04/2015                Created
    ****************************************************************************************************/
    static testmethod void getFAEsByProject_NegativeTest(){
        getRecords();
        Set<ID> SetOfProjId = new Set<ID> ();
        System.runAs(ListOfUser.get(0)){
            Test.startTest();
            Map<Id,Set<Id>> faesByProject = Core_IPS_Helper_Utility.getFAEsByProject(SetOfProjId);
            System.assert(faesByProject.isEmpty(), 'faesByProject method returns the record');
            Map<Id,Set<Id>> projIdUserIdsMap = Core_IPS_Helper_Utility.getIPSCustomerUsersByProject(SetOfProjId);
            System.assert(projIdUserIdsMap == null, 'getIPSCustomerUsersByProject method returns the record');
            Test.stopTest();
        }
    }
    /***************************************************************************************************
    Method Name:  listAssetsByProject_PositiveTest
    Method Type: Test Method
    Version     : 1.0 
    Created Date: 03 Nov 2015
    Description:  Testing "getAssets" and "listAssetsByProject" utility  method
    Scenario Type:  Positive
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Syed Moosa Nazir TN       11/04/2015                Created
    ****************************************************************************************************/
    static testmethod void listAssetsByProject_PositiveTest(){
        getRecords();
        // Create Accounts
        List<Account> ListOfAccounts = TestUtilities.getListOfAccounts(1);
        system.runAs(ListofUser[0]){
        insert ListOfAccounts;
        }
        System.assert(ListOfAccounts[0].Id != null, 'Record not created');
        // Create Ips Projects
        List<Core_IPS_Project__c> ListOfIpsProjects = TestUtilities.getListOfIpsProjects(1);
        system.runAs(ListofUser[0]){
        insert ListOfIpsProjects;
        }
        System.Assert(ListOfIpsProjects[0].Id != null, 'Record not created');
        // Create Asset
        list<Asset> AssetList = TestUtilities.getAssetList(200);
        for(Asset Asst : AssetList){
            Asst.Core_IPS_Project__c = ListOfIpsProjects.get(0).Id;
            Asst.accountId = ListOfAccounts.get(0).Id;
        }
        system.runAs(ListofUser[0]){
        insert AssetList;
        }
        System.assert(AssetList[0].Id != null, 'Record not created');
        List<String> ListOfAccId = new List<String> ();
        for(Asset Asst : AssetList){
            ListOfAccId.add(ListOfAccounts.get(0).Id);
        }
        System.runAs(ListOfUser.get(0)){
            Test.startTest();
            List<Asset> assetLst = Core_IPS_Helper_Utility.getAssets(ListOfAccId);
            System.assert(!(assetLst.isEmpty()), 'getAssets method does not return the records');
            Map<Id,Set<Id>> assetsByProject = Core_IPS_Helper_Utility.listAssetsByProject(AssetList);
            System.assert(!(assetsByProject.isEmpty()), 'listAssetsByProject method does not return the records');
            Map<Id,List<Id>> assetsByAccount = Core_IPS_Helper_Utility.getAssetsByAccount(AssetList);
            System.assert(!(assetsByAccount.isEmpty()), 'getAssetsByAccount method does not return the records');
            
            Test.stopTest();
        }
    } 
    /***************************************************************************************************
    Method Name:  listAssetsByProject_NegativeTest
    Method Type: Test Method
    Version     : 1.0 
    Created Date: 03 Nov 2015
    Description:  Testing "getAssets" and "listAssetsByProject" utility  method
    Scenario Type:  Negative
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Syed Moosa Nazir TN       11/04/2015                Created
    ****************************************************************************************************/
    static testmethod void listAssetsByProject_NegativeTest(){
        getRecords();
        List<Asset> AssetList = new List<Asset>();
        List<String> ListOfAccId;
        System.runAs(ListOfUser.get(0)){
            Test.startTest();
            List<Asset> assetLst = Core_IPS_Helper_Utility.getAssets(ListOfAccId);
            System.assertEquals(assetLst, null);
            Map<Id,Set<Id>> assetsByProject = Core_IPS_Helper_Utility.listAssetsByProject(AssetList);
            System.assert(assetsByProject.isEmpty(), 'listAssetsByProject method returns the record');
            Map<Id,List<Id>> assetsByAccount = Core_IPS_Helper_Utility.getAssetsByAccount(AssetList);
            System.assert(assetsByAccount.isEmpty(), 'getAssetsByAccount method return records');
            Test.stopTest();
        }
    }
    /***************************************************************************************************
    Method Name:  getIPSCustUsersbyAccounts_PositiveTest
    Method Type: Test Method
    Version     : 1.0 
    Created Date: 03 Nov 2015
    Description:  Testing "getIPSCustUsersbyAccounts(Set<id> AccountIdSet)" and "isIPSCustomerUser()" method
    Scenario Type:  Positive
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Syed Moosa Nazir TN       11/04/2015                Created
    ****************************************************************************************************/
    static testmethod void getIPSCustUsersbyAccounts_PositiveTest(){
        getRecords();
        // Get intelSupportOwner Id (User Id)
        Id intelSupportOwner = ListOfUser.get(0).id;
        // Create Account
        List<Account> ListOfAccounts = TestUtilities.getListOfAccounts(1);
        System.runAs(ListOfUser[0]){
        insert ListOfAccounts;
        }
        System.assert(ListOfAccounts[0].Id != null, 'Record not created');
        // Create Contact
        List<Contact> ListOfContacts = TestUtilities.getListOfContact(2);
        for(Contact ContactRec : ListOfContacts){
            ContactRec.Accountid = ListOfAccounts.get(0).Id;
            ContactRec.Core_IPS_Intel_Support_Owner__c = intelSupportOwner;
        }
        System.runAs(Listofuser[0]){
        insert ListOfContacts;
        }
        System.assert(ListOfContacts[0].Id != null, 'Record not created');
        // Profile Query
        Profile CustomerProfile = [select Id,name from Profile where UserType = 'PowerCustomerSuccess' limit 1];
        // Creating Customer User
        List<User> ListOfUsr = TestUtilities.getListOfUser(2);
        String searchStr = listofAccounts[0].name+'%';
        //UserRole role = [select id from userrole where portaltype='CustomerPortal' limit 1];
        integer Counter = 0;
        for(User Usr : ListOfUsr){
            Usr.ProfileID = CustomerProfile.id;
            Usr.UserName = Counter+'getFAEsByProject@intel.com';
            if(Counter==0)
            Usr.contactId = ListOfContacts.get(0).id;
            else
            Usr.contactId = ListOfContacts.get(1).id;
            Counter++;
           
        }
        System.runAs(listofuser[0]){
        insert ListOfUsr;
        update listofAccounts;
        }
        System.assertEquals(ListOfUsr[0].ProfileID, CustomerProfile.id);
        Set<ID> SetOfAccId = new Set<ID> ();
        for(Account Acc : ListOfAccounts){
            SetOfAccId.add(Acc.Id);
        }
        System.runAs(Listofuser[0]){
            Test.startTest();
            Map<id,Set<id>> UsersbyAccount = Core_IPS_Helper_Utility.getIPSCustUsersbyAccounts(SetOfAccId);
            //System.assert(!(UsersbyAccount.isEmpty()), 'getIPSCustUsersbyAccounts method does not return the record');
            boolean isAgent = Core_IPS_Helper_Utility.isIPSCustomerUser();
            System.AssertEquals(isAgent, true);
            Test.stopTest();
        }
        // Execute the code as Customer
        System.runAs(ListOfUsr.get(0)){
            boolean isAgent = Core_IPS_Helper_Utility.isIPSCustomerUser();
            System.AssertEquals(isAgent, false);
        }
        
    }
    /***************************************************************************************************
    Method Name:  getIPSCustUsersbyAccounts_NegativeTest
    Method Type: Test Method
    Version     : 1.0 
    Created Date: 03 Nov 2015
    Description:  Testing "getIPSCustUsersbyAccounts(Set<id> AccountIdSet)"
    Scenario Type:  Negative
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Syed Moosa Nazir TN       11/04/2015                Created
    ****************************************************************************************************/
    static testmethod void getIPSCustUsersbyAccounts_NegativeTest(){
        getRecords();
        Set<ID> SetOfAccId = new Set<ID> ();
        System.runAs(ListOfUser.get(0)){
            Test.startTest();
            Map<id,Set<id>> UsersbyAccount = Core_IPS_Helper_Utility.getIPSCustUsersbyAccounts(SetOfAccId);
            System.assert(UsersbyAccount.isEmpty(), 'getIPSCustUsersbyAccounts method returns the record');
            Test.stopTest();
        }
    }
    /***************************************************************************************************
    Method Name:  getIntelSupportOwnerByContact_PositiveTest
    Method Type: Test Method
    Version     : 1.0 
    Created Date: 03 Nov 2015
    Description:  Testing "getIntelSupportOwnerByContact(Set<String> contIdSet)"
    Scenario Type:  Positive
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Syed Moosa Nazir TN       11/04/2015                Created
    ****************************************************************************************************/
    static testmethod void getIntelSupportOwnerByContact_PositiveTest(){
        getRecords();
        
        // Get intelSupportOwner Id (User Id)
        Id intelSupportOwner = ListOfUser.get(0).id;
        
        List<Account> ListOfAccounts = TestUtilities.getListOfAccounts(1);
        System.runAs(Listofuser[0]){
            insert ListOfAccounts;
        }        
        System.assert(ListOfAccounts[0].Id != null, 'Record not created');
        
        // Create Contact
        List<Contact> ListOfContacts = TestUtilities.getListOfContact(1);
        for(Contact ContactRec : ListOfContacts){
            ContactRec.Core_IPS_Intel_Support_Owner__c = intelSupportOwner;
            ContactRec.Core_IPS_Active__c              = false;
            ContactRec.Accountid                       = ListOfAccounts.get(0).Id;            
        }
        System.runAs(ListOfUser[0]){
            insert ListOfContacts;
        }
        
        System.assert(ListOfContacts[0].Id != null, 'Record not created');
        Set<String> SetOfContactId = new Set<String> ();
        for(Contact Con : ListOfContacts){
            SetOfContactId.add(Con.id);
        }
        
        System.runAs(ListOfUser.get(0)){
            Test.startTest();
            Map<Id,Id> isoByContact = Core_IPS_Helper_Utility.getIntelSupportOwnerByContact(SetOfContactId);
            System.assert(!(isoByContact.isEmpty()), 'getIntelSupportOwnerByContact method does not return the record');
            Test.stopTest();
        }
    }
    /***************************************************************************************************
    Method Name:  getIntelSupportOwnerByContact_NegativeTest
    Method Type: Test Method
    Version     : 1.0 
    Created Date: 03 Nov 2015
    Description:  Testing "getIntelSupportOwnerByContact(Set<String> contIdSet)"
    Scenario Type:  Negative
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Syed Moosa Nazir TN       11/04/2015                Created
    ****************************************************************************************************/
    static testmethod void getIntelSupportOwnerByContact_NegativeTest(){
        getRecords();
        Set<String> SetOfContactId = new Set<String> ();
        System.runAs(ListOfUser.get(0)){
            Test.startTest();
            Map<Id,Id> isoByContact = Core_IPS_Helper_Utility.getIntelSupportOwnerByContact(SetOfContactId);
            System.assert(isoByContact.isEmpty(), 'getIntelSupportOwnerByContact method returns the record');
            Test.stopTest();
        }
    }
    /***************************************************************************************************
    Method Name:  getIntelSupportOwner_PositiveTest
    Method Type: Test Method
    Version     : 1.0 
    Created Date: 03 Nov 2015
    Description:  Testing "getIntelSupportOwner()" and "getIntelSupportOwner(Id ContactRecordId)" method
    Scenario Type:  Positive
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Syed Moosa Nazir TN       11/04/2015                Created
    ****************************************************************************************************/
    static testmethod void getIntelSupportOwner_PositiveTest(){
        getRecords();
        // Get intelSupportOwner Id (User Id)
        Id intelSupportOwner = ListOfUser.get(0).id;
        // Create Account
        List<Account> ListOfAccounts = TestUtilities.getListOfAccounts(1);
        System.runAs(Listofuser[0]){
        insert ListOfAccounts;
        }
        System.assert(ListOfAccounts[0].Id != null, 'Record not created');
        // Create Contact
        List<Contact> ListOfContacts = TestUtilities.getListOfContact(1);
        for(Contact ContactRec : ListOfContacts){
            ContactRec.Accountid = ListOfAccounts.get(0).Id;
            ContactRec.Core_IPS_Intel_Support_Owner__c = intelSupportOwner;
        }
        System.runAs(Listofuser[0]){
        insert ListOfContacts;
        }
        System.assert(ListOfContacts[0].Id != null, 'Record not created');
        // Profile Query
        Profile CustomerProfile = [select Id,name from Profile where UserType = 'PowerCustomerSuccess' limit 1];
        // Creating Customer User
        List<User> ListOfUsr = TestUtilities.getListOfUser(1);
        String searchStr = listofAccounts[0].name+'%';
        //UserRole portalRole1 = [Select Id From UserRole Where PortalType = 'CustomerPortal' and name like :searchStr Limit 1];
        //role.name='CEO';
        //insert role;
        for(User Usr : ListOfUsr){
            Usr.ProfileID = CustomerProfile.id;
            //usr.userroleid =portalRole1.Id;
            Usr.contactId = ListOfContacts.get(0).id;
            Usr.UserName = 'getFAEsByProject@intel.com';
        }
        System.runAs(listofuser[0]){
        insert ListOfUsr;
        }
        System.assertEquals(ListOfUsr[0].ProfileID, CustomerProfile.id);
        System.runAs(listofusr[0]){
            Test.startTest();
            Id IntelSupportOwnerId = Core_IPS_Helper_Utility.getIntelSupportOwner();
            System.assert(IntelSupportOwnerId != null, 'getIntelSupportOwner method does not return the record');
            Id IntelSupportOwnId = Core_IPS_Helper_Utility.getIntelSupportOwner(ListOfContacts.get(0).id);
            System.assert(IntelSupportOwnId != null, 'getIntelSupportOwner method does not return the records');
            Test.stopTest();
        }
    }
    /***************************************************************************************************
    Method Name:  getIntelSupportOwner_NegativeTest
    Method Type: Test Method
    Version     : 1.0 
    Created Date: 03 Nov 2015
    Description:  Testing "getIntelSupportOwner()" and "getIntelSupportOwner(Id ContactRecordId)" method
    Scenario Type:  Negative
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Syed Moosa Nazir TN       11/04/2015                Created
    ****************************************************************************************************/
    static testmethod void getIntelSupportOwner_NegativeTest(){
        getRecords();
        id Contactid;
        System.runAs(ListOfUser.get(0)){
            Test.startTest();
            Id IntelSupportOwnerId = Core_IPS_Helper_Utility.getIntelSupportOwner();
            System.assertEquals(IntelSupportOwnerId, null);
            //Id IntelSupportOwnId = Core_IPS_Helper_Utility.getIntelSupportOwner(Contactid);
            //System.assertEquals(IntelSupportOwnId, null);
            Test.stopTest();
        }
    }
    /***************************************************************************************************
    Method Name:  isGECAccount_PositiveTest
    Method Type: Test Method
    Version     : 1.0 
    Created Date: 03 Nov 2015
    Description:  Testing "isGECAccount()" and  method "isGECAccount(id contId)"
    Scenario Type:  Positive
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Syed Moosa Nazir TN       11/04/2015                Created
    ****************************************************************************************************/
    static testmethod void isGECAccount_PositiveTest(){
        getRecords();
        // Get intelSupportOwner Id (User Id)
        Id intelSupportOwner = ListOfUser.get(0).id;
        // Create Account
        List<Account> ListOfAccounts = TestUtilities.getListOfAccounts(2);
        integer counter = 0;
        for(Account Acc : ListOfAccounts){
            if(counter ==0)
            Acc.Core_Military_Aerospace_and_Government__c = true;
            else
            Acc.Core_Military_Aerospace_and_Government__c = false;
            counter++;  
        }
        counter = 0;
        system.runAs(ListofUser[0]){
        insert ListOfAccounts;
        }
        System.assert(ListOfAccounts[0].Id != null, 'Record not created');
        // Create Contact
        List<Contact> ListOfContacts = TestUtilities.getListOfContact(2);
        for(Contact ContactRec : ListOfContacts){
            ContactRec.Core_IPS_Intel_Support_Owner__c = intelSupportOwner;
            if(counter == 0)
            ContactRec.Accountid = ListOfAccounts.get(0).Id;
            else
            ContactRec.Accountid = ListOfAccounts.get(1).Id;
            counter++;
        }
        system.runAs(ListofUser[0]){
        insert ListOfContacts;
        }
        System.assert(ListOfContacts[0].Id != null, 'Record not created');
        counter = 0;
        // Profile Query
        Profile CustomerProfile = [select Id,name from Profile where UserType = 'PowerCustomerSuccess' limit 1];
        // Creating Customer User
        List<User> ListOfUsr = TestUtilities.getListOfUser(2);
        for(User Usr : ListOfUsr){
            Usr.UserName = counter+'getFAEsByProject@intel.com';
            Usr.ProfileID = CustomerProfile.id;
            if(counter == 0)
            Usr.contactId = ListOfContacts.get(0).id;
            else
            Usr.contactId = ListOfContacts.get(1).id;
            counter++;
        }
        System.runAs(listofuser[0]){
        insert ListOfUsr;
        }
        System.assertEquals(ListOfUsr[0].ProfileID, CustomerProfile.id);
        Test.startTest();
        // Non GEC Account User
        System.runAs(listofusr[0]){
            boolean isGECAccount = Core_IPS_Helper_Utility.isGECAccount(); 
            System.AssertEquals(isGECAccount, true);
            boolean isGECAcct = Core_IPS_Helper_Utility.isGECAccount(ListOfContacts.get(0).id);
            System.AssertEquals(isGECAcct, true);
        }
        // GEC Account User
        System.runAs(ListOfUsr.get(0)){
            boolean isGECAccount = Core_IPS_Helper_Utility.isGECAccount();
            System.AssertEquals(isGECAccount, true);
            boolean isGECAcc = Core_IPS_Helper_Utility.isGECAccount(ListOfContacts.get(0).id);
            System.AssertEquals(isGECAcc, true);
        }
        Test.stopTest();
    }
    /***************************************************************************************************
    Method Name:  isGECAccount_NegativeTest
    Method Type: Test Method
    Version     : 1.0 
    Created Date: 03 Nov 2015
    Description:  Testing "isGECAccount()" and  method "isGECAccount(id contId)"
    Scenario Type:  Negative
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Syed Moosa Nazir TN       11/04/2015                Created
    ****************************************************************************************************/
    static testmethod void isGECAccount_NegativeTest(){
        getRecords();

        // Get intelSupportOwner Id (User Id)
        Id intelSupportOwner = ListOfUser.get(0).id;
        
        List<Account> ListOfAccounts = TestUtilities.getListOfAccounts(1);
        System.runAs(Listofuser[0]){
            insert ListOfAccounts;
        }        
        System.assert(ListOfAccounts[0].Id != null, 'Record not created');
        
        List<Contact> ListOfContacts = TestUtilities.getListOfContact(1);
        for(Contact ContactRec : ListOfContacts){
            ContactRec.Core_IPS_Intel_Support_Owner__c = intelSupportOwner;
            ContactRec.Core_IPS_Active__c              = false;
            ContactRec.Accountid                       = ListOfAccounts.get(0).Id;
        }        
        
        // Run as System Admin
        System.runAs(ListOfUser.get(0)){
            insert ListOfContacts;
            Test.startTest();
            boolean isGECAccount = Core_IPS_Helper_Utility.isGECAccount(); 
            System.AssertEquals(isGECAccount, false);
            boolean isGECAcct = Core_IPS_Helper_Utility.isGECAccount(ListOfContacts[0].id);
            System.AssertEquals(isGECAcct, false);
            Test.stopTest();
        }
    }

    /***************************************************************************************************
    Method Name:  getAccountsfromContacts_PositiveTest
    Method Type: Test Method
    Version     : 1.0 
    Created Date: 03 Nov 2015
    Description:  Testing "getAccountsfromContacts(List<Account> acctList, List<Contact> conList)" 
    Scenario Type:  Positive
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Syed Moosa Nazir TN       11/04/2015                Created
    ****************************************************************************************************/
    static testmethod void getAccountsfromContacts_PositiveTest(){
        getRecords();
        // Get intelSupportOwner Id (User Id)
        Id intelSupportOwner = ListOfUser.get(0).id;
        // Create Account
        List<Account> ListOfAccounts = TestUtilities.getListOfAccounts(1);
        System.runAs(Listofuser[0]){
        insert ListOfAccounts;
        }
        System.assert(ListOfAccounts[0].Id != null, 'Record not created');
        // Create Contact
        List<Contact> ListOfContacts = TestUtilities.getListOfContact(1);
        for(Contact ContactRec : ListOfContacts){
            ContactRec.Core_IPS_Intel_Support_Owner__c = intelSupportOwner;
            ContactRec.Accountid = ListOfAccounts.get(0).Id;
        }
        System.runAs(Listofuser[0]){
        insert ListOfContacts;
        }
        System.assert(ListOfContacts[0].Id != null, 'Record not created');
        // Run as System Admin
        System.runAs(ListOfUser.get(0)){
            Test.startTest();
            Map<Contact,Account> ContoAcc = Core_IPS_Helper_Utility.getAccountsfromContacts(ListOfAccounts,ListOfContacts);
            System.assert(!(ContoAcc.isEmpty()), 'getAccountsfromContacts method does not return the record');
            Test.stopTest();
        }
    }
    /***************************************************************************************************
    Method Name:  getAccountsfromContacts_NegativeTest
    Method Type: Test Method
    Version     : 1.0 
    Created Date: 03 Nov 2015
    Description:  Testing "getAccountsfromContacts(List<Account> acctList, List<Contact> conList)" 
    Scenario Type:  Negative
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Syed Moosa Nazir TN       11/04/2015                Created
    ****************************************************************************************************/
    static testmethod void getAccountsfromContacts_NegativeTest(){
        getRecords();
        List<Account> ListOfAccounts = new List<Account> ();
        List<Contact> ListOfContacts = new List<Contact> ();
        // Run as System Admin
        System.runAs(ListOfUser.get(0)){
            Test.startTest();
            Map<Contact,Account> ContoAcc = Core_IPS_Helper_Utility.getAccountsfromContacts(ListOfAccounts,ListOfContacts);
            System.assert(ContoAcc.isEmpty(), 'getAccountsfromContacts method returns record');
            Test.stopTest();
        }
    }

    /***************************************************************************************************
    Method Name:  getOrgAdminsByOrg_PositiveTest
    Method Type: Test Method
    Version     : 1.0 
    Created Date: 03 Nov 2015
    Description:  Testing "getOrgAdminsByOrg(List<string> ListOfSupportOrgId)" and "GetSetOfUsersbyQueueID(id UserOrGroupId)" utility  method
    Scenario Type:  Positive
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Syed Moosa Nazir TN       11/04/2015                Created
    ****************************************************************************************************/
    static testmethod void getOrgAdminsByOrg_PositiveTest(){
        getRecords();
        Group QueueRecord = TestUtilities.getQueue();
        System.runAs(Listofuser[0]){
        insert QueueRecord;
        }
        System.Assert(QueueRecord.Id != null, 'Record not created');
        Group PublicGroupRecord = new Group();
        PublicGroupRecord.Name = 'TestPublicGroup';
        insert PublicGroupRecord;
        System.Assert(PublicGroupRecord.Id != null, 'Record not created');
        System.runAs(Listofuser[0]){
            QueuesObject MappingQueueRecord = TestUtilities.getMappingQueue();
            MappingQueueRecord.QueueID = QueueRecord.id;
            MappingQueueRecord.SobjectType = 'Core_IPS_Product_Organization__c';
            System.runAs(listofUser[0]){
            insert MappingQueueRecord;
            }
            System.Assert(MappingQueueRecord.Id != null, 'Record not created');
            GroupMember groupMemberObject_User = new GroupMember(
                GroupId = PublicGroupRecord.Id,
                UserOrGroupId = UserInfo.getUserId()
            );
            insert groupMemberObject_User;
            System.Assert(groupMemberObject_User.Id != null, 'Record not created');
            GroupMember groupMemberObject_Group = new GroupMember(
                GroupId = QueueRecord.Id,
                UserOrGroupId = PublicGroupRecord.id
            );
            insert groupMemberObject_Group;  
            System.Assert(groupMemberObject_Group.Id != null, 'Record not created');
        }
        
        List<Core_IPS_Product_Organization__c> ListOfSupportOrg  = TestUtilities.getListOfSupportOrg(1);
        for(Core_IPS_Product_Organization__c SupportOrg : ListOfSupportOrg){
            SupportOrg.OwnerId = QueueRecord.Id;
        }
        System.runAs(listofuser[0]){
        insert ListOfSupportOrg;
        }
        System.assertEquals(ListOfSupportOrg[0].OwnerId, QueueRecord.Id);
       //List<Core_IPS_Product_Organization__c> ListOfSupportOrgId = new List<Core_IPS_Product_Organization__c>();
        //{ListOfSupportOrg};
        // "getOrgAdminsByOrg" Utility method is not handling bulk Support Org in the Utility Class. But Utility Method Input parameter is LIST. - Syed
        System.runAs(ListOfUser.get(0)){
        Test.startTest();
            Core_IPS_Helper_Utility.getOrgAdminsByOrg(ListOfSupportOrg);
            //System.Assert(AllUserIdSet != null, 'getOrgAdminsByOrg method does not return the record');
            Set<Id> SetOfUserId = Core_IPS_Helper_Utility.GetSetOfUsersbyQueueID(QueueRecord.Id);
            System.Assert(SetOfUserId != null, 'GetSetOfUsersbyQueueID method does not return the record');
            Set<Id> SetOfUserIds  = Core_IPS_Helper_Utility.GetSetOfUsersbyQueueID(UserInfo.getUserId());
            System.Assert(SetOfUserIds != null, 'GetSetOfUsersbyQueueID method does not return the record');
            Test.stopTest();
        }
    } 
    /***************************************************************************************************
    Method Name:  getOrgAdminsByOrg_NegativeTest
    Method Type: Test Method
    Version     : 1.0 
    Created Date: 03 Nov 2015
    Description:  Testing "getOrgAdminsByOrg(List<string> ListOfSupportOrgId)" and "GetSetOfUsersbyQueueID(id UserOrGroupId)" utility  method
    Scenario Type:  Positive
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Syed Moosa Nazir TN       11/04/2015                Created
    ****************************************************************************************************/
    static testmethod void getOrgAdminsByOrg_NegativeTest(){
        getRecords();
        List<string> ListOfSupportOrgId = new List<string>();
        id UserRecordID;
        // "getOrgAdminsByOrg" Utility method is not handling bulk Support Org in the Utility Class. But Utility Method Input parameter is LIST. - Syed
        System.runAs(ListOfUser.get(0)){
            Test.startTest();
            //Set<Id> AllUserIdSet = Core_IPS_Helper_Utility.getOrgAdminsByOrg(ListOfSupportOrgId);
            //System.assert(AllUserIdSet.isEmpty(), 'getOrgAdminsByOrg method returns the records');
            Set<Id> SetOfUserId = Core_IPS_Helper_Utility.GetSetOfUsersbyQueueID(UserRecordID);
            System.Assert(SetOfUserId.isEmpty(), 'GetSetOfUsersbyQueueID method returns the records');
            Test.stopTest();
        }
    }
    /***************************************************************************************************
    Method Name:  getFAEsofAccount_PositiveTest
    Method Type: Test Method
    Version     : 1.0 
    Created Date: 03 Nov 2015
    Description:  Testing "getFAEsofAccount(Account Acc, List<String> UserInContext)" utility  method
    Scenario Type:  Positive
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Syed Moosa Nazir TN       11/04/2015                Created
    * Deepak Jetty              03/02/2016                Modified
    ****************************************************************************************************/
    static testmethod void getFAEsofAccount_PositiveTest(){
        getRecords();
        // Get intelSupportOwner Id (User Id)
        Id intelSupportOwner = ListOfUser.get(0).id;
        // Create Account
        List<Account> ListOfAccounts = TestUtilities.getListOfAccounts(1);
        for(Account acc:ListOfAccounts){
                acc.OwnerId=intelSupportOwner;
            }
        System.runAs(ListOfUser[0]){
        insert ListOfAccounts;
        }
        List<Core_IPS_Labels__c> IPSLabel = TestUtilities.getIPSLabel();
        System.runAs(ListOfUser[0]){
        Insert IPSLabel;
        }
        System.assert(ListOfAccounts[0].Id != null, 'Record not created');
        //List<string> ListOfAccId = new List<string> ();
        List<string> ListOfUserId = new List<string> ();

        for(User Usr : ListOfUser){
            ListOfUserId.add(Usr.Id);
        }
        System.runAs(ListOfUser.get(0)){
            Test.startTest();
            boolean ValueReturned = Core_IPS_Helper_Utility.getFAEsofAccount(ListOfAccounts.get(0),ListOfUserId);
            System.assertEquals(ValueReturned, true);
            Test.stopTest();
        }
    }
    /***************************************************************************************************
    Method Name:  getFAEsofAccount_NegativeTest
    Method Type: Test Method
    Version     : 1.0 
    Created Date: 03 Nov 2015
    Description:  Testing "getFAEsofAccount(List<String> AccIds, List<String> UserInContext)" utility  method
    Scenario Type:  Negative
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Syed Moosa Nazir TN       11/04/2015                Created
    * Deepak Jetty              02/03/2016                Modified
    ****************************************************************************************************/
    static testmethod void getFAEsofAccount_NegativeTest(){
        getRecords();
        
        // Get intelSupportOwner Id (User Id)
        Id intelSupportOwner = ListOfUser.get(0).id;
        
        // Query Profiles
        Map<String,ID> profiles = new Map<String,ID>();
        List<Profile> ProfileList = [select id, name from Profile where name = 'IPS Data Migration'];
        for(Profile prf : ProfileList){
            profiles.put(prf.name, prf.id);
        }
        //Create Role
        UserRole role = new UserRole();
        role.name='CEO';
        insert role;
        // Create Users
        List<User> ListOfUserAccount = new List<User> ();
        ListOfUserAccount = TestUtilities.getListOfUser(2);
        Integer Count=1;
        for(User Usr : ListOfUserAccount){
            Usr.ProfileID =  profiles.get('IPS Data Migration');
            Usr.UserRoleID = role.id;
            Usr.UserName = Count+'AccountTestnewuser@intel.com';
            Count++;
        }
        Count=0;
        insert ListOfUserAccount;
        System.assertEquals(ListOfUserAccount.get(0).profileid, profiles.get('IPS Data Migration'));
        
        // Create Account
        List<Account> ListOfAccounts = TestUtilities.getListOfAccounts(1);
        System.runAs(ListOfUser[0]){
        insert ListOfAccounts;
            for(Account acc:ListOfAccounts){
                acc.OwnerId=ListOfUserAccount[0].id;
            }
            update ListOfAccounts;
            List<AccountShare> ListOfAccountShare = [select UserOrGroupId,rowcause,CaseAccessLevel from AccountShare where AccountId =:ListOfAccounts];
            for(AccountShare Share : ListOfAccountShare){
                Share.CaseAccessLevel = 'Edit';
            }
            update ListOfAccountShare;
        }
        System.assert(ListOfAccounts[0].Id != null, 'Record not created');
        List<Core_IPS_Labels__c> IPSLabel = TestUtilities.getIPSLabel();
        System.runAs(ListOfUser[0]){
        Insert IPSLabel;
        }
        List<string> ListOfUserId = new List<string> ();

        ListOfUserId.add(ListOfUserAccount.get(1).id);
        System.runAs(ListOfUser.get(0)){
            Test.startTest();
            boolean ValueReturned = Core_IPS_Helper_Utility.getFAEsofAccount(ListOfAccounts.get(0),ListOfUserId);
            System.debug('ValueReturned***********'+ValueReturned);
            System.assert(ValueReturned== null,'Value Returned is true');
            Test.stopTest();
        }

    }

    /***************************************************************************************************
    Method Name:  listCasesByProject_PositiveTest
    Method Type: Test Method
    Version     : 1.0 
    Created Date: 24 Jan 2016
    Description:  This method tests whether the cases are returned properly by projects
    Scenario Type:  Positive
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Jayaprakash T             01/24/2016                Created
    ****************************************************************************************************/    
    static testMethod void listCasesByProject_PositiveTest(){
        getRecords();
        System.runAs(listofuser[0]){
            List<Core_IPS_Project__c> projList = TestUtilities.getListOfIpsProjects(1);
            insert projList;
            List<Core_IPS_Account__C> ipsProjAcctList = TestUtilities.getListOfIpsAccounts(1);
            for(Core_IPS_Account__C ipsAct:ipsProjAcctList){
                ipsAct.core_ips_project__c=projList[0].id;
            }
            insert ipsProjAcctList;
            List<Case> ListOfCases = TestUtilities.getListOfCases(1);
            for(Case CaseRec : ListOfCases){
                CaseRec.Core_IPS_Project_Case__c= projList[0].id;
            }
            insert ListOfCases;
            Test.startTest();
            Map<Id, List<ID>> casesByProject = Core_IPS_Helper_Utility.listCasesByProject(ListOfCases);
            Set<Id> projIdSet = casesByProject.keySet();
            System.assertEquals(1,casesByProject.get(projList[0].id).size());
            Test.stopTest();
        }
    }

    /***************************************************************************************************
    Method Name:  listCasesByProject_PositiveTest2
    Method Type: Test Method
    Version     : 1.0 
    Created Date: 24 Jan 2016
    Description:  This method tests whether the cases are returned properly by projects, two projects in this scenario
    Scenario Type:  Positive
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Jayaprakash T             01/24/2016                Created
    ****************************************************************************************************/    
    static testMethod void listCasesByProject_PositiveTest2(){
        getRecords();
        System.runAs(listofuser[0]){
            List<Core_IPS_Project__c> projList = TestUtilities.getListOfIpsProjects(2);
            insert projList;
            List<Core_IPS_Account__C> ipsProjAcctList = TestUtilities.getListOfIpsAccounts(6);
            for(Core_IPS_Account__C ipsAct:ipsProjAcctList){
                ipsAct.core_ips_project__c=projList[0].id;
            }
            insert ipsProjAcctList;
            List<Case> ListOfCases = TestUtilities.getListOfCases(2);
            Integer i=0;
            for(Case CaseRec : ListOfCases){
                if(i<1)
                    CaseRec.Core_IPS_Project_Case__c= projList[0].id;
                else
                    CaseRec.Core_IPS_Project_Case__c= projList[1].id;
                i++;
            }
            insert ListOfCases;
            Test.startTest();
            Map<Id, List<ID>> casesByProject = Core_IPS_Helper_Utility.listCasesByProject(ListOfCases);
            Set<Id> projIdSet = casesByProject.keySet();
            System.assertEquals(1,casesByProject.get(projList[0].id).size());
            System.assertEquals(1,casesByProject.get(projList[1].id).size());
            Test.stopTest();
        }
    }    

    /***************************************************************************************************
    Method Name:  listCasesByProject_Negative
    Method Type: Test Method
    Version     : 1.0 
    Created Date: 24 Jan 2016
    Description:  This method tests whether the cases are returned properly by projects. 
                  testing here if cases are returned only if they are linked with projects
    Scenario Type:  Positive
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Jayaprakash T             01/24/2016                Created
    ****************************************************************************************************/    
    static testMethod void listCasesByProject_Negative(){
        getRecords();
        System.runAs(listofuser[0]){
            List<Core_IPS_Project__c> projList = TestUtilities.getListOfIpsProjects(1);
            insert projList;
            List<Core_IPS_Account__C> ipsProjAcctList = TestUtilities.getListOfIpsAccounts(1);
            for(Core_IPS_Account__C ipsAct:ipsProjAcctList){
                ipsAct.core_ips_project__c=projList[0].id;
            }
            insert ipsProjAcctList;
            List<Case> ListOfCases = TestUtilities.getListOfCases(1);
            Integer i=0;
            for(Case CaseRec : ListOfCases){
                if(i<1)
                    CaseRec.Core_IPS_Project_Case__c= projList[0].id;
                i++;
                
            }
            insert ListOfCases;
            Test.startTest();
            Map<Id, List<ID>> casesByProject = Core_IPS_Helper_Utility.listCasesByProject(ListOfCases);
            Set<Id> projIdSet = casesByProject.keySet();
            System.assertEquals(1,casesByProject.get(projList[0].id).size());
            Test.stopTest();
        }
    }

    /***************************************************************************************************
    Method Name:  getNonProjectCasesByAccount_PositiveTest
    Method Type: Test Method
    Version     : 1.0 
    Created Date: 24 Jan 2016
    Description:  This method checks if non project cases are returned from given account Ids. 
    Scenario Type:  Positive
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Jayaprakash T             01/24/2016                Created
    ****************************************************************************************************/    
    static testMethod void getNonProjectCasesByAccount_PositiveTest(){
        getRecords();
        System.runAs(listofuser[0]){
            List<Core_IPS_Project__c> projList = TestUtilities.getListOfIpsProjects(1);
            insert projList;
            List<Core_IPS_Account__C> ipsProjAcctList = TestUtilities.getListOfIpsAccounts(1);
            List<Account> acctList = TestUtilities.getListOfAccounts(1);
            insert acctList;
            List<Id> acctIdList = new List<Id>();
            for(Account acc:acctList){
                acctIdList.add(acc.id);
            }
            for(Core_IPS_Account__C ipsAct:ipsProjAcctList){
                ipsAct.core_ips_project__c=projList[0].id;
            }
            insert ipsProjAcctList;
            List<Case> ListOfCases = TestUtilities.getListOfCases(2);
            Integer i=0;
            for(Case CaseRec : ListOfCases){
                if(i<1)
                    CaseRec.Core_IPS_Project_Case__c= projList[0].id;
                else
                    CaseRec.accountId=acctList[0].id;
                i++;
                
            }
            insert ListOfCases;
            Test.startTest();
            Map<Id, List<ID>> casesByProject = Core_IPS_Helper_Utility.listCasesByProject(ListOfCases);
            List<Case> returnedCaseList = Core_IPS_Helper_Utility.getNonProjectCasesByAccount(acctIdList);
            Set<Id> projIdSet = casesByProject.keySet();
            System.assertEquals(1,casesByProject.get(projList[0].id).size());
            System.assertEquals(1,returnedCaseList.size());
            System.assertEquals(null,Core_IPS_Helper_Utility.getNonProjectCasesByAccount(null));
            Test.stopTest();
        }
    }
    
    /***************************************************************************************************
    Method Name:  shareCaseMapFromAccount_PositiveTest
    Method Type: Test Method
    Version     : 1.0 
    Created Date: 02 Feb 2016
    Description:  Testing "shareCaseMapFromAccount(Map<Id,Id> userIdaccIdMap)" utility  method
    Scenario Type:  Positive
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Deepak Jetty              02/03/2016                Created
    ****************************************************************************************************/
    static testMethod void shareCaseMapFromAccount_PositiveTest(){
        getRecords();
        // Get intelSupportOwner Id (User Id)
        Id intelSupportOwner = ListOfUser.get(0).id;
        // Create Account
        List<Account> ListOfAccounts = TestUtilities.getListOfAccounts(1);
        System.runAs(ListOfUser[0]){
            insert ListOfAccounts;
        }
        System.assert(ListOfAccounts[0].Id != null, 'Record not created');
        // Create Case
        List<Case> ListOfCases = TestUtilities.getListOfCases(1);
        for(Case CaseRec : ListOfCases){
            CaseRec.accountId = ListOfAccounts.get(0).Id;
        }
        Test.startTest();
        System.runAs(ListOfUser[0]){
            insert ListOfCases;
            
            Map<Id,Id> userIdaccIdMap = new Map<Id,Id>();
            for(Account acc: ListOfAccounts){
                for(User Ur:ListOfUser){
                    userIdaccIdMap.put(Ur.id, acc.id);
                }
            }
            System.assert(ListOfCases[0].Id != null, 'Record not created');
            Map<Id,Set<Id>> caseShareMap = Core_IPS_Helper_Utility.shareCaseMapFromAccount(userIdaccIdMap);
            System.assert(!caseShareMap.isEmpty(),'caseShareMap not returning values');
        }
        Test.stopTest();
        
    }
    /***************************************************************************************************
    Method Name:  shareCaseMapFromAccount_NegativeTest
    Method Type: Test Method
    Version     : 1.0 
    Created Date: 02 Feb 2016
    Description:  Testing "shareCaseMapFromAccount(Map<Id,Id> userIdaccIdMap)" utility  method
    Scenario Type:  Negative
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Deepak Jetty              02/03/2016                Created
    ****************************************************************************************************/
    static testMethod void shareCaseMapFromAccount_NegativeTest(){
        getRecords();
        //Calling shareCaseMapFromAccount
        Test.startTest();
        System.runAs(ListOfUser[0]){
            Map<Id,Id> userIdaccIdMap = new Map<Id,Id>();
            Map<Id,Set<Id>> caseShareMap = Core_IPS_Helper_Utility.shareCaseMapFromAccount(userIdaccIdMap);
            System.assert(caseShareMap.isEmpty(),'caseShareMap returning values');
        }
        Test.stopTest();
        
    }
    /***************************************************************************************************
    Method Name:  shareCaseMapFromProject_PositiveTest
    Method Type: Test Method
    Version     : 1.0 
    Created Date: 02 Feb 2016
    Description:  Testing "shareCaseMapFromProject(Map<Id,Id> userIdAccountIdMap)" utility  method
    Scenario Type:  Positive
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Deepak Jetty              02/03/2016                Modified
    ****************************************************************************************************/
    static testMethod void shareCaseMapFromProject_PositiveTest(){
        getRecords();
        // Get intelSupportOwner Id (User Id)
        Id intelSupportOwner = ListOfUser.get(0).id;
        // Create Ips Project1
        List<Core_IPS_Project__c> ListOfIpsProjects = TestUtilities.getListOfIpsProjects(1);
        System.runAs(ListOfUser[0]){ 
            insert ListOfIpsProjects;
        }
        System.assert(ListOfIpsProjects[0].Id != null, 'Record not created');
        // Create Project Members
        List<Core_IPS_Project_Member__c> ListOfProjectMembers = TestUtilities.getListOfProjectMembers(200);
        for(Core_IPS_Project_Member__c ProjMem : ListOfProjectMembers){
            ProjMem.Core_IPS_Project__c = ListOfIpsProjects.get(0).Id;
            ProjMem.Core_User__c = intelSupportOwner;            
        }
        System.runAs(ListOfUser.get(0)){
            insert ListOfProjectMembers;
        }
        System.assert(ListOfProjectMembers[0].Id != null, 'Record not created');
        // Create Case
        List<Case> ListOfCases = TestUtilities.getListOfCases(1);
        for(Case CaseRec : ListOfCases){
            CaseRec.Core_IPS_Project_Case__c = ListOfIpsProjects.get(0).Id;
        }
        System.runAs(ListOfUser.get(0)){
            insert ListOfCases;
        }
        System.assert(ListOfCases[0].Id != null, 'Record not created');
        Test.startTest();
        System.runAs(ListOfUser[0]){ 
            System.assert(ListOfIpsProjects[0].Id != null, 'Record not created');
            Map<Id,Id> userIdAccountIdMap = new Map<Id,Id>();
            for(Core_IPS_Project__c IPSProj: ListOfIpsProjects){
                for(User Ur:ListOfUser){
                    userIdAccountIdMap.put(Ur.id, IPSProj.id);
                }
            }   
            Map<Id,Set<Id>> caseShareMap = Core_IPS_Helper_Utility.shareCaseMapFromProject(userIdAccountIdMap);
            System.assert(!caseShareMap.isEmpty(),'caseShareMap not returning values');
        }
        Test.stopTest();
        
    }
    /***************************************************************************************************
    Method Name:  shareCaseMapFromProject_NegativeTest
    Method Type: Test Method
    Version     : 1.0 
    Created Date: 02 Feb 2016
    Description:  Testing "shareCaseMapFromProject(Map<Id,Id> userIdAccountIdMap)" utility  method
    Scenario Type:  Negative
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Deepak Jetty              02/03/2016                Created
    ****************************************************************************************************/
    static testMethod void shareCaseMapFromProject_NegativeTest(){
        getRecords();
        //Calling shareCaseMapFromAccount
        Test.startTest();
        System.runAs(ListOfUser[0]){
            Map<Id,Id> userIdaccIdMap = new Map<Id,Id>();
            Map<Id,Set<Id>> caseShareMap = Core_IPS_Helper_Utility.shareCaseMapFromAccount(userIdaccIdMap);
            System.assert(caseShareMap.isEmpty(),'caseShareMap returning values');
        }
        Test.stopTest();
        
    }
    /***************************************************************************************************
    Method Name:  getShareAssetMapByUser_PositiveTest
    Method Type: Test Method
    Version     : 1.0 
    Created Date: 02 Feb 2016
    Description:  Testing "getShareAssetMapByUser(Set<Id> userIdSet)" utility  method
    Scenario Type:  Positive
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Deepak Jetty              02/03/2016                Modified
    ****************************************************************************************************/
    static testMethod void getShareAssetMapByUser_PositiveTest(){
        getRecords();
        // Query Profiles
        Map<String,ID> profiles = new Map<String,ID>();
        List<Profile> ProfileList = [select id, name from Profile where name = 'System Administrator'];
        for(Profile prf : ProfileList){
            profiles.put(prf.name, prf.id);
        }
        //Create Role
        UserRole role = new UserRole();
        role.name='CEO';
        insert role;
        // Create Users
        List<User> ListOfUserAsset = new List<User> ();
        ListOfUserAsset = TestUtilities.getListOfUser(1);
        for(User Usr : ListOfUserAsset){
            Usr.ProfileID =  profiles.get('System Administrator');
            Usr.UserRoleID = role.id;
            Usr.UserName = 'AccountTestnewuser@intel.com';
        }
        insert ListOfUserAsset;
        System.assertEquals(ListOfUserAsset.get(0).profileid, profiles.get('System Administrator'));
        // Get intelSupportOwner Id (User Id)
        Id intelSupportOwner = ListOfUser.get(0).id;
        // Create Asset
        list<Asset> AssetList = TestUtilities.getAssetList(200);
        System.runAs(ListOfUser.get(0)){
            insert AssetList;
        }
        System.assert(AssetList[0].Id != null, 'Record not created');
        Test.startTest();
        System.runAs(ListOfUser[0]){ 
            for(Asset asst:AssetList){
                asst.OwnerId=ListOfUserAsset[0].id;
            }
            update AssetList;
            Set<Id> userIdSet = new Set<Id>();
            for(Asset asst: AssetList){
                userIdSet.add(asst.OwnerID);
            }
            Map<Id,Set<Id>> assetShareMap = Core_IPS_Helper_Utility.getShareAssetMapByUser(userIdSet);
            System.assert(!userIdSet.isEmpty(),'userIdSet not returning values');
        }
        Test.stopTest();
        
    }
    /***************************************************************************************************
    Method Name:  getShareAssetMapByUser_NegativeTest
    Method Type: Test Method
    Version     : 1.0 
    Created Date: 02 Feb 2016
    Description:  Testing "getShareAssetMapByUser(Set<Id> userIdSet)" utility  method
    Scenario Type:  Negative
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Deepak Jetty              02/03/2016                Created
    ****************************************************************************************************/
    static testMethod void getShareAssetMapByUser_NegativeTest(){
        getRecords();
        //Calling shareCaseMapFromAccount
        Test.startTest();
        System.runAs(ListOfUser[0]){
            Set<Id> userIdSet = new Set<Id>();
            Map<Id,Set<Id>> assetShareMap = Core_IPS_Helper_Utility.getShareAssetMapByUser(userIdSet);
            System.assert(assetShareMap.isEmpty(),'assetShareMap returning values');
        }
        Test.stopTest();
        
    }
    /***************************************************************************************************
    Method Name:  getShareCaseMapByUser_PositiveTest
    Method Type: Test Method
    Version     : 1.0 
    Created Date: 02 Feb 2016
    Description:  Testing "getShareCaseMapByUser(Set<Id> userIdSet)" utility  method
    Scenario Type:  Positive
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Deepak Jetty              02/03/2016                Modified
    ****************************************************************************************************/
    static testMethod void getShareCaseMapByUser_PositiveTest(){
        getRecords();
        // Query Profiles
        Map<String,ID> profiles = new Map<String,ID>();
        List<Profile> ProfileList = [select id, name from Profile where name = 'System Administrator'];
        for(Profile prf : ProfileList){
            profiles.put(prf.name, prf.id);
        }
        //Create Role
        UserRole role = new UserRole();
        role.name='CEO';
        insert role;
        // Create Users
        List<User> ListOfUserCase = new List<User> ();
        ListOfUserCase = TestUtilities.getListOfUser(200);
        Integer Counter = 0;
        for(User Usr : ListOfUserCase){
            Usr.ProfileID =  profiles.get('System Administrator');
            Usr.UserRoleID = role.id;
            Usr.UserName = Counter+'CaseTestnewuser@intel.com';
            Counter++;
        }
        Counter = 0;
        insert ListOfUserCase;
        System.assertEquals(ListOfUserCase.get(0).profileid, profiles.get('System Administrator'));
        // Get intelSupportOwner Id (User Id)
        Id intelSupportOwner = ListOfUser.get(0).id;
        //Create IPS Labels
        List<Core_IPS_Labels__c> IPSLables = TestUtilities.getIPSLabel();
        System.runAs(ListOfUser[0]){ 
            insert IPSLables;
        }
        List<Case> ListOfCases = TestUtilities.getListOfCases(1);
        System.runAs(ListOfUser.get(0)){
            insert ListOfCases;
        }
        System.debug('List of Cases ===== '+ListOfCases);
        System.assert(ListOfCases[0].Id != null, 'Record not created');
        Test.startTest();
        System.runAs(ListOfUser[0]){
            List<CaseShare> csList = new List<CaseShare>();
            for(Case csObj:ListOfCases){
                CaseShare cs = new CaseShare();
                cs.CaseId=csObj.Id;
                cs.CaseAccessLevel = 'Edit';
                cs.UserOrGroupId = ListOfUserCase[0].id;
                cs.RowCause = 'Manual';
                csList.add(cs);
                Counter++;
            }
            Counter = 0;
            insert csList;
            Set<Id> userIdSet = new Set<Id>();
            userIdSet.add(ListOfUserCase[0].id);
            system.debug('**************************'+userIdSet);
            System.debug('Case Share Query======    '+[Select Id,CaseId,UserOrGroupId,Rowcause from CaseShare where CaseId IN: ListOfCases]);
            Map<Id,Set<Id>> caseShareMap = Core_IPS_Helper_Utility.getShareCaseMapByUser(userIdSet);
            System.assert(!caseShareMap.isEmpty(),'caseShareMap not returning values');
        }
        Test.stopTest();
        
    }
    /***************************************************************************************************
    Method Name:  getShareCaseMapByUser_NegativeTest
    Method Type: Test Method
    Version     : 1.0 
    Created Date: 02 Feb 2016
    Description:  Testing "getShareCaseMapByUser(Set<Id> userIdSet)" utility  method
    Scenario Type:  Negative
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Deepak Jetty              02/03/2016                Created
    ****************************************************************************************************/
    static testMethod void getShareCaseMapByUser_NegativeTest(){
        getRecords();
        //Calling shareCaseMapFromAccount
        Test.startTest();
        System.runAs(ListOfUser[0]){
            Set<Id> userIdSet = new Set<Id>();
            Map<Id,Set<Id>> caseShareMap = Core_IPS_Helper_Utility.getShareCaseMapByUser(userIdSet);
            System.assert(caseShareMap.isEmpty(),'assetShareMap returning values');
        }
        Test.stopTest();
        
    }
    /***************************************************************************************************
    Method Name:  shareAssetMapByProjectMember_PositiveTest
    Method Type: Test Method
    Version     : 1.0 
    Created Date: 02 Feb 2016
    Description:  Testing "shareAssetMapByProjectMember(Map<Id,Id> userIdAccountIdMap)" utility  method
    Scenario Type:  Positive
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Deepak Jetty              02/03/2016                Modified
    ****************************************************************************************************/
    static testMethod void shareAssetMapByProjectMember_PositiveTest(){
        getRecords();
        // Get intelSupportOwner Id (User Id)
        Id intelSupportOwner = ListOfUser.get(0).id;
        // Query Profiles
        Map<String,ID> profiles = new Map<String,ID>();
        List<Profile> ProfileList = [select id, name from Profile where name = 'System Administrator'];
        for(Profile prf : ProfileList){
            profiles.put(prf.name, prf.id);
        }
        //Create Role
        UserRole role = new UserRole();
        role.name='CEO';
        insert role;
        // Create Users
        Integer Counter=0;
        List<user> ListOfUserAsset = TestUtilities.getListOfUser(200);
        for(User Usr : ListOfUserAsset){
            Usr.ProfileID =  profiles.get('System Administrator');
            Usr.UserRoleID = role.id;
            Usr.UserName = Counter+'Assetuser@intel.com';
            Counter ++;
        }
        insert ListOfUserAsset;
        Counter = 0;
        System.assertEquals(ListOfUser.get(0).profileid, profiles.get('System Administrator'));
        // Create Ips Project
        List<Core_IPS_Project__c> ListOfIpsProjects = TestUtilities.getListOfIpsProjects(1);
        System.runAs(ListOfUser[0]){ 
            insert ListOfIpsProjects;
        }
        System.assert(ListOfIpsProjects[0].Id != null, 'Record not created');
        // Create Project Members
        List<Core_IPS_Project_Member__c> ListOfProjectMembers = TestUtilities.getListOfProjectMembers(200);
        for(Core_IPS_Project_Member__c ProjMem : ListOfProjectMembers){
            ProjMem.Core_IPS_Project__c = ListOfIpsProjects.get(0).Id;
            ProjMem.Core_User__c = ListOfUserAsset[Counter].id;
            Counter++;
        }
        Counter = 0;
        System.runAs(ListOfUser.get(0)){
            insert ListOfProjectMembers;
        }
        System.assert(ListOfProjectMembers[0].Id != null, 'Record not created');
        // Create Asset
        list<Asset> AssetList = TestUtilities.getAssetList(200);
        for(Asset Asst : AssetList){
            Asst.Core_IPS_Project__c = ListOfIpsProjects[0].id;
        }
        Counter = 0;
        System.runAs(ListOfUser[0]){ 
            insert AssetList;
        }
        System.assert(AssetList[0].Id != null, 'Record not created');
        Test.startTest();
        System.runAs(ListOfUser[0]){ 
            Map<Id,Id> userIdAccountIdMap = new Map<Id,Id>();
            for(User Ur:ListOfUserAsset){
                userIdAccountIdMap.put(Ur.id, ListOfIpsProjects[0].id);
            }
            Map<Id,Set<Id>> assetShareMap = Core_IPS_Helper_Utility.shareAssetMapByProjectMember(userIdAccountIdMap);
            System.assert(!assetShareMap.isEmpty(),'assetShareMap not returning values');
        }
        Test.stopTest();
        
    }
    /***************************************************************************************************
    Method Name:  shareAssetMapByProjectMember_NegativeTest
    Method Type: Test Method
    Version     : 1.0 
    Created Date: 02 Feb 2016
    Description:  Testing "shareAssetMapByProjectMember(Map<Id,Id> userIdAccountIdMap)" utility  method
    Scenario Type:  Negative
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Deepak Jetty              02/03/2016                Created
    ****************************************************************************************************/
    static testMethod void shareAssetMapByProjectMember_NegativeTest(){
        getRecords();
        //Calling shareCaseMapFromAccount
        Test.startTest();
        System.runAs(ListOfUser[0]){
            Map<Id,Id> userIdAccountIdMap = new Map<Id,Id>();
            Map<Id,Set<Id>> assetShareMap = Core_IPS_Helper_Utility.shareAssetMapByProjectMember(userIdAccountIdMap);
            System.assert(assetShareMap.isEmpty(),'assetShareMap returning values');
        }
        Test.stopTest();
        
    }
    /***************************************************************************************************
    Method Name:  shareAssetMapByAccount_PositiveTest
    Method Type: Test Method
    Version     : 1.0 
    Created Date: 02 Feb 2016
    Description:  Testing "shareAssetMapByAccount(Map<Id,Id> userIdAccountIdMap)" utility  method
    Scenario Type:  Positive
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Deepak Jetty              02/03/2016                Created
    ****************************************************************************************************/
    static testMethod void shareAssetMapByAccount_PositiveTest(){
        getRecords();
        // Get intelSupportOwner Id (User Id)
        Id intelSupportOwner = ListOfUser.get(0).id;
        // Query Profiles
        Map<String,ID> profiles = new Map<String,ID>();
        List<Profile> ProfileList = [select id, name from Profile where name = 'System Administrator'];
        for(Profile prf : ProfileList){
            profiles.put(prf.name, prf.id);
        }
        //Create Role
        UserRole role = new UserRole();
        role.name='CEO';
        insert role;
        // Create Users
        Integer Counter=0;
        List<user> ListOfUserAsset = TestUtilities.getListOfUser(200);
        for(User Usr : ListOfUserAsset){
            Usr.ProfileID =  profiles.get('System Administrator');
            Usr.UserRoleID = role.id;
            Usr.UserName = Counter+'Assetuser@intel.com';
            Counter ++;
        }
        insert ListOfUserAsset;
        Counter = 0;
        System.assertEquals(ListOfUser.get(0).profileid, profiles.get('System Administrator'));
        // Create Accounts
        List<Account> ListOfAccounts = TestUtilities.getListOfAccounts(200);
        System.runAs(ListOfUser[0]){ 
            insert ListOfAccounts;
        }
        // Create Asset
        list<Asset> AssetList = TestUtilities.getAssetList(200);
        for(Asset Asst : AssetList){
            Asst.AccountId = ListOfAccounts[Counter].id;
            Counter++;
        }
        Counter = 0;
        System.runAs(ListOfUser[0]){ 
            insert AssetList;
        }
        System.assert(AssetList[0].Id != null, 'Record not created');
        Test.startTest();
        System.runAs(ListOfUser[0]){ 
            Map<Id,Id> userIdAccountIdMap = new Map<Id,Id>();
            for(Asset asst: AssetList){
                userIdAccountIdMap.put(ListOfUserAsset[Counter].id, asst.AccountId);
                Counter++;
            }
            Counter = 0;
            Map<Id,Set<Id>> assetShareMap = Core_IPS_Helper_Utility.shareAssetMapByAccount(userIdAccountIdMap);
            System.assert(!assetShareMap.isEmpty(),'assetShareMap not returning values');
        }
        Test.stopTest();
        
    }
    /***************************************************************************************************
    Method Name:  shareAssetMapByAccount_NegativeTest
    Method Type: Test Method
    Version     : 1.0 
    Created Date: 02 Feb 2016
    Description:  Testing "shareAssetMapByAccount(Map<Id,Id> userIdAccountIdMap)" utility  method
    Scenario Type:  Negative
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Deepak Jetty              02/03/2016                Created
    ****************************************************************************************************/
    static testMethod void shareAssetMapByAccount_NegativeTest(){
        getRecords();
        //Calling shareCaseMapFromAccount
        Test.startTest();
        System.runAs(ListOfUser[0]){
            Map<Id,Id> userIdAccountIdMap = new Map<Id,Id>();
            Map<Id,Set<Id>> assetShareMap = Core_IPS_Helper_Utility.shareAssetMapByAccount(userIdAccountIdMap);
            System.assert(assetShareMap.isEmpty(),'assetShareMap returning values');
        }
        Test.stopTest();
        
    }
    /***************************************************************************************************
    Method Name:  deleteProjectMembers_PositiveTest
    Method Type: Test Method
    Version     : 1.0 
    Created Date: 02 Feb 2016
    Description:  Testing "deleteProjectMembers(Map<Id,Id> userIdAccountIdMap)" utility  method
    Scenario Type:  Positive
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Deepak Jetty              02/03/2016                Modified
    ****************************************************************************************************/
    static testMethod void deleteProjectMembers_PositiveTest(){
        getRecords();
        // Get intelSupportOwner Id (User Id)
        Id intelSupportOwner = ListOfUser.get(0).id;
        // Create Accounts
        List<Account> ListOfAccounts = TestUtilities.getListOfAccounts(1);
        System.runAs(ListOfUser[0]){
            insert ListOfAccounts;
        }
        System.assert(ListOfAccounts[0].Id != null, 'Record not created');
        integer Counter = 0;
        // Create Contact
        List<Contact> ListOfContacts = TestUtilities.getListOfContact(200);
        for(Contact ContactRec : ListOfContacts){
            ContactRec.Core_IPS_Intel_Support_Owner__c = intelSupportOwner;
            ContactRec.Accountid = ListOfAccounts[0].Id;
        }
        System.runAs(ListOfUser[0]){
            insert ListOfContacts;
        }
        // Profile Query
        Profile CustomerProfile = [select Id,name from Profile where UserType = 'PowerCustomerSuccess' limit 1];
        // Creating Customer User
        List<User> ListOfCustomerUser = TestUtilities.getListOfUser(200);
        String searchStr = listofAccounts[0].name+'%';
        //UserRole role = [select id from userrole where portaltype='CustomerPortal' limit 1];
        for(User Usr : ListOfCustomerUser){
            Usr.ProfileID = CustomerProfile.id;
            if(Counter<200){
            Usr.UserName = Counter+'getFAEsByProject@intel.com';
                Usr.contactId = ListOfContacts[Counter].id;            
            }
            Counter++;
        }
        Counter = 0;
        insert ListOfCustomerUser;
        System.assertEquals(ListOfCustomerUser[0].ProfileID, CustomerProfile.id);
        // Create Ips Project
        List<Core_IPS_Project__c> ListOfIpsProjects = TestUtilities.getListOfIpsProjects(1);
        System.runAs(ListOfUser[0]){ 
            insert ListOfIpsProjects;
        }
        System.assert(ListOfIpsProjects[0].Id != null, 'Record not created');
        // Create Project Members
        List<Core_IPS_Project_Member__c> ListOfProjectMembers = TestUtilities.getListOfProjectMembers(200);
        for(Core_IPS_Project_Member__c ProjMem : ListOfProjectMembers){
            ProjMem.Core_IPS_Project__c = ListOfIpsProjects.get(0).Id;
            ProjMem.Core_User__c = ListOfCustomerUser[Counter].id;            
            Counter++;
        }
        Counter=0;
        System.runAs(ListOfUser.get(0)){
            insert ListOfProjectMembers;
        }
        System.assert(ListOfProjectMembers[0].Id != null, 'Record not created');
        Test.startTest();
        System.runAs(ListOfUser[0]){ 
            Map<Id,Id> userIdAccountIdMap = new Map<Id,Id>();
            for(Core_IPS_Project__c IPSProj: ListOfIpsProjects){
                for(User Ur:ListOfCustomerUser){
                    userIdAccountIdMap.put(Ur.id, IPSProj.id);
                }
            }
            Core_IPS_Helper_Utility.deleteProjectMembers(userIdAccountIdMap);
            List<Core_IPS_Project_Member__c> delProj = [select id,Core_IPS_Project__c,Core_User__c,Core_Status__c from Core_IPS_Project_Member__c where Core_User__c in:ListOfUser];
            System.assert(delProj.isEmpty(),'Project members not deleted');
        }
        Test.stopTest();
        
    }
    /***************************************************************************************************
    Method Name:  deleteProjectMembers_NegativeTest
    Method Type: Test Method
    Version     : 1.0 
    Created Date: 02 Feb 2016
    Description:  Testing "deleteProjectMembers(Map<Id,Id> userIdAccountIdMap)" utility  method
    Scenario Type:  Negative
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Deepak Jetty              02/03/2016                Created
    ****************************************************************************************************/
    static testMethod void deleteProjectMembers_NegativeTest(){
        getRecords();
        // Get intelSupportOwner Id (User Id)
        Id intelSupportOwner = ListOfUser.get(0).id;
        // Create Ips Project
        List<Core_IPS_Project__c> ListOfIpsProjects = TestUtilities.getListOfIpsProjects(1);
        System.runAs(ListOfUser[0]){ 
            insert ListOfIpsProjects;
        }
        System.assert(ListOfIpsProjects[0].Id != null, 'Record not created');
        // Create Project Members
        List<Core_IPS_Project_Member__c> ListOfProjectMembers = TestUtilities.getListOfProjectMembers(5);
        for(Core_IPS_Project_Member__c ProjMem : ListOfProjectMembers){
            ProjMem.Core_IPS_Project__c = ListOfIpsProjects.get(0).Id;
            ProjMem.Core_User__c = intelSupportOwner;            
        }
        System.runAs(ListOfUser.get(0)){
            insert ListOfProjectMembers;
        }
        System.assert(ListOfProjectMembers[0].Id != null, 'Record not created');
        Test.startTest();
        System.runAs(ListOfUser[0]){
            Map<Id,Id> userIdAccountIdMap = new Map<Id,Id>();
            Core_IPS_Helper_Utility.deleteProjectMembers(userIdAccountIdMap);
            List<Core_IPS_Project_Member__c> delProj = [select id,Core_IPS_Project__c,Core_User__c,Core_Status__c from Core_IPS_Project_Member__c where Core_User__c in:ListOfUser];
            System.assert(!delProj.isEmpty(),'Project members deleted');
        }
        Test.stopTest();
        
    }
    /***************************************************************************************************
    Method Name:  deactivateProjectMembers_PositiveTest
    Method Type: Test Method
    Version     : 1.0 
    Created Date: 02 Feb 2016
    Description:  Testing "deactivateProjectMembers(Map<Id,Id> userIdAccountIdMap)" utility  method
    Scenario Type:  Positive
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Deepak Jetty              02/03/2016                Modified
    ****************************************************************************************************/
    static testMethod void deactivateProjectMembers_PositiveTest(){
        getRecords();
        // Get intelSupportOwner Id (User Id)
        Id intelSupportOwner = ListOfUser.get(0).id;
        // Create Accounts
        List<Account> ListOfAccounts = TestUtilities.getListOfAccounts(1);
        System.runAs(ListOfUser[0]){
            insert ListOfAccounts;
        }
        System.assert(ListOfAccounts[0].Id != null, 'Record not created');
        integer Counter = 0;
        // Create Contact
        List<Contact> ListOfContacts = TestUtilities.getListOfContact(200);
        for(Contact ContactRec : ListOfContacts){
            ContactRec.Core_IPS_Intel_Support_Owner__c = intelSupportOwner;
            ContactRec.Accountid = ListOfAccounts[0].Id;
        }
        System.runAs(ListOfUser[0]){
            insert ListOfContacts;
        }
        // Profile Query
        Profile CustomerProfile = [select Id,name from Profile where UserType = 'PowerCustomerSuccess' limit 1];
        // Creating Customer User
        List<User> ListOfCustomerUser = TestUtilities.getListOfUser(200);
        String searchStr = listofAccounts[0].name+'%';
        //UserRole role = [select id from userrole where portaltype='CustomerPortal' limit 1];
        for(User Usr : ListOfCustomerUser){
            Usr.ProfileID = CustomerProfile.id;
            if(Counter<200){
            Usr.UserName = Counter+'getFAEsByProject@intel.com';
                Usr.contactId = ListOfContacts[Counter].id;            
            }
            Counter++;
        }
        Counter = 0;
        insert ListOfCustomerUser;
        System.assertEquals(ListOfCustomerUser[0].ProfileID, CustomerProfile.id);
        // Create Ips Project
        List<Core_IPS_Project__c> ListOfIpsProjects = TestUtilities.getListOfIpsProjects(1);
        System.runAs(ListOfUser[0]){ 
            insert ListOfIpsProjects;
        }
        System.assert(ListOfIpsProjects[0].Id != null, 'Record not created');
        // Create Project Members
        List<Core_IPS_Project_Member__c> ListOfProjectMembers = TestUtilities.getListOfProjectMembers(200);
        for(Core_IPS_Project_Member__c ProjMem : ListOfProjectMembers){
            ProjMem.Core_IPS_Project__c = ListOfIpsProjects.get(0).Id;
            ProjMem.Core_User__c = ListOfCustomerUser[Counter].id;            
            Counter++;
        }
        Counter=0;
        System.runAs(ListOfUser.get(0)){
            insert ListOfProjectMembers;
        }
        System.assert(ListOfProjectMembers[0].Id != null, 'Record not created');
        Test.startTest();
        System.runAs(ListOfUser[0]){ 
            Map<Id,Id> userIdAccountIdMap = new Map<Id,Id>();
            for(Core_IPS_Project__c IPSProj: ListOfIpsProjects){
                for(User Ur:ListOfCustomerUser){
                    userIdAccountIdMap.put(Ur.id, IPSProj.id);
                }
            }
            Core_IPS_Helper_Utility.deactivateProjectMembers(userIdAccountIdMap);
            List<Core_IPS_Project_Member__c> delProj = [select id,Core_IPS_Project__c,Core_User__c,Core_Status__c from Core_IPS_Project_Member__c where Core_User__c in:ListOfCustomerUser];
            System.assert(delProj.get(0).Core_Status__c == 'Inactive','Project members are not deactivated');
        }
        Test.stopTest();
        
    }
    /***************************************************************************************************
    Method Name:  deactivateProjectMembers_NegativeTest
    Method Type: Test Method
    Version     : 1.0 
    Created Date: 02 Feb 2016
    Description:  Testing "deactivateProjectMembers(Map<Id,Id> userIdAccountIdMap)" utility  method
    Scenario Type:  Negative
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Deepak Jetty              02/03/2016                Created
    ****************************************************************************************************/
    static testMethod void deactivateProjectMembers_NegativeTest(){
        getRecords();
        // Get intelSupportOwner Id (User Id)
        Id intelSupportOwner = ListOfUser.get(0).id;
        // Create Ips Project
        List<Core_IPS_Project__c> ListOfIpsProjects = TestUtilities.getListOfIpsProjects(1);
        System.runAs(ListOfUser[0]){ 
            insert ListOfIpsProjects;
        }
        System.assert(ListOfIpsProjects[0].Id != null, 'Record not created');
        // Create Project Members
        List<Core_IPS_Project_Member__c> ListOfProjectMembers = TestUtilities.getListOfProjectMembers(5);
        for(Core_IPS_Project_Member__c ProjMem : ListOfProjectMembers){
            ProjMem.Core_IPS_Project__c = ListOfIpsProjects.get(0).Id;
            ProjMem.Core_User__c = intelSupportOwner;            
        }
        System.runAs(ListOfUser.get(0)){
            insert ListOfProjectMembers;
        }
        System.assert(ListOfProjectMembers[0].Id != null, 'Record not created');
        Test.startTest();
        System.runAs(ListOfUser[0]){
            Map<Id,Id> userIdAccountIdMap = new Map<Id,Id>();
            Core_IPS_Helper_Utility.deleteProjectMembers(userIdAccountIdMap);
            List<Core_IPS_Project_Member__c> delProj = [select id,Core_IPS_Project__c,Core_User__c,Core_Status__c from Core_IPS_Project_Member__c where Core_User__c in:ListOfUser];
            System.assert(delProj.get(0).Core_Status__c != 'Inactive','Project members are deactivated');
        }
        Test.stopTest();
        
    }
    /***************************************************************************************************
    Method Name:  createProjectMembers_PositiveTest
    Method Type: Test Method
    Version     : 1.0 
    Created Date: 02 Feb 2016
    Description:  Testing "createProjectMembers(Map<Id,Id> userIdAccountIdMap)" utility  method
    Scenario Type:  Positive
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Deepak Jetty              02/03/2016                Modified
    ****************************************************************************************************/
    static testMethod void createProjectMembers_PositiveTest(){
        getRecords();
        // Get intelSupportOwner Id (User Id)
        Id intelSupportOwner = ListOfUser.get(0).id;
        // Create Accounts
        List<Account> ListOfAccounts = TestUtilities.getListOfAccounts(1);
        System.runAs(ListOfUser[0]){
            insert ListOfAccounts;
        }
        System.assert(ListOfAccounts[0].Id != null, 'Record not created');
        integer Counter = 0;
        // Create Contact
        List<Contact> ListOfContacts = TestUtilities.getListOfContact(1);
        for(Contact ContactRec : ListOfContacts){
            ContactRec.Core_IPS_Intel_Support_Owner__c = intelSupportOwner;
            ContactRec.Accountid = ListOfAccounts[0].Id;
        }
        Counter =0;
        System.runAs(ListOfUser[0]){
            insert ListOfContacts;
        }
        // Profile Query
        Profile CustomerProfile = [select Id,name from Profile where UserType = 'PowerCustomerSuccess' limit 1];
        // Creating Customer User
        List<User> ListOfCustomerUser = TestUtilities.getListOfUser(1);
        //UserRole role = [select id from userrole where portaltype='CustomerPortal' limit 1];
        for(User Usr : ListOfCustomerUser){
            Usr.ProfileID = CustomerProfile.id;
            if(Counter<200){
            Usr.UserName = Counter+'getFAEsByProject@intel.com';
                Usr.contactId = ListOfContacts[0].id;            
            }
            Counter++;
        }
        Counter = 0;
        insert ListOfCustomerUser;
        System.assertEquals(ListOfCustomerUser[0].ProfileID, CustomerProfile.id);
        // Create Ips Project
        List<Core_IPS_Project__c> ListOfIpsProjects = TestUtilities.getListOfIpsProjects(1);
        System.runAs(ListOfUser[0]){
            insert ListOfIpsProjects;
        }
        System.assert(ListOfIpsProjects[0].Id != null, 'Record not created');
        // Create Ips Account
        List<Core_IPS_Account__c> ListOfIpsAccounts = TestUtilities.getListOfIpsAccounts(200);
        for(Core_IPS_Account__c IpsAcc : ListOfIpsAccounts){
            IpsAcc.Core_Account__c = ListOfAccounts[0].Id;
            IpsAcc.Core_IPS_Project__c = ListOfIpsProjects[0].Id;
        }
        System.runAs(ListOfUser[0]){
            insert ListOfIpsAccounts;
        }
        System.assert(ListOfIpsAccounts[0].Id != null, 'Record not created');
        Test.startTest();
        System.runAs(ListOfUser[0]){ 
            Map<Id,Id> userIdAccountIdMap = new Map<Id,Id>();
            for(User ur: ListOfCustomerUser){
                userIdAccountIdMap.put(ur.id, ListOfAccounts[0].id);
            }
            Counter = 0;
            Core_IPS_Helper_Utility.createProjectMembers(userIdAccountIdMap);
            List<Core_IPS_Project_Member__c> ProjMem = [select id,Core_IPS_Project__c,Core_User__c,Core_Status__c from Core_IPS_Project_Member__c where Core_User__c in:ListOfCustomerUser];
            System.assert(ProjMem[0].Id != null,'Project members are not Created');
        }
        Test.stopTest();
        
    }
    /***************************************************************************************************
    Method Name:  createProjectMembers_NegativeTest
    Method Type: Test Method
    Version     : 1.0 
    Created Date: 02 Feb 2016
    Description:  Testing "createProjectMembers(Map<Id,Id> userIdAccountIdMap)" utility  method
    Scenario Type:  Negative
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Deepak Jetty              02/03/2016                Created
    ****************************************************************************************************/
    static testMethod void createProjectMembers_NegativeTest(){
        getRecords();
        // Get intelSupportOwner Id (User Id)
        Id intelSupportOwner = ListOfUser.get(0).id;
        // Create Accounts
        List<Account> ListOfAccounts = TestUtilities.getListOfAccounts(1);
        System.runAs(ListOfUser[0]){
            insert ListOfAccounts;
        }
        System.assert(ListOfAccounts[0].Id != null, 'Record not created');
        // Create Contact
        List<Contact> ListOfContacts = TestUtilities.getListOfContact(1);
        for(Contact ContactRec : ListOfContacts){
            ContactRec.Core_IPS_Intel_Support_Owner__c = intelSupportOwner;
            ContactRec.Accountid = ListOfAccounts.get(0).Id;
        }
        System.runAs(ListOfUser[0]){
            insert ListOfContacts;
        }
        // Create Ips Project
        List<Core_IPS_Project__c> ListOfIpsProjects = TestUtilities.getListOfIpsProjects(1);
        System.runAs(ListOfUser[0]){
            insert ListOfIpsProjects;
        }
        System.assert(ListOfIpsProjects[0].Id != null, 'Record not created');
        // Create Ips Account
        List<Core_IPS_Account__c> ListOfIpsAccounts = TestUtilities.getListOfIpsAccounts(1);
        for(Core_IPS_Account__c IpsAcc : ListOfIpsAccounts){
            IpsAcc.Core_Account__c = ListOfAccounts.get(0).Id;
            IpsAcc.Core_IPS_Project__c = ListOfIpsProjects.get(0).Id;
        }
        System.runAs(ListOfUser[0]){
            insert ListOfIpsAccounts;
        }
        System.assert(ListOfIpsAccounts[0].Id != null, 'Record not created');
        Test.startTest();
        System.runAs(ListOfUser[0]){ 
            Map<Id,Id> userIdAccountIdMap = new Map<Id,Id>();
            Core_IPS_Helper_Utility.createProjectMembers(userIdAccountIdMap);
            System.assert([select id,Core_IPS_Project__c,Core_User__c,Core_Status__c from Core_IPS_Project_Member__c where Core_User__c in:ListOfUser].size()==0,'Project members are Created');
        }
        Test.stopTest();
        
    }
    /***************************************************************************************************
    Method Name:  getFAEsFromUsers_PositiveTest
    Method Type: Test Method
    Version     : 1.0 
    Created Date: 02 Feb 2016
    Description:  Testing "getFAEsFromUsers(Set<Id> userIdSet)" utility  method
    Scenario Type:  Positive
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Deepak Jetty              02/03/2016                Modified
    ****************************************************************************************************/
    static testMethod void getFAEsFromUsers_PositiveTest(){
        getRecords();
        // Query Profiles
        Map<String,ID> profiles = new Map<String,ID>();
        List<Profile> ProfileList = [select id, name from Profile where name = 'Sales Rep-BB'];
        for(Profile prf : ProfileList){
            profiles.put(prf.name, prf.id);
        }
        //Create Role
        UserRole role = new UserRole();
        role.name='CEO';
        insert role;
        // Create Users
        List<User> ListOfUserFAEs = new List<User> ();
        integer Counter = 0;
        ListOfUserFAEs = TestUtilities.getListOfUser(200);
        for(User Usr : ListOfUserFAEs){
            Usr.ProfileID =  profiles.get('Sales Rep-BB');
            Usr.UserRoleID = role.id;
            Usr.UserName = Counter+'AccountTestnewuser@intel.com';
            Counter++;
        }
        Counter =0;
        insert ListOfUserFAEs;
        System.assertEquals(ListOfUserFAEs.get(0).profileid, profiles.get('Sales Rep-BB'));
        Test.startTest();
        System.runAs(ListOfUser[0]){ 
            Set<Id> userIdSet = new Set<Id>();
            for(User Ur:ListOfUserFAEs){
                userIdSet.add(Ur.id);
            }
            Set<Id> faeUserSet = Core_IPS_Helper_Utility.getFAEsFromUsers(userIdSet);
            System.assert(!faeUserSet.isEmpty(),'faeUserSet returned null');
        }
        Test.stopTest();
        
    }
    /***************************************************************************************************
    Method Name:  getFAEsFromUsers_NegativeTest
    Method Type: Test Method
    Version     : 1.0 
    Created Date: 02 Feb 2016
    Description:  Testing "getFAEsFromUsers(Set<Id> userIdSet)" utility  method
    Scenario Type:  Negative
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Deepak Jetty              02/03/2016                Created
    ****************************************************************************************************/
    static testMethod void getFAEsFromUsers_NegativeTest(){
        getRecords();
        // Query Profiles
        Map<String,ID> profiles = new Map<String,ID>();
        List<Profile> ProfileList = [select id, name from Profile where name = 'Sales Rep-BB'];
        for(Profile prf : ProfileList){
            profiles.put(prf.name, prf.id);
        }
        //Create Role
        UserRole role = new UserRole();
        role.name='CEO';
        insert role;
        // Create Users
        List<User> ListOfUserFAEs = new List<User> ();
        integer Counter = 0;
        ListOfUserFAEs = TestUtilities.getListOfUser(200);
        for(User Usr : ListOfUserFAEs){
            Usr.ProfileID =  profiles.get('Sales Rep-BB');
            Usr.UserRoleID = role.id;
            Usr.UserName = Counter+'AccountTestnewuser@intel.com';
            Counter++;
        }
        Counter =0;
        System.assertEquals(ListOfUserFAEs.get(0).profileid, profiles.get('Sales Rep-BB'));
        Test.startTest();
        System.runAs(ListOfUser[0]){ 
            Set<Id> userIdSet = new Set<Id>();
            for(User Ur:ListOfUserFAEs){
                userIdSet.add(Ur.id);
            }
            Set<Id> faeUserSet = Core_IPS_Helper_Utility.getFAEsFromUsers(userIdSet);
            System.assert(faeUserSet==null,'faeUserSet returned FAEs');
        }
        Test.stopTest();
        
    }
    /***************************************************************************************************
    Method Name:  getProjectsByAccountId_PositiveTest
    Method Type: Test Method
    Version     : 1.0 
    Created Date: 02 Feb 2016
    Description:  Testing "getProjectsByAccountId(Set<Id> acctIdSet)" utility  method
    Scenario Type:  Positive
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Deepak Jetty              02/03/2016                Modified
    ****************************************************************************************************/
    static testMethod void getProjectsByAccountId_PositiveTest(){
        getRecords();
        // Get intelSupportOwner Id (User Id)
        Id intelSupportOwner = ListOfUser.get(0).id;
        // Create Accounts
        List<Account> ListOfAccounts = TestUtilities.getListOfAccounts(200);
        System.runAs(ListOfUser[0]){
            insert ListOfAccounts;
        }
        System.assert(ListOfAccounts[0].Id != null, 'Record not created');
        // Create Ips Project
        List<Core_IPS_Project__c> ListOfIpsProjects = TestUtilities.getListOfIpsProjects(1);
        System.runAs(ListOfUser[0]){
            insert ListOfIpsProjects;
        }
        System.assert(ListOfIpsProjects[0].Id != null, 'Record not created');
        // Create Ips Account
        Integer Counter = 0;
        List<Core_IPS_Account__c> ListOfIpsAccounts = TestUtilities.getListOfIpsAccounts(200);
        for(Core_IPS_Account__c IpsAcc : ListOfIpsAccounts){
            IpsAcc.Core_Account__c = ListOfAccounts[Counter].Id;
            IpsAcc.Core_IPS_Project__c = ListOfIpsProjects.get(0).Id;
            Counter++;
        }
        Counter =0;
        System.runAs(ListOfUser[0]){
            insert ListOfIpsAccounts;
        }
        System.assert(ListOfIpsAccounts[0].Id != null, 'Record not created');
        Test.startTest();
        System.runAs(ListOfUser[0]){ 
            Set<Id> acctIdSet = new Set<Id>();
            for(Account acc: ListOfAccounts){
                acctIdSet.add(acc.id);
            }
            Map<Id,Set<id>> projectsByAccountId = Core_IPS_Helper_Utility.getProjectsByAccountId(acctIdSet);
            System.assert(!projectsByAccountId.isEmpty(),'Project by Accountid null');
        }
        Test.stopTest();
        
    }
    /***************************************************************************************************
    Method Name:  getProjectsByAccountId_NegativeTest
    Method Type: Test Method
    Version     : 1.0 
    Created Date: 02 Feb 2016
    Description:  Testing "getProjectsByAccountId(Set<Id> acctIdSet)" utility  method
    Scenario Type:  Negative
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Deepak Jetty              02/03/2016                Created
    ****************************************************************************************************/
    static testMethod void getProjectsByAccountId_NegativeTest(){
        getRecords();
        Test.startTest();
        System.runAs(ListOfUser[0]){ 
            //Set<Id> userIdSet = new Set<Id>();
            Set<Id> userIdSet;
            Map<Id,Set<id>> projectsByAccountId = Core_IPS_Helper_Utility.getProjectsByAccountId(userIdSet);
            System.assert(projectsByAccountId==null,'Project by Accountid not null');
        }
        Test.stopTest();
        
    }
    /***************************************************************************************************
    Method Name:  getAssetsByAccountId_PositiveTest
    Method Type: Test Method
    Version     : 1.0 
    Created Date: 02 Feb 2016
    Description:  Testing "getAssetsByAccountId(Set<Id> acctIdSet)" utility  method
    Scenario Type:  Positive
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Deepak Jetty              02/03/2016                Created
    ****************************************************************************************************/
    static testMethod void getAssetsByAccountId_PositiveTest(){
        getRecords();
        // Get intelSupportOwner Id (User Id)
        Id intelSupportOwner = ListOfUser.get(0).id;
        // Create Accounts
        List<Account> ListOfAccounts = TestUtilities.getListOfAccounts(200);
        System.runAs(ListOfUser[0]){ 
            insert ListOfAccounts;
        }
        // Create Asset
        Integer Counter = 0;
        list<Asset> AssetList = TestUtilities.getAssetList(200);
        for(Asset Asst : AssetList){
            Asst.AccountId = ListOfAccounts[Counter].id;
            Counter++;
        }
        Counter = 0;
        System.runAs(ListOfUser[0]){ 
            insert AssetList;
        }
        System.assert(AssetList[0].Id != null, 'Record not created');
        Test.startTest();
        System.runAs(ListOfUser[0]){ 
            Set<Id> acctIdSet = new  Set<Id>();
            for(Account acc: ListOfAccounts){
                acctIdSet.add(acc.id);
            }
            Map<Id,Set<Id>> assetsByAccount = Core_IPS_Helper_Utility.getAssetsByAccountId(acctIdSet);
            System.assert(!assetsByAccount.isEmpty(),'assets not got');
        }
        Test.stopTest();
        
    }
    /***************************************************************************************************
    Method Name:  getAssetsByAccountId_NegativeTest
    Method Type: Test Method
    Version     : 1.0 
    Created Date: 02 Feb 2016
    Description:  Testing "getAssetsByAccountId(Set<Id> acctIdSet)" utility  method
    Scenario Type:  Negative
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Deepak Jetty              02/03/2016                Created
    ****************************************************************************************************/
     void getAssetsByAccountId_NegativeTest(){
        getRecords();
        Test.startTest();
        System.runAs(ListOfUser[0]){ 
            Set<Id> userIdSet = new Set<Id>();
            Map<Id,Set<id>> projectsByAccountId = Core_IPS_Helper_Utility.getAssetsByAccountId(userIdSet);
            System.assert(projectsByAccountId==null,'Project by Accountid not null');
        }
        Test.stopTest();
        
    }
    /***************************************************************************************************
    Method Name:  getAssetsByProjectId_PositiveTest
    Method Type: Test Method
    Version     : 1.0 
    Created Date: 02 Feb 2016
    Description:  Testing "getAssetsByProjectId(Set<Id> projectIdSet)" utility  method
    Scenario Type:  Positive
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Deepak Jetty              02/03/2016                Created
    ****************************************************************************************************/
    static testMethod void getAssetsByProjectId_PositiveTest(){
        getRecords();
        // Get intelSupportOwner Id (User Id)
        Id intelSupportOwner = ListOfUser.get(0).id;
        // Create Ips Project
        List<Core_IPS_Project__c> ListOfIpsProjects = TestUtilities.getListOfIpsProjects(200);
        System.runAs(ListOfUser[0]){
            insert ListOfIpsProjects;
        }
        // Create Asset
        Integer Counter = 0;
        list<Asset> AssetList = TestUtilities.getAssetList(200);
        for(Asset Asst : AssetList){
            Asst.Core_IPS_Project__c = ListOfIpsProjects[Counter].id;
            Counter++;
        }
        Counter = 0;
        System.runAs(ListOfUser[0]){ 
            insert AssetList;
        }
        System.assert(AssetList[0].Id != null, 'Record not created');
        Test.startTest();
        System.runAs(ListOfUser[0]){ 
            Set<Id> projectIdSet = new  Set<Id>();
            for(Core_IPS_Project__c IPSProj: ListOfIpsProjects){
                projectIdSet.add(IPSProj.id);
            }
            Map<Id,Set<Id>> assetsByProject = Core_IPS_Helper_Utility.getAssetsByProjectId(projectIdSet);
            System.assert(!assetsByProject.isEmpty(),'assets not got');
        }
        Test.stopTest();
        
    }
    /***************************************************************************************************
    Method Name:  getAssetsByProjectId_NegativeTest
    Method Type: Test Method
    Version     : 1.0 
    Created Date: 02 Feb 2016
    Description:  Testing "getAssetsByProjectId(Set<Id> projectIdSet)" utility  method
    Scenario Type:  Negative
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Deepak Jetty              02/03/2016                Created
    ****************************************************************************************************/
    static testMethod void getAssetsByProjectId_NegativeTest(){
        getRecords();
        Test.startTest();
        System.runAs(ListOfUser[0]){ 
            Set<Id> projectIdSet = new Set<Id>();
            Map<Id,Set<id>> assetsByProject = Core_IPS_Helper_Utility.getAssetsByProjectId(projectIdSet);
            System.assert(assetsByProject==null,'Project by Accountid not null');
        }
        Test.stopTest();
        
    }
    /***************************************************************************************************
    Method Name:  getPARsByAccountId_PositiveTest
    Method Type: Test Method
    Version     : 1.0 
    Created Date: 03 Feb 2016
    Description:  Testing "getPARsByAccountId(Set<Id> accountIdSet)" utility  method
    Scenario Type:  Positive
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Deepak Jetty              03/03/2016                Created
    ****************************************************************************************************/
    static testMethod void getPARsByAccountId_PositiveTest(){
        getRecords();
        // Get intelSupportOwner Id (User Id)
        Id intelSupportOwner = ListOfUser.get(0).id;
        // Create Accounts
        List<Account> ListOfAccounts = TestUtilities.getListOfAccounts(1);
        
        System.runAs(ListOfUser[0]){ 
            ListOfAccounts[0].Core_CNDA_Number__c = '5676';
            ListOfAccounts[0].Core_IPS_Active__c = true;
            insert ListOfAccounts;
        }
        // Create Product Access
        List<Core_IPS_MAP_PAR__c> MapParList = TestUtilities.getMapParList(1);
        Map<string,ID> MapRecordtype = new Map<string,ID>();
        for(Recordtype Rt:[Select ID,Name from Recordtype where sobjectType = 'Core_IPS_MAP_PAR__c'])
        {  
              MapRecordtype.put(Rt.Name,Rt.ID);
        } 
        System.runAs(ListOfUser[0]){
            for(Core_IPS_MAP_PAR__c parObj:MapParList){
                parObj.RecordTypeId = MapRecordtype.get('PAR');
            }
            insert MapParList;
        }
        // Create Product Access: Accounts
        Integer Counter = 0;
        List<Core_IPS_MAP_Account__c> IPSMAPAccountList = TestUtilities.getIPSMAPAccountList(1);
        for(Core_IPS_MAP_Account__c IPSMAPAccount:IPSMAPAccountList){
            IPSMAPAccount.Core_Account__c = ListOfAccounts[0].id;   
            IPSMAPAccount.Core_MAP_PAR__c = MapParList[0].id;
            Counter++;
        }
        Counter = 0;
        System.runAs(ListOfUser[0]){
            insert IPSMAPAccountList;
        }
        Test.startTest();
        System.runAs(ListOfUser[0]){ 
            Set<Id> accountIdSet = new  Set<Id>();
            for(Account Acc: ListOfAccounts){
                accountIdSet.add(Acc.id);
            }
            Map<Id,Set<Id>> parsByAccountId = Core_IPS_Helper_Utility.getPARsByAccountId(accountIdSet);
            System.assert(!parsByAccountId.isEmpty(),'PARs not got');
        }
        Test.stopTest();
        
    }
    /***************************************************************************************************
    Method Name:  getPARsByAccountId_NegativeTest
    Method Type: Test Method
    Version     : 1.0 
    Created Date: 03 Feb 2016
    Description:  Testing "getPARsByAccountId(Set<Id> accountIdSet)" utility  method
    Scenario Type:  Negative
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Deepak Jetty              03/03/2016                Created
    ****************************************************************************************************/
    static testMethod void getPARsByAccountId_NegativeTest(){
        getRecords();
        Test.startTest();
        System.runAs(ListOfUser[0]){ 
            Set<Id> accountIdSet = new Set<Id>();
            Map<Id,Set<id>> parsByAccountId = Core_IPS_Helper_Utility.getPARsByAccountId(accountIdSet);
            System.assert(parsByAccountId==null,'Project by Accountid not null');
        }
        Test.stopTest();
        
    }
    /***************************************************************************************************
    Method Name:  getAccountIdsbyProjectId_PositiveTest
    Method Type: Test Method
    Version     : 1.0 
    Created Date: 03 Feb 2016
    Description:  Testing "getAccountIdsbyProjectId(Set<Id> projectIdSet)" utility  method
    Scenario Type:  Positive
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Deepak Jetty              03/03/2016                Modified
    ****************************************************************************************************/
    static testMethod void getAccountIdsbyProjectId_PositiveTest(){
        getRecords();
        // Get intelSupportOwner Id (User Id)
        Id intelSupportOwner = ListOfUser.get(0).id;
        // Create Accounts
        List<Account> ListOfAccounts = TestUtilities.getListOfAccounts(200);
        System.runAs(ListOfUser[0]){
            insert ListOfAccounts;
        }
        System.assert(ListOfAccounts[0].Id != null, 'Record not created');
        // Create Ips Project
        List<Core_IPS_Project__c> ListOfIpsProjects = TestUtilities.getListOfIpsProjects(200);
        System.runAs(ListOfUser[0]){
            insert ListOfIpsProjects;
        }
        System.assert(ListOfIpsProjects[0].Id != null, 'Record not created');
        // Create Ips Account
        Integer Counter = 0;
        List<Core_IPS_Account__c> ListOfIpsAccounts = TestUtilities.getListOfIpsAccounts(200);
        for(Core_IPS_Account__c IpsAcc : ListOfIpsAccounts){
            IpsAcc.Core_Account__c = ListOfAccounts.get(0).Id;
            IpsAcc.Core_IPS_Project__c = ListOfIpsProjects[Counter].Id;
            Counter++;
        }
        Counter = 0;
        System.runAs(ListOfUser[0]){
            insert ListOfIpsAccounts;
        }
        System.assert(ListOfIpsAccounts[0].Id != null, 'Record not created');
        Test.startTest();
        System.runAs(ListOfUser[0]){ 
            Set<Id> projectIdSet = new Set<Id>();
            for(Core_IPS_Project__c IPSProj: ListOfIpsProjects){
                projectIdSet.add(IPSProj.id);
            }
            Map<Id,Set<id>> accountIdsbyProjectId = Core_IPS_Helper_Utility.getAccountIdsbyProjectId(projectIdSet);
            System.assert(!accountIdsbyProjectId.isEmpty(),'Project by Accountid null');
        }
        Test.stopTest();
        
    }
    /***************************************************************************************************
    Method Name:  getAccountIdsbyProjectId_Negative1Test
    Method Type: Test Method
    Version     : 1.0 
    Created Date: 03 Feb 2016
    Description:  Testing "getAccountIdsbyProjectId(Set<Id> projectIdSet)" utility  method
    Scenario Type:  Negative
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Deepak Jetty              03/03/2016                Modified
    ****************************************************************************************************/
    static testMethod void getAccountIdsbyProjectId_Negative1Test(){
        getRecords();
        Test.startTest();
        System.runAs(ListOfUser[0]){ 
            Set<Id> projectIdSet = new Set<Id>();
            Map<Id,Set<id>> accountIdsbyProjectId = Core_IPS_Helper_Utility.getAccountIdsbyProjectId(projectIdSet);
            System.assert(accountIdsbyProjectId==null,'Accounts not null');
        }
        Test.stopTest();
        
    }
    /***************************************************************************************************
    Method Name:  getAccountIdsbyProjectId_Negative2Test
    Method Type: Test Method
    Version     : 1.0 
    Created Date: 03 Feb 2016
    Description:  Testing "getAccountIdsbyProjectId(Set<Id> projectIdSet)" utility  method
    Scenario Type:  Negative
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Deepak Jetty              03/03/2016                Modified
    ****************************************************************************************************/
    static testMethod void getAccountIdsbyProjectId_Negative2Test(){
        getRecords();
        // Create Ips Project
        Core_IPS_Project__c IpsProject = TestUtilities.getIpsProjectRecord();
        IpsProject.Core_Status__c = 'Draft';
        List<Core_IPS_Project__c> ListOfIpsProjects = TestUtilities.getListOfIpsProjects(200);
        for(Core_IPS_Project__c prj:TestUtilities.getListOfIpsProjects(200)){
            prj.Core_Status__c = 'Draft';
            ListOfIpsProjects.add(prj);
        }
        System.runAs(ListOfUser[0]){
            insert IpsProject;
            insert ListOfIpsProjects;
        }
        System.assert(ListOfIpsProjects[0].Id != null, 'Record not created');
        // Create Ips Account
        List<Core_IPS_Account__c> ListOfIpsAccounts = TestUtilities.getListOfIpsAccounts(1);
        for(Core_IPS_Account__c IpsAcc : ListOfIpsAccounts){
            IpsAcc.Core_IPS_Project__c = IpsProject.Id;
        }
        System.runAs(ListOfUser[0]){
            insert ListOfIpsAccounts;
        }
        System.assert(ListOfIpsAccounts[0].Id != null, 'Record not created');
        Test.startTest();
        System.runAs(ListOfUser[0]){ 
            Set<Id> projectIdSet = new Set<Id>();
            for(Core_IPS_Project__c IPSProj: ListOfIpsProjects){
                projectIdSet.add(IPSProj.id);
            }
            Map<Id,Set<id>> accountIdsbyProjectId = Core_IPS_Helper_Utility.getAccountIdsbyProjectId(projectIdSet);
            System.assert(accountIdsbyProjectId==null,'Accounts not null');
        }
        Test.stopTest();
        
    }
    
}