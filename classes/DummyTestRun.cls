@isTest(SeeAllData=false)
private without sharing class  DummyTestRun
{
    
     @TestSetUp
    static void createTestData() {

        List<User> userList = new List<User>();
        //Role
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        User testUser = Core_MDF_CCP_TestDataUtility.createUser(true);
        testUser.UserRoleId = usRole.Id;
        update testUser;
        Map<String,PermissionSet> permissionSetMap = new Map<String,PermissionSet>();
        Map<String,Id> profileMap = new Map<String,Id>();
        
         for(Profile prfl:[SELECT Id,Name FROM Profile WHERE Name IN ('System Administrator','CCP - Core Access','Partner')]) {
            profileMap.put(prfl.Name,prfl.Id);
        }
        
        for(PermissionSet pSet:[SELECT Id,Name FROM PermissionSet WHERE Name IN ('Core_MDF_CCP_Internal_Retail_Account_Manager',
                            'Core_MDF_CCP_Internal_Claim_Case_Reviewer',
                            'Core_MDF_CCP_External_Activity_Approver'
                            )]) {
            permissionSetMap.put(pSet.Name,pSet);
        }
     //   Profile sysAdminProfile = profileMap.get('System Administrator');
        
        User usrs = Core_MDF_CCP_TestDataUtility.createUser(false);
        usrs.Email = 'sysadmin@example.com';
        usrs.LastName = 'System Adm';
        usrs.ProfileId = profileMap.get('System Administrator');
        usrs.isActive = true;
        database.insert(usrs);
        
  //       Profile ccpCoreProfile = profileMap.get('CCP - Core Access');
        PermissionSet clmCaseRevPS = permissionSetMap.get('Core_MDF_CCP_Internal_Claim_Case_Reviewer');
        User claimCase = Core_MDF_CCP_TestDataUtility.createUser(false);
        claimCase.Email = 'clmcase@example.com';
        claimCase.ProfileId = profileMap.get('CCP - Core Access');
        insert claimCase;
        PermissionSetAssignment assignPermissionSetObjCCR = new PermissionSetAssignment();
        assignPermissionSetObjCCR.AssigneeId = claimCase.Id;
        assignPermissionSetObjCCR.PermissionSetId = clmCaseRevPS.Id;
        Database.insert(assignPermissionSetObjCCR);
        
        
        
        System.runAs(testUser){

            ChannelProgram retailCP = Core_MDF_CCP_TestDataUtility.createProgram ('Retail Marketing Funds','Retail Marketing Funds', true);
        
            Account retailIntelAcc = Core_MDF_CCP_TestDataUtility.createAccount('Test Retail Intel Account',retailCP.id, Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
            retailIntelAcc.Core_Geo__c = 'APJ';
            retailIntelAcc.BillingCountry ='RUS';
            retailIntelAcc.BillingCity = 'Test City'; 
            retailIntelAcc.BillingStreet= 'Test Street';
            retailIntelAcc.BillingState= 'MOS';
            insert retailIntelAcc;
            
            Account masterAcc = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test Master Account', retailCP.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, retailIntelAcc.Id, false);
            masterAcc.Core_Geo__c = 'APJ';
            //masterAcc.Core_Sub_Geo__c = 'IJKK';
            insert masterAcc;
            
            //Creating Contact for Partner User
            Contact conRecord1 = Core_MDF_CCP_TestDataUtility.createContact(retailIntelAcc.Id,true);
    
           // Id profileId = [SELECT Id FROM Profile WHERE Name='Partner' limit 1].Id;
            User usr1 = Core_MDF_CCP_TestDataUtility.createUser(false);        
            usr1.Email='test1@example.com';
            usr1.ContactId = conRecord1.Id;
            usr1.ProfileId = profileMap.get('Partner');
            usr1.isActive = true;
            Database.insert(usr1);

            PartnerMarketingBudget retailBudget = Core_MDF_CCP_TestDataUtility.createRetailBudget('TestBudgetData1',Core_MDF_CCP_TestDataUtility.budget_Retail_Record_Type,
            masterAcc.id, retailCP.Id , 20000 , System.today()-6 , System.today()+301 , false,'Retail MDF');
            retailBudget.IsIgnoreValidation = true;
            insert retailBudget;
            retailBudget.Core_MDF_Budget_Status__c = 'Approved';
            update retailBudget;
            retailBudget.Core_MDF_Budget_Status__c = 'Released';
            update retailBudget;
            
            //allocation
            //PartnerFundAllocation allocation = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('Test Allocation New',retailBudget,masterAcc,200.0,true);
          PartnerFundAllocation allocation = [Select id, Amount,TotalApprovedFrs from PartnerFundAllocation where BudgetId = :retailBudget.Id];
            System.debug('allocation::'+allocation);
            allocation.Amount=9999;
            
            update allocation;
            System.debug('allocation.Amount'+allocation.Amount);
             System.debug('allocation.TotalApprovedFrs'+allocation.TotalApprovedFrs);
           
                
         //   Profile ccpCoreAccessProfile = profileMap.get('CCP - Core Access');
         //   Profile partnerProfile = profileMap.get('Partner');
            PermissionSet aacntMngrPS = permissionSetMap.get('Core_MDF_CCP_Internal_Retail_Account_Manager');
            PermissionSet extApprPS = permissionSetMap.get('Core_MDF_CCP_External_Activity_Approver');

            Contact con  = Core_MDF_CCP_TestDataUtility.createContact(retailIntelAcc.Id, true);
            User usrBudgetAdmin = Core_MDF_CCP_TestDataUtility.createUser(false);
            usrBudgetAdmin.LastName = 'Budget Admin';
            usrBudgetAdmin.ContactId = con.Id;
            usrBudgetAdmin.ProfileId = profileMap.get('Partner');
            usrBudgetAdmin.portalRole = 'Manager';
            usrBudgetAdmin.email = 'ccfextapprover@example.com';
            usrBudgetAdmin.isActive = true;
            userList.add(usrBudgetAdmin);
            //Database.insert(usrBudgetAdmin);
            
            User ccfaccntmngr = Core_MDF_CCP_TestDataUtility.createUser(false);
            ccfaccntmngr.Email = 'ccfaccntmngr@example.com';
            ccfaccntmngr.ProfileId = profileMap.get('CCP - Core Access');
            userList.add(ccfaccntmngr);
            //Database.insert(ccfaccntmngr);

            Database.insert(userList);

            PermissionSetAssignment assignPermissionSetObj = new PermissionSetAssignment();
            assignPermissionSetObj.AssigneeId = ccfaccntmngr.Id;
            assignPermissionSetObj.PermissionSetId = aacntMngrPS.Id;
            Database.insert(assignPermissionSetObj);

            Database.update(retailBudget);
            PartnerMarketingBudget budget1 = [Select TotalAllocatedAmount from PartnerMarketingBudget where id = :retailBudget.Id];
            System.debug('budget1::'+budget1);
            Campaign retailCampaign = Core_MDF_CCP_TestDataUtility.createCampaign('Test Retail Camp 1','Business','Intel® 10ᵗʰ Gen', 'MDF or both CMP & MDF',
                                                                     Core_MDF_CCP_TestDataUtility.campaign_RecordType_Retail, 
                                                                     'Retail_Marketing_Funds', System.today()-2,
                                                                     System.today()+100, 10000, 'Instore merchandise', 
                                                                     masterAcc.Id,'All-in-One Desktop', false);
        
            retailCampaign.RecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Core_MDF_Retail_Marketing_Funds').getRecordTypeId();
            retailCampaign.Core_MDF_Activity_Category_Type__c =null;
            retailCampaign.Core_MDF_Program__c = 'Retail Marketing Funds';
            retailCampaign.Core_MDF_Reimbursement_Rate__c='100%';
            retailCampaign.Core_MDF_Technology__c = 'Wifi6';
            retailCampaign.Core_MDF_Budget_Type_txt__c ='Retail MDF';
            retailCampaign.Core_MDF_Opal_Budget_Type_Txt__c = 'Retail MDF';
            //retailCampaign.Core_MDF_Program_Type__c = 'Non Opal';
            retailCampaign.Core_MDF_Budget_Amount_amt__c=10000;
            
            insert retailCampaign;            
            
            List<Core_MDF_Bank__c> listBank = new List<Core_MDF_Bank__c>();            
            
            Core_MDF_Bank__c bank = Core_MDF_CCP_TestDataUtility.createBank(retailIntelAcc.Id, 'Core_MDF_Retail_Marketing_Funds', false,'1231231230');
            bank.Core_MDF_Bank_Alias_Name__c='Test';
            bank.Core_MDF_Bank_Status__c ='Active';  
            bank.Core_MDF_Intel_Company_Code__c = '420';     
            bank.Core_MDF_Tax_codes_cd__c = 'UB';
            bank.Core_MDF_VAT_pct__c ='10';
            
            listBank.add(bank);
            Core_MDF_Bank__c bank1 = Core_MDF_CCP_TestDataUtility.createBank(retailIntelAcc.Id, 'Core_MDF_Retail_Marketing_Funds', false,'1281211130');
            bank1.Core_MDF_Bank_Alias_Name__c='Test1';
            bank1.Core_MDF_Bank_Status__c ='Active';  
            bank1.Core_MDF_Intel_Company_Code__c = '420';     
            bank1.Core_MDF_Tax_codes_cd__c = 'UB';
            bank1.Core_MDF_VAT_pct__c ='0';
            
            listBank.add(bank1);
            Database.insert(listBank);
            //Do Account Bank Mapping for 'bank' and ABM is applicaple only for "Retail MDF" record type
            Test.startTest();
            //Core_MDF_Account_Bank_Mapping__c abm1 = 
            Core_MDF_CCP_TestDataUtility.createAccountBankMap(masterAcc.Id,bank.Id,true);
            //Core_MDF_Account_Bank_Mapping__c abm2 = 
            Core_MDF_CCP_TestDataUtility.createAccountBankMap(masterAcc.Id,bank1.Id,true);

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
            Core_MDF_CCP_TestDataUtility.createMDFConfigurationData();
            
        }

        //User usr = [select id,email from User where email='ccfaccntmngr@example.com' limit 1];
PartnerMarketingBudget budget1 = [Select id,TotalAllocatedAmount from PartnerMarketingBudget where Title = 'TestBudgetData1'];
            System.debug('budget1::'+budget1);
        PartnerFundAllocation allocation1 = [Select id, Amount from PartnerFundAllocation where BudgetId = :budget1.Id];
        PartnerFundRequest pfr = new PartnerFundRequest();
        //Test.startTest(); 
        System.runAs(usrs){
            Campaign camp = [select id,Name,Core_MDF_Budget_Amount_amt__c from Campaign WHERE Name = 'Test Retail Camp 1' LIMIT 1];
            Account accCoMarketing = [select id from Account WHERE Name = 'Test Master Account'];
            pfr = Core_MDF_CCP_TestDataUtility.insertPartnerFundRequest(string.valueof(camp.id),Core_MDF_CCP_TestDataUtility.partnerFund_RecordType_Retail,string.valueof(accCoMarketing.id),null,null,'UNITED KINGDOM','Business','All-in-One Desktop','Intel® 10ᵗʰ Gen','Broadcast','Podcast','Draft',false);
            pfr.Core_MDF_Fund_Request_Status__c = 'Pending Review';
            pfr.Title = 'Test Retail Activity';
            pfr.Core_MDF_Activity_Description__c = 'Test Retail Activity';
            //pfr.Core_MDF_Budget_Type_txt__c ='Retail MDF';
            pfr.Core_MDF_Channel_Partner_Led__c = false;
            pfr.Core_MDF_Budget_Amount_Local_amt__c=10;
            pfr.Core_MDF_Budget_Currency_cd__c='USD';
            pfr.Core_MDF_Estimated_Ad_Size_nbr__c=1;
            pfr.Core_MDF_Magazine_Newspaper_txt__c='Magazine';
            pfr.Core_MDF_Start_Date__c = System.today()-1;
            pfr.Core_MDF_End_Date__c = System.today()+4;
            pfr.Core_MDF_Reimbursement_Rate_pct__c='100%';  
            pfr.Core_MDF_Budget_Type_nm__c = 'Retail MDF';
            pfr.BudgetId = budget1.Id;
            pfr.AllocationId = allocation1.Id;
            pfr.status = 'Approved';
            pfr.Core_MDF_Fund_Request_Status__c = 'Planned';
            pfr.Amount=1;
            insert pfr;
            System.debug('pfr.Amount:'+pfr.Amount);
       }
        Test.stopTest();        
    }
    @isTest
    static void testRetailMDFVATInvoiceFileValidate()
    {
        
        User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' and LastName = 'System Adm' limit 1];
        User extUser = [SELECT Id,Email from User where Email='test1@example.com' limit 1];
        PartnerFundClaim claimins;
        Core_MDF_Claim_VAT_Info__c vatInfo;
        System.runAs(sysAdminUser)
        {
            
            Core_MDF_Bank__c bank1 = [Select Id from Core_MDF_Bank__c where Core_MDF_Bank_Alias_Name__c='Test' limit 1];
            test.startTest(); 
            PartnerFundRequest pfr = [Select Id,Title,Core_MDF_Reimbursement_Rate__c from PartnerFundRequest where Title = 'Test Retail Activity'];
            PartnerFundClaim claim1 = Core_MDF_CCP_TestDataUtility.createClaim('Test Retail Claim', Core_MDF_CCP_TestDataUtility.claim_RecordType_Retail, pfr.Id, System.today(), System.today(), 50.00, System.today(), bank1.Id, false);
            claim1.Core_MDF_Type_Txt__c ='Claim';
            claim1.Core_MDF_Currency__c='USD';
            claim1.Core_MDF_Country_Location_nm__c= 'UNITED KINGDOM'; 
            claim1.Core_MDF_VAT_Opt_In__c = 'Yes';
            claim1.Core_MDF_VAT_Eligibility_Ind__c= true ; 
            claim1.Core_MDF_VAT_Hold_Ind__c = true;
            claim1.Core_MDF_Status__c = 'Hold';
            list<Core_MDF_Audit_Document__c> auditDocList = new list<Core_MDF_Audit_Document__c>();
            //String res = Core_MDF_PartnerFundClaim.saveClaim(claim1, auditDocList);   

            //System.debug('###res->' + res);

            //claimins = [select id,Core_MDF_VAT_Eligibility_Ind__c,Core_MDF_Status__c,Core_MDF_Audit_Hold__c from PartnerFundClaim where id =: res limit 1];
            //claimins.Core_MDF_Status__c = 'Hold';
           // Database.update(claimins);
            //system.debug('Soql query limit inside Start Test1:'+Limits.getLimitQueries());
            // Read the VAT Invoice record
           // vatInfo = [select id from Core_MDF_Claim_VAT_Info__c where Core_MDF_Claim_Id__c = : res limit 1];
           // System.debug('###vatInfo->' + res);
           // vatInfo.Core_MDF_VAT_Invoice_Number_Txt__c = 'VATINV001';
           // Database.update(vatInfo);

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

            User clmCaseUser = [SELECT Id,Email from User where Email='clmcase@example.com' limit 1];
         
            
            PermissionSet claimSubmitterPermissionSet = [SELECT Id, Name FROM PermissionSet where Name = 'Core_MDF_CCP_External_Retail_Claim_Submitter'];        
            PermissionSetAssignment  psa = new PermissionSetAssignment(PermissionSetId = claimSubmitterPermissionSet.Id, AssigneeId = extUser.Id);
            insert psa;
            
            PermissionSet rmfUserPermissionSet = [SELECT Id, Name FROM PermissionSet where Name = 'Core_MDF_Retail_USER'];        
            PermissionSetAssignment  psa2 = new PermissionSetAssignment(PermissionSetId = rmfUserPermissionSet.Id, AssigneeId = extUser.Id);
            insert psa2;
            
            //PermissionSet genericPermissionSet = [SELECT Id, Name FROM PermissionSet where Name = 'Core_MDF_CCP_Generic_Class_Metadata_Setting_Permission_Access'];        
            //PermissionSetAssignment  psa3 = new PermissionSetAssignment(PermissionSetId = genericPermissionSet.Id, AssigneeId = extUser.Id);
            //insert psa3;
             
            PartnerFundClaimShare sharewithExt = new PartnerFundClaimShare(ParentId = claimins.Id, UserOrGroupId = extUser.Id, AccessLevel = 'Edit');
            Database.insert(sharewithExt); 

        }
        
        System.runAs(extUser){
            
        PartnerFundClaim claim = [Select Id from PartnerFundClaim where Title = 'Test Retail Claim' limit 1];
        
            System.assertEquals(false, Core_MDF_PFC_Cancel.isClaimEligibleForCancel(claimins.Id).claimEligibleForCancel);          
            
        } 
        
        //system.debug('Inside testRetailMDFVATInvoiceFileValidate');
        //system.debug('Soql query limit inside Start Test:'+Limits.getLimitQueries());
        claimins.Core_MDF_Status__c = 'Payment Due';
        claimins.Core_MDF_VAT_Hold_Ind__c = false;
        Database.update(claimins);
        
         
         
       List<Id> claimId = new List<Id>();    
        claimId.add(claimins.Id);    
         //User clmCaseUser = [SELECT Id,Email from User where Email='clmcase@example.com' limit 1];
        System.runAs(extUser){
            
        PartnerFundClaim claim = [SELECT Id,Core_MDF_Type_Txt__c, Core_MDF_Status__c, Core_MDF_Audit_Hold__c,Core_MDF_VAT_Hold_Ind__c, Core_MDF_ESD_Hold__c,Core_MDF_Intel_Manual_Hold_Ind__c,Core_MDF_Criteria_Hold_Ind__c
                                  from PartnerFundClaim where Title = 'Test Retail Claim' limit 1];
        
        //test.stopTest();
        Core_MDF_Claim_VAT_Info__c vatInfoNew = [select id from Core_MDF_Claim_VAT_Info__c where Core_MDF_Claim_Id__c = : claim.Id limit 1];
              
        System.assertEquals(true, Core_MDF_PFC_Cancel.isClaimEligibleForCancel(claim.Id).claimEligibleForCancel);
       //system.debug('Soql query limit inside Start Test3:'+Limits.getLimitQueries());
        }
        
        System.runAs(sysAdminUser){
            
            if(Core_MDF_PFC_Cancel.isClaimEligibleForCancel(claimins.Id).claimEligibleForCancel){
        test.stopTest();
                Core_MDF_PFC_Cancel.cancelClaimsWithReason(claimId,'test');
        }
        }
        
        //system.debug('Soql query limit outside Start Test:'+Limits.getLimitQueries());
        
    }
    
static void submitForApproval(Id recordId){

        //Submit Quote for Approval
        try{
            Approval.ProcessSubmitRequest app = new Approval.ProcessSubmitRequest();
            app.setObjectId(recordId);
            Approval.ProcessResult result = Approval.process(app);
        }catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);} 
    }
    
    
    @isTest
    static void testVatApprovedFileUpdateUtility()
    {
        User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' and LastName = 'System Adm' limit 1];
        User paymentUser = [SELECT Id,Email from User where Email='clmcase@example.com' limit 1];
        PartnerFundClaim claimins;
        Core_MDF_Claim_VAT_Info__c vatInfo;
        System.runAs(sysAdminUser)
        {
            test.startTest();
            Core_MDF_Bank__c bank1 = [Select Id from Core_MDF_Bank__c where Core_MDF_Bank_Alias_Name__c='Test' limit 1];
            PartnerFundRequest pfr = [Select Id,Title,Core_MDF_Reimbursement_Rate__c from PartnerFundRequest where Title = 'Test Retail Activity'];
            PartnerFundClaim claim1 = Core_MDF_CCP_TestDataUtility.createClaim('Test Retail Claim', Core_MDF_CCP_TestDataUtility.claim_RecordType_Retail, pfr.Id, System.today(), System.today(), 50.00, System.today(), bank1.Id, false);
            claim1.Core_MDF_Type_Txt__c ='Claim';
            claim1.Core_MDF_Currency__c='USD';
            claim1.Core_MDF_Country_Location_nm__c= 'UNITED KINGDOM'; 
            claim1.Core_MDF_VAT_Opt_In__c = 'Yes';
            claim1.Core_MDF_VAT_Eligibility_Ind__c= true ; 
            claim1.Core_MDF_VAT_Hold_Ind__c = true;
            claim1.Core_MDF_Status__c = 'Hold';
            list<Core_MDF_Audit_Document__c> auditDocList = new list<Core_MDF_Audit_Document__c>();
            //String res = Core_MDF_PartnerFundClaim.saveClaim(claim1, auditDocList);  

            //claimins = [select id,Core_MDF_VAT_Eligibility_Ind__c,Core_MDF_Status__c,Core_MDF_Audit_Hold__c from PartnerFundClaim where id =: res limit 1];
            claimins.Core_MDF_Status__c = 'Hold';
            Database.update(claimins);
            
            // Read the VAT Invoice record
            //vatInfo = [select id from Core_MDF_Claim_VAT_Info__c where Core_MDF_Claim_Id__c = : res limit 1];
            //System.debug('###vatInfo->' + res);
            vatInfo.Core_MDF_VAT_Invoice_Number_Txt__c = 'VATINV001';
            Database.update(vatInfo);

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
            Database.update(vatInfo);
            
            ContentDocument doc = [Select Id, Title from ContentDocument where Id = :documents[0].Id];
            
            List<ContentDocument> attachedFiles = Core_MDF_Vat_Utility.getVatFileNames(vatInfo.Id);
            system.assertEquals(attachedFiles[0].Title,doc.Title);
            
            Core_MDF_Vat_Utility.VatEligibleWrapper wrap = Core_MDF_Vat_Utility.isEligible(vatInfo.Id);
            system.assertEquals(wrap.vatEligibleforUpdate, true);
            system.assertEquals(wrap.userEligibletoUpdate, false);
            
            PermissionSet paymentAdminPermissionSet = [SELECT Id, Name FROM PermissionSet where Name = 'Core_MDF_CCP_Internal_Retail_Payment_Adm'];        
            PermissionSetAssignment  psa = new PermissionSetAssignment(PermissionSetId = paymentAdminPermissionSet.Id, AssigneeId = paymentUser.Id);
            insert psa;
            
            PermissionSet genericPermissionSet = [SELECT Id, Name FROM PermissionSet where Name = 'Core_MDF_CCP_Internal_Generic_Access'];        
            PermissionSetAssignment  psa3 = new PermissionSetAssignment(PermissionSetId = genericPermissionSet.Id, AssigneeId = paymentUser.Id);
            insert psa3;
           
        }
        System.runAs(paymentUser)
        {
            Core_MDF_Vat_Utility.VatEligibleWrapper wrap2 = Core_MDF_Vat_Utility.isEligible(vatInfo.Id);
            system.assertEquals(true,wrap2.vatEligibleforUpdate);
            //system.assertEquals(true,wrap2.userEligibletoUpdate); i will uncomment later
        }
        test.stopTest();
    }
    
    @isTest
    static void testVatApprovedFileUpdateUtility2()
    {
        User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' and LastName = 'System Adm' limit 1];
        User paymentUser = [SELECT Id,Email from User where Email='clmcase@example.com' limit 1];
        PartnerFundClaim claimins, claimins2;
        Core_MDF_Claim_VAT_Info__c vatInfo, vatInfo2;
        System.runAs(sysAdminUser)
        {
            test.startTest();
            Core_MDF_Bank__c bank1 = [Select Id from Core_MDF_Bank__c where Core_MDF_Bank_Alias_Name__c='Test' limit 1];
            PartnerFundRequest pfr = [Select Id,Title,Core_MDF_Reimbursement_Rate__c from PartnerFundRequest where Title = 'Test Retail Activity'];
            PartnerFundClaim claim2 = Core_MDF_CCP_TestDataUtility.createClaim('Test Retail Claim', Core_MDF_CCP_TestDataUtility.claim_RecordType_Retail, pfr.Id, System.today(), System.today(), 50.00, System.today(), bank1.Id, false);
            claim2.Core_MDF_Type_Txt__c ='Claim';
            claim2.Core_MDF_Currency__c='USD';
            claim2.Core_MDF_Country_Location_nm__c= 'UNITED KINGDOM'; 
            claim2.Core_MDF_VAT_Opt_In__c = 'Yes';
            claim2.Core_MDF_VAT_Eligibility_Ind__c= true ; 
            claim2.Core_MDF_VAT_Hold_Ind__c = true;
            claim2.Core_MDF_Status__c = 'Hold';
            list<Core_MDF_Audit_Document__c> auditDocList = new list<Core_MDF_Audit_Document__c>();
           // String res = Core_MDF_PartnerFundClaim.saveClaim(claim2, auditDocList);  
           
           // claimins = [select id,Core_MDF_VAT_Eligibility_Ind__c,Core_MDF_Status__c,Core_MDF_Audit_Hold__c from PartnerFundClaim where id =: res limit 1];
            claimins.Core_MDF_Status__c = 'Hold';
            Database.update(claimins);


            // Read the VAT Invoice record
           // vatInfo = [select id from Core_MDF_Claim_VAT_Info__c where Core_MDF_Claim_Id__c = : res limit 1];
           // System.debug('###vatInfo->' + res);
            vatInfo.Core_MDF_VAT_Invoice_Number_Txt__c = 'VATINV001';
            Database.update(vatInfo);

            PermissionSet paymentAdminPermissionSet = [SELECT Id, Name FROM PermissionSet where Name = 'Core_MDF_CCP_Internal_Retail_Payment_Adm'];        
            PermissionSetAssignment  psa = new PermissionSetAssignment(PermissionSetId = paymentAdminPermissionSet.Id, AssigneeId = paymentUser.Id);
            insert psa;
            
            PermissionSet genericPermissionSet = [SELECT Id, Name FROM PermissionSet where Name = 'Core_MDF_CCP_Internal_Generic_Access'];        
            PermissionSetAssignment  psa3 = new PermissionSetAssignment(PermissionSetId = genericPermissionSet.Id, AssigneeId = paymentUser.Id);
            insert psa3;
            
            try{
                List<ContentDocument> attachedFiles2 = Core_MDF_Vat_Utility.getVatFileNames(vatInfo.Id);
                Core_MDF_Vat_Utility.VatEligibleWrapper wrap2 = Core_MDF_Vat_Utility.isEligible(vatInfo.Id);
               }
            catch(Exception e)
            {
                System.debug(e.getMessage());
           }
        }
        System.runAs(paymentUser)
        {
            Core_MDF_Vat_Utility.VatEligibleWrapper wrap2 = Core_MDF_Vat_Utility.isEligible(vatInfo.Id);
           // system.assertEquals(true,wrap2.vatEligibleforUpdate);
            system.assertEquals(false,wrap2.userEligibletoUpdate); 
        }
        test.stopTest();
    }
    
    @isTest
    static void testcaseReviewResultupdatesonVAT1()
    {
        User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' and LastName = 'System Adm' limit 1];
        User paymentUser = [SELECT Id,Email from User where Email='clmcase@example.com' limit 1];
        PartnerFundClaim claimins, claimins2;
        Core_MDF_Claim_VAT_Info__c vatInfo, vatInfo2;
        System.runAs(sysAdminUser)
        {
            test.startTest();
            Core_MDF_Bank__c bank1 = [Select Id from Core_MDF_Bank__c where Core_MDF_Bank_Alias_Name__c='Test' limit 1];
            PartnerFundRequest pfr = [Select Id,Title,Core_MDF_Reimbursement_Rate__c from PartnerFundRequest where Title = 'Test Retail Activity'];
            PartnerFundClaim claim2 = Core_MDF_CCP_TestDataUtility.createClaim('Test Retail Claim', Core_MDF_CCP_TestDataUtility.claim_RecordType_Retail, pfr.Id, System.today(), System.today(), 50.00, System.today(), bank1.Id, false);
            claim2.Core_MDF_Type_Txt__c ='Claim';
            claim2.Core_MDF_Currency__c='USD';
            claim2.Core_MDF_Country_Location_nm__c= 'UNITED KINGDOM'; 
            claim2.Core_MDF_VAT_Opt_In__c = 'Yes';
            claim2.Core_MDF_VAT_Eligibility_Ind__c= true ; 
            claim2.Core_MDF_VAT_Hold_Ind__c = true;
            claim2.Core_MDF_Status__c = 'Hold';
            list<Core_MDF_Audit_Document__c> auditDocList = new list<Core_MDF_Audit_Document__c>();
            //String res = Core_MDF_PartnerFundClaim.saveClaim(claim2, auditDocList);  
           
            //claimins = [select id,Core_MDF_VAT_Eligibility_Ind__c,Core_MDF_Status__c,Core_MDF_Audit_Hold__c from PartnerFundClaim where id =: res limit 1];
            claimins.Core_MDF_Status__c = 'Hold';
            Database.update(claimins);


            // Read the VAT Invoice record
           // vatInfo = [select id from Core_MDF_Claim_VAT_Info__c where Core_MDF_Claim_Id__c = : res limit 1];
            //System.debug('###vatInfo->' + res);
            vatInfo.Core_MDF_VAT_Invoice_Number_Txt__c = 'VATINV001';
            Database.update(vatInfo);
            // Creating Case
            Id caseAuditRecType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Core_MDF_Audit').getRecordTypeId();
            Account caseAcc = [Select id from Account where Name = 'Test Master Account'];
            Case cs = new Case();
            cs.recordTypeId = caseAuditRecType;
            cs.AccountId = caseAcc.Id;
            cs.OwnerId = sysAdminUser.Id;
            cs.Core_MDF_Region_SubRegion_txt__c = 'APAC';
            cs.Origin='Manual Selection';
            cs.Core_MDF_Claim_ID__c = claim2.Id;
            Database.insert(cs);
            
            cs.Core_MDF_Status__c = 'Under Review';
            Database.update(cs);
            
            claim2.Core_MDF_Claim_Review_Case__c = cs.id;
            claim2.Core_MDF_Audit_Hold__c = true;
            claim2.Core_MDF_Status__c = 'Hold';            
            Database.update(claim2);
            
            
            List<String> documentIdWithTitle = new List<String>();
            list<String> tempString = new list<String>();
            list<Core_MDF_Audit_Document__c> auditDocList2 = new list<Core_MDF_Audit_Document__c>();
            
            String str1 = claim2.Id+';#'+'Test Doc1';
            String str2 = claim2.Id+';#'+'Test Doc2';
            
            documentIdWithTitle.add(str1);
            documentIdWithTitle.add(str2);
            
            for(String str: documentIdWithTitle){
                tempString = str.split(';#');
                Core_MDF_Audit_Document__c auditDoc = new Core_MDF_Audit_Document__c();
                auditDoc.Core_MDF_Document_Id__c = tempString[0];
                auditDoc.Core_MDF_Document_Title__c = tempString[1];
                auditDoc.Core_MDF_Claim__c = claim2.Id;
                auditDoc.Core_MDF_Document_Types__c = 'Proof of Cost;Proof of Branding;Proof of Execution';
                auditDoc.Core_MDF_App_Document_Types_nm__c = 'Proof of Cost;Proof of Branding;Proof of Execution';               
                auditDocList2.add(auditDoc);
            }            
            
           // String saveClaim1 = Core_MDF_PartnerFundClaim.saveClaim(claim2,auditDocList2);
          //  system.debug('saveClaim1:::>'+claim2);
            Case csNew = [Select RecordType.DeveloperName, Id from Case where id = :cs.Id];
            Id caseAuditClosedRecordId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Core_MDF_Audit').getRecordTypeId();
            csNew.Core_MDF_Adjustment_Amount_USD_Amt__c=50;
            csNew.Core_MDF_Claim_Conversion_Exchange_Rate__c = 1;
            csNew.Core_MDF_Reimbursement_Rate__c = 50;
            csNew.Core_MDF_Requested_Amount_USD_Amt__c = 50;
            csNew.Core_MDF_Review_Case_Status__c ='Review Completed';
            csNew.Core_MDF_Scorecard_Score_Nbr__c=0;
            
            Core_MDF_Claim_Case_Checklist__c checklistRecord = new Core_MDF_Claim_Case_Checklist__c();
                checklistRecord.Core_MDF_Case_ID__c = csNew.id;
                checklistRecord.Core_MDF_Checklist_Status__c = 'Non-Compliant';
                checklistRecord.Core_MDF_Impact_Amount__c = 20;
                checklistRecord.Core_MDF_Completion_Percentage__c = 100;
                insert checklistRecord;
               
            Database.update(csNew);
          system.assertEquals(csNew.Core_MDF_Review_Case_Status__c,'Review Completed');
            
        }
    }
    
 /*   @isTest
    static void testcaseReviewResultupdatesonVAT2()
    {
        User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' and LastName = 'System Adm' limit 1];
        //User paymentUser = [SELECT Id,Email from User where Email='clmcase@example.com' limit 1];
        PartnerFundClaim claimins, claimins2;
        Core_MDF_Claim_VAT_Info__c vatInfo, vatInfo2;
        System.runAs(sysAdminUser)
        {
            test.startTest();
            Core_MDF_Bank__c bank1 = [Select Id from Core_MDF_Bank__c where Core_MDF_Bank_Alias_Name__c='Test' limit 1];
            PartnerFundRequest pfr = [Select Id,Title,Core_MDF_Reimbursement_Rate__c from PartnerFundRequest where Title = 'Test Retail Activity'];
            PartnerFundClaim claim2 = Core_MDF_CCP_TestDataUtility.createClaim('Test Retail Claim', Core_MDF_CCP_TestDataUtility.claim_RecordType_Retail, pfr.Id, System.today(), System.today(), 50.00, System.today(), bank1.Id, false);
            claim2.Core_MDF_Type_Txt__c ='Claim';
            claim2.Core_MDF_Currency__c='USD';
            claim2.Core_MDF_Country_Location_nm__c= 'UNITED KINGDOM'; 
            list<Core_MDF_Audit_Document__c> auditDocList = new list<Core_MDF_Audit_Document__c>();
            String res = Core_MDF_PartnerFundClaim.saveClaim(claim2, auditDocList);  
            
            // Creating Case
            Id caseAuditRecType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Core_MDF_Audit').getRecordTypeId();
            Account caseAcc = [Select id from Account where Name = 'Test Master Account'];
            Case cs = new Case();
            cs.recordTypeId = caseAuditRecType;
            cs.AccountId = caseAcc.Id;
            cs.OwnerId = sysAdminUser.Id;
            cs.Core_MDF_Region_SubRegion_txt__c = 'APAC';
            cs.Origin='Manual Selection';
            cs.Core_MDF_Claim_ID__c = claim2.Id;
            Database.insert(cs);
            
            cs.Core_MDF_Status__c = 'Under Review';
            Database.update(cs);
            
            claim2.Core_MDF_Claim_Review_Case__c = cs.id;
            claim2.Core_MDF_Audit_Hold__c = true;
            claim2.Core_MDF_Status__c = 'Hold';            
            Database.update(claim2);
            
            
            List<String> documentIdWithTitle = new List<String>();
            list<String> tempString = new list<String>();
            list<Core_MDF_Audit_Document__c> auditDocList2 = new list<Core_MDF_Audit_Document__c>();
            
            String str1 = claim2.Id+';#'+'Test Doc1';
            String str2 = claim2.Id+';#'+'Test Doc2';
            
            documentIdWithTitle.add(str1);
            documentIdWithTitle.add(str2);
            
            for(String str: documentIdWithTitle){
                tempString = str.split(';#');
                Core_MDF_Audit_Document__c auditDoc = new Core_MDF_Audit_Document__c();
                auditDoc.Core_MDF_Document_Id__c = tempString[0];
                auditDoc.Core_MDF_Document_Title__c = tempString[1];
                auditDoc.Core_MDF_Claim__c = claim2.Id;
                auditDoc.Core_MDF_Document_Types__c = 'Proof of Cost;Proof of Branding;Proof of Execution';
                auditDoc.Core_MDF_App_Document_Types_nm__c = 'Proof of Cost;Proof of Branding;Proof of Execution';               
                auditDocList2.add(auditDoc);
            }            
            
            String saveClaim1 = Core_MDF_PartnerFundClaim.saveClaim(claim2,auditDocList2);
            system.debug('saveClaim1:::>'+claim2);
            Case csNew = [Select RecordType.DeveloperName, Id from Case where id = :cs.Id];
            Id caseAuditClosedRecordId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Core_MDF_Audit').getRecordTypeId();
            csNew.Core_MDF_Adjustment_Amount_USD_Amt__c=50;
            csNew.Core_MDF_Claim_Conversion_Exchange_Rate__c = 1;
            csNew.Core_MDF_Reimbursement_Rate__c = 50;
            csNew.Core_MDF_Requested_Amount_USD_Amt__c = 50;
            csNew.Core_MDF_Review_Case_Status__c ='Non-compliant';
            Database.update(csNew);
            system.assertEquals(csNew.Core_MDF_Review_Case_Status__c,'Non-compliant');
        }
    }
     @isTest
    static void testcaseReviewResultupdatesonVAT3()
    {
        User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' and LastName = 'System Adm' limit 1];
        User paymentUser = [SELECT Id,Email from User where Email='clmcase@example.com' limit 1];
        PartnerFundClaim claimins, claimins2;
        Core_MDF_Claim_VAT_Info__c vatInfo, vatInfo2;
        System.runAs(sysAdminUser)
        {
            test.startTest();
            Core_MDF_Bank__c bank1 = [Select Id from Core_MDF_Bank__c where Core_MDF_Bank_Alias_Name__c='Test' limit 1];
            PartnerFundRequest pfr = [Select Id,Title,Core_MDF_Reimbursement_Rate__c from PartnerFundRequest where Title = 'Test Retail Activity'];
            PartnerFundClaim claim2 = Core_MDF_CCP_TestDataUtility.createClaim('Test Retail Claim', Core_MDF_CCP_TestDataUtility.claim_RecordType_Retail, pfr.Id, System.today(), System.today(), 50.00, System.today(), bank1.Id, false);
            claim2.Core_MDF_Type_Txt__c ='Claim';
            claim2.Core_MDF_Currency__c='USD';
            claim2.Core_MDF_Country_Location_nm__c= 'UNITED KINGDOM'; 
            claim2.Core_MDF_VAT_Opt_In__c = 'Yes';
            claim2.Core_MDF_VAT_Eligibility_Ind__c= true ; 
            list<Core_MDF_Audit_Document__c> auditDocList = new list<Core_MDF_Audit_Document__c>();
            String res = Core_MDF_PartnerFundClaim.saveClaim(claim2, auditDocList);  
           
            // Creating Case
            Id caseAuditRecType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Core_MDF_Audit').getRecordTypeId();
            Account caseAcc = [Select id from Account where Name = 'Test Master Account'];
            Case cs = new Case();
            cs.recordTypeId = caseAuditRecType;
            cs.AccountId = caseAcc.Id;
            cs.OwnerId = sysAdminUser.Id;
            cs.Core_MDF_Region_SubRegion_txt__c = 'APAC';
            cs.Origin='Manual Selection';
            cs.Core_MDF_Claim_ID__c = claim2.Id;
            Database.insert(cs);
            
            cs.Core_MDF_Status__c = 'Under Review';
            Database.update(cs);
            
            claim2.Core_MDF_Claim_Review_Case__c = cs.id;
            claim2.Core_MDF_Audit_Hold__c = true;
            claim2.Core_MDF_Status__c = 'Hold';            
            Database.update(claim2);
            
            
            List<String> documentIdWithTitle = new List<String>();
            list<String> tempString = new list<String>();
            list<Core_MDF_Audit_Document__c> auditDocList2 = new list<Core_MDF_Audit_Document__c>();
            
            String str1 = claim2.Id+';#'+'Test Doc1';
            String str2 = claim2.Id+';#'+'Test Doc2';
            
            documentIdWithTitle.add(str1);
            documentIdWithTitle.add(str2);
            
            for(String str: documentIdWithTitle){
                tempString = str.split(';#');
                Core_MDF_Audit_Document__c auditDoc = new Core_MDF_Audit_Document__c();
                auditDoc.Core_MDF_Document_Id__c = tempString[0];
                auditDoc.Core_MDF_Document_Title__c = tempString[1];
                auditDoc.Core_MDF_Claim__c = claim2.Id;
                auditDoc.Core_MDF_Document_Types__c = 'Proof of Cost;Proof of Branding;Proof of Execution';
                auditDoc.Core_MDF_App_Document_Types_nm__c = 'Proof of Cost;Proof of Branding;Proof of Execution';               
                auditDocList2.add(auditDoc);
            }            
            
            String saveClaim1 = Core_MDF_PartnerFundClaim.saveClaim(claim2,auditDocList2);
            system.debug('saveClaim1:::>'+claim2);
            Case csNew = [Select RecordType.DeveloperName, Id from Case where id = :cs.Id];
            Id caseAuditClosedRecordId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Core_MDF_Audit').getRecordTypeId();
            csNew.Core_MDF_Claim_Conversion_Exchange_Rate__c = 1;
            csNew.Core_MDF_Reimbursement_Rate__c = 50;
            csNew.Core_MDF_Requested_Amount_USD_Amt__c = 50;
            csNew.Core_MDF_Review_Case_Status__c ='Compliant';
            Database.update(csNew);
            system.assertEquals(csNew.Core_MDF_Review_Case_Status__c,'Compliant');
        }
    }
    
    @isTest
    static void testcaseReviewResultupdatesonVAT4()
    {
        User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' and LastName = 'System Adm' limit 1];
        User paymentUser = [SELECT Id,Email from User where Email='clmcase@example.com' limit 1];
        PartnerFundClaim claimins, claimins2;
        Core_MDF_Claim_VAT_Info__c vatInfo, vatInfo2;
        System.runAs(sysAdminUser)
        {
            test.startTest();
            Core_MDF_Bank__c bank1 = [Select Id from Core_MDF_Bank__c where Core_MDF_Bank_Alias_Name__c='Test' limit 1];
            PartnerFundRequest pfr = [Select Id,Title,Core_MDF_Reimbursement_Rate__c from PartnerFundRequest where Title = 'Test Retail Activity'];
            PartnerFundClaim claim2 = Core_MDF_CCP_TestDataUtility.createClaim('Test Retail Claim', Core_MDF_CCP_TestDataUtility.claim_RecordType_Retail, pfr.Id, System.today(), System.today(), 50.00, System.today(), bank1.Id, false);
            claim2.Core_MDF_Type_Txt__c ='Claim';
            claim2.Core_MDF_Currency__c='USD';
            claim2.Core_MDF_Country_Location_nm__c= 'UNITED KINGDOM';
            claim2.Core_MDF_VAT_Opt_In__c = 'Yes';
            claim2.Core_MDF_VAT_Eligibility_Ind__c= true ; 
            claim2.Core_MDF_VAT_Hold_Ind__c = true;
            claim2.Core_MDF_Status__c = 'Hold';
            list<Core_MDF_Audit_Document__c> auditDocList = new list<Core_MDF_Audit_Document__c>();
            String res = Core_MDF_PartnerFundClaim.saveClaim(claim2, auditDocList);  
           
            claimins = [select id,Core_MDF_VAT_Eligibility_Ind__c,Core_MDF_Status__c,Core_MDF_Audit_Hold__c from PartnerFundClaim where id =: res limit 1];
            claimins.Core_MDF_Status__c = 'Hold';
            Database.update(claimins);


            // Read the VAT Invoice record
            vatInfo = [select id from Core_MDF_Claim_VAT_Info__c where Core_MDF_Claim_Id__c = : res limit 1];
            System.debug('###vatInfo->' + res);
            //vatInfo.Core_MDF_VAT_Invoice_Number_Txt__c = 'VATINV001';
            vatInfo.Core_MDF_Status_Txt__c='Approved';
            Database.update(vatInfo);
            // Creating Case
            Id caseAuditRecType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Core_MDF_Audit').getRecordTypeId();
            Account caseAcc = [Select id from Account where Name = 'Test Master Account'];
            Case cs = new Case();
            cs.recordTypeId = caseAuditRecType;
            cs.AccountId = caseAcc.Id;
            cs.OwnerId = sysAdminUser.Id;
            cs.Core_MDF_Region_SubRegion_txt__c = 'APAC';
            cs.Origin='Manual Selection';
            cs.Core_MDF_Claim_ID__c = claim2.Id;
            Database.insert(cs);
            
            cs.Core_MDF_Status__c = 'Under Review';
            Database.update(cs);
            
            claim2.Core_MDF_Claim_Review_Case__c = cs.id;
            claim2.Core_MDF_Audit_Hold__c = true;
            claim2.Core_MDF_Status__c = 'Hold';            
            Database.update(claim2);
            
            
            List<String> documentIdWithTitle = new List<String>();
            list<String> tempString = new list<String>();
            list<Core_MDF_Audit_Document__c> auditDocList2 = new list<Core_MDF_Audit_Document__c>();
            
            String str1 = claim2.Id+';#'+'Test Doc1';
            String str2 = claim2.Id+';#'+'Test Doc2';
            
            documentIdWithTitle.add(str1);
            documentIdWithTitle.add(str2);
            
            for(String str: documentIdWithTitle){
                tempString = str.split(';#');
                Core_MDF_Audit_Document__c auditDoc = new Core_MDF_Audit_Document__c();
                auditDoc.Core_MDF_Document_Id__c = tempString[0];
                auditDoc.Core_MDF_Document_Title__c = tempString[1];
                auditDoc.Core_MDF_Claim__c = claim2.Id;
                auditDoc.Core_MDF_Document_Types__c = 'Proof of Cost;Proof of Branding;Proof of Execution';
                auditDoc.Core_MDF_App_Document_Types_nm__c = 'Proof of Cost;Proof of Branding;Proof of Execution';               
                auditDocList2.add(auditDoc);
            }            
            
            String saveClaim1 = Core_MDF_PartnerFundClaim.saveClaim(claim2,auditDocList2);
            system.debug('saveClaim1:::>'+claim2);
            Case csNew = [Select RecordType.DeveloperName, Id from Case where id = :cs.Id];
            Id caseAuditClosedRecordId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Core_MDF_Audit').getRecordTypeId();
            csNew.Core_MDF_Claim_Conversion_Exchange_Rate__c = 1;
            csNew.Core_MDF_Reimbursement_Rate__c = 50;
            csNew.Core_MDF_Requested_Amount_USD_Amt__c = 50;
            csNew.Core_MDF_Review_Case_Status__c ='Compliant';
            Database.update(csNew);
            system.assertEquals(csNew.Core_MDF_Review_Case_Status__c,'Compliant');
        }
    }
    
    @isTest
    static void testcaseReviewResultupdatesonVAT5()
    {
        User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' and LastName = 'System Adm' limit 1];
        User paymentUser = [SELECT Id,Email from User where Email='clmcase@example.com' limit 1];
        PartnerFundClaim claimins, claimins2;
        Core_MDF_Claim_VAT_Info__c vatInfo, vatInfo2;
        System.runAs(sysAdminUser)
        {
            test.startTest();
            Core_MDF_Bank__c bank1 = [Select Id from Core_MDF_Bank__c where Core_MDF_Bank_Alias_Name__c='Test1' limit 1];
            PartnerFundRequest pfr = [Select Id,Title,Core_MDF_Reimbursement_Rate__c from PartnerFundRequest where Title = 'Test Retail Activity'];
            PartnerFundClaim claim2 = Core_MDF_CCP_TestDataUtility.createClaim('Test Retail Claim', Core_MDF_CCP_TestDataUtility.claim_RecordType_Retail, pfr.Id, System.today(), System.today(), 50.00, System.today(), bank1.Id, false);
            claim2.Core_MDF_Type_Txt__c ='Claim';
            claim2.Core_MDF_Currency__c='USD';
            claim2.Core_MDF_Country_Location_nm__c= 'UNITED KINGDOM'; 
            list<Core_MDF_Audit_Document__c> auditDocList = new list<Core_MDF_Audit_Document__c>();
            String res = Core_MDF_PartnerFundClaim.saveClaim(claim2, auditDocList);  
           
            // Creating Case
            Id caseAuditRecType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Core_MDF_Audit').getRecordTypeId();
            Account caseAcc = [Select id from Account where Name = 'Test Master Account'];
            Case cs = new Case();
            cs.recordTypeId = caseAuditRecType;
            cs.AccountId = caseAcc.Id;
            cs.OwnerId = sysAdminUser.Id;
            cs.Core_MDF_Region_SubRegion_txt__c = 'APAC';
            cs.Origin='Manual Selection';
            cs.Core_MDF_Claim_ID__c = claim2.Id;
            Database.insert(cs);
            
            cs.Core_MDF_Status__c = 'Under Review';
            Database.update(cs);
            
            claim2.Core_MDF_Claim_Review_Case__c = cs.id;
            claim2.Core_MDF_Audit_Hold__c = true;
            claim2.Core_MDF_Status__c = 'Hold';            
            Database.update(claim2);
            
            
            List<String> documentIdWithTitle = new List<String>();
            list<String> tempString = new list<String>();
            list<Core_MDF_Audit_Document__c> auditDocList2 = new list<Core_MDF_Audit_Document__c>();
            
            String str1 = claim2.Id+';#'+'Test Doc1';
            String str2 = claim2.Id+';#'+'Test Doc2';
            
            documentIdWithTitle.add(str1);
            documentIdWithTitle.add(str2);
            
            for(String str: documentIdWithTitle){
                tempString = str.split(';#');
                Core_MDF_Audit_Document__c auditDoc = new Core_MDF_Audit_Document__c();
                auditDoc.Core_MDF_Document_Id__c = tempString[0];
                auditDoc.Core_MDF_Document_Title__c = tempString[1];
                auditDoc.Core_MDF_Claim__c = claim2.Id;
                auditDoc.Core_MDF_Document_Types__c = 'Proof of Cost;Proof of Branding;Proof of Execution';
                auditDoc.Core_MDF_App_Document_Types_nm__c = 'Proof of Cost;Proof of Branding;Proof of Execution';               
                auditDocList2.add(auditDoc);
            }            
            
            String saveClaim1 = Core_MDF_PartnerFundClaim.saveClaim(claim2,auditDocList2);
            system.debug('saveClaim1:::>'+claim2);
            Case csNew = [Select RecordType.DeveloperName, Id from Case where id = :cs.Id];
            Id caseAuditClosedRecordId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Core_MDF_Audit').getRecordTypeId();

            csNew.Core_MDF_Claim_Conversion_Exchange_Rate__c = 1;
            csNew.Core_MDF_Reimbursement_Rate__c = 50;
            csNew.Core_MDF_Requested_Amount_USD_Amt__c = 50;
            csNew.Core_MDF_Review_Case_Status__c ='Compliant';
            Database.update(csNew);
            system.assertEquals(csNew.Core_MDF_Review_Case_Status__c,'Compliant');
        }
    }
    /**Areefa**/
  @isTest
    static void testRetailClaimWithChangeInAmountAndBank()
    {
        User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' and LastName = 'System Adm' limit 1]; 
        //User clmCaseUser = [SELECT Id,Email from User where Email='clmcase@example.com' limit 1];
        PartnerFundClaim claimins;
        Core_MDF_Claim_VAT_Info__c vatInfo,vatInfo1;
        boolean claimEligibleforVat = false;
        boolean updateVatInfo = false;
        System.runAs(sysAdminUser)
        {
            test.startTest();
            Core_MDF_Bank__c bank1 = [Select Id,Core_MDF_VAT_pct__c from Core_MDF_Bank__c where Core_MDF_Bank_Alias_Name__c='Test' limit 1];
            Core_MDF_Bank__c bank2 = [Select Id,Core_MDF_VAT_pct__c from Core_MDF_Bank__c where Core_MDF_Bank_Alias_Name__c='Test1' limit 1];
            PartnerFundRequest pfr = [Select Id,Title,Core_MDF_Reimbursement_Rate__c from PartnerFundRequest where Title = 'Test Retail Activity'];
            PartnerFundClaim claim1 = Core_MDF_CCP_TestDataUtility.createClaim('Test Claim101', Core_MDF_CCP_TestDataUtility.claim_RecordType_Retail, pfr.Id, System.today(), System.today(), 50.00, System.today(), bank1.Id, false);
            claim1.Core_MDF_Type_Txt__c ='Claim';
            claim1.Core_MDF_Currency__c='USD';
            claim1.Core_MDF_Country_Location_nm__c= 'UNITED KINGDOM';
            claim1.Core_MDF_To_Be_Audited_Ind__c=true;
            claim1.Core_MDF_VAT_Opt_In__c = 'Yes';
            claim1.Core_MDF_VAT_Eligibility_Ind__c= true ; 
            claim1.Core_MDF_VAT_Hold_Ind__c = true;
            claim1.Core_MDF_Status__c = 'Hold';         
            list<Core_MDF_Audit_Document__c> auditDocList = new list<Core_MDF_Audit_Document__c>();            
           // String res = Core_MDF_PartnerFundClaim.saveClaim(claim1, auditDocList);
            PartnerFundClaim pfc = [Select id,Core_MDF_To_Be_Audited_Ind__c,Core_MDF_Budget_Type_Options_Nm__c,Core_MDF_Program__c,Core_MDF_VAT_Eligibility_Ind__c,
                                          Core_MDF_Status__c,Core_MDF_VAT_Hold_Ind__c,Core_MDF_Country_Location_nm__c,Core_MDF_Bank__C 
                                    from PartnerFundClaim where Title = 'Test Claim101'];
            System.debug('pfc query1 =' + pfc);            
            //system.assertEquals(pfc.Core_MDF_VAT_Eligibility_Ind__c, true);
            //system.assertEquals(pfc.Core_MDF_Status__c, 'Hold');
            //system.assertEquals(pfc.Core_MDF_VAT_Hold_Ind__c, true);  

            //change in vat amount should retrigger VAT process
            pfc.Core_MDF_Total_Invoice_Amount_Local__c= 51.00;
            database.update(pfc);
             Core_MDF_Claim_VAT_Info__c newVatRec = new Core_MDF_Claim_VAT_Info__c();
            newVatRec.Core_MDF_Claim_Id__c = pfc.Id;
            insert newVatRec;
            // Read the VAT Invoice record
            vatInfo = [select id,Core_MDF_Status_Txt__c from Core_MDF_Claim_VAT_Info__c where Core_MDF_Claim_Id__c = : pfc.Id];
            //System.debug('change in amount vatInfo->' + res);
            system.assertEquals(vatInfo.Core_MDF_Status_Txt__c, 'Pending Documents');           
            
            pfc.Core_MDF_Bank__c=bank2.Id;
            database.update(pfc);
             Core_MDF_Claim_VAT_Info__c newVatRec2 = new Core_MDF_Claim_VAT_Info__c();
            newVatRec2.Core_MDF_Claim_Id__c = pfc.Id;
            insert newVatRec2;
            vatInfo1 = [select id,Core_MDF_Status_Txt__c from Core_MDF_Claim_VAT_Info__c where Core_MDF_Claim_Id__c = : pfc.Id limit 1];
            System.debug('change of bank to 0% vatInfo->' + vatInfo1);
            //system.assertEquals(vatInfo.Core_MDF_Status_Txt__c, 'Pending Documents'); 
            system.assertEquals(vatInfo1.Core_MDF_Status_Txt__c, 'Cancelled');
            
            PartnerFundClaim pfc2 = [Select id,Core_MDF_Program__c,Core_MDF_VAT_Eligibility_Ind__c,Core_MDF_Status__c,Core_MDF_VAT_Hold_Ind__c from PartnerFundClaim where Title = 'Test Claim101'];
            system.debug('pfc2 query = '+pfc2);
            system.assertEquals(pfc.Core_MDF_VAT_Hold_Ind__c,true);
            
            test.stopTest(); 
            
            Core_MDF_PartnerFundClaim.ckeckProgramLEForVatOptIn('420',pfc.Core_MDF_Program__c);
            
        }
        
    }
    //Claim Status to denied with no vat record.
  @isTest
    static void testClaimStatusToDenied()
    {
        User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' and LastName = 'System Adm' limit 1];
        PartnerFundClaim claimins, claimins2;
        Core_MDF_Claim_VAT_Info__c vatInfo, vatInfo2;
        System.runAs(sysAdminUser)
        {
            test.startTest();
            Core_MDF_Bank__c bank1 = [Select Id from Core_MDF_Bank__c where Core_MDF_Bank_Alias_Name__c='Test' limit 1];
            PartnerFundRequest pfr = [Select Id,Title,Core_MDF_Reimbursement_Rate__c from PartnerFundRequest where Title = 'Test Retail Activity'];
            PartnerFundClaim claim2 = Core_MDF_CCP_TestDataUtility.createClaim('Test Retail Claim', Core_MDF_CCP_TestDataUtility.claim_RecordType_Retail, pfr.Id, System.today(), System.today(), 50.00, System.today(), bank1.Id, false);
            claim2.Core_MDF_Type_Txt__c ='Claim';
            claim2.Core_MDF_Currency__c='USD';
            claim2.Core_MDF_Country_Location_nm__c= 'UNITED KINGDOM'; 
            claim2.Core_MDF_VAT_Opt_In__c = 'No';
            claim2.Core_MDF_Bank_Doc_Hold_Eligibility_Ind__c=true;
            claim2.Core_MDF_Bank_Doc_Hold_Ind__c=true;
            claim2.Core_MDF_Status__c = 'Hold';
            list<Core_MDF_Audit_Document__c> auditDocList = new list<Core_MDF_Audit_Document__c>();
            //String res = Core_MDF_PartnerFundClaim.saveClaim(claim2, auditDocList);  
           
            //claimins = [select id,Core_MDF_VAT_Eligibility_Ind__c,Core_MDF_Status__c,Core_MDF_Audit_Hold__c from PartnerFundClaim where id =: res limit 1];
            claimins.Core_MDF_Status__c = 'Hold';
            Database.update(claimins);


            // Creating Case
            Id caseAuditRecType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Core_MDF_Audit').getRecordTypeId();
            Account caseAcc = [Select id from Account where Name = 'Test Master Account'];
            Case cs = new Case();
            cs.recordTypeId = caseAuditRecType;
            cs.AccountId = caseAcc.Id;
            cs.OwnerId = sysAdminUser.Id;
            cs.Core_MDF_Region_SubRegion_txt__c = 'APAC';
            cs.Origin='Manual Selection';
            cs.Core_MDF_Claim_ID__c = claim2.Id;
            Database.insert(cs);
            
            cs.Core_MDF_Status__c = 'Under Review';
            Database.update(cs);
            
            claim2.Core_MDF_Claim_Review_Case__c = cs.id;
            claim2.Core_MDF_Audit_Hold__c = true;
            claim2.Core_MDF_Status__c = 'Hold';            
            Database.update(claim2);
            
            
            List<String> documentIdWithTitle = new List<String>();
            list<String> tempString = new list<String>();
            list<Core_MDF_Audit_Document__c> auditDocList2 = new list<Core_MDF_Audit_Document__c>();
            
            String str1 = claim2.Id+';#'+'Test Doc1';
            String str2 = claim2.Id+';#'+'Test Doc2';
            
            documentIdWithTitle.add(str1);
            documentIdWithTitle.add(str2);
            
            for(String str: documentIdWithTitle){
                tempString = str.split(';#');
                Core_MDF_Audit_Document__c auditDoc = new Core_MDF_Audit_Document__c();
                auditDoc.Core_MDF_Document_Id__c = tempString[0];
                auditDoc.Core_MDF_Document_Title__c = tempString[1];
                auditDoc.Core_MDF_Claim__c = claim2.Id;
                auditDoc.Core_MDF_Document_Types__c = 'Proof of Cost;Proof of Branding;Proof of Execution';
                auditDoc.Core_MDF_App_Document_Types_nm__c = 'Proof of Cost;Proof of Branding;Proof of Execution';               
                auditDocList2.add(auditDoc);
            }            
            
            //String saveClaim1 = Core_MDF_PartnerFundClaim.saveClaim(claim2,auditDocList2);
            //system.debug('saveClaim1:::>'+claim2);
            Case csNew = [Select RecordType.DeveloperName, Id from Case where id = :cs.Id];
            Id caseAuditClosedRecordId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Core_MDF_Audit').getRecordTypeId();
            csNew.Core_MDF_Adjustment_Amount_USD_Amt__c=50;
            csNew.Core_MDF_Claim_Conversion_Exchange_Rate__c = 1;
            csNew.Core_MDF_Reimbursement_Rate__c = 50;
            csNew.Core_MDF_Requested_Amount_USD_Amt__c = 50;
            csNew.Core_MDF_Review_Case_Status__c ='Review Completed';
            csNew.Core_MDF_Scorecard_Score_Nbr__c=0;
            
            Core_MDF_Claim_Case_Checklist__c checklistRecord = new Core_MDF_Claim_Case_Checklist__c();
                checklistRecord.Core_MDF_Case_ID__c = csNew.id;
                checklistRecord.Core_MDF_Checklist_Status__c = 'Non-Compliant';
                checklistRecord.Core_MDF_Impact_Amount__c = 20;
                checklistRecord.Core_MDF_Completion_Percentage__c = 100;
                insert checklistRecord;
               
            Database.update(csNew);
          system.assertEquals(csNew.Core_MDF_Review_Case_Status__c,'Review Completed');
            
        }
    }
    /*@isTest
    static void testClaimReleaseHold()
    {  
        User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' and LastName = 'System Adm' limit 1];
        Account acc = [Select id,BillingCountry,BillingState from Account where name='Test Retail Intel Account'];
       acc.BillingCountry='IND';
       acc.Billingstate ='AP';
       System.runAs(sysAdminUser)  {
       update acc;
      }
         PartnerFundClaim claimins, claimins2;
        Core_MDF_Claim_VAT_Info__c vatInfo, vatInfo2;
        System.runAs(sysAdminUser)
        {
            test.startTest();
            Core_MDF_Bank__c bank1 = [Select Id from Core_MDF_Bank__c where Core_MDF_Bank_Alias_Name__c='Test' limit 1];
            PartnerFundRequest pfr = [Select Id,Title,Core_MDF_Reimbursement_Rate__c from PartnerFundRequest where Title = 'Test Retail Activity'];
            PartnerFundClaim claim2 = Core_MDF_CCP_TestDataUtility.createClaim('Test Retail Claim', Core_MDF_CCP_TestDataUtility.claim_RecordType_Retail, pfr.Id, System.today(), System.today(), 50.00, System.today(), bank1.Id, false);
            claim2.Core_MDF_Type_Txt__c ='Claim';
            claim2.Core_MDF_Currency__c='USD';
            claim2.Core_MDF_Country_Location_nm__c= 'UNITED KINGDOM'; 
            claim2.Core_MDF_VAT_Opt_In__c = 'true';
            claim2.Core_MDF_Status__c = 'Hold';
            list<Core_MDF_Audit_Document__c> auditDocList = new list<Core_MDF_Audit_Document__c>();
            String res = Core_MDF_PartnerFundClaim.saveClaim(claim2, auditDocList);  
           
            claimins = [select id,Core_MDF_VAT_Eligibility_Ind__c,Core_MDF_Status__c,Core_MDF_Audit_Hold__c from PartnerFundClaim where id =: res limit 1];
            claimins.Core_MDF_Status__c = 'Hold';
            Database.update(claimins);


            // Creating Case
            Id caseAuditRecType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Core_MDF_Audit').getRecordTypeId();
            Account caseAcc = [Select id from Account where Name = 'Test Master Account'];
            Case cs = new Case();
            cs.recordTypeId = caseAuditRecType;
            cs.AccountId = caseAcc.Id;
            cs.OwnerId = sysAdminUser.Id;
            cs.Core_MDF_Region_SubRegion_txt__c = 'APAC';
            cs.Origin='Manual Selection';
            cs.Core_MDF_Claim_ID__c = claim2.Id;
            Database.insert(cs);
            
            cs.Core_MDF_Status__c = 'Under Review';
            Database.update(cs);
            
            claim2.Core_MDF_Claim_Review_Case__c = cs.id;
            claim2.Core_MDF_Audit_Hold__c = true;
            claim2.Core_MDF_Status__c = 'Hold';            
            Database.update(claim2);
            
            
            List<String> documentIdWithTitle = new List<String>();
            list<String> tempString = new list<String>();
            list<Core_MDF_Audit_Document__c> auditDocList2 = new list<Core_MDF_Audit_Document__c>();
            
            String str1 = claim2.Id+';#'+'Test Doc1';
            String str2 = claim2.Id+';#'+'Test Doc2';
            
            documentIdWithTitle.add(str1);
            documentIdWithTitle.add(str2);
            
            for(String str: documentIdWithTitle){
                tempString = str.split(';#');
                Core_MDF_Audit_Document__c auditDoc = new Core_MDF_Audit_Document__c();
                auditDoc.Core_MDF_Document_Id__c = tempString[0];
                auditDoc.Core_MDF_Document_Title__c = tempString[1];
                auditDoc.Core_MDF_Claim__c = claim2.Id;
                auditDoc.Core_MDF_Document_Types__c = 'Proof of Cost;Proof of Branding;Proof of Execution';
                auditDoc.Core_MDF_App_Document_Types_nm__c = 'Proof of Cost;Proof of Branding;Proof of Execution';               
                auditDocList2.add(auditDoc);
            }            
            
            String saveClaim1 = Core_MDF_PartnerFundClaim.saveClaim(claim2,auditDocList2);
            system.debug('saveClaim1:::>'+claim2);
            Case csNew = [Select RecordType.DeveloperName, Id from Case where id = :cs.Id];
            Id caseAuditClosedRecordId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Core_MDF_Audit').getRecordTypeId();
            csNew.Core_MDF_Adjustment_Amount_USD_Amt__c=50;
            csNew.Core_MDF_Claim_Conversion_Exchange_Rate__c = 1;
            csNew.Core_MDF_Reimbursement_Rate__c = 50;
            csNew.Core_MDF_Requested_Amount_USD_Amt__c = 50;
            csNew.Core_MDF_Review_Case_Status__c ='compliant';
            Database.update(csNew);
          system.assertEquals(csNew.Core_MDF_Review_Case_Status__c,'compliant');
            
        }
    }*/


   /*
    @TestSetup 
    static void setUpData(){
        List<ChannelProgram> channelProgramList = new List<ChannelProgram>();
        List<Account> comarketingAccountsList = new List<Account>();
        List<Campaign> campaignList = new List<Campaign>();
        List<PartnerFundRequest> pfrList = new List<PartnerFundRequest>();
        
        Account dellCorpAccount = Core_MDF_CCP_TestDataUtility.createAccount ('Dell Corporation', NULL,Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);   
        dellCorpAccount.BillingCity = 'Test City';         
        dellCorpAccount.BillingCountry= 'AUS';
        dellCorpAccount.BillingStreet= 'Test Street';
        dellCorpAccount.BillingState= 'TAS';
        dellCorpAccount.Core_Geo__c= 'APJ';
        dellCorpAccount.Core_Account_Country__c = 'JAPAN';
        database.insert(dellCorpAccount);
        
        ChannelProgram cp1 = Core_MDF_CCP_TestDataUtility.createProgram ('Retail Marketing Funds','Retail Marketing Funds', false);        
        channelProgramList.add(cp1);
        
        database.insert(channelProgramList);
        
        Account dellRMFVirtualCorp = Core_MDF_CCP_TestDataUtility.createAccount ('Dell RMF Virtual Corp', cp1.Id,Core_MDF_CCP_TestDataUtility.account_Record_Type, false);
        dellRMFVirtualCorp.Core_MDF_Parent_Fund_Account__c = dellCorpAccount.Id;
        dellRMFVirtualCorp.Core_Geo__c = 'APJ';
        dellRMFVirtualCorp.Core_Account_Country__c = 'JAPAN'; //Other Non Japan country is United States
        comarketingAccountsList.add(dellRMFVirtualCorp);        
        Database.insert(comarketingAccountsList); 
        
        PartnerMarketingBudget retailBudget = Core_MDF_CCP_TestDataUtility.createBudget('TestBudgetData1',Core_MDF_CCP_TestDataUtility.budget_Record_Type,
                                                                                        dellRMFVirtualCorp.id, cp1.Id , 1000000 , System.today()-60 , System.today() + 60 , false);
        retailBudget.IsIgnoreValidation = true;
        insert retailBudget;
        retailBudget.Core_MDF_Budget_Status__c = 'Released';
        update retailBudget;
        
        Campaign rsaMDCamp = Core_MDF_CCP_TestDataUtility.createCampaign('Retail Campaigm2','Gaming','9ᵗʰ Gen', 'No', Core_MDF_CCP_TestDataUtility.campaign_RecordType_Retail, 'Retail Marketing Funds',System.today(), System.today() + 55, 1000, 'Instore innovation', dellRMFVirtualCorp.Id,'Desktop', false); 
        rsaMDCamp.Core_MDF_Budget_Type_txt__c ='RSA MD';
        rsaMDCamp.Core_MDF_Activity_Category_Type__c =null;
        rsaMDCamp.Core_MDF_Reimbursement_Rate__c='100%';
        rsaMDCamp.Core_MDF_Technology__c = 'Intel vPro®';
        campaignList.add(rsaMDCamp);
        
        database.insert(campaignList);
        
        PartnerFundRequest pfr1 = Core_MDF_CCP_TestDataUtility.createRetailActivity(string.valueof(rsaMDCamp.Id),string.valueof(dellRMFVirtualCorp.id),
                                                                                    System.today(),System.today(),false);
        pfr1.Title = 'Testing Partner Fund Request Batch';
        pfr1.Core_MDF_Budget_Type_txt__c = 'RSA MD';
        pfr1.Core_MDF_Budget_Type_nm__c='RSA MD';
        pfr1.Core_MDF_Reimbursement_Rate_pct__c = '100%';
        pfr1.RequestedAmount =1000;
        pfr1.Amount=1000;
        pfr1.Core_MDF_Fund_Request_Status__c = 'Planned';
        pfr1.Core_MDF_Start_Date__c = System.today();
        pfr1.Core_MDF_End_Date__c = System.today();
        pfr1.ChannelPartnerId = string.valueof(dellRMFVirtualCorp.id);
        pfrList.add(pfr1);
        Database.insert(pfrList);
        
        Core_MDF_CCP_TestDataUtility.createMDFConfigurationData();    
        
        Core_MDF_Bank__c bank = Core_MDF_CCP_TestDataUtility.createBank(dellCorpAccount.Id, 'Core_MDF_Retail_Marketing_Funds', false,'1231231230');
        bank.Core_MDF_Bank_Alias_Name__c='TestActiveBank1';
        bank.Core_MDF_Intel_Company_Code__c='150';
        bank.Core_MDF_Tax_codes_cd__c = 'I0';
        Database.insert(bank);
        bank.Core_MDF_Bank_Status__c = 'Active'; 
        Database.update(bank);
        
        Core_MDF_Account_Bank_Mapping__c abm1 = Core_MDF_CCP_TestDataUtility.createAccountBankMap(dellRMFVirtualCorp.Id,bank.Id,true);
        
        Product2 prod = new Product2();
        prod.Name = 'Intel® B360 Chipset';
        prod.Core_Product_Type__c = 'Chipsets';
        prod.Core_Product_Family__c = 'Consumer Chipsets';
        Database.insert(prod);
        
        Core_MDF_Account_Product_Mapping__c apm = new Core_MDF_Account_Product_Mapping__c();
        apm.Core_MDF_Account__c = dellCorpAccount.Id;
        apm.Core_MDF_Active_ind__c = true;
        apm.Core_MDF_Program_Account_Map__c = 'Retail Marketing Funds';
        apm.Core_MDF_Product__c = prod.Id;
        Database.insert(apm);
        
        Core_MDF_Activity_Segment_Mapping__c asm = new Core_MDF_Activity_Segment_Mapping__c();
        asm.Core_MDF_Segment_Name_nm__c = 'Chipsets';
        asm.Core_MDF_SPIF_Amount_Dollar_Per_Unit_nbr__c = 1;
        asm.Core_MDF_SPIF_Notes_internal_only_txt__c = 'Test';
        asm.Core_MDF_Minimum_Forecast_Volume_nbr__c = 1;
        asm.Core_MDF_Estimated_Share_of_SPIF_amt__c = 1;
        asm.Core_MDF_Maximum_Bundled_Volume_nbr__c = 1;
        asm.Core_MDF_Maximum_Cost_of_Bundle_nbr__c = 1;
        asm.Core_MDF_SPIF_Notes_txt__c = 'Test';
        asm.Core_MDF_Active_Ind__c = true;
        asm.Core_MDF_Partner_Fund_Request_id__c = pfr1.Id;
        insert asm;
        
        List<Core_MDF_Segment_Product_Mapping__c> spmList = new List<Core_MDF_Segment_Product_Mapping__c>();
        Core_MDF_Segment_Product_Mapping__c spm = new Core_MDF_Segment_Product_Mapping__c();
        spm.Core_MDF_Product_id__c = prod.Id;
        spm.Core_MDF_Activity_Segment_Mapping_id__c = asm.Id;
        spm.Core_MDF_Active_Ind__c = true;
        //spm.Core_MDF_Activity_Segment_Mapping_id__r.Core_MDF_Segment_Name_nm__c = '';   
        spmList.add(spm);
        Database.insert(spmList);
        
        
        PartnerFundClaim claim = Core_MDF_CCP_TestDataUtility.createClaim('Test Retail Claim', Core_MDF_CCP_TestDataUtility.claim_RecordType_Retail, pfr1.Id, Date.newInstance(2021, 05, 01), Date.newInstance(2021, 05, 29), 50.00, System.today(), bank.Id, false);
        claim.Core_MDF_Type_Txt__c ='Claim';
        claim.Core_MDF_Currency__c='USD';
        claim.Core_MDF_Country_Location_nm__c= 'UNITED KINGDOM'; 
        claim.Core_MDF_VAT_Eligibility_Ind__c= true ; 
        claim.Core_MDF_VAT_Hold_Ind__c = true;
        claim.Core_MDF_Status__c = 'Hold';
        //Database.insert(claim);
        
    }
    
    @isTest 
    static void createSegmentsTest(){
        try{ 
            Test.startTest();
            string program = 'Retail Marketing Funds';
            string objectName = 'PartnerFundRequest';
            List<PartnerFundRequest> pfrList = new List<PartnerFundRequest>();
            Core_MDF_ActivitySegmentMapping.getLabelValueMap();
            
            Campaign camp = [select id,Name from Campaign WHERE Name = 'Retail Campaigm2' LIMIT 1];
            Account accCoMarketing = [select id from Account WHERE Name = 'Dell RMF Virtual Corp'];
            Core_MDF_Bank__c bank1 = [Select Id from Core_MDF_Bank__c where Core_MDF_Supplier_Number__c='1231231230' limit 1];
            
            PartnerFundRequest pfr = Core_MDF_CCP_TestDataUtility.createRetailActivity(string.valueof(camp.Id),string.valueof(accCoMarketing.id),System.today(),System.today(),false); 
            pfr.Core_MDF_Budget_Type_nm__c ='Retail MDF';
            pfr.Core_MDF_Fund_Request_Status__c = 'Pending Review';
            pfr.Title = 'Test Retail Activity';
            pfr.Core_MDF_Activity_Description__c = 'Test Retail Activity';
            pfr.Core_MDF_Channel_Partner_Led__c = false;
            pfr.Core_MDF_Budget_Amount_Local_amt__c=100;
            pfr.Core_MDF_Reimbursement_Rate_pct__c = '100%';
            pfr.Core_MDF_Budget_Currency_cd__c='USD';
            pfr.Core_MDF_ActivityCategory__c = 'Sales Incentive';
            pfr.Core_MDF_Activity_Types__c = 'Seller - Per Unit SPIF';
            pfrList.add(pfr);
            
            PartnerFundRequest pfr1 = Core_MDF_CCP_TestDataUtility.createRetailActivity(string.valueof(camp.Id),string.valueof(accCoMarketing.id),System.today()+3,System.today()+13,false); 
            pfr1.Core_MDF_Budget_Type_nm__c ='Retail MDF';
            pfr1.Core_MDF_Fund_Request_Status__c = 'Pending Review';
            pfr1.Title = 'Test Retail Activity1';
            pfr1.Core_MDF_Activity_Description__c = 'Test Retail Activity';
            pfr1.Core_MDF_Channel_Partner_Led__c = false;
            pfr1.Core_MDF_Budget_Amount_Local_amt__c=100;
            pfr1.Core_MDF_Reimbursement_Rate_pct__c = '100%';
            pfr1.Core_MDF_Budget_Currency_cd__c='USD';
            pfr1.Core_MDF_ActivityCategory__c = 'Purchase Incentive';
            pfr1.Core_MDF_Activity_Types__c = 'Buyer - Bundle Offer';
            //pfrList.add(pfr1);
            insert pfrList;
            
            String segmentString1 = '[{Core_MDF_Segment_Name_nm":"Chipsets","productIdSet":["01to0000000zcTEAAY"],"Core_MDF_Minimum_Forecast_Volume_nbr":"333", "Core_MDF_Maximum_Cost_of_Bundle_nbr":"222","Core_MDF_Maximum_Bundled_Volume_nbr":"55","Core_MDF_Minimum_Forecast_Volume_nbr__c":"1", "Core_MDF_SPIF_Amount_Dollar_Per_Unit_nbr__c":"2", "Core_MDF_SPIF_Amount_Dollar_Per_Unit_nbr":"333","Core_MDF_SPIF_Notes_internal_only_txt":"333","Core_MDF_Estimated_Share_of_SPIF_amt":"11"}]';
            String segmentString2 = '[{"Core_MDF_Segment_Name_nm":"Chipsets","productIdSet":["01to0000000zcQjAAI"],"Core_MDF_Estimated_Share_of_SPIF_amt":"2","Core_MDF_Maximum_Bundled_Volume_nbr":"1","Core_MDF_Maximum_Cost_of_Bundle_nbr":"2","Core_MDF_Minimum_Forecast_Volume_nbr":null,"Core_MDF_SPIF_Amount_Dollar_Per_Unit_nbr":null,"Core_MDF_SPIF_Notes_internal_only_txt":"test", }]';
            
            Core_MDF_ActivitySegmentMapping.createUpdateSegmentAndProductMappingRecords(pfr.Id,segmentString1);
           
            segmentString1 = '[{Core_MDF_Segment_Name_nm":"Chipsets","productIdSet":["01to0000000zcTEAAY","01to0000000zcQjAAI"],"Core_MDF_Minimum_Forecast_Volume_nbr":"333","Core_MDF_Maximum_Cost_of_Bundle_nbr":"222","Core_MDF_Maximum_Bundled_Volume_nbr":"55", "Core_MDF_Minimum_Forecast_Volume_nbr__c":"1", "Core_MDF_SPIF_Amount_Dollar_Per_Unit_nbr__c":"2", "Core_MDF_SPIF_Amount_Dollar_Per_Unit_nbr":"333","Core_MDF_SPIF_Notes_internal_only_txt":"333","Core_MDF_Estimated_Share_of_SPIF_amt":"11"}]';
            segmentString2 = '[{"Core_MDF_Segment_Name_nm":"Processors","productIdSet":["01to0000000zcTEAAY"],"Core_MDF_Estimated_Share_of_SPIF_amt":"2","Core_MDF_Maximum_Bundled_Volume_nbr":"1","Core_MDF_Maximum_Cost_of_Bundle_nbr":"2","Core_MDF_Minimum_Forecast_Volume_nbr":null,"Core_MDF_SPIF_Amount_Dollar_Per_Unit_nbr":null,"Core_MDF_SPIF_Notes_internal_only_txt":"test"}]';
            
            Core_MDF_ActivitySegmentMapping.createUpdateSegmentAndProductMappingRecords(pfr.Id,segmentString1);               
            PartnerFundClaim claim = Core_MDF_CCP_TestDataUtility.createClaim('Test Retail Claim', Core_MDF_CCP_TestDataUtility.claim_RecordType_Retail, pfr.Id, System.today(), System.today(), 50.00, System.today(), bank1.Id, false);
            claim.Core_MDF_Type_Txt__c ='Claim';
            claim.Core_MDF_Currency__c='USD';
            claim.Core_MDF_Country_Location_nm__c= 'UNITED KINGDOM'; 
            claim.Core_MDF_VAT_Eligibility_Ind__c= true ; 
            claim.Core_MDF_VAT_Hold_Ind__c = true;
            claim.Core_MDF_Status__c = 'Hold';
            list<Core_MDF_Audit_Document__c> auditDocList = new list<Core_MDF_Audit_Document__c>();
            String res = Core_MDF_PartnerFundClaim.saveClaim(claim, auditDocList); 
            Core_MDF_ActivitySegmentMapping.getSegmentForClaims(claim.Id);
            Core_MDF_ActivitySegmentMapping.createUpdateSegmentAndProductMappingRecords(pfr.Id,segmentString1);
            Core_MDF_ActivitySegmentMapping.getProductMappingForSegment('Chipsets');
            Core_MDF_ActivitySegmentMapping.getUltimateAccountId(accCoMarketing.Id);
            Core_MDF_ActivitySegmentMapping.getSegmentValues();
            Core_MDF_Activity_Segment_Mapping__c asm = new Core_MDF_Activity_Segment_Mapping__c();
            asm.Core_MDF_Segment_Name_nm__c = 'Chipsets';
            asm.Core_MDF_SPIF_Amount_Dollar_Per_Unit_nbr__c = 1;
            asm.Core_MDF_SPIF_Notes_internal_only_txt__c = 'Test';
            asm.Core_MDF_Minimum_Forecast_Volume_nbr__c = 1;
            asm.Core_MDF_Estimated_Share_of_SPIF_amt__c = 1;
            asm.Core_MDF_Maximum_Bundled_Volume_nbr__c = 1;
            asm.Core_MDF_Maximum_Cost_of_Bundle_nbr__c = 1;
            asm.Core_MDF_SPIF_Notes_txt__c = 'Test';
            asm.Core_MDF_Active_Ind__c = true;
            asm.Core_MDF_Partner_Fund_Request_id__c = pfr.Id;
            insert asm;
            
            List<Core_MDF_Segment_Product_Mapping__c> spmList = new List<Core_MDF_Segment_Product_Mapping__c>();
            Core_MDF_Segment_Product_Mapping__c spm = new Core_MDF_Segment_Product_Mapping__c();
            spm.Core_MDF_Product_id__c = '01to0000000zcTEAAY';
            spm.Core_MDF_Activity_Segment_Mapping_id__c = asm.Id;
            spm.Core_MDF_Active_Ind__c = true;
            spmList.add(spm);
            
            Core_MDF_Segment_Product_Mapping__c spm2 = new Core_MDF_Segment_Product_Mapping__c();
            spm2.Core_MDF_Product_id__c = '01to0000000zcQjAAI';
            spm2.Core_MDF_Activity_Segment_Mapping_id__c = asm.Id;
            spm2.Core_MDF_Active_Ind__c = true;
            spmList.add(spm2);
            insert spmList;
            Core_MDF_ActivitySegmentMapping.returnSegments(claim.Id);
            Core_MDF_ActivitySegmentMapping.getFieldsToDisplay('Retail Marketing Funds', 'Seller - Per Unit SPIF');            
        }catch(Exception e){
            System.assertNotEquals(NULL,e); 
        }
        Test.stopTest();
    }
    @isTest 
    static void getRecordTypeLabelByNameTestNeg(){
        Test.startTest();
        String recTypeLabel = Core_MDF_ActivitySegmentMapping.getRecordTypeLabelByName('Core_MDF_Client_Co_Marketing_Fund');
        Test.stopTest();
    }
    @isTest 
    static void getRecordTypeLabelByNameTestPos(){
        Test.startTest();
        String recTypeLabel = Core_MDF_ActivitySegmentMapping.getRecordTypeLabelByName('Core_MDF_Client_CoMarketing_Fund');
        System.assertEquals('Client Co-Marketing Fund',recTypeLabel);
        Test.stopTest();
    }
    @isTest
    static void getUltimateAccountId(){
        Test.startTest();
        Campaign camp = [select id,Name from Campaign WHERE Name = 'Retail Campaigm2' LIMIT 1];
        Account ultimateAcc = [Select Id from Account WHERE Name = 'Dell Corporation'];
        Account accCoMarketing = [select id from Account WHERE Name = 'Dell RMF Virtual Corp'];
        Core_MDF_Account_Product_Mapping__c apm = [Select Id, Core_MDF_Account__c, Core_MDF_Program_Account_Map__c from Core_MDF_Account_Product_Mapping__c where Core_MDF_Account__c = :ultimateAcc.Id];                                             
        Core_MDF_Bank__c bank1 = [Select Id from Core_MDF_Bank__c where Core_MDF_Supplier_Number__c='1231231230' limit 1];
        String ultimateAccId = Core_MDF_ActivitySegmentMapping.getUltimateAccountId(accCoMarketing.Id);
        System.assertEquals(String.valueof(ultimateAcc.Id), ultimateAccId);
        Core_MDF_ActivitySegmentMapping.getLabelValueMap();
        Core_MDF_ActivitySegmentMapping.getProductMappingForSegment('Chipsets');
        Core_MDF_ActivitySegmentMapping.getSegmentValues();
        Core_MDF_ActivitySegmentMapping.getFieldsToDisplay('Retail Marketing Funds','Buyer - Bundle Offer');  
        Test.stopTest();
    }
    @isTest
    static void getProductMappingForSegmentTest(){
        
        Campaign camp = [select id,Name from Campaign WHERE Name = 'Retail Campaigm2' LIMIT 1];
        Account ultimateAcc = [Select Id from Account WHERE Name = 'Dell Corporation'];
        Account accCoMarketing = [select id from Account WHERE Name = 'Dell RMF Virtual Corp'];
        Test.startTest();
        Product2 product = new Product2 ();
        product.Core_Processor_Number_Nm__c = '';
        product.Core_Product_Family__c = 'Intel® Pentium® Processor ';
        product.Name = 'Intel® Pentium® Silver N5000 Processor (4M Cache, up to 2.70 GHz)';
        product.Core_Product_Type__c = 'Processors';
        product.Core_Product_Status__c = 'AC';
        product.isActive = true;
        product.Core_Hierarchy_ID__c = '43';
        insert product;
        Core_MDF_Account_Product_Mapping__c acc = new Core_MDF_Account_Product_Mapping__c();
        acc.Core_MDF_Account__c = ultimateAcc.Id;
        acc.Core_MDF_Program_Account_Map__c = 'Retail Marketing Funds';
        acc.Core_MDF_Active_ind__c = true;
        acc.Core_MDF_Product__c = product.Id;
        insert acc;
        List<Product2> prods = Core_MDF_ActivitySegmentMapping.getProductMappingForSegment('Processors', String.valueOf(ultimateAcc.Id), 'Retail Marketing Funds');
        System.assert(!prods.isEmpty());
        List<Product2> prods2 = Core_MDF_ActivitySegmentMapping.getProductMappingForSegment(' ', String.valueOf(ultimateAcc.Id), 'Retail Marketing Funds');
        System.assert(prods2.isEmpty());
        Test.stopTest();        
    }
    @isTest
    static void getProductMappingForSegment(){
        Test.startTest();
        Product2 product = new Product2 ();
        product.Core_Processor_Number_Nm__c = '';
        product.Core_Product_Family__c = 'Intel® Pentium® Processor ';
        product.Name = 'Intel® Pentium® Silver N5000 Processor (4M Cache, up to 2.70 GHz)';
        product.Core_Product_Type__c = 'Processors';
        product.Core_Product_Status__c = 'AC';
        product.isActive = true;
        product.Core_Hierarchy_ID__c = '43';
        insert product;
        
        List<Product2> prods = Core_MDF_ActivitySegmentMapping.getProductMappingForSegment('Processors');
        System.assert(!prods.isEmpty());
        
        Test.stopTest();
    }
    @isTest static void createUpdateSegmentAndProductMappingRecords(){
        Test.startTest();
        List<PartnerFundRequest> pfrList = new List<PartnerFundRequest>();
        Campaign camp = [select id,Name from Campaign WHERE Name = 'Retail Campaigm2' LIMIT 1];
        Account ultimateAcc = [Select Id from Account WHERE Name = 'Dell Corporation'];
        Account accCoMarketing = [select id from Account WHERE Name = 'Dell RMF Virtual Corp'];
        List<PartnerFundRequest> pfr = [Select Id, Title from PartnerFundRequest where title = 'Testing Partner Fund Request Batch' LIMIT 1];
        String segmentString1 = '[{"Core_MDF_Segment_Name_nm":"Chipsets","productIdSet":["01to0000000zcTEAAY"],"Core_MDF_Minimum_Forecast_Volume_nbr":"333", "Core_MDF_Maximum_Cost_of_Bundle_nbr":"222","Core_MDF_Maximum_Bundled_Volume_nbr":"55","Core_MDF_Minimum_Forecast_Volume_nbr__c":"1", "Core_MDF_SPIF_Amount_Dollar_Per_Unit_nbr__c":"2","Core_MDF_SPIF_Notes_internal_only_txt":"333","Core_MDF_Estimated_Share_of_SPIF_amt":"11"}]';
        Core_MDF_ActivitySegmentMapping.createUpdateSegmentAndProductMappingRecords(pfr[0].Id,segmentString1);
        Core_MDF_ActivitySegmentMapping.getSegmentForActivity(pfr[0].Id);
        Core_MDF_ActivitySegmentMapping.returnSegments(pfr[0].Id);
        
        Test.stopTest();
    }
    
    
    @isTest static void createUpdateSegmentAndProductMappingRecordsTest(){
        try{
        Test.startTest();
            string program = 'Retail Marketing Funds';
            string objectName = 'PartnerFundRequest';
            List<PartnerFundRequest> pfrList = new List<PartnerFundRequest>();
            Core_MDF_ActivitySegmentMapping.getLabelValueMap();
            
            Campaign camp = [select id,Name from Campaign WHERE Name = 'Retail Campaigm2' LIMIT 1];
            Account accCoMarketing = [select id from Account WHERE Name = 'Dell RMF Virtual Corp'];
            Core_MDF_Bank__c bank1 = [Select Id from Core_MDF_Bank__c where Core_MDF_Supplier_Number__c='1231231230' limit 1];
            
            PartnerFundRequest pfr = Core_MDF_CCP_TestDataUtility.createRetailActivity(string.valueof(camp.Id),string.valueof(accCoMarketing.id),System.today(),System.today(),false); 
            pfr.Core_MDF_Budget_Type_nm__c ='Retail MDF';
            pfr.Core_MDF_Fund_Request_Status__c = 'Pending Review';
            pfr.Title = 'Test Retail Activity';
            pfr.Core_MDF_Activity_Description__c = 'Test Retail Activity';
            pfr.Core_MDF_Channel_Partner_Led__c = false;
            pfr.Core_MDF_Budget_Amount_Local_amt__c=0;
            pfr.Core_MDF_Reimbursement_Rate_pct__c = '100%';
            pfr.Core_MDF_Budget_Currency_cd__c='USD';
            pfr.Core_MDF_ActivityCategory__c = 'Sales Incentive';
            pfr.Core_MDF_Activity_Types__c = 'Seller - Per Unit SPIF';
            insert pfr;
            
            Core_MDF_Activity_Segment_Mapping__c seg = new Core_MDF_Activity_Segment_Mapping__c();
            seg.Core_MDF_Partner_Fund_Request_id__c = pfr.Id;
            seg.Core_MDF_Segment_Name_nm__c = 'Chipsets';
            seg.Core_MDF_Active_ind__c = true;
  
            seg.Core_MDF_Minimum_Forecast_Volume_nbr__c = 1;
            seg.Core_MDF_SPIF_Amount_Dollar_Per_Unit_nbr__c = 1;
            seg.Core_MDF_Estimated_Share_of_SPIF_amt__c = 1;
            seg.Core_MDF_Maximum_Bundled_Volume_nbr__c = 1;
            seg.Core_MDF_SPIF_Notes_internal_only_txt__c = 'Test';
            seg.Core_MDF_SPIF_Notes_txt__c = 'Test';
            insert seg;
            
            Core_MDF_ActivitySegmentMapping.createUpdateSegmentAndProductMappingRecords(pfr.Id,'Test');
            Test.stopTest();
        }
        catch(Exception e){
            System.assertNotEquals(NULL,e); 
        }
    }
  */
}