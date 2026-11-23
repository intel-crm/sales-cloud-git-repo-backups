trigger Core_Banner_Text_trigger on Core_Banner_Text__c (before insert,before update) {
    String allowedUsersStr = System.Label.Core_Home_Page_Users_List;
    Set<String> allowedUsers = new Set<String>(allowedUsersStr.split(';'));
	Set<String> existingRecords = new Set<String>();

    for (Core_Banner_Text__c record : Trigger.new) {
        if (!allowedUsers.contains(UserInfo.getUserEmail())) {
            record.addError('You do not have access to create/edit records in this object.');
        }
    }
    
    // Query existing records
    for (Core_Banner_Text__c record : [SELECT core_CRM_type__c, Core_CRM_Project__c FROM Core_Banner_Text__c 
                                   WHERE core_CRM_type__c IN ('Home Page Default','KPI Header Default','KPI Body Default')]) {
        existingRecords.add(record.core_CRM_type__c + '||' + record.Core_CRM_Project__c);
    }

    // Check new records
    for (Core_Banner_Text__c newRecord : Trigger.new) {
        String key = newRecord.core_CRM_type__c + '||' + newRecord.Core_CRM_Project__c;
        
        if (existingRecords.contains(key)) {
            newRecord.addError('A record with this Type and Project Name already exists.');
        }
    }
    
    
}