public without sharing class ACM_DeleteDupsOnContactMergeHandler {
    
    public static void contactStagingRecords(Set<Id> survivorContactIds){
        Map<id, Contact> deletedCons = new Map<Id, contact>([SELECT id, MasterRecordId from contact where id in :survivorContactIds and isDeleted= true ALL ROWS]);
        Set<Id> masterRecordIds = new Set<Id>();
        for(Id masterIds: deletedCons.keySet()){
            masterRecordIds.add(deletedCons.get(masterIds).MasterRecordId);
        }
        List<Core_ACM_Contact_Staging__c> stagingList = new List<Core_ACM_Contact_Staging__c>(); 
        for(Id stagingIds: masterRecordIds){
            Core_ACM_Contact_Staging__c staging = new Core_ACM_Contact_Staging__c();
            staging.ContactId__c = stagingIds;
            staging.Core_Action__c = 'CM';
            staging.Core_Status__c = 'NEW';
            stagingList.add(staging);
        }
        Database.insert(stagingList,false);
    }
    
    /*public static Map<String, Set<Id>> deleteRelatedRecords(Set<Id> ContacIds) {
Map<String, Set<Id>> ContactResults = new Map<String, Set<Id>>();
//ContactResults.put('Success', new Set<Id>());
//ContactResults.put('Failed', new Set<Id>());
Map<String, Set<id>> tempContacts;
Set<id> failedIds = new Set<id>();
Set<id> successIds = new Set<id>();
try{
tempContacts = deleteDupsOnPrtnrCommEnrmntReq(ContacIds);
//Add Success IDs

successIds = ContactResults.get('Success'); 
successIds.addAll(tempContacts?.get('Success')); 
ContactResults.put('Success', successIds);
// Add Failed IDs 
failedIds = ContactResults.get('Failed'); 
failedIds.addAll(tempContacts?.get('Failed')); 
ContactResults.put('Failed', failedIds);
} catch(exception e) {
updateStaging(ContacIds, 'PRM_Partner_Community_Enrollment_Request__c');
}

try{
tempContacts = deleteDupsOnInquiry(ContacIds);
} catch(exception e) {
updateStaging(ContacIds,'Core_Inquiry__c');
}
//Add Success IDs
successIds = ContactResults.get('Success'); 
successIds.addAll(tempContacts.get('Success')); 
ContactResults.put('Success', successIds);
// Add Failed IDs 
failedIds = ContactResults.get('Failed'); 
failedIds.addAll(tempContacts.get('Failed')); 
ContactResults.put('Failed', failedIds);

try{
tempContacts = deleteDupsOnContSubscription(ContacIds);
} catch (exception e){
updateStaging(ContacIds,'PRM_ContactSubscriptionAssociation__c');
}
//Add Success IDs
successIds = ContactResults.get('Success'); 
successIds.addAll(tempContacts.get('Success')); 
ContactResults.put('Success', successIds);
// Add Failed IDs 
failedIds = ContactResults.get('Failed'); 
failedIds.addAll(tempContacts.get('Failed')); 
ContactResults.put('Failed', failedIds);

try{
tempContacts = deleteDupsOnContEngagement(ContacIds);
} catch (exception e){
updateStaging(ContacIds,'Core_Contact_Engagement__c');
}
//Add Success IDs
successIds = ContactResults.get('Success'); 
successIds.addAll(tempContacts.get('Success')); 
ContactResults.put('Success', successIds);
// Add Failed IDs 
failedIds = ContactResults.get('Failed'); 
failedIds.addAll(tempContacts.get('Failed')); 
ContactResults.put('Failed', failedIds);

if(ContactResults == null){
ContactResults.put('Success',null);
ContactResults.put('Failed', null);
}
return ContactResults;

}

public static void updateStaging(Set<Id> ContacIds, String Error){
List<Core_ACM_Contact_Staging__c> stagingList = new List<Core_ACM_Contact_Staging__c>();
//List<Core_ACM_Contact_Staging__c> stagingRecList = new List<Core_ACM_Contact_Staging__c>([Select id,ContactId__c from Core_ACM_Contact_Staging__c WHERE Core_Status__c = 'NEW' and ContactId__c in :ContacIds]);
for(Core_ACM_Contact_Staging__c stagingRec: [Select id,ContactId__c from Core_ACM_Contact_Staging__c WHERE Core_Status__c = 'NEW' and ContactId__c in :ContacIds]){
stagingRec.Core_Action__c = 'CM';
stagingRec.Core_Status__c = 'FAILED';
stagingRec.Status_Details__c = Error;
stagingList.add(stagingRec);
}
update stagingList;
}

//To delete the PremierSupportProjectMember duplicate records after contact merge 
public static Map<String,Set<id>> deleteDupsOnPrmrSupportProjMem(Set<Id> contactIds) {
List<Core_IPS_Project_Member__c> deletionContactProjMemList = new List<Core_IPS_Project_Member__c>();
Map<id, Core_IPS_Project_Member__c> projMemMap = new Map<id, Core_IPS_Project_Member__c>([select id,Core_Status__c,Core_IPS_Contact__c,
Core_IPS_Project__r.name, CreatedDate,Core_IPS_Project__c
from Core_IPS_Project_Member__c where Core_IPS_Contact__c =: contactIds and Core_IPS_Project__c != NULL 
order by Core_Status__c, CreatedDate]);  
List<string> contactProjMemList = new List<string>();
Database.DeleteResult[] deleteProjectResults;
map<String,Set<id>> returnProjectMemberMap= new map<String,Set<id>> ();
try {
if(!projMemMap.isEmpty()) {
for(Core_IPS_Project_Member__c projMem:projMemMap.values()) {
string Key = String.valueOf(projMem.Core_IPS_Contact__c)+'_'+(projMem.Core_IPS_Project__c!=null ? String.valueOf(projMem.Core_IPS_Project__r.name) : '');
if (contactProjMemList.contains(Key)) {
if (Core_IPS_Project_Member__c.sObjectType.getDescribe().isDeletable()){
deletionContactProjMemList.add(projMem);
}
} else {
contactProjMemList.add(Key);
}
}
if(!deletionContactProjMemList.isEmpty()) {
if (Core_IPS_Project_Member__c.sObjectType.getDescribe().isDeletable()){
deleteProjectResults = Database.delete(deletionContactProjMemList, false);
system.debug('deleteresults'+deleteProjectResults);                     
}
}
Set<id> FailedConIDs = new Set<id>();
Set<id> SuccessConIDs = new Set<id>();
for(Database.DeleteResult dr : deleteProjectResults) { 
if (dr.isSuccess()) {
SuccessConIDs.add(projMemMap.get(dr.getId()).Core_IPS_Contact__c);
} else {
FailedConIDs.add(projMemMap.get(dr.getId()).Core_IPS_Contact__c);
}
}
returnProjectMemberMap.put('Success',SuccessConIDs );
returnProjectMemberMap.put('Failed', FailedConIDs);
}


} catch (Exception ex) {
UCD_ACM_Logger.error('ACM_DeleteDupsOnContactMergeHandler','deleteDupsOnPrmrSupportProjMem','ContactIds: ' +String.join(new List<Id>(contactIds), ', ') + ' projMemMap: ' + projMemMap + '  Message: ' + ex.getStackTraceString(),null);

}
if(returnProjectMemberMap == null){
returnProjectMemberMap.put('Success',null);
returnProjectMemberMap.put('Failed', null);
}
return returnProjectMemberMap;
}*/
    
    //To delete the Partner Community Enrollment Request duplicate records after contact merge 
    public static Map<String,Set<id>> deleteDupsOnPrtnrCommEnrmntReq(Set<Id> contactIds) {
        List<PRM_Partner_Community_Enrollment_Request__c> deletionContactPartnrReqList = new List<PRM_Partner_Community_Enrollment_Request__c>();
        Map<id,PRM_Partner_Community_Enrollment_Request__c> partnrReqMap = new Map<id, PRM_Partner_Community_Enrollment_Request__c> ([select id,PRM_Status_Nm__c,PRM_Contact_Id__c,
                                                                                                                                      CreatedDate,PRM_Partner_Community_Nm__c
                                                                                                                                      from PRM_Partner_Community_Enrollment_Request__c where PRM_Contact_Id__c =: contactIds
                                                                                                                                      order by CreatedDate desc]);  
        List<string> contactPartnrReqList = new List<string>();
        Database.DeleteResult[] deletePartnerRequestResults;
        map<String,Set<id>> returnPartnerRequestMap= new map<String,Set<id>> ();
        try {
            if(!partnrReqMap.isEmpty()) {
                for(PRM_Partner_Community_Enrollment_Request__c partnrReq:partnrReqMap.values()) {
                    string Key = String.valueOf(partnrReq.PRM_Contact_Id__c)+'_'+ String.valueOf(partnrReq.PRM_Partner_Community_Nm__c);
                    if (contactPartnrReqList.contains(Key)) {
                        if (Schema.sObjectType.PRM_Partner_Community_Enrollment_Request__c.isDeletable()){
                            deletionContactPartnrReqList.add(partnrReq);
                        }
                    } else {
                        contactPartnrReqList.add(Key);
                    }
                }
                if(!deletionContactPartnrReqList.isEmpty()) {
                    if (Schema.sObjectType.PRM_Partner_Community_Enrollment_Request__c.isDeletable()){
                        deletePartnerRequestResults = Database.delete(deletionContactPartnrReqList, false);
                    }
                }
                Set<id> FailedConIDs = new Set<id>();
                Set<id> SuccessConIDs = new Set<id>();
                for(Database.DeleteResult dr : deletePartnerRequestResults) { 
                    if (dr.isSuccess()) {
                        SuccessConIDs.add(partnrReqMap.get(dr.getId()).PRM_Contact_Id__c);
                    } else {
                        FailedConIDs.add(partnrReqMap.get(dr.getId()).PRM_Contact_Id__c);
                    }
                }
                returnPartnerRequestMap.put('Success',SuccessConIDs );
                returnPartnerRequestMap.put('Failed', FailedConIDs);
            }
            
        } catch (Exception ex) {
            UCD_ACM_Logger.error('ACM_DeleteDupsOnContactMergeHandler','deleteDupsOnPrtnrCommEnrmntReq','ContactIds: ' +String.join(new List<Id>(contactIds), ', ') + ' partnrReqMap: ' + partnrReqMap + '  Message: ' + ex.getStackTraceString(),null);
            
        }
        if(returnPartnerRequestMap == null){
            returnPartnerRequestMap.put('Success',null);
            returnPartnerRequestMap.put('Failed', null);
        }
        return returnPartnerRequestMap;
    }
    
    //To delete the Inquiry duplicate records after contact merge 
    public static Map<String,Set<id>> deleteDupsOnInquiry(Set<Id> contactIds) {
        List<Core_Inquiry__c> deletionContactInquiryList = new List<Core_Inquiry__c>();
        Map<id,Core_Inquiry__c> InquiryMap =new Map<id,Core_Inquiry__c> ([select id,Core_Contact_Inquiries__c,
                                                                          CreatedDate,Name,Core_Inquiry_Type_Pkt__c
                                                                          from Core_Inquiry__c where Core_Contact_Inquiries__c =: contactIds
                                                                          order by CreatedDate desc]);  
        List<string> contactInquiryList = new List<string>();
        Database.DeleteResult[] deleteInquiryResults;
        map<String,Set<id>> returnInquiryMap= new map<String,Set<id>> ();
        try {
            if(!InquiryMap.isEmpty() && InquiryMap != null) {
                for(Core_Inquiry__c Inquiry:InquiryMap.values()) {
                    string Key = String.valueOf(Inquiry.Core_Contact_Inquiries__c)+'_'+String.valueOf(Inquiry.Core_Inquiry_Type_Pkt__c);
                    if (contactInquiryList.contains(Key)) {
                        if (Schema.sObjectType.Core_Inquiry__c.isDeletable()){
                            deletionContactInquiryList.add(Inquiry);
                        }
                    } else {
                        contactInquiryList.add(Key);
                    }
                }
                if(!deletionContactInquiryList.isEmpty()) {
                    if (Schema.sObjectType.Core_Inquiry__c.isDeletable()){
                        deleteInquiryResults = Database.delete(deletionContactInquiryList, false);
                    }
                }
                Set<id> FailedConIDs = new Set<id>();
                Set<id> SuccessConIDs = new Set<id>();
                for(Database.DeleteResult dr : deleteInquiryResults) { 
                    if (dr.isSuccess()) {
                        SuccessConIDs.add(InquiryMap.get(dr.getId()).Core_Contact_Inquiries__c);
                    } else {
                        FailedConIDs.add(InquiryMap.get(dr.getId()).Core_Contact_Inquiries__c);
                    }
                }
                returnInquiryMap.put('Success',SuccessConIDs );
                returnInquiryMap.put('Failed', FailedConIDs);
            }
            
        } catch (Exception ex) {
            UCD_ACM_Logger.error('ACM_DeleteDupsOnContactMergeHandler','deleteDupsOnInquiry','ContactIds: ' +String.join(new List<Id>(contactIds), ', ') + ' InquiryMap: ' + InquiryMap + '  Message: ' + ex.getStackTraceString(),null);
        }
        if(returnInquiryMap == null){
            returnInquiryMap.put('Success',null);
            returnInquiryMap.put('Failed', null);
        }
        return returnInquiryMap;
    }
    
    //To delete the Contact Subscription Association duplicate records after contact merge 
    public static Map<String,Set<id>> deleteDupsOnContSubscription(Set<Id> contactIds) {
        List<PRM_ContactSubscriptionAssociation__c> deletionContactSubscriptionList = new List<PRM_ContactSubscriptionAssociation__c>();
        Map<id,PRM_ContactSubscriptionAssociation__c> SubscriptionMap =new Map<id,PRM_ContactSubscriptionAssociation__c> ([select id,PRM_Contact_Id__c,
                                                                                                                           PRM_Partner_Subscription_Id__c,CreatedDate,PRM_Status_Nm__c,PRM_Partner_Subscription_Id__r.Name
                                                                                                                           from PRM_ContactSubscriptionAssociation__c where PRM_Contact_Id__c =: contactIds
                                                                                                                           order by PRM_Status_Nm__c,CreatedDate]);  
        List<string> contactSubscriptionList = new List<string>();
        Database.DeleteResult[] deleteSubscriptionResults;
        map<String,Set<id>> returnSubscriptionMap= new map<String,Set<id>> ();
        try {
            if(!SubscriptionMap.isEmpty()) {
                for(PRM_ContactSubscriptionAssociation__c Subscription:SubscriptionMap.values()) {
                    string Key = String.valueOf(Subscription.PRM_Contact_Id__c)+'_'+(Subscription.PRM_Partner_Subscription_Id__c!=null ? String.valueOf(Subscription.PRM_Partner_Subscription_Id__r.Name) : '');
                    if (contactSubscriptionList.contains(Key)) {
                        if (Schema.sObjectType.PRM_ContactSubscriptionAssociation__c.isDeletable()){
                            deletionContactSubscriptionList.add(Subscription);
                        }
                    } else {
                        contactSubscriptionList.add(Key);
                    }
                }
                if(!deletionContactSubscriptionList.isEmpty()) {
                    if (Schema.sObjectType.PRM_ContactSubscriptionAssociation__c.isDeletable()){
                        deleteSubscriptionResults = Database.delete(deletionContactSubscriptionList, false);
                    }
                }
                Set<id> FailedConIDs = new Set<id>();
                Set<id> SuccessConIDs = new Set<id>();
                for(Database.DeleteResult dr : deleteSubscriptionResults) { 
                    if (dr.isSuccess()) {
                        SuccessConIDs.add(SubscriptionMap.get(dr.getId()).PRM_Contact_Id__c);
                    } else {
                        FailedConIDs.add(SubscriptionMap.get(dr.getId()).PRM_Contact_Id__c);
                    }
                }
                returnSubscriptionMap.put('Success',SuccessConIDs );
                returnSubscriptionMap.put('Failed', FailedConIDs);
            }
            
        } catch (Exception ex) {
            UCD_ACM_Logger.error('ACM_DeleteDupsOnContactMergeHandler','deleteDupsOnContSubscription','ContactIds: ' +String.join(new List<Id>(contactIds), ', ') + ' SubscriptionMap: ' + SubscriptionMap + '  Message: ' + ex.getStackTraceString(),null);
        }
        if(returnSubscriptionMap == null){
            returnSubscriptionMap.put('Success',null);
            returnSubscriptionMap.put('Failed', null);
        }
        return returnSubscriptionMap;
    }
    
    //To delete the Contact Engagement duplicate records after contact merge 
    public static Map<String,Set<id>> deleteDupsOnContEngagement(Set<Id> contactIds) {
        List<Core_Contact_Engagement__c> deletionContactEngagementList = new List<Core_Contact_Engagement__c>();
        Map<id,Core_Contact_Engagement__c> EngagementMap =new Map<id,Core_Contact_Engagement__c> ([select id,Core_Contact__c,
                                                                                                   Core_Engagement__c,CreatedDate,Core_Active__c,Core_Engagement_Label__c
                                                                                                   from Core_Contact_Engagement__c where Core_Contact__c =: contactIds
                                                                                                   order by Core_Active__c desc,CreatedDate asc]);  
        List<string> contactEngagementList = new List<string>();
        Database.DeleteResult[] deleteEngagementResults;
        map<String,Set<id>> returnEngagementMap= new map<String,Set<id>> ();
        try {
            if(!EngagementMap.isEmpty()) {
                for(Core_Contact_Engagement__c Engagement:EngagementMap.values()) {
                    string Key = String.valueOf(Engagement.Core_Contact__c)+'_'+(Engagement.Core_Engagement__c!=null ? String.valueOf(Engagement.Core_Engagement_Label__c) : '');
                    if (contactEngagementList.contains(Key)) {
                        if (Schema.sObjectType.Core_Contact_Engagement__c.isDeletable()){
                            deletionContactEngagementList.add(Engagement);
                        }
                    } else {
                        contactEngagementList.add(Key);
                    }
                }
                if(!deletionContactEngagementList.isEmpty()) {
                    if (Schema.sObjectType.Core_Contact_Engagement__c.isDeletable()){
                        deleteEngagementResults = Database.delete(deletionContactEngagementList, false);
                    }
                }
                Set<id> FailedConIDs = new Set<id>();
                Set<id> SuccessConIDs = new Set<id>();
                for(Database.DeleteResult dr : deleteEngagementResults) { 
                    if (dr.isSuccess()) {
                        SuccessConIDs.add(EngagementMap.get(dr.getId()).Core_Contact__c);
                    } else {
                        FailedConIDs.add(EngagementMap.get(dr.getId()).Core_Contact__c);
                    }
                }
                returnEngagementMap.put('Success',SuccessConIDs );
                returnEngagementMap.put('Failed', FailedConIDs);
            }
            
        } catch (Exception ex) {
            UCD_ACM_Logger.error('ACM_DeleteDupsOnContactMergeHandler','deleteDupsOnContEngagement','ContactIds: ' +String.join(new List<Id>(contactIds), ', ') + ' EngagementMap: ' + EngagementMap + '  Message: ' + ex.getStackTraceString(),null);
        }
        if(returnEngagementMap == null){
            returnEngagementMap.put('Success',null);
            returnEngagementMap.put('Failed', null);
        }
        return returnEngagementMap;
    }
}