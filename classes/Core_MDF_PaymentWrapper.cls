public with sharing class Core_MDF_PaymentWrapper {
     
    public List<PartnerFundClaim> claimsToBeProcessed = new List<PartnerFundClaim>();
    public Core_MDF_Payment__c paymentForClaims = new Core_MDF_Payment__c();
    public Decimal sumOfClaimsAmount = 0;  
    
}