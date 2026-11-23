@SuppressWarnings('PMD')
public class PRM_SalesCloudContactIntStatus_Handler //implements Queueable 
{
    //public static String ipaRefresh =  System.label.PRM_ipaRefresh; 
    public static List<String> IPAPartnerRoles = Label.PRM_AGSIdentityCreation_PartnerRoles.split(',');
    public static Set<Id> pendingContactIds = new Set<Id>();
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
        for(PRM_Account_Contact_Relationship__c obj : newACRs) {
            contactIds.add(obj.PRM_Contact_Id__c);
        }
        if(contactIds.size() > 0) {
            updateContactIPAIntegrationStatus(contactIds);   
        }     
    }
    
    public static void setContactIPAIntegrationStatusToPending(List<PRM_ContactSubscriptionAssociation__c> newCSAs){
        Set<Id> contactIds = new Set<Id>();        
        for(PRM_ContactSubscriptionAssociation__c obj : newCSAs) {
            contactIds.add(obj.PRM_Contact_Id__c);
        }
        if(contactIds.size() > 0) {
            updateContactIPAIntegrationStatus(contactIds);   
        }

    }
    
    public static void setContactIPAIntegrationStatusToPending(List<Core_Contact_Entitlement__c> newContEnts){
        Set<Id> contactIds = new Set<Id>();    
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
        
        for(Core_Contact_Entitlement__c obj : newContEnts) {
                contactIds.add(obj.Core_Contact_Id__c);
        }
        if(contactIds!=null){
            updateContactIPAIntegrationStatus(contactIds);   
	}

    }
    
    //TWC729-7704 commenting class to prevent staus change on creation of contact through pcr invite
    /*public static void setContactIPAIntegrationStatusToPendingOnCreate(List<Contact> contacts) {
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
            }      
    }*/

    public static void setContactIPAIntegrationStatusToPendingOnUpdate(List<Contact> newContacts, Map<Id, Contact> oldContacts) {
            Set<Id> contactIds = new Set<Id>(); 
        //Added by Sushmita(Agate) to check if the existing account and new account are IPA or not.
        //Start 131 to 157
			Set<Id> newAccountIds = new Set<Id>();
			Set<Id> oldAccountIds = new Set<Id>();
			Map<Id, Boolean> ContAccMap = new Map<Id, Boolean>();
            //TWC729-7704 R4c issue fix
            Set<Id> newContactsId = new Set<Id>();
            Map<Id,PRM_Account_Contact_Relationship__c> conPcrMap = new Map<Id,PRM_Account_Contact_Relationship__c>();
            Map<Id,Boolean> conIPACheck = new Map<Id,Boolean>();
            
            if(!FeatureManagement.checkPermission('PCC_Bypass_Automation')){
			for(Contact newCon : newContacts){
                if(newCon.AccountId != oldContacts.get(newCon.Id).AccountId){
                    newAccountIds.add(newCon.AccountId); 
                    oldAccountIds.add(oldContacts.get(newCon.Id).AccountId);
                }
                if(!pendingContactIds.contains(newCon.id)){
                    newContactsId.add(newCon.id);
                }
			}
        	if(!newAccountIds.IsEmpty() && !oldAccountIds.isEmpty()){
                for(Account acc : [Select id, Core_Intel_Partner_Alliance_PartnerGroup__c from Account where id in :newAccountIds or id in :oldAccountIds]){
                    ContAccMap.put(acc.Id, acc.Core_Intel_Partner_Alliance_PartnerGroup__c);
                }
            }

            //TWC729-7704 R4c issue fix
            if(newContactsId!=null){
                conPcrMap = getPCRRecord(newContactsId);
		if(newContacts!=null){
	                for(Contact newCon: newContacts){
	                    if(conPcrMap.containsKey(newCon.id) && ((newCon.Core_IPA_PartnerRole__c!=null && conPcrMap.get(newCon.id).PRM_InActive_Ind__c ==false)||(newCon.Core_IPA_PartnerRole__c==null && oldContacts.get(newCon.id).Core_IPA_PArtnerRole__c!=null && conPcrMap.get(newCon.id).PRM_InActive_Ind__c == true))){
	                        conIPACheck.put(newCon.id,true);
	                    }
	                }
		}
            }
            //TWC729-7704 r4c issue fix
            
            for(Contact newCon : newContacts) {
				
                Boolean ipaCheckNewAcc;
                Boolean ipaCheckOldAcc;
                Boolean isAccountChanged = false;
                ipaCheckNewAcc = ContAccMap.get(newCon.AccountId) ;
                ipaCheckOldAcc = ContAccMap.get(oldContacts.get(newCon.Id).AccountId);
                if((ipaCheckNewAcc == true && ipaCheckOldAcc == true) || (ipaCheckNewAcc == false && ipaCheckOldAcc == true) || (ipaCheckNewAcc == true && ipaCheckOldAcc == false))  {						
                    isAccountChanged = true;
                }
			
                if(!IPAPartnerRoles.contains(newCon.Core_IPA_PartnerRole__c) && !newCon.Core_IPS_Employee_Customer__c && oldContacts.get(newCon.Id).PRM_IPA_Integration_Status__c != 'Pending' && 
                conIPACheck.containsKey(newCon.Id) && conIPACheck.get(newCon.Id)==true/*TWC729-7704 r4c issue fix*/
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
                    /*|| (ipaRefresh !='TRUE' && newCon.Core_IPA_Partner_Community__c != oldContacts.get(newCon.Id).Core_IPA_Partner_Community__c) */   //IPA2.0 - TWC727-2793              
                    || newCon.FirstName != oldContacts.get(newCon.Id).FirstName
                    || newCon.Core_IPA_PartnerRole__c != oldContacts.get(newCon.Id).Core_IPA_PartnerRole__c
                    || newCon.LastName != oldContacts.get(newCon.Id).LastName
                    || isAccountChanged == true
                )){
                          
                          //Contact con = new Contact(Id = newCon.id,PRM_IPA_Integration_Status__c = 'Pending');
                          newCon.PRM_IPA_Integration_Status__c = 'Pending';
                          //contactIds.add(newCon.Id);
                          pendingContactIds.add(newCon.Id);
                      }
            }
            
            
            /*if(contactIds.size() >0 ){
                System.debug('setContactIPAIntegrationStatusToPendingOnUpdate');
                updateContactIPAIntegrationStatus(contactIds);
            }*/
    }
    }

    //TWC729-7704 R4c issue fix
    private static Map<Id,PRM_Account_Contact_Relationship__c> getPCRRecord(Set<Id> contactIds){
        Map<Id,PRM_Account_Contact_Relationship__c> conPcrMap = new Map<Id,PRM_Account_Contact_Relationship__c>();
        if(contactIds!=null){
            for( PRM_Account_Contact_Relationship__c pcr: [select id,PRM_Contact_Id__c,PRM_InActive_Ind__c from PRM_Account_Contact_Relationship__c where PRM_Status_Nm__c =: 'Complete' and PRM_Contact_Id__c in: contactIds]){
                conPcrMap.put(pcr.PRM_Contact_Id__c,pcr);
            }
        }
        return conPcrMap;
    }
    

    private static void updateContactIPAIntegrationStatus(Set<Id> contacts) {
		if(!FeatureManagement.checkPermission('PCC_Bypass_Automation')){
		List<Contact> contactsToBeUpdated = new List<Contact>();
		Map<id,Contact> contactsMap = getContactsMap(contacts);
		if(contactsMap.size() > 0) {
			for(Contact cont : contactsMap.values()) {
				if(cont.PRM_IPA_Integration_Status__c != 'Pending') {
					cont.PRM_IPA_Integration_Status__c = 'Pending';
					contactsToBeUpdated.add(cont);
                    pendingContactIds.add(cont.id);
				}
			}


            List<Contact> contactsToUpdateNew = new List<Contact>();
        if(!contactsToBeUpdated.isEmpty()){
            //Added by Ankit
            Core_MergeContactHandler.isRecurssive = true;

            for(Contact ContactRec : contactsToBeUpdated){
                if(Core_MergeContactHandler.deletedContactIds != null){
                    if(!Core_MergeContactHandler.deletedContactIds.contains(ContactRec.Id)){
                        contactsToUpdateNew.add(ContactRec);
                    }
                }else{
                    contactsToUpdateNew.add(ContactRec);
                }
            }
            //update contactsToBeUpdated.values();

        }

        if(!contactsToUpdateNew.isEmpty()){
            update contactsToUpdateNew;
        }		


		}
		}
    }

    public static Map<Id,Contact> getContactsMap(Set<Id> contactIds) {
       //TWC729-7704 R4c issue fix
        Map<Id,PRM_Account_Contact_Relationship__c> conPcrMap = new Map<Id,PRM_Account_Contact_Relationship__c>();
		Map<Id,Contact> contactsMap = new Map<Id,Contact>();
        conPcrMap=getPCRRecord(contactIds);
        for(Contact con: [ SELECT id, Name , PRM_IPA_Integration_Status__c
        FROM Contact WHERE Id IN: contactIds AND Id NOT IN: pendingContactIds AND Core_IPA_PartnerRole__c!=null AND Core_IPA_PartnerRole__c NOT IN : IPAPartnerRoles]){
            if(conPcrMap.containsKey(con.id) && conPcrMap.get(con.id).PRM_InActive_Ind__c==false){
                contactsMap.put(con.id,con);
            }
        }
		return contactsMap;
        /*Core_IPA_Partner_Role__c INCLUDES ('Service Provider','FPGA Designer','Seller','Manufacturer')*/

	}

}