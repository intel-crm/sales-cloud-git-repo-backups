public class Core_IPS_MyIntel_Retry {
@invocableMethod
    public static void retryMechanism(List<Core_IPS_MyIntel_Outbound_Message__c> outbountMsgList){
        
        System.debug('outbountMsgList --- '+outbountMsgList);
        System.debug('outbountMsgList --size- '+outbountMsgList.size());
    }
}