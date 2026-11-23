/**************************************************************************************
Apex Class Name:  Core_CIMHandlerPB 
Version     : 1.0 
Created Date: 12 JUNE 2020
Function    : Subscribe to the Platform Event.
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Sanket Mahajan             06/12/2020              Original Version

*************************************************************************************/
public class Core_CIMHandlerPB {
    
    /*************
    * Method name  : updateAccounts
    * Description  : This method reads the attachment body and passes it to the XMLParserHandler.
    * Return Type  : VOID
    * Parameter    : recordid
    *************/
    
    @InvocableMethod
    public static void updateAccounts(List<id> recordId) {
    system.debug('inside process builder');
    //list<string> body = new List<string>();
    String body = '';
        List<ContentDocumentLink> contentDocLink = [select id,ContentDocument.createddate,contentdocument.latestpublishedversion.versiondata from contentDocumentLink  
                                                where LinkedEntityId in ( SELECT Id FROM Core_Integration_Inbound_Message__c) 
                                                and LinkedEntity.Type='Core_Integration_Inbound_Message__c' and LinkedEntityId =:recordId[0] order by ContentDocument.createddate desc limit 1 ];
        
        for(ContentDocumentLink cdl:contentDocLink ){
        
            //body.add(EncodingUtil.base64Decode(EncodingUtil.base64Encode(cdl.contentdocument.latestpublishedversion.versiondata)).toString());
            body = EncodingUtil.base64Decode(EncodingUtil.base64Encode(cdl.contentdocument.latestpublishedversion.versiondata)).toString();
        
        }
        //Core_XMLParserHandler.parse(body,recordId[0]);
    }
}