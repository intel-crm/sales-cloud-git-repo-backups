/******************************************************************************************************************************************
Class Name  : Core_A_E_Entitlement_Completion_Email
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
        
        Set<Id> setRequestorId = new Set<Id>();
        Map<String,Set<Id>> mapProfileWithRequesterId = new Map<String,Set<Id>>();
		
        lstContactEntitlements = new List<Core_Contact_Entitlement__c>();
        
        // Fetching all the contact entitlements where ags status on contact is successfull or failed
       
        lstContactEntitlements = [SELECT Core_Entitlement_Requester_Id__r.Id , Core_Entitlement_Id__r.Core_Display_Name__c, Core_Entitlement_Requester_Id__c,Core_Entitlement_Requester_Id__r.UserType, Core_Entitlement_Requester_Id__r.ProfileId,Core_Email_Pending_To_Requester_Ind__c
                               		FROM Core_Contact_Entitlement__c
                               		WHERE Core_Contact_Id__c =:contactId[0]
                               		/*AND LastModifiedDate >=:timeCondition*/ AND Core_Email_Pending_To_Requester_Ind__c = TRUE AND(Core_Contact_Id__r.Core_AGS_Integration_Status__c='Failed' OR Core_Contact_Id__r.Core_AGS_Integration_Status__c='Successful') AND Core_Data_Loaded__c  = FALSE /*ORDER BY lastModifiedDate*/ LIMIT 10000];
                               
        
        if(Test.isRunningTest()){ 
            	 lstConEntListOfAgsPending = [SELECT Core_Entitlement_Requester_Id__r.Id , Core_Entitlement_Id__r.Core_Display_Name__c,Core_Entitlement_Requester_Id__c,Core_Entitlement_Requester_Id__r.UserType, Core_Entitlement_Requester_Id__r.ProfileId
                                 		FROM Core_Contact_Entitlement__c
                                		WHERE Core_Contact_Id__c =:contactId[1]
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
                if(contEnt.Core_Entitlement_Requester_Id__r.UserType == 'Standard'){
                    
                    String profileId = String.valueOf(contEnt.Core_Entitlement_Requester_Id__r.ProfileId).Substring(0,15);
                    setProfileIds.add(profileId);
                    if(mapProfileWithRequesterId.containsKey(profileId)){
                        setRequestorId.add(contEnt.Core_Entitlement_Requester_Id__c);
                        setReqIds.add(contEnt.Core_Entitlement_Requester_Id__c);
                        mapProfileWithRequesterId.get(profileId).addAll(setReqIds);
                    }else{
                        setReqIds.add(contEnt.Core_Entitlement_Requester_Id__c);
                        setRequestorId.add(contEnt.Core_Entitlement_Requester_Id__c);
                        mapProfileWithRequesterId.put(profileId,setReqIds);
                    }
                    
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
                if(contEnt.Core_Entitlement_Requester_Id__r.UserType == 'Standard'){
                    
                    String profileId = String.valueOf(contEnt.Core_Entitlement_Requester_Id__r.ProfileId).Substring(0,15);
                    setProfileIds.add(profileId);
                    if(mapProfileWithRequesterId.containsKey(profileId)){
                        setRequestorId.add(contEnt.Core_Entitlement_Requester_Id__c);
                        setReqIds.add(contEnt.Core_Entitlement_Requester_Id__c);
                        mapProfileWithRequesterId.get(profileId).addAll(setReqIds);
                    }else{
                        setRequestorId.add(contEnt.Core_Entitlement_Requester_Id__c);
                        setReqIds.add(contEnt.Core_Entitlement_Requester_Id__c);
                        mapProfileWithRequesterId.put(profileId,setReqIds);
                    }
                }                
            }
              
			sendEmailToRequester(setRequestorId,mapProfileWithRequesterId,contactId,lstConEntListOfAgsPending);
        }
        
    }
    
    
       
	/*
    Method Name: sendEmailToRequester()
    Description: This method will trigger mail to all the requester whose profile is enabled for send notification .
	*/
    
	public static void sendEmailToRequester(set<Id> setRequestorId,Map<String,Set<Id>> mapProfileWithRequesterId,list<Id> contactId,List<Core_Contact_Entitlement__c> lstContactEntitlements){
		if(setRequestorId.size()>0){
                Messaging.Email[] lstEmails = new Messaging.Email[0];
            	System.debug('mapProfileWithRequesterId -=='+mapProfileWithRequesterId);
               //query on entitlement profile access object for all the profile where send notification is enabled
                for(Core_Entitlement_Profile_Access__c epa : [Select Core_Profile_Id__c,Core_Send_Notification_Ind__c from Core_Entitlement_Profile_Access__c
                                                              where Core_Send_Notification_Ind__c = TRUE AND Core_Profile_Id__c =: mapProfileWithRequesterId.keySet()])
                 
                {
                    system.debug('send notification' + epa.Core_Send_Notification_Ind__c + 'profile id' + epa.Core_Profile_Id__c);
                                                                  if(epa.Core_Send_Notification_Ind__c == TRUE)
                                                                  {
                                                                      if(mapProfileWithRequesterId.containsKey(epa.Core_Profile_Id__c)){
                                                                          for(Id reqId : mapProfileWithRequesterId.get(epa.Core_Profile_Id__c)){
                                                                              setProfIds.add(epa.Core_Profile_Id__c);
                                                                              string templateName = 'Core_A_E_Notify_Grant_Access_Completion';
                                                                              string whoId =  reqId;
                                                                              string WhatId = contactId[0];
                                                                              String templateId = [SELECT Id, Name, DeveloperName FROM EmailTemplate where DeveloperName =:templateName].Id;
                                                                              Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate(templateId, whoId, whatId);
                                                                              email.saveAsActivity = false;
                                                                              lstEmails.add(email);
                                                                          }
                                                                      }
                                                                  }                        
                                                              }
            	System.debug('lstEmails ='+lstEmails);
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
       
        try{
            Database.Update(conEntToUpdate);
        }catch(Exception e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }
		
	}
    
    
    /* Method Name: getEntilementNames()
	   return : list of entitlement name
	   Description: This method return all the latest entitlement names that a requestor have created.*/
    public static Map<Id,Set<String>> getEntitlementNames() {
        list<String> lstContactEntitlementNames = new list<String>();
        Map<Id,Set<String>> mapReqIdToContactEnt = new Map<Id,Set<String>>();
        System.debug('lstContactEntitlements'+lstContactEntitlements.size());
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