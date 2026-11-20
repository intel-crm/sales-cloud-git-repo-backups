/****************************************************************************************************************************************
* Class Name  : Core_MDF_PFC_Close_Adjustment_Test 
* Version     : 1.0 
* Created Date: 12-July-2019
* Modification Log :
* Developer               Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Intel - Areefa         12-July-2019                    Close Adjustment     
*****************************************************************************************************************************************/

@isTest(SeeAllData = false)
public class Core_MDF_PFC_Close_Adjustment_Test {
    
    @TestSetup static void setUpData(){        
        List<Account> toBeUpdated = new List<Account>();
        
        // Creating channel program with utility class
        ChannelProgram cp1 = Core_MDF_CCP_TestDataUtility.createProgram (Core_MDF_CCP_ConstantClass.CCF_PROGRAM,'Client CoMarketing Fund', true);
        ChannelProgram cp = Core_MDF_CCP_TestDataUtility.createProgram (Core_MDF_CCP_ConstantClass.RMF_PROGRAM,'Retail Marketing Funds', true);
        
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
        Profile ccpCoreProfile = [SELECT Id FROM Profile WHERE Name='CCP - Core Access' LIMIT 1];
        Id sysAdmProfileId = [SELECT Id FROM Profile WHERE Name='System Administrator' limit 1].Id;
        
        PermissionSet clmCaseRevPS = [SELECT Id, Name FROM PermissionSet WHERE Name='Core_MDF_CCP_Internal_Claim_Case_Reviewer' LIMIT 1];
        PermissionSet clmSubmitter = [SELECT Id, Name FROM PermissionSet WHERE Name='Core_MDF_CCP_External_Claim_Submitter' LIMIT 1];
        
        // Creating User with utility class 
        List<User> usrList = new List<User>();
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.Email = 'sysadmin@example.com';
        usr.ProfileId = sysAdmProfileId;
        usrList.add(usr);
        
        User usr1 = Core_MDF_CCP_TestDataUtility.createUser(false);        
        usr1.Email='test1@example.com';
        usr1.ContactId = conRecord1.Id;
        usr1.ProfileId = profileId;
        usr1.isActive = true;
        usrList.add(usr1);
        
        User claimCase = Core_MDF_CCP_TestDataUtility.createUser(false);
        claimCase.Email = 'clmcase@example.com';
        claimCase.Profile = ccpCoreProfile;
        usrList.add(claimCase);
        
        User usr2 = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr2.ProfileId = ccpCoreProfile.Id;
        usr2.Email='test1vd@intel.com';
        usr2.isActive = true;
        usr2.UserPermissionsMarketingUser=true;
        usrList.add(usr2);
        Database.insert(usrList);        
        
        List<PermissionSetAssignment> lstPSAssignment = new List<PermissionSetAssignment>();
        PermissionSetAssignment assignPermissionSetObj = Core_MDF_CCP_TestDataUtility.createPermissionSetAssignment(usr1.Id,clmSubmitter.Id,false);
        lstPSAssignment.add(assignPermissionSetObj);
        PermissionSetAssignment assignPermissionSetObj1 = Core_MDF_CCP_TestDataUtility.createPermissionSetAssignment(claimCase.Id,clmCaseRevPS.Id,false);
        lstPSAssignment.add(assignPermissionSetObj1);
        
        system.runAs(usr){
            Database.insert(lstPSAssignment);
        }
        
        Core_MDF_CCP_TestDataUtility.insertCurrencyExchangeRates();
        List<Core_Trigger_Executions__c> triggerExecutionList = new List<Core_Trigger_Executions__c>();
        
        Core_Trigger_Executions__c groupIdForAccountNode = new Core_Trigger_Executions__c();
        groupIdForAccountNode.name = 'Core_MDF_createGroupForAccountNode';
        groupIdForAccountNode.Core_Object__c = 'Account';
        groupIdForAccountNode.Core_Trigger_Events__c = 'After Insert';
        groupIdForAccountNode.Core_Active__c = TRUE;
        groupIdForAccountNode.Core_Description__c = 'To Create Group for each account';
        groupIdForAccountNode.Core_Class_Name__c = 'Core_AccountHandler';
        // insert 
        triggerExecutionList.add(groupIdForAccountNode);
        
        Core_Trigger_Executions__c shareAccountsWithGroups = new Core_Trigger_Executions__c();
        shareAccountsWithGroups.name = 'Core_MDF_ShareAccountsWithGroups';
        shareAccountsWithGroups.Core_Object__c = 'Account';
        shareAccountsWithGroups.Core_Trigger_Events__c = 'After Insert';
        shareAccountsWithGroups.Core_Active__c = TRUE;
        shareAccountsWithGroups.Core_Description__c = 'To Create Group for each account';
        shareAccountsWithGroups.Core_Class_Name__c = 'Core_AccountHandler';
        triggerExecutionList.add(shareAccountsWithGroups);
        
        //Added by Ealisha to bypass the PFR sharing from triggerhandler
        Core_Trigger_Executions__c te = new Core_Trigger_Executions__c();
        te.name = 'ShareActivityWithInternalUsers_Bypass';
        te.Core_Object__c = 'PartnerFundRequest';
        te.Core_Trigger_Events__c = 'After Update';
        te.Core_Active__c = true;
        te.Core_Description__c = 'To bypass the PFR Internal User Sharing';
        te.Core_Class_Name__c = 'Core_MDF_PartnerRequestTriggerHandler';
        triggerExecutionList.add(te);
        
        Database.insert(triggerExecutionList);
        
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
        //bypassFunctionKeys.add('Bypass_ClaimAdjReq_Share_On_Owner_Chng');
        //bypassFunctionKeys.add('Bypass_ClaimAdjReq_Share_Internal_Usrs');
        //bypassFunctionKeys.add('Bypass_ClaimAdjReq_Share_External_Usrs');
        //bypassFunctionKeys.add('Bypass_Claim_AdjReq_Amount_Validation');
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
        bypassFunctionKeys.add('Core_MDF_XMLToXLSGenerationFlag');
        bypassFunctionKeys.add('Core_MDF_StringToXLSGenerationFlag');
        bypassFunctionKeys.add('Bypass_MDF_Budget_Access_Validation');
        bypassFunctionKeys.add('Bypass_MDF_Budget_Status_Validation');
        bypassFunctionKeys.add('byPass_Cancel_Activity');
        bypassFunctionKeys.add('Core_MDF_Bypass_ATFBatchUpdate');
        bypassFunctionKeys.add('Bypass_PaymentsBulkAPISharing');
        bypassFunctionKeys.add('ByPass_BlockLegacyBudgetCreation');             
        Set<String> myset1 = new Set<String>();
        List<String> result1 = new List<String>();
        myset1.addAll(bypassFunctionKeys);
        result1.addAll(myset1);
        
        List<Core_Trigger_Executions__c> bypassfunctinalitylist1 = Core_MDF_CCP_TestDataUtility.byPassFeature(result1,true,true);
        
        PartnerMarketingBudget pbm = Core_MDF_CCP_TestDataUtility.createBudget('Test Budget 2', Core_MDF_CCP_TestDataUtility.Budget_Record_Type, acc2.Id, cp1.Id, 30000, 
                                                                               System.today(), System.today().addDays(364), false);
        pbm.Core_MDF_Budget_Type_Txt__c = 'OEM CMP';
        
        database.insert(pbm);
        
        PartnerFundAllocation pfa = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('Test PFA', pbm, acc2, 30000, true);
        
        Campaign camp = Core_MDF_CCP_TestDataUtility.createCampaign('Test Camp 12','Gaming','Intel® Core™ i7 Processor', 'Yes', Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 'Client CoMarketing Fund', System.today().addDays(-30), System.today().addDays(300), 10000, 'Always Connected PC', acc2.Id,'Desktop', false);
        
        camp.Core_MDF_Opal_Budget_Type_Txt__c = 'OEM CMP';
        system.runAs(usr){
            Database.insert(camp);
        } 
        Test.startTest();
        PartnerFundRequest testPartnerFundRequestRecord = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(camp.id,Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,acc2.Id,pfa,pbm,'ALBANIA','Consumer','Desktop','Intel® Corporate Logo','Broadcast','Radio','Draft', false);
        testPartnerFundRequestRecord.Amount = testPartnerFundRequestRecord.RequestedAmount;
        testPartnerFundRequestRecord.Core_MDF_Budget_Type_nm__c = 'OEM CMP';
        testPartnerFundRequestRecord.Title = 'indiaActivity';
        testPartnerFundRequestRecord.Status = 'Approved';
        testPartnerFundRequestRecord.Core_MDF_Start_Date__c = system.today().addDays(-20);
        testPartnerFundRequestRecord.Core_MDF_End_Date__c = system.today().addDays(30);
        testPartnerFundRequestRecord.Core_MDF_Reimbursement_Rate_pct__c = '50%';
        testPartnerFundRequestRecord.Core_MDF_Reimbursement_Rate_txt__c = '50%';
        system.runAs(usr){
            Database.insert(testPartnerFundRequestRecord);
        }
        Core_MDF_Bank__c bank = Core_MDF_CCP_TestDataUtility.createBank(acc1.Id, 'Core_MDF_Client_CoMarketing_Fund', true,'1231231230');
        
        Core_MDF_Account_Bank_Mapping__c accountBankMap = Core_MDF_CCP_TestDataUtility.createAccountBankMap(acc2.Id, bank.Id, true);
        Core_MDF_Configuration__c execution1 = new Core_MDF_Configuration__c();
        execution1.Name = 'ALLOWED_PRG_FOR_RUS_NOTIF';
        execution1.Core_MDF_Category__c = 'Bank Document Hold Logic';
        execution1.Core_MDF_Value__c = 'Retail Marketing Funds,Intel Partner Alliance';
        insert execution1;
        List<PartnerFundClaim> pfcList = new List<PartnerFundClaim>();
        PartnerFundClaim claim1 = Core_MDF_CCP_TestDataUtility.createClaim('Test Claim for Neg Adj', Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, 
                                                                           testPartnerFundRequestRecord.Id, System.today().addDays(-10), System.today().addDays(-1), 5000.00, System.today().addDays(-1), bank.Id, false);
        claim1.Status = Label.Core_MDF_Status_Approved;
        claim1.Core_MDF_Status__c = Label.Core_MDF_Status_Pending_Available_Fund; //'Pending Available Fund';
        pfcList.add(claim1);
        PartnerFundClaim indiaClaim = Core_MDF_CCP_TestDataUtility.createClaim('India Claim', Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, testPartnerFundRequestRecord.Id, System.today().addDays(-10), System.today().addDays(-1), 500.00, System.today().addDays(-1),bank.Id, false);  
        pfcList.add(indiaClaim);
        system.runAs(claimCase){
            Database.insert(pfcList);
        }
        
        List<Core_Trigger_Executions__c> executionAdjRequest = new List<Core_Trigger_Executions__c>();
        Core_Trigger_Executions__c adjustmentRequestClaimTriggerExecution = new Core_Trigger_Executions__c();
        adjustmentRequestClaimTriggerExecution.Core_Active__c = true;
        adjustmentRequestClaimTriggerExecution.Core_Class_Name__c = 'Core_MDF_AdjustmentReq_ServiceHandler';
        adjustmentRequestClaimTriggerExecution.Core_Trigger_Events__c = 'before insert';
        adjustmentRequestClaimTriggerExecution.Core_Object__c = 'Core_MDF_Adjustment_Request__c';
        adjustmentRequestClaimTriggerExecution.Name = 'createAdjustment';
        adjustmentRequestClaimTriggerExecution.Core_Description__c = 'Negative claim is getting created from Adustemt Request';
        executionAdjRequest.add(adjustmentRequestClaimTriggerExecution);
        
        Database.insert(executionAdjRequest);
        Test.stopTest();
    }
    
