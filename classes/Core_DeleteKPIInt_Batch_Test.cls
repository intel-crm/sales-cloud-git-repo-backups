@isTest
public class Core_DeleteKPIInt_Batch_Test {
    static testMethod void testMethod1() 
    {
        List<Core_KPI_Integration_Inbound__c> KPIInbound= new List<Core_KPI_Integration_Inbound__c>();
        for(Integer i=0 ;i <200;i++)
        {
            Core_KPI_Integration_Inbound__c KPI = new Core_KPI_Integration_Inbound__c();
            KPI.Core_IAH_KPI_Name__c ='Name'+i;
            KPI.CreatedDate=system.today().addDays(-91);
            KPIInbound.add(KPI);
        }
        
        insert KPIInbound;
        
        Test.startTest();

            //Core_DeleteKPIInt_Batch obj = new Core_DeleteKPIInt_Batch();
        	String cron = '0 0 0 1 * ? *';
        	System.schedule('KPI_DeltaLoad_Every24hrs', cron, new Core_Scheduler_DeleteKPIInt());
            //DataBase.executeBatch(obj); 
            
        Test.stopTest();
    }
    
    static testMethod void testMethod2() 
    {
        List<Core_KPI_Integration_Inbound__c> KPIInbound= new List<Core_KPI_Integration_Inbound__c>();
        for(Integer i=0 ;i <200;i++)
        {
            Core_KPI_Integration_Inbound__c KPI = new Core_KPI_Integration_Inbound__c();
            KPI.Core_IAH_KPI_Name__c ='Name'+i;
            KPI.CreatedDate=system.today().addDays(-30);
            KPIInbound.add(KPI);
        }
        
        insert KPIInbound;
        
        Test.startTest();

            Core_DeleteKPIInt_Batch obj = new Core_DeleteKPIInt_Batch();
            DataBase.executeBatch(obj); 
            
        Test.stopTest();
    }

}