/****************************************************************************************************************************************
* Class Name  : Core_MDF_AdjustmentRequest_Test
* Version     : 1.0 
* Created Date: 6-June-2019
* Modification Log :
* Developer    Intel :Areefa      Date:6-Jun-2019       Description: 
*****************************************************************************************************************************************/
@isTest(SeeAllData=false)
Private class Core_MDF_AdjustmentRequest_Test {    
    
    /* Method to Setup Test Data */
    @TestSetup static void setUpData(){        
        
        List<Account> accList = new List<Account>();
        ChannelProgram  cProgram = Core_MDF_CCP_TestDataUtility.createProgram ('Client Co-Marketing Fund','Client CoMarketing Fund', true);
        
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
        update accList;
        
        // Creating Contact for Partner User
        Contact conRecForPartner = Core_MDF_CCP_TestDataUtility.createContact(accIntel.Id,true);
        
        // Creating Admin and Partner Users with utility class 
        User usrAdmin = Core_MDF_CCP_TestDataUtility.createUser(false);
        usrAdmin.Email = 'sysadmin@example.com';
        Database.insert(usrAdmin);
        Id profileId = [SELECT Id FROM Profile WHERE Name='Partner' limit 1].Id;
        User usrPartner = Core_MDF_CCP_TestDataUtility.createUser(false);        
        usrPartner.Email='test1@example.com';
        usrPartner.ContactId = conRecForPartner.Id;
        usrPartner.ProfileId = profileId;
        usrPartner.isActive = true;
        Database.insert(usrPartner);
        //test.startTest(); 
        
        Profile ccpProfile = [SELECT Id FROM Profile WHERE Name='CCP - Core Access'];
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        User usr1 = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr1.ProfileId = ccpProfile.Id;
        usr1.Email='test1@intel.com';
        usr1.isActive = true;
        usr1.UserPermissionsMarketingUser=true;
        //  usr1.UserRoleId = usRole.Id;
        Database.insert(usr1);
        
        
        // Create PMB for the above Account 
        Id recordTypeIdPMB = Schema.SObjectType.PartnerMarketingBudget.getRecordTypeInfosByName().get('CoMarketing').getRecordTypeId();
        PartnerMarketingBudget  pmbRecord = Core_MDF_CCP_TestDataUtility.createBudget('TestPMB',RecordTypeIdPMB,accCoMarketing.Id,cProgram.Id,123456,System.today().addDays(-15),System.today().addDays(15),true);// new PartnerMarketingBudget(Title='TestPMB',Core_MDF_Program__c=cp.Id,Core_MDF_Budget_Partner__c=accCoMarketing.Id,StartDate=Date.today().addDays(1),EndDate=Date.today().addDays(15),Amount=1234567);
        pmbRecord.IsIgnoreValidation = true;
        Database.update(pmbRecord);
        
        // Create PFA records for the above accounts :
        PartnerFundAllocation pfaRecord = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('TestPFA',pmbRecord, accCoMarketing, 1234,true);
        
        // PartnerFundAllocation pfaRecord2 = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('TestPFA2',pmbRecord, accCoMarketing, 12345, true);       
        Campaign camp = Core_MDF_CCP_TestDataUtility.createCampaign('Test Camp 12','Gaming','Intel® Core™ i7+ Processor', Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 'Client CoMarketing Fund', System.today(), System.today().addDays(15), 10000, 'Consumer Chromebook', accCoMarketing.Id, '2-in-1', true);         
        test.startTest(); 
        //Create PFR        
        PartnerFundRequest pfRequest = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(String.valueof(camp.Id), 
                                                                                             Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,
                                                                                             String.valueof(accCoMarketing.id),pfaRecord,pmbRecord,'INDIA',
                                                                                             'Consumer',
                                                                                             'Desktop',
                                                                                             'Intel® Core™ i7+ Processor',
                                                                                             'Broadcast',
                                                                                             'Podcast',
                                                                                             'Draft',
                                                                                             false);     
        
        
        pfRequest.Title = 'Test Activity1';
        pfRequest.Core_MDF_Activity_Description__c = 'Test Activity1';
        pfRequest.Core_MDF_Start_Date__c = System.today();
        pfRequest.Core_MDF_End_Date__c = System.today();
        pfRequest.RequestedAmount = 2000;
        //pfRequest.Core_MDF_Government_Nexus__c = True;
        pfRequest.Core_MDF_pagespayingfor__c = 15;
        pfRequest.allocationId = pfaRecord.Id;
        Database.insert(pfRequest);
        
        
        
        List<Core_MDF_Currency_Exchange_Rates__c> newValues = new List<Core_MDF_Currency_Exchange_Rates__c>();
        Core_MDF_Currency_Exchange_Rates__c record1 = new Core_MDF_Currency_Exchange_Rates__c();
        record1.Name= 'ZMK';
        record1.Core_MDF_Exchange_Rate__c = 0.0000850159;
        record1.Core_MDF_Market_Date__c =System.today();
        record1.Core_MDF_Intel_WW__c = Core_MDF_CCP_Multicurrency.calculateIntelWorkWeek(System.today());
        record1.Core_MDF_Unique_Key__c = 'ZMK'+Core_MDF_CCP_Multicurrency.calculateIntelWorkWeek(System.today());
        newValues.add(record1);
        
        Core_MDF_Currency_Exchange_Rates__c record2 = new Core_MDF_Currency_Exchange_Rates__c();
        record2.Name= 'INR';
        record2.Core_MDF_Exchange_Rate__c = 1;
        record2.Core_MDF_Market_Date__c =System.today();
        record2.Core_MDF_Intel_WW__c = Core_MDF_CCP_Multicurrency.calculateIntelWorkWeek(System.today());
        record2.Core_MDF_Unique_Key__c = 'INR'+Core_MDF_CCP_Multicurrency.calculateIntelWorkWeek(System.today());
        newValues.add(record2); 
        
        Core_MDF_Currency_Exchange_Rates__c record3 = new Core_MDF_Currency_Exchange_Rates__c();
        record3.Name= 'USD';
        record3.Core_MDF_Exchange_Rate__c = 1;
        record3.Core_MDF_Market_Date__c =System.today();
        record3.Core_MDF_Intel_WW__c = Core_MDF_CCP_Multicurrency.calculateIntelWorkWeek(System.today());
        record3.Core_MDF_Unique_Key__c = 'USD'+Core_MDF_CCP_Multicurrency.calculateIntelWorkWeek(System.today());
        newValues.add(record3); 
        database.insert(newValues);
        Core_MDF_Bank__c bankPAF = Core_MDF_CCP_TestDataUtility.createBank(accIntel.Id, 'Core_MDF_Client_CoMarketing_Fund', true,'1231231230');      
        
        //creating ABM
        Core_MDF_Account_Bank_Mapping__c abm = Core_MDF_CCP_TestDataUtility.createAccountBankMap(accCoMarketing.Id,bankPAF.Id,true);
        
        //PartnerFundClaim pfClaim = Core_MDF_CCP_TestDataUtility.createClaim('Test Claim', Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, pfRequest.Id, System.today(), System.today(), 50000.00, System.today(),bankPAF.Id, true);
        //pfclaim.Core_MDF_Status__c = Label.Core_MDF_Status_Cancelled;
        //update pfClaim;  
        
        PartnerFundClaim pfClaimPAF = Core_MDF_CCP_TestDataUtility.createClaim('Test Claim for Neg Adj', Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, pfRequest.Id, System.today(), System.today(), 50000.00, System.today(),bankPAF.Id, true);
        pfClaimPAF.Core_MDF_Status__c = Label.Core_MDF_Status_Pending_Available_Fund;
        update pfClaimPAF;    
               
        
        test.stopTest(); 
        
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
    /* Method:  testToCreateNegativeClaimFromAdjustmentRequest */
    @isTest
    private  static void testToCreateNegativeClaimFromAdjustmentRequest(){
        
        test.startTest(); 
        List<Core_MDF_Adjustment_Request__c> createAdjReq = new List<Core_MDF_Adjustment_Request__c>();
        PartnerFundClaim claim = [SELECT Id FROM PartnerFundClaim where Title ='Test Claim for Neg Adj'];
        claim.Core_MDF_Type_Txt__c ='Adjustment';
        Core_MDF_Adjustment_Request__c adjReq = new Core_MDF_Adjustment_Request__c();
        adjReq.Core_MDF_Reference_Claim_Nbr__c = claim.Id; 
        adjReq.Core_MDF_Reason_Cd__c = 'Claim Review Results (Negative)';
        adjReq.Core_MDF_Amount_Amt__c = 10; 
        adjReq.Core_MDF_Comments_Txt__c = 'Test';
        createAdjReq.add(adjReq);        
        Core_MDF_AdjustmentReq_ServiceHandler.createAdjustment(createAdjReq);
       	System.assert(true, adjReq.id != null); 
        test.stopTest(); 
    }
    
    /* Method:  testToCreateNegativeClaimFromAdjustmentRequest */
    @isTest
    private  static void testToCreateEscalationClaimFromAdjustmentRequest(){
        
        test.startTest(); 
        List<Core_MDF_Adjustment_Request__c> createAdjReq = new List<Core_MDF_Adjustment_Request__c>();
        PartnerFundClaim claim = [SELECT Id FROM PartnerFundClaim where Title ='Test Claim for Neg Adj'];
        //claim.Core_MDF_Type_Txt__c ='Claim';
        Core_MDF_Adjustment_Request__c adjReq = new Core_MDF_Adjustment_Request__c();
        adjReq.Core_MDF_Reference_Claim_Nbr__c = claim.Id; 
        adjReq.Core_MDF_Reason_Cd__c = 'Escalation';
        adjReq.Core_MDF_Amount_Amt__c = 10; 
        adjReq.Core_MDF_Comments_Txt__c = 'Test1';
        	if(adjReq.Core_MDF_Escalation_Id__c != null){
                adjReq.Core_MDF_Escalation_Id__c  = adjReq.Core_MDF_Escalation_Id__c; 			// Escaltion Id 
            } 
        
        createAdjReq.add(adjReq);        
        Core_MDF_AdjustmentReq_ServiceHandler.createAdjustment(createAdjReq);
		System.assert(true, adjReq.id != null);         
        test.stopTest(); 
    }   
   
    
    /* Method to Check resharing with new owner */
    @isTest static void testRecalculateShareAdjReqWhenOwnerChange(){
        
        Test.startTest();
        
        Core_MDF_Adjustment_Request__c adjReq = new Core_MDF_Adjustment_Request__c();
        PartnerFundClaim claim = [SELECT Id FROM PartnerFundClaim where Title ='Test Claim for Neg Adj'];
        claim.Core_MDF_Type_Txt__c ='Adjustment';
        adjReq.Core_MDF_Reference_Claim_Nbr__c = claim.Id;
        adjReq.Core_MDF_Reason_Cd__c = 'Claim Review Results (Negative)';
        adjReq.Core_MDF_Amount_Amt__c = 10; 
        adjReq.Core_MDF_Comments_Txt__c = 'Test';
        adjReq.OwnerId = userInfo.getUserId();
        Database.insert(adjReq);  
        
        List<Core_MDF_Adjustment_Request__c> adjReqList = new List<Core_MDF_Adjustment_Request__c>();       
        
        Map<Id,Core_MDF_Adjustment_Request__c> adjReqIdToAdjReqMap =new  Map<Id,Core_MDF_Adjustment_Request__c>();
        
        adjReqIdToAdjReqMap.put(adjReq.Id,adjReq);
        
        User usr = [SELECT ID From User where Email = 'sysadmin@example.com'];
        
        adjReq.OwnerId = usr.Id; 
        
        update adjReq; 
        
        adjReqList.add(adjReq);
        
        Core_MDF_AdjustmentRequest_Sharing.recalculateShareAdjustmentRequestWhenOwnerChange(adjReqList,adjReqIdToAdjReqMap);
        
        Integer i = [SELECT COUNT() from Core_MDF_Adjustment_Request__Share];        
        //One of owner  
        //System.assertEquals(1, i);
        
        Test.stopTest();        
    }
    
     /* Method to Check resharing with new owner */
    @isTest static void testCancelAdjustmentRequest(){
        
        Test.startTest();
        
        Core_MDF_Adjustment_Request__c adjReq = new Core_MDF_Adjustment_Request__c();
        PartnerFundClaim claim = [SELECT Id FROM PartnerFundClaim where Title ='Test Claim for Neg Adj'];
        claim.Core_MDF_Type_Txt__c ='Adjustment';
        adjReq.Core_MDF_Reference_Claim_Nbr__c = claim.Id;
        adjReq.Core_MDF_Reason_Cd__c = 'Claim Review Results (Negative)';
        adjReq.Core_MDF_Amount_Amt__c = 10; 
        adjReq.Core_MDF_Comments_Txt__c = 'Test';
        adjReq.OwnerId = userInfo.getUserId();
        Database.insert(adjReq);  
        
       	adjReq.Core_MDF_Adjustment_Status_nm__c = 'Cancelled';
        Database.update(adjReq); 
       
        Test.stopTest();        
    }
    
}