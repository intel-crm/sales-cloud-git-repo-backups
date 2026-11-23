public without sharing class Core_ACM_InboundMessageFactory {

    public static Core_Integration_Inbound_Message__c createSuccessMessage(String responseJson) {
        Core_Integration_Inbound_Message__c inboundMsg = new Core_Integration_Inbound_Message__c();
        inboundMsg.Core_Source_System__c=Core_ACM_Constants.SOURCE_ERPM;
        inboundMsg.Core_Processing_Status__c = Core_ACM_Constants.STATUS_PENDING;
        inboundMsg.Core_Message_Type__c = Core_ACM_Constants.MESSAGE_TYPE_BLACKBOX;
        inboundMsg.Core_Payload__c = responseJson;
        return inboundMsg;
    }

    public static Core_Integration_Inbound_Message__c createFailureMessage(Core_ACM_PayloadWrapper.ResponseWrapper response, String responseJson) {
        Core_Integration_Inbound_Message__c inboundMsg = new Core_Integration_Inbound_Message__c();
        inboundMsg.Core_Payload__c = responseJson;
        inboundMsg.Core_Processing_Status__c = Core_ACM_Constants.STATUS_PENDING;
        inboundMsg.Core_Message_Type__c = Core_ACM_Constants.MESSAGE_TYPE_BLACKBOX;
        inboundMsg.Core_Error_Code__c = response.ErrorCode;
        inboundMsg.Core_Error_Description__c = response.ErrorDetails;
        inboundMsg.Core_Source_System__c=Core_ACM_Constants.SOURCE_ERPM;
        return inboundMsg;
    }
}