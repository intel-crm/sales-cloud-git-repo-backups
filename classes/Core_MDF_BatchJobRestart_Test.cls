@isTest(SeeAllData=false)
public class Core_MDF_BatchJobRestart_Test {
    @TestSetup static void setUpData(){ 
        
    } 
    
    @isTest static void restartBatchJobTest(){
        List<Core_MDF_Configuration__c> configList = new List<Core_MDF_Configuration__c>();
        Core_MDF_Configuration__c config1 = new Core_MDF_Configuration__c();
        config1.Name = 'Batch_Scheduler_Restart_Time_Buffer';
        config1.Core_MDF_Value__c = '-30';
        configList.add(config1);
        Core_MDF_Configuration__c config2 = new Core_MDF_Configuration__c();
        config2.Name = 'CUSTOM_SCHEDULER_BATCH_JOB_NAME';
        config2.Core_MDF_Value__c = 'CustomBatchSchedulerJob-';
        configList.add(config2);            
        Database.insert(configList);
        Test.startTest();
        String cronExp = '0 0 0 15 3 ? 2026'; 
        System.schedule('CCP1_CustomBatchSchedulerJob-', cronExp, new Core_MDF_BatchJobRestart('CCP1'));
        List<CronTrigger> ctListInExecState = [SELECT CronJobDetail.Name,createdDate,state FROM CronTrigger WHERE CronJobDetail.Name Like '%CCP1_CustomBatchSchedulerJob-%' and state IN ('WAITING','ACQUIRED','EXECUTING','PAUSED','PAUSED_BLOCKED') order by createdDate desc limit 1];
        
        /*if(ctListInExecState.size()>0){
            System.pauseJobById(ctListInExecState[0].Id);
        }*/
        //List<CronTrigger> ctListInExecState1 = [SELECT CronJobDetail.Name,createdDate,state FROM CronTrigger WHERE CronJobDetail.Name Like '%CCP1_CustomBatchSchedulerJob-%'  order by createdDate desc limit 1];
        //
        try{
            Core_MDF_BatchJobRestart obj = new Core_MDF_BatchJobRestart('CCP1');
            obj.execute(null);
        }catch(Exception e){
            String message = e.getMessage();
            System.assert(e.getMessage().contains('This is not a valid job to restart.Please check the input parameter'), 'message=' + e.getMessage());
        }
        Test.stopTest();
    }
    @isTest static void restartBatchJobExceptionTest(){
        List<Core_MDF_Configuration__c> configList = new List<Core_MDF_Configuration__c>();
        Core_MDF_Configuration__c config1 = new Core_MDF_Configuration__c();
        config1.Name = 'Batch_Scheduler_Restart_Time_Buffer';
        config1.Core_MDF_Value__c = '-30';
        configList.add(config1);
        Core_MDF_Configuration__c config2 = new Core_MDF_Configuration__c();
        config2.Name = 'CUSTOM_SCHEDULER_BATCH_JOB_NAME';
        config2.Core_MDF_Value__c = 'EnterExceptionBlock';
        configList.add(config2);            
        Database.insert(configList);
        Test.startTest();
        try{
            Core_MDF_BatchJobRestart obj = new Core_MDF_BatchJobRestart('CCP');
            obj.execute(null);
        }catch(Exception e){
            String message = e.getMessage();
            System.assert(e.getMessage().contains('This is not a valid job to restart.Please check the input parameter'), 'message=' + e.getMessage());
        }
        Test.stopTest();
        
    }
}