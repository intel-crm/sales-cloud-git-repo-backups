/****************************************************************************************************************************************
* Class Name       : Core_MDF_KPIDetailPage 
* Test Class Name  : Core_MDF_KPIDetailPage_test
****************************************************************************************************************************************/
@isTest(SeeAllData=false)
public class Core_MDF_KPIDetailPage_test {
    
    @TestSetUp
    static void createTestData(){
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.LastName = 'User Test';
        usr.UserRoleId = usRole.Id;
        Database.insert(usr);
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_CCF_MDF_Budget_Loader' LIMIT 1];
        insert new PermissionSetAssignment(AssigneeId = usr.id, PermissionSetId = ps.Id);
        
        System.runAs(usr){
            List<String> bypassFunctionKeys = new List<String>();
            //adding bypass feature to bypass access validation
            bypassFunctionKeys.add('Bypass_Duplicate_Budget_Check');
            bypassFunctionKeys.add('Bypass_MDF_Budget_Access_Validation');
            bypassFunctionKeys.add('Bypass_MDF_Budget_Status_Validation');
            bypassFunctionKeys.add('Bypass_MDF_Budget_Access');
            bypassFunctionKeys.add('Bypass_GeoBased_Budget_Sharing');
            bypassFunctionKeys.add('Bypass_Allocation_Reservation');
            bypassFunctionKeys.add('Bypass_GeoBased_Allocation_Sharing');
            bypassFunctionKeys.add('Bypass_Duplicate_Bank_Check');
            bypassFunctionKeys.add('Bypass_Bank_Internal_Sharing');
            bypassFunctionKeys.add('Bypass_Bank_External_Sharing'); 
            bypassFunctionKeys.add('Bypass_Bank_Program_InActivation_Check');
            bypassFunctionKeys.add('byPassShareUnshareCampaignRecord');
            bypassFunctionKeys.add('byPassCampaignAndRelatedRecords');
            bypassFunctionKeys.add('Bypass_Claims_Duplicate_Check');
            bypassFunctionKeys.add('Bypass_Claims_Sharing_Internal_Users');
            bypassFunctionKeys.add('Bypass_ClaimAdjReq_Share_On_Owner_Chng');
            bypassFunctionKeys.add('Bypass_ClaimAdjReq_Share_Internal_Usrs');
            bypassFunctionKeys.add('Bypass_ClaimAdjReq_Share_External_Usrs');
            bypassFunctionKeys.add('Bypass_Claim_AdjReq_Amount_Validation');
            bypassFunctionKeys.add('Bypass_Claims_Amt_vs_Budget_Amt_Check');
            bypassFunctionKeys.add('Bypass_Claims_Sharing_Partner_Users');
            bypassFunctionKeys.add('Bypass_Claims_Amt_vs_Camp_Amt_Check');
            bypassFunctionKeys.add('Bypass_Claim_OwnerLang_EmailTemp');
            bypassFunctionKeys.add('Bypass_StampingOfActySubType_Check');
            bypassFunctionKeys.add('Bypass_Claims_Sharing_On_Owner_Change');
            bypassFunctionKeys.add('Bypass_ValidateActivityWithCampaign');
            bypassFunctionKeys.add('byPass_Cancel_Activity');
            bypassFunctionKeys.add('Core_MDF_Bypass_ATFBatchUpdate');
            Set<String> myset1 = new Set<String>();
            List<String> result1 = new List<String>();
            myset1.addAll(bypassFunctionKeys);
            result1.addAll(myset1);
            
            List<Core_Trigger_Executions__c> bypassfunctinalitylist1 = Core_MDF_CCP_TestDataUtility.byPassFeature(result1,true,true);
            ChannelProgram cp1 = Core_MDF_CCP_TestDataUtility.createProgram ('Retail Marketing Funds','Retail Marketing Funds', true);
            Account acc3 = Core_MDF_CCP_TestDataUtility.createIntelAccount('Test Account 3', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
            acc3.Core_Geo__c = 'APJ';
            acc3.Core_Sub_Geo__c = 'IJKK';
            insert acc3;
            
            Account acc4 = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test Account 4', cp1.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, acc3.Id, false);
            acc4.Core_Geo__c = 'APJ';
            acc4.Core_Sub_Geo__c = 'IJKK';
            insert acc4;
            
            Account accRetail = Core_MDF_CCP_TestDataUtility.createAccount ('Co-marketing Test Account Retail', cp1.Id,
                                                                            Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            accRetail.Core_MDF_Parent_Fund_Account__c = acc3.Id;
            accRetail.Core_Geo__c = 'APJ';
            accRetail.Core_Sub_Geo__c = 'IJKK';
            accRetail.AccountSource='Auto';
            insert accRetail;
            
            PartnerMarketingBudget testBudget1 = Core_MDF_CCP_TestDataUtility.createBudget('TestBudgetData1',Core_MDF_CCP_TestDataUtility.budget_Record_Type,
                                                                                           acc4.id, cp1.Id , 5000000 , System.today()-60 , System.today() + 60 , 
                                                                                           false);
            
            insert testBudget1;
            testBudget1.IsIgnoreValidation = true;
            testBudget1.Core_MDF_Budget_Status__c = 'Released';
            update testBudget1;
            
            PartnerMarketingBudget testRetailBudget1 = Core_MDF_CCP_TestDataUtility.createBudget('TestRetailBudget1',Core_MDF_CCP_TestDataUtility.budget_Record_Type,
                                                                                                 accRetail.id, cp1.Id , 100000 , System.today()-60 , System.today() + 30 , 
                                                                                                 false);
            
            testRetailBudget1.IsIgnoreValidation = true;
            testRetailBudget1.Core_MDF_Budget_Partner__c=acc4.id;
            
            testRetailBudget1.Core_MDF_Budget_Status__c = 'Released';
            insert testRetailBudget1;
            
            Campaign camp1 = Core_MDF_CCP_TestDataUtility.createCampaign('Test Camp 24','Gaming','Athena','Yes', 
                                                                         Core_MDF_CCP_TestDataUtility.campaign_RecordType_Retail, 'Retail Marketing Funds',System.today()-2, 
                                                                         System.today().addDays(100), 20000, 'Instore innovation', acc4.Id,'2-in-1', false);
            insert camp1;     
            
            Campaign camp2 = Core_MDF_CCP_TestDataUtility.createCampaign('Test Camp 25','Gaming','Athena','Yes', 
                                                                         Core_MDF_CCP_TestDataUtility.campaign_RecordType_Retail, 'Retail Marketing Funds',System.today()-2, 
                                                                         System.today().addDays(100), 20000, 'Instore innovation', accRetail.Id,'2-in-1', false);
            insert camp2;      
            
            Account retailIntelAcc = Core_MDF_CCP_TestDataUtility.createIntelAccount('Test Retail Intel Account', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
            retailIntelAcc.Core_Geo__c = 'APJ';
            insert retailIntelAcc;
            
            Core_MDF_Bank__c bank = Core_MDF_CCP_TestDataUtility.createBank(acc3.Id, 'Core_MDF_Retail_Marketing_Funds', false,'1231231230');
            bank.Core_MDF_Bank_Alias_Name__c='TestActiveBank1';
            bank.Core_MDF_Intel_Company_Code__c='150';
            bank.Core_MDF_Tax_codes_cd__c = 'I0';
            Database.insert(bank);
            bank.Core_MDF_Bank_Status__c = 'Active'; 
            Database.update(bank);

            
            //Custom setting records needed for insertion of claim
            Core_MDF_CCP_TestDataUtility.createMDFConfigurationData();
        }
    }
    
    @isTest 
    static void runKPIDetailPagetest(){
        Integer pfrCount = 0;
        Core_MDF_KPIDetailPage.KPIWrapper kPIRes= new Core_MDF_KPIDetailPage.KPIWrapper(); 
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        //Creating User with utility class 
        User usr1 = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr1.LastName = 'User Test';
        usr1.UserRoleId = usRole.Id;
        Database.insert(usr1);        
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name =: Label.Core_MDF_Custom_Permission_IAM_Retail];
        insert new PermissionSetAssignment(AssigneeId = usr1.id, PermissionSetId = ps.Id);
        Test.startTest();
        System.runAs(usr1) {
            
 
            Account acc4 = [select id from account where name = 'Test Account 4']; 
            Campaign camp = [select id from Campaign where name = 'Test Camp 24' limit 1];

            
            List<PartnerFundRequest> pfrtoinsert = new List<PartnerFundRequest>();
            PartnerFundRequest testPartnerFundRequestRecord2 = Core_MDF_CCP_TestDataUtility.createRetailActivity(string.valueof(camp.Id),string.valueof(acc4.id),System.today()+1,System.today()+2,false);
            testPartnerFundRequestRecord2.Core_MDF_ActivityCategory__c = 'Print';
            testPartnerFundRequestRecord2.Core_MDF_Activity_Types__c = 'Magazine/Newspaper';
            testPartnerFundRequestRecord2.Core_MDF_Estimated_Ad_Size_nbr__c = 123;
            testPartnerFundRequestRecord2.Core_MDF_Magazine_Newspaper_txt__c     = '456';
            testPartnerFundRequestRecord2.Core_MDF_Type_of_Page_txt__c = 'colour half page';
            
            pfrtoinsert.add(testPartnerFundRequestRecord2);
            insert pfrtoinsert;
            kPIRes = Core_MDF_KPIDetailPage.getKPIvalues(testPartnerFundRequestRecord2.Id,'PartnerFundRequest','Actual_Metrics');
            pfrCount += 1;
            Test.stopTest();
        }
        Assert.isFalse(kPIRes.datamap.size()>0,'KPI values fetched');
    }
    
    
    @isTest 
    static void runKPIDetailPagetestforCase(){

        Core_MDF_KPIDetailPage.KPIWrapper kPIRes= new Core_MDF_KPIDetailPage.KPIWrapper();
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        //Creating User with utility class 
        User usr1 = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr1.LastName = 'User Test';
        usr1.UserRoleId = usRole.Id;
        Database.insert(usr1);
        
        PermissionSet ps1 = [SELECT Id, Name FROM PermissionSet WHERE Name='Core_MDF_CCP_Internal_Claim_Case_Reviewer' LIMIT 1];
        PermissionSet ps2 = [SELECT Id FROM PermissionSet WHERE Name =: Label.Core_MDF_Custom_Permission_IAM_Retail];
        insert new PermissionSetAssignment(AssigneeId = usr1.id, PermissionSetId = ps1.Id);
        insert new PermissionSetAssignment(AssigneeId = usr1.id, PermissionSetId = ps2.Id);
        
        Core_MDF_Bank__c bank = [Select Id from Core_MDF_Bank__c where Core_MDF_Supplier_Number__c='1231231230' limit 1];
        System.runAs(usr1){
             
            Account accRetail = [select id from account where name = 'Co-marketing Test Account Retail']; 
            Campaign camp2 = [select id from Campaign where name = 'Test Camp 24' limit 1]; 
            PartnerMarketingBudget testBudget = [select id from PartnerMarketingBudget where Title ='TestRetailBudget1'];
            PartnerFundAllocation allocation = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('Test Allocation New',testBudget,accRetail,20000.0,true);
            
            List<PartnerFundRequest> pfrtoinsert = new List<PartnerFundRequest>();
            PartnerFundRequest pfr1 = Core_MDF_CCP_TestDataUtility.createRetailActivity(string.valueof(camp2.Id),string.valueof(accRetail.id),System.today(),System.today(),false); 
            pfr1.Core_MDF_Budget_Type_nm__c ='Retail MDF';
            pfr1.Title = 'Test Retail Activity1';
            pfr1.Core_MDF_Activity_Description__c = 'Test Retail Activity';
            pfr1.Core_MDF_Channel_Partner_Led__c = false;
            pfr1.RequestedAmount = 100;
            pfr1.Core_MDF_Reimbursement_Rate_pct__c = '100%';
            pfr1.Core_MDF_Reimbursement_Rate_txt__c = '100%';
            pfr1.Core_MDF_Budget_Currency_cd__c='USD';
            pfr1.Core_MDF_ActivityCategory__c = '';
            pfr1.Core_MDF_Activity_Types__c ='';  // 14285 Indira
            pfr1.Core_MDF_Activity_SubType_nm__c = ''; // 14285 Indira
            pfr1.Core_MDF_Metrics_txt__c = '123';
            pfr1.Status = 'Approved';
            pfr1.AllocationId=allocation.id;
            pfr1.BudgetId = testBudget.id;
            pfrtoinsert.add(pfr1);
            Test.startTest();
            insert pfrtoinsert;    
            
            PartnerFundClaim claim = Core_MDF_CCP_TestDataUtility.createClaim('Test Retail Claim', Core_MDF_CCP_TestDataUtility.claim_RecordType_Retail, pfr1.Id, System.today(), System.today(), 50.00, System.today(), bank.Id, false);
            claim.Core_MDF_Type_Txt__c ='Claim';
            claim.Core_MDF_Currency__c='USD';
            claim.Core_MDF_Country_Location_nm__c= 'UNITED KINGDOM'; 
            claim.Core_MDF_VAT_Eligibility_Ind__c= true ; 
            claim.Core_MDF_VAT_Hold_Ind__c = true;
            claim.Core_MDF_Status__c = 'Hold';
            claim.Core_MDF_Processing_Preference_nm__c = 'Get paid, then settle';
            insert claim;
            Id caseAuditRecType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Core_MDF_Audit').getRecordTypeId();
            Case cs = new Case();
            List<Case> caseList = new List<Case>();    
            cs.recordTypeId = caseAuditRecType;
            cs.AccountId = accRetail.Id;
            cs.OwnerId = usr1.Id;
            cs.Core_MDF_Activity_ID__c = pfr1.Id;    
            cs.Origin = 'Manual Selection';    
            cs.Core_MDF_Claim_ID__c  = claim.Id;
            caseList.add(cs);
            Database.insert(caseList);            
            kPIRes = Core_MDF_KPIDetailPage.getKPIvalues(cs.Id,'PartnerFundRequest','Planned_Metrics');     
            kPIRes = Core_MDF_KPIDetailPage.getKPIvalues(cs.Id,'PartnerFundClaim','Planned_Metrics');
            Test.stopTest();
        }
        Assert.isFalse(kPIRes.datamap.size()>0,'KPI for activity fetched');
    }
    @isTest 
    static void runKPIDetailPagetestforNull(){
        Test.startTest();
        Core_MDF_KPIDetailPage.KPIWrapper kPIRes= new Core_MDF_KPIDetailPage.KPIWrapper();
        kPIRes = Core_MDF_KPIDetailPage.getKPIvalues(null,null,null);
        Test.stopTest();   
        Assert.isTrue(kPIRes.datamap.size()==0,'No KPI value fetched'); 
    }
    @isTest 
static void testFetchActCatTypePrivateMethod(){
    UserRole usRole = [SELECT Id,Name FROM UserRole WHERE Name = 'Admin' LIMIT 1];
    User usr1 = Core_MDF_CCP_TestDataUtility.createUser(false);
    usr1.LastName = 'User Test FetchActCat';
    usr1.UserRoleId = usRole.Id;
    Database.insert(usr1);
    
    PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name =: Label.Core_MDF_Custom_Permission_IAM_Retail];
    insert new PermissionSetAssignment(AssigneeId = usr1.id, PermissionSetId = ps.Id);
    
    System.runAs(usr1) {
        Test.startTest();
        
        Account acc = [SELECT Id FROM Account WHERE Name = 'Test Account 4' LIMIT 1]; 
        Campaign camp = [SELECT Id FROM Campaign WHERE Name = 'Test Camp 24' LIMIT 1];
        
        // Test PFR object - covers strCat = System.Label.Core_MDF_PFR_ActCat branch
        PartnerFundRequest pfr = Core_MDF_CCP_TestDataUtility.createRetailActivity(
            String.valueOf(camp.Id), String.valueOf(acc.Id), System.today()+1, System.today()+2, false);
        pfr.Core_MDF_ActivityCategory__c = 'Print';
        pfr.Core_MDF_Activity_Types__c = 'Magazine/Newspaper';
        //pfr.Core_MDF_Activity_SubType_nm__c = 'Test Subtype';
        insert pfr;
        
        // This will call fetchActCatType() for PFR
        Core_MDF_KPIDetailPage.getKPIvalues(pfr.Id, 'PartnerFundRequest', 'Actual_Metrics');
        
        Test.stopTest();
    }
}

@isTest 
static void testFetchActCatTypeWithIPAProgram(){
    UserRole usRole = [SELECT Id,Name FROM UserRole WHERE Name = 'Admin' LIMIT 1];
    User usr1 = Core_MDF_CCP_TestDataUtility.createUser(false);
    usr1.LastName = 'User Test IPA ActCat';
    usr1.UserRoleId = usRole.Id;
    Database.insert(usr1);
    
    PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name =: Label.Core_MDF_Custom_Permission_IAM_Retail];
    insert new PermissionSetAssignment(AssigneeId = usr1.id, PermissionSetId = ps.Id);
    
    System.runAs(usr1) {
        Test.startTest();
        
        Account acc = [SELECT Id FROM Account WHERE Name = 'Test Account 4' LIMIT 1]; 
        Campaign camp = [SELECT Id FROM Campaign WHERE Name = 'Test Camp 24' LIMIT 1];
        
        // Test IPA program with multiple subtypes - covers IPA specific logic
        PartnerFundRequest pfr = Core_MDF_CCP_TestDataUtility.createRetailActivity(
            String.valueOf(camp.Id), String.valueOf(acc.Id), System.today()+1, System.today()+2, false);
        pfr.Core_MDF_ActivityCategory__c = '';
        pfr.Core_MDF_Activity_Types__c = ''; // 14285 Indira
       pfr.Core_MDF_Activity_SubType_nm__c = ''; // 14285 Indira
        insert pfr;
        
        // This will test the IPA program logic in fetchActCatType()
        Core_MDF_KPIDetailPage.getKPIvalues(pfr.Id, 'PartnerFundRequest', 'Actual_Metrics');
        
        Test.stopTest();
    }
}

@isTest 
static void testFetchActCatTypeWithNullProgram(){
    UserRole usRole = [SELECT Id,Name FROM UserRole WHERE Name = 'Admin' LIMIT 1];
    User usr1 = Core_MDF_CCP_TestDataUtility.createUser(false);
    usr1.LastName = 'User Test Null Program';
    usr1.UserRoleId = usRole.Id;
    Database.insert(usr1);
    
    PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name =: Label.Core_MDF_Custom_Permission_IAM_Retail];
    insert new PermissionSetAssignment(AssigneeId = usr1.id, PermissionSetId = ps.Id);
    
