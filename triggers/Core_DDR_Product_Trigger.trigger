trigger Core_DDR_Product_Trigger on Core_Design_Registration_Product__c (before insert, after insert, after update)
{
    if(Trigger.isInsert)
    {
        if(trigger.isBefore)
        {
            Core_DDR_Product_Handler.processBeforeInsert(trigger.old, trigger.new, trigger.oldMap, trigger.newMap);
        }
        else if(trigger.isAfter)
        {
            Core_DDR_Product_Handler.processAfterInsert(trigger.old, trigger.new, trigger.oldMap, trigger.newMap);
        }
    }
}