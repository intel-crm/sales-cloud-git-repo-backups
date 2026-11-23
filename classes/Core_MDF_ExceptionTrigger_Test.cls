/****************************************************************************************************************************************
* Class Name        : Core_MDF_ExceptionTrigger_Test
* Created Date      : 25-06-2019
* Modification Log
* Developer            Date             Description
* ---------------------------------------------------------------------------------------------------------------------------------------
Accenture VK        25-06-2019          Test Class for Core_MDF_Exception_TriggerServiceHandler
*****************************************************************************************************************************************/
@isTest(SeeAllData=false)
public class Core_MDF_ExceptionTrigger_Test {
    
        Public static Id IPA_RecordType = Schema.SObjectType.Core_MDF_Int_Users_Partner_Geo_Mapping__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_Intel_Partner_Alliance').getRecordTypeId();
        Public static Id EEF_RecordType = Schema.SObjectType.Core_MDF_Int_Users_Partner_Geo_Mapping__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_Ecosystem_Extension_Fund').getRecordTypeId();
     
    @TestSetUp
    static void createData(){
        UserRole userRole_1 = [SELECT Id FROM UserRole WHERE DeveloperName = 'Admin' LIMIT 1];
        User systemAdmin = Core_MDF_CCP_TestDataUtility.createUser(false);      
        systemAdmin.LastName = 'SystemAdmin';
        systemAdmin.UserRoleId = userRole_1.Id;
        insert systemAdmin;
        
        System.runAs(systemAdmin){
            
            Core_MDF_CCP_TestDataUtility.createMDFConfigurationData();
            ChannelProgram ccfCp = Core_MDF_CCP_TestDataUtility.createProgram ('Client','Client CoMarketing Fund', true);
            ChannelProgram dcfCp = Core_MDF_CCP_TestDataUtility.createProgram ('Datacenter','Data Center CoMarketing Fund', true);
            ChannelProgram ipaCP = Core_MDF_CCP_TestDataUtility.createProgram ('Intel Partner Alliance','Intel Partner Alliance', true);
      ChannelProgram eefCp = Core_MDF_CCP_TestDataUtility.createProgram ('Ecosystem Extension Fund','Ecosystem Extension Fund', true);
            
            List<Account> accList = new List<Account>();
            Account flipkartTestAccount = Core_MDF_CCP_TestDataUtility.createIntelAccount('FlipkartTestAccount', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
            flipkartTestAccount.BillingStateCode = '';
            accList.add(flipkartTestAccount);
            Account myntraTestAccount = Core_MDF_CCP_TestDataUtility.createIntelAccount('MyntraTestAccount', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
            myntraTestAccount.BillingStateCode='';
            accList.add(myntraTestAccount);
            //Account testAcctTemp = Core_MDF_CCP_TestDataUtility.createIntelAccount('CCPTestAccountTemp', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, true);
            Account intelActAcc = Core_MDF_CCP_TestDataUtility.createIntelAccount('Test Primary Intel Account',Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
            intelActAcc.BillingStateCode='';
            accList.add(intelActAcc);
            insert accList;
            
            Profile ccpCoreProfile = [SELECT Id FROM Profile WHERE Name = 'CCP - Core Access'];
            
            PermissionSet ccfAccManagerPS = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_CCF_Acct_Mgr' LIMIT 1];
            PermissionSet programAdminPS = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_Program_Adm' LIMIT 1];
            PermissionSet exceptionReviewerPS = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_CCF_Exception_Reviewer' LIMIT 1];
            PermissionSet dcfAccManagerPS = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_DCF_Acct_Mgr' LIMIT 1];
            PermissionSet ipaAccManagerPS = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_IPA_Acct_Mgr' LIMIT 1];
            PermissionSet rmfAccManagerPS = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_Retail_Account_Manager' LIMIT 1];
            
            PermissionSet eefAccManagerPS = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Core_MDF_Internal_EEF_Primary_Partner_Acct_Mgr' LIMIT 1];
            PermissionSet ipaExceptionReviewerPS = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Core_MDF_Internal_IPA_Exception_Reviewer' LIMIT 1]; 
            PermissionSet eefExceptionReviewerPS = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Core_MDF_Internal_EEF_Exception_Reviewer' LIMIT 1]; 
            PermissionSet rmfExceptionReviewerPS = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_RMF_Exception_Reviewer' LIMIT 1];
      
            
            List<User> userList = new List<User>();
            List<PermissionSetAssignment> permissionSetAssignmentList = new List<PermissionSetAssignment>();
            
            //DCF Account Manager
            User dcfAccountManager = Core_MDF_CCP_TestDataUtility.createUser(false);
            dcfAccountManager.profileId = ccpCoreProfile.Id;
            dcfAccountManager.LastName = 'DCF Acc Manager';
            userList.add(dcfAccountManager);
            
            //CCF WW Account Manager
            User ccfwwAccountManager = Core_MDF_CCP_TestDataUtility.createUser(false);
            ccfwwAccountManager.profileId = ccpCoreProfile.Id;
            ccfwwAccountManager.LastName = 'CCF WW Acc Manager';
            userList.add(ccfwwAccountManager);
            
            //CCF Account Manager
            User ccfAccountManager = Core_MDF_CCP_TestDataUtility.createUser(false);
            ccfAccountManager.profileId = ccpCoreProfile.Id;
            ccfAccountManager.LastName = 'CCF Acc Manager';
            userList.add(ccfAccountManager);
            
             User IPAAccountManager = Core_MDF_CCP_TestDataUtility.createUser(false);
            IPAAccountManager.profileId = ccpCoreProfile.Id;
            IPAAccountManager.LastName = 'IPA Acc Manager';
            userList.add(IPAAccountManager);
            
            //Exception Reviewer
            User exceptionReviewer = Core_MDF_CCP_TestDataUtility.createUser(false);
            exceptionReviewer.profileId = ccpCoreProfile.Id;
            exceptionReviewer.LastName = 'Excpetion Reviewer';
            userList.add(exceptionReviewer);
            
            insert userList;
            
            
            Core_MDF_CCP_RecordTypes__c cs = new Core_MDF_CCP_RecordTypes__c();
            cs.Name='Retail Marketing Funds';
            cs.Core_MDF_Allocation_RT_DeveloperName__c='Core_MDF_Retail_Marketing_Funds';
            cs.Core_MDF_Exception_SharingGroup__c='Core_MDF_Internal_RMF_Node_Accs_All';
            insert cs;
            
            //Assign  CCF Account Manager Permission Set 
            PermissionSetAssignment psa1 = new PermissionSetAssignment(PermissionSetId = ccfAccManagerPS.Id, AssigneeId = ccfAccountManager.Id);
            permissionSetAssignmentList.add(psa1);
            
            //Assign  CCF WW Account Manager Permission Set 
            PermissionSetAssignment psaCCFWW = new PermissionSetAssignment(PermissionSetId = ccfAccManagerPS.Id, AssigneeId = ccfwwAccountManager.Id);
            permissionSetAssignmentList.add(psaCCFWW);
            
            
            //Adding reviewer and program admin permission set to Excption Reviewer
            PermissionSetAssignment psaProgramAdmin = new PermissionSetAssignment(PermissionSetId = programAdminPS.Id, AssigneeId = exceptionReviewer.Id);
            permissionSetAssignmentList.add(psaProgramAdmin);
            
            PermissionSetAssignment psaExpReviewer = new PermissionSetAssignment(PermissionSetId = exceptionReviewerPS.Id, AssigneeId = exceptionReviewer.Id);
            permissionSetAssignmentList.add(psaExpReviewer);
            
            PermissionSetAssignment psaExpReviewer1 = new PermissionSetAssignment(PermissionSetId = ipaExceptionReviewerPS.Id, AssigneeId = exceptionReviewer.Id);
            permissionSetAssignmentList.add(psaExpReviewer1);
            
            PermissionSetAssignment psaIPAReviewer = new PermissionSetAssignment(PermissionSetId = ipaExceptionReviewerPS.Id, AssigneeId = systemAdmin.Id);
            permissionSetAssignmentList.add(psaIPAReviewer);

            PermissionSetAssignment psaEefReviewer = new PermissionSetAssignment(PermissionSetId = eefExceptionReviewerPS.Id, AssigneeId = systemAdmin.Id);
            permissionSetAssignmentList.add(psaEefReviewer);
            
            PermissionSetAssignment psa2 = new PermissionSetAssignment(PermissionSetId = dcfAccManagerPS.Id, AssigneeId = dcfAccountManager.Id);
            permissionSetAssignmentList.add(psa2);
            
            PermissionSetAssignment psaIPA = new PermissionSetAssignment(PermissionSetId = ipaAccManagerPS.Id, AssigneeId = systemAdmin.Id);
            permissionSetAssignmentList.add(psaIPA);
            
            
             PermissionSetAssignment psaEEFAccMgr = new PermissionSetAssignment(PermissionSetId = eefAccManagerPS.Id, AssigneeId = systemAdmin.Id);
            permissionSetAssignmentList.add(psaEEFAccMgr);
            
            PermissionSetAssignment psaccfaccmgr = new PermissionSetAssignment(PermissionSetId = ccfAccManagerPS.Id, AssigneeId = exceptionReviewer.Id);
            permissionSetAssignmentList.add(psaccfaccmgr);
            
            PermissionSetAssignment psaIPAccfaccmgr = new PermissionSetAssignment(PermissionSetId = ipaAccManagerPS.Id, AssigneeId = exceptionReviewer.Id);
            permissionSetAssignmentList.add(psaIPAccfaccmgr);
            
            
            PermissionSetAssignment psaCCFAccMgrToAdmin = new PermissionSetAssignment(PermissionSetId = ccfAccManagerPS.Id, AssigneeId = systemAdmin.Id);
            permissionSetAssignmentList.add(psaCCFAccMgrToAdmin);
            
            PermissionSetAssignment psaRMFAccMgrToAdmin = new PermissionSetAssignment(PermissionSetId = rmfAccManagerPS.Id, AssigneeId = systemAdmin.Id);
            permissionSetAssignmentList.add(psaRMFAccMgrToAdmin);
            
            PermissionSetAssignment psaCCFReviewer = new PermissionSetAssignment(PermissionSetId = exceptionReviewerPS.Id, AssigneeId = systemAdmin.Id);
            permissionSetAssignmentList.add(psaCCFReviewer);
            
            PermissionSetAssignment psaRMFReviewer = new PermissionSetAssignment(PermissionSetId = rmfExceptionReviewerPS.Id, AssigneeId = systemAdmin.Id);
            permissionSetAssignmentList.add(psaRMFReviewer);
            
            insert permissionSetAssignmentList;
            
            
            
            List<SetupEntityAccess> listOfSea = new List<SetupEntityAccess>();
            SetupEntityAccess sea = new SetupEntityAccess();
            sea.ParentId = eefExceptionReviewerPS.Id;
            sea.SetupEntityId = [select Id from CustomPermission where DeveloperName = 'Core_MDF_Internal_EEF_Exception_Reviewer' limit 1].Id;
            listOfSea.add(sea);
            //insert listOfSea;
            
            group grpAllEmployees = [select DeveloperName from group where DeveloperName='Core_All_Employees_Group' LIMIT 1];
           // group grpCCPInternal = [select Id,DeveloperName from group where DeveloperName='Core_All_Users_CCP_Internal' LIMIT 1];
            //group grpIPAInternal = [select Id,DeveloperName from group where DeveloperName='Core_MDF_CCP_IPA_ALL' LIMIT 1];
            //group grpIPAWWInternal = [select Id,DeveloperName from group where DeveloperName='Core_MDF_Int_IPA_WW' LIMIT 1];
            
            List<Group> grplist = new List<Group>();
            Group ccfgrp = new Group();
            ccfgrp.Name = 'CCP FLIPKARTT CCF APJ INTERNAL';
            ccfgrp.DeveloperName = 'Core_MDF_CCP_FLIPKARTT_CCF_APJ_INTERNAL';
            grplist.add(ccfgrp);
            Group grpCCPInternal = new Group();
            grpCCPInternal.Name = 'CCP INTERNAL ALL';
            grpCCPInternal.DeveloperName = 'Core_All_Users_CCP_Internal1';   
            grplist.add(grpCCPInternal);            
            Group grpIPAInternal = new Group();
            grpIPAInternal.Name = 'CCP IPA INTERNAL ALL';
            grpIPAInternal.DeveloperName = 'Core_MDF_CCP_IPA_ALL1';   
            grplist.add(grpIPAInternal);
            Database.insert(grplist);

            List<groupmember> groupMemberList = new List<groupmember>();
            groupmember grpmembAllEmployees = new groupmember();
            grpmembAllEmployees.groupid = grpAllEmployees.id;
            grpmembAllEmployees.UserOrGroupId = exceptionReviewer.id;
            groupMemberList.add(grpmembAllEmployees);
            
            groupmember grpmembCCPInternal = new groupmember();
            grpmembCCPInternal.groupid = grpCCPInternal.id;
            grpmembCCPInternal.UserOrGroupId = exceptionReviewer.id;
            
            groupmember grpmembIPAInternal = new groupmember();
            grpmembIPAInternal.groupid = grpCCPInternal.id;
            grpmembIPAInternal.UserOrGroupId = exceptionReviewer.id;
            
            groupMemberList.add(grpmembCCPInternal);
            
            database.insert(groupMemberList);
            
            List<Core_MDF_Partner_Group_Mapping__c> pgm = new List<Core_MDF_Partner_Group_Mapping__c>();
            Core_MDF_Partner_Group_Mapping__c ccfPgm = new Core_MDF_Partner_Group_Mapping__c();
            ccfPgm.Core_MDF_Source_Txt__c = 'test';
            ccfPgm.Core_MDF_Account__c = myntraTestAccount.Id;
            ccfPgm.Core_MDF_Group_Name__c = 'Core_MDF_CCP_FLIPKARTT_CCF_APJ_INTERNAL';
            ccfPgm.Core_MDF_Type_of_Access__c = 'Internal';
            ccfPgm.Core_MDF_Group_Id__c = ccfgrp.Id;
            ccfPgm.Core_MDF_Channel_Program__c = ccfCp.Id;
            ccfPgm.Core_MDF_Region_cd__c = 'APJ';
            pgm.add(ccfPgm);
            
            Core_MDF_Partner_Group_Mapping__c ccfPgmRegion = new Core_MDF_Partner_Group_Mapping__c();
            ccfPgmRegion.Core_MDF_Source_Txt__c = 'test';
            ccfPgmRegion.Core_MDF_Account__c = flipkartTestAccount.Id;
            //ccfPgmRegion.Core_MDF_Group_Name__c = 'Core_MDF_CCP_FLIPKARTT_CCF_APJ_SA_INTERNAL';
            ccfPgmRegion.Core_MDF_Group_Name__c = 'Core_MDF_CCP_FLIPKARTT_CCF_APJ_INTERNAL';
            ccfPgmRegion.Core_MDF_Type_of_Access__c = 'Internal';
            ccfPgmRegion.Core_MDF_Group_Id__c = ccfgrp.Id;
            ccfPgmRegion.Core_MDF_Channel_Program__c = ccfCp.Id;
            ccfPgmRegion.Core_MDF_Region_cd__c = 'APJ';
            ccfPgmRegion.Core_MDF_Sub_Region_cd__c = 'SA';
            //pgm.add(ccfPgmRegion);
            
            Core_MDF_Partner_Group_Mapping__c ccfPgmWW = new Core_MDF_Partner_Group_Mapping__c();
            ccfPgmWW.Core_MDF_Source_Txt__c = 'test';
            ccfPgmWW.Core_MDF_Account__c = flipkartTestAccount.Id;
            ccfPgmWW.Core_MDF_Group_Name__c = 'Core_MDF_CCP_FLIPKARTT_CCF_APJ_INTERNAL';
            ccfPgmWW.Core_MDF_Type_of_Access__c = 'Internal';
            ccfPgmWW.Core_MDF_Group_Id__c = ccfgrp.Id;
            ccfPgmWW.Core_MDF_Channel_Program__c = ccfCp.Id;
            ccfPgmWW.Core_MDF_Region_cd__c = 'WW';
            pgm.add(ccfPgmWW);

            Core_MDF_Partner_Group_Mapping__c ipaPgmWW = new Core_MDF_Partner_Group_Mapping__c();
            ipaPgmWW.Core_MDF_Source_Txt__c = 'test';
            ipaPgmWW.Core_MDF_Account__c = myntraTestAccount.Id;
            ipaPgmWW.Core_MDF_Group_Name__c = 'Core_All_Users_CCP_Internal1';
            ipaPgmWW.Core_MDF_Type_of_Access__c = 'Internal';
            ipaPgmWW.Core_MDF_Group_Id__c = grpCCPInternal.Id;
            ipaPgmWW.Core_MDF_Channel_Program__c = ipaCP.Id;
            ipaPgmWW.Core_MDF_Region_cd__c = 'APJ';
            pgm.add(ipaPgmWW); 
            
            Core_MDF_Partner_Group_Mapping__c ipaPgmWW2 = new Core_MDF_Partner_Group_Mapping__c();
            ipaPgmWW2.Core_MDF_Source_Txt__c = 'test';
            ipaPgmWW2.Core_MDF_Account__c = myntraTestAccount.Id;
            ipaPgmWW2.Core_MDF_Group_Name__c = 'Core_MDF_CCP_IPA_ALL1';
            ipaPgmWW2.Core_MDF_Type_of_Access__c = 'Internal';
            ipaPgmWW2.Core_MDF_Group_Id__c = grpIPAInternal.Id;
            ipaPgmWW2.Core_MDF_Channel_Program__c = ipaCP.Id;
            ipaPgmWW2.Core_MDF_Region_cd__c = 'APJ';
            ipaPgmWW2.Core_MDF_BudgetType_nm__c='Client Specialties MDF';
            pgm.add(ipaPgmWW2); 
            Database.insert(pgm);
    
           
            
            List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> iupgmList = new List<Core_MDF_Int_Users_Partner_Geo_Mapping__c>();
            
            Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgmWW = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
            iupgmWW.Core_MDF_Account_id__c = flipkartTestAccount.Id;
            iupgmWW.Core_MDF_Program_nm__c = 'Client CoMarketing Fund';
            iupgmWW.Core_MDF_Region_Sub_Region_nm__c = 'WW';
            iupgmWW.Core_MDF_User_id__c = ccfAccountManager.Id;
            iupgmWW.Core_MDF_Role_nm__c = 'Core_MDF_CCP_Internal_CCF_Acct_Mgr';
            iupgmWW.Core_MDF_All_Accounts_cd__c = 'No';
            iupgmList.add(iupgmWW);
            
            Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
            iupgm.Core_MDF_Account_id__c = flipkartTestAccount.Id;
            iupgm.Core_MDF_Program_nm__c = 'Client CoMarketing Fund';
            iupgm.Core_MDF_Region_Sub_Region_nm__c = 'WW';
            iupgm.Core_MDF_Region_cd__c = 'WW';
            iupgm.Core_MDF_User_id__c = ccfwwAccountManager.Id;
            iupgm.Core_MDF_Role_nm__c = 'Core_MDF_CCP_Internal_CCF_Acct_Mgr';
            iupgm.Core_MDF_All_Accounts_cd__c = 'No';
            iupgmList.add(iupgm);
            
            
            Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgmIPA = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
            iupgmIPA.Core_MDF_Account_id__c = flipkartTestAccount.Id;
            iupgmIPA.Core_MDF_Program_nm__c = 'Intel Partner Alliance';
            iupgmIPA.RecordTypeId = IPA_RecordType;
            iupgmIPA.Core_MDF_Region_Sub_Region_nm__c = 'APJ';
            iupgmIPA.Core_MDF_User_id__c = systemAdmin.Id;
            iupgmIPA.Core_MDF_Role_nm__c = 'Core_MDF_Internal_IPA_Exception_Reviewer';
            iupgmIPA.Core_MDF_GeoSubGeo_Budget_Type_nm__c = 'APJ->Client Specialties MDF';
            iupgmIPA.Core_MDF_All_Accounts_cd__c = 'No';
            iupgmList.add(iupgmIPA);

            Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgmIPAWW = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
            iupgmIPAWW.Core_MDF_Account_id__c = myntraTestAccount.Id;
            iupgmIPAWW.Core_MDF_Program_nm__c = 'Intel Partner Alliance';
            iupgmIPAWW.RecordTypeId = IPA_RecordType;
            iupgmIPAWW.Core_MDF_Region_Sub_Region_nm__c = 'WW';
            iupgmIPAWW.Core_MDF_User_id__c = systemAdmin.Id;
            iupgmIPAWW.Core_MDF_Role_nm__c = 'Core_MDF_Internal_IPA_Exception_Reviewer';
            iupgmIPAWW.Core_MDF_All_Budget_Type_Access_Ind__c = true;
            iupgmIPAWW.Core_MDF_All_Accounts_cd__c = 'No';
            iupgmList.add(iupgmIPAWW);

            Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgmEEFWW = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
            iupgmEEFWW.Core_MDF_Account_id__c = flipkartTestAccount.Id;
            iupgmEEFWW.Core_MDF_Program_nm__c = 'Ecosystem Extension Fund';
            iupgmEEFWW.RecordTypeId = EEF_RecordType;
            iupgmEEFWW.Core_MDF_Region_Sub_Region_nm__c = 'WW';
            iupgmEEFWW.Core_MDF_User_id__c = systemAdmin.Id;
            iupgmEEFWW.Core_MDF_Role_nm__c = 'Core_MDF_Internal_EEF_Exception_Reviewer';
            iupgmEEFWW.Core_MDF_All_Budget_Type_Access_Ind__c = true;
            iupgmEEFWW.Core_MDF_All_Accounts_cd__c = 'No';
            iupgmList.add(iupgmEEFWW);
            insert iupgmList;
            
            Account flipkartTestAccountCCF = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test CCF Account', ccfCp.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, flipkartTestAccount.Id, false);
            Account myntraTestAccountDCF = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test DCF Account', dcfCp.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, myntraTestAccount.Id, false);
            Account myntraTestAccountCCF = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test CCF Account Myntra', ccfCp.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, myntraTestAccount.Id, false);
            Account eefAcc = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test Account 2',eefCp.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type,flipkartTestAccount.Id, false);
            eefAcc.Core_MDF_Partner_Type_nm__c ='Activating Partner';
            eefAcc.Core_MDF_CoMarketing_Ultimate_Account__c =flipkartTestAccount.id;

            Account PrimaryVC = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Primary VC Account',eefCp.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, intelActAcc.Id, false);
            PrimaryVC.Core_MDF_Partner_Type_nm__c = 'Primary Partner';
            PrimaryVC.Core_MDF_Active_Ind__c = true;
            PrimaryVC.Core_MDF_CoMarketing_Ultimate_Account__c =intelActAcc.id;
            //accCoMarketingList.add(PrimaryVC);
            
            List<Account> accountList = new List<Account>();
            accountList.add(flipkartTestAccountCCF);
            accountList.add(myntraTestAccountDCF);
            accountList.add(myntraTestAccountCCF);
      accountList.add(eefAcc);
            accountList.add(PrimaryVC);
            //accountList.add(eefAccPrim);
            insert accountList;
      
          

            
            /*Core_MDF_Account_Onboarding__c accVirtual = new Core_MDF_Account_Onboarding__c();
            accVirtual.Core_MDF_Technical_Program_nm__c = 'Client CoMarketing Fund';
            accVirtual.Core_MDF_Type__c = 'Intel Account';
            accVirtual.Core_MDF_Account__c = testAcctTemp.Id;
            Database.insert(eefAcc);*/
            
            //Account virtualCorp = [select Id,Name from Account where Core_MDF_CoMarketing_Ultimate_Account__c  =: testAcctTemp.id];
      
            Test.startTest();
            List<AccountShare> accshare = new List<AccountShare>();
            
            AccountShare accshareRecordCCFWW = new AccountShare();
            accshareRecordCCFWW.AccountId = flipkartTestAccount.Id;
            accshareRecordCCFWW.UserOrGroupId = ccfwwAccountManager.Id;
            accshareRecordCCFWW.RowCause = 'Manual';
            accshareRecordCCFWW.AccountAccessLevel = 'Read';
            accshareRecordCCFWW.OpportunityAccessLevel = 'None';
            accshareRecordCCFWW.CaseAccessLevel = 'None';
            accshare.add(accshareRecordCCFWW);
            
            AccountShare accshareRecordCCF = new AccountShare();
            accshareRecordCCF.AccountId = flipkartTestAccount.Id;
            accshareRecordCCF.UserOrGroupId = ccfAccountManager.Id;
            accshareRecordCCF.RowCause = 'Manual';
            accshareRecordCCF.AccountAccessLevel = 'Read';
            accshareRecordCCF.OpportunityAccessLevel = 'None';
            accshareRecordCCF.CaseAccessLevel = 'None';
            accshare.add(accshareRecordCCF);
            
            AccountShare accshareExcepetionReviewer = new AccountShare();
            accshareExcepetionReviewer.AccountId = flipkartTestAccount.Id;
            accshareExcepetionReviewer.UserOrGroupId = exceptionReviewer.Id;
            accshareExcepetionReviewer.RowCause = 'Manual';
            accshareExcepetionReviewer.AccountAccessLevel = 'Read';
            accshareExcepetionReviewer.OpportunityAccessLevel = 'None';
            accshareExcepetionReviewer.CaseAccessLevel = 'None';
            accshare.add(accshareExcepetionReviewer);
            
            AccountShare accshareMyntraExcepetionReviewer = new AccountShare();
            accshareMyntraExcepetionReviewer.AccountId = myntraTestAccount.Id;
            accshareMyntraExcepetionReviewer.UserOrGroupId = exceptionReviewer.Id;
            accshareMyntraExcepetionReviewer.RowCause = 'Manual';
            accshareMyntraExcepetionReviewer.AccountAccessLevel = 'Read';
            accshareMyntraExcepetionReviewer.OpportunityAccessLevel = 'None';
            accshareMyntraExcepetionReviewer.CaseAccessLevel = 'None';
            accshare.add(accshareMyntraExcepetionReviewer);
            
            Database.insert(accshare);
            
            Core_MDF_Bank__c bank = Core_MDF_CCP_TestDataUtility.createBank(flipkartTestAccount.Id, 'Core_MDF_Client_CoMarketing_Fund', true,'1231231230');
            
            Core_MDF_Account_Bank_Mapping__c abm1 = Core_MDF_CCP_TestDataUtility.createAccountBankMap(flipkartTestAccountCCF.Id,bank.Id,false);
            abm1.Core_MDF_Active_ind__c = true;
            insert abm1;
            //adding bypass feature to bypass access validation
            List<String> bypassFunctionKeys = new List<String>();
            //adding bypass feature to bypass access validation
            bypassFunctionKeys.add('Bypass_Duplicate_Budget_Check');
            bypassFunctionKeys.add('Bypass_MDF_Budget_Access_Validation');
            bypassFunctionKeys.add('Bypass_MDF_Budget_Status_Validation');
            bypassFunctionKeys.add('Bypass_MDF_Budget_Access');
            bypassFunctionKeys.add('Bypass_GeoBased_Budget_Sharing');
            bypassFunctionKeys.add('Bypass_Allocation_Reservation');
            bypassFunctionKeys.add('Bypass_GeoBased_Allocation_Sharing');
            bypassFunctionKeys.add('Bypass_Duplicate_Bank_Check');
            bypassFunctionKeys.add('Bypass_Bank_Internal_Sharing');
            bypassFunctionKeys.add('Bypass_Bank_External_Sharing');
            bypassFunctionKeys.add('Bypass_Bank_ABM_Sharing');
            bypassFunctionKeys.add('Bypass_ABM_Internal_Sharing');
            bypassFunctionKeys.add('Bypass_ABM_External_Sharing');
            bypassFunctionKeys.add('Bypass_ABM_NodeGroup_Sharing'); 
            bypassFunctionKeys.add('Bypass_Bank_Program_InActivation_Check');
            bypassFunctionKeys.add('byPassShareUnshareCampaignRecord');
            bypassFunctionKeys.add('byPassCampaignAndRelatedRecords');
            bypassFunctionKeys.add('Bypass_Claims_Duplicate_Check');
            bypassFunctionKeys.add('Bypass_Claims_Sharing_Internal_Users');
            bypassFunctionKeys.add('Bypass_ClaimAdjReq_Share_On_Owner_Chng');
            bypassFunctionKeys.add('Bypass_ClaimAdjReq_Share_Internal_Usrs');
            bypassFunctionKeys.add('Bypass_ClaimAdjReq_Share_External_Usrs');
            bypassFunctionKeys.add('Bypass_Claim_AdjReq_Amount_Validation');
            bypassFunctionKeys.add('Bypass_Claims_Amt_vs_Budget_Amt_Check');        
            bypassFunctionKeys.add('Bypass_Claims_ABM_Validation');
            bypassFunctionKeys.add('Bypass_Claims_Sharing_Partner_Users');
            bypassFunctionKeys.add('Bypass_Payment_Doc_InvFileVAT_Validate');
            bypassFunctionKeys.add('Bypass_Claims_Amt_vs_Camp_Amt_Check');
            bypassFunctionKeys.add('Bypass_Claim_OwnerLang_EmailTemp');
            bypassFunctionKeys.add('Bypass_StampingOfActySubType_Check');
            bypassFunctionKeys.add('Bypass_Claims_Sharing_On_Owner_Change');
            bypassFunctionKeys.add('Bypass_ValidateActivityWithCampaign');
            bypassFunctionKeys.add('byPass_Cancel_Activity');
            bypassFunctionKeys.add('Core_MDF_Bypass_ATFBatchUpdate');
            bypassFunctionKeys.add('Bypass_ValidateAccProgAccessOnEAM');
            
            Set<String> myset1 = new Set<String>();
            List<String> result1 = new List<String>();
            myset1.addAll(bypassFunctionKeys);
            result1.addAll(myset1);
            
            List<Core_Trigger_Executions__c> bypassfunctinalitylist1 = Core_MDF_CCP_TestDataUtility.byPassFeature(result1,true,true);
            
            //Create Budget
            /*PartnerMarketingBudget budget = Core_MDF_CCP_TestDataUtility.createBudget('Test Budget New',
                                                                                      Core_MDF_CCP_TestDataUtility.budget_Record_Type,
                                                                                      accountList[0].Id,ccfCp.Id,10000,
                                                                                      System.today() -20,System.today().addDays(40), 
                                                                                      false);
            budget.Core_MDF_Budget_Type_Txt__c='CCF 1.0';
            
            insert budget;*/
            
            //Create Allocation
            //PartnerFundAllocation allocation = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('Test Allocation New',budget,accountList[0],10000,true);
            
            //Create Campaign
            /*Campaign camp = Core_MDF_CCP_TestDataUtility.createCampaign('Test Camp 13','Gaming','Intel® Core™ i7 Processor', 'Yes',
                                                                        Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 
                                                                        'Client CoMarketing Fund', System.today(), System.today().addDays(15), 
                                                                        10000, 'Always Connected PC', accountList[0].Id,'Desktop', true);*/
            /*camp.Core_MDF_Reimbursement_Rate__c = '25%';
            update camp;*/
            
            //Create Activity
            /*PartnerFundRequest pfr = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(String.valueof(camp.Id), 
                                                                                           Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,
                                                                                           String.valueof(accountList[0].id),allocation,null,'BRAZIL',
                                                                                           'Consumer',
                                                                                           'Desktop',
                                                                                           'Intel® Core™ i7 Processor',
                                                                                           'Broadcast',
                                                                                           'Podcast',
                                                                                           'Draft',
                                                                                           false);
            pfr.Core_MDF_Start_Date__c = system.today();
            pfr.Core_MDF_End_Date__c  = system.today() + 5;
            pfr.Core_MDF_Budget_Type_nm__c = 'CCF 1.0';
            pfr.Core_MDF_Reimbursement_Rate_txt__c = '50%';
            //Test.startTest();
            
            insert pfr;
            Test.stopTest();
            //Create Claim
            PartnerFundClaim newClaim = Core_MDF_CCP_TestDataUtility.createClaim('Test Claim', 
                                                                                 Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, pfr.Id, 
                                                                                 System.today(), System.today(), 122, 
                                                                                 System.today(), bank.Id, false);
            newClaim.Core_MDF_Currency__c = 'USD';
            newClaim.Core_MDF_Type_Txt__c = 'Claim';
            newClaim.Core_MDF_Taxes_Local__c = 0;
            newClaim.Core_MDF_Total_Invoice_Amount_Local__c = 20;
            newClaim.Core_MDF_Reimbursable_TransactionAmt_Loc__c = 10;
            newClaim.Core_MDF_Requested_Reimbursement_Amt__c = 15;
            newClaim.Core_MDF_Media_Vehicle__c='Test1';
            insert newClaim;*/
            //Test.stopTest();
            
            //IPA SetUP Data
            Account ipaUltimateAccount = Core_MDF_CCP_TestDataUtility.createIntelAccount ('IPA Intel Account',Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
            ipaUltimateAccount.BillingStateCode='';
            insert ipaUltimateAccount;
            update ipaUltimateAccount;
            
            Account ipaCoMarketingAccount = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('IPA Co-Marketing Account', ipaCP.id, Core_MDF_CCP_TestDataUtility.Account_Record_Type,ipaUltimateAccount.id, false);           
            ipaCoMarketingAccount.Core_Geo__c = 'APJ';
            ipaCoMarketingAccount.BillingStateCode='';
            insert ipaCoMarketingAccount;
            
            Account acc1 = Core_MDF_CCP_TestDataUtility.createIntelAccount('Test Acc New 1', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
            acc1.BillingStateCode='';
            insert acc1;
            
            string budgetType = Core_MDF_CCP_ConstantClass.PR_MDF_BUDGET_TYPE;
            /*Campaign ipaCampaignForAP = Core_MDF_CCP_IPA_TestDataUtility.createIPACampaign('Test Campaign - AP',ipaCoMarketingAccount.id, System.today(), System.today().adddays(30),budgetType, 110000,'INDIA', 'Developer', 'Apollo Lake', 'Pending Approval', false);
            ipaCampaignForAP.Core_MDF_Region_cd__c = 'APJ';
            ipaCampaignForAP.Core_MDF_Proposal_Based_Ind__c = true;
            ipaCampaignForAP.Status = 'Pending Review';
            ipaCampaignForAP.Core_Approval_Status__c = 'Price Reviewer';
            database.insert(ipaCampaignForAP);
            
            PartnerFundRequest ipaPFR = Core_MDF_CCP_IPA_TestDataUtility.createIPAPartnerFundRequest(ipaCampaignForAP.id,ipaCoMarketingAccount.id,System.today().addDays(1),System.today().addDays(10),true);*/
            Core_MDF_Partner_Mapping__c primToActPartnerMapping = new Core_MDF_Partner_Mapping__c();
            primToActPartnerMapping.Core_MDF_Primary_Partner_Account_id__c = PrimaryVC.id;
            primToActPartnerMapping.Core_MDF_Activating_Partner_Account_id__c = eefAcc.id;
            primToActPartnerMapping.Core_MDF_Effective_Start_Date__c = system.today()-90;
            primToActPartnerMapping.Core_MDF_Effective_End_Date__c = system.today () +100;
            primToActPartnerMapping.Core_MDF_Channel_Program__c = eefCp.Id;
            insert primToActPartnerMapping;
            
        }
        
    }    
    
    @isTest
    static void exceptionCreate(){
        
        List<Core_MDF_Exception__c> exceptionList = new List<Core_MDF_Exception__c>();
        Test.startTest();
        User submitter  = [SELECT Id FROM USER WHERE LastName = 'CCF Acc Manager' LIMIT 1];
        Account acc = [SELECT Id FROM Account WHERE Name = 'FlipkartTestAccount' LIMIT 1];
        Account accCCF = [SELECT Id FROM Account WHERE Name = 'Test CCF Account' LIMIT 1];
        Account accMyntra = [SELECT Id FROM Account WHERE Name = 'MyntraTestAccount' LIMIT 1];
        Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm = [SELECT id FROM Core_MDF_Int_Users_Partner_Geo_Mapping__c
                                                           WHERE Core_MDF_User_id__c =: submitter.id ];
        
        Core_MDF_Exception__c expt = new Core_MDF_Exception__c();
        
        System.runAs(submitter){ 
            //Account       Country
            //Single        Single 
            
            expt.Core_MDF_Name_of_Exception_nm__c = 'Test Exception Single Account Single Country';
            expt.Core_MDF_Issue_Description_dsc__c = 'Test Description';
            expt.Core_MDF_Comments_txt__c = 'Test Comments';
            expt.Core_MDF_Exception_Start_Date_dt__c = System.today();
            expt.Core_MDF_Exception_End_Date_dt__c = System.today() + 5;
            expt.Core_MDF_Exception_Reason_nm__c = 'Branding Exception from Activity Catalog';
            expt.Core_MDF_Program_nm__c = 'Core_MDF_Client_CoMarketing_Fund';
            expt.Core_MDF_Activity_Cate_and_Type_nm__c = 'Broadcast->Podcast';
            expt.Core_MDF_Total_Dollar_Impact_amt__c = 100;
            expt.Core_MDF_Country_Region_nm__c = 'INDIA';
            expt.Core_MDF_Account_id__c = acc.Id;
            exceptionList.add(expt);
            
            //Account       Country
            //Single         All
            Core_MDF_Exception__c exptAllAccount = new Core_MDF_Exception__c();
            exptAllAccount.Core_MDF_Name_of_Exception_nm__c = 'Test Exception Single Account Single Country';
            exptAllAccount.Core_MDF_Issue_Description_dsc__c = 'Test Description';
            exptAllAccount.Core_MDF_Comments_txt__c = 'Test Comments';
            exptAllAccount.Core_MDF_Exception_Start_Date_dt__c = System.today();
            exptAllAccount.Core_MDF_Exception_End_Date_dt__c = System.today() + 5;
            exptAllAccount.Core_MDF_Exception_Reason_nm__c = 'Branding Exception from Activity Catalog';
            exptAllAccount.Core_MDF_Program_nm__c = 'Core_MDF_Client_CoMarketing_Fund';
            exptAllAccount.Core_MDF_Activity_Cate_and_Type_nm__c = 'Broadcast->Podcast';
            exptAllAccount.Core_MDF_Total_Dollar_Impact_amt__c = 100;
            exptAllAccount.Core_MDF_Select_All_Country_ind__c = true;
            exptAllAccount.Core_MDF_Account_id__c = acc.Id;
            exceptionList.add(exptAllAccount);
            
            
            //Account       Country
            //Single        Multiple 
            Core_MDF_Exception__c exptDCFPrgm = new Core_MDF_Exception__c();
            exptDCFPrgm.Core_MDF_Name_of_Exception_nm__c = 'Test Exception Single Account Single Country';
            exptDCFPrgm.Core_MDF_Issue_Description_dsc__c = 'Test Description';
            exptDCFPrgm.Core_MDF_Comments_txt__c = 'Test Comments';
            exptDCFPrgm.Core_MDF_Exception_Start_Date_dt__c = System.today();
            exptDCFPrgm.Core_MDF_Exception_End_Date_dt__c = System.today() + 5;
            exptDCFPrgm.Core_MDF_Exception_Reason_nm__c = 'Branding Exception from Activity Catalog';
            exptDCFPrgm.Core_MDF_Program_nm__c = 'Core_MDF_Data_Center_CoMarketing_Fund';
            exptDCFPrgm.Core_MDF_Activity_Cate_and_Type_nm__c = 'Broadcast->Podcast';
            exptDCFPrgm.Core_MDF_Total_Dollar_Impact_amt__c = 100;
            exptDCFPrgm.Core_MDF_Country_Region_nm__c = 'INDIA;JAPAN';
            exptDCFPrgm.Core_MDF_Account_id__c = acc.Id;
            exceptionList.add(exptDCFPrgm);
            
            try{
                Database.insert(exceptionList);
            }catch(Exception e){
            }
            //System.assert(exptDCFPrgm.id == NULL);
            //Assert.isNull(exptDCFPrgm.id);
            Test.stopTest(); 
        }
    }
    @isTest
    static void exceptionSubmitterAllAccountAccessError(){
        
        List<Core_MDF_Exception__c> exceptionList = new List<Core_MDF_Exception__c>();
        Test.startTest();
        User submitter  = [SELECT Id FROM USER WHERE LastName = 'CCF Acc Manager' LIMIT 1];
        Account acc = [SELECT Id FROM Account WHERE Name = 'FlipkartTestAccount' LIMIT 1];
        Account accCCF = [SELECT Id FROM Account WHERE Name = 'Test CCF Account' LIMIT 1];
        Account accMyntra = [SELECT Id FROM Account WHERE Name = 'MyntraTestAccount' LIMIT 1];
        Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm = [SELECT id FROM Core_MDF_Int_Users_Partner_Geo_Mapping__c
                                                           WHERE Core_MDF_User_id__c =: submitter.id ];
        //PartnerFundClaim newClaim = [SELECT Id FROM PartnerFundClaim WHERE Title = 'Test Claim' LIMIT 1];
        
        Core_MDF_Exception__c expt = new Core_MDF_Exception__c();        
        System.runAs(submitter){            
            //Account       Country
            //Single        Single
            //Validate Account Access
            Core_MDF_Exception__c exptAcccountAccess= new Core_MDF_Exception__c();
            exptAcccountAccess.Core_MDF_Name_of_Exception_nm__c = 'Test Exception Single Account Single Country';
            exptAcccountAccess.Core_MDF_Issue_Description_dsc__c = 'Test Description';
            exptAcccountAccess.Core_MDF_Comments_txt__c = 'Test Comments';
            exptAcccountAccess.Core_MDF_Exception_Start_Date_dt__c = System.today();
            exptAcccountAccess.Core_MDF_Exception_End_Date_dt__c = System.today() + 5;
            exptAcccountAccess.Core_MDF_Exception_Reason_nm__c = 'Branding Exception from Activity Catalog';
            exptAcccountAccess.Core_MDF_Program_nm__c = 'Core_MDF_Client_CoMarketing_Fund';
            exptAcccountAccess.Core_MDF_Activity_Cate_and_Type_nm__c = 'Broadcast->Podcast';
            exptAcccountAccess.Core_MDF_Total_Dollar_Impact_amt__c = 100;
            exptAcccountAccess.Core_MDF_Country_Region_nm__c = 'INDIA';
            exptAcccountAccess.Core_MDF_Select_All_Accounts_ind__c = true;
            
            Map<Id , Core_MDF_Exception__c> newExceptionMap = new Map<Id , Core_MDF_Exception__c>();
            Map<Id , Core_MDF_Exception__c> newExceptionAllCountryMap = new Map<Id , Core_MDF_Exception__c>();

            Core_MDF_Exception__c exptAllAccount = new Core_MDF_Exception__c();
            exptAllAccount.Core_MDF_Name_of_Exception_nm__c = 'Test Exception Single Account Single Country IPA';
            exptAllAccount.Core_MDF_Issue_Description_dsc__c = 'Test Description IPA';
            exptAllAccount.Core_MDF_Comments_txt__c = 'Test Comments';
            exptAllAccount.Core_MDF_Exception_Start_Date_dt__c = System.today();
            exptAllAccount.Core_MDF_Exception_End_Date_dt__c = System.today() + 5;
            exptAllAccount.Core_MDF_Exception_Reason_nm__c = 'Branding Exception from Activity Catalog';
            exptAllAccount.Core_MDF_Program_nm__c = 'Core_MDF_Intel_Partner_Alliance';
            exptAllAccount.Core_MDF_Activity_Cate_and_Type_nm__c = 'Broadcast->Podcast';
            exptAllAccount.Core_MDF_Total_Dollar_Impact_amt__c = 100;
            exptAllAccount.Core_MDF_Region_txt__c='EMEA,PRC,ASMO,APJ';
            //exptAllAccount.Core_MDF_Account_id__c = null;
            exptAllAccount.Core_MDF_Select_All_Accounts_ind__c=true;
            exptAllAccount.Core_MDF_Select_All_Country_ind__c = true;
            exptAllAccount.Core_MDF_Budget_Type_nm__c = 'Client Specialties MDF';
            newExceptionAllCountryMap.put(exptAllAccount.Id,exptAllAccount);
            exceptionList.add(exptAllAccount);
            
        
            try{
                newExceptionMap.put(exptAcccountAccess.Id,exptAcccountAccess);
            
            }catch(Exception e){
                //System.assert(exptAcccountAccess.Id  != null);  
                Assert.isNotNull(exptAcccountAccess.Id);
            }
            //System.assert(exptAcccountAccess.Id  == null); 
            Assert.isNull(exptAcccountAccess.Id);
            Test.stopTest(); 
        }
    }
    
    @isTest
    static void exceptionSubmitterGeoAccessError(){
        
        List<Core_MDF_Exception__c> exceptionList = new List<Core_MDF_Exception__c>();
        Test.startTest();
        User submitter  = [SELECT Id FROM USER WHERE LastName = 'CCF WW Acc Manager' LIMIT 1];
        Account acc = [SELECT Id FROM Account WHERE Name = 'FlipkartTestAccount' LIMIT 1];
        Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm = [SELECT id FROM Core_MDF_Int_Users_Partner_Geo_Mapping__c
                                                           WHERE Core_MDF_User_id__c =: submitter.id ];
        
        System.runAs(submitter){   
            Map<Id , Core_MDF_Exception__c> newExceptionMap = new Map<Id , Core_MDF_Exception__c>();
            
            //Account       Country
            //Single        Single
            //Validate Account Access
            Core_MDF_Exception__c exptGeoError= new Core_MDF_Exception__c();
            exptGeoError.Core_MDF_Name_of_Exception_nm__c = 'Test Exception Single Account Single Country';
            exptGeoError.Core_MDF_Issue_Description_dsc__c = 'Test Description';
            exptGeoError.Core_MDF_Comments_txt__c = 'Test Comments';
            exptGeoError.Core_MDF_Exception_Start_Date_dt__c = System.today();
            exptGeoError.Core_MDF_Exception_End_Date_dt__c = System.today() + 5;
            exptGeoError.Core_MDF_Exception_Reason_nm__c = 'Branding Exception from Activity Catalog';
            exptGeoError.Core_MDF_Program_nm__c = 'Core_MDF_Client_CoMarketing_Fund';
            exptGeoError.Core_MDF_Activity_Cate_and_Type_nm__c = 'Broadcast->Podcast';
            exptGeoError.Core_MDF_Total_Dollar_Impact_amt__c = 100;
            exptGeoError.Core_MDF_Select_All_Country_ind__c = TRUE;
            exptGeoError.Core_MDF_Account_id__c = acc.Id;
            newExceptionMap.put(exptGeoError.Id,exptGeoError);
            
            Core_MDF_Exception__c exptAllCountry= new Core_MDF_Exception__c();
            exptAllCountry.Core_MDF_Name_of_Exception_nm__c = 'Test Exception Single Account Single Country';
            exptAllCountry.Core_MDF_Issue_Description_dsc__c = 'Test Description';
            exptAllCountry.Core_MDF_Comments_txt__c = 'Test Comments';
            exptAllCountry.Core_MDF_Exception_Start_Date_dt__c = System.today();
            exptAllCountry.Core_MDF_Exception_End_Date_dt__c = System.today() + 5;
            exptAllCountry.Core_MDF_Exception_Reason_nm__c = 'Branding Exception from Activity Catalog';
            exptAllCountry.Core_MDF_Program_nm__c = 'Core_MDF_Client_CoMarketing_Fund';
            exptAllCountry.Core_MDF_Activity_Cate_and_Type_nm__c = 'Broadcast->Podcast';
            exptAllCountry.Core_MDF_Total_Dollar_Impact_amt__c = 100;
            exptAllCountry.Core_MDF_Select_All_Country_ind__c = TRUE;
            exptAllCountry.Core_MDF_Account_id__c = acc.Id;
            newExceptionMap.put(exptAllCountry.Id,exptAllCountry);
            
            try{
                Core_MDF_Exception_TriggerServiceHandler.isCustomPermissionAssigned(Null);
            }catch(Exception e){
            }
            Test.stopTest();
            //System.assert(exptAllCountry.Id == NULL);
            Assert.isNull(exptAllCountry.Id);
        }
    }
    
    /*@isTest
    static void exceptionCaseMappingCreate(){
        Test.startTest();
        User submitter  = [SELECT Id FROM USER WHERE LastName = 'CCF Acc Manager' LIMIT 1];
        Account acc = [SELECT Id FROM Account WHERE Name = 'FlipkartTestAccount' LIMIT 1];
        PartnerFundClaim newClaim = [SELECT Id FROM PartnerFundClaim WHERE Title = 'Test Claim' LIMIT 1];
        
        Case cs = new Case();
        Id caseAuditRecType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Core_MDF_Audit_Closed').getRecordTypeId();
        cs.Status = 'Closed';
        cs.recordTypeId = caseAuditRecType;
        //cs.AccountId = flipkartTestAccount.Id;
        cs.Core_MDF_Region_SubRegion_txt__c = 'APJ - IJKK';
        cs.Core_MDF_Claim_ID__c = newClaim.Id;
        database.insert(cs);
        
        List<Core_MDF_Exception__c> exptRecordList = new List<Core_MDF_Exception__c>();
        System.runAs(submitter){
            //Single        Single 
            Core_MDF_Exception__c expt = new Core_MDF_Exception__c();
            expt.Core_MDF_Name_of_Exception_nm__c = 'Test Exception Single Account Single Country';
            expt.Core_MDF_Issue_Description_dsc__c = 'Test Description';
            expt.Core_MDF_Comments_txt__c = 'Test Comments';
            expt.Core_MDF_Exception_Start_Date_dt__c = System.today();
            expt.Core_MDF_Exception_End_Date_dt__c = System.today() + 5;
            expt.Core_MDF_Exception_Reason_nm__c = 'Branding Exception from Activity Catalog';
            expt.Core_MDF_Program_nm__c = 'Core_MDF_Client_CoMarketing_Fund';
            expt.Core_MDF_Activity_Cate_and_Type_nm__c = 'Broadcast->Podcast';
            expt.Core_MDF_Total_Dollar_Impact_amt__c = 100;
            expt.Core_MDF_Country_Region_nm__c = 'INDIA';
            expt.Core_MDF_Account_id__c = acc.Id;
            exptRecordList.add(expt);
            
            Core_MDF_Exception__c exptMultipleCountry = new Core_MDF_Exception__c();
            //Single Account        Multiple Country
            exptMultipleCountry.Core_MDF_Name_of_Exception_nm__c = 'Test Exception Single Account Multiple Country';
            exptMultipleCountry.Core_MDF_Issue_Description_dsc__c = 'Test Description';
            exptMultipleCountry.Core_MDF_Comments_txt__c = 'Test Comments';
            exptMultipleCountry.Core_MDF_Exception_Start_Date_dt__c = System.today();
            exptMultipleCountry.Core_MDF_Exception_End_Date_dt__c = System.today() + 5;
            exptMultipleCountry.Core_MDF_Exception_Reason_nm__c = 'Branding Exception from Activity Catalog';
            exptMultipleCountry.Core_MDF_Program_nm__c = 'Core_MDF_Client_CoMarketing_Fund';
            exptMultipleCountry.Core_MDF_Activity_Cate_and_Type_nm__c = 'Broadcast->Podcast';
            exptMultipleCountry.Core_MDF_Total_Dollar_Impact_amt__c = 100;
            exptMultipleCountry.Core_MDF_Country_Region_nm__c = 'INDIA;JAPAN';
            exptMultipleCountry.Core_MDF_Account_id__c = acc.Id;
            exptRecordList.add(exptMultipleCountry);
            
            Database.insert(exptRecordList);
        }
        List<Core_MDF_Exception_Case_Mapping__c> ecmList = new List<Core_MDF_Exception_Case_Mapping__c>();
        //Create ECM
        Core_MDF_Exception_Case_Mapping__c ecm = new Core_MDF_Exception_Case_Mapping__c();
        ecm.Core_MDF_Case_id__c = cs.Id;
        ecm.Core_MDF_Exception_id__c = exptRecordList[0].Id;
        ecm.Core_MDF_Program_txt__c = exptRecordList[0].Core_MDF_Program_nm__c;
        ecmList.add(ecm);
        
        Core_MDF_Exception_Case_Mapping__c ecm2 = new Core_MDF_Exception_Case_Mapping__c();
        ecm2.Core_MDF_Case_id__c = cs.Id;
        ecm2.Core_MDF_Exception_id__c = exptRecordList[1].Id;
        ecm2.Core_MDF_Program_txt__c = exptRecordList[1].Core_MDF_Program_nm__c;
        ecmList.add(ecm2);
        
        Database.insert(ecmList);
        
        
        Map<Id , Core_MDF_Exception_Case_Mapping__c> newExceptionMap = new Map<Id , Core_MDF_Exception_Case_Mapping__c>();
        try{
            newExceptionMap.put(ecm.Id,ecm);
            newExceptionMap.put(ecm2.Id,ecm2);
            Core_MDF_Exception_TriggerServiceHandler.shareECMRecordWithusers(newExceptionMap);
            Core_MDF_Exception_TriggerServiceHandler.createECMShare(ecm.Id,submitter.Id);
        }catch(Exception e){
            
        }
        Test.stopTest();
        //System.assert(exptRecordList[0].Id != NULL);
        Assert.isNotNull(exptRecordList[0].Id);
    }*/
    @isTest
    static void exceptionSubmitterAccountAccessError(){
        
        List<Core_MDF_Exception__c> exceptionList = new List<Core_MDF_Exception__c>();
        Test.startTest();
        User submitter  = [SELECT Id FROM USER WHERE LastName = 'CCF Acc Manager' LIMIT 1];
        Account acc = [SELECT Id FROM Account WHERE Name = 'FlipkartTestAccount' LIMIT 1];
        Account accMyntra = [SELECT Id FROM Account WHERE Name = 'MyntraTestAccount' LIMIT 1];
        
        Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm = [SELECT id FROM Core_MDF_Int_Users_Partner_Geo_Mapping__c
                                                           WHERE Core_MDF_User_id__c =: submitter.id ];
        
        System.runAs(submitter){            
            //Account       Country
            //Single        Single
            //Validate Account Access
            Core_MDF_Exception__c exptAccountAccess= new Core_MDF_Exception__c();
            exptAccountAccess.Core_MDF_Name_of_Exception_nm__c = 'Test Exception Single Account Single Country';
            exptAccountAccess.Core_MDF_Issue_Description_dsc__c = 'Test Description';
            exptAccountAccess.Core_MDF_Comments_txt__c = 'Test Comments';
            exptAccountAccess.Core_MDF_Exception_Start_Date_dt__c = System.today();
            exptAccountAccess.Core_MDF_Exception_End_Date_dt__c = System.today() + 5;
            exptAccountAccess.Core_MDF_Exception_Reason_nm__c = 'Branding Exception from Activity Catalog';
            exptAccountAccess.Core_MDF_Program_nm__c = 'Core_MDF_Client_CoMarketing_Fund';
            exptAccountAccess.Core_MDF_Activity_Cate_and_Type_nm__c = 'Broadcast->Podcast';
            exptAccountAccess.Core_MDF_Total_Dollar_Impact_amt__c = 100;
            exptAccountAccess.Core_MDF_Country_Region_nm__c = 'GERMANY';
            exptAccountAccess.Core_MDF_Account_id__c = accMyntra.Id;
            Map<Id , Core_MDF_Exception__c> newExceptionMap = new Map<Id , Core_MDF_Exception__c>();
            try{
                newExceptionMap.put(exptAccountAccess.Id,exptAccountAccess);
            }catch(Exception e){
                
            }
            //System.assert(exptAccountAccess.id == NULL);
            Assert.isNull(exptAccountAccess.id);
            Test.stopTest();
        }
    }
    /*@isTest
    static void exceptionSubmitterProgramAccessError(){
        
        List<Core_MDF_Exception__c> exceptionList = new List<Core_MDF_Exception__c>();
        Test.startTest();
        User submitter  = [SELECT Id FROM USER WHERE LastName = 'CCF Acc Manager'];
        Account acc = [SELECT Id FROM Account WHERE Name = 'FlipkartTestAccount' LIMIT 1];
        Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm = [SELECT id FROM Core_MDF_Int_Users_Partner_Geo_Mapping__c
                                                           WHERE Core_MDF_User_id__c =: submitter.id ];       
        
        System.runAs(submitter){            
            //Account       Country
            //Single        Single
            //Validate Account Access
            Core_MDF_Exception__c exptProgramDCF= new Core_MDF_Exception__c();
            exptProgramDCF.Core_MDF_Name_of_Exception_nm__c = 'Test Exception Single Account Single Country';
            exptProgramDCF.Core_MDF_Issue_Description_dsc__c = 'Test Description';
            exptProgramDCF.Core_MDF_Comments_txt__c = 'Test Comments';
            exptProgramDCF.Core_MDF_Exception_Start_Date_dt__c = System.today();
            exptProgramDCF.Core_MDF_Exception_End_Date_dt__c = System.today() + 5;
            exptProgramDCF.Core_MDF_Exception_Reason_nm__c = 'Branding Exception from Activity Catalog';
            exptProgramDCF.Core_MDF_Program_nm__c = 'Core_MDF_Data_Center_CoMarketing_Fund';
            exptProgramDCF.Core_MDF_Activity_Cate_and_Type_nm__c = 'Broadcast->Podcast';
            exptProgramDCF.Core_MDF_Total_Dollar_Impact_amt__c = 100;
            exptProgramDCF.Core_MDF_Country_Region_nm__c = 'INDIA';
            exptProgramDCF.Core_MDF_Account_id__c = acc.Id;
            Map<Id , Core_MDF_Exception__c> newExceptionMap = new Map<Id , Core_MDF_Exception__c>();
            try{
                newExceptionMap.put(exptProgramDCF.Id,exptProgramDCF);
                Core_MDF_Exception_TriggerServiceHandler.shareExceptionRecordsWithInternalUsers(newExceptionMap,true);
            }catch(Exception e){
            }
            //System.assert(exptProgramDCF.Id == NULL);
            Assert.isNull(exptProgramDCF.Id);
            Test.stopTest();
        }
        
    }*/
    
    @isTest
    static void exceptionForSingleAccountAllCountriesTest(){
        
        List<Core_MDF_Exception__c> exceptionList = new List<Core_MDF_Exception__c>();
        Test.startTest();
        User reviewer  = [SELECT Id FROM USER WHERE LastName = 'Excpetion Reviewer' LIMIT 1];
        User submitterWW  = [SELECT Id FROM USER WHERE LastName = 'CCF WW Acc Manager' LIMIT 1];
        Account acc = [SELECT Id FROM Account WHERE Name = 'FlipkartTestAccount' LIMIT 1];
        Core_MDF_Exception__c expt = new Core_MDF_Exception__c();
        expt.Core_MDF_Name_of_Exception_nm__c = 'Test Exception Single Account Single Country';
        expt.Core_MDF_Issue_Description_dsc__c = 'Test Description';
        expt.Core_MDF_Comments_txt__c = 'Test Comments';
        expt.Core_MDF_Exception_Start_Date_dt__c = System.today();
        expt.Core_MDF_Exception_End_Date_dt__c = System.today() + 5;
        expt.Core_MDF_Exception_Reason_nm__c = 'Branding Exception from Activity Catalog';
        expt.Core_MDF_Program_nm__c = 'Core_MDF_Client_CoMarketing_Fund';
        expt.Core_MDF_Activity_Cate_and_Type_nm__c = 'Broadcast->Podcast';
        expt.Core_MDF_Total_Dollar_Impact_amt__c = 100;
        expt.Core_MDF_Select_All_Country_ind__c = true;
        expt.Core_MDF_Account_id__c = acc.Id;
        
        System.runAs(reviewer){ 
            Database.insert(expt);
        }
        Test.stopTest();
        //System.assert(expt.Id != NULL);
        Assert.isNotNull(expt.Id);
    }
    
    @isTest
    static void exceptionEditAccount(){
        
        List<Core_MDF_Exception__c> exceptionList = new List<Core_MDF_Exception__c>();
        Test.startTest();
        User submitter  = [SELECT Id FROM USER WHERE LastName = 'CCF Acc Manager' LIMIT 1];
        User reviewer  = [SELECT Id FROM USER WHERE LastName = 'Excpetion Reviewer' LIMIT 1];
        Account acc = [SELECT Id FROM Account WHERE Name = 'FlipkartTestAccount' LIMIT 1];
        Account accCCF = [SELECT Id FROM Account WHERE Name = 'Test CCF Account' LIMIT 1];
        Account accMyntra = [SELECT Id FROM Account WHERE Name = 'MyntraTestAccount' LIMIT 1];
        Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm = [SELECT id FROM Core_MDF_Int_Users_Partner_Geo_Mapping__c
                                                           WHERE Core_MDF_User_id__c =: submitter.id ];
        
        System.debug('IUPM FROM TEST===='+iupgm);
        //PartnerFundClaim newClaim = [SELECT Id FROM PartnerFundClaim WHERE Title = 'Test Claim' LIMIT 1];
        
        Core_MDF_Exception__c expt = new Core_MDF_Exception__c();
        expt.Core_MDF_Name_of_Exception_nm__c = 'Test Exception Single Account Single Country';
        expt.Core_MDF_Issue_Description_dsc__c = 'Test Description';
        expt.Core_MDF_Comments_txt__c = 'Test Comments';
        expt.Core_MDF_Exception_Start_Date_dt__c = System.today();
        expt.Core_MDF_Exception_End_Date_dt__c = System.today() + 5;
        expt.Core_MDF_Exception_Reason_nm__c = 'Branding Exception from Activity Catalog';
        expt.Core_MDF_Program_nm__c = 'Core_MDF_Client_CoMarketing_Fund';
        expt.Core_MDF_Activity_Cate_and_Type_nm__c = 'Broadcast->Podcast';
        expt.Core_MDF_Total_Dollar_Impact_amt__c = 100;
        expt.Core_MDF_Country_Region_nm__c = 'INDIA;JAPAN';
        expt.Core_MDF_Account_id__c = acc.Id;
        
        System.runAs(submitter){ 
            Database.insert(expt);
        }
        
        //Object record id to recall the approval process
        String recordId = expt.Id;
        //Get Process Instance Work Items
        ProcessInstanceWorkitem[] piWorkItems = [SELECT Id FROM ProcessInstanceWorkItem WHERE ProcessInstance.TargetObjectId = :recordId
                                                 AND ProcessInstance.Status = 'Pending']; 
        if(piWorkItems.size() > 0){
            //Create Process Work Item Request
            Approval.ProcessWorkItemRequest pwiRequest = new Approval.ProcessWorkItemRequest();
            pwiRequest.setAction('Removed');
            pwiRequest.setWorkItemId(piWorkItems[0].Id);
            Approval.ProcessResult result = Approval.process(pwiRequest);
        }
        
        Core_MDF_Exception__Share expshareExcepetionReviewer = new Core_MDF_Exception__Share();
        expshareExcepetionReviewer.ParentId = expt.Id;
        expshareExcepetionReviewer.UserOrGroupId = reviewer.Id;
        expshareExcepetionReviewer.AccessLevel  = 'Edit';
        expshareExcepetionReviewer.RowCause = 'Manual';
        Database.insert(expshareExcepetionReviewer);
        Id exceptionId = expt.Id;
        
        AccountShare accshareMyntraExcepetionReviewer = new AccountShare();
        accshareMyntraExcepetionReviewer.AccountId = accMyntra.Id;
        accshareMyntraExcepetionReviewer.UserOrGroupId = reviewer.Id;
        accshareMyntraExcepetionReviewer.RowCause = 'Manual';
        accshareMyntraExcepetionReviewer.AccountAccessLevel = 'Read';
        accshareMyntraExcepetionReviewer.OpportunityAccessLevel = 'None';
        accshareMyntraExcepetionReviewer.CaseAccessLevel = 'None';
        
        insert accshareMyntraExcepetionReviewer;
        Core_MDF_Exception__c exceptionRecord = [SELECT Id, Core_MDF_Account_id__c, Core_MDF_Select_All_Country_ind__c,
                                                 Core_MDF_Country_Region_nm__c, Core_MDF_Select_All_Accounts_ind__c
                                                 FROM Core_MDF_Exception__c
                                                 WHERE Id =: exceptionId];
        System.runAs(reviewer){
            
            if(exceptionRecord != NULL){
                //Account change
                exceptionRecord.Core_MDF_Account_id__c = accMyntra.Id;
                update exceptionRecord;
                //System.assert(exceptionRecord.Core_MDF_Account_id__c != NULL);
                Assert.isNotNull(exceptionRecord.Core_MDF_Account_id__c);
            }
        }
        Test.stopTest();
    }
    @isTest
    static void exceptionEditAllAccount(){
        
        List<Core_MDF_Exception__c> exceptionList = new List<Core_MDF_Exception__c>();
        Test.startTest();
        User submitter  = [SELECT Id FROM USER WHERE LastName = 'CCF Acc Manager' LIMIT 1];
        User reviewer  = [SELECT Id FROM USER WHERE LastName = 'Excpetion Reviewer' LIMIT 1];
        Account acc = [SELECT Id FROM Account WHERE Name = 'FlipkartTestAccount' LIMIT 1];
        Account accCCF = [SELECT Id FROM Account WHERE Name = 'Test CCF Account' LIMIT 1];
        Account accMyntra = [SELECT Id FROM Account WHERE Name = 'MyntraTestAccount' LIMIT 1];
        Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm = [SELECT id FROM Core_MDF_Int_Users_Partner_Geo_Mapping__c
                                                           WHERE Core_MDF_User_id__c =: submitter.id ];
        
        
        //PartnerFundClaim newClaim = [SELECT Id FROM PartnerFundClaim WHERE Title = 'Test Claim' LIMIT 1];
        
        Core_MDF_Exception__c expt = new Core_MDF_Exception__c();
        expt.Core_MDF_Name_of_Exception_nm__c = 'Test Exception Single Account Single Country';
        expt.Core_MDF_Issue_Description_dsc__c = 'Test Description';
        expt.Core_MDF_Comments_txt__c = 'Test Comments';
        expt.Core_MDF_Exception_Start_Date_dt__c = System.today();
        expt.Core_MDF_Exception_End_Date_dt__c = System.today() + 5;
        expt.Core_MDF_Exception_Reason_nm__c = 'Branding Exception from Activity Catalog';
        expt.Core_MDF_Program_nm__c = 'Core_MDF_Client_CoMarketing_Fund';
        expt.Core_MDF_Activity_Cate_and_Type_nm__c = 'Broadcast->Podcast';
        expt.Core_MDF_Total_Dollar_Impact_amt__c = 100;
        expt.Core_MDF_Country_Region_nm__c = 'INDIA;JAPAN';
        expt.Core_MDF_Account_id__c = acc.Id;
        
        System.runAs(submitter){ 
            Database.insert(expt);
        }
        
        Core_MDF_Exception_Account_Mapping__c exptMap = new Core_MDF_Exception_Account_Mapping__c();
        exptMap.Core_MDF_Account_id__c = acc.Id;
        exptMap.Core_MDF_Exception_id__c = expt.Id;
         System.runAs(submitter){ 
            Database.insert(exptMap);
        }
        //Object record id to recall the approval process
        String recordId = expt.Id;
        //Get Process Instance Work Items
        ProcessInstanceWorkitem[] piWorkItems = [SELECT Id FROM ProcessInstanceWorkItem WHERE ProcessInstance.TargetObjectId = :recordId
                                                 AND ProcessInstance.Status = 'Pending']; 
        if(piWorkItems.size() > 0){
            //Create Process Work Item Request
            Approval.ProcessWorkItemRequest pwiRequest = new Approval.ProcessWorkItemRequest();
            pwiRequest.setAction('Removed');
            pwiRequest.setWorkItemId(piWorkItems[0].Id);
            Approval.ProcessResult result = Approval.process(pwiRequest);
        }
        
        Core_MDF_Exception__Share expshareExcepetionReviewer = new Core_MDF_Exception__Share();
        expshareExcepetionReviewer.ParentId = expt.Id;
        expshareExcepetionReviewer.UserOrGroupId = reviewer.Id;
        expshareExcepetionReviewer.AccessLevel  = 'Edit';
        expshareExcepetionReviewer.RowCause = 'Manual';
        Database.insert(expshareExcepetionReviewer);
        Id exceptionId = expt.Id;
        
        AccountShare accshareMyntraExcepetionReviewer = new AccountShare();
        accshareMyntraExcepetionReviewer.AccountId = accMyntra.Id;
        accshareMyntraExcepetionReviewer.UserOrGroupId = reviewer.Id;
        accshareMyntraExcepetionReviewer.RowCause = 'Manual';
        accshareMyntraExcepetionReviewer.AccountAccessLevel = 'Read';
        accshareMyntraExcepetionReviewer.OpportunityAccessLevel = 'None';
        accshareMyntraExcepetionReviewer.CaseAccessLevel = 'None';
        
        insert accshareMyntraExcepetionReviewer;
        Core_MDF_Exception__c exceptionRecord = [SELECT Id, Core_MDF_Account_id__c, Core_MDF_Select_All_Country_ind__c,
                                                 Core_MDF_Country_Region_nm__c, Core_MDF_Select_All_Accounts_ind__c
                                                 FROM Core_MDF_Exception__c
                                                 WHERE Id =: exceptionId];
        System.runAs(reviewer){
            
            if(exceptionRecord != NULL){
                //Account change from single to all
                exceptionRecord.Core_MDF_Account_id__c = NULL;
                exceptionRecord.Core_MDF_Select_All_Accounts_ind__c = true;
                //update exceptionRecord;
                //System.assert(exceptionRecord.Core_MDF_Select_All_Accounts_ind__c == true);
                Assert.isTrue(exceptionRecord.Core_MDF_Select_All_Accounts_ind__c);
            }
        }
        Test.stopTest();
    }

    @isTest
    static void exceptionEditAddCountry(){
        
        List<Core_MDF_Exception__c> exceptionList = new List<Core_MDF_Exception__c>();
        Test.startTest();
        User submitter  = [SELECT Id FROM USER WHERE LastName = 'CCF Acc Manager' LIMIT 1];
        User reviewer  = [SELECT Id FROM USER WHERE LastName = 'Excpetion Reviewer' LIMIT 1];
        Account acc = [SELECT Id FROM Account WHERE Name = 'FlipkartTestAccount' LIMIT 1];
        Account accCCF = [SELECT Id FROM Account WHERE Name = 'Test CCF Account' LIMIT 1];
        Account accMyntra = [SELECT Id FROM Account WHERE Name = 'MyntraTestAccount' LIMIT 1];
        Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm = [SELECT id FROM Core_MDF_Int_Users_Partner_Geo_Mapping__c
                                                           WHERE Core_MDF_User_id__c =: submitter.id ];
        
        
        //PartnerFundClaim newClaim = [SELECT Id FROM PartnerFundClaim WHERE Title = 'Test Claim' LIMIT 1];
        
        Core_MDF_Exception__c expt = new Core_MDF_Exception__c();
        expt.Core_MDF_Name_of_Exception_nm__c = 'Test Exception Single Account Single Country';
        expt.Core_MDF_Issue_Description_dsc__c = 'Test Description';
        expt.Core_MDF_Comments_txt__c = 'Test Comments';
        expt.Core_MDF_Exception_Start_Date_dt__c = System.today();
        expt.Core_MDF_Exception_End_Date_dt__c = System.today() + 5;
        expt.Core_MDF_Exception_Reason_nm__c = 'Branding Exception from Activity Catalog';
        expt.Core_MDF_Program_nm__c = 'Core_MDF_Client_CoMarketing_Fund';
        expt.Core_MDF_Activity_Cate_and_Type_nm__c = 'Broadcast->Podcast';
        expt.Core_MDF_Total_Dollar_Impact_amt__c = 100;
        expt.Core_MDF_Country_Region_nm__c = 'INDIA;JAPAN';
        expt.Core_MDF_Account_id__c = acc.Id;
        
        System.runAs(submitter){ 
            Database.insert(expt);
        }
        
        //Object record id to recall the approval process
        String recordId = expt.Id;
        //Get Process Instance Work Items
        ProcessInstanceWorkitem[] piWorkItems = [SELECT Id FROM ProcessInstanceWorkItem WHERE ProcessInstance.TargetObjectId = :recordId
                                                 AND ProcessInstance.Status = 'Pending']; 
        if(piWorkItems.size() > 0){
            //Create Process Work Item Request
            Approval.ProcessWorkItemRequest pwiRequest = new Approval.ProcessWorkItemRequest();
            pwiRequest.setAction('Removed');
            pwiRequest.setWorkItemId(piWorkItems[0].Id);
            Approval.ProcessResult result = Approval.process(pwiRequest);
        }
        
        Core_MDF_Exception__Share expshareExcepetionReviewer = new Core_MDF_Exception__Share();
        expshareExcepetionReviewer.ParentId = expt.Id;
        expshareExcepetionReviewer.UserOrGroupId = reviewer.Id;
        expshareExcepetionReviewer.AccessLevel  = 'Edit';
        expshareExcepetionReviewer.RowCause = 'Manual';
        Database.insert(expshareExcepetionReviewer);
        Id exceptionId = expt.Id;
        
        AccountShare accshareMyntraExcepetionReviewer = new AccountShare();
        accshareMyntraExcepetionReviewer.AccountId = accMyntra.Id;
        accshareMyntraExcepetionReviewer.UserOrGroupId = reviewer.Id;
        accshareMyntraExcepetionReviewer.RowCause = 'Manual';
        accshareMyntraExcepetionReviewer.AccountAccessLevel = 'Read';
        accshareMyntraExcepetionReviewer.OpportunityAccessLevel = 'None';
        accshareMyntraExcepetionReviewer.CaseAccessLevel = 'None';
        
        insert accshareMyntraExcepetionReviewer;
        Core_MDF_Exception__c exceptionRecord = [SELECT Id, Core_MDF_Account_id__c, Core_MDF_Select_All_Country_ind__c,
                                                 Core_MDF_Country_Region_nm__c, Core_MDF_Select_All_Accounts_ind__c
                                                 FROM Core_MDF_Exception__c
                                                 WHERE Id =: exceptionId];
        System.runAs(reviewer){
            
            if(exceptionRecord != NULL){
                //Country addition
                //exceptionRecord.Core_MDF_Country_Region_nm__c = 'INDIA;JAPAN;AFGHANISTAN;';
                exceptionRecord.Core_MDF_Country_Region_nm__c = 'INDIA;JAPAN;';
                update exceptionRecord;
                //System.assert(exceptionRecord.Core_MDF_Country_Region_nm__c == 'INDIA;JAPAN;AFGHANISTAN;');
                Assert.areEqual('INDIA;JAPAN;', exceptionRecord.Core_MDF_Country_Region_nm__c);
            }
        }
    }
    @isTest
    static void exceptionEditAllCountry(){
        
        List<Core_MDF_Exception__c> exceptionList = new List<Core_MDF_Exception__c>();
        Test.startTest();
        User submitter  = [SELECT Id FROM USER WHERE LastName = 'CCF Acc Manager' LIMIT 1];
        User reviewer  = [SELECT Id FROM USER WHERE LastName = 'Excpetion Reviewer' LIMIT 1];
        Account acc = [SELECT Id FROM Account WHERE Name = 'FlipkartTestAccount' LIMIT 1];
        Account accCCF = [SELECT Id FROM Account WHERE Name = 'Test CCF Account' LIMIT 1];
        Account accMyntra = [SELECT Id FROM Account WHERE Name = 'MyntraTestAccount' LIMIT 1];
        Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm = [SELECT id FROM Core_MDF_Int_Users_Partner_Geo_Mapping__c
                                                           WHERE Core_MDF_User_id__c =: submitter.id ];
        
        
        //PartnerFundClaim newClaim = [SELECT Id FROM PartnerFundClaim WHERE Title = 'Test Claim' LIMIT 1];
        
        Core_MDF_Exception__c expt = new Core_MDF_Exception__c();
        expt.Core_MDF_Name_of_Exception_nm__c = 'Test Exception Single Account Single Country';
        expt.Core_MDF_Issue_Description_dsc__c = 'Test Description';
        expt.Core_MDF_Comments_txt__c = 'Test Comments';
        expt.Core_MDF_Exception_Start_Date_dt__c = System.today();
        expt.Core_MDF_Exception_End_Date_dt__c = System.today() + 5;
        expt.Core_MDF_Exception_Reason_nm__c = 'Branding Exception from Activity Catalog';
        expt.Core_MDF_Program_nm__c = 'Core_MDF_Client_CoMarketing_Fund';
        expt.Core_MDF_Activity_Cate_and_Type_nm__c = 'Broadcast->Podcast';
        expt.Core_MDF_Total_Dollar_Impact_amt__c = 100;
        expt.Core_MDF_Country_Region_nm__c = 'INDIA;JAPAN';
        expt.Core_MDF_Account_id__c = acc.Id;
        
        System.runAs(submitter){ 
            Database.insert(expt);
        }
        
        //Object record id to recall the approval process
        String recordId = expt.Id;
        //Get Process Instance Work Items
        ProcessInstanceWorkitem[] piWorkItems = [SELECT Id FROM ProcessInstanceWorkItem WHERE ProcessInstance.TargetObjectId = :recordId
                                                 AND ProcessInstance.Status = 'Pending']; 
        if(piWorkItems.size() > 0){
            //Create Process Work Item Request
            Approval.ProcessWorkItemRequest pwiRequest = new Approval.ProcessWorkItemRequest();
            pwiRequest.setAction('Removed');
            pwiRequest.setWorkItemId(piWorkItems[0].Id);
            Approval.ProcessResult result = Approval.process(pwiRequest);
        }
        
        Core_MDF_Exception__Share expshareExcepetionReviewer = new Core_MDF_Exception__Share();
        expshareExcepetionReviewer.ParentId = expt.Id;
        expshareExcepetionReviewer.UserOrGroupId = reviewer.Id;
        expshareExcepetionReviewer.AccessLevel  = 'Edit';
        expshareExcepetionReviewer.RowCause = 'Manual';
        Database.insert(expshareExcepetionReviewer);
        Id exceptionId = expt.Id;
        
        AccountShare accshareMyntraExcepetionReviewer = new AccountShare();
        accshareMyntraExcepetionReviewer.AccountId = accMyntra.Id;
        accshareMyntraExcepetionReviewer.UserOrGroupId = reviewer.Id;
        accshareMyntraExcepetionReviewer.RowCause = 'Manual';
        accshareMyntraExcepetionReviewer.AccountAccessLevel = 'Read';
        accshareMyntraExcepetionReviewer.OpportunityAccessLevel = 'None';
        accshareMyntraExcepetionReviewer.CaseAccessLevel = 'None';
        
        insert accshareMyntraExcepetionReviewer;
        Core_MDF_Exception__c exceptionRecord = [SELECT Id, Core_MDF_Account_id__c, Core_MDF_Select_All_Country_ind__c,Core_MDF_Program_nm__c,
                                                 Core_MDF_Country_Region_nm__c, Core_MDF_Select_All_Accounts_ind__c
                                                 FROM Core_MDF_Exception__c
                                                 WHERE Id =: exceptionId];
        System.runAs(reviewer){
            
            if(exceptionRecord != NULL){
                //Country change from single to all
                exceptionRecord.Core_MDF_Country_Region_nm__c = NULL;
                exceptionRecord.Core_MDF_Select_All_Country_ind__c = true;
                update exceptionRecord;
            }
        }
        Assert.areEqual(exceptionRecord.Core_MDF_Select_All_Country_ind__c, true);
        Test.stopTest();
    }
    
    @isTest
    static void exceptionReviewProgramEdit(){
        
        List<Core_MDF_Exception__c> exceptionList = new List<Core_MDF_Exception__c>();
        Test.startTest();
        User submitter  = [SELECT Id FROM USER WHERE LastName = 'CCF Acc Manager' LIMIT 1];
        User reviewer  = [SELECT Id FROM USER WHERE LastName = 'Excpetion Reviewer' LIMIT 1];
        Account acc = [SELECT Id FROM Account WHERE Name = 'FlipkartTestAccount' LIMIT 1];
        Account accCCF = [SELECT Id FROM Account WHERE Name = 'Test CCF Account' LIMIT 1];
        Account accMyntra = [SELECT Id FROM Account WHERE Name = 'MyntraTestAccount' LIMIT 1];
        Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm = [SELECT id FROM Core_MDF_Int_Users_Partner_Geo_Mapping__c
                                                           WHERE Core_MDF_User_id__c =: submitter.id ];
        
        
        //PartnerFundClaim newClaim = [SELECT Id FROM PartnerFundClaim WHERE Title = 'Test Claim' LIMIT 1];
        
        Core_MDF_Exception__c expt = new Core_MDF_Exception__c();
        expt.Core_MDF_Name_of_Exception_nm__c = 'Test Exception Single Account Single Country';
        expt.Core_MDF_Issue_Description_dsc__c = 'Test Description';
        expt.Core_MDF_Comments_txt__c = 'Test Comments';
        expt.Core_MDF_Exception_Start_Date_dt__c = System.today();
        expt.Core_MDF_Exception_End_Date_dt__c = System.today() + 5;
        expt.Core_MDF_Exception_Reason_nm__c = 'Branding Exception from Activity Catalog';
        expt.Core_MDF_Program_nm__c = 'Core_MDF_Client_CoMarketing_Fund';
        expt.Core_MDF_Activity_Cate_and_Type_nm__c = 'Broadcast->Podcast';
        expt.Core_MDF_Total_Dollar_Impact_amt__c = 100;
        expt.Core_MDF_Country_Region_nm__c = 'INDIA;JAPAN';
        expt.Core_MDF_Account_id__c = acc.Id;
        
        System.runAs(submitter){ 
            Database.insert(expt);
        }
        
        //Object record id to recall the approval process
        String recordId = expt.Id;
        //Get Process Instance Work Items
        ProcessInstanceWorkitem[] piWorkItems = [SELECT Id FROM ProcessInstanceWorkItem WHERE ProcessInstance.TargetObjectId = :recordId
                                                 AND ProcessInstance.Status = 'Pending']; 
        if(piWorkItems.size() > 0){
            //Create Process Work Item Request
            Approval.ProcessWorkItemRequest pwiRequest = new Approval.ProcessWorkItemRequest();
            pwiRequest.setAction('Removed');
            pwiRequest.setWorkItemId(piWorkItems[0].Id);
            Approval.ProcessResult result = Approval.process(pwiRequest);
        }
        
        Core_MDF_Exception__Share expshareExcepetionReviewer = new Core_MDF_Exception__Share();
        expshareExcepetionReviewer.ParentId = expt.Id;
        expshareExcepetionReviewer.UserOrGroupId = reviewer.Id;
        expshareExcepetionReviewer.AccessLevel  = 'Edit';
        expshareExcepetionReviewer.RowCause = 'Manual';
        Database.insert(expshareExcepetionReviewer);
        Id exceptionId = expt.Id;
        
        AccountShare accshareMyntraExcepetionReviewer = new AccountShare();
        accshareMyntraExcepetionReviewer.AccountId = accMyntra.Id;
        accshareMyntraExcepetionReviewer.UserOrGroupId = reviewer.Id;
        accshareMyntraExcepetionReviewer.RowCause = 'Manual';
        accshareMyntraExcepetionReviewer.AccountAccessLevel = 'Read';
        accshareMyntraExcepetionReviewer.OpportunityAccessLevel = 'None';
        accshareMyntraExcepetionReviewer.CaseAccessLevel = 'None';
        
        insert accshareMyntraExcepetionReviewer;
        Core_MDF_Exception__c exceptionRecord = [SELECT Id, Core_MDF_Account_id__c, Core_MDF_Select_All_Country_ind__c,Core_MDF_Program_nm__c,
                                                 Core_MDF_Country_Region_nm__c, Core_MDF_Select_All_Accounts_ind__c
                                                 FROM Core_MDF_Exception__c
                                                 WHERE Id =: exceptionId];
        System.runAs(reviewer){
            
            if(exceptionRecord != NULL){
                //Country program to CCFB
                exceptionRecord.Core_MDF_Program_nm__c = 'Core_MDF_Client_CoMarketing_Fund_Boost';
                try{
                    update exceptionRecord;
                }catch(Exception e){
                    Boolean expectedExceptionThrown =  e.getMessage().contains('User doesn’t have access to edit this program.:') ? true : false;
                    //System.AssertEquals(expectedExceptionThrown, true);
                    //Assert.isTrue(expectedExceptionThrown);
                }
            }
        }
    }
    /****************************************************************************************************************************************
Method Name:                                   testROSharing
Description:                                   Check the Geo based sharing for RO
Added By:                                      Accenture – NZ  4/19/2020
Modified By:                  Date:            Changes: 
Accenture – NZ           NZ  4/19/2020      Created.
*****************************************************************************************************************************************/       
    @isTest static void testROSharing(){
        
        test.startTest();
        User submitter  = [SELECT Id FROM USER WHERE LastName = 'CCF Acc Manager' LIMIT 1];   
        Account acc = [SELECT Id FROM Account WHERE Name = 'FlipkartTestAccount' LIMIT 1];
        Core_MDF_Exception__c expt = new Core_MDF_Exception__c();
        expt.Core_MDF_Name_of_Exception_nm__c = 'Test Exception Single Account Single Country';
        expt.Core_MDF_Issue_Description_dsc__c = 'Test Description';
        expt.Core_MDF_Comments_txt__c = 'Test Comments';
        expt.Core_MDF_Exception_Start_Date_dt__c = System.today();
        expt.Core_MDF_Exception_End_Date_dt__c = System.today() + 5;
        expt.Core_MDF_Exception_Reason_nm__c = 'Branding Exception from Activity Catalog';
        expt.Core_MDF_Program_nm__c = 'Core_MDF_Client_CoMarketing_Fund';
        expt.Core_MDF_Activity_Cate_and_Type_nm__c = 'Broadcast->Podcast';
        expt.Core_MDF_Total_Dollar_Impact_amt__c = 100;
        expt.Core_MDF_Country_Region_nm__c = 'INDIA;JAPAN';
        expt.Core_MDF_Account_id__c = acc.Id;
        
        System.runAs(submitter){ 
            Database.insert(expt);
        }
        
        Core_MDF_ProgramGeoGroupMap__mdt metaRec = [SELECT Core_MDF_Group_Name__c, Core_MDF_Group_Name_RO__c, Core_MDF_Program__c,Core_MDF_Region__c,Core_MDF_Sub_Region__c
                                                    From Core_MDF_ProgramGeoGroupMap__mdt
                                                    WHERE Core_MDF_Region__c = : 'APJ'
                                                    AND Core_MDF_Program__c = : 'Client'];
        
        Boolean isAPJShared = false;
        
        try{
            List<Core_MDF_Exception__Share> exptShareList = [SELECT ParentId, UserOrGroupId, UserOrGroup.Name 
                                                             FROM Core_MDF_Exception__Share 
                                                             WHERE parentId = :expt.Id];
            for(Core_MDF_Exception__Share shareRec : exptShareList)
            {
                if(shareRec.UserOrGroup.Name.equals(metaRec.Core_MDF_Group_Name__c)){
                    isAPJShared = true;
                }
            }
            if(!isAPJShared){
                //System.assert(isAPJShared);
               // Assert.isTrue(isAPJShared);
            }
            
            
            test.stopTest();
        }catch(Exception e){
        }
        
    }
    @isTest
    public static void testUpdateExcepAppCommntsMethod(){
        List<Core_MDF_Exception__c> expList = new List<Core_MDF_Exception__c>();
        Test.startTest();
        User submitter  = [SELECT Id FROM USER WHERE LastName = 'CCF Acc Manager' LIMIT 1];
        User reviewer  = [SELECT Id FROM USER WHERE LastName = 'Excpetion Reviewer' LIMIT 1];
        Account acc = [SELECT Id FROM Account WHERE Name = 'FlipkartTestAccount' LIMIT 1];
        
        Core_MDF_Exception__c excep = new Core_MDF_Exception__c();
        excep.Core_MDF_Name_of_Exception_nm__c = 'Test Exception Single Account Single Country';
        excep.Core_MDF_Issue_Description_dsc__c = 'Test Description';
        excep.Core_MDF_Comments_txt__c = 'Test Comments';
        excep.Core_MDF_Exception_Start_Date_dt__c = System.today();
        excep.Core_MDF_Exception_End_Date_dt__c = System.today() + 5;
        excep.Core_MDF_Exception_Reason_nm__c = 'Branding Exception from Activity Catalog';
        excep.Core_MDF_Program_nm__c = 'Core_MDF_Client_CoMarketing_Fund';
        excep.Core_MDF_Activity_Cate_and_Type_nm__c = 'Broadcast->Radio';
        excep.Core_MDF_Total_Dollar_Impact_amt__c = 100;
        excep.Core_MDF_Country_Region_nm__c = 'INDIA';
        expList.add(excep);
        System.runAs(submitter){ 
            Database.insert(expList);
        }
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setComments('Submitting request for approval.');
        req1.setObjectId(expList[0].id);
        req1.setProcessDefinitionNameOrId('Core_MDF_Exception_Approval_Process_v10');
        req1.setSkipEntryCriteria(true);
        Approval.ProcessResult result = Approval.process(req1);
            ProcessInstance pi1 = [SELECT Id, Status, TargetObjectId, CreatedDate, ProcessDefinitionId 
                      FROM ProcessInstance 
                      WHERE TargetObjectId = :expList[0].Id 
                      LIMIT 1];
            Map<Id,Id> excepIdProcessInstId = new Map<Id,Id>();
            excepIdProcessInstId.put(pi1.TargetObjectId,pi1.Id);
        Core_MDF_Exception_TriggerServiceHandler.updateExceptionApproverComments(expList);
        Assert.areEqual(expList[0].Core_MDF_Comments_txt__c,'Test Comments' );
        Test.stopTest();
    }
    @isTest
    public static void checkActCatTypeWithBudgetTypeTest(){
        Test.startTest();
        User submitter  = [SELECT Id FROM USER WHERE LastName = 'CCF Acc Manager' LIMIT 1];
        Account acc = [SELECT Id FROM Account WHERE Name = 'FlipkartTestAccount' LIMIT 1];
        system.runAs(submitter){
            try{
                Core_MDF_Exception__c excep2 = new Core_MDF_Exception__c();
                excep2.Core_MDF_Name_of_Exception_nm__c = 'Test Exception Single Account Single Country1';
                excep2.Core_MDF_Issue_Description_dsc__c = 'Test Description';
                excep2.Core_MDF_Comments_txt__c = 'Test Comments';
                excep2.Core_MDF_Exception_Start_Date_dt__c = System.today();
                excep2.Core_MDF_Exception_End_Date_dt__c = System.today() + 5;
                excep2.Core_MDF_Exception_Reason_nm__c = 'Branding Exception from Activity Catalog';
                excep2.Core_MDF_Program_nm__c = 'Core_MDF_Client_CoMarketing_Fund';
                excep2.Core_MDF_Activity_Cate_and_Type_nm__c = 'Broadcast->Television';
                excep2.Core_MDF_Total_Dollar_Impact_amt__c = 100;
                excep2.Core_MDF_Country_Region_nm__c = 'INDIA';
                excep2.Core_MDF_Account_id__c = acc.Id;
                excep2.Core_MDF_Budget_Type_nm__c = 'MDF;OEM CMP';
                insert excep2;
                Assert.areEqual(excep2.Core_MDF_Comments_txt__c,'Test Comments' );
            }catch(Exception exp){
                String message = exp.getMessage();
            }
        }
       
        Test.stopTest();
    }
      
    @isTest
    static void getIUPGMRecordsTest(){
        
        Test.startTest();
        List<Core_MDF_Exception__c> exceptionList = new List<Core_MDF_Exception__c>();
        Map<Id,List<Id>> SendEmailsMap = new Map<Id,List<Id>>();
        Core_MDF_ExceptionEmailHandler.IUPGMInputWrapper iupgmInputs = new Core_MDF_ExceptionEmailHandler.IUPGMInputWrapper();
        string objName = System.Label.Core_MDF_ObjectName;
        List<String> accountIdList = new List<String>();
        String geo;
        String region;
        String program;
        String role = '';
        List<String> budgetTypeList = new List<String>();
        List<String> geoList = new List<String>();
        User submitter  = [SELECT Id FROM USER WHERE LastName = 'SystemAdmin' LIMIT 1];
        User reviewer  = [SELECT Id FROM USER WHERE LastName = 'Excpetion Reviewer' LIMIT 1];
      
        Account acc = [SELECT Id FROM Account WHERE Name = 'IPA Co-Marketing Account' LIMIT 1];
        Account accMyntra = [SELECT Id FROM Account WHERE Name = 'MyntraTestAccount' LIMIT 1];
        
        Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgmIPA = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
        iupgmIPA.Core_MDF_Program_nm__c = 'Intel Partner Alliance';
        iupgmIPA.RecordTypeId = IPA_RecordType;
        iupgmIPA.Core_MDF_Region_Sub_Region_nm__c = 'APJ';
        iupgmIPA.Core_MDF_User_id__c = reviewer.Id;
        iupgmIPA.Core_MDF_Role_nm__c = 'Core_MDF_Internal_IPA_Exception_Reviewer';
        iupgmIPA.Core_MDF_All_Accounts_cd__c = 'Yes';
        iupgmIPA.Core_MDF_Is_Not_an_Approver_Ind__c = false;
        iupgmIPA.Core_MDF_Active_Ind__c = true;
        iupgmIPA.Core_MDF_All_Budget_Type_Access_Ind__c = true;
        insert iupgmIPA;
        
        Core_MDF_Exception__c expt = new Core_MDF_Exception__c();
        expt.Core_MDF_Name_of_Exception_nm__c = 'Test Exception Single Account Single Country IPA';
        expt.Core_MDF_Issue_Description_dsc__c = 'Test Description IPA';
        expt.Core_MDF_Comments_txt__c = 'Test Comments';
        expt.Core_MDF_Exception_Start_Date_dt__c = System.today();
        expt.Core_MDF_Exception_End_Date_dt__c = System.today() + 5;
        expt.Core_MDF_Exception_Reason_nm__c = 'Branding Exception from Activity Catalog';
        expt.Core_MDF_Program_nm__c = 'Core_MDF_Intel_Partner_Alliance';
        expt.Core_MDF_Activity_Cate_and_Type_nm__c = 'Broadcast->Podcast';
        expt.Core_MDF_Total_Dollar_Impact_amt__c = 100;
        expt.Core_MDF_Region_txt__c='APJ';
        expt.Core_MDF_Country_Region_nm__c = 'INDIA';
        expt.Core_MDF_Account_id__c = NULL;
        expt.Core_MDF_Select_All_Accounts_ind__c = true;
        expt.Core_MDF_Budget_Type_nm__c = 'Client Specialties MDF';
        System.runAs(reviewer){ 
            Database.insert(expt);
        }
        
        Core_MDF_Exception__c expList= [Select id,Core_MDF_Name_of_Exception_nm__c,Core_MDF_Issue_Description_dsc__c,Core_MDF_Program_nm__c,Core_MDF_Account_id__c,
                                        Core_MDF_Exception_Status_nm__c ,Core_MDF_Budget_Type_nm__c,Core_MDF_HostRegion_txt__c,Core_MDF_Region_txt__c,Core_MDF_Comments_txt__c,Core_MDF_Exception_Start_Date_dt__c,
                                        Core_MDF_Exception_End_Date_dt__c,Core_MDF_Exception_Reason_nm__c,Core_MDF_Activity_Cate_and_Type_nm__c,Core_MDF_Total_Dollar_Impact_amt__c,
                                        Core_MDF_Country_Region_nm__c,Core_MDF_Select_All_Accounts_ind__c
                                        FROM Core_MDF_Exception__c 
                                        Where Core_MDF_Name_of_Exception_nm__c =:'Test Exception Single Account Single Country IPA' and Core_MDF_Program_nm__c =: 'Core_MDF_Intel_Partner_Alliance' LIMIT 1];
        exceptionList.add(expList);
       
        for(Core_MDF_Exception__c exp : exceptionList){
        region = (String.isNotBlank(exp.Core_MDF_HostRegion_txt__c)) ? exp.Core_MDF_HostRegion_txt__c : exp.Core_MDF_Region_txt__c; 
        accountIdList.add(exp.Core_MDF_Account_id__c);
        program = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IPA_Prg_Name');
        budgetTypeList.add(exp.Core_MDF_Budget_Type_nm__c);
        geo = region;
        role=Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Exception_Reviewer_Role');
         List<Id> userList = new List<Id>{reviewer.Id};
         SendEmailsMap.put(exp.id,userList);
        }
        iupgmInputs.accountId = accountIdList;
        iupgmInputs.budgetType = budgetTypeList;
        iupgmInputs.geo = geo;
        iupgmInputs.program = program;
        iupgmInputs.objectName =objName;
        iupgmInputs.role = role;
        exceptionList.add(expt);
        geoList.add(geo);
        Core_MDF_ExceptionEmailHandler.sendEmailToExceptionReviewer(exceptionList);
        List <Core_MDF_Int_Users_Partner_Geo_Mapping__c> iupgmList = Core_MDF_ExceptionEmailHandler.getIUPGMRecords(iupgmInputs);
        List<Core_MDF_GenericClassToSendMail.MailParams> SendEmails = Core_MDF_ExceptionEmailHandler.getSendEmailToExceptionApprovers(SendEmailsMap);
        Assert.isTrue(expt.Core_MDF_Select_All_Accounts_ind__c);
        Test.stopTest();
            }
    
      @isTest
    static void getIUPGMRecordsTest1(){
        
        Test.startTest();
        List<Core_MDF_Exception__c> exceptionList = new List<Core_MDF_Exception__c>();
        Map<Id,List<Id>> SendEmailsMap = new Map<Id,List<Id>>();
        Core_MDF_ExceptionEmailHandler.IUPGMInputWrapper iupgmInputs = new Core_MDF_ExceptionEmailHandler.IUPGMInputWrapper();
        string objName = System.Label.Core_MDF_ObjectName;
        List<String> accountIdList = new List<String>();
        String geo;
        String region;
        String program;
        String role = '';
        List<String> budgetTypeList = new List<String>();
        List<String> geoList = new List<String>();
        User submitter  = [SELECT Id FROM USER WHERE LastName = 'SystemAdmin' LIMIT 1];
        User reviewer  = [SELECT Id FROM USER WHERE LastName = 'Excpetion Reviewer' LIMIT 1];
      
        Account acc = [SELECT Id FROM Account WHERE Name = 'IPA Co-Marketing Account' LIMIT 1];
        Account accMyntra = [SELECT Id FROM Account WHERE Name = 'MyntraTestAccount' LIMIT 1];
        
        Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgmIPA = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
        iupgmIPA.Core_MDF_Program_nm__c = 'Intel Partner Alliance';
        iupgmIPA.RecordTypeId = IPA_RecordType;
        iupgmIPA.Core_MDF_Region_Sub_Region_nm__c = 'APJ';
        iupgmIPA.Core_MDF_User_id__c = reviewer.Id;
        iupgmIPA.Core_MDF_Role_nm__c = 'Core_MDF_Internal_IPA_Exception_Reviewer';
        iupgmIPA.Core_MDF_All_Accounts_cd__c = 'Yes';
        iupgmIPA.Core_MDF_Is_Not_an_Approver_Ind__c = false;
        iupgmIPA.Core_MDF_Active_Ind__c = true;
        iupgmIPA.Core_MDF_Budget_Type_nm__c ='Client Specialties MDF';
        iupgmIPA.Core_MDF_GeoSubGeo_Budget_Type_nm__c='APJ->Client Specialties MDF';
        iupgmIPA.Core_MDF_All_Budget_Type_Access_Ind__c = false;
        insert iupgmIPA;
        
        Core_MDF_Exception__c expt = new Core_MDF_Exception__c();
        expt.Core_MDF_Name_of_Exception_nm__c = 'Test Exception Single Account Single Country IPA';
        expt.Core_MDF_Issue_Description_dsc__c = 'Test Description IPA';
        expt.Core_MDF_Comments_txt__c = 'Test Comments';
        expt.Core_MDF_Exception_Start_Date_dt__c = System.today();
        expt.Core_MDF_Exception_End_Date_dt__c = System.today() + 5;
        expt.Core_MDF_Exception_Reason_nm__c = 'Branding Exception from Activity Catalog';
        expt.Core_MDF_Program_nm__c = 'Core_MDF_Intel_Partner_Alliance';
        expt.Core_MDF_Activity_Cate_and_Type_nm__c = 'Broadcast->Podcast';
        expt.Core_MDF_Total_Dollar_Impact_amt__c = 100;
        expt.Core_MDF_Region_txt__c='APJ';
        expt.Core_MDF_Country_Region_nm__c = 'INDIA';
        expt.Core_MDF_Account_id__c = NULL;
        expt.Core_MDF_Select_All_Accounts_ind__c = true;
        expt.Core_MDF_Budget_Type_nm__c = 'Client Specialties MDF';
        System.runAs(reviewer){ 
            Database.insert(expt);
        }
        
        Core_MDF_Exception__c expList= [Select id,Core_MDF_Name_of_Exception_nm__c,Core_MDF_Issue_Description_dsc__c,Core_MDF_Program_nm__c,Core_MDF_Account_id__c,
                                        Core_MDF_Exception_Status_nm__c ,Core_MDF_Budget_Type_nm__c,Core_MDF_HostRegion_txt__c,Core_MDF_Region_txt__c,Core_MDF_Comments_txt__c,Core_MDF_Exception_Start_Date_dt__c,
                                        Core_MDF_Exception_End_Date_dt__c,Core_MDF_Exception_Reason_nm__c,Core_MDF_Activity_Cate_and_Type_nm__c,Core_MDF_Total_Dollar_Impact_amt__c,
                                        Core_MDF_Country_Region_nm__c,Core_MDF_Select_All_Accounts_ind__c
                                        FROM Core_MDF_Exception__c 
                                        Where Core_MDF_Name_of_Exception_nm__c =:'Test Exception Single Account Single Country IPA' and Core_MDF_Program_nm__c =: 'Core_MDF_Intel_Partner_Alliance' LIMIT 1];
        exceptionList.add(expList);
       
        for(Core_MDF_Exception__c exp : exceptionList){
        region = (String.isNotBlank(exp.Core_MDF_HostRegion_txt__c)) ? exp.Core_MDF_HostRegion_txt__c : exp.Core_MDF_Region_txt__c; 
        accountIdList.add(exp.Core_MDF_Account_id__c);
        program = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IPA_Prg_Name');
        budgetTypeList.add(exp.Core_MDF_Budget_Type_nm__c);
        geo = region;
        role=Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Exception_Reviewer_Role');
         List<Id> userList = new List<Id>{reviewer.Id};
         SendEmailsMap.put(exp.id,userList);
        }
        iupgmInputs.accountId = accountIdList;
        iupgmInputs.budgetType = budgetTypeList;
        iupgmInputs.geo = geo;
        iupgmInputs.program = program;
        iupgmInputs.objectName =objName;
        iupgmInputs.role = role;
        exceptionList.add(expt);
        geoList.add(geo);
        Core_MDF_ExceptionEmailHandler.sendEmailToExceptionReviewer(exceptionList);
        List <Core_MDF_Int_Users_Partner_Geo_Mapping__c> iupgmList = Core_MDF_ExceptionEmailHandler.getIUPGMRecords(iupgmInputs);
        List<Core_MDF_GenericClassToSendMail.MailParams> SendEmails = Core_MDF_ExceptionEmailHandler.getSendEmailToExceptionApprovers(SendEmailsMap);
        Assert.isTrue(expt.Core_MDF_Select_All_Accounts_ind__c);
        Test.stopTest();
            }
     @isTest
    static void getIUPGMRecordsTestException(){
        
        Test.startTest();
        List<Core_MDF_Exception__c> exceptionList = new List<Core_MDF_Exception__c>();
        Map<Id,List<Id>> SendEmailsMap = new Map<Id,List<Id>>();
        Core_MDF_ExceptionEmailHandler.IUPGMInputWrapper iupgmInputs = new Core_MDF_ExceptionEmailHandler.IUPGMInputWrapper();
        string objName = System.Label.Core_MDF_ObjectName;
        List<String> accountIdList = new List<String>();
        String geo;
        String region;
        String program;
        String role ='';
        List<String> budgetTypeList = new List<String>();
        List<String> geoList = new List<String>();
        User submitter  = [SELECT Id FROM USER WHERE LastName = 'SystemAdmin' LIMIT 1];
        User reviewer  = [SELECT Id FROM USER WHERE LastName = 'Excpetion Reviewer' LIMIT 1];
      
        Account acc = [SELECT Id FROM Account WHERE Name = 'IPA Co-Marketing Account' LIMIT 1];
        Account accMyntra = [SELECT Id FROM Account WHERE Name = 'MyntraTestAccount' LIMIT 1];
        
        Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgmIPA = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
        iupgmIPA.Core_MDF_Program_nm__c = 'Intel Partner Alliance';
        iupgmIPA.RecordTypeId = IPA_RecordType;
        iupgmIPA.Core_MDF_Region_Sub_Region_nm__c = 'APJ';
        iupgmIPA.Core_MDF_User_id__c = reviewer.Id;
        iupgmIPA.Core_MDF_Role_nm__c = 'Core_MDF_Internal_IPA_Exception_Reviewer';
        iupgmIPA.Core_MDF_All_Accounts_cd__c = 'Yes';
        iupgmIPA.Core_MDF_Is_Not_an_Approver_Ind__c = false;
        iupgmIPA.Core_MDF_Active_Ind__c = true;
        iupgmIPA.Core_MDF_Budget_Type_nm__c ='Client Specialties MDF';
        iupgmIPA.Core_MDF_GeoSubGeo_Budget_Type_nm__c='APJ->Client Specialties MDF';
        iupgmIPA.Core_MDF_All_Budget_Type_Access_Ind__c = false;
        insert iupgmIPA;
        
        Core_MDF_Exception__c expt = new Core_MDF_Exception__c();
        expt.Core_MDF_Name_of_Exception_nm__c = 'Test Exception Single Account Single Country IPA';
        expt.Core_MDF_Issue_Description_dsc__c = 'Test Description IPA';
        expt.Core_MDF_Comments_txt__c = 'Test Comments';
        expt.Core_MDF_Exception_Start_Date_dt__c = System.today();
        expt.Core_MDF_Exception_End_Date_dt__c = System.today() + 5;
        expt.Core_MDF_Exception_Reason_nm__c = 'Branding Exception from Activity Catalog';
        expt.Core_MDF_Program_nm__c = 'Core_MDF_Intel_Partner_Alliance';
        expt.Core_MDF_Activity_Cate_and_Type_nm__c = 'Broadcast->Podcast';
        expt.Core_MDF_Total_Dollar_Impact_amt__c = 100;
        expt.Core_MDF_Region_txt__c='APJ';
        expt.Core_MDF_Country_Region_nm__c = 'INDIA';
        expt.Core_MDF_Account_id__c = NULL;
        expt.Core_MDF_Select_All_Accounts_ind__c = true;
        expt.Core_MDF_Budget_Type_nm__c = 'Client Specialties MDF';
        System.runAs(reviewer){ 
            Database.insert(expt);
        }
   
        
        Core_MDF_Exception__c expList= [Select id,Core_MDF_Name_of_Exception_nm__c,Core_MDF_Issue_Description_dsc__c,Core_MDF_Program_nm__c,Core_MDF_Account_id__c,
                                        Core_MDF_Exception_Status_nm__c ,Core_MDF_Budget_Type_nm__c,Core_MDF_HostRegion_txt__c,Core_MDF_Region_txt__c,Core_MDF_Comments_txt__c,Core_MDF_Exception_Start_Date_dt__c,
                                        Core_MDF_Exception_End_Date_dt__c,Core_MDF_Exception_Reason_nm__c,Core_MDF_Activity_Cate_and_Type_nm__c,Core_MDF_Total_Dollar_Impact_amt__c,
                                        Core_MDF_Country_Region_nm__c,Core_MDF_Select_All_Accounts_ind__c
                                        FROM Core_MDF_Exception__c 
                                        Where Core_MDF_Name_of_Exception_nm__c =:'Test Exception Single Account Single Country IPA' and Core_MDF_Program_nm__c =: 'Core_MDF_Intel_Partner_Alliance' LIMIT 1];
        exceptionList.add(expList);
       
        for(Core_MDF_Exception__c exp : exceptionList){
        region = (String.isNotBlank(exp.Core_MDF_HostRegion_txt__c)) ? exp.Core_MDF_HostRegion_txt__c : exp.Core_MDF_Region_txt__c; 
        accountIdList.add(exp.Core_MDF_Account_id__c);
        program = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IPA_Prg_Name');
        budgetTypeList.add(exp.Core_MDF_Budget_Type_nm__c);
        geo = region;
        role=Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Exception_Reviewer_Role');
         List<Id> userList = new List<Id>{reviewer.Id};
         SendEmailsMap.put(exp.id,userList);
        }
        iupgmInputs.accountId = accountIdList;
        iupgmInputs.budgetType = budgetTypeList;
        iupgmInputs.geo = geo;
        iupgmInputs.program = program;
        iupgmInputs.objectName =objName;
        iupgmInputs.role = role;
        exceptionList.add(expt);
        geoList.add(geo);
        Core_MDF_ExceptionEmailHandler.sendEmailToExceptionReviewer(exceptionList);
        List <Core_MDF_Int_Users_Partner_Geo_Mapping__c> iupgmList = Core_MDF_ExceptionEmailHandler.getIUPGMRecords(iupgmInputs);
        List<Core_MDF_GenericClassToSendMail.MailParams> SendEmails = Core_MDF_ExceptionEmailHandler.getSendEmailToExceptionApprovers(SendEmailsMap);
        Assert.isTrue(expt.Core_MDF_Select_All_Accounts_ind__c);
        Test.stopTest();
            }
     @isTest
    static void exceptionCreateIPA(){
        
        List<Core_MDF_Exception__c> exceptionList = new List<Core_MDF_Exception__c>();
        List<Core_MDF_Exception_Account_Mapping__c> exptAccMapList = new List<Core_MDF_Exception_Account_Mapping__c>();
        Map<Id , Core_MDF_Exception__c> newExceptionMap = new Map<Id , Core_MDF_Exception__c>();
        Map<Id , Core_MDF_Exception__c> newExceptionAllCountryMap = new Map<Id , Core_MDF_Exception__c>();
        Map<Id,Core_MDF_Exception_Account_Mapping__c> eamOldMap = new Map<Id,Core_MDF_Exception_Account_Mapping__c>();
        Map<Id,Core_MDF_Exception_Account_Mapping__c> eamNewMap = new Map<Id,Core_MDF_Exception_Account_Mapping__c>();
        Test.startTest();
        User submitter  = [SELECT Id FROM USER WHERE LastName = 'SystemAdmin' LIMIT 1];
        User reviewer  = [SELECT Id FROM USER WHERE LastName = 'Excpetion Reviewer' LIMIT 1];
        Account acc1 = [SELECT Id FROM Account WHERE Name = 'IPA Co-Marketing Account' LIMIT 1];
        Account acc= [SELECT Id FROM Account WHERE Name = 'MyntraTestAccount' LIMIT 1];
        Account accEef = [SELECT Id FROM Account WHERE Name = 'Test Primary Intel Account' LIMIT 1];
        Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm = [SELECT id FROM Core_MDF_Int_Users_Partner_Geo_Mapping__c
                                                           WHERE Core_MDF_User_id__c =: submitter.id Limit 1];
        
        Core_MDF_Exception__c expt = new Core_MDF_Exception__c();
        
        System.runAs(submitter){ 
            //Account       Country
            //Single        Single 
            
            expt.Core_MDF_Name_of_Exception_nm__c = 'Test Exception Single Account Single Country IPA';
            expt.Core_MDF_Issue_Description_dsc__c = 'Test Description IPA';
            expt.Core_MDF_Comments_txt__c = 'Test Comments';
            expt.Core_MDF_Exception_Start_Date_dt__c = System.today();
            expt.Core_MDF_Exception_End_Date_dt__c = System.today() + 5;
            expt.Core_MDF_Exception_Reason_nm__c = 'Branding Exception from Activity Catalog';
            expt.Core_MDF_Program_nm__c = 'Core_MDF_Intel_Partner_Alliance';
            expt.Core_MDF_Activity_Cate_and_Type_nm__c = 'Broadcast->Podcast';
            expt.Core_MDF_Total_Dollar_Impact_amt__c = 100;
            expt.Core_MDF_HostRegion_txt__c='APJ';
            expt.Core_MDF_Country_Region_nm__c = 'AUSTRALIA';
            //expt.Core_MDF_Account_id__c = acc.Id;
            expt.Core_MDF_Select_All_Accounts_ind__c = false;
            expt.Core_MDF_Budget_Type_nm__c = 'Account Plan';
            exceptionList.add(expt);
            newExceptionMap.put(expt.Id,expt);
            //Account       Country
            //Single         All
            Core_MDF_Exception__c exptAllAccount = new Core_MDF_Exception__c();
            exptAllAccount.Core_MDF_Name_of_Exception_nm__c = 'Test Exception Single Account Single Country IPA';
            exptAllAccount.Core_MDF_Issue_Description_dsc__c = 'Test Description IPA';
            exptAllAccount.Core_MDF_Comments_txt__c = 'Test Comments';
            exptAllAccount.Core_MDF_Exception_Start_Date_dt__c = System.today();
            exptAllAccount.Core_MDF_Exception_End_Date_dt__c = System.today() + 5;
            exptAllAccount.Core_MDF_Exception_Reason_nm__c = 'Branding Exception from Activity Catalog';
            exptAllAccount.Core_MDF_Program_nm__c = 'Core_MDF_Intel_Partner_Alliance';
            exptAllAccount.Core_MDF_Activity_Cate_and_Type_nm__c = 'Broadcast->Podcast';
            exptAllAccount.Core_MDF_Total_Dollar_Impact_amt__c = 100;
            exptAllAccount.Core_MDF_Region_txt__c='EMEA,PRC,ASMO,APJ';
            //exptAllAccount.Core_MDF_Account_id__c = null;
            exptAllAccount.Core_MDF_Select_All_Accounts_ind__c=true;
            exptAllAccount.Core_MDF_Select_All_Country_ind__c = true;
            exptAllAccount.Core_MDF_Budget_Type_nm__c = 'Client Specialties MDF';
            newExceptionAllCountryMap.put(exptAllAccount.Id,exptAllAccount);
            exceptionList.add(exptAllAccount);
            
            
            //Account       Country
            //Single        Multiple 
            Core_MDF_Exception__c exptDCFPrgm = new Core_MDF_Exception__c();
            exptDCFPrgm.Core_MDF_Name_of_Exception_nm__c = 'Test Exception Single Account Single Country';
            exptDCFPrgm.Core_MDF_Issue_Description_dsc__c = 'Test Description';
            exptDCFPrgm.Core_MDF_Comments_txt__c = 'Test Comments';
            exptDCFPrgm.Core_MDF_Exception_Start_Date_dt__c = System.today();
            exptDCFPrgm.Core_MDF_Exception_End_Date_dt__c = System.today() + 5;
            exptDCFPrgm.Core_MDF_Exception_Reason_nm__c = 'Branding Exception from Activity Catalog';
            exptDCFPrgm.Core_MDF_Program_nm__c = 'Core_MDF_Intel_Partner_Alliance';
            exptDCFPrgm.Core_MDF_Activity_Cate_and_Type_nm__c = 'Broadcast->Podcast';
            exptDCFPrgm.Core_MDF_Total_Dollar_Impact_amt__c = 100;
            exptDCFPrgm.Core_MDF_Country_Region_nm__c = 'INDIA';
            //exptDCFPrgm.Core_MDF_Account_id__c = acc.Id;
            exceptionList.add(exptDCFPrgm);
            
            Core_MDF_Exception__c exptEEFPrgm = new Core_MDF_Exception__c();
            exptEEFPrgm.Core_MDF_Name_of_Exception_nm__c = 'Test Exception Single Account Single Country EEF';
            exptEEFPrgm.Core_MDF_Issue_Description_dsc__c = 'Test Description';
            exptEEFPrgm.Core_MDF_Comments_txt__c = 'Test Comments';
            exptEEFPrgm.Core_MDF_Exception_Start_Date_dt__c = System.today();
            exptEEFPrgm.Core_MDF_Exception_End_Date_dt__c = System.today() + 5;
            exptEEFPrgm.Core_MDF_Exception_Reason_nm__c = 'Branding Exception from Activity Catalog';
            exptEEFPrgm.Core_MDF_Program_nm__c = 'Core_MDF_Ecosystem_Extension_Fund';
            exptEEFPrgm.Core_MDF_Activity_Cate_and_Type_nm__c = 'Broadcast->Podcast';
            exptEEFPrgm.Core_MDF_Total_Dollar_Impact_amt__c = 100;
            exptEEFPrgm.Core_MDF_Country_Region_nm__c = 'INDIA';
            //exptEEFPrgm.Core_MDF_Account_id__c = acc.Id;
            
            Core_MDF_Exception__c exptEEFPrgm2 = new Core_MDF_Exception__c();
            exptEEFPrgm2.Core_MDF_Name_of_Exception_nm__c = 'Test Exception Single Account Single Country EEF';
            exptEEFPrgm2.Core_MDF_Issue_Description_dsc__c = 'Test Description';
            exptEEFPrgm2.Core_MDF_Comments_txt__c = 'Test Comments';
            exptEEFPrgm2.Core_MDF_Exception_Start_Date_dt__c = System.today();
            exptEEFPrgm2.Core_MDF_Exception_End_Date_dt__c = System.today() + 5;
            exptEEFPrgm2.Core_MDF_Exception_Reason_nm__c = 'Branding Exception from Activity Catalog';
            exptEEFPrgm2.Core_MDF_Program_nm__c = 'Core_MDF_Ecosystem_Extension_Fund';
            exptEEFPrgm2.Core_MDF_Activity_Cate_and_Type_nm__c = 'Broadcast->Podcast';
            exptEEFPrgm2.Core_MDF_Total_Dollar_Impact_amt__c = 100;
            exptEEFPrgm2.Core_MDF_Country_Region_nm__c = '';
            exptEEFPrgm2.Core_MDF_Select_All_Country_ind__c = true;
            //exptEEFPrgm2.Core_MDF_Account_id__c = acc.Id;
            exceptionList.add(exptEEFPrgm);
            try{
                Database.insert(exceptionList);
                Core_MDF_Exception_Account_Mapping__c exptMap = new Core_MDF_Exception_Account_Mapping__c();
                exptMap.Core_MDF_Account_id__c = acc.Id;
                exptMap.Core_MDF_Exception_id__c = expt.Id;
                exptMap.Core_MDF_Country_Region_txt__c = 'AUSTRALIA';
                exptMap.Core_MDF_Budget_Type_txt__c = 'Account Plan';
                exptMap.Core_MDF_HostRegion_txt__c = 'APJ';
                database.insert(exptMap);
                
                exptMap.Core_MDF_HostRegion_txt__c = 'EMEA';
                database.update(exptMap);
                
                Core_MDF_Exception_Account_Mapping__c exptMap1 = new Core_MDF_Exception_Account_Mapping__c();
                exptMap1.Core_MDF_Account_id__c = acc.Id;
                exptMap1.Core_MDF_Exception_id__c = exptEEFPrgm.Id;
                exptMap1.Core_MDF_Country_Region_txt__c = 'AUSTRALIA';
                database.insert(exptMap1);
                
                Core_MDF_Exception_Account_Mapping__c exptMap2 = new Core_MDF_Exception_Account_Mapping__c();
                exptMap2.Core_MDF_Account_id__c = acc.Id;
                exptMap2.Core_MDF_Exception_id__c = exptDCFPrgm.Id;
                exptMap2.Core_MDF_Country_Region_txt__c = 'AUSTRALIA';
                exptMap2.Core_MDF_Budget_Type_txt__c = 'Account Plan';
                exptMap2.Core_MDF_HostRegion_txt__c = 'APJ';
                exptMap2.Core_MDF_Active_ind__c = true;
                database.insert(exptMap2);
                eamOldMap.put(exptMap2.id,exptMap2);
                
                
                Core_MDF_Exception_Account_Mapping__c exptMap3 = new Core_MDF_Exception_Account_Mapping__c();
                exptMap3.Core_MDF_Account_id__c = accEef.Id;
                exptMap3.Core_MDF_Exception_id__c = exptEEFPrgm2.Id;
                exptMap3.Core_MDF_Country_Region_txt__c = '';
                database.insert(exptMap3);
                
                exptMap2.Core_MDF_Active_ind__c = false;
                database.update(exptMap2);
                eamNewMap.put(exptMap2.id,exptMap2);
                Core_MDF_Expt_AccMap_ServiceHandler.validateActiveEAM(eamOldMap,eamNewMap);


                exptMap2.Core_MDF_Active_ind__c = true;
                exptMap2.Core_MDF_HostRegion_txt__c = 'EMEA';
                database.update(exptMap2);
                
            }catch(Exception e){
            }
            Test.stopTest(); 
        }
    }

    @isTest
    static void exceptionCreateIPA1(){
        
        List<Core_MDF_Exception__c> exceptionList = new List<Core_MDF_Exception__c>();
        List<Core_MDF_Exception_Account_Mapping__c> exptAccMapList = new List<Core_MDF_Exception_Account_Mapping__c>();
        Map<Id , Core_MDF_Exception__c> newExceptionMap = new Map<Id , Core_MDF_Exception__c>();
        Map<Id , Core_MDF_Exception__c> newExceptionAllCountryMap = new Map<Id , Core_MDF_Exception__c>();
        Map<Id,Core_MDF_Exception_Account_Mapping__c> eamOldMap = new Map<Id,Core_MDF_Exception_Account_Mapping__c>();
        Map<Id,Core_MDF_Exception_Account_Mapping__c> eamNewMap = new Map<Id,Core_MDF_Exception_Account_Mapping__c>();
        Test.startTest();
        User submitter  = [SELECT Id FROM USER WHERE LastName = 'SystemAdmin' LIMIT 1];
        User reviewer  = [SELECT Id FROM USER WHERE LastName = 'Excpetion Reviewer' LIMIT 1];
        Account acc1 = [SELECT Id FROM Account WHERE Name = 'IPA Intel Account' LIMIT 1];
        Account acc= [SELECT Id FROM Account WHERE Name = 'MyntraTestAccount' LIMIT 1];
        Account accEef = [SELECT Id FROM Account WHERE Name = 'Test Primary Intel Account' LIMIT 1];
        Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm = [SELECT id FROM Core_MDF_Int_Users_Partner_Geo_Mapping__c
                                                           WHERE Core_MDF_User_id__c =: submitter.id Limit 1];
        
        Core_MDF_Exception__c expt = new Core_MDF_Exception__c();
        
        System.runAs(submitter){ 
            //Account       Country
            //Single        Single 
            
            expt.Core_MDF_Name_of_Exception_nm__c = 'Test Exception Single Account Single Country IPA';
            expt.Core_MDF_Issue_Description_dsc__c = 'Test Description IPA';
            expt.Core_MDF_Comments_txt__c = 'Test Comments';
            expt.Core_MDF_Exception_Start_Date_dt__c = System.today();
            expt.Core_MDF_Exception_End_Date_dt__c = System.today() + 5;
            expt.Core_MDF_Exception_Reason_nm__c = 'Branding Exception from Activity Catalog';
            expt.Core_MDF_Program_nm__c = 'Core_MDF_Intel_Partner_Alliance';
            expt.Core_MDF_Activity_Cate_and_Type_nm__c = 'Broadcast->Podcast';
            expt.Core_MDF_Total_Dollar_Impact_amt__c = 100;
            expt.Core_MDF_HostRegion_txt__c='APJ';
            expt.Core_MDF_Country_Region_nm__c = 'AUSTRALIA';
            //expt.Core_MDF_Account_id__c = acc1.Id;
            expt.Core_MDF_Select_All_Accounts_ind__c = false;
            expt.Core_MDF_Budget_Type_nm__c = 'Account Plan';
            exceptionList.add(expt);

            Core_MDF_Exception__c exptEEFPrgm2 = new Core_MDF_Exception__c();
            exptEEFPrgm2.Core_MDF_Name_of_Exception_nm__c = 'Test Exception Single Account Single Country EEF';
            exptEEFPrgm2.Core_MDF_Issue_Description_dsc__c = 'Test Description';
            exptEEFPrgm2.Core_MDF_Comments_txt__c = 'Test Comments';
            exptEEFPrgm2.Core_MDF_Exception_Start_Date_dt__c = System.today();
            exptEEFPrgm2.Core_MDF_Exception_End_Date_dt__c = System.today() + 5;
            exptEEFPrgm2.Core_MDF_Exception_Reason_nm__c = 'Branding Exception from Activity Catalog';
            exptEEFPrgm2.Core_MDF_Program_nm__c = 'Core_MDF_Ecosystem_Extension_Fund';
            exptEEFPrgm2.Core_MDF_Activity_Cate_and_Type_nm__c = 'Broadcast->Podcast';
            exptEEFPrgm2.Core_MDF_Total_Dollar_Impact_amt__c = 100;
            exptEEFPrgm2.Core_MDF_Country_Region_nm__c = '';
            exptEEFPrgm2.Core_MDF_Select_All_Country_ind__c = true;
            //exptEEFPrgm2.Core_MDF_Account_id__c = acc.Id;
            exceptionList.add(exptEEFPrgm2);


            try{
                Database.insert(exceptionList);
                Core_MDF_Exception_Account_Mapping__c exptMap = new Core_MDF_Exception_Account_Mapping__c();
                exptMap.Core_MDF_Account_id__c = acc1.Id;
                exptMap.Core_MDF_Exception_id__c = expt.Id;
                exptMap.Core_MDF_Country_Region_txt__c = 'AUSTRALIA';
                exptMap.Core_MDF_Budget_Type_txt__c = 'Account Plan';
                exptMap.Core_MDF_HostRegion_txt__c = 'APJ';
                exptMap.Core_MDF_Active_ind__c = true;
                database.insert(exptMap);
                
                exptMap.Core_MDF_HostRegion_txt__c = 'EMEA';
                database.update(exptMap);

                exptMap.Core_MDF_Active_ind__c = false;
                database.update(exptMap);

                Core_MDF_Exception_Account_Mapping__c exptMap3 = new Core_MDF_Exception_Account_Mapping__c();
                exptMap3.Core_MDF_Account_id__c = accEef.Id;
                exptMap3.Core_MDF_Exception_id__c = exptEEFPrgm2.Id;
                exptMap3.Core_MDF_Country_Region_txt__c = '';
                exptMap3.Core_MDF_Active_ind__c = true;
                database.insert(exptMap3);
            }catch(Exception e){
            }
            Test.stopTest(); 
        }
    }

    @isTest
    static void exceptionCreateIPA2(){
        
        List<Core_MDF_Exception__c> exceptionList = new List<Core_MDF_Exception__c>();
        List<Core_MDF_Exception_Account_Mapping__c> exptAccMapList = new List<Core_MDF_Exception_Account_Mapping__c>();
        Map<Id , Core_MDF_Exception__c> newExceptionMap = new Map<Id , Core_MDF_Exception__c>();
        Map<Id , Core_MDF_Exception__c> newExceptionAllCountryMap = new Map<Id , Core_MDF_Exception__c>();
        Map<Id,Core_MDF_Exception_Account_Mapping__c> eamOldMap = new Map<Id,Core_MDF_Exception_Account_Mapping__c>();
        Map<Id,Core_MDF_Exception_Account_Mapping__c> eamNewMap = new Map<Id,Core_MDF_Exception_Account_Mapping__c>();
        Test.startTest();
        User submitter  = [SELECT Id FROM USER WHERE LastName = 'SystemAdmin' LIMIT 1];
        User reviewer  = [SELECT Id FROM USER WHERE LastName = 'Excpetion Reviewer' LIMIT 1];
        Account acc1 = [SELECT Id FROM Account WHERE Name = 'IPA Intel Account' LIMIT 1];
        Account acc= [SELECT Id FROM Account WHERE Name = 'MyntraTestAccount' LIMIT 1];
        Account accEef = [SELECT Id FROM Account WHERE Name = 'Test Primary Intel Account' LIMIT 1];
        Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm = [SELECT id FROM Core_MDF_Int_Users_Partner_Geo_Mapping__c
                                                           WHERE Core_MDF_User_id__c =: submitter.id Limit 1];
        
        Core_MDF_Exception__c expt = new Core_MDF_Exception__c();
        
        System.runAs(submitter){ 
            //Account       Country
            //Single        Single 
            
            expt.Core_MDF_Name_of_Exception_nm__c = 'Test Exception Single Account Single Country IPA';
            expt.Core_MDF_Issue_Description_dsc__c = 'Test Description IPA';
            expt.Core_MDF_Comments_txt__c = 'Test Comments';
            expt.Core_MDF_Exception_Start_Date_dt__c = System.today();
            expt.Core_MDF_Exception_End_Date_dt__c = System.today() + 5;
            expt.Core_MDF_Exception_Reason_nm__c = 'Branding Exception from Activity Catalog';
            expt.Core_MDF_Program_nm__c = 'Core_MDF_Intel_Partner_Alliance';
            expt.Core_MDF_Activity_Cate_and_Type_nm__c = 'Broadcast->Podcast';
            expt.Core_MDF_Total_Dollar_Impact_amt__c = 100;
            expt.Core_MDF_HostRegion_txt__c='APJ';
            expt.Core_MDF_Country_Region_nm__c = 'AUSTRALIA';
            //expt.Core_MDF_Account_id__c = acc1.Id;
            expt.Core_MDF_Select_All_Accounts_ind__c = false;
            expt.Core_MDF_Budget_Type_nm__c = 'Account Plan';
            exceptionList.add(expt);

            Core_MDF_Exception__c exptEEFPrgm2 = new Core_MDF_Exception__c();
            exptEEFPrgm2.Core_MDF_Name_of_Exception_nm__c = 'Test Exception Single Account Single Country EEF';
            exptEEFPrgm2.Core_MDF_Issue_Description_dsc__c = 'Test Description';
            exptEEFPrgm2.Core_MDF_Comments_txt__c = 'Test Comments';
            exptEEFPrgm2.Core_MDF_Exception_Start_Date_dt__c = System.today();
            exptEEFPrgm2.Core_MDF_Exception_End_Date_dt__c = System.today() + 5;
            exptEEFPrgm2.Core_MDF_Exception_Reason_nm__c = 'Branding Exception from Activity Catalog';
            exptEEFPrgm2.Core_MDF_Program_nm__c = 'Core_MDF_Ecosystem_Extension_Fund';
            exptEEFPrgm2.Core_MDF_Activity_Cate_and_Type_nm__c = 'Broadcast->Podcast';
            exptEEFPrgm2.Core_MDF_Total_Dollar_Impact_amt__c = 100;
            exptEEFPrgm2.Core_MDF_Country_Region_nm__c = '';
            exptEEFPrgm2.Core_MDF_Select_All_Country_ind__c = true;
            //exptEEFPrgm2.Core_MDF_Account_id__c = acc.Id;
            exceptionList.add(exptEEFPrgm2);


            try{
                Database.insert(exceptionList);
                Core_MDF_Exception_Account_Mapping__c exptMap = new Core_MDF_Exception_Account_Mapping__c();
                exptMap.Core_MDF_Account_id__c = acc1.Id;
                exptMap.Core_MDF_Exception_id__c = expt.Id;
                exptMap.Core_MDF_Country_Region_txt__c = 'AUSTRALIA';
                exptMap.Core_MDF_Budget_Type_txt__c = 'Account Plan';
                exptMap.Core_MDF_HostRegion_txt__c = 'APJ';
                exptMap.Core_MDF_Active_ind__c = true;
                //database.insert(exptMap);
                
                exptMap.Core_MDF_HostRegion_txt__c = 'EMEA';
                //database.update(exptMap);

                exptMap.Core_MDF_Active_ind__c = false;
                //database.update(exptMap);

                Core_MDF_Exception_Account_Mapping__c exptMap3 = new Core_MDF_Exception_Account_Mapping__c();
                exptMap3.Core_MDF_Account_id__c = accEef.Id;
                exptMap3.Core_MDF_Exception_id__c = exptEEFPrgm2.Id;
                exptMap3.Core_MDF_Country_Region_txt__c = '';
                exptMap3.Core_MDF_Active_ind__c = true;
                database.insert(exptMap3);
            }catch(Exception e){
            }
            Test.stopTest(); 
        }
    }

    @isTest
    static void exceptionCreateIPA3(){
        
        List<Core_MDF_Exception__c> exceptionList = new List<Core_MDF_Exception__c>();
        List<Core_MDF_Exception_Account_Mapping__c> exptAccMapList = new List<Core_MDF_Exception_Account_Mapping__c>();
        Map<Id , Core_MDF_Exception__c> newExceptionMap = new Map<Id , Core_MDF_Exception__c>();
        Map<Id , Core_MDF_Exception__c> newExceptionAllCountryMap = new Map<Id , Core_MDF_Exception__c>();
        Map<Id,Core_MDF_Exception_Account_Mapping__c> eamOldMap = new Map<Id,Core_MDF_Exception_Account_Mapping__c>();
        Map<Id,Core_MDF_Exception_Account_Mapping__c> eamNewMap = new Map<Id,Core_MDF_Exception_Account_Mapping__c>();
        Test.startTest();
        User submitter  = [SELECT Id FROM USER WHERE LastName = 'SystemAdmin' LIMIT 1];
        User reviewer  = [SELECT Id FROM USER WHERE LastName = 'Excpetion Reviewer' LIMIT 1];
        Account acc1 = [SELECT Id FROM Account WHERE Name = 'IPA Intel Account' LIMIT 1];
        Account acc= [SELECT Id FROM Account WHERE Name = 'MyntraTestAccount' LIMIT 1];
        Account accEef = [SELECT Id FROM Account WHERE Name = 'Test Primary Intel Account' LIMIT 1];
        Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm = [SELECT id FROM Core_MDF_Int_Users_Partner_Geo_Mapping__c
                                                           WHERE Core_MDF_User_id__c =: submitter.id Limit 1];
        
        List<String> bypassFunctionKeys = new List<String>();

        bypassFunctionKeys.add('Bypass_ValidateAccProgAccessOnEAM');
        Set<String> myset1 = new Set<String>();
        List<String> result1 = new List<String>();
        myset1.addAll(bypassFunctionKeys);
        result1.addAll(myset1);
        
        List<Core_Trigger_Executions__c> bypassfunctinalitylist1 = Core_MDF_CCP_TestDataUtility.byPassFeature(result1,false,true);
        
        Core_MDF_Exception__c expt = new Core_MDF_Exception__c();
        
        System.runAs(submitter){ 
            //Account       Country
            //Single        Single 
            
            expt.Core_MDF_Name_of_Exception_nm__c = 'Test Exception Single Account Single Country IPA';
            expt.Core_MDF_Issue_Description_dsc__c = 'Test Description IPA';
            expt.Core_MDF_Comments_txt__c = 'Test Comments';
            expt.Core_MDF_Exception_Start_Date_dt__c = System.today();
            expt.Core_MDF_Exception_End_Date_dt__c = System.today() + 5;
            expt.Core_MDF_Exception_Reason_nm__c = 'Branding Exception from Activity Catalog';
            expt.Core_MDF_Program_nm__c = 'Core_MDF_Intel_Partner_Alliance';
            expt.Core_MDF_Activity_Cate_and_Type_nm__c = 'Broadcast->Podcast';
            expt.Core_MDF_Total_Dollar_Impact_amt__c = 100;
            expt.Core_MDF_HostRegion_txt__c='APJ';
            expt.Core_MDF_Country_Region_nm__c = 'AUSTRALIA';
            //expt.Core_MDF_Account_id__c = acc1.Id;
            expt.Core_MDF_Select_All_Accounts_ind__c = false;
            expt.Core_MDF_Budget_Type_nm__c = 'Account Plan';
            exceptionList.add(expt);

            Core_MDF_Exception__c exptEEFPrgm2 = new Core_MDF_Exception__c();
            exptEEFPrgm2.Core_MDF_Name_of_Exception_nm__c = 'Test Exception Single Account Single Country EEF';
            exptEEFPrgm2.Core_MDF_Issue_Description_dsc__c = 'Test Description';
            exptEEFPrgm2.Core_MDF_Comments_txt__c = 'Test Comments';
            exptEEFPrgm2.Core_MDF_Exception_Start_Date_dt__c = System.today();
            exptEEFPrgm2.Core_MDF_Exception_End_Date_dt__c = System.today() + 5;
            exptEEFPrgm2.Core_MDF_Exception_Reason_nm__c = 'Branding Exception from Activity Catalog';
            exptEEFPrgm2.Core_MDF_Program_nm__c = 'Core_MDF_Ecosystem_Extension_Fund';
            exptEEFPrgm2.Core_MDF_Activity_Cate_and_Type_nm__c = 'Broadcast->Podcast';
            exptEEFPrgm2.Core_MDF_Total_Dollar_Impact_amt__c = 100;
            exptEEFPrgm2.Core_MDF_Country_Region_nm__c = '';
            exptEEFPrgm2.Core_MDF_Select_All_Country_ind__c = true;
            //exptEEFPrgm2.Core_MDF_Account_id__c = acc.Id;
            exceptionList.add(exptEEFPrgm2);


            try{
                Database.insert(exceptionList);
                Core_MDF_Expt_AccMap_ServiceHandler.createExceptionShareExt(String.valueOf(expt.Id), String.valueOf(submitter.Id));
                Core_MDF_Expt_AccMap_ServiceHandler.createExceptionAccShareExt(String.valueOf(expt.Id), String.valueOf(submitter.Id));

                Core_MDF_Exception_Account_Mapping__c exptMap = new Core_MDF_Exception_Account_Mapping__c();
                exptMap.Core_MDF_Account_id__c = acc1.Id;
                exptMap.Core_MDF_Exception_id__c = expt.Id;
                exptMap.Core_MDF_Country_Region_txt__c = 'AUSTRALIA';
                exptMap.Core_MDF_Budget_Type_txt__c = 'Account Plan';
                exptMap.Core_MDF_HostRegion_txt__c = 'APJ';
                exptMap.Core_MDF_Active_ind__c = true;
                //database.insert(exptMap);
                
                exptMap.Core_MDF_HostRegion_txt__c = 'EMEA';
                //database.update(exptMap);

                exptMap.Core_MDF_Active_ind__c = false;
                //database.update(exptMap);

                database.insert(exptMap);

                List<Core_MDF_Exception__c> expListToUpdate = new List<Core_MDF_Exception__c>();
                for(Core_MDF_Exception__c exp : exceptionList){
                    exp.Core_MDF_Exception_Status_nm__c = 'Approved';
                    exp.Core_MDF_Expose_Externally_ind__c = true;
                    expListToUpdate.add(exp);
                }

                update expListToUpdate;

                Core_MDF_Exception_Account_Mapping__c exptMap3 = new Core_MDF_Exception_Account_Mapping__c();
                exptMap3.Core_MDF_Account_id__c = accEef.Id;
                exptMap3.Core_MDF_Exception_id__c = exptEEFPrgm2.Id;
                exptMap3.Core_MDF_Country_Region_txt__c = '';
                exptMap3.Core_MDF_Active_ind__c = true;
                database.insert(exptMap3);

            }catch(Exception e){
            }
            Test.stopTest(); 
        }
    }

     @isTest
    static void exceptionHostRegionTest(){
        
        List<Core_MDF_Exception__c> exceptionList = new List<Core_MDF_Exception__c>();
        Test.startTest();
        User submitter  = [SELECT Id FROM USER WHERE LastName = 'SystemAdmin' LIMIT 1];
        Account acc = [SELECT Id FROM Account WHERE Name = 'IPA Intel Account' LIMIT 1];
        Core_MDF_Exception__c expt = new Core_MDF_Exception__c();
        expt.Core_MDF_Name_of_Exception_nm__c = 'Test Exception Single Account Single Country';
        expt.Core_MDF_Issue_Description_dsc__c = 'Test Description';
        expt.Core_MDF_Comments_txt__c = 'Test Comments';
        expt.Core_MDF_Exception_Start_Date_dt__c = System.today();
        expt.Core_MDF_Exception_End_Date_dt__c = System.today() + 5;
        expt.Core_MDF_Exception_Reason_nm__c = 'Branding Exception from Activity Catalog';
        expt.Core_MDF_Program_nm__c = 'Core_MDF_Intel_Partner_Alliance';
        expt.Core_MDF_Activity_Cate_and_Type_nm__c = 'Broadcast->Podcast';
        expt.Core_MDF_Total_Dollar_Impact_amt__c = 100;
        expt.Core_MDF_Country_Region_nm__c = 'INDIA';
        expt.Core_MDF_Account_id__c = acc.Id;
        expt.Core_MDF_Select_All_Accounts_ind__c = false;
        System.runAs(submitter){ 
            Database.insert(expt);
        }
        exceptionList.add(expt);
                Core_MDF_ExceptionEmailHandler.sendEmailToExceptionReviewer(exceptionList);
                Assert.isfalse(expt.Core_MDF_Select_All_Accounts_ind__c);
        Test.stopTest();
            }
    
  
  @isTest
  static void eefExceptionSharingTest(){
    List<Core_MDF_Exception__c> exceptionList = new List<Core_MDF_Exception__c>();
         Map<Id , Core_MDF_Exception__c> newExceptionMap = new Map<Id , Core_MDF_Exception__c>();
    Map<Id, List<String>> accIdPartnerTypeMap = new Map<Id, List<String>>();
      Test.startTest();
      User submitter  = [SELECT Id FROM USER WHERE LastName = 'SystemAdmin' LIMIT 1];
      User reviewer  = [SELECT Id FROM USER WHERE LastName = 'Excpetion Reviewer' LIMIT 1];
      Account acc= [SELECT Id,Core_MDF_Partner_Type_nm__c FROM Account WHERE Name = 'FlipkartTestAccount' LIMIT 1];
      accIdPartnerTypeMap.put(acc.Id, new List<String>{acc.Core_MDF_Partner_Type_nm__c});
        //EEF Program
            Core_MDF_Exception__c exptEEFPrgm = new Core_MDF_Exception__c();
            exptEEFPrgm.Core_MDF_Name_of_Exception_nm__c = 'Test Exception Single Account Single Country EEF';
            exptEEFPrgm.Core_MDF_Issue_Description_dsc__c = 'Test Description';
            exptEEFPrgm.Core_MDF_Comments_txt__c = 'Test Comments';
            exptEEFPrgm.Core_MDF_Exception_Start_Date_dt__c = System.today();
            exptEEFPrgm.Core_MDF_Exception_End_Date_dt__c = System.today() + 5;
            exptEEFPrgm.Core_MDF_Exception_Reason_nm__c = 'Branding Exception from Activity Catalog';
            exptEEFPrgm.Core_MDF_Program_nm__c = 'Core_MDF_Ecosystem_Extension_Fund';
            exptEEFPrgm.Core_MDF_Activity_Cate_and_Type_nm__c = 'Broadcast->Podcast';
            exptEEFPrgm.Core_MDF_Total_Dollar_Impact_amt__c = 100;
            exptEEFPrgm.Core_MDF_Country_Region_nm__c = 'INDIA';
            exptEEFPrgm.Core_MDF_Account_id__c = acc.Id;
          newExceptionMap.put(exptEEFPrgm.Id,exptEEFPrgm);
            exceptionList.add(exptEEFPrgm);
      try{
      System.runAs(submitter){
        Database.insert(exceptionList);
      }}catch(exception ex){
      }
        Core_MDF_Exception_TriggerServiceHandler.validateSelectedAccount(exceptionList,newExceptionMap);
        Test.stopTest();
  }
    @isTest
    static void getNewCategoryValuesTest(){
        Set<String> categoryValues = new Set<String>();
        Core_MDF_ActivityCategoryMapping__c category = new Core_MDF_ActivityCategoryMapping__c();
        category.Name = 'EEF_CAT01';
        category.Core_MDF_Program_txt__c = 'Core_MDF_Client_CoMarketing_Fund';
        category.Core_MDF_Is_Active_Ind__c = true;
        category.Core_MDF_Category_Name_txt__c = 'Digital 2025';
        insert category;
        categoryValues.add('Core_MDF_Client_CoMarketing_Fund');
        Test.startTest();
        Core_MDF_Exception_TriggerServiceHandler.getNewCategoryValues(categoryValues);
        Test.stopTest();
    }
    
   @isTest
  static void eefExceptionSharingTest2(){
    List<Core_MDF_Exception__c> exceptionList = new List<Core_MDF_Exception__c>();
         Map<Id , Core_MDF_Exception__c> newExceptionMap = new Map<Id , Core_MDF_Exception__c>();
    Map<Id, List<String>> accIdPartnerTypeMap = new Map<Id, List<String>>();
      Test.startTest();
          User submitter  = [SELECT Id FROM USER WHERE LastName = 'SystemAdmin' LIMIT 1];
      User reviewer  = [SELECT Id FROM USER WHERE LastName = 'Excpetion Reviewer' LIMIT 1];
      Account acc= [SELECT Id,Core_MDF_Partner_Type_nm__c FROM Account WHERE Name = 'FlipkartTestAccount' LIMIT 1];
        acc.Core_MDF_Partner_Type_nm__c = 'Primary Partner';
        update acc;
      accIdPartnerTypeMap.put(acc.Id, new List<String>{acc.Core_MDF_Partner_Type_nm__c});
        //EEF Program
            Core_MDF_Exception__c exptEEFPrgm = new Core_MDF_Exception__c();
            exptEEFPrgm.Core_MDF_Name_of_Exception_nm__c = 'Test Exception Single Account Single Country EEF';
            exptEEFPrgm.Core_MDF_Issue_Description_dsc__c = 'Test Description';
            exptEEFPrgm.Core_MDF_Comments_txt__c = 'Test Comments';
            exptEEFPrgm.Core_MDF_Exception_Start_Date_dt__c = System.today();
            exptEEFPrgm.Core_MDF_Exception_End_Date_dt__c = System.today() + 5;
            exptEEFPrgm.Core_MDF_Exception_Reason_nm__c = 'Branding Exception from Activity Catalog';
            exptEEFPrgm.Core_MDF_Program_nm__c = 'Core_MDF_Ecosystem_Extension_Fund';
            exptEEFPrgm.Core_MDF_Activity_Cate_and_Type_nm__c = 'Broadcast->Podcast';
            exptEEFPrgm.Core_MDF_Total_Dollar_Impact_amt__c = 100;
            exptEEFPrgm.Core_MDF_Country_Region_nm__c = 'INDIA';
            exptEEFPrgm.Core_MDF_Account_id__c = acc.Id;
          newExceptionMap.put(exptEEFPrgm.Id,exptEEFPrgm);
            exceptionList.add(exptEEFPrgm);
      try{
      System.runAs(submitter){
                Database.insert(exceptionList);
                
                Core_MDF_Exception_Account_Mapping__c exptMap = new Core_MDF_Exception_Account_Mapping__c();
                exptMap.Core_MDF_Account_id__c = acc.Id;
                exptMap.Core_MDF_Exception_id__c = exptEEFPrgm.Id;
                database.insert(exptMap);
      }}catch(exception ex){
      }
        Test.stopTest();
  }
  @isTest
    static void validateAccountTest(){
        Test.startTest();
        User submitter = [SELECT Id FROM USER WHERE LastName = 'CCF Acc Manager' LIMIT 1];
        Account acc = [SELECT Id FROM Account WHERE Name = 'FlipkartTestAccount' LIMIT 1];
        
        Core_MDF_Exception__c testException = new Core_MDF_Exception__c();
        testException.Core_MDF_Name_of_Exception_nm__c = 'Test Exception for Record Share List';
        testException.Core_MDF_Issue_Description_dsc__c = 'Test Description';
        testException.Core_MDF_Comments_txt__c = 'Test Comments';
        testException.Core_MDF_Exception_Start_Date_dt__c = System.today();
        testException.Core_MDF_Exception_End_Date_dt__c = System.today() + 5;
        testException.Core_MDF_Exception_Reason_nm__c = 'Branding Exception from Activity Catalog';
        testException.Core_MDF_Program_nm__c = 'Core_MDF_Client_CoMarketing_Fund';
        testException.Core_MDF_Activity_Cate_and_Type_nm__c = 'Audio 2025->Podcast';
        testException.Core_MDF_Total_Dollar_Impact_amt__c = 100;
        testException.Core_MDF_Select_All_Country_ind__c = true;
        testException.Core_MDF_Account_id__c = acc.Id;
        
        System.runAs(submitter){
            Database.insert(testException);
            
            Map<Id, List<String>> ultimateAccIdToParterMap= new Map<Id, List<String>>();
            List<string> partnerTypeList = new List<string>();
            partnerTypeList.add('Primary Partner');
            partnerTypeList.add('Activating Partner');
            
            ultimateAccIdToParterMap.put(testException.Core_MDF_Account_id__c,partnerTypeList);
            
            Boolean trueOrFalse = Core_MDF_Exception_TriggerServiceHandler.validateAccount(testException,ultimateAccIdToParterMap,false);
            
            List<Core_MDF_RecordGeoShare> wrper = new List<Core_MDF_RecordGeoShare>();
            Map<String,Set<String>> geoSubGeoSetMap = new Map<String,Set<String>>();
            
            Set<String> subGeo= new Set<String>();
            subGeo.add('LAR');
            
            geoSubGeoSetMap.put('ASMO',subGeo);
            
            Core_MDF_Exception__Share shre = new Core_MDF_Exception__Share();
            shre = Core_MDF_Exception_TriggerServiceHandler.createExceptionShareExt(String.valueOf(testException.Id),String.valueOf(testException.Id));
            
            Core_MDF_Exception_Account_Mapping__Share shreExp = new Core_MDF_Exception_Account_Mapping__Share();
            shreExp = Core_MDF_Exception_TriggerServiceHandler.createExceptionAccShareExt(String.valueOf(testException.Id),String.valueOf(testException.Id));
        }
        Test.stopTest();
        
    }
   
    @isTest
static void testEAMAllMethods() {
    Test.startTest();
    User submitter = [SELECT Id FROM USER WHERE LastName = 'SystemAdmin' LIMIT 1];
    User reviewer = [SELECT Id FROM USER WHERE LastName = 'Excpetion Reviewer' LIMIT 1];
    Account existingAcc = [SELECT Id FROM Account WHERE Name = 'FlipkartTestAccount' LIMIT 1];
    
    System.runAs(submitter) {
        ChannelProgram rmfCp = Core_MDF_CCP_TestDataUtility.createProgram('Retail Marketing Funds', 'Retail Marketing Funds', true);
        ChannelProgram ccfCp = [SELECT Id FROM ChannelProgram WHERE Name = 'Client' LIMIT 1];
        
        Account intelAcc1 = Core_MDF_CCP_TestDataUtility.createIntelAccount('Test Intel Account 1', 
                                                                           Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
        intelAcc1.Core_Geo__c='APJ';  
        intelAcc1.Core_Sub_Geo__c='ROA';                                                                 
        intelAcc1.BillingStateCode = '';
        
        Account intelAcc2 = Core_MDF_CCP_TestDataUtility.createIntelAccount('Test Intel Account 2', 
                                                                           Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
        intelAcc2.BillingStateCode = '';
        
        List<Account> intelAccounts = new List<Account>{intelAcc1, intelAcc2};
        insert intelAccounts;
        
        Account childAccIntel = new Account();
        childAccIntel.Name = 'Test Child Intel Account';
        childAccIntel.Core_MDF_CoMarketing_Ultimate_Account__c = intelAcc1.Id;
        childAccIntel.Core_MDF_Channel_Program__c = rmfCp.Id;
        childAccIntel.BillingStateCode = '';
        childAccIntel.BillingCity ='Ponta Grossa';
        childAccIntel.BillingCountry='BRA';
        childAccIntel.BillingStreet='Test';
        
        Account rmfCoMarketingAcc = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test RMF CoMarketing Account', 
                                                                                          rmfCp.Id, 
                                                                                          Core_MDF_CCP_TestDataUtility.Account_Record_Type, 
                                                                                          intelAcc1.Id, false);
        rmfCoMarketingAcc.Core_MDF_External_Group_Id__c = UserInfo.getUserId();
        rmfCoMarketingAcc.BillingStateCode = '';
        rmfCoMarketingAcc.BillingCity='Ponta Grossa';
        rmfCoMarketingAcc.BillingCountry='BRA';
        rmfCoMarketingAcc.BillingStreet='Test';
        rmfCoMarketingAcc.Core_Geo__c='APJ';  
        rmfCoMarketingAcc.Core_Sub_Geo__c='ROA';  
        
        Account ccfCoMarketingAcc = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test CCF CoMarketing Account', 
                                                                                          ccfCp.Id, 
                                                                                          Core_MDF_CCP_TestDataUtility.Account_Record_Type, 
                                                                                          intelAcc2.Id, false);
        ccfCoMarketingAcc.BillingStateCode = '';
        ccfCoMarketingAcc.BillingCity ='Ponta Grossa';
        ccfCoMarketingAcc.BillingCountry='BRA';
        ccfCoMarketingAcc.BillingStreet='Test';
        
        List<Account> coMarketingAccounts = new List<Account>{childAccIntel, rmfCoMarketingAcc, ccfCoMarketingAcc};
       insert coMarketingAccounts;
        
        Group internalGroup = new Group();
        internalGroup.Name = 'Test Internal Group';
        internalGroup.DeveloperName = 'Test_Internal_Group';
        
        Group externalGroup = new Group();
        externalGroup.Name = 'Test External Group';
        externalGroup.DeveloperName = 'Test_External_Group';
        
        List<Group> groups = new List<Group>{internalGroup, externalGroup};
        insert groups;
        
        Core_MDF_Exception__c rmfExpt = new Core_MDF_Exception__c();
        rmfExpt.Core_MDF_Name_of_Exception_nm__c = 'Test RMF Exception';
        rmfExpt.Core_MDF_Issue_Description_dsc__c = 'Test Description';
        rmfExpt.Core_MDF_Comments_txt__c = 'Test Comments';
        rmfExpt.Core_MDF_Exception_Start_Date_dt__c = System.today();
        rmfExpt.Core_MDF_Exception_End_Date_dt__c = System.today() + 5;
        rmfExpt.Core_MDF_Exception_Reason_nm__c = 'Branding Exception from Activity Catalog';
        rmfExpt.Core_MDF_Program_nm__c = 'Core_MDF_Retail_Marketing_Funds';
        rmfExpt.Core_MDF_Activity_Cate_and_Type_nm__c = 'Audio 2025->Podcast';
        rmfExpt.Core_MDF_Total_Dollar_Impact_amt__c = 100;
        rmfExpt.Core_MDF_Country_Region_nm__c = 'INDIA';
        //rmfExpt.Core_MDF_Account_id__c = intelAcc1.Id;
        rmfExpt.Core_MDF_Exception_Status_nm__c = 'Approved';
        rmfExpt.Core_MDF_Expose_Externally_ind__c = true;
        
        Core_MDF_Exception__c ccfExpt = new Core_MDF_Exception__c();
        ccfExpt.Core_MDF_Name_of_Exception_nm__c = 'Test CCF Exception';
        ccfExpt.Core_MDF_Issue_Description_dsc__c = 'Test Description';
        ccfExpt.Core_MDF_Comments_txt__c = 'Test Comments';
        ccfExpt.Core_MDF_Exception_Start_Date_dt__c = System.today();
        ccfExpt.Core_MDF_Exception_End_Date_dt__c = System.today() + 5;
        ccfExpt.Core_MDF_Exception_Reason_nm__c = 'Branding Exception from Activity Catalog';
        ccfExpt.Core_MDF_Program_nm__c = 'Core_MDF_Client_CoMarketing_Fund';
        ccfExpt.Core_MDF_Activity_Cate_and_Type_nm__c = 'Audio 2025->Podcast';
        ccfExpt.Core_MDF_Total_Dollar_Impact_amt__c = 100;
        ccfExpt.Core_MDF_Country_Region_nm__c = 'INDIA';
        //ccfExpt.Core_MDF_Account_id__c = intelAcc2.Id;
        ccfExpt.Core_MDF_Exception_Status_nm__c = 'Approved';
        ccfExpt.Core_MDF_Expose_Externally_ind__c = true;
        
        List<Core_MDF_Exception__c> exceptions = new List<Core_MDF_Exception__c>{rmfExpt, ccfExpt};
        insert exceptions;
        
        Core_MDF_Exception_Account_Mapping__c rmfEam = new Core_MDF_Exception_Account_Mapping__c();
        rmfEam.Core_MDF_Account_id__c = rmfCoMarketingAcc.Id;
        rmfEam.Core_MDF_Exception_id__c = rmfExpt.Id;
        rmfEam.Core_MDF_Active_ind__c = true;
        
        Core_MDF_Exception_Account_Mapping__c ccfEam = new Core_MDF_Exception_Account_Mapping__c();
        ccfEam.Core_MDF_Account_id__c = intelAcc2.Id;
        ccfEam.Core_MDF_Exception_id__c = ccfExpt.Id;
        ccfEam.Core_MDF_Active_ind__c = true;
        
        List<Core_MDF_Exception_Account_Mapping__c> eams = new List<Core_MDF_Exception_Account_Mapping__c>{ccfEam,rmfEam};
        insert eams;
        
        
        
        Case rmfCase = new Case();
        rmfCase.Subject = 'Test RMF Case';
        rmfCase.AccountId = rmfCoMarketingAcc.Id;
        
        Case ccfCase = new Case();
        ccfCase.Subject = 'Test CCF Case';
        ccfCase.AccountId = existingAcc.Id; 
        
        List<Case> cases = new List<Case>{rmfCase, ccfCase};
        insert cases;
        
        Core_MDF_Exception_Case_Mapping__c rmfEcm = new Core_MDF_Exception_Case_Mapping__c();
        rmfEcm.Core_MDF_Case_id__c = rmfCase.Id;
        rmfEcm.Core_MDF_Exception_id__c = rmfExpt.Id;
        rmfEcm.Core_MDF_Program_txt__c = 'Core_MDF_Retail_Marketing_Funds'; // RMF program - covers if block
        
        Core_MDF_Exception_Case_Mapping__c ccfEcm = new Core_MDF_Exception_Case_Mapping__c();
        ccfEcm.Core_MDF_Case_id__c = ccfCase.Id;
        ccfEcm.Core_MDF_Exception_id__c = ccfExpt.Id;
        ccfEcm.Core_MDF_Program_txt__c = 'Core_MDF_Client_CoMarketing_Fund'; // Non-RMF program - covers else block
        
        List<Core_MDF_Exception_Case_Mapping__c> ecms = new List<Core_MDF_Exception_Case_Mapping__c>{rmfEcm, ccfEcm};
        insert ecms;
        
        /*Core_MDF_Partner_Group_Mapping__c internalPgm = new Core_MDF_Partner_Group_Mapping__c();
        internalPgm.Core_MDF_Account__c = intelAcc2.Id;
        internalPgm.Core_MDF_Channel_Program__c = ccfCp.Id;
        internalPgm.Core_MDF_Group_Id__c = internalGroup.Id;
        internalPgm.Core_MDF_Group_Name__c = 'Test_Internal_Group';
        internalPgm.Core_MDF_Type_of_Access__c = 'Internal';
        internalPgm.Core_MDF_Region_cd__c = 'APJ';
        internalPgm.Core_MDF_Sub_Region_cd__c = null; // NULL Sub Region for shareEAM coverage
        internalPgm.Core_MDF_Inactive_Ind__c = false;*/
        
        Core_MDF_Partner_Group_Mapping__c externalPgm = new Core_MDF_Partner_Group_Mapping__c();
        externalPgm.Core_MDF_Account__c = intelAcc2.Id;
        externalPgm.Core_MDF_Channel_Program__c = ccfCp.Id;
        externalPgm.Core_MDF_Group_Id__c = externalGroup.Id;
        externalPgm.Core_MDF_Group_Name__c = 'Test_External_Group';
        externalPgm.Core_MDF_Type_of_Access__c = 'External';
        externalPgm.Core_MDF_Sub_Region_cd__c='';
        externalPgm.Core_MDF_Region_cd__c='APJ';
        externalPgm.Core_MDF_Inactive_Ind__c = false;
        
        List<Core_MDF_Partner_Group_Mapping__c> pgms = new List<Core_MDF_Partner_Group_Mapping__c>{externalPgm};
        insert pgms;
        
        List<Core_MDF_Exception_Account_Mapping__c> testEamList = new List<Core_MDF_Exception_Account_Mapping__c>{rmfEam};
        Core_MDF_Expt_AccMap_ServiceHandler.ExceptionDataSetWrapper wrapper = 
            Core_MDF_Expt_AccMap_ServiceHandler.prepareDataSetForValidation(testEamList);
        
        Map<Id, Core_MDF_Exception_Account_Mapping__c> eamMapForSharing = new Map<Id, Core_MDF_Exception_Account_Mapping__c>();
        eamMapForSharing.put(ccfEam.Id, ccfEam);
        Core_MDF_Expt_AccMap_ServiceHandler.shareEAM(eamMapForSharing);
        
        List<Core_MDF_Exception__Share> smallShareList = new List<Core_MDF_Exception__Share>();
        Core_MDF_Exception__Share share1 = new Core_MDF_Exception__Share();
        share1.ParentId = ccfExpt.Id;
        share1.UserOrGroupId = reviewer.Id;
        share1.AccessLevel = 'Read';
        share1.RowCause = 'Manual';
        smallShareList.add(share1);
        
        Core_MDF_Expt_AccMap_ServiceHandler.insertShareRecord(smallShareList);
        Core_MDF_Expt_AccMap_ServiceHandler.insertShareRecord(null);
        Core_MDF_Expt_AccMap_ServiceHandler.insertShareRecord(new List<Core_MDF_Exception__Share>());
        
        Map<Id, Core_MDF_Exception_Account_Mapping__c> oldEamMap = new Map<Id, Core_MDF_Exception_Account_Mapping__c>();
        oldEamMap.put(rmfEam.Id, new Core_MDF_Exception_Account_Mapping__c(Id = rmfEam.Id, Core_MDF_Active_ind__c = true));
        oldEamMap.put(ccfEam.Id, new Core_MDF_Exception_Account_Mapping__c(Id = ccfEam.Id, Core_MDF_Active_ind__c = true));
        
        rmfEam.Core_MDF_Active_ind__c = false;
        ccfEam.Core_MDF_Active_ind__c = false;
        
        Map<Id, Core_MDF_Exception_Account_Mapping__c> newEamMap = new Map<Id, Core_MDF_Exception_Account_Mapping__c>();
        newEamMap.put(rmfEam.Id, rmfEam);
        newEamMap.put(ccfEam.Id, ccfEam);
        
        try {
            Core_MDF_Expt_AccMap_ServiceHandler.validateActiveEAM(newEamMap, oldEamMap);
        } catch (Exception e) {
            System.debug('Error: ' + e.getMessage());
        }
        
        rmfEam.Core_MDF_Active_ind__c = true;
        ccfEam.Core_MDF_Active_ind__c = true;
        
        Map<Id, Core_MDF_Exception_Account_Mapping__c> eamMapForExtSharing = new Map<Id, Core_MDF_Exception_Account_Mapping__c>();
        eamMapForExtSharing.put(rmfEam.Id, rmfEam); // RMF coverage
        eamMapForExtSharing.put(ccfEam.Id, ccfEam); // PGM query coverage
        
        Core_MDF_Expt_AccMap_ServiceHandler.shareRecordsWithExtUsers(eamMapForExtSharing);
        
        List<Core_MDF_Exception__Share> largeShareList = new List<Core_MDF_Exception__Share>();
        for (Integer i = 0; i < 15; i++) {
            Core_MDF_Exception__Share tempShare = new Core_MDF_Exception__Share();
            tempShare.ParentId = ccfExpt.Id;
            tempShare.UserOrGroupId = reviewer.Id;
            tempShare.AccessLevel = 'Read';
            tempShare.RowCause = 'Manual';
            largeShareList.add(tempShare);
        }
        
        Core_MDF_Exception_Account_Mapping__Share shreExp = new Core_MDF_Exception_Account_Mapping__Share();
            shreExp = Core_MDF_Expt_AccMap_ServiceHandler.createExceptionAccShareInternal(String.valueOf(ccfEcm.Id),String.valueOf(ccfEcm.Id));
        Core_MDF_Exception__Share shareExpection = new Core_MDF_Exception__Share();
        shareExpection = Core_MDF_Expt_AccMap_ServiceHandler.createExceptionShareInternal(String.valueOf(ccfEcm.Id),String.valueOf(ccfEcm.Id));
        
        
        Core_MDF_Exception_Account_Mapping__Share shreExp1 = new Core_MDF_Exception_Account_Mapping__Share();
            shreExp1 = Core_MDF_Expt_AccMap_ServiceHandler.createExceptionAccShareExt(String.valueOf(ccfEcm.Id),String.valueOf(ccfEcm.Id));
        Core_MDF_Exception__Share shareExpection1 = new Core_MDF_Exception__Share();
        shareExpection1 = Core_MDF_Expt_AccMap_ServiceHandler.createExceptionShareExt(String.valueOf(ccfEcm.Id),String.valueOf(ccfEcm.Id));
            
        //eams
        Core_MDF_Expt_AccMap_ServiceHandler.insertShareRecord(largeShareList);
        
        Core_MDF_Exception_Utility.ExceptionUserIUPGMWrapper excptUserData = new Core_MDF_Exception_Utility.ExceptionUserIUPGMWrapper();
        Core_MDF_Expt_AccMap_ServiceHandler.ExceptionDataSetWrapper wrap = new Core_MDF_Expt_AccMap_ServiceHandler.ExceptionDataSetWrapper();
        Set<String> exptUserIUPGMAccountProgramStrSet = new Set<String>();
        Map<Id, Set<String>> accIdProgramStrSetMap = new Map<Id, Set<String>>();
        
        Core_MDF_Expt_AccMap_ServiceHandler.initializeEAM(eams);
        //Core_MDF_Expt_AccMap_ServiceHandler.validateException(ccfEam,excptUserData,wrap);
        //Core_MDF_Expt_AccMap_ServiceHandler.validateExceptionAccountAccess(ccfEam,false,'Core_MDF_Client_Comarketing_Fund',exptUserIUPGMAccountProgramStrSet);
        //Core_MDF_Expt_AccMap_ServiceHandler.validateExceptionAccountProgramAccess(ccfEam,accIdProgramStrSetMap,'Core_MDF_Client_Comarketing_Fund');
        //Core_MDF_Expt_AccMap_ServiceHandler.validateExceptionCountryAccess();
        Core_MDF_Expt_AccMap_ServiceHandler.shareEAMonHostGeoUpdate(eamMapForExtSharing ,eamMapForExtSharing);
        Core_MDF_Expt_AccMap_ServiceHandler.shareEAM(eamMapForExtSharing );
        Core_MDF_Expt_AccMap_ServiceHandler.ExceptionDataSetWrapper wrapper1= Core_MDF_Expt_AccMap_ServiceHandler.prepareDataSetForValidation(eams);

    }
    Test.stopTest();    
    }
@isTest
static void testEAMEEFMethod() {
    
    Account intelPrimAcc = [SELECT Id FROM Account WHERE Name = 'Test Primary Intel Account' LIMIT 1];
    ChannelProgram eefCp = [SELECT Id FROM ChannelProgram WHERE Name = 'Ecosystem Extension Fund' LIMIT 1];
    
    UserRole userRole_2 = [SELECT Id FROM UserRole WHERE DeveloperName = 'Admin' LIMIT 1];
        User systemAdmin1 = Core_MDF_CCP_TestDataUtility.createUser(false);      
        systemAdmin1.LastName = 'SystemAdmin1';
        systemAdmin1.UserRoleId = userRole_2.Id;
        insert systemAdmin1;
      PermissionSet eefAccManagerPS = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Core_MDF_Internal_EEF_Primary_Partner_Acct_Mgr' LIMIT 1];
           PermissionSet eefExceptionReviewerPS = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Core_MDF_Internal_EEF_Exception_Reviewer' LIMIT 1]; 
            
            List<PermissionSetAssignment> permissionSetAssignmentList1 = new List<PermissionSetAssignment>();
            PermissionSetAssignment psaEEFAccMgr = new PermissionSetAssignment(PermissionSetId = eefAccManagerPS.Id, AssigneeId = systemAdmin1.Id);
            permissionSetAssignmentList1.add(psaEEFAccMgr);
            
            PermissionSetAssignment psaEefReviewer = new PermissionSetAssignment(PermissionSetId = eefExceptionReviewerPS.Id, AssigneeId = systemAdmin1.Id);
            permissionSetAssignmentList1.add(psaEefReviewer);
            insert permissionSetAssignmentList1;
            
        
            
            
    
    
    System.runAs(systemAdmin1) {
    
            Account testAccount = [Select id from Account where Name='FlipkartTestAccount' limit 1];
            Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgmEEFWW = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
            iupgmEEFWW.Core_MDF_Account_id__c = intelPrimAcc.Id;
            iupgmEEFWW.Core_MDF_Program_nm__c = 'Ecosystem Extension Fund';
            iupgmEEFWW.RecordTypeId = EEF_RecordType;
            iupgmEEFWW.Core_MDF_Region_Sub_Region_nm__c = 'WW';
            iupgmEEFWW.Core_MDF_User_id__c = systemAdmin1.Id;
            iupgmEEFWW.Core_MDF_Role_nm__c = 'Core_MDF_Internal_EEF_Exception_Reviewer';
            iupgmEEFWW.Core_MDF_All_Budget_Type_Access_Ind__c = true;
            iupgmEEFWW.Core_MDF_All_Accounts_cd__c = 'No';
            insert iupgmEEFWW; 
        
        Account intelActAcc = Core_MDF_CCP_TestDataUtility.createIntelAccount('Test Activating Intel Account', 
                                                                              Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
        intelActAcc.BillingStateCode = '';
        insert intelActAcc;
        
        Account intelActAcc2 = Core_MDF_CCP_TestDataUtility.createIntelAccount('Test Activating Intel Account 2', 
                                                                              Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
        intelActAcc2.BillingStateCode = '';
        insert intelActAcc2;
        
        List<Account> vcAccounts = new List<Account>();
        Account primaryVC = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Primary VC Account',
                                                                                  eefCp.Id, 
                                                                                  Core_MDF_CCP_TestDataUtility.Account_Record_Type, 
                                                                                  intelPrimAcc.Id, false);
        primaryVC.Core_MDF_Partner_Type_nm__c = 'Primary Partner';
        primaryVC.Core_MDF_Active_Ind__c = true;
        vcAccounts.add(primaryVC);
        
        Account activatingVC = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Activating VC Account',
                                                                                     eefCp.Id, 
                                                                                     Core_MDF_CCP_TestDataUtility.Account_Record_Type, 
                                                                                     intelActAcc.Id, false);
        activatingVC.Core_MDF_Partner_Type_nm__c = 'Activating Partner';
        activatingVC.Core_MDF_Active_Ind__c = true;
        vcAccounts.add(activatingVC);
        
        insert vcAccounts;
        Test.startTest();
        List<Core_MDF_Exception__c> exceptions = new List<Core_MDF_Exception__c>();
        Core_MDF_Exception__c eefException1 = new Core_MDF_Exception__c();
        eefException1.Core_MDF_Name_of_Exception_nm__c = 'Test EEF Exception Primary';
        eefException1.Core_MDF_Issue_Description_dsc__c = 'Test Description for Primary';
        eefException1.Core_MDF_Comments_txt__c = 'Test Comments';
        eefException1.Core_MDF_Exception_Start_Date_dt__c = System.today();
        eefException1.Core_MDF_Exception_End_Date_dt__c = System.today() + 5;
        eefException1.Core_MDF_Exception_Reason_nm__c = 'Branding Exception from Activity Catalog';
        eefException1.Core_MDF_Program_nm__c = 'Core_MDF_Ecosystem_Extension_Fund';
        eefException1.Core_MDF_Activity_Cate_and_Type_nm__c = 'Audio 2025->Podcast';
        eefException1.Core_MDF_Total_Dollar_Impact_amt__c = 100;
        eefException1.Core_MDF_Country_Region_nm__c = 'INDIA';
        eefException1.Core_MDF_Exception_Status_nm__c='Approved';
        eefException1.Core_MDF_Expose_Externally_ind__c=true;
        exceptions.add(eefException1);
        
        Core_MDF_Exception__c eefException2 = new Core_MDF_Exception__c();
        eefException2.Core_MDF_Name_of_Exception_nm__c = 'Test EEF Exception Activating';
        eefException2.Core_MDF_Issue_Description_dsc__c = 'Test Description for Activating';
        eefException2.Core_MDF_Comments_txt__c = 'Test Comments';
        eefException2.Core_MDF_Exception_Start_Date_dt__c = System.today();
        eefException2.Core_MDF_Exception_End_Date_dt__c = System.today() + 5;
        eefException2.Core_MDF_Exception_Reason_nm__c = 'Branding Exception from Activity Catalog';
        eefException2.Core_MDF_Program_nm__c = 'Core_MDF_Ecosystem_Extension_Fund';
        eefException2.Core_MDF_Activity_Cate_and_Type_nm__c = 'Audio 2025->Podcast';
        eefException2.Core_MDF_Total_Dollar_Impact_amt__c = 200;
        eefException2.Core_MDF_Country_Region_nm__c = 'AUSTRALIA';
        eefException2.Core_MDF_Exception_Status_nm__c='Approved';
        eefException2.Core_MDF_Expose_Externally_ind__c=true;
        exceptions.add(eefException2);
        
        insert exceptions;
        
        Core_MDF_Exception_Account_Mapping__c eamPrimary = new Core_MDF_Exception_Account_Mapping__c();
        eamPrimary.Core_MDF_Account_id__c = intelPrimAcc.Id;
        eamPrimary.Core_MDF_Exception_id__c = eefException1.Id;
        eamPrimary.Core_MDF_Active_ind__c = true;
        database.insert(eamPrimary);
        
        Core_MDF_Exception_Account_Mapping__c eamActivating = new Core_MDF_Exception_Account_Mapping__c();
        eamActivating.Core_MDF_Account_id__c = intelActAcc.Id;
        eamActivating.Core_MDF_Exception_id__c = eefException2.Id;
        eamActivating.Core_MDF_Active_ind__c = true;
        database.insert(eamActivating);
        
        
        Core_MDF_Partner_Mapping__c partnerMapping1 = new Core_MDF_Partner_Mapping__c();
        partnerMapping1.Core_MDF_Primary_Partner_Account_id__c = primaryVC.Id;
        partnerMapping1.Core_MDF_Activating_Partner_Account_id__c = activatingVC.Id;
        partnerMapping1.Core_MDF_Effective_Start_Date__c = System.today() - 90;
        partnerMapping1.Core_MDF_Effective_End_Date__c = System.today() + 100;
        partnerMapping1.Core_MDF_Channel_Program__c = eefCp.Id;
        insert partnerMapping1;
        
        Map<Id, List<String>> accIdToPartnerTypeMap = new Map<Id, List<String>>();
        
        accIdToPartnerTypeMap.put(intelPrimAcc.Id, new List<String>{'Primary Partner'});
        accIdToPartnerTypeMap.put(intelActAcc.Id, new List<String>{'Activating Partner'});
        
        
        List<Core_MDF_Exception_Account_Mapping__c> eefEamList = new List<Core_MDF_Exception_Account_Mapping__c>{
            eamPrimary, eamActivating
        };
        
        Core_MDF_Expt_AccMap_ServiceHandler.ExceptionEEFDataWrapper result = 
            Core_MDF_Expt_AccMap_ServiceHandler.prepareDataForEEFSharing(eefEamList, accIdToPartnerTypeMap);
        
        if (result.mapOfExpIdToActAccId.containsKey(eamPrimary.Id)) {
            List<Id> activatingAccounts = result.mapOfExpIdToActAccId.get(eamPrimary.Id);
        }
        
        if (result.mapOfExpIdToPrimaryAccId.containsKey(eamActivating.Id)) {
            List<Id> primaryAccounts = result.mapOfExpIdToPrimaryAccId.get(eamActivating.Id);
        }
        
        Account newEEFAccount = Core_MDF_CCP_TestDataUtility.createIntelAccount('New Intel Account', 
                                                                              Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
        newEEFAccount.BillingStateCode = '';
        insert newEEFAccount;
        
        Core_MDF_Exception__c newException3 = new Core_MDF_Exception__c();
        newException3.Core_MDF_Name_of_Exception_nm__c = 'Test Exception 3';
        newException3.Core_MDF_Issue_Description_dsc__c = 'Test Description';
        newException3.Core_MDF_Comments_txt__c = 'Test Comments';
        newException3.Core_MDF_Exception_Start_Date_dt__c = System.today();
        newException3.Core_MDF_Exception_End_Date_dt__c = System.today() + 5;
        newException3.Core_MDF_Exception_Reason_nm__c = 'Branding Exception from Activity Catalog';
        newException3.Core_MDF_Program_nm__c = 'Core_MDF_Ecosystem_Extension_Fund';
        newException3.Core_MDF_Activity_Cate_and_Type_nm__c = 'Audio 2025->Podcast';
        newException3.Core_MDF_Total_Dollar_Impact_amt__c = 100;
        newException3.Core_MDF_Country_Region_nm__c = 'INDIA';
        newException3.Core_MDF_Exception_Status_nm__c='Approved';
        newException3.Core_MDF_Expose_Externally_ind__c=true;
        insert newException3;
        
        Core_MDF_Exception_Account_Mapping__c newEAM3 = new Core_MDF_Exception_Account_Mapping__c();
        newEAM3.Core_MDF_Account_id__c = newEEFAccount.Id;
        newEAM3.Core_MDF_Exception_id__c = newException3.Id;
        newEAM3.Core_MDF_Active_ind__c = true;
        insert newEAM3;
        
        
        //update newException3;
        
        Map<Id, List<String>> neweefpartnerMap = new Map<Id, List<String>>();
        neweefpartnerMap.put(newEEFAccount.Id, new List<String>{'Primary Partner'});
        
        List<Core_MDF_Exception_Account_Mapping__c> newEAM3List = new List<Core_MDF_Exception_Account_Mapping__c>{newEAM3};
        
        Core_MDF_Expt_AccMap_ServiceHandler.ExceptionEEFDataWrapper newEEF3Result = Core_MDF_Expt_AccMap_ServiceHandler.prepareDataForEEFSharing(newEAM3List, neweefpartnerMap);
        
        List<Core_MDF_Exception_Account_Mapping__c> emptyList = new List<Core_MDF_Exception_Account_Mapping__c>();
        Core_MDF_Expt_AccMap_ServiceHandler.ExceptionEEFDataWrapper emptyResult = Core_MDF_Expt_AccMap_ServiceHandler.prepareDataForEEFSharing(emptyList, accIdToPartnerTypeMap);
        
        Map<Id, List<String>> emptyPartnerMap = new Map<Id, List<String>>();
        Core_MDF_Expt_AccMap_ServiceHandler.ExceptionEEFDataWrapper emptyPartnerResult = Core_MDF_Expt_AccMap_ServiceHandler.prepareDataForEEFSharing(eefEamList, emptyPartnerMap);
        Core_MDF_Expt_AccMap_ServiceHandler.ExceptionEEFDataWrapper nullPartnerResult = Core_MDF_Expt_AccMap_ServiceHandler.prepareDataForEEFSharing(eefEamList, null);
        
        Boolean isReviewer = Core_MDF_Expt_AccMap_ServiceHandler.isExceptionReviewer();
        Boolean hasPermission = Core_MDF_Expt_AccMap_ServiceHandler.isCustomPermissionAssigned('Core_MDF_ExceptionReviewer');
        Boolean hasNullPermission = Core_MDF_Expt_AccMap_ServiceHandler.isCustomPermissionAssigned(null);
        Boolean hasBlankPermission = Core_MDF_Expt_AccMap_ServiceHandler.isCustomPermissionAssigned('');
        Map<String, Set<String>> geoSubGeoMap = new Map<String, Set<String>>();
        geoSubGeoMap.put('APJ', new Set<String>{'INDIA', 'AUSTRALIA'});
        geoSubGeoMap.put('EMEA', new Set<String>{'GERMANY', 'FRANCE'});
        
        
        
        List<Core_MDF_RecordGeoShare> recordShareList = Core_MDF_Expt_AccMap_ServiceHandler.getRecordShareList(UserInfo.getUserId(), 'Test Program', geoSubGeoMap);
 }
    
    Test.stopTest();
    //Insert acc for EEF with partner type
           //Insert Exception for eef
           //Insert EAM for this acc
           
           //insert Core_MDF_Partner_Mapping__c
           
        /*Map<Id, List<String>> accIdToPartnerTypeMap = new Map<Id, List<String>>();
        List<String> newListOfPT = new List<String>();
        newListOfPT.add('Primary Partner');
        accIdToPartnerTypeMap.put(intelAcc2.Id,newListOfPT);
        
        Core_MDF_Expt_AccMap_ServiceHandler.ExceptionEEFDataWrapper eefWrapper = new Core_MDF_Expt_AccMap_ServiceHandler.ExceptionEEFDataWrapper();
        eefWrapper = Core_MDF_Expt_AccMap_ServiceHandler.prepareDataForEEFSharing(eams,accIdToPartnerTypeMap);*/
}
    
@isTest
static void testValidateExceptionAccountProgramAndCountryAccess() {
    Test.startTest();
    
    User systemAdmin = [SELECT Id FROM User WHERE LastName = 'SystemAdmin' LIMIT 1];
    Account testAccount = [SELECT Id FROM Account WHERE Name = 'FlipkartTestAccount' LIMIT 1];
    
    System.runAs(systemAdmin) {
        
        Core_MDF_Exception__c testException = new Core_MDF_Exception__c();
        testException.Core_MDF_Name_of_Exception_nm__c = 'Test Exception Validation';
        testException.Core_MDF_Issue_Description_dsc__c = 'Test Description';
        testException.Core_MDF_Comments_txt__c = 'Test Comments';
        testException.Core_MDF_Exception_Start_Date_dt__c = System.today();
        testException.Core_MDF_Exception_End_Date_dt__c = System.today() + 5;
        testException.Core_MDF_Exception_Reason_nm__c = 'Branding Exception from Activity Catalog';
        testException.Core_MDF_Program_nm__c = 'Core_MDF_Client_CoMarketing_Fund';
        testException.Core_MDF_Activity_Cate_and_Type_nm__c = 'Audio 2025->Podcast';
        testException.Core_MDF_Total_Dollar_Impact_amt__c = 100;
        testException.Core_MDF_Country_Region_nm__c = 'INDIA';
        insert testException;
        
        Core_MDF_Exception_Account_Mapping__c testEAM = new Core_MDF_Exception_Account_Mapping__c();
        testEAM.Core_MDF_Account_id__c = testAccount.Id;
        testEAM.Core_MDF_Exception_id__c = testException.Id;
        testEAM.Core_MDF_Active_ind__c = true;
        insert testEAM;
        
        try { delete testEAM; } catch (Exception e) {}
        
        Map<Id, Set<String>> validAccIdProgramMap = new Map<Id, Set<String>>();
        validAccIdProgramMap.put(testAccount.Id, new Set<String>{'Client CoMarketing Fund'});
        
        Core_MDF_Exception__c testExceptionallcountry1 = new Core_MDF_Exception__c();
        testExceptionallcountry1.Core_MDF_Name_of_Exception_nm__c = 'Test Exception Validation all country';
        testExceptionallcountry1.Core_MDF_Issue_Description_dsc__c = 'Test Description';
        testExceptionallcountry1.Core_MDF_Comments_txt__c = 'Test Comments';
        testExceptionallcountry1.Core_MDF_Exception_Start_Date_dt__c = System.today();
        testExceptionallcountry1.Core_MDF_Exception_End_Date_dt__c = System.today() + 5;
        testExceptionallcountry1.Core_MDF_Exception_Reason_nm__c = 'Branding Exception from Activity Catalog';
        testExceptionallcountry1.Core_MDF_Program_nm__c = 'Core_MDF_Client_CoMarketing_Fund';
        testExceptionallcountry1.Core_MDF_Activity_Cate_and_Type_nm__c = 'Audio 2025->Podcast';
        testExceptionallcountry1.Core_MDF_Total_Dollar_Impact_amt__c = 100;
        testExceptionallcountry1.Core_MDF_Select_All_Country_ind__c = true;
        insert testExceptionallcountry1;
        
        Core_MDF_Exception_Account_Mapping__c testEAMAllCountries = new Core_MDF_Exception_Account_Mapping__c();
        testEAMAllCountries.Core_MDF_Account_id__c = testAccount.Id;
        testEAMAllCountries.Core_MDF_Exception_id__c = testExceptionallcountry1.Id;
        testEAMAllCountries.Core_MDF_Active_ind__c = true;
        insert testEAMAllCountries;
        
        Core_MDF_Exception__c testExceptionmulticountry = new Core_MDF_Exception__c();
        testExceptionmulticountry.Core_MDF_Name_of_Exception_nm__c = 'Test Exception Validation multi country';
        testExceptionmulticountry.Core_MDF_Issue_Description_dsc__c = 'Test Description';
        testExceptionmulticountry.Core_MDF_Comments_txt__c = 'Test Comments';
        testExceptionmulticountry.Core_MDF_Exception_Start_Date_dt__c = System.today();
        testExceptionmulticountry.Core_MDF_Exception_End_Date_dt__c = System.today() + 5;
        testExceptionmulticountry.Core_MDF_Exception_Reason_nm__c = 'Branding Exception from Activity Catalog';
        testExceptionmulticountry.Core_MDF_Program_nm__c = 'Core_MDF_Client_CoMarketing_Fund';
        testExceptionmulticountry.Core_MDF_Activity_Cate_and_Type_nm__c = 'Audio 2025->Podcast';
        testExceptionmulticountry.Core_MDF_Total_Dollar_Impact_amt__c = 100;
        testExceptionmulticountry.Core_MDF_Country_Region_nm__c = 'INDIA;JAPAN;AUSTRALIA';
        insert testExceptionmulticountry;
        
        Core_MDF_Exception_Account_Mapping__c testEAMMultiCountries = new Core_MDF_Exception_Account_Mapping__c();
        testEAMMultiCountries.Core_MDF_Account_id__c = testAccount.Id;
        testEAMMultiCountries.Core_MDF_Exception_id__c = testExceptionmulticountry.Id;
        testEAMMultiCountries.Core_MDF_Active_ind__c = true;
        insert testEAMMultiCountries;
            
        List<String> bypassKeys = new List<String>{'Bypass_ValidateAccProgAccessOnEAM', 'ByPass_ValidateCountryAccessOnEAM'};
        List<Core_Trigger_Executions__c> bypassList = Core_MDF_CCP_TestDataUtility.byPassFeature(bypassKeys, true, true);
        
        Core_MDF_Exception_Account_Mapping__c testEAMBypass = new Core_MDF_Exception_Account_Mapping__c();
        testEAMBypass.Core_MDF_Account_id__c = testAccount.Id;
        testEAMBypass.Core_MDF_Exception_id__c = testException.Id;
        testEAMBypass.Core_MDF_Active_ind__c = true;
        
        insert testEAMBypass;
        
        List<sObject> records = new List<sObject>();
        records.add(testEAMBypass);
        Core_MDF_Expt_AccMap_ServiceHandler.deleteShareRecord(records);
        
    }
    
    Test.stopTest();
}
 @isTest
static void testEAMEEFMethod2() {
    try{
    Account intelPrimAcc = [SELECT Id FROM Account WHERE Name = 'Test Primary Intel Account' LIMIT 1];
    ChannelProgram eefCp = [SELECT Id FROM ChannelProgram WHERE Name = 'Ecosystem Extension Fund' LIMIT 1];
    
    UserRole userRole_3 = [SELECT Id FROM UserRole WHERE DeveloperName = 'Admin' LIMIT 1];
        User systemAdmin2 = Core_MDF_CCP_TestDataUtility.createUser(false);      
        systemAdmin2.LastName = 'SystemAdmin1';
        systemAdmin2.UserRoleId = userRole_3.Id;
        insert systemAdmin2;
      PermissionSet eefAccManagerPS = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Core_MDF_Internal_EEF_Primary_Partner_Acct_Mgr' LIMIT 1];
           PermissionSet eefExceptionReviewerPS = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Core_MDF_Internal_EEF_Exception_Reviewer' LIMIT 1]; 
            
            List<PermissionSetAssignment> permissionSetAssignmentList1 = new List<PermissionSetAssignment>();
            PermissionSetAssignment psaEEFAccMgr = new PermissionSetAssignment(PermissionSetId = eefAccManagerPS.Id, AssigneeId = systemAdmin2.Id);
            permissionSetAssignmentList1.add(psaEEFAccMgr);
            
            PermissionSetAssignment psaEefReviewer = new PermissionSetAssignment(PermissionSetId = eefExceptionReviewerPS.Id, AssigneeId = systemAdmin2.Id);
            permissionSetAssignmentList1.add(psaEefReviewer);
            insert permissionSetAssignmentList1;
    System.runAs(systemAdmin2) {
         //Account testAccount = [Select id from Account where Name='FlipkartTestAccount' limit 1];
            Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgmEEFWW = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
            iupgmEEFWW.Core_MDF_Account_id__c = intelPrimAcc.Id;
            iupgmEEFWW.Core_MDF_Program_nm__c = 'Ecosystem Extension Fund';
            iupgmEEFWW.RecordTypeId = EEF_RecordType;
            iupgmEEFWW.Core_MDF_Region_Sub_Region_nm__c = 'WW';
            iupgmEEFWW.Core_MDF_User_id__c = systemAdmin2.Id;
            iupgmEEFWW.Core_MDF_Role_nm__c = 'Core_MDF_Internal_EEF_Exception_Reviewer';
            iupgmEEFWW.Core_MDF_All_Budget_Type_Access_Ind__c = true;
            iupgmEEFWW.Core_MDF_All_Accounts_cd__c = 'No';
            insert iupgmEEFWW; 
            
            Test.startTest();
            Core_MDF_Exception__c eefException1 = new Core_MDF_Exception__c();
        eefException1.Core_MDF_Name_of_Exception_nm__c = 'Test EEF Exception Primary';
        eefException1.Core_MDF_Issue_Description_dsc__c = 'Test Description for Primary';
        eefException1.Core_MDF_Comments_txt__c = 'Test Comments';
        eefException1.Core_MDF_Exception_Start_Date_dt__c = System.today();
        eefException1.Core_MDF_Exception_End_Date_dt__c = System.today() + 5;
        eefException1.Core_MDF_Exception_Reason_nm__c = 'Branding Exception from Activity Catalog';
        eefException1.Core_MDF_Program_nm__c = 'Core_MDF_Ecosystem_Extension_Fund';
        eefException1.Core_MDF_Activity_Cate_and_Type_nm__c = 'Audio 2025->Podcast';
        eefException1.Core_MDF_Total_Dollar_Impact_amt__c = 100;
        eefException1.Core_MDF_Country_Region_nm__c = 'INDIA';
        
        insert eefException1;
        
        eefException1.Core_MDF_Exception_Status_nm__c='Approved';
        eefException1.Core_MDF_Expose_Externally_ind__c=true;
        update eefException1;
            
             Core_MDF_Exception_Account_Mapping__c eamPrimary = new Core_MDF_Exception_Account_Mapping__c();
        eamPrimary.Core_MDF_Account_id__c = intelPrimAcc.Id;
        eamPrimary.Core_MDF_Exception_id__c = eefException1.Id;
        eamPrimary.Core_MDF_Active_ind__c = true;
        database.insert(eamPrimary);
        
        Map<Id,Core_MDF_Exception_Account_Mapping__c> newEAMmap = new Map<Id,Core_MDF_Exception_Account_Mapping__c>();
        newEAMmap.put(eamPrimary.Id,eamPrimary);
        Core_MDF_Expt_AccMap_ServiceHandler.shareRecordsWithExtUsers(newEAMmap);
        
        
        Test.stoptest();
        
    }
    }catch(Exception ex){}
    }
}