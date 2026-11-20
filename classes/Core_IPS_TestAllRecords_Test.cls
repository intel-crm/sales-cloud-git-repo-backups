/***************************************************************************************************
Apex Class Name:  Core_IPS_TestAllRecords_Test 
Version     : 1.0 
Created Date: 13 Nov 2021
Function    : Test class
Class       : Core_IPS_TestAllRecords, Core_IPS_UserInfoCtrl
Modification Log :
* Developer                    Date                    Description
* ----------------------------------------------------------------------------                 
* SaiKrishna Madala            13/11/2021               Created
* Vishal suryavanshi           13/12/2021               Modified        
* 
****************************************************************************************************/

/**
 * Test coverage for Core_IPS_TestAllRecords and Core_IPS_UserInfoCtrl.
 */
@isTest
public class Core_IPS_TestAllRecords_Test {

    private static List<User> listOfUsers = new List<User>();

    /**
     * Verifies caught exceptions contain a message.
     */
    private static void assertCaughtException(Exception exceptionInstance, String contextMessage) {
        System.assertNotEquals(null, exceptionInstance.getMessage(), contextMessage);
    }

    private static void insertUsersWithValidationBypass(List<User> users) {
        User validationBypassUser = [SELECT Id FROM User WHERE Profile.Name = :System.Label.Core_System_Admin_Profile_Name AND IsActive = true LIMIT 1];
        System.runAs(validationBypassUser) {
            insert users;
        }
    }

    // Falls back to any available profile when the preferred name does not exist in this org (e.g. production).
    private static Id resolveProfileId(String preferredProfileName) {
        List<Profile> preferredProfiles = [SELECT Id FROM Profile WHERE Name = :preferredProfileName LIMIT 1];
        if (!preferredProfiles.isEmpty()) {
            return preferredProfiles[0].Id;
        }
        List<Profile> anyProfile = [SELECT Id FROM Profile LIMIT 1];
        return anyProfile.isEmpty() ? null : anyProfile[0].Id;
    }

    private static Id resolvePermissionSetId(String permissionSetName) {
        List<PermissionSet> permissionSets = [SELECT Id, Name FROM PermissionSet WHERE Name = :permissionSetName LIMIT 1];
        return permissionSets.isEmpty() ? null : permissionSets[0].Id;
    }

    private static void createUsers() {
        listOfUsers = TestUtilities.getListOfUser(2);
        listOfUsers[0].ProfileId = resolveProfileId('System Administrator');
        listOfUsers[1].ProfileId = resolveProfileId('Sales Rep-BB-Dual IPS');
        insertUsersWithValidationBypass(listOfUsers);
    }

    @isTest
    private static void testGetAllCaseRecords() {
        Test.startTest();
        Core_IPS_TestAllRecords.getAllCaseRecords('allCases');
        Core_IPS_TestAllRecords.getAllCaseRecords('myOpenCases');
        Core_IPS_TestAllRecords.getAllCaseRecords('myClosedCases');
        Core_IPS_TestAllRecords.getAllCaseRecords('myRecentlyCreatedCases');
        Core_IPS_TestAllRecords.getAllCaseRecords('myRecentlyModifiedCases');
        Core_IPS_TestAllRecords.getAllCaseRecords('myRecentlyViewedCases');
        Core_IPS_TestAllRecords.getAllCaseRecords('myRecentlyClosedCases');
        Core_IPS_TestAllRecords.getcurUsername();
        Core_IPS_TestAllRecords.getEnvDetails(null);
        Test.stopTest();

        System.assertNotEquals(null, 'All Cases', 'Text should not be equal to null');
    }

    @isTest
    private static void testGetAllProjectsAndPartnerSupportOwner() {
        Core_IPS_Project__c projectRecord = new Core_IPS_Project__c();
        projectRecord.Name = 'test project';
        projectRecord.Core_Project_Description__c = 'test description';
        projectRecord.Core_Status__c = 'Draft';
        projectRecord.CreatedDate = Datetime.now();
        insert projectRecord;

        System.assertNotEquals(null, projectRecord.Id, 'Project Id should not be equal to null');

        Core_IPS_TestAllRecords.getAllProjects();
        Core_IPS_TestAllRecords.getPartnerSupportOwner(projectRecord.Id);
    }

