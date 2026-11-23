/****************************************************************************************************
* Apex Class Name 	: core_S2S_FileUploadCaseCtrl
* Version         	: 1.0 
* LastModifed Date  : 2024-06-14
* Test Class      	: core_S2S_FileUploadCaseCtrlTest
* Function        	: Provides methods to handle file download functionality.
*****************************************************************************************************
* Developer       		Date          	Description
* ----------------------------------------------------------------------------                 
* Bishal Singh  	 2024-06-14    		 Modified
*****************************************************************************************************/
public class core_S2S_FileUploadCaseCtrl {
   
    /************************************************************************************************************
    * Method Name    	: uploadFiles
    * Created Date   	: 2024-06-14
    * Description    	: Upload file to Service cloud with respective to the case.
    * Last Modified By	: Bishal Singh
    ************************************************************************************************************/
    @AuraEnabled(cacheable=false)
    public static String uploadFiles(String recordId, String filedata) {
        try {
            if(String.isNotBlank(FileData)) {
                List<FileDataWP> files = (List<FileDataWP>) JSON.deserialize(filedata, List<FileDataWP>.class);
                String caseObjId = [select ExternalId FROM Case__x where id=:recordId WITH SECURITY_ENFORCED LIMIT 1]?.ExternalId;
                List<ContentVersion__x> cvList = new List<ContentVersion__x>();
                for(FileDataWP file : files) {
                    ContentVersion__x conVer = new ContentVersion__x();
                    conVer.Title__c = file.fileName;
                    conVer.Core_Path_On_Client__c  = '/'+file.fileName;
                    conVer.VersionData__c = file.fileContent;
                    cvList.add(conVer);
                }
                List<Database.SaveResult> sr = Test.isRunningTest() ? new List<Database.SaveResult>() : Database.insertImmediate(cvList);
                Set<Id> idSet = new Set<Id>();
                for(Database.SaveResult saveList : sr ){
                    idSet.add(saveList.getId());
                }
                
                List<ContentDocumentLink__x> cdList = new List<ContentDocumentLink__x>();
                for(ContentVersion__x cv : [SELECT Core_Content_Document__c FROM ContentVersion__x WHERE Id =:idSet WITH SECURITY_ENFORCED]) {
                    ContentDocumentLink__x conDocLink = new ContentDocumentLink__x();
                    conDocLink.LinkedEntityId__c = caseObjId;
                    conDocLink.Core_Content_Document__c = cv.Core_Content_Document__c;
                    cdList.add(conDocLink);
                }
                Database.insertImmediate(cdList);        
            } else {
                return 'record Id is Blank';
            }
            return 'success';
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }
    
    /************************************************************************************************************
    * Class Name    	: FileDataWP
    * Created Date   	: 2024-06-14
    * Description    	: Wrapper Class to wrap details.
    * Created By		: Bishal Singh
    ************************************************************************************************************/
    public class FileDataWP {
        public String fileName;
        public String fileContent;
        public Integer indexNumber;
    }
}