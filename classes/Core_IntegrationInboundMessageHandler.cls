/******************************************************************************************************************************************
Class Name  : Core_IntegrationInboundMessageHandler
Version     : 1.0
Created Date: 03 NOV 2016
Function    : Trigger for the object Integration Inbound Message

Modification Log :
* Developer                     Date                    Description
* ----------------------------------------------------------------------------
* Dave Hood                     11/03/2016              Original version
* Dave Hood                     01/26/2016              Added "after" method since we had to move A&E code to "after"
* Team: PopcornApps             6/6/2016                Create 3 new separate classes for processing each ERPM messages contact, Account, blackbox, new constants created from ERPM to Blackbox
* Team: Onyx -Marketplace       8/7/2019                Added handler logic for Market place Translation message type
* Team: Tanzanite -Marketplace  24/01/2020              Added handler logic for "Marketplace Translation - Partner" message type
* Team: DRACO                   26/3/2021                            Added logic to create Entitlement Status Detail object record when there is an error in ERPM blackbox inbound  
* Team: Draco                                                 05/04/2022                  Don't change ERPM Integration Status in case of 2.0 flow - ERPM Bypass Logic
* Team: Draco                                                 17/05/2022                  Added logic to retry processing the Integration Inbound Message in case of Apex Exception
*****************************************************************************************************************************************/
public without sharing class Core_IntegrationInboundMessageHandler {
    
    // Static variables to prevent unwanted re-entry
    public static Boolean hasProcessedNewMessages = false;
    public static Boolean hasProcessedNewMessagesAfter = false;
    public static boolean startedFromAGSInboundMsg = false; //DRACO Change - Don't change ERPM Integration Status in case of 2.0 flow
    public static Boolean retryForAGSApexExeption = true; //Added logic to retry processing the Integration Inbound Message in case of Apex Exception
    
    // static final constants
    public static final String MSG_TYPE_TENDER_CLAIMS = 'UpdateClaims';
    public static final String MSG_TYPE_TENDER = 'Tender';
    public static final String MSG_TYPE_TENDER_CONSUMPTION = 'UpdateDropdowns';
    public static final String SOURCE_MYDEALS = 'MyDeals';
    public static final String MSG_PENDING_STATUS = 'Pending';
    public static final String SOURCE_ERPM = 'ERPM';
    public static final String ERPM_BBox_Status_Fail = 'Failed';
    public static final String SOURCE_AGS = 'AGS';
    public static final String MSG_TYPE_ROLE = 'Role';
    public static final String MSG_TYPE_ROLE2_0  = 'Role 2.0';
    public static final String ERPM_MSG_CONTACT = 'Contact';
    //public static final String ERPM_MSG_ACCOUNT = 'Account';
    public static final String ERPM_MSG_BLACKBOX = 'Blackbox';
    public static final String MSG_TYPE_MP_TRANSLATION = 'Marketplace_Translation';
    public static final String MSG_TYPE_MP_TRANSLATION_PARTNER = 'Marketplace Translation - Partner';
    public static final Set<String> SOURCE_SYSTEMS = new Set<String>{'EDW','ECA'};
    
    // Map of our Trigger execution flags
    public static Map<String,Core_Trigger_Executions__c> mapFunctionalityNameTriggerExecution;
    
    // Handle all "Before" logic on inbound messages
    public static void beforeMethod(List<Core_Integration_Inbound_Message__c> oldList,
                                    List<Core_Integration_Inbound_Message__c> newList,
                                    Map<Id,Core_Integration_Inbound_Message__c> oldMap,
                                    Map<Id,Core_Integration_Inbound_Message__c> newMap)
    {
        mapFunctionalityNameTriggerExecution = Core_Trigger_Executions__c.getAll();
        
        if (Trigger.isInsert) {
            processMessagesBefore(oldList, newList, oldMap, newMap);
        }
        if (Trigger.isUpdate) {
            processMessagesBefore(oldList, newList, oldMap, newMap);
            
        }
        //if (Trigger.isDelete) {
        // Placeholder for future code
        //}
    }
    //---------DRACO start------------------------//
    public class jsonWrapper
    {
        public string Status;
        public string ErrorCode;
        public string ErrorText;
        public string ErrorDetails;
        public string EmailID;
    }
    public class InboundjsonWrapper
    {
        public List<contact> inboundContacts;
        public Id inboundID;    
        public string inboundSource;
        public string inboundMessageType;
        public jsonWrapper payloadfield; 
        
    }
    //---------DRACO End------------------------//
    
    // Handle all "After" logic on inbound messages
    public static void afterMethod(List<Core_Integration_Inbound_Message__c> oldList,
                                   List<Core_Integration_Inbound_Message__c> newList,
                                   Map<Id,Core_Integration_Inbound_Message__c> oldMap,
                                   Map<Id,Core_Integration_Inbound_Message__c> newMap)
    {
        mapFunctionalityNameTriggerExecution = Core_Trigger_Executions__c.getAll();
        
        if (Trigger.isInsert) {
            processMessagesAfter(oldList, newList, oldMap, newMap);
        }
        if (Trigger.isUpdate) {
            processMessagesAfter(oldList, newList, oldMap, newMap);
            
            //-------------------DRACO:Create/Update of Entitlement Status Detail object record - START----------------------//
            
            try{
                
                List<string> Contemailid =new List<string>();
                List<InboundjsonWrapper> InboundReqFields =new List<InboundjsonWrapper>();
                
                map<string,Id> inboundemail = new map<string,Id>();
                
                for(Core_Integration_Inbound_Message__c InboundlistItem :newMap.values())
                { 
                    
                    if(InboundlistItem.Core_Message_Type__c==ERPM_MSG_BLACKBOX)
                    {
                        jsonWrapper Jsondatawrapper= new jsonWrapper();
                        InboundjsonWrapper InboundjsonWrapobj= new InboundjsonWrapper();
                        string jsonstring = InboundlistItem.Core_Payload__c;
                        Jsondatawrapper = (jsonWrapper)JSON.deserialize(jsonstring,jsonWrapper.class);
                        InboundjsonWrapobj.payloadfield=Jsondatawrapper;
                        
                        InboundjsonWrapobj.inboundID = InboundlistItem.id;
                        InboundjsonWrapobj.inboundSource = InboundlistItem.Core_Source_System__c;
                        InboundjsonWrapobj.inboundMessageType = InboundlistItem.Core_Message_Type__c;
                        
                        Contemailid.add(Jsondatawrapper.EmailID);//email case
                        
                        InboundReqFields.add(InboundjsonWrapobj);   
                        
                    }
                    
                }
                
                    for(Contact ContListIds:[Select id,email from Contact where email IN:Contemailid])
                    {
                        
                        inboundemail.put(ContListIds.email,ContListIds.id);
                }
                
                if(InboundReqFields.size() > 0){
                    mapInboundToStatusdetail(InboundReqFields,inboundemail); 
                }
            }catch(Exception exp){
                Core_Log_Entry__c excepLog = new Core_Log_Entry__c(Core_Message__c = exp.getMessage(), Core_Origin__c = 'After logic on inbound messages', Core_Project__c = 'Core_IntegrationInboundMessageHandler' , Core_Details__c = 'Error while Creating/Updating Entitlement Status Detail object', Core_Severity__c = 'info', Core_When__c = System.Now());     
                insert excepLog;
            }
            
        } 
        //---------------------DRACO: Create/Update of Entitlement Status Detail object record - END --------------------//
        
        //if (Trigger.isDelete) {
        // Placeholder for future code
        //}
    }
    //---------------------DRACO: 1Create/Update of Entitlement Status Detail object record - START -----------------//
    public Static Void mapInboundToStatusdetail(List<InboundjsonWrapper> JsondatawrapperList, map<string,Id> inboundemail)
    {
        
        A_E_Integration_Status_Detail__c IntegrationStatusDetail=new A_E_Integration_Status_Detail__c();
        List<A_E_Integration_Status_Detail__c> IntegrtionStatusDetailList=new List<A_E_Integration_Status_Detail__c>();
        List<A_E_Integration_Status_Detail__c> IntegrtionStatusDetailDeleteList=new List<A_E_Integration_Status_Detail__c>(); //Draco Change [END] - 22-02-2022 ------- Delete previous integration status detail record if there is no error in the new Inbound
        Map<string,Id> ErrorMapping = new Map<string,Id>();
        
        
        
        for(A_E_Error_Mapping__c errorcde:[Select id,A_E_Error_Code_Txt__c from A_E_Error_Mapping__c ])
        {
            ErrorMapping.put(errorcde.A_E_Error_Code_Txt__c,errorcde.id); 
        }
        //StatusDetails = [Select id,A_E_Contact_Id__c,A_E_Contact_Id__r.Email from A_E_Integration_Status_Detail__c where A_E_Contact_Id__c IN:inboundemail.values()]; //Commented as its used nowherein this code - Akshay[Draco] 22-02-2022
        Map<string,A_E_Integration_Status_Detail__c> StatusDetailsMapping = new Map<string,A_E_Integration_Status_Detail__c>();
        
        for(A_E_Integration_Status_Detail__c StatusDetailsMapping1:[Select id,A_E_Contact_Id__c,A_E_Contact_Id__r.Email from A_E_Integration_Status_Detail__c where A_E_Contact_Id__c IN:inboundemail.values()])
        {
            StatusDetailsMapping.put(StatusDetailsMapping1.A_E_Contact_Id__r.Email,StatusDetailsMapping1);              
        }
        for(InboundjsonWrapper JsondatawrapperListItem:JsondatawrapperList) 
        {
            if ((JsondatawrapperListItem.inboundSource == SOURCE_ERPM)&&(JsondatawrapperListItem.inboundMessageType== ERPM_MSG_BLACKBOX))
            {
                if((JsondatawrapperListItem.payloadfield.Status!='Success')&&(JsondatawrapperListItem.payloadfield.ErrorCode!=NULL))//status,errorcode
                {                 
                    
                    if(StatusDetailsMapping.containsKey(JsondatawrapperListItem.payloadfield.EmailID))
                    { 
                        //----------------------------------Update------------------------//
                        
                        
                        IntegrationStatusDetail.Id=StatusDetailsMapping.get(JsondatawrapperListItem.payloadfield.EmailID).Id;
                    } 
                    //------------------------Upsert (Insert/Update)------------------//
                    
                    if(inboundemail.containsKey(JsondatawrapperListItem.payloadfield.EmailID))
                    {
                        IntegrationStatusDetail.A_E_Contact_Id__c=inboundemail.get(JsondatawrapperListItem.payloadfield.EmailID);
                        
                    }                             
                    
                    
                    IntegrationStatusDetail.A_E_Integration_Type_Txt__c= SOURCE_ERPM;
                    
                    IntegrationStatusDetail.A_E_Integration_Status_Txt__c  = ERPM_BBox_Status_Fail;
                    IntegrationStatusDetail.A_E_Integration_Error_Txt__c= JsondatawrapperListItem.payloadfield.ErrorCode;//ErrorText
                    IntegrationStatusDetail.A_E_Integration_Error_Description_Txt__c=JsondatawrapperListItem.payloadfield.ErrorDetails;//ErrorDetails
                    
                    If(ErrorMapping.containskey(JsondatawrapperListItem.payloadfield.ErrorCode))
                    {
                        
                        IntegrationStatusDetail.A_E_Error_Mapping_Id__c=ErrorMapping.get(JsondatawrapperListItem.payloadfield.ErrorCode);
                        
                    }
                    else{
                        IntegrationStatusDetail.A_E_Error_Mapping_Id__c=NULL;
                    }
                    IntegrtionStatusDetailList.add(IntegrationStatusDetail);
                    } 
                //-------------- Draco Change [START] - 22-02-2022 ------- Delete previous integration status detail record if there is no error in the new Inbound -------------//
                if((JsondatawrapperListItem.payloadfield.Status == 'Success')&&(JsondatawrapperListItem.payloadfield.ErrorCode == NULL) && (StatusDetailsMapping.containsKey(JsondatawrapperListItem.payloadfield.EmailID))){
                    //if(StatusDetailsMapping.containsKey(JsondatawrapperListItem.payloadfield.EmailID)){
                        IntegrationStatusDetail.Id=StatusDetailsMapping.get(JsondatawrapperListItem.payloadfield.EmailID).Id;
                        IntegrtionStatusDetailDeleteList.add(IntegrationStatusDetail);
                    //}
                    
                }
                //-------------- Draco Change [END] - 22-02-2022 ------- Delete previous integration status detail record if there is no error in the new Inbound -------------//
            }
        }
        Upsert IntegrtionStatusDetailList;
        Delete IntegrtionStatusDetailDeleteList; //Draco Change [END] - 22-02-2022 ------- Delete previous integration status detail record if there is no error in the new Inbound
    } 
    //---------------------DRACO: 1Create/Update of Entitlement Status Detail object record - END -----------------//
    public static void processMessagesBefore(List<Core_Integration_Inbound_Message__c> oldList,
                                             List<Core_Integration_Inbound_Message__c> newList,
                                             Map<Id,Core_Integration_Inbound_Message__c> oldMap,
                                             Map<Id,Core_Integration_Inbound_Message__c> newMap)
    {
        // Ensure no re-entry
        if (!hasProcessedNewMessages || !retryForAGSApexExeption) {
            hasProcessedNewMessages = true;
            //retryForAGSApexExeption = true; // Added logic to retry processing the Integration Inbound Message in case of Apex Exception
            
            // Only execute this logic if the trigger is turned on
            if (!mapFunctionalityNameTriggerExecution.isEmpty() &&
                mapFunctionalityNameTriggerExecution.containsKey('processInboundMessages') &&
                mapFunctionalityNameTriggerExecution.get('processInboundMessages').Core_Active__c) 
            {
                
                if (newList.size() > 0) {
                    
                    //Intel Altera Phase1:
                    //Below code is used for mapping all the inbound message with Message Type Quote
                    List<Core_Integration_Inbound_Message__c> quoteList = new List<Core_Integration_Inbound_Message__c>();
                    for( Core_Integration_Inbound_Message__c obj : newList ) {
                        if( obj.Core_Message_Type__c  == 'Quote') {
                            quoteList.add(obj);
                        }
                    }
                    if(quoteList.size() > 0) {
                        Core_SalesSupportPSGQuoteSFDCToSiebel.processPSGQuoteMessage(quoteList);
                    }
                    
                }
            }
        }
    }
    
    public static void processMessagesAfter(List<Core_Integration_Inbound_Message__c> oldList,
                                            List<Core_Integration_Inbound_Message__c> newList,
                                            Map<Id,Core_Integration_Inbound_Message__c> oldMap,
                                            Map<Id,Core_Integration_Inbound_Message__c> newMap)
    {
          // Ensure no re-entry
        if (!hasProcessedNewMessagesAfter || !retryForAGSApexExeption) {
            hasProcessedNewMessagesAfter = true;
            retryForAGSApexExeption = true; // Added logic to retry processing the Integration Inbound Message in case of Apex Exception
            
            // We know this is an INSERT and it will always contain messages of the same source system & message type,
            // so just check the first record to see which combination we're processing
            if (newList.size() > 0) {                    
                // Only execute this logic if the trigger is turned on
                if ((newList[0].Core_Source_System__c == SOURCE_ERPM) && (!mapFunctionalityNameTriggerExecution.isEmpty() &&
                    mapFunctionalityNameTriggerExecution.containsKey('processInboundMessagesERPM')) &&
                    (mapFunctionalityNameTriggerExecution.get('processInboundMessagesERPM').Core_Active__c)
                    && newList[0].Core_Message_Type__c == ERPM_MSG_CONTACT){
                    Core_ERPMInboundMessage_ContactService.processContactMessages(newList[0]);
                }/*else if ( (newList[0].Core_Source_System__c == SOURCE_ERPM) && (!mapFunctionalityNameTriggerExecution.isEmpty() &&
                    mapFunctionalityNameTriggerExecution.containsKey('processInboundMessagesERPM')) 
                    && newList[0].Core_Message_Type__c == ERPM_MSG_ACCOUNT) {
                    Core_IntInboundMsgERPM_Account.processAccountMessages(newList);
                }*/else if ((newList[0].Core_Source_System__c == SOURCE_ERPM) && (!mapFunctionalityNameTriggerExecution.isEmpty() &&
                    mapFunctionalityNameTriggerExecution.containsKey('processInboundMessagesERPM')) &&
                    (mapFunctionalityNameTriggerExecution.get('processInboundMessagesERPM').Core_Active__c)
                    && newList[0].Core_Message_Type__c == ERPM_MSG_BLACKBOX) {
                            Core_IntInboundMsgERPM_BlackBox.processBlackboxMessages(newList);
                } else if ((newList[0].Core_Source_System__c == SOURCE_AGS) && (!mapFunctionalityNameTriggerExecution.isEmpty()) &&
                    (mapFunctionalityNameTriggerExecution.containsKey('processInboundMessagesAGS')) &&
                    (mapFunctionalityNameTriggerExecution.get('processInboundMessagesAGS').Core_Active__c)
                    && newList[0].Core_Message_Type__c == MSG_TYPE_ROLE2_0) {
                    startedFromAGSInboundMsg = true; // No matter waht is ERPM Integration status, we will use this variable to check if the transaction is started from Role 2.0 IIM and it need to send IOM to AGS by bypassing ERPM. Used in Core_Entitlement_Outbound_Integrations class
                    Core_IntegrationInboundMessageAGS.processMessages2_0(newList);
                }
            }
            //for bank and payment handling
            if(newList != NULL && newList.size() > 0){
                Map<Id,Core_Integration_Inbound_Message__c> newMapToBeProcessed = new Map<Id,Core_Integration_Inbound_Message__c>();
                Map<Id,Core_Integration_Inbound_Message__c> newMapToBeProcessedForPayments = new Map<Id,Core_Integration_Inbound_Message__c>();
                for(Core_Integration_Inbound_Message__c iMessageRecord : newList){
                    if(SOURCE_SYSTEMS.contains(iMessageRecord.Core_Source_System__c.toUpperCase())){
                        if(('Bank').equalsIgnoreCase(iMessageRecord.Core_Message_Type__c)){
                            newMapToBeProcessed.put(iMessageRecord.Id, iMessageRecord);
                        }
                        if(('Payment').equalsIgnoreCase(iMessageRecord.Core_Message_Type__c)){
                            newMapToBeProcessedForPayments.put(iMessageRecord.Id, iMessageRecord);
                        }
                    }
                }
                if(newMapToBeProcessed.size() > 0){
                    Core_MDF_UpdateBankDetails.updateBankRecords(newMapToBeProcessed);
                }
                if(newMapToBeProcessedForPayments.size() > 0){
                    Core_MDF_PaymentServiceHandler.updatePaymentRecords(newMapToBeProcessedForPayments);
                }
            }   
            
            //Added by Onyx Team to process GLS Marketplace Translation messages
            if(newList.size() > 0){
                Map<Id,Core_Integration_Inbound_Message__c> MapToBeProcessed = new Map<Id,Core_Integration_Inbound_Message__c>();
                for(Core_Integration_Inbound_Message__c iMessageRecord : newList){
                    if (iMessageRecord.Core_Message_Type__c == MSG_TYPE_MP_TRANSLATION) 
                    {
                        MapToBeProcessed.put(iMessageRecord.Id, iMessageRecord);
                    }
                }
                /*if(MapToBeProcessed.size() > 0){
                    PMP_Locale_Inbound_Msg.updateLocaleDetails(MapToBeProcessed);
                }*/ //Commented as part of IPA2.0 EOL'ing
            }
            
            //Added by Tanzanite Team to process GLS Partner Marketplace Translation messages
            if(newList.size() > 0){
                Map<Id,Core_Integration_Inbound_Message__c> newMapToBeProcessed = new Map<Id,Core_Integration_Inbound_Message__c>();
                
                for(Core_Integration_Inbound_Message__c iMessageRecord : newList){          
                    if (iMessageRecord.Core_Message_Type__c == MSG_TYPE_MP_TRANSLATION_PARTNER){  
                        //              if (iMessageRecord.Core_Message_Type__c == MSG_TYPE_MP_TRANSLATION){
                        newMapToBeProcessed.put(iMessageRecord.Id, iMessageRecord);
                    }
                }
                
                if(newMapToBeProcessed.size() > 0){
                    PMP_Partner_Locale_Inbound_Msg.updateLocaleDetails(newMapToBeProcessed);
                }
            }
            List<Core_Integration_Inbound_Message__c> tenderInboundMsgList = new List<Core_Integration_Inbound_Message__c>();
            List<Core_Integration_Inbound_Message__c> tenderClaimsInboundMsgList = new List<Core_Integration_Inbound_Message__c>();
            List<Core_Integration_Inbound_Message__c> tenderConsumptionInboundMsgList = new List<Core_Integration_Inbound_Message__c>();
            //Process IIM only on Insert
            if (!mapFunctionalityNameTriggerExecution.isEmpty() &&
                mapFunctionalityNameTriggerExecution.containsKey('processInboundMessagesIQR') &&
                mapFunctionalityNameTriggerExecution.get('processInboundMessagesIQR').Core_Active__c) {
                    
                    for(Core_Integration_Inbound_Message__c inboundMsg : newList){
                        if (oldMap == null && inboundMsg.Core_Source_System__c == SOURCE_MYDEALS && inboundMsg.Core_Message_Type__c == MSG_TYPE_TENDER){ //Check if IIM inserted
                            tenderInboundMsgList.add(inboundMsg);
                        }else if(inboundMsg.Core_Source_System__c == SOURCE_MYDEALS && inboundMsg.Core_Message_Type__c == MSG_TYPE_TENDER && inboundMsg.Core_Processing_Status__c == MSG_PENDING_STATUS){ //Check if IIM updated
                            tenderInboundMsgList.add(inboundMsg);
                        }else if(oldMap == null && inboundMsg.Core_Source_System__c == SOURCE_MYDEALS && inboundMsg.Core_Message_Type__c == MSG_TYPE_TENDER_CLAIMS){
                            tenderClaimsInboundMsgList.add(inboundMsg);
                        }else if(oldMap == null && inboundMsg.Core_Source_System__c == SOURCE_MYDEALS && inboundMsg.Core_Message_Type__c == MSG_TYPE_TENDER_CONSUMPTION){
                            tenderConsumptionInboundMsgList.add(inboundMsg);
                        }
                    }
                    if(!tenderInboundMsgList.isEmpty()){
                        Pricing_IntegrationSFDCToPricingSystems integrationSystem = new Pricing_IntegrationSFDCToPricingSystems();
                        integrationSystem.processMessages(tenderInboundMsgList);
                    }
                    if(!tenderClaimsInboundMsgList.isEmpty()){
                        Pricing_IntegrationSFDCToPricingSystems integrationSystem = new Pricing_IntegrationSFDCToPricingSystems();
                        integrationSystem.processClaimsMessages(tenderClaimsInboundMsgList);
                    }
                    if(!tenderConsumptionInboundMsgList.isEmpty()){
                        Pricing_IntegrationConsumptionAttributes integrationSystem = new Pricing_IntegrationConsumptionAttributes();
                        integrationSystem.processConsumptionData(tenderConsumptionInboundMsgList);
                    }
                }
        }
    }
}