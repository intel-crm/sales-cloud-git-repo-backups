public with sharing class Core_IPS_BES_Error_Log_Handler {
   public static void insertbackendIntegrationEvents(List<Core_IPS_BES_Error_Log__c> newList) {
    List<String> successfailmsg = new List<String>();//ATHR changes-Gangadhar -Begin
    List<Backend_Exception_handling__e> backendIntegrationEventsList = new List<Backend_Exception_handling__e>();
        try {
          //  List<Backend_Exception_handling__e> backendIntegrationEventsList = new List<Backend_Exception_handling__e>();
            for(Core_IPS_BES_Error_Log__c log: newList){
            Backend_Exception_handling__e backEndOutboundIntegrationEvent = new Backend_Exception_handling__e();
            backEndOutboundIntegrationEvent.Core_IPS_Error_Log_Id__c = log.Id;
            backendIntegrationEventsList.add(backEndOutboundIntegrationEvent);
            }
            List<Database.SaveResult> results = EventBus.publish(backendIntegrationEventsList);
            for (Database.SaveResult sr : results) {
                if (sr.isSuccess()) {
                    successfailmsg.add('Success'+sr.getId());
                    System.debug('Successfully published event.');
                    system.debug('-->results'+results);
                } else {
                    for(Database.Error err : sr.getErrors()) {
                        successfailmsg.add('Error returned: ' + err.getStatusCode() + ' - ' +err.getMessage());
                        System.debug('Error returned: ' +
                                     err.getStatusCode() +
                                     ' - ' +
                                     err.getMessage());
                    }
                }  
            }
        } catch(exception e){
            successfailmsg.add('exception'+e.getMessage());
            System.debug('#1 Outbound insertion failed: ' + e.getMessage());
        }
        if(!successfailmsg.isEmpty()){ successfailmsg.clear();}//ATHR changes-Gangadhar -End
   }
}