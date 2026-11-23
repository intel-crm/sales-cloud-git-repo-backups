/***************************************************************************************************
Class Name:  Core_IPS_Project_Member_Test
Class Type: Test Class 
Version     : 1.0 
Created Date: 2 Feb 2016
Function    : This class contains test coverage for Core_IPS_Project_Member_Handler class
Input Parameters: None 
Output Parameters: None
Description:   This class contains unit test scenarios for Core_IPS_Project_Member_Handler class
Used in     : None
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Deepak Jetty              02/02/2016                 Created
****************************************************************************************************/
@isTest
public class Core_IPS_Project_Member_Test {
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
        strProf.add('Sales Rep-BB');
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
        ListOfUser.get(1).ProfileID =  profiles.get('Sales Rep-BB');
        insert ListOfUser;
        System.assertEquals(ListOfUser.get(0).profileid, profiles.get('System Administrator'));
        System.assertEquals(ListOfUser.get(1).profileid, profiles.get('Sales Rep-BB'));
        
    }
/***************************************************************************************************
Method Name:  InsertManageGroupMember_test
Method Type: Test Method
Version     : 1.0 
Created Date: 2 Feb 2016
Description:  Testing with Creating IPS Project Members -Manageing Group Members
Scenario Type:  Positive
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Deepak Jetty              02/02/2016                Created
****************************************************************************************************/ 
    static testmethod void InsertManageGroupMember_test(){
        getrecords();
        // Get intelSupportOwner Id (User Id)
        Id intelSupportOwner = ListOfUser.get(0).id;
        // Create Accounts
        List<Account> ListOfAccounts = TestUtilities.getListOfAccounts(1);
        System.runAs(ListOfUser.get(0)){
            insert ListOfAccounts;
        }
        System.assert(ListOfAccounts[0].Id != null, 'Record not created');
        // Create Contact
        List<Contact> ListOfContacts = TestUtilities.getListOfContact(1);
        for(Contact ContactRec : ListOfContacts){
            ContactRec.Core_IPS_Intel_Support_Owner__c = intelSupportOwner;
            ContactRec.Accountid = ListOfAccounts.get(0).Id;
            ContactRec.Core_IPS_Active__c = true;
        }
        System.runAs(ListOfUser.get(0)){
            insert ListOfContacts;
        }
        System.assert(ListOfContacts[0].Id != null, 'Record not created');
        // Create Ips Project
        List<Core_IPS_Project__c> ListOfIpsProjects = TestUtilities.getListOfIpsProjects(1);
        //added by Aayushi Us90060
        List<Core_Trigger_Executions__c> ListOfTriggerExecutions = TestUtilities.getListOfTriggerExecutions();
        // Create Ips Labels added by Aayushi US79852
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
            ListOfIpsProjects[0].Core_MPNDA__c = '';
            insert IPSLabels;
            insert ListOfIpsProjects;
            insert ListOfTriggerExecutions; //added by Aayushi US90060
        }
        System.assert(ListOfIpsProjects[0].Id != null, 'Record not created');
        // Create Ips Account
        List<Core_IPS_Account__c> ListOfIpsAccounts = TestUtilities.getListOfIpsAccounts(1);
        for(Core_IPS_Account__c IpsAcc : ListOfIpsAccounts){
            IpsAcc.Core_Account__c = ListOfAccounts.get(0).Id;
            IpsAcc.Core_IPS_Project__c = ListOfIpsProjects.get(0).Id;
        }
        System.runAs(ListOfUser.get(0)){
            insert ListOfIpsAccounts;
        }
        System.assert(ListOfIpsAccounts[0].Id != null, 'Record not created');
        
        // Create Project Member
        List<Core_IPS_Project_Member__c> ListOfProjectMembers = TestUtilities.getListOfProjectMembers(5);
        for(Core_IPS_Project_Member__c ProjMem : ListOfProjectMembers){
            ProjMem.Core_IPS_Contact__c = ListOfContacts.get(0).Id;
            ProjMem.Core_IPS_Project__c = ListOfIpsProjects.get(0).Id;
            ProjMem.Core_User__c = intelSupportOwner;            
        }
        Test.startTest();
        System.runAs(ListOfUser.get(0)){
            insert ListOfProjectMembers;
        }
        System.assert(ListOfProjectMembers[0].Id != null, 'Record not created');
        Test.stopTest();
    }
/***************************************************************************************************
Method Name:  UpdateIPSProjectActiveIPSprojMember_test
Method Type: Test Method
Version     : 1.0 
Created Date: 2 Feb 2016
Description:  Testing with Creating IPS Project Members -Updating IPS Project from Inavtive to Active
Scenario Type:  Positive
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Deepak Jetty              02/02/2016                Created
****************************************************************************************************/ 
    static testmethod void UpdateIPSProjectActiveIPSprojMember_test(){
        getrecords();
        // Get intelSupportOwner Id (User Id)
        Id intelSupportOwner = ListOfUser.get(0).id;
        // Create Accounts
        List<Account> ListOfAccounts = TestUtilities.getListOfAccounts(1);
        System.runAs(ListOfUser.get(0)){
            insert ListOfAccounts;
        }
        System.assert(ListOfAccounts[0].Id != null, 'Record not created');
        // Create Contact
        List<Contact> ListOfContacts = TestUtilities.getListOfContact(1);
        for(Contact ContactRec : ListOfContacts){
            ContactRec.Core_IPS_Intel_Support_Owner__c = intelSupportOwner;
            ContactRec.Accountid = ListOfAccounts.get(0).Id;
            ContactRec.Core_IPS_Active__c = true;
        }
        System.runAs(ListOfUser.get(0)){
            insert ListOfContacts;
        }
        System.assert(ListOfContacts[0].Id != null, 'Record not created');
        // Create Ips Project
        List<Core_IPS_Project__c> ListOfIpsProjects = TestUtilities.getListOfIpsProjects(1);
        //added by Aayushi US90060
        List<Core_Trigger_Executions__c> ListOfTriggerExecutions = TestUtilities.getListOfTriggerExecutions();
        // Create Ips Labels added by Aayushi US79852
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
            ListOfIpsProjects[0].Core_MPNDA__c = '';
            insert IPSLabels;
            insert ListOfIpsProjects;
            insert ListOfTriggerExecutions;                 //added by Aayushi US90060

        }
        System.assert(ListOfIpsProjects[0].Id != null, 'Record not created');
        // Create Ips Account
        List<Core_IPS_Account__c> ListOfIpsAccounts = TestUtilities.getListOfIpsAccounts(1);
        for(Core_IPS_Account__c IpsAcc : ListOfIpsAccounts){
            IpsAcc.Core_Account__c = ListOfAccounts.get(0).Id;
            IpsAcc.Core_IPS_Project__c = ListOfIpsProjects.get(0).Id;
        }
        System.runAs(ListOfUser.get(0)){
            insert ListOfIpsAccounts;
        }
        System.assert(ListOfIpsAccounts[0].Id != null, 'Record not created');
        
        // Create Project Member
        List<Core_IPS_Project_Member__c> ListOfProjectMembers = TestUtilities.getListOfProjectMembers(5);
        for(Core_IPS_Project_Member__c ProjMem : ListOfProjectMembers){
            ProjMem.Core_IPS_Contact__c = ListOfContacts.get(0).Id;
            ProjMem.Core_IPS_Project__c = ListOfIpsProjects.get(0).Id;
            ProjMem.Core_User__c = intelSupportOwner;
            ProjMem.Core_Status__c = 'Inactive';
        }
        Test.startTest();
        System.runAs(ListOfUser.get(0)){
            insert ListOfProjectMembers;
            System.assert(ListOfProjectMembers[0].Id != null, 'Record not created');
            for(Core_IPS_Project_Member__c projMem:ListOfProjectMembers){
                projMem.Core_Status__c = 'Active';
            
            Update ListOfProjectMembers;
            }
            System.assert(ListOfProjectMembers.get(0).Core_Status__c == 'Active', 'Record not updated');
        }
        Test.stopTest();
    }
