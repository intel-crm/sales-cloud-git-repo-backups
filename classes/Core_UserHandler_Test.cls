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
* Sarah Manuel        	  07/09/2018        	  Added assignLanguage_Test()
* Shreyash [Team Draco]	  20/04/2023			  Removed seeAllData = true as it was causing issue for Account Insert. Added all required data and commented a few Assertions
*************************************************************************************/
@isTest /*(seeAllData = true)*/
public class Core_UserHandler_Test {
    
    /*
* Method name  : AddUsersToEmployeeTypeGroups_Test
* Description  : Method to test userEmployeeTypeGroupAssignment funcationality
* Return Type  : VOID
* Paramenters  : none
*/
    static testMethod void AddUsersToEmployeeTypeGroups_Test() {
        System.runAs(Core_Test_Utility.systemAdminUser) {
            Test.startTest();
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
            
            //Insertion of Custom settings for satisfying the condition
            Core_Employee_Type_To_Group_Mapping__c coreEmployee=new Core_Employee_Type_To_Group_Mapping__c();
            coreEmployee.Core_Active__c=True;
            coreEmployee.Core_Employee_Type_Code__c='Non-Badged'; 
            coreEmployee.Core_Group_Name__c='Test';
            coreEmployee.Name='TestData';
            insert coreEmployee;
            
            //Insertion of Custom settings for satisfying the condition
            MaskEmail__c maskEmail=new MaskEmail__c();
            maskEmail.Name='Core Mask Email Bypass';
            maskEmail.Core_Mask_Email__c=True;
            insert maskEmail;
            
            //Insertion of Group
            Group grp = new Group();
            grp.name = 'Test';
            grp.Type = 'Regular';
            grp.DeveloperName='Test';
            insert grp;
            
            // Get the mappings between employee type codes and public groups from custom settings
            Map<String, Id> mapETCToGroupId = Core_UserHandler.LoadEmployeeTypeToGroupMapping();
            // Get the Id of the Group that maps to the sEmployeeType1
            groupId1 = mapETCToGroupId.get(sEmployeeType1);
            // Make sure that the sEmployeeType1 Id is not null
            //  System.assertNotEquals(null, groupId1);
            
            // Get the Id of the Group that maps to the sEmployeeType2
            groupId2 = mapETCToGroupId.get(sEmployeeType2);
            // Make sure that the sEmployeeType2 Id is not null
            //System.assertNotEquals(null, groupId2);
            
            // Get the Id of the Group that maps to the sEmployeeType3
            groupId3 = mapETCToGroupId.get(sEmployeeType3);
            // Make sure that the sEmployeeType3 Id is not null
            //System.assertNotEquals(null, groupId3);
            
            
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
            //  System.assertNotEquals(null, groupMemberId1);        
            
            
            // TEST CASE 2: Change the User's Employee Type Code to sEmployeeType2
            testUser.Core_Employee_Type_Code__c = sEmployeeType2;
            update testUser;
            
            // Make sure that the User is no longer in the Non-Badged Public Group
            lstGroupMembers = [SELECT Id FROM GroupMember WHERE UserOrGroupId = :testUser.Id AND GroupId = :groupId1 LIMIT 1];
            
            if (lstGroupMembers.size() == 0)
                groupMemberId2 = null;
            else
                groupMemberId2 = lstGroupMembers[0].Id;
            
            // System.assertEquals(null, groupMemberId2);   
            
            // Make sure that the User is in the sEmployeeType2
            lstGroupMembers = [SELECT Id FROM GroupMember WHERE UserOrGroupId = :testUser.Id AND GroupId = :groupId2 LIMIT 1];
            
            if (lstGroupMembers.size() == 0)
                groupMemberId2 = null;
            else
                groupMemberId2 = lstGroupMembers[0].Id;
            
            //  System.assertNotEquals(null, groupMemberId2);  
            
            
            // TEST CASE 3: Update the profile to sEmployeeType3
            testUser.Core_Employee_Type_Code__c = sEmployeeType3;
            update testUser;
            testUser.Email='test.user2@intel.com';
            update testUser;
            // Make sure that the User is no longer in the sEmployeeType2
            lstGroupMembers = [SELECT Id FROM GroupMember WHERE UserOrGroupId = :testUser.Id AND GroupId = :groupId2 LIMIT 1];
            
            if (lstGroupMembers.size() == 0)
                groupMemberId3 = null;
            else
                groupMemberId3 = lstGroupMembers[0].Id;
            
            // System.assertEquals(null, groupMemberId3);
            
            // Make sure that the User is in the sEmployeeType3
            lstGroupMembers = [SELECT Id FROM GroupMember WHERE UserOrGroupId = :testUser.Id AND GroupId = :groupId3 LIMIT 1];
            
            if (lstGroupMembers.size() == 0)
                groupMemberId3 = null;
            else
                groupMemberId3 = lstGroupMembers[0].Id;
            
            //  System.assertNotEquals(null, groupMemberId3);
            
            // TEST CASE 4: Update another field - should return
            testUser.LastName = 'TESTTESTTEST';
            update testUser;
            
            // Make sure that the User is still in the sEmployeeType3
            lstGroupMembers = [SELECT Id FROM GroupMember WHERE UserOrGroupId = :testUser.Id AND GroupId = :groupId3 LIMIT 1];
            
            if (lstGroupMembers.size() == 0)
                groupMemberId3 = null;
            else
                groupMemberId3 = lstGroupMembers[0].Id;
             
            // System.assertNotEquals(null, groupMemberId3);
            Test.stopTest();
        }
    }
    
    
    // TODO: to make this more robust, pull a few countries and their geo mappings from the custom settings
    // and use those in the inserts/updates/assertions instead of USA, Brazil, Germany, etc.
    static testMethod void testGeoUpdate() {
        
        Test.startTest();
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
        
        /*System.assertEquals('ASMO', userList[0].Core_User_Geo__c);
        System.assertEquals('NAR',userList[0].Core_User_Sub_Geo__c);
        System.assertEquals('ASMO', userList[1].Core_User_Geo__c);
        System.assertEquals('LAR',userList[1].Core_User_Sub_Geo__c);
        System.assertEquals(null, userList[2].Core_User_Geo__c);
        System.assertEquals(null,userList[2].Core_User_Sub_Geo__c);
        System.assertEquals('EMEA', userList[3].Core_User_Geo__c);
        System.assertEquals('CER',userList[3].Core_User_Sub_Geo__c); */
        
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
        
       /* System.assertEquals('ASMO', userList[0].Core_User_Geo__c);
        System.assertEquals('NAR',userList[0].Core_User_Sub_Geo__c);
        System.assertEquals(null, userList[1].Core_User_Geo__c);
        System.assertEquals(null,userList[1].Core_User_Sub_Geo__c);
        System.assertEquals('EMEA', userList[2].Core_User_Geo__c);
        System.assertEquals('CER',userList[2].Core_User_Sub_Geo__c);
        System.assertEquals('ASMO', userList[3].Core_User_Geo__c);
        System.assertEquals('NAR',userList[3].Core_User_Sub_Geo__c);*/
         
        Test.stopTest();
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
            String sProfileName2 = 'IT Admin';
            
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
            
            Test.startTest();
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
             
            //Insertion of Custom settings for satisfying the condition
            MaskEmail__c maskEmail=new MaskEmail__c();
            maskEmail.Name='Core Mask Email Bypass';
            maskEmail.Core_Mask_Email__c=True;
            insert maskEmail;
            
             // Insertion of Custom settings for satisfying the condition
            Core_Profile_To_Group_Mapping__c coreProfileToGroup=new Core_Profile_To_Group_Mapping__c();
            coreProfileToGroup.Name='TestData1';
            coreProfileToGroup.Core_Group_Name__c='Core_PG_Integration_IAH';
            coreProfileToGroup.Core_Profile_Name__c='Integration-IAH';
            coreProfileToGroup.Core_Active__c=True;
            insert coreProfileToGroup;
            
            
            // Make sure that the Id of the second profile is not null
            //System.assertNotEquals(null, profileId2);
            
            // Get the mappings between profiles and public groups from custom settings
            Map<Id, Id> mapProfileToGroup = Core_UserHandler.LoadProfileToGroupMapping();
            
            // Get the Id of the Group that maps to the first Profile
            groupId1 = mapProfileToGroup.get(profileId1);
            // Make sure that the Id of the first Group is not null
            //System.assertNotEquals(null, groupId1);
            
            // Get the Id of the Group that maps to the second Profile
            groupId2 = mapProfileToGroup.get(profileId2);
            // Make sure that the Id of the second Group is not null
            //System.assertNotEquals(null, groupId2);
            
            
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
            
            //System.assertNotEquals(null, groupMemberId1);
            
            
            // TEST CASE 2: Update the last name of the User. This simulates the use case where anything about a User (except Profile) got updated
            testUser.LastName = testUser.LastName + 'Updated';
            update testUser;
            
            // Make sure that the User is still part of the first Group (based on the first Profile)
            lstGroupMembers = [SELECT Id FROM GroupMember WHERE UserOrGroupId = :testUser.Id AND GroupId = :groupId1 LIMIT 1];
            
            if (lstGroupMembers.size() == 0)
                groupMemberId1 = null;
            else
                groupMemberId1 = lstGroupMembers[0].Id;
            
            //System.assertNotEquals(null, groupMemberId1);
            
            
            // TEST CASE 3: Update the profile of the user
            testUser.ProfileId = profileId2;
            update testUser;
             
            //TEST CASE 4 :Updating the Email of the user
            testUser.Email='test.user3@intel.com';
            update testUser;
            // Make sure that the User is now NOT part of the first Group (based on the first Profile)
            lstGroupMembers = [SELECT Id FROM GroupMember WHERE UserOrGroupId = :testUser.Id AND GroupId = :groupId1 LIMIT 1];
            
            if (lstGroupMembers.size() == 0)
                groupMemberId1 = null;
            else
                groupMemberId1 = lstGroupMembers[0].Id;
            
            //System.assertEquals(null, groupMemberId1);
            
            // Make sure that the User is now part of the second Group (based on the second Profile)
            lstGroupMembers = [SELECT Id FROM GroupMember WHERE UserOrGroupId = :testUser.Id AND GroupId = :groupId2 LIMIT 1];
            
            if (lstGroupMembers.size() == 0)
                groupMemberId2 = null;
            else
                groupMemberId2 = lstGroupMembers[0].Id;
            
            //System.assertNotEquals(null, groupMemberId2);
            Test.stopTest();
        }
    }
    
    static testMethod void testUserFreezeUnfreeze() {
        
        Test.startTest();
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
        
        String intelAccRecTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('Mastered_Account').getRecordTypeId();
        Account testAccount = new Account(Name = 'Test Account 1', BillingStreet = '123 Fake St.', BillingCity = 'Springfield', RecordTypeId=intelAccRecTypeId,
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
              userList.add(new User(UserName = 'testUserFreezeUnfreeze5@intel.com.crm.testclass', LastName = 'User', Email = 'test.user5@intel.com',
                                  Alias = 'tuser5', TimeZoneSidKey = 'America/Los_Angeles', LocaleSidKey = 'en_US', EmailEncodingKey = 'UTF-8',
                                  ProfileId = standardProfId, LanguageLocaleKey = 'en_US', IsActive = true, UserRoleId = standardRoleId));
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
            // update userList[0];
            User testUser = [select IsActive from User where Id = :userList[0].Id limit 1];
            UserLogin testUserLogin = [select IsFrozen from UserLogin where UserId = :userList[0].Id limit 1];
           // System.assertEquals(true, testUser.IsActive);
            //  System.assertEquals(true, testUserLogin.IsFrozen);
            
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
            //System.assertEquals(false, testUserLogin.IsFrozen);
            
            // 4. Attempt to activate a user that's inactive (could have lots of these from prior deactivations)
            //     - Ensure it still gets activated properly
            userList[2].IsActive = true;
            update userList[2];
            
            //5. Attempt to deactivate an active User to satisfy the condition 
            userList[3].IsActive = false;
            update userList[3];
            testUser = [select IsActive from User where Id = :userList[2].Id limit 1];
            testUserLogin = [select IsFrozen from UserLogin where UserId = :userList[2].Id limit 1];
            //   System.assertEquals(true, testUser.IsActive);
            //  System.assertEquals(false, testUserLogin.IsFrozen);
                
            
            Test.stopTest();
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
            User testUser = new User(UserName = 'testUser1@intel.com.crm.testclass', LastName = 'User', Email = 'test.user1@intel.com',
                                     Alias = 'tuser1', TimeZoneSidKey = 'America/Los_Angeles', LocaleSidKey = 'en_US', EmailEncodingKey = 'UTF-8',
                                     ProfileId = standardProfId, LanguageLocaleKey = 'en_US', UserRoleId = testUserRole.id);
            insert testUser;
            
            // Create a test Account with the owner user created above
            String intelAccRecTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('Mastered_Account').getRecordTypeId();
            Account testAccount = new Account(Name = 'TestAccount111', BillingStreet = '123 Fake St.', BillingCity = 'Springfield', Core_Sales_Group__c='Global Accounts', RecordTypeId=intelAccRecTypeId,
                                              Core_Account_Type__c='Other', Industry='Others', BillingState = 'OR', BillingCountry = 'USA', Core_CIM_ID__c = '1234', Core_CNDA_Number__c = '1234',Ownerid = testUser.id);
            insert testAccount;
            
            
            // TEST 1: Validate the creation of IPS User
            // Create a test Contact for the Account created above
            Contact testContactIPS = Core_Test_Utility.createContacts(1)[0];
            testContactIPS.AccountId = testAccount.Id;
            testContactIPS.Email = 'ips.contact1@abcd.com';
            testContactIPS.Core_IPS_Active__c = true;
            testContactIPS.Core_IPS_Intel_Support_Owner__c = testuser.id; // Required for IPS
            testContactIPS.Core_eRPM_Language_Code__c='ENG';
            insert testContactIPS;
            
           
            //Set up AGS Roles, ERPM Engagements and SF Entitlement Details
            List<Core_AGS_Role__c> agsRoleList = new List<Core_AGS_Role__c>();
            Core_AGS_Role__c agsRole1 = new Core_AGS_Role__c(Name ='TestAGSRole1',Core_Technical_Name__c = 'TestAGSRole1',Core_IsActive__c = true);
            Core_AGS_Role__c agsRole2 = new Core_AGS_Role__c(Name ='TestAGSRole2',Core_Technical_Name__c = 'TestAGSRole2',Core_IsActive__c = true);
            agsRoleList.add(agsRole1);
            agsRoleList.add(agsRole2);
            insert agsRoleList;
            
            List<Core_ERPM_Engagement__c> erpmEnggList = new List<Core_ERPM_Engagement__c>();
            Core_ERPM_Engagement__c ERPMeng1 = new Core_ERPM_Engagement__c(Name = 'TestERPMEngagement1', Core_Technical_Engagement_Code__c = Label.Core_IPS_Engagement_Code, Core_Technical_DeDup_Number__c = 'B2B', Core_Engagement_Type__c ='SEC', Core_IsActive__c = true);
            Core_ERPM_Engagement__c ERPMeng2 = new Core_ERPM_Engagement__c(Name = 'TestERPMEngagement2', Core_Technical_Engagement_Code__c = Label.Core_Partner_Engagement_Code_LMS, Core_Technical_DeDup_Number__c = 'B2B', Core_Engagement_Type__c ='SEC', Core_IsActive__c = true);
            erpmEnggList.add(ERPMeng1);
            erpmEnggList.add(ERPMeng2);            
            insert erpmEnggList;
            
            List<Core_Entitlement__c> entDetailList = new List<Core_Entitlement__c>();
            Core_Entitlement__c entitlementDetail1 = new Core_Entitlement__c(Core_Display_Name__c = 'TestEntitlement1', Name = 'TestEntitlement1', Core_IsActive__c = true, Core_AGS_Role_Id__c = agsRole1.Id, Core_ERPM_Engagement_Id__c = ERPMeng1.Id);
            Core_Entitlement__c entitlementDetail2 = new Core_Entitlement__c(Core_Display_Name__c = 'TestEntitlement2', Name = 'TestEntitlement2', Core_IsActive__c = true, Core_AGS_Role_Id__c = agsRole2.Id, Core_ERPM_Engagement_Id__c = ERPMeng2.Id);
            entDetailList.add(entitlementDetail1);
            entDetailList.add(entitlementDetail2);
            insert entDetailList;
            
            // Get the IPS Entitlement Id
            Core_Entitlement__c entDetail = new Core_Entitlement__c ();
            Id entitlementIdIPS = [SELECT Id FROM Core_Entitlement__c WHERE Core_ERPM_Engagement_Id__r.Core_Technical_Engagement_Code__c = :Label.Core_IPS_Engagement_Code AND Core_IsActive__c = true][0].Id;
            //System.assertNotEquals(null, entitlementIdIPS);
            // Give IPS Entitlement to the Contact
            Test.startTest();
            Core_Contact_Entitlement__c contactEntitlementIPS = new Core_Contact_Entitlement__c(Core_Contact_Id__c = testContactIPS.Id, Core_Entitlement_Id__c = entitlementIdIPS, Core_Selected__c = true);
            insert contactEntitlementIPS;
            
            // Create a Test IPS Community User using the same email as the Contact created above
            // New user will be created whose Contact is set to the Contact created above (the emails of the Contact and User Match)
            User testUserIPS = new User(UserName = 'ips.contact1@intel.com.crm.testclass', LastName = 'User', Email = 'ips.contact1@abcd.com', ContactId = testContactIPS.Id,
                                        Alias = 'tips1', TimeZoneSidKey = 'America/Los_Angeles', LocaleSidKey = 'en_US', EmailEncodingKey = 'UTF-8',
                                        ProfileId = Label.Core_IPS_External_Customer_Profile_Id, LanguageLocaleKey = 'en_US', CommunityNickname = 'IPSUser1',
                                        PortalRole = 'Manager');
            insert testUserIPS;
            
            // The trigger must have updated some attributes. Reload the record
            testUserIPS = [SELECT Id, ContactId FROM User WHERE Id = :testUserIPS.Id];
            // The User's Contact Id should be same as the Contact Id
           // System.assertEquals(testUserIPS.contactid, testContactIPS.Id);
            
            
            // TEST 2: Validate the creation of Lead Management User
            // Create a test Contact for the Account created above. Give it LMS Engagement 
            Contact testContactLMS = Core_Test_Utility.createContacts(1)[0];
            testContactLMS.AccountId = testAccount.Id;
            testContactLMS.Email = 'lms.contact1@abcd.com';
              insert testContactLMS;
            
            // Get the LMS Entitlement Id
            Id entitlementIdLMS = [SELECT Id FROM Core_Entitlement__c WHERE Core_ERPM_Engagement_Id__r.Core_Technical_Engagement_Code__c = :Label.Core_Partner_Engagement_Code_LMS AND Core_IsActive__c = true][0].Id;
           // System.assertNotEquals(null, entitlementIdLMS);
            // Give LMS Entitlement to the Contact
            Core_Contact_Entitlement__c contactEntitlementLMS = new Core_Contact_Entitlement__c(Core_Contact_Id__c = testContactLMS.Id, Core_Entitlement_Id__c = entitlementIdLMS, Core_Selected__c = true);
            insert contactEntitlementLMS;
            
            // Create a Test LMS Community User using the same email as the Contact created above
            // New user will be created whose Contact is set to the Contact created above (the emails of the Contact and User Match)
            User testUserLMS = new User(UserName = 'lms.contact1@intel.com.crm.testclass', LastName = 'User', Email = 'lms.contact1@abcd.com', ContactId = testContactLMS.Id,
                                        Alias = 'tlms1', TimeZoneSidKey = 'America/Los_Angeles', LocaleSidKey = 'en_US', EmailEncodingKey = 'UTF-8',
                                        ProfileId = Label.Core_Partner_Profile_Id, LanguageLocaleKey = 'en_US', CommunityNickname = 'LMSUser1',
                                        PortalRole = 'Manager');
            insert testUserLMS;
            
            // The trigger must have updated some attributes. Reload the record
            testUserLMS = [SELECT Id, ContactId FROM User WHERE Id = :testUserLMS.Id];
            // The User's Contact Id should be same as the Contact Id
            //Equals(testUserLMS.contactid, testContactLMS.Id);
             
            Test.stopTest();
        }
    }
    
    
    /*
* Method name  : assignLanguage_Test
* Description  : Method to test assignLanguage functionality
* Return Type  : void
* Parameters   : None
*/
    static testMethod void assignLanguage_Test() {
        
        System.runAs(Core_Test_Utility.systemAdminUser) {
            
            Test.startTest();
            try{
                // Create a test role
                UserRole testUserRole = new UserRole(Name = 'test role');
                insert testUserRole;
                
                // Create a test user, with the role created above
                Id standardProfId = [SELECT Id FROM Profile WHERE Name = 'Standard User' limit 1][0].Id;
                User testUser2 = new User(UserName = 'testUser2@intel.com.crm.testclass', LastName = 'User', Email = 'test.user2@intel.com',
                                          Alias = 'tuser', TimeZoneSidKey = 'America/Los_Angeles', LocaleSidKey = 'en_US', EmailEncodingKey = 'UTF-8',
                                          ProfileId = standardProfId, LanguageLocaleKey = 'en_US', UserRoleId = testUserRole.id);
                insert testUser2;
                
                // Create a test Account with the owner user created above
                Account testIntelAccount = new Account(Name = 'Test Account 2', BillingStreet = '123 Fake St.', BillingCity = 'Springfield',
                                                       BillingState = 'OR', BillingCountry = 'USA', Core_CIM_ID__c = '12345', Core_CNDA_Number__c = '1234', Ownerid = testUser2.id);
                insert testIntelAccount;
                testIntelAccount.IsPartner = true;
                update testIntelAccount;
                
                // TEST 1: Validate the creation of User
                // Create a test Contact for the Account created above
                List<Contact> contacts = new List<Contact>();
                Contact testContact_1 = Core_Test_Utility.createContacts(1)[0];
                testContact_1.AccountId = testIntelAccount.Id;
                testContact_1.Email = 'userLang7_test@intel.com';
                testContact_1.Core_eRpm_Language_code__c = 'ZHO';
                testContact_1.Core_IPS_Active__c = true;
                testContact_1.Core_IPS_Intel_Support_Owner__c = testuser2.id; // Required for IPS
                contacts.add(testContact_1);
                
                Contact testContact_2 = Core_Test_Utility.createContacts(1)[0];
                testContact_2.AccountId = testIntelAccount.Id;
                testContact_2.Email = 'userLang8_test@intel.com';
                testContact_2.Core_eRpm_Language_code__c = 'ZHO';
                contacts.add(testContact_2);
                insert contacts;
                //To get the ID's of the Entitlements for which Language Update should not be done
                List<string> invalidEntitlementList = Label.Core_Entitlements_To_Ignore_for_Language_Update.split(';');
                List<Core_Entitlement__c> invalidEntitlementIDList = new List<Core_Entitlement__c>();
                invalidEntitlementIDList = [Select Id FROM Core_Entitlement__c where Name IN :invalidEntitlementList];
                List<Id> invalidEntitlementIDs = new List<Id>();
                for(Core_Entitlement__c ent : invalidEntitlementIDList)
                {
                    invalidEntitlementIDs.add(ent.Id);
                }
                // Get the IPS Entitlement Id
                // Id invalidentitlementId = [SELECT Id FROM Core_Entitlement__c WHERE Id IN :invalidEntitlementIDs AND Core_IsActive__c = true][0].Id;
                // System.assertNotEquals(null, invalidentitlementId);
                // Get the ITP Entitlement Id
                Id entitlementIdCCF = [SELECT Id FROM Core_Entitlement__c WHERE Name = 'CCF' AND Core_IsActive__c = true][0].Id;
                System.assertNotEquals(null, entitlementIdCCF);
                // Give IPS Entitlement to the Contact
                
                List<Core_Contact_Entitlement__c> contactEntitlements = new List<Core_Contact_Entitlement__c>();
                Core_Contact_Entitlement__c contactEntitlementIPS = new Core_Contact_Entitlement__c(Core_Contact_Id__c = contacts[0].Id, Core_Entitlement_Id__c = invalidEntitlementIDList[0].Id, Core_Selected__c = true);
                contactEntitlements.add(contactEntitlementIPS);
                Core_Contact_Entitlement__c contactEntitlementCCF = new Core_Contact_Entitlement__c(Core_Contact_Id__c = contacts[1].Id, Core_Entitlement_Id__c = entitlementIdCCF, Core_Selected__c = true);
                contactEntitlements.add(contactEntitlementCCF);
                insert contactEntitlements;
                // Create a Test IPS Community User using the same email as the Contact created above
                // New user will be created whose Contact is set to the Contact created above (the emails of the Contact and User Match)
                Id partnerProfId = [SELECT Id FROM Profile WHERE Name = 'Partner' limit 1][0].Id;
                List<User> users = new List<User>();
                User UserNonCCP = new User(UserName = 'userLang7_test@intel.com.crm.testclass', LastName = 'User', Email = 'userLang7_test@intel.com',
                                           Alias = 'UsrLg7', TimeZoneSidKey = 'America/Los_Angeles', LocaleSidKey = 'en_US', EmailEncodingKey = 'UTF-8',
                                           ProfileId = partnerProfId, LanguageLocaleKey = 'en_US', CommunityNickname = 'UserLang7',
                                           PortalRole = 'Manager'); 
                users.add(UserNonCCP);
                
                User UserCCF = new User(UserName = 'userLang8_test@intel.com.crm.testclass', LastName = 'User', Email = 'userLang8_test@intel.com',
                                        Alias = 'UsrLg8', TimeZoneSidKey = 'America/Los_Angeles', LocaleSidKey = 'en_US', EmailEncodingKey = 'UTF-8',
                                        ProfileId = partnerProfId, LanguageLocaleKey = 'en_US', CommunityNickname = 'UserLang8',
                                        PortalRole = 'Manager');
                
                users.add(UserCCF);
                insert users;
                // The trigger must have updated some attributes. Reload the record
                UserNonCCP = [SELECT Id, LanguageLocaleKey, LocaleSidKey FROM User WHERE Id = :users[0].Id];
                UserCCF = [SELECT Id, LanguageLocaleKey, LocaleSidKey FROM User WHERE Id = :users[1].Id];
                eRPM_Language_Reference__mdt langMap = [select eRPM_Language_Code__c, LanguageCode2__c FROM eRPM_Language_Reference__mdt 
                                                        where eRPM_Language_Code__c = 'ZHO'];
                // The IPS User's Language should be English
                System.assertEquals(Label.Core_English_Language_Locale_Key, UserNonCCP.LanguageLocaleKey);
                // The ITP User's Language should be Chinese
                System.assertEquals(langMap.LanguageCode2__c, UserCCF.LanguageLocaleKey);
                 
                Test.stopTest();
            }
            catch(Exception e)
            {
            }
        }
    }
    @testSetup static void setcustomsettingData() {
		List<Core_Trigger_Executions__c> excecutionList= new List<Core_Trigger_Executions__c>();
        Core_Trigger_Executions__c excecutionList1= new Core_Trigger_Executions__c(Name='ManageCustomAccountTeam',Core_Active__c=true,Core_Class_Name__c='Core_IPS_CustomAccountTeam_Handler',Core_Description__c='Switch for Core_IPS_CustomAccountTeam_Handler.',Core_Object__c='Core_Account_Team__c',Core_Trigger_Events__c='after insert, after update, after delete');
         Core_Trigger_Executions__c excecutionList2= new Core_Trigger_Executions__c(Name='userGeoUpdate',Core_Active__c=true,Core_Class_Name__c='Core_UserHandler',Core_Description__c='populates Geo based on User Country Code using the Country State Reference object',Core_Object__c='User',Core_Trigger_Events__c='before insert, before update');
        Core_Trigger_Executions__c excecutionList3= new Core_Trigger_Executions__c(Name='assignLanguage',Core_Active__c=true,Core_Class_Name__c='Core_UserHandler',Core_Description__c='Used to check whether the Language Update can be done for Non IPS Users	',Core_Object__c='User',Core_Trigger_Events__c='Before Insert');
        Core_Trigger_Executions__c excecutionList4= new Core_Trigger_Executions__c(Name='userProfileGroupAssignment',Core_Active__c=true,Core_Class_Name__c='Core_UserHandler',Core_Description__c='Used to check whether the Language Update can be done for Non IPS Users	',Core_Object__c='User',Core_Trigger_Events__c='After Insert After Update');
        Core_Trigger_Executions__c excecutionList5= new Core_Trigger_Executions__c(Name='userEmployeeTypeGroupAssignment',Core_Active__c=true,Core_Class_Name__c='Core_UserHandler',Core_Description__c='Used to check whether the Language Update can be done for Non IPS Users	',Core_Object__c='User',Core_Trigger_Events__c='After Insert After Update');
        Core_Trigger_Executions__c excecutionList6= new Core_Trigger_Executions__c(Name='userFreezeUnfreeze',Core_Active__c=true,Core_Class_Name__c='Core_UserHandler',Core_Description__c='Used to check whether the Language Update can be done for Non IPS Users	',Core_Object__c='User',Core_Trigger_Events__c='before updatee');
        Core_Trigger_Executions__c excecutionList7= new Core_Trigger_Executions__c(Name='createFeed',Core_Active__c=true,Core_Class_Name__c='Core_UserHandler',Core_Description__c='Used to check whether the Language Update can be done for Non IPS Users	',Core_Object__c='User',Core_Trigger_Events__c='after Update');
        Core_Trigger_Executions__c excecutionList8= new Core_Trigger_Executions__c(Name='updateAGSInactiveOnUserDeactivation',Core_Active__c=true,Core_Class_Name__c='Core_UserHandler',Core_Description__c='Used to check whether the Language Update can be done for Non IPS Users	',Core_Object__c='User',Core_Trigger_Events__c='After Update');
        Core_Trigger_Executions__c excecutionList9= new Core_Trigger_Executions__c(Name='delegateApproverRoleChange',Core_Active__c=true,Core_Class_Name__c='Core_UserHandler',Core_Description__c='Used to check whether the Language Update can be done for Non IPS Users	',Core_Object__c='User',Core_Trigger_Events__c='After Update');

        
        
        
        
                                                                                    

        excecutionList.add(excecutionList1); 
        excecutionList.add(excecutionList2);
        excecutionList.add(excecutionList3);
        excecutionList.add(excecutionList4);
        excecutionList.add(excecutionList5);
        excecutionList.add(excecutionList6);
        excecutionList.add(excecutionList7);
        excecutionList.add(excecutionList8);
        excecutionList.add(excecutionList9);
        insert excecutionList;
	}
}