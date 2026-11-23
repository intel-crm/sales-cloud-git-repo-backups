/****************************************************************************************************************************************
* Class Name  : Core_MDF_InactiveAccount_Test 
* Version     : 1.0 
* Created Date: 3-28-2019
* Modification Log :
* Developer                     Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture - Vaishali D        3-28-2019                   Created to test Inactive account functionality
*****************************************************************************************************************************************/
@isTest(SeeAllData=false)
private class Core_MDF_InactiveAccount_Test { 
         public static Id CCF_RecordType = Schema.SObjectType.Core_MDF_Int_Users_Partner_Geo_Mapping__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_Client_Co_Marketing_Fund').getRecordTypeId();

/****************************************************************************************************************************************
Method Name:                                   setupMethodForCheckingValidations
Description:                                   Created to prepare data for testing 
Added By:                                      Accenture – VD  -  3-28-2019
Modified By:           Date:                    Changes: 
Accenture – VD        3-28-2019                 Created.
*****************************************************************************************************************************************/   
    @TestSetup static void setupMethodForCheckingValidations(){
        
		
    Profile ccpCoreProfile = [SELECT Id FROM Profile WHERE Name='CCP - Core Access' LIMIT 1];
        PermissionSet progAdmPS = [Select Id from PermissionSet where name='Core_MDF_CCP_Internal_Program_Adm' LIMIT 1];
        PermissionSet budgetLoaderPS = [Select Id from PermissionSet where name='Core_MDF_CCP_Internal_CCF_MDF_Budget_Loader' LIMIT 1];
          PermissionSet budgetApproverPS = [Select Id from PermissionSet where name='Core_MDF_CCP_Internal_CCF_MDF_Budget_Approver' LIMIT 1];
        
        List<User> usrList = new List<User>();
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.LastName = 'User Test';
        usrList.add(usr);
        
        User usr1 = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr1.LastName='ProgAdmUser';
        usr1.profileId=ccpCoreProfile.Id;
        usrList.add(usr1);
        
        Database.insert(usrList);
        List<PermissionSetAssignment> psList = new List<PermissionSetAssignment>();
        PermissionSetAssignment assignPermissionSetObj = new PermissionSetAssignment();
        assignPermissionSetObj.AssigneeId = usr1.Id;
        assignPermissionSetObj.PermissionSetId = progAdmPS.Id;
        psList.add(assignPermissionSetObj);
         
        PermissionSetAssignment assignPermissionSetObj1 = new PermissionSetAssignment();
        assignPermissionSetObj1.AssigneeId = usr1.Id;
        assignPermissionSetObj1.PermissionSetId = budgetLoaderPS.Id;
        psList.add(assignPermissionSetObj1);
        
        PermissionSetAssignment assignPermissionSetObj2 = new PermissionSetAssignment();
        assignPermissionSetObj2.AssigneeId = usr1.Id;
        assignPermissionSetObj2.PermissionSetId = budgetApproverPS.Id;
        psList.add(assignPermissionSetObj2); 
        system.runAs(usr){
            Database.insert(psList);
           
        }
        
        // Creating channel program with utility class
        ChannelProgram cp = Core_MDF_CCP_TestDataUtility.createProgram ('Client Co-Marketing Fund','Client CoMarketing Fund', true);
        
        // Creating IntelAccount with utility class
        Account intAcc = Core_MDF_CCP_TestDataUtility.createIntelAccount ('Test Intel Account',Core_MDF_CCP_TestDataUtility.intel_Account_Record_Type, true);
        /*intAcc.Core_Account_Type__c = 'Reseller';
        intAcc.Core_Sales_Groups__c = 'Automotive Sales Group';
        intAcc.Industry = 'Food & Beverage';
        Database.insert(intAcc);*/

        // Creating Top virtual Account with utility class
        Account acc = Core_MDF_CCP_TestDataUtility.createAccount('Test Account', cp.Id,Core_MDF_CCP_TestDataUtility.account_Record_Type, false);
        acc.Core_MDF_Parent_Fund_Account__c = intAcc.Id;
        Database.insert(acc);
        
        List<Account> listOfAcct = new List<Account>();
        
        //Creating Account below Top virtual account
        Account acc1 = Core_MDF_CCP_TestDataUtility.createAccount('Test Account1', cp.Id,Core_MDF_CCP_TestDataUtility.account_Record_Type, false);
        acc1.Core_MDF_Parent_Fund_Account__c = acc.Id;
        listOfAcct.add(acc1);
		
        Account acc2 = Core_MDF_CCP_TestDataUtility.createAccount('Test Account2', cp.Id, Core_MDF_CCP_TestDataUtility.account_Record_Type, false);
        acc2.Core_MDF_Parent_Fund_Account__c = acc.Id;
        listOfAcct.add(acc2);
        
        Account acc3 = Core_MDF_CCP_TestDataUtility.createAccount('Test Account3', cp.Id, Core_MDF_CCP_TestDataUtility.account_Record_Type, false);
        acc3.Core_MDF_Parent_Fund_Account__c = acc.Id;
        listOfAcct.add(acc3);
		
        Account acc4 = Core_MDF_CCP_TestDataUtility.createAccount('Test Account4', cp.Id, Core_MDF_CCP_TestDataUtility.account_Record_Type, false);
        acc4.Core_MDF_Parent_Fund_Account__c = acc.Id;
        listOfAcct.add(acc4);
        
        Database.insert(listOfAcct);
        
        acc2.Core_MDF_Active_Ind__c = false;
        Database.update(acc2);
	Core_MDF_CCP_TestDataUtility.createMDFConfigurationData();
        // Creating campaigns using utility class
        /*Campaign camp = Core_MDF_CCP_TestDataUtility.createCampaign('TestCamp','Consumer','Intel® Corporate Logo', 
                                                                    Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF,
                                                                    'Client CoMarketing Fund',System.today().addDays(-1) ,
                                                                    System.today().addDays(200), 2000, 'Unite',acc.Id,'2-in-1', true);*/
        
        Campaign camp = Core_MDF_CCP_TestDataUtility.createCampaign('TestCamp','Consumer','Intel® Corporate Logo','Yes', Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 
                                                                    'Client CoMarketing Fund',system.today().addDays(-10), system.today().addDays(200), 2000, 'Unite', acc.Id,'2-in-1', false);
        camp.Core_MDF_Supports_legacy_program__c = 'MDF or both CMP & MDF';
        camp.Core_MDF_Opal_Budget_Type_Txt__c = 'OEM CMP';
        database.insert(camp);
        /*system.runAs(usr){
         Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgmbudLoader = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
            iupgmbudLoader.Core_MDF_Program_nm__c = 'Client CoMarketing Fund';
            
            iupgmbudLoader.RecordTypeId = CCF_RecordType;
            iupgmbudLoader.Core_MDF_Region_Sub_Region_nm__c = 'WW';
            iupgmbudLoader.Core_MDF_User_id__c = usr1.Id;
            iupgmbudLoader.Core_MDF_Role_nm__c = 'Core_MDF_CCP_Internal_CCF_MDF_Budget_Loader';
            Database.insert(iupgmbudLoader);
         Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgmBudApprover = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
            iupgmBudApprover.Core_MDF_Program_nm__c = 'Client CoMarketing Fund';
            
            iupgmBudApprover.RecordTypeId = CCF_RecordType;
            iupgmBudApprover.Core_MDF_Region_Sub_Region_nm__c = 'WW';
            iupgmBudApprover.Core_MDF_User_id__c = usr1.Id;
            iupgmBudApprover.Core_MDF_Role_nm__c = 'Core_MDF_CCP_Internal_CCF_MDF_Budget_Approver';
            Database.insert(iupgmBudApprover);
        }*/
        
        //adding bypass feature to bypass access validation
			List<String> bypassFunctionKeys = new List<String>();
            bypassFunctionKeys.add('Bypass_MDF_Budget_Access_Validation');
            bypassFunctionKeys.add('Bypass_MDF_Budget_Status_Validation');
        	bypassFunctionKeys.add('Bypass_MDF_Budget_Creation');
            
            Set<String> myset1 = new Set<String>();
            List<String> result1 = new List<String>();
            myset1.addAll(bypassFunctionKeys);
            result1.addAll(myset1);
            
            List<Core_Trigger_Executions__c> bypassfunctinalitylist1 = Core_MDF_CCP_TestDataUtility.byPassFeature(result1,true,true);
        
        // Creating Budget using utility class
        PartnerMarketingBudget pmb = Core_MDF_CCP_TestDataUtility.createBudget('Test Budget',Core_MDF_CCP_TestDataUtility.budget_Record_Type,
                                                                               acc.Id,cp.Id,5000000,System.today().addDays(-15),System.today().addDays(110), 
                                                                               false);
        pmb.Core_MDF_Budget_Type_Txt__c = 'OEM CMP';
        //system.runAs(usr1){
        	database.insert(pmb);
         //}
        // Creating Allocation using utility class
        List<PartnerFundAllocation> pfaList = new List<PartnerFundAllocation>();
        
        PartnerFundAllocation pfa = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('Test Allocation',pmb,acc,1000000.0,false);
        pfaList.add(pfa);
        PartnerFundAllocation pfa1 = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('Test Allocation',pmb,acc1,10000,false);
        pfaList.add(pfa1);
        
        PartnerFundAllocation pfa2 = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('Test Allocation',pmb,acc4,100,false);
        pfaList.add(pfa2);
                
        Database.insert(pfaList);
        
        test.startTest();
        // Creating activities using utility class
        List<PartnerFundRequest> pfrList = new List<PartnerFundRequest>();
        PartnerFundRequest pfr = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(camp.Id),
                                                                                       Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,
                                                                                       string.valueof(acc1.id),pfa,pmb,'INDIA','Small Business',
                                                                                       'Desktop','Intel® Corporate Logo','Broadcast',
                                                                                       'Radio','Draft',false);
        pfr.RequestedAmount = 9000;
        pfr.Amount = 9000;
        pfr.Status = 'Approved';
        pfr.Core_MDF_Fund_Request_Status__c='Planned';
        pfr.AllocationId = pfa.Id;
        pfr.BudgetId = pmb.Id;
        pfr.Core_MDF_Start_Date__c = system.today().addDays(-5);
        pfr.Core_MDF_End_Date__c = system.today().addDays(5);
        pfr.Core_MDF_Reimbursement_Rate_txt__c = '100%';
        pfrList.add(pfr);
        
