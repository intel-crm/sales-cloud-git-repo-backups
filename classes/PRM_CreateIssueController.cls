public with sharing class PRM_CreateIssueController {
        @AuraEnabled  
        public static string saveCase(ServiceNow_Case__c caseRecNew, List<FileDataWrapper> filesData1) {  
          string caseId;  
          try{  
            Insert caseRecNew;  
            List<ContentVersion> contentVersions = new List<ContentVersion>();
            caseId = caseRecNew.Id; 
            if(filesData1!=null) {
              for (PRM_CreateIssueController.FileDataWrapper fileData : filesData1) {
                String fileContent = fileData.file;
                String fileName = fileData.fileName;
                String base64File = EncodingUtil.urlDecode(fileContent, 'UTF-8');  
                ContentVersion contentVersion = new ContentVersion();
                contentVersion.Title = fileName;
                contentVersion.PathOnClient = fileName;
                contentVersion.VersionData = EncodingUtil.base64Decode(base64File);
                contentVersion.FirstPublishLocationId = caseId; // Set the appropriate parent record Id
                contentVersions.add(contentVersion);
            }
    
            insert contentVersions;
        }
          } catch(Exception ex){  
           // system.debug('Exception===>'+ex.getMessage());  
          }  
          return caseId;  
        } 
        
            @AuraEnabled  
      static public Boolean checkIfUserHasAssignedPermissionSet() {
        Boolean psAssignedUser;
        List<PermissionSetAssignment> psAssigned = [ select Id from PermissionSetAssignment where PermissionSetId IN ( select Id from PermissionSet where Name = 'PRM_Incident_Management') and AssigneeId IN (select Id from User where id = :UserInfo.getUserId() ) ];
        psAssignedUser = psAssigned.size() > 0 ? true : false;
        return psAssignedUser;
}

public class FileDataWrapper {
 @AuraEnabled public String fileName { get; set; }
 @AuraEnabled public String file { get; set; }
}
}