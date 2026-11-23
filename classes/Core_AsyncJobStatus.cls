public with sharing class Core_AsyncJobStatus {
    @AuraEnabled(cacheable=true)
    public static List<AsyncApexJob> getAsyncJobs(String status, String className, Date createdDate) {
        String query = 'SELECT Id, JobType, Status, ApexClass.Name, MethodName, CreatedDate, JobItemsProcessed, TotalJobItems, NumberOfErrors FROM AsyncApexJob WHERE Id != null';
        
        if (String.isNotBlank(status)) {
            query += ' AND Status = :status';
        }
        if (String.isNotBlank(className)) {
            String likeName = '%' + className + '%';
            query += ' AND ApexClass.Name LIKE :likeName';
        }
        if (createdDate != null) {
            query += ' AND DAY_ONLY(CreatedDate) = :createdDate';
        }
        
        query += ' ORDER BY CreatedDate DESC LIMIT 100';
        return Database.query(query);
    }
}