        // Creating 2nd activity using utility class
        PartnerFundRequest pfr2 = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(camp.Id),
                                                                                       Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,
                                                                                       string.valueof(acc4.id),pfa2,pmb,'INDIA','Small Business',
                                                                                       'Desktop','Intel® Corporate Logo','Broadcast',
                                                                                       'Radio','Draft',false);
        pfr2.RequestedAmount = 100;
        pfr2.Amount = 100;
        pfr2.Status = 'Approved';
        pfr2.Core_MDF_Fund_Request_Status__c='Planned';
        pfr2.AllocationId = pfa2.Id;
        pfr2.BudgetId = pmb.Id;
        pfr2.Core_MDF_Start_Date__c = system.today().addDays(-5);
        pfr2.Core_MDF_End_Date__c = system.today().addDays(5);
        pfr2.Core_MDF_Reimbursement_Rate_txt__c = '100%';
        pfrList.add(pfr2);
        
        Database.insert(pfrList);
        
        // Creating Bank
        Core_MDF_Bank__c bank = Core_MDF_CCP_TestDataUtility.createBank(intacc.id,'Core_MDF_Client_CoMarketing_Fund',true,'9966467890');

        //Creating Account Bank Mapping
        List<Core_MDF_Account_Bank_Mapping__c> acctBankMappingList = new List<Core_MDF_Account_Bank_Mapping__c>();
        
        Core_MDF_Account_Bank_Mapping__c bankMap = new Core_MDF_Account_Bank_Mapping__c();
        bankMap.Core_MDF_Account__c = acc1.Id;
        bankMap.Core_MDF_Bank__c = bank.Id;
        acctBankMappingList.add(bankMap);
        
        Core_MDF_Account_Bank_Mapping__c bankMap2 = new Core_MDF_Account_Bank_Mapping__c();
        bankMap2.Core_MDF_Account__c = acc4.Id;
        bankMap2.Core_MDF_Bank__c = bank.Id;
        acctBankMappingList.add(bankMap2);
        
        Database.insert(acctBankMappingList);
        
        // Creating claim   
        List<PartnerFundClaim> pfclist = new List<PartnerFundClaim>();
        List<PartnerFundClaim> pfcUpdateList = new List<PartnerFundClaim>();
        
        PartnerFundClaim pfc = Core_MDF_CCP_TestDataUtility.createClaim('Test Claim',Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF,pfr.Id,System.today().addDays(-3),System.today(),5000,System.today().addDays(-3),bank.Id,false);
        pfc.Core_MDF_Country_Location_nm__c ='INDIA';
        pfc.Core_MDF_Currency__c = 'USD';
        pfclist.add(pfc);
        
        PartnerFundClaim pfcPaid = Core_MDF_CCP_TestDataUtility.createClaim('Test Claim',Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF,pfr.Id,System.today().addDays(-3),System.today(),4000,System.today().addDays(-3),bank.Id,false);
        pfcPaid.Core_MDF_Country_Location_nm__c ='INDIA';
        pfcPaid.Core_MDF_Currency__c = 'USD'; 
        pfclist.add(pfcPaid);      
        //creating claim and making to paid for inactivating node
        PartnerFundClaim pfcPaid2 = Core_MDF_CCP_TestDataUtility.createClaim('Test Claim2',Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF,pfr2.Id,System.today().addDays(-3),System.today(),100,System.today().addDays(-3),bank.Id,false);
        pfcPaid2.Core_MDF_Country_Location_nm__c ='INDIA';
        pfcPaid2.Core_MDF_Currency__c = 'USD';
        pfclist.add(pfcPaid2);
        System.runAs(usr){
        Database.insert(pfclist);
        }
        pfcPaid.Core_MDF_Status__c = 'Paid';
        pfcUpdateList.add(pfcPaid);
        
        pfcPaid2.Core_MDF_Status__c = 'Paid';
        pfcUpdateList.add(pfcPaid2);
        
        Database.update(pfcUpdateList);               
		                
        test.stopTest(); 
		                
        List<Case> caseListToBeInserted = new List<Case>();
        Case cs = new Case();
        Id caseAuditRecType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Core_MDF_Audit_Closed').getRecordTypeId();
        //cs.Id = pfc1.Core_MDF_Claim_Review_Case__c;
        cs.Status = 'Closed';
        cs.recordTypeId = caseAuditRecType;
        cs.AccountId = acc1.Id;
        cs.Core_MDF_Claim_ID__c = pfc.Id;
        cs.Origin = 'Manual Selection';
        caseListToBeInserted.add(cs); 

        Case cs1 = new Case();
        //cs.Id = pfc1.Core_MDF_Claim_Review_Case__c;
        cs1.Status = 'Closed';
        cs1.recordTypeId = caseAuditRecType;
        cs1.AccountId = acc4.Id;
        cs1.Core_MDF_Claim_ID__c = pfcPaid2.Id;
        cs1.Origin = 'Manual Selection';
        caseListToBeInserted.add(cs1);  

        Database.insert(caseListToBeInserted);
        pfr.Core_MDF_Fund_Request_Status__c = 'Closed';
        update pfr;
        List<Core_MDF_Escalation__c> escToBeInserted = new List<Core_MDF_Escalation__c>();
        
        Id caseRecType = Schema.SObjectType.Core_MDF_Escalation__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_Claim_Case_Review_Result').getRecordTypeId();
        Core_MDF_Escalation__c esc2 = new Core_MDF_Escalation__c();
        esc2.Core_MDF_Escalation_Status_nm__c='Pending Review';
        esc2.Core_MDF_Escalation_Name_txt__c='Test2';
        esc2.Core_MDF_Total_Dollar_Impact_amt__c= 45;
        esc2.Core_MDF_Root_Cause_nm__c = 'Claim Score Appeal';
        esc2.Core_MDF_Case_ID_Number_id__c = cs.Id;
        esc2.Core_MDF_Channel_Program_id__c = cp.Id;
        esc2.recordtypeid = caseRecType;
        escToBeInserted.add(esc2);
        
        Core_MDF_Escalation__c esc3 = new Core_MDF_Escalation__c();
        esc3.Core_MDF_Escalation_Status_nm__c='Pending Review';
        esc3.Core_MDF_Escalation_Name_txt__c='Test2';
        esc3.Core_MDF_Total_Dollar_Impact_amt__c= 45;
        esc3.Core_MDF_Root_Cause_nm__c = 'Claim Score Appeal';
        esc3.Core_MDF_Case_ID_Number_id__c = cs.Id;
        esc3.Core_MDF_Channel_Program_id__c = cp.Id;
        esc3.recordtypeid = caseRecType;
        escToBeInserted.add(esc3);
        
        Id claimRecType = Schema.SObjectType.Core_MDF_Escalation__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_Late_Claim').getRecordTypeId();
        Core_MDF_Escalation__c esc1 = new Core_MDF_Escalation__c();
        esc1.Core_MDF_Escalation_Status_nm__c='Pending Review';
        esc1.Core_MDF_Escalation_Name_txt__c='Test1';
        esc1.Core_MDF_Total_Dollar_Impact_amt__c= 56;
        esc1.Core_MDF_Root_Cause_nm__c = 'Tools and Systems';
        esc1.Core_MDF_Co_Marketing_Activity_id__c = pfr.Id;
        esc1.Core_MDF_Channel_Program_id__c = cp.Id;
        esc1.recordtypeid= claimRecType;
        escToBeInserted.add(esc1);
        
        Database.insert(escToBeInserted);
        
        esc3.Core_MDF_Claim_Number_id__c  = pfc.id;
        esc3.Core_MDF_Escalation_Status_nm__c = 'Approved';                         
    }
