/**************************************************************************************
Apex Class Name:  Core_Opportunity_KPI_Handler_Test
Version     : 1.0 
Created Date: 28/5/2020
Description : Test class for the Core_Opportunity_KPI_Handler class
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Mahesh Manikonda            28/5/2020               Original Version
* Mahesh Manikonda            28/5/2020               Test Class for new Opportunity KPI Object Trigger and Its handler
*************************************************************************************/
@isTest
public class Core_Opportunity_KPI_Handler_Test {
    
    public static User usr = new User();
    public static List<Core_Oppty_KPI_New__c> newKPIList= new List<Core_Oppty_KPI_New__c>();
    public static Map<Id, Core_Oppty_KPI_New__c> oldKPIMap = new Map<Id, Core_Oppty_KPI_New__c>();
    
    @testSetup
    public static void setUpData() {
        Profile prf = [SELECT id, Name FROM Profile WHERE Name='Sales Rep-BB'];
        User usr = [SELECT id, Name, isActive, Core_Employee_Type_Code__c FROM User WHERE ProfileId = :prf.Id AND isActive = true AND Core_Employee_Type_Code__c='EMP' LIMIT 1];
        
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
        kpiCustSetting1.Core_KPI_Id__c = 2301;
        kpiCustSetting1.Core_IsActive__c = TRUE;
        kpiCustSetting1.Core_KPI_Field__c = 'CORE_KPI_TOTAL_PRICE__C';
        kpiCustSetting1.Core_KPI_Type__c = 'Design';
        kpiCustSetting1.Core_KPI_Start_Dt__c = System.Date.today().addDays(-10);
        kpiCustSetting1.Core_KPI_End_Dt__c = System.Date.today().addDays(10);
        lstkpiCustSetting.add(kpiCustSetting1);
        Core_Commission_KPI_Mappings__c kpiCustSetting2 = new Core_Commission_KPI_Mappings__c();
        kpiCustSetting2.Name = 'kpi-003';
        kpiCustSetting2.Core_KPI_Name_Nm__c = 'AXG Client Graphics Design #';
        kpiCustSetting2.Core_Event_Type__c = 'Sales OKR';
        kpiCustSetting2.Core_Aggregate_Type__c = 'Count';
        kpiCustSetting2.Core_KPI_Id__c = 2302;
        kpiCustSetting2.Core_IsActive__c = TRUE;
        kpiCustSetting2.Core_KPI_Type__c = 'Design';
        kpiCustSetting2.Core_KPI_Start_Dt__c = System.Date.today().addDays(-10);
        kpiCustSetting2.Core_KPI_End_Dt__c = System.Date.today().addDays(10);
        lstkpiCustSetting.add(kpiCustSetting2);
        Core_Commission_KPI_Mappings__c kpiCustSetting3 = new Core_Commission_KPI_Mappings__c();
        kpiCustSetting3.Name = 'kpi-004';
        kpiCustSetting3.Core_KPI_Name_Nm__c = 'DCAI Strategic Next Gen Design #';
        kpiCustSetting3.Core_Event_Type__c = 'Sales OKR';
        kpiCustSetting3.Core_Aggregate_Type__c = 'Unique';
        kpiCustSetting3.Core_KPI_Id__c = 2303;
        kpiCustSetting3.Core_IsActive__c = TRUE;
        kpiCustSetting3.Core_KPI_Type__c = 'Design';
        kpiCustSetting3.Core_KPI_Start_Dt__c = System.Date.today().addDays(-10);
        kpiCustSetting3.Core_KPI_End_Dt__c = System.Date.today().addDays(10);
        lstkpiCustSetting.add(kpiCustSetting3);
        Core_Commission_KPI_Mappings__c kpiCustSetting4 = new Core_Commission_KPI_Mappings__c();
        kpiCustSetting4.Name = 'kpi-005';
        kpiCustSetting4.Core_KPI_Name_Nm__c = 'One Intel SW Enablement Design PW #';
        kpiCustSetting4.Core_Event_Type__c = 'Sales OKR';
        kpiCustSetting4.Core_Aggregate_Type__c = 'Count';
        kpiCustSetting4.Core_KPI_Id__c = 2330;
        kpiCustSetting4.Core_IsActive__c = TRUE;
        kpiCustSetting4.Core_KPI_Type__c = 'Production';
        kpiCustSetting4.Core_KPI_Start_Dt__c = System.Date.today().addDays(-10);
        kpiCustSetting4.Core_KPI_End_Dt__c = System.Date.today().addDays(10);
        lstkpiCustSetting.add(kpiCustSetting4);
        insert lstkpiCustSetting;
        
        List<Core_Commission_KPI_Mappings__c> listFunctionalityNameKPIMappings = [Select Id,Name,Core_KPI_Name_Nm__c,Core_Event_Type__c,Core_Aggregate_Type__c,Core_KPI_Field__c,Core_IsActive__c,Core_KPI_Start_Dt__c,Core_KPI_End_Dt__c,Core_KPI_Type__c
                                                                                  From Core_Commission_KPI_Mappings__c];
        
        Core_Commissions_Percent_Contribution__c commPercent = new Core_Commissions_Percent_Contribution__c();
        commPercent.Name = 'Team Member';
        commPercent.Core_Percent_Contribution__c = 100;
        insert commPercent;
        
        Id newOppRecTypeId = [select Id from RecordType where DeveloperName = 'Core_Design_Opportunity' limit 1][0].Id;
        
        // Create a product/price book entry to use on the opportunities
        Product2 p = new Product2(Name = 'Test Product KPI',Core_Inf_KPI_ProdGroup__c='PSG Board');
        insert p;
        Product2 p1 = new Product2(Name = 'Test Product KPI - 1',Core_Inf_KPI_ProdGroup__c='SSD');
        insert p1;
        PricebookEntry pbe = new PricebookEntry(Product2Id = p.Id, Pricebook2Id = Test.getStandardPricebookId(),
                                                UnitPrice = 100, IsActive = true);
        PricebookEntry pbe1 = new PricebookEntry(Product2Id = p1.Id, Pricebook2Id = Test.getStandardPricebookId(),
                                                 UnitPrice = 200, IsActive = true);
        System.runAs(Core_Test_Utility.systemAdminUser) {
            insert pbe;
            insert pbe1;
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
        acct.Core_Sales_Groups__c=Core_CRM_Utility.getSalesGroupAPI();
        acct.Industry='Health and Life Sciences'; 
        acct.Core_Sub_Industry__c='Biotechnology';     
        System.runAs(Core_Test_Utility.systemAdminUser) {
            insert acct;
        }
        
        Opportunity oppForKPI = new Opportunity(Name = 'OpportunityKPICommissionTest', RecordTypeId = newOppRecTypeId,core_approval_status__c = 'Approved', 
                                                AccountId = acct.Id,Core_Commissionable__c = 'Yes',Core_Technical_Owner__c=usr.id,Core_Date_Submitted_for_Approval__c = System.Date.today(),
                                                StageName = 'Qualify', CloseDate = System.Date.today()+1,Opportunity_Focus__c= 'Core',Core_Opportunity_Type__c ='Design: Original');
        System.runAs(Core_Test_Utility.systemAdminUser) {
            Core_Opp_Bypass_Validation_Rule__c rec = new Core_Opp_Bypass_Validation_Rule__c();
            rec.Bypass__c = true;
            insert rec;            
            insert oppForKPI;
            oppForKPI.StageName = 'Design Win';
            oppForKPI.core_approval_status__c = 'Approved';
            Update oppForKPI;
        }
        
        OpportunityTeamMember otm = new OpportunityTeamMember (OpportunityId = oppForKPI.Id,UserId = usr.id,TeamMemberRole = 'Team Member');
        insert otm;
        
        List<OpportunityLineItem> oppForKPIItems = new List<OpportunityLineItem>();
        oppForKPIItems.add(new OpportunityLineItem(OpportunityId = oppForKPI.Id, PricebookEntryId = pbe.Id,Product2Id=p.Id,
                                                   UnitPrice = 10, Quantity = 10, Core_Competitor__c = 'Acer', Core_Competitor_Product__c = 'AMD Athlon'));
        oppForKPIItems.add(new OpportunityLineItem(OpportunityId = oppForKPI.Id, PricebookEntryId = pbe.Id,Product2Id=p.Id,
                                                   UnitPrice = 10, Quantity = 10, Core_Competitor__c = 'Acer', Core_Competitor_Product__c = 'AMD Athlon'));
        oppForKPIItems.add(new OpportunityLineItem(OpportunityId = oppForKPI.Id, PricebookEntryId = pbe1.Id,Product2Id=p1.Id,
                                                   UnitPrice = 10, Quantity = 10, Core_Competitor__c = 'Acer', Core_Competitor_Product__c = 'AMD Athlon'));
        insert oppForKPIItems;
        
        for (OpportunityLineItem oppForKPIItem: oppForKPIItems) {
            oppForKPIItem.Core_Claim_Date__c = System.Date.today().addDays(2);
            oppForKPIItem.Core_Status__c = 'Win Approved';
        }
        System.runAs(Core_Test_Utility.systemAdminUser) {
            update oppForKPIItems;
        }
        List<Core_Opportunity_KPI_Batch_Detail__c> lstKPIBatch = new List<Core_Opportunity_KPI_Batch_Detail__c>();
        lstKPIBatch.add(new Core_Opportunity_KPI_Batch_Detail__c(Core_Opportunity_ID_Txt__c = oppForKPI.Id, Core_Opportunity_Stage_Txt__c = 'Design Win',
                                                                 Core_Opportunity_KPI_Batch_ID_Txt__c = '12345'));
        lstKPIBatch.add(new Core_Opportunity_KPI_Batch_Detail__c(Core_Opportunity_ID_Txt__c = oppForKPI.Id, Core_Opportunity_Stage_Txt__c = 'Production Win',
                                                                 Core_Opportunity_KPI_Batch_ID_Txt__c = '12345'));
        insert lstKPIBatch;
        List<CORE_OPPTY_KPI_NEW__C> lstkpi = new List<CORE_OPPTY_KPI_NEW__C>();
        lstkpi.add(new CORE_OPPTY_KPI_NEW__C(Name = listFunctionalityNameKPIMappings[0].Core_KPI_Name_Nm__c,Core_KPI_Opportunity__c = oppForKPI.Id,Core_IsKPI_Processed__c= false,
                                             Core_KPI_Achieved__c = true, Core_KPI_Total_Price__c = 1200,Core_IsActive__c = true,Core_Opportunity_KPI_Batch_ID__c='12345',
                                             Core_Opportunity_Product__c = oppForKPIItems[0].Id,Core_Opp_KPI_Product__c = p.Id,Core_Refresh_Type__c = 'Incremental'));
        lstkpi.add(new CORE_OPPTY_KPI_NEW__C(Name = listFunctionalityNameKPIMappings[1].Core_KPI_Name_Nm__c,Core_KPI_Opportunity__c = oppForKPI.Id,Core_IsKPI_Processed__c= false,
                                             Core_KPI_Achieved__c = true, Core_KPI_Total_Price__c = 1200,Core_IsActive__c = true,Core_Opportunity_KPI_Batch_ID__c='12345',
                                             Core_Opportunity_Product__c = oppForKPIItems[0].Id,Core_Opp_KPI_Product__c = p.Id,Core_Refresh_Type__c = 'Incremental'));
        lstkpi.add(new CORE_OPPTY_KPI_NEW__C(Name = listFunctionalityNameKPIMappings[0].Core_KPI_Name_Nm__c,Core_KPI_Opportunity__c = oppForKPI.Id,Core_IsKPI_Processed__c= false,
                                             Core_KPI_Achieved__c = true, Core_KPI_Total_Price__c = 1200,Core_IsActive__c = true,Core_Opportunity_KPI_Batch_ID__c='12345',
                                             Core_Opportunity_Product__c = oppForKPIItems[0].Id,Core_Opp_KPI_Product__c = p.Id,Core_Refresh_Type__c = 'Incremental'));
        lstkpi.add(new CORE_OPPTY_KPI_NEW__C(Name = listFunctionalityNameKPIMappings[2].Core_KPI_Name_Nm__c,Core_KPI_Opportunity__c = oppForKPI.Id,Core_IsKPI_Processed__c= false,
                                             Core_KPI_Achieved__c = true, Core_KPI_Total_Price__c = 1200,Core_IsActive__c = true,Core_Opportunity_KPI_Batch_ID__c='12345',
                                             Core_Opportunity_Product__c = oppForKPIItems[0].Id,Core_Opp_KPI_Product__c = p.Id,Core_Refresh_Type__c = 'Incremental'));
        lstkpi.add(new CORE_OPPTY_KPI_NEW__C(Name = listFunctionalityNameKPIMappings[2].Core_KPI_Name_Nm__c,Core_KPI_Opportunity__c = oppForKPI.Id,Core_IsKPI_Processed__c= false,
                                             Core_KPI_Achieved__c = true, Core_KPI_Total_Price__c = 100,Core_IsActive__c = true,Core_Opportunity_KPI_Batch_ID__c='12345',
                                             Core_Opportunity_Product__c = oppForKPIItems[2].Id,Core_Opp_KPI_Product__c = p1.Id,Core_Refresh_Type__c = 'Incremental'));
        insert lstkpi;
    }
    
    static void createTriggerExecutions() {        
        List<Core_Trigger_Executions__c> triggerExecList = new List<Core_Trigger_Executions__c>();
        Core_Trigger_Executions__c triggerExec = new Core_Trigger_Executions__c();
        triggerExec.Name = 'beforeupdateinsertGoalKPI';
        triggerExec.Core_Active__c = true;
        triggerExec.Core_Class_Name__c = 'Core_Opp_KPI_Handler';
        triggerExec.Core_Description__c = 'Test';
        triggerExec.Core_Object__c = 'Core_Oppty_KPI_New__c';
        triggerExec.Core_Trigger_Events__c = 'Before Insert Before Update Before Delete';
        triggerExecList.add(triggerExec); 
        
        Core_Trigger_Executions__c triggerExec1 = new Core_Trigger_Executions__c();
        triggerExec1.Name = 'UpdateKPIRevenueAndAchievedOnDWG';
        triggerExec1.Core_Active__c = true;
        triggerExec1.Core_Class_Name__c = 'Core_Opp_KPI_Handler';
        triggerExec1.Core_Description__c = 'Test';
        triggerExec1.Core_Object__c = 'Core_Oppty_KPI_New__c';
        triggerExec1.Core_Trigger_Events__c = 'Before Insert Before Update Before Delete';
        triggerExecList.add(triggerExec1); 
        
        insert triggerExecList;
    }
    
    Static Opportunity CreateOpportunity(){
        Profile pr = [SELECT id, Name FROM Profile WHERE Name='IT Admin'];
        usr = [SELECT id, Name, isActive FROM User WHERE ProfileId = :pr.Id AND isActive = true LIMIT 1];  
        SObjectType r = ((SObject)Type.forName('Schema','Account').newInstance()).getSObjectType();
        Id recTypeId = r.getDescribe().getRecordTypeInfosByDeveloperName().get(Label.Pricing_Tender_Account_RecordType_IntelAccount).getRecordTypeId();
        Account accountInstance = new Account();
        accountInstance.name = 'TestAccount';
        accountInstance.RecordTypeId = recTypeId;
        accountInstance.BillingCountryCode = 'USA';
        accountInstance.BIllingStateCode = 'AL';
        accountInstance.BillingCity = 'Alabama';
        accountInstance.BillingStreet = 'test';  
        //accountInstance.Core_CIM_ID__c='10102356';
        accountInstance.Core_Sales_Groups__c=Core_CRM_Utility.getSalesGroupAPI();
        accountInstance.Industry='Health and Life Sciences'; 
        accountInstance.Core_Sub_Industry__c='Biotechnology'; 
        insert accountInstance;     
        Opportunity opportunityInstance = new Opportunity();
        opportunityInstance.CloseDate = System.Today().addDays(24);
        opportunityInstance.StageName ='Define';
        opportunityInstance.Name ='Test OppName';
        opportunityInstance.AccountId = accountInstance.Id;
        opportunityInstance.Core_First_Customer_Ship_Date__c=system.today().addDays(5);
        opportunityInstance.Core_Production_End_Date__c =System.Today().addDays(-10);
        opportunityInstance.Core_Opportunity_Type__c='Design: Original';
        opportunityInstance.Core_Loss_Cancel_Details__c='Test opp record';
        opportunityInstance.Core_Intel_Platform__c='Tiger Lake M';
        opportunityInstance.Core_Technical_Owner__c =usr.Id;
        opportunityInstance.Opportunity_Focus__c='';
        insert opportunityInstance;  
        return opportunityInstance;
    }
    
    testMethod static void InsertOppTest1() {
        Profile pr = [SELECT id, Name FROM Profile WHERE Name='IT Admin'];
        usr = [SELECT id, Name, isActive FROM User WHERE ProfileId = :pr.Id AND isActive = true LIMIT 1];
        Test.startTest();
        createTriggerExecutions();
        Opportunity opportunityInstance= CreateOpportunity();
        Core_Goal__c Goal= new Core_Goal__c();
        Goal.Name='Test Goal';
        Goal.Core_Goal_Category__c='Assigned';
        Goal.Core_Goal_BU_Focus_Area__c='CCG vPro Deal $';
        Goal.Core_Goal_Criteria__c='Drive vPro branded revenue w/win-back on vPro, sell-up to vPro, sell-up to Xeon Wkstn, or vPro refresh (i.e. non-vPro to vPro, vPro ci5 to vPro ci7, core to vPro Xeon Wkstn, vPro refresh). Alignment w/SMG BU Segment Director';
        Goal.Core_Opportunity__c=opportunityInstance.Id;
        Goal.Core_Goal_KPI_Match_Flag__c=true;
        Goal.Core_Goal_KPI_Achieved_Flag__c=false;
        Goal.Core_Goal_Owner__c=usr.Id;
        insert Goal;    
        Core_Oppty_KPI_New__c OppKPI = new Core_Oppty_KPI_New__c();
        OppKPI.Name='CCG vPro Deal $';
        //OppKPI.Core_KPI_Total_Price__c=decimal.valueOf('9000');
        //OppKPI.Core_Opp_KPI_Type__c='Salesforce Pipeline $';
        OppKPI.Core_KPI_Opportunity__c=opportunityInstance.Id;
        OppKPI.Core_KPI_Achieved__c=true;
        insert OppKPI;         
        Core_Oppty_KPI_New__c OppKPI1 = new Core_Oppty_KPI_New__c();
        OppKPI1.Name='DCG Cloud New Services Dealqqq #';
        OppKPI1.Core_KPI_Opportunity__c=opportunityInstance.Id;
        OppKPI1.Core_KPI_Achieved__c=false;
        insert OppKPI1;
        OppKPI.Name='DCG Cloud New Services Deal #';
        OppKPI.Core_KPI_Achieved__c=false;
        //OppKPI1.Core_KPI_Opportunity__c=opportunityInstance11.Id;
        update OppKPI;  
        OppKPI1.Name='DCG Cloud New Services Deal #';
        update OppKPI1;
        delete OppKPI1;
        List<Core_Goal__c> GoalLst= new List<Core_Goal__c>();
        GoalLst.add(Goal);
        newKPIList.add(OppKPI);
        oldKPIMap.put(OppKPI.Id, OppKPI);
        oldKPIMap.put(OppKPI1.Id, OppKPI1);      
        Database.SaveResult[] srList = Database.update(GoalLst, false);
        system.assertEquals(srList.isempty(), false);        
        Test.stopTest(); 
    }
    testMethod static void InsertOppTest2() {
        Test.startTest();
        createTriggerExecutions();
        Opportunity opportunityInstance= CreateOpportunity();
        Profile pr = [SELECT id, Name FROM Profile WHERE Name='IT Admin'];
        usr = [SELECT id, Name, isActive FROM User WHERE ProfileId = :pr.Id AND isActive = true LIMIT 1];
        SObjectType r = ((SObject)Type.forName('Schema','Account').newInstance()).getSObjectType();
        Id recTypeId = r.getDescribe().getRecordTypeInfosByDeveloperName().get(Label.Pricing_Tender_Account_RecordType_IntelAccount).getRecordTypeId();
        Account accountInstance = new Account();
        accountInstance.name = 'TestAccount1234';
        accountInstance.RecordTypeId = recTypeId;
        accountInstance.BillingCountryCode = 'USA';
        accountInstance.BIllingStateCode = 'AL';
        accountInstance.BillingCity = 'Alabama';
        accountInstance.BillingStreet = 'test';  
        //accountInstance.Core_CIM_ID__c='10102356';
        accountInstance.Core_Sales_Groups__c=Core_CRM_Utility.getSalesGroupAPI();
        accountInstance.Industry='Health and Life Sciences'; 
        accountInstance.Core_Sub_Industry__c='Biotechnology'; 
        insert accountInstance;   
        Opportunity opportunityInstance1 = new Opportunity();
        opportunityInstance1.CloseDate = System.Today().addDays(24);
        opportunityInstance1.StageName ='Define';
        opportunityInstance1.Name ='Test OppName1233';
        opportunityInstance1.AccountId = accountInstance.Id;
        opportunityInstance1.Core_First_Customer_Ship_Date__c=system.today().addDays(5);
        opportunityInstance1.Core_Production_End_Date__c =System.Today().addDays(-10);
        opportunityInstance1.Core_Opportunity_Type__c='Design: Original';
        opportunityInstance1.Core_Loss_Cancel_Details__c='Test opp record1234';
        opportunityInstance1.Core_Intel_Platform__c='Tiger Lake M';
        opportunityInstance1.Core_Technical_Owner__c =usr.Id;
        opportunityInstance1.Opportunity_Focus__c='';
        insert opportunityInstance1;
        system.assertEquals(opportunityInstance1<>null, true);
        Core_Goal__c Goal= new Core_Goal__c();
        Goal.Name='Test Goal';
        Goal.Core_Goal_Category__c='Assigned';
        Goal.Core_Goal_BU_Focus_Area__c='CCG vPro Deal $';
        Goal.Core_Goal_Criteria__c='Drive vPro branded revenue w/win-back on vPro, sell-up to vPro, sell-up to Xeon Wkstn, or vPro refresh (i.e. non-vPro to vPro, vPro ci5 to vPro ci7, core to vPro Xeon Wkstn, vPro refresh). Alignment w/SMG BU Segment Director';
        Goal.Core_Opportunity__c=opportunityInstance.Id;
        Goal.Core_Goal_KPI_Match_Flag__c=false;
        Goal.Core_Goal_KPI_Achieved_Flag__c=false;
        Goal.Core_Goal_Owner__c=usr.Id;
        insert Goal;
        Core_Goal__c Goal1= new Core_Goal__c();
        Goal1.Name='Test Goal12';
        Goal1.Core_Goal_Category__c='Assigned';
        Goal1.Core_Goal_BU_Focus_Area__c='CCG vPro Deal $';
        Goal1.Core_Goal_Criteria__c='Drive vPro branded revenue w/win-back on vPro, sell-up to vPro, sell-up to Xeon Wkstn, or vPro refresh (i.e. non-vPro to vPro, vPro ci5 to vPro ci7, core to vPro Xeon Wkstn, vPro refresh). Alignment w/SMG BU Segment Director';
        Goal1.Core_Opportunity__c=opportunityInstance.Id;
        Goal1.Core_Goal_KPI_Match_Flag__c=false;
        Goal1.Core_Goal_KPI_Achieved_Flag__c=false; 
        Goal1.Core_Goal_Owner__c=usr.Id;
        insert Goal1;
        List<Core_Goal__c> DWG= new List<Core_Goal__c>();
        DWG.add(Goal);
        DWG.add(Goal1);
        Core_Oppty_KPI_New__c OppKPI = new Core_Oppty_KPI_New__c();
        OppKPI.Name='DCG Cloud New Services Deal #';
        OppKPI.Core_KPI_Opportunity__c=opportunityInstance1.Id;
        OppKPI.Core_KPI_Achieved__c=true;
        insert OppKPI;
        OppKPI.Core_KPI_Achieved__c=false;
        update OppKPI;
        Core_Oppty_KPI_New__c OppKPI1 = new Core_Oppty_KPI_New__c();
        OppKPI1.Name='DCG Cloud New Services Deal #';
        OppKPI1.Core_KPI_Opportunity__c=opportunityInstance.Id;
        OppKPI1.Core_KPI_Achieved__c=false;
        insert OppKPI1; 
        newKPIList.add(OppKPI);
        newKPIList.add(OppKPI1);
        oldKPIMap.put(OppKPI.Id, OppKPI);
        oldKPIMap.put(OppKPI1.Id, OppKPI1);
        //Core_Opp_KPI_Handler.updDWGonInstUpdtKPI(newKPIList,oldKPIMap,true);          
        Test.stopTest(); 
    }
    
    testMethod static void InsertOppTest3() {
        Profile pr = [SELECT id, Name FROM Profile WHERE Name='IT Admin'];
        usr = [SELECT id, Name, isActive FROM User WHERE ProfileId = :pr.Id AND isActive = true LIMIT 1];
        Test.startTest();
        createTriggerExecutions();
        Opportunity opportunityInstance= CreateOpportunity();
        Core_Goal__c Goal= new Core_Goal__c();
        Goal.Name='Test Goal';
        Goal.Core_Goal_Category__c='Assigned';
        Goal.Core_Goal_BU_Focus_Area__c='CCG vPro Deal $';
        Goal.Core_Goal_Criteria__c='Drive vPro branded revenue w/win-back on vPro, sell-up to vPro, sell-up to Xeon Wkstn, or vPro refresh (i.e. non-vPro to vPro, vPro ci5 to vPro ci7, core to vPro Xeon Wkstn, vPro refresh). Alignment w/SMG BU Segment Director';
        Goal.Core_Opportunity__c=opportunityInstance.Id;
        Goal.Core_Goal_KPI_Match_Flag__c=false; 
        Goal.Core_Goal_Owner__c=usr.Id;
        insert Goal;
        Core_Oppty_KPI_New__c OppKPI = new Core_Oppty_KPI_New__c();
        OppKPI.Name='test KPI';
        OppKPI.Core_KPI_Opportunity__c=opportunityInstance.Id;
        OppKPI.Core_KPI_Achieved__c=true;
        insert OppKPI;    
        OppKPI.Name='DCG Cloud New Services Deal #';
        //OppKPI.Core_KPI_Opportunity__c=opportunityInstance1.Id;
        update OppKPI;
        delete OppKPI;
        List<Core_Goal__c> GoalLst= new List<Core_Goal__c>();
        GoalLst.add(Goal);
        newKPIList.add(OppKPI);
        // oldKPIMap.put(OppKPI.Id, OppKPI);     
        Database.SaveResult[] srList = Database.update(GoalLst, false);
        system.assertEquals(srList.isempty(), false);
        //Core_Opp_KPI_Handler.updDWGonInstUpdtKPI(newKPIList,oldKPIMap,false);
        Test.stopTest(); 
    }
    
    testMethod static void InsertOppTest4() {
        Profile pr = [SELECT id, Name FROM Profile WHERE Name='IT Admin'];
        usr = [SELECT id, Name, isActive FROM User WHERE ProfileId = :pr.Id AND isActive = true LIMIT 1];
        Test.startTest();
        createTriggerExecutions();
        Opportunity opportunityInstance= CreateOpportunity();
        Core_Goal__c Goal= new Core_Goal__c();
        Goal.Name='Test Goal';
        Goal.Core_Goal_Category__c='Assigned';
        Goal.Core_Goal_BU_Focus_Area__c='CCG vPro Deal $';
        Goal.Core_Goal_Criteria__c='Drive vPro branded revenue w/win-back on vPro, sell-up to vPro, sell-up to Xeon Wkstn, or vPro refresh (i.e. non-vPro to vPro, vPro ci5 to vPro ci7, core to vPro Xeon Wkstn, vPro refresh). Alignment w/SMG BU Segment Director';
        Goal.Core_Opportunity__c=opportunityInstance.Id;
        Goal.Core_Goal_KPI_Match_Flag__c=false;
        Goal.Core_Goal_Owner__c=usr.Id;
        insert Goal;
        Core_Oppty_KPI_New__c OppKPI = new Core_Oppty_KPI_New__c();
        OppKPI.Name='CCG vPro Deal $';
        OppKPI.Core_KPI_Opportunity__c=opportunityInstance.Id;
        OppKPI.Core_KPI_Achieved__c=true;
        OppKPI.Core_KPI_Total_Price__c=decimal.valueOf('9000');
        OppKPI.Core_Opp_KPI_Type__c='Salesforce Pipeline $';
        insert OppKPI; 
        OppKPI.Core_KPI_Achieved__c=false;
        update OppKPI; 
        delete OppKPI;
        Core_Oppty_KPI_New__c OppKPI1 = new Core_Oppty_KPI_New__c();
        OppKPI1.Name='CCG vPro Deal $';
        OppKPI1.Core_KPI_Opportunity__c=opportunityInstance.Id;
        OppKPI1.Core_KPI_Achieved__c=false;
        OppKPI1.Core_KPI_Total_Price__c=decimal.valueOf('9000');
        OppKPI1.Core_Opp_KPI_Type__c='Salesforce Pipeline $';
        insert OppKPI1;
        
        OppKPI1.Core_KPI_Total_Price__c=decimal.valueOf('10000');
        update OppKPI1;
        List<Core_Goal__c> GoalLst= new List<Core_Goal__c>();
        GoalLst.add(Goal);
        newKPIList.add(OppKPI);
        newKPIList.add(OppKPI1);  
        //Core_Opp_KPI_Handler.updDWGonInstUpdtKPI(newKPIList,oldKPIMap,false);
        system.assertEquals(OppKPI1<>null, true);   
        delete OppKPI1;
        Test.stopTest(); 
    }  
    testMethod static void InsertOppTest5() {
        Profile pr = [SELECT id, Name FROM Profile WHERE Name='IT Admin'];
        usr = [SELECT id, Name, isActive FROM User WHERE ProfileId = :pr.Id AND isActive = true LIMIT 1];
        Test.startTest();
        createTriggerExecutions();
        Opportunity opportunityInstance= CreateOpportunity();
        
        Core_Goal__c Goal= new Core_Goal__c();
        Goal.Name='Test Goal';
        Goal.Core_Goal_Category__c='Assigned';
        Goal.Core_Goal_BU_Focus_Area__c='CCG vPro Deal $';
        Goal.Core_Goal_Criteria__c='Drive vPro branded revenue w/win-back on vPro, sell-up to vPro, sell-up to Xeon Wkstn, or vPro refresh (i.e. non-vPro to vPro, vPro ci5 to vPro ci7, core to vPro Xeon Wkstn, vPro refresh). Alignment w/SMG BU Segment Director';
        Goal.Core_Opportunity__c=opportunityInstance.Id;
        Goal.Core_Goal_KPI_Match_Flag__c=false;
        Goal.Core_Goal_Owner__c=usr.Id;
        insert Goal;
        Core_Oppty_KPI_New__c OppKPI = new Core_Oppty_KPI_New__c();
        OppKPI.Name='DCG Cloud New Services Deal #';
        OppKPI.Core_KPI_Opportunity__c=opportunityInstance.Id;
        OppKPI.Core_KPI_Achieved__c=false;
        insert OppKPI;         
        OppKPI.Name='Test 123';
        update OppKPI; 
        oldKPIMap.put(OppKPI.id,OppKPI);
        //Core_Opp_KPI_Handler.updDWGonInstUpdtKPI(newKPIList,oldKPIMap,true);
        system.assertEquals(oldKPIMap.isEmpty(), false);      
        Test.stopTest(); 
    }  
    
    testMethod static void InsertOppTest6() {
        Test.startTest();
        createTriggerExecutions();
        Opportunity opportunityInstance= CreateOpportunity();
        Profile pr = [SELECT id, Name FROM Profile WHERE Name='IT Admin'];
        usr = [SELECT id, Name, isActive FROM User WHERE ProfileId = :pr.Id AND isActive = true LIMIT 1];  
        SObjectType r = ((SObject)Type.forName('Schema','Account').newInstance()).getSObjectType();
        Id recTypeId = r.getDescribe().getRecordTypeInfosByDeveloperName().get(Label.Pricing_Tender_Account_RecordType_IntelAccount).getRecordTypeId();
        Account accountInstance1 = new Account();
        accountInstance1.name = 'TestAccount1';
        accountInstance1.RecordTypeId = recTypeId;
        accountInstance1.BillingCountryCode = 'USA';
        accountInstance1.BIllingStateCode = 'AL';
        accountInstance1.BillingCity = 'Alabama12';
        accountInstance1.BillingStreet = 'test12';  
        //accountInstance1.Core_CIM_ID__c='10103326';
        accountInstance1.Core_Sales_Groups__c=Core_CRM_Utility.getSalesGroupAPI();
        accountInstance1.Industry='Health and Life Sciences'; 
        accountInstance1.Core_Sub_Industry__c='Biotechnology'; 
        insert accountInstance1;     
        Opportunity opportunityInstance11 = new Opportunity();
        opportunityInstance11.CloseDate = System.Today().addDays(24);
        opportunityInstance11.StageName ='Define';
        opportunityInstance11.Name ='Test OppName new';
        opportunityInstance11.AccountId = accountInstance1.Id;
        opportunityInstance11.Core_First_Customer_Ship_Date__c=system.today().addDays(5);
        opportunityInstance11.Core_Production_End_Date__c =System.Today().addDays(-10);
        opportunityInstance11.Core_Opportunity_Type__c='Design: Original';
        opportunityInstance11.Core_Loss_Cancel_Details__c='Test opp record';
        opportunityInstance11.Core_Intel_Platform__c='Tiger Lake M';
        opportunityInstance11.Core_Technical_Owner__c =usr.Id;
        opportunityInstance11.Opportunity_Focus__c='';
        insert opportunityInstance11;
        system.assertEquals(opportunityInstance11<>null, true);
        
        Core_Goal__c Goal= new Core_Goal__c();
        Goal.Name='Test Goal';
        Goal.Core_Goal_Category__c='Assigned';
        Goal.Core_Goal_BU_Focus_Area__c='CCG vPro Deal $';
        Goal.Core_Goal_Criteria__c='Drive vPro branded revenue w/win-back on vPro, sell-up to vPro, sell-up to Xeon Wkstn, or vPro refresh (i.e. non-vPro to vPro, vPro ci5 to vPro ci7, core to vPro Xeon Wkstn, vPro refresh). Alignment w/SMG BU Segment Director';
        Goal.Core_Opportunity__c=opportunityInstance.Id;
        Goal.Core_Goal_KPI_Match_Flag__c=false;
        Goal.Core_Goal_Owner__c=usr.Id;
        insert Goal;
        Core_Goal__c Goal1= new Core_Goal__c();
        Goal1.Name='Test Goal1';
        Goal1.Core_Goal_Category__c='Assigned';
        Goal1.Core_Goal_BU_Focus_Area__c='CCG vPro Deal $';
        Goal1.Core_Goal_Criteria__c='Drive vPro branded revenue w/win-back on vPro, sell-up to vPro, sell-up to Xeon Wkstn, or vPro refresh (i.e. non-vPro to vPro, vPro ci5 to vPro ci7, core to vPro Xeon Wkstn, vPro refresh). Alignment w/SMG BU Segment Director';
        Goal1.Core_Opportunity__c=opportunityInstance11.Id;
        Goal1.Core_Goal_KPI_Match_Flag__c=false;
        Goal1.Core_Goal_Owner__c=usr.Id;
        insert Goal1;
        Core_Oppty_KPI_New__c OppKPI = new Core_Oppty_KPI_New__c();
        OppKPI.Name='DCG Cloud New Services Deal #';
        OppKPI.Core_KPI_Opportunity__c=opportunityInstance.Id;
        OppKPI.Core_KPI_Achieved__c=false;
        insert OppKPI;              
        Test.stopTest(); 
    } 
    
    static testmethod void insertCommissionTransactionsAllAchieved(){
        List<Opportunity> lstOpp = [select Id,Name,Core_Commissionable__c,core_approval_status__c,StageName,Core_Date_Submitted_for_Approval__c,
                                    AccountId,Core_Opportunity_Type__c,CRM_Unified_Global_Customer_Name__c,Core_Approved_Date__c,Account.Core_Business_Party_Id__c,Account.Name from Opportunity Where Name='OpportunityKPICommissionTest' limit 1];
        List<OpportunityLineItem> oppForKPIItems = [select id,Name,Core_Claim_Date__c from OpportunityLineItem Where OpportunityId=: lstOpp[0].Id];
        List<Core_Commission_KPI_Mappings__c> listFunctionalityNameKPIMappings = [Select Id,Name,Core_KPI_Name_Nm__c,Core_Event_Type__c,Core_Aggregate_Type__c,Core_KPI_Field__c,Core_IsActive__c,Core_KPI_Start_Dt__c,Core_KPI_End_Dt__c
                                                                                  From Core_Commission_KPI_Mappings__c];
        Product2 p = [SELECT Id from Product2 WHERE Name = 'Test Product KPI' LIMIT 1];
        List<CORE_OPPTY_KPI_NEW__C> lstkpi = new List<CORE_OPPTY_KPI_NEW__C>();
        lstkpi.add(new CORE_OPPTY_KPI_NEW__C(Name = listFunctionalityNameKPIMappings[0].Core_KPI_Name_Nm__c,Core_KPI_Opportunity__c = lstOpp[0].Id,
                                             Core_KPI_Achieved__c = true, Core_KPI_Total_Price__c = 1200,Core_IsActive__c = true,Core_Opportunity_KPI_Batch_ID__c='12345',
                                             Core_Opportunity_Product__c = oppForKPIItems[0].Id,Core_Opp_KPI_Product__c = p.Id,Core_Refresh_Type__c = 'Incremental'));
        lstkpi.add(new CORE_OPPTY_KPI_NEW__C(Name = listFunctionalityNameKPIMappings[1].Core_KPI_Name_Nm__c,Core_KPI_Opportunity__c = lstOpp[0].Id,
                                             Core_KPI_Achieved__c = true, Core_KPI_Total_Price__c = 1200,Core_IsActive__c = true,Core_Opportunity_KPI_Batch_ID__c='12345',
                                             Core_Opportunity_Product__c = oppForKPIItems[0].Id,Core_Opp_KPI_Product__c = p.Id,Core_Refresh_Type__c = 'Incremental'));
        lstkpi.add(new CORE_OPPTY_KPI_NEW__C(Name = listFunctionalityNameKPIMappings[0].Core_KPI_Name_Nm__c,Core_KPI_Opportunity__c = lstOpp[0].Id,
                                             Core_KPI_Achieved__c = true, Core_KPI_Total_Price__c = 1200,Core_IsActive__c = true,Core_Opportunity_KPI_Batch_ID__c='12345',
                                             Core_Opportunity_Product__c = oppForKPIItems[0].Id,Core_Opp_KPI_Product__c = p.Id,Core_Refresh_Type__c = 'Incremental'));
        lstkpi.add(new CORE_OPPTY_KPI_NEW__C(Name = listFunctionalityNameKPIMappings[2].Core_KPI_Name_Nm__c,Core_KPI_Opportunity__c = lstOpp[0].Id,
                                             Core_KPI_Achieved__c = true, Core_KPI_Total_Price__c = 1200,Core_IsActive__c = true,Core_Opportunity_KPI_Batch_ID__c='12345',
                                             Core_Opportunity_Product__c = oppForKPIItems[0].Id,Core_Opp_KPI_Product__c = p.Id,Core_Refresh_Type__c = 'Incremental'));
        
        System.runAs(Core_Test_Utility.systemAdminUser) {
            Test.startTest();
            insert lstkpi;
            Test.stopTest(); 
        }
        System.assertEquals('Approved',lstOpp[0].core_approval_status__c);
    }
    
    static testmethod void insertCommissionTransactionsNotAchieved(){
        List<Opportunity> lstOpp = [select Id,Name,Core_Commissionable__c,core_approval_status__c,StageName,Core_Date_Submitted_for_Approval__c,
                                    AccountId,Core_Opportunity_Type__c,CRM_Unified_Global_Customer_Name__c,Core_Approved_Date__c,Account.Core_Business_Party_Id__c,Account.Name from Opportunity Where Name='OpportunityKPICommissionTest' limit 1];
        List<CORE_OPPTY_KPI_NEW__C> kpis = [SELECT ID, CORE_KPI_OPPORTUNITY__C, NAME, CORE_OPP_KPI_PRODUCT__R.CORE_INF_KPI_PRODGROUP__C,Core_Opportunity_KPI_Batch_ID__c,Core_IsKPI_Processed__c,
                                            CORE_KPI_TOTAL_PRICE__C FROM CORE_OPPTY_KPI_NEW__C WHERE Core_KPI_Opportunity__c =: lstOpp[0].Id];
        for (CORE_OPPTY_KPI_NEW__C okpi: kpis) {
            okpi.Core_IsKPI_Processed__c = false;
            okpi.Core_KPI_Achieved__c = false;
            okpi.Core_IsActive__c = true;
        }
        List<Core_Commissionable_Transaction__c> lstComm = new List<Core_Commissionable_Transaction__c>();
        lstComm.add(new Core_Commissionable_Transaction__c(Core_Opportunity__c = lstOpp[0].Id,Core_Milestone_Area__c = kpis[0].Name,
                                                           Core_Status__c = 'Approved',Core_Transaction_Timestamp__c =  System.Date.today()-1,
                                                           Core_Last_Approved_Date__c =  System.today(),Core_Source_ID__c= lstOpp[0].Id));
        
        System.runAs(Core_Test_Utility.systemAdminUser) {
            update kpis;
            insert lstComm;
            lstOpp[0].StageName = 'Design';
            lstOpp[0].core_approval_status__c = 'Recalled';
            //lstOpp[0].Core_DesignWin_KPI_Txt__c = '';
            Update lstOpp[0];
        } 
        System.assertNotEquals('Approved',lstOpp[0].core_approval_status__c);
        Test.startTest();
        Core_CommissionableTransactions.alreadyAddedCommissionableTransactions = false;
        Core_CommissionableTransactions.addCommissionableTransactionsFromKPI(null,kpis,true,false);       
        Test.stopTest();          
    }
    
    static testmethod void testUpdateKPIProcessFlag(){
        List<CORE_OPPTY_KPI_NEW__C> lstkpi = [SELECT ID FROM CORE_OPPTY_KPI_NEW__C WHERE CORE_KPI_ACHIEVED__C = TRUE];
        Id recId = lstkpi[0].Id;
        Core_CommissionableTransactions.updateKPIProcessFlag(lstkpi);
        boolean lstkpiFlag = [SELECT Id,Core_IsKPI_Processed__c FROM CORE_OPPTY_KPI_NEW__C where Id =:recId limit 1][0].Core_IsKPI_Processed__c;
        system.assertEquals(lstkpiFlag, true);
    }
}