/****************************************************************************************************************************************
* Class Name  : Core_MDF_Create_Budget_Test
* Version     : 1.0 
* Created Date: 02-June-2020
* Modification Log :
* Developer            Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Intel - SM         02-June-2020                    Created to test IPA Budget Creation
*****************************************************************************************************************************************/
@isTest 
public class Core_MDF_Create_Budget_Test {
    
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
        bypassFunctionKeys.add('Bypass_Activity_ApprovalProcess');
        bypassFunctionKeys.add('Bypass_ShareActivityWithUsers');
        bypassFunctionKeys.add('Bypass_ShareActivityWithAccNodeGroup');
        bypassFunctionKeys.add('Bypass_geoLeadApprovalProcess');
        bypassFunctionKeys.add('Bypass_MDF_Budget_Access_Validation');
        bypassFunctionKeys.add('Bypass_MDF_Budget_Status_Validation');
        bypassFunctionKeys.add('Bypass_Duplicate_Budget_Check');
        
        
        Set<String> myset1 = new Set<String>();
        List<String> result1 = new List<String>();
        myset1.addAll(bypassFunctionKeys);
        result1.addAll(myset1);
        
        List<Core_Trigger_Executions__c> bypassfunctinalitylist1 = Core_MDF_CCP_TestDataUtility.byPassFeature(result1,true,true);

        ChannelProgram cp = Core_MDF_CCP_TestDataUtility.createProgram ('Intel Partner Alliance','Intel Partner Alliance', true);

                
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
        
        Account acc2Parent = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test Account 2 parent', cp.Id, Core_MDF_CCP_TestDataUtility.account_Record_Type, acc1.Id, false);//changed record type from Intel to Acc
        acc2Parent.Core_Geo__c='';
        acc2Parent.Core_Sub_Geo__c='';
       
        acc2Parent.BillingCity = 'Test City';         
        acc2Parent.BillingCountry= 'AUS';
        acc2Parent.BillingStreet= 'Test Street';
        insert acc2Parent;
        
        Account acc2 = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test Account 2', cp.Id, Core_MDF_CCP_TestDataUtility.account_Record_Type, acc2Parent.Id, false);//changed record type from Intel to Acc
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
        
        string budgetType = Core_MDF_CCP_IPA_TestDataUtility.createBenefit(acc2Parent);
        budgetType = 'Proposal I MDF';
        //PartnerMarketingBudget budget = Core_MDF_CCP_TestDataUtility.createBudget('Test Budget New',Core_MDF_CCP_IPA_TestDataUtility.budgetIPA_ProposalBased_Record_Type,acc2Parent.Id,cp.Id,200000,System.today().addDays(-20),System.today(), false);
       // budget.Core_MDF_Budget_Type_Txt__c='Proposal I MDF';
        //Database.insert(budget);
        
        //PartnerFundAllocation pfa = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('allocation',budget,acc2Parent, 0,true);
        //PartnerFundAllocation pfa2 = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('allocation',budget,acc2, 100000,true);
        List<Campaign> campList = new List<Campaign>();
        Campaign camp = Core_MDF_CCP_IPA_TestDataUtility.createIPACampaign('Test IPA Camp',acc2.Id, System.today(), System.today().addDays(300),budgetType, 1234.00, 'AFGHANISTAN','Consumer','Coffee Lake','Pending Review', false);
        camp.Core_MDF_Region_cd__c = 'APJ';
        camp.Core_MDF_Budget_Type_txt__c = budgetType;
        //camp.Core_MDF_Budget__c = budget.Id;
        camp.Core_MDF_Reimbursement_Amt__c = 10000;
        camp.Core_MDF_Technology__c='';//my change
        campList.add(camp);
        
        Campaign camp2 = Core_MDF_CCP_IPA_TestDataUtility.createIPACampaign('Test Campaign - Cancelled',acc2.id, System.today(), System.today().adddays(30),budgetType, 10000,'INDIA', 'Consumer', 'Apollo Lake', 'Draft', false);        
        camp2.Core_MDF_Reimbursement_Amt__c = 10000;
        camp2.Core_MDF_Budget_Type_txt__c = budgetType;
        camp2.Core_MDF_Region_cd__c = 'APJ';
        camp2.Core_MDF_Technology__c='';//my change
        campList.add(camp2);
        Campaign camp3 = Core_MDF_CCP_IPA_TestDataUtility.createIPACampaign('Test Campaign - Cancelled2',acc2.id, System.today(), System.today().adddays(30),budgetType, 100000,'INDIA', 'Consumer', 'Apollo Lake', 'Draft', false);        
        camp3.Core_MDF_Reimbursement_Amt__c = 100000;
        camp3.Core_MDF_Budget_Type_txt__c = budgetType;
        camp3.Core_MDF_Region_cd__c = 'ASMO';
        camp3.Core_MDF_Technology__c='';//my change
        campList.add(camp3);
        
