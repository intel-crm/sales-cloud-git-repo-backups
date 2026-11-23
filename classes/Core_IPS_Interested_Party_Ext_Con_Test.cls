/***************************************************************************************************
Class Name:  Core_IPS_Interested_Party_Ext_Con_Test
Class Type: Test Class 
Version     : 1.0 
Created Date: 03 Feb 2016
Function    : This class contains test coverage for Core_IPS_Interested_Party_Ext_Controller Apex Class.
When Agent Logs access Case, Agent is directed to Core_IPS_Interested_Party_External VF Page and Core_IPS_Interested_Party_Ext_Controller Class is invoked
Description:   This class contains unit test scenarios for Core_IPS_Interested_Party_Ext_Controller Apex Class
Used in     : None
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Abhishek Ekbote      03/02/2016                Created
****************************************************************************************************/ 
@isTest
public class Core_IPS_Interested_Party_Ext_Con_Test{
    //Instance variables that are commonly used in multiple test methods
    static List<Case> ListOfCases = new List<Case> ();
    static List<Contact> ListOfContacts = new List<Contact>();
    static List<User> ListOfInternalUsers = new List<User> ();
    static List<User> ListOfExternalUsers = new List<User> ();
    static Set<ID> allActiveContactIds= new Set<ID>();
    /***************************************************************************************************
    Method Name:  getRecords
    Method Type: Void Method
    Version     : 1.0 
    Created Date: 03 Feb 2016
    Description:  Common Test data used in multiple test methods
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Abhishek Ekbote       03/02/2016                Created
    ****************************************************************************************************/
    static void getRecords(){
        // Query Profiles
        List<string> ListOfProfileNames = new List<string> {'System Administrator','IPS External Customer'};
        Map<String,ID> MapOfProfiles = new Map<String,ID>();
        for(Profile prof : [select id, name from Profile where name IN: ListOfProfileNames]){
            MapOfProfiles.put(prof.name, prof.id);
        }
        //UserRole CustomerRole = [select id from userrole where portaltype='CustomerPortal' limit 1];
        List<User> SysAdminUsr = TestUtilities.getListOfUser(1);
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
        System.RunAs(ListOfInternalUsers.get(0)){
            insert ListOfAccounts;
         }
        System.assert(ListOfAccounts[0].Id != null, 'Account Record not created');
        // Create Contact
        ListOfContacts = TestUtilities.getListOfContact(4);//Ashutosh- Us103988
        for(Contact Con : ListOfContacts){
            Con.Accountid = ListOfAccounts.get(0).Id;
            Con.Core_IPS_Intel_Support_Owner__c = ListOfInternalUsers.get(0).id;
            Con.ownerid = ListOfInternalUsers.get(0).id;
        }
        System.RunAs(ListOfInternalUsers.get(0)){
            insert ListOfContacts;
        }
        System.assert(ListOfContacts[0].Id != null, 'Contact Record not created');
        // Create External User
        ListOfExternalUsers = TestUtilities.getListOfUser(3);//Ashutosh-US103988
        ListOfExternalUsers.get(0).ProfileID = MapOfProfiles.get('IPS External Customer');
        ListOfExternalUsers.get(0).contactId = ListOfContacts.get(0).Id;
        ListOfExternalUsers.get(0).UserName = 'CustomerUser'+ListOfExternalUsers.get(0).UserName;
        ListOfExternalUsers.get(1).ProfileID = MapOfProfiles.get('IPS External Customer');
        ListOfExternalUsers.get(1).contactId = ListOfContacts.get(1).Id;
        ListOfExternalUsers.get(1).UserName = 'CustomerUser2'+ListOfExternalUsers.get(0).UserName;
        //Ashutosh -US103988
        ListOfExternalUsers.get(2).ProfileID = MapOfProfiles.get('IPS External Customer');
        ListOfExternalUsers.get(2).contactId = ListOfContacts.get(2).Id;
        ListOfExternalUsers.get(2).UserName = 'CustomerUser3'+ListOfExternalUsers.get(0).UserName;
        // Creating SETUP OBJECT (CUSTOMER USER) RECORD
        System.RunAs(SysAdminUsr[0]){
            insert ListOfExternalUsers;
        }
        System.assertEquals(ListOfExternalUsers.get(0).profileid, MapOfProfiles.get('IPS External Customer'));
        // Create Design Project Record
        List<Core_IPS_Project__c>  ListOfIpsProjects = TestUtilities.getListOfIpsProjects(1);
        System.RunAs(ListOfInternalUsers.get(0)){
            insert ListOfIpsProjects;
        }
        System.assert(ListOfIpsProjects.get(0).Id != null, 'Design Project Record not created');
        // Create Case Record
        ListOfCases = TestUtilities.getListOfCases(1);
        ListOfCases.get(0).AccountId = ListOfAccounts.get(0).id;
        ListOfCases.get(0).ContactId = ListOfContacts.get(0).Id;
        ListOfCases.get(0).Core_IPS_Project_Case__c = ListOfIpsProjects.get(0).Id;
        System.RunAs(ListOfInternalUsers.get(0)){
            insert ListOfCases;
        }
        System.assert(ListOfCases.get(0).Id != null, 'Case Record not created');
        // Create Project Member
        List<Core_IPS_Project_Member__c> ListOfProjectMembers = TestUtilities.getListOfProjectMembers(3);//Ashutosh-US103988
        ListOfProjectMembers.get(0).Core_IPS_Contact__c = ListOfContacts.get(0).Id;
        ListOfProjectMembers.get(0).Core_IPS_Project__c = ListOfIpsProjects.get(0).Id;
        ListOfProjectMembers.get(0).Core_User__c = ListOfInternalUsers.get(0).id;
        
        ListOfProjectMembers.get(1).Core_IPS_Contact__c = ListOfContacts.get(1).Id;
        ListOfProjectMembers.get(1).Core_IPS_Project__c = ListOfIpsProjects.get(0).Id;
        ListOfProjectMembers.get(1).Core_User__c = ListOfInternalUsers.get(0).id;
        //Ashutosh _ US103988
        ListOfProjectMembers.get(2).Core_IPS_Contact__c = ListOfContacts.get(2).Id;
        ListOfProjectMembers.get(2).Core_IPS_Project__c = ListOfIpsProjects.get(0).Id;
        ListOfProjectMembers.get(2).Core_User__c = ListOfInternalUsers.get(0).id;
        System.RunAs(ListOfInternalUsers.get(0)){
            insert ListOfProjectMembers;
         }
        System.assert(ListOfProjectMembers.get(0).Id != null, 'Project Member Record not created');
        // Create Interested Party Record
        List<Core_IPS_Case_Interested_Party__c> ListOfInterestedParty = TestUtilities.getInternalInterestedParties(2);//Ashutosh-us103988 - change to 2 parties
        ListOfInterestedParty.get(0).Case__c = ListOfCases.get(0).Id;
        ListOfInterestedParty.get(0).User__c = ListOfExternalUsers.get(0).Id;
        ListOfInterestedParty.get(0).Contact__c = ListOfContacts.get(0).Id;
        ListOfInterestedParty.get(0).Type__c = 'External';//Ashutosh - US103988
        //Ashutosh-US103988
        ListOfInterestedParty.get(1).Case__c = ListOfCases.get(0).Id;
        ListOfInterestedParty.get(1).User__c = ListOfExternalUsers.get(1).Id;
        ListOfInterestedParty.get(1).Contact__c = ListOfContacts.get(1).Id;
        ListOfInterestedParty.get(1).Type__c = 'External';//Ashutosh - US103988
        System.RunAs(ListOfInternalUsers.get(0)){
            insert ListOfInterestedParty;
        }
        System.assert(ListOfInterestedParty.get(0).Id != null, 'Interested Party Record not created');
    }
    /***************************************************************************************************
    Method Name:  AddExtIPbyInternalUsr_CaseWithIpsProj
    Method Type: Test Method
    Version     : 1.0 
    Created Date: 03 Feb 2016
    Description:  Creating Case External IP with IPS Project
    Scenario Type:  Positive
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Abhishek Ekbote       03/02/2016                 Created
    ****************************************************************************************************/
    static testmethod void AddExtIPbyInternalUsr_CaseWithIpsProj(){
        getRecords();
        Test.startTest();
        User UsrRec = new User();
        Contact ConRec = new Contact();
        System.RunAs(ListOfInternalUsers.get(0)){
            // Setting the Visualforce Page
            PageReference InterestedPartyExternalPage = Page.Core_IPS_Interested_Party_External;
            Test.setCurrentPage(InterestedPartyExternalPage);
            // Assigning parameters in the URL
            ApexPages.currentPage().getParameters().put('id',ListOfCases.get(0).id);
            // instantiate the Controller - Core_IPS_Internal_Case_Controller Apex Class
            Core_IPS_Interested_Party_Ext_Controller InterestedPartyExtCon = new Core_IPS_Interested_Party_Ext_Controller(new ApexPages.StandardController(ListOfCases.get(0)));
            Core_IPS_Interested_Party_Ext_Controller.IPWrapper IpWrapClass = new  Core_IPS_Interested_Party_Ext_Controller.IPWrapper(ConRec, UsrRec);
            InterestedPartyExtCon.searchText = '*';
            PageReference pageRef1 = InterestedPartyExtCon.doSearch();
            System.assertEquals(null,pageRef1);         
            InterestedPartyExtCon.IPRecordSet.get(0).isSelected = true;
            PageReference pageRef2 = InterestedPartyExtCon.AddSelectedContacts();
            System.assertEquals(null,pageRef2);
            PageReference pageRef3 =InterestedPartyExtCon.Finished();
            System.assertEquals('/'+ListOfCases.get(0).id,pageRef3.getUrl());
        }
        Test.stopTest();
    }
    /***************************************************************************************************
    Method Name:  DeleteExtIPbyInternalUsr_CaseWithIpsProj
    Method Type: Test Method
    Version     : 1.0 
    Created Date: 02 Feb 2016
    Description:  Deleting Case External IP by Internal User with IPS Project
    Scenario Type:  Positive
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Abhishek Ekbote       03/02/2016                 Created
    ****************************************************************************************************/
    static testmethod void DeleteExtIPbyInternalUsr_CaseWithIpsProj(){
        getRecords();
        Test.startTest();
        User UsrRec = new User();
        Contact ConRec = new Contact();
        System.RunAs(ListOfInternalUsers.get(0)){
            // Setting the Visualforce Page
            PageReference InterestedPartyExternalPage = Page.Core_IPS_Interested_Party_External;
            Test.setCurrentPage(InterestedPartyExternalPage);
            // Assigning parameters in the URL
            ApexPages.currentPage().getParameters().put('id',ListOfCases.get(0).id);
            // instantiate the Controller - Core_IPS_Internal_Case_Controller Apex Class
            Core_IPS_Interested_Party_Ext_Controller InterestedPartyExtCon = new Core_IPS_Interested_Party_Ext_Controller(new ApexPages.StandardController(ListOfCases.get(0)));
            Core_IPS_Interested_Party_Ext_Controller.IPWrapper IpWrapClass = new  Core_IPS_Interested_Party_Ext_Controller.IPWrapper(ConRec, UsrRec);
            InterestedPartyExtCon.searchText = '*';
            PageReference pageRef1 = InterestedPartyExtCon.doSearch();
            System.assertEquals(null,pageRef1);
            //added by naresh
            InterestedPartyExtCon.searchText = '';
            InterestedPartyExtCon.IPRecordSet.add(IpWrapClass); 
            PageReference pageRef4 = InterestedPartyExtCon.doSearch();
            System.assertEquals(null,pageRef4);
            InterestedPartyExtCon.searchText = 'test';
            InterestedPartyExtCon.IPRecordSet.add(IpWrapClass); 
            PageReference pageRef5 = InterestedPartyExtCon.doSearch();
            System.assertEquals(null,pageRef5);
            InterestedPartyExtCon.ProjMem= null;
            InterestedPartyExtCon.IPRecordSet.add(IpWrapClass); 
            InterestedPartyExtCon.IPRecordSet.add(IpWrapClass); 
            System.Debug('count======'+InterestedPartyExtCon.IPRecordSet.size());
            PageReference pageRef6 = InterestedPartyExtCon.doSearch();
            System.assertEquals(null,pageRef6);
            // end
            //InterestedPartyExtCon.IPRecordSet.get(0).isSelected = true;
            PageReference pageRef2 = InterestedPartyExtCon.AddSelectedContacts();
            System.assertEquals(null,pageRef2);
            //InterestedPartyExtCon.LinkedExternalParties.get(0).Active__c = false;- Ashutosh US103988
            InterestedPartyExtCon.LinkedExternalPartiesList.get(0).isSelected = false;//- Ashutosh US103988
            PageReference pageRef3 = InterestedPartyExtCon.removeSelectedContacts();
            System.assertEquals(null,pageRef3);
        }
        Test.stopTest();
    }
    /***************************************************************************************************
    Method Name:  AddExtIPbyInternalUsr_CaseWithOutIpsProj
    Method Type: Test Method
    Version     : 1.0 
    Created Date: 02 Feb 2016
    Description:  Creating Case External IP by Internal User without IPS Project
    Scenario Type:  Positive
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Abhishek Ekbote       03/02/2016                 Created
    ****************************************************************************************************/
    static testmethod void AddExtIPbyInternalUsr_CaseWithOutIpsProj(){
        getRecords();
        Test.startTest();
        System.RunAs(ListOfInternalUsers.get(0)){
        ListOfCases.get(0).Core_IPS_Project_Case__c = null;
        update ListOfCases;
        System.assert(ListOfCases[0].Core_IPS_Project_Case__c == null, 'Case is not updated');
        User UsrRec = new User();
        Contact ConRec = new Contact();
        
            // Setting the Visualforce Page
            PageReference InterestedPartyExternalPage = Page.Core_IPS_Interested_Party_External;
            Test.setCurrentPage(InterestedPartyExternalPage);
            // Assigning parameters in the URL
            ApexPages.currentPage().getParameters().put('id',ListOfCases.get(0).id);
            // instantiate the Controller - Core_IPS_Internal_Case_Controller Apex Class
            Core_IPS_Interested_Party_Ext_Controller InterestedPartyExtCon = new Core_IPS_Interested_Party_Ext_Controller(new ApexPages.StandardController(ListOfCases.get(0)));
            Core_IPS_Interested_Party_Ext_Controller.IPWrapper IpWrapClass = new  Core_IPS_Interested_Party_Ext_Controller.IPWrapper(ConRec, UsrRec);
            InterestedPartyExtCon.searchText = '*';
            PageReference pageRef1 = InterestedPartyExtCon.doSearch();
            System.assertEquals(null,pageRef1);
            InterestedPartyExtCon.IPRecordSet.get(0).isSelected = true;
            PageReference pageRef2 = InterestedPartyExtCon.AddSelectedContacts();
            System.assertEquals(null,pageRef2);
            PageReference pageRef3 =InterestedPartyExtCon.Finished();
            System.assertEquals('/'+ListOfCases.get(0).id,pageRef3.getUrl());
        }
        Test.stopTest();
    }
    static testmethod void AddExtIPbyExtUsr_CaseWithIpsProj(){
        getRecords();
        System.RunAs(ListOfExternalUsers.get(0)){            
            User UsrRec = new User();
            Contact ConRec = new Contact();     
            // Setting the Visualforce Page
            PageReference InterestedPartyExternalPage = Page.Core_IPS_Interested_Party_External;
            Test.setCurrentPage(InterestedPartyExternalPage);
            // Assigning parameters in the URL
            ApexPages.currentPage().getParameters().put('id',ListOfCases.get(0).id);
            ApexPages.currentPage().getParameters().put('mode','mip');
            // instantiate the Controller - Core_IPS_Internal_Case_Controller Apex Class
            Core_IPS_Interested_Party_Ext_Controller InterestedPartyExtCon = new Core_IPS_Interested_Party_Ext_Controller(new ApexPages.StandardController(ListOfCases.get(0)));
            Core_IPS_Interested_Party_Ext_Controller.IPWrapper IpWrapClass = new  Core_IPS_Interested_Party_Ext_Controller.IPWrapper(ConRec, UsrRec);
            InterestedPartyExtCon.searchText = '*';
            InterestedPartyExtCon.doSearch();
            //InterestedPartyExtCon.IPRecordSet.get(0).isSelected = true;
            InterestedPartyExtCon.AddSelectedContacts();
            //InterestedPartyExtCon.LinkedExternalParties.get(0).Active__c = false;
            InterestedPartyExtCon.removeSelectedContacts();
        }
    }
    static testmethod void DeleExtIPbyExtUsr_CaseWithIpsProj(){
        getRecords();
        System.RunAs(ListOfExternalUsers.get(0)){
            User UsrRec = new User();
            Contact ConRec = new Contact();
            system.debug('ListOfCases.get(0)====    '+ListOfCases.get(0));
            // Setting the Visualforce Page
            PageReference InterestedPartyExternalPage = Page.Core_IPS_Interested_Party_External;
            Test.setCurrentPage(InterestedPartyExternalPage);
            // Assigning parameters in the URL
            ApexPages.currentPage().getParameters().put('id',ListOfCases.get(0).id);
            ApexPages.currentPage().getParameters().put('mode','mip');
            // instantiate the Controller - Core_IPS_Internal_Case_Controller Apex Class
            Core_IPS_Interested_Party_Ext_Controller InterestedPartyExtCon = new Core_IPS_Interested_Party_Ext_Controller(new ApexPages.StandardController(ListOfCases.get(0)));
            Core_IPS_Interested_Party_Ext_Controller.IPWrapper IpWrapClass = new  Core_IPS_Interested_Party_Ext_Controller.IPWrapper(ConRec, UsrRec);
            InterestedPartyExtCon.searchText = '*';
            InterestedPartyExtCon.doSearch();
            
            Pagereference Pg = InterestedPartyExtCon.simpleSort();
            //InterestedPartyExtCon.IPRecordSet.get(0).isSelected = true;
            InterestedPartyExtCon.AddSelectedContacts();
            //InterestedPartyExtCon.LinkedExternalParties.get(0).Active__c = false;
            InterestedPartyExtCon.removeSelectedContacts();
            
            
        }
    }
    /*Ashutosh - US103988*/
    static testMethod void testSaveAndRedirect(){
        getRecords();
        PageReference InterestedPartyExternalPage = Page.Core_IPS_Interested_Party_External;
        Test.setCurrentPage(InterestedPartyExternalPage);
        // Assigning parameters in the URL
        ApexPages.currentPage().getParameters().put('id',ListOfCases.get(0).id);
        Core_IPS_Interested_Party_Ext_Controller InterestedPartyExtCon = new Core_IPS_Interested_Party_Ext_Controller(new ApexPages.StandardController(ListOfCases.get(0)));
        InterestedPartyExtCon.searchText = '*';
        InterestedPartyExtCon.doSearch();
        System.assertEquals(true,InterestedPartyExtCon.IPRecordSet.size()>0);
        System.assertEquals(true,InterestedPartyExtCon.LinkedExternalPartiesList.size() > 0);
        //Ashutosh-US103988
            InterestedPartyExtCon.IPRecordSet.get(0).isSelected = true;
            InterestedPartyExtCon.AddSelectedContacts();
            InterestedPartyExtCon.LinkedExternalPartiesList.get(0).isSelected = false;
            InterestedPartyExtCon.removeSelectedContacts();
            Pagereference Pg1 = InterestedPartyExtCon.saveAndRedirect();
        	System.assertEquals('/'+ListOfCases.get(0).id,Pg1.getUrl());
    }
}