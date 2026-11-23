/***************************************************************************************************
Class Name:  Core_IPS_UpdatePSO_Controller_Test
Version     : 1.0 
Description:   This class is to prepage a drop dynamic downlist of project members to select as Project support Owner 
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Vamsi      		     22/Nov/2018              Created
****************************************************************************************************/
@isTest
public class Core_IPS_UpdatePSO_Controller_Test {
    static List<User> ListOfUser = new List<User> ();
   static void getRecords() {
        
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
        
        List<Core_IPS_Labels__c> lstIpsLabelTeam = new List<Core_IPS_Labels__c>();
        lstIpsLabelTeam.add(new Core_IPS_Labels__c(Name='Core_IPS_MPNDAValue_Error',Value__c='Error'));
        System.runAs(ListOfUser.get(0)){
            insert lstIpsLabelTeam;
        }
        
    }
    
    
 
    static testmethod  void testData(){
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
        
        System.runAs(ListOfUser.get(0)){
            ListOfIpsProjects[0].Core_MPNDA__c = '';
            //insert IPSLabels;
            insert ListOfIpsProjects;
            insert ListOfTriggerExecutions;
        }
        System.assert(ListOfIpsProjects[0].Id != null, 'Record not created');
        // Create Ips Account
        List<Core_IPS_Account__c> ListOfIpsAccounts = TestUtilities.getListOfIpsAccounts(1);
        List<Core_IPS_Project__c> ListOfIpsProjects2 = TestUtilities.getListOfIpsProjects(1);
        for(Core_IPS_Account__c IpsAcc : ListOfIpsAccounts){
            IpsAcc.Core_Account__c = ListOfAccounts.get(0).Id;
            IpsAcc.Core_IPS_Project__c = ListOfIpsProjects.get(0).Id;
        }
        System.runAs(ListOfUser.get(0)){
            insert ListOfIpsAccounts;
        }
        System.assert(ListOfIpsAccounts[0].Id != null, 'Record not created');
        
        User DFAEUser = TestUtilities.getListOfUser(1).get(0);
        DFAEUser.ProfileID = System.Label.Core_IPS_Partner_Profile_Id;
        DFAEUser.ContactId = ListOfContacts.get(0).Id;
        System.runAs(ListOfUser.get(0)){
            insert DFAEUser;
            PermissionSetAssignment objPSA = new PermissionSetAssignment(AssigneeId=DFAEUser.Id, PermissionSetId=System.Label.Core_IPS_Partner_DFAE_Permission_Set);
            insert objPSA;
        }
        // Create Project Member
        List<Core_IPS_Project_Member__c> ListOfProjectMembers = TestUtilities.getListOfProjectMembers(5);
        for(Core_IPS_Project_Member__c ProjMem : ListOfProjectMembers){
            ProjMem.Core_IPS_Contact__c = ListOfContacts.get(0).Id;
            ProjMem.Core_IPS_Project__c = ListOfIpsProjects.get(0).Id;
            ProjMem.Core_User__c = DFAEUser.Id;            
        }
        
        List<Core_IPS_Intel_Support_Team__c> lstIST = TestUtilities.getListOfIntelSupportTeamMembers(2);
        lstIST[0].Core_IPS_User__c = ListOfUser.get(0).Id;
        lstIST[1].Core_IPS_User__c = ListOfUser.get(1).Id;
        for(Core_IPS_Intel_Support_Team__c ist : lstIST) {
            ist.Core_IPS_Project__c = ListOfIpsProjects[0].Id;            
            ist.Status__c = 'Active';
        }
        System.runAs(ListOfUser.get(0)){
            insert lstIST;
            insert ListOfProjectMembers;
        }  
        System.assert(ListOfProjectMembers[0].Id != null, 'Record not created');
        Test.startTest();
        Core_IPS_UpdatePSO_Controller inst_Cont = new Core_IPS_UpdatePSO_Controller(new ApexPages.StandardController(ListOfIpsProjects[0]));
        inst_Cont.renderMessage = null;
        List<SelectOption>  x=inst_Cont.UserList;
        inst_Cont.SaveRedirect();
         Core_IPS_UpdatePSO_Controller inst_Cont1 = new Core_IPS_UpdatePSO_Controller(new ApexPages.StandardController(ListOfIpsProjects2[0]));
        inst_Cont1.renderMessage = null;
        List<SelectOption>  x1=inst_Cont.UserList;
        inst_Cont1.SaveRedirect();
        
          Test.stopTest();
    } 
    static testmethod  void testData1(){
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
        
        System.runAs(ListOfUser.get(0)){
            ListOfIpsProjects[0].Core_MPNDA__c = '';
            //insert IPSLabels;
            insert ListOfIpsProjects;
            insert ListOfTriggerExecutions;
        }
        System.assert(ListOfIpsProjects[0].Id != null, 'Record not created');
        // Create Ips Account
        List<Core_IPS_Account__c> ListOfIpsAccounts = TestUtilities.getListOfIpsAccounts(1);
        List<Core_IPS_Project__c> ListOfIpsProjects2 = TestUtilities.getListOfIpsProjects(1);
        for(Core_IPS_Account__c IpsAcc : ListOfIpsAccounts){
            IpsAcc.Core_Account__c = ListOfAccounts.get(0).Id;
            IpsAcc.Core_IPS_Project__c = ListOfIpsProjects.get(0).Id;
        }
        System.runAs(ListOfUser.get(0)){
            insert ListOfIpsAccounts;
        }
        System.assert(ListOfIpsAccounts[0].Id != null, 'Record not created');
        
        User DFAEUser = TestUtilities.getListOfUser(1).get(0);
         list<Profile>profId=[SELECT id FROM Profile where name='IPS Agent-Partner'];
        DFAEUser.ProfileID = profId[0].id;
        DFAEUser.ContactId = ListOfContacts.get(0).Id;
       
            insert DFAEUser;
           
       
        // Create Project Member
        List<Core_IPS_Project_Member__c> ListOfProjectMembers = TestUtilities.getListOfProjectMembers(5);
        for(Core_IPS_Project_Member__c ProjMem : ListOfProjectMembers){
            ProjMem.Core_IPS_Contact__c = ListOfContacts.get(0).Id;
            ProjMem.Core_IPS_Project__c = ListOfIpsProjects.get(0).Id;
            ProjMem.Core_User__c = DFAEUser.Id;            
        }
        List<Core_IPS_Intel_Support_Team__c> lstIST = TestUtilities.getListOfIntelSupportTeamMembers(2);
        lstIST[0].Core_IPS_User__c = ListOfUser.get(0).Id;
        lstIST[1].Core_IPS_User__c = ListOfUser.get(1).Id;
        for(Core_IPS_Intel_Support_Team__c ist : lstIST) {
            ist.Core_IPS_Project__c = ListOfIpsProjects[0].Id;            
            ist.Status__c = 'Active';
        }
        System.runAs(ListOfUser.get(0)){
            insert lstIST;
            insert ListOfProjectMembers;
        }  
        System.assert(ListOfProjectMembers[0].Id != null, 'Record not created');
        Test.startTest();
        Core_IPS_UpdatePSO_Controller inst_Cont = new Core_IPS_UpdatePSO_Controller(new ApexPages.StandardController(ListOfIpsProjects[0]));
        inst_Cont.renderMessage = null;
        List<SelectOption>  x=inst_Cont.UserList;
        inst_Cont.SaveRedirect();
         Core_IPS_UpdatePSO_Controller inst_Cont1 = new Core_IPS_UpdatePSO_Controller(new ApexPages.StandardController(ListOfIpsProjects2[0]));
        inst_Cont1.renderMessage = null;
        List<SelectOption>  x1=inst_Cont.UserList;
        inst_Cont1.SaveRedirect();
        
          Test.stopTest();
    
    }
    
}