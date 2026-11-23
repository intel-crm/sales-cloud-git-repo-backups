@isTest
private class Core_MDF_CampaignPFR_Controller_Test {
    public static Id ipaCampaignRecordId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Core_MDF_Intel_Partner_Alliance').getRecordTypeId(); 
    @TestSetup 
    static void createTestData() {
        
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        
        User systemAdmin = Core_MDF_CCP_TestDataUtility.createUser(false);      
        systemAdmin.LastName = 'SystemAdmin';
        systemAdmin.UserRoleId = usRole.Id;
        insert systemAdmin; 
        
        // Creating User with utility class 
        
        List<User> userListToInsert = new List<User>();
        
        User testUser = Core_MDF_CCP_TestDataUtility.createUser(false);
        testUser.LastName = 'Test User';
        testUser.UserRoleId = usRole.Id;
        userListToInsert.add(testUser);
        
        User pctUsr = Core_MDF_CCP_TestDataUtility.createUser(false);
        pctUsr.LastName = 'User Test11';
        pctUsr.UserRoleId = usRole.Id;
        userListToInsert.add(pctUsr);
        
        User usr2 = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr2.LastName = 'User Test122';
        usr2.UserRoleId = usRole.Id;
        userListToInsert.add(usr2);
        
        User usr3 = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr3.LastName = 'User Test133';
        usr3.UserRoleId = usRole.Id;
        userListToInsert.add(usr3);
        
        User usr4 = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr4.LastName = 'User Test144';
        usr4.UserRoleId = usRole.Id;
        userListToInsert.add(usr4);
        
        User usr5 = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr5.LastName = 'User Test155';
        usr5.UserRoleId = usRole.Id;
        userListToInsert.add(usr5);
        
        Database.insert(userListToInsert);
        
        System.runAs(testUser){
            
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
            
            Account ipaUltimateAccount = Core_MDF_CCP_TestDataUtility.createIntelAccount ('IPA Intel Account',Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, true);
            ipaUltimateAccount.Core_Unified_Global_Customer_BP_Id__c = ipaUltimateAccount.Id;
            ipaUltimateAccount.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
            update ipaUltimateAccount;
            
            // CoGTM claim data prep
            ChannelProgram coGTMCP = Core_MDF_CCP_TestDataUtility.createProgram ('Co-GTM','CoGTM', true);
            insert new Core_MDF_Configuration__c(Name = 'ALLOWED_PRG_FOR_RUS_NOTIF', Core_MDF_Category__c = 'Bank Document Hold Logic', Core_MDF_Value__c = 'Retail Marketing Funds,Intel Partner Alliance,Channel MDF,Co-GTM');
            Account coGTMIntelAccount = Core_MDF_CCP_TestDataUtility.createIntelAccount('CoGTM Intel Account', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, true);
            Account coGTMCoMarketingAccount = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('CoGTM Co-Marketing Account', coGTMCP.id, Core_MDF_CCP_TestDataUtility.Account_Record_Type,ipaUltimateAccount.id, false);
            coGTMCoMarketingAccount.Core_MDF_Payment_Type_nm__c = 'Customer (Pass Through)';
            insert coGTMCoMarketingAccount;
            
            List<Account> accList = new List<Account>();
            Account ipaCoMarketingAccount = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('IPA Co-Marketing Account', ipaCP.id, Core_MDF_CCP_TestDataUtility.Account_Record_Type,ipaUltimateAccount.id, false);           
            Account ipaCoMarketingAccount1 = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('IPA Co-Marketing Account1', ipaCP.id, Core_MDF_CCP_TestDataUtility.Account_Record_Type,ipaUltimateAccount.id, false);
            Account ipaCoMarketingAccount2 = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('IPA Co-Marketing Account2', ipaCP.id, Core_MDF_CCP_TestDataUtility.Account_Record_Type,ipaUltimateAccount.id, false);
            accList.add(ipaCoMarketingAccount);
            accList.add(ipaCoMarketingAccount1);
            accList.add(ipaCoMarketingAccount2);
            Database.insert(accList);                             
            
            Test.startTest();
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
            Contact con3 = Core_MDF_CCP_TestDataUtility.createContact (ipaUltimateAccount.Id, false);
            con3.RecordTypeId = Core_MDF_CCP_TestDataUtility.Intel_Contact_Record_Type;
            conList.add(con3);
            Contact con4 = Core_MDF_CCP_TestDataUtility.createContact (ipaUltimateAccount.Id, false);
            con4.RecordTypeId = Core_MDF_CCP_TestDataUtility.Intel_Contact_Record_Type;
            conList.add(con4);
            Contact con5 = Core_MDF_CCP_TestDataUtility.createContact (ipaUltimateAccount.Id, false);
            con5.RecordTypeId = Core_MDF_CCP_TestDataUtility.Intel_Contact_Record_Type;
            conList.add(con5);
            Contact con6 = Core_MDF_CCP_TestDataUtility.createContact (ipaUltimateAccount.Id, false);
            con6.RecordTypeId = Core_MDF_CCP_TestDataUtility.Intel_Contact_Record_Type;
            conList.add(con6);
            Contact con7 = Core_MDF_CCP_TestDataUtility.createContact (ipaUltimateAccount.Id, false);
            con7.RecordTypeId = Core_MDF_CCP_TestDataUtility.Intel_Contact_Record_Type;
            conList.add(con7);
            Contact con8 = Core_MDF_CCP_TestDataUtility.createContact (ipaUltimateAccount.Id, false);
            con8.RecordTypeId = Core_MDF_CCP_TestDataUtility.Intel_Contact_Record_Type;
            conList.add(con8);
            Contact con9 = Core_MDF_CCP_TestDataUtility.createContact (ipaUltimateAccount.Id, false);
            con9.RecordTypeId = Core_MDF_CCP_TestDataUtility.Intel_Contact_Record_Type;
            conList.add(con9);
            Contact con10 = Core_MDF_CCP_TestDataUtility.createContact (ipaUltimateAccount.Id, false);
            con10.RecordTypeId = Core_MDF_CCP_TestDataUtility.Intel_Contact_Record_Type;
            conList.add(con10);
            Contact con11 = Core_MDF_CCP_TestDataUtility.createContact (ipaUltimateAccount.Id, false);
            con11.RecordTypeId = Core_MDF_CCP_TestDataUtility.Intel_Contact_Record_Type;
            conList.add(con11);
            Database.insert(conList);
            
            Profile partnerProfile = [SELECT Id FROM Profile WHERE Name='Partner' LIMIT 1];
            
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
            User extUsr4 = Core_MDF_CCP_TestDataUtility.createUser(false);
            extUsr4.LastName = 'User Test4';
            extUsr4.ProfileId = partnerProfile.Id;
            extUsr4.ContactId = con3.Id;
            extUsr4.IsActive = TRUE;
            usrList.add(extUsr4);
            User extUsr5 = Core_MDF_CCP_TestDataUtility.createUser(false);
            extUsr5.LastName = 'User Test5';
            extUsr5.ProfileId = partnerProfile.Id;
            extUsr5.ContactId = con4.Id;
            extUsr5.IsActive = TRUE;
            usrList.add(extUsr5);
            User extUsr6 = Core_MDF_CCP_TestDataUtility.createUser(false);
            extUsr6.LastName = 'User Test6';
            extUsr6.ProfileId = partnerProfile.Id;
            extUsr6.ContactId = con5.Id;
            extUsr6.IsActive = TRUE;
            usrList.add(extUsr6);
            User extUsr7 = Core_MDF_CCP_TestDataUtility.createUser(false);
            extUsr7.LastName = 'User Test7';
            extUsr7.ProfileId = partnerProfile.Id;
            extUsr7.ContactId = con6.Id;
            extUsr7.IsActive = TRUE;
            usrList.add(extUsr7);
            User extUsr8 = Core_MDF_CCP_TestDataUtility.createUser(false);
            extUsr8.LastName = 'User Test8';
            extUsr8.ProfileId = partnerProfile.Id;
            extUsr8.ContactId = con7.Id;
            extUsr8.IsActive = TRUE;
            usrList.add(extUsr8);
            User extUsr9 = Core_MDF_CCP_TestDataUtility.createUser(false);
            extUsr9.LastName = 'User Test9';
            extUsr9.ProfileId = partnerProfile.Id;
            extUsr9.ContactId = con8.Id;
            extUsr9.IsActive = TRUE;
            usrList.add(extUsr9);
            User extUsr10 = Core_MDF_CCP_TestDataUtility.createUser(false);
            extUsr10.LastName = 'User Test10';
            extUsr10.ProfileId = partnerProfile.Id;
            extUsr10.ContactId = con9.Id;
            extUsr10.IsActive = TRUE;
            usrList.add(extUsr10);            
            User extUsr12 = Core_MDF_CCP_TestDataUtility.createUser(false);
            extUsr12.LastName = 'User Test12';
            extUsr12.ProfileId = partnerProfile.Id;
            extUsr12.ContactId = con11.Id;
            extUsr12.IsActive = TRUE;
            usrList.add(extUsr12);
            Database.insert(usrList);
            
            PermissionSet pSet = [SELECT Id FROM PermissionSet WHERE PermissionSet.Name = 'Core_MDF_CCP_External_IPA_Proposal_Manager'];
            PermissionSet pSet1 = [SELECT Id FROM PermissionSet WHERE PermissionSet.Name = 'Core_MDF_CCP_Internal_IPA_Acct_Mgr'];
            PermissionSet pSet2 = [SELECT Id FROM PermissionSet WHERE PermissionSet.Name = 'Core_MDF_CCP_Int_IPA_ProposalL1_Approver'];
            PermissionSet pSet3 = [SELECT Id FROM PermissionSet WHERE PermissionSet.Name = 'Core_MDF_CCP_Internal_Proposal_Activity_L2_Approver'];
            PermissionSet pSet4 = [SELECT Id FROM PermissionSet WHERE PermissionSet.Name = 'Core_MDF_CCP_Internal_Proposal_Activity_POR_Approver'];
            
            PermissionSet pctPermSet = [SELECT Id FROM PermissionSet WHERE PermissionSet.Name = 'Core_MDF_CCP_Internal_Price_Reviewer'];
            
            
            PermissionSet claimPerSet = [SELECT Id FROM PermissionSet WHERE PermissionSet.Name = 'Core_MDF_CCP_External_IPA_Claim_Submitter'];
            //insert new PermissionSetAssignment(AssigneeId = extUsr1.Id, PermissionSetId = pSet.id);
            
            List<PermissionSetAssignment>permissionSetAssignmentList = new List<PermissionSetAssignment>();
            
            PermissionSetAssignment psa1 = new PermissionSetAssignment(PermissionSetId = pSet.id, AssigneeId = extUsr1.Id);
            permissionSetAssignmentList.add(psa1);
            PermissionSetAssignment psa2 = new PermissionSetAssignment(PermissionSetId = pSet.id, AssigneeId = extUsr2.Id);
            permissionSetAssignmentList.add(psa2);
            PermissionSetAssignment psa3 = new PermissionSetAssignment(PermissionSetId = pSet.id, AssigneeId = extUsr3.Id);
            permissionSetAssignmentList.add(psa3);
            PermissionSetAssignment psa4 = new PermissionSetAssignment(PermissionSetId = pSet.id, AssigneeId = extUsr4.Id);
            permissionSetAssignmentList.add(psa4);
            PermissionSetAssignment psa5 = new PermissionSetAssignment(PermissionSetId = pSet.id, AssigneeId = extUsr5.Id);
            permissionSetAssignmentList.add(psa5);
            PermissionSetAssignment psa6 = new PermissionSetAssignment(PermissionSetId = pSet.id, AssigneeId = extUsr6.Id);
            permissionSetAssignmentList.add(psa6);
            PermissionSetAssignment psa7 = new PermissionSetAssignment(PermissionSetId = pSet.id, AssigneeId = extUsr7.Id);
            permissionSetAssignmentList.add(psa7);
            PermissionSetAssignment psa8 = new PermissionSetAssignment(PermissionSetId = pSet.id, AssigneeId = extUsr8.Id);
            permissionSetAssignmentList.add(psa8);
            PermissionSetAssignment psa9 = new PermissionSetAssignment(PermissionSetId = pSet.id, AssigneeId = extUsr9.Id);
            permissionSetAssignmentList.add(psa9);
            PermissionSetAssignment psa10 = new PermissionSetAssignment(PermissionSetId = pSet.id, AssigneeId = extUsr10.Id);
            permissionSetAssignmentList.add(psa10);
            PermissionSetAssignment psa11 = new PermissionSetAssignment(PermissionSetId = pctPermSet.id, AssigneeId = pctUsr.Id);
            permissionSetAssignmentList.add(psa11);
            PermissionSetAssignment psa12 = new PermissionSetAssignment(PermissionSetId = claimPerSet.id, AssigneeId = extUsr12.Id);
            permissionSetAssignmentList.add(psa12);
            PermissionSetAssignment psa13 = new PermissionSetAssignment(PermissionSetId = pSet1.id, AssigneeId = usr2.Id);
            permissionSetAssignmentList.add(psa13);
            PermissionSetAssignment psa14 = new PermissionSetAssignment(PermissionSetId = pSet2.id, AssigneeId = usr3.Id);
            permissionSetAssignmentList.add(psa14);
            PermissionSetAssignment psa15 = new PermissionSetAssignment(PermissionSetId = pSet3.id, AssigneeId = usr4.Id);
            permissionSetAssignmentList.add(psa15);
            PermissionSetAssignment psa16 = new PermissionSetAssignment(PermissionSetId = pSet4.id, AssigneeId = usr5.Id);
            permissionSetAssignmentList.add(psa16);
            PermissionSetAssignment psa17 = new PermissionSetAssignment(PermissionSetId = pSet1.id, AssigneeId = usr4.Id);
            permissionSetAssignmentList.add(psa17);
            PermissionSetAssignment psa18 = new PermissionSetAssignment(PermissionSetId = pSet1.id, AssigneeId = usr5.Id);
            permissionSetAssignmentList.add(psa18);
            PermissionSetAssignment psa19 = new PermissionSetAssignment(PermissionSetId = pSet1.id, AssigneeId = usr3.Id);
            permissionSetAssignmentList.add(psa19);
            PermissionSetAssignment psa20 = new PermissionSetAssignment(PermissionSetId = pSet1.id, AssigneeId = pctUsr.Id);
            permissionSetAssignmentList.add(psa20);
            
            insert permissionSetAssignmentList;
            
            //Test.startTest();
            List<Core_AGS_Role__c> agsRoleList = new List<Core_AGS_Role__c>();
            
            Core_AGS_Role__c agsRoleIPA = Core_MDF_CCP_TestDataUtility.createAgsRole('IPA_USER', 'Co-Marketing(Salesforce)-IPA USER', true, true);
            
            Core_ERPM_Engagement__c erpmEngagementIPA = Core_MDF_CCP_TestDataUtility.createErpmEngagement('Intel Partner Alliance', 'IPA', '', '', true, true);
            
            Core_Entitlement__c entitlementIPA = Core_MDF_CCP_TestDataUtility.createEntitlement('IPA MDF User',agsRoleIPA.Id ,'Intel Partner Alliance (IPA)','IPA MDF User',erpmEngagementIPA.Id , true,'Solutions Marketplace',true);
            
            List<Core_Contact_Entitlement__c> conEntList = new List<Core_Contact_Entitlement__c>();
            Core_Contact_Entitlement__c contactEntitlementIPA1 = Core_MDF_CCP_TestDataUtility.createContactEntitlement(con.Id,entitlementIPA.Id ,true,'Complete', false);            
            conEntList.add(contactEntitlementIPA1);
            Core_Contact_Entitlement__c contactEntitlementIPA2 = Core_MDF_CCP_TestDataUtility.createContactEntitlement(con1.Id,entitlementIPA.Id ,true,'Complete', false);            
            conEntList.add(contactEntitlementIPA2);
            Core_Contact_Entitlement__c contactEntitlementIPA3 = Core_MDF_CCP_TestDataUtility.createContactEntitlement(con2.Id,entitlementIPA.Id ,true,'Complete', false);            
            conEntList.add(contactEntitlementIPA3);
            Core_Contact_Entitlement__c contactEntitlementIPA4 = Core_MDF_CCP_TestDataUtility.createContactEntitlement(con3.Id,entitlementIPA.Id ,true,'Complete', false);            
            conEntList.add(contactEntitlementIPA4);
            Core_Contact_Entitlement__c contactEntitlementIPA5 = Core_MDF_CCP_TestDataUtility.createContactEntitlement(con4.Id,entitlementIPA.Id ,true,'Complete', false);            
            conEntList.add(contactEntitlementIPA5);
            Core_Contact_Entitlement__c contactEntitlementIPA6 = Core_MDF_CCP_TestDataUtility.createContactEntitlement(con5.Id,entitlementIPA.Id ,true,'Complete', false);            
            conEntList.add(contactEntitlementIPA6);
            Core_Contact_Entitlement__c contactEntitlementIPA7 = Core_MDF_CCP_TestDataUtility.createContactEntitlement(con6.Id,entitlementIPA.Id ,true,'Complete', false);            
            conEntList.add(contactEntitlementIPA7);
            Core_Contact_Entitlement__c contactEntitlementIPA8 = Core_MDF_CCP_TestDataUtility.createContactEntitlement(con7.Id,entitlementIPA.Id ,true,'Complete', false);            
            conEntList.add(contactEntitlementIPA8);
            Core_Contact_Entitlement__c contactEntitlementIPA9 = Core_MDF_CCP_TestDataUtility.createContactEntitlement(con8.Id,entitlementIPA.Id ,true,'Complete', false);            
            conEntList.add(contactEntitlementIPA9);
            Core_Contact_Entitlement__c contactEntitlementIPA10 = Core_MDF_CCP_TestDataUtility.createContactEntitlement(con9.Id,entitlementIPA.Id ,true,'Complete', false);            
            conEntList.add(contactEntitlementIPA10);
            Core_Contact_Entitlement__c contactEntitlementIPA11 = Core_MDF_CCP_TestDataUtility.createContactEntitlement(con10.Id,entitlementIPA.Id ,true,'Complete', false);            
            conEntList.add(contactEntitlementIPA11);
            Database.insert(conEntList);
            
            // Creating Group
            List<Group> grpList = new List<Group>();
            Group ipaExtGrp = new Group();
            ipaExtGrp.Name = 'Core CCP IPA External';
            ipaExtGrp.DeveloperName = 'Core_MDF_CCP_IPA_External';
            grpList.add(ipaExtGrp);
            Group ipaExtGrp1 = new Group();
            ipaExtGrp1.Name = 'Core CCP IPA External1';
            ipaExtGrp1.DeveloperName = 'Core_MDF_CCP_IPA_External1';
            grpList.add(ipaExtGrp1);
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
            
            GroupMember ipaExtGrpMem4 = new GroupMember();
            ipaExtGrpMem4.UserOrGroupId = extUsr4.Id;
            ipaExtGrpMem4.GroupId = ipaExtGrp.Id;
            grpMemList.add(ipaExtGrpMem4);
            
            GroupMember ipaExtGrpMem5 = new GroupMember();
            ipaExtGrpMem5.UserOrGroupId = extUsr5.Id;
            ipaExtGrpMem5.GroupId = ipaExtGrp.Id;
            grpMemList.add(ipaExtGrpMem5);
            
            GroupMember ipaExtGrpMem6 = new GroupMember();
            ipaExtGrpMem6.UserOrGroupId = extUsr6.Id;
            ipaExtGrpMem6.GroupId = ipaExtGrp.Id;
            grpMemList.add(ipaExtGrpMem6);
            
            GroupMember ipaExtGrpMem7 = new GroupMember();
            ipaExtGrpMem7.UserOrGroupId = extUsr7.Id;
            ipaExtGrpMem7.GroupId = ipaExtGrp.Id;
            grpMemList.add(ipaExtGrpMem7);
            
            GroupMember ipaExtGrpMem8 = new GroupMember();
            ipaExtGrpMem8.UserOrGroupId = extUsr8.Id;
            ipaExtGrpMem8.GroupId = ipaExtGrp.Id;
            grpMemList.add(ipaExtGrpMem8);
            
            GroupMember ipaExtGrpMem9 = new GroupMember();
            ipaExtGrpMem9.UserOrGroupId = extUsr9.Id;
            ipaExtGrpMem9.GroupId = ipaExtGrp.Id;
            grpMemList.add(ipaExtGrpMem9);
            
            GroupMember ipaExtGrpMem10 = new GroupMember();
            ipaExtGrpMem10.UserOrGroupId = extUsr10.Id;
            ipaExtGrpMem10.GroupId = ipaExtGrp.Id;
            grpMemList.add(ipaExtGrpMem10);
            
            
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
            pgmExt.Core_MDF_AccountIdGroupName__c = ipaUltimateAccount.Id+'Core_MDF_CCP_IPA_External';
            //pgmList.add(pgmExt);
            Core_MDF_Partner_Group_Mapping__c pgmExt1 = new Core_MDF_Partner_Group_Mapping__c();
            pgmExt1.Core_MDF_Account__c = ipaUltimateAccount.Id;
            pgmExt1.Core_MDF_Group_Name__c = 'Core_MDF_CCP_IPA_External1';
            pgmExt1.Core_MDF_Type_of_Access__c = 'EXTERNAL';
            pgmExt1.Core_MDF_Group_Id__c = ipaExtGrp1.Id;                
            pgmExt1.Core_MDF_Channel_Program__c = ipaCP.Id;
            //pgmExt1.Core_MDF_Source_Txt__c = 'Test1';
            pgmExt1.Core_MDF_Region_cd__C = 'APJ';
            pgmExt1.Core_MDF_AccountIdGroupName__c = ipaUltimateAccount.Id+'Core_MDF_CCP_IPA_External1';
            pgmList.add(pgmExt1);
            Database.insert(pgmList);
            
            
            Map<Id,Set<Id>> userIdCorpAcctIdSet = new Map<Id,Set<Id>>();
            Set<Id> accIdSet = new Set<Id>();
            Set<Id> accIdSet1 = new Set<Id>();
            accIdSet.add(ipaCoMarketingAccount.Id);
            accIdSet1.add(ipaCoMarketingAccount1.Id);
            userIdCorpAcctIdSet.put(extUsr1.Id, accIdSet);
            userIdCorpAcctIdSet.put(extUsr2.Id, accIdSet);
            userIdCorpAcctIdSet.put(extUsr3.Id, accIdSet);
            userIdCorpAcctIdSet.put(extUsr4.Id, accIdSet);
            userIdCorpAcctIdSet.put(extUsr5.Id, accIdSet);
            userIdCorpAcctIdSet.put(extUsr6.Id, accIdSet);
            userIdCorpAcctIdSet.put(extUsr7.Id, accIdSet);
            userIdCorpAcctIdSet.put(extUsr8.Id, accIdSet);
            userIdCorpAcctIdSet.put(extUsr9.Id, accIdSet);
            userIdCorpAcctIdSet.put(extUsr10.Id, accIdSet);
            userIdCorpAcctIdSet.put(pctUsr.Id, accIdSet1);
            //Core_MDF_IPA_AccountUserMapping.createPnumRecords(userIdCorpAcctIdSet);
            
            User usr1 = Core_MDF_CCP_TestDataUtility.createUser(false);
            usr1.LastName = 'User Test1';
            Database.insert(usr1);
            
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
                                                                                               '2',false);
            
            crList.add(crule1); 
            crList.add(crule2); 
            crList.add(crule3);
            Database.insert(crList);
            
            List<Core_MDF_Approver__c> toBeUpdatedAP = new List <Core_MDF_Approver__c>();
            ap1.Core_MDF_Active__c = True;
            toBeUpdatedAP.add(ap1);
            ap2.Core_MDF_Active__c = True;
            toBeUpdatedAP.add(ap2);
            Database.update(toBeUpdatedAP);
            
            cr.Core_MDF_Active__c = True;
            Database.update(cr);
            try{
                Core_MDF_CampaignPFR_Controller.getActivityRecords(null);
                Core_MDF_CampaignPFR_Controller.isAccountBased(null);
            }catch(Exception e){
            }
            
            Test.stopTest();   
	    
	    // CoGTM Data creation
            Id pmb_RecordType_CoGTM = Schema.SObjectType.PartnerMarketingBudget.getRecordTypeInfosByDeveloperName().get('Core_MDF_Co_GTM').getRecordTypeId();
            Id pfa_RecordType_CoGTM = Schema.SObjectType.PartnerFundAllocation.getRecordTypeInfosByDeveloperName().get('Core_MDF_Co_GTM').getRecordTypeId();
            Id campaign_RecordType_CoGTM = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Core_MDF_Co_GTM').getRecordTypeId();
            Id pfr_RecordType_CoGTM = Schema.SObjectType.PartnerFundRequest.getRecordTypeInfosByDeveloperName().get('Core_MDF_Co_GTM').getRecordTypeId();
            Id pfc_RecordType_CoGTM = Schema.SObjectType.PartnerFundClaim.getRecordTypeInfosByDeveloperName().get('Core_MDF_Co_GTM').getRecordTypeId();
            
            PartnerMarketingBudget  coGTMPMB = Core_MDF_CCP_TestDataUtility.createBudget('CoGTMPMB', pmb_RecordType_CoGTM, coGTMCoMarketingAccount.Id, coGTMCP.Id, 1000000, System.today().addDays(-10), System.today().addDays(40),false);
            coGTMPMB.Core_MDF_Budget_Type_Txt__c = 'Co-Engineering';
            insert coGTMPMB;
            
            PartnerFundAllocation coGTMPFA = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('CoGTMPFA',coGTMPMB,coGTMCoMarketingAccount,100000.0,true);

            Campaign coGTMCampaign = new Campaign();
            coGTMCampaign.Name = 'Test CoGTM Camp';
            coGTMCampaign.Core_MDF_Opal_Budget_Type_Txt__c = 'Co-Engineering';
            coGTMCampaign.Core_MDF_Proposal_Based_Ind__c = true;
            coGTMCampaign.Core_MDF_Program__c = 'CoGTM';
            coGTMCampaign.Status = 'Draft';
            coGTMCampaign.Core_MDF_Account__c = coGTMCoMarketingAccount.id;
            coGTMCampaign.RecordTypeId = campaign_RecordType_CoGTM;
            coGTMCampaign.StartDate = System.today().addDays(-5);
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
            coGTMPFR.Core_MDF_Start_Date__c=System.today().addDays(-5);
            coGTMPFR.Core_MDF_End_Date__c =System.today().addDays(2);
            coGTMPFR.Title ='Test CoGTM PFR';
            coGTMPFR.Status = 'Draft';
            coGTMPFR.Core_MDF_Reimbursement_Rate_txt__c = '100%';
            coGTMPFR.RequestedAmount = 1000200;
            coGTMPFR.AllocationId = coGTMPFA.Id;
            coGTMPFR.BudgetId = coGTMPMB.Id;
            Database.insert(coGTMPFR);

		PartnerFundClaim coGTMPFC = new PartnerFundClaim();
            coGTMPFC.RequestId = coGTMPFR.Id;
            coGTMPFC.RecordTypeId = pfc_RecordType_CoGTM;
            coGTMPFC.amount = 50;
            coGTMPFC.Core_MDF_Status__c = 'Submitted';
            coGTMPFC.Core_MDF_Invoice_Date__c = System.today().addDays(-4);
            coGTMPFC.Core_MDF_Invoice_Number__c = 'INV1686';
            coGTMPFC.Core_MDF_Media_Vehicle__c = 'Test';
            coGTMPFC.Core_MDF_OtherCostsnotReimbursable_Local__c = 0;
            coGTMPFC.Core_MDF_Taxes_Local__c = 12;
            coGTMPFC.Core_MDF_Total_Invoice_Amount_Local__c = 50;
            coGTMPFC.Core_MDF_Ad_Run_Start_Date__c = System.today().addDays(-4);
            coGTMPFC.Core_MDF_Ad_Run_End_Date__c = System.today().addDays(-4);
            coGTMPFC.Title = 'Test CoGTM PFC';
            coGTMPFC.Core_MDF_Currency__c = 'USD';        
            coGTMPFC.Description = 'Test';
            coGTMPFC.Core_MDF_Country_Location_nm__c= 'BRAZIL';
            coGTMPFC.Core_MDF_Reimbursable_Transaction_Amount__c=100;
            coGTMPFC.Core_MDF_Processing_Preference_nm__c = 'Get paid, then settle';
            Database.insert(coGTMPFC);        
            
        }
    }
    
    
    @isTest 
    static void checkPCTCustomPermAssigned(){
        User testUser = [SELECT Id FROM User WHERE LastName = 'User Test11' limit 1];
        system.runAs(testUser){
            Boolean isCPAssigned = Core_MDF_CampaignPFR_Controller.isCustomPermissionAssigned('Core_MDF_PriceReviewer');
            Assert.areEqual(isCPAssigned,true);    
        }
    }

    @isTest 
    static void rejectionScenerio_Part1() {
        Test.startTest(); 

        Id campaign_RecordType_IPA = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Core_MDF_Intel_Partner_Alliance').getRecordTypeId();
        User testUser4 = [SELECT Id FROM User WHERE LastName = 'User Test155' limit 1];
        Account ipaCoMarketingAccount = [select id,Core_MDF_Parent_Fund_Account__c,Core_MDF_Channel_Program__c from Account where Name= 'IPA Co-Marketing Account'];

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
        ipaCampaign3.Core_MDF_Approval_Stage_nm__c = 'Program Office Reviewer';
        ipaCampaign3.Core_MDF_Account__c = ipaCoMarketingAccount.id;
        ipaCampaign3.RecordTypeId = campaign_RecordType_IPA;
        ipaCampaign3.Core_MDF_IPA_Approval_Status_nm__c = '';
        insert ipaCampaign3;

        List<ProcessInstanceWorkitem> piwitmIds = [SELECT Id FROM ProcessInstanceWorkitem limit 1];
        Id piwitmId = piwitmIds[0].Id;

        system.runAs(testUser4){
            Core_MDF_CampaignPFR_Controller.loadCampRecord(ipaCampaign3.Id);
            Core_MDF_CampaignPFR_Controller.approveRejectProposal('Reject',ipaCampaign3.Id,'Rejected',piwitmId,false);
        }

        Test.stopTest();
    }

    @isTest 
    static void rejectionScenerio_Part2() {
        Test.startTest(); 

        Id campaign_RecordType_IPA = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Core_MDF_Intel_Partner_Alliance').getRecordTypeId();
        User testUser2 = [SELECT Id FROM User WHERE LastName = 'User Test133' limit 1];
        User testUser3 = [SELECT Id FROM User WHERE LastName = 'User Test144' limit 1];
        Account ipaCoMarketingAccount = [select id,Core_MDF_Parent_Fund_Account__c,Core_MDF_Channel_Program__c from Account where Name= 'IPA Co-Marketing Account'];

        Campaign ipaCampaign4 = new Campaign();
        ipaCampaign4.Name = 'Test Data12';
        ipaCampaign4.Core_MDF_Approval_Stage_nm__c = 'L2 Regional Marketing';
        ipaCampaign4.Core_MDF_Reimbursement_Rate__c = '100%';
        ipaCampaign4.Description = 'IPA Campaign Description';
        ipaCampaign4.Core_MDF_Region_cd__c = 'ASMO';
        ipaCampaign4.Core_MDF_Sub_Region_cd__c = 'NAR';
        ipaCampaign4.Core_MDF_Budget_Type_txt__c = 'Proposal I MDF';
        ipaCampaign4.Core_MDF_Proposal_Based_Ind__c = true;
        ipaCampaign4.Core_MDF_Program__c = 'Intel Partner Alliance';
        ipaCampaign4.Core_MDF_Market__c = 'AFGHANISTAN';
        ipaCampaign4.Status = 'Pending Review';
        ipaCampaign4.Core_MDF_Account__c = ipaCoMarketingAccount.id;
        ipaCampaign4.RecordTypeId = campaign_RecordType_IPA;
        ipaCampaign4.Core_MDF_IPA_Approval_Status_nm__c = '';
        insert ipaCampaign4;

        Campaign ipaCampaign5 = new Campaign();
        ipaCampaign5.Name = 'Test Data12';
        ipaCampaign5.Core_MDF_Approval_Stage_nm__c = 'L2 Regional Sales';
        ipaCampaign5.Core_MDF_Reimbursement_Rate__c = '100%';
        ipaCampaign5.Description = 'IPA Campaign Description';
        ipaCampaign5.Core_MDF_Region_cd__c = 'ASMO';
        ipaCampaign5.Core_MDF_Sub_Region_cd__c = 'NAR';
        ipaCampaign5.Core_MDF_Budget_Type_txt__c = 'Proposal I MDF';
        ipaCampaign5.Core_MDF_Proposal_Based_Ind__c = true;
        ipaCampaign5.Core_MDF_Program__c = 'Intel Partner Alliance';
        ipaCampaign5.Core_MDF_Market__c = 'AFGHANISTAN';
        ipaCampaign5.Status = 'Pending Review';
        ipaCampaign5.Core_MDF_Account__c = ipaCoMarketingAccount.id;
        ipaCampaign5.RecordTypeId = campaign_RecordType_IPA;
        ipaCampaign5.Core_MDF_IPA_Approval_Status_nm__c = '';
        insert ipaCampaign5;

        List<ProcessInstanceWorkitem> piwitmIds = [SELECT Id FROM ProcessInstanceWorkitem limit 1];
        Id piwitmId = piwitmIds[0].Id;

        system.runAs(testUser2){
            Core_MDF_CampaignPFR_Controller.loadCampRecord(ipaCampaign4.Id);
            Core_MDF_CampaignPFR_Controller.approveRejectProposal('Recall',ipaCampaign4.Id,' ',piwitmId,false);
        }

        system.runAs(testUser3){
            Core_MDF_CampaignPFR_Controller.loadCampRecord(ipaCampaign5.Id);
            Core_MDF_CampaignPFR_Controller.approveRejectProposal('Reject',ipaCampaign5.Id,'Rejected',piwitmId,false);
        }

        Test.stopTest();
    }
    
    @isTest 
    static void ApprovalScenarios() {
        Test.startTest();
        User testUser  = [SELECT Id FROM User WHERE LastName = 'User Test11'  LIMIT 1];
        User testUser1 = [SELECT Id FROM User WHERE LastName = 'User Test122' LIMIT 1];
        User testUser2 = [SELECT Id FROM User WHERE LastName = 'User Test133' LIMIT 1];
        User testUser4 = [SELECT Id FROM User WHERE LastName = 'User Test155' LIMIT 1];
    
        Account ipaCoMarketingAccount = [SELECT Id FROM Account WHERE Name = 'IPA Co-Marketing Account' LIMIT 1];
        
        String budgetType = 'Proposal I MDF';
        Date startDate = System.today();
        Date endDate   = System.today().addDays(30);
    
        List<Campaign> campaignList = new List<Campaign>{
            Core_MDF_CCP_IPA_TestDataUtility.createIPACampaign('Camp 1', ipaCoMarketingAccount.Id, startDate, endDate, budgetType, 100000, 'INDIA', 'Developer', 'Apollo Lake', 'Draft', false),
            Core_MDF_CCP_IPA_TestDataUtility.createIPACampaign('Camp 2', ipaCoMarketingAccount.Id, startDate, endDate, budgetType, 100000, 'INDIA', 'Developer', 'Apollo Lake', 'Draft', false),
            Core_MDF_CCP_IPA_TestDataUtility.createIPACampaign('Camp 3', ipaCoMarketingAccount.Id, startDate, endDate, budgetType, 100000, 'INDIA', 'Developer', 'Apollo Lake', 'Draft', false),
            Core_MDF_CCP_IPA_TestDataUtility.createIPACampaign('Camp 4', ipaCoMarketingAccount.Id, startDate, endDate, budgetType, 100000, 'INDIA', 'Developer', 'Apollo Lake', 'Draft', false),
            Core_MDF_CCP_IPA_TestDataUtility.createIPACampaign('Camp 5', ipaCoMarketingAccount.Id, startDate, endDate, budgetType, 100000, 'INDIA', 'Developer', 'Apollo Lake', 'Draft', false)
        };
    
        campaignList[0].Status = 'Pending Review'; campaignList[0].Core_MDF_Approval_Stage_nm__c = 'Price Reviewer';
        campaignList[1].Status = 'Pending Review'; campaignList[1].Core_MDF_Approval_Stage_nm__c = 'L2 Regional Sales';
        campaignList[2].Status = 'Pending Review'; campaignList[2].Core_MDF_Approval_Stage_nm__c = 'L1 Approval';
        campaignList[3].Status = 'Pending Review'; campaignList[3].Core_MDF_Approval_Stage_nm__c = 'Program Office Reviewer';
        campaignList[4].Status = 'Pending Review'; campaignList[4].Core_MDF_Approval_Stage_nm__c = 'L2 Regional Marketing';
        insert campaignList;
    
        List<Campaign> cmpUpd = new List<Campaign>();
        for (Campaign camp : campaignList) {
            cmpUpd.add(camp);
        }
        Map<Id,Campaign> oldMap = new Map<Id,Campaign>{ campaignList[0].Id => campaignList[0] };
    
        Core_MDF_Proposal_Based_Campaign_Process.onSubmitForApproval(cmpUpd, oldMap);
        Core_MDF_Proposal_Based_Campaign_Process.callApprovalProcess(cmpUpd, oldMap);
  
        Core_MDF_CampaignPFR_Controller.loadCampRecord(campaignList[0].Id);
    
        List<ProcessInstanceWorkitem> piwitmIds = [SELECT Id FROM ProcessInstanceWorkitem limit 1];
        Id piwitmId = piwitmIds[0].Id;
    
        System.runAs(testUser) {
            Core_MDF_CampaignPFR_Controller.approveRejectProposal('Approve', campaignList[0].Id, 'Approved', piwitmId, false);
        }
        System.runAs(testUser1) {
            Core_MDF_CampaignPFR_Controller.approveRejectProposal('Approve', campaignList[1].Id, 'Approved', piwitmId, false);
        }
        System.runAs(testUser2) {
            Core_MDF_CampaignPFR_Controller.approveRejectProposal('Approve', campaignList[2].Id, 'Approved', piwitmId, false);
        }
        System.runAs(testUser4) {
            Core_MDF_CampaignPFR_Controller.approveRejectProposal('Approve', campaignList[3].Id, 'Approved', piwitmId, false);
        }
    
        Test.stopTest();
    }
    
    @isTest 
    static void externalApproval(){
        
        Test.startTest(); 
        Account ipaCoMarketingAccount = [select id,Core_MDF_Parent_Fund_Account__c,Core_MDF_Channel_Program__c 
                                         from Account
                                         where Name= 'IPA Co-Marketing Account'];
        
        string budgetType = Core_MDF_CCP_IPA_TestDataUtility.createBenefit(ipaCoMarketingAccount);                                 
        budgetType = 'Proposal I MDF';
        Campaign ipaCampaign = Core_MDF_CCP_IPA_TestDataUtility.createIPACampaign('Test Campaign - AP',
                                                                                  ipaCoMarketingAccount.id, 
                                                                                  System.today(), System.today().adddays(30),
                                                                                  budgetType, 110000,'INDIA', 'Developer', 
                                                                                  'Apollo Lake', 'Draft', false); 
        ipaCampaign.Status = 'Pending Approval';
        ipaCampaign.Core_MDF_Approval_Step_Counter_nbr__c = 4;
        ipaCampaign.Core_MDF_Activity_Category_Type__c = 'Digital 2025->Web Content';
        database.insert(ipaCampaign);
        
        List<Campaign> cmpUpd = new List<Campaign>();
        cmpUpd.add(ipaCampaign); 
        
        Map<Id,Campaign> campOldMap = new Map<Id,Campaign>();
        campOldMap.put(ipaCampaign.Id, ipaCampaign);
        Core_MDF_Proposal_Based_Campaign_Process.onSubmitForApproval(cmpUpd,campOldMap);
        Core_MDF_Proposal_Based_Campaign_Process.callApprovalProcess(cmpUpd,campOldMap);
        Assert.areEqual('Digital 2025->Web Content',ipaCampaign.Core_MDF_Activity_Category_Type__c);
        Core_MDF_CampaignPFR_Controller.loadCampRecord(ipaCampaign.Id);
        List<ProcessInstanceWorkitem> piwitmIds = [SELECT Id FROM ProcessInstanceWorkitem limit 1];
        Id piwitmId = ipaCampaign.Id;//'04hDz000001PUCaIAO';
        Approval.ProcessSubmitRequest app = new Approval.ProcessSubmitRequest();
        app.setObjectId(ipaCampaign.id);
        //Approval.ProcessResult result = Approval.process(app);
        

        Core_MDF_CampaignPFR_Controller.approveRejectProposal('Approve',ipaCampaign.Id,'Approved',piwitmId,false);
        ChannelProgram cp = Core_MDF_CCP_TestDataUtility.createProgram (Core_MDF_CCP_ConstantClass.CCF_PROGRAM,'Client CoMarketing Fund', true);
        //List<Account> accList = new List<Account>();
        Account acc1 = Core_MDF_CCP_TestDataUtility.createIntelAccount('Test Account 1', 
                                                                       Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
        
        Account acc2 = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test Account 2',
                                                                             cp.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, 
                                                                             acc1.Id, false);
        Test.stopTest();        
    }
    
    
    @isTest 
    static void loadCampRecord(){
        
        Test.startTest(); 
        Account ipaCoMarketingAccount = [select id,Core_MDF_Parent_Fund_Account__c,Core_MDF_Channel_Program__c 
                                         from Account
                                         where Name= 'IPA Co-Marketing Account'];
        
        string budgetType = Core_MDF_CCP_IPA_TestDataUtility.createBenefit(ipaCoMarketingAccount);                                 
        budgetType = 'Proposal I MDF';
        Campaign ipaCampaign = Core_MDF_CCP_IPA_TestDataUtility.createIPACampaign('Test Campaign - AP',
                                                                                  ipaCoMarketingAccount.id, 
                                                                                  System.today(), System.today().adddays(30),
                                                                                  budgetType, 110000,'INDIA', 'Consumer', 
                                                                                  'Apollo Lake', 'Pending Approval', false); 
        ipaCampaign.Core_MDF_Approval_Step_Counter_nbr__c = 4;
        ipaCampaign.Status = 'Pending Approval';
        ipaCampaign.RecordTypeId = ipaCampaignRecordId;
        database.insert(ipaCampaign);
        List<ProcessInstanceWorkitem> piwitmIds = [SELECT Id FROM ProcessInstanceWorkitem limit 1];
        Id piwitmId = ipaCampaign.Id;//'04hDz000001PUCaIAO';
		Assert.areEqual(ipaCampaign.Core_MDF_Opal_Budget_Type_Txt__c,budgetType);
        

        Core_MDF_CampaignPFR_Controller.loadCampRecord(ipaCampaign.Id);
        Core_MDF_CampaignPFR_Controller.approveRejectProposal('Approve',ipaCampaign.Id,'Approved',piwitmId,false);
        Core_MDF_CampaignPFR_Controller.approveRejectProposal('Reject',ipaCampaign.Id,'Rejected',piwitmId,false);
        
        
        Test.stopTest();
    }
    
    @isTest 
    static void externalApprovalForElse(){
        
        Test.startTest(); 
        Account ipaCoMarketingAccount1 = [select id,Core_MDF_Parent_Fund_Account__c,Core_MDF_Channel_Program__c 
                                          from Account
                                          where Name= 'IPA Co-Marketing Account2'];
        string budgetType = Core_MDF_CCP_IPA_TestDataUtility.createBenefit(ipaCoMarketingAccount1);                                 
        budgetType = 'Proposal I MDF';
        Campaign ipaCampaign1 = Core_MDF_CCP_IPA_TestDataUtility.createIPACampaign('Test Campaign - AP1',
                                                                                   ipaCoMarketingAccount1.id, 
                                                                                   System.today(), System.today().adddays(30),
                                                                                   budgetType, 110000,'INDIA', 'Developer', 
                                                                                   'Apollo Lake', 'Draft', false);   
        
        ipaCampaign1.Core_MDF_Approval_Step_Counter_nbr__c = 4;
        ipaCampaign1.Core_MDF_Activity_Category_Type__c = 'Digital 2025->Web Content';
        database.insert(ipaCampaign1);
        
        List<Campaign> cmpUpd = new List<Campaign>();
        cmpUpd.add(ipaCampaign1);
        
        Map<Id,Campaign> campOldMap = new Map<Id,Campaign>();
        campOldMap.put(ipaCampaign1.Id, ipaCampaign1);
        Core_MDF_Proposal_Based_Campaign_Process.onSubmitForApproval(cmpUpd,campOldMap);
        Core_MDF_Proposal_Based_Campaign_Process.callApprovalProcess(cmpUpd,campOldMap);
        Assert.areEqual('Digital 2025->Web Content',ipaCampaign1.Core_MDF_Activity_Category_Type__c);
        
        Core_MDF_CampaignPFR_Controller.getActivityRecords(ipaCampaign1.Id);
        Core_MDF_CampaignPFR_Controller.checkUserType(true);
        ipaCampaign1.Core_MDF_Proposal_Based_Ind__c = true;
        update ipaCampaign1;
        Core_MDF_CampaignPFR_Controller.isAccountBased(ipaCampaign1.Id);
        
        
        Test.stopTest();
    }
    
    @isTest
    static void displayActivityTest(){
        
        User testUser = [SELECT Id FROM User WHERE LastName = 'User Test9'];
        
        system.runAs(testUser){
            Core_MDF_CampaignPFR_Controller.EditActivityWrapper wrapper = Core_MDF_CampaignPFR_Controller.checkUserType(true);
            Assert.areEqual(TRUE, wrapper.activityEditAccess);
            Assert.areEqual(FALSE, wrapper.claimCreateAccess);
        }
        
        User testClaimUser = [SELECT Id FROM User WHERE LastName = 'User Test12'];
        system.runAs(testClaimUser){
            Core_MDF_CampaignPFR_Controller.EditActivityWrapper wrapper = Core_MDF_CampaignPFR_Controller.checkUserType(true);
            Assert.areEqual(FALSE, wrapper.activityEditAccess);
            Assert.areEqual(FALSE, wrapper.claimCreateAccess);
        }
        
        PermissionSet ipaProposalMDFPermissionSet = [SELECT Id, Name FROM PermissionSet where Name = 'Core_MDF_CCP_IPA_Proposal_MDF'];        
        PermissionSetAssignment  psa = new PermissionSetAssignment(PermissionSetId = ipaProposalMDFPermissionSet.Id, AssigneeId = testClaimUser.Id);
        insert psa;
        system.runAs(testClaimUser){
            Core_MDF_CampaignPFR_Controller.EditActivityWrapper wrapper = Core_MDF_CampaignPFR_Controller.checkUserType(true);
            Assert.areEqual(FALSE, wrapper.activityEditAccess);
            Assert.areEqual(TRUE, wrapper.claimCreateAccess);
        }        
    }
    
    @isTest 
    static void loadClaimRecordTestRecall(){
        User usr = [Select Id, lastName from User where lastName = 'SystemAdmin' limit 1];

        System.runAs(usr){ 
            test.startTest();
            PartnerFundClaim coGTMPFC = [SELECT Id FROM PartnerFundClaim WHERE Title = 'Test CoGTM PFC' LIMIT 1];

            coGTMPFC.Core_MDF_Status__c = 'Pending Review';
            coGTMPFC.Core_MDF_Approval_Stage_nm__c = 'Technical Approver';
            coGTMPFC.Core_MDF_Approval_Step_Counter_nbr__c = 1;
            update coGTMPFC;
            
            List<ProcessInstanceWorkitem> piwitmIds = [SELECT Id FROM ProcessInstanceWorkitem limit 1];
        	Id piwitmId = piwitmIds[0].Id;
            
            Core_MDF_CampaignPFR_Controller.loadCampRecord(coGTMPFC.Id);
            Core_MDF_CampaignPFR_Controller.approveRejectProposal('Recall',coGTMPFC.Id,'Recalled',piwitmId,false);
			test.stopTest();
            
        } 
    }
    
    @isTest 
    static void loadClaimRecordTestReject(){
        User usr = [Select Id, lastName from User where lastName = 'SystemAdmin' limit 1];

        System.runAs(usr){ 
            test.startTest();
            PartnerFundClaim coGTMPFC = [SELECT Id FROM PartnerFundClaim WHERE Title = 'Test CoGTM PFC' LIMIT 1];

            coGTMPFC.Core_MDF_Status__c = 'Pending Review';
            coGTMPFC.Core_MDF_Approval_Stage_nm__c = 'Technical Approver';
            coGTMPFC.Core_MDF_Approval_Step_Counter_nbr__c = 1;
            update coGTMPFC;
            
            List<ProcessInstanceWorkitem> piwitmIds = [SELECT Id FROM ProcessInstanceWorkitem limit 1];
        	Id piwitmId = piwitmIds[0].Id;
            
            Core_MDF_CampaignPFR_Controller.loadCampRecord(coGTMPFC.Id);
            Core_MDF_CampaignPFR_Controller.approveRejectProposal('Reject',coGTMPFC.Id,'Rejected',piwitmId,false);
			test.stopTest();
            
        } 
    }
    
    @isTest 
    static void loadClaimRecordTestApprove(){
        User usr = [Select Id, lastName from User where lastName = 'SystemAdmin' limit 1];

        System.runAs(usr){ 
            test.startTest();
            PartnerFundClaim coGTMPFC = [SELECT Id FROM PartnerFundClaim WHERE Title = 'Test CoGTM PFC' LIMIT 1];

            coGTMPFC.Core_MDF_Status__c = 'Pending Review';
            coGTMPFC.Core_MDF_Approval_Stage_nm__c = 'Technical Approver';
            coGTMPFC.Core_MDF_Approval_Step_Counter_nbr__c = 1;
            update coGTMPFC;
            
            List<ProcessInstanceWorkitem> piwitmIds = [SELECT Id FROM ProcessInstanceWorkitem limit 1];
        	Id piwitmId = piwitmIds[0].Id;
            
            Core_MDF_CampaignPFR_Controller.loadCampRecord(coGTMPFC.Id);
            Core_MDF_CampaignPFR_Controller.approveRejectProposal('Approve',coGTMPFC.Id,'Approved',piwitmId,false);
			test.stopTest();
            
        } 
    }
}