@SuppressWarnings('PMD')
public class PRM_SalesCloudContactIntStatus_Handler //implements Queueable 
{
    public static List<String> IPAPartnerRoles = Label.PRM_AGSIdentityCreation_PartnerRoles.split(',');
  /*List<SObject> newRecords {set; get;}
  Map<Id,SObject> oldRecords {set; get;}
    String sObjectName {set; get;}
    Boolean isContactInsert {set;get;}

  public PRM_SalesCloudContactIntStatus_Handler(List<SObject> newRecords,  Map<Id,SObject> oldRecords, Boolean isContactInsert){
    this.newRecords = newRecords;
    this.oldRecords = oldRecords;
        this.sObjectName = sObjectName;
        this.isContactInsert = isContactInsert;
    }

    public void execute(QueueableContext qc)
    {
    if(newRecords instanceof List<PRM_Account_Contact_Relationship__c>) {
      setContactIPAIntegrationStatusToPending((List<PRM_Account_Contact_Relationship__c>) newRecords);
    }else if(newRecords instanceof List<PRM_ContactSubscriptionAssociation__c>) {
            setContactIPAIntegrationStatusToPending((List<PRM_ContactSubscriptionAssociation__c>) newRecords);
        }else if(newRecords instanceof List<Core_Contact_Entitlement__c>) {
            setContactIPAIntegrationStatusToPending((List<Core_Contact_Entitlement__c>) newRecords);
    }else if(newRecords instanceof List<Contact> && isContactInsert) {
      setContactIPAIntegrationStatusToPendingOnCreate((List<Contact>)newRecords);
    }else if(newRecords instanceof List<Contact>) {
            setContactIPAIntegrationStatusToPendingOnUpdate((List<Contact>)newRecords, (Map<Id,Contact>)oldRecords);
        }
    }
    
    public static void setContactIPAIntegrationStatusToPending(List<PRM_Account_Contact_Relationship__c> newACRs){
    Set<Id> contactIds = new Set<Id>();
        System.debug('###PRM_SalesCloudContactIntStatus_Handler###PRM_Account_Contact_Relationship__c');  
        System.debug(newACRs);         
        for(PRM_Account_Contact_Relationship__c obj : newACRs) {
            contactIds.add(obj.PRM_Contact_Id__c);
        }
        if(contactIds.size() > 0) {
            updateContactIPAIntegrationStatus(contactIds);   
        }     
    }
    
    public static void setContactIPAIntegrationStatusToPending(List<PRM_ContactSubscriptionAssociation__c> newCSAs){
        Set<Id> contactIds = new Set<Id>();
        System.debug('###PRM_SalesCloudContactIntStatus_Handler###PRM_ContactSubscriptionAssociation__c');  
        System.debug(newCSAs);         
        for(PRM_ContactSubscriptionAssociation__c obj : newCSAs) {
            contactIds.add(obj.PRM_Contact_Id__c);
        }
        if(contactIds.size() > 0) {
            updateContactIPAIntegrationStatus(contactIds);   
        }

    }
    
    public static void setContactIPAIntegrationStatusToPending(List<Core_Contact_Entitlement__c> newContEnts){
        Set<Id> contactIds = new Set<Id>();
        System.debug('###PRM_SalesCloudContactIntStatus_Handler###PRM_ContactSubscriptionAssociation__c');  
        System.debug(newContEnts);         
        for(Core_Contact_Entitlement__c obj : newContEnts) {
            contactIds.add(obj.Core_Contact_Id__c);
        }
        if(contactIds.size() > 0) {
            updateContactIPAIntegrationStatus(contactIds);   
        }

    }*/
    