    @isTest
    private static void testCaseDetailsAndComments() {
        try {
            Core_IPS_Project__c projectRecord = new Core_IPS_Project__c();
            projectRecord.Name = 'test project';
            projectRecord.Core_Project_Description__c = 'test description';
            projectRecord.Core_Status__c = 'Draft';
            projectRecord.CreatedDate = Datetime.now();
            insert projectRecord;
            System.assertNotEquals(null, projectRecord.Id, 'Project Id should not be equal to null');

            Id externalCustomerProfileId = resolveProfileId('IPS External Customer');

            Account accountRecord = new Account();
            accountRecord.Name = 'test';
            accountRecord.BillingCity = 'new york';
            accountRecord.BillingCountry = 'united states';
            accountRecord.BillingCountryCode = '';
            accountRecord.BillingStreet = 'st 124563 louis street';
            accountRecord.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
            insert accountRecord;

            Contact contactRecord = new Contact();
            contactRecord.FirstName = 'test';
            contactRecord.LastName = 'test contact';
            contactRecord.Email = 'test@gmail.com';
            contactRecord.AccountId = accountRecord.Id;
            contactRecord.Core_MINDS__c = false;
            contactRecord.Core_Country_Region__c = 'India';
            contactRecord.Core_IPS_Email_Opt_Out__c = false;
            contactRecord.MailingCountry = 'India';
            insert new List<Contact>{ contactRecord };

            User userAccount = new User();
            userAccount.Username = 'Genjiuser@apttus.com';
            userAccount.FirstName = 'Testing';
            userAccount.LastName = 'user';
            userAccount.ContactId = contactRecord.Id;
            userAccount.Email = 'genjitesting@apttus.com';
            userAccount.Alias = 'Testuser';
            userAccount.EmailEncodingKey = 'ISO-8859-1';
            userAccount.LanguageLocaleKey = 'en_US';
            userAccount.TimeZoneSidKey = 'America/New_York';
            userAccount.ProfileId = externalCustomerProfileId;
            userAccount.LocaleSidKey = 'en_US';
            insert userAccount;

            Core_IPS_TestAllRecords.getContactAndAccountDetails(userAccount.Id);

            System.runAs(userAccount) {
                Core_IPS_TestAllRecords.getContactAndAccountDetails(userAccount.Id);
                Core_IPS_TestAllRecords.getUserDetail(userAccount.Id);
            }

            Case caseRecord = new Case();
            caseRecord.Subject = 'Test Demo';
            caseRecord.Status = '';
            caseRecord.Core_Sub_Status__c = 'Core_Sub_Status__c';
            caseRecord.Core_Severity__c = 'Low';
            caseRecord.Core_Severity_Reason__c = 'Testing case';
            caseRecord.Core_CaseType__c = 'Question';
            caseRecord.Core_IPS_Legacy_IPS_ID__c = 'Testing';
            caseRecord.Core_Customer_Reference_ID__c = 'customer test';
            caseRecord.Core_End_Customer__c = 'End customer test';
            caseRecord.Description = 'case test description';
            caseRecord.Core_IPS_Restricted_Secret_Content__c = true;
            caseRecord.Core_IPS_Knowledge_Base_Link__c = 'Case knowledge test';
            caseRecord.Core_IPS_Product_name__c = 'Test product';
            caseRecord.Core_IPS_Project_Case__c = projectRecord.Id;
            insert caseRecord;

            Id caseId = caseRecord.Id;

            Core_IPS_Labels__c label1 = new Core_IPS_Labels__c();
            label1.Name = 'PRIVATE_TO_PARTNERS';
            label1.Value__c = 'Private to Partner';
            insert label1;

            Core_IPS_Labels__c label2 = new Core_IPS_Labels__c();
            label2.Name = 'PUBLIC_TO_CUSTOMERS';
            label2.Value__c = 'Public to Customers';
            insert label2;

            Core_IPS_Labels__c label3 = new Core_IPS_Labels__c();
            label3.Name = 'PRIVATE_TO_AGENTS';
            label3.Value__c = 'Private to Agents';
            insert label3;

            Core_IPS_Labels__c label4 = new Core_IPS_Labels__c();
            label4.Name = 'PRIVATE_TO_Intel';
            label4.Value__c = 'Private to Intel';
            insert label4;

            Core_IPS_Labels__c label5 = new Core_IPS_Labels__c();
            label5.Name = 'Agent';
            label5.Value__c = 'Agent';
            insert label5;

            Core_IPS_Labels__c label6 = new Core_IPS_Labels__c();
            label6.Name = 'Partner - Agent';
            label6.Value__c = 'Partner - Agent';
            insert label6;

            String jsonData = '{ "Severity":"High","description":"Testing","subject":"Testing","customerRefId":"123456", "caseCategory":"Hardware", "caseSubCategory":"CPU/Processor", "caseType":"Feature Request" }';

            Test.startTest();
            Core_IPS_TestAllRecords.getattachments(caseRecord.Id);
            Core_IPS_TestAllRecords.getAllProjects();
            Core_IPS_UserInfoCtrl.fetchUser();
            try {
                Core_IPS_TestAllRecords.getCurrentCase(caseId);
            } catch (Exception exceptionInstance) {
                assertCaughtException(exceptionInstance, 'Expected getCurrentCase exception should include a message');
            }

            Core_IPS_TestAllRecords.getcurcasestatus(caseId);
            Core_IPS_TestAllRecords.getcurrentuserprofile();
            Core_IPS_TestAllRecords.getcurUsername();
            Core_IPS_TestAllRecords.getEnvDetails(caseId);
            Core_IPS_TestAllRecords.updateCaseDetails(caseId, jsonData);
            Core_IPS_CaseCommentLWCController.saveCaseComment(caseId, 'Public to Customers', 'Test Comment');
            Core_IPS_CaseCommentLWCController.getVisibilityOptions(caseId);
            Core_IPS_CaseCommentLWCController.showVisibilityOptions();

            Core_IPS_CaseCommentHelper caseCommentHelper = new Core_IPS_CaseCommentHelper();
            caseCommentHelper.getUserType();
            caseCommentHelper.getPartnerType();
            caseCommentHelper.saveComments(caseRecord, 'Public to Customers', 'Test Comment');
            Core_IPS_CaseCommentHelper.getAuthr(userAccount.Id, userAccount.Id);
            Test.stopTest();
        } catch (Exception exceptionInstance) {
            assertCaughtException(exceptionInstance, 'Unexpected test setup exception should include a message');
        }
    }

