/************************************************************************************************************************************************************************************
* Class Name  : Core_MDF_Scheduler_IAH_Pull 
* Version     : 1.0 
* Created Date: 03-07-2022
* Modification Log :
* Developer                     Date                          Description
* --------------------------------------------------------------------------------------------------------------------------------------------------
* Intel - Navneet 		03-07-2022					  Scheduler class to invoke Core_MDF_Batch_IAH_Pull 
*********************************************************************************************************************************************************/
public without sharing class Core_MDF_Scheduler_IAH_Pull implements Schedulable {
	    public void execute(SchedulableContext sc)
        {
            Core_MDF_Batch_IAH_Pull batch = new Core_MDF_Batch_IAH_Pull();
            Database.executeBatch(batch);
        }

}