trigger Pricing_TrackAttachmentDeletion on Attachment (after Delete) {

   /* Map<Id,String> deleteddetails = new Map<Id,String>();
    Map<Id,SBQQ__Quote__c> quotesMap = new Map<Id,SBQQ__Quote__c>();
    String deletionLog;
    Id quoteId;
    for (Attachment att : Trigger.old) {
         deletionLog = 'File Deleted: ' + att.Name + ' | ParentId: ' + att.ParentId + ' | DeletedBy: ' + UserInfo.getUserId() + ' | Date: ' + System.now();
        deleteddetails.put(att.ParentId,deletionLog);
        quoteId = att.ParentId;
         
        //Pricing_TrackAttachmentDeletionHandler.addDeletedLog(att.ParentId,deletionLog);
    }
    //Pricing_TrackAttachmentDeletionHandler.addDeletedLog(quoteId,deletionLog);
    for(SBQQ__Quote__c quote : [SELECT Id, Name FROM SBQQ__Quote__c where Pricing_Quote_Program_Nm__c = 'Tender']){
        
    }
    system.debug('deletionLog:'+deletionLog);*/
}