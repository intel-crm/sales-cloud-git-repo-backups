/*********************************************************************************************************************
Apex Class Name  : PRM_IPA_Utility
Version       : 1.0
Created Date  : DEC 2021
Function      : Utility class containing common business logic for IPA

Modification Log :
* Developer                 Date                    Description
* --------------------------------------------------------------------------------------------------------------------
* 

*********************************************************************************************************************/
public without sharing class PRM_IPA_Utility {
    //Use this method to create a log entry record for PCC related integrations.
    public static PRM_Integration_Log__c createPCCIntegrationLog(String recordId ,String callType, String module, String reqPayload, String respPayload, Integer respCode ,String systemName, String className,  DateTime reqTime, DateTime resTime, Boolean insertRecord, Id program, String reqUrl)
    {
        
        PRM_Integration_Log__c intLog = new PRM_Integration_Log__c();
        intLog.PRM_Record_ID__c = recordId;
        intLog.PRM_Callout_Type__c = callType;
        intLog.PRM_Module__c = module;
        intLog.PRM_Request_Payload__c = reqPayload;
        intLog.PRM_Response_Payload__c = respPayload;
        intLog.PRM_Response_Code__c = respCode;
        intLog.PRM_System_Name__c = systemName;
        intLog.PRM_Class__c = className;
        intLog.PCC_Partner_Program__c = program;
        intLog.PCC_Requested_URL__c = reqUrl;
        if(!(System.isBatch())){
            if(Schema.sObjectType.PRM_Integration_Log__c.isCreateable()){
                insert intLog;
            }else{
                Core_Log_Entry.logEntryWithDetails('PRM_IPA_Utility', 'PCC','createIntegrationLog', 'exception',System.label.PRM_Log_Entry_Error_Object_Level,System.label.PRM_Log_Entry_Error_Object_Level , ' ', '', ' ');
            }
        }
        system.debug('---reqPayload '+reqPayload);            
        return intLog;
    }
    
   public static void createLogEntry(String logEntryMsgString, String origin, String project, String scope, String severity, String tags){
        if(logEntryMsgString!=''){// this block will create Log Entry records on the basis of length of logEntryMsg and Field limit.
            PRM_ProcessInboundOPIDLogEntriesUtility logEntryUtility=new PRM_ProcessInboundOPIDLogEntriesUtility();
            Integer fieldLength=Schema.SObjectType.Core_Log_Entry__c.fields.Core_Details__c.getLength();
            logEntryUtility.addLogEntry(logEntryMsgString,fieldLength);
            for(Integer i=0; i<logEntryUtility.logEntryList.size();i++){
                Core_Log_Entry.logEntryWithDetails(origin, project, scope, severity,logEntryMsgString.split('@@@')[0] ,logEntryUtility.logEntryList[i] , '', '', tags);
            }//loop ends here..
        }
    }  
}