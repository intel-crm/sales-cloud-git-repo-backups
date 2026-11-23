@RestResource(urlMapping='/sktemp/createcase')
global class SKTemp_createcaseapi {
     @HttpPost
    global static Core_RestAPI_Response doPost(Core_RestAPI_Case_CreateV1_Wrapper newCase){
        System.debug(' request >> '+newCase);
        Core_RestAPI_Response  resp = null;
        SKTemp_createcase handler = new SKTemp_createcase(newCase);
        
        return handler.createCase();
    }

}