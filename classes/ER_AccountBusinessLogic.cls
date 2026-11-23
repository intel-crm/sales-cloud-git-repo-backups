public with sharing class ER_AccountBusinessLogic {

    // Method 1: Search Account by Direct ID
    @AuraEnabled(cacheable=true)
    public static List<Account> searchAccountByDirectId(String directAccountId) {
        return [
            SELECT Id, Core_Direct_Account_Id__c, Name, Core_Direct_Account_Name_Txt__c,
                   Core_Direct_Account_Type_Nm__c, Core_Direct_Sales_Organization_Nm__c,
                   Core_Direct_Distributor_Channel_Nm__c, BillingStreet, BillingCity,
                   BillingState, BillingPostalCode, BillingCountry
            FROM Account
            WHERE Core_Direct_Account_Id__c = :directAccountId
            LIMIT 1
        ];
    }

    // Method 2: Create ER_Account_Business_Partner__c records
    @AuraEnabled
    public static void createAccountBusinessPartners(Id groupId, List<Object> accountData) {
        List<ER_Account_Business_Partner__c> partners = new List<ER_Account_Business_Partner__c>();

        for (Object obj : accountData) {
            String jsonString = JSON.serialize(obj);
            Map<String, Object> record = (Map<String, Object>) JSON.deserializeUntyped(jsonString);

            if (record.containsKey('Id')) {
                partners.add(new ER_Account_Business_Partner__c(
                    ER_Account__c = (Id) record.get('Id'),
                    ER_Account_Group__c = (String) record.get('Core_Direct_Account_Type_Nm__c'),
                    ER_Customer_Master_File_Grouping__c = groupId
                ));
            }
        }

        if (!partners.isEmpty()) {
            insert partners;
        }
    }

    // Method 3: Get CMF Account details
    @AuraEnabled(cacheable=true)
    public static List<Map<String, String>> getCmfAccountDetails(String accountId) {
        List<Map<String, String>> result = new List<Map<String, String>>();

        for (Account acc : [
            SELECT Id, Name
            FROM Account
            WHERE Id = :accountId
            LIMIT 1
        ]) {
            Map<String, String> accMap = new Map<String, String>();
            accMap.put('AccountName', acc.Name);
            accMap.put('AccountLink', '/' + acc.Id);
            result.add(accMap);
        }

        return result;
    }

    // Method 4: Search by multiple filters
    @AuraEnabled(cacheable=true)
    public static List<Account> searchAccountByFilters(String cmfId, String salesOrgCode, String salesDistiCode) {
        String baseQuery = 'SELECT Id, Name, Core_Direct_Account_Id__c, Core_Direct_Account_Name_Txt__c, ' +
                           'Core_Direct_Account_Type_Nm__c, Core_Direct_Sales_Organization_Nm__c, ' +
                           'Core_Direct_Distributor_Channel_Nm__c, BillingStreet, BillingCity, ' +
                           'BillingState, BillingPostalCode, BillingCountry FROM Account WHERE ';
        
        List<String> filters = new List<String>();
        if (String.isNotBlank(cmfId)) {
            filters.add('Core_Direct_Account_Id__c = :cmfId');
        }
        if (String.isNotBlank(salesOrgCode)) {
            filters.add('Core_Direct_Sales_Organization_Nm__c LIKE \'%' + salesOrgCode + '%\'');
        }
        if (String.isNotBlank(salesDistiCode)) {
            filters.add('Core_Direct_Distributor_Channel_Nm__c LIKE \'%' + salesDistiCode + '%\'');
        }

        if (filters.isEmpty()) {
            return new List<Account>();
        }

        String finalQuery = baseQuery + String.join(filters, ' AND ');
        return Database.query(finalQuery);
    }
}