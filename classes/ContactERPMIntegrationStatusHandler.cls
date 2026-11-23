public class ContactERPMIntegrationStatusHandler implements Queueable {    
    List<sObject> sObjectList = null;
    SObjectType objType = null;
    
    public ContactERPMIntegrationStatusHandler(List<sObject> sObjects, SObjectType sObjectType) {        
        sObjectList  = (List<sObject>)Type.forName('List<' + sObjectType + '>').newInstance();
        sObjectList.addAll(sObjects);
        //TODO:: REVISIT ::
        objType = sObjectType;
        system.debug('sObjectList ='+sObjectList);
    }
    
    public void execute(QueueableContext context) { 
        System.debug('Inside execute');
        if( sObjectList instanceof List<PRM_AccountChannelMembership__c>) {
            system.debug('PRM_AccountChannelMembership__c inside execute');
            parseInputList((List<PRM_AccountChannelMembership__c>)sObjectList);
        }
        if( sObjectList instanceof List<PRM_AccountBenefitAssociation__c>) {
            system.debug('PRM_AccountBenefitAssociation__c inside execute');
            parseInputList((List<PRM_AccountBenefitAssociation__c>)sObjectList);
        } 
        //if( sObjectList instanceof List<PRM_AccountLegalAgreemntAssociation__c>) {
        //    system.debug('PRM_AccountLegalAgreemntAssociation__c inside execute');
        //    parseInputList((List<PRM_AccountLegalAgreemntAssociation__c>)sObjectList);
       // } 
        if( sObjectList instanceof List<PRM_Account_Contact_Relationship__c>) {
            system.debug('PRM_Account_Contact_Relationship__c inside execute');
            parseInputList((List<PRM_Account_Contact_Relationship__c>)sObjectList);
        } 
        if( sObjectList instanceof List<PRM_Profile_Responses__c>) {
            system.debug('PRM_Profile_Responses__c inside execute');
            parseInputList((List<PRM_Profile_Responses__c>)sObjectList);
        } 
        if( sObjectList instanceof List<PRM_ContactSubscriptionAssociation__c>) {
            system.debug('PRM_ContactSubscriptionAssociation__c inside execute');
            parseInputList((List<PRM_ContactSubscriptionAssociation__c>)sObjectList);
        }         
    }
    
    private static void updateContactERPMIntegrationStatusToPending(List<Contact> contacts) {
        List<Contact> contactsToUpdate = new List<Contact>();
        System.debug('###ContactERPMIntegrationStatusHandler###updateContactStatusToPending');  
        System.debug(contacts);  
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
            List<Contact> contacts = [SELECT Id FROM Contact WHERE Account.Core_Account_Type__c Includes('Cloud Service Provider (CSP)', 'FPGA Design Services') AND Id IN :contactIds];
            if(contacts != null && contacts.size() > 0) {
                System.debug('###ContactERPMIntegrationStatusHandler###filterCSPRelatedContacts');  
                System.debug(contacts);                  
                updateContactERPMIntegrationStatusToPending(contacts);
            } 
        }
    }
    
    private static List<Account> filterCSPRelatedAccounts(Set<Id> accountIds) {
        List<Account> accounts;
        if(accountIds != null && accountIds.size() > 0) {
            accounts = [SELECT Id FROM Account WHERE Core_Account_Type__c Includes('Cloud Service Provider (CSP)') AND Id IN :accountIds];
            System.debug('###ContactERPMIntegrationStatusHandler###filterCSPRelatedAccounts');  
            System.debug(accounts);                
        }
        return accounts;        
    }
    
    private static List<Contact> retrieveOneContactEachForGivenListofAccounts(List<Account> accounts) {
        List<Contact> contacts = new List<Contact>();
        System.debug('###ContactERPMIntegrationStatusHandler###retrieveOneContactEachForGivenListofAccounts');          
        if(accounts != null && accounts.size() > 0) {
            Set<Id> accountIds = new Set<Id>();    
            for(PRM_Account_Contact_Relationship__c obj : [SELECT PRM_Contact_Id__c, PRM_Account_Id__c FROM PRM_Account_Contact_Relationship__c 
                                                           WHERE PRM_Account_Id__c IN :accounts AND PRM_Contact_Id__r.Core_IPA_Partner_Role__c INCLUDES ('Service Provider') AND PRM_InActive_Ind__c= false]) {
                                                               if(!accountIds.contains(obj.PRM_Account_Id__c)) {
                                                                   contacts.add(new Contact(id = obj.PRM_Contact_Id__c));
                                                                   accountIds.add(obj.PRM_Account_Id__c);
                                                               }
                                                           }
        }
        System.debug(contacts);             
        return contacts;
    }    
    
    private static List<Contact> retrieveAllContactsForGivenListofAccounts(List<Account> accounts) {
        List<Contact> contacts = new List<Contact>();
        System.debug('###ContactERPMIntegrationStatusHandler###retrieveAllContactsForGivenListofAccounts');          
        if(accounts != null && accounts.size() > 0) {
            for(PRM_Account_Contact_Relationship__c obj : [SELECT PRM_Contact_Id__c FROM PRM_Account_Contact_Relationship__c 
                                                           WHERE PRM_Account_Id__c IN :accounts AND PRM_Contact_Id__r.Core_IPA_Partner_Role__c INCLUDES ('Service Provider') ]) {                                                               
                                                               contacts.add(new Contact(id = obj.PRM_Contact_Id__c));
                                                           }
        }
        System.debug(contacts);             
        return contacts;
    }   
    
    public static void parseInputList(List<PRM_AccountChannelMembership__c> newList) {
        system.debug('parseInputList of PRM_AccountChannelMembership__c');
        Set<Id> accountIds = new Set<Id>();        
        System.debug('###ContactERPMIntegrationStatusHandler###PRM_AccountChannelMembership__c');  
        System.debug(newList);             
        for(PRM_AccountChannelMembership__c obj : newList) {
            accountIds.add(obj.PRM_Account_Id__c);
        }
        List<Account> accounts = filterCSPRelatedAccounts(accountIds);
        if(accounts != null && accounts.size() > 0) {
            List<Contact> contacts = retrieveAllContactsForGivenListofAccounts(accounts);
            if(contacts != null && contacts.size() > 0) {
                updateContactERPMIntegrationStatusToPending(contacts);
            }
        }
    }     
    
    public static void parseInputList(List<PRM_AccountBenefitAssociation__c> newList) {
        Set<Id> accountIds = new Set<Id>();        
        System.debug('###ContactERPMIntegrationStatusHandler###PRM_AccountBenefitAssociation__c');  
        System.debug(newList);             
        for(PRM_AccountBenefitAssociation__c obj : newList) {
            accountIds.add(obj.PRM_Account_Id__c);
        }
        List<Account> accounts = filterCSPRelatedAccounts(accountIds);
        if(accounts != null && accounts.size() > 0) {
            List<Contact> contacts = retrieveOneContactEachForGivenListofAccounts(accounts);
            if(contacts != null && contacts.size() > 0) {
                updateContactERPMIntegrationStatusToPending(contacts);
            }
        } 
    }    
    
    /*public static void parseInputList(List<PRM_AccountLegalAgreemntAssociation__c> newList) {        
        Set<Id> accountIds = new Set<Id>();
        System.debug('###ContactERPMIntegrationStatusHandler###PRM_AccountLegalAgreemntAssociation__c');  
        System.debug(newList);        
        for(PRM_AccountLegalAgreemntAssociation__c obj : newList) {
            accountIds.add(obj.PRM_Account_Id__c); 
        }
        List<Account> accounts = filterCSPRelatedAccounts(accountIds);
        if(accounts != null && accounts.size() > 0) {
            List<Contact> contacts = retrieveOneContactEachForGivenListofAccounts(accounts);
            if(contacts != null && contacts.size() > 0) {
                updateContactERPMIntegrationStatusToPending(contacts);
            }
        }
    }  */
    
    public static void parseInputList(List<PRM_Account_Contact_Relationship__c> newList) {
        Set<Id> contactIds = new Set<Id>();
        System.debug('###ContactERPMIntegrationStatusHandler###PRM_Account_Contact_Relationship__c');  
        System.debug(newList);         
        for(PRM_Account_Contact_Relationship__c obj : newList) {
            contactIds.add(obj.PRM_Contact_Id__c);
        }
        if(contactIds.size() > 0) {
            filterCSPRelatedContacts(contactIds);   
        }           
    }     
    
    public static void parseInputList(List<PRM_Profile_Responses__c> newList) {
        Set<Id> contactIds = new Set<Id>();      
        System.debug('###ContactERPMIntegrationStatusHandler###PRM_Profile_Responses__c');  
        System.debug(newList);
        for(PRM_Profile_Responses__c obj : newList) {
            contactIds.add(obj.PRM_Contact_Id__c);
        }
        filterCSPRelatedContacts(contactIds);                 
    }
    
    public static void parseInputList(List<PRM_ContactSubscriptionAssociation__c> newList) {
        Set<Id> contactIds = new Set<Id>();   
        System.debug('###ContactERPMIntegrationStatusHandler###PRM_ContactSubscriptionAssociation__c');  
        System.debug(newList);
        for(PRM_ContactSubscriptionAssociation__c obj : newList) {
            contactIds.add(obj.PRM_Contact_Id__c); 
        }
        filterCSPRelatedContacts(contactIds);               
    }
    
}