@isTest(SeeAllData = false)
public class Core_MDF_PFC_ManualAudit_Test {
    
    // test method for data setup
    @TestSetup static void setUpData(){
        
        Profile sysAdminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        
        List<User> userlist = new List<User>();
        
        // Creating User with utility class 
        /*User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.Email = 'sysadmin@example.com';
        Database.insert(usr);*/
        
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);        
        usr.LastName = 'System Adm';
        usr.ProfileId = sysAdminProfile.Id;
        usr.isActive = true;
        usr.Email = 'sysadmin@example.com';
        userlist.add(usr);
        //Database.insert(usr);
        
        List<Account> toBeUpdated = new List<Account>();
        
        // Creating channel program with utility class
        ChannelProgram cp1 = Core_MDF_CCP_TestDataUtility.createProgram ('Client Co-Marketing Fund','Client CoMarketing Fund', true);
        
        // Creating Account with utility class
        Account acc1 = Core_MDF_CCP_TestDataUtility.createIntelAccount('Test Account 1', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, true);
        
        Account acc2 = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test Account 2', cp1.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, acc1.Id, true);
        
        Account acc3 = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test Account 3', cp1.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, acc2.Id, true);
        
        
        /* Updating Accounts 
        acc1.isPartner = true;
        acc2.isPartner = true;
        acc3.isPartner = true;
        toBeUpdated.add(acc1);
        toBeUpdated.add(acc2);
        toBeUpdated.add(acc3);
        Database.update(toBeUpdated);*/
        
        //Creating Contact for Partner User
        // Contact conRecord1 = Core_MDF_CCP_TestDataUtility.createContact(acc1.Id,true);
        
        Profile ccpProfile = [SELECT Id FROM Profile WHERE Name='CCP - Core Access'];
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        
        User usr1 = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr1.ProfileId = ccpProfile.Id;
        usr1.Email='test1@intel.com';
        usr1.isActive = true;
        usr1.UserPermissionsMarketingUser=true;
        //  usr1.UserRoleId = usRole.Id;
        userlist.add(usr1);
        
        Database.insert(userlist);
        
        system.runAs(usr){
            PermissionSet claimCaseReviewerPermissionSet = [SELECT Id, Name FROM PermissionSet where Name = 'Core_MDF_CCP_Internal_Claim_Case_Reviewer_Manager'];        
            PermissionSetAssignment  psa = new PermissionSetAssignment(PermissionSetId = claimCaseReviewerPermissionSet.Id, AssigneeId = usr1.Id);
            insert psa;
        }
		
        Core_MDF_CCP_TestDataUtility.insertCurrencyExchangeRates();
        
        /*List<Core_MDF_Currency_Exchange_Rates__c> newValues = new List<Core_MDF_Currency_Exchange_Rates__c>();
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
        database.insert(newValues);*/
                        
        PartnerMarketingBudget pbm = Core_MDF_CCP_TestDataUtility.createBudget('Test Budget 2', Core_MDF_CCP_TestDataUtility.Budget_Record_Type, acc2.Id, cp1.Id, 30000, System.today(), System.today().addDays(364), true);
        
        PartnerFundAllocation pfaRecord = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('Test PFA', pbm, acc2, 30000, true);
        
        //  Profile systemAdminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator' limit 1];
        
        /*pbm.Core_MDF_Budget_Status__c = 'Approved';
		update pbm;

		pbm.Core_MDF_Budget_Status__c = 'Released'; */
        /*pbm.IsIgnoreValidation = true;
        update pbm;*/
        
        PartnerFundAllocation pfa = [Select id, Amount from PartnerFundAllocation where BudgetId =: pbm.Id and Title='Test PFA' limit 1];
        
        Campaign camp = Core_MDF_CCP_TestDataUtility.createCampaign('Test Camp 12','Gaming','Intel® Core™ i7 Processor', Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 'Client CoMarketing Fund', System.today(), System.today().addDays(300), 10000, 'Always Connected PC', acc2.Id,'Desktop', true);
        
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
                        
        List<PartnerFundClaim> pfcList = new List<PartnerFundClaim>();
        
