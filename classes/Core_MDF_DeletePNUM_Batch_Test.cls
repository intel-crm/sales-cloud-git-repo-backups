@isTest(SeeAllData = false)
private class Core_MDF_DeletePNUM_Batch_Test {
    @TestSetUp
    public static void createTestData(){
        UserRole adminRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.LastName = 'User Test';
        usr.UserRoleId = adminRole.Id;
        insert usr;
        
        System.runAs(usr){
            
            // Creating channel program with utility class
            ChannelProgram cp = Core_MDF_CCP_TestDataUtility.createProgram('Data Center Co-Marketing Fund', 'Data Center CoMarketing Fund', true);

            // Creating IntelAccount with utility class
            Account intAcc = Core_MDF_CCP_TestDataUtility.createIntelAccount('Test Account 1', 
                                                                              Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
            Database.insert(intAcc);
            
            // Creating Co-marketing Account with utility class
            Account dcfAcc = Core_MDF_CCP_TestDataUtility.createAccount('Co-marketing DCF Test Account', 
                                                                         cp.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            dcfAcc.Core_MDF_Parent_Fund_Account__c = intAcc.Id;
            dcfAcc.Core_MDF_CoMarketing_Ultimate_Account__c=intAcc.Id;
            Database.insert(dcfAcc);

            List<Contact> conList = new List<Contact>();
            // Creating Contact with utility class
            Contact con1 = Core_MDF_CCP_TestDataUtility.createContact(intAcc.Id, false);
            con1.RecordTypeId = Core_MDF_CCP_TestDataUtility.Intel_Contact_Record_Type;
            con1.Core_Audience_List__c = 'DCF User';
            conList.add(con1);
            
            Contact con2 = Core_MDF_CCP_TestDataUtility.createContact(intAcc.Id, false);
            con2.RecordTypeId = Core_MDF_CCP_TestDataUtility.Intel_Contact_Record_Type;
            con2.Core_Audience_List__c = 'DCF User';
            conList.add(con2);
            
            Contact con3 = Core_MDF_CCP_TestDataUtility.createContact(intAcc.Id, false);
            con3.RecordTypeId = Core_MDF_CCP_TestDataUtility.Intel_Contact_Record_Type;
            con3.Core_Audience_List__c = 'DCF User';
            conList.add(con3);            
            Database.insert(conList);
            
            Core_ERPM_Engagement__c cee=new Core_ERPM_Engagement__c(Name  ='DCF', Core_Engagement_Type__c='SEC',Core_IsActive__c=true,Core_Technical_Engagement_Code__c='DCF');
            insert cee;
            Core_Entitlement__c entitle = new Core_Entitlement__c (name ='DCF User', Core_Category__c='Consolidated Co-marketing Platform',Core_Sub_Category__c='Data Center Co-Marketing Fund (DCF)',Core_Help_Text__c='Help text',Core_ERPM_Engagement_Id__c=cee.id,Core_Display_Name__c='DCF User',Core_IsActive__c=true);
            insert entitle;
            //System.assert(true,entitle.Core_Category__c!= null);
            List<Core_Contact_Entitlement__c> contactEntList = new List<Core_Contact_Entitlement__c>();
            
            Core_Contact_Entitlement__c ce = new Core_Contact_Entitlement__c(Core_Contact_Id__c=con1.Id,
                                                                     Core_Entitlement_Id__c=entitle.id,
                                                                     Core_Selected__c=true);
            contactEntList.add(ce);         
                                                                     
            Core_Contact_Entitlement__c ce1 = new Core_Contact_Entitlement__c(Core_Contact_Id__c=con2.Id,
                                                                     Core_Entitlement_Id__c=entitle.id,
                                                                     Core_Selected__c=true);
            contactEntList.add(ce1);
            Core_Contact_Entitlement__c ce2 = new Core_Contact_Entitlement__c(Core_Contact_Id__c=con3.Id,
                                                                     Core_Entitlement_Id__c=entitle.id,
                                                                     Core_Selected__c=true);
            contactEntList.add(ce2);
                                                                     
            insert contactEntList; 
            Profile partnerProfile = [SELECT Id FROM Profile WHERE Name = 'Partner' LIMIT 50000];
            
            List<User> userList = new List<User>();
            // Creating User with utility class
            User usr1 = Core_MDF_CCP_TestDataUtility.createUser(false);
            usr1.LastName = 'User Test1';
            usr1.ProfileId = partnerProfile.Id;
            usr1.ContactId = con1.Id;
            usr1.isActive = true;
            userList.add(usr1);
            
            User usr2 = Core_MDF_CCP_TestDataUtility.createUser(false);
            usr2.LastName = 'User Test2';
            usr2.ProfileId = partnerProfile.Id;
            usr2.ContactId = con2.Id;
            usr2.isActive = true;
            userList.add(usr2);
            
            User usr3 = Core_MDF_CCP_TestDataUtility.createUser(false);
            usr3.LastName = 'User Test3';
            usr3.ProfileId = partnerProfile.Id;
            usr3.ContactId = con3.Id;
            usr3.isActive = true;
            userList.add(usr3);

            Database.insert(userList);
            
            // Creating Group
            Group dcfgrp = new Group();
            dcfgrp.Name = 'Core CCP DCF External';
            dcfgrp.DeveloperName = 'Core_CCP_DCF_External';
            Database.insert(dcfgrp);
            
            // Creating Partner Group Mapping
            Core_MDF_Partner_Group_Mapping__c pgm1 = new Core_MDF_Partner_Group_Mapping__c();
            pgm1.Core_MDF_Account__c = intAcc.Id;
            pgm1.Core_MDF_Group_Name__c = 'Core_CCP_DCF_External';
            pgm1.Core_MDF_Type_of_Access__c = 'External';
            pgm1.Core_MDF_Group_Id__c = dcfgrp.Id;
            pgm1.Core_MDF_Channel_Program__c = cp.Id;
            pgm1.Core_MDF_AccountIdGroupName__c = intacc.Id+'Core_CCP_DCF_External';
            Database.insert(pgm1);
            
            List<GroupMember> grpMemList = new List<GroupMember>();
            // Creating Group Member
            GroupMember dcfGrpMem1 = new GroupMember();
            dcfGrpMem1.UserOrGroupId = usr1.Id;
            dcfGrpMem1.GroupId = dcfgrp.Id;
            grpMemList.add(dcfGrpMem1);
            
            GroupMember dcfGrpMem2 = new GroupMember();
            dcfGrpMem2.UserOrGroupId = usr2.Id;
            dcfGrpMem2.GroupId = dcfgrp.Id;
            grpMemList.add(dcfGrpMem2);
            
            GroupMember dcfGrpMem3 = new GroupMember();
            dcfGrpMem3.UserOrGroupId = usr3.Id;
            dcfGrpMem3.GroupId = dcfgrp.Id;
            grpMemList.add(dcfGrpMem3);
            
            database.insert(grpMemList);
            
            // PNUM creation
            List<Core_MDF_Partner_Node_User_Mapping__c> pnumList = new List<Core_MDF_Partner_Node_User_Mapping__c>();
            Core_MDF_Partner_Node_User_Mapping__c pnum1 = Core_MDF_CCP_TestDataUtility.createPartnerNodeUserMapping(dcfAcc.Id,usr1.Id,false);
            Core_MDF_Partner_Node_User_Mapping__c pnum2 = Core_MDF_CCP_TestDataUtility.createPartnerNodeUserMapping(dcfAcc.Id,usr2.Id,false);
            Core_MDF_Partner_Node_User_Mapping__c pnum3 = Core_MDF_CCP_TestDataUtility.createPartnerNodeUserMapping(dcfAcc.Id,usr3.Id,false);
             pnumList.add(pnum1);pnumList.add(pnum2);pnumList.add(pnum3);
            insert pnumList;     
        }
    }
    
    @isTest static void testDeletePNUMBatch() {
        Test.startTest();
        User usr1 = [Select id from User where LastName = 'User Test' limit 1];
        system.runAs(usr1) {
            
        
        User usr = [Select id from User where LastName = 'User Test3' limit 1];
        usr.IsActive = false;
        Database.update(usr);
        
        // Check whether user is active or not
        system.assertEquals(usr.IsActive, false);
        
        Group grp = [Select Id from Group WHERE DeveloperName = 'Core_CCP_DCF_External' limit 1];
        GroupMember gmm = [select id from Groupmember where Groupid =:grp.id limit 1];
        delete gmm;
        Set<Id> grpIdSet = new  Set<Id>();
        grpIdSet.add(grp.Id);
        
        Core_MDF_DeletePNUM_Batch deletePnum = new Core_MDF_DeletePNUM_Batch(grpIdSet);
        DataBase.executeBatch(deletePnum);
        
        Test.stopTest();
        
        List<Core_MDF_Partner_Node_User_Mapping__c> pnumList =  [Select Id, Core_MDF_Account__c,Core_MDF_Account__r.Core_MDF_CoMarketing_Ultimate_Account__c, Core_MDF_User__c from Core_MDF_Partner_Node_User_Mapping__c];
        assert.areEqual(2, pnumList.Size());        
    }
    }
}