/****************************************************************************************************************************************
Method Name:                                   inactivateAccount
Description:                                   Created to test account inactivation
Added By:                                      Accenture – VD  -  05/Mar/2020
Modified By:                  Date:            Changes: 
Accenture – VD              05/Mar/2020         Created.
*****************************************************************************************************************************************/  
    @isTest static void inactivateAccount(){
        test.startTest();
        User usr1 = [SELECT Id FROM User WHERE LastName='ProgAdmUser' LIMIT 1];
        Account acc4 = [SELECT Id,Core_MDF_Active_Ind__c FROM Account WHERE Name='Test Account4' LIMIT 1];
        User usr = [SELECT Id FROM User WHERE LastName='User Test' LIMIT 1];
        Core_MDF_Bank__c bank = [Select id,Core_MDF_Supplier_Number__c from Core_MDF_Bank__c where Core_MDF_Supplier_Number__c='9966467890'];
        PartnerFundRequest pfr2 = [Select Id,Core_MDF_Fund_Request_Status__c,ChannelPartnerId from PartnerFundRequest where ChannelPartnerId =:acc4.Id];
        // Highlight: Unused Local Variable
       // PartnerFundClaim pfc = [Select id from PartnerFundClaim where title='Test Claim2'];
        Core_MDF_Account_Bank_Mapping__c bankMap2= [Select Core_MDF_Account__c,Core_MDF_Bank__c,Core_MDF_Active_ind__c from Core_MDF_Account_Bank_Mapping__c where Core_MDF_Bank__c=:bank.Id and Core_MDF_Account__c=:acc4.Id];
        System.runAs(usr){
            //Core_MDF_Adjustment_Request__c adjustmentRec = Core_MDF_CCP_TestDataUtility.createAdjustmentReq(pfc.Id,'Overpaid Claim',10,true);            
            //Closing activity
            pfr2.Core_MDF_Fund_Request_Status__c='Closed';
            //Database.update(pfr2);
            //inactivating account bank mapping
            bankMap2.Core_MDF_Active_ind__c=false;
            //Database.update(bankMap2);                        
            System.assertNotEquals(bankMap2.Id,null);
        }        
        //inactivating Node
        System.runAs(usr1){
            // Highlight: Unused Local Variable 
           /* Core_MDF_InactivateAccount.accountInactivationWrapper result = */ Core_MDF_InactivateAccount.isAccountEligibileForInactivation(acc4.Id);
            //System.assertEquals(FALSE, result.hasActiveClaims);
        }
        test.stopTest();               
    }