    /* Code has been moved to ContactERPMIntegrationStatusHandler class - Not required anymore *******
    public static void setContactIPAIntegrationStatusToPendingACR(List<PRM_Account_Contact_Relationship__c> newACRs)
    {
        Set<Id> contactIds = new Set<Id>();
        System.debug('###PRM_SalesCloudContactIntStatus_Handler###PRM_Account_Contact_Relationship__c');  
        System.debug(newACRs);         
        for(PRM_Account_Contact_Relationship__c obj : newACRs) {
            contactIds.add(obj.PRM_Contact_Id__c);
        }
        if(contactIds.size() > 0) {
            updateContactIPAIntegrationStatus(contactIds);   
        }  
        
    }
    
    public static void setContactIPAIntegrationStatusToPendingCSA(List<PRM_ContactSubscriptionAssociation__c> newCSAs){
        Set<Id> contactIds = new Set<Id>();
        System.debug('###PRM_SalesCloudContactIntStatus_Handler###PRM_ContactSubscriptionAssociation__c');  
        System.debug(newCSAs);         
        for(PRM_ContactSubscriptionAssociation__c obj : newCSAs) {
            contactIds.add(obj.PRM_Contact_Id__c);
        }
        if(contactIds.size() > 0) {
            updateContactIPAIntegrationStatus(contactIds);   
        }

    }*/
    
    public static void setContactIPAIntegrationStatusToPendingContEnt(List<Core_Contact_Entitlement__c> newContEnts){
        Set<Id> contactIds = new Set<Id>();
        System.debug('###PRM_SalesCloudContactIntStatus_Handler###PRM_ContactSubscriptionAssociation__c');  
        System.debug(newContEnts);         
        for(Core_Contact_Entitlement__c obj : newContEnts) {
            contactIds.add(obj.Core_Contact_Id__c);
        }
        if(contactIds.size() > 0) {
            updateContactIPAIntegrationStatus(contactIds);   
        }

    }
    
    public static void setContactIPAIntegrationStatusToPendingOnCreate(List<Contact> contacts) {
            Set<Id> contactIds = new Set<Id>(); 
            for(contact con : contacts){
                if(!con.Core_IPS_Employee_Customer__c && !String.isEmpty(con.Core_IPA_PartnerRole__c) && !IPAPartnerRoles.contains(con.Core_IPA_PartnerRole__c) && con.PRM_IPA_Integration_Status__c != 'Pending'){
          con.PRM_IPA_Integration_Status__c = 'Pending';
                    //contactIds.add(con.Id);
                }
            }
            
            /*if(contactIds.size() >0 ){
                system.debug('SeteRPMIntStatusToPendingOnContactCreate '+ contactIds);
                //updateContactIPAIntegrationStatus(contactIds);
            } */       
    }
    
