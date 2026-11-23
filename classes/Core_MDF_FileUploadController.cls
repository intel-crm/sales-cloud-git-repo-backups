public with sharing class Core_MDF_FileUploadController {
    
/****************************************************************************************************** 
Method Name:        fetchDocumentIds
@return  :          
@parameters:        Activity Id/unsaved documents
Description:        Method to return list of documents by activity id or doc id's
Added By:           Sridhar - 03/04/2019
Modified By:        Date:      Changes: 
*******************************************************************************************************/
    @AuraEnabled
    public static List<WrapperDocs> fetchDocumentIds(string pfrId,list<string> unsaveddocs)
    {
        List<WrapperDocs> wrapperdocIds = new List<WrapperDocs>();
        //List<ContentDocument> docIds = new List<ContentDocument>();
        //List<ContentDocumentLink> docIdsLink = new List<ContentDocumentLink>();
        WrapperDocs docId;
        try {
            
			if (unsaveddocs.size() > 0 && unsaveddocs != NULL) // Select the documents which are not associated to activity
            {
                //docIds = [SELECT Title,Id,FileExtension FROM ContentDocument WHERE Id IN: unsaveddocs
                //          order by Title];
                for (ContentDocument contentDocId:[SELECT Title,Id,FileExtension FROM ContentDocument WHERE Id IN: unsaveddocs
                          order by Title])
                {
                    docId = new WrapperDocs();
                    docId.Title = contentDocId.Title + '.' + contentDocId.FileExtension;
                    docId.ContentDocumentId = contentDocId.Id;
                    wrapperdocIds.add(docId);
                }
            }
            else if(pfrId != null ) // Select the documents which are associated to activity
            {
                //docIdsLink = [SELECT ContentDocument.Title,ContentDocumentId,ContentDocument.FileExtension FROM ContentDocumentLink WHERE LinkedEntityId = :pfrId 
                //          order by ContentDocument.Title];
                for (ContentDocumentLink contentDocId:[SELECT ContentDocument.Title,ContentDocumentId,ContentDocument.FileExtension FROM ContentDocumentLink WHERE LinkedEntityId = :pfrId 
                          order by ContentDocument.Title])
                {
                    docId = new WrapperDocs();
                    docId.Title = contentDocId.ContentDocument.Title + '.' + contentDocId.ContentDocument.FileExtension;
                    docId.ContentDocumentId = contentDocId.ContentDocumentId;
                    wrapperdocIds.add(docId);
                }
            }
                
        }
        catch (Exception e){Core_MDF_CCP_UtilityClass.logError(e);throw e;//throw new AuraHandledException(Label.Core_MDF_ShowFile_Error + e.getMessage()); 
        }
        
        return wrapperdocIds;
    }
    
/****************************************************************************************************** 
Method Name:        deleteDocumentIds
@return  :          
@parameters:        docIds
Description:        delete the document selected by user
Added By:           Sridhar - 03/04/2019
Modified By:        Date:      Changes: 
*******************************************************************************************************/
    @AuraEnabled
    public static void deleteDocumentIds(list<string> docIds)
    {
        List<ContentDocumentLink> doclinkIdsDel = new List<ContentDocumentLink>();
        List<ContentDocument> docIdsDel = new List<ContentDocument>();
        
        try 
        {
            //decimal val = 1/0;
            if (docIds.size() > 0)
            {
                doclinkIdsDel = [SELECT Id FROM ContentDocumentLink WHERE ContentDocumentId IN: docIds
                          AND LinkedEntityId = null];
                
                docIdsDel = [SELECT Id FROM ContentDocument WHERE Id IN: docIds];
                
                if (doclinkIdsDel.size() > 0){Database.delete(doclinkIdsDel);
                }
                if (docIdsDel.size() > 0)
                {
                    Database.delete(docIdsDel);    
                }
                
            }
       }
        catch (Exception e){Core_MDF_CCP_UtilityClass.logError(e);throw e;//throw new AuraHandledException(Label.Core_MDF_DeleteFile_Error + e.getMessage()); 
        }
    }
    
    public class WrapperDocs{
        @AuraEnabled
        public string Title {get;set;}
        @AuraEnabled
        public string ContentDocumentId {get;set;}
        @AuraEnabled
        public string docurl {get;set;}
        
        public WrapperDocs(){
         	Title='';
         	ContentDocumentId='';
       }
    }
}