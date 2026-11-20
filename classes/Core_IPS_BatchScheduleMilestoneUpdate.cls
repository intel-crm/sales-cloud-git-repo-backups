global with sharing class Core_IPS_BatchScheduleMilestoneUpdate implements Schedulable
{
    global void execute(SchedulableContext sc)
    {
        
        Core_IPS_Entitlement_For_Migrated_Cases b = new Core_IPS_Entitlement_For_Migrated_Cases();
        
       
        database.executebatch(b,Integer.valueof(System.Label.Core_IPS_Case_Milestone_Batch_Size));
    }
    
}