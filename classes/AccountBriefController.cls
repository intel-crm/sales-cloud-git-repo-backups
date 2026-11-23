public class AccountBriefController {
@AuraEnabled
    public static void saveMeetingData(List<Map<String, String>> meetings) {
        List<Account_Brief_Summary_POC__c> meetingRecords = new List<Account_Brief_Summary_POC__c>();

        for (Map<String, String> meeting : meetings) {
            Account_Brief_Summary_POC__c record = new Account_Brief_Summary_POC__c(
                Account_Brief_Summary__c = meeting.get('accountBrief'),
                Meeting_Invite__c = meeting.get('meetingInvite'),
                Attendees__c = meeting.get('attendees')
            );
            meetingRecords.add(record);
        }
        
        insert meetingRecords;
    }
}