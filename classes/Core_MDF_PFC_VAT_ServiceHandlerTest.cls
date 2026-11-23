/****************************************************************************************************************************************
* Class Name        : Core_MDF_PFC_VAT_ServiceHandlerTest
* Created Date      : 14/10/2020
* Modification Log
* Developer            Date               Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Sridhar       14/10/2020         Test Class for Core_MDF_PFC_VAT_ServiceHandlerTest
*****************************************************************************************************************************************/
@isTest(SeeAllData=false)
public class Core_MDF_PFC_VAT_ServiceHandlerTest {
    
    @TestSetUp
    static void createTestData() {

        List<User> userList = new List<User>();
        //Role
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        User testUser = Core_MDF_CCP_TestDataUtility.createUser(false);
        testUser.UserRoleId = usRole.Id;
        insert testUser;

        User testUser1 = Core_MDF_CCP_TestDataUtility.createUser(false);
        testUser1.Email = 'testUsercoreMDF1@intel.com';
        testUser1.UserName = 'testUser1'+String.valueOf(Math.random())+'@CoreMDF.com';
        testUser1.UserRoleId = usRole.Id;
        insert testUser1;
        
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
        bypassFunctionKeys.add('Bypass_Claims_Amt_vs_Budget_Amt_Check');        
        bypassFunctionKeys.add('Bypass_Claims_ABM_Validation');
        bypassFunctionKeys.add('Bypass_Claims_Sharing_Partner_Users');
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
        bypassFunctionKeys.add('Bypass_Activity_ApprovalProcess');
        bypassFunctionKeys.add('Bypass_ShareActivityWithUsers');
        bypassFunctionKeys.add('Bypass_ShareActivityWithAccNodeGroup');
        bypassFunctionKeys.add('Bypass_geoLeadApprovalProcess');
        bypassFunctionKeys.add('Bypass_MDF_Budget_Access_Validation');
        bypassFunctionKeys.add('Bypass_MDF_Budget_Status_Validation');
        
        Set<String> myset1 = new Set<String>();
        List<String> result1 = new List<String>();
        myset1.addAll(bypassFunctionKeys);
        result1.addAll(myset1);
        
        system.runAs(testUser1){
            List<Core_Trigger_Executions__c> bypassfunctinalitylist1 = Core_MDF_CCP_TestDataUtility.byPassFeature(result1,true,true);
        }

        Map<String,PermissionSet> nameToPerSet = new Map<String,PermissionSet>();
        for(PermissionSet pSet:[SELECT Id,Name FROM PermissionSet WHERE Name IN ('Core_MDF_CCP_Internal_Program_Adm',
                            'Core_MDF_CCP_Internal_Claim_Case_Reviewer',
                            'Core_MDF_CCP_External_Claim_Submitter',
                            'Core_MDF_CCP_External_Retail_Claim_Submitter',
                            'Core_MDF_CCP_Internal_APJ_User',
                            'Core_MDF_CCP_Internal_Payment_Schedule_Admin',
                            'Core_MDF_CCP_Internal_Retail_Payment_Adm',
                            'View_All_Data',
                            'Core_MDF_CCP_Internal_CCF_Payment_Adm',
                            'Core_MDF_CCP_Internal_Retail_Finance_Usr',
                            'Core_MDF_CCP_Internal_DCF_MDF_Payment_Admin')]) {
            nameToPerSet.put(pSet.Name,pSet);
        }
        
        PermissionSet retailInternalFinanceUser = nameToPerSet.get('Core_MDF_CCP_Internal_Retail_Finance_Usr'); 

        PermissionSetAssignment assignMDFBudgetLoaderPermissionSet = new PermissionSetAssignment();
        assignMDFBudgetLoaderPermissionSet.AssigneeId = testUser.Id;
        assignMDFBudgetLoaderPermissionSet.PermissionSetId = retailInternalFinanceUser.Id; 
        system.runAs(testUser){
            Database.insert(assignMDFBudgetLoaderPermissionSet);
        }
        
        List<Group> groupList = new List<Group>();

        // Creating Groups for PGM
        Group grp = new Group();
        grp.name = 'PGM_TEST';
        groupList.add(grp);

        Database.insert(groupList);

        // Adding Users in group
        List<GroupMember> gmList = new List<GroupMember>();
        GroupMember gm = new GroupMember();
        gm.GroupId = grp.Id;
        gm.UserOrGroupId = testUser.Id;

        gmList.add(gm);
        system.runAs(testUser){
          insert gmList;
        }
        
        Profile sysAdminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        
        User usrs = Core_MDF_CCP_TestDataUtility.createUser(false);
        usrs.Email = 'sysadmin@example.com';
        usrs.LastName = 'System Adm';
        usrs.ProfileId = sysAdminProfile.Id;
        usrs.isActive = true;
        database.insert(usrs);
        
        PermissionSet payAdmPS = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_Retail_Payment_Adm' LIMIT 1];
        PermissionSetAssignment assignPerSetObj = new PermissionSetAssignment();
        assignPerSetObj.AssigneeId = usrs.Id;
        assignPerSetObj.PermissionSetId = payAdmPS.Id;
        Database.insert(assignPerSetObj);
        
        System.runAs(testUser){
            
            Core_MDF_Configuration__c vatConfig = new Core_MDF_Configuration__c();
            vatConfig.Name = 'PAYMENT_DOC_ALLOWED_FILE_EXTENSIONS';
            vatConfig.Core_MDF_Value__c = 'pdf';
            insert vatConfig;
           
            ChannelProgram retailCP = Core_MDF_CCP_TestDataUtility.createProgram ('Retail Marketing Funds','Retail Marketing Funds', true);
        
            Account retailIntelAcc = Core_MDF_CCP_TestDataUtility.createIntelAccount('Test Retail Intel Account', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
            retailIntelAcc.Core_Geo__c = 'APJ';
            insert retailIntelAcc;
            
            Account masterAcc = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test Master Account', retailCP.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, retailIntelAcc.Id, false);
            masterAcc.Core_Geo__c = 'APJ';
            //masterAcc.Core_Sub_Geo__c = 'IJKK';
            insert masterAcc;

            PartnerMarketingBudget retailBudget = Core_MDF_CCP_TestDataUtility.createBudget('TestBudgetData1',Core_MDF_CCP_TestDataUtility.budget_Record_Type,
            masterAcc.id, retailCP.Id , 10000 , System.today()-60 , System.today() + 60 , false);
            retailBudget.Core_MDF_Budget_Status__c = 'Released';
            retailBudget.IsIgnoreValidation = true;
            insert retailBudget;
            /*retailBudget.Core_MDF_Budget_Status__c = 'Released';
            retailBudget.IsIgnoreValidation = true;
            update retailBudget;*/
            
            //allocation
            PartnerFundAllocation allocation = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('Test Allocation New',retailBudget,masterAcc,200.0,true);
        
                
            Profile ccpCoreAccessProfile = [SELECT Id FROM Profile WHERE Name='CCP - Core Access' LIMIT 1];
            Profile partnerProfile = [SELECT Id FROM Profile WHERE Name='Partner' limit 1];
            PermissionSet aacntMngrPS = [SELECT Id, Name FROM PermissionSet WHERE Name='Core_MDF_CCP_Internal_Retail_Account_Manager' LIMIT 1];
           // Highlight: Unused Local Variable
           // PermissionSet extApprPS = [SELECT Id, Name FROM PermissionSet WHERE Name='Core_MDF_CCP_External_Activity_Approver' LIMIT 1];

            Contact con  = Core_MDF_CCP_TestDataUtility.createContact(retailIntelAcc.Id, true);
            User usrBudgetAdmin = Core_MDF_CCP_TestDataUtility.createUser(false);
            usrBudgetAdmin.LastName = 'Budget Admin';
            usrBudgetAdmin.ContactId = con.Id;
            usrBudgetAdmin.ProfileId = partnerProfile.Id;
            usrBudgetAdmin.portalRole = 'Manager';
            usrBudgetAdmin.email = 'ccfextapprover@example.com';
            usrBudgetAdmin.isActive = true;
            userList.add(usrBudgetAdmin);
            //Database.insert(usrBudgetAdmin);
            
            User ccfaccntmngr = Core_MDF_CCP_TestDataUtility.createUser(false);
            ccfaccntmngr.Email = 'ccfaccntmngr@example.com';
            ccfaccntmngr.Profile = ccpCoreAccessProfile;
            userList.add(ccfaccntmngr);
            //Database.insert(ccfaccntmngr);

            Database.insert(userList);

            PermissionSetAssignment assignPermissionSetObj = new PermissionSetAssignment();
            assignPermissionSetObj.AssigneeId = ccfaccntmngr.Id;
            assignPermissionSetObj.PermissionSetId = aacntMngrPS.Id;
            Database.insert(assignPermissionSetObj);

            Campaign retailCampaign = Core_MDF_CCP_TestDataUtility.createCampaign('Test Retail Camp 1','Business','Intel® 10ᵗʰ Gen','Yes',
                                                                     Core_MDF_CCP_TestDataUtility.campaign_RecordType_Retail, 
                                                                     'Retail_Marketing_Funds', System.today(),
                                                                     System.today()+300, 10000, 'Instore merchandise', 
                                                                     masterAcc.Id,'All-in-One Desktop', false);
        
            retailCampaign.RecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Core_MDF_Retail_Marketing_Funds').getRecordTypeId();
            retailCampaign.Core_MDF_Activity_Category_Type__c =null;
            retailCampaign.Core_MDF_Program__c = 'Retail Marketing Funds';
            retailCampaign.Core_MDF_Reimbursement_Rate__c='100%';
            retailCampaign.Core_MDF_Technology__c = 'Wifi6';
            //retailCampaign.Core_MDF_Budget_Type_txt__c ='Retail MDF';
            retailCampaign.Core_MDF_Opal_Budget_Type_Txt__c='Retail MDF'; 
            insert retailCampaign;
            // Highlight: Unused Local Variable
           // List<Core_MDF_Bank__c> listBank = new List<Core_MDF_Bank__c>();            
            
            Core_MDF_Bank__c bank = Core_MDF_CCP_TestDataUtility.createBank(retailIntelAcc.Id, 'Core_MDF_Retail_Marketing_Funds', false,'1231231230');
            bank.Core_MDF_Bank_Alias_Name__c='Test';
            bank.Core_MDF_Bank_Status__c ='Active';  
            bank.Core_MDF_Intel_Company_Code__c = '650';     
            bank.Core_MDF_Tax_codes_cd__c = 'UB';
            bank.Core_MDF_VAT_pct__c='20';
            Database.insert(bank);        
            
            //Do Account Bank Mapping for 'bank' and ABM is applicaple only for "Retail MDF" record type
            // Highlight: Unused Local Variable
           // Core_MDF_Account_Bank_Mapping__c abm1 = Core_MDF_CCP_TestDataUtility.createAccountBankMap(masterAcc.Id,bank.Id,true);
            
            Core_MDF_CCP_TestDataUtility.createPartnerGroupMapping(retailIntelAcc.Id,'Internal',retailIntelAcc.Id,retailCP.Id,'PGM_Retail_TEST',true);
            
            //Core_MDF_CCP_TestDataUtility.createPartnerNodeUserMapping(masterAcc.Id, usrBudgetAdmin.Id, true);
            
            //Addeed by Areefa
            List<Core_Trigger_Executions__c> executionClaimVat = new List<Core_Trigger_Executions__c>();
            Core_Trigger_Executions__c claimFunctionalityNameTriggerExecution = new Core_Trigger_Executions__c();
            claimFunctionalityNameTriggerExecution.Core_Active__c = true;
            claimFunctionalityNameTriggerExecution.Core_Class_Name__c = 'Core_MDF_PFCServiceHandler';
            claimFunctionalityNameTriggerExecution.Core_Trigger_Events__c = 'before insert,after update';
            claimFunctionalityNameTriggerExecution.Core_Object__c = 'PartnerFundClaim';
            claimFunctionalityNameTriggerExecution.Name = 'enableClaimsVATEligible';
            claimFunctionalityNameTriggerExecution.Core_Description__c = 'description';
            //Database.insert(claimFunctionalityNameTriggerExecution); 
            executionClaimVat.add(claimFunctionalityNameTriggerExecution);
            
            Core_Trigger_Executions__c claimFunctionalityNameTriggerExecution1 = new Core_Trigger_Executions__c();
            claimFunctionalityNameTriggerExecution1.Core_Active__c = true;
            claimFunctionalityNameTriggerExecution1.Core_Class_Name__c = 'Core_MDF_PFCServiceHandler';
            claimFunctionalityNameTriggerExecution1.Core_Trigger_Events__c = 'before insert,after update';
            claimFunctionalityNameTriggerExecution1.Core_Object__c = 'PartnerFundClaim';
            claimFunctionalityNameTriggerExecution1.Name = 'enableClaimsVatAfterInsert';
            claimFunctionalityNameTriggerExecution1.Core_Description__c = 'description';
            executionClaimVat.add(claimFunctionalityNameTriggerExecution1);
            
            Core_Trigger_Executions__c claimFunctionalityNameTriggerExecution2 = new Core_Trigger_Executions__c();
            claimFunctionalityNameTriggerExecution2.Core_Active__c = true;
            claimFunctionalityNameTriggerExecution2.Core_Class_Name__c = 'Core_MDF_PFCServiceHandler';
            claimFunctionalityNameTriggerExecution2.Core_Trigger_Events__c = 'before insert,after update';
            claimFunctionalityNameTriggerExecution2.Core_Object__c = 'PartnerFundClaim';
            claimFunctionalityNameTriggerExecution2.Name = 'enableClaimsVatAfterUpdate';
            claimFunctionalityNameTriggerExecution2.Core_Description__c = 'description';
            executionClaimVat.add(claimFunctionalityNameTriggerExecution2);
            
            Core_Trigger_Executions__c claimFunctionalityNameTriggerExecution3 = new Core_Trigger_Executions__c();
            claimFunctionalityNameTriggerExecution3.Core_Active__c = true;
            claimFunctionalityNameTriggerExecution3.Core_Class_Name__c = 'Core_MDF_PFCServiceHandler';
            claimFunctionalityNameTriggerExecution3.Core_Trigger_Events__c = 'before insert,after update';
            claimFunctionalityNameTriggerExecution3.Core_Object__c = 'PartnerFundClaim';
            claimFunctionalityNameTriggerExecution3.Name = 'enableClaimVatBeforeUpdate';
            claimFunctionalityNameTriggerExecution3.Core_Description__c = 'description';
            executionClaimVat.add(claimFunctionalityNameTriggerExecution3);
        
            Database.insert(executionClaimVat);           
            
        }

        User usr = [select id,email from User where email='ccfaccntmngr@example.com' limit 1];

        PartnerFundRequest pfReq = new PartnerFundRequest();
        Test.startTest(); 
        System.runAs(usr){
            Campaign camp = [select id,Name from Campaign WHERE Name = 'Test Retail Camp 1' LIMIT 1];
            PartnerFundAllocation pfa=[select id from PartnerFundAllocation where Title =: 'Test Allocation New'];
            Account accCoMarketing = [select id from Account WHERE Name = 'Test Master Account'];
            pfReq = Core_MDF_CCP_TestDataUtility.insertPartnerFundRequest(string.valueof(camp.id),Core_MDF_CCP_TestDataUtility.partnerFund_RecordType_Retail,string.valueof(accCoMarketing.id),null,null,'UNITED KINGDOM','Business','All-in-One Desktop','Intel® 10ᵗʰ Gen','Broadcast (Pre-2025)','Podcast','Draft',false);
            //pfReq.Core_MDF_Fund_Request_Status__c = 'Pending Review';
            pfReq.Status='Approved';
            pfReq.Title = 'Test Retail Activity';
            pfReq.Core_MDF_Activity_Description__c = 'Test Retail Activity';
            pfReq.Core_MDF_Budget_Type_nm__c ='Retail MDF';
            pfReq.Core_MDF_Channel_Partner_Led__c = false;
            pfReq.Core_MDF_Budget_Amount_Local_amt__c=100;
            pfReq.Core_MDF_Budget_Currency_cd__c='USD';
            pfReq.Core_MDF_Estimated_Ad_Size_nbr__c=5;
            pfReq.Core_MDF_Magazine_Newspaper_txt__c='Magazine';
            pfReq.Core_MDF_Start_Date__c = System.today();
            pfReq.Core_MDF_End_Date__c = System.today();
            pfReq.Core_MDF_Reimbursement_Rate_pct__c='100%';  
            pfReq.amount = 100;
            pfReq.Core_MDF_Reimbursement_Rate_txt__c='100%';
            pfReq.AllocationId=pfa.id;
            insert pfReq;
        }
        Test.stopTest();        
    }
    
/****************************************************************************************************************************************
* Method Name        : testRetailMDFVATInvoiceFileValidate
* Created Date      : 14/10/2020
* Modification Log
* Developer            Date               Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Sridhar       14/10/2020                Coverage for invoice number and file upload scenarios for VAT
*****************************************************************************************************************************************/
    @isTest
    static void testRetailMDFVATInvoiceFileValidate()
    {
        User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' and LastName = 'System Adm' limit 1];
        boolean submitStatusBFile = false;
        boolean submitStatusAFile = false;
        Core_MDF_CCP_TestDataUtility.createMDFConfigurationData();
        System.runAs(sysAdminUser)
        {
            test.startTest();
            Core_MDF_Bank__c bank1 = [Select Id from Core_MDF_Bank__c where Core_MDF_Bank_Alias_Name__c='Test' limit 1];
            PartnerFundRequest pfr = [Select Id,Title,Core_MDF_Reimbursement_Rate__c from PartnerFundRequest where Title = 'Test Retail Activity'];
            PartnerFundClaim claim1 = Core_MDF_CCP_TestDataUtility.createClaim('Test Retail Claim', Core_MDF_CCP_TestDataUtility.claim_RecordType_Retail, pfr.Id, System.today(), System.today(), 50.00, System.today(), bank1.Id, false);
            claim1.Core_MDF_Type_Txt__c ='Claim';
            claim1.Core_MDF_Currency__c='USD';
            claim1.Core_MDF_Country_Location_nm__c= 'UNITED KINGDOM'; 
            claim1.Core_MDF_VAT_Opt_In__c = 'Service Invoice to Intel (VAT may apply)';
            claim1.Core_MDF_VAT_Eligibility_Ind__c= true ; 
            claim1.Core_MDF_VAT_Hold_Ind__c = true;
            claim1.Core_MDF_Status__c = 'Hold';
            insert claim1;
            list<Core_MDF_Audit_Document__c> auditDocList = new list<Core_MDF_Audit_Document__c>();
            String amt5='{\"totalAmountLocal\" :100,\"costNotReimbursable\":0,\"taxesLocal\":0}';
            Core_MDF_PartnerFundClaim.ClaimWrap res = new Core_MDF_PartnerFundClaim.ClaimWrap();
            res = Core_MDF_PartnerFundClaim.saveClaim(claim1, auditDocList,amt5, null,false, null, false, null, false);
            //String res = Core_MDF_PartnerFundClaim.saveClaim(claim1, auditDocList);   
			//System.assertNotEquals(null, res, 'saveClaim() returned null');
            //System.assertNotEquals(null, res.claimDetail, 'saveClaim().claimDetail is null');
            //System.assertNotEquals(null, res.claimDetail.Id, 'Claim ID in ClaimWrap is null');
           
  
            PartnerFundClaim claimins = [select id,Core_MDF_VAT_Eligibility_Ind__c,Core_MDF_Status__c,Core_MDF_Audit_Hold__c from PartnerFundClaim where Title ='Test Retail Claim' limit 1];
            claimins.Core_MDF_Status__c = 'Hold';
            Database.update(claimins);
          
            // Read the VAT Invoice record
            Core_MDF_Claim_VAT_Info__c vatInfo = [select id from Core_MDF_Claim_VAT_Info__c where Core_MDF_Claim_Id__c = : res.claimDetail.id limit 1];
            
            vatInfo.Core_MDF_VAT_Invoice_Number_Txt__c = 'VATINV001';
            vatInfo.Core_MDF_Status_Txt__c ='Pending Documents';
            Database.update(vatInfo);
            system.assertEquals('Pending Documents',vatInfo.Core_MDF_Status_Txt__c);
           // Submit for approval before uploading file
            submitStatusBFile = submitForApproval(vatInfo.Id);
            
            //Create Document
            ContentVersion cv = new ContentVersion();
            cv.Title = 'Test Document';
            cv.PathOnClient = 'TestDocument.pdf';
            cv.VersionData = Blob.valueOf('Test Content');
            cv.IsMajorVersion = true;
            insert cv;
            
            ContentVersion cv1 = new ContentVersion();
            cv1.Title = 'Test Document';
            cv1.PathOnClient = 'TestDocument.pdf';
            cv1.VersionData = Blob.valueOf('Test Content');
            cv1.IsMajorVersion = true;
            insert cv1;
            
            //Get Content documents
            List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];

            //create ContentDocumentLink  record 
            ContentDocumentLink cdl = New ContentDocumentLink();
            cdl.LinkedEntityId = vatInfo.Id;
            cdl.ContentDocumentId = documents[0].Id;
            cdl.shareType = 'V';
            insert cdl;
            
            ContentDocumentLink cdl1 = New ContentDocumentLink();
            cdl1.LinkedEntityId = vatInfo.Id;
            cdl1.ContentDocumentId = documents[0].Id;
            cdl1.shareType = 'V';
            
            try{
                insert cdl1;
                
            }catch(Exception e){ Core_MDF_CCP_UtilityClass.logError(e);} 
            
            // Submit for approval after uploading file
            submitStatusAFile = submitForApproval(vatInfo.Id);
            
            ApproveTheRecord(vatInfo.Id);
            
            // Remove from the approval queue
             
            List<Core_MDF_Claim_VAT_Info__c> vatInfoList = new List<Core_MDF_Claim_VAT_Info__c>();
            vatInfoList.add(vatInfo);
            
            Core_MDF_PFC_VAT_ServiceHandler.removeVATFromApprovalQueue(vatInfoList);
            
            
             
            //System.assertEquals(true, submitStatusAFile && !submitStatusBFile,'Invoice and File validations failed');
            
            test.stopTest();
        }
    }
    
