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
public class Core_OpportunityHandler_Test {

    static final integer OPP_COUNT = 10;
    
    /*
    * Method name  : testOpportunityHandler
    * Description  : Method to setup test data ( Opportunity)
    * Return Type  : None
    * Parameter    : None
    */
    
    static testMethod void testOpportunityHandler() {

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

        Core_Trigger_Executions__c opportunityOppFactDelete = new Core_Trigger_Executions__c();
        opportunityOppFactDelete.name = 'opportunityOppFactDelete';
        opportunityOppFactDelete.Core_Object__c = 'Opportunity';
        opportunityOppFactDelete.Core_Active__c = TRUE;
        opportunityOppFactDelete.Core_Trigger_Events__c = 'After insert';
        opportunityOppFactDelete.Core_Description__c = 'This is test description';
        opportunityOppFactDelete.Core_Class_Name__c = 'Test Class';

        lstTriggerExecution.add(opportunityOppFactDelete);

        insert lstTriggerExecution;

        List < Opportunity > lstOpp = new List < Opportunity > {};
        lstOpp = Core_Test_Utility.Core_Opportunity(OPP_COUNT);

        lstOpp.get(OPP_COUNT - 1).name = 'Test99';

        List < User > lstUser = new List < User > {};
        lstUser = [SELECT Name, id from User Where isActive = TRUE];

        for (Opportunity sobjOpp: lstOpp) {

            sobjOpp.Core_Technical_Owner__c = lstUser[0].id;

        }
        insert lstOpp;



        for (Opportunity sobjOpp: lstOpp) {

            sobjOpp.Core_Technical_Owner__c = lstUser[1].id;

        }
        Core_OpportunityHandler.bTechnicalOwnerUpdate = true;
        update lstOpp;

        //delete lstOpp.get(OPP_COUNT);
        System.debug('-----');
    }
    
