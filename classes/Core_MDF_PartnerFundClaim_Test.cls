/****************************************************************************************************************************************
* Class Name  : Core_MDF_PartnerFundClaim_Test
* Version     : 1.0 
* Created Date: 21-Oct-2018
* Modification Log :
* Developer                        Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture-Anjali/Ameya          21/Oct/2018                    Created to test PartnerFundClaim Processes & Record Sharing Functionality
*****************************************************************************************************************************************/
@isTest
private class Core_MDF_PartnerFundClaim_Test {
    
    
    /* Method to Setup Test Data */
    @testSetup 
    static void setup() {  
        
        ChannelProgram cp = Core_MDF_CCP_TestDataUtility.createProgram ('Client Co-Marketing Fund','Client CoMarketing Fund', true);
        
        Account acc1 = Core_MDF_CCP_TestDataUtility.createIntelAccount('Test Acc New 1', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, true);
        //insert acc1;
        //acc1.Core_MDF_CoMarketingActive__c = true;
        //update acc1;
        
        List<Contact> listContact = new List<Contact>();
        Contact conRecord1 = Core_MDF_CCP_TestDataUtility.createContact(acc1.Id,false);
        Contact conRecord2 = Core_MDF_CCP_TestDataUtility.createContact(acc1.Id,false);
        
        listContact.add(conRecord1);
        listContact.add(conRecord2);
        
        Database.insert(listContact);
        
        Id profileId = [SELECT Id FROM Profile WHERE Name='Partner' limit 1].Id;
        Profile ccpCoreProfile = [SELECT Id FROM Profile WHERE Name='CCP - Core Access' LIMIT 1];
        PermissionSet clmCaseRevPS = [SELECT Id, Name FROM PermissionSet WHERE Name='Core_MDF_CCP_Internal_Claim_Case_Reviewer' LIMIT 1];
        
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
        
        User usr3 = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr3.Email = 'sysadmin@example.com';
        listUser.add(usr3);
        
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
        
        Account acc2 = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test Acc New 2', cp.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, acc1.Id, true);
        PartnerMarketingBudget budget = Core_MDF_CCP_TestDataUtility.createBudget('Test Budget New',Core_MDF_CCP_TestDataUtility.budget_Record_Type,acc2.Id,cp.Id,200000,System.today().addDays(-20),System.today().addDays(40), true);
        
        //budget.IsIgnoreValidation = true;
        //update budget;
        
        PartnerFundAllocation allocation = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('Test Allocation New',budget,acc2,200.0,true);
        
        Campaign camp = Core_MDF_CCP_TestDataUtility.createCampaign('Test Camp 13','Gaming','Intel® Core™ i7 Processor', Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 'Client CoMarketing Fund', System.today().addDays(-15), System.today().addDays(15), 10000, 'Always Connected PC', acc2.Id,'Desktop', true); 
        
        PartnerFundRequest testPartnerFundRequest = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(String.valueof(camp.Id), 
                                                                                                          Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,
                                                                                                          String.valueof(acc2.id),allocation,null,'INDIA',
                                                                                                          'Consumer',
                                                                                                          'Desktop',
                                                                                                          'Intel® Core™ i5 Processor',
                                                                                                          'Broadcast',
                                                                                                          'Podcast',
                                                                                                          'Draft',
                                                                                                          false);
        
        
        testPartnerFundRequest.Core_MDF_Start_Date__c = system.today().addDays(-5);
        testPartnerFundRequest.Core_MDF_End_Date__c  = system.today().addDays(5);
        testPartnerFundRequest.Core_MDF_Country_nm__c = 'INDIA';
        testPartnerFundRequest.amount = 0;
        insert testPartnerFundRequest;
        //inserting currency data
        
        Core_MDF_CCP_TestDataUtility.insertCurrencyExchangeRates();
        
        List<Core_MDF_Bank__c> listBank = new List<Core_MDF_Bank__c>();
        List<Core_MDF_Bank__c> bankList = new List<Core_MDF_Bank__c>();
        
        //Core_MDF_CCP_TestDataUtility.createPartnerGroupMapping(acc1.Id,'Internal',acc1.Id,cp.Id,'PGM_TEST',true);
        //Core_MDF_CCP_TestDataUtility.createPartnerNodeUserMapping(acc2.Id, Usr1.Id, true);
        
        
        Core_MDF_Bank__c bank = Core_MDF_CCP_TestDataUtility.createBank(acc1.Id, 'Core_MDF_Client_CoMarketing_Fund', false,'1231231230');
        listBank.add(bank);
        
        Core_MDF_Bank__c bank1 = Core_MDF_CCP_TestDataUtility.createBank(acc1.Id, 'Core_MDF_Client_CoMarketing_Fund', false,'1241241240');
        listBank.add(bank1); 
        
        Core_MDF_Bank__c bank2 = Core_MDF_CCP_TestDataUtility.createBank(acc1.Id, 'Core_MDF_Client_CoMarketing_Fund', false,'1249641240');
        listBank.add(bank2);
        test.startTest();
        Database.insert(listBank);
                
        bank.Core_MDF_Bank_Alias_Name__c='TestActiveBank1';
        BankList.add(bank);
        
        bank1.Core_MDF_Bank_Alias_Name__c='TestActiveBank2';
    BankList.add(bank1);              
        
        bank2.Core_MDF_Bank_Alias_Name__c='TestActiveBank3';
        BankList.add(bank2); 
        
        Database.update(BankList);
        
        List<Core_MDF_Account_Bank_Mapping__c> abmList = new List<Core_MDF_Account_Bank_Mapping__c>();
        //creating ABM for bank1
        Core_MDF_Account_Bank_Mapping__c abm1 = Core_MDF_CCP_TestDataUtility.createAccountBankMap(acc2.Id,bank1.Id,false);
        abmList.add(abm1);
        //creating ABM for bank2
        Core_MDF_Account_Bank_Mapping__c abm = Core_MDF_CCP_TestDataUtility.createAccountBankMap(acc2.Id,bank2.Id,false);
        abmList.add(abm);
        Database.insert(abmList);
        abm.Core_MDF_Active_ind__c=false;
        Database.update(abm);

        //Escalation
        //Core_MDF_CCP_TestDataUtility.createEscalation();
        Id claimRecType = Schema.SObjectType.Core_MDF_Escalation__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_Late_Claim').getRecordTypeId();
        Core_MDF_Escalation__c esc1 = new Core_MDF_Escalation__c();
        esc1.Core_MDF_Escalation_Status_nm__c='Pending Review';
        esc1.Core_MDF_Escalation_Name_txt__c='TestEscalation';
        esc1.Core_MDF_Total_Dollar_Impact_amt__c= 23;
        esc1.Core_MDF_Root_Cause_nm__c = 'Tools and Systems';
        esc1.Core_MDF_Co_Marketing_Activity_id__c = testPartnerFundRequest.Id;
        esc1.Core_MDF_Channel_Program_id__c = cp.Id;
        esc1.recordtypeid= claimRecType;
        Database.insert(esc1);
        
        Core_MDF_CCP_TestDataUtility.createPartnerGroupMapping(acc1.Id,'Internal',acc1.Id,cp.Id,'PGM_TEST',true);
        
        Core_MDF_CCP_TestDataUtility.createPartnerNodeUserMapping(acc2.Id, Usr1.Id, true);
        
        List<PartnerFundClaim> pfcList = new List<PartnerFundClaim>();
        PartnerFundClaim utilityClaim = Core_MDF_CCP_TestDataUtility.createClaim('UtilityClaim', Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, testPartnerFundRequest.Id, System.today(), System.today(), 50.00, System.today(), bank1.Id, false);
        utilityClaim.Core_MDF_Media_Vehicle__c='Test1';
        pfcList.add(utilityClaim);
        
        PartnerFundClaim utilityDuplicateClaim = Core_MDF_CCP_TestDataUtility.createClaim('UtilityDuplicateClaim', Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, testPartnerFundRequest.Id, System.today(), System.today(), 50.00, System.today(), bank1.Id, false);
        utilityDuplicateClaim.Core_MDF_Media_Vehicle__c = 'Test Media';
        pfcList.add(utilityDuplicateClaim);
        
        Database.insert(pfcList);
        test.stopTest();
        
        Core_MDF_CCP_TestDataUtility.createTriggerExecutionRecords();
        
    }
    