        Test.startTest();
        
        PartnerFundRequest testPartnerFundRequestRecord = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(camp.id,Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,acc2.Id,pfa,pbm,'ALBANIA','Consumer','Desktop','Intel® Corporate Logo','Broadcast','Radio','Draft',false);
        testPartnerFundRequestRecord.Amount = testPartnerFundRequestRecord.RequestedAmount;
        Database.insert(testPartnerFundRequestRecord);
        //testPartnerFundRequestRecord.AllocationId = pfa.Id;
        /*testPartnerFundRequestRecord.Status = 'Approved';
        update testPartnerFundRequestRecord;*/
        
        PartnerFundClaim claim1 = Core_MDF_CCP_TestDataUtility.createClaim('Test Claim', Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, testPartnerFundRequestRecord.Id, System.today(), System.today(), 5000.00, System.today(), bank.Id, false);
        claim1.Status = Label.Core_MDF_Status_Approved;
        claim1.Core_MDF_Status__c = Label.Core_MDF_Status_Payment_Due;
        //update claim1;
        pfcList.add(claim1);
        
        PartnerFundClaim claim2 = Core_MDF_CCP_TestDataUtility.createClaim('Test Claim2Test', Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, testPartnerFundRequestRecord.Id, System.today(), System.today(), -5000.00, System.today(), bank.Id, false);
        claim2.Status = Label.Core_MDF_Status_Submitted;
        claim2.Core_MDF_Status__c = Label.Core_MDF_Status_Pending_Available_Fund;
        claim2.Core_MDF_Type_Txt__c = Label.Core_MDF_Claim_Type_to_be_excluded;
        //insert claim2;
        pfcList.add(claim2);
        
        Database.insert(pfcList);
        
        system.debug('sizeOfPFC'+pfcList.size());
        
        system.debug('Pfclisfft'+pfcList);
		
        PartnerFundClaimShare pfcShare = new PartnerFundClaimShare();
        pfcShare.ParentId = claim2.Id;
        pfcShare.UserOrGroupId = usr1.Id;
        pfcShare.AccessLevel = 'Edit';
        Database.insert(pfcShare); 
        
        PartnerMarketingBudgetShare shareBudgetwithExt = new PartnerMarketingBudgetShare(ParentId = pbm.Id, UserOrGroupId = usr1.Id, AccessLevel = 'Edit');
        Database.insert(shareBudgetwithExt);  
                
        PartnerFundRequestShare shareActwithExt = new PartnerFundRequestShare(ParentId = testPartnerFundRequestRecord.Id, UserOrGroupId = usr1.Id, AccessLevel = 'Edit');
        Database.insert(shareActwithExt);       
		
        Test.stopTest();
                
