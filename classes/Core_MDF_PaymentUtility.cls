public without sharing class Core_MDF_PaymentUtility {
    
    public static string blank = '';
    public static string zero = '0';
    public static string curr = 'USD';
    public static string intelLegalCode = '100';
    public static string intelCoCode = '760';
    public static string iZero = 'I0';
    public static string iOne = 'I1';    
    public static string tab = '\t';
    public static string newline = '\r\n';
    public static string underscore = '_';
    public static string batchName = 'AP';
    public static string one = '1';
    
    /****************************************************************************************************** 
Method Name:        fetchMetaDataRecord
@return  :          Map of string and metadata object
@parameters:        N/A
Description:        This method is used to get metadata records and create map
Added By:           Accenture - VD - 03/15/2019
Modified By:        Date:       Changes: 
*******************************************************************************************************/
    public static Map<String,Core_MDF_ClaimActAllocRecTypeMapping__mdt> fetchMetaDataRecord(){
        Map<String,Core_MDF_ClaimActAllocRecTypeMapping__mdt> mapOfRecordTypes = new Map<String,Core_MDF_ClaimActAllocRecTypeMapping__mdt>();
        for(Core_MDF_ClaimActAllocRecTypeMapping__mdt recTypeMetaData:[Select Id,Core_MDF_Channel_Program_Name_txt__c,Core_MDF_Payment_RecordType_txt__c 
                                                                       from Core_MDF_ClaimActAllocRecTypeMapping__mdt]){
                                                                           mapOfRecordTypes.put(recTypeMetaData.Core_MDF_Channel_Program_Name_txt__c,recTypeMetaData);  
                                                                       }
        return mapOfRecordTypes;
        
    }
    
    /****************************************************************************************************** 
Method Name:        queryPaymentDueClaimsForPayment
@return  :          list of payment due claims
@parameters:        List of payment run records
Description:        This method is used to query payment due claims for payment process
Added By:           Accenture - AD - 06/10/2019
Modified By:        Date:       Changes: 
*******************************************************************************************************/   
    public static List<PartnerFundClaim> queryPaymentDueClaimsForPayment(List<Core_MDF_Payment_Run__c> paymentRunRecordsTobeProcessed){
        // Geo Set
        Set<String> geoSet = new Set<String>();
        // Program Set 
        Set<String> programSet = new Set<String>();
        
        //Production Test Account Ids to Be Excluded 
        List<String> testAccountIdstobeExcluded = Label.Core_MDF_TestAccountIdsToBeExcluded.split(',');   
        
        for(Core_MDF_Payment_Run__c prun : paymentRunRecordsTobeProcessed){
            geoSet.add(prun.Core_MDF_Geo_Txt__c);
            programSet.add(prun.Core_MDF_Program_Id__r.Name);
        }
        //List of payment due claims to be processed
        List<PartnerFundClaim> paymentDueClaimsTobeProcessed =  
            [SELECT Id,Title,Core_MDF_Country_Location_nm__c,ChannelPartnerId,Core_MDF_Program__c,Core_MDF_AccountCompany__c,Core_MDF_Bank__c,Core_MDF_Bank__r.Core_MDF_Supplier_Number__c,Amount,Status,Core_MDF_Status__c,
             Core_MDF_Bank__r.Core_MDF_Bank_Beneficiary_Name__c,Core_MDF_Bank__r.Core_MDF_Supplier_Name__c,Core_MDF_Bank__r.Core_MDF_Intel_Company_Code__c,Core_MDF_Bank__r.Core_MDF_Payment_Method_Code__c, Request.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c,ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c, ChannelPartner.Core_MDF_Channel_Program__c,Core_MDF_Region_Cd__c,Core_MDF_Sub_Region_Cd__c,Request.ChannelPartner.Core_MDF_Channel_Program__c FROM PartnerFundClaim WHERE Core_MDF_Region_Cd__c IN:geoSet AND Core_MDF_Program__c =:programSet AND Core_MDF_Status__c=:Label.Core_MDF_Status_Payment_Due AND ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c NOT IN: testAccountIdstobeExcluded];
        system.debug('claimsTobeProcessed for payments-'+paymentDueClaimsTobeProcessed);
        return paymentDueClaimsTobeProcessed;
    }
    
    /****************************************************************************************************** 
Method Name:        restrictOnUploadContentFile
@return  :          N/A
@parameters:        list of content document link obj
Description:        This method is used to restrict payment upload content file manually
Added By:           Accenture - AD - 07/23/2019
Modified By:        Date:       Changes: 
*******************************************************************************************************/    
    public static void restrictOnUploadPaymentFile(List<ContentDocumentLink> newContentFiles){
        //To hold object api name
        String sObjectName;
        //set of content document ids
        Set<Id> contentDocumentIdSet = new Set<Id>();
        //Map of content document id to content verion reason for change
        Map<Id,ContentVersion> mapOfContentVersion = new Map<Id,ContentVersion>();
        //List of object to restrict file upload
        List<String> objectsToRestrictFileUpload = (System.Label.Core_ObjectCodeForRestrictUploadFiles).split(',');
        for(ContentDocumentLink contentDocumentLink : newContentFiles){
            contentDocumentIdSet.add(contentDocumentLink.ContentDocumentId);            
        }
        //fetching content versions for corresponding to content document and creating map of it
        for(ContentVersion contentVersion : [SELECT ContentDocumentId,ReasonForChange 
                                             FROM ContentVersion 
                                             WHERE ContentDocumentId IN:contentDocumentIdSet
                                             AND ReasonForChange=:Label.Core_MDF_ContentVersion_ReasonForChange]){
                                                 mapOfContentVersion.put(contentVersion.ContentDocumentId,contentVersion);
                                             }
        for(ContentDocumentLink contentDocumentLink : newContentFiles){
            //Object record Id
            Id objectRecordId = contentDocumentLink.LinkedEntityId;
            if(String.valueOf(objectRecordId)!=null && String.valueOf(objectRecordId)!=''){
                //Getting object api name by Id
                sObjectName = String.valueOf(objectRecordId.getSObjectType());
            }
            if(sObjectName!=null && objectsToRestrictFileUpload !=null &&
               objectsToRestrictFileUpload.contains(sObjectName)){
                   if(mapOfContentVersion == null || mapOfContentVersion.isEmpty() ||
                      !mapOfContentVersion.ContainsKey(contentDocumentLink.ContentDocumentId) ||
                     (mapOfContentVersion.ContainsKey(contentDocumentLink.ContentDocumentId) &&
                     mapOfContentVersion.get(contentDocumentLink.ContentDocumentId).ReasonForChange == null)){                       
                       contentDocumentLink.addError(System.Label.Core_ContentFileUploadErrorMsg);
                   }else{
                       if(mapOfContentVersion.ContainsKey(contentDocumentLink.ContentDocumentId)){
                       mapOfContentVersion.get(contentDocumentLink.ContentDocumentId).ReasonForChange = '';
                       }
                   }
               }
        }
        if (String.isNotBlank(sObjectName) &&
            objectsToRestrictFileUpload !=null &&
            objectsToRestrictFileUpload.contains(sObjectName)
            && mapOfContentVersion != null && !mapOfContentVersion.isEmpty()
            && mapOfContentVersion.values() != null && !mapOfContentVersion.values().isEmpty()) {
                try{
                  Database.update(mapOfContentVersion.values());  
                }catch(Exception e){
                    Core_MDF_CCP_UtilityClass.logError(e);
                }
        }
    }
}