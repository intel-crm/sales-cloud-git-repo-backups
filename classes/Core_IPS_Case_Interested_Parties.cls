/***************************************************************************************************
* Apex Class Name : Core_IPS_Case_Interested_Parties
* Test Class Name : Core_IPS_Case_Interested_PartiesTest
* Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Ganapati                   21/04/2020             Created for US639296 - LEX: Create: Create External Interested Party
****************************************************************************************************/

public with sharing class Core_IPS_Case_Interested_Parties {
    public static Boolean isEditable;
    @AuraEnabled
    
   	public static List<String> getInternalPartiesProfileIds(String caseId) {
		List<String> interestedPartiesList = new List<String>();    
        List<String> profIdList = new List<String>();        
        List<UserRecordAccess> userDetailsList = new List<UserRecordAccess>();
        List<Profile> profileLst = new List<Profile>();
		Set<String> profileIdSet = new Set<String>();
        Case caseObj = new Case();
        Set<Id> relatedUserIDs = new Set<Id>();

        if(caseId != null){
            caseObj = [Select id, RecordTypeId,AccountID,account.ownerid,ownerid, Core_IPS_Project_Case__c,Core_IPS_Private_Project__c from Case where ID =: CaseId];
        } 
        //FLS Check added - Nishitha
        if(Core_IPS_Case_Interested_Party__c.SObjectType.getDescribe().isAccessible()){
        for(Core_IPS_Case_Interested_Party__c interestedParty : [Select ID, Contact__c, First_Name__c, Email__c, Last_Name__c, User__c, Active__c from Core_IPS_Case_Interested_Party__c WHERE Case__c =: CaseId AND Type__c = 'Internal']){
            if(interestedParty.User__c != null){
                relatedUserIDs.add(interestedParty.User__c);
            }    
        }
        }
        userDetailsList = [SELECT HasEditAccess,RecordId FROM UserRecordAccess WHERE UserId =:userinfo.getuserId() AND RecordId = :CaseId];
        if(!userDetailsList.isEmpty()){
            isEditable = userDetailsList[0].HasEditAccess;
        String noAssignedContactCaseRecordType = Core_IPS_Helper_Utility.getIPSLabel('Case_RT_Name_IPS_NoAssignedContact');
        Id noAssignedContactCaseId = getCaseRecordtypeIDByName(noAssignedContactCaseRecordType);
        interestedPartiesList = System.Label.Interested_Parties_Internal_Agent.split(';');
        for(String str : Label.Interested_Parties_Internal_Agent_ProfileIds.split(',')){  //All Agents profile IDs,Agent-Partner,SalesRep BB Dual IPS,IPS Support Org Admin 
            if(str == string.valueof(UserInfo.getProfileId())){
                interestedPartiesList.addall(new List<String>(Label.Core_IPS_FAE_ProfileName.split(';')));
                break;
            }
        }
        if(caseObj.RecordTypeId==noAssignedContactCaseId && (caseObj.AccountId==null) && (caseObj.Core_IPS_Project_Case__c==null) ){
            interestedPartiesList.addall(new List<String>(Label.Core_IPS_FAE_ProfileName.split(';'))); //All Sales profiles included
        }
        if(isEditable && caseObj.RecordTypeId!=noAssignedContactCaseId ) {
            interestedPartiesList.addall(new List<String>(Label.Core_IPS_FAE_ProfileName.split(';')));                
        }            
        if(caseObj.RecordTypeId==noAssignedContactCaseId && (caseObj.AccountId==null) && (caseObj.Core_IPS_Project_Case__c==null) ){
            interestedPartiesList.addall(new List<String>(Label.Core_IPS_FAE_ProfileName.split(';'))); //All Sales profiles included
        }
        
        profileLst = [Select ID, Name from Profile Where (Name =: System.Label.Interested_Parties_Internal_Admin OR Name in: interestedPartiesList) AND (NOT(ID IN : relatedUserIDs))];           
        
        for(Profile prof : profileLst){
            profileIdSet.add(prof.Id); //Profile IDs of IPS Agent,Support Org Admin and all Sales profiles
        } 
        profIdList.addAll(profileIdSet);
        for(String profId : label.Core_IPS_Sales_Rep_ProfileIds.split(',')){ /* qualifying profiles ,Sales Manager, Sales Ops ,Sales Rep-BB ,Sales Rep-CW*/
            if(UserInfo.getProfileId() == profId ){
                profIdList.addAll(new List<String>(label.Core_IPS_Sales_Rep_ProfileIds.split(',')));
                break;
            }
        }
        
        }
        return profIdList;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Core_IPS_Case_Interested_Party__c> getLinkedInterestedParties(String caseId, String interestedPartyType) {
        List<Core_IPS_Case_Interested_Party__c> linkedInterestedParties = new List<Core_IPS_Case_Interested_Party__c>();
        if('Internal'.equalsIgnoreCase(interestedPartyType)) {
            linkedInterestedParties = [
                SELECT 
                    Id, Contact__c, First_Name__c, Email__c, Last_Name__c, User__c, Active__c 
                FROM Core_IPS_Case_Interested_Party__c 
                WHERE Case__c =: caseId 
                    AND Type__c = 'Internal'
            ];
        }
        if('External'.equalsIgnoreCase(interestedPartyType)) {
            linkedInterestedParties = [
                SELECT 
                    Id, Contact__c, Core_IPS_Account_Name__c, First_Name__c, Email__c, Last_Name__c, User__c, Active__c 
                FROM Core_IPS_Case_Interested_Party__c 
                WHERE Case__c =: caseId 
                    AND Contact__c != null  
                    AND Type__c= 'External' 
                    AND Active__c = true
                    AND ( (Case__r.AccountId !=null AND Case__r.Core_IPS_Project_Case__c =null ) OR (Case__r.Core_IPS_Project_Case__c != null))
            ];
        }
        return linkedInterestedParties;
    }
   
    @AuraEnabled
    public static Map<String,String> getContactUserMap(String queryString, Boolean isWithoutSharing) {
        /*US1038991 - 19/07/2021 - Vishal - security vulnerability --*/
       // String queryEsc = String.escapeSingleQuotes(queryString); 
        List<sObject> conList = Core_IPS_Case_Interested_Parties.getQueryResult(queryString, isWithoutSharing);
        Map<String, String> contactUserMap = new Map<String, String>();
        
     List<User> userList = [SELECT Id,contactid FROM User WHERE ContactId IN :conList];
        
        if(!userList.isEmpty()) {  
            for(User usr: userList) {
                contactUserMap.put(usr.contactid, usr.Id);
            }
        }
        if (!contactUserMap.isEmpty()){
            return contactUserMap;
        }
        else{
            return null;
        }
    }
    
    @AuraEnabled
    public static List<Id> getActiveContactIds(String accountId, String projectId) {
        Set<Id> activeContactIds = new Set<Id>();
        List<Id> conIdList = new List<Id>();
        if(accountId != null){
            for(User active : [SELECT Id, Accountid, contactid FROM User WHERE contactid != null AND Accountid=: accountId]) {
                activeContactIds.add(active.contactid);
            }
        } 
        if(projectId != null){
            ContactDataRetrieve conData = new ContactDataRetrieve();                    
            List<Core_IPS_Project_Member__c> projMem = conData.fetchProjectMembers(projectId);              
            Set<ID> contactIdSet = new Set<ID>();
            for(Core_IPS_Project_Member__c cpm : projMem){
                if(cpm.Core_IPS_Contact__c != null){
                    contactIdSet.add(cpm.Core_IPS_Contact__c);
                }
            }
            if(!contactIdSet.isEmpty()) {
                activeContactIds = conData.getActiveContactsNoSharing(contactIdSet, null);    
            }
        }
        if(!activeContactIds.isEmpty()) {
            conIdList.addAll(activeContactIds);    
        }
        return conIdList;
    }
    
    @AuraEnabled
    public static List<sObject> getQueryResult(String queryString, Boolean isWithoutSharing) {
        List<sObject> sObjLst = new list<sObject>();
        // TWC745-6696- SOQL_SOSL_Injection Fix 
        //String queryEsc = String.escapeSingleQuotes(queryString);
        if(isWithoutSharing) {
            ContactDataRetrieve conData = new ContactDataRetrieve();
            sObjLst = conData.getQueryResult(queryString);
        } else {
            sObjLst = Database.query(queryString);
        }
        if(!sObjLst.isEmpty())
          return sObjLst;
        else
          return null;  
    }
    
    @AuraEnabled
    public static Integer findTotalRecords(String query){
        Integer result = Database.countQuery(query);
        return result;
    }
    
    @AuraEnabled
    public static Boolean isCaseEditable(String caseId) {
        Boolean hasEditAccess;    
		List<UserRecordAccess> userDetailsList = new List<UserRecordAccess>();
		userDetailsList = [SELECT HasEditAccess,RecordId FROM UserRecordAccess WHERE UserId =:userinfo.getuserId() AND RecordId = :CaseId];
		if(!userDetailsList.isEmpty()){
            hasEditAccess = userDetailsList[0].HasEditAccess;
        }
        return hasEditAccess;
            }
        
    @AuraEnabled
    public static List<Core_IPS_Case_Interested_Party__c> insertInterestedParties(List<Core_IPS_Case_Interested_Party__c> interestedParties, Boolean isWithoutSharing) {
        if(isWithoutSharing) {
            ContactDataRetrieve conData = new ContactDataRetrieve();
            conData.saveRecords(interestedParties);
        } else {
            insert interestedParties;
        }
        return interestedParties;
    }
    
    public without sharing class ContactDataRetrieve{
        public  List<sObject> getQueryResult(String queryString){
            List<sObject> sObjLst = new list<sObject>();
            sObjLst = Database.query(queryString);
            return sObjLst;
        }
        public void saveRecords(list<Core_IPS_Case_Interested_Party__c> iPSObjList){
            insert iPSObjList;
        }/*
        public void deleteRecords(list<Core_IPS_Case_Interested_Party__c> IPSObjList){
            delete IPSObjList;
        }*/
        public  List<Core_IPS_Project_Member__c> fetchProjectMembers(Id caseProjectId){
            List<Core_IPS_Project_Member__c> listOfProjectMembers = new List<Core_IPS_Project_Member__c>();
            //FLS Check added - Nishitha
            if(Core_IPS_Project_Member__c.SObjectType.getDescribe().isAccessible()){
                listOfProjectMembers = [Select ID, Core_IPS_Contact__c FROM Core_IPS_Project_Member__c where Core_IPS_Project__c =: caseProjectId AND Core_Status__c = 'Active' AND Core_IPS_Contact__r.Core_IPS_Active__c = true AND Core_IPS_Contact__r.Core_IPS_Email_Opt_Out__c=false];
            }
            return listOfProjectMembers;
        }
        public Set<Id> getActiveContactsNoSharing(Set<Id> projContactIds, Id accountId){
            Set<Id> activeContactIds = new Set<Id>();
            List<User> allActiveUsers = new List<User>();
            
            if(accountId!=null && projContactIds==null){
                allActiveUsers = [SELECT Id, Accountid, contactid FROM User WHERE isActive = true AND contactid != null AND Accountid=: accountId];
            }
            else if(projContactIds!= null && accountId==null){
                allActiveUsers = [SELECT Id, contactid FROM User WHERE isActive = true AND contactid IN :projContactIds ];
            }
            for(User active : allActiveUsers){
                activeContactIds.add(active.contactid);
            }
            return activeContactIds;
        }        
    }    
    
    public static Schema.DescribeSObjectResult descCase;  
    public static Map<id,Schema.RecordTypeInfo> mapCaseRecordTypeID ;
    public static Map<string,Schema.RecordTypeInfo> mapCaseRecordTypeName;    
    public static Id getCaseRecordtypeIDByName(string caseRecordtypeName)
    {
        Id  caseRecordtypeID = null;
        if(descCase==null)
        {
            descCase = Schema.SObjectType.Case; 
        }
        if(mapCaseRecordTypeName ==  null)
        {
            mapCaseRecordTypeName = descCase.getRecordTypeInfosByName();
        }       
        caseRecordtypeID = mapCaseRecordTypeName.get(caseRecordtypeName).getRecordTypeId();
        return caseRecordtypeID;
        
    }
    //Shobhit Srivastav - TWC745-1547 - 16-03-2022 
    @AuraEnabled
    public static Boolean checkCustomerVisibility(Id recordId){
        Case caseRecord;
        //FLS Check added - Nishitha
        if(Case.SObjectType.getDescribe().isAccessible()){
            caseRecord = [SELECT Id, Core_IPS_Customer_Visible__c FROM Case WHERE Id = :recordId];
        }
            return caseRecord.Core_IPS_Customer_Visible__c;
    
    }
}