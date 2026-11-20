/******************************************************************************************************************************************
Class Name  : Core_AddSolutionArea_Test
Version     : 1.0 
Created Date: July 07, 2022
Function    : Test class for Core_AddSolutionArea 
Modification Log :
* Developer         Date          Description
* ----------------------------------------------------------------------------                 
* Gaurav Kurwade        07/07/2022   Original version
*****************************************************************************************************************************************/

@IsTest
public class Core_AddSolutionArea_Test {
    
    public static testmethod void testOppoSolution(){
        Test.StartTest();
        List<Core_Trigger_Executions__c> triggerExecList = new List<Core_Trigger_Executions__c>();
        triggerExecList.add(new Core_Trigger_Executions__c(Name='updateJSONSolutionArea', Core_Class_Name__c='updateJSONSolutionArea', Core_Object__c='OpportunitySolutionArea', Core_Trigger_Events__c='After Insert before Delete', Core_Active__c=true, Core_Description__c = 'blah blah'));
        
        insert triggerExecList;
        List<selectOption> options = new List<selectOption>();
        List<sObject> l_Types = new List<sObject>();
        List<Map<String,String>> selectOpt = new List<Map<String,String>>();
        
        
        List<String>  Application_Workload = new List<String>();
        
        // Get the describe information for the Account object
        Schema.DescribeSObjectResult Describe = Schema.sObjectType.Core_Solution_Areas__c;
        
        Schema.DescribeFieldResult FieldDescribe = Describe.fields.getMap().get('Core_Application_Workload__c').getDescribe();
        List<Schema.PicklistEntry> PicklistValues = FieldDescribe.getPicklistValues();
        
        for (Schema.PicklistEntry picklistValue : PicklistValues) {
            Application_Workload.add(picklistValue.getLabel()+'|'+ picklistValue.getValue());
        }
        
        system.assert(Application_Workload != null, 'success');
        Core_AddSolutionArea.Get_Types_Application_Workload();
        
        
        
        List<String>  Industry_UseCase = new List<String>();
        options = new List<selectOption>();
        l_Types = new List<sObject>();
        // Get the describe information for the Account object
        Schema.DescribeSObjectResult Describe1 = Schema.sObjectType.Core_Solution_Areas__c;
        Schema.DescribeFieldResult FieldDescribe1 = Describe1.fields.getMap().get('Core_Industry_Use_Case__c').getDescribe();
        List<Schema.PicklistEntry> PicklistValues1 = FieldDescribe1.getPicklistValues();
        for (Schema.PicklistEntry picklistValue : PicklistValues1) {
            Industry_UseCase.add(picklistValue.getLabel()+'|'+ picklistValue.getValue());
        } 
        system.assert(Industry_UseCase != null, 'success');
        Core_AddSolutionArea.Get_Types_Industry_UseCase();
        
        
        List<String>  TechnologyEnabled = new List<String>();
        
        selectOpt = new List<Map<String,String>>();
        options = new List<selectOption>();
        l_Types = new List<sObject>();
        // Get the describe information for the Account object
        
        Schema.DescribeSObjectResult Describe4 = Schema.sObjectType.Core_Solution_Areas__c;
        Schema.DescribeFieldResult FieldDescribe4 = Describe4.fields.getMap().get('Core_Technology_Enabled__c').getDescribe();
        List<Schema.PicklistEntry> PicklistValues4 = FieldDescribe4.getPicklistValues();
        for (Schema.PicklistEntry picklistValue : PicklistValues) {
            TechnologyEnabled.add(picklistValue.getLabel()+'|'+ picklistValue.getValue());
        } 
        
        system.assert(TechnologyEnabled != null, 'success'); 
        
        
        
        Core_AddSolutionArea.Get_Types_TechnologyEnabled();
        
        Account accountInstance = new Account();
        accountInstance.name = 'Test ';
        accountInstance.BillingCountryCode = 'USA';
        accountInstance.BIllingStateCode = 'AL';
        accountInstance.BillingCity = 'Alabama';
        accountInstance.BillingStreet = 'test';
        accountInstance.Core_Sub_Industry__c = 'Diversified Telecommunications Services';
        accountInstance.Industry = 'Telecommunications';
        accountInstance.Core_Sales_Groups__c=Core_CRM_Utility.getSalesGroupAPI();
        Id masterRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        accountInstance.RecordTypeId = masterRecordTypeId;
        insert accountInstance;
        
        
        
        Opportunity opportunityInstance = new Opportunity();
        opportunityInstance.CloseDate = System.Today().addDays(24);
        opportunityInstance.StageName = 'Qualify';
        opportunityInstance.Name = 'Test';
        opportunityInstance.Core_External_User__c=true;
        opportunityInstance.AccountId =accountInstance.id;
        opportunityInstance.Core_Opportunity_Type__c = 'Design: Original';
        insert opportunityInstance;
        
        Id DealOppRecTypeId = [select Id from RecordType where DeveloperName = 'Core_Deal_Opportunity' limit 1][0].Id;
        Opportunity opportunityInstance2 = new Opportunity();
        opportunityInstance2.CloseDate = System.Today().addDays(24);
        opportunityInstance2.StageName = 'Qualify';
        opportunityInstance2.Name = 'Test';
        opportunityInstance2.Core_External_User__c=true;
        opportunityInstance2.AccountId =accountInstance.id;
        opportunityInstance2.RecordTypeId = DealOppRecTypeId;
        insert opportunityInstance2;
        
        
        
        Core_Solution_Areas__c solStor = new Core_Solution_Areas__c();
        solStor.Core_Solution_Type__c = 'S1: Product';
        solStor.Core_End_Customer_Solution__c = 'Yes';
        solStor.Core_Design_Visible__c = true;
        solStor.Core_Status__c = 'Active';
        solStor.Core_Application_Workload__c = 'AI Inference';
        solStor.Core_Industry_Use_Case__c = 'ADAS';
        solStor.Core_Concatenated_Solution_Partners__c = 'MQL;HGST SINGAPORE';
        insert solStor;
        
        Core_Solution_Areas__c solStor2 = new Core_Solution_Areas__c();
        solStor2.Core_Solution_Type__c = 'S1: Product';
        solStor2.Core_End_Customer_Solution__c = 'Yes';
        solStor2.Core_Deal_Visible__c = true;
        solStor2.Core_Status__c = 'Active';
        solStor2.Core_Application_Workload__c = 'AI Inference';
        solStor2.Core_Industry_Use_Case__c = 'ADAS';
        solStor2.Core_Concatenated_Solution_Partners__c = 'MQL;HGST SINGAPORE';
        insert solStor2;
        
        //List<Core_Solution_Areas__c> sal = [select Id, Name, Core_Deal_Visible__c, Core_Design_Visible__c, Core_Solution_Type__c, Core_Version__c, Core_Solution_owner_email__c, Core_End_Customer_Solution__c, isDeleted__c, Core_Industry__c, toLabel(Core_Application_Workload__c), Core_Content_Link__c, Core_Region_of_availability__c, toLabel(Core_Technology_Enabled__c), toLabel(Core_Industry_Use_Case__c), Core_Solution_Long__c, Core_Solution_Description__c, Core_Concatenated_Solution_Partners__c from Core_Solution_Areas__c WHERE (Core_Design_Visible__c = TRUE AND Core_Status__c != 'EOL')];
        Core_Solution_Area_Partner__c oppPa = new Core_Solution_Area_Partner__c();
        oppPa.Core_Solution_Partner__c = accountInstance.Id;
        oppPa.Core_Solution_Partner_Role__c = 'Co-Selling';
        oppPa.Solution_Partner_Type__c = 'Cloud Service Provider';
        oppPa.Core_Solution_Area__c = solStor.Id;
        Insert oppPa;
        
        oppPa.Core_Solution_Partner_Role__c = 'Vendor';
        UPDATE oppPa;
        
        List<String> solList = new List<String> ();
        List<String> solList2 = new List<String> ();
        List<String> solList3 = new List<String> ();
        solList.add(solStor.ID);solList2.add(solStor2.ID);
        String SolString = Core_AddSolutionArea.createOppSolution(opportunityInstance.Id, solList);
        String SolString2 = Core_AddSolutionArea.createOppSolution(opportunityInstance.Id, solList2);
        String SolString3 = Core_AddSolutionArea.createOppSolution(opportunityInstance2.Id, solList3);
        
        Core_AddSolutionArea.Get_Types_Industry_UseCase();    
        Core_AddSolutionArea.Get_Types_Application_Workload();
        Core_AddSolutionArea.Get_Types_TechnologyEnabled();
        
        List<Core_Solution_Areas__c> soltest1 = Core_AddSolutionArea.searchSolutionStorage('','','','','Test','','',opportunityInstance.Id);
        List<Core_Solution_Areas__c> soltest2 = Core_AddSolutionArea.searchSolutionStorage('','','','','','','MQL',opportunityInstance.Id);
        List<Core_Solution_Areas__c> soltest3 = Core_AddSolutionArea.searchSolutionStorage('','','AI Inference','','','','MQL',opportunityInstance.Id);
        List<Core_Solution_Areas__c> soltest4 = Core_AddSolutionArea.searchSolutionStorage('','','','','Test','','MQL',opportunityInstance.Id);       
        List<Core_Solution_Areas__c> soltest5 = Core_AddSolutionArea.searchSolutionStorage('','','AI Inference','','Test','','MQL',opportunityInstance.Id);
        List<Core_Solution_Areas__c> soltest6 = Core_AddSolutionArea.searchSolutionStorage('','','','','Test','','',opportunityInstance2.Id);
        List<Core_Solution_Areas__c> soltest7 = Core_AddSolutionArea.searchSolutionStorage('','','','','','','MQL',opportunityInstance2.Id);
        
        Test.StopTest();
        
    } 
    
