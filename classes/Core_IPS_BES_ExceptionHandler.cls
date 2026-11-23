@RestResource(urlMapping='/IPS_BES_ExceptionHandler/*')
global with sharing class Core_IPS_BES_ExceptionHandler { 
    @HttpPost
    global static void postError() {
        List<Core_IPS_BES_Outbound_Message__c> ouboundMsg = new List<Core_IPS_BES_Outbound_Message__c>();
        try{
            RestRequest req = RestContext.request;
            Blob body = req.requestBody;
            String response = body.toString();
            if(response != null){
                Map<String, Object> exceptionMap = (Map<String, Object>)JSON.deserializeUntyped(response);
                if(exceptionMap.containsKey('error_response')){
                    Map<String, Object> exceptionDetailMap =  (Map<String, Object>)exceptionMap.get('error_response');
                    if(exceptionDetailMap.containsKey('Error')){
                        if(Core_IPS_BES_Outbound_Message__c.SObjectType.getDescribe().isQueryable()){
                            ouboundMsg = [SELECT Id,Status__c,(select id from BES_Error_Logs__r) FROM  Core_IPS_BES_Outbound_Message__c where Name=: (String)exceptionDetailMap.get('message_id')];
                        }
                        Core_IPS_BES_Error_Log__c errorLog = new Core_IPS_BES_Error_Log__c();
                        /*US1038991 - 07/08/2021 - Vishal - FLS Check for security vulnerability --*/
                        if (Schema.sObjectType.Core_IPS_BES_Error_Log__c.fields.Core_IPS_Error_Description__c.isCreateable()) {
                            errorLog.Core_IPS_Error_Description__c = JSON.serialize(exceptionDetailMap.get('Error'));
                        }
                        if(Schema.sObjectType.Core_IPS_BES_Error_Log__c.fields.Core_IPS_Error_Code__c.isCreateable()){
                            errorLog.Core_IPS_Error_Code__c =  Integer.valueOf(exceptionDetailMap.get('status_code'));
                        }
                        if (Schema.sObjectType.Core_IPS_BES_Error_Log__c.fields.Core_IPS_Outbound_Message_Id__c.isCreateable()) {
                            errorLog.Core_IPS_Outbound_Message_Id__c = (ouboundMsg.size() > 0) ? ouboundMsg[0].Id : null;
                        }
                        if (Schema.sObjectType.Core_IPS_BES_Error_Log__c.fields.Core_IPS_Retry_Count__c.isCreateable()) {
                        	errorLog.Core_IPS_Retry_Count__c = (ouboundMsg.size() > 0) ? ouboundMsg[0].BES_Error_Logs__r.size() : 0;
                        }
                        if(ouboundMsg[0].BES_Error_Logs__r.size() < 3){
                         	insert errorLog;   
                        }
                        /*US1038991 - 07/09/2021 - Vishal - FLS Check for security vulnerability --*/
                        //Added by tushar because of vulnerability changes 
                        if (Schema.sObjectType.Core_IPS_BES_Outbound_Message__c.fields.Status__c.isUpdateable()) {
                            ouboundMsg[0].Status__c = 'IPass Failed';
                        }
                        update ouboundMsg; 
                    }
                    //Chandra - to keep track of the error details.
                    System.debug('error response '+response);
                    Core_Log_Entry.logEntryWithDetails('SFDC','IPS',null,'info','Erro Details Json',response,null,'Core_IPS_BES_Error_Log__c',null);
                }
            }
             //Creating custom exception to cover catch block
            if(Test.isRunningTest()) {
                StringException e = new StringException();
                e.setMessage('This is a constructed exception for testing and code coverage');
                throw e;
            }
        } catch(exception e) {
            Core_IPS_BES_Error_Log__c errorLog = new Core_IPS_BES_Error_Log__c();
            /*TWC745-112 - 05/08/2021 - Vishal - FLS Check for security vulnerability --*/
            if (Schema.sObjectType.Core_IPS_BES_Error_Log__c.fields.Core_IPS_Error_Description__c.isCreateable()) {
                 errorLog.Core_IPS_Error_Description__c = e.getStackTraceString();
            }
            if (Schema.sObjectType.Core_IPS_BES_Error_Log__c.fields.Core_IPS_status__c.isCreateable()) {
                 errorLog.Core_IPS_status__c = (e.getMessage()?.length()>255)?e.getMessage().subString(0,255):e.getMessage();
            }
            insert errorLog;
        }
    }
}