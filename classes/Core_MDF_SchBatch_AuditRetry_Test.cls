@isTest(SeeAllData=false)
private class Core_MDF_SchBatch_AuditRetry_Test {
    public static Map<Id,Decimal> pfcToRetryMap = new Map<Id,Decimal>{};
    public static List<PartnerFundClaim> pfcListToBeRetried = new List<PartnerFundClaim>();     
    @TestSetup static void setUpData(){
        
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        //Creating User with utility class 
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.LastName = 'User Test';
        usr.UserRoleId = usRole.Id;
        Database.insert(usr);
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
            ChannelProgram cp = Core_MDF_CCP_TestDataUtility.createProgram ('Client Co-Marketing Fund','Client CoMarketing Fund', true);
            
            // Creating IntelAccount with utility class
            Account acc1 = Core_MDF_CCP_TestDataUtility.createIntelAccount ('Test Account 1', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, 
                                                                            false);
            acc1.Core_Account_Type__c = 'Reseller';
            acc1.Core_Sales_Groups__c = 'Automotive Sales Group';
            acc1.Industry = 'Food & Beverage';
            acc1.Core_MDF_Channel_Program__c = cp.Id;
            acc1.Core_MDF_CoMarketingAgency__c=true;
            Database.insert(acc1);
            
            // Creating Co-marketing Account with utility class
            Account acc = Core_MDF_CCP_TestDataUtility.createAccount ('Co-marketing Test Account', cp.Id,
                                                                      Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            acc.Core_MDF_Parent_Fund_Account__c = acc1.Id;
            Database.insert(acc);  
            
            // Creating Contact with utility class
            Contact con = Core_MDF_CCP_TestDataUtility.createContact (acc1.Id, false);
            con.RecordTypeId = Core_MDF_CCP_TestDataUtility.Intel_Contact_Record_Type;
            Database.insert(con);
            
            Profile partnerProfile = [SELECT Id FROM Profile WHERE Name='Partner' LIMIT 1];
            
            // Creating User with utility class 
            User usr1 = Core_MDF_CCP_TestDataUtility.createUser(false);
            usr1.LastName = 'User Test1';
            usr1.ProfileId = partnerProfile.Id;
            usr1.ContactId = con.Id;
            Database.insert(usr1);
            
            // Creating campaigns using utility class
            Campaign camp = Core_MDF_CCP_TestDataUtility.createCampaign('TestCamp','Consumer','Intel® Corporate Logo', 
                                                                        Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF,
                                                                        'Client CoMarketing Fund',System.today().addDays(5) ,
                                                                        System.today().addYears(1), 2000, 'Unite',acc.Id,'2-in-1', true);
            
            // Creating Budget using utility class
            PartnerMarketingBudget pmb = Core_MDF_CCP_TestDataUtility.createBudget('Test Budget',Core_MDF_CCP_TestDataUtility.budget_Record_Type,
                                                                                   acc.Id,cp.Id,5000000,System.today(),System.today().addDays(110), 
                                                                                   true);
            
            // Creating Allocation using utility class
            PartnerFundAllocation pfa = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('Test Allocation',pmb,acc,1000000.0,true);
            
            // Creating activities using utility class
            PartnerFundRequest pfr = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(camp.Id),
                                                                                           Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,
                                                                                           string.valueof(acc.id),pfa,pmb,'INDIA','Small Business',
                                                                                           'Desktop','Intel® Core™ i7+ Processor','Broadcast',
                                                                                           'Radio','Draft',false);
            pfr.RequestedAmount = 900000;
            pfr.Amount = 900000;
            pfr.Status = 'Approved';
            pfr.AllocationId = pfa.Id;
            pfr.BudgetId = pmb.Id;
            pfr.Core_MDF_Start_Date__c = system.today();
            pfr.Core_MDF_End_Date__c = system.today();
            Database.insert(pfr);
            test.startTest();
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

            
            
            // Creating claims
            
            PartnerFundClaim claim1  = new PartnerFundClaim();
            claim1.Title='Test Claim';
            claim1.RequestId = pfr.Id;
            claim1.Core_MDF_Ad_Run_Start_Date__c = System.today();
            claim1.Core_MDF_Bank__c = bank.Id;
            claim1.Core_MDF_Ad_Run_End_Date__c = System.today();
            claim1.Core_MDF_Media_Vehicle__c='test';
            claim1.Core_MDF_Invoice_Number__c = '1121';
            claim1.Core_MDF_Invoice_Date__c = System.today();
            claim1.Core_MDF_Total_Invoice_Amount_Local__c=6000;
            claim1.Core_MDF_OtherCostsnotReimbursable_Local__c = 0;
            claim1.Core_MDF_Taxes_Local__c = 0;
            claim1.Core_MDF_Currency__c = 'USD';
            
            newClmList.add(claim1);
            Database.insert(claim1);
            
            list<PartnerFundClaim> claims = [SELECT Id, Title, Core_MDF_Program__c,Core_MDF_Predictive_Audit_Retries__c,Core_MDF_Predictive_Audit_Error__c,Core_MDF_AuditSelectionInProgress__c,Core_MDF_Exchange_rate__c FROM PartnerFundClaim WHERE Title LIKE 'Test Claim%' LIMIT 2];
            
            for(PartnerFundClaim pfc:claims){
                pfc.Core_MDF_Predictive_Audit_Error__c = true;
                pfc.Core_MDF_AuditSelectionInProgress__c = true;
                pfc.Core_MDF_Predictive_Audit_Retries__c = pfc.Core_MDF_Predictive_Audit_Retries__c + 1;
                pfcListToBeRetried.add(pfc);
                
            }
            Database.update(pfcListToBeRetried);
            //Test.startTest();
            for(PartnerFundClaim p:pfcListToBeRetried){
                pfcToRetryMap.put(p.Id,p.Core_MDF_Predictive_Audit_Retries__c);
            }
            Test.stopTest();           
           
        }
    }
        
        
        @isTest static void testSchedulerMethod(){
            test.startTest();
            Core_MDF_SchBatch_AuditRetry batchProcess=new Core_MDF_SchBatch_AuditRetry();
            batchProcess.execute(null);
            Test.stopTest();
            system.debug('Into Assert for schedular test method1 :');           
            list<PartnerFundClaim> claimsUpdated = [select Id,Core_MDF_Audit_Type__c,Core_MDF_FlaggedForAudit__c,Core_MDF_Audit_Hold__c,Core_MDF_Status__c,Core_MDF_AuditSelectionInProgress__c,Core_MDF_Predictive_Audit_Error__c,Core_MDF_Predictive_Audit_Retries__c,Core_MDF_Pred_ModelTimeStamp__c,Core_MDF_Pred_PredictionResult__c,Core_MDF_Pred_PredictionScore__c,Core_MDF_Pred_Probability__c,Core_MDF_Pred_ThresholdFlag__c,Core_MDF_Pred_IdealModelResult__c from partnerfundclaim where id in : pfcListToBeRetried];
            system.debug('claimsUpdated:'+claimsUpdated);
            for(integer i=0;i<claimsUpdated.size();i++){
                
                if(pfcToRetryMap.containsKey(claimsUpdated[i].Id) && claimsUpdated[i].Core_MDF_Predictive_Audit_Error__c)
                    System.AssertEquals(pfcToRetryMap.get(claimsUpdated[i].Id)+1,claimsUpdated[i].Core_MDF_Predictive_Audit_Retries__c);
                else
                    System.AssertEquals(false,claimsUpdated[i].Core_MDF_Predictive_Audit_Error__c);

        }
        
    }
    
    
  
    /*@isTest static void testSchedulerMethod(){  
        Profile systemAdminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator' LIMIT 1];
        // Creating User with utility class 
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.profileId = systemAdminProfile.Id;
        insert usr;
        
        
        System.runAs(usr){
            Test.startTest();
            
            //create pfc
            list<PartnerFundClaim> claims = [SELECT Id, Title, Core_MDF_Program__c,Core_MDF_Predictive_Audit_Retries__c,Core_MDF_Predictive_Audit_Error__c,Core_MDF_AuditSelectionInProgress__c,Core_MDF_Exchange_rate__c FROM PartnerFundClaim WHERE Title LIKE 'Test Claim%' LIMIT 2];
            List<PartnerFundClaim> pfcListToBeRetried = new List<PartnerFundClaim>();
            Map<Id,Decimal> pfcToRetryMap = new Map<Id,Decimal>{};
            for(PartnerFundClaim pfc:claims){
                pfc.Core_MDF_Predictive_Audit_Error__c = true;
                pfc.Core_MDF_AuditSelectionInProgress__c = true;
                pfc.Core_MDF_Predictive_Audit_Retries__c = pfc.Core_MDF_Predictive_Audit_Retries__c + 1;
                pfcListToBeRetried.add(pfc);
                pfcToRetryMap.put(pfc.Id,pfc.Core_MDF_Predictive_Audit_Retries__c);
            }
            Database.update(pfcListToBeRetried);
            
            Core_MDF_SchBatch_AuditRetry scheduleReprocess = new Core_MDF_SchBatch_AuditRetry();
            String sch = '0 0 6 * * ? ';
            System.schedule('Test Audit Retry Batch Status Check', sch, scheduleReprocess);
            Test.stopTest();
            
            //Campaign cmpUpdatedToInProgress =  [SELECT Id, Status from Campaign WHERE Id =:cmpToBeUpdatedToInProgress.Id];  
            //system.debug('cmpUpdatedToInProgress:' + cmpUpdatedToInProgress);
            list<PartnerFundClaim> claimsUpdated = [select Id,Core_MDF_Audit_Type__c,Core_MDF_FlaggedForAudit__c,Core_MDF_Audit_Hold__c,Core_MDF_Status__c,Core_MDF_AuditSelectionInProgress__c,Core_MDF_Predictive_Audit_Error__c,Core_MDF_Predictive_Audit_Retries__c,Core_MDF_Pred_ModelTimeStamp__c,Core_MDF_Pred_PredictionResult__c,Core_MDF_Pred_PredictionScore__c,Core_MDF_Pred_Probability__c,Core_MDF_Pred_ThresholdFlag__c,Core_MDF_Pred_IdealModelResult__c from partnerfundclaim where id in : claims];
            for(integer i=0;i<claimsUpdated.size();i++){
                
                if(pfcToRetryMap.containsKey(claimsUpdated[i].Id) && claimsUpdated[i].Core_MDF_Predictive_Audit_Error__c)
                    System.AssertEquals(pfcToRetryMap.get(claimsUpdated[i].Id)+1,claimsUpdated[i].Core_MDF_Predictive_Audit_Retries__c);
                else
                    System.AssertEquals(false,claimsUpdated[i].Core_MDF_Predictive_Audit_Error__c);
            }
        }
        
    }*/
}