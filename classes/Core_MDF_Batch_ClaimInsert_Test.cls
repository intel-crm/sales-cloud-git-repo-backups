@isTest(SeeAllData = false)
public class Core_MDF_Batch_ClaimInsert_Test {

	 // test method for data setup
	@TestSetup static void setUpData(){

		
		// Creating User with utility class 
		User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
		usr.Email = 'sysadmin@example.com';
		Database.insert(usr);
		
        Profile ccpCoreProfile = [SELECT Id FROM Profile WHERE Name='CCP - Core Access' LIMIT 1];
        PermissionSet clmCaseRevPS = [SELECT Id, Name FROM PermissionSet WHERE Name='Core_MDF_CCP_Internal_Claim_Case_Reviewer' LIMIT 1];
       PermissionSet financeuser = [SELECT Id, Name FROM PermissionSet WHERE Name='Core_MDF_CCP_Internal_Finance_User' LIMIT 1];
        PermissionSet financeMgr = [SELECT Id, Name FROM PermissionSet WHERE Name='Core_MDF_CCP_Internal_Finance_Manager' LIMIT 1];
	 PermissionSet ccfUser = [SELECT Id, Name FROM PermissionSet WHERE Name='Core_MDF_CCP_Internal_CCF_User' LIMIT 1];
        

        User claimCase = Core_MDF_CCP_TestDataUtility.createUser(false);
        claimCase.Email = 'clmcase@example.com';
        claimCase.Profile = ccpCoreProfile;
        insert claimCase;
        List<PermissionSetAssignment> pdAsLit = new List<PermissionSetAssignment>();
        PermissionSetAssignment assignPermissionSetObj = new PermissionSetAssignment();
        assignPermissionSetObj.AssigneeId = claimCase.Id;
        assignPermissionSetObj.PermissionSetId = clmCaseRevPS.Id;
        pdAsLit.add(assignPermissionSetObj);
         PermissionSetAssignment assignPermissionSetObj1 = new PermissionSetAssignment();
        assignPermissionSetObj1.AssigneeId = claimCase.Id;
        assignPermissionSetObj1.PermissionSetId = financeuser.Id;
         pdAsLit.add(assignPermissionSetObj1);
         PermissionSetAssignment assignPermissionSetObj2 = new PermissionSetAssignment();
        assignPermissionSetObj2.AssigneeId = claimCase.Id;
        assignPermissionSetObj2.PermissionSetId = financeMgr.Id;
        pdAsLit.add(assignPermissionSetObj2);
	PermissionSetAssignment assignPermissionSetObj3 = new PermissionSetAssignment();        
        assignPermissionSetObj3.AssigneeId = claimCase.id;
        assignPermissionSetObj3.PermissionSetId = ccfUser.Id;
        pdAsLit.add(assignPermissionSetObj3);
        system.runas(usr){
            Database.insert(pdAsLit);
        }
        
		List<Account> toBeUpdated = new List<Account>();
		
		// Creating channel program with utility class
		ChannelProgram cp1 = Core_MDF_CCP_TestDataUtility.createProgram ('Client','Client CoMarketing Fund', true);

		// Creating Account with utility class
		Account acc1 = Core_MDF_CCP_TestDataUtility.createIntelAccount('Test Account 1', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, true);
		
		Account acc2 = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test Account 2', cp1.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, acc1.Id, true);
		

		// Updating Accounts 
		acc1.isPartner = true;
		acc2.isPartner = true;
		toBeUpdated.add(acc1);
		toBeUpdated.add(acc2);
		Database.update(toBeUpdated);

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
		 PartnerMarketingBudget pbm = new PartnerMarketingBudget();
        system.runAs(claimCase){
             pbm = Core_MDF_CCP_TestDataUtility.createBudget('Test Budget 2', Core_MDF_CCP_TestDataUtility.Budget_Record_Type, acc2.Id, cp1.Id, 30000, System.today(), System.today().addDays(364), true);
        }
		system.runas(usr){
		//PartnerMarketingBudget pbm = Core_MDF_CCP_TestDataUtility.createBudget('Test Budget 2', Core_MDF_CCP_TestDataUtility.Budget_Record_Type, acc2.Id, cp1.Id, 30000, System.today(), System.today().addDays(364), true);
        
		
		PartnerFundAllocation pfaRecord = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('Test PFA', pbm, acc2, 30000, true);
	   
			pbm.IsIgnoreValidation = true;
			update pbm;
		
			PartnerFundAllocation pfa = [Select id, Amount from PartnerFundAllocation where BudgetId =: pbm.Id and Title='Test PFA' limit 1];
			
			Campaign camp = Core_MDF_CCP_TestDataUtility.createCampaign('Test Camp 12','Gaming','Intel® Core™ i7 Processor', 'Yes', Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 'Client CoMarketing Fund', System.today(), System.today().addDays(300), 10000, 'Always Connected PC', acc2.Id,'Desktop', false);
        	camp.Core_MDF_Opal_Budget_Type_Txt__c = 'OEM CMP';
			insert camp;
        
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
        
        	Core_MDF_Bank__c bank = Core_MDF_CCP_TestDataUtility.createBank(acc1.Id, 'Core_MDF_Client_CoMarketing_Fund', true,'1231231230');
			Core_MDF_Account_Bank_Mapping__c accountBankMap = Core_MDF_CCP_TestDataUtility.createAccountBankMap(acc2.Id, bank.Id, true);

		
        Test.startTest();
        
        
		PartnerFundRequest testPartnerFundRequestRecord = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(camp.id,Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,acc2.Id,pfa,pbm,'ALBANIA','Consumer','Desktop','Intel® Corporate Logo','Broadcast','Radio','Draft',true);
			
        testPartnerFundRequestRecord.Amount = testPartnerFundRequestRecord.RequestedAmount;
			//testPartnerFundRequestRecord.AllocationId = pfa.Id;
			testPartnerFundRequestRecord.Status = 'Approved';
        	testPartnerFundRequestRecord.Title = 'indiaActivity';
       
        
			update testPartnerFundRequestRecord;
			
        
        }
    }
    
