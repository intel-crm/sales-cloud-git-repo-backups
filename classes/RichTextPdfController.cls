public with sharing class RichTextPdfController {
    @AuraEnabled(cacheable=true)
    public static String getRichTextContent(Id recordId) {
        Sales_Feedback__c record = [SELECT Rich_text__c FROM Sales_Feedback__c WHERE Id = :recordId LIMIT 1];
        return record.Rich_text__c;
    }
}