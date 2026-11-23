/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 02-09-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public class ContactERPMIntegrationStatusHandler implements Queueable {    
    public static Final String ORIGIN  = 'ContactERPMIntegrationStatusHandler';
    public static Final String SEVERITY  = 'Critical';
    public static Final String PROJECT  = 'IPA';
    public static Final String ERRORMESSAGE  = 'Too many DML rows';
    List<sObject> sObjectList = null;
    SObjectType objType = null;
    static List<String> configPartnerRoles = Label.PRM_AGSIdentityCreation_PartnerRoles.split(',');
    
    public ContactERPMIntegrationStatusHandler(List<sObject> sObjects, SObjectType sObjectType) {        
        sObjectList  = (List<sObject>)Type.forName('List<' + sObjectType + '>').newInstance();
        sObjectList.addAll(sObjects);
        //TODO:: REVISIT ::
        objType = sObjectType;
    }
    
    public void execute(QueueableContext context) { 
        callableMethod(sObjectList);
    }
    
    public static void callableMethod(List<sObject> sObjectList){
        if( sObjectList instanceof List<PRM_AccountChannelMembership__c>) {
            //Added By Naresh as part of US713206
          PRM_SalesCloudAccountIntStatus_Handler.setAccountIPAIntegrationStatusToPending((List<PRM_AccountChannelMembership__c>)sObjectList);
        }
        if( sObjectList instanceof List<PRM_AccountBenefitAssociation__c>) {
            //Added By Naresh as part of US712265
          PRM_SalesCloudAccountIntStatus_Handler.setAccountIPAIntegrationStatusToPending((List<PRM_AccountBenefitAssociation__c>)sObjectList);
        } 
        //Added By Harshitha as part of US759364
        if( sObjectList instanceof List<Core_Account_Whitelisted_Domains__c>) {
            PRM_SalesCloudAccountIntStatus_Handler.setAccountIPAIntegrationStatusToPending((List<Core_Account_Whitelisted_Domains__c>)sObjectList);
        } 
        //Added By Harshitha as part of US759364
        if( sObjectList instanceof List<PRM_Partner_Assist_Consent__c>) {
            PRM_SalesCloudAccountIntStatus_Handler.setAccountIPAIntegrationStatusToPending((List<PRM_Partner_Assist_Consent__c>)sObjectList);
        }
        //Added by Anand TB as part of US847809
        if( sObjectList instanceof List<PRM_AccountLegalAgreemntAssociation__c>) {
            PRM_SalesCloudAccountIntStatus_Handler.setAccountIPAIntegrationStatusToPending((List<PRM_AccountLegalAgreemntAssociation__c>)sObjectList);
        }
        
        if( sObjectList instanceof List<PRM_Account_Contact_Relationship__c>) {
            //Added By Naresh as part of US713206
            Core_ERPM_Outbound_Integration.updateContIPAIntStatus = true;
            //Removed by Manju because we need to generate OBM to add IPA engagement on ACR insert/update
          parseInputList((List<PRM_Account_Contact_Relationship__c>)sObjectList);
            Core_ERPM_Outbound_Integration.updateContIPAIntStatus = false;
             //Removed by Manju because we need to generate OBM to add IPA engagement on ACR insert/update
        } 
        if( sObjectList instanceof List<PRM_Profile_Responses__c>) {
            //Commented by Harshitha as not required for ERPM sync
            //Added By Harshitha as part of US759364
            PRM_SalesCloudAccountIntStatus_Handler.setAccountIPAIntegrationStatusToPending((List<PRM_Profile_Responses__c>)sObjectList);
        } 
        if( sObjectList instanceof List<PRM_ContactSubscriptionAssociation__c>) {
            //Added By Naresh as part of US712265
            Core_ERPM_Outbound_Integration.updateContIPAIntStatus = true;            
            Core_Entitlement_Outbound_Integrations.subsFlowIntiated = true;     // TWC729-3874     
          parseInputList((List<PRM_ContactSubscriptionAssociation__c>)sObjectList);
            Core_ERPM_Outbound_Integration.updateContIPAIntStatus = false;
        }
        if( sObjectList instanceof List<Account>){ //Added by UTKARSH - RUBY
            UpdateAccount((List<Account>)sObjectList);
        }
        if( sObjectList instanceof List<Contact>){ //Added by Vijay - AGATE
            UpdateContact((List<Contact>)sObjectList);
        }
	//---- End of DRACO Code ----//
        if( sObjectList instanceof List<Contact_Business_Types__c>) {          
            parseInputList((List<Contact_Business_Types__c>)sObjectList);
        }
    }
    
    private static void updateContactERPMIntegrationStatusToPending(List<Contact> contacts) {
        /*List<Contact> contactsToUpdate = new List<Contact>();
        for(Contact contact : contacts) {
            contactsToUpdate.add(new Contact(id = contact.Id
                                             //, Core_ERPM_Integration_Status__c = 'Pending'
                                             ));
        }*/
                                             
        if(contacts != null && contacts.size() > 0) {
            //update contactsToUpdate;
            Core_ERPM_Outbound_Integration.evaluateAndSetERPMOutboundIntegrationStatus(contacts,null,false);
        }
    }
    
    private static void filterCSPRelatedContacts(Set<Id> contactIds) {
        if(contactIds != null && contactIds.size() > 0) {
            //Ganesh Changes
            /*List<Contact> contacts = [SELECT Id FROM Contact WHERE Core_IPA_PartnerRole__c NOT IN : configPartnerRoles  AND Id IN :contactIds];
            if(contacts != null && contacts.size() > 0) {
                updateContactERPMIntegrationStatusToPending(contacts);
            }*/
            //Ganesh Changes
            List<Contact> contacts = [SELECT Id, Core_IPA_PartnerRole__c FROM Contact WHERE Id IN :contactIds];
            List<Contact> filteredContacts = new List<Contact>();

			for(Contact con : contacts){
    			if(!configPartnerRoles.contains(con.Core_IPA_PartnerRole__c)){
        			filteredContacts.add(con);
    			}
			}
            if(filteredContacts != null && filteredContacts.size() > 0) {
                updateContactERPMIntegrationStatusToPending(filteredContacts);
            }
            //Ganesh Changes
        }
    }     
    
    public static void parseInputList(List<PRM_Account_Contact_Relationship__c> newList) {
        Set<Id> contactIds = new Set<Id>();
        for(PRM_Account_Contact_Relationship__c obj : newList) {
            contactIds.add(obj.PRM_Contact_Id__c);
        }
        if(contactIds.size() > 0) {
            filterCSPRelatedContacts(contactIds);   
        }           
    }     
    
    
    public static void parseInputList(List<PRM_ContactSubscriptionAssociation__c> newList) {
        try{
            Set<Id> contactIds = new Set<Id>();   
            for(PRM_ContactSubscriptionAssociation__c obj : newList) {
                if(obj.LastModifiedById!=Label.ERPM_OBM_Integration){
                    contactIds.add(obj.PRM_Contact_Id__c);
                } 
            }
            //filterCSPRelatedContacts(contactIds);
            if(contactIds != null && contactIds.size() > 0) {
                List<Contact> contacts = [SELECT Id FROM Contact WHERE Id IN :contactIds];
                if(contacts != null && contacts.size() > 0) {
                    List<Contact> contactsToUpdate = new List<Contact>();
                    for(Contact contact : contacts) {
                        contactsToUpdate.add(new Contact(id = contact.Id
                                                         , Core_ERPM_Integration_Status__c = 'Pending'
                                                        ));
                    }
                    
                    if(contactsToUpdate != null && contactsToUpdate.size() > 0) {
                        update contactsToUpdate;
                        updateContactERPMIntegrationStatusToPending(contactsToUpdate);
                    } 
                } 
            }
        }catch(Exception ex){
            UCD_ACM_Logger.error('ContactERPMIntegrationStatusHandler','parseInputList','Message: '+ex.getMessage()+'. StackTrace: '+ex.getStackTraceString(),NULL);
            UCD_ACM_Logger.setLogDetails();
        }
    }
    
    public static void parseInputList(List<Contact_Business_Types__c> newList) {
        Set<Id> contactIds = new Set<Id>();   
        for(Contact_Business_Types__c obj : newList) {
            contactIds.add(obj.Contact__c); 
        }
        if(contactIds != null && contactIds.size() > 0) {
            List<Contact> contacts = [SELECT Id FROM Contact WHERE Id IN :contactIds];
            if(contacts != null && contacts.size() > 0) {                
                updateContactERPMIntegrationStatusToPending(contacts);
            } 
        } 
    }
    
    public static void UpdateAccount(List<Account> accList) { //Added by UTKARSH - RUBY
        if(accList != null && !accList.IsEmpty()){
            //update accList;
            List<Id> listOfAccIdUpdated = new List<Id>();
            Database.SaveResult[] result;
            result = Database.update(accList, false);
            if(result != null && !result.isEmpty()){
                for(Database.SaveResult sr : result){
                    if(sr.isSuccess()){
                        listOfAccIdUpdated.add(sr.getId());
                    }
                }
            }

            List<Core_Account_Group_Member__c> cagToBeUpdated = new List<Core_Account_Group_Member__c>();
            for(Core_Account_Group_Member__c cag : [SELECT id,Primary_Account__c FROM Core_Account_Group_Member__c where Core_Partner_Account_Id__c IN :listOfAccIdUpdated AND Primary_Account__c = FALSE AND Core_Inactive_Ind__c = FALSE AND UCD_Hierarchy__c =: System.label.PRM_Global_Customer AND Core_Partner_Account_Id__r.Core_Deactivated__c = FALSE ]){
                cag.Primary_Account__c = TRUE;
                cagToBeUpdated.add(cag);
            }


            upsertData(cagToBeUpdated,'Core_Account_Group_Member__c');

            //IPA Refresh 2.0 - TWC729-8102 -end

        }
    }
    
     public static void UpdateContact(List<Contact> conList) { //Added by Vijay - AGATE
        if(conList != null && !conList.IsEmpty()){
            try{
                update conList;
            }catch(Exception ex){
                UCD_ACM_Logger.error('ContactERPMIntegrationStatusHandler','UpdateContact','Message: '+ex.getMessage()+'. StackTrace: '+ex.getStackTraceString(),NULL);
                UCD_ACM_Logger.setLogDetails();
                
            }
        }
    }
    
    //Added by Tanya - Exception handling when any record got errored out.
    public static void upsertData(List<sObject> upsertList, String sObjectTypeName){
        if(upsertList.size() < Limits.getLimitDMLRows()){
            if(upsertList != null && !upsertList.IsEmpty()){
                Database.UpsertResult[] sbObjectList;
                sbObjectList = Database.upsert(upsertList, false); 
                integer index = 0;
                for (Database.UpsertResult sr : sbObjectList){                    
                    if (!sr.isSuccess()){
                        Id sId;
                        String sObjectType = sObjectTypeName;
                        String tags = '';
                        for(Database.Error err : sr.getErrors()){
                            sId =upsertList[index].Id;
                            Core_Log_Entry.logEntryWithDetails(ORIGIN, PROJECT,'Message', SEVERITY, err.getMessage(), '', sId, sObjectType, tags);
                        }
                    }
                }
                index ++;
            }
        }else{
            Core_Log_Entry.logEntryWithDetails(ORIGIN, PROJECT,'Message', SEVERITY,ERRORMESSAGE,'','' ,'','');
        } 
    }
}