/****************************************************************************************************
Apex Class Name : PSG_ContentDocLinkBusinessLogic
Version         : 1.0 
Created Date    : 01/05/2021
Function        : Business logic class for ContentDocumentLink trigger.
Modifications   :
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Shreyash                     01/05/2021               Created
*****************************************************************************************************/
public without sharing class  PSG_ContentDocLinkBusinessLogic {
    /************************************************************************************************************
	*Method Name : afterInsertUpdateOperationsNew
	*Created Date: 08/13/2021
	*Author: Shreyash
	*Description : Performs operations on after context of trigger.To create download link for file uploaded in the library.
	************************************************************************************************************/
    public static void afterInsertUpdateOperations(List<ContentDocumentLink> cdlList,Map<Id,ContentDocumentLink> oldMap,Boolean isInsert){
        try{
            Set<String> myLibraryNameSet = new Set<String>();
            String libraryName=Label.PSG_Library_Name;
            if(libraryName!=null){
                if(libraryName.contains(':')){
                    for(String name:libraryName.split(':')){
                        myLibraryNameSet.add(libraryName);
                    }
                }else{
                    myLibraryNameSet.add(libraryName);
                }
            }
            
            List<ContentWorkspace> Workspace=new List<ContentWorkspace>([Select id from ContentWorkspace where Name IN :myLibraryNameSet]);
            Set<Id> myLibraryIdSet = new Set<Id>();
            for(ContentWorkspace cw:Workspace){
                myLibraryIdSet.add(cw.Id);
            }
            Set<Id> cvIds = new Set<Id>();
            for(ContentDocumentLink cdl : cdlList){
                for(Id cwId:myLibraryIdSet){
                    if(cdl.LinkedEntityId==cwId){
                        cvIds.add(cdl.ContentDocumentId);
                    }
                }
            }
            List<ContentDistribution> cdListToInsert = new List<ContentDistribution>();
            if(isInsert){
                for(ContentVersion cv : [SELECT Id,contentDocumentId, firstPublishLocationId,Title FROM ContentVersion WHERE contentDocumentId IN : cvIds]){
                    cdListToInsert.add(new ContentDistribution(
                        ContentVersionId = cv.Id,
                        Name = cv.Title
                    ));
                }
                if(!cdListToInsert.IsEmpty()){
                    Database.insert(cdListToInsert,false,AccessLevel.System_mode);
                }
            }   
            
        }catch(Exception ex){
            PSG_Utility.logError(ex);
        }
    }
}