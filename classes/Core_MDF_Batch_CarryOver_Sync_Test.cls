@isTest
public class Core_MDF_Batch_CarryOver_Sync_Test {

    @TestSetup static void setUpData() {

        Core_MDF_CCP_TestDataUtility.byPassFeature(
            new List<String>{
                'Bypass_MDF_Budget_Access_Validation',
                'Bypass_MDF_Budget_Status_Validation',
                'checkAndSendClaimsForPIC',
                'duplicateClaimCheck',
                'Bypass_Duplicate_Budget_Check',
                'Bypass_GeoBased_Budget_Sharing',
                'Bypass_MDF_Budget_Access',
                'Bypass_ShareActivityWithUsers',
                'Bypass_Activity_ApprovalProcess',
                'Bypass_ShareActivityWithAccNodeGroup',
                'ShareActivityWithInternalUsers_Bypass',
                'Bypass_Bank_ABM_Sharing',
                'Bypass_ABM_Internal_Sharing',
                'Bypass_ABM_External_Sharing',
                'Bypass_ABM_NodeGroup_Sharing',
                'ByPass_BlockLegacyBudgetCreation'
            },
            true,
            true
        );
        ChannelProgram cp = Core_MDF_CCP_TestDataUtility.createProgram (Core_MDF_CCP_ConstantClass.CCF_PROGRAM,'Client CoMarketing Fund', true);
        
        Account acc1 = Core_MDF_CCP_TestDataUtility.createIntelAccount('Test Account 1', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
        acc1.Core_Geo__c = 'APJ';
        acc1.Core_Sub_Geo__c = 'SA';
        insert acc1;

        Account acc2 = Core_MDF_CCP_TestDataUtility.createAccount ('Test Account 2', cp.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
        acc2.Core_MDF_Parent_Fund_Account__c = acc1.Id;
        insert acc2;

        acc1.isPartner = true;
        acc2.isPartner = true;
        update new List<Account>{ acc1, acc2 };
        
        Core_MDF_CCP_TestDataUtility.createMDFConfigurationData();
        
        Profile systemAdminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator' limit 1];
        
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.profileId = systemAdminProfile.Id;
        usr.LastName = 'SysAdmUser';
        insert usr;
        
        
        PartnerMarketingBudget pbm;
        System.runAs(usr) {
            pbm = Core_MDF_CCP_TestDataUtility.createBudget('Test Budget 2', Core_MDF_CCP_TestDataUtility.Budget_Record_Type, acc2.Id, cp.Id, 200000, System.today(),System.today(), false);
            pbm.Core_MDF_Budget_Type_Txt__c = 'OEM CMP';
            insert pbm;
        }
        
        Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('Test PFA', pbm, acc2, 30000, true);
            
        PartnerFundAllocation pfa = [Select id, Amount from PartnerFundAllocation where BudgetId =: pbm.Id and Title='Test PFA' limit 1];
        Campaign camp = Core_MDF_CCP_TestDataUtility.createCampaign('Test Camp 12','Gaming','Intel® Core™ i7 Processor', 'Yes', Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 'Client CoMarketing Fund', System.today(), System.today(), 20000, 'Always Connected PC', acc2.Id,'Desktop', false);
        camp.Core_MDF_Opal_Budget_Type_Txt__c = 'OEM CMP';
        database.insert(camp);
        
        PartnerFundRequest testPartnerFundRequestRecord = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(String.valueof(camp.id),Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,String.valueof(acc2.Id),pfa,pbm,'INDIA','Consumer','Desktop','Intel® Corporate Logo','Broadcast (Pre-2025)','Podcast','Draft',false);
        testPartnerFundRequestRecord.Title = 'indiaActivity';
        testPartnerFundRequestRecord.Core_MDF_Activity_Description__c = 'indiaActivity';
        testPartnerFundRequestRecord.Core_MDF_Start_Date__c = System.today();
        testPartnerFundRequestRecord.Core_MDF_End_Date__c = System.today();
        testPartnerFundRequestRecord.RequestedAmount = 10000;
        testPartnerFundRequestRecord.Core_MDF_Channel_Partner_Led__c = True;
        testPartnerFundRequestRecord.Amount=10000;
        testPartnerFundRequestRecord.Core_MDF_Budget_Type_nm__c = 'OEM CMP';
        testPartnerFundRequestRecord.Core_MDF_Reimbursement_Rate_txt__c='60%';
        insert testPartnerFundRequestRecord;
        
        Core_MDF_Bank__c bank = Core_MDF_CCP_TestDataUtility.createBank(acc1.Id, 'Core_MDF_Client_CoMarketing_Fund', false,'1231231230');
        insert bank;
        List <PartnerFundClaim> claimList = new List <PartnerFundClaim>();
        PartnerFundClaim claim1 = Core_MDF_CCP_TestDataUtility.createClaim('Test Claim1', Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, testPartnerFundRequestRecord.Id, System.today(), System.today(), 5000.00, System.today(), bank.Id, false);
        claim1.Core_MDF_Currency__c = 'USD';
        claim1.Status = Label.Core_MDF_Status_Submitted;
        claim1.Core_MDF_Status__c = Label.Core_MDF_Claim_Status_PIC_Pending;
        claim1.Core_MDF_Budget_Type_Options_Nm__c = 'OEM CMP';
        claim1.Core_MDF_Country_Location_nm__c = 'INDIA';
        claim1.Core_MDF_Region_Cd__c = 'APJ';
        claimList.add(claim1);

        Test.startTest();
        database.insert(claimList);
        Test.stopTest();
            
        Case cs = new Case();
        Id caseAuditRecType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Core_MDF_Audit_Closed').getRecordTypeId();
        cs.Status = 'Open';
        cs.recordTypeId = caseAuditRecType;
        cs.AccountId = acc2.id;
        cs.Core_MDF_Claim_ID__c=claimList[0].Id;
        cs.Core_MDF_Claim_Lookup_Id__c = claimList[0].Id;
        cs.Core_MDF_Channel_Program_txt__c = Core_MDF_CCP_ConstantClass.CCF_PROGRAM;
        cs.Core_MDF_Budget_Type_nm__c = 'OEM CMP';
        cs.Core_MDF_Country_Region__c = 'INDIA';
        insert cs;
        
        string quarterYear = Core_MDF_ReverseAuditDecision.determineQuartYear(system.today());
        List<string> quarterYearSplit = quarterYear.split(' ');
        Core_MDF_Partnership_Score__c ps = new Core_MDF_Partnership_Score__c();
        ps.Core_MDF_Account_Id__c  = acc1.Id;
        ps.Core_MDF_Channel_Program_Id__c =cp.Id;
        ps.Core_MDF_Program_nm__c = 'Client CoMarketing Fund';
        ps.Core_MDF_Quarter_nm__c = quarterYearSplit[0].trim();
        ps.Core_MDF_Year_nm__c = quarterYearSplit[1].trim();
        ps.Core_MDF_Quarter_Year_Nm__c = quarterYear;
        ps.Core_MDF_Virtual_Corp_Account_Id__c = acc2.Id;
        ps.Core_MDF_External_Id__c = '' + cp.Id + acc2.Id + quarterYear;
        insert ps;
            
        Core_MDF_Partnership_Score_Detail__c psd = new Core_MDF_Partnership_Score_Detail__c();
        psd.Core_MDF_Budget_Type_nm__c = 'OEM CMP';
        psd.Core_MDF_Carry_Over_Amt__c = 0;
        psd.Core_MDF_Region_Cd__c = 'APJ';
        psd.Core_MDF_Partnership_Score_Id__c = ps.id;
        psd.Core_MDF_Recovered_Amt__c = 100.00;
        psd.Core_MDF_External_ID__c = '' + cp.Id + acc2.Id + quarterYear + psd.Core_MDF_Budget_Type_nm__c + psd.Core_MDF_Region_Cd__c;
        insert psd;
    }

    // @isTest
    // static void testGetPreviousQuarter() {
    //     System.assertEquals('Q4 2025', Core_MDF_Batch_CarryOver_Sync.getPreviousQuarter('Q1 2026'));
    //     System.assertEquals('Q1 2026', Core_MDF_Batch_CarryOver_Sync.getPreviousQuarter('Q2 2026'));
    // }

    @isTest
    static void testCarryOverSyncBatchUpdate() {
        Case caseRec = [SELECT Id, AccountId, Account.Core_MDF_Channel_Program__c, Account.Core_MDF_Parent_Fund_Account__c, Account.Core_MDF_CoMarketing_Ultimate_Account__c, Core_MDF_Channel_Program_txt__c, Core_MDF_Budget_Type_nm__c, Core_MDF_Claim_Lookup_Id__r.Core_MDF_Region_Cd__c
                            FROM Case WHERE Core_MDF_Budget_Type_nm__c = 'OEM CMP' LIMIT 1];

        Id ultimateAccountId = caseRec.Account.Core_MDF_Parent_Fund_Account__c;
        update new Account(Id = ultimateAccountId, Core_MDF_CoMarketingActive__c = true);
        update new Account(Id = caseRec.AccountId, Core_MDF_CoMarketing_Ultimate_Account__c = ultimateAccountId);
        update new Case(Id = caseRec.Id, Status = CCPConstantClass.CASE_OPEN_STATUS, Core_MDF_Status__c = CCPConstantClass.CASE_OPEN_STATUS);

        Case updatedCase = [SELECT Id, AccountId, Core_MDF_Earlier_Quarter_Closed_Dt__c, Core_MDF_Budget_Type_nm__c, Core_MDF_Claim_Lookup_Id__r.Core_MDF_Region_Cd__c FROM Case WHERE Id = :caseRec.Id LIMIT 1];

        Date targetDate = updatedCase.Core_MDF_Earlier_Quarter_Closed_Dt__c == null ? System.today() : Date.newInstance(updatedCase.Core_MDF_Earlier_Quarter_Closed_Dt__c.year(), updatedCase.Core_MDF_Earlier_Quarter_Closed_Dt__c.month(), updatedCase.Core_MDF_Earlier_Quarter_Closed_Dt__c.day());

        if (updatedCase.Core_MDF_Earlier_Quarter_Closed_Dt__c == null) {
            update new Case(
                Id = updatedCase.Id,
                Core_MDF_Earlier_Quarter_Closed_Dt__c = targetDate
            );
        }

        String targetQuarter = Core_MDF_ReverseAuditDecision.determineQuartYear(targetDate);
        String sourceQuarter = Core_MDF_Batch_CarryOver_Sync.getPreviousQuarter(targetQuarter);
        String region = String.valueOf(updatedCase.Core_MDF_Claim_Lookup_Id__r.Core_MDF_Region_Cd__c);
        List<String> sourceQuarterSplit = sourceQuarter.split(' ');
        List<String> targetQuarterSplit = targetQuarter.split(' ');

        Map<Id, Map<Id, Id>> intelToProgramToVirtual = Core_MDF_IAH_Partnership_Score.getVirtualCorpAccount('',  String.valueOf(ultimateAccountId));
        Id virtualCorpAccountId = intelToProgramToVirtual.containsKey(ultimateAccountId) && intelToProgramToVirtual.get(ultimateAccountId).containsKey(caseRec.Account.Core_MDF_Channel_Program__c) ? intelToProgramToVirtual.get(ultimateAccountId).get(caseRec.Account.Core_MDF_Channel_Program__c) : null;

        System.assertNotEquals(null, virtualCorpAccountId, 'Expected virtual corp account mapping for the case account.');

        List<Core_MDF_Partnership_Score__c> targetPsList = [SELECT Id, Core_MDF_Program_nm__c, Core_MDF_Channel_Program_Id__c, Core_MDF_Virtual_Corp_Account_Id__c, Core_MDF_Quarter_Year_Nm__c FROM Core_MDF_Partnership_Score__c 
                                                            WHERE Core_MDF_Channel_Program_Id__c = :caseRec.Account.Core_MDF_Channel_Program__c AND Core_MDF_Virtual_Corp_Account_Id__c = :virtualCorpAccountId AND Core_MDF_Quarter_Year_Nm__c = :targetQuarter LIMIT 1];

        Core_MDF_Partnership_Score__c targetPs = targetPsList.isEmpty() ? null : targetPsList[0];
        if (targetPs == null) {
            targetPs = new Core_MDF_Partnership_Score__c(
                Core_MDF_Account_Id__c = ultimateAccountId,
                Core_MDF_Channel_Program_Id__c = caseRec.Account.Core_MDF_Channel_Program__c,
                Core_MDF_Program_nm__c = caseRec.Core_MDF_Channel_Program_txt__c,
                Core_MDF_Quarter_nm__c = targetQuarterSplit[0].trim(),
                Core_MDF_Year_nm__c = targetQuarterSplit[1].trim(),
                Core_MDF_Quarter_Year_Nm__c = targetQuarter,
                Core_MDF_Virtual_Corp_Account_Id__c = virtualCorpAccountId,
                Core_MDF_External_Id__c = String.valueOf(caseRec.Account.Core_MDF_Channel_Program__c) + String.valueOf(virtualCorpAccountId) + targetQuarter
            );
            insert targetPs;
        }

        String targetExternalId = String.valueOf(caseRec.Account.Core_MDF_Channel_Program__c) + String.valueOf(virtualCorpAccountId) + String.valueOf(targetQuarter) + String.valueOf(updatedCase.Core_MDF_Budget_Type_nm__c) + region;
        List<Core_MDF_Partnership_Score_Detail__c> targetPsdList = [SELECT Id, Core_MDF_Carry_Over_Amt__c FROM Core_MDF_Partnership_Score_Detail__c WHERE Core_MDF_External_Id__c = :targetExternalId LIMIT 1];

        if (targetPsdList.isEmpty()) {
            insert new Core_MDF_Partnership_Score_Detail__c(
                Core_MDF_Partnership_Score_Id__c = targetPs.Id,
                Core_MDF_External_Id__c = targetExternalId,
                Core_MDF_Budget_Type_Nm__c = updatedCase.Core_MDF_Budget_Type_nm__c,
                Core_MDF_Region_Cd__c = region,
                Core_MDF_Carry_Over_Amt__c = 0
            );
        }

        Core_MDF_Partnership_Score__c sourcePs = new Core_MDF_Partnership_Score__c(
            Core_MDF_Account_Id__c = ultimateAccountId,
            Core_MDF_Channel_Program_Id__c = caseRec.Account.Core_MDF_Channel_Program__c,
            Core_MDF_Program_nm__c = targetPs.Core_MDF_Program_nm__c,
            Core_MDF_Quarter_nm__c = sourceQuarterSplit[0].trim(),
            Core_MDF_Year_nm__c = sourceQuarterSplit[1].trim(),
            Core_MDF_Quarter_Year_Nm__c = sourceQuarter,
            Core_MDF_Virtual_Corp_Account_Id__c = virtualCorpAccountId,
            Core_MDF_External_Id__c = String.valueOf(caseRec.Account.Core_MDF_Channel_Program__c) + String.valueOf(virtualCorpAccountId) + sourceQuarter
        );
        insert sourcePs;

        String sourceExternalId = String.valueOf(caseRec.Account.Core_MDF_Channel_Program__c) + String.valueOf(virtualCorpAccountId) + String.valueOf(sourceQuarter) + String.valueOf(updatedCase.Core_MDF_Budget_Type_nm__c) + region;
        insert new Core_MDF_Partnership_Score_Detail__c(
            Core_MDF_Partnership_Score_Id__c = sourcePs.Id,
            Core_MDF_External_Id__c = sourceExternalId,
            Core_MDF_Budget_Type_Nm__c = updatedCase.Core_MDF_Budget_Type_nm__c,
            Core_MDF_Region_Cd__c = region,
            Core_MDF_Carry_Over_Amt__c = 100,
            Core_MDF_Recovered_Amt__c = 0,
            Core_MDF_Recovery_Offset_Amt__c = 0
        );

        Test.startTest();
        Database.executeBatch(new Core_MDF_Batch_CarryOver_Sync(), 200);
        Test.stopTest();

        Core_MDF_Partnership_Score_Detail__c targetPsd = [SELECT Id, Core_MDF_Carry_Over_Amt__c FROM Core_MDF_Partnership_Score_Detail__c WHERE Core_MDF_External_Id__c = :targetExternalId LIMIT 1];

        System.assertEquals(100, targetPsd.Core_MDF_Carry_Over_Amt__c);
    }

    @isTest
    static void testCarryOverSyncBatchInsert() {
        Case caseRec = [SELECT Id, AccountId, Account.Core_MDF_Channel_Program__c, Account.Core_MDF_Parent_Fund_Account__c, Core_MDF_Channel_Program_txt__c, Core_MDF_Claim_Lookup_Id__r.Core_MDF_Region_Cd__c FROM Case LIMIT 1];

        update new Account(Id = caseRec.AccountId, Core_MDF_CoMarketing_Ultimate_Account__c = caseRec.Account.Core_MDF_Parent_Fund_Account__c);
        update new Account(Id = caseRec.Account.Core_MDF_Parent_Fund_Account__c, Core_MDF_CoMarketingActive__c = true);
        update new Case(Id = caseRec.Id, Status = CCPConstantClass.CASE_OPEN_STATUS, Core_MDF_Status__c = CCPConstantClass.CASE_OPEN_STATUS, Core_MDF_Budget_Type_nm__c = 'OEM CMP');

        Case updatedCase = [SELECT Id, Core_MDF_Earlier_Quarter_Closed_Dt__c, Core_MDF_Budget_Type_nm__c, Core_MDF_Claim_Lookup_Id__r.Core_MDF_Region_Cd__c FROM Case WHERE Id = :caseRec.Id LIMIT 1];
        Date targetDate = updatedCase.Core_MDF_Earlier_Quarter_Closed_Dt__c == null ? System.today() : Date.newInstance(updatedCase.Core_MDF_Earlier_Quarter_Closed_Dt__c.year(), updatedCase.Core_MDF_Earlier_Quarter_Closed_Dt__c.month(), updatedCase.Core_MDF_Earlier_Quarter_Closed_Dt__c.day());
        if (updatedCase.Core_MDF_Earlier_Quarter_Closed_Dt__c == null) {
            update new Case(Id = updatedCase.Id, Core_MDF_Earlier_Quarter_Closed_Dt__c = targetDate);
        }

        String targetQuarter = Core_MDF_ReverseAuditDecision.determineQuartYear(targetDate);
        String sourceQuarter = Core_MDF_Batch_CarryOver_Sync.getPreviousQuarter(targetQuarter);
        List<String> sourceQuarterSplit = sourceQuarter.split(' ');
        String region = updatedCase.Core_MDF_Claim_Lookup_Id__r.Core_MDF_Region_Cd__c;
        String targetExternalId = String.valueOf(caseRec.Account.Core_MDF_Channel_Program__c) + String.valueOf(caseRec.AccountId) + targetQuarter + 'OEM CMP' + region;

        insert new Core_MDF_Partnership_Score__c(
            Core_MDF_Account_Id__c = caseRec.Account.Core_MDF_Parent_Fund_Account__c,
            Core_MDF_Channel_Program_Id__c = caseRec.Account.Core_MDF_Channel_Program__c,
            Core_MDF_Program_nm__c = caseRec.Core_MDF_Channel_Program_txt__c,
            Core_MDF_Quarter_nm__c = sourceQuarterSplit[0].trim(),
            Core_MDF_Year_nm__c = sourceQuarterSplit[1].trim(),
            Core_MDF_Quarter_Year_Nm__c = sourceQuarter,
            Core_MDF_Virtual_Corp_Account_Id__c = caseRec.AccountId,
            Core_MDF_External_Id__c = String.valueOf(caseRec.Account.Core_MDF_Channel_Program__c) + String.valueOf(caseRec.AccountId) + sourceQuarter
        );

        insert new Core_MDF_Partnership_Score_Detail__c(
            Core_MDF_Partnership_Score_Id__c = [SELECT Id FROM Core_MDF_Partnership_Score__c WHERE Core_MDF_Channel_Program_Id__c = :caseRec.Account.Core_MDF_Channel_Program__c AND Core_MDF_Virtual_Corp_Account_Id__c = :caseRec.AccountId AND Core_MDF_Quarter_Year_Nm__c = :sourceQuarter LIMIT 1].Id,
            Core_MDF_External_Id__c = String.valueOf(caseRec.Account.Core_MDF_Channel_Program__c) + String.valueOf(caseRec.AccountId) + sourceQuarter + 'OEM CMP' + region,
            Core_MDF_Budget_Type_Nm__c = 'OEM CMP',
            Core_MDF_Region_Cd__c = region,
            Core_MDF_Carry_Over_Amt__c = 55,
            Core_MDF_Recovered_Amt__c = 0,
            Core_MDF_Recovery_Offset_Amt__c = 0
        );

        Test.startTest();
        Database.executeBatch(new Core_MDF_Batch_CarryOver_Sync(), 200);
        Test.stopTest();
    }
}