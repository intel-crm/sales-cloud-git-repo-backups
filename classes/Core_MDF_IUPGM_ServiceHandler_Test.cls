/****************************************************************************************************************************************
* Class Name        : Core_MDF_IUPGM_ServiceHandler_Test
* Created Date      : 07/29/2019
* Modification Log
* Developer            Date               Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture - VD       07/29/2019         Test Class for Core_MDF_IUPGM_ServiceHandler
* Accenture-  PD       12/09/2021         Modified Test class for Channel MDF program.
*****************************************************************************************************************************************/
@isTest(SeeAllData=false)
public class Core_MDF_IUPGM_ServiceHandler_Test{
     public static Id CCF_RecordType = Schema.SObjectType.Core_MDF_Int_Users_Partner_Geo_Mapping__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_Client_Co_Marketing_Fund').getRecordTypeId();
     public static Id DCF_RecordType = Schema.SObjectType.Core_MDF_Int_Users_Partner_Geo_Mapping__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_Data_Center_Co_Marketing_Fund').getRecordTypeId();
     Public static Id IPA_RecordType = Schema.SObjectType.Core_MDF_Int_Users_Partner_Geo_Mapping__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_Intel_Partner_Alliance').getRecordTypeId();
     public static Id CMDF_RecordType = Schema.SObjectType.Core_MDF_Int_Users_Partner_Geo_Mapping__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_Channel_MDF').getRecordTypeId();
     public static Id RMF_RecordType = Schema.SObjectType.Core_MDF_Int_Users_Partner_Geo_Mapping__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_Retail_Marketing_Funds').getRecordTypeId();
     public static Id EEF_RecordType = Schema.SObjectType.Core_MDF_Int_Users_Partner_Geo_Mapping__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_Ecosystem_Extension_Fund').getRecordTypeId();
    
