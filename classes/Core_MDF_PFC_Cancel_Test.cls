//from devccp
@isTest(SeeAllData = false)
public class Core_MDF_PFC_Cancel_Test {
    
    // test method for data setup
    @TestSetup static void setUpData(){
        
        
        // Creating User with utility class 
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.Email = 'sysadmin@example.com';
        Database.insert(usr);
        
        Profile ccpCoreProfile = [SELECT Id FROM Profile WHERE Name='CCP - Core Access' LIMIT 1];
        PermissionSet clmCaseRevPS = [SELECT Id, Name FROM PermissionSet WHERE Name='Core_MDF_CCP_Internal_Claim_Case_Reviewer' LIMIT 1];
        PermissionSet ccfPayAdmin = [SELECT Id, Name FROM PermissionSet WHERE Name='Core_MDF_CCP_Internal_CCF_Payment_Adm' LIMIT 1];
        User claimCase = Core_MDF_CCP_TestDataUtility.createUser(false);
        claimCase.Email = 'clmcase@example.com';
        claimCase.Profile = ccpCoreProfile;
        insert claimCase;
        List<PermissionSetAssignment> permSetAssignment = new List<PermissionSetAssignment>();
        PermissionSetAssignment assignPermissionSetObj = new PermissionSetAssignment();
        assignPermissionSetObj.AssigneeId = claimCase.Id;
        assignPermissionSetObj.PermissionSetId = clmCaseRevPS.Id;
        permSetAssignment.add(assignPermissionSetObj);
        
        PermissionSetAssignment assignPermissionSetObj1 = new PermissionSetAssignment();
        assignPermissionSetObj1.AssigneeId = usr.Id;
        assignPermissionSetObj1.PermissionSetId = ccfPayAdmin.Id;
        permSetAssignment.add(assignPermissionSetObj1);
        system.runas(usr){
            Database.insert(permSetAssignment);
        }
        
        List<Account> toBeUpdated = new List<Account>();
        
        // Creating channel program with utility class
        ChannelProgram cp1 = Core_MDF_CCP_TestDataUtility.createProgram (Core_MDF_CCP_ConstantClass.CCF_PROGRAM,'Client CoMarketing Fund', true);
        
        // Creating Account with utility class
        Account acc1 = Core_MDF_CCP_TestDataUtility.createIntelAccount('Test Account 1', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, true);
        
        Account acc2 = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test Account 2', cp1.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, acc1.Id, true);
        
        Account acc3 = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test Account 3', cp1.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, acc2.Id, true);
        
        
        // Updating Accounts 
        acc1.isPartner = true;
        acc2.isPartner = true;
        acc3.isPartner = true;
        toBeUpdated.add(acc1);
        toBeUpdated.add(acc2);
        toBeUpdated.add(acc3);
        Database.update(toBeUpdated);
        
        //Creating Contact for Partner User
        Contact conRecord1 = Core_MDF_CCP_TestDataUtility.createContact(acc1.Id,true);
        
        Id profileId = [SELECT Id FROM Profile WHERE Name='Partner' limit 1].Id;
        User usr1 = Core_MDF_CCP_TestDataUtility.createUser(false);        
        usr1.Email='test1@example.com';
        usr1.ContactId = conRecord1.Id;
        usr1.ProfileId = profileId;
        usr1.isActive = true;
        Database.insert(usr1);
        
        Profile ccpProfile1 = [SELECT Id FROM Profile WHERE Name='CCP - Core Access'];
        //UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        User usr2 = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr2.ProfileId = ccpProfile1.Id;
        usr2.Email='test2@intel.com';
        usr2.isActive = true;
        usr2.UserPermissionsMarketingUser=true;
        Database.insert(usr2);
        
        List<Core_MDF_Currency_Exchange_Rates__c> newValues = new List<Core_MDF_Currency_Exchange_Rates__c>();
        Core_MDF_Currency_Exchange_Rates__c record1 = new Core_MDF_Currency_Exchange_Rates__c();
        record1.Name= 'ZMK';
        record1.Core_MDF_Exchange_Rate__c = 0.0000850159;
        record1.Core_MDF_Market_Date__c =System.today();
        record1.Core_MDF_Intel_WW__c = Core_MDF_CCP_Multicurrency.calculateIntelWorkWeek(System.today());
        record1.Core_MDF_Unique_Key__c = 'ZMK'+Core_MDF_CCP_Multicurrency.calculateIntelWorkWeek(System.today());
        newValues.add(record1);
        
        Core_MDF_Currency_Exchange_Rates__c record2 = new Core_MDF_Currency_Exchange_Rates__c();
        record2.Name= 'INR';
        record2.Core_MDF_Exchange_Rate__c = 1;
        record2.Core_MDF_Market_Date__c =System.today();
        record2.Core_MDF_Intel_WW__c = Core_MDF_CCP_Multicurrency.calculateIntelWorkWeek(System.today());
        record2.Core_MDF_Unique_Key__c = 'INR'+Core_MDF_CCP_Multicurrency.calculateIntelWorkWeek(System.today());
        newValues.add(record2); 
        
        Core_MDF_Currency_Exchange_Rates__c record3 = new Core_MDF_Currency_Exchange_Rates__c();
        record3.Name= 'USD';
        record3.Core_MDF_Exchange_Rate__c = 1;
        record3.Core_MDF_Market_Date__c =System.today();
        record3.Core_MDF_Intel_WW__c = Core_MDF_CCP_Multicurrency.calculateIntelWorkWeek(System.today());
        record3.Core_MDF_Unique_Key__c = 'USD'+Core_MDF_CCP_Multicurrency.calculateIntelWorkWeek(System.today());
        newValues.add(record3); 
        database.insert(newValues);
        Profile systemAdminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator' limit 1];
        //Permissionset internalFinanceUser=[SELECT Id From PermissionSet WHERE Label='CCP Internal Finance User'];
        // Creating User with utility class 
        User usr3 = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr3.profileId = systemAdminProfile.Id;
        usr3.Email='test2@example.com';
        Database.insert(usr3);
        Map<String,PermissionSet> nameToPerSet = new Map<String,PermissionSet>();
        for(PermissionSet pSet:[SELECT Id,Name FROM PermissionSet WHERE Name IN (
                            'Core_MDF_CCP_Internal_Retail_Finance_Usr','Core_MDF_CCP_Internal_IPA_Finance_Usr',
            				'Core_MDF_CCP_Internal_Finance_Usr','Core_MDF_CCP_Internal_CCF_User',
            				'Core_MDF_CCP_Internal_DCF_User','Core_MDF_CCP_Internal_CCF_MDF_Budget_Loader'
                            )]) {
            nameToPerSet.put(pSet.Name,pSet);
        }
        
         
		List<PermissionSetAssignment> permSetAssgnLst = new List<PermissionSetAssignment>();
        PermissionSet retailInternalFinanceUser = nameToPerSet.get('Core_MDF_CCP_Internal_Retail_Finance_Usr');
        PermissionSetAssignment assignMDFBudgetLoaderPermissionSet = new PermissionSetAssignment();
        assignMDFBudgetLoaderPermissionSet.AssigneeId = usr3.Id;
        assignMDFBudgetLoaderPermissionSet.PermissionSetId = retailInternalFinanceUser.Id; 
        permSetAssgnLst.add(assignMDFBudgetLoaderPermissionSet);
        PermissionSet ipaFinanceUser = nameToPerSet.get('Core_MDF_CCP_Internal_IPA_Finance_Usr');
        PermissionSetAssignment assignIPAPermissionSet = new PermissionSetAssignment();
        assignIPAPermissionSet.AssigneeId = usr3.Id;
        assignIPAPermissionSet.PermissionSetId = ipaFinanceUser.Id; 
        permSetAssgnLst.add(assignIPAPermissionSet);
        PermissionSet internalFinanceUser = nameToPerSet.get('Core_MDF_CCP_Internal_Finance_Usr');
        PermissionSetAssignment assignInternalFinanceUserPermissionSet = new PermissionSetAssignment();
        assignInternalFinanceUserPermissionSet.AssigneeId = usr3.Id;
        assignInternalFinanceUserPermissionSet.PermissionSetId = internalFinanceUser.Id; 
        permSetAssgnLst.add(assignInternalFinanceUserPermissionSet);
        PermissionSet internalCCFUser = nameToPerSet.get('Core_MDF_CCP_Internal_CCF_User');
        PermissionSetAssignment assignInternalCCFUserPermissionSet = new PermissionSetAssignment();
        assignInternalCCFUserPermissionSet.AssigneeId = usr3.Id;
        assignInternalCCFUserPermissionSet.PermissionSetId = internalCCFUser.Id; 
        permSetAssgnLst.add(assignInternalCCFUserPermissionSet);
        PermissionSet internalDCFUser = nameToPerSet.get('Core_MDF_CCP_Internal_DCF_User');
        PermissionSetAssignment assigninternalDCFUserPermissionSet = new PermissionSetAssignment();
        assigninternalDCFUserPermissionSet.AssigneeId = usr3.Id;
        assigninternalDCFUserPermissionSet.PermissionSetId = internalDCFUser.Id; 
        permSetAssgnLst.add(assigninternalDCFUserPermissionSet);
        PermissionSetAssignment assigninternalCCFBudLoPermissionSet = new PermissionSetAssignment();
        assigninternalCCFBudLoPermissionSet.AssigneeId = usr3.Id;
        assigninternalCCFBudLoPermissionSet.PermissionSetId = nameToPerSet.get('Core_MDF_CCP_Internal_CCF_MDF_Budget_Loader').id;
        permSetAssgnLst.add(assigninternalCCFBudLoPermissionSet);
        system.runAs(usr3){
            Database.insert(permSetAssgnLst);
        }
        
        System.runAs(usr3){
        PartnerMarketingBudget pbm = Core_MDF_CCP_TestDataUtility.createBudget('Test Budget 2', Core_MDF_CCP_TestDataUtility.Budget_Record_Type, acc2.Id, cp1.Id, 3000000, System.today().addDays(-4), System.today().addDays(364), false);
        pbm.Core_MDF_Budget_Type_Txt__c='OEM CMP';
        insert pbm;
        PartnerFundAllocation pfaRecord = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('Test PFA', pbm, acc2, 3000000, true);
        
        pbm.IsIgnoreValidation = true;
        update pbm;
        
        PartnerFundAllocation pfa = [Select id, Amount from PartnerFundAllocation where BudgetId =: pbm.Id and Title='Test PFA' limit 1];
        
        Campaign camp = Core_MDF_CCP_TestDataUtility.createCampaign('Test Camp 12','Gaming','Intel® Core™ i7 Processor','Yes', Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 'Client CoMarketing Fund', System.today().addDays(-2), System.today().addDays(300), 100000, 'Always Connected PC', acc2.Id,'Desktop', false);
        camp.Core_MDF_Opal_Budget_Type_Txt__c = 'OEM CMP';
        camp.Core_MDF_Budget_Amount_amt__c = 1000000;
        camp.Core_MDF_Total_Campaign_Cost_Amt__c = 1000000;
        insert(camp);    
            
        List<Core_Trigger_Executions__c> executionList = new List<Core_Trigger_Executions__c>();
        Core_Trigger_Executions__c claimFunctionalityNameTriggerExecution = new Core_Trigger_Executions__c();
        claimFunctionalityNameTriggerExecution.Core_Active__c = true;
        claimFunctionalityNameTriggerExecution.Core_Class_Name__c = 'Core_MDF_ProcessCCP_Claim';
        claimFunctionalityNameTriggerExecution.Core_Trigger_Events__c = 'after insert';
        claimFunctionalityNameTriggerExecution.Core_Object__c = 'PartnerFundClaim';
        claimFunctionalityNameTriggerExecution.Name = 'fundReservation';
        claimFunctionalityNameTriggerExecution.Core_Description__c = 'description';
        executionList.add(claimFunctionalityNameTriggerExecution);
        Core_Trigger_Executions__c claimFunctionalityNameTriggerExecution2 = new Core_Trigger_Executions__c();
        claimFunctionalityNameTriggerExecution2.Core_Active__c = true;
        claimFunctionalityNameTriggerExecution2.Core_Class_Name__c = 'Core_MDF_ProcessCCP_Claim';
        claimFunctionalityNameTriggerExecution2.Core_Trigger_Events__c = 'before insert';
        claimFunctionalityNameTriggerExecution2.Core_Object__c = 'PartnerFundClaim';
        claimFunctionalityNameTriggerExecution2.Name = 'checkESDHoldAndUpdateClaimStatus';
        claimFunctionalityNameTriggerExecution2.Core_Description__c = 'check ESD hold for the bank selected on Claim and change Claim status to Hold if it is on ESD Hold';
        executionList.add(claimFunctionalityNameTriggerExecution2);
        Core_Trigger_Executions__c claimFunctionalityNameTriggerExecution1 = new Core_Trigger_Executions__c();
        claimFunctionalityNameTriggerExecution1.Core_Active__c = true;
        claimFunctionalityNameTriggerExecution1.Core_Class_Name__c = 'Core_MDF_ProcessCCP_Claim';
        claimFunctionalityNameTriggerExecution1.Core_Trigger_Events__c = 'before insert';
        claimFunctionalityNameTriggerExecution1.Core_Object__c = 'PartnerFundClaim';
        claimFunctionalityNameTriggerExecution1.Name = 'duplicateClaimCheck';
        claimFunctionalityNameTriggerExecution1.Core_Description__c = 'check ESD hold for the bank selected on Claim and change Claim status to Hold if it is on ESD Hold';
        executionList.add(claimFunctionalityNameTriggerExecution1);
        
        Database.insert(executionList); 
        
        Core_MDF_Bank__c bank = Core_MDF_CCP_TestDataUtility.createBank(acc1.Id, 'Core_MDF_Client_CoMarketing_Fund', false,'1231231230');
        bank.Core_MDF_Payment_Currency_Cd__c = 'USD';    
        bank.Core_MDF_Bank_Status__c='Active';
        //System.runAs(usr){
        insert bank;
        
        //}
        Core_MDF_Account_Bank_Mapping__c accountBankMap = Core_MDF_CCP_TestDataUtility.createAccountBankMap(acc2.Id, bank.Id, true);
        
        
        Test.startTest();
        
       
        PartnerFundRequest testPartnerFundRequestRecord = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(camp.id,Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,acc2.Id,pfa,pbm,'ALBANIA','Consumer','Desktop','Intel® Corporate Logo','Broadcast','Radio','Draft',false);
           
        testPartnerFundRequestRecord.Amount = testPartnerFundRequestRecord.RequestedAmount;
        testPartnerFundRequestRecord.Core_MDF_Budget_Type_nm__c ='OEM CMP';
        testPartnerFundRequestRecord.AllocationId = pfa.Id;
        testPartnerFundRequestRecord.Status = 'Approved';
        testPartnerFundRequestRecord.Title = 'indiaActivity';
		testPartnerFundRequestRecord.Amount = 200;
        testPartnerFundRequestRecord.Core_MDF_Reimbursement_Rate_txt__c = '50%';
        
       
        insert testPartnerFundRequestRecord;
           
        
        
        
        Core_MDF_CCP_TestDataUtility.createMDFConfigurationData();
        List<PartnerFundClaim> claimsToBeInserted = new List<PartnerFundClaim>();
        List<PartnerFundClaim> claimsToBeUpdated = new List<PartnerFundClaim>();
        PartnerFundClaim claim1 = Core_MDF_CCP_TestDataUtility.createClaim('Test Claim', Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, testPartnerFundRequestRecord.Id, System.today(), System.today(), 50.00, System.today(), bank.Id, false);
        //claimsToBeInserted.add(claim1);
        claim1.Status = Label.Core_MDF_Status_Approved;
        claim1.Core_MDF_Status__c = Label.Core_MDF_Status_Payment_Due;
        claimsToBeUpdated.add(claim1);
        
        PartnerFundClaim claim2 = Core_MDF_CCP_TestDataUtility.createClaim('Test Claim2', Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, testPartnerFundRequestRecord.Id, System.today(), System.today(), 50.00, System.today(), bank.Id, false);
        //claimsToBeInserted.add(claim2);
        claim2.Status = Label.Core_MDF_Status_Approved;
        claim2.Core_MDF_Criteria_Hold_Ind__c = true;
        claim2.Core_MDF_Intel_Manual_Hold_Ind__c =true;
        claim2.Core_MDF_Status__c = 'hold';        
        claimsToBeUpdated.add(claim2);  
        
        //Database.insert(claimsToBeInserted); 
       
        
        PartnerFundClaim claim3 = Core_MDF_CCP_TestDataUtility.createClaim('Test Claim3', Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, testPartnerFundRequestRecord.Id, System.today(), System.today(), -50.00, System.today(), bank.Id, false);
        claim3.Status = Label.Core_MDF_Status_Submitted;
        claim3.Core_MDF_Status__c = Label.Core_MDF_Status_Pending_Available_Fund;
        claim3.Core_MDF_Type_Txt__c = Label.Core_MDF_Claim_Type_to_be_excluded;
        claimsToBeUpdated.add(claim3);
        Database.upsert(claimsToBeUpdated);
        
        Test.stopTest();
        
        Core_MDF_Configuration__c config8 = new Core_MDF_Configuration__c();
        config8.Core_MDF_Value__c = 'Core_MDF_CCP_RMF_Internal_Claim_Operations';
        config8.Name = 'PRC_CLAIM_OPERATION_CUSTOM_PERMISSION';
        insert config8;
        Core_MDF_Configuration__c config9 = new Core_MDF_Configuration__c();
        config9.Core_MDF_Value__c = 'Core_MDF_CCP_Internal_CSC_Claim_Submitter';
        config9.Name = 'CSC_CLAIM_SUBMITTER_CUSTOM_PERMISSION';
        insert config9;
        }
        
    }
    
