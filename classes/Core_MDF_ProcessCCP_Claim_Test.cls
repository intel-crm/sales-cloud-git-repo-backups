/****************************************************************************************************************************************
* Class Name  : Core_MDF_ProcessCCP_Claim_Test
* Version     : 1.0 
* Created Date: 11-12-2018
* Modification Log :
* Developer                        Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture-JV                    11/12/2018                    Created to test Partner Fund Claim Process functionality. 
*****************************************************************************************************************************************/
@isTest(SeeAllData=false)
private class Core_MDF_ProcessCCP_Claim_Test {
    /****************************************************************************************************************************************
Method Name:                                   setUpData
Description:                                   Created to prepare data for testing 
Added By:                                      Accenture – VD  -  18-Dec-2019
Modified By:           Date:                   Changes: 
Accenture – VD        18-Dec-2019              Refactored to follow best practice
*****************************************************************************************************************************************/   
    @TestSetup static void setUpData(){
        
        ChannelProgram cp = Core_MDF_CCP_TestDataUtility.createProgram ('Client Co-Marketing Fund','Client CoMarketing Fund', true);
        Id profileId = [SELECT Id FROM Profile WHERE Name='Partner' limit 1].Id;
        Profile ccpCoreProfile = [SELECT Id FROM Profile WHERE Name='CCP - Core Access' LIMIT 1];
        PermissionSet clmCaseRevPS = [SELECT Id, Name FROM PermissionSet WHERE Name='Core_MDF_CCP_Internal_Claim_Case_Reviewer' LIMIT 1];
        
        Account accRecord = Core_MDF_CCP_TestDataUtility.createAccount ('Intel Test Account ', NULL, Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);   
        accRecord.BillingCity = 'Test City';         
        accRecord.BillingCountry= 'AUS';
        accRecord.BillingStreet= 'Test Street'; 
        Database.insert(accRecord);   
        
        //Creating Contact for Partner User
        List<Contact> contList = new List<Contact>();
        Contact conRecord1 = Core_MDF_CCP_TestDataUtility.createContact(accRecord.Id,false);
        contList.add(conRecord1);
        Contact conRecord2 = Core_MDF_CCP_TestDataUtility.createContact(accRecord.Id,false);
        contList.add(conRecord2);
        
        Database.insert(contList);
        
        // Creating User with utility class 
        List<User> usrList = new List<User>();
        
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.Email = 'sysadmin@example.com';
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
        
        PermissionSetAssignment assignPermissionSetObj = new PermissionSetAssignment();
        assignPermissionSetObj.AssigneeId = claimCase.Id;
        assignPermissionSetObj.PermissionSetId = clmCaseRevPS.Id;
        system.runas(usr){
            Database.insert(assignPermissionSetObj);
        }
        
        // Creating Intel Account with utility class
        Account dellCorpAccount = Core_MDF_CCP_TestDataUtility.createAccount ('Dell Corporation', NULL,Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);   
        dellCorpAccount.BillingCity = 'Test City';         
        dellCorpAccount.BillingCountry= 'AUS';
        dellCorpAccount.BillingStreet= 'Test Street';
        Database.insert(dellCorpAccount); 
        dellCorpAccount.IsPartner = true;
        dellCorpAccount.Core_MDF_CoMarketingActive__c = true;
        Database.update(dellCorpAccount);
        
        // Creating Co-marketing Account with utility class
        Account dellCCFVirtualCorp = Core_MDF_CCP_TestDataUtility.createAccount ('Dell CCF Virtual Corp', cp.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
        dellCCFVirtualCorp.Core_MDF_Parent_Fund_Account__c = dellCorpAccount.Id;
        Database.insert(dellCCFVirtualCorp);
        
        List<Account> lstVirAcct1 = new List<Account>();
        List<Account> lstVirAcct2 = new List<Account>();
        
        // Creating Co-marketing Account with utility class
        Account dellCCFEMEA = Core_MDF_CCP_TestDataUtility.createAccount ('Dell CCF EMEA', cp.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
        dellCCFEMEA.Core_MDF_Parent_Fund_Account__c = dellCCFVirtualCorp.Id;
        lstVirAcct1.add(dellCCFEMEA);
        
        Account dellCCFAPAC = Core_MDF_CCP_TestDataUtility.createAccount ('Dell CCF APAC', cp.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type,  false);
        dellCCFAPAC.Core_MDF_Parent_Fund_Account__c = dellCCFVirtualCorp.Id;
        lstVirAcct1.add(dellCCFAPAC);
        
        Database.insert(lstVirAcct1);
        
        Test.startTest();
        
        // Creating Co-marketing Account with utility class
        Account dellEMEAFrance = Core_MDF_CCP_TestDataUtility.createAccount ('Dell CCF EMEA France', cp.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
        dellEMEAFrance.Core_MDF_Parent_Fund_Account__c = dellCCFEMEA.Id;
        dellEMEAFrance.Core_MDF_Auto_Transfer_Account__c = dellCCFVirtualCorp.Id;
        dellEMEAFrance.Core_MDF_Enabled_Auto_Transfer__c = True;
        lstVirAcct2.add(dellEMEAFrance);
        
        Account dellCCFAPACIndia = Core_MDF_CCP_TestDataUtility.createAccount ('Dell CCF APAC India', cp.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
        dellCCFAPACIndia.Core_MDF_Parent_Fund_Account__c = dellCCFAPAC.Id;
        dellCCFAPACIndia.Core_MDF_Auto_Transfer_Account__c = dellCCFVirtualCorp.ID;
        dellCCFAPACIndia.Core_MDF_Enabled_Auto_Transfer__c = True;
        lstVirAcct2.add(dellCCFAPACIndia);
        
        Database.insert(lstVirAcct2);
        
        Core_MDF_CCP_TestDataUtility.createPartnerGroupMapping(dellCorpAccount.Id,'Internal',dellCorpAccount.Id,cp.Id,'PGM_TEST',true);
        
        Core_MDF_CCP_TestDataUtility.createPartnerNodeUserMapping(dellCCFAPACIndia.Id, Usr1.Id, true);
        
        // Create PMB for the above Account 
        PartnerMarketingBudget  pmbRecord = Core_MDF_CCP_TestDataUtility.createBudget('Dell PMB',Core_MDF_CCP_TestDataUtility.budget_Record_Type,dellCCFVirtualCorp.Id,cp.Id,100000,System.today().addDays(-15),System.today().addDays(15),true);
        
        // Create PFA records for the above accounts :
        List<PartnerFundAllocation> pfaList = new List<PartnerFundAllocation>();
        PartnerFundAllocation pfaDellCCFVirtualCorp = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('pfaDellCCFVirtualCorp',pmbRecord, dellCCFVirtualCorp, 10000,false);
        pfaList.add(pfaDellCCFVirtualCorp);
        PartnerFundAllocation pfaDellCCFEMEA = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('pfaDellCCFEMEA',pmbRecord, dellCCFEMEA, 1000, false);
        pfaList.add(pfaDellCCFEMEA);
        PartnerFundAllocation pfaDellCCFAPAC = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('pfaDellCCFAPAC',pmbRecord, dellCCFAPAC, 1000,false);
        pfaList.add(pfaDellCCFAPAC);
        PartnerFundAllocation pfaDellCCFFrance = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('pfaDellCCFFrance',pmbRecord, dellEMEAFrance, 1000, false);
        pfaList.add(pfaDellCCFFrance);
        PartnerFundAllocation pfaDellCCFIndia = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('pfaDellCCFIndia',pmbRecord, dellCCFAPACIndia, 1000,false);
        pfaList.add(pfaDellCCFIndia);
        
        Database.insert(pfaList);
        
        Campaign camp = Core_MDF_CCP_TestDataUtility.createCampaign('Test Camp 12','Gaming','Intel® Core™ i7+ Processor', Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 'Client CoMarketing Fund', System.today().addDays(-10), System.today().addDays(+10), 10000, 'Consumer Chromebook', dellCCFVirtualCorp.Id, '2-in-1', true); 
        
        //Test.stopTest();
        
        List<PartnerFundRequest> pfrList = new List<PartnerFundRequest>();
        PartnerFundRequest franceActivity = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(String.valueof(camp.Id), 
                                                                                                  Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,
                                                                                                  String.valueof(dellEMEAFrance.id),pfaDellCCFFrance,pmbRecord,'INDIA',
                                                                                                  'Consumer',
                                                                                                  'Desktop',
                                                                                                  'Intel® Core™ i5 Processor',
                                                                                                  'Broadcast',
                                                                                                  'Podcast',
                                                                                                  'Draft',
                                                                                                  false);
        franceActivity.Title = 'France Activity';
        franceActivity.Core_MDF_Activity_Description__c = 'France Activity';
        franceActivity.Core_MDF_Start_Date__c = System.today().addDays(-5);
        franceActivity.Core_MDF_End_Date__c = System.today().addDays(+5);
        franceActivity.RequestedAmount = 1000;
        franceActivity.Core_MDF_pagespayingfor__c = 15;
        franceActivity.Amount=0;
        pfrList.add(franceActivity);
        
        
        PartnerFundRequest indiaActivity = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(camp.Id),Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,
                                                                                                 string.valueof(dellCCFAPACIndia.id),pfaDellCCFIndia,pmbRecord,
                                                                                                 'ANGOLA','Consumer','Desktop','Intel® Core™ i5 Processor','Broadcast','Podcast','Draft'
                                                                                                 ,false);
        indiaActivity.Title = 'indiaActivity';
        indiaActivity.Core_MDF_Activity_Description__c = 'indiaActivity';
        indiaActivity.Core_MDF_Start_Date__c = System.today().addDays(-5);
        indiaActivity.Core_MDF_End_Date__c = System.today().addDays(+5);
        indiaActivity.RequestedAmount = 100;
        indiaActivity.Core_MDF_Channel_Partner_Led__c = True;
        indiaActivity.Amount=0;
        pfrList.add(indiaActivity);
        
        PartnerFundRequest indiaActivity1 = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(camp.Id),Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,
                                                                                                 string.valueof(dellCCFAPAC.id),pfaDellCCFIndia,pmbRecord,
                                                                                                 'ANGOLA','Consumer','Desktop','Intel® Core™ i5 Processor','Broadcast','Podcast','Draft'
                                                                                                 ,false);
        indiaActivity1.Title = 'indiaActivity1';
        indiaActivity1.Core_MDF_Activity_Description__c = 'indiaActivity';
        indiaActivity1.Core_MDF_Start_Date__c = System.today().addDays(-5);
        indiaActivity1.Core_MDF_End_Date__c = System.today().addDays(+5);
        indiaActivity1.RequestedAmount = 100;
        indiaActivity1.Core_MDF_Channel_Partner_Led__c = True;
        indiaActivity1.Amount=0;
        pfrList.add(indiaActivity1);
        
        Database.insert(pfrList);
        Test.stopTest();
        Core_MDF_CCP_TestDataUtility.insertCurrencyExchangeRates();
        
        Core_MDF_Bank__c indiaBank = Core_MDF_CCP_TestDataUtility.createBank(dellCorpAccount.Id, 'Core_MDF_Client_CoMarketing_Fund', true,'1231231230');
        //indiaBank.Core_MDF_Hold_Payments_from_AP_file_ind__c = 'Yes';
        //indiaBank.Core_MDF_Hold_Reason_txt__c = 'Test';        
        //Database.insert(indiaBank);
        
         //creating ABM for indiaBank
        Core_MDF_Account_Bank_Mapping__c abm = Core_MDF_CCP_TestDataUtility.createAccountBankMap(dellCCFAPACIndia.Id,indiaBank.Id,true);
        
        
        List<Core_Trigger_Executions__c> executionList = new List<Core_Trigger_Executions__c>();
        Core_Trigger_Executions__c claimFunctionalityNameTriggerExecution = new Core_Trigger_Executions__c();
        claimFunctionalityNameTriggerExecution.Core_Active__c = true;
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
        Core_Trigger_Executions__c claimFunctionalityNameTriggerExecution3 = new Core_Trigger_Executions__c();
        claimFunctionalityNameTriggerExecution3.Core_Active__c = false;
        claimFunctionalityNameTriggerExecution3.Core_Class_Name__c = 'Core_MDF_PFCServiceHandler';
        claimFunctionalityNameTriggerExecution3.Core_Trigger_Events__c = 'before upate, after update';
        claimFunctionalityNameTriggerExecution3.Core_Object__c = 'PartnerFundClaim';
        claimFunctionalityNameTriggerExecution3.Name = 'checkAndSendClaimsToAudit';
        claimFunctionalityNameTriggerExecution3.Core_Description__c = 'test';
        executionList.add(claimFunctionalityNameTriggerExecution3);
        Core_Trigger_Executions__c claimFunctionalityNameTriggerExecution4 = new Core_Trigger_Executions__c();
        claimFunctionalityNameTriggerExecution4.Core_Active__c = true;
        claimFunctionalityNameTriggerExecution4.Core_Class_Name__c = 'Core_MDF_PFCServiceHandler';
        claimFunctionalityNameTriggerExecution4.Core_Trigger_Events__c = 'before insert, before update';
        claimFunctionalityNameTriggerExecution4.Core_Object__c = 'PartnerFundClaim';
        claimFunctionalityNameTriggerExecution4.Name = 'Core_MDF_chkClaimAmtAgainstActBgtAmt';
        claimFunctionalityNameTriggerExecution4.Core_Description__c = 'description';
        executionList.add(claimFunctionalityNameTriggerExecution4);
        Core_Trigger_Executions__c claimFunctionalityNameTriggerExecution5 = new Core_Trigger_Executions__c();
        claimFunctionalityNameTriggerExecution5.Core_Active__c = true;
        claimFunctionalityNameTriggerExecution5.Core_Class_Name__c = 'Core_MDF_PFCServiceHandler';
        claimFunctionalityNameTriggerExecution5.Core_Trigger_Events__c = 'after update';
        claimFunctionalityNameTriggerExecution5.Core_Object__c = 'PartnerFundClaim';
        claimFunctionalityNameTriggerExecution5.Name = 'reserveFundsforNode';
        claimFunctionalityNameTriggerExecution5.Core_Description__c = 'description';
        executionList.add(claimFunctionalityNameTriggerExecution5);
        
        Database.insert(executionList);

        Core_MDF_CCP_Multicurrency.getExchangeRateAndAmount aObj = new Core_MDF_CCP_Multicurrency.getExchangeRateAndAmount();
        Core_MDF_CCP_Multicurrency.getExchangeRateAndAmount bObj = new Core_MDF_CCP_Multicurrency.getExchangeRateAndAmount();
        Core_MDF_CCP_Multicurrency.getExchangeRateAndAmount cObj = new Core_MDF_CCP_Multicurrency.getExchangeRateAndAmount();
        List<Core_MDF_CCP_Multicurrency.getExchangeRateAndAmount> listvar = new List<Core_MDF_CCP_Multicurrency.getExchangeRateAndAmount>();
        
        aObj.inputCurrency ='ZMK';
        aObj.inputAmount = 250.00;
        aObj.inputDate= System.today();
        bObj.inputCurrency ='INR';
        bObj.inputAmount = 350.00;
        bObj.inputDate= System.today();
        cObj.inputCurrency ='USD';
        cObj.inputAmount = 350.00;
        cObj.inputDate= System.today();
        listvar.add(aObj);
        listvar.add(bObj);
        listvar.add(cObj);
        Core_MDF_CCP_Multicurrency.getUSDExchangeRateBasedOnDate(listvar);
        
    }
    
    // Test method to test fundreservation for Claims whose Amount is less than current Allocation
    @isTest static void testPFCFundReservationScnearioOne(){
        Test.startTest();
        User clmCaseUser = [SELECT Id,Email from User where Email='clmcase@example.com' limit 1];
        User extUser = [SELECT Id,Email from User where Email='test1@example.com' limit 1];
        
        PartnerFundRequest indiaActivity = [SELECT Title,Core_MDF_Start_Date__c from PartnerFundRequest where Title='indiaActivity' limit 1];
        
        Core_MDF_Bank__c indiaBank = [Select ID from Core_MDF_Bank__c limit 1];
        
        List<PartnerFundClaim> claimListToBeProcessed = new List<PartnerFundClaim>();
        
        System.runAs(clmCaseUser){
            
            PartnerFundClaim indiaClaim = Core_MDF_CCP_TestDataUtility.createClaim('India Claim', Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF, 
                                                                                   indiaActivity.Id, 
                                                                                   indiaActivity.Core_MDF_Start_Date__c, indiaActivity.Core_MDF_Start_Date__c, 
                                                                                   101, 
                                                                                   System.today().addDays(-1), indiaBank.ID, false);
            PartnerFundClaim indiaClaim2 = Core_MDF_CCP_TestDataUtility.createClaim('India Claim', Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF, 
                                                                                    indiaActivity.Id, 
                                                                                    indiaActivity.Core_MDF_Start_Date__c, indiaActivity.Core_MDF_Start_Date__c, 
                                                                                    100, 
                                                                                    System.today().addDays(-1), indiaBank.ID, false);
            claimListToBeProcessed.add(indiaClaim);
            claimListToBeProcessed.add(indiaClaim2);
            
            try{
                Database.insert(claimListToBeProcessed);
                system.debug('###function 1 claim insert###'+claimListToBeProcessed);
                PartnerFundClaim reservedClaim = [Select Status From PartnerFundClaim WHERE Id = :indiaClaim.Id LIMIT 1];
                System.assertEquals(reservedClaim.Status, System.Label.Core_MDF_Status_Approved);
                Database.update(claimListToBeProcessed);
                system.debug('### function 1 claim update###'+claimListToBeProcessed);
            }catch(Exception e){System.debug('EXCEPTION::::'+e.getMessage());}
        }  
        Test.stopTest();      
    }
    // Test method to test fundreservation for Claims whose Amount is less than current Allocation
    @isTest static void testPFCFundReservationScnearioDup(){
        Test.startTest();
        User clmCaseUser = [SELECT Id,Email from User where Email='clmcase@example.com' limit 1];
        User extUser = [SELECT Id,Email from User where Email='test1@example.com' limit 1];
        
        PartnerFundRequest indiaActivity = [SELECT Id,Title,Core_MDF_Start_Date__c,Core_MDF_End_Date__c from PartnerFundRequest where Title='indiaActivity' limit 1];
        
        Core_MDF_Bank__c indiaBank = [Select ID from Core_MDF_Bank__c limit 1];
        
        List<PartnerFundClaim> claimListToBeProcessed = new List<PartnerFundClaim>();
        
        System.runAs(clmCaseUser){
            PartnerFundClaim indiaClaim = Core_MDF_CCP_TestDataUtility.createClaim('India Claim1', Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF, 
                                                                                   indiaActivity.Id, 
                                                                                   indiaActivity.Core_MDF_Start_Date__c, indiaActivity.Core_MDF_Start_Date__c, 
                                                                                   100, 
                                                                                   System.today().addDays(-1), indiaBank.ID, false);
            indiaClaim.Core_MDF_Currency__c='USD';
            Database.insert(indiaClaim);
            PartnerFundClaim indiaClaim2 = Core_MDF_CCP_TestDataUtility.createClaim('India Claims', Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF, 
                                                                                    indiaActivity.Id, 
                                                                                    indiaActivity.Core_MDF_Start_Date__c, indiaActivity.Core_MDF_Start_Date__c, 
                                                                                    100, 
                                                                                    System.today().addDays(-1), indiaBank.ID, false);
            indiaClaim2.Core_MDF_Currency__c='USD';
            PartnerFundClaim indiaClaim3 = Core_MDF_CCP_TestDataUtility.createClaim('India Claimr', Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF, 
                                                                                    indiaActivity.Id, 
                                                                                    indiaActivity.Core_MDF_Start_Date__c, indiaActivity.Core_MDF_Start_Date__c, 
                                                                                    101, 
                                                                                    System.today().addDays(-1), indiaBank.ID, false);
            indiaClaim3.Core_MDF_Currency__c='USD';
            PartnerFundClaim indiaClaim4 = Core_MDF_CCP_TestDataUtility.createClaim('India Claimss', Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF, 
                                                                                    indiaActivity.Id, 
                                                                                    indiaActivity.Core_MDF_Start_Date__c, indiaActivity.Core_MDF_Start_Date__c, 
                                                                                    102, 
                                                                                    System.today().addDays(-1), indiaBank.ID, false);
            indiaClaim4.Core_MDF_Currency__c='USD';
            claimListToBeProcessed.add(indiaClaim4);
            claimListToBeProcessed.add(indiaClaim3);
            claimListToBeProcessed.add(indiaClaim2);
            
            try{
                Database.insert(claimListToBeProcessed);
                System.assertEquals(indiaClaim2.Core_MDF_Duplicate_Claim__c, false);
                List<Core_MDF_Claim_Utility.ReleaseHoldParams> wrapList = new List<Core_MDF_Claim_Utility.ReleaseHoldParams>();
                Core_MDF_Claim_Utility.ReleaseHoldParams obj1 = new Core_MDF_Claim_Utility.ReleaseHoldParams();
                obj1.inputClaims = claimListToBeProcessed;
                obj1.releaseReason = new List<String>{Label.Core_MDF_Audit_Hold};
                    wrapList.add(obj1);
                Core_MDF_Claim_Utility.invokeReleaseHold(wrapList);
                Database.update(claimListToBeProcessed);
            }catch(Exception e){System.debug('EXCEPTION::::'+e.getMessage());}
        }  
        Test.stopTest();        
    }
    
    // Test method to test fundreservation for Claims whose Amount is more than 
    // current Allocation without Auto Transfer Enabled
    @isTest static void testPFCFundReservationScnearioTwo(){
        Test.startTest();
        User clmCaseUser = [SELECT Id,Email from User where Email='clmcase@example.com' limit 1];
        User extUser = [SELECT Id,Email from User where Email='test1@example.com' limit 1];
        PartnerFundRequest indiaActivity = [SELECT Id,Core_MDF_Start_Date__c,Core_MDF_End_Date__c from PartnerFundRequest where Title='indiaActivity' limit 1];
        
        Core_MDF_Bank__c indiaBank = [Select ID from Core_MDF_Bank__c limit 1];
        
        List<PartnerFundClaim> claimListToBeProcessed = new List<PartnerFundClaim>();
        
        System.runAs(clmCaseUser){
            
            PartnerFundClaim indiaClaim = Core_MDF_CCP_TestDataUtility.createClaim('India Claim', Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF, 
                                                                                   indiaActivity.Id, 
                                                                                   indiaActivity.Core_MDF_Start_Date__c, indiaActivity.Core_MDF_Start_Date__c, 
                                                                                   3000, 
                                                                                   System.today(), indiaBank.ID, false);
            PartnerFundClaim indiaClaim2 = Core_MDF_CCP_TestDataUtility.createClaim('India Claim', Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF, 
                                                                                    indiaActivity.Id, 
                                                                                    indiaActivity.Core_MDF_Start_Date__c, indiaActivity.Core_MDF_Start_Date__c, 
                                                                                    2500, 
                                                                                     System.today(), indiaBank.ID, false);
            claimListToBeProcessed.add(indiaClaim);
            claimListToBeProcessed.add(indiaClaim2);
           // try{
                Database.insert(claimListToBeProcessed);
                PartnerFundClaim reservedClaim = [Select Status From PartnerFundClaim WHERE Id = :indiaClaim.Id LIMIT 1];
                System.assertEquals(reservedClaim.Status, System.Label.Core_MDF_Status_Approved);
                Database.update(claimListToBeProcessed);
           // }catch(Exception e){System.debug(''+e.getMessage());}
        } 
        Test.stopTest();
    }   
    
    // Test method to test fundreservation for Claims whose Amount is more than 
    // current Allocation with Auto Transfer Enabled and Satisfying the Claim Amount
    @isTest static void testPFCFundReservationScnearioThree(){
        Test.startTest();
        Account  dellEMEAFranceAcc = [Select Id from Account where Name = 'Dell CCF EMEA France' Limit 1];
        User clmCaseUser = [SELECT Id,Email from User where Email='clmcase@example.com' limit 1];
        User extUser = [SELECT Id,Email from User where Email='test1@example.com' limit 1];
        PartnerFundRequest franceActivity = [SELECT Id,ChannelPartner.Core_MDF_Auto_Transfer_Account__c,ChannelPartner.Core_MDF_Enabled_Auto_Transfer__c,Core_MDF_Start_Date__c,Core_MDF_End_Date__c from PartnerFundRequest where Title='France Activity' limit 1];
        
        
        Core_MDF_Bank__c franceBank = [Select ID from Core_MDF_Bank__c limit 1];
        Core_MDF_Account_Bank_Mapping__c abm1 = Core_MDF_CCP_TestDataUtility.createAccountBankMap(dellEMEAFranceAcc.Id,franceBank.Id,true);
        List<PartnerFundClaim> claimListToBeProcessed = new List<PartnerFundClaim>();
        
        System.runAs(clmCaseUser){
            PartnerFundClaim franceClaim = Core_MDF_CCP_TestDataUtility.createClaim('India Claim', Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF, 
                                                                                    franceActivity.Id, 
                                                                                    franceActivity.Core_MDF_Start_Date__c, franceActivity.Core_MDF_Start_Date__c, 
                                                                                    30000, 
                                                                                     System.today(), franceBank.ID, false);
            PartnerFundClaim franceClaim2 = Core_MDF_CCP_TestDataUtility.createClaim('India Claim', Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF, 
                                                                                     franceActivity.Id, 
                                                                                     franceActivity.Core_MDF_Start_Date__c, franceActivity.Core_MDF_Start_Date__c, 
                                                                                     5000, 
                                                                                      System.today(), franceBank.ID, false);
            claimListToBeProcessed.add(franceClaim);
            claimListToBeProcessed.add(franceClaim2);
           // try{
                Database.insert(claimListToBeProcessed);
                PartnerFundClaim reservedClaim = [Select Status From PartnerFundClaim WHERE Id = :franceClaim.Id LIMIT 1];
                System.assertEquals(reservedClaim.Status, System.Label.Core_MDF_Status_Submitted);
                claimListToBeProcessed[0].Core_MDF_Total_Invoice_Amount_Local__c = 2500;
                Database.update(claimListToBeProcessed);
            //}catch(Exception e){System.debug(''+e.getMessage());}
        } 
        Test.stopTest();
    }
    
    @isTest
    static void testESDHoldSubmitted()
    {
        Test.startTest();
        List<PartnerFundClaim> claimListToBeProcessed = new List<PartnerFundClaim>();
        Account dellCorpAccount = [SELECT ID From Account Where Name='Dell Corporation' Limit 1];
        Account  dellEMEAFranceAcc = [Select Id from Account where Name = 'Dell CCF EMEA France' Limit 1];
        User clmCaseUser = [SELECT Id,Email from User where Email='clmcase@example.com' limit 1];
        PartnerFundRequest franceActivity = [SELECT Id,ChannelPartner.Core_MDF_Auto_Transfer_Account__c,BudgetId,AllocationId,ChannelPartner.Core_MDF_Enabled_Auto_Transfer__c,Core_MDF_Start_Date__c,Core_MDF_End_Date__c from PartnerFundRequest where Title='France Activity' limit 1];
        
        List<Core_MDF_Bank__c> bankList = new List<Core_MDF_Bank__c>();
        Core_MDF_Bank__c franceBank = Core_MDF_CCP_TestDataUtility.createBank(dellCorpAccount.Id, 'Core_MDF_Client_CoMarketing_Fund', true,'1231231231');
        //franceBank.Core_MDF_Bank_Status__c = 'Hold';
        franceBank.Core_MDF_ESD_Hold_Indicator__c = true;
        //update franceBank;
        bankList.add(franceBank);
        
        Core_MDF_Bank__c franceBank2 = [Select ID,Core_MDF_Bank_Status__c,Core_MDF_ESD_Hold_Indicator__c,Core_MDF_ESD_Update__c,Core_MDF_Hold_Payments_from_AP_file_ind__c from Core_MDF_Bank__c WHERE
                                        Core_MDF_Supplier_Number__c = '1231231230'   limit 1];
        
        //update franceBank2;
        bankList.add(franceBank2);
        
        Database.update(banklist);
        
        //creating ABM for franceBank
        List<Core_MDF_Account_Bank_Mapping__c> abmlist = new List<Core_MDF_Account_Bank_Mapping__c>();
        Core_MDF_Account_Bank_Mapping__c abm = Core_MDF_CCP_TestDataUtility.createAccountBankMap(dellEMEAFranceAcc.Id,franceBank.Id,false);
        abmlist.add(abm);
        Core_MDF_Account_Bank_Mapping__c abm1 = Core_MDF_CCP_TestDataUtility.createAccountBankMap(dellEMEAFranceAcc.Id,franceBank2.Id,false);
        abmlist.add(abm1);
        
        Database.insert(abmlist);
        
        System.runAs(clmCaseUser){
            PartnerFundClaim franceClaim = Core_MDF_CCP_TestDataUtility.createClaim('India Claim2', Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF, 
                                                                                    franceActivity.Id, 
                                                                                    franceActivity.Core_MDF_Start_Date__c, franceActivity.Core_MDF_Start_Date__c, 
                                                                                    300, 
                                                                                    System.today().addDays(-1), franceBank.ID, false);
            franceClaim.Core_MDF_Currency__c='USD';
            claimListToBeProcessed.add(franceClaim);
            
            Database.insert(claimListToBeProcessed);
            
            PartnerFundClaim reservedClaim = [Select Core_MDF_Status__c From PartnerFundClaim WHERE Id = :franceClaim.Id LIMIT 1];
            System.assertEquals(reservedClaim.Core_MDF_Status__c, System.Label.Core_MDF_Hold_Status); 
            //claimListToBeProcessed[0].Core_MDF_Bank__c = franceBank2.Id;
            //Database.update(claimListToBeProcessed);
            claimListToBeProcessed[0].Core_MDF_Bank__c = franceBank.Id;
            Database.update(claimListToBeProcessed); 
            List<PartnerFundClaim> claimListToBeProcessed1 = [Select id,Core_MDF_Status__c,Core_MDF_Claim_Previous_Status__c,Core_MDF_Audit_Hold__c,Core_MDF_Payment_Hold_ind__c,Core_MDF_Criteria_Hold_Ind__c,Core_MDF_Intel_Manual_Hold_Ind__c,Core_MDF_ESD_Hold__c,Core_MDF_Member_Manual_Hold_Ind__c from PartnerFundClaim where Title = 'India Claim2'];
            System.debug('claimListToBeProcessed::::'+claimListToBeProcessed1);
            System.assertEquals(claimListToBeProcessed1[0].Core_MDF_Claim_Previous_Status__c,'Submitted');
            Core_MDF_Claim_Utility.releaseHold(claimListToBeProcessed1,new List<String>{Label.Core_MDF_ESD_Hold});
        }
        Test.stopTest();
    }
    
    @isTest
    static void testESDHoldPaymentDue()
    {
        Test.startTest();
        List<PartnerFundClaim> claimListToBeProcessed = new List<PartnerFundClaim>();
		
        Account dellCorpAccount = [SELECT ID From Account Where Name='Dell Corporation' Limit 1];
        Account  dellEMEAFranceAcc = [Select Id from Account where Name = 'Dell CCF EMEA France' Limit 1];
        User clmCaseUser = [SELECT Id,Email from User where Email='clmcase@example.com' limit 1];
        PartnerFundRequest franceActivity = [SELECT Id,ChannelPartner.Core_MDF_Auto_Transfer_Account__c,BudgetId,AllocationId,ChannelPartner.Core_MDF_Enabled_Auto_Transfer__c,Core_MDF_Start_Date__c,Core_MDF_End_Date__c from PartnerFundRequest where Title='France Activity' limit 1];
        
		List<Core_MDF_Bank__c> banklist = new List<Core_MDF_Bank__c>();
		Core_MDF_Bank__c franceBank = Core_MDF_CCP_TestDataUtility.createBank(dellCorpAccount.Id, 'Core_MDF_Client_CoMarketing_Fund', true,'1231231231');
        //franceBank.Core_MDF_Bank_Status__c = 'Hold';
        franceBank.Core_MDF_ESD_Hold_Indicator__c = true;
        //update franceBank;
		banklist.add(franceBank);
        
		Core_MDF_Bank__c franceBank2 = [Select ID,Core_MDF_Bank_Status__c,Core_MDF_ESD_Hold_Indicator__c,Core_MDF_ESD_Update__c,Core_MDF_Hold_Payments_from_AP_file_ind__c from Core_MDF_Bank__c WHERE
                                        Core_MDF_Supplier_Number__c = '1231231230'   limit 1];
        
        //update franceBank2;
		banklist.add(franceBank2);
		
		Database.update(banklist);
        
		//creating ABM for franceBank
		List<Core_MDF_Account_Bank_Mapping__c> abmlist = new List<Core_MDF_Account_Bank_Mapping__c>();
		
        Core_MDF_Account_Bank_Mapping__c abm = Core_MDF_CCP_TestDataUtility.createAccountBankMap(dellEMEAFranceAcc.Id,franceBank.Id,false);
		abmlist.add(abm);
        Core_MDF_Account_Bank_Mapping__c abm1 = Core_MDF_CCP_TestDataUtility.createAccountBankMap(dellEMEAFranceAcc.Id,franceBank2.Id,false);
		abmlist.add(abm1);
		
		Database.insert(abmlist);
		
        System.runAs(clmCaseUser){
            PartnerFundClaim franceClaim = Core_MDF_CCP_TestDataUtility.createClaim('India Claim2', Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF, 
                                                                                    franceActivity.Id, 
                                                                                    franceActivity.Core_MDF_Start_Date__c, franceActivity.Core_MDF_Start_Date__c, 
                                                                                    300, 
                                                                                    System.today().addDays(-1), franceBank.ID, false);
            franceClaim.Core_MDF_Currency__c='USD';
            claimListToBeProcessed.add(franceClaim);
			
            Database.insert(claimListToBeProcessed);
			
            PartnerFundClaim reservedClaim = [Select Core_MDF_Status__c From PartnerFundClaim WHERE Id = :franceClaim.Id LIMIT 1];
            System.assertEquals(reservedClaim.Core_MDF_Status__c, System.Label.Core_MDF_Hold_Status); 
			
            //claimListToBeProcessed[0].Core_MDF_Bank__c = franceBank2.Id;
            //Database.update(claimListToBeProcessed);
			
            claimListToBeProcessed[0].Core_MDF_Bank__c = franceBank.Id;
            Database.update(claimListToBeProcessed); 
			
            List<PartnerFundClaim> claimListToBeProcessed1 = [Select id,Core_MDF_Status__c,Core_MDF_Claim_Previous_Status__c,Core_MDF_Audit_Hold__c,Core_MDF_Payment_Hold_ind__c,Core_MDF_Criteria_Hold_Ind__c,Core_MDF_Intel_Manual_Hold_Ind__c,Core_MDF_ESD_Hold__c,Core_MDF_Member_Manual_Hold_Ind__c from PartnerFundClaim where Title = 'India Claim2'];
            claimListToBeProcessed1[0].Core_MDF_Claim_Previous_Status__c= 'Payment Due';
            System.assertEquals(claimListToBeProcessed1[0].Core_MDF_Claim_Previous_Status__c,'Payment Due');
            Core_MDF_Claim_Utility.releaseHold(claimListToBeProcessed1,new List<String>{Label.Core_MDF_ESD_Hold});
        }
        Test.stopTest();
    }
    
    @isTest
    static void validatefundReservationCheckOnInsert(){
        Test.startTest();
        User clmCaseUser = [SELECT Id,Email from User where Email='clmcase@example.com' limit 1];
        User extUser = [SELECT Id,Email from User where Email='test1@example.com' limit 1];
        Core_Trigger_Executions__c checkAudit = [SELECT Id, Name, Core_Active__c, Core_Object__c FROM Core_Trigger_Executions__c where Name = 'checkAndSendClaimsToAudit' limit 1];
        checkAudit.Core_Active__c = true;
        Database.update(checkAudit);
        PartnerFundRequest indiaActivity = [SELECT Id,Title,Core_MDF_Start_Date__c,Core_MDF_End_Date__c from PartnerFundRequest where Title='indiaActivity' limit 1];
        
        Core_MDF_Bank__c indiaBank = [Select ID from Core_MDF_Bank__c limit 1];
        
        List<PartnerFundClaim> claimListToBeProcessed = new List<PartnerFundClaim>();
        
        System.runAs(clmCaseUser){
            PartnerFundClaim indiaClaim = Core_MDF_CCP_TestDataUtility.createClaim('India Claim', Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF, 
                                                                                   indiaActivity.Id, 
                                                                                   indiaActivity.Core_MDF_Start_Date__c, indiaActivity.Core_MDF_Start_Date__c, 
                                                                                   101, 
                                                                                   System.today().addDays(-1), indiaBank.ID, false);
            PartnerFundClaim indiaClaim2 = Core_MDF_CCP_TestDataUtility.createClaim('India Claim3', Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF, 
                                                                                    indiaActivity.Id, 
                                                                                    indiaActivity.Core_MDF_Start_Date__c, indiaActivity.Core_MDF_Start_Date__c, 
                                                                                    100, 
                                                                                    System.today().addDays(-1), indiaBank.ID, false);
            claimListToBeProcessed.add(indiaClaim);
            claimListToBeProcessed.add(indiaClaim2);
            
            try{
                Database.insert(claimListToBeProcessed);
                //Covering the Edit Controller for the Lightning component
                String indiaClaim2Id = indiaClaim2.Id;
                Core_MDF_PartnerFundClaim_Edit.fetchClaimById(indiaClaim2Id);
                Database.update(claimListToBeProcessed);
                indiaClaim2.Core_MDF_AuditSelectionInProgress__c = false;
                Database.update(claimListToBeProcessed);
                
                List<Id> claimId = new List<Id>();    
                claimId.add(indiaClaim2.Id);
                System.Debug('indiaClaim2.Core_MDF_Status__c::::'+indiaClaim2.Core_MDF_Status__c);
                Core_MDF_ProcessCCP_Claim.isClaimEligible(indiaClaim2,null,false);
                PartnerFundClaim reservedClaim = [Select Core_MDF_Status__c From PartnerFundClaim WHERE Id = :indiaClaim2.Id LIMIT 1];
                System.Debug('reservedClaim.Core_MDF_Status__c::::'+reservedClaim.Core_MDF_Status__c);
                System.assertEquals(reservedClaim.Core_MDF_Status__c, System.Label.Core_MDF_Status_Payment_Due); 
            }catch(Exception e){System.debug('EXCEPTION::::'+e.getMessage());}
        } 
        Test.stopTest();
    } 
    
    /* Test Method to Check the OwnerID Change of the Claim Record */
    @isTest
    static void testClaimOwnerChange()
    {
        test.startTest();
        PartnerFundClaim claim1 = new PartnerFundClaim();
        Map<Id,PartnerFundClaim> claimsMap= new Map<Id,PartnerFundClaim>(); 
        List<PartnerFundClaim> claimList= new List<PartnerFundClaim>();
        User clmCaseUser = [SELECT Id,Email from User where Email='clmcase@example.com' limit 1];
        Core_MDF_Bank__c indiaBank = [Select ID from Core_MDF_Bank__c limit 1];
        PartnerFundRequest indiaActivity = [SELECT Id,Title,Core_MDF_Start_Date__c,Core_MDF_End_Date__c from PartnerFundRequest where Title='indiaActivity' limit 1];
        System.runAs(clmCaseUser){
            claim1 = Core_MDF_CCP_TestDataUtility.createClaim('India Claim', Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF, 
                                                              indiaActivity.Id, 
                                                              indiaActivity.Core_MDF_Start_Date__c, indiaActivity.Core_MDF_Start_Date__c, 
                                                              105, 
                                                              System.today().addDays(-1), indiaBank.ID, true);
            claimsMap.put(claim1.Id, claim1); 
        }     
        claim1.ownerId = UserInfo.getUserId();
        Database.update(claim1);       
        claimList.add(claim1);       
        system.assertNotEquals(claimsMap.size(), NULL);
        Core_MDF_PFC_Sharing.recalculateShareClaimWhenOwnerChange(claimList, claimsMap);
        test.stopTest();
    }
    
    /* Test Method to check reserve funds for Node */
    @isTest
    static void testReserveFundsforNode()
    {
        Test.startTest();
        List<PartnerFundClaim> claimListToBeProcessed = new List<PartnerFundClaim>();
        Account dellCorpAccount = [SELECT ID From Account Where Name='Dell Corporation' Limit 1];
        Account  dellEMEAFranceAcc = [Select Id from Account where Name = 'Dell CCF EMEA France' Limit 1];
        User clmCaseUser = [SELECT Id,Email from User where Email='clmcase@example.com' limit 1];
        PartnerFundRequest franceActivity = [SELECT Id,ChannelPartner.Core_MDF_Auto_Transfer_Account__c,BudgetId,AllocationId,ChannelPartner.Core_MDF_Enabled_Auto_Transfer__c,Core_MDF_Start_Date__c,Core_MDF_End_Date__c from PartnerFundRequest where Title='France Activity' limit 1];
        
        List<Core_MDF_Bank__c> bankList = new List<Core_MDF_Bank__c>();
        Core_MDF_Bank__c franceBank = Core_MDF_CCP_TestDataUtility.createBank(dellCorpAccount.Id, 'Core_MDF_Client_CoMarketing_Fund', true,'1231231231');
        //franceBank.Core_MDF_Bank_Status__c = 'Hold';
        franceBank.Core_MDF_ESD_Hold_Indicator__c = true;
        //update franceBank;
        bankList.add(franceBank);
        Database.update(banklist);
        
        //creating ABM for franceBank
        List<Core_MDF_Account_Bank_Mapping__c> abmlist = new List<Core_MDF_Account_Bank_Mapping__c>();
        Core_MDF_Account_Bank_Mapping__c abm = Core_MDF_CCP_TestDataUtility.createAccountBankMap(dellEMEAFranceAcc.Id,franceBank.Id,false);
        abmlist.add(abm);
        Database.insert(abmlist);
        
        System.runAs(clmCaseUser){
            PartnerFundClaim franceClaim = Core_MDF_CCP_TestDataUtility.createClaim('India Claim V1', Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF, 
                                                                                    franceActivity.Id, 
                                                                                    franceActivity.Core_MDF_Start_Date__c, franceActivity.Core_MDF_Start_Date__c, 
                                                                                    300, 
                                                                                    System.today().addDays(-1), franceBank.ID, false);
            franceClaim.Core_MDF_Currency__c='USD';
            claimListToBeProcessed.add(franceClaim);
            Database.insert(claimListToBeProcessed);
            claimListToBeProcessed[0].Core_MDF_Status__c = 'Hold';
            claimListToBeProcessed[0].Status= 'Rejected';
            Database.update(claimListToBeProcessed);
            System.assertEquals(claimListToBeProcessed[0].Core_MDF_Status__c,'Hold');
        }
        Test.stopTest();
    }
    
}