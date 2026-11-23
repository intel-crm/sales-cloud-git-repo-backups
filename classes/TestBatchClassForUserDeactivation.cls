global class TestBatchClassForUserDeactivation implements Database.Batchable<sObject>{
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
       String query = 'Select Id,LastLoginDate,ContactId from User Where contactID IN (Select Core_Contact_Id__c FROM Core_Contact_Entitlement__c WHERE Core_Display_Nm__c =\'Partner Portal\') and contactID NOT IN (Select Core_Contact_Id__c FROM Core_Contact_Entitlement__c WHERE Core_Display_Nm__c = \'Resource & Design Center for Secure Content\') and LastLoginDate < LAST_N_MONTHS:6 limit 10';
       system.debug('NARA***'+query);
       //system.debug('NARA'+Database.getQueryLocator(query));
       return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<User> scope)
    {
        system.debug('***NARA*** In execute'+scope);
    }
    global void finish(Database.BatchableContext BC) {
    }

}

//TestBatchClassForUserDeactivation  exe = new TestBatchClassForUserDeactivation();
//Database.executeBatch(exe);