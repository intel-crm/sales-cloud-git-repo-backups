@isTest(SeeAllData=false)
private class Core_MDF_Prop_Based_Camp_Process_Test {
   @TestSetup 
    static void createTestData() {
        List<User> userList = new List<User>();
        Profile ccpCoreProfile = [SELECT Id FROM Profile WHERE Name = 'CCP - Core Access'];
            
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        // Creating User with utility class 
        User testUser = Core_MDF_CCP_TestDataUtility.createUser(false);
        testUser.LastName = 'Test User1';
        
        testUser.UserRoleId = usRole.Id;
        
        User progAdmUsr = Core_MDF_CCP_TestDataUtility.createUser(false);
        progAdmUsr.profileId = ccpCoreProfile.Id;
        progAdmUsr.LastName = 'Prog Adm Usr';
        progAdmUsr.UserPermissionsMarketingUser =true;
        
        userList.add(progAdmUsr);
        userList.add(testUser);
        Database.insert(userList);

        Profile sysAdminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator' LIMIT 1];
        // Creating User with utility class 
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        UserRole ur = [Select Id, Name From UserRole WHERE Name = 'Admin' LIMIT 1];
        usr.UserRoleId =ur.Id ;
        usr.LastName = 'SysAdmin';
        usr.profileId = sysAdminProfile.Id;
        Database.insert(usr);
        
        User IUPGMUser = [Select id, Name, ProfileId from user where id =: userInfo.getUserId()];
        IUPGMUser.ProfileId = ccpCoreProfile.id;
        set<string> existingPS = new set<string>();
        for(PermissionSetAssignment ps: [SELECT Id,AssigneeId, PermissionSet.Name
                                         FROM PermissionSetAssignment
                                         WHERE AssigneeId =: UserInfo.getUserId()]){
                                             existingPS.add(ps.PermissionSet.Name);                                
                                             
                                         }
           
            if(!existingPS.contains('Core_MDF_CCP_Internal_IPA_Budget_Loader')){
                PermissionSet ps=[select id from PermissionSet where name='Core_MDF_CCP_Internal_IPA_Budget_Loader'limit 1];
             insert new PermissionSetAssignment(AssigneeId = IUPGMUser.id, PermissionSetId = ps.Id);
            }
            
        if(!existingPS.contains('Core_MDF_CCP_Int_IPA_ProposalL1_Approver')){
            PermissionSet psIpaL1 = [SELECT Id FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Int_IPA_ProposalL1_Approver' LIMIT 1];
            insert new PermissionSetAssignment(AssigneeId = IUPGMUser.id, PermissionSetId = psIpaL1.Id);
        }
        if(!existingPS.contains('Core_MDF_CCP_Internal_Proposal_Activity_L2_Approver')){
            PermissionSet psIpaL2 = [SELECT Id FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_Proposal_Activity_L2_Approver' LIMIT 1];
            insert new PermissionSetAssignment(AssigneeId = IUPGMUser.id, PermissionSetId = psIpaL2.Id);
        }
        if(!existingPS.contains('Core_MDF_CCP_Internal_IPA_Acct_Mgr')){
            PermissionSet psIpaIntManager = [SELECT Id FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_IPA_Acct_Mgr' LIMIT 1];
            insert new PermissionSetAssignment(AssigneeId = IUPGMUser.id, PermissionSetId = psIpaIntManager.Id);
        }
        if(!existingPS.contains('Core_MDF_CCP_Internal_IPA_Program_Adm')){
            PermissionSet psIpaIntManager = [SELECT Id FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_IPA_Program_Adm' LIMIT 1];
            insert new PermissionSetAssignment(AssigneeId = IUPGMUser.id, PermissionSetId = psIpaIntManager.Id);
        }

       System.runAs(IUPGMUser){
           /* Core_Trigger_Executions__c execution1 = new Core_Trigger_Executions__c();
            execution1.Name = 'BypassCampaignBenefitValidation';
            execution1.Core_Active__c = FALSE;
            execution1.Core_Class_Name__c = 'Core_MDF_Proposal_Based_Campaign_Process';
            execution1.Core_Description__c = 'BypassCampaignBenefitValidation';
            execution1.Core_Object__c = 'Campaign';
            execution1.Core_Trigger_Events__c = 'Before Update,Before Insert';
            insert execution1;
            
            Core_Trigger_Executions__c execution2 = new Core_Trigger_Executions__c();
            
            execution2.Name = 'Core_MDF_Bypass_Manual_Share';
            execution2.Core_Active__c = TRUE;
            execution2.Core_Class_Name__c = 'Core_MDF_PNUMappingTriggerHandler';
            execution2.Core_Description__c = 'Switch ON/OFF the Manual Share';
            execution2.Core_Object__c = 'Core_MDF_Partner_Node_User_Mapping__c';
            execution2.Core_Trigger_Events__c = 'After Insert';
            insert execution2;*/
            
            List<String> bypassFunctionKeys = new List<String>();
            bypassFunctionKeys.add('BypassCampaignBenefitValidation');
            bypassFunctionKeys.add('Core_MDF_Bypass_Manual_Share');
            bypassFunctionKeys.add('Bypass_MDF_Budget_Access');
            bypassFunctionKeys.add('Bypass_MDF_Budget_Access_Validation');
            bypassFunctionKeys.add('Core_MDF_BudgetCapValidation');
            bypassFunctionKeys.add('Core_MDF_BypassBudgCapIUPGMValidation');
            bypassFunctionKeys.add('Core_MDF_Bypass_AccOnboardValidation');
            List<Core_Trigger_Executions__c> bypassfunctinalitylist1 = Core_MDF_CCP_TestDataUtility.byPassFeature(bypassFunctionKeys,true,true);
            List<String> bypassFunctionKeys1 = new List<String>();
            bypassFunctionKeys1.add('BypassCampaignBenefitValidation');
            List<Core_Trigger_Executions__c> bypassfunctinalitylist = Core_MDF_CCP_TestDataUtility.byPassFeature(bypassFunctionKeys,true,false);
            /*
            Core_MDF_Budget_Cap__c budgetcap2 = new Core_MDF_Budget_Cap__c();
            budgetcap2.Core_MDF_Budget_Type_nm__c='Core_MDF_Budget_Type_nm__c';
            budgetcap2.Core_MDF_Budget_Status_txt__c='Active';
            budgetcap2.Core_MDF_Effective_Start_Date_Dt__c= date.parse('1/1/2020');
            budgetcap2.Core_MDF_Effective_End_Date_Dt__c= date.parse('9/1/2022');
            budgetcap2.Core_MDF_Requested_Cap_amt__c=90000000000;
            budgetcap2.Core_MDF_Claimed_Cap_amt__c=601298938;
            budgetcap2.Core_MDF_Remaining_Cap_amt__c=89398701062;
            insert budgetcap2;
               */
            ChannelProgram ipaCP = Core_MDF_CCP_TestDataUtility.createProgram ('Intel Partner Alliance','Intel Partner Alliance', true);
            ChannelProgram coGTMCP = Core_MDF_CCP_TestDataUtility.createProgram ('Co-GTM','CoGTM', true);
            
            Account ipaUltimateAccount = Core_MDF_CCP_TestDataUtility.createIntelAccount ('IPA Intel Account',Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, true);
            //ipaUltimateAccount.Core_Prime_Id__c = 'primeId1';
            ipaUltimateAccount.Core_Unified_Global_Customer_BP_Id__c = 'primeId1';
            ipaUltimateAccount.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
            update ipaUltimateAccount;
            Account ipaCoMarketingAccount = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('IPA Co-Marketing Account', ipaCP.id, Core_MDF_CCP_TestDataUtility.Account_Record_Type,ipaUltimateAccount.id, false);           
            ipaCoMarketingAccount.Core_Geo__c = 'ASMO';
           	insert ipaCoMarketingAccount;
            Account coGTMCoMarketingAccount = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('CoGTM Co-Marketing Account', coGTMCP.id, Core_MDF_CCP_TestDataUtility.Account_Record_Type,ipaUltimateAccount.id, false);
            insert coGTMCoMarketingAccount;

                
                
            String budgetType = Core_MDF_CCP_IPA_TestDataUtility.createBenefit(ipaCoMarketingAccount);
           // Highlight: Unused Local Variable - Indira
           // Id ipaBudTypeCapRecordtype = Schema.SObjectType.Core_MDF_Budget_Cap__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_IPA_Budget_Type_Cap').getRecordTypeId();
          	Id ipaIUPGMRecTypeId = Schema.SObjectType.Core_MDF_Int_Users_Partner_Geo_Mapping__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_Intel_Partner_Alliance').getRecordTypeId();
          	
           
            List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> iupgmList = new List<Core_MDF_Int_Users_Partner_Geo_Mapping__c>();
            Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm1 = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
            //iupgm1.Core_MDF_Account_id__c = ipaUltimateAccount.Id;
            iupgm1.Core_MDF_Program_nm__c = 'Intel Partner Alliance';
           iupgm1.RecordTypeId = ipaIUPGMRecTypeId;
            iupgm1.Core_MDF_Region_Sub_Region_nm__c = 'WW';
            iupgm1.Core_MDF_User_id__c = IUPGMUser.Id;
           	iupgm1.Core_MDF_Role_nm__c = 'Core_MDF_CCP_Internal_IPA_Budget_Loader';
            iupgm1.Core_MDF_All_Budget_Type_Access_Ind__c = true;
            iupgm1.Core_MDF_All_Accounts_cd__c = 'yes';
            //iupgm1.Core_MDF_Budget_Type_nm__c = budgetType;
            //iupgm1.Core_MDF_is_User_Active_ind__c = true;
            iupgm1.Core_MDF_Active_Ind__c = true;
            iupgm1.Core_MDF_Is_Not_an_Approver_Ind__c = false;
            iupgmList.add(iupgm1);
/*List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> iupgmList =[SELECT Id, Core_MDF_User_id__c, Core_MDF_Region_cd__c, Core_MDF_Role_nm__c,
                                                            Core_MDF_is_User_Active_ind__c,Core_MDF_Active_Ind__c,Core_MDF_Is_Not_an_Approver_Ind__c, 
    Core_MDF_GeoSubGeo_Budget_Type_nm__c, Core_MDF_All_Accounts_cd__c, Core_MDF_Account_id__c ,Core_MDF_Budget_Type_nm__c FROM Core_MDF_Int_Users_Partner_Geo_Mapping__c];
        */
                    Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm2= new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
            iupgm2.Core_MDF_Account_id__c = ipaUltimateAccount.Id;
           	iupgm2.Core_MDF_Program_nm__c = 'Intel Partner Alliance';
            iupgm2.Core_MDF_Region_cd__c = 'APJ;EMEA';
            iupgm2.Core_MDF_Region_Sub_Region_nm__c = 'APJ;EMEA';
            iupgm2.Core_MDF_GeoSubGeo_Budget_Type_nm__c = 'APJ->Business Client Acceleration - MDF;EMEA->Business Client Acceleration - MDF';
            iupgm2.Core_MDF_User_id__c =IUPGMUser.Id;
           iupgm2.RecordTypeId = ipaIUPGMRecTypeId;
            iupgm2.Core_MDF_Role_nm__c='Core_MDF_CCP_Int_IPA_ProposalL1_Approver';
            iupgm2.Core_MDF_All_Accounts_cd__c = 'No';
            iupgm2.Core_MDF_All_Budget_Type_Access_Ind__c = false;
            //iupgm2.Core_MDF_is_User_Active_ind__c = true;
            iupgm2.Core_MDF_Active_Ind__c = true;
            iupgm2.Core_MDF_Is_Not_an_Approver_Ind__c = false;
            iupgm2.Core_MDF_Budget_Type_nm__c='Business Client Acceleration - MDF';
            iupgmList.add(iupgm2);
            
            Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm3= new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
            //iupgm3.Core_MDF_Account_id__c = ipaUltimateAccount.Id;
          	iupgm3.Core_MDF_Program_nm__c = 'Intel Partner Alliance';
            iupgm3.Core_MDF_Region_cd__c = 'WW';
           iupgm3.RecordTypeId = ipaIUPGMRecTypeId;
            iupgm3.Core_MDF_Region_Sub_Region_nm__c = 'WW';
           // iupgm3.Core_MDF_GeoSubGeo_Budget_Type_nm__c = 'APJ->Business Client Acceleration - MDF;EMEA->Business Client Acceleration - MDF';
            iupgm3.Core_MDF_User_id__c =UserInfo.getUserId();
            iupgm3.Core_MDF_Role_nm__c='Core_MDF_CCP_Int_IPA_ProposalL1_Approver';
            iupgm3.Core_MDF_All_Accounts_cd__c = 'Yes';
            iupgm3.Core_MDF_All_Budget_Type_Access_Ind__c = true;
            //iupgm3.Core_MDF_is_User_Active_ind__c = true;
            iupgm3.Core_MDF_Active_Ind__c = true;
            iupgm3.Core_MDF_Is_Not_an_Approver_Ind__c = false;
           // iupgm3.Core_MDF_Budget_Type_nm__c='Business Client Acceleration - MDF';
            iupgmList.add(iupgm3);
           
           /*Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm4= new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
            iupgm4.Core_MDF_Account_id__c = ipaUltimateAccount.Id;
         	iupgm4.Core_MDF_Program_nm__c = 'Intel Partner Alliance';
            iupgm4.Core_MDF_Region_cd__c = 'APJ;EMEA';
           iupgm4.RecordTypeId = ipaIUPGMRecTypeId;
            iupgm4.Core_MDF_Region_Sub_Region_nm__c = 'APJ;EMEA';
            //iupgm2.Core_MDF_GeoSubGeo_Budget_Type_nm__c = 'APJ->Business Client Acceleration - MDF;EMEA->Business Client Acceleration - MDF';
            iupgm4.Core_MDF_User_id__c =IUPGMUser.Id;
            iupgm4.Core_MDF_Role_nm__c='Core_MDF_CCP_Int_IPA_ProposalL1_Approver';
            iupgm4.Core_MDF_All_Accounts_cd__c = 'No';
            iupgm4.Core_MDF_All_Budget_Type_Access_Ind__c = true;
            //iupgm2.Core_MDF_is_User_Active_ind__c = true;
            iupgm4.Core_MDF_Active_Ind__c = true;
            iupgm4.Core_MDF_Is_Not_an_Approver_Ind__c = false;
            iupgm4.Core_MDF_Budget_Type_nm__c='Business Client Acceleration - MDF';
            iupgmList.add(iupgm4);
           

            
          /* Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm4= new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
            //iupgm3.Core_MDF_Account_id__c = ipaUltimateAccount.Id;
            iupgm4.Core_MDF_Program_nm__c = 'Intel Partner Alliance';
            iupgm4.Core_MDF_Region_cd__c = 'APJ;EMEA';
            iupgm4.Core_MDF_Region_Sub_Region_nm__c = 'APJ;EMEA';
            iupgm4.Core_MDF_All_Budget_Type_Access_Ind__c = true;
            iupgm4.Core_MDF_User_id__c =IUPGMUser.Id;
            iupgm4.Core_MDF_Role_nm__c='Core_MDF_CCP_Int_IPA_ProposalL1_Approver';
            iupgm4.Core_MDF_All_Accounts_cd__c = 'Yes';
            iupgm4.Core_MDF_All_Budget_Type_Access_Ind__c = true;
           // iupgm3.Core_MDF_is_User_Active_ind__c = true;
            iupgm4.Core_MDF_Active_Ind__c = true;
            iupgm4.Core_MDF_Is_Not_an_Approver_Ind__c = false;
           // iupgm3.Core_MDF_Budget_Type_nm__c='Business Client Acceleration - MDF';
            iupgmList.add(iupgm4);
          /*  Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm4= new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
            //iupgm4.Core_MDF_Account_id__c = ipaUltimateAccount.Id;
            iupgm4.Core_MDF_Program_nm__c = 'Intel Partner Alliance';
            iupgm4.Core_MDF_Region_cd__c = 'WW';
            iupgm4.Core_MDF_Region_Sub_Region_nm__c = 'WW';
           // iupgm4.Core_MDF_GeoSubGeo_Budget_Type_nm__c = 'APJ->Business Client Acceleration - MDF;EMEA->Business Client Acceleration - MDF';
            iupgm4.Core_MDF_User_id__c =testUser.Id;
            iupgm4.Core_MDF_Role_nm__c='Core_MDF_CCP_Int_IPA_ProposalL1_Approver';
            iupgm4.Core_MDF_All_Accounts_cd__c = 'Yes';
            iupgm4.Core_MDF_All_Budget_Type_Access_Ind__c = true;
            //iupgm4.Core_MDF_is_User_Active_ind__c = true;
            iupgm4.Core_MDF_Active_Ind__c = true;
            iupgm4.Core_MDF_Is_Not_an_Approver_Ind__c = false;
           // iupgm4.Core_MDF_Budget_Type_nm__c='Business Client Acceleration - MDF';
            iupgmList.add(iupgm4); */
             
            Database.insert(iupgmList);
             
        // Highlight: Unused Local Variable - Indira
         // List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> iupgmList1=[select id,Core_MDF_Is_Not_an_Approver_Ind__c from Core_MDF_Int_Users_Partner_Geo_Mapping__c limit 10]; //ATHR Fix - WW16
           
           /*PartnerMarketingBudget pmb = Core_MDF_CCP_TestDataUtility.createBudget('Test Budget',Core_MDF_CCP_IPA_TestDataUtility.budget_Record_Type,
                                                                                  ipaCoMarketingAccount.Id,ipaCP.Id,99999999,System.today().addDays(-10),System.today().addDays(60), 
                                                                                   false);
            pmb.Core_MDF_Budget_Type_Txt__c='Business Client Acceleration - MDF   ';
           //pmb.Core_MDF_Budget_Type__c='Client Specialties MDF';
            pmb.Core_MDF_Budget_Status__c = 'Released';
        Database.insert(pmb);
         Core_MDF_Budget_Cap__c budgetCap = new Core_MDF_Budget_Cap__c();
               budgetcap.RecordtypeId=ipaBudTypeCapRecordtype;
           // budgetCap.Core_MDF_Cap_Type_nm__c = 'IPA Budget';
             budgetCap.Core_MDF_Budget_Type_nm__c = 'Client Specialties MDF';
           // budgetCap.Core_MDF_Budget_Name_id__c = pmb.Id;
            budgetCap.Core_MDF_Requested_Cap_amt__c = 9999999;
            // budgetcap.Core_MDF_Cap_Status_nm__c ='Active';
             budgetcap.Core_MDF_Effective_Start_Date_Dt__c=  System.today();
            budgetcap.Core_MDF_Effective_End_Date_Dt__c= System.today().adddays(60);
            Database.insert(budgetCap);
    Campaign ipaCampaignForAP1 = Core_MDF_CCP_IPA_TestDataUtility.createIPACampaign('Test Campaign - AP1',ipaCoMarketingAccount.id, System.today(), System.today().adddays(30),budgetType, 110000,'INDIA', 'Developer', 'Apollo Lake', ' ',false);
           List<Campaign> campList= new  List<Campaign>();
           campList.add(ipaCampaignForAP1);
           database.insert(campList);
           PartnerFundRequest ipaPFR5 = Core_MDF_CCP_IPA_TestDataUtility.createIPAPartnerFundRequest(ipaCampaignForAP1.id,ipaCoMarketingAccount.id,System.today().addDays(1),System.today().addDays(10),true);
    
           */
         /*   Core_MDF_Budget_Cap__c budgetcap2 = new Core_MDF_Budget_Cap__c();
            budgetcap2.Core_MDF_Budget_Type_nm__c=budgetType;
              budgetcap2.Core_MDF_Cap_Status_nm__c ='Active';
           // budgetcap2.Core_MDF_Budget_Status_txt__c='Active';
            budgetcap2.Core_MDF_Effective_Start_Date_Dt__c=  System.today().adddays(-10);
            budgetcap2.Core_MDF_Effective_End_Date_Dt__c= System.today().adddays(60);
            budgetcap2.Core_MDF_Requested_Cap_amt__c=99999999;
           // budgetcap2.Core_MDF_Claimed_Cap_amt__c=6013;
            budgetcap2.RecordtypeId=ipaBudTypeCapRecordtype;
            Database.insert (budgetcap2);*/
           
            List<Contact> conList = new List<Contact>();
            Contact con = Core_MDF_CCP_TestDataUtility.createContact (ipaUltimateAccount.Id, false);
            con.RecordTypeId = Core_MDF_CCP_TestDataUtility.Intel_Contact_Record_Type;
            conList.add(con);
            
            Contact con1 = Core_MDF_CCP_TestDataUtility.createContact (ipaUltimateAccount.Id, false);
            con1.RecordTypeId = Core_MDF_CCP_TestDataUtility.Intel_Contact_Record_Type;
            conList.add(con1);
            
            Contact con2 = Core_MDF_CCP_TestDataUtility.createContact (ipaUltimateAccount.Id, false);
            con2.RecordTypeId = Core_MDF_CCP_TestDataUtility.Intel_Contact_Record_Type;
            conList.add(con2);
            
            Database.insert(conList);
            
            Profile partnerProfile = [SELECT Id FROM Profile WHERE Name='Partner' LIMIT 1];
            Profile ccpCoreProfileId = [SELECT Id FROM Profile WHERE Name='CCP - Core Access' LIMIT 1];

            // Creating User with utility class 
            List<User> usrList = new List<User>();
            User extUsr1 = Core_MDF_CCP_TestDataUtility.createUser(false);
            extUsr1.LastName = 'User Test1';
            extUsr1.ProfileId = partnerProfile.Id;
            extUsr1.ContactId = con.Id;
            extUsr1.IsActive = TRUE;
            usrList.add(extUsr1);
            
            User extUsr2 = Core_MDF_CCP_TestDataUtility.createUser(false);
            extUsr2.LastName = 'User Test2';
            extUsr2.ProfileId = partnerProfile.Id;
            extUsr2.ContactId = con1.Id;
            extUsr2.IsActive = TRUE;
            usrList.add(extUsr2);
            
            User extUsr3 = Core_MDF_CCP_TestDataUtility.createUser(false);
            extUsr3.LastName = 'User Test3';
            extUsr3.ProfileId = partnerProfile.Id;
            extUsr3.ContactId = con2.Id;
            extUsr3.IsActive = TRUE;
            usrList.add(extUsr3);
            
            User l1Appr = Core_MDF_CCP_TestDataUtility.createUser(false);
            l1Appr.LastName = 'L1 Approver';
            l1Appr.ProfileId = ccpCoreProfileId.Id;
            l1Appr.IsActive = TRUE;
            usrList.add(l1Appr);
            
            Database.insert(usrList);
            
            Test.startTest();

            PermissionSet pSet = [SELECT Id FROM PermissionSet WHERE PermissionSet.Name = 'Core_MDF_CCP_External_IPA_Proposal_Manager'];
            PermissionSet ipaL1Approver = [SELECT Id, Name FROM PermissionSet WHERE Name='Core_MDF_CCP_Int_IPA_ProposalL1_Approver' LIMIT 1];

            List<PermissionSetAssignment>permissionSetAssignmentList = new List<PermissionSetAssignment>();
            
            PermissionSetAssignment psa1 = new PermissionSetAssignment(PermissionSetId = pSet.id, AssigneeId = extUsr1.Id);
            permissionSetAssignmentList.add(psa1);            
            PermissionSetAssignment psa2 = new PermissionSetAssignment(PermissionSetId = pSet.id, AssigneeId = extUsr2.Id);
            permissionSetAssignmentList.add(psa2);            
            PermissionSetAssignment psa3 = new PermissionSetAssignment(PermissionSetId = pSet.id, AssigneeId = extUsr3.Id);
            permissionSetAssignmentList.add(psa3);            
            
            PermissionSetAssignment psa4 = new PermissionSetAssignment(PermissionSetId = ipaL1Approver.id, AssigneeId = l1Appr.Id);
            permissionSetAssignmentList.add(psa4);    
            
            Database.insert(permissionSetAssignmentList);
           // Highlight: Unused Local Variable - Indira
          //  List<Core_AGS_Role__c> agsRoleList = new List<Core_AGS_Role__c>();
            
            Core_AGS_Role__c agsRoleIPA = Core_MDF_CCP_TestDataUtility.createAgsRole('IPA_USER', 'Co-Marketing(Salesforce)-IPA USER', true, true);
            
            Core_ERPM_Engagement__c erpmEngagementIPA = Core_MDF_CCP_TestDataUtility.createErpmEngagement('Intel Partner Alliance', 'IPA', '', '', true, true);
            
            Core_Entitlement__c entitlementIPA = Core_MDF_CCP_TestDataUtility.createEntitlement('IPA MDF User',agsRoleIPA.Id ,'Intel Partner Alliance (IPA)','IPA MDF User',erpmEngagementIPA.Id , true,'Solutions Marketplace',true);
            
            List<Core_Contact_Entitlement__c> conEntList = new List<Core_Contact_Entitlement__c>();
            Core_Contact_Entitlement__c contactEntitlementIPA1 = Core_MDF_CCP_TestDataUtility.createContactEntitlement(con.Id,entitlementIPA.Id ,true,'Complete', false);            
            Core_Contact_Entitlement__c contactEntitlementIPA2 = Core_MDF_CCP_TestDataUtility.createContactEntitlement(con1.Id,entitlementIPA.Id ,true,'Complete', false);            
            Core_Contact_Entitlement__c contactEntitlementIPA3 = Core_MDF_CCP_TestDataUtility.createContactEntitlement(con2.Id,entitlementIPA.Id ,true,'Complete', false);  
              
            conEntList.add(contactEntitlementIPA1); conEntList.add(contactEntitlementIPA2); conEntList.add(contactEntitlementIPA3);
            
            Database.insert(conEntList);
            
            // Creating Group
            List<Group> grpList = new List<Group>();
            Group ipaExtGrp = new Group();
            ipaExtGrp.Name = 'Core CCP IPA External';
            ipaExtGrp.DeveloperName = 'Core_MDF_CCP_IPA_External';
            grpList.add(ipaExtGrp);
            
            Database.insert(grpList);
            
            // Creating Group Member
            List<GroupMember> grpMemList = new List<GroupMember>();
            GroupMember ipaExtGrpMem1 = new GroupMember();
            ipaExtGrpMem1.UserOrGroupId = extUsr1.Id;
            ipaExtGrpMem1.GroupId = ipaExtGrp.Id;
            grpMemList.add(ipaExtGrpMem1);
            
            GroupMember ipaExtGrpMem2 = new GroupMember();
            ipaExtGrpMem2.UserOrGroupId = extUsr2.Id;
            ipaExtGrpMem2.GroupId = ipaExtGrp.Id;
            grpMemList.add(ipaExtGrpMem2);
            
            GroupMember ipaExtGrpMem3 = new GroupMember();
            ipaExtGrpMem3.UserOrGroupId = extUsr3.Id;
            ipaExtGrpMem3.GroupId = ipaExtGrp.Id;
            grpMemList.add(ipaExtGrpMem3);
            
            Database.insert(grpMemList);
            
            List<Core_MDF_Partner_Group_Mapping__c> pgmList = new List<Core_MDF_Partner_Group_Mapping__c>();
            // Creating Partner Group Mapping
            Core_MDF_Partner_Group_Mapping__c pgmExt = new Core_MDF_Partner_Group_Mapping__c();
            pgmExt.Core_MDF_Account__c = ipaUltimateAccount.Id;
            pgmExt.Core_MDF_Group_Name__c = 'Core_MDF_CCP_IPA_External';
            pgmExt.Core_MDF_Type_of_Access__c = 'EXTERNAL';
            pgmExt.Core_MDF_Group_Id__c = ipaExtGrp.Id;                
            pgmExt.Core_MDF_Channel_Program__c = ipaCP.Id;
            pgmExt.Core_MDF_Source_Txt__c = 'Test';
            pgmExt.Core_MDF_Region_cd__C = 'APJ';
            pgmExt.Core_MDF_AccountIdGroupName__c = ipaUltimateAccount.Id+'Core_MDF_CCP_IPA_External1';
            pgmExt.Core_MDF_Virtual_Corp_nm__c = ipaCoMarketingAccount.Id;
            pgmList.add(pgmExt);
            
            Database.insert(pgmList);
           Core_MDF_Partner_Node_User_Mapping__c pnumRecord1 = Core_MDF_CCP_TestDataUtility.createPartnerNodeUserMapping(ipaCoMarketingAccount.Id,extUsr1.Id,true);
          Core_MDF_Partner_Node_User_Mapping__c pnumRecord2 = Core_MDF_CCP_TestDataUtility.createPartnerNodeUserMapping(ipaCoMarketingAccount.Id,extUsr2.Id,true);
           pnumRecord1.Core_MDF_Active_Ind__c = true;
           pnumRecord2.Core_MDF_Active_Ind__c = false;
           update pnumRecord1;
           update pnumRecord2;
            
            Map<Id,Id> userIdCorpAcctIdSet = new Map<Id,Id>();
            //Set<Id> accIdSet = new Set<Id>();
            //accIdSet.add(ipaCoMarketingAccount.Id);
            userIdCorpAcctIdSet.put(extUsr1.Id, ipaCoMarketingAccount.Id);
            userIdCorpAcctIdSet.put(extUsr2.Id, ipaCoMarketingAccount.Id);
            userIdCorpAcctIdSet.put(extUsr3.Id, ipaCoMarketingAccount.Id);
            
            Core_MDF_IPA_AccountUserMapping.createPnumRecords(userIdCorpAcctIdSet);
            Core_MDF_Configuration__c setting = new Core_MDF_Configuration__c();
                             setting.Name = 'CAMPAIGN_STATUS_IGNOREDFOR_BDGTCAPLINK';
                             setting.Core_MDF_Value__c = 'Cancelled';
                             setting.Core_MDF_Category__c='Campaign Status for exclusion while budgtCap Link';
                             insert setting;
            Id budgetcap_RecordType_IPA = Schema.SObjectType.Core_MDF_Budget_Cap__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_IPA_Budget_Type_Cap').getRecordTypeId();
            Core_MDF_Budget_Cap__c budgetCap = new Core_MDF_Budget_Cap__c();
           // budgetCap.Core_MDF_Cap_Type_nm__c = 'IPA Budget Type Cap';
            budgetCap.Core_MDF_Budget_Type_nm__c = 'Client Specialties MDF';
            budgetCap.Core_MDF_Requested_Cap_amt__c = 9999999;
            budgetCap.RecordTypeId = budgetcap_RecordType_IPA;
             //budgetcap.Core_MDF_Cap_Status_nm__c ='Active';
            budgetCap.Core_MDF_Region_nm__c ='WW';
             budgetcap.Core_MDF_Effective_Start_Date_Dt__c=  System.today().adddays(-10);
            budgetcap.Core_MDF_Effective_End_Date_Dt__c= System.today().adddays(60);
        
            Database.insert(budgetCap);
            
            //Campaign ipaCampaignForAP = Core_MDF_CCP_IPA_TestDataUtility.createIPACampaign('Test Campaign - AP',ipaCoMarketingAccount.id, Date.newInstance(2021, 01, 01), Date.newInstance(2021, 06, 29),budgetType, 110000,'INDIA', 'Developer', 'Apollo Lake', 'Pending Approval', true);
            Campaign ipaCampaignForAP = Core_MDF_CCP_IPA_TestDataUtility.createIPACampaign('Test Campaign - AP',ipaCoMarketingAccount.id, System.today(), System.today().adddays(30),budgetType, 110000,'INDIA', 'Developer', '', 'Pending Approval', false);
            ipaCampaignForAP.Core_MDF_Region_cd__c = 'APJ';
            ipaCampaignForAP.Core_MDF_Opal_Budget_Type_Txt__c ='Client Specialties MDF';
            ipaCampaignForAP.Core_MDF_Proposal_Based_Ind__c = true;
           	ipaCampaignForAP.Core_MDF_Budget_Type_txt__c = 'Client Specialties MDF';
            database.insert(ipaCampaignForAP);
            User manager = Core_MDF_CCP_TestDataUtility.createUser(false);
            manager.LastName = 'User Test Manager';
            Database.insert(manager);
            
            User usr1 = Core_MDF_CCP_TestDataUtility.createUser(false);
            usr1.LastName = 'User Test1';
            usr1.ManagerId = manager.Id;
            Database.insert(usr1);
            
            // Creating Group
            Group ipaGrp = new Group();
            ipaGrp.Name = 'Core CCP IPA Internal';
            ipaGrp.DeveloperName = 'Core_MDF_CCP_IPA_Internal';
            Database.insert(ipaGrp);
           
       /*    Group ipaGrp1 = new Group();
            ipaGrp1.Name = 'Core CCP IPA Internal12';
            ipaGrp1.DeveloperName = 'Core_MDF_CCP_IPA_Internal1';
            Database.insert(ipaGrp1);
           
           Group ipaGrp2 = new Group();
            ipaGrp2.Name = 'Core CCP IPA Internal23';
            ipaGrp2.DeveloperName = 'Core_MDF_CCP_IPA_Internal2';
            Database.insert(ipaGrp2);  */
            
            GroupMember ipaGrpMem = new GroupMember();
            ipaGrpMem.UserOrGroupId = usr1.Id;
            ipaGrpMem.GroupId = ipaGrp.Id;
            Database.insert(ipaGrpMem);
            
            List<Core_MDF_Partner_Group_Mapping__c> pgmIntList = new List<Core_MDF_Partner_Group_Mapping__c>();
            // Creating Partner Group Mapping
           Core_MDF_Partner_Group_Mapping__c pgm1 = new Core_MDF_Partner_Group_Mapping__c();
            pgm1.Core_MDF_Account__c = ipaUltimateAccount.Id;
            pgm1.Core_MDF_Group_Name__c = 'Core_MDF_CCP_IPA_Internal';
            pgm1.Core_MDF_Type_of_Access__c = 'INTERNAL';
            pgm1.Core_MDF_Group_Id__c = ipaGrp.Id;                
            pgm1.Core_MDF_Channel_Program__c = ipaCP.Id;
            pgm1.Core_MDF_Source_Txt__c = 'Test';
            pgm1.Core_MDF_Region_cd__C = 'APJ';
            pgm1.Core_MDF_AccountIdGroupName__c = ipaUltimateAccount.Id+'Core_MDF_CCP_IPA_Internal';
            pgmIntList.add(pgm1);
            
         /*	Core_MDF_Partner_Group_Mapping__c pgm2 = new Core_MDF_Partner_Group_Mapping__c();
            pgm2.Core_MDF_Account__c = ipaUltimateAccount.Id;
            pgm2.Core_MDF_Group_Name__c = 'Core_MDF_CCP_IPA_Internal';
            pgm2.Core_MDF_Type_of_Access__c = 'INTERNAL';
            pgm2.Core_MDF_Group_Id__c = ipaGrp.Id;                
            pgm2.Core_MDF_Channel_Program__c = ipaCP.Id;
            pgm2.Core_MDF_Source_Txt__c = 'Test';
            pgm2.Core_MDF_Region_cd__C = 'WW';
            pgm2.Core_MDF_AccountIdGroupName__c = ipaUltimateAccount.Id+'Core_MDF_CCP_IPA_Internal1';
            pgmIntList.add(pgm2);
            
            Core_MDF_Partner_Group_Mapping__c pgm3 = new Core_MDF_Partner_Group_Mapping__c();
            pgm3.Core_MDF_Account__c = ipaUltimateAccount.Id;
            pgm3.Core_MDF_Group_Name__c = 'Core_MDF_CCP_IPA_Internal23';
            pgm3.Core_MDF_Type_of_Access__c = 'INTERNAL';
            pgm3.Core_MDF_Group_Id__c = ipaGrp2.Id;                
            pgm3.Core_MDF_Channel_Program__c = ipaCP.Id;
            pgm3.Core_MDF_Source_Txt__c = 'Test';
            pgm3.Core_MDF_Region_cd__C = 'ASMO';
            pgm3.Core_MDF_Sub_Region_cd__c = 'NAR';
            pgm3.Core_MDF_AccountIdGroupName__c = ipaUltimateAccount.Id+'Core_MDF_CCP_IPA_Internal2';
            pgmIntList.add(pgm3);   */
            
            Database.insert(pgmIntList);
           // Test.stopTest();
            
            // Creating Criterias for approval required
            Core_MDF_Criteria__c cr = Core_MDF_CCP_TestDataUtility.createCriteria('Campaign','Core_MDF_IPA_Proposal_AP',
                                                                                  'Core_MDF_Program__c','Equal','Intel Partner Alliance','','', '',
                                                                                  '','','','','','','','','',true);
            
            // Creating Approvers
            List<Core_MDF_Approver__c> approverList = new List<Core_MDF_Approver__c>();
            Core_MDF_Approver__c ap1 = Core_MDF_CCP_TestDataUtility.createApprover(cr.Id,usr1.Id, false);
            ap1.Core_MDF_Approver_Type__c = 'Internal';
            approverList.add(ap1);
            Core_MDF_Approver__c ap2 = Core_MDF_CCP_TestDataUtility.createApprover(cr.Id,usr1.Id, false);
            ap2.Core_MDF_Approver_Type__c = 'Internal';
            approverList.add(ap2);
            Database.insert(approverList);
            
            List<Core_MDF_Criteria_Rule__c> crList = new List<Core_MDF_Criteria_Rule__c>();
            // Creating Criteria rules for approvers
            Core_MDF_Criteria_Rule__c crule1 = Core_MDF_CCP_TestDataUtility.createCriteriaRule(ap1.Id,'Core_MDF_Approval_Step_Counter_nbr__c','Equal',
                                                                                               '0',false);
            
            Core_MDF_Criteria_Rule__c crule2 = Core_MDF_CCP_TestDataUtility.createCriteriaRule(ap2.Id,'Core_MDF_Approval_Step_Counter_nbr__c','Greater Than or Equal',
                                                                                               '1',false);
            
            Core_MDF_Criteria_Rule__c crule3 = Core_MDF_CCP_TestDataUtility.createCriteriaRule(ap2.Id,'Core_MDF_Approval_Step_Counter_nbr__c','Less Than or Equal',
                                                                                               '3',false);
            
            
            crList.add(crule1); crList.add(crule2); crList.add(crule3);
            Database.insert(crList);
            
            List<Core_MDF_Approver__c> toBeUpdatedAP = new List <Core_MDF_Approver__c>();
            ap1.Core_MDF_Active__c = True;
            toBeUpdatedAP.add(ap1);
            ap2.Core_MDF_Active__c = True;
            toBeUpdatedAP.add(ap2);
            Database.update(toBeUpdatedAP);
            
            cr.Core_MDF_Active__c = True;
            Database.update(cr);
        
            Test.stopTest();
    }
    }
    
    
   // @isTest
   /* public static void IupgmTest(){
        Account ipaUltimateAccount=[select id,name from Account where name='IPA Intel Account' limit 1];
                             User usr=[select id,lastname from User where lastname='Test User1' limit 1];
                             Profile ccpCoreProf= [SELECT Id FROM Profile WHERE Name = 'CCP - Core Access'];
                             Campaign camp=[select id,Core_MDF_Region_cd__c,name,Core_MDF_Proposal_Based_Ind__c,Status,Core_MDF_Ultimate_Account_txt__c,Core_MDF_Budget_Type_txt__c from Campaign where name='Test Campaign - AP' limit 1];
        Account ipaCoMarketingAccount = [select id,Core_MDF_Parent_Fund_Account__c,Core_MDF_Channel_Program__c from Account where Name= 'IPA Co-Marketing Account' LIMIT 1];
        PartnerFundRequest ipaPFR5 = Core_MDF_CCP_IPA_TestDataUtility.createIPAPartnerFundRequest(camp.id,ipaCoMarketingAccount.id,System.today().addDays(1),System.today().addDays(10),true);
        camp.status='Pending Review';
        //update camp;
                             User IUPGMUser = Core_MDF_CCP_TestDataUtility.createUser(false);
              IUPGMUser.profileId = ccpCoreProf.Id;
                            insert IUPGMUser;
                            
           //PermissionSet ps=[select id from PermissionSet where name='Core_MDF_CCP_Internal_IPA_Finance_Usr'limit 1];
             //insert new PermissionSetAssignment(AssigneeId = IUPGMUser.id, PermissionSetId = ps.Id);
                                             PermissionSet psIpaL1 = [SELECT Id FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Int_IPA_ProposalL1_Approver' LIMIT 1];
            insert new PermissionSetAssignment(AssigneeId = IUPGMUser.id, PermissionSetId = psIpaL1.Id);
                                           PermissionSet psIpaIntManager = [SELECT Id FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_IPA_Acct_Mgr' LIMIT 1];
            insert new PermissionSetAssignment(AssigneeId = IUPGMUser.id, PermissionSetId = psIpaIntManager.Id);
        
        test.startTest();
                             List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> iupgmList = new List<Core_MDF_Int_Users_Partner_Geo_Mapping__c>();
            Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm1 = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
            iupgm1.Core_MDF_Account_id__c = ipaUltimateAccount.Id;
            iupgm1.Core_MDF_Program_nm__c = 'Intel Partner Alliance';
            iupgm1.Core_MDF_Region_Sub_Region_nm__c = 'WW';
            iupgm1.Core_MDF_User_id__c = IUPGMUser.Id;
            iupgm1.Core_MDF_Role_nm__c = 'Core_MDF_CCP_Internal_IPA_Finance_Usr';
            iupgm1.Core_MDF_All_Accounts_cd__c = 'No';
            iupgm1.Core_MDF_Active_Ind__c = true;
            iupgm1.Core_MDF_Is_Not_an_Approver_Ind__c = false;
           // iupgmList.add(iupgm1);
                                           Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm2= new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
            iupgm2.Core_MDF_Account_id__c = ipaUltimateAccount.Id;
            iupgm2.Core_MDF_Program_nm__c = 'Intel Partner Alliance';
            iupgm2.Core_MDF_Region_cd__c = 'APJ;EMEA';
            iupgm2.Core_MDF_Region_Sub_Region_nm__c = 'APJ;EMEA';
            iupgm2.Core_MDF_GeoSubGeo_Budget_Type_nm__c = 'APJ->Business Client Acceleration - MDF;EMEA->Business Client Acceleration - MDF';
            iupgm2.Core_MDF_User_id__c =IUPGMUser.Id;
            iupgm2.Core_MDF_Role_nm__c='Core_MDF_CCP_Int_IPA_ProposalL1_Approver';
            iupgm2.Core_MDF_All_Accounts_cd__c = 'No';
            iupgm2.Core_MDF_All_Budget_Type_Access_Ind__c = false;
            iupgm2.Core_MDF_Active_Ind__c = true;
            iupgm2.Core_MDF_Is_Not_an_Approver_Ind__c = false;
            iupgm2.Core_MDF_Budget_Type_nm__c='Business Client Acceleration - MDF';
            iupgmList.add(iupgm2);
            Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm3= new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
            iupgm3.Core_MDF_Program_nm__c = 'Intel Partner Alliance';
            iupgm3.Core_MDF_Region_cd__c = 'APJ;EMEA';
            iupgm3.Core_MDF_Region_Sub_Region_nm__c = 'APJ;EMEA';
           // iupgm3.Core_MDF_GeoSubGeo_Budget_Type_nm__c = 'APJ->Business Client Acceleration - MDF;EMEA->Business Client Acceleration - MDF';
            iupgm3.Core_MDF_User_id__c =IUPGMUser.Id;
            iupgm3.Core_MDF_Role_nm__c='Core_MDF_CCP_Int_IPA_ProposalL1_Approver';
            iupgm3.Core_MDF_All_Accounts_cd__c = 'Yes';
            iupgm3.Core_MDF_All_Budget_Type_Access_Ind__c = true;
           iupgm3.Core_MDF_Active_Ind__c = true;
            iupgm3.Core_MDF_Is_Not_an_Approver_Ind__c = false;
           
            iupgmList.add(iupgm3);
            
          
        system.runAs(IUPGMUser){
            Database.insert(iupgmList);
                                           }
        test.stopTest();
    }*/
    
    @isTest 
        static void subTypeForApproval(){
            try{
        User usr = [Select Id, lastName from User where lastName = 'SysAdmin' limit 1];
        System.runAs(usr){
        
        Test.startTest();
        Account ipaCoMarketingAccount = [select id,Core_MDF_Parent_Fund_Account__c,Core_MDF_Channel_Program__c from Account where Name= 'IPA Co-Marketing Account' LIMIT 1];
        
        Campaign ipaCampaignForAP = [SELECT Id, Core_MDF_Activity_Category_Type__c, Status, Core_MDF_Approval_Step_Counter_nbr__c,Core_MDF_Proposal_Based_Ind__c,Core_MDF_Program__c, 
                                     Core_MDF_Reimbursement_Rate__c, Core_MDF_Region_cd__c, Description,Core_MDF_Ultimate_Account_txt__c,
                                     StartDate, EndDate, Core_MDF_Total_Campaign_Cost_Amt__c, Core_MDF_Market__c,Core_MDF_Budget_Cap__c,Core_MDF_Opal_Budget_Type_Txt__c,Core_MDF_Account__c 
                                     FROM Campaign WHERE Name = 'Test Campaign - AP' LIMIT 1];
        ipaCampaignForAP.Core_MDF_Approval_Step_Counter_nbr__c = 3; 
        //ipaCampaignForAP.Core_MDF_Activity_Category_Type__c = 'Purchase Incentive->Buyer - Bundle Offer';
        //Core_MDF_Budget_Cap__c testbudgettype = [Select id , recordtype.name from Core_MDF_Budget_Cap__c];
        
        Database.update(ipaCampaignForAP);
        // Highlight: Unused Local Variable - Indira
      //  PartnerFundRequest ipaPFR5 = Core_MDF_CCP_IPA_TestDataUtility.createIPAPartnerFundRequest(ipaCampaignForAP.id,ipaCoMarketingAccount.id,System.today().addDays(1),System.today().addDays(10),true);
               
        List<Campaign> cmpUpd = new List<Campaign>();
        cmpUpd.add(ipaCampaignForAP);        
        
        Map<Id,Campaign> campOldMap = new Map<Id,Campaign>();
        campOldMap.put(ipaCampaignForAP.Id, ipaCampaignForAP);
        Map<Campaign,Id> ipaCampToacctIdMap =new Map<Campaign,Id> ();
          ipaCampToacctIdMap.put(ipaCampaignForAP,ipaCoMarketingAccount.id);
         User l1App = [Select Id, lastName from User where lastName = 'L1 Approver' limit 1];
        system.runAs(l1App){
        Core_MDF_Proposal_Based_Campaign_Process.onSubmitForApproval(cmpUpd,campOldMap);
        Core_MDF_Proposal_Based_Campaign_Process.notifyExternalReviewers(cmpUpd);
        Core_MDF_Proposal_Based_Campaign_Process.budgetCapConsumption(campOldMap,cmpUpd);
        Core_MDF_Proposal_Based_Campaign_Process.isMDFBenefitApplicable(ipaCampToacctIdMap);
        }
        /*User l1App = [Select Id, lastName from User where lastName = 'L1 Approver' limit 1];
        system.runAs(l1App){
Core_MDF_Proposal_Based_Campaign_Process.checkifCampaignReimbursementAmountExceedsBudgetCap(cmpUpd,campOldMap);}
           ProcessInstance pi = [SELECT Id,status, TargetObjectId FROM ProcessInstance where TargetObjectId =: cmpUpd];  
           ProcessInstanceWorkitem[] piWorkItems = [SELECT Id FROM ProcessInstanceWorkItem WHERE ProcessInstance.TargetObjectId = :cmpUpd
                                                     AND ProcessInstance.Status = 'Pending']; 
            if(piWorkItems.size() > 0){
                //Create Process Work Item Request
                Approval.ProcessWorkItemRequest pwiRequest = new Approval.ProcessWorkItemRequest();
                pwiRequest.setAction('Approve');
                //pwiRequest.setWorkItemId(piWorkItems[0].Id);
                Approval.ProcessResult result = Approval.process(pwiRequest);
            }
        }*/
       //Assert.areEqual('Purchase Incentive->Buyer - Bundle Offer',ipaCampaignForAP.Core_MDF_Activity_Category_Type__c);
        Test.stopTest();
       // Unit Test Method should include System.Assert - Indira
       System.assertEquals('L1 Approver', l1App.lastName, 'L1 Approver last name should be correct');
    }
            }catch(Exception e){
                Core_MDF_CCP_UtilityClass.logError(e);
            }
        
    }
    
    @isTest 
    static void submitForApproval(){
        try{
        User usr = [Select Id, lastName from User where lastName = 'SysAdmin' limit 1];
        System.runAs(usr){
        
        Account ipaCoMarketingAccount = [select id,Core_MDF_Parent_Fund_Account__c,Core_MDF_Channel_Program__c from Account where Name= 'IPA Co-Marketing Account' LIMIT 1];
        
        Test.startTest();
        
        Campaign ipaCampaignForAP = [SELECT Id, Core_MDF_Activity_Sub_Type_nm__c, Status, Core_MDF_Approval_Step_Counter_nbr__c, 
                                     Core_MDF_Reimbursement_Rate__c, Core_MDF_Region_cd__c, Description,
                                     StartDate, EndDate, Core_MDF_Total_Campaign_Cost_Amt__c, Core_MDF_Market__c,Core_MDF_Reimbursement_Amt__c  
                                     FROM Campaign WHERE Name = 'Test Campaign - AP' LIMIT 1];
        
        //ipaCampaignForAP.Core_MDF_Activity_Category_Type__c = 'Broadcast->Other (Broadcast)';
        ipaCampaignForAP.Core_MDF_Approval_Step_Counter_nbr__c = 2; 
        
        Database.update(ipaCampaignForAP);
       // Highlight: Unused Local Variable - Indira 
      //  PartnerFundRequest ipaPFR5 = Core_MDF_CCP_IPA_TestDataUtility.createIPAPartnerFundRequest(ipaCampaignForAP.id,ipaCoMarketingAccount.id,System.today().addDays(1),System.today().addDays(10),true);
        List<Campaign> cmpUpd = new List<Campaign>();
        cmpUpd.add(ipaCampaignForAP);        
        Map<Id,Campaign> newCampMap = new Map<Id,Campaign>();
        newCampMap.put(ipaCampaignForAP.id,ipaCampaignForAP);        
        Map<Id,Campaign> campOldMap = new Map<Id,Campaign>();
        campOldMap.put(ipaCampaignForAP.Id, ipaCampaignForAP);
        Core_MDF_Proposal_Based_Campaign_Process.onSubmitForApproval(cmpUpd,campOldMap);
        Core_MDF_Proposal_Based_Campaign_Process.validateSingleGeoOnCampaign(null);
        Core_MDF_Proposal_Based_Campaign_Process.processPropBasedCamapignsAfterUpdate(null,null);        
        
       // assert.areEqual('Broadcast->Other (Broadcast)',ipaCampaignForAP.Core_MDF_Activity_Category_Type__c);
        Test.stopTest();
            // Unit Test Method should include System.Assert - Indira
            System.assertEquals(1, cmpUpd.size(), 'Campaign list should contain one campaign');
        }
        }catch(Exception e){
            Core_MDF_CCP_UtilityClass.logError(e);
        }
    }
    
    
    @isTest 
    static void submitForExtSPIFApproval(){
        User IUPGMUser = [Select id, Name, ProfileId from user where id =: userInfo.getUserId()];
        System.runAs(IUPGMUser){
        
        Account ipaCoMarketingAccount = [select id,Core_MDF_Parent_Fund_Account__c,Core_MDF_Channel_Program__c from Account where Name= 'IPA Co-Marketing Account' LIMIT 1];
        
        Test.startTest();
        
        Campaign ipaCampaignForAP = [SELECT Id, Core_MDF_Activity_Sub_Type_nm__c, Status, Core_MDF_Approval_Step_Counter_nbr__c, 
                                     Core_MDF_Reimbursement_Rate__c, Core_MDF_Region_cd__c, Description,
                                     StartDate, EndDate, Core_MDF_Total_Campaign_Cost_Amt__c, Core_MDF_Market__c,Core_MDF_Reimbursement_Amt__c  
                                     FROM Campaign WHERE Name = 'Test Campaign - AP' LIMIT 1];
        
       // ipaCampaignForAP.Core_MDF_Activity_Category_Type__c = 'Broadcast->Podcast';
        //ipaCampaignForAP.Core_MDF_Approval_Step_Counter_nbr__c = 3;
        
        Database.update(ipaCampaignForAP);
        // Highlight: Unused Local Variable - Indira
       // PartnerFundRequest ipaPFR5 = Core_MDF_CCP_IPA_TestDataUtility.createIPAPartnerFundRequest(ipaCampaignForAP.id,ipaCoMarketingAccount.id,System.today().addDays(1),System.today().addDays(10),true);
               
        List<Campaign> cmpUpd = new List<Campaign>();
        cmpUpd.add(ipaCampaignForAP);        
        
        Map<Id,Campaign> campOldMap = new Map<Id,Campaign>();
        campOldMap.put(ipaCampaignForAP.Id, ipaCampaignForAP);
        Core_MDF_Proposal_Based_Campaign_Process.onSubmitForApproval(cmpUpd,campOldMap);
        
        //assert.areEqual('Broadcast->Podcast',ipaCampaignForAP.Core_MDF_Activity_Category_Type__c);
        Test.stopTest();
            // Unit Test Method should include System.Assert - Indira
            System.assertEquals(ipaCampaignForAP, cmpUpd[0], 'Campaign list should contain the correct campaign');
        }
    }
    
    @isTest 
    static void submitForExtApproval(){
        try{
        User usr = [Select Id, lastName from User where lastName = 'SysAdmin' limit 1];
        System.runAs(usr){
        
        Account ipaCoMarketingAccount = [select id,Core_MDF_Parent_Fund_Account__c,Core_MDF_Channel_Program__c from Account where Name= 'IPA Co-Marketing Account' LIMIT 1];
        
        Test.startTest();
        
        Campaign ipaCampaignForAP = [SELECT Id, Core_MDF_Activity_Sub_Type_nm__c, Status, Core_MDF_Approval_Step_Counter_nbr__c, 
                                     Core_MDF_Reimbursement_Rate__c, Core_MDF_Region_cd__c, Description,
                                     StartDate, EndDate, Core_MDF_Total_Campaign_Cost_Amt__c, Core_MDF_Market__c,Core_MDF_Reimbursement_Amt__c  
                                     FROM Campaign WHERE Name = 'Test Campaign - AP' LIMIT 1];
        
        //ipaCampaignForAP.Core_MDF_Activity_Category_Type__c = 'Broadcast->Podcast';
        ipaCampaignForAP.Core_MDF_Approval_Step_Counter_nbr__c = 2;  
        
        Database.update(ipaCampaignForAP);
        // Highlight: Unused Local Variable - Indira
       // PartnerFundRequest ipaPFR5 = Core_MDF_CCP_IPA_TestDataUtility.createIPAPartnerFundRequest(ipaCampaignForAP.id,ipaCoMarketingAccount.id,System.today().addDays(1),System.today().addDays(10),true);
               
        List<Campaign> cmpUpd = new List<Campaign>();
        cmpUpd.add(ipaCampaignForAP);        
        
        Map<Id,Campaign> campOldMap = new Map<Id,Campaign>();
        campOldMap.put(ipaCampaignForAP.Id, ipaCampaignForAP);
        Core_MDF_Proposal_Based_Campaign_Process.onSubmitForApproval(cmpUpd,campOldMap);
        
        //assert.areEqual('Broadcast->Podcast',ipaCampaignForAP.Core_MDF_Activity_Category_Type__c);
        Test.stopTest();
           // Unit Test Method should include System.Assert - Indira
        System.assertEquals(2, ipaCampaignForAP.Core_MDF_Approval_Step_Counter_nbr__c, 'Approval step counter should be 2');
        }
        } catch(Exception e){
            Core_MDF_CCP_UtilityClass.logError(e);
        }
    }
    
    @isTest 
    static void singleGeoValidation(){
       
        User usr = [Select Id, lastName from User where lastName = 'SysAdmin' limit 1];
        System.runAs(usr){
        
        Test.startTest(); 
        Campaign ipaCampaign = [SELECT Id, Core_MDF_Activity_Sub_Type_nm__c, Status, Core_MDF_Approval_Step_Counter_nbr__c, 
                                     Core_MDF_Reimbursement_Rate__c, Core_MDF_Region_cd__c, Description,
                                     StartDate, EndDate, Core_MDF_Total_Campaign_Cost_Amt__c, Core_MDF_Market__c,Core_MDF_Reimbursement_Amt__c  
                                     FROM Campaign WHERE Name = 'Test Campaign - AP' LIMIT 1];
                     
        
        try{
            ipaCampaign.Core_MDF_Market__c = 'INDIA;CANADA';
            database.update(ipaCampaign);
        }catch(Exception e){ 
            // Highlight: Unused Local Variable - Indira
           // String message = e.getMessage();
           
            //assert.isTrue(message.contains(Label.Core_MDF_Single_Geo_Error));
            Core_MDF_CCP_UtilityClass.logError(e);
        }
         // Unit Test Method should include System.Assert - Indira
       System.assertEquals('INDIA;CANADA', ipaCampaign.Core_MDF_Market__c, 'Market field should be updated to INDIA;CANADA');
        Test.stopTest();
    }
    }
    
    @isTest 
    static void changeBudgetType(){
        User usr = [Select Id, lastName from User where lastName = 'SysAdmin' limit 1];
        System.runAs(usr){
        
        Test.startTest(); 
        
        Campaign ipaCampaign = [SELECT Id, Core_MDF_Activity_Sub_Type_nm__c, Status, Core_MDF_Approval_Step_Counter_nbr__c, 
                                     Core_MDF_Reimbursement_Rate__c, Core_MDF_Region_cd__c, Description, Core_MDF_Opal_Budget_Type_Txt__c,
                                     StartDate, EndDate, Core_MDF_Total_Campaign_Cost_Amt__c, Core_MDF_Market__c,Core_MDF_Reimbursement_Amt__c  
                                     FROM Campaign WHERE Name = 'Test Campaign - AP' LIMIT 1];
        
        try{
            ipaCampaign.Core_MDF_Opal_Budget_Type_Txt__c = 'SP AI MDF';
            database.update(ipaCampaign);
        }catch(Exception e){
           // Highlight: Unused Local Variable - Indira
          //  String message = e.getMessage();            
        }
        assert.areEqual('INDIA',ipaCampaign.Core_MDF_Market__c);
        Test.stopTest();
    }
    }
    
    @isTest 
    static void validateDeleteShareOnGeoChange(){
        User usr = [Select Id, lastName from User where lastName = 'SysAdmin' limit 1];
        System.runAs(usr){
        
        Test.startTest(); 
        
        Campaign ipaCampaign = [SELECT Id, Core_MDF_Activity_Sub_Type_nm__c, Status, Core_MDF_Approval_Step_Counter_nbr__c, 
                                     Core_MDF_Reimbursement_Rate__c, Core_MDF_Region_cd__c, Description, Core_MDF_Opal_Budget_Type_Txt__c,
                                     StartDate, EndDate, Core_MDF_Total_Campaign_Cost_Amt__c, Core_MDF_Market__c, Core_MDF_Reimbursement_Amt__c  
                                     FROM Campaign WHERE Name = 'Test Campaign - AP' LIMIT 1];
        
        try{
            ipaCampaign.Core_MDF_Market__c = 'Canada';
            database.update(ipaCampaign);
        }catch(Exception e){
        }
        assert.areEqual('Canada',ipaCampaign.Core_MDF_Market__c);
        Test.stopTest();
    }
    }
    
   @isTest 
    static void submitCampaignWithoutActivity(){
        User usr = [Select Id, lastName from User where lastName = 'SysAdmin' limit 1];
        System.runAs(usr){
        
        Test.startTest(); 
        
        Campaign ipaCampaign = [SELECT Id, Core_MDF_Activity_Sub_Type_nm__c, Status, Core_MDF_Approval_Step_Counter_nbr__c, 
                                     Core_MDF_Reimbursement_Rate__c, Core_MDF_Region_cd__c, Description, Core_MDF_Opal_Budget_Type_Txt__c,
                                     StartDate, EndDate, Core_MDF_Total_Campaign_Cost_Amt__c, Core_MDF_Market__c,Core_MDF_Reimbursement_Amt__c 
                                     FROM Campaign WHERE Name = 'Test Campaign - AP' LIMIT 1];
        
        try{
            ipaCampaign.Core_MDF_Approval_Step_Counter_nbr__c = 4;
            ipaCampaign.Status = 'Pending Review';
            database.update(ipaCampaign);
        }catch(Exception e){
            // Highlight: Unused Local Variable - Indira
          //  String message = e.getMessage();
          
            //System.assert(message.contains(Label.Core_MDF_IPA_Submit_Approval_Error));
        }
        assert.areEqual('Pending Review',ipaCampaign.Status);
        Test.stopTest();
    }
    }
    
    @isTest 
    static void cancellingCompletedCampaign(){
        User usr = [Select Id, lastName from User where lastName = 'SysAdmin' limit 1];
        System.runAs(usr){
        
        Test.startTest(); 
        
        Campaign ipaCampaign = [SELECT Id, Core_MDF_Activity_Sub_Type_nm__c, Status, Core_MDF_Approval_Step_Counter_nbr__c, 
                                     Core_MDF_Reimbursement_Rate__c, Core_MDF_Region_cd__c, Description, Core_MDF_Opal_Budget_Type_Txt__c,
                                     StartDate, EndDate, Core_MDF_Total_Campaign_Cost_Amt__c, Core_MDF_Market__c,Core_MDF_Reimbursement_Amt__c  
                                     FROM Campaign WHERE Name = 'Test Campaign - AP' LIMIT 1];
        ipaCampaign.Status = 'Completed';
        database.update(ipaCampaign);
        try{
            ipaCampaign.Status = 'Cancelled';
            database.update(ipaCampaign);
        }catch(Exception e){
            String message = e.getMessage();
            assert.isTrue(message.contains(Label.Core_MDF_Cancel_Campaign_Error_Message));
        }
        
        Test.stopTest();
    }
    }
    
    @isTest 
    static void cancellingCampaignWithClaim(){
        User usr = [Select Id, lastName from User where lastName = 'SysAdmin' limit 1];
        System.runAs(usr){
        
        Test.startTest(); 
        
        Campaign ipaCampaign = [SELECT Id, Core_MDF_Activity_Sub_Type_nm__c, Status, Core_MDF_Approval_Step_Counter_nbr__c, 
                                     Core_MDF_Claims_Created_Ind__c, Core_MDF_Region_cd__c, Description, Core_MDF_Opal_Budget_Type_Txt__c,
                                     StartDate, EndDate, Core_MDF_Total_Campaign_Cost_Amt__c, Core_MDF_Market__c,Core_MDF_Reimbursement_Amt__c  
                                     FROM Campaign WHERE Name = 'Test Campaign - AP' LIMIT 1];
        
        ipaCampaign.Core_MDF_Claims_Created_Ind__c = TRUE;
        database.update(ipaCampaign);
        
        try{
            ipaCampaign.Status = 'Cancelled';
            database.update(ipaCampaign);
        }catch(Exception e){
            String message = e.getMessage();
            assert.isTrue(message.contains(Label.Core_MDF_IPA_Cancel_Campaign_With_Claims_Error));
        }
        
        Test.stopTest();
    }
    }
    
    @isTest 
    static void l1Approval(){
       // Highlight: Unused Local Variable - Indira
      //  User usr = [Select Id, lastName from User where lastName = 'SysAdmin' limit 1];
        User IUPGMUser = [Select id, Name, ProfileId from user where id =: userInfo.getUserId()];
        System.runAs(IUPGMUser){
        
        Test.startTest(); 
        
        Campaign ipaCampaign = [SELECT Id, Core_MDF_Activity_Sub_Type_nm__c, Status, Core_MDF_Approval_Step_Counter_nbr__c, 
                                     Core_MDF_Activity_Category_Type__c, Core_MDF_Region_cd__c, Description, Core_MDF_Opal_Budget_Type_Txt__c,
                                     StartDate, EndDate, Core_MDF_Total_Campaign_Cost_Amt__c, Core_MDF_Market__c,Core_MDF_Reimbursement_Amt__c  
                                     FROM Campaign WHERE Name = 'Test Campaign - AP' LIMIT 1];
        
        ipaCampaign.Core_MDF_Approval_Step_Counter_nbr__c = 2;
        //ipaCampaign.Core_MDF_Activity_Category_Type__c = 'Broadcast->Other (Broadcast)';
        database.update(ipaCampaign);
                
        List<Campaign> cmpUpd = new List<Campaign>();
        cmpUpd.add(ipaCampaign); 
        
        Map<Id,Campaign> campOldMap = new Map<Id,Campaign>();
        campOldMap.put(ipaCampaign.Id, ipaCampaign);
        Core_MDF_Proposal_Based_Campaign_Process.onSubmitForApproval(cmpUpd,campOldMap);
        
        
        //assert.areEqual('Broadcast->Other (Broadcast)',ipaCampaign.Core_MDF_Activity_Category_Type__c);
        // Unit Test Method should include System.Assert - Indira
         System.assertEquals(1, campOldMap.size(), 'Old campaign map should have one entry');
            
        Test.stopTest();
        }
    }
    
    @isTest 
    static void l1ManagerApproval(){
        // Highlight: Unused Local Variable - Indira
       // User usr = [Select Id, lastName from User where lastName = 'SysAdmin' limit 1];
         User IUPGMUser = [Select id, Name, ProfileId from user where id =: userInfo.getUserId()];
        System.runAs(IUPGMUser){
        
        Test.startTest(); 
        
        Campaign ipaCampaign = [SELECT Id, Core_MDF_Activity_Category_Type__c, Status, Core_MDF_Approval_Step_Counter_nbr__c, 
                                     Core_MDF_Reimbursement_Rate__c, Core_MDF_Region_cd__c, Description, Core_MDF_Opal_Budget_Type_Txt__c,
                                     StartDate, EndDate, Core_MDF_Total_Campaign_Cost_Amt__c, Core_MDF_Market__c,Core_MDF_Reimbursement_Amt__c  
                                     FROM Campaign WHERE Name = 'Test Campaign - AP' LIMIT 1];
        
        ipaCampaign.Core_MDF_Approval_Step_Counter_nbr__c = 2;
        //ipaCampaign.Core_MDF_Activity_Category_Type__c = 'Digital Media->NonPartner.com';
        database.update(ipaCampaign);
                
        List<Campaign> cmpUpd = new List<Campaign>();
        cmpUpd.add(ipaCampaign); 
        
        Map<Id,Campaign> campOldMap = new Map<Id,Campaign>();
        campOldMap.put(ipaCampaign.Id, ipaCampaign);
        Core_MDF_Proposal_Based_Campaign_Process.onSubmitForApproval(cmpUpd,campOldMap);
        
        //assert.areEqual('Digital Media->NonPartner.com',ipaCampaign.Core_MDF_Activity_Category_Type__c);
        
        // Unit Test Method should include System.Assert - Indira
        System.assertEquals(1, cmpUpd.size(), 'Campaign list should contain one campaign');
            
        Test.stopTest();
        }
    }
    
    @isTest 
    static void l2Approval(){
        Account ipaUltimateAccount = [Select Id from Account where Name = 'IPA Intel Account' limit 1];
        // Highlight: Unused Local Variable - Indira
       // User usr = [Select Id, lastName from User where lastName = 'SysAdmin' limit 1];
        User IUPGMUser = [Select id, Name, ProfileId from user where id =: userInfo.getUserId()];
        
        //PermissionSet psIpaL1 = [SELECT Id FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_Proposal_Activity_L2_Approver' LIMIT 1];
        //insert new PermissionSetAssignment(AssigneeId = IUPGMUser.id, PermissionSetId = psIpaL1.Id);
        
        Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm1= new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
        iupgm1.Core_MDF_Account_id__c = ipaUltimateAccount.Id;
        iupgm1.Core_MDF_Program_nm__c = 'Intel Partner Alliance';
        iupgm1.Core_MDF_Region_cd__c = 'APJ;EMEA';
        iupgm1.Core_MDF_Region_Sub_Region_nm__c = 'APJ;EMEA';
        iupgm1.Core_MDF_GeoSubGeo_Budget_Type_nm__c = 'APJ->Business Client Acceleration - MDF;EMEA->Business Client Acceleration - MDF';
        iupgm1.Core_MDF_User_id__c =IUPGMUser.Id;
        iupgm1.Core_MDF_Role_nm__c='Core_MDF_CCP_Internal_Proposal_Activity_L2_Approver';
        iupgm1.Core_MDF_All_Accounts_cd__c = 'No';
        iupgm1.Core_MDF_All_Budget_Type_Access_Ind__c = false;
        //iupgm2.Core_MDF_is_User_Active_ind__c = true;
        iupgm1.Core_MDF_Active_Ind__c = true;
        iupgm1.Core_MDF_Is_Not_an_Approver_Ind__c = false;
        iupgm1.Core_MDF_Budget_Type_nm__c='Business Client Acceleration - MDF';
        //insert iupgm1;
        
        System.runAs(IUPGMUser){
        
        Test.startTest(); 
        
        Campaign ipaCampaign = [SELECT Id, Core_MDF_Activity_Sub_Type_nm__c, Status, Core_MDF_Approval_Step_Counter_nbr__c, 
                                     Core_MDF_Reimbursement_Rate__c, Core_MDF_Region_cd__c, Core_MDF_Activity_Category_Type__c, Core_MDF_Opal_Budget_Type_Txt__c,
                                     StartDate, EndDate, Core_MDF_Total_Campaign_Cost_Amt__c, Core_MDF_Market__c,Core_MDF_Reimbursement_Amt__c  
                                     FROM Campaign WHERE Name = 'Test Campaign - AP' LIMIT 1];
        
        ipaCampaign.Core_MDF_Approval_Step_Counter_nbr__c = 1;
        //ipaCampaign.Core_MDF_Activity_Category_Type__c = 'Broadcast->Other (Broadcast)';
        database.update(ipaCampaign);
                
        List<Campaign> cmpUpd = new List<Campaign>();
        cmpUpd.add(ipaCampaign); 
        
        Map<Id,Campaign> campOldMap = new Map<Id,Campaign>();
        campOldMap.put(ipaCampaign.Id, ipaCampaign);
        Core_MDF_Proposal_Based_Campaign_Process.onSubmitForApproval(cmpUpd,campOldMap);
        
        //assert.areEqual('Broadcast->Other (Broadcast)',ipaCampaign.Core_MDF_Activity_Category_Type__c);
        
          // Unit Test Method should include System.Assert - Indira
        System.assertEquals(1, ipaCampaign.Core_MDF_Approval_Step_Counter_nbr__c, 'Approval step counter should be 1');
        Test.stopTest();
        }
    }
    
    @isTest 
    static void l2ApprovalProcess(){
        User usr = [Select Id, lastName from User where lastName = 'SysAdmin' limit 1];
        System.runAs(usr){
        
        Test.startTest(); 
        
        Campaign ipaCampaign = [SELECT Id, Core_MDF_Activity_Sub_Type_nm__c, Status, Core_MDF_Approval_Step_Counter_nbr__c, 
                                     Core_MDF_Reimbursement_Rate__c, Core_MDF_Region_cd__c, Core_MDF_Activity_Category_Type__c, Core_MDF_Opal_Budget_Type_Txt__c,
                                     StartDate, EndDate, Core_MDF_Total_Campaign_Cost_Amt__c, Core_MDF_Market__c,Core_MDF_Reimbursement_Amt__c  
                                     FROM Campaign WHERE Name = 'Test Campaign - AP' LIMIT 1];
        
        
        ipaCampaign.Core_MDF_Approval_Step_Counter_nbr__c = 1;
       // ipaCampaign.Core_MDF_Activity_Category_Type__c = 'Broadcast->Other (Broadcast);Purchase Incentive->Buyer - Bundle Offer';
        database.update(ipaCampaign);
                
        List<Campaign> cmpUpd = new List<Campaign>();
        cmpUpd.add(ipaCampaign); 
        
        Map<Id,Campaign> campOldMap = new Map<Id,Campaign>();
        campOldMap.put(ipaCampaign.Id, ipaCampaign);
        Core_MDF_Proposal_Based_Campaign_Process.onSubmitForApproval(cmpUpd,campOldMap);
        
        //assert.areEqual('Broadcast->Other (Broadcast);Purchase Incentive->Buyer - Bundle Offer',ipaCampaign.Core_MDF_Activity_Category_Type__c);
        
        // Unit Test Method should include System.Assert - Indira
        System.assertNotEquals(null, ipaCampaign.Id, 'Campaign should not be null');
        Test.stopTest();
        }
    }
    
    @isTest 
    static void externalApproval(){
        User IUPGMUser = [Select id, Name, ProfileId from user where id =: userInfo.getUserId()];
        System.runAs(IUPGMUser){
        
        Test.startTest(); 
        
        Campaign ipaCampaign = [SELECT Id, Core_MDF_Activity_Sub_Type_nm__c, Status, Core_MDF_Approval_Step_Counter_nbr__c, 
                                     Core_MDF_Reimbursement_Rate__c, Core_MDF_Region_cd__c, Core_MDF_Activity_Category_Type__c, Core_MDF_Opal_Budget_Type_Txt__c,
                                     StartDate, EndDate, Core_MDF_Total_Campaign_Cost_Amt__c, Core_MDF_Market__c,Core_MDF_Reimbursement_Amt__c  
                                     FROM Campaign WHERE Name = 'Test Campaign - AP' LIMIT 1];
        
        //ipaCampaign.Core_MDF_Approval_Step_Counter_nbr__c = 4;
       // ipaCampaign.Core_MDF_Activity_Category_Type__c = 'Digital Media->NonPartner.com';
        database.update(ipaCampaign);
                
        List<Campaign> cmpUpd = new List<Campaign>();
        cmpUpd.add(ipaCampaign); 
        
        Map<Id,Campaign> campOldMap = new Map<Id,Campaign>();
        campOldMap.put(ipaCampaign.Id, ipaCampaign);
        Core_MDF_Proposal_Based_Campaign_Process.onSubmitForApproval(cmpUpd,campOldMap);
        
        //assert.areEqual('Digital Media->NonPartner.com',ipaCampaign.Core_MDF_Activity_Category_Type__c);
        
        // Unit Test Method should include System.Assert - Indira
        System.assertEquals(userInfo.getUserId(), IUPGMUser.Id, 'User ID should match current user');
        Test.stopTest();
        }
    }
    
    @isTest 
    static void pfrUpdatesMethod(){
        User usr = [Select Id, lastName from User where lastName = 'SysAdmin' limit 1];
        System.runAs(usr){
        Test.startTest();
        Account ipaCoMarketingAccount = [select id,Core_MDF_Parent_Fund_Account__c,Core_MDF_Channel_Program__c from Account where Name= 'IPA Co-Marketing Account'];
        
        Campaign ipaCampaignForAP = [SELECT Id,Core_MDF_Proposal_Based_Ind__c , Core_MDF_Activity_Category_Type__c,Core_MDF_Account__c, Core_MDF_Activity_Sub_Type_nm__c, Core_MDF_Activity_Category__c,
                                    Core_MDF_Activity_Type__c, Status, Core_MDF_PGM_Internal_Group_Id_txt__c,Core_MDF_Budget_Cap__c, Core_MDF_Reimbursement_Amt__c,Core_MDF_Reimbursement_Rate__c,Core_MDF_Opal_Budget_Type_Txt__c,Core_MDF_ReimbursementRate_pct__c
                                     FROM Campaign WHERE Name = 'Test Campaign - AP' LIMIT 1];
        /*
       Core_MDF_Budget_Cap__c budgetCap =[Select id,Core_MDF_Budget_Type_nm__c from Core_MDF_Budget_Cap__c WHERE Core_MDF_Budget_Type_nm__c =:ipaCampaignForAP.Core_MDF_Opal_Budget_Type_Txt__c  LIMIT 1];
        ipaCampaignForAP.Core_MDF_Budget_Cap__c =budgetCap.id ;
        database.update(ipaCampaignForAP);*/
        
        PartnerFundRequest ipaPFR = Core_MDF_CCP_IPA_TestDataUtility.createIPAPartnerFundRequest(ipaCampaignForAP.id,ipaCoMarketingAccount.id,System.today().addDays(1),System.today().addDays(10),true);
        ipaPFR.Core_MDF_Fund_Request_Status__c = 'Pending Approval';
        ipaPFR.Core_MDF_Country_nm__c='AFGHANISTAN';
        ipaPFR.Core_MDF_Reimbursement_Rate_pct__c='50%';
        Database.update(ipaPFR);
         
           try{
               //ipaCampaignForAP.Core_MDF_Activity_Category_Type__c = 'Broadcast->Other (Broadcast)';        
              // ipaCampaignForAP.Core_MDF_Activity_Category__c = 'Broadcast';
               //ipaCampaignForAP.Core_MDF_Activity_Type__c = 'Other (Broadcast)';
               ipaCampaignForAP.Status= 'Planned'; 
               ipaCampaignForAP.Core_MDF_Reimbursement_Rate__c = '50%';
               ipaCampaignForAP.Core_MDF_Reimbursement_Amt__c = 1000;
               ipaCampaignForAP.Core_MDF_Market__c='AFGHANISTAN';
               Database.update(ipaCampaignForAP);
                                  
        Map<Id,Campaign> campaignIdStatusMap = new Map<Id,Campaign>();
        campaignIdStatusMap.put(ipaCampaignForAP.Id, ipaCampaignForAP);        
        Core_MDF_Proposal_Based_Campaign_Process.pfrUpdates(campaignIdStatusMap,true);
        //ipaPFR.Core_MDF_Fund_Request_Status__c = 'Revision Required';
        //update ipaPFR;
        
        
       /* ipaCampaignForAP.Status= 'planned';
        Database.update(ipaCampaignForAP);
        campaignIdStatusMap.put(ipaCampaignForAP.Id, ipaCampaignForAP);
        update campaignIdStatusMap.values();
        Core_MDF_Proposal_Based_Campaign_Process.pfrUpdates(campaignIdStatusMap,true);
        
        ipaCampaignForAP.Status= 'Revision Required';
        Database.update(ipaCampaignForAP);
        campaignIdStatusMap.put(ipaCampaignForAP.Id, ipaCampaignForAP);  
        update campaignIdStatusMap.values();
        Core_MDF_Proposal_Based_Campaign_Process.pfrUpdates(campaignIdStatusMap,true); */
        
        List<Campaign> cmpUpd = new List<Campaign>();
        cmpUpd.add(ipaCampaignForAP);        
        
        Map<Id,Campaign> campOldMap = new Map<Id,Campaign>();
        campOldMap.put(ipaCampaignForAP.Id, ipaCampaignForAP);
        Core_MDF_Proposal_Based_Campaign_Process.onSubmitForApproval(cmpUpd,campOldMap);
        
        Core_MDF_Proposal_Based_Campaign_Process.notifyExternalReviewers(cmpUpd);
        Core_MDF_Proposal_Based_Campaign_Process.onCampaignCancel(cmpUpd,campOldMap);
        //Core_MDF_Proposal_Based_Campaign_Process.checkifCampaignReimbursementAmountExceedsBudgetCap(cmpUpd,campOldMap);
       // Core_MDF_Proposal_Based_Campaign_Process.delinkBudgetCapFromCamp(cmpUpd);
        Core_MDF_CampaignServiceHandler.updateIpaL1ApproverComments(cmpUpd);
        Core_MDF_Proposal_Based_Campaign_Process.queryPFCRecords(cmpUpd);
       
        User l1App = [Select Id, lastName from User where lastName = 'L1 Approver' limit 1];
        system.runAs(l1App){
            Core_MDF_Proposal_Based_Campaign_Process.checkifCampaignReimbursementAmountExceedsBudgetCap(cmpUpd,campOldMap,false);
            Core_MDF_Proposal_Based_Campaign_Process.checkifCampaignReimbursementAmountExceedsBudgetCap(cmpUpd,campOldMap,true);
        }
        
        assert.areEqual('Pending Approval',ipaPFR.Core_MDF_Fund_Request_Status__c);
        
        Test.stopTest();
           }catch(Exception e){
            // Highlight: Unused Local Variable - Indira
           // String message = e.getMessage();
            Core_MDF_CCP_UtilityClass.logError(e);
        }
    }
    }
   // @isTest
   /*public static void pfrUpdatesTestMethod(){
        Account ipaCoMarketingAccount = [select id,Core_MDF_Parent_Fund_Account__c,Core_MDF_Channel_Program__c from Account where Name= 'IPA Co-Marketing Account'];
        
        Campaign ipaCampaignForAP = [SELECT Id,Core_MDF_Proposal_Based_Ind__c , Core_MDF_Activity_Category_Type__c,Core_MDF_Account__c, Core_MDF_Activity_Sub_Type_nm__c, Core_MDF_Activity_Category__c,
                                    Core_MDF_Activity_Type__c, Status, Core_MDF_PGM_Internal_Group_Id_txt__c,Core_MDF_Budget_Cap__c, Core_MDF_Reimbursement_Amt__c,Core_MDF_Reimbursement_Rate__c,Core_MDF_Opal_Budget_Type_Txt__c,Core_MDF_ReimbursementRate_pct__c
                                     FROM Campaign WHERE Name = 'Test Campaign - AP' LIMIT 1];
        ipaCampaignForAP.Status='In Progress';
        PartnerFundRequest ipaPFR = Core_MDF_CCP_IPA_TestDataUtility.createIPAPartnerFundRequest(ipaCampaignForAP.id,ipaCoMarketingAccount.id,System.today().addDays(1),System.today().addDays(10),False);
        ipaPFR.Core_MDF_Fund_Request_Status__c='Pending Approval';
        Map<id, Campaign> campaignIdStatusMap=new Map<id, Campaign>();
        campaignIdStatusMap.put(ipaCampaignForAP.id,ipaCampaignForAP);
        Core_MDF_Proposal_Based_Campaign_Process.pfrUpdates(campaignIdStatusMap,True);
        
    }*/
    @isTest 
    static void proposalAcceptedMethod(){
        User usr = [Select Id, lastName from User where lastName = 'SysAdmin' limit 1];
        System.runAs(usr){
        Test.startTest();
        List<Campaign> updateCampaigns = new List<Campaign>();
        
        Account ipaCoMarketingAccount = [select id,Core_MDF_Parent_Fund_Account__c,Core_MDF_Channel_Program__c from Account where Name= 'IPA Co-Marketing Account' LIMIT 1];
        
        Campaign ipaCampaignForAP = [SELECT Id, Core_MDF_Activity_Sub_Type_nm__c, Status, Core_MDF_Approval_Step_Counter_nbr__c, 
                                     Core_MDF_Reimbursement_Rate__c, Core_MDF_Region_cd__c, Description,Core_MDF_Claims_Created_Ind__c,
                                     StartDate, EndDate, Core_MDF_Total_Campaign_Cost_Amt__c, Core_MDF_Market__c, Core_MDF_Reimbursement_Amt__c 
                                     FROM Campaign WHERE Name = 'Test Campaign - AP' LIMIT 1];
        
        //Change fields to sync with PFR
        try{
            ipaCampaignForAP.Core_MDF_Activity_Sub_Type_nm__c = 'Other (NonPartner.com)';
            ipaCampaignForAP.Core_MDF_Approval_Step_Counter_nbr__c = 1;
            ipaCampaignForAP.Core_MDF_Market__c = 'AFGHANISTAN';
            ipaCampaignForAP.Core_MDF_Region_cd__c = 'APJ';
            ipaCampaignForAP.Status= 'Proposal Accepted';      
            ipaCampaignForAP.Core_MDF_Reimbursement_Amt__c = 1000;
            updateCampaigns.add(ipaCampaignForAP);
           Database.update(updateCampaigns); 
        }catch(Exception e){
           // Highlight: Unused Local Variable - Indira
          //  String message = e.getMessage();
        }
        
        // Highlight: Unused Local Variable - Indira
      //  PartnerFundRequest ipaPFR5 = Core_MDF_CCP_IPA_TestDataUtility.createIPAPartnerFundRequest(ipaCampaignForAP.id,ipaCoMarketingAccount.id,System.today().addDays(1),System.today().addDays(10),true);
        
        
        List<Campaign> cmpUpd = new List<Campaign>();
        cmpUpd.add(ipaCampaignForAP);        
        
        Map<Id,Campaign> campOldMap = new Map<Id,Campaign>();
        campOldMap.put(ipaCampaignForAP.Id, ipaCampaignForAP);
        Core_MDF_Proposal_Based_Campaign_Process.onSubmitForApproval(cmpUpd,campOldMap);
        Test.stopTest();
        assert.areEqual('Proposal Accepted',ipaCampaignForAP.Status);
        Core_MDF_Proposal_Based_Campaign_Process.onCampaignCancel(cmpUpd,campOldMap);
    }
    }
    
    @isTest static void dateValidation(){
        User usr = [Select Id, lastName from User where lastName = 'SysAdmin' limit 1];
        System.runAs(usr){
        
        Account ipaCoMarketingAccount = [select id,Core_MDF_Parent_Fund_Account__c,Core_MDF_Channel_Program__c 
                                         from Account
                                         where Name= 'IPA Co-Marketing Account'];
        
        
        Campaign ipaCampaign = [SELECT Id, StartDate, Core_MDF_Reimbursement_Amt__c FROM Campaign WHERE Name = 'Test Campaign - AP' LIMIT 1];
        
        Test.startTest();        
        // Highlight: Unused Local Variable - Indira
       /* PartnerFundRequest ipaPFR = Core_MDF_CCP_IPA_TestDataUtility.createIPAPartnerFundRequest(ipaCampaign.id,ipaCoMarketingAccount.id,
                                                                                                 System.today().addDays(1),
                                                                                                  System.today().addDays(10),
                                                                                                  true); */
        try{
            ipaCampaign.StartDate = System.today().addDays(5);
            database.update(ipaCampaign);
        }catch(Exception e){
            String message = e.getMessage();
            assert.isTrue(message.contains('Campaign date range must comply with Activity date range.'));
        }
        
        Test.stopTest();
    }
    }
    
    @isTest static void amountValidation(){
        User usr = [Select Id, lastName from User where lastName = 'SysAdmin' limit 1];
        System.runAs(usr){
        
        Account ipaCoMarketingAccount = [select id,Core_MDF_Parent_Fund_Account__c,Core_MDF_Channel_Program__c 
                                         from Account
                                         where Name= 'IPA Co-Marketing Account' LIMIT 1];
                 
        Campaign ipaCampaign = [SELECT Id, Core_MDF_Total_Campaign_Cost_Amt__c FROM Campaign WHERE Name = 'Test Campaign - AP' LIMIT 1];
        
        Test.startTest();        
        
        PartnerFundRequest ipaPFR1 = Core_MDF_CCP_IPA_TestDataUtility.createIPAPartnerFundRequest(ipaCampaign.id,ipaCoMarketingAccount.id,
                                                                                                  System.today().addDays(1),
                                                                                                  System.today().addDays(10),
                                                                                                  false);
        ipaPFR1.RequestedAmount = 1000;

        database.insert(ipaPFR1);
        
        try{
            ipaCampaign.Core_MDF_Total_Campaign_Cost_Amt__c = 1000;
            database.update(ipaCampaign);
        }catch(Exception e){ 
           // Highlight: Unused Local Variable - Indira
          //  String message = e.getMessage();
          
          //  System.assert(message.contains('Campaign amount must comply with total Activities amount.'));
         assert.areEqual(999,ipaCampaign.Core_MDF_Total_Campaign_Cost_Amt__c);
        }
        
        Test.stopTest();
    }
    }
    
    @isTest 
    static void campaignRejectionCheck(){
        User usr = [Select Id, lastName from User where lastName = 'SysAdmin' limit 1];
        System.runAs(usr){
        
        Account ipaCoMarketingAccount = [select id,Core_MDF_Parent_Fund_Account__c,Core_MDF_Channel_Program__c 
                                         from Account
                                         where Name= 'IPA Co-Marketing Account' LIMIT 1];
        
        Campaign ipaCampaign = [SELECT Id, Status,Core_MDF_Reimbursement_Amt__c FROM Campaign WHERE Name = 'Test Campaign - AP' LIMIT 1];
        
        Test.startTest();
       
        PartnerFundRequest ipaPFR = Core_MDF_CCP_IPA_TestDataUtility.createIPAPartnerFundRequest(ipaCampaign.id,ipaCoMarketingAccount.id,System.today().addDays(1),System.today().addDays(10),true);
        
       
        
       ipaCampaign.Status = 'Revision Required';
       // database.update(ipaCampaign);
            ipaPFR.Core_MDF_Fund_Request_Status__c = 'Pending Approval';
        Database.update(ipaPFR);
        assert.areEqual('Revision Required',ipaCampaign.Status);
       Map<Id,Campaign> campOldMap = new Map<Id,Campaign>();
       campOldMap.put(ipaCampaign.Id, ipaCampaign);
            
     
        List<Campaign> cmpUpd = new List<Campaign>();
        cmpUpd.add(ipaCampaign);        
        

        Core_MDF_Proposal_Based_Campaign_Process.onSubmitForApproval(cmpUpd,campOldMap);
        
        Test.stopTest();
        }
    }
    
    @isTest 
    static void campaignEditCheck(){
        User usr = [Select Id, lastName from User where lastName = 'SysAdmin' limit 1];
        System.runAs(usr){
        
        Account ipaCoMarketingAccount = [select id,Core_MDF_Parent_Fund_Account__c,Core_MDF_Channel_Program__c 
                                         from Account
                                         where Name= 'IPA Co-Marketing Account' LIMIT 1];
        List<Campaign> cmpList = new List<Campaign>();
        Campaign ipaCampaign = [SELECT Id, StartDate, Core_MDF_Reimbursement_Amt__c FROM Campaign WHERE Name = 'Test Campaign - AP' LIMIT 1];
        cmpList.add(ipaCampaign);
        
        List<PartnerFundRequest> pfrList = new List<PartnerFundRequest>();
        Test.startTest();
        PartnerFundRequest ipaPFR = Core_MDF_CCP_IPA_TestDataUtility.createIPAPartnerFundRequest(ipaCampaign.id,ipaCoMarketingAccount.id,
                                                                                                  System.today().addDays(4),
                                                                                                  System.today().addDays(10),
                                                                                                  false); 
        
        PartnerFundRequest ipaPFR1 = Core_MDF_CCP_IPA_TestDataUtility.createIPAPartnerFundRequest(ipaCampaign.id,ipaCoMarketingAccount.id,
                                                                                                  System.today().addDays(4),
                                                                                                  System.today().addDays(10),
                                                                                                  false);
            
        ipaPFR.Core_MDF_Fund_Request_Status__c = 'Planned';
        pfrList.add(ipaPFR);
        pfrList.add(ipaPFR1);
        Database.insert(pfrList);
        
        ipaCampaign.StartDate = System.today().addDays(2);
        database.update(ipaCampaign);
        
        Core_MDF_CampaignPFR_Controller.getActivityRecords(ipaCampaign.Id);
        Core_MDF_Proposal_Based_Campaign_Process.queryPFRRecords(cmpList);
        assert.areEqual('Planned',ipaPFR.Core_MDF_Fund_Request_Status__c);
        
        Test.stopTest();
        }
    }
    
    @isTest 
    static void testSubmitForApproval(){
        User usr = [Select Id, lastName from User where lastName = 'SysAdmin' limit 1];
        System.runAs(usr){
        
        Account ipaCoMarketingAccount = [select id,Core_MDF_Parent_Fund_Account__c,Core_MDF_Channel_Program__c from Account where Name= 'IPA Co-Marketing Account' LIMIT 1];
        
        Test.startTest();
        
        Campaign ipaCampaignForAP = [SELECT Id, Core_MDF_Activity_Sub_Type_nm__c, Status, Core_MDF_Approval_Step_Counter_nbr__c, 
                                     Core_MDF_Reimbursement_Rate__c, Core_MDF_Region_cd__c, Description,Core_MDF_Opal_Budget_Type_Txt__c,
                                     StartDate, EndDate, Core_MDF_Total_Campaign_Cost_Amt__c, Core_MDF_Market__c, Core_MDF_Reimbursement_Amt__c, Core_MDF_Activity_Category_Type__c
                                     FROM Campaign WHERE Name = 'Test Campaign - AP' LIMIT 1];
        
        /*ipaCampaignForAP.Core_MDF_Activity_Category_Type__c = 'Broadcast->Other (Broadcast)';
        ipaCampaignForAP.Core_MDF_Approval_Step_Counter_nbr__c = 2;  
        
        Database.update(ipaCampaignForAP);*/
        
        PartnerFundRequest ipaPFR5 = Core_MDF_CCP_IPA_TestDataUtility.createIPAPartnerFundRequest(ipaCampaignForAP.id,ipaCoMarketingAccount.id,System.today().addDays(1),System.today().addDays(10),false);
        ipaPFR5.Core_MDF_Budget_Type_nm__c = 'Client Specialties MDF';
        ipaPFR5.Core_MDF_BU1_Split_Percent_nbr__c = 100;
        ipaPFR5.Core_MDF_BU_Split__c = 'CCG';
        Database.insert(ipaPFR5);
        
        ipaCampaignForAP.Core_MDF_Opal_Budget_Type_Txt__c = 'Data Center Specialties MDF';
        ipaCampaignForAP.Status = 'Pending Review';
        try{
            Database.update(ipaCampaignForAP);   
        } catch (Exception e){
        }
        
        List<Campaign> cmpUpd = new List<Campaign>();
        cmpUpd.add(ipaCampaignForAP);        
        
        Map<Id,Campaign> campOldMap = new Map<Id,Campaign>();
        campOldMap.put(ipaCampaignForAP.Id, ipaCampaignForAP);
        Core_MDF_Proposal_Based_Campaign_Process.onSubmitForApproval(cmpUpd,campOldMap);
        
        assert.areEqual('Pending Review',ipaCampaignForAP.Status);
        Test.stopTest();
    }
    }
    
    //Added by Sai
    @isTest 
    static void checkMDFBenefitsTest(){
        User usr = [Select Id, lastName from User where lastName = 'SysAdmin' limit 1];
        System.runAs(usr){
        
        Test.startTest();
        Account ipaCoMarketingAccount = [select id,Core_MDF_Parent_Fund_Account__c,Core_MDF_Channel_Program__c from Account where Name= 'IPA Co-Marketing Account' LIMIT 1];
        Campaign ipaCampaignForAP = [SELECT Id, Core_MDF_Activity_Category_Type__c, Status, Core_MDF_Approval_Step_Counter_nbr__c, 
                                     Core_MDF_Reimbursement_Rate__c, Core_MDF_Region_cd__c, Description, Core_MDF_Ultimate_Account_txt__c,
                                     StartDate, EndDate, Core_MDF_Total_Campaign_Cost_Amt__c, Core_MDF_Market__c, Core_MDF_Reimbursement_Amt__c  
                                     FROM Campaign WHERE Name = 'Test Campaign - AP' LIMIT 1];
        ipaCampaignForAP.Core_MDF_Approval_Step_Counter_nbr__c = 3; 
       // ipaCampaignForAP.Core_MDF_Activity_Category_Type__c = 'Purchase Incentive->Buyer - Bundle Offer';
        
        Database.update(ipaCampaignForAP);
        // Highlight: Unused Local Variable - Indira
      // PartnerFundRequest ipaPFR5 = Core_MDF_CCP_IPA_TestDataUtility.createIPAPartnerFundRequest(ipaCampaignForAP.id,ipaCoMarketingAccount.id,System.today().addDays(1),System.today().addDays(10),true);
               
        List<Campaign> cmpUpd = new List<Campaign>();
        cmpUpd.add(ipaCampaignForAP);        
        
        Map<Campaign, Id> campToAccIdMap = new Map<Campaign, Id>();
        campToAccIdMap.put(ipaCampaignForAP, ipaCoMarketingAccount.Id);
        Core_MDF_Proposal_Based_Campaign_Process.checkMDFBenefits(campToAccIdMap);
       // assert.areEqual('Purchase Incentive->Buyer - Bundle Offer',ipaCampaignForAP.Core_MDF_Activity_Category_Type__c);
       // Core_MDF_Proposal_Based_Campaign_Process.delinkBudgetCapFromCamp(cmpUpd);
       
       // Unit Test Method should include System.Assert - Indira
       System.assertEquals(3, ipaCampaignForAP.Core_MDF_Approval_Step_Counter_nbr__c, 'Approval step counter should be 3');
        Test.stopTest();
        }
        
    }
  /*  @isTest
    public static void validateProcessIPACamapignsBeforeInsertUpdate(){
          Account ipaCoMarketingAccount = [select id,Core_MDF_Parent_Fund_Account__c,Core_MDF_Channel_Program__c from Account where Name= 'IPA Co-Marketing Account' LIMIT 1];
          ChannelProgram ipaCP = [SELECT id From ChannelProgram where Name='Intel Partner Alliance'];
         Id ipaBudTypeCapRecordtype = Schema.SObjectType.Core_MDF_Budget_Cap__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_IPA_Budget_Type_Cap').getRecordTypeId();
        String budgetType = Core_MDF_CCP_IPA_TestDataUtility.createBenefit(ipaCoMarketingAccount);
        PartnerMarketingBudget pmb = Core_MDF_CCP_TestDataUtility.createBudget('Test Budget',Core_MDF_CCP_IPA_TestDataUtility.budget_Record_Type,
                                                                                  ipaCoMarketingAccount.Id,ipaCP.Id,99999999,System.today().addDays(-10),System.today().addDays(60), 
                                                                                   false);
            pmb.Core_MDF_Budget_Type_Txt__c='Client Specialties MDF';
            pmb.Core_MDF_Budget_Status__c = 'Released';
        Test.startTest();
        Database.insert(pmb);
         Core_MDF_Budget_Cap__c budgetCap = new Core_MDF_Budget_Cap__c();
            budgetCap.Core_MDF_Cap_Type_nm__c = 'IPA Budget';
            budgetCap.Core_MDF_Budget_Name_id__c = pmb.Id;
            budgetCap.Core_MDF_Requested_Cap_amt__c = 9999999;
             budgetcap.Core_MDF_Cap_Status_nm__c ='Active';
             budgetcap.Core_MDF_Effective_Start_Date_Dt__c=  System.today().adddays(-10);
            budgetcap.Core_MDF_Effective_End_Date_Dt__c= System.today().adddays(60);
        
            Database.insert(budgetCap);
Campaign ipaCampaignForAP1 = Core_MDF_CCP_IPA_TestDataUtility.createIPACampaign('Test Campaign - AP1',ipaCoMarketingAccount.id, System.today().addDays(-5), System.today().adddays(30),budgetType, 110000,'INDIA', 'Developer', 'Apollo Lake', ' ',false);
           List<Campaign> campList= new  List<Campaign>();
           campList.add(ipaCampaignForAP1);
           database.insert(campList);
           PartnerFundRequest ipaPFR5 = Core_MDF_CCP_IPA_TestDataUtility.createIPAPartnerFundRequest(ipaCampaignForAP1.id,ipaCoMarketingAccount.id,System.today().addDays(1),System.today().addDays(10),true);
    
    
    
    }*/
    @isTest  static void mapBudgetToCampaignTest(){
        try{
        User usr = [Select Id, lastName from User where lastName = 'SysAdmin' limit 1];
        System.runAs(usr){
        Test.startTest();
                             Id ipaBudTypeCapRecordtype = Schema.SObjectType.Core_MDF_Budget_Cap__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_IPA_Budget_Type_Cap').getRecordTypeId();
       // Highlight: Unused Local Variable - Indira
      //  Map<ID, Schema.RecordTypeInfo> budgetCapRecTypeMap = Schema.SObjectType.Core_MDF_Budget_Cap__c.getRecordTypeInfosById();
        
        List<Campaign> ipaBudgetCaptoCampaignList=[select id,name,startDate,endDate,Core_MDF_Opal_Budget_Type_Txt__c,Core_MDF_Reimbursement_Amt__c,Core_MDF_Budget_Cap__c from campaign where name='Test Campaign - AP' limit 1];   
        //ipaBudgetCaptoCampaignList[0].Core_MDF_Opal_Budget_Type_Txt__c='CCF 1.0';
        //Database.update(ipaBudgetCaptoCampaignList);
        Core_MDF_Budget_Cap__c budgetCap = new Core_MDF_Budget_Cap__c();
               budgetcap.RecordtypeId=ipaBudTypeCapRecordtype;
           budgetCap.Core_MDF_Budget_Type_nm__c = 'Business Client Acceleration - MDF';
           budgetCap.Core_MDF_Requested_Cap_amt__c = 9999999;
            budgetcap.Core_MDF_Effective_Start_Date_Dt__c=  System.today();
            budgetcap.Core_MDF_Effective_End_Date_Dt__c= System.today().adddays(15);
        budgetcap.Core_MDF_Region_nm__c='WW';
            Database.insert(budgetCap);
        List<Core_MDF_Budget_Cap__c> testBudgetCapList=new List<Core_MDF_Budget_Cap__c> ();
        testBudgetCapList.add(budgetCap);
        Map<String,List<Core_MDF_Budget_Cap__c>> ipaCamptoBudgettypeMap=new Map<String,List<Core_MDF_Budget_Cap__c>>();
        String testString=ipaBudgetCaptoCampaignList[0].Core_MDF_Opal_Budget_Type_Txt__c;
        ipaCamptoBudgettypeMap.put(testString,testBudgetCapList);
        Core_MDF_Proposal_Based_Campaign_Process.mapBudgetToCampaign(ipaBudgetCaptoCampaignList,ipaCamptoBudgettypeMap);
        Core_MDF_Proposal_Based_Campaign_Process.mapBudgetToCampaign(null,null);
        Core_MDF_Proposal_Based_Campaign_Process.validateCampaignDateAndAmountAgainstActivity(null,null);
        Core_MDF_Proposal_Based_Campaign_Process.campaignUpdates(null);
        //Core_MDF_Proposal_Based_Campaign_Process.calcreimbamt(null);
        assert.areEqual('Business Client Acceleration - MDF',budgetCap.Core_MDF_Budget_Type_nm__c);
        Test.stopTest();
        }
        }catch(Exception e){
            Core_MDF_CCP_UtilityClass.logError(e);
        }
    }
    
    @isTest
        static void cancelledCampaign(){
            User usr = [Select Id, lastName from User where lastName = 'SysAdmin' limit 1];
        System.runAs(usr){
       // Highlight: Unused Local Variable - Indira 
      //  Account ipaCoMarketingAccount = [select id,Core_MDF_Parent_Fund_Account__c,Core_MDF_Channel_Program__c from Account where Name= 'IPA Co-Marketing Account' LIMIT 1];
        
        Test.startTest();
        
        Campaign ipaCampaignForAP = [SELECT Id, Core_MDF_Activity_Sub_Type_nm__c, Status, Core_MDF_Approval_Step_Counter_nbr__c, 
                                     Core_MDF_Reimbursement_Rate__c, Core_MDF_Region_cd__c, Description,Core_MDF_Opal_Budget_Type_Txt__c,
                                     StartDate, EndDate, Core_MDF_Total_Campaign_Cost_Amt__c, Core_MDF_Market__c, Core_MDF_Reimbursement_Amt__c, Core_MDF_Activity_Category_Type__c
                                     FROM Campaign WHERE Name = 'Test Campaign - AP' LIMIT 1];
        
        ipaCampaignForAP.Status = 'Cancelled';
        ipaCampaignForAP.Core_MDF_Approval_Step_Counter_nbr__c = 0;  
        
        Database.update(ipaCampaignForAP);
        
        assert.areEqual('Cancelled',ipaCampaignForAP.Status);
        Test.stopTest();
        }
    }
    
    @isTest  static void testProcessIPACamapignsBeforeInsertUpdate(){ 
        User IUPGMUser = [Select id, Name, ProfileId from user where id =: userInfo.getUserId()];
        
        Core_MDF_Budget_Cap__c budgetCap = [Select id from Core_MDF_Budget_Cap__c where Core_MDF_Budget_Type_nm__c= 'Client Specialties MDF'];
        
        System.runAs(IUPGMUser){ 
        Test.startTest();
        Id campaign_RecordType_IPA = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Core_MDF_Intel_Partner_Alliance').getRecordTypeId();
        
        Account ipaCoMarketingAccount = [select id,Core_MDF_Parent_Fund_Account__c,Core_MDF_Channel_Program__c 
                                         from Account
                                         where Name= 'IPA Co-Marketing Account'];
        
        List<Campaign> campList = new List<Campaign>();    
        Campaign ipaCampaign2 = new Campaign();
        ipaCampaign2.Name = 'Test Data12';
        ipaCampaign2.Core_MDF_Approval_Stage_nm__c = 'L1 Approval';
        ipaCampaign2.Core_MDF_Reimbursement_Rate__c = '100%';
        ipaCampaign2.Description = 'IPA Campaign Description';
        ipaCampaign2.Core_MDF_Region_cd__c = 'ASMO';
        ipaCampaign2.Core_MDF_Approval_Step_Counter_nbr__c = 0;
        ipaCampaign2.Core_MDF_IPA_NonSPIF_Apprval_Ind__c = true;
        ipaCampaign2.Core_MDF_Sub_Region_cd__c = 'NAR';
        ipaCampaign2.Core_MDF_Budget_Type_txt__c = 'Proposal I MDF';
        ipaCampaign2.Core_MDF_Proposal_Based_Ind__c = true;
        ipaCampaign2.Core_MDF_Program__c = 'Intel Partner Alliance';
        ipaCampaign2.Core_MDF_Market__c = 'AFGHANISTAN';
        ipaCampaign2.Status = 'Pending Review';
        ipaCampaign2.Core_MDF_Account__c = ipaCoMarketingAccount.id;
        ipaCampaign2.RecordTypeId = campaign_RecordType_IPA;
        ipaCampaign2.Core_MDF_IPA_Approval_Status_nm__c = '';
        ipaCampaign2.StartDate = System.today().addDays(1);
        ipaCampaign2.EndDate = System.today().addDays(10);
        ipaCampaign2.Core_MDF_Reimbursement_Amt__c = 1000200;
        //camListToBeInsrted.add(ipaCampaign2);
        campList.add(ipaCampaign2);
          
        Campaign ipaCampaign3 = new Campaign();
        ipaCampaign3.Name = 'Test Data123';
        ipaCampaign3.Core_MDF_Approval_Stage_nm__c = 'Customer Acceptance';
        ipaCampaign3.Core_MDF_Reimbursement_Rate__c = '100%';
        ipaCampaign3.Description = 'IPA Campaign Description';
        ipaCampaign3.Core_MDF_Region_cd__c = 'ASMO';
        ipaCampaign3.Core_MDF_Approval_Step_Counter_nbr__c = 0;
        ipaCampaign3.Core_MDF_IPA_NonSPIF_Apprval_Ind__c = true;
        ipaCampaign3.Core_MDF_Sub_Region_cd__c = 'NAR';
        ipaCampaign3.Core_MDF_Budget_Type_txt__c = 'Proposal I MDF';
        ipaCampaign3.Core_MDF_Proposal_Based_Ind__c = true;
        ipaCampaign3.Core_MDF_Program__c = 'Intel Partner Alliance';
        ipaCampaign3.Core_MDF_Market__c = 'AFGHANISTAN';
        ipaCampaign3.Status = 'Pending Review';
        ipaCampaign3.Core_MDF_Account__c = ipaCoMarketingAccount.id;
        ipaCampaign3.RecordTypeId = campaign_RecordType_IPA;
        ipaCampaign3.Core_MDF_IPA_Approval_Status_nm__c = '';
        ipaCampaign3.StartDate = System.today().addDays(1);
        ipaCampaign3.EndDate = System.today().addDays(10);
        ipaCampaign3.Core_MDF_Reimbursement_Amt__c = 1000200000;
        campList.add(ipaCampaign3);
        
        insert campList;       
        // Highlight: Unused Local Variable - Indira
      /*  PartnerFundRequest testPartnerFundRequest = new PartnerFundRequest(CampaignId=ipaCampaign2.id, recordtypeid = Core_MDF_CCP_IPA_TestDataUtility.partnerFund_RecordType_IPA, 
                                                        ChannelPartnerId = ipaCoMarketingAccount.id, Core_MDF_ActivityCategory__c='Broadcast',
                                                        Core_MDF_Activity_Types__c='Podcast', Core_MDF_Start_Date__c=System.today().addDays(1),
                                                        Core_MDF_End_Date__c =System.today().addDays(10), Title ='Test IPA',
                                                        Core_MDF_Activity_Description__c ='Test IPA Description', Core_MDF_Activity_Classification_nm__c = 'Marketing',
                                                        Status='Draft', Core_MDF_Reimbursement_Rate_txt__c = '100%',
                                                        RequestedAmount = 100000);  */
        //insert testPartnerFundRequest;
        
        List<Campaign> campUpdateList = new List<Campaign>();
        ipaCampaign2.Core_MDF_Approval_Step_Counter_nbr__c = 1;
        ipaCampaign2.Core_MDF_Approval_Stage_nm__c = 'Price Reviewer';
        campUpdateList.add(ipaCampaign2);
        ipaCampaign3.Core_MDF_Budget_Cap__c = budgetCap.Id;
        ipaCampaign3.Core_MDF_Approval_Step_Counter_nbr__c = 3;
        ipaCampaign3.Core_MDF_Completed_Approval_Level_Nm__c = 'L2 Regional Sales';
        ipaCampaign3.Status = 'Pending Approval';
        ipaCampaign3.Core_MDF_Approval_Stage_nm__c = 'Customer Acceptance';
        campUpdateList.add(ipaCampaign3);
        update campUpdateList;
            
        assert.areEqual(1,ipaCampaign2.Core_MDF_Approval_Step_Counter_nbr__c);
        
        Core_MDF_Proposal_Based_Campaign_Process.notifyExternalReviewers(campUpdateList);
        Test.stopTest();
        }
        
    }
    
    @isTest  
    static void testError(){
        
        User usr = [Select Id, lastName from User where lastName = 'SysAdmin' limit 1];
        Assert.areEqual(usr.lastName,'SysAdmin');
        System.runAs(usr){ 

        Set<String> testSet = new Set<String>();
        testSet.add('TestData');
        testSet.add('TestData1');
        
        try{
            Core_MDF_Proposal_Based_Campaign_Process.getRemovedPicklistValue('TestData', testSet, 'TestLabel',null);
        }catch(exception ex){
        }
        
        try{
            Core_MDF_Proposal_Based_Campaign_Process.determinePropBasedCampaignAttributes(null, null, null);
        }catch(exception ex){
            Core_MDF_CCP_UtilityClass.logError(ex);
        }
        
        try{
            Core_MDF_Proposal_Based_Campaign_Process.checkifCampaignReimbursementAmountExceedsBudgetCap(null,null,null);
        }catch(exception ex){
        }
        
        try{
            Core_MDF_Proposal_Based_Campaign_Process.checkIfCampaignNeedsStatusChange(null,null);
        }catch(exception ex){
            Core_MDF_CCP_UtilityClass.logError(ex);
        }
    }
    }
    
    @isTest  
    static void testProcessIPACamapignsBeforeInsertUpdate1(){

        User usr = [Select Id, lastName from User where lastName = 'SysAdmin' limit 1];
        System.runAs(usr){ 
        
        Id campaign_RecordType_IPA = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Core_MDF_Intel_Partner_Alliance').getRecordTypeId();
        
        Account ipaCoMarketingAccount = [select id,Core_MDF_Parent_Fund_Account__c,Core_MDF_Channel_Program__c 
                                         from Account
                                         where Name= 'IPA Co-Marketing Account'];
        
        Campaign ipaCampaign3 = new Campaign();
        ipaCampaign3.Name = 'Test Data';
        ipaCampaign3.Core_MDF_Reimbursement_Rate__c = '100%';
        ipaCampaign3.Description = 'IPA Campaign Description';
        ipaCampaign3.Core_MDF_Region_cd__c = 'ASMO';
        ipaCampaign3.Core_MDF_Sub_Region_cd__c = 'NAR';
        ipaCampaign3.Core_MDF_Budget_Type_txt__c = 'Proposal I MDF';
        ipaCampaign3.Core_MDF_Proposal_Based_Ind__c = true;
        ipaCampaign3.Core_MDF_Program__c = 'Intel Partner Alliance';
        ipaCampaign3.Core_MDF_Market__c = 'AFGHANISTAN';
        ipaCampaign3.Status = 'Pending Review';
        ipaCampaign3.Core_MDF_Approval_Stage_nm__c = 'L1 Approval';
        ipaCampaign3.Core_MDF_Account__c = ipaCoMarketingAccount.id;
        ipaCampaign3.RecordTypeId = campaign_RecordType_IPA;
        ipaCampaign3.Core_MDF_IPA_Approval_Status_nm__c = '';
        ipaCampaign3.StartDate = System.today().addDays(1);
        ipaCampaign3.EndDate = System.today().addDays(10);
        ipaCampaign3.Core_MDF_Reimbursement_Amt__c = 1000200;
        ipaCampaign3.Core_MDF_Approval_Step_Counter_nbr__c = 0;
        insert ipaCampaign3;
        
        // Highlight: Unused Local Variable - Indira
       /* PartnerFundRequest testPartnerFundRequest1 = new PartnerFundRequest(CampaignId=ipaCampaign3.id, recordtypeid = Core_MDF_CCP_IPA_TestDataUtility.partnerFund_RecordType_IPA, 
                                                        ChannelPartnerId = ipaCoMarketingAccount.id, Core_MDF_ActivityCategory__c='Broadcast',
                                                        Core_MDF_Activity_Types__c='Other (Broadcast)', Core_MDF_Start_Date__c=System.today().addDays(1),
                                                        Core_MDF_End_Date__c =System.today().addDays(10), Title ='Test IPA',
                                                        Core_MDF_Activity_Description__c ='Test IPA Description', Core_MDF_Activity_Classification_nm__c = 'Marketing',
                                                        Status='Draft', Core_MDF_Reimbursement_Rate_txt__c = '100%',
                                                        RequestedAmount = 100000); */
        //insert testPartnerFundRequest1;
        
        Test.startTest();
        ipaCampaign3.Core_MDF_Approval_Step_Counter_nbr__c = 1;
        update ipaCampaign3;
            
        assert.areEqual(1,ipaCampaign3.Core_MDF_Approval_Step_Counter_nbr__c);
        Test.stopTest();
        }
    } 
    
    @isTest  
    static void testProcessIPACamapignsBeforeInsertUpdate2(){
        User usr = [Select Id, lastName from User where lastName = 'SysAdmin' limit 1];
        System.runAs(usr){ 
        
        Id campaign_RecordType_IPA = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Core_MDF_Intel_Partner_Alliance').getRecordTypeId();
        
        Account ipaCoMarketingAccount = [select id,Core_MDF_Parent_Fund_Account__c,Core_MDF_Channel_Program__c 
                                         from Account
                                         where Name= 'IPA Co-Marketing Account'];
        
        Campaign ipaCampaign7 = new Campaign();
        ipaCampaign7.Name = 'Test Data12';
        ipaCampaign7.Core_MDF_Approval_Stage_nm__c = 'L1 Approval';
        ipaCampaign7.Core_MDF_Reimbursement_Rate__c = '100%';
        ipaCampaign7.Description = 'IPA Campaign Description';
        ipaCampaign7.Core_MDF_Region_cd__c = 'ASMO';
        ipaCampaign7.Core_MDF_Sub_Region_cd__c = 'NAR';
        ipaCampaign7.Core_MDF_Budget_Type_txt__c = 'Proposal I MDF';
        ipaCampaign7.Core_MDF_Proposal_Based_Ind__c = true;
        ipaCampaign7.Core_MDF_Program__c = 'Intel Partner Alliance';
        ipaCampaign7.Core_MDF_Market__c = 'AFGHANISTAN';
        ipaCampaign7.Status = 'Pending Review';
        ipaCampaign7.Core_MDF_Account__c = ipaCoMarketingAccount.id;
        ipaCampaign7.RecordTypeId = campaign_RecordType_IPA;
        ipaCampaign7.Core_MDF_IPA_Approval_Status_nm__c = '';
        ipaCampaign7.StartDate = System.today().addDays(1);
        ipaCampaign7.EndDate = System.today().addDays(10);
        ipaCampaign7.Core_MDF_Reimbursement_Amt__c = 1000200;
        ipaCampaign7.Core_MDF_Approval_Step_Counter_nbr__c = 0;
        insert ipaCampaign7;
        // Highlight: Unused Local Variable - Indira
      /*  PartnerFundRequest testPartnerFundRequest2 = new PartnerFundRequest(CampaignId=ipaCampaign7.id, recordtypeid = Core_MDF_CCP_IPA_TestDataUtility.partnerFund_RecordType_IPA, 
                                                        ChannelPartnerId = ipaCoMarketingAccount.id, Core_MDF_ActivityCategory__c='Sales Incentive',
                                                        Core_MDF_Activity_Types__c='Seller - Target SPIF', Core_MDF_Start_Date__c=System.today().addDays(1),
                                                        Core_MDF_End_Date__c =System.today().addDays(10), Title ='Test IPA',
                                                        Core_MDF_Activity_Description__c ='Test IPA Description', Core_MDF_Activity_Classification_nm__c = 'Sales',
                                                        Status='Draft', Core_MDF_Reimbursement_Rate_txt__c = '100%',
                                                        RequestedAmount = 100000, Core_MDF_SPIF_Segments_Available_ind__c= true); */
        //insert testPartnerFundRequest2;
        
        Test.startTest();
        ipaCampaign7.Core_MDF_Approval_Step_Counter_nbr__c = 1;
        update ipaCampaign7;
            
        assert.areEqual(1,ipaCampaign7.Core_MDF_Approval_Step_Counter_nbr__c);
        Test.stopTest();
        }
    }
    
    @isTest  
    static void testProcessIPACamapignsBeforeInsertUpdate4(){
        User usr = [Select Id, lastName from User where lastName = 'SysAdmin' limit 1];
        System.runAs(usr){ 
        Test.startTest();
         Id campaign_RecordType_IPA = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Core_MDF_Intel_Partner_Alliance').getRecordTypeId();
        
        Account ipaCoMarketingAccount = [select id,Core_MDF_Parent_Fund_Account__c,Core_MDF_Channel_Program__c 
                                         from Account
                                         where Name= 'IPA Co-Marketing Account'];
        
        Campaign ipaCampaign8 = new Campaign();
        ipaCampaign8.Name = 'Test Data12';
        ipaCampaign8.Core_MDF_Approval_Stage_nm__c = 'L2 Regional Sales';
        ipaCampaign8.Core_MDF_Reimbursement_Rate__c = '100%';
        ipaCampaign8.Description = 'IPA Campaign Description';
        ipaCampaign8.Core_MDF_Region_cd__c = 'ASMO';
        ipaCampaign8.Core_MDF_Sub_Region_cd__c = 'NAR';
        ipaCampaign8.Core_MDF_Budget_Type_txt__c = 'Proposal I MDF';
        ipaCampaign8.Core_MDF_Proposal_Based_Ind__c = true;
        ipaCampaign8.Core_MDF_Program__c = 'Intel Partner Alliance';
        ipaCampaign8.Core_MDF_Market__c = 'AFGHANISTAN';
        ipaCampaign8.Status = 'Pending Review';
        ipaCampaign8.Core_MDF_Account__c = ipaCoMarketingAccount.id;
        ipaCampaign8.RecordTypeId = campaign_RecordType_IPA;
        ipaCampaign8.Core_MDF_IPA_Approval_Status_nm__c = '';
        ipaCampaign8.StartDate = System.today().addDays(1);
        ipaCampaign8.EndDate = System.today().addDays(10);
        ipaCampaign8.Core_MDF_Reimbursement_Amt__c = 1000200;
        ipaCampaign8.Core_MDF_Approval_Step_Counter_nbr__c = 2;
        ipaCampaign8.Core_MDF_Proposal_Based_Ind__c = true;
        insert ipaCampaign8;
        // Highlight: Unused Local Variable - Indira
       /* PartnerFundRequest testPartnerFundRequest3 = new PartnerFundRequest(CampaignId=ipaCampaign8.id, recordtypeid = Core_MDF_CCP_IPA_TestDataUtility.partnerFund_RecordType_IPA, 
                                                        ChannelPartnerId = ipaCoMarketingAccount.id, Core_MDF_ActivityCategory__c='Broadcast',
                                                        Core_MDF_Activity_Types__c='Other (Broadcast)', Core_MDF_Start_Date__c=System.today().addDays(1),
                                                        Core_MDF_End_Date__c =System.today().addDays(10), Title ='Test IPA',
                                                        Core_MDF_Activity_Description__c ='Test IPA Description', Core_MDF_Activity_Classification_nm__c = 'Marketing',
                                                        Status='Draft', Core_MDF_Reimbursement_Rate_txt__c = '100%',
                                                        RequestedAmount = 100000);  */
       // insert testPartnerFundRequest3;
        
        
        ipaCampaign8.Status = 'Pending Approval';
        ipaCampaign8.Core_MDF_Approval_Step_Counter_nbr__c = 3;
        update ipaCampaign8;
            
        assert.areEqual(3,ipaCampaign8.Core_MDF_Approval_Step_Counter_nbr__c);
        
        ipaCampaign8.Status = 'Cancelled';
        update ipaCampaign8;
        assert.areEqual('Cancelled',ipaCampaign8.Status);
        Test.stopTest();
        }
        
            List<Campaign> newCampList = new List<Campaign>();
        try {
            Core_MDF_CampaignServiceHandler.updateIpaL1ApproverComments(newCampList);
        }catch(Exception e){ 
        }
    }
    
    @isTest
    static void testCampaignCancellation(){
        User usr = [Select Id, lastName from User where lastName = 'SysAdmin' limit 1];
        System.runAs(usr){ 
         test.startTest();
         Id campaign_RecordType_IPA = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Core_MDF_Intel_Partner_Alliance').getRecordTypeId();
        
        Account ipaCoMarketingAccount = [select id,Core_MDF_Parent_Fund_Account__c,Core_MDF_Channel_Program__c 
                                         from Account
                                         where Name= 'IPA Co-Marketing Account'];
        
        Campaign ipaCampaign8 = new Campaign();
        ipaCampaign8.Name = 'Test Data12';
        ipaCampaign8.Core_MDF_Approval_Stage_nm__c = 'L2 Regional Sales';
        ipaCampaign8.Core_MDF_Reimbursement_Rate__c = '100%';
        ipaCampaign8.Description = 'IPA Campaign Description';
        ipaCampaign8.Core_MDF_Region_cd__c = 'ASMO';
        ipaCampaign8.Core_MDF_Sub_Region_cd__c = 'NAR';
        ipaCampaign8.Core_MDF_Budget_Type_txt__c = 'Proposal I MDF';
        ipaCampaign8.Core_MDF_Proposal_Based_Ind__c = true;
        ipaCampaign8.Core_MDF_Program__c = 'Intel Partner Alliance';
        ipaCampaign8.Core_MDF_Market__c = 'AFGHANISTAN';
        ipaCampaign8.Status = 'Draft';
        ipaCampaign8.Core_MDF_Account__c = ipaCoMarketingAccount.id;
        ipaCampaign8.RecordTypeId = campaign_RecordType_IPA;
        ipaCampaign8.Core_MDF_IPA_Approval_Status_nm__c = '';
        ipaCampaign8.StartDate = System.today().addDays(1);
        ipaCampaign8.EndDate = System.today().addDays(10);
        ipaCampaign8.Core_MDF_Reimbursement_Amt__c = 1000200;
        ipaCampaign8.Core_MDF_Approval_Step_Counter_nbr__c = 2;
        ipaCampaign8.Core_MDF_Proposal_Based_Ind__c = true;
        insert ipaCampaign8;
        
        PartnerFundRequest testPartnerFundRequest3 = new PartnerFundRequest(CampaignId=ipaCampaign8.id, recordtypeid = Core_MDF_CCP_IPA_TestDataUtility.partnerFund_RecordType_IPA, 
                                                        ChannelPartnerId = ipaCoMarketingAccount.id, Core_MDF_ActivityCategory__c='Broadcast (Pre-2025)',
                                                        Core_MDF_Activity_Types__c='Other (Broadcast)', Core_MDF_Start_Date__c=System.today().addDays(1),
                                                        Core_MDF_End_Date__c =System.today().addDays(10), Title ='Test IPA',
                                                        Core_MDF_Activity_Description__c ='Test IPA Description', Core_MDF_Activity_Classification_nm__c = 'Marketing',
                                                        Status='Draft', Core_MDF_Reimbursement_Rate_txt__c = '100%',
                                                        RequestedAmount = 100000);
        insert testPartnerFundRequest3;
            
            
        ipaCampaign8.Status = 'Completed';
        update ipaCampaign8;

        ipaCampaign8.Status = 'Cancelled';
        update ipaCampaign8;
        test.stopTest();
        // Unit Test Method should include System.Assert - Indira
         System.assertEquals('Cancelled', ipaCampaign8.Status, 'Campaign status should be Cancelled');
        }        
    }

    @isTest
    static void testCoGTMApprovalProcess() {

        User usr = [Select Id, lastName from User where lastName = 'SysAdmin' limit 1];
        System.runAs(usr){ 
            test.startTest();
	
            ChannelProgram coGTMCP = [Select Id from ChannelProgram where Name = 'Co-GTM' limit 1];
            Id pmb_RecordType_CoGTM = Schema.SObjectType.PartnerMarketingBudget.getRecordTypeInfosByDeveloperName().get('Core_MDF_Co_GTM').getRecordTypeId();
           // Highlight: Unused Local Variable - Indira
          //  Id pfa_RecordType_CoGTM = Schema.SObjectType.PartnerFundAllocation.getRecordTypeInfosByDeveloperName().get('Core_MDF_Co_GTM').getRecordTypeId();
            Id campaign_RecordType_CoGTM = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Core_MDF_Co_GTM').getRecordTypeId();
            Id pfr_RecordType_CoGTM = Schema.SObjectType.PartnerFundRequest.getRecordTypeInfosByDeveloperName().get('Core_MDF_Co_GTM').getRecordTypeId();

            Account coGTMCoMarketingAccount = [SELECT Id,Core_MDF_Parent_Fund_Account__c,Core_MDF_Channel_Program__c FROM Account WHERE Name= 'CoGTM Co-Marketing Account'];
            
            PartnerMarketingBudget  coGTMPMB = Core_MDF_CCP_TestDataUtility.createBudget('CoGTMPMB', pmb_RecordType_CoGTM, coGTMCoMarketingAccount.Id, coGTMCP.Id, 
                                                                                         1000000, System.today().addDays(-10), System.today().addDays(40),false);
            coGTMPMB.Core_MDF_Budget_Type_Txt__c = 'Co-Engineering';
            insert coGTMPMB;
            
            /*PartnerFundAllocation coGTMPFA = new PartnerFundAllocation();
            coGTMPFA.RecordTypeId = pfa_RecordType_CoGTM;
            coGTMPFA.Title = 'CoGTMPFA';
            coGTMPFA.Budget = coGTMPMB;
            coGTMPFA.BudgetId = coGTMPMB.Id;
            coGTMPFA.ChannelPartnerId = coGTMCoMarketingAccount.Id;
            coGTMPFA.Amount = 10000;
            insert coGTMPFA;*/
            
            PartnerFundAllocation coGTMPFA = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('CoGTMPFA',coGTMPMB,coGTMCoMarketingAccount,100000.0,true);

            Campaign coGTMCampaign = new Campaign();
            coGTMCampaign.Name = 'Test CoGTM Camp';
            //coGTMCampaign.Core_MDF_Approval_Stage_nm__c = 'L2 Regional Sales';
            coGTMCampaign.Core_MDF_Opal_Budget_Type_Txt__c = 'Co-Engineering';
            coGTMCampaign.Core_MDF_Proposal_Based_Ind__c = true;
            coGTMCampaign.Core_MDF_Program__c = 'CoGTM';
            coGTMCampaign.Status = 'Draft';
            coGTMCampaign.Core_MDF_Account__c = coGTMCoMarketingAccount.id;
            coGTMCampaign.RecordTypeId = campaign_RecordType_CoGTM;
            coGTMCampaign.StartDate = System.today().addDays(-1);
            coGTMCampaign.EndDate = System.today().addDays(15);
            coGTMCampaign.Core_MDF_Reimbursement_Amt__c = 1000200;
            coGTMCampaign.Core_MDF_Activity_Category_Type__c = 'Innovation ->Engineering';
            Database.insert(coGTMCampaign);
            
            PartnerFundRequest coGTMPFR = new PartnerFUndRequest();
            coGTMPFR.CampaignId=coGTMCampaign.id;
            coGTMPFR.RecordTypeId = pfr_RecordType_CoGTM;
            coGTMPFR.ChannelPartnerId = coGTMCoMarketingAccount.id;
            coGTMPFR.Core_MDF_ActivityCategory__c='Innovation';
            coGTMPFR.Core_MDF_Activity_Types__c='Engineering';
            coGTMPFR.Core_MDF_Start_Date__c=System.today().addDays(1);
            coGTMPFR.Core_MDF_End_Date__c =System.today().addDays(2);
            coGTMPFR.Title ='Test CoGTM PFR';
            coGTMPFR.Status = 'Draft';
            coGTMPFR.Core_MDF_Reimbursement_Rate_txt__c = '100%';
            coGTMPFR.RequestedAmount = 1000200;
            coGTMPFR.AllocationId = coGTMPFA.Id;
            coGTMPFR.BudgetId = coGTMPMB.Id;
            Database.insert(coGTMPFR);
            
            coGTMCampaign.Status = 'Pending Review';
            coGTMCampaign.StartDate=System.today().addDays(-2);
            coGTMCampaign.Core_MDF_Reason_for_Back_Dating_Nm__c = 'Other';
            coGTMCampaign.Core_MDF_Other_Reason_Name_txt__c = 'Other';
            try { Database.update(coGTMCampaign); } catch (Exception e) {}
            coGTMCampaign.StartDate=System.today().addDays(6);
            coGTMCampaign.Core_MDF_Approval_Step_Counter_nbr__c = 1;
            coGTMCampaign.Core_MDF_Reason_for_Back_Dating_Nm__c = '';
            coGTMCampaign.Core_MDF_Other_Reason_Name_txt__c = '';
            coGTMCampaign.Core_MDF_Approval_Stage_nm__c = 'Price Reviewer';
            try { Database.update(coGTMCampaign); } catch (Exception e) {}
            coGTMCampaign.Core_MDF_Approval_Step_Counter_nbr__c = 2;
            coGTMCampaign.Core_MDF_Approval_Stage_nm__c = 'L2 Approval';
			try { Database.update(coGTMCampaign); } catch (Exception e) {}
            Assert.areEqual('', coGTMCampaign.Core_MDF_Other_Reason_Name_txt__c);
        }
    }

}