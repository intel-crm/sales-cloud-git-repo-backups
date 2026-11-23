trigger Pricing_ApprovalPriceRulesTrigger on Pricing_Approval_Price_Rules__c (after update, before Insert, before update) 
    {
        new Pricing_ApprovalPriceRulesTriggerHandler().run();
    }