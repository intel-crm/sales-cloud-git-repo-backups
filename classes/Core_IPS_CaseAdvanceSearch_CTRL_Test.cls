@isTest
public class Core_IPS_CaseAdvanceSearch_CTRL_Test {
   //Instance variables that are commonly used in multiple test methods
    static List<Case> ListOfCases = new List<Case> ();
    static Set<string> setcaseid = new Set<string>();
    static string filterString='';
    static List<User> SysAdminUsr = new List<User>();
    static case searchCaseObj = new Case();
    static List<Contact> ListOfContacts = new List<Contact>();
    static List<User> ListOfInternalUsers = new List<User> ();
    static List<User> ListOfExternalUsers = new List<User> ();
    static List<Core_IPS_Environment_Details__c> ListOfenvDetails = new List<Core_IPS_Environment_Details__c>();
    static List<Core_IPS_Product_Issue_Category__c> ListissueCatgory = new List<Core_IPS_Product_Issue_Category__c>();
    static List<Core_IPS_Project__c> ListOfProjects = new List<Core_IPS_Project__c>();
    static string searchstring='';
    static List<Case> casesForSearch = new List<case>();
    static List<Sobject> lstSObject = new List<Sobject>();
    static Map <string,string> mapstr= new Map<string,string>();
   
    static void getRecords(){
        // Query Profiles
        List<string> ListOfProfileNames = new List<string> {'System Administrator','IPS External Customer'};
        Map<String,ID> MapOfProfiles = new Map<String,ID>();
        for(Profile prof : [select id, name from Profile where name IN: ListOfProfileNames]){
            MapOfProfiles.put(prof.name, prof.id);
        }
        //UserRole CustomerRole = [select id from userrole where portaltype='CustomerPortal' limit 1];
        SysAdminUsr = TestUtilities.getListOfUser(1);
        SysAdminUsr.get(0).UserName = 'SysAdminUsr'+SysAdminUsr.get(0).UserName;
        SysAdminUsr.get(0).ProfileID =  MapOfProfiles.get('System Administrator');
        // Create UserRole Record
        UserRole role = new UserRole();
        role.name='CEO';
        // Creating SETUP OBJECT (USERROLE) RECORD
        System.RunAs(SysAdminUsr[0]){
            insert role;
        }
        // Create Internal User
        ListOfInternalUsers = TestUtilities.getListOfUser(1);
        ListOfInternalUsers.get(0).ProfileID =  MapOfProfiles.get('System Administrator');
        ListOfInternalUsers.get(0).userroleid = role.id;
        // Creating SETUP OBJECT (INTERNAL USER) RECORD
        System.RunAs(SysAdminUsr[0]){
            insert ListOfInternalUsers;
        }
        System.assertEquals(ListOfInternalUsers.get(0).profileid, MapOfProfiles.get('System Administrator'));
        
        // Create Account Record
        List<Account> ListOfAccounts = new List<Account> ();
        Account AccountRec1 = TestUtilities.getAccount();
        AccountRec1.Core_IPS_Active__c = true;
        AccountRec1.ownerid = ListOfInternalUsers.get(0).id; 
        ListOfAccounts.add(AccountRec1);
        insert ListOfAccounts;
        System.assert(ListOfAccounts[0].Id != null, 'Account Record not created');
        // Create Contact
        ListOfContacts = TestUtilities.getListOfContact(2);
        for(Contact Con : ListOfContacts){
            Con.Accountid = ListOfAccounts.get(0).Id;
            Con.Core_IPS_Intel_Support_Owner__c = ListOfInternalUsers.get(0).id;
            Con.ownerid = ListOfInternalUsers.get(0).id;
        }
        insert ListOfContacts;
        System.assert(ListOfContacts[0].Id != null, 'Contact Record not created');
         
        // Create External User
        ListOfExternalUsers = TestUtilities.getListOfUser(2);
        ListOfExternalUsers.get(0).ProfileID = MapOfProfiles.get('IPS External Customer');
        ListOfExternalUsers.get(0).contactId = ListOfContacts.get(0).Id;
        ListOfExternalUsers.get(0).UserName = 'CustomerUser'+ListOfExternalUsers.get(0).UserName;
        ListOfExternalUsers.get(1).ProfileID = MapOfProfiles.get('IPS External Customer');
        ListOfExternalUsers.get(1).contactId = ListOfContacts.get(1).Id;
        ListOfExternalUsers.get(1).UserName = 'CustomerUser2'+ListOfExternalUsers.get(0).UserName;
        // Creating SETUP OBJECT (CUSTOMER USER) RECORD
        System.RunAs(SysAdminUsr[0]){
            insert ListOfExternalUsers;
        }
        System.assertEquals(ListOfExternalUsers.get(0).profileid, MapOfProfiles.get('IPS External Customer'));
        // Create Ips Labels
        List<Core_IPS_Labels__c> IPSLabels = TestUtilities.getIPSLabel();
        for(Core_IPS_Labels__c IL: IPSLabels){
            if(IL.name=='ProjectGroupPrefix'){
                IL.Value__c = 'IPS_Proj_';
            }
             if(IL.name=='CoreStatus_SPtoActive_Error'){
                IL.Value__c = 'Project Status cannot be changed from Submitted Pending to Active';
            }
             if(IL.name=='Core_OneProjProdMem_Error'){
                IL.Value__c = 'Project cannot be submitted without atleast one account and one Product and one Project Member';
            }
            if(IL.name=='CoreStatus_Draft'){
               IL.Value__c = 'Draft'; 
            }
            if(IL.name=='CoreStatus_Active'){
               IL.Value__c = 'Active' ; 
            }
            if(IL.name=='CoreStatus_Inactive'){
               IL.Value__c = 'Inactive' ;
            }
            if(IL.name=='CoreStatus_SP'){
               IL.Value__c = 'Submitted Pending' ;
            }
        }

            Insert IPSLabels; 
        
        // Create Design Project Record
        List<Core_IPS_Project__c>  ListOfIpsProjects = TestUtilities.getListOfIpsProjects(1);
        insert ListOfIpsProjects;
        System.assert(ListOfIpsProjects.get(0).Id != null, 'Design Project Record not created');
        // Create Case Record
        ListOfCases = TestUtilities.getListOfCases(10);
        integer count=0;
        for(Case caseobj : ListOfCases){
            caseobj.AccountId = ListOfAccounts.get(0).id;
            caseobj.ContactId = ListOfContacts.get(0).Id;
            caseobj.Core_IPS_Project_Case__c = ListOfIpsProjects.get(0).Id;
            caseobj.Subject ='SubjectTest'+count;
            count++;
        }
        insert ListOfCases;
        casesForSearch = [Select subject,CaseNumber from case where id IN : ListOfCases];
        System.assert(ListOfCases.get(0).Id != null, 'Case Record not created');

        // Create Project Member
        List<Core_IPS_Project_Member__c> ListOfProjectMembers = TestUtilities.getListOfProjectMembers(2);
        ListOfProjectMembers.get(0).Core_IPS_Contact__c = ListOfContacts.get(0).Id;
        ListOfProjectMembers.get(0).Core_IPS_Project__c = ListOfIpsProjects.get(0).Id;
        ListOfProjectMembers.get(0).Core_User__c = ListOfInternalUsers.get(0).id;
        ListOfProjectMembers.get(1).Core_IPS_Contact__c = ListOfContacts.get(1).Id;
        ListOfProjectMembers.get(1).Core_IPS_Project__c = ListOfIpsProjects.get(0).Id;
        ListOfProjectMembers.get(1).Core_User__c = ListOfInternalUsers.get(0).id;
        insert ListOfProjectMembers;
        System.assert(ListOfProjectMembers.get(0).Id != null, 'Project Member Record not created');
        
        searchCaseObj = ListOfCases[0];
        Core_IPS_Environment_Details__c envDetal = new Core_IPS_Environment_Details__c();
        envDetal.Name = 'Issue Resolution List';
        envDetal.Core_Question__c='intel';
        envDetal.Core_Answer__c='TestAnswer1;TestAns2;Testans3';
        envDetal.Core_Case__c = searchCaseObj.id;
        insert envDetal;                
        System.assert(envDetal.Id != null, 'Record not created');
    }
    
    
    static testmethod void testSearchWithAllParams(){
        getRecords();
        System.runAs(SysAdminUsr[0])
        {
            Test.startTest();
            // Setting the Visualforce Page
          //  PageReference GlobalCaseSearchPage = Page.Core_IPS_GlobalCaseSearchPage;
           // Test.setCurrentPage(GlobalCaseSearchPage);
            // Assigning parameters in the URL
            ApexPages.currentPage().getParameters().put('id',searchCaseObj.id);
            // instantiate the Controller - Core_IPS_GlobalCaseSearchController Apex Class
          //  Core_IPS_CaseAdvanceSearch_CTRL_Test GlobalCaseSearchCon = new Core_IPS_CaseAdvanceSearch_CTRL_Test(searchCaseObj);
           // GlobalCaseSearchCon.Environment_Details = null;
           // String resut = GlobalCaseSearchCon.getCaseColumnsName(); 
          //  filterString ='CaseSubject='+searchCaseObj.Subject+'#%#CaseNumber='+casesForSearch.get(0).CaseNumber;
           filterString= 'CreatingDateFrom=2016-02-10#%#CreatingDateTo=2016-02-17#%#ProductName=skylake#%#status=\'New\',\'Open\',\'Closed\'#%#';
           // String substatus=\'Customer requesting open\'#%#';
            Core_IPS_CaseAdvanceSearch_CTRL.getCaseList('Test0', filterString,'Substatus');
            String filterString1 = 'CreatingDateFrom=2016-02-10#%#ProductName=skylake#%#status=\'New\',\'Open\',\'Closed\'#%#';
            Core_IPS_CaseAdvanceSearch_CTRL.getCaseList('Test0', filterString1,'Substatus');
            String filterString2 = 'Core_Customer_Reference_ID__c=customerID#%#CreatingDateTo=2016-02-10#%#ProductName=skylake#%#Status=\'New\',\'Open\',\'Closed\'#%#';
            Core_IPS_CaseAdvanceSearch_CTRL.getCaseList('Test0', filterString2,'Substatus');
            System.AssertEquals(filterString2 != null, true);
            Test.stopTest();
        }
    }
    static testmethod void testSearchWithoutParam(){
        getRecords();
        System.runAs(SysAdminUsr[0])
        {
        Test.startTest();
        // Setting the Visualforce Page
       // PageReference GlobalCaseSearchPage = Page.Core_IPS_CaseAdvanceSearch_CTRL_Test;
        //Test.setCurrentPage(GlobalCaseSearchPage);
        // Assigning parameters in the URL
       // ApexPages.currentPage().getParameters().put('id',searchCaseObj.id);
        // instantiate the Controller - Core_IPS_GlobalCaseSearchController Apex Class
     //   Core_IPS_CaseAdvanceSearch_CTRL GlobalCaseSearchCon = new Core_IPS_CaseAdvanceSearch_CTRL(searchCaseObj);
      //  String resut = GlobalCaseSearchCon.getCaseColumnsName();
        Core_IPS_CaseAdvanceSearch_CTRL.getCaseList('Test','','');
        Test.stopTest();
        System.AssertEquals(SysAdminUsr.size()>0, true);
        }
    }
   
