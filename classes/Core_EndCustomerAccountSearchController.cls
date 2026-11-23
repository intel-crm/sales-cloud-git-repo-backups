public with sharing class Core_EndCustomerAccountSearchController {

    private static final String ACCOUNT_RECORD_TYPE =
        'Mastered_Account';

    private static final Integer MAX_RESULTS = 25;

    public class AccountSearchResult {

        @AuraEnabled
        public Id accountId;

        @AuraEnabled
        public String accountName;

        @AuraEnabled
        public String billingCountry;

        @AuraEnabled
        public String website;

        @AuraEnabled
        public String partnerRole;

        @AuraEnabled
        public Boolean ipa;

        @AuraEnabled
        public String ipaStatus;

        @AuraEnabled
        public String ownerName;
    }

    @AuraEnabled(cacheable=true)
    public static List<AccountSearchResult> searchAccounts(
        String customerName,
        String customerCountry,
        String customerWebsite
    ) {
        List<AccountSearchResult> results =
            new List<AccountSearchResult>();

        if (String.isBlank(customerName)) {
            return results;
        }

        String nameFilter =
            '%' + customerName.trim() + '%';

        String normalizedSourceWebsite =
            normalizeWebsite(customerWebsite);

        List<Account> candidateAccounts;

        /*
         * Country is required as an exact filter when provided.
         */
        if (String.isNotBlank(customerCountry)) {
            candidateAccounts = [
                SELECT Id,
                       Name,
                       BillingCountry,
                       Website,
                       Core_IPA_Partner_Role__c,
                       Core_Intel_Partner_Alliance_PartnerGroup__c,
                       Owner.Name,
                       RecordType.DeveloperName
                FROM Account
                WHERE RecordType.DeveloperName =
                      :ACCOUNT_RECORD_TYPE
                AND Name LIKE :nameFilter
                AND BillingCountry = :customerCountry
                WITH USER_MODE
                ORDER BY Name
                LIMIT 100
            ];
        } else {
            candidateAccounts = [
                SELECT Id,
                       Name,
                       BillingCountry,
                       Website,
                       Core_IPA_Partner_Role__c,
                       Core_Intel_Partner_Alliance_PartnerGroup__c,
                       Owner.Name,
                       RecordType.DeveloperName
                FROM Account
                WHERE RecordType.DeveloperName =
                      :ACCOUNT_RECORD_TYPE
                AND Name LIKE :nameFilter
                WITH USER_MODE
                ORDER BY Name
                LIMIT 100
            ];
        }

        for (Account accountRecord : candidateAccounts) {

            String normalizedAccountWebsite =
                normalizeWebsite(accountRecord.Website);

            /*
             * Website must match exactly after normalization
             * when the source website is populated.
             */
            if (
                String.isNotBlank(normalizedSourceWebsite) &&
                normalizedSourceWebsite !=
                    normalizedAccountWebsite
            ) {
                continue;
            }

            AccountSearchResult row =
                new AccountSearchResult();

            row.accountId = accountRecord.Id;
            row.accountName = accountRecord.Name;
            row.billingCountry =
                accountRecord.BillingCountry;
            row.website = accountRecord.Website;
            row.partnerRole =
                accountRecord.Core_IPA_Partner_Role__c;
            row.ipa =
                accountRecord
                    .Core_Intel_Partner_Alliance_PartnerGroup__c;
            row.ipaStatus =
                accountRecord
                    .Core_Intel_Partner_Alliance_PartnerGroup__c
                    ? 'IPA'
                    : 'Non-IPA';
            row.ownerName =
                accountRecord.Owner != null
                    ? accountRecord.Owner.Name
                    : null;

            results.add(row);

            if (results.size() == MAX_RESULTS) {
                break;
            }
        }

        return results;
    }

    private static String normalizeWebsite(String website) {

        if (String.isBlank(website)) {
            return null;
        }

        String normalized =
            website.trim().toLowerCase();

        normalized = normalized.replaceFirst(
            '^https?://',
            ''
        );

        normalized = normalized.replaceFirst(
            '^www\\.',
            ''
        );

        /*
         * Remove the page path.
         */
        if (normalized.contains('/')) {
            normalized =
                normalized.substringBefore('/');
        }

        /*
         * Remove query parameters.
         */
        if (normalized.contains('?')) {
            normalized =
                normalized.substringBefore('?');
        }

        /*
         * Remove port when present.
         */
        if (normalized.contains(':')) {
            normalized =
                normalized.substringBefore(':');
        }

        return normalized;
    }
}