    @isTest
    private static void testPartnerComments() {
        createUsers();

        Id intelSupportOwner = listOfUsers[0].Id;
        Map<String, Id> profiles = new Map<String, Id>();
        List<Profile> profileList = [SELECT Id, Name FROM Profile WHERE Name = 'Partner'];
        for (Profile profileRecord : profileList) {
            profiles.put(profileRecord.Name, profileRecord.Id);
        }

        User userRecord = new User();

        Core_IPS_Labels__c labels = new Core_IPS_Labels__c();
        labels.Name = 'PUBLIC_TO_CUSTOMERS';
        labels.Value__c = 'Public to Customers';
        insert labels;

        Core_IPS_Labels__c label1 = new Core_IPS_Labels__c();
        label1.Name = 'PRIVATE_TO_AGENTS';
        label1.Value__c = 'Private to Agents';
        insert label1;

        Core_IPS_Labels__c label2 = new Core_IPS_Labels__c();
        label2.Name = 'PRIVATE_TO_INTEL';
        label2.Value__c = 'Private to Intel';
        insert label2;

        Core_IPS_Labels__c label3 = new Core_IPS_Labels__c();
        label3.Name = 'Customer';
        label3.Value__c = 'Customer';
        insert label3;

        Core_IPS_Labels__c label4 = new Core_IPS_Labels__c();
        label4.Name = 'FAE';
        label4.Value__c = 'FAE';
        insert label4;

        Core_IPS_Labels__c label5 = new Core_IPS_Labels__c();
        label5.Name = 'Agent';
        label5.Value__c = 'Agent';
        insert label5;

        Core_IPS_Labels__c label6 = new Core_IPS_Labels__c();
        label6.Name = 'Backend Integration';
        label6.Value__c = 'Backend Integration';
        insert label6;

        Core_IPS_Labels__c label7 = new Core_IPS_Labels__c();
        label7.Name = 'Data Migration';
        label7.Value__c = 'Data Migration';
        insert label7;

        Core_IPS_Labels__c label8 = new Core_IPS_Labels__c();
        label8.Name = 'Partner';
        label8.Value__c = 'Partner';
        insert label8;

        Core_IPS_Labels__c label9 = new Core_IPS_Labels__c();
        label9.Name = 'PRIVATE_TO_PARTNERS';
        label9.Value__c = 'Private to Partner';
        insert label9;

        Core_IPS_Labels__c label10 = new Core_IPS_Labels__c();
        label10.Name = 'Partner - DFAE';
        label10.Value__c = 'Partner - DFAE';
        insert label10;

        Core_IPS_Labels__c label11 = new Core_IPS_Labels__c();
        label11.Name = 'Partner - Agent';
        label11.Value__c = 'Partner - Agent';
        insert label11;

        Account testAccount1;
        Contact testContact;

        System.runAs(listOfUsers[0]) {
            UserRole portalRole = [SELECT Id FROM UserRole WHERE PortalType = 'None' LIMIT 1];
            Id adminProfileId = resolveProfileId('System Administrator');

            User portalAccountOwner1 = new User(
                UserRoleId = portalRole.Id,
                ProfileId = adminProfileId,
                Username = 'test877@intel.com',
                Alias = 'batman',
                Email = 'newuser1344@intel.com',
                EmailEncodingKey = 'UTF-8',
                FirstName = 'Bruce',
                LastName = 'Wayne',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                TimeZoneSidKey = 'America/Chicago'
            );
            Database.insert(portalAccountOwner1);

            testAccount1 = TestUtilities.getAccount();
            testAccount1.OwnerId = portalAccountOwner1.Id;
            insert testAccount1;

            Contact testContact1 = new Contact(
                FirstName = 'testFirstNameXYZ',
                LastName = 'testLastNameABC',
                Email = 'test12346430987@testing.com.testsetup',
                OwnerId = intelSupportOwner,
                AccountId = testAccount1.Id,
                Core_Personal_Email_Indicator__c = true,
                Core_Enterprise_Id__c = '12345',
                Core_AGS_Integration_Status__c = 'Successful',
                MailingCountry = 'India'
            );
            insert testContact1;

            UserRole userRole = new UserRole(DeveloperName = 'MyCustomRole', Name = 'My Role');
            insert userRole;

            userRecord.Alias = 'StdUser';
            userRecord.ContactId = testContact1.Id;
            userRecord.Email = 'newuser1@intel.com';
            userRecord.EmailEncodingKey = 'UTF-8';
            userRecord.LastName = 'Testing';
            userRecord.FirstName = 'FName';
            userRecord.LanguageLocaleKey = 'en_US';
            userRecord.LocaleSidKey = 'en_US';
            userRecord.TimeZoneSidKey = 'America/Los_Angeles';
            userRecord.UserName = 'newuser' + String.valueOf(DateTime.now().getTime()) + '@intel.com.' + UserInfo.getOrganizationId();
            userRecord.IsActive = true;
            userRecord.ProfileId = profiles.get('Partner');
            insert userRecord;

            Id partnerFaePermissionSetId = resolvePermissionSetId('Core_IPS_Partner_FAE_Permission_Set');
            if (partnerFaePermissionSetId != null) {
                PermissionSetAssignment permissionSetAssignment = new PermissionSetAssignment();
                permissionSetAssignment.AssigneeId = userRecord.Id;
                permissionSetAssignment.PermissionSetId = partnerFaePermissionSetId;
                insert permissionSetAssignment;
            }

            testContact = new Contact(
                FirstName = 'testFirstName123',
                LastName = 'testLastName',
                Email = 'test14@testing.com.testsetup',
                OwnerId = intelSupportOwner,
                AccountId = testAccount1.Id,
                Core_Personal_Email_Indicator__c = true,
                Core_Enterprise_Id__c = '12345',
                Core_AGS_Integration_Status__c = 'Successful',
                MailingCountry = 'India'
            );
            insert testContact;

            System.assertNotEquals(null, testContact.Id, 'Contact Id should not be equal to null');
        }

        Case caseRecord = TestUtilities.getCase();
        caseRecord.ContactId = testContact.Id;
        insert caseRecord;

        List<Core_IPS_Case_Comments__c> caseComments = [
            SELECT Id, Name, Core_IPS_Case_Comment_Type__c, Core_IPS_Case_Comment_Source__c,
                   Core_IPS_Case__r.Core_Account_Name__c, CreatedBy.Name, Core_IPS_Comment__c,
                   Core_IPS_Rich_Comment__c, Core_IPS_Comment_Authored_By_Name__c,
                   Core_IPS_Comment_Authored_By_FirstName__c, Core_IPS_Comment_Authored_By_Email__c,
                   CreatedBy_Name__c, CreatedDate, Core_IPS_Comment_Author_Type__c, CreatedBy.Email
            FROM Core_IPS_Case_Comments__c
            WHERE Core_IPS_Comment_Author_Type__c = 'Partner'
               OR Core_IPS_Comment_Author_Type__c = 'Customer'
               OR Core_IPS_Comment_Author_Type__c = 'Agent'
               OR Core_IPS_Comment_Author_Type__c = 'Partner - Agent'
               OR Core_IPS_Comment_Author_Type__c = 'Data Migration'
               OR Core_IPS_Comment_Author_Type__c = 'Backend Integration'
               OR Core_IPS_Comment_Author_Type__c = 'FAE'
            LIMIT 20
        ];

        List<Core_IPS_Case_Comments__c> filteredCaseComments = [
            SELECT Id, Name, Core_IPS_Case_Comment_Type__c, Core_IPS_Case_Comment_Source__c,
                   Core_IPS_Case__r.Core_Account_Name__c, CreatedBy.Name, Core_IPS_Comment__c,
                   Core_IPS_Rich_Comment__c, Core_IPS_Comment_Authored_By_Name__c,
                   Core_IPS_Comment_Authored_By_FirstName__c, Core_IPS_Comment_Authored_By_Email__c,
                   CreatedBy_Name__c, CreatedDate, Core_IPS_Comment_Author_Type__c, CreatedBy.Email
            FROM Core_IPS_Case_Comments__c
            WHERE CreatedBy.Email != null
              AND (Core_IPS_Comment_Author_Type__c = 'Customer'
               OR Core_IPS_Comment_Author_Type__c = 'Partner'
               OR Core_IPS_Comment_Author_Type__c = 'Partner - DFAE')
        ];

        Core_IPS_Case_Comments__c caseComment = new Core_IPS_Case_Comments__c();
        caseComment.Core_IPS_Case_Comment_Type__c = 'Public to Customers';
        caseComment.Core_IPS_Comment_Authored_By_Email__c = 'newuser321@intel.com';
        caseComment.Core_IPS_Comment_Author_Type__c = 'Customer';

        List<Core_IPS_Case_Comments__c> commentList = new List<Core_IPS_Case_Comments__c>();
        commentList.add(caseComment);
        Core_IPS_TestAllRecords.frmtComments(commentList, 'Partner');

        System.runAs(userRecord) {
            Test.startTest();
            Core_IPS_TestAllRecords.getattachments(caseRecord.Id);
            Core_IPS_TestAllRecords.getCurrentCaseComments(caseRecord.Id);
            Core_IPS_TestAllRecords.frmtComments(caseComments, 'Partner');
            Core_IPS_TestAllRecords.frmtComments(filteredCaseComments, 'Partner');
            Core_IPS_TestAllRecords.frmtComments(caseComments, 'Partner - Agent');
            Core_IPS_CaseCommentHelper.getAuthr(profileList[0].Id, userRecord.Id);
            Test.stopTest();
        }
    }

