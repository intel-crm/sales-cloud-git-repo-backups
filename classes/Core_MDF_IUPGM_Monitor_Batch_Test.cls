@isTest
public class Core_MDF_IUPGM_Monitor_Batch_Test {
    @TestSetup
    static void createTestData(){
        
        User testUser = Core_MDF_CCP_TestDataUtility.createUser(false); 
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        testUser.LastName='Admin_user';
        testUser.UserRoleId = usRole.Id;
        insert testUser;
        System.runAs(testUser){
            //Test.startTest();
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
            ccpIntelAccount.Core_Prime_Id__c = 'ABC123';
            ccpIntelAccount.Core_Unified_Global_Customer_BP_Id__c='1000873392';
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
            
          
            Core_Account_Group_Member__c agm= new Core_Account_Group_Member__c();
            agm.Core_Intel_Account_Id__c=ccpIntelAccount.Id;
            agm.Core_Partner_Account_Id__c=ccpIntelAccount1.Id;
            agm.Core_Inactive_Ind__c= false;
            Database.insert(agm);
            
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
            
            Core_MDF_Partner_Group_Mapping__c IPAPgm = new Core_MDF_Partner_Group_Mapping__c();
            IPAPgm.Core_MDF_Account__c =ccpIntelAccount.Id;
            IPAPgm.Core_MDF_Group_Name__c = 'Core_MDF_CCP_TESTACCTTEMP_CCF_EMEA_INTERNAL';
            IPAPgm.Core_MDF_Type_of_Access__c = 'External';           
            IPAPgm.Core_MDF_Channel_Program__c = ipaCp.Id;
            IPAPgm.Core_MDF_Inactive_Ind__c=false;
            IPAPgm.Core_MDF_Source_Txt__c = 'Test';            
            Database.insert(IPAPgm);
            
            Core_MDF_Partner_Group_Mapping__c RMFpgm = new Core_MDF_Partner_Group_Mapping__c();
            RMFpgm.Core_MDF_Account__c =ccpIntelRmfAccount.Id;
            RMFpgm.Core_MDF_Group_Name__c = 'Core_MDF_CCP_TESTACCTTEMP_CCF_EMEA_INTERNAL';
            RMFpgm.Core_MDF_Type_of_Access__c = 'External';           
            RMFpgm.Core_MDF_Channel_Program__c = retailCp.Id;
            IPAPgm.Core_MDF_Inactive_Ind__c=false;
            RMFpgm.Core_MDF_Region_cd__c = 'EMEA';
            RMFpgm.Core_MDF_Source_Txt__c = 'Test'; 
            Database.insert(RMFpgm);
            
           
            PermissionSet ipaL2ApproverPS = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_Proposal_Activity_L2_Approver' LIMIT 1];
            PermissionSetAssignment psa9 = new PermissionSetAssignment(PermissionSetId = ipaL2ApproverPS.Id, AssigneeId = testUser.Id);
            Database.insert(psa9);
            PermissionSet RMFApproverPS = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_Price_Reviewer' LIMIT 1];
            PermissionSetAssignment psa = new PermissionSetAssignment(PermissionSetId = RMFApproverPS.Id, AssigneeId = testUser.Id);
            Database.insert(psa);
            
            PermissionSet ipaL3ApproverPS = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_IPA_Escalation_Reviewer_L1' LIMIT 1];
            PermissionSetAssignment psa14 = new PermissionSetAssignment(PermissionSetId = ipaL3ApproverPS.Id, AssigneeId = testUser.Id);
            Database.insert(psa14);
            
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
                         
            Core_MDF_Partner_Group_Mapping__c ccfPgm = new Core_MDF_Partner_Group_Mapping__c();
            ccfPgm.Core_MDF_Account__c = testAcctTemp.Id;
            ccfPgm.Core_MDF_Group_Name__c = 'Core_MDF_CCP_TESTACCTTEMP_CCF_EMEA_INTERNAL';
            ccfPgm.Core_MDF_Type_of_Access__c = 'Internal';           
            ccfPgm.Core_MDF_Channel_Program__c = ccfCp.Id;
            ccfPgm.Core_MDF_Region_cd__c = 'EMEA';
            ccfPgm.Core_MDF_Source_Txt__c = 'Test';            
            Database.insert(ccfPgm);
            
            Profile ccpCoreProfile = [SELECT Id FROM Profile WHERE Name = 'CCP - Core Access'];
            
            PermissionSet ccfAccManagerPS = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_CCF_Acct_Mgr' LIMIT 1];
            PermissionSet dcfAccManagerPS = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_DCF_Acct_Mgr' LIMIT 1];
            PermissionSet retailAccManagerPS = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_Retail_Account_Manager' LIMIT 1];
            PermissionSet readOnlyUsrPS = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Int_Read_Only' LIMIT 1];
            PermissionSet ipaAccManagerPS = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_IPA_Acct_Mgr' LIMIT 1];
            PermissionSet ipaProgAdmPS = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_IPA_Program_Adm' LIMIT 1];
            PermissionSet ipaApprPS = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Int_IPA_ProposalL1_Approver' LIMIT 1];
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
            //
            // Insert mock BudgetType-Benefit mappings
            List<Core_MDF_BudgetType_Benefit_Mappings__c> mappings = new List<Core_MDF_BudgetType_Benefit_Mappings__c>{
                new Core_MDF_BudgetType_Benefit_Mappings__c(
                    Name='test',
                    Core_MDF_Budget_Type__c = 'SOEM Data Center MDF',
                    Core_MDF_Partner_Benefit__c = 'Strategic OEM – DCG MDF',
                    Core_MDF_Program_Nm__c = 'Intel Partner Alliance',
                    Core_MDF_Is_IUPGM_Monitor_Applicable_Ind__c = true
                ),
                    new Core_MDF_BudgetType_Benefit_Mappings__c(
                        Name='test2',
                        Core_MDF_Budget_Type__c = 'Proposal I MDF',
                        Core_MDF_Partner_Benefit__c = 'MDFPRPCCP',
                        Core_MDF_Program_Nm__c = 'Intel Partner Alliance',
                        Core_MDF_Is_IUPGM_Monitor_Applicable_Ind__c = true
                    ),
                    
                    new Core_MDF_BudgetType_Benefit_Mappings__c(
                        Name='test3',
                        Core_MDF_Budget_Type__c = 'Proposal II MDF',
                        Core_MDF_Partner_Benefit__c = 'Proposal II MDF',
                        Core_MDF_Program_Nm__c = 'Intel Partner Alliance',
                        Core_MDF_Is_IUPGM_Monitor_Applicable_Ind__c = true
                    ),
                    new Core_MDF_BudgetType_Benefit_Mappings__c(
                        Name='test4',
                        Core_MDF_Budget_Type__c = 'Proposal I MDF',
                        Core_MDF_Partner_Benefit__c = 'Proposal I MDF',
                        Core_MDF_Program_Nm__c = 'Intel Partner Alliance',
                        Core_MDF_Is_IUPGM_Monitor_Applicable_Ind__c = true
                    )
                    };
                        insert mappings;
            //
            
            
            
            
            List<Core_MDF_ProgramGeoRoleGroupMap__c> progGeoRoleGrpList = new List<Core_MDF_ProgramGeoRoleGroupMap__c>();
            Core_MDF_ProgramGeoRoleGroupMap__c progGeoRoleGrp = new Core_MDF_ProgramGeoRoleGroupMap__c();
            progGeoRoleGrp.Core_MDF_Program_txt__c = 'Intel Partner Alliance';
            progGeoRoleGrp.Name = 'Test Role';
            progGeoRoleGrp.Core_MDF_Is_For_IUPGM_Monitor_Ind__c=true;
            //progGeoRoleGrp.Core_MDF_Is_Ultimate_Account_Based_Ind__c=true;
            progGeoRoleGrp.Core_MDF_Budget_Type_txt__c='Account Plan';
            progGeoRoleGrp.Core_MDF_Region_txt__c = 'APJ';
            progGeoRoleGrp.Core_MDF_Is_Primary_Role__c = false;
            progGeoRoleGrp.Core_MDF_Role_txt__c = 'Core_MDF_CCP_Internal_Proposal_Activity_L2_Approver';
            progGeoRoleGrp.Core_MDF_Group_Name_txt__c = 'Core_MDF_CCP_IPA_APJ_Escltns_L1_Apr_Grp';
            progGeoRoleGrp.Core_MDF_Is_Active__c = true;
            progGeoRoleGrp.Core_MDF_Is_Budget_Type_Applicable_Ind__c=true;
            progGeoRoleGrpList.add(progGeoRoleGrp);
            
            Core_MDF_ProgramGeoRoleGroupMap__c progGeoRoleGrpNew = new Core_MDF_ProgramGeoRoleGroupMap__c();
            progGeoRoleGrpNew.Core_MDF_Program_txt__c = 'Intel Partner Alliance';
            progGeoRoleGrpNew.Name = 'Test RoleNew';
            progGeoRoleGrpNew.Core_MDF_Is_For_IUPGM_Monitor_Ind__c=true;
            // progGeoRoleGrpNew.Core_MDF_Is_Ultimate_Account_Based_Ind__c=true;
            progGeoRoleGrpNew.Core_MDF_Budget_Type_txt__c='Account Plan';
            progGeoRoleGrpNew.Core_MDF_Region_txt__c = 'APJ';
            progGeoRoleGrpNew.Core_MDF_Is_Primary_Role__c = false;
            progGeoRoleGrpNew.Core_MDF_Role_txt__c = 'Core_MDF_CCP_Internal_Proposal_Activity_L2_Approver';
            progGeoRoleGrpNew.Core_MDF_Group_Name_txt__c = 'Core_MDF_CCP_IPA_APJ_Escltns_L1_Apr_Grp';
            progGeoRoleGrpNew.Core_MDF_Is_Active__c = true;
            progGeoRoleGrpNew.Core_MDF_Is_Budget_Type_Applicable_Ind__c=true;
            progGeoRoleGrpList.add(progGeoRoleGrpNew);
            
            Core_MDF_ProgramGeoRoleGroupMap__c progGeoRoleGrp1 = new Core_MDF_ProgramGeoRoleGroupMap__c();
            progGeoRoleGrp1.Core_MDF_Program_txt__c = 'Retail Marketing Funds';
            progGeoRoleGrp1.Name = 'Test Role1';
            progGeoRoleGrp1.Core_MDF_Is_For_IUPGM_Monitor_Ind__c=true;
            //progGeoRoleGrp1.Core_MDF_Is_Ultimate_Account_Based_Ind__c=true;
            progGeoRoleGrp1.Core_MDF_Region_txt__c = 'APJ';
            progGeoRoleGrp1.Core_MDF_Is_Primary_Role__c = true;
            progGeoRoleGrp1.Core_MDF_Budget_Type_txt__c='Retail MDF';
            progGeoRoleGrp1.Core_MDF_Role_txt__c = 'Core_MDF_CCP_Internal_Price_Reviewer';
            progGeoRoleGrp1.Core_MDF_Group_Name_txt__c = 'Core_MDF_CCP_TESTACCTTEMP_CCF_EMEA_INTERNAL';
            progGeoRoleGrp1.Core_MDF_Is_Active__c = true;
            progGeoRoleGrpList.add(progGeoRoleGrp1);
            
            insert progGeoRoleGrpList;
           
        Id IUPGM_recordtype_IPA = Schema.SObjectType.Core_MDF_Int_Users_Partner_Geo_Mapping__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_Intel_Partner_Alliance').getRecordTypeId();
Id IUPGM_recordtype_RMF = Schema.SObjectType.Core_MDF_Int_Users_Partner_Geo_Mapping__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_Retail_Marketing_Funds').getRecordTypeId();
            Core_MDF_Int_Users_Partner_Geo_Mapping__c IPAiupgm5= new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
            IPAiupgm5.Core_MDF_Account_id__c = ccpIntelAccount.Id;
            IPAiupgm5.Core_MDF_Program_nm__c = 'Intel Partner Alliance';
             IPAiupgm5.RecordTypeId = IUPGM_recordtype_IPA;
            IPAiupgm5.Core_MDF_Region_cd__c = 'WW';
            IPAiupgm5.Core_MDF_Region_Sub_Region_nm__c = 'WW';
            IPAiupgm5.Core_MDF_Budget_Type_nm__c='Account Plan';
            IPAiupgm5.Core_MDF_GeoSubGeo_Budget_Type_nm__c='EMEA->Client Specialties MDF';
            IPAiupgm5.Core_MDF_User_id__c =testUser.Id;
            IPAiupgm5.Core_MDF_Role_nm__c='Core_MDF_CCP_Internal_Proposal_Activity_L2_Approver';
            IPAiupgm5.Core_MDF_All_Accounts_cd__c = 'Yes';
            IPAiupgm5.Core_MDF_All_Budget_Type_Access_Ind__c = false;
            IPAiupgm5.Core_MDF_Activity_Classification_nm__c ='Sales;Marketing';
            Database.insert(IPAiupgm5);
       
            Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm01 = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
            iupgm01.Core_MDF_Account_id__c = ccpIntelRmfAccount.Id;
            iupgm01.Core_MDF_All_Accounts_cd__c ='Yes';
            iupgm01.Core_MDF_Program_nm__c = 'Retail Marketing Funds';
   iupgm01.RecordTypeId = IUPGM_recordtype_RMF;
            iupgm01.Core_MDF_Region_cd__c = 'EMEA';
            iupgm01.Core_MDF_Region_Sub_Region_nm__c = 'EMEA';
            iupgm01.Core_MDF_User_id__c = testUser.Id;
            iupgm01.Core_MDF_Budget_Type_nm__c='Retail MDF';
            iupgm01.Core_MDF_Role_nm__c = 'Core_MDF_CCP_Internal_Price_Reviewer';
            //iupgm01.Core_MDF_GeoSubGeo_Budget_Type_nm__c='EMEA->Client Specialties MDF';
            iupgm01.Core_MDF_All_Budget_Type_Access_Ind__c = false;
            insert iupgm01;

            
            //Test.stopTest();
            List<Core_MDF_Partner_Group_Mapping__c> pgmList1= [SELECT Id, Core_MDF_Account__c, Core_MDF_Account__r.Name, Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c
            FROM Core_MDF_Partner_Group_Mapping__c 
            WHERE Core_MDF_Type_of_Access__c = 'External'
            AND Core_MDF_Account__c != NULL 
            AND Core_MDF_Channel_Program__c != NULL 
            AND Core_MDF_Account__r.Core_MDF_CoMarketingActive__c = TRUE 
            AND Core_MDF_Inactive_Ind__c = FALSE
            ];
            for(Core_MDF_Partner_Group_Mapping__c pgm:pgmList1){
            }
            
            
            List<Core_MDF_ProgramGeoRoleGroupMap__c> csReclist = [SELECT Id, Core_MDF_Region_txt__c, Core_MDF_Program_txt__c,Core_MDF_Role_txt__c,Core_MDF_Is_Budget_Type_Applicable_Ind__c
                                                                  FROM Core_MDF_ProgramGeoRoleGroupMap__c
                                                                  WHERE Core_MDF_Is_Active__c = true 
                                                                  AND Core_MDF_Is_For_IUPGM_Monitor_Ind__c = true];
            
            
            PRM_Specialty__c prmSpec = new PRM_Specialty__c();
            prmSpec.Name='Proposal I MDF';
            prmSpec.PRM_Access_Level_Nm__c='Public';
            prmSpec.PRM_Description_Txt__c='Test';
            prmSpec.PRM_Funding_BU_Nm__c='CCG Sales Group';
            prmSpec.PRM_Role_Nm__c='Manufacturer';
            prmSpec.PRM_Start_Date_Dt__c=System.today();
            prmSpec.PRM_Tier_Nm__c='Member';
            insert prmSpec;
             Test.startTest();
            PRM_Account_Specialty_Association__c prmAccSpec= new PRM_Account_Specialty_Association__c();
           // prmAccSpec.Name='Test prmAccSpec';
            prmAccSpec.PRM_Account_Id__c=ccpIntelAccount.Id;
            prmAccSpec.PRM_Specialty_Id__c=prmSpec.Id;
            insert prmAccSpec;
            Test.stopTest();
            
        }
    }
    @isTest
    public static void testMethod1(){
        
        Test.startTest();
       
        Account acc = [SELECT Id,Core_Unified_Global_Customer_BP_Id__c,Core_MDF_CoMarketingActive__c,Core_IPA_One_Partner_Id__c FROM Account WHERE Name = 'CCP Test Intel Account' limit 1];
        
        
        Set<String> programSet = new set<String>();
        for(Core_MDF_ProgramGeoRoleGroupMap__c pfrgm : [SELECT Id,
                                                        Core_MDF_Region_txt__c,
                                                        Core_MDF_Program_txt__c, 
                                                        Core_MDF_Role_txt__c,
                                                        Core_MDF_Is_Budget_Type_Applicable_Ind__c
                                                        FROM Core_MDF_ProgramGeoRoleGroupMap__c
                                                        WHERE Core_MDF_Is_Active__c = true 
                                                        AND Core_MDF_Is_For_IUPGM_Monitor_Ind__c = true]){
                                                            programSet.add(pfrgm.Core_MDF_Program_txt__c);     
                                                        }
        
        Map<String, String> benefitToBudgetTypeMap = new Map<String, String>();
        for(Core_MDF_BudgetType_Benefit_Mappings__c   budgetTypeBenefit : [SELECT Id, Core_MDF_Budget_Type__c, Core_MDF_Partner_Benefit__c from Core_MDF_BudgetType_Benefit_Mappings__c   
                                                                           WHERE Core_MDF_Program_Nm__c IN :programSet
                                                                           And Core_MDF_Is_IUPGM_Monitor_Applicable_Ind__c = TRUE]){
                                                                               benefitToBudgetTypeMap.put(budgetTypeBenefit.Core_MDF_Partner_Benefit__c, budgetTypeBenefit.Core_MDF_Budget_Type__c);
                                                                               
                                                                           }
        PRM_Specialty__c xyz=[select id,name from PRM_Specialty__c];  
        
        PRM_Account_Specialty_Association__c asa=[SELECT PRM_Account_Id__c,PRM_Specialty_Id__r.Name,PRM_Specialty_Id__c 
                                                  FROM PRM_Account_Specialty_Association__c 
                                                  WHERE PRM_Specialty_Id__r.Name in: benefitToBudgetTypeMap.keySet()
                                                  AND PRM_Account_Id__c=:acc.id 
                                                  AND PRM_Specialty_Id__c != null 
                                                  AND PRM_Specialty_Id__r.Name != null
                                                 ];
        
        system.debug('asa:::'+asa);
        system.debug('xyz:::'+xyz);
        Core_MDF_IUPGM_Monitor_Batch obj=new Core_MDF_IUPGM_Monitor_Batch();
        database.executebatch(obj,5);
        database.executebatch(obj);
        Id batchId = Database.executeBatch(obj);
        Test.stopTest();
      }
      @isTest
    public static void testMethod2(){
        Set<String> programSet = new set<String>();
        Test.startTest();
        List<String> csvDataList= new List<String>();
        csvDataList.add('Test');
        Set<String> primeIdSet =  new Set<String>();
        primeIdSet.add('ABC123');
         for(Core_MDF_ProgramGeoRoleGroupMap__c pfrgm : [SELECT Id,
                                                        Core_MDF_Region_txt__c,
                                                        Core_MDF_Program_txt__c, 
                                                        Core_MDF_Role_txt__c,
                                                        Core_MDF_Is_Budget_Type_Applicable_Ind__c
                                                        FROM Core_MDF_ProgramGeoRoleGroupMap__c
                                                        WHERE Core_MDF_Is_Active__c = true 
                                                       AND Core_MDF_Is_For_IUPGM_Monitor_Ind__c = true]){
                                                       programSet.add(pfrgm.Core_MDF_Program_txt__c);     
                                                       }
        
        Map<String, String> benefitToBudgetTypeMap = new Map<String, String>();
        for(Core_MDF_BudgetType_Benefit_Mappings__c   budgetTypeBenefit : [SELECT Id, Core_MDF_Budget_Type__c, Core_MDF_Partner_Benefit__c from Core_MDF_BudgetType_Benefit_Mappings__c   
                                                                           WHERE Core_MDF_Program_Nm__c IN :programSet
                                                                           And Core_MDF_Is_IUPGM_Monitor_Applicable_Ind__c = TRUE]){
                                                                               benefitToBudgetTypeMap.put(budgetTypeBenefit.Core_MDF_Partner_Benefit__c, budgetTypeBenefit.Core_MDF_Budget_Type__c);
                                                                               
                                                                           }
        List<ContentVersion> contentVersionListToBeInserted= new List<ContentVersion>();
        
        ContentVersion cv = new ContentVersion();
        contentVersionListToBeInserted.add(cv);
        
        Core_MDF_IUPGM_Monitor_Batch obj=new Core_MDF_IUPGM_Monitor_Batch();
        //obj.GetLocationAccountsByPrimeId(primeIdSet);
        obj.createContentVersion(csvDataList);
        obj.saveAttachment(contentVersionListToBeInserted);
        Test.stopTest();
      }
    @isTest
    static void testCoverageForBenefitMappingsQuery() {
        Test.startTest();
        // Step 1: Prime Id set
        Set<String> primeIdSet = new Set<String>{ 'ABC123' };
            Map<String, String> benefitToBudgetTypeMap = new Map<String, String>();
        // Step 5: Call your actual method
        Core_MDF_IUPGM_Monitor_Batch obj = new Core_MDF_IUPGM_Monitor_Batch();
        Map<Id, Set<String>> result =
            obj.GetBenefitsMappedtoAccountByOPId(primeIdSet, benefitToBudgetTypeMap);
        Test.stopTest();
    }
}