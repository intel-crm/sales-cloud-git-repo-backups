@IsTest
public class Core_MDF_Activity_Controller_Test {
    
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
        Core_MDF_Activity_Outcome__c activityOutcome = new Core_MDF_Activity_Outcome__c(
            Core_MDF_Activity_Id__c	 = pfr.Id,
            Core_MDF_Outcome_Metric_nm__c = 'Revenue - Billings',
            Core_MDF_Goal_Value_nbr__c = 200,
            Core_MDF_Baseline_Value_nbr__c = 190,
            Core_MDF_Baseline_Period_nm__c = 'Same period as this campaign, one year before',
            Core_MDF_Active_Ind__c = true
        );
        insert activityOutcome;
        
        
        Test.stopTest();
        
    }  
    @IsTest
    static void testGetAndSaveActivityOutcomes() {
        PartnerFundRequest pfr = [SELECT Id FROM PartnerFundRequest WHERE Amount = 500 LIMIT 1];
        
        Core_MDF_Activity_Outcome__c accout = [SELECT Id, Core_MDF_Outcome_Metric_nm__c, Core_MDF_Active_Ind__c, Core_MDF_Baseline_Value_nbr__c,Core_MDF_Goal_Value_nbr__c, Core_MDF_Result_Value_nbr__c, Core_MDF_Baseline_Period_nm__c, 
                                               Core_MDF_Activity_Id__c
                                               FROM Core_MDF_Activity_Outcome__c 
                                               WHERE Core_MDF_Activity_Id__c = :pfr.Id
                                               AND Core_MDF_Active_Ind__c = TRUE];
        Core_MDF_Activity_Purpose_Controller.getActivityOutcomes(pfr.Id);
        Core_MDF_Activity_Purpose_Controller.ActivityOutcomeWrapper w = new Core_MDF_Activity_Purpose_Controller.ActivityOutcomeWrapper();
        w.outcomeMetric = 'Revenue - Billings';
        w.goalValue = '200';
        w.baselineValue = '190';
        w.baseLinePeriod = 'Same period as this campaign, one year before';
        w.resultValue = null;     // optional
        w.Description = 'Test description';
        
        List<Core_MDF_Activity_Purpose_Controller.ActivityOutcomeWrapper> valuesToSend = new List<Core_MDF_Activity_Purpose_Controller.ActivityOutcomeWrapper>{ w };
        Core_MDF_Activity_Purpose_Controller.saveActivityOutcome(pfr.Id, valuesToSend);
    }
    
}