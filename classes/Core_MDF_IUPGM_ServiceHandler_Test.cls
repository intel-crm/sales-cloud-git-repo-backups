/****************************************************************************************************************************************
* Class Name        : Core_MDF_IUPGM_ServiceHandler_Test
* Created Date      : 07/29/2019
* Modification Log
* Developer            Date               Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture - VD       07/29/2019         Test Class for Core_MDF_IUPGM_ServiceHandler
*****************************************************************************************************************************************/
@isTest(SeeAllData=false)
public class Core_MDF_IUPGM_ServiceHandler_Test {
    @TestSetUp
    static void createTestData(){
        
        User testUser = Core_MDF_CCP_TestDataUtility.createUser(true);
        
        System.runAs(testUser){
            ChannelProgram ccfCp = Core_MDF_CCP_TestDataUtility.createProgram ('Client Co-Marketing Fund','Client CoMarketing Fund', true);
            ChannelProgram dcfCp = Core_MDF_CCP_TestDataUtility.createProgram ('Data Center Co-Marketing Fund','Data Center CoMarketing Fund', true);
            ChannelProgram retailCp = Core_MDF_CCP_TestDataUtility.createProgram ('Retail Marketing Funds','Retail Marketing Funds', true);
            
            Account flipkartTestAccount = Core_MDF_CCP_TestDataUtility.createIntelAccount('FlipkartTestAccount', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, true);
            Account myntraTestAccount = Core_MDF_CCP_TestDataUtility.createIntelAccount('MyntraTestAccount', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, true);
			Account retailTestAccount = Core_MDF_CCP_TestDataUtility.createIntelAccount('RetailTestAccount', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, true);
            
            Group ccfgrp = new Group();
            ccfgrp.Name = 'CCP FLIPKARTT CCF EMEA INTERNAL';
            ccfgrp.DeveloperName = 'Core_MDF_CCP_FLIPKARTT_CCF_EMEA_INTERNAL';
            Database.insert(ccfgrp);
            
            Core_MDF_Partner_Group_Mapping__c ccfPgm = new Core_MDF_Partner_Group_Mapping__c();
            ccfPgm.Core_MDF_Account__c = flipkartTestAccount.Id;
            ccfPgm.Core_MDF_Group_Name__c = 'Core_MDF_CCP_FLIPKARTT_CCF_EMEA_INTERNAL';
            ccfPgm.Core_MDF_Type_of_Access__c = 'Internal';
            ccfPgm.Core_MDF_Group_Id__c = ccfgrp.Id;
            ccfPgm.Core_MDF_Channel_Program__c = ccfCp.Id;
            ccfPgm.Core_MDF_Region_cd__c = 'EMEA';
            ccfPgm.Core_MDF_Source_Txt__c = 'Test';
            Database.insert(ccfPgm);
            
            Profile ccpCoreProfile = [SELECT Id FROM Profile WHERE Name = 'CCP - Core Access'];
            
            PermissionSet ccfAccManagerPS = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_CCF_Acct_Mgr' LIMIT 1];
            PermissionSet dcfAccManagerPS = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_DCF_Acct_Mgr' LIMIT 1];
			PermissionSet retailAccManagerPS = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_Retail_Account_Manager' LIMIT 1];
            
            List<User> userList = new List<User>();
            List<PermissionSetAssignment> permissionSetAssignmentList = new List<PermissionSetAssignment>();
            
            User retailAccountManager = Core_MDF_CCP_TestDataUtility.createUser(false);
            retailAccountManager.profileId = ccpCoreProfile.Id;
            retailAccountManager.LastName = 'Retail Acc Manager';
            userList.add(retailAccountManager);
            
            User dcfAccountManager = Core_MDF_CCP_TestDataUtility.createUser(false);
            dcfAccountManager.profileId = ccpCoreProfile.Id;
            dcfAccountManager.LastName = 'DCF Acc Manager';
            userList.add(dcfAccountManager);
            
            User ccfAccountManager = Core_MDF_CCP_TestDataUtility.createUser(false);
            ccfAccountManager.profileId = ccpCoreProfile.Id;
            ccfAccountManager.LastName = 'CCF Acc Manager';
            userList.add(ccfAccountManager);
            
            User ccfAccManager = Core_MDF_CCP_TestDataUtility.createUser(false);
            ccfAccManager.profileId = ccpCoreProfile.Id;
            ccfAccManager.LastName = 'CCF Account Manager';
            userList.add(ccfAccManager);
            
            User accountManager = Core_MDF_CCP_TestDataUtility.createUser(false);
            AccountManager.profileId = ccpCoreProfile.Id;
            AccountManager.LastName = 'CCF DCF Acc Manager';
            userList.add(AccountManager);
            
            insert userList;
            
            PermissionSetAssignment psa1 = new PermissionSetAssignment(PermissionSetId = ccfAccManagerPS.Id, AssigneeId = ccfAccountManager.Id);
            permissionSetAssignmentList.add(psa1);
            
            PermissionSetAssignment psa2 = new PermissionSetAssignment(PermissionSetId = dcfAccManagerPS.Id, AssigneeId = dcfAccountManager.Id);
            permissionSetAssignmentList.add(psa2);
            
            PermissionSetAssignment psa3 = new PermissionSetAssignment(PermissionSetId = dcfAccManagerPS.Id, AssigneeId = accountManager.Id);
            permissionSetAssignmentList.add(psa3);
            
            PermissionSetAssignment psa4 = new PermissionSetAssignment(PermissionSetId = ccfAccManagerPS.Id, AssigneeId = accountManager.Id);
            permissionSetAssignmentList.add(psa4);
            
            PermissionSetAssignment psa5 = new PermissionSetAssignment(PermissionSetId = ccfAccManagerPS.Id, AssigneeId = ccfAccManager.Id);
            permissionSetAssignmentList.add(psa5);
            
            PermissionSetAssignment psa6 = new PermissionSetAssignment(PermissionSetId = retailAccManagerPS.Id, AssigneeId = retailAccountManager.Id);
            permissionSetAssignmentList.add(psa6);
            
            insert permissionSetAssignmentList;
        }
    }
    