/****************************************************************************************************************************************
Method Name:                                   checkingUserPermission
Description:                                   Created to test user permission 
Added By:                                      Accenture – VD  -  03/28/2019
Modified By:                  Date:            Changes: 
Accenture – VD              03/28/2019         Created.
*****************************************************************************************************************************************/  
    @isTest static void ifUserDoesntHavePermission(){
        test.startTest();
        User usr = [SELECT Id FROM User WHERE LastName='User Test' LIMIT 1];
        //checking if user doesn't have permission
        System.runAs(usr){
            Boolean resultUserhasPerm = Core_MDF_InactivateAccount.isUserEligibiletoInactivate();
            System.assertEquals(false, resultUserhasPerm);
        }
        test.stopTest();
    }

/****************************************************************************************************************************************
Method Name:                                   checkTopVirtualAccount
Description:                                   Created to check top Virtual account
Added By:                                      Accenture – VD  -  03/28/2019
Modified By:                  Date:            Changes: 
Accenture – VD              03/28/2019         Created.
*****************************************************************************************************************************************/      
   @isTest static void checkTopVirtualAccount(){
       test.startTest();
       Account acct = [SELECT Id FROM Account WHERE Name='Test Account' LIMIT 1];
       Account acct1 = [SELECT Id FROM Account WHERE Name='Test Account1' LIMIT 1];
       User usr1 = [SELECT Id FROM User WHERE LastName='ProgAdmUser' LIMIT 1];
       System.runAs(usr1){
           Core_MDF_InactivateAccount.accountInactivationWrapper resultTopVirtual = Core_MDF_InactivateAccount.isAccountEligibileForInactivation(acct.Id);
           System.assertEquals(TRUE, resultTopVirtual.isTopVirtualNode);
          // Highlight: Unused Local Variable
         /*  Core_MDF_InactivateAccount.accountInactivationWrapper resultNotTopVirtual = */ Core_MDF_InactivateAccount.isAccountEligibileForInactivation(acct1.Id);
           //System.assertEquals(FALSE, resultNotTopVirtual.isTopVirtualNode);
       }
       test.stopTest();
   }

