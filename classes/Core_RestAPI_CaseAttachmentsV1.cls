/****************************************************************************************************************************************
* Class Name  : Core_RestAPI_CaseAttachmentsV1
* Version     : 1.0 
* Created Date: 3 Jan 2018
* Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Team: PopcornApps         1/3/2018              Rest API class retrieves attachments of case for the given caseNumber 
*****************************************************************************************************************************************/
@RestResource(urlMapping='/v1.0/cases/*/attachments') 
global with sharing  class Core_RestAPI_CaseAttachmentsV1 {
    private static final DateTime ENTRY_TIME = System.now();
    private static final String RESTAPI_NAME= Core_RestAPI_CaseAttachmentsV1.class.getName();
    
    @HttpGet
    global static Core_RestAPI_Response doGet(){
        Core_RestAPI_CaseAttachmentV1_Handler handler = new Core_RestAPI_CaseAttachmentV1_Handler(ENTRY_TIME, RESTAPI_NAME); 
        Core_RestAPI_Response response = handler.getCaseAttachments();
        return response;
    }
    
    @HttpPost
    global static Core_RestAPI_Response doPost(Core_RestAPI_AttachmentV1_Wrapper attachmentInfo){
        Core_RestAPI_AttachmentV1_Handler handler = new Core_RestAPI_AttachmentV1_Handler(ENTRY_TIME, RESTAPI_NAME, attachmentInfo);
        Core_RestAPI_Response response = handler.createAttachment();
        return response;
    }
}