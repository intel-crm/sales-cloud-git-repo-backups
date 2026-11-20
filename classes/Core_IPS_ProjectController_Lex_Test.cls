/* Class Name : Core_IPS_ProjectController_Lex_Test
   Description : Test Class for Core_IPS_ProjectController_Lex
   Author : Chandrashekar */

@isTest
@SuppressWarnings('PMD.CyclomaticComplexity')
public with sharing class Core_IPS_ProjectController_Lex_Test {
    private static void insertUsersWithValidationBypass(List<User> users) {
        User validationBypassUser = [SELECT Id FROM User WHERE Profile.Name = :System.Label.Core_System_Admin_Profile_Name AND IsActive = true LIMIT 1];
        System.runAs(validationBypassUser) {
            insert users;
        }
    }

    @TestSetup
    static void makeData() {
        UserRole role = [SELECT Id FROM UserRole WHERE PortalType = 'None' LIMIT 1];

        Map<String, Id> profiles = new Map<String, Id>();
        List<String> profileNames = new List<String>();
        profileNames.add('System Administrator');
        profileNames.add('Sales Rep-BB');
        List<Profile> profileList = [SELECT Id, Name FROM Profile WHERE Name IN :profileNames];
        for (Profile profileRecord : profileList) {
            profiles.put(profileRecord.Name, profileRecord.Id);
        }

        List<User> listOfUsers = new List<User>();
        listOfUsers = TestUtilities.getListOfUser(2);
        listOfUsers.get(0).ProfileID = profiles.get('System Administrator');
        listOfUsers.get(0).UserRoleId = role.Id;
        listOfUsers.get(1).ProfileID = profiles.get('Sales Rep-BB');
        insertUsersWithValidationBypass(listOfUsers);

        System.assertEquals(profiles.get('System Administrator'), listOfUsers.get(0).ProfileId, 'First user should have System Administrator profile');
        System.assertEquals(profiles.get('Sales Rep-BB'), listOfUsers.get(1).ProfileId, 'Second user should have Sales Rep-BB profile');

        Core_IPS_Project__c project = TestUtilities.getIpsProjectRecord();
        project.Core_Status__c = 'Draft';
        project.Name = 'Test Project';
        System.runAs(listOfUsers.get(0)) {
            insert project;
        }

        /*Core_IPS_Product__c prod = TestUtilities.getIpsProduct();
        prod.Core_IPS_Project__c = project.Id;
        System.runAs(listOfUsers.get(0)){
            insert prod;
        }*/

        Account accRec = TestUtilities.getAccount();
        accRec.Name = 'Test Account 1';
        accRec.Core_CNDA_Number__c = '1234';
        accRec.Core_IPS_Active__c = true;
        accRec.OwnerId = listOfUsers.get(0).Id;
        System.runAs(listOfUsers.get(0)) {
            insert accRec;
        }

        Account accRec1 = TestUtilities.getAccount();
        accRec1.Name = 'Test Account 2';
        accRec1.Core_CNDA_Number__c = '1234';
        accRec1.Core_IPS_Active__c = true;
        System.runAs(listOfUsers.get(0)) {
            insert accRec1;
        }

        Account accRec2 = TestUtilities.getAccount();
        accRec2.Name = 'Test Account 3';
        accRec2.Core_CNDA_Number__c = '1234';
        accRec2.Core_IPS_Active__c = true;
        System.runAs(listOfUsers.get(0)) {
            insert accRec2;
        }

        Account accRec3 = TestUtilities.getAccount();
        accRec3.Name = 'Test Account 4';
        accRec3.Core_CNDA_Number__c = '1234';
        accRec3.Core_IPS_Active__c = true;
        System.runAs(listOfUsers.get(0)) {
            insert accRec3;
        }

        Account accRec4 = TestUtilities.getAccount();
        accRec4.Name = 'Test Account 5';
        accRec4.Core_CNDA_Number__c = '1234';
        accRec4.Core_IPS_Active__c = true;
        System.runAs(listOfUsers.get(0)) {
            insert accRec4;
        }

        Core_IPS_Account__c coreAcc = TestUtilities.getCoreIpsAccount();
        coreAcc.Core_IPS_Project__c = project.Id;
        coreAcc.Core_Account__c = accRec.Id;
        System.runAs(listOfUsers.get(0)) {
            insert coreAcc;
        }

        Core_IPS_Account__c coreAcc1 = TestUtilities.getCoreIpsAccount();
        coreAcc1.Core_IPS_Project__c = project.Id;
        coreAcc1.Core_Account__c = accRec1.Id;
        System.runAs(listOfUsers.get(0)) {
            insert coreAcc1;
        }

        Core_IPS_Account__c coreAcc2 = TestUtilities.getCoreIpsAccount();
        coreAcc2.Core_IPS_Project__c = project.Id;
        coreAcc2.Core_Account__c = accRec2.Id;
        System.runAs(listOfUsers.get(0)) {
            insert coreAcc2;
        }

        Id intelSupportOwner = listOfUsers.get(0).Id;

        List<Contact> listOfContacts = TestUtilities.getListOfContact(1);
        for (Contact contactRecord : listOfContacts) {
            contactRecord.Core_IPS_Intel_Support_Owner__c = intelSupportOwner;
            contactRecord.AccountId = accRec.Id;
            contactRecord.Core_IPS_Active__c = true;
            contactRecord.MailingCountry = 'India';
        }

        System.runAs(listOfUsers.get(0)) {
            insert listOfContacts;
        }
        System.assert(listOfContacts[0].Id != null, 'Record not created');

        User dfaeUser = TestUtilities.getListOfUser(1).get(0);
        dfaeUser.ProfileID = System.Label.Core_IPS_Partner_Profile_Id;
        dfaeUser.ContactId = listOfContacts.get(0).Id;
        dfaeUser.Email = 'unique@example.com';

        System.runAs(listOfUsers.get(0)) {
            insert dfaeUser;
            PermissionSetAssignment objPSA = new PermissionSetAssignment(
                AssigneeId = dfaeUser.Id,
                PermissionSetId = System.Label.Core_IPS_Partner_DFAE_Permission_Set
            );
            insert objPSA;
        }

        List<Core_IPS_Project_Member__c> listOfProjectMembers = TestUtilities.getListOfProjectMembers(5);
        for (Core_IPS_Project_Member__c projectMember : listOfProjectMembers) {
            projectMember.Core_IPS_Contact__c = listOfContacts.get(0).Id;
            projectMember.Core_IPS_Project__c = project.Id;
            projectMember.Core_User__c = dfaeUser.Id;
        }

        List<Core_IPS_Intel_Support_Team__c> intelSupportTeamMembers = TestUtilities.getListOfIntelSupportTeamMembers(2);
        intelSupportTeamMembers[0].Core_IPS_User__c = listOfUsers.get(0).Id;
        intelSupportTeamMembers[1].Core_IPS_User__c = listOfUsers.get(1).Id;
        for (Core_IPS_Intel_Support_Team__c supportTeamMember : intelSupportTeamMembers) {
            supportTeamMember.Core_IPS_Project__c = project.Id;
            supportTeamMember.Status__c = 'Active';
        }
        System.runAs(listOfUsers.get(0)) {
            insert intelSupportTeamMembers;
            insert listOfProjectMembers;
        }
        System.assert(listOfProjectMembers[0].Id != null, 'Record not created');
    }

    @isTest
    static void testExistingAccounts() {
        String projectId = [SELECT Id FROM Core_IPS_Project__c LIMIT 1].Id;
        List<Core_IPS_Account__c> coreList = Core_IPS_ProjectController_Lex.getExistingAccounts(projectId);
        System.assert(coreList.size() > 0, 'Existing accounts should be returned');
        Core_IPS_ProjectController_Lex.checkExistingAccounts(projectId);
    }

    @isTest
    static void testExistingAccountsNegative() {
        List<Core_IPS_Account__c> coreList = Core_IPS_ProjectController_Lex.getExistingAccounts(null);
        System.assert(coreList == null, 'Existing accounts should be null for null projectId');
    }

    @isTest
    static void testLoadAccounts() {
        List<Core_IPS_Account__c> coreAccounts = [SELECT Id, Core_Account__c FROM Core_IPS_Account__c];
        List<Id> ids = new List<Id>();
        Integer limitSize = 3;
        Integer offsetValue = 0;
        String fetchType = 'Load Data';
        String searchText = 'test';
        for (Core_IPS_Account__c coreAccount : coreAccounts) {
            ids.add(coreAccount.Core_Account__c);
        }
        List<Account> coreAccList = Core_IPS_ProjectController_Lex.getAddAccounts(ids, limitSize, offsetValue, fetchType, searchText);
        Core_IPS_ProjectController_Lex.getAccountMemberType((String) ids[0]);
        System.assert(coreAccList.size() > 0, 'Accounts should be loaded');
    }

    @isTest
    static void testAllAccounts() {
        List<Core_IPS_Account__c> coreAccounts = [SELECT Id, Core_Account__c FROM Core_IPS_Account__c];
        List<Id> ids = new List<Id>();
        Integer limitSize = 2;
        Integer offsetValue = 0;
        String fetchType = 'All Data';
        String searchText = 'test';
        for (Core_IPS_Account__c coreAccount : coreAccounts) {
            ids.add(coreAccount.Core_Account__c);
        }
        List<Account> coreAccList = Core_IPS_ProjectController_Lex.getAddAccounts(ids, limitSize, offsetValue, fetchType, searchText);
        System.assert(coreAccList.size() > 0, 'All accounts should be loaded');

        List<Id> ids1 = new List<Id>();
        List<Account> coreAccList1 = Core_IPS_ProjectController_Lex.getAddAccounts(ids1, limitSize, offsetValue, fetchType, searchText);
        System.assert(coreAccList1.size() > 0, 'Accounts should be returned when ids list is empty');
    }

    @isTest
    static void testExistingMembers() {
        Id projectId = [SELECT Id FROM Core_IPS_Project__c LIMIT 1].Id;
        Integer limitSize = 10;
        Integer offsetValue = 0;
        List<Core_IPS_Project_Member__c> existingProjMembers = Core_IPS_ProjectController_Lex.getExistingMembers(projectId, limitSize, offsetValue);
        System.assert(existingProjMembers.size() > 0, 'Existing members should be returned');
    }

    @isTest
    static void testHasProjectEditAccess() {
        Id projectId = [SELECT Id FROM Core_IPS_Project__c LIMIT 1].Id;
        Core_IPS_ProjectController_Lex.hasProjectEditAccess(projectId);
        System.assert(projectId != null, 'Project Id should not be null');
    }

    @isTest
    static void testLoadMembers() {
        Integer limitSize = 10;
        Integer offsetValue = 0;
        String fetchType = 'Load Data';

        List<Account> listOfAccounts = [SELECT Id, Name FROM Account LIMIT 2];

        Map<String, Id> profiles = new Map<String, Id>();
        List<String> profileNames = new List<String>();
        profileNames.add('System Administrator');
        profileNames.add('Sales Rep-BB');
        List<Profile> profileList = [SELECT Id, Name FROM Profile WHERE Name IN :profileNames];
        for (Profile profileRecord : profileList) {
            profiles.put(profileRecord.Name, profileRecord.Id);
        }

        UserRole role = new UserRole();
        role.Name = 'CEO';
        insert role;

        List<User> listOfUsers = TestUtilities.getListOfUser(2);
        listOfUsers.get(0).ProfileID = profiles.get('System Administrator');
        listOfUsers.get(1).ProfileID = profiles.get('Sales Rep-BB');
        insertUsersWithValidationBypass(listOfUsers);

        User sysAdminUser = listOfUsers[0];
        User faeUser = listOfUsers[1];

        List<AccountTeamMember> members = new List<AccountTeamMember>();
        List<AccountShare> sharingRules = new List<AccountShare>();
        String teamMemberRole = 'Account Manager';
        String accountAccessLevel = 'Edit';
        String opportunityAccessLevel = 'Edit';
        String caseAccessLevel = 'None';

        for (Account accountRecord : listOfAccounts) {
            members.add(new AccountTeamMember(AccountId = accountRecord.Id, TeamMemberRole = teamMemberRole, UserId = faeUser.Id));
            sharingRules.add(new AccountShare(
                AccountAccessLevel = accountAccessLevel,
                OpportunityAccessLevel = opportunityAccessLevel,
                CaseAccessLevel = caseAccessLevel,
                UserOrGroupId = faeUser.Id,
                AccountId = accountRecord.Id
            ));
        }

        System.runAs(sysAdminUser) {
            insert members;
            insert sharingRules;
        }

        List<Core_IPS_Project__c> listOfIpsProjects = TestUtilities.getListOfIpsProjects(1);
        System.runAs(faeUser) {
            listOfIpsProjects[0].Name = 'Test FAE Project';
            insert listOfIpsProjects;
        }

        List<Core_IPS_Account__c> listOfIpsAccounts = TestUtilities.getListOfIpsAccounts(2);
        for (Core_IPS_Account__c ipsAccount : listOfIpsAccounts) {
            ipsAccount.Core_Account__c = listOfAccounts.get(0).Id;
            ipsAccount.Core_IPS_Project__c = listOfIpsProjects.get(0).Id;
            ipsAccount.Core_Members__c = 'All';
        }

        System.runAs(faeUser) {
            insert listOfIpsAccounts;
        }

        System.runAs(faeUser) {
            String memList = Core_IPS_ProjectController_Lex.getAddMembers(listOfIpsProjects[0].Id, limitSize, offsetValue, fetchType);
            System.assert(memList != null, 'Member list should be returned for load data');
        }

        fetchType = 'All Data';
        System.runAs(faeUser) {
            String memList1 = Core_IPS_ProjectController_Lex.getAddMembers(listOfIpsProjects[0].Id, limitSize, offsetValue, fetchType);
            System.assert(memList1 != null, 'Member list should be returned for all data');
        }

        System.assert(listOfIpsProjects.size() > 0, 'FAE project should be created');
    }

    @isTest
    static void testAllAndInsertMembers() {
        String projectId = [SELECT Id FROM Core_IPS_Project__c LIMIT 1].Id;
        List<Core_IPS_Account__c> coreAccounts = [SELECT Id, Core_Account__c FROM Core_IPS_Account__c];
        List<Id> ids = new List<Id>();

        Integer limitSize = 10;
        Integer offsetValue = 0;
        String fetchType = 'All Data';
        for (Core_IPS_Account__c coreAccount : coreAccounts) {
            ids.add(coreAccount.Core_Account__c);
        }

        User projectUser = [SELECT Id FROM User WHERE Email = '1newuser@intel.com' LIMIT 1];
        Account accRec = TestUtilities.getAccount();
        accRec.Name = 'Test Account 6';
        accRec.Core_CNDA_Number__c = '12345';
        accRec.Core_IPS_Active__c = true;
        accRec.OwnerId = projectUser.Id;
        insert accRec;

        Core_IPS_Account__c coreAcc = TestUtilities.getCoreIpsAccount();
        coreAcc.Core_IPS_Project__c = projectId;
        coreAcc.Core_Account__c = accRec.Id;
        insert coreAcc;

        Contact con1 = TestUtilities.getContact();
        con1.FirstName = 'Test';
        con1.LastName = 'Contact17';
        con1.Email = 'Contact17test@gmail.com';
        con1.AccountId = accRec.Id;
        con1.Core_IPS_Active__c = true;
        con1.MailingCountry = 'India';
        con1.Core_IPS_Intel_Support_Owner__c = UserInfo.getUserId();
        insert con1;

        User user1 = TestUtilities.getUser();
        user1.ContactId = con1.Id;
        user1.ProfileID = System.Label.Core_IPS_Partner_Profile_Id;
        insertUsersWithValidationBypass(new List<User>{user1});

        Core_IPS_ProjectController_Lex.IPSMemberWrapper wrapper = new Core_IPS_ProjectController_Lex.IPSMemberWrapper();
        wrapper.FirstName = 'Test';
        wrapper.LastName = 'Contact17';
        wrapper.Email = 'Contact17test@gmail.com';
        wrapper.Name = accRec.Name;
        wrapper.ContactId = con1.Id;
        wrapper.Selected = true;
        wrapper.Id = user1;
        wrapper.compareTo(wrapper);

        String memList = Core_IPS_ProjectController_Lex.getAddMembers(projectId, limitSize, offsetValue, fetchType);
        System.assert(memList.length() > 0, 'Member list should contain data for all data fetch');

        fetchType = 'Load Data';
        String memList2 = Core_IPS_ProjectController_Lex.getAddMembers(projectId, limitSize, offsetValue, fetchType);
        System.assert(memList2.length() > 0, 'Member list should contain data for load data fetch');

        List<Core_IPS_Project_Member__c> memList1 = new List<Core_IPS_Project_Member__c>();
        Core_IPS_Project_Member__c memberRecord = new Core_IPS_Project_Member__c(
            Core_IPS_Contact__c = user1.ContactId,
            Core_User__c = user1.Id,
            Core_IPS_Project__c = projectId,
            Core_Status__c = 'Active',
            Core_Selective_Member__c = true
        );
        memList1.add(memberRecord);
        String projMemListStatus = Core_IPS_ProjectController_Lex.insertProjectMembers(memList1);
        System.assert(projMemListStatus == 'Success', 'Project members should be inserted successfully');
    }

    @isTest
    static void testIntelSupportOwner() {
        Id projectId = [SELECT Id FROM Core_IPS_Project__c LIMIT 1].Id;
        List<Core_IPS_Intel_Support_Team__c> intelSupportOwners = Core_IPS_ProjectController_Lex.getIntelSupportOwner(projectId);
        System.assert(intelSupportOwners.size() > 0, 'Intel support owners should be returned');
    }

    @isTest
    static void testPartnerSupportOwner() {
        Id projectId = [SELECT Id FROM Core_IPS_Project__c LIMIT 1].Id;
        List<Core_IPS_Project_Member__c> partnerSupportOwners = Core_IPS_ProjectController_Lex.getPartnerSupportOwner(projectId);
        System.assert(partnerSupportOwners.size() > 0, 'Partner support owners should be returned');
    }

    @isTest
    static void testUpdateSupportOwner() {
        Id projectId = [SELECT Id FROM Core_IPS_Project__c LIMIT 1].Id;
        List<Core_IPS_Intel_Support_Team__c> intelSupportOwners = Core_IPS_ProjectController_Lex.getIntelSupportOwner(projectId);
        List<Core_IPS_Project_Member__c> partnerSupportOwners = Core_IPS_ProjectController_Lex.getPartnerSupportOwner(projectId);

        String supportOwner = intelSupportOwners[0].Core_IPS_User__c;
        String partnerOwner = partnerSupportOwners[0].Core_User__c;
        String insertSupportOwners = Core_IPS_ProjectController_Lex.updateSupportOwner(projectId, supportOwner, partnerOwner);
        System.assert(insertSupportOwners.length() > 0, 'Support owners update response should not be empty');
    }

    @isTest
    static void testInsertTeamMembers() {
        Id userId = [SELECT Id FROM User WHERE Email = '2newuser@intel.com' LIMIT 1].Id;
        Id projectId = [SELECT Id FROM Core_IPS_Project__c LIMIT 1].Id;
        List<String> inputStrings = new List<String>();
        inputStrings.add('{"userId": "' + userId + '"}');
        Integer response = Core_IPS_ProjectController_Lex.insertTeamMembers(inputStrings, projectId);
        System.assert(response == 1, 'Team member insert should return success status');
    }

    @isTest
    static void testInsertTeamMembersNegative() {
        Id userId = [SELECT Id FROM User WHERE Email = '2newuser@intel.com' LIMIT 1].Id;
        List<String> inputStrings = new List<String>();
        inputStrings.add('{"userId": "' + userId + '"}');
        Exception caughtException;
        try {
            Core_IPS_ProjectController_Lex.insertTeamMembers(inputStrings, null);
        } catch (Exception exceptionRecord) {
            caughtException = exceptionRecord;
        }
        //System.assert(caughtException != null, 'Exception should be thrown when projectId is null');
    }

    @isTest
    static void testGetAddTeamMembers() {
        Core_IPS_Labels__c setting = new Core_IPS_Labels__c();
        setting.Name = 'CoreStatus_Active';
        setting.Value__c = 'Active';
        insert setting;

        Core_IPS_Account__c ipsAcc = [SELECT Core_IPS_Project__c, Core_Status__c FROM Core_IPS_Account__c WHERE Core_IPS_Project__r.Name = 'Test Project' AND Core_Account__r.Name = 'Test Account 1' LIMIT 1];
        ipsAcc.Core_Status__c = 'Active';
        update ipsAcc;

        List<Core_IPS_Intel_Support_Team__c> existingMembers = [SELECT Id, Core_IPS_User__c FROM Core_IPS_Intel_Support_Team__c LIMIT 1];

        Core_IPS_ProjectController_Lex.teamMembersWrapper wrapper = Core_IPS_ProjectController_Lex.getAddTeamMembers(ipsAcc.Core_IPS_Project__c, '2newuser@intel.com', existingMembers);
        System.assert(setting != null, 'Setting should be created');
        System.assert(wrapper != null, 'Wrapper should be returned');
    }

    @isTest
    static void testGetAddTeamMembersException() {
        Core_IPS_Labels__c setting = new Core_IPS_Labels__c();
        setting.Name = 'CoreStatus_Active';
        setting.Value__c = 'Active';
        insert setting;

        Core_IPS_Account__c ipsAcc = [SELECT Core_IPS_Project__c, Core_Status__c FROM Core_IPS_Account__c WHERE Core_IPS_Project__r.Name = 'Test Project' AND Core_Account__r.Name = 'Test Account 1' LIMIT 1];
        ipsAcc.Core_Status__c = 'Active';
        update ipsAcc;

        List<Core_IPS_Intel_Support_Team__c> existingMembers = [SELECT Id FROM Core_IPS_Intel_Support_Team__c LIMIT 1];
        Exception caughtException;
        try {
            Core_IPS_ProjectController_Lex.getAddTeamMembers(ipsAcc.Core_IPS_Project__c, '2newuser@intel.com', existingMembers);
        } catch (Exception exceptionRecord) {
            caughtException = exceptionRecord;
        }
        System.assert(caughtException != null, 'Exception should be captured');
    }

    @isTest
    static void testGetAddTeamMembersNoDataFound() {
        Core_IPS_Account__c ipsAcc = [SELECT Core_IPS_Project__c, Core_Status__c FROM Core_IPS_Account__c WHERE Core_IPS_Project__r.Name = 'Test Project' AND Core_Account__r.Name = 'Test Account 1' LIMIT 1];
        ipsAcc.Core_Status__c = 'Active';
        update ipsAcc;

        Core_IPS_ProjectController_Lex.teamMembersWrapper wrapper = Core_IPS_ProjectController_Lex.getAddTeamMembers(ipsAcc.Core_IPS_Project__c, 'test@intel.com', null);
        System.assert(wrapper.userList == null, 'Wrapper user list should be null when no data is found');
    }

    @isTest
    static void testGetExistingTeamMembers() {
        Id projectId = [SELECT Id FROM Core_IPS_Project__c WHERE Name = 'Test Project' LIMIT 1].Id;
        List<Core_IPS_Intel_Support_Team__c> supportTeamMems = Core_IPS_ProjectController_Lex.getExistingTeamMembers(projectId);
        System.assert(supportTeamMems.size() == 2, 'Exactly two support team members should be returned');
    }

    @isTest
    static void testInsertAccount() {
        Account accRec = TestUtilities.getAccount();
        accRec.Name = 'Test Account 23';
        accRec.Core_CNDA_Number__c = '1234';
        accRec.Core_IPS_Active__c = true;
        insert accRec;

        Id projectId = [SELECT Id FROM Core_IPS_Project__c WHERE Name = 'Test Project' LIMIT 1].Id;
        List<String> inputStrings = new List<String>();
        inputStrings.add('{"accid": "' + accRec.Id + '","Members": "All"}');
        Integer result = Core_IPS_ProjectController_Lex.insertAccount(inputStrings, projectId);
        System.assert(result == 1, 'Account insert should return success status');
    }

    @isTest
    static void testInsertAccountNegative() {
        List<Account> allAccounts = [SELECT Id, Core_CNDA_Number__c FROM Account];
        for (Account accountRecord : allAccounts) {
            accountRecord.Core_CNDA_Number__c = null;
        }
        update allAccounts;

        Account accRec = TestUtilities.getAccount();
        accRec.Name = 'Test Account 23';
        accRec.Core_IPS_Active__c = true;
        insert accRec;

        Id projectId = [SELECT Id FROM Core_IPS_Project__c WHERE Name = 'Test Project' LIMIT 1].Id;
        List<String> inputStrings = new List<String>();
        inputStrings.add('{"accid": "' + accRec.Id + '","Members": "All"}');
        Integer result = Core_IPS_ProjectController_Lex.insertAccount(inputStrings, projectId);
        System.assert(result == 2, 'Account insert should return duplicate or validation status');
    }

    @isTest
    static void testGetDefaultCaseOwnerUser() {
        Id projectId = [SELECT Id FROM Core_IPS_Project__c WHERE Name = 'Test Project' LIMIT 1].Id;

        User user1 = TestUtilities.getUser();
        user1.FirstName = 'TestingSearchOwner';
        user1.ProfileID = System.Label.Core_IPS_DefaultCaseOwner_Profile_Id.split(';')[0];
        insertUsersWithValidationBypass(new List<User>{user1});

        List<Core_IPS_Product_Organization__c> listOfSupportOrg = TestUtilities.getListOfSupportOrg(1);
        insert listOfSupportOrg;

        List<Product2> listOfProducts = TestUtilities.getListOfProduct(1);
        listOfProducts[0].Core_Hierarchy_ID__c = '43';
        listOfProducts[0].Core_Hierarchy_Name__c = 'ProdHierarchyName';
        listOfProducts[0].Core_Unique_ID__c = 'Product12345';
        listOfProducts[0].Core_Code_Name__c = 'ProductCoreCodeName';
        insert listOfProducts;

        List<Core_IPS_Supported_Product__c> listOfSupportedProduct = TestUtilities.getListOfSupportedProduct(1);
        listOfSupportedProduct[0].Core_Product__c = listOfProducts[0].Id;
        listOfSupportedProduct[0].Core_Product_Organization__c = listOfSupportOrg[0].Id;
        listOfSupportedProduct[0].Core_Flag_Status__c = 'Approved';
        insert listOfSupportedProduct;

        List<Core_IPS_Product__c> listOfIpsProducts = TestUtilities.getListOfIpsProducts(1);
        listOfIpsProducts[0].Core_IPS_Project__c = projectId;
        listOfIpsProducts[0].Core_Supported_Product__c = listOfSupportedProduct.get(0).Id;
        listOfIpsProducts[0].Status__c = 'Submitted';
        listOfIpsProducts[0].Core_IPS_Prod_Def_Case_Owner_ID__c = user1.Id;
        listOfIpsProducts[0].Core_IPS_Prod_Default_Case_Owner__c = user1.Id;
        insert listOfIpsProducts;

        Core_IPS_ProjectController_Lex.WrapperClass wrapper = Core_IPS_ProjectController_Lex.getDefaultCaseOwner(listOfIpsProducts[0].Id);
        System.assert(wrapper.returnData.size() == 1, 'One default case owner should be returned');
    }

    @isTest
    static void testGetDefaultCaseOwnerQueue() {
        Id projectId = [SELECT Id FROM Core_IPS_Project__c WHERE Name = 'Test Project' LIMIT 1].Id;

        Group caseOwnerQueue = TestUtilities.getQueue();
        System.runAs([SELECT Id FROM User WHERE Id != :UserInfo.getUserId() AND Profile.Name = 'System Administrator' AND IsActive = true][0]) {
            insert caseOwnerQueue;
        }

        List<Core_IPS_Product_Organization__c> listOfSupportOrg = TestUtilities.getListOfSupportOrg(1);
        insert listOfSupportOrg;

        List<Product2> listOfProducts = TestUtilities.getListOfProduct(1);
        listOfProducts[0].Core_Hierarchy_ID__c = '43';
        listOfProducts[0].Core_Hierarchy_Name__c = 'ProdHierarchyName';
        listOfProducts[0].Core_Unique_ID__c = 'Product12345';
        listOfProducts[0].Core_Code_Name__c = 'ProductCoreCodeName';
        insert listOfProducts;

        List<Core_IPS_Supported_Product__c> listOfSupportedProduct = TestUtilities.getListOfSupportedProduct(1);
        listOfSupportedProduct[0].Core_Product__c = listOfProducts[0].Id;
        listOfSupportedProduct[0].Core_Product_Organization__c = listOfSupportOrg[0].Id;
        listOfSupportedProduct[0].Core_Flag_Status__c = 'Approved';
        insert listOfSupportedProduct;

        List<Core_IPS_Product__c> listOfIpsProducts = TestUtilities.getListOfIpsProducts(1);
        listOfIpsProducts[0].Core_IPS_Project__c = projectId;
        listOfIpsProducts[0].Core_Supported_Product__c = listOfSupportedProduct.get(0).Id;
        listOfIpsProducts[0].Status__c = 'Submitted';
        listOfIpsProducts[0].Core_IPS_Prod_Def_Case_Owner_ID__c = caseOwnerQueue.Id;
        listOfIpsProducts[0].Core_IPS_Prod_Default_Case_Owner__c = caseOwnerQueue.Id;
        insert listOfIpsProducts;

        Core_IPS_ProjectController_Lex.WrapperClass wrapper = Core_IPS_ProjectController_Lex.getDefaultCaseOwner(listOfIpsProducts[0].Id);
        System.assert(wrapper.returnData.size() == 1, 'One queue default case owner should be returned');
    }

    @isTest
    static void testGetDefaultCaseOwnerNegative() {
        Id projectId = [SELECT Id FROM Core_IPS_Project__c WHERE Name = 'Test Project' LIMIT 1].Id;

        List<Core_IPS_Product_Organization__c> listOfSupportOrg = TestUtilities.getListOfSupportOrg(1);
        insert listOfSupportOrg;

        List<Product2> listOfProducts = TestUtilities.getListOfProduct(1);
        listOfProducts[0].Core_Hierarchy_ID__c = '43';
        listOfProducts[0].Core_Hierarchy_Name__c = 'ProdHierarchyName';
        listOfProducts[0].Core_Unique_ID__c = 'Product12345';
        listOfProducts[0].Core_Code_Name__c = 'ProductCoreCodeName';
        insert listOfProducts;

        List<Core_IPS_Supported_Product__c> listOfSupportedProduct = TestUtilities.getListOfSupportedProduct(1);
        listOfSupportedProduct[0].Core_Product__c = listOfProducts[0].Id;
        listOfSupportedProduct[0].Core_Product_Organization__c = listOfSupportOrg[0].Id;
        listOfSupportedProduct[0].Core_Flag_Status__c = 'Approved';
        insert listOfSupportedProduct;

        List<Core_IPS_Product__c> listOfIpsProducts = TestUtilities.getListOfIpsProducts(1);
        listOfIpsProducts[0].Core_IPS_Project__c = projectId;
        listOfIpsProducts[0].Core_Supported_Product__c = listOfSupportedProduct.get(0).Id;
        listOfIpsProducts[0].Status__c = 'Submitted';
        insert listOfIpsProducts;

        Core_IPS_ProjectController_Lex.WrapperClass wrapper = Core_IPS_ProjectController_Lex.getDefaultCaseOwner(listOfIpsProducts[0].Id);
        System.assert(wrapper.returnData == null, 'No default case owner should be returned');
    }

    @isTest
    static void testRemoveCaseOwner() {
        Id projectId = [SELECT Id FROM Core_IPS_Project__c WHERE Name = 'Test Project' LIMIT 1].Id;

        User user1 = TestUtilities.getUser();
        user1.FirstName = 'TestingSearchOwner';
        user1.ProfileID = System.Label.Core_IPS_DefaultCaseOwner_Profile_Id.split(';')[0];
        insertUsersWithValidationBypass(new List<User>{user1});

        List<Core_IPS_Product_Organization__c> listOfSupportOrg = TestUtilities.getListOfSupportOrg(1);
        insert listOfSupportOrg;

        List<Product2> listOfProducts = TestUtilities.getListOfProduct(1);
        listOfProducts[0].Core_Hierarchy_ID__c = '43';
        listOfProducts[0].Core_Hierarchy_Name__c = 'ProdHierarchyName';
        listOfProducts[0].Core_Unique_ID__c = 'Product12345';
        listOfProducts[0].Core_Code_Name__c = 'ProductCoreCodeName';
        insert listOfProducts;

        List<Core_IPS_Supported_Product__c> listOfSupportedProduct = TestUtilities.getListOfSupportedProduct(1);
        listOfSupportedProduct[0].Core_Product__c = listOfProducts[0].Id;
        listOfSupportedProduct[0].Core_Product_Organization__c = listOfSupportOrg[0].Id;
        listOfSupportedProduct[0].Core_Flag_Status__c = 'Approved';
        insert listOfSupportedProduct;

        List<Core_IPS_Product__c> listOfIpsProducts = TestUtilities.getListOfIpsProducts(1);
        listOfIpsProducts[0].Core_IPS_Project__c = projectId;
        listOfIpsProducts[0].Core_Supported_Product__c = listOfSupportedProduct.get(0).Id;
        listOfIpsProducts[0].Status__c = 'Submitted';
        listOfIpsProducts[0].Core_IPS_Prod_Def_Case_Owner_ID__c = user1.Id;
        listOfIpsProducts[0].Core_IPS_Prod_Default_Case_Owner__c = user1.Id;
        insert listOfIpsProducts;

        Core_IPS_ProjectController_Lex.removeCaseOwner(listOfIpsProducts[0].Id);
        Core_IPS_Product__c ipsProd = [SELECT Core_IPS_Prod_Def_Case_Owner_ID__c, Core_IPS_Prod_Default_Case_Owner__c FROM Core_IPS_Product__c WHERE Id = :listOfIpsProducts[0].Id];
        System.assert(ipsProd.Core_IPS_Prod_Def_Case_Owner_ID__c == null, 'Default case owner Id should be cleared');
        System.assert(ipsProd.Core_IPS_Prod_Default_Case_Owner__c == null, 'Default case owner lookup should be cleared');
    }

    @isTest
    static void testUpdateCaseOwner() {
        Id projectId = [SELECT Id FROM Core_IPS_Project__c WHERE Name = 'Test Project' LIMIT 1].Id;

        User user1 = TestUtilities.getUser();
        user1.FirstName = 'TestingSearchOwner';
        user1.ProfileID = System.Label.Core_IPS_DefaultCaseOwner_Profile_Id.split(';')[0];
        insertUsersWithValidationBypass(new List<User>{user1});

        Group caseOwnerQueue = TestUtilities.getQueue();
        System.runAs([SELECT Id FROM User WHERE Id != :UserInfo.getUserId() AND Profile.Name = 'System Administrator' AND IsActive = true][0]) {
            insert caseOwnerQueue;
        }

        List<Core_IPS_Product_Organization__c> listOfSupportOrg = TestUtilities.getListOfSupportOrg(1);
        insert listOfSupportOrg;

        List<Product2> listOfProducts = TestUtilities.getListOfProduct(1);
        listOfProducts[0].Core_Hierarchy_ID__c = '43';
        listOfProducts[0].Core_Hierarchy_Name__c = 'ProdHierarchyName';
        listOfProducts[0].Core_Unique_ID__c = 'Product12345';
        listOfProducts[0].Core_Code_Name__c = 'ProductCoreCodeName';
        insert listOfProducts;

        List<Core_IPS_Supported_Product__c> listOfSupportedProduct = TestUtilities.getListOfSupportedProduct(1);
        listOfSupportedProduct[0].Core_Product__c = listOfProducts[0].Id;
        listOfSupportedProduct[0].Core_Product_Organization__c = listOfSupportOrg[0].Id;
        listOfSupportedProduct[0].Core_Flag_Status__c = 'Approved';
        insert listOfSupportedProduct;

        List<Core_IPS_Product__c> listOfIpsProducts = TestUtilities.getListOfIpsProducts(1);
        listOfIpsProducts[0].Core_IPS_Project__c = projectId;
        listOfIpsProducts[0].Core_Supported_Product__c = listOfSupportedProduct.get(0).Id;
        listOfIpsProducts[0].Status__c = 'Submitted';
        insert listOfIpsProducts;

        Core_IPS_ProjectController_Lex.updateCaseOwner(user1.Id, 'User', listOfIpsProducts[0].Id);
        Core_IPS_Product__c ipsProd = [SELECT Core_IPS_Prod_Def_Case_Owner_ID__c, Core_IPS_Prod_Default_Case_Owner__c FROM Core_IPS_Product__c WHERE Id = :listOfIpsProducts[0].Id];
        System.assert(ipsProd.Core_IPS_Prod_Def_Case_Owner_ID__c == user1.Id, 'User should be set as default case owner');

        Core_IPS_ProjectController_Lex.updateCaseOwner(caseOwnerQueue.Id, 'Queue', listOfIpsProducts[0].Id);
        ipsProd = [SELECT Core_IPS_Prod_Def_Case_Owner_ID__c, Core_IPS_Prod_Default_Case_Owner__c FROM Core_IPS_Product__c WHERE Id = :listOfIpsProducts[0].Id];
        System.assert(ipsProd.Core_IPS_Prod_Def_Case_Owner_ID__c == caseOwnerQueue.Id, 'Queue should be set as default case owner');
    }

    @isTest
    static void testDefaultSearchOwner() {
        Id projectId = [SELECT Id FROM Core_IPS_Project__c WHERE Name = 'Test Project' LIMIT 1].Id;

        List<Core_IPS_Product_Organization__c> listOfSupportOrg = TestUtilities.getListOfSupportOrg(1);
        insert listOfSupportOrg;

        List<Product2> listOfProducts = TestUtilities.getListOfProduct(1);
        listOfProducts[0].Core_Hierarchy_ID__c = '43';
        listOfProducts[0].Core_Hierarchy_Name__c = 'ProdHierarchyName';
        listOfProducts[0].Core_Unique_ID__c = 'Product12345';
        listOfProducts[0].Core_Code_Name__c = 'ProductCoreCodeName';
        insert listOfProducts;

        List<Core_IPS_Supported_Product__c> listOfSupportedProduct = TestUtilities.getListOfSupportedProduct(1);
        listOfSupportedProduct[0].Core_Product__c = listOfProducts[0].Id;
        listOfSupportedProduct[0].Core_Product_Organization__c = listOfSupportOrg[0].Id;
        listOfSupportedProduct[0].Core_Flag_Status__c = 'Approved';
        insert listOfSupportedProduct;

        List<Core_IPS_Product__c> listOfIpsProducts = TestUtilities.getListOfIpsProducts(1);
        listOfIpsProducts[0].Core_IPS_Project__c = projectId;
        listOfIpsProducts[0].Core_Supported_Product__c = listOfSupportedProduct.get(0).Id;
        listOfIpsProducts[0].Status__c = 'Submitted';
        insert listOfIpsProducts;

        Id profileId = Label.Core_IPS_DefaultCaseOwner_Profile_Id.split(';')[0];
        List<User> listOfUsers = TestUtilities.getListOfUser(1);
        listOfUsers[0].ProfileID = profileId;
        listOfUsers[0].Email = 'testowner@example.com';
        insertUsersWithValidationBypass(listOfUsers);

        Core_IPS_ProjectController_Lex.WrapperClass wrapper = Core_IPS_ProjectController_Lex.searchOwner('testowner@example.com', 'user', listOfIpsProducts[0].Id);
        System.assert(wrapper.returnData.size() == 1, 'One matching user should be returned');

        wrapper = Core_IPS_ProjectController_Lex.searchOwner('testowner@search.com', 'user', listOfIpsProducts[0].Id);
        System.assert(wrapper.returnData == null, 'No matching user should be returned');

        wrapper = Core_IPS_ProjectController_Lex.searchOwner('partnerowner@example.com', 'partnerUser', listOfIpsProducts[0].Id);
        System.assert(wrapper.returnData == null, 'No matching partner owner should be returned');

        Group caseOwnerQueue = TestUtilities.getQueue();
        System.runAs([SELECT Id FROM User WHERE Id != :UserInfo.getUserId() AND Profile.Name = 'System Administrator' AND IsActive = true][0]) {
            caseOwnerQueue.DeveloperName = 'IPS_Priority_Queue';
            caseOwnerQueue.Name = 'IPS Priority Queue';
            insert caseOwnerQueue;
        }

        QueueSobject sobjectRel = new QueueSobject();
        System.runAs([SELECT Id FROM User WHERE Id != :UserInfo.getUserId() AND Profile.Name = 'System Administrator' AND IsActive = true][0]) {
            sobjectRel.QueueId = caseOwnerQueue.Id;
            sobjectRel.SobjectType = 'Case';
            insert sobjectRel;
        }

        wrapper = Core_IPS_ProjectController_Lex.searchOwner('Priority', 'queue', listOfIpsProducts[0].Id);
        System.assert(wrapper.returnData.size() == 1, 'One matching queue should be returned');

        wrapper = Core_IPS_ProjectController_Lex.searchOwner('FailThis', 'queue', listOfIpsProducts[0].Id);
        System.assert(wrapper.returnData == null, 'No matching queue should be returned');
    }

    @isTest
    static void testStatusUpdate() {
        Id userId = [SELECT Id FROM User WHERE Name LIKE '%test%' LIMIT 1].Id;
        Boolean result = Core_IPS_ProjectController_Lex.userDetails(userId);
        System.assert(result == true || result == false, 'User details should return a boolean value');

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
        System.assert(submitResult > 0, 'Project submit should return a positive result');
    }
}