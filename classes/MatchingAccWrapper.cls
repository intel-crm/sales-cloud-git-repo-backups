public class MatchingAccWrapper {
    @AuraEnabled public String accUrl;
    @AuraEnabled public Id accId;
    @AuraEnabled public String accName;
    @AuraEnabled public String unifiedHierarchy;
    @AuraEnabled public String aggrCode;
    @AuraEnabled public String intrmdtCust;
    @AuraEnabled public String unifiedId;
    @AuraEnabled public String address;
    @AuraEnabled public String bizOrgType;
    @AuraEnabled public Boolean ipaAccount;
    @AuraEnabled public String partnerRole;
    @AuraEnabled public Boolean gecBlock;
    @AuraEnabled public String recordType;
    @AuraEnabled public String accountOwner;
    @AuraEnabled public String parentAccUrl;
    @AuraEnabled public String parentAccName;
    // added as Part fo IPA 2.0 Refresh
    @AuraEnabled public String street;
    @AuraEnabled public String city;
    @AuraEnabled public String state;
    @AuraEnabled public String stateCode;
    @AuraEnabled public String postalCode;
    @AuraEnabled public String country;
    @AuraEnabled public String countryCode;
    
    public static MatchingAccWrapper parse(String json) {
        return (MatchingAccWrapper) System.JSON.deserialize(json, MatchingAccWrapper.class);
    }
}