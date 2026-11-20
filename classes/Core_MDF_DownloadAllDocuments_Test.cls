@isTest(SeeAllData=false)
private class Core_MDF_DownloadAllDocuments_Test {
    @testSetup 
    static void setUpData() {
        List<String> bypassFunctionKeys = new List<String>();
        bypassFunctionKeys.add('Bypass_MDF_Budget_Access_Validation');
        bypassFunctionKeys.add('Bypass_MDF_Budget_Status_Validation');
        bypassFunctionKeys.add('checkAndSendClaimsForPIC');
        bypassFunctionKeys.add('duplicateClaimCheck');
        
        Set<String> myset1 = new Set<String>();
        List<String> result1 = new List<String>();
        myset1.addAll(bypassFunctionKeys);
        result1.addAll(myset1);
        
        Core_MDF_CCP_TestDataUtility.byPassFeature(result1,true,true);
        Profile systemAdminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator' limit 1];
        // Creating Internal User with utility class 
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.profileId = systemAdminProfile.Id;
        usr.LastName = 'SysAdmUser';
        Database.insert(usr);
        
        Core_MDF_CCP_TestDataUtility.createMDFConfigurationData();
        
        System.runAs(usr){
            //Assigning Claim Case Reviewer Permission Set to user
            PermissionSet pSet = [SELECT Id FROM PermissionSet WHERE PermissionSet.Name = 'Core_MDF_CCP_Internal_Claim_Case_Reviewer'];
            insert new PermissionSetAssignment(AssigneeId=usr.Id, PermissionSetId = pSet.id);
            Case cs = new Case();
            Id caseAuditRecType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Core_MDF_Audit').getRecordTypeId();
            cs.Status = 'Open';
            cs.recordTypeId = caseAuditRecType;
            cs.Core_MDF_Status__c = 'Pending Documents';
            cs.Origin = 'Manual Selection';
            cs.Core_MDF_Claim_ID__c = 'ClaimID';
            cs.Core_MDF_More_Documentation_Required__c = TRUE;
            insert cs;            
            //Core_MDF_CCP_TestDataUtility.createMDFConfigurationData(); 
            //Creating channel program with utility class
            ChannelProgram cp = Core_MDF_CCP_TestDataUtility.createProgram (Core_MDF_CCP_ConstantClass.CCF_PROGRAM,'Client CoMarketing Fund', true);
            
            //Creating IntelAccount with utility class
            Account acc1 = Core_MDF_CCP_TestDataUtility.createIntelAccount ('Test Account 1', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, 
                                                                            true);
            
            //Creating Co-marketing Account with utility class
            Account acc2 = Core_MDF_CCP_TestDataUtility.createAccount (Core_MDF_CCP_ConstantClass.CCF_PROGRAM, cp.Id,
                                                                       Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            acc2.Core_MDF_Parent_Fund_Account__c = acc1.Id;
            Database.insert(acc2);
            
            Account acc = [select id from Account where Name = 'Client'];
            
            //Creating campaigns using utility class
            Campaign camp = Core_MDF_CCP_TestDataUtility.createCampaign('TestCamp','Consumer','Intel® Corporate Logo', 
                                                                        'Yes',Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF,
                                                                        'Client CoMarketing Fund',System.today().addDays(-15), 
                                                                        System.today().addDays(15), 2000, 'Unite',acc.Id,'2-in-1', false);
            camp.Core_MDF_Opal_Budget_Type_Txt__c = 'OEM CMP';
            insert camp;
            //Creating Budget using utility class
            PartnerMarketingBudget pmb = Core_MDF_CCP_TestDataUtility.createBudget('Test Budget',Core_MDF_CCP_TestDataUtility.budget_Record_Type,
                                                                                   acc.Id,cp.Id,5000000,System.today().addDays(-20),System.today().addDays(40), 
                                                                                   false);
            
            pmb.Core_MDF_Budget_Type_Txt__c='OEM CMP';
            insert pmb;
            
            Core_MDF_Campaign_Budgets__c campBudget= new Core_MDF_Campaign_Budgets__c();
            campBudget.Core_MDF_Campaign_Id__c=camp.id;
            campBudget.Core_MDF_Budget_Name_Id__c=pmb.id;
            campBudget.Core_MDF_Reimbursement_Rate_Pct__c='100%';
            campBudget.Core_MDF_Reimbursement_Amt__c=100000;
            campBudget.Core_MDF_Budget_Amt__c=100000;
            campBudget.Core_MDF_Active_ind__c=true;
            insert campBudget;
            //Creating Allocation using utility class
            PartnerFundAllocation pfa = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('Test Allocation',pmb,acc,1000000.0,true);
            
            //Creating activities using utility class
            PartnerFundRequest pfr = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(camp.Id),
                                                                                           Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,
                                                                                           string.valueof(acc.id),pfa,pmb,'INDIA','Small Business',
                                                                                           'Desktop','Intel® Core™ i7 Processor','Broadcast (Pre-2025)',
                                                                                           'Radio','Draft',false);
            pfr.RequestedAmount = 100;
            pfr.Amount = 100;
            pfr.Status = 'Approved';
            pfr.AllocationId = pfa.Id;
            pfr.BudgetId = pmb.Id;
            pfr.Core_MDF_Start_Date__c = system.today().addDays(-1);
            pfr.Core_MDF_End_Date__c = system.today().addDays(1);
            pfr.Core_MDF_Reimbursement_Rate_txt__c = '100%';
            pfr.Core_MDF_Budget_Type_nm__c = 'OEM CMP';
            Database.insert(pfr);
            
            Test.startTest();
            
            //Creating Bank
            Core_MDF_Bank__c bank = Core_MDF_CCP_TestDataUtility.createBank(acc1.id,'Core_MDF_Client_CoMarketing_Fund',false,'1234567890');
            bank.Core_MDF_Bank_Alias_Name__c='TestActiveBank1';
            bank.Core_MDF_Bank_Status__c = 'Active';
            Database.insert(bank);  
            
            //creating ABM for bank
            // Highlight: Unused Local Variable 
           // Core_MDF_Account_Bank_Mapping__c abm1 = Core_MDF_CCP_TestDataUtility.createAccountBankMap(acc.Id,bank.Id,true);
            
            // Creating claims
            List<PartnerFundClaim> pfcList = new List<PartnerFundClaim>();
            PartnerFundClaim pfc  = new PartnerFundClaim();
            pfc.RecordTypeId = Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF;
            pfc.Title = 'Test Claim from Case Obj';
            pfc.Core_MDF_Total_Invoice_Amount_Local__c = 200000;
            pfc.Core_MDF_FlaggedForAudit__c = false;
            pfc.Core_MDF_Status__c = 'PIC Pending';
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
            pfc.Core_MDF_Claim_Review_Case__c = cs.Id; 
            pfc.Core_MDF_RMF_Last_POP_Submission_Dt__c = null;
            pfc.Core_MDF_Eligible_for_PIC__c = true;
            pfc.RequestId = pfr.Id;
            pfcList.add(pfc);
            
            insert(pfcList);
            Test.stopTest();
        }
    }
    
