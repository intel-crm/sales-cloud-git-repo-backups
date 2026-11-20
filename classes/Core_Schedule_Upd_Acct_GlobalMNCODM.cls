/***************************************************************************************************************************************************************************************************
Apex Class Name:   Core_Schedule_Upd_Acct_GlobalMNCODM
Version     : 1.0 
Created Date: 3/21/16
Function    : Schedulable class for Core_Batch_Upd_Acct_GlobalMNCODM
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Shailaja Gandam           3/21/16                 Initial Creation
*****************************************************************************************************************************************************************************************************/
global class Core_Schedule_Upd_Acct_GlobalMNCODM implements Schedulable{
    global void execute(SchedulableContext sc) {
        Database.executebatch(new Core_Batch_Upd_Acct_GlobalMNCODM());        
    }
}