/****************************************************************************************************************************************
* Class Name  : Core_MDF_SendEmailHelper 
* Version     : 1.0 
* Created Date: 02-07-2019
* Modification Log :
* Developer            Date               Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture - JV    02-07-2019       Helper Class for notifying Account Managers/Support Team in case of any Escalation Errors
*****************************************************************************************************************************************/
public without sharing class Core_MDF_SendEmailHelper {
    
    /* Method to SendEmail to Account Managers/Support Team in case of any Escalation Errors */
    public static void sendEmail(List<Core_MDF_Notify_Account_Manager__e> listEvents){

       /* try {
            Set<Id> escalationIdset = new Set<Id>();
            Map<Id,Core_MDF_Escalation__c> escalationIdToEscalationMap= new Map<Id,Core_MDF_Escalation__c>();
            Messaging.SingleEmailMessage[] emailmessages = new List<Messaging.SingleEmailMessage>();

            for(Core_MDF_Notify_Account_Manager__e notificationevent :listEvents) {
                if(notificationevent.Core_MDF_Escalation_Id_txt__c != null) {
                    escalationIdset.add(notificationevent.Core_MDF_Escalation_Id_txt__c);
                }
            }

            for(Core_MDF_Escalation__c esc : [SELECT Id, Name,createdById,Core_MDF_Case_ID_Number_id__c,Core_MDF_Case_ID_Number_id__r.CaseNumber FROM Core_MDF_Escalation__c WHERE Id IN:escalationIdset]) {
                escalationIdToEscalationMap.put(esc.Id,esc);
            }

            for(Core_MDF_Notify_Account_Manager__e notificationevent :listEvents) {

                if(notificationevent.Core_MDF_errorMessage_txt__c != null
                && (notificationevent.Core_MDF_errorMessage_txt__c.contains(Label.Core_MDF_ClaimExceedsCapRemainder_ErrorMsg)
                   ||notificationevent.Core_MDF_errorMessage_txt__c.contains(Label.Core_MDF_Retail_Claim_Amount_ShdBeWithIn_ActyBudgetAmt))
                && escalationIdToEscalationMap.containsKey(notificationevent.Core_MDF_Escalation_Id_txt__c)
                && notificationevent.Core_MDF_isBusinessError_ind__c) 
                {
                    //added condition for Core_MDF_Retail_Claim_Amount_ShdBeWithIn_ActyBudgetAmt
                    String emailBody = getEmailBody(escalationIdToEscalationMap,notificationevent);
                    Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                    message.setTargetObjectId(escalationIdToEscalationMap.get(notificationevent.Core_MDF_Escalation_Id_txt__c).createdById);
                    message.setSaveAsActivity(false);
                    message.setOrgWideEmailAddressId(Label.Core_MDF_OrgWideId);
                    message.subject = Label.Core_MDF_Budget_Cap_Subject;
                    message.setHTMLBody(emailBody);
                    emailmessages.add(message);
                    //Messaging.SendEmailResult[] results = Messaging.sendEmail(emailmessages);
                    Core_MDF_CCP_UtilityClass.logErrorinLogObject(notificationevent.Core_MDF_errorMessage_txt__c,'Core_MDF_Escalation__c');
            
                }else if(notificationevent.Core_MDF_errorMessage_txt__c != null) {
                    Core_MDF_CCP_UtilityClass.logErrorinLogObject(notificationevent.Core_MDF_errorMessage_txt__c,'Core_MDF_Escalation__c');
                }
            }
            if(emailmessages!=null && !emailmessages.isEmpty()){
                Messaging.SendEmailResult[] results = Messaging.sendEmail(emailmessages);
            }
            
        } catch (Exception e) {Core_MDF_CCP_UtilityClass.logError(e);}*/
    }

      /*public static String getEmailBody (Map<Id,Core_MDF_Escalation__c> escalationIdToEscalationMap, Core_MDF_Notify_Account_Manager__e notificationevent){
          string errorType;
          if(notificationevent.Core_MDF_errorMessage_txt__c.contains(Label.Core_MDF_ClaimExceedsCapRemainder_ErrorMsg)){
              errorType='BudgetCapError';
          }
          else if(notificationevent.Core_MDF_errorMessage_txt__c.contains(Label.Core_MDF_Retail_Claim_Amount_ShdBeWithIn_ActyBudgetAmt)){
              errorType='ActivityBudgetError';
          }
          
          String emailBody1 = 'Your approved ';
          String emailBody2 = '<a href="'+Label.Core_MDF_PFRDetailLink+''+escalationIdToEscalationMap.get(notificationevent.Core_MDF_Escalation_Id_txt__c).Id+'">' + 'Escalation' + '</a>';
          String emailBody3 = ' - '+escalationIdToEscalationMap.get(notificationevent.Core_MDF_Escalation_Id_txt__c).Name+' request for ';
          String emailBody4  = '<a href="' + Label.Core_MDF_PFRDetailLink+''+escalationIdToEscalationMap.get(notificationevent.Core_MDF_Escalation_Id_txt__c).Core_MDF_Case_ID_Number_id__c+'">' + 'Case' + '</a>';
          String emailBody5 = ' - '+escalationIdToEscalationMap.get(notificationevent.Core_MDF_Escalation_Id_txt__c).Core_MDF_Case_ID_Number_id__r.CaseNumber+' edit resulted in a Claim which exceeds ';
          String emailBody7 = ' Please submit new Escalation request for Total Dollar Impact equal to or less than ';
          String emailBody6,emailBody8;
          
          if(errorType=='BudgetCapError'){
          emailBody6=  'Remaining Cap Amount.';
          emailBody8=  'Remaining Cap Amount.';
          }
          else if(errorType=='ActivityBudgetError'){
          emailBody6=  'Remaining Activity Budget Amount.';
          emailBody8 = 'Remaining Activity Budget Amount.';   
          }
          String emailBody = emailBody1 + emailBody2 + emailBody3 + emailBody4 +emailBody5+emailBody6+emailBody7+emailBody8;
          
          return emailBody;
      }*/
}