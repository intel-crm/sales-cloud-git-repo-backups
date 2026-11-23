/***************************************************************************************************** 
Class Name :    Core_MDF_IPA_ReminderBatch
Description:    To Notify IPA Users on Claim window closure
   
******************************************************************************************************/
global class Core_MDF_IPA_ReminderBatch implements Database.Batchable<sObject>, Database.Stateful {
              
     
     Set<id> pfrAccIds= new Set<Id>(); 
    Set<Id> pfrUltimateAccIds = new Set<Id>();
    List<Partnerfundrequest> pfrList=new List<Partnerfundrequest>();
   
    
    /*Start Method - Will return the PFR's which will be closed in nect 5,15 and 30 days*/
    public  Database.QueryLocator start(Database.BatchableContext bc) {   
 
        Date next30days =system.today() + 30 ;//first
        Date next15days =system.today() + 15 ;//second
        Date next5days =system.today() + 5 ;//third
        Date next90days =system.today() +90 ;
        String plannedStatus = Core_MDF_CCP_ConstantClass.PFR_PLANNED_STATUS;
        String ipaProgram = Core_MDF_CCP_ConstantClass.PFR_IPA_PROGRAM;
                             
        /*return [SELECT id, Core_MDF_Fund_Request_Status__c,Core_MDF_Ultimate_Account_Id__c,
                Core_MDF_ToBeClosedDate__c, Core_MDF_Program__c, ChannelPartnerId, Core_MDF_End_Date__c from PartnerFundRequest
               where Core_MDF_Program__c =:ipaProgram and Core_MDF_Fund_Request_Status__c =:plannedStatus
               and ( (Core_MDF_ToBeClosedDate__c = :next30days OR Core_MDF_ToBeClosedDate__c = :next15days OR Core_MDF_ToBeClosedDate__c = :next5days  ) OR 
                   Core_MDF_End_Date__c =:tomorrowDate) ];*/
        String query = 'SELECT id, Core_MDF_Fund_Request_Status__c,Core_MDF_Ultimate_Account_Id__c,'+
                'Core_MDF_ToBeClosedDate__c, Core_MDF_Program__c, ChannelPartnerId, Core_MDF_End_Date__c'+
                ' FROM PartnerFundRequest' +
                ' WHERE Core_MDF_Program__c =:ipaProgram AND Core_MDF_Fund_Request_Status__c =: plannedStatus'+
                ' AND '+'(' + 'Core_MDF_ToBeClosedDate__c = :next30days OR Core_MDF_ToBeClosedDate__c = :next15days OR Core_MDF_ToBeClosedDate__c = :next5days OR Core_MDF_ToBeClosedDate__c = :next90days' +')';
                             
         return Database.getQueryLocator(query);
         
        
    } 
    /*Execute Method - Taking PFR Ultimate and Account Id's to get the users*/
    global void execute(Database.BatchableContext batchableContext, List<PartnerFundRequest> pfr) { 
        
        try {
            for(PartnerFundRequest pfrRecord:pfr) {
            
                if(pfrRecord.ChannelPartnerId !=null) {
                        pfrUltimateAccIds.add(pfrRecord.Core_MDF_Ultimate_Account_Id__c);
                               pfrAccIds.add(pfrRecord.ChannelPartnerId);
                               pfrList.add(pfrRecord);
                    
                }
                
        }
        } 
        catch(Exception ex) {
            Core_MDF_CCP_UtilityClass.logError(ex);
        }
             
    }    
    /*Finish Method - To Send Email Notification*/   
    global void finish (Database.BatchableContext batchableContext) { 
        if(pfrList!=null && !pfrList.isEmpty()) {
        String notificationType = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IPARmdrBtch_Unsubscribed_Notify');
            Core_MDF_ScheduledNotificationHandler.notifyIPAUsers(pfrAccIds,pfrUltimateAccIds,pfrList,notificationType);
            //Core_MDF_ScheduledNotificationHandler.notifyIPAUsers(pfrAccIds,pfrUltimateAccIds,pfrList,'');
        }
        
        
    } 
    
}