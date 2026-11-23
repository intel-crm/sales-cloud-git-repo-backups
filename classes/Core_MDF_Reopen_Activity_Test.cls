@isTest
public class Core_MDF_Reopen_Activity_Test {
    public static Id claimRecType = Schema.SObjectType.Core_MDF_Escalation__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_Late_Claim').getRecordTypeId();
    @TestSetup 
    static void createTestData(){
        
        List<String> bypassFunctionKeys = new List<String>();
        bypassFunctionKeys.add('Bypass_Duplicate_Budget_Check');
        bypassFunctionKeys.add('Bypass_MDF_Budget_Access_Validation');
        bypassFunctionKeys.add('Bypass_MDF_Budget_Status_Validation');
        bypassFunctionKeys.add('Bypass_GeoBased_Budget_Sharing');
        bypassFunctionKeys.add('Bypass_Allocation_Reservation');
        bypassFunctionKeys.add('Bypass_GeoBased_Allocation_Sharing');
        bypassFunctionKeys.add('byPassShareUnshareCampaignRecord');
        bypassFunctionKeys.add('byPassCampaignAndRelatedRecords');
        bypassFunctionKeys.add('Bypass_ValidateActivityWithCampaign');
        bypassFunctionKeys.add('byPass_Cancel_Activity');
        bypassFunctionKeys.add('Core_MDF_Bypass_ATFBatchUpdate');
        bypassFunctionKeys.add('Bypass_Claims_Duplicate_Check');
        bypassFunctionKeys.add('Bypass_Claims_Sharing_Internal_Users');
        bypassFunctionKeys.add('Bypass_ClaimAdjReq_Share_On_Owner_Chng');
        bypassFunctionKeys.add('Bypass_ClaimAdjReq_Share_Internal_Usrs');
        bypassFunctionKeys.add('Bypass_ClaimAdjReq_Share_External_Usrs');
        bypassFunctionKeys.add('Bypass_Claim_AdjReq_Amount_Validation');
        bypassFunctionKeys.add('Bypass_Claims_Amt_vs_Budget_Amt_Check');        
        bypassFunctionKeys.add('Bypass_Claims_ABM_Validation');
        bypassFunctionKeys.add('Bypass_Claims_Sharing_Partner_Users');
        bypassFunctionKeys.add('Bypass_Claims_Amt_vs_Camp_Amt_Check');
        bypassFunctionKeys.add('Bypass_Claim_OwnerLang_EmailTemp');
        bypassFunctionKeys.add('Bypass_StampingOfActySubType_Check');
        bypassFunctionKeys.add('Bypass_Claims_Sharing_On_Owner_Change');
        bypassFunctionKeys.add('Core_MDF_BypassATFFlagUpdate');
        bypassFunctionKeys.add('Core_MDF_BypassATFFlagUpdateBatch');
        bypassFunctionKeys.add('Core_MDF_Bypass_CloseDateExtend_ATF');
        bypassFunctionKeys.add('Bypass_MDF_Budget_Update_Validation');
        bypassFunctionKeys.add('Bypass_MDF_Budget_Access');
        bypassFunctionKeys.add('ShareActivityWithInternalUsers_Bypass');
        Set<String> myset1 = new Set<String>();
        List<String> result1 = new List<String>();
        myset1.addAll(bypassFunctionKeys);
        result1.addAll(myset1);
        List<Core_Trigger_Executions__c> bypassfunctinalitylist1 = Core_MDF_CCP_TestDataUtility.byPassFeature(result1,true,true);
        
        profile systemAdminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator' limit 1];
        Profile ccpCoreProfile = [SELECT Id FROM Profile WHERE Name='CCP - Core Access' LIMIT 1];
        UserRole usRole1 = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        
        List<User> usrList=new List<User>();
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.profileId = ccpCoreProfile.Id;
        usr.LastName = 'Budget Loader CCPTest';
        usrList.add(usr);
        
        User usr1 = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr1.profileId = systemAdminProfile.Id;
        usrList.add(usr1);
        
        
        User usrtest = Core_MDF_CCP_TestDataUtility.createUser(false);
        usrtest.LastName = 'User Test';
        usrtest.profileId = ccpCoreProfile.Id;
        //usrtest.UserRoleId = usRole1.Id;
        usrList.add(usrtest);

        //EEF User
        User usr8 = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr8.lastname = 'Test EEF User8';
        usrList.add(usr8);
        User usr9 = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr9.lastname = 'Test EEF User9';
        usrList.add(usr9);
        database.insert(usrList);
        
        
        List<ChannelProgram> cpList = new List<ChannelProgram>();
        ChannelProgram cp = Core_MDF_CCP_TestDataUtility.createProgram (Core_MDF_CCP_ConstantClass.CCF_PROGRAM,'Client CoMarketing Fund', true);
        ChannelProgram cpRetail = Core_MDF_CCP_TestDataUtility.createProgram (Core_MDF_CCP_ConstantClass.RMF_PROGRAM,'Retail Marketing Funds', true);
        ChannelProgram ipaCP = Core_MDF_CCP_TestDataUtility.createProgram (Core_MDF_CCP_ConstantClass.IPA_PROGRAM,'Intel Partner Alliance', true);
        ChannelProgram eefCp = Core_MDF_CCP_TestDataUtility.createProgram(Core_MDF_CCP_ConstantClass.EEF_PROGRAM,'Ecosystem Extension Fund', true);
        List<Account> accList = new List<Account>();
        Account accIntel = Core_MDF_CCP_TestDataUtility.createIntelAccount('Test Acc New 1', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, true);
        Account acc1 = Core_MDF_CCP_TestDataUtility.createIntelAccount ('Test Account 1', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, 
                                                                        false);
        acc1.Core_Account_Type__c = 'Reseller';            
        acc1.Industry = 'Food & Beverage';
        acc1.Core_MDF_Channel_Program__c = cp.Id;
        accList.add(acc1);
        Account acc1Retail = Core_MDF_CCP_TestDataUtility.createIntelAccount ('Test Account Retail', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, 
                                                                              false);
        acc1Retail.Core_Account_Type__c = 'Reseller';
        acc1Retail.Industry = 'Food & Beverage';
        acc1Retail.Core_MDF_Channel_Program__c = cpRetail.Id;
        acc1Retail.Core_Geo__c = 'APJ';            
        acc1Retail.Core_Sub_Geo__c = 'IJKK';
        accList.add(acc1Retail);

        //EEF Account
        Account intelPrimAcc = Core_MDF_CCP_TestDataUtility.createIntelAccount('Test Primary Intel Account', 
                                Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
        accList.add(intelPrimAcc);
        Account intelActAcc = Core_MDF_CCP_TestDataUtility.createIntelAccount('Test Activating Intel Account', 
                                Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
        accList.add(intelActAcc);

        Account ipaAcc = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test Account 3', ipaCP.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, accIntel.Id, false);
        accList.add(ipaAcc);
        
        System.runAs(usr1){
            database.insert(accList);
        }
        List<Account> accCoMarketingList = new List<Account>();
        
        Account acc = Core_MDF_CCP_TestDataUtility.createAccount ('Co-marketing Test Account', cp.Id,
                                                                  Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
        acc.Core_MDF_Parent_Fund_Account__c = acc1.Id;
        accCoMarketingList.add(acc);
        Account accRetail = Core_MDF_CCP_TestDataUtility.createAccount ('Co-marketing Test Account Retail', cpRetail.Id,
                                                                        Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
        accRetail.Core_MDF_Parent_Fund_Account__c = acc1Retail.Id;
        accRetail.Core_Geo__c = 'APJ';
        accRetail.Core_Sub_Geo__c = 'IJKK';
        accCoMarketingList.add(accRetail);

        Account PrimaryVC = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Primary VC Account',
                                                                             eefCp.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, 
                                                                             intelPrimAcc.Id, false);
            PrimaryVC.Core_MDF_Partner_Type_nm__c = 'Primary Partner';
            PrimaryVC.Core_MDF_Active_Ind__c = true;
        accCoMarketingList.add(PrimaryVC);

        Account activatingVC = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Acticating VC Account',
                                                                             eefCp.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, 
                                                                             intelActAcc.Id, false);
            activatingVC.Core_MDF_Partner_Type_nm__c = 'Activating Partner';
            activatingVC.Core_MDF_Active_Ind__c = true;
        accCoMarketingList.add(activatingVC);
        System.runAs(usr1){
            database.insert(accCoMarketingList);
        }
        
        test.starttest();
        list<PermissionSetAssignment> permList = new list<PermissionSetAssignment>();
        system.runAs(usr1){
            PermissionSet psFinance = [SELECT Id FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_Finance_Usr' LIMIT 1];
            PermissionSetAssignment perm1 = new PermissionSetAssignment(AssigneeId = usr1.id, PermissionSetId = psFinance.Id);
            permList.add(perm1);
            PermissionSet psFinance1 = [SELECT Id FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_CCF_User' LIMIT 1];
            PermissionSetAssignment perm2 = new PermissionSetAssignment(AssigneeId = usr1.id, PermissionSetId = psFinance1.Id);
            permList.add(perm2);
            PermissionSet psbudLoader = [SELECT Id FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_CCF_MDF_Budget_Loader' LIMIT 1];
            PermissionSetAssignment perm3 = new PermissionSetAssignment(AssigneeId = usr1.id, PermissionSetId = psbudLoader.Id);
            permList.add(perm3);
            permissionSet eefBudgetLoaderPs= [SELECT Id FROM PermissionSet WHERE Name = 'Core_MDF_Internal_EEF_Budget_Loader' LIMIT 1];
            PermissionSetAssignment perm4 = new PermissionSetAssignment(AssigneeId = usr8.id, PermissionSetId = eefBudgetLoaderPs.Id);
            permList.add(perm4);
            permissionSet primaryAccManPs= [SELECT Id FROM PermissionSet WHERE Name = 'Core_MDF_Internal_EEF_Primary_Partner_Acct_Mgr' LIMIT 1];
            PermissionSetAssignment perm5 = new PermissionSetAssignment(AssigneeId = usr9.id, PermissionSetId = primaryAccManPs.Id);
            permList.add(perm5);

            insert permList;
        }

        Id camp_Recordtype_EEF = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Core_MDF_Ecosystem_Extension_Fund').getRecordTypeId();
        Id pfr_Recordtype_EEF = Schema.SObjectType.PartnerFundRequest.getRecordTypeInfosByDeveloperName().get('Core_MDF_Ecosystem_Extension_Fund').getRecordTypeId();
        
        Core_MDF_Partner_Mapping__c primToActPartnerMapping = new Core_MDF_Partner_Mapping__c();
        primToActPartnerMapping.Core_MDF_Primary_Partner_Account_id__c = PrimaryVC.id;
        primToActPartnerMapping.Core_MDF_Activating_Partner_Account_id__c = activatingVC.id;
        primToActPartnerMapping.Core_MDF_Effective_Start_Date__c = system.today()-90;
        primToActPartnerMapping.Core_MDF_Effective_End_Date__c = system.today () +100;
        primToActPartnerMapping.Core_MDF_Channel_Program__c = eefCp.Id;
        insert primToActPartnerMapping;
        
        Id recordTypeIdPMB = Schema.SObjectType.PartnerMarketingBudget.getRecordTypeInfosByName().get('CoMarketing').getRecordTypeId();
        PartnerMarketingBudget  pmbRecord = Core_MDF_CCP_TestDataUtility.createBudget('TestPMB',RecordTypeIdPMB,acc.Id,cp.Id,12345678,System.today()-1,System.today()-1,false);
        pmbRecord.Core_MDF_Budget_Type__c='CCF 1.0';
        pmbRecord.Core_MDF_Budget_Type_Txt__c='CCF 1.0';
        PartnerFundAllocation pfaRecord = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('TestPFA',pmbRecord, acc, 99999,false);
        Id budget_EEFRecord_Type = Schema.SObjectType.PartnerMarketingBudget.getRecordTypeInfosByDeveloperName().get('Core_MDF_Ecosystem_Extension_Fund').getRecordTypeId();
        PartnerMarketingBudget testBudgetCloud = Core_MDF_CCP_TestDataUtility.createBudget('TestBudgetCloud',budget_EEFRecord_Type,
                                                                                         PrimaryVC.id, eefCp.Id , 300 ,  System.today().addDays(-30) ,System.today().addDays(30),
                                                                                         false);
        
        testBudgetCloud.IsIgnoreValidation = true;
        testBudgetCloud.Core_MDF_Budget_Type_Txt__c = 'Cloud';
        testBudgetCloud.Core_MDF_Budget_Type__c='Cloud';
        System.runAs(usr8){
            insert testBudgetCloud;
        }
        List<PartnerFundAllocation> pfaList = new List<PartnerFundAllocation>();
        PartnerFundAllocation eefAllocation = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('Test Allocation EEF',
                                              testBudgetCloud,PrimaryVC,200.0,false);
        PartnerFundAllocation eefActAllocation = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('Test Allocation activating EEF',
                                              testBudgetCloud,activatingVC,100.0,false);
        pfaList.add(eefAllocation);
        pfaList.add(eefActAllocation);

        System.runAs(usr1){
            database.insert(pfaList);
        }

        List<Campaign> campList = new List<Campaign>();
        Campaign camp = Core_MDF_CCP_TestDataUtility.createCampaign('TestCamp','Consumer','Intel® Corporate Logo', 'Yes',
                                                                    Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 'Client CoMarketing Fund',System.today()-60 , 
                                                                    System.today()+200, 2000, 'Unite', acc.Id,'2-in-1', false);
        //camp.Core_MDF_Opal_Budget_Type_Txt__c = 'CCF 1.0'; 
        campList.add(camp);
        Campaign MDFcamp = Core_MDF_CCP_TestDataUtility.createCampaign('TestCampOpal','Consumer','Intel® Corporate Logo', 'MDF or both CMP & MDF',
                                                                       Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 'Client CoMarketing Fund',System.today()-250 , 
                                                                       System.today()+90, 2000, 'Unite', acc.Id,'2-in-1', false);
        MDFcamp.Core_MDF_Opal_Budget_Type_Txt__c = 'MDF;OEM CMP'; 
        campList.add(MDFcamp);
        Campaign oemCamp = Core_MDF_CCP_TestDataUtility.createCampaign('TestCamp','Gaming','Athena', 'MDF or both CMP & MDF',
                                                                       Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF,
                                                                       'Client CoMarketing Fund',System.today().addDays(-5) ,
                                                                       System.today().addDays(200), 2000, 'Test',acc.Id,'2-in-1', false);
        oemCamp.Core_MDF_Market__c = 'AFGHANISTAN';
        campList.add(oemCamp);
        Campaign camp1 = Core_MDF_CCP_TestDataUtility.createCampaign('TestRetailCamp','Gaming','Athena', 'RSA MD',
                                                                     Core_MDF_CCP_TestDataUtility.campaign_RecordType_Retail, 'Retail Marketing Funds',System.today().addDays(-180), 
                                                                     System.today().addYears(1), 200000, 'Instore innovation', accRetail.Id,'2-in-1', false);
        
        //camp1.Core_MDF_Campaign_Amount__c=1000;
        camp1.Core_MDF_Budget_Type_txt__c = 'RSA MD';
        campList.add(camp1);
        
        Campaign camp2 = Core_MDF_CCP_TestDataUtility.createCampaign('TestRetailCamp123','Gaming','Athena', 'Retail MDF',
                                                                     Core_MDF_CCP_TestDataUtility.campaign_RecordType_Retail, 'Retail Marketing Funds',System.today().addDays(-180), 
                                                                     System.today().addYears(1), 200000, 'Instore innovation', accRetail.Id,'2-in-1', false);
        
        //camp1.Core_MDF_Campaign_Amount__c=1000;
        camp2.Core_MDF_Budget_Type_txt__c = 'Retail MDF';
        campList.add(camp2);
        
        Campaign eefCampaign  = Core_MDF_CCP_TestDataUtility.createCampaign('Test EEF Camp','Gaming','Athena', 'MDF or both CMP & MDF',
                                                                         camp_Recordtype_EEF, 
                                                                         'Ecosystem Extension Fund', system.today() - 30, //System.today().addDays(-300), 
                                                                         System.today() + 30, 100000, 'Advanced Analystics', 
                                                                         PrimaryVC.Id,'Cloud Instance Consumption', false);
        eefCampaign.Core_MDF_Partner_Mapping_Txt__c = activatingVC.id;
        eefCampaign.Core_MDF_Reimbursement_Rate__c = '100%';
        campList.add(eefCampaign);
        System.runAs(usr1){
            database.insert(campList);
        }
        List<PartnerFundRequest> pfrList = new List<PartnerFundRequest>();
        PartnerFundRequest pfr2 = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(camp.Id),
                                                                                        Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,string.valueof(acc.id),pfaRecord,pmbRecord,'INDIA','Small Business','Desktop',
                                                                                        'Intel® Core™ i9 Processor','Broadcast','Radio','Draft',false);
        pfr2.Title = 'Test Activity2';
        pfr2.Core_MDF_Activity_Description__c = 'Test Activity2';
        pfr2.Core_MDF_Start_Date__c = system.today()-30;
        pfr2.Core_MDF_End_Date__c = system.today()-30;
        pfr2.RequestedAmount = 16000;
        pfr2.Core_MDF_Channel_Partner_Led__c = True;
        pfr2.Core_MDF_Fund_Request_Status__c = 'Pending Review';
        //pfr2.Core_MDF_Budget_Type_nm__c='CCF 1.0';
        pfr2.Core_MDF_Activity_Closure_Type__c='Manual';
        //pfr2.Core_MDF_ATF_Flag_nm__c=System.Label.Core_MDF_ATF_Closed_Status;
        pfr2.Core_MDF_ToBeClosedDate__c=system.today()-5;
        pfrList.add(pfr2);

        PartnerFundRequest eefPfr = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(eefCampaign.Id),
                                                                                        pfr_Recordtype_EEF,string.valueof(activatingVC.id),eefAllocation,testBudgetCloud,'INDIA','Technical Influencer','Cloud Instance Consumption',
                                                                                        'Intel® SGX','Broadcast','Radio','Draft',false);
            eefPfr.Core_MDF_Budget_Type_nm__c = 'Cloud'; 
            eefPfr.Title ='Test EEF Activity';
            eefPfr.RequestedAmount =200;
            eefPfr.Core_MDF_Reimbursement_Rate_txt__c = '100%';
            eefPfr.Core_MDF_Approval_Step_Completed__c=1;
            eefPfr.Core_MDF_Fund_Request_Status__c = 'Pending Review';
        pfrlist.add(eefPfr);
        
        
        PartnerMarketingBudget opalbudget = Core_MDF_CCP_TestDataUtility.createBudget('TestOpalPMB',recordTypeIdPMB,acc.Id,cp.Id,12345678,System.today().addDays(-90),System.today().addDays(+90),false);
        opalbudget.Core_MDF_Budget_Type__c='MDF';
        opalbudget.Core_MDF_Budget_Type_Txt__c='MDF';
        
        PartnerMarketingBudget cmpbudget = Core_MDF_CCP_TestDataUtility.createBudget('TestOEMCMP',recordTypeIdPMB,acc.Id,cp.Id,12345678,System.today().addDays(-90),System.today().addDays(+90),false);
        cmpbudget.IsIgnoreValidation = true;
        cmpbudget.Core_MDF_Budget_Type__c='OEM CMP';
        cmpbudget.Core_MDF_Budget_Type_Txt__c='OEM CMP';
        
        system.runAs(usr1){
            insert opalbudget;
            insert cmpbudget;
        }
        
        test.stopTest();
        PartnerFundAllocation pfaRecordOpal = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('TestPFA3',opalbudget, acc, 199999, false);
        insert pfaRecordOpal;
        
        PartnerFundAllocation pfaRecordCmp = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('TestPFA3',cmpbudget, acc, 199999, false);
        insert pfaRecordCmp;
        
        List<Core_MDF_Campaign_Budgets__c>  CampaignBudgetList = new List<Core_MDF_Campaign_Budgets__c>();
        Core_MDF_Campaign_Budgets__c mdfBudget = new Core_MDF_Campaign_Budgets__c();
        mdfBudget.Core_MDF_Budget_Name_Id__c = cmpbudget.id;
        mdfBudget.Core_MDF_Campaign_Id__c=MDFcamp.id;
        mdfBudget.Core_MDF_Budget_Amt__c=363636;
        mdfBudget.Core_MDF_Reimbursement_Rate_Pct__c='100%';
        mdfBudget.Core_MDF_Reimbursement_Amt__c= 200000;
        mdfBudget.Core_MDF_Active_ind__c=true;
        CampaignBudgetList.add(mdfBudget);
        
        Core_MDF_Campaign_Budgets__c oemcmpBudget = new Core_MDF_Campaign_Budgets__c();
        oemcmpBudget.Core_MDF_Budget_Name_Id__c = opalbudget.id;
        oemcmpBudget.Core_MDF_Campaign_Id__c=MDFcamp.id;
        oemcmpBudget.Core_MDF_Budget_Amt__c=363636;
        oemcmpBudget.Core_MDF_Reimbursement_Rate_Pct__c='100%';
        oemcmpBudget.Core_MDF_Reimbursement_Amt__c= 200000;
        oemcmpBudget.Core_MDF_Active_ind__c=true;
        CampaignBudgetList.add(oemcmpBudget);
        System.runAs(usr1){
            Database.insert(CampaignBudgetList);
        }
        PartnerFundRequest MDFpfr = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(MDFcamp.Id),
                                                                                          Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,string.valueof(acc.id),null,null,'INDIA','Small Business','Desktop',
                                                                                          'Intel® Core™ i7 Processor','Broadcast','Radio','Draft',false);
        MDFpfr.Title = 'Test Activity';
        MDFpfr.Core_MDF_Activity_Description__c = 'Test Activity';
        MDFpfr.Core_MDF_Start_Date__c = system.today()-90;
        MDFpfr.Core_MDF_End_Date__c =  system.today()-30;
        MDFpfr.BudgetId = opalbudget.Id;
        MDFpfr.AllocationId = pfaRecordOpal.Id;
        MDFpfr.Core_MDF_Channel_Partner_Led__c = True;
        MDFpfr.Core_MDF_Budget_Type_nm__c = 'MDF';
        MDFpfr.Core_MDF_Approval_Step_Completed__c = 1;
        MDFpfr.Core_MDF_Price_reviewer_check_ind__c = False; 
        MDFpfr.Core_MDF_Program_Office_Check_ind__c = False;
        MDFpfr.Core_MDF_Require_Additional_Review_ind__c = True;
        MDFpfr.Core_MDF_Reimbursement_Rate_txt__c = '100%';
        MDFpfr.Core_MDF_Reimbursement_Rate_pct__c='100%';
        MDFpfr.Core_MDF_Activity_Closure_Type__c='Manual';
        MDFpfr.Core_MDF_Fund_Request_Status__c = 'Pending Review';
        MDFpfr.Core_MDF_PriorValueOfStatus__c='Planned';
        pfrList.add(MDFpfr);
        
        
        PartnerFundRequest OemCmpPfr = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(MDFcamp.Id),
                                                                                             Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,string.valueof(acc.id),null,null,'INDIA','Small Business','Desktop',
                                                                                             'Intel® Core™ i7 Processor','Broadcast','Radio','Draft',false);
        OemCmpPfr.Title = 'Test Activity OEMCMP';
        OemCmpPfr.Core_MDF_Activity_Description__c = 'Test Activity';
        OemCmpPfr.Core_MDF_Start_Date__c = system.today()-90;
        OemCmpPfr.BudgetId = cmpbudget.Id;
        OemCmpPfr.AllocationId = pfaRecordCmp.Id;
        OemCmpPfr.Core_MDF_Budget_Type_nm__c = 'OEM CMP';
        OemCmpPfr.Core_MDF_End_Date__c =  system.today()-30;
        OemCmpPfr.Core_MDF_Channel_Partner_Led__c = True;
        OemCmpPfr.Core_MDF_Approval_Step_Completed__c = 1;
        OemCmpPfr.Core_MDF_Price_reviewer_check_ind__c = False; 
        OemCmpPfr.Core_MDF_Program_Office_Check_ind__c = False;
        OemCmpPfr.Core_MDF_Require_Additional_Review_ind__c = True;
        OemCmpPfr.Core_MDF_Reimbursement_Rate_txt__c = '100%';
        OemCmpPfr.Core_MDF_Reimbursement_Rate_pct__c='100%';
        OemCmpPfr.Core_MDF_Activity_Closure_Type__c='Manual';
        OemCmpPfr.Core_MDF_PriorValueOfStatus__c='Planned';
        OemCmpPfr.Core_MDF_Fund_Request_Status__c='Pending Review';
        pfrList.add(OemCmpPfr);
        
        
        PartnerFundRequest OemCmpPfr1 = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(MDFcamp.Id),
                                                                                              Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,string.valueof(acc.id),null,null,'INDIA','Small Business','Desktop',
                                                                                              'Intel® Core™ i7 Processor','Broadcast','Radio','Draft',false);
        OemCmpPfr1.Title = 'Test Activity OEMCMP1';
        OemCmpPfr1.Core_MDF_Activity_Description__c = 'Test Activity';
        OemCmpPfr1.Core_MDF_Start_Date__c = system.today()-90;
        OemCmpPfr1.BudgetId = cmpbudget.Id;
        OemCmpPfr1.AllocationId = pfaRecordCmp.Id;
        OemCmpPfr1.Core_MDF_Budget_Type_nm__c = 'OEM CMP';
        OemCmpPfr1.Core_MDF_End_Date__c =  system.today()-30;
        OemCmpPfr1.Core_MDF_Channel_Partner_Led__c = True;
        OemCmpPfr1.Core_MDF_Approval_Step_Completed__c = 1;
        OemCmpPfr1.Core_MDF_Price_reviewer_check_ind__c = False; 
        OemCmpPfr1.Core_MDF_Program_Office_Check_ind__c = False;
        OemCmpPfr1.Core_MDF_Require_Additional_Review_ind__c = True;
        OemCmpPfr1.Core_MDF_Reimbursement_Rate_txt__c = '100%';
        OemCmpPfr1.Core_MDF_Reimbursement_Rate_pct__c='100%';
        OemCmpPfr1.Core_MDF_Activity_Closure_Type__c='Manual';
        OemCmpPfr1.Core_MDF_PriorValueOfStatus__c='Planned';
        OemCmpPfr1.Core_MDF_Fund_Request_Status__c='Closed'; 
        OemCmpPfr1.RequestedAmount = 1;
        pfrList.add(OemCmpPfr1);
        
        
        PartnerFundRequest OemCmpPfr2 = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(MDFcamp.Id),
                                                                                              Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,string.valueof(acc.id),null,null,'INDIA','Small Business','Desktop',
                                                                                              'Intel® Core™ i7 Processor','Broadcast','Radio','Draft',false);
        OemCmpPfr2.Title = 'Test Activity OEMCMP2';
        OemCmpPfr2.Core_MDF_Activity_Description__c = 'Test Activity';
        OemCmpPfr2.Core_MDF_Start_Date__c = system.today()-90;
        OemCmpPfr2.BudgetId = cmpbudget.Id;
        OemCmpPfr2.AllocationId = pfaRecordCmp.Id;
        OemCmpPfr2.Core_MDF_Budget_Type_nm__c = 'OEM CMP';
        OemCmpPfr2.Core_MDF_End_Date__c =  system.today()-30;
        OemCmpPfr2.Core_MDF_Channel_Partner_Led__c = True;
        OemCmpPfr2.Core_MDF_Approval_Step_Completed__c = 1;
        OemCmpPfr2.Core_MDF_Price_reviewer_check_ind__c = False; 
        OemCmpPfr2.Core_MDF_Program_Office_Check_ind__c = False;
        OemCmpPfr2.Core_MDF_Require_Additional_Review_ind__c = True;
        OemCmpPfr2.Core_MDF_Reimbursement_Rate_txt__c = '100%';
        OemCmpPfr2.Core_MDF_Reimbursement_Rate_pct__c='100%';
        OemCmpPfr2.Core_MDF_Activity_Closure_Type__c='Manual';
        OemCmpPfr2.Core_MDF_PriorValueOfStatus__c='Planned';
        OemCmpPfr2.Core_MDF_Fund_Request_Status__c='Closed';        
        OemCmpPfr2.RequestedAmount = 1;
        pfrList.add(OemCmpPfr2);
        
