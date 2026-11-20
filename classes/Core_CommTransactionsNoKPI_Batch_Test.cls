/********************************************************************************************************************************************************************
Apex Class Name:  Core_CommTransactionsNoKPI_Batch_Test
Version     : 1.0 
Created Date: 03/05/2023  
Function    : Process the pending Opportunity KPI test class

Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Biswa               		07/27/2023               Original Version
*******************************************************************************************************************************************************************/
@isTest
public class Core_CommTransactionsNoKPI_Batch_Test {
    public static User usr = new User();
    public static List<Core_Oppty_KPI_New__c> newKPIList= new List<Core_Oppty_KPI_New__c>();
    public static Map<Id, Core_Oppty_KPI_New__c> oldKPIMap = new Map<Id, Core_Oppty_KPI_New__c>();
    
    @testSetup
    public static void setUpData() {
        Profile prf = [SELECT id, Name FROM Profile WHERE Name='Sales Rep-BB'];
        User usr = [SELECT id, Name, isActive,Core_WWID__c FROM User WHERE ProfileId = :prf.Id AND isActive = true AND Core_Employee_Type_Code__c='EMP' LIMIT 1];
        
        Core_Trigger_Executions__c opportunityAddCommTxns = new Core_Trigger_Executions__c();
        opportunityAddCommTxns.name = 'opportunityAddCommTxnsFromKPI';
        opportunityAddCommTxns.Core_Object__c = 'Core_Oppty_KPI_New__c';
        opportunityAddCommTxns.Core_Active__c = TRUE;
        opportunityAddCommTxns.Core_Trigger_Events__c = 'after insert, after update';
        opportunityAddCommTxns.Core_Description__c = 'This is test description';
        opportunityAddCommTxns.Core_Class_Name__c = 'Test Class';
        insert opportunityAddCommTxns;
        
        List < Core_Commission_KPI_Mappings__c > lstkpiCustSetting = new List < Core_Commission_KPI_Mappings__c > ();
        Core_Commission_KPI_Mappings__c kpiCustSetting1 = new Core_Commission_KPI_Mappings__c();
        kpiCustSetting1.Name = 'kpi-002';
        kpiCustSetting1.Core_KPI_Name_Nm__c = 'NEX Deal Sell-To $';
        kpiCustSetting1.Core_Event_Type__c = 'Sales OKR';
        kpiCustSetting1.Core_Aggregate_Type__c = 'SUM';
        kpiCustSetting1.Core_IsActive__c = TRUE;
        kpiCustSetting1.Core_KPI_Field__c = 'CORE_KPI_TOTAL_PRICE__C';
        kpiCustSetting1.Core_KPI_Id__c = 2301;
        lstkpiCustSetting.add(kpiCustSetting1);
        Core_Commission_KPI_Mappings__c kpiCustSetting2 = new Core_Commission_KPI_Mappings__c();
        kpiCustSetting2.Name = 'kpi-003';
        kpiCustSetting2.Core_KPI_Name_Nm__c = 'AXG Client Graphics Design #';
        kpiCustSetting2.Core_Event_Type__c = 'Sales OKR';
        kpiCustSetting2.Core_Aggregate_Type__c = 'Count';
        kpiCustSetting2.Core_IsActive__c = TRUE;
        kpiCustSetting2.Core_KPI_Id__c = 2302;
        lstkpiCustSetting.add(kpiCustSetting2);
        Core_Commission_KPI_Mappings__c kpiCustSetting3 = new Core_Commission_KPI_Mappings__c();
        kpiCustSetting3.Name = 'kpi-004';
        kpiCustSetting3.Core_KPI_Name_Nm__c = 'DCAI Strategic Next Gen Design #';
        kpiCustSetting3.Core_Event_Type__c = 'Sales OKR';
        kpiCustSetting3.Core_Aggregate_Type__c = 'Unique';
        kpiCustSetting3.Core_IsActive__c = TRUE;
        kpiCustSetting3.Core_KPI_Id__c = 2303;
        lstkpiCustSetting.add(kpiCustSetting3);
        insert lstkpiCustSetting;
        
        List<Core_Commission_KPI_Mappings__c> listFunctionalityNameKPIMappings = [Select Id,Name,Core_KPI_Name_Nm__c,Core_Event_Type__c,Core_Aggregate_Type__c
                                                                                  From Core_Commission_KPI_Mappings__c];
        
        Core_Commissions_Percent_Contribution__c commPercent = new Core_Commissions_Percent_Contribution__c();
        commPercent.Name = 'Team Member';
        commPercent.Core_Percent_Contribution__c = 100;
        insert commPercent;
        
        Id newOppRecTypeId = [select Id from RecordType where DeveloperName = 'Core_Design_Opportunity' limit 1][0].Id;
        
        // Create a product/price book entry to use on the opportunities
        Product2 p = new Product2(Name = 'Test Product KPI',Core_Inf_KPI_ProdGroup__c='PSG Board');
        insert p;
        PricebookEntry pbe = new PricebookEntry(Product2Id = p.Id, Pricebook2Id = Test.getStandardPricebookId(),
                                                UnitPrice = 0, IsActive = true);
        System.runAs(Core_Test_Utility.systemAdminUser) {
            insert pbe;
        }
        
        SObjectType r = ((SObject)Type.forName('Schema','Account').newInstance()).getSObjectType();
        Id recTypeId = r.getDescribe().getRecordTypeInfosByDeveloperName().get(Label.Pricing_Tender_Account_RecordType_IntelAccount).getRecordTypeId();
        
        // Create an account
        Account acct = new Account();
        acct.name = 'TestAccountKPI';
        acct.RecordTypeId = recTypeId;
        acct.BillingCountryCode = 'USA';
        acct.BIllingStateCode = 'AL';
        acct.BillingCity = 'Alabama123';
        acct.BillingStreet = 'test123';  
        //acct.Core_CIM_ID__c='10103325';
        acct.Core_Sales_Groups__c= Core_CRM_Utility.getSalesGroupAPI();
        acct.Industry='Health and Life Sciences'; 
        acct.Core_Sub_Industry__c='Biotechnology';     
        System.runAs(Core_Test_Utility.systemAdminUser) {
            insert acct;
        }
        
        Opportunity oppForKPI = new Opportunity(Name = 'OpportunityNoKPICommissionTest', RecordTypeId = newOppRecTypeId,core_approval_status__c = 'Approved',Opportunity_Focus__c= 'Core',Core_Opportunity_Type__c ='Design: Original',
                                                AccountId = acct.Id,Core_Commissionable__c = 'Yes',Core_Technical_Owner__c=usr.id,Core_Date_Submitted_for_Approval__c = System.Date.today()+1,
                                                StageName = 'Qualify', CloseDate = System.Date.today()+1);
        System.runAs(Core_Test_Utility.systemAdminUser) {
            insert oppForKPI;
        }
        
        OpportunityTeamMember otm = new OpportunityTeamMember (OpportunityId = oppForKPI.Id,UserId = usr.id,TeamMemberRole = 'Team Member');
        insert otm;
        
        List<OpportunityLineItem> oppForKPIItems = new List<OpportunityLineItem>();
        oppForKPIItems.add(new OpportunityLineItem(OpportunityId = oppForKPI.Id, PricebookEntryId = pbe.Id,
                                                   UnitPrice = 0, Quantity = 10, Core_Competitor__c = 'Acer', Core_Competitor_Product__c = 'AMD Athlon'));
        oppForKPIItems.add(new OpportunityLineItem(OpportunityId = oppForKPI.Id, PricebookEntryId = pbe.Id,
                                                   UnitPrice = 0, Quantity = 10, Core_Competitor__c = 'Acer', Core_Competitor_Product__c = 'AMD Athlon'));
        List<CORE_OPPTY_KPI_NEW__C> lstkpi = new List<CORE_OPPTY_KPI_NEW__C>();
        lstkpi.add(new CORE_OPPTY_KPI_NEW__C(Name = listFunctionalityNameKPIMappings[0].Core_KPI_Name_Nm__c,Core_KPI_Opportunity__c = oppForKPI.Id,
                                             Core_KPI_Achieved__c = true, Core_KPI_Total_Price__c = 1200,Core_IsActive__c = true,Core_Batch_Time__c = System.now(),
                                             Core_Opportunity_Product_Id__c = oppForKPIItems[0].Id,Core_IsKPI_Processed__c=false,Core_Refresh_Type__c = 'Full'));
        lstkpi.add(new CORE_OPPTY_KPI_NEW__C(Name = listFunctionalityNameKPIMappings[1].Core_KPI_Name_Nm__c,Core_KPI_Opportunity__c = oppForKPI.Id,
                                             Core_KPI_Achieved__c = true, Core_KPI_Total_Price__c = 1200,Core_IsActive__c = true,Core_Batch_Time__c = System.now(),
                                             Core_Opportunity_Product_Id__c = oppForKPIItems[0].Id,Core_IsKPI_Processed__c=false,Core_Refresh_Type__c = 'Full'));
        lstkpi.add(new CORE_OPPTY_KPI_NEW__C(Name = listFunctionalityNameKPIMappings[0].Core_KPI_Name_Nm__c,Core_KPI_Opportunity__c = oppForKPI.Id,
                                             Core_KPI_Achieved__c = true, Core_KPI_Total_Price__c = 1200,Core_IsActive__c = true,Core_Batch_Time__c = System.now(),
                                             Core_Opportunity_Product_Id__c = oppForKPIItems[0].Id,Core_IsKPI_Processed__c=false,Core_Refresh_Type__c = 'Full'));
        lstkpi.add(new CORE_OPPTY_KPI_NEW__C(Name = listFunctionalityNameKPIMappings[2].Core_KPI_Name_Nm__c,Core_KPI_Opportunity__c = oppForKPI.Id,
                                             Core_KPI_Achieved__c = true, Core_KPI_Total_Price__c = 1200,Core_IsActive__c = true,Core_Batch_Time__c = System.now(),
                                             Core_Opportunity_Product_Id__c = oppForKPIItems[0].Id,Core_IsKPI_Processed__c=false,Core_Refresh_Type__c = 'Full'));
        System.runAs(Core_Test_Utility.systemAdminUser) {
            insert oppForKPIItems;
            insert lstkpi;
        }
    }
    
