public with sharing class PRM_AdminAccountSearch {
    public class SearchResult {
        @AuraEnabled public List<Account> accounts { get; set; }
        @AuraEnabled public Boolean hasMore { get; set; }
    }

    @AuraEnabled
    public static SearchResult searchAccounts(String accountName, String website) {
        if (String.isBlank(accountName) || accountName.trim().length() < 2) {
            throw new AuraHandledException('Enter at least two characters in Account Name.');
        }
        String domain = websiteDomain(website);
        if (domain == null) {
            throw new AuraHandledException('Enter a valid website domain, for example example.com.');
        }
        String namePattern = '%' + escapeLike(accountName.trim()) + '%';
        String websitePattern = '%' + escapeLike(domain) + '%';
        List<Account> candidates = [
            SELECT Id, Name, Website, Core_User_Defined_Website__c,
                Core_IPA_Partner_Role__c, Core_Intel_Partner_Alliance_PartnerGroup__c,
                BillingStreet, BillingCity,
                BillingState, BillingStateCode, BillingCountry,
                BillingCountryCode, BillingPostalCode
            FROM Account
            WHERE recordtype.name=: System.Label.PRM_Intel_Account_Record_Type and 
            Name LIKE :namePattern
            AND (Core_User_Defined_Website__c LIKE :websitePattern
            OR Website LIKE :websitePattern)
            WITH USER_MODE
            ORDER BY Name, Id
            LIMIT 201
        ];
        SearchResult result = new SearchResult();
        result.accounts = new List<Account>();
        result.hasMore = candidates.size() == 201;
        for (Account candidate : candidates) {
            if (websiteDomain(candidate.Core_User_Defined_Website__c) == domain
                || websiteDomain(candidate.Website) == domain) {
                if (result.accounts.size() == 50) {
                    result.hasMore = true;
                    break;
                }
                result.accounts.add(candidate);
            }
        }
        return result;
    }

    @TestVisible
    private static String escapeLike(String value) {
        return value.replace('\\', '\\\\').replace('%', '\\%').replace('_', '\\_');
    }

    @TestVisible
    private static String websiteDomain(String website) {
        if (String.isBlank(website)) {
            return null;
        }
        String domain = website.trim().toLowerCase();
        domain = domain.replaceFirst('^https?://', '');
        List<String> parts = domain.split('[/?#]');
        if (parts.isEmpty()) {
            return null;
        }
        domain = parts[0].replaceFirst('^www\\.', '');
        domain = domain.replaceFirst(':\\d+$', '').replaceFirst('\\.$', '');
        if (!Pattern.matches(
            '([a-z0-9]([a-z0-9-]*[a-z0-9])?\\.)+[a-z]{2,63}', domain
        )) {
            return null;
        }
        return domain;
    }
}