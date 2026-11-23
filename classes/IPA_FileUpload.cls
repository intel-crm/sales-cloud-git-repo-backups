/****************************************************************************************************************************
Apex Class Name     : IPA_FileUpload 
Version             : 1.0
Created Date        : Sep 2025
Developer           : 
Function 			: Allows users to upload file in IPA Site
****************************************************************************************************************************/

public class IPA_FileUpload {
	 @AuraEnabled
  public static String uploadFile(String base64, String filename, String recordId) {
        ContentVersion cv = createContentVersion(base64, filename);
        ContentDocumentLink cdl = createContentLink(cv.Id, recordId);
        if (cv == null || cdl == null) { return null; }
        return cdl.Id;
  }

  public static ContentVersion createContentVersion(String base64, String filename) {
    system.debug('Inside create content version apex params'+base64);
    system.debug('FileName is: '+fileName);
    ContentVersion cv = new ContentVersion();
    cv.VersionData = EncodingUtil.base64Decode(base64);
    cv.Title = filename;
    cv.PathOnClient = filename;
    try {
      insert cv;
      return cv;
    } catch(DMLException e) {
      System.debug(e);
      return null;
    }
  }


  public static ContentDocumentLink createContentLink(String contentVersionId, String recordId) {
              if (contentVersionId == null || recordId == null) { return null; }
    ContentDocumentLink cdl = new ContentDocumentLink();
    cdl.ContentDocumentId = [SELECT ContentDocumentId  FROM ContentVersion  WHERE Id =: contentVersionId].ContentDocumentId;
    cdl.LinkedEntityId = recordId;
    // ShareType is either 'V', 'C', or 'I'
    // V = Viewer, C = Collaborator, I = Inferred
    cdl.ShareType = 'V';
    try {
      insert cdl;
      return cdl;
    } catch(DMLException e) {
      System.debug('Error occured:'+e);
      return null;
    }
  }
}