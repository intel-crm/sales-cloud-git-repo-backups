/******************************************************************************************************************************************
Class Name  : Core_A_E_Notify_Requester(previously known as Core_A_E_Entitlement_Completion_Email)
Version     : 1.0 
Created Date: 02/28/2020
Function    : Sends notification email to the requester upon the entitlement grant access

*****************************************************************************************************************************************/
Public without sharing class Core_A_E_Notify_Requester{  //
    
    
    public Id conObj {get;set;}
    public Id requestorId {get;set;}
    
    static Id requestorId1;
    static Integer minutes = Integer.valueOf(System.label.Core_A_E_Entitlement_Creation_Time_Window);
    //static Integer agsPendingInMinutes = Integer.valueOf(System.label.Core_A_E_AGS_Pending_Time_Window);
    static DateTime timeCondition = Datetime.now().addMinutes(minutes);
    //static DateTime agsPendingTimeCondition = Datetime.now().addMinutes(agsPendingInMinutes);
    static List<Core_Contact_Entitlement__c> lstContactEntitlements = new List<Core_Contact_Entitlement__c>();
    static List<Core_Contact_Entitlement__c> lstConEntListOfAgsPending = new List<Core_Contact_Entitlement__c> ();
    static Set<Id> setProfIds = New Set<Id> ();
    /*
Method Name: sendEmail()
return : ids of profiles
Description: This method return all the profiles to whom the send notification is enabled  .*/
    
    @InvocableMethod(label='Send Notification To Requestor' description='Notify requestor on A&E grant access status' category='Contact')
    public static void sendEmail(List<Id> contactId)
    {  
        if(System.IsBatch() == false && System.isFuture() == false){
            // your future method call here
            
            sendEmailFuture(contactId);
        }
    }
    //sendEmailFuture() method converted to future context to reduce SOQL Count.[TWC1811-5410]-Bhavani(Draco)
    @future
    public static void sendEmailFuture(List<Id> contactId){
        Set<Id> setRequestorId = new Set<Id>();
        Map<String,Set<Id>> mapProfileWithRequesterId = new Map<String,Set<Id>>();
        
        lstContactEntitlements = new List<Core_Contact_Entitlement__c>();
        
        // Fetching all the contact entitlements where ags status on contact is successfull or failed
        try{
        lstContactEntitlements = [SELECT Core_Entitlement_Requester_Id__r.Id , Core_Entitlement_Id__r.Core_Display_Name__c, Core_Entitlement_Requester_Id__c,Core_Entitlement_Requester_Id__r.UserType, Core_Entitlement_Requester_Id__r.ProfileId,Core_Email_Pending_To_Requester_Ind__c
                                  FROM Core_Contact_Entitlement__c
                                  WHERE Core_Contact_Id__c =:contactId[0]
                                  /*AND LastModifiedDate >=:timeCondition*/ AND Core_Email_Pending_To_Requester_Ind__c = TRUE AND(Core_Contact_Id__r.Core_AGS_Integration_Status__c='Failed' OR Core_Contact_Id__r.Core_AGS_Integration_Status__c='Successful') AND Core_Data_Loaded__c  = FALSE /*ORDER BY lastModifiedDate*/ LIMIT 10000];
        
        
        if(Test.isRunningTest()){ 
            lstConEntListOfAgsPending = [SELECT Core_Entitlement_Requester_Id__r.Id , Core_Entitlement_Id__r.Core_Display_Name__c,Core_Entitlement_Requester_Id__c,Core_Entitlement_Requester_Id__r.UserType, Core_Entitlement_Requester_Id__r.ProfileId
                                         FROM Core_Contact_Entitlement__c
                                         WHERE Core_Contact_Id__c =:contactId[0]
                                         AND Core_Contact_Id__r.Core_AGS_Integration_Status__c='Pending' AND Core_Email_Pending_To_Requester_Ind__c = TRUE AND Core_Data_Loaded__c  = FALSE  LIMIT 10000];
        }
        else{
            // Fetching all the contact entitlements where ags status on contact is pending
            lstConEntListOfAgsPending = [SELECT Core_Entitlement_Requester_Id__r.Id , Core_Entitlement_Id__r.Core_Display_Name__c,Core_Entitlement_Requester_Id__c,Core_Entitlement_Requester_Id__r.UserType, Core_Entitlement_Requester_Id__r.ProfileId
                                         FROM Core_Contact_Entitlement__c
                                         WHERE Core_Contact_Id__c =:contactId[0]
                                         AND Core_Contact_Id__r.Core_AGS_Integration_Status__c='Pending' AND Core_Email_Pending_To_Requester_Ind__c = TRUE AND Core_Data_Loaded__c  = FALSE  LIMIT 10000];
        }
        
        
        if(lstContactEntitlements.size() > 0 ){
            
            Set<Id> setProfileIds = new Set<Id>();
            for(Core_Contact_Entitlement__c contEnt : lstContactEntitlements){
                
                Set<Id> setReqIds = new Set<Id> ();
                String profileId = String.valueOf(contEnt.Core_Entitlement_Requester_Id__r.ProfileId).Substring(0,15);
                if(contEnt.Core_Entitlement_Requester_Id__r.UserType == 'Standard'){
                    setProfileIds.add(profileId);
                }
                if(contEnt.Core_Entitlement_Requester_Id__r.UserType == 'Standard' && mapProfileWithRequesterId.containsKey(profileId)){
                    setRequestorId.add(contEnt.Core_Entitlement_Requester_Id__c);
                    setReqIds.add(contEnt.Core_Entitlement_Requester_Id__c);
                    mapProfileWithRequesterId.get(profileId).addAll(setReqIds);
                }else if(contEnt.Core_Entitlement_Requester_Id__r.UserType == 'Standard' && !mapProfileWithRequesterId.containsKey(profileId)){
                    setReqIds.add(contEnt.Core_Entitlement_Requester_Id__c);
                    setRequestorId.add(contEnt.Core_Entitlement_Requester_Id__c);
                    mapProfileWithRequesterId.put(profileId,setReqIds);
                }
                
            }                
            
            
            sendEmailToRequester(setRequestorId,mapProfileWithRequesterId,contactId,lstContactEntitlements);  
        }
        
        /*********************************Added by Raushan***********************/
        // Check if the list entitlement where ags status is pending on contact 
        if(lstConEntListOfAgsPending.size() > 0){
            
            Set<Id> setProfileIds = new Set<Id>();
            //query on entitlement profile access object for all the profile where send notification is enabled
            for(Core_Contact_Entitlement__c contEnt : lstConEntListOfAgsPending){
                Set<Id> setReqIds = new Set<Id> ();
                String profileId = String.valueOf(contEnt.Core_Entitlement_Requester_Id__r.ProfileId).Substring(0,15);
                if(contEnt.Core_Entitlement_Requester_Id__r.UserType == 'Standard'){
                    setProfileIds.add(profileId);
                }
                if(contEnt.Core_Entitlement_Requester_Id__r.UserType == 'Standard' && mapProfileWithRequesterId.containsKey(profileId)){
                    setRequestorId.add(contEnt.Core_Entitlement_Requester_Id__c);
                    setReqIds.add(contEnt.Core_Entitlement_Requester_Id__c);
                    mapProfileWithRequesterId.get(profileId).addAll(setReqIds);
                }else if (contEnt.Core_Entitlement_Requester_Id__r.UserType == 'Standard' && !mapProfileWithRequesterId.containsKey(profileId)){
                    setRequestorId.add(contEnt.Core_Entitlement_Requester_Id__c);
                    setReqIds.add(contEnt.Core_Entitlement_Requester_Id__c);
                    mapProfileWithRequesterId.put(profileId,setReqIds);
                }
                
            }
            
            sendEmailToRequester(setRequestorId,mapProfileWithRequesterId,contactId,lstConEntListOfAgsPending);
        }
        }catch(exception e){
            Core_Log_Entry__c logEntry = new Core_Log_Entry__c( Core_Message__c = 'Error in class Core_A_E_Notify_Requester method sendEmailFuture',Core_Project__c = 'Draco',Core_Origin__c = 'Core_A_E_Notify_Requester',Core_Details__c = e.getMessage(),Core_Severity__c = 'Error',Core_When__c = System.now());
            Database.insert(logEntry, false);
        }  
    }
    
    
    
    /*
Method Name: sendEmailToRequester()
Description: This method will trigger mail to all the requester whose profile is enabled for send notification .
*/
    
    public static void sendEmailToRequester(set<Id> setRequestorId,Map<String,Set<Id>> mapProfileWithRequesterId,list<Id> contactId,List<Core_Contact_Entitlement__c> lstContactEntitlements){
        try{
        if(setRequestorId.size()>0){
            Messaging.Email[] lstEmails = new Messaging.Email[0];
            string whoId = '';
            string WhatId = '';
            String templateId = '';
            //System.debug('mapProfileWithRequesterId -=='+mapProfileWithRequesterId);
            string templateName = 'Core_A_E_Notify_Grant_Access_Completion';
            List<EmailTemplate> emailTemplateList = new List<EmailTemplate>([SELECT Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where DeveloperName =: templateName LIMIT 1]);
            //query on entitlement profile access object for all the profile where send notification is enabled
            for(Core_Entitlement_Profile_Access__c epa : [Select Core_Profile_Id__c,Core_Send_Notification_Ind__c from Core_Entitlement_Profile_Access__c
                                                          where Core_Send_Notification_Ind__c = TRUE AND Core_Profile_Id__c =: mapProfileWithRequesterId.keySet()])
                
            {
                if (epa.Core_Send_Notification_Ind__c == TRUE && mapProfileWithRequesterId.containsKey(epa.Core_Profile_Id__c)) {
                    for (Id reqId : mapProfileWithRequesterId.get(epa.Core_Profile_Id__c)) {
                        setProfIds.add(epa.Core_Profile_Id__c);
                        // string templateName = 'Core_A_E_Notify_Grant_Access_Completion';
                        whoId = reqId;
                        WhatId = contactId[0];
                        // String templateId = [SELECT Id, Name, DeveloperName FROM EmailTemplate where DeveloperName =:templateName].Id;
                        templateId = emailTemplateList[0].id;
                    }
                }                        
            }
            //Moving this part of code outside of For Each Loop as a part of Sela Code Scan Fixes(TWC1811-6067)
            if(templateId != ''){
                Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate(templateId, whoId, whatId);
                email.saveAsActivity = false;
                lstEmails.add(email);
                
                OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'wsm-postmaster@intel.com'LIMIT 1 ];
                if ( owea.size() > 0 ) {
                    email.setOrgWideEmailAddressId(owea.get(0).Id);
                }
            }
            //System.debug('lstEmails ='+lstEmails);
            
            if(lstEmails.size()>0){
                Messaging.sendEmail(lstEmails);
                
            }              
        }
        
        //Once the mail is triggerd to requestors make the send notification as false
        List<Core_Contact_Entitlement__c> conEntToUpdate = new List<Core_Contact_Entitlement__c>();
        if(lstContactEntitlements.size()>0){
            for(Core_Contact_Entitlement__c contEnt:lstContactEntitlements){
                
                contEnt.Core_Email_Pending_To_Requester_Ind__c = false;
                conEntToUpdate.add(contEnt);
            }
        }    
            Database.Update(conEntToUpdate);
        }catch(Exception e) {
            Core_Log_Entry__c excepLog = new Core_Log_Entry__c(Core_Message__c = e.getMessage(), Core_Origin__c = 'sendEmailToRequester', Core_Project__c = 'Core_A_E_Notify_Requester' , Core_Details__c = 'Error while sending email', Core_Severity__c = 'info', Core_When__c = System.Now());     
            insert excepLog;
        }
    }
    
    
    /* Method Name: getEntilementNames()
return : list of entitlement name
Description: This method return all the latest entitlement names that a requestor have created.*/
    public static Map<Id,Set<String>> getEntitlementNames() {
        Map<Id,Set<String>> mapReqIdToContactEnt = new Map<Id,Set<String>>();
        if(lstContactEntitlements.size()>0 ){
            for(Core_Contact_Entitlement__c ent :lstContactEntitlements){
                /*if(setProfIds.contains(ent.Core_Entitlement_Requester_Id__r.ProfileId)){
lstContactEntitlementNames.add(ent.Core_Entitlement_Id__r.Core_Display_Name__c);
}*/
                //lstContactEntitlementNames.add(ent.Core_Entitlement_Id__r.Core_Display_Name__c);
                if(mapReqIdToContactEnt.containsKey(ent.Core_Entitlement_Requester_Id__c)){
                    
                    mapReqIdToContactEnt.get(ent.Core_Entitlement_Requester_Id__c).add(ent.Core_Entitlement_Id__r.Core_Display_Name__c);
                    
                }
                else{
                    
                    mapReqIdToContactEnt.put(ent.Core_Entitlement_Requester_Id__c, new Set<String>{ent.Core_Entitlement_Id__r.Core_Display_Name__c});
                }  
                
            }
        }
        
        if(lstConEntListOfAgsPending.size()>0){
            for(Core_Contact_Entitlement__c ent :lstConEntListOfAgsPending){
                //lstContactEntitlementNames.add(ent.Core_Entitlement_Id__r.Core_Display_Name__c);
                if(mapReqIdToContactEnt.containsKey(ent.Core_Entitlement_Requester_Id__c)){
                    
                    mapReqIdToContactEnt.get(ent.Core_Entitlement_Requester_Id__c).add(ent.Core_Entitlement_Id__r.Core_Display_Name__c);
                    
                }
                else{
                    
                    mapReqIdToContactEnt.put(ent.Core_Entitlement_Requester_Id__c, new Set<String>{ent.Core_Entitlement_Id__r.Core_Display_Name__c});
                }
            }
        }
        return mapReqIdToContactEnt;
    }
    
}