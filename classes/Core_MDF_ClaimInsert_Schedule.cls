/************************************************************************************************************************************************************************************
* Class Name  : Core_MDF_ClaimInsert_Schedule 
* Version     : 1.0 
* Created Date: 08-12-2020
* Modification Log :
* Developer                     Date                          Description
* --------------------------------------------------------------------------------------------------------------------------------------------------
* Intel - SM         08-12-2020            Scheduler class to invoke Core_MDF_Batch_ClaimInsert
**************************************************************************************************************************************************************************************/
global without sharing class Core_MDF_ClaimInsert_Schedule implements Schedulable{
    DateTime runStartTime;
    global Core_MDF_ClaimInsert_Schedule() {
       this.runStartTime = null;
    }    
    global Core_MDF_ClaimInsert_Schedule(DateTime runStTime) {
       this.runStartTime = runStTime;
    }    
    global void execute(SchedulableContext sc) {
        Database.executeBatch(new Core_MDF_ClaimInsert_Batch(runStartTime), 200);
    }
}