/*********************************************************************************************************************
Apex Class Name  : PRM_CreateIntegrationLogs
Version       : 1.0
Created Date  : DEC 2021
Function      : This Queueable class is used to create Integration Log records

Modification Log :
* Developer                 Date                    Description
* --------------------------------------------------------------------------------------------------------------------
* 

*********************************************************************************************************************/

public without sharing class PRM_CreateIntegrationLogs implements Queueable{
    String sobjectId;
    String externalId;
    String callType;
    String module;
    String reqPayload;
    String respPayload;
    Integer respCode;
    String errorMsg;
    String systemName;
    String className; 

    public PRM_CreateIntegrationLogs(String recordId,String extId,String calloutType,String mod,String request,String response,Integer code,String erMsg,String sysName,String clsName) {
     this.sobjectId=recordId;
     this.externalId=extId;
     this.callType=calloutType;
     this.module = mod;
     this.reqPayload = request;
     this.respPayload = response;
     this.respCode = code;
     this.errorMsg = erMsg;
     this.systemName = sysName;
     this.className = clsName;

    }

    public void execute(QueueableContext currentContext){
        try{
            PRM_Integration_Log__c intLog = new PRM_Integration_Log__c();
            intLog.PRM_Record_ID__c = sobjectId;
            intlog.PRM_External_ID__c = externalId;
            intLog.PRM_Callout_Type__c = callType;
            intLog.PRM_Module__c = module;
            intLog.PRM_Request_Payload__c = reqPayload;
            intLog.PRM_Response_Payload__c = respPayload;
            intLog.PRM_Response_Code__c = respCode;
            intLog.PRM_Error_Message__c = errorMsg;
            intLog.PRM_System_Name__c = systemName;
            intLog.PRM_Class__c = className;

            insert intLog;
        }
        catch(exception e)
        {
            PRM_ErrorUtilityClass.logError(e);
        }



    }

}