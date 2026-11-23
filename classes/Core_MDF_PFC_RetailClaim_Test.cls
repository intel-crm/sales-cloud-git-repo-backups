/****************************************************************************************************************************************
* Class Name  : Core_MDF_PFC_RetailClaim_Test
* Version     : 1.0 
* Created Date: 24-Feb-2020
* Modification Log :
* Developer                        Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Intel -Areefa          24-Feb-2020                    Created to test RetailClaim Functionality :working Version
*****************************************************************************************************************************************/
@isTest
public class Core_MDF_PFC_RetailClaim_Test {
    
    /* Method to Setup Test Data */
    @testSetup 
    static void setup() {  
        ChannelProgram cp = Core_MDF_CCP_TestDataUtility.createProgram ('Retail Marketing Funds','Retail Marketing Funds', true);
        
        system.debug('cpId for Retail ::' +cp.Id);
        
        Account acc1 = Core_MDF_CCP_TestDataUtility.createIntelAccount('Test RetailAccount 1', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
        acc1.Core_Geo__c = 'APJ';
        Database.insert(acc1);
        
        List<Contact> listContact = new List<Contact>();
        Contact conRecord1 = Core_MDF_CCP_TestDataUtility.createContact(acc1.Id,false);
        Contact conRecord2 = Core_MDF_CCP_TestDataUtility.createContact(acc1.Id,false);
        
        listContact.add(conRecord1);
        listContact.add(conRecord2);
        
        Database.insert(listContact);
        
        Id profileId = [SELECT Id FROM Profile WHERE Name='Partner' limit 1].Id;
        Profile ccpCoreProfile = [SELECT Id FROM Profile WHERE Name='CCP - Core Access' LIMIT 1];
        PermissionSet clmCaseRevPS = [SELECT Id, Name FROM PermissionSet WHERE Name='Core_MDF_CCP_Internal_Claim_Case_Reviewer' LIMIT 1];
        Profile sysAdminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        
        User usrs = Core_MDF_CCP_TestDataUtility.createUser(false);
        usrs.LastName = 'System Adm';
        usrs.ProfileId = sysAdminProfile.Id;
        usrs.isActive = true;
        usrs.Email = 'sysadmin@example.com';
        Database.insert(usrs); 
        
        List<User> listUser = new List<User>();
        
        User usr1 = Core_MDF_CCP_TestDataUtility.createUser(false);        
        usr1.Email='test1@example.com';
        usr1.ContactId = listContact[0].Id;
        usr1.ProfileId = profileId;
        usr1.isActive = true;
        listUser.add(usr1);        
        
        User usr2 = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr2.Email='test123@example.com';
        usr2.ContactId = listContact[1].Id;
        usr2.ProfileId = profileId;
        usr2.isActive = true;
        listUser.add(usr2);
        
        /*User usr3 = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr3.Email = 'sysadmin@example.com';
        listUser.add(usr3);*/
        
        //Login as claim claim Case reviewer
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User ccrUser = Core_MDF_CCP_TestDataUtility.createUser(false);
        ccrUser.Email='testCCR@example.com';
        ccrUser.ProfileId = p.id;
        listUser.add(ccrUser);
        
        //creating system admin user
        User sysAdmUsr = Core_MDF_CCP_TestDataUtility.createUser(false);
        sysAdmUsr.LastName = 'System Adm';
        listUser.add(sysAdmUsr);
        
        //creating claim case user
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.LastName='Claim Case User';
        usr.profile=ccpCoreProfile;
        listUser.add(usr);
        
        Database.insert(listUser);    
        
        //asigning permission set to claim case user
        PermissionSetAssignment assignPermissionSetObj = new PermissionSetAssignment();
        assignPermissionSetObj.AssigneeId = usr.Id;
        assignPermissionSetObj.PermissionSetId = clmCaseRevPS.Id;
        system.runAs(sysAdmUsr){
            Database.insert(assignPermissionSetObj);
        }
        
        Account acc2 = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Retail TestAccount', cp.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, acc1.Id, false); // virtual corp
        acc2.Core_Geo__c = 'APJ';
        Database.insert(acc2);
        
        //Ameyaa
        Account acc3 = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Retail TestAccount Acc 3', cp.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, acc2.Id, false);
        acc3.Core_Geo__c = 'APJ';
        Database.insert(acc3);
        
        Account acc4 = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Retail TestAccount Acc 4', cp.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, acc3.Id, false);
        acc4.Core_Geo__c = 'APJ';
        Database.insert(acc4);
        //Ameya
        
        PartnerMarketingBudget budget = Core_MDF_CCP_TestDataUtility.createRetailBudget('Retail TestBudget',Core_MDF_CCP_TestDataUtility.budget_Record_Type,acc2.Id,cp.Id,200000,System.today(),System.today(), true,'RSA MD');
        
        PartnerFundAllocation allocation = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('Test Allocation New',budget,acc2,200.0,true);
        
        List<Campaign> campaigns = new List<Campaign>();
        Campaign reatailMDFCampaign = Core_MDF_CCP_TestDataUtility.createCampaign('Retail Campaigm1','Gaming','9ᵗʰ Gen', Core_MDF_CCP_TestDataUtility.campaign_RecordType_Retail, 'Retail Marketing Funds', System.today(), System.today().addDays(2), 10000, 'Instore innovation', acc2.Id,'Desktop', false); 
        reatailMDFCampaign.Core_MDF_Budget_Type_txt__c ='Retail MDF';
        reatailMDFCampaign.Core_MDF_Activity_Category_Type__c =null;
        reatailMDFCampaign.Core_MDF_Reimbursement_Rate__c='100%';
        reatailMDFCampaign.Core_MDF_Technology__c = 'Intel vPro®';
        
        Campaign rSAMDCampaign = Core_MDF_CCP_TestDataUtility.createCampaign('Retail Campaigm1','Gaming','9ᵗʰ Gen', Core_MDF_CCP_TestDataUtility.campaign_RecordType_Retail, 'Retail Marketing Funds', System.today(), System.today().addDays(2), 10000, 'Instore innovation', acc2.Id,'Desktop', false); 
        rSAMDCampaign.Core_MDF_Budget_Type_txt__c ='RSA MD';
        rSAMDCampaign.Core_MDF_Activity_Category_Type__c =null;
        rSAMDCampaign.Core_MDF_Reimbursement_Rate__c='100%';
        rSAMDCampaign.Core_MDF_Technology__c = 'Intel vPro®';
        
        //Ameya
        Campaign rSAMDCampaignOnLevelOneNode = Core_MDF_CCP_TestDataUtility.createCampaign('RSA MD Level One Node Campaigm','Gaming','9ᵗʰ Gen', Core_MDF_CCP_TestDataUtility.campaign_RecordType_Retail, 'Retail Marketing Funds', System.today(), System.today().addDays(2), 10000, 'Instore innovation', acc3.Id,'Desktop', false); 
        rSAMDCampaignOnLevelOneNode.Core_MDF_Budget_Type_txt__c ='RSA MD';
        rSAMDCampaignOnLevelOneNode.Core_MDF_Activity_Category_Type__c =null;
        rSAMDCampaignOnLevelOneNode.Core_MDF_Reimbursement_Rate__c='100%';
        rSAMDCampaignOnLevelOneNode.Core_MDF_Technology__c = 'Intel vPro®';
        
        Campaign rSAMDCampaignOnLevelTwoNode = Core_MDF_CCP_TestDataUtility.createCampaign('RSA MD Level Two Node Campaigm','Gaming','9ᵗʰ Gen', Core_MDF_CCP_TestDataUtility.campaign_RecordType_Retail, 'Retail Marketing Funds', System.today(), System.today().addDays(2), 10000, 'Instore innovation', acc4.Id,'Desktop', false); 
        rSAMDCampaignOnLevelTwoNode.Core_MDF_Budget_Type_txt__c ='RSA MD';
        rSAMDCampaignOnLevelTwoNode.Core_MDF_Activity_Category_Type__c =null;
        rSAMDCampaignOnLevelTwoNode.Core_MDF_Reimbursement_Rate__c='100%';
        rSAMDCampaignOnLevelTwoNode.Core_MDF_Technology__c = 'Intel vPro®';
        
        campaigns.add(reatailMDFCampaign);
        campaigns.add(rSAMDCampaign);
        campaigns.add(rSAMDCampaignOnLevelOneNode);
        campaigns.add(rSAMDCampaignOnLevelTwoNode);
        system.debug('campaigns::'+campaigns);
        test.startTest();        
        insert campaigns;
        
       // test.startTest();
        List<PartnerFundRequest> pFR = new List<PartnerFundRequest>();        
        PartnerFundRequest testPartnerFundRequest = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(rSAMDCampaign.Id),
                                                                                                          Core_MDF_CCP_TestDataUtility.partnerFund_RecordType_Retail,string.valueof(acc2.id),NULL,NULL,'AFGHANISTAN','Enthusiast Gaming','Traditional Notebook',
                                                                                                              'Intel® 11ᵗʰ Gen','Sales Readiness','In-Store Promotion','Draft',false);      
        
        testPartnerFundRequest.Title ='Retail RSA MD Activity';
        testPartnerFundRequest.Core_MDF_Activity_Description__c ='Retail RSA MD Activity';
        testPartnerFundRequest.Core_MDF_Budget_Type_txt__c ='RSA MD';
        testPartnerFundRequest.Core_MDF_Start_Date__c = System.today();
        testPartnerFundRequest.Core_MDF_End_Date__c  = System.today();
        testPartnerFundRequest.RequestedAmount =100000;
        testPartnerFundRequest.Amount=100000;
        testPartnerFundRequest.Core_MDF_Country__c ='AFGHANISTAN';
        testPartnerFundRequest.Core_MDF_Country_nm__c = 'AFGHANISTAN';
        testPartnerFundRequest.Core_MDF_Fund_Request_Status__c = 'Planned';
        testPartnerFundRequest.Core_MDF_Budget_Currency_cd__c ='USD';
        testPartnerFundRequest.Core_MDF_Reimbursement_Rate_pct__c='100%';
        
        
        PartnerFundRequest testPartnerFundRequest1 =Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(reatailMDFCampaign.Id),
                                                                                                          Core_MDF_CCP_TestDataUtility.partnerFund_RecordType_Retail,string.valueof(acc2.id),NULL,NULL,'AFGHANISTAN','Enthusiast Gaming','Traditional Notebook',
                                                                                                              'Intel® 11ᵗʰ Gen','Sales Readiness','In-Store Promotion','Draft',false);
        
