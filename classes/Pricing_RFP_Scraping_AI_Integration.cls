/****************************************************************************************************************************************************
 * Class Name      : Pricing_RFP_Scraping_AI_Integration
 * Version               : 1.0
 * Created Date          :  04-02-2026 
 * Modification Log      :
 * Developer            Date             Description
 * ----------------------------------------------------------------------------------------------------------------------------------------------------
 *  Aswin Selvaraj    04-02-2026        This class implements the Quote Agentic RFP generation
 ******************************************************************************************************************************************************/

public class Pricing_RFP_Scraping_AI_Integration {
    
    /***********************************************************************************************************
    Method Name:        checkRFPDocumentExists
    Description:        Check if RFP document exists for the given quote
    @Added By:          Sinduja - 09-April-2026
    Modified By:        Date:       Changes:
    ************************************************************************************************************/
    @AuraEnabled
    public static Map<Id, List<Id>> checkRFPDocumentExists (List<Id> quoteIds){
    try {
        system.debug('Inside checkRFPDocumentExists method:'+quoteIds);
        
       // Get document title pattern from custom label
       String documentTitlePattern = System.Label.Pricing_AI_RFP_Scraping_Document_Title;
 
        List<ContentDocumentLink> contentDocLinksList = [
            SELECT Id, ContentDocumentId, LinkedEntityId,
                   ContentDocument.Title 
            FROM ContentDocumentLink 
            WHERE LinkedEntityId IN :quoteIds  
            //AND ContentDocument.CreatedBy.UserType = 'PowerPartner'
            AND ContentDocument.Title LIKE :documentTitlePattern
        ];
        
        system.debug('Inside checkRFPDocumentExists contentDocLinksList:'+contentDocLinksList.size());
        
        Map<Id, List<Id>> quoteIdToContentDocumentsMap = new Map<Id, List<Id>>();
        
         // Initialize map for all quote IDs (even if they don't have RFP documents)
        for(Id quoteId : quoteIds) {
            quoteIdToContentDocumentsMap.put(quoteId, new List<Id>());
        }
        
        for(ContentDocumentLink cdl : contentDocLinksList) {
            if(!quoteIdToContentDocumentsMap.containsKey(cdl.LinkedEntityId)) {
                quoteIdToContentDocumentsMap.put(cdl.LinkedEntityId, new List<Id>{cdl.ContentDocumentId});
            }
            else{
                quoteIdToContentDocumentsMap.get(cdl.LinkedEntityId).add(cdl.ContentDocumentId);
            }
        }
        
        system.debug('INSIDE quoteIdToContentDocumentsMap'+quoteIdToContentDocumentsMap);
        return quoteIdToContentDocumentsMap;
        
    } catch (Exception exp) {
            system.debug('Inside checkRFPDocumentExists catch:'+exp.getMessage());
            Core_Log_Entry__c logEntry =new Core_Log_Entry__c(Core_Message__c = 'Error',Core_Details__c = exp.getMessage(), Core_Origin__c='Pricing_RFP_Scraping_AI_Integration.checkRFPDocumentExists', Core_Severity__c='Low', Core_When__c=System.Now(), Core_Project__c = 'IQR');          
            insert logEntry;
            return new Map<Id, List<Id>>();
        }
    }
	/***********************************************************************************************************
    Method Name:        updateQuoteStatus
    Description:        Update Agentic Drafting Status to 'In Progress'
    @Added By:          Aswin - 02-April-2026
    Modified By:        Date:       Changes:
    ************************************************************************************************************/
    @AuraEnabled
    public static void updateQuoteStatus(List<Id> quoteIds) {
        List<SBQQ__Quote__c> quoteToUpdate = new List<SBQQ__Quote__c>();
    	
        for(Id quoteId : quoteIds) {
            if(quoteId != null) {
                SBQQ__Quote__c quoteRec = new SBQQ__Quote__c(Id = quoteId);
                quoteRec.Pricing_AI_RFP_Scraping_Status__c = 'In Progress';
                quoteToUpdate.add(quoteRec);
            }
        }
        
        if(!quoteToUpdate.isEmpty()) {
            SBQQ.TriggerControl.disable();
            Database.SaveResult[] saveResultList= Database.update(quoteToUpdate);
            SBQQ.TriggerControl.enable();
        }
            
      }