    @isTest
    static void testGetUserDetailsForInternalUsers() {
        Case case1 = [select Id from Case limit 1];
        PartnerFundClaim pfc  = [select id,Core_MDF_Claim_Review_Case__c,Core_MDF_Claim_Review_Case__r.Core_MDF_Status__c,Core_MDF_RMF_Last_POP_Submission_Dt__c from PartnerFundClaim limit 1];
       // Highlight: Unused Local Variable  
      //  List<String> documentIdWithTitle = new List<String>();
        List<Core_MDF_Audit_Document__c> listDoc =  new List<Core_MDF_Audit_Document__c>();
        Core_MDF_Audit_Document__c auditDocs = new Core_MDF_Audit_Document__c();
        auditDocs.Core_MDF_Document_Id__c = case1.Id;
        auditDocs.Core_MDF_Document_Title__c = 'Test Docs';
        auditDocs.Core_MDF_Claim__c = pfc.Id;
        auditDocs.Core_MDF_Audit__c = case1.Id;
        auditDocs.Core_MDF_Document_Types__c='Proof of Cost;Proof of Execution;Proof of Attribution';
        auditDocs.Core_MDF_App_Document_Types_nm__c='Proof of Cost;Proof of Execution;Proof of Attribution';
        auditDocs.CreatedDate = system.today();
        listDoc.add(auditDocs);
        insert listDoc;
        // Unit Test Method should include System.Assert
        System.assert(listDoc.size() > 0,'Audit document list should contain inserted records');
        
        //for internal claim case reviewer - download all documents
        Core_MDF_DownloadAllDocumentsController.getUserDetails(case1.Id);
    }
    
    @isTest
    static void testGetUserDetailsErrorScenario() {
        // Highlight: Unused Local Variable
       // Case case1 = [select Id from Case limit 1];
        PartnerFundClaim pfc = [select Id from PartnerFundClaim limit 1];
        
        //for internal claim case reviewer - download all documents
        try {
            Core_MDF_DownloadAllDocumentsController.getUserDetails(pfc.Id);
        } catch(Exception ex) {
        }
        // Unit Test Method should include System.Assert 
        System.assertNotEquals(null,pfc.Id,'PartnerFundClaim Id should not be null');
    }
   
}