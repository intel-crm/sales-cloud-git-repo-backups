/*-------------------------------------------------------------------------------------------
Apex Class  : Core_Schedule_SendEmail
Version     : 1.0 
Created Date: 11 Nov 2018
Function    : Schedule class to schedule Core_Lead_SLA_SendEmailBatch batch class
Modification Log :
* Developer                  Date                   Description
* ----------------------------------------------------------------------------                 
* Sougata Sarkar            11/11/2018              Original Version
--------------------------------------------------------------------------------------------*/

global class Core_Schedule_SendEmail implements Schedulable {

    global void execute(SchedulableContext sc){
        Database.executeBatch(new Core_Lead_SLA_SendEmailBatch(), 100);
    }
}