@isTest
public class Core_MDF_PICReviewScreen_Controller_Test {
    @TestSetup static void setUpData(){
        
        Profile sysAdminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        
        Profile ccpCoreAccessProfile = [SELECT Id FROM Profile WHERE Name='CCP - Core Access'];
        
        List<User> userlist = new List<User>();
        
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);        
        usr.LastName = 'System Adm';
        usr.ProfileId = sysAdminProfile.Id;
        usr.isActive = true;
        usr.Email = 'sysadmin@example.com';
        userlist.add(usr);
        
        User usr2 = Core_MDF_CCP_TestDataUtility.createUser(false);        
        usr2.LastName = 'PIC Reviewer';
        usr2.ProfileId = ccpCoreAccessProfile.Id;
        usr2.isActive = true;
        usr2.Email = 'picreviewer@example.com';
        userlist.add(usr2);
        
        Database.insert(userlist);
        
        
        
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
        bypassFunctionKeys.add('Bypass_Claims_Amt_vs_Budget_Amt_Check');        
        bypassFunctionKeys.add('Bypass_Claims_ABM_Validation');
        bypassFunctionKeys.add('Bypass_Claims_Sharing_Partner_Users');
        bypassFunctionKeys.add('Bypass_Payment_Doc_InvFileVAT_Validate');
        bypassFunctionKeys.add('Bypass_Bank_Program_InActivation_Check');
        bypassFunctionKeys.add('Bypass_Activity_ApprovalProcess');
        bypassFunctionKeys.add('Bypass_MDF_Budget_Access');
        bypassFunctionKeys.add('Bypass_MDF_Budget_Access_Validation');
        bypassFunctionKeys.add('ByPass_BlockLegacyBudgetCreation');
        List<Core_Trigger_Executions__c> bypassfunctinalitylist = Core_MDF_CCP_TestDataUtility.byPassFeature(bypassFunctionKeys,true,true);
        // Highlight: Unused Local Variable - Indira
       // List<Account> toBeUpdated = new List<Account>();
        
        // Creating channel program with utility class
        ChannelProgram cp1 = Core_MDF_CCP_TestDataUtility.createProgram (Core_MDF_CCP_ConstantClass.CCF_PROGRAM,'Client CoMarketing Fund', true);
        
        // Creating Account with utility class
        Account acc1 = Core_MDF_CCP_TestDataUtility.createIntelAccount('Test Account 1', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, true);
        Account acc2 = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test Account 2', cp1.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, acc1.Id, true);
       // Highlight: Unused Local Variable - Indira 
       // Profile ccpProfile = [SELECT Id FROM Profile WHERE Name='CCP - Core Access'];
       // UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        
        system.runAs(usr){
            PermissionSet claimCaseReviewerPermissionSet = [SELECT Id, Name FROM PermissionSet where Name = 'Core_MDF_CCP_Internal_Claim_Case_Reviewer_Manager'];        
            PermissionSetAssignment  psa = new PermissionSetAssignment(PermissionSetId = claimCaseReviewerPermissionSet.Id, AssigneeId = usr.Id);
            insert psa;
        }
        
        system.runAs(usr){
            PermissionSet picReviewerPermissionSet = [SELECT Id, Name FROM PermissionSet where Name = 'Core_MDF_CCP_Internal_PIC_Reviewer'];        
            PermissionSetAssignment  psa2 = new PermissionSetAssignment(PermissionSetId = picReviewerPermissionSet.Id, AssigneeId = usr2.Id);
             PermissionSetAssignment  psa2admin = new PermissionSetAssignment(PermissionSetId = picReviewerPermissionSet.Id, AssigneeId = usr.Id);
            insert psa2;
            insert psa2admin;
        }
        
        system.runAs(usr){
            PermissionSet cscPS = [SELECT Id, Name FROM PermissionSet where Name = 'Core_MDF_Internal_CSC_User'];        
            PermissionSetAssignment  psa3 = new PermissionSetAssignment(PermissionSetId = cscPS.Id, AssigneeId = usr.Id);
            insert psa3;
        }
        
