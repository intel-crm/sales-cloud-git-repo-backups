/****************************************************************************************************
* Apex Class Name 	: core_S2S_FileDownloadCaseController
* Version         	: 1.0 
* LastModifed Date  : 2024-06-14
* Test Class        : core_S2S_FileDownloadCaseControllerTest
* Function        	: Provides methods to handle file download functionality.
*****************************************************************************************************
* Developer       		Date          	Description
* ----------------------------------------------------------------------------                 
* Bishal Singh  	 2024-06-14    		 Modified
*****************************************************************************************************/
public without sharing class core_S2S_FileDownloadCaseController {

    /************************************************************************************************************
    * Method Name    	: getRelatedFilesByRecordId
    * Created Date   	: 2024-06-14
    * Description    	: Retrieves related files by record Id.
    * Last Modified By	: Bishal Singh
    ************************************************************************************************************/
    @AuraEnabled(cacheable=false)
    public static Map<Id, ContentVersion__x> getRelatedFilesByRecordId(String recordId) {
        String caseObjId = [SELECT ExternalId FROM Case__x WHERE Id=:recordId LIMIT 1]?.ExternalId;
        List<String> fileIDs = new List<String>();
        for(ContentDocumentLink__x cntLink : [SELECT Id, ContentDocumentId__c FROM ContentDocumentLink__x WHERE LinkedEntityId__c =:caseObjId]) {
            fileIDs.add(cntLink.ContentDocumentId__c);
        }
        List<ContentVersion__x> docs = [SELECT Id, Title__c, ContentDocumentId__c, ContentDocumentId__r.FileType__c, VersionData__c FROM ContentVersion__x WHERE ContentDocumentId__c IN :fileIDs ORDER BY createddate__c DESC];
        Map<Id, ContentVersion__x> mapIdTitle = new Map<Id, ContentVersion__x>();
        for (ContentVersion__x docLink : docs) {
            mapIdTitle.put(docLink.ContentDocumentId__c, docLink);
        }
        return mapIdTitle;
    }
    
    /************************************************************************************************************
    * Method Name    	: getContentVersion
    * Created Date   	: 2024-06-14
    * Description    	: Retrieves ContentVersion data.
    * Last Modified By	: Bishal Singh
    ************************************************************************************************************/
    @AuraEnabled(cacheable=true)
    public static String getContentVersion(String recordId) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:Service_Cloud_API/sobjects/ContentVersion/' + recordId + '/VersionData');
        req.setMethod('GET');
        Http http = new Http();
        HTTPResponse res = http.send(req);
        System.debug(res.getBody());
        return (EncodingUtil.base64Encode(res.getBodyAsBlob()));
    }
}