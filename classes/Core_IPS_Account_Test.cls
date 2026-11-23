/***************************************************************************************************
Class Name:  Core_IPS_Account_Test
Class Type: Test Class 
Version     : 1.0 
Created Date: 1 Feb 2016
Function    : This class contains test coverage for Core_IPS_Account_Handler class
Input Parameters: None 
Output Parameters: None
Description:   This class contains unit test scenarios for Core_IPS_Account_Handler class
Used in     : None
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Deepak Jetty              02/02/2016                 Created
****************************************************************************************************/
@isTest
public class Core_IPS_Account_Test {
    //Instance variables that are commonly used in multiple test methods
    static List<User> ListOfUser = new List<User> ();
    /***************************************************************************************************
Method Name:  getRecords()
Method Type: void
Version     : 1.0 
Created Date: 02 Feb 2016
Description:  Common Test data used for all test methods
Scenario Type:  
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Deepak Jetty       02/02/2016              Created
****************************************************************************************************/
    static void getRecords (){
        // Query Profiles
        Map<String,ID> profiles = new Map<String,ID>();
        List<String> strProf = new List<String>();
        strProf.add('System Administrator');
        List<Profile> ProfileList = [select id, name from Profile where name IN : strProf];
        for(Profile prf : ProfileList){
            profiles.put(prf.name, prf.id);
        }
        //Create Role
        UserRole role = new UserRole();
        role.name='CEO';
        insert role;
        // Create Users
        ListOfUser = TestUtilities.getListOfUser(2);
        ListOfUser.get(0).ProfileID =  profiles.get('System Administrator');
        ListOfUser.get(1).ProfileID =  profiles.get('System Administrator');
        ListOfUser.get(1).UserRoleID = role.id;
        insert ListOfUser;
        System.assertEquals(ListOfUser.get(0).profileid, profiles.get('System Administrator'));
        System.assertEquals(ListOfUser.get(1).profileid, profiles.get('System Administrator'));
    }
    /***************************************************************************************************
Method Name:  InsertIPSAccountaddIPSUsersToProjectMembers_test
Method Type: Test Method
Version     : 1.0 
Created Date: 2 Feb 2016
Description:  Testing with Creating IPS Account with add IPS Users To ProjectMembers
Scenario Type:  Positive
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Deepak Jetty              02/02/2016                Created
****************************************************************************************************/ 
    static testmethod void InsertIPSAccountaddIPSUsersToProjectMembers_test(){
        getrecords();
        // Get intelSupportOwner Id (User Id)
        Id intelSupportOwner = ListOfUser.get(0).id;
        Map<String,ID> profiles = new Map<String,ID>();
        List<String> strProf = new List<String>();
        User portalUser = new User();
        // Create Accounts
        List<Account> ListOfAccounts = TestUtilities.getListOfAccounts(2);
        System.runAs(ListOfUser.get(0)){
            insert ListOfAccounts;
        }
        System.assert(ListOfAccounts[0].Id != null, 'Record not created');
        Integer Counter=0;
        // Create Contact
        List<Contact> ListOfContacts = TestUtilities.getListOfContact(2);
        for(Contact ContactRec : ListOfContacts){
            ContactRec.Core_IPS_Intel_Support_Owner__c = intelSupportOwner;
            ContactRec.Accountid = ListOfAccounts.get(Counter).Id;
            ContactRec.Core_IPS_Active__c = true;
            Counter++;
        }
        Counter=0;
        System.runAs(ListOfUser.get(0)){
            insert ListOfContacts;
        }
        System.assert(ListOfContacts[0].Id != null, 'Record not created');
        // Customer Profile Query
        Profile CustomerProfile = [select Id,name from Profile where UserType = 'PowerCustomerSuccess' limit 1];
        // Creating Customer User
        List<User> ListOfCustomerUsr = TestUtilities.getListOfUser(1);
        for(user ur:ListOfCustomerUsr){
            ur.UserName = 'TestCustomerUsr@intel.com';
            ur.ProfileID = CustomerProfile.id;
            ur.contactId = ListOfContacts.get(0).id;
        }
        System.runAs(listofuser[0]){
            insert ListOfCustomerUsr;
        }
        System.assertEquals(ListOfCustomerUsr[0].ProfileID, CustomerProfile.id);
        // Create Ips Project
        List<Core_IPS_Project__c> ListOfIpsProjects = TestUtilities.getListOfIpsProjects(3);
        ListOfIpsProjects[2].Core_MPNDA__c='123';
        // Create Ips Labels added by Aayushi for US79852
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
            if(IL.name=='Core_IPS_DuplicateAccount_Error'){
                IL.Value__c = 'Account already exists';
            }
            if(IL.name=='Core_IPS_MPNDAValue_Error'){
                IL.Value__c='You cannot enter an MPNDA value if an Account on the Project does not have a CNDA.';
            }
        }
        