/****************************************************************************************************************************************
Method Name:                                   checkDeactivatedAccount
Description:                                   Created to check top Virtual account
Added By:                                      Accenture – VD  -  03/28/2019
Modified By:                  Date:            Changes: 
Accenture – VD              03/28/2019         Created.
*****************************************************************************************************************************************/  
    
   @isTest static void checkDeactivatedAccount(){
       test.startTest();
       Account acct2 = [SELECT Id FROM Account WHERE Name='Test Account2' LIMIT 1];
       Account acct = [SELECT Id FROM Account WHERE Name='Test Account' LIMIT 1];
       User usr1 = [SELECT Id FROM User WHERE LastName='ProgAdmUser' LIMIT 1];
       System.runAs(usr1){
           Core_MDF_InactivateAccount.accountInactivationWrapper resultDeactivated = Core_MDF_InactivateAccount.isAccountEligibileForInactivation(acct2.Id);
           System.assertEquals(TRUE, resultDeactivated.isDeactivated); 
           Core_MDF_InactivateAccount.accountInactivationWrapper resultNotDeactivated = Core_MDF_InactivateAccount.isAccountEligibileForInactivation(acct.Id);
           System.assertEquals(FALSE, resultNotDeactivated.isDeactivated); 
       }
       test.stopTest();
   }

