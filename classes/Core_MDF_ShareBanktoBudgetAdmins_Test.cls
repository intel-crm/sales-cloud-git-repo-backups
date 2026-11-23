@isTest(SeeAllData = false)
//Test class for Batch job Core_MDF_ShareBankWithUser
private class Core_MDF_ShareBanktoBudgetAdmins_Test {
    
    @isTest
    //This method creates all the records that meets criterion to test whether Bank is shared with Users
    static void testShareBanktoBudgetAdmins(){
        //Role
        UserRole usRole = [SELECT Id,Name FROM UserRole 
                           WHERE Name = 'Admin' LIMIT 1];
        
        // Creating User with utility class 
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        //usr.profileId = itAdminProfile.Id;
        usr.UserRoleId = usRole.Id;
        insert usr;
        
        System.runAs(usr){
            
            // Creating Intel Recordtype Account with utility class
            Account acc = Core_MDF_CCP_TestDataUtility.createIntelAccount('Test Account', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, true);
            
            //Creating Contact with utility class
            Test.startTest();
            Contact testContact = Core_MDF_CCP_TestDataUtility.createContact(acc.Id,true);
            Contact testContact1 = Core_MDF_CCP_TestDataUtility.createContact(acc.Id,true);
            Contact testContact2 = Core_MDF_CCP_TestDataUtility.createContact(acc.Id,true);
            Test.stopTest();
            
            //Partner profile
            Profile partnerProfile = [SELECT Id FROM Profile WHERE Name='Partner' LIMIT 1];
            
            //Inserting user with same contact Id
            User testUser = Core_MDF_CCP_TestDataUtility.createUser(false);
            testUser.ContactId = testContact.Id;
            testUser.ProfileId = partnerProfile.Id;
            testUser.portalRole = 'Manager';
            insert  testUser;
            
            //Inserting user1
            User testUser1 = Core_MDF_CCP_TestDataUtility.createUser(false);
            testUser1.ContactId = testContact1.Id;
            testUser1.ProfileId = partnerProfile.Id;
            testUser1.portalRole = 'Executive';
            insert  testUser1;
            
            //Inserting user2 : Areefa
            User testUser2 = Core_MDF_CCP_TestDataUtility.createUser(false);
            testUser2.ContactId = testContact2.Id;
            testUser2.ProfileId = partnerProfile.Id;
            testUser2.portalRole = 'Manager';
            insert  testUser2;
            
            //PermissionSet
            List<PermissionSet> permissionSetList = [SELECT Id from PermissionSet
                                                     WHERE PermissionSet.Name = 'Core_MDF_CCP_External_Account_Budget_Administrator'
                                                     LIMIT 1];
            
            List<PermissionSetAssignment> psaList = new List<PermissionSetAssignment>();
            //Assigning PermissionSet to User
            /*for(PermissionSet pset:permissionSetList){
                psaList.add(Core_MDF_CCP_TestDataUtility.createPermissionSetAssignment(testUser.Id,pset.Id,false));  
                //psaList.add(Core_MDF_CCP_TestDataUtility.createPermissionSetAssignment(testUser2.Id,pset.Id,false));  //Areefa: Assigner permission for TestUser2
            }*/
            Core_MDF_CCP_TestDataUtility.createPermissionSetAssignment(testUser.Id,permissionSetList[0].Id,true); 
            Core_MDF_CCP_TestDataUtility.createPermissionSetAssignment(testUser1.Id,permissionSetList[0].Id,true); 
            Core_MDF_CCP_TestDataUtility.createPermissionSetAssignment(testUser2.Id,permissionSetList[0].Id,true); 
            //insert psaList;
            
            // Creating channel program with utility class
            ChannelProgram cp = Core_MDF_CCP_TestDataUtility.createProgram ('Client Co-Marketing Fund','Client CoMarketing Fund', true);
            ChannelProgram cp1 = Core_MDF_CCP_TestDataUtility.createProgram ('Data Center Co-Marketing Fund','Data Center CoMarketing Fund', true);
            ChannelProgram cp2 = Core_MDF_CCP_TestDataUtility.createProgram ('Service Provider Co-Marketing Fund','Service Provider CoMarketing Fund', true); // Areefa
            
            //Create Group
            List<Group> groupList = new List<Group>();
            Group grp = new Group();
            grp.Name = 'Test';
            grp.Type = 'Regular'; 
            groupList.add(grp);
            
            Group grp1 = new Group();
            grp1.Name = 'Test1';
            grp1.Type = 'Regular'; 
            groupList.add(grp1);
            
            Group grp2 = new Group();
            grp2.Name = 'Test2';
            grp2.Type = 'Regular'; 
            groupList.add(grp2); 
            
            Group grp3 = new Group();
            grp3.Name = 'Test3';
            grp3.Type = 'Regular'; 
            groupList.add(grp3); 
            
            insert groupList;
            
            //Create Group Member
            List<GroupMember> groupMemberList = new List<GroupMember>();
            GroupMember grpMem = new GroupMember();
            grpMem.UserOrGroupId = testUser.Id;
            grpMem.GroupId = grp.Id;
            groupMemberList.add(grpMem);
            
            //Create Group Member
            GroupMember grpMem1 = new GroupMember();
            grpMem1.UserOrGroupId = testUser1.Id;
            grpMem1.GroupId = grp1.Id;
            groupMemberList.add(grpMem1);
 			
            //Create Group Member
            GroupMember grpMem2 = new GroupMember();
            grpMem2.UserOrGroupId = testUser2.Id;
            grpMem2.GroupId = grp2.Id;
            groupMemberList.add(grpMem2);
            
            //Create Group Member
            GroupMember grpMem3 = new GroupMember();
            grpMem3.UserOrGroupId = testUser2.Id;
            grpMem3.GroupId = grp3.Id;
            groupMemberList.add(grpMem3);
            
            insert groupMemberList;
            
            //Creating CCF1 Partner Group Mapping		
            Core_MDF_Partner_Group_Mapping__c pgm = new Core_MDF_Partner_Group_Mapping__c();
            pgm.Core_MDF_Account__c = acc.Id;
            pgm.Core_MDF_Type_of_Access__c = 'External';
            pgm.Core_MDF_Channel_Program__c = cp.Id;
            pgm.Core_MDF_Group_Name__c = grp3.Name;
            insert pgm;
            
            pgm.Core_MDF_Group_Id__c = grp3.Id;
            
            update pgm;
            
              //Creating DCF Partner Group Mapping		
            Core_MDF_Partner_Group_Mapping__c pgmccf2 = new Core_MDF_Partner_Group_Mapping__c();
            pgmccf2.Core_MDF_Account__c = acc.Id;
            pgmccf2.Core_MDF_Type_of_Access__c = 'External';
            pgmccf2.Core_MDF_Channel_Program__c = cp1.Id;
            pgmccf2.Core_MDF_Group_Name__c = grp.Name;
            insert pgmccf2;
            
            pgmccf2.Core_MDF_Group_Id__c = grp.Id;
            
            update pgmccf2;
            
            //Creating DCF PGM		
            Core_MDF_Partner_Group_Mapping__c pgm1 = new Core_MDF_Partner_Group_Mapping__c();
            pgm1.Core_MDF_Account__c = acc.Id;
            pgm1.Core_MDF_Type_of_Access__c = 'External';
            pgm1.Core_MDF_Channel_Program__c = cp1.Id;
            pgm1.Core_MDF_Group_Name__c = grp1.Name;
            insert pgm1;
            
            pgm1.Core_MDF_Group_Id__c = grp1.Id;
            
            update pgm1;
            
            //Areefa Creating SPCF PGM		
            Core_MDF_Partner_Group_Mapping__c pgm2 = new Core_MDF_Partner_Group_Mapping__c();
            pgm2.Core_MDF_Account__c = acc.Id;
            pgm2.Core_MDF_Type_of_Access__c = 'External';
            pgm2.Core_MDF_Channel_Program__c = cp2.Id;
            pgm2.Core_MDF_Group_Name__c = grp2.Name;
            insert pgm2;
            pgm2.Core_MDF_Group_Id__c = grp2.Id;
            update pgm2;
            
            // Creating Bank with utility class
            List<Core_MDF_Bank__c> bankList = new List<Core_MDF_Bank__c>();
            bankList.add(Core_MDF_CCP_TestDataUtility.createBank(acc.Id,NULL,false,'3847664738'));
            bankList.add(Core_MDF_CCP_TestDataUtility.createBank(acc.Id,NULL,false,'4587552155'));
            bankList.add(Core_MDF_CCP_TestDataUtility.createBank(acc.Id,NULL,false,'4557552255')); // Areefa
            bankList[0].Core_MDF_Program__c = 'Core_MDF_Client_CoMarketing_Fund';
            bankList[1].Core_MDF_Program__c = Label.Core_MDF_DCF_Program;
            bankList[2].Core_MDF_Program__c = Label.Core_MDF_SPCF_Program;
            insert bankList;
            
            //Creating Bank Share record
            Core_MDF_Bank__Share bankShare = new Core_MDF_Bank__Share();
            bankShare.ParentId = bankList[0].Id;
            bankShare.UserOrGroupId = testUser1.Id; 
            bankShare.RowCause = Schema.Core_MDF_Bank__Share.RowCause.AccountBudgetAdmin__c;
            bankShare.AccessLevel = Label.Core_MDF_Read_Access;
            insert bankShare;
            
            //Test.startTest();
            
            Core_MDF_ShareBanktoBudgetAdmins obj = new Core_MDF_ShareBanktoBudgetAdmins();
            DataBase.executeBatch(obj); 
            
            //Test.stopTest();
            
            //Query on BankShare to find if record is shared with user or not
            List<Core_MDF_Bank__Share> bankShareRecords = [SELECT Id, ParentId, UserOrGroupId FROM Core_MDF_Bank__Share
                                                           WHERE ParentId =: bankList[0].Id AND
                                                                 UserOrGroupId =: testUser.Id AND
                                                           		 RowCause =: Schema.Core_MDF_Bank__Share.RowCause.AccountBudgetAdmin__c
                                                           LIMIT 1];
            
            if(bankShareRecords.size() > 0)
            	System.assert(bankShareRecords.size() > 0);
        }
    }
}