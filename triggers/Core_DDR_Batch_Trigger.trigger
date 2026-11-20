trigger Core_DDR_Batch_Trigger on Core_Design_Registration_Batch__c (before insert, before update, after insert, after update) {
    
    if (Trigger.isAfter) {
        
        if (Trigger.isInsert) {
            Core_DDR_Batch_Handler.processAfterInsert(trigger.new, trigger.old);
        }
               
    }   
}