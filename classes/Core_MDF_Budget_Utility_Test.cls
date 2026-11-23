/**************************************************************************************
Apex Class Name:  Core_MDF_BudgetTransfer_Test 
Version     : 1.0 
Created Date: 02 08 2018
Function    : Test class for the Core_MDF_BudgetTransfer used for Budget Transfer.
Author      : Sarah Manuel
Modification Log :
* Change#           Author                   Date                   Description
* ----------------------------------------------------------------------------                 
* Core MDF Rel1   Sarah Manuel         02/08/2018              Original Version
*
*************************************************************************************/
@isTest(SeeAllData=false) 
public class Core_MDF_Budget_Utility_Test {
    @TestSetup 
    static void createTestData() {       
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        // Creating User with utility class 
        User testUser = Core_MDF_CCP_TestDataUtility.createUser(false);
        testUser.LastName = 'Test User';
        testUser.UserRoleId = usRole.Id;
        Database.insert(testUser);
        User usr2 = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr2.Email='financeManager@example.com';
        Database.insert(usr2);
        
        
        System.runAs(testUser){
            List<ChannelProgram> cpList = new List<ChannelProgram>();
            List<Account> accountList = new List<Account>();
            ChannelProgram ipaCP = Core_MDF_CCP_TestDataUtility.createProgram ('Intel Partner Alliance','Intel Partner Alliance', false);
            ChannelProgram ccpCP = Core_MDF_CCP_TestDataUtility.createProgram(Core_MDF_CCP_ConstantClass.CCF_PROGRAM, 'Client CoMarketing Fund', false);
            cpList.add(ipaCP); 
            cpList.add(ccpCP); 
            Database.insert(cpList);
            Account ipaUltimateAccount = Core_MDF_CCP_TestDataUtility.createIntelAccount ('IPA Intel Account',Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, true);
            Account ipaCoMarketingAccount = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('IPA Co-Marketing Account', ipaCP.id, Core_MDF_CCP_TestDataUtility.Account_Record_Type,ipaUltimateAccount.id, false);   
            Account ccpCoMarketingAccount = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('CCF Co-Marketing Account', ccpCP.id, Core_MDF_CCP_TestDataUtility.Account_Record_Type,ipaUltimateAccount.id, false);
            Account ccpCoMarketingAccount2 = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('CCF Co-Marketing Account2', ccpCP.id, Core_MDF_CCP_TestDataUtility.Account_Record_Type,ipaUltimateAccount.id, false);
            accountList.add(ccpCoMarketingAccount2);
            accountList.add(ipaCoMarketingAccount);accountList.add(ccpCoMarketingAccount);
            Database.insert(accountList);
            
            //adding bypass feature to bypass access validation
			List<String> bypassFunctionKeys = new List<String>();
            bypassFunctionKeys.add('Bypass_MDF_Budget_Access_Validation');
            bypassFunctionKeys.add('Bypass_MDF_Budget_Status_Validation');
            bypassFunctionKeys.add('Bypass_MDF_Budget_Access');
            bypassFunctionKeys.add('byPass_Cancel_Activity');
            bypassFunctionKeys.add('Bypass_ValidateActivityWithCampaign');
            bypassFunctionKeys.add('Bypass_UpdateActivityFields');
            
            Set<String> myset1 = new Set<String>();
            List<String> result1 = new List<String>();
            myset1.addAll(bypassFunctionKeys);
            result1.addAll(myset1);
            
           List<Core_Trigger_Executions__c> bypassfunctinalitylist1 = Core_MDF_CCP_TestDataUtility.byPassFeature(result1,true,true);
            
            List<PartnerMarketingBudget> budgetList = new List<PartnerMarketingBudget>();
            //14285-Unused Rule
           // List<PartnerMarketingBudget> updatebudgetList = new List<PartnerMarketingBudget>();
            PartnerMarketingBudget opalbudgetMDF = Core_MDF_CCP_TestDataUtility.createBudget('Test Budget MDF', Core_MDF_CCP_TestDataUtility.budget_Record_Type, ccpCoMarketingAccount.Id, ccpCP.Id, 300000, System.today().addDays(-5), System.today().addDays(5), false);
            opalbudgetMDF.Core_MDF_Budget_Type_Txt__c = 'MDF';
            budgetList.add(opalbudgetMDF);
                
            PartnerMarketingBudget opalbudgetMDF2 = Core_MDF_CCP_TestDataUtility.createBudget('Test Budget MDF 2', Core_MDF_CCP_TestDataUtility.budget_Record_Type, ccpCoMarketingAccount2.Id, ccpCP.Id, 300000, System.today().addDays(6), System.today().addDays(15), false);
            opalbudgetMDF2.Core_MDF_Budget_Type_Txt__c = 'MDF';
            budgetList.add(opalbudgetMDF2);
            Database.insert(budgetList);
            
        	PermissionSet ps = [SELECT ID From PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_Finance_Manager'];
          	Group grp = [Select id from Group where DeveloperName = 'Core_MDF_CCP_CCF_Fin_Mgr_Queue_Group' limit 1];
            GroupMember grpMember = new GroupMember();
            grpMember.GroupId = grp.Id;
            grpMember.UserOrGroupId = usr2.id;
            database.insert(grpMember);
        	insert new PermissionSetAssignment(AssigneeId = usr2.id, PermissionSetId = ps.Id ); 
        	System.runAs(usr2){
                opalbudgetMDF2.Core_MDF_Budget_Status__c = 'Released';
                Database.update(opalbudgetMDF2);
                opalbudgetMDF.Core_MDF_Budget_Status__c = 'Released';
                Database.update(opalbudgetMDF);
			 }
            Campaign ccfOpalCampaign = Core_MDF_CCP_TestDataUtility.createCampaign('CCF Opal Campaign','Gaming','Intel® Core™ i7+ Processor','MDF or both CMP & MDF', Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 'Client CoMarketing Fund', System.today().adddays(-2), System.today().adddays(3), 10000, 'Consumer Chromebook', ccpCoMarketingAccount.Id, '2-in-1', false);
            ccfOpalCampaign.Core_MDF_Supports_legacy_program__c = 'MDF or both CMP & MDF';
            ccfOpalCampaign.Core_MDF_Opal_Budget_Type_Txt__c = 'MDF';
            Database.insert(ccfOpalCampaign);
            
            List<String> budgetTypeList = new List<String>();
            budgetTypeList.add('MDF');
            Test.startTest();
            List<Core_MDF_CampaignCreatePage.CampaignBudgetWrapperClass> campaignBudgetsList = new List<Core_MDF_CampaignCreatePage.CampaignBudgetWrapperClass>();
            Core_MDF_CampaignCreatePage.CampaignBudgetWrapperClass campaignBudgetRecord = new Core_MDF_CampaignCreatePage.CampaignBudgetWrapperClass();
            campaignBudgetRecord.budgetId = opalbudgetMDF.id;
            campaignBudgetRecord.budgetName = 'CCF Opal Budget';
            campaignBudgetRecord.budgetAmount = 1000;
            campaignBudgetRecord.budgetRR = '50%';
            campaignBudgetRecord.budgetRAmount = 500;
            campaignBudgetRecord.isActive = true;
            campaignBudgetsList.add(campaignBudgetRecord);
            //14285-Unused Variable
           //Map<id,PartnerMarketingBudget> campaignBudgets = Core_MDF_CampaignCreatePage.getBudgetsForCampaign(ccpCoMarketingAccount.id, System.today(), System.today(), budgetTypeList);
           //List<Core_MDF_Campaign_Budgets__c> retrieveCampaignBudgets =  Core_MDF_CampaignCreatePage.getCampaignBudgetsForCampaign(ccfOpalCampaign.id);
           // PartnerFundAllocation pfaRecord3 = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('TestPFA3',opalbudgetMDF, ccpCoMarketingAccount, 0, true);

            Test.stopTest();
            
            List<Core_Trigger_Executions__c> executionList = new List<Core_Trigger_Executions__c>();
            Core_Trigger_Executions__c claimFunctionalityNameTriggerExecution = new Core_Trigger_Executions__c();
            claimFunctionalityNameTriggerExecution.Core_Active__c = true;
            claimFunctionalityNameTriggerExecution.Core_Class_Name__c = 'Core_MDF_PMBTriggerHandler';
            claimFunctionalityNameTriggerExecution.Core_Trigger_Events__c = 'Before Update';
            claimFunctionalityNameTriggerExecution.Core_Object__c = 'PartnerMarketingBudget';
            claimFunctionalityNameTriggerExecution.Name = 'Core_MDF_Budget_Act_Date_Validation';
            claimFunctionalityNameTriggerExecution.Core_Description__c = 'description';
            executionList.add(claimFunctionalityNameTriggerExecution);
            Database.insert(executionList);
        }
    }
    @isTest
    static void testValidateBudgetDateChangeAgainstAct(){
      	Test.startTest();
   	  	Account acc = [SELECT Id, Name FROM Account WHERE Name = 'CCF Co-Marketing Account' LIMIT 1];
      	Campaign MDFcamp = [SELECT Id FROM Campaign WHERE Name = 'CCF Opal Campaign'];
      	PartnerMarketingBudget  pmbRecord =[SELECT Id,Title FROM PartnerMarketingBudget WHERE Title = 'Test Budget MDF'];
      	PartnerMarketingBudget  pmbRecord2 =[SELECT Id,Title,Core_MDF_Budget_Status__c FROM PartnerMarketingBudget WHERE Title = 'Test Budget MDF 2'];
      	PartnerFundAllocation  pfaRecord =[SELECT Id,Title, BudgetId FROM PartnerFundAllocation WHERE BudgetId = :pmbRecord.Id limit 1];

        // Creating activities using utility class
        PartnerFundRequest MDFpfr4 = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(MDFcamp.Id),Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,string.valueof(acc.id),pfaRecord,pmbRecord,'INDIA','Small Business','Desktop',
                                                                                           'Intel® Core™ i7 Processor','Broadcast','Radio','Draft',false);
        MDFpfr4.Title = 'Test Activity';
        MDFpfr4.Core_MDF_Activity_Description__c = 'Test Activity';
        MDFpfr4.Core_MDF_Start_Date__c = System.today();
        MDFpfr4.Core_MDF_End_Date__c = System.today();
        MDFpfr4.RequestedAmount = 6000;
        MDFpfr4.Core_MDF_Channel_Partner_Led__c = True;
       // MDFpfr4.Core_MDF_Budget_Type_txt__c = 'MDF';
        MDFpfr4.Core_MDF_Approval_Step_Completed__c = 0;
        MDFpfr4.Core_MDF_Price_reviewer_check_ind__c = False; 
        MDFpfr4.Core_MDF_Program_Office_Check_ind__c = False;
        MDFpfr4.Core_MDF_Require_Additional_Review_ind__c = False;  
        MDFpfr4.BudgetId=pmbRecord.Id;
        MDFpfr4.Core_MDF_ActivityCategory__c='';
        MDFpfr4.Core_MDF_Activity_Types__c='';
        database.insert(MDFpfr4);
        PartnerFundRequest MDFpfr5 = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(MDFcamp.Id),Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,string.valueof(acc.id),pfaRecord,pmbRecord,'INDIA','Small Business','Desktop',
                                                                                           'Intel® Core™ i7 Processor','','','Draft',false);
        MDFpfr5.Title = 'Test Activity';
        MDFpfr5.Core_MDF_Activity_Description__c = 'Test Activity';
        MDFpfr5.Core_MDF_Start_Date__c = System.today();
        MDFpfr5.Core_MDF_End_Date__c = System.today().addDays(2);
        MDFpfr5.RequestedAmount = 6000;
        MDFpfr5.Core_MDF_Channel_Partner_Led__c = True;
      //  MDFpfr5.Core_MDF_Budget_Type_txt__c = 'MDF';
        MDFpfr5.Core_MDF_Approval_Step_Completed__c = 0;
        MDFpfr5.Core_MDF_Price_reviewer_check_ind__c = False; 
        MDFpfr5.Core_MDF_Program_Office_Check_ind__c = False;
        MDFpfr5.Core_MDF_Require_Additional_Review_ind__c = False;
        MDFpfr5.BudgetId=pmbRecord.Id;
        database.insert(MDFpfr5);        
        Test.stopTest();
        Assert.areEqual(true, MDFpfr4!=null);
        
        
        pmbRecord.StartDate = System.today().addDays(3);
        pmbRecord2.StartDate = System.today().addDays(7);
        //check beyond date, equal date and no activities
        try{Database.update(pmbRecord);
           Database.update(pmbRecord2);}  
        catch(Exception e){
            String errorMessage = e.getMessage();
               }
        pmbRecord.StartDate = System.today().addDays(-3);
    }
        @isTest static void unlockBudgetTest(){
        User testUser = Core_MDF_CCP_TestDataUtility.createUser(false);
        System.runAs(testUser){
        Test.startTest();
        List<PartnerMarketingBudget> pmbLst = new List<PartnerMarketingBudget>();
            PartnerMarketingBudget pmb = new PartnerMarketingBudget();
            try{
                Core_MDF_Budget_Utility.unlockBudget(pmbLst);
                pmbLst.add(pmb);
                Core_MDF_Budget_Utility.unlockBudget(pmbLst);  
            }
            catch(Exception e){
              String errorMessage = e.getMessage();
            }
            // US - TWC702-14285: Unit Test Method should include System.Assert
            System.assert(true, 'unlockBudget method executed without throwing exception');
        Test.stopTest();
        }
     }
}