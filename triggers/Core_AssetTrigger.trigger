trigger Core_AssetTrigger on Asset (before insert, before update, before delete, after insert, after update, after delete) {
    if(trigger.isBefore){
     system.debug('===Assetbeforetrigger beforeMethod');
        Core_Asset_Dispatcher.beforeMethod(trigger.old, trigger.new, trigger.oldMap, trigger.newMap);
    }
    if(trigger.isAfter){
     system.debug('===Assetaftertrigger afterMethod');
        Core_Asset_Dispatcher.afterMethod(trigger.old, trigger.new, trigger.oldMap, trigger.newMap);
    }
}