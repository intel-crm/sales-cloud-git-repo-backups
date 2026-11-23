/****************************************************************************************************************************************
* Class Name  : Core_MDF_Process_PAF_Claim_Test
* Version     : 1.0 
* Created Date: 11-21-2018
* Modification Log :
* Developer                        Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture
Gaurav                           11/21/2018                    Created to test List of Claims being sent to Fund Reservation. 
*****************************************************************************************************************************************/
@isTest(SeeAllData=false)
private class Core_MDF_Process_PAF_Claim_Test{
/****************************************************************************************************************************************
Method Name:                                   setUpData
Description:                                   Created to prepare data for testing 
Added By:                                      Accenture – VD  -  18-Dec-2019
Modified By:           Date:                   Changes: 
Accenture – VD        18-Dec-2019              Refactored to follow best practice
*****************************************************************************************************************************************/   
    @TestSetup static void setUpData(){
        
                List<Core_Trigger_Executions__c> transactions = new List<Core_Trigger_Executions__c>();
        transactions.addAll(Core_MDF_CCP_TestDataUtility.byPassFeature(new List<String>{'Bypass_Duplicate_Budget_Check','Bypass_GeoBased_Budget_Sharing'}, true, false));       
        transactions.addAll(Core_MDF_CCP_TestDataUtility.byPassFeature(new List<String>{'Bypass_Allocation_Reservation','Bypass_GeoBased_Allocation_Sharing'}, true, false));   
        transactions.addAll(Core_MDF_CCP_TestDataUtility.byPassFeature(new List<String>{'Bypass_Duplicate_Bank_Check','Bypass_Bank_Internal_Sharing',
                    'Bypass_Bank_External_Sharing','Bypass_Bank_Program_InActivation_Check','Bypass_Bank_ABM_Sharing'}, true, false));
        transactions.addAll(Core_MDF_CCP_TestDataUtility.byPassFeature(new List<String>{'Bypass_ABM_Internal_Sharing','Bypass_ABM_External_Sharing','Bypass_ABM_NodeGroup_Sharing','Bypass_Claims_Sharing_Internal_Users'}, true, false));                  
        Database.insert(transactions);
        
        List<Core_Trigger_Executions__c> executionList = new List<Core_Trigger_Executions__c>();
        
        Core_Trigger_Executions__c claimFunctionalityNameTriggerExecution = new Core_Trigger_Executions__c();
        claimFunctionalityNameTriggerExecution.Core_Active__c = true;
        claimFunctionalityNameTriggerExecution.Core_Class_Name__c = 'Core_MDF_ProcessCCP_Claim';
        claimFunctionalityNameTriggerExecution.Core_Trigger_Events__c = 'after insert, after update';
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
        Core_Trigger_Executions__c claimFunctionalityNameTriggerExecution6 = new Core_Trigger_Executions__c();
        claimFunctionalityNameTriggerExecution6.Core_Active__c = true;
        claimFunctionalityNameTriggerExecution6.Core_Class_Name__c = 'Core_MDF_PFCServiceHandler';
        claimFunctionalityNameTriggerExecution6.Core_Trigger_Events__c = 'after insert, after update';
        claimFunctionalityNameTriggerExecution6.Core_Object__c = 'PartnerFundClaim';
        claimFunctionalityNameTriggerExecution6.Name = 'checkAndSendClaimsForPIC';
        claimFunctionalityNameTriggerExecution6.Core_Description__c = 'description';
        executionList.add(claimFunctionalityNameTriggerExecution6);
        
        Database.insert(executionList);
        
        Profile ccpCoreProfile = [SELECT Id FROM Profile WHERE Name='CCP - Core Access' LIMIT 1];
        PermissionSet clmCaseRevPS = [SELECT Id, Name FROM PermissionSet WHERE Name='Core_MDF_CCP_Internal_Claim_Case_Reviewer' LIMIT 1];
        List<Account> accList = new List<Account>();
        ChannelProgram  cProgram = Core_MDF_CCP_TestDataUtility.createProgram ('Client','Client CoMarketing Fund', true);
        
        // Creating Intel Account with utility class
        Account accIntel = Core_MDF_CCP_TestDataUtility.createAccount ('Test Account ', cProgram.Id,Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);   
        accIntel.BillingCity = 'Test City';         
        accIntel.BillingCountry= 'AUS';
        accIntel.BillingStreet= 'Test Street';
        Database.insert(accIntel); 
        accIntel.IsPartner = true;
        accList.add(accIntel);
        
        // Creating Co-marketing Account with utility class        
        Account accCoMarketing = Core_MDF_CCP_TestDataUtility.createAccount ('Test Account 2', cProgram.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type,  false);
        accCoMarketing.Core_MDF_Parent_Fund_Account__c = accIntel.Id;
        Database.insert(accCoMarketing);
        accCoMarketing.IsPartner = true;
        accList.add(accCoMarketing);
        
        Database.update(accList);
        
        // Creating Users
        List<User> lstUser = new List<user>();
        User sysadm = Core_MDF_CCP_TestDataUtility.createUser(false);
        sysadm.Email = 'sysadm@example.com';
        lstUser.add(sysadm);
        
        User claimCase = Core_MDF_CCP_TestDataUtility.createUser(false);
        claimCase.Email = 'clmcase@example.com';
        claimCase.Profile = ccpCoreProfile;
        lstUser.add(claimCase);
        
        Database.insert(lstUser);
        
        PermissionSetAssignment assignPermissionSetObj = new PermissionSetAssignment();
        assignPermissionSetObj.AssigneeId = claimCase.Id;
        assignPermissionSetObj.PermissionSetId = clmCaseRevPS.Id;
        system.runas(sysadm){
            Database.insert(assignPermissionSetObj);
       
        //adding bypass feature to bypass access validation
            List<String> bypassFunctionKeys = new List<String>();
            bypassFunctionKeys.add('Bypass_MDF_Budget_Access_Validation');
            bypassFunctionKeys.add('Bypass_MDF_Budget_Status_Validation');
            
            Set<String> myset1 = new Set<String>();
            List<String> result1 = new List<String>();
            myset1.addAll(bypassFunctionKeys);
            result1.addAll(myset1);
            
            List<Core_Trigger_Executions__c> bypassfunctinalitylist1 = Core_MDF_CCP_TestDataUtility.byPassFeature(result1,true,true);
        
        // Create PMB for the above Account 
        PartnerMarketingBudget  pmbRecord = Core_MDF_CCP_TestDataUtility.createBudget('TestPMB',Core_MDF_CCP_TestDataUtility.budget_Record_Type,accCoMarketing.Id,cProgram.Id,123456,
                                                                                      System.today()-25, System.today()+30,false);//System.today().adddays(-100),System.today().addDays(250),false);
        //pmbRecord.Core_MDF_Budget_Type__c= 'RSA MD';
        pmbRecord.Core_MDF_Budget_Type_Txt__c='OEM CMP';
        pmbRecord.IsIgnoreValidation = true;
        database.insert(pmbRecord);
        // Create PFA records for the above accounts :
        PartnerFundAllocation pfaRecord = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('TestPFA',pmbRecord, accCoMarketing, 1234,true);
        
        // PartnerFundAllocation pfaRecord2 = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('TestPFA2',pmbRecord, accCoMarketing, 12345, true);       
        Campaign camp = Core_MDF_CCP_TestDataUtility.createCampaign('Test Camp 12','Gaming','Intel® Xeon® Platinum Processor','Yes', Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 'Client CoMarketing Fund',
                                                                   System.today(),//System.today().addDays(-1), 
                                                                            System.today().addDays(20),//System.today().addDays(20),
                                                                            10000, 'Consumer Chromebook', accCoMarketing.Id, '2-in-1', false);
        camp.Core_MDF_Opal_Budget_Type_Txt__c = 'OEM CMP';
        database.insert(camp);
        
        test.startTest(); 
        //Create PFR        
        PartnerFundRequest pfRequest = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(String.valueof(camp.Id), 
                                                                                             Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,
                                                                                             String.valueof(accCoMarketing.id),pfaRecord,pmbRecord,'INDIA',
                                                                                             'Consumer',
                                                                                             'Desktop',
                                                                                             'Intel® Core™ i5 Processor',//Intel® Core™ i7+ Processor
                                                                                             'Broadcast',
                                                                                             'Podcast',
                                                                                             'Draft',
                                                                                             false);     
        pfRequest.Title = 'Test Activity1';
        pfRequest.Core_MDF_Activity_Description__c = 'Test Activity1';
        pfRequest.Core_MDF_Budget_Type_nm__c='OEM CMP';
        pfRequest.Core_MDF_Start_Date__c = System.today();
        pfRequest.Core_MDF_End_Date__c = System.today();
        pfRequest.RequestedAmount = 2000;
        pfRequest.Core_MDF_pagespayingfor__c = 15;
        pfRequest.allocationId = pfaRecord.Id;
        Database.insert(pfRequest);
        
        Core_MDF_CCP_TestDataUtility.insertCurrencyExchangeRates();
        
        Core_MDF_Bank__c bankPAF = Core_MDF_CCP_TestDataUtility.createBank(accIntel.Id, 'Core_MDF_Client_CoMarketing_Fund', true,'1231231230');      
        
         //creating ABM for indiaBank
        Core_MDF_Account_Bank_Mapping__c abm = Core_MDF_CCP_TestDataUtility.createAccountBankMap(accCoMarketing.Id,bankPAF.Id,true);
        test.stopTest(); 

        }
        
    }
    /****************************************************************************************************************************************
Method Name:                                   testListOfClaims
Description:                                   Created to test user permission 
Added By:                                      Accenture – VD  -  18-Dec-2019
Modified By:                  Date:            Changes: 
Accenture – VD              18-Dec-2019        Refactored to follow best practice
*****************************************************************************************************************************************/  
    @isTest static void testListOfClaims(){
        
        
        Core_MDF_Configuration__c execution1 = new Core_MDF_Configuration__c();
        execution1.Name = 'ALLOWED_PRG_FOR_RUS_NOTIF';
        execution1.Core_MDF_Category__c = 'Bank Document Hold Logic';
        execution1.Core_MDF_Value__c = 'Retail Marketing Funds,Intel Partner Alliance';
        insert execution1;
        User usr = [select id,email from User where email='clmcase@example.com'];
        PartnerFundRequest pfRequest= [Select id from PartnerFundRequest where title = 'Test Activity1'];
        Core_MDF_Bank__c bankPAF = [Select id from Core_MDF_Bank__c ];
        List<PartnerFundClaim> pfcList = new List<PartnerFundClaim>();
        
       /* PartnerFundClaim pfClaim = Core_MDF_CCP_TestDataUtility.createClaim('Test Claim', Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, pfRequest.Id, System.today(), System.today(), 500.00, System.today(),bankPAF.Id, true);
        pfclaim.Core_MDF_Status__c = Label.Core_MDF_Status_Cancelled;
        pfcList.add(pfClaim);*/
        test.startTest();
        PartnerFundClaim pfClaimPAF = Core_MDF_CCP_TestDataUtility.createClaim('Test Claim1', Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, pfRequest.Id, System.today(), System.today(), 50000.00, System.today(),bankPAF.Id, false);
        pfClaimPAF.Core_MDF_Status__c = Label.Core_MDF_Status_Pending_Available_Fund;
        pfClaimPAF.Core_MDF_Currency__c='USD';//INR
        list<Core_MDF_Audit_Document__c> auditDocList = new list<Core_MDF_Audit_Document__c>();
        Core_MDF_PartnerFundClaim.ClaimWrap res = new Core_MDF_PartnerFundClaim.ClaimWrap();
        //res = Core_MDF_PartnerFundClaim.saveClaim(pfClaimPAF, auditDocList,null, null);  
        res = Core_MDF_PartnerFundClaim.saveClaim(pfClaimPAF, auditDocList,null, null,false, null);
        //pfcList.add(pfClaimPAF);
        
        //database.update(pfcList);
        //list<partnerFundClaim> cancelledClaims = [select id,ChannelPartnerId,AllocationId from partnerFundClaim where title = 'Test Claim'];
        Map<Id,partnerFundAllocation> pfaMap = new Map<Id,partnerFundAllocation>([select id,ChannelPartnerId from partnerFundAllocation where title = 'TestPFA']);
        
        system.runAs(usr){
            
            Core_MDF_Process_PAF_Claim.fetchClaimsByAllocationIds(pfaMap.keySet());
            
        }
        System.assertNotEquals(NULL,pfaMap);
        test.stopTest(); 
      
    }
}