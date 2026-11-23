@RestResource(urlMapping='/IPS_RDC/v1.0/cases/attachments')

global with sharing class Core_IPS_RDC_Attachments {
    
    private static final DateTime ENTRY_TIME = System.now();
    private static final String RESTAPI_NAME= Core_IPS_RDC_Attachments.class.getName();
    
    @HttpPost
    global static Core_RestAPI_Response doPost(Core_IPS_RDC_AttachmentsWrapper caseAtt){
        System.debug('Inside the Post method of RDC Att');
        Core_IPS_RDC_Attachments_Handler handler = new Core_IPS_RDC_Attachments_Handler(ENTRY_TIME, RESTAPI_NAME,caseAtt);
        //Core_IPS_RDC_Attachments_Handler handler = new Core_IPS_RDC_Attachments_Handler();
        Core_RestAPI_Response response = handler.createCaseAttachments();
        //Core_RestAPI_Response response = handler.insertCaseAttachment('5003F000004tx0k');
        System.debug('Response for Post method==>'+response);
        return response;
        
    }
    
}