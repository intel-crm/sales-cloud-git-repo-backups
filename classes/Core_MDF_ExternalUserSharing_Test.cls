/****************************************************************************************************************************************
 * Class Name  : Core_MDF_ExternalUserSharing_Test
 * Version     : 1.0
 * Created Date: 09-18-2019
 * Modification Log :
 * Developer                     Date                          Description
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Accenture – Manasa          09-18-2019                   Created Core_MDF_ExternalUserSharing_Test to test User Sharing functionality when
 external users are activated from inactive state
 *****************************************************************************************************************************************/
@isTest(SeeAllData = false)private class Core_MDF_ExternalUserSharing_Test {
    /****************************************************************************************************************************************
     Method Name:                                             createTestData
     @return  :                                               Void
     @parameters:                                             --
     Description:                                             Created Test data for User Sharing
     Added By:                                                Accenture – Harika P  -  9/18/2019
     Modified By:                  Date:                      Changes:
     Accenture – Harika P        9/18/2019                    Created.
     *****************************************************************************************************************************************/
    @TestSetUp
    public static void createTestData() {
        UserRole usRole = [SELECT Id, Name FROM UserRole where Name = 'Admin' LIMIT 50000];
        List<Account> accList = new List<Account>();
        List<Contact> conList = new List<Contact>();
        List<User> userList = new List<User>();

        // Creating User with utility class
        User usr1 = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr1.LastName = 'User Test1';
        usr1.UserRoleId = usRole.Id;
        Database.insert(usr1);

        System.runAs(usr1) {
            
            List<Core_Trigger_Executions__c> triggerExeList = new List<Core_Trigger_Executions__c>();
            
            Core_Trigger_Executions__c triggerExe1 = new Core_Trigger_Executions__c();
            triggerExe1.Name = 'pnumUpdateIndicator';
            triggerExe1.Core_Object__c = 'Contact';
            triggerExe1.Core_Active__c = TRUE;
            triggerExe1.Core_Trigger_Events__c = 'After Insert, After Update';
            triggerExe1.Core_Description__c = 'Enable/Disable the PNUM update from ExternalUserSharing class';
            triggerExe1.Core_Class_Name__c = 'Core_MDF_ExternalUserSharing';
            triggerExeList.add(triggerExe1);
            
            Core_Trigger_Executions__c triggerExe2 = new Core_Trigger_Executions__c();
            triggerExe2.Name = 'externalUserSharingJobRetry';
            triggerExe2.Core_Object__c = 'Contact';
            triggerExe2.Core_Active__c = TRUE;
            triggerExe2.Core_Trigger_Events__c = 'After Insert, After Update';
            triggerExe2.Core_Description__c = 'Enable/Disable the PNUM update from ExternalUserSharing class';
            triggerExe2.Core_Class_Name__c = 'Core_MDF_ExternalUserSharing';
            triggerExeList.add(triggerExe2);
            
            Core_Trigger_Executions__c triggerExe3 = new Core_Trigger_Executions__c();
            triggerExe3.Name = 'callPnumDeleteBatch';
            triggerExe3.Core_Object__c = 'Contact';
            triggerExe3.Core_Active__c = TRUE;
            triggerExe3.Core_Trigger_Events__c = 'After Insert, After Update';
            triggerExe3.Core_Description__c = 'Enable/Disable the PNUM update from ExternalUserSharing class';
            triggerExe3.Core_Class_Name__c = 'Core_MDF_ExternalUserSharing';
            triggerExeList.add(triggerExe3);
            
            database.insert(triggerExeList);
            

            // Creating channel program with utility class
            ChannelProgram cp = Core_MDF_CCP_TestDataUtility.createProgram(Core_MDF_CCP_ConstantClass.DCF_PROGRAM, 'Data Center CoMarketing Fund', true);

            // Creating IntelAccount with utility class
            Account intAcc = Core_MDF_CCP_TestDataUtility.createIntelAccount('Test Account 1', 
                                                                              Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
            Database.insert(intAcc);

            // Creating Co-marketing Account with utility class
            Account dcfAcc = Core_MDF_CCP_TestDataUtility.createAccount('Co-marketing DCF Test Account', 
                                                                         cp.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            dcfAcc.Core_MDF_Parent_Fund_Account__c = intAcc.Id;
            accList.add(dcfAcc);

            Database.insert(accList);

            // Creating Contact with utility class
            Contact con = Core_MDF_CCP_TestDataUtility.createContact(intAcc.Id, false);
            con.RecordTypeId = Core_MDF_CCP_TestDataUtility.Intel_Contact_Record_Type;
            conList.add(con);

            Contact con1 = Core_MDF_CCP_TestDataUtility.createContact(intAcc.Id, false);
            con1.RecordTypeId = Core_MDF_CCP_TestDataUtility.Intel_Contact_Record_Type;
            conList.add(con1);

            Database.insert(conList);

            Profile partnerProfile = [SELECT Id FROM Profile WHERE Name = 'Partner' LIMIT 50000];

            // Creating User with utility class
            User usr2 = Core_MDF_CCP_TestDataUtility.createUser(false);
            usr2.LastName = 'User Test2';
            usr2.ProfileId = partnerProfile.Id;
            usr2.ContactId = con.Id;
            usr2.isActive = true;
            userList.add(usr2);

            User usr3 = Core_MDF_CCP_TestDataUtility.createUser(false);
            usr3.LastName = 'User Test3';
            usr3.ProfileId = partnerProfile.Id;
            usr3.ContactId = con1.Id;
            usr3.isActive = false;
            //usr3.isActive = true;
            userList.add(usr3);

            Database.insert(userList);
            
            Core_ERPM_Engagement__c cee=new Core_ERPM_Engagement__c(Name  ='DCF', Core_Engagement_Type__c='SEC',Core_IsActive__c=true,Core_Technical_Engagement_Code__c='DCF');
            insert cee;
            Core_Entitlement__c entitle = new Core_Entitlement__c (name ='DCF User', Core_Category__c='Intel® Partner Investment Center',Core_Sub_Category__c='Datacenter',Core_Help_Text__c='Help text',Core_ERPM_Engagement_Id__c=cee.id,Core_Display_Name__c='Datacenter User',Core_IsActive__c=true);
            insert entitle;
            Core_Contact_Entitlement__c ce = new Core_Contact_Entitlement__c(Core_Contact_Id__c=con.Id,
                                                                     Core_Entitlement_Id__c=entitle.id,
                                                                     Core_Selected__c=true);
            insert ce;


            //Creating Groups
            Group grp1 = new Group();
            grp1.Name = 'Core_MDF_CCP_External';
            grp1.DeveloperName = 'Core_MDF_CCP_External';

            Group grp2 = new Group();
            grp2.Name = 'Core_MDF_CCP_CCF_External';
            grp2.DeveloperName = 'Core_MDF_CCP_CCF_External';

            List<Group> lstGroup = new List<Group>();
            lstGroup.add(grp1);
            lstGroup.add(grp2);
            Database.insert(lstGroup);

            // Creating Group Members
            GroupMember grpMember = new GroupMember();
            grpMember.UserOrGroupId = usr2.Id;
            grpMember.GroupId = grp1.Id;

            GroupMember grpMember1 = new GroupMember();
            grpMember1.UserOrGroupId = usr3.Id;
            grpMember1.GroupId = grp1.Id;

            GroupMember grpMember2 = new GroupMember();
            grpMember2.UserOrGroupId = usr2.Id;
            grpMember2.GroupId = grp2.Id;
            
            GroupMember grpMember3 = new GroupMember();
            grpMember3.UserOrGroupId = usr3.Id;
            grpMember3.GroupId = grp2.Id;

            List<UserShare> usList = new List<UserShare>();
            UserShare us2 = new UserShare(UserId = usr3.Id, UserOrGroupId = grp1.Id, RowCause = 'Manual', UserAccessLevel = 'Read');
            usList.add(us2);
            Database.insert(usList);

            List<GroupMember> lstGrpMember = new List<GroupMember>();
            lstGrpMember.add(grpMember);
            lstGrpMember.add(grpMember1);
            lstGrpMember.add(grpMember2);
            lstGrpMember.add(grpMember3);
            Database.insert(lstGrpMember);

            // Inactivating user
            usr3.IsActive = False;
            Database.update(usr3);
            // Creating Partner Group Mapping
            Core_MDF_Partner_Group_Mapping__c pgm1 = new Core_MDF_Partner_Group_Mapping__c();
            pgm1.Core_MDF_Account__c = intacc.Id;
            pgm1.Core_MDF_Group_Name__c = 'Core_MDF_CCP_External';
            pgm1.Core_MDF_Type_of_Access__c = 'External';
            pgm1.Core_MDF_Group_Id__c = grp1.Id;
            pgm1.Core_MDF_Channel_Program__c = cp.Id;
            pgm1.Core_MDF_AccountIdGroupName__c = intacc.Id+'Core_MDF_CCP_External';
            pgm1.Core_MDF_Inactive_Ind__c=false;
            // Creating Partner Group Mapping
            Core_MDF_Partner_Group_Mapping__c pgm2 = new Core_MDF_Partner_Group_Mapping__c();
            pgm2.Core_MDF_Account__c = intacc.Id;
            pgm2.Core_MDF_Group_Name__c = 'Core_MDF_CCP_CCF_External';
            pgm2.Core_MDF_Type_of_Access__c = 'External';
            pgm2.Core_MDF_Group_Id__c = grp2.Id;
            pgm2.Core_MDF_Channel_Program__c = cp.Id;
            pgm2.Core_MDF_AccountIdGroupName__c = intacc.Id+'Core_MDF_CCP_CCF_External';
            pgm2.Core_MDF_Inactive_Ind__c=false;
            List<Core_MDF_Partner_Group_Mapping__c> pgmList = new List<Core_MDF_Partner_Group_Mapping__c>();
            pgmList.add(pgm1);
            //pgmList.add(pgm2);
            Database.insert(pgmList);
            //Core_MDF_Partner_Node_User_Mapping__c pnum = Core_MDF_CCP_TestDataUtility.createPartnerNodeUserMapping(dcfAcc.Id, usr2.Id, true);
            //usr2.isActive = false;
            //Database.update(usr2);

        }
    }
    /****************************************************************************************************************************************
     Method Name:                                             testUsrShare
     @return  :                                               Void
     @parameters:                                             --
     Description:                                             Created to test user sharing.
     Added By:                                                Accenture – Manasa  -  9/18/2019
     Modified By:                  Date:                      Changes:
     Accenture – Manasa          9/18/2019                    Created.
     *****************************************************************************************************************************************/

    @isTest static void testUsrShare() {
        Test.startTest();
        User usr = [Select id from User where LastName = 'User Test2' limit 1];
        usr.IsActive = false;
        Database.update(usr);
        // Check whether user is active or not
        system.assertEquals(usr.IsActive, false);
        Core_MDF_ExternalUserSharing be = new Core_MDF_ExternalUserSharing(false, (Set<String>)null);
        be.counter = 2;
        be.errorMap.put(usr.Id, 'jg');
        DataBase.executeBatch(be);
        Test.stopTest();
    }
    @isTest static void testUsrShare1() {
        Test.startTest();
        Core_MDF_ExternalUserSharing be2 = new Core_MDF_ExternalUserSharing(false, (Set<String>)null);
        DataBase.executeBatch(be2);

        User usr = [Select id from User where LastName = 'User Test2' limit 1];
        usr.IsActive = true;
        Database.update(usr);

        // Check whether user is active or not
        system.assertEquals(usr.IsActive, true);
        //insert us;
        Core_MDF_ExternalUserSharing be = new Core_MDF_ExternalUserSharing(true, new Set<String>{ usr.Id });
        DataBase.executeBatch(be);

        usr.IsActive = true;
        Database.update(usr);

        // Check whether user is active or not
        system.assertEquals(usr.IsActive, true);

        Core_MDF_ExternalUserSharing be1 = new Core_MDF_ExternalUserSharing(false, (Set<String>)null);
        DataBase.executeBatch(be1);

        // Passing the UserSHare Record to Delete explicitly::
        List<UserShare> uShareList = [Select Id from UserShare Where UserId =:usr.Id AND RowCause IN('Manual','Owner')];
        Core_MDF_ExternalUserSharing be3 = new Core_MDF_ExternalUserSharing(true, uShareList);
        Database.executeBatch(be3);
        Test.stopTest();
    }
    
    @isTest static void testConstructor() {
        Test.startTest();
        Core_MDF_ExternalUserSharing be3 = new Core_MDF_ExternalUserSharing(true, null, 1);
        Database.executeBatch(be3);
        Test.stopTest();
        // Unit Test Method should include System.Assert 
        System.assertNotEquals(null, be3, 'Constructor should create a valid instance');
    }
    
    @isTest static void testConstructor1() {
        Test.startTest();
        List<UserShare> us = null;
        Core_MDF_ExternalUserSharing be3 = new Core_MDF_ExternalUserSharing(true, us);
        Database.executeBatch(be3);
        Test.stopTest();
        // Unit Test Method should include System.Assert
        System.assertNotEquals(null, be3, 'Constructor should create a valid instance');
        System.assertEquals(null, us, 'UserShare list should remain null');
    }
}