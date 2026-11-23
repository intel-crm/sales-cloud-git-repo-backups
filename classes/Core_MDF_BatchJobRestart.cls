/******************************************************************************************************
* Class Name  : Core_MDF_BatchJobRestart  
* Version     : 1.0    
* Created Date: 03-10-2021
* Modification Log :
* Developer            Date               Description
* -----------------------------------------------------------------------------------------------------
* Accenture - NK      03/10/2021         Schedulable class to check if custom scheduler is working.
*******************************************************************************************************/
public without sharing class Core_MDF_BatchJobRestart implements Schedulable{
    public class customException extends Exception{}
    public String programs ='';
    public String progNames;
    public String jobName;
    public String jobNameStr;
    List<String> programList;
    // inputPrograms is either one program or multiple programs with Comma seperated ex:'CCP,CPQ'
    public Core_MDF_BatchJobRestart(string inputPrograms){
        this.programs = inputPrograms;
        //retrieves the batch job name "CustomBatchSchedulerJob-"
        Core_MDF_Configuration__c configBatchName = Core_MDF_Configuration__c.getValues('CUSTOM_SCHEDULER_BATCH_JOB_NAME');
        jobNameStr = configBatchName.Core_MDF_Value__c;
        if(string.isNotEmpty(programs)){
            progNames = programs.replaceAll(',','_');
            //setting up the jobname format
            jobName='%' + progNames +'_'+ jobNameStr+'%';
        }
    }
    public void execute(SchedulableContext sc) {
        //retrieves crontrigger records with the jobname combination 
        List<CronTrigger> ctListWithJob = [SELECT CronJobDetail.Name,createdDate FROM CronTrigger WHERE CronJobDetail.Name Like : jobName order by createdDate desc limit 10];
        //checks there is job exist with the given job name
        if(ctListWithJob !=null && ctListWithJob.size()>0){
            //retrieves crontrigger record in which are in queue/processing state for the given jobname
            List<CronTrigger> ctListInExecState = [SELECT CronJobDetail.Name,createdDate FROM CronTrigger WHERE CronJobDetail.Name Like : jobName and state IN ('WAITING','ACQUIRED','EXECUTING','PAUSED','PAUSED_BLOCKED') order by createdDate desc limit 1];
            CronTrigger latestCronTrigger = [SELECT CronJobDetail.Name,createdDate,state FROM CronTrigger WHERE CronJobDetail.Name Like : jobName order by createdDate desc limit 1];
            //executes the batch chaining when there is no job running with the given jobname combination
            Core_MDF_Configuration__c configBatchName = Core_MDF_Configuration__c.getValues('Batch_Scheduler_Restart_Time_Buffer');
            Integer timeBuffer = Integer.valueOf(configBatchName.Core_MDF_Value__c);
            DateTime lastJobTime = latestCronTrigger.createdDate.addminutes(timeBuffer);
            if(ctListInExecState.isEmpty() && lastJobTime < system.now()){
                String errorMsg = 'Batch Scheduler Stopped :: ' + latestCronTrigger + '--Restart time :: '+ system.now();
                String objectName = 'Batch Scheduler';
                String subject = Label.Core_MDF_CCP_Support_Email_Subject + ' ' + objectName;
                Map<String, String> coreLogMap = new Map<String, String>();
                coreLogMap.put('Core_Details__c',errorMsg);
                coreLogMap.put('Core_Message__c', Label.Core_MDF_SFDC_Environment + ': ' + subject);
                coreLogMap.put('Core_Origin__c', objectName);
                coreLogMap.put('Core_Project__c',Label.Core_MDF_Program_Name);
                coreLogMap.put('Core_Scope__c',objectName);
                coreLogMap.put('Core_Severity__c', 'Info');
                coreLogMap.put('Core_Support_Email__c', Label.Core_MDF_CCP_Support_Email);
                coreLogMap.put('Core_Support_Link__c', Label.Core_MDF_CCP_Support_Link);
                coreLogMap.put('Core_Tags__c', objectName + '\t' + 'Co-Marketing') ;
                String errorText = Core_MDF_CCP_UtilityClass.createLogEntry(coreLogMap);
                //rescheduling batch for failed jobs
                Core_MDF_BatchSchedulerUtility.generateBatchChaining(programs);
            }
        }
        else{
            customException ex=new customException();
            ex.setMessage('This is not a valid job to restart.Please check the input parameter');
            Core_MDF_CCP_UtilityClass.logError(ex);
            throw ex;
        }
    }      
    
}