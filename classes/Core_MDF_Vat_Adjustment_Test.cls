@isTest(SeeAllData=false)
public class Core_MDF_Vat_Adjustment_Test {
    
    @TestSetUp
    static void createTestData() {

        List<User> userList = new List<User>();
        //Role
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        User testUser = Core_MDF_CCP_TestDataUtility.createUser(true);
        testUser.UserRoleId = usRole.Id;
        update testUser;
        
        Profile sysAdminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        
        User usrs = Core_MDF_CCP_TestDataUtility.createUser(false);
        usrs.Email = 'sysadmin@example.com';
        usrs.LastName = 'System Adm';
        usrs.ProfileId = sysAdminProfile.Id;
        usrs.isActive = true;
		database.insert(usrs);
      System.runAs(testUser){
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
            retailBudget.IsIgnoreValidation = true;
            insert retailBudget;
            retailBudget.Core_MDF_Budget_Status__c = 'Released';
            update retailBudget;
            
            //allocation
            PartnerFundAllocation allocation = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('Test Allocation New',retailBudget,masterAcc,200.0,true);
        
                
            Profile ccpCoreAccessProfile = [SELECT Id FROM Profile WHERE Name='CCP - Core Access' LIMIT 1];

            Test.startTest();
            Campaign retailCampaign = Core_MDF_CCP_TestDataUtility.createCampaign('Test Retail Camp 1','Business','Intel® 10ᵗʰ Gen','No', 
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
            
            List<Core_MDF_Bank__c> listBank = new List<Core_MDF_Bank__c>();            
            
            Core_MDF_Bank__c bank = Core_MDF_CCP_TestDataUtility.createBank(retailIntelAcc.Id, 'Core_MDF_Retail_Marketing_Funds', false,'1231231230');
            bank.Core_MDF_Bank_Alias_Name__c='Test';
            bank.Core_MDF_Bank_Status__c ='Active';  
            bank.Core_MDF_Intel_Company_Code__c = '420';     
            bank.Core_MDF_Tax_codes_cd__c = 'UB';
            bank.Core_MDF_VAT_pct__c ='10';
            listBank.add(bank);
            
            Database.insert(listBank);
            //Do Account Bank Mapping for 'bank' and ABM is applicaple only for "Retail MDF" record type
            
            //Core_MDF_Account_Bank_Mapping__c abm1 = 
            Core_MDF_CCP_TestDataUtility.createAccountBankMap(masterAcc.Id,bank.Id,true);

            //Core_MDF_CCP_TestDataUtility.createPartnerGroupMapping(masterAcc.Id,'Internal',masterAcc.Id,retailCP.Id,'PGM_Retail_TEST',true);
            
            //Core_MDF_CCP_TestDataUtility.createPartnerNodeUserMapping(masterAcc.Id, usrBudgetAdmin.Id, true);
            
            //Addeed by Areefa
            Core_Trigger_Executions__c claimFunctionalityNameTriggerExecution = new Core_Trigger_Executions__c();
            claimFunctionalityNameTriggerExecution.Core_Active__c = true;
            claimFunctionalityNameTriggerExecution.Core_Class_Name__c = 'Core_MDF_PFCServiceHandler';
            claimFunctionalityNameTriggerExecution.Core_Trigger_Events__c = 'before insert,after update';
            claimFunctionalityNameTriggerExecution.Core_Object__c = 'PartnerFundClaim';
            claimFunctionalityNameTriggerExecution.Name = 'enableClaimsVATEligible';
            claimFunctionalityNameTriggerExecution.Core_Description__c = 'description';
            Database.insert(claimFunctionalityNameTriggerExecution);            
    

           PartnerFundRequest pfr = Core_MDF_CCP_TestDataUtility.insertPartnerFundRequest(retailCampaign.id,Core_MDF_CCP_TestDataUtility.partnerFund_RecordType_Retail,masterAcc.id,allocation,retailBudget,'UNITED KINGDOM','Business','All-in-One Desktop','Intel® 10ᵗʰ Gen','Broadcast','Podcast','Draft',false);
            pfr.Core_MDF_Fund_Request_Status__c = 'Pending Review';
            pfr.Title = 'Test Retail Activity';
            pfr.Core_MDF_Activity_Description__c = 'Test Retail Activity';
            //pfr.Core_MDF_Budget_Type_txt__c ='Retail MDF';
            pfr.Core_MDF_Channel_Partner_Led__c = false;
            pfr.Core_MDF_Budget_Amount_Local_amt__c=100;
            pfr.Core_MDF_Budget_Currency_cd__c='USD';
            pfr.Core_MDF_Estimated_Ad_Size_nbr__c=5;
            pfr.Core_MDF_Magazine_Newspaper_txt__c='Magazine';
            pfr.Core_MDF_Start_Date__c = System.today();
            pfr.Core_MDF_End_Date__c = System.today();
            pfr.Core_MDF_Reimbursement_Rate_pct__c='100%';  
            //pfr.Core_MDF_Budget_Type_txt__c = 'Retail MDF';
            insert pfr;
          Core_MDF_CCP_TestDataUtility.createMDFConfigurationData();
          PartnerFundClaim claim1 = Core_MDF_CCP_TestDataUtility.createClaim('Test Retail Claim', Core_MDF_CCP_TestDataUtility.claim_RecordType_Retail, pfr.Id, System.today(), System.today(), 50.00, System.today(), bank.Id, false);
           	claim1.Core_MDF_Type_Txt__c ='Claim';
        	claim1.Core_MDF_Currency__c='USD';
            claim1.Core_MDF_VAT_Opt_In__c='Yes';
            claim1.Core_MDF_Country_Location_nm__c= 'UNITED KINGDOM'; 
            claim1.Core_MDF_VAT_Eligibility_Ind__c= true ; 
            claim1.Core_MDF_VAT_Hold_Ind__c = true;
            claim1.Core_MDF_Status__c = 'Hold';
            insert claim1;
            list<Core_MDF_Audit_Document__c> auditDocList = new list<Core_MDF_Audit_Document__c>();
            //test.startTest();
            //String res = Core_MDF_PartnerFundClaim.saveClaim(claim1, auditDocList);  
			System.debug('Query Limit 2: '+ Limits.getQueries());
           PartnerFundClaim claimins = [select id,Core_MDF_VAT_Eligibility_Ind__c,Core_MDF_Status__c,Core_MDF_Audit_Hold__c from PartnerFundClaim where id =: claim1.id limit 1];
            claimins.Core_MDF_Status__c = 'Hold';
            
            Database.update(claimins);
          Test.stopTest();
     }
    }
    
     @isTest
    static void testVatAdjustmentReq()
    {
        System.debug('Query Limit 1: '+ Limits.getQueries());
        User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' and LastName = 'System Adm' limit 1];
        PartnerFundClaim claimins;
        Core_MDF_Claim_VAT_Info__c vatInfo,vatInfo2;
        System.runAs(sysAdminUser)
        {
            
            
            Core_MDF_Bank__c bank1 = [Select Id from Core_MDF_Bank__c where Core_MDF_Bank_Alias_Name__c='Test' limit 1];
            PartnerFundRequest pfr = [Select Id,Title,Core_MDF_Reimbursement_Rate__c from PartnerFundRequest where Title = 'Test Retail Activity'];
           /* PartnerFundClaim claim1 = Core_MDF_CCP_TestDataUtility.createClaim('Test Retail Claim', Core_MDF_CCP_TestDataUtility.claim_RecordType_Retail, pfr.Id, System.today(), System.today(), 50.00, System.today(), bank1.Id, false);
           	claim1.Core_MDF_Type_Txt__c ='Claim';
        	claim1.Core_MDF_Currency__c='USD';
            claim1.Core_MDF_Country_Location_nm__c= 'UNITED KINGDOM'; 
            claim1.Core_MDF_VAT_Eligibility_Ind__c= true ; 
            claim1.Core_MDF_VAT_Hold_Ind__c = true;
            claim1.Core_MDF_Status__c = 'Hold';
            list<Core_MDF_Audit_Document__c> auditDocList = new list<Core_MDF_Audit_Document__c>();
            test.startTest();
            String res = Core_MDF_PartnerFundClaim.saveClaim(claim1, auditDocList);  
			System.debug('Query Limit 2: '+ Limits.getQueries());*/
           // claimins = [select id,Core_MDF_VAT_Eligibility_Ind__c,Core_MDF_Status__c,Core_MDF_Audit_Hold__c from PartnerFundClaim where id =: res limit 1];
            claimins = [select id,Core_MDF_VAT_Eligibility_Ind__c,Core_MDF_Status__c,Core_MDF_Audit_Hold__c from PartnerFundClaim where Title = 'Test Retail Claim' limit 1];
            //claimins.Core_MDF_Status__c = 'Hold';
            
            //Database.update(claimins);
            System.debug('Query Limit 3: '+ Limits.getQueries());
            // Read the VAT Invoice record
            test.startTest();
            vatInfo = [select id from Core_MDF_Claim_VAT_Info__c where Core_MDF_Claim_Id__c = : claimins.Id limit 1];
           // System.debug('###vatInfo->' + res);
            vatInfo.Core_MDF_VAT_Invoice_Number_Txt__c = 'VATINV001';
            Database.update(vatInfo);
			System.debug('Query Limit 4: '+ Limits.getQueries());
            
            
            //Create Document
            ContentVersion cv = new ContentVersion();
            cv.Title = 'Test Document';
            cv.PathOnClient = 'TestDocument.pdf';
            cv.VersionData = Blob.valueOf('Test Content');
            cv.IsMajorVersion = true;
            Insert cv;
			System.debug('Query Limit 5: '+ Limits.getQueries());
            //Get Content documents
            List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];

            //create ContentDocumentLink  record 
            ContentDocumentLink cdl = New ContentDocumentLink();
            cdl.LinkedEntityId = vatInfo.Id;
            cdl.ContentDocumentId = documents[0].Id;
            cdl.shareType = 'V';
            insert cdl;
            System.debug('Query Limit 6: '+ Limits.getQueries());
            vatInfo.Core_MDF_Status_Txt__c = 'Approved';
            Database.update(vatInfo);
            System.debug('Query Limit 7: '+ Limits.getQueries());
            
            Core_MDF_Adjustment_Request__c adjustment1 = new Core_MDF_Adjustment_Request__c();          
            adjustment1.Core_MDF_Reference_Claim_Nbr__c = claimins.Id;
            adjustment1.Core_MDF_Amount_Amt__c = 1;
            adjustment1.Core_MDF_Reason_Cd__c = 'Claim Review Results (Negative)';
            
            Database.insert(adjustment1);
            System.debug('Query Limit 8: '+ Limits.getQueries());
            Core_MDF_Adjustment_Request__c adjustment2 = [Select id, Core_MDF_Adjustment_Claim_Nbr__c 
                                                          from Core_MDF_Adjustment_Request__c where Core_MDF_Reference_Claim_Nbr__c = :claimins.Id limit 1];
              //Introduce Delay
            Long startingTime = System.now().getTime();
            Integer delayInMilliseconds = 10000; // 10-second delay
            while (System.now().getTime() - startingTime < delayInMilliseconds)  {
            // Do nothing until desired delay has passed
            //system.debug('delay');
            }
            
            vatInfo2 = [select id from Core_MDF_Claim_VAT_Info__c where Core_MDF_Claim_Id__c = :adjustment2.Core_MDF_Adjustment_Claim_Nbr__c limit 1];
            vatInfo2.Core_MDF_VAT_Invoice_Number_Txt__c = 'VATINV001';
            Database.update(vatInfo2);
            Test.stopTest();
			System.debug('Query Limit 9: '+ Limits.getQueries());
            //Create Document
            ContentVersion cv2 = new ContentVersion();
            cv2.Title = 'Test Document';
            cv2.PathOnClient = 'TestDocument.pdf';
            cv2.VersionData = Blob.valueOf('Test Content');
            cv2.IsMajorVersion = true;
            Insert cv2;
			System.debug('Query Limit 10: '+ Limits.getQueries());
            //Get Content documents
            List<ContentDocument> documents2 = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];

            //create ContentDocumentLink  record 
            ContentDocumentLink cdl2 = New ContentDocumentLink();
            cdl2.LinkedEntityId = vatInfo2.Id;
            cdl2.ContentDocumentId = documents2[0].Id;
            cdl2.shareType = 'V';
            insert cdl2;
            System.debug('Query Limit 11: '+ Limits.getQueries());
            vatInfo2.Core_MDF_Status_Txt__c = 'Approved';
            Database.update(vatInfo2);
            System.debug('Query Limit 12: '+ Limits.getQueries());
        }
       
    }
    

}