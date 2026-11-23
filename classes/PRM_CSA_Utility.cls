/*********************************************************************************************************************
Apex Class Name     : PRM_CSA_Utility
Version             : 1.0
Created Date        : Dec 2018
Function            : Restricts user from creating the same Contact Subscription Association record for the same Contact

Modification Log    :
* Developer                 Date                    Description
* --------------------------------------------------------------------------------------------------------------------
* Anupam Agarwal      10-Dec-2018                   Added the new methods duplicateRecordCheck(List) 
                                                    for checking the duplicate Contact
                                                    Subscription Association records

*********************************************************************************************************************/
public with sharing class PRM_CSA_Utility {
    public static void duplicateRecordCheck(List<PRM_ContactSubscriptionAssociation__c> contSubAssociationNewList)
    {   
        Set<String> contactIds = new Set<String>();
        Set<String> partnerSubcriptionId = new Set<String>();
        
        for(PRM_ContactSubscriptionAssociation__c csa : contSubAssociationNewList){
            contactIds.add(csa.PRM_Contact_Id__c); 
        }
        //system.debug('Hi from Contact Set   '+contactIds);
        for(Contact contact : [Select id, name, AccountId, (select id,PRM_Contact_Id__c, PRM_Partner_Subscription_Id__c,PRM_Status_Nm__c from  Contact_Subscription_Associations__r where PRM_Contact_Id__c in :contactIds) from Contact where id in :contactIds]){
            for(PRM_ContactSubscriptionAssociation__c csaRecord:contact.Contact_Subscription_Associations__r){
                partnerSubcriptionId.add(csaRecord.PRM_Partner_Subscription_Id__c);  
            }
        }
        //system.debug('Hi from Set   '+partnerSubcriptionId);
        //system.debug('inside mehotd 12'+contactIds);
        
            List<PRM_ContactSubscriptionAssociation__c> csaList = [Select Id , PRM_Contact_Id__c, PRM_Partner_Subscription_Id__c, PRM_Status_Nm__c from PRM_ContactSubscriptionAssociation__c where PRM_Contact_Id__c in :contactIds and PRM_Partner_Subscription_Id__c in :partnerSubcriptionId];
            if(csaList.size()>0){
                for(PRM_ContactSubscriptionAssociation__c csa : contSubAssociationNewList){
                    if(partnerSubcriptionId.contains(csa.PRM_Partner_Subscription_Id__c) && csa.PRM_Status_Nm__c == 'Inactive'){
                        csa.addError ('This subscription is already assigned and currently inactive. Please activate the same subscription');
                    } 
                    else if(partnerSubcriptionId.contains(csa.PRM_Partner_Subscription_Id__c) && csa.PRM_Status_Nm__c == 'Active'){
                        csa.addError ('This subscription is already assigned to the contact');
                    }
                } 
            } 
        
    }
    
    //This method blanks out inactive status reason when a contact susbcription is activated again
    public static void updateConSubscription(List<PRM_ContactSubscriptionAssociation__c> contSubAssociationNewList, Map<id, PRM_ContactSubscriptionAssociation__c> oldMap){
        for(PRM_ContactSubscriptionAssociation__c csa: contSubAssociationNewList){
            if(oldMap != null && oldMap.get(csa.id) != null && oldMap.get(csa.id).PRM_Status_Nm__c == 'Inactive' && csa.PRM_Status_Nm__c == 'Active'){
                csa.PRM_Status_Reason_Txt__c = 'Activated as Contact eligible';
            }
        }
    }
}