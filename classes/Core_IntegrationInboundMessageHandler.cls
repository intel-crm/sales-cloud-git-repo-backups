/******************************************************************************************************************************************
Class Name  : Core_IntegrationInboundMessageHandler
Version     : 1.0
Created Date: 03 NOV 2016
Function    : Trigger for the object Integration Inbound Message

Modification Log :
* Developer                 Date                    Description
* ----------------------------------------------------------------------------
* Dave Hood                 11/03/2016              Original version
* Dave Hood                 01/26/2016              Added "after" method since we had to move A&E code to "after"
* Team: PopcornApps         6/6/2016                Create 3 new separate classes for processing each ERPM messages contact, Account, blackbox, new constants created from ERPM to Blackbox
*****************************************************************************************************************************************/
public class Core_IntegrationInboundMessageHandler {
    
    // Static variables to prevent unwanted re-entry
    public static Boolean hasProcessedNewMessages = false;
    public static Boolean hasProcessedNewMessagesAfter = false;

    // static final constants
    public static final String SOURCE_ERPM       = 'ERPM';
    public static final String SOURCE_AGS        = 'AGS';
    public static final String MSG_TYPE_ROLE     = 'Role';
    public static final String ERPM_MSG_CONTACT  = 'Contact';
    public static final String ERPM_MSG_ACCOUNT  = 'Account';
    public static final String ERPM_MSG_BLACKBOX = 'Blackbox';
    
    
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
        if (!hasProcessedNewMessages) {
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
        if (!hasProcessedNewMessagesAfter) {
            System.debug('**** inside processMessagesAfter*****');
            hasProcessedNewMessagesAfter = true;
            
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
                            Core_IntInboundMsgERPM_Contact.processContactMessages(newList);
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
        }
    }
}