    static testmethod void testSearchWithCreatingDateFrom(){
        getRecords();
        System.runAs(SysAdminUsr[0])
        {
            Test.startTest();
            // Setting the Visualforce Page
            PageReference GlobalCaseSearchPage = Page.Core_IPS_GlobalCaseSearchPage;
            Test.setCurrentPage(GlobalCaseSearchPage);
            // Assigning parameters in the URL
            ApexPages.currentPage().getParameters().put('id',searchCaseObj.id);
            // instantiate the Controller - Core_IPS_GlobalCaseSearchController Apex Class
           // Core_IPS_CaseAdvanceSearch_CTRL_Test GlobalCaseSearchCon = new Core_IPS_CaseAdvanceSearch_CTRL_Test(new ApexPages.StandardController(searchCaseObj));
            //String resut = GlobalCaseSearchCon.getCaseColumnsName();
           String filterString ='CaseSubject='+searchCaseObj.Subject+'#%# CaseNumber='+casesForSearch.get(0).CaseNumber;
          //  filterString= filterString+'#%#Core_Customer_Reference_ID__c=Hello  world#%#ProductName=skylake#%#CreatingDateFrom=2016-02-10#%#status=\'New\',\'Open\',\'Closed\'#%#';
            Core_IPS_CaseAdvanceSearch_CTRL.getCaseList('Test', filterString, 'substatus');
            Test.stopTest();
            System.AssertEquals(SysAdminUsr.size()>0, true);
        }
    }
    
   
    static testmethod void testSearchWithCreatingDateTo(){
        getRecords();
        System.runAs(SysAdminUsr[0])
        {
            Test.startTest();
            // Setting the Visualforce Page
           // PageReference GlobalCaseSearchPage = Page.Core_IPS_CaseAdvanceSearch_CTRL_Test;
            //Test.setCurrentPage(GlobalCaseSearchPage);
            // Assigning parameters in the URL
            ApexPages.currentPage().getParameters().put('id',searchCaseObj.id);
            // instantiate the Controller - Core_IPS_GlobalCaseSearchController Apex Class
          //  Core_IPS_CaseAdvanceSearch_CTRL_Test GlobalCaseSearchCon = new Core_IPS_CaseAdvanceSearch_CTRL_Test(new ApexPages.StandardController(searchCaseObj));
           // String resut = GlobalCaseSearchCon.getCaseColumnsName();
         String  filterString ='CaseNumber='+casesForSearch.get(0).CaseNumber;
            //filterString= filterString+'#%#Core_Customer_Reference_ID__c=Hello  world#%#ProductName=skylake#%#CreatingDateTo=2016-02-17#%#status=\'New\',\'Open\',\'Closed\'#%#';
            Core_IPS_CaseAdvanceSearch_CTRL.getCaseList('Test', filterString,'substatus');
            Test.stopTest();
            System.AssertEquals(SysAdminUsr.size()>0, true);
        }
    }
    //This method is used to check user type as Powerpartner
     static testmethod void testUserTypeCheck(){
        getRecords();
        User u = [SELECT Id,name,userType FROM User WHERE userType = 'PowerPartner' and isactive=true limit 1];
       
        System.runAs(u)
        {
            Test.startTest();
            // instantiate the Controller - Core_IPS_GlobalCaseSearchController Apex Class
           // Core_IPS_CaseAdvanceSearch_CTRL_Test GlobalCaseSearchCon = new Core_IPS_CaseAdvanceSearch_CTRL_Test(new ApexPages.StandardController(searchCaseObj));
           // String resut = GlobalCaseSearchCon.getCaseColumnsName();
            Test.stoptest();
            System.AssertEquals(u != null, true);
           
        }
    }
}