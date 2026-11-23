@RestResource(urlMapping='/v1.0/case/*')
Global class ICS_ILM_RESTAPI_CaseDetails {
     private static final DateTime ENTRY_TIME = System.now();
     private static final String RESTAPI_NAME = Core_RestAPI_CaseDetailV1.class.getName();
   @HttpGet
    global static String doGet(){
        //ICS_ILM_RestAPI_CaseDetails_Handler handler = new ICS_ILM_RestAPI_CaseDetails_Handler(); 
        string response = ICS_ILM_RestAPI_CaseDetails_Handler.getCases();
        system.debug('response'+response);
        return response;
    }
}