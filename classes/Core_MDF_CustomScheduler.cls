/******************************************************************************************************
* Class Name  : Core_MDF_CustomScheduler
* Version     : 1.0    
* Created Date: 03/10/2021
* Modification Log :
* Developer            Date               Description
* -----------------------------------------------------------------------------------------------------
* Accenture - NK      03/10/2021      Schedulable class to schedule batch jobs saved in custom scheduler object.
*******************************************************************************************************/
public class Core_MDF_CustomScheduler  implements Schedulable {

     public void execute(SchedulableContext sc) {
         List<Core_MDF_Custom_Scheduler__c > lstBatch = new List<Core_MDF_Custom_Scheduler__c >();
         list<Core_MDF_Custom_Scheduler__c> recordsToUpdate = new list<Core_MDF_Custom_Scheduler__c>();            
        //to start batch job for instance provided in custom scheduler record.
        lstBatch = Core_MDF_CustomSchedulerUtility.startBatchJob();
        //to update status of custom scheduler records.
        recordsToUpdate = Core_MDF_CustomSchedulerUtility.updateStatusForCompletedOrFailedJob();
        //to create custom scheduler records.
        Core_MDF_CustomSchedulerUtility.generateBatchChaining();  
         if(recordsToUpdate != null && recordsToUpdate.size()>0){
            lstBatch.addAll(recordsToUpdate);                
            }            
            try{
                Database.update(lstBatch);  
            }
            catch(exception e){
                Core_MDF_CCP_UtilityClass.logError(e);
                throw e;}
    }
}