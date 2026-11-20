/****************************************************************************************************************************************
* Class Name  : Core_MDF_BudgetCapHelper_Test 
* Version     : 1.0 
* Created Date: 05-09-2019
* Modification Log :
* Developer                     Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture – Harika P        5/09/2019                   Created Core_MDF_ProcessCCP_BudgetCap_Test to test 
*****************************************************************************************************************************************/
@isTest
private class Core_MDF_BudgetCapHelper_Test {
/****************************************************************************************************************************************
Method Name:                                   createBudgetCapRecords
Description:                                   Created createBudgetCapRecords() to test sum of claimed cap amount
Added By:                                      Accenture – Harika P      -  5/09/2019
Modified By:                  Date:            Changes: 
Accenture – Harika P         5/09/2019         Created.
*****************************************************************************************************************************************/
    @isTest static void createBudgetCapRecords() {
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 50000];
        // Creating User with utility class 
        User usr1 = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr1.LastName = 'User Test1';
        usr1.UserRoleId = usRole.Id;
        Database.insert(usr1);
        
        System.runAs(usr1){
            //adding bypass feature to bypass access validation
      List<String> bypassFunctionKeys = new List<String>();
            bypassFunctionKeys.add('Bypass_MDF_Budget_Access_Validation');
            bypassFunctionKeys.add('Bypass_MDF_Budget_Status_Validation');
            bypassFunctionKeys.add('Core_MDF_BudgetCapValidation');
            bypassFunctionKeys.add('Bypass_ShareActivityWithExternalUsers');
            bypassFunctionKeys.add('Bypass_ShareActivityWithAccNodeGroup');
            bypassFunctionKeys.add('Bypass_ShareActivityWithUsers');
            bypassFunctionKeys.add('Core_MDF_OpalBudgetValidation');
             bypassFunctionKeys.add('ByPass_BlockLegacyBudgetCreation');
              bypassFunctionKeys.add('Bypass_Claims_Amt_vs_Budget_Amt_Check');
            bypassFunctionKeys.add('Bypass_Claim_AdjReq_Amount_Validation');
            bypassFunctionKeys.add('Bypass_Claims_Amt_vs_Camp_Amt_Check');
            Set<String> myset1 = new Set<String>();
            List<String> result1 = new List<String>();
            myset1.addAll(bypassFunctionKeys);
            result1.addAll(myset1);
            List<Core_Trigger_Executions__c> bypassfunctinalitylist1 = Core_MDF_CCP_TestDataUtility.byPassFeature(result1,true,true);

            /*Core_MDF_CCP_TestDataUtility.byPassFeature(new List<String>{'Bypass_Claims_ABM_Validation','Bypass_Claims_Amt_vs_Budget_Amt_Check',
            'Bypass_Claims_Amt_vs_Camp_Amt_Check','Bypass_Claims_Duplicate_Check',
            'Bypass_Claim_OwnerLang_EmailTemp','Bypass_Claims_Sharing_Internal_Users',
            'Bypass_Claims_Sharing_Partner_Users','Bypass_Claims_Sharing_On_Owner_Change'}, true, true);*/
            
                        
Core_MDF_CCP_TestDataUtility.createMDFConfigurationData();  
            
            // Custom setting creation
            /*
            Core_MDF_Skip_Validation_Rule__c skipValidation = new Core_MDF_Skip_Validation_Rule__c();
            skipValidation.Skip_Rule__c = TRUE;
            Database.insert(skipValidation);*/
            
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
            test.startTest();
            database.insert(newValues);
            
            // Creating channel program with utility class
            ChannelProgram cp = Core_MDF_CCP_TestDataUtility.createProgram ('Client','Client CoMarketing Fund', true);
            
            // Creating IntelAccount with utility class
            Account acc1 = Core_MDF_CCP_TestDataUtility.createIntelAccount ('Master Test Account 1', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, 
                                                                            false);
             try {
              Database.insert(acc1);
             }catch (DMLException e) {
             }
            /*acc1.Core_Account_Type__c = 'Reseller';
            acc1.Core_Sales_Groups__c = 'Automotive Sales Group';
            acc1.Industry = 'Food & Beverage';
            acc1.Core_MDF_Channel_Program__c = cp.Id;
            acc1.Core_MDF_CoMarketingAgency__c=true;
            Database.insert(acc1);*/
            
            // Creating Co-marketing Account with utility class
            Account acc = Core_MDF_CCP_TestDataUtility.createAccount ('Co-marketing Test Account', cp.Id,
                                                                      Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            acc.Core_MDF_Parent_Fund_Account__c = acc1.Id;
            Database.insert(acc);  
            
            // Creating campaigns using utility class
            Campaign camp = Core_MDF_CCP_TestDataUtility.createCampaign('TestCamp','Consumer','Intel® Corporate Logo','Yes', 
                                                                        Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF,
                                                                        'Client CoMarketing Fund',System.today() ,
                                                                        System.today().addDays(200), 20000000, 'Unite',acc.Id,'2-in-1', false);
            camp.Core_MDF_Reimbursement_Rate__c = '100%';
            camp.Core_MDF_Opal_Budget_Type_Txt__c = 'OEM CMP';
            insert camp;
            // Creating Budget using utility class
            PartnerMarketingBudget pmb = Core_MDF_CCP_TestDataUtility.createBudget('Test Budget',Core_MDF_CCP_TestDataUtility.budget_Record_Type,
                                                                                   acc.Id,cp.Id,50000000,System.today(),System.today().addDays(110), 
                                                                                   false);
            pmb.Core_MDF_Budget_Type_Txt__c='CCF 1.0';
            //pmb.Core_MDF_Budget_Status__c = 'Approved';
            Database.insert(pmb);
            

            pmb.Core_MDF_Budget_Status__c = 'Released';
            Database.update(pmb);

            
            // Creating Allocation using utility class
            //PartnerFundAllocation pfa = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('Test Allocation',pmb,acc,0,false);
            PartnerFundAllocation pfa = [Select id,amount, BudgetId from PartnerFundAllocation where budgetId =: pmb.id];
            //Database.insert(pfa);
            
            PartnerMarketingBudget pmb1 = [SELECT Id,Title, Core_MDF_Budget_Status__c, TotalAllocatedAmount FROM PartnerMarketingBudget WHERE Title ='Test Budget'];
      
             // Creating Bank
            Core_MDF_Bank__c bank = Core_MDF_CCP_TestDataUtility.createBank(acc1.id,'Core_MDF_Client_CoMarketing_Fund',true,'1234567890');
            
            //ABM
            // Highlight: Unused Local Variable 
            //Core_MDF_Account_Bank_Mapping__c abm = Core_MDF_CCP_TestDataUtility.createAccountBankMap(acc.id,bank.id,true);
           // Creating BudgetCap Record
      Id budget_Cap_Record_Type = Schema.SObjectType.Core_MDF_Budget_Cap__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_CCP_Budget_Cap').getRecordTypeId();
            Core_MDF_Budget_Cap__c budgetCap = new Core_MDF_Budget_Cap__c();
            budgetCap.RecordTypeId = budget_Cap_Record_Type;
            budgetCap.Core_MDF_Cap_Type_nm__c = 'Channel Led Activity';
            budgetCap.Core_MDF_Budget_Name_id__c = pmb.Id;
            budgetCap.Core_MDF_Requested_Cap_amt__c = 150000;
            budgetCap.Core_MDF_Approved_Cap_amt__c = 150000;
            Database.insert(budgetCap);
            
             
            // Creating activities using utility class
            PartnerFundRequest pfr = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(camp.Id),
                                                                                           Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,
                                                                                           string.valueof(acc.id),pfa,pmb1,'INDIA','Small Business',
                                                                                           'Desktop','Intel® Corporate Logo','Broadcast (Pre-2025)',
                                                                                           'Podcast','Draft',false);
            pfr.RequestedAmount = 90000;
            pfr.Amount = 90000;
            pfr.Status = 'Approved';
            pfr.Core_MDF_Reimbursement_Rate_txt__c = '100%';
            PartnerFundRequest pfr1 = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(camp.Id),
                                                                                           Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,
                                                                                           string.valueof(acc.id),pfa,pmb1,'INDIA','Small Business',
                                                                                           'Desktop','Intel® Corporate Logo','Broadcast (Pre-2025)',
                                                                                           'Podcast','Draft',false);
            pfr1.Core_MDF_Channel_Partner_Led__c = true;
            pfr1.RequestedAmount = 90000;
            pfr1.Amount = 90000;
            pfr1.Status = 'Approved';
            pfr1.Core_MDF_Reimbursement_Rate_txt__c = '100%';
            
