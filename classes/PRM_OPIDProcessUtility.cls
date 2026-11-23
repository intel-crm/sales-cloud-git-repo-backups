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
        //String errMsg = null;
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
        //String errMsg = null;
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
        //String errMsg = null;
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
        //String errMsg = null;
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
        //String errMsg = null;
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
        //String errMsg = null;
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

    //NJ AIA Start
    /**
        *  @description      : capture failure in Upsert operation of IPA Affiliations
        *  @name             : getErrorMessageForAIAupsert
        *  @param            : List<PRM_IPA_Affiliation__c> listOfobject, Database.UpsertResult[] saveresult
        *  @throws exception : NONE
        * @userstory         : TWC729-7521 
    **/
    public static Map<String,String> getErrorMessageForAIAupsert(List<PRM_IPA_Affiliation__c> listOfobject, Database.UpsertResult[] saveresult){
        //String errMsg = null;
        Integer recordid = 0;
        Map<String,String> mapofError = new Map<String,String>();
        for(Database.UpsertResult sr : saveresult) {
            if (!sr.isSuccess()) {
                mapofError.put(listOfobject[recordid].PRM_Account__c,sr.getErrors()[0].getMessage());
            }
            recordid++;
        }
        return mapofError;
    }
    //NJ AIA end
    /*
    public static Set<String> getSetOfAsscoiatedSFID(List<Core_Account_Group_Member__c> listOfObj){
        Set<String> setOfIDs = new Set<String>();
        if(listOfObj != null && listOfObj.size() >0){
            for(Core_Account_Group_Member__c obj : listOfObj){
                setOfIDs.add(obj.Core_Intel_Account_Id__c);
            }
        }
        return setOfIDs;
    }
    */
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
            //system.debug('Core_SalesCloud_AccountID__c >> '+sfAccid);
            if(mapOfACMObj.containsKey(sfAccid)){
                inboundMessage.Error_Description__c = mapOfACMObj.get(sfAccid);
            }
        }
        // System.debug(' listOfInboundMessage : '+listOfInboundMessage);
        // system.debug('Log 1--'+listOfInboundMessage[0].Core_Effective_End_Date_Time__c);
        // system.debug('Log 2--'+listOfInboundMessage[0].Core_PrimeID__c);
        // system.debug('Log 3--'+listOfInboundMessage[0].Core_SalesCloud_AccountID__c);
        update listOfInboundMessage;
    }
    
    
    public static Map<String,String> getErrorMessageForCAGUpsert(List<Core_Account_Group_Member__c> listOfobject, Database.UpsertResult[] saveresult){
        //String errMsg = null;
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
        //String errMsg = null;
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
        //String errMsg = null;
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
    /**
        *  @description      : fetch non ipa accounts for wich inbounds need to get created for association to Opid account
        *  @name             : OpidAssociationForNonIpaIntelAccount
        *  @param            : List<Id> approvedAqrRecords
        *  @throws exception : NONE
        * @userstory         : TWC729-6912 
    **/
    @InvocableMethod(Label = 'Associate to OPID')
    public static void OpidAssociationForNonIpaIntelAccount(List<Id> approvedAqrRecords){
        Set<String> parentUcdSet = new Set<String>();
        Map<String,account> ucdNonGlblAccMap = new Map<String,account>();
        Map<String,Core_Account_Group_Member__c> parentCagRec = new Map<String,Core_Account_Group_Member__c>();
        List<Core_OnePartner_Inbound_Message__c> listOfInboundOnePartner = new List<Core_OnePartner_Inbound_Message__c>();
        Map<Id,PRM_AccountChannelMembership__c> AcmWithOPIDCheckMap = new Map<Id,PRM_AccountChannelMembership__c>();
        Map<String,Account_Create_Request__c> approvedAqr = new Map<String,Account_Create_Request__c>();
        Set<String> noIpaAccountIds = new Set<String>();
        String errorLogMsg='';
        try{
            errorLogMsg+='***OpidAssociationForNonIpaIntelAccount***';
            errorLogMsg+='\napprovedAqrRecords : '+approvedAqrRecords;
            List<Account_Create_Request__c> aqrList = [Select id,Requested_Account__r.Core_Unified_Global_Customer_BP_Id__c, Requested_Account__r.Core_Business_Party_Id__c, Requested_Account__r.Core_Parent_Business_Party_Id__c,Requested_Account__r.Core_Customer_Aggregation_Type__c, (select id from New_Registrations__r) from Account_Create_Request__c where id in : approvedAqrRecords];
            for(Account_Create_Request__c aqr : aqrList){
                if(aqr.New_Registrations__r.size() == 0 && aqr.Requested_Account__r.Core_Parent_Business_Party_Id__c!=null){
                    parentUcdSet.add(aqr.Requested_Account__r.Core_Parent_Business_Party_Id__c);
                    ucdNonGlblAccMap.put(aqr.Requested_Account__r.Core_Business_Party_Id__c,aqr.Requested_Account__r);
                    noIpaAccountIds.add(aqr.Requested_Account__r.Core_Unified_Global_Customer_BP_Id__c);
                }
            }
            if(parentUcdSet!=null){
                for(Core_Account_Group_Member__c agm :[SELECT Id,
                                                                Name,
                                                                Core_Partner_Account_Id__c,
                                                                Core_Intel_Account_Id__c,
                                                                Core_Business_Party_Id__c,
                                                                Core_Partner_Account_Id__r.Core_OnePartnerID__c,
                                                                Core_Partner_Account_Id__r.Name,
                                                                Core_Inactive_Ind__c
                                                                FROM Core_Account_Group_Member__c 
                                                                WHERE (Core_Business_Party_Id__c in :parentUcdSet and Core_Inactive_Ind__c = false)]){
                    if(parentUcdSet.contains(agm.Core_Business_Party_Id__c)){
                        parentCagRec.put(agm.Core_Business_Party_Id__c,agm);
                    }
                }
            }
            errorLogMsg+='\nucdNonGlblAccMap : '+ucdNonGlblAccMap;
            errorLogMsg+='\nparentCagRec : '+parentCagRec;
            if(!ucdNonGlblAccMap.isEmpty() && !noIpaAccountIds.isEmpty()){
                errorLogMsg+='***CreateInboundRecord***';
                PRM_ACMTriggerHandlerNew.CreateInboundRecord(parentCagRec,ucdNonGlblAccMap,listOfInboundOnePartner,AcmWithOPIDCheckMap,noIpaAccountIds); 
            }
        }catch(Exception ex){
            errorLogMsg+= ex.getMessage();
        }
        finally{
            Core_Log_Entry.logEntryWithDetails('PRM_OPIDProcessutility', 'IPA','PRM_OPIDProcessutility','Medium','Non IPA inbound creation method ',errorLogMsg ,'', '', '');
        }
    }
    //TWC729-6912 : non ipa inbound End
    /**
        *  @description      : Consolidates the list of accounts successfully associated to an OPID for Success email
        *  @name             : opidAssociationEmail
        *  @param            : List<String> intelAccountIds,List<Core_OnePartner_Inbound_Message__c> inbndMsgList
        *  @throws exception : NONE
        * @userstory         : TWC729-7132
    **/
    public static String opidAssociationEmail(List<String> intelAccountIds,List<Core_OnePartner_Inbound_Message__c> inbndMsgList,Map<id,Core_Account_Group_Member__c> cagsToUpsertMap){
        String sfdcBaseURL = URL.getOrgDomainURL().toExternalForm();
        String automatedAccountNamesString = '';
        String lobAccountNamesString = '';
        String emailIds='';
        String errorLogMsg='';
        try{
            errorLogMsg+='***opidAssociationEmail***';
            Map<String,String> automationPlaceholderMap=new Map<String,String>();
            Map<String,String> lobPlaceholderMap=new Map<String,String>();
            Map<String,String> automationprocessedAccountIds = new Map<String,String>();
            Map<String,String> lobprocessedAccountIds = new Map<String,String>();
            //failed scenario:
            set<string> successAccIds=new set<string>();
            set<string> delinkAccIds=new set<string>();
            Map<String,String> SuccessMapOfAccIdWithName = new Map<String,String>();
            Map<String,String> delinkMapOfAccIdWithName = new Map<String,String>();
            string successAccIdString = '';
            string delinkAccIdString = ''; 
            if(!inbndMsgList.isEmpty() && !intelAccountIds.isEmpty()){
                for(Core_OnePartner_Inbound_Message__c inbMsg : inbndMsgList){
                    if(inbMsg.Core_Status_Effective_End_Date_Time__c==null && inbMsg.Core_Effective_End_Date_Time__c == null && inbMsg.Core_Status__c == System.Label.PRM_INBOUNDMSG_PROCESSED && cagsToUpsertMap.containskey(inbMsg.Core_SalesCloud_AccountID__c)){
                        if(cagsToUpsertMap.get(inbMsg.Core_SalesCloud_AccountID__c).Delink_Association_User__c==null){
                            automationprocessedAccountIds.put(cagsToUpsertMap.get(inbMsg.Core_SalesCloud_AccountID__c).Core_Partner_Account_Id__c,inbMsg.Core_OnePartner_Account_Name__c);
                        }else{
                            lobprocessedAccountIds.put(cagsToUpsertMap.get(inbMsg.Core_SalesCloud_AccountID__c).Core_Partner_Account_Id__c,inbMsg.Core_OnePartner_Account_Name__c);
                        }
                    }
                   //for delinking and association failed records:
                   if(inbMsg.Core_Status_Effective_End_Date_Time__c==null && inbMsg.Core_Effective_End_Date_Time__c == null 
                   && inbMsg.Core_Status__c != System.Label.PRM_INBOUNDMSG_PROCESSED && intelAccountIds.contains(inbMsg.Core_SalesCloud_AccountID__c)){
                       successAccIds.add(inbMsg.Core_SalesCloud_AccountID__c);
                   }
                   if((inbMsg.Core_Status_Effective_End_Date_Time__c!=null || inbMsg.Core_Effective_End_Date_Time__c != null ) 
                   && inbMsg.Core_Status__c != System.Label.PRM_INBOUNDMSG_PROCESSED && intelAccountIds.contains(inbMsg.Core_SalesCloud_AccountID__c)){
                       delinkAccIds.add(inbMsg.Core_SalesCloud_AccountID__c);
                    }
                }
            }
            if(!automationprocessedAccountIds.isEmpty()){
                for(String str : automationprocessedAccountIds.keySet()){
                    automatedAccountNamesString = automatedAccountNamesString + '<a href='+sfdcBaseURL+'/' +str+'>'+automationprocessedAccountIds.get(str) +'</a>'+ '<br/>';
                }
            }
            errorLogMsg+='***automatedAccountNamesString : '+automatedAccountNamesString;
            if(!lobprocessedAccountIds.isEmpty()){
                for(String str : lobprocessedAccountIds.keySet()){
                    lobAccountNamesString = lobAccountNamesString + '<a href='+sfdcBaseURL+'/' +str+'>'+lobprocessedAccountIds.get(str) +'</a>'+ '<br/>';
                }
            }
            errorLogMsg+='***lobAccountNamesString : '+lobAccountNamesString;
            if(!String.isBlank(automatedAccountNamesString)){
                automationPlaceholderMap.put('%AccountNames%',automatedAccountNamesString);
                String businessEvent = 'OPID_Creation_Email';
                callSendEmailUtil(automationPlaceholderMap,businessEvent);
            }
            if(!String.isBlank(lobAccountNamesString)){
                lobPlaceholderMap.put('%AccountNames%',lobAccountNamesString);
                String lobBusinessEvent = 'OPID_Creation_Email_LOB';
                callSendEmailUtil(lobPlaceholderMap,lobBusinessEvent);
            }
            //for failure scenario:
            if((!successAccIds.isEmpty() && successAccIds!=null) || (!delinkAccIds.isEmpty() && delinkAccIds!=null)){
                for(account str :[select id,name from account where id in:successAccIds or id in:delinkAccIds] ){
                    if(successAccIds.contains(str.id))
                    SuccessMapOfAccIdWithName.put(str.id,str.name);
                    else if(delinkAccIds.contains(str.id))
                    delinkMapOfAccIdWithName.put(str.id,str.name);
                }
            }

            errorLogMsg+='***successAccIdString : '+successAccIdString;
           
            if(!SuccessMapOfAccIdWithName.isEmpty()){
                for(String str : SuccessMapOfAccIdWithName.keySet()){
                    successAccIdString = successAccIdString + '<a href='+sfdcBaseURL+'/' +str+'>'+SuccessMapOfAccIdWithName.get(str) +'</a>'+ '<br/>';
                }
            }

            if(!delinkMapOfAccIdWithName.isEmpty()){
                for(String str : delinkMapOfAccIdWithName.keySet()){
                    delinkAccIdString = delinkAccIdString + '<a href='+sfdcBaseURL+'/' +str+'>'+delinkMapOfAccIdWithName.get(str) +'</a>'+ '<br/>';
                }
            }
            errorLogMsg+='***delinkAccIdString : '+delinkAccIdString;
            if(!String.isBlank(successAccIdString)){
                lobPlaceholderMap.put('%AccountList%',successAccIdString);
                lobPlaceholderMap.put('%Process%','association');
                String lobBusinessEvent = 'OPID_AssociationFailure_Email';
                callSendEmailUtil(lobPlaceholderMap,lobBusinessEvent);
                // string joblink='associate to the';
                // OPID_AssociationFailure_Email
                // sendEmail('OPIDLINKDELINK_FAILURE_NOTIFICATION',successAccIdString,joblink,'OPID Failed to Associate');
                
            }
            if(!String.isBlank(delinkAccIdString)){
                lobPlaceholderMap.put('%AccountList%',delinkAccIdString);
                lobPlaceholderMap.put('%Process%','delinking');
                String lobBusinessEvent = 'OPID_DelinkingFailure_Email';
                callSendEmailUtil(lobPlaceholderMap,lobBusinessEvent);
                // string joblink='delink from the';
                
                // sendEmail('OPIDLINKDELINK_FAILURE_NOTIFICATION',delinkAccIdString,joblink,'OPID Failed to Delink');
            }
            
        }catch(Exception e){
            errorLogMsg+='***'+e;
        }
        return errorLogMsg;
    }
    public static void callSendEmailUtil(Map<String,String> placeholderMap,String businessEvent){
        try{
            List<PRM_EmailUtility.EmailNotification> emailList = new List<PRM_EmailUtility.EmailNotification>();
            PRM_EmailUtility.EmailNotification email = new PRM_EmailUtility.EmailNotification();
            email.businessEvent = businessEvent;
            emailList.add(email);
            PRM_EmailUtility.customPlaceholdersMap = placeHolderMap;
            PRM_EmailUtility.sendEmailUtil(emailList);
        }catch(Exception ex){
            System.debug('@NJ Exception in emailUtil :'+ex);
        }
    }

}