        List<AccountShare> accSharLst = new List<AccountShare>();
        AccountShare sharewithExt1 = new AccountShare(AccountId = acc1.Id, UserOrGroupId = usr1.Id, AccountAccessLevel = 'Edit', OpportunityAccessLevel = 'Read', CaseAccessLevel = 'Read');
        AccountShare sharewithExt2 = new AccountShare(AccountId = acc2.Id, UserOrGroupId = usr1.Id, AccountAccessLevel = 'Edit', OpportunityAccessLevel = 'Read', CaseAccessLevel = 'Read');
        AccountShare sharewithExt3 = new AccountShare(AccountId = acc3.Id, UserOrGroupId = usr1.Id, AccountAccessLevel = 'Edit', OpportunityAccessLevel = 'Read', CaseAccessLevel = 'Read');
        accSharLst.add(sharewithExt1);
        accSharLst.add(sharewithExt2);
        accSharLst.add(sharewithExt3);
        Database.insert(accSharLst);                                 
    }
    
    @isTest static void validatecheckAccess(){ 
        
        User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        User intUser = [SELECT Id,Email from User where Email='test1@intel.com' limit 1];
        Test.startTest();
        System.runAs(sysAdminUser){
            
            PartnerFundClaim claim = [Select Id from PartnerFundClaim where Title = 'Test Claim' limit 1];
            
            System.assertEquals(Label.Core_MDF_Manual_Audit_Access_Error, Core_MDF_PFC_ManualAudit.isClaimEligibleForManualAudit(claim.Id));

            /*PermissionSet claimCaseReviewerPermissionSet = [SELECT Id, Name FROM PermissionSet where Name = 'Core_MDF_CCP_Internal_Claim_Case_Reviewer_Manager'];        
            PermissionSetAssignment  psa = new PermissionSetAssignment(PermissionSetId = claimCaseReviewerPermissionSet.Id, AssigneeId = intUser.Id);
            insert psa;*/
            
            PartnerFundClaimShare sharewithExt = new PartnerFundClaimShare(ParentId = claim.Id, UserOrGroupId = intUser.Id, AccessLevel = 'Edit');
            Database.insert(sharewithExt);                
        }                        
        System.runAs(intUser){            
            PartnerFundClaim claim = [Select Id,Core_MDF_Type_Txt__c from PartnerFundClaim where Title = 'Test Claim' limit 1];            
            System.assertEquals(Label.Core_MDF_Success, Core_MDF_PFC_ManualAudit.isClaimEligibleForManualAudit(claim.Id));                        
        }  
        
        System.runAs(sysAdminUser){
            PartnerFundClaim claim = [Select Id from PartnerFundClaim where Title = 'Test Claim' limit 1];    
            claim.Core_MDF_Audit_Hold__c = true;
            claim.Core_MDF_Status__c = Label.Core_MDF_Status_Hold;
            claim.Status = Label.Core_MDF_Status_Submitted;
            update claim;              
        }
        
        System.runAs(intUser){            
            PartnerFundClaim claim = [Select Id from PartnerFundClaim where Title = 'Test Claim' limit 1];            
            System.assertEquals(Label.Core_MDF_Claim_Cannot_be_set_for_Manual_Audit, Core_MDF_PFC_ManualAudit.isClaimEligibleForManualAudit(claim.Id));            
        }         
        Test.stopTest();
    }
    
    @isTest static void validateCancelClaim(){ 
                
        User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        User intUser = [SELECT Id,Email from User where Email='test1@intel.com' limit 1];
        //Group grp = [SELECT Id, Name, DeveloperName FROM Group where DeveloperName = 'Core_MDF_CCP_Claim_Case_Reviewer_Q_Group'];
        //Group grp2 = [SELECT Id, Name, DeveloperName FROM Group where DeveloperName = 'Core_All_Users_CCP_Internal'];
        Test.startTest();
        System.runAs(sysAdminUser){
                                    
            /*GroupMember grpMem = new GroupMember();
            grpMem.GroupId = grp.Id;
            grpMem.UserOrGroupId = intUser.Id;
            GroupMember grpMem2 = new GroupMember();
            grpMem2.GroupId = grp2.Id;
            grpMem2.UserOrGroupId = intUser.Id;
            Database.insert(grpMem2);*/
            
            PartnerFundClaim claim = [Select Id from PartnerFundClaim where Title = 'Test Claim' limit 1];    
            
            System.assertEquals(Label.Core_MDF_Manual_Audit_Access_Error, Core_MDF_PFC_ManualAudit.isClaimEligibleForManualAudit(claim.Id));
            claim.Status = Label.Core_MDF_Status_Approved;
            claim.Core_MDF_Status__c = Label.Core_MDF_Status_Payment_Due;
            claim.OwnerId = intUser.Id;
            update claim;                                      
        }
        
        System.runAs(intUser){            
            PartnerFundClaim claim = [Select Id from PartnerFundClaim where Title = 'Test Claim' limit 1];
            List<Id> claimId = new List<Id>();    
            claimId.add(claim.Id);
            string result = Core_MDF_PFC_ManualAudit.isClaimEligibleForManualAudit(claim.Id);   
            if(Label.Core_MDF_Success.equals(result)){
                Core_MDF_PFC_ManualAudit.assignClaimsForManualAudit(claimId);
            }
            PartnerFundClaim claimUpdated = [Select Id,Status,Core_MDF_Status__c,Core_MDF_Audit_Type__c, Core_MDF_FlaggedForAudit__c, Core_MDF_Audit_Hold__c from PartnerFundClaim where Title = 'Test Claim' limit 1];
            
            System.assertEquals(Label.Core_MDF_Status_Hold, claimUpdated.Core_MDF_Status__c);
            System.assertEquals(Label.Core_MDF_Manual_Audit_Type, claimUpdated.Core_MDF_Audit_Type__c);
            System.assertEquals(true, claimUpdated.Core_MDF_FlaggedForAudit__c);
            System.assertEquals(true, claimUpdated.Core_MDF_Audit_Hold__c);
            System.assertEquals(Label.Core_MDF_Status_Submitted, claimUpdated.Status);
        }
        
        System.runAs(sysAdminUser){
            PartnerFundClaim claimUpdated2 = [Select Id,Core_MDF_Status__c,Core_MDF_Audit_Type__c, Core_MDF_FlaggedForAudit__c, Core_MDF_Audit_Hold__c from PartnerFundClaim where Title = 'Test Claim' limit 1];
            claimUpdated2.Status = Label.Core_MDF_Status_Approved;
            claimUpdated2.Core_MDF_Status__c = Label.Core_MDF_Status_Payment_Due;
            update claimUpdated2;
        }
        
        System.runAs(intUser){
            PartnerFundClaim claimUpdated3 = [Select Id,Core_MDF_Status__c,Core_MDF_Audit_Type__c, Core_MDF_FlaggedForAudit__c, Core_MDF_Audit_Hold__c from PartnerFundClaim where Title = 'Test Claim' limit 1];
            System.assertEquals(Label.Core_MDF_Claim_Reviewed_Previously, Core_MDF_PFC_ManualAudit.isClaimEligibleForManualAudit(claimUpdated3.Id));
        }  	
        Test.stopTest();
        
    }
    
    @isTest static void validateNegativeClaim(){ 

       // User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];        
        
        //Group grp = [SELECT Id, Name, DeveloperName FROM Group where DeveloperName = 'Core_MDF_CCP_Claim_Case_Reviewer_Q_Group'];
       // Group grp2 = [SELECT Id, Name, DeveloperName FROM Group where DeveloperName = 'Core_All_Users_CCP_Internal'];

       // System.runAs(sysAdminUser){            
            /*PermissionSet claimCaseReviewerPermissionSet = [SELECT Id, Name FROM PermissionSet where Name = 'Core_MDF_CCP_Internal_Claim_Case_Reviewer_Manager'];        
            PermissionSetAssignment  psa = new PermissionSetAssignment(PermissionSetId = claimCaseReviewerPermissionSet.Id, AssigneeId = intUser.Id);
            insert psa;*/
                        
            /**GroupMember grpMem = new GroupMember();
            grpMem.GroupId = grp.Id;
            grpMem.UserOrGroupId = intUser.Id;
            GroupMember grpMem2 = new GroupMember();
            grpMem2.GroupId = grp2.Id;
            grpMem2.UserOrGroupId = intUser.Id;
            Database.insert(grpMem2);*/
            
       // }   
        Test.startTest();  
        User intUser = [SELECT Id,Email from User where Email='test1@intel.com' limit 1];   
        System.runAs(intUser){
            PartnerFundClaim claim = [Select Id from PartnerFundClaim where Title = 'Test Claim2Test' and Core_MDF_Status__c =: Label.Core_MDF_Status_Pending_Available_Fund limit 1];    
            claim.OwnerId = intUser.Id;
            update claim;                                   
            PartnerFundClaim claimUpdated3 = [Select Id,Core_MDF_Status__c,Core_MDF_Audit_Type__c, Core_MDF_FlaggedForAudit__c,Core_MDF_Audit_Hold__c from PartnerFundClaim where Title = 'Test Claim2Test' limit 1];
            System.assertEquals(Label.Core_MDF_Negative_Claim_Error, Core_MDF_PFC_ManualAudit.isClaimEligibleForManualAudit(claimUpdated3.Id));
        } 
        Test.stopTest();
    }
}