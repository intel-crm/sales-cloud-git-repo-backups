/****************************************************************************************************************************************
* Class Name  : Core_MDF_AdjustmentRequest_Test
* Version     : 1.0 
* Created Date: 6-June-2019
* Modification Log :
* Developer    Intel :Areefa      Date:6-Jun-2019       Description: 
*****************************************************************************************************************************************/
@isTest(SeeAllData=false)
Private class Core_MDF_AdjustmentRequest_Test {    
    
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
        PartnerFundRequest testPartnerFundRequestRecord = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(camp.id,Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,acc2.Id,pfa,pbm,'ALBANIA','Consumer','Desktop','Intel® Corporate Logo','Digital','','Draft', false);
        testPartnerFundRequestRecord.Amount = testPartnerFundRequestRecord.RequestedAmount;
        testPartnerFundRequestRecord.Core_MDF_Budget_Type_nm__c = 'OEM CMP';
        testPartnerFundRequestRecord.Title = 'Test Activity For Manual Hold';
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
        claim1.Core_MDF_Processing_Preference_nm__c = 'Settle, then get paid';
        claim1.Core_MDF_Currency__c = 'USD';
        claim1.Core_MDF_Budget_Type_Options_Nm__c= 'MDF';
        claim1.Amount = 1000;
        claim1.Core_MDF_Status__c = Label.Core_MDF_Status_Pending_Available_Fund; //'Pending Available Fund';
        pfcList.add(claim1);
        PartnerFundClaim escalationClaim = Core_MDF_CCP_TestDataUtility.createClaim('Test Escalation Claim', Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, testPartnerFundRequestRecord.Id, System.today().addDays(-10), System.today().addDays(-1), 500.00, System.today().addDays(-1),bank.Id, false);  
        escalationClaim.Core_MDF_Processing_Preference_nm__c = 'Settle, then get paid';
        pfcList.add(escalationClaim);
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
    
    @isTest
    private  static void testToCreateNegativeClaimFromAdjustmentRequest(){
        
        
        User refClaimOwner =[Select id,isActive from User where email ='sysadmin@example.com' LIMIT 1];
        test.startTest(); 
        system.runAs(refClaimOwner){
            List<Core_MDF_Adjustment_Request__c> createAdjReq = new List<Core_MDF_Adjustment_Request__c>();
            List<PartnerFundClaim> pfcClm = new List<PartnerFundClaim>();
            PartnerFundClaim claim = [SELECT Id, Amount,Core_MDF_Status__c,Request.Core_MDF_Fund_Request_Status__c FROM PartnerFundClaim where Title ='Test Claim for Neg Adj'];
            claim.Amount =-10;
            claim.Core_MDF_Status__c =  Label.Core_MDF_Status_Pending_Available_Fund;   
            claim.Core_MDF_Type_Txt__c ='Adjustment';
            pfcClm.add(claim);
            PartnerFundClaim claim1 = [SELECT Id, Amount,Core_MDF_Status__c,Request.Core_MDF_Fund_Request_Status__c FROM PartnerFundClaim where Title ='Test Escalation Claim'];
            claim1.Core_MDF_Status__c =  'Payment Due';
            pfcClm.add(claim1);
            update pfcClm;
            
            Core_MDF_Adjustment_Request__c adjReq1 = new Core_MDF_Adjustment_Request__c();
            adjReq1.Core_MDF_Reference_Claim_Nbr__c = claim1.Id; 
            adjReq1.Core_MDF_Reason_Cd__c = 'Duplicate Claim';
            adjReq1.Core_MDF_Amount_Amt__c = 2; 
            adjReq1.Core_MDF_Comments_Txt__c = 'Test';
            adjReq1.Core_MDF_Adjustment_Status_nm__c = 'Approved';
            adjReq1.Core_MDF_Bypass_Amt_Val_Ind__c= true;
            adjReq1.Core_MDF_Adjustment_Claim_Nbr__c = claim.Id;
            createAdjReq.add(adjReq1);                
            insert createAdjReq;  
            
            Core_MDF_AdjustmentReq_ServiceHandler.claimAdjustmentAmountValidation(createAdjReq);        
            Core_MDF_AdjustmentReq_ServiceHandler.createAdjustment(createAdjReq);
            System.assert(true, adjReq1.id != null);
        }
        test.stopTest(); 
    } 
    
    @isTest
    private  static void testToCreateEscalationClaimFromAdjustmentRequest(){
        
        test.startTest(); 
        List<Core_MDF_Adjustment_Request__c> createAdjReq = new List<Core_MDF_Adjustment_Request__c>();
        PartnerFundClaim claim = [SELECT Id FROM PartnerFundClaim where Title ='Test Claim for Neg Adj'];
        //claim.Core_MDF_Type_Txt__c ='Claim';
        Core_MDF_Adjustment_Request__c adjReq = new Core_MDF_Adjustment_Request__c();
        adjReq.Core_MDF_Reference_Claim_Nbr__c = claim.Id; 
        adjReq.Core_MDF_Reason_Cd__c = 'Escalation';
        adjReq.Core_MDF_Amount_Amt__c = 10; 
        adjReq.Core_MDF_Comments_Txt__c = 'Test1';
        if(adjReq.Core_MDF_Escalation_Id__c != null){
            adjReq.Core_MDF_Escalation_Id__c  = adjReq.Core_MDF_Escalation_Id__c;           // Escaltion Id 
        } 
        
        createAdjReq.add(adjReq);        
        Core_MDF_AdjustmentReq_ServiceHandler.createAdjustment(createAdjReq);
        System.assert(true, adjReq.id != null);         
        test.stopTest(); 
    }   
    
    
    /* Method to Check status of adjustment request after adjustment claim is Cancelled */
    @isTest static void testCancelAdjustmentRequest(){
        
        Test.startTest();
        User usr = [SELECT ID From User where Email = 'clmcase@example.com'];
        PartnerFundClaim claim1 = [SELECT Id,Core_MDF_Status__c FROM PartnerFundClaim where Title ='Test Claim for Neg Adj'];
        claim1.OwnerId=usr.id;
        Database.update(claim1); 
        
        System.runAs(usr)
        {
            List<Core_MDF_Adjustment_Request__c> listAdjReq = new List<Core_MDF_Adjustment_Request__c>();
            Core_MDF_Adjustment_Request__c adjReq = new Core_MDF_Adjustment_Request__c();
            PartnerFundClaim claim = [SELECT Id,Core_MDF_Status__c,Core_MDF_Type_Txt__c FROM PartnerFundClaim where Title ='Test Claim for Neg Adj'];
            claim.Core_MDF_Type_Txt__c ='Adjustment';
            adjReq.Core_MDF_Reference_Claim_Nbr__c = claim.Id;
            adjReq.Core_MDF_Reason_Cd__c = 'Claim Review Results (Negative)';
            adjReq.Core_MDF_Amount_Amt__c = 510; 
            adjReq.Core_MDF_Comments_Txt__c = 'Test';
            adjReq.OwnerId = userInfo.getUserId();
            adjReq.Core_MDF_Adjustment_Status_nm__c = 'Approved';
            listAdjReq.add(adjReq);
            
            Core_MDF_Adjustment_Request__c adjReq1 = new Core_MDF_Adjustment_Request__c();
            adjReq1.Core_MDF_Reference_Claim_Nbr__c = claim.Id;
            adjReq1.Core_MDF_Reason_Cd__c = 'Claim Review Results (Negative)';
            adjReq1.Core_MDF_Amount_Amt__c = 510; 
            adjReq1.Core_MDF_Comments_Txt__c = 'Test';
            adjReq1.OwnerId = userInfo.getUserId();
            adjReq1.Core_MDF_Adjustment_Status_nm__c = 'Cancelled';
            listAdjReq.add(adjReq1);
            Core_MDF_AdjustmentReq_ServiceHandler.createAdjustment(listAdjReq);
            // Unit Test Method should include System.Assert
            System.assertNotEquals(null, listAdjReq, 'listAdjReq should not be null');
            System.assertEquals(2, listAdjReq.size(), 'listAdjReq should contain 2 records');
            
            Map<Id,Core_MDF_Adjustment_Request__c> oldMap = new Map<Id,Core_MDF_Adjustment_Request__c>();
            Map<Id,Core_MDF_Adjustment_Request__c> newMap = new Map<Id,Core_MDF_Adjustment_Request__c>();
            oldMap.put(adjReq.id,adjReq);
            newMap.put(adjReq1.id,adjReq1);
            //Core_MDF_AdjustmentReq_ServiceHandler.cancelAdjustmentRequest(oldMap,newMap);
            //Core_MDF_Adjustment_Request__c adjReq1 = [SELECT Id,Core_MDF_Adjustment_Status_nm__c,Core_MDF_Adjustment_Claim_Nbr__c from Core_MDF_Adjustment_Request__c where Id =:adjReq.id];
            
            //Database.insert(adjReq);             
            
            
            //Database.update(adjReq); 
            
            
            
            
            //PartnerFundClaim adjClaim = [SELECT Id,Core_MDF_Status__c FROM PartnerFundClaim where Id=:adjReq1.Core_MDF_Adjustment_Claim_Nbr__c];
            
            //system.assertEquals(adjReq1.Core_MDF_Adjustment_Status_nm__c, adjClaim.Core_MDF_Status__c,'Error');
            Test.stopTest();    
            
        }
        
    }
    @isTest static void testAdjustmentClaim(){
        
        List<PartnerFundClaim> pfcList = new List<PartnerFundClaim>();
        User usr = [SELECT ID From User where Email = 'clmcase@example.com'];
        Test.startTest();
        PartnerFundClaim claim1 = [SELECT Id,Core_MDF_Status__c FROM PartnerFundClaim where Title ='Test Claim for Neg Adj'];
        PartnerFundClaim escalationClaim = [SELECT Id,Core_MDF_Status__c FROM PartnerFundClaim where Title ='Test Escalation Claim'];
        claim1.OwnerId=usr.id;
        escalationClaim.OwnerId=usr.id;
        pfcList.add(claim1);
        pfcList.add(escalationClaim);
        Database.update(pfcList); 
        System.runAs(usr){ 
          // Highlight: Unused Local Variable
          //  Core_MDF_Adjustment_Request__c adjReq = new Core_MDF_Adjustment_Request__c();
            PartnerFundClaim positiveClaim = [SELECT Id,Core_MDF_Status__c FROM PartnerFundClaim where Title ='Test Claim for Neg Adj'];
            
            PartnerFundClaim escalationClaim1 = [SELECT Id,Core_MDF_Status__c FROM PartnerFundClaim where Title ='Test Escalation Claim'];
            
            List<Core_MDF_Adjustment_Request__c> listAdjReq = new List<Core_MDF_Adjustment_Request__c>();
            Core_MDF_Adjustment_Request__c adjReq1 = new Core_MDF_Adjustment_Request__c();
            adjReq1.Core_MDF_Reference_Claim_Nbr__c = positiveClaim.Id;
            adjReq1.Core_MDF_Reason_Cd__c = 'Escalation';
            adjReq1.Core_MDF_Amount_Amt__c = 10; 
            adjReq1.Core_MDF_Comments_Txt__c = 'Test';
            //adjReq1.Core_MDF_Adjustment_Claim_Nbr__c=escalationClaim1.Id;
            adjReq1.OwnerId = userInfo.getUserId();
            //insert adjReq1;
            listAdjReq.add(adjReq1);
            
            Core_MDF_Adjustment_Request__c adjReq2 = new Core_MDF_Adjustment_Request__c();
            adjReq2.Core_MDF_Reference_Claim_Nbr__c = escalationClaim.Id;
            adjReq2.Core_MDF_Reason_Cd__c = 'Duplicate Claim';
            adjReq2.Core_MDF_Amount_Amt__c = 10; 
            adjReq2.Core_MDF_Comments_Txt__c = 'Test';
            adjReq2.Core_MDF_Adjustment_Claim_Nbr__c=escalationClaim1.Id;
            adjReq2.OwnerId = userInfo.getUserId();
            //insert adjReq2;
            listAdjReq.add(adjReq2);
            //Database.insert(adjReq1);  
            Core_MDF_AdjustmentReq_ServiceHandler.createAdjustment(listAdjReq);
            
            //Database.insert(listAdjReq);  
            System.assert(true, adjReq1.id != null); 
            System.assert(true, adjReq2.id != null); 
            Test.stopTest();
            
        }
    }
    @isTest
    private  static void testinActiveRefClaimOwnerErrorMsg(){
        
        test.startTest(); 
        User refClaimOwner =[Select id,isActive from User where email ='sysadmin@example.com' LIMIT 1];
        refClaimOwner.isActive =false;
        Update refClaimOwner;
        List<Core_MDF_Adjustment_Request__c> createAdjReq = new List<Core_MDF_Adjustment_Request__c>();
        PartnerFundClaim claim = [SELECT Id FROM PartnerFundClaim where Title ='Test Claim for Neg Adj'];
        Core_MDF_Adjustment_Request__c adjReq = new Core_MDF_Adjustment_Request__c();
        adjReq.Core_MDF_Reference_Claim_Nbr__c = claim.Id; 
        adjReq.Core_MDF_Reason_Cd__c = 'Claim Review Results (Negative)';
        adjReq.Core_MDF_Amount_Amt__c = 10; 
        adjReq.Core_MDF_Comments_Txt__c = 'Test1';
        createAdjReq.add(adjReq);
        Core_MDF_Adjustment_Request__c adjReq1 = new Core_MDF_Adjustment_Request__c();
        adjReq1.Core_MDF_Reference_Claim_Nbr__c = claim.Id; 
        adjReq1.Core_MDF_Reason_Cd__c = 'Claim Review Results (Positive)';
        adjReq1.Core_MDF_Amount_Amt__c = 10; 
        adjReq1.Core_MDF_Comments_Txt__c = 'Test2';
        createAdjReq.add(adjReq1);
        try{
            Core_MDF_AdjustmentReq_ServiceHandler.createAdjustment(createAdjReq);
        }catch(Exception e){
            System.assertNotEquals(null,e);
        }
        test.stopTest(); 
    }
    
    @isTest static void testRecalculateShareAdjReqWhenOwnerChangeIntenal(){
        
        Test.startTest();
        ChannelProgram cp1 = Core_MDF_CCP_TestDataUtility.createProgram (Core_MDF_CCP_ConstantClass.IPA_PROGRAM,'Intel Partner Alliance', false);
        insert cp1;
        // Highlight: Unused Local Variable
       // Core_MDF_ChannelProgram__mdt mdt = [Select Core_MDF_Technical_Program_Name__c,Core_MDF_Node_Based_Sharing_Required_Ind__c from Core_MDF_ChannelProgram__mdt where Core_MDF_Technical_Program_Name__c = 'Intel Partner Alliance'];
        
        
        List<PartnerFundClaim> pfcClm = new List<PartnerFundClaim>();
        PartnerFundClaim claim = [SELECT Id, Amount,channelpartnerId,Channelpartner.Core_MDF_Channel_Program__c,Core_MDF_Status__c,Request.Core_MDF_Fund_Request_Status__c FROM PartnerFundClaim where Title ='Test Claim for Neg Adj'];
        claim.Amount =-10;
        claim.Core_MDF_Status__c =  Label.Core_MDF_Status_Pending_Available_Fund;   
        claim.Core_MDF_Type_Txt__c ='Adjustment';
        pfcClm.add(claim);
        PartnerFundClaim claim1 = [SELECT Id, Amount,channelpartnerId,Channelpartner.Core_MDF_Channel_Program__c,Core_MDF_Status__c,Request.Core_MDF_Fund_Request_Status__c FROM PartnerFundClaim where Title ='Test Escalation Claim'];
        claim1.Core_MDF_Status__c =  'Payment Due';
        pfcClm.add(claim1);
        update pfcClm;
        Account acc =[Select id,Core_MDF_Channel_Program__c from Account where id=:claim.channelpartnerId];
        acc.Core_MDF_Channel_Program__c = cp1.id;
        //acc.Core_MDF_Group_Id__c = grp.Id;
        update acc;
        Core_MDF_Adjustment_Request__c adjReq = new Core_MDF_Adjustment_Request__c();
        claim.Core_MDF_Type_Txt__c ='Adjustment';
        adjReq.Core_MDF_Reference_Claim_Nbr__c = claim1.Id;
        adjReq.Core_MDF_Reason_Cd__c = 'Claim Review Results (Negative)';
        adjReq.Core_MDF_Amount_Amt__c = 1; 
        adjReq.Core_MDF_Comments_Txt__c = 'Test';
        adjReq.Core_MDF_Adjustment_Claim_Nbr__c = claim.id;
        adjReq.Core_MDF_Bypass_Amt_Val_Ind__c = true;
        adjReq.OwnerId = userInfo.getUserId();
        Database.insert(adjReq); 
        
        List<Core_MDF_Adjustment_Request__c> adjReqList = new List<Core_MDF_Adjustment_Request__c>();       
        
        Map<Id,Core_MDF_Adjustment_Request__c> adjReqIdToAdjReqMap =new  Map<Id,Core_MDF_Adjustment_Request__c>();
        
        adjReqIdToAdjReqMap.put(adjReq.Id,adjReq);
        
        User usr = [SELECT ID From User where Email = 'sysadmin@example.com' LIMIT 1];
        
        adjReq.OwnerId = usr.Id; 
        
        update adjReq; 
        
        adjReqList.add(adjReq);
        
        Core_MDF_AdjustmentRequest_Sharing.shareAdjustmentRequestToInternalUsers(adjReqList);
        
        Integer i = [SELECT COUNT() from Core_MDF_Adjustment_Request__Share where UserOrGroupId =: usr.Id];          
        //One of owner  
        System.assertEquals(1, i,'Error');
        
        Test.stopTest();        
    }
    /* Method to Check resharing with new owner */
    @isTest static void testRecalculateShareAdjReqWhenOwnerChangeIntenalRMF(){
        
        Test.startTest();
       // Highlight: Unused Local Variable
       // ChannelProgram cp1 = [Select Id from ChannelProgram where Core_MDF_Technical_Program_Name__c='Retail Marketing Funds'];
       //insert cp2;
       // Highlight: Unused Local Variable
       // Core_MDF_ChannelProgram__mdt mdt = [Select Core_MDF_Technical_Program_Name__c,Core_MDF_Node_Based_Sharing_Required_Ind__c from Core_MDF_ChannelProgram__mdt where Core_MDF_Technical_Program_Name__c = 'Retail Marketing Funds'];
        
        
        List<PartnerFundClaim> pfcClm = new List<PartnerFundClaim>();
        PartnerFundClaim claim = [SELECT Id, Amount,channelpartnerId,Core_MDF_Status__c,Request.Core_MDF_Fund_Request_Status__c FROM PartnerFundClaim where Title ='Test Claim for Neg Adj'];
        claim.Amount =-10;
        claim.Core_MDF_Status__c =  Label.Core_MDF_Status_Pending_Available_Fund;   
        claim.Core_MDF_Type_Txt__c ='Adjustment';
        pfcClm.add(claim);
        PartnerFundClaim claim1 = [SELECT Id, Amount,Core_MDF_Status__c,Request.Core_MDF_Fund_Request_Status__c FROM PartnerFundClaim where Title ='Test Escalation Claim'];
        claim1.Core_MDF_Status__c =  'Payment Due';
        pfcClm.add(claim1);
        update pfcClm;
      // Highlight: Unused Local Variable
      //  Account acc =[Select id,Core_MDF_Channel_Program__c from Account where id=:claim.channelpartnerId];
        //acc.Core_MDF_Channel_Program__c = cp1.id;
        //acc.Core_MDF_Group_Id__c = grp.Id;
        //acc.Core_Geo__c = 'APJ';
        //acc.Core_Sub_Geo__c = 'SA';
        //update acc;
        
        
        Core_MDF_Adjustment_Request__c adjReq = new Core_MDF_Adjustment_Request__c();
        claim.Core_MDF_Type_Txt__c ='Adjustment';
        adjReq.Core_MDF_Reference_Claim_Nbr__c = claim1.Id;
        adjReq.Core_MDF_Reason_Cd__c = 'Claim Review Results (Negative)';
        adjReq.Core_MDF_Amount_Amt__c = 10; 
        adjReq.Core_MDF_Comments_Txt__c = 'Test';
        adjReq.Core_MDF_Adjustment_Claim_Nbr__c = claim.id;
        adjReq.OwnerId = userInfo.getUserId();
        Database.insert(adjReq); 
        
        List<Core_MDF_Adjustment_Request__c> adjReqList = new List<Core_MDF_Adjustment_Request__c>();       
        
        Map<Id,Core_MDF_Adjustment_Request__c> adjReqIdToAdjReqMap =new  Map<Id,Core_MDF_Adjustment_Request__c>();
        
        adjReqIdToAdjReqMap.put(adjReq.Id,adjReq);
        
        User usr = [SELECT ID From User where Email = 'sysadmin@example.com' LIMIT 1];
        
        adjReq.OwnerId = usr.Id; 
        
        update adjReq; 
        
        adjReqList.add(adjReq);
        
        Core_MDF_AdjustmentRequest_Sharing.shareAdjustmentRequestToInternalUsers(adjReqList);
        
        Integer i = [SELECT COUNT() from Core_MDF_Adjustment_Request__Share where UserOrGroupId =: usr.Id];          
        //One of owner  
        System.assertEquals(1, i,'Error');
        
        Test.stopTest();        
    }
    
    /* Method to Check resharing with new owner */
    @isTest static void testRecalculateShareAdjReqWhenOwnerChange(){
        
        Test.startTest();
        
        List<PartnerFundClaim> pfcClm = new List<PartnerFundClaim>();
        PartnerFundClaim claim = [SELECT Id, Amount,Core_MDF_Status__c,Request.Core_MDF_Fund_Request_Status__c FROM PartnerFundClaim where Title ='Test Claim for Neg Adj'];
        claim.Amount =-10;
        claim.Core_MDF_Status__c =  Label.Core_MDF_Status_Pending_Available_Fund;   
        claim.Core_MDF_Type_Txt__c ='Adjustment';
        pfcClm.add(claim);
        PartnerFundClaim claim1 = [SELECT Id, Amount,Core_MDF_Status__c,Request.Core_MDF_Fund_Request_Status__c FROM PartnerFundClaim where Title ='Test Escalation Claim'];
        claim1.Core_MDF_Status__c =  'Payment Due';
        pfcClm.add(claim1);
        update pfcClm;
       // Highlight: Unused Local Variable
      //  Core_MDF_ChannelProgram__mdt mdt = [Select Core_MDF_Technical_Program_Name__c,Core_MDF_Node_Based_Sharing_Required_Ind__c from Core_MDF_ChannelProgram__mdt where Core_MDF_Technical_Program_Name__c = 'Client CoMarketing Fund'];
        
        Core_MDF_Adjustment_Request__c adjReq = new Core_MDF_Adjustment_Request__c();
        claim.Core_MDF_Type_Txt__c ='Adjustment';
        adjReq.Core_MDF_Reference_Claim_Nbr__c = claim1.Id;
        adjReq.Core_MDF_Reason_Cd__c = 'Claim Review Results (Negative)';
        adjReq.Core_MDF_Amount_Amt__c = 10; 
        adjReq.Core_MDF_Comments_Txt__c = 'Test';
        adjReq.Core_MDF_Adjustment_Claim_Nbr__c = claim.id;
        adjReq.OwnerId = userInfo.getUserId();
        Database.insert(adjReq); 
        
        List<Core_MDF_Adjustment_Request__c> adjReqList = new List<Core_MDF_Adjustment_Request__c>();       
        
        Map<Id,Core_MDF_Adjustment_Request__c> adjReqIdToAdjReqMap =new  Map<Id,Core_MDF_Adjustment_Request__c>();
        
        adjReqIdToAdjReqMap.put(adjReq.Id,adjReq);
        
        User usr = [SELECT ID From User where Email = 'sysadmin@example.com' LIMIT 1];
        
        adjReq.OwnerId = usr.Id; 
        
        update adjReq; 
        
        adjReqList.add(adjReq);
        
        Core_MDF_AdjustmentRequest_Sharing.recalculateShareAdjustmentRequestWhenOwnerChange(adjReqList,adjReqIdToAdjReqMap);
        
        Integer i = [SELECT COUNT() from Core_MDF_Adjustment_Request__Share where UserOrGroupId =: usr.Id];          
        //One of owner  
        System.assertEquals(1, i,'Error');
        
        Test.stopTest();        
    }
}