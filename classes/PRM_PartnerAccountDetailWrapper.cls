public with sharing class PRM_PartnerAccountDetailWrapper {
    @AuraEnabled
    public String accountNumber;

    @AuraEnabled
    public String accountName;

    @AuraEnabled
    public String partnerRole;
    
    @AuraEnabled
    public String partnerTier;
    
    @AuraEnabled
    public String partnerAdmin;
    
    @AuraEnabled
    public List<String> primaryAddress;
    
    @AuraEnabled
    public String website;
    
    @AuraEnabled
    public Boolean ipaTCAccepted;
    
    @AuraEnabled
    public String ipaPartnerAdminName;
    
     @AuraEnabled
    public String ipaPartnerAdminEmail;
    
    @AuraEnabled
    public Decimal trainingCreditCurPeriod;
    
    @AuraEnabled
    public String pointStatus;

    @AuraEnabled
    public Boolean isAuthorised{get;set;}
    
    @AuraEnabled
    public List<ContactDetailWrapper> contacts;

    @AuraEnabled
    public List<PartnerAdminWrapper> partnerDetails;

    @AuraEnabled
    public Boolean isValidRegion;

    @AuraEnabled
    public String cndaNumber;

    @AuraEnabled
    public String affiliation;

    @AuraEnabled
    public String dzpBenefit;

    public class ContactDetailWrapper {
        @AuraEnabled
        public String contactId;

        @AuraEnabled
        public String firstName;
    
        @AuraEnabled
        public String lastName;
        
        @AuraEnabled
        public String email;
    }

    public class PartnerAdminWrapper {
        @AuraEnabled
        public String partnerAdminId;

        @AuraEnabled
        public String partnerAdminFirstName;

        @AuraEnabled
        public String partnerAdminLastName;

        @AuraEnabled 
        public String partnerAdminEmail;
    }
    
}