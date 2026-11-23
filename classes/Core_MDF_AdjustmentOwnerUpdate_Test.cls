@isTest(SeeAllData = false)
public class Core_MDF_AdjustmentOwnerUpdate_Test {
    
    // test method for data setup
    @TestSetup static void setUpData(){
        
        
        // Creating User with utility class 
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.Email = 'sysadmin@example.com';
        Database.insert(usr);
        
        
        // Creating Account with utility class
        Account acc1 = Core_MDF_CCP_TestDataUtility.createIntelAccount('Test Account 1', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, true);
        
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
        
        
        List<Account> toBeUpdated = new List<Account>();
        
        
        
        // Creating channel program with utility class
        ChannelProgram cp1 = Core_MDF_CCP_TestDataUtility.createProgram ('Client Co-Marketing Fund','Client CoMarketing Fund', true);
        
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
        
        
        
        PartnerMarketingBudget pbm = Core_MDF_CCP_TestDataUtility.createBudget('Test Budget 2', Core_MDF_CCP_TestDataUtility.Budget_Record_Type, acc2.Id, cp1.Id, 30000, System.today(), System.today().addDays(364), false);
        pbm.Core_MDF_Budget_Type_Txt__c='CCF 1.0';
        insert pbm;
        
        PartnerFundAllocation pfaRecord = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('Test PFA', pbm, acc2, 30000, true);
        
        pbm.IsIgnoreValidation = true;
        update pbm;
        
        PartnerFundAllocation pfa = [Select id, Amount from PartnerFundAllocation where BudgetId =: pbm.Id and Title='Test PFA' limit 1];
        
        Campaign camp = Core_MDF_CCP_TestDataUtility.createCampaign('Test Camp 12','Gaming','Intel® Core™ i7 Processor','yes', Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 'Client CoMarketing Fund', System.today(), System.today().addDays(300), 10000, 'Always Connected PC', acc2.Id,'Desktop', true);
        
        Test.startTest();
        
        PartnerFundRequest testPartnerFundRequestRecord = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(camp.id,Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,acc2.Id,pfa,pbm,'ALBANIA','Consumer','Desktop','Intel® Corporate Logo','Broadcast','Radio','Draft',true);
        testPartnerFundRequestRecord.Amount = testPartnerFundRequestRecord.RequestedAmount;
        //testPartnerFundRequestRecord.AllocationId = pfa.Id;
        testPartnerFundRequestRecord.Status = 'Approved';
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
        
    }
    
    @isTest static void validateAdjustmentOwnerUpdate(){ 
        
        Test.startTest();
        
        User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        User usr1 = [SELECT Id,Email from User where Email='test1@example.com' limit 1];
        
        System.runAs(sysAdminUser){
            
            PermissionSet claimSubmitterPermissionSet = [SELECT Id, Name FROM PermissionSet where Name = 'Core_MDF_CCP_External_Claim_Submitter'];        
            
            PermissionSetAssignment  psa = new PermissionSetAssignment(PermissionSetId = claimSubmitterPermissionSet.Id, AssigneeId = usr1.Id);
            insert psa;
            
            PartnerFundClaim claim = [Select Id, OwnerId from PartnerFundClaim where Title = 'Test Claim' limit 1];
            claim.OwnerId = usr1.id;
            database.update(claim);
            
            Core_MDF_Adjustment_Request__c adjReq = Core_MDF_CCP_TestDataUtility.createAdjustmentReq(claim.Id, 'Claim Review Results (Negative)', 100.00, true);
            PartnerFundClaim claim1 = [Select Id, OwnerId from PartnerFundClaim where Title = 'Test Claim' limit 1];
            PartnerFundClaim claim2 = [Select Id, OwnerId from PartnerFundClaim where Title = '[Adjustment] Test Claim' limit 1];   
            
            System.assertEquals(claim1.OwnerId, claim2.OwnerId);
        }
        
        Test.stopTest();
    }
    
