/**************************************************************************************
Apex Class Name:  Core_UserHandler_Test
Version     : 1.0 
Created Date: 05 DEC 2014
Function    : Test Class for the Core_UserHandler
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Kunal Mehta             10/05/2014              Original Version               
* Dave Hood               12/19/2014              Added Geo population test code
* Brian Matthews          03/09/2015              Clone Cleanup 
* Venu Karumuru           07/29/2015              Added AddUsersToProfileGroups_Test()
* Venu Karumuru           05/18/2016              Added assignContact_Test()
* Venu Karumuru           04/06/2017              Updated assignContact() to remove use of Contact Engagement Object and use Contact Entitlement Object
* Nick Krisa              06/22/2017              Updated/Added AddUsersToEmployeeTypeGroups_Test
*************************************************************************************/
@isTest(seeAllData = true)
public class Core_UserHandler_Test {
    
     /*
     * Method name  : AddUsersToEmployeeTypeGroups_Test
     * Description  : Method to test userEmployeeTypeGroupAssignment funcationality
     * Return Type  : VOID
     * Paramenters  : none
     */
    static testMethod void AddUsersToEmployeeTypeGroups_Test() {
        System.runAs(Core_Test_Utility.systemAdminUser) {
            
            // Profiles used in the test
            String sProfileName = 'Standard User';
            
            // Employee Type Codes in the test
            String sEmployeeType1 = 'Non-Badged';
            String sEmployeeType2 = 'EMP';
            String sEmployeeType3 = 'CTW';
            
            // User used in the test
            String sLastName = 'User1';
            String sAlias = 'tuser1';
            String sEmail = 'test.user1@intel.com';
            String sUserName = 'test.user1@intel.com.crm.testclass';
            
            // Variables list
            Id profileId;
            Id groupId1, // sEmployeeType1
               groupId2, // sEmployeeType2
               groupId3; // sEmployeeType3
            Id groupMemberId1, groupMemberId2, groupMemberId3;
            List<GroupMember> lstGroupMembers = null;
            List<Profile> lstProfiles = null;
            
            // Get the Id of the Standard Profile             
            lstProfiles = [SELECT Id FROM Profile WHERE Name = :sProfileName LIMIT 1];
            if (lstProfiles.size() == 0)
                profileId = null;
            else
                profileId = lstProfiles[0].Id;
            
            // Get the mappings between employee type codes and public groups from custom settings
            Map<String, Id> mapETCToGroupId = Core_UserHandler.LoadEmployeeTypeToGroupMapping();
            
            // Get the Id of the Group that maps to the sEmployeeType1
            groupId1 = mapETCToGroupId.get(sEmployeeType1);
            // Make sure that the sEmployeeType1 Id is not null
            System.assertNotEquals(null, groupId1);
            
            // Get the Id of the Group that maps to the sEmployeeType2
            groupId2 = mapETCToGroupId.get(sEmployeeType2);
            // Make sure that the sEmployeeType2 Id is not null
            System.assertNotEquals(null, groupId2);
            
            // Get the Id of the Group that maps to the sEmployeeType3
            groupId3 = mapETCToGroupId.get(sEmployeeType3);
            // Make sure that the sEmployeeType3 Id is not null
            System.assertNotEquals(null, groupId3);
            
            
            // TEST CASE 1: Create a new User, default to Non-Badged
            User testUser = new User(LastName = sLastName, Alias = sAlias, Email = sEmail, UserName = sUserName, ProfileId = profileId,
                EmailEncodingKey = 'UTF-8', TimeZoneSidKey = 'America/Los_Angeles', LocaleSidKey = 'en_US', LanguageLocaleKey = 'en_US');
            
            insert testUser;
            
            // Make sure that the User is part of the first Group (based on the first Employee Type Code)
            lstGroupMembers = [SELECT Id FROM GroupMember WHERE UserOrGroupId = :testUser.Id AND GroupId = :groupId1 LIMIT 1];
            
            if (lstGroupMembers.size() == 0)
                groupMemberId1 = null;
            else
                groupMemberId1 = lstGroupMembers[0].Id;
            
            // User is in the Non-Badged Public Group
            System.assertNotEquals(null, groupMemberId1);        
            
            
            // TEST CASE 2: Change the User's Employee Type Code to sEmployeeType2
            testUser.Core_Employee_Type_Code__c = sEmployeeType2;
            update testUser;
            
            // Make sure that the User is no longer in the Non-Badged Public Group
            lstGroupMembers = [SELECT Id FROM GroupMember WHERE UserOrGroupId = :testUser.Id AND GroupId = :groupId1 LIMIT 1];
            
            if (lstGroupMembers.size() == 0)
                groupMemberId2 = null;
            else
                groupMemberId2 = lstGroupMembers[0].Id;
            
            System.assertEquals(null, groupMemberId2);   
            
            // Make sure that the User is in the sEmployeeType2
            lstGroupMembers = [SELECT Id FROM GroupMember WHERE UserOrGroupId = :testUser.Id AND GroupId = :groupId2 LIMIT 1];
            
            if (lstGroupMembers.size() == 0)
                groupMemberId2 = null;
            else
                groupMemberId2 = lstGroupMembers[0].Id;
            
            System.assertNotEquals(null, groupMemberId2);  
            
            
            // TEST CASE 3: Update the profile to sEmployeeType3
            testUser.Core_Employee_Type_Code__c = sEmployeeType3;
            update testUser;
            
            // Make sure that the User is no longer in the sEmployeeType2
            lstGroupMembers = [SELECT Id FROM GroupMember WHERE UserOrGroupId = :testUser.Id AND GroupId = :groupId2 LIMIT 1];
            
            if (lstGroupMembers.size() == 0)
                groupMemberId3 = null;
            else
                groupMemberId3 = lstGroupMembers[0].Id;
            
            System.assertEquals(null, groupMemberId3);
            
            // Make sure that the User is in the sEmployeeType3
            lstGroupMembers = [SELECT Id FROM GroupMember WHERE UserOrGroupId = :testUser.Id AND GroupId = :groupId3 LIMIT 1];
            
            if (lstGroupMembers.size() == 0)
                groupMemberId3 = null;
            else
                groupMemberId3 = lstGroupMembers[0].Id;
            
            System.assertNotEquals(null, groupMemberId3);
            
            // TEST CASE 4: Update another field - should return
            testUser.LastName = 'TESTTESTTEST';
            update testUser;
            
            // Make sure that the User is still in the sEmployeeType3
            lstGroupMembers = [SELECT Id FROM GroupMember WHERE UserOrGroupId = :testUser.Id AND GroupId = :groupId3 LIMIT 1];
            
            if (lstGroupMembers.size() == 0)
                groupMemberId3 = null;
            else
                groupMemberId3 = lstGroupMembers[0].Id;
            
            System.assertNotEquals(null, groupMemberId3);
        }
    }

    
    // TODO: to make this more robust, pull a few countries and their geo mappings from the custom settings
    // and use those in the inserts/updates/assertions instead of USA, Brazil, Germany, etc.
    static testMethod void testGeoUpdate() {
        
        // Insert a bunch of users with different countries and one not specified
        Id profId = [select Id from Profile where Name = 'Standard User'
            limit 1
        ][0].Id;
        List < User > userList = new List < User > ();
        userList.add(new User(UserName = 'testGeoUpdate1@intel.com.crm.testclass', LastName = 'User', Email = 'test.user1@intel.com',
            Alias = 'tclass1', TimeZoneSidKey = 'America/Los_Angeles', LocaleSidKey = 'en_US', EmailEncodingKey = 'UTF-8',
            ProfileId = profId, LanguageLocaleKey = 'en_US', Core_User_Country_Code__c = 'USA'));
        userList.add(new User(UserName = 'testGeoUpdate2@intel.com.crm.testclass', LastName = 'User', Email = 'test.user2@intel.com',
            Alias = 'tclass2', TimeZoneSidKey = 'America/Los_Angeles', LocaleSidKey = 'en_US', EmailEncodingKey = 'UTF-8',
            ProfileId = profId, LanguageLocaleKey = 'en_US', Core_User_Country_Code__c = 'BRA'));
        userList.add(new User(UserName = 'testGeoUpdate3@intel.com.crm.testclass', LastName = 'User', Email = 'test.user3@intel.com',
            Alias = 'tclass3', TimeZoneSidKey = 'America/Los_Angeles', LocaleSidKey = 'en_US', EmailEncodingKey = 'UTF-8',
            ProfileId = profId, LanguageLocaleKey = 'en_US'));
        userList.add(new User(UserName = 'testGeoUpdate4@intel.com.crm.testclass', LastName = 'User', Email = 'test.user4@intel.com',
            Alias = 'tclass4', TimeZoneSidKey = 'America/Los_Angeles', LocaleSidKey = 'en_US', EmailEncodingKey = 'UTF-8',
            ProfileId = profId, LanguageLocaleKey = 'en_US', Core_User_Country_Code__c = 'DEU'));
        
        insert userList;
        
        userList = [select Core_User_Geo__c, Core_User_Sub_Geo__c from User where UserName like 'testGeoUpdate%'
            order by UserName
        ];
        
        System.assertEquals('ASMO', userList[0].Core_User_Geo__c);
        System.assertEquals('NAR',userList[0].Core_User_Sub_Geo__c);
        System.assertEquals('ASMO', userList[1].Core_User_Geo__c);
        System.assertEquals('LAR',userList[1].Core_User_Sub_Geo__c);
        System.assertEquals(null, userList[2].Core_User_Geo__c);
        System.assertEquals(null,userList[2].Core_User_Sub_Geo__c);
        System.assertEquals('EMEA', userList[3].Core_User_Geo__c);
        System.assertEquals('CER',userList[3].Core_User_Sub_Geo__c);
        
        // Test some updates
        userList[0].Core_User_Country_Code__c = 'CAN';
        userList[1].Core_User_Country_Code__c = null;
        userList[2].Core_User_Country_Code__c = 'DEU';
        userList[3].Core_User_Country_Code__c = 'USA';
        
        System.runAs(Core_Test_Utility.systemAdminUser) {
            update UserList;
        }

        userList = [select Core_User_Geo__c, Core_User_Sub_Geo__c from User where UserName like 'testGeoUpdate%'
            order by UserName
        ];

        System.assertEquals('ASMO', userList[0].Core_User_Geo__c);
        System.assertEquals('NAR',userList[0].Core_User_Sub_Geo__c);
        System.assertEquals(null, userList[1].Core_User_Geo__c);
        System.assertEquals(null,userList[1].Core_User_Sub_Geo__c);
        System.assertEquals('EMEA', userList[2].Core_User_Geo__c);
        System.assertEquals('CER',userList[2].Core_User_Sub_Geo__c);
        System.assertEquals('ASMO', userList[3].Core_User_Geo__c);
        System.assertEquals('NAR',userList[3].Core_User_Sub_Geo__c);
    }
    
    
    /*
     * Method name  : AddUsersToProfileGroups_Test
     * Description  : Method to test AddUsersToProfileGroups functionality
     * Return Type  : void
     * Parameters   : None
     */
    
