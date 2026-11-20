trigger Core_IPS_BckFieldMap_Trigger on Core_IPS_Backend_Field_Map__c (after insert, after update, after delete) {
   
     if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)){
        Core_IPS_New_Backend_System_Handler.afterFmapinsertupdatedelete(trigger.new); 
    }
    
    
    if(Trigger.isAfter && Trigger.isDelete){
        Core_IPS_New_Backend_System_Handler.afterFmapinsertupdatedelete(trigger.old);   
    }
}