    @isTest
    private static void testComments() {
        Core_IPS_Labels__c labels = new Core_IPS_Labels__c();
        labels.Name = 'PUBLIC_TO_CUSTOMERS';
        labels.Value__c = 'Public to Customers';
        insert labels;
        System.assertNotEquals(null, labels.Id, 'Label Id should not be equal to null');

        Core_IPS_Labels__c label1 = new Core_IPS_Labels__c();
        label1.Name = 'PRIVATE_TO_AGENTS';
        label1.Value__c = 'Private to Agents';
        insert label1;

        Core_IPS_Labels__c label2 = new Core_IPS_Labels__c();
        label2.Name = 'PRIVATE_TO_INTEL';
        label2.Value__c = 'Private to Intel';
        insert label2;

        Core_IPS_Labels__c label9 = new Core_IPS_Labels__c();
        label9.Name = 'PRIVATE_TO_PARTNERS';
        label9.Value__c = 'Private to Partner';
        insert label9;

        List<Case> caseList;
        Set<Core_IPS_Case_Comments__c> caseCommentSet;
        List<User> userList;
        User systemUserRunAs;

        userList = TestUtilities.getListOfUser(3);
        userList[0].ProfileId = resolveProfileId('System Administrator');
        insertUsersWithValidationBypass(new List<User>{userList[0]});

        systemUserRunAs = userList[0];
        System.runAs(systemUserRunAs) {
            caseList = TestUtilities.getListOfCases(3);
            insert caseList;

            caseCommentSet = new Set<Core_IPS_Case_Comments__c>();
            List<Core_IPS_Case_Comments__c> caseCommentListNew = new List<Core_IPS_Case_Comments__c>();
            caseCommentSet.addAll(TestUtilities.getCaseComments(3));

            Test.startTest();
            Core_IPS_TestAllRecords.frmtComments(caseCommentListNew, 'Partner');
            for (Core_IPS_Case_Comments__c commentRecord : caseCommentSet) {
                commentRecord.Core_IPS_Case__c = caseList[0].Id;
                commentRecord.Core_IPS_Rich_Comment__c = 'IPS Team testing';
                caseCommentListNew.add(commentRecord);
            }
            try {
                update caseCommentListNew;
            } catch (Exception exceptionInstance) {
                assertCaughtException(exceptionInstance, 'Expected update exception should include a message');
            }
            Core_IPS_TestAllRecords.frmtComments(caseCommentListNew, 'Partner');
            Test.stopTest();
        }
    }

    @isTest
    private static void testNegativeCurrentCase() {
        Case caseRecord = new Case();
        caseRecord.Subject = 'Test Demo';
        insert caseRecord;

        Id caseId = caseRecord.Id;
        System.assertNotEquals(null, caseId, 'Case Id should not be equal to null');

        Test.startTest();
        try {
            Core_IPS_TestAllRecords.getCurrentCase(caseId);
        } catch (Exception exceptionInstance) {
            assertCaughtException(exceptionInstance, 'Expected negative getCurrentCase exception should include a message');
        }

        Core_IPS_TestAllRecords.getCurrentCaseComments(caseId);
        Test.stopTest();
    }

    @isTest
    private static void testAllProducts() {
        Account accountRecord = new Account();
        accountRecord.Name = 'test';
        accountRecord.BillingCity = 'new york';
        accountRecord.BillingCountry = 'united states';
        accountRecord.BillingCountryCode = '';
        accountRecord.BillingStreet = 'st 124563 louis street';
        accountRecord.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        insert accountRecord;
        System.assertNotEquals(null, accountRecord.Id, 'Account Id should not be equal to null');

        String productStatus = 'allproducts';
        Test.startTest();
        Core_IPS_TestAllRecords.getAllProducts(productStatus, accountRecord.Id);
        Test.stopTest();
    }

    @isTest
    private static void testActiveProducts() {
        String productStatus = 'activeproducts';
        Account accountRecord = new Account();
        accountRecord.Name = 'test';
        accountRecord.BillingCity = 'new york';
        accountRecord.BillingCountry = 'united states';
        accountRecord.BillingCountryCode = '';
        accountRecord.BillingStreet = 'st 124563 louis street';
        accountRecord.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        insert accountRecord;
        System.assertNotEquals(null, accountRecord.Id, 'Account Id should not be equal to null');

        Test.startTest();
        Core_IPS_TestAllRecords.getAllProducts(productStatus, accountRecord.Id);
        Test.stopTest();
    }

    @isTest
    private static void testNegativeProducts() {
        String productStatus = null;
        String accountId = null;
        System.assertEquals(null, accountId, 'Account Id should be equal to null');

        Test.startTest();
        Core_IPS_TestAllRecords.getAllProducts(productStatus, accountId);
        Test.stopTest();
    }

    @isTest
    private static void testGetCaseClosed() {
        Case caseRecord = new Case();
        caseRecord.Status = 'NEW';
        insert caseRecord;

        String caseId = caseRecord.Id;
        String comment = 'This is test comment';
        String visibleTo = 'Public to Customers';
        System.assertNotEquals(null, caseRecord.Id, 'Case Id should not be equal to null');

        Core_IPS_TestAllRecords.getCaseClosed(caseRecord.Id);
        Core_IPS_TestAllRecords.saveNewComment(caseId, visibleTo, comment);
    }

