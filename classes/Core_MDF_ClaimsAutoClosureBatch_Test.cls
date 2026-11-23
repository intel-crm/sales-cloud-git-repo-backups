@isTest
private class Core_MDF_ClaimsAutoClosureBatch_Test {
    
    @TestSetup static void setUpData(){
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.Email = 'sysadmin@example.com';
        usr.IsActive = true;
        Database.insert(usr);
        
        // Creating channel program with utility class
        ChannelProgram cp1 = Core_MDF_CCP_TestDataUtility.createProgram ('Client','Client CoMarketing Fund', true);
        
        // Creating Account with utility class
        Account acc1 = Core_MDF_CCP_TestDataUtility.createIntelAccount('Test Account 1', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, true);
        
        Account acc2 = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test Account 2', cp1.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, acc1.Id, true);
        
        Core_MDF_CCP_TestDataUtility.insertCurrencyExchangeRates();	
        Core_MDF_CCP_TestDataUtility.createMDFConfigurationData();
        Core_MDF_CCP_TestDataUtility.createTriggerExecutionRecords();
        
        List<String> bypassFunctionKeys = new List<String>();
        bypassFunctionKeys.add('Core_MDF_OpalBudgetValidation');
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
        bypassFunctionKeys.add('Bypass_Claims_Amt_vs_Budget_Amt_Check');        
        bypassFunctionKeys.add('Bypass_Claims_ABM_Validation');
        bypassFunctionKeys.add('Bypass_Claims_Sharing_Partner_Users');
        bypassFunctionKeys.add('Bypass_Payment_Doc_InvFileVAT_Validate');
        bypassFunctionKeys.add('Bypass_Bank_Program_InActivation_Check');
        List<Core_Trigger_Executions__c> bypassfunctinalitylist = Core_MDF_CCP_TestDataUtility.byPassFeature(bypassFunctionKeys,true,true);
        
        // Creating Budget with utility class
    	System.runAs(usr) {
            PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_Finance_Usr'];
        	insert new PermissionSetAssignment(AssigneeId = usr.id, PermissionSetId = ps.Id);
            PermissionSet ps1 = [SELECT Id FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_CCF_User'];
        	insert new PermissionSetAssignment(AssigneeId = usr.id, PermissionSetId = ps1.Id);
            PermissionSet ps2 = [SELECT Id FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_CCF_MDF_Budget_Loader'];
        	insert new PermissionSetAssignment(AssigneeId = usr.id, PermissionSetId = ps2.Id);
        }
        PartnerMarketingBudget pbm = Core_MDF_CCP_TestDataUtility.createBudget('Test Budget 2', Core_MDF_CCP_TestDataUtility.Budget_Record_Type, acc2.Id, cp1.Id, 30000, System.today().addDays(-14), System.today().addDays(14), false);
        pbm.Core_MDF_Budget_Type_Txt__c = 'OEM CMP';
        pbm.IsIgnoreValidation = true;
        pbm.Core_MDF_Budget_Status__c = 'Released';
        System.runAs(usr) {
            Database.insert(pbm);
        }
        
        // Creating Allocation with utility class
        PartnerFundAllocation pfaRecord = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('Test Partner Fund Allocation', pbm, acc2, 30000, true);
        
        // Creating Campaign with utility class
        Campaign camp = Core_MDF_CCP_TestDataUtility.createCampaign('Test Camp 1','Gaming','Intel® Core™ i7 Processor','MDF or both CMP & MDF', Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 'Client CoMarketing Fund', System.today().addDays(-3), System.today().addDays(3), 10000, 'Always Connected PC', acc2.Id,'Desktop', true);
        
        Core_MDF_Bank__c bank = Core_MDF_CCP_TestDataUtility.createBank(acc1.Id, 'Core_MDF_Client_CoMarketing_Fund', false,'1249641240');
        bank.Core_MDF_Bank_Status__c='Active';
        bank.Core_MDF_Bank_Location__c ='IN';
        database.insert(bank);
        
        Core_MDF_Account_Bank_Mapping__c abm1 = Core_MDF_CCP_TestDataUtility.createAccountBankMap(acc2.Id,bank.Id,false);
        Database.insert(abm1);
        
        Test.startTest();
        // Creating Activity with utility class
        PartnerFundRequest testPartnerFundRequestRecord = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(camp.id,Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,acc2.Id,pfaRecord,pbm,'ALBANIA','Consumer','Desktop','Intel® Corporate Logo','Broadcast','Radio','Draft',false);
        testPartnerFundRequestRecord.Amount = testPartnerFundRequestRecord.RequestedAmount;
        testPartnerFundRequestRecord.Core_MDF_Budget_Type_nm__c = 'OEM CMP';
        testPartnerFundRequestRecord.Core_MDF_Start_Date__c = System.today()-2;
        testPartnerFundRequestRecord.Core_MDF_End_Date__c = System.today()+2;
        testPartnerFundRequestRecord.Core_MDF_Fund_Request_Status__c = 'In-Progress';
        testPartnerFundRequestRecord.Core_MDF_Reimbursement_Rate_txt__c = '60%';
        Database.insert(testPartnerFundRequestRecord);
        test.stopTest();
        
        Core_MDF_PICReviewQuestion__c picReviewQuestion = Core_MDF_CCP_TestDataUtility.createPICReviewQuestion('Does POC document show cost?','POC document does not show cost',10);
        
        Core_MDF_PICReviewQuestion__c picReviewQuestion1 = Core_MDF_CCP_TestDataUtility.createPICReviewQuestion('Does POE document show execution?','POE document does not show execution',20);
    }
    
    @isTest
    static void claimsAutoClosureBatchTest(){    
        
        User usr = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        Core_MDF_Bank__c bank = [Select Id from Core_MDF_Bank__c where Core_MDF_Supplier_Number__c='1249641240' limit 1];
        PartnerFundRequest testPartnerFundRequestRecord = [Select Id,Title,Core_MDF_Fund_Request_Status__c from PartnerFundRequest where Title = 'test'];
        
        System.runAs(usr){
            // Creating Claim with utility class
            PartnerFundClaim claim1 = Core_MDF_CCP_TestDataUtility.createClaim('PIC Review Claim', Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, testPartnerFundRequestRecord.Id, System.today()-1, System.today(), 5000.00, System.today(), bank.Id, false);
            claim1.Core_MDF_Invoice_Date__c = System.today().addDays(-1);
            claim1.Core_MDF_Escalation_Id__c = null;
            Test.startTest();
            Database.insert(claim1);
            
            testPartnerFundRequestRecord.Core_MDF_Fund_Request_Status__c = 'Closed';
            
            database.update(testPartnerFundRequestRecord);
            
            claim1.Core_MDF_Status__c = 'Resubmission Required';
            
            database.update(claim1);
            
            Core_MDF_ClaimsAutoClosureBatch batch1 = new Core_MDF_ClaimsAutoClosureBatch();
            database.executebatch(batch1,5);
            System.assertNotEquals(claim1.Id,null);
            test.stopTest();
        }
    }
}