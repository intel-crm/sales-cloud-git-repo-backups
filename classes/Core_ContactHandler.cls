/**************************************************************************************
Apex Class Name:  Core_ContactHandler
Version     : 1.0 
Created Date: 02 NOV 2015
Function    : Methods to handle Contact Trigger functions
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Venu Karumuru             11/02/2015              Added Method UpdateJobFunction() that updates Job Function based on the value in Job Function Code
* Venu Karumuru             11/02/2015              Added Method UpdateJobFunctionCode() that updates Job Function Code based on the value in Job Function
* Pratiksha Mahajan         26/07/2019              Method to update membership Flag of partner Account based on the value change on segment field of Contact
* Agam Sharma               03/01/2020              Method to update custom field on contact object that is getting the extracted value of error code form Erpm Integration Message.
*************************************************************************************/

public class Core_ContactHandler {
    public static boolean runOnce = false;
    public static boolean hasRunCreate = false;
    public static boolean hasRunUpdate = false;
    public static boolean hasRunRepublish = false;
    public static boolean hasMembershipRun = false;
    public static boolean isUpdatedMailingCountry = false;

    
        /*
    * Method name  : UpdateJobFunction
    * Description  : Method to update Job Function based on the value in Job Function Code
    * Return Type  : void
    * Parameter    : map<Id, Contact>, map<Id, Contact>
    */    
    public static void UpdateJobFunction(map<Id, Contact> mapOld, map<Id, Contact> mapNew) {
         if(!runOnce) {
             Set<Id> setContactIds = new Set<Id>(); // Contacts whose Job Function Code got updated
             
             // Get the list of Contact Ids to be updated
             for (Contact contact :mapNew.values()) {
                 if (mapOld == null || mapOld.get(contact.Id) == null) { 
                     if (contact.Core_Job_Function_Code__c != null) // New Contacts that have Job Function Code
                         setContactIds.add(contact.Id);
                 }
                 
                 if (mapOld != null && mapOld.get(contact.Id).Core_Job_Function_Code__c != contact.Core_Job_Function_Code__c) // Updated Contacts whose Job Function Code got updated
                     setContactIds.add(contact.Id);
             }
             
             
             System.debug('### UpdateJobFunction() 01 ### Job Function Contact Count: ' + setContactIds.size());
             
             // Stop and Return if there are no Contacts to process
             if (setContactIds.size() == 0)
                 return;
             
             
             // Get the mappings between Job Function names and codes from the custom settings list
             Map<String, Core_Job_Function_Reference__c> mapJobFunctionReference = Core_Job_Function_Reference__c.getAll();
             
             // Store the mappings between Job Function Code and Job Function Name
             Map<String, String> mapJobCodeJobName = new Map<String, String>();
             
             for (Core_Job_Function_Reference__c jobFunctionReference :mapJobFunctionReference.values()) {
                 if (jobFunctionReference.Core_Active__c == true) // Use only Active mappings
                     mapJobCodeJobName.put(jobFunctionReference.Core_Job_Function_Code__c, jobFunctionReference.Core_Job_Function_Name__c);
             }
             
             System.debug('### UpdateJobFunction() 02 ### Job Function Code - Job Function Name: ' + mapJobCodeJobName);
             
             
             // Get the list of contacts to be updated
             List<Contact> lstContacts = [SELECT Id, Core_Job_Function__c, Core_Job_Function_Code__c FROM Contact WHERE Id IN :setContactIds];
             
             // Set the Job Function
             for (Contact contact: lstContacts) {
                 contact.Core_Job_Function__c = mapJobCodeJobName.get(contact.Core_Job_Function_Code__c);
             }
             
             runOnce = true;
             
             // Update the Contacts
             update lstContacts;
         }
     }
    
/*
* Method name  : PopulateAccountBillingCountry
* Description  : Method to populate account billing country to contact mailing country
* Return Type  : void
* Parameter    : List<Contact>
*/    
public static void UCD_ACMPopulateAccountBillingCountry(List<Contact> contacts) {
    if(!isUpdatedMailingCountry) {
        set<id> setOfAccountIds=new set<id>();
            for(Contact contact:contacts){
            if(contact.AccountId!=null)
            {
                setOfAccountIds.add(contact.AccountId);
            }
        }
        if(setOfAccountIds !=null && !setOfAccountIds.isEmpty()){
        Map<id,account> accountMap = new Map<id,account>([select id,billingCountry from account where id in :setofaccountIds]);
        for(contact contact :contacts){
            if(String.isBlank(contact.MailingCountryCode) && (String.isNotBlank(accountMap.get(contact.AccountId).billingCountry))){
            contact.MailingCountry = accountMap.get(contact.AccountId).billingCountry;
            }
          }
       }
       isUpdatedMailingCountry = true;
    }
}
    
/*
* Method name  : UpdateJobFunctionNameAndCode
* Description  : Method to update Job Function based on the value in Job Function Code
* Return Type  : void
* Parameter    : map<Id, Contact>, map<Id, Contact>
*/
    