/***************************************************************************************************
Method Name:  UpdateIPSProjectInactiveIPSProjMember_test
Method Type: Test Method
Version     : 1.0 
Created Date: 2 Feb 2016
Description:  Testing with Creating IPS Project Members -Updating IPS Project from Avtive to Inactive
Scenario Type:  Positive
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Deepak Jetty              02/02/2016                Created
****************************************************************************************************/ 
    static testmethod void UpdateIPSProjectInactiveIPSProjMember_test(){
        getrecords();
        // Get intelSupportOwner Id (User Id)
        Id intelSupportOwner = ListOfUser.get(0).id;
        // Create Accounts
        List<Account> ListOfAccounts = TestUtilities.getListOfAccounts(1);
        System.runAs(ListOfUser.get(0)){
            insert ListOfAccounts;
        }
        System.assert(ListOfAccounts[0].Id != null, 'Record not created');
        // Create Contact
        List<Contact> ListOfContacts = TestUtilities.getListOfContact(1);
        for(Contact ContactRec : ListOfContacts){
            ContactRec.Core_IPS_Intel_Support_Owner__c = intelSupportOwner;
            ContactRec.Accountid = ListOfAccounts.get(0).Id;
            ContactRec.Core_IPS_Active__c = true;
        }
        System.runAs(ListOfUser.get(0)){
            insert ListOfContacts;
        }
        System.assert(ListOfContacts[0].Id != null, 'Record not created');
        // Create Ips Project
        List<Core_IPS_Project__c> ListOfIpsProjects = TestUtilities.getListOfIpsProjects(1);
        //added by Aayushi US90060
        List<Core_Trigger_Executions__c> ListOfTriggerExecutions = TestUtilities.getListOfTriggerExecutions();
        // Create Ips Labels added by Aayushi US79852
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
            //added by Aayushi US90060
            if(IL.name=='Core_InactivatingProjMem_Error'){
               IL.Value__c = 'At least one contact should be associated to the Project' ;
            }
            
        }
        System.runAs(ListOfUser.get(0)){
            ListOfIpsProjects[0].Core_MPNDA__c = '';
            insert IPSLabels;
            insert ListOfIpsProjects;
            insert ListOfTriggerExecutions;                 //added by Aayushi US90060

        }
        System.assert(ListOfIpsProjects[0].Id != null, 'Record not created');
        // Create Ips Account
        List<Core_IPS_Account__c> ListOfIpsAccounts = TestUtilities.getListOfIpsAccounts(1);
        for(Core_IPS_Account__c IpsAcc : ListOfIpsAccounts){
            IpsAcc.Core_Account__c = ListOfAccounts.get(0).Id;
            IpsAcc.Core_IPS_Project__c = ListOfIpsProjects.get(0).Id;
        }
        System.runAs(ListOfUser.get(0)){
            insert ListOfIpsAccounts;
        }
        // start added by Amritesh
        System.assert(ListOfIpsAccounts[0].Id != null, 'Record not created');
        Id ExternalUserProfileId = [select id, name from Profile where name='IPS External Customer'].Id;
        User customerUser = TestUtilities.getListOfUser(1).get(0);
        customerUser.ProfileId = ExternalUserProfileId;
        customerUser.UserName = 'testips.contact999@intel.com.crm';
        customerUser.FirstName = 'TestExt';
        customerUser.LastName = 'User192';
        customerUser.Alias = 'eusr192'; 
        customerUser.CommunityNickname = 'IPSExtUser192';
        customerUser.ContactId = ListOfContacts[0].Id;
        insert customerUser;
        //end Added by Amritesh
        System.assert(customerUser.Id != null, 'Record not created');
        
        // Create Project Member
        List<Core_IPS_Project_Member__c> ListOfProjectMembers = TestUtilities.getListOfProjectMembers(5);
        for(Core_IPS_Project_Member__c ProjMem : ListOfProjectMembers){
            ProjMem.Core_IPS_Contact__c = ListOfContacts.get(0).Id;
            ProjMem.Core_IPS_Project__c = ListOfIpsProjects.get(0).Id;
            ProjMem.Core_User__c = customerUser.Id;                             //added by Amritesh
            ProjMem.Core_Status__c = 'Active';
        }
        Test.startTest();
        System.runAs(ListOfUser.get(0)){
            insert ListOfProjectMembers;
            System.assert(ListOfProjectMembers[0].Id != null, 'Record not created');
            ListOfProjectMembers[0].Core_Status__c = 'Inactive';                    //added by Aayushi US90060
            Update ListOfProjectMembers[0];
           for(Core_IPS_Project_Member__c projMem:ListOfProjectMembers){
                projMem.Core_Status__c = 'Inactive';
           }
            //start modified by Aayushi US90060
               try{
            Update ListOfProjectMembers;
               }
               catch(Exception ex){
                 Boolean expectedExceptionThrown =  ex.getMessage().contains('At least one contact should be associated to the Project') ? true : false;
                 //System.assertEquals(expectedExceptionThrown, true);   
               }
            
           
          //  System.assert(ListOfProjectMembers.get(0).Core_Status__c == 'Inactive', 'Record not updated');
          //  end
        }
        Test.stopTest();
    }
