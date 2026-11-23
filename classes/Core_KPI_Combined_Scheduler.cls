public class Core_KPI_Combined_Scheduler  implements Schedulable {
    
    public string context;
    public Integer batchSize;
    public Core_KPI_Combined_Scheduler(string currContext, Integer currBatchSize){
        context=currContext;
        batchSize=currBatchSize;
    }
    public void execute(SchedulableContext sc) {
        
        switch on context{
          when 'Core_Opp_LastActvityUpdate_Batch'{
                Database.executeBatch(new Core_Opp_LastActvityUpdate_Batch(), 200);                
            }

            when 'Core_OppProductConcatenatedFieldUpdBatch'{
                Database.executeBatch(new Core_OppProductConcatenatedFieldUpdBatch(), 200);                
            }
            when 'Core_Batch_Delete_Dup_Accounts'{
                Database.executeBatch(new Core_Batch_Delete_Dup_Accounts());                
            }
            when 'Core_Batch_Delete_Old_Log_Entries'{
                Database.executeBatch(new Core_Batch_Delete_Old_Log_Entries());                
            }
            when 'Core_Batch_Populate_Territory'{
                Database.executeBatch(new Core_Batch_Populate_Territory());                
            }
        }
        
        //String CRON_EXP = '0 29 22 ? * * *';
        //System.schedule('Core_KPI_Combined_Scheduler1', CRON_EXP, new Core_KPI_Combined_Scheduler('Core_KPI_Combined_Scheduler'));        
    }
}