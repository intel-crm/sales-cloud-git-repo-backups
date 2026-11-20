/* Class Name : Core_IPS_ProjectController_Lex
Test Class : Core_IPS_ProjectController_Lex_Test
Description : This class is used as a controller for Premier Support Project LEX Components.
Author : Chandrashekar */
public with sharing class Core_IPS_ProjectController_Lex {
    
    
    public static Set<String> agentProfileId = new Set<String>();
    public static Set<Id> existingUser=new Set<Id>();
    public static Set<Id> faeId=new Set<Id>();
    
    //Added as Part of Active Project Member Fix - Showing warning message if Account Member Type is selected as 'ALL'
    /* @AuraEnabled // Commented by tushar for vanuability
public static Boolean getAccountMemberType(String projAccId) {
Boolean isAccntMemTypeAll = false;
Core_IPS_Account__c coreAccList = new Core_IPS_Account__c();
try{
if(Core_IPS_Account__c.SObjectType.getDescribe().isQueryable()) {
coreAccList =[SELECT Id, Core_Members__c FROM Core_IPS_Account__c WHERE Id= :projAccId LIMIT 1];
}
if(coreAccList!=null && coreAccList.Core_Members__c == 'All') {
isAccntMemTypeAll = true;
}
}catch(Exception e){}
return isAccntMemTypeAll;
}*/
    @AuraEnabled // Added by tushar for vanuability
    public static Boolean getAccountMemberType(String projAccId) {
        
        try {
            
           /* if (
                Schema.sObjectType.Core_IPS_Account__c.isAccessible() &&
                Schema.sObjectType.Core_IPS_Account__c.fields.Core_Members__c.isAccessible()
            ) {*/
                
                Core_IPS_Account__c coreAcc = [
                    SELECT Id, Core_Members__c
                    FROM Core_IPS_Account__c
                    WHERE Id = :projAccId
                    WITH USER_MODE
                    LIMIT 1
                ];
                
                return coreAcc != null &&
                    coreAcc.Core_Members__c == 'All';
           // }
            
        } catch (Exception e) {
            System.debug('Error: ' + e.getMessage());
        }
        
        return false;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Core_IPS_Account__c> getExistingAccounts(String projectId) {
        List<Core_IPS_Account__c> coreAccList = new List<Core_IPS_Account__c>();
        if(Core_IPS_Account__c.SObjectType.getDescribe().isQueryable()) {
            //US964686-- 30/4/2024 -- Farooq -- Replaced CIM ID with Businesss_Party_Id 
            //10/7/2024 venkatesh added CIM ID and Businesss_Party_Id 
            coreAccList =[SELECT Id, Name,Core_Account__r.Name,Core_Account__r.Owner.Name,Core_Account__r.Core_Business_Party_Id__c,Core_Account__r.Core_CIM_ID__c,Core_Account__c, Core_Members__c FROM Core_IPS_Account__c WHERE core_ips_project__c= :projectId LIMIT 100];
        }
        if(!coreAccList.isEmpty()) {
            return coreAccList;
        }
        return null;
    }
    @AuraEnabled(cacheable=true)
    public static Boolean checkExistingAccounts(String projectId) {
        Core_IPS_Project__c project = new Core_IPS_Project__c();
        List<Core_IPS_Account__c> projAccList = new List<Core_IPS_Account__c>();
        if(core_ips_project__c.SObjectType.getDescribe().isAccessible()){
            project = [select id,Core_Number_of_Accounts__c from Core_IPS_Project__c where id=:projectId limit 1];
        }
        if(Core_IPS_Account__c.SObjectType.getDescribe().isAccessible()) { //FLS Read fix applied - Gangadhar 19-10-2022
            projAccList=[Select Id,Core_Account__r.Core_CNDA_Number__c,Core_Status__c from Core_IPS_Account__c where Core_IPS_Project__c =:projectId];
        } 
        if(projAccList!=null && projAccList.size()>0){
            for(Core_IPS_Account__c projAcc: projAccList){
                // if(String.isBlank(projAcc.Core_Account__r.Core_CNDA_Number__c)){
                //     return true;
                // }
                //If the account is active then only check for CNDA. 08-06-2026-Nuthana
                if(projAcc.Core_Status__c == 'Active' && String.isBlank(projAcc.Core_Account__r.Core_CNDA_Number__c)){
                    return true;
                }
            }
        }
        return false;
    } 
    @AuraEnabled(cacheable=true)
    public static List<Account> getAddAccounts(List<String> accIds,Integer limitSize, Integer offset , String fetchType, String searchText){
        
        //public static List<Account> getAddAccounts(List<String> accIds,Integer limitSize, Integer offset , String fetchType, String sortBy, String sortDirection, String searchText){
        String searchCondition = '';
        String searchTextescqt;
        //TWC745-6696- SOQL_SOSL_Injection Fix
        if(searchText != null){
            searchTextescqt = String.escapeSingleQuotes(searchText);
        }
        
        String swtichColumn = (Label.Core_IPS_UCD_Toggle_Switch == '0') ? 'Core_CIM_ID__c' : 'Core_Business_Party_Id__c';
        if (!String.isBlank(searchTextescqt)) searchCondition = ' AND (Name Like \'%' + searchTextescqt + '%\' OR Owner.Name Like \'%' + searchTextescqt + '%\' OR  '+ swtichColumn +' LIKE \'%' + searchTextescqt + '%\' ) ';
        //if(!String.isBlank(searchText)) searchCondition = ' AND (Name Like \'%' + searchText + '%\' OR Owner.Name Like \'%' + searchText + '%\' OR  '+ swtichColumn +' LIKE \'%' + searchText + '%\' ) ';
        Boolean checkNDAAccount = false;
        List<Account> extAccList = new List<Account>();
        List<Account> allAccounts = new List<Account>();
        if(Account.SObjectType.getDescribe().isQueryable()) {
            //US964686-- 30/4/2024 -- Farooq -- Replaced CIM ID with Businesss_Party_Id
            //10/7/2024 venkatesh added CIM ID and Businesss_Party_Id 
            extAccList = [SELECT Id,Name,Core_CNDA_Number__c,Owner.Name,Core_Business_Party_Id__c,Core_CIM_ID__c FROM Account WHERE Id in :accIds];
        }
        if(!extAccList.isEmpty()){
            for(Account act: extAccList){
                if(act.Core_CNDA_Number__c != null){
                    checkNDAAccount = true;
                    break;
                }
            }
        }
        if(!extAccList.isEmpty() && checkNDAAccount && Account.SObjectType.getDescribe().isQueryable()) {
            if(fetchType == 'Load Data') {
                //US964686-- 30/4/2024 -- Farooq -- Replaced CIM ID with Businesss_Party_Id
                //10/7/2024 venkatesh added CIM ID and Businesss_Party_Id 
                //allAccounts = Database.query('SELECT Id,Name,Owner.Name,Core_Business_Party_Id__c,Core_CNDA_Number__c FROM Account WHERE Core_IPS_Active__c = true AND (Core_CNDA_Number__c != null OR Core_CNDA_Number__c != \'\') AND Id NOT IN :accIds ' + searchCondition + 'ORDER BY ' + sortBy + ' ' + sortDirection + ' LIMIT :limitSize OFFSET :offset');
                allAccounts = Database.query('SELECT Id,Name,Owner.Name,Core_Business_Party_Id__c,Core_CIM_ID__c,Core_CNDA_Number__c FROM Account WHERE Core_IPS_Active__c = true AND (Core_CNDA_Number__c != null OR Core_CNDA_Number__c != \'\') AND Id NOT IN :accIds ' + searchCondition + ' LIMIT :limitSize OFFSET :offset');
                
            } else if(fetchType == 'All Data') {
                //US964686-- 30/4/2024 -- Farooq -- Replaced CIM ID with Businesss_Party_Id
                //10/7/2024 venkatesh added CIM ID and Businesss_Party_Id 
                allAccounts = Database.query('SELECT Id,Name,Owner.Name,Core_Business_Party_Id__c,Core_CIM_ID__c,Core_CNDA_Number__c FROM Account WHERE Core_IPS_Active__c = true AND (Core_CNDA_Number__c != null OR Core_CNDA_Number__c != \'\') AND Id NOT IN :accIds ' + searchCondition );
                //allAccounts = Database.query('SELECT Id,Name,Owner.Name,Core_Business_Party_Id__c,Core_CNDA_Number__c FROM Account WHERE Core_IPS_Active__c = true AND (Core_CNDA_Number__c != null OR Core_CNDA_Number__c != \'\') AND Id NOT IN :accIds ' + searchCondition + 'ORDER BY ' + sortBy + ' ' + sortDirection );
            }
        }
        else if(!extAccList.isEmpty() && !checkNDAAccount){
            allAccounts = null;
        }
        else{
            if(fetchType == 'Load Data') {
                //US964686-- 30/4/2024 -- Farooq -- Replaced CIM ID with Businesss_Party_Id--*/
                //10/7/2024 venkatesh added CIM ID and Businesss_Party_Id 
                //allAccounts = Database.query('select Id,Name,Owner.Name,Core_Business_Party_Id__c,Core_CNDA_Number__c From Account where Core_IPS_Active__c=true ' + searchCondition + ' ORDER BY ' + sortBy + ' ' + sortDirection + ' LIMIT :limitSize OFFSET :offset');
                allAccounts = Database.query('select Id,Name,Owner.Name,Core_Business_Party_Id__c,Core_CIM_ID__c,Core_CNDA_Number__c From Account where Core_IPS_Active__c=true ' + searchCondition + ' LIMIT :limitSize OFFSET :offset');
            } else if(fetchType == 'All Data') {
                //US964686-- 30/4/2024 -- Farooq -- Replaced CIM ID with Businesss_Party_Id
                //10/7/2024 venkatesh added CIM ID and Businesss_Party_Id 
                allAccounts = Database.query('select Id,Name,Owner.Name,Core_Business_Party_Id__c,Core_CIM_ID__c,Core_CNDA_Number__c From Account where Core_IPS_Active__c=true ' + searchCondition );
                //allAccounts = Database.query('select Id,Name,Owner.Name,Core_Business_Party_Id__c,Core_CNDA_Number__c From Account where Core_IPS_Active__c=true ' + searchCondition + ' ORDER BY ' + sortBy + ' ' + sortDirection );
            }
        }
        if(!allAccounts.isEmpty()) {
            return allAccounts;
        }
        return null;
    }
    
    @AuraEnabled
    public static Integer insertAccount(List<String> inputStrings, String projId) {
        List<Core_IPS_Account__c> projAccList;
        Boolean errorMsg = false;
        if(Core_IPS_Account__c.SObjectType.getDescribe().isQueryable()) {
            projAccList = [SELECT Id,Core_Account__r.Core_CNDA_Number__c FROM Core_IPS_Account__c WHERE Core_IPS_Project__c =:projId];
        }
        Map<String,Object> obj = new Map<String, Object>();
        List<Core_IPS_Account__c> coreAccList = new List<Core_IPS_Account__c>();
        Core_IPS_Project__c proj= new Core_IPS_Project__c();
        proj=[Select Id,Core_Number_of_Accounts__c,Core_MPNDA__c from Core_IPS_Project__c where Id= :projId];
        Boolean stopProcessing = true;
        if(projAccList.size()>0){
            for(Core_IPS_Account__c prjAcc : projAccList) {
                If(!String.isBlank(prjAcc.Core_Account__r.Core_CNDA_Number__c)) {
                    stopProcessing = false;
                }
            }
        }
        else{
            stopProcessing = false;
        }
        if(!stopProcessing) {
            for(String str : inputStrings) {
                obj = (Map<string,Object>) JSON.deserializeUntyped(str);
                Core_IPS_Account__c acc = new Core_IPS_Account__c();
                acc.Core_Account__c = (Id)obj.get('accid');
                acc.Core_Members__c = (String)obj.get('Members');
                if (Schema.sObjectType.Core_IPS_Account__c.fields.Core_IPS_Project__c.isCreateable()) { //Fls Create fix applied - Gangadhar - 07/09/2022
                    acc.Core_IPS_Project__c = projId;
                }    
                if (Schema.sObjectType.Core_IPS_Account__c.fields.Core_Status__c.isCreateable()) {
                    acc.Core_Status__c = 'Active';
                }
                if((String)obj.get('cnda') == null){
                    errorMsg = true;
                }
                coreAccList.add(acc);
                
            }
            if(coreAccList.size()>0) {
                if(errorMsg && coreAccList.size()>1){
                    return 3;
                }
                else if((projAccList.size()>=1||(coreAccList.size()>1 && projAccList.size()==0 )) && (proj.Core_MPNDA__c==null||String.isBlank(proj.Core_MPNDA__c))){
                    return 4;       
                }
                
                if(Schema.sObjectType.Core_IPS_Account__c.isCreateable()){
                    insert coreAccList;
                    return 1;
                }
            }
        } else {
            return 2;
        }
        return null;
    }
    
    @AuraEnabled(cacheable=true)
    public static Boolean hasProjectEditAccess(String projectId) {
        
        Id userId =userInfo.getUserId();
        Boolean hasProjectEditAccess = false;
        List<UserRecordAccess> objURA;
        if(UserRecordAccess.SObjectType.getDescribe().isQueryable()) {
            objURA = [SELECT RecordId,HasEditAccess FROM UserRecordAccess WHERE UserId=:userId AND RecordId=:projectId];
        }
        if (objURA != null && objURA.size()>0){
            hasProjectEditAccess = objURA[0].HasEditAccess;
        }
        return hasProjectEditAccess;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Core_IPS_Project_Member__c> getExistingMembers(String projectId1,Integer limitSize1, Integer offset1) {
        List<Core_IPS_Project_Member__c> existingMembersList = new List<Core_IPS_Project_Member__c>();
        //if(Core_IPS_Project_Member__c.SObjectType.getDescribe().isQueryable()) {
            existingMembersList =[select Id, name, core_ips_contact__c, Core_IPS_Contact__r.FirstName, Core_IPS_Contact__r.LastName, Core_IPS_Contact__r.Email,Core_IPS_Contact__r.Account.Name from Core_IPS_Project_Member__c where core_ips_project__c =: projectId1 LIMIT :limitSize1 OFFSET :offset1];  
        //}
        if(!existingMembersList.isEmpty()) {
            return existingMembersList;         
        }
        return null;
    }
    
    @AuraEnabled(cacheable=true)
    //public static String getAddMembers(String projectId,Integer limitSize, Integer offset, String fetchType, String searchText) {
    public static String getAddMembers(String projectId,Integer limitSize, Integer offset, String fetchType) {    
        
        List<User> membersList = new List<User>();
        set<Id> setAccTeamIds = new set<Id>();
        set<Id> setAcctIds = new set<Id>();
        List <Core_ips_account__c> existingAccounts = new List <Core_ips_account__c>();
        List<Core_IPS_Project_Member__c> existingMembers = new List<Core_IPS_Project_Member__c>();
        List <IPSMemberWrapper> wrapperInContext = new List <IPSMemberWrapper> ();      
        if(core_ips_account__c.SObjectType.getDescribe().isQueryable())
           existingAccounts = [select id, core_account__r.OwnerId, core_account__c from core_ips_account__c where core_ips_project__c =: projectId and Core_Status__c='Active' and(core_members__c = 'Selective' OR core_members__c = 'All')];//added Core_Status__c='Active' by sabira  as part of TWC745-9522                     
        for (Core_ips_account__c ipsAct: existingAccounts) {
            setAcctIds.add(ipsAct.core_account__c); 
            if(ipsAct.core_account__r.OwnerId == userinfo.getUserId()){
                setAccTeamIds.add(ipsAct.core_account__c);        
            }             
        }
        if(Core_IPS_Project_Member__c.SObjectType.getDescribe().isQueryable()){
            existingMembers = [select Id, name, core_ips_contact__c, Core_IPS_Contact__r.FirstName, Core_IPS_Contact__r.LastName, Core_IPS_Contact__r.Email,Core_IPS_Contact__r.Account.Name from Core_IPS_Project_Member__c where core_ips_project__c =: projectId];
        }
        set<Id> setMemIds = new set<Id>();
        for (Core_IPS_Project_Member__c ipsMem: existingMembers) {
            setMemIds.add(ipsMem.core_ips_contact__c);        
        }
        System.debug('### getAddMembers DEBUG ### projectId=' + projectId + ' fetchType=' + fetchType);
        System.debug('### setAcctIds (all project accounts)=' + setAcctIds);
        System.debug('### setMemIds (existing member contacts)=' + setMemIds);
        //In case of FAE only those contacts should be vailable where FAE is Account Team Member
        if(System.Label.Core_IPS_SalesRep_Profile_Ids.Contains(String.ValueOf(userinfo.getProfileId()).substring(0,15))){ 
            System.debug('### Running as FAE/SalesRep profile: ' + UserInfo.getProfileId());
            //if(AccountTeamMember.SObjectType.getDescribe().isAccessible()){
            for(AccountTeamMember accteam : [Select Id, AccountId From AccountTeamMember WHERE UserId =:UserInfo.getUserId() AND AccountId IN: setAcctIds]){
                setAccTeamIds.add(accteam.AccountId); 
            }
            //}
            System.debug('### setAccTeamIds (owned/team accounts)=' + setAccTeamIds);
            // Use all project accounts so members from every project account are visible.
            // The original narrow fallback (setAccTeamIds when non-empty) caused accounts where
            // the FAE is neither owner nor ATM to be silently excluded even though the project
            // admin deliberately added those accounts to the project.
            Set<Id> queryAcctIds = setAcctIds;
            System.debug('### queryAcctIds (used for User query)=' + queryAcctIds);
            if(fetchType == 'Load Data') {
                //if(User.SObjectType.getDescribe().isQueryable())
                membersList = [Select id,ContactId ,Contact.FirstName,Contact.LastName,Contact.Email, Contact.Account.Name from User where Contact.Core_IPS_Active__c=true AND AccountId IN :queryAcctIds AND ContactId NOT IN :setMemIds LIMIT :limitSize OFFSET :offset];  
            }
            else if(fetchType == 'All Data') {
                //if(User.SObjectType.getDescribe().isQueryable())
                membersList = [Select id,ContactId,Contact.FirstName,Contact.LastName,Contact.Email, Contact.Account.Name from User where Contact.Core_IPS_Active__c=true AND AccountId IN :queryAcctIds AND ContactId NOT IN :setMemIds ];   
            }
            for (User objUser : membersList){
                IPSMemberWrapper wrapper = new IPSMemberWrapper();
                wrapper.selected = false;
                wrapper.FirstName = objUser.Contact.FirstName;
                wrapper.LastName  = objUser.Contact.LastName;
                wrapper.Email= objUser.Contact.Email;               
                wrapper.Name  = objUser.Contact.Account.Name;
                wrapper.Id = objUser;
                wrapper.ContactId  = objUser.contactId;
                wrapperInContext.add(wrapper);
            }
        }
        
        else{
            System.debug('### Running as non-FAE profile: ' + UserInfo.getProfileId());
            System.debug('### queryAcctIds (setAcctIds for non-FAE)=' + setAcctIds);
            if(fetchType == 'Load Data') {
                //if(User.SObjectType.getDescribe().isQueryable())
                membersList = [Select id,ContactId,Contact.FirstName,Contact.LastName,Contact.Email, Contact.Account.Name from User where Contact.Core_IPS_Active__c=true AND AccountId IN :setAcctIds AND ContactId NOT IN :setMemIds LIMIT :limitSize OFFSET :offset];  
                //membersList = Database.query('Select id,ContactId,Contact.FirstName,Contact.LastName,Contact.Email, Contact.Account.Name from User where Contact.Core_IPS_Active__c=true and IsActive=true AND AccountId IN :setAcctIds AND ContactId NOT IN :setMemIds LIMIT :limitSize OFFSET :offset');  
            }
            else if(fetchType == 'All Data') {
                
                //if(User.SObjectType.getDescribe().isQueryable())
                membersList = [Select id,ContactId,Contact.FirstName,Contact.LastName,Contact.Email, Contact.Account.Name from User where Contact.Core_IPS_Active__c=true AND AccountId IN :setAcctIds AND ContactId NOT IN :setMemIds ];   
                //membersList = Database.query('Select id,ContactId,Contact.FirstName,Contact.LastName,Contact.Email, Contact.Account.Name from User where Contact.Core_IPS_Active__c=true and IsActive=true AND AccountId IN :setAcctIds AND ContactId NOT IN :setMemIds ' + searchCondition);   
            }
            for (User objUser : membersList){
                IPSMemberWrapper wrapper = new IPSMemberWrapper();
                wrapper.selected = false;
                wrapper.FirstName = objUser.Contact.FirstName;
                wrapper.LastName  = objUser.Contact.LastName;
                wrapper.Email= objUser.Contact.Email;           
                wrapper.Name  = objUser.Contact.Account.Name;
                wrapper.Id = objUser;
                wrapper.ContactId  = objUser.contactId;       
                wrapperInContext.add(wrapper);
            }
        }
        //wrapperInContext.sort();
        System.debug('### getAddMembers returning ' + wrapperInContext.size() + ' members');
        return JSON.serialize(wrapperInContext);
    }
    
    public class IPSMemberWrapper implements Comparable {
        public string FirstName;
        public string LastName;
        public string Email;            
        public string Name;
        public string ContactId;
        public contact conObj;
        public boolean selected; 
        public User Id;
        
        public Integer compareTo(Object o) {
            IPSMemberWrapper  that = (IPSMemberWrapper) o;
            if (this.conObj.FirstName==null || this.conObj.FirstName==null) {return -1 ;}
            else if(this.conObj.FirstName<that.conObj.FirstName) {return -1;}
            
            else{return 1;}
        }
    }
    
    @AuraEnabled
    public static String insertProjectMembers(List<Core_IPS_Project_Member__c> projectMemberInfo){
        /* Start ---- Tushar ----- Added new code and comment projectID*/
        if (projectMemberInfo == null || projectMemberInfo.isEmpty()) return 'failed';
        
        Id projectId = projectMemberInfo[0].Core_IPS_Project__c;
        
        // Validate user has edit access to the target project
        List<UserRecordAccess> uraList = [
            SELECT RecordId,HasEditAccess 
            FROM UserRecordAccess 
            WHERE UserId = :UserInfo.getUserId() AND RecordId = :projectId
        ];
        if (uraList.isEmpty() || !uraList[0].HasEditAccess) {
            return 'exception';
        }
        //Id projectId = projectMemberInfo[0].Core_IPS_Project__c;
        /* End ---- Tushar ----- Added new code and comment projectID*/
        List<Core_IPS_Project_Member__c> existingMembersList = new List<Core_IPS_Project_Member__c>();
        Set<Id> memIds = new Set<Id>();
        if(Core_IPS_Project_Member__c.SObjectType.getDescribe().isAccessible()){
            existingMembersList =[select Id, name, core_ips_contact__c, Core_IPS_Contact__r.FirstName, Core_IPS_Contact__r.LastName, Core_IPS_Contact__r.Email,Core_IPS_Contact__r.Account.Name from Core_IPS_Project_Member__c where core_ips_project__c =: projectId ORDER BY Core_IPS_Contact__r.FirstName]; 
            for(Core_IPS_Project_Member__c em : existingMembersList) {
                memIds.add(em.core_ips_contact__c);
            }
        }
        if(projectMemberInfo<>null){
            try{
                Map<Id,Core_IPS_Project_Member__c> mapUserId2ProjectMember = new Map<Id,Core_IPS_Project_Member__c>();
                for(Core_IPS_Project_Member__c projMember : projectMemberInfo) {
                    if(memIds.contains(projMember.Core_IPS_Contact__c)){
                    } 
                    else{
                        mapUserId2ProjectMember.put(projMember.Core_User__c, projMember);
                    }    
                } 
                if(Schema.sObjectType.Core_IPS_Project_Member__c.isCreateable()){              
                    insert mapUserId2ProjectMember.values();
                    return 'Success';
                }
                else {
                    return 'failed';
                }   
            }
            catch(Exception e){ return 'exception';}
        }
        else{ return null; }
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Core_IPS_Intel_Support_Team__c> getIntelSupportOwner(String projectId) {
        List<Core_IPS_Intel_Support_Team__c> intelSupportOwner = new List<Core_IPS_Intel_Support_Team__c>();
        if(Core_IPS_Intel_Support_Team__c.SObjectType.getDescribe().isQueryable()) {
            //Moved query to Without sharing class as part of vulnerability fix - Nuthana
            String ownerQuery = 'SELECT Id,Core_IPS_User__c,Core_IPS_User__r.FirstName,Core_IPS_User__r.LastName,Core_IPS_User__r.Email FROM Core_IPS_Intel_Support_Team__c WHERE Status__c=\'Active\' AND Core_IPS_User__r.isActive=true AND Core_IPS_Project__c=:projectId ORDER BY Core_IPS_User__r.Name';
            intelSupportOwner = (List<Core_IPS_Intel_Support_Team__c>) Core_IPS_QueryService.queryRecords(ownerQuery, new Map<String, Object>{ 'projectId' => projectId });
        }
        if(!intelSupportOwner.isEmpty()) {
            return intelSupportOwner;      
        }
        return null;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Core_IPS_Project_Member__c> getPartnerSupportOwner(String projectId) {
        List<Core_IPS_Project_Member__c> partnerSupportOwner = new List<Core_IPS_Project_Member__c>();
        String DFAEPermissionSetId = System.Label.Core_IPS_Partner_DFAE_Permission_Set;
        String partnerProfileId = System.Label.Core_IPS_Partner_Profile_Id;      
        if(Core_IPS_Project_Member__c.SObjectType.getDescribe().isQueryable()) {
            partnerSupportOwner = [SELECT Id,Core_User__c,Core_User__r.FirstName,Core_User__r.LastName,Core_User__r.Email FROM Core_IPS_Project_Member__c
                                   WHERE Core_Status__c='Active' AND Core_IPS_Contact__r.Core_IPS_Active__c=true AND Core_User__r.isActive=true AND Core_IPS_Project__c=:projectId AND Core_User__c IN (SELECT AssigneeId FROM PermissionSetAssignment WHERE PermissionSetId =:DFAEPermissionSetId AND Assignee.ProfileId =:PartnerProfileId) ORDER BY Core_User__r.Name];           
        }
        if(!partnerSupportOwner.isEmpty()) {
            return partnerSupportOwner;      
        }
        return null;
    }
    
    @AuraEnabled
    public static String updateSupportOwner(String projectId,String supportOwner,String partnerOwner) {
        Core_IPS_Project__c proj = new Core_IPS_Project__c(Id=projectId);
        Boolean isUpdate = false;
        if(String.isNotBlank(supportOwner)) {
            if (Schema.sObjectType.Core_IPS_Project__c.fields.Core_IPS_Intel_Support_Owner__c.isUpdateable()) {
                proj.Core_IPS_Intel_Support_Owner__c = supportOwner=='none' ? null : supportOwner;
            }
            isUpdate = true;
        }
        if(String.isNotBlank(partnerOwner)) {
            if (Schema.sObjectType.Core_IPS_Project__c.fields.Core_IPS_Partner_Support_Owner__c.isUpdateable()) {
                proj.Core_IPS_Partner_Support_Owner__c = partnerOwner=='none' ? null : partnerOwner;
            }
            isUpdate = true;
        }      
        if(isUpdate){
            if (Schema.sObjectType.Core_IPS_Project__c.isUpdateable()){
                //update proj;
                List<Core_IPS_Project__c> projects = new List<Core_IPS_Project__c>{ proj };
                Core_IPS_QueryService.updateRecords(projects);
                return 'Success';
            }
            else {
                return 'failed';
            }    
        }
        else{ return null; }
    }
    
    @AuraEnabled(cacheable = true)
    public static List<Core_IPS_Intel_Support_Team__c> getExistingTeamMembers(String projId){
        List<Core_IPS_Intel_Support_Team__c> existingTeamMems = new List<Core_IPS_Intel_Support_Team__c>();
        
        if(Core_IPS_Intel_Support_Team__c.SObjectType.getDescribe().isQueryable()) {
            String teamQuery = 'SELECT Id,Core_IPS_User__c,Core_IPS_User__r.FirstName,Core_IPS_User__r.LastName,Core_IPS_User__r.Email,Core_IPS_Profile__c,Core_IPS_Project__c FROM Core_IPS_Intel_Support_Team__c WHERE Core_IPS_Project__c = :projId';
            existingTeamMems = (List<Core_IPS_Intel_Support_Team__c>) Core_IPS_QueryService.queryRecords(teamQuery, new Map<String, Object>{ 'projId' => projId });
        }
        if(!existingTeamMems.isEmpty()) {
            return existingTeamMems;
        }
        return null;
    }
    
    public class teamMembersWrapper{
        @AuraEnabled
        public List<User> userList;
        @AuraEnabled
        public String Message;
    }
    
    @AuraEnabled(cacheable = true)
    public static teamMembersWrapper getAddTeamMembers(String projId, String searchTxt, List<Core_IPS_Intel_Support_Team__c> existingData){
        String searchableString = '';
        Set<Id> accountId = new Set<Id>();
        List<User> userList = new List<User>();
        teamMembersWrapper wrapperObj = new teamMembersWrapper();
        try {
            String activeStatus=Core_IPS_Helper_Utility.getIPSLabel('CoreStatus_Active');
            List<Core_IPS_Account__c>  projAccList;
            if(Core_IPS_Account__c.SObjectType.getDescribe().isAccessible()){
                projAccList=[SELECT Id,Core_Account__c,Core_IPS_Project__c FROM Core_IPS_Account__c WHERE Core_IPS_Project__c=:projId AND Core_Status__c=:activeStatus];    
            }
            if(projAccList!=null && projAccList.size()>0) {
                for(Core_IPS_Account__c projAcc: projAccList) {
                    accountId.add(projAcc.Core_Account__c);  
                }
                if(accountId!=null && accountId.size()>0) {
                    for(Set<Id> setId: Core_IPS_Helper_Utility.getFAEsByAccount(accountId).values()) {
                        faeId.addAll(SetId);
                    }  
                }
            }
            AgentProfileId.addall(new List<String>(label.Core_IPS_Agent_Profile_Ids.split(',')));
            List<Id> orgAdminPermUser = new List<Id>();    
            //if(PermissionSetAssignment.SObjectType.getDescribe().isAccessible()){
            for(PermissionSetAssignment permSetUser: [SELECT Id,AssigneeId FROM PermissionSetAssignment WHERE PermissionSet.name ='Core_IPS_SupportOrgAdmin' ]) {              
                orgAdminPermUser.add(permSetUser.AssigneeId);
            }
            //}
            if(existingData!=null && existingData.size()>0) {
                for(Core_IPS_Intel_Support_Team__c existingmem: existingData) {
                    existingUser.add(existingmem.Core_IPS_User__c)   ;
                }
            }
            searchableString = searchTxt + '%';
            String sQuery;                                                                                                
            if((AgentProfileId!=null && AgentProfileId.size()>0) || (FaeId!=null && FaeId.size()>0) || orgAdminPermUser .size()>0) {
                // SOQL Injection Fix - Start -  Shipra
                // ATHR fix-start
                Integer limitValue = Integer.valueOf(System.Label.Core_IPS_Interested_Party_Limit);
           
                Map<String, Object> bindMap = new Map<String, Object>{ 'agentProfileId' => AgentProfileId, 'searchableString' => searchTxt + '%', 'ExistingUser' => existingUser, 'faeId' => FaeId, 'OrgAdminPermUser' => orgAdminPermUser, 'limitValue' => limitValue };
                    sQuery = 'SELECT Id,Profile.Name, Name, FirstName, LastName, Email FROM User ' +
                    'WHERE (ProfileID In :AgentProfileId  AND (FirstName like :searchableString OR LastName like :searchableString OR Email like :searchableString) AND (NOT(ID IN :existingUser)) AND (IsActive = true)) OR (ID in :FaeId AND (FirstName like :searchableString OR LastName like :searchableString OR Email like :searchableString) AND (NOT(ID IN : existingUser))  AND (IsActive = true))  OR (ID IN :orgAdminPermUser AND (FirstName like :searchableString OR LastName like :searchableString OR Email like :searchableString) AND (NOT(ID IN : existingUser))  AND (IsActive = true))' +
                    ' Limit :limitValue';
                     
           
                UserList = (List<User>) Core_IPS_QueryService.queryRecords(sQuery, bindMap);
                System.debug(UserList);
                if(UserList!=null && UserList.size()>0) {
                    if(isMoreThanThousand(searchableString)) {
                        wrapperObj.Message = System.label.Core_IPS_Interested_Party_Warning_Msg;
                        wrapperObj.userList = null;
                        return wrapperObj;
                    }
                    wrapperObj.userList = UserList;
                    wrapperObj.Message = 'Data returned';
                    return wrapperObj;
                }
                else {
                    wrapperObj.Message = System.label.Core_IPS_No_User;
                    wrapperObj.userList = null;
                    return wrapperObj;
                }
            }  
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return null;
    }
    
    @AuraEnabled
    public static Integer insertTeamMembers(List<String> inputStrings, String projId){
        Map<String,Object> obj = new Map<String,Object>();
        List<Core_IPS_Intel_Support_Team__c> teamMemberList = new List<Core_IPS_Intel_Support_Team__c>();
        for(String str : inputStrings) {
            obj = (Map<string,Object>) JSON.deserializeUntyped(str);
            Core_IPS_Intel_Support_Team__c tMember = new Core_IPS_Intel_Support_Team__c();
            // Niyaz -- 12/06/2025 --- added as part of vulnerability fix
            if (Schema.sObjectType.Core_IPS_Intel_Support_Team__c.fields.Core_IPS_User__c.isCreateable()) { 
            tMember.Core_IPS_User__c = (Id)obj.get('userId');
            }
            if (Schema.sObjectType.Core_IPS_Intel_Support_Team__c.fields.Core_IPS_Project__c.isCreateable()) {
                tMember.Core_IPS_Project__c = projId;
            }
            if (Schema.sObjectType.Core_IPS_Intel_Support_Team__c.fields.Status__c.isCreateable()) {
                tMember.Status__c = 'Active';
            }
            teamMemberList.add(tMember);
            System.debug('teamMemberList'+teamMemberList);
        }
        if(teamMemberList.size()>0) {
            if(Schema.sObjectType.Core_IPS_Intel_Support_Team__c.isCreateable()){
                //insert teamMemberList; Commented As part of Vulnerability fix-moved DML to Without sharing class - Nuthana
                Core_IPS_QueryService.insertRecords(teamMemberList);
                return 1;
            }
        }
        return 2;
    }
    
    public static boolean isMoreThanThousand(String searchableString){
        // SOQL Injection Fix - Start -  Shipra                
        // ATHR fix - start
        //Map<String, Object> bindMap = new Map<String, Object>{ 'agentProfileId' => AgentProfileId, 'SearchableString' => searchableString, 'ExistingUser' => existingUser, 'faeId' => FaeId};
            
            String sQueryCount = 'Select Count() FROM User ' + 
            'WHERE (ProfileID IN :agentProfileId AND (FirstName like :SearchableString OR LastName like :SearchableString OR Email like :SearchableString) AND (NOT(ID IN :ExistingUser)) AND (IsActive = true)) OR (ID in :faeId AND (FirstName like :SearchableString OR LastName like :SearchableString OR Email like :SearchableString) AND (NOT(ID IN : ExistingUser)) AND (IsActive = true)) ';
        //Integer recordCount = Database.countQueryWithBinds(sQueryCount,bindMap,AccessLevel.USER_MODE);
        Integer recordCount = Database.countQuery(sQueryCount);
        // ATHR fix - end
        // SOQL Injection Fix - End -  Shipra
        
        return (recordCount > Integer.valueof(System.Label.Core_IPS_Interested_Party_Limit));
    }
    
    
    public class WrapperClass {
        @AuraEnabled
        public Boolean hasData;
        @AuraEnabled
        public String type;
        @AuraEnabled
        public List<sObject> returnData;
    }
    
    @AuraEnabled(cacheable = true)
    public static WrapperClass getDefaultCaseOwner(String productId) {
        WrapperClass wrap = new WrapperClass();
        Core_IPS_Product__c prodObj;
        try {
            if(productId != null){ 
                if(Core_IPS_Product__c.SobjectType.getDescribe().isQueryable()){
                    ProdObj = [Select id,Core_IPS_Product_Name__c,Status__c ,Core_Supported_Product__c,Core_IPS_Project__c,Core_IPS_Prodcut_Org__c, Core_IPS_Prod_Def_Case_Owner_ID__c, Core_IPS_Prod_Default_Case_Owner__c  FROM Core_IPS_Product__c where ID =:productId ];
                }
                if(String.isNotBlank(ProdObj.Core_IPS_Prod_Def_Case_Owner_ID__c) && String.isNotBlank(ProdObj.Core_IPS_Prod_Default_Case_Owner__c)) {
                    if(ProdObj.Core_IPS_Prod_Def_Case_Owner_ID__c.startsWith('005')) { 
                        User usr;  
                        if(User.SObjectType.getDescribe().isQueryable()) {                     
                            usr = [Select Id, FirstName, LastName, Email FROM User WHERE Id =: ProdObj.Core_IPS_Prod_Def_Case_Owner_ID__c];
                        }
                        wrap.hasData = true;
                        wrap.type = 'User';
                        wrap.returnData = new List<sObject>{usr};
                            } else {
                                Group defaultCaseOwnerQueue;
                                if(Group.SObjectType.getDescribe().isQueryable()) {                     
                                    defaultCaseOwnerQueue = [Select Id, Name, DeveloperName FROM Group WHERE Id =: ProdObj.Core_IPS_Prod_Def_Case_Owner_ID__c];
                                }
                                wrap.hasData = true;
                                wrap.type = 'Queue';
                                wrap.returnData = new List<sObject>{defaultCaseOwnerQueue};
                                    }
                } else {
                    wrap.hasData = false;
                    wrap.type ='';
                    wrap.returnData = null;
                }
                return wrap;
            }
        } catch (Exception e) {
        }
        return null;
    }
    
    @AuraEnabled
    public static Integer removeCaseOwner(String productId){
        Core_IPS_Product__c prodObj;
        if(Core_IPS_Product__c.SObjectType.getDescribe().isQueryable()) {                     
            ProdObj = [Select id,Core_IPS_Product_Name__c,Status__c ,Core_Supported_Product__c,Core_IPS_Project__c,Core_IPS_Prodcut_Org__c, Core_IPS_Prod_Def_Case_Owner_ID__c, Core_IPS_Prod_Default_Case_Owner__c  FROM Core_IPS_Product__c where ID =:ProductId ];
        }
        //if (Schema.sObjectType.Core_IPS_Product__c.fields.Core_IPS_Prod_Def_Case_Owner_ID__c.isUpdateable()) {
        ProdObj.Core_IPS_Prod_Def_Case_Owner_ID__c = '';     
        //}
        //if (Schema.sObjectType.Core_IPS_Product__c.fields.Core_IPS_Prod_Default_Case_Owner__c.isUpdateable()) {
        ProdObj.Core_IPS_Prod_Default_Case_Owner__c = ''; 
        //}
        try {
            //if(Schema.sObjectType.Core_IPS_Product__c.isUpdateable()){
            update ProdObj;
            //}
            return 1;
        } catch(exception e){
        }
        return 2;
    }
    
    
    
    @AuraEnabled(cacheable= true)
    public static WrapperClass searchOwner(String searchTxt, String type, String productId){
        WrapperClass wrap2 = new WrapperClass();
        Core_IPS_Product__c prodRec;
        if(Core_IPS_Product__c.SObjectType.getDescribe().isQueryable()) { 
            prodRec = [Select Id,Core_IPS_Project__c  FROM Core_IPS_Product__c where Id =: productId ];
        }
        String projectId = prodRec.Core_IPS_Project__c;
        List<User> userList;
        List<QueueSobject> queueList;
        String partnerProfileID = string.escapeSingleQuotes(System.Label.Core_IPS_Agent_Partner_Profile_id);
        String profileIds = System.Label.Core_IPS_DefaultCaseOwner_Profile_Id;
        List<String> lstProfId = ProfileIds.split(';');
        String searchableString = '';
        try {
            if(type == 'user'){
                searchableString = '%'+ searchTxt + '%' ;
                searchableString = String.escapeSingleQuotes(searchableString);
                String sQuery;         
                sQuery = 'SELECT Id, Name, FirstName, LastName, Email FROM User ' + 
                    'WHERE (ProfileID IN :lstProfId AND (FirstName like :searchableString OR LastName like ' +
                    ':searchableString OR Email like :searchableString) AND (IsActive = true))' + 
                    ' Limit  1000 ' ;
                if(User.SobjectType.getDescribe().isQueryable()){
                    userList = Database.query(string.escapeSingleQuotes(sQuery));
                }
                if(userList.size()>0){
                    wrap2.hasData = true; 
                    wrap2.returnData = userList;   
                } else {
                    wrap2.hasData = false; 
                    wrap2.returnData = null;
                }
                wrap2.type = 'User'; 
            } else if(type == 'partnerUser') {
                searchableString = '%'+ searchTxt + '%' ;
                searchableString = String.escapeSingleQuotes(searchableString);
                String sQuery;                 
                sQuery = 'SELECT Id, Name, FirstName, LastName, Email FROM User ' + 
                    ' WHERE Id IN (Select Core_User__c from Core_IPS_Project_Member__c ' +
                    ' where Core_IPS_Project__c =: projectId ) AND  (ProfileID  =: PartnerProfileID ) ' +
                    ' AND (FirstName like :searchableString OR LastName like :searchableString OR ' +
                    ' Email like :searchableString) AND (IsActive = true)' +  
                    ' Limit 1000 ';          
                if(User.SobjectType.getDescribe().isQueryable()){          
                    userList =  Database.query(string.escapeSingleQuotes(sQuery));
                }
                if(userList.size()>0){
                    wrap2.hasData = true; 
                    wrap2.returnData = userList;   
                } else {
                    wrap2.hasData = false; 
                    wrap2.returnData = null;
                }
                wrap2.type = 'PartnerUser';
            } else if(type == 'queue'){
                searchableString = '%'+ searchTxt + '%' ;
                searchableString = String.escapeSingleQuotes(searchableString);
                String sobjectTypeCase = string.escapeSingleQuotes('Case');
                String ipsQueues = string.escapeSingleQuotes('%IPS_%');
                String sQuery;
                sQuery = 'SELECT QueueId, Queue.Name,Queue.DeveloperName, SobjectType FROM QueueSobject Where SobjectType =:sobjectTypeCase' +
                    ' AND (Queue.NAME like :searchableString OR Queue.DeveloperName like :searchableString) and Queue.DeveloperName like :ipsQueues' +                   
                    ' Limit 1000 ';
                queuelist = Database.query(string.escapeSingleQuotes(sQuery));  
                if(queuelist.size()>0){
                    wrap2.hasData = true; 
                    wrap2.returnData = queuelist;   
                } else {
                    wrap2.hasData = false; 
                    wrap2.returnData = null;
                }
                wrap2.type = 'Queue';
            }
            return wrap2;
        } catch (Exception e) {
        }
        return null;
    }
    
    @AuraEnabled
    public static Integer updateCaseOwner(Id inputString,String inputType, String productId){
        List<User> selectedUser = new List<User>();
        List<Group> selectedQueue = new List<Group>();
        Core_IPS_Product__c prodObj = new Core_IPS_Product__c(Id=productId);
        if(inputType=='Queue'){
            if(Group.SobjectType.getDescribe().isQueryable()){
                selectedQueue = [Select Id,Name from Group where Id =: inputString];
            }
            /*START Niyaz -- 12/06/2025 --- added as part of vulnerability fix */
            //Commented by Nuthana-As part of Vulnerability fixes - 19-08-2026
            //if (Schema.sObjectType.Core_IPS_Product__c.fields.Core_IPS_Prod_Default_Case_Owner__c.isUpdateable()) {
            prodObj.Core_IPS_Prod_Default_Case_Owner__c = selectedQueue[0].Name;
            //}
            
            if (Schema.sObjectType.Core_IPS_Product__c.fields.Core_IPS_Prod_Def_Case_Owner_ID__c.isUpdateable()) {
            prodObj.Core_IPS_Prod_Def_Case_Owner_ID__c = selectedQueue[0].Id;
            }   
        } else if(inputType=='User'){
            if(User.SobjectType.getDescribe().isQueryable()){
                selectedUser = [Select Id,Name from User where Id =: inputString];
            }
            //Commented by Nuthana-As part of Vulnerability fixes - 19-08-2026
            //if (Schema.sObjectType.Core_IPS_Product__c.fields.Core_IPS_Prod_Default_Case_Owner__c.isUpdateable()) {
            prodObj.Core_IPS_Prod_Default_Case_Owner__c = selectedUser[0].Name;
            //}
            
            if (Schema.sObjectType.Core_IPS_Product__c.fields.Core_IPS_Prod_Def_Case_Owner_ID__c.isUpdateable()) {   
            prodObj.Core_IPS_Prod_Def_Case_Owner_ID__c = selectedUser[0].Id;  
            }   
        }
        try {
            
            if(Schema.sObjectType.Core_IPS_Product__c.isUpdateable()){
            update prodObj;
            }
            /*END Niyaz -- 12/06/2025 */
            return 1;
        } catch(Exception e){
        }
        return 2;
    }
    @AuraEnabled(cacheable= true)
    public static Boolean userDetails(Id userId){
        User u = [SELECT Core_User_Profile_Name__c FROM  User WHERE Id=:userId];
        if(u.Core_User_Profile_Name__c == 'Sales Rep-BB'||u.Core_User_Profile_Name__c =='Sales Rep-BB-Dual IPS')
            return true;
        else
            return false;
    }
    @AuraEnabled
    public static Integer projSubmit(Id projectId){
        core_ips_project__c project;
        if(core_ips_project__c.SObjectType.getDescribe().isAccessible()){
            project = [select id, Name, core_status__c, Core_Number_of_Accounts__c, Core_Number_of_Products__c,Core_Number_of_Users__c, (Select id,Status__c,Core_IPS_IsAutoApprove__c, Core_Supported_Product__c, Core_Supported_Product__r.Core_Flag_Status__c, Core_IPS_Project__c,Core_IsSubmitted_Header__c from IPS_Products__r) from core_ips_project__c where id=:projectId];        
        }
        if(project.core_status__c=='Submitted Pending' || project.core_status__c=='Active'){
            return 1;
        }
        if(project.core_status__c=='Draft' && (project.Core_Number_of_Accounts__c == 0 || project.Core_Number_of_Products__c ==0 || project.Core_Number_of_Users__c == 0)){
            return 2;
        }
        Boolean alreadySubmitted = false;
        if (Schema.sObjectType.core_ips_project__c.fields.core_status__c.isUpdateable()) {
            project.core_status__c = 'Submitted Pending';
        }
        update project;
        List<Core_IPS_Product__c> updateIPSProductList = new List<Core_IPS_Product__c>();
        for(Core_IPS_Product__c iPSProductRecord: project.IPS_Products__r){
            IPSProductRecord.Core_IsSubmitted_Header__c = true;
            if(IPSProductRecord.Core_Supported_Product__r.Core_Flag_Status__c == 'Auto Approve'){
                IPSProductRecord.Core_IPS_IsAutoApprove__c = true;
                IPSProductRecord.Status__c = 'Auto Approve';
            }
            UpdateIPSProductList.add(IPSProductRecord);
        }        
        update UpdateIPSProductList;  
        return 3;
    }
    @AuraEnabled(cacheable= true)
    public static List<Core_IPS_Project__c> getRecordDetail(Id projectId){
        List<Core_IPS_Project__c> projectRec = new List<Core_IPS_Project__c>();
        if(Core_IPS_Project__c.SObjectType.getDescribe().isQueryable()) {
            projectRec =[select Id,Name,Owner.Name,Core_MPNDA__c,Core_Status__c,Core_Project_Description__c,Core_IPS_Support_Level__c,Core_IPS_Intel_Support_Owner__r.Name,Region__c,Core_IPS_Partner_Support_Owner__r.Name,Sub_Region__c,Core_IPS_EnableMemberasInterestedParties__c,Core_IPS_Remove_Notification_Details__c,Core_IPS_Enable_ISTasInterested_Parties__c,Core_IPS_Project_ID__c,Core_IPS_Legacy_Collab_Team_ID__c,Core_IPS_GroupId__c from Core_IPS_Project__c where id=:projectId];  
        }
        if(!projectRec.isEmpty()) {
            return projectRec;         
        }
        return null;
    }
    
}