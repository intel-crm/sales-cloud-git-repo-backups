public with sharing class DataTableController {
    @AuraEnabled
    public static void createRecords(List<Sobject> records) {
        try {
            insert records;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}