public without sharing class PicklistManagerBackFillBatch implements Queueable, Database.AllowsCallouts{
    PicklistManagerMetadataService.CustomField plParams = new PicklistManagerMetadataService.CustomField();
    PicklistManagerMetadataService.RecordType rtParams = new PicklistManagerMetadataService.RecordType();
    
    public PicklistManagerBackFillBatch(PicklistManagerMetadataService.CustomField params){
       	system.debug('INSIDE BACKFILL BATCH CONSTRUCTOR');
        this.plParams = params;
    }
    
    public PicklistManagerBackFillBatch(PicklistManagerMetadataService.RecordType params){
        this.rtParams = params;
    }
    
    public void execute(QueueableContext context) {
        system.debug('Queue class:'+plParams );
        PicklistManagerMetadataService.MetadataPort service = PicklistManager.createService();
        try{
            if(plParams != null){
                List<PicklistManagerMetadataService.SaveResult> saveResults = service.updateMetadata(new PicklistManagerMetadataService.CustomField[] { plParams });    
            }
            else if(rtParams != null){
                List<PicklistManagerMetadataService.SaveResult> saveResults = service.updateRTMetadata(new PicklistManagerMetadataService.RecordType[] { rtParams });
            }    
        }
        catch(exception ex){
            system.debug('Exception: '+ ex.getMessage() +' ' + ex.getLineNumber());
        }
        PicklistManagerBackFillBatchFinalizer finalizer = new PicklistManagerBackFillBatchFinalizer();
        System.attachFinalizer(finalizer);
}
public class PicklistManagerBackFillBatchFinalizer implements Finalizer{
     public void execute(FinalizerContext fc){
            // Query the AsyncApexJob object to retrieve the current job's information.  
            system.debug('SMART PICKLIST FINISH METHOD');
            AsyncApexJob a = [Select Id, Status,ExtendedStatus,NumberOfErrors, JobItemsProcessed,
            TotalJobItems, CreatedBy.Email
            from AsyncApexJob where Id =:fc.getAsyncApexJobId()];
            system.debug('APEX JOB STATUS:'+a);
            
            // Send an email to the Apex job's submitter notifying of job completion.  
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                String[] toAddresses = new String[] {UserInfo.getUserEmail()};
                system.debug('TOADDRESS:'+toAddresses);
                mail.setToAddresses(toAddresses);
                mail.setSubject('Smart Picklist Batch Status');
                mail.setPlainTextBody('The batch Apex job processed ' + a.TotalJobItems +
               ' batches with '+ a.NumberOfErrors + ' failures.');
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
         		
        }
}
}