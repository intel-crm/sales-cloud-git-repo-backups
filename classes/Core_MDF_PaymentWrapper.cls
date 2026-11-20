public with sharing class Core_MDF_PaymentWrapper {
     
    public List<PartnerFundClaim> claimsToBeProcessed = new List<PartnerFundClaim>();
    public Core_MDF_Payment__c paymentForClaims = new Core_MDF_Payment__c();
    public Decimal sumOfClaimsAmount = 0;  
    public Decimal sumOfConvertedAmount = 0;
    public Decimal currencyExchangeRate = 0;
    public String budgetType=null;
    public boolean includeOnlyClaimAmountForPayment = false;
    public Decimal sumOfClaimsAmountExcludesRecovery = 0;  
    public Decimal sumOfConvertedAmountExcludesRecovery = 0;
    //public String ultimateAcc='';
}