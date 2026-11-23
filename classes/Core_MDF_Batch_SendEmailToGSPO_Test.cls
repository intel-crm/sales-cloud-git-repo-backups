/****************************************************************************************************************************************
* Class Name        : Core_MDF_Batch_SendEmailToGSPO_Test
* Created Date      : 13/11/2020
* Modification Log
* Developer            Date               Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Ayesha    13/11/2020        Test Class for Core_MDF_Batch_SendEmailToGSPO
*****************************************************************************************************************************************/
@isTest(SeeAllData=false)
public class Core_MDF_Batch_SendEmailToGSPO_Test {
    @TestSetUp
    static void createTestData() {

        List<PermissionSetAssignment> permissionSetAssignmentList = new  List<PermissionSetAssignment>();
        //Role
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        User testUser = Core_MDF_CCP_TestDataUtility.createUser(true);
        testUser.UserRoleId = usRole.Id;
        update testUser;
        List<User> userList = new List<User>();
        
        
        Profile sysAdminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        
        User usrs = Core_MDF_CCP_TestDataUtility.createUser(false);
        usrs.Email = 'sysadmin@example.com';
        usrs.LastName = 'System Adm';
        usrs.ProfileId = sysAdminProfile.Id;
        usrs.isActive = true;
        database.insert(usrs);
           System.runAs(usrs){
               List<Core_MDF_Configuration__c> configList = new List<Core_MDF_Configuration__c>();
        Core_MDF_Configuration__c config = new Core_MDF_Configuration__c();
        config.Name = 'ALLOWED_PRG_FOR_RUS_NOTIF';
        config.Core_MDF_Value__c = 'Retail Marketing Funds,Intel Partner Alliance';
        configList.add(config);
        database.insert(configList);
               //adding bypass feature to bypass access validation
			List<String> bypassFunctionKeys = new List<String>();
            bypassFunctionKeys.add('Bypass_MDF_Budget_Access_Validation');
            bypassFunctionKeys.add('Bypass_MDF_Budget_Status_Validation');
            
            Set<String> myset1 = new Set<String>();
            List<String> result1 = new List<String>();
            myset1.addAll(bypassFunctionKeys);
            result1.addAll(myset1);
            
            List<Core_Trigger_Executions__c> bypassfunctinalitylist1 = Core_MDF_CCP_TestDataUtility.byPassFeature(result1,true,true);  
               
             Core_MDF_Configuration__c c=new Core_MDF_Configuration__c();
            c.Name='Core_MDF_RecoveryClaimUpdateBatch_Size';
            c.Core_MDF_Value__c='30';
            insert c;

            ChannelProgram retailCP = Core_MDF_CCP_TestDataUtility.createProgram ('Retail Marketing Funds','Retail Marketing Funds', true);
        
            Account retailIntelAcc = Core_MDF_CCP_TestDataUtility.createIntelAccount('Test Retail Intel Account', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
            retailIntelAcc.Core_Geo__c = 'EMEA';
            insert retailIntelAcc;
            
            Account masterAcc = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test Master Account', retailCP.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, retailIntelAcc.Id, false);
            masterAcc.Core_Geo__c = 'EMEA';
            //masterAcc.Core_Sub_Geo__c = 'IJKK';
            insert masterAcc;

            PartnerMarketingBudget retailBudget = Core_MDF_CCP_TestDataUtility.createRetailBudget('TestBudgetData1',Core_MDF_CCP_TestDataUtility.budget_Retail_Record_Type,
                                                 masterAcc.Id,retailCP.Id,1000000,System.today().addDays(1),System.today().addDays(100),false, 'Retail MDF');
                //Core_MDF_CCP_TestDataUtility.createBudget('TestBudgetData1',Core_MDF_CCP_TestDataUtility.budget_Record_Type,
           // masterAcc.id, retailCP.Id , 10000 , System.today()-60 , System.today() + 60 , false);
            //retailBudget.IsIgnoreValidation = true;
            retailBudget.Core_MDF_Budget_Status__c = 'Released';
            insert retailBudget;
            
           
            //retailBudget.IsIgnoreValidation = true;
            //update retailBudget;
            
            //allocation
            PartnerFundAllocation allocation = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('Test Allocation New',retailBudget,masterAcc,200.0,true);
        
                
            Profile ccpCoreAccessProfile = [SELECT Id FROM Profile WHERE Name='CCP - Core Access' LIMIT 1];
            //Profile partnerProfile = [SELECT Id FROM Profile WHERE Name='Partner' limit 1];
            PermissionSet aacntMngrPS = [SELECT Id, Name FROM PermissionSet WHERE Name='Core_MDF_CCP_Internal_Retail_Account_Manager' LIMIT 1];
            //PermissionSet extApprPS = [SELECT Id, Name FROM PermissionSet WHERE Name='Core_MDF_CCP_External_Activity_Approver' LIMIT 1];
            PermissionSet rmfPaymentAdm = [SELECT Id, Name FROM PermissionSet WHERE Name='Core_MDF_CCP_Internal_Retail_Payment_Adm' LIMIT 1];
            PermissionSet emeaUser = [SELECT Id, Name FROM PermissionSet WHERE Name='Core_MDF_CCP_Internal_EMEA_User' LIMIT 1];
            PermissionSet paymentScheduleAdmin = [SELECT Id, Name FROM PermissionSet WHERE Name='Core_MDF_CCP_Internal_Payment_Schedule_Admin' LIMIT 1];
            // Highlight: Unused Local Variable
           // PermissionSet genericPermSet = [SELECT Id, Name FROM PermissionSet WHERE Name='Core_MDF_CCP_Internal_Generic_Access' LIMIT 1];

            
            User ccfaccntmngr = Core_MDF_CCP_TestDataUtility.createUser(false);
            ccfaccntmngr.Email = 'ccfaccntmngr@example.com';
            ccfaccntmngr.Profile = ccpCoreAccessProfile;
            userList.add(ccfaccntmngr);
            //Database.insert(ccfaccntmngr);
            
            User retailPaymentAdmin = Core_MDF_CCP_TestDataUtility.createUser(false);
            retailPaymentAdmin.Email = 'retailpaymentadmin@example.com';
            retailPaymentAdmin.Profile = ccpCoreAccessProfile;
            userList.add(retailPaymentAdmin);
            Database.insert(userList);

            PermissionSetAssignment assignPermissionSetObj = new PermissionSetAssignment();
            assignPermissionSetObj.AssigneeId = ccfaccntmngr.Id;
            assignPermissionSetObj.PermissionSetId = aacntMngrPS.Id;
            //Database.insert(assignPermissionSetObj);
            permissionSetAssignmentList.add(assignPermissionSetObj);
            
            PermissionSetAssignment assignPermissionSetObj1 = new PermissionSetAssignment();
            assignPermissionSetObj1.AssigneeId = retailPaymentAdmin.Id;
            assignPermissionSetObj1.PermissionSetId = rmfPaymentAdm.Id;
            //Database.insert(assignPermissionSetObj1);
            permissionSetAssignmentList.add(assignPermissionSetObj1);

            PermissionSetAssignment assignPermissionSetObj2 = new PermissionSetAssignment();
            assignPermissionSetObj2.AssigneeId = retailPaymentAdmin.Id;
            assignPermissionSetObj2.PermissionSetId = emeaUser.Id;
           // Database.insert(assignPermissionSetObj2);
            permissionSetAssignmentList.add(assignPermissionSetObj2);
            
            PermissionSetAssignment assignPermissionSetObj3 = new PermissionSetAssignment();
            assignPermissionSetObj3.AssigneeId = retailPaymentAdmin.Id;
            assignPermissionSetObj3.PermissionSetId = paymentScheduleAdmin.Id;
            //Database.insert(assignPermissionSetObj1);
            permissionSetAssignmentList.add(assignPermissionSetObj3);
            
            /* PermissionSetAssignment assignPermissionSetObj4 = new PermissionSetAssignment();
            assignPermissionSetObj4.AssigneeId = retailPaymentAdmin.Id;
            assignPermissionSetObj4.PermissionSetId = genericPermSet.Id;
            //Database.insert(assignPermissionSetObj1);
            permissionSetAssignmentList.add(assignPermissionSetObj4);*/
             Database.insert(permissionSetAssignmentList);

            Campaign retailCampaign = Core_MDF_CCP_TestDataUtility.createCampaign('Test Retail Camp 1','Business','Intel® 10ᵗʰ Gen', 'Yes', 
                                                                     Core_MDF_CCP_TestDataUtility.campaign_RecordType_Retail, 
                                                                     'Retail_Marketing_Funds', System.today(),
                                                                     System.today()+300, 10000, 'Instore merchandise', 
                                                                     masterAcc.Id,'All-in-One Desktop', false);
        
            retailCampaign.RecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Core_MDF_Retail_Marketing_Funds').getRecordTypeId();
            retailCampaign.Core_MDF_Activity_Category_Type__c =null;
            retailCampaign.Core_MDF_Program__c = 'Retail Marketing Funds';
            retailCampaign.Core_MDF_Reimbursement_Rate__c='100%';
            retailCampaign.Core_MDF_Technology__c = 'Wifi6';
            //retailCampaign.Core_MDF_Budget_Type_txt__c ='RSA MD';
            retailCampaign.Core_MDF_Opal_Budget_Type_Txt__c='Retail MDF';
            insert retailCampaign;
            // Highlight: Unused Local Variable
           // List<Core_MDF_Bank__c> listBank = new List<Core_MDF_Bank__c>();            
            
            Core_MDF_Bank__c bank = Core_MDF_CCP_TestDataUtility.createBank(retailIntelAcc.Id, 'Core_MDF_Retail_Marketing_Funds', false,'1231231230');
            bank.Core_MDF_Bank_Alias_Name__c='Test';
            bank.Core_MDF_Bank_Status__c ='Active';  
            bank.Core_MDF_Intel_Company_Code__c = '420';     
            bank.Core_MDF_Tax_codes_cd__c = 'UB';   
            bank.Core_MDF_VAT_pct__c ='10';
            Database.insert(bank);        
            
            //Do Account Bank Mapping for 'bank' and ABM is applicaple only for "Retail MDF" record type
            // Highlight: Unused Local Variable
           // Core_MDF_Account_Bank_Mapping__c abm1 = Core_MDF_CCP_TestDataUtility.createAccountBankMap(masterAcc.Id,bank.Id,true);
               
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
            
            
            Core_MDF_CCP_TestDataUtility.createPartnerGroupMapping(retailIntelAcc.Id,'Internal',retailIntelAcc.Id,retailCP.Id,'PGM_Retail_TEST',true);
               Core_Trigger_Executions__c setting = new Core_Trigger_Executions__c();
               setting.Core_Active__c = false;
               setting.Core_Class_Name__c = 'Core_MDF_AdjustmentClaimOffsetProcess';
               setting.Core_Description__c = 'Demo Description';
               setting.Core_Object__c = 'Core_MDF_Payment_Run__c';
               setting.Core_Trigger_Events__c = 'after insert';
               setting.name = 'Core_MDF_AdjustmentClaimOffsetProcess';
               insert setting;
        }

        User usr = [select id,email from User where email='ccfaccntmngr@example.com' limit 1];

        PartnerFundRequest pfr = new PartnerFundRequest();
        Test.startTest(); 
        System.runAs(usr){
            Campaign camp = [select id,Name from Campaign WHERE Name = 'Test Retail Camp 1' LIMIT 1];
            PartnerFundAllocation pfa=[select id from PartnerFundAllocation where Title='Test Allocation New'];
            PartnerMarketingBudget pmb=[select id from PartnerMarketingBudget where Title='TestBudgetData1'];
            Account accCoMarketing = [select id from Account WHERE Name = 'Test Master Account'];
            //pfr = Core_MDF_CCP_TestDataUtility.insertPartnerFundRequest(string.valueof(camp.id),Core_MDF_CCP_TestDataUtility.partnerFund_RecordType_Retail,string.valueof(accCoMarketing.id),null,null,'UNITED KINGDOM','Business','All-in-One Desktop','Intel® 10ᵗʰ Gen','Broadcast','Podcast','Draft',false);
            pfr = Core_MDF_CCP_TestDataUtility.insertPartnerFundRequest(string.valueof(camp.id),Core_MDF_CCP_TestDataUtility.partnerFund_RecordType_Retail,string.valueof(accCoMarketing.id),pfa,pmb,'UNITED KINGDOM','Business','All-in-One Desktop','Intel® 10ᵗʰ Gen','Audio','Podcast','Draft',false);
            //pfr.Core_MDF_Fund_Request_Status__c = 'Pending Review';
            pfr.Status = 'Approved';
            pfr.Core_MDF_Fund_Request_Status__c='Planned';
            pfr.Title = 'Test Retail Activity';
            pfr.Core_MDF_Activity_Description__c = 'Test Retail Activity';
            pfr.Core_MDF_Budget_Type_nm__c ='Retail MDF';
            pfr.Core_MDF_Channel_Partner_Led__c = false;
            pfr.Core_MDF_Budget_Amount_Local_amt__c=100;
            pfr.Core_MDF_Budget_Currency_cd__c='USD';
            pfr.Core_MDF_Estimated_Ad_Size_nbr__c=5;
            pfr.Core_MDF_Magazine_Newspaper_txt__c='Magazine';
            pfr.Core_MDF_Start_Date__c = System.today();
            pfr.Core_MDF_End_Date__c = System.today();
            pfr.Core_MDF_Reimbursement_Rate_pct__c='100%';  
            pfr.Core_MDF_Reimbursement_Rate_txt__c='100%';
            //pfr.Core_MDF_Budget_Type_txt__c = 'Retail MDF';
            pfr.AllocationId=pfa.id;
            insert pfr;
        }
        Test.stopTest();        
    }
     @isTest
    static void testNotificationToGSPO()
    {
        User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' and LastName = 'System Adm' limit 1];
        User rmfPaymentAdmin = [SELECT Id,Email from User where Email='retailpaymentadmin@example.com' limit 1];
        PartnerFundClaim claimins;
        Core_MDF_Claim_VAT_Info__c vatInfo;
        System.runAs(sysAdminUser)
        {
            test.startTest();

            Core_MDF_Bank__c bank1 = [Select Id from Core_MDF_Bank__c where Core_MDF_Bank_Alias_Name__c='Test' limit 1];
            PartnerFundRequest pfr = [Select Id,Title,Core_MDF_Reimbursement_Rate__c from PartnerFundRequest where Title = 'Test Retail Activity'];
        /*    PartnerFundClaim claim1 = Core_MDF_CCP_TestDataUtility.createClaim('Test Retail Claim', Core_MDF_CCP_TestDataUtility.claim_RecordType_Retail, pfr.Id, System.today(), System.today(), 50.00, System.today(), bank1.Id, false);
            claim1.Core_MDF_Type_Txt__c ='Claim';
            claim1.Core_MDF_Currency__c='USD';
            claim1.Core_MDF_Country_Location_nm__c= 'UNITED KINGDOM'; 
            claim1.Core_MDF_VAT_Eligibility_Ind__c= true ; 
            claim1.Core_MDF_VAT_Hold_Ind__c = true;
            claim1.Core_MDF_Status__c = 'Hold';
            database.insert(claim1); */
            
              //PartnerFundClaim claim1 = Core_MDF_CCP_TestDataUtility.createClaim('Test Retail Claim', Core_MDF_CCP_TestDataUtility.claim_RecordType_Retail, pfr.Id, System.today()+10, System.today()+100, 50.00, System.today(), bank1.Id, false);
              PartnerFundClaim claim1 = Core_MDF_CCP_TestDataUtility.createClaim('Test Retail Claim', Core_MDF_CCP_TestDataUtility.claim_RecordType_Retail, pfr.Id, System.today(), System.today(), 50.00, System.today(), bank1.Id, false);
             claim1.Core_MDF_Type_Txt__c ='Claim';
              claim1.Core_MDF_Currency__c='USD';
            claim1.Core_MDF_VAT_Opt_In__c='';
            claim1.Core_MDF_Country_Location_nm__c= 'UNITED KINGDOM'; 
            claim1.Core_MDF_VAT_Eligibility_Ind__c= true ; 
            claim1.Core_MDF_VAT_Hold_Ind__c = true;
            claim1.Core_MDF_Status__c = 'Hold';
            //claim1.Core_MDF_Status__c = 'Submitted';
            PartnerFundClaim superClaim = claim1.clone(false, false, false, false);
            superClaim.Title = 'Test Retail Super Claim';
            superClaim.Core_MDF_Has_Sub_Claims_Ind__c = true;
            superClaim.Core_MDF_VAT_Eligibility_Ind__c = false;
            insert superClaim;
            claim1.Core_MDF_Claim_Id__c = superClaim.Id;
            insert claim1;
            list<Core_MDF_Audit_Document__c> auditDocList = new list<Core_MDF_Audit_Document__c>();
            //Core_MDF_PartnerFundClaim.ClaimWrap claimWrapResult = Core_MDF_PartnerFundClaim.saveClaim(claim1, auditDocList, null);  
            //String res = claimWrapResult.claimDetail.Id;
           List<String> documentIdWithTitle = new List<String>();
        list<String> tempString = new list<String>();
       // list<Core_MDF_Audit_Document__c> auditDocList = new list<Core_MDF_Audit_Document__c>();
        
        String str1 = claim1.Id+';#'+'Test Doc1';
       // Highlight: Unused Local Variable
       // String str2 = claim1.Id+';#'+'Test Doc2';
        
        documentIdWithTitle.add(str1);
        //documentIdWithTitle.add(str2);
        
        for(String str: documentIdWithTitle){
            tempString = str.split(';#');
            Core_MDF_Audit_Document__c auditDoc = new Core_MDF_Audit_Document__c();
            auditDoc.Core_MDF_Document_Id__c = tempString[0];
            auditDoc.Core_MDF_Document_Title__c = tempString[1];
            auditDoc.Core_MDF_Claim__c = claim1.Id;
            auditDoc.Core_MDF_Proof_of_Branding__c = true;
            auditDoc.Core_MDF_Proof_of_Cost__c = true;
            auditDoc.Core_MDF_Proof_of_Execution__c = true;   
            auditDoc.Core_MDF_App_Document_Types_nm__c= 'Proof of Cost;Proof of Execution;Proof of Attribution';
            auditDoc.Core_MDF_Document_Types__c = 'Proof of Cost;Proof of Execution;Proof of Attribution';
            auditDocList.add(auditDoc);
        }            
        
        if(auditDocList.size()>0){
            Database.insert(auditDocList);                
        }
             /*List<ContentVersion> conVersionLst1 = new List<ContentVersion>();
            ContentVersion conVersion1 = new ContentVersion();
            conVersion1.ContentLocation = 'S';
            conVersion1.Title = 'Test1';
            conVersion1.PathOnClient='Test1';
            conVersion1.ReasonForChange = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_ContentVersion_ReasonForChange');
            conVersion1.VersionData = Blob.valueOf('content1');
            conVersionLst1.add(conVersion1);
            Database.insert(conVersionLst1); //Insert contentversion list
            ContentVersion contentVersions1 = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id IN : conVersionLst1 limit 1];
            
            ContentDocument conDoc1= [SELECT Id,OwnerId FROM ContentDocument WHERE Id =:contentVersions1.ContentDocumentId limit 1];
            Core_MDF_Audit_Document__c auditDoc1 = new Core_MDF_Audit_Document__c(); 
            auditDoc1.Core_MDF_Document_Id__c = conDoc1.Id;
            auditDoc1.Core_MDF_Document_Title__c = 'Test';
            auditDoc1.Core_MDF_Claim__c = claim1.Id;
            auditDoc1.Core_MDF_Document_Types__c='Proof of Cost;Proof of Execution;Proof of Attribution';
            auditDoc1.Core_MDF_App_Document_Types_nm__c= 'Proof of Cost;Proof of Execution;Proof of Attribution';
            insert auditDoc1;
            auditDocList.add(auditDoc1);*/
            //Core_MDF_PartnerFundClaim.saveClaim(claim1, auditDocList,null);   

           /* PartnerFundClaim claimins = [select id,Core_MDF_VAT_Eligibility_Ind__c,Core_MDF_Status__c,Core_MDF_Audit_Hold__c from PartnerFundClaim where id =: claim1.Id limit 1];
            claimins.Core_MDF_Status__c = 'Hold';
            claimins.Core_MDF_VAT_Hold_Ind__c = true;
            Database.update(claimins); */
            
             
            Core_MDF_Claim_VAT_Info__c newVatRec = new Core_MDF_Claim_VAT_Info__c();
            newVatRec.Core_MDF_Claim_Id__c = superClaim.Id;
            newVatRec.Core_MDF_Sub_Claim_Id__c = claim1.Id;
            insert newVatRec;

            claimins = [select id,Core_MDF_VAT_Eligibility_Ind__c,Core_MDF_Status__c,Core_MDF_Audit_Hold__c from PartnerFundClaim where id =: claim1.Id limit 1];
            claimins.Core_MDF_Status__c = 'Hold';
            Database.update(claimins);
             
            //Create Document
            ContentVersion cv = new ContentVersion();
            cv.Title = 'Test Document';
            cv.PathOnClient = 'TestDocument.pdf';
            cv.VersionData = Blob.valueOf('Test Content');
            cv.IsMajorVersion = true;
            Insert cv;
            
            //Get Content documents
            List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];

            // Read the VAT Invoice record
            vatInfo = [select id from Core_MDF_Claim_VAT_Info__c where Core_MDF_Sub_Claim_Id__c =: claimins.id  limit 1];
            
            vatInfo.Core_MDF_VAT_Invoice_Number_Txt__c = 'VATINV001';
            vatInfo.Core_MDF_Approved_File_Id__c = documents[0].Id;
            Database.update(vatInfo);
           
            //create ContentDocumentLink  record 
            ContentDocumentLink cdl = New ContentDocumentLink();
            cdl.LinkedEntityId = vatInfo.Id;
            cdl.ContentDocumentId = documents[0].Id;
            cdl.shareType = 'V';
            insert cdl;
            
            claimins.Core_MDF_Status__c = 'Payment Due';
            claimins.Core_MDF_VAT_Hold_Ind__c = false;
            Database.update(claimins);
            test.stopTest();
        }
         System.runAs(rmfPaymentAdmin)
            {
                ChannelProgram cp = [SELECT ID From ChannelProgram where Name = 'Retail Marketing Funds'];
                PartnerFundClaim claim1 = [select id,Core_MDF_Status__c,Core_MDF_Audit_Hold__c,Core_MDF_Payment_Id__r.Core_MDF_Payment_Run_Id__c,Core_MDF_VAT_Eligibility_Ind__c from PartnerFundClaim where Title='Test Retail Claim' limit 1];
                Id payRun_RecordType_RMF = Schema.SObjectType.Core_MDF_Payment_Run__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_Retail_Marketing_Funds').getRecordTypeId();
                Core_MDF_Payment_Run__c payRunRecord = new Core_MDF_Payment_Run__c();
                payRunRecord.RecordTypeId = payRun_RecordType_RMF;
                payRunRecord.Core_MDF_Run_Now_Ind__c = true ;
                payRunRecord.Core_MDF_Geo_Txt__c = 'EMEA';
                payRunRecord.Core_MDF_Program_Id__c  = cp.Id;
                payRunRecord.Core_MDF_Budget_Type_nm__c = 'Retail MDF';
                payRunRecord.Core_MDF_Start_Dt__c = System.today().addDays(-5);
                payRunRecord.Core_MDF_End_Dt__c = System.today().addDays(5);
                //payRunRecord.Core_MDF_Send_Notification_Ind__c = true ;
                payRunRecord.Core_MDF_Status_Txt__c = 'Completed';
                Database.insert(payRunRecord);
                //payRunRecord.Core_MDF_GSPO_Notification_Sent_On_Dtm__c = System.now();
                
                 Core_MDF_Payment__c newPayment = new Core_MDF_Payment__c();
                newPayment.Core_MDF_Payment_Status_Txt__c = 'Pending Payment';
                newPayment.Core_MDF_Payment_Run_Id__c = payRunRecord.Id;
                insert newPayment;
                
                claim1.Core_MDF_Status__c = 'Pending Payment';
                claim1.Core_MDF_Payment_Id__c = newPayment.Id;
                update claim1;
                //update payRunRecord;
                
                List<Id> listOfPaymentRun = new List<Id>();
                listOfPaymentRun.add(payRunRecord.Id);
                Core_MDF_EmailToGSPO.callBatchToSendEmailToGSPO(listOfPaymentRun);
                Core_MDF_VatUtility.getCountOfVatClaimRecords(listOfPaymentRun);
                
                
            }
         System.runAs(sysAdminUser){
             
            PartnerFundClaim claim1 = [select id,Core_MDF_Status__c,Core_MDF_Audit_Hold__c,Core_MDF_Payment_Id__r.Core_MDF_Payment_Run_Id__c,Core_MDF_VAT_Eligibility_Ind__c from PartnerFundClaim where Title='Test Retail Claim' limit 1];
           
            
           List<PartnerFundClaim> listOfClaim = new  List<PartnerFundClaim>();
            listOfClaim.add(claim1);
            Core_MDF_Batch_SendEmailToGSPO sendNotification = new Core_MDF_Batch_SendEmailToGSPO(listOfClaim);
                        Database.QueryLocatorIterator vatInfoIterator = sendNotification.start(null).iterator();
                        System.assert(vatInfoIterator.hasNext(), 'Sub-Claim VAT information should be included in the GSPO notification batch');
                        Core_MDF_Claim_VAT_Info__c selectedVatInfo = (Core_MDF_Claim_VAT_Info__c) vatInfoIterator.next();
                        System.assertEquals(vatInfo.Id, selectedVatInfo.Id, 'The batch should select VAT information linked through the Sub-Claim lookup');
             // Highlight: Unused Local Variable - Indira
           /* Id batchId = */  Database.executeBatch(sendNotification);
            // Unit Test Method should include System.Assert - Indira
            System.assertEquals(1, listOfClaim.size(), 'Claim list should have one entry');
        }
        
    }
   
}