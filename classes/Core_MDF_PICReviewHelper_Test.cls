@isTest(SeeAllData = false)
public class Core_MDF_PICReviewHelper_Test {
@TestSetup static void setUpData(){
        
        Profile sysAdminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        
        List<User> userlist = new List<User>();
        
        
        
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);        
        usr.LastName = 'System Adm';
        usr.ProfileId = sysAdminProfile.Id;
        usr.isActive = true;
        usr.Email = 'sysadmin@example.com';
        userlist.add(usr);
        
        
        
        
        // Creating channel program with utility class
        ChannelProgram cp1 = Core_MDF_CCP_TestDataUtility.createProgram ('Client Co-Marketing Fund','Client CoMarketing Fund', true);
        
        // Creating Account with utility class
        Account acc1 = Core_MDF_CCP_TestDataUtility.createIntelAccount('Test Account 1', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, true);
        
        Account acc2 = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test Account 2', cp1.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, acc1.Id, true);
        
        Account acc3 = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test Account 3', cp1.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, acc2.Id, true);
        
        

        
        Profile ccpProfile = [SELECT Id FROM Profile WHERE Name='CCP - Core Access'];
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        
        User usr1 = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr1.ProfileId = ccpProfile.Id;
        usr1.Email='test1@intel.com';
        usr1.isActive = true;
        usr1.UserPermissionsMarketingUser=true;
        
        userlist.add(usr1);
        
        Database.insert(userlist);
        
