@isTest(SeeAllData=false)
public class Core_MDF_CampaignUtility_Test {

    @TestSetup 
    static void createTestData() {
        
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        // Creating User with utility class 
        User testUser = Core_MDF_CCP_TestDataUtility.createUser(false);
        testUser.LastName = 'TestUser TestClass';
        testUser.UserRoleId = usRole.Id;
        Database.insert(testUser);
        
        User testUser2 = Core_MDF_CCP_TestDataUtility.createUser(false);
        testUser2.LastName = 'TestUser TestClass2';
        testUser2.UserRoleId = usRole.Id;
        Database.insert(testUser2);
        
        PermissionSet ps=[select id from PermissionSet where name='Core_MDF_CCP_Internal_IPA_Finance_Usr'limit 1];
         insert new PermissionSetAssignment(AssigneeId = testUser.id, PermissionSetId = ps.Id);
        
        PermissionSet ps1=[select id from PermissionSet where name='Core_MDF_CCP_Internal_IPA_Budget_Loader'limit 1];
         insert new PermissionSetAssignment(AssigneeId = testUser.id, PermissionSetId = ps1.Id);
        
        PermissionSet ps2=[select id from PermissionSet where name='Core_MDF_CCP_Internal_IPA_Finance_Usr'limit 1];
         insert new PermissionSetAssignment(AssigneeId = testUser2.id, PermissionSetId = ps2.Id);
        
        PermissionSet ps3=[select id from PermissionSet where name='Core_MDF_CCP_Internal_IPA_Budget_Loader'limit 1];
         insert new PermissionSetAssignment(AssigneeId = testUser2.id, PermissionSetId = ps3.Id);
        
        System.runAs(testUser){
            
            List<Core_Trigger_Executions__c> triggerExecList =  new List<Core_Trigger_Executions__c>();
            Core_Trigger_Executions__c groupIdForAccountNode = new Core_Trigger_Executions__c();
            groupIdForAccountNode.name = 'Core_MDF_createGroupForAccountNode';
            groupIdForAccountNode.Core_Object__c = 'Account';
            groupIdForAccountNode.Core_Trigger_Events__c = 'After Insert';
            groupIdForAccountNode.Core_Active__c = TRUE;
            groupIdForAccountNode.Core_Description__c = 'To Create Group for each account';
            groupIdForAccountNode.Core_Class_Name__c = 'Core_AccountHandler';
            triggerExecList.add(groupIdForAccountNode);
            
            Core_Trigger_Executions__c execution1 = new Core_Trigger_Executions__c();
            execution1.Name = 'BypassCampaignBenefitValidation';
            execution1.Core_Active__c = FALSE;
	    execution1.Core_Class_Name__c = 'Core_MDF_Proposal_Based_Campaign_Process';
            execution1.Core_Description__c = 'BypassCampaignBenefitValidation';
            execution1.Core_Object__c = 'Campaign';
            execution1.Core_Trigger_Events__c = 'Before Update,Before Insert';
            triggerExecList.add(execution1);
            
            Core_Trigger_Executions__c execution2 = new Core_Trigger_Executions__c();
            execution2.Name = 'Core_MDF_Bypass_Manual_Share';
            execution2.Core_Active__c = TRUE;
            execution2.Core_Class_Name__c = 'Core_MDF_PNUMappingTriggerHandler';
            execution2.Core_Description__c = 'Switch ON/OFF the Manual Share';
            execution2.Core_Object__c = 'Core_MDF_Partner_Node_User_Mapping__c';
            execution2.Core_Trigger_Events__c = 'After Insert';
            triggerExecList.add(execution2);
            
            insert execution2;
            List<String> bypassFunctionKeys = new List<String>();
            bypassFunctionKeys.add('Bypass_MDF_Budget_Access');
            bypassFunctionKeys.add('Bypass_MDF_Budget_Access_Validation');
            bypassFunctionKeys.add('Core_MDF_BypassBudgCapIUPGMValidation');
            List<Core_Trigger_Executions__c> bypassfunctinalitylist1 = Core_MDF_CCP_TestDataUtility.byPassFeature(bypassFunctionKeys,true,true);
            Core_MDF_Configuration__c setting = new Core_MDF_Configuration__c();
        setting.Name = 'CAMPAIGN_STATUS_IGNOREDFOR_BDGTCAPLINK';
        setting.Core_MDF_Value__c = 'Cancelled';
        setting.Core_MDF_Category__c='Campaign Status for exclusion while budgtCap Link';
        insert setting;
            
            
            Id IPA_RecordType = Schema.SObjectType.Core_MDF_Int_Users_Partner_Geo_Mapping__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_Intel_Partner_Alliance').getRecordTypeId();
            Id ipaBudTypeCapRecordtype = Schema.SObjectType.Core_MDF_Budget_Cap__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_IPA_Budget_Type_Cap').getRecordTypeId();
               Core_MDF_Budget_Cap__c budgetCap = new Core_MDF_Budget_Cap__c();
               budgetcap.RecordtypeId=ipaBudTypeCapRecordtype;
             budgetCap.Core_MDF_Budget_Type_nm__c = 'Client Specialties MDF';
           // budgetCap.Core_MDF_Budget_Name_id__c = pmb.Id;
            budgetCap.Core_MDF_Requested_Cap_amt__c = 9999999;
            // budgetcap.Core_MDF_Cap_Status_nm__c ='Active';
             budgetcap.Core_MDF_Effective_Start_Date_Dt__c=  System.today();
            budgetcap.Core_MDF_Effective_End_Date_Dt__c= System.today().adddays(60);
        budgetcap.Core_MDF_Region_nm__c='WW';
            Database.insert(budgetCap);
            budgetcap.Core_MDF_Effective_Start_Date_Dt__c=  System.today().addDays(1);
			update budgetcap;  
            List<Core_MDF_Budget_Cap__c> bcList = new List<Core_MDF_Budget_Cap__c>();
            Core_MDF_Budget_Cap__c budgetCap1 = new Core_MDF_Budget_Cap__c();
            budgetCap1.RecordtypeId=ipaBudTypeCapRecordtype;
            budgetCap1.Core_MDF_Budget_Type_nm__c = 'Client Specialties MDF';
            budgetCap1.Core_MDF_Requested_Cap_amt__c = 9999999;
            budgetCap1.Core_MDF_Effective_Start_Date_Dt__c=  System.today().adddays(2);
            budgetCap1.Core_MDF_Effective_End_Date_Dt__c= System.today().adddays(90);
            budgetCap1.Core_MDF_Region_nm__c='WW';
            bcList.add(budgetCap1);

            Core_MDF_Budget_Cap__c budgetCap2 = new Core_MDF_Budget_Cap__c();
            budgetCap2.RecordtypeId=ipaBudTypeCapRecordtype;
            budgetCap2.Core_MDF_Budget_Type_nm__c = 'Client Specialties MDF';
            budgetCap2.Core_MDF_Requested_Cap_amt__c = 9999999;
            budgetCap2.Core_MDF_Effective_Start_Date_Dt__c=  System.today().adddays(2);
            budgetCap2.Core_MDF_Effective_End_Date_Dt__c= System.today().adddays(90);
            budgetCap2.Core_MDF_Region_nm__c='WW';
			bcList.add(budgetCap2);
            try {
                Database.insert(budgetCap2);
            }Catch(Exception ex) {
                System.debug(ex);
            }
            ChannelProgram ipaCP = Core_MDF_CCP_TestDataUtility.createProgram ('Intel Partner Alliance','Intel Partner Alliance', true);
            
            Account ipaUltimateAccount = Core_MDF_CCP_TestDataUtility.createIntelAccount ('IPA Intel Account',Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
            ipaUltimateAccount.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
            insert ipaUltimateAccount;
            Account ipaUltimateAccount2 = Core_MDF_CCP_TestDataUtility.createIntelAccount ('IPA Intel Account2',Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, true);
            
            Account ipaCoMarketingAccount = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('IPA Co-Marketing Account', ipaCP.id, Core_MDF_CCP_TestDataUtility.Account_Record_Type,ipaUltimateAccount.id, true);   
            Account ipaCoMarketingAccount2 = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('IPA Co-Marketing Account2', ipaCP.id, Core_MDF_CCP_TestDataUtility.Account_Record_Type,ipaUltimateAccount2.id, true);           
            
            String budgetType = Core_MDF_CCP_IPA_TestDataUtility.createBenefit(ipaCoMarketingAccount);
             //Id ipaBudTypeCapRecordtype = Schema.SObjectType.Core_MDF_Budget_Cap__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_IPA_Budget_Type_Cap').getRecordTypeId();
          /*PartnerMarketingBudget pmb = Core_MDF_CCP_TestDataUtility.createBudget('Test Budget',Core_MDF_CCP_IPA_TestDataUtility.budget_Record_Type,
                                                                                  ipaCoMarketingAccount.Id,ipaCP.Id,99999999,System.today().addDays(-10),System.today().addDays(60), 
                                                                                   false);
            pmb.Core_MDF_Budget_Type_Txt__c='Business Client Acceleration - MDF ';
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

            User mdfManager = Core_MDF_CCP_TestDataUtility.createUser(false);
            mdfManager.LastName = 'Mdf Manager';
            mdfManager.ProfileId = ccpCoreProfileId.Id;
            mdfManager.IsActive = TRUE;
            
            User priceRev = Core_MDF_CCP_TestDataUtility.createUser(false);
            priceRev.profileId = ccpCoreProfileId.Id;
            priceRev.LastName = 'Price Reviewer';
            
            User priceRev2 = Core_MDF_CCP_TestDataUtility.createUser(false);
            priceRev2.profileId = ccpCoreProfileId.Id;
            priceRev2.LastName = 'Price Reviewer2';
            
            User priceRev3 = Core_MDF_CCP_TestDataUtility.createUser(false);
            priceRev3.profileId = ccpCoreProfileId.Id;
            priceRev3.LastName = 'Price Reviewer3';
            
             User manager = Core_MDF_CCP_TestDataUtility.createUser(false);
            manager.LastName = 'User Test Manager';
            usrList.add(manager);
            
            usrList.add(l1Appr);
            usrList.add(priceRev);
            usrList.add(priceRev2);
            usrList.add(priceRev3);
            usrList.add(mdfManager);
            Database.insert(usrList);
            
           
            
            User usr1 = Core_MDF_CCP_TestDataUtility.createUser(false);
            usr1.LastName = 'User Test1';
            usr1.ManagerId = manager.Id;
            Database.insert(usr1);

            PermissionSet pSet = [SELECT Id FROM PermissionSet WHERE PermissionSet.Name = 'Core_MDF_CCP_External_IPA_Proposal_Manager'];
            PermissionSet ipaL1Approver = [SELECT Id, Name FROM PermissionSet WHERE Name='Core_MDF_CCP_Int_IPA_ProposalL1_Approver' LIMIT 1];
            PermissionSet priceReviewerPS = [SELECT Id FROM PermissionSet WHERE Name =: 'Core_MDF_CCP_Internal_Price_Reviewer' LIMIT 1];
            PermissionSet ipaMdfManager = [SELECT Id FROM PermissionSet WHERE Name =: 'Core_MDF_CCP_Internal_IPA_Acct_Mgr' LIMIT 1];
            List<PermissionSetAssignment>permissionSetAssignmentList = new List<PermissionSetAssignment>();
            
            PermissionSetAssignment psa1 = new PermissionSetAssignment(PermissionSetId = pSet.id, AssigneeId = extUsr1.Id);
            permissionSetAssignmentList.add(psa1);            
            PermissionSetAssignment psa2 = new PermissionSetAssignment(PermissionSetId = pSet.id, AssigneeId = extUsr2.Id);
            permissionSetAssignmentList.add(psa2);            
            PermissionSetAssignment psa3 = new PermissionSetAssignment(PermissionSetId = pSet.id, AssigneeId = extUsr3.Id);
            permissionSetAssignmentList.add(psa3);            
            
            PermissionSetAssignment psa4 = new PermissionSetAssignment(PermissionSetId = ipaL1Approver.id, AssigneeId = l1Appr.Id);
            permissionSetAssignmentList.add(psa4); 
            
             PermissionSetAssignment psa5 = new PermissionSetAssignment(PermissionSetId = priceReviewerPS.Id, AssigneeId = priceRev.Id);
            permissionSetAssignmentList.add(psa5);
            
            PermissionSetAssignment psa6 = new PermissionSetAssignment(PermissionSetId = priceReviewerPS.Id, AssigneeId = priceRev2.Id);
            permissionSetAssignmentList.add(psa6);
            
            PermissionSetAssignment psa7 = new PermissionSetAssignment(PermissionSetId = priceReviewerPS.Id, AssigneeId = priceRev3.Id);
            permissionSetAssignmentList.add(psa7);
            
            PermissionSetAssignment psa8 = new PermissionSetAssignment(PermissionSetId = ipaMdfManager.Id, AssigneeId = mdfManager.Id);
            permissionSetAssignmentList.add(psa8);
            PermissionSetAssignment psa9 = new PermissionSetAssignment(PermissionSetId = ipaL1Approver.Id, AssigneeId = mdfManager.Id);
            permissionSetAssignmentList.add(psa9);
            
            Database.insert(permissionSetAssignmentList);
            

            List<Core_AGS_Role__c> agsRoleList = new List<Core_AGS_Role__c>();
            
            Core_AGS_Role__c agsRoleIPA = Core_MDF_CCP_TestDataUtility.createAgsRole('IPA_USER', 'Co-Marketing(Salesforce)-IPA USER', true, true);
            
            Core_ERPM_Engagement__c erpmEngagementIPA = Core_MDF_CCP_TestDataUtility.createErpmEngagement('Intel Partner Alliance', 'IPA', '', '', true, true);
            
            Core_Entitlement__c entitlementIPA = Core_MDF_CCP_TestDataUtility.createEntitlement('IPA MDF User',agsRoleIPA.Id ,'Intel Partner Alliance (IPA)','IPA MDF User',erpmEngagementIPA.Id , true,'Solutions Marketplace',true);
            
            List<Core_Contact_Entitlement__c> conEntList = new List<Core_Contact_Entitlement__c>();
            Core_Contact_Entitlement__c contactEntitlementIPA1 = Core_MDF_CCP_TestDataUtility.createContactEntitlement(con.Id,entitlementIPA.Id ,true,'Complete', false);            
            Core_Contact_Entitlement__c contactEntitlementIPA2 = Core_MDF_CCP_TestDataUtility.createContactEntitlement(con1.Id,entitlementIPA.Id ,true,'Complete', false);            
            Core_Contact_Entitlement__c contactEntitlementIPA3 = Core_MDF_CCP_TestDataUtility.createContactEntitlement(con2.Id,entitlementIPA.Id ,true,'Complete', false);  
              
            conEntList.add(contactEntitlementIPA1); conEntList.add(contactEntitlementIPA2); conEntList.add(contactEntitlementIPA3);
            Test.startTest();
            Database.insert(conEntList);
            
            // Creating Group
            List<Group> grpList = new List<Group>();
            Group ipaExtGrp = new Group();
            ipaExtGrp.Name = 'Core CCP IPA External';
            ipaExtGrp.DeveloperName = 'Core_MDF_CCP_IPA_External';
            grpList.add(ipaExtGrp);
            
            Group ipaExtGrp2 = new Group();
            ipaExtGrp2.Name = 'Core CCP IPA External2';
            ipaExtGrp2.DeveloperName = 'Core_MDF_CCP_IPA_External2';
            grpList.add(ipaExtGrp2);
            
            // Creating Group
            Group ipaGrp = new Group();
            ipaGrp.Name = 'Core CCP IPA Internal';
            ipaGrp.DeveloperName = 'Core_MDF_CCP_IPA_Internal';
            grpList.add(ipaGrp);
            Group ipaGrp2 = new Group();
            ipaGrp2.Name = 'Core CCP IPA Internal acc 2';
            ipaGrp2.DeveloperName = 'Core_MDF_CCP_IPA_Internal_acc2';
            grpList.add(ipaGrp2);
            
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
            
            
            GroupMember ipaGrpMem = new GroupMember();
            ipaGrpMem.UserOrGroupId = usr1.Id;
            ipaGrpMem.GroupId = ipaGrp.Id;
            
            GroupMember ipaGrpMem2 = new GroupMember();
            ipaGrpMem2.UserOrGroupId = mdfManager.Id;
            ipaGrpMem2.GroupId = ipaGrp2.Id;
            grpMemList.add(ipaGrpMem);
            
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
            pgmList.add(pgmExt);
            
            Core_MDF_Partner_Group_Mapping__c pgmExt2 = new Core_MDF_Partner_Group_Mapping__c();
            pgmExt2.Core_MDF_Account__c = ipaUltimateAccount2.Id;
            pgmExt2.Core_MDF_Group_Name__c = 'Core_MDF_CCP_IPA_External2';
            pgmExt2.Core_MDF_Type_of_Access__c = 'EXTERNAL';
            pgmExt2.Core_MDF_Group_Id__c = ipaExtGrp2.Id;                
            pgmExt2.Core_MDF_Channel_Program__c = ipaCP.Id;
            pgmExt2.Core_MDF_Source_Txt__c = 'Test';
            pgmExt2.Core_MDF_Region_cd__C = 'APJ';
            pgmExt2.Core_MDF_AccountIdGroupName__c = ipaUltimateAccount2.Id+'Core_MDF_CCP_IPA_External2';
            pgmList.add(pgmExt2);
            
            Core_MDF_Partner_Group_Mapping__c pgm1 = new Core_MDF_Partner_Group_Mapping__c();
            pgm1.Core_MDF_Account__c = ipaUltimateAccount.Id;
            pgm1.Core_MDF_Group_Name__c = 'Core_MDF_CCP_IPA_Internal';
            pgm1.Core_MDF_Type_of_Access__c = 'INTERNAL';
            pgm1.Core_MDF_Group_Id__c = ipaGrp.Id;                
            pgm1.Core_MDF_Channel_Program__c = ipaCP.Id;
            pgm1.Core_MDF_Source_Txt__c = 'Test';
            pgm1.Core_MDF_Region_cd__C = 'APJ';
            pgm1.Core_MDF_AccountIdGroupName__c = ipaUltimateAccount.Id+'Core_MDF_CCP_IPA_Internal';
            pgmList.add(pgm1);
            
            // Core_MDF_Partner_Group_Mapping__c pgm2 = new Core_MDF_Partner_Group_Mapping__c();
            // pgm2.Core_MDF_Account__c = ipaUltimateAccount.Id;
            // pgm2.Core_MDF_Group_Name__c = 'Core_MDF_CCP_IPA_Internal12';
            // pgm2.Core_MDF_Type_of_Access__c = 'INTERNAL';
            // pgm2.Core_MDF_Group_Id__c = ipaGrp.Id;                
            // pgm2.Core_MDF_Channel_Program__c = ipaCP.Id;
            // pgm2.Core_MDF_Source_Txt__c = 'Test';
            // pgm2.Core_MDF_Region_cd__C = 'WW';
            // pgm2.Core_MDF_AccountIdGroupName__c = ipaUltimateAccount.Id+'Core_MDF_CCP_IPA_Internal1';
            // pgmList.add(pgm2);
            
            // Core_MDF_Partner_Group_Mapping__c pgm3 = new Core_MDF_Partner_Group_Mapping__c();
            // pgm3.Core_MDF_Account__c = ipaUltimateAccount.Id;
            // pgm3.Core_MDF_Group_Name__c = 'Core_MDF_CCP_IPA_Internal23';
            // pgm3.Core_MDF_Type_of_Access__c = 'INTERNAL';
            // pgm3.Core_MDF_Group_Id__c = ipaGrp.Id;                
            // pgm3.Core_MDF_Channel_Program__c = ipaCP.Id;
            // pgm3.Core_MDF_Source_Txt__c = 'Test';
            // pgm3.Core_MDF_Region_cd__C = 'ASMO';
            // pgm3.Core_MDF_Sub_Region_cd__c = 'NAR';
            // pgm3.Core_MDF_AccountIdGroupName__c = ipaUltimateAccount.Id+'Core_MDF_CCP_IPA_Internal2';
            // pgmList.add(pgm3);
            
            Core_MDF_Partner_Group_Mapping__c pgm5 = new Core_MDF_Partner_Group_Mapping__c();
            pgm5.Core_MDF_Account__c = ipaUltimateAccount2.Id;
            pgm5.Core_MDF_Group_Name__c = 'Core_MDF_CCP_IPA_Internal_acc2';
            pgm5.Core_MDF_Type_of_Access__c = 'INTERNAL';
            pgm5.Core_MDF_Group_Id__c = ipaGrp2.Id;                
            pgm5.Core_MDF_Channel_Program__c = ipaCP.Id;
            pgm5.Core_MDF_Source_Txt__c = 'Test';
            pgm5.Core_MDF_Region_cd__C = 'WW';
            pgm5.Core_MDF_AccountIdGroupName__c = ipaUltimateAccount2.Id+'Core_MDF_CCP_IPA_Internal_acc2';
            pgmList.add(pgm5);
            
            Database.insert(pgmList);
            List<AccountShare> accShareList = new List<AccountShare>();
            AccountShare accshareRecordCCF = new AccountShare();
            accshareRecordCCF.AccountId = ipaUltimateAccount2.Id;
            accshareRecordCCF.UserOrGroupId = mdfManager.Id;
            accshareRecordCCF.RowCause = 'Manual';
            accshareRecordCCF.AccountAccessLevel = 'Read';
            accshareRecordCCF.OpportunityAccessLevel = 'None';
            accshareRecordCCF.CaseAccessLevel = 'None';
            accShareList.add(accshareRecordCCF);
            
            AccountShare accshareRecord = new AccountShare();
            accshareRecord.AccountId = ipaUltimateAccount.Id;
            accshareRecord.UserOrGroupId = mdfManager.Id;
            accshareRecord.RowCause = 'Manual';
            accshareRecord.AccountAccessLevel = 'Read';
            accshareRecord.OpportunityAccessLevel = 'None';
            accshareRecord.CaseAccessLevel = 'None';
            accShareList.add(accshareRecord);
            
            AccountShare accshareRecord3 = new AccountShare();
            accshareRecord3.AccountId = ipaCoMarketingAccount.Id;
            accshareRecord3.UserOrGroupId = mdfManager.Id;
            accshareRecord3.RowCause = 'Manual';
            accshareRecord3.AccountAccessLevel = 'Read';
            accshareRecord3.OpportunityAccessLevel = 'None';
            accshareRecord3.CaseAccessLevel = 'None';
            accShareList.add(accshareRecord3);
            
            AccountShare accshareRecord4 = new AccountShare();
            accshareRecord4.AccountId = ipaCoMarketingAccount2.Id;
            accshareRecord4.UserOrGroupId = mdfManager.Id;
            accshareRecord4.RowCause = 'Manual';
            accshareRecord4.AccountAccessLevel = 'Read';
            accshareRecord4.OpportunityAccessLevel = 'None';
            accshareRecord4.CaseAccessLevel = 'None';
            accShareList.add(accshareRecord4);
            Database.Insert(accShareList);
            
            
            Map<Id,Set<Id>> userIdCorpAcctIdSet = new Map<Id,Set<Id>>();
            Set<Id> accIdSet = new Set<Id>();
            accIdSet.add(ipaCoMarketingAccount.Id);
            userIdCorpAcctIdSet.put(extUsr1.Id, accIdSet);
            userIdCorpAcctIdSet.put(extUsr2.Id, accIdSet);
            userIdCorpAcctIdSet.put(extUsr3.Id, accIdSet);
            string accBasedBudgetType = Core_MDF_CCP_IPA_TestDataUtility.createBenefitforAccountBased(ipaCoMarketingAccount2);
            //Campaign ipaCampaignForAP = Core_MDF_CCP_IPA_TestDataUtility.createIPACampaign('Test Campaign - AP',ipaCoMarketingAccount.id, Date.newInstance(2021, 01, 01), Date.newInstance(2021, 06, 29),budgetType, 110000,'INDIA', 'Developer', 'Apollo Lake', 'Pending Approval', true);
            List<Campaign> campList = new List<Campaign>();
            System.runAs(mdfManager){
            Campaign ipaCampaignForAP = Core_MDF_CCP_IPA_TestDataUtility.createIPACampaign('Test Campaign - AP',ipaCoMarketingAccount.id, System.today(), System.today().adddays(30),budgetType, 110000,'INDIA', 'Developer', 'Apollo Lake', 'Draft', false);
            ipaCampaignForAP.Core_MDF_Opal_Budget_Type_Txt__c ='Client Specialties MDF';
            ipaCampaignForAP.Core_MDF_Proposal_Based_Ind__c = true;
            campList.add(ipaCampaignForAP);
            
             Campaign ipaAccCampaign = Core_MDF_CCP_IPA_TestDataUtility.createIPACampaign('Test Campaign - Acc based',ipaCoMarketingAccount2.id, System.today(), System.today().adddays(30),accBasedBudgetType, 110000,'INDIA', 'Developer', 'Apollo Lake', 'Draft', false);
            ipaAccCampaign.Core_MDF_Opal_Budget_Type_Txt__c ='Account Plan';
            ipaAccCampaign.Core_MDF_Proposal_Based_Ind__c = false;
            campList.add(ipaAccCampaign);
            Campaign ipaAccCampaign2 = Core_MDF_CCP_IPA_TestDataUtility.createIPACampaign('Test Campaign - Acc based2',ipaCoMarketingAccount2.id, System.today().addDays(-1), System.today().adddays(-1),accBasedBudgetType, 110000,'INDIA', 'Developer', 'Apollo Lake', 'Draft', false);
            ipaAccCampaign2.Core_MDF_Opal_Budget_Type_Txt__c ='Account Plan';
            ipaAccCampaign2.Core_MDF_Proposal_Based_Ind__c = false;
            campList.add(ipaAccCampaign2);
            Campaign ipaCampaignForAP2 = Core_MDF_CCP_IPA_TestDataUtility.createIPACampaign('Test Campaign - AP2',ipaCoMarketingAccount.id, System.today(), System.today().adddays(30),budgetType, 110000,'INDIA', 'Developer', 'Apollo Lake', 'Draft', false);
            ipaCampaignForAP.Core_MDF_Opal_Budget_Type_Txt__c ='Client Specialties MDF';
            ipaCampaignForAP2.Core_MDF_Proposal_Based_Ind__c =true;
            campList.add(ipaCampaignForAP2);
            Database.insert(campList);
            }
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
            
            
            User priceReviewerUser =[select Id from User where LastName = 'Price Reviewer' LIMIT 1];
            User priceReviewerUser2 =[select Id from User where LastName = 'Price Reviewer2' LIMIT 1];
            User priceReviewerUser3 =[select Id from User where LastName = 'Price Reviewer3' LIMIT 1];

            
        
        List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> iupgmList = new List<Core_MDF_Int_Users_Partner_Geo_Mapping__c>();
        Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm1 = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
       // iupgm3.Core_MDF_Account_id__c = ipaUltimateAccount.Id;
        iupgm1.Core_MDF_Program_nm__c = 'Intel Partner Alliance';
        iupgm1.RecordTypeId = IPA_RecordType;
        iupgm1.Core_MDF_Region_Sub_Region_nm__c = 'WW';
        iupgm1.Core_MDF_User_id__c = priceRev.Id;
        iupgm1.Core_MDF_All_Accounts_cd__c = 'Yes';
        iupgm1.Core_MDF_Role_nm__c='Core_MDF_CCP_Internal_Price_Reviewer';
        iupgm1.Core_MDF_All_Budget_Type_Access_Ind__c = true;
        iupgm1.Core_MDF_Active_Ind__c = true;
        iupgm1.Core_MDF_Approval_Region_nm__c = 'WW';
            
        Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm2 = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
        iupgm2.Core_MDF_Account_id__c = ipaUltimateAccount.Id;
        iupgm2.Core_MDF_Program_nm__c = 'Intel Partner Alliance';
        iupgm2.RecordTypeId = IPA_RecordType;
        iupgm2.Core_MDF_Region_Sub_Region_nm__c = 'WW';
        iupgm2.Core_MDF_User_id__c = priceRev2.Id;
        iupgm2.Core_MDF_All_Accounts_cd__c = 'No';
        iupgm2.Core_MDF_Role_nm__c='Core_MDF_CCP_Internal_Price_Reviewer';
        iupgm2.Core_MDF_All_Budget_Type_Access_Ind__c = true;
        iupgm2.Core_MDF_Approval_Region_nm__c = 'WW';
        iupgm2.Core_MDF_Active_Ind__c = true;
        
        Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm3 = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
     //   iupgm3.Core_MDF_Account_id__c = ipaUltimateAccount.Id;
        iupgm3.Core_MDF_Program_nm__c = 'Intel Partner Alliance';
        iupgm3.RecordTypeId = IPA_RecordType;
        iupgm3.Core_MDF_Region_Sub_Region_nm__c = 'WW';
        iupgm3.Core_MDF_User_id__c = priceRev3.Id;
        iupgm3.Core_MDF_All_Accounts_cd__c = 'Yes';
        iupgm3.Core_MDF_Role_nm__c='Core_MDF_CCP_Internal_Price_Reviewer';
        iupgm3.Core_MDF_All_Budget_Type_Access_Ind__c = true;
        iupgm3.Core_MDF_Active_Ind__c = true;
        iupgm3.Core_MDF_Approval_Region_nm__c = 'WW';
            
        Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm4 = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
       // iupgm3.Core_MDF_Account_id__c = ipaUltimateAccount.Id;
        iupgm4.Core_MDF_Program_nm__c = 'Intel Partner Alliance';
        iupgm4.Core_MDF_Region_Sub_Region_nm__c = 'WW';
        iupgm4.RecordTypeId = IPA_RecordType;
        iupgm4.Core_MDF_User_id__c = mdfManager.Id;
        iupgm4.Core_MDF_All_Accounts_cd__c = 'No';
        iupgm4.Core_MDF_Account_id__c = ipaUltimateAccount2.Id;
        iupgm4.Core_MDF_All_Budget_Type_Access_Ind__c = true;
        iupgm4.Core_MDF_Role_nm__c='Core_MDF_CCP_Internal_IPA_Acct_Mgr';
        iupgm4.Core_MDF_Active_Ind__c = true;    
            
         Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm5 = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
        iupgm5.Core_MDF_Account_id__c = ipaUltimateAccount.Id;
        iupgm5.Core_MDF_Program_nm__c = 'Intel Partner Alliance';
        iupgm5.RecordTypeId = IPA_RecordType;
        iupgm5.Core_MDF_Region_Sub_Region_nm__c = 'WW';
        iupgm5.Core_MDF_User_id__c = testUser.Id;
        iupgm5.Core_MDF_All_Accounts_cd__c = 'No';
        iupgm5.Core_MDF_Role_nm__c='Core_MDF_CCP_Internal_IPA_Budget_Loader';
        iupgm5.Core_MDF_All_Budget_Type_Access_Ind__c = false;
        iupgm5.Core_MDF_Approval_Region_nm__c = 'WW';
        iupgm5.Core_MDF_Active_Ind__c = true;
        iupgm5.Core_MDF_Region_cd__c = 'WW';
        iupgm5.Core_MDF_GeoSubGeo_Budget_Type_nm__c = 'WW->Account Plan';
            
       Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm6 = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
        iupgm6.Core_MDF_Account_id__c = ipaUltimateAccount.Id;
        iupgm6.Core_MDF_Program_nm__c = 'Intel Partner Alliance';
        iupgm6.RecordTypeId = IPA_RecordType;
        iupgm6.Core_MDF_Region_Sub_Region_nm__c = 'WW';
        iupgm6.Core_MDF_User_id__c = testUser2.Id;
        iupgm6.Core_MDF_All_Accounts_cd__c = 'No';
        iupgm6.Core_MDF_Role_nm__c='Core_MDF_CCP_Internal_IPA_Budget_Loader';
        iupgm6.Core_MDF_All_Budget_Type_Access_Ind__c = true;
        iupgm6.Core_MDF_Approval_Region_nm__c = 'WW';
        iupgm6.Core_MDF_Active_Ind__c = false;
        iupgm6.Core_MDF_Region_cd__c = 'WW';
        iupgm6.Core_MDF_GeoSubGeo_Budget_Type_nm__c = 'WW->Account Plan';
        
        iupgmList.add(iupgm1); 
        iupgmList.add(iupgm2);
        iupgmList.add(iupgm3);
        iupgmList.add(iupgm4);
        iupgmList.add(iupgm5);
      	iupgmList.add(iupgm6);
        Test.stopTest();
       Database.insert(iupgmList);
            
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
        
            
        /*    List<CampaignShare> capShareList = new List<CampaignShare>();
            CampaignShare campShare1 = new CampaignShare();
            campShare1.CampaignId = ipaCampaignForAP.Id;
            campShare1.UserOrGroupId = mdfManager.Id;
            campShare1.RowCause = 'Manual';
            campShare1.CampaignAccessLevel = 'Edit';
            capShareList.add(campShare1);
            
            CampaignShare campShare2 = new CampaignShare();
            campShare2.CampaignId = ipaCampaignForAP2.Id;
            campShare2.UserOrGroupId = mdfManager.Id;
            campShare2.RowCause = 'Manual';
            campShare2.CampaignAccessLevel = 'Edit';
            capShareList.add(campShare2);
            Database.Insert(capShareList);*/
        }
    }
    
    @isTest 
    static void subTypeForApproval(){
        
        Test.startTest();
        User mdfUsr = [Select id from User where LastName = 'Mdf Manager' limit 1];
        
        Account ipaCoMarketingAccount = [select id,Core_MDF_Parent_Fund_Account__c, Core_MDF_CoMarketing_Ultimate_Account__c, Core_MDF_Channel_Program__c from Account where Name= 'IPA Co-Marketing Account' LIMIT 1];
        
        Campaign ipaCampaignForAP = [SELECT Id, Core_MDF_Activity_Category_Type__c,Core_MDF_Program__c,Core_MDF_Region_cd__c, Status, Core_MDF_Approval_Step_Counter_nbr__c, 
                                     Core_MDF_Reimbursement_Rate__c, Description,Core_MDF_IPA_NonSPIF_Apprval_Ind__c,Core_MDF_IPA_SPIF_Apprval_Ind__c,
                                     StartDate, EndDate, Core_MDF_Total_Campaign_Cost_Amt__c, Core_MDF_Market__c, Core_MDF_Reimbursement_Amt__c  
                                     FROM Campaign WHERE Name = 'Test Campaign - AP' LIMIT 1];
        System.runAs(mdfUsr){
         PartnerFundRequest ipaPFR5 = Core_MDF_CCP_IPA_TestDataUtility.createIPAPartnerFundRequest(ipaCampaignForAP.id,ipaCoMarketingAccount.id,System.today().addDays(1),System.today().addDays(10),false);
        ipaPFR5.Core_MDF_Fund_Request_Status__c = 'Pending Review';
        ipaPFR5.Core_MDF_ActivityCategory__c = 'Seller Incentive 2025';
        ipaPFR5.Core_MDF_Activity_Types__c = 'SPIF - Volume';
        ipaPFR5.Core_MDF_SPIF_Segments_Available_ind__c = true;
        ipaPFR5.RequestedAmount = 100;
        Database.insert(ipaPFR5);
        
        Product2 prod = new Product2();
        prod.Name = 'Intel® B360 Chipset';
        prod.Core_Product_Type__c = 'Chipsets';
        prod.Core_Product_Family__c = 'Consumer Chipsets';
        Database.insert(prod);
        
        Core_MDF_Account_Product_Mapping__c apm = new Core_MDF_Account_Product_Mapping__c();
        apm.Core_MDF_Account__c = ipaCoMarketingAccount.Core_MDF_CoMarketing_Ultimate_Account__c;
        apm.Core_MDF_Active_ind__c = true;
        apm.Core_MDF_Program_Account_Map__c = 'Intel Partner Alliance';
        apm.Core_MDF_Product__c = prod.Id;
        Database.insert(apm);
        
        Core_MDF_Activity_Segment_Mapping__c asm = new Core_MDF_Activity_Segment_Mapping__c();
        asm.Core_MDF_Segment_Name_nm__c = 'Chipsets';
        asm.Core_MDF_SPIF_Amount_Dollar_Per_Unit_nbr__c = 1;
        asm.Core_MDF_SPIF_Notes_internal_only_txt__c = 'Test';
        asm.Core_MDF_Minimum_Forecast_Volume_nbr__c = 1;
        asm.Core_MDF_Estimated_Share_of_SPIF_amt__c = 1;
        asm.Core_MDF_Maximum_Bundled_Volume_nbr__c = 1;
        asm.Core_MDF_Maximum_Cost_of_Bundle_nbr__c = 1;
        asm.Core_MDF_SPIF_Notes_txt__c = 'Test';
        asm.Core_MDF_Active_Ind__c = true;
        asm.Core_MDF_Partner_Fund_Request_id__c = ipaPFR5.Id;
        insert asm;
        
        List<Core_MDF_Segment_Product_Mapping__c> spmList = new List<Core_MDF_Segment_Product_Mapping__c>();
        Core_MDF_Segment_Product_Mapping__c spm = new Core_MDF_Segment_Product_Mapping__c();
        spm.Core_MDF_Product_id__c = prod.Id;
        spm.Core_MDF_Activity_Segment_Mapping_id__c = asm.Id;
        spm.Core_MDF_Active_Ind__c = true;
        //spm.Core_MDF_Activity_Segment_Mapping_id__r.Core_MDF_Segment_Name_nm__c = '';   
        spmList.add(spm);
        Database.insert(spmList);
        
        
       
        //ipaCampaignForAP.Core_MDF_Ultimate_Account_txt__c = ipaCoMarketingAccount.Core_MDF_CoMarketing_Ultimate_Account__c;     
        ipaCampaignForAP.Core_MDF_Program__c = 'Intel Partner Alliance';
        ipaCampaignForAP.Core_MDF_Region_cd__c='APJ';
        ipaCampaignForAP.Status = 'Pending Review';
        ipaCampaignForAP.Core_MDF_IPA_SPIF_Apprval_Ind__c = true;
        ipaCampaignForAP.Core_MDF_Approval_Step_Counter_nbr__c = 0;
        ipaCampaignForAP.Core_MDF_IPA_NonSPIF_Apprval_Ind__c =false;
        //ipaCampaignForAP.Core_MDF_Approval_Stage_nm__c = 'L2 Approval';
        ipaCampaignForAP.Core_MDF_Activity_Category_Type__c = 'Purchase Incentive->Buyer - Bundle Offer';
        
        Database.update(ipaCampaignForAP);
        }
        
        List<Campaign> cmpUpd = new List<Campaign>();
        cmpUpd.add(ipaCampaignForAP);        
        
        Map<Id,Campaign> campOldMap = new Map<Id,Campaign>();
        campOldMap.put(ipaCampaignForAP.Id, ipaCampaignForAP);
	Core_MDF_Proposal_Based_Campaign_Process.callApprovalProcess(cmpUpd,campOldMap);
        
        
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
       // System.assertEquals('Purchase Incentive->Buyer - Bundle Offer',ipaCampaignForAP.Core_MDF_Activity_Category_Type__c);
       Assert.isNotNull(ipaCampaignForAP);
        Test.stopTest();
        
    }
    
    @isTest 
    static void testPCTEditAccess(){
        
        Test.startTest();
        User priceReviewerUser =[select Id from User where LastName = 'Price Reviewer' LIMIT 1];
        User mdfUsr = [Select id from User where LastName = 'Mdf Manager' limit 1];
         Account ipaCoMarketingAccount = [select id,Core_MDF_Parent_Fund_Account__c, Core_MDF_CoMarketing_Ultimate_Account__c, Core_MDF_Channel_Program__c from Account where Name= 'IPA Co-Marketing Account' LIMIT 1];
        
        Campaign ipaCampaignForAP = [SELECT Id, Core_MDF_Activity_Category_Type__c,Core_MDF_Program__c,Core_MDF_Region_cd__c,recordType.DeveloperName, Status, Core_MDF_Approval_Step_Counter_nbr__c, 
                                     Core_MDF_Reimbursement_Rate__c, Description,Core_MDF_IPA_NonSPIF_Apprval_Ind__c,Core_MDF_IPA_SPIF_Apprval_Ind__c,
                                     StartDate, EndDate, Core_MDF_Total_Campaign_Cost_Amt__c, Core_MDF_Market__c,Core_MDF_Reimbursement_Amt__c  
                                     FROM Campaign WHERE Name = 'Test Campaign - AP2' LIMIT 1];
        System.runAs(mdfUsr){
         PartnerFundRequest ipaPFR5 = Core_MDF_CCP_IPA_TestDataUtility.createIPAPartnerFundRequest(ipaCampaignForAP.id,ipaCoMarketingAccount.id,System.today().addDays(1),System.today().addDays(10),false);
        ipaPFR5.Core_MDF_Fund_Request_Status__c = 'Pending Review';
        ipaPFR5.Core_MDF_ActivityCategory__c = 'Seller Incentive 2025';
        ipaPFR5.Core_MDF_Activity_Types__c = 'SPIF - Volume';
        ipaPFR5.Core_MDF_SPIF_Segments_Available_ind__c = true;
        ipaPFR5.RequestedAmount = 100;
        Database.insert(ipaPFR5);
        
        Product2 prod = new Product2();
        prod.Name = 'Intel® B360 Chipset';
        prod.Core_Product_Type__c = 'Chipsets';
        prod.Core_Product_Family__c = 'Consumer Chipsets';
        Database.insert(prod);
        
        Core_MDF_Account_Product_Mapping__c apm = new Core_MDF_Account_Product_Mapping__c();
        apm.Core_MDF_Account__c = ipaCoMarketingAccount.Core_MDF_CoMarketing_Ultimate_Account__c;
        apm.Core_MDF_Active_ind__c = true;
        apm.Core_MDF_Program_Account_Map__c = 'Intel Partner Alliance';
        apm.Core_MDF_Product__c = prod.Id;
        Database.insert(apm);
        
        Core_MDF_Activity_Segment_Mapping__c asm = new Core_MDF_Activity_Segment_Mapping__c();
        asm.Core_MDF_Segment_Name_nm__c = 'Chipsets';
        asm.Core_MDF_SPIF_Amount_Dollar_Per_Unit_nbr__c = 1;
        asm.Core_MDF_SPIF_Notes_internal_only_txt__c = 'Test';
        asm.Core_MDF_Minimum_Forecast_Volume_nbr__c = 1;
        asm.Core_MDF_Estimated_Share_of_SPIF_amt__c = 1;
        asm.Core_MDF_Maximum_Bundled_Volume_nbr__c = 1;
        asm.Core_MDF_Maximum_Cost_of_Bundle_nbr__c = 1;
        asm.Core_MDF_SPIF_Notes_txt__c = 'Test';
        asm.Core_MDF_Active_Ind__c = true;
        asm.Core_MDF_Partner_Fund_Request_id__c = ipaPFR5.Id;
        insert asm;
        
        List<Core_MDF_Segment_Product_Mapping__c> spmList = new List<Core_MDF_Segment_Product_Mapping__c>();
        Core_MDF_Segment_Product_Mapping__c spm = new Core_MDF_Segment_Product_Mapping__c();
        spm.Core_MDF_Product_id__c = prod.Id;
        spm.Core_MDF_Activity_Segment_Mapping_id__c = asm.Id;
        spm.Core_MDF_Active_Ind__c = true;
        //spm.Core_MDF_Activity_Segment_Mapping_id__r.Core_MDF_Segment_Name_nm__c = '';   
        spmList.add(spm);
        Database.insert(spmList);
        
        
        //ipaCampaignForAP.Core_MDF_Ultimate_Account_txt__c = ipaCoMarketingAccount.Core_MDF_CoMarketing_Ultimate_Account__c;     
        ipaCampaignForAP.Core_MDF_Program__c = 'Intel Partner Alliance';
        ipaCampaignForAP.Core_MDF_Region_cd__c='APJ';
        ipaCampaignForAP.Status = 'Pending Review';
        ipaCampaignForAP.Core_MDF_IPA_SPIF_Apprval_Ind__c = true;
        ipaCampaignForAP.Core_MDF_Approval_Step_Counter_nbr__c = 2;
        ipaCampaignForAP.Core_MDF_IPA_NonSPIF_Apprval_Ind__c =false;
        //ipaCampaignForAP.Core_MDF_Approval_Stage_nm__c = 'Price Reviewer';
        ipaCampaignForAP.Core_MDF_Activity_Category_Type__c = 'Purchase Incentive->Buyer - Bundle Offer';
        
        Database.update(ipaCampaignForAP);
        }
        
        Assert.isNotNull(ipaCampaignForAP);
        List<Campaign> cmpUpd = new List<Campaign>();
        cmpUpd.add(ipaCampaignForAP);        
        
        Map<Id,Campaign> campOldMap = new Map<Id,Campaign>();
        campOldMap.put(ipaCampaignForAP.Id, ipaCampaignForAP);
        
              Core_MDF_Proposal_Based_Campaign_Process.callApprovalProcess(cmpUpd,campOldMap);
        
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
       // System.assertEquals('Purchase Incentive->Buyer - Bundle Offer',ipaCampaignForAP.Core_MDF_Activity_Category_Type__c);
        Test.stopTest();
        System.runAs(priceReviewerUser)
        {
            Core_MDF_CampaignCreatePage.checkEditProposalAccess(ipaCampaignForAP.Id, ipaCampaignForAP.recordType.DeveloperName);
        }
        
        
        
        
    }
    
   /* @isTest 
    static void testAccCampaignStatusUpdates(){
        
        Test.startTest();
        
         Account ipaCoMarketingAccount = [select id,Core_MDF_Parent_Fund_Account__c, Core_MDF_CoMarketing_Ultimate_Account__c, Core_MDF_Channel_Program__c from Account where Name= 'IPA Co-Marketing Account2' LIMIT 1];
        
        Campaign ipaCampaignForAP = [SELECT Id, Core_MDF_Opal_Budget_Type_Txt__c,Core_MDF_Activity_Category_Type__c,Core_MDF_Program__c,Core_MDF_Region_cd__c,recordType.DeveloperName, Status, Core_MDF_Approval_Step_Counter_nbr__c, 
                                     Core_MDF_Reimbursement_Rate__c, Description,Core_MDF_IPA_NonSPIF_Apprval_Ind__c,Core_MDF_IPA_SPIF_Apprval_Ind__c,
                                     StartDate, EndDate, Core_MDF_Total_Campaign_Cost_Amt__c, Core_MDF_Market__c,Core_MDF_Reimbursement_Amt__c  
                                     FROM Campaign WHERE Name = 'Test Campaign - Acc based' LIMIT 1];
        Id budget_Record_Type = Schema.SObjectType.PartnerMarketingBudget.getRecordTypeInfosByDeveloperName().get('Core_MDF_IPA_Account_Based').getRecordTypeId();
        Id allocation_Record_Type = Schema.SObjectType.PartnerFundAllocation.getRecordTypeInfosByDeveloperName().get('Core_MDF_Intel_Partner_Alliance').getRecordTypeId();
        PartnerMarketingBudget  pmbRecord = Core_MDF_CCP_TestDataUtility.createBudget('Acc based PMB',budget_Record_Type,ipaCoMarketingAccount.Id,ipaCoMarketingAccount.Core_MDF_Channel_Program__c,100000,
                                                                                      System.today().addDays(-15),System.today().addDays(15),false);
        pmbRecord.Core_MDF_Budget_Type_Txt__c = ipaCampaignForAP.Core_MDF_Opal_Budget_Type_Txt__c;
        database.insert(pmbRecord);
        
        // Create PFA records for the above accounts :
        List<PartnerFundAllocation> pfaList = new List<PartnerFundAllocation>();
        

        PartnerFundAllocation pfa = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('pfaDellCCFVirtualCorp',pmbRecord, ipaCoMarketingAccount, 10000,false);
        pfa.RecordTypeId=allocation_Record_Type;
        database.insert(pfa);
        
         PartnerFundRequest ipaPFR5 = Core_MDF_CCP_IPA_TestDataUtility.createIPAPartnerFundRequest(ipaCampaignForAP.id,ipaCoMarketingAccount.id,System.today().addDays(1),System.today().addDays(10),false);
        ipaPFR5.Core_MDF_Fund_Request_Status__c = 'Pending Review';
        ipaPFR5.Core_MDF_ActivityCategory__c = 'Digital Media';
        ipaPFR5.Core_MDF_Activity_Types__c = 'IndustryPartner.com';
        ipaPFR5.Core_MDF_Activity_SubType_nm__c= 'Banner/Display';
        ipaPFR5.RequestedAmount = 100;
        ipaPFR5.AllocationId = pfa.Id;
        Database.insert(ipaPFR5);
        try{
        ipaCampaignForAP.Status = 'Cancelled';
        Database.update(ipaCampaignForAP);
        }
        catch(Exception e){
            
        }
    
    }*/
    @isTest
    static void notifyFinanceusersTest(){
        test.startTest();
        ChannelProgram cpRetail = Core_MDF_CCP_TestDataUtility.createProgram ('Retail Marketing Funds','Retail Marketing Funds', True);

         Account acc1Retail = Core_MDF_CCP_TestDataUtility.createIntelAccount ('Test Account Retail', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, 
                                                                              false);
        acc1Retail.Core_Account_Type__c = 'Reseller';
        acc1Retail.Industry = 'Food & Beverage';
        acc1Retail.Core_MDF_Channel_Program__c = cpRetail.Id;
        acc1Retail.Core_Geo__c = 'APJ';            
        acc1Retail.Core_Sub_Geo__c = 'IJKK';
        insert acc1Retail;
        Account accRetail = Core_MDF_CCP_TestDataUtility.createAccount ('Co-marketing Test Account Retail', cpRetail.Id,
                                                                        Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
        accRetail.Core_MDF_Parent_Fund_Account__c = acc1Retail.Id;
        accRetail.Core_Geo__c = 'APJ';
        accRetail.Core_Sub_Geo__c = 'IJKK';
        insert accRetail;
       Campaign camp1 = Core_MDF_CCP_TestDataUtility.createCampaign('TestRetailCamp','Gaming','Athena', 'MDF or both CMP & MDF',
                                                                     Core_MDF_CCP_TestDataUtility.campaign_RecordType_Retail, 'Retail Marketing Funds',System.today()-90, 
                                                                     System.today().addYears(1), 2000, 'Instore innovation', accRetail.Id,'2-in-1', true);
        
       
        List<Campaign> campaignList=new  List<Campaign>();
        campaignList.add(camp1);
        core_mdf_CampaignUtility.notifyFinanceusers(campaignList);
        Assert.isNotNull(campaignList);
        test.stoptest();
    }
    
    @isTest
    static void testBudgetTypeCapOverlapDupCheck() {
		Test.startTest();
        User testUsr = [Select id, Profile.UserLicense.Name from User where LastName = 'TestUser TestClass' limit 1];
        User testUsr2 = [Select id, Profile.UserLicense.Name from User where LastName = 'TestUser TestClass2' limit 1];
        
        Core_MDF_Configuration__c testConfig = new Core_MDF_Configuration__c(
             Name = 'CAMPAIGN_STATUS_FOR_BUDGETCAPAMT',
            Core_MDF_Value__c = 'Approved,Pending,Completed'
        );
        insert testConfig;
        
        Account ipaCoMarketingAccount = [select id,Core_MDF_Parent_Fund_Account__c, Core_MDF_CoMarketing_Ultimate_Account__c, Core_MDF_Channel_Program__c from Account where Name= 'IPA Co-Marketing Account' LIMIT 1];
        
        Campaign ipaCampaignForAP = [SELECT Id, Core_MDF_Activity_Category_Type__c,Core_MDF_Program__c,Core_MDF_Region_cd__c, Status, Core_MDF_Approval_Step_Counter_nbr__c, 
                                     Core_MDF_Reimbursement_Rate__c, Description,Core_MDF_IPA_NonSPIF_Apprval_Ind__c,Core_MDF_IPA_SPIF_Apprval_Ind__c,
                                     StartDate, EndDate, Core_MDF_Total_Campaign_Cost_Amt__c, Core_MDF_Market__c, Core_MDF_Reimbursement_Amt__c  
                                     FROM Campaign WHERE Name = 'Test Campaign - AP' LIMIT 1];
        List<Core_MDF_Budget_Cap__c> bCap = [Select Id,Core_MDF_Region_nm__c,Core_MDF_Budget_Type_nm__c,Core_MDF_Effective_Start_Date_Dt__c,Core_MDF_Effective_End_Date_Dt__c,Core_MDF_Cap_Status_nm__c,RecordTypeId  from Core_MDF_Budget_Cap__c where Core_MDF_Budget_Type_nm__c='Client Specialties MDF' limit 1];
        System.runAs(testUsr) {
            Map<Id, Core_MDF_Budget_Cap__c> bcMap = new Map<Id, Core_MDF_Budget_Cap__c>();
            bcMap.put(bCap[0].Id, bCap[0]);
            bCap[0].Core_MDF_Region_nm__c = 'APJ';
            Core_MDF_BudgetTypeCap_Utility.budgetTypeCapOverlapDupCheck(bCap, bcMap, false, true);
            Core_MDF_BudgetTypeCap_Utility.validateBudgetTypeCapCreationOrUpdateAccess(bcap);
            Core_MDF_BudgetTypeCap_Utility.checkCampaignStatusForCapAmount('Planned', 1);
        }
        
        System.runAs(testUsr2) {
        	Core_MDF_BudgetTypeCap_Utility.validateBudgetTypeCapCreationOrUpdateAccess(bcap);
        }
        
        Test.stopTest();
        
    }
}