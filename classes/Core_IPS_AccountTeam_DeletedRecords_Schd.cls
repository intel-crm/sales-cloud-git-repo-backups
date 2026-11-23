global class Core_IPS_AccountTeam_DeletedRecords_Schd implements Schedulable {
   global void execute(SchedulableContext sc) {
      Core_IPS_AccountTeam_DeletedRecords_Bulk accountTeamDeleteBatch = new Core_IPS_AccountTeam_DeletedRecords_Bulk(); 
      database.executebatch(accountTeamDeleteBatch, 1000);
   }
}