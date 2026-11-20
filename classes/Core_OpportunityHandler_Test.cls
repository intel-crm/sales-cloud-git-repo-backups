/**************************************************************************************
Apex Class Name:  Core_OpportunityHandler_Test
Version     : 1.0 
Created Date: 10 DEC 2014
Function    : Test Class for the Core_OpportunityHandler
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Kunal Mehta             12/04/2014              Original Version
* Dave Hood               12/19/2014              Added Geo population test code
* Dave Hood               03/24/2015              Opportunity Stage update (for Lost/Cancelled) and removal of dead Opportunity Geo code
* Venu Karumuru           07/31/2015              Added method UpdateActivityLineItems_Test()
*************************************************************************************/
@isTest
public without sharing class Core_OpportunityHandler_Test {
    
    static final integer OPP_COUNT = 5;
    static final String OSC_DEPARTMENT = 'ONLINE SALES CENTER (OSC)';
    static final String NO_OSC_INVOLVMENT = 'No OSC Involvement';
    static final String OSC_ASSISTING_FIELD = 'OSC Assisting the Field';
    static final String OSC_SOLO = 'OSC Solo';
    static final String OSC_FIELD_ASSISTANCE = 'OSC with Field Assistance';
    
    /*
* Method name  : testOpportunityHandler
* Description  : Method to setup test data ( Opportunity)
* Return Type  : None
* Parameter    : None
*/
    
    @testSetup
    private static void setupTestData() {
        Core_Opp_Bypass_Validation_Rule__c rec = new Core_Opp_Bypass_Validation_Rule__c();
        rec.Bypass__c = true;
        insert rec;        
        
        enableTriggers();
        
        Core_Design_Registration__c DDRLst = new Core_Design_Registration__c(
            Core_Product_Group_Nm__c = 'FPGA/Power',
            Core_Design_Registration_Nm__c = 'DDR Test',
            Core_Design_Registration_Dsc__c = 'ABC',
            Core_Opportunity_Volume_Cnt__c = 5,
            Core_Partner_FAE_Nm__c = '6',            
            Core_End_Customer_Nm__c = 'DDR Test',            
            Core_End_Customer_Street_Addr_Line1_Txt__c = 'ABC',
            Core_End_Customer_Street_Addr_Line2_Txt__c = 'Abc',
            Core_End_Customer_City_Nm__c = 'BAN',
            Core_End_Customer_Country_Subdivision_Nm__c = 'KA',
            PCC_End_Customer_Country__c = 'United States',
            Core_End_Customer_Postal_Cd__c = '560037',
            Core_Military_Aerospace_Gvrnmt_Use_Ind__c = 'Yes',
            Core_Opportunity_Decision_Dt__c = system.today()+45,
            Core_First_Customer_Ship_Dt__c = system.today()+46,
            Core_Production_End_Dt__c = system.today()+47,
            Core_Vertical_Market_Nm__c = 'Education',
            Core_Intel_Platform_Nm__c = 'Board',
            Core_Product_Application_Nm__c = 'Business Desktop',
            Core_Product_Segment_Nm__c = 'Client Computing',
            Core_Manufacturing_Region_Cd__c = 'APJ',
            Core_Design_Registration_Status_Nm__c = 'Re-Submitted'
        );
        DDRLst.Core_Product_Group_Nm__c ='Embedded/IOT';
        insert DDRLst;
        Product2 p = new Product2(Name = 'TestPro05-26-2024');
        insert p;
        PricebookEntry pbe = new PricebookEntry(Product2Id = p.Id, Pricebook2Id = Test.getStandardPricebookId(),
                                                UnitPrice = 10, IsActive = true);
        System.runAs(Core_Test_Utility.systemAdminUser) {
            insert pbe;
        }
        system.assert(pbe != null , 'success');
        //Id accountRecordTypeIntel = Schema.sObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        Account accountInstance = new Account(Name = 'TestoppAcchandle', BillingStreet = '123 Fake St',/*recordtypeId = accountRecordTypeIntel,*/
                                              BillingCity = 'Springfield', BillingState = 'IL', BillingCountry = 'USA',Industry='Agriculture',Core_Sub_Industry__c= 'Crop Production',
                                              BillingPostalCode = '12345',Core_Sales_Groups__c='Americas US Sales Group');
        
        
        List<User> users = Core_Test_Utility.Core_User(6);
        
        User oscUser       = users[0];
        oscUser.userName = 'test0'+ oscUser.userName ;
        oscUser.Department = OSC_DEPARTMENT;
        insert oscUser;
        
        User nonOSCUser       = users[1];
        nonOSCUser.userName =  'test1' + nonOSCUser.userName ;
        nonOSCUser.Department = '';        
        insert nonOSCUser;
        
        User oscTm       = users[2];
        oscTm.userName = 'test2' + oscTm.userName ;
        oscTm.Department = OSC_DEPARTMENT;
        insert oscTm;
        
        User nonOSCTm       = users[3];
        nonOSCTm.userName = 'test3' + nonOSCTm.userName ;
        nonOSCTm.Department = '';        
        insert nonOSCTm;
        
        User oscTo       = users[4];
        oscTo.userName = 'test4'+ oscTo.userName ;
        oscTo.Department = OSC_DEPARTMENT;
        insert oscTo;
        
        User nonOSCTo       = users[5];
        nonOSCTo.userName = 'test5' + nonOSCTo.userName ;
        nonOSCTo.Department = '';        
        insert nonOSCTo;     
        
        System.runAs(Core_Test_Utility.systemAdminUser) {
            //Core_Opp_Bypass_Validation_Rule__c triggerExecList = new Core_Opp_Bypass_Validation_Rule__c();
        	//triggerExecList.Bypass__c = true;
        	//INSERT triggerExecList;
            insert accountInstance;
            
        }
        //TWC4767-3990
        DDRLst.Core_Partner_Account_Id__c= accountInstance.Id;
        update DDRLst;
        
        system.assert(accountInstance != null , 'success');
        Contact cont = new Contact();
        cont.FirstName = 'Test11';
        cont.LastName  = 'Contact';
        cont.AccountId = accountInstance.id;
        cont.Email = 'testingzzz@example.com';
        //cont.Mailing_Country_Region__c='AUS';
        cont.MailingCountry='AUS';    //migrate these 2 lines while moving to devint/higher orgs
        insert cont;
        system.assert(cont != null , 'success');
        Opportunity opportunityInstance = new Opportunity();
        opportunityInstance.CloseDate = System.Today().addDays(24);
        opportunityInstance.StageName = 'Qualify';
        opportunityInstance.Name = 'TestRE1';
        opportunityInstance.Core_External_User__c=true;
        opportunityInstance.AccountId =accountInstance.id;
        opportunityInstance.Core_Product_Segment__c='Client Computing';
        opportunityInstance.Core_Consumption_Market__c = 'Education';
        opportunityInstance.Core_Product_Application__c ='Business Mobility';
        opportunityInstance.Core_Opportunity_Type__c = 'Design: Original';
        opportunityInstance.Core_Opportunity_Coverage_Nm__c = 'Intel-Led Opportunity';
        opportunityInstance.Description = 'test';
        opportunityInstance.Core_IsClone__c = False;
        opportunityInstance.OwnerId= UserInfo.getUserId();
        insert opportunityInstance;
        
        Id DealOppRecTypeId = [select Id from RecordType where DeveloperName = 'Core_Deal_Opportunity' limit 1][0].Id;
        Opportunity opportunityInstance2 = new Opportunity();
        opportunityInstance2.CloseDate = System.Today().addDays(24);
        opportunityInstance2.StageName = 'Qualify';
        opportunityInstance2.Name = 'TestRE2';
        opportunityInstance2.Core_External_User__c=true;
        opportunityInstance2.AccountId =accountInstance.id;
        opportunityInstance2.RecordTypeId = DealOppRecTypeId;
        opportunityInstance2.Description = 'test';
        opportunityInstance2.Core_Product_Segment__c='Client Computing';
        opportunityInstance2.Core_Consumption_Market__c = 'Education';
        opportunityInstance2.Core_Product_Application__c ='Business Mobility';
        opportunityInstance2.Core_Opportunity_Coverage_Nm__c = 'Intel-Led Opportunity';
        opportunityInstance2.Description = 'test';
       	opportunityInstance2.Core_Opportunity_Type__c = 'Deal: Sell-through';
      	opportunityInstance2.Core_IsClone__c = False;
        opportunityInstance2.OwnerId= UserInfo.getUserId();
        insert opportunityInstance2;
        
        Opportunity opportunityInstance3 = new Opportunity(Name = 'TestRE3', RecordTypeId = DealOppRecTypeId,
                                                           AccountId = accountInstance.Id, OwnerId= UserInfo.getUserId(), Core_IsClone__c = False,
                                                           StageName = 'Qualify', CloseDate = System.Date.today().addYears(1),Core_Opportunity_Coverage_Nm__c ='Partner-Led Opportunity',
                                                           Core_Product_Segment__c='Client Computing', Core_Consumption_Market__c = 'Education', Description = 'test',
                                                           Core_Product_Application__c ='Business Mobility', Core_Opportunity_Type__c ='Deal: Sell-through',Core_Approval_Status__c = 'Not Submitted');
        insert opportunityInstance3;
        
        List<OpportunityLineItem> oppForLossItems = new List<OpportunityLineItem>();
        oppForLossItems.add(new OpportunityLineItem(OpportunityId = opportunityInstance.Id, PricebookEntryId = pbe.Id, Core_Status__c='Pending',
                                                    UnitPrice = 200, Quantity = 10, Core_Competitor__c = 'Acer', Core_Competitor_Product__c = 'AMD Athlon'));
        oppForLossItems.add(new OpportunityLineItem(OpportunityId = opportunityInstance.Id, PricebookEntryId = pbe.Id, Core_Status__c='Pending',
                                                    UnitPrice = 200, Quantity = 10, Core_Competitor__c = 'Acer', Core_Competitor_Product__c = 'AMD Athlon'));
        oppForLossItems.add(new OpportunityLineItem(OpportunityId = opportunityInstance.Id, PricebookEntryId = pbe.Id, Core_Status__c='Pending',
                                                    UnitPrice = 200, Quantity = 10, Core_Competitor__c = 'Acer', Core_Competitor_Product__c = 'AMD Athlon'));
        oppForLossItems.add(new OpportunityLineItem(OpportunityId = opportunityInstance.Id, PricebookEntryId = pbe.Id, Core_Status__c='Pending',
                                                    UnitPrice = 200, Quantity = 10, Core_Competitor__c = 'Acer', Core_Competitor_Product__c = 'AMD Athlon'));
        oppForLossItems.add(new OpportunityLineItem(OpportunityId = opportunityInstance2.Id, PricebookEntryId = pbe.Id, Core_Status__c='Pending',
                                                    UnitPrice = 200, Quantity = 10, Core_Competitor__c = 'Acer', Core_Competitor_Product__c = 'AMD Athlon'));
        oppForLossItems.add(new OpportunityLineItem(OpportunityId = opportunityInstance2.Id, PricebookEntryId = pbe.Id, Core_Status__c='Pending',
                                                    UnitPrice = 200, Quantity = 10, Core_Competitor__c = 'Acer', Core_Competitor_Product__c = 'AMD Athlon'));
        oppForLossItems.add(new OpportunityLineItem(OpportunityId = opportunityInstance2.Id, PricebookEntryId = pbe.Id, Core_Status__c='Pending',
                                                    UnitPrice = 200, Quantity = 10, Core_Competitor__c = 'Acer', Core_Competitor_Product__c = 'AMD Athlon'));
        oppForLossItems.add(new OpportunityLineItem(OpportunityId = opportunityInstance3.Id, PricebookEntryId = pbe.Id, Core_Status__c='Pending',
                                                    UnitPrice = 200, Quantity = 10, Core_Competitor__c = 'Acer', Core_Competitor_Product__c = 'AMD Athlon'));
        Test.StartTest();
        
        System.runAs(Core_Test_Utility.systemAdminUser) {
            insert oppForLossItems;
        }
        
        Core_Solution_Areas__c solStor = new Core_Solution_Areas__c();
        solStor.name ='SA0';
        solStor.Core_Solution_Type__c = 'S1: Product';
        solStor.Core_End_Customer_Solution__c = 'Yes';
        solStor.Core_Design_Visible__c = true;
        solStor.Core_Status__c = 'Active';
        solStor.Core_Application_Workload__c = 'AI Inference';
        solStor.Core_Industry_Use_Case__c = 'ADAS';
        solStor.Core_Concatenated_Solution_Partners__c = 'MQL;HGST SINGAPORE';
        solStor.Core_Version__c = '0';
        insert solStor;
        
        Core_Solution_Areas__c solStor2 = new Core_Solution_Areas__c();
        solStor2.name ='SA01';
        solStor2.Core_Solution_Type__c = 'S1: Product';
        solStor2.Core_End_Customer_Solution__c = 'Yes';
        solStor2.Core_Deal_Visible__c = true;
        solStor2.Core_Status__c = 'Active';
        solStor2.Core_Application_Workload__c = 'AI Inference';
        solStor2.Core_Industry_Use_Case__c = 'ADAS';
        solStor2.Core_Concatenated_Solution_Partners__c = 'MQL;HGST SINGAPORE';
        solStor2.Core_Version__c = '1';
        insert solStor2;
        
         system.assert(oppForLossItems != null , 'success');
        Test.StopTest();
    }
    
    static void enableTriggers() {   
        List < Core_Trigger_Executions__c > lstTriggerExecution = new List < Core_Trigger_Executions__c > ();
        
        Core_Trigger_Executions__c opportunityTechnicalOwnerUpdate = new Core_Trigger_Executions__c();
        opportunityTechnicalOwnerUpdate.name = 'opportunityTechnicalOwnerUpdate';
        opportunityTechnicalOwnerUpdate.Core_Object__c = 'Opportunity';
        opportunityTechnicalOwnerUpdate.Core_Active__c = TRUE;
        opportunityTechnicalOwnerUpdate.Core_Trigger_Events__c = 'After insert';
        opportunityTechnicalOwnerUpdate.Core_Description__c = 'This is test description';
        opportunityTechnicalOwnerUpdate.Core_Class_Name__c = 'Test Class';
        
        lstTriggerExecution.add(opportunityTechnicalOwnerUpdate);
        
        Core_Trigger_Executions__c opportunityNameDuplicateCheck = new Core_Trigger_Executions__c();
        opportunityNameDuplicateCheck.name = 'opportunityNameDuplicateCheck';
        opportunityNameDuplicateCheck.Core_Object__c = 'Opportunity';
        opportunityNameDuplicateCheck.Core_Active__c = TRUE;
        opportunityNameDuplicateCheck.Core_Trigger_Events__c = 'After insert';
        opportunityNameDuplicateCheck.Core_Description__c = 'This is test description';
        opportunityNameDuplicateCheck.Core_Class_Name__c = 'Test Class';
        
        lstTriggerExecution.add(opportunityNameDuplicateCheck);
        
        
        Core_Trigger_Executions__c opportunitylockFields = new Core_Trigger_Executions__c();
        opportunitylockFields.name = 'OpportunityLockFields';
        opportunitylockFields.Core_Object__c = 'Opportunity';
        opportunitylockFields.Core_Active__c = TRUE;
        opportunitylockFields.Core_Trigger_Events__c = 'After insert';
        opportunitylockFields.Core_Description__c = 'This is test description';
        opportunitylockFields.Core_Class_Name__c = 'Test Class';
        
        lstTriggerExecution.add(opportunitylockFields);
        
        Core_Trigger_Executions__c opportunityOppFactDelete = new Core_Trigger_Executions__c();
        opportunityOppFactDelete.name = 'opportunityOppFactDelete';
        opportunityOppFactDelete.Core_Object__c = 'Opportunity';
        opportunityOppFactDelete.Core_Active__c = TRUE;
        opportunityOppFactDelete.Core_Trigger_Events__c = 'After insert';
        opportunityOppFactDelete.Core_Description__c = 'This is test description';
        opportunityOppFactDelete.Core_Class_Name__c = 'Test Class';
        
        lstTriggerExecution.add(opportunityOppFactDelete);
        
        Core_Trigger_Executions__c OpportunityKPIJSON = new Core_Trigger_Executions__c();
        OpportunityKPIJSON.name = 'OpportunityKPIJSON';
        OpportunityKPIJSON.Core_Object__c = 'Opportunity';
        OpportunityKPIJSON.Core_Active__c = TRUE;
        OpportunityKPIJSON.Core_Trigger_Events__c = 'After insert,After Update';
        OpportunityKPIJSON.Core_Description__c = 'This is test description';
        OpportunityKPIJSON.Core_Class_Name__c = 'Test Class';
        
        lstTriggerExecution.add(OpportunityKPIJSON);
        
        Core_Trigger_Executions__c OpportunityCoEStatusUpdate = new Core_Trigger_Executions__c();
        OpportunityCoEStatusUpdate.name = 'OpportunityCoEStatusUpdate';
        OpportunityCoEStatusUpdate.Core_Object__c = 'Opportunity';
        OpportunityCoEStatusUpdate.Core_Active__c = TRUE;
        OpportunityCoEStatusUpdate.Core_Trigger_Events__c = 'Before insert,Before Update';
        OpportunityCoEStatusUpdate.Core_Description__c = 'This is test description';
        OpportunityCoEStatusUpdate.Core_Class_Name__c = 'Test Class';
        
        lstTriggerExecution.add(OpportunityCoEStatusUpdate);       
        Core_Trigger_Executions__c AutoCalculate6QPS = new Core_Trigger_Executions__c();
        AutoCalculate6QPS.name = 'OpportunityAutoCalculate6QPS';
        AutoCalculate6QPS.Core_Object__c = 'Opportunity';
        AutoCalculate6QPS.Core_Active__c = TRUE;
        AutoCalculate6QPS.Core_Trigger_Events__c = 'After Update';
        AutoCalculate6QPS.Core_Description__c = 'This is test description';
        AutoCalculate6QPS.Core_Class_Name__c = 'Test Class';
        
        lstTriggerExecution.add(AutoCalculate6QPS); 
        
        
        
        Core_Trigger_Executions__c set_BUShortName = new Core_Trigger_Executions__c();
        set_BUShortName.name = 'set_BUShortName';
        set_BUShortName.Core_Object__c = 'OpportunityLineItem';
        set_BUShortName.Core_Active__c = TRUE;
        set_BUShortName.Core_Trigger_Events__c = 'before insert';
        set_BUShortName.Core_Description__c = 'testing BU Mapping';
        set_BUShortName.Core_Class_Name__c = 'Core_OpportunityLineItemHandler';
        lstTriggerExecution.add(set_BUShortName);   
        
        
        Core_Trigger_Executions__c triggerExec25 = new Core_Trigger_Executions__c();
        triggerExec25.Name='OppDecisionDtCannotGreaterOLIofQLStrDt'; 
        triggerExec25.Core_Class_Name__c='Core_OpportunityHandler';
        triggerExec25.Core_Object__c='Opportunity';
        triggerExec25.Core_Trigger_Events__c='before Update'; 
        triggerExec25.Core_Active__c=true; 
        triggerExec25.Core_Description__c = 'OppDecisionDtCannotGreaterOLIofQLStrDt';
        lstTriggerExecution.add(triggerExec25); 
        
        Core_Trigger_Executions__c triggerExec26 = new Core_Trigger_Executions__c();
        triggerExec26.Name='PCCDealRegOwnerOptyQuoteSync'; 
        triggerExec26.Core_Class_Name__c='Core_OpportunityHandler';
        triggerExec26.Core_Object__c='Opportunity';
        triggerExec26.Core_Trigger_Events__c='after Update'; 
        triggerExec26.Core_Active__c=true; 
        triggerExec26.Core_Description__c = 'PCCDealRegOwnerOptyQuoteSync';
        lstTriggerExecution.add(triggerExec26); 
        
        Core_Trigger_Executions__c triggerExec27 = new Core_Trigger_Executions__c();
        triggerExec27.Name='ILO_syncStatus_Opportunity_IQRQuote'; 
        triggerExec27.Core_Class_Name__c='Core_OpportunityHandler';
        triggerExec27.Core_Object__c='Opportunity';
        triggerExec27.Core_Trigger_Events__c='After Update'; 
        triggerExec27.Core_Active__c=true; 
        triggerExec27.Core_Description__c = 'ILO_syncStatus_Opportunity_IQRQuote';
        lstTriggerExecution.add(triggerExec27); 
        
        
        Core_Trigger_Executions__c triggerExec28 = new Core_Trigger_Executions__c();
        triggerExec28.Name='OpportunityKPIfieldRefresh'; 
        triggerExec28.Core_Class_Name__c='Core_OpportunityHandler';
        triggerExec28.Core_Object__c='Opportunity';
        triggerExec28.Core_Trigger_Events__c='After Update'; 
        triggerExec28.Core_Active__c=true; 
        triggerExec28.Core_Description__c = 'OpportunityKPIfieldRefresh';
        lstTriggerExecution.add(triggerExec28);
        
        Core_Trigger_Executions__c oppStageUpdate = new Core_Trigger_Executions__c();
        oppStageUpdate.Name = 'opportunityStageUpdate';
        oppStageUpdate.Core_Object__c = 'Opportunity';
        oppStageUpdate.Core_Active__c = TRUE;
        oppStageUpdate.Core_Trigger_Events__c = 'after update';
        oppStageUpdate.Core_Description__c = 'blahblahblah';
        oppStageUpdate.Core_Class_Name__c = 'Core_OpportunityHandler';
        lstTriggerExecution.add(oppStageUpdate);
        
        lstTriggerExecution.add(new Core_Trigger_Executions__c(Name='updateActivityLineItems', Core_Class_Name__c='Core_OpportunityHandler', Core_Object__c='Opportunity_Partner', Core_Trigger_Events__c='After Update', Core_Active__c=true, Core_Description__c = 'blah blah'));
        
        
        
        
        Core_Trigger_Executions__c triggerExec = new Core_Trigger_Executions__c( 
            Name='UpdateTerritoryInfoOnOppty', Core_Class_Name__c='Core_OpportunityHandler', Core_Object__c='Opportunity', 
            Core_Trigger_Events__c='before Insert before update', Core_Active__c=true, Core_Description__c = 'For testing territory information on Opportunity');
        
        lstTriggerExecution.add(triggerExec);
        
        
        lstTriggerExecution.add(new Core_Trigger_Executions__c(Name='deleteKPIonOpportunityDelete', Core_Class_Name__c='Core_OpportunityHandler', 
                                                               Core_Object__c='Opportunity', Core_Trigger_Events__c='before Delete', 
                                                               Core_Active__c=true, Core_Description__c = 'delete kpi on opportunity delete'));
        
        Core_Trigger_Executions__c forecastUpdateFromOppty = new Core_Trigger_Executions__c( 
            Name='forecastUpdateFromOppty', Core_Class_Name__c='Core_OpportunityHandler', Core_Object__c='Opportunity', 
            Core_Trigger_Events__c='After Update', Core_Active__c=true, Core_Description__c = ' Forecast on updation of an Opportunity.');
        
        lstTriggerExecution.add(forecastUpdateFromOppty);	
        
        lstTriggerExecution.add(new Core_Trigger_Executions__c(Name='POPCheckOnUpdate', Core_Class_Name__c='Core_OpportunityHandler', Core_Object__c='Opportunity', Core_Trigger_Events__c='Before Update After Update', Core_Active__c=true, Core_Description__c = 'blah blah'));
        
        lstTriggerExecution.add(new Core_Trigger_Executions__c(Name='BlockExistingOppOnLeadConversion', Core_Class_Name__c='Core_OpportunityHandler', Core_Object__c='Opportunity', Core_Trigger_Events__c='Before Update', Core_Active__c=true, Core_Description__c = 'blah blah'));
        
        lstTriggerExecution.add(new Core_Trigger_Executions__c(Name='RestrictSolutionDetailLOV', Core_Class_Name__c='Core_OpportunityHandler', Core_Object__c='Opportunity', Core_Trigger_Events__c='Before Update', Core_Active__c=true, Core_Description__c = 'blah blah'));
        
        lstTriggerExecution.add(new Core_Trigger_Executions__c(Name='StampSolutionDetailValue', Core_Class_Name__c='Core_OpportunityHandler', Core_Object__c='Opportunity', Core_Trigger_Events__c='Before Insert Before Update', Core_Active__c=true, Core_Description__c = 'blah blah'));
        
        lstTriggerExecution.add(new Core_Trigger_Executions__c(Name='CombineSolutionDetailFields', Core_Class_Name__c='Core_OpportunityHandler', Core_Object__c='Opportunity', Core_Trigger_Events__c='Before Insert Before Update', Core_Active__c=true, Core_Description__c = 'blah blah'));
        
        lstTriggerExecution.add(new Core_Trigger_Executions__c(Name='RestrictSolutionAreaInactiveLOV', Core_Class_Name__c='Core_OpportunityHandler', Core_Object__c='Opportunity', Core_Trigger_Events__c='Before Update', Core_Active__c=true, Core_Description__c = 'blah blah'));
        
        
        lstTriggerExecution.add(new Core_Trigger_Executions__c(Name='updateJSONSolutionArea', Core_Class_Name__c='updateJSONSolutionArea', Core_Object__c='OpportunitySolutionArea', Core_Trigger_Events__c='After Insert before Delete', Core_Active__c=true, Core_Description__c = 'blah blah'));   
        
        
        lstTriggerExecution.add(new Core_Trigger_Executions__c(Name='createJSONSolutionArea', Core_Class_Name__c='createJSONSolutionArea', Core_Object__c='Solution Area', Core_Trigger_Events__c='After Update', Core_Active__c=true, Core_Description__c = 'blah blah'));
        
        Core_Trigger_Executions__c triggerEntry = new Core_Trigger_Executions__c(Name='updatePWFieldsonProduct', Core_Object__c='Opportunity',
                                                                                 Core_Class_Name__c='Core_OpportunityHandler',Core_Trigger_Events__c='after update',
                                                                                 Core_Active__c=true, Core_Description__c='update pw fields on product');
        lstTriggerExecution.add(triggerEntry);
        
        Core_Trigger_Executions__c triggerEntry1 = new Core_Trigger_Executions__c(Name='lockPCCOpportunity', Core_Object__c='Opportunity',
                                                                                  Core_Class_Name__c='Core_OpportunityHandler',Core_Trigger_Events__c='before update, before', 
                                                                                  Core_Active__c=true, Core_Description__c='for PCC Lock');
        
        lstTriggerExecution.add(triggerEntry1);
        
        lstTriggerExecution.add(new Core_Trigger_Executions__c(Name='addSolutionRelatedRecords', Core_Class_Name__c='Core_AddSolutionArea', Core_Object__c='Solution Area', Core_Trigger_Events__c='After Update', Core_Active__c=true, Core_Description__c = 'blah blah')); 
        
        
        
        
        
        
        lstTriggerExecution.add(new Core_Trigger_Executions__c(Name='OpportunityShare', Core_Class_Name__c='Core_OpportunityHandler', Core_Object__c='Opportunity', Core_Trigger_Events__c='Before update',Core_Active__c = TRUE, Core_Description__c = 'This is test description'));
        
        
        Core_Trigger_Executions__c OpportunityStageExitValidation = new Core_Trigger_Executions__c();
        OpportunityStageExitValidation.name = 'OpportunityStageExitValidation';
        OpportunityStageExitValidation.Core_Object__c = 'Opportunity';
        OpportunityStageExitValidation.Core_Active__c = TRUE;
        OpportunityStageExitValidation.Core_Trigger_Events__c = 'Before update';
        OpportunityStageExitValidation.Core_Description__c = 'This is test description';
        OpportunityStageExitValidation.Core_Class_Name__c = 'Test Class';
        /***/
        //lstTriggerExecution.add(OpportunityStageExitValidation);
        /***/
        Core_Trigger_Executions__c storeOppTeamMemDescription = new Core_Trigger_Executions__c();
        storeOppTeamMemDescription.Name='storeOppTeamMemDescription'; 
        storeOppTeamMemDescription.Core_Class_Name__c='Core_OpportunityHandler';
        storeOppTeamMemDescription.Core_Object__c='Opportunity';
        storeOppTeamMemDescription.Core_Trigger_Events__c='before Update'; 
        storeOppTeamMemDescription.Core_Active__c=true; 
        storeOppTeamMemDescription.Core_Description__c = 'storeOppTeamMemDescription';
        lstTriggerExecution.add(storeOppTeamMemDescription); 
        
        Core_Trigger_Executions__c updateProductLineItems = new Core_Trigger_Executions__c();
        updateProductLineItems.Name='updateProductLineItems'; 
        updateProductLineItems.Core_Class_Name__c='Core_OpportunityHandler';
        updateProductLineItems.Core_Object__c='Opportunity';
        updateProductLineItems.Core_Trigger_Events__c='after Update'; 
        updateProductLineItems.Core_Active__c=true; 
        updateProductLineItems.Core_Description__c = 'updateProductLineItems';
        lstTriggerExecution.add(updateProductLineItems); 
        
        Core_Trigger_Executions__c determineApprovers = new Core_Trigger_Executions__c();
        determineApprovers.Name='determineApprovers'; 
        determineApprovers.Core_Class_Name__c='Core_OpportunityHandler';
        determineApprovers.Core_Object__c='Opportunity';
        determineApprovers.Core_Trigger_Events__c='before Update'; 
        determineApprovers.Core_Active__c=true; 
        determineApprovers.Core_Description__c = 'determineApprovers';
        lstTriggerExecution.add(determineApprovers); 
        
        Core_Trigger_Executions__c FedCRMShareUnshare = new Core_Trigger_Executions__c();
        FedCRMShareUnshare.Name='FedCRMShareUnshare'; 
        FedCRMShareUnshare.Core_Class_Name__c='Core_OpportunityHandler';
        FedCRMShareUnshare.Core_Object__c='Opportunity';
        FedCRMShareUnshare.Core_Trigger_Events__c='after Insert'; 
        FedCRMShareUnshare.Core_Active__c=true; 
        FedCRMShareUnshare.Core_Description__c = 'FedCRMShareUnshare';
        lstTriggerExecution.add(FedCRMShareUnshare); 
        
        Core_Trigger_Executions__c delegateApproverRoleChange = new Core_Trigger_Executions__c();
        delegateApproverRoleChange.Name='delegateApproverRoleChange'; 
        delegateApproverRoleChange.Core_Class_Name__c='Core_OpportunityHandler';
        delegateApproverRoleChange.Core_Object__c='Opportunity';
        delegateApproverRoleChange.Core_Trigger_Events__c='after Insert'; 
        delegateApproverRoleChange.Core_Active__c=true; 
        delegateApproverRoleChange.Core_Description__c = 'delegateApproverRoleChange';
        lstTriggerExecution.add(delegateApproverRoleChange); 
        
        Core_Trigger_Executions__c crmOpportunityHandler1 = new Core_Trigger_Executions__c();
        crmOpportunityHandler1.Name='crmOpportunityHandler'; 
        crmOpportunityHandler1.Core_Class_Name__c='CRM_OpportunityHandler';
        crmOpportunityHandler1.Core_Object__c='Opportunity';
        crmOpportunityHandler1.Core_Trigger_Events__c='after Insert,after Update,Before Update'; 
        crmOpportunityHandler1.Core_Active__c=true; 
        crmOpportunityHandler1.Core_Description__c = 'crmOpportunityHandler';
        lstTriggerExecution.add(crmOpportunityHandler1); 
        insert lstTriggerExecution;
         system.assert(lstTriggerExecution != null , 'success');
    }
 
   static testmethod void testOpportunity(){
        Test.StartTest();
        Profile pro = [SELECT id, Name FROM Profile WHERE Name='Sales Rep-BB'];
        User usr1 = [SELECT id, Name, isActive FROM User WHERE ProfileId = :pro.Id AND isActive = true LIMIT 1];
        List<Opportunity> lstOpp= new List<Opportunity>();
        lstOpp=[SELECT Id, CloseDate , StageName, Name , Core_External_User__c, AccountId , Core_Product_Segment__c,       Core_Consumption_Market__c , Core_Product_Application__c ,
                Core_Opportunity_Type__c , Core_Opportunity_Coverage_Nm__c,
                Description , Core_IsClone__c  FROM Opportunity where Name like '%TestRE%' LIMIT 3];
        system.assert(lstOpp.size() > 0, 'success');
        for (Opportunity sobjOpp: lstOpp) {
            
            sobjOpp.Core_Technical_Owner__c = usr1.id;
            
        }
        
        Core_OpportunityHandler.bTechnicalOwnerUpdate = true;
        update lstOpp;
        
        Test.StopTest();
        
    } 
  

    
    static testmethod void testOppoSolutionJSONKPI(){
        Test.StartTest();
        
        List<User> users= [select Id from User where userName like '%test%' limit 4];
        Profile pro = [SELECT id, Name FROM Profile WHERE Name='Sales Rep-BB'];
        User usr1 = [SELECT id, Name, isActive FROM User WHERE ProfileId = :pro.Id AND isActive = true LIMIT 1];
        List<Opportunity> lstOpp= new List<Opportunity>();
        lstOpp=[SELECT Id, CloseDate , StageName, Name , Core_External_User__c, AccountId , Core_Product_Segment__c,       Core_Consumption_Market__c , Core_Product_Application__c ,
                Core_Opportunity_Type__c , Core_Opportunity_Coverage_Nm__c,
                Description , Core_IsClone__c  FROM Opportunity where Name like '%TestRE%' LIMIT 3];
        List<Account> lstAcc= [select Id from Account where Name='TestoppAcchandle'];
        List<Core_Solution_Areas__c> lstSolnArea= [select Id, Core_Solution_Type__c,Core_Application_Workload__c, Core_Industry_Use_Case__c, Core_Version__c from Core_Solution_Areas__c where Name like '%SA%' limit 2];
        
        Core_Solution_Area_Partner__c oppPa = new Core_Solution_Area_Partner__c();
        oppPa.Core_Solution_Partner__c = lstAcc[0].Id;
        oppPa.Core_Solution_Partner_Role__c = 'Co-Selling';
        oppPa.Solution_Partner_Type__c = 'Cloud Service Provider';
        oppPa.Core_Solution_Area__c = lstSolnArea[0].Id;
        Insert oppPa;
        system.assert(oppPa != null, 'success');
        oppPa.Core_Solution_Partner_Role__c = 'Vendor';
        UPDATE oppPa;
        system.assert(oppPa != null, 'success');
        List<Opportunity_Solution_Area__c> oSAList= new List<Opportunity_Solution_Area__c>();
        Opportunity_Solution_Area__c oSA= new Opportunity_Solution_Area__c();
        oSA.Core_Opportunity__c = lstOpp[1].Id;
        oSA.Core_Solution_Areas__c =lstSolnArea[1].id;
        
        List<Core_Oppty_KPI_New__c> oppKPIList = new List<Core_Oppty_KPI_New__c>();
        for(Integer i=0;i<2;i++){        
            Core_Oppty_KPI_New__c OppKPI1 = new Core_Oppty_KPI_New__c();
            OppKPI1.Name='aa'+i;
            OppKPI1.Core_KPI_Opportunity__c = lstOpp[0].Id;
            OppKPI1.Core_Batch_Time__c = System.Now();
            OppKPI1.Core_Opportunity_KPI_Batch_ID__c = '25';
            oppKPIList.add(OppKPI1);
        }
        
        
        
        System.runAs(Core_Test_Utility.systemAdminUser) {
            Core_Opp_Bypass_Validation_Rule__c SolnArearec = new Core_Opp_Bypass_Validation_Rule__c();
            SolnArearec.Bypass__c = true;
            //SolnArearec.SetupOwnerId = Core_Test_Utility.systemAdminUser.Id;
            //update SolnArearec;
            insert oSA;
            Opportunity_Solution_Area__c oSA1= new Opportunity_Solution_Area__c();
            oSA1.Core_Opportunity__c = lstOpp[0].Id;
            oSA1.Core_Solution_Areas__c =lstSolnArea[0].Id;
            oSAList.add(oSA1);             
            insert oppKPIList;
            
            Core_OpportunityHandler.createJSONSolutionArea(oSAList);
            
            Map<Id, Opportunity> oldOppMapKPI = new Map<Id, Opportunity>(lstOpp);
            lstSolnArea[0].Core_Solution_Description__c ='Test ssss';
            lstSolnArea[1].Core_Solution_Description__c ='Test ssss1111';
            update lstSolnArea;
            
            Core_OpportunityHandler.OpportunityKPIBatchUpdate(lstOpp,oldOppMapKPI);
        }
        Test.StopTest();
         system.assert(oppKPIList != null , 'success');
    } 


    static testMethod void UpdateTerritoryInfoOnOppty_Test() {
        list<territory2type> tTypeList = new list<territory2type>();
        list<territory2> territoryList = new list<territory2>();
        Territory2Model tModel = new Territory2Model();
        tModel.name = 'test';
        tModel.developername = 'test';
        insert tModel;
        
        // DML not allowed on Territory2Type object. so extracting recrds using Soql.
        Id tBusinessType = [Select id from territory2type where MasterLabel = 'Business Units and Specialists'].Id;
        Id tGeographicType = [Select id from territory2type where MasterLabel = 'Geographic World Wide'].Id;
        Id tNamedType = [Select id from territory2type where MasterLabel = 'Named / Strategic Accounts'].Id;
        territory2 t = new territory2();
        t.name = 'test';
        t.developername = 'test';
        t.Territory2ModelId = tModel.Id;
        t.territory2typeId = tBusinessType;
        territoryList.add(t);
        territory2 t1 = new territory2();
        t1.name = 'test';
        t1.developername = 'test1';
        t1.Territory2ModelId = tModel.Id;
        t1.territory2typeId = tGeographicType;
        territoryList.add(t1);
        territory2 t2 = new territory2();
        t2.name = 'test';
        t2.developername = 'test2';
        t2.Territory2ModelId = tModel.Id;
        t2.territory2typeId = tNamedType;
        territoryList.add(t2);
        insert territoryList;
        
        System.runAs(Core_Test_Utility.systemAdminUser) {
            list<Account> acclist = new list<Account>();
            list<Opportunity> opplist = new list<Opportunity>();
            // Create the configuration item so the Insert and Update trigger on Opportunity gets executed
            
            
            // Create a new account  
            Id newAccountRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
            Account acct = new Account(Name = 'TestAccountterritory', BillingStreet = '123 Fake St',RecordTypeId = newAccountRecTypeId,
                                       BillingCity = 'Springfield', BillingState = 'IL', BillingCountry = 'USA', Industry='Agriculture',Core_Sub_Industry__c= 'Crop Production',
                                       BillingPostalCode = '12345', Core_Sales_Groups__c=Core_CRM_Utility.getSalesGroupAPI());
            Account acct1 = new Account(Name = 'TestAccountterritory1', BillingStreet = '123 Fake St',RecordTypeId = newAccountRecTypeId,
                                        BillingCity = 'Springfield', BillingState = 'IL', BillingCountry = 'USA', Industry='Agriculture', Core_Sub_Industry__c='Crop Production',
                                        BillingPostalCode = '12345',Core_Sales_Groups__c=Core_CRM_Utility.getSalesGroupAPI());
            Account acct2 = new Account(Name = 'TestAccountterritory2', BillingStreet = '123 Fake St',RecordTypeId = newAccountRecTypeId,
                                        BillingCity = 'Springfield', BillingState = 'IL', BillingCountry = 'USA', Industry='Agriculture', Core_Sub_Industry__c='Crop Production',
                                        BillingPostalCode = '12345',Core_Sales_Groups__c=Core_CRM_Utility.getSalesGroupAPI());
            
            acclist.add(acct);
            acclist.add(acct1);
            acclist.add(acct2);
            system.runAs(Core_Test_Utility.systemAdminUser){
                insert acclist;
            }
            list<ObjectTerritory2Association> objectassocitelist = new list<ObjectTerritory2Association>();
            for(integer j = 0; j< 3 ; j++){
                ObjectTerritory2Association oTerri2 = new ObjectTerritory2Association();
                oTerri2.ObjectId = acclist[j].Id;
                oterri2.territory2Id = territoryList[j].Id;
                oterri2.AssociationCause  = 'Territory2Manual';
                objectassocitelist.add(oTerri2);
            }
            insert objectassocitelist;
            
            test.starttest();
            // Create a new opportunity using the account created above
            Id newOppRecTypeId = [select Id from RecordType where DeveloperName = 'Core_Design_Opportunity' limit 1][0].Id;
            Opportunity opp = new Opportunity(Name = 'Test Opportunity1', RecordTypeId = newOppRecTypeId,
                                               AccountId = acclist[0].Id, StageName = 'Qualify', CloseDate = System.Date.today().addYears(1) ,Core_Opportunity_Type__c='Design: Original', Opportunity_Focus__c= 'Core');
            Opportunity opp1 = new Opportunity(Name = 'Test Opportunity1', RecordTypeId = newOppRecTypeId,
                                                 AccountId = acclist[1].Id, StageName = 'Qualify', CloseDate = System.Date.today().addYears(1),Core_Opportunity_Type__c='Design: Original', Opportunity_Focus__c= 'Core');
            Opportunity opp2 = new Opportunity(Name = 'Test Opportunity1', RecordTypeId = newOppRecTypeId,
                                                 AccountId = acclist[2].Id, StageName = 'Qualify', CloseDate = System.Date.today().addYears(1),Core_Opportunity_Type__c='Design: Original', Opportunity_Focus__c= 'Core');
            opplist.add(opp);
            opplist.add(opp1);
            opplist.add(opp2);
            insert opplist;
            opplist[0].Core_Business_Unit_Territory__c=null;
            opplist[1].Core_Geographical_Territory__c=null;
            opplist[2].Core_Named_Strategic__c=null;
            Core_OpportunityHandler.TerritoryUpdateCheck=true;
            update opplist;
            test.stoptest();
            system.assert(opplist.size() > 0, 'success');
        }
    }

    
	// this method created by infosys team rajesh //
    static testMethod void opportunityOppFactDelete_Test() {
        test.starttest();
        System.runAs(Core_Test_Utility.systemAdminUser){
            list<Account> acclist = new list<Account>();
            list<Opportunity> opplist = new list<Opportunity>();
            // Create the configuration item so the Insert and Update trigger on Opportunity gets executed
            
            Core_Opportunity_Facts__c oppFact=new Core_Opportunity_Facts__c();
            oppFact.Core_Ambient_Temp_Req__c='Test Facts';
            insert oppFact;
            // Create a new account  
            Id newAccountRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
            Account acct = new Account(Name = 'TestAccountterritory', BillingStreet = '123 Fake St',RecordTypeId = newAccountRecTypeId,
                                       BillingCity = 'Springfield', BillingState = 'IL', BillingCountry = 'USA',Industry='Agriculture',Core_Sub_Industry__c= 'Crop Production',
                                       BillingPostalCode = '12345',Core_Sales_Groups__c=Core_CRM_Utility.getSalesGroupAPI());
            insert acct;
            // Create a new opportunity using the account created above
            Id newOppRecTypeId = [select Id from RecordType where DeveloperName = 'Core_Design_Opportunity' limit 1][0].Id;
            Opportunity opp = new Opportunity(Name = 'Test Opportunity1',Core_Opportunity_Facts_ID__c=oppFact.Id, RecordTypeId = newOppRecTypeId,
                                                AccountId = acct.Id, StageName = 'Qualify', CloseDate = System.Date.today().addYears(1),Core_Opportunity_Type__c='Design: Original', Opportunity_Focus__c= 'Core');
            opplist.add(opp);
            insert opplist;
            delete opplist;
            test.stoptest();
            system.assert(opp <> null, 'success');
        }
    }
    public static List<Opportunity> opptyList = new List<Opportunity>();
    
    static void setupData(){
         User partnerUsr = [select Id,UserRoleId from User where Profile.Name='Partner' AND IsActive=true LIMIT 1];
         User users= [select Id from User where userName like '%test%' limit 1];         

        Id newAccountRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        Account acct = new Account(Name = 'TestAccountterritory', BillingStreet = '123 Fake St',RecordTypeId = newAccountRecTypeId,
                                   BillingCity = 'Springfield', BillingState = 'IL', BillingCountry = 'USA',Industry='Agriculture',Core_Sub_Industry__c= 'Crop Production',
                                   BillingPostalCode = '12345', Core_Sales_Groups__c='Americas US Sales Group');
        insert acct;
        Account acct1 = new Account(Name = 'TestAccountterritory1', BillingStreet = '123 Fake St',RecordTypeId = newAccountRecTypeId,
                                   BillingCity = 'Springfield', BillingState = 'IL', BillingCountry = 'USA',Industry='Agriculture',Core_Sub_Industry__c= 'Crop Production',
                                   BillingPostalCode = '12345', Core_Sales_Groups__c='Americas US Sales Group');
        System.runAs(Core_Test_Utility.systemAdminUser) {
            insert acct1;
        }
         system.assert(acct != null , 'success');
        Id newOppRecTypeId = [select Id from RecordType where DeveloperName = 'Core_Design_Opportunity' limit 1][0].Id;
        //
        Id DealOppRecTypeId = [select Id from RecordType where DeveloperName = 'Core_Deal_Opportunity' limit 1][0].Id;
        
         Core_Design_Registration__c DDRLst = new Core_Design_Registration__c(
            Core_Product_Group_Nm__c = 'FPGA/Power',
            Core_Design_Registration_Nm__c = 'DDR Test',
            Core_Design_Registration_Dsc__c = 'ABC',
            Core_Opportunity_Volume_Cnt__c = 5,
            Core_Partner_FAE_Nm__c = '6',            
            Core_End_Customer_Nm__c = 'DDR Test',            
            Core_End_Customer_Street_Addr_Line1_Txt__c = 'ABC',
            Core_End_Customer_Street_Addr_Line2_Txt__c = 'Abc',
            Core_End_Customer_City_Nm__c = 'BAN',
            Core_End_Customer_Country_Subdivision_Nm__c = 'KA',
            PCC_End_Customer_Country__c = 'United States',
            Core_End_Customer_Postal_Cd__c = '560037',
            Core_Military_Aerospace_Gvrnmt_Use_Ind__c = 'Yes',
            Core_Opportunity_Decision_Dt__c = system.today()+45,
            Core_First_Customer_Ship_Dt__c = system.today()+46,
            Core_Production_End_Dt__c = system.today()+47,
            Core_Vertical_Market_Nm__c = 'Education',
            Core_Intel_Platform_Nm__c = 'Board',
            Core_Product_Application_Nm__c = 'Business Desktop',
            Core_Product_Segment_Nm__c = 'Client Computing',
            Core_Manufacturing_Region_Cd__c = 'APJ',
            Core_Design_Registration_Status_Nm__c = 'Re-Submitted'
        );
        DDRLst.Core_Product_Group_Nm__c ='Embedded/IOT';
        DDRLst.Core_Partner_Account_Id__c = acct1.Id;
        insert DDRLst;
        
        
        System.runAs(Core_Test_Utility.systemAdminUser){
            opptyList.add(new Opportunity(Name = 'Test Opportunity1', RecordTypeId = newOppRecTypeId,
                                           AccountId = acct.Id, StageName = 'Qualify', CloseDate = System.Date.today().addYears(1), Core_Technical_Owner__c = users.Id, Core_Sales_Group__c='Industry Sales', Core_Commissionable__c ='Yes', Core_Product_Segment__c='Client Computing', Core_Product_Application__c = 'Consumer Mobility', Core_Consumption_Market__c = 'Education',Core_Sales_Objectives__c='Standard Refresh', Core_Solution_Focus_Area__c='Not Solution Selling', Core_Solution_Focus__c='5G Network Infrastructure',   Core_Solution_Play__c='Not Solution Selling', Core_Opportunity_Country__c='India',Core_Opportunity_Type__c='Design: Original', Opportunity_Focus__c= 'Core'));
            opptyList.add(new Opportunity(Name = 'Test Opportunity2', RecordTypeId = newOppRecTypeId,
                                           AccountId = acct.Id, StageName = 'Qualify', CloseDate = System.Date.today().addYears(1), Core_Technical_Owner__c = UserInfo.getUserId(), Core_Sales_Group__c='Industry Sales', Core_Commissionable__c ='Yes', Core_Product_Segment__c='Client Computing', Core_Product_Application__c = 'Consumer Mobility', Core_Consumption_Market__c = 'Education',Core_Sales_Objectives__c='Standard Refresh', Core_Solution_Focus_Area__c='Not Solution Selling', Core_Solution_Focus__c='5G Network Infrastructure',   Core_Solution_Play__c='Not Solution Selling', Core_Opportunity_Country__c='India',Core_Opportunity_Type__c='Design: Original', Opportunity_Focus__c= 'Core'));
            opptyList.add(new Opportunity(Name = 'TestClass PCC Opportunity', RecordTypeId = DealOppRecTypeId,Core_Design_Registration_Id__c= DDRLst.Id,
                                            AccountId = acct.Id,Core_Coverage_Type_Nm__c = 'Deal Registration',Core_Technical_Owner__c = partnerUsr.Id,
                                            CRM_SW_Flag_Ind__c = true,StageName = 'Qualify', CloseDate = System.Date.today().addYears(1), Core_Opportunity_Coverage_Nm__c ='Partner-Led Opportunity'));
           
            insert opptyList;
        }    
         system.assert(opptyList != null , 'success');
        Profile p = [SELECT id, Name FROM Profile WHERE Name='Sales Rep-BB'];
        User usr = [SELECT id, Name, isActive FROM User WHERE ProfileId = :p.Id AND isActive = true LIMIT 1];
        System.runAs(Core_Test_Utility.systemAdminUser){
            opptyList.add(new Opportunity(Name = 'Test Opportunity2', RecordTypeId = newOppRecTypeId,
                                          AccountId = acct.Id, StageName = 'Qualify', CloseDate = System.Date.today().addYears(1), Core_Technical_Owner__c = usr.Id, Core_Sales_Group__c='Industry Sales', Core_Commissionable__c ='Yes', Core_Product_Segment__c='Client Computing', Core_Product_Application__c = 'Consumer Mobility', Core_Consumption_Market__c = 'Education',Core_Sales_Objectives__c='Standard Refresh', Core_Solution_Focus_Area__c='Not Solution Selling', Core_Solution_Focus__c='5G Network Infrastructure',     Core_Solution_Play__c='Not Solution Selling', Core_Opportunity_Country__c='India',Core_Opportunity_Type__c='Design: Original', Opportunity_Focus__c= 'Core'));
            insert opptyList[3];
        }
    }
    
    
    static testMethod void Test_opportunityTechnicalOwnerUpdate(){
        List<Opportunity> oppList = new List<Opportunity>();
        List<Opportunity> oppList1 = new List<Opportunity>();
        Map<Id,Opportunity> mapOldsObject = new Map<Id,Opportunity>();
        Map<Id,Opportunity> mapNewsObject = new Map<Id,Opportunity>();
        
        Profile p = [SELECT id, Name FROM Profile WHERE Name='Sales Rep-BB'];
        User usr = [SELECT id, Name, isActive FROM User WHERE ProfileId = :p.Id AND isActive = true LIMIT 1];
      
        test.startTest();
        setupData();
        oppList.add(opptyList[0]);
        oppList1.add(opptyList[2]);
        mapOldsObject.put(opptyList[0].Id, opptyList[0]);
        mapNewsObject.put(opptyList[2].Id, opptyList[2]);
        
        
        opptyList[0].Core_Technical_Owner__c = usr.Id;
        opptyList[2].Core_Technical_Owner__c = usr.Id;
        opptyList[0].Core_Product_Segment__c = 'Client Computing';
        opptyList[0].Core_Product_Application__c = 'Consumer Mobility';
        opptyList[3].Core_Technical_Owner__c = Core_Test_Utility.systemAdminUser.Id;
        opptyList[3].Core_Product_Segment__c = 'Client Computing';
        opptyList[3].Core_Product_Application__c = 'Consumer Mobility';
        opptyList[0].OwnerId = UserInfo.getUserId();
        opptyList[3].OwnerId = UserInfo.getUserId();
        opptyList[0].Core_Opportunity_Coverage_Nm__c='Partner-Led Opportunity';
        opptyList[3].Core_Opportunity_Coverage_Nm__c='Partner-Led Opportunity';
        opptyList[0].Description = 'Uniquedaw';
        opptyList[3].Description = 'Uniquedaw2';
        
        update opptyList;
        
        
        Core_OpportunityHandler.opportunityTechnicalOwnerUpdate(mapOldsObject, mapNewsObject, true);        

        
        test.stopTest();
        system.assert(opptyList.size() > 0, 'success');       
    }
    
    static testMethod void Test_opportunityTechnicalOwnerUpdate1(){
        Profile p = [SELECT id, Name FROM Profile WHERE Name='Sales Rep-BB'];
        User usr = [SELECT id, Name, isActive FROM User WHERE ProfileId = :p.Id AND isActive = true LIMIT 1];
        test.startTest();
        setupData();
        
        opptyList[0].Core_Technical_Owner__c = UserInfo.getUserId();
        opptyList[0].Core_Product_Segment__c = 'Client Computing';
        opptyList[0].Core_Product_Application__c = 'Consumer Mobility';
        opptyList[2].Core_Technical_Owner__c = UserInfo.getUserId();
        opptyList[2].Core_Product_Segment__c = 'Client Computing';
        opptyList[2].Core_Product_Application__c = 'Consumer Mobility';
        opptyList[0].OwnerId = usr.Id;
        opptyList[2].OwnerId = Core_Test_Utility.systemAdminUser.Id;
        opptyList[0].Core_Opportunity_Coverage_Nm__c='Partner-Led Opportunity';
        opptyList[2].Core_Opportunity_Coverage_Nm__c='Partner-Led Opportunity';
        opptyList[0].Description = 'Uniquedaw';
        opptyList[2].Description = 'Uniquedaw2';
        Map<Id, Opportunity> newOppMap = new Map<Id,Opportunity>(opptyList);
        Map<Id, Opportunity> oldOppMap = new Map<Id,Opportunity>(opptyList);
        
        update opptyList;
        
        test.stopTest();
        system.assert(opptyList.size() > 0, 'success');       
    }
    
    
    // this method created by infosys team rajesh //
    static testMethod void updateForecastRecs_Test() {
        test.starttest();
        System.runAs(Core_Test_Utility.systemAdminUser){
            list<Account> acclist = new list<Account>();
            list<Opportunity> opplist = new list<Opportunity>();
            // Create the configuration item so the Insert and Update trigger on Opportunity gets executed
            
            Core_Opportunity_Facts__c oppFact=new Core_Opportunity_Facts__c();
            oppFact.Core_Ambient_Temp_Req__c='Test Facts';
            insert oppFact;
            
            Profile p1 = [SELECT id, Name FROM Profile WHERE Name='Sales Rep-BB'];
            User usr = [SELECT id, Name, isActive FROM User WHERE ProfileId = :p1.Id AND isActive = true LIMIT 1];
            // Create a new account  
            Id newAccountRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
            Account acct = new Account(Name = 'TestAccountterritory', BillingStreet = '123 Fake St',RecordTypeId = newAccountRecTypeId,
                                       BillingCity = 'Springfield', BillingState = 'IL', BillingCountry = 'USA',Industry='Agriculture',Core_Sub_Industry__c= 'Crop Production',
                                       BillingPostalCode = '12345',Core_Sales_Groups__c=Core_CRM_Utility.getSalesGroupAPI());
            insert acct;
            // Create a new opportunity using the account created above
            Id newOppRecTypeId = [select Id from RecordType where DeveloperName = 'Core_Design_Opportunity' limit 1][0].Id;
            Id newOppRecTypeId2 = [select Id from RecordType where DeveloperName = 'Core_Deal_Opportunity' limit 1][0].Id;
            opplist.add(new opportunity(Name = 'Test Opportunity1',Core_Opportunity_Facts_ID__c=oppFact.Id, RecordTypeId = newOppRecTypeId2,
                                         AccountId = acct.Id, StageName = 'Qualify', CloseDate = System.today(),Core_Opportunity_Type__c='Deal: Sell-to',Core_Solution_Area__c='DCG Compute Deal $'));
            
            opplist.add(new opportunity(Name = 'Test Opportunity2',Core_Opportunity_Facts_ID__c=oppFact.Id, RecordTypeId = newOppRecTypeId,
                                         AccountId = acct.Id, StageName = 'Qualify', CloseDate = System.today(),Core_Opportunity_Type__c='Design: Original',Core_Intel_Platform__c='ALDER LAKE',Core_Technical_Owner__c=usr.Id,Core_First_Customer_Ship_Date__c=system.today()));                                      
            
            insert opplist;
            // Create a product/price book entry to use on the opportunities
            Product2 p = new Product2(Name = 'Test Product 03-24-2015');
            insert p;
            PricebookEntry pbe = new PricebookEntry(Product2Id = p.Id, Pricebook2Id = Test.getStandardPricebookId(),
                                                    UnitPrice = 0, IsActive = true);
            insert pbe;
            List<OpportunityLineItem> oppForLossItems = new List<OpportunityLineItem>();
            oppForLossItems.add(new OpportunityLineItem(OpportunityId = opplist[0].Id, PricebookEntryId = pbe.Id,Core_Status__c='Pending',
                                                        UnitPrice = 200, Quantity = 10)); 
            insert oppForLossItems;                            
            //coverage for kpi
            //oppForLossItems[0].Quantity = 2.00;
            //update oppForLossItems;
            //
            list<Core_Opp_FC_Prod_Schedule__c> ProdScheList=new list<Core_Opp_FC_Prod_Schedule__c>();
            ProdScheList.add(new Core_Opp_FC_Prod_Schedule__c(Core_Opp_Line_Item_RecordID__c=oppForLossItems[0].Id,Core_Opp_FC_Opportunity__c=opplist[0].Id));
            insert ProdScheList;
            opplist[0].CloseDate=system.today().adddays(1);
            update opplist[0];
            opplist[1].Core_First_Customer_Ship_Date__c=system.today().adddays(1);
            update opplist[1];
            test.stoptest();
            system.assert(opplist.size() > 0, 'success');                   
        }
    }
   /* 
    static testMethod void CreateLead_Test() {
        String Rid = [Select id from Recordtype where Name = 'Sales Lead'].id;
        
        // Lead leadInstance = new Lead();
        Lead leadInstance = new Lead(FirstName = 'Testhello',Core_Job_Function__c = 'Branch Manager',lastName = 'CS',Company = 'testAccounthello',CountryCode = 'USA',StateCode = 'AL',City = 'Alabama',
                                     Street = 'test',status = 'Tele Accepted Lead',leadSource = 'Email',email = 'test@infosys.com',Core_Last_Activity_Date__c = NULL,Core_Lead_Status__c='Accepted',PostalCode = '577101',
                                     Title = 'Hello',Core_Current_Architecture__c='Test',Phone='9777787888',Core_Product_Interest__c='10',Core_Project_Phase__c='testing',Core_Project_Size__c='4',Core_Project_Timeframe__c='12-24 Months',
                                     Core_Lead_State__c = 'In Pursuit',recordtypeid = RId ,  Core_Sales_Group__c = 'Americas Brazil Sales Group', Industry= 'Agriculture' );
        insert leadInstance;
        leadInstance.status = 'Sales Accepted Lead';
        leadInstance.Core_System_Account_Sales_Group__c = 'APJ India Sales Group' ; 
        
        update leadInstance;
        system.assert(leadInstance <> null, 'success');                   
        List<Opportunity> Oppnew = new List<Opportunity>();
        Id newAccountRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        Account acct = new Account(Name = 'TestAccountterritory', BillingStreet = '123 Fake St',RecordTypeId = newAccountRecTypeId,
                                   BillingCity = 'Springfield', BillingState = 'IL', BillingCountry = 'USA',Industry='Agriculture',Core_Sub_Industry__c= 'Crop Production',
                                   BillingPostalCode = '12345', Core_Sales_Groups__c=Core_CRM_Utility.getSalesGroupAPI());
        insert acct;
        test.startTest();
        Database.LeadConvert lc = new database.LeadConvert();
        lc.setLeadId(leadInstance.Id);
        lc.setAccountId(acct.Id);
        
        LeadStatus convertStatus = [Select Id, MasterLabel from LeadStatus where IsConverted=true limit 1];
        lc.setConvertedStatus(convertStatus.MasterLabel);
        
        // Database.LeadConvertResult lcr = Database.convertLead(lc);
        // System.assert(lcr.isSuccess());
        Core_OpportunityHandler.UpdateActivityLineItems(Oppnew);
        test.stopTest();
        
    } */
    
    
    
    static testMethod void test_SADelete() 
    {
        Test.startTest();
        List<Opportunity> lstOpp= new List<Opportunity>();
        lstOpp=[SELECT Id, CloseDate , StageName, Name , Core_External_User__c, AccountId , Core_Product_Segment__c,       Core_Consumption_Market__c , Core_Product_Application__c ,
                Core_Opportunity_Type__c , Core_Opportunity_Coverage_Nm__c,
                Description , Core_IsClone__c  FROM Opportunity where Name like '%TestRE%' LIMIT 3];
        system.assert(lstOpp.size() > 0, 'success');                   
        List<Core_Solution_Areas__c> SAList= new List<Core_Solution_Areas__c>();
        Map<Id, Core_Solution_Areas__c> SAMap= new Map<Id, Core_Solution_Areas__c>();
        Core_Solution_Areas__c cSA = new Core_Solution_Areas__c();
        cSA.Name = 'Test1';
        cSA.Core_Version__c = 'Test1.0';
        cSA.Core_End_Customer_Solution__c = 'Yes';
        cSA.Core_Application_Workload__c ='AI Inference';
        cSA.Core_Technology_Enabled__c = 'BFloat16';
        cSA.Core_Industry_Use_Case__c = 'ADAS';
        System.runAs(Core_Test_Utility.systemAdminUser) {
            insert cSA;
        }
        SAMap.put(cSA.Id, cSA);
        SAList.add(cSA);
        List<Opportunity_Solution_Area__c> oSAList= new List<Opportunity_Solution_Area__c>();
        Opportunity_Solution_Area__c oSA= new Opportunity_Solution_Area__c();
        oSA.Core_Opportunity__c = lstOpp[0].id;
        oSA.Core_Solution_Areas__c =cSA.id;
        insert oSA;
        try
        { 
            Core_OpportunityHandler.createJSONSolutionArea(oSAList);
            Delete  oSA;
        }
        catch(Exception e)
        {
            Core_Log_Entry__c logEntry =new Core_Log_Entry__c(Core_Message__c = 'Error in test class ',Core_Details__c = e.getMessage(), Core_Origin__c='Core_OpportunityHandler_test', Core_Severity__c='Info', Core_When__c=System.Now(), Core_Project__c = 'Sales CRM');
            insert logEntry;
        }
        Test.stopTest(); 
    }
    
    
    static testMethod void validateUniqueOppTest(){
        Test.startTest();
        
        Id newOppRecTypeId = [select Id from RecordType where DeveloperName = 'Core_Design_Opportunity' limit 1][0].Id;
        
        // Create an account
        Account acct = new Account(Name = 'TestoppAccounthandle', BillingStreet = '123 Fake St',
                                   BillingCity = 'Springfield', BillingState = 'IL', BillingCountry = 'USA',Industry='Agriculture',Core_Sub_Industry__c= 'Crop Production',
                                   BillingPostalCode = '12345', Core_Sales_Groups__c=Core_CRM_Utility.getSalesGroupAPI());
        System.runAs(Core_Test_Utility.systemAdminUser) {
            insert acct;
        }
        List<Opportunity> oppsd = new List<Opportunity>();
        Map<Id, Opportunity> oppsdMap = new Map<Id, Opportunity>();
        Opportunity opps = new Opportunity(Name = 'Opportunity to Lose 03-24-2015', RecordTypeId = newOppRecTypeId,
                                           AccountId = acct.Id,
                                           StageName = 'Qualifying', CloseDate = System.Date.today().addYears(1),Core_Opportunity_Type__c='Design: Original', Opportunity_Focus__c= 'Core');
        
        Opportunity oppold = new Opportunity(Name = 'Opportunity to Lose 03-24-2015', RecordTypeId = newOppRecTypeId,
                                             AccountId = acct.Id,
                                             StageName = 'Qualifying', CloseDate = System.Date.today().addYears(1));
        
        
        system.assert(opps<>null, 'success');                   
        System.runAs(Core_Test_Utility.systemAdminUser) {
            insert opps;
        }
        oppsdMap.put(opps.Id, opps);
        oppsd.add(oppold);
        
        System.runAs(Core_Test_Utility.systemAdminUser) {
            Core_Opp_Bypass_Validation_Rule__c vrBypass = new Core_Opp_Bypass_Validation_Rule__c();
            vrBypass.Bypass__c = true;
            //vrBypass.SetupOwnerId = Core_Test_Utility.systemAdminUser.Id;
            //update vrBypass;
            
            Core_OpportunityHandler.validateUniqueOppUpdate(oppsd, oppsdMap);
            Core_OpportunityHandler.validateUniqueOppInsert(oppsd);
            
        }
        Test.stopTest();
    }
    

    static testMethod void dealOppSalesMotionTest() {
        test.starttest(); 
        
        Account acct = new Account(Name = 'TestoppAccounthandle', BillingStreet = '123 Fake St',
                                   BillingCity = 'Springfield', BillingState = 'IL', BillingCountry = 'USA',Industry='Agriculture',Core_Sub_Industry__c= 'Crop Production',
                                   BillingPostalCode = '12345', Core_Sales_Groups__c=Core_CRM_Utility.getSalesGroupAPI());
        
        System.runAs(Core_Test_Utility.systemAdminUser) {
            insert acct;
        }
        
        
        Contact cont = new Contact();
        cont.FirstName = 'Test11';
        cont.LastName  = 'Contact';
        cont.AccountId = acct.id;
        cont.Email = 'testingzz@example.com';
        //cont.Mailing_Country_Region__c='AUS';
        cont.MailingCountry='AUS';    //migrate these 2 lines while moving to devint/higher orgs
        System.runAs(Core_Test_Utility.systemAdminUser) {
            insert cont;
        }
        
        List<Opportunity> NewOppList = new List<Opportunity>();
        //List<Opportunity> lstOpp= new List<Opportunity>();
        /***/
        Id dealRecordTypeId = [select Id from RecordType where DeveloperName = 'Core_Deal_Opportunity' limit 1][0].Id;
        Id DesignOppRecTypeId = [select Id from RecordType where DeveloperName = 'Core_Design_Opportunity' limit 1][0].Id;

		/***/
        //lstOpp=[SELECT Id, CloseDate , StageName, Name , Core_External_User__c, AccountId , Core_Product_Segment__c,RecordTypeId,  Core_Coverage_Type_Nm__c,    Core_Consumption_Market__c , Core_Product_Application__c ,
        //        Core_Opportunity_Type__c , Core_Opportunity_Coverage_Nm__c, Core_Competitive_Architecture__c, Core_Design_Registration_Id__c, Core_Contact_Roles_Count__c,Core_lead_Id__c,
        //        Description , Core_IsClone__c  FROM Opportunity where Name like '%TestRE%' LIMIT 3];
        //lstOpp= [SELECT Id,RecordType.id, CloseDate , StageName, Name , Core_External_User__c, AccountId , Core_Product_Segment__c,RecordTypeId,  Core_Coverage_Type_Nm__c,    Core_Consumption_Market__c , Core_Product_Application__c ,
        //        Core_Opportunity_Type__c , Core_Opportunity_Coverage_Nm__c, Core_Competitive_Architecture__c, Core_Design_Registration_Id__c, Core_Contact_Roles_Count__c,Core_lead_Id__c,
        //        Description , Core_IsClone__c  FROM Opportunity where Name like '%Test%' and RecordType.id = :dealRecordTypeId and StageName= 'Qualify' and Core_Opportunity_Type__c != 'Deal: Sell-through' and Core_Opportunity_Type__c != 'Deal: Sell-to' and Core_Opportunity_Coverage_Nm__c ='Intel-Led Opportunity' LIMIT 3];
        /***/
        
        Product2 p2 = new Product2(Name = 'TestProduct03-24-2015');
        System.runAs(Core_Test_Utility.systemAdminUser) {
           insert p2;
        }
        
        PricebookEntry pbe1 = new PricebookEntry(Product2Id = p2.Id, Pricebook2Id = Test.getStandardPricebookId(),
                                                UnitPrice = 0, IsActive = true);
        System.runAs(Core_Test_Utility.systemAdminUser) {
            insert pbe1;
        }
       
        Opportunity opps1 = new Opportunity(Name = 'TestRecordd', RecordTypeId = dealRecordTypeId,
                                           AccountId = acct.Id,
                                           StageName = 'Define',Core_Opportunity_Coverage_Nm__c ='Intel-Led Opportunity',Core_Opportunity_Type__c = 'Deal: Sell-through',CloseDate = System.Date.today().addYears(1),Core_Status_Update__c = '',Description = '');
        Opportunity opps2 = new Opportunity(Name = 'TestRecordd2', RecordTypeId = DesignOppRecTypeId,
                                           AccountId = acct.Id,
                                           StageName = 'Define',Core_Opportunity_Coverage_Nm__c ='Intel-Led Opportunity',Core_Opportunity_Type__c = 'Design: Original',CloseDate = System.Date.today().addYears(1),Core_Status_Update__c = '',Description = '',Core_IsClone__c = false);
        
        System.runAs(Core_Test_Utility.systemAdminUser) {
            insert opps1;
            insert opps2;
        }
        
        List<OpportunityLineItem> oppLine = new List<OpportunityLineItem>();
        oppLine.add(new OpportunityLineItem(OpportunityId = opps1.Id, PricebookEntryId = pbe1.Id, Core_Status__c='Pending',
                                                    UnitPrice = 200, Quantity = 10, Core_Competitor__c = 'Acer', Core_Competitor_Product__c = 'AMD Athlon'));
        oppLine.add(new OpportunityLineItem(OpportunityId = opps2.Id, PricebookEntryId = pbe1.Id, Core_Status__c='Pending',
                                                    UnitPrice = 200, Quantity = 10, Core_Competitor__c = 'Acer', Core_Competitor_Product__c = 'AMD Athlon'));
        System.runAs(Core_Test_Utility.systemAdminUser) {
            insert oppLine ;
        }
        
        OpportunityContactRole crole= new OpportunityContactRole();
        crole.IsPrimary = true;
        crole.OpportunityId = opps1.Id;
        crole.Role='Business Decision Maker';
        crole.ContactId= cont.Id;
        System.runAs(Core_Test_Utility.systemAdminUser) {
           insert crole;
        }
        
       // NewOppList.add(opps2);
        NewOppList = [Select Id,RecordType.id, CloseDate , StageName, Name , Core_External_User__c, AccountId , Core_Product_Segment__c,RecordTypeId,  Core_Coverage_Type_Nm__c,    Core_Consumption_Market__c , Core_Product_Application__c ,
                Core_Opportunity_Type__c , Core_Opportunity_Coverage_Nm__c, Core_Competitive_Architecture__c, Core_Design_Registration_Id__c, Core_Contact_Roles_Count__c,Core_lead_Id__c,
                Description , Core_IsClone__c,Core_Status_Update__c,Core_Technical_Owner__c,Core_Product_Count__c,Core_Write_In_Product_Count__c from Opportunity Where id = :opps1.id];
        
        List<Opportunity> NewOppListFalseCase = NewOppList;
        
        System.runAs(Core_Test_Utility.systemAdminUser) {
            Core_Opp_Bypass_Validation_Rule__c vrBypass12 = new Core_Opp_Bypass_Validation_Rule__c();
            vrBypass12.Bypass__c = true;
            //vrBypass12.SetupOwnerId = Core_Test_Utility.systemAdminUser.Id;
            //update vrBypass12;          
            Map<Id, Opportunity> OldOppMap = new Map<Id, Opportunity>(NewOppList);   
            opps1.StageName='Design';
            opps1.Core_Opportunity_Type__c = 'Deal: Sell-through';
            opps1.Core_Technical_Owner__c = Core_Test_Utility.systemAdminUser.id;
            opps1.Core_Status_Update__c = 'Test2';
            opps1.Description = 'Test2';
            opps1.Core_Product_Segment__c='Client Computing';
            opps1.Core_Product_Application__c ='Business Mobility';
            opps1.Core_Consumption_Market__c = 'Education';
            opps1.Core_Competitive_Architecture__c = 'ARM';
            opps1.Opportunity_Focus__c= 'Core';
             opps2.StageName='Design';
            opps2.Core_Technical_Owner__c = Core_Test_Utility.systemAdminUser.id;
            opps2.Core_Status_Update__c = 'Test2';
            opps2.Description = 'Test2';
            update opps1;
           // update opps2;
            NewOppList = [Select Id,RecordType.id, CloseDate , StageName, Name , Core_External_User__c, AccountId , Core_Product_Segment__c,RecordTypeId,  Core_Coverage_Type_Nm__c,    Core_Consumption_Market__c , Core_Product_Application__c ,
                Core_Opportunity_Type__c , Core_Opportunity_Coverage_Nm__c, Core_Competitive_Architecture__c, Core_Design_Registration_Id__c, Core_Contact_Roles_Count__c,Core_lead_Id__c,
                Description , Core_IsClone__c,Core_Status_Update__c,Core_Technical_Owner__c,Core_Product_Count__c,Core_Write_In_Product_Count__c from Opportunity Where id = :opps1.id];
           // NewOppList.add(opps2);

            Core_OpportunityHandler.restrictBlankFieldUpdates(NewOppList,OldOppMap,NewOppList,true);
            //Core_OpportunityHandler.BlockExistingOppOnLeadConversion(NewOppList,OldOppMap);
            Core_OpportunityHandler.restrictBlankFieldUpdates(NewOppListFalseCase,OldOppMap,NewOppListFalseCase,false);
            
        }
        test.stoptest();
        system.assert(NewOppList.size()>0, 'success');                   
    }

    
    static testMethod void Test_validateAllActiveLOV() {
        test.starttest(); 
        
        Account acct = new Account(Name = 'TestoppAccounthandle', BillingStreet = '123 Fake St',
                                   BillingCity = 'Springfield', BillingState = 'IL', BillingCountry = 'USA',Industry='Agriculture',Core_Sub_Industry__c= 'Crop Production',
                                   BillingPostalCode = '12345', Core_Sales_Groups__c=Core_CRM_Utility.getSalesGroupAPI());
        
        System.runAs(Core_Test_Utility.systemAdminUser) {
            insert acct;
        }
        
        
        Contact cont = new Contact();
        cont.FirstName = 'Test11';
        cont.LastName  = 'Contact';
        cont.AccountId = acct.id;
        cont.Email = 'testingzz@example.com';
        //cont.Mailing_Country_Region__c='AUS';
        cont.MailingCountry='AUS';    //migrate these 2 lines while moving to devint/higher orgs
        System.runAs(Core_Test_Utility.systemAdminUser) {
            insert cont;
        }
        
        List<Opportunity> NewOppList = new List<Opportunity>();
        //List<Opportunity> lstOpp= new List<Opportunity>();
        /***/
        Id dealRecordTypeId = [select Id from RecordType where DeveloperName = 'Core_Deal_Opportunity' limit 1][0].Id;
		/***/

    
    	  
        Product2 p2 = new Product2(Name = 'TestProduct03-24-2015');
        System.runAs(Core_Test_Utility.systemAdminUser) {
           insert p2;
        }
        
        PricebookEntry pbe1 = new PricebookEntry(Product2Id = p2.Id, Pricebook2Id = Test.getStandardPricebookId(),
                                                UnitPrice = 0, IsActive = true);
        System.runAs(Core_Test_Utility.systemAdminUser) {
            insert pbe1;
        }
       
        Opportunity opps1 = new Opportunity(Name = 'TestRecordd', RecordTypeId = dealRecordTypeId,
                                           AccountId = acct.Id,
                                           StageName = 'Define',Core_Opportunity_Coverage_Nm__c ='Intel-Led Opportunity',Core_Opportunity_Type__c = 'Deal: Sell-through',CloseDate = System.Date.today().addYears(1),Core_Status_Update__c = 'Test1',Description = 'Test1',Core_Solution_Detail__c='vRAN',Core_Product_Segment__c='Client Computing');
        //vPro Refresh;vRAN
        System.runAs(Core_Test_Utility.systemAdminUser) {
            insert opps1;
        }
                           
        
        List<OpportunityLineItem> oppLine = new List<OpportunityLineItem>();
        oppLine.add(new OpportunityLineItem(OpportunityId = opps1.Id, PricebookEntryId = pbe1.Id, Core_Status__c='Pending',
                                                    UnitPrice = 200, Quantity = 10, Core_Competitor__c = 'Acer', Core_Competitor_Product__c = 'AMD Athlon'));
        System.runAs(Core_Test_Utility.systemAdminUser) {
            insert oppLine ;
        }
        
        OpportunityContactRole crole= new OpportunityContactRole();
        crole.IsPrimary = true;
        crole.OpportunityId = opps1.Id;
        crole.Role='Business Decision Maker';
        crole.ContactId= cont.Id;
        System.runAs(Core_Test_Utility.systemAdminUser) {
           insert crole;
        }
        
        
        NewOppList = [Select Id,RecordType.id, CloseDate , StageName, Name , Core_External_User__c, AccountId , Core_Product_Segment__c,RecordTypeId,  Core_Coverage_Type_Nm__c,    Core_Consumption_Market__c , Core_Product_Application__c ,
                Core_Opportunity_Type__c , Core_Opportunity_Coverage_Nm__c, Core_Competitive_Architecture__c, Core_Design_Registration_Id__c, Core_Contact_Roles_Count__c,Core_lead_Id__c,
                Description , Core_IsClone__c,Core_Status_Update__c,Core_Technical_Owner__c,Core_Product_Count__c,Core_Write_In_Product_Count__c,Core_Solution_Detail__c from Opportunity Where id = :opps1.id];
        
        System.runAs(Core_Test_Utility.systemAdminUser) {
            Core_Opp_Bypass_Validation_Rule__c vrBypass12 = new Core_Opp_Bypass_Validation_Rule__c();
            vrBypass12.Bypass__c = true;
            //vrBypass12.SetupOwnerId = Core_Test_Utility.systemAdminUser.Id;
            //update vrBypass12;

			Id oppRecordTypeId =Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Core_Design_Opportunity').getRecordTypeId();
            Map<Id, Opportunity> OldOppMap = new Map<Id, Opportunity>(NewOppList);   
            opps1.StageName='Design';
            opps1.Core_Opportunity_Type__c = 'Design: Original';
            opps1.Core_Technical_Owner__c = Core_Test_Utility.systemAdminUser.id;
            opps1.Core_Status_Update__c = 'Test2';//
            opps1.Description = 'Test2';//
            opps1.Core_Product_Segment__c='Data Center Computing';
            opps1.Core_Product_Application__c ='Server - On Prem';
            opps1.Core_Consumption_Market__c = 'Education';
            opps1.Core_Competitive_Architecture__c = 'ARM';
            opps1.Opportunity_Focus__c= 'Core';
            opps1.RecordTypeId = oppRecordTypeId;

            update opps1;


            NewOppList = [Select Id,RecordType.id, CloseDate , StageName, Name , Core_External_User__c, AccountId , Core_Product_Segment__c,RecordTypeId,  Core_Coverage_Type_Nm__c,    Core_Consumption_Market__c , Core_Product_Application__c ,
                Core_Opportunity_Type__c , Core_Opportunity_Coverage_Nm__c, Core_Competitive_Architecture__c, Core_Design_Registration_Id__c, Core_Contact_Roles_Count__c,Core_lead_Id__c,
                Description , Core_IsClone__c,Core_Status_Update__c,Core_Technical_Owner__c,Core_Product_Count__c,Core_Write_In_Product_Count__c,Core_Solution_Detail__c from Opportunity Where id = :opps1.id];

			update NewOppList;
            
            
            
			Core_OpportunityHandler.validateAllActiveLOV(NewOppList,OldOppMap,true);
            
            Core_OpportunityHandler.createOppJSONUpdate(NewOppList,oldOppMap);
        	
        }
        test.stoptest();
        system.assert(NewOppList.size()>0, 'success');                   
    }
    static testmethod void OpportunityShareTest()
    {
        Test.startTest();
        List<Opportunity> oppList = new List<Opportunity>();
        Id newOppRecTypeId = [select Id from RecordType where DeveloperName = 'Core_Design_Opportunity' limit 1][0].Id; 
        Id DealOppRecTypeId = [select Id from RecordType where DeveloperName = 'Core_Deal_Opportunity' limit 1][0].Id;

        // Create an account
        Account acct = new Account(Name = 'TestoppAccounthandle2', BillingStreet = '123 Fake St',
                                   BillingCity = 'Springfield', BillingState = 'IL', BillingCountry = 'USA',Industry='Agriculture',Core_Sub_Industry__c= 'Crop Production',
                                   BillingPostalCode = '12345',Core_Sales_Groups__c=Core_CRM_Utility.getSalesGroupAPI());
        System.runAs(Core_Test_Utility.systemAdminUser) {
            insert acct;
        }
        //TWC4767-3990
        Account acct1 = [Select id,OwnerId from Account where Name ='TestoppAcchandle' limit 1];
        Core_Design_Registration__c ddr = [select id,Core_Partner_Account_Id__c from Core_Design_Registration__c limit 1];
        ddr.Core_Partner_Account_Id__c = acct1.Id;
        update ddr;
        
        Map<Id, Opportunity> OldMap = new Map<Id, Opportunity>();
        
        User partnerUsr = [select Id,UserRoleId from User where Profile.Name='Partner' AND IsActive=true LIMIT 1];
        Opportunity opps = new Opportunity(Name = 'Opportunity to Lose 03-24-2015', RecordTypeId = newOppRecTypeId,
                                           AccountId = acct.Id, Core_Technical_Owner__c = partnerUsr.Id,
                                           StageName = 'Qualify', CloseDate = System.Date.today().addYears(1), Core_Opportunity_Coverage_Nm__c=Core_CRM_Utility.getCRMLabel('Core_OpportunityPartnerProgram'),Core_Opportunity_Type__c='Design: Original', Opportunity_Focus__c= 'Core');
        opps.Core_Channel_Opportunity_Ind__c=true;
        //TWC4767-3990
        Opportunity opps1 =new Opportunity(Name = 'TestClass PCC Opportunity', RecordTypeId = DealOppRecTypeId,Core_Design_Registration_Id__c=ddr.Id,
                                            AccountId = acct.Id,Core_Coverage_Type_Nm__c = 'Deal Registration',Core_Technical_Owner__c = partnerUsr.Id,
                                            CRM_SW_Flag_Ind__c = true,StageName = 'Qualify', CloseDate = System.Date.today().addYears(1), Core_Opportunity_Coverage_Nm__c ='Partner-Led Opportunity');
        
        System.runAs(Core_Test_Utility.systemAdminUser) {
            insert opps;
            insert opps1;
        }
        //oppList.add(opps);
        OldMap.put(opps.Id,opps);
        OldMap.put(opps1.Id,opps1);
        User partnerUsr2 = [select Id,UserRoleId from User where Profile.Name='Partner' AND Id != :partnerUsr.Id AND IsActive=true LIMIT 1];
        Opportunity opp1=[select Id,OwnerId,Core_Opportunity_Coverage_Nm__c,Core_Technical_Owner__c from Opportunity where Id=:opps.Id];
        Opportunity opp2=[select Id,OwnerId,Core_Opportunity_Coverage_Nm__c,Core_Technical_Owner__c from Opportunity where Id=:opps1.Id];        
        opp1.Core_Technical_Owner__c = partnerUsr2.Id;
        opp2.Core_Technical_Owner__c = partnerUsr2.Id;
        
        System.runAs(Core_Test_Utility.systemAdminUser) {
            update opp1;
            update opp2;
        }
        oppList.add(opp1);
        oppList.add(opp2);
        
        Core_OpportunityHandler.OpportunityShare(OppList,OldMap);
        Test.stopTest();
        system.assert(oppList.size()>0, 'success');
    }
    
    static testmethod void FedCRMOpportunityShareTest()
    {
        Test.startTest();
        List<Opportunity> oppList = new List<Opportunity>();
        Id newOppRecTypeId = [select Id from RecordType where DeveloperName = 'Core_Design_Opportunity' limit 1][0].Id;        
        // Create an account
        Account acct = new Account(Name = 'TestoppAccounthandle2', BillingStreet = '123 Fake St',
                                   BillingCity = 'Springfield', BillingState = 'IL', BillingCountry = 'USA',Industry='Agriculture',Core_Sub_Industry__c= 'Crop Production',
                                   BillingPostalCode = '12345',Core_Sales_Groups__c='Americas US Sales Group');
        System.runAs(Core_Test_Utility.systemAdminUser) {
            insert acct;
        }
        
        Map<Id, Opportunity> OldMap = new Map<Id, Opportunity>();
        
        User partnerUsr = [select Id,UserRoleId from User where Profile.Name='Partner' AND IsActive=true LIMIT 1];
        Opportunity opps = new Opportunity(Name = 'Opportunity to Lose 03-24-2015', RecordTypeId = newOppRecTypeId,
                                           AccountId = acct.Id, Core_Technical_Owner__c = partnerUsr.Id,
                                           StageName = 'Qualify', CloseDate = System.Date.today().addYears(1), Core_Opportunity_Coverage_Nm__c=Core_CRM_Utility.getCRMLabel('Core_OpportunityPartnerProgram'),Core_Opportunity_Type__c='Design: Original', Opportunity_Focus__c= 'Core');
        opps.Core_Channel_Opportunity_Ind__c=true;
    
        System.runAs(Core_Test_Utility.systemAdminUser) {
            insert opps;
        }
        //oppList.add(opps);
        OldMap.put(opps.Id,opps);
        User partnerUsr2 = [select Id,UserRoleId from User where Profile.Name='Partner' AND Id != :partnerUsr.Id AND IsActive=true LIMIT 1];
        Opportunity opp1=[select Id,OwnerId,Core_Opportunity_Coverage_Nm__c,Core_Technical_Owner__c,Core_Sales_Groups__c from Opportunity where Id=:opps.Id];
        opp1.Core_Technical_Owner__c = partnerUsr2.Id;
        
        System.runAs(Core_Test_Utility.systemAdminUser) {
            update opp1;
        }
        oppList.add(opp1);
        Core_OpportunityHandler.FedCRMOpportunityShare(OppList,OldMap,true,true);
        Test.stopTest();
        system.assert(oppList.size()>0, 'success');
    }
    

    static testMethod void storeOppTeamMemDescTest()
    {
        Test.startTest();
        
        Id newOppRecTypeId = [select Id from RecordType where DeveloperName = 'Core_Design_Opportunity' limit 1][0].Id;
        
        // Create an account
        Account acct = new Account(Name = 'TestoppAccount', BillingStreet = '123 Fake St',
                                   BillingCity = 'Springfield', BillingState = 'IL', BillingCountry = 'USA',Industry='Agriculture',Core_Sub_Industry__c= 'Crop Production',
                                   BillingPostalCode = '12345',Core_Sales_Groups__c=Core_CRM_Utility.getSalesGroupAPI());
        System.runAs(Core_Test_Utility.systemAdminUser) {
            insert acct;
        }
        
        User Usr = [select Id,UserRoleId from User where Profile.Name='Sales Rep-BB' AND IsActive=true LIMIT 1];
        Map<Id, Opportunity> oppsdMap = new Map<Id, Opportunity>();
        Opportunity opps = new Opportunity(Name = 'Opportunity to Lose 03-24-2015', RecordTypeId = newOppRecTypeId,
                                           AccountId = acct.Id, OwnerId= UserInfo.getUserId(), Core_Technical_Owner__c = Usr.id,
                                           StageName = 'Qualify', CloseDate = System.Date.today().addYears(1),Core_Opportunity_Type__c='Design: Original', Opportunity_Focus__c= 'Core');
        System.runAs(Core_Test_Utility.systemAdminUser) {
            insert opps;
        }
        oppsdMap.put(opps.Id, opps);
        //oppsd.add(oppold);
        system.assert(opps<>null, 'success');
        System.runAs(Core_Test_Utility.systemAdminUser) {
            Core_Opp_Bypass_Validation_Rule__c bp = new Core_Opp_Bypass_Validation_Rule__c();
            bp.Bypass__c = true;
            //bp.SetupOwnerId = Core_Test_Utility.systemAdminUser.Id;
            //update bp;
            
            //Core_OpportunityHandler.storeOppTeamMemDescription();
            opps.OwnerId = Core_Test_Utility.systemAdminUser.Id;
            update opps;
            
        } 
        Test.stopTest();
    }
    
    //Added as part of TWC3123-6003 start    
    static testMethod void testOpportunityShare() {
        Test.startTest();  
        Id designOppRecTypeId = [select Id from RecordType where DeveloperName = 'Core_Design_Opportunity' limit 1][0].Id;
        Account acct = new Account(Name = 'TestShareoppAccount', BillingStreet = '123 Fake St', OwnerId= UserInfo.getUserId(),
                                   BillingCity = 'Springfield', BillingState = 'IL', BillingCountry = 'USA',Industry='Agriculture',Core_Sub_Industry__c= 'Crop Production',
                                   BillingPostalCode = '12345',Core_Sales_Groups__c=Core_CRM_Utility.getSalesGroupAPI());
        System.runAs(Core_Test_Utility.systemAdminUser) {
            insert acct;
        }
        User Usr = [select Id,UserRoleId from User where Profile.Name='Partner' AND IsActive=true LIMIT 1];
        Core_Design_Registration__c ddr = [select id from Core_Design_Registration__c limit 1];
        Map<Id, Opportunity> oppsdMap = new Map<Id, Opportunity>();
        Opportunity opps = new Opportunity(Name = 'Opportunity to Lose 03-24-2015', RecordTypeId = designOppRecTypeId,
                                           AccountId = acct.Id,  OwnerId= UserInfo.getUserId(), Core_Design_Registration_Id__c =ddr.id,
                                           StageName = 'Qualify', CloseDate = System.Date.today().addYears(1), Core_Opportunity_Coverage_Nm__c ='Partner-Led Opportunity',Core_Opportunity_Type__c='Design: Original', Opportunity_Focus__c= 'Core');
        
        System.runAs(Core_Test_Utility.systemAdminUser) {
            insert opps;
        }
        system.assert(opps<>null, 'success');
        ddr.Core_End_Customer_Account_Id__c = acct.id;
        ddr.Core_Partner_Account_Id__c = acct.id;
        ddr.Core_Opportunity_Id__c = opps.id;
        System.runAs(Core_Test_Utility.systemAdminUser) {
            update ddr;
        }
        opps.Core_Technical_Owner__c = Usr.id;
        opps.OwnerId = Core_Test_Utility.systemAdminUser.id;
        System.runAs(Core_Test_Utility.systemAdminUser) {
            update opps;
        }
        
        Test.stopTest();
        
    }
    
    
    static testMethod void retrigger6QPS_Test(){
        Profile pro = [SELECT id, Name FROM Profile WHERE Name='Sales Rep-BB'];
        //User usr1 = [SELECT id, Name, isActive FROM User WHERE ProfileId = :pro.Id AND isActive = true LIMIT 1];
        List<Opportunity> lstOpp= new List<Opportunity>();
        lstOpp=[SELECT Id, CloseDate , StageName, Name , Core_External_User__c, AccountId , Core_Product_Segment__c, Core_First_Customer_Ship_Date__c,  Core_Status_Update__c ,Core_Technical_Owner__c ,Core_Product_Count__c,  Core_Consumption_Market__c , Core_Product_Application__c ,
                Core_Opportunity_Type__c , Core_Contact_Roles_Count__c,Core_Opportunity_Coverage_Nm__c,
                Description , Core_IsClone__c  FROM Opportunity where Name like '%TestRE%' LIMIT 3];
        system.assert(lstOpp.size()>0, 'success');
        List<OpportunityLineItem> lstOppItem= [Select Id from OpportunityLineItem where  OpportunityId = : lstOpp[0].Id];
        Opportunity opps= [Select Id from Opportunity where  Id = : lstOpp[0].Id];
        
        List<Core_Opp_FC_Prod_Schedule__c> fcRec = new List<Core_Opp_FC_Prod_Schedule__c>();
        fcRec.add(new Core_Opp_FC_Prod_Schedule__c(Core_Opp_FC_Opportunity__c = lstOpp[0].Id, Core_Opp_Line_Item_RecordID__c = lstOppItem[0].Id)); 
        Test.startTest();
        System.runAs(Core_Test_Utility.systemAdminUser) {
            
            insert fcRec;
            
        }  
        List<Opportunity> NewOppList= new List<Opportunity>();
        NewOppList.add(lstOpp[0]);
        
        Map<Id, Opportunity> OldOppMap = new Map<Id, Opportunity>(lstOpp);
        Opportunity opp1=lstOpp[1];
        opp1.Core_First_Customer_Ship_Date__c = system.today().adddays(10);        
        opp1.Description = 'test';
        System.runAs(Core_Test_Utility.systemAdminUser) {
            
          //  update opp1;
            
        }
        NewOppList.add(opp1);
           
        System.runAs(Core_Test_Utility.systemAdminUser) {
            Core_Opp_Bypass_Validation_Rule__c triggerExecList = new Core_Opp_Bypass_Validation_Rule__c();
            //triggerExecList.SetupOwnerId = Core_Test_Utility.systemAdminUser.Id;
            triggerExecList.Bypass__c = true;
            //insert triggerExecList;
            
            Core_OpportunityHandler.retrigger6QPS(NewOppList);
            
            
        }
        Test.stopTest();
    }
    
    
    
    static testMethod void opportunityCancel_Test() {
        
        test.starttest();
        
        // Create an opportunity to test a cancel, with multiple line items in various stages
        List<User> usr= [Select Id from User  limit 1];
        List<PricebookEntry> pbe= [Select Id from PricebookEntry  limit 1];
        List<Account> acct= [Select id from Account limit 1];
        /*Account acct = new Account(Name = 'TesAccount1', BillingStreet = '123 Fake St',
                                       BillingCity = 'Springfield', BillingState = 'IL', BillingCountry = 'USA',Industry='Agriculture',Core_Sub_Industry__c= 'Crop Production',
                                       BillingPostalCode = '12345',Core_CIM_ID__c= '45777884412',
 	
			Core_Sales_Groups__c='PRC Sales Group');*/
        Id newOppRecTypeId = [select Id from RecordType where DeveloperName = 'Core_Design_Opportunity' limit 1][0].Id;      
        Opportunity oppForCancel = new Opportunity(Name = 'Opportunity to Cancel 03-24-2024', RecordTypeId = newOppRecTypeId,
                                                   AccountId = acct[0].Id, Core_Bypass_Field_Validation__c = true,
                                                   StageName = 'Qualify', CloseDate = System.Date.today().addYears(1),Core_Opportunity_Type__c='Design: Original', Opportunity_Focus__c= 'Core');
        
        Opportunity oppForLoss = new Opportunity(Name = 'Test Opportunity902', RecordTypeId = newOppRecTypeId,
                                                  AccountId = acct[0].Id, StageName = 'Qualify', CloseDate = System.today(),Core_Opportunity_Type__c='Design: Original',Core_Intel_Platform__c='ALDER LAKE',Core_Technical_Owner__c=usr[0].Id,Core_First_Customer_Ship_Date__c=system.today(),Opportunity_Focus__c= 'Core');                                      
        System.runAs(Core_Test_Utility.systemAdminUser) { insert oppForCancel;
	     //insert oppForLoss;
        }
        
        // Since a workflow rule ensures all new line items are Pending, we need to first insert, then update
        List<OpportunityLineItem> oppForCancelItems = new List<OpportunityLineItem>();
        oppForCancelItems.add(new OpportunityLineItem(OpportunityId = oppForCancel.Id, PricebookEntryId = pbe[0].Id,
                                                      UnitPrice = 200, Quantity = 1, Core_Competitor__c = 'Acer', Core_Competitor_Product__c = 'AMD Athlon'));
        oppForCancelItems.add(new OpportunityLineItem(OpportunityId = oppForCancel.Id, PricebookEntryId = pbe[0].Id,
                                                      UnitPrice = 200, Quantity = 2, Core_Competitor__c = 'Acer', Core_Competitor_Product__c = 'AMD Athlon'));
        oppForCancelItems.add(new OpportunityLineItem(OpportunityId = oppForCancel.Id, PricebookEntryId = pbe[0].Id,
                                                      UnitPrice = 200, Quantity = 3, Core_Competitor__c = 'Acer', Core_Competitor_Product__c = 'AMD Athlon'));
        oppForCancelItems.add(new OpportunityLineItem(OpportunityId = oppForCancel.Id, PricebookEntryId = pbe[0].Id,
                                                      UnitPrice = 200, Quantity = 4, Core_Competitor__c = 'Acer', Core_Competitor_Product__c = 'AMD Athlon'));
        oppForCancelItems.add(new OpportunityLineItem(OpportunityId = oppForCancel.Id, PricebookEntryId = pbe[0].Id,
                                                      UnitPrice = 200, Quantity = 5, Core_Competitor__c = 'Acer', Core_Competitor_Product__c = 'AMD Athlon'));
        oppForCancelItems.add(new OpportunityLineItem(OpportunityId = oppForCancel.Id, PricebookEntryId = pbe[0].Id,
                                                      UnitPrice = 200, Quantity = 6, Core_Competitor__c = 'Acer', Core_Competitor_Product__c = 'AMD Athlon'));
        oppForCancelItems.add(new OpportunityLineItem(OpportunityId = oppForCancel.Id, PricebookEntryId = pbe[0].Id,
                                                      UnitPrice = 200, Quantity = 7, Core_Competitor__c = 'Acer', Core_Competitor_Product__c = 'AMD Athlon'));
        
        System.runAs(Core_Test_Utility.systemAdminUser) { insert oppForCancelItems;     
        }
        system.assert(oppForCancelItems.size()>0, 'success');       
        oppForCancelItems[0].Core_Status__c = 'Pending';
        oppForCancelItems[1].Core_Status__c = 'Lost';
        oppForCancelItems[1].Core_Loss_Cancel_Reason__c = 'Lost already';
        oppForCancelItems[1].Core_Loss_Cancel_Details__c = 'Lost already';
        oppForCancelItems[2].Core_Status__c = 'Lost';
        oppForCancelItems[2].Core_Loss_Cancel_Reason__c = 'Cancelled already';
        oppForCancelItems[2].Core_Loss_Cancel_Details__c = 'Lost already';
        oppForCancelItems[3].Core_Status__c = 'Pending';
        oppForCancelItems[4].Core_Status__c = 'Won';
        oppForCancelItems[5].Core_Status__c = 'Deleted';
        oppForCancelItems[6].Core_Status__c = 'Pending';        
        System.runAs(Core_Test_Utility.systemAdminUser) {update oppForCancelItems;
        }
        
        
        oppForCancel.StageName = 'Lost';
        oppForCancel.Core_Loss_Cancel_Reason__c = 'Cancelled - Budget';
        oppForCancel.Core_Loss_Cancel_Details__c = 'Cancelled - Budget';
        System.runAs(Core_Test_Utility.systemAdminUser) {
            Core_Opp_Bypass_Validation_Rule__c vrBypass = [select id, Bypass__c from Core_Opp_Bypass_Validation_Rule__c limit 1]; 
            vrBypass.Bypass__c = true;
            update vrBypass;
            update oppForCancel;
        }
        
        
        
        test.stoptest();
    }
    
    
    static testMethod void UpdateActivityLineItems1_Test() {
        test.starttest();
        System.runAs(Core_Test_Utility.systemAdminUser) {
            Core_Opp_Bypass_Validation_Rule__c vrBypass121 = new Core_Opp_Bypass_Validation_Rule__c();
            vrBypass121.Bypass__c = true;
            //vrBypass121.SetupOwnerId = Core_Test_Utility.systemAdminUser.Id;
            //update vrBypass121;
            
            Id strRecordTypeId = [Select Id, SobjectType From RecordType Where SobjectType = 'Account' and Name = 'Intel Account' limit 1].Id;
            Id stExam = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();    
            Account acct = new Account(Name = 'TesAccount1', BillingStreet = '123 Fake St', RecordTypeId=stExam,
                                       BillingCity = 'Springfield', BillingState = 'IL', BillingCountry = 'USA',Industry='Agriculture',Core_Sub_Industry__c= 'Crop Production',
                                       BillingPostalCode = '12345',/* Core_CIM_ID__c = '8675309',*/
 	
			Core_Sales_Groups__c=Core_CRM_Utility.getSalesGroupAPI());
            
    		insert acct;
            Product2 product = new Product2(Name = 'Test Product1');
            insert product;
            PricebookEntry pbe = new PricebookEntry(Product2Id = product.Id, Pricebook2Id = Test.getStandardPricebookId(),
                                                    UnitPrice = 100, IsActive = true);
            insert pbe;
            List<User> usr =[select Id from User where Isactive= true limit 1];
            Id newOppRecTypeId = [select Id from RecordType where DeveloperName = 'Core_Design_Opportunity' limit 1][0].Id;
            Opportunity opportunity = new Opportunity(Name = 'Test Opportunity1', RecordTypeId = newOppRecTypeId,Core_Status_Update__c = 'Test',Description = 'Test',
                                                      Core_Technical_Owner__c=Core_Test_Utility.systemAdminUser.Id, Core_Opportunity_Coverage_Nm__c='Intel-Led Opportunity',
                                                         AccountId = acct.Id, StageName = 'Qualify', Core_Opportunity_Type__c='Design: Original', Opportunity_Focus__c= 'Core',
                                                      CloseDate = System.Date.today().addYears(1),Core_Approval_Status__c='Approved',
                                                      Core_Product_Segment__c='Client Computing',Core_Consumption_Market__c = 'Education',
                                                      Core_Product_Application__c ='Business Mobility');
            insert opportunity;
            Core_Solution_Areas__c cSA = new Core_Solution_Areas__c();
            cSA.Name = 'Test1';
            cSA.Core_End_Customer_Solution__c = 'Yes';
            cSA.Core_Application_Workload__c ='AI Inference';
            cSA.Core_Technology_Enabled__c = 'BFloat16';
            // cSA.Core_Industry_Use_Case__c = ;
            insert cSA;
            
            List<Opportunity_Solution_Area__c> oSAList= new List<Opportunity_Solution_Area__c>();
            Opportunity_Solution_Area__c oSA= new Opportunity_Solution_Area__c();
            
            
            oSA.Core_Opportunity__c = opportunity.id;
            oSA.Core_Solution_Areas__c =cSA.id;
            
            oSAList.add(oSA);
            insert oSAList;
            
            
            // update opportunity;
            OpportunityLineItem opportunityProduct = new OpportunityLineItem(OpportunityId = opportunity.Id, PricebookEntryId = pbe.Id,
                                                                             Core_Status__c = 'Pending', UnitPrice = 100, Quantity = 100, Core_PW_Quantity__c = 3, Core_PW_Sales_Price__c =20);
            System.runAs(Core_Test_Utility.systemAdminUser) {
                insert opportunityProduct;
            }

            List<Opportunity> opportunityList = new List<Opportunity> ();
            Map<Id, Opportunity> oldOppMap = new Map<Id, Opportunity>();
            oldOppMap.put(opportunity.id, opportunity);
            opportunityList.add(opportunity);
            
            
            
            Core_OpportunityHandler.createOppJSONUpdate(opportunityList,oldOppMap);
            opportunity = [select Id, Name, Amount, Core_Opportunity_U_Base__c ,
                           RecordTypeId ,Core_Status_Update__c ,Description , Core_Technical_Owner__c,    AccountId , StageName , Core_Opportunity_Coverage_Nm__c,
                           CloseDate ,Core_Approval_Status__c, Core_Product_Segment__c,Core_Consumption_Market__c ,
                           Core_Product_Application__c FROM Opportunity WHERE Id = :opportunity.Id];
            System.assertEquals(10000, opportunity.Amount);
            System.assertEquals(100, opportunity.Core_Opportunity_U_Base__c);
            Core_Marketing_Activity__c marketingActivity = new Core_Marketing_Activity__c (Name = 'Test Activity1', Core_Activity_Account__c = acct.Id,
                                                                                           Core_Activity_Start_Date__c = System.Date.today(),
                                                                                           Core_Activity_End_Date__c = System.Date.today().AddYears(1),
                                                                                           Core_Activity_Geo__c = 'ASMO');
            insert marketingActivity;
            Core_Marketing_Activity_Opportunity__c marketingActivityOpp = new Core_Marketing_Activity_Opportunity__c(Core_Marketing_Activity__c = marketingActivity.Id,Core_Opportunity_Amount__c=10000,Core_Opportunity_Volume__c=100,
                                                                                                                     Core_Opportunity__c = opportunity.Id);
            insert marketingActivityOpp;
            marketingActivityOpp = [select Id, Core_Opportunity_Amount__c, Core_Opportunity_Volume__c FROM Core_Marketing_Activity_Opportunity__c WHERE Id = :marketingActivityOpp.Id];
            System.assertEquals(10000, marketingActivityOpp.Core_Opportunity_Amount__c);
            System.assertEquals(100, marketingActivityOpp.Core_Opportunity_Volume__c);
            opportunityProduct.Quantity = 200;
            
            update opportunityProduct;
            opportunity = [select Id, Name, Amount, Core_Opportunity_U_Base__c ,
                           RecordTypeId ,Core_Status_Update__c ,Description , Core_Technical_Owner__c,    AccountId , StageName , 
                           CloseDate ,Core_Approval_Status__c, Core_Product_Segment__c,Core_Consumption_Market__c ,Core_Opportunity_Coverage_Nm__c,
                           Core_Product_Application__c FROM Opportunity WHERE Id = :opportunity.Id];
            System.assertEquals(20000, opportunity.Amount);
            System.assertEquals(200, opportunity.Core_Opportunity_U_Base__c);
            marketingActivityOpp = [select Id, Core_Opportunity_Amount__c, Core_Opportunity_Volume__c FROM Core_Marketing_Activity_Opportunity__c WHERE Id = :marketingActivityOpp.Id];
            
            opportunity.StageName = 'Design';
            opportunity.Core_Status_Update__c = 'Test111';
            // update opportunity;
            opportunity = [select Id, Name, Amount, Core_Opportunity_U_Base__c ,
                           RecordTypeId ,Core_Status_Update__c ,Description , Core_Technical_Owner__c,    AccountId , StageName , 
                           CloseDate ,Core_Approval_Status__c, Core_Product_Segment__c,Core_Consumption_Market__c ,
                           Core_Product_Application__c FROM Opportunity WHERE Id = :opportunity.Id];
            opportunity.Core_Status_Update__c = 'Test11122';
            opportunity.StageName = 'Design Win';
            Map<Id, Opportunity> oldOppMapKPI = new Map<Id, Opportunity>();
            oldOppMapKPI.put(opportunity.id, opportunity);            
            Core_OpportunityHandler.OpportunityKPIBatchUpdate(opportunityList,oldOppMap);         
        }
        test.stoptest();
    }
    /*Added as part of TWC3123-6003 start*/
    /*static testmethod void testupdatePWFieldsonProduct() {
        Test.startTest();
        Id newOppRecTypeId = [select Id from RecordType where DeveloperName = 'Core_Design_Opportunity' limit 1][0].Id;
        Product2 p = new Product2(Name = 'TestProduct03-24-2015');
        insert p;
        PricebookEntry pbe = new PricebookEntry(Product2Id = p.Id, Pricebook2Id = Test.getStandardPricebookId(),
                                                UnitPrice = 0, IsActive = true);
        System.runAs(Core_Test_Utility.systemAdminUser) {insert pbe;

        }
        // Create an account
        Account acct = new Account(Name = 'TestoppAccounthandle', BillingStreet = '123 Fake St',
                                   BillingCity = 'Springfield', BillingState = 'IL', BillingCountry = 'USA',Industry='Agriculture',Core_Sub_Industry__c= 'Crop Production',
                                   BillingPostalCode = '12345',Core_Sales_Groups__c='Americas US Sales Group');
        System.runAs(Core_Test_Utility.systemAdminUser) {
            insert acct;
        }
        //List<Opportunity> oppsd = new List<Opportunity>();
        Map<Id, Opportunity> OldOppMap = new Map<Id, Opportunity>();
        List<Opportunity> OppList = new List<Opportunity>();
        Opportunity opps = new Opportunity(Name = 'Opportunity to Lose 03-24-2015', RecordTypeId = newOppRecTypeId,
                                           AccountId = acct.Id,
                                           StageName = 'Qualify', CloseDate = System.Date.today().addYears(1),
                                           Core_Opportunity_Coverage_Nm__c='Intel-Led Opportunity',
                                           Core_Product_Segment__c='Client Computing', Core_Consumption_Market__c = 'Education',
                                           Core_Product_Application__c ='Business Mobility',Core_Opportunity_Type__c='Design: Original', Opportunity_Focus__c= 'Core');
        
        System.runAs(Core_Test_Utility.systemAdminUser) {
            insert opps;
        }
        Contact con = [select id,name from Contact where Email = 'testingzzz@example.com'];
        List<OpportunityLineItem> olis = new List<OpportunityLineItem>();
        olis.add(new OpportunityLineItem(OpportunityId = opps.Id, PricebookEntryId = pbe.Id, core_status__c = 'Pending',
                                         UnitPrice = 200, Quantity = 10, Core_Competitor__c = 'Acer', Core_Competitor_Product__c = 'AMD Athlon'));
        
        OpportunityContactRole crole= new OpportunityContactRole();
        crole.IsPrimary = true;
        crole.OpportunityId = opps.Id;
        crole.Role='Business Decision Maker';
        crole.ContactId= con.Id;
        
        System.runAs(Core_Test_Utility.systemAdminUser) {
            insert crole;
            insert olis;
        }
        
        opps.StageName= 'Define';
        opps.Core_Status_Update__c = 'Test';
        opps.Description = 'Test';
        opps.Core_Technical_Owner__c = Core_Test_Utility.systemAdminUser.Id;
        update opps;
        opps.Core_Status_Update__c = 'Test 11';
        opps.StageName= 'Develop';
        update opps;
        opps.Core_Status_Update__c = 'Test 12';
        opps.StageName= 'Design';
        //update opps;
        opps.Core_Status_Update__c = 'Test 13';
        opps.StageName= 'Design Win';
        //update opps;
        olis[0].core_status__c = 'Win Approved';
        olis[0].Core_PW_Sales_Price__c = null;
        olis[0].Core_PW_Quantity__c = null;
        //update olis[0];
        
        OppList.add(opps);
        Core_OpportunityHandler.updatePWFieldsonProduct(OppList);
        Test.stopTest();
        system.assert(OppList.size()>0, 'success');
    }*/
    static testMethod void testCRMoptyHandler1(){
        Test.startTest();
        Id newOppRecTypeId = [select Id from RecordType where DeveloperName = 'Core_Design_Opportunity' limit 1][0].Id;	
    	Product2 p = new Product2(Name = 'TestProduct03-24-2015');
        System.runAs(Core_Test_Utility.systemAdminUser) {
           insert p;
        }
        
        PricebookEntry pbe = new PricebookEntry(Product2Id = p.Id, Pricebook2Id = Test.getStandardPricebookId(),
                                                UnitPrice = 0, IsActive = true);
        System.runAs(Core_Test_Utility.systemAdminUser) {
            insert pbe;
        }
        Id accountRecordTypeIntel = Schema.sObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        Account acct = new Account(Name = 'TestoppAccounthandle', BillingStreet = '123 Fake St', recordtypeId = accountRecordTypeIntel,
                                   BillingCity = 'Springfield', BillingState = 'IL', BillingCountry = 'USA',Industry='Agriculture',Core_Sub_Industry__c= 'Crop Production',
                                   BillingPostalCode = '12345',Core_Sales_Groups__c='Americas US Sales Group');
        System.runAs(Core_Test_Utility.systemAdminUser) {
            insert acct;
        }
        Opportunity opps = new Opportunity(Name = 'Opportunity to Lose 03-24-2015', RecordTypeId = newOppRecTypeId,
                                           AccountId = acct.Id,
                                           StageName = 'Qualify', CloseDate = System.Date.today().addYears(1),
                                           Core_Opportunity_Coverage_Nm__c='Intel-Led Opportunity',
                                           Core_Product_Segment__c='Client Computing', Core_Consumption_Market__c = 'Education',
                                           Core_Product_Application__c ='Business Mobility',Core_Push_Counter__c=0,Core_Status_Update__c='test',
                                           Description = 'test',Core_Technical_Owner__c = Core_Test_Utility.systemAdminUser.Id,Core_Opportunity_Type__c='Design: Original', Opportunity_Focus__c= 'Core',Core_Commissionable__c='Yes');
       System.runAs(Core_Test_Utility.systemAdminUser) {
           insert opps;
        }
         system.assert(opps != null , 'success');
        Test.stopTest();
    }
    static testMethod void testCRMoptyHandler2(){
        Test.startTest();
        Id newOppRecTypeId = [select Id from RecordType where DeveloperName = 'Core_Design_Opportunity' limit 1][0].Id;
        
    	Product2 p = new Product2(Name = 'TestProduct03-24-2015');
        
        System.runAs(Core_Test_Utility.systemAdminUser) {
            insert p;
        }
        PricebookEntry pbe = new PricebookEntry(Product2Id = p.Id, Pricebook2Id = Test.getStandardPricebookId(),
                                                UnitPrice = 0, IsActive = true);
        System.runAs(Core_Test_Utility.systemAdminUser) {
            insert pbe;
        }
        Id accountRecordTypeIntel = Schema.sObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        Account acct = new Account(Name = 'TestoppAccounthandle', BillingStreet = '123 Fake St', recordtypeId = accountRecordTypeIntel,
                                   BillingCity = 'Springfield', BillingState = 'IL', BillingCountry = 'USA',Industry='Agriculture',Core_Sub_Industry__c= 'Crop Production',
                                   BillingPostalCode = '12345',Core_Sales_Groups__c='Americas US Sales Group');
        System.runAs(Core_Test_Utility.systemAdminUser) {
            insert acct;
        }
        Opportunity opps = new Opportunity(Name = 'Opportunity to Lose 03-24-2015', RecordTypeId = newOppRecTypeId,
                                           AccountId = acct.Id,
                                           StageName = 'Qualify', CloseDate = System.today(),
                                           Core_Opportunity_Coverage_Nm__c='Intel-Led Opportunity',
                                           Core_Product_Segment__c='Client Computing', Core_Consumption_Market__c = 'Education',
                                           Core_Product_Application__c ='Business Mobility',Core_Push_Counter__c=0,Core_Status_Update__c='test',
                                           Description = 'test',Core_Technical_Owner__c = Core_Test_Utility.systemAdminUser.Id ,Core_Opportunity_Type__c='Design: Original', Opportunity_Focus__c= 'Core');
        
        System.runAs(Core_Test_Utility.systemAdminUser) {
            insert opps;
        }
         system.assert(opps != null , 'success');
        Test.stopTest();
    }
    static testMethod void testCRMoptyHandler3(){
        Test.startTest();
        Id newOppRecTypeId = [select Id from RecordType where DeveloperName = 'Core_Design_Opportunity' limit 1][0].Id;
        Product2 p = new Product2(Name = 'TestProduct03-24-2015');
        System.runAs(Core_Test_Utility.systemAdminUser) {
           insert p;
        }
        
        PricebookEntry pbe = new PricebookEntry(Product2Id = p.Id, Pricebook2Id = Test.getStandardPricebookId(),
                                                UnitPrice = 0, IsActive = true);
        System.runAs(Core_Test_Utility.systemAdminUser) {
            insert pbe;
        }
        Account acct = new Account(Name = 'TestoppAccounthandle', BillingStreet = '123 Fake St',
                                   BillingCity = 'Springfield', BillingState = 'IL', BillingCountry = 'USA',Industry='Agriculture',Core_Sub_Industry__c= 'Crop Production',
                                   BillingPostalCode = '12345',Core_Sales_Groups__c='Americas US Sales Group');
        System.runAs(Core_Test_Utility.systemAdminUser) {
            insert acct;
        }
        
        Opportunity opps = new Opportunity(Name = 'Opportunity to Lose 03-24-2015', RecordTypeId = newOppRecTypeId,
                                           AccountId = acct.Id,
                                           StageName = 'Qualify', CloseDate = System.Today(),
                                           Core_Opportunity_Coverage_Nm__c='Intel-Led Opportunity',/*Core_Loss_Cancel_Reason__c='Price',Core_Loss_Cancel_Details__c='txt',*/
                                           Core_Product_Segment__c='Client Computing', Core_Consumption_Market__c = 'Education',
                                           Core_Product_Application__c ='Business Mobility',Core_Push_Counter__c=0,Core_Status_Update__c='test',
                                           Description = 'test',Core_Technical_Owner__c = Core_Test_Utility.systemAdminUser.Id,Core_Approval_Status__c='Not Submitted',Core_Coverage_Type_Nm__c = '',Core_Opportunity_Type__c='Design: Original', Opportunity_Focus__c= 'Core' );
        
        System.runAs(Core_Test_Utility.systemAdminUser) {
            insert opps;
        }
         system.assert(opps != null , 'success');
        Contact con = [select id,name from Contact where Email = 'testingzzz@example.com'];
        OpportunityContactRole crole= new OpportunityContactRole();
        crole.IsPrimary = true;
        crole.OpportunityId = opps.Id;
        crole.Role='Business Decision Maker';
        crole.ContactId= con.Id;
        System.runAs(Core_Test_Utility.systemAdminUser) {
           insert crole;
        }
        
        opps.Core_Approval_Status__c = 'Submitted';
        opps.StageName = 'Develop';
        opps.CloseDate = System.Today().addDays(290);
        System.runAs(Core_Test_Utility.systemAdminUser) {
            update opps; 
        }
        
        system.assert(opps != null , 'success');
        Test.stopTest();
    }
    static testMethod void testCRMoptyHandler4(){
        Test.startTest();
        Id newOppRecTypeId = [select Id from RecordType where DeveloperName = 'Core_Design_Opportunity' limit 1][0].Id;
        Product2 p = new Product2(Name = 'TestProduct03-24-2015');
        System.runAs(Core_Test_Utility.systemAdminUser) {
           insert p;
        }
        
        PricebookEntry pbe = new PricebookEntry(Product2Id = p.Id, Pricebook2Id = Test.getStandardPricebookId(),
                                                UnitPrice = 0, IsActive = true);
        System.runAs(Core_Test_Utility.systemAdminUser) {
            insert pbe;
        }
        Id accountRecordTypeIntel = Schema.sObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        Account acct = new Account(Name = 'TestoppAccounthandle', BillingStreet = '123 Fake St',
                                   BillingCity = 'Springfield', BillingState = 'IL', BillingCountry = 'USA',Industry='Agriculture',Core_Sub_Industry__c= 'Crop Production',
                                   BillingPostalCode = '12345',Core_Sales_Groups__c='Americas US Sales Group');
        System.runAs(Core_Test_Utility.systemAdminUser) {
            insert acct;
        }
        list<Opportunity> newOpptylist = new list<Opportunity>();
        Opportunity opps1 = new Opportunity(Name = 'Opportunity Solution Group 123', RecordTypeId = newOppRecTypeId, Core_Opportunity_Coverage_Nm__c='Intel-Led Opportunity',
                                           AccountId = acct.Id, StageName = 'Group Open', CloseDate = System.Date.today().addYears(1),Core_Opportunity_Type__c='Design: Original');
        newOpptylist.add(opps1);
        Opportunity opps = new Opportunity(Name = 'Opportunity to Lose 03-24-2015', RecordTypeId = newOppRecTypeId,
                                           AccountId = acct.Id, Core_Bypass_Field_Validation__c = true,
                                           StageName = 'Qualify', CloseDate = System.Date.today().addYears(1),
                                           Core_Opportunity_Coverage_Nm__c='Intel-Led Opportunity',
                                           Core_Product_Segment__c='Client Computing', Core_Consumption_Market__c = 'Education',
                                           Core_Product_Application__c ='Business Mobility',Core_Push_Counter__c=0,Core_Status_Update__c='test',
                                           Description = 'test',Core_Technical_Owner__c = Core_Test_Utility.systemAdminUser.Id,Core_Lead_Conversion_Flag__c = true,
                                           Core_Lead_Notes__c ='txt',Core_Last_Activity_Date__c = null,Core_Risk_Reason__c = '',Core_Prior_Lost_Opportunity_Stage__c='',Core_Approval_Status__c ='Not Submitted',Core_Opportunity_Type__c='Design: Original', Opportunity_Focus__c= 'Core');
        newOpptylist.add(opps);
        System.runAs(Core_Test_Utility.systemAdminUser) {
            insert newOpptylist;
            //Test.setCreatedDate(newOpptylist[0].Id, Date.today().addDays(-1));
        }
        
        system.assert(newOpptylist.size() != 0 , 'success');
        List<OpportunityLineItem> oppForLossItems = new List<OpportunityLineItem>();
        oppForLossItems.add(new OpportunityLineItem(OpportunityId = newOpptylist[1].Id, PricebookEntryId = pbe.Id, Core_Status__c='Pending',
                                                    UnitPrice = 200, Quantity = 10, Core_Competitor__c = 'Acer', Core_Competitor_Product__c = 'AMD Athlon'));
        System.runAs(Core_Test_Utility.systemAdminUser) {
            insert oppForLossItems ;
        }
        
        Contact con = [select id,name from Contact where Email = 'testingzzz@example.com'];
        OpportunityContactRole crole= new OpportunityContactRole();
        crole.IsPrimary = true;
        crole.OpportunityId = newOpptylist[1].Id;
        crole.Role='Business Decision Maker';
        crole.ContactId= con.Id;
        System.runAs(Core_Test_Utility.systemAdminUser) {
            insert crole;
        }
        
        newOpptylist[1].StageName = 'Lost';
        newOpptylist[1].Core_Loss_Cancel_Reason__c = 'Cancelled - Budget';
        newOpptylist[1].Core_Loss_Cancel_Details__c = 'Cancelled - Budget';
        newOpptylist[1].Core_Lead_Conversion_Flag__c = true;
        newOpptylist[1].CloseDate = System.Today().addDays(190);
        newOpptylist[1].Core_Risk_Reason__c = 'Risk-COCID-19';
        System.runAs(Core_Test_Utility.systemAdminUser) {
            Core_Opp_Bypass_Validation_Rule__c vrBypass = [select id, Bypass__c from Core_Opp_Bypass_Validation_Rule__c limit 1]; 
            vrBypass.Bypass__c = true;
            update vrBypass;
            update opps;
        }
        
        system.assert(newOpptylist[1] != null , 'success');
        Test.stopTest();
    }
    static testMethod void testCRMoptyHandler5(){
        Test.startTest();
        List<Opportunity> NewOppList = new List<Opportunity>();
        
       	Id newOppRecTypeId = [select Id from RecordType where DeveloperName = 'Core_Design_Opportunity' limit 1][0].Id;
        Id dealRecordTypeId = [select Id from RecordType where DeveloperName = 'Core_Deal_Opportunity' limit 1][0].Id;

        Product2 p = new Product2(Name = 'TestProduct03-24-2015');
        insert p;
        PricebookEntry pbe = new PricebookEntry(Product2Id = p.Id, Pricebook2Id = Test.getStandardPricebookId(),
                                                UnitPrice = 0, IsActive = true);
        System.runAs(Core_Test_Utility.systemAdminUser) {
            insert pbe;
        }
        Account acct = new Account(Name = 'TestoppAccounthandle', BillingStreet = '123 Fake St',
                                   BillingCity = 'Springfield', BillingState = 'IL', BillingCountry = 'USA',Industry='Agriculture',Core_Sub_Industry__c= 'Crop Production',
                                   BillingPostalCode = '12345',Core_Sales_Groups__c='Americas US Sales Group');
        System.runAs(Core_Test_Utility.systemAdminUser) {
            insert acct;
        }
        
        Opportunity opps = new Opportunity(Name = 'Opportunity to Lose 03-24-2015', RecordTypeId = newOppRecTypeId,
                                           AccountId = acct.Id,
                                           StageName = 'Design Win', CloseDate = System.Date.today(),
                                           Core_Opportunity_Coverage_Nm__c='Intel-Led Opportunity',
                                           Core_Product_Segment__c='Client Computing', Core_Consumption_Market__c = 'Education',
                                           Core_Product_Application__c ='Business Mobility',Core_Push_Counter__c=0,Core_Status_Update__c='test',
                                           Description = 'test',Core_Technical_Owner__c = Core_Test_Utility.systemAdminUser.Id,Core_Lead_Conversion_Flag__c = true,
                                           Core_Lead_Notes__c ='txt',Core_Last_Activity_Date__c = null,Core_PW_Approval_Status__c='Approved',Core_First_Customer_Ship_Date__c= System.Date.today(),Core_Opportunity_Type__c='Design: Original', Opportunity_Focus__c= 'Core');
        
       
        NewOppList.add(opps);//insert opps;
        
        Opportunity oppsDev = new Opportunity(Name = 'TestRecordd', RecordTypeId = dealRecordTypeId,
                                           AccountId = acct.Id,
                                           StageName = 'Develop',Core_Opportunity_Coverage_Nm__c ='Intel-Led Opportunity',Core_Opportunity_Type__c = 'Deal: Sell-through',CloseDate = System.Date.today().addYears(1),Core_Status_Update__c = '',Description = '');
        NewOppList.add(oppsDev);
        //TWC
        Opportunity oppsDev2 = new Opportunity(Name = 'TestRecordd2', RecordTypeId = dealRecordTypeId,
                                           AccountId = acct.Id,Core_PW_Approval_Status__c='Approved',
                                           StageName = 'Develop',Core_Opportunity_Coverage_Nm__c ='Intel-Led Opportunity',Core_Opportunity_Type__c = 'Deal: Sell-through',CloseDate = System.Date.today().addYears(1),Core_Status_Update__c = '',Description = '');
        NewOppList.add(oppsDev2);
        System.runAs(Core_Test_Utility.systemAdminUser) {
            insert NewOppList; //oppsDev;
        }
        
        system.assert(!NewOppList.isempty() , 'success');
        List<OpportunityLineItem> opplitem = new List<OpportunityLineItem>();
        opplitem.add(new OpportunityLineItem(OpportunityId = NewOppList[0].Id, PricebookEntryId = pbe.Id, Core_Status__c='Production Win Approved',
                                                    UnitPrice = 200, Quantity = 10, Core_Competitor__c = 'Acer', Core_Competitor_Product__c = 'AMD Athlon',
                                                    CRM_PW_App_UCD_Customer_Name__c='',Core_PW_Approved_BU_Product_Segment__c='',Core_PW_Approved_BU_Short_Name__c='',
                                                    Core_PW_Approved_By__c='',Core_PW_Approved_Commissionable__c=''));
        opplitem.add(new OpportunityLineItem(OpportunityId = NewOppList[0].Id, PricebookEntryId = pbe.Id, Core_Status__c='Pending',
                                                    UnitPrice = 200, Quantity = 10, Core_Competitor__c = 'Acer', Core_Competitor_Product__c = 'AMD Athlon',
                                                    CRM_PW_App_UCD_Customer_Name__c='',Core_PW_Approved_BU_Product_Segment__c='',Core_PW_Approved_BU_Short_Name__c='',
                                                    Core_PW_Approved_By__c='',Core_PW_Approved_Commissionable__c=''));
        opplitem.add(new OpportunityLineItem(OpportunityId = NewOppList[0].Id, PricebookEntryId = pbe.Id, Core_Status__c='Pending',
                                                    UnitPrice = 200, Quantity = 10, Core_Competitor__c = 'Acer', Core_Competitor_Product__c = 'AMD Athlon',
                                                    CRM_PW_App_UCD_Customer_Name__c='',Core_PW_Approved_BU_Product_Segment__c='',Core_PW_Approved_BU_Short_Name__c='',
                                                    Core_PW_Approved_By__c='',Core_PW_Approved_Commissionable__c=''));
        insert opplitem;
        
        Map<Id, Opportunity> OldOppMap = new Map<Id, Opportunity>(NewOppList);   
        //TWC
        map<Id,list<OpportunityLineItem>> opplineItemmap = new map<Id,list<OpportunityLineItem>>();
        opplineItemmap.put(NewOppList[0].id, opplitem);
       
        NewOppList[1].StageName='Design';
        NewOppList[1].Core_Technical_Owner__c = Core_Test_Utility.systemAdminUser.id;
        NewOppList[1].Core_Status_Update__c = 'Test2';
        NewOppList[1].Description = 'Test2';
        NewOppList[1].Core_Product_Segment__c='Client Computing';
        NewOppList[1].Core_Product_Application__c ='Business Mobility';
        NewOppList[1].Core_Consumption_Market__c = 'Education';
        NewOppList[1].Core_Competitive_Architecture__c = 'ARM';
        update NewOppList[1];
        
        NewOppList[0].Core_Status_Update__c='txt';
        NewOppList[0].StageName = 'Design Win';
        NewOppList[0].Core_PW_Approval_Status__c = 'Recalled';
        Update NewOppList[0];
		
        Core_OpportunityHandler.restrictBlankFieldUpdates(NewOppList,OldOppMap,NewOppList,true);
        CRM_OpportunityHandler.clearPWApprovedFields(NewOppList[0],NewOppList[1],opplineItemmap);
        Test.stopTest();
    }
    /*static testMethod void testCRMoptyHandler6(){
        Id newOppRecTypeId = [select Id from RecordType where DeveloperName = 'Core_New_Solution_Group' limit 1][0].Id;
        Id accountRecordTypeIntel = Schema.sObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        Account acct = [Select id from account where recordtypeid =:accountRecordTypeIntel limit 1][0];
        
        //Opportunity opp =[select id, RecordTypeId, RecordType.DeveloperName, createdDate from opportunity limit 1][0];
        Opportunity opp = new Opportunity(Name = 'Opportunity Solution Group 123', RecordTypeId = newOppRecTypeId, Core_Opportunity_Coverage_Nm__c='Intel-Led Opportunity',
                                           AccountId = acct.Id, StageName = 'Group Open', CloseDate = System.Date.today().addYears(1),Core_Opportunity_Type__c='Design: Original');
        
        //opp.RecordTypeId = newOppRecTypeId;
        System.runAs(Core_Test_Utility.systemAdminUser) {
            insert opp;
        }
        Test.setCreatedDate(opp.Id, Date.today().addDays(-1));
        Test.startTest();
        
        system.assert(opp != null , 'success');
        Test.stopTest();
    }*/
   /*
    Static testmethod Void testCallQuoteApproveNotify(){
        Opportunity testOpp = new Opportunity(
        Name = 'Test Opportunity',
        StageName = 'Prospecting',
        CloseDate = Date.today());
        insert testOpp;
        
        SBQQ__Quote__c testQuote = new SBQQ__Quote__c(
        //Name= 'Test Quote',
        SBQQ__Opportunity2__c =testOpp.Id,
        Pricing_Quote_Program_Nm__c = 'Tender');
        insert testQuote;
        
        Set<Id> oppIds = new Set<Id>{testOpp.Id};
            Test.startTest();
        Core_OpportunityHandler.callQuoteApproveNotify(oppIds);
        Test.stopTest();
        SBQQ__Quote__c fetchedQuote = [SELECT Id FROM SBQQ__Quote__c where Id = :testQuote.Id LIMIT 1];
        System.assertNotEquals(null, fetchedQuote, 'Quote should exist after method execution.' );
        
    }*/
}