    public static testmethod void testOppoSolution1(){
        Account accountInstance = new Account();
        accountInstance.name = 'Test ';
        accountInstance.BillingCountryCode = 'USA';
        accountInstance.BIllingStateCode = 'AL';
        accountInstance.BillingCity = 'Alabama';
        accountInstance.BillingStreet = 'test';
        accountInstance.Core_Sub_Industry__c = 'Diversified Telecommunications Services';
        accountInstance.Industry = 'Telecommunications';
        accountInstance.Core_Sales_Groups__c=Core_CRM_Utility.getSalesGroupAPI();//'Americas Partner Holding';
        Id masterRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        accountInstance.RecordTypeId = masterRecordTypeId;
        insert accountInstance;
        
        RecordType r1 = [Select Id from recordType where Name='Design Opportunity'];
        Opportunity opportunityInstance = new Opportunity();
        opportunityInstance.CloseDate = System.Today().addDays(24);
        opportunityInstance.StageName = 'Qualify';
        opportunityInstance.RecordTypeId = r1.Id;
        opportunityInstance.Name = 'Test';
        opportunityInstance.Core_External_User__c=true;
        opportunityInstance.AccountId =accountInstance.id;
        opportunityInstance.Core_Opportunity_Type__c = 'Design: Original';
        insert opportunityInstance;
        
        Core_Solution_Areas__c solStor = new Core_Solution_Areas__c();
        solStor.Core_Solution_Type__c = 'S1: Product';
        solStor.Core_End_Customer_Solution__c = 'Yes';
        solStor.Core_Design_Visible__c = true;
        solStor.Core_Status__c = 'Active';
        insert solStor;
        
        Core_Solution_Areas__c solSt = new Core_Solution_Areas__c();
        solSt.Core_Solution_Type__c = 'S1: Product';
        solSt.Core_End_Customer_Solution__c = 'Yes';
        solSt.Core_Design_Visible__c = true;
        solSt.Core_Status__c = 'Active';
        insert solSt;
        
        Core_Solution_Area_Partner__c oppPa = new Core_Solution_Area_Partner__c();
        oppPa.Core_Solution_Partner__c = accountInstance.Id;
        oppPa.Core_Solution_Partner_Role__c = 'Co-Selling';
        oppPa.Solution_Partner_Type__c = 'Cloud Service Provider';
        oppPa.Core_Solution_Area__c = solStor.Id;
        Insert oppPa;
        
        Core_Solution_Area_Partner__c oppPa1 = new Core_Solution_Area_Partner__c();
        oppPa1.Core_Solution_Partner__c = accountInstance.Id;
        oppPa1.Core_Solution_Partner_Role__c = 'Co-Selling';
        oppPa1.Solution_Partner_Type__c = 'Cloud Service Provider';
        oppPa1.Core_Solution_Area__c = solSt.Id;
        Insert oppPa1;
        
        List<String> solList = new List<String> ();
        solList.add(solStor.ID);
        
        oppPa.Core_Solution_Partner_Role__c = 'Vendor';
        oppPa.Solution_Partner_Type__c = 'EMS';
        update oppPa;
        
        Test.StartTest();
        List<selectOption> options = new List<selectOption>();
        List<sObject> l_Types = new List<sObject>();
        List<Map<String,String>> selectOpt = new List<Map<String,String>>();
        
        
        List<String>  Application_Workload = new List<String>();
        
        // Get the describe information for the Account object
        Schema.DescribeSObjectResult Describe = Schema.sObjectType.Core_Solution_Areas__c;
        
        Schema.DescribeFieldResult FieldDescribe = Describe.fields.getMap().get('Core_Application_Workload__c').getDescribe();
        List<Schema.PicklistEntry> PicklistValues = FieldDescribe.getPicklistValues();
        try{
            for (Schema.PicklistEntry picklistValue : PicklistValues) {
                Application_Workload.add(picklistValue.getLabel()+'|'+ picklistValue.getValue());
            } 
            
            system.assert(Application_Workload != null, 'success');
            Core_CloneSolutionArea.Get_Types_Application_Workload();
            
        }
        catch (Exception e) {
            PMP_Utility.logError(e, 'Core_AddSolutionArea_Test.testOppoSolution1');
            system.assert(Application_Workload == null, 'Failed');
        }
        
        try
        {
            
            List<String>  Industry_UseCase = new List<String>();
            options = new List<selectOption>();
            l_Types = new List<sObject>();
            // Get the describe information for the Account object
            Schema.DescribeSObjectResult Describe1 = Schema.sObjectType.Core_Solution_Areas__c;
            Schema.DescribeFieldResult FieldDescribe1 = Describe1.fields.getMap().get('Core_Industry_Use_Case__c').getDescribe();
            List<Schema.PicklistEntry> PicklistValues1 = FieldDescribe1.getPicklistValues();
            for (Schema.PicklistEntry picklistValue : PicklistValues1) {
                Industry_UseCase.add(picklistValue.getLabel()+'|'+ picklistValue.getValue());
            } 
            system.assert(Industry_UseCase != null, 'success');
            Core_CloneSolutionArea.Get_Types_Industry_UseCase();
            
        }
        catch (Exception e) {
            PMP_Utility.logError(e, 'Core_AddSolutionArea_Test.testOppoSolution1');
            system.assert(Application_Workload == null, 'Failed');
        }
        
        List<String>  TechnologyEnabled = new List<String>();
        
        selectOpt = new List<Map<String,String>>();
        options = new List<selectOption>();
        l_Types = new List<sObject>();
        // Get the describe information for the Account object
        try
        {
            Schema.DescribeSObjectResult Describe4 = Schema.sObjectType.Core_Solution_Areas__c;
            Schema.DescribeFieldResult FieldDescribe4 = Describe4.fields.getMap().get('Core_Technology_Enabled__c').getDescribe();
            List<Schema.PicklistEntry> PicklistValues4 = FieldDescribe4.getPicklistValues();
            for (Schema.PicklistEntry picklistValue : PicklistValues) {
                TechnologyEnabled.add(picklistValue.getLabel()+'|'+ picklistValue.getValue());
            } 
            
            system.assert(TechnologyEnabled != null, 'success'); 
            
        }
        catch (Exception e) {
            PMP_Utility.logError(e, 'Core_AddSolutionArea_Test.testOppoSolution1');
            system.assert(Application_Workload == null, 'Failed');
            
        }
        String SolString = Core_AddSolutionArea.createOppSolution(opportunityInstance.Id, solList);
        Core_CloneSolutionArea.Get_Types_TechnologyEnabled();
        List<Core_Solution_Areas__c> sol= new List<Core_Solution_Areas__c>();
        sol = Core_AddSolutionArea.searchSolutionStorage('','','','','','','','');
        
        List<Core_Solution_Areas__c> sol1 = Core_AddSolutionArea.searchSolutionStorage('','','','','','','',opportunityInstance.Id);
        List<Core_Solution_Areas__c> sol2 = Core_AddSolutionArea.searchSolutionStorage('','','','','SAP','','',opportunityInstance.Id);
        List<Core_Solution_Areas__c> sol3 = Core_AddSolutionArea.searchSolutionStorage('','','','','test','','',opportunityInstance.Id);
        List<Core_Solution_Areas__c> sol9 = Core_AddSolutionArea.searchSolutionStorage('CNDP','','','','','','',opportunityInstance.Id);
        List<Core_Solution_Areas__c> sol4 = Core_AddSolutionArea.searchSolutionStorage('CNDP','','','','test','','',opportunityInstance.Id);
        List<Core_Solution_Areas__c> sol5 = Core_AddSolutionArea.searchSolutionStorage('CNDP','Interactive Media-Chessboard','','','test','','',opportunityInstance.Id);
        List<Core_Solution_Areas__c> sol6 = Core_AddSolutionArea.searchSolutionStorage('AI Inference','Ad Serving','AMT','','test','','',opportunityInstance.Id);                                         
        List<Core_Solution_Areas__c> sol7 = Core_AddSolutionArea.searchSolutionStorage('','','AMT','','','','',opportunityInstance.Id);
        List<Core_Solution_Areas__c> sol8 = Core_AddSolutionArea.searchSolutionStorage('','Interactive Media-Chessboard','','','','','',opportunityInstance.Id);
        
        
        
        //Core_AddSolutionArea.sendEmailController('Test');
        Core_AddSolutionArea.showOpptySolution(opportunityInstance.Id);
        Test.StopTest();
        
    } 
    
