public class AttachmentRepository {
    public static Attachment__c insertRecord(Id contactId, String key) {
    Attachment__c attachment = new Attachment__c();
    attachment.Contact__c = contactId;
    attachment.Key__c = key;
    insert attachment;

    return attachment;
}

}