        PartnerFundRequest RetailPfr = Core_MDF_CCP_TestDataUtility.createRetailActivity(string.valueof(camp1.Id),string.valueof(accRetail.id),System.today(),System.today(),false); 
        RetailPfr.Title ='Retail RSA MD Activity';
        RetailPfr.Core_MDF_Activity_Description__c ='Retail RSA MD Activity';
        RetailPfr.Core_MDF_Budget_Type_nm__c ='RSA MD';
        RetailPfr.RequestedAmount =1000;
        RetailPfr.Core_MDF_Country_nm__c = 'AFGHANISTAN';
        RetailPfr.Core_MDF_Fund_Request_Status__c = 'Planned';
        RetailPfr.Core_MDF_Budget_Currency_cd__c ='USD';
        RetailPfr.Core_MDF_Reimbursement_Rate_pct__c='100%';
        pfrList.add(RetailPfr);
        
        PartnerFundRequest RetailPfrAd = Core_MDF_CCP_TestDataUtility.createRetailActivity(string.valueof(camp2.Id),string.valueof(accRetail.id),System.today(),System.today(),false); 
        RetailPfrAd.Title ='Retail RSA MD Activity Test';
        RetailPfrAd.Core_MDF_Activity_Description__c ='Retail RSA MD Activity Test';
        RetailPfrAd.Core_MDF_Budget_Type_nm__c ='Retail MDF';
        RetailPfrAd.RequestedAmount =1000;
        RetailPfrAd.Core_MDF_Country_nm__c = 'AFGHANISTAN';
        RetailPfrAd.Core_MDF_Fund_Request_Status__c = 'Planned';
        RetailPfrAd.Core_MDF_Budget_Currency_cd__c ='USD';
        RetailPfrAd.Core_MDF_Reimbursement_Rate_pct__c='100%';
        pfrList.add(RetailPfrAd);
        
