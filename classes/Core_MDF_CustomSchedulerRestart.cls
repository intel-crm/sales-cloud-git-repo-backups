/******************************************************************************************************
* Class Name  : Core_MDF_CustomSchedulerRestart  
* Version     : 1.0    
* Created Date: 03-10-2021
* Modification Log :
* Developer            Date               Description
* -----------------------------------------------------------------------------------------------------
* Accenture - NK      03/10/2021         Schedulable class to check if custom scheduler is working.
*******************************************************************************************************/
public class Core_MDF_CustomSchedulerRestart implements Schedulable{
	public void execute(SchedulableContext sc) {
       /* List<string> statuslist = new List<String>{'Holding', 'Queued', 'Preparing', 'Processing'};
        List<AsyncApexJob> jobList = [SELECT Id, ApexClass.Name from AsyncApexJob  where ApexClass.Name = 'Core_MDF_CustomScheduler' and status in:statuslist ];
        if(jobList == null || jobList.size() == 0){
            Core_MDF_CustomSchedulerUtility.generateBatchChaining();
        }*/
    }
}