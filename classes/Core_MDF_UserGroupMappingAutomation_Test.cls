/************************************************************************************************************************************************************************************
* Class Name  : Core_MDF_UserGroupMappingAutomation_Test 
* Version     : 1.0 
* Created Date: 21-02-2019
* Modification Log :
* Developer                     Date                          Description
* --------------------------------------------------------------------------------------------------------------------------------------------------
* Intel - Narayani Perachi 		21-02-2019					  Test class for Core_MDF_UserGroupMappingAutomation
* Intel - NP (11630236)         22-10-2019                    Removed unwanted code
**************************************************************************************************************************************************************************************/
@isTest(SeeAllData=FALSE)
public class Core_MDF_UserGroupMappingAutomation_Test 
{
    public static List<Contact> contactRecords = new List<Contact>();
    public static List<Contact> contactRecordsWithNoUser = new List<Contact>();
	
    @isTest static void testUserGroupMappingAutomation()
    {
        
        //List<Contact> contactRecord = new List<Contact>();
		List<Contact> updateContactRecord = new List<Contact>();  
        
        List<User> partnerUserList = new List<User>();
        
        List<id> contactIds = new List<id>();
        Map<id,id> contactToUser = new Map<id,id>();
        
        
        Account intacc= [select id from Account where Name='Test Intel Account 345'];
        
        //Creating Contact 
        Contact contactRecord1 = [select id,Core_Audience_List__c from Contact limit 1];
        User contact1User =[select id from User where ContactId=: contactRecord1.id];
        Groupmember contact1GmRecord = [select id from Groupmember where UserOrGroupId=: contact1User.id];

        system.assertNotEquals(NULL,contact1GmRecord);

        Contact contactRecord2 = new Contact(Salutation = 'Mr',FirstName = 'Test',LastName='Contact',Email='testcontact'+String.valueOf(Math.random())+'@CoreMDF.com',AccountId=intacc.Id,Phone='123456798',Core_Audience_List__c='DCF User;CCF User');
        Contact contactRecord3 = new Contact(Salutation = 'Mr',FirstName = 'Test',LastName='Contact',Email='testcontact'+String.valueOf(Math.random())+'@CoreMDF.com',AccountId=intacc.Id,Phone='123456798',Core_Audience_List__c='SPCF User');
        Contact contactRecord4 = new Contact(Salutation = 'Mr',FirstName = 'Test',LastName='Contact',Email='testcontact'+String.valueOf(Math.random())+'@CoreMDF.com',AccountId=intacc.Id,Phone='123456798',Core_Audience_List__c=' ');
        Contact contactRecord5 = new Contact(Salutation = 'Mr',FirstName = 'Test',LastName='Contact',Email='testcontact'+String.valueOf(Math.random())+'@CoreMDF.com',AccountId=intacc.Id,Phone='123456798',Core_Audience_List__c='CCF User;DCF User;SPCF User');
        
        contactRecords.add(contactRecord2);contactRecords.add(contactRecord3);contactRecords.add(contactRecord4);contactRecords.add(contactRecord5);
        Database.insert(contactRecords);

        contactRecord2.Core_Audience_List__c='DCF User;';
        updateContactRecord.add(contactRecord2);
                        
        contactRecord1.Core_Audience_List__c = '';
        updateContactRecord.add(contactRecord1);
                  
        contactRecord4.Core_Audience_List__c = 'DCF User';
        updateContactRecord.add(contactRecord4);

        Database.update(updateContactRecord);
    }

