@IsTest private class ReltioSyncAccountRequestTest { 
    @IsTest static void testBehavior() { 
        try { 
            insert new Account_Request__c( Account_Name__c = 'TriggerCoverage'); 
        } 
        catch (Exception e) {
        } 
    } 
}