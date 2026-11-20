public class Pricing_IntegrationStagingTriggerHandler extends TriggerHandler {    
    public override void beforeUpdate() {
        if(TriggerHandler.isActive('Pricing_UCD_Switch')) {
            for(Pricing_Integration_Staging__c pis : (List<Pricing_Integration_Staging__c>)Trigger.new) {
                Pricing_Integration_Staging__c pisOld = (Pricing_Integration_Staging__c)Trigger.oldMap.get(pis.Id);
                if(pis.Pricing_Message_Type__c == Label.Pricing_Tender_Inbound_MsgType_Tender && pis.Pricing_Retry_Number__c != pisOld.Pricing_Retry_Number__c) {
                    pis.Pricing_Retry_Time_Stamp__c = System.now();
                }
            }
        }
    }
}