    @isTest static void validatecheckAccess(){ 
        
        Test.startTest();
        
        
        User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        User extUser = [SELECT Id,Email from User where Email='test1@example.com' limit 1];
        
        System.runAs(sysAdminUser){
            
            PartnerFundClaim claim = [Select Id,Core_MDF_Status__c from PartnerFundClaim where Title = 'Test Claim' limit 1];

            
            //System.assertEquals(true, Core_MDF_PFC_Cancel.isClaimEligibleForCancel(claim.Id).claimEligibleForCancel);
            
            claim.Core_MDF_Audit_Hold__c = true;
            claim.Core_MDF_Status__c = Label.Core_MDF_Status_Hold;
            claim.Status = Label.Core_MDF_Status_Submitted;
            claim.Core_MDF_Invoice_Date__c = System.today().addDays(-1);
            update claim;   
            
            
            PermissionSet claimSubmitterPermissionSet = [SELECT Id, Name FROM PermissionSet where Name = 'Core_MDF_CCP_External_Claim_Submitter'];        
            PermissionSetAssignment  psa = new PermissionSetAssignment(PermissionSetId = claimSubmitterPermissionSet.Id, AssigneeId = extUser.Id); // For External user we are assigning ClaimSubmitterPS
            insert psa;
            
            PartnerFundClaimShare sharewithExt = new PartnerFundClaimShare(ParentId = claim.Id, UserOrGroupId = extUser.Id, AccessLevel = 'Read');
            Database.insert(sharewithExt);    
            
        }
        
        System.runAs(extUser){
            
            PartnerFundClaim claim = [Select Id,Core_MDF_Status__c from PartnerFundClaim where Title = 'Test Claim' limit 1];
            
            System.assertEquals(false, Core_MDF_PFC_Cancel.isClaimEligibleForCancel(claim.Id).claimEligibleForCancel);
            
        } 
        
        Test.stopTest();
    }
    
