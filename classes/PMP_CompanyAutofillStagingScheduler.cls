global class PMP_CompanyAutofillStagingScheduler implements Schedulable {

    global void execute(SchedulableContext sc) {

        PMP_Company_Autofill_Config__mdt config = [
            SELECT Active__c, GEOs__c, Countries__c, Record_Ids__c, Record_Limit__c
            FROM PMP_Company_Autofill_Config__mdt
            WHERE Active__c = true
            LIMIT 1
        ];

        Set<String> geos = new Set<String>();
        Set<String> countries = new Set<String>();
        Set<Id> recordIds = new Set<Id>();

        if (!String.isBlank(config.GEOs__c)) {
            for (String geo : config.GEOs__c.split(',')) {
                if (!String.isBlank(geo)) {
                    geos.add(geo.trim());
                }
            }
        }

        if (!String.isBlank(config.Countries__c)) {
            for (String country : config.Countries__c.split(',')) {
                if (!String.isBlank(country)) {
                    countries.add(country.trim());
                }
            }
        }

        if (!String.isBlank(config.Record_Ids__c)) {
            for (String recordId : config.Record_Ids__c.split(',')) {
                if (!String.isBlank(recordId)) {
                    recordIds.add((Id)recordId.trim());
                }
            }
        }

        Integer recordLimit = config.Record_Limit__c == null || config.Record_Limit__c <= 0 ? 50 : Integer.valueOf(config.Record_Limit__c);

        Database.executeBatch(new PMP_CompanyAutofillStagingBatch(geos, countries, recordIds, recordLimit), 200);
    }
}