    public static void UpdateJobFunctionNameAndCode(map<Id, Contact> mapOld, List<Contact> mapNew) {
        if(!runOnce) {
            //Set<Id> setContactIds = new Set<Id>(); // Contacts whose Job Function Code got updated
            
            // Get the mappings between Job Function names and codes from the custom settings list
            Map<String, Core_Job_Function_Reference__c> mapJobFunctionReference = Core_Job_Function_Reference__c.getAll();
            
            // Store the mappings between Job Function Code and Job Function Name
            Map<String, String> mapJobCodeJobName = new Map<String, String>();
            // Store the mappings between Job Function Name and Job Function Code
            Map<String, String> mapJobNameJobCode = new Map<String, String>();
            
            for (Core_Job_Function_Reference__c jobFunctionReference :mapJobFunctionReference.values()) {
                if (jobFunctionReference.Core_Active__c == true) { // Use only Active mappings
                    mapJobCodeJobName.put(jobFunctionReference.Core_Job_Function_Code__c, jobFunctionReference.Core_Job_Function_Name__c);
                    mapJobNameJobCode.put(jobFunctionReference.Core_Job_Function_Name__c, jobFunctionReference.Core_Job_Function_Code__c);
                }
            }
            
            System.debug('### UpdateJobFunction() ### Job Function Code - Job Function Name: ' + mapJobCodeJobName);
            System.debug('### UpdateJobFunction() ### Job Function Name - Job Function Code: ' + mapJobNameJobCode);
            system.debug('mapNew.values()' + mapNew);
            system.debug('mapOld.values()' + mapOld);
            // Get the list of Contact Ids to be updated
            for (Contact contact :mapNew) {
                system.debug('inside the new map contact -for loop ::: ' + contact);
                if(((mapOld == null || mapOld.get(contact.Id) == null) && contact.Core_Job_Function_Code__c != null) || (mapOld != null && (mapOld.get(contact.Id).Core_Job_Function_Code__c != contact.Core_Job_Function_Code__c)))
                    contact.Core_Job_Function__c = mapJobCodeJobName.get(contact.Core_Job_Function_Code__c);
                else if(((mapOld == null || mapOld.get(contact.Id) == null) && contact.Core_Job_Function__c != null) || (mapOld != null && (mapOld.get(contact.Id).Core_Job_Function__c != contact.Core_Job_Function__c)))
                    contact.Core_Job_Function_Code__c = mapJobNameJobCode.get(contact.Core_Job_Function__c);                 
            }            
            runOnce = true;            
        }
    }
    
        /*
    * Method name  : UpdateJobFunctionCode
    * Description  : Method to update Job Function Code based on the value in Job Function
    * Return Type  : void
    * Parameter    : map<Id, Contact>, map<Id, Contact>
    */
    
    public static void UpdateJobFunctionCode(map<Id, Contact> mapOld, map<Id, Contact> mapNew) {
        if(!runOnce) {
            Set<Id> setContactIds = new Set<Id>(); // Contacts whose Job Function got updated
            
            // Get the list of Contact Ids to be updated
            for (Contact contact :mapNew.values()) {
                if (mapOld == null || mapOld.get(contact.Id) == null) { 
                    if (contact.Core_Job_Function__c != null) // New Contacts that have Job Function
                        setContactIds.add(contact.Id);
                }
                
                if (mapOld != null && mapOld.get(contact.Id).Core_Job_Function__c != contact.Core_Job_Function__c) // Updated Contacts whose Job Function got updated
                    setContactIds.add(contact.Id);
            }
            
            
            System.debug('### UpdateJobFunctionCode() 01 ### Job Function Contact Count: ' + setContactIds.size());
            
            // Stop and Return if there are no Contacts to process
            if (setContactIds.size() == 0)
                return;
            
            // Get the mappings between Job Function names and codes from the custom settings list
            Map<String, Core_Job_Function_Reference__c> mapJobFunctionReference = Core_Job_Function_Reference__c.getAll();
            
            // Store the mappings between Job Function Name and Job Function Code
            Map<String, String> mapJobNameJobCode = new Map<String, String>();
            
            for (Core_Job_Function_Reference__c jobFunctionReference :mapJobFunctionReference.values()) {
                if (jobFunctionReference.Core_Active__c == true) // Use only Active mappings
                    mapJobNameJobCode.put(jobFunctionReference.Core_Job_Function_Name__c, jobFunctionReference.Core_Job_Function_Code__c);
            }
            System.debug('### UpdateJobFunctionCode() 02 ### Job Function Name - Job Function Code: ' + mapJobNameJobCode);
            
            
            // Get the list of contacts to be updated
            List<Contact> lstContacts = [SELECT Id, Core_Job_Function__c, Core_Job_Function_Code__c FROM Contact WHERE Id IN :setContactIds];
            
            // Set the Job Function
            for (Contact contact: lstContacts) {
                contact.Core_Job_Function_Code__c = mapJobNameJobCode.get(contact.Core_Job_Function__c);
            }
            runOnce = true;
            
            // Update the Contacts
            update lstContacts;
        }
    }
    
