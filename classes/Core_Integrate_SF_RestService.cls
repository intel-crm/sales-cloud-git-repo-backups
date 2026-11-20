/******************************************************************************************************************************************
Class Name:  Core_Integrate_SF_RestService
Version     : 1.0 
Created Date: 04 SEP 2020
Function    : Rest Service class
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Sougata Sarkar             04/09/2020              Original Version
*****************************************************************************************************************************************/

@RestResource(urlMapping='/v1.0/utils/inboundintegration')
global with sharing class Core_Integrate_SF_RestService {

    @HttpPost
    global static void doPost(){
        string sourceType = RestContext.request.params.get('sourceType');
        /*********************************************CIM Integration Starts*********************************************/
        if(sourceType <> null && sourceType.equalsIgnoreCase('CIM')){
            try{
                String xmlBody = RestContext.request.requestBody.toString();
                String xmlName = 'CIM_Message';
                SalesforceError err;
                if(ContentVersion.SObjectType.getDescribe().isCreateable() && Core_CIM_Staging__c.SObjectType.getDescribe().isCreateable()){
                    //Insert contentVersion
                    ContentVersion conVer = new ContentVersion();
                    conVer.ContentLocation = 'S';
                    conVer.PathOnClient = xmlName + '.xml';
                    conVer.Title = xmlName;
                    conVer.VersionData = blob.valueOf(xmlBody);
                    insert conVer;
                    
                    //Insert CIM stage record
                    Core_CIM_Staging__c cimMsg = new Core_CIM_Staging__c();
                    cimMsg.Core_Source_System__c = 'CIM';
                    cimMsg.Core_Retry_Counter__c = 0;
                    cimMsg.Core_Status__c = 'Pending';
                    cimMsg.Core_ContentVersion_ID__c = conVer.Id;
                    insert cimMsg;
                    
                    err = new SalesforceError('SUCCESS', 'CIM', cimMsg.Id);
                }else{
                    err = new SalesforceError('FAILED', 'CIM', 'Insufficient Privilege on ContentVersion or Core_CIM_Staging__c object.');
                }
                
                //Prepare response
                RestContext.response.responseBody = Blob.valueOf(JSON.serialize(err));
            }catch(Exception ex){
                RestContext.response.statusCode = 500;
                SalesforceError errs = new SalesforceError('FAILED', 'CIM', ex.getMessage() + ex.getLineNumber());
                RestContext.response.responseBody = Blob.valueOf(JSON.serialize(errs));
            }
        }
        /*********************************************CIM Integration Ends*********************************************/
        
        //Other integration logic can be added below
        
    }
    
    //Error response structure
    public class SalesforceError {
        public String STATUS;
        public String SOURCE_TYPE;
        public String MESSAGE;
        public SalesforceError(String STATUS, string SOURCE_TYPE, string MESSAGE){
            this.STATUS = STATUS;
            this.SOURCE_TYPE = SOURCE_TYPE;
            this.MESSAGE = MESSAGE;
        }
    }
}