@isTest 
public class Core_Batch_OpportunityKPIDelete_Test 
{
    static testMethod void testMethod1() 
    {
        //setupData();
        Account acct = new Account(Name = 'Test Account1', BillingStreet = '123 Fake St',
                                   BillingCity = 'Springfield', BillingState = 'IL', BillingCountry = 'USA',
                                   BillingPostalCode = '12345', /*Core_CIM_ID__c = '8675309',*/Core_Sales_Groups__c='Americas Brazil Sales Group', Industry = 'Agriculture' , Core_Sub_Industry__c ='Animal Production');
        insert acct;
        Id newOppRecTypeId = [select Id from RecordType where DeveloperName = 'Core_New_Opportunity' limit 1][0].Id;
        Opportunity oppo = new Opportunity(Name = 'Test Opportunity1', RecordTypeId = newOppRecTypeId, 
                                                  AccountId = acct.Id, StageName = 'Qualify', CloseDate = System.Date.today());
        List <Opportunity> oppList= new List<Opportunity>();
        oppList.add(oppo);
        insert oppList;
        List<Core_Oppty_KPI_New__c> lstOpptyNewKPI= new List<Core_Oppty_KPI_New__c>();
        
        for(Integer i=0 ;i <200;i++)
        {
            Core_Oppty_KPI_New__c opp = new Core_Oppty_KPI_New__c();
            opp.Name ='Name'+i;
            opp.Core_Opportunity_KPI_Batch_ID__c ='1';
            opp.Core_KPI_Opportunity__c=oppo.id;
            lstOpptyNewKPI.add(opp);
        }
        
        insert lstOpptyNewKPI;
        
        
        
        Test.startTest();
            
            Core_Batch_OpportunityKPIDelete obj = new Core_Batch_OpportunityKPIDelete(lstOpptyNewKPI[0].Core_Opportunity_KPI_Batch_ID__c);
            DataBase.executeBatch(obj); 
            
            
        Test.stopTest();
    }
    /*static testMethod void testMethod2() 
    {
        List<Core_Oppty_KPI_New__c> lstOpptyNewKPI= new List<Core_Oppty_KPI_New__c>();
        List<Core_Oppty_KPI_New__c> lstOpptyNewKPI2= new List<Core_Oppty_KPI_New__c>();
        for(Integer i=0 ;i <200;i++)
        {
            Core_Oppty_KPI_New__c opp = new Core_Oppty_KPI_New__c();
            opp.Name ='Name'+i;
            opp.Core_Opportunity_KPI_Batch_ID__c ='1';
            lstOpptyNewKPI.add(opp);
        }
        for(Integer i=0 ;i <200;i++)
        {
            Core_Oppty_KPI_New__c opp = new Core_Oppty_KPI_New__c();
            opp.Name ='Name'+i;
            opp.Core_Opportunity_KPI_Batch_ID__c ='1';
            opp.Core_IsActive__c = false;
            lstOpptyNewKPI2.add(opp);
        }
        
        insert lstOpptyNewKPI2;
        
        insert lstOpptyNewKPI;
        
        Test.startTest();
            List<Core_Oppty_KPI_New__c> listop =[select id,Core_Opportunity_KPI_Batch_ID__c from Core_Oppty_KPI_New__c where Core_Opportunity_KPI_Batch_ID__c =:lstOpptyNewKPI[0].Core_Opportunity_KPI_Batch_ID__c ];
            delete lstOpptyNewKPI;
            Core_Batch_OpportunityKPIDelete obj = new Core_Batch_OpportunityKPIDelete(listop[0].Core_Opportunity_KPI_Batch_ID__c);
            DataBase.executeBatch(obj);
            Core_Batch_InactiveKPIDelete obj1 = new Core_Batch_InactiveKPIDelete();
            DataBase.executeBatch(obj1);
            
        Test.stopTest();
    }*/
}