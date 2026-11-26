@isTest(SeeAllData=false)
public class Core_MDF_PFC_VAT_Test {
    private static final String ADMIN_USERNAME = 'core.mdf.pfc.vat.test.admin.' + UserInfo.getOrganizationId() + '@example.com';
    
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
                            'Core_MDF_CCP_Internal_Claim_Case_Reviewer_Manager',
                            'Core_MDF_CCP_External_Activity_Approver'
                            )]) {
            permissionSetMap.put(pSet.Name,pSet);
        }
         
     //   Profile sysAdminProfile = profileMap.get('System Administrator');
        
        User usrs = Core_MDF_CCP_TestDataUtility.createUser(false);
        usrs.Email = 'sysadmin@example.com';
        usrs.Username = ADMIN_USERNAME;
        usrs.LastName = 'System Adm';
        usrs.ProfileId = profileMap.get('System Administrator');
        usrs.isActive = true;
        database.insert(usrs);
        
  //       Profile ccpCoreProfile = profileMap.get('CCP - Core Access');
        PermissionSet clmCaseRevPS = permissionSetMap.get('Core_MDF_CCP_Internal_Claim_Case_Reviewer_Manager');
        User claimCase = Core_MDF_CCP_TestDataUtility.createUser(false);
        claimCase.LastName = 'TestClassClaimCaseReviewwerManager';
        claimCase.Email = 'clmcase@example.com';
        claimCase.ProfileId = profileMap.get('CCP - Core Access');
        insert claimCase;
        PermissionSetAssignment assignPermissionSetObjCCR = new PermissionSetAssignment();
        assignPermissionSetObjCCR.AssigneeId = claimCase.Id;
        assignPermissionSetObjCCR.PermissionSetId = clmCaseRevPS.Id;
        Database.insert(assignPermissionSetObjCCR);
        
        
        
        System.runAs(testUser){
            List<Core_Trigger_Executions__c> transactions = new List<Core_Trigger_Executions__c>();
            transactions.addAll(Core_MDF_CCP_TestDataUtility.byPassFeature(new List<String>{'Bypass_Duplicate_Budget_Check','Bypass_GeoBased_Budget_Sharing','Bypass_MDF_Budget_Access_Validation','Bypass_MDF_Budget_Status_Validation'}, true, false));       
            transactions.addAll(Core_MDF_CCP_TestDataUtility.byPassFeature(new List<String>{'Bypass_Allocation_Reservation','Bypass_GeoBased_Allocation_Sharing'}, true, false));   
            transactions.addAll(Core_MDF_CCP_TestDataUtility.byPassFeature(new List<String>{'Bypass_Duplicate_Bank_Check','Bypass_Bank_Internal_Sharing',
                        'Bypass_Bank_External_Sharing','Bypass_Bank_Program_InActivation_Check','Bypass_Bank_ABM_Sharing','BypassRetailMDFBudgetValidation'}, true, false));
            transactions.addAll(Core_MDF_CCP_TestDataUtility.byPassFeature(new List<String>{'Bypass_ABM_Internal_Sharing','Bypass_ABM_External_Sharing','Bypass_ABM_NodeGroup_Sharing'}, true, false));                 
            Database.insert(transactions);
            Core_MDF_Configuration__c config9 = new Core_MDF_Configuration__c();
            config9.Core_MDF_Value__c = 'Core_MDF_CCP_Internal_CSC_Claim_Submitter';
            config9.Name = 'CSC_CLAIM_SUBMITTER_CUSTOM_PERMISSION';
            insert config9;

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
            masterAcc.id, retailCP.Id , 200000 , System.today()-6 , System.today()+301 , false,'Retail MDF');
            retailBudget.IsIgnoreValidation = true;
            insert retailBudget;
            //retailBudget.Core_MDF_Budget_Status__c = 'Approved';
          ///  update retailBudget;
          //  retailBudget.Core_MDF_Budget_Status__c = 'Released';
          //  update retailBudget;
            
            //allocation
            PartnerFundAllocation allocation = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('Test Allocation New',retailBudget,masterAcc,99999.0,true);
         // PartnerFundAllocation allocation = [Select id, Amount,TotalApprovedFrs from PartnerFundAllocation where BudgetId = :retailBudget.Id];
            
            //allocation.Amount=99999;
            
            //update allocation;
           
           
                
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
           
        
            Campaign retailCampaign = Core_MDF_CCP_TestDataUtility.createCampaign('Test Retail Camp 1','Business','Intel® 10ᵗʰ Gen', 'MDF or both CMP & MDF',
                                                                     Core_MDF_CCP_TestDataUtility.campaign_RecordType_Retail, 
                                                                     'Retail_Marketing_Funds', System.today()-2,
                                                                     System.today()+100, 100000, 'Instore merchandise', 
                                                                     masterAcc.Id,'All-in-One Desktop', false);
        
            retailCampaign.RecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Core_MDF_Retail_Marketing_Funds').getRecordTypeId();
            retailCampaign.Core_MDF_Activity_Category_Type__c =null;
            retailCampaign.Core_MDF_Program__c = 'Retail Marketing Funds';
            retailCampaign.Core_MDF_Reimbursement_Rate__c='100%';
            retailCampaign.Core_MDF_Technology__c = 'Wifi6';
            retailCampaign.Core_MDF_Budget_Type_txt__c ='Retail MDF';
            retailCampaign.Core_MDF_Opal_Budget_Type_Txt__c = 'Retail MDF';
            //retailCampaign.Core_MDF_Program_Type__c = 'Non Opal';
            retailCampaign.Core_MDF_Budget_Amount_amt__c=100000;
            
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
            
            Core_MDF_Bank__Share bankshare = new Core_MDF_Bank__Share(UserOrGroupId = claimCase.Id, AccessLevel = 'Edit', parentId = bank.Id, RowCause = 'Manual');
            insert bankshare;
            insert new List<Core_MDF_Bank__Share>{
                new Core_MDF_Bank__Share(UserOrGroupId = usrs.Id, AccessLevel = 'Edit', ParentId = bank.Id, RowCause = 'Manual'),
                new Core_MDF_Bank__Share(UserOrGroupId = usrs.Id, AccessLevel = 'Edit', ParentId = bank1.Id, RowCause = 'Manual')
            };
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
        
            Core_Trigger_Executions__c claimFunctionalityNameTriggerExecution6 = new Core_Trigger_Executions__c();
        claimFunctionalityNameTriggerExecution6.Core_Active__c = true;
        claimFunctionalityNameTriggerExecution6.Core_Class_Name__c = 'Core_MDF_PFCServiceHandler';
        claimFunctionalityNameTriggerExecution6.Core_Trigger_Events__c = 'after insert, after update';
        claimFunctionalityNameTriggerExecution6.Core_Object__c = 'PartnerFundClaim';
        claimFunctionalityNameTriggerExecution6.Name = 'checkAndSendClaimsForPIC';
        claimFunctionalityNameTriggerExecution6.Core_Description__c = 'description';
        executionClaimVat.add(claimFunctionalityNameTriggerExecution6);
                
            Database.insert(executionClaimVat); 
            Core_MDF_CCP_TestDataUtility.createMDFConfigurationData();
            
        }

        //User usr = [select id,email from User where email='ccfaccntmngr@example.com' limit 1];
