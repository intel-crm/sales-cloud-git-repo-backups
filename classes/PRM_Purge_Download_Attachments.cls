global with sharing class PRM_Purge_Download_Attachments  implements Database.Batchable<Sobject>, Database.Stateful , Schedulable {
    global PRM_Purge_Download_Attachments() {
    }
    public Database.QueryLocator start(Database.BatchableContext bc) {
        set<id> userContIds = new set<id>();
            for(User u:[SELECT ContactId FROM User where IsPortalEnabled =true and IsActive =true]){
                userContIds.add(u.ContactId);
            }
    //   list<id> contLst = [SELECT id FROM Contact WHERE id in: userContIds ]; 
        return Database.getQueryLocator([
                    SELECT id,visibility,ContentDocument.CreatedDate , ContentDocument.Title,ContentDocument.LastModifiedDate ,ContentDocument.CreatedBy.name, ContentDocument.ContentSize, ContentDocument.LatestPublishedVersionId, ContentDocument.FileType 
                                      FROM ContentDocumentLink 
                                      WHERE LinkedEntityId in: userContIds and
                                      ContentDocument.Title like 'Sales%' and ContentDocument.CreatedDate <=LAST_N_DAYS:7]);
    }
    public void execute(Database.BatchableContext bc, List<ContentDocumentLink> scope) { 
        System.debug('scope\n'+scope);
        if(!scope.isEmpty()){
            delete scope;
        }
    }
    public void finish(Database.BatchableContext context){
    } 
    
global void execute(SchedulableContext SC) {
    database.executebatch(new PRM_Purge_Download_Attachments());
    }

    global static void start(integer hour){
        string jobName = 'job name';
        if (hour == 0) database.executebatch(new PRM_Purge_Download_Attachments());
    else {
        jobName = jobName += ' - ' + datetime.now().format();
        string cron = '0 0 ' + string.valueof(hour) + ' * * ?';
        system.schedule(jobName, cron, new PRM_Purge_Download_Attachments());
    }
    }

    
}