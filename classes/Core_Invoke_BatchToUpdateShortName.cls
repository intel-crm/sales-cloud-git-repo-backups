global class Core_Invoke_BatchToUpdateShortName implements schedulable
{
    global void execute(SchedulableContext sc)
    {
        Core_OpportunityLineItem_BatchClass classObj = new Core_OpportunityLineItem_BatchClass();
        system.debug('======'+database.executebatch(classObj,Integer.valueOf(Label.Core_BU_Batch_Size)));
    }
}