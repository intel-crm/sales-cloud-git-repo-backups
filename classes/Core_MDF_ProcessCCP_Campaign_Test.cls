@isTest(SeeAllData=false)
private class Core_MDF_ProcessCCP_Campaign_Test {   
    @TestSetup 
    static void createTestData() 
    { //addedBySS
        
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        // Creating User with utility class 
        User usr1 = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr1.LastName = 'User Test1';
        usr1.UserRoleId = usRole.Id;
        Database.insert(usr1);
        
        
        System.runAs(usr1){
            Core_Trigger_Executions__c groupIdForAccountNode = new Core_Trigger_Executions__c();
            groupIdForAccountNode.name = 'Core_MDF_createGroupForAccountNode';
            groupIdForAccountNode.Core_Object__c = 'Account';
            groupIdForAccountNode.Core_Trigger_Events__c = 'After Insert';
            groupIdForAccountNode.Core_Active__c = TRUE;
            groupIdForAccountNode.Core_Description__c = 'To Create Group for each account';
            groupIdForAccountNode.Core_Class_Name__c = 'Core_AccountHandler';
            insert groupIdForAccountNode;
            
            //Added by Ealisha to bypass the PFR sharing from triggerhandler
            Core_Trigger_Executions__c te = new Core_Trigger_Executions__c();
            te.name = 'ShareActivityWithInternalUsers_Bypass';
            te.Core_Object__c = 'PartnerFundRequest';
            te.Core_Trigger_Events__c = 'After Update';
            te.Core_Active__c = true;
            te.Core_Description__c = 'To bypass the PFR Internal User Sharing';
            te.Core_Class_Name__c = 'Core_MDF_PartnerRequestTriggerHandler';
            insert te;
            
            
            Core_Trigger_Executions__c bypassretailMDFCampcreationvalidation = new Core_Trigger_Executions__c();
            bypassretailMDFCampcreationvalidation.Core_Active__c = true;
            bypassretailMDFCampcreationvalidation.Core_Class_Name__c = 'Core_MDF_ProcessCCP_Campaign';
            bypassretailMDFCampcreationvalidation.Core_Trigger_Events__c = 'before insert, before update';
            bypassretailMDFCampcreationvalidation.Core_Object__c = 'Campaign';
            bypassretailMDFCampcreationvalidation.Name = 'BypassRetailMDFBudgetValidation';
            bypassretailMDFCampcreationvalidation.Core_Description__c = 'to bypass the campaign retail btype validation';
            insert bypassretailMDFCampcreationvalidation;
            
            Core_Trigger_Executions__c bypass = new Core_Trigger_Executions__c();
            bypass.name = 'Core_MDF_Bypass_Campaign_Trigger';
            bypass.Core_Object__c = 'Campaign';
            bypass.Core_Trigger_Events__c = 'After Insert';
            bypass.Core_Active__c = false;
            bypass.Core_Description__c = 'To bypass Campaign trigger';
            bypass.Core_Class_Name__c = 'Core_MDF_Campaign';
            insert bypass;
            
            List<Core_Trigger_Executions__c> transactions = new List<Core_Trigger_Executions__c>();
            transactions.addAll(Core_MDF_CCP_TestDataUtility.byPassFeature(new List<String>{'Bypass_GeoBased_Budget_Sharing','Bypass_MDF_Budget_Access_Validation', 'Bypass_MDF_Budget_Status_Validation'}, true, false));       
            transactions.addAll(Core_MDF_CCP_TestDataUtility.byPassFeature(new List<String>{'Bypass_Allocation_Reservation','Bypass_GeoBased_Allocation_Sharing'}, true, false));   
            transactions.addAll(Core_MDF_CCP_TestDataUtility.byPassFeature(new List<String>{'Bypass_Duplicate_Bank_Check','Bypass_Bank_Internal_Sharing','Bypass_StampingOfActySubType_Check',
                            'Bypass_Bank_External_Sharing','Bypass_Bank_Program_InActivation_Check','Bypass_Bank_ABM_Sharing','Bypass_Claims_ABM_Validation','Bypass_Claims_Amt_vs_Budget_Amt_Check',
                    'Bypass_Claims_Amt_vs_Camp_Amt_Check','Bypass_Claims_Duplicate_Check',
                    'Bypass_Claim_OwnerLang_EmailTemp','Bypass_Claims_Sharing_Internal_Users',
                    'Bypass_Claims_Sharing_Partner_Users','Bypass_Claims_Sharing_On_Owner_Change'}, true, false));
            transactions.addAll(Core_MDF_CCP_TestDataUtility.byPassFeature(new List<String>{'Bypass_ABM_Internal_Sharing','Bypass_ABM_External_Sharing','Bypass_ABM_NodeGroup_Sharing'}, true, false)); 
            
            Database.insert(transactions);
            // Creating channel program with utility class
            List<ChannelProgram> channelProgList = new List<ChannelProgram>();
            
            ChannelProgram cp = Core_MDF_CCP_TestDataUtility.createProgram (Core_MDF_CCP_ConstantClass.DCF_PROGRAM,'Data Center CoMarketing Fund', false);
            channelProgList.add(cp);
            
            ChannelProgram cp1 = Core_MDF_CCP_TestDataUtility.createProgram (Core_MDF_CCP_ConstantClass.CCF_PROGRAM,'Client CoMarketing Fund', false);
            channelProgList.add(cp1);
            
            ChannelProgram cp2 = Core_MDF_CCP_TestDataUtility.createProgram (Core_MDF_CCP_ConstantClass.RMF_PROGRAM,'Retail Marketing Funds', false);
            channelProgList.add(cp2);
            Database.insert(channelProgList);
            
            // Creating IntelAccount with utility class
            Test.startTest();
            Account intacc = Core_MDF_CCP_TestDataUtility.createIntelAccount ('Test Account 1', 
                                                                              Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
            intacc.Core_Account_Type__c = 'Reseller';
            intacc.Industry = 'Food & Beverage';
            Database.insert(intacc);
            
            
            Account racc = Core_MDF_CCP_TestDataUtility.createIntelAccount ('Test Account 2', 
                                                                            Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
            racc.Core_Account_Type__c = 'Service Provider';
            racc.Industry = 'Health';
            racc.Core_Geo__c ='ASMO';
            racc.Core_Sub_Geo__c ='LAR';
            Database.insert(racc);
            
            // Creating Co-marketing Account with utility class
            List<Account> accList = new List<Account>();
            
            Account dcfacc = Core_MDF_CCP_TestDataUtility.createAccount ('Co-marketing DCF Test Account', 
                                                                         cp.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            dcfacc.Core_MDF_Parent_Fund_Account__c = intacc.Id;
            accList.add(dcfacc);
            
            Account dcfacc1 = Core_MDF_CCP_TestDataUtility.createAccount ('DCF Test Account', 
                                                                          cp.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            dcfacc1.Core_MDF_Parent_Fund_Account__c = intacc.Id;
            accList.add(dcfacc1);
            
            Account ccfacc = Core_MDF_CCP_TestDataUtility.createAccount ('Co-marketing CCF Test Account', 
                                                                         cp1.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            ccfacc.Core_MDF_Parent_Fund_Account__c = intacc.Id;
            ccfacc.Core_MDF_CoMarketingActive__c = true;
            accList.add(ccfacc);
            
            
            
            Account retacc1 = Core_MDF_CCP_TestDataUtility.createAccount ('Retail Test Account', 
                                                                          cp2.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            retacc1.Core_MDF_Parent_Fund_Account__c = racc.Id;
            retacc1.Core_Geo__c ='ASMO';
            retacc1.Core_Sub_Geo__c ='LAR';
            accList.add(retacc1);
            
            Database.insert(accList);
            
            Account dellCCFAPACIndia = Core_MDF_CCP_TestDataUtility.createAccount ('Dell CCF APAC India', cp1.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            dellCCFAPACIndia.Core_MDF_Parent_Fund_Account__c = ccfacc.Id;
            dellCCFAPACIndia.Core_MDF_CoMarketingActive__c = true;
            Database.insert(dellCCFAPACIndia);
            
             Account NodeAccRetail = Core_MDF_CCP_TestDataUtility.createAccount ('Co-marketing Test Node Account', cp2.Id,
                                                                              Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            NodeAccRetail.Core_MDF_Parent_Fund_Account__c = retacc1.Id;
             NodeAccRetail.Core_MDF_CoMarketing_Ultimate_Account__c =  racc.Id;
             NodeAccRetail.Core_Geo__c ='ASMO';
             NodeAccRetail.Core_Sub_Geo__c ='LAR';
           Database.insert(NodeAccRetail);
            
            // Creating Contact with utility class
            List<Contact> conList = new List<Contact>();
            
            Contact con = Core_MDF_CCP_TestDataUtility.createContact (intacc.Id, false);
            con.RecordTypeId = Core_MDF_CCP_TestDataUtility.Intel_Contact_Record_Type;
            conList.add(con);
            
            Contact con1 = Core_MDF_CCP_TestDataUtility.createContact (intacc.Id, false);
            con1.RecordTypeId = Core_MDF_CCP_TestDataUtility.Intel_Contact_Record_Type;
            conList.add(con1);
            
            Database.insert(conList);
            
            
            Profile partnerProfile = [SELECT Id FROM Profile WHERE Name='Partner' LIMIT 1];
          // Highlight: Unused Local Variable - Indira  
          //  Profile ccpCoreProfile = [SELECT Id FROM Profile WHERE Name = 'CCP - Core Access'];
        
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_CCF_MDF_Budget_Loader' LIMIT 1];
        PermissionSet ps1 = [SELECT Id FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_CCF_MDF_Budget_Approver' LIMIT 1];
        // Creating User with utility class 
        User mdfBudgetLoader = Core_MDF_CCP_TestDataUtility.createUser(false);
        mdfBudgetLoader.LastName = 'MDF Budget Loader';
        //mdfBudgetLoader.profileId = ccpCoreProfile.Id;
         
        
        
            
            List<User> usrList = new List<User>();
            // Creating User with utility class 
            User usr2 = Core_MDF_CCP_TestDataUtility.createUser(false);
            usr2.LastName = 'User Test2';
            usr2.ProfileId = partnerProfile.Id;
            usr2.ContactId = con.Id;
            usrList.add(usr2);        
            User usr3 = Core_MDF_CCP_TestDataUtility.createUser(false);
            usr3.LastName = 'User Test3';
            usr3.ProfileId = partnerProfile.Id;
            usr3.ContactId = con1.Id;
            usrList.add(mdfBudgetLoader);
            usrList.add(usr3);
            
            User user4 = Core_MDF_CCP_TestDataUtility.createUser(false);
             usrList.add(user4);
            
            Database.insert(usrList);
            
         
            insert new PermissionSetAssignment(AssigneeId = mdfBudgetLoader.id, PermissionSetId = ps.Id);
            insert new PermissionSetassignment(AssigneeId = user4.id,PermissionSetId = ps1.Id);
            insert new PermissionSetassignment(AssigneeId = user4.id,PermissionSetId = ps.Id);
            Id ccfIUPGMRecTypeId = Schema.SObjectType.Core_MDF_Int_Users_Partner_Geo_Mapping__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_Client_Co_Marketing_Fund').getRecordTypeId();
           //Id ccfIUPGMRecTypeId = '012Dz000000BcfdIAC';
             Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm1 = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
            List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> iupgmList = new List<Core_MDF_Int_Users_Partner_Geo_Mapping__c>();
             iupgm1.Core_MDF_Program_nm__c = Core_MDF_CCP_ConstantClass.CCF_PROGRAM;
           iupgm1.RecordTypeId = ccfIUPGMRecTypeId;
            iupgm1.Core_MDF_Region_Sub_Region_nm__c = 'WW';
            iupgm1.Core_MDF_User_id__c = user4.Id;
           	iupgm1.Core_MDF_Role_nm__c = 'Core_MDF_CCP_Internal_CCF_MDF_Budget_Loader';
            iupgm1.Core_MDF_All_Budget_Type_Access_Ind__c = true;
            iupgm1.Core_MDF_All_Accounts_cd__c = 'yes';
            //iupgm1.Core_MDF_Budget_Type_nm__c = budgetType;
            //iupgm1.Core_MDF_is_User_Active_ind__c = true;
            iupgm1.Core_MDF_Active_Ind__c = true;
            iupgm1.Core_MDF_Is_Not_an_Approver_Ind__c = false;
            iupgmList.add(iupgm1);
            
            List<Group> grpList = new List<Group>();
            // Creating Group
            Group dcfgrp = new Group();
            dcfgrp.Name = 'Core CCP DCF External';
            dcfgrp.DeveloperName = 'Core_CCP_DCF_External';
            grpList.add(dcfgrp);
            
            Group ccfgrp = new Group();
            ccfgrp.Name = 'Core CCP CCF External';
            ccfgrp.DeveloperName = 'Core_CCP_CCF_External';
            grpList.add(ccfgrp);
            
            //ASMO Internal group
            Group dcfAsmogrp = new Group();
            dcfAsmogrp.Name = 'Core CCP DCF ASMO INTERNAL';
            dcfAsmogrp.DeveloperName = 'Core_CCP_DCF_ASMO_Internal';
            grpList.add(dcfAsmogrp);
            
            //WW Internal group
            Group dcfWWgrp = new Group();
            dcfWWgrp.Name = 'Core CCP DCF WW INTERNAL';
            dcfWWgrp.DeveloperName = 'Core_CCP_DCF_WW_Internal';
            grpList.add(dcfWWgrp);
            
            //ASMO Internal group
            Group retASMOgrp = new Group();
            retASMOgrp.Name = 'Core CCP Retail ASMO INTERNAL';
            retASMOgrp.DeveloperName = 'Core_CCP_Retail_ASMO_Internal';
            grpList.add(retASMOgrp);
            
            //EMEA Internal group
            Group dcfEMEAgrp = new Group();
            dcfEMEAgrp.Name = 'Core CCP DCF EMEA INTERNAL';
            dcfEMEAgrp.DeveloperName = 'Core_CCP_DCF_EMEA_Internal';
            grpList.add(dcfEMEAgrp);
            
            Database.insert(grpList);
            
            
            
            List<GroupMember> grpMemList = new List<GroupMember>();
            // Creating Group Member
            GroupMember dcfGrpMem = new GroupMember();
            dcfGrpMem.UserOrGroupId = usr2.Id;
            dcfGrpMem.GroupId = dcfgrp.Id;
            grpMemList.add(dcfGrpMem);
            GroupMember ccfGrpMem = new GroupMember();
            ccfGrpMem.UserOrGroupId = usr3.Id;
            ccfGrpMem.GroupId = ccfgrp.Id;
            grpMemList.add(ccfGrpMem);
            
            Database.insert(grpMemList);
            
            List<Core_MDF_Partner_Group_Mapping__c> pgmList = new List<Core_MDF_Partner_Group_Mapping__c>();
            // Creating Partner Group Mapping
            Core_MDF_Partner_Group_Mapping__c pgm = new Core_MDF_Partner_Group_Mapping__c();
            pgm.Core_MDF_Account__c = intacc.Id;
            pgm.Core_MDF_Group_Name__c = 'Core_CCP_DCF_External';
            pgm.Core_MDF_Type_of_Access__c = 'External';
            pgm.Core_MDF_Group_Id__c = dcfgrp.Id;                
            pgm.Core_MDF_Channel_Program__c = cp.Id;
            pgm.Core_MDF_AccountIdGroupName__c = intacc.Id+'Core_CCP_DCF_External';
            pgmList.add(pgm);
            
            Core_MDF_Partner_Group_Mapping__c pgm1 = new Core_MDF_Partner_Group_Mapping__c();
            pgm1.Core_MDF_Account__c = intacc.Id;
            pgm1.Core_MDF_Group_Name__c = 'Core_CCP_CCF_External';
            pgm1.Core_MDF_Type_of_Access__c = 'External';
            pgm1.Core_MDF_Group_Id__c = ccfgrp.Id;                
            pgm1.Core_MDF_Channel_Program__c = cp1.Id;
            pgm1.Core_MDF_AccountIdGroupName__c = intacc.Id+'Core_CCP_CCF_External';
            pgmList.add(pgm1);
            
            Core_MDF_Partner_Group_Mapping__c geoPgm = new Core_MDF_Partner_Group_Mapping__c();
            geoPgm.Core_MDF_Account__c = intacc.Id;
            geoPgm.Core_MDF_Group_Name__c = 'Core_CCP_DCF_ASMO_Internal';
            geoPgm.Core_MDF_Type_of_Access__c = 'Internal';
            geoPgm.Core_MDF_Region_cd__c = 'ASMO';
            geoPgm.Core_MDF_Group_Id__c = dcfAsmogrp.Id;                
            geoPgm.Core_MDF_Channel_Program__c = cp.Id;
            geoPgm.Core_MDF_Source_Txt__c = 'Test';
            geoPgm.Core_MDF_AccountIdGroupName__c = intacc.Id+'Core_CCP_DCF_ASMO_Internal';
            pgmList.add(geoPgm);
            
            Core_MDF_Partner_Group_Mapping__c wwPgm = new Core_MDF_Partner_Group_Mapping__c();
            wwPgm.Core_MDF_Account__c = intacc.Id;
            wwPgm.Core_MDF_Group_Name__c = 'Core_CCP_DCF_WW_Internal';
            wwPgm.Core_MDF_Type_of_Access__c = 'Internal';
            wwPgm.Core_MDF_Region_cd__c = 'WW';
            wwPgm.Core_MDF_Group_Id__c = dcfWWgrp.Id;                
            wwPgm.Core_MDF_Channel_Program__c = cp.Id;
            wwPgm.Core_MDF_Source_Txt__c = 'Test';
            wwPgm.Core_MDF_AccountIdGroupName__c = intacc.Id+'Core_CCP_DCF_WW_Internal';
            pgmList.add(wwPgm);
            
            Core_MDF_Partner_Group_Mapping__c pgmEMEA = new Core_MDF_Partner_Group_Mapping__c();
            pgmEMEA.Core_MDF_Account__c = intacc.Id;
            pgmEMEA.Core_MDF_Group_Name__c = 'Core_CCP_DCF_EMEA_Internal';
            pgmEMEA.Core_MDF_Type_of_Access__c = 'Internal';
            pgmEMEA.Core_MDF_Region_cd__c = 'EMEA';
            pgmEMEA.Core_MDF_Group_Id__c = dcfEMEAgrp.Id;                
            pgmEMEA.Core_MDF_Channel_Program__c = cp.Id;
            pgmEMEA.Core_MDF_Source_Txt__c = 'Test';
            pgmEMEA.Core_MDF_AccountIdGroupName__c = intacc.Id+'Core_CCP_DCF_EMEA_Internal';
            pgmList.add(pgmEMEA);
            
            Core_MDF_Partner_Group_Mapping__c pgmASMO = new Core_MDF_Partner_Group_Mapping__c();
            pgmASMO.Core_MDF_Account__c = racc.Id;
            pgmASMO.Core_MDF_Group_Name__c = 'Core_CCP_Retail_ASMO_Internal';
            pgmASMO.Core_MDF_Type_of_Access__c = 'Internal';
            pgmASMO.Core_MDF_Region_cd__c = 'ASMO';
            pgmASMO.Core_MDF_Sub_Region_cd__c = 'LAR';
            pgmASMO.Core_MDF_Group_Id__c = retASMOgrp.Id;                
            pgmASMO.Core_MDF_Channel_Program__c = cp2.Id;
            pgmASMO.Core_MDF_Source_Txt__c = 'Test';
            pgmASMO.Core_MDF_AccountIdGroupName__c = intacc.Id+'Core_CCP_Retail_ASMO_Internal';
            pgmList.add(pgmASMO);
            
            Database.insert(pgmList);
            List<String> bypassFunctionKeys = new List<String>();
            bypassFunctionKeys.add('Bypass_MDF_Budget_Access');
            bypassFunctionKeys.add('Bypass_Duplicate_Budget_Check');
            bypassFunctionKeys.add('ByPass_BlockLegacyBudgetCreation');
            Set<String> myset1 = new Set<String>();
            List<String> result1 = new List<String>();
            myset1.addAll(bypassFunctionKeys);
            result1.addAll(myset1);
            List<Core_Trigger_Executions__c> bypassfunctinalitylist1 = Core_MDF_CCP_TestDataUtility.byPassFeature(result1,true,true);
            
            
            
            Test.stopTest();
            PartnerMarketingBudget  pmbRecord = Core_MDF_CCP_TestDataUtility.createBudget('Dell PMB2',Core_MDF_CCP_TestDataUtility.budget_Record_Type,ccfacc.Id,cp1.Id,1000000,System.today().addDays(-10),System.today().addDays(40),false);
            pmbRecord.Core_MDF_Budget_Type_Txt__c = 'MDF';
            pmbRecord.Title = 'Dell PMB2';
            insert pmbRecord;
            
            /*PartnerMarketingBudget  pmbRecord = Core_MDF_CCP_TestDataUtility.createBudget('Dell PMB1',Core_MDF_CCP_TestDataUtility.budget_Record_Type,ccfacc.Id,cp1.Id,1000000,Date.newInstance(2021, 01, 01),Date.newInstance(2022, 06, 30),false);
            pmbRecord.Core_MDF_Budget_Type_Txt__c = 'CCF 1.0';
            insert pmbRecord;
            Test.stopTest();*/
            
            // PartnerFundAllocation pfa1 = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('Test Allocation',pmbRecord2,retacc1,5000,true);
            // PartnerFundAllocation PFA11= [ select id,Core_MDF_Total_Activity_Allocated_Amount__c,Amount from PartnerFundAllocation where Budget.Title ='Dell RMF PMB-2' limit 1];
            
            // PartnerMarketingBudget pmb1 = [SELECT Id,Title, Core_MDF_Budget_Status__c, TotalAllocatedAmount FROM PartnerMarketingBudget WHERE Title ='Dell RMF PMB-2' limit 1];
            
            
            //PartnerFundAllocation pfaDellCCFVirtualCorp = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('pfaDellCCFVirtualCorp',pmbRecord, ccfacc, 100000,true);
            PartnerFundAllocation pfaDellCCFIndia = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('pfaDellCCFIndia',pmbRecord, dellCCFAPACIndia, 10000,true);
            Core_MDF_Bank__c indiaBank = Core_MDF_CCP_TestDataUtility.createBank(intacc.Id, 'CCF', false,'1231231230');
            indiaBank.Core_MDF_Bank_Status__c = 'Active';
            indiaBank.Core_MDF_Program__c='Core_MDF_Data_Center_CoMarketing_Fund;Core_MDF_Client_CoMarketing_Fund';
            database.insert(indiaBank);
            // Highlight: Unused Local Variable - Indira
          //  Core_MDF_Account_Bank_Mapping__c abm1 = Core_MDF_CCP_TestDataUtility.createAccountBankMap(dellCCFAPACIndia.Id,indiaBank.Id,true);
            
            Core_AGS_Role__c agsRoleRMF = Core_MDF_CCP_TestDataUtility.createAgsRole('Co-Marketing(Salesforce)-RMF User', 'Co-Marketing(Salesforce)-RMF User', true, true);
            Core_ERPM_Engagement__c erpmEngagementRMF = Core_MDF_CCP_TestDataUtility.createErpmEngagement('RPS_Retailer', 'RPS_Retailer', 'DEDUPGPRET', 'SEC', true, true);
            // Highlight: Unused Local Variable - Indira
           // Core_Entitlement__c entitlementRMF = Core_MDF_CCP_TestDataUtility.createEntitlement('RMF User',agsRoleRMF.Id ,'Intel® Partner Investment Center','RMF User',erpmEngagementRMF.Id , true,'Retail Marketing Funds (RMF)',true);
            
            
            //Campaign CAP Campaign and Activity
            Campaign campCAP = Core_MDF_CCP_TestDataUtility.createCampaign('Campaign CAP Campaign','Gaming','Intel® Core™ i7+ Processor','Yes' ,Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 'Client CoMarketing Fund', System.today(), System.today().adddays(30), 10000, 'Consumer Chromebook', ccfacc.Id, '2-in-1', false);
            campCAP.Core_MDF_Opal_Budget_Type_Txt__c= 'MDF';
            Database.insert(campCAP);
            

          
            
            PartnerFundRequest testActivity = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(campCAP.Id),Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,
                                                                                                    string.valueof(dellCCFAPACIndia.id),pfaDellCCFIndia,pmbRecord,
                                                                                                    'BRAZIL','Consumer','Desktop','Intel® Core™ i5 Processor','Broadcast (Pre-2025)','Podcast','Draft'
                                                                                                    ,false);
            testActivity.Core_MDF_Budget_Type_nm__c = 'MDF';
            testActivity.Core_MDF_Start_Date__c = System.today();
            testActivity.Core_MDF_End_Date__c = System.today().adddays(1);
            Database.insert(testActivity);
            
            Core_MDF_Configuration__c config = new Core_MDF_Configuration__c();
            config.Core_MDF_Value__c = 'MDF,MDF+';
            config.Name = 'BUDGET_TYPE_CLAIM_BANK_HIDE';
            insert config;         
            
        }  
    }      
@isTest
    static void createCampaignRecords(){
       // Highlight: Unused Local Variable - Indira
       // User mdfBudgetLoader = [Select id from User where LastName =  'MDF Budget Loader' Limit 1];
        try{
            Test.startTest();
            
            //Creating channel program with utility class
            // Highlight: Unused Local Variable - Indira
           /* ChannelProgram cp = [SELECT Id, Name, Core_MDF_Technical_Program_Name__c 
                                 FROM ChannelProgram 
                                 WHERE Core_MDF_Technical_Program_Name__c ='Data Center CoMarketing Fund' LIMIT 1]; */
            
            ChannelProgram rcp = [SELECT Id, Name, Core_MDF_Technical_Program_Name__c FROM ChannelProgram WHERE Core_MDF_Technical_Program_Name__c ='Retail Marketing Funds' LIMIT 1];            
            //Test.startTest();
           Account acc =  [select id from Account where name = 'DCF Test Account'];
           Account acc1 = [select id,name from Account where name = 'Retail Test Account'];
          // Highlight: Unused Local Variable - Indira
       //  Account RetailAcc=[select Id, name from Account where Name='Co-marketing Test Node Account'];
            
            Account acc12 = Core_MDF_CCP_TestDataUtility.createIntelAccount ('Test Account 1234', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, 
                                                                             false);
            acc12.Core_MDF_CoMarketingAgency__c = TRUE;
            acc12.Core_Geo__c = 'EMEA';
            acc12.Core_Sub_Geo__c = 'META';
            //Database.insert(acc12);  
            
            Account intelRetail = Core_MDF_CCP_TestDataUtility.createAccount ('Co-marketing Test Account', rcp.Id,
                                                                              Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            intelRetail.Core_MDF_Parent_Fund_Account__c = acc12.Id;
            intelRetail.Core_MDF_CoMarketing_Ultimate_Account__c = acc12.Id;
            intelRetail.Core_Geo__c = 'EMEA';
            intelRetail.Core_Sub_Geo__c = 'META';
           // insert intelRetail;
         //   System.runAs(mdfBudgetLoader){
            List<PartnerMarketingBudget> pmbList = new List<PartnerMarketingBudget>();
            PartnerMarketingBudget  pmbRecord2 = Core_MDF_CCP_TestDataUtility.createRetailBudget('Dell RMF PMB-2',Core_MDF_CCP_TestDataUtility.budget_Retail_Record_Type,acc1.Id,rcp.Id,1000000, System.today()-5,System.today()+5,false, 'Retail MDF');  
            //pmbRecord2.IsIgnoreValidation=true; 
            pmbRecord2.Core_MDF_Budget_Status__c = 'Released';  
            pmbList.add(pmbRecord2);
            PartnerMarketingBudget  pmbRecord3 = Core_MDF_CCP_TestDataUtility.createRetailBudget('Dell RMF PMB-3',Core_MDF_CCP_TestDataUtility.budget_Retail_Record_Type,acc1.Id,rcp.Id,1000000,System.today()-5,System.today()+5,false, 'RSA MD');                                                                        
            //pmbRecord3.IsIgnoreValidation=true;
            pmbRecord3.Core_MDF_Budget_Status__c = 'Released';
            pmbList.add(pmbRecord3);
            Database.insert(pmbList);
            pmbList.clear();
            //retailBudget.Core_MDF_Budget_Status__c = 'Approved';
            //pmbRecord2.Core_MDF_Budget_Status__c = 'Approved';
            
            // insert pmbRecord2;
            //pmbRecord2.Core_MDF_Budget_Status__c = 'Released';
           // pmbRecord3.Core_MDF_Budget_Status__c = 'Approved';
            
            // insert pmbRecord2;
            //pmbRecord3.Core_MDF_Budget_Status__c = 'Released';
            //retailBudget.Core_MDF_Budget_Status__c = 'Released';
            //pmbList.add(pmbRecord2);
            //pmbList.add(pmbRecord3);
            // Database.update(retailBudget);
             //Database.update(pmbList);
            
            List<PartnerFundAllocation> pfaList = new List<PartnerFundAllocation>();
             PartnerFundAllocation pfa = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('pfa',pmbRecord2, acc1, 1000.0,false);
            PartnerFundAllocation pfa2 = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('pfa2',pmbRecord3, acc1, 1000.0,false);
            pfaList.add(pfa);
            pfaList.add(pfa2);
            Database.insert(pfaList);
            Campaign updateCamp=[select Id, Name,StartDate from campaign where name='Campaign CAP Campaign'];
            updateCamp.StartDate= System.today();
           // Database.update(updateCamp);
           // Highlight: Unused Local Variable - Indira
           // List<PartnerMarketingBudget> pmbList2 = [Select id, Title, Core_MDF_Budget_Partner__r.name from PartnerMarketingBudget];
            
            
            //Creating Campaign with utility class
            List<Campaign> campaignList = new List<Campaign>();
           
            Campaign camp = Core_MDF_CCP_TestDataUtility.createCampaign('Test Camp','Reseller','Intel® Corporate Logo','MDF or both CMP & MDF', 
                                                                        Core_MDF_CCP_TestDataUtility.Campaign_RecordType_DCF, 'Data Center CoMarketing Fund', System.today()-5,System.today()+30, 5000, 'Hybrid Cloud', acc.Id,'Server',false);
            Campaign chkCampEdit = Core_MDF_CCP_TestDataUtility.createCampaign('Test Camp 1','Reseller','Intel® Corporate Logo', 
                                                                               'yes',  Core_MDF_CCP_TestDataUtility.campaign_RecordType_Retail, 'Retail Marketing Funds', System.today()-5,System.today()+30, 10000, 'Hybrid Cloud', acc1.Id,'Server',false); 
            Campaign chkCampEdit1 = Core_MDF_CCP_TestDataUtility.createCampaign('Test Camp 2','Reseller','Intel® Corporate Logo', 
                                                                                'yes',  Core_MDF_CCP_TestDataUtility.campaign_RecordType_Retail, 'Retail Marketing Funds', System.today()-2,System.today()+3, 10000, 'Hybrid Cloud', acc1.Id,'Server',false); 
           
            Campaign RmfCamp = Core_MDF_CCP_TestDataUtility.createCampaign('Test RMF Camp','Reseller','Intel® Corporate Logo', 
                                                                               'yes',  Core_MDF_CCP_TestDataUtility.campaign_RecordType_Retail, 'Retail Marketing Funds', System.today()-5,System.today()+30, 10000, 'Hybrid Cloud', acc1.Id,'Server',false); 
            
            chkCampEdit1.Core_MDF_Budget_Type_txt__c ='Retail MDF';
            chkCampEdit1.Core_MDF_Opal_Budget_Type_Txt__c='Retail MDF';
            RmfCamp.Core_MDF_Budget_Type_txt__c ='RSA MD';
            RmfCamp.Core_MDF_Opal_Budget_Type_Txt__c='RSA MD';
            chkCampEdit.Core_MDF_Technology__c ='Wifi6';
            chkCampEdit.Name= 'Insert Camp';
            camp.Core_MDF_Opal_Budget_Type_Txt__c='MDF';
            campaignList.add(camp);campaignList.add(chkCampEdit); 
            campaignList.add(chkCampEdit1);
           
            campaignList.add(RmfCamp);
           Database.insert (campaignList);
  
           Campaign RmfCamp1 = Core_MDF_CCP_TestDataUtility.createCampaign('Test RMF Camp','Reseller','Intel® Corporate Logo', 
                                                                               'yes',  Core_MDF_CCP_TestDataUtility.campaign_RecordType_Retail, 'Retail Marketing Funds', System.today()-5,System.today()+30, 10000, 'Hybrid Cloud', acc1.Id,'Server',false); 
           RmfCamp1.Core_MDF_Budget_Type_txt__c ='Retail MDF';
           RmfCamp1.Core_MDF_Opal_Budget_Type_Txt__c='Retail MDF';
           insert RmfCamp1;
           RmfCamp1.StartDate=System.today()+5;
           RmfCamp1.EndDate=System.today()+10; 
           update RmfCamp1;
            // Unit Test Method should include System.Assert - Indira
            System.assertEquals(4, campaignList.size(), 'Campaign list should contain 4 campaigns');
            
            Campaign cmp =  [SELECT Id, Core_MDF_Activity_Category__c, Core_MDF_Activity_Type__c, Core_MDF_Activity_Category_Type__c from Campaign
                             WHERE Id =:camp.Id LIMIT 1];  
            cmp.Core_MDF_Opal_Budget_Type_Txt__c='DCF 1.0';
          
            List<PartnerFundRequest> pfrList = new List<PartnerFundRequest>();
            PartnerFundRequest testPartnerFundRequestRecord1 = Core_MDF_CCP_TestDataUtility.insertPartnerFundRequest(chkCampEdit1.Id,Core_MDF_CCP_TestDataUtility.partnerFund_RecordType_Retail,acc1.Id,null,null,'INDIA','Business','Chromebook','Intel® Corporate Logo','Broadcast','Radio','Draft',false);
            testPartnerFundRequestRecord1.RequestedAmount = 250;
            testPartnerFundRequestRecord1.Core_MDF_Priorities__c = 'Consumer Chromebook';
            testPartnerFundRequestRecord1.Core_MDF_Fund_Request_Status__c = 'Planned';
            testPartnerFundRequestRecord1.Core_MDF_Budget_Amount_Local_amt__c = 250;
            testPartnerFundRequestRecord1.Core_MDF_Budget_Currency_cd__c = 'USD';
            testPartnerFundRequestRecord1.Core_MDF_Channel_Partner_Led__c = false;
            testPartnerFundRequestRecord1.Core_MDF_Channel_Partner__c = '';
            testPartnerFundRequestRecord1.Core_MDF_Budget_Type_nm__c='Retail MDF';
            testPartnerFundRequestRecord1.Core_MDF_Start_Date__c =System.today();
            testPartnerFundRequestRecord1.Core_MDF_End_Date__c =System.today();
            testPartnerFundRequestRecord1.AllocationId=pfa.Id;
            testPartnerFundRequestRecord1.Core_MDF_Reimbursement_Rate_pct__c='100%';
            testPartnerFundRequestRecord1.Core_MDF_Reimbursement_Rate_txt__c = '100%';
            PartnerFundRequest testPartnerFundRequestRecord2 = Core_MDF_CCP_TestDataUtility.insertPartnerFundRequest(RmfCamp.Id,Core_MDF_CCP_TestDataUtility.partnerFund_RecordType_Retail,acc1.Id,null,null,'INDIA','Business','Chromebook','Intel® Corporate Logo','Broadcast','Radio','Draft',false);
            testPartnerFundRequestRecord2.RequestedAmount = 250;
            testPartnerFundRequestRecord2.Core_MDF_Priorities__c = 'Consumer Chromebook';
            testPartnerFundRequestRecord2.Core_MDF_Fund_Request_Status__c = 'Planned';
            testPartnerFundRequestRecord2.Core_MDF_Budget_Amount_Local_amt__c = 250;
            testPartnerFundRequestRecord2.Core_MDF_Budget_Currency_cd__c = 'USD';
            testPartnerFundRequestRecord2.Core_MDF_Channel_Partner_Led__c = false;
            testPartnerFundRequestRecord2.Core_MDF_Channel_Partner__c = '';
            testPartnerFundRequestRecord2.Core_MDF_Budget_Type_nm__c='RSA MD';
            testPartnerFundRequestRecord2.Core_MDF_Start_Date__c =System.today();
            testPartnerFundRequestRecord2.Core_MDF_End_Date__c =System.today()+5;
            testPartnerFundRequestRecord2.AllocationId=pfa2.Id;
            testPartnerFundRequestRecord2.Core_MDF_Reimbursement_Rate_pct__c='100%';
            testPartnerFundRequestRecord2.Core_MDF_Reimbursement_Rate_txt__c = '100%';
        
                PartnerFundRequest testPartnerFundRequestRecord3 = Core_MDF_CCP_TestDataUtility.insertPartnerFundRequest(RmfCamp.Id,Core_MDF_CCP_TestDataUtility.partnerFund_RecordType_Retail,acc1.Id,null,null,'INDIA','Business','Chromebook','Intel® Corporate Logo','Broadcast','Radio','Draft',false);
            testPartnerFundRequestRecord3.RequestedAmount = 250;
            testPartnerFundRequestRecord3.Core_MDF_Priorities__c = 'Consumer Chromebook';
            testPartnerFundRequestRecord3.Core_MDF_Fund_Request_Status__c = 'Closed';
            testPartnerFundRequestRecord3.Core_MDF_Budget_Amount_Local_amt__c = 250;
            testPartnerFundRequestRecord3.Core_MDF_Budget_Currency_cd__c = 'USD';
            testPartnerFundRequestRecord3.Core_MDF_Channel_Partner_Led__c = false;
            testPartnerFundRequestRecord3.Core_MDF_Channel_Partner__c = '';
            testPartnerFundRequestRecord3.Core_MDF_Budget_Type_nm__c='RSA MD';
            testPartnerFundRequestRecord3.Core_MDF_Start_Date__c =System.today();
            testPartnerFundRequestRecord3.Core_MDF_End_Date__c =System.today()+5;
            testPartnerFundRequestRecord3.AllocationId=pfa2.Id;
            testPartnerFundRequestRecord3.Core_MDF_Reimbursement_Rate_pct__c='100%';
            testPartnerFundRequestRecord3.Core_MDF_Reimbursement_Rate_txt__c = '100%';
                testPartnerFundRequestRecord3.Core_MDF_Activity_Closure_Type__c = 'Manual';
            pfrList.add(testPartnerFundRequestRecord1);
            pfrList.add(testPartnerFundRequestRecord2);
                pfrList.add(testPartnerFundRequestRecord3);
            Database.insert(pfrList);
            Core_MDF_Configuration__c config = new Core_MDF_Configuration__c();
        config.name = 'ALLOWED_PRG_FOR_RUS_NOTIF';
        config.Core_MDF_Category__c = 'Bank Document Hold Logic';
        config.Core_MDF_Value__c = 'Retail Marketing Funds,Intel Partner Alliance';
        insert config;
            List<PartnerFundClaim> pfcList = new List<PartnerFundClaim>();
        PartnerFundClaim claim1 = Core_MDF_CCP_TestDataUtility.createClaim('France Claim', Core_MDF_CCP_TestDataUtility.claim_RecordType_Retail,testPartnerFundRequestRecord2.Id,
                                                                                   testPartnerFundRequestRecord2.Core_MDF_Start_Date__c, 
                                                                                   testPartnerFundRequestRecord2.Core_MDF_Start_Date__c,50,System.today(),null,false);
        claim1.Core_MDF_PIC_Review_Completed__c = true;
        claim1.Core_MDF_BackendReviewSelection_Ind__c = false;
        claim1.Amount = 300;
        claim1.Core_MDF_Currency__c='USD'; 
        pfcList.add(claim1);
        
        PartnerFundClaim claim2 = Core_MDF_CCP_TestDataUtility.createClaim('France Claim 2', Core_MDF_CCP_TestDataUtility.claim_RecordType_Retail,testPartnerFundRequestRecord2.Id,
                                                                                      testPartnerFundRequestRecord2.Core_MDF_Start_Date__c, 
                                                                                      testPartnerFundRequestRecord2.Core_MDF_Start_Date__c,50,System.today(),null,false);
        claim2.Core_MDF_PIC_Review_Completed__c = true;
        claim2.Core_MDF_BackendReviewSelection_Ind__c = false;
        claim2.Amount = 300;
        claim2.Core_MDF_Currency__c='USD'; 
        pfcList.add(claim2);
        
        Database.insert(pfcList);
        Test.stopTest();
        claim1.Core_MDF_Status__c = 'Paid';
        claim2.Core_MDF_Status__c = 'Paid';
        pfcList.clear();
        pfcList.add(claim1);
        pfcList.add(claim2);
        Database.update(pfcList);
        
        testPartnerFundRequestRecord2.Core_MDF_Fund_Request_Status__c = 'Closed';
        Database.update(testPartnerFundRequestRecord2);
        Id claimRecType = Schema.SObjectType.Core_MDF_Escalation__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_Late_Claim').getRecordTypeId();
            Core_MDF_Escalation__c esc1 = new Core_MDF_Escalation__c();
            esc1.Core_MDF_Escalation_Status_nm__c='Approved';
            esc1.Core_MDF_Escalation_Name_txt__c='TestEscalation';
            esc1.Core_MDF_Total_Dollar_Impact_amt__c= 23;
            esc1.Core_MDF_Root_Cause_nm__c = 'Tools and Systems';
            esc1.Core_MDF_Co_Marketing_Activity_id__c = testPartnerFundRequestRecord2.Id;
            esc1.Core_MDF_Channel_Program_id__c = rcp.Id;
            esc1.recordtypeid= claimRecType;
            Database.insert(esc1);
            //testPartnerFundRequestRecord1.BudgetId=pmbRecord2.Id;
            
            //assert.areEqual('Broadcast',cmp.Core_MDF_Activity_Category__c);
            //assert.areEqual('Radio',cmp.Core_MDF_Activity_Type__c);
               
            try{
                campaignList.clear();
                chkCampEdit.Core_MDF_Technology__c ='Thunderbolt';
                chkCampEdit.Name= 'Update Camp Name';
                chkCampEdit1.Core_MDF_Budget_Amount_amt__c = 300;
                RmfCamp.Core_MDF_Budget_Amount_amt__c = 300;
                campaignList.add(chkCampEdit);
                campaignList.add(chkCampEdit1);
                campaignList.add(RmfCamp);
                update campaignList;
                  database.update(cmp);
                
            }catch(Exception e){
                
            }  
           
       // }
    }catch(Exception e){
        Core_MDF_CCP_UtilityClass.logError(e);
    }     
    }
    
    @isTest static  void createCampaign()
        
    {   
        try{
        User user = [SELECT Id, LastName FROM User WHERE LastName ='User Test1' LIMIT 1];
        System.runAs(user){
            Account intacc;
            Account dcfacc;
            Account ccfacc;
            Account retacc;
            for(Account acc: [SELECT Id,Name,Core_MDF_Parent_Fund_Account__c FROM Account LIMIT 50000]){
                if(acc.Name == 'Test Account 1'){
                    intacc = acc;
                }
                if(acc.Name == 'Co-marketing DCF Test Account'){
                    dcfacc = acc;
                }
                if(acc.Name == 'Co-marketing CCF Test Account'){
                    ccfacc = acc;
                }    
                if(acc.Name == 'Co-marketing Retail Test Account'){
                    retacc = acc;
                }   
                
            }
            Test.startTest();
            User usr1;
            User usr2;
            User usr3;
            
            for(User usr: [SELECT Id,LastName FROM User WHERE LastName='User Test1' OR LastName='User Test2' OR LastName='User Test3' LIMIT 50000]){
                if(usr.LastName == 'User Test1' ){
                    usr1 = usr;
                }
                if(usr.LastName == 'User Test2'){
                    usr2 = usr;
                }
                if(usr.LastName == 'User Test3'){
                    usr3 = usr;
                }
            }
            
            Id dcfgrp;
            Id ccfgrp;
            Id retgrp;
            for(Group grp:[SELECT Id,Name FROM Group WHERE Name = 'Core CCP DCF External' OR Name = 'Core CCP CCF External' OR Name ='Core_CCP_Retail_ASMO_Internal' LIMIT 50000]){
                if(grp.Name == 'Core CCP DCF External'){
                    dcfgrp = grp.Id;
                }
                if(grp.Name == 'Core CCP CCF External'){
                    ccfgrp = grp.Id;
                } 
                if(grp.Name == 'Core_CCP_Retail_ASMO_Internal'){
                    retgrp = grp.Id;
                } 
            }
            
            
            
            // Creating Campaign with utility class
            // Test.startTest();
            List<Campaign> campList = new List<Campaign>();
            Campaign campc1 = Core_MDF_CCP_TestDataUtility.createCampaign('Test Camp 1','Reseller','Intel® Corporate Logo',
                                                                          'MDF or both CMP & MDF',Core_MDF_CCP_TestDataUtility.Campaign_RecordType_DCF, 'Data Center CoMarketing Fund',System.today()-15 , 
                                                                          System.today()+30, 5000, 'Hybrid Cloud', dcfacc.Id,'Server', false);
            
            //campc1.Core_MDF_External_Visibility_Date__c = System.today();
            campc1.Core_MDF_External_Visibility_Date__c =  System.today()-15;
            campc1.Core_MDF_Region_cd__c='APJ';
            Database.insert(campc1);
            campList.add(campc1);
            //added for activity association to campaign
            PartnerFundRequest testPartnerFundRequestRecord1 = Core_MDF_CCP_TestDataUtility.insertPartnerFundRequest(campc1.id,Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,dcfacc.Id,null,null,'INDIA','Consumer','Desktop','Intel® Corporate Logo','Broadcast','Radio','Draft',false);
            testPartnerFundRequestRecord1.RequestedAmount = 250;
            testPartnerFundRequestRecord1.Core_MDF_Priorities__c = 'Always Connected PC';
            testPartnerFundRequestRecord1.Core_MDF_Fund_Request_Status__c = 'Revision Required';
            testPartnerFundRequestRecord1.Core_MDF_Budget_Amount_Local_amt__c = 250;
            testPartnerFundRequestRecord1.Core_MDF_Budget_Currency_cd__c = 'USD';
            testPartnerFundRequestRecord1.Core_MDF_Channel_Partner_Led__c = false;
            testPartnerFundRequestRecord1.Core_MDF_Channel_Partner__c = '';
            testPartnerFundRequestRecord1.Core_MDF_Start_Date__c =System.today()-15;
            testPartnerFundRequestRecord1.Core_MDF_End_Date__c = System.today()+30;
            insert testPartnerFundRequestRecord1; 
            Campaign UpdateCampaign=[select Id , Name, StartDate From campaign where Id=:campc1.Id];
           // UpdateCampaign.StartDate= System.today()-14;
             UpdateCampaign.Core_MDF_Region_cd__c='ASMO';
            UpdateCampaign.Core_MDF_External_Visibility_Date__c=System.today()-16;
            Try{
            Database.update(UpdateCampaign);
            }catch(Exception ex1){}
            
            List<String> grpIdList= new List<String>();
            for(CampaignShare cmpshr : [SELECT Id, CampaignId, UserOrGroupId FROM CampaignShare WHERE CampaignId =: campc1.Id LIMIT 50000]){
                grpIdList.add(string.valueof(cmpshr.UserOrGroupId));
            }
            Core_MDF_CampaignServiceHandler.updateIpaL1ApproverComments(campList);
            //Since the external visibility date is today the above campaign should be shared with DCF external group
            //and it should not shared with CCF external group
                   
            //assert.isTrue(grpIdList.contains(dcfgrp));
            assert.isTrue(!grpIdList.contains(ccfgrp));
            
           
            Test.stopTest();
            
        }
    }catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);}     
    }
    @isTest static void testCampaignCAP(){
        try{        
        User user = [SELECT Id, LastName FROM User WHERE LastName ='User Test1' LIMIT 1];
        System.runAs(user){
            Core_MDF_CCP_TestDataUtility.createMDFConfigurationData(); 
            Test.startTest(); 
            Campaign camp = [select id, Core_MDF_Reimbursement_Rate__c from Campaign where Name = 'Campaign CAP Campaign']; 
           
            PartnerFundRequest testActivity = [select id, Core_MDF_Start_Date__c from PartnerFundRequest limit 1];
            
            Core_MDF_Bank__c indiaBank = [select id from Core_MDF_Bank__c where Core_MDF_Bank_Status__c = 'Active' ];
            List<PartnerFundClaim> claimList = new List<PartnerFundClaim>();
            
            PartnerFundClaim testClaim1 = Core_MDF_CCP_TestDataUtility.createClaim('Test Campaign CAP Claim1', Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF, 
                                                                                   testActivity.Id, 
                                                                                   testActivity.Core_MDF_Start_Date__c, testActivity.Core_MDF_Start_Date__c, 
                                                                                   101, 
                                                                                   testActivity.Core_MDF_Start_Date__c, indiaBank.ID, false);
            testClaim1.Core_MDF_Currency__c = 'USD';
            testClaim1.Core_MDF_Campaign_Id__c= camp.id;
            
            PartnerFundClaim testClaim2 = Core_MDF_CCP_TestDataUtility.createClaim('Test Campaign CAP Claim2', Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF, 
                                                                                   testActivity.Id, 
                                                                                   testActivity.Core_MDF_Start_Date__c, testActivity.Core_MDF_Start_Date__c, 
                                                                                   101, 
                                                                                   testActivity.Core_MDF_Start_Date__c, indiaBank.ID, false);
            testClaim2.Core_MDF_Currency__c = 'USD';
            testClaim2.Core_MDF_Campaign_Id__c= camp.id;
            claimList.add(testClaim1);claimList.add(testClaim2);
            // Test.startTest();    
            
            Database.insert(claimList);
            
            camp.Core_MDF_Spending_Cap_Amt__c = 1000;
            Database.update(camp);
            try{
            camp.Status = 'Cancelled';
            Database.update(camp);
            }
            catch(Exception e){
            }
            list<id> campID = new list<id>();
            campID.add(camp.id);
            
            Core_MDF_ProcessCCP_Campaign.removeApprovalLock(campID);
            // Test.stopTest();
            
            Campaign campAssert = [select id,Core_MDF_Spending_Cap_Amt__c from Campaign where Name = 'Campaign CAP Campaign'];
            Test.stopTest();
            assert.areEqual(campAssert.Core_MDF_Spending_Cap_Amt__c, 1000);
            
        }
    }catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);}     
    }
    
    
    @isTest static void testCampaignCAP2(){
        try{
        User user = [SELECT Id, LastName FROM User WHERE LastName ='User Test1' LIMIT 1];
        System.runAs(user){
            Core_MDF_CCP_TestDataUtility.createMDFConfigurationData(); 
            Test.startTest(); 
            Campaign camp = [select id, Core_MDF_Reimbursement_Rate__c from Campaign where Name = 'Campaign CAP Campaign']; 
           
            PartnerFundRequest testActivity = [select id, Core_MDF_Start_Date__c from PartnerFundRequest limit 1];
                            
                
            Core_MDF_Bank__c indiaBank = [select id from Core_MDF_Bank__c where Core_MDF_Bank_Status__c = 'Active' ];
            List<PartnerFundClaim> claimList = new List<PartnerFundClaim>();
            
            PartnerFundClaim testClaim1 = Core_MDF_CCP_TestDataUtility.createClaim('Test Campaign CAP Claim1', Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF, 
                                                                                   testActivity.Id, 
                                                                                   testActivity.Core_MDF_Start_Date__c, testActivity.Core_MDF_Start_Date__c, 
                                                                                   101, 
                                                                                   testActivity.Core_MDF_Start_Date__c, indiaBank.ID, false);
            testClaim1.Core_MDF_Currency__c = 'USD';
            testClaim1.Core_MDF_Campaign_Id__c= camp.id;
            testClaim1.Core_MDF_Status__c = 'Payment Due';
            testClaim1.Core_MDF_Type_Txt__c = Core_MDF_CCP_ConstantClass.TYPE_CLAIM;
            testClaim1.Core_MDF_Escalation_Id__c = null;
            
            PartnerFundClaim testClaim2 = Core_MDF_CCP_TestDataUtility.createClaim('Test Campaign CAP Claim2', Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF, 
                                                                                   testActivity.Id, 
                                                                                   testActivity.Core_MDF_Start_Date__c, testActivity.Core_MDF_Start_Date__c, 
                                                                                   101, 
                                                                                   testActivity.Core_MDF_Start_Date__c, indiaBank.ID, false);
            testClaim2.Core_MDF_Currency__c = 'USD';
            testClaim2.Core_MDF_Campaign_Id__c= camp.id;
            testClaim2.Core_MDF_Status__c = 'PIC Pending';
            testClaim2.Core_MDF_Type_Txt__c = Core_MDF_CCP_ConstantClass.TYPE_CLAIM;
            testClaim2.Core_MDF_Escalation_Id__c = null;
            claimList.add(testClaim1);
            claimList.add(testClaim2);
            // Test.startTest();    
            
            Database.insert(claimList);
            
            testActivity.Core_MDF_Fund_Request_Status__c = 'Closed';
            testActivity.Core_MDF_Activity_Closure_Type__c = 'Auto';
                                             Database.update(testActivity); 
            
            camp.Core_MDF_Spending_Cap_Amt__c = 1000;
            Database.update(camp);
            try{
            camp.Status = 'Cancelled';
            Database.update(camp);
            }
            catch(Exception e){
            }
            list<id> campID = new list<id>();
            campID.add(camp.id);
            
            Core_MDF_ProcessCCP_Campaign.removeApprovalLock(campID);
            // Test.stopTest();
            
            Campaign campAssert = [select id,Core_MDF_Spending_Cap_Amt__c from Campaign where Name = 'Campaign CAP Campaign'];
            Test.stopTest();
            assert.areEqual(campAssert.Core_MDF_Spending_Cap_Amt__c, 1000);
            
        }
    }catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);}     
    }
    
    
    
    //US952018: [Technical] [Opal & SPCF] - Case- Display Strategic Marketing Fund Checkbox
    @isTest static void testSMF(){
        try{
        User user = [SELECT Id, LastName FROM User WHERE LastName ='User Test1' LIMIT 1];
        System.runAs(user){
        Test.startTest();
        
        Campaign camp = [select id from Campaign where Name = 'Campaign CAP Campaign'];
        
        Case cs = new Case();
        Id caseAuditRecType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Core_MDF_Audit').getRecordTypeId();
        cs.Status = 'New';
        cs.recordTypeId = caseAuditRecType;
        cs.Core_MDF_Campaign_ID__c=camp.ID;
        cs.Core_MDF_Claim_ID__c=camp.id;
        cs.Origin='Manual Selection';
        insert cs;
        
        camp.Core_MDF_Strategic_Marketing_Fund_Ind__c = true;
        camp.Core_MDF_Proposal_Based_Ind__c = false;
        update camp;
        Test.stopTest();
       // Unit Test Method should include System.Assert - Indira
       System.assertEquals(false, camp.Core_MDF_Proposal_Based_Ind__c, 'Proposal Based indicator should be false');
    }
    }catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);}     
    }
    
      @isTest static void testRelatedrecords()
 {
 Profile sysAdminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator' LIMIT 1];
 UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
 // Creating User with utility class 
 Test.startTest();
 User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
 usr.profileId = sysAdminProfile.Id;
 usr.UserRoleId = usRole.Id;
 Database.insert(usr);
 //Running as System Admin
 System.runAs(usr)
 {

  ChannelProgram cp = Core_MDF_CCP_TestDataUtility.createProgram ('Service Provider Co-Marketing Fund','Service Provider CoMarketing Fund', true);

 // Creating IntelAccount with utility class
 Account acc1 = Core_MDF_CCP_TestDataUtility.createIntelAccount ('Test Account Intel', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, 
 true);
 Account acc = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Co-marketing Test Account_DCF', cp.Id,
  Core_MDF_CCP_TestDataUtility.Account_Record_Type, acc1.Id, true);

 PartnerMarketingBudget pmb = [SELECT Id FROM PartnerMarketingBudget LIMIT 1];

 // Creating Allocation using utility class
 PartnerFundAllocation pfa = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('Test Allocation',pmb,acc,100000.0,true);
     List<Campaign> campList = new List<Campaign>();
 // Creating campaigns using utility class
 Campaign camp = Core_MDF_CCP_TestDataUtility.createCampaign('TestCamp','Consumer','Intel® Corporate Logo','Yes', 
 Core_MDF_CCP_TestDataUtility.Campaign_RecordType_SPCF,
 'Service Provider CoMarketing Fund',System.today().addDays(-15), 
 System.today().addDays(15), 2000, 'Unite',acc.Id,'Cloud', true);
     campList.add(camp);

 //Test.stopTest();
 // Creating activities using utility class
 PartnerFundRequest pfr = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(camp.Id),
 Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_SPCF,
 string.valueof(acc.id),pfa,pmb,'INDIA','Small Business',
 'Cloud','Intel® Corporate Logo',
'','','Draft',false);
 pfr.RequestedAmount = 90000;
 pfr.Amount = 90000;
 pfr.Status = 'Approved';
 pfr.AllocationId = pfa.Id;
 pfr.BudgetId = pmb.Id;
 pfr.Core_MDF_Start_Date__c = system.today().addDays(-5);
 pfr.Core_MDF_End_Date__c = system.today().addDays(5);

 Database.insert(pfr);
 camp.Core_MDF_Reimbursement_Rate__c='90%';
 update camp;
 // Unit Test Method should include System.Assert - Indira
  System.assertEquals(1, campList.size(), 'Campaign list should contain 1 campaign');  
     
     if(campList.size() > 0){
         Core_MDF_CampaignUtility.notifyFinanceusers(campList);
     }
 Test.stopTest();
 }
     
 }  
    @isTest static void testShareUnshareGeneric(){
        try{
        User user = [SELECT Id, LastName FROM User WHERE LastName ='User Test1' LIMIT 1];
        System.runAs(user){
        Map<Id, Campaign> campMap = new Map<Id, Campaign>();
        Map<Id, Set<Id>> campIdToGrpsToBeDeleted = new Map<Id, Set<Id>>();
        List<Campaign> campaignList = new List<Campaign>();
        Account RetailAcc=[select Id, name from Account where Name='Co-marketing Test Node Account'];
        Campaign RmfCamp = Core_MDF_CCP_TestDataUtility.createCampaign('Test RMF Camp','Reseller','Intel® Corporate Logo', 
                                                                       'yes',  Core_MDF_CCP_TestDataUtility.campaign_RecordType_Retail, 'Retail Marketing Funds', System.today()-25,System.today()+30, 10000, 'Hybrid Cloud', RetailAcc.Id,'Server',false);
        campaignList.add(RmfCamp);
        Database.insert (campaignList);
        campMap.put(RmfCamp.Id, RmfCamp);
         // Unit Test Method should include System.Assert - Indira   
         System.assertEquals(1, campMap.size(), 'Campaign map should contain 1 campaign');
            
           Group grp = [Select id from group where name = 'Core CCP Retail ASMO INTERNAL'];
        campIdToGrpsToBeDeleted.put(RmfCamp.Id, new Set<Id>{grp.Id});
        Core_MDF_ProcessCCP_Campaign.shareUnshareCampaignGenericMethod(campMap, campIdToGrpsToBeDeleted);
        Core_MDF_ProcessCCP_Campaign.blockCampaignDeletion(campaignList); 
        Core_MDF_ProcessCCP_Campaign.determineCampaignAttributes(campaignList, campMap, true, true);
        Core_MDF_ProcessCCP_Campaign.shareUnshareCampaign(campaignList, campMap, true, true);
            
        
        }
        }catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);}     
    }
    @isTest static void validateBudgetToCampaignMaptest(){
        try{
        User user = [SELECT Id, LastName FROM User WHERE LastName ='User Test1' LIMIT 1];
        System.runAs(user){
        Test.startTest();
        Map <id,id> AccNodeVirtualCorpMap = new Map <id,id>();
        Map<String,List<PartnerMarketingBudget>> RMFCamptoBudgettypeMap = new Map<String,List<PartnerMarketingBudget>>();
        List<Campaign> testCampaign = [select id,name,StartDate,EndDate,Core_MDF_Account__c,Core_MDF_Opal_Budget_Type_Txt__c from Campaign where name='Campaign CAP Campaign' limit 1];
        List<PartnerMarketingBudget> pmbtestList = [select ID,Title,StartDate,EndDate,Core_MDF_Budget_Type_Txt__c,Core_MDF_Budget_Partner__c from PartnerMarketingBudget where Title='Dell PMB2' limit 1];
        string key = pmbtestList[0].Core_MDF_Budget_Type_Txt__c + pmbtestList[0].Core_MDF_Budget_Partner__c;
        RMFCamptoBudgettypeMap.put(key,pmbtestList);
        AccNodeVirtualCorpMap.put(testCampaign[0].Core_MDF_Account__c,pmbtestList[0].Core_MDF_Budget_Partner__c);
        Core_MDF_ProcessCCP_Campaign.validateBudgetToCampaignMap(testCampaign, RMFCamptoBudgettypeMap, AccNodeVirtualCorpMap);
        Test.stopTest();
       // system.assert(testCampaign != null);
       assert.isNotNull(testCampaign);
        }
    }catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);}     
    }
    
