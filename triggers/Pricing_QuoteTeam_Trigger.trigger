trigger Pricing_QuoteTeam_Trigger on Pricing_Quote_Team__c (after insert, before delete, after delete) {
    new Pricing_QuoteTeam_Trigger_Handler().run();    
}