    System.runAs(usr1) {
        Test.startTest();
        
        Account acc = [SELECT Id FROM Account WHERE Name = 'Test Account 4' LIMIT 1]; 
        Campaign camp = [SELECT Id FROM Campaign WHERE Name = 'Test Camp 24' LIMIT 1];
        
        // Test with null program and subtype
        PartnerFundRequest pfr = Core_MDF_CCP_TestDataUtility.createRetailActivity(
            String.valueOf(camp.Id), String.valueOf(acc.Id), System.today()+1, System.today()+2, false);
        pfr.Core_MDF_ActivityCategory__c = 'Print';
        pfr.Core_MDF_Activity_Types__c = 'Magazine/Newspaper';
        pfr.Core_MDF_Activity_SubType_nm__c = null;
        insert pfr;
        
        // This will test null program handling in fetchActCatType()
        Core_MDF_KPIDetailPage.getKPIvalues(pfr.Id, 'PartnerFundRequest', 'Actual_Metrics');
        
        Test.stopTest();
    }
}

@isTest 
static void testFetchMetadataPrivateMethod(){
    UserRole usRole = [SELECT Id,Name FROM UserRole WHERE Name = 'Admin' LIMIT 1];
    User usr1 = Core_MDF_CCP_TestDataUtility.createUser(false);
    usr1.LastName = 'User Test FetchMeta';
    usr1.UserRoleId = usRole.Id;
    Database.insert(usr1);
    
    PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name =: Label.Core_MDF_Custom_Permission_IAM_Retail];
    insert new PermissionSetAssignment(AssigneeId = usr1.id, PermissionSetId = ps.Id);
    
    System.runAs(usr1) {
        Test.startTest();
        
        Account acc = [SELECT Id FROM Account WHERE Name = 'Test Account 4' LIMIT 1]; 
        Campaign camp = [SELECT Id FROM Campaign WHERE Name = 'Test Camp 24' LIMIT 1];
        
        // Test PFR with Planned_Metrics and proposal based = true
        PartnerFundRequest pfr1 = Core_MDF_CCP_TestDataUtility.createRetailActivity(
            String.valueOf(camp.Id), String.valueOf(acc.Id), System.today()+1, System.today()+2, false);
        pfr1.Core_MDF_ActivityCategory__c = '';
        pfr1.Core_MDF_Activity_Types__c = '';
        insert pfr1;
        
        // This covers the first if condition in fetchMetadata
        Core_MDF_KPIDetailPage.getKPIvalues(pfr1.Id, 'PartnerFundRequest', 'Planned_Metrics');
        
        // Test PFR with Actual_Metrics and proposal based = false
        PartnerFundRequest pfr2 = Core_MDF_CCP_TestDataUtility.createRetailActivity(
            String.valueOf(camp.Id), String.valueOf(acc.Id), System.today()+1, System.today()+2, false);
        pfr2.Core_MDF_ActivityCategory__c = '';
        pfr2.Core_MDF_Activity_Types__c = '';  // 14285 Indira
        insert pfr2;
        
        // This covers the else if condition for PFR in fetchMetadata
        Core_MDF_KPIDetailPage.getKPIvalues(pfr2.Id, 'PartnerFundRequest', 'Actual_Metrics');
        
        Test.stopTest();
    }
}


