/******************************************************************************************************************************************
Class Name:  Core_Opp_FC_HandlerTest
Version     : 1.0 
Created Date: 27 Mar 2021
Function    : Test class of Core_Opp_FC_Handler
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------        
* Sougata Sarkar            03/27/2021             Original Version
********************************************************************************************************************************************/
@isTest
public class Core_Opp_FC_HandlerTest {

    public static List<Core_Trigger_Executions__c> triggExecList = new List<Core_Trigger_Executions__c>();
    public static List<Core_FC_Commission_Criterias__c> fcCommsnCriteriaList = new List<Core_FC_Commission_Criterias__c>();
    public static List<Core_Commissions_Percent_Contribution__c> comsnPrcntList = new List<Core_Commissions_Percent_Contribution__c>();
    public static List<Opportunity> opptyList = new List<Opportunity>();
    public static List<OpportunityLineItem> oliTestList = new List<OpportunityLineItem>();
    public static List<Core_Opp_FC_Prod_Schedule__c> insertForeCastList = new List<Core_Opp_FC_Prod_Schedule__c>();
    public static List<Product2> testProducts = new List<Product2>();
    public static List<PricebookEntry> testPBEs = new List<PricebookEntry>();
    public static List<Core_Opp_FC_Prod_Schedule__c> foreCastList = new List<Core_Opp_FC_Prod_Schedule__c>();
    public static List<User> sysAdminList = new List<User>();
    
