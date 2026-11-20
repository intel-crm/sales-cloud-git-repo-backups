public class ER_ProcessAutoApprovedRecordsHandler extends TriggerHandler
{
    public override void afterInsert() 
    {
        ER_ProcessAutoApprovedRecordsUtility.AssignABTandCBT((List<ProcessAutoApprovedRecords__e>)Trigger.new);
    }

}