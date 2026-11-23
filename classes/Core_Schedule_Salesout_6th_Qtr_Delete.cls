/***************************************************************************************************************************************************************************************************
Apex Class Name:   Core_Schedule_Salesout_6th_Qtr_Delete
Version     : 1.0 
Created Date: 1/6/15
Function    : Schedulable class for Core_Batch_Salesout_6th_Quarter_Delete
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Brian Matthews              1/6/15                 Initial Creation
*****************************************************************************************************************************************************************************************************/
global class Core_Schedule_Salesout_6th_Qtr_Delete implements Schedulable{
    global void execute(SchedulableContext sc) {
        Database.executebatch(new Core_Batch_Salesout_6th_Qtr_Delete(), 200);        
    }
}