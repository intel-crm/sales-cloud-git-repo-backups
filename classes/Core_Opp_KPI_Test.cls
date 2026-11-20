@isTest
public class Core_Opp_KPI_Test {
    static List<Account> accountList;
    static testMethod void test1(){
        /* Create a new account        
        Account acct = new Account(Name = 'Test Account1', BillingStreet = '123 Fake St',
                                   BillingCity = 'Springfield', BillingState = 'IL', BillingCountry = 'USA',Industry='Agriculture',Core_Sub_Industry__c= 'Crop Production',
                                   BillingPostalCode = '12345', Core_Business_Party_Id__c= '8675309',Core_Sales_Groups__c='Americas Partner Holding');
        insert acct;*/
         Id accountRecordTypeIntel = Schema.sObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();   
        accountList = Core_Test_Utility.createAccount(1);
        accountList[0].Name = 'Dell';
        accountList[0].Core_Sales_Groups__c = 'PRC Sales Group';//Core_CRM_Utility.getSalesGroupAPI();        
        accountList[0].Industry = 'Agriculture';
        accountList[0].Core_Sub_Industry__c = 'Forestry';
        accountList[0].recordtypeID = accountRecordTypeIntel;
        insert accountList;
        
        List<account> LstAcc = Core_Test_Utility.createAccount(2);
        LstAcc[0].Core_Sales_Groups__c = 'PRC Sales Group';//Core_CRM_Utility.getSalesGroupAPI();
        lstAcc[1].Core_Sales_Groups__c = 'PRC Sales Group';//Core_CRM_Utility.getSalesGroupAPI();           
        
        LstAcc[0].recordtypeID = accountRecordTypeIntel;
        lstAcc[1].recordtypeID = accountRecordTypeIntel;
        insert LstAcc;
        
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
                                                  AccountId = accountList[0].Id, StageName = 'Qualify', CloseDate = System.Date.today().addYears(1));
        insert opportunity;
        
        List<Core_Opportunity_KPI__c> oppKpiList = new List<Core_Opportunity_KPI__c>();
        Core_Opportunity_KPI__c oppKpi = new Core_Opportunity_KPI__c();
        oppKpi.Core_Opp_KPI_Achieved__c = false;
        oppKpi.Core_Opp_KPI_Add_Date__c = system.now();
        oppKpi.Core_Opp_KPI_BU_Owner__c = userInfo.getUserId();
        oppKpi.Core_Opp_KPI_Description__c = 'Test Description';
        oppKpi.Core_Opp_KPI_Last_Update_Date__c = system.now();
        oppKpi.Core_Opp_KPI_Volume__c = 10;
        oppKpi.Core_Opp_KPI_Quantity__c = 5;
        oppKpi.Core_Opp_KPI_Total_Price__c = 100;
        oppKpi.Core_Opp_KPI_Opportunity__c = opportunity.Id;
        oppKpi.Core_Opp_KPI_Threshold_Met__c = 'No';
        oppKpi.Core_Opp_KPI_Threshold_Req__c = 'Testing';
        oppKpi.Core_Opp_KPI_Type__c = 'Salesforce Pipeline $';
        oppKpiList.add(oppKpi);
        
        oppKpi = new Core_Opportunity_KPI__c();
        oppKpi.Core_Opp_KPI_Achieved__c = false;
        oppKpi.Core_Opp_KPI_Add_Date__c = system.now();
        oppKpi.Core_Opp_KPI_BU_Owner__c = userInfo.getUserId();
        oppKpi.Core_Opp_KPI_Description__c = 'Test Description';
        oppKpi.Core_Opp_KPI_Last_Update_Date__c = system.now();
        oppKpi.Core_Opp_KPI_Volume__c = 10;
        oppKpi.Core_Opp_KPI_Quantity__c = 5;
        oppKpi.Core_Opp_KPI_Total_Price__c = 100;
        oppKpi.Core_Opp_KPI_Opportunity__c = opportunity.Id;
        oppKpi.Core_Opp_KPI_Threshold_Met__c = 'No';
        oppKpi.Core_Opp_KPI_Threshold_Req__c = 'Testing';
        oppKpi.Core_Opp_KPI_Type__c = 'Salesforce Pipeline $';
        oppKpiList.add(oppKpi);
        
        Core_KPI_FullRefresh_Check__c fullRefresh = new Core_KPI_FullRefresh_Check__c();
        fullRefresh.IsFullRefresh__c = false;
        insert fullRefresh;
        
        insert oppKpiList;
        
        delete oppKpiList[0];
        system.assertEquals(oppKpiList.size(), 2);
    }
}