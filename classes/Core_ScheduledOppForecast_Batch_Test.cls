@IsTest
public class Core_ScheduledOppForecast_Batch_Test {
	@TestSetup
    static void setupTestData() {
        Profile prf = [SELECT id, Name FROM Profile WHERE Name='Sales Rep-BB'];
        User usr = [SELECT id, Name, isActive FROM User WHERE ProfileId = :prf.Id AND isActive = true AND Core_Employee_Type_Code__c='EMP' LIMIT 1];
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
        acct.Core_Sales_Groups__c=Core_CRM_Utility.getSalesGroupAPI();
        acct.Industry='Health and Life Sciences'; 
        acct.Core_Sub_Industry__c='Biotechnology';     
        System.runAs(Core_Test_Utility.systemAdminUser) {
            insert acct;
        }
        
        Opportunity oppForecast = new Opportunity(Name = 'OpportunityForecast##', RecordTypeId = newOppRecTypeId,core_approval_status__c = 'Approved',
                                                 AccountId = acct.Id,Core_Commissionable__c = 'Yes',Core_Technical_Owner__c=usr.id,Core_Date_Submitted_for_Approval__c = System.Date.today()+1,
                                                 StageName = 'Qualify', CloseDate = System.Date.today()+1);
        System.runAs(Core_Test_Utility.systemAdminUser) {
            insert oppForecast;
        }
    }
    
    static testmethod void testOppForBatch() {
        List<Opportunity> lstOpp = [select id,Name from Opportunity Where Name='OpportunityForecast##' limit 1];
        String currentFiscalYear = [SELECT FiscalYearSettings.Name FROM Period WHERE Type = 'Year' AND StartDate <= TODAY AND EndDate >= TODAY].FiscalYearSettings.Name;
        Integer currentFiscalQuarterNum = [Select startdate, Number From Period Where type = 'Quarter' and StartDate = THIS_FISCAL_QUARTER].Number;
        String currentQuarter = 'Q'+currentFiscalQuarterNum+' '+currentFiscalYear;
        Id recordTypeId = [select Id,Name,DeveloperName from RecordType where DeveloperName='Core_OppForecastNew'].Id;
        List<Core_Opportunity_Forecast__c> lstOppFor = new List<Core_Opportunity_Forecast__c>();
        lstOppFor.add(new Core_Opportunity_Forecast__c(Core_Forecast_Quarter__c = currentQuarter,Core_Opportunity__c = lstOpp[0].Id,
                                                             Core_Forecast__c = 'Best Case', Core_Forecast_Amount__c = 1200, Core_Read_Only__c = false, RecordTypeId = recordTypeId));
        
 		System.runAs(Core_Test_Utility.systemAdminUser) {
            insert lstOppFor;
        }
        // Create and execute the batch
        Core_ScheduledOppForecast_Batch batch = new Core_ScheduledOppForecast_Batch();
        Test.startTest();
        Database.executeBatch(batch);
        Test.stopTest();
        
        // Verify the results
        List<Core_Opportunity_Forecast__c> results = [SELECT Id,Core_Forecast_Quarter__c  FROM Core_Opportunity_Forecast__c];
        System.assertEquals(1, results.size());
        for (Core_Opportunity_Forecast__c obj : results) {
            System.assertEquals(currentQuarter, obj.Core_Forecast_Quarter__c);
        }
    }
}