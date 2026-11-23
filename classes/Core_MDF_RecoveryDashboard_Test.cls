@isTest(SeeAllData=false)
public class Core_MDF_RecoveryDashboard_Test {
	
    public static set<String> Programs_For_Node_Account = Core_MDF_CCP_ConstantClass.Programs_For_Node_Account;
    @TestSetup 
    static void makeData() {
        
        Profile sysAdminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator' LIMIT 1];
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.profileId = sysAdminProfile.Id;
        usr.UserRoleId = usRole.Id;
        Database.insert(usr);
        //Running as System Admin
        System.runAs(usr){
            List<Core_Trigger_Executions__c> transactions = new List<Core_Trigger_Executions__c>();
            transactions.addAll(Core_MDF_CCP_TestDataUtility.byPassFeature(new List<String>{'Bypass_Duplicate_Budget_Check','Bypass_MDF_Budget_Access','Bypass_GeoBased_Budget_Sharing','Bypass_MDF_Budget_Access_Validation','Bypass_MDF_Budget_Status_Validation'}, true, false));        
            transactions.addAll(Core_MDF_CCP_TestDataUtility.byPassFeature(new List<String>{'Bypass_Allocation_Reservation','Bypass_GeoBased_Allocation_Sharing'}, true, false));   
            transactions.addAll(Core_MDF_CCP_TestDataUtility.byPassFeature(new List<String>{'Bypass_Duplicate_Bank_Check','Bypass_Bank_Internal_Sharing',
                'Bypass_Bank_External_Sharing','Bypass_Bank_Program_InActivation_Check','Bypass_Bank_ABM_Sharing'}, true, false));
            transactions.addAll(Core_MDF_CCP_TestDataUtility.byPassFeature(new List<String>{'Bypass_ABM_Internal_Sharing','Bypass_ABM_External_Sharing','Bypass_ABM_NodeGroup_Sharing'}, true, false));                 
            Database.insert(transactions);
            
            List<Core_Trigger_Executions__c> executionList = new List<Core_Trigger_Executions__c>();
            
            Core_Trigger_Executions__c claimFunctionalityNameTriggerExecution = new Core_Trigger_Executions__c();
            claimFunctionalityNameTriggerExecution.Core_Active__c = true;
            claimFunctionalityNameTriggerExecution.Core_Class_Name__c = 'Core_MDF_ProcessCCP_Claim';
            claimFunctionalityNameTriggerExecution.Core_Trigger_Events__c = 'after insert, after update';
            claimFunctionalityNameTriggerExecution.Core_Object__c = 'PartnerFundClaim';
            claimFunctionalityNameTriggerExecution.Name = 'fundReservation';
            claimFunctionalityNameTriggerExecution.Core_Description__c = 'description';
            executionList.add(claimFunctionalityNameTriggerExecution);
            Core_Trigger_Executions__c claimFunctionalityNameTriggerExecution2 = new Core_Trigger_Executions__c();
            claimFunctionalityNameTriggerExecution2.Core_Active__c = true;
            claimFunctionalityNameTriggerExecution2.Core_Class_Name__c = 'Core_MDF_ProcessCCP_Claim';
            claimFunctionalityNameTriggerExecution2.Core_Trigger_Events__c = 'before insert';
            claimFunctionalityNameTriggerExecution2.Core_Object__c = 'PartnerFundClaim';
            claimFunctionalityNameTriggerExecution2.Name = 'checkESDHoldAndUpdateClaimStatus';
            claimFunctionalityNameTriggerExecution2.Core_Description__c = 'check ESD hold for the bank selected on Claim and change Claim status to Hold if it is on ESD Hold';
            executionList.add(claimFunctionalityNameTriggerExecution2);
            Core_Trigger_Executions__c claimFunctionalityNameTriggerExecution1 = new Core_Trigger_Executions__c();
            claimFunctionalityNameTriggerExecution1.Core_Active__c = true;
            claimFunctionalityNameTriggerExecution1.Core_Class_Name__c = 'Core_MDF_ProcessCCP_Claim';
            claimFunctionalityNameTriggerExecution1.Core_Trigger_Events__c = 'before insert';
            claimFunctionalityNameTriggerExecution1.Core_Object__c = 'PartnerFundClaim';
            claimFunctionalityNameTriggerExecution1.Name = 'duplicateClaimCheck';
            claimFunctionalityNameTriggerExecution1.Core_Description__c = 'check ESD hold for the bank selected on Claim and change Claim status to Hold if it is on ESD Hold';
            executionList.add(claimFunctionalityNameTriggerExecution1);
            Core_Trigger_Executions__c claimFunctionalityNameTriggerExecution3 = new Core_Trigger_Executions__c();
            claimFunctionalityNameTriggerExecution3.Core_Active__c = false;
            claimFunctionalityNameTriggerExecution3.Core_Class_Name__c = 'Core_MDF_PFCServiceHandler';
            claimFunctionalityNameTriggerExecution3.Core_Trigger_Events__c = 'before upate, after update';
            claimFunctionalityNameTriggerExecution3.Core_Object__c = 'PartnerFundClaim';
            claimFunctionalityNameTriggerExecution3.Name = 'checkAndSendClaimsToAudit';
            claimFunctionalityNameTriggerExecution3.Core_Description__c = 'test';
            // executionList.add(claimFunctionalityNameTriggerExecution3);
            Core_Trigger_Executions__c claimFunctionalityNameTriggerExecution4 = new Core_Trigger_Executions__c();
            claimFunctionalityNameTriggerExecution4.Core_Active__c = true;
            claimFunctionalityNameTriggerExecution4.Core_Class_Name__c = 'Core_MDF_PFCServiceHandler';
            claimFunctionalityNameTriggerExecution4.Core_Trigger_Events__c = 'before insert, before update';
            claimFunctionalityNameTriggerExecution4.Core_Object__c = 'PartnerFundClaim';
            claimFunctionalityNameTriggerExecution4.Name = 'Core_MDF_chkClaimAmtAgainstActBgtAmt';
            claimFunctionalityNameTriggerExecution4.Core_Description__c = 'description';
            executionList.add(claimFunctionalityNameTriggerExecution4);
            Core_Trigger_Executions__c claimFunctionalityNameTriggerExecution5 = new Core_Trigger_Executions__c();
            claimFunctionalityNameTriggerExecution5.Core_Active__c = true;
            claimFunctionalityNameTriggerExecution5.Core_Class_Name__c = 'Core_MDF_PFCServiceHandler';
            claimFunctionalityNameTriggerExecution5.Core_Trigger_Events__c = 'after update';
            claimFunctionalityNameTriggerExecution5.Core_Object__c = 'PartnerFundClaim';
            claimFunctionalityNameTriggerExecution5.Name = 'reserveFundsforNode';
            claimFunctionalityNameTriggerExecution5.Core_Description__c = 'description';
            executionList.add(claimFunctionalityNameTriggerExecution5);
            Core_Trigger_Executions__c claimFunctionalityNameTriggerExecution6 = new Core_Trigger_Executions__c();
            claimFunctionalityNameTriggerExecution6.Core_Active__c = true;
            claimFunctionalityNameTriggerExecution6.Core_Class_Name__c = 'Core_MDF_PFCServiceHandler';
            claimFunctionalityNameTriggerExecution6.Core_Trigger_Events__c = 'after insert, after update';
            claimFunctionalityNameTriggerExecution6.Core_Object__c = 'PartnerFundClaim';
            claimFunctionalityNameTriggerExecution6.Name = 'checkAndSendClaimsForPIC';
            claimFunctionalityNameTriggerExecution6.Core_Description__c = 'description';
            executionList.add(claimFunctionalityNameTriggerExecution6);
            
            Database.insert(executionList);
            List<Account> intelAccList = new List<Account>();
            ChannelProgram ccfCP = Core_MDF_CCP_TestDataUtility.createProgram (Core_MDF_CCP_ConstantClass.CCF_PROGRAM,'Client CoMarketing Fund', true);
            
            Account arpIntelAcc = Core_MDF_CCP_TestDataUtility.createAccount ('ARP Test Account', NULL, Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);   
            arpIntelAcc.BillingCity = 'ARP City';         
            arpIntelAcc.BillingCountry= 'IND';
            arpIntelAcc.BillingStreet= 'ARP Street';
            arpIntelAcc.Core_MDF_Active_Ind__c=true;
            intelAccList.add(arpIntelAcc);
            Account arpIntelAcc2 = Core_MDF_CCP_TestDataUtility.createAccount ('ARP Test Account2', NULL, Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);   
            arpIntelAcc2.BillingCity = 'ARP City';         
            arpIntelAcc2.BillingCountry= 'IND';
            arpIntelAcc2.BillingStreet= 'ARP Street';
            arpIntelAcc2.Core_MDF_CoMarketingAgency__c = true;
            arpIntelAcc2.Core_MDF_CoMarketingActive__c = false;
            //arpIntelAcc2.Core_MDF_Active_Ind__c=true;
            Account arpIntelAcc3 = Core_MDF_CCP_TestDataUtility.createAccount ('ARP Test Account3', NULL, Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);   
            arpIntelAcc3.BillingCity = 'ARP City';         
            arpIntelAcc3.BillingCountry= 'IND';
            arpIntelAcc3.BillingStreet= 'ARP Street';
            arpIntelAcc3.Core_MDF_CoMarketingAgency__c = false;
            arpIntelAcc3.Core_MDF_CoMarketingActive__c = false;
            intelAccList.add(arpIntelAcc3);
            intelAccList.add(arpIntelAcc2);
            Database.insert(intelAccList);   
           
            List<Account> vcAccList = new List<Account>();
            Account arpCCFVC = Core_MDF_CCP_TestDataUtility.createAccount ('ARP CCF Virtual Corp', ccfCP.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            arpCCFVC.Core_MDF_Parent_Fund_Account__c = arpIntelAcc.Id;
            vcAccList.add(arpCCFVC);
            Account arpCCFVC2 = Core_MDF_CCP_TestDataUtility.createAccount ('ARP CCF2 Virtual Corp', ccfCP.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            arpCCFVC2.Core_MDF_Parent_Fund_Account__c = arpIntelAcc2.Id;
            vcAccList.add(arpCCFVC2);
            Account arpCCFVC3 = Core_MDF_CCP_TestDataUtility.createAccount ('ARP CCF3 Virtual Corp', ccfCP.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            arpCCFVC3.Core_MDF_Parent_Fund_Account__c = arpIntelAcc2.Id;
            vcAccList.add(arpCCFVC3);
            Database.insert(vcAccList);  
            Test.startTest();
            
            List<Group> grpList = new List<Group>();
            Group ccfgrp = new Group();
            ccfgrp.Name = 'Core CCP CCF External';
            ccfgrp.DeveloperName = 'Core_CCP_CCF_External';
            grpList.add(ccfgrp);
            Database.insert(grpList);            
            
            Core_MDF_Configuration__c config1 = new Core_MDF_Configuration__c();
            config1.Core_MDF_Value__c = '20';
            config1.Name = 'Core_MDF_PScore_Edit_Buffer_Days';
            insert config1;
            List<Core_MDF_Partnership_Score__c> psList = new List<Core_MDF_Partnership_Score__c>();
            Core_MDF_Partnership_Score__c ps = new Core_MDF_Partnership_Score__c();
            ps.Core_MDF_Account_Id__c = arpIntelAcc.id;
            ps.Core_MDF_Channel_Program_Id__c = ccfCP.Id;
            ps.Core_MDF_Program_nm__c = 'Client CoMarketing Fund';
            ps.Core_MDF_Quarter_Year_Nm__c = 'Q1 2024';
            ps.Core_MDF_Zone_nm__c = 'A3';
            ps.Core_MDF_External_Id__c = String.valueOf(ccfCP.Id)+String.valueOf(arpIntelAcc.id)+String.valueOf(ps.Core_MDF_Quarter_Year_Nm__c);
            psList.add(ps);
            Core_MDF_Partnership_Score__c ps2 = new Core_MDF_Partnership_Score__c();
            ps2.Core_MDF_Account_Id__c = arpIntelAcc2.id;
            ps2.Core_MDF_Channel_Program_Id__c = ccfCP.Id;
            ps2.Core_MDF_Program_nm__c = 'Client CoMarketing Fund';
            ps2.Core_MDF_Quarter_Year_Nm__c = 'Q1 2024';
            ps2.Core_MDF_Zone_nm__c = 'A3';
            ps2.Core_MDF_External_Id__c = String.valueOf(ccfCP.Id)+String.valueOf(arpIntelAcc2.id)+String.valueOf(ps.Core_MDF_Quarter_Year_Nm__c);
            //psList.add(ps2);
            insert psList;
            
            List<Core_MDF_Partner_Group_Mapping__c> pgmList = new List<Core_MDF_Partner_Group_Mapping__c>();
            // Creating Partner Group Mapping
            Core_MDF_Partner_Group_Mapping__c pgm = new Core_MDF_Partner_Group_Mapping__c();
            pgm.Core_MDF_Account__c = arpIntelAcc.Id;
            pgm.Core_MDF_Virtual_Corp_nm__c = arpCCFVC.id;
            pgm.Core_MDF_Group_Name__c = 'Core_CCP_CCF_External';
            pgm.Core_MDF_Type_of_Access__c = 'External';
            pgm.Core_MDF_Group_Id__c = ccfgrp.Id;                
            pgm.Core_MDF_Channel_Program__c = ccfCP.Id;
            pgm.Core_MDF_AccountIdGroupName__c = arpIntelAcc.Id+'Core_CCP_CCF_External';
            pgmList.add(pgm);
            Core_MDF_Partner_Group_Mapping__c pgm2 = new Core_MDF_Partner_Group_Mapping__c();
            pgm2.Core_MDF_Account__c = arpIntelAcc2.Id;
            pgm2.Core_MDF_Virtual_Corp_nm__c = arpCCFVC2.id;
            pgm2.Core_MDF_Group_Name__c = 'Core_CCP_CCF_External';
            pgm2.Core_MDF_Type_of_Access__c = 'External';
            pgm2.Core_MDF_Group_Id__c = ccfgrp.Id;                
            pgm2.Core_MDF_Channel_Program__c = ccfCP.Id;
            pgm2.Core_MDF_AccountIdGroupName__c = arpIntelAcc2.Id+'Core_CCP_CCF_External';
            pgmList.add(pgm2);//arpCCFVC2
            Core_MDF_Partner_Group_Mapping__c pgm3 = new Core_MDF_Partner_Group_Mapping__c();
            pgm3.Core_MDF_Account__c = arpIntelAcc3.Id;
            pgm3.Core_MDF_Virtual_Corp_nm__c = arpCCFVC3.id;
            pgm3.Core_MDF_Group_Name__c = 'Core_CCP_CCF_External';
            pgm3.Core_MDF_Type_of_Access__c = 'External';
            pgm3.Core_MDF_Group_Id__c = ccfgrp.Id;                
            pgm3.Core_MDF_Channel_Program__c = ccfCP.Id;
            pgm3.Core_MDF_AccountIdGroupName__c = arpIntelAcc3.Id+'Core_CCP_CCF_External';
            pgmList.add(pgm3);
            Database.insert(pgmList);
            Test.stopTest(); 
        }
    }
    
    @isTest
    static void testGetProgramIdToNameMap(){
        Profile sysAdminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator' LIMIT 1];
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.profileId = sysAdminProfile.Id;
        usr.UserRoleId = usRole.Id;
        Database.insert(usr);
        //Running as System Admin
        System.runAs(usr)
        {
        Core_MDF_RecoveryDashboardController.ProgramUserDataWrapper cp = Core_MDF_RecoveryDashboardController.getProgramIdToNameMap();
        Assert.isNotNull(cp);
        Account acc1 = [select id from Account where name='ARP Test Account' limit 1];
        Core_MDF_Partnership_Score__c pss = [select id,Core_MDF_Quarter_Year_Nm__c,Core_MDF_Channel_Program_Id__c,Core_MDF_Account_Id__c,Core_MDF_Program_nm__c from Core_MDF_Partnership_Score__c where Core_MDF_Account_Id__c =: acc1.id limit 1];
        
        List<Core_MDF_Partnership_Score__c> RecMapRec = Core_MDF_RecoveryDashboardController.getPartnershipScoreRecord(pss.Core_MDF_Channel_Program_Id__c,pss.Core_MDF_Account_Id__c,pss.Core_MDF_Quarter_Year_Nm__c);
        }
    }
    
    @isTest
    static void testGetAccountIdToNameMapExternal(){
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1]; 
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.LastName = 'User Test';
        usr.UserRoleId = usRole.Id;
        Database.insert(usr);
        User usr1 = Core_MDF_CCP_TestDataUtility.createUser(false);
        User usr2 = Core_MDF_CCP_TestDataUtility.createUser(false);
        User usr3 = Core_MDF_CCP_TestDataUtility.createUser(false);
        system.runAs(usr) {
            Account acc1 = [select id from Account where name='ARP Test Account' limit 1];
            Account acc2 = [select id from Account where name='ARP Test Account2' limit 1];
            Account acc3 = [select id from Account where name='ARP Test Account3' limit 1];
            //Account acc2 = [select id from Account where name='ARP CCF Virtual Corp' limit 1];
        List<Contact> cntcts = New List<Contact>();
        Contact conRecord1 = Core_MDF_CCP_TestDataUtility.createContact(acc1.Id,false);
        Contact conRecord2 = Core_MDF_CCP_TestDataUtility.createContact(acc2.Id,false);
        Contact conRecord3 = Core_MDF_CCP_TestDataUtility.createContact(acc3.Id,false);
            cntcts.add(conRecord1);
            cntcts.add(conRecord2);
            cntcts.add(conRecord3);
        Database.insert(cntcts);
           // Contact conRecord2 = Core_MDF_CCP_TestDataUtility.createContact(acc2.Id,false);
        //Database.insert(conRecord2);
        Id profileId = [SELECT Id FROM Profile WHERE Name='Partner' limit 1].Id;
        Core_AGS_Role__c agsRoleCCFClaimSub = Core_MDF_CCP_TestDataUtility.createAgsRole('Co-Marketing(Salesforce)-External Claim Submitter-CCF', 'Co-Marketing(Salesforce)-External Claim Submitter-CCF', true, false);
        Database.insert(agsRoleCCFClaimSub);
        Core_ERPM_Engagement__c erpmEngagementCCF = Core_MDF_CCP_TestDataUtility.createErpmEngagement('CCF', 'CCF', 'DEDUPB2B', 'SEC', true, false);
        Database.insert(erpmEngagementCCF);
        Core_Entitlement__c entitlementCCFClaimSub = Core_MDF_CCP_TestDataUtility.createEntitlement('CCF Claim Submitter',agsRoleCCFClaimSub.Id ,'Intel® Partner Investment Center','CCF Claim Submitter',erpmEngagementCCF.Id , true,'Client',false);
        Database.insert(entitlementCCFClaimSub);
        List<Core_Contact_Entitlement__c> contactEntitlementlist = new List<Core_Contact_Entitlement__c>();
            Core_Contact_Entitlement__c contactEntitlementCCFClaimSub = Core_MDF_CCP_TestDataUtility.createContactEntitlement(conRecord1.Id,entitlementCCFClaimSub.Id ,true,'Complete', false);
        Core_Contact_Entitlement__c contactEntitlementCCFClaimSub2 = Core_MDF_CCP_TestDataUtility.createContactEntitlement(conRecord2.Id,entitlementCCFClaimSub.Id ,true,'Complete', false);
		Core_Contact_Entitlement__c contactEntitlementCCFClaimSub3 = Core_MDF_CCP_TestDataUtility.createContactEntitlement(conRecord3.Id,entitlementCCFClaimSub.Id ,true,'Complete', false);
        contactEntitlementlist.add(contactEntitlementCCFClaimSub);
        contactEntitlementlist.add(contactEntitlementCCFClaimSub2);
        contactEntitlementlist.add(contactEntitlementCCFClaimSub3);
         
        Database.insert(contactEntitlementlist);
        List<User> users = new List<User>();
        UserRole userRole_1 = [SELECT Id FROM UserRole WHERE DeveloperName = 'Admin' LIMIT 1];
        usr1.Email='test123@example.com';
        usr1.ContactId = conRecord1.Id;
        usr1.ProfileId = profileId;
        usr1.isActive = true;
        //usr2.UserRoleId = userRole_1.Id;
        users.add(usr1);
        
        usr2.Email='test123@example.com';
        usr2.ContactId = conRecord2.Id;
        usr2.ProfileId = profileId;
        usr2.isActive = true;
            users.add(usr2);
        //usr2.UserRoleId = userRole_1.Id;
        Database.insert(users);
            
        usr3.Email='test123@example.com';
        usr3.ContactId = conRecord3.Id;
        usr3.ProfileId = profileId;
        usr3.isActive = true;
        //usr2.UserRoleId = userRole_1.Id;
        Database.insert(usr3);
            
        }
        
        test.startTest();
        
        system.runAs(usr2){
            Core_MDF_RecoveryDashboardController.AccountUserDataWrapper accExt = Core_MDF_RecoveryDashboardController.getAccountIdToNameMap(Core_MDF_CCP_ConstantClass.CCF_PROGRAM);
            Core_MDF_RecoveryDashboardController.AccountUserDataWrapper accExt1 = Core_MDF_RecoveryDashboardController.getAccountIdToNameMap(Core_MDF_CCP_ConstantClass.RMF_PROGRAM);
            Core_MDF_RecoveryDashboardController.ProgramUserDataWrapper prgrmOpt = Core_MDF_RecoveryDashboardController.getProgramIdToNameMap();
            Assert.isNotNull(accExt);
        }
        
        system.runAs(usr1){
            Core_MDF_RecoveryDashboardController.AccountUserDataWrapper accExt = Core_MDF_RecoveryDashboardController.getAccountIdToNameMap(Core_MDF_CCP_ConstantClass.CCF_PROGRAM);
            Core_MDF_RecoveryDashboardController.AccountUserDataWrapper accExt1 = Core_MDF_RecoveryDashboardController.getAccountIdToNameMap(Core_MDF_CCP_ConstantClass.RMF_PROGRAM);
            Core_MDF_RecoveryDashboardController.ProgramUserDataWrapper prgrmOpt = Core_MDF_RecoveryDashboardController.getProgramIdToNameMap();
        }
        
        system.runAs(usr3){
            Core_MDF_RecoveryDashboardController.AccountUserDataWrapper accExt = Core_MDF_RecoveryDashboardController.getAccountIdToNameMap(Core_MDF_CCP_ConstantClass.CCF_PROGRAM);
            Core_MDF_RecoveryDashboardController.AccountUserDataWrapper accExt1 = Core_MDF_RecoveryDashboardController.getAccountIdToNameMap(Core_MDF_CCP_ConstantClass.RMF_PROGRAM);
            Core_MDF_RecoveryDashboardController.ProgramUserDataWrapper prgrmOpt = Core_MDF_RecoveryDashboardController.getProgramIdToNameMap();
        }
		test.stopTest();
        
    }
    
    @isTest
    static void testGetAccountIdToNameMap(){
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1]; 
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.LastName = 'User Test';
        usr.UserRoleId = usRole.Id;
        Database.insert(usr);
        system.runAs(usr) {
        Core_MDF_RecoveryDashboardController.AccountUserDataWrapper acc = Core_MDF_RecoveryDashboardController.getAccountIdToNameMap(Core_MDF_CCP_ConstantClass.CCF_PROGRAM);
            Assert.isNotNull(acc);
        }
    }
    
    @isTest
    static void testGetQuarterOptionsMap(){
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1]; 
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.LastName = 'User Test';
        usr.UserRoleId = usRole.Id;
        Database.insert(usr);
        system.runAs(usr) {
        List<String> q = Core_MDF_RecoveryDashboardController.getQuarterOptionsMap();
            Assert.isNotNull(q);
          
        }
    }
    
   
   
    @isTest
    static void testWrappers(){
        Core_MDF_RecoveryClaimReportViewCtrl.ReportColumns rc =  new Core_MDF_RecoveryClaimReportViewCtrl.ReportColumns();
        rc.editable = true;
        
        Account acc1 = [select id from Account where name='ARP Test Account' limit 1];
        Core_MDF_RecoveryClaimReportViewCtrl.RightReportRows rrr =  new Core_MDF_RecoveryClaimReportViewCtrl.RightReportRows();
        rrr.mode = 'read';
        rrr.onSelect = 'true';
        rrr.accountId = String.valueOf(acc1.Id);
        rrr.program = 'Intel Partner alliance';
        rrr.quarter = 'Q1 2023';
    }

}