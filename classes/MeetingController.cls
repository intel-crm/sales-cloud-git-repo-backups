public with sharing class MeetingController {
  @AuraEnabled
    public static void saveMeetings(Id recordId, List<Map<String, String>> meetings) {
        List<Account_Brief_Summary_POC__c> recordsToSave = new List<Account_Brief_Summary_POC__c>();

        for (Map<String, String> meeting : meetings) {
            Account_Brief_Summary_POC__c record = new Account_Brief_Summary_POC__c(
                Id = recordId,
                Account_Brief_Summary__c = meeting.get('Account_Brief_Summary__c'),
                Meeting_Invite__c = meeting.get('Meeting_Invite__c'),
                Attendees__c = meeting.get('Attendees__c')
            );
            recordsToSave.add(record);
        }

        if (!recordsToSave.isEmpty()) {
            upsert recordsToSave;
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<Account_Brief_Summary_POC__c> fetchMeetings(Id recordId) {
        return [
            SELECT Id, Account_Brief_Summary__c, Meeting_Invite__c, Attendees__c
            FROM Account_Brief_Summary_POC__c
            WHERE Id = :recordId
        ];
    }

    @AuraEnabled
    public static String downloadPdf(Id accountBriefSummaryId) {
        // Generate a PDF for the record
        PageReference pdfPage = Page.AccountBriefSummaryPDFPage;
        pdfPage.getParameters().put('id', accountBriefSummaryId);
        Blob pdfBlob = pdfPage.getContentAsPDF();
        return EncodingUtil.base64Encode(pdfBlob);
    }
}