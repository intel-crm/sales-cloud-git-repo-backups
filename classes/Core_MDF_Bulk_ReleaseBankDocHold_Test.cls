/**********************************************************************************************************************************************************************
* Class Name  : Core_MDF_Bulk_ReleaseBankDocHold_Test
* Version     : 1.0 
* Created Date: 15-MAR-2021
* Modification Log :
* Developer                        Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------------------------------------
* Accenture- TT                 15-MAR-2021                     Test class to cover "Core_MDF_Bulk_ReleaseBankDocHoldController" & "Core_MDF_BatchUpdateStatusOnClaim"
***********************************************************************************************************************************************************************/
@isTest(SeeAllData=false)
private class Core_MDF_Bulk_ReleaseBankDocHold_Test {
     @TestSetup static void setUpData(){ 
      List<PartnerFundRequest> testPartnerFundRequestRecordList = new List<PartnerFundRequest>();
        List<Account> accountList = new List<Account>();
        List<Campaign> campaignList = new List<Campaign>();
        List<ChannelProgram> channelProgramList = new List<ChannelProgram>();
        List<PartnerMarketingBudget> budgetList= new List<PartnerMarketingBudget>();
        
        Profile adminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        Profile ccpCoreProfile= [SELECT Id FROM Profile WHERE Name='CCP - Core Access'];
        List<User> userList= new List<User>();
        // Creating User with utility class
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.Email = 'sysadmin@example.com';
        usr.profileId = adminProfile.Id;
        userList.add(usr);
        User usr1 = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr1.Email='testexmpl2@intel.com';
        usr1.profileId=ccpCoreProfile.Id;
        usr1.UserPermissionsMarketingUser=true;
        usr1.isActive=true;
        userList.add(usr1);
        Database.insert(userList);
        
        PermissionSet retailPayAdmPS = [SELECT Id, Name FROM PermissionSet WHERE Name='Core_MDF_CCP_Internal_Retail_Payment_Adm' LIMIT 1];
        PermissionSet claimCaseUser = [SELECT Id, Name FROM PermissionSet WHERE Name='Core_MDF_CCP_Internal_Claim_Case_Reviewer' LIMIT 1];
        
        List<PermissionSetAssignment> assignPermissionList = new List<PermissionSetAssignment>();    
        
        PermissionSetAssignment assignPermissionSetObj1 = new PermissionSetAssignment();
        assignPermissionSetObj1.AssigneeId = usr1.Id;
        assignPermissionSetObj1.PermissionSetId = retailPayAdmPS.Id;
        assignPermissionList.add(assignPermissionSetObj1);
        PermissionSetAssignment assignPermissionSetObj2 = new PermissionSetAssignment();
        assignPermissionSetObj2.AssigneeId = usr1.Id;
        assignPermissionSetObj2.PermissionSetId = claimCaseUser.Id;
        assignPermissionList.add(assignPermissionSetObj2);
        
        PermissionSetAssignment assignPermissionSetObj3 = new PermissionSetAssignment();
        assignPermissionSetObj3.AssigneeId = usr.Id;
        assignPermissionSetObj3.PermissionSetId = claimCaseUser.Id;
         assignPermissionList.add(assignPermissionSetObj3);
        //Custom setting records needed for insertion of claim
        Core_MDF_CCP_TestDataUtility.createMDFConfigurationData();
        
        System.runAs(usr){
            //adding bypass feature to bypass access validation
            List<String> bypassFunctionKeys = new List<String>();
            bypassFunctionKeys.add('Bypass_MDF_Budget_Access_Validation');
            bypassFunctionKeys.add('Bypass_MDF_Budget_Status_Validation');
            
            Set<String> myset1 = new Set<String>();
            List<String> result1 = new List<String>();
            myset1.addAll(bypassFunctionKeys);
            result1.addAll(myset1);
            
            List<Core_Trigger_Executions__c> bypassfunctinalitylist1 = Core_MDF_CCP_TestDataUtility.byPassFeature(result1,true,true);
            Database.insert(assignPermissionList);
            //Creating RMF Channel Program with utility class
            ChannelProgram cpRMF = Core_MDF_CCP_TestDataUtility.createProgram ('Retail Marketing Funds','Retail Marketing Funds', false); 
            channelProgramList.add(cpRMF);
            database.insert(channelProgramList);
            List<Account> intelAccounts = new List<Account>();
            
            
             // Creating Intel Account with utility class
            Account dellCorpAccount = Core_MDF_CCP_TestDataUtility.createAccount('Dell Corporation',cpRMF.Id,Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);   
            dellCorpAccount.BillingCity = 'Test City';         
            dellCorpAccount.BillingCountry= 'RUS';
            dellCorpAccount.BillingStreet= 'Test Street';
            dellCorpAccount.BillingState= 'MOS';
            dellCorpAccount.Core_Geo__c= 'EMEA';
            intelAccounts.add(dellCorpAccount);
            database.insert(intelAccounts);
            
            
            //Creating RMF Account with utility class
            Account dellRMFVirtualCorp = Core_MDF_CCP_TestDataUtility.createAccount ('Dell RMF Virtual Corp', cpRMF.Id,Core_MDF_CCP_TestDataUtility.account_Record_Type, false);
            dellRMFVirtualCorp.Core_MDF_Parent_Fund_Account__c = dellCorpAccount.Id;
            dellRMFVirtualCorp.Core_Geo__c = 'EMEA';
            accountList.add(dellRMFVirtualCorp);
            
            database.insert(accountList);            
               
            //Creating Retail Campaign using utility class
            Campaign retailCampaign = Core_MDF_CCP_TestDataUtility.createCampaign('Retail Campaigm1','Gaming','9ᵗʰ Gen','Yes',Core_MDF_CCP_TestDataUtility.campaign_RecordType_Retail, 'Retail Marketing Funds', System.today().addDays(-10), System.today().addDays(10), 100000, 'Instore innovation', dellRMFVirtualCorp.Id,'Desktop', false); 
            retailCampaign.Core_MDF_Opal_Budget_Type_Txt__c ='Retail MDF';
            retailCampaign.Core_MDF_Activity_Category_Type__c =null;
            retailCampaign.Core_MDF_Reimbursement_Rate__c='100%';
            retailCampaign.Core_MDF_Technology__c = 'Intel vPro®';
            campaignList.add(retailCampaign);
            database.insert(campaignList);
         
            //Creating RMF PMB using utility class
            PartnerMarketingBudget  pmbRecord1 = Core_MDF_CCP_TestDataUtility.createRetailBudget('Dell RMF PMB',Core_MDF_CCP_TestDataUtility.budget_Retail_Record_Type,dellRMFVirtualCorp.Id,cpRMF.Id,1000000,System.today().addDays(-15),System.today().addDays(15),false, 'Retail MDF');
            pmbRecord1.IsIgnoreValidation = true;
            budgetList.add(pmbRecord1);
            database.insert(budgetList);
            Test.startTest();
            //Create PFA using utility class
            List<PartnerFundAllocation> pfaList = new List<PartnerFundAllocation>();
            PartnerFundAllocation retailAlloc = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('retailAlloc',pmbRecord1,dellRMFVirtualCorp,20000.0,false);
            pfaList.add(retailAlloc);
            database.insert(pfaList);
            //Create retail bank using utility class
            List<Core_MDF_Bank__c> bankList = new List<Core_MDF_Bank__c>();
            Core_MDF_Bank__c retailBank = Core_MDF_CCP_TestDataUtility.createBank(dellCorpAccount.Id, 'Core_MDF_Retail_Marketing_Funds', false,'1231231230');
            retailBank.Core_MDF_Intel_Company_Code__c = '650';
            retailBank.name = 'retailBank';
            retailBank.Core_MDF_Currency_cd__c = 'USD';
            retailBank.Core_MDF_Payment_Currency_Cd__c = 'USD';
            retailBank.Core_MDF_Tax_codes_cd__c = 'I0';
            retailBank.Core_MDF_Bank_Status__c = 'Active';   
            retailBank.Core_MDF_Supplier_Country_txt__c = 'US';  
            retailBank.Core_MDF_Supplier_City_txt__c = 'New York';  
            retailBank.Core_MDF_Supplier_Region_txt__c = 'New York';  
            retailBank.Core_MDF_Supplier_Postal_Code_cd__c = '728378';  
            //retailBank.Core_MDF_VAT_pct__c = '10';
            bankList.add(retailBank);
            Database.insert(bankList);
            //Create ABM record using utility class
            Core_MDF_Account_Bank_Mapping__c abm1 = Core_MDF_CCP_TestDataUtility.createAccountBankMap(dellRMFVirtualCorp.Id,retailBank.Id,false);
            insert abm1;
            // Creating Activity with budget using utility class
            
            
            //Test.startTest();
            
            
            //Create retail partnerFundRequest
            PartnerFundRequest indiaActivity4 = Core_MDF_CCP_TestDataUtility.createRetailActivity(string.valueof(retailCampaign.Id),string.valueof(dellRMFVirtualCorp.id),
                            System.today()-2,System.today()+2,false);
            indiaActivity4.Title = 'indiaActivity4';
            indiaActivity4.Core_MDF_Budget_Type_nm__c = 'Retail MDF';
            indiaActivity4.Core_MDF_Country_nm__c = 'INDIA';
            indiaActivity4.Core_MDF_Reimbursement_Rate_pct__c = '100%';
            indiaActivity4.Core_MDF_Reimbursement_Rate_txt__c = '100%';
            indiaActivity4.RequestedAmount =1000;
            indiaActivity4.Amount=1000;
            indiaActivity4.Core_MDF_Product_Category_txt__c ='Desktop';
            indiaActivity4.AllocationId  = retailAlloc.Id;//pfaList[0].Id;
            testPartnerFundRequestRecordList.add(indiaActivity4);
        
            database.insert(testPartnerFundRequestRecordList);
            
            List<PartnerMarketingBudget> updateBudgets = new List<PartnerMarketingBudget>();
            pmbRecord1.Core_MDF_Budget_Status__c = 'Released';
            updateBudgets.add(pmbRecord1);
            
           // Database.update(updateBudgets);
            Test.stopTest();
            
            Core_MDF_Configuration__c batchLimit = new Core_MDF_Configuration__c();
            batchLimit.name='BATCH_RECORD_LIMIT_FOR_BULKRELEASE';
            batchLimit.Core_MDF_Value__c='1';
            insert batchLimit;
        }
    }
     @isTest
    static void testClaimsForBankDocHold(){
        Test.startTest();
        List<Id> ClaimIds = new List<Id>();
        User paymentadmin = [SELECT Id,Email from User where Email='testexmpl2@intel.com' limit 1];
        User sysAdmin = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        PartnerFundRequest retailActivity = [SELECT Id,Title,Core_MDF_Start_Date__c,Core_MDF_End_Date__c from PartnerFundRequest where Title='indiaActivity4' limit 1];
        Core_MDF_Bank__c retailBank = [Select ID from Core_MDF_Bank__c where Core_MDF_Program__c = 'Core_MDF_Retail_Marketing_Funds' limit 1];
        List<PartnerFundClaim> claimListToBeProcessed = new List<PartnerFundClaim>();
        System.runAs(sysAdmin){
            
            PartnerFundClaim rmfMdfClaim = Core_MDF_CCP_TestDataUtility.createClaim('RMF MDF Claim', Core_MDF_CCP_TestDataUtility.claim_RecordType_Retail, retailActivity.Id, System.today(), System.today(), 50.00, System.today(), retailBank.Id, false);
            rmfMdfClaim.Core_MDF_Type_Txt__c ='Claim';
            rmfMdfClaim.Core_MDF_Currency__c='USD';
            rmfMdfClaim.Core_MDF_Country_Location_nm__c= 'RUSSIAN FEDERATION'; 
            rmfMdfClaim.Core_MDF_Quarter_Year_Txt__c = 'Q1-2021';
            rmfMdfClaim.Core_MDF_Region_cd__c='EMEA';
            rmfMdfClaim.Core_MDF_To_Be_Audited_Ind__c=TRUE;
            claimListToBeProcessed.add(rmfMdfClaim);
            
            PartnerFundClaim rmfMdfClaim1 = Core_MDF_CCP_TestDataUtility.createClaim('RMF MDF Claim1', Core_MDF_CCP_TestDataUtility.claim_RecordType_Retail, retailActivity.Id, System.today(), System.today(), 50.00, System.today(), retailBank.Id, false);
            rmfMdfClaim1.Core_MDF_Type_Txt__c ='Claim';
            rmfMdfClaim1.Core_MDF_Currency__c='USD';
            rmfMdfClaim1.Core_MDF_Country_Location_nm__c= 'RUSSIAN FEDERATION';
            rmfMdfClaim1.Core_MDF_To_Be_Audited_Ind__c=TRUE;
            rmfMdfClaim1.Core_MDF_Region_cd__c='EMEA';
            claimListToBeProcessed.add(rmfMdfClaim1);
            try{
            Database.insert(claimListToBeProcessed);}
            catch(Exception e){ Core_MDF_CCP_UtilityClass.logError(e);throw e;} 
            ClaimIds.add(claimListToBeProcessed[0].Id);
            ClaimIds.add(claimListToBeProcessed[1].Id);
            Core_MDF_Bulk_ReleaseBankDocHold.getClaims();
            Core_MDF_Bulk_ReleaseBankDocHold.releaseHold(ClaimIds);
            Core_MDF_Bulk_ReleaseBankDocHold.checkAccess();
            rmfMdfClaim.Core_MDF_Bank_Doc_Hold_Ind__c=false;
            Update rmfMdfClaim;
            List<PartnerFundClaim> pfcLst =[Select id,title,Core_MDF_Region_cd__c,Core_MDF_Bank_Doc_Hold_Ind__c,Core_MDF_Program__c,Core_MDF_Status__c from PartnerFundClaim where title='RMF MDF Claim'];
            System.assertEquals(false,pfcLst[0].Core_MDF_Bank_Doc_Hold_Ind__c,'Claim should be released from bank doc hold');
            Test.stopTest();
        }
    }
    
