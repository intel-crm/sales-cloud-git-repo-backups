/********************************************************************************************************************
Apex Class Name:  Core_IPS_AddProjectMemberController_Test
Version     : 1.0 
Created Date: 08 Nov 2017
Function    : Test class for Core_IPS_Survey_Controller
Modification Log :
* Developer                             Date                   Description
* ----------------------------------------------------------------------------                 
* Amritesh Sahu                       11/08/2017                Created
* Sugandha                            20/04/2018                Modified(User Story# US102846 Iteration 10)
*******************************************************************************************************************/
@isTest
public class Core_IPS_AddProjectMemberController_Test {
    
    /***************************************************************************************************
    Method Name:  SetupTestData()
    Version     : 1.0 
    Description:  Test data setup method 
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Amritesh                    11/08/2017              Created
    * Sugandha                    20/04/2018              Modified(User Story# US102846 Iteration 10)
    ****************************************************************************************************/
    @testSetup static void SetupTestData() {
        
        // Query Profiles
        Map<String,ID> profiles = new Map<String,ID>();
        List<String> strProf = new List<String>();
        strProf.add('System Administrator');
        strProf.add('Sales Rep-BB'); //added by Sugandha for US102846
        List<Profile> ProfileList = [select id, name from Profile where name IN : strProf];
        for(Profile prf : ProfileList){
            profiles.put(prf.name, prf.id);
        }
        //Create Role
        UserRole role = new UserRole();
        role.name='CEO';
        insert role;
        // Create Users
        List<User> ListOfUser = TestUtilities.getListOfUser(2);
        ListOfUser.get(0).ProfileID =  profiles.get('System Administrator');
        ListOfUser.get(1).ProfileID =  profiles.get('Sales Rep-BB');//added by Sugandha for US102846
        insert ListOfUser;
        
        System.assertEquals(ListOfUser.get(0).profileid, profiles.get('System Administrator'));
        System.assertEquals(ListOfUser.get(1).profileid, profiles.get('Sales Rep-BB'));//added by Sugandha for US102846
        
        // Create Ips Labels
        List<Core_IPS_Labels__c> IPSLabels = TestUtilities.getIPSLabel();
        
        System.runAs(ListOfUser.get(0)){
            insert IPSLabels;
        }
        
        Id intelSupportOwner = ListOfUser.get(0).id;
        List<User> UserList = new List<User> ();
                
        //Create Customer User
        System.runAs(ListOfUser.get(0)){
            UserList.add(TestUtilities.getCustomerUser('IPS External Customer'));    
            Contact objContact = new Contact(Id=UserList.get(0).contactId);
            objContact.Core_IPS_Intel_Support_Owner__c = intelSupportOwner;
            objContact.Core_IPS_Active__c = true;
            update objContact;
        }
       
        
        List<Account> ListOfAccounts = [SELECT Id,Name FROM Account WHERE Id IN (SELECT AccountId FROM Contact WHERE Id=:UserList.get(0).contactId)];
        
        // Create Ips Project
        List<Core_IPS_Project__c> ListOfIpsProjects = TestUtilities.getListOfIpsProjects(1);
        System.runAs(ListOfUser.get(0)){
            insert ListOfIpsProjects;
        }
        System.assert(ListOfIpsProjects[0].Id != null, 'Record not created');
        
        // Create Ips Account
        List<Core_IPS_Account__c> ListOfIpsAccounts = TestUtilities.getListOfIpsAccounts(2);
        for(Core_IPS_Account__c IpsAcc : ListOfIpsAccounts){
            IpsAcc.Core_Account__c = ListOfAccounts.get(0).Id;
            IpsAcc.Core_IPS_Project__c = ListOfIpsProjects.get(0).Id;
            IpsAcc.core_members__c = 'Selective';
        }
        System.runAs(ListOfUser.get(0)){
            insert ListOfIpsAccounts;
        }
        System.assert(ListOfIpsAccounts[0].Id != null, 'Record not created');
    }
    