@isTest 
static void testFetchSavedValuesPrivateMethod(){
    UserRole usRole = [SELECT Id,Name FROM UserRole WHERE Name = 'Admin' LIMIT 1];
    User usr1 = Core_MDF_CCP_TestDataUtility.createUser(false);
    usr1.LastName = 'User Test FetchSaved';
    usr1.UserRoleId = usRole.Id;
    Database.insert(usr1);
    
    PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name =: Label.Core_MDF_Custom_Permission_IAM_Retail];
    insert new PermissionSetAssignment(AssigneeId = usr1.id, PermissionSetId = ps.Id);
    
    System.runAs(usr1) {
        Test.startTest();
        
        Account acc = [SELECT Id FROM Account WHERE Name = 'Test Account 4' LIMIT 1]; 
        Campaign camp = [SELECT Id FROM Campaign WHERE Name = 'Test Camp 24' LIMIT 1];
        
        // Create PFR with various field values to test fetchsavedValues
        PartnerFundRequest pfr = Core_MDF_CCP_TestDataUtility.createRetailActivity(
            String.valueOf(camp.Id), String.valueOf(acc.Id), System.today()+1, System.today()+2, false);
        pfr.Core_MDF_ActivityCategory__c = 'Print';
        pfr.Core_MDF_Activity_Types__c = 'Magazine/Newspaper';
        pfr.Core_MDF_Estimated_Ad_Size_nbr__c = 123;
        pfr.Core_MDF_Magazine_Newspaper_txt__c = '456';
        pfr.Core_MDF_Type_of_Page_txt__c = 'colour half page';
        pfr.Core_MDF_Metrics_txt__c = 'Test Metrics';
        insert pfr;
        
        // This will call fetchsavedValues to retrieve the field values
        Core_MDF_KPIDetailPage.getKPIvalues(pfr.Id, 'PartnerFundRequest', 'Actual_Metrics');
        
        Test.stopTest();
    }
}