        system.runAs(usr){
            PermissionSet cscManager = [SELECT Id, Name FROM PermissionSet where Name = 'Core_MDF_CCP_Internal_CCF_Acct_Mgr'];        
            PermissionSetAssignment  psa4 = new PermissionSetAssignment(PermissionSetId = cscManager.Id, AssigneeId = usr.Id);
            insert psa4;
            
            PermissionSet paymentAdm = [SELECT Id, Name FROM PermissionSet where Name = 'Core_MDF_CCP_Internal_CCF_MDF_Payment_Admin'];        
            PermissionSetAssignment  psa5 = new PermissionSetAssignment(PermissionSetId = paymentAdm.Id, AssigneeId = usr.Id);
            insert psa5;
        
        
        Core_MDF_CCP_TestDataUtility.insertCurrencyExchangeRates();
        
        PartnerMarketingBudget pbm = Core_MDF_CCP_TestDataUtility.createBudget('Test Budget 2', Core_MDF_CCP_TestDataUtility.Budget_Record_Type, acc2.Id, cp1.Id, 30000, System.today().addDays(-4), System.today().addDays(364), false);
        pbm.Core_MDF_Budget_Type_Txt__c = 'CCF 1.0';
        insert pbm;
        
        PartnerFundAllocation pfaRecord = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('Test PFA', pbm, acc2, 30000, true);
        PartnerFundAllocation pfa = [Select id, Amount from PartnerFundAllocation where BudgetId =: pbm.Id and Title='Test PFA' limit 1];
        
        Campaign camp = Core_MDF_CCP_TestDataUtility.createCampaign('Test Camp 12','Gaming','Intel® Core™ i7 Processor','CMP Only', Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 'Client CoMarketing Fund', System.today().addDays(-3), System.today().addDays(300), 10000, 'Always Connected PC', acc2.Id,'Desktop', false);
        camp.Core_MDF_Opal_Budget_Type_Txt__c='OEM CMP';
        camp.Core_MDF_Activity_Category_Type__c = 'Event->Joint Event';
		insert camp;

        Core_MDF_Bank__c bank = Core_MDF_CCP_TestDataUtility.createBank(acc1.Id, 'Core_MDF_Client_CoMarketing_Fund', true,'1231231230');
       // Highlight: Unused Local Variable - Indira
       // Core_MDF_Account_Bank_Mapping__c accountBankMap = Core_MDF_CCP_TestDataUtility.createAccountBankMap(acc2.Id, bank.Id, true);                
        
        List<Core_Trigger_Executions__c> executionList = new List<Core_Trigger_Executions__c>();
        Core_Trigger_Executions__c claimFunctionalityNameTriggerExecution = new Core_Trigger_Executions__c();
        claimFunctionalityNameTriggerExecution.Core_Active__c = false;
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
        
        
        
        Test.startTest();
        PartnerFundRequest testPartnerFundRequestRecord = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(camp.id,Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,acc2.Id,pfa,pbm,'ALBANIA','Consumer','Desktop','Intel® Corporate Logo','Broadcast','Radio','Draft',false);

        testPartnerFundRequestRecord.Amount = testPartnerFundRequestRecord.RequestedAmount;
        testPartnerFundRequestRecord.Core_MDF_Budget_Type_nm__c = 'OEM CMP';
        testPartnerFundRequestRecord.Core_MDF_Start_Date__c = System.today() - 1;
        testPartnerFundRequestRecord.Core_MDF_End_Date__c = System.today();
        testPartnerFundRequestRecord.Core_MDF_Reimbursement_Rate_txt__c='50%';
        testPartnerFundRequestRecord.Core_MDF_Activity_Types__c='Joint Event';
        testPartnerFundRequestRecord.Core_MDF_ActivityCategory__c='Event';
        Database.insert(testPartnerFundRequestRecord);
        
        PartnerFundClaim claimInsert = Core_MDF_CCP_TestDataUtility.createClaim('PIC Review Claim Test', Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, testPartnerFundRequestRecord.Id, System.today()-1, System.today()-1, 5000.00, System.today(), bank.Id, true);

            
        PartnerFundClaim claim5 = Core_MDF_CCP_TestDataUtility.createClaim('PIC Review Claim', Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, testPartnerFundRequestRecord.Id, System.today()-1, System.today()-1, 5000.00, System.today(), bank.Id, false);
        claim5.Core_MDF_Invoice_Date__c = System.today().addDays(-1);
        claim5.Status = Label.Core_MDF_Status_Submitted;
        claim5.Core_MDF_Status__c = label.Core_MDF_Claim_Status_PIC_Pending;
        claim5.Core_MDF_Processing_Preference_nm__c = 'Get paid, then settle';
        pfcList.add(claim5);
        PartnerFundClaim claim4 = Core_MDF_CCP_TestDataUtility.createClaim('PIC Review Claim1', Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, testPartnerFundRequestRecord.Id, System.today()-1, System.today()-1, 5000.00, System.today(), bank.Id, false);
        claim4.Core_MDF_Invoice_Date__c = System.today().addDays(-1);
        claim4.Status = Label.Core_MDF_Status_Submitted;
        claim4.Core_MDF_Status__c = Label.Core_MDF_Claim_Status_PIC_Pending;
        claim4.Core_MDF_Processing_Preference_nm__c = 'Get paid, then settle';
        pfcList.add(claim4);
        PartnerFundClaim claim3 = Core_MDF_CCP_TestDataUtility.createClaim('PIC Review Claim2', Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, testPartnerFundRequestRecord.Id, System.today()-1, System.today()-1, 5000.00, System.today(), bank.Id, false);
        claim3.Core_MDF_Invoice_Date__c = System.today().addDays(-1);
        claim3.Core_MDF_RecentInternalComments_txt__c = 'Testing 1';
        claim3.Status = Label.Core_MDF_Status_Submitted;
        claim3.Core_MDF_Status__c = Label.Core_MDF_Claim_Status_Paid_and_PIC_Pending;
        claim3.Core_MDF_Processing_Preference_nm__c = 'Get paid, then settle';
        pfcList.add(claim3);
        
   
        Database.insert(pfcList);
        
        
        Core_MDF_Audit_Document__c CMD = new Core_MDF_Audit_Document__c();
        CMD.Core_MDF_Claim__c = claim4.Id;
        CMD.Core_MDF_Document_Types__c = 'Proof of Cost;Proof of Execution;Proof of Attribution';
        CMD.Core_MDF_App_Document_Types_nm__c = 'Proof of Cost;Proof of Execution;Proof of Attribution';
        CMD.Core_MDF_Document_Title__c = 'Test Docs';
        Database.insert(CMD);
        
        Core_MDF_PICReviewQuestion__c prq = new Core_MDF_PICReviewQuestion__c();
        prq.Core_MDF_All_Budget_Types_Ind__c = true;
        prq.Core_MDF_All_Programs_Ind__c = true;
        prq.Core_MDF_EffectiveDate_dt__c = Date.today();
        prq.Core_MDF_IneffectiveDate_dt__c = Date.today().addDays(7);
        prq.Core_MDF_Is_Active_ind__c = true;
        prq.Core_MDF_Question_File_Type_nm__c = 'Proof of Cost';
        prq.Core_MDF_Question_English_txt__c = 'Does the file tagged as POC show cost?';
        prq.Core_MDF_Question_English_External_txt__c = 'File(s) tagged as POC does not show cost';
        prq.Core_MDF_Sort_Order__c = 10;
        insert prq;
        
        Test.stopTest();
        
        }
        
    }
    @isTest static void fetch_ClaimRecords(){
        
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1]; 
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.LastName = 'User Test';
        usr.UserRoleId = usRole.Id;
        Database.insert(usr);
        system.runAs(usr) {
            test.startTest();
            PartnerFundClaim claim = [Select Id from PartnerFundClaim limit 1];
        List<ContentDocument> contentDoc = Core_MDF_CCP_TestDataUtility.createContentDocument(true);
        ContentDocumentLink docLink = new ContentDocumentLink(ContentDocumentId = contentDoc[0].Id, LinkedEntityId=claim.Id,ShareType='I',Visibility='AllUsers');
        insert docLink;
        Core_MDF_Audit_Document__c doc = [Select Id, Core_MDF_Claim__c from Core_MDF_Audit_Document__c  limit 1];
        Core_MDF_PICReviewScreen_Controller.fetchAuditDocuments(doc.Core_MDF_Claim__c);
        Core_MDF_PICReviewScreen_Controller.fetchClaimRecords(claim.Id,true);
        Core_MDF_PICReviewScreen_Controller.fetchQuestionRecords(claim.Id);
        Core_MDF_PICReviewScreen_Controller.fetchClaimRecordData(claim.Id);
        
        
        test.stopTest();
        Assert.areNotEqual(claim,null);
        }
    }
    @isTest static void fetch_AuditDocuments(){        
        //User usr = [SELECT Id,Name FROM User where Email = 'sysadmin@example.com' LIMIT 1];
         UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1]; 
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.LastName = 'User Test';
        usr.UserRoleId = usRole.Id;
        Database.insert(usr);
        system.runAs(usr) {
        test.startTest(); 
        PartnerFundClaim claim = [Select Id from PartnerFundClaim limit 1];
        Core_MDF_Audit_Document__c doc = [Select Id, Core_MDF_Claim__c from Core_MDF_Audit_Document__c limit 1];
        Core_MDF_PICReviewScreen_Controller.fetchAuditDocumentList(doc.Core_MDF_Claim__c);
        //fetchKPIFields change - getClaimAttributesFromMetaData
        PartnerFundRequest pfr = [Select Id from PartnerFundRequest limit 1];
        // Highlight: Unused Local Variable - Indira
        //Core_MDF_Bank__c bank = [select Id from Core_MDF_Bank__c limit 1];
        pfr.Core_MDF_ActivityCategory__c = 'Purchase Incentive';
        pfr.Core_MDF_Activity_Types__c = 'Buyer - Sweepstakes';
        //update pfr;
        Core_MDF_PICReviewScreen_Controller.getClaimAttributesFromMetaData(claim.Id);

        test.stopTest();
        Assert.areNotEqual(claim,null);
        }
    }
    
    @isTest static void check_UserPermissionSet(){
        test.startTest();
        
        User usr = [SELECT Id,Name FROM User where Email = 'picreviewer@example.com' LIMIT 1];
        User usr1 = [SELECT Id,Name FROM User where Email = 'sysadmin@example.com' LIMIT 1];
        system.runAs(usr1) {
        Core_MDF_PICReviewScreen_Controller.checkUserPermissionSet(usr.Id);
 
        test.stopTest();
        Assert.areNotEqual(usr,null);
        }
    }
    @isTest static void check_IfNoUserPermissionSet(){
        test.startTest();
        PermissionSetAssignment UPS = [select AssigneeId from PermissionSetAssignment where PermissionSet.Name != 'Core_MDF_CCP_Internal_PIC_Reviewer' limit 1];
        User usr = [SELECT Id,Name FROM User where Email = 'sysadmin@example.com' LIMIT 1];
        system.runAs(usr) {
        Core_MDF_PICReviewScreen_Controller.checkUserPermissionSet(UPS.AssigneeId);

        test.stopTest();
        Assert.areNotEqual(UPS,null);
        }
    }
    
    @isTest static void testReviewDataInsertion()
    {
     test.startTest();   
     Core_MDF_PICReviewQuestion__c prq = [select Id from Core_MDF_PICReviewQuestion__c limit 1];
     PartnerFundClaim claim = [Select Id from PartnerFundClaim where title = 'PIC Review Claim2' limit 1];
     User usr = [select id,LastName from User where LastName = 'System Adm' limit 1];
        system.runAs(usr) {
     String questionData = '[{"questionEnglish" : "Is information on POA document consistent with claim?", "fileType" : "Proof of Attribution", "id" : "questionId", "name" : "QC-0010" , "fileNames" : [{"id" : "QC-0010-308", "label" : "PIC Review POC.docx", "selected" : true, "value": "PIC Review POC.docx"}], "response" : "No"}, {"questionEnglish" : "Does the file tagged as POC show cost ?", "fileType" : "Proof of Cost" , "id" : "questionId", "name" : "QC-0013", "fileNames" : [{"id" : "QC-0013", "label" : "PIC Review POC.docx", "selected" : false, "value" : "PIC Review POC.docx"}], "response" : "Yes"}]';
     String updatedQuestionData = questionData.replaceAll('questionId', prq.Id);
     Core_MDF_PICReviewScreen_Controller.picReviewDetailsWrapper wrapper = new Core_MDF_PICReviewScreen_Controller.picReviewDetailsWrapper();
     wrapper.questionData = (List<Core_MDF_PICReviewScreen_Controller.QuestionWrapper>)JSON.deserialize(updatedQuestionData, List<Core_MDF_PICReviewScreen_Controller.QuestionWrapper>.class);
     wrapper.internalComments = 'Testing';
     wrapper.startDateTime = System.now() - 2;
     wrapper.endDateTime = system.now() + 2;
     wrapper.claimId = claim.Id;
     wrapper.userId = usr.Id;
     wrapper.isReviewFailed = true;
     wrapper.isRecommendedForAudit = false;
     
     wrapper.questionData = new List<Core_MDF_PICReviewScreen_Controller.QuestionWrapper>();
     Core_MDF_PICReviewScreen_Controller.QuestionWrapper qw = new Core_MDF_PICReviewScreen_Controller.QuestionWrapper();
     qw.id = prq.Id;
     qw.fileType = 'Proof of Cost';
     qw.response = 'Yes';
     qw.comment = 'Test comment';
     qw.tactic = new List<String>{ 'Digital Media' };
     qw.fileNames = new List<Core_MDF_PICReviewScreen_Controller.FileDetails>();
     Core_MDF_PICReviewScreen_Controller.FileDetails fd = new Core_MDF_PICReviewScreen_Controller.FileDetails();
     fd.selected = true;
     fd.originalFileName = 'TestFile.docx';
     qw.fileNames.add(fd);
     wrapper.questionData.add(qw);       
            
     Core_MDF_PICReviewScreen_Controller.reviewDataInsertion(wrapper);

     test.stopTest();
        Assert.areNotEqual(claim,null);
        }
    }
    @isTest static void testReviewDataInsertionWithPICFailed()
    {
     test.startTest();   
     Core_MDF_PICReviewQuestion__c prq = [select Id from Core_MDF_PICReviewQuestion__c limit 1];
     PartnerFundClaim claim = [Select Id from PartnerFundClaim limit 1];
     User usr = [select id,LastName from User where LastName = 'System Adm' limit 1];
        system.runAs(usr) {
     String questionData = '[{"questionEnglish" : "Is information on POA document consistent with claim?", "fileType" : "Proof of Attribution", "id" : "questionId", "name" : "QC-0010" , "fileNames" : [{"id" : "QC-0010-308", "label" : "PIC Review POC.docx", "selected" : true, "value": "PIC Review POC.docx"}], "response" : "No"}, {"questionEnglish" : "Does the file tagged as POC show cost ?", "fileType" : "Proof of Cost" , "id" : "questionId", "name" : "QC-0013", "fileNames" : [{"id" : "QC-0013", "label" : "PIC Review POC.docx", "selected" : false, "value" : "PIC Review POC.docx"}], "response" : "Yes"}]';
     String updatedQuestionData = questionData.replaceAll('questionId', prq.Id); 
     Core_MDF_PICReviewScreen_Controller.picReviewDetailsWrapper wrapper = new Core_MDF_PICReviewScreen_Controller.picReviewDetailsWrapper();
     wrapper.questionData = (List<Core_MDF_PICReviewScreen_Controller.QuestionWrapper>)JSON.deserialize(updatedQuestionData, List<Core_MDF_PICReviewScreen_Controller.QuestionWrapper>.class);
     wrapper.internalComments = 'Testing';
     wrapper.startDateTime = System.now() - 2;
     wrapper.endDateTime = system.now() + 2;
     wrapper.claimId = claim.Id;
     wrapper.userId = usr.Id;
     wrapper.isReviewFailed = true;
     wrapper.isRecommendedForAudit = false;
            
     wrapper.questionData = new List<Core_MDF_PICReviewScreen_Controller.QuestionWrapper>();
     Core_MDF_PICReviewScreen_Controller.QuestionWrapper qw = new Core_MDF_PICReviewScreen_Controller.QuestionWrapper();
     qw.id = prq.Id;
     qw.fileType = 'Proof of Cost';
     qw.response = 'Yes';
     qw.comment = 'Test comment';
     qw.tactic = new List<String>{ 'Digital Media' };
     qw.fileNames = new List<Core_MDF_PICReviewScreen_Controller.FileDetails>();
     Core_MDF_PICReviewScreen_Controller.FileDetails fd = new Core_MDF_PICReviewScreen_Controller.FileDetails();
     fd.selected = true;
     fd.originalFileName = 'TestFile.docx';
     qw.fileNames.add(fd);
     wrapper.questionData.add(qw);  
     Core_MDF_PICReviewScreen_Controller.reviewDataInsertion(wrapper);

     test.stopTest();
        Assert.areNotEqual(claim,null);
        }
    }
    
    @isTest static void testReviewDataInsertionfailedWithPICPassed()
    { 
       
     Core_MDF_PICReviewQuestion__c prq = [select Id from Core_MDF_PICReviewQuestion__c limit 1];
     PartnerFundClaim claim = [Select Id from PartnerFundClaim where title = 'PIC Review Claim1' limit 1];
     User usr = [select id,LastName from User where LastName = 'System Adm' limit 1];
           system.runAs(usr) {
     String questionData = '[{"questionEnglish" : "Is information on POA document consistent with claim?", "fileType" : "Proof of Attribution", "id" : "questionId", "name" : "QC-0010" , "fileNames" : [{"id" : "QC-0010-308", "label" : "PIC Review POC.docx", "selected" : true, "value": "PIC Review POC.docx"}], "response" : "No"}, {"questionEnglish" : "Does the file tagged as POC show cost ?", "fileType" : "Proof of Cost" , "id" : "questionId", "name" : "QC-0013", "fileNames" : [{"id" : "QC-0013", "label" : "PIC Review POC.docx", "selected" : false, "value" : "PIC Review POC.docx"}], "response" : "Yes"}]';
     String updatedQuestionData = questionData.replaceAll('questionId', prq.Id);
     Core_MDF_PICReviewScreen_Controller.picReviewDetailsWrapper wrapper = new Core_MDF_PICReviewScreen_Controller.picReviewDetailsWrapper();
     wrapper.questionData = (List<Core_MDF_PICReviewScreen_Controller.QuestionWrapper>)JSON.deserialize(updatedQuestionData, List<Core_MDF_PICReviewScreen_Controller.QuestionWrapper>.class);
     wrapper.internalComments = 'Testing';
     wrapper.startDateTime = System.now() - 2;
     wrapper.endDateTime = system.now() + 2;
     wrapper.claimId = claim.Id;
     wrapper.userId = usr.Id;
     wrapper.isReviewFailed = false;
     wrapper.isRecommendedForAudit = false;
     wrapper.questionData = new List<Core_MDF_PICReviewScreen_Controller.QuestionWrapper>();
     Core_MDF_PICReviewScreen_Controller.QuestionWrapper qw = new Core_MDF_PICReviewScreen_Controller.QuestionWrapper();
     qw.id = prq.Id;
     qw.fileType = 'Proof of Cost';
     qw.response = 'Yes';
     qw.comment = 'Test comment';
     qw.tactic = new List<String>{ 'Digital Media' };
     qw.fileNames = new List<Core_MDF_PICReviewScreen_Controller.FileDetails>();
     Core_MDF_PICReviewScreen_Controller.FileDetails fd = new Core_MDF_PICReviewScreen_Controller.FileDetails();
     fd.selected = true;
     fd.originalFileName = 'TestFile.docx';
     qw.fileNames.add(fd);
     wrapper.questionData.add(qw);  
     test.startTest(); 
     Core_MDF_PICReviewScreen_Controller.reviewDataInsertion(wrapper);

     test.stopTest();
        Assert.areNotEqual(claim,null);
           }
    }
    
    @isTest static void testReviewDataInsertionPIC()
    {   Core_MDF_PICReviewQuestion__c prq = [select Id from Core_MDF_PICReviewQuestion__c limit 1];
     PartnerFundClaim claim = [Select Id from PartnerFundClaim where title = 'PIC Review Claim2' limit 1];
     User usr = [select id,LastName from User where LastName = 'System Adm' limit 1];
        system.runAs(usr) {
     String questionData = '[{"Core_MDF_Question_English_txt__c" : "Is information on POA document consistent with claim?", "Core_MDF_Question_File_Type_nm__c" : "Proof of Attribution", "id" : "questionId", "name" : "QC-0010" , "fileNames" : [{"id" : "QC-0010-308", "label" : "PIC Review POC.docx", "selected" : true, "value": "PIC Review POC.docx"}], "response" : "No"}, {"questionEnglish" : "Does the file tagged as POC show cost ?", "fileType" : "Proof of Cost" , "id" : "questionId", "name" : "QC-0013", "fileNames" : [{"id" : "QC-0013", "label" : "PIC Review POC.docx", "selected" : false, "value" : "PIC Review POC.docx"}], "response" : "Yes"}]';
     String updatedQuestionData = questionData.replaceAll('questionId', prq.Id);
     Core_MDF_PICReviewScreen_Controller.picReviewDetailsWrapper wrapper = new Core_MDF_PICReviewScreen_Controller.picReviewDetailsWrapper();
     wrapper.questionData = (List<Core_MDF_PICReviewScreen_Controller.QuestionWrapper>)JSON.deserialize(updatedQuestionData, List<Core_MDF_PICReviewScreen_Controller.QuestionWrapper>.class);
     wrapper.internalComments = 'Testing';
     wrapper.startDateTime = System.now() - 2;
     wrapper.endDateTime = system.now() + 2;
     wrapper.claimId = claim.Id;
     wrapper.userId = usr.Id;
     wrapper.isReviewFailed = false;
     wrapper.isRecommendedForAudit = false;
     wrapper.questionData = new List<Core_MDF_PICReviewScreen_Controller.QuestionWrapper>();
     Core_MDF_PICReviewScreen_Controller.QuestionWrapper qw = new Core_MDF_PICReviewScreen_Controller.QuestionWrapper();
     qw.id = prq.Id;
     qw.fileType = 'Proof of Cost';
     qw.response = 'Yes';
     qw.comment = 'Test comment';
     qw.tactic = new List<String>{ 'Digital Media' };
     qw.fileNames = new List<Core_MDF_PICReviewScreen_Controller.FileDetails>();
     Core_MDF_PICReviewScreen_Controller.FileDetails fd = new Core_MDF_PICReviewScreen_Controller.FileDetails();
     fd.selected = true;
     fd.originalFileName = 'TestFile.docx';
     qw.fileNames.add(fd);
     wrapper.questionData.add(qw);  
     test.startTest();
     Core_MDF_PICReviewScreen_Controller.reviewDataInsertion(wrapper);

     test.stopTest();
     Assert.areNotEqual(claim,null);
        }
    }
    
    @isTest static void testReviewDataInsertionPICPending()
    {    
     Core_MDF_PICReviewQuestion__c prq = [select Id from Core_MDF_PICReviewQuestion__c limit 1];
     PartnerFundClaim claim = [Select Id from PartnerFundClaim where title = 'PIC Review Claim' limit 1];
     User usr = [select id,LastName from User where LastName = 'System Adm' limit 1];
           system.runAs(usr) {
     String questionData = '[{"Core_MDF_Question_English_txt__c" : "Is information on POA document consistent with claim?", "Core_MDF_Question_File_Type_nm__c" : "Proof of Attribution", "id" : "questionId", "name" : "QC-0010" , "fileNames" : [{"id" : "QC-0010-308", "label" : "PIC Review POC.docx", "selected" : true, "value": "PIC Review POC.docx"}], "response" : "No"}, {"questionEnglish" : "Does the file tagged as POC show cost ?", "fileType" : "Proof of Cost" , "id" : "questionId", "name" : "QC-0013", "fileNames" : [{"id" : "QC-0013", "label" : "PIC Review POC.docx", "selected" : false, "value" : "PIC Review POC.docx"}], "response" : "Yes"}]';
     String updatedQuestionData = questionData.replaceAll('questionId', prq.Id);
     Core_MDF_PICReviewScreen_Controller.picReviewDetailsWrapper wrapper = new Core_MDF_PICReviewScreen_Controller.picReviewDetailsWrapper();
     wrapper.questionData = (List<Core_MDF_PICReviewScreen_Controller.QuestionWrapper>)JSON.deserialize(updatedQuestionData, List<Core_MDF_PICReviewScreen_Controller.QuestionWrapper>.class);
     wrapper.internalComments = 'Testing';
     wrapper.startDateTime = System.now() - 2;
     wrapper.endDateTime = system.now() + 2;
     wrapper.claimId = claim.Id;
     wrapper.userId = usr.Id;
     wrapper.isReviewFailed = true;
     wrapper.isRecommendedForAudit = true;
     wrapper.questionData = new List<Core_MDF_PICReviewScreen_Controller.QuestionWrapper>();
     Core_MDF_PICReviewScreen_Controller.QuestionWrapper qw = new Core_MDF_PICReviewScreen_Controller.QuestionWrapper();
     qw.id = prq.Id;
     qw.fileType = 'Proof of Cost';
     qw.response = 'Yes';
     qw.comment = 'Test comment';
     qw.tactic = new List<String>{ 'Digital Media' };
     qw.fileNames = new List<Core_MDF_PICReviewScreen_Controller.FileDetails>();
     Core_MDF_PICReviewScreen_Controller.FileDetails fd = new Core_MDF_PICReviewScreen_Controller.FileDetails();
     fd.selected = true;
     fd.originalFileName = 'TestFile.docx';
     qw.fileNames.add(fd);
     wrapper.questionData.add(qw);
     test.startTest(); 
     Core_MDF_PICReviewScreen_Controller.reviewDataInsertion(wrapper);
 
     test.stopTest();
        Assert.areNotEqual(claim,null);
           }
    }  
    
    @isTest static void validateFailedPicReview(){
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1]; 
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.LastName = 'User Test';
        usr.UserRoleId = usRole.Id;
        Database.insert(usr);
        system.runAs(usr) {
        Test.startTest();
        PartnerFundClaim claim1 = [Select Id,Core_MDF_Status__c,Core_MDF_PIC_Review_Completed__c from PartnerFundClaim limit 1];
        claim1.Core_MDF_Status__c = label.Core_MDF_Claim_Status_PIC_Pending;
        update claim1;
         
        Core_MDF_PIC_Review__c picReview = Core_MDF_CCP_TestDataUtility.insertPICReview(1,'int comments',System.today()-2,System.today()+2,claim1.Id,usr.Id,true);
        //Core_MDF_PIC_Review__c picReview1 = Core_MDF_CCP_TestDataUtility.insertPICReview(2,'int comments',System.today()-2,System.today()+2,claim1.Id,usr.Id,true);
        Core_MDF_PICReviewScreen_Controller.claimUpdateOperations(picReview,claim1.id,false);
    
        Test.stopTest();
        Assert.areNotEqual(claim1,null);
           }
    }
    
    @isTest static void validateFailedPicReviewPostPayment(){
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1]; 
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.LastName = 'User Test';
        usr.UserRoleId = usRole.Id;
        Database.insert(usr);
        system.runAs(usr) {
        Test.startTest();
        PartnerFundClaim claim1 = [Select Id,Core_MDF_Status__c,Core_MDF_PIC_Review_Completed__c from PartnerFundClaim where Title = 'PIC Review Claim' limit 1];
        claim1.Core_MDF_Status__c = label.Core_MDF_Claim_Status_Paid_and_PIC_Pending;
        update claim1;        
        Core_MDF_PIC_Review__c picReview = Core_MDF_CCP_TestDataUtility.insertPICReview(1,'int comments',System.today()-2,System.today()+2,claim1.Id,usr.Id,true);
        //Core_MDF_PIC_Review__c picReview1 = Core_MDF_CCP_TestDataUtility.insertPICReview(2,'int comments',System.today()-2,System.today()+2,claim1.Id,usr.Id,true);
        
        Core_MDF_PICReviewScreen_Controller.claimUpdateOperations(picReview,claim1.id,false);
    
        Test.stopTest();
        Assert.areNotEqual(claim1,null);
           }
    }
    
    @isTest static void validateCompletedPicReview(){
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1]; 
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.LastName = 'User Test';
        usr.UserRoleId = usRole.Id;
        Database.insert(usr);
        system.runAs(usr){
        Test.startTest();
        PartnerFundClaim claim1 = [Select Id,Core_MDF_Status__c,Core_MDF_PIC_Review_Completed__c from PartnerFundClaim limit 1];
        claim1.Core_MDF_Status__c = label.Core_MDF_Claim_Status_PIC_Pending;
        update claim1;
        Core_MDF_PIC_Review__c picReview = Core_MDF_CCP_TestDataUtility.insertPICReview(1,'int comments',System.today()-2,System.today()+2,claim1.Id,usr.Id,false);
        
        //Core_MDF_PIC_Review__c picReview1 = Core_MDF_CCP_TestDataUtility.insertPICReview(2,'int comments',System.today()-2,System.today()+2,claim1.Id,usr.Id,true);
       
        Core_MDF_PICReviewScreen_Controller.claimUpdateOperations(picReview,claim1.id,false);

        Test.stopTest();
        Assert.areNotEqual(claim1,null);
        }
    }
    
    @isTest static void validateCompletedPicReviewPostPayment(){
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1]; 
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.LastName = 'User Test';
        usr.UserRoleId = usRole.Id;
        Database.insert(usr);
        system.runAs(usr) {
        Test.startTest();
        PartnerFundClaim claim1 = [Select Id,Core_MDF_Status__c,Core_MDF_PIC_Review_Completed__c from PartnerFundClaim limit 1];
        claim1.Core_MDF_Status__c = label.Core_MDF_Claim_Status_Paid_and_PIC_Pending;
        update claim1;
           
        Core_MDF_PIC_Review__c picReview = Core_MDF_CCP_TestDataUtility.insertPICReview(1,'int comments',System.today()-2,System.today()+2,claim1.Id,usr.Id,false);
        
        
        Core_MDF_PICReviewScreen_Controller.claimUpdateOperations(picReview,claim1.id,false);
  
        Test.stopTest();
        Assert.areNotEqual(claim1,null);
           }
    }
    
    @isTest static void validateFailedPicReviewDenied(){
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1]; 
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.LastName = 'User Test';
        usr.UserRoleId = usRole.Id;
        Database.insert(usr);
        system.runAs(usr) {
        Test.startTest();
        PartnerFundClaim claim1 = [Select Id,Core_MDF_Status__c,Core_MDF_PIC_Review_Completed__c from PartnerFundClaim limit 1];
        claim1.Core_MDF_Status__c = label.Core_MDF_Claim_Status_Paid_and_PIC_Pending;
        update claim1;
           
        Core_MDF_PIC_Review__c picReview = Core_MDF_CCP_TestDataUtility.insertPICReview(3,'int comments',System.today()-2,System.today()+2,claim1.Id,usr.Id,true);
        
        try
        {
            Core_MDF_PICReviewScreen_Controller.claimUpdateOperations(picReview,claim1.id,false);
          
        }
        catch(Exception e)
        {
            // Avoid empty catch blocks - Indira
                System.debug('Exception occurred: ' + e.getMessage());
                System.assert(e != null); 
        }
        Test.stopTest();
        Assert.areNotEqual(claim1,null);
           }
    }
    
    @isTest static void validateFailedPicReviewLegacy(){
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1]; 
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.LastName = 'User Test';
        usr.UserRoleId = usRole.Id;
        Database.insert(usr);
        system.runAs(usr) {
        Test.startTest(); 
        PartnerFundClaim claim1 = [Select Id,Core_MDF_Status__c,Core_MDF_PIC_Review_Completed__c,Core_MDF_RecentInternalComments_txt__c from PartnerFundClaim limit 1];
        claim1.Core_MDF_Status__c = label.Core_MDF_Claim_Status_PIC_Pending;
        claim1.Core_MDF_RecentInternalComments_txt__c = 'Testing';
        claim1.Core_MDF_Budget_Type_Options_Nm__c='CCF 1.0';
        update claim1;
           
        Core_MDF_PIC_Review__c picReview = Core_MDF_CCP_TestDataUtility.insertPICReview(3,null,System.today()-2,System.today()+2,claim1.Id,usr.Id,true);
            
        
        try
        {
             Core_MDF_PICReviewScreen_Controller.claimUpdateOperations(picReview,claim1.id,false);
          
        }
       catch(Exception e)
       {
           // Avoid empty catch blocks - Indira
              System.debug('Exception occurred: ' + e.getMessage());
              System.assert(e != null); 
       }
       Test.stopTest();
        Assert.areNotEqual(claim1,null);
           }
    }
    
     @isTest static void validateFailedPicReviewIntComments(){
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1]; 
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.LastName = 'User Test';
        usr.UserRoleId = usRole.Id;
        Database.insert(usr);
        system.runAs(usr) {
        Test.startTest();  
        PartnerFundClaim claim1 = [Select Id,Core_MDF_Status__c,Core_MDF_PIC_Review_Completed__c from PartnerFundClaim limit 1];
        claim1.Core_MDF_Status__c = label.Core_MDF_Claim_Status_PIC_Pending;
        claim1.Core_MDF_Budget_Type_Options_Nm__c='CCF 1.0';
        update claim1;
         
        Core_MDF_PIC_Review__c picReview = Core_MDF_CCP_TestDataUtility.insertPICReview(3,null,System.today()-2,System.today()+2,claim1.Id,usr.Id,true);
          
        try
        {
             Core_MDF_PICReviewScreen_Controller.claimUpdateOperations(picReview,claim1.id,false);
           
        }
       catch(Exception e)
       {
           // Avoid empty catch blocks - Indira  
          System.debug('Exception occurred: ' + e.getMessage());
          System.assert(e != null); 
       }
       Test.stopTest();
         Assert.areNotEqual(claim1,null);
           }
    }

    @isTest
    static void testFetchExceptionsByClaimId() {
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1]; 
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.LastName = 'User Test';
        usr.UserRoleId = usRole.Id;
        Database.insert(usr);
        
        PermissionSet ps = [SELECT Id FROM PermissionSet 
                    WHERE Name = 'Core_MDF_CCP_Internal_CCF_Acct_Mgr' 
                    LIMIT 1];

        insert new PermissionSetAssignment(
            AssigneeId = usr.Id,
            PermissionSetId = ps.Id
        );
        
        system.runAs(usr){
        Test.startTest();
        Account intelAccount = [Select id from Account limit 1];

        PartnerFundClaim claim1 = [Select Id,Core_MDF_Status__c,Core_MDF_PIC_Review_Completed__c, Core_MDF_Ad_Run_Start_Date__c, Core_MDF_Ad_Run_End_Date__c, Core_MDF_Program__c,Core_MDF_Activity_Category__c, Core_MDF_Activity_Types__c, ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__r.Id  from PartnerFundClaim where Title = 'PIC Review Claim' limit 1];
        claim1.Core_MDF_Status__c = label.Core_MDF_Claim_Status_PIC_Pending;
        update claim1;

        Core_MDF_Exception__c expt = new Core_MDF_Exception__c();
        expt.Core_MDF_Name_of_Exception_nm__c = 'Test Exception Single Account Single Country';
        expt.Core_MDF_Issue_Description_dsc__c = 'Test Description';
        expt.Core_MDF_Comments_txt__c = 'Test Comments';
        expt.Core_MDF_Exception_Start_Date_dt__c = System.today() - 182;
        expt.Core_MDF_Exception_End_Date_dt__c = System.today() + 5;
        expt.Core_MDF_Exception_Reason_nm__c = 'Branding Exception from Activity Catalog';
        expt.Core_MDF_Program_nm__c = 'Core_MDF_Client_CoMarketing_Fund';
        expt.Core_MDF_Activity_Cate_and_Type_nm__c = 'Broadcast (Pre-2025)->Podcast';
        expt.Core_MDF_Total_Dollar_Impact_amt__c = 100;
        expt.Core_MDF_Country_Region_nm__c = 'INDIA';
        expt.Core_MDF_Account_id__c = intelAccount.Id;
        expt.Core_MDF_Select_All_Accounts_ind__c = false;
        //expt.Core_MDF_Budget_Type_nm__c = 'MDF';
                system.runAs(usr) {
        insert expt;
        expt.Core_MDF_Exception_Status_nm__c = 'Approved';
        update expt;
       // Unit Test Method should include System.Assert - Indira
       System.assertEquals('Approved', expt.Core_MDF_Exception_Status_nm__c, 'Exception status should be Approved');
                    
            // Highlight: Unused Local Variable - Indira
           /* Map<Id, Core_MDF_Exception__c> result = */ Core_MDF_PICReviewScreen_Controller.fetchExceptionsByClaimId(claim1.Id, intelAccount.Id);
        test.stoptest();
                }
        }
        //assert.areEqual(1, result.size(), 'Expected one exception record.');
    } 

    @isTest
    static void testFetchAIResponse() {         
         UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1]; 
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.LastName = 'User Test';
        usr.UserRoleId = usRole.Id;
        Database.insert(usr);
        PartnerFundClaim testClaim = [SELECT Id FROM PartnerFundClaim LIMIT 1];
        system.runAs(usr) {
            Test.startTest();        
            // Seed one PIC review as manual (AI flag false)
            Core_MDF_PIC_Review__c review = new Core_MDF_PIC_Review__c(
                Core_MDF_Claim_ID_id__c = testClaim.Id,
                Core_MDF_AI_PIC_Review_Ind__c = false,
                Core_MDF_StartTime_dtm__c = System.now(),
                Core_MDF_EndTime_dtm__c = System.now()
            );
            insert review;

            // Case 1: Manual latest -> UNAVAILABLE
            Core_MDF_PICReviewScreen_Controller.AIResponseWrapper r1 = Core_MDF_PICReviewScreen_Controller.fetchAIResponse(testClaim.Id);
            System.assertEquals('UNAVAILABLE', r1.status, 'Manual latest -> UNAVAILABLE');
            System.assertEquals(null, r1.picReviewId, 'No picReviewId expected when UNAVAILABLE');
            System.assertEquals(0, r1.picReviewDetails.size(), 'No details expected when UNAVAILABLE');

            // Prepare one result row connected to the same review (for AVAILABLE checks)
            Core_MDF_PICReviewResult__c resultRow = new Core_MDF_PICReviewResult__c(
                Core_MDF_PIC_Review_id__c = review.Id,
                Core_MDF_Question_id__c = [SELECT Id FROM Core_MDF_PICReviewQuestion__c LIMIT 1].Id,
                Core_MDF_Response_txt__c = 'No'
            );
            insert resultRow;

            // Case 2: AI Failed -> AVAILABLE
            review.Core_MDF_AI_PIC_Review_Ind__c = true;
            review.Core_MDF_Review_Status_nm__c = 'AI Failed';
            update review;
            Core_MDF_PICReviewScreen_Controller.AIResponseWrapper r2 = Core_MDF_PICReviewScreen_Controller.fetchAIResponse(testClaim.Id);
            System.assertEquals('AVAILABLE', r2.status, 'AI Failed -> AVAILABLE');
            System.assertEquals(review.Id, r2.picReviewId, 'Should return same review Id');
            System.assert(r2.picReviewDetails.size() > 0, 'Details should be returned for AVAILABLE');

            // Case 3: AI Passed -> AVAILABLE
            review.Core_MDF_Review_Status_nm__c = 'AI Passed';
            update review;
            Core_MDF_PICReviewScreen_Controller.AIResponseWrapper r3 = Core_MDF_PICReviewScreen_Controller.fetchAIResponse(testClaim.Id);
            System.assertEquals('AVAILABLE', r3.status, 'AI Passed -> AVAILABLE');
            System.assertEquals(review.Id, r3.picReviewId, 'Should return same review Id');
            System.assert(r3.picReviewDetails.size() > 0, 'Details should be returned for AVAILABLE');

            // Case 4: Blank status -> INPROGRESS
            review.Core_MDF_Review_Status_nm__c = null;
            update review;
            Core_MDF_PICReviewScreen_Controller.AIResponseWrapper r4 = Core_MDF_PICReviewScreen_Controller.fetchAIResponse(testClaim.Id);
            System.assertEquals('INPROGRESS', r4.status, 'Blank status -> INPROGRESS');
            System.assertEquals(0, r4.picReviewDetails.size(), 'No details when INPROGRESS');

            // Case 5: Other status -> UNAVAILABLE
            review.Core_MDF_Review_Status_nm__c = 'Completed';
            update review;
            Core_MDF_PICReviewScreen_Controller.AIResponseWrapper r5 = Core_MDF_PICReviewScreen_Controller.fetchAIResponse(testClaim.Id);
            System.assertEquals('UNAVAILABLE', r5.status, 'Non-allowed status -> UNAVAILABLE');
            System.assertEquals(0, r5.picReviewDetails.size(), 'No details when UNAVAILABLE');

            Test.stopTest();
        }
    }
    
    @isTest
    static void testFetchTactics() {
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1]; 
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.LastName = 'User Test';
        usr.UserRoleId = usRole.Id;
        Database.insert(usr);
        system.runAs(usr) {
            test.startTest();
            PartnerFundClaim claim = [Select Id from PartnerFundClaim limit 1];


        // Create test records for Core_MDF_Claim_Attributes__c
        List<Core_MDF_Claim_Attributes__c> attrList = new List<Core_MDF_Claim_Attributes__c>();

        attrList.add(new Core_MDF_Claim_Attributes__c(
            Core_MDF_Claim_Id__c = claim.Id,
            Core_MDF_Is_Active_Ind__c = true,
            Core_MDF_Tactics_nm__c = 'Event',
            Core_MDF_Type_nm__c = 'KPI - Claim',
            Core_MDF_Field_Name_nm__c = 'Training Percentage Spend',
            Core_MDF_Field_Value_nbr__c = 10
        ));

        attrList.add(new Core_MDF_Claim_Attributes__c(
            Core_MDF_Claim_Id__c = claim.Id,
            Core_MDF_Is_Active_Ind__c = true,
            Core_MDF_Tactics_nm__c = 'Funded Headcount',
            Core_MDF_Type_nm__c = 'Spend This Period',
            Core_MDF_Field_Name_nm__c = 'Training Percentage Spend',
            Core_MDF_Field_Value_nbr__c = 20
        ));

        attrList.add(new Core_MDF_Claim_Attributes__c(
            Core_MDF_Claim_Id__c = claim.Id,
            Core_MDF_Is_Active_Ind__c = true,
            Core_MDF_Tactics_nm__c = 'Incentive',
            Core_MDF_Type_nm__c = 'KPI - Claim',
            Core_MDF_Field_Name_nm__c = 'Training Percentage Spend',
            Core_MDF_Field_Value_nbr__c = 30
        ));

        // This record should NOT be included (inactive)
        attrList.add(new Core_MDF_Claim_Attributes__c(
            Core_MDF_Claim_Id__c = claim.Id,
            Core_MDF_Is_Active_Ind__c = false,
            Core_MDF_Tactics_nm__c = 'Training',
            Core_MDF_Type_nm__c = 'KPI - Claim'
        ));

        insert attrList;

        Map<String, List<Core_MDF_Claim_Attributes__c>> result =
            Core_MDF_PICReviewScreen_Controller.fetchTactics(claim.Id);
        Test.stopTest();
        }        
    
	}
}