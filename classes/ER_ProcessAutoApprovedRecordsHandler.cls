public class ER_ProcessAutoApprovedRecordsHandler extends TriggerHandler
{
    public override void afterInsert() 
    {
        system.debug('AssignABTandCBT');
        ER_ProcessAutoApprovedRecordsUtility.AssignABTandCBT((List<ProcessAutoApprovedRecords__e>)Trigger.new);
    }

}