        PartnerFundRequest pfr3 = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(oemCamp.Id),
                                                                                        Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,
                                                                                        string.valueof(acc.id),pfaRecordCmp,cmpbudget,'INDIA','Small Business',
                                                                                        'Desktop','Intel® Corporate Logo','Broadcast',
                                                                                        'Radio','Draft',false);
        pfr3.RequestedAmount = 9000;
        pfr3.Amount = 9000;
        pfr3.Status = 'Approved';
        pfr3.title = 'Test CCF Activity 3';
        pfr3.Core_MDF_Start_Date__c = System.today().addDays(-5);
        pfr3.Core_MDF_End_Date__c = System.today();
        //pfr3.Core_MDF_Region_cd__c = 'APJ';
        pfr3.Core_MDF_Region_nm__c = 'APJ';
        pfr3.Core_MDF_Budget_Type_nm__c = 'OEM CMP';
        pfr3.Core_MDF_Reimbursement_Rate_txt__c = '100%';
        pfrList.add(pfr3);
        System.runAs(usr1){
            Database.insert(pfrList);
        }
        PartnerFundRequestHistory ph1=new PartnerFundRequestHistory();
        ph1.Field='Core_MDF_ToBeClosedDate__c';
        ph1.PartnerFundRequestId=RetailPfr.Id;
        Database.insert(ph1);
        
        PartnerFundRequestHistory ph2=new PartnerFundRequestHistory();
        ph2.Field='Core_MDF_ActivityCategory__c';
        ph2.PartnerFundRequestId=RetailPfrAd.Id;
        Database.insert(ph2);
        
        
        PartnerFundRequest RetailPfr1 = Core_MDF_CCP_TestDataUtility.createRetailActivity(string.valueof(camp2.Id),string.valueof(accRetail.id),System.today(),System.today(),false); 
        RetailPfr1.Title ='Retail RSA MD Activity1';
        RetailPfr1.Core_MDF_Activity_Description__c ='Retail RSA MD Activity1';
        RetailPfr1.Core_MDF_Budget_Type_nm__c ='Retail MDF';
        RetailPfr1.RequestedAmount =1000;
        RetailPfr1.Core_MDF_Country_nm__c = 'AFGHANISTAN';
        RetailPfr1.Core_MDF_Fund_Request_Status__c = 'Planned';
        RetailPfr1.Core_MDF_Budget_Currency_cd__c ='USD';
        RetailPfr1.Core_MDF_Reimbursement_Rate_pct__c='100%';
        System.runAs(usr1){
            Database.insert(RetailPfr1);
        }
        Account ipaUltimateAccount = Core_MDF_CCP_TestDataUtility.createIntelAccount ('IPA Intel Account',Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, true);
        Account IPACoMarketingAcc = Core_MDF_CCP_TestDataUtility.createAccount ('Test IPA Account', ipaCP.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type,  false);
        IPACoMarketingAcc.Core_MDF_Parent_Fund_Account__c = ipaUltimateAccount.Id;
        IPACoMarketingAcc.Core_MDF_CoMarketing_Ultimate_Account__c = ipaUltimateAccount.Id;
        System.runAs(usr1){
            Database.insert(IPACoMarketingAcc);
        }
        Campaign camp4 = Core_MDF_CCP_TestDataUtility.createCampaign('Test Camp IPA','Gaming','Intel® Core™ i7+ Processor','Yes', Core_MDF_CCP_IPA_TestDataUtility.campaign_RecordType_IPA, 'Intel Partner Alliance', System.today()-15, System.today()+15, 10000, 'Consumer Chromebook', IPACoMarketingAcc.Id, '2-in-1', false);
        camp4.Core_MDF_Proposal_Based_Ind__c=false;
        camp4.Core_MDF_Program__c='Intel Partner Alliance';
        camp4.Core_MDF_Market__c = 'INDIA';
        System.runAs(usr1){
            Database.insert(camp4);
        }
        PartnerFundRequest IPApfr2 = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(camp4.Id),
                                                                                           Core_MDF_CCP_IPA_TestDataUtility.partnerFund_RecordType_IPA,string.valueof(IPACoMarketingAcc.id),NULL,NULL,'India','','Traditional Notebook',
                                                                                           'Intel® 11ᵗʰ Gen','Sales Incentive','Seller - Target SPIF','Draft',false); 
        IPApfr2.Core_MDF_Activity_Description__c = 'Test IPA Activity2';
        IPApfr2.Title = 'Test IPA Activity2';
        IPApfr2.Core_MDF_Approval_Stage__c='Program Office Reviewer';
        IPApfr2.Core_MDF_Start_Date__c = System.today().addDays(1);
        IPApfr2.Core_MDF_End_Date__c = System.today().addDays(2);
        IPApfr2.Core_MDF_Program_Office_Check_ind__c = true;
        IPApfr2.Core_MDF_Country_nm__c = 'India';
        IPApfr2.Core_MDF_Fund_Request_Status__c = 'Pending Review';
        IPApfr2.Core_MDF_Reimbursement_Rate_txt__c = '100%';
        IPApfr2.Core_MDF_Reimbursement_Rate_pct__c='100%';
        IPApfr2.RequestedAmount =1000;
        System.runAs(usr1){
            Database.insert(IPApfr2);
        }
        
        Set<String> psNameSet = new Set<String> ();
        Map<string,String>  psNameVsIdMap = new Map<string,String>();
        psNameSet.add('Core_MDF_CCP_Internal_CCF_Acct_Mgr');
        psNameSet.add('Core_MDF_CCP_Internal_Generic_Access');
        psNameSet.add('Core_MDF_CCP_Internal_Retail_Account_Manager');
        psNameVsIdMap = getPermissionSetIdbyName(psNameSet);
        String ccfAcctMgrPsId =  psNameVsIdMap.get('Core_MDF_CCP_Internal_CCF_Acct_Mgr');
        String genricAccessPsId =  psNameVsIdMap.get('Core_MDF_CCP_Internal_Generic_Access');
        String rmfAcctMgrPsId =  psNameVsIdMap.get('Core_MDF_CCP_Internal_Retail_Account_Manager');
        
        User ccfaccntmngr = Core_MDF_CCP_TestDataUtility.createUser(false);
        ccfaccntmngr.Email = 'ccfaccntmngr@example.com';
        ccfaccntmngr.Profile = ccpCoreProfile;
        Database.insert(ccfaccntmngr);
        
        User rmfaccntmngr = Core_MDF_CCP_TestDataUtility.createUser(false);
        rmfaccntmngr.Email = 'rmfaccntmngr@example.com';
        rmfaccntmngr.Profile = ccpCoreProfile;
        Database.insert(rmfaccntmngr);
        
        
    }
    
    static Map<string,String> getPermissionSetIdbyName(Set<String> psNameSet){
        Map<string,String>  resultMap = new Map<string,String>();
        for(permissionSet ps: [SELECT Id , Name
                               FROM PermissionSet
                               WHERE Name IN:psNameSet]){
                                   resultMap.put(ps.Name, ps.Id);
                                   
                               }
        return resultMap;
    }
    
    @isTest
    public static void validateActivityTest1(){
        Test.startTest();
        User usr = [select id from User where lastname='Budget Loader CCPTest' limit 1];
        System.runAs(usr){
            PermissionSet psFinance = [SELECT Id FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_CCF_Field_Acct_Mgr' LIMIT 1];
            insert new PermissionSetAssignment(AssigneeId = usr.id, PermissionSetId = psFinance.Id);
        }
        string returnMsg='';
        PartnerFundRequest pfr=[select id,Core_MDF_Fund_Request_Status__c,Core_MDF_PriorValueOfStatus__c,Core_MDF_ToBeClosedDate__c,Core_MDF_Budget_Type_nm__c from  PartnerFundRequest where title='Test Activity2' LIMIT 1];
        System.runAs(usr){
            returnMsg = Core_MDF_Reopen_Activity.validateActivity(pfr.id);
        }
        Core_MDF_Reopen_Activity.ReopenWrapper reOpen = (Core_MDF_Reopen_Activity.ReopenWrapper) JSON.deserialize(returnMsg,Core_MDF_Reopen_Activity.ReopenWrapper.class); 
        Test.stopTest();
        Assert.isNotNull(returnMsg);
    }
    
    @isTest
    public static void validateActivityTest2(){
        Test.startTest();
        User usr = [select id from User where lastname='Budget Loader CCPTest' limit 1];
        System.runAs(usr){
            PermissionSet psFinance = [SELECT Id FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_CCF_Field_Acct_Mgr' LIMIT 1];
            insert new PermissionSetAssignment(AssigneeId = usr.id, PermissionSetId = psFinance.Id);
        }
        PartnerFundRequest pfr=[select id,Core_MDF_Fund_Request_Status__c,Core_MDF_ToBeClosedDate__c,Core_MDF_Budget_Type_nm__c from  PartnerFundRequest where title='Test Activity' LIMIT 1];
        string returnMsg='';
        System.runAs(usr){
            returnMsg = Core_MDF_Reopen_Activity.validateActivity(pfr.id);
        }
        Core_MDF_Reopen_Activity.ReopenWrapper reOpen = (Core_MDF_Reopen_Activity.ReopenWrapper) JSON.deserialize(returnMsg,Core_MDF_Reopen_Activity.ReopenWrapper.class); 
        Test.stopTest();
        Assert.isNotNull(returnMsg);
    }
    
    @isTest
    public static void validateActivityTest3(){
        Test.startTest();
        User usr = [select id from User where lastname='Budget Loader CCPTest' limit 1];
        System.runAs(usr){
            PermissionSet psFinance = [SELECT Id FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_CCF_Field_Acct_Mgr' LIMIT 1];
            insert new PermissionSetAssignment(AssigneeId = usr.id, PermissionSetId = psFinance.Id);
        }
        PartnerFundRequest pfr=[select id,Core_MDF_Fund_Request_Status__c,Core_MDF_PriorValueOfStatus__c,Core_MDF_ToBeClosedDate__c,Core_MDF_Budget_Type_nm__c,Core_MDF_ATF_Flag_nm__c from  PartnerFundRequest where title='Test IPA Activity2' LIMIT 1];
        string returnMsg='';
        System.runAs(usr){
            returnMsg = Core_MDF_Reopen_Activity.validateActivity(pfr.id);
            Core_MDF_Reopen_Activity.ReopenWrapper reOpen = (Core_MDF_Reopen_Activity.ReopenWrapper) JSON.deserialize(returnMsg,Core_MDF_Reopen_Activity.ReopenWrapper.class); 
        }
        Test.stopTest();
        Assert.isNotNull(returnMsg);
    }
    
    @isTest
    public static void validateActivityTest4(){
        PartnerFundRequest pfr=[select id,Core_MDF_Fund_Request_Status__c,Core_MDF_Activity_Closure_Type__c,Core_MDF_ToBeClosedDate__c,Core_MDF_Budget_Type_nm__c from  PartnerFundRequest where title='Test Activity' LIMIT 1];
        Test.startTest();
        User user1 = [select id,email from User where email='ccfaccntmngr@example.com' limit 1];
        User usr = [select id from User where lastname='Budget Loader CCPTest' limit 1];
        System.runAs(usr){
            PermissionSet psFinance = [SELECT Id FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_CCF_Field_Acct_Mgr' LIMIT 1];
            insert new PermissionSetAssignment(AssigneeId = usr.id, PermissionSetId = psFinance.Id);
        }
        pfr.Core_MDF_Activity_Closure_Type__c='Auto';
        pfr.Core_MDF_Fund_Request_Status__c='Closed'; 
        System.runAs(user1){
            update pfr;
        }
        Core_MDF_Reopen_Activity.ReopenWrapper reOpen;
        System.runAs(usr){
            string returnMsg=Core_MDF_Reopen_Activity.validateActivity(pfr.id);
            reOpen = (Core_MDF_Reopen_Activity.ReopenWrapper) JSON.deserialize(returnMsg,Core_MDF_Reopen_Activity.ReopenWrapper.class); 
            Core_MDF_Reopen_Activity.reOpenActivity(pfr.id);
        }
        Test.stopTest();
        Assert.areEqual(reOpen.validationMsg, system.Label.Core_MDF_Activity_Not_Closed_Manually);
    }
    
    @isTest
    public static void validateActivityTest5(){
        
        Test.startTest();
        User user1 = [select id,email from User where email='ccfaccntmngr@example.com' limit 1];
        PartnerFundRequest pfr=[select id ,Core_MDF_Program__c from PartnerFundRequest where title='Test Activity' LIMIT 1];
        User usr=[select id from User where lastname='Budget Loader CCPTest' limit 1];
        System.runAs(usr){
            PermissionSet psFinance = [SELECT Id FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_CCF_Field_Acct_Mgr' LIMIT 1];
            insert new PermissionSetAssignment(AssigneeId = usr.id, PermissionSetId = psFinance.Id);
            
        }
        pfr.Core_MDF_Fund_Request_Status__c = 'Closed';
        pfr.Core_MDF_ToBeClosedDate__c=system.today()-10;
        System.runAs(user1){
            update pfr;
        }
        Core_MDF_Reopen_Activity.ReopenWrapper reOpen=new Core_MDF_Reopen_Activity.ReopenWrapper();
        System.runAs(usr){
            string returnMsg=Core_MDF_Reopen_Activity.validateActivity(pfr.id);
            reOpen = (Core_MDF_Reopen_Activity.ReopenWrapper) JSON.deserialize(returnMsg,Core_MDF_Reopen_Activity.ReopenWrapper.class); 
        }
        Test.stopTest();
        Assert.areEqual(reOpen.validationMsg,'success');
    }
    
    @isTest
    public static void validateActivityTest6(){
        Test.startTest();
        User user1 = [select id,email from User where email='ccfaccntmngr@example.com' limit 1];
        PartnerFundRequest pfr1 = [select id,Core_MDF_Program__c,Core_MDF_PriorValueOfStatus__c from PartnerFundRequest where title='Test Activity' LIMIT 1];
        User usr=[select id from User where lastname='Budget Loader CCPTest' limit 1];
        System.runAs(usr){
            PermissionSet psFinance = [SELECT Id FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_CCF_Field_Acct_Mgr' LIMIT 1];
            insert new PermissionSetAssignment(AssigneeId = usr.id, PermissionSetId = psFinance.Id);
        }
        try{
            System.runAs(user1){
                pfr1.Core_MDF_Fund_Request_Status__c = 'Pending Review';
                update pfr1; 
            }
        }catch(exception ex){
        }
        string returnMsg='';
        System.runAs(usr){
            returnMsg = Core_MDF_Reopen_Activity.validateActivity(pfr1.id);
        }
        Test.stopTest();
        Assert.isNotNull(returnMsg);
        
    }
    
    @isTest
    public static void validateActivityTest7(){
        PartnerFundRequest pfr1 = [select id,Core_MDF_Program__c,Core_MDF_Start_Date__c,Core_MDF_End_Date__c,Core_MDF_PriorValueOfStatus__c from PartnerFundRequest where title='Test Activity' LIMIT 1];
        Test.startTest();
        User usr=[select id from User where lastname='Budget Loader CCPTest' limit 1];
        System.runAs(usr){
            PermissionSet psFinance = [SELECT Id FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_CCF_Field_Acct_Mgr' LIMIT 1];
            insert new PermissionSetAssignment(AssigneeId = usr.id, PermissionSetId = psFinance.Id);
        }
        pfr1.Core_MDF_Fund_Request_Status__c = 'Closed';
        pfr1.Core_MDF_Activity_Closure_Type__c='Manual';
        pfr1.Core_MDF_Start_Date__c=system.today()-95;
        pfr1.Core_MDF_End_Date__c=system.today()-95;
        User user1 = [select id,email from User where email='ccfaccntmngr@example.com' limit 1];  
        System.runAs(user1){
            update pfr1;
        }
        string returnMsg='';
        System.runAs(usr){
            returnMsg = Core_MDF_Reopen_Activity.validateActivity(pfr1.id);
        }
        Test.stopTest();
        Assert.isNotNull(returnMsg);
        
    }
    
    @isTest
    public static void validateActivityCMPTest(){
        PartnerFundRequest pfr1 = new PartnerFundRequest();
        List<PartnerFundRequest> pfrList = new List<PartnerFundRequest>();
        pfrList = [select id,Core_MDF_Program__c,title,BudgetId,CampaignId,Core_MDF_Budget_Type_nm__c,Core_MDF_Start_Date__c,
                   Core_MDF_End_Date__c,Core_MDF_PriorValueOfStatus__c,Core_MDF_Fund_Request_Status__c,Core_MDF_Activity_Closure_Type__c
                   from PartnerFundRequest];
        
        for(PartnerFundRequest pfr: pfrList){
            if(pfr.Title == 'Test Activity OEMCMP'){
                pfr1 = pfr;
            }
            pfr.Core_MDF_Fund_Request_Status__c = 'Closed';
            pfr.Core_MDF_Activity_Closure_Type__c='Manual';
        }
        Test.startTest();
        User usr=[select id from User where lastname='Budget Loader CCPTest' limit 1];
        System.runAs(usr){
            PermissionSet psFinance = [SELECT Id FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_CCF_Acct_Mgr' LIMIT 1];
            insert new PermissionSetAssignment(AssigneeId = usr.id, PermissionSetId = psFinance.Id);
        }
        User user1 = [select id,email from User where email='ccfaccntmngr@example.com' limit 1];
        System.runAs(user1){
            update pfrList;
        }
        
        System.runAs(usr){
            //update pfrList;
            string returnMsg = Core_MDF_Reopen_Activity.validateActivity(pfr1.id);
            Assert.isNotNull(returnMsg);
            pfr1.Core_MDF_Fund_Request_Status__c='Cancelled';
            Core_MDF_Reopen_Activity.validateActivity(pfr1.id);
        }
        Test.stopTest();
    }
    
    @isTest
    public static void validateActivityCMPTestCheck(){
        PartnerFundRequest pfr1 = new PartnerFundRequest();
        List<PartnerFundRequest> pfrList = new List<PartnerFundRequest>();
        pfrList = [select id,Core_MDF_Program__c,title,BudgetId,CampaignId,Core_MDF_Budget_Type_nm__c,Core_MDF_Start_Date__c,
                   Core_MDF_End_Date__c,Core_MDF_PriorValueOfStatus__c,Core_MDF_Fund_Request_Status__c,Core_MDF_Activity_Closure_Type__c
                   from PartnerFundRequest];
        
        for(PartnerFundRequest pfr: pfrList){
            if(pfr.Title == 'Test Activity OEMCMP'){
                pfr1 = pfr;
            }
            pfr.Core_MDF_Fund_Request_Status__c = 'Planned';
            pfr.Core_MDF_Activity_Closure_Type__c='Manual';
        }
        Test.startTest();
        User usr=[select id from User where lastname='Budget Loader CCPTest' limit 1];
        System.runAs(usr){
            PermissionSet psFinance = [SELECT Id FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_CCF_Acct_Mgr' LIMIT 1];
            insert new PermissionSetAssignment(AssigneeId = usr.id, PermissionSetId = psFinance.Id);
        }
        User user1 = [select id,email from User where email='ccfaccntmngr@example.com' limit 1];
        System.runAs(user1){
            update pfrList;
        }
        System.runAs(usr){
            //update pfrList;
            string returnMsg = Core_MDF_Reopen_Activity.validateActivityWithCampaign(pfr1);
            Assert.isNotNull(returnMsg);
        }
        Test.stopTest();
        
    }
    
    
    @isTest
    public static void validateActivityCMPTest2(){
        PartnerFundRequest pfr = [select id,Core_MDF_Program__c,Core_MDF_Proposal_Based_Ind__c,Core_MDF_Budget_Type_nm__c,CampaignId,BudgetId,Campaign.Core_MDF_Reimbursement_Amt__c from PartnerFundRequest where Title = 'Test IPA Activity2' limit 1];
        Test.startTest();
        User usr=[select id from User where lastname='Budget Loader CCPTest' limit 1];
        System.runAs(usr){
            PermissionSet psFinance = [SELECT Id FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_CCF_Acct_Mgr' LIMIT 1];
            insert new PermissionSetAssignment(AssigneeId = usr.id, PermissionSetId = psFinance.Id);
        }
        //update pfrList;
        System.runAs(usr){
            string returnMsg = Core_MDF_Reopen_Activity.validateActivityWithCampaign(pfr);
            Assert.isNotNull(returnMsg);
        }
        Test.stopTest();
        
    }
    
    @isTest
    public static void validateActivityCMPTest3(){
        PartnerFundRequest pfr = [select id,Core_MDF_Program__c,Core_MDF_Proposal_Based_Ind__c,Core_MDF_Budget_Type_nm__c,CampaignId,BudgetId from PartnerFundRequest where Title = 'Retail RSA MD Activity1' limit 1];
        Test.startTest();
        User usr=[select id from User where lastname='Budget Loader CCPTest' limit 1];
        System.runAs(usr){
            PermissionSet psFinance = [SELECT Id FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_CCF_Acct_Mgr' LIMIT 1];
            insert new PermissionSetAssignment(AssigneeId = usr.id, PermissionSetId = psFinance.Id);
        }
        //update pfrList;
        System.runAs(usr){
            string returnMsg = Core_MDF_Reopen_Activity.validateActivityWithCampaign(pfr);
            Assert.isNotNull(returnMsg);
        }
        Test.stopTest(); 
        
    }
    @isTest
    public static void validateActivityOEMCMPTest(){
        Test.startTest();
        User usr2 = [select Id,email from user where email = 'rmfaccntmngr@example.com' LIMIT 1];
        PartnerFundRequest pfr1 = [select id,Core_MDF_Program__c,Core_MDF_Proposal_Based_Ind__c,Core_MDF_ToBeClosedDate__c,Core_MDF_Budget_Type_nm__c,CreatedDate,Core_MDF_End_Date__c,Core_MDF_End_Date_Is_Changed_ind__c,Core_MDF_PriorValueOfStatus__c from PartnerFundRequest where title='Retail RSA MD Activity Test' LIMIT 1];
        pfr1.Core_MDF_Start_Date__c=system.today()-95;
        pfr1.Core_MDF_End_Date__c=system.today()-95;
        pfr1.Core_MDF_ATF_Flag_nm__c='ATF date and claim window closed';
        pfr1.Core_MDF_ToBeClosedDate__c=System.today()-10;
        //pfr1.Budget.EndDate=system.today()-15;
        System.runAs(usr2){
            update pfr1;
        }
        User usr=[select id,IsActive from User where lastname='Budget Loader CCPTest' limit 1];
        System.runAs(usr){
            PermissionSet psFinance = [SELECT Id FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_Retail_Account_Manager' LIMIT 1];
            insert new PermissionSetAssignment(AssigneeId = usr.id, PermissionSetId = psFinance.Id);
        }
        
        System.runAs(usr){
            Core_MDF_Reopen_Activity.reOpenActivity(pfr1.id);
            Core_MDF_Reopen_Activity.validateActivity(pfr1.id);
        }
        Test.stopTest(); 
    }
    @isTest
    public static void ValidateActivityTest(){
        Test.startTest();
        User usr2 = [select Id,email from user where email = 'rmfaccntmngr@example.com' LIMIT 1];
        PartnerFundRequest pfr1 = [select id,Core_MDF_Program__c,Core_MDF_Proposal_Based_Ind__c,Core_MDF_ToBeClosedDate__c,Core_MDF_Budget_Type_nm__c,CreatedDate,Core_MDF_End_Date__c,Core_MDF_End_Date_Is_Changed_ind__c,Core_MDF_PriorValueOfStatus__c from PartnerFundRequest where title='Retail RSA MD Activity' LIMIT 1];
        pfr1.Core_MDF_Manual_Closure_Prior_Status_txt__c='Planned';
        //pfr1.Core_MDF_ATF_Flag_nm__c=System.Label.Core_MDF_ATF_Closed_Status;
        System.runAs(usr2){
            update pfr1;
        }
        User usr=[select id,IsActive from User where lastname='Budget Loader CCPTest' limit 1];
        System.runAs(usr){
            PermissionSet psFinance = [SELECT Id FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_Retail_Account_Manager' LIMIT 1];
            insert new PermissionSetAssignment(AssigneeId = usr.id, PermissionSetId = psFinance.Id);
        }
        
        System.runAs(usr){
            Core_MDF_Reopen_Activity.reOpenActivity(pfr1.id);
            string returnMsg = Core_MDF_Reopen_Activity.validateActivity(pfr1.id);
            Core_MDF_Reopen_Activity.getCloseDate(pfr1);
            Core_MDF_Reopen_Activity.reOpenActivity(pfr1.id);
            Assert.isNotNull(returnMsg);
        }
        Test.stopTest();
    }
    
    
    
    /*@isTest
public static void ValidateATFActivity(){
test.startTest();
User usr2 = [select Id,email from user where email = 'rmfaccntmngr@example.com' LIMIT 1];
PartnerFundRequest pfr1 = [select id,Core_MDF_Program__c,Core_MDF_Proposal_Based_Ind__c,Core_MDF_ToBeClosedDate__c,Core_MDF_Budget_Type_nm__c,CreatedDate,Core_MDF_End_Date__c,Core_MDF_End_Date_Is_Changed_ind__c,Core_MDF_PriorValueOfStatus__c from PartnerFundRequest where title='Retail RSA MD Activity' LIMIT 1];
pfr1.Core_MDF_Start_Date__c=system.today()-95;
pfr1.Core_MDF_End_Date__c=system.today()-95;
pfr1.Core_MDF_ATF_Flag_nm__c='ATF date and claim window closed';
pfr1.Core_MDF_ToBeClosedDate__c=System.today()-10;
System.runAs(usr2){
update pfr1;
Core_MDF_Reopen_Activity.validateActivity(pfr1.id);
Core_MDF_Reopen_Activity.reOpenActivity(pfr1.id);
Core_MDF_Reopen_Activity.getActClosureDate(null);
Core_MDF_Reopen_Activity.validateActivity(null);
}
Assert.isNotNull(pfr1.id);
test.stopTest();
}*/ 
    @isTest
    public static void ValidateCatchBlock(){
        test.startTest();
        User usr2 = [select Id,email from user where email = 'rmfaccntmngr@example.com' LIMIT 1];
        Campaign camp=[select id,Name from Campaign where Name='TestCamp' limit 1];
        PartnerFundRequest pfr1 = [select id,Core_MDF_Program__c,Core_MDF_Proposal_Based_Ind__c,Core_MDF_ToBeClosedDate__c,Core_MDF_Budget_Type_nm__c,CreatedDate,Core_MDF_End_Date__c,Core_MDF_End_Date_Is_Changed_ind__c,Core_MDF_PriorValueOfStatus__c,
                                   ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__r.Core_Geo__c from PartnerFundRequest where title='Retail RSA MD Activity' LIMIT 1];
        pfr1.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__r.Core_Geo__c=null;
        System.runAs(usr2){
            update pfr1;
            Core_MDF_Reopen_Activity.reOpenActivity(pfr1.Id);
        }
        test.stopTest();
    }
    
    @istest
    public static void ValidateAllocationTest(){
        Test.startTest();
        
        PartnerFundAllocation pfa=[select id,title,amount from PartnerFundAllocation where title='TestPFA3' Limit 1];
        pfa.Amount=0;
        update pfa;
        User user1 = [select id,email from User where email='ccfaccntmngr@example.com' limit 1];
        List<PartnerFundRequest> pfrList = [select id,Core_MDF_Program__c,Core_MDF_Proposal_Based_Ind__c,Core_MDF_ToBeClosedDate__c,Core_MDF_Budget_Type_nm__c,CreatedDate,Core_MDF_End_Date__c,Core_MDF_End_Date_Is_Changed_ind__c,Core_MDF_PriorValueOfStatus__c 
                                            from PartnerFundRequest 
                                            where title='Test Activity' LIMIT 1];
        if(!pfrList.isEmpty()){
            PartnerFundRequest pfr1 = pfrList[0];
            pfr1.AllocationId=pfa.id;
            pfr1.Core_MDF_Fund_Request_Status__c = 'Closed';
            pfr1.Core_MDF_Activity_Closure_Type__c='Manual';
            System.runAs(user1){
                update pfr1;
                Core_MDF_Reopen_Activity.validateActivity(pfr1.id);
            }
        }
        Assert.isNotNull(pfrList);
        
        test.stopTest();
    }
    @isTest
    public static void validateEEFActivity(){
        Test.startTest();
        User usr = [select id from User where lastname='Test EEF User9' limit 1];
        string returnMsg = '';
        PartnerFundRequest pfr = [select id,Core_MDF_Fund_Request_Status__c,Core_MDF_PriorValueOfStatus__c,Core_MDF_ToBeClosedDate__c,
                                Core_MDF_Budget_Type_nm__c from  PartnerFundRequest where title='Test EEF Activity' LIMIT 1];
        System.runAs(usr){
            returnMsg = Core_MDF_Reopen_Activity.validateActivity(pfr.id);
            pfr.RequestedAmount = 400;
            update pfr;
            returnMsg = Core_MDF_Reopen_Activity.validateActivity(pfr.id);
            pfr.RequestedAmount = 200;
            update pfr;
            returnMsg = Core_MDF_Reopen_Activity.reOpenActivity(pfr.id);
        }
        //Core_MDF_Reopen_Activity.ReopenWrapper reOpen = (Core_MDF_Reopen_Activity.ReopenWrapper) JSON.deserialize(returnMsg,Core_MDF_Reopen_Activity.ReopenWrapper.class); 
        Test.stopTest();
        Assert.isNotNull(returnMsg);
    }
}