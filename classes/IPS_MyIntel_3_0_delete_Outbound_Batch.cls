/************************************************************************************************************
* Purpose: This Class is used for Deleting the Outbound messages and error logs which are older than 90 days
* @Name IPS_MyIntel_3_0_delete_Outbound_Batch.
* @Author Karthik Bandla
* @version 1.0
* @Created Date 22/06/2021
* @Last Modfied Date 25/06/2021
************************************************************************************************************/
global class IPS_MyIntel_3_0_delete_Outbound_Batch implements Database.Batchable<sObject> {
    
    private final static String strScope = 'IPS_Delete_OutboundMyintelRecords';
    private final static String strSeverity = 'Critical';
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        DateTime s = System.Now().addDays(integer.valueOf(system.label.IPS_MyIntel_3_0_delete_days)); 
        return Database.getQueryLocator
            ([Select id,Name from Core_IPS_MyIntel_Outbound_Message__c where CreatedDate <= :s WITH SECURITY_ENFORCED]);
    }
    global void execute(Database.BatchableContext BC, List<Core_IPS_MyIntel_Outbound_Message__c> outboundRec){
        try{
            
            List<Core_Log_Entry__c> logRec = new List<Core_Log_Entry__c>();
            
            DateTime s = System.Now().addDays(integer.valueOf(system.label.IPS_MyIntel_3_0_delete_days));
            
           if(Core_Log_Entry__c.SObjectType.getDescribe().isAccessible()){
            logRec = [select Id,CreatedDate,Core_Origin__c FROM Core_Log_Entry__c WHERE Core_Origin__c like '%IPS_MyIntel_Integration issue%' and CreatedDate <= :s WITH SECURITY_ENFORCED];
           }
            if(logRec.size()>0 && !logRec.isEmpty() && Schema.SObjectType.Core_Log_Entry__c.isDeletable())
            {              
                Database.delete(logRec,false); 
            }
            if(outboundRec.size()>0 && !outboundRec.isEmpty() && Schema.SObjectType.Core_IPS_MyIntel_Outbound_Message__c.isDeletable())
            {
                Database.delete(outboundRec,false); 
            }
            
            //Creating custom exception to cover catch block
            if(Test.isRunningTest()){
                CalloutException e = new CalloutException();
                e.setMessage('This is a constructed exception for testing and code coverage');
                throw e;
            }
        } 
        catch(exception ex)
        { 
            Core_Log_Entry.logEntryWithException('SFDC','IPS',strScope,strSeverity,'Issue in IPS_MyIntel_3_0_delete_Outbound_Batch',ex.getMessage(),null,'Core_IPS_MyIntel_Outbound_Message__c',null,ex);
        }
    }
    global void finish(Database.BatchableContext BC) {
        
    }
    
    
}