    @isTest static void userHasPermission(){
        test.startTest();
        User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        User intUser = [SELECT Id,Email from User where Email='test1vd@intel.com' limit 1];
        System.runAs(sysAdminUser){              
            Boolean userDoesnotHaveAcess = Core_MDF_PFC_Close_Adjustment.hasAccess();
            System.assertEquals(false, userDoesnotHaveAcess);
            
            PermissionSet financeMgr = [SELECT Id, Name FROM PermissionSet where Name = 'Core_MDF_CCP_Internal_Finance_Manager'];        
            PermissionSetAssignment  fm = new PermissionSetAssignment(PermissionSetId = financeMgr.Id, AssigneeId = intUser.Id);
            insert fm;
        }
        
        System.runAs(intUser){            
            Boolean userHasAcess = Core_MDF_PFC_Close_Adjustment.hasAccess();
           
            //System.assertEquals(true, userHasAcess);
        }
        test.stopTest();
    }
    
    @isTest 
    static void  testPaidClaimEligibleForClose(){
        
        User clmCaseuser = [SELECT Id,Email from User where Email='clmcase@example.com' limit 1];
        
        //PartnerFundRequest indiaActivity = [SELECT Id,Title,Core_MDF_Start_Date__c,Core_MDF_End_Date__c from PartnerFundRequest where Title='indiaActivity' limit 1];        
        //Core_MDF_Bank__c indiaBank = [Select ID from Core_MDF_Bank__c limit 1];
        List<PartnerFundClaim> claimListToBeProcessed = new List<PartnerFundClaim>();
       
        System.runAs(clmCaseuser){           
            Test.startTest();
            
            
            PartnerFundClaim claim1 = [Select Id, OwnerId from PartnerFundClaim  limit 1];
            claim1.Core_MDF_Status__c='Paid';
            update claim1;
            
            Core_MDF_PFC_Close_Adjustment.eligibilityToCloseWrapper paidClaimCannotClose = Core_MDF_PFC_Close_Adjustment.claimEligibleForClose(claim1.Id);      
                     
            system.assertNotEquals(paidClaimCannotClose, NULL); 
            Test.stopTest();
        }         
    }
    