            PartnerFundRequest pfr2 = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(camp.Id),
                                                                                           Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,
                                                                                           string.valueof(acc.id),pfa,pmb1,'INDIA','Small Business',
                                                                                           'Desktop','Intel® Corporate Logo','Broadcast (Pre-2025)',
                                                                                           'Podcast','Draft',false);
            pfr2.Core_MDF_Channel_Partner_Led__c = true;
            pfr2.RequestedAmount = 90000;
            pfr2.Amount = 90000;
            pfr2.Status = 'Approved';
          pfr2.Core_MDF_Reimbursement_Rate_txt__c = '100%';
            
            List<PartnerFundRequest> pfrList = new List<PartnerFundRequest>();
            pfrList.add(pfr);
            pfrList.add(pfr1);
            pfrList.add(pfr2);
             
            Database.insert(pfrList);
            
      test.stopTest();           
            
     
            
       
            
            
            // Creating claims
            List<PartnerFundClaim> newClmList = new List<PartnerFundClaim>();
            for(Integer i = 0; i < 5; i++) {                
                PartnerFundClaim pfc  = new PartnerFundClaim();
                pfc.RecordTypeId = Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF;
                pfc.Title = 'Test Claim' + i;
                if(i==0){
                    pfc.Core_MDF_Total_Invoice_Amount_Local__c = 4000;
                    pfc.RequestId = pfr.Id;
                }
                if(i==1){
                    pfc.Core_MDF_Total_Invoice_Amount_Local__c = 3000;
                    pfc.RequestId = pfr.Id;
                }
                if(i==2){
                    pfc.Core_MDF_Total_Invoice_Amount_Local__c = 10000;
                    pfc.RequestId = pfr1.Id;
                }
                if(i==3){
                    pfc.Core_MDF_Total_Invoice_Amount_Local__c = 5000;
                    pfc.RequestId = pfr1.Id;
                }
                if(i==4){
                    pfc.Core_MDF_Total_Invoice_Amount_Local__c = 5000;
                    pfc.RequestId = pfr2.Id;
                }
                pfc.Core_MDF_Status__c = 'Submitted';
                pfc.Description = 'Test PFC ';
                pfc.Core_MDF_Ad_Run_Start_Date__c = System.today();
                pfc.Core_MDF_Ad_Run_End_Date__c = System.today();
                pfc.Core_MDF_Invoice_Date__c = System.today();
                pfc.Core_MDF_Invoice_Number__c = '1121';
                pfc.Core_MDF_Media_Vehicle__c = 'test';
                pfc.Core_MDF_OtherCostsnotReimbursable_Local__c = 0;
                pfc.Core_MDF_Taxes_Local__c = 0;
                pfc.Core_MDF_Currency__c = 'USD';
                pfc.Core_MDF_Exchange_rate__c = 1;
                pfc.Core_MDF_Bank__c = bank.Id;
                pfc.amount = 2500;
                pfc.Core_MDF_Country_Location_nm__c= 'BRAZIL';
                pfc.RecordTypeId = Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF;
                newClmList.add(pfc);
               
            }
            
            Database.insert(newClmList);
            
             
            PartnerFundClaim pfc1 = [SELECT Id, Title, Core_MDF_Total_Invoice_Amount_Local__c FROM PartnerFundClaim WHERE Title ='Test Claim1'];
            pfc1.Core_MDF_Total_Invoice_Amount_Local__c = 100;
            Database.update(pfc1);
            
            PartnerFundClaim pfc2 = [SELECT Id, Title, Core_MDF_Total_Invoice_Amount_Local__c FROM PartnerFundClaim WHERE Title ='Test Claim2'];
            pfc2.Core_MDF_Total_Invoice_Amount_Local__c = 120;
            Database.saveResult srRes1 = Database.update(pfc2,false);
             
            System.assertEquals(true,srRes1.isSuccess());                                            
        }        
    }
    
