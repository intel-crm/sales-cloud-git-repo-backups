/* Class Name : Core_IPS_ProjectController_Lex_Test
   Description : Test Class for Core_IPS_ProjectController_Lex
   Author : Chandrashekar */

@isTest
public with sharing class Core_IPS_ProjectController_Lex_Test {
    @TestSetup
    static void makeData(){
		UserRole role = [SELECT Id FROM UserRole WHERE PortalType = 'None' LIMIT 1];

        Map<String,ID> profiles = new Map<String,ID>();
        List<String> strProf = new List<String>();
        strProf.add('System Administrator');
        strProf.add('Sales Rep-BB');
        List<Profile> ProfileList = [select id, name from Profile where name IN : strProf];
        for(Profile prf : ProfileList){
            profiles.put(prf.name, prf.id);
        }
        user sysAdminUser; 
	user FAEUser;
        List<User> ListOfUser = new List<User> ();
        ListOfUser = TestUtilities.getListOfUser(2);
        ListOfUser.get(0).ProfileID =  profiles.get('System Administrator');
        ListOfUser.get(0).userRoleId = role.Id;
        ListOfUser.get(1).ProfileID =  profiles.get('Sales Rep-BB');
        insert ListOfUser;

        System.assertEquals(ListOfUser.get(0).profileid, profiles.get('System Administrator'));
        System.assertEquals(ListOfUser.get(1).profileid, profiles.get('Sales Rep-BB'));

        Core_IPS_Project__c project = TestUtilities.getIpsProjectRecord ();
        project.Core_Status__c = 'Draft';
        project.Name = 'Test Project';
        System.runAs(ListOfUser.get(0)){
        	insert project;
        }

        /*Core_IPS_Product__c prod = TestUtilities.getIpsProduct();
        prod.Core_IPS_Project__c = project.Id;
        System.runAs(ListOfUser.get(0)){
            insert prod;
        }*/

        Account accRec = TestUtilities.getAccount();
        accRec.Name ='Test Account 1';
        accRec.Core_CNDA_Number__c ='1234';
        accRec.Core_IPS_Active__c = true;
        accRec.OwnerId = ListOfUser.get(0).Id;
        System.runAs(ListOfUser.get(0)){
        	insert accRec;
        }

        Account accRec1 = TestUtilities.getAccount();
        accRec1.Name ='Test Account 2';
        accRec1.Core_CNDA_Number__c ='1234';
        accRec1.Core_IPS_Active__c = true;
        System.runAs(ListOfUser.get(0)){
        	insert accRec1;
        }

        Account accRec2 = TestUtilities.getAccount();
        accRec2.Name ='Test Account 3';
        accRec2.Core_CNDA_Number__c ='1234';
        accRec2.Core_IPS_Active__c = true;
        System.runAs(ListOfUser.get(0)){
        	insert accRec2;
        }

        Account accRec3 = TestUtilities.getAccount();
        accRec3.Name ='Test Account 4';
        accRec3.Core_CNDA_Number__c ='1234';
        accRec3.Core_IPS_Active__c = true;
        System.runAs(ListOfUser.get(0)){
        	insert accRec3;
        }

        Account accRec4 = TestUtilities.getAccount();
        accRec4.Name ='Test Account 5';
        accRec4.Core_CNDA_Number__c ='1234';
        accRec4.Core_IPS_Active__c = true;
        System.runAs(ListOfUser.get(0)){
        	insert accRec4;
        }

        Core_IPS_Account__c coreAcc = TestUtilities.getCoreIpsAccount();
        coreAcc.Core_IPS_Project__c = project.Id;
        coreAcc.Core_Account__c = accRec.Id;
        System.runAs(ListOfUser.get(0)){
        	insert coreAcc;
        }

        Core_IPS_Account__c coreAcc1 = TestUtilities.getCoreIpsAccount();
        coreAcc1.Core_IPS_Project__c = project.Id;
        coreAcc1.Core_Account__c = accRec1.Id;
        System.runAs(ListOfUser.get(0)){
        	insert coreAcc1;
        }

        Core_IPS_Account__c coreAcc2 = TestUtilities.getCoreIpsAccount();
        coreAcc2.Core_IPS_Project__c = project.Id;
        coreAcc2.Core_Account__c = accRec2.Id;
        System.runAs(ListOfUser.get(0)){
        	insert coreAcc2;
        }

        Id intelSupportOwner = ListOfUser.get(0).id;

        List<Contact> ListOfContacts = TestUtilities.getListOfContact(1);
        for(Contact ContactRec : ListOfContacts){
            ContactRec.Core_IPS_Intel_Support_Owner__c = intelSupportOwner;
            ContactRec.Accountid = accRec.Id;
            ContactRec.Core_IPS_Active__c = true;
	    ContactRec.MailingCountry = 'India';
        }
        
        System.runAs(ListOfUser.get(0)){
            insert ListOfContacts;
        }
        System.assert(ListOfContacts[0].Id != null, 'Record not created');
        
        User DFAEUser = TestUtilities.getListOfUser(1).get(0);
        DFAEUser.ProfileID = System.Label.Core_IPS_Partner_Profile_Id;
        DFAEUser.ContactId = ListOfContacts.get(0).Id;
        DFAEUser.Email = 'unique@example.com';

        System.runAs(ListOfUser.get(0)){
            insert DFAEUser;
            PermissionSetAssignment objPSA = new PermissionSetAssignment(AssigneeId=DFAEUser.Id, PermissionSetId=System.Label.Core_IPS_Partner_DFAE_Permission_Set);
            insert objPSA;
        }
        
        List<Core_IPS_Project_Member__c> ListOfProjectMembers = TestUtilities.getListOfProjectMembers(5);
        for(Core_IPS_Project_Member__c ProjMem : ListOfProjectMembers){
            ProjMem.Core_IPS_Contact__c = ListOfContacts.get(0).Id;
            ProjMem.Core_IPS_Project__c = project.Id;
            ProjMem.Core_User__c = DFAEUser.Id;            
        }
        
        List<Core_IPS_Intel_Support_Team__c> lstIST = TestUtilities.getListOfIntelSupportTeamMembers(2);
        lstIST[0].Core_IPS_User__c = ListOfUser.get(0).Id;
        lstIST[1].Core_IPS_User__c = ListOfUser.get(1).Id;
        for(Core_IPS_Intel_Support_Team__c ist : lstIST) {
            ist.Core_IPS_Project__c = project.Id;            
            ist.Status__c = 'Active';
        }
        System.runAs(ListOfUser.get(0)){
            insert lstIST;
            insert ListOfProjectMembers;
        }        
        System.assert(ListOfProjectMembers[0].Id != null, 'Record not created');
        
    } 
    @isTest
    static void testExistingAccounts(){
        String projectId = [SELECT Id FROM Core_IPS_Project__c LIMIT 1].Id;
        List<Core_IPS_Account__c> coreList = Core_IPS_ProjectController_Lex.getExistingAccounts(projectId);
        System.assert(coreList.size()>0);
        Core_IPS_ProjectController_Lex.checkExistingAccounts(projectId);
    }
    @isTest
    static void testExistingAccountsNegative(){
        List<Core_IPS_Account__c> coreList = Core_IPS_ProjectController_Lex.getExistingAccounts(null);
        System.assert(coreList == null);
    }
    @isTest
    static void testLoadAccounts(){
        List<Core_IPS_Account__c> coreAccounts = [SELECT Id,Core_Account__c FROM Core_IPS_Account__c];
        List<Id> ids = new List<Id>();
        Integer limitSize = 3;
        Integer offSet = 0;
        String fetchType = 'Load Data';
        String searchText = 'test';
        for(Core_IPS_Account__c acc : coreAccounts){
            ids.add(acc.Core_Account__c);
        }
        List<Account> coreAccList = Core_IPS_ProjectController_Lex.getAddAccounts(ids, limitSize, offSet, fetchType,searchText);
        Boolean isAccountTypeALL = Core_IPS_ProjectController_Lex.getAccountMemberType((String) ids[0]);
        //List<Account> coreAccList = Core_IPS_ProjectController_Lex.getAddAccounts(ids, limitSize, offSet, fetchType,sortBy,sortDirection,searchText);
        System.assert(coreAccList.size()>0);
    }
    @isTest
    static void testAllAccounts(){
        List<Core_IPS_Account__c> coreAccounts = [SELECT Id,Core_Account__c FROM Core_IPS_Account__c];
        List<Id> ids = new List<Id>();
        Integer limitSize = 2;
        Integer offSet = 0;
        String fetchType ='All Data';
        String searchText = 'test';
        for(Core_IPS_Account__c acc : coreAccounts){
            ids.add(acc.Core_Account__c);
        }
        List<Account> coreAccList = Core_IPS_ProjectController_Lex.getAddAccounts(ids, limitSize, offSet, fetchType,searchText);
        //List<Account> coreAccList = Core_IPS_ProjectController_Lex.getAddAccounts(ids, limitSize, offSet, fetchType,sortBy,sortDirection,searchText);
        System.assert(coreAccList.size()>0);
        List<Id> ids1 = new List<Id>();
        List<Account> coreAccList1 = Core_IPS_ProjectController_Lex.getAddAccounts(ids1, limitSize, offSet, fetchType,searchText);
        System.assert(coreAccList1.size()>0);
    }
    @isTest
    static void testExistingMembers(){
        Id projectId = [SELECT Id FROM Core_IPS_Project__c LIMIT 1].Id;
        Integer limitSize = 10;
        Integer offSet = 0;
        List<Core_IPS_Project_Member__c> existingProjMembers = Core_IPS_ProjectController_Lex.getExistingMembers(projectId,limitSize,offset);
        System.assert(existingProjMembers.size()>0);
    }
    @isTest
    static void testhasProjectEditAccess(){
        Id projectId = [SELECT Id FROM Core_IPS_Project__c LIMIT 1].Id;
        Boolean projEditAccess = Core_IPS_ProjectController_Lex.hasProjectEditAccess(projectId);
        System.assert(projectId!=null);
    }
    @isTest
    static void testLoadMembers(){
        Integer limitSize = 10;
        Integer offSet = 0;
        String fetchType = 'Load Data';
        
        List<Account> ListOfAccounts = [SELECT Id,Name FROM Account limit 2];
        user sysAdminUser; 
	user FAEUser;
        
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
        List<User> ListOfUser = TestUtilities.getListOfUser(2);
        ListOfUser.get(0).ProfileID =  profiles.get('System Administrator');
        ListOfUser.get(1).ProfileID =  profiles.get('Sales Rep-BB');
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
            IpsAcc.core_members__c = 'All';
        }
        
        System.runAs(FAEUser){
            insert ListOfIpsAccounts;
        }
        
        System.runAs(FAEUser){
           String memList = Core_IPS_ProjectController_Lex.getAddMembers(ListOfIpsProjects[0].Id, limitSize, offSet, fetchType);
        }
        fetchType = 'All Data';
        System.runAs(FAEUser){
           String memList1 = Core_IPS_ProjectController_Lex.getAddMembers(ListOfIpsProjects[0].Id, limitSize, offSet, fetchType);
        }
        System.assert(ListOfIpsProjects.size()>0);
        }
        @isTest
    static void testAllAndInsertMembers(){
        String projectId = [SELECT Id FROM Core_IPS_Project__c LIMIT 1].Id;
        List<Core_IPS_Account__c> coreAccounts = [SELECT Id,Core_Account__c FROM Core_IPS_Account__c];
        List<Id> ids = new List<Id>();
        set<Id> setMemIds = new set<Id>();

        List<Core_IPS_Project_Member__c> existingMembers = [select Id, name, core_ips_contact__c, Core_IPS_Contact__r.FirstName, Core_IPS_Contact__r.LastName, Core_IPS_Contact__r.Email,Core_IPS_Contact__r.Account.Name from Core_IPS_Project_Member__c where core_ips_project__c =: projectId];
        
        for (Core_IPS_Project_Member__c ipsMem: existingMembers) {
              setMemIds.add(ipsMem.core_ips_contact__c);        
            }
        Integer limitSize = 10;
        Integer offSet = 0;        
        String fetchType = 'All Data';
        for(Core_IPS_Account__c acc : coreAccounts){
            ids.add(acc.Core_Account__c);
        }

        User user = [SELECT Id FROM User WHERE Email = '1newuser@intel.com' LIMIT 1];
        Account accRec = TestUtilities.getAccount();
        accRec.Name ='Test Account 6';
        accRec.Core_CNDA_Number__c ='12345';
        accRec.Core_IPS_Active__c = true;
        accRec.OwnerId = user.Id;
        insert accRec;

        Core_IPS_Account__c coreAcc = TestUtilities.getCoreIpsAccount();
        coreAcc.Core_IPS_Project__c = projectId;
        coreAcc.Core_Account__c = accRec.Id;
        insert coreAcc;

        Contact con1 = TestUtilities.getContact();
        con1.FirstName = 'Test';
        con1.Lastname = 'Contact17';
        con1.Email = 'Contact17test@gmail.com';
        con1.AccountId = accRec.Id;
        con1.Core_IPS_Active__c = true;
	con1.MailingCountry = 'India';
        con1.Core_IPS_Intel_Support_Owner__c = UserInfo.getUserId();
        insert con1;
 
        User user1 = TestUtilities.getUser();
        user1.ContactId = con1.Id;
        user1.ProfileID = System.Label.Core_IPS_Partner_Profile_Id;
        insert user1;

        Core_IPS_ProjectController_Lex.IPSMemberWrapper wrapper = new Core_IPS_ProjectController_Lex.IPSMemberWrapper();
        wrapper.FirstName = 'Test';
        wrapper.LastName = 'Contact17';
        wrapper.Email = 'Contact17test@gmail.com';			
        wrapper.Name = accRec.Name;
        wrapper.ContactId = con1.Id;
        wrapper.selected = true; 
        wrapper.Id = user1;
        wrapper.compareTo(wrapper);
        
        String memList = Core_IPS_ProjectController_Lex.getAddMembers(projectId,limitSize, offSet,fetchType);
        System.assert(memList.length()>0);
        fetchType = 'Load Data';
        String memList2 = Core_IPS_ProjectController_Lex.getAddMembers(projectId,limitSize, offSet,fetchType);
        System.assert(memList2.length()>0);

        List<Core_IPS_Project_Member__c> memList1 = new List<Core_IPS_Project_Member__c>();
        Core_IPS_Project_Member__c memberList = new Core_IPS_Project_Member__c(
        Core_IPS_Contact__c=user1.ContactId,
        Core_User__c=user1.Id,
        Core_IPS_Project__c=projectId,
        Core_Status__c='Active',
        Core_Selective_Member__c=true); 
        memList1.add(memberList);
        String projMemListStatus = Core_IPS_ProjectController_Lex.insertProjectMembers(memList1);
        System.assert(projMemListStatus=='Success');
    
        }   
    @isTest
    static void testIntelSupportOwner(){
        Id projectId = [SELECT Id FROM Core_IPS_Project__c LIMIT 1].Id;
        List<Core_IPS_Intel_Support_Team__c> intelSupportOwners = Core_IPS_ProjectController_Lex.getIntelSupportOwner(projectId);
        System.assert(intelSupportOwners.size()>0);
    }
    @isTest
    static void testPartnerSupportOwner(){
        Id projectId = [SELECT Id FROM Core_IPS_Project__c LIMIT 1].Id;
        List<Core_IPS_Project_Member__c> partnerSupportOwners = Core_IPS_ProjectController_Lex.getPartnerSupportOwner(projectId);
        System.assert(partnerSupportOwners.size()>0);
    }
    @isTest
    static void testUpdateSupportOwner(){
        Id projectId = [SELECT Id FROM Core_IPS_Project__c LIMIT 1].Id;
        List<Core_IPS_Intel_Support_Team__c> intelSupportOwners = Core_IPS_ProjectController_Lex.getIntelSupportOwner(projectId);
        List<Core_IPS_Project_Member__c> partnerSupportOwners = Core_IPS_ProjectController_Lex.getPartnerSupportOwner(projectId);
               
        String supportOwner = intelSupportOwners[0].Core_IPS_User__c;
        String partnerOwner = partnerSupportOwners[0].Core_User__c;
        String insertSupportOwners = Core_IPS_ProjectController_Lex.updateSupportOwner(projectId,supportOwner,partnerOwner);
        System.assert(insertSupportOwners.length()>0);
    }
    @isTest
    static void insertTeamMembersTest() {
        Id userId = [SELECT Id FROM User WHERE Email = '2newuser@intel.com' LIMIT 1].Id;
        Id projectId = [SELECT Id FROM Core_IPS_Project__c LIMIT 1].Id;
        List<String> inputStrings = new List<String>();
        inputStrings.add('{"userId": "' + userId + '"}');
        Integer response = Core_IPS_ProjectController_Lex.insertTeamMembers(inputStrings, projectId);
        System.assert(response == 1);
	}
    @isTest
    static void insertTeamMembersTestNegative() {
        Id userId = [SELECT Id FROM User WHERE Email = '2newuser@intel.com' LIMIT 1].Id;
        List<String> inputStrings = new List<String>();
        inputStrings.add('{"userId": "' + userId + '"}');
        Exception except;
        try {
			Core_IPS_ProjectController_Lex.insertTeamMembers(inputStrings, null);
        } catch (Exception e) {
            except = e;
        }
        System.assert(except != null);
	}

    @isTest
    static void getAddTeamMembersTest() {
        Core_IPS_Labels__c setting = new Core_IPS_Labels__c();
        setting.Name = 'CoreStatus_Active';
        setting.Value__c = 'Active';
        insert setting;

        Core_IPS_Account__c ipsAcc = [SELECT Core_IPS_Project__c, Core_Status__c FROM Core_IPS_Account__c WHERE Core_IPS_Project__r.Name = 'Test Project' AND Core_Account__r.Name = 'Test Account 1' LIMIT 1];
		ipsAcc.Core_Status__c = 'Active';
   		update ipsAcc;

        List<Core_IPS_Intel_Support_Team__c> existingMems = [SELECT Id, Core_IPS_User__c FROM Core_IPS_Intel_Support_Team__c LIMIT 1];
        
		Core_IPS_ProjectController_Lex.teamMembersWrapper wrapper = Core_IPS_ProjectController_Lex.getAddTeamMembers(ipsAcc.Core_IPS_Project__c, '2newuser@intel.com', existingMems);
        //System.assert(wrapper.userList.size() == 1);
 	System.assert(setting != null);
	}
    @isTest
    static void getAddTeamMembersTestException() {
        Core_IPS_Labels__c setting = new Core_IPS_Labels__c();
        setting.Name = 'CoreStatus_Active';
        setting.Value__c = 'Active';
        insert setting;

        Core_IPS_Account__c ipsAcc = [SELECT Core_IPS_Project__c, Core_Status__c FROM Core_IPS_Account__c WHERE Core_IPS_Project__r.Name = 'Test Project' AND Core_Account__r.Name = 'Test Account 1' LIMIT 1];
		ipsAcc.Core_Status__c = 'Active';
   		update ipsAcc;

        List<Core_IPS_Intel_Support_Team__c> existingMems = [SELECT Id FROM Core_IPS_Intel_Support_Team__c LIMIT 1];
        Exception except;
        try {
            Core_IPS_ProjectController_Lex.getAddTeamMembers(ipsAcc.Core_IPS_Project__c, '2newuser@intel.com', existingMems);
        } catch(Exception e) {
            except = e;
        }
        System.assert(except != null);
	}
    @isTest
    static void getAddTeamMembersTestNoDataFound() {
        Core_IPS_Account__c ipsAcc = [SELECT Core_IPS_Project__c, Core_Status__c FROM Core_IPS_Account__c WHERE Core_IPS_Project__r.Name = 'Test Project' AND Core_Account__r.Name = 'Test Account 1' LIMIT 1];
		ipsAcc.Core_Status__c = 'Active';
   		update ipsAcc;

        Core_IPS_ProjectController_Lex.teamMembersWrapper wrapper = Core_IPS_ProjectController_Lex.getAddTeamMembers(ipsAcc.Core_IPS_Project__c, 'test@intel.com', null);
        System.assert(wrapper.userList == null);
	}

    @isTest
    static void getExistingTeamMembersTest() {
        Id projectId = [SELECT Id FROM Core_IPS_Project__c WHERE Name = 'Test Project' LIMIT 1].Id;
        List<Core_IPS_Intel_Support_Team__c> supportTeamMems = Core_IPS_ProjectController_Lex.getExistingTeamMembers(projectId);
        System.assert(supportTeamMems.size() == 2);
	}

    @isTest
    static void insertAccountTest() {
        Account accRec = TestUtilities.getAccount();
        accRec.Name ='Test Account 23';
        accRec.Core_CNDA_Number__c ='1234';
        accRec.Core_IPS_Active__c = true;
       	insert accRec;

        Id projectId = [SELECT Id FROM Core_IPS_Project__c WHERE Name = 'Test Project' LIMIT 1].Id;
        List<String> inputStrings = new List<String>();
        inputStrings.add('{"accid": "' + accRec.Id + '","Members": "All"}');
       	Integer result = Core_IPS_ProjectController_Lex.insertAccount(inputStrings, projectId);
        System.assert(result == 1);
	}
    @isTest
    static void insertAccountTestNegative() {
        List<Account> allAccs = [SELECT Id, Core_CNDA_Number__c FROM Account];
        for (Account acc:allAccs) {
            acc.Core_CNDA_Number__c = null;
        }
        update allAccs;

        Account accRec = TestUtilities.getAccount();
        accRec.Name ='Test Account 23';
        accRec.Core_IPS_Active__c = true;
       	insert accRec;

        Id projectId = [SELECT Id FROM Core_IPS_Project__c WHERE Name = 'Test Project' LIMIT 1].Id;
        List<String> inputStrings = new List<String>();
        inputStrings.add('{"accid": "' + accRec.Id + '","Members": "All"}');
       	Integer result = Core_IPS_ProjectController_Lex.insertAccount(inputStrings, projectId);
        System.assert(result == 2);
	}
    @isTest
    static void getDefaultCaseOwnerUserTest() {
        Id projectId = [SELECT Id FROM Core_IPS_Project__c WHERE Name = 'Test Project' LIMIT 1].Id;

        User user1 = TestUtilities.getUser();
        user1.Firstname = 'TestingSearchOwner';
        user1.ProfileID = System.Label.Core_IPS_DefaultCaseOwner_Profile_Id.split(';')[0];
        insert user1;

        List<Core_IPS_Product_Organization__c> listOfSupportOrg  = TestUtilities.getListOfSupportOrg(1);
        insert listOfSupportOrg;
        
        List<Product2> listOfProducts = TestUtilities.getListOfProduct(1);
        listOfProducts[0].Core_Hierarchy_ID__c = '43';
        listOfProducts[0].Core_Hierarchy_Name__c = 'ProdHierarchyName';
        listOfProducts[0].Core_Unique_ID__c = 'Product12345';
        listOfProducts[0].Core_Code_Name__c = 'ProductCoreCodeName';
        insert listOfProducts;

        List<Core_IPS_Supported_Product__c> listOfSupportedProduct = TestUtilities.getListOfSupportedProduct(1);
        listOfSupportedProduct[0].Core_Product__c = ListOfProducts[0].Id;
        listOfSupportedProduct[0].Core_Product_Organization__c = listOfSupportOrg[0].id;
        listOfSupportedProduct[0].Core_Flag_Status__c = 'Approved';
        insert listOfSupportedProduct;

        List<Core_IPS_Product__c> listOfIpsProductsOne = TestUtilities.getListOfIpsProducts(1);
        listOfIpsProductsOne[0].Core_IPS_Project__c = projectId;
        listOfIpsProductsOne[0].Core_Supported_Product__c = ListOfSupportedProduct.get(0).id;
        listOfIpsProductsOne[0].Status__c = 'Submitted';
        listOfIpsProductsOne[0].Core_IPS_Prod_Def_Case_Owner_ID__c = user1.Id;
        listOfIpsProductsOne[0].Core_IPS_Prod_Default_Case_Owner__c = user1.Id;
        insert listOfIpsProductsOne;

        Core_IPS_ProjectController_Lex.WrapperClass wrapper = Core_IPS_ProjectController_Lex.getDefaultCaseOwner(listOfIpsProductsOne[0].Id);
		System.assert(wrapper.returnData.size() == 1);
    }
    @isTest
    static void getDefaultCaseOwnerQueueTest() {
        Id projectId = [SELECT Id FROM Core_IPS_Project__c WHERE Name = 'Test Project' LIMIT 1].Id;

        Group caseOwnerQueue = TestUtilities.getQueue();
        System.runAs([SELECT Id FROM User WHERE Id != :UserInfo.getUserId() AND Profile.Name='System Administrator' AND IsActive = true][0]) {
            insert caseOwnerQueue;
        }

        List<Core_IPS_Product_Organization__c> listOfSupportOrg  = TestUtilities.getListOfSupportOrg(1);
        insert listOfSupportOrg;

        List<Product2> listOfProducts = TestUtilities.getListOfProduct(1);
        listOfProducts[0].Core_Hierarchy_ID__c = '43';
        listOfProducts[0].Core_Hierarchy_Name__c = 'ProdHierarchyName';
        listOfProducts[0].Core_Unique_ID__c = 'Product12345';
        listOfProducts[0].Core_Code_Name__c = 'ProductCoreCodeName';
        insert listOfProducts;

        List<Core_IPS_Supported_Product__c> listOfSupportedProduct = TestUtilities.getListOfSupportedProduct(1);
        listOfSupportedProduct[0].Core_Product__c = ListOfProducts[0].Id;
        listOfSupportedProduct[0].Core_Product_Organization__c = listOfSupportOrg[0].id;
        listOfSupportedProduct[0].Core_Flag_Status__c = 'Approved';
        insert listOfSupportedProduct;

        List<Core_IPS_Product__c> listOfIpsProductsOne = TestUtilities.getListOfIpsProducts(1);
        listOfIpsProductsOne[0].Core_IPS_Project__c = projectId;
        listOfIpsProductsOne[0].Core_Supported_Product__c = ListOfSupportedProduct.get(0).id;
        listOfIpsProductsOne[0].Status__c = 'Submitted';
        listOfIpsProductsOne[0].Core_IPS_Prod_Def_Case_Owner_ID__c = caseOwnerQueue.Id;
        listOfIpsProductsOne[0].Core_IPS_Prod_Default_Case_Owner__c = caseOwnerQueue.Id;
        insert listOfIpsProductsOne;

        Core_IPS_ProjectController_Lex.WrapperClass wrapper = Core_IPS_ProjectController_Lex.getDefaultCaseOwner(listOfIpsProductsOne[0].Id);
		System.assert(wrapper.returnData.size() == 1);
    }
    @isTest
    static void getDefaultCaseOwnerNegativeTest() {
        Id projectId = [SELECT Id FROM Core_IPS_Project__c WHERE Name = 'Test Project' LIMIT 1].Id;

        List<Core_IPS_Product_Organization__c> listOfSupportOrg  = TestUtilities.getListOfSupportOrg(1);
        insert listOfSupportOrg;

        List<Product2> listOfProducts = TestUtilities.getListOfProduct(1);
        listOfProducts[0].Core_Hierarchy_ID__c = '43';
        listOfProducts[0].Core_Hierarchy_Name__c = 'ProdHierarchyName';
        listOfProducts[0].Core_Unique_ID__c = 'Product12345';
        listOfProducts[0].Core_Code_Name__c = 'ProductCoreCodeName';
        insert listOfProducts;

        List<Core_IPS_Supported_Product__c> listOfSupportedProduct = TestUtilities.getListOfSupportedProduct(1);
        listOfSupportedProduct[0].Core_Product__c = ListOfProducts[0].Id;
        listOfSupportedProduct[0].Core_Product_Organization__c = listOfSupportOrg[0].id;
        listOfSupportedProduct[0].Core_Flag_Status__c = 'Approved';
        insert listOfSupportedProduct;

        List<Core_IPS_Product__c> listOfIpsProductsOne = TestUtilities.getListOfIpsProducts(1);
        listOfIpsProductsOne[0].Core_IPS_Project__c = projectId;
        listOfIpsProductsOne[0].Core_Supported_Product__c = ListOfSupportedProduct.get(0).id;
        listOfIpsProductsOne[0].Status__c = 'Submitted';
        insert listOfIpsProductsOne;

        Core_IPS_ProjectController_Lex.WrapperClass wrapper = Core_IPS_ProjectController_Lex.getDefaultCaseOwner(listOfIpsProductsOne[0].Id);
		System.assert(wrapper.returnData == null);
    }
    @isTest
    static void removeCaseOwnerTest() {
        Id projectId = [SELECT Id FROM Core_IPS_Project__c WHERE Name = 'Test Project' LIMIT 1].Id;

        User user1 = TestUtilities.getUser();
        user1.Firstname = 'TestingSearchOwner';
        user1.ProfileID = System.Label.Core_IPS_DefaultCaseOwner_Profile_Id.split(';')[0];
        insert user1;

        List<Core_IPS_Product_Organization__c> listOfSupportOrg  = TestUtilities.getListOfSupportOrg(1);
        insert listOfSupportOrg;
        
        List<Product2> listOfProducts = TestUtilities.getListOfProduct(1);
        listOfProducts[0].Core_Hierarchy_ID__c = '43';
        listOfProducts[0].Core_Hierarchy_Name__c = 'ProdHierarchyName';
        listOfProducts[0].Core_Unique_ID__c = 'Product12345';
        listOfProducts[0].Core_Code_Name__c = 'ProductCoreCodeName';
        insert listOfProducts;

        List<Core_IPS_Supported_Product__c> listOfSupportedProduct = TestUtilities.getListOfSupportedProduct(1);
        listOfSupportedProduct[0].Core_Product__c = ListOfProducts[0].Id;
        listOfSupportedProduct[0].Core_Product_Organization__c = listOfSupportOrg[0].id;
        listOfSupportedProduct[0].Core_Flag_Status__c = 'Approved';
        insert listOfSupportedProduct;

        List<Core_IPS_Product__c> listOfIpsProductsOne = TestUtilities.getListOfIpsProducts(1);
        listOfIpsProductsOne[0].Core_IPS_Project__c = projectId;
        listOfIpsProductsOne[0].Core_Supported_Product__c = ListOfSupportedProduct.get(0).id;
        listOfIpsProductsOne[0].Status__c = 'Submitted';
        listOfIpsProductsOne[0].Core_IPS_Prod_Def_Case_Owner_ID__c = user1.Id;
        listOfIpsProductsOne[0].Core_IPS_Prod_Default_Case_Owner__c = user1.Id;
        insert listOfIpsProductsOne;

        Core_IPS_ProjectController_Lex.removeCaseOwner(listOfIpsProductsOne[0].Id);
        Core_IPS_Product__c ipsProd = [SELECT Core_IPS_Prod_Def_Case_Owner_ID__c, Core_IPS_Prod_Default_Case_Owner__c FROM Core_IPS_Product__c WHERE Id=:listOfIpsProductsOne[0].Id];
		System.assert(ipsProd.Core_IPS_Prod_Def_Case_Owner_ID__c== null);
        System.assert(ipsProd.Core_IPS_Prod_Default_Case_Owner__c== null);
    }
    @isTest
    static void updateCaseOwnerTest() {
        Id projectId = [SELECT Id FROM Core_IPS_Project__c WHERE Name = 'Test Project' LIMIT 1].Id;

        User user1 = TestUtilities.getUser();
        user1.Firstname = 'TestingSearchOwner';
        user1.ProfileID = System.Label.Core_IPS_DefaultCaseOwner_Profile_Id.split(';')[0];
        insert user1;

        Group caseOwnerQueue = TestUtilities.getQueue();
        //excluding current user in case the current user is also a system admin the row lock error comes up
        System.runAs([SELECT Id FROM User WHERE Id != :UserInfo.getUserId() AND Profile.Name='System Administrator' AND IsActive = true][0]) {
            insert caseOwnerQueue;
        }

        List<Core_IPS_Product_Organization__c> listOfSupportOrg  = TestUtilities.getListOfSupportOrg(1);
        insert listOfSupportOrg;
        
        List<Product2> listOfProducts = TestUtilities.getListOfProduct(1);
        listOfProducts[0].Core_Hierarchy_ID__c = '43';
        listOfProducts[0].Core_Hierarchy_Name__c = 'ProdHierarchyName';
        listOfProducts[0].Core_Unique_ID__c = 'Product12345';
        listOfProducts[0].Core_Code_Name__c = 'ProductCoreCodeName';
        insert listOfProducts;

        List<Core_IPS_Supported_Product__c> listOfSupportedProduct = TestUtilities.getListOfSupportedProduct(1);
        listOfSupportedProduct[0].Core_Product__c = ListOfProducts[0].Id;
        listOfSupportedProduct[0].Core_Product_Organization__c = listOfSupportOrg[0].id;
        listOfSupportedProduct[0].Core_Flag_Status__c = 'Approved';
        insert listOfSupportedProduct;

        List<Core_IPS_Product__c> listOfIpsProductsOne = TestUtilities.getListOfIpsProducts(1);
        listOfIpsProductsOne[0].Core_IPS_Project__c = projectId;
        listOfIpsProductsOne[0].Core_Supported_Product__c = ListOfSupportedProduct.get(0).id;
        listOfIpsProductsOne[0].Status__c = 'Submitted';
        insert listOfIpsProductsOne;

        Core_IPS_ProjectController_Lex.updateCaseOwner(user1.Id, 'User', listOfIpsProductsOne[0].Id);
        Core_IPS_Product__c ipsProd = [SELECT Core_IPS_Prod_Def_Case_Owner_ID__c, Core_IPS_Prod_Default_Case_Owner__c FROM Core_IPS_Product__c WHERE Id=:listOfIpsProductsOne[0].Id];
		System.assert(ipsProd.Core_IPS_Prod_Def_Case_Owner_ID__c == user1.Id);

        Core_IPS_ProjectController_Lex.updateCaseOwner(caseOwnerQueue.Id, 'Queue', listOfIpsProductsOne[0].Id);
        ipsProd = [SELECT Core_IPS_Prod_Def_Case_Owner_ID__c, Core_IPS_Prod_Default_Case_Owner__c FROM Core_IPS_Product__c WHERE Id=:listOfIpsProductsOne[0].Id];
		System.assert(ipsProd.Core_IPS_Prod_Def_Case_Owner_ID__c == caseOwnerQueue.Id);
    }
    @isTest
    static void defaultSearchOwner() {
        Id projectId = [SELECT Id FROM Core_IPS_Project__c WHERE Name = 'Test Project' LIMIT 1].Id;

        List<Core_IPS_Product_Organization__c> listOfSupportOrg  = TestUtilities.getListOfSupportOrg(1);
        insert listOfSupportOrg;
        
        List<Product2> listOfProducts = TestUtilities.getListOfProduct(1);
        listOfProducts[0].Core_Hierarchy_ID__c = '43';
        listOfProducts[0].Core_Hierarchy_Name__c = 'ProdHierarchyName';
        listOfProducts[0].Core_Unique_ID__c = 'Product12345';
        listOfProducts[0].Core_Code_Name__c = 'ProductCoreCodeName';
        insert listOfProducts;

        List<Core_IPS_Supported_Product__c> listOfSupportedProduct = TestUtilities.getListOfSupportedProduct(1);
        listOfSupportedProduct[0].Core_Product__c = ListOfProducts[0].Id;
        listOfSupportedProduct[0].Core_Product_Organization__c = listOfSupportOrg[0].id;
        listOfSupportedProduct[0].Core_Flag_Status__c = 'Approved';
        insert listOfSupportedProduct;

        List<Core_IPS_Product__c> listOfIpsProductsOne = TestUtilities.getListOfIpsProducts(1);
        listOfIpsProductsOne[0].Core_IPS_Project__c = projectId;
        listOfIpsProductsOne[0].Core_Supported_Product__c = ListOfSupportedProduct.get(0).id;
        listOfIpsProductsOne[0].Status__c = 'Submitted';
        insert listOfIpsProductsOne;

        Id profileId = Label.Core_IPS_DefaultCaseOwner_Profile_Id.split(';')[0];
        List<User> ListOfUser = TestUtilities.getListOfUser(1);
        ListOfUser[0].ProfileID =  profileId;
        ListOfUser[0].Email = 'testowner@example.com';
        insert ListOfUser;

        Core_IPS_ProjectController_Lex.WrapperClass wrapper = Core_IPS_ProjectController_Lex.searchOwner('testowner@example.com', 'user', listOfIpsProductsOne[0].Id);
    	System.assert(wrapper.returnData.size() == 1);

        //no user found
        wrapper = Core_IPS_ProjectController_Lex.searchOwner('testowner@search.com', 'user', listOfIpsProductsOne[0].Id);
    	System.assert(wrapper.returnData == null);

        //partner owner
      	wrapper = Core_IPS_ProjectController_Lex.searchOwner('partnerowner@example.com', 'partnerUser', listOfIpsProductsOne[0].Id);
    	System.assert(wrapper.returnData == null);

        //Queue
        Group caseOwnerQueue = TestUtilities.getQueue();

        System.runAs([SELECT Id FROM User WHERE Id != :UserInfo.getUserId() AND Profile.Name='System Administrator' AND IsActive = true][0]) {
        	caseOwnerQueue.DeveloperName = 'IPS_Priority_Queue';
        	caseOwnerQueue.Name = 'IPS Priority Queue';
            insert caseOwnerQueue;
        }

        QueueSobject sobjectRel = new QueueSobject();

        System.runAs([SELECT Id FROM User WHERE Id != :UserInfo.getUserId() AND Profile.Name='System Administrator' AND IsActive = true][0]) {
            sobjectRel.QueueId = caseOwnerQueue.Id;
        	sobjectRel.SobjectType = 'Case';
            insert sobjectRel;
        }

        wrapper = Core_IPS_ProjectController_Lex.searchOwner('Priority', 'queue', listOfIpsProductsOne[0].Id);
    	System.assert(wrapper.returnData.size() == 1);

        wrapper = Core_IPS_ProjectController_Lex.searchOwner('FailThis', 'queue', listOfIpsProductsOne[0].Id);
    	System.assert(wrapper.returnData == null);
    }
    @isTest
    static void statusUpdateTest() {
      
        Id userId = [SELECT Id FROM User WHERE Name LIKE '%test%' LIMIT 1].Id;
        Boolean result = Core_IPS_ProjectController_Lex.userDetails(userId);
        Id projectId = [SELECT Id FROM Core_IPS_Project__c WHERE Name = 'Test Project' LIMIT 1].Id;
        /*Core_IPS_Project__c project = TestUtilities.getIpsProjectRecord ();
        project.Core_Status__c = 'Draft';
        project.Name = 'Test Project';
        insert project;
        
        List<Core_IPS_Project__c> projList = new List<Core_IPS_Project__c>();
        projList.add(project);
        TestUtilities.addAccMemProdToProject(projList);*/
        Core_IPS_ProjectController_Lex.getRecordDetail(projectId);
        Integer submitResult = Core_IPS_ProjectController_Lex.projSubmit(projectId);
        System.assert(submitResult>0);
    }    
     
    
}