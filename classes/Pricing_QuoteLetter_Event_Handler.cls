public without sharing class Pricing_QuoteLetter_Event_Handler extends TriggerHandler {
    
      public override void afterInsert() {
          Pricing_QuoteLetter_BusinessLogic.generateQuoteLetters( (List<Pricing_Quote_Letter_Event__e>) trigger.new );
      }

}