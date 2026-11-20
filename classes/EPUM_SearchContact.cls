/**************************************************************************************
Apex Class Name : EPUM_SearchContact
Version     : 1.0 
Created Date: 20th March 2020
Description : Controller class to retrieve the Contact information based on Email
* Modification Log :
* Developer                 Date                     Description
* ----------------------------------------------------------------------------
* Vaibhav                  20/03/2020             Original Version
* Manikanta           24/04/2020          Version 2
* Akshay                   22/11/2021             Draco Change for restricting invites to pending registration request approval contacts
*************************************************************************************/

public without sharing class EPUM_SearchContact {
    Public static final String strCompleteStatus = 'Complete';
    Public static final String strPendingActionStatus = 'Pending Action';
    Public static final String strPartnerAdminName = 'Partner Admin';
    public static Boolean IS_CIDAAS_ENABLED = !Test.isRunningTest()?Boolean.valueof(Label.PRM_CiDaaS_Enabled):True;
    
    @AuraEnabled
    public static WrapperContactDetails searchContactByEmail(String searchKeyWord, string userId){
        
        String strLoggedUserId = userId;
        String strSearchedEmailText = searchKeyWord;
        DateTime dtSearchStart = datetime.now();
        String strEMPRelationshipName = 'WORKSFOR';
        //Epum log related strings
        String strActionSalesCRMSearch = 'SalesCRMSearch';
        String strActionOPIDSearch = 'OPIDSearch';
        String strActionPartnerRoleSearch = 'PartnerRoleSearch';
        String strActionContactStatusSearch = 'ContactStatusSearch';
      //  Map<string,string> mapEPUMConstants = fetchEPUMConstants();

        List<EPUM_Log__c > lstEpumLogs = new List<EPUM_Log__c >();
        
        WrapperContactDetails wrapContactDetailsObj = new WrapperContactDetails();
        //wrapContactDetailsObj.mapEPUMConstants = fetchEPUMConstants();
        List<User> lstLoggedInUser = [SELECT Id, ContactId, Contact.AccountId,Contact.Core_IPA_PartnerRole__c, Core_IPA_One_Partner_Id__c, Contact.Account.Core_Geo__c FROM User WHERE Id = : strLoggedUserId];
        System.debug('lstLoggedInUser ==='+lstLoggedInUser[0].Contact.Account.Core_Geo__c);
        if(lstLoggedInUser.size() > 0) {
        wrapContactDetailsObj.accGeo = lstLoggedInUser[0].Contact.Account.Core_Geo__c;
        }
        Set<Id> setEntIds = new Set<Id>();
       
            //for(PRM_VXEnttlmntMatrix__c vxe: [SELECT PRM_IPA_Partner_Role_Nm__c,PRM_Approval_Type_Nm__c,PRM_Entitlement_Id__c FROM PRM_VXEnttlmntMatrix__c WHERE PRM_IPA_Partner_Role_Nm__c =:lstLoggedInUser[0].Contact.Core_IPA_PartnerRole__c ]){
            //  setEntIds.add(vxe.PRM_Entitlement_Id__c);
            //}
        for(Core_Entitlement__c coreEnt : EPUM_ContactEntitlement_Util.getCoreEntitlements()){
            setEntIds.add(coreEnt.Id);
        }
			
        //Search for the contact in database
        
        List<Contact> lstContacts = [SELECT Id, Email,Core_Login_Status__c,Core_Enterprise_Id__c, Phone, Name, FirstName, LastName, AccountId, Account.Name, Account.Core_IPA_Partner_Role__c, Core_IPA_One_Partner_Id__c, Core_IPA_PartnerRole__c,(SELECT Id,PRM_Relationship_Id__r.Name,PRM_Relationship_Id__r.PRM_Contact_Relationship_Cd__c,PRM_Status_Nm__c, PRM_InActive_Ind__c FROM Account_Contact_Relationships__r WHERE PRM_Relationship_Id__r.PRM_Contact_Relationship_Cd__c =: strEMPRelationshipName), (SELECT Id,Core_Entitlement_Id__r.Name,Core_Entitlement_Id__c, Core_Entitlement_Id__r.Core_Display_Name__c FROM Contact_Entitlements__r WHERE Core_Selected__c =true AND Core_Status__c =:strCompleteStatus AND ( Core_Entitlement_Id__c IN:setEntIds OR Core_Entitlement_Id__r.Name =: strPartnerAdminName ) ORDER BY Core_Entitlement_Id__r.Name ) FROM Contact WHERE Email =: strSearchedEmailText];
        /*List<PRM_AccountChannelMembership__c> lstACM = new List<PRM_AccountChannelMembership__c>([SELECT PRM_Partner_Role__c from PRM_AccountChannelMembership__c where PRM_Account_Id__c =:lstContacts[0].AccountId]);
        List<String> lstActRole = new List<String>();
        for(PRM_AccountChannelMembership__c acctChannelRec :lstACM){
            lstActRole.add(acctChannelRec.PRM_Partner_Role__c);
        }*/
        if(lstContacts.size() > 0) {
            List<PRM_AccountChannelMembership__c> lstACM = new List<PRM_AccountChannelMembership__c>([SELECT PRM_Partner_Role__c from PRM_AccountChannelMembership__c where PRM_Account_Id__c =:lstContacts[0].AccountId AND PRM_Status_Nm__c = 'Approved']);
        List<String> lstActRole = new List<String>();
        for(PRM_AccountChannelMembership__c acctChannelRec :lstACM){
            lstActRole.add(acctChannelRec.PRM_Partner_Role__c);
        }
            wrapContactDetailsObj.isContactExistsinDB = true;
            //call log entry method
           	EPUM_Log__c epumLog1 = EPUM_Utility.createEPUMLogs(strActionSalesCRMSearch,'Yes',dtSearchStart,strSearchedEmailText);  
            lstEpumLogs.add(epumLog1);

        // *** DRACO - Error message on searching for Deleted/Expired/Disabled Contacts - start ***//
            //if(/*(lstContacts[0].Core_Login_Status__c == 'Deleted'|| lstContacts[0].Core_Login_Status__c == 'Disabled'|| lstContacts[0].Core_Login_Status__c == 'Expired') && */lstContacts[0].Core_Enterprise_Id__c == null) { //subhadeep change for soft contacts
               //wrapContactDetailsObj.isContactDeleted = true;
            //}
       // *** DRACO - Error message on searching for Deleted/Expired/Disabled Contacts - end ***// 
//subhadeep change start
        if(lstContacts[0].Account_Contact_Relationships__r.size() > 0 && lstContacts[0].Account_Contact_Relationships__r[0].PRM_InActive_Ind__c == false 
       && lstContacts[0].Account_Contact_Relationships__r[0].PRM_Status_Nm__c == strCompleteStatus){
           wrapContactDetailsObj.acrActive = true;
       }
//subhadeep change end
            if(((lstContacts[0].Core_IPA_One_Partner_Id__c == lstLoggedInUser[0].Core_IPA_One_Partner_Id__c && lstContacts[0].Core_IPA_One_Partner_Id__c != null && lstLoggedInUser[0].Core_IPA_One_Partner_Id__c != null) || (lstLoggedInUser[0].Contact.AccountId == lstContacts[0].AccountId)))
             {

                wrapContactDetailsObj.contactDetails = lstContacts[0];//contact details for only deleted contact..newly added
                if(lstContacts[0].Core_Enterprise_Id__c == null && lstActRole.contains(lstLoggedInUser[0].Contact.Core_IPA_PartnerRole__c)) { //subhadeep change for soft contacts
                    wrapContactDetailsObj.isContactDeleted = true;
                }
                
                //call log entry method
                EPUM_Log__c epumLog2 = EPUM_Utility.createEPUMLogs(strActionOPIDSearch,'Yes',dtSearchStart,strSearchedEmailText);
                lstEpumLogs.add(epumLog2);
                
                wrapContactDetailsObj.isContactExistsinOnePartnerAcc = true;
                //subhadeep change start--non IPA user invite
                if((lstContacts[0].Account_Contact_Relationships__r.size() == 0 || (lstContacts[0].Account_Contact_Relationships__r.size() > 0 && lstContacts[0].Account_Contact_Relationships__r[0].PRM_InActive_Ind__c == True )) 
                && lstLoggedInUser[0].Contact.Core_IPA_PartnerRole__c != null /*&& lstContacts[0].Account.Core_IPA_Partner_Role__c != null && !lstContacts[0].Account.Core_IPA_Partner_Role__c.split(';').contains(lstLoggedInUser[0].Contact.Core_IPA_PartnerRole__c)*/ && !lstActRole.contains(lstLoggedInUser[0].Contact.Core_IPA_PartnerRole__c) ){
                wrapContactDetailsObj.isSendInvite = false;
                wrapContactDetailsObj.contactDetails = lstContacts[0];
                        wrapContactDetailsObj.strLoggedinUserAccId = lstLoggedInUser[0].Contact.AccountId;
                        wrapContactDetailsObj.strOnePartnerId = lstLoggedInUser[0].Core_IPA_One_Partner_Id__c;
                }
               
                //subhadeep change end
                               
                else if(lstLoggedInUser[0].Contact.Core_IPA_PartnerRole__c != null /*&& lstContacts[0].Core_IPA_PartnerRole__c != null*/ && lstActRole.contains(lstLoggedInUser[0].Contact.Core_IPA_PartnerRole__c)){                    
                    
                    
                    //call log entry method
                    EPUM_Log__c epumLog3 = EPUM_Utility.createEPUMLogs(strActionPartnerRoleSearch,'Yes',dtSearchStart,strSearchedEmailText);
                    lstEpumLogs.add(epumLog3);
                    
                    wrapContactDetailsObj.isContactExitssWithSameRole = true;
                    
                    if(lstContacts[0].Account_Contact_Relationships__r.size() > 0){
                        if(lstContacts[0].Account_Contact_Relationships__r[0].PRM_Status_Nm__c == strCompleteStatus &&
                          lstContacts[0].Account_Contact_Relationships__r[0].PRM_InActive_Ind__c == False){
                            wrapContactDetailsObj.isPendingContact = false;
                            wrapContactDetailsObj.contactDetails = lstContacts[0];
                            wrapContactDetailsObj.strLoggedinUserAccId = lstLoggedInUser[0].Contact.AccountId;
                            wrapContactDetailsObj.strOnePartnerId = lstLoggedInUser[0].Core_IPA_One_Partner_Id__c;
                            EPUM_Log__c epumLog5 = EPUM_Utility.createEPUMLogs(strActionContactStatusSearch,'Yes',dtSearchStart,strSearchedEmailText);
                            lstEpumLogs.add(epumLog5);
                        } else if (lstContacts[0].Account_Contact_Relationships__r[0].PRM_Status_Nm__c != strCompleteStatus &&
                            lstContacts[0].Account_Contact_Relationships__r[0].PRM_InActive_Ind__c == False){
                            wrapContactDetailsObj.isPendingContact = true;
                            EPUM_Log__c epumLog6 = EPUM_Utility.createEPUMLogs(strActionContactStatusSearch,'No',dtSearchStart,strSearchedEmailText);
                            lstEpumLogs.add(epumLog6);
                        } else if (lstContacts[0].Account_Contact_Relationships__r[0].PRM_InActive_Ind__c == True) {
                            wrapContactDetailsObj.isSendInvite = true;
                        	wrapContactDetailsObj.contactDetails = lstContacts[0];
                        	wrapContactDetailsObj.strLoggedinUserAccId = lstLoggedInUser[0].Contact.AccountId;
                        	wrapContactDetailsObj.strOnePartnerId = lstLoggedInUser[0].Core_IPA_One_Partner_Id__c;
                        }
                    } else {
                        //wrapContactDetailsObj.isPendingContact = true;
                        wrapContactDetailsObj.isSendInvite = true;
                        wrapContactDetailsObj.contactDetails = lstContacts[0];
                        wrapContactDetailsObj.strLoggedinUserAccId = lstLoggedInUser[0].Contact.AccountId;
                        wrapContactDetailsObj.strOnePartnerId = lstLoggedInUser[0].Core_IPA_One_Partner_Id__c;
                        //EPUM_Log__c epumLog6 = EPUM_Utility.createEPUMLogs(strActionContactStatusSearch,'No',dtSearchStart,strSearchedEmailText);
                        //lstEpumLogs.add(epumLog6);
                    }
                    
                } else if ((lstContacts[0].Account_Contact_Relationships__r.size() == 0 || (lstContacts[0].Account_Contact_Relationships__r.size() > 0 && lstContacts[0].Account_Contact_Relationships__r[0].PRM_InActive_Ind__c == True )) 
                           && lstLoggedInUser[0].Contact.Core_IPA_PartnerRole__c != null && /*lstContacts[0].Account.Core_IPA_Partner_Role__c != null &&*/ lstActRole.contains(lstLoggedInUser[0].Contact.Core_IPA_PartnerRole__c) ) { 
                    wrapContactDetailsObj.isSendInvite = true;
                    wrapContactDetailsObj.contactDetails = lstContacts[0];
                    wrapContactDetailsObj.strLoggedinUserAccId = lstLoggedInUser[0].Contact.AccountId;
                    wrapContactDetailsObj.strOnePartnerId = lstLoggedInUser[0].Core_IPA_One_Partner_Id__c;
                } else {
                    //contact Partner role mismatch
                    wrapContactDetailsObj.isContactExitssWithSameRole = false;
                    //call log entry method
                    EPUM_Log__c epumLog4 = EPUM_Utility.createEPUMLogs(strActionPartnerRoleSearch,'No',dtSearchStart,strSearchedEmailText);
                    lstEpumLogs.add(epumLog4);
                }
                
            } else {
                //contact one partner id mismatch 
                wrapContactDetailsObj.isContactExistsinOnePartnerAcc = false;
                //call log entry method
                EPUM_Log__c epumLog7 = EPUM_Utility.createEPUMLogs(strActionOPIDSearch,'No',dtSearchStart,strSearchedEmailText);
                lstEpumLogs.add(epumLog7);
            }
     
        } else {
            //Contact not found in database
            //Draco Change START [22-11-2021] for restricting invites to pending registration request approval contacts
            List<PRM_Registration_Request__c> regRequest = [SELECT Id FROM PRM_Registration_Request__c WHERE PRM_Email_ID__c =: strSearchedEmailText AND PRM_Status__c = 'New' AND PRM_Channel_Program_Level_txt__c = 'Intel Partner Alliance'];
            if(regRequest.size() > 0) {
                wrapContactDetailsObj.isExistingIPASelfRegistration = true;
                wrapContactDetailsObj.isContactExistsinDB = true;
            }
            else{
                wrapContactDetailsObj.isContactExistsinDB = false;
                //call log entry method
                EPUM_Log__c epumLog6 = EPUM_Utility.createEPUMLogs(strActionSalesCRMSearch,'No',dtSearchStart,strSearchedEmailText);
                lstEpumLogs.add(epumLog6);
            }
            //Draco Change END [22-11-2021] for restricting invites to pending registration request approval contacts
        }
        
        if(!lstEpumLogs.isEmpty()){
        	Database.insert(lstEpumLogs, false);
        }
        if(string.isNotBlank(searchKeyWord)){
           wrapContactDetailsObj.BlockedContact=PRM_AdminRegistration.getBlockedAccountContact(searchKeyWord,null);
        }
        
        return wrapContactDetailsObj;
    }

    /*public static Map<String,String> fetchEPUMConstants()
    {
        Map<String,String> mapEPUMConstants = new map<String,String>();
        for(EPUM_Constants__mdt EPUMConst:[SELECT EPUM_isActive_ind__c, EPUM_Value_txt__c, Label FROM EPUM_Constants__mdt WHERE EPUM_isActive_ind__c = TRUE])
        {
            mapEPUMConstants.put(EPUMConst.Label,EPUMConst.EPUM_Value_txt__c);        
        }
        return mapEPUMConstants;
        
    } */ 
    
    @AuraEnabled	
    public static WrapperPicklists fetchContactPickListValues(String searchedEmail) {
        String strActionInviteContact = 'InviteContact';
        DateTime dtSearchStart = datetime.now();
        
        WrapperPicklists wrapPicklists = new WrapperPicklists();
        //wrapPicklists.mapEPUMConstants = fetchEPUMConstants();
            
        List<WrapperPicklistSkeleton> lstCountryPicklistValues = new List<WrapperPicklistSkeleton>();
        List<WrapperPicklistSkeleton> lstPreferredLanguagePicklistValues = new List<WrapperPicklistSkeleton>();
        Map<String,Schema.SObjectType> mapGd = Schema.getGlobalDescribe(); 
        Map<String, Schema.SObjectField> mapFields = mapGd.get('Contact').getDescribe().fields.getMap();
        List<Schema.PicklistEntry> lstCountryPicklist = mapFields.get('MailingCountryCode').getDescribe().getPickListValues();  
        List<Schema.PicklistEntry> lstPreferredLanguagePicklist = mapFields.get('Core_Preferred_Language__c').getDescribe().getPickListValues(); 
        
        for (Schema.PicklistEntry pv : lstCountryPicklist) {
            lstCountryPicklistValues.add(new WrapperPicklistSkeleton(pv.getLabel(), pv.getValue()));
        }
        
        for (Schema.PicklistEntry pv : lstPreferredLanguagePicklist) {
            lstPreferredLanguagePicklistValues.add(new WrapperPicklistSkeleton(pv.getLabel(), pv.getValue()));
        }
        wrapPicklists.lstCountryValues = lstCountryPicklistValues;
        wrapPicklists.lstPreferredLanguageValues = lstPreferredLanguagePicklistValues;
        
        EPUM_Log__c epumLog = EPUM_Utility.createEPUMLogs(strActionInviteContact, 'Yes', dtSearchStart, searchedEmail);
        Insert epumLog;

        return wrapPicklists;
    }
    
    @AuraEnabled
    public static map<String,String> createContact(Contact con, String loggedInUserId){
        String strActionSendInvite = 'SendInvite';
        String strIntelContactRecType = 'Intel Contact';
        String strACRStatus = 'Pending Action';
        String strRelationshipName = 'WORKSFOR';
        DateTime dtSearchStart = datetime.now();
        
      
        List<User> lstLoggedInUser = [SELECT Id, ContactId, Contact.AccountId, Contact.Core_IPA_PartnerRole__c, Core_IPA_One_Partner_Id__c, Contact.Account.Core_User_Defined_Website__c, Contact.Account.BillingCountry, Contact.MailingCountry FROM User WHERE Id = : loggedInUserId];
      
        Map<String,String> mapResult = new Map<String,String>();

        if(lstLoggedInUser[0].Contact.Account.Core_User_Defined_Website__c != null && (lstLoggedInUser[0].Contact.Account.BillingCountry== null || !System.Label.PRM_Embargoed_country.contains(lstLoggedInUser[0].Contact.Account.BillingCountry)) && (lstLoggedInUser[0].Contact.MailingCountry == null || !System.Label.PRM_Embargoed_country.contains(lstLoggedInUser[0].Contact.MailingCountry))){
            try {
                Id idIntelAccRecId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(strIntelContactRecType).getRecordTypeId();
                con.AccountId = lstLoggedInUser[0].Contact.AccountId;
                con.Core_IPA_PartnerRole__c = lstLoggedInUser[0].Contact.Core_IPA_PartnerRole__c;
                con.RecordTypeId = idIntelAccRecId;
                Database.saveresult sr = database.Insert(con);
                
                List<PRM_ContactRelationships__c> lstPcr =[SELECT Id,Name,PRM_Contact_Relationship_Cd__c FROM PRM_ContactRelationships__c WHERE PRM_Contact_Relationship_Cd__c =: strRelationshipName ]; 
                if (!lstPcr.isEmpty()) {
                    PRM_Account_Contact_Relationship__c acr = new PRM_Account_Contact_Relationship__c();
                    acr.PRM_Account_Id__c = lstLoggedInUser[0].Contact.AccountId;
                    acr.PRM_Contact_Id__c = con.Id;
                    acr.PRM_Relationship_Id__c = lstPcr[0].Id;
                    acr.PRM_Status_Nm__c = strACRStatus;
                    acr.PRM_Status_Reason_Txt__c = 'External Invite';//TWC729-8089 : Adding reason text : NJ
                    Insert acr;
                }
                
                if(sr.isSuccess()){ 
                    EPUM_Log__c epumLog = EPUM_Utility.createEPUMLogs(strActionSendInvite, 'Yes', dtSearchStart, con.Email.toLowerCase());
                    Insert epumLog;
                }
                mapResult.put('status', 'success');
                mapResult.put('message', 'Invite sent successfully');  
            }
            catch (Exception e) {
                system.debug('error msg'+e);
                mapResult.put('status', 'error');
                mapResult.put('message', e.getMessage());
            }
        } else if(System.Label.PRM_Embargoed_country.contains(lstLoggedInUser[0].Contact.Account.BillingCountry) || System.Label.PRM_Embargoed_country.contains(lstLoggedInUser[0].Contact.MailingCountry) ){
            mapResult.put('status', 'error');
            mapResult.put('message', 'This registration was denied because the registrant identified their location as an embargoed country or their IP address is from an embargoed country.');
        }else if(lstLoggedInUser[0].Contact.Account.Core_User_Defined_Website__c == null ){
            mapResult.put('status', 'error');
            mapResult.put('message', 'Website is mandatory for extending invite');
        } 
        
        
        return mapResult;
    }

    
    @AuraEnabled
    public static Map<String,String> createACR (sObject contact, sObject acr){
        Contact con = (Contact)contact;
        PRM_Account_Contact_Relationship__c acrToUpdate = (PRM_Account_Contact_Relationship__c)acr;
        System.debug('contact = '+ contact);
        System.debug('acrToUpdate = '+ acrToUpdate);
        System.debug('acRelation = '+ acr);
        String strACRStatus = 'Pending Action';
        String strRelationshipName = 'WORKSFOR';
        Map<String,String> mapResult = new Map<String,String>();
        List<User> lstLoggedInUser = [SELECT Id, ContactId, Contact.AccountId, Contact.Core_IPA_PartnerRole__c, Core_IPA_One_Partner_Id__c FROM User WHERE Id = : UserInfo.getUserId()];
        try {
            if(con.Core_IPA_PartnerRole__c == null || con.Core_IPA_PartnerRole__c != lstLoggedInUser[0].Contact.Core_IPA_PartnerRole__c ) {
            	Contact updateCon = new Contact();
                updateCon.id = con.Id;
            	updateCon.Core_IPA_PartnerRole__c = lstLoggedInUser[0].Contact.Core_IPA_PartnerRole__c;
                update updateCon;
            }
            if(acrToUpdate != null && acrToUpdate.PRM_InActive_Ind__c == True) {
                PRM_Account_Contact_Relationship__c updateACR = new PRM_Account_Contact_Relationship__c();
                updateACR.PRM_Status_Nm__c = strACRStatus;
                updateACR.PRM_Status_Reason_Txt__c ='External Invite';//TWC729-8089 : Adding reason text : NJ
                updateACR.PRM_InActive_Ind__c = false;
                updateACR.id = acrToUpdate.Id;
                /*
                string conMail = con.Email.toLowerCase();
                string newEVToken = PRM_RetriggerEV_Token_API.reTriggerEV(conMail);

                If(con.Core_Do_Not_Contact__c == false && newEVToken != null){
                    List<string> emMsg = PRM_Contact_AGS_CallbackHandler.sendEmailToContact(con, newEVToken, conMail);
                }
                */
                update updateACR;
            } else {
                List<PRM_ContactRelationships__c> lstPcr =[SELECT Id,Name,PRM_Contact_Relationship_Cd__c FROM PRM_ContactRelationships__c WHERE PRM_Contact_Relationship_Cd__c =: strRelationshipName ]; 
                if (!lstPcr.isEmpty()) {
                    PRM_Account_Contact_Relationship__c insertACR = new PRM_Account_Contact_Relationship__c();
                    insertACR.PRM_Account_Id__c = con.AccountId;
                    insertACR.PRM_Contact_Id__c = con.Id;
                    insertACR.PRM_Relationship_Id__c = lstPcr[0].Id;
                    insertACR.PRM_Status_Nm__c = strACRStatus;
                    insertACR.PRM_Status_Reason_Txt__c='External Invite';//TWC729-8089 : Adding reason text : NJ
                    Insert insertACR;
                }
            }
        	mapResult.put('status', 'success');
            mapResult.put('message', 'Invite sent successfully');  
        }
        catch (Exception e) {
            system.debug('error msg'+e);
            mapResult.put('status', 'error');
            if(e.getMessage().contains(System.label.PRM_ACR_Error1)){
                mapResult.put('message',System.label.EPUM_isPendingContactMsg);
            }else{
                mapResult.put('message', e.getMessage());
            }
        }
        return mapResult;
    }
    //Added by Raushan
    @AuraEnabled(cacheable=true)
    public static WrapperCotactListView contactListView(){
        String strWFRelationCode = 'WORKSFOR';
        String strPARelationCode = 'PRIMARY';
        String strPADRelationCode = 'PRIMCONTDEL';
        WrapperCotactListView contactListViewWrapperObject = new WrapperCotactListView();
        List<String> IPADetachedEntList = string.isNotBlank(Label.EPUM_IPADetachEntitlements) ? Label.EPUM_IPADetachEntitlements.split(',') : null;
        
        List<User> lstUserIntelAccountId = [SELECT Id, ContactId,toLabel(Contact.Core_IPA_PartnerRole__c), Contact.AccountId,Core_IPA_One_Partner_Id__c FROM User WHERE Id = :UserInfo.getUserId()];//subhadeep change for country
		 //Added by raushan
		 String strOnePartnerId = lstUserIntelAccountId[0].Core_IPA_One_Partner_Id__c;
         String strContactPartnerRole = lstUserIntelAccountId[0].Contact.Core_IPA_PartnerRole__c;
         String strContactId = lstUserIntelAccountId[0].ContactId;
         String strAccuntId = lstUserIntelAccountId[0].Contact.AccountId;
        Set<Id> setEntIds = new Set<Id>();
        List<Core_Entitlement__c> coreEntNames = new List<Core_Entitlement__c>(EPUM_ContactEntitlement_Util.getCoreEntitlements());
      
        //for(PRM_VXEnttlmntMatrix__c vxe: [SELECT PRM_IPA_Partner_Role_Nm__c,PRM_Approval_Type_Nm__c,PRM_Entitlement_Id__c FROM PRM_VXEnttlmntMatrix__c WHERE PRM_IPA_Partner_Role_Nm__c =:strContactPartnerRole]){
           
          //    setEntIds.add(vxe.PRM_Entitlement_Id__c);
        //}
       	for(Core_Entitlement__c coreEnt : coreEntNames){
            setEntIds.add(coreEnt.Id);
        }
        //subhadeep change for country---START
        Map<string,string> countryMap = new Map<string,string>();
        for(Core_Country_Reference__c countryRec :Core_Country_Reference__c.getAll().values()){
            countryMap.put(countryRec.Core_ISO_Code__c, countryRec.name);
        }
        //subhadeep change for country---END
        
        
        List<Contact> lstPC = new List<Contact>();
        List<Contact> lstPCd = new List<Contact>();
        Set<Contact> lstWorksFor1 = new Set<Contact>();
        List<Contact> lstWorksFor2 = new List<Contact>();
        List<Contact> lstWorksFor3 = new List<Contact>();
        List<Contact> lstAllContacts = new List<Contact>();
		list<contact> lstNonIPAContacts = new list<Contact>();
		Map<Id,Contact> mapPADContacts = new Map<Id,Contact>();
		Map<Id,Contact> mapPAContacts = new Map<Id,Contact>();
        Integer rank = 0;
		Map<Integer , Contact> rankContactToDisplay = new Map<Integer,Contact>();
        List<Id> lstOfOPID = new list<Id>();

        // Akshay change START -----
        Set<Id> MPIRecordSet = new Set<Id>();
        set<Id> listOfOPIDsForMPI_Id = new Set<Id>();
        if(strOnePartnerId != null){
            for(PMP_OPID_MPI_Rel__c ListMPIs : [SELECT PMP_Marketing_Profile_Id__c FROM PMP_OPID_MPI_Rel__c WHERE PMP_One_Partner_ID__c =: strOnePartnerId AND Is_Active__c = true])
            MPIRecordSet.add(ListMPIs.PMP_Marketing_Profile_Id__c);
            if(MPIRecordSet != null){
                for(PMP_OPID_MPI_Rel__c listOfOPIDsForMPI : [SELECT PMP_One_Partner_ID__c FROM PMP_OPID_MPI_Rel__c WHERE PMP_Marketing_Profile_Id__c =: MPIRecordSet AND Is_Active__c = true])
                listOfOPIDsForMPI_Id.add(listOfOPIDsForMPI.PMP_One_Partner_ID__c);
            }
        }
            
        listOfOPIDsForMPI_Id.add(strAccuntId);
        listOfOPIDsForMPI_Id.add(strOnePartnerId);

        if(listOfOPIDsForMPI_Id.contains(null)){
            listOfOPIDsForMPI_Id.remove(null);
        }
        system.debug('List of OPID to be fetched: '+ listOfOPIDsForMPI_Id);
        // Akshay change END -----

        Map<Contact,List<Core_Contact_Entitlement__c /*Sobject*/>> mapContactToContactEnt = new Map<Contact,List<Core_Contact_Entitlement__c>>();
                                                           
       //Akshay (Draco) change - Added Core_Login_Status__c to query  
       //Added MailingCountry                                                    
       for(Contact con: [SELECT Id,MailingCountry,Name,Email,Phone, Core_IPA_One_Partner_Id__c, toLabel(Core_IPA_PartnerRole__c), (SELECT Id, LastLoginDate FROM Users), Account.Name,Mailing_Country_Region__c, Account.BillingCountry,
                                (SELECT Id,Core_Entitlement_Id__r.Name,Core_Entitlement_Id__c, Core_Entitlement_Id__r.Core_Display_Name__c FROM Contact_Entitlements__r 
                                WHERE Core_Selected__c =true AND Core_Status__c =: strCompleteStatus AND (Core_Entitlement_Id__c IN:setEntIds OR Core_Entitlement_Id__r.Core_Display_Name__c =: strPartnerAdminName ) ORDER BY Core_Entitlement_Id__r.Core_Display_Name__c),
                                (SELECT Id,PRM_Status_Nm__c, PRM_InActive_Ind__c, PRM_Relationship_Id__r.Name, PRM_Relationship_Id__r.PRM_Contact_Relationship_Cd__c FROM Account_Contact_Relationships__r) 
                                FROM contact WHERE ((Core_Login_Status__c = 'Active' OR Core_Login_Status__c = null) AND Core_Enterprise_Id__c != null) AND Core_IPA_PartnerRole__c != NULL AND
                                ((Core_IPA_One_Partner_Id__c =: listOfOPIDsForMPI_Id AND Core_IPA_One_Partner_Id__c != NULL) OR AccountId =: strAccuntId) AND
                                Id IN (SELECT PRM_Contact_Id__c FROM PRM_Account_Contact_Relationship__c WHERE /* PRM_Status_Nm__c =: strCompleteStatus AND */ PRM_Relationship_Id__r.PRM_Contact_Relationship_Cd__c =: strWFRelationCode AND PRM_InActive_Ind__c = false) ORDER BY Name]){  
		
            if(con.Core_IPA_One_Partner_Id__c == strOnePartnerId && con.Core_IPA_PartnerRole__c == strContactPartnerRole){
                if(con.Contact_Entitlements__r.size() > 0){
                    for(Core_Contact_Entitlement__c conEnt: con.Contact_Entitlements__r){				
                    if(conEnt.Core_Entitlement_Id__r.Name == 'Partner Admin'){
                        mapPAContacts.put(con.Id,con);
                        System.debug('Partner Admin Contact: ==='+con);
                        break;
                    }else if(conEnt.Core_Entitlement_Id__r.Name =='Partner Admin Delegate'){
                        mapPADContacts.put(con.Id,con);
                        System.debug('Partner Admin Deligate Contact: ==='+con);
                        break;
                    }else if(conEnt.Core_Entitlement_Id__r.Name =='Employee' || IPADetachedEntList.contains(conEnt.Core_Entitlement_Id__r.Name)){
                        if(!mapPADContacts.containsKey(con.Id)){
                            lstWorksFor1.add(con);
                            System.debug('Employee Contact: ==='+con);
                            }
                        }
                    }
                }
                if(con.Contact_Entitlements__r.isEmpty()){
                    lstWorksFor1.add(con);
                    System.debug('No Entitlements Contact: ==='+con);
                }
            } else if(con.Core_IPA_One_Partner_Id__c == strOnePartnerId && con.Core_IPA_PartnerRole__c != strContactPartnerRole){
                lstWorksFor2.add(con);
                System.debug('Same OPID and non-matching Partner Role Contact: ==='+con);
            } else{
                lstWorksFor3.add(con);
                System.debug('Non-matching OPID and Partner Role Contact: ==='+con);
            }

            if(con.Core_IPA_One_Partner_Id__c != null){
                lstOfOPID.add(con.Core_IPA_One_Partner_Id__c);
            }
		}
        lstOfOPID.add(strAccuntId);
		lstAllContacts.addAll(mapPAContacts.values());
        lstAllContacts.addAll(mapPADContacts.values());
        
		for(contact c: lstWorksFor1){
			if(!mapPAContacts.containsKey(c.Id) && !mapPADContacts.containsKey(c.Id)){
				lstAllContacts.add(c);
			}			
		}
		lstAllContacts.addAll(lstWorksFor2);
        lstAllContacts.addAll(lstWorksFor3);
        // Country should be contact country instead of Account Billing country on manage personal page on bulk invite
        for(Contact fetContactRec :lstAllContacts){
            if(countryMap.get(fetContactRec.MailingCountry) != null){
                fetContactRec.MailingCountry = countryMap.get(fetContactRec.MailingCountry);
            }
        }
        //Subhadeep change for country---START
        List<Id> acctIds = new List<Id>();
        for(Contact fetContactRec :lstAllContacts){
            system.debug(fetContactRec.Account.BillingCountry);
            system.debug(countryMap.get(fetContactRec.Account.BillingCountry));
            system.debug(fetContactRec.Account.name);
            if(countryMap.get(fetContactRec.Account.BillingCountry) != null){
                
                fetContactRec.Account.BillingCountry = countryMap.get(fetContactRec.Account.BillingCountry);
            	acctIds.add(fetContactRec.Account.Id);
            }
			system.debug(fetContactRec.Account.BillingCountry);            
            
        }
        //Subhadeep change for country---END
        contactListViewWrapperObject.lstContactToReturn = lstAllContacts;
        contactListViewWrapperObject.contactPartnerRole = [SELECT Id, ContactId,toLabel(Contact.Core_IPA_PartnerRole__c), Contact.AccountId,Core_IPA_One_Partner_Id__c FROM User WHERE Id = : UserInfo.getUserId()].Contact.Core_IPA_PartnerRole__c;
        contactListViewWrapperObject.accountPartnerTier = EPUM_ContactEntitlement_Util.getLogoUrl();
        contactListViewWrapperObject.loggedUserOPID = strOnePartnerId;
        contactListViewWrapperObject.loggedUserId = UserInfo.getUserId();
        contactListViewWrapperObject.loggedUserPartnerRole = strContactPartnerRole;
        contactListViewWrapperObject.coreEntNames = coreEntNames;
        contactListViewWrapperObject.loggedUserIntelAccId = strAccuntId;
        system.debug('List of OPID to be fetched: '+ listOfOPIDsForMPI_Id);
        contactListViewWrapperObject.listOfOPIDs = [SELECT Id, Name, Core_IPA_One_Partner_Id__c, (select toLabel(PRM_Partner_Role__c),PRM_Tier_Name_txt__c from Channel_Memberships1__r) FROM Account WHERE (Core_IPA_One_Partner_Id__c =: listOfOPIDsForMPI_Id OR Id =: listOfOPIDsForMPI_Id) ];
        return contactListViewWrapperObject;
    }
	@AuraEnabled
    public static void insertEpumLog(){
            String strListView = 'ListViewContact';
            DateTime dtSearchStart = datetime.now();
            EPUM_Log__c epumLog1 = EPUM_Utility.createEPUMLogs(strListView,'Yes',dtSearchStart,'');
            Database.insert(epumLog1);
    	}
    
    @AuraEnabled
    public static loggedInUserWrapper isLoggedInUserPAOrPAD() {
        
        String partnerAdminDelegate= 'Partner Admin Delegate';
        String partnerAdmin= 'Partner Admin';
        loggedInUserWrapper wrapObj = new loggedInUserWrapper();
        user loggedUserInfo = EPUM_ContactEntitlement_Util.getUserInformation(); 
        wrapObj.loggedInUserProfile = loggedUserInfo.Profile.Name;
        
        List<Core_Contact_Entitlement__c> ccnList = [select Core_Entitlement_Id__r.Name ,Core_Selected__c from Core_Contact_Entitlement__c where Core_Selected__c=true AND Core_Status__c='Complete' AND Core_Contact_Id__c=:loggedUserInfo.ContactId];
        
         if(!ccnList.isEmpty() && ccnList != null){
            for(Core_Contact_Entitlement__c ccnObj : ccnList){
                if(partnerAdminDelegate.equalsIgnoreCase(ccnObj.Core_Entitlement_Id__r.Name)){
                    wrapObj.isPartnerAdminDelegate = true;
                }
                if(partnerAdmin.equalsIgnoreCase(ccnObj.Core_Entitlement_Id__r.Name)){
                    wrapObj.isPartnerAdmin = true;
                }
            }  
        } 
        return wrapObj; 
    }

    /*--------------- If T&C not checked Redirected to overview page - DRACO -start--------------- */
    @AuraEnabled
    public static String TCRedirection()
    {
        string checkAgreement = 'tandc';
        List<User> lstLoggedInUser = [SELECT Id, ContactId, Contact.AccountId,Contact.Core_IPA_PartnerRole__c, Core_IPA_One_Partner_Id__c FROM User WHERE Id = : userInfo.getUserId()];
        if(!lstLoggedInUser.isEmpty() && lstLoggedInUser[0].Contact.AccountId != null){
            
            List<PRM_AccountLegalAgreemntAssociation__c>  checkAggr = [Select id from PRM_AccountLegalAgreemntAssociation__c where PRM_Account_Id__c =: lstLoggedInUser[0].Contact.AccountId and PRM_Partner_Agreement_Id__r.PRM_Agreement_Cd__c =:system.label.PRM_IPATNCCode and PRM_InActive_Ind__c=false];
            
            if(checkAggr.size()>0){
               checkAgreement='';
            }
            else{
               checkAgreement='tandc';
            }

        } 
        return checkAgreement;

    }
    /* --------------- If T&C not checked Redirected to overview page - DRACO ----------------end*/

    public class loggedInUserWrapper{
        @AuraEnabled public Boolean isPartnerAdmin = false;
        @AuraEnabled public Boolean isPartnerAdminDelegate = false;
        @AuraEnabled public String loggedInUserProfile = '';
    }

    
    public class WrapperContactDetails {
        @AuraEnabled public List<Contact> lstContactToReturn;
        @AuraEnabled public Contact contactDetails;
        @AuraEnabled public Boolean isContactExistsinDB = false;
        @AuraEnabled public Boolean isPendingContact =false; 
        @AuraEnabled public Boolean acrActive =false;  
        @AuraEnabled public Boolean isContactExistsinOnePartnerAcc = false;
        @AuraEnabled public Boolean isContactExitssWithSameRole = false;
        @AuraEnabled public Boolean isSendInvite = false;
        @AuraEnabled public Boolean isContactDeleted = false; //praveena - ForLoginDeleted
        @AuraEnabled public String strLoggedinUserAccId = '';
        @AuraEnabled public String strOnePartnerId = '';
        @AuraEnabled public String accGeo;
        @AuraEnabled public Boolean isExistingIPASelfRegistration = false; // Akshay - For contacts with existing self registration
        @AuraEnabled public Boolean BlockedContact;
        //@AuraEnabled public Map<String,String> mapEPUMConstants;
    }
    
    public class WrapperCotactListView {
        @AuraEnabled public List<Contact> lstContactToReturn;
        @AuraEnabled public String contactPartnerRole;
        @AuraEnabled public String accountPartnerTier;
        @AuraEnabled public String loggedUserPartnerRole;
        @AuraEnabled public List<Core_Entitlement__c> coreEntNames;
        @AuraEnabled public String loggedUserOPID;
        @AuraEnabled public String loggedUserId;
        @AuraEnabled public List<Account> listOfOPIDs;
        @AuraEnabled public String loggedUserIntelAccId;
    }
    
    public class WrapperPicklistSkeleton {
        @AuraEnabled public String strLabel;
        @AuraEnabled public String strValue;
        
        public WrapperPicklistSkeleton(String label, String value){
            this.strLabel = label;
            this.strValue = value;
        }
        
    }
    
    public class WrapperPicklists {
        @AuraEnabled public List<WrapperPicklistSkeleton> lstCountryValues;
        @AuraEnabled public List<WrapperPicklistSkeleton> lstPreferredLanguageValues;
        //@AuraEnabled public Map<String,String> mapEPUMConstants;
    }

    @AuraEnabled
    public static boolean showReInvite (string cId){
       List<PRM_Account_Contact_Relationship__c> acr = new List<PRM_Account_Contact_Relationship__c>([SELECT Id,PRM_Status_Nm__c,PRM_InActive_Ind__c,PRM_Relationship_Id__r.name from PRM_Account_Contact_Relationship__c where PRM_Contact_Id__c =: cId]);

       for(PRM_Account_Contact_Relationship__c cr :acr){
           if(cr.PRM_Status_Nm__c == 'Pending Action' && cr.PRM_Relationship_Id__r.name == 'Employee'){
               return true;
           }
       }
       return false;
    }

    @AuraEnabled
    public static Map<String,String> sendReInvite (string cEmail){
        Map<String,String> mapResult = new Map<String,String>();
        try{
            DateTime dtSearchStart = datetime.now();
        string conMail = cEmail.toLowerCase();

        Contact cont = [SELECT Id, Email, Core_IPA_PartnerRole__c, AccountId, Account.Name, Account.AccountNumber, MailingCountryCode, Core_Preferred_Language__c,Core_Do_Not_Contact__c FROM Contact WHERE email =: conMail][0];
		string newEVToken = PRM_RetriggerEV_Token_API.reTriggerEV(conMail);
        If(cont.Core_Do_Not_Contact__c == false && newEVToken != null){
    //           if(IS_CIDAAS_ENABLED) {
    //             PRM_Contact_AGS_CallbackHandler.IS_CIDAAS_ENABLED = True;
    //    }
            List<string> emMsg = PRM_Contact_AGS_CallbackHandler.sendEmailToContact(cont, newEVToken, conMail);
        //EPUM_Log__c epumLog = EPUM_Utility.createEPUMLogs('SendInvite', 'Yes', dtSearchStart, conMail);
        //Insert epumLog;

            mapResult.put('status', 'success');
            mapResult.put('message', emMsg[0]);
            }
            else{
                mapResult.put('status', 'failed');
                mapResult.put('message', 'Core_Do_Not_Contact__c field is true');
            }
        }
        catch (Exception e) {
            system.debug('error msg'+e);
            mapResult.put('status', 'error');
            mapResult.put('message', e.getMessage());
        }
        return mapResult;
    }

    //---------------------- Draco Change START - Get Pending Registrations from OPID level -- [08-12-2021] -------------------------------------
    @AuraEnabled(cacheable=true)
    public static String getMyCompanySecContForEPUM() {
        SecondaryContacts scs = new SecondaryContacts();
        Set<Id> listOfAccounts = new Set<Id>();
        User loggedInUser = [SELECT ContactId, Contact.AccountId, Contact.Core_IPA_One_Partner_Id__c, Contact.Core_IPA_PartnerRole__c FROM User WHERE Id = :UserInfo.getUserId()];
        if(!String.isEmpty(loggedInUser.Contact.Core_IPA_One_Partner_Id__c)){
            for (Core_Account_Group_Member__c listOPIDChildAccounts : [SELECT Core_Intel_Account_Id__c FROM Core_Account_Group_Member__c WHERE Core_Partner_Account_Id__c =: loggedInUser.Contact.Core_IPA_One_Partner_Id__c]){
                listOfAccounts.add(listOPIDChildAccounts.Core_Intel_Account_Id__c);
            }
        }
        listOfAccounts.add(loggedInUser.Contact.AccountId);
        if (!String.isEmpty(loggedInUser.ContactId)) {
            scs.RegRequests = getPendingReqforEPUM(listOfAccounts, loggedInUser.Contact.Core_IPA_PartnerRole__c.split(';'));
        }
        return JSON.serialize(scs.RegRequests);
    }
    private static List<SecondaryContactWrapper> getPendingReqforEPUM(Set<Id> sfAccountId, List<String> partnerRoles) {
        List<SecondaryContactWrapper> regRequests = new List<SecondaryContactWrapper>();
        Id AccountCreateRT = Schema.SObjectType.PRM_Registration_Request__c.getRecordTypeInfosByDeveloperName().get('Account_Create_Request').getRecordTypeId();
        Id AdminRegistrationRT = Schema.SObjectType.PRM_Registration_Request__c.getRecordTypeInfosByDeveloperName().get('Admin_Registration').getRecordTypeId();
        for (PRM_Registration_Request__c regReq : [
            SELECT
            id,
            PRM_Person_Phone_Number__c,
            PRM_First_Name__c,
            PRM_Last_Name__c,
            PRM_Partner_Relationship__c,
            PRM_Email_ID__c,
            Email_Verification_Status__c,
            PRM_EmailVerifiedDateTime__c
            FROM PRM_Registration_Request__c
            WHERE
            PRM_Status__c = 'New'
            AND (RecordTypeId = :AccountCreateRT)
                 // OR RecordTypeId = :AdminRegistrationRT)
            AND PRM_Partner_Role__c IN :partnerRoles
            AND PRM_Salesforce_ID__c IN :sfAccountId
            ORDER BY PRM_First_Name__c ASC
        ]) {
            SecondaryContactWrapper RegRequest = new SecondaryContactWrapper();
            RegRequest.RecordId = regReq.Id;
            RegRequest.Name = regReq.PRM_First_Name__c + ' ' + regReq.PRM_Last_Name__c;
            RegRequest.Email = regReq.PRM_Email_ID__c;
            RegRequest.Phone = regReq.PRM_Person_Phone_Number__c;
            RegRequest.EVStatus = regReq.Email_Verification_Status__c == 'SUCCESS' ? 'Verified' : 'Not Verified';
            if (regReq.PRM_Partner_Relationship__c != null) {
                RegRequest.Relationship = regReq.PRM_Partner_Relationship__c.Replace(';', ',');  
            }
            RegRequest.EVVerificationDateTime = regReq.PRM_EmailVerifiedDateTime__c;
            if (RegRequest.EVStatus == 'Verified') {
                RegRequest.isApprove = false;
            } else {
                RegRequest.isApprove = true;
            }
            regRequests.add(RegRequest);
        }
        return regRequests;
    }

    public class SecondaryContacts {
        @AuraEnabled public List<SecondaryContactWrapper> RegRequests { get; set; }
        @AuraEnabled public List<SecondaryContactWrapper> Contacts { get; set; }
    }

    public class SecondaryContactWrapper {
        @AuraEnabled public Id RecordId { get; set; }
        @AuraEnabled public String Name { get; set; }
        @AuraEnabled public String Email { get; set; }
        @AuraEnabled public String Phone { get; set; }
        @AuraEnabled public String Responsibilities { get; set; }
        @AuraEnabled public String Status { get; set; }
        @AuraEnabled public String EVStatus { get; set; }
        @AuraEnabled public Datetime EVVerificationDateTime { get; set; }
        @AuraEnabled public Boolean isLoggedinUser { get; set; }
        @AuraEnabled public Boolean isPrimary { get; set; }
        @AuraEnabled public String Relationship { get; set; }
        @AuraEnabled public boolean isApprove { get; set; }
    }
        //---------------------- Draco Change END - Get Pending Registrations from OPID level -- [08-12-2021] -------------------------------------
}