    static testMethod void testStageUpdate() {

        // Ensure our trigger code executes
        Core_Trigger_Executions__c oppStageUpdate = new Core_Trigger_Executions__c();
        oppStageUpdate.Name = 'opportunityStageUpdate';
        oppStageUpdate.Core_Object__c = 'Opportunity';
        oppStageUpdate.Core_Active__c = TRUE;
        oppStageUpdate.Core_Trigger_Events__c = 'after update';
        oppStageUpdate.Core_Description__c = 'blahblahblah';
        oppStageUpdate.Core_Class_Name__c = 'Core_OpportunityHandler';
        
        System.runAs(Core_Test_Utility.systemAdminUser) {
            insert oppStageUpdate;
        }
        
        Id newOppRecTypeId = [select Id from RecordType where DeveloperName = 'Core_New_Opportunity' limit 1][0].Id;
        
        // Create a product/price book entry to use on the opportunities
        Product2 p = new Product2(Name = 'Test Product 03-24-2015');
        insert p;
        PricebookEntry pbe = new PricebookEntry(Product2Id = p.Id, Pricebook2Id = Test.getStandardPricebookId(),
                                                UnitPrice = 0, IsActive = true);
        System.runAs(Core_Test_Utility.systemAdminUser) {
            insert pbe;
        }
        
        // Create an account
        Account acct = new Account(Name = 'Test Account 03-25-2015', BillingStreet = '123 Fake St',
                                   BillingCity = 'Springfield', BillingState = 'IL', BillingCountry = 'USA',
                                   BillingPostalCode = '12345', Core_CIM_ID__c = '8675309');
        System.runAs(Core_Test_Utility.systemAdminUser) {
            insert acct;
        }
            
        //-----------------------------------------------------------------------------------
        // Create an opportunity to test a loss, with multiple line items in various stages
        
        Opportunity oppForLoss = new Opportunity(Name = 'Opportunity to Lose 03-24-2015', RecordTypeId = newOppRecTypeId,
                                                 AccountId = acct.Id,
                                                 StageName = 'Qualifying', CloseDate = System.Date.today().addYears(1));
        System.runAs(Core_Test_Utility.systemAdminUser) {
            insert oppForLoss;
        }
        
        // Since a workflow rule ensures all new line items are Pending, we need to first insert, then update
        List<OpportunityLineItem> oppForLossItems = new List<OpportunityLineItem>();
        oppForLossItems.add(new OpportunityLineItem(OpportunityId = oppForLoss.Id, PricebookEntryId = pbe.Id,
                                                    UnitPrice = 0, Quantity = 10));
        oppForLossItems.add(new OpportunityLineItem(OpportunityId = oppForLoss.Id, PricebookEntryId = pbe.Id,
                                                    UnitPrice = 0, Quantity = 10));
        oppForLossItems.add(new OpportunityLineItem(OpportunityId = oppForLoss.Id, PricebookEntryId = pbe.Id,
                                                    UnitPrice = 0, Quantity = 10));
        oppForLossItems.add(new OpportunityLineItem(OpportunityId = oppForLoss.Id, PricebookEntryId = pbe.Id,
                                                    UnitPrice = 0, Quantity = 10));
        oppForLossItems.add(new OpportunityLineItem(OpportunityId = oppForLoss.Id, PricebookEntryId = pbe.Id,
                                                    UnitPrice = 0, Quantity = 10));
        oppForLossItems.add(new OpportunityLineItem(OpportunityId = oppForLoss.Id, PricebookEntryId = pbe.Id,
                                                    UnitPrice = 0, Quantity = 10));
        oppForLossItems.add(new OpportunityLineItem(OpportunityId = oppForLoss.Id, PricebookEntryId = pbe.Id,
                                                    UnitPrice = 0, Quantity = 10));
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
        oppForLossItems[6].Core_Status__c = 'On Hold';
        
        System.runAs(Core_Test_Utility.systemAdminUser) {        
            update oppForLossItems;
        }
        
        //-----------------------------------------------------------------------------------
        // Create an opportunity to test a cancel, with multiple line items in various stages
        
        Opportunity oppForCancel = new Opportunity(Name = 'Opportunity to Cancel 03-24-2015', RecordTypeId = newOppRecTypeId,
                                                   AccountId = acct.Id,
                                                   StageName = 'Qualifying', CloseDate = System.Date.today().addYears(1));
        System.runAs(Core_Test_Utility.systemAdminUser) {
            insert oppForCancel;
        }
        
        // Since a workflow rule ensures all new line items are Pending, we need to first insert, then update
        List<OpportunityLineItem> oppForCancelItems = new List<OpportunityLineItem>();
        oppForCancelItems.add(new OpportunityLineItem(OpportunityId = oppForCancel.Id, PricebookEntryId = pbe.Id,
                                                      UnitPrice = 0, Quantity = 1));
        oppForCancelItems.add(new OpportunityLineItem(OpportunityId = oppForCancel.Id, PricebookEntryId = pbe.Id,
                                                      UnitPrice = 0, Quantity = 2));
        oppForCancelItems.add(new OpportunityLineItem(OpportunityId = oppForCancel.Id, PricebookEntryId = pbe.Id,
                                                      UnitPrice = 0, Quantity = 3));
        oppForCancelItems.add(new OpportunityLineItem(OpportunityId = oppForCancel.Id, PricebookEntryId = pbe.Id,
                                                      UnitPrice = 0, Quantity = 4));
        oppForCancelItems.add(new OpportunityLineItem(OpportunityId = oppForCancel.Id, PricebookEntryId = pbe.Id,
                                                      UnitPrice = 0, Quantity = 5));
        oppForCancelItems.add(new OpportunityLineItem(OpportunityId = oppForCancel.Id, PricebookEntryId = pbe.Id,
                                                      UnitPrice = 0, Quantity = 6));
        oppForCancelItems.add(new OpportunityLineItem(OpportunityId = oppForCancel.Id, PricebookEntryId = pbe.Id,
                                                      UnitPrice = 0, Quantity = 7));
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
        oppForCancelItems[6].Core_Status__c = 'On Hold';

        System.runAs(Core_Test_Utility.systemAdminUser) {
            update oppForCancelItems;
        }
        
        // Flip one opportunity to Lost and run some checks
        oppForLoss.StageName = 'Lost';
        oppForLoss.Core_Loss_Cancel_Reason__c = 'Lost - Price';
        oppForLoss.Core_Loss_Cancel_Details__c = 'Lost because our price was too high...';
        update oppForLoss;
        oppForLossItems = [select Id, Core_Status__c, Core_Loss_Cancel_Reason__c
                           from OpportunityLineItem where OpportunityId = :oppForLoss.Id order by Quantity];
        
        System.assertEquals('Lost',              oppForLossItems[0].Core_Status__c);
        System.assertEquals('Opportunity Lost',  oppForLossItems[0].Core_Loss_Cancel_Reason__c);
        System.assertEquals('Lost',              oppForLossItems[1].Core_Status__c);
        System.assertEquals('Lost already',      oppForLossItems[1].Core_Loss_Cancel_Reason__c);
        System.assertEquals('Cancelled',         oppForLossItems[2].Core_Status__c);
        System.assertEquals('Cancelled already', oppForLossItems[2].Core_Loss_Cancel_Reason__c);
        System.assertEquals('Lost',              oppForLossItems[3].Core_Status__c);
        System.assertEquals('Opportunity Lost',  oppForLossItems[3].Core_Loss_Cancel_Reason__c);
        System.assertEquals('Won',               oppForLossItems[4].Core_Status__c);
        System.assertEquals('Deleted',           oppForLossItems[5].Core_Status__c);
        System.assertEquals('Lost',              oppForLossItems[6].Core_Status__c);
        System.assertEquals('Opportunity Lost',  oppForLossItems[6].Core_Loss_Cancel_Reason__c);
        
        // Flip the other opportunity to Cancelled and run some checks
        oppForCancel.StageName = 'Cancelled';
        oppForCancel.Core_Loss_Cancel_Reason__c = 'Cancelled - Budget';
        update oppForCancel;
        oppForCancelItems = [select Id, Core_Status__c, Core_Loss_Cancel_Reason__c
                             from OpportunityLineItem where OpportunityId = :oppForCancel.Id order by Quantity];
        
        System.assertEquals('Cancelled',          oppForCancelItems[0].Core_Status__c);
        System.assertEquals('Opportunity Cancelled', oppForCancelItems[0].Core_Loss_Cancel_Reason__c);
        System.assertEquals('Lost',               oppForCancelItems[1].Core_Status__c);
        System.assertEquals('Lost already',       oppForCancelItems[1].Core_Loss_Cancel_Reason__c);
        System.assertEquals('Cancelled',          oppForCancelItems[2].Core_Status__c);
        System.assertEquals('Cancelled already',  oppForCancelItems[2].Core_Loss_Cancel_Reason__c);
        System.assertEquals('Cancelled',          oppForCancelItems[3].Core_Status__c);
        System.assertEquals('Opportunity Cancelled', oppForCancelItems[3].Core_Loss_Cancel_Reason__c);
        System.assertEquals('Won',                oppForCancelItems[4].Core_Status__c);
        System.assertEquals('Deleted',            oppForCancelItems[5].Core_Status__c);
        System.assertEquals('Cancelled',          oppForCancelItems[6].Core_Status__c);
        System.assertEquals('Opportunity Cancelled', oppForCancelItems[6].Core_Loss_Cancel_Reason__c);
    }
    
    
    /*
    * Method name  : UpdateActivityLineItems_Test
    * Description  : Method to test UpdateActivityLineItems functionality
    * Return Type  : void
    * Parameter    : None
    */
    
