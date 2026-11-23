public without sharing class CRM_CheckFolderAccess {
    public static void checkUserAccessForFolder(String folderId) {
        String endpoint = '/services/data/v58.0/folders/' + folderId + '/shares';
        
        HttpRequest request = new HttpRequest();
        request.setEndpoint(URL.getOrgDomainUrl().toExternalForm() + endpoint);
        request.setMethod('GET');
        
        request.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
        request.setHeader('Content-Type', 'application/json');
        
        Http http = new Http();
        
        try {
            HttpResponse response = http.send(request);
            System.debug(response.getBody());
            if (response.getStatusCode() == 200) {
                List<FolderShare> folderShares = (List<FolderShare>) JSON.deserialize('['+response.getBody().toString()+']', List<FolderShare>.class);
                //System.debug(folderShares);
                List<String> str = response.getBody().toString().split('sharedWithId":');
                String str2 = str.remove(0);
                //system.debug(str.Size());
                //system.debug(str);
                //system.debug(str2);
                for(String str1 : str){
                    system.debug(str1.split(',')[0]); 
                }
                for (FolderShare share : folderShares) {
                    System.debug('User/Group ID: ' + share.sharedEntityId);
                    System.debug('Access Level: ' + share.shareType);
                }
            } else {
                System.debug('Error: ' + response.getStatusCode() + ' - ' + response.getBody());
            }
        } catch (Exception e) {
            System.debug('Exception: ' + e.getMessage());
        }
    }

    public class FolderShare {
        public String sharedEntityId { get; set; } // User or Group ID
        public String shareType { get; set; } // Access level (e.g., Viewer, Editor)
    }
}