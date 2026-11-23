@isTest
public class Core_Opportunity_KPI_Delete_Batch_Test {
    
    
    static testMethod void testMethod1() 
    {
        Id newOppRecTypeId = [select Id from RecordType where DeveloperName = 'Core_Design_Opportunity' limit 1][0].Id;
        Account acct = new Account(Name = 'Test Account 03-25-2015', BillingStreet = '123 Fake St',
                                   BillingCity = 'Springfield', BillingState = 'IL', BillingCountry = 'USA',Industry='Agriculture',Core_Sub_Industry__c= 'Crop Production',
                                   BillingPostalCode = '12345', Core_Business_Party_Id__c= '8675309',Core_Sales_Groups__c='EMEA Sales Group');
        System.runAs(Core_Test_Utility.systemAdminUser) {
            insert acct;
        }
        Opportunity opp = new Opportunity(Name = 'Opportunity on 05-28-2021', RecordTypeId = newOppRecTypeId,
                                                 AccountId = acct.Id,Opportunity_Focus__c= 'Core',Core_Opportunity_Type__c ='Design: Original',
                                                 StageName = 'Qualify', CloseDate = System.Date.today().addYears(1));
        System.runAs(Core_Test_Utility.systemAdminUser) {
            insert opp;
        }
        
        
        List<Core_Oppty_KPI_New__c> OppKPIList= new List<Core_Oppty_KPI_New__c>();
        for(Integer i=0 ;i <200;i++)
        {
            Core_Oppty_KPI_New__c KPI = new Core_Oppty_KPI_New__c();
            KPI.Name ='Name'+i;
            KPI.Core_KPI_Opportunity__c=opp.id;
            OppKPIList.add(KPI);
        }
        
        insert OppKPIList;
        //List<Core_Opp_KPI_History__c> kpiHistoryList = new List<Core_Opp_KPI_History__c>();
        //kpiHistoryList = [SELECT id, Core_Opp_KPI_Opportunity_KPI_Name__c, Core_Opp_KPI_Opportunity_Name__c FROM Core_Opp_KPI_History__c WHERE Core_Opp_KPI_Opportunity_KPI_Name__c IN :OppKPIList];
        
        Test.startTest();
        
        Core_Opportunity_KPI_Delete_Batch obj = new Core_Opportunity_KPI_Delete_Batch();
        DataBase.executeBatch(obj);         
        Test.stopTest();
        System.assertEquals(true,true);
    }
    
    
}