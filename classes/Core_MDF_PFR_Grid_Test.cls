@isTest(SeeAllData=false)
private class Core_MDF_PFR_Grid_Test {
   @TestSetup 
    static void createTestData() {
        List<User> userList = new List<User>();
        Profile ccpCoreProfile = [SELECT Id FROM Profile WHERE Name = 'CCP - Core Access'];
        
        // Create UserRole instead of querying for it
        UserRole usRole = new UserRole(
            Name = 'Admin'
           // DeveloperName = 'Admin'
        );
        insert usRole;
		UserRole usRole1 = [SELECT Id,Name FROM UserRole where Name like '%Partner User%' LIMIT 1];        
        // Creating User with utility class 
        User testUser = Core_MDF_CCP_TestDataUtility.createUser(false);
        testUser.LastName = 'Test User1';
        testUser.UserRoleId = usRole.Id;
        
        User progAdmUsr = Core_MDF_CCP_TestDataUtility.createUser(false);
        progAdmUsr.profileId = ccpCoreProfile.Id;
        progAdmUsr.LastName = 'Prog Adm Usr';
        progAdmUsr.UserPermissionsMarketingUser = true;
        
        userList.add(progAdmUsr);
        userList.add(testUser);
        Database.insert(userList);

        Profile sysAdminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator' LIMIT 1];
        // Creating User with utility class 
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.UserRoleId = usRole.Id; // Reuse the same UserRole
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
            
            List<String> bypassFunctionKeys = new List<String>();
            bypassFunctionKeys.add('BypassCampaignBenefitValidation');
            bypassFunctionKeys.add('Core_MDF_Bypass_Manual_Share');
            bypassFunctionKeys.add('Bypass_MDF_Budget_Access');
            bypassFunctionKeys.add('Bypass_MDF_Budget_Access_Validation');
            bypassFunctionKeys.add('Core_MDF_BudgetCapValidation');
            bypassFunctionKeys.add('Core_MDF_BypassBudgCapIUPGMValidation');
            List<Core_Trigger_Executions__c> bypassfunctinalitylist1 = Core_MDF_CCP_TestDataUtility.byPassFeature(bypassFunctionKeys,true,true);
            List<String> bypassFunctionKeys1 = new List<String>();
            bypassFunctionKeys1.add('BypassCampaignBenefitValidation');
            List<Core_Trigger_Executions__c> bypassfunctinalitylist = Core_MDF_CCP_TestDataUtility.byPassFeature(bypassFunctionKeys,true,false);
            
            ChannelProgram ipaCP = Core_MDF_CCP_TestDataUtility.createProgram ('Intel Partner Alliance','Intel Partner Alliance', true);
            ChannelProgram coGTMCP = Core_MDF_CCP_TestDataUtility.createProgram ('Co-GTM','CoGTM', true);
            
            Account ipaUltimateAccount = Core_MDF_CCP_TestDataUtility.createIntelAccount ('IPA Intel Account',Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, true);
            ipaUltimateAccount.Core_Prime_Id__c = 'primeId1';
            ipaUltimateAccount.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
            update ipaUltimateAccount;
            Account ipaCoMarketingAccount = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('IPA Co-Marketing Account', ipaCP.id, Core_MDF_CCP_TestDataUtility.Account_Record_Type,ipaUltimateAccount.id, false);           
            ipaCoMarketingAccount.Core_Geo__c = 'ASMO';
           	insert ipaCoMarketingAccount;
            Account coGTMCoMarketingAccount = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('CoGTM Co-Marketing Account', coGTMCP.id, Core_MDF_CCP_TestDataUtility.Account_Record_Type,ipaUltimateAccount.id, false);
            insert coGTMCoMarketingAccount;

            // Fixed: Replace the problematic createBenefit call with a direct budget type assignment
            String budgetType = 'Client Specialties MDF';
            
            // Alternative: If you need to create benefit records, do it manually
            /*
            try {
                budgetType = Core_MDF_CCP_IPA_TestDataUtility.createBenefit(ipaCoMarketingAccount);
            } catch (Exception e) {
                System.debug('Error creating benefit: ' + e.getMessage());
                budgetType = 'Client Specialties MDF'; // Fallback to default
            }
            */
            
             Id ipaBudTypeCapRecordtype = Schema.SObjectType.Core_MDF_Budget_Cap__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_IPA_Budget_Type_Cap').getRecordTypeId();
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
           
           // Database.insert(iupgmList);
             
        

          
           
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
           	//extUsr1.UserRoleId=usRole1.id;
            usrList.add(extUsr1);
            
            User extUsr2 = Core_MDF_CCP_TestDataUtility.createUser(false);
            extUsr2.LastName = 'User Test2';
            extUsr2.ProfileId = partnerProfile.Id;
            extUsr2.ContactId = con1.Id;
          // extUsr2.UserRoleId=usRole1.id;
            extUsr2.IsActive = TRUE;
            usrList.add(extUsr2);
            
            User extUsr3 = Core_MDF_CCP_TestDataUtility.createUser(false);
            extUsr3.LastName = 'User Test3';
            extUsr3.ProfileId = partnerProfile.Id;
           // extUsr3.UserRoleId=usRole1.id;
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
            
            
            Map<Id,Set<Id>> userIdCorpAcctIdSet = new Map<Id,Set<Id>>();
            Set<Id> accIdSet = new Set<Id>();
            accIdSet.add(ipaCoMarketingAccount.Id);
            userIdCorpAcctIdSet.put(extUsr1.Id, accIdSet);
            userIdCorpAcctIdSet.put(extUsr2.Id, accIdSet);
            userIdCorpAcctIdSet.put(extUsr3.Id, accIdSet);
            
            //Core_MDF_IPA_AccountUserMapping.createPnumRecords(userIdCorpAcctIdSet);
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
            Campaign ipaCampaignForAP = Core_MDF_CCP_IPA_TestDataUtility.createIPACampaign('Test Campaign - AP',ipaCoMarketingAccount.id, System.today(), System.today().adddays(30),budgetType, 110000,'INDIA', 'Developer', 'Apollo Lake', 'Pending Approval', false);
            ipaCampaignForAP.Core_MDF_Region_cd__c = 'APJ';
            ipaCampaignForAP.Core_MDF_Opal_Budget_Type_Txt__c ='Client Specialties MDF';
            ipaCampaignForAP.Core_MDF_Proposal_Based_Ind__c = true;
           	ipaCampaignForAP.Core_MDF_Budget_Type_txt__c = 'Client Specialties MDF';
           	ipaCampaignForAP.Core_MDF_Technology__c='Intel® Core™ Ultra Series 2 (Lunar Lake)';
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
            
            Database.insert(pgmIntList);
            
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

    @isTest
    static void testCoGTMApprovalProcess() {

        User usr = [Select Id, lastName from User where lastName = 'SysAdmin' limit 1];
        System.runAs(usr){ 
            Account coGTMCoMarketingAccount = [SELECT Id,Core_MDF_CoMarketing_Ultimate_Account__c,Core_MDF_Parent_Fund_Account__c,Core_MDF_Channel_Program__c FROM Account WHERE Name= 'CoGTM Co-Marketing Account'];
            ChannelProgram coGTMProgram = [SELECT Id,Core_MDF_Technical_Program_Name__c FROM ChannelProgram WHERE Core_MDF_Technical_Program_Name__c = 'CoGTM' LIMIT 1];
            test.startTest();

            // Check if permission set exists before trying to assign it
            List<PermissionSet> psList = [SELECT Id FROM PermissionSet WHERE Name= 'Core_MDF_CCP_Internal_Co_GTM_Account_Manager' LIMIT 1];
            if (!psList.isEmpty()) {
                // Check if assignment already exists
                List<PermissionSetAssignment> existingAssignments = [SELECT Id FROM PermissionSetAssignment 
                                                                   WHERE AssigneeId = :usr.id 
                                                                   AND PermissionSetId = :psList[0].Id LIMIT 1];
                if (existingAssignments.isEmpty()) {
                    insert new PermissionSetAssignment(AssigneeId = usr.id, PermissionSetId = psList[0].Id);
                }
            }

            List<PermissionSet> ps2List = [SELECT Id FROM PermissionSet WHERE Name= 'Core_MDF_CCP_Internal_Generic_Access' LIMIT 1];
            if (!ps2List.isEmpty()) {
                // Check if assignment already exists
                List<PermissionSetAssignment> existingAssignments2 = [SELECT Id FROM PermissionSetAssignment 
                                                                    WHERE AssigneeId = :usr.id 
                                                                    AND PermissionSetId = :ps2List[0].Id LIMIT 1];
                if (existingAssignments2.isEmpty()) {
                    insert new PermissionSetAssignment(AssigneeId = usr.id, PermissionSetId = ps2List[0].Id);
                }
            }

            Id iupgm_RecordType_CoGTM = Schema.SObjectType.Core_MDF_Int_Users_Partner_Geo_Mapping__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_Co_GTM').getRecordTypeId();

            Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgmRec = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
            iupgmRec.Core_MDF_Account_id__c = coGTMCoMarketingAccount.Core_MDF_CoMarketing_Ultimate_Account__c;
            iupgmRec.Core_MDF_Active_Ind__c = true;
            iupgmRec.Core_MDF_All_Accounts_cd__c = 'No';
            iupgmRec.Core_MDF_All_Budget_Type_Access_Ind__c = true;
            iupgmRec.Core_MDF_Channel_Program_id__c = coGTMProgram.Id;
            iupgmRec.Core_MDF_Program_nm__c = 'CoGTM';
            iupgmRec.Core_MDF_Region_cd__c = 'WW';
            iupgmRec.Core_MDF_Region_Sub_Region_nm__c = 'WW';
            iupgmRec.Core_MDF_Role_nm__c = 'Core_MDF_CCP_Internal_Co_GTM_Account_Manager';
            iupgmRec.Core_MDF_User_id__c = usr.id;
            iupgmRec.RecordTypeId = iupgm_RecordType_CoGTM;
           // insert iupgmRec;

            Id campaign_RecordType_CoGTM = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Core_MDF_Co_GTM').getRecordTypeId();
            Id activity_RecordType_CoGTM = Schema.SObjectType.PartnerFundRequest.getRecordTypeInfosByDeveloperName().get('Core_MDF_Co_GTM').getRecordTypeId();

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
            coGTMCampaign.EndDate = System.today().addDays(10);
            coGTMCampaign.Core_MDF_Reimbursement_Amt__c = 1000200;
            coGTMCampaign.Core_MDF_Activity_Category_Type__c = 'Innovation ->Engineering';
            //coGTMCampaign.Core_MDF_Approval_Step_Counter_nbr__c = 2;
            insert coGTMCampaign;
            
            Id budget_RecordType_CoGTM = Schema.SObjectType.PartnerMarketingBudget.getRecordTypeInfosByDeveloperName().get('Core_MDF_Co_GTM').getRecordTypeId();
            PartnerMarketingBudget bud = new PartnerMarketingBudget();
            bud.Amount = 10000;
            bud.Core_MDF_Budget_Partner__c = coGTMCoMarketingAccount.id;
            bud.Core_MDF_Budget_Status__c = 'Released';
            bud.Core_MDF_Budget_Type__c = 'Co-Engineering';
            bud.Core_MDF_Budget_Type_Txt__c = 'Co-Engineering';
            bud.Core_MDF_Program__c = coGTMProgram.Id;
            bud.Description = 'Test Budget';
            bud.RecordTypeId = budget_RecordType_CoGTM;
            bud.Title = 'Test Bud';
            bud.StartDate = System.today().addDays(-1);
            bud.EndDate = System.today().addDays(10);
            insert bud;

            Core_MDF_Campaign_Budgets__c campBudget = new Core_MDF_Campaign_Budgets__c();
            campBudget.Core_MDF_Campaign_Id__c = coGTMCampaign.Id;
            campBudget.Core_MDF_Budget_Name_Id__c = bud.Id;
            campBudget.Core_MDF_Budget_Amt__c = 100;
            campBudget.Core_MDF_Reimbursement_Amt__c = 100;
            campBudget.Core_MDF_Reimbursement_Rate_Pct__c = '0%';
            campBudget.Core_MDF_Active_ind__c = true;
            insert campBudget;
             // Test getBudgetDetails with valid campaignId
            List<PartnerMarketingBudget> budgetDetails = Core_MDF_PFR_Grid.getBudgetDetails(coGTMCampaign.Id);
            System.assertNotEquals(null, budgetDetails);
            System.assertEquals(1, budgetDetails.size());
            
             // Test getBudgetDetails with invalid campaignId
            budgetDetails = Core_MDF_PFR_Grid.getBudgetDetails(null);
            System.assertEquals(0, budgetDetails.size());

            // Test getCampaignDetails with valid campaignId
            Boolean allowToCreate = Core_MDF_PFR_Grid.getCampaignDetails(coGTMCampaign.Id);
            System.assertEquals(false, allowToCreate);

            // Test getCampaignDetails with invalid campaignId
            allowToCreate = Core_MDF_PFR_Grid.getCampaignDetails(null);
            System.assertEquals(false, allowToCreate);

            // Test getExistingActivityDetails with valid campaignId
            Core_MDF_PFR_Grid.ActivityDetailsWrapper activityDetails = Core_MDF_PFR_Grid.getExistingActivityDetails(coGTMCampaign.Id);
            System.assertNotEquals(null, activityDetails);
            System.assertNotEquals(null, activityDetails.activityOrCampaignList);
             // Test getExistingActivityDetails with invalid campaignId
            activityDetails = Core_MDF_PFR_Grid.getExistingActivityDetails(null);
            System.assertEquals(null, activityDetails);

            Core_MDF_PFR_Grid.getBudgetDetails(coGTMCampaign.Id);
            Core_MDF_PFR_Grid.getCampaignDetails(coGTMCampaign.Id);
            Core_MDF_PFR_Grid.getExistingActivityDetails(coGTMCampaign.Id);

            List<PartnerFundRequest> pfrList = new List<PartnerFundRequest>();
            PartnerFundRequest pfr= new PartnerFundRequest();
            pfr.Core_MDF_Activity_Engineering_Nm__c = 'Benchmarking';
            pfr.Core_MDF_Other_Engineering_Activity_txt__c = '';
            pfr.Core_MDF_End_Date__c = System.today().addDays(9);
            pfr.Core_MDF_Budget_Amount_Local_amt__c = 100;
            pfr.Core_MDF_POP_Requirement_nm__c = 'Product availability in public catalog';
            pfr.BudgetId = bud.Id;
            pfr.Core_MDF_Exchange_Rate_ptc__c = 1;
            pfr.RecordTypeId = activity_RecordType_CoGTM;
            pfr.CampaignId = coGTMCampaign.Id;
            pfr.Core_MDF_Budget_Type_nm__c = 'Co-Engineering';
            pfr.ChannelPartnerId = coGTMCoMarketingAccount.id;

            pfrList.add(pfr);
            Core_MDF_PFR_Grid.insertRecords(pfrList);
            Core_MDF_PFR_Grid.getExistingActivityDetails(coGTMCampaign.Id);
            
            List<PartnerFundRequest> pfrList1 = new List<PartnerFundRequest>();
            PartnerFundRequest pfr1 = new PartnerFundRequest();
            pfr1.Core_MDF_Activity_Engineering_Nm__c = 'Benchmarking';
            pfr1.Core_MDF_Other_Engineering_Activity_txt__c = '';
            pfr1.Core_MDF_End_Date__c = System.today().addDays(9);
            pfr1.Core_MDF_Budget_Amount_Local_amt__c = 100;
            pfr1.Core_MDF_POP_Requirement_nm__c = 'Product availability in public catalog';
            //pfr1.BudgetId = bud.Id;
            pfr1.Core_MDF_Exchange_Rate_ptc__c = 1;
            pfr1.RecordTypeId = activity_RecordType_CoGTM;
            pfr1.CampaignId = coGTMCampaign.Id;
            pfr1.Core_MDF_Budget_Type_nm__c = 'Co-Engineering';
            pfr1.ChannelPartnerId = coGTMCoMarketingAccount.id;

            pfrList1.add(pfr1);
            Core_MDF_PFR_Grid.insertRecords(pfrList1);

            test.stopTest();
        }
    }

    // NEW TEST METHODS FOR IMPROVED COVERAGE

    @isTest
    static void testGetBudgetDetailsWithEmptyBudgetIdSet() {
        User usr = [Select Id, lastName from User where lastName = 'SysAdmin' limit 1];
        System.runAs(usr) {
            Account coGTMCoMarketingAccount = [SELECT Id FROM Account WHERE Name= 'CoGTM Co-Marketing Account'];
            ChannelProgram coGTMProgram = [SELECT Id FROM ChannelProgram WHERE Core_MDF_Technical_Program_Name__c = 'CoGTM' LIMIT 1];
            
            Test.startTest();
            
            // Create campaign without any budget mappings
            Id campaign_RecordType_CoGTM = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Core_MDF_Co_GTM').getRecordTypeId();
            Campaign coGTMCampaign = new Campaign();
            coGTMCampaign.Name = 'Test CoGTM Camp No Budget';
            coGTMCampaign.Core_MDF_Opal_Budget_Type_Txt__c = 'Co-Engineering';
            coGTMCampaign.Core_MDF_Proposal_Based_Ind__c = true;
            coGTMCampaign.Core_MDF_Program__c = 'CoGTM';
            coGTMCampaign.Status = 'Draft';
            coGTMCampaign.Core_MDF_Account__c = coGTMCoMarketingAccount.id;
            coGTMCampaign.RecordTypeId = campaign_RecordType_CoGTM;
            coGTMCampaign.StartDate = System.today().addDays(-1);
            coGTMCampaign.EndDate = System.today().addDays(10);
            insert coGTMCampaign;
            
            // Test getBudgetDetails with campaign that has no budget mappings
            List<PartnerMarketingBudget> budgetDetails = Core_MDF_PFR_Grid.getBudgetDetails(coGTMCampaign.Id);
            System.assertEquals(0, budgetDetails.size(), 'Should return empty list when no budget mappings exist');
            
            Test.stopTest();
        }
    }

    @isTest
    static void testGetBudgetDetailsWithBlankCampaignId() {
        Test.startTest();
        
        // Test with blank string
        List<PartnerMarketingBudget> budgetDetails = Core_MDF_PFR_Grid.getBudgetDetails('');
        System.assertEquals(0, budgetDetails.size(), 'Should return empty list for blank campaign ID');
        
        // Test with whitespace string
        budgetDetails = Core_MDF_PFR_Grid.getBudgetDetails('   ');
        System.assertEquals(0, budgetDetails.size(), 'Should return empty list for whitespace campaign ID');
        
        Test.stopTest();
    }

    @isTest
    static void testInsertRecordsWithEmptyList() {
        Test.startTest();
        
        // Test with empty list
        List<PartnerFundRequest> emptyList = new List<PartnerFundRequest>();
        Boolean result = Core_MDF_PFR_Grid.insertRecords(emptyList);
        System.assertEquals(false, result, 'Should return false for empty list');
        
        // Test with null list
        result = Core_MDF_PFR_Grid.insertRecords(null);
        System.assertEquals(false, result, 'Should return false for null list');
        
        Test.stopTest();
    }

    @isTest
    static void testGetCampaignDetailsWithInvalidStatus() {
        User usr = [Select Id, lastName from User where lastName = 'SysAdmin' limit 1];
        System.runAs(usr) {
            Account coGTMCoMarketingAccount = [SELECT Id FROM Account WHERE Name= 'CoGTM Co-Marketing Account'];
            
            Test.startTest();
            
            // Create campaign with status not in allowed list
            Id campaign_RecordType_CoGTM = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Core_MDF_Co_GTM').getRecordTypeId();
            Campaign coGTMCampaign = new Campaign();
            coGTMCampaign.Name = 'Test CoGTM Camp Invalid Status';
            coGTMCampaign.Core_MDF_Opal_Budget_Type_Txt__c = 'Co-Engineering';
            coGTMCampaign.Core_MDF_Proposal_Based_Ind__c = true;
            coGTMCampaign.Core_MDF_Program__c = 'CoGTM';
            coGTMCampaign.Status = 'Completed'; // Not in allowed status list
            coGTMCampaign.Core_MDF_Account__c = coGTMCoMarketingAccount.id;
            coGTMCampaign.RecordTypeId = campaign_RecordType_CoGTM;
            coGTMCampaign.StartDate = System.today().addDays(-1);
            coGTMCampaign.EndDate = System.today().addDays(10);
            insert coGTMCampaign;
            
            Boolean allowToCreate = Core_MDF_PFR_Grid.getCampaignDetails(coGTMCampaign.Id);
            System.assertEquals(false, allowToCreate, 'Should return false for invalid campaign status');
            
            Test.stopTest();
        }
    }

   
    @isTest
    static void testInnerClassDirectly() {
        User usr = [Select Id, lastName from User where lastName = 'SysAdmin' limit 1];
        System.runAs(usr) {
            Account coGTMCoMarketingAccount = [SELECT Id FROM Account WHERE Name= 'CoGTM Co-Marketing Account'];
            
            Test.startTest();
            
            // Create campaign
            Id campaign_RecordType_CoGTM = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Core_MDF_Co_GTM').getRecordTypeId();
            Campaign coGTMCampaign = new Campaign();
            coGTMCampaign.Name = 'Test CoGTM Camp Inner Class';
            coGTMCampaign.Core_MDF_Opal_Budget_Type_Txt__c = 'Co-Engineering';
            coGTMCampaign.Core_MDF_Proposal_Based_Ind__c = true;
            coGTMCampaign.Core_MDF_Program__c = 'CoGTM';
            coGTMCampaign.Status = 'Draft';
            coGTMCampaign.Core_MDF_Account__c = coGTMCoMarketingAccount.id;
            coGTMCampaign.RecordTypeId = campaign_RecordType_CoGTM;
            coGTMCampaign.StartDate = System.today().addDays(-1);
            coGTMCampaign.EndDate = System.today().addDays(10);
            insert coGTMCampaign;
            
            // Test inner class directly
            Core_MDF_PFR_Grid.Core_MDF_PFR_Grid_InnerClass innerClass = new Core_MDF_PFR_Grid.Core_MDF_PFR_Grid_InnerClass();
            Core_MDF_PFR_Grid.ActivityDetailsWrapper result = innerClass.getExistingActivityDetails(coGTMCampaign.Id);
            
            System.assertNotEquals(null, result, 'Inner class should return result');
            System.assertNotEquals(null, result.activityOrCampaignList, 'Should return campaign list when no activities exist');
            
            Test.stopTest();
        }
    }

    @isTest
    static void testInsertRecordsWithInvalidData() {
        Test.startTest();
        
        // Create invalid PFR record to trigger exception
        List<PartnerFundRequest> invalidPfrList = new List<PartnerFundRequest>();
        PartnerFundRequest invalidPfr = new PartnerFundRequest();
        // Missing required fields to trigger exception
        invalidPfr.Core_MDF_Budget_Amount_Local_amt__c = 100;
        invalidPfrList.add(invalidPfr);
        
        Boolean result = Core_MDF_PFR_Grid.insertRecords(invalidPfrList);
        System.assertEquals(false, result, 'Should return false when insert fails');
        
        Test.stopTest();
    }

    @isTest
    static void testGetCampaignDetailsWithBlankCampaignId() {
        Test.startTest();
        
        // Test with blank campaign ID
        Boolean result = Core_MDF_PFR_Grid.getCampaignDetails('');
        System.assertEquals(false, result, 'Should return false for blank campaign ID');
        
        // Test with whitespace campaign ID
        result = Core_MDF_PFR_Grid.getCampaignDetails('   ');
        System.assertEquals(false, result, 'Should return false for whitespace campaign ID');
        
        Test.stopTest();
    }

    @isTest
    static void testGetExistingActivityDetailsWithBlankCampaignId() {
        Test.startTest();
        
        // Test with blank campaign ID
        Core_MDF_PFR_Grid.ActivityDetailsWrapper result = Core_MDF_PFR_Grid.getExistingActivityDetails('');
        System.assertEquals(null, result, 'Should return null for blank campaign ID');
        
        // Test with whitespace campaign ID
        result = Core_MDF_PFR_Grid.getExistingActivityDetails('   ');
        System.assertEquals(null, result, 'Should return null for whitespace campaign ID');
        
        Test.stopTest();
    }

}