    @isTest static void validateAdjustmentOffset(){ 
        
        Test.startTest();
        
        User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        User intUser = [SELECT Id,Email from User where Email='test2@intel.com' limit 1];
        
        Group grp = [SELECT Id, Name, DeveloperName FROM Group where DeveloperName = 'Core_MDF_CCP_Claim_Case_Reviewer_Q_Group'];
        Group grp2 = [SELECT Id, Name, DeveloperName FROM Group where DeveloperName = 'Core_All_Users_CCP_Internal'];
        
        System.runAs(sysAdminUser){
            
            PermissionSet claimCaseReviewerPermissionSet = [SELECT Id, Name FROM PermissionSet where Name = 'Core_MDF_CCP_Internal_Claim_Case_Reviewer_Manager'];        
            PermissionSetAssignment  psa = new PermissionSetAssignment(PermissionSetId = claimCaseReviewerPermissionSet.Id, AssigneeId = intUser.Id);
            insert psa;
            
            
            GroupMember grpMem = new GroupMember();
            grpMem.GroupId = grp.Id;
            grpMem.UserOrGroupId = intUser.Id;
            GroupMember grpMem2 = new GroupMember();
            grpMem2.GroupId = grp2.Id;
            grpMem2.UserOrGroupId = intUser.Id;
            Database.insert(grpMem2);
            
           
                
                PartnerFundClaim claim = [Select Id, OwnerId from PartnerFundClaim where Title = 'Test Claim' limit 1];
                claim.OwnerId = intUser.id;
                database.update(claim);
                
                Core_MDF_Adjustment_Request__c adjReq = Core_MDF_CCP_TestDataUtility.createAdjustmentReq(claim.Id, 'Claim Review Results (Negative)', 5500.00, true);
                PartnerFundClaim claim1 = [Select Id, Amount, Core_MDF_Status__c, OwnerId from PartnerFundClaim where Title = 'Test Claim' limit 1];
                PartnerFundClaim claim2 = [Select Id, Core_MDF_Total_Invoice_Amount_Local__c, Amount, Core_MDF_Status__c, OwnerId from PartnerFundClaim where Title = '[Adjustment] Test Claim' limit 1];   
                System.debug('claim2: '+claim2);

                
                claim2.Amount = -((Math.abs(claim2.Amount)) - claim1.Amount);
                claim1.Amount =0.0;
                claim2.Core_MDF_Status__c = Label.Core_MDF_Status_Pending_Available_Fund;
                claim1.Core_MDF_Status__c = Label.Core_MDF_Status_Paid;
                List<PartnerFundClaim> claims = new List<PartnerFundClaim>();
                claims.add(claim1);
                claims.add(claim2);
                database.update(claims);
                PartnerFundClaim claim3 = [Select Id, Amount, Core_MDF_Status__c, OwnerId from PartnerFundClaim where Title = 'Test Claim' limit 1];
                PartnerFundClaim claim4 = [Select Id, Core_MDF_Type_txt__c, Core_MDF_Total_Invoice_Amount_Local__c, Amount, Core_MDF_Status__c, OwnerId from PartnerFundClaim where Title = '[Adjustment] Test Claim' limit 1];
                System.debug('claim4: '+claim4);
                Core_MDF_Claim_Offset__c offset = New Core_MDF_Claim_Offset__c();
                offset.Core_MDF_Offset_Amount_Amt__c = claim3.Amount;
                offset.Core_MDF_Adjustment_Claim_Nbr__c = claim4.Id;
                offset.Core_MDF_Offset_Claim_Nbr__c = claim3.Id;
                database.insert(offset);
                List<Id> closeClaims = new List<Id>();
                closeClaims.add(claim4.ID);
                boolean partialOffsetClaim = Core_MDF_PFC_Close_Adjustment.closeClaims(closeClaims);
                system.AssertEquals(true,partialOffsetClaim);
            }
            
            Test.stopTest();
        }
        
    }