    @isTest 
    static void  testAdjClaimWithCancelledSts(){
        Test.startTest();
        
        User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        User intUser = [SELECT Id,Email from User where Email='test1vd@intel.com' limit 1];
        Group grp = [SELECT Id, Name, DeveloperName FROM Group where DeveloperName = 'Core_MDF_CCP_Claim_Case_Reviewer_Q_Group'];
        Group grp2 = [SELECT Id, Name, DeveloperName FROM Group where DeveloperName = 'Core_All_Users_CCP_Internal'];
        
        PartnerFundRequest indiaActivity = [SELECT Id,Title,Core_MDF_Start_Date__c,Core_MDF_End_Date__c from PartnerFundRequest where Title='indiaActivity' limit 1];
        
        Core_MDF_Bank__c indiaBank = [Select ID from Core_MDF_Bank__c limit 1];
        
        List<PartnerFundClaim> claimListToBeProcessed = new List<PartnerFundClaim>();
        
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
            

            PartnerFundClaim claim1 = [Select Id, OwnerId from PartnerFundClaim where Title = 'India Claim' limit 1];
            claim1.Core_MDF_Status__c='Cancelled';
            update claim1;
            List<PartnerFundClaim> pfcList = new List<PartnerFundClaim>();
            pfcList.add(claim1);
            List<Id> pfcIdList = new List<Id>();
            pfcIdList.add(claim1.Id);
            Core_MDF_PFC_Close_Adjustment.updateClaimCloseStatus(pfcList);
            Core_MDF_PFC_Close_Adjustment.closeClaims(pfcIdList);
            PartnerFundClaimShare sharewithIntUser = new PartnerFundClaimShare(ParentId = claim1.Id, UserOrGroupId = intUser.Id, AccessLevel = 'Edit');
            Database.insert(sharewithIntUser);    
        }
        System.runAs(intUser){            
            Core_MDF_PFC_Close_Adjustment.eligibilityToCloseWrapper eligibilityToClose = new Core_MDF_PFC_Close_Adjustment.eligibilityToCloseWrapper(); 
            
            PartnerFundClaim claim2 = [Select Id, OwnerId from PartnerFundClaim limit 1]; 
            
            List<id> claimList = new List<id>();
            claimList.add(claim2.Id);
            
            Core_MDF_PFC_Close_Adjustment.eligibilityToCloseWrapper claimWithCancelledSts = Core_MDF_PFC_Close_Adjustment.claimEligibleForClose(claim2.Id);
            System.AssertEquals(false,eligibilityToClose.claimCannotBeClose);
            System.AssertEquals(false,eligibilityToClose.isPAF);
        }        
        Test.stopTest();
    }
}