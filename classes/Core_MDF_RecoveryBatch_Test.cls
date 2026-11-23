@isTest(SeeAllData=false)
public class Core_MDF_RecoveryBatch_Test {
    
    @TestSetup
    static void makeData() {
        Profile adminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        UserRole usRole = [SELECT Id FROM UserRole WHERE Name = 'Admin' LIMIT 1];
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.Email = 'sysadmin@example.com';
        usr.profileId = adminProfile.Id;
        usr.UserRoleId = usRole.Id;
        insert usr;

        List<Core_Trigger_Executions__c> transactions = new List<Core_Trigger_Executions__c>();
        transactions.addAll(Core_MDF_CCP_TestDataUtility.byPassFeature(new List<String>{
            'Bypass_Duplicate_Budget_Check', 'Bypass_GeoBased_Budget_Sharing',
            'Bypass_Allocation_Reservation', 'Bypass_GeoBased_Allocation_Sharing',
            'Bypass_Duplicate_Bank_Check', 'Bypass_Bank_Internal_Sharing',
            'Bypass_Bank_External_Sharing', 'Bypass_Bank_Program_InActivation_Check',
            'Bypass_Account_Program_based_Sharing', 'Bypass_Bank_ABM_Sharing',
            'Bypass_Claims_Sharing_Internal_Users', 'Bypass_ABM_Internal_Sharing',
            'Bypass_ABM_External_Sharing', 'Bypass_ABM_NodeGroup_Sharing',
            'Bypass_MDF_Budget_Access_Validation', 'Bypass_MDF_Budget_Status_Validation',
            'Bypass_ValidatePartnerScoreforUpdate'
        }, true, false));
        
        system.runAs(usr) {
            Database.insert(transactions);

            // Create Channel Program
            ChannelProgram ccfCP = Core_MDF_CCP_TestDataUtility.createProgram(Core_MDF_CCP_ConstantClass.CCF_PROGRAM, 'Client CoMarketing Fund', true);
            // Create Accounts
            List<Account> accounts = new List<Account>();
            Account recoveryIntelAcc = Core_MDF_CCP_TestDataUtility.createAccount('Recovery Test Account', ccfCP.Id, Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
            recoveryIntelAcc.BillingCity = 'Recovery City';
            recoveryIntelAcc.BillingCountry = 'IND';
            recoveryIntelAcc.BillingStreet = 'Recovery Street';
            //accounts.add(recoveryIntelAcc);
            Database.insert(recoveryIntelAcc);

            Account recoveryCCFVC = Core_MDF_CCP_TestDataUtility.createAccount('Recovery CCF Virtual Corp', ccfCP.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            recoveryCCFVC.Core_MDF_Parent_Fund_Account__c = recoveryIntelAcc.Id;
            recoveryCCFVC.Core_MDF_CoMarketingActive__c = true;
            accounts.add(recoveryCCFVC);
            Database.insert(recoveryCCFVC);

            Account recoveryCCFEMEA = Core_MDF_CCP_TestDataUtility.createAccount('Recovery CCF EMEA', ccfCP.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            recoveryCCFEMEA.Core_MDF_Parent_Fund_Account__c = recoveryCCFVC.Id;
            accounts.add(recoveryCCFEMEA);
            Database.insert(recoveryCCFEMEA);

            Account recoveryEMEAFrance = Core_MDF_CCP_TestDataUtility.createAccount('Recovery CCF EMEA France', ccfCP.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            recoveryEMEAFrance.Core_MDF_Parent_Fund_Account__c = recoveryCCFEMEA.Id;
            recoveryEMEAFrance.Core_MDF_Auto_Transfer_Account__c = recoveryCCFVC.Id;
            recoveryEMEAFrance.Core_MDF_Enabled_Auto_Transfer__c = true;
            accounts.add(recoveryEMEAFrance);
            Database.insert(recoveryEMEAFrance);

           //Database.insert(accounts);

            // Create PartnerMarketingBudget
            PartnerMarketingBudget recoveryPmbRecord = Core_MDF_CCP_TestDataUtility.createBudget('Recovery PMB', Core_MDF_CCP_TestDataUtility.budget_Record_Type, recoveryCCFVC.Id, ccfCP.Id, 100000, System.today().addDays(-10), System.today().addDays(10), false);
            recoveryPmbRecord.Core_MDF_Budget_Type_Txt__c = 'OEM CMP';
            Database.insert(recoveryPmbRecord);

            // Create PartnerFundAllocation
            PartnerFundAllocation pfaRecoveryCCFFrance = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('pfaRecoveryCCFFrance', recoveryPmbRecord, recoveryEMEAFrance, 1000, true);

            // Create Bank and AccountBankMapping
            Core_MDF_Bank__c recoveryBank = Core_MDF_CCP_TestDataUtility.createBank(recoveryIntelAcc.Id, 'Core_MDF_Client_CoMarketing_Fund', true, '1231231230');
            Core_MDF_Account_Bank_Mapping__c abm = Core_MDF_CCP_TestDataUtility.createAccountBankMap(recoveryEMEAFrance.Id, recoveryBank.Id, true);

            // Create Campaign
            Campaign recoveryCamp = Core_MDF_CCP_TestDataUtility.createCampaign('ARP Campaign', 'Gaming', 'Intel® Core™ i7+ Processor', 'Yes', Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 'Client CoMarketing Fund', System.today().addDays(-5), System.today().addDays(+5), 10000, 'Consumer Chromebook', recoveryCCFVC.Id, '2-in-1', false);
            recoveryCamp.Core_MDF_Opal_Budget_Type_Txt__c = 'MDF';
            recoveryCamp.Core_MDF_Supports_legacy_program__c = 'MDF or both CMP & MDF';
            Database.insert(recoveryCamp);

            // Create Core_MDF_Campaign_Budgets__c
            Core_MDF_Campaign_Budgets__c campBudget = new Core_MDF_Campaign_Budgets__c();
            campBudget.Core_MDF_Budget_Name_Id__c = recoveryPmbRecord.id;
            campBudget.Core_MDF_Campaign_Id__c = recoveryCamp.id;
            campBudget.Core_MDF_Budget_Amt__c = 363636;
            campBudget.Core_MDF_Reimbursement_Rate_Pct__c = '55%';
            campBudget.Core_MDF_Reimbursement_Amt__c = 200000;
            campBudget.Core_MDF_Active_ind__c = true;
            Database.insert(campBudget);

            // Create Core_MDF_Configuration__c
            List<Core_MDF_Configuration__c> configMDF = new List<Core_MDF_Configuration__c>();
            Core_MDF_Configuration__c configPS = new Core_MDF_Configuration__c();
            configPS.Core_MDF_Value__c = '10';
            configPS.Name = 'Core_MDF_PScore_Edit_Buffer_Days';
            configMDF.add(configPS);

            Core_MDF_Configuration__c config = new Core_MDF_Configuration__c();
            config.NAME = 'ALLOWED_PRG_FOR_RUS_NOTIF';
            config.Core_MDF_Value__c = '3';
            config.Core_MDF_Category__c = 'Bank Document Hold Logic';
            configMDF.add(config);
            insert configMDF;

            Test.startTest();
            List<PartnerFundRequest> pfrList = new List<PartnerFundRequest>();
            PartnerFundRequest recoveryFranceActivity = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(String.valueOf(recoveryCamp.Id), Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF, String.valueOf(recoveryEMEAFrance.id), pfaRecoveryCCFFrance, recoveryPmbRecord, 'INDIA', 'Consumer', 'Desktop', 'Intel® Core™ i5 Processor', 'Broadcast', 'Podcast', 'Draft', false);
            recoveryFranceActivity.Title = 'France Activity';
            recoveryFranceActivity.Core_MDF_Activity_Description__c = 'France Activity';
            recoveryFranceActivity.Core_MDF_Start_Date__c = System.today().addDays(-2);
            recoveryFranceActivity.Core_MDF_End_Date__c = System.today().addDays(+2);
            recoveryFranceActivity.RequestedAmount = 1000;
            recoveryFranceActivity.Core_MDF_pagespayingfor__c = 15;
            recoveryFranceActivity.Amount = 1000;
            recoveryFranceActivity.Core_MDF_Budget_Type_nm__c = 'MDF';
            recoveryFranceActivity.Core_MDF_Reimbursement_Rate_pct__c = '50%';
            recoveryFranceActivity.Core_MDF_Reimbursement_Rate_txt__c = '50%';
            recoveryFranceActivity.Core_MDF_Channel_Partner_Led__c = true;

            PartnerFundRequest recoveryFranceActivityMDFP = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(String.valueOf(recoveryCamp.Id), Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF, String.valueOf(recoveryEMEAFrance.id), pfaRecoveryCCFFrance, recoveryPmbRecord, 'INDIA', 'Consumer', 'Desktop', 'Intel® Core™ i5 Processor', 'Broadcast', 'Podcast', 'Draft', false);
            recoveryFranceActivityMDFP.Title = 'France Activity MDF+';
            recoveryFranceActivityMDFP.Core_MDF_Activity_Description__c = 'France Activity MDF+';
            recoveryFranceActivityMDFP.Core_MDF_Start_Date__c = System.today().addDays(-2);
            recoveryFranceActivityMDFP.Core_MDF_End_Date__c = System.today().addDays(+2);
            recoveryFranceActivityMDFP.RequestedAmount = 1000;
            recoveryFranceActivityMDFP.Core_MDF_pagespayingfor__c = 15;
            recoveryFranceActivityMDFP.Amount = 1000;
            recoveryFranceActivityMDFP.Core_MDF_Budget_Type_nm__c = 'MDF+';
            recoveryFranceActivityMDFP.Core_MDF_Reimbursement_Rate_pct__c = '50%';
            recoveryFranceActivityMDFP.Core_MDF_Reimbursement_Rate_txt__c = '50%';
            recoveryFranceActivityMDFP.Core_MDF_Channel_Partner_Led__c = true;
            pfrList.add(recoveryFranceActivity);
            pfrList.add(recoveryFranceActivityMDFP);

            Database.insert(pfrList);

            List<PartnerFundClaim> pfcList = new List<PartnerFundClaim>();
            PartnerFundClaim recoveryClaim1 = Core_MDF_CCP_TestDataUtility.createClaim('France Claim', Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF, recoveryFranceActivity.Id, recoveryFranceActivity.Core_MDF_Start_Date__c, recoveryFranceActivity.Core_MDF_Start_Date__c, 300, System.today(), null, false);
            recoveryClaim1.Core_MDF_PIC_Review_Completed__c = true;
            recoveryClaim1.Core_MDF_BackendReviewSelection_Ind__c = false;
            recoveryClaim1.Amount = 300;
            recoveryClaim1.Core_MDF_Recovery_Hold_Ind__c = true;
            recoveryClaim1.Core_MDF_Currency__c = 'USD';
            pfcList.add(recoveryClaim1);

            PartnerFundClaim recoveryClaim2 = Core_MDF_CCP_TestDataUtility.createClaim('France Claim', Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF, recoveryFranceActivity.Id, recoveryFranceActivity.Core_MDF_Start_Date__c, recoveryFranceActivity.Core_MDF_Start_Date__c, 300, System.today(), null, false);
            recoveryClaim2.Core_MDF_PIC_Review_Completed__c = true;
            recoveryClaim2.Core_MDF_BackendReviewSelection_Ind__c = false;
            recoveryClaim2.Amount = 30;
            recoveryClaim2.Core_MDF_Currency__c = 'USD';
            pfcList.add(recoveryClaim2);

            PartnerFundClaim recoveryClaimMDFP = Core_MDF_CCP_TestDataUtility.createClaim('France Claim MDF+', Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF, recoveryFranceActivityMDFP.Id, recoveryFranceActivity.Core_MDF_Start_Date__c, recoveryFranceActivity.Core_MDF_Start_Date__c, 300, System.today(), null, false);
            recoveryClaimMDFP.Core_MDF_Document_Submission_Missed_Ind__c = true;
            recoveryClaimMDFP.Amount = 300;
            recoveryClaimMDFP.Core_MDF_Currency__c = 'USD';
            pfcList.add(recoveryClaimMDFP);
            Database.insert(pfcList);
            Test.stopTest();

            List<Core_MDF_Partnership_Score__c> PSList = new List<Core_MDF_Partnership_Score__c>();
            Core_MDF_Partnership_Score__c partnershipScore = new Core_MDF_Partnership_Score__c();
            partnershipScore.Core_MDF_Account_Id__c = recoveryIntelAcc.id;
            partnershipScore.Core_MDF_Program_nm__c = 'Client CoMarketing Fund';
            partnershipScore.Core_MDF_Quarter_Year_Nm__c = 'Q4 2023';
            partnershipScore.Core_MDF_Zone_nm__c = 'A3';
            partnershipScore.Core_MDF_Channel_Program_Id__c = ccfCP.Id;
            partnershipScore.Core_MDF_Quarter_nm__c = 'Q4';
            partnershipScore.Core_MDF_Year_nm__c = '2023';
            PSList.add(partnershipScore);
            insert PSList;

            List<Core_MDF_Partnership_Score_Detail__c> psdList = new List<Core_MDF_Partnership_Score_Detail__c>();
            Core_MDF_Partnership_Score_Detail__c psd1 = new Core_MDF_Partnership_Score_Detail__c();
            psd1.Core_MDF_Budget_Type_nm__c = 'MDF';
            psd1.Core_MDF_Region_Cd__c = 'APJ';
            psd1.Core_MDF_Partnership_Score_Id__c = partnershipScore.Id;
            psd1.Core_MDF_Recovered_Amt__c = 0.00;
            psdList.add(psd1);

            Core_MDF_Partnership_Score_Detail__c psd2 = new Core_MDF_Partnership_Score_Detail__c();
            psd2.Core_MDF_Budget_Type_nm__c = 'MDF';
            psd2.Core_MDF_Region_Cd__c = 'ASMO';
            psd2.Core_MDF_Partnership_Score_Id__c = partnershipScore.Id;
            psd2.Core_MDF_Recovered_Amt__c = 0.00;
            psdList.add(psd2);

            Core_MDF_Partnership_Score_Detail__c psd3 = new Core_MDF_Partnership_Score_Detail__c();
            psd3.Core_MDF_Budget_Type_nm__c = 'MDF+';
            psd3.Core_MDF_Region_Cd__c = 'APJ';
            psd3.Core_MDF_Partnership_Score_Id__c = partnershipScore.Id;
            psd3.Core_MDF_Recovered_Amt__c = 0.00;
            psdList.add(psd3);
            insert psdList;

            List<PartnerFundClaim> claimList = [SELECT Id, Core_MDF_Status__c, Core_MDF_Region_Cd__c FROM PartnerFundClaim];
            for (PartnerFundClaim claim : claimList) {
                claim.Core_MDF_Status__c = 'Payment Due';
            }
            Database.update(claimList);

            Core_MDF_Configuration__c con = new Core_MDF_Configuration__c();
            con.Name = 'Core_MDF_RecoveryClaimUpdateBatch_Size';
            con.Core_MDF_Value__c = '30';
            Database.insert(con);

            PartnerMarketingBudget pbm = Core_MDF_CCP_TestDataUtility.createBudget('Test Budget 2', Core_MDF_CCP_TestDataUtility.Budget_Record_Type, recoveryCCFVC.Id, ccfCP.Id, 200000, System.today(), System.today(), false);
            pbm.Core_MDF_Budget_Type_Txt__c = 'OEM CMP';
            insert pbm;

            PartnerFundAllocation pfaRecord = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('Test PFA', pbm, recoveryCCFVC, 30000, true);

            PartnerFundAllocation pfa = [SELECT Id, Amount FROM PartnerFundAllocation WHERE BudgetId = :pbm.Id AND Title = 'Test PFA' LIMIT 1];
            Campaign camp = Core_MDF_CCP_TestDataUtility.createCampaign('Test Camp 12', 'Gaming', 'Intel® Core™ i7 Processor', 'Yes', Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 'Client CoMarketing Fund', System.today(), System.today(), 20000, 'Always Connected PC', recoveryCCFVC.Id, 'Desktop', false);
            camp.Core_MDF_Opal_Budget_Type_Txt__c = 'OEM CMP';
            Database.insert(camp);

            string quarterYear = Core_MDF_ReverseAuditDecision.determineQuartYear(System.today());
            List<string> quarterYearSplit = quarterYear.split(' ');
            Core_MDF_Partnership_Score__c ps = new Core_MDF_Partnership_Score__c();
            ps.Core_MDF_Account_Id__c = recoveryIntelAcc.Id;
            ps.Core_MDF_Channel_Program_Id__c = ccfCP.Id;
            ps.Core_MDF_Program_nm__c = 'Client CoMarketing Fund';
            ps.Core_MDF_Quarter_nm__c = quarterYearSplit[0].trim();
            ps.Core_MDF_Year_nm__c = quarterYearSplit[1].trim();
            ps.Core_MDF_Quarter_Year_Nm__c = quarterYear;
            ps.Core_MDF_Virtual_Corp_Account_Id__c = recoveryCCFVC.Id;
            ps.Core_MDF_External_Id__c = '' + ccfCP.Id + recoveryCCFVC.Id + quarterYear;
            insert ps;

            Core_MDF_Partnership_Score_Detail__c psd = new Core_MDF_Partnership_Score_Detail__c();
            psd.Core_MDF_Budget_Type_nm__c = 'CCF 1.0';
            psd.Core_MDF_Carry_Over_Amt__c = 0;
            psd.Core_MDF_Region_Cd__c = 'APJ';
            psd.Core_MDF_Partnership_Score_Id__c = ps.Id;
            psd.Core_MDF_Recovered_Amt__c = 100.00;
            psd.Core_MDF_External_ID__c = '' + ccfCP.Id + recoveryCCFVC.Id + quarterYear + psd.Core_MDF_Budget_Type_nm__c + psd.Core_MDF_Region_Cd__c;
            insert psd;

            Campaign camp1 = Core_MDF_CCP_TestDataUtility.createCampaign('Test Camp 12', 'Gaming', 'Intel® Core™ i7 Processor', 'Yes', Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 'Client CoMarketing Fund', System.today(), System.today(), 20000, 'Always Connected PC', recoveryCCFVC.Id, 'Desktop', false);
            camp1.Core_MDF_Opal_Budget_Type_Txt__c = 'OEM CMP';
            Database.insert(camp1);

            PartnerFundRequest testPartnerFundRequestRecord = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(String.valueOf(camp1.Id), Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF, String.valueOf(recoveryCCFVC.Id), pfa, pbm, 'INDIA', 'Consumer', 'Desktop', 'Intel® Corporate Logo', 'Broadcast', 'Podcast', 'Draft', false);
            testPartnerFundRequestRecord.Title = 'indiaActivity';
            testPartnerFundRequestRecord.Core_MDF_Activity_Description__c = 'indiaActivity';
            testPartnerFundRequestRecord.Core_MDF_Start_Date__c = System.today();
            testPartnerFundRequestRecord.Core_MDF_End_Date__c = System.today();
            testPartnerFundRequestRecord.RequestedAmount = 10000;
            testPartnerFundRequestRecord.Core_MDF_Channel_Partner_Led__c = true;
            testPartnerFundRequestRecord.Amount = 10000;
            testPartnerFundRequestRecord.Core_MDF_Budget_Type_nm__c = 'CCF 1.0';
            testPartnerFundRequestRecord.Core_MDF_Reimbursement_Rate_txt__c = '60%';
            insert testPartnerFundRequestRecord;

            PartnerFundClaim clm1 = Core_MDF_CCP_TestDataUtility.createClaim('Test Claim1', Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, testPartnerFundRequestRecord.Id, System.today(), System.today(), 5000.00, System.today(), recoveryBank.Id, false);
            clm1.Core_MDF_Currency__c = 'USD';
            clm1.Status = Label.Core_MDF_Status_Submitted;
            clm1.Core_MDF_Status__c = Label.Core_MDF_Claim_Status_PIC_Pending;
            clm1.Core_MDF_Budget_Type_Options_Nm__c = 'OEM CMP';
            clm1.Core_MDF_Country_Location_nm__c = 'INDIA';
            clm1.Core_MDF_Region_Cd__c = 'APJ';
            Database.insert(clm1);

            Case cs = new Case();
            Id caseAuditRecType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Core_MDF_Audit_Closed').getRecordTypeId();
            cs.Status = 'Open';
            cs.recordTypeId = caseAuditRecType;
            cs.AccountId = recoveryCCFVC.Id;
            cs.Core_MDF_Claim_ID__c = clm1.Id;
            cs.Core_MDF_Claim_Lookup_Id__c = clm1.Id;
            cs.Core_MDF_Channel_Program_txt__c = Core_MDF_CCP_ConstantClass.CCF_PROGRAM;
            cs.Core_MDF_Budget_Type_nm__c = 'OEM CMP ';
            cs.Core_MDF_Country_Region__c = 'INDIA';
            insert cs;

            Core_MDF_Scorecard__c scoreCard = new Core_MDF_Scorecard__c();
            scoreCard.Core_MDF_Case_Id__c = cs.Id;
            scoreCard.Core_MDF_Attribution_Nbr__c = '2';
            scoreCard.Core_MDF_Attribution_PV_Ind__c = 'M';
            scoreCard.Core_MDF_Engagement_Nbr__c = '2';
            scoreCard.Core_MDF_Engagement_PV_Ind__c = 'M';
            scoreCard.Core_MDF_POP__c = '1';
            scoreCard.Core_MDF_POP_PV_Ind__c = 'M';
            scoreCard.Core_MDF_Manual_Recovery_Amount_USD_Amt__c = 0;
            insert scoreCard;

            Core_MDF_Recovery_Dashboard__c recDashboardRec = new Core_MDF_Recovery_Dashboard__c();
            recDashboardRec.Core_MDF_Scorecard_Id__c = scoreCard.Id;
            recDashboardRec.Core_MDF_Partnership_Score_Detail_Id__c = psd.Id;
            recDashboardRec.Core_MDF_Partnership_Score_Id__c = ps.Id;
            recDashboardRec.Core_MDF_Is_Active_Ind__c = true;
            insert recDashboardRec;
        }
    }
    
    @isTest static void testRecoveryBatch1() {
        Test.startTest(); 
        List<PartnerFundClaim> claimList = [SELECT Id, Core_MDF_Status__c, Core_MDF_Region_Cd__c FROM PartnerFundClaim LIMIT 5];
        List<Core_MDF_Partnership_Score_Detail__c> detailist = [SELECT Id, Core_MDF_Account_Id__c, Core_MDF_Partnership_Score_Id__r.Core_MDF_Program_nm__c, Core_MDF_Region_Cd__c, Core_MDF_Budget_Type_nm__c, Core_MDF_Quarter_Year_Nm__c, Core_MDF_Partnership_Score_Id__c, Core_MDF_Recovered_Amt__c
                                                                FROM Core_MDF_Partnership_Score_Detail__c WHERE Core_MDF_Partnership_Score_Id__r.Core_MDF_Channel_Program_Id__r.Core_MDF_Technical_Program_Name__c = 'Client CoMarketing Fund' AND Core_MDF_Budget_Type_nm__c = 'MDF' AND Core_MDF_Quarter_Year_Nm__c = 'Q1 2022' LIMIT 5];
        Core_MDF_Recovery_Batch obj = new Core_MDF_Recovery_Batch('Client CoMarketing Fund', 'MDF', 'Q4 2023');
        Id jobId = Database.executeBatch(obj);
        Test.stopTest();
        for (Core_MDF_Partnership_Score_Detail__c psd : detailist) {
            if (psd.Core_MDF_Region_Cd__c == 'ASMO') {
                System.assertEquals(0.00, psd.Core_MDF_Recovered_Amt__c);   
            } else if (psd.Core_MDF_Region_Cd__c == 'APJ') {
                System.assertEquals(0.00, psd.Core_MDF_Recovered_Amt__c);
            }
        }
    }
    
    @isTest static void testRecoveryBatch2() {
        Test.startTest();
        string programBudgetTypeQuarter = 'Client CoMarketing Fund;MDF;Q4 2023';
        List<Id> accountIds = new List<Id>();
        Account accountRecord = [SELECT Id FROM Account LIMIT 1];
        Account accountRecord2 = [SELECT Id FROM Account LIMIT 1];
        List<PartnerFundClaim> claim = [SELECT Id FROM PartnerFundClaim WHERE Core_MDF_Budget_Type_Options_Nm__c = 'MDF' LIMIT 2];
        PartnerFundClaim claim2 = [SELECT Id FROM PartnerFundClaim WHERE Core_MDF_Budget_Type_Options_Nm__c = 'MDF+' LIMIT 1];
        accountIds.add(accountRecord.Id);
        string acctList = accountRecord.Id + ',' + accountRecord2.Id;
        Core_MDF_Recovery_Request__c rr = new Core_MDF_Recovery_Request__c();
        rr.Core_MDF_Claim_Id__c = claim2.Id;
        rr.Core_MDF_Account_Id__c = accountRecord.Id;
        rr.Core_MDF_Recovery_Amount_Amt__c = 100;
        rr.Core_MDF_Program_Nm__c = 'Client CoMarketing Fund';
        rr.Core_MDF_Quarter_Year_Nm__c = 'Q4 2023';
        rr.Core_MDF_Active_Ind__c = true;
        rr.Core_MDF_Recovered_Budget_Nm__c = 'MDF+;APJ=100';
        rr.Core_MDF_Claim_External_ID__c = claim2.Id;
        
        Database.insert(rr);
        
        List<Core_MDF_Partnership_Score_Detail__c> detailist2 = [SELECT Id, Core_MDF_Account_Id__c, Core_MDF_Partnership_Score_Id__r.Core_MDF_Channel_Program_Id__r.Core_MDF_Technical_Program_Name__c, Core_MDF_Region_Cd__c, Core_MDF_Budget_Type_nm__c, Core_MDF_Quarter_Year_Nm__c, Core_MDF_Partnership_Score_Id__c, Core_MDF_Recovered_Amt__c
                                                                 FROM Core_MDF_Partnership_Score_Detail__c WHERE Core_MDF_Partnership_Score_Id__r.Core_MDF_Channel_Program_Id__r.Core_MDF_Technical_Program_Name__c = 'Client CoMarketing Fund' AND Core_MDF_Budget_Type_nm__c = 'MDF+' AND Core_MDF_Quarter_Year_Nm__c = 'Q1 2022'];
        Core_MDF_Recovery_Batch obj = new Core_MDF_Recovery_Batch('Client CoMarketing Fund', 'MDF+', 'Q4 2023');
        Id jobId = Database.executeBatch(obj);
        Core_MDF_Recovery_Batch obj2 = new Core_MDF_Recovery_Batch('Client CoMarketing Fund', 'MDF+', 'Q4 2023', acctList);
        
        Core_MDF_Recovery_Batch obj3 = new Core_MDF_Recovery_Batch('Client CoMarketing Fund', '', '', '', '', 'Payment Run', false, false);
        Id jobId2 = Database.executeBatch(obj3);
        System.assertNotEquals(jobId2, null);
    }
    
    @isTest static void testRecoveryBatchGenerateInstance() {
        Object obj = Core_MDF_Recovery_Batch.generateInstance('{"pgm":"","bgtType":"","qtrYr":"","accounts":""}', 'Core_MDF_Recovery_Batch(string pgm, string bgtType, string qtrYr, string accounts)');
        Core_MDF_Recovery_Batch.generateInstance('{"pgm":"","bgtTypes":"","qtrYr":"","accounts":"","regions":"","source":"","isRecReq_RecvryDone":false,"isPreSelClaim_RecvryDone":false}', 'Core_MDF_Recovery_Batch(string pgm, string bgtTypes, string qtrYr, string accounts, string regions, string source, boolean isRecReq_RecvryDone, boolean isPreSelClaim_RecvryDone)');
        Core_MDF_Recovery_Batch.generateInstance('{"pgm":"","bgtType":"","qtrYr":""}', 'Core_MDF_Recovery_Batch(string pgm, string bgtType, string qtrYr)');
        System.assertNotEquals(obj, null);
    }
}