    @TestSetup
    static void createTestData(){
        Profile sysAdminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator' LIMIT 1];
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        // Creating User with utility class 
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.profileId = sysAdminProfile.Id;
        usr.UserRoleId = portalRole.Id;
        Database.insert(usr);
        
        
        List<Core_Trigger_Executions__c> triggerExes = new List<Core_Trigger_Executions__c>();
        
        
        System.runAs(usr)
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
                                    
            //Put an entry in 'Trigger Executions' custom settings so the Contact trigger gets exectued
            Core_Trigger_Executions__c triggerExe2 = new Core_Trigger_Executions__c();
            triggerExe2.Name = 'ContactEmailChangeUpdate';
            triggerExe2.Core_Active__c = true;
            triggerExe2.Core_Class_Name__c = 'Core_Contact_EmailChange_Handler';
            triggerExe2.Core_Description__c = 'test description';
            triggerExe2.Core_Object__c = 'Contact';
            triggerExe2.Core_Trigger_Events__c = 'After Update';
            triggerExes.add(triggerExe2);
                                    
            //Put an entry in 'Trigger Executions' custom settings so the Contact trigger gets exectued
            Core_Trigger_Executions__c triggerExe3 = new Core_Trigger_Executions__c();
            triggerExe3.Name = 'ContactAccountChangeUpdate';
            triggerExe3.Core_Active__c = true;
            triggerExe3.Core_Class_Name__c = 'Core_Contact_AccountChange_Handler';
            triggerExe3.Core_Description__c = 'test description';
            triggerExe3.Core_Object__c = 'Contact';
            triggerExe3.Core_Trigger_Events__c = 'Before Update , After Update';
            triggerExes.add(triggerExe3);

                                    
            //Put an entry in 'Trigger Executions' custom settings so the Contact trigger gets exectued
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

            Database.insert(triggerExes);
                        
                        
       		// Creating channel program with utility class
            ChannelProgram cp1 = Core_MDF_CCP_TestDataUtility.createProgram ('Client Co-Marketing Fund','Client CoMarketing Fund', true);
            ChannelProgram cp2 = Core_MDF_CCP_TestDataUtility.createProgram ('Data Center Co-Marketing Fund','Data Center CoMarketing Fund', true);
                         
            // Creating IntelAccount with utility class
            Account intacc = Core_MDF_CCP_TestDataUtility.createIntelAccount ('Test Intel Account 345',Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
            intacc.Core_Account_Type__c = 'Reseller';
            intacc.Core_Sales_Groups__c = 'Automotive Sales Group';
            intacc.Industry = 'Food & Beverage';
            insert intacc;
                           
            Contact contactRecord1 = new Contact(Salutation = 'Mr',FirstName = 'Test',LastName='Contact',Email='testcontact'+String.valueOf(Math.random())+'@CoreMDF.com',AccountId=intacc.Id,Phone='123456798',Core_Audience_List__c='CCF User;SPCF User');              
            Database.insert(contactRecord1);       

            Profile partnerProfile = [SELECT Id FROM Profile WHERE Name='Partner' LIMIT 1];
            User partnerUser1 = new User(Alias = String.valueOf(datetime.now()).substring(0,8), Email='testUsercoreMDF@intel.com',
                                 	EmailEncodingKey='UTF-8', LastName='User'+String.valueOf(date.today()), LanguageLocaleKey='en_US',
                                 	LocaleSidKey='en_US', ProfileId = partnerProfile.Id, ContactId = contactRecord1.Id,
                                 	TimeZoneSidKey='America/Los_Angeles', UserName='testUser'+String.valueOf(Math.random())+'@CoreMDF.com',
                                    FirstName='Test',isActive=true);   

            Database.insert(partnerUser1);
                                            
            List<Group> groupList = new List<Group>();
            Group ccfgrp1 = new Group();
            ccfgrp1.Name = 'Core CCP CCF External';
            ccfgrp1.DeveloperName = 'Core_MDF_CCP_CCF_External1';
            groupList.add(ccfgrp1);
                        
            Group ccfgrp2 = new Group();
            ccfgrp2.Name = 'Core CCP DCF External';
            ccfgrp2.DeveloperName = 'Core_MDF_CCP_DCF_External';
            groupList.add(ccfgrp2);
                        
            Group ccfgrp3 = new Group();
            ccfgrp3.Name = 'Core Test CCP DCF External';
            ccfgrp3.DeveloperName = 'Core_MDF_CCP_Test_External';
            groupList.add(ccfgrp3);
                        
            Group ccfgrp4 = new Group();
            ccfgrp4.Name = 'Core Test CCP CCF External';
            ccfgrp4.DeveloperName = 'Core_MDF_CCP_CCF_External2';
            groupList.add(ccfgrp4);

            Database.insert(groupList);

            List<GroupMember> gmList = new List<GroupMember>();
            GroupMember ccfGrpMem1 = new GroupMember();
            ccfGrpMem1.UserOrGroupId = partnerUser1.Id;
            ccfGrpMem1.GroupId = ccfgrp1.Id;
            gmList.add(ccfGrpMem1);
                        
            GroupMember ccfGrpMem2 = new GroupMember();
            ccfGrpMem2.UserOrGroupId = partnerUser1.Id;
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
            pgmRecord1.Core_MDF_Group_Name__c = 'Core_MDF_CCP_CCF_External1';
                        
            Core_MDF_Partner_Group_Mapping__c pgmRecord2 = new Core_MDF_Partner_Group_Mapping__c();
            pgmRecord2.Core_MDF_Account__c = intacc.Id;
            pgmRecord2.Core_MDF_Works_For__c = intacc.Id;
            pgmRecord2.Core_MDF_Channel_Program__c = cp2.Id; 
            pgmRecord2.Core_MDF_Type_of_Access__c = 'External';
            pgmRecord2.Core_MDF_Group_Name__c = 'Core_MDF_CCP_DCF_External';
                        
            Core_MDF_Partner_Group_Mapping__c pgmRecord3 = new Core_MDF_Partner_Group_Mapping__c();
            pgmRecord3.Core_MDF_Account__c = intacc.Id;
            pgmRecord3.Core_MDF_Works_For__c = intacc.Id;
            pgmRecord3.Core_MDF_Channel_Program__c = cp1.Id; 
            pgmRecord3.Core_MDF_Type_of_Access__c = 'External';
            pgmRecord3.Core_MDF_Group_Name__c = 'Core_MDF_CCP_Test_External';
                        
            Core_MDF_Partner_Group_Mapping__c pgmRecord4 = new Core_MDF_Partner_Group_Mapping__c();
            pgmRecord4.Core_MDF_Account__c = intacc.Id;
            pgmRecord4.Core_MDF_Works_For__c = null;
            pgmRecord4.Core_MDF_Channel_Program__c = cp1.Id; 
            pgmRecord4.Core_MDF_Type_of_Access__c = 'External';
            pgmRecord4.Core_MDF_Group_Name__c = 'Core_MDF_CCP_CCF_External2';
                        
                        
            pgmRecords.add(pgmRecord1);pgmRecords.add(pgmRecord2);pgmRecords.add(pgmRecord3);pgmRecords.add(pgmRecord4);
            
            Database.insert(pgmRecords);                                          
                    
        } 

        
    } 
}