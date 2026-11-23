/****************************************************************************************************************************
Apex Class Name     : PRM_PartnerAssistConsent_Handler 
Version             : 1.0
Created Date        : July 2020

Modification Log    :
* Developer                 Date                    Description
* --------------------------------------------------------------------------------------------------------------------------
* Tejasree                10-July-2020               To send Emails to PartnerAssist when a record is created & updated
****************************************************************************************************************************/
public without sharing class PRM_PartnerAssistConsent_Handler extends TriggerHandler{
    public static boolean IPAfirstRun = true;
    public override void afterInsert(){
        if(isActive('PRM_PartnerAssistConsent_Switch')){
            //system.debug('PAC after insert trigger entered');
            PRM_EmailUtility.sendOptInEmail(Trigger.new);
        }
       /* if(isActive('PAC_Insert_IPA_Integration_Trigger') && IPAfirstRun) {            
            System.enqueueJob(new ContactERPMIntegrationStatusHandler((List<PRM_Partner_Assist_Consent__c>)Trigger.new,  Trigger.new.getSObjectType()));
            IPAfirstRun = false;
        }*/
    }
    public override void afterUpdate(){
        if(isActive('PRM_PartnerAssistConsent_Switch')){
            //system.debug('PAC after update trigger entered');
            PRM_EmailUtility.sendOptOutEmail(Trigger.new,(Map<Id,PRM_Partner_Assist_Consent__c>)Trigger.oldMap);
            PRM_EmailUtility.sendPartnerModifyEmail(Trigger.new,(Map<Id,PRM_Partner_Assist_Consent__c>)Trigger.oldMap);
        }
        if(isActive('PAC_Update_IPA_Integration_Trigger') && IPAfirstRun) { 
            
            boolean isUpdated = false;
            for(PRM_Partner_Assist_Consent__c newPAConsent : (List<PRM_Partner_Assist_Consent__c>)Trigger.new) {
                PRM_Partner_Assist_Consent__c oldPAConsent = (PRM_Partner_Assist_Consent__c)Trigger.oldMap.get(newPAConsent.Id);
                if((newPAConsent.PRM_End_Date_Dt__c != oldPAConsent.PRM_End_Date_Dt__c 
                   || newPAConsent.PRM_Choice_Nm__c != oldPAConsent.PRM_Choice_Nm__c
                   || newPAConsent.PRM_Distributor_Id__c != oldPAConsent.PRM_Distributor_Id__c
                   ||newPAConsent.PRM_Consent_Provided_Ind__c != oldPAConsent.PRM_Consent_Provided_Ind__c) && newPAConsent.PRM_InActive_Ind__c == false) {
                       isUpdated = true;
                       break;
                   }
            } 
           /* if(isUpdated)
            {
                System.enqueueJob(new ContactERPMIntegrationStatusHandler((List<PRM_Partner_Assist_Consent__c>)Trigger.new,  Trigger.new.getSObjectType()));
                IPAfirstRun = false;
            }*/
        }
        
    }
}