    /*
* Method name  : UpdateMembershipFlag
* Description  : Method to update membership Flag of partner Account based on the value change on segment field of Contact
* Return Type  : void
* Parameter    : map<Id, Contact>, map<Id, Contact>
*/
    public static void UpdateMembershipFlag(map<Id, Contact> mapOld, map<Id, Contact> mapNew) { 
        if(!hasMembershipRun) {
            Set<Id> updatedContactIds = new Set<Id>(); // Contacts whose Partner Program Segment field got updated
            Set<Id> contactIds = new Set<Id>(); 
            Set<Id> accountIds = new Set<Id>(); 
            Set<Id> partnerAccountIds = new Set<Id>();
            List<Account> updatedPartnerAcc = new List<Account>();
            List<Account> lstAccount = new List<Account>();
            List<contact> ContIds =new List<contact>();
            List<Core_Account_Group_Member__c> accIds = new List<Core_Account_Group_Member__c>();
            list<Core_Contact_Entitlement__c> contEntitlemetList = new  list<Core_Contact_Entitlement__c>();
            String LDRName = 'Lead Development Representative';
            
            // Get the list of Contact Ids for which segment field is updated
            for (Contact contact :mapNew.values()) {
                if ( mapOld.get(contact.Id).Core_IPA_Contact_Segment__c != contact.Core_IPA_Contact_Segment__c) { 
                    updatedContactIds.add(contact.Id);
                }     
            }  
            System.debug('updatedContactIds==>'+updatedContactIds);
            if(updatedContactIds != null && !updatedContactIds.isEmpty()){
                List<Core_Entitlement__c> LDRList = [SELECT Id from Core_Entitlement__c where name =: LDRName LIMIT 1];
                Core_Entitlement__c LDR = LDRList[0];
                if(LDRList != null && !LDRList.isEmpty()){
                    contEntitlemetList = [select id,Core_Entitlement_Id__c,Core_Contact_Id__c 
                                          from Core_Contact_Entitlement__c where Core_Contact_Id__c IN 
                                          :updatedContactIds AND Core_Entitlement_Id__c = :LDR.id AND Core_Selected__c = true AND Core_Status__c = 'Complete'];    
                }
                //Get the list of contact Ids for which segment field is updated and it is LDR contact
                for(Core_Contact_Entitlement__c contEnt : contEntitlemetList){
                    contactIds.add(contEnt.Core_Contact_Id__c);
                }
                
                if(contactIds != null && !contactIds.isEmpty()){
                    ContIds = [select id,AccountId from Contact where id IN :contactIds];
                }
                for (Contact contId : ContIds){
                    accountIds.add(contId.AccountId);
                }
                if(accountIds != null && !accountIds.isEmpty()){
                    accIds = [select id,Core_Partner_Account_Id__c from Core_Account_Group_Member__c where Core_Intel_Account_Id__c IN :accountIds];
                }
                for(Core_Account_Group_Member__c accGrpMem : accIds)
                {
                    partnerAccountIds.add(accGrpMem.Core_Partner_Account_Id__c) ;
                }  
                if(partnerAccountIds != null && !partnerAccountIds.isEmpty()){
                    lstAccount = [select id,Name,Core_PMP_Membership_Change_Ind__c from Account where id IN :partnerAccountIds];
                } 
                List<Account> accList = new List<Account>();
                for(Account acc : lstAccount){
                    acc.Core_PMP_Membership_Change_Ind__c = true;
                    accList.add(acc);
                }
                try{
                    if(accList != null && !accList.isEmpty()) {  
                        update accList;
                        hasMembershipRun = true;
                    } 
                }
                catch(DmlException  e){
                    System.debug('The following exception has occurred: ' + e.getMessage());
                }
            }
        }           
    }
    
