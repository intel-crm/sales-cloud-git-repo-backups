/**************************************************************************************
Apex Class Name : EPUM_ContactListView
Version     : 1.0 
Created Date: 28th may 2020
Description : Controller class to fetch all contact record of same role as logged in user from 1 PID 
* Modification Log :
* Developer                 Date                     Description
* ----------------------------------------------------------------------------
* Raushan                  28/04/2020             Original Version
*************************************************************************************/

public Without Sharing class EPUM_ContactListView {
    
    @AuraEnabled
    public static List<Contact> fetchContactListView(){
        
        String strListView = 'ListViewContact';
        DateTime dtSearchStart = datetime.now();
        
        //List<User> lstUserIntelAccountId = [SELECT Id, ContactId,Contact.Core_IPA_Partner_Role__c, Contact.AccountId,Core_IPA_One_Partner_Id__c FROM User WHERE Id = : UserInfo.getUserId()];
        List<User> lstUserIntelAccountId = [SELECT Id, ContactId,Contact.Core_IPA_PartnerRole__c, Contact.AccountId,Core_IPA_One_Partner_Id__c FROM User WHERE Id = : UserInfo.getUserId()];
        System.debug('lstUserIntelAccountId ='+lstUserIntelAccountId);
        
        String strOnePartnerId = lstUserIntelAccountId[0].Core_IPA_One_Partner_Id__c;
        //String strContactPartnerRole =lstUserIntelAccountId[0].Contact.Core_IPA_Partner_Role__c;
        String strContactPartnerRole =lstUserIntelAccountId[0].Contact.Core_IPA_PartnerRole__c;
        
        System.debug('strContactPartnerRole ='+strContactPartnerRole);
        System.debug('strOnePartnerId ='+strOnePartnerId);
        Set<Id> setEntIds = new Set<Id>();
        for(PRM_VXEnttlmntMatrix__c vxe: [SELECT PRM_IPA_Partner_Role_Nm__c,PRM_Approval_Type_Nm__c,PRM_Entitlement_Id__c FROM PRM_VXEnttlmntMatrix__c WHERE PRM_IPA_Partner_Role_Nm__c=:strContactPartnerRole AND PRM_Approval_Type_Nm__c='Manual']){
                setEntIds.add(vxe.PRM_Entitlement_Id__c);
        }
        
        
        List<Contact> lstPC = new List<Contact>();
        List<Contact> lstPCd = new List<Contact>();
        List<Contact> lstWorksFor = new List<Contact>();
        List<Contact> lstAllContacts = new List<Contact>();
        for(Contact con: [SELECT Id,Name,Email,Phone, (SELECT Id,Core_Entitlement_Id__r.Name,Core_Entitlement_Id__c FROM 
                                                       Contact_Entitlements__r WHERE Core_Selected__c =true AND Core_Status__c ='Complete' 
                                                       AND Core_Entitlement_Id__c IN:setEntIds ),(SELECT PRM_Relationship_Id__r.Name FROM 
                                                       Account_Contact_Relationships__r) FROM contact WHERE Core_IPA_One_Partner_Id__c=:strOnePartnerId 
                                                       AND Core_IPA_PartnerRole__c=:strContactPartnerRole /*AND Id IN:setWorksForCon*/]){
            system.debug('con__>'+con);
            System.debug('con.Account_Contact_Relationships__r[0].PRM_Relationship_Id__r.Name====='+con.Account_Contact_Relationships__r[0].PRM_Relationship_Id__r.Name);
            if(con.Account_Contact_Relationships__r[0].PRM_Relationship_Id__r.Name == 'Works For') {
                lstWorksFor.add(con);
            } else if (con.Account_Contact_Relationships__r[0].PRM_Relationship_Id__r.Name == 'Primary Contact') {
                lstPC.add(con);
            } else if (con.Account_Contact_Relationships__r[0].PRM_Relationship_Id__r.Name == 'Primary Contact Delegate') {
                lstPCd.add(con);
            }
        }
        lstAllContacts.addAll(lstPC);
        lstAllContacts.addAll(lstPCd);
        lstAllContacts.addAll(lstWorksFor);
        System.debug('lstPC'+lstPC);
        System.debug('lstPCd'+lstPCd);
        System.debug('lstWorksFor'+lstWorksFor);
        System.debug('lstAllContacts'+lstAllContacts);
        return lstAllContacts;
        
    }
    
    @AuraEnabled
    public static void insertEpumLog(){
            String strListView = 'ListViewContact';
            DateTime dtSearchStart = datetime.now();
            EPUM_Log__c epumLog1 = EPUM_Utility.createEPUMLogs(strListView,'Yes',dtSearchStart,'');
            Database.insert(epumLog1);
        }
    
    }