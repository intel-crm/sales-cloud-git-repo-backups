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
        //nn:  Bharath to remove the hardcoding
        Id opidAccRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(System.label.PRM_Partner_Account_Group_Record_Type).getRecordTypeId();
        for(MessageWrapper msg:msgWrap){
            accId = msg.accountId;
            messageCd = msg.msgCd;
        }
        //If the Account is OPID Account querying on PAGM to get the location accounts
        Id recTypeId = [select RecordTypeId from Account where id =: accId ].RecordTypeId;
        if(messageCd == System.label.PRM_Msgcd_Store_Front || messageCd == System.label.PRM_Msgcd_Market || recTypeId == opidAccRecTypeId){
            for (Core_Account_Group_Member__c cagm:[Select Id,Name,Core_Partner_Account_Id__c, Core_Intel_Account_Id__c From Core_Account_Group_Member__c Where Core_Partner_Account_Id__c = :accId AND Core_Intel_Account_Id__r.Core_Intel_Partner_Alliance_PartnerGroup__c = true and Core_Inactive_Ind__c = false]){
                intelAccIdsList.add(cagm.Core_Intel_Account_Id__c);
            }
            if(messageCd == System.label.PRM_Msgcd_Store_Front){
                benefitName = System.label.PRM_Solutions_Marketplace_Enhanced;
            }else if(messageCd == System.label.PRM_Msgcd_Market){
                benefitName = System.label.PRM_Solutions_Marketplace_Basic_Profile;
            }
            if(benefitName != null && benefitName != ''){
                for(PRM_VXBnftMatrix__c bm:[Select PRM_Partner_Benefit_Id__r.Name, PRM_Partner_Role_Nm__c, PRM_Channel_Program_Level_Id__r.Name, PRM_IsActive_Ind__c from PRM_VXBnftMatrix__c where PRM_Partner_Benefit_Id__r.Name =:benefitName and PRM_IsActive_Ind__c = true ]){
                    String benefitCombination = bm.PRM_Partner_Role_Nm__c+','+bm.PRM_Channel_Program_Level_Id__r.Name;
                    if(benefitCombination != null && !benefitMatrixList.contains(benefitCombination)){
                        benefitMatrixList.add(benefitCombination);
                    }
                }
                if(!benefitMatrixList.isEmpty() && benefitMatrixList.size() > 0 && !intelAccIdsList.isEmpty()){
                    for(PRM_AccountChannelMembership__c acm:[Select name,PRM_Account_Id__c, PRM_Channel_Program_Level_Id__r.Name, PRM_Partner_Role__c, PRM_Status_Nm__c from PRM_AccountChannelMembership__c where PRM_Account_Id__c IN :intelAccIdsList and PRM_Status_Nm__c = :STATUS_APPROVED]){
                        String acmCombination = acm.PRM_Partner_Role__c+','+acm.PRM_Channel_Program_Level_Id__r.Name;
                        if(acmCombination != null && benefitMatrixList.contains(acmCombination) && !intelAccACMsMatchedwithBenefitMatrixData.contains(acm.PRM_Account_Id__c)){
                            intelAccACMsMatchedwithBenefitMatrixData.add(acm.PRM_Account_Id__c);
                        }
                    }
                }
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
        /*if(PRM_ACRNotificationMessage.MsgForLogEntry!=null){        
            PRM_ACRNotificationMessage.MsgForLogEntry+='\n*** Entered upsertMsgLogRecs Method *** \n';
        }else{
            PRM_ACRNotificationMessage.MsgForLogEntry='\n*** Entered upsertMsgLogRecs Method *** \n';
        }*/
        PRM_ACRNotificationMessage.MsgForLogEntry = PRM_ACRNotificationMessage.MsgForLogEntry != null ?
        PRM_ACRNotificationMessage.MsgForLogEntry + '\n*** Entered upsertMsgLogRecs Method *** \n' : '\n*** Entered upsertMsgLogRecs Method *** \n';
        try{
            Id eventMsgRecTypeId  = Schema.SObjectType.PRM_Message__c.getRecordTypeInfosByDeveloperName().get(System.label.PRM_Event_RecordType).getRecordTypeId();
            PRM_ACRNotificationMessage.MsgForLogEntry+='\n*** Contact Query Starts ***';
            /*if(messageCode == System.label.PRM_Msgcd_NewContact){//Different Query to accomodate the logic if the new ACR is inserted esclude the contact associated to it
                contactList = [Select Id,Name,AccountId from Contact where AccountId IN (Select PRM_Account_Id__c from PRM_Account_Contact_Relationship__c where PRM_Contact_Id__c IN :accIds and PRM_Status_Nm__c='Complete' and PRM_InActive_Ind__c=false) and Core_Do_Not_Contact__c=false and id Not IN :accIds];
            }else{
                contactList = [Select Id,Name,AccountId from Contact where AccountId IN:accIds and Core_Do_Not_Contact__c=false];
            }*/
            contactList = (messageCode == System.label.PRM_Msgcd_NewContact) ? [SELECT Id, Name, AccountId FROM Contact WHERE AccountId IN (
            SELECT PRM_Account_Id__c FROM PRM_Account_Contact_Relationship__c WHERE PRM_Contact_Id__c IN :accIds AND PRM_Status_Nm__c = 'Complete' AND PRM_InActive_Ind__c = false)
            AND Core_Do_Not_Contact__c = false AND Id NOT IN :accIds] : [SELECT Id, Name, AccountId FROM Contact WHERE AccountId IN :accIds
            AND Core_Do_Not_Contact__c = false];
            //add Contact size
            if(contactList != null && !contactList.isEmpty()){
                for(Contact con:contactList){
                    conIdsSet.add(con.Id);
                }
                PRM_ACRNotificationMessage.MsgForLogEntry+='\n contactList size===> '+contactList.size();
                
                PRM_ACRNotificationMessage.MsgForLogEntry+='\n*** Contact Query Ends ***'+'\n';
                
                PRM_ACRNotificationMessage.MsgForLogEntry+='\n*** Message Query Starts***';
                for(PRM_Message__c msgObj:[Select Id,Name,PRM_Message_Cd__c,PRM_Title_Txt__c From PRM_Message__c where RecordTypeId =:eventMsgRecTypeId and PRM_Message_Cd__c =:messageCode and PRM_InActive_Ind__c=false LIMIT 1]){
                    msgRecord = msgObj;
                }
                if(msgRecord!=null)
                    PRM_ACRNotificationMessage.MsgForLogEntry+='\n msgRecord===> '+msgRecord.Id;
                    
                PRM_ACRNotificationMessage.MsgForLogEntry+='\n*** Message Query Ends ***'+'\n';
                
                
                PRM_ACRNotificationMessage.MsgForLogEntry+='\n*** Message Entitlement Association Query Starts ***';
                //msgRecord = [Select Id,Name,PRM_Message_Cd__c,PRM_Title_Txt__c From PRM_Message__c where RecordTypeId =:eventMsgRecTypeId and PRM_Message_Cd__c =:messageCode LIMIT 1];
                /*if(msgRecord != emptyMsg){
                    List<PRM_Message_Entitlement_Association__c> meaRecords= [Select Id,PRM_Message_Id__c,PRM_Entitlement_Detail_Id__c from PRM_Message_Entitlement_Association__c where PRM_Message_Id__c = :msgRecord.Id];
                    if(meaRecords.size()>0)
                    */
                List<PRM_Message_Entitlement_Association__c> meaRecords= [Select Id,PRM_Message_Id__c,PRM_Entitlement_Detail_Id__c from PRM_Message_Entitlement_Association__c where PRM_Message_Id__c = :msgRecord.Id];
                if(msgRecord != emptyMsg && meaRecords.size()>0){
                    PRM_ACRNotificationMessage.MsgForLogEntry+='\n Msg entitlement size===> '+ meaRecords.size();
                    PRM_ACRNotificationMessage.MsgForLogEntry+='\n*** Message Entitlement Association QueryEnds ***'+'\n';                    
                    
                    for(PRM_Message_Entitlement_Association__c roles:meaRecords){
                        entitlementRoles.add(roles.PRM_Entitlement_Detail_Id__c);
                    }
                    
                    PRM_ACRNotificationMessage.MsgForLogEntry+='\n*** Contact Entitlements Query Starts ***';                    
                    //List<Core_Contact_Entitlement__c> contEntitlements = [Select Core_Contact_Id__c,Core_Entitlement_Id__c,Core_Status__c,Core_Selected__c from Core_Contact_Entitlement__c where Core_Contact_Id__c IN:conIdsSet and Core_Status__c='Complete' and Core_Selected__c=true];
                    //if(contEntitlements != null && !contEntitlements.isEmpty()){
                    //    for(Core_Contact_Entitlement__c ce:contEntitlements){
                    List<Core_Contact_Entitlement__c> contEntitlements = new List<Core_Contact_Entitlement__c>();
                    for(Contact c:[Select id, (Select Core_Contact_Id__c,Core_Entitlement_Id__c,Core_Status__c,Core_Selected__c from Contact_Entitlements__r where Core_Status__c='Complete' and Core_Selected__c=true) from Contact where Id IN:conIdsSet]){
                    //for(Core_Contact_Entitlement__c ce:[Select Core_Contact_Id__c,Core_Entitlement_Id__c,Core_Status__c,Core_Selected__c from Core_Contact_Entitlement__c where Core_Contact_Id__c IN:conIdsSet and Core_Status__c='Complete' and Core_Selected__c=true]){
                        if(c.Contact_Entitlements__r != null && !c.Contact_Entitlements__r.isEmpty() ){
                          contEntitlements.addAll(c.Contact_Entitlements__r);
                        }
                    }
                    for(Core_Contact_Entitlement__c ce:contEntitlements){
                        if(entitlementRoles.contains(ce.Core_Entitlement_Id__c) && ce.Core_Selected__c == true && ce.Core_Status__c == STATUS_COMPLETE){
                            toInsertLogRecConIdSet.add(ce.Core_Contact_Id__c);
                        }                        
                    }
                    if(contEntitlements.size()>0)
                    PRM_ACRNotificationMessage.MsgForLogEntry+='\n Contact entitlement size===> '+ contEntitlements.size();
                    PRM_ACRNotificationMessage.MsgForLogEntry+='\n*** Contact Entitlements Query Ends ***\n'; 
                                       
                    PRM_ACRNotificationMessage.MsgForLogEntry+='\n*** Message Log Query Ends ***'+'\n';
                    PRM_ACRNotificationMessage.MsgForLogEntry+='\n*** Message Log Query Starts ***'; 
                    /*if(toInsertLogRecConIdSet != null && !toInsertLogRecConIdSet.isEmpty()){
                        system.debug('toInsertLogRecConIdSet:'+ toInsertLogRecConIdSet);
                        List<PRM_Message_log__c> msgLogRecs = [Select Id,PRM_Message_Id__c,PRM_Contact_Id__c,PRM_Inactive_Ind__c,PRM_Message_Viewed_Ind__c from PRM_Message_log__c where PRM_Contact_Id__c IN :toInsertLogRecConIdSet AND PRM_Message_Id__c = :msgRecord.Id];
                        system.debug('msgLogRecs:'+ msgLogRecs);
                        if(!msgLogRecs.isEmpty() && msgLogRecs.size() > 0 ){
                        */    
                    List<PRM_Message_log__c> msgLogRecs = [Select Id,PRM_Message_Id__c,PRM_Contact_Id__c,PRM_Inactive_Ind__c,PRM_Message_Viewed_Ind__c from PRM_Message_log__c where PRM_Contact_Id__c IN :toInsertLogRecConIdSet AND PRM_Message_Id__c = :msgRecord.Id];
                    if(toInsertLogRecConIdSet != null && !toInsertLogRecConIdSet.isEmpty() && !msgLogRecs.isEmpty() && msgLogRecs.size() > 0 ){
                        PRM_ACRNotificationMessage.MsgForLogEntry+='\n Msg Log Size size===> '+ msgLogRecs.size();
                        for(PRM_Message_log__c ml:msgLogRecs){
                            //if(ml.PRM_Inactive_Ind__c == true || ml.PRM_Message_Viewed_Ind__c == true){
                                ml.PRM_Inactive_Ind__c = false;
                                ml.PRM_Message_Viewed_Ind__c = false;
                                upsertMsgLogList.add(ml);
                            //}
                            existingLogRecodIdSet.add(ml.PRM_Contact_Id__c);
                        }
                        if(existingLogRecodIdSet.size() > 0){
                            toInsertLogRecConIdSet.removeAll(existingLogRecodIdSet);
                        }
                        
                        PRM_ACRNotificationMessage.MsgForLogEntry+='\n*** Message Log Query Ends ***'+'\n';
                        if(existingLogRecodIdSet.size()>0)
                            PRM_ACRNotificationMessage.MsgForLogEntry+='\n*** Size of Existing logrecords size==> '+existingLogRecodIdSet.size()+'\n'; 
                        if(toInsertLogRecConIdSet.size()>0)
                            PRM_ACRNotificationMessage.MsgForLogEntry+='\n*** Size of new logrecords size==> '+toInsertLogRecConIdSet.size()+'\n'; 
                        if(toInsertLogRecConIdSet.size() > 0){
                            for(Id conId:toInsertLogRecConIdSet){
                                PRM_Message_log__c msgLog = new PRM_Message_log__c();
                                msgLog.PRM_Contact_Id__c = conId;
                                msgLog.PRM_Message_Id__c = msgRecord.Id;
                                msgLog.PRM_Inactive_Ind__c = false;
                                upsertMsgLogList.add(msgLog);
                            }
                        }
                        if(!upsertMsgLogList.isEmpty()){
                            PRM_ACRNotificationMessage.MsgForLogEntry+='\n*** Final list size to insert msg Log==> '+toInsertLogRecConIdSet.size()+'\n'; 
                            upsertMessageLog(upsertMsgLogList);
                        }   
                    }
                }
            }
        }
        catch(exception e){
            Core_Log_Entry.logEntryWithDetails(PRM_ACRNotificationMessage.LOG_ENTRY_ORIGIN, PRM_ACRNotificationMessage.LOG_ENTRY_PROJECT, PRM_ACRNotificationMessage.LOG_ENTRY_SCOPE, PRM_ACRNotificationMessage.LOG_ENTRY_SEVERITY,'PRM_SendNotificationMessages.upsermsglogs Incoked at'+system.today() ,PRM_ACRNotificationMessage.MsgForLogEntry+e.getmessage()  , '', '', '');           

        }
        finally{
            Core_Log_Entry.logEntryWithDetails(PRM_ACRNotificationMessage.LOG_ENTRY_ORIGIN, PRM_ACRNotificationMessage.LOG_ENTRY_PROJECT, PRM_ACRNotificationMessage.LOG_ENTRY_SCOPE, PRM_ACRNotificationMessage.LOG_ENTRY_SEVERITY,'PRM_SendNotificationMessages.upsermsglogs Incoked at'+system.today() ,PRM_ACRNotificationMessage.MsgForLogEntry , '', '', '');
        }
        
    }
    //Upsert method for both Event Type and Adhoc Type Message Log
    public static void upsertMessageLog(List<PRM_Message_Log__c> upsertMsgLogList){
        try {
            if(upsertMsgLogList !=null && !upsertMsgLogList.isEmpty()){
                Database.upsert(upsertMsgLogList,PRM_Message_Log__c.Fields.Id,false);
            }
        } catch (Exception e) {
            Core_Log_Entry.logEntryWithDetails(PRM_ACRNotificationMessage.LOG_ENTRY_ORIGIN, PRM_ACRNotificationMessage.LOG_ENTRY_PROJECT, PRM_ACRNotificationMessage.LOG_ENTRY_SCOPE, PRM_ACRNotificationMessage.LOG_ENTRY_SEVERITY,'PRM_SendNotificationMessages.upsermsglogs Incoked at'+system.today() ,PRM_ACRNotificationMessage.MsgForLogEntry+e.getmessage()  , '', '', '');

        }
    }
    public class MessageWrapper{
        @InvocableVariable(required=true)
        public String msgCd;
        @InvocableVariable(required=true)
        public Id accountId;
    }
}