    @isTest static void validateCancelClaim(){ 
        
        Test.startTest();
        User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        User clmCaseUser = [SELECT Id,Email from User where Email='clmcase@example.com' limit 1];
        
        PartnerFundRequest indiaActivity = [SELECT Title,Core_MDF_Start_Date__c from PartnerFundRequest where Title='indiaActivity' limit 1];
        Core_MDF_Bank__c indiaBank = [Select ID from Core_MDF_Bank__c limit 1];
        
        System.runAs(clmCaseUser){
            PartnerFundClaim indiaClaim = [select id,Core_MDF_Status__c from PartnerFundClaim where Title = 'Test Claim' limit 1];
            /*PartnerFundClaim indiaClaim = Core_MDF_CCP_TestDataUtility.createClaim('India Claim1', Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF, 
                                                                                   indiaActivity.Id, 
                                                                                   indiaActivity.Core_MDF_Start_Date__c, indiaActivity.Core_MDF_Start_Date__c, 
                                                                                   101, 
                                                                                   System.today().addDays(-1), indiaBank.ID, true);
            */
            indiaClaim.Core_MDF_Status__c = 'PIC Pending';
            update indiaClaim;
            List<Id> claimId = new List<Id>();    
            claimId.add(indiaClaim.Id);
            
            //if(Core_MDF_PFC_Cancel.isClaimEligibleForCancel(indiaClaim.Id).claimEligibleForCancel){
                Core_MDF_PFC_Cancel.cancelClaims(claimId);
            //}
            //PartnerFundClaim claimUpdated = [Select Id,Core_MDF_Status__c,Status from PartnerFundClaim where Title = 'India Claim' limit 1];
            //System.assertEquals(Label.Core_MDF_Status_Cancelled, indiaClaim.Core_MDF_Status__c);
            //System.assertEquals(Label.Core_MDF_Status_Rejected, indiaClaim.Status);
        }
        Test.stopTest();
    }
    
