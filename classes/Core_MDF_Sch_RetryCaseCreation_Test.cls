@isTest(SeeAllData=false)
private class Core_MDF_Sch_RetryCaseCreation_Test {
    public static List<String> audHoldClaimIds = new List<String>();            
    @TestSetup static void setUpData(){
        
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        //Creating User with utility class 
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.LastName = 'User Test';
        usr.UserRoleId = usRole.Id;
        Database.insert(usr);
        
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
            ChannelProgram cp = Core_MDF_CCP_TestDataUtility.createProgram ('Service Provider Co-Marketing Fund','Service Provider CoMarketing Fund', true);
            
            // Creating IntelAccount with utility class
            Account acc1 = Core_MDF_CCP_TestDataUtility.createIntelAccount ('Test Account 1', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, 
                                                                            true);
            
            // Creating Contact with utility class
            Contact con = Core_MDF_CCP_TestDataUtility.createContact (acc1.Id, false);
            Database.insert(con);
                        
            Id profileId = [SELECT Id FROM Profile WHERE Name='Partner' limit 1].Id;
            
            // Creating User with utility class 
            User usr1 = Core_MDF_CCP_TestDataUtility.createUser(false);
            usr1.LastName = 'User Test1';
            usr1.Email='test1@example.com';
            usr1.ProfileId = profileId;
            usr1.ContactId = con.Id;
            usr1.isActive = true;
            Database.insert(usr1);
            
            // Creating Co-marketing Account with utility class
            Account acc = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Co-marketing Test Account', cp.Id,
                                                                                Core_MDF_CCP_TestDataUtility.Account_Record_Type, acc1.Id, true);
            
            // Creating Budget using utility class
            PartnerMarketingBudget pmb = Core_MDF_CCP_TestDataUtility.createBudget('Test Budget New',Core_MDF_CCP_TestDataUtility.budget_Record_Type,
                                                                                      acc.Id,cp.Id,200000,System.today().addDays(-20),System.today().addDays(40), true);
            
            // Creating Allocation using utility class
            PartnerFundAllocation pfa = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('Test Allocation',pmb,acc,100000.0,true);
            
