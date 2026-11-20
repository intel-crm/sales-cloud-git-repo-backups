trigger Core_IPS_BckValueMap_Trigger on Core_IPS_Backend_Value_Map__c (after insert, after update, after delete) {
  
   if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)){
         Core_IPS_New_Backend_System_Handler.afterVmapinsertupdatedelete(Trigger.new);
     }
    
    if(Trigger.isAfter && Trigger.isDelete){
        Core_IPS_New_Backend_System_Handler.afterVmapinsertupdatedelete(Trigger.old);       
    }  
}