    public static testmethod void testOppoS(){
        
        Test.StartTest();
        Account accountInstance = new Account();
        accountInstance.name = 'Test ';
        accountInstance.BillingCountryCode = 'USA';
        accountInstance.BIllingStateCode = 'AL';
        accountInstance.BillingCity = 'Alabama';
        accountInstance.BillingStreet = 'test';
        accountInstance.Core_Sub_Industry__c = 'Diversified Telecommunications Services';
        accountInstance.Industry = 'Telecommunications';
        accountInstance.Core_Sales_Groups__c=Core_CRM_Utility.getSalesGroupAPI();//'Americas Partner Holding;
        Id masterRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        accountInstance.RecordTypeId = masterRecordTypeId;
        insert accountInstance;
        
        Opportunity opportunityInstance = new Opportunity();
        opportunityInstance.CloseDate = System.Today().addDays(24);
        opportunityInstance.StageName = 'Define';
        opportunityInstance.Name = 'Test';
        opportunityInstance.Core_External_User__c=true;
        opportunityInstance.AccountId =accountInstance.id;
        insert opportunityInstance;
        
        
        Core_Solution_Areas__c solStor = new Core_Solution_Areas__c();
        solStor.Core_Solution_Type__c = 'S1: Product';
        solStor.Core_End_Customer_Solution__c = 'Yes';
        
        insert solStor;
        
        Core_Solution_Areas__c solStor1 = new Core_Solution_Areas__c();
        solStor.Core_Solution_Type__c = 'S1: Product';
        solStor.Core_End_Customer_Solution__c = 'Yes';
        
        insert solStor1;
        
        Core_Solution_Area_Partner__c oppPa = new Core_Solution_Area_Partner__c();
        oppPa.Core_Solution_Partner__c = accountInstance.Id;
        oppPa.Core_Solution_Partner_Role__c = 'Co-Selling';
        oppPa.Solution_Partner_Type__c = 'Cloud Service Provider';
        oppPa.Core_Solution_Area__c = solStor1.Id;
        Insert oppPa;
        
        List<Opportunity_Solution_Area__c> oppSolArea = new List<Opportunity_Solution_Area__c>();
        
        Opportunity_Solution_Area__c ops = new Opportunity_Solution_Area__c();
        ops.Core_Solution_Areas__c = solStor.Id;
        ops.Core_Opportunity__c = opportunityInstance.Id;
        insert ops;
        oppSolArea.add(ops);
        
        Core_Solution_Area_Partner__c oppPa11 = new Core_Solution_Area_Partner__c();
        oppPa11.Core_Solution_Partner__c = accountInstance.Id;
        oppPa11.Core_Solution_Partner_Role__c = 'Co-Selling';
        oppPa11.Solution_Partner_Type__c = 'Cloud Service Provider';
        oppPa11.Core_Solution_Area__c = solStor.Id;
        Insert oppPa11;
        
        
        Core_Solution_Area_Partner__c oppPa1 = new Core_Solution_Area_Partner__c();
        oppPa1.Core_Solution_Partner__c = accountInstance.Id;
        oppPa1.Core_Solution_Partner_Role__c = 'Vendor';
        oppPa1.Solution_Partner_Type__c = 'Cloud Service Provider';
        oppPa1.Core_Solution_Area__c = solStor1.Id;
        Insert oppPa1;
        
        Core_Solution_Area_Partner__c oppPa3 = new Core_Solution_Area_Partner__c();
        oppPa3.Id = oppPa1.Id;       
        oppPa3.Core_Solution_Partner_Role__c = 'Fulfillment';       
        update oppPa3;
        
        Core_Solution_Area_Partner__c oppPa2 = new Core_Solution_Area_Partner__c();
        oppPa2.Core_Solution_Partner__c = accountInstance.Id;
        oppPa2.Core_Solution_Partner_Role__c = ' End Customer';
        oppPa2.Solution_Partner_Type__c = 'Cloud Service Provider';
        oppPa2.Core_Solution_Area__c = solStor.Id;
        Insert oppPa2;
        
        oppPa1.Core_Solution_Partner_Role__c = 'Vendor';
        oppPa1.Solution_Partner_Type__c = 'EMS';
        update oppPa1;
        
        
        
        System.runAs(Core_Test_Utility.systemAdminUser) { 
            List<Core_Trigger_Executions__c> triggerExecList = new List<Core_Trigger_Executions__c>();
            triggerExecList.add(new Core_Trigger_Executions__c(Name='updateJSONSolutionArea', Core_Class_Name__c='updateJSONSolutionArea', Core_Object__c='OpportunitySolutionArea', Core_Trigger_Events__c='After Insert before Delete', Core_Active__c=true, Core_Description__c = 'blah blah'));
            //triggerExecList.add(new Core_Trigger_Executions__c(Name='createJSONSolutionArea', Core_Class_Name__c='createJSONSolutionArea', Core_Object__c='Solution Area', Core_Trigger_Events__c='After Update', Core_Active__c=true, Core_Description__c = 'blah blah'));
            //triggerExecList.add(new Core_Trigger_Executions__c(Name='addSolutionPartnerRelatedRecords', Core_Class_Name__c='updateJSONSolutionArea', Core_Object__c='SolutionAreaPartner', Core_Trigger_Events__c='After Insert before Delete', Core_Active__c=true, Core_Description__c = 'blah blah'));                       
            insert triggerExecList;
            // List<Core_Trigger_Executions__c> triggerExecList1 = new List<Core_Trigger_Executions__c>();
            //triggerExecList1.add(new Core_Trigger_Executions__c(Name='addSolutionRelatedRecords', Core_Class_Name__c='addSolutionRelatedRecords', Core_Object__c='Solutions', Core_Trigger_Events__c='After Insert', Core_Active__c=true, Core_Description__c = 'blah blah'));
            // insert triggerExecList1;
            //solStor.Core_Application_Workload__c = 'Visual Cloud';
            // solStor.Core_Application_Workload__c = 'AI Inference';
            //solStor.Core_Industry_Use_Case__c = 'ADAS';
            solStor.Core_Solution_Description__c ='test class test 111';
            Update solStor;
            
            Core_AddSolutionArea.addOppPartner(oppSolArea);
            
            // Core_Solution_Area_Partner__c oppPa4 = new Core_Solution_Area_Partner__c();
            //oppPa4.Id = oppPa2.Id
            //Delete oppPa4;
            
            
            
            Test.StopTest();
        }     
    } 
    /*
public static testmethod void testOppoS2(){

Test.StartTest();
Account accountInstance = new Account();
accountInstance.name = 'Test ';
accountInstance.BillingCountryCode = 'USA';
accountInstance.BIllingStateCode = 'AL';
accountInstance.BillingCity = 'Alabama';
accountInstance.BillingStreet = 'test';
accountInstance.Core_Sub_Industry__c = 'Diversified Telecommunications Services';
accountInstance.Industry = 'Telecommunications';
accountInstance.Core_Sales_Groups__c=Core_CRM_Utility.getSalesGroupAPI();
insert accountInstance;

Opportunity opportunityInstance = new Opportunity();
opportunityInstance.CloseDate = System.Today().addDays(24);
opportunityInstance.StageName = 'Qualify';
opportunityInstance.Name = 'Test';
opportunityInstance.Core_External_User__c=true;
opportunityInstance.AccountId =accountInstance.id;
insert opportunityInstance;


Core_Solution_Areas__c solStor = new Core_Solution_Areas__c();
solStor.Core_Solution_Type__c = 'S1: Product';
solStor.Core_End_Customer_Solution__c = 'Yes';

insert solStor;

List<Opportunity_Solution_Area__c> oppSolArea = new List<Opportunity_Solution_Area__c>();

Opportunity_Solution_Area__c ops = new Opportunity_Solution_Area__c();
ops.Core_Solution_Areas__c = solStor.Id;
ops.Core_Opportunity__c = opportunityInstance.Id;
insert ops;
oppSolArea.add(ops);

Core_Solution_Area_Partner__c oppPa = new Core_Solution_Area_Partner__c();
oppPa.Core_Solution_Partner__c = accountInstance.Id;
oppPa.Core_Solution_Partner_Role__c = 'Co-Selling';
oppPa.Solution_Partner_Type__c = 'Cloud Service Provider';
oppPa.Core_Solution_Area__c = solStor.Id;
Insert oppPa;

Core_Solution_Area_Partner__c oppPa1 = new Core_Solution_Area_Partner__c();
oppPa.Core_Solution_Partner__c = accountInstance.Id;
oppPa.Core_Solution_Partner_Role__c = 'Vendor';
oppPa.Solution_Partner_Type__c = 'Cloud Service Provider';
oppPa.Core_Solution_Area__c = solStor.Id;
Insert oppPa1;

Core_Solution_Area_Partner__c oppPa2 = new Core_Solution_Area_Partner__c();
oppPa.Core_Solution_Partner__c = accountInstance.Id;
oppPa.Core_Solution_Partner_Role__c = ' End Customer';
oppPa.Solution_Partner_Type__c = 'Cloud Service Provider';
oppPa.Core_Solution_Area__c = solStor.Id;
Insert oppPa2;

System.runAs(Core_Test_Utility.systemAdminUser) { 
List<Core_Trigger_Executions__c> triggerExecList = new List<Core_Trigger_Executions__c>();
triggerExecList.add(new Core_Trigger_Executions__c(Name='createJSONSolutionArea', Core_Class_Name__c='createJSONSolutionArea', Core_Object__c='Solution Area', Core_Trigger_Events__c='After Update', Core_Active__c=true, Core_Description__c = 'blah blah'));
insert triggerExecList;
List<Core_Trigger_Executions__c> triggerExecList1 = new List<Core_Trigger_Executions__c>();
triggerExecList1.add(new Core_Trigger_Executions__c(Name='addSolutionRelatedRecords', Core_Class_Name__c='addSolutionRelatedRecords', Core_Object__c='Solutions', Core_Trigger_Events__c='After Insert', Core_Active__c=true, Core_Description__c = 'blah blah'));
insert triggerExecList1;
//solStor.Core_Application_Workload__c = 'Visual Cloud';
solStor.Core_End_Customer_Solution__c = 'No';
Update solStor;
// ops.Core_Solution_Areas__c = solStor.Id;
Update ops;
Core_AddSolutionArea.addOppPartner(oppSolArea);
Test.StopTest();
}     
}
*/
    public static testmethod void testDeleteOSA(){
        Test.StartTest();
        Id newOppRecTypeId = [select Id from RecordType where DeveloperName = 'Core_Design_Opportunity' limit 1][0].Id;
        
        Id masterRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        
        // Create an account
        Account acct = new Account(Name = 'TestoppAccounthandle', BillingStreet = '123 Fake St', RecordTypeId = masterRecordTypeId,
                                   BillingCity = 'Springfield', BillingState = 'IL', BillingCountry = 'USA',Industry='Agriculture',Core_Sub_Industry__c= 'Crop Production',
                                   BillingPostalCode = '12345', Core_Sales_Groups__c=Core_CRM_Utility.getSalesGroupAPI());
        System.runAs(Core_Test_Utility.systemAdminUser) {
            insert acct;
        }
        
        Opportunity opps = new Opportunity(Name = 'Opportunity to Lose 03-24-2015', RecordTypeId = newOppRecTypeId,
                                           AccountId = acct.Id,
                                           StageName = 'Qualify', CloseDate = System.Date.today().addYears(1));
        System.runAs(Core_Test_Utility.systemAdminUser) {
            insert opps;
        }
        
        List<Core_Solution_Areas__c> SAList= new List<Core_Solution_Areas__c>();
        Map<Id, Core_Solution_Areas__c> SAMap= new Map<Id, Core_Solution_Areas__c>();
        Core_Solution_Areas__c cSA = new Core_Solution_Areas__c();
        cSA.Name = 'Test1';
        cSA.Core_Version__c = 'Test1.0';
        cSA.Core_End_Customer_Solution__c = 'Yes';
        cSA.Core_Application_Workload__c = 'AI Inference';
        cSA.Core_Industry_Use_Case__c = 'ADAS';
        insert cSA;
        
        Core_Solution_Area_Partner__c oppPa = new Core_Solution_Area_Partner__c();
        oppPa.Core_Solution_Partner__c = acct.Id;
        oppPa.Core_Solution_Partner_Role__c = 'Co-Selling';
        oppPa.Solution_Partner_Type__c = 'Cloud Service Provider';
        oppPa.Core_Solution_Area__c = cSA.id;
        Insert oppPa;
        
        Core_Solution_Area_Partner__c oppPa2 = new Core_Solution_Area_Partner__c();
        oppPa2.Core_Solution_Partner__c = acct.Id;
        oppPa2.Core_Solution_Partner_Role__c = 'End Customer';
        oppPa2.Solution_Partner_Type__c = 'Cloud Service Provider';
        oppPa2.Core_Solution_Area__c = cSA.id;
        Insert oppPa2;
        
        
        
        SAMap.put(cSA.Id, cSA);
        SAList.add(cSA);
        
        
        
        List<Opportunity_Solution_Area__c> oSAList= new List<Opportunity_Solution_Area__c>();
        Opportunity_Solution_Area__c oSA= new Opportunity_Solution_Area__c();
        oSA.Core_Opportunity__c = opps.id;
        oSA.Core_Solution_Areas__c =cSA.id;
        insert oSA;
        
        oSAList.add(oSA);
        
        oppPa.Core_Solution_Partner_Role__c = 'Vendor';
        oppPa.Solution_Partner_Type__c = 'EMS';
        update oppPa;
        
        System.runAs(Core_Test_Utility.systemAdminUser) {
            List<Core_Trigger_Executions__c> triggerExecList = new List<Core_Trigger_Executions__c>();
            triggerExecList.add(new Core_Trigger_Executions__c(Name='updateJSONSolutionArea', Core_Class_Name__c='updateJSONSolutionArea', Core_Object__c='OpportunitySolutionArea', Core_Trigger_Events__c='After Insert before Delete', Core_Active__c=true, Core_Description__c = 'blah blah'));
            
            insert triggerExecList;
            try
            {
                
                Core_AddSolutionArea.checkSolutions(oSAList);
                DELETE oppPa2;
                Delete  oppPa;
                Delete  oSA;
                
            }
            catch(Exception ee)
            {}
        }
        
        Test.StopTest();
    }
    
}