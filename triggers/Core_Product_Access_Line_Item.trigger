trigger Core_Product_Access_Line_Item on Core_IPS_Map_Par_Line_Item__c(after insert, after update, after delete, before insert, before update, before delete) {
    if(trigger.isBefore){
        Core_Product_Access_Line_Item_Dispatcher.beforeMethod(trigger.old, trigger.new, trigger.oldMap, trigger.newMap);
    }
    if(trigger.isAfter){
        Core_Product_Access_Line_Item_Dispatcher.afterMethod(trigger.old, trigger.new, trigger.oldMap, trigger.newMap);
    }    
}