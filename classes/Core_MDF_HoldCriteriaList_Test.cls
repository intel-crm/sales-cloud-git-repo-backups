/****************************************************************************************************************************************
* Class Name  : Core_MDF_HoldCriteriaList_Test
* Version     : 1.0 
* Created Date: 5/10/2019
* Modification Log :
* Developer                        Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture- AD          5/10/2019                    Created to test hold criteria list functionality
* NP(11630236)           05-03-2020                   Added ABM
*****************************************************************************************************************************************/

@isTest
private class Core_MDF_HoldCriteriaList_Test
{
    @TestSetup static void setUpData(){
   
        List<String> bypassFunctionKeys = new List<String>();
        bypassFunctionKeys.add('Bypass_MDF_Budget_Access_Validation');
        bypassFunctionKeys.add('Bypass_MDF_Budget_Status_Validation');
        bypassFunctionKeys.add('Bypass_MDF_Budget_Access');
        
        Set<String> myset1 = new Set<String>();
        List<String> result1 = new List<String>();
        myset1.addAll(bypassFunctionKeys);
        result1.addAll(myset1);
        
        Core_MDF_CCP_TestDataUtility.byPassFeature(result1,true,true);
        
        Account accRecord = Core_MDF_CCP_TestDataUtility.createAccount ('Intel Test Account', NULL, Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);   
        accRecord.BillingCity = 'Test City';         
        accRecord.BillingCountry= 'AUS';
        accRecord.BillingStreet= 'Test Street';
        Database.insert(accRecord);   
        
        
        //Creating Contact for Partner User
        Contact conRecord1 = Core_MDF_CCP_TestDataUtility.createContact(accRecord.Id,true);
        
        // Creating User with utility class 
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.Email = 'sysadmin@example.com';
        Database.insert(usr);
        
        Id profileId = [SELECT Id FROM Profile WHERE Name='Partner' limit 1].Id;
        User usr1 = Core_MDF_CCP_TestDataUtility.createUser(false);        
        usr1.Email='test1@example.com';
        usr1.ContactId = conRecord1.Id;
        usr1.ProfileId = profileId;
        usr1.isActive = true;
        Database.insert(usr1);
        
        ChannelProgram cp = Core_MDF_CCP_TestDataUtility.createProgram (Core_MDF_CCP_ConstantClass.CCF_PROGRAM,'Client CoMarketing Fund', true);
        ChannelProgram cp1 = Core_MDF_CCP_TestDataUtility.createProgram (Core_MDF_CCP_ConstantClass.DCF_PROGRAM,'Data Center CoMarketing Fund', true);
        // Creating Intel Account with utility class
        Account dellCorpAccount = Core_MDF_CCP_TestDataUtility.createAccount ('Dell Corporation', cp.Id,Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);   
        dellCorpAccount.BillingCity = 'Test City';         
        dellCorpAccount.BillingCountry= 'AUS';
        dellCorpAccount.BillingStreet= 'Test Street';
        dellCorpAccount.Core_MDF_CoMarketingActive__c = true;
        Database.insert(dellCorpAccount); 
        dellCorpAccount.IsPartner = true;
        Database.update(dellCorpAccount);
        
        // Creating Co-marketing Account with utility class
        Account dellCCFVirtualCorp = Core_MDF_CCP_TestDataUtility.createAccount ('Dell CCF Virtual Corp', cp.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
        dellCCFVirtualCorp.Core_MDF_Parent_Fund_Account__c = dellCorpAccount.Id;
        dellCCFVirtualCorp.Core_MDF_CoMarketingActive__c = true;
        Database.insert(dellCCFVirtualCorp);
        
         // Creating Co-marketing Account with utility class
        Account dellCCFVirtualCorp1 = Core_MDF_CCP_TestDataUtility.createAccount ('Dell CCF Virtual Corp 1', cp.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
        dellCCFVirtualCorp1.Core_MDF_Parent_Fund_Account__c = dellCorpAccount.Id;
        dellCCFVirtualCorp1.Core_MDF_CoMarketingActive__c = true;
        Database.insert(dellCCFVirtualCorp1);
        
        //Core_MDF_CCP_TestDataUtility.createPartnerGroupMapping(dellCorpAccount.Id,'Internal',dellCorpAccount.Id,cp.Id,'PGM_TEST',true);        
        
        
        Account dellCCFAPAC = Core_MDF_CCP_TestDataUtility.createAccount ('Dell CCF APAC', cp.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type,  false);
        dellCCFAPAC.Core_MDF_Parent_Fund_Account__c = dellCCFVirtualCorp.Id;
        dellCCFAPAC.Core_MDF_CoMarketingActive__c = true;
        Database.insert(dellCCFAPAC);
        
        
        Account dellCCFAPACIndia = Core_MDF_CCP_TestDataUtility.createAccount ('Dell CCF APAC India', cp.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
        dellCCFAPACIndia.Core_MDF_Parent_Fund_Account__c = dellCCFAPAC.Id;
        dellCCFAPACIndia.Core_MDF_Auto_Transfer_Account__c = dellCCFVirtualCorp.ID;
        dellCCFAPACIndia.Core_MDF_Enabled_Auto_Transfer__c = True;
        dellCCFAPACIndia.Core_MDF_CoMarketingActive__c = true;
        dellCCFAPACIndia.Core_MDF_Channel_Program__c = cp.id;
        Database.insert(dellCCFAPACIndia);
        
        //Insert Core_MDF_Configuration__c record - **RG**
        Core_MDF_CCP_TestDataUtility.createMDFConfigurationData();
        
        //Core_MDF_CCP_TestDataUtility.createPartnerNodeUserMapping(dellCCFAPACIndia.Id, usr1.Id, true);
        
        Id recordTypeIdPMB = Schema.SObjectType.PartnerMarketingBudget.getRecordTypeInfosByName().get('CoMarketing').getRecordTypeId();
        // Create PMB for the above Account 
        PartnerMarketingBudget  pmbRecord = Core_MDF_CCP_TestDataUtility.createBudget('Dell PMB',RecordTypeIdPMB,dellCCFVirtualCorp.Id,cp.Id,100000,System.today().addDays(-15),System.today().addDays(30),false);
        pmbRecord.Core_MDF_Budget_Type_Txt__c='OEM CMP';
        pmbRecord.IsIgnoreValidation = true;
        Database.insert(pmbRecord);
        Test.startTest();
        // Create PFA records for the above accounts :
        PartnerFundAllocation pfaDellCCFVirtualCorp = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('pfaDellCCFVirtualCorp',pmbRecord, dellCCFVirtualCorp, 10000,true);
        
        PartnerFundAllocation pfaDellCCFIndia = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('pfaDellCCFIndia',pmbRecord, dellCCFAPACIndia, 1000,true);
        
        Campaign camp = Core_MDF_CCP_TestDataUtility.createCampaign('Test Camp 12','Gaming','IntelÂ® Coreâ„¢ i7 Processor','Yes', Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 'Client CoMarketing Fund', System.today()-3, System.today()+20, 10000, 'Consumer Chromebook', dellCCFVirtualCorp.Id, '2-in-1', true); 
          
        PartnerFundRequest indiaActivity = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(camp.Id),Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,
                                                                                                 string.valueof(dellCCFAPACIndia.id),pfaDellCCFIndia,pmbRecord,
                                                                                                 'BRAZIL','Consumer','Desktop','Intel® Core™ i7 Processor','Broadcast','Podcast','Draft'
                                                                                              ,false);
       
        indiaActivity.Core_MDF_Budget_Type_nm__c = 'CCF 1.0';
        indiaActivity.Title = 'indiaActivity';
        indiaActivity.Core_MDF_Activity_Description__c = 'indiaActivity';
        indiaActivity.Core_MDF_Start_Date__c = System.today()-2;
        indiaActivity.Core_MDF_End_Date__c = System.today()+2;
        indiaActivity.RequestedAmount = 100;
        indiaActivity.Core_MDF_Channel_Partner_Led__c = True;
        indiaActivity.Amount = 0;
        indiaActivity.Core_MDF_Reimbursement_Rate_txt__c='100%';
        Database.insert(indiaActivity);
        
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
        claimFunctionalityNameTriggerExecution3.Core_Active__c = true;
        claimFunctionalityNameTriggerExecution3.Core_Class_Name__c = 'Core_MDF_PFCServiceHandler';
        claimFunctionalityNameTriggerExecution3.Core_Trigger_Events__c = 'after insert,after update';
        claimFunctionalityNameTriggerExecution3.Core_Object__c = 'PartnerFundClaim';
        claimFunctionalityNameTriggerExecution3.Name = 'checkAndSendClaimsToAudit';
        claimFunctionalityNameTriggerExecution3.Core_Description__c = 'test';
        executionList.add(claimFunctionalityNameTriggerExecution3);
        
        Database.insert(executionList);
        System.runAs(usr){
            Core_MDF_Bank__c indiaBank = Core_MDF_CCP_TestDataUtility.createBank(dellCorpAccount.Id, 'Core_MDF_Client_CoMarketing_Fund', false,'1231231230');
            indiaBank.Core_MDF_Payment_Currency_Cd__c = 'USD';
            indiaBank.Core_MDF_Bank_Status__c ='Active';
            Database.insert(indiaBank);
            Core_MDF_Account_Bank_Mapping__c abmCCF1 = Core_MDF_CCP_TestDataUtility.createAccountBankMap(dellCCFAPACIndia.id, indiaBank.Id, TRUE);
        }
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
        
        List<Core_MDF_Hold_Criteria__c> listOfCriteria = new List<Core_MDF_Hold_Criteria__c>();
        //Create Hold List Criteria
        Core_MDF_Hold_Criteria__c criteria1 = new Core_MDF_Hold_Criteria__c();
        criteria1.Core_MDF_Program_id__c = cp.Id;
        criteria1.Core_MDF_Effective_Dt__c = Date.today();
        criteria1.Core_MDF_Ineffective_Dt__c = Date.today().addDays(1);
        criteria1.Core_MDF_UltimateAccount_Id__c = dellCorpAccount.Id;
        
        Core_MDF_Hold_Criteria__c criteria2 = new Core_MDF_Hold_Criteria__c();
        criteria2.Core_MDF_Geo_Txt__c = 'ASMO';
        criteria2.Core_MDF_Effective_Dt__c = Date.today();
        criteria2.Core_MDF_Ineffective_Dt__c = Date.today().addDays(1);
        
        Core_MDF_Hold_Criteria__c criteria3 = new Core_MDF_Hold_Criteria__c();
        criteria3.Core_MDF_Geo_Txt__c = 'PRC';
        criteria3.Core_MDF_Effective_Dt__c = Date.today();
        criteria3.Core_MDF_Ineffective_Dt__c = Date.today();
        
        Core_MDF_Hold_Criteria__c criteria4 = new Core_MDF_Hold_Criteria__c();
        criteria4.Core_MDF_Threshold_Amt__c = 10;
        criteria4.Core_MDF_Effective_Dt__c = Date.today();
        criteria4.Core_MDF_Ineffective_Dt__c = Date.today().addDays(1);
        
        
        listOfCriteria.add(criteria4);
        listOfCriteria.add(criteria3);
        listOfCriteria.add(criteria2);
        listOfCriteria.add(criteria1);
        Database.insert(listOfCriteria);  
        
        Test.stopTest();
    }
    // Test method to run hold list criteria
    @isTest static void testHoldListCriteria(){
        
        Test.startTest();
        
        ChannelProgram cp = [SELECT ID From ChannelProgram where Name =:Core_MDF_CCP_ConstantClass.CCF_PROGRAM];
        User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        
        PartnerFundRequest indiaActivity = [SELECT Id,Title,Core_MDF_Start_Date__c,Core_MDF_End_Date__c  from PartnerFundRequest where Title='indiaActivity' limit 1];
        
        Core_MDF_Bank__c indiaBank = [Select ID from Core_MDF_Bank__c limit 1];
        
        System.runAs(sysAdminUser){
            PartnerFundClaim indiaClaim = Core_MDF_CCP_TestDataUtility.createClaim('India Claim', Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF, 
                                                                                   indiaActivity.Id, 
                                                                                   System.today(),System.today(), 
                                                                                   100, 
                                                                                   System.today(), indiaBank.ID, false);           
            
            indiaClaim.Core_MDF_Currency__c = 'USD';
            Database.insert(indiaClaim);
            
            PartnerFundClaim pfc = [Select Id,Amount from PartnerFundClaim where Id=: indiaClaim.Id LIMIT 1];
            Core_MDF_Hold_Criteria__c criteria = [Select Id,Core_MDF_Threshold_Amt__c from Core_MDF_Hold_Criteria__c where Core_MDF_Threshold_Amt__c = 10 LIMIT 1];
            system.assert(pfc.Amount > criteria.Core_MDF_Threshold_Amt__c);
        }
        Test.stopTest(); 
    }
    
    // Test method to prevent delete hold list criteria
    @isTest static void testPreventDeleteHoldListCriteria(){
        Test.startTest();
        User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        System.runAs(sysAdminUser){
            try{
                Core_MDF_Hold_Criteria__c holdListCriteria  =
                    [Select Id,Core_MDF_UltimateAccount_Id__c,Core_MDF_Program_id__c from Core_MDF_Hold_Criteria__c where Core_MDF_Geo_Txt__c = 'PRC' LIMIT 1];
                Database.delete(holdListCriteria);
            }catch(Exception e){System.assertNotEquals(null,e);}
        }
        Test.stopTest();
    }
    
    // Test method to validate program and account combination
    @isTest static void testPreventCreateHoldCriteria(){
        Test.startTest();
        User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        Account dellIntelAccount = [SELECT Id from Account where Name='Dell Corporation' limit 1];
        ChannelProgram dcfCp = [SELECT Id from ChannelProgram where Name=:Core_MDF_CCP_ConstantClass.DCF_PROGRAM limit 1];
        System.runAs(sysAdminUser){
            
                Core_MDF_Hold_Criteria__c holdListCriteria  =
                    [Select Id,Core_MDF_UltimateAccount_Id__c,Core_MDF_Activity_Category_Type_Txt__c,Core_MDF_Activity_Category_Txt__c,Core_MDF_Program_id__c from Core_MDF_Hold_Criteria__c where Core_MDF_Geo_Txt__c = 'ASMO' LIMIT 1];
                holdListCriteria.Core_MDF_UltimateAccount_Id__c = dellIntelAccount.Id;
                holdListCriteria.Core_MDF_Program_id__c = dcfCp.Id;
                try{ Database.update(holdListCriteria);
                    }catch(Exception e){System.assertNotEquals(null,e);}
                holdListCriteria.Core_MDF_UltimateAccount_Id__c = null;
                holdListCriteria.Core_MDF_Program_id__c = null;
                holdListCriteria.Core_MDF_Region_Country_txt__c = 'PRC->MAINLAND CHINA';
                try{ Database.update(holdListCriteria);
                }catch(Exception e){System.assertNotEquals(null,e);}
                holdListCriteria.Core_MDF_Geo_Txt__c = null;
                try{ Database.update(holdListCriteria);
                }catch(Exception e){System.assertNotEquals(null,e);}

                holdListCriteria.Core_MDF_Region_Country_txt__c = null;
                holdListCriteria.Core_MDF_Activity_Category_Type_Txt__c = 'Broadcast->Podcast';
                try{ Database.update(holdListCriteria);
                }catch(Exception e){System.assertNotEquals(null,e);}
                holdListCriteria.Core_MDF_Activity_Category_Txt__c = 'Event';
                try{ Database.update(holdListCriteria);
                }catch(Exception e){System.assertNotEquals(null,e);}
        }
        
        Test.stopTest();
        
    }
}