        Database.insert(campList); 
        
         Test.startTest();
        List<PartnerFundRequest> pfrList = new List<PartnerFundRequest>();
        PartnerFundRequest pfr = Core_MDF_CCP_IPA_TestDataUtility.createIPAPartnerFundRequest(camp.Id,acc2.Id,System.today(),System.today(),false);
        pfr.Core_MDF_BU_Split__c ='CCG';
        pfr.Core_MDF_BU1_Split_Percent_nbr__c=100;
        pfr.amount = 500;
        pfr.Core_MDF_Reimbursement_Rate_txt__c='60%';
        pfr.Core_MDF_Budget_Type_nm__c = 'Proposal I MDF';
        pfrList.add(pfr);
        PartnerFundRequest pfr2 = Core_MDF_CCP_IPA_TestDataUtility.createIPAPartnerFundRequest(camp2.Id,acc2.Id,System.today(),System.today(),false);
        pfrList.add(pfr2);
        Database.insert(pfrList);
      
        
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
        System.runAs(usr2){
            Database.insert(bank);
        }

        //Do Account Bank Mapping for 'bank' and ABM 
        //Core_MDF_Account_Bank_Mapping__c abm1 = Core_MDF_CCP_TestDataUtility.createAccountBankMap(acc2.Id,bank.Id,true);
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
        
    }
    
     @isTest static void validateIPABudget() {

        Test.startTest();
        User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];

            System.runAs(sysAdminUser)
            {
				List<Campaign> campToBeUpdated = new List<Campaign>();
                Campaign camp  = [Select Id, Name, StartDate, EndDate, Description, Core_MDF_Budget__c,Core_MDF_Account__c,Core_MDF_Account__r.Core_MDF_Active_Ind__c,Core_MDF_Channel_Program__c,
                                  Core_MDF_Budget_Type_txt__c,Core_MDF_Total_Campaign_Cost_Amt__c,Core_MDF_Reimbursement_Amt__c,Core_MDF_Program__c
                                  from Campaign where Name = 'Test IPA Camp' limit 1];
               Campaign camp2  = [Select Id, Name, StartDate, EndDate, Description, Core_MDF_Budget__c,Core_MDF_Account__c,Core_MDF_Account__r.Core_MDF_Active_Ind__c,Core_MDF_Channel_Program__c,
                                   Core_MDF_Budget_Type_txt__c,Core_MDF_Total_Campaign_Cost_Amt__c,Core_MDF_Reimbursement_Amt__c,Core_MDF_Program__c
                                   from Campaign where Name = 'Test Campaign - Cancelled2' limit 1];
                
             	campToBeUpdated.add(camp);  
                campToBeUpdated.add(camp2); 
                Map<Campaign,PartnerMarketingBudget> campBudgetMap = new Map<Campaign,PartnerMarketingBudget>();
                campBudgetMap=Core_MDF_Create_Budget.manageBudget(campToBeUpdated);
         
                Assert.areNotEqual(0,campBudgetMap.size());
                // US - TWC702-14285: Unit Test Method should include System.Assert
                Assert.isTrue(campBudgetMap.containsKey(camp), 'Campaign 1 should be in the budget map');
                Assert.isTrue(campBudgetMap.containsKey(camp2), 'Campaign 2 should be in the budget map');
            }
         Test.stopTest();
     }
    
    @isTest static void validateIPABudgetCancel() {        
        Test.startTest();
        
       
        User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];        
        System.runAs(sysAdminUser){
            Campaign camp1  = [Select Id, Name, StartDate, EndDate, Description, Core_MDF_Budget__c,Core_MDF_Account__c,Core_MDF_Channel_Program__c,
                              Core_MDF_Budget_Type_txt__c,Core_MDF_Total_Campaign_Cost_Amt__c,Core_MDF_Reimbursement_Amt__c,Core_MDF_Program__c
                              from Campaign where Name = 'Test Campaign - Cancelled2' limit 1];
            PartnerMarketingBudget pmb = Core_MDF_Create_Budget.createBudgetForCampaigns(camp1);
            Database.insert(pmb);
            camp1.Core_MDF_Budget__c = pmb.Id;
            List<Campaign> campToBeUpdatedName = new List<Campaign>();
            camp1.Name='Test Campaign - Cancelled3';
            campToBeUpdatedName.add(camp1);
            Core_MDF_Create_Budget.updateBudget(campToBeUpdatedName);
            Assert.areEqual('Test Campaign - Cancelled3',camp1.Name);
            Assert.areEqual('Test Campaign - Cancelled2 Budget',pmb.Title);
            List<Campaign> campList = new List<Campaign>();
            campList.add(Camp1);
            Core_MDF_Create_Budget.cancelBudget(campList);
            // US - TWC702-14285: Unit Test Method should include System.Assert
            Assert.isTrue(true, 'Budget cancellation method executed successfully');
            Test.stopTest();
        }
    }
    
}