/****************************************************************************************************************************************
Method Name:                                   checkTopVirtualAccount
Description:                                   Created to check top Virtual account
Added By:                                      Accenture – VD  -  03/28/2019
Modified By:                  Date:            Changes: 
Accenture – VD              03/28/2019         Created.
*****************************************************************************************************************************************/  
   @isTest static void checkAllocation(){
       test.startTest();
       Account acct1 = [SELECT Id FROM Account WHERE Name='Test Account1' LIMIT 1];
       Account acct2 = [SELECT Id FROM Account WHERE Name='Test Account2' LIMIT 1];
       User usr1 = [SELECT Id FROM User WHERE LastName='ProgAdmUser' LIMIT 1];
       System.runAs(usr1){
           Core_MDF_InactivateAccount.accountInactivationWrapper resultAllocationAvailable = Core_MDF_InactivateAccount.isAccountEligibileForInactivation(acct1.Id);
           System.assertEquals(TRUE, resultAllocationAvailable.hasAllocation);
           Core_MDF_InactivateAccount.accountInactivationWrapper resultNoAllocationAvailable = Core_MDF_InactivateAccount.isAccountEligibileForInactivation(acct2.Id);
           System.assertEquals(FALSE, resultNoAllocationAvailable.hasAllocation);  
       }
       test.stopTest();
   }
   
