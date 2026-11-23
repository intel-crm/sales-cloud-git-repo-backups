public without sharing class Core_MDF_ScheduleBatch {
    
     public void invokeBatchScheduler(){
        Core_MDF_Payment_Run__c pRun = new Core_MDF_Payment_Run__c();
        pRun = [Select id,CreatedDate,Core_MDF_Status_Txt__c from Core_MDF_Payment_Run__c order by CreatedDate limit 1];
        Core_MDF_Batch_PaymentFileGenerator batchClassInstance = new Core_MDF_Batch_PaymentFileGenerator(pRun);
         datetime dt = datetime.now();
         dt=dt.addMinutes(15);
        Core_MDF_CustomSchedulerUtility.scheduleJob(batchClassInstance, 200, dt);
		//System.schedule('Scheduled Job 1', '0 43 * * * ?', s);
    }      
}