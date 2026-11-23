@isTest
public class Core_Batch_KPIStageDelete_Test {
    static testMethod void testMethod1() 
    {
        List<Core_KPI_Staging__c > KPIInbound= new List<Core_KPI_Staging__c >();
        for(Integer i=0 ;i <200;i++)
        {
            Core_KPI_Staging__c  KPI = new Core_KPI_Staging__c ();
            KPI.Core_KPI_Name__c ='Name'+i;
            KPI.CreatedDate=system.today().addDays(-91);
            KPIInbound.add(KPI);
        }
        
        insert KPIInbound;
        
        Test.startTest();

            //Core_DeleteKPIInt_Batch obj = new Core_DeleteKPIInt_Batch();
          /*String cron = '0 0 0 1 * ? *';
          System.schedule('KPI_DeltaLoad_Every24hrs', cron, new Core_Scheduler_DeleteKPIStage());*/
         Core_Batch_KPIStageDelete obj = new Core_Batch_KPIStageDelete();//TWC4767-3867
         DataBase.executeBatch(obj); 
            
            
        Test.stopTest();
    }
    
    static testMethod void testMethod2() 
    {
        List<Core_KPI_Staging__c > KPIInbound= new List<Core_KPI_Staging__c >();
        for(Integer i=0 ;i <200;i++)
        {
            Core_KPI_Staging__c  KPI = new Core_KPI_Staging__c ();
            KPI.Core_KPI_Name__c ='Name'+i;
            KPI.CreatedDate=system.today().addDays(-30);
            KPIInbound.add(KPI);
        }
        
        insert KPIInbound;
        
        Test.startTest();

            Core_Batch_KPIStageDelete obj = new Core_Batch_KPIStageDelete();
            DataBase.executeBatch(obj); 
            
        Test.stopTest();
    }

}