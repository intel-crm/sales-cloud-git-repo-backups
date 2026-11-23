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
        PermissionSet extIPAActivityManager = nameToPerSet.get('Core_MDF_CCP_External_IPA_Activity_Manager');
        
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
            
            List<Campaign> campList = new List<Campaign>();
            Campaign IPAcamp = Core_MDF_CCP_TestDataUtility.createCampaign('Test Camp IPA','Gaming','Intel® Core™ i7+ Processor','Yes', Core_MDF_CCP_IPA_TestDataUtility.campaign_RecordType_IPA, 'Intel Partner Alliance', System.today()-15, System.today()+15, 10000, 'Consumer Chromebook', ipaCoMarketingAccount.Id, '2-in-1', false);
            IPAcamp.Core_MDF_Program__c='Intel Partner Alliance';
            IPAcamp.Core_MDF_Focus_Area_nm__c='Client Computing';
            IPAcamp.Core_MDF_Market__c='INDIA';
            IPAcamp.Core_MDF_Proposal_Based_Ind__c=true;
            IPAcamp.Core_MDF_Approval_Stage_nm__c='L1 Approval';
            campList.add(IPAcamp);
            
            Database.insert(campList);
            
            List<PartnerFundRequest> pfrList = new List<PartnerFundRequest>();
            
            
            PartnerFundRequest IPApfr = Core_MDF_CCP_IPA_TestDataUtility.createIPAPartnerFundRequest(string.valueof(IPAcamp.Id),string.valueof(ipaCoMarketingAccount.id),System.today().addDays(1),System.today().addDays(2),false);
            IPApfr.Core_MDF_Activity_Description__c = 'Test IPA Activity Tactic Controller';
            IPApfr.Title = 'Test IPA Activity Tactic Controller';
            IPApfr.Core_MDF_Focus_Area_nm__c='Client Computing';
            IPApfr.ChannelPartnerId = ipaCoMarketingAccount.id;
            pfrList.add(IPApfr);
            //Database.insert(IPApfr);
            
            PartnerFundRequest IPApfr2 = Core_MDF_CCP_IPA_TestDataUtility.createIPAPartnerFundRequest(string.valueof(IPAcamp.Id),string.valueof(ipaCoMarketingAccount.id),System.today().addDays(1),System.today().addDays(2),false);
            IPApfr2.Core_MDF_Activity_Description__c = 'Test IPA Activity2 Tactic Controller';
            IPApfr2.Title = 'Test IPA Activity2 Tactic Controller';
            IPApfr2.Core_MDF_Focus_Area_nm__c='Client Computing';
            IPApfr2.Core_MDF_Country_nm__c='CANADA';
            IPApfr.ChannelPartnerId = ipaCoMarketingAccount.id;
            pfrList.add(IPApfr2);
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
            Core_MDF_Program__c = 'Client'
        ));
        testMappings.add(new Core_MDF_CCP_Custom_Metadata_Utility__c(
            Core_MDF_Field_1_txt__c = 'Event',
            Core_MDF_Field_2_txt__c = 'Event - # of Seller Attendees',
            Core_MDF_Field_3_txt__c = 'Percentage',
            Core_MDF_Is_Active_Ind__c = true,
            Core_MDF_Category__c = 'Tactic Metrics',
            Core_MDF_Program__c = 'Client'
        ));
        testMappings.add(new Core_MDF_CCP_Custom_Metadata_Utility__c(
            Core_MDF_Field_1_txt__c = 'Digital Media',
            Core_MDF_Field_2_txt__c = 'Digital Media - # of Leads',
            Core_MDF_Field_3_txt__c = 'KPI',
            Core_MDF_Is_Active_Ind__c = true,
            Core_MDF_Category__c = 'Tactic Metrics',
            Core_MDF_Program__c = 'Client'
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

        PartnerFundRequest IPApfr=[select Id from PartnerFundRequest where title='Test IPA Activity Tactic Controller' LIMIT 1];

        // Create test data for Core_MDF_Activity_Attributes__c
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

        // Prepare input data for saveKpiData method
        List<Map<String, Object>> inputData = new List<Map<String, Object>>();
        inputData.add(new Map<String, Object>{
            'tactic' => 'Lead Cultivation',
            'percentageField' => new Map<String, Object>{
                'label' => 'Lead Cultivation Percentage Spend',
                'value' => 'Lead Cultivation Percentage Spend'
            },
            'percentageValue' => 100,
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

        // Call the saveKpiData method
        Core_MDF_Tactics_Controller.saveKpiData((Object)inputData, IPApfr.Id, false);

        List<Core_MDF_Activity_Attributes__c> updatedAttributes = [
            SELECT Core_MDF_Field_Value_nbr__c
            FROM Core_MDF_Activity_Attributes__c
            WHERE Core_MDF_Co_Marketing_Activity__c = :IPApfr.Id
        ];

        // Check the updated values
        Decimal sumOfKPIValues = 0;
        for (Core_MDF_Activity_Attributes__c attr : updatedAttributes) {
            sumOfKPIValues += attr.Core_MDF_Field_Value_nbr__c;
        }
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
}