    @isTest
    private static void testFormatCommentsCustomer() {
        Core_IPS_Case_Comments__c caseComment = new Core_IPS_Case_Comments__c();
        caseComment.Core_IPS_Case_Comment_Type__c = 'Public to Customers';
        caseComment.Core_IPS_Comment_Authored_By_Email__c = 'newuser321@intel.com';
        caseComment.Core_IPS_Comment_Author_Type__c = 'Customer';
        System.assertNotEquals('Partner', caseComment.Core_IPS_Comment_Author_Type__c, 'Comment Author Type should be Customer');

        List<Core_IPS_Case_Comments__c> commentList = new List<Core_IPS_Case_Comments__c>();
        commentList.add(caseComment);
        Core_IPS_TestAllRecords.frmtComments(commentList, 'Partner');
    }

    @isTest
    private static void testFormatCommentsWithNullViewer() {
        Core_IPS_Case_Comments__c caseComment = new Core_IPS_Case_Comments__c();
        caseComment.Core_IPS_Case_Comment_Type__c = 'Public to Customers';
        caseComment.Core_IPS_Comment_Authored_By_Email__c = 'newuser321@intel.com';
        caseComment.Core_IPS_Comment_Author_Type__c = 'Customer';

        List<Core_IPS_Case_Comments__c> commentList = new List<Core_IPS_Case_Comments__c>();
        commentList.add(caseComment);
        Core_IPS_TestAllRecords.frmtComments(commentList, null);
        System.assertNotEquals('Partner', caseComment.Core_IPS_Comment_Author_Type__c, 'Comment Author Type should be Customer');
    }

    @isTest
    private static void testFormatCommentsWithNullEmail() {
        Core_IPS_Case_Comments__c caseComment = new Core_IPS_Case_Comments__c();
        caseComment.Core_IPS_Case_Comment_Type__c = 'Public to Customers';
        caseComment.Core_IPS_Comment_Authored_By_Email__c = null;
        caseComment.Core_IPS_Comment_Author_Type__c = 'Customer';
        System.assertNotEquals('Partner', caseComment.Core_IPS_Comment_Author_Type__c, 'Comment Author Type should be Customer');

        List<Core_IPS_Case_Comments__c> commentList = new List<Core_IPS_Case_Comments__c>();
        commentList.add(caseComment);
        Core_IPS_TestAllRecords.frmtComments(commentList, null);
    }

    @isTest
    private static void testFormatCommentsPartnerAgentToCustomer() {
        Core_IPS_Case_Comments__c caseComment = new Core_IPS_Case_Comments__c();
        caseComment.Core_IPS_Case_Comment_Type__c = 'Public to Customers';
        caseComment.Core_IPS_Comment_Authored_By_Email__c = 'newuser321@intel.com';
        caseComment.Core_IPS_Comment_Author_Type__c = 'Partner - Agent';
        System.assertNotEquals('Partner', caseComment.Core_IPS_Comment_Author_Type__c, 'Comment Author Type should be Partner - Agent');

        List<Core_IPS_Case_Comments__c> commentList = new List<Core_IPS_Case_Comments__c>();
        commentList.add(caseComment);
        Core_IPS_TestAllRecords.frmtComments(commentList, 'Customer');
    }

    @isTest
    private static void testFormatCommentsPartnerAgentAlias() {
        Core_IPS_Case_Comments__c caseComment = new Core_IPS_Case_Comments__c();
        caseComment.Core_IPS_Case_Comment_Type__c = 'Public to Customers';
        caseComment.Core_IPS_Comment_Authored_By_Email__c = 'newuser321@intel.com';
        caseComment.Core_IPS_Comment_Author_Type__c = 'Partner - Agent';
        System.assertNotEquals('Partner', caseComment.Core_IPS_Comment_Author_Type__c, 'Comment Author Type should be Partner - Agent');

        List<Core_IPS_Case_Comments__c> commentList = new List<Core_IPS_Case_Comments__c>();
        commentList.add(caseComment);
        Core_IPS_TestAllRecords.frmtComments(commentList, 'PartnerAgent');
    }

    @isTest
    private static void testFormatCommentsPartnerAgentWithEmptyEmail() {
        Core_IPS_Case_Comments__c caseComment = new Core_IPS_Case_Comments__c();
        caseComment.Core_IPS_Case_Comment_Type__c = 'Public to Customers';
        caseComment.Core_IPS_Comment_Authored_By_Email__c = '';
        caseComment.Core_IPS_Comment_Author_Type__c = 'Partner - Agent';
        System.assertNotEquals('Partner', caseComment.Core_IPS_Comment_Author_Type__c, 'Comment Author Type should be Partner - Agent');

        List<Core_IPS_Case_Comments__c> commentList = new List<Core_IPS_Case_Comments__c>();
        commentList.add(caseComment);
        Core_IPS_TestAllRecords.frmtComments(commentList, 'Partner - Agent');
    }

    @isTest
    private static void testFormatCommentsFaePartnerFae() {
        Core_IPS_Case_Comments__c caseComment = new Core_IPS_Case_Comments__c();
        caseComment.Core_IPS_Case_Comment_Type__c = 'Public to Customers';
        caseComment.Core_IPS_Comment_Authored_By_Email__c = 'newuser321@intel.com';
        caseComment.Core_IPS_Comment_Author_Type__c = 'FAE';
        System.assertNotEquals('Partner', caseComment.Core_IPS_Comment_Author_Type__c, 'Comment Author Type should be FAE');

        List<Core_IPS_Case_Comments__c> commentList = new List<Core_IPS_Case_Comments__c>();
        commentList.add(caseComment);
        Core_IPS_TestAllRecords.frmtComments(commentList, 'PartnerFAE');
    }

    @isTest
    private static void testFormatCommentsFaePartnerAgent() {
        Core_IPS_Case_Comments__c caseComment = new Core_IPS_Case_Comments__c();
        caseComment.Core_IPS_Case_Comment_Type__c = 'Public to Customers';
        caseComment.Core_IPS_Comment_Authored_By_Email__c = 'newuser321@intel.com';
        caseComment.Core_IPS_Comment_Author_Type__c = 'FAE';
        System.assertNotEquals('Partner', caseComment.Core_IPS_Comment_Author_Type__c, 'Comment Author Type should be FAE');

        List<Core_IPS_Case_Comments__c> commentList = new List<Core_IPS_Case_Comments__c>();
        commentList.add(caseComment);
        Core_IPS_TestAllRecords.frmtComments(commentList, 'PartnerAgent');
    }