    /***************************************************************************************************
    Method Name:  Test_Core_IPS_AddProjectMemberController()
    Version     : 1.0 
    Description:  Test method for the controller Core_IPS_AddProjectMemberController
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Amritesh                    11/08/2017              Created
    ****************************************************************************************************/
    static testMethod void Test_Core_IPS_AddProjectMemberController() {
        
        Id projectId = [SELECT Id FROM Core_IPS_Project__c LIMIT 1].Id;
        Pagereference pgref = Page.Core_addProjectMembersInformation;
        pgref.getParameters().put('projectId', projectId);
        Test.setCurrentPage(pgref);
        
        Test.startTest();
        Core_IPS_AddProjectMember_Controller inst_AddProjMember = new Core_IPS_AddProjectMember_Controller();
        String strExistingProjMembers = Core_IPS_AddProjectMember_Controller.getlstExistingProjectMembers();
        String strProjMembers = Core_IPS_AddProjectMember_Controller.getlstProjectMemberWrapperInfo(); 
        List<Core_IPS_Project_Member__c> lstProjMember = new List<Core_IPS_Project_Member__c>(); 
        
        String newProjMembers_Msg = Core_IPS_AddProjectMember_Controller.insertProjectMembers(lstProjMember);
        newProjMembers_Msg = Core_IPS_AddProjectMember_Controller.insertProjectMembers(null);
        
        List<User> UserList = [SELECT Id, ContactId FROM User WHERE Contact.Core_IPS_Active__c=true and IsActive=true AND AccountId IN (SELECT Core_Account__c FROM Core_IPS_Account__c WHERE Core_IPS_Project__c=:projectId)];
        lstProjMember.add(new Core_IPS_Project_Member__c(Core_IPS_Contact__c = UserList.get(0).ContactId,
                                                         Core_User__c = UserList.get(0).Id,
                                                         core_ips_project__c = projectId,
                                                         Core_Status__c = 'Active',
                                                         Core_Selective_Member__c = true)
                          );
        newProjMembers_Msg = Core_IPS_AddProjectMember_Controller.insertProjectMembers(lstProjMember);
        System.assert([SELECT COUNT() FROM Core_IPS_Project_Member__c]>0, 'Project Member not inserted');
        strExistingProjMembers = Core_IPS_AddProjectMember_Controller.getlstExistingProjectMembers();
        strProjMembers = Core_IPS_AddProjectMember_Controller.getlstProjectMemberWrapperInfo(); 
        String errMsg = inst_AddProjMember.errorMsg;
        
        List<Core_IPS_AddProjectMember_Controller.IPSMemberWrapper> wrapperInContext = new List<Core_IPS_AddProjectMember_Controller.IPSMemberWrapper> ();  
        for (User objUser : [Select id, contactid, Contact.FirstName,Contact.LastName, Contact.Account.Name from User where Contact.Core_IPS_Active__c=true and IsActive=true AND AccountId IN (SELECT Core_Account__c FROM Core_IPS_Account__c WHERE Core_IPS_Project__c=:projectId)]) {           
            Core_IPS_AddProjectMember_Controller.IPSMemberWrapper wrapper = new Core_IPS_AddProjectMember_Controller.IPSMemberWrapper();
            wrapper.selected = false;
            wrapper.conFirstName = objUser.Contact.firstName;
            wrapper.conLastName  = objUser.Contact.LastName;
            wrapper.accountName  = objUser.Contact.account.Name;
            wrapper.contactId  = objUser.contactId;
            wrapper.user = objUser;            
            wrapperInContext.add(wrapper);
        }
        Integer compareResult = wrapperInContext.get(0).compareTo(wrapperInContext.get(0));
        Test.stopTest();
        
    }
    
