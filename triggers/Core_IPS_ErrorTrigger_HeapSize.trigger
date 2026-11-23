trigger Core_IPS_ErrorTrigger_HeapSize on Core_IPS_BES_Handle_HeapSize__e (after insert) {
    public class CustomException extends Exception {}
system.debug('Core_IPS_ErrorTrigger_HeapSize');
              Core_IPS_BES_Outbound_Message__c outboundRec = new Core_IPS_BES_Outbound_Message__c();
              outboundRec.Id= Trigger.new[0].Outbound_Id__c;
              outboundRec.Status__c = Trigger.new[0].Outbound_Status__c;
              CustomException heapSizeException = new CustomException('Failed due to heap size issue');
              Core_IPS_BES_LogEntry_Utility.insertLog(heapSizeException,outboundRec,null,'501',null);
        }