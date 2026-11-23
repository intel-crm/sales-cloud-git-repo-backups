@IsTest(seeAllData=false)
public class Dummy_GeneralPurpose_UI_Utility_Test{
    @TestSetup
    static void createTestData(){
        User testUser = Core_MDF_CCP_TestDataUtility.createUser(true);        
        System.runAs(testUser){
            Test.startTest();
            List<ChannelProgram> cpList = new List<ChannelProgram>();
            ChannelProgram ccfCp = Core_MDF_CCP_TestDataUtility.createProgram ('Client Co-Marketing Fund','Client CoMarketing Fund', false);
            ChannelProgram dcfCp = Core_MDF_CCP_TestDataUtility.createProgram ('Data Center Co-Marketing Fund','Data Center CoMarketing Fund', false);
            cpList.add(ccfCp); cpList.add(dcfCp);
            Database.insert (cpList);
            Account ccpIntelAccount = Core_MDF_CCP_TestDataUtility.createIntelAccount('CCP Test Intel Account', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);  
            Database.insert(ccpIntelAccount);
            List<Account> accountList = new List<Account>();
            Account ccfacc = Core_MDF_CCP_TestDataUtility.createAccount ('Co-marketing CCF Test Account', 
                                                                         ccfCp.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            ccfacc.Core_MDF_Parent_Fund_Account__c = ccpIntelAccount.Id;
            accountList.add(ccfacc);
            Account dcfacc = Core_MDF_CCP_TestDataUtility.createAccount ('Co-marketing DCF Test Account', 
                                                                         dcfCp.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            dcfacc.Core_MDF_Parent_Fund_Account__c = ccpIntelAccount.Id;
            accountList.add(dcfacc);
            Database.insert(accountList);
            
            Group ccfgrp = new Group();
            ccfgrp.Name = 'CCP TESTACCTTEMP CCF EMEA INTERNAL';
            ccfgrp.DeveloperName = 'Core_MDF_CCP_TESTACCTTEMP_CCF_EMEA_INTERNAL';
            Database.insert(ccfgrp);
            
            Core_MDF_Partner_Group_Mapping__c ccfPgm = new Core_MDF_Partner_Group_Mapping__c();
            ccfPgm.Core_MDF_Account__c =ccpIntelAccount.Id;
            ccfPgm.Core_MDF_Group_Name__c = 'Core_MDF_CCP_TESTACCTTEMP_CCF_EMEA_INTERNAL';
            ccfPgm.Core_MDF_Type_of_Access__c = 'Internal';           
            ccfPgm.Core_MDF_Channel_Program__c = ccfCp.Id;
            ccfPgm.Core_MDF_Region_cd__c = 'EMEA';
            ccfPgm.Core_MDF_Source_Txt__c = 'Test';            
            Database.insert(ccfPgm);
            
            Profile ccpCoreProfile = [SELECT Id FROM Profile WHERE Name = 'CCP - Core Access'];
            
            PermissionSet ccfAccManagerPS = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_CCF_Acct_Mgr' LIMIT 1];
            PermissionSet dcfAccManagerPS = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_DCF_Acct_Mgr' LIMIT 1];
            
            List<User> userList = new List<User>();
            List<PermissionSetAssignment> permissionSetAssignmentList = new List<PermissionSetAssignment>();
            
            User dcfAccountManager = Core_MDF_CCP_TestDataUtility.createUser(false);
            dcfAccountManager.profileId = ccpCoreProfile.Id;
            dcfAccountManager.LastName = 'DCF Acc Manager';
            userList.add(dcfAccountManager);
            
            User ccfAccountManager = Core_MDF_CCP_TestDataUtility.createUser(false);
            ccfAccountManager.profileId = ccpCoreProfile.Id;
            ccfAccountManager.LastName = 'CCF Acc Manager';
            userList.add(ccfAccountManager);
            Database.insert(userList);
            
            PermissionSetAssignment psa1 = new PermissionSetAssignment(PermissionSetId = ccfAccManagerPS.Id, AssigneeId = ccfAccountManager.Id);
            permissionSetAssignmentList.add(psa1);
            
            PermissionSetAssignment psa2 = new PermissionSetAssignment(PermissionSetId = dcfAccManagerPS.Id, AssigneeId = dcfAccountManager.Id);
            permissionSetAssignmentList.add(psa2);
            
            Database.insert(permissionSetAssignmentList);
            
            Test.stopTest();
        }
    }
    @isTest
    public static void testGetIntelActivityOwners(){
        Account ccpIntelAccount = [SELECT Id FROM Account WHERE Name = 'CCP Test Intel Account'];
        Account ccfCoMarketingAccount=[select Id from Account where Name='Co-marketing CCF Test Account'];
        Account dcfCoMarketingAccount=[select Id from Account where Name='Co-marketing DCF Test Account'];
        
        User dcfAccManager= [select Id From User where LastName='DCF Acc Manager'];
        User ccfAccountManager =[select Id from User where LastName = 'CCF Acc Manager'];
        Test.startTest();        
        List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> iupgmList = new List<Core_MDF_Int_Users_Partner_Geo_Mapping__c>();
        Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm3 = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
        iupgm3.Core_MDF_Account_id__c = ccpIntelAccount.Id;
        iupgm3.Core_MDF_Program_nm__c = 'Client CoMarketing Fund';
        iupgm3.Core_MDF_Region_Sub_Region_nm__c = 'EMEA';
        iupgm3.Core_MDF_User_id__c = ccfAccountManager.Id;
        iupgm3.Core_MDF_All_Accounts_cd__c = 'No';
        iupgm3.Core_MDF_Role_nm__c='Core_MDF_CCP_Internal_CCF_Acct_Mgr';
        iupgmList.add(iupgm3);
        Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm4 = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
        iupgm4.Core_MDF_Account_id__c = ccpIntelAccount.Id;
        iupgm4.Core_MDF_Program_nm__c = 'Data Center CoMarketing Fund';
        iupgm4.Core_MDF_Region_Sub_Region_nm__c = 'EMEA';
        iupgm4.Core_MDF_User_id__c =dcfAccManager.Id;
        iupgm4.Core_MDF_Role_nm__c='Core_MDF_CCP_Internal_DCF_Acct_Mgr';
        iupgm4.Core_MDF_All_Accounts_cd__c = 'No';
        iupgmList.add(iupgm4);
        Database.insert(iupgmList);
        
        List<string> countryList=new List<string>();
        countryList.add('AFGHANISTAN');
        countryList.add('ALBANIA');
        countryList.add('AMERICAN SOMOA');
        
        Core_MDF_GeneralPurpose_UI_Utility.getIntelActivityOwners(dcfCoMarketingAccount.Id,'Data Center Co-Marketing Fund',countryList,'OEM CMP');
        Core_MDF_GeneralPurpose_UI_Utility.getIntelActivityOwners(ccfCoMarketingAccount.Id,'Client Co-Marketing Fund',countryList,'OEM CMP');
        Core_MDF_GeneralPurpose_UI_Utility.isApprover(dcfCoMarketingAccount.Id, 'Data Center Co-Marketing Fund', countryList,'OEM CMP', String.valueOf(dcfAccManager.Id));
        Test.stopTest(); 
    }
}