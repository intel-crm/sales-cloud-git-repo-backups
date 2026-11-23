trigger Core_CaseTrigger on Case (before insert, before update, before delete, after insert, after update, after delete) {
    
    if(trigger.isBefore){     
	    Core_CaseTrigger_Dispatcher.beforeMethod(trigger.oldMap, trigger.newMap, trigger.old , trigger.new);
        /*Start - TWC777-2514 - 08/08/2024 - Vishal - STOWD - Custom Implementation*/
        if(trigger.isBefore && trigger.isUpdate){
            if(!Core_IPS_Status_Ownership_Ctrl_Util.hasHandlerExecuted) {
                Core_IPS_Status_Ownership_Ctrl_Util.handleBeforeUpdate(Trigger.new, Trigger.oldMap);
            }
        
        }
        /*End - TWC777-2514 - 08/08/2024 - Vishal - STOWD - Custom Implementation*/
    }
    if(trigger.isAfter){
	    Core_CaseTrigger_Dispatcher.afterMethod(trigger.oldMap, trigger.newMap, trigger.old, trigger.new);  
    }
  // Addes By Shubham 10/Oct/20205 Hercules Team workflow to Apex trigger
    /*if((trigger.isinsert || trigger.isupdate) && Trigger.isAfter){
        Core_CaseTrigger_Dispatcher.UpdateLastAssignQueufield(trigger.new);     
}*/
    
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
        Core_AAQC_Case_Ask_Commissions_Handler.ShareWithOBOField(trigger.new);
        Core_AAQC_Case_Ask_Commissions_Handler.ShareWithMyManager(trigger.new,null);
    }
    
    //RAR Nov-11-2018 Added call to ShareWithMyManager - US84930
    if(trigger.isAfter && trigger.isUpdate){
        Core_AAQC_Case_Ask_Commissions_Handler.ShareWithOBOField(trigger.new);
        Core_AAQC_Case_Ask_Commissions_Handler.ShareWithMyManager(trigger.new, trigger.oldMap);
    }*/

}