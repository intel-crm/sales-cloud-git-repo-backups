global class Schedulable_Update_Sub_Status implements schedulable
{
   global void execute(SchedulableContext sc)
   {
   Core_IPS_Update_Sub_Status updateSubStatus = new Core_IPS_Update_Sub_Status();
   Database.executeBatch(updateSubStatus);    
   }
}