    static testMethod void AddUsersToProfileGroups_Test() {
        
        System.runAs(Core_Test_Utility.systemAdminUser) {
            
            // Profiles used in the test
            String sProfileName1 = 'Standard User';
            String sProfileName2 = 'Read Only';
            
            // User used in the test
            String sLastName = 'User1';
            String sAlias = 'tuser1';
            String sEmail = 'test.user1@intel.com';
            String sUserName = 'test.user1@intel.com.crm.testclass';
            
            // Variables list
            Id profileId1, profileId2;
            Id groupId1, groupId2;
            Id groupMemberId1, groupMemberId2;
            List<GroupMember> lstGroupMembers = null;
            List<Profile> lstProfiles = null;
            
            
            // Get the Id of the first Profile             
            lstProfiles = [SELECT Id FROM Profile WHERE Name = :sProfileName1 LIMIT 1];
            if (lstProfiles.size() == 0)
                profileId1 = null;
            else
                profileId1 = lstProfiles[0].Id;
            
            // Make sure that the Id of the first Profile is not null
            System.assertNotEquals(null, profileId1);
            
            // Get the Id of the second profile
            lstProfiles = [SELECT Id FROM Profile WHERE Name = :sProfileName2 LIMIT 1];
            if (lstProfiles.size() == 0)
                profileId2 = null;
            else
                profileId2 = lstProfiles[0].Id;
            
            // Make sure that the Id of the second profile is not null
            System.assertNotEquals(null, profileId2);
            
            // Get the mappings between profiles and public groups from custom settings
            Map<Id, Id> mapProfileToGroup = Core_UserHandler.LoadProfileToGroupMapping();
            
            // Get the Id of the Group that maps to the first Profile
            groupId1 = mapProfileToGroup.get(profileId1);
            // Make sure that the Id of the first Group is not null
            System.assertNotEquals(null, groupId1);
            
            // Get the Id of the Group that maps to the second Profile
            groupId2 = mapProfileToGroup.get(profileId2);
            // Make sure that the Id of the second Group is not null
            System.assertNotEquals(null, groupId2);
            
            
            // TEST CASE 1: Create a new User
            User testUser = new User(LastName = sLastName, Alias = sAlias, Email = sEmail, UserName = sUserName, ProfileId = profileId1,
                EmailEncodingKey = 'UTF-8', TimeZoneSidKey = 'America/Los_Angeles', LocaleSidKey = 'en_US', LanguageLocaleKey = 'en_US');
            
            insert testUser;
            
            // Make sure that the User is part of the first Group (based on the first Profile)
            lstGroupMembers = [SELECT Id FROM GroupMember WHERE UserOrGroupId = :testUser.Id AND GroupId = :groupId1 LIMIT 1];
            
            if (lstGroupMembers.size() == 0)
                groupMemberId1 = null;
            else
                groupMemberId1 = lstGroupMembers[0].Id;
            
            System.assertNotEquals(null, groupMemberId1);
            
            
            // TEST CASE 2: Update the last name of the User. This simulates the use case where anything about a User (except Profile) got updated
            testUser.LastName = testUser.LastName + 'Updated';
            update testUser;
            
            // Make sure that the User is still part of the first Group (based on the first Profile)
            lstGroupMembers = [SELECT Id FROM GroupMember WHERE UserOrGroupId = :testUser.Id AND GroupId = :groupId1 LIMIT 1];
            
            if (lstGroupMembers.size() == 0)
                groupMemberId1 = null;
            else
                groupMemberId1 = lstGroupMembers[0].Id;
            
            System.assertNotEquals(null, groupMemberId1);
            
            
            // TEST CASE 3: Update the profile of the user
            testUser.ProfileId = profileId2;
            update testUser;
            
            // Make sure that the User is now NOT part of the first Group (based on the first Profile)
            lstGroupMembers = [SELECT Id FROM GroupMember WHERE UserOrGroupId = :testUser.Id AND GroupId = :groupId1 LIMIT 1];
            
            if (lstGroupMembers.size() == 0)
                groupMemberId1 = null;
            else
                groupMemberId1 = lstGroupMembers[0].Id;
            
            System.assertEquals(null, groupMemberId1);
            
            // Make sure that the User is now part of the second Group (based on the second Profile)
            lstGroupMembers = [SELECT Id FROM GroupMember WHERE UserOrGroupId = :testUser.Id AND GroupId = :groupId2 LIMIT 1];
            
            if (lstGroupMembers.size() == 0)
                groupMemberId2 = null;
            else
                groupMemberId2 = lstGroupMembers[0].Id;
            
            System.assertNotEquals(null, groupMemberId2);
        }
    }
    