    @isTest
    static void pgmExists(){
        Account acc = [SELECT Id FROM Account WHERE Name = 'FlipkartTestAccount'];
        
        ChannelProgram cp = [SELECT Id FROM ChannelProgram WHERE Name = 'Client Co-Marketing Fund'];
        
        User user = [SELECT Id FROM User WHERE LastName = 'CCF Acc Manager'];
        User ccfDcfuser = [SELECT Id FROM User WHERE LastName = 'CCF DCF Acc Manager'];
        
        Group groupId = [SELECT Id FROM Group WHERE DeveloperName = 'Core_MDF_CCP_FLIPKARTT_CCF_EMEA_INTERNAL'];
        
        List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> iupgmList = new List<Core_MDF_Int_Users_Partner_Geo_Mapping__c>();
        
        test.startTest();
        Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
        iupgm.Core_MDF_Account_id__c = acc.Id;
        iupgm.Core_MDF_Program_nm__c = 'Client CoMarketing Fund';
        iupgm.Core_MDF_Region_Sub_Region_nm__c = 'EMEA';
        iupgm.Core_MDF_User_id__c = user.Id;
        iupgm.Core_MDF_Role_nm__c = 'Core_MDF_CCP_Internal_CCF_Acct_Mgr';
        iupgmList.add(iupgm);
        
        Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm2 = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
        iupgm2.Core_MDF_Account_id__c = acc.Id;
        iupgm2.Core_MDF_Program_nm__c = 'Client CoMarketing Fund';
        iupgm2.Core_MDF_Region_Sub_Region_nm__c = 'EMEA';
        iupgm2.Core_MDF_User_id__c = ccfDcfuser.Id;
        iupgm2.Core_MDF_Role_nm__c = 'Core_MDF_CCP_Internal_CCF_Acct_Mgr';
        iupgmList.add(iupgm2);
        
        insert iupgmList;
        test.stopTest();
        
        GroupMember newGM = [SELECT Id, GroupId, UserOrGroupId FROM GroupMember WHERE GroupId =: groupId.Id AND UserOrGroupId =: user.Id];
        System.assert(newGM != NULL); 
    }
    
