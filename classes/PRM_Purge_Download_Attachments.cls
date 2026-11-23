global with sharing class PRM_Purge_Download_Attachments  implements Database.Batchable<Sobject>, Database.Stateful , Schedulable {
    global PRM_Purge_Download_Attachments() {
    }
    public Database.QueryLocator start(Database.BatchableContext bc) {
               
  
    return Database.getQueryLocator([
                    SELECT id,visibility,ContentDocument.id,ContentDocument.CreatedDate , ContentDocument.Title,ContentDocument.LastModifiedDate ,ContentDocument.CreatedBy.name, ContentDocument.ContentSize, ContentDocument.LatestPublishedVersionId, ContentDocument.FileType 
                                      FROM ContentDocumentLink 
                                      WHERE LinkedEntityId in (SELECT ContactId FROM User where IsPortalEnabled =true and IsActive =true) and
                                      (ContentDocument.Title like 'Sales%' or ContentDocument.Title like  'Training%' or ContentDocument.Title like 'CompanyTraining%')   
                                      and ContentDocument.CreatedDate =today]); 
    }
    public void execute(Database.BatchableContext bc, List<ContentDocumentLink> scope) { 
        set<Id> contentids=new set<Id>();
        System.debug('scope\n'+scope);
        for( ContentDocumentLink d:scope){
            contentids.add(d.ContentDocument.id);
        }
       list<contentversion> contentVersionLst=[select id from contentversion 
       where contentdocumentid In: contentids];
        if(!scope.isEmpty()){
            delete scope;
        }
        // if(!contentVersionLst.isEmpty()){
        //     delete contentVersionLst;
        // }
    }
    public void finish(Database.BatchableContext context){
    } 
    
global void execute(SchedulableContext SC) {
    database.executebatch(new PRM_Purge_Download_Attachments());
    }

global static void start(integer day){
    string jobName = 'job name';
    if (day == 0) database.executebatch(new PRM_Purge_Download_Attachments());
else {
    jobName = jobName += ' - ' + datetime.now().format();
    string cron = '0 0' +string.valueof(day)+ '* * ?';
    system.schedule(jobName, cron, new PRM_Purge_Download_Attachments());
    }
}

    
}