        System.runAs(ListOfUser.get(0)){
            insert IPSLabels;
            insert ListOfIpsProjects;
        }
        
        System.assert(ListOfIpsProjects[0].Id != null, 'Record not created');
        System.debug('MPNDA Test1-->'+ListOfIpsProjects[0].Core_MPNDA__c+'<--MPNDA Test2-->'+ListOfIpsProjects[1].Core_MPNDA__c);
        // Create Ips Account
        List<Core_IPS_Account__c> ListOfIpsAccounts = TestUtilities.getListOfIpsAccounts(2);
        for(Core_IPS_Account__c IpsAcc : ListOfIpsAccounts){
            if(counter<1){
                IpsAcc.Core_Account__c = ListOfAccounts.get(0).Id;
                IpsAcc.Core_IPS_Project__c = ListOfIpsProjects.get(0).Id;
            } else {
                IpsAcc.Core_Account__c = ListOfAccounts.get(1).Id;
                IpsAcc.Core_IPS_Project__c = ListOfIpsProjects.get(1).Id;
            }
            counter++;
        }
        counter = 0;
        Test.startTest();
        System.runAs(ListOfUser.get(0)){
            insert ListOfIpsAccounts;
        }
        System.assert(ListOfIpsAccounts[0].Id != null, 'Record not created');
        
        List<Core_Trigger_Executions__c> lstTriggerExecution  = new List<Core_Trigger_Executions__c>();
        Core_Trigger_Executions__c  TriggerExecution = new Core_Trigger_Executions__c();
        TriggerExecution.Name = 'checkDuplicateAccount';
        TriggerExecution.Core_Active__c = true;
        TriggerExecution.Core_Class_Name__c ='Core_IPS_Account_Handler';
        TriggerExecution.Core_Description__c = 'prevent duplicate account addition to project';
        TriggerExecution.Core_Object__c = 'Core_IPS_Account__c';
        TriggerExecution.Core_Trigger_Events__c = 'before insert';
        lstTriggerExecution.add(TriggerExecution);
        
        Core_Trigger_Executions__c  TriggerExecution1 = new Core_Trigger_Executions__c();
        TriggerExecution1.Name = 'preventMPNDAforNonNDAAccount';
        TriggerExecution1.Core_Active__c = true;
        TriggerExecution1.Core_Class_Name__c ='Core_IPS_Account_Handler';
        TriggerExecution1.Core_Description__c = 'Not be able to add/save an MPNDA value on a Project if the Account has no CNDA on its Account Record';
        TriggerExecution1.Core_Object__c = 'Core_IPS_Account__c';
        TriggerExecution1.Core_Trigger_Events__c = 'after insert';
        lstTriggerExecution.add(TriggerExecution1);
        
