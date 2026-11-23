/****************************************************************************************************************************************
* Class Name  : Core_MDF_AuditSelectionHelper_Test 
* Version     : 1.0 
* Created Date: 8-23-2018
* Modification Log :
* Developer                     Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture - Harika P        10/23/2018                    Created to test Random Audit Selection. 
* NP(11630236)                05-03-2020                    Added ABM
*****************************************************************************************************************************************/
@isTest(SeeAllData=false)
private class Core_MDF_AuditSelectionHelper_Test{
/****************************************************************************************************************************************
Method Name:                                   setUpData
Description:                                   Created setUpData() to prepare data for testing 
Added By:                                      Accenture – Harika P  -  10/23/2018
Modified By:                  Date:            Changes: 
Accenture – Harika P        10/23/2018         Created.
*****************************************************************************************************************************************/
    
    @TestSetup static void setUpData(){
        
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        //Creating User with utility class 
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.LastName = 'User Test';
        usr.UserRoleId = usRole.Id;
        Database.insert(usr);
        
        User usr1;
        List<PartnerFundClaim> newClmList = new List<PartnerFundClaim>();
        
        System.runAs(usr){
            
            //Create Exchnage rates records
            List<Core_MDF_Currency_Exchange_Rates__c> newValues = new List<Core_MDF_Currency_Exchange_Rates__c>();            
            Core_MDF_Currency_Exchange_Rates__c record1 = new Core_MDF_Currency_Exchange_Rates__c();
            record1.Name= 'ZMK';
            record1.Core_MDF_Exchange_Rate__c = 0.0000850159;
            record1.Core_MDF_Market_Date__c =System.today()-2;
            record1.Core_MDF_Intel_WW__c = 'WW 46';
            newValues.add(record1);
            
            Core_MDF_Currency_Exchange_Rates__c record2 = new Core_MDF_Currency_Exchange_Rates__c();
            record2.Name= 'INR';
            record2.Core_MDF_Exchange_Rate__c = 1;
            record2.Core_MDF_Market_Date__c =System.today()-2;
            record2.Core_MDF_Intel_WW__c = 'WW 46';
            newValues.add(record2); 
            
            Core_MDF_Currency_Exchange_Rates__c record3 = new Core_MDF_Currency_Exchange_Rates__c();
            record3.Name= 'USD';
            record3.Core_MDF_Exchange_Rate__c = 1;
            record3.Core_MDF_Market_Date__c =System.today()-2;
            record3.Core_MDF_Intel_WW__c = 'WW 46';
            newValues.add(record3); 
            
            Core_MDF_CCP_Multicurrency.getExchangeRateAndAmount aObj = new Core_MDF_CCP_Multicurrency.getExchangeRateAndAmount();
            Core_MDF_CCP_Multicurrency.getExchangeRateAndAmount bObj = new Core_MDF_CCP_Multicurrency.getExchangeRateAndAmount();
            Core_MDF_CCP_Multicurrency.getExchangeRateAndAmount cObj = new Core_MDF_CCP_Multicurrency.getExchangeRateAndAmount();
            List<Core_MDF_CCP_Multicurrency.getExchangeRateAndAmount> listvar = new List<Core_MDF_CCP_Multicurrency.getExchangeRateAndAmount>();
            
            aObj.inputCurrency ='ZMK';
            aObj.inputAmount = 250.00;
            aObj.inputDate= date.newInstance(2018, 11, 13);
            bObj.inputCurrency ='INR';
            bObj.inputAmount = 350.00;
            bObj.inputDate= date.newInstance(2018, 11, 12);
            cObj.inputCurrency ='USD';
            cObj.inputAmount = 350.00;
            cObj.inputDate= date.newInstance(2018, 11, 12);
            listvar.add(aObj);
            listvar.add(bObj);
            listvar.add(cObj);
            Core_MDF_CCP_Multicurrency.getUSDExchangeRateBasedOnDate(listvar);
            
            database.insert(newValues);                     
            
            // Creating channel program with utility class
            List<ChannelProgram> channelProgramList = new List<ChannelProgram>();
            ChannelProgram cp = Core_MDF_CCP_TestDataUtility.createProgram ('Client Co-Marketing Fund','Client CoMarketing Fund', false);
            ChannelProgram retailCp = Core_MDF_CCP_TestDataUtility.createProgram ('Retail Marketing Funds','Retail Marketing Funds', false);
            channelProgramList.add(cp);
            channelProgramList.add(retailCp);
            Database.insert(channelProgramList);
            
            // Creating IntelAccount with utility class
            Account acc1 = Core_MDF_CCP_TestDataUtility.createIntelAccount ('Test Account 1', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, 
                                                                            false);
            acc1.Core_MDF_CoMarketingAgency__c = TRUE;
            acc1.Core_Geo__c = 'EMEA';
            Database.insert(acc1);
            
            // Creating Co-marketing Account with utility class
            List<Account> listOfAccounts = new List<Account>();
            Account acc = Core_MDF_CCP_TestDataUtility.createAccount ('Co-marketing Test Account', cp.Id,
                                                                      Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            acc.Core_MDF_Parent_Fund_Account__c = acc1.Id;
            listOfAccounts.add(acc);
            Account intelRetail = Core_MDF_CCP_TestDataUtility.createAccount ('Co-marketing Test Account', retailCp.Id,
                                                                              Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            intelRetail.Core_MDF_Parent_Fund_Account__c = acc1.Id;
            intelRetail.Core_MDF_CoMarketing_Ultimate_Account__c = acc1.Id;
            intelRetail.Core_Geo__c = 'EMEA';
            listOfAccounts.add(intelRetail);
            
            Database.insert(listOfAccounts);
                        
            // Creating Contact with utility class
            Contact con = Core_MDF_CCP_TestDataUtility.createContact (acc1.Id, false);
            con.RecordTypeId = Core_MDF_CCP_TestDataUtility.Intel_Contact_Record_Type;
            Database.insert(con);
            
            Profile partnerProfile = [SELECT Id FROM Profile WHERE Name='Partner' LIMIT 1];
            
            // Creating User with utility class 
            usr1 = Core_MDF_CCP_TestDataUtility.createUser(false);
            usr1.LastName = 'User Test1';
            usr1.ProfileId = partnerProfile.Id;
            usr1.ContactId = con.Id;
            Database.insert(usr1);
            
            // Creating campaigns using utility class
            List<Campaign> listOfCampaign = new List<Campaign>();
            
            Campaign camp = Core_MDF_CCP_TestDataUtility.createCampaign('TestCamp','Consumer','Intel® Corporate Logo', 
                                                                        Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF,
                                                                        'Client CoMarketing Fund',System.today(),
                                                                        System.today().addDays(200), 2000, 'Unite',acc.Id,'2-in-1', false);
                                                                        
            Campaign camp1 = Core_MDF_CCP_TestDataUtility.createCampaign('TestRetailCamp','Gaming','Athena', 
                                                                        Core_MDF_CCP_TestDataUtility.campaign_RecordType_Retail, 'Retail Marketing Funds',
                                                                        System.today() - 45, System.today().addYears(1), 2000, 
                                                                        'Instore innovation', intelRetail.Id,'2-in-1', false);
            camp1.Core_MDF_Budget_Type_txt__c ='RSA MD';
            listOfCampaign.add(camp);
            listOfCampaign.add(camp1);
            database.insert(listOfCampaign);
            
            List<PartnerMarketingBudget> listOfBudget = new List<PartnerMarketingBudget>();
            PartnerMarketingBudget pmb = Core_MDF_CCP_TestDataUtility.createBudget('Test Budget',Core_MDF_CCP_TestDataUtility.budget_Record_Type,
                                                                                   acc.Id,cp.Id,5000000,System.today(),System.today().addDays(110), 
                                                                                   false);
            listOfBudget.add(pmb);                                                                     
                                                                                        
                                                                                   
            PartnerMarketingBudget pmb1 = Core_MDF_CCP_TestDataUtility.createRetailBudget('Retail TestBudget',
                                                                                          Core_MDF_CCP_TestDataUtility.budget_Record_Type,
                                                                                          intelRetail.Id,retailCp.Id,500000000,
                                                                                          System.today().addDays(-5),System.today().addDays(5), 
                                                                                          false,'RSA MD');                                                                      
            listOfBudget.add(pmb1); 
            Database.insert(listOfBudget);
            
            // Creating Allocation using utility class
            List<PartnerFundAllocation> pfaList = new List<PartnerFundAllocation>();
            PartnerFundAllocation pfa = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('Test Allocation',pmb,acc,1000000.0,false);
            PartnerFundAllocation pfa1 = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('Test Allocation',pmb,intelRetail,1000000.0,false);
            pfaList.add(pfa);
            pfaList.add(pfa1);
            Database.insert(pfaList);
            
            Test.startTest();
            
            List<PartnerFundRequest> pfrList = new List<PartnerFundRequest>();
            // Creating activities using utility class
            PartnerFundRequest pfr = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(camp.Id),
                                                                                           Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,
                                                                                           string.valueof(acc.id),pfa,pmb,'INDIA','Small Business',
                                                                                           'Desktop','Intel® Core™ i7 Processor','Broadcast',
                                                                                           'Radio','Draft',false);
            pfr.RequestedAmount = 900000;
            pfr.Amount = 900000;
            pfr.Status = 'Approved';
            pfr.AllocationId = pfa.Id;
            pfr.BudgetId = pmb.Id;
            pfr.Core_MDF_Start_Date__c = system.today();
            pfr.Core_MDF_End_Date__c = system.today();
            pfrList.add(pfr);
            
            
            
            PartnerFundRequest currentQuarterPfr = Core_MDF_CCP_TestDataUtility.createRetailActivity(string.valueof(camp1.Id),                                                                                                         
                                                                                                         string.valueof(intelRetail.id),NULL,NULL,
                                                                                                         false);
            
            currentQuarterPfr.Title ='RSA MD Activity';
            currentQuarterPfr.Core_MDF_Activity_Description__c ='RSA MD Activity';
            currentQuarterPfr.Core_MDF_Budget_Type_txt__c ='RSA MD';
            currentQuarterPfr.Core_MDF_Start_Date__c = System.today() - 5;
            currentQuarterPfr.Core_MDF_End_Date__c  = System.today() + 5;
            currentQuarterPfr.RequestedAmount =100000000;
            currentQuarterPfr.Amount=10000000;
            currentQuarterPfr.Core_MDF_Country__c ='GERMANY';
            currentQuarterPfr.Core_MDF_Country_nm__c = 'GERMANY';
            currentQuarterPfr.Core_MDF_Fund_Request_Status__c = 'Planned';
            currentQuarterPfr.Core_MDF_Budget_Currency_cd__c ='USD'; 
            currentQuarterPfr.Core_MDF_Reimbursement_Rate_pct__c='100%';
            pfrList.add(currentQuarterPfr);
            
            PartnerFundRequest asmoPfr = Core_MDF_CCP_TestDataUtility.createRetailActivity(string.valueof(camp1.Id),                                                                                                         
                                                                                                         string.valueof(intelRetail.id),NULL,NULL,
                                                                                                         false);
            
            asmoPfr.Title ='RSA MD ASMO Activity';
            asmoPfr.Core_MDF_Activity_Description__c ='RSA MD ASMO Activity';
            asmoPfr.Core_MDF_Budget_Type_txt__c ='RSA MD';
            asmoPfr.Core_MDF_Start_Date__c = System.today() - 5;
            asmoPfr.Core_MDF_End_Date__c  = System.today() + 5;
            asmoPfr.RequestedAmount =40000;
            asmoPfr.Amount=1000;
            asmoPfr.Core_MDF_Country__c ='United States';
            asmoPfr.Core_MDF_Country_nm__c = 'United States';
            asmoPfr.Core_MDF_Fund_Request_Status__c = 'Planned';
            asmoPfr.Core_MDF_Budget_Currency_cd__c ='USD'; 
            asmoPfr.Core_MDF_Reimbursement_Rate_pct__c='100%';
            pfrList.add(asmoPfr);
            database.insert(pfrList);
            
            // Creating Bank
            Core_MDF_Bank__c bank = Core_MDF_CCP_TestDataUtility.createBank(acc1.id,'Core_MDF_Client_CoMarketing_Fund',true,'1234567890');
                        
            PartnerFundRequestShare pfrShare = new PartnerFundRequestShare();
            pfrShare.ParentId = pfr.Id;
            pfrShare.UserOrGroupId = usr1.id;
            pfrShare.AccessLevel = 'Edit';
            Database.insert(pfrShare);  

            Core_MDF_Bank__Share bankShare  = new Core_MDF_Bank__Share();
            bankShare.ParentId = bank.Id;
            bankShare.UserOrGroupId = usr1.id;
            bankShare.AccessLevel = 'Edit'; 
            Database.insert(bankShare);
            
            Core_MDF_Account_Bank_Mapping__c abmCCF1 = Core_MDF_CCP_TestDataUtility.createAccountBankMap(acc.id, bank.Id, TRUE);
                                      
            // Creating claims
            for(Integer i = 0; i < 11; i++) {        
                PartnerFundClaim pfc  = new PartnerFundClaim();
                pfc.RecordTypeId = Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF;
                pfc.Title = 'Test Claim' + i;
                pfc.RequestId = pfr.Id;
                if(i>=3 && i<=8){
                    pfc.Core_MDF_Total_Invoice_Amount_Local__c = 20000;
                }
                if(i<3){
                    pfc.Core_MDF_Total_Invoice_Amount_Local__c = 400;
                }
                
                if(i==9){
                    pfc.Core_MDF_Total_Invoice_Amount_Local__c = 200000;
                }
                if(i==10){
                    pfc.Core_MDF_Total_Invoice_Amount_Local__c = 20000;
                    pfc.Core_MDF_IsClaimReviewEscalation_Ind__c = true;
                }                    
                pfc.Core_MDF_Status__c = 'Submitted';
                pfc.Description = 'Test PFC ';
                pfc.Core_MDF_Ad_Run_Start_Date__c = system.today();
                pfc.Core_MDF_Ad_Run_End_Date__c = system.today();
                pfc.Core_MDF_Invoice_Date__c = System.today();
                pfc.Core_MDF_Invoice_Number__c = '1121';
                pfc.Core_MDF_Media_Vehicle__c = 'test';
                pfc.Core_MDF_OtherCostsnotReimbursable_Local__c = 0;
                pfc.Core_MDF_Taxes_Local__c = 0;
                pfc.Core_MDF_Currency__c = 'USD';
                pfc.Core_MDF_Exchange_rate__c = 1;
                pfc.Core_MDF_Bank__c = bank.Id;
                pfc.amount = 25000;
                pfc.Core_MDF_Country_Location_nm__c= 'BRAZIL';
                newClmList.add(pfc);
            }
               // Creating claims
            for(Integer i = 0; i < 11; i++) {        
                PartnerFundClaim pfc1  = new PartnerFundClaim();
                pfc1.RecordTypeId = Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF;
                pfc1.Title = 'Testing Claim' + i;
                pfc1.RequestId = pfr.Id;
                if(i>=3 && i<=8){
                    pfc1.Core_MDF_Total_Invoice_Amount_Local__c = 3000;
                }
                if(i<3){
                    pfc1.Core_MDF_Total_Invoice_Amount_Local__c = 400;
                }
                
                if(i==9){
                    pfc1.Core_MDF_Total_Invoice_Amount_Local__c = 3000;
                }
                if(i==10){
                    pfc1.Core_MDF_Total_Invoice_Amount_Local__c = 3000;
                    pfc1.Core_MDF_IsClaimReviewEscalation_Ind__c = false;
                }                    
                pfc1.Description = 'Test PFC ';
                pfc1.Core_MDF_Ad_Run_Start_Date__c = system.today();
                pfc1.Core_MDF_Ad_Run_End_Date__c = system.today();
                pfc1.Core_MDF_Invoice_Date__c = System.today();
                pfc1.Core_MDF_Invoice_Number__c = '1121';
                pfc1.Core_MDF_Media_Vehicle__c = 'test';
                pfc1.Core_MDF_OtherCostsnotReimbursable_Local__c = 0;
                pfc1.Core_MDF_Taxes_Local__c = 0;
                pfc1.Core_MDF_Currency__c = 'USD';
                pfc1.Core_MDF_Exchange_rate__c = 1;
                pfc1.Core_MDF_Bank__c = bank.Id;
                pfc1.amount = 10000;
                pfc1.Core_MDF_Country_Location_nm__c= 'BRAZIL';
                pfc1.Core_MDF_FlaggedForAudit__c =false;
                pfc1.Core_MDF_Audit_Hold__c = false;
                pfc1.Core_MDF_Status__c ='Submitted';
                newClmList.add(pfc1);
            }   
            
             
            
            PartnerFundClaim pfc2 = Core_MDF_CCP_TestDataUtility.createClaim('India Claim New', Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF, 
                                                                               pfr.Id, 
                                                                               pfr.Core_MDF_Start_Date__c, pfr.Core_MDF_Start_Date__c, 
                                                                               3000, 
                                                                               pfr.Core_MDF_Start_Date__c, bank.ID, false);
            pfc2.Core_MDF_Currency__c = 'USD';
            pfc2.Core_MDF_Taxes_Local__c = 0;            
            newClmList.add(pfc2);
            
            
            List<PartnerFundRequest> partnerFndActivityNumber = [select Core_MDF_Activity_Number__c from PartnerFundRequest where id=:pfr.id limit 1];
                         
            Id claimRecType = Schema.SObjectType.Core_MDF_Escalation__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_Late_Claim').getRecordTypeId();
            Core_MDF_Escalation__c esc1 = new Core_MDF_Escalation__c();
            esc1.Core_MDF_Escalation_Status_nm__c='Pending Review';
            esc1.Core_MDF_Escalation_Name_txt__c='Test1';
            esc1.Core_MDF_Total_Dollar_Impact_amt__c= 56;
            esc1.Core_MDF_Root_Cause_nm__c = 'Tools and Systems';
            esc1.Core_MDF_Co_Marketing_Activity_id__c = partnerFndActivityNumber[0].Id;
            esc1.Core_MDF_Channel_Program_id__c = cp.Id;
            esc1.recordtypeid= claimRecType;
            Database.insert(esc1);   
            
            //Database.insert(newClmList); 
        }
        
        System.runAs(usr1){
            Database.insert(newClmList); 
        } 
        Test.stopTest();               
    }
    
    /****************************************************************************************************************************************
    Method Name:                                   testAuditSelectionMethod
    Description:                                   Created to test random audit
    Added By:                                      Accenture – Harika P  -  10/23/2018
    Modified By:                  Date:            Changes: 
    Accenture – Harika P        10/23/2018         Created.
    *****************************************************************************************************************************************/  
    @isTest static void testAuditSelectionMethod(){
        // To cover exception in randomAuditSelection method
        // Excluded Core_MDF_Total_Invoice_Amount_Local__c field in below SOQL
        list<PartnerFundClaim> exceptionPFC = [SELECT Id,Amount, Core_MDF_Claim_Ref_Number__c,CreatedDate,Title,Core_MDF_AccountCompany__c,Core_MDF_Activity_Category__c,Core_MDF_Country_Location_nm__c,Core_MDF_Activity_Types__c, Core_MDF_Program__c,Core_MDF_Exchange_rate__c, Core_MDF_Budget_Type_Nm__c 
                                               FROM PartnerFundClaim];
        Core_MDF_AuditSelectionHelper.randomAuditSelection(exceptionPFC);

        PartnerFundClaim isEscalationTypeClm = new PartnerFundClaim();
                PartnerFundClaim isEscalationTypeClm1 = new PartnerFundClaim();

        //Restting static variable so that it will
        if(Core_MDF_AuditSelectionHelper.isError){
            Core_MDF_AuditSelectionHelper.isError = false;
        }

        
        Test.startTest();
        List<Core_MDF_Escalation__c> esc =[Select Id, recordtypeid from Core_MDF_Escalation__c limit 1];
        List<PartnerFundClaim> clm = [SELECT Id,Core_MDF_IsClaimReviewEscalation_Ind__c,
                                          Core_MDF_Pred_PredictionResult__c,
                                          Core_MDF_AuditSelectionInProgress__c,
                                          Core_MDF_FlaggedForAudit__c,
                                          Core_MDF_Audit_Type__c,Title, Core_MDF_Program__c,
                                          Core_MDF_Total_Invoice_Amount_Local__c,Core_MDF_Exchange_rate__c,
                                          CreatedById,Core_MDF_Country_Location_nm__c,
                                          Core_MDF_Claim_Ref_Number__c,CreatedDate,Core_MDF_AccountCompany__c,
                                          Core_MDF_Activity_Category__c,Amount,Core_MDF_Audit_Hold__c,Core_MDF_Status__c,
                                          Core_MDF_Activity_Types__c,Core_MDF_Predictive_Audit_Error__c,
                                          Core_MDF_Predictive_Audit_Retries__c, Core_MDF_Budget_Type_Nm__c,Core_MDF_Escalation_Id__c, 
                                          Core_MDF_Escalation_Id__r.RecordTypeId FROM PartnerFundClaim WHERE Title LIKE 'Testing Claim%' LIMIT 1];
        
        clm[0].Core_MDF_Escalation_Id__c = esc[0].Id;
        clm[0].Core_MDF_Audit_Type__c ='Manual';
        clm[0].Core_MDF_FlaggedForAudit__c =true;
        clm[0].Core_MDF_Audit_Hold__c = true;
        clm[0].Core_MDF_Status__c ='Hold';
        //Test.startTest();
        update clm;
        
        list<PartnerFundClaim> pfcList = [SELECT Id,Core_MDF_IsClaimReviewEscalation_Ind__c,
                                          Core_MDF_Pred_PredictionResult__c,
                                          Core_MDF_AuditSelectionInProgress__c,
                                          Core_MDF_FlaggedForAudit__c,
                                          Core_MDF_Audit_Type__c,Title, Core_MDF_Program__c,
                                          Core_MDF_Total_Invoice_Amount_Local__c,Core_MDF_Exchange_rate__c,
                                          CreatedById,Core_MDF_Country_Location_nm__c,
                                          Core_MDF_Claim_Ref_Number__c,CreatedDate,Core_MDF_AccountCompany__c,
                                          Core_MDF_Activity_Category__c,Amount,Core_MDF_Audit_Hold__c,Core_MDF_Status__c,
                                          Core_MDF_Activity_Types__c,Core_MDF_Predictive_Audit_Error__c,
                                          Core_MDF_Predictive_Audit_Retries__c, Core_MDF_Budget_Type_Nm__c,Core_MDF_Escalation_Id__c, Core_MDF_Escalation_Id__r.RecordTypeId FROM PartnerFundClaim WHERE Title LIKE 'Test Claim%' LIMIT 11];
        pfcList[0].Core_MDF_Escalation_Id__c =esc[0].Id;
        //pfcList[0].Core_MDF_Pred_ThresholdFlag__c = 'No';
        update pfcList;

        for(PartnerFundClaim p:clm){
            if(p.Core_MDF_IsClaimReviewEscalation_Ind__c == false){
                isEscalationTypeClm1.Id = p.Id;
                isEscalationTypeClm1.Core_MDF_Pred_PredictionResult__c = p.Core_MDF_Pred_PredictionResult__c;
                isEscalationTypeClm1.Core_MDF_AuditSelectionInProgress__c = p.Core_MDF_AuditSelectionInProgress__c;
                isEscalationTypeClm1.Core_MDF_FlaggedForAudit__c = p.Core_MDF_FlaggedForAudit__c;
                isEscalationTypeClm1.Core_MDF_Audit_Type__c = p.Core_MDF_Audit_Type__c;
            }
        }
        System.debug('isEscalationTypeClm1-->'+isEscalationTypeClm1);
        
        for(PartnerFundClaim p:pfcList){
            if(p.Core_MDF_IsClaimReviewEscalation_Ind__c == true){
                isEscalationTypeClm.Id = p.Id;
                isEscalationTypeClm.Core_MDF_Pred_PredictionResult__c = p.Core_MDF_Pred_PredictionResult__c;
                isEscalationTypeClm.Core_MDF_AuditSelectionInProgress__c = p.Core_MDF_AuditSelectionInProgress__c;
                isEscalationTypeClm.Core_MDF_FlaggedForAudit__c = p.Core_MDF_FlaggedForAudit__c;
                isEscalationTypeClm.Core_MDF_Audit_Type__c = p.Core_MDF_Audit_Type__c;
            }
        }
        
        System.debug('isEscalationTypeClm-->'+isEscalationTypeClm);
        //Map<String,Map<PartnerFundClaim, String>> randomSelectionResult = Core_MDF_AuditSelectionHelper.randomAuditSelection(pfcList);
        //Map<String,Map<PartnerFundClaim, String>> randomSelectionResult1 = Core_MDF_AuditSelectionHelper.randomAuditSelection(clm);

        /*if(randomSelectionResult != null){
            System.assert(randomSelectionResult.containsKey('Random') || randomSelectionResult.containsKey('CheckForPredictiveAudit'));
        }*/
        Core_MDF_AuditSelectionHelper auditSelection = new Core_MDF_AuditSelectionHelper(pfcList);

        //to cover Exception
        Core_MDF_AuditSelectionHelper.groupClaimsBasedOnAuditType(null,null);
        Core_MDF_AuditSelectionHelper.predictiveAuditSelection(null,null,null);
        //Test.startTest();
        
        
        PartnerFundClaim clm1 = [Select Id, Amount,Core_MDF_Status__c from PartnerFundClaim where Title = 'India Claim New' limit 1];
        clm1.Core_MDF_Status__c = 'Hold';
        update clm1;
        
        
        // Invoke mock respnse
        Test.setMock(HttpCalloutMock.class, new Core_MDF_MockHttpResponseGenerator_Test());
        System.enqueueJob(auditSelection);
        
        //
        Map<PartnerFundClaim,String> claimToBeChecked = new Map<PartnerFundClaim,String>();
        claimToBeChecked.put(pfcList[0],'Random');
        claimToBeChecked.put(pfcList[1],'Random');
        claimToBeChecked.put(pfcList[2],'Random');
        claimToBeChecked.put(pfcList[3],'Predictive');
        claimToBeChecked.put(pfcList[4],'Predictive');
        claimToBeChecked.put(pfcList[5],'Predictive');
                
        User partnerUser = [SELECT Id, User.Name,LastName,email FROM User WHERE LastName='User Test1'];
        
        //Prepare xml and put it in map
        
        Map<Id,String> xmlClaimMapping = new Map<Id,String>{};
        String tempString = Core_MDF_AuditSelectionHelper.formXmlForPredAuditCheck(pfcList[3],'Test Agency','Test Geo', partnerUser.Name,partnerUser.email);
        xmlClaimMapping.put(pfcList[3].Id,tempString);
        
        /*tempString = Core_MDF_AuditSelectionHelper.formXmlForPredAuditCheck(pfcList[4],'Test Agency','Test Geo', partnerUser.Name,partnerUser.email);           
        xmlClaimMapping.put(pfcList[4].Id,tempString);
        tempString = Core_MDF_AuditSelectionHelper.formXmlForPredAuditCheck(pfcList[5],'Test Agency','Test Geo', partnerUser.Name,partnerUser.email);           
        xmlClaimMapping.put(pfcList[5].Id,tempString);*/
           
        //Core_MDF_AuditSelectionHelper.predictiveAuditSelection(pfcList,xmlClaimMapping,null);

        
        Map<Id,boolean> claimWithBoolean = new Map<Id,boolean>{};
        claimWithBoolean.put(pfcList[3].Id,true);
        claimWithBoolean.put(pfcList[4].Id,true);
        claimWithBoolean.put(pfcList[5].Id,true);
        claimWithBoolean.put(pfcList[0].Id,false);
        claimWithBoolean.put(pfcList[1].Id,false);
        claimWithBoolean.put(pfcList[2].Id,false);
        Core_MDF_AuditSelectionHelper.predictiveAuditSelection(pfcList,xmlClaimMapping,claimWithBoolean);
        Core_MDF_AuditSelectionHelper.predictiveAuditSelection(clm,xmlClaimMapping,claimWithBoolean);

        //Calling recheckCliam method
        Core_MDF_AuditSelectionHelper.recheckClaims(claimToBeChecked,xmlClaimMapping,claimWithBoolean);
        //Core_MDF_AuditSelectionHelper.recheckClaims(claimToBeChecked,null,null);
        //
        
        /*
        Map<PartnerFundClaim,String> claimToBeChecked9 = new Map<PartnerFundClaim,String>();
        claimToBeChecked9.put(clm[0],'Manual');        
        System.debug('claimToBeChecked9->'+claimToBeChecked9);
       
        Map<Id,String> xmlClaimMapping9= new Map<Id,String>{};
        tempString = Core_MDF_AuditSelectionHelper.formXmlForPredAuditCheck(clm[0],'Test Agency','Test Geo', partnerUser.Name,partnerUser.email);           
        xmlClaimMapping9.put(clm[0].Id,tempString);
        System.debug('xmlClaimMapping9->'+xmlClaimMapping9);
        Map<Id,boolean> claimWithBoolean9= new Map<Id,boolean>{};
        claimWithBoolean9.put(clm[0].Id,true);
        Core_MDF_AuditSelectionHelper.recheckClaims(claimToBeChecked9,xmlClaimMapping9,claimWithBoolean9);
        System.debug('claimWithBoolean9-->'+claimWithBoolean9);*/
        
        
        //Create fake response
        String response = '<AdvancedBI>'+
                        '<header>'+
                        '<CycleID>07122018032444</CycleID>'+
                        '<RecordsNumber>1</RecordsNumber>'+
                        '<PredictionTimeStamp>2018-12-09T20:45:22</PredictionTimeStamp>'+
                        '</header>'+
                        '<Request>'+
                        '<Line Number="1">'+
                        '<ProjectId ID="118">'+
                        '<RequestID>'+pfcList[0].Core_MDF_Claim_Ref_Number__c+'</RequestID>'+
                        '<Program>Client Co-Marketing Fund</Program>'+
                        '<PredictionResult>Non-compliant High</PredictionResult>'+
                        '<PredictionScore>0.921954</PredictionScore>'+
                        '<ThresholdFlag>Yes</ThresholdFlag>'+
                        '<Probability>0.5666667</Probability>'+
                        '<ModelTimeStamp>11/1/2018 3:17:30 PM</ModelTimeStamp>'+
                        '<IdealModelResult>Non-Compliant</IdealModelResult>'+
                        '</ProjectId>'+
                        '</Line>'+
                        '</Request>'+
                        '</AdvancedBI>';
    //Response with Core_MDF_Pred_ThresholdFlag__c as 'No' to cover else part in readXmlResponseAfterCAPSApiCall method.
    String response1 = '<AdvancedBI>'+
                        '<header>'+
                        '<CycleID>07122018032444</CycleID>'+
                        '<RecordsNumber>1</RecordsNumber>'+
                        '<PredictionTimeStamp>2018-12-09T20:45:22</PredictionTimeStamp>'+
                        '</header>'+
                        '<Request>'+
                        '<Line Number="1">'+
                        '<ProjectId ID="118">'+
                        '<RequestID>'+pfcList[0].Core_MDF_Claim_Ref_Number__c+'</RequestID>'+
                        '<Program>Client Co-Marketing Fund</Program>'+
                        '<PredictionResult>Non-compliant High</PredictionResult>'+
                        '<PredictionScore>0.921954</PredictionScore>'+
                        '<ThresholdFlag>No</ThresholdFlag>'+
                        '<Probability>0.5666667</Probability>'+
                        '<ModelTimeStamp>11/1/2018 3:17:30 PM</ModelTimeStamp>'+
                        '<IdealModelResult>Non-Compliant</IdealModelResult>'+
                        '</ProjectId>'+
                        '</Line>'+
                        '</Request>'+
                        '</AdvancedBI>';
        String response2 = NULL;
        //Reading xml response
        Core_MDF_AuditSelectionHelper.readXmlResponseAfterCAPSApiCall(response,pfcList);
        Core_MDF_AuditSelectionHelper.readXmlResponseAfterCAPSApiCall(response1,pfcList);
        Core_MDF_AuditSelectionHelper.readXmlResponseAfterCAPSApiCall(response2,clm);

        Map<PartnerFundClaim,String> claimToBeChecked2 = new Map<PartnerFundClaim,String>();
        claimToBeChecked2.put(pfcList[0],'Predictive');
        Core_MDF_AuditSelectionHelper.setAuditStatus(claimToBeChecked2);
        
        Map<PartnerFundClaim,String> claimToBeChecked4 = new Map<PartnerFundClaim,String>();
        claimToBeChecked4.put(clm[0],'Manual');
        Core_MDF_AuditSelectionHelper.setAuditStatus(claimToBeChecked4);
        
        /*
        Map<PartnerFundClaim,String> claimToBeChecked3 = new Map<PartnerFundClaim,String>();
        claimToBeChecked3.put(clm[0],null);
        Core_MDF_AuditSelectionHelper.setAuditStatus(claimToBeChecked3);*/
        /*
        Map<PartnerFundClaim,String> claimWithNoResponse = new Map<PartnerFundClaim,String>();
        claimWithNoResponse.put(pfc,'Predictive');
        Core_MDF_AuditSelectionHelper.setAuditStatus(claimWithNoResponse);*/
        
        //Test.stopTest();

        String outputResult = Core_MDF_AuditSelectionHelper.getValueForAuditTypePicklist('Predictive');
        System.AssertEquals('CAP',outputResult);
        outputResult = Core_MDF_AuditSelectionHelper.getValueForAuditTypePicklist('Random');
        System.AssertEquals('Random',outputResult);
        outputResult = Core_MDF_AuditSelectionHelper.getValueForAuditTypePicklist('Manual');
        System.AssertEquals('Manual',outputResult);
        outputResult = Core_MDF_AuditSelectionHelper.getValueForAuditTypePicklist(NULL);

        //check escalation claim
        /*list<PartnerFundClaim> pfcEscalationList = [SELECT Id, Title, Core_MDF_Pred_PredictionResult__c, 
                                                    Core_MDF_IsClaimReviewEscalation_Ind__c,
                                                    Core_MDF_AuditSelectionInProgress__c,
                                                    Core_MDF_Program__c, Core_MDF_Total_Invoice_Amount_Local__c,
                                                    Core_MDF_Audit_Type__c,
                                                    Core_MDF_FlaggedForAudit__c,Core_MDF_Exchange_rate__c,Amount,
                                                    CreatedById,Core_MDF_Predictive_Audit_Error__c,
                                                    Core_MDF_Predictive_Audit_Retries__c,Core_MDF_Escalation_Id__c, 
                                                    Core_MDF_Escalation_Id__r.RecordTypeId FROM PartnerFundClaim
                                                    WHERE Title LIKE 'Test Claim%' LIMIT 1];
        for(PartnerFundClaim pfcEscalation:pfcEscalationList){
            if(pfcEscalation.Core_MDF_IsClaimReviewEscalation_Ind__c == true){
                System.AssertEquals(true,String.isEmpty(isEscalationTypeClm.Core_MDF_Pred_PredictionResult__c));
                System.AssertEquals(false,isEscalationTypeClm.Core_MDF_AuditSelectionInProgress__c);
                System.AssertEquals(false,isEscalationTypeClm.Core_MDF_FlaggedForAudit__c);
                System.AssertEquals(true,String.isEmpty(isEscalationTypeClm.Core_MDF_Audit_Type__c));
            }
            
        }*/
       //Restting static variable so that it will
        if(Core_MDF_AuditSelectionHelper.isError){
            Core_MDF_AuditSelectionHelper.isError = false;
        }
         
        // Covering exception of all the method by passing negative data 
        list<PartnerFundClaim> pfcExceptionList = [SELECT Id, Title, Core_MDF_Program__c, Core_MDF_Total_Invoice_Amount_Local__c,Core_MDF_Exchange_rate__c,Amount,
                                            CreatedById,Core_MDF_Predictive_Audit_Error__c,Core_MDF_Predictive_Audit_Retries__c FROM PartnerFundClaim
                                            WHERE Title LIKE 'Test Claim%' LIMIT 11];
                                            
        
        Map<PartnerFundClaim,String> claimToBeChecked1 = new Map<PartnerFundClaim,String>();
        claimToBeChecked1.put(pfcExceptionList[0],'Random');
        claimToBeChecked1.put(pfcExceptionList[1],'Random');
        claimToBeChecked1.put(pfcExceptionList[2],'Random');
        claimToBeChecked1.put(pfcExceptionList[3],'Predictive');
        claimToBeChecked1.put(pfcExceptionList[4],'Predictive');
        claimToBeChecked1.put(pfcExceptionList[5],'Predictive');            
        
        //Prepare xml and put it in map
        
        Map<Id,String> xmlClaimMapping1 = new Map<Id,String>{};
        tempString = Core_MDF_AuditSelectionHelper.formXmlForPredAuditCheck(pfcExceptionList[3],'Test Agency','Test Geo', partnerUser.Name,partnerUser.email);
        xmlClaimMapping1.put(pfcExceptionList[3].Id,tempString);
        tempString = Core_MDF_AuditSelectionHelper.formXmlForPredAuditCheck(pfcExceptionList[4],'Test Agency','Test Geo', partnerUser.Name,partnerUser.email);           
        xmlClaimMapping1.put(pfcExceptionList[4].Id,tempString);
        tempString = Core_MDF_AuditSelectionHelper.formXmlForPredAuditCheck(pfcExceptionList[5],'Test Agency','Test Geo', partnerUser.Name,partnerUser.email);           
        xmlClaimMapping1.put(pfcExceptionList[5].Id,tempString);
        String res = Core_MDF_AuditSelectionHelper.callCAPSApi(pfcList,xmlClaimMapping);
        Core_MDF_AuditSelectionHelper.callCAPSApi(pfcList,null);
        //Core_MDF_AuditSelectionHelper.callCAPSApi(null,null);

            
        /*
        Map<Id,String> xmlClaimMapping2 = new Map<Id,String>{};
        tempString = Core_MDF_AuditSelectionHelper.formXmlForPredAuditCheck(pfcExceptionList[3],'Test Agency','Test Geo', partnerUser.Name,partnerUser.email);
        xmlClaimMapping2.put(pfcExceptionList[0].Id,tempString);
        tempString = Core_MDF_AuditSelectionHelper.formXmlForPredAuditCheck(pfcExceptionList[4],'Test Agency','Test Geo', partnerUser.Name,partnerUser.email);           
        xmlClaimMapping2.put(pfcExceptionList[1].Id,tempString);
        tempString = Core_MDF_AuditSelectionHelper.formXmlForPredAuditCheck(pfcExceptionList[5],'Test Agency','Test Geo', partnerUser.Name,partnerUser.email);           
        xmlClaimMapping2.put(pfcExceptionList[2].Id,tempString);*/
        
        Map<Id,boolean> claimWithBoolean1 = new Map<Id,boolean>{};
        claimWithBoolean1.put(pfcExceptionList[3].Id,true);
        claimWithBoolean1.put(pfcExceptionList[4].Id,true);
        claimWithBoolean1.put(pfcExceptionList[5].Id,true);
        claimWithBoolean1.put(pfcExceptionList[0].Id,false);
        claimWithBoolean1.put(pfcExceptionList[1].Id,false);
        claimWithBoolean1.put(pfcExceptionList[2].Id,false);
        /*
        Map<Id,boolean> claimWithBoolean2 = new Map<Id,boolean>{};
        
        claimWithBoolean2.put(pfcExceptionList[0].Id,true);
        claimWithBoolean2.put(pfcExceptionList[1].Id,true);
        claimWithBoolean2.put(pfcExceptionList[2].Id,true);*/
        
        //Calling recheckCliam method
        Core_MDF_AuditSelectionHelper.recheckClaims(claimToBeChecked1,xmlClaimMapping1,claimWithBoolean1);
        Core_MDF_AuditSelectionHelper.recheckClaims(claimToBeChecked1,xmlClaimMapping1,null);
        //Core_MDF_AuditSelectionHelper.recheckClaims(claimWithNoResponse,xmlClaimMapping1,null);

        //Reading xml response
        Core_MDF_AuditSelectionHelper.readXmlResponseAfterCAPSApiCall(response,pfcExceptionList);    
        //Core_MDF_AuditSelectionHelper.readXmlResponseAfterCAPSApiCall(null,pfcExceptionList);    
        // Calling getDateTimeForString method
        Core_MDF_AuditSelectionHelper.getDateTimeForString('11/1/2018 3:17:30 PM ');
        Core_MDF_AuditSelectionHelper.getDateTimeForString('11-1-2018 3:17:30:20 PM ');
        Core_MDF_AuditSelectionHelper.setAuditStatus(null);
        
        Test.stopTest();
       
    }
    
    @isTest
    static void retailEmeaAuditValidations(){
        
        test.startTest();
        PartnerFundRequest retailEmeaPfr = [SELECT Id FROM PartnerFundRequest WHERE Title = 'RSA MD Activity' limit 1];
        System.Assert(retailEmeaPfr != NULL); 
        List<PartnerFundClaim> claimListToInsert = new List<PartnerFundClaim>();
        
        for(Integer i = 0; i < 3; i++) {        
            PartnerFundClaim pfcl  = new PartnerFundClaim();
            pfcl.RecordTypeId = Core_MDF_CCP_TestDataUtility.claim_RecordType_Retail;                
            pfcl.Title = 'Test Claim EMEA' ;
            pfcl.RequestId = retailEmeaPfr.Id;
            if(i==0){
                pfcl.Core_MDF_Total_Invoice_Amount_Local__c = 105000;
            }else if(i==1){
                pfcl.Core_MDF_Total_Invoice_Amount_Local__c = 25000;
            }else if(i==2){
                pfcl.Core_MDF_Total_Invoice_Amount_Local__c = 100;
            }                                  
            pfcl.Core_MDF_Status__c = 'Submitted';
            pfcl.Description = 'Test PFC' + i;
            pfcl.Core_MDF_Ad_Run_Start_Date__c = system.today();
            pfcl.Core_MDF_Ad_Run_End_Date__c = system.today();
            pfcl.Core_MDF_Currency__c = 'USD';
            pfcl.Core_MDF_Country_Location_nm__c= 'GERMANY';
            
            claimListToInsert.add(pfcl);
        }
        
        database.insert(claimListToInsert);
        
        list<PartnerFundClaim> randomClaimList = [SELECT Id,Amount, Core_MDF_Claim_Ref_Number__c,CreatedDate,Title,Core_MDF_Region_Cd__c,
                                                  Core_MDF_AccountCompany__c,Core_MDF_Activity_Category__c,Core_MDF_Country_Location_nm__c,
                                                  ChannelPartnerId,Core_MDF_Activity_Types__c, Core_MDF_Program__c,Core_MDF_Exchange_rate__c, 
                                                  Core_MDF_Budget_Type_Nm__c 
                                                  FROM PartnerFundClaim 
                                                  WHERE Title LIKE 'Test Claim EMEA'];
        Core_MDF_AuditSelectionHelper.randomAuditSelection(randomClaimList);
        test.stopTest();
    }
    
     @isTest
    static void retailAsmoAuditValidations(){
        
        test.startTest();
        PartnerFundRequest retailAsmoPfr = [SELECT Id FROM PartnerFundRequest WHERE Title = 'RSA MD ASMO Activity' limit 1];
        System.Assert(retailAsmoPfr != NULL);        
        List<PartnerFundClaim> claimListToInsert = new List<PartnerFundClaim>();
        
        for(Integer i = 0; i < 3; i++) {        
            PartnerFundClaim pfcl  = new PartnerFundClaim();
            pfcl.RecordTypeId = Core_MDF_CCP_TestDataUtility.claim_RecordType_Retail;                
            pfcl.Title = 'Test Claim ASMO' ;
            pfcl.RequestId = retailAsmoPfr.Id;
            if(i==0){
                pfcl.Core_MDF_Total_Invoice_Amount_Local__c = 5000;
            }else if(i==1){
                pfcl.Core_MDF_Total_Invoice_Amount_Local__c = 25000;
            }else if(i==2){
                pfcl.Core_MDF_Total_Invoice_Amount_Local__c = 100;
            }                                  
            pfcl.Core_MDF_Status__c = 'Submitted';
            pfcl.Description = 'Test PFC' + i;
            pfcl.Core_MDF_Ad_Run_Start_Date__c = system.today();
            pfcl.Core_MDF_Ad_Run_End_Date__c = system.today();
            pfcl.Core_MDF_Currency__c = 'USD';
            pfcl.Core_MDF_Country_Location_nm__c= 'United States';
            
            claimListToInsert.add(pfcl);
        }
        
        database.insert(claimListToInsert);
        
        list<PartnerFundClaim> randomClaimList = [SELECT Id,Amount, Core_MDF_Claim_Ref_Number__c,CreatedDate,Title,Core_MDF_Region_Cd__c,
                                                  Core_MDF_AccountCompany__c,Core_MDF_Activity_Category__c,Core_MDF_Country_Location_nm__c,
                                                  ChannelPartnerId,Core_MDF_Activity_Types__c, Core_MDF_Program__c,Core_MDF_Exchange_rate__c, 
                                                  Core_MDF_Budget_Type_Nm__c 
                                                  FROM PartnerFundClaim 
                                                  WHERE Title LIKE 'Test Claim ASMO'];
        Core_MDF_AuditSelectionHelper.randomAuditSelection(randomClaimList);
        test.stopTest();
    }
}