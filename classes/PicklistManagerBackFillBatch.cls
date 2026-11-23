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
         /*try{
                    HttpRequest req= new HttpRequest();
                    HttpResponse response = new HttpResponse();
                    Http http = new Http();
                   	String serializedWrapper = JSON.serialize(plParams);  
                    req.setEndpoint('callout:SmartPicklist_Named_Cred/services/apexrest/TargetEndPoint/');
                    req.setHeader('content-type','application/json; charset=UTF-8');
                    req.setHeader('Accept', 'application/json');
                    req.setMethod('POST');
                    req.setBody(serializedWrapper);
                    response = http.send(req);
                    if (response.getStatusCode() == 200) {
                        String jsonResponse = response.getBody();
                        System.debug('Response-' + jsonResponse);
                    }
                }
                catch(Exception ex){
                    system.debug('Exception: '+ ex.getMessage() +' ' + ex.getLineNumber());
                }*/
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