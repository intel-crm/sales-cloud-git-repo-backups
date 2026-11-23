/****************************************************************************************************************************************
* Class Name        : Core_MDF_IUPGM_ServiceHandler_TestClone
* Created Date      : 07/29/2019
* Modification Log
* Developer            Date               Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture - VD       07/29/2019         Test Class for Core_MDF_IUPGM_ServiceHandler
* Accenture-  RK       12/09/2021         Modified Test class for Channel MDF program.
*****************************************************************************************************************************************/
@isTest(SeeAllData=false)
public class Core_MDF_IUPGM_ServiceHandler_TestClone {
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
            
            List<ChannelProgram> cpList = new List<ChannelProgram>();
            ChannelProgram ccfCp = Core_MDF_CCP_TestDataUtility.createProgram ('Client Co-Marketing Fund','Client CoMarketing Fund', false);
            ChannelProgram dcfCp = Core_MDF_CCP_TestDataUtility.createProgram ('Data Center Co-Marketing Fund','Data Center CoMarketing Fund', false);
            ChannelProgram retailCp = Core_MDF_CCP_TestDataUtility.createProgram ('Retail Marketing Funds','Retail Marketing Funds', false);
            ChannelProgram ipaCp = Core_MDF_CCP_TestDataUtility.createProgram ('Intel Partner Alliance','Intel Partner Alliance', false);
          
            //Added by Ravi 12/09/2021
            ChannelProgram cmdfCp = Core_MDF_CCP_TestDataUtility.createProgram ('Channel MDF','Channel MDF', false);
            // 12/09/2021
            cpList.add(ccfCp);
            cpList.add(dcfCp);
            cpList.add(retailCp);
            cpList.add(ipaCp);
            //Added by Ravi 12/09/2021
            cpList.add(cmdfCp);
            // 12/09/2021
            insert cpList;
            
            List<Account> intelAccList = new List<Account>();
            
