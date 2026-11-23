@isTest(seeAllData=false)
public class Core_MDF_GetObjectDetailsTest {
    //@isTest(seeAllData=true)
    @isTest
    static void getFieldsAndRecordsTest(){
         Profile sysAdminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator' LIMIT 1];
        
        // Creating User with utility class 
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.profileId = sysAdminProfile.Id;
        Database.insert(usr);
        
        PermissionSet eefBudLoader = [SELECT Id FROM PermissionSet WHERE Name = 'Core_MDF_Internal_EEF_Budget_Loader' LIMIT 1];
        insert new PermissionSetAssignment(AssigneeId = usr.id, PermissionSetId = eefBudLoader.Id);
        PermissionSet eefBudManager = [SELECT Id FROM PermissionSet WHERE Name = 'Core_MDF_Internal_EEF_Budget_Manager' LIMIT 1];
        insert new PermissionSetAssignment(AssigneeId = usr.id, PermissionSetId = eefBudManager.Id);
            
        List<String> bypassFunctionKeys = new List<String>();
        bypassFunctionKeys.add('Bypass_Duplicate_Budget_Check');
        bypassFunctionKeys.add('Bypass_GeoBased_Budget_Sharing');
        bypassFunctionKeys.add('Bypass_Allocation_Reservation');
        bypassFunctionKeys.add('Bypass_GeoBased_Allocation_Sharing');
        bypassFunctionKeys.add('Bypass_Duplicate_Bank_Check');
        bypassFunctionKeys.add('Bypass_Bank_Internal_Sharing');
        bypassFunctionKeys.add('Bypass_Bank_External_Sharing');
        bypassFunctionKeys.add('Bypass_Bank_ABM_Sharing');
        bypassFunctionKeys.add('Bypass_ABM_Internal_Sharing');
        bypassFunctionKeys.add('Bypass_ABM_External_Sharing');
        bypassFunctionKeys.add('Bypass_ABM_NodeGroup_Sharing');        
        bypassFunctionKeys.add('byPassShareUnshareCampaignRecord');
        bypassFunctionKeys.add('byPassCampaignAndRelatedRecords');
        bypassFunctionKeys.add('Bypass_PaymentRun_Duplicate_Check');
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
        bypassFunctionKeys.add('Bypass_Bank_Program_InActivation_Check');
        bypassFunctionKeys.add('Bypass_Claims_Amt_vs_Camp_Amt_Check');
        bypassFunctionKeys.add('Bypass_Claim_OwnerLang_EmailTemp');
        bypassFunctionKeys.add('Bypass_StampingOfActySubType_Check');
        bypassFunctionKeys.add('Bypass_Claims_Sharing_On_Owner_Change');
        bypassFunctionKeys.add('Bypass_UpdateActivityFields');
        bypassFunctionKeys.add('Bypass_ValidateActivityWithCampaign');
        bypassFunctionKeys.add('Bypass_MDF_Budget_Access');
        bypassFunctionKeys.add('Core_MDF_XMLToXLSGenerationFlag');
        bypassFunctionKeys.add('Core_MDF_StringToXLSGenerationFlag');
        bypassFunctionKeys.add('Bypass_MDF_Budget_Access_Validation');
        bypassFunctionKeys.add('Bypass_MDF_Budget_Status_Validation');  
        
        Set<String> myset1 = new Set<String>();
        List<String> result1 = new List<String>();
        myset1.addAll(bypassFunctionKeys);
        result1.addAll(myset1); 
         System.runAs(usr){
             List<Core_Trigger_Executions__c> bypassfunctinalitylist1 = Core_MDF_CCP_TestDataUtility.byPassFeature(result1,true,true);
              ChannelProgram eefCp = Core_MDF_CCP_TestDataUtility.createProgram('Ecosystem Extension Fund','Ecosystem Extension Fund', true);
            
            Id campaign_RecordType_EEF = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Core_MDF_Ecosystem_Extension_Fund').getRecordTypeId();
            Group eefGrp = new Group();
            eefGrp.Name = 'Core CCP EEF External';
            eefGrp.DeveloperName = 'Core_CCP_EEF_External';
            Database.insert(eefGrp);
             
             // Creating Account with utility class
            Account account1 = Core_MDF_CCP_TestDataUtility.createIntelAccount('Test Account 1', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, true);
            
            Account intelAccount = Core_MDF_CCP_TestDataUtility.createIntelAccount('Intel Account', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, true);
            List<Account> eefAccList = new List<Account>();
            
            Account eefPrimaryVirtualCorp = Core_MDF_CCP_TestDataUtility.createAccount ('EEF Primary Virtual Corp', eefCp.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);                           
            eefPrimaryVirtualCorp.Core_MDF_Parent_Fund_Account__c = intelAccount.Id;
            eefPrimaryVirtualCorp.Core_MDF_Partner_Type_nm__c ='Primary Partner';
            eefPrimaryVirtualCorp.Core_MDF_External_Group_Id__c = eefGrp.Id;
            eefAccList.add(eefPrimaryVirtualCorp);
            //insert eefPrimaryVirtualCorp;
            
            Account eefActivatingVirtualCorp = Core_MDF_CCP_TestDataUtility.createAccount ('EEF Activating Virtual Corp', eefCp.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);                           
            eefActivatingVirtualCorp.Core_MDF_Parent_Fund_Account__c = account1.Id;
            eefActivatingVirtualCorp.Core_MDF_Partner_Type_nm__c ='Activating Partner';
            eefAccList.add(eefActivatingVirtualCorp);
            Account eefActivatingVirtualCorp2 = Core_MDF_CCP_TestDataUtility.createAccount ('EEF Activating Virtual Corp ', eefCp.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);                           
            
            eefActivatingVirtualCorp2.Core_MDF_Parent_Fund_Account__c = intelAccount.Id;
            eefActivatingVirtualCorp2.Core_MDF_Partner_Type_nm__c ='Activating Partner';
            eefAccList.add(eefActivatingVirtualCorp2);
            
            insert eefAccList; 
            
            
            Group extGrp = new Group();
            extGrp.name = 'Core_MDF_EEF_EXT';
            extGrp.DoesIncludeBosses = false;
            insert extGrp;
            Group eeFWWgrp = new Group();
            eeFWWgrp.Name = 'Core CCP EEF WW INTERNAL';
            eeFWWgrp.DeveloperName = 'Core_CCP_EEF_WW_Internal';
            insert eeFWWgrp;
            //}
            //Test.startTest();
            List<PartnerMarketingBudget> pmbList = new List<PartnerMarketingBudget>(); 
            List<Core_MDF_Partner_Mapping__c> pmList = new List<Core_MDF_Partner_Mapping__c>();
            //System.runAs(usr){
            Core_MDF_Partner_Mapping__c priToActiPartnerMapping = new Core_MDF_Partner_Mapping__c();
            priToActiPartnerMapping.Core_MDF_Primary_Partner_Account_id__c = eefPrimaryVirtualCorp.Id;
            priToActiPartnerMapping.Core_MDF_Activating_Partner_Account_id__c = eefActivatingVirtualCorp.Id;
            priToActiPartnerMapping.Core_MDF_Effective_Start_Date__c = System.today()-10;
            priToActiPartnerMapping.Core_MDF_Effective_End_Date__c = System.today()+10;
            priToActiPartnerMapping.Core_MDF_Channel_Program__c = eefCp.Id;
            pmList.add(priToActiPartnerMapping);
            Core_MDF_Partner_Mapping__c priToActiPartnerMapping2 = new Core_MDF_Partner_Mapping__c();
            priToActiPartnerMapping2.Core_MDF_Primary_Partner_Account_id__c = eefPrimaryVirtualCorp.Id;
            priToActiPartnerMapping2.Core_MDF_Activating_Partner_Account_id__c = eefActivatingVirtualCorp2.Id;
            priToActiPartnerMapping2.Core_MDF_Effective_Start_Date__c = System.today()-10;
            priToActiPartnerMapping2.Core_MDF_Effective_End_Date__c = System.today()+10;
            priToActiPartnerMapping2.Core_MDF_Channel_Program__c = eefCp.Id;
            insert pmList;
          
            
            PartnerMarketingBudget pbmEef = Core_MDF_CCP_TestDataUtility.createBudget('Test Budget EEF', Core_MDF_CCP_TestDataUtility.Budget_Record_Type, eefPrimaryVirtualCorp.Id, eefCp.Id, 30000, System.today()-30, System.today()+30, false);
            pbmEef.Core_MDF_Budget_Status__c = 'Released';
            pmbList.add(pbmEef);
            
            Database.insert(pmbList);
             // Highlight: Unused Local Variable 
           // PartnerFundAllocation eefPFA = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('Test EEF PFA', pbmEef, eefActivatingVirtualCorp, 30000, true);
            
         /*   List<Core_MDF_Partner_Group_Mapping__c> pgmList = new List<Core_MDF_Partner_Group_Mapping__c>();
            
            // Creating Partner Group Mapping
            Core_MDF_Partner_Group_Mapping__c pgm = new Core_MDF_Partner_Group_Mapping__c();
            pgm.Core_MDF_Account__c = intelAccount.Id;
            pgm.Core_MDF_Group_Name__c = 'Core_CCP_EEF_External';
            pgm.Core_MDF_Type_of_Access__c = 'External';
            pgm.Core_MDF_Group_Id__c = intelAccount.Id;                
            pgm.Core_MDF_Channel_Program__c = eefCp.Id;
            pgmList.add(pgm);
            //Database.insert(pgm);
            Core_MDF_Partner_Group_Mapping__c pgm1 = new Core_MDF_Partner_Group_Mapping__c();
            pgm1.Core_MDF_Account__c = account1.Id;
            pgm1.Core_MDF_Group_Name__c = 'Core_MDF_EEF_EXT';
            pgm1.Core_MDF_Type_of_Access__c = 'External';
            pgm1.Core_MDF_Group_Id__c = extGrp.Id;                
            pgm1.Core_MDF_Channel_Program__c = eefCp.Id;
            pgmList.add(pgm1);
            //Database.insert(pgmList);
            
            Core_MDF_Partner_Group_Mapping__c wwPgm = new Core_MDF_Partner_Group_Mapping__c();
            wwPgm.Core_MDF_Account__c = intelAccount.Id;
            wwPgm.Core_MDF_Group_Name__c = 'Core_CCP_EEF_WW_Internal';
            wwPgm.Core_MDF_Type_of_Access__c = 'Internal';
            wwPgm.Core_MDF_Region_cd__c = 'WW';
            wwPgm.Core_MDF_Group_Id__c = eeFWWgrp.Id;                
            wwPgm.Core_MDF_Channel_Program__c = eefCp.Id;
            wwPgm.Core_MDF_Source_Txt__c = 'Test';
            wwPgm.Core_MDF_AccountIdGroupName__c = intelAccount.Id+'Core_CCP_DCF_WW_Internal';
            pgmList.add(wwPGM);
            Database.insert(pgmList); */
            
            
            Campaign eefCamp = new Campaign();
            eefCamp.RecordTypeId = campaign_RecordType_EEF;
            eefCamp.Core_MDF_Program__c = 'Ecosystem Extension Fund';
            eefCamp.Name = 'Campaign EEF Campaign';
            eefCamp.Description = 'Test';
            eefCamp.Core_MDF_Account__c = eefPrimaryVirtualCorp.Id;
            eefCamp.Core_MDF_Partner_Mapping_Txt__c = eefActivatingVirtualCorp.Id;
            eefCamp.StartDate = System.today();
            eefCamp.EndDate = System.today()+5;
            eefCamp.Core_MDF_External_Visibility_Date__c = System.today();
            eefCamp.Core_MDF_Opal_Budget_Type_Txt__c = 'Cloud';
            eefCamp.Core_MDF_Total_Campaign_Cost_Amt__c = 10000;
            eefCamp.Core_MDF_CSP_Intel_Based_Revenue_Amt__c = 1000;
            eefCamp.Core_MDF_Priority__c = 'Enterprise AI';
            eefCamp.Core_MDF_Market__c = 'AFGHANISTAN';
            eefCamp.Core_MDF_Audience__c = 'C-Suite';
            eefCamp.Core_MDF_Product_Type__c = 'Cloud Instance Consumption';
            eefCamp.Core_MDF_Brand__c = 'Intel® SGX';
            eefCamp.Core_MDF_Industry_Nm__c = 'Accommodation and Food Services';
            eefCamp.Core_MDF_Activity_Category__c = 'Broadcast';
            eefCamp.Core_MDF_Activity_Type__c = 'Radio';
            eefCamp.Core_MDF_Supports_legacy_program__c = 'MDF or both CMP & MDF';
            eefCamp.Core_MDF_CampOutcomeOpt_In_Ind__c = true;
            
            insert eefCamp;
            
            Core_MDF_Camp_to_ActPartner__c camptoActPtr = new Core_MDF_Camp_to_ActPartner__c();
            camptoActPtr.Core_MDF_Activating_Partner_Account_id__c = eefActivatingVirtualCorp.Id;
            camptoActPtr.Core_MDF_Channel_Program__c = eefCp.Id;
            camptoActPtr.Core_MDF_Campaign_Id__c = eefCamp.Id;
            camptoActPtr.Core_MDF_Reimbursement_Rate_pct__c = '100%';
            camptoActPtr.Core_MDF_Active_Ind__c = true;
            insert camptoActPtr;
            eefCamp.Core_MDF_Partner_Mapping_Txt__c = eefActivatingVirtualCorp2.id;
            update eefCamp;
            Test.startTest();
            String relatedobjectApiName = 'Core_MDF_Camp_to_ActPartner__c';
            String strFields = 'Core_MDF_Activating_Partner_Account_id__c';
            String criteriaField = 'Core_MDF_Campaign_Id__c'; 
            String criteriaFieldValue = eefCamp.Id; 
            String additionalCriteria = ' Core_MDF_Active_Ind__c=true';
            String sharingFlag = 'false';
			String strLabels = '';
			String restrictFieldVisiblityCriteriaFieldAPIName = 'Core_MDF_CampOutcomeOpt_In_Ind__c = true';
            String tableHeader = 'Payment_Details';
// FIX: Capture return value - getFieldsAndRecords returns objectDataWrapper, not void
Core_MDF_GetObjectDetails.objectDataWrapper result = Core_MDF_GetObjectDetails.getFieldsAndRecords(relatedobjectApiName, strFields, criteriaField, criteriaFieldValue, additionalCriteria, sharingFlag,strLabels);
assert.isNotNull(result, 'getFieldsAndRecords result should not be null');

// Test other methods
Boolean filterResult = Core_MDF_GetObjectDetails.getFilterCondition(eefCamp.Id, restrictFieldVisiblityCriteriaFieldAPIName);
String tableHeaderResult = Core_MDF_GetObjectDetails.getTableHeader(tableHeader);
Boolean visibilityResult = Core_MDF_GetObjectDetails.evaluateVisibilityCriteria(eefCamp.Id,'Core_MDF_CampOutcomeOpt_In_Ind__c == true');

// Assertions
assert.isNotNull(eefCamp);
assert.isNotNull(result.recordsData);
Test.stopTest();
        }
        
    }
     @isTest
    static void getTranslatedLabelsTest() {
        Test.startTest();
        List<String> emptyResult = Core_MDF_GetObjectDetails.getTranslatedLabels('');
        
        Assert.isNotNull(emptyResult, 'Result should not be null for blank input');
        Assert.areEqual(0, emptyResult.size(), 'Empty list expected for blank input');
        
        List<String> translatedResult = Core_MDF_GetObjectDetails.getTranslatedLabels('Payment Details,Claim Amount,Activity Type');
        
        Assert.isNotNull(translatedResult, 'Translated result should not be null');
        Assert.areEqual(3, translatedResult.size(), 'Should return 3 translated labels');
        
        List<String> singleResult = Core_MDF_GetObjectDetails.getTranslatedLabels('Payment_Details');
        
        Assert.isNotNull(singleResult, 'Single label result should not be null');
        Assert.areEqual(1, singleResult.size(), 'Should return 1 translated label');
        
        List<String> spacedResult = Core_MDF_GetObjectDetails.getTranslatedLabels(' Payment Details , Claim Amount ');
        
        Assert.isNotNull(spacedResult, 'Spaced label result should not be null');
        Assert.areEqual(2, spacedResult.size(), 'Should return 2 translated labels for spaced input');
        
        Test.stopTest();
    }

}