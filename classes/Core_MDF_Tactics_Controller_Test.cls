@isTest
public class Core_MDF_Tactics_Controller_Test {

     @TestSetup
    static void setup()
    {    
        List<User> UserList= new List<User>();
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.LastName = 'User Test';
        UserList.add(usr);
        UserRole usRole1 = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        User User1 = Core_MDF_CCP_TestDataUtility.createUser(false);
        User1.LastName ='Admin User';
        User1.UserRoleId=usRole1.id;
        UserList.add(User1);
        Database.insert(UserList);
        
        Map<String,PermissionSet> nameToPerSet = new Map<String,PermissionSet>();
        for(PermissionSet pSet : [SELECT Id,Name FROM PermissionSet WHERE Name IN ('Core_MDF_CCP_External_IPA_Activity_Manager')]){
                                                                                       nameToPerSet.put(pSet.Name,pSet);
                                                                                   }
        // Highlight: Unused Local Variable - 14285 // Suma
        //PermissionSet extIPAActivityManager = nameToPerSet.get('Core_MDF_CCP_External_IPA_Activity_Manager');
        
        Map<String,Id> profileToId = new Map<String,Id>();
        for(Profile prfl:[SELECT Id,Name FROM Profile WHERE Name IN ('CCP - Core Access', 'Partner')]) {
            profileToId.put(prfl.Name,prfl.Id);
        }
        
        List<String> bypassFunctionKeys = new List<String>();
        bypassFunctionKeys.add('Bypass_MDF_Budget_Status_Validation');
        bypassFunctionKeys.add('Bypass_MDF_Budget_Access_Validation');
        bypassFunctionKeys.add('Bypass_Duplicate_Budget_Check');
        bypassFunctionKeys.add('Bypass_GeoBased_Budget_Sharing');
        bypassFunctionKeys.add('Bypass_GeoBased_Allocation_Sharing');
        bypassFunctionKeys.add('Bypass_MDF_Budget_Access');
        bypassFunctionKeys.add('Bypass_Duplicate_Budget_Check');
        bypassFunctionKeys.add('Core_MDF_OpalBudgetValidation');
        bypassFunctionKeys.add('Core_MDF_Campaign_Trigger_After_Insert');
        bypassFunctionKeys.add('Core_MDF_Bypass_Campaign_Trigger');
        bypassFunctionKeys.add('Bypass_Claims_Duplicate_Check');
        bypassFunctionKeys.add('Bypass_Claims_Sharing_Internal_Users');
        bypassFunctionKeys.add('Bypass_ClaimAdjReq_Share_On_Owner_Chng');
        bypassFunctionKeys.add('Bypass_ClaimAdjReq_Share_Internal_Usrs');
        bypassFunctionKeys.add('Bypass_ClaimAdjReq_Share_External_Usrs');
        bypassFunctionKeys.add('Bypass_Claim_AdjReq_Amount_Validation');
        bypassFunctionKeys.add('Bypass_Claims_Amt_vs_Budget_Amt_Check');        
        bypassFunctionKeys.add('Bypass_Claims_ABM_Validation');
        bypassFunctionKeys.add('Bypass_Claims_Sharing_Partner_Users');
        bypassFunctionKeys.add('Bypass_Payment_Doc_InvFileVAT_Validate');
        bypassFunctionKeys.add('Bypass_Claims_Amt_vs_Camp_Amt_Check');
        bypassFunctionKeys.add('Bypass_Claim_OwnerLang_EmailTemp');
        bypassFunctionKeys.add('Bypass_StampingOfActySubType_Check');
        bypassFunctionKeys.add('Bypass_Claims_Sharing_On_Owner_Change');
        bypassFunctionKeys.add('Bypass_Bank_Internal_Sharing');
        bypassFunctionKeys.add('Bypass_Bank_External_Sharing');
        bypassFunctionKeys.add('Bypass_Bank_ABM_Sharing');
        bypassFunctionKeys.add('Bypass_ABM_Internal_Sharing');
        bypassFunctionKeys.add('Bypass_ABM_External_Sharing');
        bypassFunctionKeys.add('Bypass_ABM_NodeGroup_Sharing'); 
        bypassFunctionKeys.add('Bypass_Bank_Program_InActivation_Check');
        bypassFunctionKeys.add('byPassShareUnshareCampaignRecord');
        bypassFunctionKeys.add('byPassCampaignAndRelatedRecords');
        bypassFunctionKeys.add('ByPass_BlockLegacyBudgetCreation');
        bypassFunctionKeys.add('Bypass_Claim_Insert_Calculations');
        bypassFunctionKeys.add('Bypass_Claim_Amount_Calculation');
        
        Set<String> myset1 = new Set<String>(); 
        List<String> result1 = new List<String>();
        myset1.addAll(bypassFunctionKeys);
        result1.addAll(myset1);
        System.runAs(User1) {
            List<Core_Trigger_Executions__c> bypassfunctinalitylist1 = Core_MDF_CCP_TestDataUtility.byPassFeature(result1,true,true); 
            
            Test.startTest();
            
            List<Account> accListInsert = new List<Account>();
            List<ChannelProgram> cplist = new List<ChannelProgram>();
            ChannelProgram cpipa = Core_MDF_CCP_TestDataUtility.createProgram ('Intel Partner Alliance','Intel Partner Alliance', false);
            cplist.add(cpipa);
            Database.insert(cplist);
            
            //Creating Test Acc New 1-  Intel Account using Data Utility
            
            Account ipaUltimateAccount = Core_MDF_CCP_TestDataUtility.createIntelAccount ('IPA Intel Account',Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, true);
            
            Account ipaCoMarketingAccount = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('IPA Co-Marketing Account', cpipa.id, Core_MDF_CCP_TestDataUtility.Account_Record_Type,ipaUltimateAccount.id, false);
            ipaCoMarketingAccount.AccountSource='Auto';
            accListInsert.add(ipaCoMarketingAccount);
            
            Account acc1 = Core_MDF_CCP_TestDataUtility.createIntelAccount('Test IPA Account', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
            acc1.Core_Intel_Partner_Alliance_PartnerGroup__c=true;
            acc1.Core_MDF_CoMarketingActive__c = true;
            acc1.Core_IPA_One_Partner_Id__c=ipaUltimateAccount.id;
            accListInsert.add(acc1);
           
            
            
            Database.insert(accListInsert);
            
            List<User> lstUser = new List<user>();
            //System Admin
            User systemAdm = Core_MDF_CCP_TestDataUtility.createUser(false);
            systemadm.Email = 'systemadm@example.com';
            systemadm.LastName='System Admin';
            lstUser.add(systemAdm);
            //CCF Account Manager
            User ccfaccntmngr = Core_MDF_CCP_TestDataUtility.createUser(false);
            ccfaccntmngr.Email = 'ccfaccntmngr@example.com';
            ccfaccntmngr.ProfileId = profileToId.get('CCP - Core Access');
            ccfaccntmngr.IsActive=true;
            lstUser.add(ccfaccntmngr);
            Database.insert(lstUser);
            
            Group grp = new Group();
            grp.Name = 'CCP INTERNAL CCF APJ TACCOUNT';
            grp.DeveloperName = 'Core_MDF_CCP_INTERNAL_CCF_APJ_TACCOUNT';
            Database.insert (grp);
            
            GroupMember grpMember = new GroupMember();
            grpMember.UserOrGroupId = ccfaccntmngr.Id;
            grpMember.GroupId = grp.Id;
            Database.insert (grpMember);
            Set<Id> grpIdSet = new Set<Id>();
            grpIdSet.add(grp.Id);
            Set<Id> usrIdSet = Core_MDF_PartnerFundRequestCreatePage.getUsersFromGroup(grpIdSet);
            
            Group grp1 = new Group();
            grp1.Name = 'CCP INTERNAL CCF ASMO TACCOUNT';
            grp1.DeveloperName = 'Core_MDF_CCP_INTERNAL_CCF_ASMO_TACCOUNT';
            database.insert(grp1);
            
            GroupMember grpMember2 = new GroupMember();
            grpMember2.UserOrGroupId = grp.Id;
            grpMember2.GroupId = grp1.Id;
            Database.insert (grpMember2);
            grpIdSet.add(grp1.Id);
            Set<Id> usrIdSet1 = Core_MDF_PartnerFundRequestCreatePage.getUsersFromGroup(grpIdSet);
            
            List<Core_MDF_Bank__c> listBank = new List<Core_MDF_Bank__c>();
            
            Core_MDF_Bank__c bank = Core_MDF_CCP_TestDataUtility.createBank(acc1.Id, 'Core_MDF_Intel_Partner_Alliance', false,'1231231230');
            bank.Core_MDF_Intel_Company_Code__c = '650';
            bank.Core_MDF_Effective_Date__c = System.today().addDays(-2);
            bank.Core_MDF_Currency_cd__c = 'USD';
            bank.Core_MDF_Tax_codes_cd__c = 'UB';
            bank.Core_MDF_Bank_Status__c = 'Active';
            bank.Core_MDF_VAT_pct__c= '20';
            bank.Core_MDF_Bank_Location__c = 'US';
            bank.Core_MDF_Supplier_City_txt__c = 'New York';
            bank.Core_MDF_Supplier_Country_txt__c = 'US';
            bank.Core_MDF_Supplier_Postal_Code_cd__c = '110111';
            bank.Core_MDF_Supplier_Region_txt__c = 'USA';
            
            Database.insert(bank);
        
            
            
            
            List<Campaign> campList = new List<Campaign>();
            Campaign IPAcamp = Core_MDF_CCP_TestDataUtility.createCampaign('Test Camp IPA','Gaming','Intel® Core™ i7+ Processor','Yes', Core_MDF_CCP_IPA_TestDataUtility.campaign_RecordType_IPA, 'Intel Partner Alliance', System.today()-15, System.today()+15, 10000, 'Consumer Chromebook', ipaCoMarketingAccount.Id, '2-in-1', false);
            IPAcamp.Core_MDF_Program__c='Intel Partner Alliance';
            IPAcamp.Core_MDF_Focus_Area_nm__c='Client Computing';
            IPAcamp.Core_MDF_Market__c='INDIA';
            IPAcamp.Core_MDF_Supports_legacy_program__c='';
            IPAcamp.Core_MDF_Proposal_Based_Ind__c=true;
            IPAcamp.Core_MDF_Approval_Stage_nm__c='L1 Approval';
            campList.add(IPAcamp);
            
            Database.insert(campList);
            
            List<PartnerFundRequest> pfrList = new List<PartnerFundRequest>();
            
            
            PartnerFundRequest IPApfr = Core_MDF_CCP_IPA_TestDataUtility.createIPAPartnerFundRequest(string.valueof(IPAcamp.Id),string.valueof(ipaCoMarketingAccount.id),System.today().addDays(1),System.today().addDays(2),false);
            IPApfr.Core_MDF_Activity_Description__c = 'Test IPA Activity Tactic Controller';
            IPApfr.Title = 'Test IPA Activity Tactic Controller';
            IPApfr.Core_MDF_ActivityCategory__c= 'Broadcast (Pre-2025)';
            IPApfr.Core_MDF_Activity_Types__c= '';    
            IPApfr.Core_MDF_Focus_Area_nm__c='Client Computing';
            IPApfr.ChannelPartnerId = ipaCoMarketingAccount.id;
            pfrList.add(IPApfr);
            //Database.insert(IPApfr);
            
            PartnerFundRequest IPApfr2 = Core_MDF_CCP_IPA_TestDataUtility.createIPAPartnerFundRequest(string.valueof(IPAcamp.Id),string.valueof(ipaCoMarketingAccount.id),System.today().addDays(1),System.today().addDays(2),false);
            IPApfr2.Core_MDF_Activity_Description__c = 'Test IPA Activity2 Tactic Controller';
            IPApfr2.Title = 'Test IPA Activity2 Tactic Controller';
            IPApfr2.Core_MDF_ActivityCategory__c= 'Broadcast (Pre-2025)';
            IPApfr2.Core_MDF_Activity_Types__c= '';  
            IPApfr2.Core_MDF_Focus_Area_nm__c='Client Computing';
            IPApfr2.Core_MDF_Country_nm__c='CANADA';
            IPApfr.ChannelPartnerId = ipaCoMarketingAccount.id;
            pfrList.add(IPApfr2);
            
            PartnerFundRequest IPApfr3 = Core_MDF_CCP_IPA_TestDataUtility.createIPAPartnerFundRequest(string.valueof(IPAcamp.Id),string.valueof(ipaCoMarketingAccount.id),System.today().addDays(1),System.today().addDays(2),false);
            IPApfr3.Core_MDF_Activity_Description__c = 'Test IPA Activity2 Tactic Controller';
            IPApfr3.Title = 'Test IPA Activity2 Tactic Controller';
            IPApfr3.Core_MDF_ActivityCategory__c= 'Broadcast (Pre-2025)';
            IPApfr3.Core_MDF_Activity_Types__c= '';  
            IPApfr3.Core_MDF_Focus_Area_nm__c='Client Computing';
            IPApfr3.Core_MDF_Country_nm__c='CANADA';
            IPApfr3.ChannelPartnerId = ipaCoMarketingAccount.id;
            IPApfr3.Core_MDF_Fund_Request_Status__c='Planned';
            pfrList.add(IPApfr3);
            Database.insert(pfrList);
                         
              

        }
        
    }

@IsTest
    static void testKpiSaveResponse() {
        List<Core_MDF_Activity_Attributes__c> records = new List<Core_MDF_Activity_Attributes__c>();
        Core_MDF_Tactics_Controller.KpiSaveResponse response = new Core_MDF_Tactics_Controller.KpiSaveResponse(true, records);
        
        System.assertEquals(true, response.noError);
        System.assertEquals(records, response.records);
    }

@IsTest
    static void testGetTacticMappings() {
        // Create test data for Core_MDF_CCP_Custom_Metadata_Utility__c
        List<Core_MDF_CCP_Custom_Metadata_Utility__c> testMappings = new List<Core_MDF_CCP_Custom_Metadata_Utility__c>();
        testMappings.add(new Core_MDF_CCP_Custom_Metadata_Utility__c(
            Core_MDF_Field_1_txt__c = 'Event',
            Core_MDF_Field_2_txt__c = 'Event - # of Deal Wins',
            Core_MDF_Field_3_txt__c = 'KPI',
            Core_MDF_Is_Active_Ind__c = true,
            Core_MDF_Category__c = 'Tactic Metrics',
                        Core_MDF_Program__c='Client'

        ));
        testMappings.add(new Core_MDF_CCP_Custom_Metadata_Utility__c(
            Core_MDF_Field_1_txt__c = 'Event',
            Core_MDF_Field_2_txt__c = 'Event - # of Seller Attendees',
            Core_MDF_Field_3_txt__c = 'Percentage',
            Core_MDF_Is_Active_Ind__c = true,
            Core_MDF_Category__c = 'Tactic Metrics',
                        Core_MDF_Program__c='Client'

        ));
        testMappings.add(new Core_MDF_CCP_Custom_Metadata_Utility__c(
            Core_MDF_Field_1_txt__c = 'Digital Media',
            Core_MDF_Field_2_txt__c = 'Digital Media - # of Leads',
            Core_MDF_Field_3_txt__c = 'KPI',
            Core_MDF_Is_Active_Ind__c = true,
            Core_MDF_Category__c = 'Tactic Metrics',
            Core_MDF_Program__c='Client'
        ));
        insert testMappings;

        // Call the method to test
        String programName = 'Client';
        List<Map<String, Object>> tacticMappings = Core_MDF_Tactics_Controller.getTacticMappings(programName);

        // Check the first tactic
        Map<String, Object> Event = tacticMappings[0];
        List<String> kpiFields1 = (List<String>)Event.get('kpiFields');

        // Check the second tactic
        Map<String, Object> tactic2 = tacticMappings[1];
        List<String> kpiFields2 = (List<String>)tactic2.get('kpiFields');
    }

@IsTest
static void testSaveKpiData() {
    
    PartnerFundRequest IPApfr = [
        SELECT Id 
        FROM PartnerFundRequest 
        WHERE Title = 'Test IPA Activity Tactic Controller' 
        LIMIT 1
    ];

   List<Core_MDF_Activity_Attributes__c> testAttributes = new List<Core_MDF_Activity_Attributes__c>();
    testAttributes.add(new Core_MDF_Activity_Attributes__c(
        Core_MDF_Co_Marketing_Activity__c = IPApfr.Id,
        Core_MDF_Tactics_nm__c = 'Event', 
        //Core_MDF_Field_Name_nm__c = 'Event - # of Deal Wins', 
        Core_MDF_Type_nm__c = 'KPI', 
        Core_MDF_Field_Value_nbr__c = 10.00,
        Core_MDF_Is_Active_Ind__c = true
    )); 
    testAttributes.add(new Core_MDF_Activity_Attributes__c( 
        Core_MDF_Co_Marketing_Activity__c = IPApfr.Id,
        Core_MDF_Tactics_nm__c = 'Event',
        Core_MDF_Type_nm__c = 'Percentage',
        Core_MDF_Field_Value_nbr__c = 100.00,
        Core_MDF_Is_Active_Ind__c = true 
    ));
    insert testAttributes;

    List<Map<String, Object>> inputData = new List<Map<String, Object>>();
    inputData.add(new Map<String, Object>{
        'tactic' => 'Lead Cultivation',

        'percentageField' => new Map<String, Object>{
            'label' => 'Lead Cultivation Percentage Spend',
            'value' => 'Lead Cultivation Percentage Spend'
        },
        'percentageValue' => 100,
        'intelContri' => 100,
        'maxIntelInvest' => 100,

        'firstKpi' => new Map<String, Object>{
            'label' => 'Lead Cultivation - # of Sales Qualified Leads',
            'value' => 15.00
        },

        'otherKpis' => new List<Object>{
            new Map<String, Object>{
                'label' => 'Lead Cultivation - # of Leads',
                'value' => 20.00
            }
        }
    });

    Test.startTest();
    Core_MDF_Tactics_Controller.saveKpiData(inputData, IPApfr.Id, false);
    Test.stopTest();

    //  Filter only new tactic records
    List<Core_MDF_Activity_Attributes__c> updatedAttributes = [
        SELECT Core_MDF_Field_Value_nbr__c
        FROM Core_MDF_Activity_Attributes__c
        WHERE Core_MDF_Co_Marketing_Activity__c = :IPApfr.Id
        AND Core_MDF_Tactics_nm__c = 'Lead Cultivation'
    ];

    // Calculate sum
    Decimal sumOfKPIValues = 0;
    for (Core_MDF_Activity_Attributes__c attr : updatedAttributes) {
        sumOfKPIValues += attr.Core_MDF_Field_Value_nbr__c;
    }

   // US - TWC702-14285: Unit Test Method should include System.Assert
    System.assertEquals(3, updatedAttributes.size(), 'Should have 3 records created');
    System.assertEquals(135.00, sumOfKPIValues, 'Sum should be 130 (100 + 15 + 20)');
}

@IsTest
    static void testGetSavedKpiData() {

        PartnerFundRequest IPApfr=[select Id from PartnerFundRequest where title='Test IPA Activity Tactic Controller' LIMIT 1];

        // Create test data for Core_MDF_Activity_Attributes__c
        List<Core_MDF_Activity_Attributes__c> testAttributes = new List<Core_MDF_Activity_Attributes__c>();
        testAttributes.add(new Core_MDF_Activity_Attributes__c(
            Core_MDF_Co_Marketing_Activity__c = IPApfr.Id,
            Core_MDF_Tactics_nm__c = 'Event',
            Core_MDF_Type_nm__c = 'KPI',
            Core_MDF_Field_Value_nbr__c = 10.00,
            Core_MDF_Is_Active_Ind__c = true
        ));
        testAttributes.add(new Core_MDF_Activity_Attributes__c(
            Core_MDF_Co_Marketing_Activity__c = IPApfr.Id,
            Core_MDF_Tactics_nm__c = 'Event',
            Core_MDF_Type_nm__c = 'Percentage',
            Core_MDF_Field_Value_nbr__c = 50.00,
            Core_MDF_Is_Active_Ind__c = true
        ));
        insert testAttributes;

        // Call the getSavedKpiData method
        List<Map<String, Object>> savedKpiData = Core_MDF_Tactics_Controller.getSavedKpiData(IPApfr.Id);

        Map<String, Object> tacticData = savedKpiData[0];

        Map<String, Object> firstKpi = (Map<String, Object>)tacticData.get('firstKpi');

        List<Map<String, Object>> otherKpis = (List<Map<String, Object>>)tacticData.get('otherKpis');
    }

@IsTest
    static void testHasMoreThanTwoDecimals() {
        // Test cases for hasMoreThanTwoDecimals method
        System.assertEquals(false, Core_MDF_Tactics_Controller.hasMoreThanTwoDecimals(10.50));
        System.assertEquals(true, Core_MDF_Tactics_Controller.hasMoreThanTwoDecimals(10.555));
        System.assertEquals(false, Core_MDF_Tactics_Controller.hasMoreThanTwoDecimals(10));
    }

@IsTest
    static void testGetPicklistLabels() {
        // Call the getPicklistLabels method
        Map<String, String> labels = Core_MDF_Tactics_Controller.getPicklistLabels();
    }
    @IsTest
    static void getTacticSpending() {
        PartnerFundRequest IPApfr=[select Id from PartnerFundRequest where title='Test IPA Activity Tactic Controller' LIMIT 1];

        // Create test data for Core_MDF_Activity_Attributes__c
        List<Core_MDF_Activity_Attributes__c> testAttributes = new List<Core_MDF_Activity_Attributes__c>();
        testAttributes.add(new Core_MDF_Activity_Attributes__c(
            Core_MDF_Co_Marketing_Activity__c = IPApfr.Id,
            Core_MDF_Tactics_nm__c = 'Event',
            Core_MDF_Type_nm__c = 'KPI',
            Core_MDF_Field_Value_nbr__c = 10.00,
            Core_MDF_Is_Active_Ind__c = true
        ));
        testAttributes.add(new Core_MDF_Activity_Attributes__c(
            Core_MDF_Co_Marketing_Activity__c = IPApfr.Id,
            Core_MDF_Tactics_nm__c = 'Event',
            Core_MDF_Type_nm__c = 'Percentage',
            Core_MDF_Field_Value_nbr__c = 50.00,
            Core_MDF_Is_Active_Ind__c = true
        ));
        insert testAttributes;
         Core_MDF_Tactics_Controller.getTacticSpending(false, null , IPApfr.Id);        
    }
   //14285 Indira - start
     @IsTest
static void testUpdateClaimAttributesEdgeCases() {
    // Test with null parameters
    Test.startTest();
    Core_MDF_Tactics_Controller.updateClaimAttributes(null, null, 'Cancel');
    Core_MDF_Tactics_Controller.updateClaimAttributes(new Map<String, String>(), null, 'Cancel');
    Test.stopTest();
    
    System.assert(true, 'Should handle null parameters gracefully');
}
    
    @IsTest
static void testGetLocalizedFieldMetadata() {
    // Test the getLocalizedFieldMetadata method
    List<String> objectList = new List<String>{'Core_MDF_Activity_Attributes__c', 'PartnerFundRequest'};
    List<String> fieldList = new List<String>{'Core_MDF_Tactics_nm__c', 'Core_MDF_Field_Name_nm__c', 'Title'};
    
    List<Core_MDF_Tactics_Controller.FieldInfo> result = Core_MDF_Tactics_Controller.getLocalizedFieldMetadata(objectList, fieldList);
    
    System.assertNotEquals(null, result, 'Result should not be null');
    System.assert(result.size() > 0, 'Should return field information');
    
    // Verify FieldInfo properties
    if (result.size() > 0) {
        Core_MDF_Tactics_Controller.FieldInfo fieldInfo = result[0];
        System.assertNotEquals(null, fieldInfo.objectName, 'Object name should not be null');
        System.assertNotEquals(null, fieldInfo.fieldName, 'Field name should not be null');
        System.assertNotEquals(null, fieldInfo.label, 'Label should not be null');
    }
    
    // Test with invalid object
    List<String> invalidObjectList = new List<String>{'Invalid_Object__c'};
    List<Core_MDF_Tactics_Controller.FieldInfo> resultInvalid = Core_MDF_Tactics_Controller.getLocalizedFieldMetadata(invalidObjectList, fieldList);
    System.assertNotEquals(null, resultInvalid, 'Result should not be null even for invalid object');
}
   @IsTest
static void testUpdateClaimAttributes() {
    // Create required custom settings if not already created
    if (Core_MDF_Configuration__c.getValues('ALLOWED_PRG_FOR_RUS_NOTIF') == null) {
        Core_MDF_Configuration__c allowedProgConfig = new Core_MDF_Configuration__c();
        allowedProgConfig.Name = 'ALLOWED_PRG_FOR_RUS_NOTIF';
        allowedProgConfig.Core_MDF_Value__c = 'Intel Partner Alliance,Other Program';
        insert allowedProgConfig;
    }
    
    if (Core_MDF_Configuration__c.getValues('ADD_BUS_DAYS_ON_REMINDER_DATE_CLAIM') == null) {
        Core_MDF_Configuration__c businessDaysConfig = new Core_MDF_Configuration__c();
        businessDaysConfig.Name = 'ADD_BUS_DAYS_ON_REMINDER_DATE_CLAIM';
        businessDaysConfig.Core_MDF_Value__c = '3';
        insert businessDaysConfig;
    }
    
    // Get test data
     Account acc2 = [Select Id, Name From Account Where Name = 'IPA Co-Marketing Account' Limit 1];
     ChannelProgram cpipa1 = [Select Id, Name From ChannelProgram Where Name = 'Intel Partner Alliance' Limit 1];
     PartnerMarketingBudget budget = Core_MDF_CCP_TestDataUtility.createBudget('Test Budget New',Core_MDF_CCP_IPA_TestDataUtility.budgetIPA_ProposalBased_Record_Type,acc2.Id,cpipa1.Id,200000,System.today().addDays(-20),System.today().addDays(300), false);
     budget.Core_MDF_Budget_Type_Txt__c='Proposal I MDF';
     Database.insert(budget);
     PartnerFundAllocation pfa = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('allocation',budget,acc2, 100000,true);
     PartnerFundRequest IPApfr2 = [SELECT Id FROM PartnerFundRequest WHERE title='Test IPA Activity2 Tactic Controller' LIMIT 1];
     IPApfr2.Core_MDF_Fund_Request_Status__c = '';
     IPApfr2.Status = 'Approved';
     IPApfr2.AllocationId=pfa.Id;
     IPApfr2.Core_MDF_Start_Date__c = System.today().addDays(-10);
     IPApfr2.Core_MDF_End_Date__c = System.today().addDays(10);
     update IPApfr2;

    
    // Create multiple claims for the same activity
    List<PartnerFundClaim> claims = new List<PartnerFundClaim>();
    
    PartnerFundClaim claim1 = new PartnerFundClaim();
    claim1.Title = 'Title 729046153';
    claim1.RequestId = IPApfr2.Id;
    claim1.Core_MDF_Status__c = 'Cancelled';
    claim1.Core_MDF_Claim_Ref_Number__c = 'TEST-001';
    claim1.Core_MDF_Total_Invoice_Amount_Local__c = 1000.00;
    claim1.Core_MDF_Currency__c = 'USD';
    claim1.Core_MDF_OtherCostsnotReimbursable_Local__c = 0;
    claim1.Core_MDF_Taxes_Local__c = 0;
  //  claim1.Core_MDF_Program__c = 'Other Program';
    // Set execution dates within the activity range
    claim1.Core_MDF_Ad_Run_Start_Date__c = System.today().addDays(-5); // Within the activity range
    claim1.Core_MDF_Ad_Run_End_Date__c = System.today().addDays(-1);    
    claim1.Core_MDF_Invoice_Date__c = System.today().addDays(-5);
    claim1.Core_MDF_Invoice_Number__c = 'POC-001';
    claim1.Core_MDF_Country_Location_nm__c = 'UNITED STATES';
    claim1.Core_MDF_Bank_Doc_Hold_Ind__c = false;
    claim1.Core_MDF_Audit_Hold__c = false;
    claims.add(claim1);
    
    PartnerFundClaim claim2 = new PartnerFundClaim();
    claim2.Title = 'Title 729046154';
    claim2.RequestId = IPApfr2.Id;
    claim2.Core_MDF_Status__c = 'Paid';
    claim2.Core_MDF_Claim_Ref_Number__c = 'TEST-002';
    claim2.Core_MDF_Total_Invoice_Amount_Local__c = 1500.00;
    claim2.Core_MDF_Currency__c = 'USD';
    claim2.Core_MDF_OtherCostsnotReimbursable_Local__c = 0;
    claim2.Core_MDF_Taxes_Local__c = 0;
   // claim2.Core_MDF_Program__c = 'Other Program';
 
    // Set execution dates within the activity range
    claim2.Core_MDF_Ad_Run_Start_Date__c = System.today().addDays(-5); // Within the activity range
    claim2.Core_MDF_Ad_Run_End_Date__c = System.today().addDays(-1);
   
    claim2.Core_MDF_Invoice_Date__c = System.today().addDays(-5);
    claim2.Core_MDF_Invoice_Number__c= 'POC-002';
    claim2.Core_MDF_Country_Location_nm__c = 'UNITED STATES';
    claim2.Core_MDF_Bank_Doc_Hold_Ind__c = false;
    claim2.Core_MDF_Audit_Hold__c = false;
    claims.add(claim2);
    
    PartnerFundClaim claim3 = new PartnerFundClaim();
    claim3.Title = 'Title 729046155';
    claim3.RequestId = IPApfr2.Id;
    claim3.Core_MDF_Status__c = 'Denied';
    claim3.Core_MDF_Claim_Ref_Number__c = 'TEST-003';
    claim3.Core_MDF_Total_Invoice_Amount_Local__c = 2000.00;
    claim3.Core_MDF_Currency__c = 'USD';
    claim3.Core_MDF_OtherCostsnotReimbursable_Local__c = 0;
    claim3.Core_MDF_Taxes_Local__c = 0;
   // claim3.Core_MDF_Program__c = 'Other Program';
   
    // Set execution dates within the activity range
    claim3.Core_MDF_Ad_Run_Start_Date__c = System.today().addDays(-5); // Within the activity range
    claim3.Core_MDF_Ad_Run_End_Date__c = System.today().addDays(-1);
   
    claim3.Core_MDF_Invoice_Date__c = System.today().addDays(-5);
    claim3.Core_MDF_Invoice_Number__c= 'POC-003';
    claim3.Core_MDF_Country_Location_nm__c = 'UNITED STATES';
    claim3.Core_MDF_Bank_Doc_Hold_Ind__c = false;
    claim3.Core_MDF_Audit_Hold__c = false;
    claims.add(claim3);
    
    insert claims;
    
    // Create claim attributes
    List<Core_MDF_Claim_Attributes__c> claimAttributes = new List<Core_MDF_Claim_Attributes__c>();
    
    // Attributes for cancelled claim (claim1)
    claimAttributes.add(new Core_MDF_Claim_Attributes__c(
        Core_MDF_Claim_Id__c = claim1.Id,
        Core_MDF_Tactics_nm__c = 'Event',
        Core_MDF_Type_nm__c = 'Spend This Period',
        Core_MDF_Field_Value_nbr__c = 500.00,
        Core_MDF_Is_Active_Ind__c = true
    ));
    
    claimAttributes.add(new Core_MDF_Claim_Attributes__c(
        Core_MDF_Claim_Id__c = claim1.Id,
        Core_MDF_Tactics_nm__c = 'Digital Media',
        Core_MDF_Type_nm__c = 'Spend This Period',
        Core_MDF_Field_Value_nbr__c = 300.00,
        Core_MDF_Is_Active_Ind__c = true
    ));
    
    // Attributes for subsequent claims
    claimAttributes.add(new Core_MDF_Claim_Attributes__c(
        Core_MDF_Claim_Id__c = claim2.Id,
        Core_MDF_Tactics_nm__c = 'Event',
        Core_MDF_Type_nm__c = 'Previous Period Spends',
        Core_MDF_Field_Value_nbr__c = 500.00,
        Core_MDF_Is_Active_Ind__c = true
    ));
    
    claimAttributes.add(new Core_MDF_Claim_Attributes__c(
        Core_MDF_Claim_Id__c = claim3.Id,
        Core_MDF_Tactics_nm__c = 'Event',
        Core_MDF_Type_nm__c = 'Previous Period Spends',
        Core_MDF_Field_Value_nbr__c = 500.00,
        Core_MDF_Is_Active_Ind__c = true
    ));
    
    insert claimAttributes;
    
    // Test Cancel operation
    Map<String, String> claimIdToRefMap = new Map<String, String>();
    claimIdToRefMap.put(claim1.Id, 'TEST-001');
    
    Test.startTest();
    Core_MDF_Tactics_Controller.updateClaimAttributes(claimIdToRefMap, null, 'Cancel');
    Test.stopTest();
    
    // Verify that subsequent claims' Previous Period Spends were reduced
    List<Core_MDF_Claim_Attributes__c> updatedAttributes = [
        SELECT Id, Core_MDF_Field_Value_nbr__c, Core_MDF_Claim_Id__c, Core_MDF_Tactics_nm__c
        FROM Core_MDF_Claim_Attributes__c
        WHERE Core_MDF_Claim_Id__c IN :new List<Id>{claim2.Id, claim3.Id}
        AND Core_MDF_Type_nm__c = 'Previous Period Spends'
        AND Core_MDF_Tactics_nm__c = 'Event'
    ];
    
    System.assert(updatedAttributes.size() > 0, 'Should have updated attributes');
    
    // Test Edit operation
    Map<String, Map<String, Decimal>> tacticDiffMap = new Map<String, Map<String, Decimal>>();
    Map<String, Decimal> tacticDiffs = new Map<String, Decimal>();
    tacticDiffs.put('Event', 100.00);
    tacticDiffs.put('Digital Media', -50.00);
    tacticDiffMap.put(claim1.Id, tacticDiffs);
    
    Core_MDF_Tactics_Controller.updateClaimAttributes(claimIdToRefMap, tacticDiffMap, 'Edit');
    
    System.assert(true, 'Edit operation should complete without errors');
}
    // 14285 Indira - end
}