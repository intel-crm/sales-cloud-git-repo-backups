/***************************************************************************************************************************************************************************************************
Apex Class Name:  Core_Batch_DeleteInactiveKPIHistory
Version     : 1.0 
Modified Date: 07/22/2022
Function    : Batch class to delete Inactive Oppo KPI history records
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Gaurav Kurwade             07/22/2022              Updated Version
*****************************************************************************************************************************************************************************************************/
@isTest 
public class Core_DeleteInactiveKPIs_Test {
    static testMethod void testMethod1() 
    {    
        Id newOppRecTypeId = [select Id from RecordType where DeveloperName = 'Core_New_Opportunity' limit 1][0].Id;
        SObjectType r = ((SObject)Type.forName('Schema','Account').newInstance()).getSObjectType();
        Id recTypeId = r.getDescribe().getRecordTypeInfosByDeveloperName().get(Label.Pricing_Tender_Account_RecordType_IntelAccount).getRecordTypeId();
        Account acct = new Account(Name = 'Test Account 03-25-2015', BillingStreet = '123 Fake St',RecordTypeId = recTypeId,
                                   BillingCity = 'Springfield', BillingState = 'IL', BillingCountry = 'USA',Industry='Agriculture',Core_Sub_Industry__c= 'Crop Production',
                                   BillingPostalCode = '12345',Core_Sales_Groups__c='Americas Brazil Sales Group');
        System.runAs(Core_Test_Utility.systemAdminUser) {
            insert acct;
        }
        Opportunity opprec = new Opportunity(Name = 'Opportunity test', RecordTypeId = newOppRecTypeId,
                                                 AccountId = acct.Id,
                                                 StageName = 'Qualifying', CloseDate = System.Date.today().addYears(1));
                                                 insert opprec ;
        List<Core_Oppty_KPI_New__c> lstOpptyNewKPI= new List<Core_Oppty_KPI_New__c>();
        List<Core_Opp_KPI_History__c> kpiHistoryList = new List<Core_Opp_KPI_History__c>();

            Core_Oppty_KPI_New__c opp = new Core_Oppty_KPI_New__c();
            opp.Name ='NameKPI';
            opp.Core_Opportunity_KPI_Batch_ID__c ='1';
            opp.Core_KPI_Opportunity__c =  opprec.id;
            opp.Core_IsActive__c = false;
            insert opp;
            lstOpptyNewKPI.add(opp);

            Core_Opp_KPI_History__c opphis = new Core_Opp_KPI_History__c();
            opphis.Core_Opp_KPI_Opportunity_Name__c = opprec.id;
            opphis.Core_New_Opportunity_KPI__c =opp.id;
            insert opphis;  
            
        
        system.assertequals(lstOpptyNewKPI.isEmpty(),false);
        
        Test.startTest();
            Core_DeleteInactiveKPIs.deleteKpi();
            
        Test.stopTest();
    }
}