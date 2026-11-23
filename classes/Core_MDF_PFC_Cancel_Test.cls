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
        User claimCase = Core_MDF_CCP_TestDataUtility.createUser(false);
        claimCase.Email = 'clmcase@example.com';
        claimCase.Profile = ccpCoreProfile;
        insert claimCase;
        PermissionSetAssignment assignPermissionSetObj = new PermissionSetAssignment();
        assignPermissionSetObj.AssigneeId = claimCase.Id;
        assignPermissionSetObj.PermissionSetId = clmCaseRevPS.Id;
        system.runas(usr){
            Database.insert(assignPermissionSetObj);
        }
        
		List<Account> toBeUpdated = new List<Account>();
		
		// Creating channel program with utility class
		ChannelProgram cp1 = Core_MDF_CCP_TestDataUtility.createProgram ('Client Co-Marketing Fund','Client CoMarketing Fund', true);

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
		
		
		
		PartnerMarketingBudget pbm = Core_MDF_CCP_TestDataUtility.createBudget('Test Budget 2', Core_MDF_CCP_TestDataUtility.Budget_Record_Type, acc2.Id, cp1.Id, 30000, System.today(), System.today().addDays(364), true);
		
		PartnerFundAllocation pfaRecord = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('Test PFA', pbm, acc2, 30000, true);
	   
			pbm.IsIgnoreValidation = true;
			update pbm;
		
			PartnerFundAllocation pfa = [Select id, Amount from PartnerFundAllocation where BudgetId =: pbm.Id and Title='Test PFA' limit 1];
			
			Campaign camp = Core_MDF_CCP_TestDataUtility.createCampaign('Test Camp 12','Gaming','Intel® Core™ i7 Processor', Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 'Client CoMarketing Fund', System.today(), System.today().addDays(300), 10000, 'Always Connected PC', acc2.Id,'Desktop', true);
			
		 Test.startTest();
		
			PartnerFundRequest testPartnerFundRequestRecord = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(camp.id,Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,acc2.Id,pfa,pbm,'ALBANIA','Consumer','Desktop','Intel® Corporate Logo','Broadcast','Radio','Draft',true);
			testPartnerFundRequestRecord.Amount = testPartnerFundRequestRecord.RequestedAmount;
			//testPartnerFundRequestRecord.AllocationId = pfa.Id;
			testPartnerFundRequestRecord.Status = 'Approved';
        	testPartnerFundRequestRecord.Title = 'indiaActivity';
			update testPartnerFundRequestRecord;
			
			Core_MDF_Bank__c bank = Core_MDF_CCP_TestDataUtility.createBank(acc1.Id, 'Core_MDF_Client_CoMarketing_Fund', true,'1231231230');
			Core_MDF_Account_Bank_Mapping__c accountBankMap = Core_MDF_CCP_TestDataUtility.createAccountBankMap(acc2.Id, bank.Id, true);
			
		   
			
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
		 
	   
			
		PartnerFundClaim claim1 = Core_MDF_CCP_TestDataUtility.createClaim('Test Claim', Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, testPartnerFundRequestRecord.Id, System.today(), System.today(), 5000.00, System.today(), bank.Id, true);
		claim1.Status = Label.Core_MDF_Status_Approved;
		claim1.Core_MDF_Status__c = Label.Core_MDF_Status_Payment_Due;
		update claim1;
		
		PartnerFundClaim claim2 = Core_MDF_CCP_TestDataUtility.createClaim('Test Claim2', Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, testPartnerFundRequestRecord.Id, System.today(), System.today(), 5000.00, System.today(), bank.Id, true);
		claim2.Status = Label.Core_MDF_Status_Approved;
		claim2.Core_MDF_Criteria_Hold_Ind__c = true;
		claim2.Core_MDF_Intel_Manual_Hold_Ind__c =true;        
		update claim2;	
		
		 Test.stopTest();
		
		PartnerFundClaim claim3 = Core_MDF_CCP_TestDataUtility.createClaim('Test Claim3', Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, testPartnerFundRequestRecord.Id, System.today(), System.today(), -5000.00, System.today(), bank.Id, false);
		claim3.Status = Label.Core_MDF_Status_Submitted;
		claim3.Core_MDF_Status__c = Label.Core_MDF_Status_Pending_Available_Fund;
		claim3.Core_MDF_Type_Txt__c = Label.Core_MDF_Claim_Type_to_be_excluded;
		insert claim3;
		
	}
		
	@isTest static void validatecheckAccess(){ 
		
		Test.startTest();
		
		
		User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
		User extUser = [SELECT Id,Email from User where Email='test1@example.com' limit 1];
		
		System.runAs(sysAdminUser){
			
		PartnerFundClaim claim = [Select Id from PartnerFundClaim where Title = 'Test Claim' limit 1];
		
		System.assertEquals(true, Core_MDF_PFC_Cancel.isClaimEligibleForCancel(claim.Id).claimEligibleForCancel);
		
		claim.Core_MDF_Audit_Hold__c = true;
		claim.Core_MDF_Status__c = Label.Core_MDF_Status_Hold;
		claim.Status = Label.Core_MDF_Status_Submitted;
		update claim;   
			
			
		PermissionSet claimSubmitterPermissionSet = [SELECT Id, Name FROM PermissionSet where Name = 'Core_MDF_CCP_External_Claim_Submitter'];        
		PermissionSetAssignment  psa = new PermissionSetAssignment(PermissionSetId = claimSubmitterPermissionSet.Id, AssigneeId = extUser.Id);
		insert psa;
		 
		PartnerFundClaimShare sharewithExt = new PartnerFundClaimShare(ParentId = claim.Id, UserOrGroupId = extUser.Id, AccessLevel = 'Read');
			Database.insert(sharewithExt);    
			
		}
		
		System.runAs(extUser){
			
		PartnerFundClaim claim = [Select Id from PartnerFundClaim where Title = 'Test Claim' limit 1];
		
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
            PartnerFundClaim indiaClaim = Core_MDF_CCP_TestDataUtility.createClaim('India Claim', Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF, 
                                                                                   indiaActivity.Id, 
                                                                                   indiaActivity.Core_MDF_Start_Date__c, indiaActivity.Core_MDF_Start_Date__c, 
                                                                                   101, 
                                                                                   System.today().addDays(-1), indiaBank.ID, true);

            List<Id> claimId = new List<Id>();    
            claimId.add(indiaClaim.Id);
            if(Core_MDF_PFC_Cancel.isClaimEligibleForCancel(indiaClaim.Id).claimEligibleForCancel){
                Core_MDF_PFC_Cancel.cancelClaims(claimId);
            }
            PartnerFundClaim claimUpdated = [Select Id,Core_MDF_Status__c,Status from PartnerFundClaim where Title = 'India Claim' limit 1];
            System.assertEquals(Label.Core_MDF_Status_Cancelled, claimUpdated.Core_MDF_Status__c);
            System.assertEquals(Label.Core_MDF_Status_Rejected, claimUpdated.Status);
		}
		Test.stopTest();
	}

	@isTest static void testHoldIndicator()
	{
		Test.startTest();
		User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
		System.runAs(sysAdminUser)
		{
			PartnerFundClaim claim = [Select Id,Core_MDF_Intel_Manual_Hold_Ind__c,Core_MDF_Criteria_Hold_Ind__c from PartnerFundClaim where Title = 'Test Claim2' limit 1]; 
			boolean result = Core_MDF_PFC_Cancel.isClaimOnIntelOrCriteiaHold(claim);
			System.assertEquals(result, true);         	
		}
		Test.stopTest();
	}
	@isTest static void testHoldIndicatorFail()
	{
		Test.startTest();
		User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
		System.runAs(sysAdminUser)
		{
			PartnerFundClaim claim = [Select Id,Core_MDF_Intel_Manual_Hold_Ind__c,Core_MDF_Criteria_Hold_Ind__c from PartnerFundClaim where Title = 'Test Claim' limit 1]; 
			boolean result = Core_MDF_PFC_Cancel.isClaimOnIntelOrCriteiaHold(claim);
			System.assertEquals(result, false);         	
		}
		Test.stopTest();
	}

		@isTest static void validateNegativeClaim(){ 
		
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
		
		PartnerFundClaim claim = [Select Id from PartnerFundClaim where Title = 'Test Claim3' limit 1];
			
			claim.OwnerId = extUser.Id;
			update claim;    
			
		}
		
		System.runAs(extUser){
			
		PartnerFundClaim claim = [Select Id from PartnerFundClaim where Title = 'Test Claim3' limit 1];
			
			System.assertEquals(true, Core_MDF_PFC_Cancel.isClaimEligibleForCancel(String.valueOf(claim.Id)).claimEligibleForCancel);
			
			System.assertEquals(false, Core_MDF_PFC_Cancel.isClaimEligibleForCancel(String.valueOf(claim.Id)).restrictClaimOperator);
			
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
		
		PartnerFundClaim claim = [Select Id from PartnerFundClaim where Title = 'Test Claim' limit 1];
	
		claim.Core_MDF_Status__c = Label.Core_MDF_Status_Cancelled;
		claim.Status = Label.Core_MDF_Status_Rejected;
		claim.OwnerId = extUser.Id;
		update claim;      
			
		}
		
		System.runAs(extUser){
			
		PartnerFundClaim claim = [Select Id from PartnerFundClaim where Title = 'Test Claim' limit 1];
			
			System.assertEquals(false, Core_MDF_PFC_Cancel.isClaimEligibleForCancel(String.valueOf(claim.Id)).claimEligibleForCancel);
			
			System.assertEquals(false, Core_MDF_PFC_Cancel.isClaimEligibleForCancel(String.valueOf(claim.Id)).restrictClaimOperator);
			
		} 
		
		Test.stopTest();
	}

}