/****************************************************************************************************************************************
    Method Name:                                             testValidateRuleMethod
    Description:                                             Created for Validating Rules
    Added By:                                                Accenture – Harika P  -  5/09/2019
    Modified By:                  Date:                      Changes: 
    Accenture – Harika P          5/09/2019                  Created.
*****************************************************************************************************************************************/      
    
    @isTest static void testValidateRuleMethod()
    { 
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 50000];
        test.startTest();
        // Creating User with utility class 
        User usr1 = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr1.LastName = 'User Test1';
        usr1.UserRoleId = usRole.Id;
        Database.insert(usr1);
        System.runAs(usr1){
            Boolean ruleResult;
            //testing validateRule method for data type DOUBLE with appropriate operators
            ruleResult = Core_MDF_BudgetCapHelper.isCriteriaMatching('10','10','Equal','DOUBLE');
            System.assertEquals(true,ruleResult);
            ruleResult = Core_MDF_BudgetCapHelper.isCriteriaMatching('10','20','Not Equal','DOUBLE');
            System.assertEquals(true,ruleResult);
            ruleResult = Core_MDF_BudgetCapHelper.isCriteriaMatching('10','40','Equal','DOUBLE');
            System.assertEquals(false,ruleResult);
            ruleResult = Core_MDF_BudgetCapHelper.isCriteriaMatching('20','20','Not Equal','DOUBLE');
            System.assertEquals(false,ruleResult);  

            //testing validateRule method for data type PICKLIST with appropriate operators         
            ruleResult = Core_MDF_BudgetCapHelper.isCriteriaMatching('50%','50%','Equal','PICKLIST');
            System.assertEquals(true,ruleResult);
            ruleResult = Core_MDF_BudgetCapHelper.isCriteriaMatching('50%','30%','Not Equal','PICKLIST');
            System.assertEquals(true,ruleResult);
            ruleResult = Core_MDF_BudgetCapHelper.isCriteriaMatching('50%','30%','Greater Than','PICKLIST');
            System.assertEquals(false,ruleResult);
            
            //testing validateRule method for data type CURRENCY with appropriate operators             
            ruleResult = Core_MDF_BudgetCapHelper.isCriteriaMatching('5000','2000','Not Equal','CURRENCY');
            System.assertEquals(true,ruleResult);
            ruleResult = Core_MDF_BudgetCapHelper.isCriteriaMatching('5000','5000','Equal','CURRENCY');
            System.assertEquals(true,ruleResult);
            ruleResult = Core_MDF_BudgetCapHelper.isCriteriaMatching('5000','2000','Greater Than','CURRENCY');
            System.assertEquals(true,ruleResult);
            ruleResult = Core_MDF_BudgetCapHelper.isCriteriaMatching('2000','5000','Less Than','CURRENCY');
            System.assertEquals(true,ruleResult);
            ruleResult = Core_MDF_BudgetCapHelper.isCriteriaMatching('5000','4000','Greater Than or Equal','CURRENCY');
            System.assertEquals(true,ruleResult);
            ruleResult = Core_MDF_BudgetCapHelper.isCriteriaMatching('4000','5000','Less Than or Equal','CURRENCY');
            System.assertEquals(true,ruleResult);
            
            //testing validateRule method for data type DATE with appropriate operators  
            ruleResult = Core_MDF_BudgetCapHelper.isCriteriaMatching(String.valueOf(System.today().addDays(5)),String.valueOf(System.today()),
                                                                      'Greater Than','DATE');
            System.assertEquals(true,ruleResult);
            ruleResult = Core_MDF_BudgetCapHelper.isCriteriaMatching(String.valueOf(System.today()),String.valueOf(System.today().addDays(5)),
                                                                      'Less Than','DATE');
            System.assertEquals(true,ruleResult);
            ruleResult = Core_MDF_BudgetCapHelper.isCriteriaMatching(String.valueOf(System.today()),String.valueOf(System.today()),'Equal','DATE');
            System.assertEquals(true,ruleResult);
            ruleResult = Core_MDF_BudgetCapHelper.isCriteriaMatching(String.valueOf(System.today()),String.valueOf(System.today()),'Not Equal',
                                                                      'DATE');
            System.assertEquals(false,ruleResult);
            ruleResult = Core_MDF_BudgetCapHelper.isCriteriaMatching(String.valueOf(System.today()),String.valueOf(System.today()),
                                                                      'Greater Than or Equal','DATE');
            System.assertEquals(true,ruleResult);
            ruleResult = Core_MDF_BudgetCapHelper.isCriteriaMatching(String.valueOf(System.today()),String.valueOf(System.today().addDays(1)),
                                                                      'Less Than or Equal','DATE');
            System.assertEquals(true,ruleResult);
            
            //testing validateRule method for data type MULTIPICKLIST with appropriate operators    
            ruleResult = Core_MDF_BudgetCapHelper.isCriteriaMatching('ALBANIA;AUSTRALIA','ALBANIA;AUSTRALIA','Equal','MULTIPICKLIST');
            System.assertEquals(true,ruleResult);
            ruleResult = Core_MDF_BudgetCapHelper.isCriteriaMatching('ALBANIA;AUSTRALIA','ALBANIA;AUSTRALIA','Not Equal','MULTIPICKLIST');
            System.assertEquals(false,ruleResult);
            ruleResult = Core_MDF_BudgetCapHelper.isCriteriaMatching('ALBANIA;AUSTRALIA','ALBANIA;INDIA','Not Equal','MULTIPICKLIST');
            System.assertEquals(true,ruleResult);
            ruleResult = Core_MDF_BudgetCapHelper.isCriteriaMatching('ALBANIA;AUSTRALIA','ALBANIA;INDIA','Equal','MULTIPICKLIST');
            System.assertEquals(false,ruleResult);
            ruleResult = Core_MDF_BudgetCapHelper.isCriteriaMatching('ALBANIA','ALBANIA;AUSTRALIA','Equal','MULTIPICKLIST');
            System.assertEquals(false,ruleResult);
            ruleResult = Core_MDF_BudgetCapHelper.isCriteriaMatching('ALBANIA;AUSTRALIA','ALBANIA;AUSTRALIA','Greater Than','MULTIPICKLIST');
            System.assertEquals(false,ruleResult);
            
            //testing validateRule method for data type TEXTAREA with appropriate operators
            ruleResult = Core_MDF_BudgetCapHelper.isCriteriaMatching('Tset','Test','Equal','TEXTAREA');
            System.assertEquals(false,ruleResult);
            ruleResult = Core_MDF_BudgetCapHelper.isCriteriaMatching('Test','Test','Equal','TEXTAREA');
            System.assertEquals(true,ruleResult);
            ruleResult = Core_MDF_BudgetCapHelper.isCriteriaMatching('Test1','Test','Not Equal','TEXTAREA');
            System.assertEquals(true,ruleResult);
            ruleResult = Core_MDF_BudgetCapHelper.isCriteriaMatching('Test1','Test','Not Equal','TESTFIELDTYPE');
            System.assertEquals(false,ruleResult);
            
            //testing validateRule method for data type all with appropriate IN,NOT In, Equla and Not Equal operators
            ruleResult = Core_MDF_BudgetCapHelper.isCriteriaMatching('ALBANIA','ALBANIA;AUSTRALIA','In','MULTIPICKLIST');
            System.assertEquals(true,ruleResult); 
            ruleResult = Core_MDF_BudgetCapHelper.isCriteriaMatching('ALBANIA;INDIA','ALBANIA;AUSTRALIA','In','MULTIPICKLIST');
            System.assertEquals(false,ruleResult);  
            ruleResult = Core_MDF_BudgetCapHelper.isCriteriaMatching('ALBANIA;INDIA','ALBANIA;AUSTRALIA','Not In','MULTIPICKLIST');
            System.assertEquals(false,ruleResult);
            ruleResult = Core_MDF_BudgetCapHelper.isCriteriaMatching('10','10','In','STRING');
            System.assertEquals(true,ruleResult);
            ruleResult = Core_MDF_BudgetCapHelper.isCriteriaMatching('10;20','10','In','STRING');
            System.assertEquals(false,ruleResult);
            ruleResult = Core_MDF_BudgetCapHelper.isCriteriaMatching(NULL,NULL,'In','STRING');
            System.assertEquals(true,ruleResult);
            ruleResult = Core_MDF_BudgetCapHelper.isCriteriaMatching(NULL,'ALBANIA;AUSTRALIA','In','STRING');
            System.assertEquals(false,ruleResult);
            ruleResult = Core_MDF_BudgetCapHelper.isCriteriaMatching(NULL,'ALBANIA;AUSTRALIA','Not In','STRING');
            System.assertEquals(true,ruleResult);
            ruleResult = Core_MDF_BudgetCapHelper.isCriteriaMatching('ALBANIA','ALBANIA;AUSTRALIA','Not In','STRING');
            System.assertEquals(false,ruleResult);      
            ruleResult = Core_MDF_BudgetCapHelper.isCriteriaMatching('INDIA','ALBANIA;AUSTRALIA','Not In','STRING');
            System.assertEquals(true,ruleResult);       
            ruleResult = Core_MDF_BudgetCapHelper.isCriteriaMatching(NULL,NULL,'Not In','STRING');
            System.assertEquals(false,ruleResult);
            ruleResult = Core_MDF_BudgetCapHelper.isCriteriaMatching('ALBANIA','ALBANIA;AUSTRALIA','In','MULTIPICKLIST');
            System.assertEquals(true,ruleResult);
            ruleResult = Core_MDF_BudgetCapHelper.isCriteriaMatching('ALBANIA',NULL,'In','MULTIPICKLIST');
            System.assertEquals(false,ruleResult);
            ruleResult = Core_MDF_BudgetCapHelper.isCriteriaMatching(NULL,'ALBANIA','In','MULTIPICKLIST');
            System.assertEquals(false,ruleResult);
            ruleResult = Core_MDF_BudgetCapHelper.isCriteriaMatching(NULL,NULL,'In','MULTIPICKLIST');
            System.assertEquals(true,ruleResult);
            ruleResult = Core_MDF_BudgetCapHelper.isCriteriaMatching(NULL,NULL,'Not In','MULTIPICKLIST');
            System.assertEquals(false,ruleResult);
            ruleResult = Core_MDF_BudgetCapHelper.isCriteriaMatching('ALBANIA','ALBANIA;AUSTRALIA','Not In','MULTIPICKLIST');
            System.assertEquals(false,ruleResult);      
            ruleResult = Core_MDF_BudgetCapHelper.isCriteriaMatching(NULL,'ALBANIA','Not In','MULTIPICKLIST');
            System.assertEquals(true,ruleResult);
            ruleResult = Core_MDF_BudgetCapHelper.isCriteriaMatching(NULL,NULL,'Equal','MULTIPICKLIST');
            System.assertEquals(true,ruleResult);
            ruleResult = Core_MDF_BudgetCapHelper.isCriteriaMatching('ALBANIA',NULL,'Equal','STRING');
            System.assertEquals(false,ruleResult);
            ruleResult = Core_MDF_BudgetCapHelper.isCriteriaMatching(NULL,'ALBANIA','Equal','MULTIPICKLIST');
            System.assertEquals(false,ruleResult);
            ruleResult = Core_MDF_BudgetCapHelper.isCriteriaMatching(NULL,NULL,'Not Equal','MULTIPICKLIST');
            System.assertEquals(false,ruleResult);
            ruleResult = Core_MDF_BudgetCapHelper.isCriteriaMatching('ALBANIA',NULL,'Not Equal','STRING');
            System.assertEquals(true,ruleResult);
            ruleResult = Core_MDF_BudgetCapHelper.isCriteriaMatching(NULL,'ALBANIA','Not Equal','MULTIPICKLIST');
            System.assertEquals(true,ruleResult); 
            ruleResult = Core_MDF_BudgetCapHelper.isCriteriaMatching('INDIA','ALBANIA;AUSTRALIA','Not In','MULTIPICKLIST');
            System.assertEquals(true,ruleResult);       
           test.stopTest();
        } 
    }
}