/****************************************************************************************************************************************
* Test Class Name   : Core_MDF_Claim_Score_Notify_Batch_Test
* Business Class    : Core_MDF_Claim_Score_Notify_Batch , Core_MDF_Email_NotificationLoggingBatch
* Description       : To cover Core_MDF_Claim_Score_Notify_Batch & Core_MDF_Email_NotificationLoggingBatch classes
* Developer         : Shiva
* Updated     		: Date			developer			description
*****************************************************************************************************************************************/

@isTest
public class Core_MDF_Claim_Score_Notify_Batch_Test {
    @testSetup
    static void createTestData(){
        User testUser = Core_MDF_CCP_TestDataUtility.createUser(false); 
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        testUser.LastName='Admin_user';
        testUser.UserRoleId = usRole.Id;
        insert testUser;
        
        List<String> bypassFunctionKeys = new List<String>();
        bypassFunctionKeys.add('Bypass_Duplicate_Budget_Check');
        bypassFunctionKeys.add('Bypass_MDF_Budget_Access_Validation');
        bypassFunctionKeys.add('Bypass_MDF_Budget_Status_Validation');
        bypassFunctionKeys.add('Bypass_GeoBased_Budget_Sharing');
        bypassFunctionKeys.add('Bypass_Allocation_Reservation');
        bypassFunctionKeys.add('Bypass_GeoBased_Allocation_Sharing');
        bypassFunctionKeys.add('byPassShareUnshareCampaignRecord');
        bypassFunctionKeys.add('byPassCampaignAndRelatedRecords');
        bypassFunctionKeys.add('Bypass_ValidateActivityWithCampaign');
        bypassFunctionKeys.add('byPass_Cancel_Activity');
        bypassFunctionKeys.add('Core_MDF_Bypass_ATFBatchUpdate');
        bypassFunctionKeys.add('Bypass_Claims_Duplicate_Check');
        bypassFunctionKeys.add('Bypass_Claims_Sharing_Internal_Users');
        bypassFunctionKeys.add('Bypass_ClaimAdjReq_Share_On_Owner_Chng');
        bypassFunctionKeys.add('Bypass_ClaimAdjReq_Share_Internal_Usrs');
        bypassFunctionKeys.add('Bypass_ClaimAdjReq_Share_External_Usrs');
        bypassFunctionKeys.add('Bypass_Claim_AdjReq_Amount_Validation');
        bypassFunctionKeys.add('Bypass_Claims_Amt_vs_Budget_Amt_Check');        
        bypassFunctionKeys.add('Bypass_Claims_ABM_Validation');
        bypassFunctionKeys.add('Bypass_Claims_Sharing_Partner_Users');
        bypassFunctionKeys.add('Bypass_Claims_Amt_vs_Camp_Amt_Check');
        bypassFunctionKeys.add('Bypass_Claim_OwnerLang_EmailTemp');
        bypassFunctionKeys.add('Bypass_StampingOfActySubType_Check');
        bypassFunctionKeys.add('Bypass_Claims_Sharing_On_Owner_Change');
        bypassFunctionKeys.add('Core_MDF_BypassATFFlagUpdate');
        bypassFunctionKeys.add('Core_MDF_BypassATFFlagUpdateBatch');
        bypassFunctionKeys.add('Core_MDF_Bypass_CloseDateExtend_ATF');
        bypassFunctionKeys.add('Bypass_MDF_Budget_Update_Validation');
        bypassFunctionKeys.add('Bypass_MDF_Budget_Access');
        bypassFunctionKeys.add('ShareActivityWithInternalUsers_Bypass');
        bypassFunctionKeys.add('Bypass_Duplicate_Bank_Check');
        bypassFunctionKeys.add('Bypass_Bank_Internal_Sharing');
        bypassFunctionKeys.add('Bypass_Bank_External_Sharing');
        bypassFunctionKeys.add('Bypass_Bank_Program_InActivation_Check');
        bypassFunctionKeys.add('Bypass_Bank_ABM_Sharing');
        bypassFunctionKeys.add('Bypass_ABM_Internal_Sharing');
        bypassFunctionKeys.add('Bypass_ABM_External_Sharing');
        
        
        Set<String> myset1 = new Set<String>();
        List<String> result1 = new List<String>();
        myset1.addAll(bypassFunctionKeys);
        result1.addAll(myset1);
        
        System.runAs(testUser){
            List<Core_Trigger_Executions__c> bypassfunctinalitylist1 = Core_MDF_CCP_TestDataUtility.byPassFeature(result1,true,true);
            Core_MDF_Configuration__c execution1 = new Core_MDF_Configuration__c();
            execution1.Name = 'ALLOWED_PRG_FOR_RUS_NOTIF';
            execution1.Core_MDF_Category__c = 'Bank Document Hold Logic';
            execution1.Core_MDF_Value__c = 'Retail Marketing Funds,Intel Partner Alliance';
            insert execution1;   
        }
        
        
        Test.startTest();
        List<ChannelProgram> cpList = new List<ChannelProgram> ();
        ChannelProgram ccfCp = Core_MDF_CCP_TestDataUtility.createProgram ('Client','Client CoMarketing Fund', false);
        ChannelProgram rmfCp = Core_MDF_CCP_TestDataUtility.createProgram ('Retail Marketing Funds','Retail Marketing Funds', false);
        cpList.add(ccfCp);
        cpList.add(rmfCp);
        System.runAs(testUser){
            insert cpList;
        }
        Account ccpIntelAccount = Core_MDF_CCP_TestDataUtility.createIntelAccount('CCP Test Intel Account', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);  
        Account dellCorpAccount = Core_MDF_CCP_TestDataUtility.createAccount ('Dell Corporation', NULL,Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);   
        dellCorpAccount.BillingCity = 'Test City';         
        dellCorpAccount.BillingCountry= 'AUS';
        dellCorpAccount.BillingStreet= 'Test Street';
        dellCorpAccount.BillingState= 'TAS';
        dellCorpAccount.Core_Geo__c= 'APJ';
        
        System.runAs(testUser){
            Database.insert(ccpIntelAccount);
            database.insert(dellCorpAccount);
        }
        Account dellRMFVirtualCorp = Core_MDF_CCP_TestDataUtility.createAccount ('Dell RMF Virtual Corp', rmfCp.Id,Core_MDF_CCP_TestDataUtility.account_Record_Type, false);
        dellRMFVirtualCorp.Core_MDF_Parent_Fund_Account__c = dellCorpAccount.Id;
        dellRMFVirtualCorp.Core_Geo__c = 'APJ';
        System.runAs(testUser){
            database.insert(dellRMFVirtualCorp);
        }
        List<Account> accountList = new List<Account>();
        Account ccfacc = Core_MDF_CCP_TestDataUtility.createAccount ('Co-marketing CCF Test Account', 
                                                                     ccfCp.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
        ccfacc.Core_MDF_Parent_Fund_Account__c = ccpIntelAccount.Id;
        accountList.add(ccfacc);
        System.runAs(testUser){
            Database.insert(accountList);
        }
        List<Account> accCoMarketingList = new List<Account>();
        
        Account acc = Core_MDF_CCP_TestDataUtility.createAccount ('Co-marketing Test Account', ccfCp.Id,
                                                                  Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
        acc.Core_MDF_Parent_Fund_Account__c = ccfacc.Id;
        accCoMarketingList.add(acc);
        System.runAs(testUser){
            Database.insert(accCoMarketingList);
        }
        
        PartnerMarketingBudget  pmbRecord1 = Core_MDF_CCP_TestDataUtility.createRetailBudget('Dell RMF PMB',Core_MDF_CCP_TestDataUtility.budget_Retail_Record_Type,dellRMFVirtualCorp.Id,rmfCp.Id,1000000,System.today().addDays(-15),System.today().addDays(15),false, 'Retail MDF');
        pmbRecord1.IsIgnoreValidation = true;
        pmbRecord1.Core_MDF_Budget_Type_Txt__c = 'Retail MDF';
        System.runAs(testUser){
            database.insert(pmbRecord1);
        }
        
        PartnerFundAllocation retailAlloc = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('retailAlloc',pmbRecord1,dellRMFVirtualCorp,20000.0,false);
        System.runAs(testUser){
            database.insert(retailAlloc);
        }
        List<Campaign> campList=new List<Campaign>();
        Campaign MDFcamp = Core_MDF_CCP_TestDataUtility.createCampaign('TestCampOpal','Consumer','Intel® Corporate Logo', 'MDF or both CMP & MDF',
                                                                       Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 'Client CoMarketing Fund',System.today()-250 , 
                                                                       System.today()+90, 2000, 'Unite', ccfacc.Id,'2-in-1', false);
        MDFcamp.Core_MDF_Opal_Budget_Type_Txt__c = 'MDF;OEM CMP'; 
        campList.add(MDFcamp);
        Campaign retailCampaign = Core_MDF_CCP_TestDataUtility.createCampaign('Retail Campaigm1','Gaming','9ᵗʰ Gen','No', Core_MDF_CCP_TestDataUtility.campaign_RecordType_Retail, 'Retail Marketing Funds', System.today().addDays(-22), System.today().addDays(20), 100000, 'Instore innovation', dellRMFVirtualCorp.Id,'Desktop', false); 
        retailCampaign.Core_MDF_Is_Opal__c='No';
        retailCampaign.Core_MDF_Opal_Budget_Type_Txt__c= 'Retail MDF';
        retailCampaign.Core_MDF_Activity_Category_Type__c =null;
        retailCampaign.Core_MDF_Reimbursement_Rate__c='100%';
        retailCampaign.Core_MDF_Technology__c = 'Intel vPro®';
        campList.add(retailCampaign);
        System.runAs(testUser){
            insert campList;
        }
        
        system.runAs(testUser)
        {
            PermissionSet psFinance = [SELECT Id FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_Finance_Usr' LIMIT 1];
            insert new PermissionSetAssignment(AssigneeId = testUser.id, PermissionSetId = psFinance.Id);
            PermissionSet psFinance1 = [SELECT Id FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_CCF_User' LIMIT 1];
            insert new PermissionSetAssignment(AssigneeId = testUser.id, PermissionSetId = psFinance1.Id);
            PermissionSet psbudLoader = [SELECT Id FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_CCF_MDF_Budget_Loader' LIMIT 1];
            insert new PermissionSetAssignment(AssigneeId = testUser.id, PermissionSetId = psbudLoader.Id);
            PermissionSet rmfPayAdmPS = [SELECT Id, Name From PermissionSet WHERE Name='Core_MDF_CCP_Internal_Retail_Payment_Adm' LIMIT 1];
            insert new PermissionSetAssignment(AssigneeId = testUser.id, PermissionSetId = rmfPayAdmPS.Id);
            PermissionSet ccfPayAdmPS = [SELECT Id, Name From PermissionSet WHERE Name='Core_MDF_CCP_Internal_CCF_MDF_Payment_Admin' LIMIT 1];
            insert new PermissionSetAssignment(AssigneeId = testUser.id, PermissionSetId = ccfPayAdmPS.Id);
            PermissionSet rmfAccMgr = [SELECT Id, Name From PermissionSet WHERE Name='Core_MDF_CCP_Internal_Retail_Account_Manager' LIMIT 1];
            insert new PermissionSetAssignment(AssigneeId = testUser.id, PermissionSetId = rmfAccMgr.Id);
        }
        
        Id retailIUPGMRecordTypeId = Schema.SObjectType.Core_MDF_Int_Users_Partner_Geo_Mapping__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_Retail_Marketing_Funds').getRecordTypeId();
        Core_MDF_Int_Users_Partner_Geo_Mapping__c rmfIupgm = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
        rmfIupgm.recordTypeId = retailIUPGMRecordTypeId;
        rmfIupgm.Core_MDF_Account_id__c = dellRMFVirtualCorp.Id;
        rmfIupgm.Core_MDF_Program_nm__c = 'Retail Marketing Funds';
        rmfIupgm.Core_MDF_Region_Sub_Region_nm__c = 'EMEA';
        rmfIupgm.Core_MDF_User_id__c =testUser.Id;
        rmfIupgm.Core_MDF_Role_nm__c='Core_MDF_CCP_Internal_Retail_Account_Manager';
        rmfIupgm.Core_MDF_All_Accounts_cd__c = 'No';
        System.runAs(testUser){
            insert rmfIupgm;
        }
        
        Id recordTypeIdPMB = Schema.SObjectType.PartnerMarketingBudget.getRecordTypeInfosByName().get('CoMarketing').getRecordTypeId();
        PartnerMarketingBudget opalbudget = Core_MDF_CCP_TestDataUtility.createBudget('TestOpalPMB',recordTypeIdPMB,ccfacc.Id,ccfCp.Id,12345678,System.today().addDays(-90),System.today().addDays(+90),false);
        opalbudget.Core_MDF_Budget_Type__c='MDF';
        opalbudget.Core_MDF_Budget_Type_Txt__c='MDF';
        System.runAs(testUser){
            insert opalbudget;
        }
        
        Core_MDF_Bank__c retailBank = Core_MDF_CCP_TestDataUtility.createBank(dellCorpAccount.Id, 'Core_MDF_Retail_Marketing_Funds', false,'1231231230');
        retailBank.Core_MDF_Intel_Company_Code__c = '150';
        retailBank.name = 'retailBank';
        retailBank.Core_MDF_Currency_cd__c = 'USD';
        retailBank.Core_MDF_Payment_Currency_Cd__c = 'USD';
        retailBank.Core_MDF_Tax_codes_cd__c = 'I0';
        retailBank.Core_MDF_Bank_Location__c = 'US';
        retailBank.Core_MDF_Bank_Status__c = 'Active';   
        retailBank.Core_MDF_Effective_Date__c=System.today().addDays(-1);
        retailBank.Core_MDF_Supplier_Country_txt__c = 'US';  
        retailBank.Core_MDF_Supplier_City_txt__c = 'New York';  
        retailBank.Core_MDF_Supplier_Region_txt__c = 'New York';  
        retailBank.Core_MDF_Supplier_Postal_Code_cd__c = '728378';  
        retailBank.Core_MDF_VAT_pct__c = '10';
        system.runAs(testUser){
            database.insert(retailBank);
        }
        PartnerFundRequest rmfPfr = Core_MDF_CCP_TestDataUtility.createRetailActivity(string.valueof(retailCampaign.Id),string.valueof(dellRMFVirtualCorp.id),
                                                                                      System.today()-5,System.today()+5,false);
        rmfPfr.Title = 'indiaActivity4';
        rmfPfr.Core_MDF_Budget_Type_nm__c = 'Retail MDF';
        rmfPfr.Core_MDF_Country_nm__c = 'INDIA';
        rmfPfr.Core_MDF_Reimbursement_Rate_pct__c = '100%';
        rmfPfr.RequestedAmount =1000;
        rmfPfr.Amount=1000;
        rmfPfr.Core_MDF_Reimbursement_Rate_txt__c='60%';
        rmfPfr.Core_MDF_Product_Category_txt__c ='Notebook/Mobile';
        rmfPfr.AllocationId = retailAlloc.Id;
        rmfPfr.Core_MDF_TargetAudience__c = 'Small and Medium Business';
        system.runAs(testUser){
            database.insert(rmfPfr);
        }
        Core_MDF_Account_Bank_Mapping__c rmfBank = Core_MDF_CCP_TestDataUtility.createAccountBankMap(dellRMFVirtualCorp.Id,retailBank.Id,false);
        system.runAs(testUser){
            database.insert(rmfBank);
        }
        
        PartnerFundAllocation pfaRecordOpal = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('TestPFA3',opalbudget, ccfacc, 199999, false);
        System.runAs(testUser){
            insert pfaRecordOpal;
        }
        Core_MDF_Campaign_Budgets__c oemcmpBudget = new Core_MDF_Campaign_Budgets__c();
        oemcmpBudget.Core_MDF_Budget_Name_Id__c = opalbudget.id;
        oemcmpBudget.Core_MDF_Campaign_Id__c=MDFcamp.id;
        oemcmpBudget.Core_MDF_Budget_Amt__c=363636;
        oemcmpBudget.Core_MDF_Reimbursement_Rate_Pct__c='100%';
        oemcmpBudget.Core_MDF_Reimbursement_Amt__c= 200000;
        oemcmpBudget.Core_MDF_Active_ind__c=true;
        System.runAs(testUser){
            insert oemcmpBudget;
        }
        PartnerFundRequest MDFpfr = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(MDFcamp.Id),
                                                                                          Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,string.valueof(acc.id),null,null,'INDIA','Small Business','Desktop',
                                                                                          'Intel® Core™ i7 Processor','Broadcast','Radio','Draft',false);
        MDFpfr.Title = 'Test Activity';
        MDFpfr.Core_MDF_Activity_Description__c = 'Test Activity';
        MDFpfr.Core_MDF_Start_Date__c = system.today()-90;
        MDFpfr.Core_MDF_End_Date__c =  system.today()-30;
        MDFpfr.BudgetId = opalbudget.Id;
        MDFpfr.AllocationId = pfaRecordOpal.Id;
        MDFpfr.Core_MDF_Channel_Partner_Led__c = True;
        MDFpfr.Core_MDF_Budget_Type_nm__c = 'MDF';
        MDFpfr.Core_MDF_Intel_Activity_Owner_Id__c = UserInfo.getUserId();
        MDFpfr.Core_MDF_Approval_Step_Completed__c = 1;
        MDFpfr.Core_MDF_Price_reviewer_check_ind__c = False; 
        MDFpfr.Core_MDF_Program_Office_Check_ind__c = False;
        MDFpfr.Core_MDF_Require_Additional_Review_ind__c = True;
        MDFpfr.Core_MDF_Reimbursement_Rate_txt__c = '100%';
        MDFpfr.Core_MDF_Reimbursement_Rate_pct__c='100%';
        
        MDFpfr.Core_MDF_Fund_Request_Status__c = 'Planned';
        MDFpfr.Core_MDF_MDFReimbursement_Amt__c = 1000;
        MDFpfr.RequestedAmount = 1000;
        System.runAs(testUser){
            insert MDFpfr;
        }
        MDFpfr.Core_MDF_Fund_Request_Status__c='In-Progress';
        System.runAs(testUser){
            update MDFpfr;
        }
        system.runAs(testUser)
        {
            PermissionSet clmCaseRevPS = [SELECT Id, Name FROM PermissionSet WHERE Name='Core_MDF_CCP_Internal_Claim_Case_Reviewer' LIMIT 1];
            insert new PermissionSetAssignment(AssigneeId = testUser.id, PermissionSetId = clmCaseRevPS.Id);
            
        }
        
        Core_MDF_Bank__c bank1 = Core_MDF_CCP_TestDataUtility.createBank(ccpIntelAccount.Id, 'Core_MDF_Client_CoMarketing_Fund', false,'1241241240');
        //bank1.Core_MDF_Bank_Status__c='Active';
        bank1.Core_MDF_Bank_Location__c ='AM';
        bank1.Core_MDF_Effective_Date__c = System.today().addDays(-1);
        system.runAs(testUser){
            insert bank1;
        }
        bank1.Core_MDF_Bank_Status__c='Active';
        system.runAs(testUser){
            update bank1;
        }
        Core_MDF_Account_Bank_Mapping__c abm2 = Core_MDF_CCP_TestDataUtility.createAccountBankMap(ccfacc.Id,bank1.Id,false);
        system.runAs(testUser){
            insert abm2;
        }
        
        List<PartnerFundClaim> pfcList = new List<PartnerFundClaim>();
        PartnerFundClaim claim1 = Core_MDF_CCP_TestDataUtility.createClaim('PIC Review Claim', Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, MDFpfr.Id, MDFpfr.Core_MDF_Start_Date__c, MDFpfr.Core_MDF_Start_Date__c, 500.00, System.today(), null, false);
        claim1.Core_MDF_Invoice_Date__c = System.today().addDays(-1);
        claim1.Status = Label.Core_MDF_Status_Submitted;
        claim1.Core_MDF_Type_Txt__c ='Claim';
        claim1.Core_MDF_Currency__c='USD';
        claim1.Core_MDF_Country_Location_nm__c= 'India'; 
        claim1.Core_MDF_Quarter_Year_Txt__c = 'Q3-2020';
        claim1.Core_MDF_VAT_Eligibility_Ind__c = false;
        claim1.Core_MDF_To_Be_Audited_Ind__c=true;
        claim1.Core_MDF_Region_Cd__c='APJ';
        claim1.Core_MDF_Status__c ='PIC Pending';
        claim1.Core_MDF_PIC_Review_Completed__c = true;
        pfcList.add(claim1);
        
        PartnerFundClaim claim2 = Core_MDF_CCP_TestDataUtility.createClaim('PIC RMF Review Claim', Core_MDF_CCP_TestDataUtility.claim_RecordType_Retail, rmfPfr.Id, rmfPfr.Core_MDF_Start_Date__c, rmfPfr.Core_MDF_Start_Date__c, 500.00, System.today(), retailBank.id, false);
        claim2.Core_MDF_Invoice_Date__c = System.today().addDays(-1);
        claim2.Status = Label.Core_MDF_Status_Submitted;
        claim2.Core_MDF_Type_Txt__c ='Claim';
        claim2.Core_MDF_Currency__c='USD';
        claim2.Core_MDF_Country_Location_nm__c= 'India'; 
        claim2.Core_MDF_Quarter_Year_Txt__c = 'Q3-2020';
        claim2.Core_MDF_VAT_Eligibility_Ind__c = false;
        claim2.Core_MDF_To_Be_Audited_Ind__c=true;
        claim2.Core_MDF_Region_Cd__c='APJ';
        claim2.Core_MDF_Status__c ='PIC Pending';
        
        claim2.Core_MDF_PIC_Review_Completed__c = true;
        pfcList.add(claim2);
        
        system.runAs(testUser){
            Database.insert(pfcList);
        }
        claim2.Core_MDF_Status__c ='Paid';
        system.runAs(testUser){
            update claim2;
        }
        List<Case> caseListToBeInserted = new List<Case>();
        Case cs = new Case();
        Id caseAuditRecType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Core_MDF_Audit_Closed').getRecordTypeId();
        
        cs.Status = 'Under Review';
        cs.Core_MDF_Status__c='Under Review';
        cs.recordTypeId = caseAuditRecType;
        cs.AccountId = ccpIntelAccount.Id;
        cs.Core_MDF_Claim_ID__c = claim1.id;
        cs.Core_MDF_Claim_Lookup_Id__c = claim1.id;
        cs.Origin = 'Manual Selection';
        cs.Status = 'Closed';
        cs.Core_MDF_Channel_Program_txt__c = 'Client';
        cs.CreatedDate = system.today()-1;
        cs.ClosedDate = system.today()-1;
        system.runAs(testUser){
            insert cs;
        }
        
        cs.Core_MDF_Checklist_Completion__c=100;
        cs.Core_MDF_Scorecard_Score_Nbr__c=100;
        cs.Core_MDF_Status__c='Review Completed';
        
        system.runAs(testUser){
            update cs;
        }
        Case csRmf = new Case();
        csRmf.Status = 'Under Review';
        csRmf.Core_MDF_Status__c='Under Review';
        csRmf.recordTypeId = caseAuditRecType;
        csRmf.AccountId = ccpIntelAccount.Id;
        csRmf.Core_MDF_Claim_Lookup_Id__c = claim2.id;
        csRmf.Core_MDF_Claim_ID__c = claim2.id;
        csRmf.Origin = 'Manual Selection';
        csRmf.Status = 'Closed';
        csRmf.Core_MDF_Channel_Program_txt__c = 'Retail Marketing Funds';
        csRmf.CreatedDate = system.today()-1;
        csRmf.ClosedDate = system.today()-1;
        system.runAs(testUser){
            insert csRmf;
        }
        
        csRmf.Core_MDF_Checklist_Completion__c=100;
        csRmf.Core_MDF_Scorecard_Score_Nbr__c=100;
        csRmf.Core_MDF_Status__c='Review Completed';
        
        system.runAs(testUser){
            update csRmf;
        }
        Test.stopTest();
        
        
    }
    
    @isTest
    public static void testMethod1(){
        User usr = [select id,lastname from User where lastname='Admin_user' limit 1 ];
        System.runAs(usr){
            Core_MDF_Claim_Score_Notify_Batch claimScoreBatch = new Core_MDF_Claim_Score_Notify_Batch();
            id batchid = Database.executeBatch(claimScoreBatch);
            system.assert(batchid!=null,'Batch is Executed Sucessfully');
        }
    }
}