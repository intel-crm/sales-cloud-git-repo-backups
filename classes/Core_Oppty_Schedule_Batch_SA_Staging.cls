global class Core_Oppty_Schedule_Batch_SA_Staging implements Schedulable {
	global void execute(SchedulableContext sc)
     {
     Core_OpptyBatch_Del_Inactive_rec b = new Core_OpptyBatch_Del_Inactive_rec(); 
     database.executeBatch(b);
     }
}