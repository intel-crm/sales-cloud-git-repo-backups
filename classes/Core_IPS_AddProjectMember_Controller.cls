/**************************************************************************************************
Apex Class Name :  Core_IPS_AddProjectMember_Controller
Description     :  Display IPS Project Member information based on ProjectID,IPS Project Account information.
Modification Log :
* Developer                             Date                   Description
* ----------------------------------------------------------------------------                 
* G.Krishnareddy G                                             Created
* Amritesh                              11/10/2017             Modified - optimized
* Sugandha                              19/04/2018             Modified(User Story# US102846 Iteration# 10)
*****************************************************************************************************/


global with sharing class Core_IPS_AddProjectMember_Controller { 
    
    Public Boolean isError{get;set;}
    Public String errorMsg{get;set;}
    
    public Core_IPS_AddProjectMember_Controller() {
        String projectId = ApexPages.currentPage().getParameters().get('projectId').escapeHtml4();
            
        isError = false;
        if(String.isNotBlank(projectId)) {
            Boolean hasEditAccess = Core_IPS_Project_Controller.hasProjectEditAccess(string.escapeSingleQuotes(projectId), UserInfo.getUserId());
            if(!hasEditAccess) {
                errorMsg='You do not have permission to Add Project Member';
                isError = true;
            }
        }
    }
 
    //IPSMemberWrapper 
    public class IPSMemberWrapper implements Comparable {
        public string conFirstName;
        public string conLastName;
        public string conEmail;         //added by Aayushi US119231
        public string accountName;
        public string contactId;
        public contact conObj;
        public boolean selected; 
        public User user;
        
         public Integer compareTo(Object o) {
            IPSMemberWrapper  that = (IPSMemberWrapper) o;
            if (this.conObj.FirstName==null || this.conObj.FirstName==null) {return -1 ;}
            else if(this.conObj.FirstName<that.conObj.FirstName) {return -1;}
            
            else{return 1;}
        }
    }
    
    //Query the existing project Member info.
    public static Set<string> existingIPSContIds(string projectId) {
        Set<string> existingIPSContIdsInfo = new Set<string>();
        //FLS Check added - Yasasvi
        if(Core_IPS_Project_Member__c.SObjectType.getDescribe().isAccessible()){
        for (Core_IPS_Project_Member__c objCoreIpsContact: [select id, name, Core_IPS_Contact__r.firstname, Core_IPS_Contact__r.lastname, core_ips_contact__c from Core_IPS_Project_Member__c where core_ips_project__c =: projectId]) {
            existingIPSContIdsInfo.add(objCoreIpsContact.core_ips_contact__c);
        }
        }
        return existingIPSContIdsInfo;
    }
    
    //Display current Project Having the Core IPS Account have the Member status as Selective those IPS Project Contacts have to select the page.
    public static List <Core_ips_account__c> getSelectiveAccounts(String projectId) {
        List <Core_ips_account__c> ipsAcctList;
        //FLS Check added - Yasasvi
        if(Core_ips_account__c.SObjectType.getDescribe().isAccessible()){
         ipsAcctList = new List <Core_ips_account__c>([select id, core_account__r.OwnerId, core_account__c from core_ips_account__c where core_ips_project__c =: projectId and (core_members__c = 'Selective' OR core_members__c = 'All')]);
        }
        return ipsAcctList;
    }
    
    //Display the Current IPS Project Account having the IPS Project Member Information for JSREMOTING.
    public static string getlstProjectMemberWrapperInfo() {
        set<Id> setAccTeamIds = new set<Id>();
        List <IPSMemberWrapper> wrapperInContext = new List <IPSMemberWrapper> ();        
        String projectId = ApexPages.currentPage().getParameters().get('projectId').escapeHtml4();
      
        List <Core_ips_account__c> ipsAcctList = getSelectiveAccounts(projectId);
        Set <Id> selActSet = new Set <Id> ();
        set <String> existingConIdSet = existingIPSContIds(projectId);    
        for (Core_ips_account__c ipsAct: ipsAcctList) {
            selActSet.add(ipsAct.core_account__c); 
            //PRB000094949 - if user is owner on account, should able to add contact of the account as memeber on project
            if(ipsAct.core_account__r.OwnerId == userinfo.getUserId()){
                setAccTeamIds.add(ipsAct.core_account__c);        
            }
        }

        //In case of FAE only those contacts should be vailable where FAE is Account Team Member added by Sugandha for US102846
        if(System.Label.Core_IPS_SalesRep_Profile_Ids.Contains(String.ValueOf(userinfo.getProfileId()).substring(0,15))){ 
            //FLS Check added - Yasasvi
            if(AccountTeamMember.SObjectType.getDescribe().isAccessible()){
            for(AccountTeamMember accteam : [Select Id, AccountId From AccountTeamMember WHERE UserId =:UserInfo.getUserId() AND AccountId IN: selActSet]){
                setAccTeamIds.add(accteam.AccountId); 
            }
            }
            //added Contact.Email field in query by Aayushi US119231
            for (User objUser : [Select id, contactid, Contact.FirstName,Contact.LastName,Contact.Email, Contact.Account.Name from User where Contact.Core_IPS_Active__c=true and IsActive=true AND AccountId IN :setAccTeamIds AND ContactId NOT IN :existingConIdSet ORDER BY Contact.Name ASC]) {           
                IPSMemberWrapper wrapper = new IPSMemberWrapper();
                wrapper.selected = false;
                wrapper.conFirstName = objUser.Contact.firstName;
                wrapper.conLastName  = objUser.Contact.LastName;
                wrapper.conEmail= objUser.Contact.Email;                //added by Aayushi US119231
                wrapper.accountName  = objUser.Contact.account.Name;
                wrapper.contactId  = objUser.contactId;
                wrapper.user = objUser;
                wrapperInContext.add(wrapper);
            }
        }
        //end
        
        //List <contact> contList;
        //List <User> UserList;
        //string QueryString = 'select id, firstName, lastName, account.name from contact where Core_IPS_Active__c = true and accountId in:  \'' + selActSet + '\'';
        /*if (existingConIdSet != null && existingConIdSet.size() > 0) {
           contList = [select id, firstName, lastName, account.name from contact where Core_IPS_Active__c = true and accountId in:selActSet and id not in:existingConIdSet];
        } else{
          contList = [select id, firstName, lastName, account.name from contact where Core_IPS_Active__c = true and accountId in:selActSet];
        }*/
        
        //contList  = database.query(QueryString);
        /*Map<Id,User> mapofContactInfoWithUserDetails = new Map<Id,User>();

        if (contList <> null && contList.size() > 0) {
            for (User ObjUser: [Select id, contactid,  from User where Contactid IN: contList and IsActive = true]) {
                mapofContactInfoWithUserDetails.put(ObjUser.ContactId, ObjUser);
            }
        }*/
        else{
            //added Contact.Email field in query by Aayushi US119231
            for (User objUser : [Select id, contactid, Contact.FirstName,Contact.LastName,Contact.Email, Contact.Account.Name from User where Contact.Core_IPS_Active__c=true and IsActive=true AND AccountId IN :selActSet AND ContactId NOT IN :existingConIdSet ORDER BY Contact.Name ASC]) {           
                IPSMemberWrapper wrapper = new IPSMemberWrapper();
                wrapper.selected = false;
                //wrapper.conObj = new Contact();
                wrapper.conFirstName = objUser.Contact.firstName;
                wrapper.conLastName  = objUser.Contact.LastName;
                wrapper.conEmail= objUser.Contact.Email;            //added Contact.Email field by Aayushi US119231
                wrapper.accountName  = objUser.Contact.account.Name;
                wrapper.contactId  = objUser.contactId;
                //if (mapofContactInfoWithUserDetails!=null && mapofContactInfoWithUserDetails.ContainsKey(con.id)) {
                wrapper.user = objUser;
                //}
                wrapperInContext.add(wrapper);
            }
        }
        wrapperInContext.sort();
        return JSON.serialize(wrapperInContext);
    }
    
    //Getting the existing IPS Project Members information for JSREMOTING.
    public static string getlstExistingProjectMembers() {   
        //added Contact.Email field in query by Aayushi US119231
        List<Core_IPS_Project_Member__c>  existingMembers = new List<Core_IPS_Project_Member__c>([select id, name,core_ips_contact__c,Core_IPS_Contact__r.firstname,Core_IPS_Contact__r.lastname,Core_IPS_Contact__r.Email,Core_IPS_Contact__r.Account.Name from Core_IPS_Project_Member__c where core_ips_project__c= :apexpages.currentpage().getparameters().get('projectId') and Core_Selective_Member__c = true ORDER BY Core_IPS_Contact__r.Name ASC]);
        return JSON.serialize(existingMembers);
    }
    
    
    //All Selected Project Membres to insert the Data.
    @RemoteAction
    global static string insertProjectMembers(List<Core_IPS_Project_Member__c> lstProjectMemberInfo){
        if(lstProjectMemberInfo<>null){
            try{
                Map<Id,Core_IPS_Project_Member__c> mapUserId2ProjectMember = new Map<Id,Core_IPS_Project_Member__c>();
                for(Core_IPS_Project_Member__c objProjMember : lstProjectMemberInfo) {
                    mapUserId2ProjectMember.put(objProjMember.Core_User__c, objProjMember);
                }
                //insert lstProjectMemberInfo; 
                insert mapUserId2ProjectMember.values();
                return 'Success';       
            }
            Catch(Exception ex){return ex.getMessage(); 
            }
        }
        else{ return null; }
    }

}