    /***************************************************************************************************
    Method Name:  Test_Core_IPS_AddProjectMemberController1()
    Version     : 1.0 
    Description:  Test method for the controller Core_IPS_AddProjectMemberController
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Sugandha                    20/04/2018              Created(User Story# US102846 Iteration# 10)
    ****************************************************************************************************/
    static testMethod void Test_Core_IPS_AddProjectMemberController1() {
        
        List<Account> ListOfAccounts = [SELECT Id,Name FROM Account limit 2];
        user sysAdminUser; user FAEUser;
        
        Map<String,ID> profiles = new Map<String,ID>();
        List<String> strProf = new List<String>();
        strProf.add('System Administrator');
        strProf.add('Sales Rep-BB'); //added by Sugandha for US102846
        List<Profile> ProfileList = [select id, name from Profile where name IN : strProf];
        for(Profile prf : ProfileList){
            profiles.put(prf.name, prf.id);
        }
        //Create Role
        UserRole role = new UserRole();
        role.name='CEO';
        insert role;
        // Create Users
        List<User> ListOfUser = TestUtilities.getListOfUser(2);
        ListOfUser.get(0).ProfileID =  profiles.get('System Administrator');
        ListOfUser.get(1).ProfileID =  profiles.get('Sales Rep-BB');//added by Sugandha for US102846
        insert ListOfUser;
        sysAdminUser = ListOfUser[0];
        FAEUser = ListOfUser[1];
                
        //Provide access to FAE as Account Team Member
        List<AccountTeamMember> members = new list<AccountTeamMember>();
        List<AccountShare> sharingRules = new list<AccountShare>();
        String teamMemberRole = 'Account Manager';
        String accountAccessLevel = 'Edit', opportunityAccessLevel = 'Edit', caseAccessLevel = 'None';
        
        for(Account a : ListOfAccounts) {
            members.add(New AccountTeamMember(AccountId = a.id, TeamMemberRole = teamMemberRole, UserId= FAEUser.Id));
            sharingRules.add(new AccountShare(AccountAccessLevel = accountAccessLevel, OpportunityAccessLevel = OpportunityAccessLevel, CaseAccessLevel = caseAccessLevel, UserOrGroupId = FAEUser.Id, AccountId = a.id));
        }
        
        System.runAs(sysAdminUser){
            insert members;
            insert sharingRules;
        }
        
        // Create Ips Project with FAE login
        List<Core_IPS_Project__c> ListOfIpsProjects = TestUtilities.getListOfIpsProjects(1);
        System.runAs(FAEUser){
            ListOfIpsProjects[0].Name = 'Test FAE Project';
            insert ListOfIpsProjects;
        }
        
        // Create Ips Account with FAE login
        List<Core_IPS_Account__c> ListOfIpsAccounts = TestUtilities.getListOfIpsAccounts(2);
        for(Core_IPS_Account__c IpsAcc : ListOfIpsAccounts){
            IpsAcc.Core_Account__c = ListOfAccounts.get(0).Id;
            IpsAcc.Core_IPS_Project__c = ListOfIpsProjects.get(0).Id;
            IpsAcc.core_members__c = 'Selective';
        }
        
        System.runAs(FAEUser){
            insert ListOfIpsAccounts;
        }
        
        Pagereference pgref = Page.Core_addProjectMembersInformation;
        pgref.getParameters().put('projectId', ListOfIpsProjects[0].Id);
        Test.setCurrentPage(pgref);
        
        Test.startTest();
            system.runAs(FAEUser){
                Core_IPS_AddProjectMember_Controller inst_AddProjMember = new Core_IPS_AddProjectMember_Controller();
                String strExistingProjMembers = Core_IPS_AddProjectMember_Controller.getlstExistingProjectMembers();
                String strProjMembers = Core_IPS_AddProjectMember_Controller.getlstProjectMemberWrapperInfo(); 
            }
        Test.stopTest();
        
    }
    
}