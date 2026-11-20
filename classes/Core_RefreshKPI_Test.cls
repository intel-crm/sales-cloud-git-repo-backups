@isTest
public class Core_RefreshKPI_Test {
    static testMethod void testMethod1(){
        Account acct = new Account(Name = 'Test Account1', BillingStreet = '123 Fake St',
                                   BillingCity = 'Springfield', BillingState = 'IL', BillingCountry = 'USA',
                                   BillingPostalCode = '12345',Core_Sales_Groups__c='Americas US Sales Group', Industry = 'Agriculture' , Core_Sub_Industry__c ='Animal Production');
        insert acct;
        
        // Create a new opportunity using the account created above
        Id newOppRecTypeId = [select Id from RecordType where DeveloperName = 'Core_New_Opportunity' limit 1][0].Id;
        Opportunity oppo = new Opportunity(Name = 'Test Opportunity1', RecordTypeId = newOppRecTypeId, 
                                                  AccountId = acct.Id, StageName = 'Qualify', CloseDate = System.Date.today());
        insert oppo;
        List<opportunity> olist = new List<opportunity>();
        olist.add(oppo);
        
        Test.startTest();
        PageReference testPage = Page.Core_RefreshKPI_VF;
        Test.setCurrentPage(testPage );
        ApexPages.StandardSetController setCon = new ApexPages.StandardSetController(olist);
        apexPages.Currentpage().getParameters().put('Id',olist[0].id);
        Core_RefreshKPI ext = new Core_RefreshKPI(setCon );
        
        ext.autorun();
        Test.stopTest();
        
    }
    static testMethod void testMethod2(){
        Account acct = new Account(Name = 'Test Account1', BillingStreet = '123 Fake St',
                                   BillingCity = 'Springfield', BillingState = 'IL', BillingCountry = 'USA',
                                   BillingPostalCode = '12345',Core_Sales_Groups__c='Americas US Sales Group', Industry = 'Agriculture' , Core_Sub_Industry__c ='Animal Production');
        insert acct;
        
        // Create a new opportunity using the account created above
        Id newOppRecTypeId = [select Id from RecordType where DeveloperName = 'Core_New_Opportunity' limit 1][0].Id;
        Opportunity oppo = new Opportunity(Name = 'Test Opportunity1', RecordTypeId = newOppRecTypeId, 
                                                  AccountId = acct.Id, StageName = 'Qualify', CloseDate = System.Date.today());
        insert oppo;
        oppo.Core_Is_KPI_Refresh__c = true;
        update oppo;
        List<opportunity> olist = new List<opportunity>();
        olist.add(oppo);

        core_kpi_staging__c obj4 = new core_kpi_staging__c();
        obj4.Core_Opportunity_ID_Txt__c = olist[0].id;
        obj4.Core_Refresh_Type__c = 'Incremental';
        obj4.Core_Status__c = 'Success';
        obj4.Core_Batch_ID__c = '1';
        insert obj4;

        Test.setCreatedDate(obj4.Id, DateTime.newInstance(2022,09,09));

        
       
       

        PageReference testPage = Page.Core_RefreshKPI_VF;
        Test.setCurrentPage(testPage );
        ApexPages.StandardSetController setCon = new ApexPages.StandardSetController(olist);
        apexPages.Currentpage().getParameters().put('Id',olist[0].id);
        Core_RefreshKPI ext = new Core_RefreshKPI(setCon );
        core_kpi_staging__c obj = new core_kpi_staging__c();
        obj.Core_Opportunity_ID_Txt__c = olist[0].id;
        obj.Core_Batch_ID__c = '0';
        insert obj;
        Core_RefreshKPI.checkKPIRefreshProcessing(olist[0].id);
        core_kpi_staging__c obj1 = new core_kpi_staging__c();
        obj1.Core_Opportunity_ID_Txt__c = olist[0].id;
        obj1.Core_Refresh_Type__c = 'Incremental';
        obj1.Core_Status__c = 'New';
        obj1.Core_Batch_ID__c = '2';

        core_kpi_staging__c obj2 = new core_kpi_staging__c();
        obj2.Core_Opportunity_ID_Txt__c = olist[0].id;
        obj2.Core_Refresh_Type__c = 'Incremental';
        obj2.Core_Status__c = 'New';
        obj2.Core_Batch_ID__c = '2';
        List<core_kpi_staging__c> listKpi = new LIst<core_kpi_staging__c>();
        listKpi.add(obj1);
        listKpi.add(obj2);
        insert listKpi;
        
        List<core_kpi_staging__c> listKpi1 = new LIst<core_kpi_staging__c>();
        Core_RefreshKPI.checkKPIRefreshProcessing(olist[0].id);
        obj1.Core_Status__c = 'Success';
        listKpi1.add(obj1);
        listKpi1.add(obj2);
        update listKpi1;

        
        Core_RefreshKPI.checkKPIRefreshProcessing(olist[0].id);
        obj1.Core_Status__c = 'Failure';
        update obj1;
        Core_RefreshKPI.checkKPIRefreshProcessing(olist[0].id);
    }
}