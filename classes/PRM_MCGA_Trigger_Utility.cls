/***************************************************************************************************************************************
Apex Class Name     : PRM_MCGA_Trigger_Utility 
Version             : 1.0
Created Date        : March 2020
Function            : Utility class for PRM_MCGA_Trigger_Handler.
Maximum Batch Size  : 
Modification Log    :
* Developer                         Date                           Description
* ------------------------------------------------------------------------------------------------------------------------------------
* Srishty                        8-June-2020                     US651041-add the contacts form the group into the message log on assigning the contact group to the message
* Srishty                       17-June-2020                     US695552-Trigger will create record in Message Log for only Message with Adhoc type and duplicate contact 
with same Message and different Contact Group will upsert in Message Log.
*************************************************************************************************************************************/
public without sharing class PRM_MCGA_Trigger_Utility {
    
    //This method will create record in Message log when Message Contact Group Associciation Record is newly created.
    public static void createMessageLogForContact(List<PRM_Message_Contact_Group_Association__c> mcgaList){
        List<PRM_Message_log__c> msgLogList = new List<PRM_Message_log__c>();
        Map<Id,Set<Id>> contactGroupIdWithMessageIdsMap = new Map<Id,Set<Id>>();
        Set<String> messageContactSet = new Set<String>();
        Set<Id> messageIdsSet =new Set<Id>();
        Id recordTypeId=Schema.SObjectType.PRM_Message__c.getRecordTypeInfosByName().get(System.Label.PRM_Adhoc).getRecordTypeId();
        for(PRM_Message_Contact_Group_Association__c mcga: mcgaList ){
            if(mcga.PRM_Message_Id__c !=Null){
                messageIdsSet.add(mcga.PRM_Message_Id__c);
            }
        }
        Map<Id,PRM_Message__c> messageMap =new Map<Id,PRM_Message__c>([Select Id ,RecordTypeId from PRM_Message__c where Id IN:messageIdsSet]);
        
        
        for(PRM_Message_Contact_Group_Association__c mcga: mcgaList ){
            if(mcga.PRM_Message_Id__c!=Null){
                PRM_Message__c message = messageMap.get(mcga.PRM_Message_Id__c);
                if(message.RecordTypeId==recordTypeId){//for Adhoc Record type Message only.
                    if(contactGroupIdWithMessageIdsMap.containsKey(mcga.PRM_Contact_Group_Id__c)){
                        Set<Id> messageIds = contactGroupIdWithMessageIdsMap.get(mcga.PRM_Contact_Group_Id__c);
                        messageIds.add(mcga.PRM_Message_Id__c);
                        contactGroupIdWithMessageIdsMap.put(mcga.PRM_Contact_Group_Id__c,messageIds);
                    }
                    else{
                        Set<Id> messageIds = new Set<Id>();
                        messageIds.add(mcga.PRM_Message_Id__c);
                        contactGroupIdWithMessageIdsMap.put(mcga.PRM_Contact_Group_Id__c,messageIds);
                    }
                }
            }
        }//Loop Ends here.
        for(PRM_Contact_Group_Contact_Association__c contactGroupWithContactAssoc :[Select Id,PRM_Contact_Id__c,PRM_Contact_Group_Id__c from PRM_Contact_Group_Contact_Association__c where PRM_Contact_Group_Id__c IN:contactGroupIdWithMessageIdsMap.keySet() AND PRM_InActive_Ind__c =:False]){
            Set<Id> messageIds = contactGroupIdWithMessageIdsMap.get(contactGroupWithContactAssoc.PRM_Contact_Group_Id__c);
            String contactsMessageConcatenation = String.join(new List<Id>(messageIds),'-'+contactGroupWithContactAssoc.PRM_Contact_Id__c+',');
            contactsMessageConcatenation = contactsMessageConcatenation+'-'+contactGroupWithContactAssoc.PRM_Contact_Id__c;
            messageContactSet.addAll(contactsMessageConcatenation.split(','));
        }
        for(String messageContact : messageContactSet){
            PRM_Message_log__c messageLog = new PRM_Message_log__c();
            messageLog.PRM_Message_Id__c = messageContact.split('-')[0];
            messageLog.PRM_Contact_Id__c = messageContact.split('-')[1];
            msgLogList.add(messageLog);
        }
        
        if(msgLogList.size()>0){
            upsertMessageLog(msgLogList);
        }
    }
    //US695552:Method to Upsert Message Log.
    private static void upsertMessageLog(List<PRM_Message_Log__c> messageLogList){
        Map<String,PRM_Message_Log__c> existingMessageLogMap =new Map<String,PRM_Message_Log__c>();//Map of Existing Message Log  
        List<PRM_Message_Log__c> upsertMessageLogList =new List<PRM_Message_Log__c>();//List to upsert Message Log
        for(PRM_Message_Log__c msgLog:[Select Id, PRM_Message_Id__c,PRM_Contact_Id__c from PRM_Message_Log__c]){
            String key=(String)msgLog.PRM_Message_Id__c+(String)msgLog.PRM_Contact_Id__c;
            existingMessageLogMap.put(key,msglog);                
        }
        for(PRM_Message_Log__c newMsgLog :messageLogList){
            String key=(String)newMsgLog.PRM_Message_Id__c+(String)newMsgLog.PRM_Contact_Id__c;
            if(existingMessageLogMap.containsKey(key)){//for updating existing record.
                newMsgLog.Id = existingMessageLogMap.get(Key).Id;
                upsertMessageLogList.add(newMsgLog);
            }
            else {//for creating new record
                upsertMessageLogList.add(newMsgLog);
            }
        }
        if(!upsertMessageLogList.isEmpty()){
            PRM_SendNotificationMessages.upsertMessageLog(upsertMessageLogList);//calling Notification Utility class method for Upsert
        }   
    }
}