/********************************************************************************************************************************************************************
Apex Class Name:  Core_Opp_LastActvityDt_Schedule
Version     : 1.0 
Created Date: 15/04/2020
Function    : Schedule class for Core_Opp_LastActvityUpdate_Batch batch class

Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Mahesh Manikonda               15/04/2020               Original Version developed
*******************************************************************************************************************************************************************/
global without sharing class Core_Opp_LastActvityDt_Schedule  implements Schedulable { //TWC3123-5359 Added without sharing keyword to fix code scan issue

        global void execute(SchedulableContext sc) {
        Database.executeBatch(new Core_Opp_LastActvityUpdate_Batch(), 200);
    }
}