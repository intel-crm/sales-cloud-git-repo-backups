/*******************************************************************************************************************************************************************************************************
* Class Name  : PMP_SendExpiryOfferingEmailsBatch
* Description : Stores the logic for sending the email for expiry offering email scenarios.If any email logs created with email api response field with value 
                Pending/failed due to error in email, should be deleted and retrigger this batch again with batch size 1 for reprocess.
* Version     : 1.0 
* Created Date: 18-may-2022
* Condition : Always use batch size as one.
* Created By  : Krishna ch (Infosys)
* Modified By : Sandhya Dayananda
********************************************************************************************************************************************************************************************************/
// IPA2.0 - As part of TWC729-7977 commented the entire class & added dummy syntax to override error
public with sharing class PMP_SendExpiryOfferingEmailsBatch implements Database.Batchable<sObject>,schedulable{
public Iterable<sObject> start(Database.BatchableContext bc) {
        return new List<sObject>(); 
    }
    public void execute(Database.BatchableContext bc, List<sObject> scope) {   
    }
    public void execute(SchedulableContext sc) {   
    }
    public void finish(Database.BatchableContext bc) {
    }

    /*
    public static Integer firstReminderDays = Integer.valueOf(System.label.PMP_14days_reminderDays);
    public static Integer secondReminderDays = Integer.valueOf(System.label.PMP_7Days_ReminderDays);
    public static Integer finalReminderDays = Integer.valueOf(System.label.PMP_Final_ReminderDays);
    public static Date firstReminderDate = System.today().adddays(firstReminderDays);
    public static Date secondReminderDate = System.today().adddays(secondReminderDays);
    public static Date finalReminderDate = System.today().adddays(finalReminderDays);
    public static string approvedStatus = PMP_StaticConstants_Offering.APPROVED;
    public static string publishedStatus = PMP_StaticConstants_Offering.PUBLISHED;
    public static string adminReviewStatus = PMP_StaticConstants_Offering.ADMIN_REVIEW;
    public static string updateRequiredStatus = PMP_StaticConstants_Offering.Update_Required;
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        Set<String> statusSet = new Set<String>{approvedStatus,adminReviewStatus,updateRequiredStatus}; 
        String query = 'Select Id, Name,PMP_Partner_Offering_End_Dt__c,PMP_Partner_Offering_Lifecycle_Status_Nm__c,PMP_Working_Copy_Id__c,PMP_Offering_Status_Update_Dt__c,PMP_Workflow_Three_Day_Trigger_Dt__c,PMP_Workflow_One_Week_Trigger_Dt__c,PMP_Working_Copy_Id__r.PMP_Partner_Offering_Lifecycle_Status_Nm__c from PMP_Partner_Offering__c where ((PMP_Partner_Offering_End_Dt__c =: firstReminderDate OR PMP_Partner_Offering_End_Dt__c =: secondReminderDate OR PMP_Partner_Offering_End_Dt__c =: finalReminderDate) AND (PMP_Partner_Offering_Lifecycle_Status_Nm__c = :publishedStatus) AND ( PMP_Working_Copy_Id__r.PMP_Partner_Offering_Lifecycle_Status_Nm__c IN :statusSet)) OR (PMP_Working_Copy_Id__r.PMP_Intel_Admin_Id__c!=null AND PMP_Partner_Offering_Lifecycle_Status_Nm__c = :publishedStatus AND PMP_Working_Copy_Id__r.PMP_Partner_Offering_Lifecycle_Status_Nm__c = :updateRequiredStatus)';
        return Database.getQueryLocator(query);
    } 
    
    //Always use batch size as one.
    public void execute(Database.BatchableContext BC, List<PMP_Partner_Offering__c> scope)
    { 
        if(scope.size() > 0 && !scope.isempty()){
            Boolean isFinalReminderSent = False;
            Boolean isSecondReminderSent = False;
            Boolean isFirstReminderSent = false;
            Boolean isFirstUpdateRequiredSent = False;
            Boolean isSecondUpdateRequiredSent = False;
            Date threeDayReminderDate ;
            Date tenDayReminderDate ;
            
            if(scope[0].PMP_Offering_Status_Update_Dt__c != NULL){
            threeDayReminderDate = scope[0].PMP_Workflow_Three_Day_Trigger_Dt__c.adddays(3);
            tenDayReminderDate = scope[0].PMP_Workflow_One_Week_Trigger_Dt__c.adddays(10);
            }
            
            map<string,string> tempNameDevloperNameMap = new map<string,string>();
            List<PRM_EmailLog__c> emailLogList =[select id,PRM_Subject__c,Email_Template_Name__c,PMP_Partner_Offering__c from PRM_EmailLog__c where PMP_Partner_Offering__c = : scope[0].id ];
            List<EmailTemplate> tempList = [SELECT Id,Name,DeveloperName FROM EmailTemplate WHERE DeveloperName IN ('PMP_OfferingUpdateRequiredFirstNotify','PMP_OfferingUpdateRequiredSecondNotify','PMP_OfferingExpiryFinalReminder','PMP_OfferingExpiryFirstReminder','PMP_OfferingExpirySecondReminder')];
            
            for(EmailTemplate temp :tempList){
                tempNameDevloperNameMap.put(temp.name,temp.DeveloperName);
            }

            Map<String, Boolean> reminderFlags = new Map<String, Boolean>{
                'PMP_OfferingExpiryFirstReminder' => false,
                'PMP_OfferingExpirySecondReminder' => false,
                'PMP_OfferingExpiryFinalReminder' => false,
                'PMP_OfferingUpdateRequiredFirstNotify' => false,
                'PMP_OfferingUpdateRequiredSecondNotify' => false
            };
            for(PRM_EmailLog__c emailLog : emailLogList){
                    if (!tempNameDevloperNameMap.isempty() && tempNameDevloperNameMap.containsKey(emailLog.Email_Template_Name__c) && emailLog.PMP_Partner_Offering__c == scope[0].Id) {
                        reminderFlags.put(tempNameDevloperNameMap.get(emailLog.Email_Template_Name__c), true);
                    }
            }
            
            List<PMP_SendEmailAlertsForOfferings.SendEmailRequestWrapper> offList = new List<PMP_SendEmailAlertsForOfferings.SendEmailRequestWrapper>();
            getOfferingData(offList, scope, reminderFlags, threeDayReminderDate, tenDayReminderDate);
            if(!offList.isempty()){
                PMP_SendEmailAlertsForOfferings.sendOfferingEmailNotifications(offList);
                
            }
        }
    }
    
    public void finish(Database.BatchableContext BC)
    {
        
    }
    
    public void execute(SchedulableContext SC) {
        
     PMP_SendExpiryOfferingEmailsBatch batch = new PMP_SendExpiryOfferingEmailsBatch();
     Database.executeBatch(batch,1);   
    }

    private PMP_SendEmailAlertsForOfferings.SendEmailRequestWrapper getEmailRequestWrapper(String templateName, Id offeringId) {
        PMP_SendEmailAlertsForOfferings.SendEmailRequestWrapper off = new PMP_SendEmailAlertsForOfferings.SendEmailRequestWrapper();
        off.templateName = templateName;
        off.offeringId = offeringId;
        return off;
    }

    public void getOfferingData(List<PMP_SendEmailAlertsForOfferings.SendEmailRequestWrapper> offList, List<PMP_Partner_Offering__c> scope, Map<String, Boolean> reminderFlags, Date threeDayReminderDate, Date tenDayReminderDate){
        List<Date> reminderDates = new List<Date>{firstReminderDate, secondReminderDate,finalReminderDate};
        List<String> expiryReminder = new List<String>{'PMP_OfferingExpiryFirstReminder', 'PMP_OfferingExpirySecondReminder', 'PMP_OfferingExpiryFinalReminder'};
        PMP_SendEmailAlertsForOfferings.SendEmailRequestWrapper off = new PMP_SendEmailAlertsForOfferings.SendEmailRequestWrapper();
        for(Integer i = 0;i < reminderDates.size();i++){
            if(scope[0].PMP_Partner_Offering_End_Dt__c == reminderDates[i] && !reminderFlags.get(expiryReminder[i])){
                offList.add(getEmailRequestWrapper(expiryReminder[i], scope[0].Id));
            }
        }
        if(scope[0].PMP_Workflow_Three_Day_Trigger_Dt__c!=null && threeDayReminderDate != null && threeDayReminderDate==System.TODAY() && !reminderFlags.get('PMP_OfferingUpdateRequiredFirstNotify') && scope[0].PMP_Working_Copy_Id__r.PMP_Partner_Offering_Lifecycle_Status_Nm__c == updateRequiredStatus){
            offList.add(getEmailRequestWrapper('PMP_OfferingUpdateRequiredFirstNotify', scope[0].Id));
           }
        if(scope[0].PMP_Workflow_One_Week_Trigger_Dt__c!=null && tenDayReminderDate != null && tenDayReminderDate==System.TODAY() && !reminderFlags.get('PMP_OfferingUpdateRequiredSecondNotify') && scope[0].PMP_Working_Copy_Id__r.PMP_Partner_Offering_Lifecycle_Status_Nm__c == updateRequiredStatus){
            offList.add(getEmailRequestWrapper('PMP_OfferingUpdateRequiredSecondNotify', scope[0].Id));
           }
    }   
*/
}