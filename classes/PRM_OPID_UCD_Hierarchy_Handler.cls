/****************************************************************************************************************************
Apex Class Name     : PRM_OPID_UCD_Hierarchy_Handler 
Version             : 1.0
Created Date        : Sept 2024
Function            : Handler for OPID Hierarchy changes when UCD Hierarchy change

Modification Log    :
* Developer                  Date                    Description
* --------------------------------------------------------------------------------------------------------------------------
* Nandana Jayachandran       18-Sept-2024            Handler for OPID Hierarchy changes when UCD Hierarchy change
****************************************************************************************************************************/
public with sharing class PRM_OPID_UCD_Hierarchy_Handler {
    /**
        *  @description      : Consolidates and processes the accounts for which UCD hierarchy has changed on the basis of Customer Aggregation Type
        *  @name             : processOpidUcdHierarchy
        *  @param            : List<ACM_Account_Change_Event__e> acmAccChangeEventList
        *  @throws exception : NONE
        * @userstory         : TWC729-7184
    **/
    public static String errorLogMsg =''; 
    public static void processOpidUcdHierarchy (List<ACM_Account_Change_Event__e> acmAccChangeEventList) {   
        List<String> accountIds = new List<String>();
        Map<String,Core_Account_group_Member__c> accountsWithActiveCagMap = new Map<String,Core_Account_group_Member__c>();
        List<ResponseData> responseList = new List<ResponseData>();
        Map<String,ResponseData> globalResponseMap = new Map<String,ResponseData>();
        Map<String,ResponseData> intmdResponseMap = new Map<String,ResponseData>();
        Map<String,ResponseData> cntryResponseMap = new Map<String,ResponseData>();
        Map<String,ResponseData> locResponseMap = new Map<String,ResponseData>();
        Map<String,ResponseData> primaryCountryResponseMap = new Map<String,ResponseData>();
        Map<String,ResponseData> primaryLocResponseMap = new Map<String,ResponseData>();
        List<Core_Account_Group_Member__c> activeCagList = new List<Core_Account_Group_Member__c>();
        Map<String,Core_OnePartner_Inbound_Message__c> mapOfDelinkingInbound = new Map<String,Core_OnePartner_Inbound_Message__c>();
        List<Core_OnePartner_Inbound_Message__c> listOfDelinkInbound = new List<Core_OnePartner_Inbound_Message__c>();
        Map<id,Core_OnePartner_Inbound_Message__c> inboundRecMap = new Map<id,Core_OnePartner_Inbound_Message__c>();
        List<Account> opidToUpdate = new List<Account>();
        
            try{
                errorLogMsg+= '***processOpidUcdHierarchy';
                for(ACM_Account_Change_Event__e event : acmAccChangeEventList){
                    if(event.Message__c != null){
                        ResponseData response = (ResponseData)System.JSON.deserialize(event.Message__c, ResponseData.class);
                        if(response.RecordType=='Intel Account'){
                            accountIds.add(response.AccountId);
                            responseList.add(response);
                        }
                    }
                }
                if(accountIds!=null && !accountIds.isEmpty()){
                    activeCagList=[Select Id,Name,Primary_Account__c,Core_Partner_Account_Id__c,Core_Partner_Account_Id__r.Core_OnePartnerID__c,Core_Partner_Account_Id__r.Name, Core_Intel_Account_Id__c, Core_Intel_Account_Id__r.Name,Core_Intel_Account_Id__r.Core_Unified_Global_Customer_Name__c,Core_Partner_Account_Id__r.Core_PAG_Grouping_Method__c,Core_Inactive_Ind__c From Core_Account_Group_Member__c Where Core_Intel_Account_Id__c IN :accountIds AND Core_Inactive_Ind__c = false];
                }
                if(activeCagList!=null && !activeCagList.isEmpty()){
                    for(Core_Account_Group_Member__c cag: activeCagList){
                        accountsWithActiveCagMap.put(cag.Core_Intel_Account_Id__c,cag);
                    }
                }
                if(responseList!=null && !responseList.isEmpty()){
                    for(ResponseData response: responseList){
                        if(accountsWithActiveCagMap.containsKey(response.AccountId)){
                            String aggregationType = response.CustomerAggregationType.Name;
                            Boolean primary = accountsWithActiveCagMap.get(response.AccountId).Primary_Account__c;
                            switch on aggregationType {
                                when 'Unified Global Customer' {
                                    if( !primary){
                                        globalResponseMap.put(response.AccountId,response);
                                    }//TWC729-7455 - hierarchy change enhancements
                                    else if(accountsWithActiveCagMap.get(response.AccountId).Core_Partner_Account_Id__r.Core_PAG_Grouping_Method__c!='GLBL'){
                                        accountsWithActiveCagMap.get(response.AccountId).Core_Partner_Account_Id__r.Name = accountsWithActiveCagMap.get(response.AccountId).Core_Intel_Account_Id__r.Core_Unified_Global_Customer_Name__c+'-Global';
                                        accountsWithActiveCagMap.get(response.AccountId).Core_Partner_Account_Id__r.Core_PAG_Grouping_Method__c='GLBL';
                                        opidToUpdate.add(accountsWithActiveCagMap.get(response.AccountId).Core_Partner_Account_Id__r);
                                    }
                                }
                                when 'Unified Intermediate Customer' {
                                    if(!primary){
                                        intmdResponseMap.put(response.AccountId,response);
                                    }//TWC729-7455 - hierarchy change enhancements
                                    else if(accountsWithActiveCagMap.get(response.AccountId).Core_Partner_Account_Id__r.Core_PAG_Grouping_Method__c!='LINEOFBUSNS'){
                                        accountsWithActiveCagMap.get(response.AccountId).Core_Partner_Account_Id__r.Name = accountsWithActiveCagMap.get(response.AccountId).Core_Intel_Account_Id__r.Core_Unified_Global_Customer_Name__c+'-'+accountsWithActiveCagMap.get(response.AccountId).Core_Intel_Account_Id__r.Name;
                                        accountsWithActiveCagMap.get(response.AccountId).Core_Partner_Account_Id__r.Core_PAG_Grouping_Method__c='LINEOFBUSNS';
                                        opidToUpdate.add(accountsWithActiveCagMap.get(response.AccountId).Core_Partner_Account_Id__r);
                                    }
                                }
                                when 'Unified Country Customer' {
                                    (primary ? primaryCountryResponseMap : cntryResponseMap).put(response.AccountId, response);
                                }
                                when 'Unified Location Customer' {
                                    (primary ? primaryLocResponseMap : locResponseMap).put(response.AccountId, response);
                                }
                            }
                        }
                    }
                }
                if(globalResponseMap!=null && !globalResponseMap.isEmpty()){
                    for(String accountId :globalResponseMap.keySet()){
                        Core_OnePartner_Inbound_Message__c inbound = new Core_OnePartner_Inbound_Message__c();
                        inbound=createDelinkInbound(accountsWithActiveCagMap.get(accountId).Core_Partner_Account_Id__r.Core_OnePartnerID__c,accountsWithActiveCagMap.get(accountId).Core_Partner_Account_Id__r.Name,globalResponseMap.get(accountId));
                        mapOfDelinkingInbound.put(inbound.Core_SalesCloud_AccountID__c,inbound);
                    }
                }
                if(intmdResponseMap!=null  && !intmdResponseMap.isEmpty()){
                    mapOfDelinkingInbound = checkParentChildOPID(intmdResponseMap,mapOfDelinkingInbound,accountsWithActiveCagMap);
                    mapOfDelinkingInbound = checkActiveParentDelinkInbnd(intmdResponseMap,mapOfDelinkingInbound,accountsWithActiveCagMap);
                }
                if(cntryResponseMap!=null  && !cntryResponseMap.isEmpty()){
                    mapOfDelinkingInbound = checkParentChildOPID(cntryResponseMap,mapOfDelinkingInbound,accountsWithActiveCagMap);
                    mapOfDelinkingInbound = checkActiveParentDelinkInbnd(cntryResponseMap,mapOfDelinkingInbound,accountsWithActiveCagMap);
                }
                //TWC729-7455 - hierarchy change enhancements
                if(primaryCountryResponseMap!=null && !primaryCountryResponseMap.isEmpty()){
                    mapOfDelinkingInbound = createDeactivateinbound(primaryCountryResponseMap,mapOfDelinkingInbound,accountsWithActiveCagMap);
                }
                if(locResponseMap!=null  && !locResponseMap.isEmpty()){
                    mapOfDelinkingInbound = checkParentChildOPID(locResponseMap,mapOfDelinkingInbound,accountsWithActiveCagMap);
                    mapOfDelinkingInbound = checkActiveParentDelinkInbnd(locResponseMap,mapOfDelinkingInbound,accountsWithActiveCagMap);
                }
                //TWC729-7455 - hierarchy change enhancements
                if(primaryLocResponseMap!=null && !primaryLocResponseMap.isEmpty()){
                    mapOfDelinkingInbound = createDeactivateinbound(primaryLocResponseMap,mapOfDelinkingInbound,accountsWithActiveCagMap);
                }
                if(!mapOfDelinkingInbound.isEmpty() && mapOfDelinkingInbound!=null){
                    for(Core_OnePartner_Inbound_Message__c inbnd: mapOfDelinkingInbound.values()){
                        listOfDelinkInbound.add(inbnd);
                    }
                }
                errorLogMsg+='***listofDelinkInbnd :'+listOfDelinkInbound;
                List<PRM_Tracker__c> trackerList = new List<PRM_Tracker__c>();
                if(opidToUpdate!=null && !opidToUpdate.isEmpty()){
                    Database.SaveResult[] saveOpidResultList = Database.update(opidToUpdate, false);
                    errorLogMsg=errorLog(saveOpidResultList,errorLogMsg);
                    
                }
                if(listOfDelinkInbound!=null){
                    Database.SaveResult[] saveResultList = Database.insert(listOfDelinkInbound, false);
                    inboundRecMap = new Map<id,Core_OnePartner_Inbound_Message__c>(listOfDelinkInbound);
                    for(Database.SaveResult result: saveResultList){//loop start
                        if(result.isSuccess()){
                            Id sId = result.getId();
                            if(sId!=null && inboundRecMap.keySet().contains(sId) ){
                                PRM_Tracker__c tracker = new PRM_Tracker__c();
                                tracker.PRM_Type__c = 'OPID Updates';
                                tracker.PRM_Milestone__c = 'DLNK_INBD_CRTD';
                                tracker.PRM_Location_Account__c = inboundRecMap.get(sId).Core_SalesCloud_AccountID__c;
                                tracker.PRM_Milestone_Display_Name__c = 'OPID Delink Request Created';
                                tracker.PRM_Completed__c = true;
                                trackerList.add(tracker);    
                            }
                        }
                        errorLogMsg=errorLog(saveResultList,errorLogMsg);
                    }//loop ends here..
                }
                if (!trackerList.isEmpty()) {
                    Database.SaveResult[] insertTrackerResult = Database.insert(trackerList,false);
                    errorLogMsg=errorLog(insertTrackerResult,errorLogMsg);
                }
            }catch(Exception ex){
                errorLogMsg+='***Exception: '+ex;
            }finally{
                Core_Log_Entry.logEntryWithDetails('OPID_UCD_Hierarchy_Handler', 'IPA','OPID_UCD_Hierarchy_Handler','Medium','',errorLogMsg ,'', '', '');
            }
    }
    /**
        *  @description      : gathers errorlogs for failed dmls
        *  @name             : errorLog
        *  @param            : Database.SaveResult[] saveResult, String errorLogMsg
        *  @throws exception : NONE
        * @userstory         : TWC729-7184
    **/
    public static String errorLog(Database.SaveResult[] saveResult, String errorLogMsg){
        for(Database.SaveResult result: saveResult){//loop start
            if (!result.isSuccess()){
                for (Database.Error err : result.getErrors()) {
                    errorLogMsg+= 'Message: ' + err.getMessage() + '\n'+ 'Fields: ' + err.Fields.toString() + '\n'+ 'StatusCode: ' + err.getStatusCode() + '\n';
                }
            }
        }//loop ends here..
        return errorLogMsg;
    }
    /**
        *  @description      : checks if parent and child OPID matches
        *  @name             : checkParentChildOPID
        *  @param            : Map<String,ResponseData> accountResponseMap,Map<String,Core_OnePartner_Inbound_Message__c> mapOfDelinkingInbound, Map<String,Core_Account_group_Member__c> accountsWithActiveCagMap
        *  @throws exception : NONE
        * @userstory         : TWC729-7184
    **/
    public static Map<String,Core_OnePartner_Inbound_Message__c>  checkParentChildOPID(Map<String,ResponseData> accountResponseMap,Map<String,Core_OnePartner_Inbound_Message__c> mapOfDelinkingInbound, Map<String,Core_Account_group_Member__c> accountsWithActiveCagMap){
        List<String> parentAccIdList= new List<String>();
        Map<String,ResponseData> parentChildMap = new Map<String,ResponseData>();
        Map<String,Core_Account_Group_Member__c> parentCagMap = new Map<String,Core_Account_Group_Member__c>();
        errorLogMsg+= '***checkParentChildOPID';
        try{
            for(String accountId :accountResponseMap.keySet()){
                if(accountResponseMap.get(accountId).ParentAccount!=null && !mapOfDelinkingInbound.containsKey(accountId)){
                    parentAccIdList.add(accountResponseMap.get(accountId).ParentAccount.AccountId);
                    parentChildMap.put(accountResponseMap.get(accountId).ParentAccount.AccountId,accountResponseMap.get(accountId));
                }
            }
            List<Core_Account_Group_Member__c> parentCagList = [Select Id,Name,Core_Partner_Account_Id__c,Core_Partner_Account_Id__r.Core_OnePartnerID__c,Core_Partner_Account_Id__r.Name, Core_Intel_Account_Id__c,Core_Inactive_Ind__c From Core_Account_Group_Member__c Where Core_Intel_Account_Id__c IN :parentAccIdList AND Core_Inactive_Ind__c = false];
            if(parentCagList!=null){
                for(Core_Account_Group_Member__c cag : parentCagList){
                    parentCagMap.put(cag.Core_Intel_Account_Id__c,cag);
                }
                for(String parent: parentChildMap.keySet()){
                    Core_OnePartner_Inbound_Message__c inbound = new Core_OnePartner_Inbound_Message__c();
                    ResponseData child = parentChildMap.get(parent);
                    if(!parentCagMap.containsKey(parent) || (parentChildMap.containsKey(parent) && accountsWithActiveCagMap.get(child.AccountId).Core_Partner_Account_Id__c != parentCagMap.get(parent).Core_Partner_Account_Id__c) ){
                        inbound=createDelinkInbound(accountsWithActiveCagMap.get(child.AccountId).Core_Partner_Account_Id__r.Core_OnePartnerID__c,accountsWithActiveCagMap.get(child.AccountId).Core_Partner_Account_Id__r.Name,child);
                    }
                    mapOfDelinkingInbound.put(inbound.Core_SalesCloud_AccountID__c,inbound);
                }
            }
        }catch(Exception e){
            errorLogMsg+='***Exception opid match method: '+e;
        }
        return mapOfDelinkingInbound;
    }
    /**
        *  @description      : checks if parent has an active inbound
        *  @name             : checkActiveParentDelinkInbnd
        *  @param            : Map<String,ResponseData> accountResponseMap,Map<String,Core_OnePartner_Inbound_Message__c> mapOfDelinkingInbound, Map<String,Core_Account_group_Member__c> accountsWithActiveCagMap
        *  @throws exception : NONE
        * @userstory         : TWC729-7184
    **/
    public static Map<String,Core_OnePartner_Inbound_Message__c>  checkActiveParentDelinkInbnd(Map<String,ResponseData> accountResponseMap,Map<String,Core_OnePartner_Inbound_Message__c> mapOfDelinkingInbound, Map<String,Core_Account_group_Member__c> accountsWithActiveCagMap){
        List<String> parentAccIdList= new List<String>();
        Map<String,ResponseData> parentChildMap = new Map<String,ResponseData>();
        Map<String,Core_OnePartner_Inbound_Message__c> parentInbndMap = new Map<String,Core_OnePartner_Inbound_Message__c>();
        errorLogMsg+= '***checkActiveParentDelinkInbnd';
        try{
            for(String accountId :accountResponseMap.keySet()){
                if(accountResponseMap.get(accountId).ParentAccount!=null && !mapOfDelinkingInbound.containsKey(accountId)){
                    parentAccIdList.add(accountResponseMap.get(accountId).ParentAccount.AccountId);
                    parentChildMap.put(accountResponseMap.get(accountId).ParentAccount.AccountId,accountResponseMap.get(accountId));
                }
            }
            List<Core_OnePartner_Inbound_Message__c> parentInboundList = [Select id,Core_CIM_ID__c,Core_OnePartnerID__c,Core_SalesCloud_AccountID__c, Core_PrimeID__c, Core_OnePartner_Account_Name__c, Core_Status__c, Core_Effective_Start_Date_Time__c, Core_Effective_End_Date_Time__c, Error_Description__c,  CreatedDate,Core_Status_Effective_End_Date_Time__c  from Core_OnePartner_Inbound_Message__c where Core_SalesCloud_AccountID__c in: parentAccIdList and (Core_Effective_End_Date_Time__c!=null or Core_Status_Effective_End_Date_Time__c!=null) and Core_Status__c='NEW'];
            if(parentInboundList!=null){
                for(Core_OnePartner_Inbound_Message__c inbnd: parentInboundList ){
                    parentInbndMap.put(inbnd.Core_SalesCloud_AccountID__c,inbnd);
                }
                for(String parent:parentChildMap.keySet()){
                    Core_OnePartner_Inbound_Message__c inbound = new Core_OnePartner_Inbound_Message__c();
                    if(parentInbndMap.containsKey(parent) && parentInbndMap.get(parent).Core_Status_Effective_End_Date_Time__c==null){
                        String opidnumber=String.valueOf(parentInbndMap.get(parent).Core_OnePartnerID__c);
                        inbound=createDelinkInbound(opidnumber,parentInbndMap.get(parent).Core_OnePartner_Account_Name__c,parentChildMap.get(parent));
                    }else if(mapOfDelinkingInbound.containsKey(parent) && mapOfDelinkingInbound.get(parent).Core_Status_Effective_End_Date_Time__c==null){
                        String opidnumber=String.valueOf(mapOfDelinkingInbound.get(parent).Core_OnePartnerID__c);
                        inbound=createDelinkInbound(opidnumber,mapOfDelinkingInbound.get(parent).Core_OnePartner_Account_Name__c,parentChildMap.get(parent));
                    }
                    mapOfDelinkingInbound.put(inbound.Core_SalesCloud_AccountID__c,inbound);
                }
            }
        }catch(Exception e){
            errorLogMsg+='***Exception parent inbnd method: '+e;
        }
        return mapOfDelinkingInbound;
    }
    /**
        *  @description      : create an instance of Delinking inbound
        *  @name             : createDelinkInbound
        *  @param            : String opidNumber,String opidName,ResponseData response
        *  @throws exception : NONE
        * @userstory         : TWC729-7184
    **/
    public static Core_OnePartner_Inbound_Message__c createDelinkInbound(String opidNumber,String opidName,ResponseData response){
        Core_OnePartner_Inbound_Message__c  inboundOnePartner = new Core_OnePartner_Inbound_Message__c  () ;
        inboundOnePartner.Core_OnePartnerID__c  = integer.valueof(opidNumber);
        inboundOnePartner.Core_OnePartner_Account_Name__c = opidName;
        inboundOnePartner.Core_SalesCloud_AccountID__c = response.AccountId ;
        inboundOnePartner.Core_Status__c = 'NEW';
        inboundOnePartner.Core_PAG_Grouping_Method__c = 'GLBL' ; 
        inboundOnePartner.Core_CIM_ID__c  = Decimal.valueof(response.BusinessPartyIdentifier); 
        inboundOnePartner.Core_Effective_End_Date_Time__c = System.now();
        inboundOnePartner.Comments__c='Delinking since UCD Hierarchy changed.';
        return inboundOnePartner;
    }
     /**
        *  @description      : create an instance of Delinking and deactivate inbound
        *  @name             : createDeactivateinbound
        *  @param            : Map<String,ResponseData> accountResponseMap,Map<String,Core_OnePartner_Inbound_Message__c> mapOfDelinkingInbound, Map<String,Core_Account_group_Member__c> accountsWithActiveCagMap
        *  @throws exception : NONE
        * @userstory         : TWC729-7184
    **/
    public static Map<String,Core_OnePartner_Inbound_Message__c> createDeactivateinbound(Map<String,ResponseData> accountResponseMap,Map<String,Core_OnePartner_Inbound_Message__c> mapOfDelinkingInbound, Map<String,Core_Account_group_Member__c> accountsWithActiveCagMap){
        List<String> parentAccIdList= new List<String>();
        Map<String,ResponseData> parentChildMap = new Map<String,ResponseData>();
        Map<String,Core_Account_Group_Member__c> parentCagMap = new Map<String,Core_Account_Group_Member__c>();
        errorLogMsg+= '***checkParentChildOPID';
        try{
           for(String accId:accountResponseMap.keySet()){
            Core_OnePartner_Inbound_Message__c  inboundOnePartner = new Core_OnePartner_Inbound_Message__c  () ;
            inboundOnePartner.Core_OnePartnerID__c  = integer.valueof(accountsWithActiveCagMap.get(accId).Core_Partner_Account_Id__r.Core_OnePartnerID__c);
            inboundOnePartner.Core_OnePartner_Account_Name__c = accountsWithActiveCagMap.get(accId).Core_Partner_Account_Id__r.name;
            inboundOnePartner.Core_SalesCloud_AccountID__c = accId ;
            inboundOnePartner.Core_Status__c = 'NEW';
            inboundOnePartner.Core_PAG_Grouping_Method__c = 'GLBL' ;
            inboundOnePartner.Core_CIM_ID__c  = Decimal.valueof(accountResponseMap.get(accId).BusinessPartyIdentifier);
            inboundOnePartner.Core_Status_Effective_End_Date_Time__c = System.now();
            inboundOnePartner.Comments__c='Delinking since UCD Hierarchy changed.';
            mapOfDelinkingInbound.put(inboundOnePartner.Core_SalesCloud_AccountID__c,inboundOnePartner);
           }
        }catch(Exception e){
            errorLogMsg+='***Exception opid match method: '+e;
        }
        return mapOfDelinkingInbound;
    }
    /**
     * Wrapper Class to hold response from event
     */
    public class ResponseData{
        public String AccountId {set;get;}
        public String BusinessPartyIdentifier {set;get;} 
        public String RecordType {set;get;}
        public CustomerAggregationType CustomerAggregationType {set;get;}
        public Parent ParentAccount {set;get;}
    }
    /**
     * Wrapper Class to hold CustomerAggregationType of response
     */
    public class CustomerAggregationType{

        public string Name{get;set;}
    }
    /**
     * Wrapper Class to hold Parent Account of response
     */
    public class Parent{
        public string BusinessPartyIdentifier{get;set;}
        public string AccountId{get;set;}
    }
}