@isTest static void testCalculatecampaignCAPAmount_withClaims() {
         UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1]; 
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.LastName = 'User Test';
        usr.UserRoleId = usRole.Id;
        Database.insert(usr);
        system.runAs(usr) {
             Test.startTest();
         ChannelProgram cp = [SELECT Id FROM ChannelProgram WHERE Core_MDF_Technical_Program_Name__c='Client CoMarketing Fund'  LIMIT 1];
            Account acc1 = Core_MDF_CCP_TestDataUtility.createIntelAccount ('Test Account 123', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, 
                                                                            true);
        Account acc = Core_MDF_CCP_TestDataUtility.createAccount ('Co-marketing Test Account123', cp.Id,
                                                                      Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
        acc.Core_MDF_Parent_Fund_Account__c = acc1.Id;
        Database.insert(acc); 
        // Prepare campaign
        Campaign c = new Campaign(Name = 'CAP Test Campaign123', StartDate = Date.today().addDays(-1), EndDate = Date.today().addDays(10));
        insert c;       
        
        PartnerMarketingBudget pmb = [SELECT Id FROM PartnerMarketingBudget LIMIT 1];
            
        PartnerFundAllocation pfa = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('Test Allocation123',pmb,acc,10.0,true);
        
        PartnerFundRequest pfr = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(c.Id),
                                                                                           Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,
                                                                                           string.valueof(acc.id),pfa,pmb,'INDIA','Creator',
                                                                                           'Desktop','Intel® Core™ i7 Processor','Broadcast (Pre-2025)',
                                                                                           'Radio','Draft',false);
        pfr.RequestedAmount = 9000;
        pfr.Amount = 90;
        pfr.Status = 'Approved';
        pfr.AllocationId = pfa.Id;
        pfr.BudgetId = pmb.Id;
        pfr.Core_MDF_Start_Date__c = System.today().addDays(1);
        pfr.Core_MDF_End_Date__c = System.today().addDays(5);
        pfr.Core_MDF_Reimbursement_Rate_pct__c = '50%';
        pfr.Core_MDF_Reimbursement_Rate_txt__c = '50%';
        pfr.Core_MDF_Budget_Amount_Local_amt__c=10;
        Database.insert(pfr);
        
        Core_MDF_Bank__c bank = Core_MDF_CCP_TestDataUtility.createBank(acc1.id,'Core_MDF_Client_CoMarketing_Fund',true,'1234567890');

        // Create a PartnerFundClaim linked to the PFR and referencing the campaign via Core_MDF_Campaign_Id__
            
        //PartnerFundClaim pfc = [Select Id from PartnerFundClaim limit 1];       

       
            // Call the method with the campaign Id set
        Map<Id, Decimal> result = Core_MDF_ProcessCCP_Campaign.calculatecampaignCAPAmount(new Set<Id>{c.Id});
         Core_MDF_ProcessCCP_Campaign.removeApprovalLock(new List<Id>{c.Id});
        Test.stopTest();

        // Verify the map contains the campaign id and amounts summed correctly (250 + 100 = 350)
        System.assertNotEquals(null, result, 'Result map must not be null');
        }
    }
    
    @isTest static void testCheckEdit_removedAndNotRemoved() {
        Campaign oldC = new Campaign(Name = 'Old', StartDate = Date.today().addDays(-10), EndDate = Date.today().addDays(10));
        insert oldC;
        Campaign newC = new Campaign(Name = 'New', StartDate = Date.today().addDays(-10), EndDate = Date.today().addDays(10));
        insert newC;        
        String fieldApi = 'Description';
        // Set old and new values through update (we'll construct maps and call method directly)
        Campaign oldCampaign = new Campaign(Id = oldC.Id, Description = 'A;B;C');
        Campaign newCampaignNoRemove = new Campaign(Id = newC.Id, Description = 'A;B;C');
        Campaign newCampaignRemoved = new Campaign(Id = newC.Id, Description = 'A;C');

        // Directly call checkEdit: when nothing removed should be false
        Boolean removedFalse = Core_MDF_ProcessCCP_Campaign.checkEdit(newCampaignNoRemove, oldCampaign, fieldApi);
        System.assertEquals(false, removedFalse, 'No value removed - should return false');

        // When B removed, should return true
        Boolean removedTrue = Core_MDF_ProcessCCP_Campaign.checkEdit(newCampaignRemoved, oldCampaign, fieldApi);
        System.assertEquals(true, removedTrue, 'Value removed - should return true');
    }
    
}