            Account flipkartTestAccount = Core_MDF_CCP_TestDataUtility.createIntelAccount('FlipkartTestAccount', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
            Account myntraTestAccount = Core_MDF_CCP_TestDataUtility.createIntelAccount('MyntraTestAccount', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
            Account retailTestAccount = Core_MDF_CCP_TestDataUtility.createIntelAccount('RetailTestAccount', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
            retailTestAccount.Core_Geo__c ='APJ';
            retailTestAccount.Core_Sub_Geo__c ='SA';
            
            intelAccList.add(flipkartTestAccount);
            intelAccList.add(myntraTestAccount);
            intelAccList.add(retailTestAccount);
            database.insert(intelAccList);
            
            Group ccfgrp = new Group();
            ccfgrp.Name = 'CCP FLIPKARTT CCF EMEA INTERNAL';
            ccfgrp.DeveloperName = 'Core_MDF_CCP_FLIPKARTT_CCF_EMEA_INTERNAL';
            Database.insert(ccfgrp);
                        
            Core_MDF_Partner_Group_Mapping__c ccfPgm = new Core_MDF_Partner_Group_Mapping__c();
            ccfPgm.Core_MDF_Account__c = flipkartTestAccount.Id;
            ccfPgm.Core_MDF_Group_Name__c = 'Core_MDF_CCP_FLIPKARTT_CCF_EMEA_INTERNAL';
            ccfPgm.Core_MDF_Type_of_Access__c = 'Internal';
            //ccfPgm.Core_MDF_Group_Id__c = ccfgrp.Id;
            ccfPgm.Core_MDF_Channel_Program__c = ccfCp.Id;
            ccfPgm.Core_MDF_Region_cd__c = 'EMEA';
            ccfPgm.Core_MDF_Source_Txt__c = 'Test';            
            Database.insert(ccfPgm);
            //Added by Ravi 12/09/2021
             Group cmdfgrp = new Group();
            cmdfgrp.Name = 'CCP FLIPKARTT CMDF EMEA INTERNAL';
            cmdfgrp.DeveloperName = 'Core_MDF_CCP_FLIPKARTT_CMDF_EMEA_INTERNAL';
            Database.insert(cmdfgrp);
                        
            Core_MDF_Partner_Group_Mapping__c cmdfPgm = new Core_MDF_Partner_Group_Mapping__c();
            cmdfPgm.Core_MDF_Account__c = flipkartTestAccount.Id;
            cmdfPgm.Core_MDF_Group_Name__c = 'Core_MDF_CCP_FLIPKARTT_CMDF_EMEA_INTERNAL';
            cmdfPgm.Core_MDF_Type_of_Access__c = 'Internal';
            //ccfPgm.Core_MDF_Group_Id__c = ccfgrp.Id;
            cmdfPgm.Core_MDF_Channel_Program__c = ccfCp.Id;
            cmdfPgm.Core_MDF_Region_cd__c = 'EMEA';
            cmdfPgm.Core_MDF_Source_Txt__c = 'Test';  
            cmdfPgm.Core_MDF_BudgetType_nm__c='	Intel MDF Account Based1';
            Database.insert(cmdfPgm);
            //End 12/09/2021
                        
            
            Profile ccpCoreProfile = [SELECT Id FROM Profile WHERE Name = 'CCP - Core Access'];
            
            PermissionSet ccfAccManagerPS = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_CCF_Acct_Mgr' LIMIT 1];
            PermissionSet dcfAccManagerPS = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_DCF_Acct_Mgr' LIMIT 1];
            PermissionSet retailAccManagerPS = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_Retail_Account_Manager' LIMIT 1];
            PermissionSet readOnlyUsrPS = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Int_Read_Only' LIMIT 1];
            PermissionSet ipaAccManagerPS = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_IPA_Acct_Mgr' LIMIT 1];
            PermissionSet ipaProgAdmPS = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_IPA_Program_Adm' LIMIT 1];
      PermissionSet ipaApprPS = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Int_IPA_ProposalL1_Approver' LIMIT 1];
               //Added by Ravi 12/09/2021
            PermissionSet channelPS = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Core_MDF_Int_Channel_MDF_Acct_Mgr' LIMIT 1];
            PermissionSet channelPS1 = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_Channel_MDF_Budget_Approver' LIMIT 1];
            
               
               // End 12/09/2021
            
            
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
             //Added by Ravi 12/09/2021
             User cmdfAccManager = Core_MDF_CCP_TestDataUtility.createUser(false);
            cmdfAccManager.profileId = ccpCoreProfile.Id;
            cmdfAccManager.LastName = 'cmdf Account Manager';
            userList.add(cmdfAccManager);
             //End 12/09/2021
            
            insert userList;
            System.debug('userList@@'+userList);

            
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
            //Added by Ravi 12/09/2021
            PermissionSetAssignment psa10 = new PermissionSetAssignment(PermissionSetId = channelPS.Id, AssigneeId = cmdfAccManager.Id);
            permissionSetAssignmentList.add(psa10);
            PermissionSetAssignment psa11 = new PermissionSetAssignment(PermissionSetId = channelPS1.Id, AssigneeId = cmdfAccManager.Id);
            permissionSetAssignmentList.add(psa11);
            //End 12/09/2021
            insert permissionSetAssignmentList;
            
            
        }
    }
    
    @isTest
    static void pgmExists(){
        Account acc = [SELECT Id FROM Account WHERE Name = 'FlipkartTestAccount'];
        
        ChannelProgram cp = [SELECT Id FROM ChannelProgram WHERE Name = 'Client Co-Marketing Fund'];
        //Added by Ravi 12/09/2021
          ChannelProgram cpcmdf = [SELECT Id FROM ChannelProgram WHERE Name = 'Channel MDF'];
         User userCMDF = [SELECT Id FROM User WHERE LastName = 'cmdf Account Manager'];
        
        Group CmdfgroupId = [SELECT Id FROM Group WHERE DeveloperName = 'Core_MDF_CCP_FLIPKARTT_CMDF_EMEA_INTERNAL']; 
        System.debug('groupId@@'+CmdfgroupId);
        //End 12/09/2021
        User user = [SELECT Id FROM User WHERE LastName = 'CCF Acc Manager'];
        System.debug('user@@'+user);
        
        User ccfDcfuser = [SELECT Id FROM User WHERE LastName = 'CCF DCF Acc Manager'];
        
        User readOnlyuser = [SELECT Id FROM User WHERE LastName = 'Read Only Usr'];
        
        User pausr = [SELECT Id FROM User WHERE LastName = 'Prog Adm Usr'];
        
        Group groupId = [SELECT Id FROM Group WHERE DeveloperName = 'Core_MDF_CCP_FLIPKARTT_CCF_EMEA_INTERNAL']; 
        System.debug('groupId@@'+groupId);
        
        List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> iupgmList = new List<Core_MDF_Int_Users_Partner_Geo_Mapping__c>();
        List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> iupgmUpdateList = new List<Core_MDF_Int_Users_Partner_Geo_Mapping__c>();
        
        test.startTest();
        Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
        iupgm.Core_MDF_Account_id__c = acc.Id;
        iupgm.Core_MDF_Program_nm__c = 'Client CoMarketing Fund';
        iupgm.Core_MDF_Region_Sub_Region_nm__c = 'EMEA';
        iupgm.Core_MDF_User_id__c = user.Id;
        iupgm.Core_MDF_Role_nm__c = 'Core_MDF_CCP_Internal_CCF_Acct_Mgr';
        iupgm.Core_MDF_All_Accounts_cd__c = 'No';
        iupgmList.add(iupgm);
       
        
        Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm2 = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
        iupgm2.Core_MDF_Account_id__c = acc.Id;
        iupgm2.Core_MDF_Program_nm__c = 'Client CoMarketing Fund';
        iupgm2.Core_MDF_Region_Sub_Region_nm__c = 'EMEA';
        iupgm2.Core_MDF_User_id__c = ccfDcfuser.Id;
        iupgm2.Core_MDF_Role_nm__c = 'Core_MDF_CCP_Internal_CCF_Acct_Mgr';
        iupgm2.Core_MDF_All_Accounts_cd__c = 'No';
       iupgm2.Core_MDF_All_Budget_Type_Access_Ind__c=false;
        iupgm2.Core_MDF_GeoSubGeo_Budget_Type_nm__c='EMEA->Client Specialties MDF;EMEA->Data Center Specialties MDF';
        iupgmList.add(iupgm2);
        
        Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm3 = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();        
        iupgm3.Core_MDF_Program_nm__c = 'Data Center CoMarketing Fund';
        iupgm3.Core_MDF_Region_Sub_Region_nm__c = 'APJ';
        iupgm3.Core_MDF_User_id__c = ccfDcfuser.Id;
        iupgm3.Core_MDF_Role_nm__c = 'Core_MDF_CCP_Internal_DCF_Acct_Mgr';
        iupgm3.Core_MDF_All_Accounts_cd__c = 'Yes';
        
        iupgmList.add(iupgm3);
        
        Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm4 = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();        
        iupgm4.Core_MDF_Program_nm__c = 'Data Center CoMarketing Fund';
        iupgm4.Core_MDF_Region_Sub_Region_nm__c = 'WW';
        iupgm4.Core_MDF_User_id__c = readOnlyuser.Id;
        iupgm4.Core_MDF_Role_nm__c = 'Core_MDF_CCP_Int_Read_Only';
        iupgm4.Core_MDF_All_Accounts_cd__c = 'Yes';
        
        Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm5 = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();        
        iupgm5.Core_MDF_Program_nm__c = 'Intel Partner Alliance';
        iupgm5.Core_MDF_Region_Sub_Region_nm__c = 'ASMO-NAR;ASMO-LAR';
        iupgm5.Core_MDF_User_id__c = readOnlyuser.Id;
        iupgm5.Core_MDF_Role_nm__c = 'Core_MDF_CCP_Int_Read_Only';
        iupgm5.Core_MDF_All_Accounts_cd__c = 'Yes';
        iupgm5.Core_MDF_Active_Ind__c=true;
        //iupgm5.Core_MDF_Budget_Type_nm__c = 'Client Specialties MDF;Data Center Specialties MDF;Optane Specialties MDF';
        iupgm5.Core_MDF_GeoSubGeo_Budget_Type_nm__c = 'ASMO-NAR->Data Center Specialties MDF;ASMO-NAR->Client Specialties MDF';
        
        Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm6 = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
        iupgm6.Core_MDF_Program_nm__c = 'Intel Partner Alliance';
        iupgm6.Core_MDF_Region_Sub_Region_nm__c = 'ASMO-NAR;ASMO-LAR';
        iupgm6.Core_MDF_User_id__c = pausr.Id;
        iupgm6.Core_MDF_Role_nm__c = 'Core_MDF_CCP_Internal_IPA_Program_Adm';
        iupgm6.Core_MDF_All_Accounts_cd__c = 'Yes';
        iupgm6.Core_MDF_Budget_Type_nm__c = 'Data Center Specialties MDF';//Client Specialties MDF;Optane Specialties MDF';
        iupgm6.Core_MDF_GeoSubGeo_Budget_Type_nm__c = 'ASMO-LAR->Data Center Specialties MDF;ASMO-NAR->Data Center Specialties MDF';
        
    Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm7 = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
        iupgm7.Core_MDF_Program_nm__c = 'Intel Partner Alliance';
        iupgm7.Core_MDF_Region_Sub_Region_nm__c = 'PRC';
        iupgm7.Core_MDF_User_id__c = pausr.Id;
        iupgm7.Core_MDF_Role_nm__c = 'Core_MDF_CCP_Int_IPA_ProposalL1_Approver';
        iupgm7.Core_MDF_All_Accounts_cd__c = 'Yes';
        iupgm7.Core_MDF_Budget_Type_nm__c = 'Data Center Specialties MDF';//Client Specialties MDF;Optane Specialties MDF';
        iupgm7.Core_MDF_GeoSubGeo_Budget_Type_nm__c = 'PRC->Data Center Specialties MDF';
        //iupgm7.Core_MDF_CMDF_GeoSubGeo_BudgetType_nm__c='PRC->Intel MDF Account Based2';
        //Added by Ravi 12/09/2021
        Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm8 = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
        iupgm8.Core_MDF_Program_nm__c = 'Channel MDF';
        //iupgm8.Core_MDF_Region_Sub_Region_nm__c = 'PRC';
        iupgm8.Core_MDF_Account_id__c=acc.id;
        iupgm8.Core_MDF_All_Budget_Type_Access_Ind__c=false;
        //iupgm8.Core_MDF_channel_MDF_GeoSubGeo_Bdgt_Type__c='ASMO-NAR->Intel MDF Proposal Based2';
        iupgm8.Core_MDF_User_id__c = userCMDF.Id;
        //iupgm8.Core_MDF_CMDF_GeoSubGeo_BudgetType_nm__c='ASMO-LAR->Intel MDF Account Based1';
        iupgm8.Core_MDF_Role_nm__c = 'Core_MDF_Int_Channel_MDF_Acct_Mgr';
        iupgm8.Core_MDF_All_Accounts_cd__c = 'No';
       // iupgm8.Core_MDF_Budget_Type_nm__c = 'Data Center Specialties MDF';//Client Specialties MDF;Optane Specialties MDF';
        iupgmList.add(iupgm8); 

        //End 12/09/2021
                        
        iupgmList.add(iupgm4);
        iupgmList.add(iupgm5);
        iupgmList.add(iupgm6);
        iupgmList.add(iupgm7); 
        insert iupgmList;
        system.debug('iupgmList@@'+iupgmList);
          Core_MDF_Int_Users_Partner_Geo_Mapping__c UpdateIUPGM=[Select Id,Core_MDF_Program_nm__c,Core_MDF_All_Budget_Type_Access_Ind__c from Core_MDF_Int_Users_Partner_Geo_Mapping__c
                                                               where Core_MDF_Program_nm__c = 'Channel MDF'AND  Core_MDF_Role_nm__c = 'Core_MDF_Int_Channel_MDF_Acct_Mgr'  ];
         
         //UpdateIUPGM.Core_MDF_CMDF_GeoSubGeo_BudgetType_nm__c='ASMO-LAR->Intel MDF Account Based2;ASMO-NAR->Intel MDF Account Based1';
          UpdateIUPGM.Core_MDF_All_Budget_Type_Access_Ind__c=True;
        UpdateIUPGM.Core_MDF_Active_Ind__c=false;
          Database.update(UpdateIUPGM);
        Core_MDF_Int_Users_Partner_Geo_Mapping__c UpdateIUPGM1=[Select Id,Core_MDF_Program_nm__c,Core_MDF_All_Budget_Type_Access_Ind__c from Core_MDF_Int_Users_Partner_Geo_Mapping__c
                                                               where Core_MDF_Program_nm__c = 'Channel MDF'AND  Core_MDF_Role_nm__c = 'Core_MDF_Int_Channel_MDF_Acct_Mgr'  ];
          UpdateIUPGM1.Core_MDF_All_Budget_Type_Access_Ind__c=False;
          Database.update(UpdateIUPGM1);

        Core_MDF_Int_Users_Partner_Geo_Mapping__c UpdateIUPGM2=[Select Id,Core_MDF_Program_nm__c,Core_MDF_GeoSubGeo_Budget_Type_nm__c from Core_MDF_Int_Users_Partner_Geo_Mapping__c
                                                               where Core_MDF_Program_nm__c = 'Intel Partner Alliance'AND  Core_MDF_Role_nm__c = 'Core_MDF_CCP_Int_Read_Only'  ];
        UpdateIUPGM2.Core_MDF_GeoSubGeo_Budget_Type_nm__c = 'ASMO-LAR->Data Center Specialties MDF;ASMO-LAR->Client Specialties MDF';
        Database.update(UpdateIUPGM2);
        //Added by Ravi 12/24/2021
        List<String> geoSubGeoStringList = new List<String>();
        geoSubGeoStringList.add('ASMO');
        geoSubGeoStringList.add('APJ');
        geoSubGeoStringList.add('ASMO-LAR');
        
        String accountName='Test Acc';
        String programName='CMDF';
        String budgetType='Client Specialties MDF';
        Core_MDF_IUPGM_ServiceHandler.geoSubGeoWrapper gsg = new Core_MDF_IUPGM_ServiceHandler.geoSubGeoWrapper();
        gsg=Core_MDF_IUPGM_ServiceHandler.getAccProgramGeoSubGeo(geoSubGeoStringList,accountName, programName,budgetType);
            //End 12/24/2021
        test.stopTest();
        
        /*GroupMember newGM = [SELECT Id, GroupId, UserOrGroupId FROM GroupMember WHERE GroupId =: groupId.Id AND UserOrGroupId =: user.Id];
        System.debug('newGM@@'+newGM);
        
        System.assert(newGM != NULL); */
        iupgm4.Core_MDF_Region_Sub_Region_nm__c = 'APJ';
        iupgmUpdateList.add(iupgm4);
        //iupgm5.Core_MDF_Budget_Type_nm__c ='Client Specialties MDF;Data Center Specialties MDF';
        iupgm5.Core_MDF_Region_Sub_Region_nm__c = 'ASMO-NAR';
        //iupgm5.Core_MDF_GeoSubGeo_Budget_Type_nm__c = 'ASMO-LAR->Data Center Specialties MDF';
        iupgm5.Core_MDF_Active_Ind__c = FALSE;
        iupgmUpdateList.add(iupgm5);
        
        iupgm6.Core_MDF_Budget_Type_nm__c ='Data Center Specialties MDF';
        iupgm6.Core_MDF_Region_Sub_Region_nm__c = 'ASMO-LAR;APJ';
        iupgm6.Core_MDF_GeoSubGeo_Budget_Type_nm__c = 'ASMO-LAR->Data Center Specialties MDF;APJ->Data Center Specialties MDF';
        iupgm6.Core_MDF_Active_Ind__c = FALSE;
        iupgmUpdateList.add(iupgm6);
        update iupgmUpdateList;
    system.debug('iupgmUpdateList@@'+iupgmUpdateList);
    }
    
    @isTest
    static void pgmIsAbsent(){
        Account acc = [SELECT Id FROM Account WHERE Name = 'MyntraTestAccount'];
        
        ChannelProgram cp = [SELECT Id FROM ChannelProgram WHERE Name = 'Data Center Co-Marketing Fund'];
        
        User user = [SELECT Id FROM User WHERE LastName = 'DCF Acc Manager'];
        User user2 = [SELECT Id FROM User WHERE LastName = 'Retail Acc Manager'];
       
        
        Group dcfgrp = new Group();
        dcfgrp.Name = 'CCP MYNTRATES DCF ASMO INTERNAL';
        dcfgrp.DeveloperName = 'Core_MDF_CCP_MYNTRATES_DCF_ASMO_INTERNAL';
        Database.insert(dcfgrp);        
        
        test.startTest();
        List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> iupgmList=new List<Core_MDF_Int_Users_Partner_Geo_Mapping__c>();
        Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
        iupgm.Core_MDF_Account_id__c = acc.Id;
        iupgm.Core_MDF_Program_nm__c = 'Data Center CoMarketing Fund';
        iupgm.Core_MDF_Region_Sub_Region_nm__c = 'ASMO';
        iupgm.Core_MDF_User_id__c = user.Id;
        iupgm.Core_MDF_Role_nm__c = 'Core_MDF_CCP_Internal_DCF_Acct_Mgr';
        iupgm.Core_MDF_All_Accounts_cd__c = 'No';
        iupgmList.add(iupgm);
        
        Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm2 = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
        iupgm2.Core_MDF_Account_id__c = acc.Id;
        iupgm2.Core_MDF_Program_nm__c = 'Intel Partner Alliance';
        iupgm2.Core_MDF_Region_Sub_Region_nm__c = 'ASMO-NAR;ASMO-LAR';
        iupgm2.Core_MDF_User_id__c = user2.Id;
        iupgm2.Core_MDF_Role_nm__c = 'Core_MDF_CCP_Internal_IPA_Acct_Mgr';
        iupgm2.Core_MDF_All_Accounts_cd__c = 'No';
        //iupgm2.Core_MDF_Budget_Type_nm__c = 'Client Specialties MDF;Data Center Specialties MDF;Optane Specialties MDF';
        //iupgm2.Core_MDF_GeoSubGeo_Budget_Type_nm__c = 'ASMO-NAR->Data Center Specialties MDF;ASMO-LAR->Data Center Specialties MDF';
        iupgmList.add(iupgm2);
                
        insert iupgmList;
         //Added by Ravi 12/24/2021
        List<String> geoSubGeoStringList = new List<String>();
        geoSubGeoStringList.add('ASMO');
        geoSubGeoStringList.add('APJ');
        geoSubGeoStringList.add('ASMO-LAR');
        
        String accountName='Test Acc';
        String programName='CMDF';
        String budgetType='';
        Core_MDF_IUPGM_ServiceHandler.geoSubGeoWrapper gsg = new Core_MDF_IUPGM_ServiceHandler.geoSubGeoWrapper();
        gsg=Core_MDF_IUPGM_ServiceHandler.getAccProgramGeoSubGeo(geoSubGeoStringList,accountName, programName,budgetType);
        
        List<String> geoSubGeoStringList1 = new List<String>();
        geoSubGeoStringList1.add('ASMO');
        geoSubGeoStringList1.add('APJ');
        //geoSubGeoStringList1.add('ASMO-LAR');
        
        String accountName1='Test Acc';
        String programName1='CMDF';
        String budgetType1='';
        Core_MDF_IUPGM_ServiceHandler.geoSubGeoWrapper gsg1 = new Core_MDF_IUPGM_ServiceHandler.geoSubGeoWrapper();
        gsg1=Core_MDF_IUPGM_ServiceHandler.getAccProgramGeoSubGeo(geoSubGeoStringList1,accountName1, programName1,budgetType1);
        
        List<String> geoSubGeoStringList2 = new List<String>();
        geoSubGeoStringList2.add('ASMO');
        geoSubGeoStringList2.add('APJ');
        //geoSubGeoStringList1.add('ASMO-LAR');
        
        String accountName2='Test Acc';
        String programName2='CMDF';
        String budgetType2='';
        Core_MDF_IUPGM_ServiceHandler.geoSubGeoWrapper gsg2 = new Core_MDF_IUPGM_ServiceHandler.geoSubGeoWrapper();
        gsg2=Core_MDF_IUPGM_ServiceHandler.getAccProgramGeoSubGeo(geoSubGeoStringList2,accountName2, programName2,budgetType2);
        
        List<String> geoSubGeoStringList3 = new List<String>();
        geoSubGeoStringList3.add('ASMO');
        geoSubGeoStringList3.add('APJ');
        //geoSubGeoStringList1.add('ASMO-LAR');
        
        String accountName3='Test Acc';
        String programName3='CMDF';
        String budgetType3 ='_ALL';
        Core_MDF_IUPGM_ServiceHandler.geoSubGeoWrapper gsg3 = new Core_MDF_IUPGM_ServiceHandler.geoSubGeoWrapper();
        gsg3=Core_MDF_IUPGM_ServiceHandler.getAccProgramGeoSubGeo(geoSubGeoStringList3,accountName3, programName3,budgetType3);
        
        
           //End 12/24/2021
        test.stopTest();
        
        /*GroupMember newGM = [SELECT Id, GroupId, UserOrGroupId FROM GroupMember WHERE UserOrGroupId =: user.Id LIMIT 1];
        
        System.assert(newGM != NULL);*/
        
        Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgmUpdated = [SELECT Id, Core_MDF_Active_Ind__c 
                                                                  FROM Core_MDF_Int_Users_Partner_Geo_Mapping__c 
                                                                  WHERE Core_MDF_Account_id__c =: acc.Id AND 
                                                                  Core_MDF_Program_nm__c='Intel Partner Alliance' ];//Data Center CoMarketing Fund
        
        iupgmUpdated.Core_MDF_Active_Ind__c = false;
        iupgmUpdated.Core_MDF_Region_Sub_Region_nm__c = 'ASMO-NAR';
        //iupgmUpdated.Core_MDF_Budget_Type_nm__c = 'Client Specialties MDF;Data Center Specialties MDF';
        update iupgmUpdated;
    }
    
   @isTest
    static void iupgmWithSubRegion(){
    
        List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> iupgmList = new List<Core_MDF_Int_Users_Partner_Geo_Mapping__c>();

        Account acc = [SELECT Id FROM Account WHERE Name = 'FlipkartTestAccount'];

        Account retailAcc = [SELECT Id FROM Account WHERE Name = 'RetailTestAccount' limit 1];
        
        ChannelProgram retailCp = [SELECT Id FROM ChannelProgram WHERE Name = 'Retail Marketing Funds'];   
        //Added by Ravi 12/09/2021
           ChannelProgram cmdfCp = [SELECT Id FROM ChannelProgram WHERE Name = 'Channel MDF'];
        //End 12/09/2021
        
        Account retailCoMarketingAccount = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Retail Co-Marketing Account', 
                                                                                                 retailCp.id, 
                                                                                                 Core_MDF_CCP_TestDataUtility.Account_Record_Type,
                                                                                                 retailAcc.id, false); 
        retailCoMarketingAccount.Core_Geo__c ='APJ';
        retailCoMarketingAccount.Core_Sub_Geo__c ='SA';
        insert retailCoMarketingAccount;
        
        User retailUser = [SELECT Id FROM User WHERE LastName = 'Retail Acc Manager'];
        //Added by Ravi 12/09/2021
           User cmdfUser = [SELECT Id FROM User WHERE LastName = 'cmdf Account Manager'];
        //End 12/09/2021
        
        Test.startTest();
        Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
        iupgm.Core_MDF_Account_id__c = retailCoMarketingAccount.Id;
        iupgm.Core_MDF_User_id__c = retailUser.Id;
        iupgm.Core_MDF_Program_nm__c = 'Retail Marketing Funds';        
        iupgm.Core_MDF_Role_nm__c = 'Core_MDF_CCP_Internal_Retail_Account_Manager';
        iupgm.Core_MDF_All_Accounts_cd__c = 'No';
        iupgmList.add(iupgm);
        
        User userInactive = [SELECT Id FROM User WHERE LastName = 'Inactive CCF Acc Manager'];

        Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm1 = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
        iupgm1.Core_MDF_Account_id__c = acc.Id;
        iupgm1.Core_MDF_Program_nm__c = 'Client CoMarketing Fund';
        iupgm1.Core_MDF_Region_Sub_Region_nm__c = 'EMEA';
        iupgm1.Core_MDF_User_id__c = userInactive.Id;
        iupgm1.Core_MDF_Role_nm__c = 'Core_MDF_CCP_Internal_CCF_Acct_Mgr';
        iupgm1.Core_MDF_All_Accounts_cd__c = 'No';
        iupgmList.add(iupgm1);
        //Added by Ravi 12/09/2021
         Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm2 = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
        iupgm2.Core_MDF_Program_nm__c = 'Channel MDF';
        iupgm2.Core_MDF_Region_Sub_Region_nm__c = 'PRC';
        iupgm2.Core_MDF_Account_id__c=acc.id;
        iupgm2.Core_MDF_All_Budget_Type_Access_Ind__c=true;
        //iupgm2.Core_MDF_channel_MDF_GeoSubGeo_Bdgt_Type__c='PRC->Data Center Specialties MDF';
        iupgm2.Core_MDF_User_id__c = cmdfUser.Id;
        iupgm2.Core_MDF_Role_nm__c = 'Core_MDF_Int_Channel_MDF_Acct_Mgr';
        iupgm2.Core_MDF_All_Accounts_cd__c = 'No';
        iupgmList.add(iupgm2);
        //End 12/09/2021
        insert iupgmList;
        Test.stopTest();
        
        Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgmInactive = [SELECT Id,Core_MDF_Active_Ind__c
                                                                   FROM Core_MDF_Int_Users_Partner_Geo_Mapping__c 
                                                                   WHERE Core_MDF_Program_nm__c = 'Retail Marketing Funds'];
        iupgmInactive.Core_MDF_Active_Ind__c = FALSE;
        update iupgmInactive;
        /*Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgmUpdated2 = [SELECT Id, Core_MDF_Active_Ind__c 
                                                                  FROM Core_MDF_Int_Users_Partner_Geo_Mapping__c 
                                                                  WHERE Core_MDF_GeoSubGeo_Budget_Type_nm__c != NULL AND 
                                                                  Core_MDF_Program_nm__c='Intel Partner Alliance' Limit 1];*/
        List<Core_MDF_Partner_Group_Mapping__c> pgm = [SELECT Id 
                                                       FROM Core_MDF_Partner_Group_Mapping__c 
                                                       WHERE Core_MDF_Account__c =: acc.Id AND
                                                       Core_MDF_Channel_Program__r.Name = 'Client Co-Marketing Fund' AND
                                                       Core_MDF_Region_cd__c = 'EMEA'];        
        //System.assert(pgm.Size() == 1 );   
    }
    