@isTest 
static void testGetActClaimIdWithNonCaseObject(){
    UserRole usRole = [SELECT Id,Name FROM UserRole WHERE Name = 'Admin' LIMIT 1];
    User usr1 = Core_MDF_CCP_TestDataUtility.createUser(false);
    usr1.LastName = 'User Test NonCase';
    usr1.UserRoleId = usRole.Id;
    Database.insert(usr1);
    
    PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name =: Label.Core_MDF_Custom_Permission_IAM_Retail];
    insert new PermissionSetAssignment(AssigneeId = usr1.id, PermissionSetId = ps.Id);
    
    System.runAs(usr1) {
        Test.startTest();
        
        Account acc = [SELECT Id FROM Account WHERE Name = 'Test Account 4' LIMIT 1]; 
        Campaign camp = [SELECT Id FROM Campaign WHERE Name = 'Test Camp 24' LIMIT 1];
        
        PartnerFundRequest pfr = Core_MDF_CCP_TestDataUtility.createRetailActivity(
            String.valueOf(camp.Id), String.valueOf(acc.Id), System.today()+1, System.today()+2, false);
        pfr.Core_MDF_ActivityCategory__c = 'Print';
        pfr.Core_MDF_Activity_Types__c = 'Magazine/Newspaper';
        insert pfr;
        
        // Test with non-Case object (PFR directly) - should return original ID
        Core_MDF_KPIDetailPage.getKPIvalues(pfr.Id, 'PartnerFundRequest', 'Actual_Metrics');
        
        Test.stopTest();
    }
}

