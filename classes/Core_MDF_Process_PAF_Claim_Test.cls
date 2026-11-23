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
        
        Profile ccpCoreProfile = [SELECT Id FROM Profile WHERE Name='CCP - Core Access' LIMIT 1];
        PermissionSet clmCaseRevPS = [SELECT Id, Name FROM PermissionSet WHERE Name='Core_MDF_CCP_Internal_Claim_Case_Reviewer' LIMIT 1];
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
        }
        
        // Create PMB for the above Account 
        PartnerMarketingBudget  pmbRecord = Core_MDF_CCP_TestDataUtility.createBudget('TestPMB',Core_MDF_CCP_TestDataUtility.budget_Record_Type,accCoMarketing.Id,cProgram.Id,123456,System.today()-1,System.today()-1,true);
        
        // Create PFA records for the above accounts :
        PartnerFundAllocation pfaRecord = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('TestPFA',pmbRecord, accCoMarketing, 1234,true);
        
        // PartnerFundAllocation pfaRecord2 = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('TestPFA2',pmbRecord, accCoMarketing, 12345, true);       
        Campaign camp = Core_MDF_CCP_TestDataUtility.createCampaign('Test Camp 12','Gaming','Intel® Core™ i7+ Processor', Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 'Client CoMarketing Fund', System.today()-1, System.today()-1, 10000, 'Consumer Chromebook', accCoMarketing.Id, '2-in-1', true);         
        
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
        pfRequest.Core_MDF_Start_Date__c = System.today()-1;
        pfRequest.Core_MDF_End_Date__c = System.today()-1;
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
    /****************************************************************************************************************************************
Method Name:                                   testListOfClaims
Description:                                   Created to test user permission 
Added By:                                      Accenture – VD  -  18-Dec-2019
Modified By:                  Date:            Changes: 
Accenture – VD              18-Dec-2019        Refactored to follow best practice
*****************************************************************************************************************************************/  
    @isTest static void testListOfClaims(){
        
        test.startTest();
        
        PartnerFundRequest pfRequest= [Select id from PartnerFundRequest where title = 'Test Activity1'];
        Core_MDF_Bank__c bankPAF = [Select id from Core_MDF_Bank__c ];
        List<PartnerFundClaim> pfcList = new List<PartnerFundClaim>();
        PartnerFundClaim pfClaim = Core_MDF_CCP_TestDataUtility.createClaim('Test Claim', Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, pfRequest.Id, System.today()-1, System.today()-1, 50000.00, System.today()-1,bankPAF.Id, true);
        pfclaim.Core_MDF_Status__c = Label.Core_MDF_Status_Cancelled;
        pfcList.add(pfClaim);
        
        PartnerFundClaim pfClaimPAF = Core_MDF_CCP_TestDataUtility.createClaim('Test Claim1', Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, pfRequest.Id, System.today()-1, System.today()-1, 50000.00, System.today()-1,bankPAF.Id, true);
        pfClaimPAF.Core_MDF_Status__c = Label.Core_MDF_Status_Pending_Available_Fund;
        pfcList.add(pfClaimPAF);
        
        database.update(pfcList);
        User usr = [select id,email from User where email='clmcase@example.com'];
        list<partnerFundClaim> cancelledClaims = [select id,ChannelPartnerId,AllocationId from partnerFundClaim where title = 'Test Claim'];
        Map<Id,partnerFundAllocation> pfaMap = new Map<Id,partnerFundAllocation>([select id,ChannelPartnerId from partnerFundAllocation where title = 'TestPFA']);
        system.runAs(usr){
            Core_MDF_Process_PAF_Claim.fetchAccountIdsbyCancelledClaims(cancelledClaims);
            
            Core_MDF_Process_PAF_Claim.fetchClaimsByAllocationIds(pfaMap.keySet());
            
        }
        System.assertNotEquals(NULL,pfaMap);
        test.stopTest(); 
      
    }
}