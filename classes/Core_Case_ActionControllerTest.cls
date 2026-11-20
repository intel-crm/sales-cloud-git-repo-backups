@isTest
public class Core_Case_ActionControllerTest
{
static List<User> ListOfUser = new List<User> ();
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
          string  rtId= '';
        List<Case> ListOfCases = TestUtilities.getListOfCases(10);
        for(Case CaseRec : ListOfCases){
            for(RecordType rt: rtList){
                if(rt.Name=='CEP Case'){
                    CaseRec.ContactId = ListOfContacts[0].id;
                    CaseRec.accountId = ListOfAccounts[0].Id;
                    CaseRec.RecordTypeId = rt.Id;
                    rtId = rt.Id;
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
            stdAct.Action__c='New';
            stdAct.Record_Type__c='CEP_Case';
            stdAct.URI__c='/Caseid/e?nooverride=1&retURL=';
        }
        System.runAs(ListOfUser.get(0)){
            insert ListStdActions;
        }
        ApexPages.StandardController Controller = new ApexPages.StandardController(ListOfCases.get(0));
        PageReference pageRef = Page.Core_Case_New_LandingPage;
        pageRef.getParameters().put('RecordType',rtId);
        pageRef.getParameters().put('cancelURL','abc');
        pageRef.getParameters().put('ent','abc');
        pageRef.getParameters().put('_CONFIRMATIONTOKEN','abc');
        pageRef.getParameters().put('save_new_url','asasas');
        //pageRef.getParameters().put('id', ListOfCases.get(0).id);
        Test.setCurrentPage(pageRef);
        Pagereference ref;
        Core_Case_ActionController pagExt = new Core_Case_ActionController(Controller);
        System.runAs(ListOfUser.get(0)){
            ref=pagExt.redirect2();
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
    static testmethod void redirectActionCEPCaseRTEdit_Test1(){
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
          string  rtId= '';
        List<Case> ListOfCases = TestUtilities.getListOfCases(10);
        for(Case CaseRec : ListOfCases){
            for(RecordType rt: rtList){
                if(rt.Name=='CEP Case'){
                    CaseRec.ContactId = ListOfContacts[0].id;
                    CaseRec.accountId = ListOfAccounts[0].Id;
                    CaseRec.RecordTypeId = rt.Id;
                    rtId = rt.Id;
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
            stdAct.Action__c='New';
            stdAct.Record_Type__c='CEP_Case';
            stdAct.URI__c='/Caseid/e?nooverride=1&retURL=';
        }
        System.runAs(ListOfUser.get(0)){
            insert ListStdActions;
        }
        ApexPages.StandardController Controller = new ApexPages.StandardController(ListOfCases.get(0));
        PageReference pageRef = Page.Core_Case_New_LandingPage;
        //pageRef.getParameters().put('RecordType',rtId);
        pageRef.getParameters().put('cancelURL','abc');
        pageRef.getParameters().put('ent','abc');
        pageRef.getParameters().put('_CONFIRMATIONTOKEN','abc');
        pageRef.getParameters().put('save_new_url','asasas');
        //pageRef.getParameters().put('id', ListOfCases.get(0).id);
        Test.setCurrentPage(pageRef);
        Pagereference ref;
        Core_Case_ActionController pagExt = new Core_Case_ActionController(Controller);
        System.runAs(ListOfUser.get(0)){
            ref=pagExt.redirect2();
        }
        System.assert(ref!=null, 'Empty Url');
        Test.stopTest();
    }
}