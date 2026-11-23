/****************************************************************************************************************************************
* Class Name  : Core_MDF_ReleaseHold_Test 
* Version     : 1.0 
* Created Date: 10-05-2019
* Modification Log :
* Developer                     Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture - Vaishali D        10-05-2019                   Created to test Release Criteria and Manual Hold claims
*****************************************************************************************************************************************/
@isTest(SeeAllData=false)
private class Core_MDF_ReleaseHold_Test {

/****************************************************************************************************************************************
Method Name:                                   
Description:                                   
Added By:                                      Accenture – VD  -  10-05-2019
Modified By:           Date:                    Changes: 
Accenture – VD        10-05-2019                Created.
*****************************************************************************************************************************************/   
     @TestSetup static void setupMethodForCheckingReleaseHold(){
         
        // Creating channel program with utility class
        ChannelProgram cp = Core_MDF_CCP_TestDataUtility.createProgram ('Client Co-Marketing Fund','Client CoMarketing Fund', true);
         
        // Creating IntelAccount with utility class
        Account intAcc = Core_MDF_CCP_TestDataUtility.createIntelAccount ('Test Intel Account',Core_MDF_CCP_TestDataUtility.intel_Account_Record_Type, false);
        intAcc.Core_Account_Type__c = 'Reseller';
        intAcc.Core_Sales_Groups__c = 'Automotive Sales Group';
        intAcc.Industry = 'Food & Beverage';
        intAcc.Core_MDF_Channel_Program__c = cp.Id;
        Database.insert(intAcc);
         
        // Creating Top virtual Account with utility class
        Account acc = Core_MDF_CCP_TestDataUtility.createAccount('Test Account', cp.Id,Core_MDF_CCP_TestDataUtility.account_Record_Type, false);
        acc.Core_MDF_Parent_Fund_Account__c = intAcc.Id;
        acc.Core_MDF_Active_Ind__c = true;
        Database.insert(acc);
         
        //Creating Account below Top virtual account
        Account acc1 = Core_MDF_CCP_TestDataUtility.createAccount('Test Account1', cp.Id,Core_MDF_CCP_TestDataUtility.account_Record_Type, false);
        acc1.Core_MDF_Parent_Fund_Account__c = acc.Id;
        acc1.Core_MDF_Active_Ind__c = true;
        Database.insert(acc1);
        
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
        PartnerFundAllocation pfa1 = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('Test Allocation',pmb,acc1,10000,true);
        
        // Creating activities using utility class
        PartnerFundRequest pfr = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(camp.Id),
                                                                                       Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,
                                                                                       string.valueof(acc1.id),pfa,pmb,'INDIA','Small Business',
                                                                                       'Desktop','Intel® Core™ i7+ Processor','Broadcast',
                                                                                       'Radio','Draft',false);
        pfr.RequestedAmount = 9000;
        pfr.Amount = 9000;
        pfr.Status = 'Approved';
        pfr.Core_MDF_Fund_Request_Status__c='Planned';
        pfr.AllocationId = pfa.Id;
        pfr.BudgetId = pmb.Id;
        pfr.Core_MDF_Start_Date__c = system.today();
        pfr.Core_MDF_End_Date__c = system.today();
        Database.insert(pfr);
         
        // Creating Bank
        Core_MDF_Bank__c bank = Core_MDF_CCP_TestDataUtility.createBank(intacc.id,'Core_MDF_Client_CoMarketing_Fund',true,'9966467890');
        
        test.startTest();
        
        //Creating Account Bank Mapping
        Core_MDF_Account_Bank_Mapping__c bankMap = new Core_MDF_Account_Bank_Mapping__c();
        bankMap.Core_MDF_Account__c = acc1.Id;
        bankMap.Core_MDF_Bank__c = bank.Id;
        Database.insert(bankMap);
         
