/**************************************************************************************
Apex Class Name : Core_Batch_A_E_PermSet_Mgmt_Scheduler
Version     : 1.0 
Created Date: 30th March 2020
Description : Scheduler class to Schedule Core_AssignRemove_PermissionSet_Batch class
* Modification Log :
* Developer                 Date                     Description
* ----------------------------------------------------------------------------
* Vaibhav                  30/03/2020             Original Version
*************************************************************************************/

global without sharing class Core_Batch_A_E_PermSet_Mgmt_Scheduler implements Schedulable {
    global void execute(SchedulableContext sc){
        Core_Batch_A_E_PermSet_Mgmt classCon = new Core_Batch_A_E_PermSet_Mgmt();       
        //Parameters of ExecuteBatch(Classcontext,BatchSize)
        //Integer batchSize = 200;
        database.executebatch(classCon);
    }
   
}