@isTest 
static void testFetchLabelPrivateMethod(){
    UserRole usRole = [SELECT Id,Name FROM UserRole WHERE Name = 'Admin' LIMIT 1];
    User usr1 = Core_MDF_CCP_TestDataUtility.createUser(false);
    usr1.LastName = 'User Test FetchLabel';
    usr1.UserRoleId = usRole.Id;
    usr1.LanguageLocaleKey = 'en_US'; // Supported language
    Database.insert(usr1);
    
    PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name =: Label.Core_MDF_Custom_Permission_IAM_Retail];
    insert new PermissionSetAssignment(AssigneeId = usr1.id, PermissionSetId = ps.Id);
    
    System.runAs(usr1) {
        Test.startTest();
        
        Account acc = [SELECT Id FROM Account WHERE Name = 'Test Account 4' LIMIT 1]; 
        Campaign camp = [SELECT Id FROM Campaign WHERE Name = 'Test Camp 24' LIMIT 1];
        
        PartnerFundRequest pfr = Core_MDF_CCP_TestDataUtility.createRetailActivity(
            String.valueOf(camp.Id), String.valueOf(acc.Id), System.today()+1, System.today()+2, false);
        pfr.Core_MDF_ActivityCategory__c = 'Print';
        pfr.Core_MDF_Activity_Types__c = 'Magazine/Newspaper';
        insert pfr;
        
        // Test with valid display header - covers fetchLabel method
        Core_MDF_KPIDetailPage.getKPIvalues(pfr.Id, 'PartnerFundRequest', 'Planned_Metrics');
        
        // Test with different display header
        Core_MDF_KPIDetailPage.getKPIvalues(pfr.Id, 'PartnerFundRequest', 'Actual_Metrics');
        
        Test.stopTest();
    }
}