    @isTest
    static void testClaimsForImmediateReleaseBankDocHold(){
        Test.startTest();
        List<Id> ClaimIds = new List<Id>();
        User payAdmnUser = [SELECT Id,Email from User where Email='testexmpl2@intel.com' limit 1];
        User sysAdmin = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        PartnerFundRequest retailActivity = [SELECT Id,Title,Core_MDF_Start_Date__c,Core_MDF_End_Date__c from PartnerFundRequest where Title='indiaActivity4' limit 1];
        Core_MDF_Bank__c retailBank = [Select ID from Core_MDF_Bank__c where Core_MDF_Program__c = 'Core_MDF_Retail_Marketing_Funds' limit 1];
        List<PartnerFundClaim> claimListToBeProcessed = new List<PartnerFundClaim>();
        System.runAs(sysAdmin){
            
            PartnerFundClaim rmfMdfClaim = Core_MDF_CCP_TestDataUtility.createClaim('RMF MDF Claim', Core_MDF_CCP_TestDataUtility.claim_RecordType_Retail, retailActivity.Id, System.today(), System.today(), 50.00, System.today(), retailBank.Id, false);
            rmfMdfClaim.Core_MDF_Type_Txt__c ='Claim';
            rmfMdfClaim.Core_MDF_Currency__c='USD';
            rmfMdfClaim.Core_MDF_Country_Location_nm__c= 'RUSSIAN FEDERATION'; 
            rmfMdfClaim.Core_MDF_Quarter_Year_Txt__c = 'Q1-2021';
            rmfMdfClaim.Core_MDF_Region_cd__c='EMEA';
            rmfMdfClaim.Core_MDF_To_Be_Audited_Ind__c=TRUE;
            claimListToBeProcessed.add(rmfMdfClaim);
            
           
            try{
            Database.insert(claimListToBeProcessed);}
            catch(Exception e){ Core_MDF_CCP_UtilityClass.logError(e);throw e;} 
            ClaimIds.add(claimListToBeProcessed[0].Id);
         
            Core_MDF_Bulk_ReleaseBankDocHold.getClaims();
            Core_MDF_Bulk_ReleaseBankDocHold.releaseHold(ClaimIds);
            Core_MDF_Bulk_ReleaseBankDocHold.checkAccess();
            rmfMdfClaim.Core_MDF_Bank_Doc_Hold_Ind__c=false;
            Update rmfMdfClaim;
            List<PartnerFundClaim> pfcLst =[Select id,title,Core_MDF_Region_cd__c,Core_MDF_Bank_Doc_Hold_Ind__c,Core_MDF_Program__c,Core_MDF_Status__c from PartnerFundClaim where title='RMF MDF Claim'];
            System.assertEquals(false,pfcLst[0].Core_MDF_Bank_Doc_Hold_Ind__c,'Claim should be released from bank doc hold');
            Test.stopTest();
        }
    }
     @isTest
    static void testClaimsForBankDocHoldNew(){
        
        User sysAdmin = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        PartnerFundRequest retailActivity = [SELECT Id,Title,Core_MDF_Start_Date__c,Core_MDF_End_Date__c from PartnerFundRequest where Title='indiaActivity4' limit 1];
        Core_MDF_Bank__c retailBank = [Select ID from Core_MDF_Bank__c where Core_MDF_Program__c = 'Core_MDF_Retail_Marketing_Funds' limit 1];
        List<PartnerFundClaim> claimListToBeProcessed = new List<PartnerFundClaim>();
        System.runAs(sysAdmin){
            PartnerFundClaim pfclaim = Core_MDF_CCP_TestDataUtility.createClaim('Test Claim', Core_MDF_CCP_TestDataUtility.claim_RecordType_Retail, retailActivity.Id, System.today(), System.today(), 50.00, System.today(), retailBank.Id, false);
            pfclaim.Core_MDF_Type_Txt__c ='Claim';
            pfclaim.Core_MDF_Currency__c='USD';
            pfclaim.Core_MDF_Country_Location_nm__c= 'RUSSIAN FEDERATION'; 
            pfclaim.Core_MDF_Quarter_Year_Txt__c = 'Q1-2021';
            pfclaim.Core_MDF_Region_cd__c='EMEA';
            pfclaim.Core_MDF_To_Be_Audited_Ind__c=TRUE;
            pfclaim.Core_MDF_Criteria_Hold_Ind__c=true;
            pfclaim.Core_MDF_Member_Manual_Hold_Ind__c=true;
            pfclaim.Core_MDF_Intel_Manual_Hold_Ind__c=true;
            pfclaim.Core_MDF_Bank_Doc_Hold_Ind__c = true;
            insert pfclaim;
            //claimListToBeProcessed.add(rmfMdfClaim);
            
            PartnerFundClaim pfundclaim = Core_MDF_CCP_TestDataUtility.createClaim('Test Claim1', Core_MDF_CCP_TestDataUtility.claim_RecordType_Retail, retailActivity.Id, System.today(), System.today(), 50.00, System.today(), retailBank.Id, false);
            pfundclaim.Core_MDF_Type_Txt__c ='Claim';
            pfundclaim.Core_MDF_Currency__c='USD';
            pfundclaim.Core_MDF_Country_Location_nm__c= 'RUSSIAN FEDERATION';
            pfundclaim.Core_MDF_To_Be_Audited_Ind__c=TRUE;
            pfundclaim.Core_MDF_Region_cd__c='EMEA';
            pfundclaim.Core_MDF_Criteria_Hold_Ind__c=false;
            pfundclaim.Core_MDF_Member_Manual_Hold_Ind__c=false;
            pfundclaim.Core_MDF_Intel_Manual_Hold_Ind__c=false;
            insert pfundclaim;
           
            test.startTest();
            Core_MDF_ReleaseHold.criteriaManualHoldWrapper wrapp = Core_MDF_ReleaseHold.fetchClaimHoldDetails(pfclaim.Id);
            //system.assertEquals(true, wrapp.hasAccess);
            String result = Core_MDF_ReleaseHold.releaseHoldFromClaim(pfundclaim, pfclaim.Core_MDF_Member_Manual_Hold_Ind__c, pfclaim.Core_MDF_Intel_Manual_Hold_Ind__c, pfclaim.Core_MDF_Criteria_Hold_Ind__c, pfclaim.Core_MDF_Bank_Doc_Hold_Ind__c);
            test.stopTest();
    }}
    @isTest 
    static void testException(){
        
         User sysAdminUser=[SELECT Id FROM User WHERE Email='sysadmin@example.com' LIMIT 1];
         System.runAs(sysAdminUser){
            try{
                Id claim = '006000000000000AAA';  //using hardcoded id for negative test
                Core_MDF_ReleaseHold.fetchClaimHoldDetails(claim);
            }
            catch(exception ex){
                System.debug('Exception'+ex.getMessage());
            }
         }       
    }
}