    /* Method to test save claim */
    @isTest
    static void testSaveClaimSuccessMethod()
    {
        User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        System.runAs(sysAdminUser)
        {
            test.startTest();
            Core_MDF_Bank__c bank1 = [Select Id from Core_MDF_Bank__c where Core_MDF_Bank_Alias_Name__c='TestActiveBank2' limit 1];
            PartnerFundRequest pfr = [Select Id,Title from PartnerFundRequest where Title = 'test'];
            PartnerFundClaim claim1 = Core_MDF_CCP_TestDataUtility.createClaim('Test Claim', Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, pfr.Id, System.today(), System.today(), 50.00, System.today(), bank1.Id, false);
            claim1.Core_MDF_Currency__c='USD';//INR
            list<Core_MDF_Audit_Document__c> auditDocList = new list<Core_MDF_Audit_Document__c>();
            String res = Core_MDF_PartnerFundClaim.saveClaim(claim1, auditDocList);            
            System.assertEquals(claim1.ID,res);
            
            test.stopTest();
        }
    }
    
    /*POP*/
    @isTest
    static void testPOPdocForSaveClaimMethod()
    {
        User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        System.runAs(sysAdminUser)
        {
            test.startTest();
            Core_MDF_Bank__c bank1 = [Select Id from Core_MDF_Bank__c where Core_MDF_Bank_Alias_Name__c='TestActiveBank2' limit 1];
            PartnerFundRequest pfr = [Select Id,Title from PartnerFundRequest where Title = 'test'];
            
            PartnerFundClaim claim1 = Core_MDF_CCP_TestDataUtility.createClaim('Test Claim', Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, pfr.Id, System.today(), System.today(), 50.00, System.today(), bank1.Id, true);
            
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
                auditDoc.Core_MDF_Document_Types__c = 'Proof of Cost;Proof of Branding;Proof of Execution';
                auditDoc.Core_MDF_App_Document_Types_nm__c = 'Proof of Cost;Proof of Branding;Proof of Execution';              
                auditDocList.add(auditDoc);
                
                 Core_MDF_Audit_Document__c auditDoc1 = new Core_MDF_Audit_Document__c();
                auditDoc1.Core_MDF_Document_Id__c = tempString[0];
                auditDoc1.Core_MDF_Document_Title__c = tempString[1];
                auditDoc1.Core_MDF_Document_Types__c = 'Proof of Cost;Proof of Branding;Proof of Execution';
                auditDoc1.Core_MDF_App_Document_Types_nm__c = 'Proof of Cost;Proof of Branding;Proof of Execution';
                auditDocList.add(auditDoc1);
                system.debug('auditDocList-->' +auditDocList);
            }
            
            String res = Core_MDF_PartnerFundClaim.saveClaim(claim1, auditDocList);            
            System.assertEquals(claim1.ID,res);
            
            test.stopTest();
        }
    }
    /*POP*/
    
    /*POP*/
    @isTest
    static void testPOPdocForSaveUpdateClaimMethod()
    {
        User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        System.runAs(sysAdminUser)
        {
            test.startTest();
            Core_MDF_Bank__c bank1 = [Select Id from Core_MDF_Bank__c where Core_MDF_Bank_Alias_Name__c='TestActiveBank2' limit 1];
            PartnerFundRequest pfr = [Select Id,Title from PartnerFundRequest where Title = 'test'];
            PartnerFundClaim utilityClaim = Core_MDF_CCP_TestDataUtility.createClaim('Test Claim', Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, pfr.Id, System.today(), System.today(), 50.00, System.today(), bank1.Id, true);  

            // Creating Case
            
            Id caseAuditRecType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Core_MDF_Audit').getRecordTypeId();
            Account caseAcc = [Select id from Account where Name = 'Test Acc New 2'];
            Case cs = new Case();
            cs.recordTypeId = caseAuditRecType;
            cs.AccountId = caseAcc.Id;
            cs.OwnerId = sysAdminUser.Id;
            Database.insert(cs);
            
            utilityClaim.Core_MDF_Claim_Review_Case__c = cs.id;
            Database.update(utilityClaim);
            
            List<String> documentIdWithTitle = new List<String>();
            list<String> tempString = new list<String>();
            list<Core_MDF_Audit_Document__c> auditDocList = new list<Core_MDF_Audit_Document__c>();
            
            String str1 = utilityClaim.Id+';#'+'Test Doc1';
            String str2 = utilityClaim.Id+';#'+'Test Doc2';
            
            documentIdWithTitle.add(str1);
            documentIdWithTitle.add(str2);
            
            for(String str: documentIdWithTitle){
                tempString = str.split(';#');
                Core_MDF_Audit_Document__c auditDoc = new Core_MDF_Audit_Document__c();
                auditDoc.Core_MDF_Document_Id__c = tempString[0];
                auditDoc.Core_MDF_Document_Title__c = tempString[1];
                auditDoc.Core_MDF_Claim__c = utilityClaim.Id;
                auditDoc.Core_MDF_Document_Types__c = 'Proof of Cost;Proof of Branding;Proof of Execution';
                auditDoc.Core_MDF_App_Document_Types_nm__c = 'Proof of Cost;Proof of Branding;Proof of Execution';               
                auditDocList.add(auditDoc);
            }            
            
            String res = Core_MDF_PartnerFundClaim.saveClaim(utilityClaim,auditDocList);
            System.assertEquals(utilityClaim.ID,res);
            
            test.stopTest();
        }
    }
    /*POP*/
    
    
    /* Method to test fail scenerio of save claim */
    @isTest
    static void testSaveClaimFailedMethod()
    {
        test.startTest();
        User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        System.runAs(sysAdminUser)
        {
            PartnerFundClaim claim = null;
            List<Core_MDF_Audit_Document__c> listDoc =  new List<Core_MDF_Audit_Document__c>();
            String res = Core_MDF_PartnerFundClaim.saveClaim(claim,listDoc);
            System.assertEquals(res,'');
        }
        test.stopTest();
    }
    
    
    /* Method to test exception scenerio of save claim */
    @isTest
    static void testSaveClaimExcMethod()
    {
        try{
            User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
            System.runAs(sysAdminUser)
            {
                test.startTest();
                PartnerFundClaim claim = new PartnerFundClaim();
                List<Core_MDF_Audit_Document__c> listDoc =  new List<Core_MDF_Audit_Document__c>();
                String res = Core_MDF_PartnerFundClaim.saveClaim(claim,listDoc);            
                test.stopTest();
            }
        }catch(Exception e){
            System.assertNotEquals(null,e);
        }
    }
    
    /* Method to test fetch activity details */
    @isTest
    static void testFetchActivityMethod()
    {
        User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        System.runAs(sysAdminUser)
        {
            test.startTest();
            PartnerFundRequest pfr = [Select Id,Title from PartnerFundRequest where Title = 'test'];   
            PartnerFundRequest pfrObj = Core_MDF_PartnerFundClaim.getActivityFields(pfr.Id);
            Core_MDF_PartnerFundClaim.createClaimWrapper claimWrapper = Core_MDF_PartnerFundClaim.checkClaimFromActivity('PartnerFundClaim',pfr.Id);
            System.assertNotEquals(claimWrapper.activityObj , NULL);
            test.stopTest();
        }
    }
    
    /* Method to test fetch activity details */
    @isTest
    static void testFetchActivityMethodFail()
    {
        User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        System.runAs(sysAdminUser)
        {
            test.startTest();
            PartnerFundRequest pfr = [Select Id,Title from PartnerFundRequest where Title = 'test'];   
            PartnerFundRequest pfrObj = Core_MDF_PartnerFundClaim.getActivityFields(pfr.Id);
            Core_MDF_PartnerFundClaim.createClaimWrapper claimWrapper = Core_MDF_PartnerFundClaim.checkClaimFromActivity('ABC',pfr.Id);
            system.assertEquals(claimWrapper, null);
            test.stopTest();
        }
    }
    
    /* Method to test exception scenerio while fetching activity details */
    @isTest
    static void testFetchActivityExcMethod()
    {
        try{
            User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
            System.runAs(sysAdminUser)
            {
                test.startTest();
                PartnerFundRequest testPartnerFundRequest = null;
                PartnerFundRequest pfrObj = Core_MDF_PartnerFundClaim.getActivityFields(testPartnerFundRequest.Id);                
                test.stopTest();
            }
        }catch(Exception e){
            System.assertNotEquals(NULL,e);
        }
    }
    
    /* Method to test fetch pick list values */
    @isTest
    static void testGetPickListValuesMethod()
    {
        test.startTest();
        User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        System.runAs(sysAdminUser)
        {
            String objName = 'PartnerFundClaim';
            String apiName = 'Core_MDF_Currency__c';Core_MDF_PartnerFundClaim.userAndPicklistInfoWrapper userAndPicklistWrap = Core_MDF_PartnerFundClaim.fetchUserAndPicklistInfo(objName,apiName);
            system.assertNotEquals(userAndPicklistWrap.pickListValuesMap, null);
        }
        test.stopTest();
    }
    
    /* Method to test fetch pick list values */
    @isTest
    static void testGetPickListValuesMethodFail()
    {
        test.startTest();
        Map<String,String> emptyMap = new Map<String,String>();
        User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        System.runAs(sysAdminUser)
        {
            String objName = 'ABC';
            String apiName = 'Core_MDF_Currency__c';
            Core_MDF_PartnerFundClaim.userAndPicklistInfoWrapper userAndPicklistWrap = Core_MDF_PartnerFundClaim.fetchUserAndPicklistInfo(objName,apiName);
            system.assertNotEquals(userAndPicklistWrap.pickListValuesMap, null);
        }
        test.stopTest();
    }
    
    
    /* Method to test fetch bank records */
    @isTest
    static void testFetchBanksMethod()
    {
        User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        System.runAs(sysAdminUser)
        {
            test.startTest();
            Account accBank = [Select Id,Name from Account where Name = 'Test Acc New 1'];
            List<sObject> listOfBanks = Core_MDF_PartnerFundClaim.fetchBankRecords(accBank.Id);
            system.assertNotEquals(listOfBanks,null);
            test.stopTest();
        }
    }
    
    /* Method to test duplicate check on claim */
    @isTest
    static void testDupicateClaimCheckMethod()
    {
        User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        System.runAs(sysAdminUser)
        {
            test.startTest();
            List<PartnerFundClaim> claimList= new List<PartnerFundClaim>();
            Core_MDF_Bank__c bank1 = [Select Id from Core_MDF_Bank__c where Core_MDF_Bank_Alias_Name__c='TestActiveBank2' limit 1];
            PartnerFundRequest pfr = [Select Id,Title from PartnerFundRequest where Title = 'test'];
            system.assertEquals(pfr.Title, 'test');
            PartnerFundClaim claim1 = Core_MDF_CCP_TestDataUtility.createClaim('Test Claim', Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, pfr.Id, System.today(), System.today(), 52.00, System.today(), bank1.Id, true);
            claim1.Core_MDF_Media_Vehicle__c = 'test3'+System.now();
            claim1.Core_MDF_Currency__c='USD';
            Database.update(claim1);
            PartnerFundClaim claim2 = Core_MDF_CCP_TestDataUtility.createClaim('Test Claim', Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, pfr.Id, System.today(), System.today(), 52.00, System.today(), bank1.Id, true);
            claim1.Core_MDF_Currency__c='USD';
            Database.update(claim1);
            PartnerFundClaim claim3 = Core_MDF_CCP_TestDataUtility.createClaim('Test Claim', Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, pfr.Id, System.today(), System.today(), 51.00, System.today(), bank1.Id, true);
            claim1.Core_MDF_Currency__c='USD';
            Database.update(claim1);
            claimList.add(claim1);
            claimList.add(claim2);
            claimList.add(claim3);
            List<PartnerFundClaim> res2 = Core_MDF_Claim_Utility.duplicateClaimCheckOnInsert(claimList);
            Map<Id,PartnerFundClaim> claimMap = new Map<Id,PartnerFundClaim>();
            for(PartnerFundClaim pfc : claimList)
            {
                claimMap.put(pfc.Id,pfc);
            }
            List<PartnerFundClaim> claimList2= new List<PartnerFundClaim>();
            claimList2.add(claim1);
            claim2.Core_MDF_Media_Vehicle__c = 'test3';
            claim2.Core_MDF_Invoice_Number__c = 'test3';
            claimList2.add(claim2);
            claim3.Core_MDF_Media_Vehicle__c = 'test3'+System.now();
            claim3.Core_MDF_Invoice_Number__c = 'test3'+System.now();
            claimList2.add(claim3);
            Database.update(claimList2);
            Core_MDF_Claim_Utility.duplicateClaimCheckOnUpdate(claimList2, claimMap);
            Core_MDF_PartnerFundClaim.duplicateClaimCheck(claim2);
            //system.assertNotEquals(res3.size(),0);
            test.stopTest();
        }
    }
    
    /* Test Method to Check the OwnerID Change of the Claim Record */
    @isTest
    static void testClaimOwnerChange()
    {
        test.startTest();
        PartnerFundClaim claim1 = new PartnerFundClaim();
        Map<Id,PartnerFundClaim> claimsMap= new Map<Id,PartnerFundClaim>(); 
        List<PartnerFundClaim> claimList= new List<PartnerFundClaim>();
        ChannelProgram cp = [SELECT id FROM ChannelProgram limit 1];
        Account acc1 = [SELECT id from Account where Name = 'Test Acc New 1' limit 1];
        User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        System.runAs(sysAdminUser)
        {
            
            Core_MDF_Bank__c bank1 = [Select Id,Core_MDF_Bank_Alias_Name__c from Core_MDF_Bank__c where Core_MDF_Bank_Alias_Name__c='TestActiveBank2' limit 1];
            PartnerFundRequest pfr = [Select Id from PartnerFundRequest where Title = 'test'];
            claim1 = Core_MDF_CCP_TestDataUtility.createClaim('Test Claim', Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, pfr.Id, System.today(), System.today(), 50.00, System.today(), bank1.Id, false);
            claim1.Amount = 100;
            //chnages here
            claim1.Core_MDF_Currency__c = 'USD';
            claim1.Core_MDF_Total_Invoice_Amount_Local__c = 100;
            Database.insert(claim1);
            claimsMap.put(claim1.Id, claim1); 
        }     
        claim1.ownerId = UserInfo.getUserId();
        claim1.Core_MDF_Currency__c='USD';
        Database.update(claim1); 
        claimList.add(claim1);       
        system.assertNotEquals(claimsMap.size(), NULL);
        Core_MDF_PFC_Sharing.recalculateShareClaimWhenOwnerChange(claimList, claimsMap);
        
        test.stopTest();
    }
    
    /* Method to test fetch claim record by Id */
    @isTest
    public static void testFetchClaimById(){
        User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        System.runAs(sysAdminUser)
        {
            test.startTest();
           
            PartnerFundClaim claim = [Select id from PartnerFundClaim where Title = 'UtilityClaim'];
            String recordId = claim.Id;
            PartnerFundClaim pfc = Core_MDF_PartnerFundClaim_Edit.fetchClaimById(recordId).claimObj;
            PartnerFundClaim pfcClone = Core_MDF_PartnerFundClaim_Edit.prepareCloneData(recordId).claimObj;
            system.assertEquals(pfc.Id, recordId); 
            test.stopTest();
        }
    }
    
    // Method to Edit claim - calculate fields
    @isTest
    public static void testEditClaimCalculateFields(){
        User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        System.runAs(sysAdminUser)
        {
            test.startTest();
            PartnerFundClaim claim = [Select Id,Title, Core_MDF_Total_Invoice_Amount_Local__c from PartnerFundClaim where Title = 'UtilityClaim'];
            claim.Core_MDF_Total_Invoice_Amount_Local__c = 20;
            update claim;
            system.assertEquals(20,claim.Core_MDF_Total_Invoice_Amount_Local__c );
            test.stopTest();
        }
    }
    
    // Method to Edit claim - duplicate check
    /*@isTest
    public static void testEditClaimDuplicateCheck(){
        User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        
        System.runAs(sysAdminUser)
        {
            test.startTest();
            PartnerFundClaim claim1 = [Select Id,Title,Amount, Core_MDF_Total_Invoice_Amount_Local__c,Core_MDF_Media_Vehicle__c,Core_MDF_Duplicate_Claim__c from PartnerFundClaim where Title = 'UtilityDuplicateClaim'];
            PartnerFundClaim claim = [Select Id,Title,Amount, Core_MDF_Total_Invoice_Amount_Local__c,Core_MDF_Media_Vehicle__c,Core_MDF_Duplicate_Claim__c from PartnerFundClaim where Title = 'UtilityClaim'];
            claim.Core_MDF_Media_Vehicle__c = 'Test Media';
            claim.Core_MDF_Ad_Run_Start_Date__c = System.today();
            claim.Core_MDF_Ad_Run_End_Date__c = System.today();
            claim.Core_MDF_Invoice_Number__c = ;
            claim.Core_MDF_Total_Invoice_Amount_Local__c = ;
            Database.update(claim);
            system.assertEquals(true,claim.Core_MDF_Duplicate_Claim__c);
            test.stopTest();
        }
    }*/
    
    /* Method to check audit internal user */
    @isTest
    static void testInternalAuditUser()
    {
        test.startTest();
        User ccrUser = [SELECT Id,Email from User where Email='testCCR@example.com' limit 1];
        //User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_Claim_Case_Reviewer_Manager'];
        PermissionSetAssignment psa = new PermissionSetAssignment();
        psa.AssigneeId = ccrUser.Id;
        psa.PermissionSetId = ps.Id;
        Database.insert(psa);        
        System.runAs(ccrUser){
            system.assertEquals(true,Core_MDF_PartnerFundClaim.isInternalAuditUser(System.Label.Core_MDF_ClaimEditAccessToAuditUser));  
        }
        test.stopTest();
    }
    
    
    /* Method to check audit internal user */
    @isTest
    static void testInternalAuditUserFail()
    {
        User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        System.runAs(sysAdminUser)
        {
            system.assertEquals(false,Core_MDF_PartnerFundClaim.isInternalAuditUser(System.Label.Core_MDF_ClaimEditAccessToAuditUser));
        }
    }
    
    /* Method to test fetch activity details */
    @isTest
    static void testFetchRecordTypeMetaData()
    {
        User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        System.runAs(sysAdminUser)
        {
            Map<String,Core_MDF_ClaimActAllocRecTypeMapping__mdt> mapOfRecordTypes = Core_MDF_PartnerFundClaim.fetchRecordTypeMetaData();
            system.assertNotEquals(mapOfRecordTypes, null);
        }
    }
    
    /* Method to test clone claim Permissions */
    @isTest
    public static void testCloneClaimPermission(){
        User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        System.runAs(sysAdminUser)
        {
            boolean hasCloneAccess = Core_MDF_PartnerFundClaim_Edit.isClaimEligibleForClone();
            system.assertEquals(true,hasCloneAccess);
        }
    }
    
    @isTest
    public static void testDoesNothaveCloneClaimPermission(){
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'Core_MDF_CCP_External_View_Only'];
        User usr2 = [ SELECT Id FROM User WHERE Email='test123@example.com'];
        PermissionSetAssignment psa = new PermissionSetAssignment();
        psa.AssigneeId = usr2.Id;
        psa.PermissionSetId = ps.Id;
        insert psa;
        System.runAs(usr2){
            boolean hasCloneAccess = Core_MDF_PartnerFundClaim_Edit.isClaimEligibleForClone();
            system.assertEquals(false,hasCloneAccess);
        }        
    } 
    
    /* Method to test fecth user details */
    @isTest
    public static void testFetchUserDetails(){
        User ccrUser = [SELECT Id,Email from User where Email='testCCR@example.com' limit 1];
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_Claim_Case_Reviewer_Manager'];
        PermissionSetAssignment psa = new PermissionSetAssignment();
        psa.AssigneeId = ccrUser.Id;
        psa.PermissionSetId = ps.Id;
        Database.insert(psa);        
        System.runAs(ccrUser)
        {
            Core_MDF_PartnerFundClaim.userInfoWrapper userInfoWrapper = Core_MDF_PartnerFundClaim.fetchUserDetails();
            system.assertEquals(true, userInfoWrapper.isUserClaimCaseReviewerOrManager);
        }
    }
    
    /* Method to test save claim with escalation */
    @isTest
    static void testSaveClaimWithEscalation()
    {
        test.startTest();
        User ccrUser = [SELECT Id,Email from User where Email='testCCR@example.com' limit 1];
        Core_MDF_Bank__c bank1 = [Select Id from Core_MDF_Bank__c where Core_MDF_Bank_Alias_Name__c='TestActiveBank2' limit 1];
        PartnerFundRequest pfr = [Select Id,Title from PartnerFundRequest where Title = 'test'];
        Core_MDF_Escalation__c escalation = [Select Id from Core_MDF_Escalation__c where Core_MDF_Escalation_Name_txt__c='TestEscalation'];
        //Core_MDF_Escalation__c resEscalation = [Select Id from Core_MDF_Escalation__c where Id=:escalation.Id];
        System.runAs(ccrUser)
        {
            //test.startTest();      
            PartnerFundClaim claim1 = Core_MDF_CCP_TestDataUtility.createClaim('Test Claim', Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, pfr.Id, System.today(), System.today(), 50.00, System.today(), bank1.Id, false);
            claim1.Core_MDF_Escalation_Id__c = escalation.Id;
            claim1.Core_MDF_Currency__c='USD';//INR
            List<Core_MDF_Audit_Document__c> listDoc =  new List<Core_MDF_Audit_Document__c>();
            String res = Core_MDF_PartnerFundClaim.saveClaim(claim1,listDoc);            
            Core_MDF_PartnerFundClaim.getEscalationFields(escalation.Id);       
            system.assertEquals(claim1.Id , res);
            //test.stopTest();
        }
        test.stopTest();
    }
    /*Method to test inactive ABM while claim creation*/
    @isTest
    static void testInactiveABM()
    {
        test.startTest();
        PartnerFundRequest pfr = [Select Id,Title from PartnerFundRequest where Title = 'test'];
        Core_MDF_Bank__c bank2 = [SELECT Id FROM Core_MDF_Bank__c WHERE Core_MDF_Bank_Alias_Name__c='TestActiveBank3' LIMIT 1];
        User usr=[SELECT Id FROM User WHERE LastName='Claim Case User' LIMIT 1];
        System.runAs(usr){
            try{
                PartnerFundClaim claim1 = Core_MDF_CCP_TestDataUtility.createClaim('Test Claim V', Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, pfr.Id, System.today(), System.today(), 50.00, System.today(), bank2.Id, false);
                claim1.Core_MDF_Currency__c='USD';
                Database.insert(claim1);//will go to catch block since its ABM is Inactive
            }
            catch(Exception e){
                String errorMessage = e.getMessage();
                System.assert(errorMessage.contains(System.Label.Core_MDF_Claim_Stage_Bank_Error));  
            }
        }
        test.stopTest();
    }

   /*Method to test inactive ABM for claim update scenario*/   
    
    public static void testInactiveABMInClaimUpdate()
    {
        test.startTest();
        Core_MDF_Bank__c bank2 = [SELECT Id FROM Core_MDF_Bank__c WHERE Core_MDF_Bank_Alias_Name__c='TestActiveBank3' LIMIT 1];
        PartnerFundClaim claim = [Select id,Core_MDF_Bank__c from PartnerFundClaim where Title = 'UtilityClaim'];
        User usr=[SELECT Id FROM User WHERE LastName='Claim Case User' LIMIT 1];
        System.runAs(usr){
            try{    
                
                claim.Core_MDF_Bank__c=bank2.Id;
                Database.update(claim);
            }
            catch(Exception e){
                String errorMessage = e.getMessage();
                System.assert(errorMessage.contains(System.Label.Core_MDF_Claim_Stage_Bank_Error));  
            }
        }
        test.stopTest();
    }
    
}