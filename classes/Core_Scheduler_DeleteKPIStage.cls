/********************************************************************************************************************************************************************
Apex Class Name:  Core_Scheduler_DeleteKPIStage
Version     : 1.0 
Created Date:  04/02/2021
Function    : Schedules the deletion of KPI Staging records which were created older than 90 days from today

Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Sanket Mahajan             04/02/2021               Original Version developed
*******************************************************************************************************************************************************************/
public without sharing class Core_Scheduler_DeleteKPIStage implements Schedulable{

    public void execute(SchedulableContext sc) {
        Database.executeBatch(new Core_Batch_KPIStageDelete(), 200);
    }
}