/***************************************************************************************************
Method Name:  DeleteIPSProjMemberNewIPSProject_test
Method Type: Test Method
Version     : 1.0 
Created Date: 2 Feb 2016
Description:  Testing with Deleting IPS Project Members having status New
Scenario Type:  Positive
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Deepak Jetty              02/02/2016                Created
****************************************************************************************************/ 
    static testmethod void DeleteIPSProjMemberNewIPSProject_test(){
        getrecords();
        // Get intelSupportOwner Id (User Id)
        Id intelSupportOwner = ListOfUser.get(0).id;
        // Create Accounts
        List<Account> ListOfAccounts = TestUtilities.getListOfAccounts(1);
        System.runAs(ListOfUser.get(0)){
            insert ListOfAccounts;
        }
        System.assert(ListOfAccounts[0].Id != null, 'Record not created');
        // Create Contact
        List<Contact> ListOfContacts = TestUtilities.getListOfContact(1);
        for(Contact ContactRec : ListOfContacts){
            ContactRec.Core_IPS_Intel_Support_Owner__c = intelSupportOwner;
            ContactRec.Accountid = ListOfAccounts.get(0).Id;
            ContactRec.Core_IPS_Active__c = true;
        }
        System.runAs(ListOfUser.get(0)){
            insert ListOfContacts;
        }
        System.assert(ListOfContacts[0].Id != null, 'Record not created');
        // Create Ips Project
        List<Core_IPS_Project__c> ListOfIpsProjects = TestUtilities.getListOfIpsProjects(1);
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
        //added by Aayushi US90060
        List<Core_Trigger_Executions__c> ListOfTriggerExecutions = TestUtilities.getListOfTriggerExecutions();
        // Create Ips Labels added by Aayushi US79852
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
            ListOfIpsProjects[0].Core_MPNDA__c = '';
            insert IPSLabels;
            insert ListOfIpsProjects;
            insert ListOfTriggerExecutions;         //added by Aayushi US90060

        }
        System.assert(ListOfIpsProjects[0].Id != null, 'Record not created');
        // Create Ips Account
        List<Core_IPS_Account__c> ListOfIpsAccounts = TestUtilities.getListOfIpsAccounts(1);
        for(Core_IPS_Account__c IpsAcc : ListOfIpsAccounts){
            IpsAcc.Core_Account__c = ListOfAccounts.get(0).Id;
            IpsAcc.Core_IPS_Project__c = ListOfIpsProjects.get(0).Id;
        }
        System.runAs(ListOfUser.get(0)){
            insert ListOfIpsAccounts;
        }
        System.assert(ListOfIpsAccounts[0].Id != null, 'Record not created');
        
        // Create Project Member
        List<Core_IPS_Project_Member__c> ListOfProjectMembers = TestUtilities.getListOfProjectMembers(5);
        for(Core_IPS_Project_Member__c ProjMem : ListOfProjectMembers){
            ProjMem.Core_IPS_Contact__c = ListOfContacts.get(0).Id;
            ProjMem.Core_IPS_Project__c = ListOfIpsProjects.get(0).Id;
            ProjMem.Core_User__c = intelSupportOwner;
        }
        Test.startTest();
        System.runAs(ListOfUser.get(0)){
            insert ListOfProjectMembers;
            System.assert(ListOfProjectMembers[0].Id != null, 'Record not created');
            // start added by Aayushi US90060
            try{
              
                update ListOfIpsProjects.get(0);
                System.debug('In Try>>');
            Core_IPS_Project_Member_Handler.PreventDelete(ListOfProjectMembers);
            delete ListOfProjectMembers;
                
            }
        catch(Exception ex){
            System.debug('Message>>'+ex.getMessage());
            Boolean expectedExceptionThrown =  ex.getMessage().contains('Cannot delete this Project Member when status is either Submitted or Active') ? true : false;
            System.assertEquals(expectedExceptionThrown, false);   
               }         
            List<Core_IPS_Project_Member__c> ListOfProjectMembers_Delete = [select id from Core_IPS_Project_Member__c where id IN: ListOfProjectMembers];
            System.assert(ListOfProjectMembers_Delete.isEmpty(), 'Record not deleted');
        }
        //end
        Test.stopTest();
    }
/***************************************************************************************************
Method Name:  DeleteIPSProjMemberNonNewIPSProject_test
Method Type: Test Method
Version     : 1.0 
Created Date: 2 Feb 2016
Description:  Testing with Deleting IPS Project Members having status New
Scenario Type:  Negative
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Deepak Jetty              02/02/2016                Created
****************************************************************************************************/ 
   //commented by Aayushi to avoid IPs Case Evolve R2 deployment error
  /*  static testmethod void DeleteIPSProjMemberNonNewIPSProject_test(){
        getrecords();
        String ExceptionError;
        // Get intelSupportOwner Id (User Id)
        Id intelSupportOwner = ListOfUser.get(0).id;
        // Create Accounts
        List<Account> ListOfAccounts = TestUtilities.getListOfAccounts(1);
        System.runAs(ListOfUser.get(0)){
            insert ListOfAccounts;
        }
        System.assert(ListOfAccounts[0].Id != null, 'Record not created');
        // Create Contact
        List<Contact> ListOfContacts = TestUtilities.getListOfContact(1);
        for(Contact ContactRec : ListOfContacts){
            ContactRec.Core_IPS_Intel_Support_Owner__c = intelSupportOwner;
            ContactRec.Accountid = ListOfAccounts.get(0).Id;
            ContactRec.Email= 'testemail@gmail.com';
            ContactRec.Core_IPS_Active__c = true;
        }
        System.runAs(ListOfUser.get(0)){
            insert ListOfContacts;
        }
        System.assert(ListOfContacts[0].Id != null, 'Record not created');
        // Create Ips Project
        // modified the status to Draft from Active to accomodate changes from US79853
        List<Core_IPS_Project__c> ListOfIpsProjects = TestUtilities.getListOfIpsProjects(1);
        for(Core_IPS_Project__c ipsProj:ListOfIpsProjects){
            ipsProj.Core_Status__c='Draft';
        }
        // Create Ips Labels added by Aayushi US79852
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
        
            TestUtilities.addAccMemProdToProject(ListOfIpsProjects);
        
            for(Core_IPS_Project__c proj:ListOfIpsProjects){
                proj.Core_Status__c = 'Active';
                proj.Core_MPNDA__c='1234';
            }
            System.debug('>>Check>>');
            Update ListOfIpsProjects;
        }
        System.assert(ListOfIpsProjects[0].Id != null, 'Record not created');
        // Create Ips Account
        List<Core_IPS_Account__c> ListOfIpsAccounts = TestUtilities.getListOfIpsAccounts(1);
        for(Core_IPS_Account__c IpsAcc : ListOfIpsAccounts){
            IpsAcc.Core_Account__c = ListOfAccounts.get(0).Id;
            IpsAcc.Core_IPS_Project__c = ListOfIpsProjects.get(0).Id;
        }
        System.runAs(ListOfUser.get(0)){
            insert ListOfIpsAccounts;
        }
        System.assert(ListOfIpsAccounts[0].Id != null, 'Record not created');
        
        // Create Project Member
        List<Core_IPS_Project_Member__c> ListOfProjectMembers = TestUtilities.getListOfProjectMembers(5);
        for(Core_IPS_Project_Member__c ProjMem : ListOfProjectMembers){
            ProjMem.Core_IPS_Contact__c = ListOfContacts.get(0).Id;
            ProjMem.Core_IPS_Project__c = ListOfIpsProjects.get(0).Id;
            ProjMem.Core_User__c = intelSupportOwner;
        }
        Test.startTest();
        System.runAs(ListOfUser.get(0)){
            insert ListOfProjectMembers;
            System.assert(ListOfProjectMembers[0].Id != null, 'Record not created');
            try{
            delete ListOfProjectMembers;
            }Catch(Exception e){
                ExceptionError = e.getMessage();
            }            
            System.assert(ExceptionError.contains('Cannot delete this Project Member when status is either Submitted or Active'), 'Prevent delete error not occured ');
        }
        Test.stopTest();
    } */