    @isTest
    static void pgmIsAbsent(){
        Account acc = [SELECT Id FROM Account WHERE Name = 'MyntraTestAccount'];
        
        ChannelProgram cp = [SELECT Id FROM ChannelProgram WHERE Name = 'Data Center Co-Marketing Fund'];
        
        User user = [SELECT Id FROM User WHERE LastName = 'DCF Acc Manager'];
        
        Group dcfgrp = new Group();
        dcfgrp.Name = 'CCP MYNTRATES DCF ASMO INTERNAL';
        dcfgrp.DeveloperName = 'Core_MDF_CCP_MYNTRATES_DCF_ASMO_INTERNAL';
        Database.insert(dcfgrp);
        
        test.startTest();
        Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
        iupgm.Core_MDF_Account_id__c = acc.Id;
        iupgm.Core_MDF_Program_nm__c = 'Data Center CoMarketing Fund';
        iupgm.Core_MDF_Region_Sub_Region_nm__c = 'ASMO';
        iupgm.Core_MDF_User_id__c = user.Id;
        iupgm.Core_MDF_Role_nm__c = 'Core_MDF_CCP_Internal_DCF_Acct_Mgr';
        insert iupgm;
        test.stopTest();
        
        GroupMember newGM = [SELECT Id, GroupId, UserOrGroupId FROM GroupMember WHERE UserOrGroupId =: user.Id LIMIT 1];
        System.assert(newGM != NULL);
        
        Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgmUpdated = [SELECT Id, Core_MDF_Active_Ind__c 
                                                                        FROM Core_MDF_Int_Users_Partner_Geo_Mapping__c 
                                                                        WHERE Core_MDF_Account_id__c =: acc.Id];
        
        iupgmUpdated.Core_MDF_Active_Ind__c = false;
        update iupgmUpdated;
    }
    
   @isTest
    static void iupgmWithSubRegion(){

        Account retailAcc = [SELECT Id FROM Account WHERE Name = 'RetailTestAccount'];
        
        ChannelProgram retailCp = [SELECT Id FROM ChannelProgram WHERE Name = 'Retail Marketing Funds'];
            
        User retailUser = [SELECT Id FROM User WHERE LastName = 'Retail Acc Manager'];
        
        Test.startTest();
        Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
        iupgm.Core_MDF_Account_id__c = retailAcc.Id;
        iupgm.Core_MDF_User_id__c = retailUser.Id;
        iupgm.Core_MDF_Program_nm__c = 'Retail Marketing Funds';
        iupgm.Core_MDF_Region_Sub_Region_nm__c = 'ASMO-LAR';
        iupgm.Core_MDF_Role_nm__c = 'Core_MDF_CCP_Internal_Retail_Account_Manager';
        insert iupgm;
        Test.stopTest();
        
        List<Core_MDF_Partner_Group_Mapping__c> pgm = [SELECT Id 
                                                       FROM Core_MDF_Partner_Group_Mapping__c 
                                                       WHERE Core_MDF_Account__c =: retailAcc.Id AND
                                                       Core_MDF_Channel_Program__c =: retailCp.Id AND
                                                       Core_MDF_Region_cd__c = 'ASMO' AND
													   Core_MDF_Sub_Region_cd__c = 'LAR'];
        System.assert(pgm != NULL);     
    }
    
    @isTest
    static void activateIUPGM(){
        Account acc = [SELECT Id FROM Account WHERE Name = 'FlipkartTestAccount'];
        
        ChannelProgram cp = [SELECT Id FROM ChannelProgram WHERE Name = 'Client Co-Marketing Fund'];
        
        User user = [SELECT Id FROM User WHERE LastName = 'CCF Acc Manager'];
        
        Group groupId = [SELECT Id FROM Group WHERE DeveloperName = 'Core_MDF_CCP_FLIPKARTT_CCF_EMEA_INTERNAL'];
        test.startTest();
        Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
        iupgm.Core_MDF_Account_id__c = acc.Id;
        iupgm.Core_MDF_Program_nm__c = 'Client CoMarketing Fund';
        iupgm.Core_MDF_Region_Sub_Region_nm__c = 'EMEA';
        iupgm.Core_MDF_User_id__c = user.Id;
        iupgm.Core_MDF_Role_nm__c = 'Core_MDF_CCP_Internal_CCF_Acct_Mgr';
        insert iupgm;
        test.stopTest();
        
        Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgmInactive = [SELECT Id,Core_MDF_Active_Ind__c
                                                                   FROM Core_MDF_Int_Users_Partner_Geo_Mapping__c 
                                                                WHERE Core_MDF_Program_nm__c = 'Client CoMarketing Fund'];
        iupgmInactive.Core_MDF_Active_Ind__c = FALSE;
        update iupgmInactive;
        
        Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgmActive = [SELECT Id,Core_MDF_Active_Ind__c
                                                                   FROM Core_MDF_Int_Users_Partner_Geo_Mapping__c 
                                                                   WHERE Core_MDF_Program_nm__c = 'Client CoMarketing Fund'];
        iupgmActive.Core_MDF_Active_Ind__c = TRUE;
        update iupgmActive;
        
        GroupMember newGM = [SELECT Id, GroupId, UserOrGroupId 
                             FROM GroupMember 
                             WHERE GroupId =: groupId.Id AND UserOrGroupId =: user.Id];
        System.assert(newGM != NULL);
    } 
}