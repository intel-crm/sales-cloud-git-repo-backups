public with sharing class PRM_PartnerSearchResultWrapper {
    @AuraEnabled
    public String accountId;

    @AuraEnabled
    public String accountNumber;

    @AuraEnabled
    public String accountName;

    @AuraEnabled
    public String accountLink;

    @AuraEnabled
    public String partnerRole;

    @AuraEnabled
    public String partnerTier;

    @AuraEnabled
    public String billingAddress;

    @AuraEnabled
    public String billingState;

    @AuraEnabled
    public String billingCountry;

    @AuraEnabled
    public String billingZipcode;
}