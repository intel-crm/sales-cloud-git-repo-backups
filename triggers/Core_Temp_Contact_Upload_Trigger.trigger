trigger Core_Temp_Contact_Upload_Trigger on Core_Temp_Contact_Upload__c (after insert, after update) {
    
    
    if(trigger.isBefore){
        Core_Temp_Contact_Dispatcher.beforeMethod(trigger.old, trigger.new, trigger.oldMap, trigger.newMap);
    }
    if(trigger.isAfter){
        Core_Temp_Contact_Dispatcher.afterMethod(trigger.old, trigger.new, trigger.oldMap, trigger.newMap);
    }

}