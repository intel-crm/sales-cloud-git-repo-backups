global class Core_PCC_OpportunityReminderSch implements Schedulable {
   global static void execute(SchedulableContext sc) {
       String jobName = 'Core_PCC_OpportunityReminderBatch';
       String cronExpression = '0 30 4 * * ?';
      
       Core_PCC_OpportunityReminderBatch batchInstance = new Core_PCC_OpportunityReminderBatch();
      
   //Database.executeBatch(new Core_PCC_OpportunityReminderBatch(), 20);
   }
}