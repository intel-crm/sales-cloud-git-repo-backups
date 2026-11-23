public class PMP_File_Uploader {
	@future(callout=true)
    public static void insertFile(String parentId, String fileURL) {
        
        if(String.isNotBlank(parentId) && String.isNotBlank(fileURL)) {
            BlobData b = getContent(fileURL);
            system.debug('BlobData***>>>'+b);
            if(b != null && b.data != null) { 
                
                List<Network> psmNetwork = [SELECT Id FROM Network WHERE Name =: PMP_Utility.getValue('Marketplace_Community_Name') ];
                Id networkId = psmNetwork.size() > 0 ? psmNetwork[0].Id : null;
                
                String fileName = b.type != null ? (parentId + '.' + b.type) : parentId;
                ContentVersion cv = new ContentVersion(Title=parentId + '__' + b.type, VersionData=b.data, Origin='H',NetworkId=networkId, PathOnClient=fileName);
                insert cv;  
                
                /*
                ContentAsset ca = new ContentAsset();
                List<ContentAsset> contAsset = [SELECT Id FROM ContentAsset WHERE DeveloperName=:parentId AND MasterLabel=:parentId AND isVisibleByExternalUsers=true];
                if(contAsset.size() > 0) {
                    ca = contAsset[0];
                } else {
                    ca = new ContentAsset(DeveloperName=parentId, MasterLabel=parentId,isVisibleByExternalUsers=true);
                    insert ca;
                } */
                
                List<ContentVersion> contVer = [SELECT Id,ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];
                Id contDocId = contVer.size() > 0 ? contVer[0].ContentDocumentId : null;
                
                if(contDocId != null) {                    
                    
                    /*
                    if(b.type != null) {
                        ContentDocument cd = new ContentDocument(Id=contDocId,ContentAssetId=ca.Id);
                        update cd;
                    }*/
                    
                    ContentDocumentLink cdl = new ContentDocumentLink(ContentDocumentId=contDocId, LinkedEntityId=parentId, ShareType = 'I', Visibility = 'AllUsers');
                    insert cdl;
                } 
            }
        }
        
        //return null;
    }
    
	public static BlobData getContent(String fileURL) {
        
        BlobData b;
        
        if(String.isNotBlank(fileURL)) {
            
            Http h = new Http(); 
            HttpRequest req = new HttpRequest();
            req.setEndpoint(fileURL);
            req.setMethod('GET'); 
            req.setCompressed(true);
            req.setTimeout(60000); 
            HttpResponse res = h.send(req); 
            
            if(res != null && res.getStatusCode() == 200) {
                b= new BlobData();
                b.data = res.getBodyAsBlob();
                String contType = res.getHeader('Content-Type');
                if(contType != null) {
                    b.type = contType.contains('mp4') ? 'mp4' : contType.contains('zip') ? 'zip' : contType.contains('pdf') ? 'pdf' : contType.contains('jpeg') ? 'jpeg' : contType.contains('png') ? 'png' : contType.contains('plain') ? 'txt' : contType.contains('presentation') ? 'pptx' : contType.contains('document') ? 'docx' : '';
                }
                
            }
        }
        return b;
    }
    
    public class BlobData {
        Blob data { get; set; }
        String type { get; set; }
    }
}