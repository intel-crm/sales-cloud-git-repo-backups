/************************************************************************************************************************************************************************************
* Class Name  : Core_MDF_UserGroupMappingAutomation_Test 
* Version     : 1.0 
* Created Date: 21-02-2019
* Modification Log :
* Developer                     Date                          Description
* --------------------------------------------------------------------------------------------------------------------------------------------------
* Intel - Narayani Perachi 		21-02-2019					  Test class for Core_MDF_UserGroupMappingAutomation
* Intel - NP (11630236)         22-10-2019                    Removed unwanted code
* Intel - NP (11630236)			16-06-2020					  Added code to cover PNUM deletion class
**************************************************************************************************************************************************************************************/
@isTest(SeeAllData=FALSE)
public class Core_MDF_UserGroupMappingAutomation_Test 
{
    public static List<Contact> contactRecords = new List<Contact>();
    public static List<Contact> contactRecordsWithNoUser = new List<Contact>();
	
    @isTest static void testUserGroupMappingAutomation()
    {
        
		List<Contact> updateContactRecord = new List<Contact>();  
     
        Account intacc= [select id from Account where Name='UserGroupMapping Intel Account'];
        Account coMarketingAccount=[select id from Account where Name='UserGroupMapping Co-Marketing Account'];
        Account noPGMAccount = [select id from Account where Name='UserGroupMapping NO PGM Intel Account'];
        
        //Creating Contact 
        Contact ccfdcfContact = [select id,Core_Audience_List__c from Contact limit 1];
        User ccfdcfUser =[select id from User where ContactId=: ccfdcfContact.id];
        List<Groupmember> ccfdcfUserGmRecord = [select id from Groupmember where UserOrGroupId=: ccfdcfUser.id];

        //Assert cannot be on the result since deletion of Groupmember/ PNUM happens in future methods
        system.assertEquals(2, ccfdcfUserGmRecord.size(), 'Existing GM records');

        Contact dcfccfContact = Core_MDF_CCP_TestDataUtility.createContact(intacc.Id,false);
        dcfccfContact.Core_Audience_List__c='DCF User;CCF User';

        Contact nullAudienceContact = Core_MDF_CCP_TestDataUtility.createContact(intacc.Id,false);
        nullAudienceContact.Core_Audience_List__c=' ';
        
        Contact spcfContact = Core_MDF_CCP_TestDataUtility.createContact(intacc.Id,false);
        spcfContact.Core_Audience_List__c='SPCF User';
        
        Contact noPGMContact = Core_MDF_CCP_TestDataUtility.createContact(noPGMAccount.Id,false);
        noPGMContact.Core_Audience_List__c='SPCF User; DCF User';
		
        
        contactRecords.add(dcfccfContact);contactRecords.add(nullAudienceContact);contactRecords.add(spcfContact); contactRecords.add(noPGMContact);
        Database.insert(contactRecords);
		
        Test.startTest();
        Core_MDF_Partner_Node_User_Mapping__c ccfPnumRecordForCcfspcfContact = Core_MDF_CCP_TestDataUtility.createPartnerNodeUserMapping(coMarketingAccount.id,ccfdcfUser.id, true);

        //Removing one CCP entitlement while retaining the other
        dcfccfContact.Core_Audience_List__c='DCF User;';
        updateContactRecord.add(dcfccfContact);
                        
        //Removing all CCP entitlements
        ccfdcfContact.Core_Audience_List__c = '';
        updateContactRecord.add(ccfdcfContact);
                  
        //Adding CCP entitlement to a Non CCP contact
        nullAudienceContact.Core_Audience_List__c = 'DCF User;';
        updateContactRecord.add(nullAudienceContact);

        Database.update(updateContactRecord);
        Test.stopTest();
        Core_MDF_UserGroupMappingAutomation.createMapforNullGroupId('DCF User',ccfdcfUser.id);
        
    }

