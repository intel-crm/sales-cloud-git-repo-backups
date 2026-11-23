public class Core_IntegrationOutboundAGSMsg {

    @AuraEnabled
    public String myId;
    
    @AuraEnabled
    public String mySObject;
    
    @AuraEnabled
    public String myMessageType;
    
    @AuraEnabled
    public String myPayload;

    //This method is used as part of the Create Apex Action section.
    public static Core_IntegrationOutboundAGSMsg parse(String json) {
        return (Core_IntegrationOutboundAGSMsg) System.JSON.deserialize(json, Core_IntegrationOutboundAGSMsg.class);
    }
}