global class Intrested_Party_Update_Queueable implements Database.Batchable<sObject> {
    private Set<Id> inactiveuser;
        public Intrested_Party_Update_Queueable(Set<Id> lstInactivatedUsers) {
        System.debug('inside constructor>>>>>'+lstInactivatedUsers);
        this.inactiveuser = lstInactivatedUsers;
    }
    global Database.QueryLocator start(Database.BatchableContext bc){
        //String query = 'SELECT Id,Active__c FROM Core_IPS_Case_Interested_Party__c WHERE Type__c IN (\'Internal\', \'External\') AND User__c IN :inactiveuser AND Active__c = true';
        String query = 'SELECT Id,Active__c FROM Core_IPS_Case_Interested_Party__c WHERE Type__c IN (\'Internal\', \'External\') AND User__c IN :inactiveuser AND Active__c = true and Case__r.Core_IPS_Case_Owner_Groups__r.Name !=null and Case__r.Core_IPS_Case_Owner_Groups__r.Core_IPS_Case_Owner__r.Id !=null ';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc,List<Core_IPS_Case_Interested_Party__c> IP){
        for(Core_IPS_Case_Interested_Party__c ipc : IP){
            ipc.Active__c=false;
        }
        if(!IP.isEmpty()){
            update IP;
        }
    }
    
    global void finish(Database.BatchableContext bc){
        System.debug('updation complete');
    }
    
}

/*public class Intrested_Party_Update_Queueable implements Queueable {
   // private List<Id> activeuser;
    private Set<Id> inactiveuser;
        public Intrested_Party_Update_Queueable(Set<Id> lstInactivatedUsers) {
        System.debug('inside constructor>>>>>'+lstInactivatedUsers);
        this.inactiveuser = lstInactivatedUsers;
    }

    public void execute(QueueableContext context) {
        System.debug('inside 111');

        if (inactiveuser != null && !inactiveuser.isEmpty()) {
            List<Core_IPS_Case_Interested_Party__c> lstCaseInterestedParty2Inactivate = [
                SELECT Id 
                FROM Core_IPS_Case_Interested_Party__c 
                WHERE Type__c IN ('Internal', 'External') 
                AND User__c IN :inactiveuser 
                AND Active__c = true
            ];
              System.debug('list od Intrested party>>>'+lstCaseInterestedParty2Inactivate);
            for (Core_IPS_Case_Interested_Party__c objIP : lstCaseInterestedParty2Inactivate) {
                objIP.Active__c = false;
            }

            if (!lstCaseInterestedParty2Inactivate.isEmpty()) {
                update lstCaseInterestedParty2Inactivate;
            }
            System.debug('finish Deactivation of Intrested party');
        }
    }
}
*/