    @isTest static void validateClaimInsertBatch(){ 
		
		Test.startTest();
		User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
		
        PartnerFundRequest indiaActivity = [SELECT Title,Core_MDF_Start_Date__c from PartnerFundRequest where Title='indiaActivity' limit 1];
        Core_MDF_Bank__c indiaBank = [Select ID from Core_MDF_Bank__c limit 1];
        
		
	    List<PartnerFundClaim> claimsToBeInserted = new List<PartnerFundClaim>();
		PartnerFundClaim claim1 = Core_MDF_CCP_TestDataUtility.createClaim('Test Claim', Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, indiaActivity.Id, System.today(), System.today(), 500.00, System.today(), indiaBank.Id, false);
		claimsToBeInserted.add(claim1);
		
		PartnerFundClaim claim2 = Core_MDF_CCP_TestDataUtility.createClaim('Test Claim2', Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, indiaActivity.Id, System.today(), System.today(), 500.00, System.today(), indiaBank.Id, false);
		claimsToBeInserted.add(claim2);	
        
        Core_MDF_ClaimStage_ServiceHandler.stageAndClaimRecWrapper wrapperInst = new Core_MDF_ClaimStage_ServiceHandler.stageAndClaimRecWrapper();
        wrapperInst.nonduplicateClaims.addAll(claimsToBeInserted);
        Core_MDF_BatchClaimHelper.insertClaimsAndUpdateClaimStageRecords(wrapperInst);
        Test.stopTest();
        
        
       // Core_MDF_Batch_ClaimInsert claimInsertbatch = new Core_MDF_Batch_ClaimInsert(claimsToBeInserted);
        //Parameters of ExecuteBatch(context,BatchSize)
       // database.executebatch(claimInsertbatch,30);
        
        //PartnerFundClaim newClaim1 = [Select Id from PartnerFundClaim where Title = 'Test Claim' limit 1];
       // PartnerFundClaim newClaim2 = [Select Id from PartnerFundClaim where Title = 'Test Claim2' limit 1];
        
        //System.assertNotEquals(null, newClaim1.Id);
        //System.assertNotEquals(null, newClaim2.Id);
        
    }
}