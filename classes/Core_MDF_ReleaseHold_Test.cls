/****************************************************************************************************************************************
* Class Name  : Core_MDF_ReleaseHold_Test 
* Version     : 1.0 
* Created Date: 10-05-2019
* Modification Log :
* Developer                     Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture - Vaishali D        10-05-2019                   Created to test Release Criteria and Manual Hold claims
*****************************************************************************************************************************************/
@isTest(SeeAllData=false)
private class Core_MDF_ReleaseHold_Test {
    
    /****************************************************************************************************************************************
Method Name:                                   
Description:                                   
Added By:                                      Accenture – VD  -  10-05-2019
Modified By:           Date:                    Changes: 
Accenture – VD        10-05-2019                Created.
*****************************************************************************************************************************************/   
   @TestSetup
    static void setupMethodForCheckingReleaseHold(){
        
        List<String> bypassFunctionKeys = new List<String>();
        bypassFunctionKeys.add('Bypass_MDF_Budget_Access_Validation');
        bypassFunctionKeys.add('Bypass_MDF_Budget_Status_Validation');
        bypassFunctionKeys.add('checkAndSendClaimsForPIC');
        bypassFunctionKeys.add('duplicateClaimCheck');
        bypassFunctionKeys.add('ByPass_BlockLegacyBudgetCreation');
        
        Set<String> myset1 = new Set<String>();
        List<String> result1 = new List<String>();
        myset1.addAll(bypassFunctionKeys);
        result1.addAll(myset1);
        
        Core_MDF_CCP_TestDataUtility.byPassFeature(result1,true,true);
        
        List<Account> masterAccountList = new List<Account>();
        List<Account> accountList = new List<Account>();
        List<Account> toBeUpdated = new List<Account>();
        List<Campaign> campaignList = new List<Campaign>();
        List<PartnerMarketingBudget> budgetList= new List<PartnerMarketingBudget>();
        List<PartnerFundRequest> testPartnerFundRequestRecordList = new List<PartnerFundRequest>();
        
        List<ChannelProgram> channelProg = new List<ChannelProgram>();
        // Creating channel program with utility class
        ChannelProgram cp = Core_MDF_CCP_TestDataUtility.createProgram ('Client','Client CoMarketing Fund', false);
        channelProg.add(cp);
        Database.insert(channelProg);
        
        Account Masteracc = Core_MDF_CCP_TestDataUtility.createIntelAccount('Test Account 1', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
       
        Masteracc.Core_Geo__c= 'EMEA';
        insert Masteracc;
        
        Account ccfAccount = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test Account CCF', cp.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, Masteracc.Id, false);
        accountList.add(ccfAccount);
        
        database.insert(accountList);
        // Updating Accounts 
        Masteracc.isPartner = true;
        ccfAccount.isPartner = true;
        toBeUpdated.add(Masteracc);
        toBeUpdated.add(ccfAccount);
        Database.update(toBeUpdated);
        Core_MDF_CCP_TestDataUtility.createMDFConfigurationData();
        
        
    
        Profile systemAdminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator' limit 1];
        Profile ccpCoreProfile = [SELECT Id FROM Profile WHERE Name='CCP - Core Access' LIMIT 1];
        PermissionSet clmCaseRevPS = [SELECT Id, Name FROM PermissionSet WHERE Name='Core_MDF_CCP_Internal_Claim_Case_Reviewer' LIMIT 1];
        PermissionSet bankDocHoldPS = [SELECT Id, Name FROM PermissionSet WHERE Name='Core_MDF_CCP_Internal_CCF_Payment_Adm' LIMIT 1];
        
        List<User> usrList = new List<User>();
        // Creating User with utility class 
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.profileId = systemAdminProfile.Id;
        usr.LastName = 'SysAdmUser';
        usrList.add(usr);
        
        User usr1 = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr1.LastName='Claim Case User';
        usr1.profile=ccpCoreProfile;
        usrList.add(usr1);
        
        Database.insert(usrList);
        
        List<PermissionSetAssignment> permissionList = new List <PermissionSetAssignment>();
        PermissionSetAssignment assignPermissionSetObj = new PermissionSetAssignment();
        assignPermissionSetObj.AssigneeId = usr1.Id;
        assignPermissionSetObj.PermissionSetId = clmCaseRevPS.Id;
        permissionList.add(assignPermissionSetObj);
        
        PermissionSetAssignment assignPermissionSetObj1 = new PermissionSetAssignment();
        assignPermissionSetObj1.AssigneeId = usr1.Id;
        assignPermissionSetObj1.PermissionSetId = bankDocHoldPS.Id;
        permissionList.add(assignPermissionSetObj1);
        
        system.runAs(usr){
            Database.insert(permissionList);
        }
        
        
        System.runAs(usr){
            PartnerMarketingBudget budgetCCF = Core_MDF_CCP_TestDataUtility.createBudget('Test Budget 2', Core_MDF_CCP_TestDataUtility.Budget_Record_Type, ccfAccount.Id, cp.Id, 5000000, System.today(),System.today().addDays(110), false);
            budgetCCF.Core_MDF_Budget_Type_Txt__c = 'CCF 1.0';
            budgetList.add(budgetCCF);
            Database.insert(budgetList);
            
            List<PartnerFundAllocation> pfaList = new List<PartnerFundAllocation>();
            
            PartnerFundAllocation pfaCCF = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('Test Allocation CCF',budgetCCF,ccfAccount,200000.0,false);
            pfaList.add(pfaCCF);
            Database.insert(pfaList);
            
            // Creating campaigns using utility class
            Campaign camp = Core_MDF_CCP_TestDataUtility.createCampaign('TestCamp','Consumer','Intel® Corporate Logo', 
                                                                        'Yes',Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF,
                                                                        'Client CoMarketing Fund',System.today(),
                                                                        System.today().addDays(200), 20000, 'Unite',ccfAccount.Id,'2-in-1', false);
            
            campaignList.add(camp);
            
            database.insert(campaignList);
            
            // Creating activities using utility class
            PartnerFundRequest pfrCCF = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(camp.Id),
                                                                                           Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,
                                                                                           string.valueof(ccfAccount.id),pfaCCF,budgetCCF,'INDIA','Small and Medium Business',
                                                                                           'Desktop','Intel® Core™ i7 Processor','Broadcast',
                                                                                           'Radio','Draft',false);
            pfrCCF.Title = 'Activity CCF';
            pfrCCF.Core_MDF_Activity_Description__c = 'indiaActivity';
            pfrCCF.Core_MDF_Start_Date__c = system.today();
            pfrCCF.Core_MDF_End_Date__c = system.today();
            pfrCCF.RequestedAmount = 10000;
            pfrCCF.Amount = 10000;
            pfrCCF.Status = 'Approved';
            pfrCCF.Core_MDF_Budget_Type_nm__c = 'CCF 1.0';
            pfrCCF.Core_MDF_Fund_Request_Status__c='Planned';
            pfrCCF.Core_MDF_Reimbursement_Rate_txt__c='100%';
            
            testPartnerFundRequestRecordList.add(pfrCCF);
            database.insert(testPartnerFundRequestRecordList);
            
            List<Core_MDF_Bank__c> bankList = new List<Core_MDF_Bank__c>();
            // Creating Bank
            Core_MDF_Bank__c ccfBank = Core_MDF_CCP_TestDataUtility.createBank(Masteracc.id,'Core_MDF_Client_CoMarketing_Fund',false,'9966467890');
            bankList.add(ccfBank);
                      
            Database.insert(bankList);
            bankList[0].Core_MDF_Bank_Status__c = 'Active';
            Database.update(bankList);
            
            List<Core_MDF_Account_Bank_Mapping__c> abmList = new List<Core_MDF_Account_Bank_Mapping__c>();
            //Creating Account Bank Mapping
            Core_MDF_Account_Bank_Mapping__c abm1 = Core_MDF_CCP_TestDataUtility.createAccountBankMap(ccfAccount.Id,ccfBank.Id,false);
            abmList.add(abm1);
            Database.insert(abmList);
            
            List<PartnerFundClaim> pfcList=new List<PartnerFundClaim>();
            PartnerFundClaim pfc = Core_MDF_CCP_TestDataUtility.createClaim('Test Claim',Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF,pfrCCF.Id,System.today(),System.today(),2000,System.today(),ccfBank.Id,false);
            pfc.Core_MDF_Country_Location_nm__c ='INDIA';
            pfc.Core_MDF_Currency__c = 'USD';
            pfc.Core_MDF_Criteria_Hold_Ind__c=true;
            pfc.Core_MDF_Member_Manual_Hold_Ind__c=true;
            pfc.Core_MDF_Intel_Manual_Hold_Ind__c=true;
            pfc.Core_MDF_Bank_Doc_Hold_Ind__c = true;
            pfc.Core_MDF_Processing_Preference_nm__c = 'Settle, then get paid';
            pfcList.add(pfc);
            
            PartnerFundClaim claim = Core_MDF_CCP_TestDataUtility.createClaim('Test Claim1',Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF,pfrCCF.Id,System.today(),System.today(),2000,System.today(),ccfBank.Id,false);
            claim.Core_MDF_Country_Location_nm__c ='INDIA';
            claim.Core_MDF_Currency__c = 'USD';
            claim.Core_MDF_Criteria_Hold_Ind__c=false;
            claim.Core_MDF_Member_Manual_Hold_Ind__c=false;
            claim.Core_MDF_Intel_Manual_Hold_Ind__c=false;
            claim.Core_MDF_Processing_Preference_nm__c = 'Settle, then get paid';
            pfcList.add(claim);
            test.startTest();
            database.insert(pfcList);
            test.stopTest();
        }
         
        List<Core_MDF_Hold_Criteria__c> listOfCriteria = new List<Core_MDF_Hold_Criteria__c>();
        //Create Hold List Criteria
        Core_MDF_Hold_Criteria__c criteria1 = new Core_MDF_Hold_Criteria__c();
        criteria1.Core_MDF_Program_id__c = cp.Id;
        criteria1.Core_MDF_Effective_Dt__c = Date.today();
        criteria1.Core_MDF_Ineffective_Dt__c = Date.today().addDays(5);
        //criteria1.Core_MDF_UltimateAccount_Id__c = dellCorpAccount.Id;
        
        Core_MDF_Hold_Criteria__c criteria2 = new Core_MDF_Hold_Criteria__c();
        criteria2.Core_MDF_Geo_Txt__c = 'ASMO';
        criteria2.Core_MDF_Effective_Dt__c = Date.today();
        criteria2.Core_MDF_Ineffective_Dt__c = Date.today().addDays(5);
        
        Core_MDF_Hold_Criteria__c criteria3 = new Core_MDF_Hold_Criteria__c();
        criteria3.Core_MDF_Geo_Txt__c = 'PRC';
        criteria3.Core_MDF_Effective_Dt__c = Date.today();
        criteria3.Core_MDF_Ineffective_Dt__c = Date.today().addDays(5);
        
        Core_MDF_Hold_Criteria__c criteria4 = new Core_MDF_Hold_Criteria__c();
        criteria4.Core_MDF_Threshold_Amt__c = 10;
        criteria4.Core_MDF_Effective_Dt__c = Date.today();
        criteria4.Core_MDF_Ineffective_Dt__c = Date.today().addDays(5);
        
        
        listOfCriteria.add(criteria4);
        listOfCriteria.add(criteria3);
        listOfCriteria.add(criteria2);
        listOfCriteria.add(criteria1);
        Database.insert(listOfCriteria);
    }
    
