trigger Core_DDR_Design_Trigger on Core_Design_Registration__c (before insert, before update, after insert, after update)
{   
    
    Boolean newTrigger = Boolean.valueOf(System.Label.CORE_DDR_New_Trigger_Switch);
    if(LabelConfiguration__mdt.getInstance('BypassAutomationCP')==null || (LabelConfiguration__mdt.getInstance('BypassAutomationCP')!=null && (String)LabelConfiguration__mdt.getInstance('BypassAutomationCP').value__c !=null && !FeatureManagement.checkPermission((String)LabelConfiguration__mdt.getInstance('BypassAutomationCP').value__c))){
        if(newTrigger){
            new CORE_DDR_TriggerHandler().run();
        }
        }
}