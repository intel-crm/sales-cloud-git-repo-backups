@isTest
public class Core_MDF_CampaignPurposeBatch_Test {
    
    public static Id payRun_RecordType_IPAMDF = Schema.SObjectType.Core_MDF_Payment_Run__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_Intel_Partner_Alliance_MDF').getRecordTypeId();
    
    // test method for data setup
    @TestSetup static void setUpData(){
        
        
        
        
        UserRole adminRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        
        User u = Core_MDF_CCP_TestDataUtility.createUser(false);
        u.LastName = 'User Test';
        u.Email = 'testsysAdmin@example.com';
        u.UserRoleId = adminRole.Id;
        insert u;
        
        User testUser = Core_MDF_CCP_TestDataUtility.createUser(false);
        testUser.LastName = 'Sys Admin';
        testUser.UserRoleId = adminRole.Id;
        testUser.IsActive=true;
        insert testUser;
        
        
        System.runAs(u){
        
        List<Account> acctList = new List<Account>();
        
        List<String> bypassFunctionKeys = new List<String>();
        bypassFunctionKeys.add('Bypass_Duplicate_Budget_Check');
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
        bypassFunctionKeys.add('byPassShareUnshareCampaignRecord');
        bypassFunctionKeys.add('byPassCampaignAndRelatedRecords');
        bypassFunctionKeys.add('Bypass_PaymentRun_Duplicate_Check');
        bypassFunctionKeys.add('Bypass_Claims_Duplicate_Check');
        bypassFunctionKeys.add('Bypass_Claims_Sharing_Internal_Users');
        bypassFunctionKeys.add('Bypass_Claims_Amt_vs_Budget_Amt_Check');        
        bypassFunctionKeys.add('Bypass_Claims_ABM_Validation');
        bypassFunctionKeys.add('Bypass_Claims_Sharing_Partner_Users');
        bypassFunctionKeys.add('Bypass_Payment_Doc_InvFileVAT_Validate');
        bypassFunctionKeys.add('Bypass_Bank_Program_InActivation_Check');
        bypassFunctionKeys.add('Bypass_Claims_Amt_vs_Camp_Amt_Check');
        bypassFunctionKeys.add('Bypass_Claim_OwnerLang_EmailTemp');
        bypassFunctionKeys.add('Bypass_StampingOfActySubType_Check');
        bypassFunctionKeys.add('Bypass_Claims_Sharing_On_Owner_Change');
        bypassFunctionKeys.add('Bypass_UpdateActivityFields');
        bypassFunctionKeys.add('Bypass_ValidateActivityWithCampaign');
        bypassFunctionKeys.add('Bypass_MDF_Budget_Access');
        bypassFunctionKeys.add('Core_MDF_XMLToXLSGenerationFlag');
        bypassFunctionKeys.add('Core_MDF_StringToXLSGenerationFlag');
        //bypassFunctionKeys.add('Bypass_Activity_ApprovalProcess');
        bypassFunctionKeys.add('Bypass_ShareActivityWithUsers');
        bypassFunctionKeys.add('Bypass_ShareActivityWithAccNodeGroup');
        bypassFunctionKeys.add('Bypass_geoLeadApprovalProcess');
        bypassFunctionKeys.add('Bypass_MDF_Budget_Access_Validation');
        bypassFunctionKeys.add('Bypass_MDF_Budget_Status_Validation');
        
        Set<String> myset1 = new Set<String>();
        List<String> result1 = new List<String>();
        myset1.addAll(bypassFunctionKeys);
        result1.addAll(myset1);
        
        List<Core_Trigger_Executions__c> bypassfunctinalitylist1 = Core_MDF_CCP_TestDataUtility.byPassFeature(result1,true,true);
        
        ChannelProgram cp = Core_MDF_CCP_TestDataUtility.createProgram ('Intel Partner Alliance','Intel Partner Alliance', true);
        Id campaign_RecordType_IPA = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Core_MDF_Intel_Partner_Alliance').getRecordTypeId();
        PermissionSet IPAPayAdmPS = [SELECT Id, Name FROM PermissionSet WHERE Name='Core_MDF_CCP_Internal_IPA_Payment_Adm' LIMIT 1];
        
        // Creating a map of profile name and profile Id
        Map<String,Id> profileToId = new Map<String,Id>();
        for(Profile prfl:[SELECT Id,Name FROM Profile WHERE Name IN ('System Administrator','CCP - Core Access')]) {
            profileToId.put(prfl.Name,prfl.Id);
        }
        
        // Creating User with utility class 
        List<User> userList = new List<User>();
        
        User usr1 = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr1.Email = 'sysadmin@example.com';
        userList.add(usr1);
        Database.insert(userList);
        system.runAs(usr1){
         PermissionSetAssignment assignPermissionSetObj1 = new PermissionSetAssignment();
            assignPermissionSetObj1.AssigneeId = usr1.Id;
            assignPermissionSetObj1.PermissionSetId = IPAPayAdmPS.Id;
            Database.insert(assignPermissionSetObj1);
        }
             // Creating a map of PS names and PS
            Map<String,PermissionSet> nameToPerSet = new Map<String,PermissionSet>();
            for(PermissionSet pSet:[SELECT Id,Name FROM PermissionSet WHERE Name IN (
                'Core_MDF_CCP_Internal_APJ_User',
                'Core_MDF_CCP_Internal_Payment_Schedule_Admin',
                'Core_MDF_CCP_Internal_IPA_Payment_Adm',
                'View_All_Data',
                'Core_MDF_CCP_Internal_IPA_Acct_Mgr'
            )]) {
                nameToPerSet.put(pSet.Name,pSet);
            }
            
            PermissionSet paymentAdmGeoPS = nameToPerSet.get('Core_MDF_CCP_Internal_APJ_User'); 
            PermissionSet paymentAdmSchedulePS = nameToPerSet.get('Core_MDF_CCP_Internal_Payment_Schedule_Admin'); 
            PermissionSet ipaPaymentAdmPS = nameToPerSet.get('Core_MDF_CCP_Internal_IPA_Payment_Adm');
            PermissionSet viewAllDataPS = nameToPerSet.get('View_All_Data');
            
        List<PermissionSetAssignment> permSetAssgnLst = new List<PermissionSetAssignment>();
            
            // Assigning IPA Payment Admin PS
           /* PermissionSetAssignment assignPermissionSetObj3 = new PermissionSetAssignment();
            assignPermissionSetObj3.AssigneeId = testUser.Id;
            assignPermissionSetObj3.PermissionSetId = accountmanagerrole.Id;
            permSetAssgnLst.add(assignPermissionSetObj3);*/
            
            
            // Assigning IPA Payment Admin PS
            PermissionSetAssignment assignPermissionSetObj2 = new PermissionSetAssignment();
            assignPermissionSetObj2.AssigneeId = testUser.Id;
            assignPermissionSetObj2.PermissionSetId = ipaPaymentAdmPS.Id;
            permSetAssgnLst.add(assignPermissionSetObj2);
            
            // Assigning CCP Internal APJ User PS
            PermissionSetAssignment assignGeoPermissionSet = new PermissionSetAssignment();
            assignGeoPermissionSet.AssigneeId = testUser.Id;
            assignGeoPermissionSet.PermissionSetId = paymentAdmGeoPS.Id;
            permSetAssgnLst.add(assignGeoPermissionSet);
            
            // Assigning Payment Admin Schedule PS
            PermissionSetAssignment assignSchedulePermissionSet = new PermissionSetAssignment();
            assignSchedulePermissionSet.AssigneeId = testUser.Id;
            assignSchedulePermissionSet.PermissionSetId = paymentAdmSchedulePS.Id;
            permSetAssgnLst.add(assignSchedulePermissionSet);
            
            // Assigning View All Data PS
            PermissionSetAssignment assignViewAllPermissionSet = new PermissionSetAssignment();
            assignViewAllPermissionSet.AssigneeId = testUser.Id;
            assignViewAllPermissionSet.PermissionSetId = viewAllDataPS.Id;
            permSetAssgnLst.add(assignViewAllPermissionSet);
            system.runAs(testUser){
                Database.insert(permSetAssgnLst);
                
            }
            PermissionSet ccfAccManagerPS = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_CCF_Acct_Mgr' LIMIT 1];
            PermissionSet retailAccManagerPS = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_Retail_Account_Manager' LIMIT 1];
            PermissionSet ipaAccManagerPS = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_IPA_Acct_Mgr' LIMIT 1];
            PermissionSet ipaProgAdmPS = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_Proposal_Activity_POR_Approver' LIMIT 1];
            PermissionSet ipaL2ApproverPS = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_Proposal_Activity_L2_Approver' LIMIT 1];
            PermissionSet ipaPriceReviewPS = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_Price_Reviewer' LIMIT 1];
            PermissionSet rmfGeoApp = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_Retail_Marketing_GEO_Approver' LIMIT 1];
            PermissionSet ipaL1Approver = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Int_IPA_ProposalL1_Approver' LIMIT 1];
            PermissionSet dcfBudgetApprover = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_DCF_MDF_Budget_Approver' LIMIT 1];
            
            List<PermissionSetAssignment> permissionSetAssignmentList = new List<PermissionSetAssignment>();
            PermissionSetAssignment psa = new PermissionSetAssignment(PermissionSetId = ipaPriceReviewPS.Id, AssigneeId = testUser.Id);
            permissionSetAssignmentList.add(psa);
            
            PermissionSetAssignment psa1 = new PermissionSetAssignment(PermissionSetId = ccfAccManagerPS.Id, AssigneeId = testUser.Id);
            permissionSetAssignmentList.add(psa1);
            
            PermissionSetAssignment psa6 = new PermissionSetAssignment(PermissionSetId = retailAccManagerPS.Id, AssigneeId = testUser.Id);
            permissionSetAssignmentList.add(psa6);
            
            PermissionSetAssignment psa7 = new PermissionSetAssignment(PermissionSetId = ipaAccManagerPS.Id, AssigneeId = testUser.Id);
            permissionSetAssignmentList.add(psa7);
            
            PermissionSetAssignment psa8 = new PermissionSetAssignment(PermissionSetId = ipaProgAdmPS.Id, AssigneeId = testUser.Id);
            permissionSetAssignmentList.add(psa8);
            
            PermissionSetAssignment psa9 = new PermissionSetAssignment(PermissionSetId = ipaL2ApproverPS.Id, AssigneeId = testUser.Id);
            permissionSetAssignmentList.add(psa9);
            
            PermissionSetAssignment psa10 = new PermissionSetAssignment(PermissionSetId = rmfGeoApp.Id, AssigneeId = testUser.Id);
            permissionSetAssignmentList.add(psa10);
            
            PermissionSetAssignment psa11 = new PermissionSetAssignment(PermissionSetId = ipaL1Approver.Id, AssigneeId = testUser.Id);
            permissionSetAssignmentList.add(psa11);
            
            PermissionSetAssignment psa12 = new PermissionSetAssignment(PermissionSetId = dcfBudgetApprover.Id, AssigneeId = testUser.Id);
            permissionSetAssignmentList.add(psa12);
            
            System.runAs(testUser){
                insert permissionSetAssignmentList;
            }
            
            
            
        Id acctRecord_Type = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Core_Partner_Account_Group').getRecordTypeId();
        Id IPABudgetCapRecord_Type = Schema.SObjectType.Core_MDF_Budget_Cap__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_IPA_Budget_Type_Cap').getRecordTypeId();
        Account acc = Core_MDF_CCP_TestDataUtility.createIntelAccount('Test IPA Accounttest', acctRecord_Type, false);
        acc.Core_MDF_CoMarketingActive__c = false;
        insert acc;
        
        // Creating Account with utility class
        Account acc1 = Core_MDF_CCP_TestDataUtility.createIntelAccount('Test IPA Account', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
        acc1.Core_Intel_Partner_Alliance_PartnerGroup__c=true;
        acc1.Core_MDF_CoMarketingActive__c = true;
        acc1.Core_IPA_One_Partner_Id__c=acc.id;
        acctList.add(acc1);
        insert(acctList);
        
        // Updating Accounts 
        acc1.isPartner = true;
        Database.update(acc1); 
        
        Account acc2 = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test Account 2', cp.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, acc1.Id, false);
        acc2.Core_Geo__c='';
        acc2.Core_Sub_Geo__c='';
        insert acc2;       
        
        //string budgetType = Core_MDF_CCP_IPA_TestDataUtility.createBenefit(acc2);
        string budgetType = 'Proposal I MDF';
        
        Group ipaGrp = new Group();
            ipaGrp.Name = 'Core CCP IPA Internal';
            ipaGrp.DeveloperName = 'Core_MDF_CCP_IPA_Internal';
          system.runAs(usr1){ 
        Database.insert(ipaGrp);
     
     GroupMember ipaGrpMem = new GroupMember();
            ipaGrpMem.UserOrGroupId = usr1.Id;
            ipaGrpMem.GroupId = ipaGrp.Id;
            Database.insert(ipaGrpMem);

        }
		Core_MDF_Partner_Group_Mapping__c pgm1 = new Core_MDF_Partner_Group_Mapping__c();
            pgm1.Core_MDF_Account__c = acc1.Id;
            pgm1.Core_MDF_Group_Name__c = 'Core_MDF_CCP_IPA_Internal';
            pgm1.Core_MDF_Type_of_Access__c = 'EXTERNAL';
            pgm1.Core_MDF_Group_Id__c = ipaGrp.Id;                
            pgm1.Core_MDF_Channel_Program__c = cp.Id;
            pgm1.Core_MDF_Source_Txt__c = 'Test';
            pgm1.Core_MDF_Region_cd__C = 'APJ';
            pgm1.Core_MDF_AccountIdGroupName__c = acc1.Id+'Core_MDF_CCP_IPA_Internal';
            Database.insert(pgm1);
        //added
        //string budgetType = Core_MDF_CCP_IPA_TestDataUtility.createBenefit(acc2);
        //budgetType = 'Data Center Specialties MDF';
        PartnerMarketingBudget budget = Core_MDF_CCP_TestDataUtility.createBudget('Test Budget New',Core_MDF_CCP_IPA_TestDataUtility.budgetIPA_ProposalBased_Record_Type,acc2.Id,cp.Id,200000,System.today().addDays(-20),System.today().addDays(300), false);
        //budget.Core_MDF_Budget_Type__c='Data Centric Acceleration - MDF';
        budget.Core_MDF_Budget_Type_Txt__c='Proposal I MDF';
        Database.insert(budget);
        
        PartnerFundAllocation pfa = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('allocation',budget,acc2, 100000,true);
        
        Campaign camp = Core_MDF_CCP_IPA_TestDataUtility.createIPACampaign('Test IPA Camp',acc2.Id, System.today().addDays(-2), System.today().addDays(300),budgetType,
                                                                           1234.00, 'AFGHANISTAN','Consumer','Coffee Lake','Planned', false);
        camp.Core_MDF_Region_cd__c = 'APJ';
        camp.Core_MDF_Budget_Type_txt__c = budgetType;
        camp.Core_MDF_Budget__c = budget.Id;
        camp.Core_MDF_Reimbursement_Amt__c = 10000;
        Database.insert(camp);
            camp.Status = 'Completed';
            camp.Core_MDF_CampOutcomeOpt_In_Ind__c=true;
            camp.Core_MDF_Outcomes_nm__c='Revenue - Billings';
            update camp;
            
        Core_MDF_Campaign_Outcomes__c campPurpose = new Core_MDF_Campaign_Outcomes__c(Core_MDF_Active_Ind__c = true, Core_MDF_Initial_Baseline_Quantity_nbr__c =10, Core_MDF_Campaign_Id__c = camp.Id, Core_MDF_Goal_Quantity_nbr__c = 10,Core_MDF_Outcome_Criteria_txt__c = 'test', Core_MDF_Outcomes_nm__c = 'Revenue - Billings');
        insert campPurpose;

        Test.startTest();
        PartnerFundRequest pfr = Core_MDF_CCP_IPA_TestDataUtility.createIPAPartnerFundRequest(camp.Id,acc2.Id,System.today().addDays(-2),System.today().addDays(20),false);
        pfr.Core_MDF_BU_Split__c ='CCG';
        pfr.Core_MDF_BU1_Split_Percent_nbr__c=100;
        pfr.amount = 500;
        pfr.Core_MDF_Reimbursement_Rate_txt__c='60%';
        pfr.Core_MDF_Country_nm__c = 'AFGHANISTAN';
        pfr.Core_MDF_ActivityCategory__c = 'Outcome-Based';
        pfr.Core_MDF_Activity_Types__c = 'Outcome-Based';
        pfr.Core_MDF_Reimbursement_Rate_txt__c ='50%';
            pfr.AllocationId=pfa.id;
        //pfr.Core_MDF_Budget_Type_nm__c = 'SOEM Client MDF';
       // pfr.Core_MDF_Budget_Type_txt__c = 'SOEM Client MDF';
        Database.insert(pfr);
        
        List<Core_MDF_Activity_Attributes__c> activityAttributeList = new List<Core_MDF_Activity_Attributes__c>();
        Core_MDF_Activity_Attributes__c activityAttributeKpi = new Core_MDF_Activity_Attributes__c();
        activityAttributeKpi.Core_MDF_Co_Marketing_Activity__c = pfr.Id;
        activityAttributeKpi.Core_MDF_Field_Name_nm__c = 'Digital Media - # of Impressions';
        activityAttributeKpi.Core_MDF_Field_Value_nbr__c = 10;
        activityAttributeKpi.Core_MDF_Is_Active_Ind__c = true;
        activityAttributeKpi.Core_MDF_Tactics_nm__c = 'Digital Media';
        activityAttributeKpi.Core_MDF_Type_nm__c = 'KPI';
        activityAttributeList.add(activityAttributeKpi);
        
        Core_MDF_Activity_Attributes__c activityAttributePercentage = new Core_MDF_Activity_Attributes__c();
        activityAttributePercentage.Core_MDF_Co_Marketing_Activity__c = pfr.Id;
        activityAttributePercentage.Core_MDF_Field_Name_nm__c = 'Digital Media Percentage Spend';
        activityAttributePercentage.Core_MDF_Field_Value_nbr__c = 100;
        activityAttributePercentage.Core_MDF_Is_Active_Ind__c = true;
        activityAttributePercentage.Core_MDF_Tactics_nm__c = 'Digital Media';
        activityAttributePercentage.Core_MDF_Type_nm__c = 'Percentage';
        activityAttributeList.add(activityAttributePercentage);
        
        insert activityAttributeList;
        
        camp.Status = 'Proposal Accepted';
        Database.update(camp);
        pfr.Core_MDF_Fund_Request_Status__c = 'Planned';
        pfr.Core_MDF_Reimbursement_Rate_pct__c ='100%';
        Database.update(pfr);
        
        Core_MDF_CCP_TestDataUtility.insertCurrencyExchangeRates();        
        Test.stopTest();
        
        List<Core_MDF_Bank__c> listBank = new List<Core_MDF_Bank__c>();
        
        Core_MDF_Bank__c bank = Core_MDF_CCP_TestDataUtility.createBank(acc1.Id, 'Core_MDF_Intel_Partner_Alliance', false,'1231231230');
        bank.Core_MDF_Intel_Company_Code__c = '650';
        bank.Core_MDF_Effective_Date__c = System.today().addDays(-2);
        bank.Core_MDF_Currency_cd__c = 'USD';
        bank.Core_MDF_Tax_codes_cd__c = 'UB';
        bank.Core_MDF_Bank_Status__c = 'Active';
        bank.Core_MDF_VAT_pct__c= '20';
        bank.Core_MDF_Bank_Location__c = 'US';
        bank.Core_MDF_Supplier_City_txt__c = 'New York';
        bank.Core_MDF_Supplier_Country_txt__c = 'US';
        bank.Core_MDF_Supplier_Postal_Code_cd__c = '110111';
        bank.Core_MDF_Supplier_Region_txt__c = 'USA';
        System.runAs(usr1){
            Database.insert(bank);
        }
        
        //Do Account Bank Mapping for 'bank' and ABM 
        Core_MDF_Account_Bank_Mapping__c abm1 = Core_MDF_CCP_TestDataUtility.createAccountBankMap(acc2.Id,bank.Id,true);
        //Database.insert(abm1);
        
        
        Core_MDF_CCP_TestDataUtility.createMDFConfigurationData();
                        Id IUPGM_recordtype_IPA = Schema.SObjectType.Core_MDF_Int_Users_Partner_Geo_Mapping__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_Intel_Partner_Alliance').getRecordTypeId();

            
            List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> iupgmList = new List<Core_MDF_Int_Users_Partner_Geo_Mapping__c>();
        Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm1 = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();        
        iupgm1.Core_MDF_Program_nm__c = 'Intel Partner Alliance';
        iupgm1.Core_MDF_Region_Sub_Region_nm__c = 'WW';
        iupgm1.Core_MDF_Approval_Region_nm__c = 'WW';
        iupgm1.Core_MDF_User_id__c = testUser.Id;
        iupgm1.Core_MDF_All_Budget_Type_Access_Ind__c = true;
        iupgm1.Core_MDF_Role_nm__c = 'Core_MDF_CCP_Internal_IPA_Acct_Mgr';
        iupgm1.Core_MDF_All_Accounts_cd__c = 'Yes';
        iupgm1.Core_MDF_Account_id__c = acc1.Id;
        iupgm1.Core_MDF_Active_Ind__c =  true;
        iupgm1.RecordTypeId = IUPGM_recordtype_IPA;
        //iupgm1.Core_MDF_Channel_Program_id__c = progToIdMap.get('Intel Partner Alliance');
        insert iupgm1;
       // iupgmList.add(iupgm1);
        
    }   
    }
    @isTest 
    static void validateIPAPaymentRun() { 
        
        // User sysAdminUser = [SELECT Id,Email FROM User WHERE Email='sysadmin@example.com' LIMIT 1];
        // User ipaPayAdm = [SELECT Id,Email FROM User WHERE Email='testPayment@example.com' LIMIT 1];
        User testUser = [SELECT Id FROM User WHERE LastName = 'Sys Admin'];
                User sysAdminUser = [SELECT Id,Email from User where Email='testsysAdmin@example.com' limit 1];

        Account acc = [SELECT Id FROM Account WHERE Name = 'Test IPA Accounttest' limit 1];
       // PartnerFundClaim claim1;
        System.runAs(testUser){          
            
            Test.startTest();
            
            // Get IPA Campaign
            Campaign ipaCamp  = [SELECT Id, Name, StartDate, Status, EndDate, Description,Core_MDF_Ultimate_Account_txt__c,
                                 Core_MDF_Budget__c, Core_MDF_Account__c, Core_MDF_Channel_Program__c,
                                 Core_MDF_Opal_Budget_Type_Txt__c, Core_MDF_Total_Campaign_Cost_Amt__c
                                 FROM Campaign 
                                 WHERE Name = 'Test IPA Camp' 
                                 LIMIT 1];
            ipaCamp.Status='Completed';
            database.update(ipaCamp);
            PartnerFundRequest pfr = [Select id,Core_MDF_Fund_Request_Status__c,Core_MDF_Start_Date__c,Core_MDF_End_Date__c from PartnerFundRequest where CampaignId=:ipaCamp.Id];
                pfr.Core_MDF_Reimbursement_Rate_pct__c ='100%';
            
                database.update(pfr);
            
            Core_MDF_Campaign_Outcomes__c cmppurpose=[SELECT Id, Name, Core_MDF_Active_Ind__c, Core_MDF_Campaign_Id__c, Core_MDF_Quantity_nbr__c,
                                                     Core_MDF_Campaign_Id__r.Core_MDF_Ultimate_Account_txt__c, Core_MDF_Campaign_Id__r.Status 
                                                     FROM Core_MDF_Campaign_Outcomes__c];
            
            
            
            List<Campaign> campToBeUpdated = new List<Campaign>();
                List<PartnerFundRequest> pfrToBeUpdated = new List<PartnerFundRequest>();
                List<PartnerFundClaim> pfc = new List<PartnerFundClaim>();
                Id recordtype = Schema.SObjectType.PartnerMarketingBudget.getRecordTypeInfosByDeveloperName().get('Core_MDF_IPA_ProposalBased').getRecordTypeId(); 
                
                
                
                PartnerMarketingBudget pmb = [Select id,Title, Description, Core_MDF_Budget_Status__c, StartDate, EndDate, Amount, Core_MDF_Budget_Type_Txt__c,
                                              Core_MDF_Budget_Partner__c,Core_MDF_Program__c, RecordTypeId, IsIgnoreValidation From PartnerMarketingBudget where Id = :ipaCamp.Core_MDF_Budget__c];
                
                PartnerFundAllocation pfa = [Select Id, ChannelPartnerId, Amount from PartnerFundAllocation where BudgetId = :pmb.Id]; 
                
                Core_MDF_Bank__c bank1 = [Select Id from Core_MDF_Bank__c where Core_MDF_Bank_Alias_Name__c='Test' limit 1];
                
                List<String> documentIdWithTitle = new List<String>();
            	list<String> tempString = new list<String>();
            	list<Core_MDF_Audit_Document__c> auditDocList = new list<Core_MDF_Audit_Document__c>(); 
                
                PartnerFundClaim claim1 =  Core_MDF_CCP_IPA_TestDataUtility.createIPAClaim('IPA Claim',Core_MDF_CCP_IPA_TestDataUtility.claim_RecordType_IPA, pfr.Id, pfr.Core_MDF_Start_Date__c, pfr.Core_MDF_Start_Date__c,1000.00, bank1.Id, false); 
                claim1.Core_MDF_Type_Txt__c ='Claim';
                claim1.Core_MDF_Currency__c='USD';
                claim1.Core_MDF_Country_Location_nm__c= 'AFGHANISTAN'; 
                claim1.Core_MDF_Campaign_Id__c = ipaCamp.Id;
            claim1.Core_MDF_Status__c='Paid';
            insert claim1;
			
                String str1 = claim1.Id+';#'+'Test Doc1';
                String str2 = claim1.Id+';#'+'Test Doc2';
				
                
                documentIdWithTitle.add(str1);
                documentIdWithTitle.add(str2);
				
                
                for(PartnerFundClaim p : pfc){
					for(String str: documentIdWithTitle){
						tempString = str.split(';#');
						Core_MDF_Audit_Document__c auditDoc = new Core_MDF_Audit_Document__c();
						auditDoc.Core_MDF_Document_Id__c = tempString[0];
						auditDoc.Core_MDF_Document_Title__c = tempString[1];
						auditDoc.Core_MDF_Claim__c = p.Id;
						auditDoc.Core_MDF_Proof_of_Branding__c = true;
						auditDoc.Core_MDF_Proof_of_Cost__c = true;
						auditDoc.Core_MDF_Proof_of_Execution__c = true;
                        auditDoc.Core_MDF_App_Document_Types_nm__c = 'Proof of Cost;Proof of Execution;Proof of Attribution';
                        auditDoc.Core_MDF_Document_Types__c = 'Proof of Cost;Proof of Execution;Proof of Attribution';
						auditDocList.add(auditDoc);
					}
				}   				
                
                if(auditDocList.size()>0){
                    Database.insert(auditDocList);                
                }
            
            list<PartnerFundClaim> claimObj=[select id,RequestId,Core_MDF_Status__c from PartnerFundClaim where RequestId=:pfr.Id limit 1];
            claimObj[0].Core_MDF_Status__c='Paid';
            database.update(claimObj);
            
           
            
            list<Core_MDF_Int_Users_Partner_Geo_Mapping__c> iupgm = [SELECT id,Core_MDF_User_id__c,Core_MDF_Program_nm__c,Core_MDF_GeoSubGeo_Budget_Type_nm__c,Core_MDF_is_User_Active_ind__c,
                                                                     Core_MDF_Role_nm__c,Core_MDF_Region_Sub_Region_nm__c, Core_MDF_Active_Ind__c,Core_MDF_Account_id__c
                                                               FROM Core_MDF_Int_Users_Partner_Geo_Mapping__c
                                                                    where Core_MDF_Account_id__c=:acc.Id
                                                                    and Core_MDF_Active_Ind__c = TRUE
                                                                    and Core_MDF_Role_nm__c='Core_MDF_CCP_Internal_IPA_Acct_Mgr'
                                                                    AND Core_MDF_is_User_Active_ind__c = TRUE];
           
            
            
            Core_MDF_CampaignPurposeBatchForReminder ipaReminder = new Core_MDF_CampaignPurposeBatchForReminder();
            Database.executeBatch(ipaReminder);
            System.Assert(ipaReminder!=null);
            
        }
        
        Test.stopTest();
    }
   

    
}