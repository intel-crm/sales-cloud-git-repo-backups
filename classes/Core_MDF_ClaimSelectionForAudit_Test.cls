@isTest(SeeAllData=false)
public class Core_MDF_ClaimSelectionForAudit_Test {
   @TestSetUp
    static void createTestData(){
         UserRole adminRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.LastName = 'User Test';
        usr.UserRoleId = adminRole.Id;
        insert usr;
        
        System.runAs(usr){
            ChannelProgram retailCp = Core_MDF_CCP_TestDataUtility.createProgram ('Retail Marketing Funds','Retail Marketing Funds', true);
            Account intelAccount = Core_MDF_CCP_TestDataUtility.createIntelAccount('Flipkart', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
            intelAccount.Core_Geo__c = 'EMEA';
            database.insert(intelAccount);
            
            Account intelRetail = Core_MDF_CCP_TestDataUtility.createAccount ('Co-marketing Test Account', retailCp.Id,
                                                                              Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            intelRetail.Core_MDF_Parent_Fund_Account__c = intelAccount.Id;
            intelRetail.Core_MDF_CoMarketing_Ultimate_Account__c = intelAccount.Id;
            intelRetail.Core_Geo__c = 'EMEA';
            Database.insert(intelRetail);
            
            PartnerMarketingBudget pmb = Core_MDF_CCP_TestDataUtility.createBudget('Test Budget',Core_MDF_CCP_TestDataUtility.budget_Record_Type,
                                                                                   intelRetail.Id,retailCp.Id,500000000,System.today().addDays(-97),
                                                                                   System.today().addDays(5), 
                                                                                   true); 
            
            PartnerFundAllocation pfa = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('Test Allocation',pmb,intelRetail,1000000.0,true);
            
            Campaign camp = Core_MDF_CCP_TestDataUtility.createCampaign('TestRetailCamp','Gaming','Athena', 
                                                                         Core_MDF_CCP_TestDataUtility.campaign_RecordType_Retail, 'Retail Marketing Funds',
                                                                         System.today() - 97, System.today().addYears(1), 2000, 
                                                                         'Instore innovation', intelRetail.Id,'2-in-1', false);
            camp.Core_MDF_Budget_Type_txt__c ='RSA MD';
            database.insert(camp);
            
            
            
            List<PartnerFundRequest> pfrList = new List<PartnerFundRequest>();
            
            test.startTest();
            PartnerFundRequest currentQuarterPfr = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(camp.Id),
                                                                                           Core_MDF_CCP_TestDataUtility.partnerFund_RecordType_Retail,
                                                                                           string.valueof(intelRetail.id),NULL,NULL,
                                                                                           'AFGHANISTAN','Business','Workstation',
                                                                                           'EVO','Broadcast',
                                                                                           'Podcast','Draft',false);
            
            currentQuarterPfr.Title ='RSA MD Activity';
            currentQuarterPfr.Core_MDF_Activity_Description__c ='RSA MD Activity';
            currentQuarterPfr.Core_MDF_Budget_Type_txt__c ='RSA MD';
            currentQuarterPfr.Core_MDF_Start_Date__c = System.today();
            currentQuarterPfr.Core_MDF_End_Date__c  = System.today();
            currentQuarterPfr.RequestedAmount =100000000;
            currentQuarterPfr.Amount=10000000;
            currentQuarterPfr.Core_MDF_Country__c ='GERMANY';
            currentQuarterPfr.Core_MDF_Country_nm__c = 'GERMANY';
            currentQuarterPfr.Core_MDF_Fund_Request_Status__c = 'Planned';
            currentQuarterPfr.Core_MDF_Budget_Currency_cd__c ='USD'; 
            currentQuarterPfr.Core_MDF_Reimbursement_Rate_pct__c='100%';
            pfrList.add(currentQuarterPfr);
            
            PartnerFundRequest lastQuarterPfr = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(camp.Id),
                                                                                           Core_MDF_CCP_TestDataUtility.partnerFund_RecordType_Retail,
                                                                                           string.valueof(intelRetail.id),NULL,NULL,
                                                                                           'AFGHANISTAN','Business','Workstation',
                                                                                           'EVO','Broadcast',
                                                                                           'Podcast','Draft',false);
            
            lastQuarterPfr.Title ='RSA MD Activity';
            lastQuarterPfr.Core_MDF_Activity_Description__c ='RSA MD Activity';
            lastQuarterPfr.Core_MDF_Budget_Type_txt__c ='RSA MD';
            lastQuarterPfr.Core_MDF_Start_Date__c = System.today() - 96;
            lastQuarterPfr.Core_MDF_End_Date__c  = System.today() - 93;
            lastQuarterPfr.RequestedAmount =100000000;
            lastQuarterPfr.Amount=10000000;
            lastQuarterPfr.Core_MDF_Country__c ='GERMANY';
            lastQuarterPfr.Core_MDF_Country_nm__c = 'GERMANY';
            lastQuarterPfr.Core_MDF_Fund_Request_Status__c = 'Planned';
            lastQuarterPfr.Core_MDF_Budget_Currency_cd__c ='USD'; 
            lastQuarterPfr.Core_MDF_Reimbursement_Rate_pct__c='100%';
            pfrList.add(lastQuarterPfr);
            
            database.insert(pfrList);
            
            List<PartnerFundClaim> pfcList = new List<PartnerFundClaim>();
            
            for(Integer i = 0; i < 30; i++) {        
                PartnerFundClaim pfc  = new PartnerFundClaim();
                pfc.RecordTypeId = Core_MDF_CCP_TestDataUtility.claim_RecordType_Retail;                
                pfc.Title = 'Test Claim' + i;
                pfc.RequestId = currentQuarterPfr.Id;
                if(i==3){
                    pfc.Core_MDF_Total_Invoice_Amount_Local__c = 55000;
                }else{
                    pfc.Core_MDF_Total_Invoice_Amount_Local__c = 25000;
                }                                  
                pfc.Core_MDF_Status__c = 'Submitted';
                pfc.Description = 'Test PFC ';
                pfc.Core_MDF_Ad_Run_Start_Date__c = system.today();
                pfc.Core_MDF_Ad_Run_End_Date__c = system.today();
                pfc.Core_MDF_Currency__c = 'USD';
                pfc.Core_MDF_Country_Location_nm__c= 'GERMANY';

                pfcList.add(pfc);
            }  
            
            for(Integer i = 0; i < 20; i++) {        
                PartnerFundClaim pfc  = new PartnerFundClaim();
                pfc.RecordTypeId = Core_MDF_CCP_TestDataUtility.claim_RecordType_Retail;                
                pfc.Title = 'Test LQ Claim' + i;
                pfc.RequestId = LastQuarterPfr.Id;
                if(i==3){
                    pfc.Core_MDF_Total_Invoice_Amount_Local__c = 55000+(i*2);
                    pfc.Core_MDF_Audit_Type__c = 'Random';            
                    pfc.Core_MDF_FlaggedForAudit__c = TRUE;
                    pfc.Core_MDF_Status__c = 'Hold';
                    pfc.Core_MDF_Audit_Hold__c = TRUE;
                }else{
                    pfc.Core_MDF_Total_Invoice_Amount_Local__c = 25000;
                    pfc.Core_MDF_Status__c = 'Submitted';
                }                                                  
                pfc.Description = 'Test PFC ';
                pfc.Core_MDF_Ad_Run_Start_Date__c = system.today().addDays(-94);
                pfc.Core_MDF_Ad_Run_End_Date__c = system.today().addDays(-94);
                pfc.Core_MDF_Currency__c = 'USD';
                pfc.Core_MDF_Country_Location_nm__c= 'GERMANY';

                pfcList.add(pfc);
            }
            
            database.insert(pfcList);
            
            List<Case> caseList = new List<Case>();
            
            Case cs = new Case();
            Id caseAuditRecType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Core_MDF_Audit').getRecordTypeId();
            cs.Status = 'Open';
            cs.recordTypeId = caseAuditRecType;
            cs.AccountId = intelRetail.Id;
            caseList.add(cs);
            
            Case currentCase = new Case();
            currentCase.Status = 'Open';
            currentCase.recordTypeId = caseAuditRecType;
            currentCase.AccountId = intelRetail.Id;
            caseList.add(currentCase);
            
            Case currentCase1 = new Case();
            currentCase1.Status = 'Open';
            currentCase1.recordTypeId = caseAuditRecType;
            currentCase1.AccountId = intelRetail.Id;
            caseList.add(currentCase1);
            
            database.insert(caseList);
            
            List<PartnerFundClaim> pfcListForUpdate = new List<PartnerFundClaim>();
            
            for(PartnerFundClaim testClaim : [SELECT Id, Title, Core_MDF_Region_Cd__c, Amount, Core_MDF_Activity_Types__c, RequestId,
                                              Request.CreatedDate, Core_MDF_Claim_Review_Case__c, Core_MDF_Status__c,Core_MDF_Program__c
                                              FROM PartnerFundClaim WHERE Title LIKE 'Test LQ Claim%' LIMIT 2])
            {
                if(testClaim.Title == 'Test LQ Claim1'){
                    testClaim.Core_MDF_Claim_Review_Case__c = currentCase1.Id;
                }else{
                   testClaim.Core_MDF_Claim_Review_Case__c = cs.Id; 
                }
                testClaim.Core_MDF_Status__c = 'Hold';
                pfcListForUpdate.add(testClaim);
            }
            
            PartnerFundClaim currentTestClaim = [SELECT Id, Core_MDF_Region_Cd__c, Amount, Core_MDF_Activity_Types__c, RequestId,
                                                 Request.CreatedDate, Core_MDF_Claim_Review_Case__c, Core_MDF_Status__c,Core_MDF_Program__c
                                                 FROM PartnerFundClaim WHERE Title = 'Test Claim1'];
            currentTestClaim.Core_MDF_Claim_Review_Case__c = currentCase.Id;
            currentTestClaim.Core_MDF_Status__c = 'Hold';
            pfcListForUpdate.add(currentTestClaim);
            
            database.update(pfcListForUpdate);
            
            test.stopTest();
            Datetime createdate = Datetime.now().addDays(-93);
            Test.setCreatedDate(LastQuarterPfr.Id, createdate);
        }
        
    }
    
    @isTest
    static void executeBatch(){
        test.startTest();
        Core_MDF_ClaimSelectionForAudit_Batch auditBatch = new  Core_MDF_ClaimSelectionForAudit_Batch();
        Database.executeBatch(auditBatch);
        test.stopTest();
        
        List<AggregateResult> sumofPFCAmount = [SELECT RequestId, SUM(Amount) pfcAmt FROM PartnerFundClaim WHERE
                                                Title LIKE 'Test Claim%' AND Core_MDF_Claim_Review_Case__c != NULL Group BY RequestId];
        Decimal auditedAmt = (Decimal)sumofPFCAmount[0].get('pfcAmt');
        System.assert(auditedAmt >= 312000);
    }
    
}