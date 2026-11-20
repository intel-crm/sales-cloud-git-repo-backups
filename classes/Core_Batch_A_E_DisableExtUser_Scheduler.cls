/**************************************************************************************************************************************************
* Apex Class Name : Core_Batch_A_E_DisableExtUser_Scheduler
* Created Date: 25/09/2020 
* Description : Scheduler class to Schedule Core_Batch_A_E_DisableExtUser class 
* Developer                 Date                     Description
* -------------------------------------------------------------------------------------------------------------------------------------------------
* Sonali Mehetre            25/09/2020               US731342 - Pipeline: IPS Issue fix implementation
*************************************************************************************************************************************************/
global without sharing class Core_Batch_A_E_DisableExtUser_Scheduler implements Schedulable {
    global void execute(SchedulableContext sc){
        Core_Batch_A_E_DisableExtUser classCon = new Core_Batch_A_E_DisableExtUser();       
        //Parameters of ExecuteBatch(Classcontext,BatchSize)
        //Integer batchSize = 200;
        database.executebatch(classCon);        
    }
}