    @isTest
    static void testClaimsForBankDocHold(){
        
        PartnerFundClaim pfclaim = [SELECT Id,Core_MDF_Criteria_Hold_Ind__c,Core_MDF_Member_Manual_Hold_Ind__c,Core_MDF_Intel_Manual_Hold_Ind__c,Core_MDF_Bank_Doc_Hold_Ind__c FROM PartnerFundClaim WHERE Title='Test Claim' LIMIT 1];
      PartnerFundClaim pfundclaim = [SELECT Id,Core_MDF_Criteria_Hold_Ind__c,Core_MDF_Member_Manual_Hold_Ind__c,Core_MDF_Intel_Manual_Hold_Ind__c,Core_MDF_Bank_Doc_Hold_Ind__c FROM PartnerFundClaim WHERE Title='Test Claim1' LIMIT 1];
        
        User sysAdminUser=[SELECT Id FROM User WHERE LastName='Claim Case User' LIMIT 1];
      List<PartnerFundClaim> claimListToBeProcessed = new List<PartnerFundClaim>();
        System.runAs(sysAdminUser){
            test.startTest();
            Core_MDF_ReleaseHold.criteriaManualHoldWrapper wrapp = Core_MDF_ReleaseHold.fetchClaimHoldDetails(pfclaim.Id);
            system.assertEquals(true, wrapp.hasAccess);
            String result = Core_MDF_ReleaseHold.releaseHoldFromClaim(pfundclaim, pfclaim.Core_MDF_Member_Manual_Hold_Ind__c, pfclaim.Core_MDF_Intel_Manual_Hold_Ind__c, pfclaim.Core_MDF_Criteria_Hold_Ind__c, pfclaim.Core_MDF_Bank_Doc_Hold_Ind__c);
            test.stopTest();
        }
    }
    
    @isTest 
    static void testException(){
        
        
        User sysAdminUser=[SELECT Id FROM User WHERE LastName='Claim Case User' LIMIT 1];
         System.runAs(sysAdminUser){
            try{
                Id claim = '006000000000000AAA';
                Core_MDF_ReleaseHold.fetchClaimHoldDetails(claim);
            }
            catch(exception ex){
                System.debug('Exception'+ex.getMessage());
            }
         }       
    }
     @isTest 
    static void testCriteriaHold(){
        List<PartnerFundClaim> pfundclaimlist = [SELECT Id,Core_MDF_Criteria_Hold_Ind__c,Core_MDF_Member_Manual_Hold_Ind__c,Core_MDF_Intel_Manual_Hold_Ind__c,Core_MDF_Bank_Doc_Hold_Ind__c FROM PartnerFundClaim];
        Core_MDF_HoldCriteriaListProcessHelper.processClaimsForCriteriaHold(pfundclaimlist);
    }
}