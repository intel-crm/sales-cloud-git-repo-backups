public with sharing class CRM_MultiUserSelectionController {
    @AuraEnabled(cacheable=true)
    public static List<User> searchUsers(String searchTerm) {
        return [SELECT Id, Name FROM User WHERE Name LIKE :('%' + searchTerm + '%') LIMIT 10]; // IsActive = true AND
    }

    @AuraEnabled
    public static void saveUserIds(Id recordId, String userIds) {
        Executive_Meeting_Brief__c meetingBrief = [SELECT Id FROM Executive_Meeting_Brief__c WHERE Id = :recordId LIMIT 1];
        //meetingBrief.CRM_ReviewedBy__c = userIds;
        update meetingBrief;
    }
}