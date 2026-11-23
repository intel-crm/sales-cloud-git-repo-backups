/******************************************************************************************************************************
Apex Class Name:  Core_internalUserNotificationOnEV
Version     : 1.0 
Created Date: 11 AUG 2021
Function    : This class contains methods to send email notification to Entitlement Requester on Email Verification completion of Contacts
Modification Log :
* Developer                   Date                   Description
* ---------------------------------------------------------------------------- 
Subhadeep Sadhu				10-Dec-2021				Added checks for blank Core_Entitlement_Requester_Id__c contact entitlements 
*******************************************************************************************************************************/
Public without sharing class Core_internalUserNotificationOnEV {    
    /*
Method Name: sendEmailOnEvCompletion()
return : null
Description: This method send email to contact entitlement requester  .*/
    
    @InvocableMethod(label='Send Email to Requester on EV' description='Notify requestor after Email Verification is completed')
    public static void sendEmailOnEvCompletion(List<Id> contactId){
        //Set<String> setEntitlementName = new Set<String>();
        Messaging.Email[] lstEmails = new Messaging.Email[0];
        
        List<Core_Contact_Entitlement__c> conEntlmtLst = new List<Core_Contact_Entitlement__c>([SELECT
                                                                                                Core_Entitlement_Requester_Id__c,
                                                                                                Core_Contact_Id__r.Id,
                                                                                                Core_Source__c,
                                                                                                Core_Entitlement_Id__r.name,
                                                                                                Core_Entitlement_Requester_Id__r.UserType, 
                                                                                                //Core_Entitlement_Requester_Id__r.ProfileId,
                                                                                                Core_Email_Pending_To_Requester_Ind__c, 
                                                                                                Core_Selected__c
                                                                                                FROM Core_Contact_Entitlement__c
                                                                                                WHERE Core_Contact_Id__c in:contactId 
                                                                                                AND Core_Source__c = 'Grant Access' 
                                                                                                AND Core_Selected__c = True 
                                                                                                AND Core_Status__c = 'Complete'
                                                                                                AND Core_Entitlement_Requester_Id__c != null]);
        
        if(conEntlmtLst.size()>0){
            //internalUserNotificationOnEV userEVClass = new internalUserNotificationOnEV();
            System.debug('Cont entl exists.');
            set<string> contactUser = new set<string>();
            string whoId, whatId;
            string templateName = 'Notification_to_Internal_Users_on_EV';
            String templateId = [SELECT Id, Name, DeveloperName FROM EmailTemplate where DeveloperName =:templateName].Id;
            
            
            for(Core_Contact_Entitlement__c conEntl :conEntlmtLst){
                if(!contactUser.contains(conEntl.Core_Entitlement_Requester_Id__c +'__'+ conEntl.Core_Contact_Id__r.Id)){
                    whoId = conEntl.Core_Entitlement_Requester_Id__c;
                    whatId = conEntl.Core_Contact_Id__r.Id;
                    Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate(templateId, whoId, whatId);
                    email.saveAsActivity = false;
                    lstEmails.add(email);
                    OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'wsm-postmaster@intel.com'LIMIT 1 ];
                    if ( owea.size() > 0 ) {
                        email.setOrgWideEmailAddressId(owea.get(0).Id);
                    }
                    contactUser.add(conEntl.Core_Entitlement_Requester_Id__c +'__'+ conEntl.Core_Contact_Id__r.Id);
                }
            }
        }
        
        //System.debug('Request Id>>'+reqId);
        if(lstEmails.size()>0){
            Messaging.sendEmail(lstEmails);
            
        } 
        
    }
    
}