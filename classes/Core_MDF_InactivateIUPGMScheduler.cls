/****************************************************************************************************************************************
* Class Name        : Core_MDF_InactivateIUPGMScheduler
* Created Date      : 09-03-2019
* Modification Log
* Developer            Date               Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture - VK       09-03-2019         It is the Schedulable class which calls the batch job to inactivate IUPGM records when user is 
                                          deactivated
*****************************************************************************************************************************************/
//global class Core_MDF_InactivateIUPGMScheduler implements Schedulable{
/* US930208-  Added without sharing keyword to fix checkmarx issue */
global without sharing class Core_MDF_InactivateIUPGMScheduler implements Schedulable {
    
    DateTime runStartTime;
    global Core_MDF_InactivateIUPGMScheduler() {
       this.runStartTime = null;
    }    
    global Core_MDF_InactivateIUPGMScheduler(DateTime runStTime) {
       this.runStartTime = runStTime;
    } 
    
    global void execute (SchedulableContext sc) {
        Core_MDF_InactivateIUPGM inactivateIUPGM = new  Core_MDF_InactivateIUPGM();
        Database.executeBatch(inactivateIUPGM);
    }
}