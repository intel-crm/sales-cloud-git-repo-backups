/***************************************************************************************************************************************************************************************************
Apex Class Name:   Core_Schedule_Batch_Populate_Territory 
Version     : 1.0 
Created Date: 11 SEP 2015
Function    : Schedulable class for Core_Batch_Populate_Territory.
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Kalpana Choudhary         09/11/2015              Schedulable class for Core_Batch_Populate_Territory.
*****************************************************************************************************************************************************************************************************/
global class Core_Schedule_Batch_Populate_Territory implements Schedulable{
    global void execute(SchedulableContext sc) {
         Core_Batch_Populate_Territory rL = new  Core_Batch_Populate_Territory();
          database.executebatch(rL);
    }
}