/****************************************************************************************************************************************
* Class Name  : Core_MDF_UpdateClaim_Test 
* Version     : 1.0 
* Created Date: 04-30-2019
* Modification Log :
* Developer                     Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture – Sai Sugathri N   04-30-2019                   Created Core_MDF_UpdateClaim_Test to test the flow functionality.
*****************************************************************************************************************************************/
@isTest
public class Core_MDF_UpdateClaim_Test{

public static Id contactId; 
/****************************************************************************************************************************************
Method Name:                                             testCaseToClaimFlow
Description:                                             Updating Case status to test Functionality of UpdateClaim Flow.
Added By:                                                Accenture – Sai Sugathri N  - 04-30-2019
Modified By:                  Date:                      Changes: 
Accenture – Sai Sugathri N   04-30-2019                  Created.
*****************************************************************************************************************************************/
    
    @TestSetup static void insertTestRec() {
        
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        //Creating User with utility class 
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.LastName = 'User Test';
        usr.UserRoleId = usRole.Id;
        Database.insert(usr);
        List<PartnerFundClaim> newClmList = new List<PartnerFundClaim>();
        
        System.runAs(usr){
            
            //Creating Trigger Excecution Custom Setting record to 
            Core_Trigger_Executions__c claimToCase = new Core_Trigger_Executions__c();
            claimToCase.Core_Active__c = true;
            claimToCase.Core_Class_Name__c = 'Core_MDF_PFCServiceHandler';
            claimToCase.Core_Description__c = 'This Custom Setting is used to turn on/off claim to case functionality.';
            claimToCase.Core_Object__c = 'PartnerFundClaim';
            claimToCase.Core_Trigger_Events__c = 'after update';
            claimToCase.Name='Core_MDF_ClaimToCase';        
            Database.insert(claimToCase);                       
            
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
            contactId = con.Id;
            
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
                                                                        System.today().addDays(200), 2000, 'Unite',acc.Id,'2-in-1', true);
            
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
            List<PartnerFundClaim> toBeInsertedClaims= new List<PartnerFundClaim>();             
            PartnerFundClaim pfc  = new PartnerFundClaim();
            pfc.RecordTypeId = Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF;
            pfc.Title = 'Test Claim';
            pfc.RequestId = pfr.Id;
            pfc.Core_MDF_Total_Invoice_Amount_Local__c = 20000;        
            pfc.Core_MDF_Audit_Hold__c = true;                 
            pfc.Core_MDF_Status__c = 'Submitted';
            pfc.Description = 'Test PFC ';
            //pfc.Core_MDF_FlaggedForAudit__c = true;
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
            
            PartnerFundClaim pfc1  = new PartnerFundClaim();
            pfc1.RecordTypeId = Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF;
            pfc1.Title = 'Test Claim1';
            pfc1.RequestId = pfr.Id;
            pfc1.Core_MDF_Total_Invoice_Amount_Local__c = 20000;        
            pfc1.Core_MDF_Audit_Hold__c = true;                 
            pfc1.Core_MDF_Status__c = 'Submitted';
            pfc1.Description = 'Test PFC ';
            //pfc.Core_MDF_FlaggedForAudit__c = true;
            pfc1.Core_MDF_Ad_Run_Start_Date__c = System.today();
            pfc1.Core_MDF_Ad_Run_End_Date__c = System.today();
            pfc1.Core_MDF_Invoice_Date__c = System.today();
            pfc1.Core_MDF_Invoice_Number__c = '1121';
            pfc1.Core_MDF_Media_Vehicle__c = 'test';
            pfc1.Core_MDF_OtherCostsnotReimbursable_Local__c = 0;
            pfc1.Core_MDF_Taxes_Local__c = 0;
            pfc1.Core_MDF_Currency__c = 'USD';
            pfc1.Core_MDF_Exchange_rate__c = 1;
            pfc1.Core_MDF_Bank__c = bank.Id; 
            
            
            PartnerFundClaim pfc2  = new PartnerFundClaim();
            pfc2.RecordTypeId = Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF;
            pfc2.Title = 'Test Claim2';
            pfc2.RequestId = pfr.Id;
            pfc2.Core_MDF_Total_Invoice_Amount_Local__c = 20000;        
            pfc2.Core_MDF_Audit_Hold__c = true;                 
            pfc2.Core_MDF_Status__c = 'Submitted';
            pfc2.Description = 'Test PFC ';
            //pfc.Core_MDF_FlaggedForAudit__c = true;
            pfc2.Core_MDF_Ad_Run_Start_Date__c = System.today();
            pfc2.Core_MDF_Ad_Run_End_Date__c = System.today();
            pfc2.Core_MDF_Invoice_Date__c = System.today();
            pfc2.Core_MDF_Invoice_Number__c = '1121';
            pfc2.Core_MDF_Media_Vehicle__c = 'test';
            pfc2.Core_MDF_OtherCostsnotReimbursable_Local__c = 0;
            pfc2.Core_MDF_Taxes_Local__c = 0;
            pfc2.Core_MDF_Currency__c = 'USD';
            pfc2.Core_MDF_Exchange_rate__c = 1;
            pfc2.Core_MDF_Bank__c = bank.Id;   
                     
            //Creating Claim data to handle Paid Claim scenario
            PartnerFundClaim pfc3  = new PartnerFundClaim();
            pfc3.RecordTypeId = Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF;
            pfc3.Title = 'Test Claim3';
            pfc3.RequestId = pfr.Id;
            pfc3.Core_MDF_Total_Invoice_Amount_Local__c = 20000;        
            pfc3.Core_MDF_Audit_Hold__c = true;                 
            pfc3.Core_MDF_Status__c = 'Submitted';
            pfc3.Description = 'Test PFC ';
            //pfc.Core_MDF_FlaggedForAudit__c = true;
            pfc3.Core_MDF_Ad_Run_Start_Date__c = System.today();
            pfc3.Core_MDF_Ad_Run_End_Date__c = System.today();
            pfc3.Core_MDF_Invoice_Date__c = System.today();
            pfc3.Core_MDF_Invoice_Number__c = '1121';
            pfc3.Core_MDF_Media_Vehicle__c = 'test';
            pfc3.Core_MDF_OtherCostsnotReimbursable_Local__c = 0;
            pfc3.Core_MDF_Taxes_Local__c = 0;
            pfc3.Core_MDF_Currency__c = 'USD';
            pfc3.Core_MDF_Exchange_rate__c = 1;
            pfc3.Core_MDF_Bank__c = bank.Id;    
            
            PartnerFundClaim pfc4  = new PartnerFundClaim();
            pfc4.RecordTypeId = Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF;
            pfc4.Title = 'Test Claim4';
            pfc4.RequestId = pfr.Id;
            pfc4.Core_MDF_Total_Invoice_Amount_Local__c = 20000;        
            pfc4.Core_MDF_Audit_Hold__c = true;                 
            pfc4.Core_MDF_Status__c = 'Submitted';
            pfc4.Description = 'Test PFC ';
            //pfc.Core_MDF_FlaggedForAudit__c = true;
            pfc4.Core_MDF_Ad_Run_Start_Date__c = System.today();
            pfc4.Core_MDF_Ad_Run_End_Date__c = System.today();
            pfc4.Core_MDF_Invoice_Date__c = System.today();
            pfc4.Core_MDF_Invoice_Number__c = '1121';
            pfc4.Core_MDF_Media_Vehicle__c = 'test';
            pfc4.Core_MDF_OtherCostsnotReimbursable_Local__c = 0;
            pfc4.Core_MDF_Taxes_Local__c = 0;
            pfc4.Core_MDF_Currency__c = 'USD';
            pfc4.Core_MDF_Exchange_rate__c = 1;
            pfc4.Core_MDF_Bank__c = bank.Id;    
            
            PartnerFundClaim pfc5  = new PartnerFundClaim();
            pfc5.RecordTypeId = Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF;
            pfc5.Title = 'Test Claim5';
            pfc5.RequestId = pfr.Id;
            pfc5.Core_MDF_Total_Invoice_Amount_Local__c = 20000;        
            pfc5.Core_MDF_Audit_Hold__c = true;                 
            pfc5.Core_MDF_Status__c = 'Submitted';
            pfc5.Description = 'Test PFC ';
            //pfc.Core_MDF_FlaggedForAudit__c = true;
            pfc5.Core_MDF_Ad_Run_Start_Date__c = System.today();
            pfc5.Core_MDF_Ad_Run_End_Date__c = System.today();
            pfc5.Core_MDF_Invoice_Date__c = System.today();
            pfc5.Core_MDF_Invoice_Number__c = '1121';
            pfc5.Core_MDF_Media_Vehicle__c = 'test';
            pfc5.Core_MDF_OtherCostsnotReimbursable_Local__c = 0;
            pfc5.Core_MDF_Taxes_Local__c = 0;
            pfc5.Core_MDF_Currency__c = 'USD';
            pfc5.Core_MDF_Exchange_rate__c = 1;
            pfc5.Core_MDF_Bank__c = bank.Id;    
            
            toBeInsertedClaims.add(pfc);
            toBeInsertedClaims.add(pfc1);
            toBeInsertedClaims.add(pfc2);
            toBeInsertedClaims.add(pfc3);
            toBeInsertedClaims.add(pfc4);
            toBeInsertedClaims.add(pfc5);
            Database.insert(toBeInsertedClaims);
            
            Test.stopTest();
            
            //Updating Claims which are not selected for Audit
            List<PartnerFundClaim> claimListToBeUpdated = new List<PartnerFundClaim>();

            for(PartnerFundClaim pfc6: [SELECT Id, Title, Core_MDF_Claim_Review_Case__c,Core_MDF_FlaggedForAudit__c
                                        FROM PartnerFundClaim WHERE Title IN ('Test Claim','Test Claim1','Test Claim2', 'Test Claim3','Test Claim4','Test Claim5') 
                                        AND Core_MDF_FlaggedForAudit__c = false]){
                                            
                                            pfc6.Core_MDF_FlaggedForAudit__c = true;  
                                            if(pfc6.Title == 'Test Claim3' || pfc6.Title == 'Test Claim4' || pfc6.Title == 'Test Claim5'){
                                                
                                                pfc6.Core_MDF_Status__c = 'Paid';
                                            }
                                            claimListToBeUpdated.add(pfc6);                                                                                                                          
            }
            
            if(claimListToBeUpdated.size() > 0 ){

                Database.update(claimListToBeUpdated);

            }                       
        }
    }
    
    @isTest static void testCaseToClaimFlow(){
        List<Case> caseListToBeUpdated = new List<Case>();  
        List<Case> caseListToBeUpdated1 = new List<Case>();        

        Integer temp = 1;
        Integer count = 1;

        Id nonCompliantClaimId;
        Id compliantClaimId1;
        Id compliantClaimId2;
        
        Id nonCompliantClaimId1;
        Id compliantClaimId3;
        Id compliantClaimId4;
        Contact cnct = [Select Id from Contact limit 5];

        //Setting the case status as either compliant or non compliant
        
        for(PartnerFundClaim pfc: [SELECT Id, Core_MDF_Claim_Review_Case__c,Core_MDF_FlaggedForAudit__c
                                   FROM PartnerFundClaim WHERE Title IN ('Test Claim','Test Claim1','Test Claim2') 
                                   AND (Core_MDF_Claim_Review_Case__c != null AND Core_MDF_FlaggedForAudit__c = true)]){
                                       
                                       Case caseInstance = new Case();
                                       
                                       caseInstance.Id = pfc.Core_MDF_Claim_Review_Case__c;
                                       caseInstance.ContactId = cnct.Id;
                                       caseInstance.Core_MDF_Status__c = 'Under Review';
                                       if(temp == 1){
                                           caseInstance.Core_MDF_Review_Case_Status__c = 'Non-compliant';
                                           nonCompliantClaimId = pfc.Id;
                                           caseInstance.Core_MDF_Checklist_Completion__c  = 100;
                                       }
                                       if(temp == 2){
                                           caseInstance.Core_MDF_Review_Case_Status__c = 'Compliant';
                                           caseInstance.Core_MDF_Adjustment_Amount_Local__c = 100;
                                           caseInstance.Core_MDF_Checklist_Completion__c  = 100;
                                           compliantClaimId1 = pfc.Id;
                                       }
                                       if(temp == 3){
                                           caseInstance.Core_MDF_Review_Case_Status__c = 'Compliant';
                                           caseInstance.Core_MDF_Adjustment_Amount_Local__c = 0;
                                           caseInstance.Core_MDF_Checklist_Completion__c  = 100;
                                           compliantClaimId2 = pfc.Id;
                                       }           
                                       temp++;
                                       caseListToBeUpdated.add(caseInstance);                                                                               
                                   }
                                   
        
        //Setting the Case status as either compliant or non compliant for Paid Claim

         for(PartnerFundClaim pfcWithPaid: [SELECT Id, Core_MDF_Claim_Review_Case__c,Core_MDF_FlaggedForAudit__c
                                   FROM PartnerFundClaim WHERE Title IN ('Test Claim3','Test Claim4','Test Claim5') 
                                   AND (Core_MDF_Claim_Review_Case__c != null AND Core_MDF_FlaggedForAudit__c = true AND Core_MDF_Status__c = 'Paid')]){
                                       
                                       Case caseInstance1 = new Case();
                                       caseInstance1.Core_MDF_Checklist_Completion__c  = 100;
                                       caseInstance1.Id = pfcWithPaid.Core_MDF_Claim_Review_Case__c;
                                       caseInstance1.ContactId = cnct.Id;
                                       //caseInstance1.Core_MDF_Status__c = 'Under Review';
                                       if(count == 1){
                                           caseInstance1.Core_MDF_Review_Case_Status__c = 'Non-compliant';
                                           nonCompliantClaimId1 = pfcWithPaid.Id;
                                       }
                                       if(count == 2){
                                           caseInstance1.Core_MDF_Review_Case_Status__c = 'Compliant';
                                           caseInstance1.Core_MDF_Adjustment_Amount_Local__c = 100;
                                           compliantClaimId3 = pfcWithPaid.Id;
                                       }
                                       if(count == 3){
                                           caseInstance1.Core_MDF_Review_Case_Status__c = 'Compliant';
                                           caseInstance1.Core_MDF_Adjustment_Amount_Local__c = 0;
                                           compliantClaimId4 = pfcWithPaid.Id;
                                       }           
                                       count++;
                                       caseListToBeUpdated.add(caseInstance1);  
                                       
                                       
                                   }
                            
        Test.startTest();
        
        List<Core_MDF_Claim_Case_Checklist__c> checkListToBeUpdated = new List<Core_MDF_Claim_Case_Checklist__c>();
        
        if(caseListToBeUpdated.size() > 0){
            for(Core_MDF_Claim_Case_Checklist__c checkList : [select Core_MDF_Completion_Percentage__c,Core_MDF_Case_ID__c from Core_MDF_Claim_Case_Checklist__c 
                                                                where Core_MDF_Case_ID__c =: caseListToBeUpdated] ){
                                                                checkList.Core_MDF_Completion_Percentage__c = 100;  
                                                                checkListToBeUpdated.add(checkList);
            }
            if(checkListToBeUpdated.size()>0){
                Database.update(checkListToBeUpdated); 
                Database.update(caseListToBeUpdated); 
            }
            
        }           
               
        Test.stopTest();
        
        for (PartnerFundClaim pfc : [SELECT Id, Core_MDF_Status__c, Core_MDF_Audit_Hold__c, Core_MDF_Audit_Adjustment_Amount__c from PartnerFundClaim WHERE Id =: nonCompliantClaimId OR
                                     Id=: compliantClaimId1 OR Id=: compliantClaimId2]){
                                         if(pfc.Id==nonCompliantClaimId) {                           
                                             System.assertEquals('Denied', pfc.Core_MDF_Status__c);
                                             System.assertEquals(False, pfc.Core_MDF_Audit_Hold__c);
                                         }
                                         if(pfc.Id==CompliantClaimId1) {                           
                                             System.assertEquals(False, pfc.Core_MDF_Audit_Hold__c);                                                              
                                             System.assertEquals(100, pfc.Core_MDF_Audit_Adjustment_Amount__c );
                                         }
                                         if(pfc.Id==CompliantClaimId2) {                           
                                             System.assertEquals(0, pfc.Core_MDF_Audit_Adjustment_Amount__c ); 
                                         }   
                         
        }
        
        Case cs = new Case();
        Id caseAuditRecType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Core_MDF_Audit').getRecordTypeId();
        cs.Status = 'New';
        cs.recordTypeId = caseAuditRecType;
        cs.ContactId = contactId;
        insert cs;
        
        cs.Core_MDF_Status__c = 'Pending Documents';
        update cs;
        
        cs.Core_MDF_Status__c = 'Cancelled';
        update cs;      
        
    }       
}