/***************************************************************************************************
Class Name:  Core_IPS_Helper_Utility_Test_sk
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
public class Core_IPS_Helper_Utility_Test_sk{
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
    }