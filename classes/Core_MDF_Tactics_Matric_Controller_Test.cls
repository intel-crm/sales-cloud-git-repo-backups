@isTest
public class Core_MDF_Tactics_Matric_Controller_Test {

    public static Id payRun_RecordType_IPAMDF = Schema.SObjectType.Core_MDF_Payment_Run__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_Intel_Partner_Alliance_MDF').getRecordTypeId();
    
    // test method for data setup
    @TestSetup static void setUpData(){
        List<Account> acctList = new List<Account>();
        List<User> userList = new List<User>();
        
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
        //bypassFunctionKeys.add('Bypass_Activity_ApprovalProcess');
        bypassFunctionKeys.add('Bypass_ShareActivityWithUsers');
        bypassFunctionKeys.add('Bypass_ShareActivityWithAccNodeGroup');
        bypassFunctionKeys.add('Bypass_geoLeadApprovalProcess');
        bypassFunctionKeys.add('Bypass_MDF_Budget_Access_Validation');
        bypassFunctionKeys.add('Bypass_MDF_Budget_Status_Validation');
        
        Set<String> myset1 = new Set<String>();
        List<String> result1 = new List<String>();
        myset1.addAll(bypassFunctionKeys);
        result1.addAll(myset1);
        
        List<Core_Trigger_Executions__c> bypassfunctinalitylist1 = Core_MDF_CCP_TestDataUtility.byPassFeature(result1,true,true);
        
        ChannelProgram cp = Core_MDF_CCP_TestDataUtility.createProgram ('Intel Partner Alliance','Intel Partner Alliance', true);
        Id campaign_RecordType_IPA = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Core_MDF_Intel_Partner_Alliance').getRecordTypeId();
        
        // Creating a map of profile name and profile Id
        Map<String,Id> profileToId = new Map<String,Id>();
        for(Profile prfl:[SELECT Id,Name FROM Profile WHERE Name IN ('System Administrator','CCP - Core Access')]) {
            profileToId.put(prfl.Name,prfl.Id);
        }
        // Creating a map of PS names and PS
        Map<String,PermissionSet> nameToPerSet = new Map<String,PermissionSet>();
        for(PermissionSet pSet:[SELECT Id,Name FROM PermissionSet WHERE Name IN (
            'Core_MDF_CCP_Internal_APJ_User',
            'Core_MDF_CCP_Internal_Payment_Schedule_Admin',
            'Core_MDF_CCP_Internal_IPA_Payment_Adm',
            'View_All_Data'
        )]) {
            nameToPerSet.put(pSet.Name,pSet);
        }
        
        PermissionSet paymentAdmGeoPS = nameToPerSet.get('Core_MDF_CCP_Internal_APJ_User'); 
        PermissionSet paymentAdmSchedulePS = nameToPerSet.get('Core_MDF_CCP_Internal_Payment_Schedule_Admin'); 
        PermissionSet ipaPaymentAdmPS = nameToPerSet.get('Core_MDF_CCP_Internal_IPA_Payment_Adm');
        PermissionSet viewAllDataPS = nameToPerSet.get('View_All_Data');
        
        User usr2 = Core_MDF_CCP_TestDataUtility.createUser(false); 
        usr2.Email='testPayment@example.com';
        usr2.LastName='PayAdmUser';
        usr2.profileId = profileToId.get('CCP - Core Access');
        usr2.IsActive = true;
        userList.add(usr2); 
        
        // Creating User with utility class 
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.Email = 'sysadmin@example.com';
        userList.add(usr);
        database.insert(userList);
        List<PermissionSetAssignment> permSetAssgnLst = new List<PermissionSetAssignment>();
        
        // Assigning IPA Payment Admin PS
        PermissionSetAssignment assignPermissionSetObj2 = new PermissionSetAssignment();
        assignPermissionSetObj2.AssigneeId = usr2.Id;
        assignPermissionSetObj2.PermissionSetId = ipaPaymentAdmPS.Id;
        permSetAssgnLst.add(assignPermissionSetObj2);
        
        // Assigning CCP Internal APJ User PS
        PermissionSetAssignment assignGeoPermissionSet = new PermissionSetAssignment();
        assignGeoPermissionSet.AssigneeId = usr2.Id;
        assignGeoPermissionSet.PermissionSetId = paymentAdmGeoPS.Id;
        permSetAssgnLst.add(assignGeoPermissionSet);
        
        // Assigning Payment Admin Schedule PS
        PermissionSetAssignment assignSchedulePermissionSet = new PermissionSetAssignment();
        assignSchedulePermissionSet.AssigneeId = usr2.Id;
        assignSchedulePermissionSet.PermissionSetId = paymentAdmSchedulePS.Id;
        permSetAssgnLst.add(assignSchedulePermissionSet);
        
        // Assigning View All Data PS
        PermissionSetAssignment assignViewAllPermissionSet = new PermissionSetAssignment();
        assignViewAllPermissionSet.AssigneeId = usr2.Id;
        assignViewAllPermissionSet.PermissionSetId = viewAllDataPS.Id;
        permSetAssgnLst.add(assignViewAllPermissionSet);
        system.runAs(usr){
            Database.insert(permSetAssgnLst);
            
        }
        
        Id acctRecord_Type = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Core_Partner_Account_Group').getRecordTypeId();
        Account acc = Core_MDF_CCP_TestDataUtility.createIntelAccount('Test IPA Accounttest', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);//changed 2nd parameter
        acc.Core_MDF_CoMarketingActive__c = true;//changed to true
        //Test.startTest();
        insert acc;
        //acctList.add(acc);
        // Creating Account with utility class
        Account acc1 = Core_MDF_CCP_TestDataUtility.createIntelAccount('Test IPA Account', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
        acc1.Core_Intel_Partner_Alliance_PartnerGroup__c=true;
        acc1.Core_MDF_CoMarketingActive__c = true;
        acc1.Core_IPA_One_Partner_Id__c=acc.id;
        acctList.add(acc1);
        insert(acctList);
        // Updating Accounts 
        acc1.isPartner = true;
        Database.update(acc1);
        Account acc2 = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test Account 2', cp.Id, Core_MDF_CCP_TestDataUtility.account_Record_Type, acc1.Id, false);//changed record type from Intel to Acc
        acc2.Core_Geo__c='';
        acc2.Core_Sub_Geo__c='';
        
        acc2.BillingCity = 'Test City';         
        acc2.BillingCountry= 'AUS';
        acc2.BillingStreet= 'Test Street';
        insert acc2;
        //NA
        //Account ccfAccforAcc = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test Account 2', cp.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, acctList[0].Id, false);
        //ccfAccforAcc.Core_Geo__c='';
        //ccfAccforAcc.Core_Sub_Geo__c='';
        //insert ccfAccforAcc;
        
        
        //NA
        List<Group> grpList = new List<Group>();
        Group ipaExtGrp = new Group();
        ipaExtGrp.Name = 'Core CCP IPA External';
        ipaExtGrp.DeveloperName = 'Core_MDF_CCP_IPA_External';
        grpList.add(ipaExtGrp);
        
        Group ipaExtGrp2 = new Group();
        ipaExtGrp2.Name = 'Core CCP IPA External2';
        ipaExtGrp2.DeveloperName = 'Core_MDF_CCP_IPA_External2';
        grpList.add(ipaExtGrp2);
        System.runAs(usr){
            Database.insert(grpList);  
            
            
            // Creating Group Member
            List<GroupMember> grpMemList = new List<GroupMember>();
            GroupMember ipaExtGrpMem1 = new GroupMember();
            ipaExtGrpMem1.UserOrGroupId = usr2.Id;
            ipaExtGrpMem1.GroupId = ipaExtGrp.Id;
            grpMemList.add(ipaExtGrpMem1);
            
            GroupMember ipaExtGrpMem2 = new GroupMember();
            ipaExtGrpMem2.UserOrGroupId =usr.Id;
            ipaExtGrpMem2.GroupId = ipaExtGrp.Id;
            grpMemList.add(ipaExtGrpMem2);
            
            Database.insert(grpMemList);
        }
        List<Core_MDF_Partner_Group_Mapping__c> pgmList = new List<Core_MDF_Partner_Group_Mapping__c>();
        // Creating Partner Group Mapping
        Core_MDF_Partner_Group_Mapping__c pgmExt = new Core_MDF_Partner_Group_Mapping__c();
        pgmExt.Core_MDF_Account__c = acc1.Id;
        pgmExt.Core_MDF_Group_Name__c = 'Core_MDF_CCP_IPA_External';
        pgmExt.Core_MDF_Type_of_Access__c = 'EXTERNAL';
        pgmExt.Core_MDF_Group_Id__c = ipaExtGrp.Id;                
        pgmExt.Core_MDF_Channel_Program__c = cp.Id;
        pgmExt.Core_MDF_Source_Txt__c = 'Test';
        pgmExt.Core_MDF_Region_cd__C = 'APJ';
        pgmExt.Core_MDF_AccountIdGroupName__c = acc1.Id+'Core_MDF_CCP_IPA_External';
        pgmList.add(pgmExt);
        
       
        Database.insert(pgmList);
        ///////////////////////////
        
        string budgetType = Core_MDF_CCP_IPA_TestDataUtility.createBenefit(acc2);
        //budgetType = 'Proposal I MDF';
        PartnerMarketingBudget budget = Core_MDF_CCP_TestDataUtility.createBudget('Test Budget New',Core_MDF_CCP_IPA_TestDataUtility.budgetIPA_ProposalBased_Record_Type,acc2.Id,cp.Id,200000,System.today().addDays(-20),System.today(), false);
        budget.Core_MDF_Budget_Type_Txt__c= budgetType;
        Database.insert(budget);
        
        PartnerFundAllocation pfa = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('allocation',budget,acc2, 100000,true);
        
        Core_MDF_Account_Node_Attributes__c accNodeAttr = new Core_MDF_Account_Node_Attributes__c();
        accNodeAttr.Core_MDF_Account_id__c = acc2.Id;
        accNodeAttr.Core_MDF_Program_id__c = cp.Id;
        accNodeAttr.Core_MDF_CSAR_GL_Account_nbr__c = 402110;
        accNodeAttr.Core_MDF_NonPO_GL_Account_nbr__c = 506710;
        accNodeAttr.Core_MDF_Customer_NonPO_GL_Account_nbr__c = 244200;
        insert accNodeAttr;

        Campaign camp = Core_MDF_CCP_IPA_TestDataUtility.createIPACampaign('Test IPA Camp',acc2.Id, System.today().addDays(-30), System.today().addDays(300),budgetType, 1234.00, 'AFGHANISTAN','Consumer','Coffee Lake','Pending Review', false);
        camp.Core_MDF_Region_cd__c = 'APJ';
        camp.Core_MDF_Budget_Type_txt__c = budgetType;
        camp.Core_MDF_Budget__c = budget.Id;
        camp.Core_MDF_Reimbursement_Amt__c = 10000;
        Database.insert(camp);
        
        Test.startTest();
        PartnerFundRequest pfr = Core_MDF_CCP_IPA_TestDataUtility.createIPAPartnerFundRequest(camp.Id,acc2.Id,System.today().addDays(-25),System.today().addDays(25),false);
        pfr.Core_MDF_BU_Split__c ='CCG';
        pfr.Core_MDF_BU1_Split_Percent_nbr__c=100;
        pfr.amount = 500;
        pfr.Core_MDF_Reimbursement_Rate_txt__c='60%';
        pfr.Core_MDF_Budget_Type_nm__c = budgetType;
        Database.insert(pfr);
        List<Campaign> campToBeUpdated = new List<Campaign>();
        List<PartnerFundRequest> pfrToBeUpdated = new List<PartnerFundRequest>(); 
        camp.Status = 'Proposal Accepted';
        campToBeUpdated.add(camp);
        Database.update(campToBeUpdated);
        
        pfr.Core_MDF_Fund_Request_Status__c = 'Planned';
        pfr.Core_MDF_Reimbursement_Rate_pct__c ='100%';
        pfrToBeUpdated.add(pfr);
        
        Database.update(pfrToBeUpdated);
        Core_MDF_CCP_TestDataUtility.insertCurrencyExchangeRates();  
       // Create test data for Core_MDF_Activity_Attributes__c
        Core_MDF_Activity_Attributes__c activityAttribute = new Core_MDF_Activity_Attributes__c(
            Core_MDF_Co_Marketing_Activity__c = pfr.Id,
            Core_MDF_Field_Name_nm__c = 'Digital Media - # of Impressions',
            Core_MDF_Field_Value_nbr__c = 200,
            Core_MDF_Type_nm__c = 'KPI',
            Core_MDF_Tactics_nm__c = 'Digital Media',
            Core_MDF_Is_Active_Ind__c = true
        );
        insert activityAttribute;
        
        
        Test.stopTest();
        
        List<Core_MDF_Bank__c> listBank = new List<Core_MDF_Bank__c>();
        
        Core_MDF_Bank__c bank = Core_MDF_CCP_TestDataUtility.createBank(acc1.Id, 'Core_MDF_Intel_Partner_Alliance', false,'1231231230');
        bank.Core_MDF_Intel_Company_Code__c = '650';
        bank.Core_MDF_Currency_cd__c = 'USD';
        bank.Core_MDF_Tax_codes_cd__c = 'UB';
        bank.Core_MDF_Bank_Status__c = 'Active';
        bank.Core_MDF_VAT_pct__c= '20';
        bank.Core_MDF_Bank_Location__c = 'US';
        bank.Core_MDF_Supplier_City_txt__c = 'New York';
        bank.Core_MDF_Supplier_Country_txt__c = 'US';
        bank.Core_MDF_Supplier_Postal_Code_cd__c = '110111';
        bank.Core_MDF_Supplier_Region_txt__c = 'USA';
        
        bank.Core_MDF_Payment_Currency_Cd__c = 'USD';
        bank.Name = 'Test IPA Bankk';
        bank.Core_MDF_Effective_Date__c=System.today().addDays(-3);
        System.runAs(usr2){
            Database.insert(bank);  
        }
       
        //Do Account Bank Mapping for 'bank' and ABM 
        Core_MDF_Account_Bank_Mapping__c abm1 = Core_MDF_CCP_TestDataUtility.createAccountBankMap(acc2.Id,bank.Id,true);
        Core_MDF_CCP_TestDataUtility.createMDFConfigurationData();
        Core_Trigger_Executions__c setting = new Core_Trigger_Executions__c();
        setting.Core_Active__c = true;
        setting.Core_Class_Name__c = 'Core_MDF_AdjustmentClaimOffsetProcess';
        setting.Core_Description__c = 'Demo Description';
        setting.Core_Object__c = 'Core_MDF_Payment_Run__c';
        setting.Core_Trigger_Events__c = 'after insert';
        setting.name = 'Core_MDF_AdjustmentClaimOffsetProcess';
        insert setting;
        List<Core_Trigger_Executions__c> executionClaimVat = new List<Core_Trigger_Executions__c>();
        Core_Trigger_Executions__c claimFunctionalityNameTriggerExecution = new Core_Trigger_Executions__c();
        claimFunctionalityNameTriggerExecution.Core_Active__c = true;
        claimFunctionalityNameTriggerExecution.Core_Class_Name__c = 'Core_MDF_PFCServiceHandler';
        claimFunctionalityNameTriggerExecution.Core_Trigger_Events__c = 'before insert,after update';
        claimFunctionalityNameTriggerExecution.Core_Object__c = 'PartnerFundClaim';
        claimFunctionalityNameTriggerExecution.Name = 'enableClaimsVATEligible';
        claimFunctionalityNameTriggerExecution.Core_Description__c = 'description';
        executionClaimVat.add(claimFunctionalityNameTriggerExecution);
        
        Core_Trigger_Executions__c claimFunctionalityNameTriggerExecution1 = new Core_Trigger_Executions__c();
        claimFunctionalityNameTriggerExecution1.Core_Active__c = true;
        claimFunctionalityNameTriggerExecution1.Core_Class_Name__c = 'Core_MDF_PFCServiceHandler';
        claimFunctionalityNameTriggerExecution1.Core_Trigger_Events__c = 'before insert,after update';
        claimFunctionalityNameTriggerExecution1.Core_Object__c = 'PartnerFundClaim';
        claimFunctionalityNameTriggerExecution1.Name = 'enableClaimsVatAfterInsert';
        claimFunctionalityNameTriggerExecution1.Core_Description__c = 'description';
        executionClaimVat.add(claimFunctionalityNameTriggerExecution1);
        
        Core_Trigger_Executions__c claimFunctionalityNameTriggerExecution2 = new Core_Trigger_Executions__c();
        claimFunctionalityNameTriggerExecution2.Core_Active__c = true;
        claimFunctionalityNameTriggerExecution2.Core_Class_Name__c = 'Core_MDF_PFCServiceHandler';
        claimFunctionalityNameTriggerExecution2.Core_Trigger_Events__c = 'before insert,after update';
        claimFunctionalityNameTriggerExecution2.Core_Object__c = 'PartnerFundClaim';
        claimFunctionalityNameTriggerExecution2.Name = 'enableClaimsVatAfterUpdate';
        claimFunctionalityNameTriggerExecution2.Core_Description__c = 'description';
        executionClaimVat.add(claimFunctionalityNameTriggerExecution2);
        
        Core_Trigger_Executions__c claimFunctionalityNameTriggerExecution3 = new Core_Trigger_Executions__c();
        claimFunctionalityNameTriggerExecution3.Core_Active__c = true;
        claimFunctionalityNameTriggerExecution3.Core_Class_Name__c = 'Core_MDF_PFCServiceHandler';
        claimFunctionalityNameTriggerExecution3.Core_Trigger_Events__c = 'before insert,after update';
        claimFunctionalityNameTriggerExecution3.Core_Object__c = 'PartnerFundClaim';
        claimFunctionalityNameTriggerExecution3.Name = 'enableClaimVatBeforeUpdate';
        claimFunctionalityNameTriggerExecution3.Core_Description__c = 'description';
        executionClaimVat.add(claimFunctionalityNameTriggerExecution3);
        
        Database.insert(executionClaimVat);
        Core_MDF_Configuration__c mdfRecTypes = new Core_MDF_Configuration__c();
        mdfRecTypes.name='Payment_Run_RecordTypes_MDF';
        mdfRecTypes.Core_MDF_Value__c='Client_Co_Marketing_Fund_MDF,Data_Center_Co_Marketing_Fund_MDF';
        database.Insert(mdfRecTypes);
        List<Core_MDF_Configuration__c> mdfRecTypesList = new List<Core_MDF_Configuration__c>();
        Core_MDF_Configuration__c mdfbudgTypes= new Core_MDF_Configuration__c();
        mdfbudgTypes.name='BUDGET_TYPE_CLAIM_BANK_HIDE';
        mdfbudgTypes.Core_MDF_Value__c='MDF,MDF+';
        mdfRecTypesList.add(mdfbudgTypes);
        
        Core_MDF_Configuration__c mdfPRunPgms= new Core_MDF_Configuration__c();
        mdfPRunPgms.name='Programs_For_MDF_PaymentRun';
        mdfPRunPgms.Core_MDF_Value__c='Client,Datacenter';
        mdfRecTypesList.add(mdfPRunPgms);
        insert mdfRecTypesList;
        
        //Bu SPlits
        List<Core_MDF_CCP_Custom_Metadata_Utility__c> mdtUtilityRecList = new List<Core_MDF_CCP_Custom_Metadata_Utility__c>();
        Core_MDF_CCP_Custom_Metadata_Utility__c buSplit = new Core_MDF_CCP_Custom_Metadata_Utility__c();
        buSplit.Core_MDF_Field_5_txt__c = 'CCG CPU Desktop';
        buSplit.Core_MDF_Field_6_txt__c = 'Core_MDF_BU1_Split_Percent_nbr__c';
        buSplit.Core_MDF_Program__c = 'Intel Partner Alliance';
        buSplit.Core_MDF_Category__c = 'BU Splits';
     	mdtUtilityRecList.add(buSplit);
        
        Core_MDF_CCP_Custom_Metadata_Utility__c costCenter = new Core_MDF_CCP_Custom_Metadata_Utility__c();
        costCenter.Core_MDF_Sub_Category__c = 'COST_CENTER';
        costCenter.Core_MDF_Region_Country__c = 'APJ';
        costCenter.Core_MDF_Program__c = 'Intel Partner Alliance';
        costCenter.Core_MDF_Category__c = 'Payment';
        costCenter.Core_MDF_Value__c = '49529';
        mdtUtilityRecList.add(costCenter);
        
        Core_MDF_CCP_Custom_Metadata_Utility__c geoAppr = new Core_MDF_CCP_Custom_Metadata_Utility__c();
        geoAppr.Core_MDF_Sub_Category__c = 'GEO_APPR';
        geoAppr.Core_MDF_Region_Country__c = 'APJ';
        geoAppr.Core_MDF_Program__c = 'Intel Partner Alliance';
        geoAppr.Core_MDF_Category__c = 'Payment';
        geoAppr.Core_MDF_Name_Criteria__c = '1000000';
        geoAppr.Core_MDF_Value__c = '11794891';
        mdtUtilityRecList.add(geoAppr);
        
      	insert mdtUtilityRecList;
        
    }   
    
    
   @isTest
    static void testGetTacticMappingsWithActivityId() {
        Core_MDF_Activity_Attributes__c activityAttribute = [SELECT Id, Core_MDF_Co_Marketing_Activity__c FROM Core_MDF_Activity_Attributes__c LIMIT 1];
        System.assert(activityAttribute != null, 'Activity attribute should not be null');
        
        Test.startTest();
        List<Core_MDF_Tactics_Matric_Controller.TacticKpiWrapper> resultByActivityId = Core_MDF_Tactics_Matric_Controller.getTacticMappings(activityAttribute.Core_MDF_Co_Marketing_Activity__c, null);
        Test.stopTest();
        
        System.assert(resultByActivityId != null, 'Result should not be null');
        System.assertEquals(1, resultByActivityId.size(), 'Result size should be 1');
        System.assertEquals('Digital Media', resultByActivityId[0].tactic);
    }
    @isTest
    static void testGetTacticMappingsWithEmptyInputs() {
        Test.startTest();
        List<Core_MDF_Tactics_Matric_Controller.TacticKpiWrapper> result = Core_MDF_Tactics_Matric_Controller.getTacticMappings(null, null);
        //  List<Core_MDF_Tactics_Matric_Controller.TacticKpiWrapper> result = Core_MDF_Tactics_Matric_Controller.getTacticMappings(null, null);
        Test.stopTest();
        
        System.assert(result != null, 'Result should not be null');
        System.assertEquals(0, result.size(), 'Result size should be 0');
    }
    @isTest static void validateIPAPaymentRun() { 
        // Fetch test users
        User sysAdminUser = [SELECT Id,Email FROM User WHERE Email='sysadmin@example.com' LIMIT 1];
        User ipaPayAdm = [SELECT Id,Email FROM User WHERE Email='testPayment@example.com' LIMIT 1];
        
        // Variable to hold claim record across runAs blocks
        PartnerFundClaim claim1;
        
        Test.startTest();
        
        System.runAs(sysAdminUser) {
            // Get IPA Campaign
            Campaign ipaCamp  = [SELECT Id, Name, StartDate, Status, EndDate, Description, 
                                 Core_MDF_Budget__c, Core_MDF_Account__c, Core_MDF_Channel_Program__c,
                                 Core_MDF_Opal_Budget_Type_Txt__c, Core_MDF_Total_Campaign_Cost_Amt__c
                                 FROM Campaign 
                                 WHERE Name = 'Test IPA Camp' 
                                 LIMIT 1];
            
            // Update account
            Account acc2 = [SELECT Id, Name FROM Account WHERE Name ='Test Account 2'];
            acc2.Core_MDF_Payment_Type_nm__c = 'Distributor (Credit Memo)';
            update acc2;
            
            // Create PartnerFundRequest
            PartnerFundRequest pfr = Core_MDF_CCP_IPA_TestDataUtility.createIPAPartnerFundRequest(
                ipaCamp.Id, acc2.Id, System.today().addDays(-25), System.today().addDays(25), false
            );
            pfr.Core_MDF_BU_Split__c = 'CCG';
            pfr.Core_MDF_BU1_Split_Percent_nbr__c = 100;
            pfr.Core_MDF_Product_Category_txt__c ='Desktop';
            insert pfr;
            
            // Update Campaign
            ipaCamp.Status = 'Proposal Accepted';
            update ipaCamp;
            
            // Get PMB and Allocation
            PartnerMarketingBudget pmb = [
                SELECT Id, Title, Description, Core_MDF_Budget_Status__c, StartDate, EndDate, Amount, 
                Core_MDF_Budget_Type_Txt__c, Core_MDF_Budget_Partner__c, Core_MDF_Program__c, 
                RecordTypeId, IsIgnoreValidation 
                FROM PartnerMarketingBudget 
                WHERE Id = :ipaCamp.Core_MDF_Budget__c
            ];
            
            PartnerFundAllocation pfa = [
                SELECT Id, ChannelPartnerId, Amount 
                FROM PartnerFundAllocation 
                WHERE BudgetId = :pmb.Id 
                LIMIT 1
            ];
            
            // Update Fund Request
            pfr.Core_MDF_Fund_Request_Status__c = 'Planned';
            pfr.Status = 'Approved';
            pfr.Amount = 100.0;
            pfr.AllocationId = pfa.Id;
            pfr.Core_MDF_Reimbursement_Rate_pct__c ='100%';
            update pfr;
            
            // Create PartnerFundClaim
            claim1 = Core_MDF_CCP_IPA_TestDataUtility.createIPAClaim(
                'IPA Claim', Core_MDF_CCP_IPA_TestDataUtility.claim_RecordType_IPA, 
                pfr.Id, System.today().addDays(-20), System.today().addDays(-5), 50.00, null, false
            ); 
            claim1.Core_MDF_Type_Txt__c ='Claim';
            claim1.Core_MDF_Currency__c='USD';
            claim1.Core_MDF_Country_Location_nm__c= 'AFGHANISTAN'; 
            claim1.Core_MDF_Campaign_Id__c = ipaCamp.Id;
            claim1.Core_MDF_VAT_Opt_In__c = 'Service Invoice to Intel (VAT may apply)';
            claim1.Core_MDF_VAT_Eligibility_Ind__c= true; 
            claim1.Core_MDF_VAT_Hold_Ind__c = true;
            claim1.Core_MDF_Status__c = 'Hold';
            claim1.Core_MDF_Ad_Run_Start_Date__c=System.today();
            claim1.Core_MDF_Ad_Run_End_Date__c=System.today();
            claim1.Core_MDF_Processing_Preference_nm__c='Get paid, then settle';
           
            insert claim1;
        }
        Core_MDF_Claim_Attributes__c claimAttribute = new Core_MDF_Claim_Attributes__c(
            Core_MDF_Claim_Id__c = claim1.id,
            Core_MDF_Field_Name_nm__c = 'Digital Media - Average time on Page (Seconds)',
            Core_MDF_Field_Value_nbr__c = 100,
            Core_MDF_Type_nm__c = 'KPI - Claim',
            Core_MDF_Tactics_nm__c = 'Digital Media',
            Core_MDF_Is_Active_Ind__c = true
            
        );
        insert claimAttribute;
        System.runAs(ipaPayAdm) {
            ChannelProgram cp1 = [SELECT Id, Name FROM ChannelProgram WHERE Name ='Intel Partner Alliance' LIMIT 1];
            
            Core_MDF_Payment_Run__c ipaPayRunRecord = new Core_MDF_Payment_Run__c();
            ipaPayRunRecord.Core_MDF_ScheduleRun_Dtm__c = DateTime.now().addMinutes(1);
            ipaPayRunRecord.Core_MDF_Geo_Txt__c = 'APJ';
            ipaPayRunRecord.Core_MDF_Start_Dt__c = System.today().addDays(-30);                                                       
            ipaPayRunRecord.Core_MDF_End_Dt__c = System.today().addDays(30);
            ipaPayRunRecord.Core_MDF_Program_Txt__c = 'Intel Partner Alliance';
            ipaPayRunRecord.Core_MDF_Program_Id__c = cp1.Id;
            ipaPayRunRecord.Core_MDF_Payment_Nature_nm__c = 'Contra Revenue';
            insert ipaPayRunRecord;  
            
            // Call the method under test
            Map<String,String> dummyMap = new Map<String,String>();
            Core_MDF_Tactics_Matric_Controller.getTacticMappingsByRecordId(claim1.Id, dummyMap);
            
            System.assertNotEquals(ipaPayRunRecord.Id, null, 'Payment Run record should be inserted');
        }
        
        Test.stopTest();
    }
   
}