        system.runAs(usr){
            PermissionSet claimCaseReviewerPermissionSet = [SELECT Id, Name FROM PermissionSet where Name = 'Core_MDF_CCP_Internal_Claim_Case_Reviewer_Manager'];        
            PermissionSetAssignment  psa = new PermissionSetAssignment(PermissionSetId = claimCaseReviewerPermissionSet.Id, AssigneeId = usr1.Id);
            insert psa;
        
        
        Core_MDF_CCP_TestDataUtility.insertCurrencyExchangeRates();
		List<String> bypassFunctionKeys =new List<String>();
            bypassFunctionKeys.add('Bypass_MDF_Budget_Access_Validation');
            bypassFunctionKeys.add('Bypass_MDF_Budget_Status_Validation');
            Set<String> myset1 = new Set<String>();
            List<String> result1 = new List<String>();
			myset1.addAll(bypassFunctionKeys);
            result1.addAll(myset1);
        	List<Core_Trigger_Executions__c> bypassfunctinalitylist1 = Core_MDF_CCP_TestDataUtility.byPassFeature(result1,true,true);
        PartnerMarketingBudget pbm = Core_MDF_CCP_TestDataUtility.createBudget('Test Budget 2', Core_MDF_CCP_TestDataUtility.Budget_Record_Type, acc2.Id, cp1.Id, 30000, System.today().addDays(-4), System.today().addDays(364), false);
        pbm.Core_MDF_Budget_Type_Txt__c = 'CCF 1.0';
        insert pbm;
        
        PartnerFundAllocation pfaRecord = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('Test Partner Fund Allocation', pbm, acc2, 30000, true);
        
        
        
        PartnerFundAllocation pfa = [Select id, Amount from PartnerFundAllocation where BudgetId =: pbm.Id and Title='Test Partner Fund Allocation' limit 1];
        
        Campaign camp = Core_MDF_CCP_TestDataUtility.createCampaign('Test Camp 13','Gaming','Intel® Core™ i7 Processor','Yes', Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 'Client CoMarketing Fund', System.today().addDays(-3), System.today().addDays(300), 10000, 'Always Connected PC', acc2.Id,'Desktop', true);
        
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
        Core_MDF_Configuration__c execution1 = new Core_MDF_Configuration__c();
        execution1.Name = 'ALLOWED_PRG_FOR_RUS_NOTIF';
        execution1.Core_MDF_Category__c = 'Bank Document Hold Logic';
        execution1.Core_MDF_Value__c = 'Retail Marketing Funds,Intel Partner Alliance';
        insert execution1;                 
        List<PartnerFundClaim> pfcList = new List<PartnerFundClaim>();
        List<Core_MDF_PICReviewQuestion__c> prqList = new List<Core_MDF_PICReviewQuestion__c>();
        
        Test.startTest();
        
        
        
        PartnerFundRequest testPartnerFundRequestRecord = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(camp.id,Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,acc2.Id,pfa,pbm,'ALBANIA','Consumer','Desktop','Intel® Corporate Logo','Broadcast','Radio','Draft',false);
        testPartnerFundRequestRecord.Amount = testPartnerFundRequestRecord.RequestedAmount;
        testPartnerFundRequestRecord.Core_MDF_Budget_Type_nm__c = 'CCF 1.0';
        testPartnerFundRequestRecord.Core_MDF_Start_Date__c = System.today()-1;
        testPartnerFundRequestRecord.Core_MDF_End_Date__c = System.today()+2;
        Database.insert(testPartnerFundRequestRecord);
         
        PartnerFundClaim claim1 = Core_MDF_CCP_TestDataUtility.createClaim('PIC Review Claim', Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, testPartnerFundRequestRecord.Id, System.today()-1, System.today()-1, 5000.00, System.today(), bank.Id, false);
        claim1.Core_MDF_Invoice_Date__c = System.today().addDays(-1);
        claim1.Status = Label.Core_MDF_Status_Submitted;
        claim1.Core_MDF_Status__c = label.Core_MDF_Claim_Status_PIC_Pending;
        
        pfcList.add(claim1);
        PartnerFundClaim claim2 = Core_MDF_CCP_TestDataUtility.createClaim('PIC Review Claim1', Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, testPartnerFundRequestRecord.Id, System.today()-1, System.today()-1, 5000.00, System.today(), bank.Id, false);
        claim2.Core_MDF_Invoice_Date__c = System.today().addDays(-1);
        claim2.Status = Label.Core_MDF_Status_Submitted;
        claim2.Core_MDF_Status__c = Label.Core_MDF_Claim_Status_PIC_Pending;
        pfcList.add(claim2);
        PartnerFundClaim claim3 = Core_MDF_CCP_TestDataUtility.createClaim('PIC Review Claim2', Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, testPartnerFundRequestRecord.Id, System.today()-1, System.today()-1, 5000.00, System.today(), bank.Id, false);
        claim3.Core_MDF_Invoice_Date__c = System.today().addDays(-1);
        claim3.Status = Label.Core_MDF_Status_Submitted;
        claim3.Core_MDF_Status__c = Label.Core_MDF_Claim_Status_Paid_and_PIC_Pending;
        pfcList.add(claim3);
        Database.insert(pfcList);
        }
        Test.stopTest();
    }
    @isTest static void validateFailedPicReview(){
        PartnerFundClaim claim1 = [Select Id,Core_MDF_Status__c,Core_MDF_PIC_Review_Completed__c from PartnerFundClaim where Title = 'PIC Review Claim' limit 1];
        claim1.Core_MDF_Status__c = label.Core_MDF_Claim_Status_PIC_Pending;
        update claim1;
        User usr = [SELECT Id,Name FROM User where Email = 'sysadmin@example.com' LIMIT 1];
        Test.startTest();
          Core_MDF_PIC_Review__c picReview = Core_MDF_CCP_TestDataUtility.insertPICReview(1,'int comments',System.today()-2,System.today()+2,claim1.Id,usr.Id,true);
          Core_MDF_PIC_Review__c picReview1 = Core_MDF_CCP_TestDataUtility.insertPICReview(2,'int comments',System.today()-2,System.today()+2,claim1.Id,usr.Id,true);
        system.debug('claim1'+claim1.Core_MDF_Status__c); 
        Test.stopTest();
    }
    
       @isTest static void validateCompletedPicReview(){
        PartnerFundClaim claim1 = [Select Id,Core_MDF_Status__c,Core_MDF_PIC_Review_Completed__c from PartnerFundClaim where Title = 'PIC Review Claim2' limit 1];
        claim1.Core_MDF_Status__c = label.Core_MDF_Claim_Status_Paid_and_PIC_Pending;
        update claim1;
           User usr = [SELECT Id,Name FROM User where Email = 'sysadmin@example.com' LIMIT 1];
        Test.startTest();
       
         Core_MDF_PIC_Review__c picReview = Core_MDF_CCP_TestDataUtility.insertPICReview(1,'int comments',System.today()-2,System.today()+2,claim1.Id,usr.Id,false);
       
        Test.stopTest();
    }
    
     @isTest static void validateCompletedPicReview1(){
        PartnerFundClaim claim1 = [Select Id,Core_MDF_Status__c,Core_MDF_PIC_Review_Completed__c from PartnerFundClaim where Title = 'PIC Review Claim' limit 1];
        claim1.Core_MDF_Status__c = label.Core_MDF_Claim_Status_PIC_Pending;
        update claim1;
        User usr = [SELECT Id,Name FROM User where Email = 'sysadmin@example.com' LIMIT 1];
        Test.startTest();
       
        Core_MDF_PIC_Review__c picReview = Core_MDF_CCP_TestDataUtility.insertPICReview(1,'int comments',System.today()-2,System.today()+2,claim1.Id,usr.Id,false);
        //Core_MDF_PIC_Review__c picReview1 = Core_MDF_CCP_TestDataUtility.insertPICReview(2,'int comments',System.today()-2,System.today()+2,claim1.Id,usr.Id,false);

        Test.stopTest();
    }
    @isTest static void validateFailedPicReview1(){
        PartnerFundClaim claim1 = [Select Id,Core_MDF_Status__c,Core_MDF_PIC_Review_Completed__c from PartnerFundClaim where Title = 'PIC Review Claim' limit 1];
        claim1.Core_MDF_Status__c = label.Core_MDF_Claim_Status_Paid_and_PIC_Pending;
        claim1.Core_MDF_Budget_Type_Options_Nm__c='CCF 1.0';
        update claim1;
        User usr = [SELECT Id,Name FROM User where Email = 'sysadmin@example.com' LIMIT 1];
        Test.startTest();
          //Core_MDF_PIC_Review__c picReview = Core_MDF_CCP_TestDataUtility.insertPICReview(1,'int comments',System.today()-2,System.today()+2,claim1.Id,usr.Id,true);
          Core_MDF_PIC_Review__c picReview1 = Core_MDF_CCP_TestDataUtility.insertPICReview(2,'int comments',System.today()-2,System.today()+2,claim1.Id,usr.Id,true);
        system.debug('claim1'+claim1.Core_MDF_Status__c); 
        Test.stopTest();
    }
     @isTest static void validateFailedPicReview2(){
        PartnerFundClaim claim1 = [Select Id,Core_MDF_Status__c,Core_MDF_PIC_Review_Completed__c from PartnerFundClaim where Title = 'PIC Review Claim' limit 1];
        claim1.Core_MDF_Status__c = label.Core_MDF_Claim_Status_PIC_Pending;
        claim1.Core_MDF_Budget_Type_Options_Nm__c='CCF 1.0';
        update claim1;
        User usr = [SELECT Id,Name FROM User where Email = 'sysadmin@example.com' LIMIT 1];
        Test.startTest();
          Core_MDF_PIC_Review__c picReview = Core_MDF_CCP_TestDataUtility.insertPICReview(2,'int comments',System.today()-2,System.today()+2,claim1.Id,usr.Id,true);
          
         Core_MDF_PIC_Review__c picReview1 = Core_MDF_CCP_TestDataUtility.insertPICReview(3,'int comments',System.today()-2,System.today()+2,claim1.Id,usr.Id,true);
        system.debug('claim1'+claim1.Core_MDF_Status__c); 
        Test.stopTest();
    }
    @isTest static void validateFailedPicReview3(){
        PartnerFundClaim claim1 = [Select Id,Core_MDF_Status__c,Core_MDF_PIC_Review_Completed__c from PartnerFundClaim where Title = 'PIC Review Claim' limit 1];
        claim1.Core_MDF_Status__c = label.Core_MDF_Claim_Status_Paid_and_PIC_Pending;
        claim1.Core_MDF_Budget_Type_Options_Nm__c='CCF 1.0';
        update claim1;
        User usr = [SELECT Id,Name FROM User where Email = 'sysadmin@example.com' LIMIT 1];
        Test.startTest();
          Core_MDF_PIC_Review__c picReview = Core_MDF_CCP_TestDataUtility.insertPICReview(2,'int comments',System.today()-2,System.today()+2,claim1.Id,usr.Id,true);
          
         Core_MDF_PIC_Review__c picReview1 = Core_MDF_CCP_TestDataUtility.insertPICReview(3,'int comments',System.today()-2,System.today()+2,claim1.Id,usr.Id,true);
        system.debug('claim1'+claim1.Core_MDF_Status__c); 
        Test.stopTest();
    }
    @isTest static void validateFailedPicReview4(){
        String errMsg='';
		try{
        	PartnerFundClaim claim1 = [Select Id,Core_MDF_Status__c,Core_MDF_PIC_Review_Completed__c from PartnerFundClaim where Title = 'PIC Review Claim' limit 1];
        	claim1.Core_MDF_Status__c = label.Core_MDF_Claim_Status_Paid_and_PIC_Pending;
        	claim1.Core_MDF_Budget_Type_Options_Nm__c='CCF 1.0';
        	update claim1;
        	User usr = [SELECT Id,Name FROM User where Email = 'sysadmin@example.com' LIMIT 1];
        	Test.startTest();
            Core_MDF_PIC_Review__c picReview = Core_MDF_CCP_TestDataUtility.insertPICReview(0,'int comments',System.today()-2,System.today()+2,claim1.Id,usr.Id,true);
          
         	Core_MDF_PIC_Review__c picReview1 = Core_MDF_CCP_TestDataUtility.insertPICReview(1,'int comments',System.today()-2,System.today()+2,claim1.Id,usr.Id,true);
        	system.debug('claim1'+claim1.Core_MDF_Status__c); 
        	Test.stopTest();
		}
		catch(Exception e)
		{
			System.debug('Error msg -->'+e.getMessage());
			errMsg=e.getMessage();
		}
		System.assert(errMsg=='', errMsg);    
	}
    
}