    static testMethod void testUserFreezeUnfreeze() {
        
        /*Core_Trigger_Executions__c triggerEntry = new Core_Trigger_Executions__c(
            Name='userFreezeUnfreeze', Core_Object__c='User', Core_Class_Name__c='Core_UserHandler',
            Core_Trigger_Events__c='before update', Core_Active__c=true, Core_Description__c='testing, testing');
        insert triggerEntry;*/
        
        // Test the following:
        // 1. Attempt to deactivate an active Standard user
        //     - Ensure it remains active, but gets frozen
        // 2. Attempt to deactivate an active "non-Standard license type" user
        //     - Ensure it gets deactivated, and not frozen
        // 3. Attempt to activate a Standard user that's active/frozen
        //     - Ensure it gets unfrozen
        // 4. Attempt to activate a user that's inactive (could have lots of these from prior deactivations)
        //     - Ensure it still gets activated properly
        
        Id standardProfId = [select Id from Profile where Name = 'Standard User' limit 1][0].Id;
        Id nonStandardProfId = [select Id from Profile where Name = 'IPS External Customer' limit 1][0].Id;
        Id standardRoleId = [select Id from UserRole where DeveloperName = 'Admin' limit 1][0].Id;
        //Id portalRoleId = [select Id from UserRole where PortalType = 'CustomerPortal' limit 1][0].Id;
        
        System.debug('##### standardProfId: ' + standardProfId);
        System.debug('##### nonStandardProfId: ' + nonStandardProfId);
        
        Account testAccount = new Account(Name = 'Test Account 1', BillingStreet = '123 Fake St.', BillingCity = 'Springfield',
                                          BillingState = 'OR', BillingCountry = 'USA');
        insert testAccount;
        
        Contact testContact = Core_Test_Utility.createContacts(1)[0];
        testContact.AccountId = testAccount.Id;
        insert testContact;
        
        System.runAs([select Id from User where Id = :Label.Core_User_Provisioning_User_ID limit 1][0]) {
            
            // Insert a few users that meet the above criteria
            List<User> userList = new List<User>();
            userList.add(new User(UserName = 'testUserFreezeUnfreeze1@intel.com.crm.testclass', LastName = 'User', Email = 'test.user1@intel.com',
                                  Alias = 'tuser1', TimeZoneSidKey = 'America/Los_Angeles', LocaleSidKey = 'en_US', EmailEncodingKey = 'UTF-8',
                                  ProfileId = standardProfId, LanguageLocaleKey = 'en_US', UserRoleId = standardRoleId));
            // TO DO: add this user back in and test against it; had to comment it out due to problems deploying in production
            //userList.add(new User(UserName = 'testUserFreezeUnfreeze2@intel.com.crm.testclass', LastName = 'User', Email = 'test.user2@intel.com',
            //                      Alias = 'tuser2', TimeZoneSidKey = 'America/Los_Angeles', LocaleSidKey = 'en_US', EmailEncodingKey = 'UTF-8',
            //                      ProfileId = nonStandardProfId, LanguageLocaleKey = 'en_US', CommunityNickname = 'testUserFreezeUnfreeze2',
            //                      ContactId = testContact.Id, UserRoleId = portalRoleId));
            userList.add(new User(UserName = 'testUserFreezeUnfreeze3@intel.com.crm.testclass', LastName = 'User', Email = 'test.user3@intel.com',
                                  Alias = 'tuser3', TimeZoneSidKey = 'America/Los_Angeles', LocaleSidKey = 'en_US', EmailEncodingKey = 'UTF-8',
                                  ProfileId = standardProfId, LanguageLocaleKey = 'en_US', UserRoleId = standardRoleId));
            userList.add(new User(UserName = 'testUserFreezeUnfreeze4@intel.com.crm.testclass', LastName = 'User', Email = 'test.user4@intel.com',
                                  Alias = 'tuser4', TimeZoneSidKey = 'America/Los_Angeles', LocaleSidKey = 'en_US', EmailEncodingKey = 'UTF-8',
                                  ProfileId = standardProfId, LanguageLocaleKey = 'en_US', IsActive = false, UserRoleId = standardRoleId));
            insert userList;
            
            /*
            Set<Id> userIds = new Set<Id>();
            for (User u : userList)
                userIds.add(u.Id);
            System.debug('##### User table: ' + [select Id, Name, Email, IsActive from User where Id in :userIds]);
            System.debug('##### UserLogin table: ' + [select Id, UserId, IsFrozen from UserLogin where UserId in :userIds]);*/
            
            // Freeze the 2nd "standard" user
            UserLogin userLogin3 = [select IsFrozen from UserLogin where UserId = :userList[2].Id limit 1];
            userLogin3.IsFrozen = true;
            update userLogin3;
            
            // 1. Attempt to deactivate an active Standard user
            //     - Ensure it remains active, but gets frozen
            userList[0].IsActive = false;
            update userList[0];
            User testUser = [select IsActive from User where Id = :userList[0].Id limit 1];
            UserLogin testUserLogin = [select IsFrozen from UserLogin where UserId = :userList[0].Id limit 1];
            System.assertEquals(true, testUser.IsActive);
            System.assertEquals(true, testUserLogin.IsFrozen);
            
            // TO DO: add this back in; had to comment it out due to problems deploying in production
            // 2. Attempt to deactivate an active "non-Standard license type" user
            //     - Ensure it gets deactivated
            //userList[1].IsActive = false;
            //update userList[1];
            //testUser = [select IsActive from User where Id = :userList[1].Id limit 1];
            //testUserLogin = [select IsFrozen from UserLogin where UserId = :userList[1].Id limit 1];
            //System.assertEquals(false, testUser.IsActive);
            //System.assertEquals(false, testUserLogin.IsFrozen);
            
            // 3. Attempt to activate a Standard user that's active/frozen
            //     - Ensure it gets unfrozen
            userList[1].IsActive = true;
            update userList[1];
            testUserLogin = [select IsFrozen from UserLogin where UserId = :userList[1].Id limit 1];
            System.assertEquals(false, testUserLogin.IsFrozen);
            
            // 4. Attempt to activate a user that's inactive (could have lots of these from prior deactivations)
            //     - Ensure it still gets activated properly
            userList[2].IsActive = true;
            update userList[2];
            testUser = [select IsActive from User where Id = :userList[2].Id limit 1];
            testUserLogin = [select IsFrozen from UserLogin where UserId = :userList[2].Id limit 1];
            System.assertEquals(true, testUser.IsActive);
            System.assertEquals(false, testUserLogin.IsFrozen);
        }
    }


