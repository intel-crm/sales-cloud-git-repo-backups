public class PRMRegistrationRequestTriggerHandler {

    // If you later want to watch more fields, add their API names here.
    private static final Set<String> WATCH_FIELDS = new Set<String>{
        'PRM_Account_Name__c'
    };

    public static void handleAfter(
        List<PRM_Registration_Request__c> newRecs,
        Map<Id, PRM_Registration_Request__c> oldMap,
        Boolean isInsert,
        Boolean isUpdate
    ){
        List<Id> toProcess = new List<Id>();

        for (PRM_Registration_Request__c r : newRecs) {
            if (isInsert) {
                toProcess.add(r.Id);
            } else if (isUpdate) {
                PRM_Registration_Request__c oldR = oldMap.get(r.Id);
                // Enqueue only if a watched field actually changed
                for (String f : WATCH_FIELDS) {
                    if (String.valueOf(r.get(f)) != String.valueOf(oldR.get(f))) {
                        toProcess.add(r.Id);
                        break;
                    }
                }
            }
        }

        if (!toProcess.isEmpty()) {
            //System.enqueueJob(new PRMRegistrationSyncJob(toProcess));
        }
         /* List<Core_CDB_Platform_Event__e> events = new List<Core_CDB_Platform_Event__e>();
        for (PRM_Registration_Request__c regReq : (List<PRM_Registration_Request__c>)Trigger.new) {
            system.debug('regReq.PRM_Status__c>>'+regReq.PRM_Status__c);
            if(Trigger.isAfter && Trigger.isInsert && regReq.PRM_Status__c=='New'){
                events.add(new Core_CDB_Platform_Event__e(
                    Core_Record_Id__c = regReq.Id
                    
                ));
            }
        }
        if (!events.isEmpty()) {
            Database.SaveResult[] results = EventBus.publish(events);
            System.debug('Published Events: ' + results.size());
    }*/
    }
}