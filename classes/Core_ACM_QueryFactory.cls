public without sharing class Core_ACM_QueryFactory {

    private static final String BASE_FIELDS = 'SELECT Id, Core_Contact__c, Core_Process_Type__c, Core_Payload__c, Core_Status__c, Core_Retry_Count__c FROM Core_ACM_Integration_Queue__c';

    public static String getQuery(Set<Id> recordIdsToProcess, String processType) {
        if (recordIdsToProcess != null && !recordIdsToProcess.isEmpty()) {
            return BASE_FIELDS + ' WHERE Id IN :recordIdsToProcess';
        }
        if (String.isNotBlank(processType) && processType == Core_ACM_Constants.getProcessTypeValue(Core_ACM_Constants.ProcessType.LIVE)) {
            return BASE_FIELDS + ' WHERE Core_Status__c IN (\'' + Core_ACM_Constants.getStatusValue(Core_ACM_Constants.Status.NEW_STATUS) + '\') AND Core_Process_Type__c = \'' + Core_ACM_Constants.getProcessTypeValue(Core_ACM_Constants.ProcessType.LIVE) + '\'';
        }
        return BASE_FIELDS + ' WHERE Core_Status__c IN (\'' + Core_ACM_Constants.getStatusValue(Core_ACM_Constants.Status.NEW_STATUS) + '\') AND Core_Process_Type__c = \'' + Core_ACM_Constants.getProcessTypeValue(Core_ACM_Constants.ProcessType.BULK_MODE) + '\'';
    }
}