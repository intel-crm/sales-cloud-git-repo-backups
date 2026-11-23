/********************************************************************************************************************************************************************
Apex Class Name:  Core_Oppty_LastActvityDt_Schedule
Version     : 1.0 
Created Date: 17/09/2022
Function    : Schedule class for Core_Oppty_LastActvityUpdate_Batch batch class

Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Mua Yeshwanth               17/09/2022              Original Version developed
*******************************************************************************************************************************************************************/
global without sharing class Core_Oppty_LastActvityDt_Schedule  implements Schedulable {//TWC3123-5359 included without sharing

        global void execute(SchedulableContext sc) {
        Database.executeBatch(new Core_Opp_OLI_LastActvityUpdate_Batch(), 200);
    }
}