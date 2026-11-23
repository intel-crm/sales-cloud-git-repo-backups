public class ContactERPMIntegrationStatusHandler implements Queueable,Database.AllowsCallouts {    
    public static Final String ORIGIN  = 'ContactERPMIntegrationStatusHandler';
    public static Final String SEVERITY  = 'Critical';
    public static Final String PROJECT  = 'IPA';
    public static Final String ERRORMESSAGE  = 'Too many DML rows';
    List<sObject> sObjectList = null;
    SObjectType objType = null;
    static List<String> configPartnerRoles = Label.PRM_AGSIdentityCreation_PartnerRoles.split(',');
    public static boolean inFutureContext = false;
    
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
            system.debug('PRM_ContactSubscriptionAssociation__c inside execute');  
            //Added By Naresh as part of US712265
            Core_ERPM_Outbound_Integration.updateContIPAIntStatus = true;            
          parseInputList((List<PRM_ContactSubscriptionAssociation__c>)sObjectList);
            Core_ERPM_Outbound_Integration.updateContIPAIntStatus = false;
        }
        if( sObjectList instanceof List<Account>){ //Added by UTKARSH - RUBY
            UpdateAccount((List<Account>)sObjectList);
        }
         if( sObjectList instanceof List<Contact>){ //Added by Vijay - AGATE
            UpdateContact((List<Contact>)sObjectList);
        }
        //---- Start of DRACO Code ----//
        //if( sObjectList instanceof List<Core_Integration_Outbound_Message__c>) {          
        //    updateOutboundMessage((List<Core_Integration_Outbound_Message__c>)sObjectList);
        //}
        //---- End of DRACO Code ----//
        if( sObjectList instanceof List<Contact_Business_Types__c>) {          
            parseInputList((List<Contact_Business_Types__c>)sObjectList);
        }
    } 
    
    private static void updateContactERPMIntegrationStatusToPending(List<Contact> contacts) {
        List<Contact> contactsToUpdate = new List<Contact>(); 
        for(Contact contact : contacts) {
            contactsToUpdate.add(new Contact(id = contact.Id
                                             //, Core_ERPM_Integration_Status__c = 'Pending'
                                             ));
        }
        if(contactsToUpdate != null && contactsToUpdate.size() > 0) {
            //update contactsToUpdate;
            Core_ERPM_Outbound_Integration.evaluateAndSetERPMOutboundIntegrationStatus(contactsToUpdate,null,false);
        }
    }
    
    private static void filterCSPRelatedContacts(Set<Id> contactIds) {
        if(contactIds != null && contactIds.size() > 0) {
            List<Contact> contacts = [SELECT Id FROM Contact WHERE Core_IPA_PartnerRole__c NOT IN : configPartnerRoles  AND Id IN :contactIds];
            if(contacts != null && contacts.size() > 0) {                 
                updateContactERPMIntegrationStatusToPending(contacts);
            } 
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
        Set<Id> contactIds = new Set<Id>();   
        for(PRM_ContactSubscriptionAssociation__c obj : newList) {
            contactIds.add(obj.PRM_Contact_Id__c); 
        }
        //filterCSPRelatedContacts(contactIds);
        if(contactIds != null && contactIds.size() > 0) {
            List<Contact> contacts = [SELECT Id FROM Contact WHERE Id IN :contactIds];
            if(contacts != null && contacts.size() > 0) {
                updateContactERPMIntegrationStatusToPending(contacts);
            } 
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
            // update accList;
            upsertData(accList, 'Account');
            
        }
    }
    public static void UpdateContact(List<Contact> conList) { //Added by Vijay - AGATE
        System.debug('Contact list is '+conList);
        if(conList != null && !conList.IsEmpty()){
            //update conList;
            upsertData(conList, 'Contact');
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
    //Added by Sankarshana - Start of DRACO code //
    /*
    public static void updateOutboundMessage(List<Core_Integration_Outbound_Message__c> iomList){
        List<Core_Integration_Outbound_Message__c> lstOutbound = New List<Core_Integration_Outbound_Message__c>();
        for(Core_Integration_Outbound_Message__c objIom : iomList){
            objIom.Core_Status__c='Pending';
            objIom.Core_Retry_Number__c = 0;
            lstOutbound.add(objIom);
        }
        if(!lstOutbound.isEmpty() && lstOutbound != null){
            update lstOutbound;
        }
    } */
      //-- END of DRACO code--//


}