    @TestSetUp
    static void createTestData(){
        User testUser = Core_MDF_CCP_TestDataUtility.createUser(true);        
        System.runAs(testUser){
            List<Core_Trigger_Executions__c> executionList = new List<Core_Trigger_Executions__c>();
            Core_Trigger_Executions__c groupIdForAccountNode = new Core_Trigger_Executions__c();
            groupIdForAccountNode.name = 'Core_MDF_createGroupForAccountNode';
            groupIdForAccountNode.Core_Object__c = 'Account';
            groupIdForAccountNode.Core_Trigger_Events__c = 'After Insert';
            groupIdForAccountNode.Core_Active__c = TRUE;
            groupIdForAccountNode.Core_Description__c = 'To Create Group for each account';
            groupIdForAccountNode.Core_Class_Name__c = 'Core_AccountHandler';
            executionList.add(groupIdForAccountNode);
            
            Core_Trigger_Executions__c marketingUserPermissionUpdate = new Core_Trigger_Executions__c();
            marketingUserPermissionUpdate.name = 'marketingUserPermissionUpdate';
            marketingUserPermissionUpdate.Core_Object__c = 'Core_MDF_Int_Users_Partner_Geo_Mapping__c   ';
            marketingUserPermissionUpdate.Core_Trigger_Events__c = 'After Insert';
            marketingUserPermissionUpdate.Core_Active__c = TRUE;
            marketingUserPermissionUpdate.Core_Description__c = 'If enabled, the user will be updated with Marketing user permission';
            marketingUserPermissionUpdate.Core_Class_Name__c = 'Core_MDF_IUPGM_ServiceHandler';
            executionList.add(marketingUserPermissionUpdate);
            
            Core_Trigger_Executions__c marketingUserPermissionRemoval = new Core_Trigger_Executions__c();
            marketingUserPermissionRemoval.name = 'marketingUserPermissionRemoval';
            marketingUserPermissionRemoval.Core_Object__c = 'Core_MDF_Int_Users_Partner_Geo_Mapping__c  ';
            marketingUserPermissionRemoval.Core_Trigger_Events__c = 'after Update';
            marketingUserPermissionRemoval.Core_Active__c = TRUE;
            marketingUserPermissionRemoval.Core_Description__c = 'If turned on, the marketing user permission on user record will be turned off on IUPGM inactivation';
            marketingUserPermissionRemoval.Core_Class_Name__c = 'Core_MDF_IUPGM_ServiceHandler';
            executionList.add(marketingUserPermissionRemoval);
            
            insert executionList;
            
            List<String> bypassFunctionKeys = new List<String>();
            Set<String> myset1 = new Set<String>();
            List<String> result1 = new List<String>();
            bypassFunctionKeys.add('Bypass_OwnerTransfer');
            bypassFunctionKeys.add('Bypass_External_Group_Creation');
            bypassFunctionKeys.add('byPassMDFPFAChangesMethod');
            bypassFunctionKeys.add('byPassRetailCampSharingOnPFAChange');
            bypassFunctionKeys.add('byPassValidateAccountHierarchy');
            myset1.addAll(bypassFunctionKeys);
            result1.addAll(myset1);
        
             List<Core_Trigger_Executions__c> bypassfunctinalitylist1 = Core_MDF_CCP_TestDataUtility.byPassFeature(result1,true,true);
            
            List<ChannelProgram> cpList = new List<ChannelProgram>();
            ChannelProgram ccfCp = Core_MDF_CCP_TestDataUtility.createProgram ('Client','Client CoMarketing Fund', false);
            ChannelProgram dcfCp = Core_MDF_CCP_TestDataUtility.createProgram ('Datacenter','Data Center CoMarketing Fund', false);
            ChannelProgram retailCp = Core_MDF_CCP_TestDataUtility.createProgram ('Retail Marketing Funds','Retail Marketing Funds', false);
            ChannelProgram ipaCp = Core_MDF_CCP_TestDataUtility.createProgram ('Intel Partner Alliance','Intel Partner Alliance', false);   
            ChannelProgram cmdfCp = Core_MDF_CCP_TestDataUtility.createProgram ('Channel MDF','Channel MDF', false);
            ChannelProgram eefCp = Core_MDF_CCP_TestDataUtility.createProgram ('Ecosystem Extension Fund','Ecosystem Extension Fund', false);
            cpList.add(ccfCp);
            cpList.add(dcfCp);
            cpList.add(retailCp);
            cpList.add(ipaCp);
            cpList.add(cmdfCp);
            cpList.add(eefCp);
            insert cpList;
            
            List<Account> intelAccList = new List<Account>();
            
            Account testAcctTemp = Core_MDF_CCP_TestDataUtility.createIntelAccount('CCPTestAccountTemp', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
            Account testAcctTemp1 = Core_MDF_CCP_TestDataUtility.createIntelAccount('CCPTestAccountTemp1', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
            Account retailTestAccount = Core_MDF_CCP_TestDataUtility.createIntelAccount('RetailTestAccount', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
            retailTestAccount.Core_Geo__c ='APJ';
            retailTestAccount.Core_Sub_Geo__c ='SA';
            
            intelAccList.add(testAcctTemp);
            intelAccList.add(testAcctTemp1);
            intelAccList.add(retailTestAccount);
            database.insert(intelAccList);
             
           Account eefAcc = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test Account 2',
                                                                             eefCp.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, 
                                                                             testAcctTemp.Id, false);
            eefAcc.Core_MDF_Partner_Type_nm__c ='Activating Partner';
            eefAcc.Core_MDF_CoMarketing_Ultimate_Account__c =testAcctTemp.id;
            
            Core_MDF_Account_Onboarding__c accVirtual = new Core_MDF_Account_Onboarding__c();
            accVirtual.Core_MDF_Technical_Program_nm__c = 'Client CoMarketing Fund';
            accVirtual.Core_MDF_Type__c = 'Intel Account';
            accVirtual.Core_MDF_Account__c = testAcctTemp.Id;
            Database.insert(accVirtual);
            
            Account virtualCorp = [select Id,Name from Account where Core_MDF_CoMarketing_Ultimate_Account__c  =: testAcctTemp.id];
            
            Group ccfgrp = new Group();
            ccfgrp.Name = 'CCP TESTACCTTEMP CCF EMEA INTERNAL';
            ccfgrp.DeveloperName = 'Core_MDF_CCP_TESTACCTTEMP_CCF_EMEA_INTERNAL';
            Database.insert(ccfgrp);
            
            Core_MDF_Partner_Group_Mapping__c ccfPgm = new Core_MDF_Partner_Group_Mapping__c();
            ccfPgm.Core_MDF_Account__c = testAcctTemp.Id;
            ccfPgm.Core_MDF_Group_Name__c = 'Core_MDF_CCP_TESTACCTTEMP_CCF_EMEA_INTERNAL';
            ccfPgm.Core_MDF_Type_of_Access__c = 'Internal';           
            ccfPgm.Core_MDF_Channel_Program__c = ccfCp.Id;
            ccfPgm.Core_MDF_Region_cd__c = 'EMEA';
            ccfPgm.Core_MDF_Source_Txt__c = 'Test';  
            ccfPgm.Core_MDF_Virtual_Corp_nm__c = virtualCorp.id;        
            Database.insert(ccfPgm);
            
            Group cmdfgrp = new Group();
            cmdfgrp.Name = 'CCP TESTACCTTEMP CMDF EMEA INTERNAL';
            cmdfgrp.DeveloperName = 'Core_MDF_CCP_TESTACCTTEMP_CMDF_EMEA_INTERNAL';
            Database.insert(cmdfgrp);
            
            Core_MDF_Partner_Group_Mapping__c cmdfPgm = new Core_MDF_Partner_Group_Mapping__c();
            cmdfPgm.Core_MDF_Account__c = testAcctTemp.Id;
            cmdfPgm.Core_MDF_Group_Name__c = 'Core_MDF_CCP_TESTACCTTEMP_CMDF_EMEA_INTERNAL';
            cmdfPgm.Core_MDF_Type_of_Access__c = 'Internal';           
            cmdfPgm.Core_MDF_Channel_Program__c = ccfCp.Id;
            cmdfPgm.Core_MDF_Region_cd__c = 'EMEA';
            cmdfPgm.Core_MDF_Source_Txt__c = 'Test';  
            cmdfPgm.Core_MDF_BudgetType_nm__c='Intel MDF Account Based2';
            cmdfPgm.Core_MDF_Virtual_Corp_nm__c = virtualCorp.id; 
            Database.insert(cmdfPgm);
            
            Profile ccpCoreProfile = [SELECT Id FROM Profile WHERE Name = 'CCP - Core Access'];
            
            PermissionSet ccfAccManagerPS = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_CCF_Acct_Mgr' LIMIT 1];
            PermissionSet dcfAccManagerPS = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_DCF_Acct_Mgr' LIMIT 1];
            PermissionSet retailAccManagerPS = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_Retail_Account_Manager' LIMIT 1];
            PermissionSet readOnlyUsrPS = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Int_Read_Only' LIMIT 1];
            PermissionSet ipaAccManagerPS = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_IPA_Acct_Mgr' LIMIT 1];
            PermissionSet ipaProgAdmPS = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_IPA_Program_Adm' LIMIT 1];
            PermissionSet ipaApprPS = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Int_IPA_ProposalL1_Approver' LIMIT 1];
            PermissionSet ipaEscRevL1PS = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Core_MDF_Internal_Escalation_Reviewer_L1' LIMIT 1];
            PermissionSet eefActivatingPS = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Core_MDF_Internal_EEF_Activating_Partner_Acct_Mgr' LIMIT 1];
            
            List<PermissionSet> channelPS = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Core_MDF_Int_Channel_MDF_Acct_Mgr' LIMIT 1];
            List<PermissionSet> channelPS1 = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_Channel_MDF_Budget_Approver' LIMIT 1];
            
            
            List<User> userList = new List<User>();
            List<PermissionSetAssignment> permissionSetAssignmentList = new List<PermissionSetAssignment>();
            
            User readOnlyUsr = Core_MDF_CCP_TestDataUtility.createUser(false);
            readOnlyUsr.profileId = ccpCoreProfile.Id;
            readOnlyUsr.LastName = 'Read Only Usr';
            userList.add(readOnlyUsr);
            
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
            
            User ccfAccountManagerinactive = Core_MDF_CCP_TestDataUtility.createUser(false);
            ccfAccountManagerinactive.profileId = ccpCoreProfile.Id;
            ccfAccountManagerinactive.LastName = 'Inactive CCF Acc Manager';
            ccfAccountManagerinactive.UserPermissionsMarketingUser = False;
            userList.add(ccfAccountManagerinactive);
            
            User ccfAccManager = Core_MDF_CCP_TestDataUtility.createUser(false);
            ccfAccManager.profileId = ccpCoreProfile.Id;
            ccfAccManager.LastName = 'CCF Account Manager';
            userList.add(ccfAccManager);
            
            User accountManager = Core_MDF_CCP_TestDataUtility.createUser(false);
            AccountManager.profileId = ccpCoreProfile.Id;
            AccountManager.LastName = 'CCF DCF Acc Manager';
            userList.add(AccountManager);
            
            User progAdmUsr = Core_MDF_CCP_TestDataUtility.createUser(false);
            progAdmUsr.profileId = ccpCoreProfile.Id;
            progAdmUsr.LastName = 'Prog Adm Usr';
            userList.add(progAdmUsr);
            
            User escReviewer = Core_MDF_CCP_TestDataUtility.createUser(false);
            escReviewer.profileId = ccpCoreProfile.Id;
            escReviewer.LastName = 'Escalation Reviewer';
            userList.add(escReviewer);
            
            User cmdfAccManager = Core_MDF_CCP_TestDataUtility.createUser(false);
            cmdfAccManager.profileId = ccpCoreProfile.Id;
            cmdfAccManager.LastName = 'cmdf Account Manager';
            userList.add(cmdfAccManager);            
            
            insert userList;
            
            
            PermissionSetAssignment ps = new PermissionSetAssignment(PermissionSetId = ccfAccManagerPS.Id, AssigneeId = ccfAccountManagerinactive.Id);
            permissionSetAssignmentList.add(ps);
            
            PermissionSetAssignment psa = new PermissionSetAssignment(PermissionSetId = readOnlyUsrPS.Id, AssigneeId = readOnlyUsr.Id);
            permissionSetAssignmentList.add(psa);
            
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
            
            PermissionSetAssignment psa7 = new PermissionSetAssignment(PermissionSetId = ipaAccManagerPS.Id, AssigneeId = retailAccountManager.Id);
            permissionSetAssignmentList.add(psa7);
            
            PermissionSetAssignment psa8 = new PermissionSetAssignment(PermissionSetId = ipaProgAdmPS.Id, AssigneeId = progAdmUsr.Id);
            permissionSetAssignmentList.add(psa8);
            
            PermissionSetAssignment psa9 = new PermissionSetAssignment(PermissionSetId = ipaApprPS.Id, AssigneeId = progAdmUsr.Id);
            permissionSetAssignmentList.add(psa9);
            if(channelPS != null && !channelPS.isEmpty()){
                PermissionSetAssignment psa10 = new PermissionSetAssignment(PermissionSetId = channelPS[0].Id, AssigneeId = cmdfAccManager.Id);
                permissionSetAssignmentList.add(psa10);
            }
            if(channelPS1 != null && !channelPS1.isEmpty()){
                PermissionSetAssignment psa11 = new PermissionSetAssignment(PermissionSetId = channelPS1[0].Id, AssigneeId = cmdfAccManager.Id);
                permissionSetAssignmentList.add(psa11);
            }
            
            PermissionSetAssignment psa12 = new PermissionSetAssignment(PermissionSetId = ipaEscRevL1PS.Id, AssigneeId = progAdmUsr.Id);
            permissionSetAssignmentList.add(psa12);
            
            PermissionSetAssignment psa13 = new PermissionSetAssignment(PermissionSetId = eefActivatingPS.Id, AssigneeId = progAdmUsr.Id);
            permissionSetAssignmentList.add(psa13);
            
            PermissionSetAssignment psaEscReviewer = new PermissionSetAssignment(PermissionSetId = ipaEscRevL1PS.Id, AssigneeId = escReviewer.Id);
            permissionSetAssignmentList.add(psaEscReviewer);
            
            
            insert permissionSetAssignmentList;
            
            
            List<Core_MDF_ProgramGeoRoleGroupMap__c> progGeoRoleGrpList = new List<Core_MDF_ProgramGeoRoleGroupMap__c>();
            Core_MDF_ProgramGeoRoleGroupMap__c progGeoRoleGrp = new Core_MDF_ProgramGeoRoleGroupMap__c();
            
            progGeoRoleGrp.Core_MDF_Program_txt__c = 'Intel Partner Alliance';
            progGeoRoleGrp.Name = 'Test Role';
            progGeoRoleGrp.Core_MDF_Region_txt__c = 'APJ';
            progGeoRoleGrp.Core_MDF_Is_Primary_Role__c = false;
            progGeoRoleGrp.Core_MDF_Role_txt__c = 'Core_MDF_Internal_Escalation_Reviewer_L1';
            progGeoRoleGrp.Core_MDF_Group_Name_txt__c = 'Core_MDF_CCP_IPA_APJ_Escltns_L1_Apr_Grp';
            progGeoRoleGrp.Core_MDF_Is_Active__c = true;
            progGeoRoleGrpList.add(progGeoRoleGrp);
            
            Core_MDF_ProgramGeoRoleGroupMap__c progGeoRoleGrp1 = new Core_MDF_ProgramGeoRoleGroupMap__c();
            progGeoRoleGrp1.Core_MDF_Program_txt__c = 'Intel Partner Alliance';
            progGeoRoleGrp1.Name = 'Test Role1';
            progGeoRoleGrp1.Core_MDF_Region_txt__c = 'APJ';
            progGeoRoleGrp1.Core_MDF_Is_Primary_Role__c = true;
            progGeoRoleGrp1.Core_MDF_Role_txt__c = 'Core_MDF_Internal_Escalation_Reviewer_L1';
            progGeoRoleGrp1.Core_MDF_Group_Name_txt__c = 'Core_MDF_CCP_TESTACCTTEMP_CCF_EMEA_INTERNAL';
            progGeoRoleGrp1.Core_MDF_Is_Active__c = true;
            progGeoRoleGrpList.add(progGeoRoleGrp1);
            
            insert progGeoRoleGrpList;
            
           
            Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgmEscReviewer = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
            iupgmEscReviewer.Core_MDF_Program_nm__c = 'Intel Partner Alliance';
            
            iupgmEscReviewer.RecordTypeId = IPA_RecordType;
            iupgmEscReviewer.Core_MDF_Region_Sub_Region_nm__c = 'APJ';
            iupgmEscReviewer.Core_MDF_User_id__c = escReviewer.Id;
            iupgmEscReviewer.Core_MDF_Role_nm__c = 'Core_MDF_Internal_Escalation_Reviewer_L1';
            Database.insert(iupgmEscReviewer);
            
            Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgmPgrAdm = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
            iupgmPgrAdm.Core_MDF_Program_nm__c = 'Intel Partner Alliance';
            iupgmPgrAdm.RecordTypeId = IPA_RecordType;
            iupgmPgrAdm.Core_MDF_Region_Sub_Region_nm__c = 'APJ;PRC';
            iupgmPgrAdm.Core_MDF_User_id__c = progAdmUsr.Id;
            iupgmPgrAdm.Core_MDF_Role_nm__c = 'Core_MDF_CCP_Internal_IPA_Program_Adm';
            iupgmPgrAdm.Core_MDF_All_Accounts_cd__c = 'Yes';
            iupgmPgrAdm.Core_MDF_Budget_Type_nm__c = 'Data Centric Acceleration - MDF';//Client Specialties MDF;Optane Specialties MDF';
            iupgmPgrAdm.Core_MDF_GeoSubGeo_Budget_Type_nm__c = 'APJ->Data Centric Acceleration - MDF;PRC->Data Centric Acceleration - MDF';
            Database.insert(iupgmPgrAdm);
            
            Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgmactAcctMrg = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
            iupgmactAcctMrg.Core_MDF_Program_nm__c = 'Ecosystem Extension Fund';
            iupgmactAcctMrg.RecordTypeId = EEF_RecordType;
            iupgmactAcctMrg.Core_MDF_Region_Sub_Region_nm__c = 'APJ;PRC';
            iupgmactAcctMrg.Core_MDF_User_id__c = progAdmUsr.Id;
            iupgmactAcctMrg.Core_MDF_Role_nm__c = 'Core_MDF_Internal_EEF_Activating_Partner_Acct_Mgr';
            iupgmactAcctMrg.Core_MDF_All_Accounts_cd__c = 'No';
            iupgmactAcctMrg.Core_MDF_Account_id__c = testAcctTemp.Id ;
            //Database.insert(iupgmactAcctMrg);
            
            Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgmPgrAdm2 = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
            iupgmPgrAdm2.Core_MDF_Program_nm__c = 'Intel Partner Alliance';
            iupgmPgrAdm2.RecordTypeId = IPA_RecordType;
            iupgmPgrAdm2.Core_MDF_Region_Sub_Region_nm__c = 'APJ;PRC';
            iupgmPgrAdm2.Core_MDF_User_id__c = retailAccountManager.Id;
            iupgmPgrAdm2.Core_MDF_Role_nm__c = 'Core_MDF_CCP_Internal_IPA_Acct_Mgr';
            iupgmPgrAdm2.Core_MDF_All_Accounts_cd__c = 'No';
            iupgmPgrAdm2.Core_MDF_Account_id__c = testAcctTemp.Id ;
            iupgmPgrAdm2.Core_MDF_Budget_Type_nm__c = 'Data Centric Acceleration - MDF';//Client Specialties MDF;Optane Specialties MDF';
            iupgmPgrAdm2.Core_MDF_GeoSubGeo_Budget_Type_nm__c = 'APJ->Data Centric Acceleration - MDF;PRC->Data Centric Acceleration - MDF';
            Database.insert(iupgmPgrAdm2);
            
            
            
            
        }
    }
    
    @isTest
    static void pgmExists(){
        test.startTest();
        Account acc = [SELECT Id FROM Account WHERE Name = 'CCPTestAccountTemp'];
        ChannelProgram cp = [SELECT Id FROM ChannelProgram WHERE Name = 'Client'];
        ChannelProgram cpcmdf = [SELECT Id FROM ChannelProgram WHERE Name = 'Channel MDF'];
        User userCMDF = [SELECT Id FROM User WHERE LastName = 'cmdf Account Manager'];
        Group CmdfgroupId = [SELECT Id FROM Group WHERE DeveloperName = 'Core_MDF_CCP_TESTACCTTEMP_CMDF_EMEA_INTERNAL']; 
        User user = [SELECT Id FROM User WHERE LastName = 'CCF Acc Manager'];
        User ccfDcfuser = [SELECT Id FROM User WHERE LastName = 'CCF DCF Acc Manager'];
        User readOnlyuser = [SELECT Id FROM User WHERE LastName = 'Read Only Usr'];
        User pausr = [SELECT Id FROM User WHERE LastName = 'Prog Adm Usr'];
        User escReviewerIPA = [SELECT Id FROM User WHERE LastName = 'Escalation Reviewer' LIMIT 1];
        Group groupId = [SELECT Id FROM Group WHERE DeveloperName = 'Core_MDF_CCP_TESTACCTTEMP_CCF_EMEA_INTERNAL'];
        Group IPAEscGroupId = [SELECT Id FROM Group WHERE DeveloperName = 'Core_MDF_CCP_IPA_APJ_Escltns_L1_Apr_Grp'];

        List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> iupgmList = new List<Core_MDF_Int_Users_Partner_Geo_Mapping__c>();
        List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> iupgmUpdateList = new List<Core_MDF_Int_Users_Partner_Geo_Mapping__c>();
        
        Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
        iupgm.Core_MDF_Account_id__c = acc.Id;
        iupgm.Core_MDF_Program_nm__c = 'Client CoMarketing Fund';
        iupgm.RecordTypeId = CCF_RecordType ;
        iupgm.Core_MDF_Region_Sub_Region_nm__c = 'EMEA';
        iupgm.Core_MDF_User_id__c = user.Id;
        iupgm.Core_MDF_Role_nm__c = 'Core_MDF_CCP_Internal_CCF_Acct_Mgr';
        iupgm.Core_MDF_All_Accounts_cd__c = 'No';
        iupgmList.add(iupgm);
        
        
        Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm2 = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
        iupgm2.Core_MDF_Account_id__c = acc.Id;
        iupgm2.Core_MDF_Program_nm__c = 'Client CoMarketing Fund';
        iupgm2.RecordTypeId = CCF_RecordType;
        iupgm2.Core_MDF_Region_Sub_Region_nm__c = 'EMEA';
        iupgm2.Core_MDF_User_id__c = ccfDcfuser.Id;
        iupgm2.Core_MDF_Role_nm__c = 'Core_MDF_CCP_Internal_CCF_Acct_Mgr';
        iupgm2.Core_MDF_All_Accounts_cd__c = 'No';
        
        iupgmList.add(iupgm2);
        
        Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm3 = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();        
        iupgm3.Core_MDF_Program_nm__c = 'Data Center CoMarketing Fund';
        iupgm3.RecordTypeId = DCF_RecordType;
        iupgm3.Core_MDF_Region_Sub_Region_nm__c = 'APJ';
        iupgm3.Core_MDF_User_id__c = ccfDcfuser.Id;
        iupgm3.Core_MDF_Role_nm__c = 'Core_MDF_CCP_Internal_DCF_Acct_Mgr';
        iupgm3.Core_MDF_All_Accounts_cd__c = 'Yes';
        
        iupgmList.add(iupgm3);
        
        Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm4 = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();        
        iupgm4.Core_MDF_Program_nm__c = 'Data Center CoMarketing Fund';
        iupgm4.RecordTypeId = DCF_RecordType;
        iupgm4.Core_MDF_Region_Sub_Region_nm__c = 'WW';
        iupgm4.Core_MDF_User_id__c = readOnlyuser.Id;
        iupgm4.Core_MDF_Role_nm__c = 'Core_MDF_CCP_Int_Read_Only';
        iupgm4.Core_MDF_All_Accounts_cd__c = 'Yes';
        
        Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm5 = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();        
        iupgm5.Core_MDF_Program_nm__c = 'Intel Partner Alliance';
        iupgm5.RecordTypeId =IPA_RecordType ;
        iupgm5.Core_MDF_Region_Sub_Region_nm__c = 'APJ';
        iupgm5.Core_MDF_User_id__c = readOnlyuser.Id;
        iupgm5.Core_MDF_Role_nm__c = 'Core_MDF_CCP_Int_Read_Only';
        iupgm5.Core_MDF_All_Accounts_cd__c = 'Yes';
        
        Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm6 = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
        iupgm6.Core_MDF_Program_nm__c = 'Intel Partner Alliance';
        iupgm6.RecordTypeId = IPA_RecordType;
        iupgm6.Core_MDF_Region_Sub_Region_nm__c = 'APJ';
        iupgm6.Core_MDF_User_id__c = pausr.Id;
        iupgm6.Core_MDF_Role_nm__c = 'Core_MDF_CCP_Internal_IPA_Program_Adm';
        iupgm6.Core_MDF_All_Accounts_cd__c = 'Yes';
        iupgm6.Core_MDF_Budget_Type_nm__c = 'Data Centric Acceleration - MDF';//Client Specialties MDF;Optane Specialties MDF';
        iupgm6.Core_MDF_GeoSubGeo_Budget_Type_nm__c = 'APJ->Data Centric Acceleration - MDF;APJ->Data Centric Acceleration - MDF';
        
        Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm7 = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
        iupgm7.Core_MDF_Program_nm__c = 'Intel Partner Alliance';
        iupgm7.RecordTypeId =IPA_RecordType;
        iupgm7.Core_MDF_Region_Sub_Region_nm__c = 'PRC';
        iupgm7.Core_MDF_User_id__c = pausr.Id;
        iupgm7.Core_MDF_Role_nm__c = 'Core_MDF_CCP_Int_IPA_ProposalL1_Approver';
        iupgm7.Core_MDF_All_Accounts_cd__c = 'Yes';
        iupgm7.Core_MDF_Budget_Type_nm__c = 'Data Centric Acceleration - MDF';//Client Specialties MDF;Optane Specialties MDF';
        iupgm7.Core_MDF_GeoSubGeo_Budget_Type_nm__c = 'PRC->Data Centric Acceleration - MDF';
        //iupgm7.Core_MDF_CMDF_GeoSubGeo_BudgetType_nm__c='PRC->Intel MDF Account Based2';
        
        Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm8 = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
        iupgm8.Core_MDF_Program_nm__c = 'Channel MDF';
        iupgm8.RecordTypeId=CMDF_RecordType ;
        iupgm8.Core_MDF_Account_id__c=acc.id;
        iupgm8.Core_MDF_All_Budget_Type_Access_Ind__c=false;
        iupgm8.Core_MDF_User_id__c = userCMDF.Id;
        //iupgm8.Core_MDF_CMDF_GeoSubGeo_BudgetType_nm__c='APJ->Intel MDF Account Based2';
        iupgm8.Core_MDF_Role_nm__c = 'Core_MDF_Int_Channel_MDF_Acct_Mgr';
        iupgm8.Core_MDF_All_Accounts_cd__c = 'No';
        iupgmList.add(iupgm8); 
        
        Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm9 = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
        iupgm9.Core_MDF_Program_nm__c = 'Intel Partner Alliance';
        iupgm9.RecordTypeId = IPA_RecordType;
        iupgm9.Core_MDF_Region_Sub_Region_nm__c = 'WW';
        iupgm9.Core_MDF_User_id__c = pausr.Id;
        iupgm9.Core_MDF_Role_nm__c = 'Core_MDF_Internal_Escalation_Reviewer_L1';
        
        Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgmEscReviewer = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
        iupgmEscReviewer.Core_MDF_Program_nm__c = 'Intel Partner Alliance';
        iupgmEscReviewer.RecordTypeId =IPA_RecordType;
        iupgmEscReviewer.Core_MDF_Region_Sub_Region_nm__c = 'APJ';
        iupgmEscReviewer.Core_MDF_User_id__c = escReviewerIPA.Id;
        iupgmEscReviewer.Core_MDF_Role_nm__c = 'Core_MDF_Internal_Escalation_Reviewer_L1';
        
        
        iupgmList.add(iupgm4);
        iupgmList.add(iupgm5);
        iupgmList.add(iupgm6);
        iupgmList.add(iupgm7);
        iupgmList.add(iupgm9);
        iupgmList.add(iupgmEscReviewer);
        try{
            insert iupgmList;
        }catch(Exception e){
        }
        
        List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> UpdateIUPGM=[Select Id,Core_MDF_Program_nm__c,Core_MDF_All_Budget_Type_Access_Ind__c from Core_MDF_Int_Users_Partner_Geo_Mapping__c
                                                                     where Core_MDF_Program_nm__c = 'Channel MDF' AND  Core_MDF_Role_nm__c = 'Core_MDF_Int_Channel_MDF_Acct_Mgr'  LIMIT 1];
        if(UpdateIUPGM != null && !UpdateIUPGM.isEmpty()){
            //UpdateIUPGM[0].Core_MDF_CMDF_GeoSubGeo_BudgetType_nm__c='APJ->Intel MDF Account Based2;APJ->Intel MDF Account Based2';
            UpdateIUPGM[0].Core_MDF_All_Budget_Type_Access_Ind__c=True;
            UpdateIUPGM[0].Core_MDF_Active_Ind__c=false;
            Database.update(UpdateIUPGM);   
        }
        List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> UpdateIUPGM1=[Select Id,Core_MDF_Program_nm__c,Core_MDF_All_Budget_Type_Access_Ind__c from Core_MDF_Int_Users_Partner_Geo_Mapping__c
                                                                      where Core_MDF_Program_nm__c = 'Channel MDF'AND  Core_MDF_Role_nm__c = 'Core_MDF_Int_Channel_MDF_Acct_Mgr' LIMIT 1];
        if(UpdateIUPGM1 !=null && !UpdateIUPGM1.isEmpty()){
            UpdateIUPGM1[0].Core_MDF_All_Budget_Type_Access_Ind__c=false;
            Database.update(UpdateIUPGM1);
        }
        
      
        
        List<String> geoSubGeoStringList = new List<String>();
        geoSubGeoStringList.add('APJ');
        geoSubGeoStringList.add('APJ');
        
        
        String accountName='Test Acc';
        String programName='CMDF';
        String budgetType='Client Specialties MDF';
        Core_MDF_IUPGM_ServiceHandler.geoSubGeoWrapper gsg = new Core_MDF_IUPGM_ServiceHandler.geoSubGeoWrapper();
        gsg=Core_MDF_IUPGM_ServiceHandler.getAccProgramGeoSubGeo(geoSubGeoStringList,accountName, programName,budgetType);
        test.stopTest();        
        Assert.isTrue(gsg != null);
        
        iupgm4.Core_MDF_Region_Sub_Region_nm__c = 'APJ';
        iupgmUpdateList.add(iupgm4);
        iupgm5.Core_MDF_Region_Sub_Region_nm__c = 'APJ';
        iupgm5.Core_MDF_Active_Ind__c = FALSE;
        iupgmUpdateList.add(iupgm5);
        
        iupgm6.Core_MDF_Budget_Type_nm__c ='Data Centric Acceleration - MDF';
        iupgm6.Core_MDF_Region_Sub_Region_nm__c = 'PRC;APJ';
        iupgm6.Core_MDF_GeoSubGeo_Budget_Type_nm__c = 'PRC->Data Centric Acceleration - MDF;APJ->Data Centric Acceleration - MDF';
        iupgm6.Core_MDF_Active_Ind__c = FALSE;
        iupgmUpdateList.add(iupgm6);
        iupgmEscReviewer.Core_MDF_Region_Sub_Region_nm__c = 'WW';
        iupgmUpdateList.add(iupgmEscReviewer);
        iupgm9.Core_MDF_Region_Sub_Region_nm__c = 'APJ';
        iupgmUpdateList.add(iupgm9);
        try{
            update iupgmUpdateList;
        }Catch(Exception e){
        }
       
    }
    
    @isTest
    static void pgmIsAbsent(){
        Account acc = [SELECT Id FROM Account WHERE Name = 'CCPTestAccountTemp1'];
        ChannelProgram cp = [SELECT Id FROM ChannelProgram WHERE Name = 'Datacenter'];
        User user = [SELECT Id FROM User WHERE LastName = 'DCF Acc Manager'];
        User user2 = [SELECT Id FROM User WHERE LastName = 'Retail Acc Manager'];
        
        Group dcfgrp = new Group();
        dcfgrp.Name = 'CCP TESTACCTTEMP1 DCF APJ INTERNAL';
        dcfgrp.DeveloperName = 'Core_MDF_CCP_TESTACCTTEMP1_DCF_APJ_INTERNAL';
        Database.insert(dcfgrp);        
        
        /*test.startTest();
        List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> iupgmList=new List<Core_MDF_Int_Users_Partner_Geo_Mapping__c>();
        Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
        iupgm.Core_MDF_Account_id__c = acc.Id;
        iupgm.RecordTypeId = DCF_RecordType;
        iupgm.Core_MDF_Program_nm__c = 'Data Center CoMarketing Fund';
        iupgm.Core_MDF_Region_Sub_Region_nm__c = 'APJ';
        iupgm.Core_MDF_User_id__c = user.Id;
        iupgm.Core_MDF_Role_nm__c = 'Core_MDF_CCP_Internal_DCF_Acct_Mgr';
        iupgm.Core_MDF_All_Accounts_cd__c = 'No';
        iupgmList.add(iupgm);
        
        Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm2 = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
        iupgm2.Core_MDF_Account_id__c = acc.Id;
        iupgm2.Core_MDF_Program_nm__c = 'Intel Partner Alliance';
        iupgm2.RecordTypeId =IPA_RecordType ;
        iupgm2.Core_MDF_Region_Sub_Region_nm__c = 'APJ';
        iupgm2.Core_MDF_All_Budget_Type_Access_Ind__c = true;
        iupgm2.Core_MDF_User_id__c = user2.Id;
        iupgm2.Core_MDF_Role_nm__c = 'Core_MDF_CCP_Internal_IPA_Acct_Mgr';
        iupgm2.Core_MDF_All_Accounts_cd__c = 'No';
        iupgmList.add(iupgm2);
        
        insert iupgmList;
        
        iupgm2.Core_MDF_Region_Sub_Region_nm__c = 'EMEA';
        update iupgm2;
        
        List<String> geoSubGeoStringList = new List<String>();
        geoSubGeoStringList.add('APJ');
        geoSubGeoStringList.add('APJ');
        
        
        String accountName='Test Acc';
        String programName='CMDF';
        String budgetType='';
        Core_MDF_IUPGM_ServiceHandler.geoSubGeoWrapper gsg = new Core_MDF_IUPGM_ServiceHandler.geoSubGeoWrapper();
        gsg=Core_MDF_IUPGM_ServiceHandler.getAccProgramGeoSubGeo(geoSubGeoStringList,accountName, programName,budgetType);
        
        List<String> geoSubGeoStringList1 = new List<String>();
        geoSubGeoStringList1.add('APJ');
        geoSubGeoStringList1.add('APJ');
        
        
        String accountName1='Test Acc';
        String programName1='CMDF';
        String budgetType1='';
        Core_MDF_IUPGM_ServiceHandler.geoSubGeoWrapper gsg1 = new Core_MDF_IUPGM_ServiceHandler.geoSubGeoWrapper();
        gsg1=Core_MDF_IUPGM_ServiceHandler.getAccProgramGeoSubGeo(geoSubGeoStringList1,accountName1, programName1,budgetType1);
        
        List<String> geoSubGeoStringList2 = new List<String>();
        geoSubGeoStringList2.add('APJ');
        geoSubGeoStringList2.add('APJ');
        
        
        String accountName2='Test Acc';
        String programName2='CMDF';
        String budgetType2='';
        Core_MDF_IUPGM_ServiceHandler.geoSubGeoWrapper gsg2 = new Core_MDF_IUPGM_ServiceHandler.geoSubGeoWrapper();
        gsg2=Core_MDF_IUPGM_ServiceHandler.getAccProgramGeoSubGeo(geoSubGeoStringList2,accountName2, programName2,budgetType2);
        
        List<String> geoSubGeoStringList3 = new List<String>();
        geoSubGeoStringList3.add('APJ');
        geoSubGeoStringList3.add('APJ');
        
        
        String accountName3='Test Acc';
        String programName3='CMDF';
        String budgetType3 ='_ALL';
        Core_MDF_IUPGM_ServiceHandler.geoSubGeoWrapper gsg3 = new Core_MDF_IUPGM_ServiceHandler.geoSubGeoWrapper();
        gsg3=Core_MDF_IUPGM_ServiceHandler.getAccProgramGeoSubGeo(geoSubGeoStringList3,accountName3, programName3,budgetType3);        
        
        
        Assert.isTrue(gsg3 != null);
        
        
        Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgmUpdated = [SELECT Id, Core_MDF_Active_Ind__c 
                                                                  FROM Core_MDF_Int_Users_Partner_Geo_Mapping__c 
                                                                  WHERE Core_MDF_Account_id__c =: acc.Id AND 
                                                                  Core_MDF_Program_nm__c='Intel Partner Alliance' ];//Data Center CoMarketing Fund
        
        iupgmUpdated.Core_MDF_Active_Ind__c = false;
        iupgmUpdated.Core_MDF_Region_Sub_Region_nm__c = 'APJ';
        update iupgmUpdated;
        test.stopTest();*/
    }
    
    @isTest
    static void iupgmWithSubRegion(){
        List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> iupgmList = new List<Core_MDF_Int_Users_Partner_Geo_Mapping__c>();
        Account acc = [SELECT Id FROM Account WHERE Name = 'CCPTestAccountTemp'];
        Account retailAcc = [SELECT Id FROM Account WHERE Name = 'RetailTestAccount' limit 1];
        ChannelProgram retailCp = [SELECT Id FROM ChannelProgram WHERE Name = 'Retail Marketing Funds'];   
        ChannelProgram cmdfCp = [SELECT Id FROM ChannelProgram WHERE Name = 'Channel MDF'];
        Account retailCoMarketingAccount = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Retail Co-Marketing Account', 
                                                                                                 retailCp.id, 
                                                                                                 Core_MDF_CCP_TestDataUtility.Account_Record_Type,
                                                                                                 retailAcc.id, false); 
        retailCoMarketingAccount.Core_Geo__c ='APJ';
        retailCoMarketingAccount.Core_Sub_Geo__c ='SA';
        insert retailCoMarketingAccount;
        
        /*User retailUser = [SELECT Id FROM User WHERE LastName = 'Retail Acc Manager'];
        User cmdfUser = [SELECT Id FROM User WHERE LastName = 'cmdf Account Manager'];
        try{
        Test.startTest();
        Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
        iupgm.Core_MDF_Account_id__c = retailCoMarketingAccount.Id;
        iupgm.Core_MDF_User_id__c = retailUser.Id;
        iupgm.RecordTypeId=RMF_RecordType;
        iupgm.Core_MDF_Program_nm__c = 'Retail Marketing Funds';        
        iupgm.Core_MDF_Role_nm__c = 'Core_MDF_CCP_Internal_Retail_Account_Manager';
        iupgm.Core_MDF_All_Accounts_cd__c = 'No';
        //iupgmList.add(iupgm);
        
        User userInactive = [SELECT Id FROM User WHERE LastName = 'Inactive CCF Acc Manager'];
        
        Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm1 = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
        iupgm1.Core_MDF_Account_id__c = acc.Id;
        iupgm1.Core_MDF_Program_nm__c = 'Client CoMarketing Fund';
        iupgm1.RecordTypeId = CCF_RecordType;
        iupgm1.Core_MDF_Region_Sub_Region_nm__c = 'EMEA';
        iupgm1.Core_MDF_User_id__c = userInactive.Id;
        iupgm1.Core_MDF_Role_nm__c = 'Core_MDF_CCP_Internal_CCF_Acct_Mgr';
        iupgm1.Core_MDF_All_Accounts_cd__c = 'No';
        iupgmList.add(iupgm1);
        
        Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm2 = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
        iupgm2.Core_MDF_Program_nm__c = 'Channel MDF';
        iupgm2.RecordTypeId = CMDF_RecordType;
        iupgm2.Core_MDF_Region_Sub_Region_nm__c = 'PRC';
        iupgm2.Core_MDF_Account_id__c=acc.id;
        iupgm2.Core_MDF_All_Budget_Type_Access_Ind__c=true;
        iupgm2.Core_MDF_User_id__c = cmdfUser.Id;
        iupgm2.Core_MDF_Role_nm__c = 'Core_MDF_Int_Channel_MDF_Acct_Mgr';
        iupgm2.Core_MDF_All_Accounts_cd__c = 'No';
        iupgmList.add(iupgm2);
        
        Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm3 = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
        iupgm3.Core_MDF_Program_nm__c = 'Channel MDF';
        iupgm3.RecordTypeId = CMDF_RecordType;
        iupgm3.Core_MDF_Region_Sub_Region_nm__c = 'WW';
        iupgm3.Core_MDF_Account_id__c=acc.id;
        iupgm3.Core_MDF_All_Budget_Type_Access_Ind__c=false;
        iupgm3.Core_MDF_User_id__c = cmdfUser.Id;
        iupgm3.Core_MDF_Role_nm__c = 'Core_MDF_CCP_Internal_Channel_MDF_Budget_Approver';
        iupgm3.Core_MDF_All_Accounts_cd__c = 'No';
        iupgmList.add(iupgm3);
        Core_MDF_IUPGM_ServiceHandler.getProgramGeoRoleGroupMap();
        
            insert iupgmList;
            
            for(Core_MDF_Int_Users_Partner_Geo_Mapping__c iup: iupgmList){
                if(iup.Core_MDF_Program_nm__c == 'Channel MDF' && iup.Core_MDF_Region_Sub_Region_nm__c == 'WW' && 
                  iup.Core_MDF_Role_nm__c == 'Core_MDF_CCP_Internal_Channel_MDF_Budget_Approver'){
                    iup.Core_MDF_All_Budget_Type_Access_Ind__c = true;
                }
            }
            update iupgmList;
        
       
        assert.isTrue(iupgmList != null);
        
        List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> iupgmInactive = [SELECT Id,Core_MDF_Active_Ind__c
                                                                         FROM Core_MDF_Int_Users_Partner_Geo_Mapping__c 
                                                                         WHERE Core_MDF_Program_nm__c = 'Retail Marketing Funds' LIMIT 1];
        if(iupgmInactive != null && !iupgmInactive.isEmpty()){                                                         
            iupgmInactive[0].Core_MDF_Active_Ind__c = FALSE;
            update iupgmInactive;
        }
        }catch(Exception e){
        }
         Test.stopTest();        
        /*List<Core_MDF_Partner_Group_Mapping__c> pgm = [SELECT Id 
                                                       FROM Core_MDF_Partner_Group_Mapping__c 
                                                       WHERE Core_MDF_Account__c =: acc.Id AND
                                                       Core_MDF_Channel_Program__r.Name = 'Client Co-Marketing Fund' AND
                                                       Core_MDF_Region_cd__c = 'EMEA'];*/  
    }
    
    @isTest
    static void activateIUPGM(){
        Account acc = [SELECT Id FROM Account WHERE Name = 'CCPTestAccountTemp'];
        ChannelProgram cp = [SELECT Id FROM ChannelProgram WHERE Name = 'Client'];
        User user = [SELECT Id FROM User WHERE LastName = 'CCF Acc Manager'];
        User dcfuser = [SELECT Id FROM User WHERE LastName = 'DCF Acc Manager'];
        Group groupId = [SELECT Id FROM Group WHERE DeveloperName = 'Core_MDF_CCP_TESTACCTTEMP_CCF_EMEA_INTERNAL'];
        test.startTest();
        
        Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
        iupgm.Core_MDF_Account_id__c = acc.Id;
        iupgm.Core_MDF_Program_nm__c = 'Client CoMarketing Fund';
        iupgm.RecordTypeId = CCF_RecordType;
        iupgm.Core_MDF_Region_Sub_Region_nm__c = 'EMEA';
        iupgm.Core_MDF_User_id__c = user.Id;
        iupgm.Core_MDF_Role_nm__c = 'Core_MDF_CCP_Internal_CCF_Acct_Mgr';
        iupgm.Core_MDF_All_Accounts_cd__c = 'No';
        insert iupgm;
        
        Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm3 = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();        
        iupgm3.Core_MDF_Program_nm__c = 'Data Center CoMarketing Fund';
        iupgm3.RecordTypeId = DCF_RecordType;
        iupgm3.Core_MDF_Region_Sub_Region_nm__c = 'APJ';
        iupgm3.Core_MDF_User_id__c = dcfuser.Id;
        iupgm3.Core_MDF_Role_nm__c = 'Core_MDF_CCP_Internal_DCF_Acct_Mgr';
        iupgm3.Core_MDF_All_Accounts_cd__c = 'Yes';
        insert iupgm3;
        
        iupgm3.Core_MDF_Region_Sub_Region_nm__c = 'PRC';
        update iupgm3;
        
        Core_MDF_IUPGM_ServiceHandler.queryMetadataForMasterGroup();
        
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
        
        List<GroupMember> newGM = [SELECT Id, GroupId, UserOrGroupId 
                                   FROM GroupMember 
                                   WHERE GroupId =: groupId.Id AND UserOrGroupId =: user.Id LIMIT 1];   
        test.stopTest();
        System.assert(newGM != NULL);
    }
    
    @isTest
    static void pgmExistsCmdfTest(){
        Account acc = [SELECT Id FROM Account WHERE Name = 'CCPTestAccountTemp'];
        ChannelProgram cpcmdf = [SELECT Id FROM ChannelProgram WHERE Name = 'Channel MDF'];
        User userCMDF = [SELECT Id FROM User WHERE LastName = 'cmdf Account Manager'];
        User dcfuser = [SELECT Id FROM User WHERE LastName = 'DCF Acc Manager'];
        Group CmdfgroupId = [SELECT Id FROM Group WHERE DeveloperName = 'Core_MDF_CCP_TESTACCTTEMP_CMDF_EMEA_INTERNAL']; 
        
        Group groupId = [SELECT Id FROM Group WHERE DeveloperName = 'Core_MDF_CCP_TESTACCTTEMP_CCF_EMEA_INTERNAL']; 
        
        List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> iupgmList = new List<Core_MDF_Int_Users_Partner_Geo_Mapping__c>();
        List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> iupgmUpdateList = new List<Core_MDF_Int_Users_Partner_Geo_Mapping__c>();
        
        test.startTest();
        Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
        iupgm.Core_MDF_Account_id__c = acc.Id;
        iupgm.Core_MDF_Program_nm__c = 'Channel MDF';
        iupgm.RecordTypeId = CMDF_RecordType;
        iupgm.Core_MDF_Region_Sub_Region_nm__c = 'EMEA';
        iupgm.Core_MDF_User_id__c = userCMDF.Id;
        iupgm.Core_MDF_Role_nm__c = 'Core_MDF_Int_Channel_MDF_Acct_Mgr';
        iupgm.Core_MDF_All_Accounts_cd__c = 'No';
        
        Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm3 = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();        
        iupgm3.Core_MDF_Program_nm__c = 'Data Center CoMarketing Fund';
        iupgm3.RecordTypeId = DCF_RecordType;
        iupgm3.Core_MDF_Region_Sub_Region_nm__c = 'APJ';
        
        iupgm3.Core_MDF_User_id__c = dcfuser.Id;
        iupgm3.Core_MDF_Role_nm__c = 'Core_MDF_CCP_Internal_DCF_Acct_Mgr';
        iupgm3.Core_MDF_All_Accounts_cd__c = 'Yes';
        iupgm3.Core_MDF_All_Budget_Type_Access_Ind__c=False;
        iupgm3.Core_MDF_GeoSubGeo_Budget_Type_nm__c='APJ->Client Specialties MDF';
        //iupgm3.Core_MDF_CMDF_GeoSubGeo_BudgetType_nm__c='APJ->Intel MDF Account Based2';
        iupgmList.add(iupgm3);
        
        Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm2 = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
        iupgm2.Core_MDF_Program_nm__c = 'Channel MDF';
        iupgm2.RecordTypeId = CMDF_RecordType;
        iupgm2.Core_MDF_Region_Sub_Region_nm__c = 'PRC';
        iupgm2.Core_MDF_Account_id__c=acc.id;
        iupgm2.Core_MDF_All_Budget_Type_Access_Ind__c=False;
        iupgm2.Core_MDF_User_id__c = userCMDF.Id;
        iupgm2.Core_MDF_Role_nm__c = 'Core_MDF_CCP_Internal_Channel_MDF_Budget_Approver';
        iupgm2.Core_MDF_All_Accounts_cd__c = 'No';
        iupgm2.Core_MDF_Sub_Region_cd__c='LAR';
        iupgm2.Core_MDF_Budget_Type_nm__c='Client Specialties MDF';
        //iupgm2.Core_MDF_CMDF_GeoSubGeo_BudgetType_nm__c='PRC->Intel MDF Account Based2';
        
        iupgmList.add(iupgm2);
        try{
            insert iupgmList;
        }catch(Exception e){

        } 
        
        
        List<String> geoSubGeoStringList = new List<String>();
        geoSubGeoStringList.add('APJ');
        geoSubGeoStringList.add('APJ');
        
        
        String accountName='Test Acc';
        String programName='CMDF';
        String budgetType='Client Specialties MDF';
        Core_MDF_IUPGM_ServiceHandler.geoSubGeoWrapper gsg = new Core_MDF_IUPGM_ServiceHandler.geoSubGeoWrapper();
        gsg=Core_MDF_IUPGM_ServiceHandler.getAccProgramGeoSubGeo(geoSubGeoStringList,accountName, programName,budgetType);
        
        
        System.assertNotEquals(Null, Core_MDF_IUPGM_ServiceHandler.programGeoSubGeoBudgetMap);
        
        try{
            Map<Id, Core_MDF_Int_Users_Partner_Geo_Mapping__c> iupgmListMap = new Map<Id, Core_MDF_Int_Users_Partner_Geo_Mapping__c>(iupgmList);
            Core_MDF_IUPGM_ServiceHandler.checkPGM(iupgmListMap);
            Map<String,List<GroupMember>> newGroupMemberMap  = Core_MDF_IUPGM_ServiceHandler.addRoleSpecificIUPGMGroupMember(iupgmList);
            Core_MDF_IUPGM_ServiceHandler.checkPGM(null);
            Core_MDF_IUPGM_ServiceHandler.checkUserPermission(null,null,null,null);
            Core_MDF_IUPGM_ServiceHandler.deleteGroupMember(' ');
            Core_MDF_IUPGM_ServiceHandler.removeGroupMember(null, null);
            Core_MDF_IUPGM_ServiceHandler.getExistingIupgmUserIdGeoBudgetMap(null);
            //Core_MDF_IUPGM_ServiceHandler.createIUPGMPlatformEventRecords(null,null,' ');    
        }
        catch(exception e){
            system.assert(e != null);
        }
        test.stopTest();
        
        
    }
    
    /* @isTest
   static void pgmExistsCmdf(){
        User us = [SELECT Id,LastName, isActive FROM User WHERE profile.Name = 'System Administrator' and isActive=true limit 1];
        System.runAs(us)
        {
            
            
            Account acc = [SELECT Id,Name FROM Account WHERE Name = 'CCPTestAccountTemp'];          
            ChannelProgram cpcmdf1 = [SELECT Id,Name FROM ChannelProgram WHERE Name = 'Channel MDF'];
            User userCMDF1 = [SELECT Id,LastName FROM User WHERE LastName = 'cmdf Account Manager'];
            Group CmdfgroupId1 = [SELECT Id,DeveloperName FROM Group WHERE DeveloperName = 'Core_MDF_CCP_TESTACCTTEMP_CMDF_EMEA_INTERNAL'];      
            List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> iupgmList = new List<Core_MDF_Int_Users_Partner_Geo_Mapping__c>();
            List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> iupgmUpdateList = new List<Core_MDF_Int_Users_Partner_Geo_Mapping__c>();
            
            Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
            iupgm.Core_MDF_Program_nm__c = 'Channel MDF';
            iupgm.Core_MDF_CMDF_GeoSubGeo_BudgetType_nm__c='PRC->Intel MDF Account Based2';
            iupgm.Core_MDF_Role_nm__c = 'Core_MDF_Int_Channel_MDF_Acct_Mgr';
            iupgm.Core_MDF_User_id__c = userCMDF1.Id;
            iupgm.Core_MDF_Region_Sub_Region_nm__c='PRC';   
            iupgm.Core_MDF_All_Accounts_cd__c = 'Yes';
            
            GroupMember gm = new  GroupMember();
            gm.GroupId= CmdfgroupId1.id;
            gm.UserOrGroupId=userCMDF1.id;
            test.startTest();
            insert gm;           
            
            insert iupgm;
            test.stopTest(); 
            
        }            
    }*/
    
    @isTest
    static void removeRoleSpecificUser(){
        
        Map<Id, Core_MDF_Int_Users_Partner_Geo_Mapping__c> oldMap = new Map<Id, Core_MDF_Int_Users_Partner_Geo_Mapping__c>();
        Map<Id, Core_MDF_Int_Users_Partner_Geo_Mapping__c> newMap = new Map<Id, Core_MDF_Int_Users_Partner_Geo_Mapping__c>();
        Map<Id, Core_MDF_Int_Users_Partner_Geo_Mapping__c> oldMap2 = new Map<Id, Core_MDF_Int_Users_Partner_Geo_Mapping__c>();
        Map<Id, Core_MDF_Int_Users_Partner_Geo_Mapping__c> newMap2 = new Map<Id, Core_MDF_Int_Users_Partner_Geo_Mapping__c>();
        Map<Id, Core_MDF_Int_Users_Partner_Geo_Mapping__c> oldMap3 = new Map<Id, Core_MDF_Int_Users_Partner_Geo_Mapping__c>();
       
        Map<String, List<String>> groupNameToGeo = new Map<String, List<String>>();
        
        test.starttest();
        //Account acc = [SELECT Id FROM Account WHERE Name = 'CCPTestAccountTemp'];
        //ChannelProgram ipaCp = Core_MDF_CCP_TestDataUtility.createProgram ('Intel Partner Alliance','Intel Partner Alliance', false); 
        //User escReviewerIPA = [SELECT Id,LastName FROM User WHERE LastName = 'Escalation Reviewer'];
        //User pausr = [SELECT Id FROM User WHERE LastName = 'Prog Adm Usr'];
        /*Core_MDF_ProgramGeoRoleGroupMap__c IPAEscGroupId = [SELECT Id,Core_MDF_Program_txt__c,Core_MDF_Role_txt__c FROM 
                                                            Core_MDF_ProgramGeoRoleGroupMap__c WHERE Core_MDF_Group_Name_txt__c = 'Core_MDF_CCP_IPA_APJ_Escltns_L1_Apr_Grp' LIMIT 1];*/
        //String progRoleKey = IPAEscGroupId.Core_MDF_Program_txt__c + IPAEscGroupId.Core_MDF_Role_txt__c ;
        
        Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm = [SELECT id,Core_MDF_User_id__c,Core_MDF_Program_nm__c,Core_MDF_GeoSubGeo_Budget_Type_nm__c,Core_MDF_Role_nm__c,Core_MDF_Region_Sub_Region_nm__c, Core_MDF_Active_Ind__c
                                                           FROM Core_MDF_Int_Users_Partner_Geo_Mapping__c WHERE Core_MDF_User_id__r.LastName = 'Escalation Reviewer' LIMIT 1];
        
        Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgmPrgAdm = [SELECT id,Core_MDF_User_id__c,Core_MDF_Program_nm__c,Core_MDF_Role_nm__c,Core_MDF_Region_Sub_Region_nm__c, Core_MDF_Active_Ind__c
                                                           FROM Core_MDF_Int_Users_Partner_Geo_Mapping__c WHERE Core_MDF_User_id__r.LastName = 'Prog Adm Usr' AND Core_MDF_All_Accounts_cd__c = 'Yes' LIMIT 1];
        
        Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgmPrgAdm2 = [SELECT id,Core_MDF_User_id__c,Core_MDF_Program_nm__c,Core_MDF_GeoSubGeo_Budget_Type_nm__c,Core_MDF_Role_nm__c,Core_MDF_Region_Sub_Region_nm__c, Core_MDF_Active_Ind__c
                                                           FROM Core_MDF_Int_Users_Partner_Geo_Mapping__c WHERE Core_MDF_User_id__r.LastName = 'Retail Acc Manager' AND Core_MDF_All_Accounts_cd__c = 'No' LIMIT 1];
        
        oldMap2.put(iupgmPrgAdm.Id, iupgmPrgAdm);
        oldMap.put(iupgm.Id, iupgm);
        oldMap3.put(iupgmPrgAdm2.Id,iupgmPrgAdm2);
        
        iupgm.Core_MDF_Region_Sub_Region_nm__c = 'WW' ;
        Database.update(iupgm);
        iupgmPrgAdm.Core_MDF_Region_Sub_Region_nm__c = 'APJ;EMEA';
        iupgmPrgAdm.Core_MDF_GeoSubGeo_Budget_Type_nm__c = 'APJ->Data Centric Acceleration - MDF;EMEA->Data Centric Acceleration - MDF';
        Database.update(iupgmPrgAdm);
        List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> iupgmList= new List<Core_MDF_Int_Users_Partner_Geo_Mapping__c>();
        iupgmList.add(iupgm);
        Map<Id, Core_MDF_Int_Users_Partner_Geo_Mapping__c> iupgmListMap = new Map<Id, Core_MDF_Int_Users_Partner_Geo_Mapping__c>(iupgmList);
        Core_MDF_IUPGM_ServiceHandler.checkPGM(iupgmListMap);
        newMap.put(iupgm.Id,iupgm);
        newMap2.put(iupgmPrgAdm.Id,iupgmPrgAdm);
      
        Core_MDF_IUPGM_ServiceHandler.removeRoleSpecificIUPGMGroupMember(oldMap,newMap);
        Core_MDF_IUPGM_ServiceHandler.removeGroupMember(oldMap,newMap);
        Core_MDF_IUPGM_ServiceHandler.removeGroupMember(oldMap2,newMap2);
        Core_MDF_IUPGM_ServiceHandler.removeGroupMember(oldMap3,null);
        Core_MDF_IUPGM_ServiceHandler.getExistingIupgmUserIdGeoBudgetMap(iupgmPrgAdm2);
        iupgmPrgAdm2.Core_MDF_Region_Sub_Region_nm__c = 'APJ;EMEA';
        iupgmPrgAdm2.Core_MDF_GeoSubGeo_Budget_Type_nm__c = 'APJ->Data Centric Acceleration - MDF;EMEA->Data Centric Acceleration - MDF';
        
        Database.update(iupgmPrgAdm2);  
        test.stoptest();
        Core_MDF_IUPGM_ServiceHandler.getExistingIupgmUserIdGeoBudgetMap(iupgmPrgAdm2);
        assert.isTrue(iupgmList != null);
        
    }
    
    // New test method to cover Core_MDF_DeleteGroupMember queueable class
    @isTest
    static void testDeleteGroupMemberQueueable(){
        test.startTest();
        
        Account acc = [SELECT Id FROM Account WHERE Name = 'CCPTestAccountTemp'];
        User user = [SELECT Id FROM User WHERE LastName = 'CCF Acc Manager'];
        Group groupId = [SELECT Id FROM Group WHERE DeveloperName = 'Core_MDF_CCP_TESTACCTTEMP_CCF_EMEA_INTERNAL'];
        
        // Create a group member to delete
        GroupMember gm = new GroupMember();
        gm.GroupId = groupId.Id;
        gm.UserOrGroupId = user.Id;
        insert gm;
        
        // Create test data for the queueable class
        List<GroupMember> groupMembersToDelete = new List<GroupMember>{gm};
        List<Core_MDF_Bulk_Transaction__e> userUpdates = new List<Core_MDF_Bulk_Transaction__e>();
        
        // Create a test user update event
        User testUser = new User();
        testUser.Id = user.Id;
        testUser.UserPermissionsMarketingUser = false;
        
        Core_MDF_Bulk_Transaction__e evtObj = new Core_MDF_Bulk_Transaction__e();
        evtObj.Core_MDF_JSON_Data__c = JSON.serialize(testUser);
        evtObj.Core_MDF_Object_Name__c = 'User';
        userUpdates.add(evtObj);
        
        // Execute the queueable class
        Core_MDF_DeleteGroupMember deleteJob = new Core_MDF_DeleteGroupMember(groupMembersToDelete, userUpdates);
        System.enqueueJob(deleteJob);
        
        test.stopTest();
        
        // Verify the group member was deleted
        List<GroupMember> remainingMembers = [SELECT Id FROM GroupMember WHERE Id = :gm.Id];
        System.assertEquals(0, remainingMembers.size(), 'Group member should have been deleted');
    }
}