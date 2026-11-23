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
public class Core_OpportunityHandler_Test2 {
    
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
        enableTriggers();
        
        List <Account> AccListList = new List <Account> ();
        List<Opportunity> testOpps=new List<Opportunity>();
        
       Account acct = new Account(Name = 'TestoppAccounthandle', BillingStreet = '123 Fake St',
                                   BillingCity = 'Springfield', BillingState = 'IL', BillingCountry = 'USA',Industry='Agriculture',Core_Sub_Industry__c= 'Crop Production',
                                   BillingPostalCode = '12345',/* Core_CIM_ID__c = '8675309',*/Core_Sales_Groups__c=Core_CRM_Utility.getSalesGroupAPI());
        System.runAs(Core_Test_Utility.systemAdminUser) {
            insert acct;
        }

        
        Id DealOppRecTypeId = [select Id from RecordType where DeveloperName = 'Core_Deal_Opportunity' limit 1][0].Id;
        Opportunity oppty = new Opportunity(Name = 'TestClass PCC Opportunity', RecordTypeId = DealOppRecTypeId,
                                            AccountId = acct.Id, OwnerId= UserInfo.getUserId(),Core_Coverage_Type_Nm__c = 'Deal Registration',
                                            StageName = 'Qualify', CloseDate = System.Date.today().addYears(1), Core_Opportunity_Coverage_Nm__c ='Partner-Led Opportunity');
        insert oppty;
        
        

    }
    //static testMethod void testOpportunityHandler() {
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
        
		lstTriggerExecution.add(OpportunityStageExitValidation);
       
        
         insert lstTriggerExecution;
             
     
       
    }
    
     static testMethod void testStageUpdate() {
        
      
        Id newOppRecTypeId = [select Id from RecordType where DeveloperName = 'Core_Design_Opportunity' limit 1][0].Id;
        
        // Create a product/price book entry to use on the opportunities
        Product2 p = new Product2(Name = 'Test Product 03-24-2015');
        insert p;
        PricebookEntry pbe = new PricebookEntry(Product2Id = p.Id, Pricebook2Id = Test.getStandardPricebookId(),
                                                UnitPrice = 0, IsActive = true);
        System.runAs(Core_Test_Utility.systemAdminUser) {
            insert pbe;
        }
        
        // Create an account
        Account acct = new Account(Name = 'TestoppAccounthandle', BillingStreet = '123 Fake St',
                                   BillingCity = 'Springfield', BillingState = 'IL', BillingCountry = 'USA',Industry='Agriculture',Core_Sub_Industry__c= 'Crop Production',
                                   BillingPostalCode = '12345',/* Core_CIM_ID__c = '8675309',*/Core_Sales_Groups__c=Core_CRM_Utility.getSalesGroupAPI());
        System.runAs(Core_Test_Utility.systemAdminUser) {
            insert acct;
        }
        
        //-----------------------------------------------------------------------------------
        // Create an opportunity to test a loss, with multiple line items in various stages
        
        Opportunity oppForLoss = new Opportunity(Name = 'Opportunity to Lose 03-24-2015', RecordTypeId = newOppRecTypeId,
                                                 AccountId = acct.Id,Opportunity_Focus__c='',
                                                 StageName = 'Qualifying', CloseDate = System.Date.today().addYears(1));
        System.runAs(Core_Test_Utility.systemAdminUser) {
            insert oppForLoss;
        }
      
        
        // Since a workflow rule ensures all new line items are Pending, we need to first insert, then update
        List<OpportunityLineItem> oppForLossItems = new List<OpportunityLineItem>();
        oppForLossItems.add(new OpportunityLineItem(OpportunityId = oppForLoss.Id, PricebookEntryId = pbe.Id,
                                                    UnitPrice = 200, Quantity = 10, Core_Competitor__c = 'Acer', Core_Competitor_Product__c = 'AMD Athlon'));
        oppForLossItems.add(new OpportunityLineItem(OpportunityId = oppForLoss.Id, PricebookEntryId = pbe.Id,
                                                    UnitPrice = 200, Quantity = 10, Core_Competitor__c = 'Acer', Core_Competitor_Product__c = 'AMD Athlon'));
        oppForLossItems.add(new OpportunityLineItem(OpportunityId = oppForLoss.Id, PricebookEntryId = pbe.Id,
                                                    UnitPrice = 200, Quantity = 10, Core_Competitor__c = 'Acer', Core_Competitor_Product__c = 'AMD Athlon'));
        oppForLossItems.add(new OpportunityLineItem(OpportunityId = oppForLoss.Id, PricebookEntryId = pbe.Id,
                                                    UnitPrice = 200, Quantity = 10, Core_Competitor__c = 'Acer', Core_Competitor_Product__c = 'AMD Athlon'));
        oppForLossItems.add(new OpportunityLineItem(OpportunityId = oppForLoss.Id, PricebookEntryId = pbe.Id,
                                                    UnitPrice = 200, Quantity = 10, Core_Competitor__c = 'Acer', Core_Competitor_Product__c = 'AMD Athlon'));
        oppForLossItems.add(new OpportunityLineItem(OpportunityId = oppForLoss.Id, PricebookEntryId = pbe.Id,
                                                    UnitPrice = 200, Quantity = 10, Core_Competitor__c = 'Acer', Core_Competitor_Product__c = 'AMD Athlon'));
        oppForLossItems.add(new OpportunityLineItem(OpportunityId = oppForLoss.Id, PricebookEntryId = pbe.Id,
                                                    UnitPrice = 200, Quantity = 10, Core_Competitor__c = 'Acer', Core_Competitor_Product__c = 'AMD Athlon'));
        System.runAs(Core_Test_Utility.systemAdminUser) {
            insert oppForLossItems;
        }
        
        oppForLossItems[0].Core_Status__c = 'Pending';
        oppForLossItems[1].Core_Status__c = 'Lost';
        oppForLossItems[1].Core_Loss_Cancel_Reason__c = 'Lost already';
        oppForLossItems[2].Core_Status__c = 'Cancelled';
        oppForLossItems[2].Core_Loss_Cancel_Reason__c = 'Cancelled already';
        oppForLossItems[3].Core_Status__c = 'Pending';
        oppForLossItems[4].Core_Status__c = 'Won';
        oppForLossItems[5].Core_Status__c = 'Deleted';
        oppForLossItems[6].Core_Status__c = 'Pending';
        
        System.runAs(Core_Test_Utility.systemAdminUser) {        
            update oppForLossItems;
        }
        
        //vineetha
        oppForLoss.StageName='Lost';
        update oppForLoss;
        //-----------------------------------------------------------------------------------
        // Create an opportunity to test a cancel, with multiple line items in various stages
        
        Opportunity oppForCancel = new Opportunity(Name = 'Opportunity to Cancel 03-24-2015', RecordTypeId = newOppRecTypeId,
                                                   AccountId = acct.Id,Opportunity_Focus__c='',
                                                   StageName = 'Qualifying', CloseDate = System.Date.today().addYears(1));
        System.runAs(Core_Test_Utility.systemAdminUser) {
            insert oppForCancel;
        }
        
        // Since a workflow rule ensures all new line items are Pending, we need to first insert, then update
        List<OpportunityLineItem> oppForCancelItems = new List<OpportunityLineItem>();
        oppForCancelItems.add(new OpportunityLineItem(OpportunityId = oppForCancel.Id, PricebookEntryId = pbe.Id,
                                                      UnitPrice = 200, Quantity = 1, Core_Competitor__c = 'Acer', Core_Competitor_Product__c = 'AMD Athlon'));
        oppForCancelItems.add(new OpportunityLineItem(OpportunityId = oppForCancel.Id, PricebookEntryId = pbe.Id,
                                                      UnitPrice = 200, Quantity = 2, Core_Competitor__c = 'Acer', Core_Competitor_Product__c = 'AMD Athlon'));
        oppForCancelItems.add(new OpportunityLineItem(OpportunityId = oppForCancel.Id, PricebookEntryId = pbe.Id,
                                                      UnitPrice = 200, Quantity = 3, Core_Competitor__c = 'Acer', Core_Competitor_Product__c = 'AMD Athlon'));
        oppForCancelItems.add(new OpportunityLineItem(OpportunityId = oppForCancel.Id, PricebookEntryId = pbe.Id,
                                                      UnitPrice = 200, Quantity = 4, Core_Competitor__c = 'Acer', Core_Competitor_Product__c = 'AMD Athlon'));
        oppForCancelItems.add(new OpportunityLineItem(OpportunityId = oppForCancel.Id, PricebookEntryId = pbe.Id,
                                                      UnitPrice = 200, Quantity = 5, Core_Competitor__c = 'Acer', Core_Competitor_Product__c = 'AMD Athlon'));
        oppForCancelItems.add(new OpportunityLineItem(OpportunityId = oppForCancel.Id, PricebookEntryId = pbe.Id,
                                                      UnitPrice = 200, Quantity = 6, Core_Competitor__c = 'Acer', Core_Competitor_Product__c = 'AMD Athlon'));
        oppForCancelItems.add(new OpportunityLineItem(OpportunityId = oppForCancel.Id, PricebookEntryId = pbe.Id,
                                                      UnitPrice = 200, Quantity = 7, Core_Competitor__c = 'Acer', Core_Competitor_Product__c = 'AMD Athlon'));
        test.starttest();
        System.runAs(Core_Test_Utility.systemAdminUser) {
            insert oppForCancelItems;
        }
        
        oppForCancelItems[0].Core_Status__c = 'Pending';
        oppForCancelItems[1].Core_Status__c = 'Lost';
        oppForCancelItems[1].Core_Loss_Cancel_Reason__c = 'Lost already';
        oppForCancelItems[2].Core_Status__c = 'Cancelled';
        oppForCancelItems[2].Core_Loss_Cancel_Reason__c = 'Cancelled already';
        oppForCancelItems[3].Core_Status__c = 'Pending';
        oppForCancelItems[4].Core_Status__c = 'Won';
        oppForCancelItems[5].Core_Status__c = 'Deleted';
        oppForCancelItems[6].Core_Status__c = 'Pending';
        
        System.runAs(Core_Test_Utility.systemAdminUser) {
            update oppForCancelItems;
        }
        
        // Flip one opportunity to Lost and run some checks
        oppForLoss.StageName = 'Lost';
        oppForLoss.Core_Loss_Cancel_Reason__c = 'Lost - Price';
        oppForLoss.Core_Loss_Cancel_Details__c = 'Lost because our price was too high...';
        update oppForLoss;
        test.stoptest();
        oppForLossItems = [select Id, Core_Status__c, Core_Loss_Cancel_Reason__c
                           from OpportunityLineItem where OpportunityId = :oppForLoss.Id order by Quantity];

        // Flip the other opportunity to Cancelled and run some checks
        oppForCancel.StageName = 'Cancelled';
        oppForCancel.Core_Loss_Cancel_Reason__c = 'Cancelled - Budget';
       // update oppForCancel;
        oppForCancelItems = [select Id, Core_Status__c, Core_Loss_Cancel_Reason__c
                             from OpportunityLineItem where OpportunityId = :oppForCancel.Id order by Quantity];
        System.debug('opp list'+oppForCancelItems);
        //System.assertEquals('Cancelled',oppForCancelItems[0].Core_Status__c);
        }
    
    
    
}