    @isTest static void testHoldIndicator()
    {
        Test.startTest();
        User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        System.runAs(sysAdminUser)
        {
            PartnerFundClaim claim = [Select Id,Core_MDF_Audit_Hold__c,Core_MDF_VAT_Hold_Ind__c,Core_MDF_Document_Hold_Ind__c,Core_MDF_Intel_Manual_Hold_Ind__c,Core_MDF_Criteria_Hold_Ind__c,Core_MDF_Status__c from PartnerFundClaim where Title = 'Test Claim2' limit 1]; 
            boolean result = Core_MDF_PFC_Cancel.isClaimOnHold(claim);
            System.assertEquals(result, false);          
        }
        Test.stopTest();
    }
    @isTest static void testHoldIndicatorFail()
    {
        Test.startTest();
        User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        System.runAs(sysAdminUser)
        {
            PartnerFundClaim claim = [Select Id,Core_MDF_Audit_Hold__c,Core_MDF_VAT_Hold_Ind__c,Core_MDF_Document_Hold_Ind__c,Core_MDF_Intel_Manual_Hold_Ind__c,Core_MDF_Criteria_Hold_Ind__c,Core_MDF_Member_Manual_Hold_Ind__c,Core_MDF_ESD_Hold__c,Core_MDF_Payment_Hold_ind__c,Core_MDF_Status__c from PartnerFundClaim where Title = 'Test Claim' limit 1]; 
            boolean result = Core_MDF_PFC_Cancel.isClaimOnHold(claim);
            System.assertEquals(result, false);             
        }
        Test.stopTest();
    }
    
