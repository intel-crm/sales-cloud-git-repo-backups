/****************************************************************************************************************************************
* Class Name  : Core_MDF_PartnerFundClaim_Test
* Version     : 1.0 
* Created Date: 4-May-2019
* Modification Log :
* Developer    Intel :Areefa      Date:4-May-2019       Description:Claim Manual Hold Functionalty 
*****************************************************************************************************************************************/
@isTest(SeeAllData=false)
Private class Core_MDF_PFC_ManualHold_Claim_Test {    
    
    /* Method to Setup Test Data */
    @TestSetup static void setUpData(){        
        
        // Creating User with utility class 
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.Email = 'sysadmin@example.com';
        Database.insert(usr);
        
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
        
        Contact conRecord1 = Core_MDF_CCP_TestDataUtility.createContact(acc1.Id,true);

        Id profileId = [SELECT Id FROM Profile WHERE Name='Partner' limit 1].Id;
        User usr1 = Core_MDF_CCP_TestDataUtility.createUser(false);        
        usr1.Email='test1@example.com';
        usr1.ContactId = conRecord1.Id;
        usr1.ProfileId = profileId;
        usr1.isActive = true;
        Database.insert(usr1);        
        
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
        
        
        Test.startTest();
        PartnerMarketingBudget pbm = Core_MDF_CCP_TestDataUtility.createBudget('Test Budget 2', Core_MDF_CCP_TestDataUtility.Budget_Record_Type, acc2.Id, cp1.Id, 30000, System.today(), System.today().addDays(364), true);
        
        PartnerFundAllocation pfaRecord = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('Test PFA', pbm, acc2, 30000, true);
        
        
        pbm.IsIgnoreValidation = true;
        update pbm;
        
        PartnerFundAllocation pfa = [Select id, Amount from PartnerFundAllocation where BudgetId =: pbm.Id and Title='Test PFA' limit 1];
        
        Campaign camp = Core_MDF_CCP_TestDataUtility.createCampaign('Test Camp 12','Gaming','Intel® Core™ i7 Processor', Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 'Client CoMarketing Fund', System.today(), System.today().addDays(300), 10000, 'Always Connected PC', acc2.Id,'Desktop', true);
        
        PartnerFundRequest testPartnerFundRequestRecord = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(camp.id,Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,acc2.Id,pfa,pbm,'ALBANIA','Consumer','Desktop','Intel® Corporate Logo','Broadcast','Radio','Draft',true);
        testPartnerFundRequestRecord.Amount = testPartnerFundRequestRecord.RequestedAmount;
        //testPartnerFundRequestRecord.AllocationId = pfa.Id;
        testPartnerFundRequestRecord.Status = 'Approved';
        update testPartnerFundRequestRecord;
        
        Core_MDF_Bank__c bank = Core_MDF_CCP_TestDataUtility.createBank(acc1.Id, 'Core_MDF_Client_CoMarketing_Fund', true,'1231231230');
        Core_MDF_Account_Bank_Mapping__c accountBankMap = Core_MDF_CCP_TestDataUtility.createAccountBankMap(acc2.Id, bank.Id, true);
        
       //testStop
        
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
        
        
        PartnerFundClaim claim1 = Core_MDF_CCP_TestDataUtility.createClaim('Test Claim For Manual Hold', Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, testPartnerFundRequestRecord.Id, System.today(), System.today(), 5000.00, System.today(), bank.Id, true);
        claim1.Status = Label.Core_MDF_Status_Approved;
        claim1.Core_MDF_Status__c = Label.Core_MDF_Status_Pending_Available_Fund; //'Pending Available Fund';
        update claim1;
         Test.stopTest();
        PartnerFundClaim claim2 = Core_MDF_CCP_TestDataUtility.createClaim('Test isMemEligibleForEdit', Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, testPartnerFundRequestRecord.Id, System.today(), System.today(), 5000.00, System.today(), bank.Id, true);
        claim2.Status = Label.Core_MDF_Status_Approved;
        claim2.Core_MDF_Status__c = 'Pending Available Fund';
        claim2.Core_MDF_Intel_Manual_Hold_Ind__c = true;
        update claim2;
        
       
        
        PartnerFundClaim claim3 = Core_MDF_CCP_TestDataUtility.createClaim('Test Claim3', Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, testPartnerFundRequestRecord.Id, System.today(), System.today(), -5000.00, System.today(), bank.Id, false);
		claim3.Status = Label.Core_MDF_Status_Submitted;
		claim3.Core_MDF_Status__c = Label.Core_MDF_Status_Pending_Available_Fund;
		claim3.Core_MDF_Type_Txt__c = Label.Core_MDF_Claim_Type_to_be_excluded;
		insert claim3;
                
    }  
    
   /*check user has access to Manual Hold Claim or not*/
   @isTest static void checkingUserPermission(){
        test.startTest();
        
        //checking if user doesn't have permission
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.LastName = 'User Test';
        Database.insert(usr);
        System.runAs(usr){
            Boolean resultUserhasPerm = Core_MDF_PFC_ManualHold_Claim.hasAccess();
            System.assertEquals(false, resultUserhasPerm);
        }
        test.stopTest();
    }
    
    /*isPartner*/
    @isTest static void checkisPartner(){
        test.startTest();
        
        User usr1 = [SELECT Id,Email from User where Email='test1@example.com' limit 1];        
        
        System.runAs(usr1){
            Boolean isPartner = Core_MDF_PFC_ManualHold_Claim.isPartner();
            System.assertEquals(true, isPartner);
        }
        test.stopTest();
    }
    
    /* Method to test Manual Hold details details */
    @isTest
    static void testcheckClaimForHold()
    {
        test.startTest();
        //PartnerFundRequest pfr = [Select Id,Title from PartnerFundRequest where Title = 'test'];        
        PartnerFundClaim pfr = [SELECT Id, Title FROM PartnerFundClaim where Title='Test Claim For Manual Hold'];
        Core_MDF_PFC_ManualHold_Claim.HoldClaimDetails claimWrapper = Core_MDF_PFC_ManualHold_Claim.getClaimAndHoldDeatils(pfr.Id);
        system.assertNotEquals(claimWrapper.claimObj , NULL);
        test.stopTest();
    }
        
    /*Get Hold details*/
    @isTest
    static void testgetHoldDetails()
    {
        test.startTest();
        //PartnerFundClaim pfr = [SELECT Id, Core_MDF_Status__c,Core_MDF_Intel_Manual_Hold_Ind__c, Core_MDF_Member_Manual_Hold_Ind__c FROM PartnerFundClaim where Title = 'test'];
        PartnerFundClaim pfr = [SELECT Id, Title FROM PartnerFundClaim where Title='Test Claim For Manual Hold'];
        PartnerFundClaim pfrObj = Core_MDF_PFC_ManualHold_Claim.getClaimHoldStatus(pfr.Id);
        System.assertNotEquals(pfrObj , NULL);
        test.stopTest();
    }
    
    /*manual hold update*/
    @isTest
    public static void testUpdateClaimOnManualHoldById(){
        test.startTest();   
                    
       User usr1 = [SELECT Id,Email from User where Email='test1@example.com' limit 1]; 
        
        User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];  
        
        System.runAs(sysAdminUser)
        {           
            
            PartnerFundClaim pfr1 = [SELECT Id, Title FROM PartnerFundClaim where Title='Test Claim For Manual Hold']; 
            
            PartnerFundClaimShare sharewithExt = new PartnerFundClaimShare(ParentId = pfr1.Id, UserOrGroupId = usr1.Id, AccessLevel = 'Edit');
            Database.insert(sharewithExt);            
            
            boolean claimRec = Core_MDF_PFC_ManualHold_Claim.updateClaimOnManualHold(pfr1.Id, ' Test Claim For Manual Hold put on Manual Hold');
            PartnerFundClaim claimAfterUpdate = [Select Id,Core_MDF_Intel_Manual_Hold_Ind__c  ,Core_MDF_Status__c from PartnerFundClaim where Title = 'Test Claim For Manual Hold']; //Id =: claim1.Id];
            System.assertEquals(Label.Core_MDF_Status_Hold, claimAfterUpdate.Core_MDF_Status__c);
            System.assertEquals(true, claimAfterUpdate.Core_MDF_Intel_Manual_Hold_Ind__c);
            System.assertEquals(true, claimRec);
        }
               
        
        System.runAs(usr1)
        {		
            PartnerFundClaim pfr2 = [SELECT Id, Title FROM PartnerFundClaim where Title='Test Claim For Manual Hold'];
            boolean claimRec = Core_MDF_PFC_ManualHold_Claim.updateClaimOnManualHold(pfr2.Id, ' Test Claim For Manual Hold put on Manual Hold');
            PartnerFundClaim claimAfterUpdate = [Select Id,Core_MDF_Member_Manual_Hold_Ind__c,Core_MDF_Status__c from PartnerFundClaim where Title = 'Test Claim For Manual Hold']; //Id =: claim1.Id];
            System.assertEquals(Label.Core_MDF_Status_Hold, claimAfterUpdate.Core_MDF_Status__c);
            System.assertEquals(true, claimAfterUpdate.Core_MDF_Member_Manual_Hold_Ind__c);
            System.assertEquals(true, claimRec);
        }
        test.stopTest();
        
    }
        
}