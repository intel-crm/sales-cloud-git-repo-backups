/****************************************************************************************************************************************
* Class Name  : Core_IPS_RDC_Comments
* Version     : 1.0 
* Created Date: 9/9/2019
* Modification Log :
* Developer                 Date                    Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
*Aparna                        9/9/2019                 This class is for inserting comments to acse number in IPS via POST call-US460268
****************************************************************************************************************************************/
@RestResource(urlMapping='/IPS_RDC/v1.0/cases/comments')

global with sharing class Core_IPS_RDC_Comments {
    
    private static final DateTime ENTRY_TIME = System.now();
    private static final String RESTAPI_NAME= Core_IPS_RDC_Comments.class.getName();
    
    @HttpPost
    global static Core_RestAPI_Response doPost(Core_IPS_RDC_CommentsWrapper caseComments){
        System.debug('Inside the Post method of RDC Att');
        Core_IPS_RDC_Comments_Handler handler = new Core_IPS_RDC_Comments_Handler(ENTRY_TIME, RESTAPI_NAME,caseComments);
        Core_RestAPI_Response response = handler.createCaseComments();    
        //System.debug('Response for Post method==>'+response);
        return response;
        
    }
    
}