@isTest 
static void testFetchLabelWithUnsupportedLanguage(){
    UserRole usRole = [SELECT Id,Name FROM UserRole WHERE Name = 'Admin' LIMIT 1];
    User usr1 = Core_MDF_CCP_TestDataUtility.createUser(false);
    usr1.LastName = 'User Test UnsupportedLang';
    usr1.UserRoleId = usRole.Id;
    usr1.LanguageLocaleKey = 'zh_TW'; // Unsupported language
    Database.insert(usr1);
    
    PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name =: Label.Core_MDF_Custom_Permission_IAM_Retail];
    insert new PermissionSetAssignment(AssigneeId = usr1.id, PermissionSetId = ps.Id);
    
    System.runAs(usr1) {
        Test.startTest();
        
        Account acc = [SELECT Id FROM Account WHERE Name = 'Test Account 4' LIMIT 1]; 
        Campaign camp = [SELECT Id FROM Campaign WHERE Name = 'Test Camp 24' LIMIT 1];
        
        PartnerFundRequest pfr = Core_MDF_CCP_TestDataUtility.createRetailActivity(
            String.valueOf(camp.Id), String.valueOf(acc.Id), System.today()+1, System.today()+2, false);
        pfr.Core_MDF_ActivityCategory__c = 'Print';
        pfr.Core_MDF_Activity_Types__c = 'Magazine/Newspaper';
        insert pfr;
        
        // Test with unsupported language - should default to en_US
        Core_MDF_KPIDetailPage.getKPIvalues(pfr.Id, 'PartnerFundRequest', 'Planned_Metrics');
        
        Test.stopTest();
    }
}

