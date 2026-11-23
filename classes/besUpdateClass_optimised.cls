public class besUpdateClass_optimised implements Database.Batchable<Id>,Database.AllowsCallouts {
    Public List<Id> recordIdList;
    public besUpdateClass_optimised(List<Id> recordIdLst){
        this.recordIdList= recordIdLst;
		System.debug('recordIdLst'+recordIdLst);
       
    }
     public Iterable<Id> start(Database.BatchableContext BC) {
        return recordIdList;
    }

    public void execute(Database.BatchableContext BC, List<Id> scope) {
    try{
		System.debug('runing main batch');

       // Core_IPS_BES_JSONTriggerHandler.getJson1(scope);
        }catch(exception e){}
        finally {
   
    //        List<Core_IPS_BES_Handle_HeapSize__e> backendIntegrationEventsList = new List<Core_IPS_BES_Handle_HeapSize__e>();
    //         Core_IPS_BES_Handle_HeapSize__e heape = new Core_IPS_BES_Handle_HeapSize__e();
    //         heape.Platform_Event_Error_Name__c ='test';
    //            backendIntegrationEventsList.add(heape);
    //             List<Database.SaveResult> results = EventBus.publish(backendIntegrationEventsList);
    //             for (Database.SaveResult sr : results) {
    //                 if (sr.isSuccess()) {
    //                     System.debug('Successfully published event.');
    //                 } else {
    //                     for(Database.Error err : sr.getErrors()) {
    //                         System.debug('Error returned: ' + err.getStatusCode() );
    //                     }
    
    //                 }
    //             }
    }
    }
     public void finish(Database.BatchableContext BC) {
     }
}