	 /*****************************************************************************************************************************************
    Method Name:        fetchQuoteDetails
    Description:        To Fetch Quote and Document Details, then serialize it into a JSON string for Integration outbound.
    @Added By:          Aswin - 02-April-2026
    Modified By:        Date:       Changes:
    ******************************************************************************************************************************************/
    @AuraEnabled
    public static void fetchQuoteDetails(List<Id> quoteIds)
    {
        try{
			List<SBQQ__Quote__c> quoteRecords = new List<SBQQ__Quote__c>();
			List<ContentDocumentLink> contentDocLinksList = new List<ContentDocumentLink>();
            Map<Id, List<String>> quoteIdToContentDocumentsMap = new Map<Id, List<String>>();
            Map<String,String> quoteIdToJsonMap = new Map<String,String>();

			if(quoteIds != null){
                quoteRecords = [SELECT Id FROM SBQQ__Quote__c WHERE Id IN :quoteIds];
                system.debug('INSIDE QUOTE RECORDS:'+quoteRecords);
                
                quoteIdToContentDocumentsMap = checkRFPDocumentExists(quoteIds);
				 // Creating mainWrapper for each quote
				for(SBQQ__Quote__c quoteRecord:quoteRecords){
                   if(quoteIdToContentDocumentsMap.containsKey(quoteRecord.Id) && !quoteIdToContentDocumentsMap.get(quoteRecord.Id).isEmpty()) {
                        QuoteWrapper quoteWrap = new QuoteWrapper();
                        quoteWrap.quoteId = quoteRecord.Id;
    
                        if(quoteIdToContentDocumentsMap.containsKey(quoteRecord.Id)){
                            // Initialize the list if it's null
                            if(quoteWrap.contentDocumentDetails == null) {
                                quoteWrap.contentDocumentDetails = new List<ContentDocumentDetailsWrapper>();
                            }
                            for(String cdId : quoteIdToContentDocumentsMap.get(quoteRecord.Id)) {
                                ContentDocumentDetailsWrapper cdWrapper = new ContentDocumentDetailsWrapper();
                                cdWrapper.contentDocumentId = cdId;
                                quoteWrap.contentDocumentDetails.add(cdWrapper);
                            }
                            
                        }
                        
                        // Add content document IDs for this quote
                        String jsonPayload = JSON.serialize(quoteWrap);
                        system.debug('JSON PAYLOAD:'+jsonPayload);
                        quoteIdToJsonMap.put(quoteRecord.Id,jsonPayload);
                    }
                    
                else{
                    system.debug('INSIDE ELSE WHERE DOC NOT ATTACHED');
                     Core_Log_Entry__c logEntry =new Core_Log_Entry__c(Core_Message__c = 'Error',Core_Details__c = 'No RFP Document attached to the quote. Please attach before proceeding with callout', Core_Origin__c='Pricing_RFP_Scraping_AI_Integration.fetchQuoteDetails', Core_Severity__c='Low', Core_When__c=System.Now(), Core_Project__c = 'IQR');          
            		insert logEntry;
                }
                    
             }
             if(!quoteIdToJsonMap.isEmpty()){
             	makeCDBCallout(quoteIdToJsonMap);
             }

            }
		} catch (Exception exp) {       
            Core_Log_Entry__c logEntry =new Core_Log_Entry__c(Core_Message__c = 'Error',Core_Details__c = exp.getMessage(), Core_Origin__c='Pricing_RFP_Scraping_AI_Integration.fetchQuoteDetails', Core_Severity__c='Low', Core_When__c=System.Now(), Core_Project__c = 'IQR');          
            insert logEntry;
        }
	}

/***********************************************************************************************************
Method Name:        makeCDBCallout
Description:        To call sendCDBPayload method with CDB Payload and handle retry logic.
@Added By:          Aswin - 02-April-2026
Modified By:        Date:       Changes:
************************************************************************************************************/
    @Future(callout=true)
    public static void makeCDBCallout(Map<String, String> quoteIdToJsonMap)
    {
        try {
            List<Core_CDB_Integration_Log__c> cdbLogList = new List<Core_CDB_Integration_Log__c>();
            List<SBQQ__Quote__c> quoteList = new List<SBQQ__Quote__c>();
            List<Exception> calloutExceptions = new List<Exception>();
            
            // Process each payload
            for (String quoteId : quoteIdToJsonMap.keySet()) {
                
                String payload = quoteIdToJsonMap.get(quoteId);
                
                if (String.isBlank(payload)) {
                    continue;
                }
                // Send payload to CDB
                HttpResponse res =  Pricing_QuoteAgentic_Utility.sendCDBPayload(payload, 'Pricing_Apigee_RFP_Scraping');
                Boolean isSuccess = (res != null && (res.getStatus() == 'SUCCESS' || res.getStatus() == 'OK' || res.getStatus() == 'Accepted')) ? true : false;
                
            // If callout layer returned an Apex exception as response, aggregate it
            if (!isSuccess && res != null && res.getStatusCode() == 503 && res.getStatus() == 'APEX_EXCEPTION') {
                String expnMsg = res.getBody();
                if (String.isBlank(expnMsg)) {
                	expnMsg = 'Unhandled Apex exception during CDB callout';
                }
                calloutExceptions.add(new CDBCalloutException(expnMsg));
             }
            
            //Create a CDB Integration Log Record and add it to a list
            Core_CDB_Integration_Log__c cdbLogRec = Pricing_QuoteAgentic_Utility.createCDBLogInstance('RFP Scraping Integration', quoteId, res, isSuccess, 0);
            if(cdbLogRec!=null){
            	cdbLogList.add(cdbLogRec);
            }
                
           }
            if(!quoteList.isEmpty()){
                //update quoteList;
                 Database.SaveResult[] saveResultList= Database.update(quoteList);
                system.debug('INSIDE QUOTE UPDATE:'+saveResultList);
            }
            // Insert log records if we have any
            if (!cdbLogList.isEmpty()) {
                Pricing_QuoteAgentic_Utility.upsertCDBIntegrationLogList(cdbLogList);
            }
               
          
        }
        catch (Exception exp) {
            Core_Log_Entry__c logEntry =new Core_Log_Entry__c(Core_Message__c = 'Error',Core_Details__c = exp.getMessage(), Core_Origin__c='Pricing_RFP_Scraping_AI_Integration.makeCDBCallout', Core_Severity__c='Low', Core_When__c=System.Now(), Core_Project__c = 'IQR');          
            insert logEntry;
        }
    }
    @AuraEnabled(cacheable=true)
public static List<DocumentWrapper> getQuoteDocuments(List<Id> quoteId) {

    List<DocumentWrapper> result = new List<DocumentWrapper>();

    for(ContentDocumentLink cdl : [
        SELECT ContentDocumentId,
               ContentDocument.Title
        FROM ContentDocumentLink
        WHERE LinkedEntityId IN :quoteId
    ]) {
        result.add(new DocumentWrapper(
            cdl.ContentDocumentId,
            cdl.ContentDocument.Title
        ));
    }

    return result;
}

public class DocumentWrapper {
    @AuraEnabled public String ContentDocumentId;
    @AuraEnabled public String Title;

    public DocumentWrapper(String docId, String title) {
        this.ContentDocumentId = docId;
        this.Title = title;
    }
}
    
	  //Quote Wrapper
    public class QuoteWrapper
    {
        public String quoteId;
        public List<ContentDocumentDetailsWrapper> contentDocumentDetails;
    }
	//ContentVersion Wrapper
    public class ContentDocumentDetailsWrapper{
        public String contentDocumentId;
    }
    // Custom exception for callout errors that can be instantiated anywhere
     public class CDBCalloutException extends Exception {}
}