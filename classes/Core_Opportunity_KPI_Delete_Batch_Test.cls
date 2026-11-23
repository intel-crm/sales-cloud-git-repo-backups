@isTest
public class Core_Opportunity_KPI_Delete_Batch_Test {
    
    
    static testMethod void testMethod1() 
    {
        Account acct = new Account(Name = 'Test Account 03-25-2015', BillingStreet = '123 Fake St',
                                   BillingCity = 'Springfield', BillingState = 'IL', BillingCountry = 'USA',
                                   BillingPostalCode = '12345', Core_CIM_ID__c = '8675309',Core_Sales_Groups__c='DCG Sales Group');
        
        insert acct;
        
        Id newOppRecTypeId = [select Id from RecordType where DeveloperName = 'Core_New_Opportunity' limit 1][0].Id;
        Opportunity opp = new Opportunity(Name = 'Opportunity to Lose 03-24-2015', RecordTypeId = newOppRecTypeId,
                                          AccountId = acct.Id,
                                          StageName = 'Qualifying', CloseDate = System.Date.today().addYears(1));
        
        insert opp;
        
        
        List<Core_Opportunity_KPI__c> OppKPIList= new List<Core_Opportunity_KPI__c>();
        for(Integer i=0 ;i <200;i++)
        {
            Core_Opportunity_KPI__c KPI = new Core_Opportunity_KPI__c();
            KPI.Name ='Name'+i;
            KPI.Core_Opp_KPI_Opportunity__c=opp.id;
            OppKPIList.add(KPI);
        }
        
        insert OppKPIList;
        //List<Core_Opp_KPI_History__c> kpiHistoryList = new List<Core_Opp_KPI_History__c>();
        //kpiHistoryList = [SELECT id, Core_Opp_KPI_Opportunity_KPI_Name__c, Core_Opp_KPI_Opportunity_Name__c FROM Core_Opp_KPI_History__c WHERE Core_Opp_KPI_Opportunity_KPI_Name__c IN :OppKPIList];
        
        Test.startTest();
        
        Core_Opportunity_KPI_Delete_Batch obj = new Core_Opportunity_KPI_Delete_Batch();
        DataBase.executeBatch(obj);         
        Test.stopTest();
    }
    
    
}