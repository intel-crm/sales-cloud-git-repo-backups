/****************************************************************************************************
Apex Class Name : PSG_fileDownloadController
Version         : 1.0 
Created Date    : 08/13/2021
Function        : This class is used by disty to view & download files.
Modifications   :
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Shreyash                    08/13/2021                Created
*****************************************************************************************************/
@isTest
public with sharing class PSG_fileDownloadController {
    
    /*@AuraEnabled(Cacheable=true)
    public static  List<fileWrapper> getPdfDownloadLink(){
        String folderName = Label.Download_Price_Book_Folder_Name;
        Set<String> myFolderNameSet = new Set<String>();
        if(folderName.contains(':')){
            for(String name:folderName.split(':')){
                myFolderNameSet.add(name);
            }
        }
        else{
            myFolderNameSet.add(folderName);
        }
        Map<Id,ContentFolderItem> contentFolderItemMap = new Map<Id,ContentFolderItem>([SELECT Id,Title FROM ContentFolderItem WHERE ParentContentFolderId
                                                                                        IN (SELECT Id FROM ContentFolder WHERE Name IN: myFolderNameSet) and isDeleted = false order by Id]);
        Map<Id,ContentVersion> contentversionMap = new Map<Id,ContentVersion>([SELECT id,ContentDocumentId FROM ContentVersion WHERE (ContentDocumentId IN : contentFolderItemMap.keySet())  order by ContentDocumentId]);
        
        List<fileWrapper> downloadableFileList=new List<fileWrapper>();
        if(contentFolderItemMap != null && !contentFolderItemMap.isEmpty()){
            for( ContentDistribution conDistri : [SELECT ContentDownloadUrl, ContentDocumentId FROM ContentDistribution WHERE (ContentVersionId IN : contentversionMap.keySet())  order by ContentDocumentId]){
                downloadableFileList.add(new fileWrapper(contentFolderItemMap.get(conDistri.ContentDocumentId).Id,contentFolderItemMap.get(conDistri.ContentDocumentId).Title,conDistri.ContentDownloadUrl));
            }
        }
        if(!downloadableFileList.isEmpty()){
            return downloadableFileList;
        }
        else{
             throw new AuraHandledException('Error while Processing data');  
        }
       
    }
    public class fileWrapper{
        @AuraEnabled public Id fileId{get;set;}
        @AuraEnabled public String fileTitle{get;set;}
        @AuraEnabled public String fileUrl{get;set;}
        public fileWrapper(ID fileID,String fileTitle,String fileUrl){
            this.fileID=fileID;
            this.fileTitle=fileTitle;
            this.fileUrl=fileUrl;
        }
    }*/
}