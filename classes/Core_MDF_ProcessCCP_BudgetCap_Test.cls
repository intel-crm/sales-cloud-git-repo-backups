/****************************************************************************************************************************************
* Class Name  : Core_MDF_ProcessCCP_BudgetCap_Test 
* Version     : 1.0 
* Created Date: 05-09-2019
* Modification Log :
* Developer                     Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture – Harika P        5/09/2019                   Created Core_MDF_ProcessCCP_BudgetCap_Test to test sum of claimed cap amount
*****************************************************************************************************************************************/
@isTest
private class Core_MDF_ProcessCCP_BudgetCap_Test {
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
        usr1.UserPermissionsMarketingUser = true;
        usr1.UserRoleId = usRole.Id;
        Database.insert(usr1);
        
        System.runAs(usr1){
            
            // Custom setting creation
            /*
            Core_MDF_Skip_Validation_Rule__c skipValidation = new Core_MDF_Skip_Validation_Rule__c();
            skipValidation.Skip_Rule__c = TRUE;
            Database.insert(skipValidation);*/
            
            //Creating Trigger Excecution Custom Setting record 
            Core_Trigger_Executions__c bcValidation = new Core_Trigger_Executions__c();
            bcValidation.Core_Active__c = true;
            bcValidation.Core_Class_Name__c = 'Core_MDF_PFCServiceHandler';
            bcValidation.Core_Description__c = 'Budget Cap Validation';
            bcValidation.Core_Object__c = 'PartnerFundClaim';
            bcValidation.Core_Trigger_Events__c = 'before insert,before update';
            bcValidation.Name='Core_MDF_BudgetCapValidation';        
            Database.insert(bcValidation);          
            
            Core_Trigger_Executions__c bcValidation1 = new Core_Trigger_Executions__c();
            bcValidation1.Core_Active__c = true;
            bcValidation1.Core_Class_Name__c = 'Core_MDF_ProcessCCP_Claim';
            bcValidation1.Core_Description__c = 'Budget Cap Validation';
            bcValidation1.Core_Object__c = 'PartnerFundClaim';
            bcValidation1.Core_Trigger_Events__c = 'before insert,before update';
            bcValidation1.Name='checkESDHoldAndUpdateClaimStatus';        
            Database.insert(bcValidation1); 

            Core_Trigger_Executions__c bcValidation2 = new Core_Trigger_Executions__c();
            bcValidation2.Core_Active__c = true;
            bcValidation2.Core_Class_Name__c = 'Core_MDF_ProcessCCP_Claim';
            bcValidation2.Core_Description__c = 'Budget Cap Validation';
            bcValidation2.Core_Object__c = 'PartnerFundClaim';
            bcValidation2.Core_Trigger_Events__c = 'before insert,before update';
            bcValidation2.Name='duplicateClaimCheck';        
            Database.insert(bcValidation2);

            Core_Trigger_Executions__c bcValidation3 = new Core_Trigger_Executions__c();
            bcValidation3.Core_Active__c = true;
            bcValidation3.Core_Class_Name__c = 'Core_MDF_PFCServiceHandler';
            bcValidation3.Core_Description__c = 'Budget Cap Validation';
            bcValidation3.Core_Object__c = 'PartnerFundClaim';
            bcValidation3.Core_Trigger_Events__c = 'after insert,after update';
            bcValidation3.Name='checkAndSendClaimsToAudit';        
            Database.insert(bcValidation3); 
            
            Core_Trigger_Executions__c bcValidation4 = new Core_Trigger_Executions__c();
            bcValidation4.Core_Active__c = true;
            bcValidation4.Core_Class_Name__c = 'Core_MDF_PFCServiceHandler';
            bcValidation4.Core_Description__c = 'Budget Cap Validation';
            bcValidation4.Core_Object__c = 'PartnerFundClaim';
            bcValidation4.Core_Trigger_Events__c = 'after insert,after update';
            bcValidation4.Name='Core_MDF_ClaimToCase';        
            Database.insert(bcValidation4);

            Core_Trigger_Executions__c bcValidation5 = new Core_Trigger_Executions__c();
            bcValidation5.Core_Active__c = true;
            bcValidation5.Core_Class_Name__c = 'Core_MDF_ProcessCCP_Claim';
            bcValidation5.Core_Description__c = 'Budget Cap Validation';
            bcValidation5.Core_Object__c = 'PartnerFundClaim';
            bcValidation5.Core_Trigger_Events__c = 'after insert,after update';
            bcValidation5.Name='fundReservation';        
            Database.insert(bcValidation5);     
                
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
            ChannelProgram cp = Core_MDF_CCP_TestDataUtility.createProgram ('Client Co-Marketing Fund','Client CoMarketing Fund', true);
            
            // Creating IntelAccount with utility class
            Account acc1 = Core_MDF_CCP_TestDataUtility.createIntelAccount ('Test Account 1', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, 
                                                                            true);
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
            Campaign camp = Core_MDF_CCP_TestDataUtility.createCampaign('TestCamp','Consumer','Intel® Corporate Logo', 
                                                                        Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF,
                                                                        'Client CoMarketing Fund',System.today() ,
                                                                        System.today().addDays(200), 20000000, 'Unite',acc.Id,'2-in-1', true);
            
            // Creating Budget using utility class
            PartnerMarketingBudget pmb = Core_MDF_CCP_TestDataUtility.createBudget('Test Budget',Core_MDF_CCP_TestDataUtility.budget_Record_Type,
                                                                                   acc.Id,cp.Id,5000000,System.today(),System.today().addDays(110), 
                                                                                   false);
            pmb.Core_MDF_Budget_Status__c = 'Approved';
            Database.insert(pmb);
            

            pmb.Core_MDF_Budget_Status__c = 'Released';
            Database.update(pmb);

            
            // Creating Allocation using utility class
            PartnerFundAllocation pfa = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('Test Allocation',pmb,acc,5000000,true);
            
            PartnerMarketingBudget pmb1 = [SELECT Id,Title, Core_MDF_Budget_Status__c, TotalAllocatedAmount FROM PartnerMarketingBudget WHERE Title ='Test Budget'];
            System.debug('pmb1.TotalAllocatedAmount :' + pmb1.TotalAllocatedAmount);
            
            test.startTest();
            // Creating activities using utility class
            PartnerFundRequest pfr = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(camp.Id),
                                                                                           Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,
                                                                                           string.valueof(acc.id),pfa,pmb1,'INDIA','Small Business',
                                                                                           'Desktop','Intel® Core™ i7 Processor','Broadcast',
                                                                                           'Podcast','Draft',false);
            pfr.RequestedAmount = 90000;
            pfr.Amount = 90000;
            pfr.Status = 'Approved';
            PartnerFundRequest pfr1 = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(camp.Id),
                                                                                           Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,
                                                                                           string.valueof(acc.id),pfa,pmb1,'INDIA','Small Business',
                                                                                           'Desktop','Intel® Core™ i7 Processor','Broadcast',
                                                                                           'Podcast','Draft',false);
            pfr1.Core_MDF_Channel_Partner_Led__c = true;
            pfr1.RequestedAmount = 90000;
            pfr1.Amount = 90000;
            pfr1.Status = 'Approved';
            
            PartnerFundRequest pfr2 = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(camp.Id),
                                                                                           Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,
                                                                                           string.valueof(acc.id),pfa,pmb1,'INDIA','Small Business',
                                                                                           'Desktop','Intel® Core™ i7 Processor','Broadcast',
                                                                                           'Podcast','Draft',false);
            pfr2.Core_MDF_Channel_Partner_Led__c = true;
            pfr2.RequestedAmount = 90000;
            pfr2.Amount = 90000;
            pfr2.Status = 'Approved';
            
            List<PartnerFundRequest> pfrList = new List<PartnerFundRequest>();
            pfrList.add(pfr);
            pfrList.add(pfr1);
            pfrList.add(pfr2);
            Database.insert(pfrList);
            
            // Creating Bank
            Core_MDF_Bank__c bank = Core_MDF_CCP_TestDataUtility.createBank(acc1.id,'Core_MDF_Client_CoMarketing_Fund',true,'1234567890');
            
            //ABM
            Core_MDF_Account_Bank_Mapping__c abm = Core_MDF_CCP_TestDataUtility.createAccountBankMap(acc.id,bank.id,true);
            
            
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
                newClmList.add(pfc);
            }
            Database.insert(newClmList);
            
            
            // Creating BudgetCap Record
            Core_MDF_Budget_Cap__c budgetCap = new Core_MDF_Budget_Cap__c();
            budgetCap.Core_MDF_Cap_Type_nm__c = 'Channel Led Activity';
            budgetCap.Core_MDF_Budget_Name_id__c = pmb1.Id;
            budgetCap.Core_MDF_Requested_Cap_amt__c = 15000;
            Database.insert(budgetCap);   
            test.stopTest();
            
            //Updating budget cap record to validate error 
            Core_MDF_Budget_Cap__c bcRecord = [SELECT Id,Core_MDF_Requested_Cap_amt__c,Core_MDF_Cap_Type_nm__c,Core_MDF_Approved_Cap_amt__c FROM 
                                               Core_MDF_Budget_Cap__c WHERE Id =:budgetCap.Id ];
            bcRecord.Core_MDF_Requested_Cap_amt__c = 5000;
            Database.saveResult srRes2 = Database.update(bcRecord,false);
            System.assertEquals(false,srRes2.isSuccess());
            
            List<Database.saveResult> srResList = new List<Database.saveResult>(); 
            srResList.add(srRes2);
            // Calling insertLogEntryRecord method
            Core_MDF_ProcessCCP_BudgetCap.insertLogEntryRecord(srResList);
            Core_MDF_ProcessCCP_BudgetCap.insertLogEntryRecord(null);
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
        test.startTest();
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 50000];
        
        // Creating User with utility class 
        User usr1 = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr1.LastName = 'User Test1';
        usr1.UserRoleId = usRole.Id;
        Database.insert(usr1);
        System.runAs(usr1){
            Boolean ruleResult;
            //testing validateRule method for data type DOUBLE with appropriate operators
            ruleResult = Core_MDF_ProcessCCP_BudgetCap.isCriteriaMatching('10','10','Equal','DOUBLE');
            System.assertEquals(true,ruleResult);
            ruleResult = Core_MDF_ProcessCCP_BudgetCap.isCriteriaMatching('10','20','Not Equal','DOUBLE');
            System.assertEquals(true,ruleResult);
            ruleResult = Core_MDF_ProcessCCP_BudgetCap.isCriteriaMatching('10','40','Equal','DOUBLE');
            System.assertEquals(false,ruleResult);
            ruleResult = Core_MDF_ProcessCCP_BudgetCap.isCriteriaMatching('20','20','Not Equal','DOUBLE');
            System.assertEquals(false,ruleResult);  

            //testing validateRule method for data type PICKLIST with appropriate operators         
            ruleResult = Core_MDF_ProcessCCP_BudgetCap.isCriteriaMatching('50%','50%','Equal','PICKLIST');
            System.assertEquals(true,ruleResult);
            ruleResult = Core_MDF_ProcessCCP_BudgetCap.isCriteriaMatching('50%','30%','Not Equal','PICKLIST');
            System.assertEquals(true,ruleResult);
            ruleResult = Core_MDF_ProcessCCP_BudgetCap.isCriteriaMatching('50%','30%','Greater Than','PICKLIST');
            System.assertEquals(false,ruleResult);
            
            //testing validateRule method for data type CURRENCY with appropriate operators             
            ruleResult = Core_MDF_ProcessCCP_BudgetCap.isCriteriaMatching('5000','2000','Not Equal','CURRENCY');
            System.assertEquals(true,ruleResult);
            ruleResult = Core_MDF_ProcessCCP_BudgetCap.isCriteriaMatching('5000','5000','Equal','CURRENCY');
            System.assertEquals(true,ruleResult);
            ruleResult = Core_MDF_ProcessCCP_BudgetCap.isCriteriaMatching('5000','2000','Greater Than','CURRENCY');
            System.assertEquals(true,ruleResult);
            ruleResult = Core_MDF_ProcessCCP_BudgetCap.isCriteriaMatching('2000','5000','Less Than','CURRENCY');
            System.assertEquals(true,ruleResult);
            ruleResult = Core_MDF_ProcessCCP_BudgetCap.isCriteriaMatching('5000','4000','Greater Than or Equal','CURRENCY');
            System.assertEquals(true,ruleResult);
            ruleResult = Core_MDF_ProcessCCP_BudgetCap.isCriteriaMatching('4000','5000','Less Than or Equal','CURRENCY');
            System.assertEquals(true,ruleResult);
            
            //testing validateRule method for data type DATE with appropriate operators  
            ruleResult = Core_MDF_ProcessCCP_BudgetCap.isCriteriaMatching(String.valueOf(System.today().addDays(5)),String.valueOf(System.today()),
                                                                      'Greater Than','DATE');
            System.assertEquals(true,ruleResult);
            ruleResult = Core_MDF_ProcessCCP_BudgetCap.isCriteriaMatching(String.valueOf(System.today()),String.valueOf(System.today().addDays(5)),
                                                                      'Less Than','DATE');
            System.assertEquals(true,ruleResult);
            ruleResult = Core_MDF_ProcessCCP_BudgetCap.isCriteriaMatching(String.valueOf(System.today()),String.valueOf(System.today()),'Equal','DATE');
            System.assertEquals(true,ruleResult);
            ruleResult = Core_MDF_ProcessCCP_BudgetCap.isCriteriaMatching(String.valueOf(System.today()),String.valueOf(System.today()),'Not Equal',
                                                                      'DATE');
            System.assertEquals(false,ruleResult);
            ruleResult = Core_MDF_ProcessCCP_BudgetCap.isCriteriaMatching(String.valueOf(System.today()),String.valueOf(System.today()),
                                                                      'Greater Than or Equal','DATE');
            System.assertEquals(true,ruleResult);
            ruleResult = Core_MDF_ProcessCCP_BudgetCap.isCriteriaMatching(String.valueOf(System.today()),String.valueOf(System.today().addDays(1)),
                                                                      'Less Than or Equal','DATE');
            System.assertEquals(true,ruleResult);
            
            //testing validateRule method for data type MULTIPICKLIST with appropriate operators    
            ruleResult = Core_MDF_ProcessCCP_BudgetCap.isCriteriaMatching('ALBANIA;AUSTRALIA','ALBANIA;AUSTRALIA','Equal','MULTIPICKLIST');
            System.assertEquals(true,ruleResult);
            ruleResult = Core_MDF_ProcessCCP_BudgetCap.isCriteriaMatching('ALBANIA;AUSTRALIA','ALBANIA;AUSTRALIA','Not Equal','MULTIPICKLIST');
            System.assertEquals(false,ruleResult);
            ruleResult = Core_MDF_ProcessCCP_BudgetCap.isCriteriaMatching('ALBANIA;AUSTRALIA','ALBANIA;INDIA','Not Equal','MULTIPICKLIST');
            System.assertEquals(true,ruleResult);
            ruleResult = Core_MDF_ProcessCCP_BudgetCap.isCriteriaMatching('ALBANIA;AUSTRALIA','ALBANIA;INDIA','Equal','MULTIPICKLIST');
            System.assertEquals(false,ruleResult);
            ruleResult = Core_MDF_ProcessCCP_BudgetCap.isCriteriaMatching('ALBANIA','ALBANIA;AUSTRALIA','Equal','MULTIPICKLIST');
            System.assertEquals(false,ruleResult);
            ruleResult = Core_MDF_ProcessCCP_BudgetCap.isCriteriaMatching('ALBANIA;AUSTRALIA','ALBANIA;AUSTRALIA','Greater Than','MULTIPICKLIST');
            System.assertEquals(false,ruleResult);
            
            //testing validateRule method for data type TEXTAREA with appropriate operators
            ruleResult = Core_MDF_ProcessCCP_BudgetCap.isCriteriaMatching('Tset','Test','Equal','TEXTAREA');
            System.assertEquals(false,ruleResult);
            ruleResult = Core_MDF_ProcessCCP_BudgetCap.isCriteriaMatching('Test','Test','Equal','TEXTAREA');
            System.assertEquals(true,ruleResult);
            ruleResult = Core_MDF_ProcessCCP_BudgetCap.isCriteriaMatching('Test1','Test','Not Equal','TEXTAREA');
            System.assertEquals(true,ruleResult);
            ruleResult = Core_MDF_ProcessCCP_BudgetCap.isCriteriaMatching('Test1','Test','Not Equal','TESTFIELDTYPE');
            System.assertEquals(false,ruleResult);
            
            //testing validateRule method for data type all with appropriate IN,NOT In, Equla and Not Equal operators
            ruleResult = Core_MDF_ProcessCCP_BudgetCap.isCriteriaMatching('ALBANIA','ALBANIA;AUSTRALIA','In','MULTIPICKLIST');
            System.assertEquals(true,ruleResult); 
            ruleResult = Core_MDF_ProcessCCP_BudgetCap.isCriteriaMatching('ALBANIA;INDIA','ALBANIA;AUSTRALIA','In','MULTIPICKLIST');
            System.assertEquals(false,ruleResult);  
            ruleResult = Core_MDF_ProcessCCP_BudgetCap.isCriteriaMatching('ALBANIA;INDIA','ALBANIA;AUSTRALIA','Not In','MULTIPICKLIST');
            System.assertEquals(false,ruleResult);
            ruleResult = Core_MDF_ProcessCCP_BudgetCap.isCriteriaMatching('10','10','In','STRING');
            System.assertEquals(true,ruleResult);
            ruleResult = Core_MDF_ProcessCCP_BudgetCap.isCriteriaMatching('10;20','10','In','STRING');
            System.assertEquals(false,ruleResult);
            ruleResult = Core_MDF_ProcessCCP_BudgetCap.isCriteriaMatching(NULL,NULL,'In','STRING');
            System.assertEquals(true,ruleResult);
            ruleResult = Core_MDF_ProcessCCP_BudgetCap.isCriteriaMatching(NULL,'ALBANIA;AUSTRALIA','In','STRING');
            System.assertEquals(false,ruleResult);
            ruleResult = Core_MDF_ProcessCCP_BudgetCap.isCriteriaMatching(NULL,'ALBANIA;AUSTRALIA','Not In','STRING');
            System.assertEquals(true,ruleResult);
            ruleResult = Core_MDF_ProcessCCP_BudgetCap.isCriteriaMatching('ALBANIA','ALBANIA;AUSTRALIA','Not In','STRING');
            System.assertEquals(false,ruleResult);      
            ruleResult = Core_MDF_ProcessCCP_BudgetCap.isCriteriaMatching('INDIA','ALBANIA;AUSTRALIA','Not In','STRING');
            System.assertEquals(true,ruleResult);       
            ruleResult = Core_MDF_ProcessCCP_BudgetCap.isCriteriaMatching(NULL,NULL,'Not In','STRING');
            System.assertEquals(false,ruleResult);
            ruleResult = Core_MDF_ProcessCCP_BudgetCap.isCriteriaMatching('ALBANIA','ALBANIA;AUSTRALIA','In','MULTIPICKLIST');
            System.assertEquals(true,ruleResult);
            ruleResult = Core_MDF_ProcessCCP_BudgetCap.isCriteriaMatching('ALBANIA',NULL,'In','MULTIPICKLIST');
            System.assertEquals(false,ruleResult);
            ruleResult = Core_MDF_ProcessCCP_BudgetCap.isCriteriaMatching(NULL,'ALBANIA','In','MULTIPICKLIST');
            System.assertEquals(false,ruleResult);
            ruleResult = Core_MDF_ProcessCCP_BudgetCap.isCriteriaMatching(NULL,NULL,'In','MULTIPICKLIST');
            System.assertEquals(true,ruleResult);
            ruleResult = Core_MDF_ProcessCCP_BudgetCap.isCriteriaMatching(NULL,NULL,'Not In','MULTIPICKLIST');
            System.assertEquals(false,ruleResult);
            ruleResult = Core_MDF_ProcessCCP_BudgetCap.isCriteriaMatching('ALBANIA','ALBANIA;AUSTRALIA','Not In','MULTIPICKLIST');
            System.assertEquals(false,ruleResult);      
            ruleResult = Core_MDF_ProcessCCP_BudgetCap.isCriteriaMatching(NULL,'ALBANIA','Not In','MULTIPICKLIST');
            System.assertEquals(true,ruleResult);
            ruleResult = Core_MDF_ProcessCCP_BudgetCap.isCriteriaMatching(NULL,NULL,'Equal','MULTIPICKLIST');
            System.assertEquals(true,ruleResult);
            ruleResult = Core_MDF_ProcessCCP_BudgetCap.isCriteriaMatching('ALBANIA',NULL,'Equal','STRING');
            System.assertEquals(false,ruleResult);
            ruleResult = Core_MDF_ProcessCCP_BudgetCap.isCriteriaMatching(NULL,'ALBANIA','Equal','MULTIPICKLIST');
            System.assertEquals(false,ruleResult);
            ruleResult = Core_MDF_ProcessCCP_BudgetCap.isCriteriaMatching(NULL,NULL,'Not Equal','MULTIPICKLIST');
            System.assertEquals(false,ruleResult);
            ruleResult = Core_MDF_ProcessCCP_BudgetCap.isCriteriaMatching('ALBANIA',NULL,'Not Equal','STRING');
            System.assertEquals(true,ruleResult);
            ruleResult = Core_MDF_ProcessCCP_BudgetCap.isCriteriaMatching(NULL,'ALBANIA','Not Equal','MULTIPICKLIST');
            System.assertEquals(true,ruleResult); 
            ruleResult = Core_MDF_ProcessCCP_BudgetCap.isCriteriaMatching('INDIA','ALBANIA;AUSTRALIA','Not In','MULTIPICKLIST');
            System.assertEquals(true,ruleResult);       
          
            test.stopTest();
        }
    }
}