/****************************************************************************************************************************************
* Class Name  : Core_MDF_PFC_IPAClaim_Test
* Version     : 1.0 
* Created Date: 23-Aug-2021
* Modification Log :
* Developer                        Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture -Hamza          23-Aug-2021                    Created to test Payment Run functionality for IPA Claim process & BU Split process
*****************************************************************************************************************************************/
@isTest
public class Core_MDF_IPA_PaymentRun_Test {
    
    public static Id payRun_RecordType_IPAMDF = Schema.SObjectType.Core_MDF_Payment_Run__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_Intel_Partner_Alliance_MDF').getRecordTypeId();
    public static Id payRun_RecordType_CoGTM = Schema.SObjectType.Core_MDF_Payment_Run__c.getRecordTypeInfosByDeveloperName().get('Co_Engineering').getRecordTypeId();
    
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
        // Highlight: Unused Local Variable - Indira
       // Id campaign_RecordType_IPA = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Core_MDF_Intel_Partner_Alliance').getRecordTypeId();
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
            'View_All_Data',
            'Core_MDF_CCP_Internal_Co_GTM_Payment_Adm'
        )]) {
            nameToPerSet.put(pSet.Name,pSet);
        }
        
        PermissionSet paymentAdmGeoPS = nameToPerSet.get('Core_MDF_CCP_Internal_APJ_User'); 
        PermissionSet paymentAdmSchedulePS = nameToPerSet.get('Core_MDF_CCP_Internal_Payment_Schedule_Admin'); 
        PermissionSet ipaPaymentAdmPS = nameToPerSet.get('Core_MDF_CCP_Internal_IPA_Payment_Adm');
        PermissionSet viewAllDataPS = nameToPerSet.get('View_All_Data');
        PermissionSet cogtmPaymentAdmPS = nameToPerSet.get('Core_MDF_CCP_Internal_Co_GTM_Payment_Adm');
        
        User usr2 = Core_MDF_CCP_TestDataUtility.createUser(false); 
        usr2.Email='testPayment@example.com';
        usr2.LastName='PayAdmUser';
        usr2.profileId = profileToId.get('CCP - Core Access');
        usr2.IsActive = true;
        userList.add(usr2); 
        
        User usrcogtmPayAdm = Core_MDF_CCP_TestDataUtility.createUser(false); 
        usrcogtmPayAdm.Email='testCoGTMPayment@example.com';
        usrcogtmPayAdm.LastName='PayAdmUser';
        usrcogtmPayAdm.profileId = profileToId.get('CCP - Core Access');
        usrcogtmPayAdm.IsActive = true;
        userList.add(usrcogtmPayAdm); 
        
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
        
        // Assigning CoGTM Payment Admin PS Co-GTM
        PermissionSetAssignment assignPermissionSetObj3 = new PermissionSetAssignment();
        assignPermissionSetObj3.AssigneeId = usrcogtmPayAdm.Id;
        assignPermissionSetObj3.PermissionSetId = cogtmPaymentAdmPS.Id;
        permSetAssgnLst.add(assignPermissionSetObj3);
        
        // Assigning Payment Admin Schedule PS Co-GTM
        PermissionSetAssignment assignSchedulePermissionSetForCoGTM = new PermissionSetAssignment();
        assignSchedulePermissionSetForCoGTM.AssigneeId = usrcogtmPayAdm.Id;
        assignSchedulePermissionSetForCoGTM.PermissionSetId = paymentAdmSchedulePS.Id;
        permSetAssgnLst.add(assignSchedulePermissionSetForCoGTM);
        
        // Assigning View All Data PS Co-GTM
        PermissionSetAssignment assignViewAllPermissionSetCoGTM = new PermissionSetAssignment();
        assignViewAllPermissionSetCoGTM.AssigneeId = usrcogtmPayAdm.Id;
        assignViewAllPermissionSetCoGTM.PermissionSetId = viewAllDataPS.Id;
        permSetAssgnLst.add(assignViewAllPermissionSetCoGTM);
        
        PermissionSetAssignment assignViewAllPermissionSetCoGTMAPJ = new PermissionSetAssignment();
        assignViewAllPermissionSetCoGTMAPJ.AssigneeId = usrcogtmPayAdm.Id;
        assignViewAllPermissionSetCoGTMAPJ.PermissionSetId = paymentAdmGeoPS.Id;
        permSetAssgnLst.add(assignViewAllPermissionSetCoGTMAPJ);
        
        system.runAs(usr){
            Database.insert(permSetAssgnLst);
            
        }
        // Highlight: Unused Local Variable - Indira
       // Id acctRecord_Type = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Core_Partner_Account_Group').getRecordTypeId();
        Account acc = Core_MDF_CCP_TestDataUtility.createIntelAccount('Test IPA Accounttest', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);//changed 2nd parameter
        acc.Core_MDF_CoMarketingActive__c = true;
        insert acc;
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
        
        string budgetType = Core_MDF_CCP_IPA_TestDataUtility.createBenefit(acc2);
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
        
        Campaign camp = Core_MDF_CCP_IPA_TestDataUtility.createIPACampaign('Test IPA Camp',acc2.Id, System.today().addDays(-30), System.today().addDays(300),budgetType, 1234.00, 'AFGHANISTAN','Consumer','Other','Pending Review', false);
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
        Test.stopTest();
        // Highlight: Unused Local Variable - Indira
       // List<Core_MDF_Bank__c> listBank = new List<Core_MDF_Bank__c>();
        
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
        // Highlight: Unused Local Variable - Indira
       // Core_MDF_Account_Bank_Mapping__c abm1 = Core_MDF_CCP_TestDataUtility.createAccountBankMap(acc2.Id,bank.Id,true);
        
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
        
        // CoGTM claim data prep
        ChannelProgram coGTMCP = Core_MDF_CCP_TestDataUtility.createProgram('Co-GTM','CoGTM', true);
        Account ipaUltimateAccount = Core_MDF_CCP_TestDataUtility.createIntelAccount ('IPA Intel Account',Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, true);
        ipaUltimateAccount.Core_Unified_Global_Customer_BP_Id__c = ipaUltimateAccount.Id;
        ipaUltimateAccount.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        update ipaUltimateAccount;
        Account coGTMIntelAccount = Core_MDF_CCP_TestDataUtility.createIntelAccount('CoGTM Intel Account', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, true);
        Account coGTMCoMarketingAccount = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('CoGTM Co-Marketing Account', coGTMCP.id, Core_MDF_CCP_TestDataUtility.Account_Record_Type,coGTMIntelAccount.id, false);
        coGTMCoMarketingAccount.Core_MDF_Payment_Type_nm__c = 'Customer';
        insert coGTMCoMarketingAccount;
        
        Core_MDF_Bank__c bankCoGTM = Core_MDF_CCP_TestDataUtility.createBank(coGTMIntelAccount.Id, 'Core_MDF_Co_GTM', false,'1231231230');
        bankCoGTM.Core_MDF_Intel_Company_Code__c = '100';
        bankCoGTM.Core_MDF_Currency_cd__c = 'USD';
        bankCoGTM.Core_MDF_Tax_codes_cd__c = 'UB';
        bankCoGTM.Core_MDF_Bank_Status__c = 'Active';
        bankCoGTM.Core_MDF_VAT_pct__c= '20';
        bankCoGTM.Core_MDF_Bank_Location__c = 'US';
        bankCoGTM.Core_MDF_Supplier_City_txt__c = 'New York';
        bankCoGTM.Core_MDF_Supplier_Country_txt__c = 'US';
        bankCoGTM.Core_MDF_Supplier_Postal_Code_cd__c = '110111';
        bankCoGTM.Core_MDF_Supplier_Region_txt__c = 'USA';
        
        bankCoGTM.Core_MDF_Payment_Currency_Cd__c = 'USD';
        bankCoGTM.Name = 'Test CoGTM Bank';
        bankCoGTM.Core_MDF_Effective_Date__c=System.today().addDays(-3);
        System.runAs(usrcogtmPayAdm){
            Database.insert(bankCoGTM);  
        }

        Id pmb_RecordType_CoGTM = Schema.SObjectType.PartnerMarketingBudget.getRecordTypeInfosByDeveloperName().get('Core_MDF_Co_GTM').getRecordTypeId();
        Id pfa_RecordType_CoGTM = Schema.SObjectType.PartnerFundAllocation.getRecordTypeInfosByDeveloperName().get('Core_MDF_Co_GTM').getRecordTypeId();
        Id campaign_RecordType_CoGTM = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Core_MDF_Co_GTM').getRecordTypeId();
        Id pfr_RecordType_CoGTM = Schema.SObjectType.PartnerFundRequest.getRecordTypeInfosByDeveloperName().get('Core_MDF_Co_GTM').getRecordTypeId();
        
        PartnerMarketingBudget  coGTMPMB = Core_MDF_CCP_TestDataUtility.createBudget('CoGTMPMB', pmb_RecordType_CoGTM, coGTMCoMarketingAccount.Id, coGTMCP.Id, 1000000, System.today().addDays(-10), System.today().addDays(40),false);
        coGTMPMB.Core_MDF_Budget_Type_Txt__c = 'Co-Engineering';
        insert coGTMPMB;
        
        PartnerFundAllocation coGTMPFA = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('CoGTMPFA',coGTMPMB,coGTMCoMarketingAccount,100000.0,true);
        
        Campaign coGTMCampaign = new Campaign();
        coGTMCampaign.Name = 'Test CoGTM Camp';
        coGTMCampaign.Core_MDF_Opal_Budget_Type_Txt__c = 'Co-Engineering';
        coGTMCampaign.Core_MDF_Proposal_Based_Ind__c = true;
        coGTMCampaign.Core_MDF_Program__c = 'CoGTM';
        coGTMCampaign.Status = 'Draft';
        coGTMCampaign.Core_MDF_Account__c = coGTMCoMarketingAccount.id;
        coGTMCampaign.RecordTypeId = campaign_RecordType_CoGTM;
        coGTMCampaign.StartDate = System.today().addDays(-5);
        coGTMCampaign.EndDate = System.today().addDays(15);
        coGTMCampaign.Core_MDF_Reimbursement_Amt__c = 1000200;
        coGTMCampaign.Core_MDF_Activity_Category_Type__c = 'Innovation ->Engineering';
        Database.insert(coGTMCampaign);
        
        PartnerFundRequest coGTMPFR = new PartnerFUndRequest();
        coGTMPFR.CampaignId=coGTMCampaign.id;
        coGTMPFR.RecordTypeId = pfr_RecordType_CoGTM;
        coGTMPFR.ChannelPartnerId = coGTMCoMarketingAccount.id;
        coGTMPFR.Core_MDF_ActivityCategory__c='Innovation';
        coGTMPFR.Core_MDF_Activity_Types__c='Engineering';
        coGTMPFR.Core_MDF_Start_Date__c=System.today().addDays(-5);
        coGTMPFR.Core_MDF_End_Date__c =System.today().addDays(2);
        coGTMPFR.Title ='Test CoGTM PFR';
        coGTMPFR.Status = 'Draft';
        coGTMPFR.Core_MDF_Reimbursement_Rate_txt__c = '100%';
        coGTMPFR.RequestedAmount = 1000200;
        coGTMPFR.AllocationId = coGTMPFA.Id;
        coGTMPFR.BudgetId = coGTMPMB.Id;
        Database.insert(coGTMPFR);
    }   
    @isTest static void validateIPAPaymentRun() { 
        User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        User ipaPayAdm = [SELECT Id,Email from User where Email='testPayment@example.com' limit 1];
        System.runAs(sysAdminUser)
        {
            Test.startTest(); 
            
            Campaign ipaCamp  = [Select Id, Name, StartDate,status, EndDate, Description, Core_MDF_Budget__c,Core_MDF_Account__c,Core_MDF_Channel_Program__c,
                                 Core_MDF_Opal_Budget_Type_Txt__c,Core_MDF_Total_Campaign_Cost_Amt__c
                                 from Campaign where Name = 'Test IPA Camp' limit 1];
            Account acc2 = [Select Id, name from Account Where Name ='Test Account 2'];
            acc2.Core_MDF_Payment_Type_nm__c =  'Distributor (Credit Memo)' ;
            update acc2;
            PartnerFundRequest pfr = Core_MDF_CCP_IPA_TestDataUtility.createIPAPartnerFundRequest(ipaCamp.Id,acc2.Id,System.today().addDays(-25),System.today().addDays(25),false);
            pfr.Core_MDF_BU_Split__c = 'CCG';
            pfr.Core_MDF_BU1_Split_Percent_nbr__c = 100;
            pfr.Core_MDF_Product_Category_txt__c ='Desktop';
            Database.insert(pfr);
            
            List<Campaign> campToBeUpdated = new List<Campaign>();
            List<PartnerFundRequest> pfrToBeUpdated = new List<PartnerFundRequest>(); 
            ipaCamp.Status = 'Proposal Accepted';
            campToBeUpdated.add(ipaCamp);
            
            Database.update(campToBeUpdated);
            // Highlight: Unused Local Variable - Indira
           // Id recordtype = Schema.SObjectType.PartnerMarketingBudget.getRecordTypeInfosByDeveloperName().get('Core_MDF_IPA_ProposalBased').getRecordTypeId(); 
            
            PartnerMarketingBudget pmb = [Select id,Title, Description, Core_MDF_Budget_Status__c, StartDate, EndDate, Amount, Core_MDF_Budget_Type_Txt__c,
                                          Core_MDF_Budget_Partner__c,Core_MDF_Program__c, RecordTypeId, IsIgnoreValidation From PartnerMarketingBudget where Id = :ipaCamp.Core_MDF_Budget__c];
            PartnerFundAllocation pfa = [Select Id, ChannelPartnerId, Amount from PartnerFundAllocation where BudgetId = :pmb.Id]; 
            Core_MDF_Bank__c bank1 = [Select Id from Core_MDF_Bank__c where Core_MDF_Program__c='Core_MDF_Intel_Partner_Alliance' limit 1];
            bank1.Core_MDF_Intel_Company_Code__c = '420';
            pfr.Core_MDF_Fund_Request_Status__c = 'Planned';
            pfr.Status ='Approved';
            pfr.amount  = 100.0;
            pfr.AllocationId = pfa.Id;
            pfr.Core_MDF_Reimbursement_Rate_pct__c ='100%';
            pfrToBeUpdated.add(pfr);
            
            Database.update(pfrToBeUpdated);
            
            
            PartnerFundClaim claim1 =  Core_MDF_CCP_IPA_TestDataUtility.createIPAClaim('IPA Claim',Core_MDF_CCP_IPA_TestDataUtility.claim_RecordType_IPA, pfr.Id, System.today().addDays(-20), System.today().addDays(-5),50.00, null, false); 
            claim1.Core_MDF_Type_Txt__c ='Claim';
            claim1.Core_MDF_Currency__c='USD';
            claim1.Core_MDF_Country_Location_nm__c= 'AFGHANISTAN'; 
            claim1.Core_MDF_Campaign_Id__c = ipaCamp.Id;
            claim1.Core_MDF_VAT_Opt_In__c = 'Service Invoice to Intel (VAT may apply)';
            claim1.Core_MDF_VAT_Eligibility_Ind__c= true ; 
            claim1.Core_MDF_VAT_Hold_Ind__c = true;
            claim1.Core_MDF_Status__c = 'Hold';
            insert claim1;
        }
        System.runAs(ipaPayAdm){
            ChannelProgram cp1 = [Select Id,Name from ChannelProgram where Name ='Intel Partner Alliance' LIMIT 1];
            Core_MDF_Payment_Run__c ipaPayRunRecord = new Core_MDF_Payment_Run__c();
            ipaPayRunRecord.Core_MDF_ScheduleRun_Dtm__c= DateTime.Now().addMinutes(1);
            ipaPayRunRecord.Core_MDF_Geo_Txt__c = 'APJ';
            ipaPayRunRecord.Core_MDF_Start_Dt__c = System.today().addDays(-30);                                                       
            ipaPayRunRecord.Core_MDF_End_Dt__c = System.today().addDays(30);
            ipaPayRunRecord.Core_MDF_Program_Txt__c = 'Intel Partner Alliance';
            ipaPayRunRecord.RecordTypeId  = payRun_RecordType_IPAMDF;
            ipaPayRunRecord.Core_MDF_Program_Id__c = cp1.Id;
            ipaPayRunRecord.Core_MDF_Payment_Nature_nm__c = 'Contra Revenue' ;
            Database.insert(ipaPayRunRecord);  
            List<Id> listOfPaymentRun = new List<Id>();
            listOfPaymentRun.add(ipaPayRunRecord.Id);
            Core_MDF_Batch_PaymentFileGenerator paymentbatch = new Core_MDF_Batch_PaymentFileGenerator(ipaPayRunRecord);
            database.executebatch(paymentbatch,200);
            System.assertNotEquals(ipaPayRunRecord.Id,null);
            Test.stopTest();
            Core_MDF_EmailToGSPO.callBatchToSendEmailToGSPO(listOfPaymentRun);
            Core_MDF_VatUtility.getCountOfVatClaimRecords(listOfPaymentRun);  
            
            
        }
    }
    
    @isTest static void validateVATIPAPaymentRun() { 
        User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        User ipaPayAdm = [SELECT Id,Email from User where Email='testPayment@example.com' limit 1];
        Map<String, PartnerFundClaim> claimMap = new Map<String, PartnerFundClaim>();
        System.runAs(sysAdminUser)
        {
            
            Test.startTest(); 
            Campaign ipaCamp  = [Select Id, Name, StartDate,status, EndDate, Description, Core_MDF_Budget__c,Core_MDF_Account__c,Core_MDF_Channel_Program__c,
                                 Core_MDF_Opal_Budget_Type_Txt__c,Core_MDF_Total_Campaign_Cost_Amt__c
                                 from Campaign where Name = 'Test IPA Camp' limit 1];
            Account acc2 = [Select Id, name from Account Where Name ='Test Account 2'];
            acc2.Core_MDF_Payment_Type_nm__c = 'Distributor (Cash)';
            update acc2;
            
            Core_MDF_Comarketing_CMF_Map__c cmfRec = new Core_MDF_Comarketing_CMF_Map__c();
            cmfRec.Core_MDF_Account_Id__c = acc2.Id ;
            cmfRec.Core_MDF_Distribution_Channel_cd__c = '02';
            cmfRec.Core_MDF_Sales_Org_cd__c= 'EU02';
            cmfRec.Core_MDF_Active_Ind__c = true;
            cmfRec.Core_MDF_Ship_To_Number_Id__c = '2356';
            cmfRec.Core_MDF_Sold_To_Number_Id__c = '8956';
            insert cmfRec;
            
            PartnerFundRequest pfr = Core_MDF_CCP_IPA_TestDataUtility.createIPAPartnerFundRequest(ipaCamp.Id,acc2.Id,System.today().addDays(-25),System.today().addDays(25),false);
            pfr.Core_MDF_BU_Split__c = 'CCG CPU Desktop';
            pfr.Core_MDF_BU1_Split_Percent_nbr__c = 100;
            pfr.Core_MDF_Product_Category_txt__c ='Desktop';
            Database.insert(pfr);
            
            List<Campaign> campToBeUpdated = new List<Campaign>();
            List<PartnerFundRequest> pfrToBeUpdated = new List<PartnerFundRequest>(); 
            ipaCamp.Status = 'Proposal Accepted';
            campToBeUpdated.add(ipaCamp);
            
            Database.update(campToBeUpdated);
            // Highlight: Unused Local Variable - Indira
           // Id recordtype = Schema.SObjectType.PartnerMarketingBudget.getRecordTypeInfosByDeveloperName().get('Core_MDF_IPA_ProposalBased').getRecordTypeId(); 
            
            PartnerMarketingBudget pmb = [Select id,Title, Description, Core_MDF_Budget_Status__c, StartDate, EndDate, Amount, Core_MDF_Budget_Type_Txt__c,
                                          Core_MDF_Budget_Partner__c,Core_MDF_Program__c, RecordTypeId, IsIgnoreValidation From PartnerMarketingBudget where Id = :ipaCamp.Core_MDF_Budget__c];
            PartnerFundAllocation pfa = [Select Id, ChannelPartnerId, Amount from PartnerFundAllocation where BudgetId = :pmb.Id]; 
            Core_MDF_Bank__c bank1 = [Select Id from Core_MDF_Bank__c where Core_MDF_Program__c='Core_MDF_Intel_Partner_Alliance' limit 1];
            bank1.Core_MDF_Intel_Company_Code__c = '150';
            pfr.Core_MDF_Fund_Request_Status__c = 'Planned';
            pfr.Status ='Approved';
            pfr.amount  = 100.0;
            pfr.AllocationId = pfa.Id;
            pfr.Core_MDF_Reimbursement_Rate_pct__c ='100%';
            pfrToBeUpdated.add(pfr);
            
            Database.update(pfrToBeUpdated);
            
            PartnerFundClaim claim1 =  Core_MDF_CCP_IPA_TestDataUtility.createIPAClaim('IPA Claim',Core_MDF_CCP_IPA_TestDataUtility.claim_RecordType_IPA, pfr.Id, System.today().addDays(-20), System.today().addDays(-5),50.00, bank1.Id, false); 
            claim1.Core_MDF_Type_Txt__c ='Claim';
            claim1.Core_MDF_Currency__c='USD';
            claim1.Core_MDF_Country_Location_nm__c= 'AUSTRALIA'; 
            claim1.Core_MDF_Campaign_Id__c = ipaCamp.Id;
            claim1.Core_MDF_VAT_Opt_In__c = 'Service Invoice to Intel (VAT may apply)';
            claim1.Core_MDF_VAT_Eligibility_Ind__c= true ; 
            claim1.Core_MDF_VAT_Hold_Ind__c = true;
            claim1.Core_MDF_To_Be_Audited_Ind__c = true;
            claim1.Core_MDF_Quarter_Year_txt__c = 'Q2-2023';
            claim1.Core_MDF_Paid_By_Payment_Type_nm__c = 'Distributor (Cash)';
            insert claim1;
            
            claim1.Core_MDF_Status__c = 'Hold';
            update claim1;
            PartnerFundClaim pfc = [Select Id,Core_MDF_Region_Cd__c,Core_MDF_Sub_Region_Cd__c,Core_MDF_Country_Location_nm__c,Core_MDF_Bank__r.Core_MDF_Intel_Company_Code__c,Core_MDF_Applicable_VAT_Percentage_nm__c,Title,Core_MDF_VAT_Amt__c,Amount,Request.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c,Core_MDF_Total_Claim_Recovery_Amount__c,Request.Core_MDF_BU1_Split_Percent_nbr__c,Request.Core_MDF_Product_Category_txt__c,Core_MDF_Status__c,Core_MDF_Payment_Id__c,Core_MDF_Paid_By_Payment_Type_nm__c,Core_MDF_Budget_Type_Options_Nm__c,Core_MDF_VAT_Eligibility_Ind__c,Core_MDF_C_Type_Ind__c,ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c,Core_MDF_Bank__c,Core_MDF_Bank__r.Core_MDF_Supplier_Number__c,Core_MDF_Quarter_Year_Txt__c,Core_MDF_Program__c,Core_MDF_Payment_Type_nm__c,ChannelPartnerId,Request.Core_MDF_BU_Split__c, RequestId,Core_MDF_Type_Txt__c from PartnerFundClaim where Title =: 'IPA Claim' limit 1];
            claimMap.put(pfc.title,pfc);

            claim1.Core_MDF_Status__c = 'Payment Due';
            Database.update(claim1);
            
            Core_MDF_Recovery__c recoveryRec = new Core_MDF_Recovery__c();
            recoveryRec.Core_MDF_Claim_Id__c = claim1.Id;
            recoveryRec.Core_MDF_Amount_Amt__c = 10.0;
            Insert recoveryRec;
        }
        System.runAs(ipaPayAdm){
            
            ChannelProgram cp1 = [Select Id,Name from ChannelProgram where Name ='Intel Partner Alliance' LIMIT 1];
            Core_MDF_Comarketing_CMF_Map__c cmfRec = [Select Id,Core_MDF_Account_Id__c,Core_MDF_Distribution_Channel_cd__c,Core_MDF_Sales_Org_cd__c,Core_MDF_Active_Ind__c,Core_MDF_Ship_To_Number_Id__c,Core_MDF_Sold_To_Number_Id__c  from Core_MDF_Comarketing_CMF_Map__c LIMIT 1];
            Map<Id,Core_MDF_Comarketing_CMF_Map__c> cmfMap = new MAp<Id,Core_MDF_Comarketing_CMF_Map__c>();
            cmfMap.put(cmfRec.Core_MDF_Account_Id__c,cmfRec);
            Core_MDF_Payment_Run__c ipaPayRunRecord = new Core_MDF_Payment_Run__c();
            ipaPayRunRecord.Core_MDF_ScheduleRun_Dtm__c= DateTime.Now().addMinutes(1);
            ipaPayRunRecord.Core_MDF_Geo_Txt__c = 'APJ';
            ipaPayRunRecord.Core_MDF_Start_Dt__c = System.today().addDays(-30);                                                       
            ipaPayRunRecord.Core_MDF_End_Dt__c = System.today().addDays(30);
            ipaPayRunRecord.Core_MDF_Program_Txt__c = 'Intel Partner Alliance';
            ipaPayRunRecord.Core_MDF_Program_Id__c = cp1.Id;
            ipaPayRunRecord.RecordTypeId  = payRun_RecordType_IPAMDF;
            ipaPayRunRecord.Core_MDF_Payment_Nature_nm__c = 'Contra Revenue' ;
            Database.insert(ipaPayRunRecord);
            Core_MDF_Payment_Run__c testipaPayRunRecord = [Select Id,Core_MDF_Program_Id__c, Core_MDF_Program_Id__r.Name,Core_MDF_ScheduleRun_Dtm__c,Core_MDF_Geo_Txt__c,Core_MDF_Start_Dt__c,Core_MDF_End_Dt__c,Core_MDF_Program_Txt__c,RecordTypeId,Core_MDF_Payment_Nature_nm__c,Core_MDF_Subgeo_Txt__c, Name,Core_MDF_Budget_Type_nm__c from Core_MDF_Payment_Run__c where Id =: ipaPayRunRecord.Id];
            Core_MDF_Batch_PaymentFileGenerator paymentbatch = new Core_MDF_Batch_PaymentFileGenerator(testipaPayRunRecord);
            database.executebatch(paymentbatch,200);
            System.assertNotEquals(testipaPayRunRecord.Id,null);
            Map<String,Core_MDF_PaymentWrapper> grps = new Map<String,Core_MDF_PaymentWrapper>();
            
            Core_MDF_PaymentWrapper paymentWrapper = new Core_MDF_PaymentWrapper();
            paymentWrapper.claimsToBeProcessed = claimMap.values();
            paymentWrapper.sumOfClaimsAmount = 0;  
            paymentWrapper.sumOfConvertedAmount = 0;
            paymentWrapper.currencyExchangeRate = 0;
            grps.put('test',paymentWrapper);
            
            Core_MDF_PaymentFileWrapper paymentFileWrapper = new Core_MDF_PaymentFileWrapper();
            paymentFileWrapper.claimsToBeProcessed = claimMap.values();
            paymentFileWrapper.sumOfClaimsAmount = 100;  
            paymentFileWrapper.sumOfConvertedAmount = 0;
            paymentFileWrapper.geoLocation = '';
            paymentFileWrapper.subGeoLocation = '';
            paymentFileWrapper.currencyExchangeRate = 0;
            paymentFileWrapper.productCategory = '';
            paymentFileWrapper.quarterNum = '';
            paymentFileWrapper.fiscalYear = '';
            paymentFileWrapper.fyQuarterAndYear = '';
            paymentFileWrapper.paymentWrapperUniqueKey = '';
            paymentFileWrapper.totalVatAmt = 0;
            paymentFileWrapper.isVatEligible = true;
            paymentFileWrapper.totalConvertedVatAmt = 0;
            paymentFileWrapper.isCTypeInd=false;
            paymentFileWrapper.businessUnit = '';
            paymentFileWrapper.profitcenter = '';
            paymentFileWrapper.materialCode = '';
            paymentFileWrapper.isRecoveryIncluded = true;
            paymentFileWrapper.sumOfClaimsAmountExcludesRecovery = 50;
            paymentFileWrapper.includeOnlyClaimAmountForPayment = true;
            Map<String,Core_MDF_PaymentFileWrapper> paymentFileWrapperMap = new Map<String,Core_MDF_PaymentFileWrapper>();
            paymentFileWrapperMap.put('test',paymentFileWrapper);
            
            Map<Id, Core_MDF_Account_Node_Attributes__c> accNodeAttrMap = new Map<Id,Core_MDF_Account_Node_Attributes__c>([Select Id,Core_MDF_Account_id__c, Core_MDF_Program_id__c,Core_MDF_CSAR_GL_Account_nbr__c,Core_MDF_External_ID__c,Core_MDF_NonPO_GL_Account_nbr__c from Core_MDF_Account_Node_Attributes__c limit 1]);
            Core_MDF_Payment_FileHelper.generateIPAPaymentFileForCreditMemo(paymentFileWrapperMap,testipaPayRunRecord,'Intel Partner Alliance');
            Map<String,List<PartnerFundClaim>> paymentTypeToClaims= new Map<String,List<PartnerFundClaim>>();
            paymentTypeToClaims.put('CSAR Cash',claimMap.values());
            Core_MDF_PaymentProcessRetailMdfIPA.groupClaimsforPaymentFileRetailMDFIPA(claimMap.values(),testipaPayRunRecord, cmfMap, accNodeAttrMap);
            Core_MDF_PaymentProcessRetailMdfIPA.createPaymentWrapperMap(paymentFileWrapperMap,testipaPayRunRecord);
            Map<String,Map<String,Core_MDF_PaymentFileWrapper>> paymentTypeToFileWrapper= new Map<String,Map<String,Core_MDF_PaymentFileWrapper>>();
            paymentTypeToFileWrapper.put('CSAR Cash',paymentFileWrapperMap);
            Core_MDF_Batch_UpdatePaymentRunClaims batch = new Core_MDF_Batch_UpdatePaymentRunClaims(null, paymentFileWrapperMap,paymentTypeToFileWrapper, claimMap.values(), testipaPayRunRecord, null,paymentTypeToClaims,null, accNodeAttrMap);
            database.executebatch(batch,200);

            Test.stopTest();
            
            
        }
    }
    
    @isTest static void validateVATIPAPaymentRunExpense() { 
        User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        User ipaPayAdm = [SELECT Id,Email from User where Email='testPayment@example.com' limit 1];
        Map<String, PartnerFundClaim> claimMap = new Map<String, PartnerFundClaim>();
        System.runAs(sysAdminUser)
        {
            Test.startTest(); 
            
            Campaign ipaCamp  = [Select Id, Name, StartDate,status, EndDate, Description, Core_MDF_Budget__c,Core_MDF_Account__c,Core_MDF_Channel_Program__c,
                                 Core_MDF_Opal_Budget_Type_Txt__c,Core_MDF_Total_Campaign_Cost_Amt__c
                                 from Campaign where Name = 'Test IPA Camp' limit 1];
            Account acc2 = [Select Id, name from Account Where Name ='Test Account 2'];
            acc2.Core_MDF_Payment_Type_nm__c = 'Non-Customer';
            update acc2;
            
            Core_MDF_Comarketing_CMF_Map__c cmfRec = new Core_MDF_Comarketing_CMF_Map__c();
            cmfRec.Core_MDF_Account_Id__c = acc2.Id ;
            cmfRec.Core_MDF_Distribution_Channel_cd__c = '02';
            cmfRec.Core_MDF_Sales_Org_cd__c= 'EU02';
            cmfRec.Core_MDF_Active_Ind__c = true;
            cmfRec.Core_MDF_Ship_To_Number_Id__c = '2356';
            cmfRec.Core_MDF_Sold_To_Number_Id__c = '8956';
            insert cmfRec;
            
            PartnerFundRequest pfr = Core_MDF_CCP_IPA_TestDataUtility.createIPAPartnerFundRequest(ipaCamp.Id,acc2.Id,System.today().addDays(-25),System.today().addDays(25),false);
            pfr.Core_MDF_BU_Split__c = 'CCG';
            pfr.Core_MDF_BU1_Split_Percent_nbr__c = 100;
            pfr.Core_MDF_Product_Category_txt__c ='Desktop';
            Database.insert(pfr);
            
            List<Campaign> campToBeUpdated = new List<Campaign>();
            List<PartnerFundRequest> pfrToBeUpdated = new List<PartnerFundRequest>(); 
            ipaCamp.Status = 'Proposal Accepted';
            campToBeUpdated.add(ipaCamp);
            
            Database.update(campToBeUpdated);
           // Highlight: Unused Local Variable - Indira 
          //  Id recordtype = Schema.SObjectType.PartnerMarketingBudget.getRecordTypeInfosByDeveloperName().get('Core_MDF_IPA_ProposalBased').getRecordTypeId(); 
            
            PartnerMarketingBudget pmb = [Select id,Title, Description, Core_MDF_Budget_Status__c, StartDate, EndDate, Amount, Core_MDF_Budget_Type_Txt__c,
                                          Core_MDF_Budget_Partner__c,Core_MDF_Program__c, RecordTypeId, IsIgnoreValidation From PartnerMarketingBudget where Id = :ipaCamp.Core_MDF_Budget__c];
            PartnerFundAllocation pfa = [Select Id, ChannelPartnerId, Amount from PartnerFundAllocation where BudgetId = :pmb.Id]; 
            Core_MDF_Bank__c bank1 = [Select Id from Core_MDF_Bank__c where Core_MDF_Program__c='Core_MDF_Intel_Partner_Alliance' limit 1];
            bank1.Core_MDF_Intel_Company_Code__c = '150';
            pfr.Core_MDF_Fund_Request_Status__c = 'Planned';
            pfr.Status ='Approved';
            pfr.amount  = 100.0;
            pfr.AllocationId = pfa.Id;
            pfr.Core_MDF_Reimbursement_Rate_pct__c ='100%';
            pfrToBeUpdated.add(pfr);
            
            Database.update(pfrToBeUpdated);
            
            PartnerFundClaim claim1 =  Core_MDF_CCP_IPA_TestDataUtility.createIPAClaim('IPA Claim',Core_MDF_CCP_IPA_TestDataUtility.claim_RecordType_IPA, pfr.Id, System.today().addDays(-20), System.today().addDays(-5),50.00, bank1.Id, false); 
            claim1.Core_MDF_Type_Txt__c ='Claim';
            claim1.Core_MDF_Currency__c='USD';
            claim1.Core_MDF_Campaign_Id__c = ipaCamp.Id;
            claim1.Core_MDF_VAT_Opt_In__c = 'Service Invoice to Intel (VAT may apply)';
            claim1.Core_MDF_VAT_Eligibility_Ind__c= true ; 
            claim1.Core_MDF_VAT_Hold_Ind__c = true;
            claim1.Core_MDF_To_Be_Audited_Ind__c = true;
            claim1.Core_MDF_Quarter_Year_txt__c = 'Q2-2023';
            claim1.Core_MDF_Paid_By_Payment_Type_nm__c = 'Non-Customer';
            insert claim1;
            
            claim1.Core_MDF_Status__c = 'Hold';
            update claim1;
            claimMap.put(claim1.title,claim1);
            Core_MDF_Claim_VAT_Info__c vatInfo = [select id,Core_MDF_VAT_Invoice_Number_Txt__c from Core_MDF_Claim_VAT_Info__c where Core_MDF_Claim_Id__c = : claim1.Id limit 1];
            vatInfo.Core_MDF_VAT_Invoice_Number_Txt__c = 'VATINV001';
            Database.update(vatInfo);

            claim1.Core_MDF_Status__c = 'Payment Due';
            Database.update(claim1);
            
            Core_MDF_Recovery__c recoveryRec = new Core_MDF_Recovery__c();
            recoveryRec.Core_MDF_Claim_Id__c = claim1.Id;
            recoveryRec.Core_MDF_Amount_Amt__c = 10.0;
            Insert recoveryRec;
        }
        
        System.runAs(ipaPayAdm){
            
            ChannelProgram cp1 = [Select Id,Name from ChannelProgram where Name ='Intel Partner Alliance' LIMIT 1];
            Core_MDF_Comarketing_CMF_Map__c cmfRec = [Select Id,Core_MDF_Account_Id__c,Core_MDF_Distribution_Channel_cd__c,Core_MDF_Sales_Org_cd__c,Core_MDF_Active_Ind__c,Core_MDF_Ship_To_Number_Id__c,Core_MDF_Sold_To_Number_Id__c  from Core_MDF_Comarketing_CMF_Map__c LIMIT 1];
            
            Map<Id,Core_MDF_Comarketing_CMF_Map__c> cmfMap = new MAp<Id,Core_MDF_Comarketing_CMF_Map__c>();
            cmfMap.put(cmfRec.Core_MDF_Account_Id__c,cmfRec);
            Core_MDF_Payment_Run__c ipaPayRunRecord = new Core_MDF_Payment_Run__c();
            ipaPayRunRecord.Core_MDF_ScheduleRun_Dtm__c= DateTime.Now().addMinutes(1);
            ipaPayRunRecord.Core_MDF_Geo_Txt__c = 'APJ';
            ipaPayRunRecord.Core_MDF_Start_Dt__c = System.today().addDays(-30);
            ipaPayRunRecord.Core_MDF_End_Dt__c = System.today().addDays(30);
            ipaPayRunRecord.Core_MDF_Program_Txt__c = 'Intel Partner Alliance';
            ipaPayRunRecord.Core_MDF_Program_Id__c = cp1.Id;
            ipaPayRunRecord.Core_MDF_Payment_Nature_nm__c = 'Expense' ;
            ipaPayRunRecord.RecordTypeId  = payRun_RecordType_IPAMDF;
            Database.insert(ipaPayRunRecord);                    
            //explicitly calling queryPaymentDueClaimsForPayment in PaymentUtility 
            List<Core_MDF_Payment_Run__c> paymentRecordList = new List<Core_MDF_Payment_Run__c>();
            paymentRecordList.add(ipaPayRunRecord);
           // Highlight: Unused Local Variable - Indira
           /* List<PartnerFundClaim> claims =*/ Core_MDF_PaymentUtility.queryPaymentDueClaimsForPayment(paymentRecordList);
            Core_MDF_Batch_PaymentFileGenerator paymentbatch = new Core_MDF_Batch_PaymentFileGenerator(ipaPayRunRecord);
            database.executebatch(paymentbatch,200);
            System.assertNotEquals(ipaPayRunRecord.Id,null);
            Map<String,Core_MDF_PaymentWrapper> grps = new Map<String,Core_MDF_PaymentWrapper>();
            
            Core_MDF_PaymentWrapper paymentWrapper = new Core_MDF_PaymentWrapper();
            paymentWrapper.claimsToBeProcessed = claimMap.values();
            paymentWrapper.sumOfClaimsAmount = 0;  
            paymentWrapper.sumOfConvertedAmount = 0;
            paymentWrapper.currencyExchangeRate = 0;
            grps.put('test',paymentWrapper);
            
            Core_MDF_PaymentFileWrapper paymentFileWrapper = new Core_MDF_PaymentFileWrapper();
            paymentFileWrapper.claimsToBeProcessed = claimMap.values();
            paymentFileWrapper.sumOfClaimsAmount = 100;  
            paymentFileWrapper.sumOfConvertedAmount = 0;
            paymentFileWrapper.geoLocation = '';
            paymentFileWrapper.subGeoLocation = '';
            paymentFileWrapper.currencyExchangeRate = 0;
            paymentFileWrapper.productCategory = '';
            paymentFileWrapper.quarterNum = '';
            paymentFileWrapper.fiscalYear = '';
            paymentFileWrapper.fyQuarterAndYear = '';
            paymentFileWrapper.paymentWrapperUniqueKey = '';
            paymentFileWrapper.totalVatAmt = 0;
            paymentFileWrapper.isVatEligible = true;
            paymentFileWrapper.totalConvertedVatAmt = 0;
            paymentFileWrapper.isCTypeInd=false;
            paymentFileWrapper.businessUnit = '';
            paymentFileWrapper.profitcenter = '';
            paymentFileWrapper.materialCode = '';
            paymentFileWrapper.isRecoveryIncluded = true;
            paymentFileWrapper.sumOfClaimsAmountExcludesRecovery = 50;
            paymentFileWrapper.includeOnlyClaimAmountForPayment = true;
            Map<String,Core_MDF_PaymentFileWrapper> paymentFileWrapperMap = new Map<String,Core_MDF_PaymentFileWrapper>();
            paymentFileWrapperMap.put('test',paymentFileWrapper);
            try{
                Core_MDF_Payment_FileHelper.generateIPAPaymentFileForExpense(paymentFileWrapperMap,ipaPayRunRecord,'Intel Partner Alliance');
            }catch(Exception e){
            }
            Core_MDF_Payment_FileHelper.generateHeader();
            Core_MDF_Payment_FileHelper.generateFooter();
            
            Core_MDF_Payment_FileHelper.generateIPAPaymentFileForCreditMemo(paymentFileWrapperMap,ipaPayRunRecord,'Intel Partner Alliance');
            Map<String,List<PartnerFundClaim>> paymentTypeToClaims= new Map<String,List<PartnerFundClaim>>();
            paymentTypeToClaims.put('Expense',claimMap.values());
            Core_MDF_PaymentProcessRetailMdfIPA.groupClaimsforPaymentFileRetailMDFIPA(claimMap.values(),ipaPayRunRecord, cmfMap, null);
            Core_MDF_PaymentProcessRetailMdfIPA.createPaymentWrapperMap(paymentFileWrapperMap,ipaPayRunRecord);
            Map<String,Map<String,Core_MDF_PaymentFileWrapper>> paymentTypeToFileWrapper= new Map<String,Map<String,Core_MDF_PaymentFileWrapper>>();
            paymentTypeToFileWrapper.put('Expense',paymentFileWrapperMap);
            Core_MDF_Batch_UpdatePaymentRunClaims batch = new Core_MDF_Batch_UpdatePaymentRunClaims(null, paymentFileWrapperMap,paymentTypeToFileWrapper, claimMap.values(), ipaPayRunRecord, null,paymentTypeToClaims,null, null);
            database.executebatch(batch,200);
            
        }
        Test.stopTest();
    }
}