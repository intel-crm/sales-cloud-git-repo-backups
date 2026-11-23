public without sharing class userEVInternalUser {

    
    
    public Id conObj {get;set;}
    public Id requestorId {get;set;}
    Static Set<String> setEntitlementName = new Set<String>();
    
    /*
Method Name: sendEmail()
return : null
Description: This method send email to user  .*/
    
    @InvocableMethod(label='Send Email to Requester on EV' description='Notify requestor after Email Verification is completed')
    public static void sendEmail(List<Id> contactId){
        
        Set<Id> setRequestorId = new Set<Id>();
        //Set<String> setEntitlementName = new Set<String>();
        Messaging.Email[] lstEmails = new Messaging.Email[0];
        // Map<Id,List<string>> requesterEn
        List<Core_Contact_Entitlement__c> conEntlmtLst = new List<Core_Contact_Entitlement__c>([SELECT
                                                                                                Core_Entitlement_Requester_Id__c,
                                                                                                Core_Contact_Id__r.Id,
                                                                                                Core_Source__c,
                                                                                                Core_Entitlement_Id__r.name,
                                                                                                Core_Entitlement_Requester_Id__r.UserType, 
                                                                                                Core_Entitlement_Requester_Id__r.ProfileId,
                                                                                                Core_Email_Pending_To_Requester_Ind__c, 
                                                                                                Core_Selected__c
                                                                                                FROM Core_Contact_Entitlement__c
                                                                                                WHERE Core_Contact_Id__c in:contactId and Core_Source__c = 'Grant Access']);
        
        if(conEntlmtLst.size()>0){
            for(Core_Contact_Entitlement__c conEntl :conEntlmtLst){
                setRequestorId.add(conEntl.Core_Entitlement_Requester_Id__c);
                setEntitlementName.add(conEntl.Core_Entitlement_Id__r.name);
                
            }
        }
        
        string templateName = 'Notification_to_Internal_Users_on_EV';
        string WhatId = contactId[0];
        
        for(Id reqId :setRequestorId){
            string whoId =  reqId;
            
            String templateId = [SELECT Id, Name, DeveloperName FROM EmailTemplate where DeveloperName =:templateName].Id;
            Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate(templateId, whoId, whatId);
            lstEmails.add(email);
        }
        
        if(lstEmails.size()>0){
            Messaging.sendEmail(lstEmails);
            
        } 
        
    }
    
    public Set<string> getEntitlementList(){
        return setEntitlementName;
        
    
    
}

}