    static void getTriggerExecutionPopulated(){
        triggExecList.add(new Core_Trigger_Executions__c(Name='opportunityLineItemAfterHandler', Core_Class_Name__c='Test', Core_Object__c='Test',Core_Trigger_Events__c='Test', Core_Active__c=true, Core_Description__c = 'Test'));
        triggExecList.add(new Core_Trigger_Executions__c(Name='insertForecast', Core_Class_Name__c='Test', Core_Object__c='Test',Core_Trigger_Events__c='Test', Core_Active__c=true, Core_Description__c = 'Test'));
        triggExecList.add(new Core_Trigger_Executions__c(Name='updateForecast', Core_Class_Name__c='Test', Core_Object__c='Test',Core_Trigger_Events__c='Test', Core_Active__c=true, Core_Description__c = 'Test'));
        triggExecList.add(new Core_Trigger_Executions__c(Name='trackOpportunityProductHistory', Core_Class_Name__c='Test', Core_Object__c='Test',Core_Trigger_Events__c='Test', Core_Active__c=true, Core_Description__c = 'Test'));
        triggExecList.add(new Core_Trigger_Executions__c(Name='deleteForecast', Core_Class_Name__c='Test', Core_Object__c='Test',Core_Trigger_Events__c='Test', Core_Active__c=true, Core_Description__c = 'Test'));
        triggExecList.add(new Core_Trigger_Executions__c(Name='UpdateTerritoryInfoOnOppty', Core_Class_Name__c='Test', Core_Object__c='Test',Core_Trigger_Events__c='Test', Core_Active__c=true, Core_Description__c = 'Test'));
        triggExecList.add(new Core_Trigger_Executions__c(Name='determineApprovers', Core_Class_Name__c='Test', Core_Object__c='Test',Core_Trigger_Events__c='Test', Core_Active__c=true, Core_Description__c = 'Test'));
        triggExecList.add(new Core_Trigger_Executions__c(Name='updateProductLineItems', Core_Class_Name__c='Test', Core_Object__c='Test',Core_Trigger_Events__c='Test', Core_Active__c=true, Core_Description__c = 'Test'));
        triggExecList.add(new Core_Trigger_Executions__c(Name='opportunityStageUpdate', Core_Class_Name__c='Test', Core_Object__c='Test',Core_Trigger_Events__c='Test', Core_Active__c=true, Core_Description__c = 'Test'));
        triggExecList.add(new Core_Trigger_Executions__c(Name='forecastUpdateFromOppty', Core_Class_Name__c='Test', Core_Object__c='Test',Core_Trigger_Events__c='Test', Core_Active__c=true, Core_Description__c = 'Test'));
        triggExecList.add(new Core_Trigger_Executions__c(Name='beforeFCUpdate', Core_Class_Name__c='Test', Core_Object__c='Test',Core_Trigger_Events__c='Test', Core_Active__c=true, Core_Description__c = 'Test'));
        triggExecList.add(new Core_Trigger_Executions__c(Name='afterFCUpdate', Core_Class_Name__c='Test', Core_Object__c='Test',Core_Trigger_Events__c='Test', Core_Active__c=true, Core_Description__c = 'Test'));
        triggExecList.add(new Core_Trigger_Executions__c(Name='forecastCommissionCreate', Core_Class_Name__c='Test', Core_Object__c='Test',Core_Trigger_Events__c='Test', Core_Active__c=true, Core_Description__c = 'Test'));
        insert triggExecList;
        
        fcCommsnCriteriaList.add(new Core_FC_Commission_Criterias__c(Name='FCCMSN01', Core_BU_Focus__c='any', Core_Account_Tier__c='DCG-Tier 2', Core_Opportunity_Type__c='Deal: Sell-to', Core_Schedule_Quarter_Start_Date__c=date.today().addMonths(-3), Core_Schedule_Quarter_End_Date__c=date.today().addMonths(3)));
        fcCommsnCriteriaList.add(new Core_FC_Commission_Criterias__c(Name='FCCMSN02', Core_BU_Focus__c='DCG-Cloud', Core_Account_Tier__c='any', Core_Opportunity_Type__c='Deal: Sell-to', Core_Schedule_Quarter_Start_Date__c=date.today().addMonths(-3), Core_Schedule_Quarter_End_Date__c=date.today().addMonths(3)));
        fcCommsnCriteriaList.add(new Core_FC_Commission_Criterias__c(Name='FCCMSN03', Core_BU_Focus__c='any', Core_Account_Tier__c='DCG-Tier 2', Core_Opportunity_Type__c='Deal: Sell-to', Core_Schedule_Quarter_Start_Date__c=date.today().addMonths(-3), Core_Schedule_Quarter_End_Date__c=date.today().addMonths(3)));
        fcCommsnCriteriaList.add(new Core_FC_Commission_Criterias__c(Name='FCCMSN04', Core_BU_Focus__c='any', Core_Account_Tier__c='any', Core_Opportunity_Type__c='Deal: Sell-to', Core_Schedule_Quarter_Start_Date__c=date.today().addMonths(-3), Core_Schedule_Quarter_End_Date__c=date.today().addMonths(3)));
        fcCommsnCriteriaList.add(new Core_FC_Commission_Criterias__c(Name='FCCMSN05', Core_BU_Focus__c='DCG-Cloud', Core_Account_Tier__c='DCG-Tier 2', Core_Opportunity_Type__c='Deal: Sell-to', Core_Schedule_Quarter_Start_Date__c=date.today().addMonths(-3), Core_Schedule_Quarter_End_Date__c=date.today().addMonths(3)));
        fcCommsnCriteriaList.add(new Core_FC_Commission_Criterias__c(Name='FCCMSN06', Core_BU_Focus__c='any', Core_Account_Tier__c='any', Core_Opportunity_Type__c='Deal: Sell-to', Core_Schedule_Quarter_Start_Date__c=date.today().addMonths(-3), Core_Schedule_Quarter_End_Date__c=date.today().addMonths(3)));
        fcCommsnCriteriaList.add(new Core_FC_Commission_Criterias__c(Name='FCCMSN07', Core_BU_Focus__c='any', Core_Account_Tier__c='any', Core_Opportunity_Type__c='Deal: Sell-to', Core_Schedule_Quarter_Start_Date__c=date.today().addMonths(-3), Core_Schedule_Quarter_End_Date__c=date.today().addMonths(3)));
        fcCommsnCriteriaList.add(new Core_FC_Commission_Criterias__c(Name='FCCMSN08', Core_BU_Focus__c='DCG-Cloud', Core_Account_Tier__c='DCG-Tier 2', Core_Opportunity_Type__c='Deal: Sell-to', Core_Schedule_Quarter_Start_Date__c=date.today().addMonths(-3), Core_Schedule_Quarter_End_Date__c=date.today().addMonths(3)));
        fcCommsnCriteriaList.add(new Core_FC_Commission_Criterias__c(Name='FCCMSN09', Core_BU_Focus__c='any', Core_Account_Tier__c='DCG-Tier 2', Core_Opportunity_Type__c='Deal: Sell-to', Core_Schedule_Quarter_Start_Date__c=date.today().addMonths(-3), Core_Schedule_Quarter_End_Date__c=date.today().addMonths(3)));
        insert fcCommsnCriteriaList;
        
        comsnPrcntList.add(new Core_Commissions_Percent_Contribution__c(Name='Opportunity Owner', Core_Percent_Contribution__c=100));
        comsnPrcntList.add(new Core_Commissions_Percent_Contribution__c(Name='Technical Owner', Core_Percent_Contribution__c=100));
        comsnPrcntList.add(new Core_Commissions_Percent_Contribution__c(Name='Team Member', Core_Percent_Contribution__c=100));
        comsnPrcntList.add(new Core_Commissions_Percent_Contribution__c(Name='Viewer', Core_Percent_Contribution__c=0));
        insert comsnPrcntList;
    }
    
