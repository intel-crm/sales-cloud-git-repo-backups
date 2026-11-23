/* Class Name : Core_IPS_BES_LogEntry_Utility
   Description : This class is used as a utility for inserting BES Error Log records. Implemented as part of exception handling for new bridge design.
   Author : Chandrashekar */

public with sharing class Core_IPS_BES_LogEntry_Utility {
    public static void insertLog(Exception e, Core_IPS_BES_Outbound_Message__c outboundRec, Core_IPS_BES_Inbound_Message__c inboundRec, String errorCode, String objId) {
        try {
            //System.debug('here is the outbound record===>'+outboundRec);
            //System.debug('inside utility bes error log');
            List<Core_IPS_BES_Error_Log__c> retryCount = new List<Core_IPS_BES_Error_Log__c>();
            if(outboundRec!=null){
                retryCount = [SELECT Id FROM Core_IPS_BES_Error_Log__c WHERE Core_IPS_Outbound_Message_Id__c =: outboundRec.Id];   
            }
            Core_IPS_BES_Error_Log__c errorLog = new Core_IPS_BES_Error_Log__c();
            if(inboundRec!=null && Schema.sObjectType.Core_IPS_BES_Error_Log__c.fields.Core_BES_Inbound_Message__c.isCreateable()){
                errorLog.Core_BES_Inbound_Message__c = inboundRec.Id;
            }
            if(errorCode!=null && Schema.sObjectType.Core_IPS_BES_Error_Log__c.fields.Core_IPS_Error_Code__c.isCreateable()){
                errorLog.Core_IPS_Error_Code__c =Integer.valueof(errorCode.trim());
            } 
            if(Schema.sObjectType.Core_IPS_BES_Error_Log__c.fields.Core_IPS_Error_Description__c.isCreateable()){
                errorLog.Core_IPS_Error_Description__c = e.getStackTraceString();
            }
            if(outboundRec!=null && Schema.sObjectType.Core_IPS_BES_Error_Log__c.fields.Core_IPS_Outbound_Message_Id__c.isCreateable()){
                errorLog.Core_IPS_Outbound_Message_Id__c = outboundRec.Id;
            } 
            if(Schema.sObjectType.Core_IPS_BES_Error_Log__c.fields.Core_IPS_Status__c.isCreateable()){
                 errorLog.Core_IPS_Status__c = e.getMessage().length()> 255 ? e.getMessage().substring(0,255) : e.getMessage();   
                //errorLog.Core_IPS_Status__c = e.getTypeName();
            }  
            if(Schema.sObjectType.Core_IPS_BES_Error_Log__c.fields.Core_IPS_ObjectIds__c.isCreateable()){
                errorLog.Core_IPS_ObjectIds__c = objId;
            } 
            if(Schema.sObjectType.Core_IPS_BES_Error_Log__c.fields.Core_IPS_Retry_Count__c.isCreateable()){
                errorLog.Core_IPS_Retry_Count__c = retryCount.size();
            }
            if(Core_IPS_BES_Error_Log__c.SObjectType.getDescribe().isCreateable()){
                insert errorLog;
            }
            if(Schema.sObjectType.Core_IPS_BES_Outbound_Message__c.fields.Status__c.isUpdateable()){
                outboundRec.Status__c = 'IPS Failed';
            }
                Update outboundRec;   
            System.debug('log rec===>'+errorLog);
            System.debug('outbound rec===>'+outboundRec);
            System.debug('errorcode===>'+errorCode);
            Core_IPS_BES_Transaction_Track.sendTransactionDetails((errorLog != null) ? errorLog.Id : null , (outboundRec != null) ? outboundRec.Id : null, (inboundRec != null) ? inboundRec.Id : null, errorCode);   
              
        } catch(Exception ecp) {
            System.debug('exception occured'+ ecp.getLineNumber()+''+ecp.getStackTraceString());
        }
    }
    public static void insertLog(Decimal errorcode, String errordesc, String errstatus){
        
        try{
            //System.debug('inside utility bes error log');
            Core_IPS_BES_Error_Log__c errorLog = new Core_IPS_BES_Error_Log__c();
            if(errorcode!=null && Schema.sObjectType.Core_IPS_BES_Error_Log__c.fields.Core_IPS_Error_Code__c.isCreateable()){
                errorLog.Core_IPS_Error_Code__c = errorcode;
            }
            if(errordesc!=null && Schema.sObjectType.Core_IPS_BES_Error_Log__c.fields.Core_IPS_Error_Description__c.isCreateable()){
                errorLog.Core_IPS_Error_Description__c = errordesc ;
            }
            if(errstatus!=null && Schema.sObjectType.Core_IPS_BES_Error_Log__c.fields.Core_IPS_Status__c.isCreateable()){
                errorLog.Core_IPS_Status__c = errstatus;
            }
            
            if(Core_IPS_BES_Error_Log__c.SObjectType.getDescribe().isCreateable()){
                insert errorLog;
            } 
            //System.debug('log rec===>'+errorLog);
            //System.debug('errorcode===>'+errorcode);
       }
        catch(Exception e){
            //System.debug('exception occured'+ e.getLineNumber()+''+e.getStackTraceString());
        }
    }
}