    @isTest static void validateNegativeClaim(){ 
        
        Test.startTest();
        
        Set<Id> pfcSet = new Set<Id>();
        User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        User extUser = [SELECT Id,Email from User where Email='test2@intel.com' limit 1];
        
        Group grp = [SELECT Id, Name, DeveloperName FROM Group where DeveloperName = 'Core_MDF_CCP_Claim_Case_Reviewer_Q_Group'];
        Group grp2 = [SELECT Id, Name, DeveloperName FROM Group where DeveloperName = 'Core_All_Users_CCP_Internal'];
        
        System.runAs(sysAdminUser){
            
            PermissionSet claimCaseReviewerPermissionSet = [SELECT Id, Name FROM PermissionSet where Name = 'Core_MDF_CCP_Internal_Claim_Case_Reviewer_Manager'];        
            PermissionSetAssignment  psa = new PermissionSetAssignment(PermissionSetId = claimCaseReviewerPermissionSet.Id, AssigneeId = extUser.Id);
            insert psa;
            
            
            GroupMember grpMem = new GroupMember();
            grpMem.GroupId = grp.Id;
            grpMem.UserOrGroupId = extUser.Id;
            GroupMember grpMem2 = new GroupMember();
            grpMem2.GroupId = grp2.Id;
            grpMem2.UserOrGroupId = extUser.Id;
            Database.insert(grpMem2);
            
            PartnerFundClaim claim = [Select Id,Core_MDF_Status__c from PartnerFundClaim where Title = 'Test Claim3' limit 1];
            claim.Core_MDF_Invoice_Date__c = System.today().addDays(-1);
            claim.OwnerId = extUser.Id;
            update claim;    
            
            pfcSet.add(claim.id);
        }
        
        System.runAs(extUser){
            
            PartnerFundClaim claim = [Select Id,Core_MDF_Status__c from PartnerFundClaim where Title = 'Test Claim3' limit 1];
            Core_MDF_Claim_VAT_Info__c vatInfo = new Core_MDF_Claim_VAT_Info__c();
            //vatInfo.Core_MDF_Document_Type_Txt__c = 'VAT Invoice';
            vatInfo.Core_MDF_Status_Txt__c = 'Approved';
            vatInfo.Core_MDF_Claim_Id__c = claim.Id;
            Insert vatInfo;
            
            System.assertEquals(true, Core_MDF_PFC_Cancel.isClaimEligibleForCancel(String.valueOf(claim.Id)).claimEligibleForCancel);
            
            System.assertEquals(false, Core_MDF_PFC_Cancel.isClaimEligibleForCancel(String.valueOf(claim.Id)).restrictClaimOperator);
            Core_MDF_PFC_Cancel.cancelVatInformation(pfcSet);
        } 
        
        Test.stopTest();
    }
    
