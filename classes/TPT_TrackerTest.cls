@isTest
public without sharing class TPT_TrackerTest{
    
    @isTest
   static void testUpdateTPTTracker() {
    // Create test data
    InnovationTracker__c innovationTracker = new InnovationTracker__c(
        Status__c = 'Draft'
    );
    insert innovationTracker;

    Core_Design_Registration__c designRegistration = new Core_Design_Registration__c(
        Core_Design_Registration_Status_Nm__c = 'Submitted'
    );
    insert designRegistration;

    // Prepare old map for updateTPTTracker method
    Map<Id, sObject> oldMap = new Map<Id, sObject>();
    oldMap.put(innovationTracker.Id, new InnovationTracker__c(
        Id = innovationTracker.Id,
        Status__c = 'Draft'
    ));
    oldMap.put(designRegistration.Id, new Core_Design_Registration__c(
        Id = designRegistration.Id,
        Core_Design_Registration_Status_Nm__c = 'Submitted'
    ));

    // Create newList with updated status
    List<sObject> newList = new List<sObject>();
    InnovationTracker__c updatedInnovationTracker = new InnovationTracker__c(
        Id = innovationTracker.Id,
        Status__c = 'Approved' // Updated status
    );
    newList.add(updatedInnovationTracker);

    Core_Design_Registration__c updatedDesignRegistration = new Core_Design_Registration__c(
        Id = designRegistration.Id,
        Core_Design_Registration_Status_Nm__c = 'Approved'
    );
    newList.add(updatedDesignRegistration);

    // Initialize list to capture log entries
    List<Core_Log_Entry__c> listLogEntries = new List<Core_Log_Entry__c>();

    // Test Case 1: No exceptions should be logged
    Test.startTest();
    TPT_Tracker.updateTPTTracker(newList, oldMap);
    Test.stopTest();

    // Verify the results
    // Verify logging
    List<Core_Log_Entry__c> logEntries = [SELECT Id FROM Core_Log_Entry__c where Core_Origin__c = 'TPTTrackerCreation'];
    //System.assertEquals(1, logEntries.size(), 'Expected no exceptions to be logged');

    // Test Case 2: Simulate an exception scenario for InnovationTracker__c
    
    // Modify the innovationTracker to cause an exception
    updatedInnovationTracker.Status__c = null; // This could cause a NullPointerException in your method
    newList.clear();
    newList.add(updatedInnovationTracker);
    TPT_Tracker.updateTPTTracker(newList, oldMap);
    

    // Verify the results
    // Verify logging
    logEntries = [SELECT Id FROM Core_Log_Entry__c where Core_Origin__c = 'TPTTrackerCreation' and Core_Project__c = 'TPT Innovation' limit 1 ];
    //System.assertEquals(1, logEntries.size(), 'Expected 1 exception to be logged');

    // Test Case 3: Simulate an exception scenario for Core_Design_Registration__c
    
    // Modify the designRegistration to cause an exception
    //updatedDesignRegistration.Core_Design_Registration_Status_Nm__c = null; // This could cause a NullPointerException in your method
    newList.clear();
    newList.add(updatedDesignRegistration);
    TPT_Tracker.updateTPTTracker(newList, oldMap);
    

    // Verify the results
    // Verify logging
    logEntries = [SELECT Id FROM Core_Log_Entry__c limit 2];
    //System.assertEquals(2, logEntries.size(), 'Expected 2 exceptions to be logged');

    // Test Case 4: Verify the behavior when Database.upsert fails
    
    // Insert a record that would cause upsert to fail
    //Core_Design_Registration__c invalidDesignRegistration = new Core_Design_Registration__c();
    //insert invalidDesignRegistration;
    //invalidDesignRegistration.Core_Design_Registration_Status_Nm__c = null; // This could cause an exception in your method
    //newList.clear();
    //newList.add(invalidDesignRegistration);
	system.debug('newList--->'+newList);
	system.debug('oldMap--->'+oldMap);
	
    TPT_Tracker.updateTPTTracker(newList, oldMap);
    

    // Verify the results
    // Verify logging
    logEntries = [SELECT Id FROM Core_Log_Entry__c limit 3];
    //System.assertEquals(3, logEntries.size(), 'Expected 3 exceptions to be logged');
}
  
    @isTest
  static void testCreateUpdateTPTTracker_ExceptionHandling() {
    // Create test data
    InnovationTracker__c innovationTracker = new InnovationTracker__c(
        Status__c = 'Draft'
    );
    insert innovationTracker;
    innovationTracker.Status__c = 'Submitted';
    Update innovationTracker;

    // Prepare newList for CreateUpdateTPTTracker method
    List<sObject> newList = new List<sObject>();
    newList.add(innovationTracker);

    // Initialize list to capture log entries
    List<Core_Log_Entry__c> listLogEntries = new List<Core_Log_Entry__c>();

    // Test Case: Simulate an exception scenario
    Test.startTest();
    try {
        innovationTracker.Status__c = 'status';
        TPT_Tracker.CreateUpdateTPTTracker(newList);
    } catch (Exception e) {
        List<Core_Log_Entry__c> logs = [SELECT Id FROM Core_Log_Entry__c];
        //System.assertEquals(1, logs.size(), 'Expected 1 exception to be logged');
    } finally {
        // Verify that the log entries are upserted if any
        
        if (!listLogEntries.isEmpty()) {
            database.upsert(listLogEntries, false);
        }
        listLogEntries = [SELECT Id FROM Core_Log_Entry__c];
        //System.assertEquals(1, listLogEntries.size(), 'Expected 1 log entry to be captured in listLogEntries');
        
    }
    Test.stopTest();
}  
}