            // Creating campaigns using utility class
            Campaign camp = Core_MDF_CCP_TestDataUtility.createCampaign('TestCamp','Consumer','Intel® Corporate Logo', 
                                                                        Core_MDF_CCP_TestDataUtility.Campaign_RecordType_SPCF,
                                                                        'Service Provider CoMarketing Fund',System.today().addDays(-15), 
                                                                        System.today().addDays(15), 2000, 'Unite',acc.Id,'Cloud', true);
            
            
            // Creating activities using utility class
            PartnerFundRequest pfr = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(camp.Id),
                                                                                           Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_SPCF,
                                                                                           string.valueof(acc.id),pfa,pmb,'INDIA','Small Business',
                                                                                           'Cloud','Intel® Corporate Logo',
                                                                                           'Broadcast','Podcast','Draft',false);
            pfr.RequestedAmount = 90000;
            pfr.Amount = 90000;
            pfr.Status = 'Approved';
            pfr.AllocationId = pfa.Id;
            pfr.BudgetId = pmb.Id;
            pfr.Core_MDF_Start_Date__c = system.today().addDays(-5);
            pfr.Core_MDF_End_Date__c = system.today().addDays(5);
            Database.insert(pfr);
            
            Test.startTest();
            // Creating Bank
            Core_MDF_Bank__c bank = Core_MDF_CCP_TestDataUtility.createBank(acc1.id,'Core_MDF_Service_Provider_CoMarketing_Fund',true,'1234567890');
            bank.Core_MDF_Bank_Alias_Name__c='TestActiveBank1';
            Database.update(bank);
            
            //creating ABM for bank1
            Core_MDF_Account_Bank_Mapping__c abm1 = Core_MDF_CCP_TestDataUtility.createAccountBankMap(acc.Id,bank.Id,true);
            
            // Create claims
            PartnerFundClaim pfc  = new PartnerFundClaim();
            pfc.RecordTypeId = Core_MDF_CCP_TestDataUtility.claim_RecordType_SPCF;
            pfc.Title = 'Test Claim';
            pfc.RequestId = pfr.Id;
            pfc.Core_MDF_Total_Invoice_Amount_Local__c = 400;
            pfc.Core_MDF_FlaggedForAudit__c = false;
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
            pfc.Core_MDF_Country_Location_nm__c ='INDIA';
            Database.insert(pfc);            
            
            PartnerFundClaim claims = [SELECT Id,Core_MDF_Status__c,Core_MDF_Claim_Review_Case__c, Core_MDF_Country_Location_nm__c,Title, Core_MDF_Program__c FROM PartnerFundClaim WHERE Title LIKE 'Test Claim' LIMIT 1];
            Test.stopTest();
            system.debug('claims:'+claims);
            claims.Core_MDF_Status__c = 'Hold';
            claims.Core_MDF_Audit_Hold__c=true;
            claims.Core_MDF_Audit_Type__c = 'Random';
            Database.update(claims);
                                    
			List<Core_MDF_Audit_Hold_Claim__c> audHoldClaims = [SELECT Id,Name,Core_MDF_Retry_Indicator__c,Core_MDF_Status__c,Core_MDF_Claim_Id__c,Createddate FROM Core_MDF_Audit_Hold_Claim__c WHERE Name LIKE 'Test Claim%' LIMIT 1];
             system.debug('audHoldClaims:'+audHoldClaims);
                Datetime yesterday = Datetime.now().addDays(-1);
                
           //insert the claims in Core_MDF_Audit_Hold_Claim__c in not already there.
                
            if(audHoldClaims.size() == 0 || audHoldClaims[0].Core_MDF_Claim_Id__c != String.valueOf(claims.Id)){
                Core_MDF_Audit_Hold_Claim__c newAudHoldClaim = new Core_MDF_Audit_Hold_Claim__c();
                newAudHoldClaim.Core_MDF_Claim_Id__c = String.valueOf(claims.Id);
                newAudHoldClaim.Name = claims.Title;
                newAudHoldClaim.Core_MDF_Retry_Indicator__c = 0;
                newAudHoldClaim.Core_MDF_Status__c = 'Pending';
                insert newAudHoldClaim;                
                Test.setCreatedDate(newAudHoldClaim.Id, yesterday);
                audHoldClaimIds.add(newAudHoldClaim.Core_MDF_Claim_Id__c);          
                }
            else{
                Test.setCreatedDate(audHoldClaims[0].Id, yesterday);
                audHoldClaimIds.add(audHoldClaims[0].Core_MDF_Claim_Id__c);
            }  
            
              system.debug('audHoldClaimIds:'+audHoldClaimIds); 
        }
    }
        
        
       @isTest static void testSchedulerMethodForPending(){                             
           List<Core_MDF_Audit_Hold_Claim__c> pendingBatchRec = [SELECT Id,Name,Core_MDF_Retry_Indicator__c,Core_MDF_Status__c,Core_MDF_Claim_Id__c,Createddate FROM Core_MDF_Audit_Hold_Claim__c WHERE Name LIKE 'Test Claim%' LIMIT 1];
            Core_MDF_Scheduler_RetryCaseCreation batchProcessCaseCreation=new Core_MDF_Scheduler_RetryCaseCreation(); 
			
            if(pendingBatchRec.size()>0){
            System.AssertEquals(pendingBatchRec[0].Core_MDF_Status__c,'Pending');
            test.startTest();
            batchProcessCaseCreation.execute(null);
            Test.stopTest();
            }
            List<Core_MDF_Audit_Hold_Claim__c> processingBatchRec = [SELECT Id,Name,Core_MDF_Retry_Indicator__c,Core_MDF_Status__c,Core_MDF_Claim_Id__c,Createddate FROM Core_MDF_Audit_Hold_Claim__c WHERE Name LIKE 'Test Claim%' LIMIT 1];
            if(processingBatchRec.size()>0){
                System.AssertEquals(processingBatchRec[0].Core_MDF_Status__c,'Processing'); }           
           
           /*List<Core_MDF_Audit_Hold_Claim__c> processingBatchRec1 = [SELECT Id,Name,Core_MDF_Retry_Indicator__c,Core_MDF_Status__c,Core_MDF_Claim_Id__c,Createddate FROM Core_MDF_Audit_Hold_Claim__c WHERE Name LIKE 'Test Claim%' LIMIT 1];

           processingBatchRec1[0].Core_MDF_Retry_Indicator__c = 1;
           update processingBatchRec1[0];*/
           PartnerFundClaim claims1 = [SELECT Id,Core_MDF_Claim_Review_Case__c FROM PartnerFundClaim WHERE Title LIKE 'Test Claim%' LIMIT 1];
        
           Id caseAuditRecordId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Core_MDF_Audit').getRecordTypeId();       
            Case testCase= new Case();
            testCase.recordtypeid = caseAuditRecordId;
            testCase.Status = 'Open';
            testCase.Core_MDF_Adjustment_Amount_Local__c =0;
            testCase.Core_MDF_Claim_Conversion_Exchange_Rate__c = 1;
            testCase.Core_MDF_Reimbursement_Rate__c = 50;
            testCase.Core_MDF_Status__c ='Under Review';
            testCase.Core_MDF_Claim_Id__c = claims1.Id;
            Database.insert(testCase);
           
           Core_MDF_Audit_Document__c aDoc =  new Core_MDF_Audit_Document__c();
                /*aDoc.Core_MDF_Proof_of_Branding__c = true;
                aDoc.Core_MDF_Proof_of_Cost__c = true;
                aDoc.Core_MDF_Proof_of_Execution__c = true;*/
           		aDoc.Core_MDF_Document_Types__c = 'Proof of Cost;Proof of Branding;Proof of Execution';
        		aDoc.Core_MDF_App_Document_Types_nm__c = 'Proof of Cost;Proof of Branding;Proof of Execution';
                aDoc.Core_MDF_Audit__c = testCase.Id;
                aDoc.Core_MDF_Claim__c = claims1.Id;
                insert aDoc;
           
            batchProcessCaseCreation.execute(null);
           
           claims1.Core_MDF_Claim_Review_Case__c=null;
           update claims1;
           batchProcessCaseCreation.execute(null);
           }
    
    @isTest static void testSchedulerMethodForFailed(){
        Core_MDF_Scheduler_RetryCaseCreation batchProcessCaseCreation=new Core_MDF_Scheduler_RetryCaseCreation();                                           
        List<Core_MDF_Audit_Hold_Claim__c> beforeRunUpdate = [SELECT Id,Name,Core_MDF_Retry_Indicator__c,Core_MDF_Status__c,Core_MDF_Claim_Id__c,Createddate FROM Core_MDF_Audit_Hold_Claim__c WHERE Name LIKE 'Test Claim%' LIMIT 1];
        beforeRunUpdate[0].Core_MDF_Retry_Indicator__c = 2;
        update beforeRunUpdate[0];
        test.startTest();
        batchProcessCaseCreation.execute(null);
        Test.stopTest();
        List<Core_MDF_Audit_Hold_Claim__c> failedBatchRec = [SELECT Id,Name,Core_MDF_Retry_Indicator__c,Core_MDF_Status__c,Core_MDF_Claim_Id__c,Createddate FROM Core_MDF_Audit_Hold_Claim__c WHERE Name LIKE 'Test Claim%' LIMIT 1];
        system.debug('failedBatchRec:'+failedBatchRec);
        if(failedBatchRec.size()>0){
        System.AssertEquals(failedBatchRec[0].Core_MDF_Status__c,'Failed');            
        }              
    }
    
   @isTest static void testSchedulerMethodForProcessing(){
        Core_MDF_Scheduler_RetryCaseCreation batchProcessCaseCreation1=new Core_MDF_Scheduler_RetryCaseCreation();                                           
        List<Core_MDF_Audit_Hold_Claim__c> beforeRunUpdate1 = [SELECT Id,Name,Core_MDF_Retry_Indicator__c,Core_MDF_Status__c,Core_MDF_Claim_Id__c,Createddate FROM Core_MDF_Audit_Hold_Claim__c WHERE Name LIKE 'Test Claim%' LIMIT 1];
        beforeRunUpdate1[0].Core_MDF_Retry_Indicator__c = 1;
        beforeRunUpdate1[0].Core_MDF_Status__c = 'Processing';
        update beforeRunUpdate1[0];
        test.startTest();
        batchProcessCaseCreation1.execute(null);
      	
        Test.stopTest();
        List<Core_MDF_Audit_Hold_Claim__c> processingBatchRec = [SELECT Id,Name,Core_MDF_Retry_Indicator__c,Core_MDF_Status__c,Core_MDF_Claim_Id__c,Createddate FROM Core_MDF_Audit_Hold_Claim__c WHERE Name LIKE 'Test Claim%' LIMIT 1];
        if(processingBatchRec.size()>0){
        System.AssertEquals(processingBatchRec[0].Core_MDF_Status__c,'Processing');            
        }              
       
       
    } 
    
}