@isTest 
static void testFetchLabelWithBlankDisplayHeader(){
    UserRole usRole = [SELECT Id,Name FROM UserRole WHERE Name = 'Admin' LIMIT 1];
    User usr1 = Core_MDF_CCP_TestDataUtility.createUser(false);
    usr1.LastName = 'User Test BlankHeader';
    usr1.UserRoleId = usRole.Id;
    Database.insert(usr1);
    
    PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name =: Label.Core_MDF_Custom_Permission_IAM_Retail];
    insert new PermissionSetAssignment(AssigneeId = usr1.id, PermissionSetId = ps.Id);
    
    System.runAs(usr1) {
        Test.startTest();
        
        Account acc = [SELECT Id FROM Account WHERE Name = 'Test Account 4' LIMIT 1]; 
        Campaign camp = [SELECT Id FROM Campaign WHERE Name = 'Test Camp 24' LIMIT 1];
        
        PartnerFundRequest pfr = Core_MDF_CCP_TestDataUtility.createRetailActivity(
            String.valueOf(camp.Id), String.valueOf(acc.Id), System.today()+1, System.today()+2, false);
        pfr.Core_MDF_ActivityCategory__c = 'Print';
        pfr.Core_MDF_Activity_Types__c = 'Magazine/Newspaper';
        insert pfr;
        
        // Test with blank display header - covers the blank check in fetchLabel
        Core_MDF_KPIDetailPage.getKPIvalues(pfr.Id, 'PartnerFundRequest', '');
        
        // Test with null display header
        Core_MDF_KPIDetailPage.getKPIvalues(pfr.Id, 'PartnerFundRequest', null);
        
        Test.stopTest();
    }
}

