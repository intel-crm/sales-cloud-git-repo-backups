global class CRMTimezoneValuesBatch
implements Database.Batchable<String>, Database.Stateful {

    global Iterable<String> start(Database.BatchableContext bc) {

        List<String> countries = new List<String>();

        for (Schema.PicklistEntry country :
            Account.BillingCountryCode.getDescribe().getPicklistValues()) {

            if (country.isActive()) {
                countries.add(country.getLabel());
            }
        }

        return countries;
    }

    global void execute(
        Database.BatchableContext bc,
        List<String> scope
    ) {

        Map<String,String> countryMap = new Map<String,String>();

        for (Schema.PicklistEntry c :
            Account.BillingCountryCode.getDescribe().getPicklistValues()) {

            if (c.isActive()) {
                countryMap.put(c.getLabel(), c.getValue());
            }
        }

        List<CRM_Timezone_values__c> inserts =
            new List<CRM_Timezone_values__c>();

        for (String country : scope) {

            inserts.add(
                new CRM_Timezone_values__c(
                    CRM_Country_txt__c = country,
                    CRM_Country_Code_txt__c = countryMap.get(country)
                )
            );
        }

        if (!inserts.isEmpty()) {

            Database.SaveResult[] results =
                Database.insert(inserts, false);

            Integer successCount = 0;
            Integer failureCount = 0;

            for (Database.SaveResult sr : results) {

                if (sr.isSuccess()) {
                    successCount++;
                } else {
                    failureCount++;

                    for (Database.Error e : sr.getErrors()) {
                        System.debug(
                            'Insert Error: ' +
                            e.getMessage()
                        );
                    }
                }
            }

            System.debug(
                'Success=' + successCount +
                ', Failed=' + failureCount
            );
        }
    }

    global void finish(Database.BatchableContext bc) {

        System.debug('Country Load Completed');
    }
}