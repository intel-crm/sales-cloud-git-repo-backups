//This class is no more required. Please DELETE this class.
public without sharing class Pricing_FIQuoteQLCreation_Event_Handler extends TriggerHandler{
    public override void afterInsert(){
        List<Id> oppIds = new List<Id>();
        for(Pricing_FI_Quote_and_QL_Creation__e evt : (List<Pricing_FI_Quote_and_QL_Creation__e>)Trigger.New){
            if(!String.isEmpty(evt.Pricing_FI_Opportunity_IDs_txt__c)){
                oppIds.addAll(evt.Pricing_FI_Opportunity_IDs_txt__c.split(','));
            }
        }
        Pricing_FinancialIncentive_BusinessLogic.createQuoteQuoteLine(oppIds);
    }
}