   @isTest
    static void activateIUPGM(){
        Account acc = [SELECT Id FROM Account WHERE Name = 'FlipkartTestAccount'];
        
        ChannelProgram cp = [SELECT Id FROM ChannelProgram WHERE Name = 'Client Co-Marketing Fund'];
        
        User user = [SELECT Id FROM User WHERE LastName = 'CCF Acc Manager'];
        
        User dcfuser = [SELECT Id FROM User WHERE LastName = 'DCF Acc Manager'];
        
        Group groupId = [SELECT Id FROM Group WHERE DeveloperName = 'Core_MDF_CCP_FLIPKARTT_CCF_EMEA_INTERNAL'];
       
        test.startTest();
        
        Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
        iupgm.Core_MDF_Account_id__c = acc.Id;
        iupgm.Core_MDF_Program_nm__c = 'Client CoMarketing Fund';
        iupgm.Core_MDF_Region_Sub_Region_nm__c = 'EMEA';
        iupgm.Core_MDF_User_id__c = user.Id;
        iupgm.Core_MDF_Role_nm__c = 'Core_MDF_CCP_Internal_CCF_Acct_Mgr';
        iupgm.Core_MDF_All_Accounts_cd__c = 'No';
        insert iupgm;
        
        Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm3 = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();        
        iupgm3.Core_MDF_Program_nm__c = 'Data Center CoMarketing Fund';
        iupgm3.Core_MDF_Region_Sub_Region_nm__c = 'APJ';
        iupgm3.Core_MDF_User_id__c = dcfuser.Id;
        iupgm3.Core_MDF_Role_nm__c = 'Core_MDF_CCP_Internal_DCF_Acct_Mgr';
        iupgm3.Core_MDF_All_Accounts_cd__c = 'Yes';
        insert iupgm3;
        
        iupgm3.Core_MDF_Region_Sub_Region_nm__c = 'PRC';
        update iupgm3;
        //Added by Ravi 12/24/2021
        Core_MDF_IUPGM_ServiceHandler.queryMetadataForMasterGroup();
        //End 12/24/2021
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
        
        List<GroupMember> newGM = [SELECT Id, GroupId, UserOrGroupId 
                             FROM GroupMember 
                             WHERE GroupId =: groupId.Id AND UserOrGroupId =: user.Id LIMIT 1];        
        System.assert(newGM != NULL);
    }
    @isTest
    static void pgmExistsCmdf(){
        Account acc = [SELECT Id FROM Account WHERE Name = 'FlipkartTestAccount'];
        
               
          ChannelProgram cpcmdf = [SELECT Id FROM ChannelProgram WHERE Name = 'Channel MDF'];
         User userCMDF = [SELECT Id FROM User WHERE LastName = 'cmdf Account Manager'];
         User dcfuser = [SELECT Id FROM User WHERE LastName = 'DCF Acc Manager'];
        Group CmdfgroupId = [SELECT Id FROM Group WHERE DeveloperName = 'Core_MDF_CCP_FLIPKARTT_CMDF_EMEA_INTERNAL']; 
        System.debug('groupId@@'+CmdfgroupId);
       
        
        
        Group groupId = [SELECT Id FROM Group WHERE DeveloperName = 'Core_MDF_CCP_FLIPKARTT_CCF_EMEA_INTERNAL']; 
        System.debug('groupId@@'+groupId);
        
        List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> iupgmList = new List<Core_MDF_Int_Users_Partner_Geo_Mapping__c>();
        List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> iupgmUpdateList = new List<Core_MDF_Int_Users_Partner_Geo_Mapping__c>();
        
        test.startTest();
        Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
        iupgm.Core_MDF_Account_id__c = acc.Id;
        iupgm.Core_MDF_Program_nm__c = 'Channel MDF';
        iupgm.Core_MDF_Region_Sub_Region_nm__c = 'EMEA';
        iupgm.Core_MDF_User_id__c = userCMDF.Id;
        iupgm.Core_MDF_Role_nm__c = 'Core_MDF_Int_Channel_MDF_Acct_Mgr';
        iupgm.Core_MDF_All_Accounts_cd__c = 'No';
        //iupgmList.add(iupgm);
        Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm3 = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();        
        iupgm3.Core_MDF_Program_nm__c = 'Data Center CoMarketing Fund';
        iupgm3.Core_MDF_Region_Sub_Region_nm__c = 'APJ';
        //iupgm3.Core_MDF_Account_id__c=acc.id;
        iupgm3.Core_MDF_User_id__c = dcfuser.Id;
        iupgm3.Core_MDF_Role_nm__c = 'Core_MDF_CCP_Internal_DCF_Acct_Mgr';
        iupgm3.Core_MDF_All_Accounts_cd__c = 'Yes';
         iupgm3.Core_MDF_All_Budget_Type_Access_Ind__c=False;
        iupgm3.Core_MDF_GeoSubGeo_Budget_Type_nm__c='APJ->Client Specialties MDF';
        //iupgm3.Core_MDF_CMDF_GeoSubGeo_BudgetType_nm__c='APJ->Intel MDF Account Based2';
        iupgmList.add(iupgm3);
        
         Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm2 = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
        //iupgm2.Core_MDF_Program_nm__c = 'Channel MDF';
        iupgm2.Core_MDF_Program_nm__c = 'Channel MDF';
        iupgm2.Core_MDF_Region_Sub_Region_nm__c = 'PRC';
        iupgm2.Core_MDF_Account_id__c=acc.id;
        iupgm2.Core_MDF_All_Budget_Type_Access_Ind__c=False;
        //iupgm2.Core_MDF_channel_MDF_GeoSubGeo_Bdgt_Type__c='ASMO-LAR->Client Specialties MDF';
        //iupgm2.Core_MDF_channel_MDF_GeoSubGeo_Bdgt_Type__c='ASMO-LAR->Client Specialties MDF';
        iupgm2.Core_MDF_User_id__c = userCMDF.Id;
        iupgm2.Core_MDF_Role_nm__c = 'Core_MDF_CCP_Internal_Channel_MDF_Budget_Approver';
        iupgm2.Core_MDF_All_Accounts_cd__c = 'No';
        iupgm2.Core_MDF_Sub_Region_cd__c='LAR';
        iupgm2.Core_MDF_Budget_Type_nm__c='Client Specialties MDF';
        //iupgm2.Core_MDF_CMDF_GeoSubGeo_BudgetType_nm__c='PRC->Intel MDF Account Based2;PRC->Intel MDF Account Based1';
       
        iupgmList.add(iupgm2);
   
       insert iupgmList;  
        system.debug('iupgmList@@'+iupgmList);
        //Added by Ravi 12/24/2021
        List<String> geoSubGeoStringList = new List<String>();
        geoSubGeoStringList.add('ASMO');
        geoSubGeoStringList.add('APJ');
        geoSubGeoStringList.add('ASMO-LAR');
        
        String accountName='Test Acc';
        String programName='CMDF';
        String budgetType='Client Specialties MDF';
        Core_MDF_IUPGM_ServiceHandler.geoSubGeoWrapper gsg = new Core_MDF_IUPGM_ServiceHandler.geoSubGeoWrapper();
        gsg=Core_MDF_IUPGM_ServiceHandler.getAccProgramGeoSubGeo(geoSubGeoStringList,accountName, programName,budgetType);
            //End 12/24/2021
            
            System.assertNotEquals(Null, Core_MDF_IUPGM_ServiceHandler.programGeoSubGeoBudgetMap);
        
            //Core_MDF_IUPGM_ServiceHandler.checkPGM(iupgmList);
        
                        
        test.stopTest();
                
        
    }
    @isTest
    static void pgmExistsCmdf1(){
        User us = [SELECT Id,LastName, isActive FROM User WHERE profile.Name = 'System Administrator' and isActive=true limit 1];
        System.runAs(us)
        {
            
        
             Account acc = [SELECT Id,Name FROM Account WHERE Name = 'FlipkartTestAccount'];
              System.debug('acc id'+acc.id +acc.Name);
               
          ChannelProgram cpcmdf1 = [SELECT Id,Name FROM ChannelProgram WHERE Name = 'Channel MDF'];
            System.debug('cpcmdf id'+cpcmdf1.id +cpcmdf1.Name);
         User userCMDF1 = [SELECT Id,LastName FROM User WHERE LastName = 'cmdf Account Manager'];
        
            System.debug('userCMDF id'+userCMDF1.id +userCMDF1.LastName);
            
        Group CmdfgroupId1 = [SELECT Id,DeveloperName FROM Group WHERE DeveloperName = 'Core_MDF_CCP_FLIPKARTT_CMDF_EMEA_INTERNAL']; 
        System.debug('groupId@@'+CmdfgroupId1);
            System.debug('groupId@@ devname'+CmdfgroupId1.DeveloperName);
            
             List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> iupgmList = new List<Core_MDF_Int_Users_Partner_Geo_Mapping__c>();
        List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> iupgmUpdateList = new List<Core_MDF_Int_Users_Partner_Geo_Mapping__c>();
        
        
        Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
        //iupgm.Core_MDF_Account_id__c = acc.Id;
        iupgm.Core_MDF_Program_nm__c = 'Channel MDF';
        //iupgm.Core_MDF_Region_Sub_Region_nm__c = 'EMEA';
        //iupgm.Core_MDF_CMDF_GeoSubGeo_BudgetType_nm__c='ASMO-LAR->Intel MDF Account Based2';
        iupgm.Core_MDF_User_id__c = userCMDF1.Id;
        iupgm.Core_MDF_Region_Sub_Region_nm__c='ASMO-NAR';
       // iupgm.Core_MDF_Role_nm__c = 'Core_MDF_Int_Channel_MDF_Acct_Mgr';
        //iupgm.Core_MDF_Role_nm__c= 'Core_MDF_CCP_Internal_Channel_MDF_Budget_Approver';
       // iupgm.Core_MDF_All_Accounts_cd__c = 'No';
          iupgm.Core_MDF_All_Accounts_cd__c = 'Yes';
        
        GroupMember gm = new  GroupMember();
        gm.GroupId= CmdfgroupId1.id;
        gm.UserOrGroupId=userCMDF1.id;
         test.startTest();
        insert gm;
            
        //iupgmList.add(iupgm);
       
            insert iupgm;
        test.stopTest();
       
       }
            
        
    }
    
}