    static boolean submitForApproval(Id recordId){

        //Submit Quote for Approval
        try{
            Approval.ProcessSubmitRequest app = new Approval.ProcessSubmitRequest();
            app.setObjectId(recordId);
            // Highlight: Unused Local Variable
           /* Approval.ProcessResult result = */ Approval.process(app);
            return true;
        }catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e); return false;} 
    }
    
    static boolean ApproveTheRecord(Id recordId){

        //Submit Quote for Approval
        try{
            Approval.ProcessWorkitemRequest witmReq = new Approval.ProcessWorkitemRequest();
            witmReq.setComments('Approving request.');
            witmReq.setAction('Approve');
            //witmReq.setNextApproverIds(new Id[] {UserInfo.getUserId()});
        
            ProcessInstanceWorkitem pItem = [Select Id from ProcessInstanceWorkitem where ProcessInstance.TargetObjectId =: recordId and ProcessInstance.Status = 'Pending' limit 1];
            witmReq.setWorkitemId(pItem.Id);
            
            // Submit the request for approval
            Approval.process(witmReq);
            return true;
            
        }catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e); return false;} 
    }
    
    @isTest 
     static void testDateFieldsOnVATUpdate()
     {
        User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' and LastName = 'System Adm' limit 1];
        // Highlight: Unused Local Variable
       // boolean submitStatusBFile = false;
       // boolean submitStatusAFile = false;
        Core_MDF_CCP_TestDataUtility.createMDFConfigurationData();
        System.runAs(sysAdminUser)
        {
            /*Core_MDF_Configuration__c config = new Core_MDF_Configuration__c();
            config.name = 'ALLOWED_PRG_FOR_RUS_NOTIF';
            config.Core_MDF_Category__c = 'Bank Document Hold Logic';
            config.Core_MDF_Value__c = 'Retail Marketing Funds,Intel Partner Alliance,Channel MDF';
            insert config;*/
            test.startTest();
            Core_MDF_Bank__c bank1 = [Select Id from Core_MDF_Bank__c where Core_MDF_Bank_Alias_Name__c='Test' limit 1];
            PartnerFundRequest pfr = [Select Id,Title,Core_MDF_Reimbursement_Rate__c from PartnerFundRequest where Title = 'Test Retail Activity'];
            PartnerFundClaim claim1 = Core_MDF_CCP_TestDataUtility.createClaim('Test Retail Claim', Core_MDF_CCP_TestDataUtility.claim_RecordType_Retail, pfr.Id, System.today(), System.today(), 50.00, System.today(), bank1.Id, false);
            claim1.Core_MDF_Type_Txt__c ='Claim';
            claim1.Core_MDF_Currency__c='USD';
            claim1.Core_MDF_Country_Location_nm__c= 'UNITED KINGDOM'; 
            claim1.Core_MDF_VAT_Opt_In__c = 'Service Invoice to Intel (VAT may apply)';
            claim1.Core_MDF_VAT_Eligibility_Ind__c= true ; 
            claim1.Core_MDF_VAT_Hold_Ind__c = true;
            insert claim1;
            list<Core_MDF_Audit_Document__c> auditDocList = new list<Core_MDF_Audit_Document__c>();
            Core_MDF_PartnerFundClaim.ClaimWrap res = new Core_MDF_PartnerFundClaim.ClaimWrap();
            res = Core_MDF_PartnerFundClaim.saveClaim(claim1, auditDocList,null, null,false, null, false, null, false);
            
            
            //String res = Core_MDF_PartnerFundClaim.saveClaim(claim1, auditDocList); 

            PartnerFundClaim claimins = [select id,Core_MDF_VAT_Eligibility_Ind__c,Core_MDF_Status__c,Core_MDF_Audit_Hold__c from PartnerFundClaim where id =: res.claimDetail.Id limit 1];
            claimins.Core_MDF_Status__c = 'Hold';
            Database.update(claimins);
            
            // Read the VAT Invoice record
            Core_MDF_Claim_VAT_Info__c vatInfo = [select id,Core_MDF_RSMRemNotificationSent_Ind__c, Core_MDF_Status_Txt__c,
                                                  Core_MDF_ClaimSubRemNotificationSent_Ind__c, Core_MDF_Payment_Admin_Reminder_Sent_Ind__c,
                                                  Core_MDF_ClaimSubmitterReminder_Dtm__c, Core_MDF_RSMReminderDate_Dtm__c,
                                                  Core_MDF_Payment_Admin_Reminder_Date_Dtm__c, Core_MDF_VAT_Invoice_Number_Txt__c
                                                  from Core_MDF_Claim_VAT_Info__c where Core_MDF_Claim_Id__c =: claimins.Id limit 1];
            
            //Update VAT Invoice Number and RSM Reminder Notification Sent check box to true
            vatInfo.Core_MDF_VAT_Invoice_Number_Txt__c = 'VATINV001';
            vatInfo.Core_MDF_RSMRemNotificationSent_Ind__c = TRUE;
            Database.update(vatInfo);
            system.assertEquals(Core_MDF_PFC_VAT_ServiceHandler.addBusinessDays(system.today(),5), vatInfo.Core_MDF_RSMReminderDate_Dtm__c,'Update Second Reminder Date');
            
            // Update Status to Revision Required and Claim Submitter Reminder Notification sent to true
            vatInfo.Core_MDF_Status_Txt__c = 'Revision Required';
          	vatInfo.Core_MDF_ClaimSubRemNotificationSent_Ind__c = true;
            try{
                Database.update(vatInfo);
            }catch(Exception e){}               
         	//Database.update(vatInfo);	
           	system.assertEquals(Core_MDF_PFC_VAT_ServiceHandler.addBusinessDays(system.today(),3), vatInfo.Core_MDF_ClaimSubmitterReminder_Dtm__c,'Update First Reminder Date');
          	system.assertEquals(Core_MDF_PFC_VAT_ServiceHandler.addBusinessDays(system.today(),5), vatInfo.Core_MDF_RSMReminderDate_Dtm__c,'Update Second Reminder Date');

            //Create Document
            ContentVersion cv = new ContentVersion();
            cv.Title = 'Test Document';
            cv.PathOnClient = 'TestDocument.pdf';
            cv.VersionData = Blob.valueOf('Test Content');
            cv.IsMajorVersion = true;
            Insert cv;

            //Get Content documents
            List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];

            //create ContentDocumentLink  record 
            ContentDocumentLink cdl = New ContentDocumentLink();
            cdl.LinkedEntityId = vatInfo.Id;
            cdl.ContentDocumentId = documents[0].Id;
            cdl.shareType = 'V';
            insert cdl;
            
            vatInfo.Core_MDF_Status_Txt__c = 'Under Review';
            vatInfo.Core_MDF_Payment_Admin_Reminder_Sent_Ind__c = TRUE;
            try{
            Database.update(vatInfo);
            }catch(Exception ex){
            }
            test.stopTest();
        }
         
     }      
}