    /*
* Method name  : SeteRPMIntStatusToPendingOnContactCreate
* Description  : Set eRPM integartion satus to pending on new contact creation
* Return Type  : void
* Parameter    : List<contact>
*/
    
    public static void SeteRPMIntStatusToPendingOnContactCreate(List<Contact> contacts) {
        if(!hasRunCreate) {
            Set<Id> contactIds = new Set<Id>(); 
            for(contact con : contacts){
                if(!con.Core_IPS_Employee_Customer__c){
                    contactIds.add(con.Id);
                }
            }
            
            if(contactIds.size() >0 ){
                hasRunCreate = true;
                system.debug('SeteRPMIntStatusToPendingOnContactCreate '+ contactIds);
                Core_ERPM_Outbound_Integration.evaluateAndSetERPMOutboundIntegrationStatus(null, contactIds, false);
            }
        }
    }   
    
    public static void SeteRPMIntStatusToPendingOnContactUpdate(List<Contact> newContacts, Map<Id, Contact> oldContacts) {
        if(!hasRunUpdate) {
            Set<Id> contactIds = new Set<Id>(); 
            for(Contact newCon : newContacts) {
                if(!newCon.Core_IPS_Employee_Customer__c 
                   && ( newCon.Core_Job_Function_Code__c != oldContacts.get(newCon.Id).Core_Job_Function_Code__c
                       || newCon.FirstName != oldContacts.get(newCon.Id).FirstName
                       || newCon.LastName != oldContacts.get(newCon.Id).LastName
                       || newCon.Email != oldContacts.get(newCon.Id).Email
                       || newCon.MailingStateCode != oldContacts.get(newCon.Id).MailingStateCode
                       || newCon.MailingCountryCode != oldContacts.get(newCon.Id).MailingCountryCode
                       || (newCon.Core_Enterprise_Id__c != oldContacts.get(newCon.Id).Core_Enterprise_Id__c && newCon.LastModifiedById == Label.AGS_OBM_Integration)
                       || newCon.Phone != oldContacts.get(newCon.Id).Phone
                       || newCon.MobilePhone != oldContacts.get(newCon.Id).MobilePhone
                       || newCon.Core_Job_Function__c != oldContacts.get(newCon.Id).Core_Job_Function__c
                       || newCon.Core_Profession__c != oldContacts.get(newCon.Id).Core_Profession__c
                       || newCon.Salutation != oldContacts.get(newCon.Id).Salutation
                       || newCon.Core_Do_Not_Contact__c != oldContacts.get(newCon.Id).Core_Do_Not_Contact__c
                       || (String.isNotBlank(oldContacts.get(newCon.Id).Core_IPA_Partner_Role__c) 
                           && newCon.Core_IPA_Partner_Role__c != oldContacts.get(newCon.Id).Core_IPA_Partner_Role__c)
                       || (newCon.Core_English_Only_First_Name__c != oldContacts.get(newCon.Id).Core_English_Only_First_Name__c 
                           && String.isNotBlank(oldContacts.get(newCon.Id).Core_English_Only_First_Name__c))
                       || (newCon.Core_English_Only_Last_Name__c != oldContacts.get(newCon.Id).Core_English_Only_Last_Name__c 
                           && String.isNotBlank(oldContacts.get(newCon.Id).Core_English_Only_Last_Name__c))                  
                      )) {
                          system.debug('conatct update');
                          System.debug('Old Name : ' +oldContacts.get(newCon.Id).FirstName + 'New Name :' +newCon.FirstName);
                          contactIds.add(newCon.Id);
                      }
            }
            
            
            if(contactIds.size() >0 ){
                hasRunUpdate = true;
                System.debug('SeteRPMIntStatusToPendingOnContactUpdate');
                Core_ERPM_Outbound_Integration.evaluateAndSetERPMOutboundIntegrationStatus(null, contactIds, false);
            }
        }
    }
    
