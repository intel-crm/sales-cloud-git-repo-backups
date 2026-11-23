/***************************************************************************************************
Class Name:  Core_Case_ActionEditController_Test
Class Type: Test Class 
Version     : 1.0 
Created Date: 05 Feb 2016
Function    : This class contains test coverage for Core_Case_ActionEditController class
Input Parameters: None 
Output Parameters: None
Description:   This class contains unit test scenarios for Core_Case_ActionEditController class
Used in     : None
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Deepak Jetty              5/02/2016                 Created
****************************************************************************************************/
@isTest
public class Core_Case_ActionEditController_Test {
    //Instance variables that are commonly used in multiple test methods
    static List<User> ListOfUser = new List<User> ();
    /***************************************************************************************************
Method Name:  getRecords()
Method Type: void
Version     : 1.0 
Created Date: 05 Feb 2016
Description:  Common Test data used for all test methods
Scenario Type:  
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Deepak Jetty       5/05/2016              Created
****************************************************************************************************/
    static void getRecords (){
        // Query Profiles
        Map<String,ID> profiles = new Map<String,ID>();
        List<String> strProf = new List<String>();
        strProf.add('System Administrator');
        strProf.add('Sales Rep-BB');
        List<Profile> ProfileList = [select id, name from Profile where name IN : strProf];
        for(Profile prf : ProfileList){
            profiles.put(prf.name, prf.id);
        }
        // Create Users
        ListOfUser = TestUtilities.getListOfUser(2);
        ListOfUser.get(0).ProfileID =  profiles.get('System Administrator');
        ListOfUser.get(1).ProfileID =  profiles.get('Sales Rep-BB');
        UserRole role = new UserRole();
        role.name='CEO';
        insert role;
        ListOfUser.get(0).UserRoleID =  role.Id;
        insert ListOfUser;
        System.assertEquals(ListOfUser.get(0).profileid, profiles.get('System Administrator'));
        System.assertEquals(ListOfUser.get(1).profileid, profiles.get('Sales Rep-BB'));
    }
/***************************************************************************************************
Method Name:  redirectActionCEPCaseRTEdit_Test
Method Type: Test Method
Version     : 1.0 
Created Date: 5 Feb 2016
Description:  Testing redirect Action with Record Type CEP Case and Edit
Scenario Type:  Positive
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Deepak Jetty              5/02/2016                Created
****************************************************************************************************/
    static testmethod void redirectActionCEPCaseRTEdit_Test(){
        getrecords();
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
        List<RecordType> rtList = [SELECT id,developerName,name FROM RecordType where SobjectType='Case'];
        // Create Case
        List<Case> ListOfCases = TestUtilities.getListOfCases(10);
        for(Case CaseRec : ListOfCases){
            for(RecordType rt: rtList){
                if(rt.Name=='CEP Case'){
                    CaseRec.ContactId = ListOfContacts[0].id;
                    CaseRec.accountId = ListOfAccounts[0].Id;
                    CaseRec.RecordTypeId = rt.Id;
                    CaseRec.OwnerId = intelSupportOwner;                         
                }
            }
        }
        System.runAs(ListOfUser.get(0)){
            insert ListOfCases;
        }
        System.assert(ListOfCases[0].Id != null, 'Record not created');
        Test.startTest();
        List<StandardActionRedirection__C> ListStdActions = TestUtilities.getStandardActionRedirection(1);
        for(StandardActionRedirection__C stdAct:ListStdActions){
            stdAct.Name='22';
            stdAct.Action__c='Edit';
            stdAct.Record_Type__c='CEP_Case';
            stdAct.URI__c='/Caseid/e?nooverride=1&retURL=';
        }
        System.runAs(ListOfUser.get(0)){
            insert ListStdActions;
        }
        ApexPages.StandardController Controller = new ApexPages.StandardController(ListOfCases.get(0));
        PageReference pageRef = Page.Core_Case_New_LandingEditPage;
        pageRef.getParameters().put('id', ListOfCases.get(0).id);
        Test.setCurrentPage(pageRef);
        Pagereference ref;
        Core_Case_ActionEditController pagExt = new Core_Case_ActionEditController(Controller);
        System.runAs(ListOfUser.get(0)){
            ref=pagExt.redirect();
        }
        System.assert(ref!=null, 'Empty Url');
        Test.stopTest();
    }
    /***************************************************************************************************
Method Name:  redirectActionCEPCaseRTEdit_Test
Method Type: Test Method
Version     : 1.0 
Created Date: 5 Feb 2016
Description:  Testing redirect Action with Record Type other than CEP Case and Edit
Scenario Type:  Positive
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Deepak Jetty              5/02/2016                Created
****************************************************************************************************/
    static testmethod void redirectActionNonCEPCaseRTEdit_Test(){
        getrecords();
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
        List<RecordType> rtList = [SELECT id,developerName,name FROM RecordType where SobjectType='Case'];
        // Create Case
        List<Case> ListOfCases = TestUtilities.getListOfCases(10);
        for(Case CaseRec : ListOfCases){
            for(RecordType rt: rtList){
                if(rt.Name=='IPS_Case_Create'){
                    CaseRec.ContactId = ListOfContacts[0].id;
                    CaseRec.accountId = ListOfAccounts[0].Id;
                    CaseRec.RecordTypeId = rt.Id;
                    CaseRec.OwnerId = intelSupportOwner;                         
                }
            }
        }
        System.runAs(ListOfUser.get(0)){
            insert ListOfCases;
        }
        System.assert(ListOfCases[0].Id != null, 'Record not created');
        Test.startTest();
        List<StandardActionRedirection__C> ListStdActions = TestUtilities.getStandardActionRedirection(1);
        for(StandardActionRedirection__C stdAct:ListStdActions){
            stdAct.Name='12';
            stdAct.Action__c='Edit';
            stdAct.Record_Type__c='IPS_Case_Create';
            stdAct.URI__c='/apex/Core_IPS_Internal_Case_Creation?mode=edit&id=';
        }
        System.runAs(ListOfUser.get(0)){
            insert ListStdActions;
        }
        ApexPages.StandardController Controller = new ApexPages.StandardController(ListOfCases.get(0));
        PageReference pageRef = Page.Core_Case_New_LandingEditPage;
        pageRef.getParameters().put('id', ListOfCases.get(0).id);
        Test.setCurrentPage(pageRef);
        Pagereference ref;
        Core_Case_ActionEditController pagExt = new Core_Case_ActionEditController(Controller);
        System.runAs(ListOfUser.get(0)){
            ref=pagExt.redirect();
        }
        System.assert(ref!=null, 'Empty Url');
        Test.stopTest();
    }
    /***************************************************************************************************
Method Name:  redirectActionCEPCaseRTEdit_Test
Method Type: Test Method
Version     : 1.0 
Created Date: 5 Feb 2016
Description:  Testing redirect Action with Record Type CEP Case and Edit
Scenario Type:  Positive
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Deepak Jetty              5/02/2016                Created
****************************************************************************************************/
    static testmethod void redirectActionWithoutRTEdit_Test(){
        getrecords();
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
        // Create Case
        List<Case> ListOfCases = TestUtilities.getListOfCases(10);
        for(Case CaseRec : ListOfCases){
            CaseRec.ContactId = ListOfContacts[0].id;
            CaseRec.accountId = ListOfAccounts[0].Id;
            CaseRec.OwnerId = intelSupportOwner;                         
        }
        System.runAs(ListOfUser.get(0)){
            insert ListOfCases;
        }
        System.assert(ListOfCases[0].Id != null, 'Record not created');
        Test.startTest();
        List<StandardActionRedirection__C> ListStdActions = TestUtilities.getStandardActionRedirection(1);
        for(StandardActionRedirection__C stdAct:ListStdActions){
            stdAct.Name='21';
            stdAct.Action__c='Edit';
            stdAct.URI__c='/apex/Core_IPS_Internal_Case_Creation?retURL=';
            stdAct.Profile_del__c = 'Sales Rep-BB';
        }
        System.runAs(ListOfUser.get(0)){
            insert ListStdActions;
        }
        ApexPages.StandardController Controller = new ApexPages.StandardController(ListOfCases.get(0));
        PageReference pageRef = Page.Core_Case_New_LandingEditPage;
        pageRef.getParameters().put('id', ListOfCases.get(0).id);
        Test.setCurrentPage(pageRef);
        Pagereference ref;
        Core_Case_ActionEditController pagExt = new Core_Case_ActionEditController(Controller);
        System.runAs(ListOfUser.get(1)){
            ref=pagExt.redirect();
        }
        System.assert(ref!=null, 'Empty Url');
        Test.stopTest();
    }
    /***************************************************************************************************
Method Name:  redirectActionCustomerUserWithAccountID_Test
Method Type: Test Method
Version     : 1.0 
Created Date: 5 Feb 2016
Description:  Testing redirect Action with External User Profile and AccountID and Edit
Scenario Type:  Positive
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Deepak Jetty              5/02/2016                Created
****************************************************************************************************/
    static testmethod void redirectActionCustomerUserWithAccountID_Test(){
        getrecords();
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
        List<User> ListOfCustomerUser = TestUtilities.getListOfUser(1);
        //UserRole role = [select id from userrole where portaltype='CustomerPortal' limit 1];
        integer Counter = 0;
        for(User Usr : ListOfCustomerUser){
            Usr.ProfileID = CustomerProfile.id;
            Usr.UserName = Counter+'getFAEsByProject@intel.com';
            Usr.contactId = ListOfContacts.get(0).id;
            Counter++;
        }
        insert ListOfCustomerUser;
        System.assertEquals(ListOfCustomerUser[0].ProfileID, CustomerProfile.id);
        List<RecordType> rtList = [SELECT id,developerName,name FROM RecordType where SobjectType='Case'];
        // Create Case
        List<Case> ListOfCases = TestUtilities.getListOfCases(10);
        for(Case CaseRec : ListOfCases){
            for(RecordType rt: rtList){
                if(rt.Name=='IPS_Case_Create'){
                    CaseRec.ContactId = ListOfContacts[0].id;
                    CaseRec.accountId = ListOfAccounts[0].Id;
                    CaseRec.RecordTypeId = rt.Id;
                    CaseRec.OwnerId = intelSupportOwner;                         
                }
            }
        }
        System.runAs(ListOfUser.get(0)){
            insert ListOfCases;
        }
        System.assert(ListOfCases[0].Id != null, 'Record not created');
        Test.startTest();
        List<StandardActionRedirection__C> ListStdActions = TestUtilities.getStandardActionRedirection(1);
        for(StandardActionRedirection__C stdAct:ListStdActions){
            stdAct.Name='15';
            stdAct.Action__c='Edit';
            stdAct.URI__c='/apex/Core_IPS_Customer_Case_Creation?mode=edit&id=';
            stdAct.Profile_del__c = 'IPS External Customer';
        }
        System.runAs(ListOfUser.get(0)){
            insert ListStdActions;
        }
        ApexPages.StandardController Controller = new ApexPages.StandardController(ListOfCases.get(0));
        PageReference pageRef = Page.Core_Case_New_LandingEditPage;
        pageRef.getParameters().put('id', ListOfCases.get(0).id);
        pageRef.getParameters().put('def_account_id', ListOfAccounts.get(0).Id);
        Test.setCurrentPage(pageRef);
        Pagereference ref;
        Core_Case_ActionEditController pagExt = new Core_Case_ActionEditController(Controller);
        System.runAs(ListOfCustomerUser.get(0)){
            ref=pagExt.redirect();
        }
        System.assert(ref!=null, 'Empty Url');
        Test.stopTest();
    }
    /***************************************************************************************************
Method Name:  redirectActionCustomerUserWithContactID_Test
Method Type: Test Method
Version     : 1.0 
Created Date: 5 Feb 2016
Description:  Testing redirect Action with External User Profile and ContactID and Edit
Scenario Type:  Positive
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Deepak Jetty              5/02/2016                Created
****************************************************************************************************/
    static testmethod void redirectActionCustomerUserWithContactID_Test(){
        getrecords();
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
        List<User> ListOfCustomerUser = TestUtilities.getListOfUser(1);
        //UserRole role = [select id from userrole where portaltype='CustomerPortal' limit 1];
        integer Counter = 0;
        for(User Usr : ListOfCustomerUser){
            Usr.ProfileID = CustomerProfile.id;
            Usr.UserName = Counter+'getFAEsByProject@intel.com';
            Usr.contactId = ListOfContacts.get(0).id;
            Counter++;
        }
        insert ListOfCustomerUser;
        System.assertEquals(ListOfCustomerUser[0].ProfileID, CustomerProfile.id);
        List<RecordType> rtList = [SELECT id,developerName,name FROM RecordType where SobjectType='Case'];
        // Create Case
        List<Case> ListOfCases = TestUtilities.getListOfCases(10);
        for(Case CaseRec : ListOfCases){
            for(RecordType rt: rtList){
                if(rt.Name=='IPS_Case_Create'){
                    CaseRec.ContactId = ListOfContacts[0].id;
                    CaseRec.accountId = ListOfAccounts[0].Id;
                    CaseRec.RecordTypeId = rt.Id;
                    CaseRec.OwnerId = intelSupportOwner;                         
                }
            }
        }
        System.runAs(ListOfUser.get(0)){
            insert ListOfCases;
        }
        System.assert(ListOfCases[0].Id != null, 'Record not created');
        Test.startTest();
        String nextPage;
        List<StandardActionRedirection__C> ListStdActions = TestUtilities.getStandardActionRedirection(1);
        for(StandardActionRedirection__C stdAct:ListStdActions){
            stdAct.Name='15';
            stdAct.Action__c='Edit';
            stdAct.URI__c='/apex/Core_IPS_Customer_Case_Creation?mode=edit&id=';
            stdAct.Profile_del__c = 'IPS External Customer';
        }
        System.runAs(ListOfUser.get(0)){
            insert ListStdActions;
        }
        ApexPages.StandardController Controller = new ApexPages.StandardController(ListOfCases.get(0));
        PageReference pageRef = Page.Core_Case_New_LandingEditPage;
        pageRef.getParameters().put('id', ListOfCases.get(0).id);
        pageRef.getParameters().put('def_contact_id', ListOfContacts.get(0).Id);
        Test.setCurrentPage(pageRef);
        Pagereference ref;
        Core_Case_ActionEditController pagExt = new Core_Case_ActionEditController(Controller);
        System.runAs(ListOfCustomerUser.get(0)){
            ref=pagExt.redirect();
        }
        System.assert(ref!=null, 'Empty Url');
        Test.stopTest();
    }

}