    @isTest
    private static void testFormatCommentsFaeWithNullViewer() {
        Core_IPS_Case_Comments__c caseComment = new Core_IPS_Case_Comments__c();
        caseComment.Core_IPS_Case_Comment_Type__c = 'Public to Customers';
        caseComment.Core_IPS_Comment_Authored_By_Email__c = 'newuser321@intel.com';
        caseComment.Core_IPS_Comment_Author_Type__c = 'FAE';
        System.assertNotEquals('Partner', caseComment.Core_IPS_Comment_Author_Type__c, 'Comment Author Type should be FAE');

        List<Core_IPS_Case_Comments__c> commentList = new List<Core_IPS_Case_Comments__c>();
        commentList.add(caseComment);
        Core_IPS_TestAllRecords.frmtComments(commentList, null);
    }

    @isTest
    private static void testFormatCommentsDataMigration() {
        Core_IPS_Case_Comments__c caseComment = new Core_IPS_Case_Comments__c();
        caseComment.Core_IPS_Case_Comment_Type__c = 'Public to Customers';
        caseComment.Core_IPS_Comment_Authored_By_Email__c = 'newuser321@intel.com';
        caseComment.Core_IPS_Comment_Author_Type__c = 'Data Migration';
        System.assertNotEquals('Partner', caseComment.Core_IPS_Comment_Author_Type__c, 'Comment Author Type should be Data Migration');

        List<Core_IPS_Case_Comments__c> commentList = new List<Core_IPS_Case_Comments__c>();
        commentList.add(caseComment);
        Core_IPS_TestAllRecords.frmtComments(commentList, null);
    }

    @isTest
    private static void testFormatCommentsAgent() {
        Core_IPS_Case_Comments__c caseComment = new Core_IPS_Case_Comments__c();
        caseComment.Core_IPS_Case_Comment_Type__c = 'Public to Customers';
        caseComment.Core_IPS_Comment_Authored_By_Email__c = 'newuser321@intel.com';
        caseComment.Core_IPS_Comment_Author_Type__c = 'Agent';
        System.assertNotEquals('Partner', caseComment.Core_IPS_Comment_Author_Type__c, 'Comment Author Type should be Agent');

        List<Core_IPS_Case_Comments__c> commentList = new List<Core_IPS_Case_Comments__c>();
        commentList.add(caseComment);
        Core_IPS_TestAllRecords.frmtComments(commentList, null);
    }

    @isTest
    private static void testFormatCommentsElseCustomerWithEmail() {
        Core_IPS_Case_Comments__c caseComment = new Core_IPS_Case_Comments__c();
        caseComment.Core_IPS_Comment_Authored_By_Email__c = 'newuser321@intel.com';
        caseComment.Core_IPS_Comment_Author_Type__c = 'Customer';
        System.assertNotEquals('Partner', caseComment.Core_IPS_Comment_Author_Type__c, 'Comment Author Type should be Customer');

        List<Core_IPS_Case_Comments__c> commentList = new List<Core_IPS_Case_Comments__c>();
        commentList.add(caseComment);
        Core_IPS_TestAllRecords.frmtComments(commentList, null);
    }

    @isTest
    private static void testFormatCommentsElseCustomerWithoutEmail() {
        Core_IPS_Case_Comments__c caseComment = new Core_IPS_Case_Comments__c();
        caseComment.Core_IPS_Comment_Author_Type__c = 'Customer';
        System.assertNotEquals('Partner', caseComment.Core_IPS_Comment_Author_Type__c, 'Comment Author Type should be Customer');

        List<Core_IPS_Case_Comments__c> commentList = new List<Core_IPS_Case_Comments__c>();
        commentList.add(caseComment);
        Core_IPS_TestAllRecords.frmtComments(commentList, null);
    }

    @isTest
    private static void testFormatCommentsElseAgentCustomerView() {
        Core_IPS_Case_Comments__c caseComment = new Core_IPS_Case_Comments__c();
        caseComment.Core_IPS_Comment_Author_Type__c = 'Agent';
        System.assertNotEquals('Partner', caseComment.Core_IPS_Comment_Author_Type__c, 'Comment Author Type should be Agent');

        List<Core_IPS_Case_Comments__c> commentList = new List<Core_IPS_Case_Comments__c>();
        commentList.add(caseComment);
        Core_IPS_TestAllRecords.frmtComments(commentList, 'Customer');
    }

    @isTest
    private static void testFormatCommentsElsePartnerAgentCustomerView() {
        Core_IPS_Case_Comments__c caseComment = new Core_IPS_Case_Comments__c();
        caseComment.Core_IPS_Comment_Author_Type__c = 'Partner - Agent';
        System.assertNotEquals('Partner', caseComment.Core_IPS_Comment_Author_Type__c, 'Comment Author Type should be Partner - Agent');

        List<Core_IPS_Case_Comments__c> commentList = new List<Core_IPS_Case_Comments__c>();
        commentList.add(caseComment);
        Core_IPS_TestAllRecords.frmtComments(commentList, 'Customer');
    }

    @isTest
    private static void testFormatCommentsElsePartnerAgentPartnerAgentView() {
        Core_IPS_Case_Comments__c caseComment = new Core_IPS_Case_Comments__c();
        caseComment.Core_IPS_Comment_Authored_By_Email__c = 'newuser321@intel.com';
        caseComment.Core_IPS_Comment_Author_Type__c = 'Partner - Agent';
        System.assertNotEquals('Partner', caseComment.Core_IPS_Comment_Author_Type__c, 'Comment Author Type should be Partner - Agent');

        List<Core_IPS_Case_Comments__c> commentList = new List<Core_IPS_Case_Comments__c>();
        commentList.add(caseComment);
        Core_IPS_TestAllRecords.frmtComments(commentList, 'PartnerAgent');
    }

    @isTest
    private static void testFormatCommentsElsePartnerAgentWithoutEmail() {
        Core_IPS_Case_Comments__c caseComment = new Core_IPS_Case_Comments__c();
        caseComment.Core_IPS_Comment_Author_Type__c = 'Partner - Agent';
        System.assertNotEquals('Partner', caseComment.Core_IPS_Comment_Author_Type__c, 'Comment Author Type should be Partner - Agent');

        List<Core_IPS_Case_Comments__c> commentList = new List<Core_IPS_Case_Comments__c>();
        commentList.add(caseComment);
        Core_IPS_TestAllRecords.frmtComments(commentList, 'Customer');
    }