        testPartnerFundRequest1.Title ='Retail MDF Activity';
        testPartnerFundRequest1.Core_MDF_Activity_Description__c ='Retail MDF Activity';
        testPartnerFundRequest1.Core_MDF_Budget_Type_txt__c ='Retail MDF';
        testPartnerFundRequest1.Core_MDF_Start_Date__c = System.today();
        testPartnerFundRequest1.Core_MDF_End_Date__c  = System.today();
        testPartnerFundRequest1.RequestedAmount =100000;
        testPartnerFundRequest1.Amount=100000;
        testPartnerFundRequest1.Core_MDF_Country__c ='AFGHANISTAN';
        testPartnerFundRequest1.Core_MDF_Country_nm__c = 'AFGHANISTAN';
        testPartnerFundRequest1.Core_MDF_Fund_Request_Status__c = 'Planned';
        testPartnerFundRequest1.Core_MDF_Budget_Currency_cd__c ='USD'; 
        testPartnerFundRequest1.Core_MDF_Reimbursement_Rate_pct__c='100%';
        
        //Ameya
        PartnerFundRequest testPartnerFundRequestOnLevelOneNode =Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(rSAMDCampaignOnLevelOneNode.Id),
                                                                                                          Core_MDF_CCP_TestDataUtility.partnerFund_RecordType_Retail,string.valueof(acc3.id),NULL,NULL,'AFGHANISTAN','Enthusiast Gaming','Traditional Notebook',
                                                                                                              'Intel® 11ᵗʰ Gen','Sales Readiness','In-Store Promotion','Draft',false);
        
        testPartnerFundRequestOnLevelOneNode.Title ='RSA MD Level One Node Activity';
        testPartnerFundRequestOnLevelOneNode.Core_MDF_Activity_Description__c ='RSA MD Activity';
        testPartnerFundRequestOnLevelOneNode.Core_MDF_Budget_Type_txt__c ='RSA MD';
        testPartnerFundRequestOnLevelOneNode.Core_MDF_Start_Date__c = System.today();
        testPartnerFundRequestOnLevelOneNode.Core_MDF_End_Date__c  = System.today();
        testPartnerFundRequestOnLevelOneNode.RequestedAmount =100000;
        testPartnerFundRequestOnLevelOneNode.Amount=100000;
        testPartnerFundRequestOnLevelOneNode.Core_MDF_Country__c ='AFGHANISTAN';
        testPartnerFundRequestOnLevelOneNode.Core_MDF_Country_nm__c = 'AFGHANISTAN';
        testPartnerFundRequestOnLevelOneNode.Core_MDF_Fund_Request_Status__c = 'Planned';
        testPartnerFundRequestOnLevelOneNode.Core_MDF_Budget_Currency_cd__c ='USD'; 
        testPartnerFundRequestOnLevelOneNode.Core_MDF_Reimbursement_Rate_pct__c='100%';
        
        //Ameya
        PartnerFundRequest testPartnerFundRequestOnLevelTwoNode =Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(rSAMDCampaignOnLevelTwoNode.Id),
                                                                                                          Core_MDF_CCP_TestDataUtility.partnerFund_RecordType_Retail,string.valueof(acc4.id),NULL,NULL,'AFGHANISTAN','Enthusiast Gaming','Traditional Notebook',
                                                                                                              'Intel® 11ᵗʰ Gen','Sales Readiness','In-Store Promotion','Draft',false);
        
        testPartnerFundRequestOnLevelTwoNode.Title ='RSA MD Level Two Node Activity';
        testPartnerFundRequestOnLevelTwoNode.Core_MDF_Activity_Description__c ='RSA MD Activity';
        testPartnerFundRequestOnLevelTwoNode.Core_MDF_Budget_Type_txt__c ='RSA MD';
        testPartnerFundRequestOnLevelTwoNode.Core_MDF_Start_Date__c = System.today();
        testPartnerFundRequestOnLevelTwoNode.Core_MDF_End_Date__c  = System.today();
        testPartnerFundRequestOnLevelTwoNode.RequestedAmount =1000000;
        testPartnerFundRequestOnLevelTwoNode.Amount=100000;
        testPartnerFundRequestOnLevelTwoNode.Core_MDF_Country__c ='AFGHANISTAN';
        testPartnerFundRequestOnLevelTwoNode.Core_MDF_Country_nm__c = 'AFGHANISTAN';
        testPartnerFundRequestOnLevelTwoNode.Core_MDF_Fund_Request_Status__c = 'Planned';
        testPartnerFundRequestOnLevelTwoNode.Core_MDF_Budget_Currency_cd__c ='USD'; 
        testPartnerFundRequestOnLevelTwoNode.Core_MDF_Reimbursement_Rate_pct__c='100%';
        
        pFR.add(testPartnerFundRequest);
        pFR.add(testPartnerFundRequest1);
        pFR.add(testPartnerFundRequestOnLevelOneNode);
        pFR.add(testPartnerFundRequestOnLevelTwoNode);
        system.debug('testPartnerFundRequest::'+testPartnerFundRequest);
        system.debug('testPartnerFundRequest.Core_MDF_Reimbursement_Rate__c::' +testPartnerFundRequest.Core_MDF_Reimbursement_Rate__c);
        system.debug('testPartnerFundRequest1::'+testPartnerFundRequest1);
        system.debug('testPartnerFundRequest.Core_MDF_Reimbursement_Rate__c::' +testPartnerFundRequest1.Core_MDF_Reimbursement_Rate__c);
        insert pFR;  
        
        /*pFR[0].RequestedAmount = 2000;
        PartnerFundRequest p1 = null;
        system.runAs(sysAdmUsr){
        update pFR[0];
        p1 =[SELECT Id, Core_MDF_Reimbursement_Rate__c,RequestedAmount from PartnerFundRequest WHERE id =: pFR[0].id ];
        system.debug('pFR p1 ::::'+ p1);
        system.debug('pFR p1.Core_MDF_Reimbursement_Rate__c ::::'+p1.Core_MDF_Reimbursement_Rate__c);
        }*/
        
        Core_MDF_CCP_TestDataUtility.insertCurrencyExchangeRates();
        List<Core_MDF_Bank__c> listBank = new List<Core_MDF_Bank__c>();
        
        
        /*Core_MDF_Bank__c bank = Core_MDF_CCP_TestDataUtility.createBank(acc1.Id, 'Core_MDF_Retail_Marketing_Funds', false,'1231231230');
        bank.Core_MDF_Bank_Alias_Name__c='Test';
        bank.Core_MDF_Bank_Status__c ='Active';          
        system.debug('bank' +bank);
        Database.insert(bank); */
        
        Core_MDF_Bank__c bank = Core_MDF_CCP_TestDataUtility.createBank(acc1.Id, 'Core_MDF_Retail_Marketing_Funds', false,'1231231230');
        bank.Core_MDF_Intel_Company_Code__c = '150';
        bank.Core_MDF_Currency_cd__c = 'USD';
        bank.Core_MDF_Tax_codes_cd__c = 'I0';
        bank.Core_MDF_Bank_Status__c = 'Active';
        database.insert(bank);
        
        //Do Account Bank Mapping for 'bank' and ABM is applicaple only for "Retail MDF" record type
        Core_MDF_Account_Bank_Mapping__c abm1 = Core_MDF_CCP_TestDataUtility.createAccountBankMap(acc2.Id,bank.Id,true);
        
        Core_MDF_CCP_TestDataUtility.createPartnerGroupMapping(acc1.Id,'Internal',acc1.Id,cp.Id,'PGM_Retail_TEST',true);
        
        Core_MDF_CCP_TestDataUtility.createPartnerNodeUserMapping(acc2.Id, Usr1.Id, true);
        
        //List<PartnerFundClaim> pfcList = new List<PartnerFundClaim>();        
        //PartnerFundClaim retailMDFClaim = Core_MDF_CCP_TestDataUtility.createClaim('UtilityClaim', Core_MDF_CCP_TestDataUtility.claim_RecordType_Retail, testPartnerFundRequest.Id, System.today().addDays(20), System.today().addDays(20), 50.00, System.today().addDays(20), bank.Id, false);
        //retailMDFClaim.Core_MDF_Type_Txt__c ='Claim';
        //retailMDFClaim.Core_MDF_Currency__c='USD';
        //retailMDFClaim.Core_MDF_Country_Location_nm__c= 'AFGHANISTAN';       
        
        //pfcList.add(retailMDFClaim);
        //system.debug('Retail pfcList::' +pfcList);
        
        //PartnerFundClaim retailRSAClaim = Core_MDF_CCP_TestDataUtility.createRetailRSAMDClaim(Core_MDF_CCP_TestDataUtility.claim_RecordType_Retail, testPartnerFundRequest.Id, System.today().addDays(20), System.today().addDays(20), 50.00,false);
        //retailRSAClaim.Core_MDF_Type_Txt__c ='Claim';
        // pfcList.add(retailRSAClaim);        
        //insert(pfcList);
        test.stopTest();        
        
        Core_MDF_CCP_TestDataUtility.createTriggerExecutionRecords();
        
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
        
    }
    
    /* Method to test RetailMDF saveClaim */
    @isTest
    static void testRetailMDFSaveClaimSuccessMethod()
    {
        User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        System.runAs(sysAdminUser)
        {
            test.startTest();
            Core_MDF_Bank__c bank1 = [Select Id from Core_MDF_Bank__c where Core_MDF_Bank_Alias_Name__c='Test' limit 1];
            PartnerFundRequest pfr = [Select Id,Title from PartnerFundRequest where Title = 'Retail MDF Activity'];
            PartnerFundClaim claim1 = Core_MDF_CCP_TestDataUtility.createClaim('Retail MDF Claim', Core_MDF_CCP_TestDataUtility.claim_RecordType_Retail, pfr.Id, System.today(), System.today(), 50.00, System.today(), bank1.Id, false);
            claim1.Core_MDF_Type_Txt__c ='Claim';
            claim1.Core_MDF_Currency__c='USD';
            claim1.Core_MDF_Country_Location_nm__c= 'AFGHANISTAN'; 
            /*POP mandatory for Retail*/
            List<String> documentIdWithTitle = new List<String>();
            list<String> tempString = new list<String>();
            list<Core_MDF_Audit_Document__c> auditDocList = new list<Core_MDF_Audit_Document__c>();
            
            String str1 = claim1.Id+';#'+'Test Doc1';
            String str2 = claim1.Id+';#'+'Test Doc2';
            system.debug('str2' +str2);
            
            documentIdWithTitle.add(str1);
            documentIdWithTitle.add(str2);
            
            for(String str: documentIdWithTitle){
                tempString = str.split(';#');
                Core_MDF_Audit_Document__c auditDoc = new Core_MDF_Audit_Document__c();
                auditDoc.Core_MDF_Document_Id__c = tempString[0];
                auditDoc.Core_MDF_Document_Title__c = tempString[1];
                auditDoc.Core_MDF_Claim__c = claim1.Id;
                auditDoc.Core_MDF_Proof_of_Branding__c = true;
                auditDoc.Core_MDF_Proof_of_Cost__c = true;
                auditDoc.Core_MDF_Proof_of_Execution__c = true;                
                auditDocList.add(auditDoc);
                system.debug('auditDocList-->' +auditDocList);
            }            
            
            if(auditDocList.size()>0){
                Database.insert(auditDocList);                
            }
            String res = Core_MDF_PartnerFundClaim.saveClaim(claim1, auditDocList);            
            System.assertEquals(claim1.ID,res);            
            test.stopTest();
        }
    }
    
    /* Method to test RSA MD saveClaim */
    @isTest
    static void testRetailRsaMDSaveClaimSuccessMethod()
    {
        User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        System.runAs(sysAdminUser)
        {
            test.startTest();
            Core_MDF_Bank__c bank1 = [Select Id from Core_MDF_Bank__c where Core_MDF_Bank_Alias_Name__c='Test' limit 1];
            PartnerFundRequest pfr = [Select Id,Title from PartnerFundRequest where Title = 'Retail RSA MD Activity'];
            PartnerFundClaim claim1 = Core_MDF_CCP_TestDataUtility.createRetailRSAMDClaim(Core_MDF_CCP_TestDataUtility.claim_RecordType_Retail, pfr.Id, System.today(), System.today(), 50.00, false);
            claim1.Core_MDF_Country_Location_nm__c= 'AFGHANISTAN';
            claim1.Title = 'Retail RSA MD Claim';            
            /*POP mandatory for Retail*/
            List<String> documentIdWithTitle = new List<String>();
            list<String> tempString = new list<String>();
            list<Core_MDF_Audit_Document__c> auditDocList = new list<Core_MDF_Audit_Document__c>();
            
            String str1 = claim1.Id+';#'+'Test Doc1';
            String str2 = claim1.Id+';#'+'Test Doc2';
            system.debug('str2' +str2);
            
            documentIdWithTitle.add(str1);
            documentIdWithTitle.add(str2);
            
            for(String str: documentIdWithTitle){
                tempString = str.split(';#');
                Core_MDF_Audit_Document__c auditDoc = new Core_MDF_Audit_Document__c();
                auditDoc.Core_MDF_Document_Id__c = tempString[0];
                auditDoc.Core_MDF_Document_Title__c = tempString[1];
                auditDoc.Core_MDF_Claim__c = claim1.Id;
                auditDoc.Core_MDF_Proof_of_Branding__c = true;
                auditDoc.Core_MDF_Proof_of_Cost__c = true;
                auditDoc.Core_MDF_Proof_of_Execution__c = true;                
                auditDocList.add(auditDoc);
                system.debug('auditDocList-->' +auditDocList);
            }            
            
            if(auditDocList.size()>0){
                Database.insert(auditDocList);                
            }
            
            String res = Core_MDF_PartnerFundClaim.saveClaim(claim1, auditDocList);            
            System.assertEquals(claim1.ID,res);            
            test.stopTest();
        }
    }
    
    /* Method to test RSA MD saveClaim without POP*/
    @isTest
    static void testRetailRsaMDSaveClaimFailureMethod()
    {            
        try{
            User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
            System.runAs(sysAdminUser)
            {
                test.startTest();
                Core_MDF_Bank__c bank1 = [Select Id from Core_MDF_Bank__c where Core_MDF_Bank_Alias_Name__c='Test' limit 1];
                PartnerFundRequest pfr = [Select Id,Title from PartnerFundRequest where Title = 'Retail RSA MD Activity'];
                PartnerFundClaim claim1 = Core_MDF_CCP_TestDataUtility.createRetailRSAMDClaim(Core_MDF_CCP_TestDataUtility.claim_RecordType_Retail, pfr.Id, System.today(), System.today(), 50.00, false);
                claim1.Core_MDF_Country_Location_nm__c= 'AFGHANISTAN';
                claim1.Title = 'Retail RSA MD Claim';
                list<Core_MDF_Audit_Document__c> auditDocList = new list<Core_MDF_Audit_Document__c>(); 
                String res = Core_MDF_PartnerFundClaim.saveClaim(claim1, auditDocList);            
                System.assertEquals(claim1.ID,res);            
                test.stopTest();
            }
        }catch(Exception e){
            System.assertNotEquals(NULL,e);
        }
        
    }
    
    /* Method to test RSA MD saveClaim with POP and Claims budget Amount should be with Activity request Amount*/
    @isTest
    static void testRetailAmtAgainstActivityBudgetAmtMethod()
    {
        User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        System.runAs(sysAdminUser)
        {
            test.startTest();
            Core_MDF_Bank__c bank1 = [Select Id from Core_MDF_Bank__c where Core_MDF_Bank_Alias_Name__c='Test' limit 1];
            PartnerFundRequest pfr = [Select Id,Title,RequestedAmount,Amount from PartnerFundRequest where Title = 'Retail RSA MD Activity']; // 1000$
            System.debug('pfr req amt' + pfr);
            List<PartnerFundClaim> pfc = new List<PartnerFundClaim>();
            
            /*POP mandatory for Retail*/
            List<String> documentIdWithTitle = new List<String>();
            list<String> tempString = new list<String>();
            list<Core_MDF_Audit_Document__c> auditDocList = new list<Core_MDF_Audit_Document__c>();            
            List<PartnerFundClaim> pfcList = [Select id,Amount,Request.Amount from PartnerFundClaim where RequestId =: pfr.Id];
            System.debug('pfcList ::::'+pfcList);
            PartnerFundClaim claim1 = Core_MDF_CCP_TestDataUtility.createRetailRSAMDClaim(Core_MDF_CCP_TestDataUtility.claim_RecordType_Retail, pfr.Id, System.today(), System.today(), 500.00, false);
            //Claim1 500$
            claim1.Core_MDF_Country_Location_nm__c= 'AFGHANISTAN';
            claim1.Title = 'Retail RSA MD Claim1';
            //pfc.add(claim1);
            String res = Core_MDF_PartnerFundClaim.saveClaim(claim1, auditDocList);            
            System.assertEquals(claim1.ID,res);
            
            PartnerFundClaim claim2 = Core_MDF_CCP_TestDataUtility.createRetailRSAMDClaim(Core_MDF_CCP_TestDataUtility.claim_RecordType_Retail, pfr.Id, System.today(), System.today(), 500.00, false);
            //Claim2 500$
            claim2.Core_MDF_Country_Location_nm__c= 'AFGHANISTAN';
            claim2.Title = 'Retail RSA MD Claim2';
            //pfc.add(claim2);
            String res1 = Core_MDF_PartnerFundClaim.saveClaim(claim2, auditDocList);            
            System.assertEquals(claim2.ID,res1);
            
            
            String str1 = claim1.Id+';#'+'Test Doc1';
            String str2 = claim1.Id+';#'+'Test Doc2';
            String str3 = claim2.Id+';#'+'Test Doc3';
            String str4 = claim2.Id+';#'+'Test Doc4';                
            system.debug('str3' +str3);
            
            documentIdWithTitle.add(str1);
            documentIdWithTitle.add(str2);
            documentIdWithTitle.add(str3);
            documentIdWithTitle.add(str4);
            for(PartnerFundClaim p : pfc){
                for(String str: documentIdWithTitle){
                    tempString = str.split(';#');
                    Core_MDF_Audit_Document__c auditDoc = new Core_MDF_Audit_Document__c();
                    auditDoc.Core_MDF_Document_Id__c = tempString[0];
                    auditDoc.Core_MDF_Document_Title__c = tempString[1];
                    auditDoc.Core_MDF_Claim__c = p.Id;
                    auditDoc.Core_MDF_Proof_of_Branding__c = true;
                    auditDoc.Core_MDF_Proof_of_Cost__c = true;
                    auditDoc.Core_MDF_Proof_of_Execution__c = true;                
                    auditDocList.add(auditDoc);
                    system.debug('auditDocList-->' +auditDocList);
                }
            }            
            
            if(auditDocList.size()>0){
                Database.insert(auditDocList);                
            }
            
            //System.assertEquals(claim2.ID,res);
            
            test.stopTest();
        }
    }
    
    @isTest
    static void testRetailAmtAgainstActivityBudgetAmtExceptionMethod()
    {
        try{
            User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
            System.runAs(sysAdminUser)
            {
                test.startTest();
                
                Core_MDF_Bank__c bank1 = [Select Id from Core_MDF_Bank__c where Core_MDF_Bank_Alias_Name__c='Test' limit 1];
                PartnerFundRequest pfr = [Select Id,Title,RequestedAmount from PartnerFundRequest where Title = 'Retail RSA MD Activity']; // 1000$
                System.debug('pfr req amt' + pfr);
                List<PartnerFundClaim> pfc = new List<PartnerFundClaim>();
                
                /*POP mandatory for Retail*/
                List<String> documentIdWithTitle = new List<String>();
                list<String> tempString = new list<String>();
                list<Core_MDF_Audit_Document__c> auditDocList = new list<Core_MDF_Audit_Document__c>();     
                PartnerFundClaim claim1 = Core_MDF_CCP_TestDataUtility.createRetailRSAMDClaim(Core_MDF_CCP_TestDataUtility.claim_RecordType_Retail, pfr.Id, System.today(), System.today(), 2500.00, false);
                //Claim1 2500$
                claim1.Core_MDF_Country_Location_nm__c= 'AFGHANISTAN';
                claim1.Title = 'Retail RSA MD Claim4';
                pfc.add(claim1);
                
                PartnerFundClaim claim2 = Core_MDF_CCP_TestDataUtility.createRetailRSAMDClaim(Core_MDF_CCP_TestDataUtility.claim_RecordType_Retail, pfr.Id, System.today(), System.today(), 2500.00, false);
                //Claim5 2500$
                claim2.Core_MDF_Country_Location_nm__c= 'AFGHANISTAN';
                claim2.Title = 'Retail RSA MD Claim5';
                pfc.add(claim2);  
                
                String str1 = claim1.Id+';#'+'Test Doc1';
                String str2 = claim1.Id+';#'+'Test Doc2';
                
                String str3 = claim1.Id+';#'+'Test Doc3';
                String str4 = claim1.Id+';#'+'Test Doc4';
                
                system.debug('str3' +str3);
                
                documentIdWithTitle.add(str1);
                documentIdWithTitle.add(str2);
                documentIdWithTitle.add(str3);
                documentIdWithTitle.add(str4);
                
                for(PartnerFundClaim p : pfc){
                    for(String str: documentIdWithTitle){
                        tempString = str.split(';#');
                        Core_MDF_Audit_Document__c auditDoc = new Core_MDF_Audit_Document__c();
                        auditDoc.Core_MDF_Document_Id__c = tempString[0];
                        auditDoc.Core_MDF_Document_Title__c = tempString[1];
                        auditDoc.Core_MDF_Claim__c = p.Id;
                        auditDoc.Core_MDF_Proof_of_Branding__c = true;
                        auditDoc.Core_MDF_Proof_of_Cost__c = true;
                        auditDoc.Core_MDF_Proof_of_Execution__c = true;                
                        auditDocList.add(auditDoc);
                        system.debug('auditDocList-->' +auditDocList);
                    }            
                } 
                if(auditDocList.size()>0){
                    Database.insert(auditDocList);                
                }
                
                
                Database.insert(pfc);
                List<PartnerFundClaim> pfc2 = new List<PartnerFundClaim>();
                claim1.Core_MDF_Invoice_Number__c = '234542';
                claim1.Core_MDF_Media_Vehicle__c = 'test1';
                claim2.Core_MDF_Invoice_Number__c = '234543';
                claim2.Core_MDF_Media_Vehicle__c = 'test2';
                pfc2.add(claim1);
                pfc2.add(claim2);
                Database.update(pfc2);
                test.stopTest();
            }
        }catch(Exception e){
            System.assertNotEquals(NULL,e);
        }
        
    }
    
        //Ameya
        /* Method to test RSA MD saveClaim */
    @isTest
    static void testRsaMDSaveClaimOnLevelOneNode()
    {
        User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        System.runAs(sysAdminUser)
        {
            test.startTest();
            Core_MDF_Bank__c bank1 = [Select Id from Core_MDF_Bank__c where Core_MDF_Bank_Alias_Name__c='Test' limit 1];
            PartnerFundRequest pfr = [Select Id,Title from PartnerFundRequest where Title = 'RSA MD Level One Node Activity'];
            PartnerFundClaim claim1 = Core_MDF_CCP_TestDataUtility.createRetailRSAMDClaim(Core_MDF_CCP_TestDataUtility.claim_RecordType_Retail, pfr.Id, System.today(), System.today(), 50.00, false);
            claim1.Core_MDF_Country_Location_nm__c= 'AFGHANISTAN';
            claim1.Title = 'RSA MD Level One Node Claim';            
            /*POP mandatory for Retail*/
            List<String> documentIdWithTitle = new List<String>();
            list<String> tempString = new list<String>();
            list<Core_MDF_Audit_Document__c> auditDocList = new list<Core_MDF_Audit_Document__c>();
            
            String str1 = claim1.Id+';#'+'Test Doc1';
            String str2 = claim1.Id+';#'+'Test Doc2';
            system.debug('str2' +str2);
            
            documentIdWithTitle.add(str1);
            documentIdWithTitle.add(str2);
            
            for(String str: documentIdWithTitle){
                tempString = str.split(';#');
                Core_MDF_Audit_Document__c auditDoc = new Core_MDF_Audit_Document__c();
                auditDoc.Core_MDF_Document_Id__c = tempString[0];
                auditDoc.Core_MDF_Document_Title__c = tempString[1];
                auditDoc.Core_MDF_Claim__c = claim1.Id;
                auditDoc.Core_MDF_Proof_of_Branding__c = true;
                auditDoc.Core_MDF_Proof_of_Cost__c = true;
                auditDoc.Core_MDF_Proof_of_Execution__c = true;                
                auditDocList.add(auditDoc);
                system.debug('auditDocList-->' +auditDocList);
            }            
            
            if(auditDocList.size()>0){
                Database.insert(auditDocList);                
            }
            
            String res = Core_MDF_PartnerFundClaim.saveClaim(claim1, auditDocList);            
            System.assertEquals(claim1.ID,res);            
            test.stopTest();
        }
    }
    
        /* Method to test RSA MD saveClaim */
    @isTest
    static void testRsaMDSaveClaimOnLevelTwoNode()
    {
        User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        System.runAs(sysAdminUser)
        {
            test.startTest();
            Core_MDF_Bank__c bank1 = [Select Id from Core_MDF_Bank__c where Core_MDF_Bank_Alias_Name__c='Test' limit 1];
            PartnerFundRequest pfr = [Select Id,Title from PartnerFundRequest where Title = 'RSA MD Level Two Node Activity'];
            PartnerFundClaim claim1 = Core_MDF_CCP_TestDataUtility.createRetailRSAMDClaim(Core_MDF_CCP_TestDataUtility.claim_RecordType_Retail, pfr.Id, System.today(), System.today(), 50.00, false);
            claim1.Core_MDF_Country_Location_nm__c= 'AFGHANISTAN';
            claim1.Title = 'RSA MD Level Two Node Claim';            
            /*POP mandatory for Retail*/
            List<String> documentIdWithTitle = new List<String>();
            list<String> tempString = new list<String>();
            list<Core_MDF_Audit_Document__c> auditDocList = new list<Core_MDF_Audit_Document__c>();
            
            String str1 = claim1.Id+';#'+'Test Doc1';
            String str2 = claim1.Id+';#'+'Test Doc2';
            system.debug('str2' +str2);
            
            documentIdWithTitle.add(str1);
            documentIdWithTitle.add(str2);
            
            for(String str: documentIdWithTitle){
                tempString = str.split(';#');
                Core_MDF_Audit_Document__c auditDoc = new Core_MDF_Audit_Document__c();
                auditDoc.Core_MDF_Document_Id__c = tempString[0];
                auditDoc.Core_MDF_Document_Title__c = tempString[1];
                auditDoc.Core_MDF_Claim__c = claim1.Id;
                auditDoc.Core_MDF_Proof_of_Branding__c = true;
                auditDoc.Core_MDF_Proof_of_Cost__c = true;
                auditDoc.Core_MDF_Proof_of_Execution__c = true;                
                auditDocList.add(auditDoc);
                system.debug('auditDocList-->' +auditDocList);
            }            
            
            if(auditDocList.size()>0){
                Database.insert(auditDocList);                
            }
            
            String res = Core_MDF_PartnerFundClaim.saveClaim(claim1, auditDocList);            
            System.assertEquals(claim1.ID,res);            
            test.stopTest();
        }
    }    
    
    
}