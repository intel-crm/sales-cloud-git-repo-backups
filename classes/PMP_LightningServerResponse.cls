/*
 * Class Name    : PMP_LightningServerResponse
 * Description   : class created to send response information requested by any lightning component to client
*/
 
public with sharing class PMP_LightningServerResponse{
    @AuraEnabled public Boolean isSuccessful {get; private set;}
    @AuraEnabled public map<String, Object> mapErrorInfo { get; private set; }
    @AuraEnabled public map<String, Object> objectData { get; private set; }
    
    //Overloading constructor with different input parameters
    
    public PMP_LightningServerResponse(Boolean isSuccessful, map<String, Object> mapErrorInfo, map<String, Object> objectData) {
        this.isSuccessful = isSuccessful;
        this.mapErrorInfo = mapErrorInfo;
        this.objectData = objectData;
    }
    

    public PMP_LightningServerResponse() {
        this.isSuccessful = isSuccessful;
    }
}