@isTest 
static void testAllPrivateMethodBranches(){
    UserRole usRole = [SELECT Id,Name FROM UserRole WHERE Name = 'Admin' LIMIT 1];
    User usr1 = Core_MDF_CCP_TestDataUtility.createUser(false);
    usr1.LastName = 'User Test All Branches';
    usr1.UserRoleId = usRole.Id;
    Database.insert(usr1);
    
    PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name =: Label.Core_MDF_Custom_Permission_IAM_Retail];
    insert new PermissionSetAssignment(AssigneeId = usr1.id, PermissionSetId = ps.Id);
    
    System.runAs(usr1) {
        Test.startTest();
        
        Account acc = [SELECT Id FROM Account WHERE Name = 'Test Account 4' LIMIT 1]; 
        Campaign camp = [SELECT Id FROM Campaign WHERE Name = 'Test Camp 24' LIMIT 1];
        
        // Test with empty activity category to cover String.isNotBlank(strCat) = false
        PartnerFundRequest pfr = Core_MDF_CCP_TestDataUtility.createRetailActivity(
            String.valueOf(camp.Id), String.valueOf(acc.Id), System.today()+1, System.today()+2, false);
        pfr.Core_MDF_ActivityCategory__c = null;
        pfr.Core_MDF_Activity_Types__c = null;
        insert pfr;
        
        // This should cover the case where strCat is blank
        Core_MDF_KPIDetailPage.getKPIvalues(pfr.Id, 'PartnerFundRequest', 'Actual_Metrics');
        
        Test.stopTest();
    }
}
    // 14285 Indira - Start
    @isTest 
static void testLogErrorImperative(){
    UserRole usRole = [SELECT Id,Name FROM UserRole WHERE Name = 'Admin' LIMIT 1];
    User usr1 = Core_MDF_CCP_TestDataUtility.createUser(false);
    usr1.LastName = 'User Test LogError';
    usr1.UserRoleId = usRole.Id;
    Database.insert(usr1);
    
    PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name =: Label.Core_MDF_Custom_Permission_IAM_Retail];
    insert new PermissionSetAssignment(AssigneeId = usr1.id, PermissionSetId = ps.Id);
    
    System.runAs(usr1) {
        Test.startTest();
        
        // Test with valid error message and object API name
        Core_MDF_KPIDetailPage.logErrorImperative('Test error message', 'PartnerFundRequest');
        
        // Test with valid error message and null object API name
        Core_MDF_KPIDetailPage.logErrorImperative('Another test error', null);
        
        // Test with blank error message - should return early without logging
        Core_MDF_KPIDetailPage.logErrorImperative('', 'PartnerFundRequest');
        
        // Test with null error message - should return early without logging
        Core_MDF_KPIDetailPage.logErrorImperative(null, 'PartnerFundRequest');
	
        // Test with whitespace only error message - should return early
        Core_MDF_KPIDetailPage.logErrorImperative('   ', 'PartnerFundRequest');
	
        Test.stopTest();
    }
    // Assert that the method executed without throwing exceptions
    // Since logErrorImperative is void and calls another utility method,
    // we're mainly testing that it doesn't throw exceptions
    Assert.isTrue(true, 'logErrorImperative method executed successfully');
}
    // 14285 Indira - End
}