    static testmethod void insertPendingCommissionTransactionsByBatch(){    
        Profile prf = [SELECT id, Name FROM Profile WHERE Name='Sales Rep-BB'];
        User usr = [SELECT id, Name, isActive FROM User WHERE ProfileId = :prf.Id AND isActive = true AND Core_Employee_Type_Code__c='EMP' LIMIT 1];
        List<Opportunity> lstOpp = [select id,Name,StageName,core_approval_status__c from Opportunity Where Name='OpportunityNoKPICommissionTest' limit 1];
        lstOpp[0].StageName = 'Design Win';
        List<CORE_OPPTY_KPI_NEW__C> kpis = [SELECT ID,Name,Core_KPI_Total_Price__c,Core_IsKPI_Processed__c FROM CORE_OPPTY_KPI_NEW__C WHERE Core_KPI_Opportunity__c =: lstOpp[0].Id];
        
        List<Core_Commissionable_Transaction__c> commTransactions = new List<Core_Commissionable_Transaction__c>();
        for (Opportunity opp : lstOpp) {
            commTransactions.add(new Core_Commissionable_Transaction__c(Core_Opportunity__c = opp.Id,Core_Status__c = 'Approved',Core_Milestone_Area__c=kpis[0].Name,Core_Approved_Total_Price__c=kpis[0].Core_KPI_Total_Price__c,Core_Employee_ID__c=usr.Id,
                                                                        Core_Last_Approved_Date__c= System.now().date(), Core_Source_ID__c=opp.Id , Core_Transaction_Timestamp__c = Datetime.newInstance(2023, 2, 1, 0, 0, 0)));
        }
        insert commTransactions;
        
        System.runAs(Core_Test_Utility.systemAdminUser) {
            Core_Opp_Bypass_Validation_Rule__c triggerExecList = new Core_Opp_Bypass_Validation_Rule__c();
            triggerExecList.Bypass__c = true;
            INSERT triggerExecList;
            UPDATE lstOpp; 
            DELETE kpis;
        }
        Test.startTest(); 
		Database.executeBatch(new Core_CommissionTransactionsNoKPI_Batch(),10);         
		Test.stopTest();
        Integer expectedLogEntries = 0; // Since there are no Opportunity records to process, there should be no errors
        Integer actualLogEntries = [SELECT COUNT() FROM Core_Log_Entry__c WHERE Core_Origin__c = 'Core_CommissionTransactionsNoKPI_Batch'];
        System.assertEquals(expectedLogEntries, actualLogEntries, 'Number of Core_Log_Entry__c records is incorrect.');
    }
}