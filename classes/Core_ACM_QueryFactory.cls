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
    
    //Ganesh Changes
	public static String getAGSQuery(Set<Id> failedRecordsToRetry, String processType, String source) {
    // Handle retry scenario first
    if (failedRecordsToRetry != null && !failedRecordsToRetry.isEmpty()) {
        return BASE_FIELDS + ' WHERE Id IN :failedRecordsToRetry AND Core_Message_Type__c = \'' + Core_ACM_Constants.MESSAGE_TYPE_AGS + '\'' + ' ORDER BY CreatedDate ASC';
    }

    // Get current hour boundaries
    Datetime startOfHour = Datetime.now().addMinutes(-Datetime.now().minute()).addSeconds(-Datetime.now().second());
    Datetime endOfHour = startOfHour.addHours(1);
    //New Change Ganesh
	String startHourStr = startOfHour.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
    String endHourStr = endOfHour.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
    // Query Live processed records for current hour
    List<Core_ACM_Integration_Queue__c> liveRecordsProcessed = [
        SELECT Id, Core_Process_Type__c, Core_Status__c, CreatedDate
        FROM Core_ACM_Integration_Queue__c
        WHERE CreatedDate >= :startOfHour 
        AND CreatedDate < :endOfHour 
		AND Core_Message_Type__c = :Core_ACM_Constants.MESSAGE_TYPE_AGS
        AND Core_Process_Type__c = 'LIVE' 
        AND Core_Status__c IN ('Success','Failed')
    ];
    
    //query Bulk processed records for current hour
    List<Core_ACM_Integration_Queue__c> bulkRecordsProcessed = [
        SELECT Id, Core_Process_Type__c, Core_Status__c, CreatedDate
        FROM Core_ACM_Integration_Queue__c
        WHERE CreatedDate >= :startOfHour
        AND CreatedDate < :endOfHour 
        AND Core_Process_Type__c = 'BULK' 
		AND Core_Message_Type__c = :Core_ACM_Constants.MESSAGE_TYPE_AGS
        AND Core_Status__c IN ('Success','Failed')
    ];
    
    // Calculate available limits
    Integer liveUsed = liveRecordsProcessed.size();
    Integer bulkUsed = bulkRecordsProcessed.size();
    Integer availableLive = 240 - liveUsed; // 80% of 300
    Integer availableBulk;
    
    // If no live records processed, bulk gets full 300 limit
    if(liveUsed == 0) {
        availableBulk = 300 - bulkUsed;
    } else {
        availableBulk = 60 - bulkUsed; // 20% of 300
    }
    
    System.debug('getAGSQuery - Current usage - Live: ' + liveUsed + '/240, Bulk: ' + bulkUsed + 
                 ', Available - Live: ' + availableLive + ', Bulk: ' + availableBulk);

    // Handle LIVE processing - Keep as current hour only
    if (String.isNotBlank(processType) && processType == Core_ACM_Constants.getProcessTypeValue(Core_ACM_Constants.ProcessType.LIVE)) {
        if (availableLive <= 0) {
            // No capacity, return query that returns no records
            System.debug('getAGSQuery - No LIVE capacity available, returning empty query');
            return BASE_FIELDS + ' WHERE Id = null';
        }
        
        // Return query for LIVE records created in current hour only
        return BASE_FIELDS + 
               ' WHERE Core_Status__c = \'' + Core_ACM_Constants.getStatusValue(Core_ACM_Constants.Status.NEW_STATUS) + '\'' +
               ' AND Core_Process_Type__c = \'' + Core_ACM_Constants.getProcessTypeValue(Core_ACM_Constants.ProcessType.LIVE) + '\'' +
               ' AND Core_Message_Type__c = \'' + Core_ACM_Constants.MESSAGE_TYPE_AGS + '\'' +
               ' AND CreatedDate >= '+ startHourStr +
               ' AND CreatedDate < ' + endHourStr +
               ' ORDER BY CreatedDate ASC' +
               ' LIMIT ' + availableLive;
    }
	
	else{
    // Handle BULK processing - Check past hours first, then current hour
    if (availableBulk <= 0) {
        // No capacity, return query that returns no records
        System.debug('getAGSQuery - No BULK capacity available, returning empty query');
        return BASE_FIELDS + ' WHERE Id = null';
    }
    
    // For BULK: First check if there are any pending records from past hours
    Integer pendingFromPastHours = [
        SELECT COUNT()
        FROM Core_ACM_Integration_Queue__c
        WHERE Core_Status__c = :Core_ACM_Constants.getStatusValue(Core_ACM_Constants.Status.NEW_STATUS)
        AND Core_Message_Type__c = :Core_ACM_Constants.MESSAGE_TYPE_AGS
		AND Core_Message_Type__c = :Core_ACM_Constants.MESSAGE_TYPE_AGS
        AND CreatedDate < :startOfHour
    ];
    
    System.debug('getAGSQuery - BULK records pending from past hours: ' + pendingFromPastHours);
    
    if (pendingFromPastHours > 0) {
        // Return past hour records first (prioritize older records) both Live and Bulk Records
        System.debug('getAGSQuery - Returning BULK records from past hours first');
        return BASE_FIELDS + 
               ' WHERE Core_Status__c = \'' + Core_ACM_Constants.getStatusValue(Core_ACM_Constants.Status.NEW_STATUS) + '\'' +
               ' AND Core_Message_Type__c = \'' + Core_ACM_Constants.MESSAGE_TYPE_AGS + '\'' +
               ' AND CreatedDate < ' + startHourStr +
               ' ORDER BY CreatedDate ASC' +
               ' LIMIT ' + availableBulk;
    } else {
        // No past hour records, return current hour records only BULK records
        System.debug('getAGSQuery - No past hour BULK records, returning current hour records');
        return BASE_FIELDS + 
               ' WHERE Core_Status__c = \'' + Core_ACM_Constants.getStatusValue(Core_ACM_Constants.Status.NEW_STATUS) + '\'' +
               ' AND Core_Process_Type__c = \'' + Core_ACM_Constants.getProcessTypeValue(Core_ACM_Constants.ProcessType.BULK_MODE) + '\'' +
               ' AND Core_Message_Type__c = \'' + Core_ACM_Constants.MESSAGE_TYPE_AGS + '\'' +
               ' AND CreatedDate >= ' + startHourStr +
               ' AND CreatedDate < ' + endHourStr +
               ' ORDER BY CreatedDate ASC' +
               ' LIMIT ' + availableBulk;
    }
	}
}

    //Ganesh Changes End 
}