        System.runAs(ListOfUser.get(0)){
            insert lstTriggerExecution;
        } 
        //start add duplicate account on a project DE37603
        List<Core_IPS_Account__c> ListOfIpsAccountsDup = TestUtilities.getListOfIpsAccounts(1);
        for(Core_IPS_Account__c IpsAcc : ListOfIpsAccountsDup){
                IpsAcc.Core_Account__c = ListOfAccounts.get(0).Id;
                IpsAcc.Core_IPS_Project__c = ListOfIpsProjects.get(0).Id;
        }
        System.runAs(ListOfUser.get(0)){
            try{
            insert ListOfIpsAccountsDup;
            }catch(Exception ex){
            Boolean expectedExceptionThrown =  ex.getMessage().contains('Account already exists') ? true : false;
                System.assertEquals(expectedExceptionThrown, true);}
        }
        
        //end
        //
        //start prevent MPNDA value on project for Non NDA Account US103460
        List<Core_IPS_Account__c> ListOfIpsAccountsTest = TestUtilities.getListOfIpsAccounts(1);
        for(Core_IPS_Account__c IpsAcc : ListOfIpsAccountsTest){
            IpsAcc.Core_Account__c = ListOfAccounts.get(0).Id;
            IpsAcc.Core_IPS_Project__c = ListOfIpsProjects.get(2).Id;
        }
        System.runAs(ListOfUser.get(0)){
            try{
                insert ListOfIpsAccountsTest;
            }catch(Exception ex){
                Boolean expectedExceptionThrown =  ex.getMessage().contains('You cannot enter an MPNDA value if an Account on the Project does not have a CNDA.') ? true : false;
                System.assertEquals(expectedExceptionThrown, true);}
        }
       
        //end
        Test.stopTest();
    }
    /***************************************************************************************************
Method Name:  InsertAccountFAEtoProject_test
Method Type: Test Method
Version     : 1.0 
Created Date: 2 Feb 2016
Description:  Testing with Creating IPS Account by FAEtoProject
Scenario Type:  Positive
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Deepak Jetty              02/02/2016                Created
****************************************************************************************************/ 
    static testmethod void InsertAccountFAEtoProject_test(){
        getrecords();
        // Get intelSupportOwner Id (User Id)
        Id intelSupportOwner = ListOfUser.get(1).id;
        Map<String,ID> profiles = new Map<String,ID>();
        List<String> strProf = new List<String>();
        User portalUser = new User();
        // Create Accounts
        List<Account> ListOfAccounts = TestUtilities.getListOfAccounts(2);
        System.runAs(ListOfUser.get(0)){
            insert ListOfAccounts;
            System.debug('**********Insert--->'+ListOfAccounts.get(0).Owner.UserRole.Name);
            for(Account Acc : ListOfAccounts){
                Acc.ownerid = ListOfUser.get(1).id;
                System.debug('**********Loop--->'+Acc.Owner.UserRole.Name);
            }
            update ListOfAccounts;
            System.debug('**********Update--->'+ListOfAccounts.get(0).Owner.UserRole.Name);
            List<AccountShare> ListOfAccountShare = [select UserOrGroupId,rowcause,CaseAccessLevel from AccountShare where AccountId =:ListOfAccounts];
            for(AccountShare Share : ListOfAccountShare){
                Share.CaseAccessLevel = 'Edit';
            }
            update ListOfAccountShare;
        }
        
        System.assert(ListOfAccounts[0].Id != null, 'Record not created');
        // Create Contact
        Integer Counter=0;
        List<Contact> ListOfContacts = TestUtilities.getListOfContact(1);
        for(Contact ContactRec : ListOfContacts){
            ContactRec.Core_IPS_Intel_Support_Owner__c = intelSupportOwner;
            ContactRec.Accountid = ListOfAccounts.get(Counter).Id;
            ContactRec.Core_IPS_Active__c = true;
            Counter++;
        }
        Counter=0;
        System.runAs(ListOfUser.get(0)){
            insert ListOfContacts;
        }
        System.assert(ListOfContacts[0].Id != null, 'Record not created');
        // Customer Profile Query
        Profile CustomerProfile = [select Id,name from Profile where UserType = 'PowerCustomerSuccess' limit 1];
        // Creating Customer User
        List<User> ListOfCustomerUsr = TestUtilities.getListOfUser(1);
        ListOfCustomerUsr.get(0).UserName = 'TestCustomerUsr@intel.com';
        ListOfCustomerUsr.get(0).ProfileID = CustomerProfile.id;
        ListOfCustomerUsr.get(0).contactId = ListOfContacts.get(0).id;
        System.runAs(listofuser[0]){
            insert ListOfCustomerUsr;
        }
        System.assertEquals(ListOfCustomerUsr[0].ProfileID, CustomerProfile.id);
        // Create Ips Project
        List<Core_IPS_Project__c> ListOfIpsProjects = TestUtilities.getListOfIpsProjects(2);
        // Create Ips Labels added by Aayushi for US79852
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
        System.runAs(ListOfUser.get(0)){
            insert IPSLabels;
            insert ListOfIpsProjects;
        }
        System.assert(ListOfIpsProjects[0].Id != null, 'Record not created');
        // Create Ips Account
        List<Core_IPS_Account__c> ListOfIpsAccounts = TestUtilities.getListOfIpsAccounts(2);
        for(Core_IPS_Account__c IpsAcc : ListOfIpsAccounts){
            if(counter<1){
                IpsAcc.Core_Account__c = ListOfAccounts.get(0).Id;
                IpsAcc.Core_IPS_Project__c = ListOfIpsProjects.get(0).Id;
            } else {
                IpsAcc.Core_Account__c = ListOfAccounts.get(0).Id;
                IpsAcc.Core_IPS_Project__c = ListOfIpsProjects.get(1).Id;
            }
            counter++;
        }
        counter = 0;
        /*Creating IPS Labels
        List<Core_IPS_Labels__c> IPSLables = TestUtilities.getIPSLabel();
        System.runAs(ListOfUser.get(0)){
            Insert IPSLables;
        }
        System.assert(IPSLables[0].Id != null, 'Record not created');*/
        Test.startTest();
        System.runAs(ListOfUser.get(0)){
            insert ListOfIpsAccounts;
        }
        System.assert(ListOfIpsAccounts[0].Id != null, 'Record not created');
        Test.stopTest();
    }
