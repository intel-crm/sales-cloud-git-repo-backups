global without sharing class Core_IPS_AccountTeamScheduler implements Schedulable {
   global void execute(SchedulableContext sc) {
      Core_IPS_AccountTeamUpdate_Scheduler accountTeamBatch = new Core_IPS_AccountTeamUpdate_Scheduler(); 
      database.executebatch(accountTeamBatch,1);
   }
}