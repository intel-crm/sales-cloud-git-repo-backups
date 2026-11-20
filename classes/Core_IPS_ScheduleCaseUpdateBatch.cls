/***************************************************************************************************
* Class Name          : Core_IPS_ScheduleCaseUpdateBatch 
* Version             : 1.0 
*Description          : Schedule to weekly run Core_IPS_CaseUpdateBatch to update managers in case
* Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                    
* Amritesh                    10/19/2018             Created US194563
****************************************************************************************************/ 
global without sharing class Core_IPS_ScheduleCaseUpdateBatch implements Schedulable {
   global static String CRON_EXP = '0 0 0 ? * SUN';
   global void execute(SchedulableContext sc) {
      Core_IPS_CaseUpdateBatch b = new Core_IPS_CaseUpdateBatch(Core_IPS_CaseUpdateBatch.batchMode.ManagerUpdate); 
      database.executebatch(b);
   }
}