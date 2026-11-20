trigger Core_IPS_ErrorTrigger on Core_IPS_BES_Error_Log__c (after insert) {
    // ATHR Fix - TWC745-7150 - Shipra
    if(trigger.isAfter){
        Core_IPS_BES_Error_Log_Dispatcher.afterMethod(trigger.new);
    }
}
    // List<Backend_Exception_handling__e> backendIntegrationEventsList = new List<Backend_Exception_handling__e>();
    //     try {
    //         List<Backend_Exception_handling__e> backendIntegrationEventsList = new List<Backend_Exception_handling__e>();
    //         for(Core_IPS_BES_Error_Log__c log: Trigger.new){
    //         Backend_Exception_handling__e backEndOutboundIntegrationEvent = new Backend_Exception_handling__e();
    //         backEndOutboundIntegrationEvent.Core_IPS_Error_Log_Id__c = log.Id;
    //         backendIntegrationEventsList.add(backEndOutboundIntegrationEvent);
    //         }
    //         List<Database.SaveResult> results = EventBus.publish(backendIntegrationEventsList);
    //         for (Database.SaveResult sr : results) {
    //             if (sr.isSuccess()) {
    //                 System.debug('Successfully published event.');
    //                 system.debug('-->results'+results);
    //             } else {
    //                 for(Database.Error err : sr.getErrors()) {
    //                     System.debug('Error returned: ' +
    //                                  err.getStatusCode() +
    //                                  ' - ' +
    //                                  err.getMessage());
    //                 }
    //             }  
    //         }
    //     } catch(exception e){
    //         System.debug('#1 Outbound insertion failed: ' + e.getMessage());
    //     }