    public static void setContactIPAIntegrationStatusToPendingOnUpdate(List<Contact> newContacts, Map<Id, Contact> oldContacts) {
            Set<Id> contactIds = new Set<Id>(); 
        //Added by Sushmita(Agate) to check if the existing account and new account are IPA or not.
        //Start 131 to 157
      Set<Id> newAccountIds = new Set<Id>();
      Set<Id> oldAccountIds = new Set<Id>();
      Map<Id, Boolean> ContAccMap = new Map<Id, Boolean>();

      for(Contact newCon : newContacts){
                if(newCon.AccountId != oldContacts.get(newCon.Id).AccountId){
                    newAccountIds.add(newCon.AccountId); 
                    oldAccountIds.add(oldContacts.get(newCon.Id).AccountId);
                    System.Debug('newAccountsIds----> '+newAccountIds);
                    System.Debug('oldAccountIds----> '+oldAccountIds);
                }
      }
          if(!newAccountIds.IsEmpty() && !oldAccountIds.isEmpty()){
                for(Account acc : [Select id, Core_Intel_Partner_Alliance_PartnerGroup__c from Account where id in :newAccountIds or id in :oldAccountIds]){
                    ContAccMap.put(acc.Id, acc.Core_Intel_Partner_Alliance_PartnerGroup__c);
                    System.debug('ContAccMap----> '+ContAccMap);
                }
            }

            for(Contact newCon : newContacts) {
                System.debug('Old Name : ' +oldContacts.get(newCon.Id).FirstName + 'New Name :' +newCon.FirstName);
        
                Boolean ipaCheckNewAcc;
                Boolean ipaCheckOldAcc;
                Boolean isAccountChanged = false;
                ipaCheckNewAcc = ContAccMap.get(newCon.AccountId) ;
                ipaCheckOldAcc = ContAccMap.get(oldContacts.get(newCon.Id).AccountId);
                if((ipaCheckNewAcc == true && ipaCheckOldAcc == true) || (ipaCheckNewAcc == false && ipaCheckOldAcc == true) || (ipaCheckNewAcc == true && ipaCheckOldAcc == false))  {            
                    isAccountChanged = true;
                    system.debug('IPA checkbox conatct update--> '+newCon.PRM_IPA_Integration_Status__c);
                }
      
                if(!String.isEmpty(newCon.Core_IPA_PartnerRole__c)
                        && !IPAPartnerRoles.contains(newCon.Core_IPA_PartnerRole__c) && !newCon.Core_IPS_Employee_Customer__c && oldContacts.get(newCon.Id).PRM_IPA_Integration_Status__c != 'Pending'
                   && ( newCon.Core_Job_Function_Code__c != oldContacts.get(newCon.Id).Core_Job_Function_Code__c
                       || newCon.Email != oldContacts.get(newCon.Id).Email
                       || newCon.Phone != oldContacts.get(newCon.Id).Phone
                       || newCon.MobilePhone != oldContacts.get(newCon.Id).MobilePhone
                       || newCon.Core_Job_Function_Code__c != oldContacts.get(newCon.Id).Core_Job_Function_Code__c
                       || newCon.Salutation != oldContacts.get(newCon.Id).Salutation
                       || newCon.Core_Preferred_Language__c != oldContacts.get(newCon.Id).Core_Preferred_Language__c
                       || newCon.MailingCountryCode != oldContacts.get(newCon.Id).MailingCountryCode
                       || newCon.Core_Do_Not_Contact__c != oldContacts.get(newCon.Id).Core_Do_Not_Contact__c
                       || (newCon.Core_English_Only_First_Name__c != oldContacts.get(newCon.Id).Core_English_Only_First_Name__c 
                           && String.isNotBlank(oldContacts.get(newCon.Id).Core_English_Only_First_Name__c))
                       || (newCon.Core_English_Only_Last_Name__c != oldContacts.get(newCon.Id).Core_English_Only_Last_Name__c 
                           && String.isNotBlank(oldContacts.get(newCon.Id).Core_English_Only_Last_Name__c))
                       || newCon.Core_IPA_Partner_Community__c != oldContacts.get(newCon.Id).Core_IPA_Partner_Community__c
                       || newCon.FirstName != oldContacts.get(newCon.Id).FirstName
                       || newCon.LastName != oldContacts.get(newCon.Id).LastName
                       || isAccountChanged == true
                      )) {
                          
                          System.debug('Old Name : ' +oldContacts.get(newCon.Id).FirstName + 'New Name :' +newCon.FirstName);
                          //Contact con = new Contact(Id = newCon.id,PRM_IPA_Integration_Status__c = 'Pending');
                          newCon.PRM_IPA_Integration_Status__c = 'Pending';
                          system.debug('conatct update');
                          //contactIds.add(newCon.Id);
                      }
            }
            
            
            /*if(contactIds.size() >0 ){
                System.debug('setContactIPAIntegrationStatusToPendingOnUpdate');
                updateContactIPAIntegrationStatus(contactIds);
            }*/
    }

    private static void updateContactIPAIntegrationStatus(Set<Id> contacts) {
        system.debug('inside updateContactIPAIntegrationStatus');
    List<Contact> contactsToBeUpdated = new List<Contact>();
    Map<id,Contact> contactsMap = getContactsMap(contacts);
    if(contactsMap.size() > 0) {
      for(Contact cont : contactsMap.values()) {
        if(cont.PRM_IPA_Integration_Status__c != 'Pending') {
          cont.PRM_IPA_Integration_Status__c = 'Pending';
          contactsToBeUpdated.add(cont);
        }
      }
      system.debug('contactsToBeUpdated ==>'+contactsToBeUpdated);
      if(contactsToBeUpdated.size() > 0 ) {              
        update contactsToBeUpdated;
      }
    }
    }

    public static Map<Id,Contact> getContactsMap(Set<Id> contactIds) {
    return new Map<Id,Contact>([ SELECT id, Name , PRM_IPA_Integration_Status__c
                                 FROM Contact WHERE Id IN: contactIds AND Core_IPA_PartnerRole__c!=null AND Core_IPA_PartnerRole__c NOT IN : IPAPartnerRoles
                                    /*Core_IPA_Partner_Role__c INCLUDES ('Service Provider','FPGA Designer','Seller','Manufacturer')*/]);

  }

}