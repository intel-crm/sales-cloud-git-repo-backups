/****************************************************************************************************************************************
* Class Name  : Core_MDF_Custom_BatchJobSch
* Version     : 1.0 
* Created Date: 8-Apr-2021
* Modification Log :
* Developer   Vivek                  Date                          Description
****************************************************************************************************************************************/
public class Core_MDF_Custom_BatchJobSch implements Schedulable{ 
    public class CustomException extends Exception{}
    private string progNameToBeRun = '';
    
    public Core_MDF_Custom_BatchJobSch(string program){ 
        progNameToBeRun = program;
    }
    
    public void execute(SchedulableContext sc) { 
        try{
            if(string.isEmpty(progNameToBeRun)){
                Throw new CustomException('Program cannot be empty');
            }
            Core_MDF_BatchSchedulerUtility.startBatchJob(progNameToBeRun);   
            Core_MDF_BatchSchedulerUtility.updateStatusForCompletedOrFailedJob(progNameToBeRun); 
            Core_MDF_BatchSchedulerUtility.generateBatchChaining(progNameToBeRun);   
        }catch(Exception ex){
            Core_MDF_CCP_UtilityClass.logError(ex);
        }
        
    }
}