        // Creating claims                
        PartnerFundClaim pfc  = new PartnerFundClaim();
        pfc.RecordTypeId = Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF;
        pfc.Title = 'Test Claim';
        pfc.RequestId = pfr.Id;
        pfc.Core_MDF_Total_Invoice_Amount_Local__c = 20000;
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
        pfc.Core_MDF_Criteria_Hold_Ind__c=true;
        pfc.Core_MDF_Member_Manual_Hold_Ind__c=true;
        pfc.Core_MDF_Intel_Manual_Hold_Ind__c=true;
        Database.insert(pfc);
        
        PartnerFundClaim claim  = new PartnerFundClaim();
        claim.RecordTypeId = Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF;
        claim.Title = 'Test Claim1';
        claim.RequestId = pfr.Id;
        claim.Core_MDF_Total_Invoice_Amount_Local__c = 20000;
        claim.Core_MDF_Status__c = 'Submitted';
        claim.Description = 'Test PFC ';
        claim.Core_MDF_Ad_Run_Start_Date__c = System.today();
        claim.Core_MDF_Ad_Run_End_Date__c = System.today();
        claim.Core_MDF_Invoice_Date__c = System.today();
        claim.Core_MDF_Invoice_Number__c = '1121';
        claim.Core_MDF_Media_Vehicle__c = 'test';
        claim.Core_MDF_OtherCostsnotReimbursable_Local__c = 0;
        claim.Core_MDF_Taxes_Local__c = 0;
        claim.Core_MDF_Currency__c = 'USD';
        claim.Core_MDF_Exchange_rate__c = 1;
        claim.Core_MDF_Bank__c = bank.Id;
        claim.Core_MDF_Criteria_Hold_Ind__c=false;
        claim.Core_MDF_Member_Manual_Hold_Ind__c=false;
        claim.Core_MDF_Intel_Manual_Hold_Ind__c=false;
        Database.insert(claim);
        test.stopTest(); 
     }
    /****************************************************************************************************************************************
Method Name:                                   checkingReleaseHold
Description:                                   
Added By:                                      Accenture – VD  -  10-05-2019
Modified By:                  Date:            Changes: 
Accenture – VD              10-05-2019         Created.
*****************************************************************************************************************************************/ 
    @isTest static void checkingReleaseHold(){
        
        PartnerFundClaim pfclaim = [SELECT Id,Core_MDF_Criteria_Hold_Ind__c,Core_MDF_Member_Manual_Hold_Ind__c,Core_MDF_Intel_Manual_Hold_Ind__c FROM PartnerFundClaim WHERE Title='Test Claim' LIMIT 1];
        PartnerFundClaim pfundclaim = [SELECT Id,Core_MDF_Criteria_Hold_Ind__c,Core_MDF_Member_Manual_Hold_Ind__c,Core_MDF_Intel_Manual_Hold_Ind__c FROM PartnerFundClaim WHERE Title='Test Claim1' LIMIT 1];
        List<String> releaseReason = new List<String>();
        //checking user permission
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.LastName = 'User Test';
        Database.insert(usr);
        PermissionSet financeUserPS = [SELECT Id, Name FROM PermissionSet WHERE Name='Core_MDF_CCP_Internal_Finance_User' LIMIT 1];
        insert new PermissionSetAssignment(PermissionSetId = financeUserPS.Id, AssigneeId = usr.Id);
        System.runAs(usr){
            Core_MDF_ReleaseHold.criteriaManualHoldWrapper wrapp = Core_MDF_ReleaseHold.fetchClaimHoldDetails(pfclaim.Id);
            system.assertEquals(true, wrapp.hasAccess);
            if(wrapp.hasAccess){
                system.assertEquals('Standard', wrapp.loggedInUserType);
            }
            String result = Core_MDF_ReleaseHold.releaseHoldFromClaim(pfundclaim, pfclaim.Core_MDF_Member_Manual_Hold_Ind__c, pfclaim.Core_MDF_Intel_Manual_Hold_Ind__c, pfclaim.Core_MDF_Criteria_Hold_Ind__c);
        }
    }
}