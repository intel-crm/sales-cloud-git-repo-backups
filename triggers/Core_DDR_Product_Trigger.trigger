trigger Core_DDR_Product_Trigger on Core_Design_Registration_Product__c (before insert, after insert, before update, after update)
{
    if(LabelConfiguration__mdt.getInstance('BypassAutomationCP')==null || (LabelConfiguration__mdt.getInstance('BypassAutomationCP')!=null && (String)LabelConfiguration__mdt.getInstance('BypassAutomationCP').value__c !=null && !FeatureManagement.checkPermission((String)LabelConfiguration__mdt.getInstance('BypassAutomationCP').value__c))){
        if(LabelConfiguration__mdt.getInstance('inactive_DRP_Trigger')!=null || (LabelConfiguration__mdt.getInstance('inactive_DRP_Trigger') !=null && !Boolean.valueOf(LabelConfiguration__mdt.getInstance('inactive_DRP_Trigger').value__c))){
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
            
            else if(Trigger.isUpdate)
            {
                if(trigger.isBefore)
                {
                    Core_DDR_Product_Handler.processBeforeUpdate(trigger.old, trigger.new, trigger.oldMap, trigger.newMap);
                }else if(trigger.isAfter){
                    Core_DDR_Product_Handler.processAfterUpdate(trigger.old, trigger.new, trigger.oldMap, trigger.newMap);
                    
                }
            }
        }
    }
}