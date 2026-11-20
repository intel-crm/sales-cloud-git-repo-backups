@isTest(SeeAllData = false)
public class Core_MDF_PFC_ManualAudit_Test {
    
    // test method for data setup
    @TestSetup static void setUpData(){
        
        Profile sysAdminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        
        List<User> userlist = new List<User>();
        
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);        
        usr.LastName = 'System Adm';
        usr.ProfileId = sysAdminProfile.Id;
        usr.isActive = true;
        usr.Email = 'sysadmin@example.com';
        userlist.add(usr);
        //Database.insert(usr);
        
        List<Account> toBeUpdated = new List<Account>();
        
        // Creating channel program with utility class
        ChannelProgram cp1 = Core_MDF_CCP_TestDataUtility.createProgram ('Client','Client CoMarketing Fund', true);
        
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
        }
        
        Core_MDF_CCP_TestDataUtility.insertCurrencyExchangeRates();
         
        List<String> bypassFunctionKeys = new List<String>();
        bypassFunctionKeys.add('Bypass_Duplicate_Budget_Check');
        bypassFunctionKeys.add('Bypass_GeoBased_Budget_Sharing');
        bypassFunctionKeys.add('Bypass_Allocation_Reservation');
        bypassFunctionKeys.add('Bypass_GeoBased_Allocation_Sharing');
        bypassFunctionKeys.add('Bypass_Duplicate_Bank_Check');
        bypassFunctionKeys.add('Bypass_Bank_Internal_Sharing');
        bypassFunctionKeys.add('Bypass_Bank_External_Sharing');
        bypassFunctionKeys.add('Bypass_Bank_ABM_Sharing');
        bypassFunctionKeys.add('Bypass_ABM_Internal_Sharing');
        bypassFunctionKeys.add('Bypass_ABM_External_Sharing');
        bypassFunctionKeys.add('Bypass_ABM_NodeGroup_Sharing');        
        bypassFunctionKeys.add('byPassShareUnshareCampaignRecord');
        bypassFunctionKeys.add('byPassCampaignAndRelatedRecords');
        bypassFunctionKeys.add('Bypass_PaymentRun_Duplicate_Check');
        bypassFunctionKeys.add('Bypass_Claims_Duplicate_Check');
        bypassFunctionKeys.add('Bypass_Claims_Sharing_Internal_Users');
        bypassFunctionKeys.add('Bypass_ClaimAdjReq_Share_On_Owner_Chng');
        bypassFunctionKeys.add('Bypass_ClaimAdjReq_Share_Internal_Usrs');
        bypassFunctionKeys.add('Bypass_ClaimAdjReq_Share_External_Usrs');
        bypassFunctionKeys.add('Bypass_Claim_AdjReq_Amount_Validation');
        bypassFunctionKeys.add('Bypass_Claims_Amt_vs_Budget_Amt_Check');        
        bypassFunctionKeys.add('Bypass_Claims_ABM_Validation');
        bypassFunctionKeys.add('Bypass_Claims_Sharing_Partner_Users');
        bypassFunctionKeys.add('Bypass_Payment_Doc_InvFileVAT_Validate');
        bypassFunctionKeys.add('Bypass_Bank_Program_InActivation_Check');
        bypassFunctionKeys.add('Bypass_Claims_Amt_vs_Camp_Amt_Check');
        bypassFunctionKeys.add('Bypass_Claim_OwnerLang_EmailTemp');
        bypassFunctionKeys.add('Bypass_StampingOfActySubType_Check');
        bypassFunctionKeys.add('Bypass_Claims_Sharing_On_Owner_Change');
        bypassFunctionKeys.add('Bypass_UpdateActivityFields');
        bypassFunctionKeys.add('Bypass_ValidateActivityWithCampaign');
        bypassFunctionKeys.add('Bypass_MDF_Budget_Access');
        bypassFunctionKeys.add('Bypass_MDF_Budget_Access_Validation');
            bypassFunctionKeys.add('Bypass_MDF_Budget_Status_Validation');
        
        Set<String> myset1 = new Set<String>();
        List<String> result1 = new List<String>();
        myset1.addAll(bypassFunctionKeys);
        result1.addAll(myset1);
        
        List<Core_Trigger_Executions__c> bypassfunctinalitylist1 = Core_MDF_CCP_TestDataUtility.byPassFeature(result1,true,true);
        PartnerMarketingBudget pbm = Core_MDF_CCP_TestDataUtility.createBudget('Test Budget 2', Core_MDF_CCP_TestDataUtility.Budget_Record_Type, acc2.Id, cp1.Id, 30000, System.today().addDays(-4), System.today().addDays(364), false);
        pbm.Core_MDF_Budget_Type_Txt__c = 'OEM CMP';
        insert pbm;
        
        PartnerFundAllocation pfaRecord = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('Test PFA', pbm, acc2, 30000, true);
        
        PartnerFundAllocation pfa = [Select id, Amount from PartnerFundAllocation where BudgetId =: pbm.Id and Title='Test PFA' limit 1];
        
        Campaign camp = Core_MDF_CCP_TestDataUtility.createCampaign('Test Camp 12','Gaming','Intel® Core™ i7 Processor','Yes', Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 'Client CoMarketing Fund', System.today().addDays(-3), System.today().addDays(300), 10000, 'Always Connected PC', acc2.Id,'Desktop', true);
        system.runAs(usr){
            Core_MDF_Bank__c bank = Core_MDF_CCP_TestDataUtility.createBank(acc1.Id, 'Core_MDF_Client_CoMarketing_Fund', true,'1231231230');
            Core_MDF_Account_Bank_Mapping__c accountBankMap = Core_MDF_CCP_TestDataUtility.createAccountBankMap(acc2.Id, bank.Id, true);        
        }
        
        
        Core_MDF_Configuration__c execution1 = new Core_MDF_Configuration__c();
        execution1.Name = 'ALLOWED_PRG_FOR_RUS_NOTIF';
        execution1.Core_MDF_Category__c = 'Bank Document Hold Logic';
        execution1.Core_MDF_Value__c = 'Retail Marketing Funds,Intel Partner Alliance';
        insert execution1; 
        
        Test.startTest();
        
        PartnerFundRequest testPartnerFundRequestRecord = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(camp.id,Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,acc2.Id,pfa,pbm,'ALBANIA','Consumer','Desktop','Intel® Corporate Logo','Broadcast (Pre-2025)','Radio','Draft',false);
        testPartnerFundRequestRecord.Amount = testPartnerFundRequestRecord.RequestedAmount;
        testPartnerFundRequestRecord.Core_MDF_Budget_Type_nm__c = 'CCF 1.0';
        testPartnerFundRequestRecord.Core_MDF_Start_Date__c = System.today()-2;
        testPartnerFundRequestRecord.Core_MDF_End_Date__c = System.today()+2;
        testPartnerFundRequestRecord.Core_MDF_Reimbursement_Rate_txt__c='60%';
        Database.insert(testPartnerFundRequestRecord);
        
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
        
        List<PartnerFundClaim> pfcList = new List<PartnerFundClaim>();
        User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        User intUser = [SELECT Id,Email from User where Email='test1@intel.com' limit 1];
        PartnerFundRequest testPartnerFundRequestRecord = [SELECT Id,Title,Core_MDF_Start_Date__c,Core_MDF_End_Date__c from PartnerFundRequest limit 1];
         
        Core_MDF_Bank__c bank = [Select ID from Core_MDF_Bank__c limit 1];
        Test.startTest();
        
        PartnerFundClaim claim1 = Core_MDF_CCP_TestDataUtility.createClaim('Test Claim', Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, testPartnerFundRequestRecord.Id, System.today()-1, System.today()-1, 5000.00, System.today(), bank.Id, false);
        claim1.Core_MDF_Invoice_Date__c = System.today().addDays(-1);
        claim1.Status = Label.Core_MDF_Status_Approved;
        claim1.Core_MDF_Status__c = Label.Core_MDF_Status_Payment_Due;
        pfcList.add(claim1);
        
        PartnerFundClaim claim2 = Core_MDF_CCP_TestDataUtility.createClaim('Test Claim2Test', Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, testPartnerFundRequestRecord.Id, System.today()-1, System.today()-1, -5000.00, System.today(), bank.Id, false);
        claim2.Core_MDF_Invoice_Date__c = System.today().addDays(-1);
        claim2.Status = Label.Core_MDF_Status_Submitted;
        claim2.Core_MDF_Status__c = Label.Core_MDF_Status_Pending_Available_Fund;
        claim2.Core_MDF_Type_Txt__c = Label.Core_MDF_Claim_Type_to_be_excluded;
        pfcList.add(claim2);
        
        Database.insert(pfcList);
        
        
        System.runAs(sysAdminUser){
            PartnerFundClaim claim = [Select Id from PartnerFundClaim where Title = 'Test Claim' limit 1];
            Core_MDF_PFC_ManualAudit.ManualAuditWrapper wpr = Core_MDF_PFC_ManualAudit.isClaimEligibleForManualAudit(claim.Id);
            System.assertEquals(Label.Core_MDF_Manual_Audit_Access_Error, wpr.message); //Label.Core_MDF_Manual_Audit_Access_Error
            
            PartnerFundClaimShare sharewithExt = new PartnerFundClaimShare(ParentId = claim.Id, UserOrGroupId = intUser.Id, AccessLevel = 'Edit');
            Database.insert(sharewithExt);                
        }                        
        System.runAs(intUser){            
            PartnerFundClaim claim = [Select Id,Core_MDF_Type_Txt__c from PartnerFundClaim where Title = 'Test Claim' limit 1]; 
            Core_MDF_PFC_ManualAudit.ManualAuditWrapper wpr = Core_MDF_PFC_ManualAudit.isClaimEligibleForManualAudit(claim.Id);
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
            Core_MDF_PFC_ManualAudit.ManualAuditWrapper wpr = Core_MDF_PFC_ManualAudit.isClaimEligibleForManualAudit(claim.Id);
            System.assertEquals(Label.Core_MDF_Claim_Cannot_be_set_for_Manual_Audit, wpr.message); //Label.Core_MDF_Claim_Cannot_be_set_for_Manual_Audit           
        }         
        Test.stopTest();
    }
    
    @isTest static void validateCancelClaim(){ 
                
        User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        User intUser = [SELECT Id,Email from User where Email='test1@intel.com' limit 1];
        List<PartnerFundClaim> pfcList = new List<PartnerFundClaim>();
         Test.startTest();
        PartnerFundRequest testPartnerFundRequestRecord = [SELECT Id,Title,Core_MDF_Start_Date__c,Core_MDF_End_Date__c from PartnerFundRequest limit 1];
         
        Core_MDF_Bank__c bank = [Select ID from Core_MDF_Bank__c limit 1];
        
        PartnerFundClaim claim1 = Core_MDF_CCP_TestDataUtility.createClaim('Test Claim', Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, testPartnerFundRequestRecord.Id, System.today()-1, System.today()-1, 5000.00, System.today(), bank.Id, false);
        claim1.Core_MDF_Invoice_Date__c = System.today().addDays(-1);
        claim1.Status = Label.Core_MDF_Status_Approved;
        claim1.Core_MDF_Status__c = Label.Core_MDF_Status_Payment_Due;
        pfcList.add(claim1);
        
        PartnerFundClaim claim2 = Core_MDF_CCP_TestDataUtility.createClaim('Test Claim2Test', Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, testPartnerFundRequestRecord.Id, System.today()-1, System.today()-1, -5000.00, System.today(), bank.Id, false);
        claim2.Core_MDF_Invoice_Date__c = System.today().addDays(-1);
        claim2.Status = Label.Core_MDF_Status_Submitted;
        claim2.Core_MDF_Status__c = Label.Core_MDF_Status_Pending_Available_Fund;
        claim2.Core_MDF_Type_Txt__c = Label.Core_MDF_Claim_Type_to_be_excluded;
        pfcList.add(claim2);
        
        Database.insert(pfcList);
       
        System.runAs(sysAdminUser){
            
            PartnerFundClaim claim = [Select Id from PartnerFundClaim where Title = 'Test Claim' limit 1];    
            Core_MDF_PFC_ManualAudit.ManualAuditWrapper wpr = Core_MDF_PFC_ManualAudit.isClaimEligibleForManualAudit(claim.Id);
            System.assertEquals(Label.Core_MDF_Manual_Audit_Access_Error, wpr.message);//Label.Core_MDF_Manual_Audit_Access_Error
            claim.Status = Label.Core_MDF_Status_Approved;
            claim.Core_MDF_Status__c = Label.Core_MDF_Status_Payment_Due;
            claim.OwnerId = intUser.Id;
            update claim;                                      
        }
        
        System.runAs(intUser){            
            PartnerFundClaim claim = [Select Id from PartnerFundClaim where Title = 'Test Claim' limit 1];
            List<Id> claimId = new List<Id>();    
            claimId.add(claim.Id);
            Core_MDF_PFC_ManualAudit.ManualAuditWrapper wpr = Core_MDF_PFC_ManualAudit.isClaimEligibleForManualAudit(claim.Id);
            if(Label.Core_MDF_Success.equals(wpr.message)){
                Core_MDF_PFC_ManualAudit.assignClaimsForManualAudit(claimId);
            }
            PartnerFundClaim claimUpdated = [Select Id,Status,Core_MDF_Status__c, Core_MDF_Manaul_Audit_Staging_Ind__c, Core_MDF_Audit_Type__c, Core_MDF_FlaggedForAudit__c, Core_MDF_Audit_Hold__c from PartnerFundClaim where Title = 'Test Claim' limit 1];
            System.assertEquals('Payment Due', claimUpdated.Core_MDF_Status__c);
            //System.assertEquals(false, claimUpdated.Core_MDF_Manaul_Audit_Staging_Ind__c);

        }
        
        System.runAs(sysAdminUser){
            PartnerFundClaim claimUpdated2 = [Select Id,Core_MDF_Status__c,Core_MDF_Audit_Type__c, Core_MDF_FlaggedForAudit__c, Core_MDF_Audit_Hold__c from PartnerFundClaim where Title = 'Test Claim' limit 1];
            claimUpdated2.Status = Label.Core_MDF_Status_Approved;
            claimUpdated2.Core_MDF_Status__c = 'Hold';
            update claimUpdated2;
        }
        
        System.runAs(intUser){
            PartnerFundClaim claimUpdated3 = [Select Id,Core_MDF_Status__c,Core_MDF_Audit_Type__c, Core_MDF_FlaggedForAudit__c, Core_MDF_Audit_Hold__c from PartnerFundClaim where Title = 'Test Claim' limit 1];
            Core_MDF_PFC_ManualAudit.ManualAuditWrapper wpr = Core_MDF_PFC_ManualAudit.isClaimEligibleForManualAudit(claimUpdated3.Id);
            //System.assertEquals(Label.Core_MDF_ClaimIsAlreadyOnManualHoldMsg, wpr.message); //Label.Core_MDF_Claim_Reviewed_Previously

            claimUpdated3.Core_MDF_Status__c = Label.Core_MDF_Status_Payment_Due;
            claimUpdated3.Core_MDF_PIC_Review_Completed__c = true;
            update claimUpdated3;

            Core_MDF_PFC_ManualAudit.assignClaimsForManualAudit(new List<Id>{claimUpdated3.Id});
        }   
        Test.stopTest();
        
    }
    
    @isTest static void validateNegativeClaim(){ 

        Test.startTest(); 
        List<PartnerFundClaim> pfcList = new List<PartnerFundClaim>(); 
        User intUser = [SELECT Id,Email from User where Email='test1@intel.com' limit 1];   
        PartnerFundRequest testPartnerFundRequestRecord = [SELECT Id,Title,Core_MDF_Start_Date__c,Core_MDF_End_Date__c from PartnerFundRequest limit 1];
         
        Core_MDF_Bank__c bank = [Select ID from Core_MDF_Bank__c limit 1];
        
        PartnerFundClaim claim1 = Core_MDF_CCP_TestDataUtility.createClaim('Test Claim', Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, testPartnerFundRequestRecord.Id, System.today()-1, System.today()-1, 5000.00, System.today(), bank.Id, false);
        claim1.Core_MDF_Invoice_Date__c = System.today().addDays(-1);
        claim1.Status = Label.Core_MDF_Status_Approved;
        claim1.Core_MDF_Status__c = Label.Core_MDF_Status_Payment_Due;
        pfcList.add(claim1);
        
        PartnerFundClaim claim2 = Core_MDF_CCP_TestDataUtility.createClaim('Test Claim2Test', Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, testPartnerFundRequestRecord.Id, System.today()-1, System.today()-1, -5000.00, System.today(), bank.Id, false);
        claim2.Core_MDF_Invoice_Date__c = System.today().addDays(-1);
        claim2.Status = Label.Core_MDF_Status_Submitted;
        claim2.Core_MDF_Status__c = Label.Core_MDF_Status_Pending_Available_Fund;
        claim2.Core_MDF_Type_Txt__c = Label.Core_MDF_Claim_Type_to_be_excluded;
        pfcList.add(claim2);
        
        Database.insert(pfcList);
        
        PartnerFundClaimShare pfcShare = new PartnerFundClaimShare();
        pfcShare.ParentId = claim2.Id;
        pfcShare.UserOrGroupId = intUser.Id;
        pfcShare.AccessLevel = 'Edit';
        Database.insert(pfcShare);
        
        System.runAs(intUser){
            PartnerFundClaim claim = [Select Id from PartnerFundClaim where Title = 'Test Claim2Test' and Core_MDF_Status__c =: Label.Core_MDF_Status_Pending_Available_Fund limit 1];    
            claim.OwnerId = intUser.Id;
            update claim;                                   
            PartnerFundClaim claimUpdated3 = [Select Id,Core_MDF_Status__c,Core_MDF_Audit_Type__c, Core_MDF_FlaggedForAudit__c,Core_MDF_Audit_Hold__c from PartnerFundClaim where Title = 'Test Claim2Test' limit 1];
            Core_MDF_PFC_ManualAudit.ManualAuditWrapper wpr = Core_MDF_PFC_ManualAudit.isClaimEligibleForManualAudit(claimUpdated3.Id);
            System.assertEquals(Label.Core_MDF_Negative_Claim_Error, wpr.message); //Label.Core_MDF_Negative_Claim_Error
        } 
        Test.stopTest();
    }
    @isTest static void validateDocumentHoldClaim(){  
        Test.startTest();  
        List<PartnerFundClaim> pfcList = new List<PartnerFundClaim>();
        User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        User intUser = [SELECT Id,Email from User where Email='test1@intel.com' limit 1]; 
        PartnerFundRequest testPartnerFundRequestRecord = [SELECT Id,Title,Core_MDF_Start_Date__c,Core_MDF_End_Date__c from PartnerFundRequest limit 1];
         
        Core_MDF_Bank__c bank = [Select ID from Core_MDF_Bank__c limit 1];
        
        PartnerFundClaim claim1 = Core_MDF_CCP_TestDataUtility.createClaim('Test Claim', Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, testPartnerFundRequestRecord.Id, System.today()-1, System.today()-1, 5000.00, System.today(), bank.Id, false);
        claim1.Core_MDF_Invoice_Date__c = System.today().addDays(-1);
        claim1.Status = Label.Core_MDF_Status_Approved;
        claim1.Core_MDF_Status__c = Label.Core_MDF_Status_Payment_Due;
        pfcList.add(claim1);
        
        PartnerFundClaim claim2 = Core_MDF_CCP_TestDataUtility.createClaim('Test Claim2Test', Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, testPartnerFundRequestRecord.Id, System.today()-1, System.today()-1, -5000.00, System.today(), bank.Id, false);
        claim2.Core_MDF_Invoice_Date__c = System.today().addDays(-1);
        claim2.Status = Label.Core_MDF_Status_Submitted;
        claim2.Core_MDF_Status__c = Label.Core_MDF_Status_Pending_Available_Fund;
        claim2.Core_MDF_Type_Txt__c = Label.Core_MDF_Claim_Type_to_be_excluded;
        pfcList.add(claim2);
        
        Database.insert(pfcList);
        System.runAs(sysAdminUser){
            PartnerFundClaim claim = [Select Id,Core_MDF_Document_Hold_Ind__c,Core_MDF_Manaul_Audit_Staging_Ind__c from PartnerFundClaim where Title = 'Test Claim' limit 1];    
            claim.Core_MDF_Manaul_Audit_Staging_Ind__c = true;
            claim.Core_MDF_FlaggedForAudit__c = false;
            claim.OwnerId = intUser.Id;
            update claim;
        }
        System.runAs(intUser){  
            PartnerFundClaim claimUpdated3 = [Select Id,Core_MDF_Document_Hold_Ind__c,Core_MDF_Manaul_Audit_Staging_Ind__c from PartnerFundClaim where Title = 'Test Claim' limit 1];
            Core_MDF_PFC_ManualAudit.ManualAuditWrapper wpr = Core_MDF_PFC_ManualAudit.isClaimEligibleForManualAudit(claimUpdated3.Id);
            //System.assertEquals(Label.Core_MDF_ClaimIsAlreadyOnManualHoldMsg, wpr.message); //Label.Core_MDF_ClaimIsAlreadyOnManualHoldMsg
        } 
        Test.stopTest();
    }

    /*@isTest static void validateFlaggeForAudit(){ 
        Test.startTest();  
        List<PartnerFundClaim> pfcList = new List<PartnerFundClaim>();
        User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        User intUser = [SELECT Id,Email from User where Email='test1@intel.com' limit 1]; 
        PartnerFundRequest testPartnerFundRequestRecord = [SELECT Id,Title,Core_MDF_Start_Date__c,Core_MDF_End_Date__c from PartnerFundRequest limit 1];
         
        Core_MDF_Bank__c bank = [Select ID from Core_MDF_Bank__c limit 1];
        
        PartnerFundClaim claim1 = Core_MDF_CCP_TestDataUtility.createClaim('Test Claim', Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, testPartnerFundRequestRecord.Id, System.today()-1, System.today()-1, 5000.00, System.today(), bank.Id, false);
        claim1.Core_MDF_Invoice_Date__c = System.today().addDays(-1);
        claim1.Status = Label.Core_MDF_Status_Approved;
        claim1.Core_MDF_Status__c = Label.Core_MDF_Status_Payment_Due;
        pfcList.add(claim1);
        
        PartnerFundClaim claim2 = Core_MDF_CCP_TestDataUtility.createClaim('Test Claim2Test', Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, testPartnerFundRequestRecord.Id, System.today()-1, System.today()-1, -5000.00, System.today(), bank.Id, false);
        claim2.Core_MDF_Invoice_Date__c = System.today().addDays(-1);
        claim2.Status = Label.Core_MDF_Status_Submitted;
        claim2.Core_MDF_Status__c = Label.Core_MDF_Status_Pending_Available_Fund;
        claim2.Core_MDF_Type_Txt__c = Label.Core_MDF_Claim_Type_to_be_excluded;
        pfcList.add(claim2);
        
        Database.insert(pfcList);
        
        System.runAs(sysAdminUser){
            PartnerFundClaim claim = [Select Id,Core_MDF_Document_Hold_Ind__c,Core_MDF_Manaul_Audit_Staging_Ind__c from PartnerFundClaim where Title = 'Test Claim' limit 1];    
            claim.Core_MDF_FlaggedForAudit__c = true;
            claim.Core_MDF_Audit_Hold__c = false;
            claim.OwnerId = intUser.Id;
            update claim;
        }
        System.runAs(intUser){  
            PartnerFundClaim claimUpdated3 = [Select Id,Core_MDF_FlaggedForAudit__c,Core_MDF_Audit_Hold__c, Core_MDF_Manaul_Audit_Staging_Ind__c from PartnerFundClaim where Title = 'Test Claim' limit 1];
            Core_MDF_PFC_ManualAudit.ManualAuditWrapper wpr = Core_MDF_PFC_ManualAudit.isClaimEligibleForManualAudit(claimUpdated3.Id);
            //System.assertEquals(Label.Core_MDF_Claim_Reviewed_Previously, wpr.message); //Label.Core_MDF_ClaimIsAlreadyOnManualHoldMsg
        } 
        Test.stopTest();
    }

    @isTest static void validateFlaggedForAudit(){ 
        
        List<PartnerFundClaim> pfcList = new List<PartnerFundClaim>();
        User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        User intUser = [SELECT Id,Email from User where Email='test1@intel.com' limit 1];
        PartnerFundRequest testPartnerFundRequestRecord = [SELECT Id,Title,Core_MDF_Start_Date__c,Core_MDF_End_Date__c from PartnerFundRequest limit 1];
         
        Core_MDF_Bank__c bank = [Select ID from Core_MDF_Bank__c limit 1];
        Test.startTest();
        
        PartnerFundClaim claim1 = Core_MDF_CCP_TestDataUtility.createClaim('Test Claim', Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, testPartnerFundRequestRecord.Id, System.today()-1, System.today()-1, 5000.00, System.today(), bank.Id, false);
        claim1.Core_MDF_Invoice_Date__c = System.today().addDays(-1);
        claim1.Status = Label.Core_MDF_Status_Approved;
        claim1.Core_MDF_Status__c = Label.Core_MDF_Status_Payment_Due;
        pfcList.add(claim1);
        
        PartnerFundClaim claim2 = Core_MDF_CCP_TestDataUtility.createClaim('Test Claim2Test', Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, testPartnerFundRequestRecord.Id, System.today()-1, System.today()-1, -5000.00, System.today(), bank.Id, false);
        claim2.Core_MDF_Invoice_Date__c = System.today().addDays(-1);
        claim2.Status = Label.Core_MDF_Status_Submitted;
        claim2.Core_MDF_Status__c = Label.Core_MDF_Status_Pending_Available_Fund;
        claim2.Core_MDF_Type_Txt__c = Label.Core_MDF_Claim_Type_to_be_excluded;
        pfcList.add(claim2);
        
        Database.insert(pfcList);
        
        
        System.runAs(sysAdminUser){
            PartnerFundClaim claim = [Select Id from PartnerFundClaim where Title = 'Test Claim' limit 1];
            Core_MDF_PFC_ManualAudit.ManualAuditWrapper wpr = Core_MDF_PFC_ManualAudit.isClaimEligibleForManualAudit(claim.Id);
            
            PartnerFundClaimShare sharewithExt = new PartnerFundClaimShare(ParentId = claim.Id, UserOrGroupId = intUser.Id, AccessLevel = 'Edit');
            Database.insert(sharewithExt);                
        }                        
        System.runAs(intUser){            
            PartnerFundClaim claim = [Select Id,Core_MDF_Type_Txt__c from PartnerFundClaim where Title = 'Test Claim' limit 1]; 
            Core_MDF_PFC_ManualAudit.ManualAuditWrapper wpr = Core_MDF_PFC_ManualAudit.isClaimEligibleForManualAudit(claim.Id);
        }  
        
        System.runAs(sysAdminUser){
            PartnerFundClaim claim = [Select Id from PartnerFundClaim where Title = 'Test Claim' limit 1];
            claim.Core_MDF_FlaggedForAudit__c = true;
            claim.Core_MDF_Status__c = Label.Core_MDF_Status_Hold;
            claim.Status = Label.Core_MDF_Status_Submitted;
            update claim;              
        }
        
        System.runAs(intUser){            
            PartnerFundClaim claim = [Select Id from PartnerFundClaim where Title = 'Test Claim' limit 1]; 
            Core_MDF_PFC_ManualAudit.ManualAuditWrapper wpr = Core_MDF_PFC_ManualAudit.isClaimEligibleForManualAudit(claim.Id);
        }         
        Test.stopTest();
    }*/

    @isTest static void validateLegacyPostPaymentWithoutDocs(){ 
                
        User sysAdminUser = [SELECT Id,Email FROM User WHERE Email='sysadmin@example.com' LIMIT 1];
        User intUser = [SELECT Id,Email FROM User WHERE Email='test1@intel.com' LIMIT 1];
        List<PartnerFundClaim> pfcList = new List<PartnerFundClaim>();
        
        Test.startTest();
        PartnerFundRequest testPartnerFundRequestRecord = [SELECT Id,Title,Core_MDF_Start_Date__c,Core_MDF_End_Date__c FROM PartnerFundRequest LIMIT 1];
         
        Core_MDF_Bank__c bank = [SELECT Id FROM Core_MDF_Bank__c LIMIT 1];
        
        PartnerFundClaim claim1 = Core_MDF_CCP_TestDataUtility.createClaim('Test Claim', Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, testPartnerFundRequestRecord.Id, System.today()-1, System.today()-1, 5000.00, System.today(), bank.Id, false);
        claim1.Core_MDF_Invoice_Date__c = System.today().addDays(-1);
        claim1.Status = Label.Core_MDF_Status_Approved;
        claim1.Core_MDF_Status__c = Label.Core_MDF_Status_Payment_Due;
        pfcList.add(claim1);
        
        Database.insert(pfcList);

        List<PartnerFundClaim> pfcListToUpdate = new List<PartnerFundClaim>();
        claim1.Core_MDF_Status__c = 'Paid';
        pfcListToUpdate.add(claim1);

        Database.update(pfcListToUpdate);
       
        System.runAs(sysAdminUser){
            
            PartnerFundClaim claim = [SELECT Id FROM PartnerFundClaim WHERE Title = 'Test Claim' LIMIT 1];    
            Core_MDF_PFC_ManualAudit.ManualAuditWrapper wpr = Core_MDF_PFC_ManualAudit.isClaimEligibleForManualAudit(claim.Id);
            //System.assertEquals(Label.Core_MDF_Manual_Audit_Access_Error, wpr.message);//Label.Core_MDF_Manual_Audit_Access_Error
            claim.OwnerId = intUser.Id;
            update claim;                                      
        }
        
        System.runAs(intUser){            
            PartnerFundClaim claim = [SELECT Id FROM PartnerFundClaim WHERE Title = 'Test Claim' LIMIT 1];
            List<Id> claimId = new List<Id>();    
            claimId.add(claim.Id);
            Core_MDF_PFC_ManualAudit.ManualAuditWrapper wpr = Core_MDF_PFC_ManualAudit.isClaimEligibleForManualAudit(claim.Id);
            if(Label.Core_MDF_Success.equals(wpr.message)){
                Core_MDF_PFC_ManualAudit.assignClaimsForManualAudit(claimId);
            }
            PartnerFundClaim claimUpdated = [SELECT Id,Status,Core_MDF_Status__c, Core_MDF_Manaul_Audit_Staging_Ind__c FROM PartnerFundClaim WHERE Title = 'Test Claim' LIMIT 1];
            System.assertEquals('Paid and Pending Documents', claimUpdated.Core_MDF_Status__c);
            System.assertEquals(true, claimUpdated.Core_MDF_Manaul_Audit_Staging_Ind__c);
        }   

        system.runAs(sysAdminUser){
            PartnerFundClaim claimtoupdate = [SELECT Id FROM PartnerFundClaim WHERE Title = 'Test Claim' LIMIT 1];  
            List<String> documentIdWithTitle = new List<String>();
            list<String> tempString = new list<String>();
            list<Core_MDF_Audit_Document__c> auditDocList = new list<Core_MDF_Audit_Document__c>();
            
            String str1 = claimtoupdate.Id+';#'+'Test Doc1';
            String str2 = claimtoupdate.Id+';#'+'Test Doc2';
            
            
            documentIdWithTitle.add(str1);
            documentIdWithTitle.add(str2);
            
            for(String str: documentIdWithTitle){
                tempString = str.split(';#');
                Core_MDF_Audit_Document__c auditDoc = new Core_MDF_Audit_Document__c();
                auditDoc.Core_MDF_Document_Id__c = tempString[0];
                auditDoc.Core_MDF_Document_Title__c = tempString[1];
                auditDoc.Core_MDF_Claim__c = claimtoupdate.Id;
                auditDoc.Core_MDF_Document_Types__c = 'Proof of Cost;Proof of Branding;Proof of Execution';
                auditDoc.Core_MDF_App_Document_Types_nm__c = 'Proof of Cost;Proof of Branding;Proof of Execution';              
                auditDocList.add(auditDoc);
                
                 Core_MDF_Audit_Document__c auditDoc1 = new Core_MDF_Audit_Document__c();
                auditDoc1.Core_MDF_Document_Id__c = tempString[0];
                auditDoc1.Core_MDF_Document_Title__c = tempString[1];
                auditDoc1.Core_MDF_Document_Types__c = 'Proof of Cost;Proof of Branding;Proof of Execution';
                auditDoc1.Core_MDF_App_Document_Types_nm__c = 'Proof of Cost;Proof of Branding;Proof of Execution';
                auditDocList.add(auditDoc1);
            }
            Core_MDF_PartnerFundClaim.ClaimWrap res = new Core_MDF_PartnerFundClaim.ClaimWrap();
            res = Core_MDF_PartnerFundClaim.saveClaim(claimtoupdate, auditDocList,null,null, false, null, null, null, false);
            claimtoupdate.Core_MDF_Status__c = 'Paid and PIC Pending';
            update claimtoupdate;

            claimtoupdate.Core_MDF_PIC_Review_Completed__c = true;
            claimtoupdate.Core_MDF_Status__c = 'Paid';
            update claimtoupdate;
        }

        System.runAs(intUser){            
            PartnerFundClaim claimMA = [SELECT Id FROM PartnerFundClaim WHERE Title = 'Test Claim' LIMIT 1];
            Core_MDF_PFC_ManualAudit.ManualAuditWrapper wpr2 = Core_MDF_PFC_ManualAudit.isClaimEligibleForManualAudit(claimMA.Id);
            System.assertEquals(Label.Core_MDF_Claim_Reviewed_Previously, wpr2.message);
        }   
        Test.stopTest();
    }

    @isTest static void validateLegacyPostPaymentWithDocs(){ 
                
        User sysAdminUser = [SELECT Id,Email FROM User WHERE Email='sysadmin@example.com' LIMIT 1];
        User intUser = [SELECT Id,Email FROM User WHERE Email='test1@intel.com' LIMIT 1];
        List<PartnerFundClaim> pfcList = new List<PartnerFundClaim>();
        
        Test.startTest();
        PartnerFundRequest testPartnerFundRequestRecord = [SELECT Id,Title,Core_MDF_Start_Date__c,Core_MDF_End_Date__c FROM PartnerFundRequest LIMIT 1];
         
        Core_MDF_Bank__c bank = [SELECT ID FROM Core_MDF_Bank__c LIMIT 1];
        
        PartnerFundClaim claim1 = Core_MDF_CCP_TestDataUtility.createClaim('Test Claim', Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, testPartnerFundRequestRecord.Id, System.today()-1, System.today()-1, 5000.00, System.today(), bank.Id, false);
        claim1.Core_MDF_Invoice_Date__c = System.today().addDays(-1);
        claim1.Status = Label.Core_MDF_Status_Approved;
        claim1.Core_MDF_Status__c = Label.Core_MDF_Status_Payment_Due;
        pfcList.add(claim1);
        
        Database.insert(pfcList);

        List<PartnerFundClaim> pfcListToUpdate = new List<PartnerFundClaim>();
        claim1.Core_MDF_Status__c = 'Paid';
        pfcListToUpdate.add(claim1);

        Database.update(pfcListToUpdate);
       
        System.runAs(sysAdminUser){
            
            PartnerFundClaim claim = [SELECT Id FROM PartnerFundClaim WHERE Title = 'Test Claim' LIMIT 1];    
            Core_MDF_PFC_ManualAudit.ManualAuditWrapper wpr = Core_MDF_PFC_ManualAudit.isClaimEligibleForManualAudit(claim.Id);
            claim.OwnerId = intUser.Id;
            claim.Core_MDF_PIC_Review_Completed__c = true;
            update claim;
            
            List<String> documentIdWithTitle = new List<String>();
            list<String> tempString = new list<String>();
            list<Core_MDF_Audit_Document__c> auditDocList = new list<Core_MDF_Audit_Document__c>();
            
            String str1 = claim.Id+';#'+'Test Doc1';
            String str2 = claim.Id+';#'+'Test Doc2';
            
            documentIdWithTitle.add(str1);
            documentIdWithTitle.add(str2);
            
            for(String str: documentIdWithTitle){
                tempString = str.split(';#');
                Core_MDF_Audit_Document__c auditDoc = new Core_MDF_Audit_Document__c();
                auditDoc.Core_MDF_Document_Id__c = tempString[0];
                auditDoc.Core_MDF_Document_Title__c = tempString[1];
                auditDoc.Core_MDF_Claim__c = claim.Id;
                auditDoc.Core_MDF_Document_Types__c = 'Proof of Cost;Proof of Branding;Proof of Execution';
                auditDoc.Core_MDF_App_Document_Types_nm__c = 'Proof of Cost;Proof of Branding;Proof of Execution';              
                auditDocList.add(auditDoc);
                
                 Core_MDF_Audit_Document__c auditDoc1 = new Core_MDF_Audit_Document__c();
                auditDoc1.Core_MDF_Document_Id__c = tempString[0];
                auditDoc1.Core_MDF_Document_Title__c = tempString[1];
                auditDoc1.Core_MDF_Document_Types__c = 'Proof of Cost;Proof of Branding;Proof of Execution';
                auditDoc1.Core_MDF_App_Document_Types_nm__c = 'Proof of Cost;Proof of Branding;Proof of Execution';
                auditDocList.add(auditDoc1);
            }
            Core_MDF_PartnerFundClaim.ClaimWrap res = new Core_MDF_PartnerFundClaim.ClaimWrap();
            res = Core_MDF_PartnerFundClaim.saveClaim(claim, auditDocList,null,null, false, null, null, null, false);
        }
        
        System.runAs(intUser){            
            PartnerFundClaim claim = [SELECT Id FROM PartnerFundClaim WHERE Title = 'Test Claim' LIMIT 1];
            List<Id> claimId = new List<Id>();    
            claimId.add(claim.Id);
            Core_MDF_PFC_ManualAudit.ManualAuditWrapper wpr = Core_MDF_PFC_ManualAudit.isClaimEligibleForManualAudit(claim.Id);
            if(Label.Core_MDF_Success.equals(wpr.message)){
                Core_MDF_PFC_ManualAudit.assignClaimsForManualAudit(claimId);
            }
            PartnerFundClaim claimUpdated = [SELECT Id, Core_MDF_Audit_Hold__c FROM PartnerFundClaim WHERE Title = 'Test Claim' LIMIT 1];
            System.assertEquals(true, claimUpdated.Core_MDF_Audit_Hold__c);

        }   
        Test.stopTest();
    }

    @isTest static void validateLegacyPendingPayment(){ 
                
        User sysAdminUser = [SELECT Id,Email FROM User WHERE Email='sysadmin@example.com' LIMIT 1];
        User intUser = [SELECT Id,Email FROM User WHERE Email='test1@intel.com' LIMIT 1];
        List<PartnerFundClaim> pfcList = new List<PartnerFundClaim>();
        
        Test.startTest();
        PartnerFundRequest testPartnerFundRequestRecord = [SELECT Id,Title,Core_MDF_Start_Date__c,Core_MDF_End_Date__c FROM PartnerFundRequest LIMIT 1];
         
        Core_MDF_Bank__c bank = [SELECT Id FROM Core_MDF_Bank__c LIMIT 1];
        
        PartnerFundClaim claim1 = Core_MDF_CCP_TestDataUtility.createClaim('Test Claim', Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, testPartnerFundRequestRecord.Id, System.today()-1, System.today()-1, 5000.00, System.today(), bank.Id, false);
        claim1.Core_MDF_Invoice_Date__c = System.today().addDays(-1);
        claim1.Status = Label.Core_MDF_Status_Approved;
        claim1.Core_MDF_Status__c = Label.Core_MDF_Status_Payment_Due;
        pfcList.add(claim1);
        Id ccfRecordTypeId = Schema.SObjectType.Core_MDF_Payment__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_Client_Co_Marketing_Fund').getRecordTypeId();
        Core_MDF_Payment_Run__c payRunRecord = new Core_MDF_Payment_Run__c();
            payRunRecord.Core_MDF_ScheduleRun_Dtm__c= DateTime.Now().addMinutes(1);
            payRunRecord.Core_MDF_Geo_Txt__c = 'APJ';
            payRunRecord.Core_MDF_Program_Txt__c  ='Client CoMarketing Fund';
            payRunRecord.Core_MDF_Budget_Type_nm__c  ='CCF 1.0';
            payRunRecord.RecordTypeId = Schema.SObjectType.Core_MDF_Payment_Run__c.getRecordTypeInfosByDeveloperName().get('Client_Co_Marketing_Fund_CMP').getRecordTypeId();
            Database.insert(payRunRecord);
        
        Database.insert(pfcList);
		Core_MDF_Payment__c newPayment = new Core_MDF_Payment__c();
        newPayment.Core_MDF_Payment_Status_Txt__c = 'Pending Payment';
        newPayment.Core_MDF_Payment_Run_Id__c = payRunRecord.Id;
        newPayment.RecordTypeId = ccfRecordTypeId;
        insert newPayment;

        List<PartnerFundClaim> pfcListToUpdate = new List<PartnerFundClaim>();
        claim1.Core_MDF_Status__c = 'Pending Payment';
        //claim1.Core_MDF_Payment_Id__c= 'a4JD30000006LSUMA2';
        claim1.Core_MDF_Payment_Id__c= newPayment.Id;
        pfcListToUpdate.add(claim1);

       // Database.update(pfcListToUpdate);
       
        System.runAs(sysAdminUser){
            
            PartnerFundClaim claim = [SELECT Id FROM PartnerFundClaim WHERE Title = 'Test Claim' LIMIT 1];    
            Core_MDF_PFC_ManualAudit.ManualAuditWrapper wpr = Core_MDF_PFC_ManualAudit.isClaimEligibleForManualAudit(claim.Id);
            claim.OwnerId = intUser.Id;
            update claim;
            
            List<String> documentIdWithTitle = new List<String>();
            list<String> tempString = new list<String>();
            list<Core_MDF_Audit_Document__c> auditDocList = new list<Core_MDF_Audit_Document__c>();
            
            String str1 = claim.Id+';#'+'Test Doc1';
            String str2 = claim.Id+';#'+'Test Doc2';
            
            documentIdWithTitle.add(str1);
            documentIdWithTitle.add(str2);
            
            for(String str: documentIdWithTitle){
                tempString = str.split(';#');
                Core_MDF_Audit_Document__c auditDoc = new Core_MDF_Audit_Document__c();
                auditDoc.Core_MDF_Document_Id__c = tempString[0];
                auditDoc.Core_MDF_Document_Title__c = tempString[1];
                auditDoc.Core_MDF_Claim__c = claim.Id;
                auditDoc.Core_MDF_Document_Types__c = 'Proof of Cost;Proof of Branding;Proof of Execution';
                auditDoc.Core_MDF_App_Document_Types_nm__c = 'Proof of Cost;Proof of Branding;Proof of Execution';              
                auditDocList.add(auditDoc);
                
                 Core_MDF_Audit_Document__c auditDoc1 = new Core_MDF_Audit_Document__c();
                auditDoc1.Core_MDF_Document_Id__c = tempString[0];
                auditDoc1.Core_MDF_Document_Title__c = tempString[1];
                auditDoc1.Core_MDF_Document_Types__c = 'Proof of Cost;Proof of Branding;Proof of Execution';
                auditDoc1.Core_MDF_App_Document_Types_nm__c = 'Proof of Cost;Proof of Branding;Proof of Execution';
                auditDocList.add(auditDoc1);
            }
            Core_MDF_PartnerFundClaim.ClaimWrap res = new Core_MDF_PartnerFundClaim.ClaimWrap();
            res = Core_MDF_PartnerFundClaim.saveClaim(claim, auditDocList,null,null, false, null, null, null, false);
        }
        
        System.runAs(intUser){            
            PartnerFundClaim claim = [SELECT Id FROM PartnerFundClaim WHERE Title = 'Test Claim' LIMIT 1];
            List<Id> claimId = new List<Id>();    
            claimId.add(claim.Id);
            Core_MDF_PFC_ManualAudit.ManualAuditWrapper wpr = Core_MDF_PFC_ManualAudit.isClaimEligibleForManualAudit(claim.Id);
            if(Label.Core_MDF_Success.equals(wpr.message)){
                Core_MDF_PFC_ManualAudit.assignClaimsForManualAudit(claimId);
            }
            PartnerFundClaim claimUpdated = [SELECT Id,Status,Core_MDF_Status__c, Core_MDF_Manaul_Audit_Staging_Ind__c FROM PartnerFundClaim WHERE Title = 'Test Claim' LIMIT 1];
            //claimUpdated.Core_MDF_Manaul_Audit_Staging_Ind__c = false;
            //System.assertEquals(false, claimUpdated.Core_MDF_Manaul_Audit_Staging_Ind__c);

            //If the claim already in Manual Audit
            Core_MDF_PFC_ManualAudit.ManualAuditWrapper wpr1 = Core_MDF_PFC_ManualAudit.isClaimEligibleForManualAudit(claim.Id);
           // System.assertEquals(Label.Core_MDF_ClaimIsAlreadyOnManualHoldMsg, wpr1.message);
        }   

        System.runAs(sysAdminUser){
            PartnerFundClaim claimMA = [SELECT Id FROM PartnerFundClaim WHERE Title = 'Test Claim' LIMIT 1];
            claimMA.Core_MDF_Status__c = 'Paid';
            update claimMA;
        }
        Test.stopTest();
    }
}