@isTest(SeeAllData=false)
public class Core_MDF_InactivateIUPGM_Test {
    @TestSetUp
    static void createTestData(){
        UserRole usRole = [SELECT Id, Name FROM UserRole where Name = 'Admin' LIMIT 50000];
        User testUser = Core_MDF_CCP_TestDataUtility.createUser(false);
        testUser.LastName = 'Sys Admin';
        testUser.UserRoleId = usRole.Id;
        insert testUser;
        
        System.runAs(testUser){
            ChannelProgram ccfCp = Core_MDF_CCP_TestDataUtility.createProgram ('Client Co-Marketing Fund','Client CoMarketing Fund', true);
            
            Account flipkartTestAccount = Core_MDF_CCP_TestDataUtility.createIntelAccount('FlipkartTestAccount', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, true);
            
            Profile ccpCoreProfile = [SELECT Id FROM Profile WHERE Name = 'CCP - Core Access'];
            
            PermissionSet ccfAccManagerPS = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_CCF_Acct_Mgr' LIMIT 1];
            
            List<User> userList = new List<User>();
            List<PermissionSetAssignment> permissionSetAssignmentList = new List<PermissionSetAssignment>();            
            
            User ccfAccountManager1 = Core_MDF_CCP_TestDataUtility.createUser(false);
            ccfAccountManager1.profileId = ccpCoreProfile.Id;
            ccfAccountManager1.LastName = 'CCF Acc Manager 1';
            ccfAccountManager1.UserPermissionsMarketingUser = true;          
            userList.add(ccfAccountManager1);
            
            User ccfAccountManager2 = Core_MDF_CCP_TestDataUtility.createUser(false);
            ccfAccountManager2.profileId = ccpCoreProfile.Id;
            ccfAccountManager2.LastName = 'CCF Acc Manager 2';            
            userList.add(ccfAccountManager2);
            
            User ccfAccountManager3 = Core_MDF_CCP_TestDataUtility.createUser(false);
            ccfAccountManager3.profileId = ccpCoreProfile.Id;
            ccfAccountManager3.LastName = 'CCF Acc Manager 3';            
            userList.add(ccfAccountManager3);
            
            User ccfAccountManager4 = Core_MDF_CCP_TestDataUtility.createUser(false);
            ccfAccountManager4.profileId = ccpCoreProfile.Id;
            ccfAccountManager4.LastName = 'CCF Acc Manager 4';            
            userList.add(ccfAccountManager4);
            
            User ccfAccountManager5 = Core_MDF_CCP_TestDataUtility.createUser(false);
            ccfAccountManager5.profileId = ccpCoreProfile.Id;
            ccfAccountManager5.LastName = 'CCF Acc Manager 5';            
            userList.add(ccfAccountManager5);
            
            insert userList;
            
            PermissionSetAssignment psa1 = new PermissionSetAssignment(PermissionSetId = ccfAccManagerPS.Id, AssigneeId = ccfAccountManager1.Id);
            permissionSetAssignmentList.add(psa1);
            
            PermissionSetAssignment psa2 = new PermissionSetAssignment(PermissionSetId = ccfAccManagerPS.Id, AssigneeId = ccfAccountManager2.Id);
            permissionSetAssignmentList.add(psa2);
            
            PermissionSetAssignment psa3 = new PermissionSetAssignment(PermissionSetId = ccfAccManagerPS.Id, AssigneeId = ccfAccountManager3.Id);
            permissionSetAssignmentList.add(psa3);
            
            PermissionSetAssignment psa4 = new PermissionSetAssignment(PermissionSetId = ccfAccManagerPS.Id, AssigneeId = ccfAccountManager4.Id);
            permissionSetAssignmentList.add(psa4);
            
            PermissionSetAssignment psa5 = new PermissionSetAssignment(PermissionSetId = ccfAccManagerPS.Id, AssigneeId = ccfAccountManager5.Id);
            permissionSetAssignmentList.add(psa5);
            
            database.insert(permissionSetAssignmentList);
            
            List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> iupgmList = new List<Core_MDF_Int_Users_Partner_Geo_Mapping__c>();
            
            Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgmEMEA = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
            iupgmEMEA.Core_MDF_Account_id__c = flipkartTestAccount.Id;
            iupgmEMEA.Core_MDF_Program_nm__c = 'Client CoMarketing Fund';
            iupgmEMEA.Core_MDF_Region_Sub_Region_nm__c = 'EMEA;APJ';
            iupgmEMEA.Core_MDF_User_id__c = ccfAccountManager1.Id;
            iupgmEMEA.Core_MDF_Role_nm__c = 'Core_MDF_CCP_Internal_CCF_Acct_Mgr';
            iupgmEMEA.Core_MDF_All_Accounts_cd__c = 'No';
            iupgmList.add(iupgmEMEA);
            
            Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgmASMO = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
            iupgmASMO.Core_MDF_Account_id__c = flipkartTestAccount.Id;
            iupgmASMO.Core_MDF_Program_nm__c = 'Client CoMarketing Fund';
            iupgmASMO.Core_MDF_Region_Sub_Region_nm__c = 'ASMO';
            iupgmASMO.Core_MDF_User_id__c = ccfAccountManager2.Id;
            iupgmASMO.Core_MDF_Role_nm__c = 'Core_MDF_CCP_Internal_CCF_Acct_Mgr';
            iupgmASMO.Core_MDF_All_Accounts_cd__c = 'No';
            iupgmList.add(iupgmASMO);
            
            Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgmAPJ = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
            iupgmAPJ.Core_MDF_Account_id__c = flipkartTestAccount.Id;
            iupgmAPJ.Core_MDF_Program_nm__c = 'Client CoMarketing Fund';
            iupgmAPJ.Core_MDF_Region_Sub_Region_nm__c = 'WW';
            iupgmAPJ.Core_MDF_User_id__c = ccfAccountManager3.Id;
            iupgmAPJ.Core_MDF_Role_nm__c = 'Core_MDF_CCP_Internal_CCF_Acct_Mgr';
            iupgmAPJ.Core_MDF_All_Accounts_cd__c = 'No';
            iupgmList.add(iupgmAPJ);
            
            Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgmWW = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
            iupgmWW.Core_MDF_Account_id__c = flipkartTestAccount.Id;
            iupgmWW.Core_MDF_Program_nm__c = 'Client CoMarketing Fund';
            iupgmWW.Core_MDF_Region_Sub_Region_nm__c = 'PRC';
            iupgmWW.Core_MDF_User_id__c = ccfAccountManager4.Id;
            iupgmWW.Core_MDF_Role_nm__c = 'Core_MDF_CCP_Internal_CCF_Acct_Mgr';
            iupgmWW.Core_MDF_All_Accounts_cd__c = 'No';
            iupgmList.add(iupgmWW);
            
            Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgmPRC = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
            iupgmPRC.Core_MDF_Account_id__c = flipkartTestAccount.Id;
            iupgmPRC.Core_MDF_Program_nm__c = 'Client CoMarketing Fund';
            iupgmPRC.Core_MDF_Region_Sub_Region_nm__c = 'PRC;EMEA';
            iupgmPRC.Core_MDF_User_id__c = ccfAccountManager5.Id;
            iupgmPRC.Core_MDF_Role_nm__c = 'Core_MDF_CCP_Internal_CCF_Acct_Mgr';
            iupgmPRC.Core_MDF_All_Accounts_cd__c = 'No';
            iupgmList.add(iupgmPRC);
            
            test.startTest();
            insert iupgmList;
            test.stopTest();
        }
    }
    
