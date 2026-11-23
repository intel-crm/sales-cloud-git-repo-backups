public with sharing class Product_AsyncApexJob {
    @AuraEnabled(cacheable=true)
    public static List<AsyncApexJob> getAsyncJobs() {
        String query = 'SELECT Id, ApexClass.Name, JobType, Status, format(CreatedDate),TotalJobItems,JobItemsProcessed,format(CompletedDate)  FROM AsyncApexJob WHERE ApexClass.Name = \'Product_upsertProduct2Records\'  and JobType=\'BatchApex\'';
        query+=' order by createdDate DESC';
        return Database.query(query);
    }
}