    @testSetup
    static void setupData(){
        
        getTriggerExecutionPopulated();
        sysAdminList =  [SELECT Id, Name FROM User WHERE isActive = TRUE AND Core_Employee_Type_Code__c = 'EMP' AND Profile.Name = 'Sales Rep-BB' AND ManagerId != '' AND Manager.DelegatedApproverId != '' AND Core_User_Type__c != 'External User' LIMIT 1];
        Id newAccountRecTypeId = [select Id from RecordType where DeveloperName = 'Mastered_Account' limit 1][0].Id;
        Account acct;
        System.runAs(Core_Test_Utility.systemAdminUser){  
        //System.runAs(sysAdminList[0]){
            acct = new Account(Name = 'Test Account territory', BillingStreet = '123 Fake St', Core_Account_Tier__c = 'DCG-Tier 2; CCG-Tier 1', Core_Account_BU_Focus__c = 'DCG-Cloud',
                                           BillingCity = 'Springfield', BillingState = 'IL', BillingCountry = 'USA', Core_Sales_Groups__c='Americas Brazil Sales Group',
                                           BillingPostalCode = '12345', Industry ='Agriculture', Core_Sub_Industry__c='Forestry', Core_Account_Primary_Coverage__c='Intel Covered');
            insert acct;
        }
        
        Id newOppRecTypeId = [select Id from RecordType where DeveloperName = 'Core_New_Opportunity' limit 1][0].Id;
        Profile p = [SELECT id, Name FROM Profile WHERE Name='Sales Rep-BB'];
        User usr = [SELECT id, Name, isActive FROM User WHERE ProfileId = :p.Id AND isActive = true LIMIT 1];
        
        System.runAs(Core_Test_Utility.systemAdminUser){  
        //System.runAs(sysAdminList[0]){
            opptyList.add(new Opportunity(Name = 'Test Opportunity1', RecordTypeId = newOppRecTypeId, Core_Commissionable__c = 'Yes', Core_Exclude_From_KPIs__c = false,
                AccountId = acct.Id, StageName = 'Qualify', CloseDate = System.Date.today().addYears(1), Core_Technical_Owner__c = sysAdminList[0].Id, Core_Sales_Group__c='Global Accounts', Core_Opportunity_Type__c='Deal: Sell-to', Core_Product_Segment__c='Data Center Computing', Core_Product_Application__c = 'Storage', Core_Consumption_Market__c = 'Education',Core_Intel_Platform__c='AGILEX', Core_First_Customer_Ship_Date__c= System.Date.today().addMonths(8), Core_Solution_Area__c='DCG Compute Deal $'));
            opptyList.add(new Opportunity(Name = 'Test Opportunity2', RecordTypeId = newOppRecTypeId, Core_Commissionable__c = 'Yes', Core_Exclude_From_KPIs__c = false,
                AccountId = acct.Id, StageName = 'Qualify', CloseDate = System.Date.today().addYears(1), Core_Technical_Owner__c = sysAdminList[0].Id, Core_Sales_Group__c='Regional Sales', Core_Opportunity_Type__c='Deal: Sell-to', Core_Product_Segment__c='Data Center Computing', Core_Product_Application__c = 'Storage', Core_Consumption_Market__c = 'Education',Core_Intel_Platform__c='AGILEX', Core_First_Customer_Ship_Date__c= System.Date.today().addMonths(8), Core_Solution_Area__c='DCG Compute Deal $'));
            opptyList.add(new Opportunity(Name = 'Test Opportunity3', RecordTypeId = newOppRecTypeId, Core_Commissionable__c = 'Yes', Core_Exclude_From_KPIs__c = false,
                AccountId = acct.Id, StageName = 'Define', CloseDate = System.Date.today().addYears(1), Core_Technical_Owner__c = sysAdminList[0].Id, Core_Sales_Group__c='Regional Sales', Core_Opportunity_Type__c='Deal: Sell-to', Core_Product_Segment__c='Data Center Computing', Core_Product_Application__c = 'Storage', Core_Consumption_Market__c = 'Education',Core_Intel_Platform__c='AGILEX', Core_First_Customer_Ship_Date__c= System.Date.today().addMonths(8), Core_Solution_Area__c='DCG Compute Deal $'));
            insert opptyList;
        }
        
        testProducts = Core_Test_Utility.createProduct(3);
        insert testProducts;
        
        testPBEs = Core_Test_Utility.createPriceBookEntry(3, testProducts, Test.getStandardPricebookId());
        insert testPBEs;
        System.runAs(Core_Test_Utility.systemAdminUser){
            oliTestList.add(new OpportunityLineItem(OpportunityId = opptyList[0].Id, PricebookEntryId= testPBEs[0].Id, Description = 'Test 11', UnitPrice=11, Quantity=2000, Core_Loss_Cancel_Reason__c = null, Core_Status__c='Pending', Core_Approved_KPI_Product_Group__c='test', CRM_DW_App_UCD_Customer_Name__c='test', Core_Opp_Approved_Sales_Group__c='test'));
            oliTestList.add(new OpportunityLineItem(OpportunityId = opptyList[1].Id, PricebookEntryId= testPBEs[1].Id, Description = 'Test 11', UnitPrice=11, Quantity=2345, Core_Loss_Cancel_Reason__c = null, Core_Status__c='Pending', Core_Approved_KPI_Product_Group__c='test', CRM_DW_App_UCD_Customer_Name__c='test', Core_Opp_Approved_Sales_Group__c='test'));
            oliTestList.add(new OpportunityLineItem(OpportunityId = opptyList[1].Id, PricebookEntryId= testPBEs[1].Id, Description = 'Test 11', UnitPrice=11, Quantity=123, Core_Loss_Cancel_Reason__c = null, Core_Status__c ='Pending', Core_Approved_KPI_Product_Group__c='test', CRM_DW_App_UCD_Customer_Name__c='test', Core_Opp_Approved_Sales_Group__c='test')); 
            oliTestList.add(new OpportunityLineItem(OpportunityId = opptyList[2].Id, PricebookEntryId= testPBEs[2].Id, Description = 'Test 11', UnitPrice=11, Quantity=1230, Core_Loss_Cancel_Reason__c = null, Core_Status__c = 'Pending', Core_Approved_KPI_Product_Group__c='test', CRM_DW_App_UCD_Customer_Name__c='test', Core_Opp_Approved_Sales_Group__c='test'));                 
            oliTestList.add(new OpportunityLineItem(OpportunityId = opptyList[2].Id, PricebookEntryId= testPBEs[1].Id, Description = 'Test 11', UnitPrice=20, Quantity=11000, Core_Loss_Cancel_Reason__c = null, Core_Status__c = 'Pending', Core_Approved_KPI_Product_Group__c='test', CRM_DW_App_UCD_Customer_Name__c='test', Core_Opp_Approved_Sales_Group__c='test')); 
            oliTestList.add(new OpportunityLineItem(OpportunityId = opptyList[2].Id, PricebookEntryId= testPBEs[2].Id, Description = 'Test 11', UnitPrice=20, Quantity=11000, Core_Loss_Cancel_Reason__c = null, Core_Status__c = 'Pending', Core_Approved_KPI_Product_Group__c='test', CRM_DW_App_UCD_Customer_Name__c='test', Core_Opp_Approved_Sales_Group__c='test'));  
            insert oliTestList;
        }        
        insertForeCastList.add(new Core_Opp_FC_Prod_Schedule__c(Core_Opp_FC_Opportunity__c = opptyList[0].Id, Core_Opp_Line_Item_RecordID__c = oliTestList[1].Id, Core_Opp_FC_Product__c = oliTestList[0].Product2Id, Core_Opp_FC_Quarter_Date__c = System.Today(), Core_Opp_FC_Quantity__c = 654, Core_Opp_FC_isdeleted__c = false));
        insertForeCastList.add(new Core_Opp_FC_Prod_Schedule__c(Core_Opp_FC_Opportunity__c = opptyList[0].Id, Core_Opp_Line_Item_RecordID__c = oliTestList[1].Id, Core_Opp_FC_Product__c = oliTestList[0].Product2Id, Core_Opp_FC_Quarter_Date__c = System.Today(), Core_Opp_FC_Quantity__c = 1000, Core_Opp_FC_isdeleted__c = true));
        insertForeCastList.add(new Core_Opp_FC_Prod_Schedule__c(Core_Opp_FC_Opportunity__c = opptyList[0].Id, Core_Opp_Line_Item_RecordID__c = oliTestList[1].Id, Core_Opp_FC_Product__c = oliTestList[0].Product2Id, Core_Opp_FC_Quarter_Date__c = System.Today(), Core_Opp_FC_Quantity__c = 123, Core_Opp_FC_isdeleted__c = false));
        insertForeCastList.add(new Core_Opp_FC_Prod_Schedule__c(Core_Opp_FC_Opportunity__c = opptyList[0].Id, Core_Opp_Line_Item_RecordID__c = oliTestList[1].Id, Core_Opp_FC_Product__c = oliTestList[0].Product2Id, Core_Opp_FC_Quarter_Date__c = System.Today(), Core_Opp_FC_Quantity__c = 134, Core_Opp_FC_isdeleted__c = false));
        insertForeCastList.add(new Core_Opp_FC_Prod_Schedule__c(Core_Opp_FC_Opportunity__c = opptyList[0].Id, Core_Opp_Line_Item_RecordID__c = oliTestList[1].Id, Core_Opp_FC_Product__c = oliTestList[0].Product2Id, Core_Opp_FC_Quarter_Date__c = System.Today(), Core_Opp_FC_Quantity__c = 13555, Core_Opp_FC_isdeleted__c = false));
        insertForeCastList.add(new Core_Opp_FC_Prod_Schedule__c(Core_Opp_FC_Opportunity__c = opptyList[0].Id, Core_Opp_Line_Item_RecordID__c = oliTestList[1].Id, Core_Opp_FC_Product__c = oliTestList[0].Product2Id, Core_Opp_FC_Quarter_Date__c = System.Today(), Core_Opp_FC_Quantity__c = 12344, Core_Opp_FC_isdeleted__c = false));
        insertForeCastList.add(new Core_Opp_FC_Prod_Schedule__c(Core_Opp_FC_Opportunity__c = opptyList[0].Id, Core_Opp_Line_Item_RecordID__c = oliTestList[1].Id, Core_Opp_FC_Product__c = oliTestList[0].Product2Id, Core_Opp_FC_Quarter_Date__c = System.Today(), Core_Opp_FC_Quantity__c = 1234, Core_Opp_FC_isdeleted__c = false));
        insert insertForeCastList;
        
        for(Core_Opp_FC_Prod_Schedule__c fc : insertForeCastList){
            fc.Core_Opp_FC_Quantity__c = 500;
            fc.Core_Opp_FC_Prod_Sales_Price__c = 50;
        }
        update insertForeCastList;
        system.debug('forecastlist '+[select Id, Core_Opp_FC_Quantity__c, Core_Opp_FC_Sched_Revenue__c from Core_Opp_FC_Prod_Schedule__c where Id IN: insertForeCastList]);
    }
    
