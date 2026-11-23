public without sharing class PicklistManagerBackFillBatch implements Queueable, Database.AllowsCallouts{
    PicklistManagerMetadataService.CustomField plParams = new PicklistManagerMetadataService.CustomField();
    PicklistManagerMetadataService.RecordType rtParams = new PicklistManagerMetadataService.RecordType();
    
    public PicklistManagerBackFillBatch(PicklistManagerMetadataService.CustomField params){
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
        catch(exception ex){system.debug('Exception: '+ ex.getMessage() +' ' + ex.getLineNumber());} 
    }
}