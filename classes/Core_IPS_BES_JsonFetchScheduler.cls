public class Core_IPS_BES_JsonFetchScheduler Implements Schedulable {
    public List<Id> recordListId ;
    public Core_IPS_BES_JsonFetchScheduler (List<Id> recordIds){
        this.recordListId = recordIds ;

    }
    public void execute(SchedulableContext sc) {
        // call the getJson method here
       // Core_IPS_BES_JSONTriggerHandler.getJson(recordListId);
    }
    
}