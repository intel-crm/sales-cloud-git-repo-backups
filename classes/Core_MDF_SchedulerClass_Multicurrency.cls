/************************************************************************************************************************************************************************************
* Class Name  : Core_MDF_SchedulerClass_Multicurrency 
* Version     : 1.0 
* Created Date: 11-29-2018
* Modification Log :
* Developer                     Date                          Description
* --------------------------------------------------------------------------------------------------------------------------------------------------
* Intel - Narayani Perachi      11-29-2018                    Scheduler class to invoke Core_MDF_BatchClass_Multicurrency
**************************************************************************************************************************************************************************************/
public without sharing class Core_MDF_SchedulerClass_Multicurrency implements Schedulable{
    
    public void execute(SchedulableContext sc)
        {
            Core_MDF_BatchClass_Multicurrency batch = new Core_MDF_BatchClass_Multicurrency();
            Database.executeBatch(batch, 100);
            //system.debug('Scheduler class');
        }

}