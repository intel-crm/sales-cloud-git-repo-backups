/*****************************************************************************************************  
Class Name :    Core_MDF_IPA_ReminderBatch
Description:    To Notify IPA Users on Claim window closure
   
******************************************************************************************************/
global class Core_MDF_IPA_ReminderBatch implements Database.Batchable<sObject>, Database.Stateful {
              
    Set<Id> pfrAccIds = new Set<Id>(); 
    Set<Id> pfrUltimateAccIds = new Set<Id>();
    List<PartnerFundRequest> pfrList = new List<PartnerFundRequest>();
   
    Set<Id> pfrOutcomeBaseAccIds = new Set<Id>(); 
    Set<Id> pfrOutcomeBaseUltimateAccIds = new Set<Id>();
    List<PartnerFundRequest> pfrOutcomeBaseList = new List<PartnerFundRequest>();
    
    /*Start Method - Will return the PFR's which will be closed in next 5,15 and 30 days*/
    public Database.QueryLocator start(Database.BatchableContext bc) {   
 
        Date next30days = system.today() + 30;
        Date next15days = system.today() + 15;
        Date next5days  = system.today() + 5;
        Date next90days = system.today() + 90;
        String plannedStatus = Core_MDF_CCP_ConstantClass.PFR_PLANNED_STATUS;
        String ipaProgram    = Core_MDF_CCP_ConstantClass.PFR_IPA_PROGRAM;
                             
        String query = 'SELECT id,' +
                       'Core_MDF_Fund_Request_Status__c,' +
                       'Core_MDF_Ultimate_Account_Id__c,' +
                       'Core_MDF_Is_Outcome_Based_Ind__c,' +
                       'Core_MDF_ToBeClosedDate__c,' +
                       'Core_MDF_Program__c,' +
                       'ChannelPartnerId,' +
                       'Core_MDF_End_Date__c' +
                       ' FROM PartnerFundRequest' +
                       ' WHERE Core_MDF_Program__c =:ipaProgram' +
                       ' AND Core_MDF_Fund_Request_Status__c =:plannedStatus' +
                       ' AND (' +
                       'Core_MDF_ToBeClosedDate__c = :next30days OR ' +
                       'Core_MDF_ToBeClosedDate__c = :next15days OR ' +
                       'Core_MDF_ToBeClosedDate__c = :next5days  OR ' +
                       'Core_MDF_ToBeClosedDate__c = :next90days' +
                       ')';
                             
        return Database.getQueryLocator(query);
    } 

    /*Execute Method - Taking PFR Ultimate and Account Id's to get the users*/
    global void execute(Database.BatchableContext batchableContext, 
                        List<PartnerFundRequest> pfr) { 
        
        try {
            for(PartnerFundRequest pfrRecord : pfr) {
            
                if(pfrRecord.ChannelPartnerId != null && 
                   pfrRecord.Core_MDF_Is_Outcome_Based_Ind__c == false) {

                    pfrUltimateAccIds.add(pfrRecord.Core_MDF_Ultimate_Account_Id__c);
                    pfrAccIds.add(pfrRecord.ChannelPartnerId);
                    pfrList.add(pfrRecord);

                } else if(pfrRecord.ChannelPartnerId != null && 
                          pfrRecord.Core_MDF_Is_Outcome_Based_Ind__c == true) {

                    pfrOutcomeBaseUltimateAccIds.add(pfrRecord.Core_MDF_Ultimate_Account_Id__c);
                    pfrOutcomeBaseAccIds.add(pfrRecord.ChannelPartnerId);
                    pfrOutcomeBaseList.add(pfrRecord);
                }
            }

        } catch(Exception ex) {
            Core_MDF_CCP_UtilityClass.logError(ex);
        }
    }    

    /*Finish Method - To Send Email Notification*/   
    global void finish(Database.BatchableContext batchableContext) { 

        String notificationType = Core_MDF_CustomLabelConfig.getTextValues(
            'Core_MDF_IPARmdrBtch_Unsubscribed_Notify');

        if(pfrList != null && !pfrList.isEmpty()) {
            Core_MDF_ScheduledNotificationHandler.notifyIPAUsers(
                pfrAccIds,
                pfrUltimateAccIds,
                pfrList,
                notificationType,
                false
            );
        }

        if(pfrOutcomeBaseList != null && !pfrOutcomeBaseList.isEmpty()) {
            Core_MDF_ScheduledNotificationHandler.notifyIPAUsers(
                pfrOutcomeBaseAccIds,
                pfrOutcomeBaseUltimateAccIds,
                pfrOutcomeBaseList,
                notificationType,
                true
            );
        }
    } 
}