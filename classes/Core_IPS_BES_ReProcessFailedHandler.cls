public with sharing class Core_IPS_BES_ReProcessFailedHandler {
    
    @AuraEnabled
    public static String executeBatch(String objectAPIName, Integer numOfDays){
        try{
            Id batchJobId = Database.executeBatch(new Core_IPS_BES_ReprocessFailedRecords(objectAPIName, numOfDays), 1 );
            return batchJobId;
            
        } catch (Exception e) { throw new AuraHandledException(e.getMessage()); }
    }
    
}