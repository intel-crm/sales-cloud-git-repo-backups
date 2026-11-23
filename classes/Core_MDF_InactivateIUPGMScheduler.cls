/****************************************************************************************************************************************
* Class Name        : Core_MDF_InactivateIUPGMScheduler
* Created Date      : 09-03-2019
* Modification Log
* Developer            Date               Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture - VK       09-03-2019         It is the Schedulable class which calls the batch job to inactivate IUPGM records when user is 
										  deactivated
*****************************************************************************************************************************************/
global class Core_MDF_InactivateIUPGMScheduler implements Schedulable{
    global void execute (SchedulableContext SC){
        Core_MDF_InactivateIUPGM inactivateIUPGM = new  Core_MDF_InactivateIUPGM();
        Database.executeBatch(inactivateIUPGM);
    }
}