    @isTest
    static void inactiveIUPGM(){
        
        User testUser = [SELECT Id FROM User WHERE LastName = 'Sys Admin'];
        Account acc = [SELECT Id FROM Account WHERE Name = 'FlipkartTestAccount'];
        
        System.runAs(testUser){          
            
            //ChannelProgram cp = [SELECT Id FROM ChannelProgram WHERE Name = 'Client Co-Marketing Fund'];
            
            List<User> inactiveUserList = new List<User>();
            
            for(User usr : [SELECT Id, IsActive, LastName FROM User WHERE LastName LIKE 'CCF Acc Manager%' LIMIT 5]){
                usr.IsActive = FALSE;
                inactiveUserList.add(usr);
            }        
            update inactiveUserList;
        }
        
        Test.startTest();
        
        Core_MDF_InactivateIUPGM inactivateBatch = new Core_MDF_InactivateIUPGM();
        Id batchId = DataBase.executeBatch(inactivateBatch); 
        Test.stopTest();
        
        Core_MDF_Int_Users_Partner_Geo_Mapping__c inactivePRC = [SELECT Core_MDF_Active_Ind__c, Core_MDF_Region_cd__c, Core_MDF_is_User_Active_ind__c
                                                                 FROM Core_MDF_Int_Users_Partner_Geo_Mapping__c
                                                                 WHERE Core_MDF_Account_id__c =: acc.Id AND
                                                                 Core_MDF_Region_Sub_Region_nm__c = 'PRC;EMEA' LIMIT 1];
        System.assertEquals(FALSE, inactivePRC.Core_MDF_Active_Ind__c);
        
        
    }
}