/****************************************************************************************************************************
Apex Class Name     : PRM_SendNotificationMessages 
Version             : 1.0
Created Date        : 18 June 2020

Modification Log    :
* Developer             Date                    Description
* ------------------------------------------------------------------------------------------------------------------------------
* Bharath Kumar       18 June 2020          Reusable Apex class to Send Notifications Messages to Contacts on different contexts

***********************************************************************************************************************^^^^^*****/
public without sharing class PRM_SendNotificationMessages {
    
    public static final String STATUS_COMPLETE = 'Complete';
    public static final String STATUS_APPROVED = 'Approved';
    
    @InvocableMethod(label='Send Notifications Messages')
    public static void sendNotifications(MessageWrapper[] msgWrap){
        Id accId = null;
        String messageCd = '';
        String benefitName = '';
        List<Id> intelAccIdsList = new List<Id>();
        List<String> benefitMatrixList = new List<String>();
        List<Id> intelAccACMsMatchedwithBenefitMatrixData = new List<Id>();
        System.debug('Inside Process builder');
        //nn:  Bharath to remove the hardcoding
        Id opidAccRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(System.label.PRM_Partner_Account_Group_Record_Type).getRecordTypeId();
        for(MessageWrapper msg:msgWrap){
            accId = msg.accountId;
            messageCd = msg.msgCd;
        }
        System.debug('From Process builder Ids:'+accId);
        System.debug('Message Code: '+messageCd);
        //If the Account is OPID Account querying on PAGM to get the location accounts
        Id recTypeId = [select RecordTypeId from Account where id =: accId ].RecordTypeId;
        if(messageCd == System.label.PRM_Msgcd_Store_Front || messageCd == System.label.PRM_Msgcd_Market || recTypeId == opidAccRecTypeId){
            for (Core_Account_Group_Member__c cagm:[Select Id,Name,Core_Partner_Account_Id__c, Core_Intel_Account_Id__c From Core_Account_Group_Member__c Where Core_Partner_Account_Id__c = :accId AND Core_Intel_Account_Id__r.Core_Intel_Partner_Alliance_PartnerGroup__c = true and Core_Inactive_Ind__c = false]){
                intelAccIdsList.add(cagm.Core_Intel_Account_Id__c);
            }
            System.debug('PB Location Acc Size: '+intelAccIdsList.size());
            if(messageCd == System.label.PRM_Msgcd_Store_Front){
                benefitName = System.label.PRM_Solutions_Marketplace_Enhanced;
            }else if(messageCd == System.label.PRM_Msgcd_Market){
                benefitName = System.label.PRM_Solutions_Marketplace_Basic_Profile;
            }
            System.debug('Benefit Name: '+benefitName);
            if(benefitName != null && benefitName != ''){
                for(PRM_VXBnftMatrix__c bm:[Select PRM_Partner_Benefit_Id__r.Name, PRM_Partner_Role_Nm__c, PRM_Channel_Program_Level_Id__r.Name, PRM_IsActive_Ind__c from PRM_VXBnftMatrix__c where PRM_Partner_Benefit_Id__r.Name =:benefitName and PRM_IsActive_Ind__c = true ]){
                    String benefitCombination = bm.PRM_Partner_Role_Nm__c+','+bm.PRM_Channel_Program_Level_Id__r.Name;
                    if(benefitCombination != null && !benefitMatrixList.contains(benefitCombination)){
                        benefitMatrixList.add(benefitCombination);
                    }
                }
                System.debug('Benefit Matrix List: '+benefitMatrixList);
                if(!benefitMatrixList.isEmpty() && benefitMatrixList.size() > 0 && !intelAccIdsList.isEmpty()){
                    for(PRM_AccountChannelMembership__c acm:[Select name,PRM_Account_Id__c, PRM_Channel_Program_Level_Id__r.Name, PRM_Partner_Role__c, PRM_Status_Nm__c from PRM_AccountChannelMembership__c where PRM_Account_Id__c IN :intelAccIdsList and PRM_Status_Nm__c = :STATUS_APPROVED]){
                        String acmCombination = acm.PRM_Partner_Role__c+','+acm.PRM_Channel_Program_Level_Id__r.Name;
                        if(acmCombination != null && benefitMatrixList.contains(acmCombination) && !intelAccACMsMatchedwithBenefitMatrixData.contains(acm.PRM_Account_Id__c)){
                            intelAccACMsMatchedwithBenefitMatrixData.add(acm.PRM_Account_Id__c);
                        }
                    }
                }
                System.debug('Accs Matched with Benefit Matrix Data :'+intelAccACMsMatchedwithBenefitMatrixData);
            }
            if(intelAccACMsMatchedwithBenefitMatrixData != null && !intelAccACMsMatchedwithBenefitMatrixData.isEmpty()){
                upsertMsgLogRecs(intelAccACMsMatchedwithBenefitMatrixData,messageCd);
            }
        }else {
            intelAccIdsList.add(accId);
            upsertMsgLogRecs(intelAccIdsList,messageCd);
        }
    }
    //Method to fetch Contacts and upsert the message log records
    public static void upsertMsgLogRecs(List<Id> accIds,String messageCode){
        Set<Id> conIdsSet = new Set<Id>();
        Set<Id> toInsertLogRecConIdSet = new Set<Id>();
        Set<Id> entitlementRoles = new Set<Id>();
        Set<Id> existingLogRecodIdSet = new Set<Id>();
        PRM_Message__c msgRecord = new PRM_Message__c();
        PRM_Message__c emptyMsg = new PRM_Message__c();
        List<Contact> contactList = new List<Contact>();
        List<PRM_Message_log__c> upsertMsgLogList = new List<PRM_Message_log__c>();
        Id eventMsgRecTypeId  = Schema.SObjectType.PRM_Message__c.getRecordTypeInfosByDeveloperName().get(System.label.PRM_Event_RecordType).getRecordTypeId();
        if(messageCode == System.label.PRM_Msgcd_NewContact){//Different Query to accomodate the logic if the new ACR is inserted esclude the contact associated to it
            contactList = [Select Id,Name,AccountId from Contact where AccountId IN (Select PRM_Account_Id__c from PRM_Account_Contact_Relationship__c where PRM_Contact_Id__c IN :accIds) and Core_Do_Not_Contact__c=false and id Not IN :accIds];
        }else{
            contactList = [Select Id,Name,AccountId from Contact where AccountId IN:accIds and Core_Do_Not_Contact__c=false];
        }
        if(contactList != null && !contactList.isEmpty()){
            for(Contact con:contactList){
                conIdsSet.add(con.Id);
            }
            System.debug('Total Contact Ids =>'+conIdsSet);
            System.debug('Total Con Size after Query on Accounts: '+conIdsSet.size());
            for(PRM_Message__c msgObj:[Select Id,Name,PRM_Message_Cd__c,PRM_Title_Txt__c From PRM_Message__c where RecordTypeId =:eventMsgRecTypeId and PRM_Message_Cd__c =:messageCode and PRM_InActive_Ind__c=false LIMIT 1]){
                msgRecord = msgObj;
            }
            //msgRecord = [Select Id,Name,PRM_Message_Cd__c,PRM_Title_Txt__c From PRM_Message__c where RecordTypeId =:eventMsgRecTypeId and PRM_Message_Cd__c =:messageCode LIMIT 1];
            if(msgRecord != emptyMsg){
                List<PRM_Message_Entitlement_Association__c> meaRecords= [Select Id,PRM_Message_Id__c,PRM_Entitlement_Detail_Id__c from PRM_Message_Entitlement_Association__c where PRM_Message_Id__c = :msgRecord.Id];
                for(PRM_Message_Entitlement_Association__c roles:meaRecords){
                    entitlementRoles.add(roles.PRM_Entitlement_Detail_Id__c);
                }
                List<Core_Contact_Entitlement__c> contEntitlements = [Select Core_Contact_Id__c,Core_Entitlement_Id__c,Core_Status__c,Core_Selected__c from Core_Contact_Entitlement__c where Core_Contact_Id__c IN:conIdsSet];
                if(contEntitlements != null && !contEntitlements.isEmpty()){
                    for(Core_Contact_Entitlement__c ce:contEntitlements){
                        if(entitlementRoles.contains(ce.Core_Entitlement_Id__c) && ce.Core_Selected__c == true && ce.Core_Status__c == STATUS_COMPLETE){
                            toInsertLogRecConIdSet.add(ce.Core_Contact_Id__c);
                        }
                    }
                }
                if(toInsertLogRecConIdSet != null && !toInsertLogRecConIdSet.isEmpty()){
                    List<PRM_Message_log__c> msgLogRecs = [Select Id,PRM_Message_Id__c,PRM_Contact_Id__c,PRM_Inactive_Ind__c,PRM_Message_Viewed_Ind__c from PRM_Message_log__c where PRM_Contact_Id__c IN :toInsertLogRecConIdSet AND PRM_Message_Id__c = :msgRecord.Id];
                    if(!msgLogRecs.isEmpty() && msgLogRecs.size() > 0 ){
                        System.debug('Total Existing Log Rec Size=> '+msgLogRecs.size());
                        for(PRM_Message_log__c ml:[Select Id,PRM_Message_Id__c,PRM_Contact_Id__c,PRM_Inactive_Ind__c,PRM_Message_Viewed_Ind__c from PRM_Message_log__c where PRM_Contact_Id__c IN :toInsertLogRecConIdSet AND PRM_Message_Id__c = :msgRecord.Id]){
                            if(ml.PRM_Inactive_Ind__c == true || ml.PRM_Message_Viewed_Ind__c == true){
                                ml.PRM_Inactive_Ind__c = false;
                                ml.PRM_Message_Viewed_Ind__c = false;
                                upsertMsgLogList.add(ml);
                            }
                            existingLogRecodIdSet.add(ml.PRM_Contact_Id__c);
                        }
                        if(existingLogRecodIdSet.size() > 0){
                            toInsertLogRecConIdSet.removeAll(existingLogRecodIdSet);
                        }
                    }
                    if(toInsertLogRecConIdSet.size() > 0){
                        System.debug('Insert Log list Records: '+toInsertLogRecConIdSet);
                        for(Id conId:toInsertLogRecConIdSet){
                            PRM_Message_log__c msgLog = new PRM_Message_log__c();
                            msgLog.PRM_Contact_Id__c = conId;
                            msgLog.PRM_Message_Id__c = msgRecord.Id;
                            msgLog.PRM_Inactive_Ind__c = false;
                            upsertMsgLogList.add(msgLog);
                        }
                    }
                    if(!upsertMsgLogList.isEmpty()){
                        upsertMessageLog(upsertMsgLogList);
                    }   
                }
            }
        }
    }
    //Upsert method for both Event Type and Adhoc Type Message Log
    public static void upsertMessageLog(List<PRM_Message_Log__c> upsertMsgLogList){
        try {
            if(upsertMsgLogList !=null && !upsertMsgLogList.isEmpty()){
                Database.upsert(upsertMsgLogList,PRM_Message_Log__c.Fields.Id,false);
            }
        } catch (Exception e) {
            System.debug('Inside Catch => '+e.getMessage());
        }
    }
    public class MessageWrapper{
        @InvocableVariable(required=true)
        public String msgCd;
        @InvocableVariable(required=true)
        public Id accountId;
    }
}