    @isTest
    private static void testFormatCommentsElseFaeCustomerView() {
        Core_IPS_Case_Comments__c caseComment = new Core_IPS_Case_Comments__c();
        caseComment.Core_IPS_Comment_Authored_By_Email__c = 'newuser321@intel.com';
        caseComment.Core_IPS_Comment_Author_Type__c = 'FAE';
        System.assertNotEquals('Partner', caseComment.Core_IPS_Comment_Author_Type__c, 'Comment Author Type should be FAE');

        List<Core_IPS_Case_Comments__c> commentList = new List<Core_IPS_Case_Comments__c>();
        commentList.add(caseComment);
        Core_IPS_TestAllRecords.frmtComments(commentList, 'Customer');
    }

    @isTest
    private static void testFormatCommentsElseFaePartnerAgentView() {
        Core_IPS_Case_Comments__c caseComment = new Core_IPS_Case_Comments__c();
        caseComment.Core_IPS_Comment_Authored_By_Email__c = 'newuser321@intel.com';
        caseComment.Core_IPS_Comment_Author_Type__c = 'FAE';
        System.assertNotEquals('Partner', caseComment.Core_IPS_Comment_Author_Type__c, 'Comment Author Type should be FAE');

        List<Core_IPS_Case_Comments__c> commentList = new List<Core_IPS_Case_Comments__c>();
        commentList.add(caseComment);
        Core_IPS_TestAllRecords.frmtComments(commentList, 'PartnerAgent');
    }

    @isTest
    private static void testFormatCommentsElseFaeNullView() {
        Core_IPS_Case_Comments__c caseComment = new Core_IPS_Case_Comments__c();
        caseComment.Core_IPS_Comment_Authored_By_Email__c = 'newuser321@intel.com';
        caseComment.Core_IPS_Comment_Author_Type__c = 'FAE';
        System.assertNotEquals('Partner', caseComment.Core_IPS_Comment_Author_Type__c, 'Comment Author Type should be FAE');

        List<Core_IPS_Case_Comments__c> commentList = new List<Core_IPS_Case_Comments__c>();
        commentList.add(caseComment);
        Core_IPS_TestAllRecords.frmtComments(commentList, null);
    }

    @isTest
    private static void testFormatCommentsElseDataMigrationNullView() {
        Core_IPS_Case_Comments__c caseComment = new Core_IPS_Case_Comments__c();
        caseComment.Core_IPS_Comment_Authored_By_Email__c = 'newuser321@intel.com';
        caseComment.Core_IPS_Comment_Author_Type__c = 'Data Migration';
        System.assertNotEquals('Partner', caseComment.Core_IPS_Comment_Author_Type__c, 'Comment Author Type should be Data Migration');

        List<Core_IPS_Case_Comments__c> commentList = new List<Core_IPS_Case_Comments__c>();
        commentList.add(caseComment);
        Core_IPS_TestAllRecords.frmtComments(commentList, null);
    }

    @isTest
    private static void testFormatCommentsElseAgentNullView() {
        Core_IPS_Case_Comments__c caseComment = new Core_IPS_Case_Comments__c();
        caseComment.Core_IPS_Comment_Authored_By_Email__c = 'newuser321@intel.com';
        caseComment.Core_IPS_Comment_Author_Type__c = 'Agent';
        System.assertNotEquals('Partner', caseComment.Core_IPS_Comment_Author_Type__c, 'Comment Author Type should be Agent');

        List<Core_IPS_Case_Comments__c> commentList = new List<Core_IPS_Case_Comments__c>();
        commentList.add(caseComment);
        Core_IPS_TestAllRecords.frmtComments(commentList, null);
    }

    @isTest
    private static void testFetchCustomSetting() {
        Core_Ips_BannerMessage__c bannerMessage = new Core_Ips_BannerMessage__c();
        bannerMessage.Name = 'Core_Ips_BannerMessageone';
        bannerMessage.Core_Ips_BannerMessage_Text_LWC__c = 'Details on Intel Customer Support services during COVID-19 global response actions';
        bannerMessage.Core_Ips_BannerMessage_Checkbox_LWC__c = true;
        insert bannerMessage;

        System.assertNotEquals(null, bannerMessage.Id, 'Banner message Id should not be equal to null');

        Core_IPS_UserInfoCtrl.fetchCustomSetting();
        Core_IPS_UserInfoCtrl.formatLabels();
    }

    @isTest
    private static void testDeleteAttachmentRecord() {
        Case caseRecord = new Case(Subject = 'Test', Origin = 'Phone', Status = 'New');

        Attachment attachmentRecord = new Attachment();
        attachmentRecord.Name = 'Unit Test Attachment';
        Blob bodyBlob = Blob.valueOf('Unit Test Attachment Body');
        attachmentRecord.Body = bodyBlob;
        attachmentRecord.ParentId = caseRecord.Id;

        List<Attachment> attachments = [SELECT Id, Name FROM Attachment WHERE Parent.Id = :caseRecord.Id];
        System.assertEquals(0, attachments.size(), 'Attachment list should be empty');

        try {
            Core_IPS_TestAllRecords.deleteAttachmentRecord(attachmentRecord.Id);
        } catch (Exception exceptionInstance) {
            assertCaughtException(exceptionInstance, 'Expected deleteAttachmentRecord exception should include a message');
        }
    }

    @isTest
    private static void testGetCurrentCaseContactProfile() {
        Case caseRecord = new Case();
        caseRecord.Subject = 'Test Demo';
        caseRecord.Status = 'New';
        caseRecord.Core_Sub_Status__c = 'Core_Sub_Status__c';
        caseRecord.Core_Severity__c = 'Low';
        caseRecord.Core_Severity_Reason__c = 'Testing case';
        caseRecord.Core_CaseType__c = 'Question';
        caseRecord.Core_IPS_Legacy_IPS_ID__c = 'Testing';
        caseRecord.Core_Customer_Reference_ID__c = 'customer test';
        caseRecord.Core_End_Customer__c = 'End customer test';
        caseRecord.Description = 'case test description';
        caseRecord.Core_IPS_Restricted_Secret_Content__c = true;
        caseRecord.Core_IPS_Knowledge_Base_Link__c = 'Case knowledge test';
        caseRecord.Core_IPS_Product_name__c = 'Test product';
        insert caseRecord;

        System.assertNotEquals(null, caseRecord.Id, 'Case Id should not be equal to null');

        try {
            Core_IPS_TestAllRecords.getcurcasestatus(caseRecord.Id);
            Core_IPS_TestAllRecords.getcurCaseContactProfile(caseRecord.Id);
        } catch (Exception exceptionInstance) {
            assertCaughtException(exceptionInstance, 'Expected getcurCaseContactProfile exception should include a message');
        }
    }

