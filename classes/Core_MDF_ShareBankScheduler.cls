/****************************************************************************************************************************************
* Class Name        : Core_MDF_ShareBankScheduler
* Created Date      : 11-30-2018
* Modification Log
* Developer            Date               Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture - SB       01/15/2019          It is the Schedulable class which calls the batch job to share bank record with user when they are elevated 
										   with AccountBudgetAdmin Permission Set.
*****************************************************************************************************************************************/
global class Core_MDF_ShareBankScheduler implements Schedulable{
    global void execute (SchedulableContext SC){
        Core_MDF_ShareBanktoBudgetAdmins b1 = new  Core_MDF_ShareBanktoBudgetAdmins();
        Database.executeBatch(b1);
    }
}