    @isTest static void validatecancelledClaim(){ 
        
        Test.startTest();
        
        
        User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        User extUser = [SELECT Id,Email from User where Email='test2@intel.com' limit 1];
        
        Group grp = [SELECT Id, Name, DeveloperName FROM Group where DeveloperName = 'Core_MDF_CCP_Claim_Case_Reviewer_Q_Group'];
        Group grp2 = [SELECT Id, Name, DeveloperName FROM Group where DeveloperName = 'Core_All_Users_CCP_Internal'];
        
        System.runAs(sysAdminUser){
            
            PermissionSet claimCaseReviewerPermissionSet = [SELECT Id, Name FROM PermissionSet where Name = 'Core_MDF_CCP_Internal_Claim_Case_Reviewer_Manager'];        
            PermissionSetAssignment  psa = new PermissionSetAssignment(PermissionSetId = claimCaseReviewerPermissionSet.Id, AssigneeId = extUser.Id);
            insert psa;
            
            
            GroupMember grpMem = new GroupMember();
            grpMem.GroupId = grp.Id;
            grpMem.UserOrGroupId = extUser.Id;
            GroupMember grpMem2 = new GroupMember();
            grpMem2.GroupId = grp2.Id;
            grpMem2.UserOrGroupId = extUser.Id;
            Database.insert(grpMem2);
            
            PartnerFundClaim claim = [Select Id,Core_MDF_Status__c from PartnerFundClaim where Title = 'Test Claim' limit 1];
            
            claim.Core_MDF_Status__c = Label.Core_MDF_Status_Cancelled;
            claim.Status = Label.Core_MDF_Status_Rejected;
            claim.OwnerId = extUser.Id;
            claim.Core_MDF_Invoice_Date__c = System.today().addDays(-1);            
            update claim;      
            
        }
        
        System.runAs(extUser){
            
            PartnerFundClaim claim = [Select Id,Core_MDF_Status__c from PartnerFundClaim where Title = 'Test Claim' limit 1];
            
            System.assertEquals(false, Core_MDF_PFC_Cancel.isClaimEligibleForCancel(String.valueOf(claim.Id)).claimEligibleForCancel);
            
            System.assertEquals(false, Core_MDF_PFC_Cancel.isClaimEligibleForCancel(String.valueOf(claim.Id)).restrictClaimOperator);
            
        } 
        
        Test.stopTest();
    }
    @isTest static void validatecheckhold(){ 
        
        Test.startTest();
        
        
        User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        User extUser = [SELECT Id,Email from User where Email='test1@example.com' limit 1];
        
        System.runAs(sysAdminUser){
            
            PartnerFundClaim claim = [Select Id,Core_MDF_Status__c from PartnerFundClaim where Title = 'Test Claim' limit 1];
            
            
            //System.assertEquals(true, Core_MDF_PFC_Cancel.isClaimEligibleForCancel(claim.Id).claimEligibleForCancel);
            
            //claim.Core_MDF_Criteria_Hold_Ind__c = true;
            claim.Core_MDF_Status__c = Label.Core_MDF_Claim_Status_PIC_Pending;
            claim.Status = Label.Core_MDF_Status_Submitted;
            claim.Core_MDF_Invoice_Date__c = System.today().addDays(-1);
            update claim;  
            
            
            PermissionSet claimSubmitterPermissionSet = [SELECT Id, Name FROM PermissionSet where Name = 'Core_MDF_CCP_External_Claim_Submitter'];        
            PermissionSetAssignment  psa = new PermissionSetAssignment(PermissionSetId = claimSubmitterPermissionSet.Id, AssigneeId = extUser.Id); // For External user we are assigning ClaimSubmitterPS
            insert psa;
            
            PartnerFundClaimShare sharewithExt = new PartnerFundClaimShare(ParentId = claim.Id, UserOrGroupId = extUser.Id, AccessLevel = 'Read');
            Database.insert(sharewithExt);    
            
        }
        
        System.runAs(extUser){
            
            PartnerFundClaim claim = [Select Id,Core_MDF_Status__c from PartnerFundClaim where Title = 'Test Claim' limit 1];
            
            System.assertEquals(true, Core_MDF_PFC_Cancel.isClaimEligibleForCancel(claim.Id).claimEligibleForCancel);
            
        } 
        
        Test.stopTest();
    }
    
}