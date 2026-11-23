/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 10-28-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public class Pricing_QuoteLineResubmissionQueue implements Queueable{
    public Set<Id> quoteIds = new Set<Id>();
    
    public Pricing_QuoteLineResubmissionQueue (Set<Id> quoteIds){
        system.debug('quoteIds----->'+quoteIds);
        this.quoteIds = quoteIds;
    }
    public void execute(QueueableContext context) {
        Pricing_QuoteTeam_Trigger_Handler.hasQuoteLineResubmission = true;
        //Set<Id> quoteIds = new Set<Id>();      
        set<Id> quoteLineId = new set<ID>();          
        
        /*List<ProcessInstanceWorkitem> processInsWork = new List<ProcessInstanceWorkitem>();
if(quoteTeam.size() > 0){           
for(Pricing_Quote_Team__c qtm : quoteTeam){
quoteIds.add(qtm.Pricing_Quote_Id__c);
}
}*/
        system.debug('quoteIds----->'+quoteIds);
        if(quoteIds.size() > 0){
            
            for(SBQQ__QuoteLine__c quoteLine : [SELECT Id From SBQQ__QuoteLine__c WHERE SBQQ__Quote__c IN : quoteIds and Pricing_Status_Nm__c =: Label.Pricing_Tender_QuoteLine_Status_PendingIntelFieldReview]) {
                if(quoteLine != null) { 
                    quoteLineId.add(quoteLine.id);
                }
            }
            Pricing_Publish_Quote.approveOrRejectQLI(quoteLineId, Label.Pricing_Tender_QuoteLine_Action_Reject, Label.Pricing_Tender_QuoteLine_Action_Reject);
            Pricing_Publish_Quote.publishQuoteLinesToMultipleFSE(quoteLineId);
            Pricing_QuoteTeam_Trigger_Handler.hasQuoteLineResubmission = false;        
        }
    }
}