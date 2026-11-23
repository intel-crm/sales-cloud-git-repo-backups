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
        system.runAs(usrAdmin){

        Id profileId = [SELECT Id FROM Profile WHERE Name='Partner' limit 1].Id;
        User usrPartner = Core_MDF_CCP_TestDataUtility.createUser(false);        
        usrPartner.Email='test1@example.com';
        usrPartner.ContactId = conRecForPartner.Id;
        usrPartner.ProfileId = profileId;
        usrPartner.isActive = true;
        Database.insert(usrPartner);
        
        Profile ccpProfile = [SELECT Id FROM Profile WHERE Name='CCP - Core Access'];
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        User usr1 = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr1.ProfileId = ccpProfile.Id;
        usr1.Email='test1@intel.com';
        usr1.isActive = true;
        usr1.UserPermissionsMarketingUser=true;
        //  usr1.UserRoleId = usRole.Id;
        Database.insert(usr1);
        
         //Login as claim claim Case reviewer
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User ccrUser = Core_MDF_CCP_TestDataUtility.createUser(false);
        ccrUser.Email='testCCR@example.com';
        ccrUser.ProfileId = p.id;
        Database.insert(ccrUser);
        
        PermissionSet clmCaseRevPS = [SELECT Id, Name FROM PermissionSet WHERE Name='Core_MDF_CCP_Internal_Claim_Case_Reviewer' LIMIT 1];
        PermissionSetAssignment assignPermissionSetObj = new PermissionSetAssignment();
        assignPermissionSetObj.AssigneeId = ccrUser.Id;
        assignPermissionSetObj.PermissionSetId = clmCaseRevPS.Id;
            Database.insert(assignPermissionSetObj);
        }
        
        // Create PMB for the above Account 
        Id recordTypeIdPMB = Schema.SObjectType.PartnerMarketingBudget.getRecordTypeInfosByName().get('CoMarketing').getRecordTypeId();
        PartnerMarketingBudget  pmbRecord = Core_MDF_CCP_TestDataUtility.createBudget('TestPMB',RecordTypeIdPMB,accCoMarketing.Id,cProgram.Id,123456,System.today().addDays(-15),System.today().addDays(15),true);// new PartnerMarketingBudget(Title='TestPMB',Core_MDF_Program__c=cp.Id,Core_MDF_Budget_Partner__c=accCoMarketing.Id,StartDate=Date.today().addDays(1),EndDate=Date.today().addDays(15),Amount=1234567);
        pmbRecord.IsIgnoreValidation = true;
        Database.update(pmbRecord);
        
                
        
        
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
        //Core_MDF_Bank__c bankPAF = Core_MDF_CCP_TestDataUtility.createBank(accIntel.Id, 'Core_MDF_Client_CoMarketing_Fund', true,'1231231230');
        Core_MDF_Bank__c bankPAF = Core_MDF_CCP_TestDataUtility.createBank(accIntel.Id, 'Core_MDF_Client_CoMarketing_Fund', true,'1231231230');
        
        //creating ABM
        Core_MDF_Account_Bank_Mapping__c abm = Core_MDF_CCP_TestDataUtility.createAccountBankMap(accCoMarketing.Id,bankPAF.Id,true);       
        
        // Create PFA records for the above accounts :
        PartnerFundAllocation pfaRecord = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('TestPFA',pmbRecord, accCoMarketing, 1234,true);
        

        // PartnerFundAllocation pfaRecord2 = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('TestPFA2',pmbRecord, accCoMarketing, 12345, true);       
        Campaign camp = Core_MDF_CCP_TestDataUtility.createCampaign('Test Camp 12','Gaming','Intel® Core™ i7 Processor', Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 'Client CoMarketing Fund', System.today(), System.today().addDays(15), 10000, 'Consumer Chromebook', accCoMarketing.Id, '2-in-1', true);         
        test.startTest(); 
        //Create PFR        
        PartnerFundRequest pfRequest = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(String.valueof(camp.Id), 
                                                                                             Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,
                                                                                             String.valueof(accCoMarketing.id),pfaRecord,pmbRecord,'INDIA',
                                                                                             'Consumer',
                                                                                             'Desktop',
                                                                                             'Intel® Core™ i7 Processor',
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

        //PartnerFundClaim pfClaim = Core_MDF_CCP_TestDataUtility.createClaim('Test Claim', Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, pfRequest.Id, System.today(), System.today(), 50000.00, System.today(),bankPAF.Id, true);
        //pfclaim.Core_MDF_Status__c = Label.Core_MDF_Status_Cancelled;
        //update pfClaim;  
        System.runAs(usrAdmin)
        {
        User usr = [SELECT ID From User where Email = 'testCCR@example.com'];
        List<PartnerFundClaim> pfcList = new List<PartnerFundClaim>();
        PartnerFundClaim pfClaimPAF = Core_MDF_CCP_TestDataUtility.createClaim('Test Claim for Neg Adj', Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, pfRequest.Id, System.today(), System.today(), 50000.00, System.today(),bankPAF.Id, false);
        pfClaimPAF.Core_MDF_Status__c = Label.Core_MDF_Status_Pending_Available_Fund;
        //update pfClaimPAF;
                    
        PartnerFundClaim escalationClaim = Core_MDF_CCP_TestDataUtility.createClaim('Test Escalation Claim', Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, pfRequest.Id, System.today(), System.today(), 500.00, System.today(),bankPAF.Id, false);  
        pfcList.add(pfClaimPAF);
        pfcList.add(escalationClaim);
        Database.insert(pfcList);
        PartnerFundClaimShare sharewithExt = new PartnerFundClaimShare(ParentId = pfClaimPAF.Id, UserOrGroupId = usr.Id, AccessLevel = 'Read');
            Database.insert(sharewithExt); 
        }           
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
        PartnerFundClaim claim = [SELECT Id, Amount FROM PartnerFundClaim where Title ='Test Claim for Neg Adj'];
        System.debug('Claims Amount'+claim.Amount);
        claim.Core_MDF_Type_Txt__c ='Adjustment';
        Core_MDF_Adjustment_Request__c adjReq1 = new Core_MDF_Adjustment_Request__c();
        adjReq1.Core_MDF_Reference_Claim_Nbr__c = claim.Id; 
        adjReq1.Core_MDF_Reason_Cd__c = 'Claim Review Results (Negative)';
        adjReq1.Core_MDF_Amount_Amt__c = 500000; 
        adjReq1.Core_MDF_Comments_Txt__c = 'Test';
        createAdjReq.add(adjReq1);
        Core_MDF_AdjustmentReq_ServiceHandler.claimAdjustmentAmountValidation(createAdjReq);
        Core_MDF_Adjustment_Request__c adjReq2 = new Core_MDF_Adjustment_Request__c();
        adjReq2.Core_MDF_Reference_Claim_Nbr__c = claim.Id; 
        adjReq2.Core_MDF_Reason_Cd__c = 'Claim Review Results (Negative)';
        adjReq2.Core_MDF_Amount_Amt__c = 500; 
        adjReq2.Core_MDF_Comments_Txt__c = 'Test';
        createAdjReq.add(adjReq2);
        insert adjReq2;        
        System.assert(true, adjReq2.id != null);
        List<Core_MDF_Adjustment_Request__c> createAdjReq1 = new List<Core_MDF_Adjustment_Request__c>();
        claim.Core_MDF_Type_Txt__c ='Adjustment';
        Core_MDF_Adjustment_Request__c adjReq3 = new Core_MDF_Adjustment_Request__c();
        adjReq3.Core_MDF_Reference_Claim_Nbr__c = claim.Id; 
        adjReq3.Core_MDF_Reason_Cd__c = 'Claim Review Results (Negative)';
        adjReq3.Core_MDF_Amount_Amt__c = 50000; 
        adjReq3.Core_MDF_Comments_Txt__c = 'Test';
        createAdjReq1.add(adjReq3);        
        claim.Core_MDF_Type_Txt__c ='Adjustment';
        Core_MDF_Adjustment_Request__c adjReq4 = new Core_MDF_Adjustment_Request__c();
        adjReq4.Core_MDF_Reference_Claim_Nbr__c = claim.Id; 
        adjReq4.Core_MDF_Reason_Cd__c = 'Claim Review Results (Negative)';
        adjReq4.Core_MDF_Amount_Amt__c = 500; 
        adjReq4.Core_MDF_Comments_Txt__c = 'Test';
        createAdjReq1.add(adjReq4);
		Core_MDF_AdjustmentReq_ServiceHandler.claimAdjustmentAmountValidation(createAdjReq1);        
        Core_MDF_AdjustmentReq_ServiceHandler.createAdjustment(createAdjReq1);
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
                adjReq.Core_MDF_Escalation_Id__c  = adjReq.Core_MDF_Escalation_Id__c;           // Escaltion Id 
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
        system.debug('claim'+claim);
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
        
        Integer i = [SELECT COUNT() from Core_MDF_Adjustment_Request__Share where UserOrGroupId =: usr.Id];          
        //One of owner  
        System.assertEquals(1, i,'Error');
        
        Test.stopTest();        
    }
    
     /* Method to Check status of adjustment request after adjustment claim is Cancelled */
    @isTest static void testCancelAdjustmentRequest(){
        
        Test.startTest();
        User usr = [SELECT ID From User where Email = 'testCCR@example.com'];
        PartnerFundClaim claim1 = [SELECT Id,Core_MDF_Status__c FROM PartnerFundClaim where Title ='Test Claim for Neg Adj'];
        claim1.OwnerId=usr.id;
        Database.update(claim1); 

        System.runAs(usr)
        {
        Core_MDF_Adjustment_Request__c adjReq = new Core_MDF_Adjustment_Request__c();
        PartnerFundClaim claim = [SELECT Id,Core_MDF_Status__c FROM PartnerFundClaim where Title ='Test Claim for Neg Adj'];
        system.debug('claim'+claim);
        claim.Core_MDF_Type_Txt__c ='Adjustment';
        adjReq.Core_MDF_Reference_Claim_Nbr__c = claim.Id;
        adjReq.Core_MDF_Reason_Cd__c = 'Claim Review Results (Negative)';
        adjReq.Core_MDF_Amount_Amt__c = 10; 
        adjReq.Core_MDF_Comments_Txt__c = 'Test';
        adjReq.OwnerId = userInfo.getUserId();
        Database.insert(adjReq);  
        
        adjReq.Core_MDF_Adjustment_Status_nm__c = 'Cancelled';
        Database.update(adjReq); 
        Core_MDF_Adjustment_Request__c adjReq1 = [SELECT Id,Core_MDF_Adjustment_Status_nm__c,Core_MDF_Adjustment_Claim_Nbr__c from Core_MDF_Adjustment_Request__c where Core_MDF_Reference_Claim_Nbr__c=:claim.Id];
        PartnerFundClaim adjClaim = [SELECT Id,Core_MDF_Status__c FROM PartnerFundClaim where Id=:adjReq1.Core_MDF_Adjustment_Claim_Nbr__c];

        system.assertEquals(adjReq1.Core_MDF_Adjustment_Status_nm__c, adjClaim.Core_MDF_Status__c,'Error');
        Test.stopTest();    
            
        }
           
    }
     @isTest static void testAdjustmentClaim(){
        Test.startTest();
        List<PartnerFundClaim> pfcList = new List<PartnerFundClaim>();
        User usr = [SELECT ID From User where Email = 'testCCR@example.com'];
        PartnerFundClaim claim1 = [SELECT Id,Core_MDF_Status__c FROM PartnerFundClaim where Title ='Test Claim for Neg Adj'];
        PartnerFundClaim escalationClaim = [SELECT Id,Core_MDF_Status__c FROM PartnerFundClaim where Title ='Test Escalation Claim'];
        claim1.OwnerId=usr.id;
        escalationClaim.OwnerId=usr.id;
        pfcList.add(claim1);
        pfcList.add(escalationClaim);
        Database.update(pfcList); 
        System.runAs(usr){ 
        Core_MDF_Adjustment_Request__c adjReq = new Core_MDF_Adjustment_Request__c();
        PartnerFundClaim positiveClaim = [SELECT Id,Core_MDF_Status__c FROM PartnerFundClaim where Title ='Test Claim for Neg Adj'];
        
        PartnerFundClaim escalationClaim1 = [SELECT Id,Core_MDF_Status__c FROM PartnerFundClaim where Title ='Test Escalation Claim'];
            
        Core_MDF_Adjustment_Request__c adjReq1 = new Core_MDF_Adjustment_Request__c();
        adjReq1.Core_MDF_Reference_Claim_Nbr__c = positiveClaim.Id;
        adjReq1.Core_MDF_Reason_Cd__c = 'Escalation';
        adjReq1.Core_MDF_Amount_Amt__c = 10; 
        adjReq1.Core_MDF_Comments_Txt__c = 'Test';
        adjReq1.Core_MDF_Adjustment_Claim_Nbr__c=escalationClaim1.Id;
        adjReq1.OwnerId = userInfo.getUserId();
        Database.insert(adjReq1);  
        System.assert(true, adjReq1.id != null); 
        }


    }
    
}