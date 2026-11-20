trigger CompetitorProductPriceStagingTrigger on Pricing_Competitor_Product_Price_Staging__c (after insert,before insert) {
    //new CompetitorProdPriceStagingTriggerHandler().run();
    if(Trigger.isBefore){
        for(Pricing_Competitor_Product_Price_Staging__c rec : Trigger.new){
            if(rec.Pricing_Application_Staging_Nm__c == null){
                rec.Pricing_Application_Staging_Nm__c = 'Enterprise';
            }
        }
    }else{
        new CompetitorProdPriceStagingTriggerHandler().run();
    }
}