PartnerMarketingBudget budget1 = [Select id,TotalAllocatedAmount from PartnerMarketingBudget where Title = 'TestBudgetData1'];
            
        PartnerFundAllocation allocation1 = [Select id, Amount from PartnerFundAllocation where BudgetId = :budget1.Id];
        PartnerFundRequest pfr = new PartnerFundRequest();
        //Test.startTest(); 
        System.runAs(usrs){
            Campaign camp = [select id,Name,Core_MDF_Budget_Amount_amt__c from Campaign WHERE Name = 'Test Retail Camp 1' LIMIT 1];
            Account accCoMarketing = [select id from Account WHERE Name = 'Test Master Account'];
            pfr = Core_MDF_CCP_TestDataUtility.insertPartnerFundRequest(string.valueof(camp.id),Core_MDF_CCP_TestDataUtility.partnerFund_RecordType_Retail,string.valueof(accCoMarketing.id),null,null,'UNITED KINGDOM','Business','All-in-One Desktop','Intel® 10ᵗʰ Gen','Broadcast (Pre-2025)','Television','Draft',false);
            pfr.Core_MDF_Fund_Request_Status__c = 'Pending Review';
            pfr.Title = 'Test Retail Activity';
            pfr.Core_MDF_Activity_Description__c = 'Test Retail Activity';
            pfr.Core_MDF_Budget_Type_nm__c ='Retail MDF';
            pfr.Core_MDF_Channel_Partner_Led__c = false;
            pfr.Core_MDF_Budget_Amount_Local_amt__c=10;
            pfr.Core_MDF_Budget_Currency_cd__c='USD';
            pfr.Core_MDF_Estimated_Ad_Size_nbr__c=1;
            pfr.Core_MDF_Magazine_Newspaper_txt__c='Magazine';
            pfr.Core_MDF_Start_Date__c = System.today()-1;
            pfr.Core_MDF_End_Date__c = System.today()+4;
            pfr.Core_MDF_Reimbursement_Rate_pct__c='100%'; 
            pfr.Core_MDF_Reimbursement_Rate_txt__c='100%';
            pfr.Core_MDF_Budget_Type_nm__c = 'Retail MDF';
            pfr.BudgetId = budget1.Id;
            pfr.AllocationId = allocation1.Id;
            pfr.status = 'Approved';
            pfr.Core_MDF_Fund_Request_Status__c = 'Planned';
            pfr.Amount=1;
            insert pfr;
            
            PartnerFundRequestShare pfrShare = new  PartnerFundRequestShare(UserOrGroupId = claimCase.Id, AccessLevel = 'Edit', parentId = pfr.Id, RowCause = 'Manual');
            insert pfrShare;
       }
        Test.stopTest();        
    }
    @isTest
    static void testRetailMDFVATInvoiceFileValidate()
    {
        
        User sysAdminUser = [SELECT Id, Email FROM User WHERE Username = :ADMIN_USERNAME];
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
            claim1.Core_MDF_VAT_Opt_In__c = 'Service Invoice to Intel (VAT may apply)';
            claim1.Core_MDF_VAT_Eligibility_Ind__c= true ; 
            claim1.Core_MDF_VAT_Hold_Ind__c = true;
            claim1.Core_MDF_Status__c = 'Hold';
            claim1.Core_MDF_Processing_Preference_nm__c='Settle, then get paid';
            list<Core_MDF_Audit_Document__c> auditDocList = new list<Core_MDF_Audit_Document__c>(); 
            //String amt5='{\"totalAmountLocal\" :100,\"costNotReimbursable\":0,\"taxesLocal\":0}';
            //Core_MDF_PartnerFundClaim.ClaimWrap res = new Core_MDF_PartnerFundClaim.ClaimWrap();
       //res = Core_MDF_PartnerFundClaim.saveClaim(claim1, auditDocList,amt5);
       insert claim1;

            
            //String res = Core_MDF_PartnerFundClaim.saveClaim(claim1, auditDocList);   

          

            claimins = [select id,Core_MDF_VAT_Eligibility_Ind__c,Core_MDF_Status__c,Core_MDF_Audit_Hold__c from PartnerFundClaim where id =: claim1.id limit 1];
          
            claimins.Core_MDF_Status__c = 'Hold';
            Database.update(claimins);
           
            // Read the VAT Invoice record
            vatInfo = [select id from Core_MDF_Claim_VAT_Info__c where Core_MDF_Claim_Id__c = :claim1.id limit 1];
            
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
       // Core_MDF_PFC_Cancel.cancelClaims(claimId); 
       
        }
        
        System.runAs(sysAdminUser){
            
            if(Core_MDF_PFC_Cancel.isClaimEligibleForCancel(claimins.Id).claimEligibleForCancel){
        test.stopTest();
                Core_MDF_PFC_Cancel.cancelClaimsWithReason(claimId, 'test');
        }
        }
        
        
        
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
        User sysAdminUser = [SELECT Id, Email FROM User WHERE Username = :ADMIN_USERNAME];
        User paymentUser = [SELECT Id,Email from User where Email='clmcase@example.com' limit 1];
        User extUser = [SELECT Id,Email from User where Email='test1@example.com' limit 1];
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
            claim1.Core_MDF_VAT_Opt_In__c = 'Service Invoice to Intel (VAT may apply)';
            claim1.Core_MDF_VAT_Eligibility_Ind__c= true ; 
            claim1.Core_MDF_VAT_Hold_Ind__c = true;
            claim1.Core_MDF_Status__c = 'Hold';
            claim1.Core_MDF_Processing_Preference_nm__c='Settle, then get paid';
            list<Core_MDF_Audit_Document__c> auditDocList = new list<Core_MDF_Audit_Document__c>();
           // Core_MDF_PartnerFundClaim.ClaimWrap res = new Core_MDF_PartnerFundClaim.ClaimWrap();
          //  String amt='{\"totalAmountLocal\" :100,\"costNotReimbursable\":0,\"taxesLocal\":0}';
      // res = Core_MDF_PartnerFundClaim.saveClaim(claim1, auditDocList,amt,null,false,null,false,null,false);
             Database.insert(claim1);
            //String res = Core_MDF_PartnerFundClaim.saveClaim(claim1, auditDocList);  

            claimins = [select id,Core_MDF_VAT_Eligibility_Ind__c,Core_MDF_Status__c,Core_MDF_Audit_Hold__c from PartnerFundClaim where id =: claim1.id limit 1];
            claimins.Core_MDF_Status__c = 'Hold';
            Database.update(claimins);
            
            // Read the VAT Invoice record
            vatInfo = [select id from Core_MDF_Claim_VAT_Info__c where Core_MDF_Claim_Id__c = : claim1.id limit 1];
            
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
            cdl.Visibility = 'AllUsers';
            insert cdl;

            PermissionSet claimSubmitterPermissionSet = [SELECT Id, Name FROM PermissionSet where Name = 'Core_MDF_CCP_External_Retail_Claim_Submitter'];        
            PermissionSetAssignment  psaExt = new PermissionSetAssignment(PermissionSetId = claimSubmitterPermissionSet.Id, AssigneeId = extUser.Id);
            insert psaExt;
            
            PermissionSet rmfUserPermissionSet = [SELECT Id, Name FROM PermissionSet where Name = 'Core_MDF_Retail_USER'];        
            PermissionSetAssignment  psaExt2 = new PermissionSetAssignment(PermissionSetId = rmfUserPermissionSet.Id, AssigneeId = extUser.Id);
            insert psaExt2;

            PartnerFundClaimShare shareRec = new PartnerFundClaimShare(ParentId = claim1.id , UserOrGroupId = extUser.Id, AccessLevel = 'Edit');
            insert shareRec;
            
            PermissionSet paymentAdminPermissionSet = [SELECT Id, Name FROM PermissionSet where Name = 'Core_MDF_CCP_Internal_Retail_Payment_Adm'];        
            PermissionSetAssignment  psa = new PermissionSetAssignment(PermissionSetId = paymentAdminPermissionSet.Id, AssigneeId = paymentUser.Id);
            insert psa;
            
            PermissionSet genericPermissionSet = [SELECT Id, Name FROM PermissionSet where Name = 'Core_MDF_CCP_Internal_Generic_Access'];        
            PermissionSetAssignment  psa3 = new PermissionSetAssignment(PermissionSetId = genericPermissionSet.Id, AssigneeId = paymentUser.Id);
            insert psa3;
           
        }

        System.runAs(extUser){
            vatInfo.Core_MDF_Status_Txt__c = 'Under Review';
            Database.update(vatInfo);
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
        User sysAdminUser = [SELECT Id, Email FROM User WHERE Username = :ADMIN_USERNAME];
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
            claim2.Core_MDF_VAT_Opt_In__c = 'Service Invoice to Intel (VAT may apply)';
            claim2.Core_MDF_VAT_Eligibility_Ind__c= true ; 
            claim2.Core_MDF_VAT_Hold_Ind__c = true;
            claim2.Core_MDF_Status__c = 'Hold';
            claim2.Core_MDF_Processing_Preference_nm__c='Settle, then get paid';
            list<Core_MDF_Audit_Document__c> auditDocList = new list<Core_MDF_Audit_Document__c>();
           // Core_MDF_PartnerFundClaim.ClaimWrap res = new Core_MDF_PartnerFundClaim.ClaimWrap();
            // String amt='{\"totalAmountLocal\" :100,\"costNotReimbursable\":0,\"taxesLocal\":0}';
       // res = Core_MDF_PartnerFundClaim.saveClaim(claim2, auditDocList,amt,null,false,null,false,null,false);
     Database.insert(claim2);
            //String res = Core_MDF_PartnerFundClaim.saveClaim(claim2, auditDocList);  
           
            claimins = [select id,Core_MDF_VAT_Eligibility_Ind__c,Core_MDF_Status__c,Core_MDF_Audit_Hold__c from PartnerFundClaim where id =: claim2.id limit 1];
            claimins.Core_MDF_Status__c = 'Hold';
            Database.update(claimins);


            // Read the VAT Invoice record
            vatInfo = [select id from Core_MDF_Claim_VAT_Info__c where Core_MDF_Claim_Id__c = : claim2.id limit 1];
            
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
        User sysAdminUser = [SELECT Id, Email FROM User WHERE Username = :ADMIN_USERNAME];
        User paymentUser = [SELECT Id,Email from User where Email='clmcase@example.com' limit 1];
        PartnerFundClaim claimins, claimins2;
        Core_MDF_Claim_VAT_Info__c vatInfo, vatInfo2;
        Case cs;
        List<PartnerFundClaim> pfclist;
        System.runAs(sysAdminUser)
        {
            test.startTest();
            Core_MDF_Bank__c bank1 = [Select Id from Core_MDF_Bank__c where Core_MDF_Bank_Alias_Name__c='Test' limit 1];
            PartnerFundRequest pfr = [Select Id,Title,Core_MDF_Reimbursement_Rate__c from PartnerFundRequest where Title = 'Test Retail Activity'];
            PartnerFundClaim claim2 = Core_MDF_CCP_TestDataUtility.createClaim('Test Retail Claim', Core_MDF_CCP_TestDataUtility.claim_RecordType_Retail, pfr.Id, System.today(), System.today(), 50.00, System.today(), bank1.Id, false);
            claim2.Core_MDF_Type_Txt__c ='Claim';
            claim2.Core_MDF_Currency__c='USD';
            claim2.Core_MDF_Country_Location_nm__c= 'UNITED KINGDOM'; 
            claim2.Core_MDF_VAT_Opt_In__c = 'Service Invoice to Intel (VAT may apply)';
            claim2.Core_MDF_VAT_Eligibility_Ind__c= true ; 
            claim2.Core_MDF_VAT_Hold_Ind__c = true;
            claim2.Core_MDF_Status__c = 'Hold';
            claim2.Core_MDF_Bank_Doc_Hold_Eligibility_Ind__c=true;
            claim2.Core_MDF_FlaggedForBankDocHold_Ind__c=false;
            claim2.Core_MDF_Processing_Preference_nm__c='Settle, then get paid';
            list<Core_MDF_Audit_Document__c> auditDocList = new list<Core_MDF_Audit_Document__c>();
          //  Core_MDF_PartnerFundClaim.ClaimWrap res = new Core_MDF_PartnerFundClaim.ClaimWrap();
          // String amt='{\"totalAmountLocal\" :100,\"costNotReimbursable\":0,\"taxesLocal\":0}';
     //  res = Core_MDF_PartnerFundClaim.saveClaim(claim2, auditDocList,amt,null,false,null,false,null,false);

            //String res = Core_MDF_PartnerFundClaim.saveClaim(claim2, auditDocList);  
           Database.insert(claim2);
            claimins = [select id,Core_MDF_VAT_Eligibility_Ind__c,Core_MDF_Status__c,Core_MDF_Audit_Hold__c from PartnerFundClaim where id =: claim2.id limit 1];
            claimins.Core_MDF_Status__c = 'Hold';
            Database.update(claimins);
            pfclist= new List<PartnerFundClaim>();
            pfclist.add(claim2);
             Core_MDF_Claim_VAT_Process.updateclaimVATInfo(pfclist);
            // Read the VAT Invoice record
            vatInfo = [select id from Core_MDF_Claim_VAT_Info__c where Core_MDF_Claim_Id__c = : claim2.id limit 1];
            
            vatInfo.Core_MDF_VAT_Invoice_Number_Txt__c = 'VATINV001';
            Database.update(vatInfo);
            // Creating Case
            Id caseAuditRecType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Core_MDF_Audit').getRecordTypeId();
            Account caseAcc = [Select id from Account where Name = 'Test Master Account'];
            cs = new Case();
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
          //  Core_MDF_PartnerFundClaim.ClaimWrap saveClaim1  = new Core_MDF_PartnerFundClaim.ClaimWrap();
     //  saveClaim1  = Core_MDF_PartnerFundClaim.saveClaim(claim2, auditDocList,amt,null,false,null,false,null,false);

            //String saveClaim1 = Core_MDF_PartnerFundClaim.saveClaim(claim2,auditDocList2);
               
        }
        
        User ccrmUser = [SELECT Id,Email FROM User WHERE LastName = 'TestClassClaimCaseReviewwerManager' LIMIT 1];
        CaseShare cshare = new CaseShare(UserOrGroupId = ccrmUser.Id, CaseAccessLevel = 'Edit', CaseId = cs.Id, RowCause = 'Manual' );
        insert cshare;
        system.runAs(ccrmUser){
            Case csNew = [Select RecordType.DeveloperName, Id from Case where id = :cs.Id];
            Id caseAuditClosedRecordId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Core_MDF_Audit').getRecordTypeId();
            csNew.Core_MDF_Adjustment_Amount_USD_Amt__c=50;
            csNew.Core_MDF_Claim_Conversion_Exchange_Rate__c = 1;
            csNew.Core_MDF_Reimbursement_Rate__c = 50;
            csNew.Core_MDF_Requested_Amount_USD_Amt__c = 50;
            csNew.Core_MDF_Review_Case_Status__c ='Review Completed';
            csNew.Core_MDF_Scorecard_Score_Nbr__c=0;
            csNew.Core_MDF_Checklist_Completion__c=100;
            
            Core_MDF_Claim_Case_Checklist__c checklistRecord = new Core_MDF_Claim_Case_Checklist__c();
            checklistRecord.Core_MDF_Case_ID__c = csNew.id;
            checklistRecord.Core_MDF_Checklist_Status__c = 'Non-Compliant';
            checklistRecord.Core_MDF_Impact_Amount__c = 20;
            checklistRecord.Core_MDF_Completion_Percentage__c = 100;
            insert checklistRecord;
            
            Database.update(csNew);
            Core_MDF_Vat_Utility.caseReviewResultupdatesonVAT(pfclist,'Compliant');
            system.assertEquals(csNew.Core_MDF_Review_Case_Status__c,'Review Completed');   
        }
         
    }

    /**Areefa**/
  @isTest
    static void testRetailClaimWithChangeInAmountAndBank()
    {
        User sysAdminUser = [SELECT Id, Email FROM User WHERE Username = :ADMIN_USERNAME]; 
        //User clmCaseUser = [SELECT Id,Email from User where Email='clmcase@example.com' limit 1];
        PartnerFundClaim claimins;
        Core_MDF_Claim_VAT_Info__c vatInfo,vatInfo1;
        boolean claimEligibleforVat = false;
        boolean updateVatInfo = false;
        //System.runAs(sysAdminUser)
        //{
            test.startTest();
            Core_MDF_Bank__c bank1 = [Select Id,Core_MDF_VAT_pct__c from Core_MDF_Bank__c where Core_MDF_Bank_Alias_Name__c='Test' limit 1];
            Core_MDF_Bank__c bank2 = [Select Id,Core_MDF_VAT_pct__c from Core_MDF_Bank__c where Core_MDF_Bank_Alias_Name__c='Test1' limit 1];
            PartnerFundRequest pfr = [Select Id,Title,Core_MDF_Reimbursement_Rate__c from PartnerFundRequest where Title = 'Test Retail Activity'];
            PartnerFundClaim claim1 = Core_MDF_CCP_TestDataUtility.createClaim('Test Claim101', Core_MDF_CCP_TestDataUtility.claim_RecordType_Retail, pfr.Id, System.today(), System.today(), 50.00, System.today(), bank1.Id, false);
            claim1.Core_MDF_Type_Txt__c ='Claim';
            claim1.Core_MDF_Currency__c='USD';
            claim1.Core_MDF_Country_Location_nm__c= 'UNITED KINGDOM';
            claim1.Core_MDF_To_Be_Audited_Ind__c=true;
            claim1.Core_MDF_VAT_Opt_In__c = 'Service Invoice to Intel (VAT may apply)';
            claim1.Core_MDF_VAT_Eligibility_Ind__c= true ; 
            claim1.Core_MDF_VAT_Hold_Ind__c = true;
            claim1.Core_MDF_Status__c = 'Hold';         
            claim1.Core_MDF_Processing_Preference_nm__c='Settle, then get paid';
            list<Core_MDF_Audit_Document__c> auditDocList = new list<Core_MDF_Audit_Document__c>(); 
          //  Core_MDF_PartnerFundClaim.ClaimWrap res = new Core_MDF_PartnerFundClaim.ClaimWrap();
          //  String amt='{\"totalAmountLocal\" :100,\"costNotReimbursable\":0,\"taxesLocal\":0}';
     //  res = Core_MDF_PartnerFundClaim.saveClaim(claim1, auditDocList,amt,null,false,null,false,null,false);
           Database.insert(claim1);
            //String res = Core_MDF_PartnerFundClaim.saveClaim(claim1, auditDocList);
            PartnerFundClaim pfc = [Select id,Core_MDF_To_Be_Audited_Ind__c,Core_MDF_Budget_Type_Options_Nm__c,Core_MDF_Program__c,Core_MDF_VAT_Eligibility_Ind__c,
                                          Core_MDF_Status__c,Core_MDF_VAT_Hold_Ind__c,Core_MDF_Country_Location_nm__c,Core_MDF_Bank__C 
                                    from PartnerFundClaim where Title = 'Test Claim101'];
                      
            //system.assertEquals(pfc.Core_MDF_VAT_Eligibility_Ind__c, true);
            //system.assertEquals(pfc.Core_MDF_Status__c, 'Hold');
            //system.assertEquals(pfc.Core_MDF_VAT_Hold_Ind__c, true);  

            //change in vat amount should retrigger VAT process
            pfc.Core_MDF_Total_Invoice_Amount_Local__c= 51.00;
            database.update(pfc);
             Core_MDF_Claim_VAT_Info__c newVatRec = new Core_MDF_Claim_VAT_Info__c();
            newVatRec.Core_MDF_Claim_Id__c = pfc.Id;
            newVatRec.Core_MDF_Status_Txt__c = System.label.Core_MDF_Case_Status_Under_Review;
            insert newVatRec;
            // Read the VAT Invoice record
            vatInfo = [select id,Core_MDF_Status_Txt__c from Core_MDF_Claim_VAT_Info__c where Core_MDF_Claim_Id__c = : pfc.Id];
            
            system.assertEquals(vatInfo.Core_MDF_Status_Txt__c, System.label.Core_MDF_Case_Status_Under_Review);           
            
            pfc.Core_MDF_Bank__c=bank2.Id;
            database.update(pfc);
             Core_MDF_Claim_VAT_Info__c newVatRec2 = new Core_MDF_Claim_VAT_Info__c();
            newVatRec2.Core_MDF_Claim_Id__c = pfc.Id;
            insert newVatRec2;
            vatInfo1 = [select id,Core_MDF_Status_Txt__c from Core_MDF_Claim_VAT_Info__c where Core_MDF_Claim_Id__c = : pfc.Id limit 1];
            //system.assertEquals(vatInfo.Core_MDF_Status_Txt__c, 'Pending Documents'); 
            system.assertEquals(vatInfo1.Core_MDF_Status_Txt__c, 'Cancelled');
            
            PartnerFundClaim pfc2 = [Select id,Core_MDF_Program__c,Core_MDF_VAT_Eligibility_Ind__c,Core_MDF_Status__c,Core_MDF_VAT_Hold_Ind__c from PartnerFundClaim where Title = 'Test Claim101'];
            
            system.assertEquals(pfc.Core_MDF_VAT_Hold_Ind__c,true);
            
            test.stopTest(); 
            
            Core_MDF_PartnerFundClaim.ckeckProgramLEForVatOptIn('420',pfc.Core_MDF_Program__c);
            
        //}
        
    }
    //Claim Status to denied with no vat record.
  @isTest
    static void testClaimStatusToDenied()
    {
        User sysAdminUser = [SELECT Id, Email FROM User WHERE Username = :ADMIN_USERNAME];
        User paymentUser = [SELECT Id,Email from User where Email='clmcase@example.com' limit 1];
        PartnerFundClaim claimins, claimins2;
        Core_MDF_Claim_VAT_Info__c vatInfo, vatInfo2;
        Case cs;
        //System.runAs(sysAdminUser)
        //{
            test.startTest();
            Core_MDF_Bank__c bank1 = [Select Id from Core_MDF_Bank__c where Core_MDF_Bank_Alias_Name__c='Test' limit 1];
            PartnerFundRequest pfr = [Select Id,Title,Core_MDF_Reimbursement_Rate__c from PartnerFundRequest where Title = 'Test Retail Activity'];
            PartnerFundClaim claim2 = Core_MDF_CCP_TestDataUtility.createClaim('Test Retail Claim', Core_MDF_CCP_TestDataUtility.claim_RecordType_Retail, pfr.Id, System.today(), System.today(), 50.00, System.today(), bank1.Id, false);
            claim2.Core_MDF_Type_Txt__c ='Claim';
            claim2.Core_MDF_Currency__c='USD';
            claim2.Core_MDF_Country_Location_nm__c= 'UNITED KINGDOM'; 
            claim2.Core_MDF_VAT_Opt_In__c = 'Service Invoice to Intel (VAT may apply)';
            claim2.Core_MDF_Bank_Doc_Hold_Eligibility_Ind__c=true;
            claim2.Core_MDF_Bank_Doc_Hold_Ind__c=true;
            claim2.Core_MDF_Status__c = 'Hold';
            claim2.Core_MDF_Processing_Preference_nm__c='Settle, then get paid';
            list<Core_MDF_Audit_Document__c> auditDocList = new list<Core_MDF_Audit_Document__c>();
         //   Core_MDF_PartnerFundClaim.ClaimWrap res = new Core_MDF_PartnerFundClaim.ClaimWrap();
          //  String amt='{\"totalAmountLocal\" :100,\"costNotReimbursable\":0,\"taxesLocal\":0}';
     //  res = Core_MDF_PartnerFundClaim.saveClaim(claim2, auditDocList,amt,null,false,null,false,null,false);
             Database.insert(claim2);
            //String res = Core_MDF_PartnerFundClaim.saveClaim(claim2, auditDocList);  
           
            claimins = [select id,Core_MDF_VAT_Eligibility_Ind__c,Core_MDF_Status__c,Core_MDF_Audit_Hold__c from PartnerFundClaim where id =: claim2.id limit 1];
            claimins.Core_MDF_Status__c = 'Hold';
            Database.update(claimins);


            // Creating Case
            Id caseAuditRecType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Core_MDF_Audit').getRecordTypeId();
            Account caseAcc = [Select id from Account where Name = 'Test Master Account'];
            cs = new Case();
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
            String amt1='{\"totalAmountLocal\" :100,\"costNotReimbursable\":0,\"taxesLocal\":0}';
            Core_MDF_PartnerFundClaim.ClaimWrap saveClaim1 = new Core_MDF_PartnerFundClaim.ClaimWrap();
       saveClaim1 = Core_MDF_PartnerFundClaim.saveClaim(claim2, auditDocList,amt1,null,false,null,false,null,false);

            
        //}
            //String saveClaim1 = Core_MDF_PartnerFundClaim.saveClaim(claim2,auditDocList2);
           User ccrmUser = [SELECT Id,Email FROM User WHERE LastName = 'TestClassClaimCaseReviewwerManager' LIMIT 1];
        CaseShare cshare = new CaseShare(UserOrGroupId = ccrmUser.Id, CaseAccessLevel = 'Edit', CaseId = cs.Id, RowCause = 'Manual' );
        insert cshare;
        system.runAs(ccrmUser){
            Case csNew = [Select RecordType.DeveloperName,Core_MDF_Review_Case_Status__c,Id,Core_MDF_Status__c from Case where id = :cs.Id];
            Id caseAuditClosedRecordId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Core_MDF_Audit').getRecordTypeId();
            csNew.Core_MDF_Adjustment_Amount_USD_Amt__c=50;
            csNew.Core_MDF_Claim_Conversion_Exchange_Rate__c = 1;
            csNew.Core_MDF_Reimbursement_Rate__c = 50;
            csNew.Core_MDF_Requested_Amount_USD_Amt__c = 50;
            csNew.Core_MDF_Review_Case_Status__c ='Review Completed';
            csNew.Core_MDF_Scorecard_Score_Nbr__c=0;
            csNew.Core_MDF_Checklist_Completion__c=100;
            
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
    @isTest
    static void testcaseReviewResultupdatesonVAT2()
    {
        User sysAdminUser = [SELECT Id, Email FROM User WHERE Username = :ADMIN_USERNAME];
        User paymentUser = [SELECT Id,Email from User where Email='clmcase@example.com' limit 1];
        PartnerFundClaim claimins, claimins2;
        Core_MDF_Claim_VAT_Info__c vatInfo, vatInfo2;
        Case cs;
        List<PartnerFundClaim> pfclist;
        System.runAs(sysAdminUser)
        {
            test.startTest();            
            Core_MDF_Bank__c bank1 = [Select Id from Core_MDF_Bank__c where Core_MDF_Bank_Alias_Name__c='Test' limit 1];
            PartnerFundRequest pfr = [Select Id,Title,Core_MDF_Reimbursement_Rate__c from PartnerFundRequest where Title = 'Test Retail Activity'];
            PartnerFundClaim claim2 = Core_MDF_CCP_TestDataUtility.createClaim('Test Retail Claim', Core_MDF_CCP_TestDataUtility.claim_RecordType_Retail, pfr.Id, System.today(), System.today(), 50.00, System.today(), bank1.Id, false);
            claim2.Core_MDF_Type_Txt__c ='Claim';
            claim2.Core_MDF_Currency__c='USD';
            claim2.Core_MDF_Country_Location_nm__c= 'UNITED KINGDOM'; 
            claim2.Core_MDF_VAT_Opt_In__c = 'Service Invoice to Intel (VAT may apply)';
            claim2.Core_MDF_VAT_Eligibility_Ind__c= true ; 
            claim2.Core_MDF_VAT_Hold_Ind__c = true;
            claim2.Core_MDF_Status__c = 'Hold';
            claim2.Core_MDF_Processing_Preference_nm__c='Settle, then get paid';
            list<Core_MDF_Audit_Document__c> auditDocList = new list<Core_MDF_Audit_Document__c>();
          //  String amt='{\"totalAmountLocal\" :100,\"costNotReimbursable\":0,\"taxesLocal\":0}';
         //   Core_MDF_PartnerFundClaim.ClaimWrap res = new Core_MDF_PartnerFundClaim.ClaimWrap();
     //  res = Core_MDF_PartnerFundClaim.saveClaim(claim2, auditDocList,amt,null,false,null,false,null,false);
          Database.insert(claim2);
            //String res = Core_MDF_PartnerFundClaim.saveClaim(claim2, auditDocList);  
           
            claimins = [select id,Core_MDF_VAT_Eligibility_Ind__c,Core_MDF_Status__c,Core_MDF_Audit_Hold__c from PartnerFundClaim where id =: claim2.id limit 1];
            claimins.Core_MDF_Status__c = 'Hold';
            Database.update(claimins);
            pfclist= new List<PartnerFundClaim>();
            pfclist.add(claim2);
             Core_MDF_Claim_VAT_Process.updateclaimVATInfo(pfclist);
            
            // Read the VAT Invoice record
            vatInfo = [select id from Core_MDF_Claim_VAT_Info__c where Core_MDF_Claim_Id__c = : claim2.id limit 1];
            
            vatInfo.Core_MDF_VAT_Invoice_Number_Txt__c = 'VATINV001';
            Database.update(vatInfo);
            // Creating Case
            Id caseAuditRecType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Core_MDF_Audit').getRecordTypeId();
            Account caseAcc = [Select id from Account where Name = 'Test Master Account'];
            cs = new Case();
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
            String amt2='{\"totalAmountLocal\" :100,\"costNotReimbursable\":0,\"taxesLocal\":0}';
            Core_MDF_PartnerFundClaim.ClaimWrap saveClaim1 = new Core_MDF_PartnerFundClaim.ClaimWrap();
       saveClaim1 = Core_MDF_PartnerFundClaim.saveClaim(claim2, auditDocList,amt2,null,false,null,false,null,false);
      
          }
            //String saveClaim1 = Core_MDF_PartnerFundClaim.saveClaim(claim2,auditDocList2);
            User ccrmUser = [SELECT Id,Email FROM User WHERE LastName = 'TestClassClaimCaseReviewwerManager' LIMIT 1];
            CaseShare cshare = new CaseShare(UserOrGroupId = ccrmUser.Id, CaseAccessLevel = 'Edit', CaseId = cs.Id, RowCause = 'Manual' );
            insert cshare;
            system.runAs(ccrmUser){
            Case csNew = [Select RecordType.DeveloperName, Id from Case where id = :cs.Id];
            Id caseAuditClosedRecordId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Core_MDF_Audit').getRecordTypeId();
            csNew.Core_MDF_Adjustment_Amount_USD_Amt__c=50;
            csNew.Core_MDF_Claim_Conversion_Exchange_Rate__c = 1;
            csNew.Core_MDF_Reimbursement_Rate__c = 50;
            csNew.Core_MDF_Requested_Amount_USD_Amt__c = 50;
            csNew.Core_MDF_Review_Case_Status__c ='Review Completed';
            csNew.Core_MDF_Scorecard_Score_Nbr__c=0;
            csNew.Core_MDF_Checklist_Completion__c=100;
            
            Core_MDF_Claim_Case_Checklist__c checklistRecord = new Core_MDF_Claim_Case_Checklist__c();
                checklistRecord.Core_MDF_Case_ID__c = csNew.id;
                checklistRecord.Core_MDF_Checklist_Status__c = 'Non-Compliant';
                checklistRecord.Core_MDF_Impact_Amount__c = 20;
                checklistRecord.Core_MDF_Completion_Percentage__c = 100;
                insert checklistRecord;
               
            Database.update(csNew);
                test.stopTest();
            Core_MDF_Vat_Utility.caseReviewResultupdatesonVAT(pfclist,'Denied');
          system.assertEquals(csNew.Core_MDF_Review_Case_Status__c,'Review Completed');
            }
    }
    @isTest
    static void testcaseReviewResultupdatesonVAT3()
    {
        User sysAdminUser = [SELECT Id, Email FROM User WHERE Username = :ADMIN_USERNAME];
        User paymentUser = [SELECT Id,Email from User where Email='clmcase@example.com' limit 1];
        PartnerFundClaim claimins, claimins2;
        Core_MDF_Claim_VAT_Info__c vatInfo, vatInfo2;
        Case cs ;
        List<PartnerFundClaim> pfclist;
        System.runAs(sysAdminUser)
        {
            test.startTest();
            Core_MDF_Bank__c bank1 = [Select Id from Core_MDF_Bank__c where Core_MDF_Bank_Alias_Name__c='Test' limit 1];
            PartnerFundRequest pfr = [Select Id,Title,Core_MDF_Reimbursement_Rate__c from PartnerFundRequest where Title = 'Test Retail Activity'];
            PartnerFundClaim claim2 = Core_MDF_CCP_TestDataUtility.createClaim('Test Retail Claim', Core_MDF_CCP_TestDataUtility.claim_RecordType_Retail, pfr.Id, System.today(), System.today(), 50.00, System.today(), bank1.Id, false);
            claim2.Core_MDF_Type_Txt__c ='Claim';
            claim2.Core_MDF_Currency__c='USD';
            claim2.Core_MDF_Country_Location_nm__c= 'UNITED KINGDOM'; 
            claim2.Core_MDF_VAT_Opt_In__c = 'Service Invoice to Intel (VAT may apply)';
            claim2.Core_MDF_VAT_Eligibility_Ind__c= true ; 
            claim2.Core_MDF_VAT_Hold_Ind__c = true;
            claim2.Core_MDF_Status__c = 'Hold';
            claim2.Core_MDF_Processing_Preference_nm__c='Settle, then get paid';
            list<Core_MDF_Audit_Document__c> auditDocList = new list<Core_MDF_Audit_Document__c>();
           // String amt3='{\"totalAmountLocal\" :100,\"costNotReimbursable\":0,\"taxesLocal\":0}';
          //  Core_MDF_PartnerFundClaim.ClaimWrap res = new Core_MDF_PartnerFundClaim.ClaimWrap();
     //  res = Core_MDF_PartnerFundClaim.saveClaim(claim2, auditDocList,amt3,null,false,null,false,null,false);
       Database.insert(claim2);
            //String res = Core_MDF_PartnerFundClaim.saveClaim(claim2, auditDocList);  
           
            claimins = [select id,Core_MDF_VAT_Eligibility_Ind__c,Core_MDF_Status__c,Core_MDF_Audit_Hold__c from PartnerFundClaim where id =: claim2.id limit 1];
            claimins.Core_MDF_Status__c = 'Hold';
            Database.update(claimins);
            pfclist= new List<PartnerFundClaim>();
            pfclist.add(claim2);
             Core_MDF_Claim_VAT_Process.updateclaimVATInfo(pfclist);
            // Read the VAT Invoice record
            vatInfo = [select id from Core_MDF_Claim_VAT_Info__c where Core_MDF_Claim_Id__c = : claim2.id limit 1];
            
            vatInfo.Core_MDF_VAT_Invoice_Number_Txt__c = 'VATINV001';
            Database.update(vatInfo);
            // Creating Case
            Id caseAuditRecType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Core_MDF_Audit').getRecordTypeId();
            Account caseAcc = [Select id from Account where Name = 'Test Master Account'];
            cs = new Case();
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
            String amt4='{\"totalAmountLocal\" :100,\"costNotReimbursable\":0,\"taxesLocal\":0}';
            Core_MDF_PartnerFundClaim.ClaimWrap saveClaim1 = new Core_MDF_PartnerFundClaim.ClaimWrap();
       saveClaim1 = Core_MDF_PartnerFundClaim.saveClaim(claim2, auditDocList,amt4,null,false,null,false,null,false);

        }
        //String saveClaim1 = Core_MDF_PartnerFundClaim.saveClaim(claim2,auditDocList2);
        User ccrmUser = [SELECT Id,Email FROM User WHERE LastName = 'TestClassClaimCaseReviewwerManager' LIMIT 1];
        CaseShare cshare = new CaseShare(UserOrGroupId = ccrmUser.Id, CaseAccessLevel = 'Edit', CaseId = cs.Id, RowCause = 'Manual' );
        insert cshare;
        system.runAs(ccrmUser){
            Case csNew = [Select RecordType.DeveloperName, Id from Case where id = :cs.Id];
            Id caseAuditClosedRecordId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Core_MDF_Audit').getRecordTypeId();
            csNew.Core_MDF_Adjustment_Amount_USD_Amt__c=50;
            csNew.Core_MDF_Claim_Conversion_Exchange_Rate__c = 1;
            csNew.Core_MDF_Reimbursement_Rate__c = 50;
            csNew.Core_MDF_Requested_Amount_USD_Amt__c = 50;
            csNew.Core_MDF_Review_Case_Status__c ='Review Completed';
            csNew.Core_MDF_Checklist_Completion__c=100;
            csNew.Core_MDF_Scorecard_Score_Nbr__c=0;
            
            Core_MDF_Claim_Case_Checklist__c checklistRecord = new Core_MDF_Claim_Case_Checklist__c();
            checklistRecord.Core_MDF_Case_ID__c = csNew.id;
            checklistRecord.Core_MDF_Checklist_Status__c = 'Non-Compliant';
            checklistRecord.Core_MDF_Impact_Amount__c = 20;
            checklistRecord.Core_MDF_Completion_Percentage__c = 100;
            insert checklistRecord;
            
            Database.update(csNew);
            
            List<Core_MDF_Vat_Utility.CaseReviewResultParams> paramsList = new List<Core_MDF_Vat_Utility.CaseReviewResultParams>();
            Core_MDF_Vat_Utility.CaseReviewResultParams params = new Core_MDF_Vat_Utility.CaseReviewResultParams();
            params.inputClaims = pfclist;
            params.action = 'Compliant';
            paramsList.add(params);
            
            Core_MDF_Vat_Utility.invokeCaseReviewResultupdatesonVAT(paramsList);
            system.assertEquals(csNew.Core_MDF_Review_Case_Status__c,'Review Completed');
        }
    }

    @isTest
    static void testIsClaimEligibleForVATWhenNotOptedIn() {
        PartnerFundClaim claim = new PartnerFundClaim();
        claim.Core_MDF_VAT_Opt_In__c = 'Not Applicable';
        claim.Core_MDF_VAT_Eligibility_Ind__c = true;

        Test.startTest();
        Core_MDF_Claim_VAT_Process.isClaimEligibleForVAT(new List<PartnerFundClaim>{ claim });
        Test.stopTest();

        System.assertEquals(false, claim.Core_MDF_VAT_Eligibility_Ind__c);
    }

    @isTest
    static void testCreateUpdateVATRecordSkipsSuperClaim() {
        PartnerFundClaim superClaim = new PartnerFundClaim();
        superClaim.Core_MDF_Has_Sub_Claims_Ind__c = true;
        superClaim.Core_MDF_VAT_Eligibility_Ind__c = true;

        Test.startTest();
        Core_MDF_Claim_VAT_Process.createUpdateVATRecord(new List<PartnerFundClaim>{ superClaim }, new Map<Id, PartnerFundClaim>(), new Map<Id, PartnerFundClaim>());
        Test.stopTest();

        System.assertEquals(true, superClaim.Core_MDF_Has_Sub_Claims_Ind__c);
    }

    @isTest
    static void testGetVATCancellationOptionsWithoutPermission() {
        User externalUser = [SELECT Id FROM User WHERE Email = 'test1@example.com' LIMIT 1];

        System.runAs(externalUser) {
            Test.startTest();
            Core_MDF_Claim_VAT_Process.VATCancellationDecision result = Core_MDF_Claim_VAT_Process.getVATCancellationOptions(null);
            Test.stopTest();

            System.assertEquals(false, result.isEligible);
            System.assertEquals(false, result.isSuperClaim);
            System.assertEquals(0, result.subClaims.size());
        }
    }

    @isTest
    static void testCancelClaimVATWithoutPermission() {
        User externalUser = [SELECT Id FROM User WHERE Email = 'test1@example.com' LIMIT 1];

        System.runAs(externalUser) {
            Boolean exceptionThrown = false;

            Test.startTest();
            try {
                Core_MDF_Claim_VAT_Process.cancelClaimVAT(null);
            } catch (AuraHandledException ex) {
                exceptionThrown = true;
            }
            Test.stopTest();

            System.assertEquals(true, exceptionThrown);
        }
    }

    @isTest
    static void testCancelSelectedSubClaimVATWithoutPermission() {
        User externalUser = [SELECT Id FROM User WHERE Email = 'test1@example.com' LIMIT 1];

        System.runAs(externalUser) {
            Boolean exceptionThrown = false;

            Test.startTest();
            try {
                Core_MDF_Claim_VAT_Process.cancelSelectedSubClaimVAT(null, new List<Id>());
            } catch (AuraHandledException ex) {
                exceptionThrown = true;
            }
            Test.stopTest();

            System.assertEquals(true, exceptionThrown);
        }
    }
    private static void assignCancelVATPermission(User targetUser) {
        CustomPermission cancelPermission = [SELECT Id FROM CustomPermission WHERE DeveloperName = 'Core_MDF_Cancel_VAT_Claim' LIMIT 1];

        Set<Id> permissionSetIds = new Set<Id>();
        for (SetupEntityAccess accessRecord : [SELECT ParentId FROM SetupEntityAccess WHERE SetupEntityId = :cancelPermission.Id]) {
            permissionSetIds.add(accessRecord.ParentId);
        }

        List<PermissionSet> assignablePermissionSets = [SELECT Id FROM PermissionSet WHERE Id IN :permissionSetIds AND IsOwnedByProfile = false LIMIT 1];
        System.assert(!assignablePermissionSets.isEmpty());
        PermissionSetAssignment assignmentRecord = new PermissionSetAssignment(AssigneeId = targetUser.Id, PermissionSetId = assignablePermissionSets[0].Id);

        User currentUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(currentUser) {
            insert assignmentRecord;
        }
    }

    private static Id getVATCancellationRequest(Boolean outcomeBased) {
        PartnerFundRequest request = [SELECT Id, Core_MDF_Is_Outcome_Based_Ind__c FROM PartnerFundRequest WHERE Title = 'Test Retail Activity'LIMIT 1];
        if (outcomeBased && request.Core_MDF_Is_Outcome_Based_Ind__c != true) {
            TriggerHandler.bypass('Core_MDF_PartnerRequestTriggerHandler');
            request.Core_MDF_Is_Outcome_Based_Ind__c = true;
            update request;
            TriggerHandler.clearBypass('Core_MDF_PartnerRequestTriggerHandler');
        }
        return request.Id;
    }


    private static PartnerFundClaim createVATCancellationClaim(String claimTitle, Id parentClaimId, Boolean isSuperClaim, Id requestId) {
        Core_MDF_Bank__c testBank = [SELECT Id FROM Core_MDF_Bank__c WHERE Core_MDF_Bank_Alias_Name__c = 'Test' LIMIT 1];

        PartnerFundClaim claim = Core_MDF_CCP_TestDataUtility.createClaim(
            claimTitle,
            Core_MDF_CCP_TestDataUtility.claim_RecordType_Retail,
            requestId,
            System.today(),
            System.today(),
            50.00,
            System.today(),
            testBank.Id,
            false
        );

        claim.Core_MDF_Type_Txt__c = 'Claim';
        claim.Core_MDF_Currency__c = 'USD';
        claim.Core_MDF_Country_Location_nm__c = 'UNITED KINGDOM';
        claim.Core_MDF_VAT_Opt_In__c = Label.Core_MDF_nonTranslate_Service_Invoice_to_Intel;
        claim.Core_MDF_VAT_Eligibility_Ind__c = true;
        claim.Core_MDF_VAT_Hold_Ind__c = !isSuperClaim;
        claim.Core_MDF_Status__c = Label.Core_MDF_Status_Hold;
        claim.Core_MDF_Has_Sub_Claims_Ind__c = isSuperClaim;
        claim.Core_MDF_Processing_Preference_nm__c = 'Settle, then get paid';
        claim.Core_MDF_Requested_Reimbursement_Amt__c = 75;
        claim.Core_MDF_Reimbursable_TransactionAmt_Loc__c = 75;
        claim.Core_MDF_Reimbursable_Transaction_Amount__c = 75;
        claim.Amount = 75;
        claim.Core_MDF_ESD_Hold__c = false;
        claim.Core_MDF_Audit_Hold__c = false;
        claim.Core_MDF_Payment_Hold_ind__c = false;
        claim.Core_MDF_Criteria_Hold_Ind__c = false;
        claim.Core_MDF_Intel_Manual_Hold_Ind__c = false;
        claim.Core_MDF_Member_Manual_Hold_Ind__c = false;
        claim.Core_MDF_Bank_Doc_Hold_Ind__c = false;
        claim.Core_MDF_Document_Hold_Ind__c = false;
        claim.Core_MDF_Bank_Doc_Hold_Eligibility_Ind__c = false;

        if (parentClaimId != null) {
            claim.Core_MDF_Claim_Id__c = parentClaimId;
        }

        TriggerHandler.bypass('Core_MDF_PFC_TriggerHandler');
        insert claim;
        TriggerHandler.clearBypass('Core_MDF_PFC_TriggerHandler');

        List<Core_MDF_Claim_VAT_Info__c> vatRecords;
        if (parentClaimId == null) {
            vatRecords = [SELECT Id, Core_MDF_Status_Txt__c FROM Core_MDF_Claim_VAT_Info__c WHERE Core_MDF_Claim_Id__c = :claim.Id AND Core_MDF_Sub_Claim_Id__c = null];
        } else {
            vatRecords = [SELECT Id, Core_MDF_Status_Txt__c FROM Core_MDF_Claim_VAT_Info__c WHERE Core_MDF_Sub_Claim_Id__c = :claim.Id
            ];
        }

        if (vatRecords.size() > 1) {
            delete vatRecords;
            vatRecords.clear();
        }
        if (vatRecords.isEmpty()) {
            Core_MDF_Claim_VAT_Info__c vatInfo = new Core_MDF_Claim_VAT_Info__c();
            vatInfo.Core_MDF_Claim_Id__c = parentClaimId == null ? claim.Id : parentClaimId;
            if (parentClaimId != null) {
                vatInfo.Core_MDF_Sub_Claim_Id__c = claim.Id;
            }
            vatInfo.Core_MDF_Status_Txt__c = 'Pending Documents';
            insert vatInfo;
        } else {
            vatRecords[0].Core_MDF_Status_Txt__c = 'Pending Documents';
            update vatRecords[0];
        }
        return claim;
    }

    private static void updateClaimWithoutTrigger(PartnerFundClaim claim) {
        TriggerHandler.bypass('Core_MDF_PFC_TriggerHandler');
        update claim;
        TriggerHandler.clearBypass('Core_MDF_PFC_TriggerHandler');
    }

    @isTest
    static void testGetVATCancellationOptionsForEligibleClaim() {
        User externalUser = [SELECT Id FROM User WHERE Email = 'test1@example.com' LIMIT 1];
        assignCancelVATPermission(externalUser);

        Id requestId = getVATCancellationRequest(false);
        PartnerFundClaim claim = createVATCancellationClaim('VAT Cancellation Eligible Claim', null, false, requestId);

        System.runAs(externalUser) {
            Test.startTest();
            Core_MDF_Claim_VAT_Process.VATCancellationDecision decision = Core_MDF_Claim_VAT_Process.getVATCancellationOptions(claim.Id);
            Test.stopTest();

            System.assertEquals(false, decision.isSuperClaim);
            System.assertEquals(true, decision.isEligible);
            System.assertEquals(0, decision.subClaims.size());
        }
    }

    @isTest
    static void testGetVATCancellationOptionsForSuperClaimWithEligibleSubclaim() {
        User externalUser = [SELECT Id FROM User WHERE Email = 'test1@example.com' LIMIT 1];
        assignCancelVATPermission(externalUser);

        Id outcomeRequestId = getVATCancellationRequest(true);
        PartnerFundClaim superClaim = createVATCancellationClaim('VAT Cancellation Super Claim', null, true, outcomeRequestId);
        PartnerFundClaim subClaim = createVATCancellationClaim('VAT Cancellation Sub Claim', superClaim.Id, false, outcomeRequestId);

        System.runAs(externalUser) {
            Test.startTest();
            Core_MDF_Claim_VAT_Process.VATCancellationDecision decision = Core_MDF_Claim_VAT_Process.getVATCancellationOptions(superClaim.Id);
            Test.stopTest();

            System.assertEquals(true, decision.isSuperClaim);
            System.assertEquals(true, decision.isEligible);
            System.assertEquals(1, decision.subClaims.size());
            System.assertEquals(subClaim.Id, decision.subClaims[0].id);
            System.assertEquals('Pending Documents', decision.subClaims[0].vatStatus);
        }
    }

    @isTest
    static void testGetVATCancellationOptionsWhenClaimIsNotOnVATHold() {
        User externalUser = [SELECT Id FROM User WHERE Email = 'test1@example.com' LIMIT 1];
        assignCancelVATPermission(externalUser);

        Id requestId = getVATCancellationRequest(false);
        PartnerFundClaim claim = createVATCancellationClaim('VAT Cancellation Not On Hold', null, false, requestId);
        claim.Core_MDF_VAT_Hold_Ind__c = false;
        updateClaimWithoutTrigger(claim);

        System.runAs(externalUser) {
            Test.startTest();
            Core_MDF_Claim_VAT_Process.VATCancellationDecision decision = Core_MDF_Claim_VAT_Process.getVATCancellationOptions(claim.Id);
            Test.stopTest();

            System.assertEquals(false, decision.isEligible);
            System.assertEquals(false, decision.isSuperClaim);
            System.assertEquals(Label.Core_MDF_Claim_Not_On_VAT_Hold, decision.errorMessage);
        }
    }

    @isTest
    static void testCancelSelectedSubClaimVATRequiresSelection() {
        User externalUser = [SELECT Id FROM User WHERE Email = 'test1@example.com' LIMIT 1];
        assignCancelVATPermission(externalUser);

        System.runAs(externalUser) {
            Boolean exceptionThrown = false;

            Test.startTest();
            try {
               	Core_MDF_Claim_VAT_Process.cancelSelectedSubClaimVAT(null, new List<Id>());
            } catch (AuraHandledException ex) {
                exceptionThrown = true;
            }
            Test.stopTest();

            System.assertEquals(true, exceptionThrown);
        }
    }

    @isTest
    static void testCancelClaimVATSuccessfullyCancelsVAT() {
        User externalUser = [SELECT Id FROM User WHERE Email = 'test1@example.com' LIMIT 1];
        assignCancelVATPermission(externalUser);

        Id requestId = getVATCancellationRequest(false);
        PartnerFundClaim claim = createVATCancellationClaim('VAT Cancellation Successful Claim', null, false, requestId);

        System.runAs(externalUser) {
            Test.startTest();
            Boolean result = Core_MDF_Claim_VAT_Process.cancelClaimVAT(claim.Id);
            Test.stopTest();

            System.assertEquals(true, result);
        }

        PartnerFundClaim updatedClaim = [SELECT Id, Core_MDF_VAT_Eligibility_Ind__c, Core_MDF_VAT_Opt_In__c FROM PartnerFundClaim WHERE Id = :claim.Id];
        Core_MDF_Claim_VAT_Info__c updatedVAT = [SELECT Id, Core_MDF_Status_Txt__c, Core_MDF_VAT_Comments_txt__c FROM Core_MDF_Claim_VAT_Info__c WHERE Core_MDF_Claim_Id__c = :claim.Id AND Core_MDF_Sub_Claim_Id__c = null LIMIT 1];

        System.assertEquals(false, updatedClaim.Core_MDF_VAT_Eligibility_Ind__c);
        System.assertEquals('Reimbursement Request for 3rd party payment (NET cost only)', updatedClaim.Core_MDF_VAT_Opt_In__c);
        System.assertEquals('Cancelled', updatedVAT.Core_MDF_Status_Txt__c);
        System.assert(String.isNotBlank(updatedVAT.Core_MDF_VAT_Comments_txt__c));
    }

    @isTest
    static void testCancelSelectedSubClaimVATSuccessfullyCancelsSelectedSubclaim() {
        User externalUser = [SELECT Id FROM User WHERE Email = 'test1@example.com' LIMIT 1];
        assignCancelVATPermission(externalUser);

        Id outcomeRequestId = getVATCancellationRequest(true);
        PartnerFundClaim superClaim = createVATCancellationClaim('VAT Selected Cancellation Super Claim', null, true, outcomeRequestId);
        PartnerFundClaim subClaim = createVATCancellationClaim('VAT Selected Cancellation Sub Claim', superClaim.Id, false, outcomeRequestId);

        System.runAs(externalUser) {
            Test.startTest();
            Boolean result = Core_MDF_Claim_VAT_Process.cancelSelectedSubClaimVAT(superClaim.Id, new List<Id>{ subClaim.Id });
            Test.stopTest();

            System.assertEquals(true, result);
        }

        PartnerFundClaim updatedSubClaim = [SELECT Id, Core_MDF_VAT_Eligibility_Ind__c, Core_MDF_VAT_Opt_In__c FROM PartnerFundClaim WHERE Id = :subClaim.Id];
        Core_MDF_Claim_VAT_Info__c updatedVAT = [SELECT Id, Core_MDF_Status_Txt__c, Core_MDF_VAT_Comments_txt__c FROM Core_MDF_Claim_VAT_Info__c WHERE Core_MDF_Sub_Claim_Id__c = :subClaim.Id LIMIT 1];

        System.assertEquals(false, updatedSubClaim.Core_MDF_VAT_Eligibility_Ind__c);
        System.assertEquals('Reimbursement Request for 3rd party payment (NET cost only)', updatedSubClaim.Core_MDF_VAT_Opt_In__c);
        System.assertEquals('Cancelled', updatedVAT.Core_MDF_Status_Txt__c);
        System.assert(String.isNotBlank(updatedVAT.Core_MDF_VAT_Comments_txt__c));
    }
}