/***************************************************************************************************
Method Name:  DeleteIPSAccountNotNew_test
Method Type: Test Method
Version     : 1.0 
Created Date: 2 Feb 2016
Description:  Testing with Delete IPS Account of Project status Not New
Scenario Type:  Positive
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Deepak Jetty              02/02/2016                Created
****************************************************************************************************/ 
    static testmethod void DeleteIPSAccountNotNew_test(){
        getrecords();
        String ExceptionError;
        // Get intelSupportOwner Id (User Id)
        Id intelSupportOwner = ListOfUser.get(1).id;
        Map<String,ID> profiles = new Map<String,ID>();
        List<String> strProf = new List<String>();
        User portalUser = new User();
        // Create Accounts
        List<Account> ListOfAccounts = TestUtilities.getListOfAccounts(2);
        System.runAs(ListOfUser.get(0)){
            insert ListOfAccounts;
            System.debug('**********Insert--->'+ListOfAccounts.get(0).Owner.UserRole.Name);
            for(Account Acc : ListOfAccounts){
                Acc.ownerid = ListOfUser.get(1).id;
                System.debug('**********Loop--->'+Acc.Owner.UserRole.Name);
            }
            update ListOfAccounts;
            System.debug('**********Update--->'+ListOfAccounts.get(0).Owner.UserRole.Name);
            List<AccountShare> ListOfAccountShare = [select UserOrGroupId,rowcause,CaseAccessLevel from AccountShare where AccountId =:ListOfAccounts];
            for(AccountShare Share : ListOfAccountShare){
                Share.CaseAccessLevel = 'Edit';
            }
            update ListOfAccountShare;
        }
        
        System.assert(ListOfAccounts[0].Id != null, 'Record not created');
        Integer Counter=0;
        // Create Contact
        List<Contact> ListOfContacts = TestUtilities.getListOfContact(2);
        for(Contact ContactRec : ListOfContacts){
            ContactRec.Core_IPS_Intel_Support_Owner__c = intelSupportOwner;
            ContactRec.Accountid = ListOfAccounts.get(Counter).Id;
            ContactRec.Core_IPS_Active__c = true;
            Counter++;
        }
        Counter=0;
        System.runAs(ListOfUser.get(0)){
            insert ListOfContacts;
        }
        System.assert(ListOfContacts[0].Id != null, 'Record not created');
        // Customer Profile Query
        Profile CustomerProfile = [select Id,name from Profile where UserType = 'PowerCustomerSuccess' limit 1];
        // Creating Customer User
        List<User> ListOfCustomerUsr = TestUtilities.getListOfUser(1);
        for(User ur:ListOfCustomerUsr){
        ur.UserName = 'TestCustomerUsr@intel.com';
        ur.ProfileID = CustomerProfile.id;
        ur.contactId = ListOfContacts.get(0).id;
        }
        System.runAs(listofuser[0]){
            insert ListOfCustomerUsr;
        }
        System.assertEquals(ListOfCustomerUsr[0].ProfileID, CustomerProfile.id);
        // Create Ips Project
        List<Core_IPS_Project__c> ListOfIpsProjects = TestUtilities.getListOfIpsProjects(2);
        for(Core_IPS_Project__c proj:ListOfIpsProjects){
            //status changed to Draft for US79852
            proj.Core_Status__c = 'Draft';
        }
        List<Core_Trigger_Executions__c> lstTriggerExecution  = new List<Core_Trigger_Executions__c>();
        Core_Trigger_Executions__c  TriggerExecution = new Core_Trigger_Executions__c();
        TriggerExecution.Name = 'PreventDelete';
        TriggerExecution.Core_Active__c = true;
        TriggerExecution.Core_Class_Name__c ='Core_IPS_Account_Handler';
        TriggerExecution.Core_Description__c = 'Prevent Delete';
        TriggerExecution.Core_Object__c = 'Core_IPS_Account__c';
        TriggerExecution.Core_Trigger_Events__c = 'after update';
        lstTriggerExecution.add(TriggerExecution);
       
        System.runAs(ListOfUser.get(0)){
            insert lstTriggerExecution;
        } 
        // Create Ips Labels added by Aayushi for US79852
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
        System.runAs(ListOfUser.get(0)){
            insert IPSLabels;
            insert ListOfIpsProjects;
            //added by Aayushi to accomodate changes made in
            // US79853
          /*  TestUtilities.addAccMemProdToProject(ListOfIpsProjects);

            for(Core_IPS_Project__c proj:ListOfIpsProjects){
                proj.Core_Status__c = 'Active';
            }
            Update ListOfIpsProjects;*/
        }
        System.assert(ListOfIpsProjects[0].Id != null, 'Record not created');
        // Create Ips Account
        List<Core_IPS_Account__c> ListOfIpsAccounts = TestUtilities.getListOfIpsAccounts(2);
        for(Core_IPS_Account__c IpsAcc : ListOfIpsAccounts){
            if(counter<1){
                IpsAcc.Core_Account__c = ListOfAccounts.get(0).Id;
                IpsAcc.Core_IPS_Project__c = ListOfIpsProjects.get(0).Id;
            } else {
                IpsAcc.Core_Account__c = ListOfAccounts.get(0).Id;
                IpsAcc.Core_IPS_Project__c = ListOfIpsProjects.get(1).Id;
            }
            counter++;
        }
        counter = 0;
        /*Creating IPS Labels
        List<Core_IPS_Labels__c> IPSLables = TestUtilities.getIPSLabel();
        System.runAs(ListOfUser.get(0)){
            Insert IPSLables;
        }
        System.assert(IPSLables[0].Id != null, 'Record not created');*/
        System.runAs(ListOfUser.get(0)){
            insert ListOfIpsAccounts;
        }
        System.assert(ListOfIpsAccounts[0].Id != null, 'Record not created');
        Test.startTest();
        System.runAs(ListOfUser.get(0)){
            try{
                Delete ListOfIpsAccounts;
            } Catch (Exception e){
                ExceptionError = e.getMessage();
            }
        }
      //System.assert(ExceptionError.contains('Cannot delete this Account when status is either Submitted or Active'),'Prevent Delete Error not occured');
        Test.stopTest();
    }    
