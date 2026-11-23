/********************************************************************************************************************************************************************
Apex Class Name:  Core_Scheduler_DeleteKPIInt
Version     : 1.0 
Created Date: 03/12/2020
Function    : Schedules the deletion of KPI Integration records which were created older than 90 days from today

Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Ashwin Dash               03/12/2020               Original Version developed
*******************************************************************************************************************************************************************/
public without sharing class Core_Scheduler_DeleteKPIInt implements Schedulable{

    public void execute(SchedulableContext sc) {
        Database.executeBatch(new Core_DeleteKPIInt_Batch(), 200);
    }
}