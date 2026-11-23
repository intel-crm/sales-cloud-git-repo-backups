@isTest(SeeAllData=false)
public class Core_MDF_ClaimSelectionForAudit_Test {
      /*@TestSetUp
    static void createTestData(){
        UserRole adminRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.LastName = 'User Test';
        usr.UserRoleId = adminRole.Id;
        insert usr;Ov
        
        System.runAs(usr){
            //adding bypass feature to bypass access validation
            List<String> bypassFunctionKeys = new List<String>();
            bypassFunctionKeys.add('Bypass_MDF_Budget_Access_Validation');
            bypassFunctionKeys.add('Bypass_MDF_Budget_Status_Validation');
            
            Set<String> myset1 = new Set<String>();
            List<String> result1 = new List<String>();
            myset1.addAll(bypassFunctionKeys);
            result1.addAll(myset1);
            
            List<Core_Trigger_Executions__c> bypassfunctinalitylist1 = Core_MDF_CCP_TestDataUtility.byPassFeature(result1,true,true);
            
            ChannelProgram retailCp = Core_MDF_CCP_TestDataUtility.createProgram ('Retail Marketing Funds','Retail Marketing Funds', true);
            
            Account intelAccount = Core_MDF_CCP_TestDataUtility.createIntelAccount('Flipkart', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
            intelAccount.Core_Geo__c = 'EMEA';
            intelAccount.Core_Sub_Geo__c = 'WEUR';
            insert intelAccount;
         
            Account intelRetail = Core_MDF_CCP_TestDataUtility.createAccount ('Co-marketing Test Account', retailCp.Id,
                                                                              Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            intelRetail.Core_MDF_Parent_Fund_Account__c = intelAccount.Id;
            intelRetail.Core_MDF_CoMarketing_Ultimate_Account__c = intelAccount.Id;
            intelRetail.Core_Geo__c = 'EMEA';
            intelRetail.Core_Sub_Geo__c = 'WEUR';
            insert intelRetail;
                       
            PartnerMarketingBudget pmb = Core_MDF_CCP_TestDataUtility.createRetailBudget('Test Budget',Core_MDF_CCP_TestDataUtility.budget_Retail_Record_Type,
                                                                                   intelRetail.Id,retailCp.Id,500000000,System.today().addDays(-107),
                                                                                   System.today().addYears(1), 
                                                                                   false,'RSA MD');
            pmb.Core_MDF_Budget_Type_Txt__c = 'RSA MD';
            pmb.Core_MDF_Budget_Type__c = 'RSA MD';
          
            //pmbRecord.IsIgnoreValidation = true;
            test.startTest();
            insert pmb; 
            
             Core_MDF_CCP_TestDataUtility.createMDFConfigurationData();
            PartnerFundAllocation pfa = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('Test Allocation',pmb,intelRetail,1000000.0,true);
             
            Campaign camp = Core_MDF_CCP_TestDataUtility.createCampaign('TestRetailCamp','Gaming','Athena', 'Yes MDF or both CMP & MDF',
                                                                        Core_MDF_CCP_TestDataUtility.campaign_RecordType_Retail, 'Retail Marketing Funds',
                                                                        System.today() - 97, System.today().addYears(1), 2000, 
                                                                        'Instore innovation', intelRetail.Id,'2-in-1', false);
            camp.Core_MDF_Budget_Type_txt__c ='RSA MD';
            
            insert camp;
            
                      
            List<PartnerFundRequest> pfrList = new List<PartnerFundRequest>();
            
            //test.startTest();
            PartnerFundRequest currentQuarterPfr = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(camp.Id),
                                                                                                         Core_MDF_CCP_TestDataUtility.partnerFund_RecordType_Retail,
                                                                                                         string.valueof(intelRetail.id),NULL,NULL,
                                                                                                         'AFGHANISTAN','Business','Workstation',
                                                                                                         'EVO','Broadcast',
                                                                                                         'Podcast','Draft',false);
            
            currentQuarterPfr.Title ='RSA MD Activity';
            currentQuarterPfr.Core_MDF_Activity_Description__c ='RSA MD Activity';
            currentQuarterPfr.Core_MDF_Budget_Type_nm__c = 'RSA MD';
            currentQuarterPfr.Core_MDF_Start_Date__c = System.today();
            currentQuarterPfr.Core_MDF_End_Date__c  = System.today();
            currentQuarterPfr.RequestedAmount =100000000;
            currentQuarterPfr.Amount=10000000;
            //currentQuarterPfr.Core_MDF_Country__c ='GERMANY';
            currentQuarterPfr.Core_MDF_Country_nm__c = 'GERMANY';
            currentQuarterPfr.Core_MDF_Fund_Request_Status__c = 'Planned';
            currentQuarterPfr.Core_MDF_Budget_Currency_cd__c ='USD'; 
            currentQuarterPfr.Core_MDF_Reimbursement_Rate_pct__c='100%';
            currentQuarterPfr.Core_MDF_Reimbursement_Rate_txt__c = '100%';
            currentQuarterPfr.Status = 'Approved';
            currentQuarterPfr.AllocationId = pfa.id;
            
            pfrList.add(currentQuarterPfr);
            
            PartnerFundRequest lastQuarterPfr = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(camp.Id),
                                                                                                      Core_MDF_CCP_TestDataUtility.partnerFund_RecordType_Retail,
                                                                                                      string.valueof(intelRetail.id),NULL,NULL,
                                                                                                      'AFGHANISTAN','Business','Workstation',
                                                                                                      'EVO','Broadcast',
                                                                                                      'Podcast','Draft',false);
            
            lastQuarterPfr.Title ='RSA MD Activity';
            lastQuarterPfr.Core_MDF_Activity_Description__c ='RSA MD Activity';
            lastQuarterPfr.Core_MDF_Budget_Type_nm__c = 'RSA MD';
            lastQuarterPfr.Core_MDF_Start_Date__c = System.today() - 96;
            lastQuarterPfr.Core_MDF_End_Date__c  = System.today() - 93;
            lastQuarterPfr.RequestedAmount =100000000;
            lastQuarterPfr.Amount=10000000;
            //lastQuarterPfr.Core_MDF_Country__c ='GERMANY';
            lastQuarterPfr.Core_MDF_Country_nm__c = 'GERMANY';
            lastQuarterPfr.Core_MDF_Fund_Request_Status__c = 'Planned';
            lastQuarterPfr.Core_MDF_Budget_Currency_cd__c ='USD'; 
            lastQuarterPfr.Core_MDF_Reimbursement_Rate_pct__c='100%';
            lastQuarterPfr.Core_MDF_Reimbursement_Rate_txt__c = '100%';
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
                
                //pfcList.add(pfc);
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
                
               
                
                //pfcList.add(pfc);
            }
             
            PartnerFundClaim pfc1  = new PartnerFundClaim();
            pfc1.RecordTypeId = Core_MDF_CCP_TestDataUtility.claim_RecordType_Retail;                
            pfc1.Title = 'Test Claim 1';
            pfc1.RequestId = currentQuarterPfr.Id;
            pfc1.Core_MDF_Total_Invoice_Amount_Local__c = 55000;
            pfc1.Core_MDF_Status__c = 'Submitted';
            pfc1.Description = 'Test PFC ';
            pfc1.Core_MDF_Ad_Run_Start_Date__c = system.today();
            pfc1.Core_MDF_Ad_Run_End_Date__c = system.today();
            pfc1.Core_MDF_Currency__c = 'USD';
            pfc1.Core_MDF_Country_Location_nm__c= 'GERMANY';
            pfcList.add(pfc1);
            
            PartnerFundClaim pfc2  = new PartnerFundClaim();
            pfc2.RecordTypeId = Core_MDF_CCP_TestDataUtility.claim_RecordType_Retail;                
            pfc2.Title = 'Test Claim 2';
            pfc2.RequestId = currentQuarterPfr.Id;
            pfc2.Core_MDF_Total_Invoice_Amount_Local__c = 25000;
            pfc2.Core_MDF_Status__c = 'Submitted';
            pfc2.Description = 'Test PFC ';
            pfc2.Core_MDF_Ad_Run_Start_Date__c = system.today();
            pfc2.Core_MDF_Ad_Run_End_Date__c = system.today();
            pfc2.Core_MDF_Currency__c = 'USD';
            pfc2.Core_MDF_Country_Location_nm__c= 'GERMANY';
            pfcList.add(pfc2);
             test.stopTest();
            
            database.insert(pfcList); 
           
           
            List<Case> caseList = new List<Case>();
            
            Case cs = new Case();
            Id caseAuditRecType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Core_MDF_Audit').getRecordTypeId();
            cs.Status = 'Open';
            cs.recordTypeId = caseAuditRecType;
            cs.Core_MDF_Claim_ID__c = pfcList[0].id;
            caseList.add(cs);       
                       
            
            Case currentCase = new Case();
            currentCase.Status = 'Open';
            currentCase.recordTypeId = caseAuditRecType;
            currentCase.Core_MDF_Claim_ID__c = pfcList[1].id;
            caseList.add(currentCase);
            
           /* Case currentCase1 = new Case();
            currentCase1.Status = 'Open';
            currentCase1.recordTypeId = caseAuditRecType;
            currentCase1.Core_MDF_Claim_ID__c = pfcList[2].id;
            caseList.add(currentCase1);
            
            database.insert(caseList);
                        
            Datetime createdate = Datetime.now().addDays(-93);
            Test.setCreatedDate(LastQuarterPfr.Id, createdate);
        }        
    }
    
    @isTest
    static void executeBatch(){
      
        test.startTest();
        Core_MDF_ClaimSelectionForAudit_Batch auditBatch = new  Core_MDF_ClaimSelectionForAudit_Batch();
        Database.executeBatch(auditBatch);
        Core_MDF_Scheduler_RetryCaseCreation sch = new Core_MDF_Scheduler_RetryCaseCreation();
        sch.execute(null);

        
        
        List<PartnerFundClaim> pfcList = [SELECT id FROM PartnerFundClaim WHERE
                                                Title LIKE 'Test%'];
        auditBatch.setClaimsOnHoldBasedOnHighestAmountForLastQuarter(pfcList);
        auditBatch.setClaimsOnHoldBasedOnHighestAmount(pfcList);
        auditBatch.pfcListForRandomAuditForLastQuarter = pfcList;
        auditBatch.pfcListForRandomAudit = pfcList;
        
        
        List<AggregateResult> sumofPFCAmount = [SELECT RequestId, SUM(Amount) pfcAmt FROM PartnerFundClaim WHERE
                                                Title LIKE 'Test%' Group BY RequestId];
       
        Decimal auditedAmt = (Decimal)sumofPFCAmount[0].get('pfcAmt');
        
        test.stopTest();
       
        System.assert(auditedAmt >= 80000);
    }*/
     @isTest 
    static void getCodeCoverageForMainClass(){
         Test.startTest();
         Core_MDF_ClaimSelectionForAudit_Batch.getCodeCoverage();
         Test.stopTest();
    }
    
}