/***************************************************************************************************
Method Name:  DeleteIPSAccountNew_test
Method Type: Test Method
Version     : 1.0 
Created Date: 2 Feb 2016
Description:  Testing with Delete IPS Account of Project status Not New
Scenario Type:  Negative
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Deepak Jetty              02/02/2016                Created
****************************************************************************************************/ 
    static testmethod void DeleteIPSAccountNew_test(){
        getrecords();
        String ExceptionError;
        // Get intelSupportOwner Id (User Id)
        Id intelSupportOwner = ListOfUser.get(1).id;
        Map<String,ID> profiles = new Map<String,ID>();
        List<String> strProf = new List<String>();
        User portalUser = new User();
        // Create Accounts
        List<Account> ListOfAccounts = TestUtilities.getListOfAccounts(2);
        System.runAs(ListOfUser.get(0)){
            insert ListOfAccounts;
            for(Account Acc : ListOfAccounts){
                Acc.ownerid = ListOfUser.get(1).id;
            }
            update ListOfAccounts;
            List<AccountShare> ListOfAccountShare = [select UserOrGroupId,rowcause,CaseAccessLevel from AccountShare where AccountId =:ListOfAccounts];
            for(AccountShare Share : ListOfAccountShare){
                Share.CaseAccessLevel = 'Edit';
            }
            update ListOfAccountShare;
        }
        System.assert(ListOfAccounts[0].Id != null, 'Record not created');
        Integer Counter=0;
        // Create Contact
        List<Contact> ListOfContacts = TestUtilities.getListOfContact(2);
        for(Contact ContactRec : ListOfContacts){
            ContactRec.Core_IPS_Intel_Support_Owner__c = intelSupportOwner;
            ContactRec.Accountid = ListOfAccounts.get(Counter).Id;
            ContactRec.Core_IPS_Active__c = true;
            Counter++;
        }
        System.runAs(ListOfUser.get(0)){
            insert ListOfContacts;
        }
        Counter=0;
        System.assert(ListOfContacts[0].Id != null, 'Record not created');
        // Customer Profile Query
        Profile CustomerProfile = [select Id,name from Profile where UserType = 'PowerCustomerSuccess' limit 1];
        // Creating Customer User
        List<User> ListOfCustomerUsr = TestUtilities.getListOfUser(1);
        for(User ur:ListOfCustomerUsr){
            ur.UserName = 'TestCustomerUsr@intel.com';
            ur.ProfileID = CustomerProfile.id;
            ur.contactId = ListOfContacts.get(0).id;
        }
        System.runAs(listofuser[0]){
            insert ListOfCustomerUsr;
        }
        System.assertEquals(ListOfCustomerUsr[0].ProfileID, CustomerProfile.id);
        // Create Ips Project
        List<Core_IPS_Project__c> ListOfIpsProjects = TestUtilities.getListOfIpsProjects(2);
        List<Core_Trigger_Executions__c> lstTriggerExecution  = new List<Core_Trigger_Executions__c>();
        Core_Trigger_Executions__c  TriggerExecution = new Core_Trigger_Executions__c();
        TriggerExecution.Name = 'PreventDelete';
        TriggerExecution.Core_Active__c = true;
        TriggerExecution.Core_Class_Name__c ='Core_IPS_Account_Handler';
        TriggerExecution.Core_Description__c = 'Prevent Delete';
        TriggerExecution.Core_Object__c = 'Core_IPS_Account__c';
        TriggerExecution.Core_Trigger_Events__c = 'after update';
        lstTriggerExecution.add(TriggerExecution);
        
        System.runAs(ListOfUser.get(0)){
            insert lstTriggerExecution;
        } 
        // Create Ips Labels added by Aayushi for US79852
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
        System.runAs(ListOfUser.get(0)){
            Insert IPSLabels;
            insert ListOfIpsProjects;
        }
        System.assert(ListOfIpsProjects[0].Id != null, 'Record not created');
        // Create Ips Account
        List<Core_IPS_Account__c> ListOfIpsAccounts = TestUtilities.getListOfIpsAccounts(2);
        for(Core_IPS_Account__c IpsAcc : ListOfIpsAccounts){
            if(counter<1){
                IpsAcc.Core_Account__c = ListOfAccounts.get(0).Id;
                IpsAcc.Core_IPS_Project__c = ListOfIpsProjects.get(0).Id;
            } else {
                IpsAcc.Core_Account__c = ListOfAccounts.get(1).Id;
                IpsAcc.Core_IPS_Project__c = ListOfIpsProjects.get(1).Id;
            }
            counter++;
        }
        counter = 0;

        /*Creating IPS Labels
        List<Core_IPS_Labels__c> IPSLables = TestUtilities.getIPSLabel();
        System.runAs(ListOfUser.get(0)){
            Insert IPSLables;
        }
        System.assert(IPSLables[0].Id != null, 'Record not created');*/
        System.runAs(ListOfUser.get(0)){
            insert ListOfIpsAccounts;
        }
        System.assert(ListOfIpsAccounts[0].Id != null, 'Record not created');
        Test.startTest();
        System.runAs(ListOfUser.get(0)){
            Core_IPS_Account_Handler.PreventDelete(ListOfIpsAccounts);
            Delete ListOfIpsAccounts;
        }
        List<Core_IPS_Account__c> ListOfIPSAccounts_Delete = [select id from Core_IPS_Account__c where id IN: ListOfIpsAccounts];
        System.assert(ListOfIPSAccounts_Delete.isEmpty(), 'Record not deleted');
        Test.stopTest();
    }
    
    /***************************************************************************************************
    Method Name:  ActivateOrDeactivateProjectMembers_Test
    Method Type: Test Method
    Version     : 1.0 
    Created Date: 08 Nov 2017
    Description:  Test to activate/deactivate project members related to IPS Project Account
    Scenario Type:  
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Amritesh             11/08/2017                Created - US80097
    ****************************************************************************************************/ 
    static testmethod void ActivateOrDeactivateProjectMembers_Test(){
        getrecords();
        
        List<Core_Trigger_Executions__c> lstTriggerExecution  = new List<Core_Trigger_Executions__c>();
        Core_Trigger_Executions__c  TriggerExecution = new Core_Trigger_Executions__c();
        TriggerExecution.Name = 'ActivateOrDeactivateProjectMembers';
        TriggerExecution.Core_Active__c = true;
        TriggerExecution.Core_Class_Name__c ='Core_IPS_Account_Handler';
        TriggerExecution.Core_Description__c = 'Activate Or Deactivate Project Members';
        TriggerExecution.Core_Object__c = 'Core_IPS_Account__c';
        TriggerExecution.Core_Trigger_Events__c = 'after update';
        lstTriggerExecution.add(TriggerExecution);
        
        System.runAs(ListOfUser.get(0)){
            insert lstTriggerExecution;
        } 
        
        String ExceptionError;
        // Get intelSupportOwner Id (User Id)
        Id intelSupportOwner = ListOfUser.get(1).id;
        Map<String,ID> profiles = new Map<String,ID>();
        List<String> strProf = new List<String>();
        User portalUser = new User();
        // Create Accounts
        List<Account> ListOfAccounts = TestUtilities.getListOfAccounts(2);
        System.runAs(ListOfUser.get(0)){
            insert ListOfAccounts;
            for(Account Acc : ListOfAccounts){
                Acc.ownerid = ListOfUser.get(1).id;
            }
            update ListOfAccounts;
            List<AccountShare> ListOfAccountShare = [select UserOrGroupId,rowcause,CaseAccessLevel from AccountShare where AccountId =:ListOfAccounts];
            for(AccountShare Share : ListOfAccountShare){
                Share.CaseAccessLevel = 'Edit';
            }
            update ListOfAccountShare;
        }
        System.assert(ListOfAccounts[0].Id != null, 'Record not created');
        Integer Counter=0;
        // Create Contact
        List<Contact> ListOfContacts = TestUtilities.getListOfContact(2);
        for(Contact ContactRec : ListOfContacts){
            ContactRec.Core_IPS_Intel_Support_Owner__c = intelSupportOwner;
            ContactRec.Accountid = ListOfAccounts.get(Counter).Id;
            ContactRec.Core_IPS_Active__c = true;
            Counter++;
        }
        System.runAs(ListOfUser.get(0)){
            insert ListOfContacts;
        }
        Counter=0;
        System.assert(ListOfContacts[0].Id != null, 'Record not created');
        // Customer Profile Query
        Profile CustomerProfile = [select Id,name from Profile where UserType = 'PowerCustomerSuccess' limit 1];
        // Creating Customer User
        List<User> ListOfCustomerUsr = TestUtilities.getListOfUser(1);
        for(User ur:ListOfCustomerUsr){
            ur.UserName = 'TestCustomerUsr@intel.com';
            ur.ProfileID = CustomerProfile.id;
            ur.contactId = ListOfContacts.get(0).id;
        }
        System.runAs(listofuser[0]){
            insert ListOfCustomerUsr;
        }
        System.assertEquals(ListOfCustomerUsr[0].ProfileID, CustomerProfile.id);
        // Create Ips Project
        List<Core_IPS_Project__c> ListOfIpsProjects = TestUtilities.getListOfIpsProjects(2);
        // Create Ips Labels added by Aayushi for US79852
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
        System.runAs(ListOfUser.get(0)){
            Insert IPSLabels;
            insert ListOfIpsProjects;
        }
        System.assert(ListOfIpsProjects[0].Id != null, 'Record not created');
        // Create Ips Account
        List<Core_IPS_Account__c> ListOfIpsAccounts = TestUtilities.getListOfIpsAccounts(2);
        for(Core_IPS_Account__c IpsAcc : ListOfIpsAccounts){
            if(counter<1){
                IpsAcc.Core_Account__c = ListOfAccounts.get(0).Id;
                IpsAcc.Core_IPS_Project__c = ListOfIpsProjects.get(0).Id;
            } else {
                IpsAcc.Core_Account__c = ListOfAccounts.get(1).Id;
                IpsAcc.Core_IPS_Project__c = ListOfIpsProjects.get(1).Id;
            }
            counter++;
        }
        counter = 0;

        System.runAs(ListOfUser.get(0)){
            insert ListOfIpsAccounts;
        }
        System.assert(ListOfIpsAccounts[0].Id != null, 'Record not created');
        Test.startTest();
        for(Core_IPS_Account__c objProjAcc : ListOfIpsAccounts) {
            objProjAcc.Core_Status__c = 'Inactive';
        }
        System.runAs(ListOfUser.get(0)){
            update ListOfIpsAccounts;
        }
        for(Core_IPS_Account__c objProjAcc : ListOfIpsAccounts) {
            objProjAcc.Core_Status__c = 'Active';
        }
        System.runAs(ListOfUser.get(0)){
            update ListOfIpsAccounts;
        }
        Test.stopTest();
    }
}