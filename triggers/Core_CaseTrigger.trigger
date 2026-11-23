trigger Core_CaseTrigger on Case (before insert, before update, before delete, after insert, after update, after delete) {
    if(trigger.isBefore){ 
        //system.debug('before calling dispatcher===Casebeforetrigger beforeMethod===>'+Trigger.new);
        system.debug('before calling dispatcher===Casebeforetrigger beforeMethod===>');
        Core_CaseTrigger_Dispatcher.beforeMethod(trigger.oldMap, trigger.newMap, trigger.old , trigger.new);
        
      

        //system.debug('Casebeforetrigger beforeMethod===>'+Trigger.new);
        system.debug('Casebeforetrigger beforeMethod===>');
    }
    if(trigger.isAfter){
        //system.debug('Before calling dispatcher===Caseaftertrigger afterMethod===>'+Trigger.new);
        system.debug('Before calling dispatcher===Caseaftertrigger afterMethod===>');
        Core_CaseTrigger_Dispatcher.afterMethod(trigger.oldMap, trigger.newMap, trigger.old, trigger.new);
        //system.debug('===Caseaftertrigger afterMethod===>'+Trigger.new);
        system.debug('===Caseaftertrigger afterMethod===>');
    }
    
    /*
    // Below lines of Code written for Ask Commission Project
    
    if(trigger.isBefore && trigger.isInsert){
        Core_AAQC_Case_Ask_Commissions_Handler.UpdateCreatedByManagerEmail(trigger.new, null);
    }
    
    if(trigger.isBefore && trigger.isUpdate){
        Core_AAQC_Case_Ask_Commissions_Handler.UpdateCreatedByManagerEmail(trigger.new, trigger.oldMap);
    }
    
    /*
    
    User story – US84930 and US76746 - this feature hasn’t been approved by Security council. So this part of the code is commented out. 
    
    //RAR Nov-11-2018 Added call to ShareWithMyManager - US84930
    if(trigger.isAfter && trigger.isInsert){
        system.debug('===Before calling ShareWithMyManager ===Caseaftertrigger afterMethod===>'+trigger.oldMap);    
        Core_AAQC_Case_Ask_Commissions_Handler.ShareWithOBOField(trigger.new);
        Core_AAQC_Case_Ask_Commissions_Handler.ShareWithMyManager(trigger.new,null);
        system.debug('===After calling ShareWithMyManager ===Caseaftertrigger afterMethod===>'+Trigger.new);        
    }
    
    //RAR Nov-11-2018 Added call to ShareWithMyManager - US84930
    if(trigger.isAfter && trigger.isUpdate){
        system.debug('===Before calling ShareWithMyManager ===Caseaftertrigger afterMethod===>'+Trigger.new);
        Core_AAQC_Case_Ask_Commissions_Handler.ShareWithOBOField(trigger.new);
        Core_AAQC_Case_Ask_Commissions_Handler.ShareWithMyManager(trigger.new, trigger.oldMap);
        system.debug('===After calling ShareWithMyManager ===Caseaftertrigger afterMethod===>'+Trigger.new);        
    }*/

}