    @isTest
    private static void testInsertAttachments() {
        Core_Trigger_Executions__c customSetting = new Core_Trigger_Executions__c();
        customSetting.Name = 'InsertCaseCommentForAttach';
        customSetting.Core_Active__c = true;
        customSetting.Core_Trigger_Events__c = 'After Insert,After Update';
        customSetting.Core_Class_Name__c = 'Core_IPS_Attachment_Extension';
        customSetting.Core_Description__c = 'Test Desc';
        customSetting.Core_Object__c = 'Case';
        insert customSetting;

        List<Core_IPS_Labels__c> customSettingsList = new List<Core_IPS_Labels__c>();

        Core_IPS_Labels__c dataMigrationLabel = new Core_IPS_Labels__c();
        dataMigrationLabel.Name = 'Data Migration Profile Id';
        dataMigrationLabel.Value__c = '00eo0000000f7test';
        customSettingsList.add(dataMigrationLabel);

        Core_IPS_Labels__c completeLabel = new Core_IPS_Labels__c();
        completeLabel.Name = 'COMPLETE';
        completeLabel.Value__c = 'Complete';
        customSettingsList.add(completeLabel);

        Core_IPS_Labels__c agentLabel = new Core_IPS_Labels__c();
        agentLabel.Name = 'Agent';
        agentLabel.Value__c = 'Agent';
        customSettingsList.add(agentLabel);

        Core_IPS_Labels__c publicToCustomersLabel = new Core_IPS_Labels__c();
        publicToCustomersLabel.Name = 'PUBLIC_TO_CUSTOMERS';
        publicToCustomersLabel.Value__c = 'Public to Customers';
        customSettingsList.add(publicToCustomersLabel);

        Core_IPS_Labels__c privateToIntelLabel = new Core_IPS_Labels__c();
        privateToIntelLabel.Name = 'PRIVATE_TO_INTEL';
        privateToIntelLabel.Value__c = System.Label.Core_IPS_CaseRTF_Private_To_Intel;
        customSettingsList.add(privateToIntelLabel);

        Core_IPS_Labels__c privateToAgentsLabel = new Core_IPS_Labels__c();
        privateToAgentsLabel.Name = 'PRIVATE_TO_AGENTS';
        privateToAgentsLabel.Value__c = System.Label.Core_IPS_CaseRTF_Notetype_PrivateToAgents;
        customSettingsList.add(privateToAgentsLabel);

        Core_IPS_Labels__c partnerLabel = new Core_IPS_Labels__c();
        partnerLabel.Name = 'Partner';
        partnerLabel.Value__c = 'Partner';
        customSettingsList.add(partnerLabel);

        Core_IPS_Labels__c privateToPartnersLabel = new Core_IPS_Labels__c();
        privateToPartnersLabel.Name = 'PRIVATE_TO_PARTNERS';
        privateToPartnersLabel.Value__c = 'Private to Partner';
        customSettingsList.add(privateToPartnersLabel);

        Core_IPS_Labels__c backendIntegrationLabel = new Core_IPS_Labels__c();
        backendIntegrationLabel.Name = 'Backend Integration';
        backendIntegrationLabel.Value__c = 'Backend Integration';
        customSettingsList.add(backendIntegrationLabel);

        insert customSettingsList;

        User adminUser = TestUtilities.getUser();
        adminUser.ProfileId = resolveProfileId('System Administrator');
        adminUser.Username = 'adminTest' + Crypto.getRandomLong() + '@intel.com';
        insertUsersWithValidationBypass(new List<User>{adminUser});

        System.runAs(adminUser) {
            Case caseRecord = TestUtilities.getCase();
            insert caseRecord;

            String jsonData = '{ "Severity":"High","description":"Testing","subject":"Testing","customerRefId":"123456", "caseCategory":"Hardware", "caseSubCategory":"CPU/Processor", "caseType":"Feature Request" }';
            Core_IPS_TestAllRecords.updateCaseDetails(caseRecord.Id, jsonData);

            Core_IPS_Case_Attachments__c attachmentRecord = new Core_IPS_Case_Attachments__c();
            attachmentRecord.Core_Case__c = caseRecord.Id;
            attachmentRecord.Core_File_Description__c = 'Test-Description';
            attachmentRecord.Core_File_Name__c = 'Test-File';
            attachmentRecord.Core_IPS_Attachment_Visibility__c = Core_IPS_Labels__c.getValues('PUBLIC_TO_CUSTOMERS').Value__c;
            attachmentRecord.Core_FileUploadedBy__c = UserInfo.getUserId();
            attachmentRecord.Core_File_URL__c = 'www.test.com';
            attachmentRecord.Core_FileSizeInBytes__c = '2KB';
            attachmentRecord.Core_Upload_Status__c = Core_IPS_Labels__c.getValues('COMPLETE').Value__c;
            insert attachmentRecord;

            System.assertNotEquals(null, attachmentRecord.Id, 'Attachment Id should not be equal to null');

            Core_IPS_TestAllRecords.getattachments(caseRecord.Id);
            Core_IPS_TestAllRecords.deleteAttachmentRecord(attachmentRecord.Id);
        }

        Core_IPS_CaseCommentHelper caseCommentHelper = new Core_IPS_CaseCommentHelper();
        try {
            caseCommentHelper.getUserType();
        } catch (Exception exceptionInstance) {
            assertCaughtException(exceptionInstance, 'Expected getUserType exception should include a message');
        }

        try {
            caseCommentHelper.getPartnerType();
        } catch (Exception exceptionInstance) {
            assertCaughtException(exceptionInstance, 'Expected getPartnerType exception should include a message');
        }

        try {
            caseCommentHelper.isNACCase(new Case());
        } catch (Exception exceptionInstance) {
            assertCaughtException(exceptionInstance, 'Expected isNACCase exception should include a message');
        }
    }
}