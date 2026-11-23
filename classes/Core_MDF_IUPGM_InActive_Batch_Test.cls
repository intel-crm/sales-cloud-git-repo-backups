@isTest
public class Core_MDF_IUPGM_InActive_Batch_Test {
    
    public static Id IUPGM_RecordType_IPA = Schema.SObjectType.Core_MDF_Int_Users_Partner_Geo_Mapping__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_Intel_Partner_Alliance').getRecordTypeId();
    
    @TestSetup
    static void createTestData(){
        
        Boolean isUnifiedIdEnabled = Core_MDF_CustomLabelConfig.getBooleanValues('Core_MDF_UnifiedIdCheck');
        User testUser = Core_MDF_CCP_TestDataUtility.createUser(false); 
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        testUser.LastName='Admin_user';
        testUser.UserRoleId = usRole.Id;
        testUser.IsActive=true;
        insert testUser;
        System.runAs(testUser){
            // 14285 Indira - start
            List<String> bypassFunctionKeys = new List<String>();
            Set<String> myset1 = new Set<String>();
            List<String> result1 = new List<String>();
            bypassFunctionKeys.add('Core_MDF_Bypass_AccOnboardValidation');
            myset1.addAll(bypassFunctionKeys);
            result1.addAll(myset1);
            List<Core_Trigger_Executions__c> bypassfunctinalitylist1 = Core_MDF_CCP_TestDataUtility.byPassFeature(result1,true,true);
            // 14285 Indira - end
            List<ChannelProgram> cpList = new List<ChannelProgram>();
            ChannelProgram ccfCp = Core_MDF_CCP_TestDataUtility.createProgram (Core_MDF_CCP_ConstantClass.CCF_PROGRAM,'Client CoMarketing Fund', false);
            ChannelProgram dcfCp = Core_MDF_CCP_TestDataUtility.createProgram (Core_MDF_CCP_ConstantClass.DCF_PROGRAM,'Data Center CoMarketing Fund', false);
            ChannelProgram retailCp = Core_MDF_CCP_TestDataUtility.createProgram ('Retail Marketing Funds','Retail Marketing Funds', false);
            ChannelProgram ipaCp = Core_MDF_CCP_TestDataUtility.createProgram ('Intel Partner Alliance','Intel Partner Alliance', false);
            cpList.add(ccfCp);
            cpList.add(dcfCp);
            cpList.add(retailCp);
            cpList.add(ipaCp);
            insert cpList;
            
            Account ccpIntelAccount = Core_MDF_CCP_TestDataUtility.createIntelAccount('CCP Test Intel Account', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false); 
            ccpIntelAccount.Core_MDF_CoMarketingActive__c= true;
            ccpIntelAccount.Core_Intel_Partner_Alliance_PartnerGroup__c= true;
            if(isUnifiedIdEnabled){
                ccpIntelAccount.Core_Unified_Global_Customer_BP_Id__c = 'ABC123';
            }else{
                ccpIntelAccount.Core_Prime_Id__c = 'ABC123'; 
            }
            Database.insert(ccpIntelAccount);
            
            Id account_Record_TypePAG = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Core_Partner_Account_Group').getRecordTypeId();
            Account ccpIntelAccount1 = Core_MDF_CCP_TestDataUtility.createIntelAccount('CCP Test Intel Account1', account_Record_TypePAG, false); 
            ccpIntelAccount1.Core_MDF_CoMarketingActive__c= true;
            ccpIntelAccount1.Core_Intel_Partner_Alliance_PartnerGroup__c= true;
            ccpIntelAccount1.Core_MDF_Active_Ind__c=true;
            Database.insert(ccpIntelAccount1);
            
            
            Account accCoMarketing2 = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test Account 3', ipaCp.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, ccpIntelAccount.Id, false);
            accCoMarketing2.Core_Geo__c = 'APJ';
            accCoMarketing2.Core_MDF_CoMarketing_Ultimate_Account__c = ccpIntelAccount.Id;
            Database.insert(accCoMarketing2);
            
            Account ccpIntelRmfAccount = Core_MDF_CCP_TestDataUtility.createIntelAccount('CCP Test Account', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);  
            ccpIntelRmfAccount.Core_MDF_CoMarketingActive__c = TRUE ;
            Database.insert(ccpIntelRmfAccount);
            Account accCoMarketing = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test Account 3', retailCp.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, ccpIntelRmfAccount.Id, false);
            accCoMarketing.Core_Geo__c = 'APJ';
            accCoMarketing.Core_Sub_Geo__c = 'ROA';
            Database.insert(accCoMarketing);
            
            Group ipaGRP = new Group();
            ipaGRP.Name = 'CCP TESTACCTTEMP CCF EMEA INTERNAL';
            ipaGRP.DeveloperName = 'Core_MDF_CCP_TESTACCTTEMP_CCF_EMEA_INTERNAL';
            Database.insert(ipaGRP);
            
           
            PermissionSet ipaL2ApproverPS = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_Proposal_Activity_L2_Approver' LIMIT 1];
            PermissionSetAssignment psa9 = new PermissionSetAssignment(PermissionSetId = ipaL2ApproverPS.Id, AssigneeId = testUser.Id);
            Database.insert(psa9);
            PermissionSet RMFApproverPS = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_Price_Reviewer' LIMIT 1];
            PermissionSetAssignment psa = new PermissionSetAssignment(PermissionSetId = RMFApproverPS.Id, AssigneeId = testUser.Id);
            Database.insert(psa);
            
            PermissionSet ipaL3ApproverPS = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_IPA_Escalation_Reviewer_L1' LIMIT 1];
            PermissionSetAssignment psa14 = new PermissionSetAssignment(PermissionSetId = ipaL3ApproverPS.Id, AssigneeId = testUser.Id);
            Database.insert(psa14);
            
            PermissionSet ipaApprPS = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Int_IPA_ProposalL1_Approver' LIMIT 1];
            PermissionSetAssignment psa15 = new PermissionSetAssignment(PermissionSetId = ipaApprPS.Id, AssigneeId = testUser.Id);
            Database.insert(psa15);
            
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
            
            Profile ccpCoreProfile = [SELECT Id FROM Profile WHERE Name = 'CCP - Core Access'];
            
            PermissionSet ccfAccManagerPS = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_CCF_Acct_Mgr' LIMIT 1];
            PermissionSet dcfAccManagerPS = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_DCF_Acct_Mgr' LIMIT 1];
            PermissionSet retailAccManagerPS = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_Retail_Account_Manager' LIMIT 1];
            PermissionSet readOnlyUsrPS = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Int_Read_Only' LIMIT 1];
            PermissionSet ipaAccManagerPS = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_IPA_Acct_Mgr' LIMIT 1];
            PermissionSet ipaProgAdmPS = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_IPA_Program_Adm' LIMIT 1];
            PermissionSet ipaEscRevL1PS = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_IPA_Escalation_Reviewer_L1' LIMIT 1];
            
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
            
            insert userList;
            
            
            PermissionSetAssignment ps = new PermissionSetAssignment(PermissionSetId = ccfAccManagerPS.Id, AssigneeId = ccfAccountManagerinactive.Id);
            permissionSetAssignmentList.add(ps);
                       
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
            
            PermissionSetAssignment psa12 = new PermissionSetAssignment(PermissionSetId = ipaEscRevL1PS.Id, AssigneeId = progAdmUsr.Id);
            permissionSetAssignmentList.add(psa12);
            
            PermissionSetAssignment psaEscReviewer = new PermissionSetAssignment(PermissionSetId = ipaEscRevL1PS.Id, AssigneeId = escReviewer.Id);
            permissionSetAssignmentList.add(psaEscReviewer);
            
            insert permissionSetAssignmentList;
                       
            List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> iupgmList = new List<Core_MDF_Int_Users_Partner_Geo_Mapping__c>();

			Core_MDF_Int_Users_Partner_Geo_Mapping__c IPAiupgm6= new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
            IPAiupgm6.Core_MDF_Account_id__c = ccpIntelAccount.Id;
            IPAiupgm6.Core_MDF_Program_nm__c = 'Intel Partner Alliance';
            IPAiupgm6.RecordTypeId = IUPGM_RecordType_IPA;
            IPAiupgm6.Core_MDF_Region_cd__c = 'EMEA';
            IPAiupgm6.Core_MDF_Region_Sub_Region_nm__c = 'EMEA';
            IPAiupgm6.Core_MDF_Budget_Type_nm__c='Account Plan';
            IPAiupgm6.Core_MDF_GeoSubGeo_Budget_Type_nm__c='EMEA->Client Specialties MDF';
            IPAiupgm6.Core_MDF_User_id__c =testUser.Id;
            IPAiupgm6.Core_MDF_Role_nm__c='Core_MDF_CCP_Internal_Proposal_Activity_L2_Approver';
            IPAiupgm6.Core_MDF_All_Accounts_cd__c = 'No';
            IPAiupgm6.Core_MDF_Active_Ind__c = TRUE;
            IPAiupgm6.Core_MDF_All_Budget_Type_Access_Ind__c = false;
            IPAiupgm6.Core_MDF_Activity_Classification_nm__c ='Sales;Marketing';
            iupgmList.add(IPAiupgm6);
            
            Core_MDF_Int_Users_Partner_Geo_Mapping__c IPAiupgm7= new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
            IPAiupgm7.Core_MDF_Account_id__c = ccpIntelAccount.Id;
            IPAiupgm7.Core_MDF_Program_nm__c = 'Intel Partner Alliance';
            IPAiupgm7.RecordTypeId = IUPGM_RecordType_IPA;
            IPAiupgm7.Core_MDF_Region_cd__c = 'EMEA';
            IPAiupgm7.Core_MDF_Region_Sub_Region_nm__c = 'EMEA';
            IPAiupgm7.Core_MDF_User_id__c =testUser.Id;
            IPAiupgm7.Core_MDF_Role_nm__c='Core_MDF_CCP_Int_IPA_ProposalL1_Approver';
            IPAiupgm7.Core_MDF_All_Accounts_cd__c = 'No';
            IPAiupgm7.Core_MDF_All_Budget_Type_Access_Ind__c = true;
            iupgmList.add(IPAiupgm7);
            
              insert iupgmList; 
            
        }
    }
    @isTest
    public static void testMethod1(){
        Test.startTest();
        Core_MDF_IUPGM_InActive_Batch obj=new Core_MDF_IUPGM_InActive_Batch();
        database.executebatch(obj,5);
        Id batchId = Database.executeBatch(obj);
        Test.stopTest();
        Assert.areNotEqual(batchId,null);
      } 
}