    static testMethod void commissionTest(){
        List<Core_Opp_FC_Prod_Schedule__c> fcList = [SELECT id, Core_Opp_FC_Opportunity__c, Core_Opp_Line_Item_RecordID__c, Core_Opp_FC_Product__c, Core_Opp_FC_Quarter_Date__c, Core_Opp_FC_Quantity__c, Core_Opp_FC_isdeleted__c, Core_Opp_FC_Approval_Status__c, Core_Opp_FC_Approved_Date__c, Core_Opp_FC_Prod_Sales_Price__c, Core_Opp_FC_Sched_Revenue__c FROM Core_Opp_FC_Prod_Schedule__c];
        for(Core_Opp_FC_Prod_Schedule__c fc : fcList){
            fc.Core_Opp_FC_Approval_Status__c = 'Approved';
            fc.Core_Opp_FC_Approved_Date__c = datetime.now();
        }
        update fcList;
        
        for(Core_Opp_FC_Prod_Schedule__c fc : fcList){
            fc.Core_Opp_FC_Approval_Status__c = null;
        }
        update fcList;
    }
    
    static testMethod void commissionTest1(){
        List<Core_Commissions_Percent_Contribution__c> comsnPrsnList = Core_Commissions_Percent_Contribution__c.getAll().values();
        delete comsnPrsnList;
        List<Core_Opp_FC_Prod_Schedule__c> fcList = [SELECT id, Core_Opp_FC_Opportunity__c, Core_Opp_Line_Item_RecordID__c, Core_Opp_FC_Product__c, Core_Opp_FC_Quarter_Date__c, Core_Opp_FC_Quantity__c, Core_Opp_FC_isdeleted__c, Core_Opp_FC_Approval_Status__c, Core_Opp_FC_Approved_Date__c, Core_Opp_FC_Prod_Sales_Price__c, Core_Opp_FC_Sched_Revenue__c FROM Core_Opp_FC_Prod_Schedule__c];
        for(Core_Opp_FC_Prod_Schedule__c fc : fcList){
            fc.Core_Opp_FC_Approval_Status__c = 'Approved';
            fc.Core_Opp_FC_Approved_Date__c = datetime.now();
        }
        update fcList;
        
        for(Core_Opp_FC_Prod_Schedule__c fc : fcList){
            fc.Core_Opp_FC_Approval_Status__c = null;
        }
        update fcList;
        
        Core_Opp_FC_Handler.getMonths('2021-Q1');
        Core_Opp_FC_Handler.getMonths('2021-Q2');
        Core_Opp_FC_Handler.getMonths('2021-Q3');
        Core_Opp_FC_Handler.getMonths('2021-Q4');
    }
        static testMethod void createFCTasks_Test(){
        List<Core_Opp_FC_Prod_Schedule__c> fcList = [SELECT id, Core_Opp_FC_Opportunity__c, Core_Opp_FC_Opportunity__r.Core_Opportunity_Coverage_Nm__c, Core_Opp_FC_Opportunity__r.Core_Coverage_Type_Nm__c, Core_Opp_Line_Item_RecordID__c, Core_Opp_FC_Product__c, Core_Opp_FC_Quarter_Date__c, Core_Opp_FC_Quantity__c, Core_Opp_FC_isdeleted__c, Core_Opp_FC_Approval_Status__c, Core_Opp_FC_Approved_Date__c, Core_Opp_FC_Prod_Sales_Price__c, Core_Opp_FC_Sched_Revenue__c FROM Core_Opp_FC_Prod_Schedule__c];

        for(Core_Opp_FC_Prod_Schedule__c fc : fcList){
            fc.Core_Opp_FC_Opportunity__r.Core_Opportunity_Coverage_Nm__c = 'Partner-Led Opportunity';
          fc.Core_Opp_FC_Opportunity__r.Core_Coverage_Type_Nm__c ='Deal Registration';
            fc.Core_Opp_FC_Approval_Status__c = 'Submitted';
        }
        update fcList;
        
        for(Core_Opp_FC_Prod_Schedule__c fc : fcList){
            fc.Core_Opp_FC_Approval_Status__c = 'Approved';
            fc.Core_Opp_FC_Approved_Date__c = datetime.now();
        }
        update fcList;
        
        for(Core_Opp_FC_Prod_Schedule__c fc : fcList){
            fc.Core_Opp_FC_Approval_Status__c = 'Submitted';
        }
        update fcList;
        
        for(Core_Opp_FC_Prod_Schedule__c fc : fcList){
            fc.Core_Opp_FC_Approval_Status__c = null;
        }
        update fcList;
        
    }
    
}