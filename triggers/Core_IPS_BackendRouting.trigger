trigger Core_IPS_BackendRouting on Core_IPS_Backend_Routing__c ( After Insert, After Update) {
    
    if(trigger.isAfter && trigger.isInsert ||trigger.isAfter && trigger.isUpdate ) {
        if(core_IPS_BES_RecursionHandler.isFirstTime){
            core_IPS_BES_RecursionHandler.isFirstTime = false;
            Core_IPS_BES_Outbound_JSON.setOrder(trigger.new);
        }
    }    
}