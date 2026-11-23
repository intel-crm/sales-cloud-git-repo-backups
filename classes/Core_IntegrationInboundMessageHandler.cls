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
*****************************************************************************************************************************************/
public class Core_IntegrationInboundMessageHandler {
    
    // Static variables to prevent unwanted re-entry
    public static Boolean hasProcessedNewMessages = false;
    public static Boolean hasProcessedNewMessagesAfter = false;
    public static Boolean retryForAGSApexExeption = true;
    
    // static final constants
    public static final String MSG_TYPE_TENDER = 'Tender';
    public static final String MSG_TYPE_TENDER_CLAIMS = 'UpdateClaims';
    public static final String MSG_TYPE_TENDER_CONSUMPTION = 'UpdateDropdowns';
    public static final String SOURCE_MYDEALS = 'MyDeals';
    public static final String MSG_PENDING_STATUS = 'Pending';
    public static final String SOURCE_ERPM = 'ERPM';
    public static final String SOURCE_AGS = 'AGS';
    public static final String MSG_TYPE_ROLE = 'Role';
    public static final String ERPM_MSG_CONTACT = 'Contact';
    public static final String ERPM_MSG_ACCOUNT = 'Account';
    public static final String ERPM_MSG_BLACKBOX = 'Blackbox';
    public static final String MSG_TYPE_MP_TRANSLATION = 'Marketplace_Translation';
    public static final String MSG_TYPE_MP_TRANSLATION_PARTNER = 'Marketplace Translation - Partner';
    
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
        }
        //if (Trigger.isDelete) {
        // Placeholder for future code
        //}
    }
    
    public static void processMessagesBefore(List<Core_Integration_Inbound_Message__c> oldList,
                                             List<Core_Integration_Inbound_Message__c> newList,
                                             Map<Id,Core_Integration_Inbound_Message__c> oldMap,
                                             Map<Id,Core_Integration_Inbound_Message__c> newMap)
    {
        // Ensure no re-entry
        if (!hasProcessedNewMessages || !retryForAGSApexExeption) {
            System.debug('**** inside processMessagesBefore*****');
            hasProcessedNewMessages = true;
            
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
                    System.debug('****** QuoteList*****'+quoteList);
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
            System.debug('**** inside processMessagesAfter*****');
            hasProcessedNewMessagesAfter = true;
            retryForAGSApexExeption = true; // Added logic to retry processing the Integration Inbound Message in case of Apex Exception
            
            // We know this is an INSERT and it will always contain messages of the same source system & message type,
            // so just check the first record to see which combination we're processing
            if (newList.size() > 0) {
                System.debug(newList);
                // Source System = ERPM
                if (newList[0].Core_Source_System__c == SOURCE_ERPM) {
                    
                    // Only execute this logic if the trigger is turned on
                    if (!mapFunctionalityNameTriggerExecution.isEmpty() &&
                        mapFunctionalityNameTriggerExecution.containsKey('processInboundMessagesERPM') &&
                        mapFunctionalityNameTriggerExecution.get('processInboundMessagesERPM').Core_Active__c)
                    {
                        
                        if (newList[0].Core_Message_Type__c == ERPM_MSG_CONTACT) {
                            //Core_IntInboundMsgERPM_Contact.processContactMessages(newList);
                            if(!mapFunctionalityNameTriggerExecution.isEmpty() &&
                               mapFunctionalityNameTriggerExecution.containsKey('SwitchToERPMInboundContactService') &&
                               mapFunctionalityNameTriggerExecution.get('SwitchToERPMInboundContactService').Core_Active__c){
                                 System.debug('$$#@ Enter if part');
                                 Core_ERPMInboundMessage_ContactService.processContactMessages(newList[0]);
                            }
                            else{
                                System.debug('$$#@ Else part');
                                Core_IntInboundMsgERPM_Contact.processContactMessages(newList);
                            }
                            //Core_IntegrationInboundMessageERPM.processContactMessages(newList);
                        }
                        else if (newList[0].Core_Message_Type__c == ERPM_MSG_ACCOUNT) {
                            Core_IntInboundMsgERPM_Account.processAccountMessages(newList);
                            //Core_IntegrationInboundMessageERPM.processAccountMessages(newList);
                        }
                        else if (newList[0].Core_Message_Type__c == ERPM_MSG_BLACKBOX) {
                            Core_IntInboundMsgERPM_BlackBox.processBlackboxMessages(newList);
                            //Core_IntegrationInboundMessageERPM.processBlackboxMessages(newList);
                        }
                    }
                }
                // Source System = AGS
                else if (newList[0].Core_Source_System__c == SOURCE_AGS) 
                {
                    
                    // Only execute this logic if the trigger is turned on
                    if (!mapFunctionalityNameTriggerExecution.isEmpty() &&
                        mapFunctionalityNameTriggerExecution.containsKey('processInboundMessagesAGS') &&
                        mapFunctionalityNameTriggerExecution.get('processInboundMessagesAGS').Core_Active__c) {
                            
                            if (newList[0].Core_Message_Type__c == MSG_TYPE_ROLE) {
                                Core_IntegrationInboundMessageAGS.processMessages(newList);
                            }
                        }
                }
            }
            //for bank and payment handling
            if(newList != NULL && newList.size() > 0){
                Map<Id,Core_Integration_Inbound_Message__c> newMapToBeProcessed = new Map<Id,Core_Integration_Inbound_Message__c>();
                Map<Id,Core_Integration_Inbound_Message__c> newMapToBeProcessedForPayments = new Map<Id,Core_Integration_Inbound_Message__c>();
                for(Core_Integration_Inbound_Message__c iMessageRecord : newList){
                    if(('Bank').equalsIgnoreCase(iMessageRecord.Core_Message_Type__c) && 
                       (('EDW').equalsIgnoreCase(iMessageRecord.Core_Source_System__c))){
                           newMapToBeProcessed.put(iMessageRecord.Id, iMessageRecord);
                       }
                    if(('Payment').equalsIgnoreCase(iMessageRecord.Core_Message_Type__c) && 
                       (('EDW').equalsIgnoreCase(iMessageRecord.Core_Source_System__c))){
                           newMapToBeProcessedForPayments.put(iMessageRecord.Id, iMessageRecord);
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
                //system.debug('messagetype1=' + newList[0].Core_Message_Type__c);
                for(Core_Integration_Inbound_Message__c iMessageRecord : newList){
                    if (iMessageRecord.Core_Message_Type__c == MSG_TYPE_MP_TRANSLATION) 
                    {
                        //system.debug('messagetype2=' + iMessageRecord.Core_Message_Type__c);
                        MapToBeProcessed.put(iMessageRecord.Id, iMessageRecord);
                    }
                }
                //system.debug('length=' + MapToBeProcessed.size());
                if(MapToBeProcessed.size() > 0){
                    PMP_Locale_Inbound_Msg.updateLocaleDetails(MapToBeProcessed);
                }
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
                        if (oldMap == null && inboundMsg.Core_Source_System__c == SOURCE_MYDEALS && inboundMsg.Core_Message_Type__c == MSG_TYPE_TENDER){   //Check if IIM inserted              
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