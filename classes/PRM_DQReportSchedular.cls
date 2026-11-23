/**
* Class Name - PRM_DQReportSchedular
* Created By - DINESH
* Created Date - 07-06-2023
* Description - This is schedular for PRM_ProfileReponseMismatchReportBatch and PRM_BenefitMismatchReportBatch
*/
public class PRM_DQReportSchedular implements Schedulable {
    String className;
    
    public PRM_DQReportSchedular(String className) {
        this.className = className;
    }
    
    // Executes the scheduled job
    public void execute(SchedulableContext context) {
        // Get the dynamic type based on the class name
        Type dynamicType = Type.forName(className);
        
        if (dynamicType != null) {
            // Check if the dynamic type is an instance of PRM_ProfileReponseMismatchReportBatch
            if (dynamicType.newInstance() instanceof PRM_ProfileReponseMismatchReportBatch) {
                // Cast the dynamic instance to PRM_ProfileReponseMismatchReportBatch
                PRM_ProfileReponseMismatchReportBatch batchInstance = (PRM_ProfileReponseMismatchReportBatch) dynamicType.newInstance();
                
                // Execute the batch job
                Database.executeBatch(batchInstance);
            } 
            // Check if the dynamic type is an instance of PRM_BenefitMismatchReportBatch
            else if(dynamicType.newInstance() instanceof PRM_BenefitMismatchReportBatch){
                // Cast the dynamic instance to PRM_BenefitMismatchReportBatch
                PRM_BenefitMismatchReportBatch batchInstance = (PRM_BenefitMismatchReportBatch) dynamicType.newInstance();
                
                // Execute the batch job
                Database.executeBatch(batchInstance);
            }
        }
    }
    
    // Schedule a batch job
    public static void scheduleBatch(String className, String cronExpression, String jobName) {
        PRM_DQReportSchedular schedulable = new PRM_DQReportSchedular(className);
        
        // Schedule the job with the given cron expression
        System.schedule(jobName, cronExpression, schedulable);
    }
}