    static testMethod void UpdateActivityLineItems_Test() {
        
        System.runAs(Core_Test_Utility.systemAdminUser) {
            List<Core_Trigger_Executions__c> triggExecList = new List<Core_Trigger_Executions__c>();
            // Create the configuration item so the Update trigger on Opportunity gets executed
            //Core_Trigger_Executions__c triggerExec = new Core_Trigger_Executions__c( 
            //    Name='updateActivityLineItems', Core_Class_Name__c='Core_OpportunityHandler', Core_Object__c='Opportunity_Partner', 
            //    Core_Trigger_Events__c='After Update', Core_Active__c=true, Core_Description__c = 'blah blah');
            triggExecList.add(new Core_Trigger_Executions__c(Name='updateActivityLineItems', Core_Class_Name__c='Core_OpportunityHandler', Core_Object__c='Opportunity_Partner', Core_Trigger_Events__c='After Update', Core_Active__c=true, Core_Description__c = 'blah blah'));
            
            triggExecList.add(new Core_Trigger_Executions__c(Name='opportunityTechnicalOwnerUpdate', Core_Class_Name__c='Core_OpportunityHandler', Core_Object__c='Opportunity', Core_Trigger_Events__c='After Insert After Update', Core_Active__c=true, Core_Description__c = 'blah blah'));
            insert triggExecList;
        
            // Create a new account        
            Account acct = new Account(Name = 'Test Account1', BillingStreet = '123 Fake St',
                                       BillingCity = 'Springfield', BillingState = 'IL', BillingCountry = 'USA',
                                       BillingPostalCode = '12345', Core_CIM_ID__c = '8675309');
            insert acct;

            // Create a new product
            Product2 product = new Product2(Name = 'Test Product1');
            insert product;
        
            // Create a new price book entry using the product created above
            PricebookEntry pbe = new PricebookEntry(Product2Id = product.Id, Pricebook2Id = Test.getStandardPricebookId(),
                                                UnitPrice = 100, IsActive = true);
            insert pbe;
        
            // Create a new opportunity using the account created above
            Id newOppRecTypeId = [select Id from RecordType where DeveloperName = 'Core_New_Opportunity' limit 1][0].Id;
            Opportunity opportunity = new Opportunity(Name = 'Test Opportunity1', RecordTypeId = newOppRecTypeId,
                                                   AccountId = acct.Id, StageName = 'Qualify', CloseDate = System.Date.today().addYears(1));
            insert opportunity;
        
            // Create a new opportunity line item using the price book entry created above
            OpportunityLineItem opportunityProduct = new OpportunityLineItem(OpportunityId = opportunity.Id, PricebookEntryId = pbe.Id,
                                                      Core_Status__c = 'Pending', UnitPrice = 100, Quantity = 100);
            insert opportunityProduct;
        
            // Reload the opportunity created   
            opportunity = [select Id, Name, Amount, Core_Opportunity_U_Base__c FROM Opportunity WHERE Id = :opportunity.Id];
        
            // Make sure that the amount, item counts are correct
            System.assertEquals(10000, opportunity.Amount);
            System.assertEquals(100, opportunity.Core_Opportunity_U_Base__c);

        
            // Create a new Marketing Activity using the account created above
            Core_Marketing_Activity__c marketingActivity = new Core_Marketing_Activity__c (Name = 'Test Activity1', Core_Activity_Account__c = acct.Id,
                                                                                      Core_Activity_Start_Date__c = System.Date.today(),
                                                                                      Core_Activity_End_Date__c = System.Date.today().AddYears(1),
                                                                                      Core_Activity_Geo__c = 'ASMO');
            insert marketingActivity;
        
            // Create Marketing Activity opportunity using the opportunity and marketing activity created above
            Core_Marketing_Activity_Opportunity__c marketingActivityOpp = new Core_Marketing_Activity_Opportunity__c(Core_Marketing_Activity__c = marketingActivity.Id,
                                                                                                                Core_Opportunity__c = opportunity.Id);
            insert marketingActivityOpp;
        
            // Reload to get the updated data
            marketingActivityOpp = [select Id, Core_Opportunity_Amount__c, Core_Opportunity_Volume__c FROM Core_Marketing_Activity_Opportunity__c WHERE Id = :marketingActivityOpp.Id];
        
            // Make sure that the amount, item count got copied over from Opportunity to Marketing Activity Opportunity line item
            System.assertEquals(10000, marketingActivityOpp.Core_Opportunity_Amount__c);
            System.assertEquals(100, marketingActivityOpp.Core_Opportunity_Volume__c);
        
        
            // Update the Quantity of the Opportunity line item. It will update the amount, item count
            opportunityProduct.Quantity = 200;
            update opportunityProduct;
        
            // Reload to get the updates
            opportunity = [select Id, Name, Amount, Core_Opportunity_U_Base__c FROM Opportunity WHERE Id = :opportunity.Id];
            // Make sure the new amount, item counts are reflected at the opportunity object 
            System.assertEquals(20000, opportunity.Amount);
            System.assertEquals(200, opportunity.Core_Opportunity_U_Base__c);
        
            // Reload to get the updates
            marketingActivityOpp = [select Id, Core_Opportunity_Amount__c, Core_Opportunity_Volume__c FROM Core_Marketing_Activity_Opportunity__c WHERE Id = :marketingActivityOpp.Id];
            // Make sure the new amount, item counts are reflected at the marketing activity opportunity line item
            System.assertEquals(20000, marketingActivityOpp.Core_Opportunity_Amount__c);
            System.assertEquals(200, marketingActivityOpp.Core_Opportunity_Volume__c);
        }

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
            Core_Trigger_Executions__c triggerExec = new Core_Trigger_Executions__c( 
                Name='UpdateTerritoryInfoOnOppty', Core_Class_Name__c='Core_OpportunityHandler', Core_Object__c='Opportunity', 
                Core_Trigger_Events__c='before Insert before update', Core_Active__c=true, Core_Description__c = 'For testing territory information on Opportunity');
    
            insert triggerExec;
        
            // Create a new account  
            Id newAccountRecTypeId = [select Id from RecordType where DeveloperName = 'Mastered_Account' limit 1][0].Id;
            Account acct = new Account(Name = 'Test Account territory', BillingStreet = '123 Fake St',RecordTypeId = newAccountRecTypeId,
                                       BillingCity = 'Springfield', BillingState = 'IL', BillingCountry = 'USA',
                                       BillingPostalCode = '12345', Core_CIM_ID__c = '8675309');
            Account acct1 = new Account(Name = 'Test Account territory1', BillingStreet = '123 Fake St',RecordTypeId = newAccountRecTypeId,
                                       BillingCity = 'Springfield', BillingState = 'IL', BillingCountry = 'USA',
                                       BillingPostalCode = '12345', Core_CIM_ID__c = '8675309');
            Account acct2 = new Account(Name = 'Test Account territory2', BillingStreet = '123 Fake St',RecordTypeId = newAccountRecTypeId,
                                       BillingCity = 'Springfield', BillingState = 'IL', BillingCountry = 'USA',
                                       BillingPostalCode = '12345', Core_CIM_ID__c = '8675309');
            
            acclist.add(acct);acclist.add(acct1);acclist.add(acct2);
            insert acclist;
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
            Id newOppRecTypeId = [select Id from RecordType where DeveloperName = 'Core_New_Opportunity' limit 1][0].Id;
            Opportunity opp = new Opportunity(Name = 'Test Opportunity1', RecordTypeId = newOppRecTypeId,
                                                   AccountId = acclist[0].Id, StageName = 'Qualify', CloseDate = System.Date.today().addYears(1));
            Opportunity opp1 = new Opportunity(Name = 'Test Opportunity1', RecordTypeId = newOppRecTypeId,
                                                   AccountId = acclist[1].Id, StageName = 'Qualify', CloseDate = System.Date.today().addYears(1));
            Opportunity opp2 = new Opportunity(Name = 'Test Opportunity1', RecordTypeId = newOppRecTypeId,
                                                   AccountId = acclist[2].Id, StageName = 'Qualify', CloseDate = System.Date.today().addYears(1));
            opplist.add(opp);opplist.add(opp1);opplist.add(opp2);
            insert opplist;
            update opplist;
            test.stoptest();
        }
    }
    
    // this method created by infosys team rajesh //
    static testMethod void opportunityOppFactDelete_Test() {
    test.starttest();
              System.runAs(Core_Test_Utility.systemAdminUser){
            list<Account> acclist = new list<Account>();
            list<Opportunity> opplist = new list<Opportunity>();
            // Create the configuration item so the Insert and Update trigger on Opportunity gets executed
            Core_Trigger_Executions__c triggerExec = new Core_Trigger_Executions__c( 
                Name='opportunityOppFactDelete', Core_Class_Name__c='Core_OpportunityHandler', Core_Object__c='Opportunity', 
                Core_Trigger_Events__c='before Delete', Core_Active__c=true, Core_Description__c = 'For testing territory information on Opportunity');
    
            insert triggerExec;
          Core_Opportunity_Facts__c oppFact=new Core_Opportunity_Facts__c();
            oppFact.Core_Ambient_Temp_Req__c='Test Facts';
            insert oppFact;
            // Create a new account  
            Id newAccountRecTypeId = [select Id from RecordType where DeveloperName = 'Mastered_Account' limit 1][0].Id;
            Account acct = new Account(Name = 'Test Account territory', BillingStreet = '123 Fake St',RecordTypeId = newAccountRecTypeId,
                                       BillingCity = 'Springfield', BillingState = 'IL', BillingCountry = 'USA',
                                       BillingPostalCode = '12345', Core_CIM_ID__c = '8675309');
                                       insert acct;
            // Create a new opportunity using the account created above
            Id newOppRecTypeId = [select Id from RecordType where DeveloperName = 'Core_New_Opportunity' limit 1][0].Id;
             Opportunity opp = new Opportunity(Name = 'Test Opportunity1',Core_Opportunity_Facts_ID__c=oppFact.Id, RecordTypeId = newOppRecTypeId,
                                                   AccountId = acct.Id, StageName = 'Qualify', CloseDate = System.Date.today().addYears(1));
             opplist.add(opp);
            insert opplist;
            delete opplist;
            test.stoptest();
        }
    }
    public static List<Opportunity> opptyList = new List<Opportunity>();
    
    static void setupData(){
        Id newAccountRecTypeId = [select Id from RecordType where DeveloperName = 'Mastered_Account' limit 1][0].Id;
        Account acct = new Account(Name = 'Test Account territory', BillingStreet = '123 Fake St',RecordTypeId = newAccountRecTypeId,
                                       BillingCity = 'Springfield', BillingState = 'IL', BillingCountry = 'USA',
                                       BillingPostalCode = '12345', Core_CIM_ID__c = '8675309');
                                       insert acct;
        
        Id newOppRecTypeId = [select Id from RecordType where DeveloperName = 'Core_New_Opportunity' limit 1][0].Id;
        
        System.runAs(Core_Test_Utility.systemAdminUser){
            opptyList.add(new Opportunity(Name = 'Test Opportunity1', RecordTypeId = newOppRecTypeId,
                          AccountId = acct.Id, StageName = 'Qualify', CloseDate = System.Date.today().addYears(1), Core_Technical_Owner__c = UserInfo.getUserId(), Core_Sales_Group__c='Industry Sales', Core_Commissionable__c ='Yes', Core_Product_Segment__c='Client Computing', Core_Product_Application__c = 'Mobile', Core_Consumption_Market__c = 'Education',Core_Sales_Objectives__c='Standard Refresh', Core_Solution_Focus_Area__c='Not Solution Selling', Core_Solution_Focus__c='5G Network Infrastructure',   Core_Solution_Play__c='Not Solution Selling', Core_Opportunity_Country__c='India'));
            opptyList.add(new Opportunity(Name = 'Test Opportunity2', RecordTypeId = newOppRecTypeId,
                      AccountId = acct.Id, StageName = 'Qualify', CloseDate = System.Date.today().addYears(1), Core_Technical_Owner__c = UserInfo.getUserId(), Core_Sales_Group__c='Industry Sales', Core_Commissionable__c ='Yes', Core_Product_Segment__c='Client Computing', Core_Product_Application__c = 'Mobile', Core_Consumption_Market__c = 'Education',Core_Sales_Objectives__c='Standard Refresh', Core_Solution_Focus_Area__c='Not Solution Selling', Core_Solution_Focus__c='5G Network Infrastructure',   Core_Solution_Play__c='Not Solution Selling', Core_Opportunity_Country__c='India'));
            insert opptyList;
        }       
        Profile p = [SELECT id, Name FROM Profile WHERE Name='Sales Rep-BB'];
        User usr = [SELECT id, Name, isActive FROM User WHERE ProfileId = :p.Id AND isActive = true LIMIT 1];
        System.runAs(Core_Test_Utility.systemAdminUser){
            opptyList.add(new Opportunity(Name = 'Test Opportunity2', RecordTypeId = newOppRecTypeId,
                      AccountId = acct.Id, StageName = 'Qualify', CloseDate = System.Date.today().addYears(1), Core_Technical_Owner__c = usr.Id, Core_Sales_Group__c='Industry Sales', Core_Commissionable__c ='Yes', Core_Product_Segment__c='Client Computing', Core_Product_Application__c = 'Mobile', Core_Consumption_Market__c = 'Education',Core_Sales_Objectives__c='Standard Refresh', Core_Solution_Focus_Area__c='Not Solution Selling', Core_Solution_Focus__c='5G Network Infrastructure',     Core_Solution_Play__c='Not Solution Selling', Core_Opportunity_Country__c='India'));
            insert opptyList[2];
        }
    }
    
    
    static testMethod void opportunityTechnicalOwnerUpdate1(){
        Profile p = [SELECT id, Name FROM Profile WHERE Name='Sales Rep-BB'];
        User usr = [SELECT id, Name, isActive FROM User WHERE ProfileId = :p.Id AND isActive = true LIMIT 1];
        List<Core_Trigger_Executions__c> triggExecList = new List<Core_Trigger_Executions__c>();
        triggExecList.add(new Core_Trigger_Executions__c(Name='updateActivityLineItems', Core_Class_Name__c='Core_OpportunityHandler', Core_Object__c='Opportunity_Partner', Core_Trigger_Events__c='After Update', Core_Active__c=true, Core_Description__c = 'blah blah'));
        
        triggExecList.add(new Core_Trigger_Executions__c(Name='opportunityTechnicalOwnerUpdate', Core_Class_Name__c='Core_OpportunityHandler', Core_Object__c='Opportunity', Core_Trigger_Events__c='After Insert After Update', Core_Active__c=true, Core_Description__c = 'blah blah'));
        insert triggExecList;
        test.startTest();
            setupData();
            System.debug('****Opportunities inserted-- '+opptyList);
            opptyList[0].Core_Technical_Owner__c = usr.Id;
            opptyList[0].Core_Product_Segment__c = 'Connected Home';
            opptyList[0].Core_Product_Application__c = 'Media Center';
            opptyList[2].Core_Technical_Owner__c = Core_Test_Utility.systemAdminUser.Id;
            opptyList[2].Core_Product_Segment__c = 'Connected Home';
            opptyList[2].Core_Product_Application__c = 'Media Center';
            update opptyList;
            System.debug('****Opportunities Updated-- '+opptyList);
        test.stopTest();
    }
    
    
    /*static testMethod void opportunityTechnicalOwnerUpdate() {
         System.runAs(Core_Test_Utility.systemAdminUser) {    
            // Profiles used in the test
            String sProfileName = 'Standard User';
            
            // User used in the test
            String sLastName = 'User1';
            String sAlias = 'tuser1';
            String sEmail = 'test.user1@intel.com';
            String sUserName = 'test.user1@intel.com.crm.testclass';
            
            // Variables list
            Id profileId;
                      List<Profile> lstProfiles = null;
            
          // Get the Id of the Standard Profile             
            lstProfiles = [SELECT Id FROM Profile WHERE Name = :sProfileName LIMIT 1];
            if (lstProfiles.size() == 0)
                profileId = null;
            else
                profileId = lstProfiles[0].Id;
            
          
            // TEST CASE 1: Create a new User, default to Non-Badged
            User testUser = new User(LastName = sLastName, Alias = sAlias, Email = sEmail, UserName = sUserName, ProfileId = profileId,
                EmailEncodingKey = 'UTF-8', TimeZoneSidKey = 'America/Los_Angeles', LocaleSidKey = 'en_US', LanguageLocaleKey = 'en_US');
            
            insert testUser;
             User testUser1 = new User(LastName ='test1', Alias = sAlias, Email = 'tes1t@intel.com', UserName = 'test4.user123@intel.com.crm.testclass', ProfileId = profileId,
                EmailEncodingKey = 'UTF-8', TimeZoneSidKey = 'America/Los_Angeles', LocaleSidKey = 'en_US', LanguageLocaleKey = 'en_US');
            
            insert testUser1;

        List < Core_Trigger_Executions__c > lstTriggerExecution = new List < Core_Trigger_Executions__c > ();
        Core_Trigger_Executions__c opportunityTechnicalOwnerUpdate = new Core_Trigger_Executions__c();
        opportunityTechnicalOwnerUpdate.name = 'opportunityTechnicalOwnerUpdate';
        opportunityTechnicalOwnerUpdate.Core_Object__c = 'Opportunity';
        opportunityTechnicalOwnerUpdate.Core_Active__c = TRUE;
        opportunityTechnicalOwnerUpdate.Core_Trigger_Events__c = 'After insert';
        opportunityTechnicalOwnerUpdate.Core_Description__c = 'This is test description';
        opportunityTechnicalOwnerUpdate.Core_Class_Name__c = 'Test Class';
        lstTriggerExecution.add(opportunityTechnicalOwnerUpdate);
        insert lstTriggerExecution;
           Id newAccountRecTypeId = [select Id from RecordType where DeveloperName = 'Mastered_Account' limit 1][0].Id;
            Account acct = new Account(Name = 'Test Account territory', BillingStreet = '123 Fake St',RecordTypeId = newAccountRecTypeId,
                                       BillingCity = 'Springfield', BillingState = 'IL', BillingCountry = 'USA',
                                       BillingPostalCode = '12345', Core_CIM_ID__c = '8675309');
                                       insert acct;
            // Create a new opportunity using the account created above
             Id newOppRecTypeId = [select Id from RecordType where DeveloperName = 'Core_New_Opportunity' limit 1][0].Id;
             Opportunity opp = new Opportunity(Name = 'Test Opportunity1', RecordTypeId = newOppRecTypeId,Core_Technical_Owner__c=testUser.Id,
                                                   AccountId = acct.Id, StageName = 'Qualify', CloseDate = System.Date.today().addYears(1));
             insert opp;
             
             opp.Core_Technical_Owner__c=testUser1.Id;
             opp.Name='TestRecord_Opp';
             update opp;
          }   
    }*/
    // this method created by infosys team rajesh //
    static testMethod void updateForecastRecs_Test() {
    test.starttest();
              System.runAs(Core_Test_Utility.systemAdminUser){
                    list<Account> acclist = new list<Account>();
                    list<Opportunity> opplist = new list<Opportunity>();
                    // Create the configuration item so the Insert and Update trigger on Opportunity gets executed
                    Core_Trigger_Executions__c triggerExec = new Core_Trigger_Executions__c( 
                        Name='forecastUpdateFromOppty', Core_Class_Name__c='Core_OpportunityHandler', Core_Object__c='Opportunity', 
                        Core_Trigger_Events__c='After Update', Core_Active__c=true, Core_Description__c = ' Forecast on updation of an Opportunity.');
            
                    insert triggerExec;
                    Core_Opportunity_Facts__c oppFact=new Core_Opportunity_Facts__c();
                    oppFact.Core_Ambient_Temp_Req__c='Test Facts';
                    insert oppFact;
                    // Create a new account  
                    Id newAccountRecTypeId = [select Id from RecordType where DeveloperName = 'Mastered_Account' limit 1][0].Id;
                    Account acct = new Account(Name = 'Test Account territory', BillingStreet = '123 Fake St',RecordTypeId = newAccountRecTypeId,
                                               BillingCity = 'Springfield', BillingState = 'IL', BillingCountry = 'USA',
                                               BillingPostalCode = '12345', Core_CIM_ID__c = '8675309');
                                               insert acct;
                    // Create a new opportunity using the account created above
                    Id newOppRecTypeId = [select Id from RecordType where DeveloperName = 'Core_New_Opportunity' limit 1][0].Id;
                    opplist.add(new opportunity(Name = 'Test Opportunity1',Core_Opportunity_Facts_ID__c=oppFact.Id, RecordTypeId = newOppRecTypeId,
                                                           AccountId = acct.Id, StageName = 'Qualify', CloseDate = System.today(),Core_Opportunity_Type__c='Deal'));
                                                           
                    opplist.add(new opportunity(Name = 'Test Opportunity1',Core_Opportunity_Facts_ID__c=oppFact.Id, RecordTypeId = newOppRecTypeId,
                                                           AccountId = acct.Id, StageName = 'Qualify', CloseDate = System.today(),Core_Opportunity_Type__c='Design',Core_First_Customer_Ship_Date__c=system.today()));                                      
                 
                    insert opplist;
                     // Create a product/price book entry to use on the opportunities
                      Product2 p = new Product2(Name = 'Test Product 03-24-2015');
                      insert p;
                      PricebookEntry pbe = new PricebookEntry(Product2Id = p.Id, Pricebook2Id = Test.getStandardPricebookId(),
                                                UnitPrice = 0, IsActive = true);
                      insert pbe;
                      List<OpportunityLineItem> oppForLossItems = new List<OpportunityLineItem>();
                      oppForLossItems.add(new OpportunityLineItem(OpportunityId = opplist[0].Id, PricebookEntryId = pbe.Id,Core_Status__c='Pending',
                                                    UnitPrice = 0, Quantity = 10)); 
                      insert oppForLossItems;                            
                      
                      list<Core_Opp_FC_Prod_Schedule__c> ProdScheList=new list<Core_Opp_FC_Prod_Schedule__c>();
                      ProdScheList.add(new Core_Opp_FC_Prod_Schedule__c(Core_Opp_Line_Item_RecordID__c=oppForLossItems[0].Id,Core_Opp_FC_Opportunity__c=opplist[0].Id));
                      insert ProdScheList;
                     opplist[0].CloseDate=system.today().adddays(1);
                     update opplist[0];
                     opplist[1].Core_First_Customer_Ship_Date__c=system.today().adddays(1);
                     update opplist[1];
                    test.stoptest();
                   
          }
    }  
  
        
        
        
}