    @TestSetup
    static void createTestData(){
        
        Profile sysAdminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator' LIMIT 1];
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        // Creating User with utility class 
        User sysAdmin = Core_MDF_CCP_TestDataUtility.createUser(false);
        sysAdmin.profileId = sysAdminProfile.Id;
        sysAdmin.UserRoleId = portalRole.Id;
        Database.insert(sysAdmin);

        List<Core_Trigger_Executions__c> triggerExes = new List<Core_Trigger_Executions__c>();

        System.runAs(sysAdmin)
        {   
            
            //The below has been added to cover the other lines in Core_Contact Trigger
            Core_Trigger_Executions__c triggerExe1 = new Core_Trigger_Executions__c();
            triggerExe1.Name = 'contactJobFunction';
            triggerExe1.Core_Object__c = 'Contact';
            triggerExe1.Core_Active__c = TRUE;
            triggerExe1.Core_Trigger_Events__c = 'After Insert, After Update';
            triggerExe1.Core_Description__c = 'Updates Job Function based on Job Function Code and vice versa.';
            triggerExe1.Core_Class_Name__c = 'Core_ContactHandler';
            triggerExes.add(triggerExe1);
                                    
            Core_Trigger_Executions__c triggerExe2 = new Core_Trigger_Executions__c();
            triggerExe2.Name = 'ContactEmailChangeUpdate';
            triggerExe2.Core_Active__c = true;
            triggerExe2.Core_Class_Name__c = 'Core_Contact_EmailChange_Handler';
            triggerExe2.Core_Description__c = 'test description';
            triggerExe2.Core_Object__c = 'Contact';
            triggerExe2.Core_Trigger_Events__c = 'After Update';
            triggerExes.add(triggerExe2);
                                    
            Core_Trigger_Executions__c triggerExe3 = new Core_Trigger_Executions__c();
            triggerExe3.Name = 'ContactAccountChangeUpdate';
            triggerExe3.Core_Active__c = true;
            triggerExe3.Core_Class_Name__c = 'Core_Contact_AccountChange_Handler';
            triggerExe3.Core_Description__c = 'test description';
            triggerExe3.Core_Object__c = 'Contact';
            triggerExe3.Core_Trigger_Events__c = 'Before Update , After Update';
            triggerExes.add(triggerExe3);

            Core_Trigger_Executions__c triggerExe4 = new Core_Trigger_Executions__c();
            triggerExe4.Name = 'intStatusLastUpdate';
            triggerExe4.Core_Active__c = true;
            triggerExe4.Core_Class_Name__c = 'Core_Contact_AccountChange_Handler';
            triggerExe4.Core_Description__c = 'test description';
            triggerExe4.Core_Object__c = 'Contact';
            triggerExe4.Core_Trigger_Events__c = 'Before Insert, Before Update';
            triggerExes.add(triggerExe4);
                        
            Core_Trigger_Executions__c triggerExe5 = new Core_Trigger_Executions__c();
            triggerExe5.Name = 'userGroupMappingIndicator';
            triggerExe5.Core_Active__c = true;
            triggerExe5.Core_Class_Name__c = 'Core_MDF_UserGroupMappingAutomation';
            triggerExe5.Core_Description__c = 'User Group Mapping Automation';
            triggerExe5.Core_Object__c = 'Contact';
            triggerExe5.Core_Trigger_Events__c = 'After Insert, After Update';
            triggerExes.add(triggerExe5);

            Core_Trigger_Executions__c triggerExe6 = new Core_Trigger_Executions__c();
            triggerExe6.Name = 'pnumDeletionIndicator';
            triggerExe6.Core_Active__c = true;
            triggerExe6.Core_Class_Name__c = 'Core_MDF_UserGroupMapping_Deletion';
            triggerExe6.Core_Description__c = 'User Group Mapping Automation';
            triggerExe6.Core_Object__c = 'Contact';
            triggerExe6.Core_Trigger_Events__c = 'After Insert, After Update';
            triggerExes.add(triggerExe6);
            
            Core_Trigger_Executions__c triggerExe7 = new Core_Trigger_Executions__c();
            triggerExe7.Name = 'callExternalUserSharingFromUGMDeletion';
            triggerExe7.Core_Active__c = true;
            triggerExe7.Core_Class_Name__c = 'Core_MDF_UserGroupMapping_Deletion';
            triggerExe7.Core_Description__c = 'User Group Mapping Automation';
            triggerExe7.Core_Object__c = 'Contact';
            triggerExe7.Core_Trigger_Events__c = 'After Insert, After Update';
            triggerExes.add(triggerExe7);
            
            Core_Trigger_Executions__c triggerExe8 = new Core_Trigger_Executions__c();
            triggerExe8.Name = 'callExtUsrSharingFrmUGMAutomation';
            triggerExe8.Core_Active__c = true;
            triggerExe8.Core_Class_Name__c = 'Core_MDF_UserGroupMappingAutomation';
            triggerExe8.Core_Description__c = 'User Group Mapping Automation';
            triggerExe8.Core_Object__c = 'Contact';
            triggerExe8.Core_Trigger_Events__c = 'After Insert, After Update';
            triggerExes.add(triggerExe8);

            Database.insert(triggerExes);
          
       		// Creating channel program with utility class
            ChannelProgram cp1 = Core_MDF_CCP_TestDataUtility.createProgram ('Client Co-Marketing Fund','Client CoMarketing Fund', true);
            ChannelProgram cp2 = Core_MDF_CCP_TestDataUtility.createProgram ('Data Center Co-Marketing Fund','Data Center CoMarketing Fund', true);
                         
            // Creating IntelAccount with utility class
            Account intacc = Core_MDF_CCP_TestDataUtility.createIntelAccount ('UserGroupMapping Intel Account',Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, true);
            Account accWithNoPGM = Core_MDF_CCP_TestDataUtility.createIntelAccount ('UserGroupMapping NO PGM Intel Account',Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, true);
            

            Account coMarketingAccount = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('UserGroupMapping Co-Marketing Account', cp1.id, Core_MDF_CCP_TestDataUtility.Account_Record_Type,intacc.id, false);
            coMarketingAccount.Core_MDF_CoMarketing_Ultimate_Account__c = intacc.id;
            Database.insert(coMarketingAccount);
            
            Contact ccfdcfContact = new Contact(Salutation = 'Mr',FirstName = 'Test',LastName='Contact',Email='testcontact'+String.valueOf(Math.random())+'@CoreMDF.com',AccountId=intacc.Id,Phone='123456798',Core_Audience_List__c='CCF User;DCF User');              
            Database.insert(ccfdcfContact);

            Profile partnerProfile = [SELECT Id FROM Profile WHERE Name='Partner' LIMIT 1];
            User ccfdcfUser = new User(Alias = String.valueOf(datetime.now()).substring(0,8), Email='testUsercoreMDF@intel.com',
                                 	EmailEncodingKey='UTF-8', LastName='User'+String.valueOf(date.today()), LanguageLocaleKey='en_US',
                                 	LocaleSidKey='en_US', ProfileId = partnerProfile.Id, ContactId = ccfdcfContact.Id,
                                 	TimeZoneSidKey='America/Los_Angeles', UserName='testUser'+String.valueOf(Math.random())+'@CoreMDF.com',
                                    FirstName='Test',isActive=true);

            Database.insert(ccfdcfUser);
                                            
            List<Group> groupList = new List<Group>();
            Group ccfgrp1 = new Group();
            ccfgrp1.Name = 'Core CCP CCF External';
            ccfgrp1.DeveloperName = 'Core_MDF_CCP_CCF_External';
            groupList.add(ccfgrp1);
                        
            Group ccfgrp2 = new Group();
            ccfgrp2.Name = 'Core CCP DCF External';
            ccfgrp2.DeveloperName = 'Core_MDF_CCP_DCF_External';
            groupList.add(ccfgrp2);
                        
            Group ccfgrp3 = new Group();
            ccfgrp3.Name = 'Core Test CCP DCF External';
            ccfgrp3.DeveloperName = 'Core_MDF_CCP_Test_External';
            groupList.add(ccfgrp3);

            Database.insert(groupList);

            List<GroupMember> gmList = new List<GroupMember>();
            GroupMember ccfGrpMem1 = new GroupMember();
            ccfGrpMem1.UserOrGroupId = ccfdcfUser.Id;
            ccfGrpMem1.GroupId = ccfgrp1.Id;
            gmList.add(ccfGrpMem1);
                        
            GroupMember ccfGrpMem2 = new GroupMember();
            ccfGrpMem2.UserOrGroupId = ccfdcfUser.Id;
            ccfGrpMem2.GroupId = ccfgrp2.Id;
            gmList.add(ccfGrpMem2);

            Database.insert(gmList);
                        
            //Creating PGM record
            List<Core_MDF_Partner_Group_Mapping__c> pgmRecords = new List<Core_MDF_Partner_Group_Mapping__c>();
            
           	Core_MDF_Partner_Group_Mapping__c pgmRecord1 = new Core_MDF_Partner_Group_Mapping__c();
            pgmRecord1.Core_MDF_Account__c = intacc.Id;
            pgmRecord1.Core_MDF_Works_For__c = null;
            pgmRecord1.Core_MDF_Channel_Program__c = cp1.Id; 
            pgmRecord1.Core_MDF_Type_of_Access__c = 'External';
            pgmRecord1.Core_MDF_Group_Name__c = 'Core_MDF_CCP_CCF_External';
                        
            Core_MDF_Partner_Group_Mapping__c pgmRecord2 = new Core_MDF_Partner_Group_Mapping__c();
            pgmRecord2.Core_MDF_Account__c = intacc.Id;
            pgmRecord2.Core_MDF_Works_For__c = null;
            pgmRecord2.Core_MDF_Channel_Program__c = cp2.Id; 
            pgmRecord2.Core_MDF_Type_of_Access__c = 'External';
            pgmRecord2.Core_MDF_Group_Name__c = 'Core_MDF_CCP_DCF_External';
                        
            Core_MDF_Partner_Group_Mapping__c pgmRecord3 = new Core_MDF_Partner_Group_Mapping__c();
            pgmRecord3.Core_MDF_Account__c = intacc.Id;
            pgmRecord3.Core_MDF_Works_For__c = intacc.Id;
            pgmRecord3.Core_MDF_Channel_Program__c = cp1.Id; 
            pgmRecord3.Core_MDF_Type_of_Access__c = 'External';
            pgmRecord3.Core_MDF_Group_Name__c = 'Core_MDF_CCP_Test_External';                       
            
            pgmRecords.add(pgmRecord1);pgmRecords.add(pgmRecord2);pgmRecords.add(pgmRecord3);
            Database.insert(pgmRecords);           
        }   
    } 
}