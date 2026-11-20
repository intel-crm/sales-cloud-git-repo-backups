/**************************************************************************************
Apex Class Name:  Core_WebQuotesController_Test
Version     : 1.0 
Created Date: 10 August 2023
Function    : Test Class for the Core_WebQuotes
Modification Log :
* Developer           Date               Description
* ----------------------------------------------------------------------------            
* Hira Khan        Aug 1st, 2023        Original Version
*************************************************************************************/
@isTest
public class Core_WebQuotesController_Test {
    
    @testSetup
    static void prepareCustomSetting(){
        Account acct = new Account(Name = 'TestDE', BillingStreet = '123 Fake St',
                                   BillingCity = 'Springfield', BillingState = 'IL', BillingCountry = 'USA',Industry='Agriculture',Core_Sub_Industry__c= 'Crop Production',
                                   BillingPostalCode = '12345', Core_Sales_Groups__c=Core_CRM_Utility.getSalesGroupAPI(), Core_Account_Type__c='End Customer');
        System.runAs(Core_Test_Utility.systemAdminUser) {
            insert acct;
        }
        Id newOppRecTypeId = [select Id from RecordType where DeveloperName = 'Core_New_Opportunity' limit 1][0].Id;
        
        Opportunity opps = new Opportunity(Name = 'Opportunity to Lose 03-24-2015', RecordTypeId = newOppRecTypeId,
                                           AccountId = acct.Id,
                                           StageName = 'Qualifying', CloseDate = System.Date.today().addYears(1));
        
        
        System.runAs(Core_Test_Utility.systemAdminUser) {
            insert opps;
            Core_Opportunity_Forecast__c oSA= new Core_Opportunity_Forecast__c();
            oSA.Core_Opportunity__c = opps.id;
            oSA.Core_Forecast_Quarter__c ='Q4 2023';
            oSA.Core_Forecast__c = 'Commit';
            oSA.Core_Read_Only__c = false;
            insert oSA;
            
        }
    }
    
    static testmethod void testgetWebQuotes(){
        Test.startTest();
        Test.setMock(HTTPCalloutMock.class, new Core_SalesSupportHomeControllerMock());
        Opportunity oppsidtest = [Select id from Opportunity where Name='Opportunity to Lose 03-24-2015'];
        Core_WebQuotesController.pullWebQuotes(oppsidtest.Id);
        Core_WebQuotesController.WebQuote webquote = new Core_WebQuotesController.WebQuote();
        Core_WebQuotesController.WebQuoteData webquoteData= new Core_WebQuotesController.WebQuoteData();
        webquote.aprv_prc = 12;
        webquote.approved_quantity=12;
        webquote.cre_dt =  Date.newInstance(2016,6,15);
        webquote.dpa_expr_dt = Date.newInstance(2016,6,15);
        webquote.dpa_vld_fr_dt = Date.newInstance(2016,6,15);
        webquote.prd_dsc =null;
        webquote.quote_name = '869476.01';
        webquote.quote_status = 'DPA Closed';
        webquote.quote_type = 'Volume';
        webquote.creator = 'Sarah Manuel';
        webquote.disti_cost=1.1;
        webquote.intel_prc=12;
        webquote.dpa_number=1;
        webquote.intel_prc_sdc=5;
        webquote.creation_type='Test';
        webquoteData.bQuotesErrorFlag=false;
        webquoteData.bQuotesErrorMessage='Test';
        Test.stopTest();
    }
    //Handling Exception
    static testmethod void testgetWebQuotes2(){
        Test.startTest();
        try{
            Opportunity oppsidtest = [Select id from Opportunity where Name='Opportunity to Lose 03-24-2015'];
            Core_WebQuotesController.pullWebQuotes(null);
            Core_WebQuotesController.WebQuote webquote = new Core_WebQuotesController.WebQuote();
            webquote=null;
        } catch(Exception e){
            system.assertNotEquals(null, e.getMessage());
        }
        Test.stopTest();
    }
}