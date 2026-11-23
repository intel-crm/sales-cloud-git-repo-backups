trigger PRM_NewRegCDBEventTrigger on PRM_CDB_Platform_Event__e (after insert) {
     public static Final String ORIGIN  = 'PRM_NewRegCDBEventTrigger';
    public static Final String SEVERITY  = 'Error';
    public static Final String PROJECT  = 'IPA';
    public static final String SCOPE    = 'PRM_NewRegCDBEventTrigger';
    System.debug('### Event Trigger Fired, Size: ' + Trigger.new.size());
    
    
    // Collect all event record IDs first to avoid SOQL in loop
    Set<Id> eventRecordIds = new Set<Id>();
    for (PRM_CDB_Platform_Event__e evt : Trigger.new) {
        if (evt.Core_Record_Id__c != null && !String.isEmpty(evt.Core_Record_Id__c)) {
            eventRecordIds.add(evt.Core_Record_Id__c);
        }
    }
    
    // Query all related records in one SOQL statement
    List<PRM_Registration_Request__c> newRegList = new List<PRM_Registration_Request__c>();
    if (!eventRecordIds.isEmpty()) {
        newRegList = [SELECT Id FROM PRM_Registration_Request__c WHERE Id IN :eventRecordIds];
    } 
    
    
    /* List<Core_CDB_Platform_Event__e> eventList = Trigger.new;

for (Core_CDB_Platform_Event__e evt : eventList) {

List<PRM_Registration_Request__c> newRegList = new  List<PRM_Registration_Request__c>();
try {
string newRegId=evt.Core_Record_Id__c;

if(!String.isEmpty(newRegId)){

newRegList= [select id from PRM_Registration_Request__c where id =: newRegId];
}*/
    
    System.debug('RegList>> : ' + newRegList);
    try {
        PRM_CDB_CompanyValidation_APICallout.processWebsiteValidationRequest(newRegList);
    } catch (Exception ex) {
        Core_Log_Entry.logEntryWithException(ORIGIN, PROJECT, SCOPE, SEVERITY,'', ex.getMessage() ,'' ,'PRM_NewRegCDBEventTrigger' ,'' ,ex);  
        System.debug('Error processing Core_CDB_Platform_Event in event trigger : ' + ex.getMessage());
    }

}