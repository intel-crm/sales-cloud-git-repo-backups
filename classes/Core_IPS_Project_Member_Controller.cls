/*
Cretaed By:G.Krishnareddy G
Description :We need to display IPS Project Member information based on ProjectID,IPS Project Account information.
*/

Public with sharing class Core_IPS_Project_Member_Controller{ // added with sharing by tushar for vanuability changes--- Also change class public to global
    
    //IPSMemberWrapper 
    public class IPSMemberWrapper implements Comparable {
        public string conFirstName;
        public string conLastName;
        public string accountName;
        public contact conObj;
        public boolean selected; 
        public User user;
        
        public Integer compareTo(Object o) {
            IPSMemberWrapper  that = (IPSMemberWrapper) o;
            if (this.conObj.FirstName==null || this.conObj.FirstName==null){ return -1; }
            else if(this.conObj.FirstName<that.conObj.FirstName) { return -1; }
            
            else{return 1;}
        }
    }
    
    //Query the existing project Member info.
    public static set < string > existingIPSContIds(string projectId) {
        set < string > existingIPSContIdsInfo = new set < string > ();
        //FLS Check Added - Nishitha
        if(Core_IPS_Project_Member__c.SObjectType.getDescribe().isAccessible()){
            for (Core_IPS_Project_Member__c objCoreIpsContact: [select id, name, Core_IPS_Contact__r.firstname, Core_IPS_Contact__r.lastname, core_ips_contact__c from Core_IPS_Project_Member__c where core_ips_project__c =: projectId and Core_Selective_Member__c = true]) {
                existingIPSContIdsInfo.add(objCoreIpsContact.core_ips_contact__c);
            }
        }
        return existingIPSContIdsInfo;
    }
    
    //Display current Project Having the Core IPS Account have the Member status as Selective those IPS Project Contacts have to select the page.
    public static List < Core_ips_account__c > getSelectiveAccounts(String projectId) {
        List < Core_ips_account__c > ipsAcctList;
        //FLS Check Added - Nishitha
        if(core_ips_account__c.SObjectType.getDescribe().isAccessible()){
            ipsAcctList = [select id, core_account__c from core_ips_account__c where core_ips_project__c =: projectId and core_members__c = 'Selective'];
        }
        return ipsAcctList;
        
    }
    
    
    
    //Display the Current IPS Project Account having the IPS Project Member Information for JSREMOTING.
    public static string getlstProjectMemberWrapperInfo() {
        List < IPSMemberWrapper > wrapperInContext = new List < IPSMemberWrapper > ();
        List < Core_ips_account__c > ipsAcctList = new List < core_ips_account__c > ();
        ipsAcctList = getSelectiveAccounts(apexpages.currentpage().getparameters().get('projectId').escapeHtml4());
        Set < Id > selActSet = new Set < Id > ();
        set < string > existingConIdSet = existingIPSContIds(apexpages.currentpage().getparameters().get('projectId').escapeHtml4());
        for (Core_ips_account__c ipsAct: ipsAcctList) {
            selActSet.add(ipsAct.core_account__c);
        }
        List < contact > contList;
        List < User > userList;
        //string QueryString = 'select id, firstName, lastName, account.name from contact where Core_IPS_Active__c = true and accountId in:  \'' + selActSet + '\'';
        //FLS Check Added - Nishitha
        if(Contact.SObjectType.getDescribe().isAccessible()){
            if (existingConIdSet != null && existingConIdSet.size() > 0) {
                contList = [select id, firstName, lastName, account.name from contact where Core_IPS_Active__c = true and accountId in:selActSet and id not in:existingConIdSet];
            } else{
                //FLS Check Added - Nishitha
                if(Contact.SObjectType.getDescribe().isAccessible()){
                    contList = [select id, firstName, lastName, account.name from contact where Core_IPS_Active__c = true and accountId in:selActSet];
                }
            }
        }
        
        //contList  = database.query(QueryString);
        map < id, User > mapofContactInfoWithUserDetails = new map < id, User > ();
        
        if (contList <> null && contList.size() > 0) {
            for (User objUser: [Select id, contactid from User where Contactid IN: contList and IsActive = true]) {
                mapofContactInfoWithUserDetails.put(ObjUser.ContactId, ObjUser);
            }
        }
        for (Contact con: contList) {
            
            IPSMemberWrapper wrapper = new IPSMemberWrapper();
            wrapper.selected = false;
            wrapper.conObj = con;
            wrapper.conFirstName = con.firstName;
            wrapper.conLastName  = con.LastName;
            wrapper.accountName  = con.account.Name;
            if (mapofContactInfoWithUserDetails!=null && mapofContactInfoWithUserDetails.ContainsKey(con.id)) {
                wrapper.user = mapofContactInfoWithUserDetails.get(con.id);
                
                
            }
            wrapperInContext.add(wrapper);
        }
        
        wrapperInContext.sort();
        return JSON.serialize(wrapperInContext);
    }
    
    //Getting the existing IPS Project Members information for JSREMOTING.
    public static string getlstExistingProjectMembers(){
        
        list<Core_IPS_Project_Member__c>  existingMembers = [select id, name,Core_IPS_Contact__r.firstname,Core_IPS_Contact__r.lastname, core_ips_contact__c from Core_IPS_Project_Member__c where core_ips_project__c= :apexpages.currentpage().getparameters().get('projectId') and Core_Selective_Member__c = true];
        
        return JSON.serialize(existingMembers);
    }
    
    
    //All Selected Project Membres to insert the Data.
    // TO:
    // Changed by tushar for vanuability changes
    @RemoteAction
    public static string succuessProjectMembers(list<Core_IPS_Project_Member__c> lstProjectMemberInfo) {
        if (lstProjectMemberInfo == null || lstProjectMemberInfo.isEmpty()) return 'failed';
        
        Set<Id> projectIds = new Set<Id>();
        for (Core_IPS_Project_Member__c m : lstProjectMemberInfo) {
            if (m.Core_IPS_Project__c != null) projectIds.add(m.Core_IPS_Project__c);
        }
        
        Map<Id, UserRecordAccess> accessMap = new Map<Id, UserRecordAccess>();
        for (UserRecordAccess ura : [
            SELECT RecordId, HasEditAccess 
            FROM UserRecordAccess 
            WHERE UserId = :UserInfo.getUserId() AND RecordId IN :projectIds
        ]) {
            accessMap.put(ura.RecordId, ura);
        }
        
        List<Core_IPS_Project_Member__c> toInsert = new List<Core_IPS_Project_Member__c>();
        for (Core_IPS_Project_Member__c m : lstProjectMemberInfo) {
            UserRecordAccess ura = accessMap.get(m.Core_IPS_Project__c);
            if (ura == null || !ura.HasEditAccess) return 'exception';
            if (!Schema.sObjectType.Core_IPS_Project_Member__c.fields.Core_IPS_Project__c.isCreateable()) return 'failed';
            if (!Schema.sObjectType.Core_IPS_Project_Member__c.fields.Core_IPS_Contact__c.isCreateable()) return 'failed';
            if (!Schema.sObjectType.Core_IPS_Project_Member__c.fields.Core_User__c.isCreateable()) return 'failed';
            if (!Schema.sObjectType.Core_IPS_Project_Member__c.fields.Core_Status__c.isCreateable()) return 'failed';
            if (!Schema.sObjectType.Core_IPS_Project_Member__c.fields.Core_Selective_Member__c.isCreateable()) return 'failed';
            toInsert.add(m);
        }
        try {
            insert toInsert;
            return 'Success';
        } catch(Exception e) {
            return 'exception';
        }
    }
}