    public static void SeteRPMAGSIntStatusToPendingOnRepublish(List<Contact> newContacts, Map<Id, Contact> oldContacts) {
        system.debug('republish hasRun '+ hasRunRepublish);
        if(!hasRunRepublish) {
            List<Contact> contacts = new List<Contact>(); 
            for(Contact newCon : newContacts) {  
                system.debug('befr if :'+newCon.Core_Republish_OBM_s__c +': employee '+newCon.Core_IPS_Employee_Customer__c);
                system.debug('oldContacts.get(newCon.Id).Core_Republish_OBM_s__c'+ oldContacts.get(newCon.Id).Core_Republish_OBM_s__c);
                if(newCon.Core_Republish_OBM_s__c && !newCon.Core_IPS_Employee_Customer__c
                   && newCon.Core_Republish_OBM_s__c != oldContacts.get(newCon.Id).Core_Republish_OBM_s__c)                   
                {
                    system.debug('re publish conatct update');
                    contacts.add(newCon);
                }
            }
            
            if(contacts.size() >0 ){
                hasRunRepublish = true;
                Core_ERPM_Outbound_Integration.forceSetERPMOutboundIntegrationStatus(contacts);
            }
        }
    }
    
    
        /*
     * Method name  : updateInquiryOwnerOnConOwnerUpdate
     * Description  : Method to update Owner field of Inquiry records on Contact owner's update
     * Return Type  : void
     * Parameter    : List<Contact> newContactList, Map<Id, Contact> oldMap
     */   
   /* public static void updateInquiryOwnerOnConOwnerUpdate(List<Contact> newContactList, Map<Id, Contact> oldMap){
        List<Core_Inquiry__c> updatedInquiryOwner = new List<Core_Inquiry__c>();
        List<Core_Inquiry__c> updateInqOwnerList = new List<Core_Inquiry__c>();
        Set<Id> setContactId = new Set<Id>();
        
        for(Contact conRec : newContactList){
            if(conRec.OwnerId != oldMap.get(conRec.Id).OwnerId){            
                setContactId.add(conRec.Id);              
            }            
        }
        
        //Query all the inquiries for the owner updated Conatct
        if(!setContactId.isEmpty() && setContactId.size()!=0){
            updatedInquiryOwner = [SELECT id,Core_AcccountName__c, Core_Contact_Inquiries__c, OwnerId, Core_Contact_Inquiries__r.OwnerId FROM Core_Inquiry__c WHERE Core_Contact_Inquiries__c=: setContactId];
        }
        
        //Populate the Inquiry Owner with associated Contact's owner
        for(Core_Inquiry__c inq : updatedInquiryOwner){
            if(inq.OwnerId == oldMap.get(inq.Core_Contact_Inquiries__c).OwnerId){
                inq.OwnerId = inq.Core_Contact_Inquiries__r.OwnerId ;
                updateInqOwnerList.add(inq);
            }
        }
        //Update the Inquiry list records with Contact's Owner                               
        if(!updateInqOwnerList.isEmpty() && updateInqOwnerList.size()!=0){
            Database.update(updateInqOwnerList);        
        }     
    }*/
    
    
     /*
     * Method name  : SendUpdatedContactsDatatoLicence
     * Description  : Method to Call PSG License related functions on change of contact name and email
     * Return Type  : void
     * Parameter    : List<Contact> newContactList, Map<Id, Contact> oldMap
     */   
    
        public static void SendUpdatedContactsDatatoLicence(List<Contact> newContactList, Map<Id, Contact> oldMap){
            List<Contact> ConLst= new List<Contact>();
            Set<Id> ContactIdSet =new  Set<Id>();
            for(Contact conRec : newContactList){
                if(conRec.FirstName != oldMap.get(conRec.Id).FirstName ||conRec.LastName != oldMap.get(conRec.Id).LastName || conRec.Email != oldMap.get(conRec.Id).Email){            
                  ConLst.add(conRec);              
            } 
                //Added By dnyanada To call PSG Method for Retriggering Sharing Logic
                if(conRec.Core_Account__c!=oldMap.get(conRec.Id).Core_Account__c){
                    ContactIdSet.add(conRec.id);
                }
        }
            
            if(ConLst.size() >0){
                system.debug('****ConLst'+ConLst);
                Sales_UpdateContactDetails.updateContactDetails_LicenseHost(ConLst);
                Sales_UpdateContactDetails.updateContactDetails_LicenseAdminDelegate (ConLst);

            }
             //Added By dnyanada To call PSG Method for Retriggering Sharing Logic
            if(ContactIdSet.size()>0){
                //Sales_LicenseAdminDelegateUtility.shareLicenseAndHostRecordsForAccountChange(ContactIdSet);
            }
        }
    
}