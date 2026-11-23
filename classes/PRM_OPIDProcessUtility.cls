/****************************************************************************************************************************
Apex Class Name     : PRM_OPIDProcessUtility 
Version             : 1.0
Created Date        : Dec 2018
Function            : Utility for all common funcationality for OPID related changes

Modification Log    :
* Developer                 Date                    Description
* --------------------------------------------------------------------------------------------------------------------------
* Prasant Sahu      24-Jun-2020                   Utility for all common funcationality for OPID related changes
****************************************************************************************************************************/


public without sharing class PRM_OPIDProcessUtility {
    public static Map<String,String> getErrorMessageForOPID(List<Account> listOfobject, Database.UpsertResult[] saveresult){
        String errMsg = null;
        Integer recordid = 0;
        Map<String,String> mapofError = new Map<String,String>();
        for(Database.UpsertResult sr : saveresult) {
            if (!sr.isSuccess()) {
                mapofError.put(listOfobject[recordid].Core_OnePartnerID__c,sr.getErrors()[0].getMessage());
            }
            recordid++;
        }
        return mapofError;
    }
    
    
    public static Map<String,String> getErrorMessageForCAG(List<Core_Account_Group_Member__c> listOfobject, Database.SaveResult[] saveresult){
        String errMsg = null;
        Integer recordid = 0;
        
        Map<String,String> mapofError = new Map<String,String>();
        for(Database.SaveResult sr : saveresult) {
            if (!sr.isSuccess()) {
                mapofError.put(listOfobject[recordid].Core_Intel_Account_Id__c,sr.getErrors()[0].getMessage());
            }
            
            
            recordid++;
        }
        return mapofError;
    }
    
    public static Map<String,String> getErrorMessageForASA(List<PRM_Account_Specialty_Association__c> listOfobject, Database.SaveResult[] saveresult){
        String errMsg = null;
        Integer recordid = 0;
        Map<String,String> mapofError = new Map<String,String>();
        for(Database.SaveResult sr : saveresult) {
            if (!SR.isSuccess()) {
                mapofError.put(listOfobject[recordid].PRM_Account_Id__c,sr.getErrors()[0].getMessage());
            }
            recordid++;
        }
        return mapofError;
    }
    
    public static Map<String,String> getErrorMessageForACM(List<PRM_AccountChannelMembership__c> listOfobject, Database.SaveResult[] saveresult){
        String errMsg = null;
        Integer recordid = 0;
        Map<String,String> mapofError = new Map<String,String>();
        for(Database.SaveResult sr : saveresult) {
            if (!sr.isSuccess()) {
                mapofError.put(listOfobject[recordid].PRM_Account_Id__c,sr.getErrors()[0].getMessage());
            }
            recordid++;
        }
        return mapofError;
    }
    
    public static Map<String,String> getErrorMessageForACMupsert(List<PRM_AccountChannelMembership__c> listOfobject, Database.UpsertResult[] saveresult){
        String errMsg = null;
        Integer recordid = 0;
        Map<String,String> mapofError = new Map<String,String>();
        for(Database.UpsertResult sr : saveresult) {
            if (!sr.isSuccess()) {
                mapofError.put(listOfobject[recordid].PRM_Account_Id__c,sr.getErrors()[0].getMessage());
            }
            recordid++;
        }
        return mapofError;
    }
    
    
    public static Map<String,String> getErrorMessageForASAupsert(List<PRM_Account_Specialty_Association__c> listOfobject, Database.UpsertResult[] saveresult){
        String errMsg = null;
        Integer recordid = 0;
        Map<String,String> mapofError = new Map<String,String>();
        for(Database.UpsertResult sr : saveresult) {
            if (!sr.isSuccess()) {
                mapofError.put(listOfobject[recordid].PRM_Account_Id__c,sr.getErrors()[0].getMessage());
            }
            recordid++;
        }
        return mapofError;
    }
    public static Set<String> getSetOfAsscoiatedSFID(List<Core_Account_Group_Member__c> listOfObj){
        Set<String> setOfIDs = new Set<String>();
        if(listOfObj != null && listOfObj.size() >0){
            for(Core_Account_Group_Member__c obj : listOfObj){
                setOfIDs.add(obj.Core_Intel_Account_Id__c);
            }
        }
        return setOfIDs;
    }
    
    public static String acmUpdateStatusMessage(String existingBadge, String updatedBadge){
        String statusMessage = null;
        if(existingBadge != null && updatedBadge != null){                    
            statusMessage = System.Label.PRM_ACM_UPDATE; 
            /*   if(statusMessage.contains('{OldTier}')){
statusMessage = statusMessage.replace('{OldTier}', existingBadge);
} */
            
            if(statusMessage.contains('{UpdateTier}')){
                statusMessage = statusMessage.replace('{UpdateTier}', updatedBadge);
            }
        }
        return statusMessage;
    }
    
    public static void updateErrorDetailsAtInboundTable(Map<String,String> mapOfACMObj){
        List<Core_OnePartner_Inbound_Message__c> listOfInboundMessage = [Select id,Core_Status__c,Core_CIM_ID__c,Core_OnePartnerID__c,Core_SalesCloud_AccountID__c,Core_PrimeID__c, Error_Description__c, Core_OnePartner_Account_Name__c, Core_Effective_End_Date_Time__c from Core_OnePartner_Inbound_Message__c where Core_Status__c = 'LOAD COMPLETE' and Core_SalesCloud_AccountID__c in :mapOfACMObj.keySet()];
        for(Core_OnePartner_Inbound_Message__c inboundMessage : listOfInboundMessage){
            String sfAccid = inboundMessage.Core_SalesCloud_AccountID__c;
            system.debug('Core_SalesCloud_AccountID__c >> '+sfAccid);
            if(mapOfACMObj.containsKey(sfAccid)){
                inboundMessage.Error_Description__c = mapOfACMObj.get(sfAccid);
            }
        }
        System.debug(' listOfInboundMessage : '+listOfInboundMessage);
        update listOfInboundMessage;
    }
    
    
    public static Map<String,String> getErrorMessageForCAGUpsert(List<Core_Account_Group_Member__c> listOfobject, Database.UpsertResult[] saveresult){
        String errMsg = null;
        Integer recordid = 0;
        Map<String,String> mapofError = new Map<String,String>();
        for(Database.UpsertResult sr : saveresult) {
            if (!sr.isSuccess()) {
                mapofError.put(listOfobject[recordid].Core_Intel_Account_Id__c,sr.getErrors()[0].getMessage());
            }
            recordid++;
        }
        return mapofError;
    }
    
    public static Map<String,String> getErrorMessageForABA(List<PRM_AccountBenefitAssociation__c> listOfobject, Database.SaveResult[] saveresult){
        String errMsg = null;
        Integer recordid = 0;
        Map<String,String> mapofError = new Map<String,String>();
        for(Database.SaveResult sr : saveresult) {
            if (!sr.isSuccess()) {
                mapofError.put(listOfobject[recordid].PRM_Account_Id__c,sr.getErrors()[0].getMessage());
            }
            recordid++;
        }
        return mapofError;
    } 
    
    public static Map<String,String> getErrorMessageForInboundMsgupsert(List<Core_OnePartner_Inbound_Message__c> listOfobject, Database.UpsertResult[] saveresult){
        String errMsg = null;
        Integer recordid = 0;
        Map<String,String> mapofError = new Map<String,String>();
        for(Database.UpsertResult sr : saveresult) {
            if (!sr.isSuccess()) {
                mapofError.put(listOfobject[recordid].Core_SalesCloud_AccountID__c,sr.getErrors()[0].getMessage());
            }
            recordid++;
        }
        return mapofError;
    }
    
    public static String updateABAErrorsInBoundTable(Map<String,String> abaMapError,Map<String,Core_OnePartner_Inbound_Message__c> opidAcc){
        System.debug('Update inbound ABA Error ..');
        System.debug('abaMapError ..'+abaMapError);
        System.debug('opidAcc ..'+opidAcc);
        String logEntryMsg='';
        List<Core_OnePartner_Inbound_Message__c> listOfInbound = new List<Core_OnePartner_Inbound_Message__c>(); 
        for(String accId : opidAcc.keySet()){
            if(abaMapError.containsKey(accId)){
                String msg = abaMapError.get(accId);
                Core_OnePartner_Inbound_Message__c inMsg = opidAcc.get(accId);
                inMsg.Core_Status__c = System.Label.PRM_POST_PROCESSING_FAILED;
                inMsg.Error_Description__c=msg;
                listOfInbound.add(inMsg);
            }
        }
        System.debug('listOfInbound >> '+listOfInbound);
        if(!listOfInbound.isEmpty()){
            
            List<Database.SaveResult> listOfInboundUpdateResult=new List<Database.SaveResult>();
            listOfInboundUpdateResult = Database.Update(listOfInbound,false);
            logEntryMsg+=PRM_ProcessInboundOPIDLogEntriesUtility.processDatabaseSaveResult(listOfInbound, listOfInboundUpdateResult,'Core_OnePartner_Inbound_Message__c');
            
            //update listOfInbound;
        }
        return logEntryMsg;
    }
}