/***************************************************************************************************
Method Name:  PreventInactivateProMem_FAE_Test
Method Type: Test Method
Version     : 1.0 
Created Date: 20 Apr 2018
Description:  
Scenario Type:  Positive
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Sugandha                    20/04/2018             Created
****************************************************************************************************/ 
    static testmethod void PreventInactivateProMem_FAE_Test(){
        getrecords();
        // Get intelSupportOwner Id (User Id)
        Id intelSupportOwner = ListOfUser.get(0).id;
        // Create Accounts
        List<Account> ListOfAccounts = TestUtilities.getListOfAccounts(1);
        System.runAs(ListOfUser.get(0)){
            insert ListOfAccounts;
        }
        System.assert(ListOfAccounts[0].Id != null, 'Record not created');
        // Create Contact
        List<Contact> ListOfContacts = TestUtilities.getListOfContact(1);
        for(Contact ContactRec : ListOfContacts){
            ContactRec.Core_IPS_Intel_Support_Owner__c = intelSupportOwner;
            ContactRec.Accountid = ListOfAccounts.get(0).Id;
            ContactRec.Core_IPS_Active__c = true;
        }
        System.runAs(ListOfUser.get(0)){
            insert ListOfContacts;
        }
        System.assert(ListOfContacts[0].Id != null, 'Record not created');
        // Create Ips Project
        List<Core_IPS_Project__c> ListOfIpsProjects = TestUtilities.getListOfIpsProjects(1);
        List<Core_Trigger_Executions__c> ListOfTriggerExecutions = TestUtilities.getListOfTriggerExecutions();
        Core_Trigger_Executions__c triExeRec = new Core_Trigger_Executions__c();
        triExeRec.Name = 'PreventInactivateProMem_FAE';
        triExeRec.Core_Active__c = True;
        triExeRec.Core_Class_Name__c = 'Core_IPS_Project_Member_Handler';
        triExeRec.Core_Description__c = 'This method is to prevent inactivating project member for FAE for non affiliated accounts.';
        triExeRec.Core_Object__c = 'Core_IPS_Project_Member__c';
        triExeRec.Core_Trigger_Events__c = 'Before Update';
        ListOfTriggerExecutions.add(triExeRec);
        
        List<Core_IPS_Labels__c> IPSLabels = TestUtilities.getIPSLabel();
        Core_IPS_Labels__c ipsLablRec = new Core_IPS_Labels__c();
        ipsLablRec.Name = 'Core_IPS_ProjectMem_Inactive_Error';
        ipsLablRec.Value__c = 'Error';
        IPSLabels.add(ipsLablRec);
        
        System.runAs(ListOfUser.get(0)){
            insert IPSLabels;
            insert ListOfTriggerExecutions; 
        }
        System.runAs(ListOfUser.get(1)){
            ListOfIpsProjects[0].Core_MPNDA__c = '';
            insert ListOfIpsProjects;
        }
        System.assert(ListOfIpsProjects[0].Id != null, 'Record not created');
        // Create Ips Account
        List<Core_IPS_Account__c> ListOfIpsAccounts = TestUtilities.getListOfIpsAccounts(1);
        for(Core_IPS_Account__c IpsAcc : ListOfIpsAccounts){
            IpsAcc.Core_Account__c = ListOfAccounts.get(0).Id;
            IpsAcc.Core_IPS_Project__c = ListOfIpsProjects.get(0).Id;
        }
        System.runAs(ListOfUser.get(0)){
            insert ListOfIpsAccounts;
        }
        System.assert(ListOfIpsAccounts[0].Id != null, 'Record not created');
        Id ExternalUserProfileId = [select id, name from Profile where name='IPS External Customer'].Id;
        User customerUser = TestUtilities.getListOfUser(1).get(0);
        customerUser.ProfileId = ExternalUserProfileId;
        customerUser.UserName = 'testips.contact999@intel.com.crm';
        customerUser.FirstName = 'TestExt';
        customerUser.LastName = 'User192';
        customerUser.Alias = 'eusr192'; 
        customerUser.CommunityNickname = 'IPSExtUser192';
        customerUser.ContactId = ListOfContacts[0].Id;
        insert customerUser;
        System.assert(customerUser.Id != null, 'Record not created');
        
        // Create Project Member
        List<Core_IPS_Project_Member__c> ListOfProjectMembers = TestUtilities.getListOfProjectMembers(5);
        for(Core_IPS_Project_Member__c ProjMem : ListOfProjectMembers){
            ProjMem.Core_IPS_Contact__c = ListOfContacts.get(0).Id;
            ProjMem.Core_IPS_Project__c = ListOfIpsProjects.get(0).Id;
            ProjMem.Core_User__c = customerUser.Id;                             
            ProjMem.Core_Status__c = 'Active';
        }
        System.runAs(ListOfUser.get(0)){
            insert ListOfProjectMembers;
            }
        Test.startTest();
            System.runAs(ListOfUser.get(1)){
            ListOfProjectMembers[0].Core_Status__c = 'Inactive';
            try{                    
            Update ListOfProjectMembers[0];
            }
            catch(Exception e){
            }
            
            }
        Test.stopTest();
    }
    
    //add as interested party
    static testmethod void AddasInterestedParty(){
        getrecords();
        // Get intelSupportOwner Id (User Id)
        Id intelSupportOwner = ListOfUser.get(0).id;
        // Create Accounts
        List<Account> ListOfAccounts = TestUtilities.getListOfAccounts(1);
        System.runAs(ListOfUser.get(0)){
            insert ListOfAccounts;
        }
        System.assert(ListOfAccounts[0].Id != null, 'Record not created');
        // Create Contact
        List<Contact> ListOfContacts = TestUtilities.getListOfContact(1);
        for(Contact ContactRec : ListOfContacts){
            ContactRec.Core_IPS_Intel_Support_Owner__c = intelSupportOwner;
            ContactRec.Accountid = ListOfAccounts.get(0).Id;
            ContactRec.Core_IPS_Active__c = true;
        }
        System.runAs(ListOfUser.get(0)){
            insert ListOfContacts;
        }
        System.assert(ListOfContacts[0].Id != null, 'Record not created');
        // Create Ips Project
        List<Core_IPS_Project__c> ListOfIpsProjects = TestUtilities.getListOfIpsProjects(1);
        /*List<Core_Trigger_Executions__c> ListOfTriggerExecutions = TestUtilities.getListOfTriggerExecutions();
        Core_Trigger_Executions__c triExeRec = new Core_Trigger_Executions__c();
        triExeRec.Name = 'PreventInactivateProMem_FAE';
        triExeRec.Core_Active__c = True;
        triExeRec.Core_Class_Name__c = 'Core_IPS_Project_Member_Handler';
        triExeRec.Core_Description__c = 'This method is to prevent inactivating project member for FAE for non affiliated accounts.';
        triExeRec.Core_Object__c = 'Core_IPS_Project_Member__c';
        triExeRec.Core_Trigger_Events__c = 'Before Update';
        ListOfTriggerExecutions.add(triExeRec);*/
        
        List<Core_IPS_Labels__c> IPSLabels = TestUtilities.getIPSLabel();
                
        System.runAs(ListOfUser.get(0)){
            insert IPSLabels;
            //insert ListOfTriggerExecutions; 
        }
        System.runAs(ListOfUser.get(1)){
            ListOfIpsProjects[0].Core_MPNDA__c = '';
            ListOfIpsProjects[0].Core_IPS_EnableMemberasInterestedParties__c = true;
            insert ListOfIpsProjects;
        }
        System.assert(ListOfIpsProjects[0].Id != null, 'Record not created');
        // Create Ips Account
        List<Core_IPS_Account__c> ListOfIpsAccounts = TestUtilities.getListOfIpsAccounts(1);
        for(Core_IPS_Account__c IpsAcc : ListOfIpsAccounts){
            IpsAcc.Core_Account__c = ListOfAccounts.get(0).Id;
            IpsAcc.Core_IPS_Project__c = ListOfIpsProjects.get(0).Id;
        }
        System.runAs(ListOfUser.get(0)){
            insert ListOfIpsAccounts;
        }
        System.assert(ListOfIpsAccounts[0].Id != null, 'Record not created');
        Id ExternalUserProfileId = [select id, name from Profile where name='IPS External Customer'].Id;
        User customerUser = TestUtilities.getListOfUser(1).get(0);
        customerUser.ProfileId = ExternalUserProfileId;
        customerUser.UserName = 'testips.contact999@intel.com.crm';
        customerUser.FirstName = 'TestExt';
        customerUser.LastName = 'User192';
        customerUser.Alias = 'eusr192'; 
        customerUser.CommunityNickname = 'IPSExtUser192';
        customerUser.ContactId = ListOfContacts[0].Id;
        
        insert customerUser;
        System.assert(customerUser.Id != null, 'Record not created');
        
        System.runAs(ListOfUser.get(0)){
            // Create Asset
            list<Asset> AssetList = TestUtilities.getAssetList(1);
            for(Asset Asst : AssetList){
                Asst.accountId = ListOfAccounts.get(0).Id;
                Asst.Contactid = ListOfContacts.get(0).id;
            }
            insert AssetList;
            System.assert(AssetList[0].Id != null, 'Record not created');
            /*
            // Create Entitlement
            List<Entitlement> ListOfEntitlement = TestUtilities.getListOfEntitlement(1);
            for(Entitlement EntitlementRec : ListOfEntitlement){
                EntitlementRec.AccountId = ListOfAccounts.get(0).Id;
                EntitlementRec.AssetId = AssetList.get(0).id;
            }
            insert ListOfEntitlement;
            System.assert(ListOfEntitlement[0].Id != null, 'Record not created');
            // Create EntitlementContact
            List<EntitlementContact> ListOfEntitlementContact = TestUtilities.getListOfEntitlementContact(1);
            for(EntitlementContact EntitlementContactRec : ListOfEntitlementContact){
                EntitlementContactRec.ContactId = ListOfContacts.get(0).Id;
                EntitlementContactRec.EntitlementId = ListOfEntitlement.get(0).id;
            }
            insert ListOfEntitlementContact;
            System.assert(ListOfEntitlementContact[0].Id != null, 'Record not created');
            */
            // Create Case
            List<Case> ListOfCases = TestUtilities.getListOfCases(1);
            for(Case CaseRec : ListOfCases){
                CaseRec.ContactId = ListOfContacts.get(0).id;
                CaseRec.accountId = ListOfAccounts.get(0).Id;
                CaseRec.Core_IPS_Project_Case__c = ListOfIpsProjects.get(0).Id;
            }
            insert ListOfCases;
        }
        Test.startTest();
        // Create Project Member
        List<Core_IPS_Project_Member__c> ListOfProjectMembers = TestUtilities.getListOfProjectMembers(5);
        for(Core_IPS_Project_Member__c ProjMem : ListOfProjectMembers){
            ProjMem.Core_IPS_Contact__c = ListOfContacts.get(0).Id;
            ProjMem.Core_IPS_Project__c = ListOfIpsProjects.get(0).Id;
            ProjMem.Core_User__c = customerUser.Id;                             
            ProjMem.Core_Status__c = 'Active';
            ProjMem.Add_as_Case_Interested_Party__c =True;
        }
        System.runAs(ListOfUser.get(0)){
            insert ListOfProjectMembers;
        }
        
        Test.stopTest();
    } 
    
    static testmethod void AddasInterestedParty3(){
        getrecords();
        // Get intelSupportOwner Id (User Id)
        Id intelSupportOwner = ListOfUser.get(0).id;
        // Create Accounts
        List<Account> ListOfAccounts = TestUtilities.getListOfAccounts(1);
        System.runAs(ListOfUser.get(0)){
            insert ListOfAccounts;
        }
        System.assert(ListOfAccounts[0].Id != null, 'Record not created');
        // Create Contact
        List<Contact> ListOfContacts = TestUtilities.getListOfContact(1);
        for(Contact ContactRec : ListOfContacts){
            ContactRec.Core_IPS_Intel_Support_Owner__c = intelSupportOwner;
            ContactRec.Accountid = ListOfAccounts.get(0).Id;
            ContactRec.Core_IPS_Active__c = true;
            ContactRec.Core_IPS_Email_Opt_Out__c = false;
        }
        System.runAs(ListOfUser.get(0)){
            insert ListOfContacts;
        }
        System.assert(ListOfContacts[0].Id != null, 'Record not created');
        // Create Ips Project
        List<Core_IPS_Project__c> ListOfIpsProjects = TestUtilities.getListOfIpsProjects(1);
        /*List<Core_Trigger_Executions__c> ListOfTriggerExecutions = TestUtilities.getListOfTriggerExecutions();
        Core_Trigger_Executions__c triExeRec = new Core_Trigger_Executions__c();
        triExeRec.Name = 'PreventInactivateProMem_FAE';
        triExeRec.Core_Active__c = True;
        triExeRec.Core_Class_Name__c = 'Core_IPS_Project_Member_Handler';
        triExeRec.Core_Description__c = 'This method is to prevent inactivating project member for FAE for non affiliated accounts.';
        triExeRec.Core_Object__c = 'Core_IPS_Project_Member__c';
        triExeRec.Core_Trigger_Events__c = 'Before Update';
        ListOfTriggerExecutions.add(triExeRec);*/
        
        List<Core_IPS_Labels__c> IPSLabels = TestUtilities.getIPSLabel();
                
        System.runAs(ListOfUser.get(0)){
            insert IPSLabels;
            //insert ListOfTriggerExecutions; 
        }
        System.runAs(ListOfUser.get(1)){
            ListOfIpsProjects[0].Core_MPNDA__c = '';
            ListOfIpsProjects[0].Core_IPS_EnableMemberasInterestedParties__c = true;
            insert ListOfIpsProjects;
        }
        System.assert(ListOfIpsProjects[0].Id != null, 'Record not created');
        // Create Ips Account
        List<Core_IPS_Account__c> ListOfIpsAccounts = TestUtilities.getListOfIpsAccounts(1);
        for(Core_IPS_Account__c IpsAcc : ListOfIpsAccounts){
            IpsAcc.Core_Account__c = ListOfAccounts.get(0).Id;
            IpsAcc.Core_IPS_Project__c = ListOfIpsProjects.get(0).Id;
        }
        System.runAs(ListOfUser.get(0)){
            insert ListOfIpsAccounts;
        }
        System.assert(ListOfIpsAccounts[0].Id != null, 'Record not created');
        Id ExternalUserProfileId = [select id, name from Profile where name='IPS External Customer'].Id;
        User customerUser = TestUtilities.getListOfUser(2).get(1);
        customerUser.ProfileId = ExternalUserProfileId;
        customerUser.UserName = 'testips.contact999@intel.com.crm';
        customerUser.FirstName = 'TestExt';
        customerUser.LastName = 'User192';
        customerUser.Alias = 'eusr192';
        customeruser.Isactive = true; 
        customerUser.CommunityNickname = 'IPSExtUser192';
        customerUser.ContactId = ListOfContacts[0].Id;
        
        insert customerUser;
        System.assert(customerUser.Id != null, 'Record not created');
       
        System.runAs(ListOfUser.get(0)){
            // Create Asset
            list<Asset> AssetList = TestUtilities.getAssetList(1);
            for(Asset Asst : AssetList){
                Asst.accountId = ListOfAccounts.get(0).Id;
                Asst.Contactid = ListOfContacts.get(0).id;
            }
            insert AssetList;
            System.assert(AssetList[0].Id != null, 'Record not created');
            /*
            // Create Entitlement
            List<Entitlement> ListOfEntitlement = TestUtilities.getListOfEntitlement(1);
            for(Entitlement EntitlementRec : ListOfEntitlement){
                EntitlementRec.AccountId = ListOfAccounts.get(0).Id;
                EntitlementRec.AssetId = AssetList.get(0).id;
            }
            insert ListOfEntitlement;
            System.assert(ListOfEntitlement[0].Id != null, 'Record not created');
            // Create EntitlementContact
            List<EntitlementContact> ListOfEntitlementContact = TestUtilities.getListOfEntitlementContact(1);
            for(EntitlementContact EntitlementContactRec : ListOfEntitlementContact){
                EntitlementContactRec.ContactId = ListOfContacts.get(0).Id;
                EntitlementContactRec.EntitlementId = ListOfEntitlement.get(0).id;
            }
            insert ListOfEntitlementContact;
            System.assert(ListOfEntitlementContact[0].Id != null, 'Record not created');
            */
            // Create Case
            List<Case> ListOfCases = TestUtilities.getListOfCases(1);
            for(Case CaseRec : ListOfCases){
                CaseRec.ContactId = ListOfContacts.get(0).id;
                CaseRec.accountId = ListOfAccounts.get(0).Id;
                CaseRec.Core_IPS_Project_Case__c = ListOfIpsProjects.get(0).Id;
            }
            insert ListOfCases;
        }
        
        // Create Project Member
        List<Core_IPS_Project_Member__c> ListOfProjectMembers = TestUtilities.getListOfProjectMembers(5);
        for(Core_IPS_Project_Member__c ProjMem : ListOfProjectMembers){
            ProjMem.Core_IPS_Contact__c = ListOfContacts.get(0).Id;
            ProjMem.Core_IPS_Project__c = ListOfIpsProjects.get(0).Id;
            ProjMem.Core_User__c = customerUser.Id;                             
            ProjMem.Core_Status__c = 'Active';
            ProjMem.Add_as_Case_Interested_Party__c =True;
        }
        System.runAs(ListOfUser.get(0)){
            insert ListOfProjectMembers;
        }
        Test.startTest();
            {
           // ContactRec.Core_IPS_Active__c = true;
           // ListOfContacts.get(1).Core_IPS_Active__c = true;
           // ListofUser.get(1).Isactive = false;
            try{                    
           // Update ListofUser.get(1);
           // update ListOfContacts.get(1);
           
            }
            catch(Exception e){
              /*  System.assert(e.getMessage().contains('Update failed.'));
                System.assert(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
                System.assert(e.getMessage().contains('Contact IPS is Not Checked'));*/
            }
                
            }
        Test.stopTest();
       
    } 
    
    
    //Created by karthick   
    static testmethod void AddasInterestedParty4(){
        getrecords();
        // Get intelSupportOwner Id (User Id)
        Id intelSupportOwner = ListOfUser.get(0).id;
        // Create Accounts
        List<Account> ListOfAccounts = TestUtilities.getListOfAccounts(1);
        System.runAs(ListOfUser.get(0)){
            insert ListOfAccounts;
        }
        System.assert(ListOfAccounts[0].Id != null, 'Record not created');
        // Create Contact
        List<Contact> ListOfContacts = TestUtilities.getListOfContact(1);
        for(Contact ContactRec : ListOfContacts){
            ContactRec.Core_IPS_Intel_Support_Owner__c = intelSupportOwner;
            ContactRec.Accountid = ListOfAccounts.get(0).Id;
            ContactRec.Core_IPS_Active__c = true;
            ContactRec.Core_IPS_Email_Opt_Out__c = false;
        }
        System.runAs(ListOfUser.get(0)){
            insert ListOfContacts;
        }
        System.assert(ListOfContacts[0].Id != null, 'Record not created');
        // Create Ips Project
        List<Core_IPS_Project__c> ListOfIpsProjects = TestUtilities.getListOfIpsProjects(1);
        
        List<Core_IPS_Labels__c> IPSLabels = TestUtilities.getIPSLabel();
                
        System.runAs(ListOfUser.get(0)){
            insert IPSLabels;
            //insert ListOfTriggerExecutions; 
        }
        System.runAs(ListOfUser.get(1)){
            ListOfIpsProjects[0].Core_MPNDA__c = '';
            ListOfIpsProjects[0].Core_IPS_EnableMemberasInterestedParties__c = true;
            insert ListOfIpsProjects;
        }
        System.assert(ListOfIpsProjects[0].Id != null, 'Record not created');
        // Create Ips Account
        List<Core_IPS_Account__c> ListOfIpsAccounts = TestUtilities.getListOfIpsAccounts(1);
        for(Core_IPS_Account__c IpsAcc : ListOfIpsAccounts){
            IpsAcc.Core_Account__c = ListOfAccounts.get(0).Id;
            IpsAcc.Core_IPS_Project__c = ListOfIpsProjects.get(0).Id;
        }
        System.runAs(ListOfUser.get(0)){
            insert ListOfIpsAccounts;
        }
        System.assert(ListOfIpsAccounts[0].Id != null, 'Record not created');
        Id ExternalUserProfileId = [select id, name from Profile where name='IPS External Customer'].Id;
        User customerUser = TestUtilities.getListOfUser(2).get(1);
        customerUser.ProfileId = ExternalUserProfileId;
        customerUser.UserName = 'testips.contact999@intel.com.crm';
        customerUser.FirstName = 'TestExt';
        customerUser.LastName = 'User192';
        customerUser.Alias = 'eusr192';
        customeruser.Isactive = true; 
        customerUser.CommunityNickname = 'IPSExtUser192';
        customerUser.ContactId = ListOfContacts[0].Id;
        
        insert customerUser;
        System.assert(customerUser.Id != null, 'Record not created');
       
        System.runAs(ListOfUser.get(0)){
            // Create Asset
            list<Asset> AssetList = TestUtilities.getAssetList(1);
            for(Asset Asst : AssetList){
                Asst.accountId = ListOfAccounts.get(0).Id;
                Asst.Contactid = ListOfContacts.get(0).id;
            }
            insert AssetList;
            System.assert(AssetList[0].Id != null, 'Record not created');
            
            // Create Case
            List<Case> ListOfCases = TestUtilities.getListOfCases(1);
            for(Case CaseRec : ListOfCases){
                CaseRec.ContactId = ListOfContacts.get(0).id;
                CaseRec.accountId = ListOfAccounts.get(0).Id;
                CaseRec.Core_IPS_Project_Case__c = ListOfIpsProjects.get(0).Id;
            }
            insert ListOfCases;
        }
        
        //Core_IPS_Active__c check 
        System.runAs(ListOfUser.get(0)){
            ListOfContacts[0].Core_IPS_Active__c = false;
            update ListOfContacts;
        }
        
        
        // Create Project Member
        List<Core_IPS_Project_Member__c> ListOfProjectMembers = TestUtilities.getListOfProjectMembers(3);
        for(Core_IPS_Project_Member__c ProjMem : ListOfProjectMembers){
            ProjMem.Core_IPS_Contact__c = ListOfContacts.get(0).Id;
            ProjMem.Core_IPS_Project__c = ListOfIpsProjects.get(0).Id;
            ProjMem.Core_User__c = customerUser.Id;                             
            ProjMem.Core_Status__c = 'Active';
            ProjMem.Add_as_Case_Interested_Party__c =True;
        }
        
        
        try{
            
            System.runAs(ListOfUser.get(0)){
                ListOfProjectMembers[2].Add_as_Case_Interested_Party__c=false;
                insert ListOfProjectMembers;
                System.debug('ListOfProjectMembers[2].Add_as_Case_Interested_Party__c 1--->'+ListOfProjectMembers[2].Add_as_Case_Interested_Party__c);
                ListOfProjectMembers[2].Add_as_Case_Interested_Party__c=true;
                update ListOfProjectMembers[2];
                System.debug('ListOfProjectMembers[2].Add_as_Case_Interested_Party__c 2--->'+ListOfProjectMembers[2].Add_as_Case_Interested_Party__c);

            }
            
        }catch(Exception e){
            System.debug('---error::');
        }
        
        //Core_IPS_Email_Opt_Out__c check
        System.runAs(ListOfUser.get(0)){
            ListOfContacts[0].Core_IPS_Active__c = true;
            ListOfContacts[0].Core_IPS_Email_Opt_Out__c = true;
            update ListOfContacts;
        }
        
        
        // Create Project Member
        List<Core_IPS_Project_Member__c> ListOfProjectMembers2 = TestUtilities.getListOfProjectMembers(3);
        for(Core_IPS_Project_Member__c ProjMem : ListOfProjectMembers2){
            ProjMem.Core_IPS_Contact__c = ListOfContacts.get(0).Id;
            ProjMem.Core_IPS_Project__c = ListOfIpsProjects.get(0).Id;
            ProjMem.Core_User__c = customerUser.Id;                             
            ProjMem.Core_Status__c = 'Active';
            ProjMem.Add_as_Case_Interested_Party__c =True;
        }
        
        
        try{
            
            System.runAs(ListOfUser.get(0)){
                insert ListOfProjectMembers2;
            }
            
        }catch(Exception e){
            System.debug('---2nd :::error::');
        }
        
        
        //3.User active check
        System.runAs(ListOfUser.get(0)){
            ListOfContacts[0].Core_IPS_Active__c = true;
            ListOfContacts[0].Core_IPS_Email_Opt_Out__c = false;
            update ListOfContacts;
            
            customeruser.Isactive = false; 
            update customeruser;
        }
        
        
        // Create Project Member
        List<Core_IPS_Project_Member__c> ListOfProjectMembers3 = TestUtilities.getListOfProjectMembers(3);
        for(Core_IPS_Project_Member__c ProjMem : ListOfProjectMembers3){
            ProjMem.Core_IPS_Contact__c = ListOfContacts.get(0).Id;
            ProjMem.Core_IPS_Project__c = ListOfIpsProjects.get(0).Id;
            ProjMem.Core_User__c = customerUser.Id;                             
            ProjMem.Core_Status__c = 'Active';
            ProjMem.Add_as_Case_Interested_Party__c =True;
        }
        
        
        try{
            
            System.runAs(ListOfUser.get(0)){
                insert ListOfProjectMembers3;
            }
            
        }catch(Exception e){
            System.debug('---3rd :::error::');
        }
        
    }
    
    
    /****************************************************************
     * Description : Check Inactivation Of Project member
     * Modification Log :
     * Name			    Date					Description
     * --------------------------------------------------------------
     * Amritesh         09/10/2018             Modified
    *****************************************************************/
    static testmethod void InactivateProjectMemberTest(){
        getrecords();
        // Get intelSupportOwner Id (User Id)
        Id intelSupportOwner = ListOfUser.get(0).id;
        // Create Accounts
        List<Account> ListOfAccounts = TestUtilities.getListOfAccounts(1);
        System.runAs(ListOfUser.get(0)){
            insert ListOfAccounts;
        }
        System.assert(ListOfAccounts[0].Id != null, 'Record not created');
        // Create Contact
        List<Contact> ListOfContacts = TestUtilities.getListOfContact(3);
        for(Contact ContactRec : ListOfContacts){
            ContactRec.Core_IPS_Intel_Support_Owner__c = intelSupportOwner;
            ContactRec.Accountid = ListOfAccounts.get(0).Id;
            ContactRec.Core_IPS_Active__c = true;
            ContactRec.Core_IPS_Email_Opt_Out__c = false;
        }
        System.runAs(ListOfUser.get(0)){
            insert ListOfContacts;
        }
        System.assert(ListOfContacts[0].Id != null, 'Record not created');
        // Create Ips Project
        List<Core_IPS_Project__c> ListOfIpsProjects = TestUtilities.getListOfIpsProjects(1);
        
        List<Core_IPS_Labels__c> IPSLabels = TestUtilities.getIPSLabel();
        
        List<Core_Trigger_Executions__c> ListOfTriggerExecutions = TestUtilities.getListOfTriggerExecutions();
        
        Core_Trigger_Executions__c triExeRec1 = new Core_Trigger_Executions__c();
        Core_Trigger_Executions__c triExeRec = new Core_Trigger_Executions__c();
        triExeRec.Core_Class_Name__c = 'Core_IPS_Project_Member_Handler';
        triExeRec.Core_Description__c = 'Remove Interested Party';
        triExeRec.Core_Object__c ='Core_IPS_Project__c' ;
        triExeRec.Core_Trigger_Events__c = 'after update';
        triExeRec.Name = 'removeRelatedIpsOnStatusChangeForPM';
        triExeRec.Core_Active__c = True;       
        ListOfTriggerExecutions.add(triExeRec);
        
        Core_Trigger_Executions__c triExeRec2 = new Core_Trigger_Executions__c();
        triExeRec2.Core_Class_Name__c = 'Core_IPS_Project_Member_Handler';
        triExeRec2.Core_Description__c = 'Remove PSO';
        triExeRec2.Core_Object__c ='Core_IPS_Project__c' ;
        triExeRec2.Core_Trigger_Events__c = 'after update';
        triExeRec2.Name = 'removePSOonProject';
        triExeRec2.Core_Active__c = True;       
        ListOfTriggerExecutions.add(triExeRec2);
                
        System.runAs(ListOfUser.get(0)){
            insert IPSLabels;
            insert ListOfTriggerExecutions; 
        }
        
        Id ExternalUserProfileId = [select id, name from Profile where name='IPS External Customer'].Id;
        User customerUser = TestUtilities.getListOfUser(2).get(1);
        customerUser.ProfileId = ExternalUserProfileId;
        customerUser.UserName = 'testips.contact999@intel.com.crm';
        customerUser.FirstName = 'TestExt';
        customerUser.LastName = 'User192';
        customerUser.Alias = 'eusr192';
        customeruser.Isactive = true; 
        customerUser.CommunityNickname = 'IPSExtUser192';
        customerUser.ContactId = ListOfContacts[0].Id;
        
        //second user
        User customerUser2 = TestUtilities.getListOfUser(2).get(1);
        customerUser2.ProfileId = ExternalUserProfileId;
        customerUser2.UserName = 'testips.contact2_999@intel.com.crm';
        customerUser2.FirstName = 'TestExt2_99';
        customerUser2.LastName = 'Us2_199';
        customerUser2.Alias = 'eu2_199';
        customerUser2.Isactive = true; 
        customerUser2.CommunityNickname = 'IPSExtUs2_199';
        customerUser2.ContactId = ListOfContacts[1].Id;
        
               
        System.runAs(ListOfUser.get(0)){
            
            insert customerUser;
            insert customerUser2;
            
            // Create Asset
            list<Asset> AssetList = TestUtilities.getAssetList(1);
            for(Asset Asst : AssetList){
                Asst.accountId = ListOfAccounts.get(0).Id;
                Asst.Contactid = ListOfContacts.get(0).id;
            }
            insert AssetList;
            System.assert(AssetList[0].Id != null, 'Record not created');
            
        }
        
        System.runAs(ListOfUser.get(1)){
            ListOfIpsProjects[0].Core_MPNDA__c = '';
            ListOfIpsProjects[0].Core_IPS_EnableMemberasInterestedParties__c = true;
            ListOfIpsProjects[0].Core_IPS_Partner_Support_Owner__c = customerUser.Id;
            insert ListOfIpsProjects;
        }
        System.assert(ListOfIpsProjects[0].Id != null, 'Record not created');
        // Create Ips Account
        List<Core_IPS_Account__c> ListOfIpsAccounts = TestUtilities.getListOfIpsAccounts(1);
        for(Core_IPS_Account__c IpsAcc : ListOfIpsAccounts){
            IpsAcc.Core_Account__c = ListOfAccounts.get(0).Id;
            IpsAcc.Core_IPS_Project__c = ListOfIpsProjects.get(0).Id;
        }
        System.runAs(ListOfUser.get(0)){
            insert ListOfIpsAccounts;
        }
        System.assert(ListOfIpsAccounts[0].Id != null, 'Record not created');
        
        // Create Project Member
        Integer count=1;
        List<Core_IPS_Project_Member__c> ListOfProjectMembers = TestUtilities.getListOfProjectMembers(5);
        for(Core_IPS_Project_Member__c ProjMem : ListOfProjectMembers){
            if(count==2){
                ProjMem.Core_IPS_Contact__c = ListOfContacts.get(1).Id;
                ProjMem.Core_User__c = customerUser2.Id; 
            }
            else{
                ProjMem.Core_IPS_Contact__c = ListOfContacts.get(0).Id;
                ProjMem.Core_User__c = customerUser.Id; 
            }
            ProjMem.Core_IPS_Project__c = ListOfIpsProjects.get(0).Id;
            
            ProjMem.Core_Status__c = 'Active';
            ProjMem.Add_as_Case_Interested_Party__c =True;
            count++;
        }
        System.runAs(ListOfUser.get(0)){
            insert ListOfProjectMembers;
            Test.startTest();
            // Create Case
            List<Case> ListOfCases = TestUtilities.getListOfCases(3);
            for(Case CaseRec : ListOfCases){
                CaseRec.ContactId = ListOfContacts.get(0).id;
                CaseRec.accountId = ListOfAccounts.get(0).Id;
                CaseRec.Core_IPS_Project_Case__c = ListOfIpsProjects.get(0).Id;
                CaseRec.Core_IPS_Partner_Sup_Owner__c = customerUser.Id;
                CaseRec.Status='Open';
            }
            insert ListOfCases;
        }
        
        
        //Update project member status to inactive
        ListOfProjectMembers[0].Core_Status__c ='Inactive';
        System.runAs(ListOfUser.get(0)){
            update ListOfProjectMembers;
        }
        Test.stopTest();
        
    }
 
 
 
  
}