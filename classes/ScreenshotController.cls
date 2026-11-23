public with sharing class ScreenshotController {
    @AuraEnabled
    public static Id uploadScreenshot(Id recordId, String base64Image) {
        // Decode the Base64 string to a Blob
        Blob imageBlob = EncodingUtil.base64Decode(base64Image);

        // Create a new ContentVersion (Salesforce Files)
        ContentVersion file = new ContentVersion();
        file.Title = 'Page Screenshot';
        file.PathOnClient = 'PageScreenshot.png';
        file.VersionData = imageBlob;
        file.IsMajorVersion = true;
        insert file;

        // Link the file to the record
        ContentDocumentLink link = new ContentDocumentLink();
        link.ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :file.Id].ContentDocumentId;
        link.LinkedEntityId = recordId;
        link.ShareType = 'V'; // Viewer permission
        link.Visibility = 'AllUsers';
        insert link;

        return file.Id;
    }
}