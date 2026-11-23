@RestResource(urlMapping='/skpoc/poc/*')
global class SKTemp_Rest {
   
    
     @HttpPatch
    global static Core_RestAPI_Response  doPatch(Core_RestAPI_Case_UpdateV1_Wrapper caseDetail){
        Core_RestAPI_Response  resp = null;
        System.debug(' RestContext.request >> '+Json.serialize(RestContext.request));
        System.debug(' request Wrapper >> '+Json.serialize(caseDetail));
        System.debug('caseDetail ==>> '+caseDetail);
        Core_RestAPI_Case_UpdateV1_Handler_BAKUP handler = new Core_RestAPI_Case_UpdateV1_Handler_BAKUP('SKTemp_Rest', System.now(), caseDetail);
        Core_RestAPI_Response response = handler.updateCase();
        return response;
    }
    
    
}