    /*
     * Method name  : assignContact_Test
     * Description  : Method to test assignContact functionality
     * Return Type  : void
     * Parameters   : None
     */
    static testMethod void assignContact_Test() {

        System.runAs(Core_Test_Utility.systemAdminUser) {
            
            // Create a test role
            UserRole testUserRole = new UserRole(Name = 'test role');
            insert testUserRole;
            
            // Create a test user, with the role created above
            Id standardProfId = [SELECT Id FROM Profile WHERE Name = 'Standard User' limit 1][0].Id;
            
            Id ExternalCustomerprofileId = [SELECT Id FROM Profile WHERE Name = 'IPS External Customer' limit 1][0].Id;
            
            User testUser = new User(UserName = 'testUser1@intel.com.crm.testclass', LastName = 'User', Email = 'test.user1@intel.com',
                                  Alias = 'tuser1', TimeZoneSidKey = 'America/Los_Angeles', LocaleSidKey = 'en_US', EmailEncodingKey = 'UTF-8',
                                  ProfileId = standardProfId, LanguageLocaleKey = 'en_US', UserRoleId = testUserRole.id);
            insert testUser;
            
            // Create a test Account with the owner user created above
            Account testAccount = new Account(Name = 'Test Account 1', BillingStreet = '123 Fake St.', BillingCity = 'Springfield',
                                          BillingState = 'OR', BillingCountry = 'USA', Core_CIM_ID__c = '1234', Core_CNDA_Number__c = '1234', Ownerid = testUser.id);
            insert testAccount;
            
            
            // TEST 1: Validate the creation of IPS User
            // Create a test Contact for the Account created above
            Contact testContactIPS = Core_Test_Utility.createContacts(1)[0];
            testContactIPS.AccountId = testAccount.Id;
            testContactIPS.Email = 'ips.contact1@abcd.com';
            testContactIPS.Core_IPS_Intel_Support_Owner__c = testuser.id; // Required for IPS
            insert testContactIPS;
            
            // Get the IPS Entitlement Id
            Id entitlementIdIPS = [SELECT Id FROM Core_Entitlement__c WHERE Core_ERPM_Engagement_Id__r.Core_Technical_Engagement_Code__c = :Label.Core_IPS_Engagement_Code AND Core_IsActive__c = true][0].Id;
            System.assertNotEquals(null, entitlementIdIPS);
            // Give IPS Entitlement to the Contact
            Core_Contact_Entitlement__c contactEntitlementIPS = new Core_Contact_Entitlement__c(Core_Contact_Id__c = testContactIPS.Id, Core_Entitlement_Id__c = entitlementIdIPS, Core_Selected__c = true);
            insert contactEntitlementIPS;
            
            // Create a Test IPS Community User using the same email as the Contact created above
            // New user will be created whose Contact is set to the Contact created above (the emails of the Contact and User Match)
            User testUserIPS = new User(UserName = 'ips.contact1@intel.com.crm.testclass', LastName = 'User', Email = 'ips.contact1@abcd.com',
                        Alias = 'tips1', TimeZoneSidKey = 'America/Los_Angeles', LocaleSidKey = 'en_US', EmailEncodingKey = 'UTF-8',
                        ProfileId = Label.Core_IPS_External_Customer_Profile_Id, LanguageLocaleKey = 'en_US', CommunityNickname = 'IPSUser1',
                        PortalRole = 'Manager');
            insert testUserIPS;

            // The trigger must have updated some attributes. Reload the record
            testUserIPS = [SELECT Id, ContactId FROM User WHERE Id = :testUserIPS.Id];
            // The User's Contact Id should be same as the Contact Id
            System.assertEquals(testUserIPS.contactid, testContactIPS.Id);
            
            
            // TEST 2: Validate the creation of Lead Management User
            // Create a test Contact for the Account created above. Give it LMS Engagement 
            Contact testContactLMS = Core_Test_Utility.createContacts(1)[0];
            testContactLMS.AccountId = testAccount.Id;
            testContactLMS.Email = 'lms.contact1@abcd.com';
            insert testContactLMS;
            
            // Get the LMS Entitlement Id
            Id entitlementIdLMS = [SELECT Id FROM Core_Entitlement__c WHERE Core_ERPM_Engagement_Id__r.Core_Technical_Engagement_Code__c = :Label.Core_Partner_Engagement_Code_LMS AND Core_IsActive__c = true][0].Id;
            System.assertNotEquals(null, entitlementIdLMS);
            // Give LMS Entitlement to the Contact
            Core_Contact_Entitlement__c contactEntitlementLMS = new Core_Contact_Entitlement__c(Core_Contact_Id__c = testContactLMS.Id, Core_Entitlement_Id__c = entitlementIdLMS, Core_Selected__c = true);
            insert contactEntitlementLMS;

            // Create a Test LMS Community User using the same email as the Contact created above
            // New user will be created whose Contact is set to the Contact created above (the emails of the Contact and User Match)
            User testUserLMS = new User(UserName = 'lms.contact1@intel.com.crm.testclass', LastName = 'User', Email = 'lms.contact1@abcd.com',
                        Alias = 'tlms1', TimeZoneSidKey = 'America/Los_Angeles', LocaleSidKey = 'en_US', EmailEncodingKey = 'UTF-8',
                        ProfileId = Label.Core_Partner_Profile_Id, LanguageLocaleKey = 'en_US', CommunityNickname = 'LMSUser1',
                        PortalRole = 'Manager');
            insert testUserLMS;

            // The trigger must have updated some attributes. Reload the record
            testUserLMS = [SELECT Id, ContactId FROM User WHERE Id = :testUserLMS.Id];
            // The User's Contact Id should be same as the Contact Id
            System.assertEquals(testUserLMS.contactid, testContactLMS.Id);
            
           
        }
    }
    
    
}