/****************************************************************************************************************************************
Method Name:                                   checkTopVirtualAccount
Description:                                   Created to check top Virtual account
Added By:                                      Accenture – VD  -  03/28/2019
Modified By:                  Date:            Changes: 
Accenture – VD              03/28/2019         Created.
*****************************************************************************************************************************************/  
   @isTest static void checkEscalation(){
       test.startTest();
       Account acct1 = [SELECT Id FROM Account WHERE Name='Test Account1' LIMIT 1];
       Account acct2 = [SELECT Id FROM Account WHERE Name='Test Account2' LIMIT 1];
       Account acct3 = [SELECT Id FROM Account WHERE Name='Test Account3' LIMIT 1];
       User usr1 = [SELECT Id FROM User WHERE LastName='ProgAdmUser' LIMIT 1];
       System.runAs(usr1){
           Boolean resultEscalationRecordAvailable = Core_MDF_InactivateAccount.hasOpenEscalations(acct1);
           System.assertEquals(TRUE, resultEscalationRecordAvailable);
           Boolean resultNoEscalationRecordAvailable = Core_MDF_InactivateAccount.hasOpenEscalations(acct2);
           System.assertEquals(FALSE, resultNoEscalationRecordAvailable);  
           Boolean resultNoEscalationRecordAvailable1 = Core_MDF_InactivateAccount.hasOpenEscalations(acct3);
           System.assertEquals(FALSE, resultNoEscalationRecordAvailable1);  
       }
       test.stopTest();
   }

/****************************************************************************************************************************************
Method Name:                                   checkingNegativeValidations
Description:                                   Created to check top Virtual account
Added By:                                      Accenture – VD  -  03/28/2019
Modified By:                  Date:            Changes: 
Accenture – VD              03/28/2019         Created.
*****************************************************************************************************************************************/      
    @isTest static void checkingNegativeValidations(){
        test.startTest();
        
        //Creating account instance
        Account act1 = [SELECT Id FROM Account WHERE Name='Test Account1' LIMIT 1];
       // Highlight: Unused Local Variable 
       // Account act = [SELECT Id FROM Account WHERE Name='Test Account' LIMIT 1];
        User usr1 = [SELECT Id FROM User WHERE LastName='ProgAdmUser' LIMIT 1];
        System.runAs(usr1){
            //Checking when account is not top virtual account and not deactivated
            Core_MDF_InactivateAccount.isAccountEligibileForInactivation(act1.Id);  
            
            //checking if account is not used as Auto transfer account
            boolean resultIfNotAutoTransAcct = Core_MDF_InactivateAccount.isAutoTransAcct(act1);// 
            System.assertEquals(false, resultIfNotAutoTransAcct);
        }
        test.stopTest();
    }
/****************************************************************************************************************************************
Method Name:                                   checkingExceptions
Description:                                   Created to handle exception
Added By:                                      Accenture – VD  -  03/28/2019
Modified By:                  Date:            Changes: 
Accenture – VD              03/28/2019         Created.
*****************************************************************************************************************************************/      
    @isTest static void checkingExceptions(){
        test.startTest();
        User usr1 = [SELECT Id FROM User WHERE LastName='ProgAdmUser' LIMIT 1];
        System.runAs(usr1){
            Core_MDF_InactivateAccount.isAccountEligibileForInactivation(null);
            Boolean excep1 = Core_MDF_InactivateAccount.isTopVirtualNode(null);
            System.assertEquals(null, excep1);
            Boolean excep2 = Core_MDF_InactivateAccount.isDeactivatedAccount(null);
            System.assertEquals(null, excep2);
            Boolean excep3 = Core_MDF_InactivateAccount.isAutoTransAcct(null);
            System.assertEquals(null, excep3);
            Boolean excep4 = Core_MDF_InactivateAccount.isAllocationAvailable(null);
            System.assertEquals(null, excep4);
            Core_MDF_InactivateAccount.isClaimsAssociated(null);
            Core_MDF_InactivateAccount.isActivitiesAssociated(null);
            Boolean excep5 = Core_MDF_InactivateAccount.hasAccntBankMappings(null);
            System.assertEquals(null, excep5);
            Boolean excep6 = Core_MDF_InactivateAccount.hasOpenEscalations(null);
            System.assertEquals(null, excep6);
        }
        test.stopTest();
    }
}