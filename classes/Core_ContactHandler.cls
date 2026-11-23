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
* Agam Sharma               17/07/2020              Method to update custom field on contact object that is getting the extracted value of error code form Erpm Integration Message.
* Praveena Yegurla          30/03/2021              Modified method "UpdateMembershipFlag" - To reduce SOQL count from 5 to 1
* Praveena Yegurla          16/04/2021              Entitlement Status Detail record creation on error in ERPM-inbound-blackbox functionality - Moved to Core_IntegrationInboundMessageHandler
*************************************************************************************/

public without sharing class Core_ContactHandler {
    public static boolean runOnce = false;
    public static boolean hasRunCreate = false;
    public static boolean hasRunUpdate = false;
    public static boolean hasRunRepublish = false;
    public static boolean hasMembershipRun = false;
    public static boolean isCommunityUpdated = false;
    public static String approvedStatusVal = 'Approved';
    public static boolean isUpdatedMailingCountry = false;
    public static String NAval = 'NA';
    public static Boolean isExecuted = true;
    
    /*
* Method name  : UpdateJobFunction
* Description  : Method to update Job Function based on the value in Job Function Code
* Return Type  : void
* Parameter    : map<Id, Contact>, map<Id, Contact>
*/
    //Commented by Gireeshk as it's not used anymore and no test coverage
    /*public static void UpdateJobFunction(map<Id, Contact> mapOld, map<Id, Contact> mapNew) {
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
}*/
    
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
            
            // Get the list of Contact Ids to be updated
            for (Contact contact :mapNew) {
                if(((mapOld == null || mapOld.get(contact.Id) == null) && contact.Core_Job_Function_Code__c != null) || (mapOld != null && (mapOld.get(contact.Id).Core_Job_Function_Code__c != contact.Core_Job_Function_Code__c)))
                    contact.Core_Job_Function__c = mapJobCodeJobName.get(contact.Core_Job_Function_Code__c);
                else if(((mapOld == null || mapOld.get(contact.Id) == null) && contact.Core_Job_Function__c != null) || (mapOld != null && (mapOld.get(contact.Id).Core_Job_Function__c != contact.Core_Job_Function__c)))
                    contact.Core_Job_Function_Code__c = mapJobNameJobCode.get(contact.Core_Job_Function__c);
            }
            runOnce = true;
        }
    }
    
/*
* Method name  : PopulateAccountBillingCountry
* Description  : Method to populate account billing country to contact mailing country
* Return Type  : void
* Parameter    : List<Contact>
*/    
public static void ACM_SetContactAttribute(List<Contact> contacts) {
    if(!isUpdatedMailingCountry) {
        set<id> setOfAccountIds=new set<id>();
            for(Contact contact:contacts){
            if(contact.AccountId!=null && String.IsBlank(contact.MailingCountryCode))
            {
                setOfAccountIds.add(contact.AccountId);
            }
        }
        if(setOfAccountIds !=null && !setOfAccountIds.isEmpty()){
       // Map<id,account> accountMap = new Map<id,account>([select id,billingCountry from account where id in :setofaccountIds]);
        for(contact contact :contacts){
            if(String.isBlank(contact.MailingCountryCode) && (String.isNotBlank(contact.Mailing_Country_Region__c))){
            contact.MailingCountry =  contact.Mailing_Country_Region__c;
            }
          }
       }
       isUpdatedMailingCountry = true;
    }
}
    /*
* Method name  : UpdateJobFunctionCode
* Description  : Method to update Job Function Code based on the value in Job Function
* Return Type  : void
* Parameter    : map<Id, Contact>, map<Id, Contact>
*/
    //Commented by Gireeshk as it's not used anymore and no test coverage
    /*public static void UpdateJobFunctionCode(map<Id, Contact> mapOld, map<Id, Contact> mapNew) {
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
}*/
    
    /*
* Method name  : UpdateMembershipFlag
* Description  : Method to update membership Flag of partner Account based on the value change on segment field of Contact
* Return Type  : void
* Parameter    : map<Id, Contact>, map<Id, Contact>
*/
    /*public static void UpdateMembershipFlag(map<Id, Contact> mapOld, map<Id, Contact> mapNew) {
        if (!hasMembershipRun) {
            Set<Id> updatedContactIds = new Set<Id>(); // Contacts whose Partner Program Segment field got updated
            Set<Id> contactIds = new Set<Id>();
            Set<Id> accountIds = new Set<Id>();
            Set<Id> partnerAccountIds = new Set<Id>();
            List<Account> updatedPartnerAcc = new List<Account>();
            List<Account> lstAccount = new List<Account>();
            List<contact> ContIds = new List<contact>();
            List<Core_Account_Group_Member__c> accIds = new List<Core_Account_Group_Member__c>();
            list<Core_Contact_Entitlement__c> contEntitlemetList = new List<Core_Contact_Entitlement__c>();
            String LDRName = 'Lead Development Representative';
            
            // Get the list of Contact Ids for which segment field is updated
            for (Contact contact : mapNew.values()) {
                if (mapOld.get(contact.Id).Core_IPA_Contact_Segment__c != contact.Core_IPA_Contact_Segment__c) {
                    updatedContactIds.add(contact.Id);
                }	
            }
            if (updatedContactIds != null && !updatedContactIds.isEmpty()) {
                if (Schema.sObjectType.Core_Contact_Entitlement__c.fields.Name.isAccessible()) {
                    contEntitlemetList = [
                        SELECT id, Core_Entitlement_Id__c, Core_Contact_Id__c
                        FROM Core_Contact_Entitlement__c
                        //  WHERE Core_Contact_Id__c IN :updatedContactIds AND Core_Entitlement_Id__c = :LDR.id AND Core_Selected__c = TRUE AND Core_Status__c = 'Complete'
                        WHERE Core_Contact_Id__c IN :updatedContactIds AND Core_Entitlement_Id__r.Name = :LDRName AND Core_Selected__c = TRUE AND Core_Status__c = 'Complete'
                    ];
                
                    //Get the list of contact Ids for which segment field is updated and it is LDR contact
                    for (Core_Contact_Entitlement__c contEnt : contEntitlemetList) {
                        contactIds.add(contEnt.Core_Contact_Id__c);
                    }
                
                    for (Id contId : contactIds) {
                        if(mapNew.get(contId).Core_IPA_One_Partner_Id__c!=null)
                            accountIds.add(mapNew.get(contId).Core_IPA_One_Partner_Id__c);
                    }
                
                
                    List<Account> accList = new List<Account>();
                        for (Id accId : accountIds) {
                        Account acc = new Account();
                        acc.Id=accId;
                        acc.Core_PMP_Membership_Change_Ind__c = true;
                        accList.add(acc);
                    }
                    try {
                        if (accList != null && !accList.isEmpty()) {
                                update accList;
                                hasMembershipRun = true;
                        }
                    } catch (DmlException e) {
                        UCD_ACM_Logger.error('Core_ContactHandler','UpdateMembershipFlag','Message: '+e.getMessage()+'. StackTrace: '+e.getStackTraceString(),NULL);
                        }
                }
            }
        }
    }*/
    
    
    //added by manikanta US789741
    public static void UpdateExternalUserLanguage(map<Id, Contact> mapOld, map<Id, Contact> mapNew) {
        Set<Id> setContactIds = new set<Id>();
        for (Contact contact : mapNew.values()) {
            if (mapOld.get(contact.Id).Core_eRPM_Language_Code__c != contact.Core_eRPM_Language_Code__c && contact.Core_eRPM_Language_Code__c != null) {
                setContactIds.add(contact.Id);
            }
        }
        if(!setContactIds.isEmpty()){
            Core_UpdateExternalUserLanguage updateJob = new Core_UpdateExternalUserLanguage(setContactIds, mapNew);
            // enqueue the job for processing
            ID jobID = System.enqueueJob(updateJob);
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
                Core_ERPM_Outbound_Integration.evaluateAndSetERPMOutboundIntegrationStatus(null, contactIds, false);
            }
        }
    }
    
    public static void SeteRPMIntStatusToPendingOnContactUpdate(List<Contact> newContacts, Map<Id, Contact> oldContacts) {
        if(!hasRunUpdate) {
            Set<Id> contactIds = new Set<Id>();
            for(Contact newCon : newContacts) {
                if(/*(newCon.Core_Login_Status__c == 'Active' || String.isblank(newCon.Core_Login_Status__c)) && */newCon.LastModifiedById != Label.ERPM_OBM_Integration && !newCon.Core_IPS_Employee_Customer__c
                   && ( newCon.Core_Job_Function_Code__c != oldContacts.get(newCon.Id).Core_Job_Function_Code__c
                       || newCon.FirstName != oldContacts.get(newCon.Id).FirstName
                       || newCon.LastName != oldContacts.get(newCon.Id).LastName
                       || newCon.Email != oldContacts.get(newCon.Id).Email
                       || newCon.MailingStateCode != oldContacts.get(newCon.Id).MailingStateCode
                       || newCon.MailingCountryCode != oldContacts.get(newCon.Id).MailingCountryCode
                       || (newCon.Core_Enterprise_Id__c != oldContacts.get(newCon.Id).Core_Enterprise_Id__c && (newCon.LastModifiedById == Label.AGS_OBM_Integration || newCon.LastModifiedById == Label.IPA_Integration_User))
                       || newCon.Phone != oldContacts.get(newCon.Id).Phone
                       || newCon.MobilePhone != oldContacts.get(newCon.Id).MobilePhone
                       || newCon.Core_Job_Function__c != oldContacts.get(newCon.Id).Core_Job_Function__c
                       || newCon.Core_Profession__c != oldContacts.get(newCon.Id).Core_Profession__c
                       || newCon.Salutation != oldContacts.get(newCon.Id).Salutation
                       || newCon.Core_Sales_Do_Not_Contact_Ind__c != oldContacts.get(newCon.Id).Core_Sales_Do_Not_Contact_Ind__c //Gireesh:US942207:DNC:Sales - Do Not Contact
                       //Due to recursive erpm outbound prod issue commented below 2 lines
                       //|| newCon.Core_Do_Not_Contact_Dtm__c != oldContacts.get(newCon.Id).Core_Do_Not_Contact_Dtm__c //Gireesh:US942207:DNC:Sales - Do Not Contact Date                      
                       //|| newCon.Core_Marketing_Do_Not_Contact_Dtm__c != oldContacts.get(newCon.Id).Core_Marketing_Do_Not_Contact_Dtm__c  //Gireesh:US942207:DNC:Marketing - Do Not Contact Date
                       || newCon.AccountId != oldContacts.get(newCon.Id).AccountId
                       || newCon.Core_Do_Not_Contact__c != oldContacts.get(newCon.Id).Core_Do_Not_Contact__c //Gireesh:US942207:DNC:Marketing - Do Not Contact
                       || (String.isNotBlank(oldContacts.get(newCon.Id).Core_IPA_PartnerRole__c)
                           && newCon.Core_IPA_PartnerRole__c != oldContacts.get(newCon.Id).Core_IPA_PartnerRole__c)
                       || (String.isNotBlank(oldContacts.get(newCon.Id).Core_Preferred_Language__c)
                           && newCon.Core_Preferred_Language__c != oldContacts.get(newCon.Id).Core_Preferred_Language__c)
                       || (newCon.Core_English_Only_First_Name__c != oldContacts.get(newCon.Id).Core_English_Only_First_Name__c
                           && String.isNotBlank(oldContacts.get(newCon.Id).Core_English_Only_First_Name__c))
                       || (newCon.Core_English_Only_Last_Name__c != oldContacts.get(newCon.Id).Core_English_Only_Last_Name__c
                           && String.isNotBlank(oldContacts.get(newCon.Id).Core_English_Only_Last_Name__c))
                      )) {
                          contactIds.add(newCon.Id);
                      }
            }
            
            if(contactIds.size() >0 ){
                hasRunUpdate = true;
                Core_Entitlement_Outbound_Integrations.contactUpdate=true;
                Core_ERPM_Outbound_Integration.evaluateAndSetERPMOutboundIntegrationStatus(null, contactIds, false);
            }
        }
    }
    
    public static void SeteRPMAGSIntStatusToPendingOnRepublish(List<Contact> newContacts, Map<Id, Contact> oldContacts) {
        if(!hasRunRepublish) {
            List<Contact> contacts = new List<Contact>();
            for(Contact newCon : newContacts) {
                if(newCon.Core_Republish_OBM_s__c && !newCon.Core_IPS_Employee_Customer__c
                   && newCon.Core_Republish_OBM_s__c != oldContacts.get(newCon.Id).Core_Republish_OBM_s__c)
                {
                    contacts.add(newCon);
                }
            }
            if(contacts.size() >0 ){
                hasRunRepublish = true;
                Core_ERPM_Outbound_Integration.forceSetERPMOutboundIntegrationStatus(contacts);
            }
        }
    }
    public static void emptyAGSStatusOnInsert(List<Contact> newContacts){//Addeb by shreyash as part of unhandled exceptions
        for(Contact rec: newContacts){
            if(!(String.isBlank(rec.Core_AGS_Integration_Status__c))){
                rec.Core_AGS_Integration_Status__c = null;
            }
        }
    }
    
    /*
* Method name  : insertRecordInIntegrationStatusDetail
* Description  : Insert and Update Record in Entitlement Status Detail Object
* Return Type  : void
* Parameter    : List<contact>, Map<Id, Contact> & List<A_E_Integration_Status_Detail__c>
*/
    /* public Static Void insertRecordInIntegrationStatusDetail(List<Contact> ContactList,Map<Id, Contact> oldContacts,List<A_E_Integration_Status_Detail__c> StatusDetailID){
List<A_E_Integration_Status_Detail__c> IntegrtionStatusDetailList=new List<A_E_Integration_Status_Detail__c>();
A_E_Integration_Status_Detail__c IntegrationStatusDetail=new A_E_Integration_Status_Detail__c();

List<Contact_Message__c> contactMsgList=new List<Contact_Message__c>();
Integer Flag=0;
ID Id;
for(Contact ContList:ContactList){
Id=ContList.id;
}
//contactMsgList=[Select id,Inbound_Message__r.Core_Error_Description__c,Inbound_Message__r.Core_Source_System__c,Inbound_Message__r.Core_Error_Code__c,Contact__r.Id from Contact_Message__c  where Contact__r.id =:Id ORDER BY createdDate DESC];

for(Contact ContList:ContactList){
if(ContList.Core_ERPM_Integration_Status__c!=oldContacts.get(ContList.Id).Core_ERPM_Integration_Status__c)
{
Flag=1;

if(StatusDetailID.size()>0){
IntegrationStatusDetail.Id=StatusDetailID[0].Id;


}
IntegrationStatusDetail.A_E_Contact_Id__c=Id;
IntegrationStatusDetail.A_E_Integration_Type_Txt__c='ERPM';
IntegrationStatusDetail.A_E_Integration_Status_Txt__c  =ContList.Core_ERPM_Integration_Status__c;
if((ContList.Core_ERPM_Integration_Message__c==NULL)||(!ContList.Core_ERPM_Integration_Message__c.contains('Error Code:'))){
IntegrationStatusDetail.A_E_Integration_Error_Txt__c='';
IntegrationStatusDetail.A_E_Integration_Error_Description_Txt__c='';
}

else if(ContList.Core_ERPM_Integration_Message__c!=Null && ContList.Core_ERPM_Integration_Message__c.contains('Error Code:')){
IntegrationStatusDetail.A_E_Integration_Error_Txt__c= ContList.Core_ERPM_Integration_Message__c.substring(88,92);
IntegrationStatusDetail.A_E_Integration_Error_Description_Txt__c=ContList.Core_ERPM_Integration_Message__c.substring(94,ContList.Core_ERPM_Integration_Message__c.length()-1);
}

}

else If(ContList.Core_AGS_Integration_Status__c!=oldContacts.get(ContList.Id).Core_AGS_Integration_Status__c){
Flag=1;
if(StatusDetailID.size()>0){
IntegrationStatusDetail.Id=StatusDetailID[0].Id;
}
IntegrationStatusDetail.A_E_Contact_Id__c=Id;
IntegrationStatusDetail.A_E_Integration_Status_Txt__c=ContList.Core_AGS_Integration_Status__c;
IntegrationStatusDetail.A_E_Integration_Type_Txt__c='AGS';
IntegrationStatusDetail.A_E_Integration_Error_Txt__c='';
IntegrationStatusDetail.A_E_Integration_Error_Description_Txt__c='';
*/
    //if(contactMsgList.Size()>0){
    //  If(ContactMsgList[0].Inbound_Message__r.Core_Source_System__c=='AGS'){
    /*IntegrationStatusDetail.A_E_Integration_Error_Txt__c=ContactMsgList[0].Inbound_Message__r.Core_Error_Code__c;
IntegrationStatusDetail.A_E_Integration_Error_Description_Txt__c=ContactMsgList[0].Inbound_Message__r.Core_Error_Description__c;*/
    //  }
    //  }
    
    /*     }

}
List<A_E_Error_Mapping__c> ErrorMapping=[Select id,A_E_Error_Code_Txt__c from A_E_Error_Mapping__c where A_E_Error_Code_Txt__c=:IntegrationStatusDetail.A_E_Integration_Error_Txt__c];
If(ErrorMapping.Size()>0){
IntegrationStatusDetail.A_E_Error_Mapping_Id__c=ErrorMapping[0].id;
}
else{
IntegrationStatusDetail.A_E_Error_Mapping_Id__c=NULL;
}
IntegrtionStatusDetailList.add( IntegrationStatusDetail);

if(Flag==1){
Upsert IntegrtionStatusDetailList;
}
} */
    
    /*
* Method name  : updateInquiryOwnerOnConOwnerUpdate
* Description  : Method to update Owner field of Inquiry records on Contact owner's update
* Return Type  : void
* Parameter    : List<Contact> newContactList, Map<Id, Contact> oldMap
*/   
    /*public static void updateInquiryOwnerOnConOwnerUpdate(List<Contact> newContactList, Map<Id, Contact> oldMap){
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
* Method name  : UpdateSoftContactIndicator
* Description  : Method to update Soft Contact Flag of ACR based on the value change on EnterpriseID field of Contact
* Return Type  : void
* Parameter    : list<Contact>, map<Id, Contact>
*/
    public static void updateSoftContactIndicator(list<Contact>contLst, Map<Id,Contact>oldMap, Map<Id,Contact> newMap) {
        Set<Id> contactSet = new Set<Id>();
        List<PRM_Account_Contact_Relationship__c> acrFinalList= new List<PRM_Account_Contact_Relationship__c>();
        List<PRM_Account_Contact_Relationship__c> acrPartnerAdminFinalList= new List<PRM_Account_Contact_Relationship__c>();
        List<PRM_Account_Contact_Relationship__c> acrEmployeeFinalList= new List<PRM_Account_Contact_Relationship__c>();
        Set<PRM_Account_Contact_Relationship__c> acrPartnerAdminSet= new Set<PRM_Account_Contact_Relationship__c>();
        Set<PRM_Account_Contact_Relationship__c> acrEmployeeSet= new Set<PRM_Account_Contact_Relationship__c>();
        
        try{
            for(Contact con: contLst){
                if((oldMap!=null && !oldMap.isEmpty())&&((oldMap.get(con.id).Core_Login_Status__c != con.Core_Login_Status__c )&&
                (con.Core_Login_Status__c == 'Deleted'|| con.Core_Login_Status__c == System.Label.IPA_Downgrade_to_B2C
                || con.Core_Login_Status__c == 'Disabled'|| con.Core_Login_Status__c == 'Expired'))){
                    contactSet.add(con.Id);
                }
            }
            if(contactSet != null && !contactSet.IsEmpty()){
                Schema.DescribeFieldResult fieldResult = Contact.Core_Deletion_Reason__c.getDescribe();
                List<Schema.PicklistEntry> values = fieldResult.getPicklistValues();
                Map<String, String> deletionreasonValeLabelMap = new Map<String, String>();
                for( Schema.PicklistEntry v : values) {
                    deletionreasonValeLabelMap.put(v.getValue(),v.getLabel());
                }
                for(PRM_Account_Contact_Relationship__c acr:[SELECT Id,PRM_Soft_Contact__c,PRM_InActive_Ind__c,PRM_Contact_Id__c,
                                                             PRM_Relationship_Id__r.PRM_Default_Relationship_Ind__c,
                                                             PRM_Relationship_Id__r.PRM_Mandatory_Relationship_Ind__c,PRM_Relationship_Id__c FROM PRM_Account_Contact_Relationship__c
                                                             WHERE PRM_InActive_Ind__c=false AND PRM_AGS_Identity_Creation_Fail__c = false AND PRM_Soft_Contact__c=false AND PRM_Contact_Id__c IN:contactSet]){
                                                                 acr.PRM_InActive_Ind__c=true;
                                                                 acr.PRM_Soft_Contact__c=true;
                                                                 acr.PRM_End_Date_Dt__c = System.today();
                                                                 //TWC729-9097 - Add login status as status reason on ACR where deletion reason is blank on contact 
                                                                 if(String.isNotBlank(newMap.get(acr.PRM_Contact_Id__c).Core_Deletion_Reason__c)){
                                                                    acr.PRM_Status_Reason_Txt__c = deletionreasonValeLabelMap.get(newMap.get(acr.PRM_Contact_Id__c).Core_Deletion_Reason__c);
                                                                 }
                                                                 else{
                                                                    acr.PRM_Status_Reason_Txt__c = newMap.get(acr.PRM_Contact_Id__c).Core_Login_Status__c;
                                                                 }

                                                                 /*Utkarsh - Comment both if else as it was not required and causing issue to remove partner role from contact when contact has both active PA and employee relation and its identity got deleted*/
                                                                 /*if(acr.PRM_Relationship_Id__r.PRM_Default_Relationship_Ind__c==false){         
acrPartnerAdminSet.add(acr);
}else{                                                            
acrEmployeeSet.add(acr);
}*/
                                                                 acrFinalList.add(acr);
                                                             }
            }
            
            
            /*if(acrPartnerAdminSet != null && acrPartnerAdminSet.size()>0){
acrPartnerAdminFinalList.addall(acrPartnerAdminSet);
update acrPartnerAdminFinalList;
//String obj = JSON.serialize(acrPartnerAdminFinalList);
//dbOperations(obj);
}
if(acrEmployeeSet != null && acrEmployeeSet.size()>0){
acrEmployeeFinalList.addall(acrEmployeeSet);
update acrEmployeeFinalList;
//String obj = JSON.serialize(acrEmployeeFinalList);
//futureACROperation(obj);
}*/
            if(acrFinalList != null && !acrFinalList.IsEmpty()){
                update acrFinalList;
            }    
        }catch(Exception ex){
            PRM_ErrorUtilityClass.logError(ex);
        }
    }  
    //Added by Agate Team
    public static void assignPartnerCommunityContactEntitlements(map<Id,Contact> cntMapOld, List<Contact> conList) {    
        Map<id, List<String>> contactIdCommunitymap = new Map<Id, List<String>>();        
        Map<id, List<String>> newConComMap = new Map<Id, List<String>>();
        Set<String> communitiesAvailable = new Set<String>();
        Map<id, List<String>> ipaComComMap = new Map<Id, List<String>>();
        Map<Id,List<String>> OptOutcontactParComMap = new Map<Id,List<String>>();
        communitiesAvailable.addAll((System.Label.PRM_Available_Communities).split(';'));
        Set<Id> noComOptOut = new Set<Id>();        
        Set<Id> ContactIds = new Set<Id>();            
        map<string,string> subMap=new map<string,string>();
        list<PRM_ContactSubscriptionAssociation__c> UpsertConSub =new list<PRM_ContactSubscriptionAssociation__c>();
        
        List<Core_Contact_Entitlement__c> ceRecordsToInsert =  new List<Core_Contact_Entitlement__c>();
        List<Core_Contact_Entitlement__c> ceRecordsToDelete =  new List<Core_Contact_Entitlement__c>();
        
        for(Contact ctRecord: conList){            
            Contact  contactOld ;
            if(cntMapOld != null){
                contactOld = (Contact) cntMapOld.get(ctRecord.id) ;
            }
            if((contactOld == null && ctRecord.Core_IPA_Partner_Community__c != null)
               || (contactOld != null && contactOld.Core_IPA_Partner_Community__c != ctRecord.Core_IPA_Partner_Community__c)){
                   ContactIds.add(ctRecord.id);    
               }
            
            if(contactOld != null && contactOld.Core_IPA_Partner_Community__c != ctRecord.Core_IPA_Partner_Community__c && ctRecord.Core_Login_Status__c =='Active'){
                if(ctRecord.Core_IPA_Partner_Community__c!=null){
                    contactIdCommunitymap.put(ctRecord.Id, ctRecord.Core_IPA_Partner_Community__c.split(';'));
                    newConComMap.put(ctRecord.Id, ctRecord.Core_IPA_Partner_Community__c.split(';'));     //TWC729-2258
                }else if(ctRecord.Core_IPA_Partner_Community__c ==null || !communitiesAvailable.contains(ctRecord.Core_IPA_Partner_Community__c)){
                    noComOptOut.add(ctRecord.Id);
                }
            }  
        }      
        if(!ContactIds.IsEmpty()){
            List<Core_Contact_Entitlement__c>contactEntilementList = new List<Core_Contact_Entitlement__c>();
            
            
            //Below code is added as part of userstory TWC729-2033, This will create enrollment request record when contact IPA Community is updated 
            map<id, List<PRM_Partner_Community_Enrollment_Request__c>> comEnrolReqMap = new map<id,List<PRM_Partner_Community_Enrollment_Request__c>>();
            for(PRM_Partner_Community_Enrollment_Request__c parComEnrReq : [Select Id,PRM_Contact_Id__c,PRM_Partner_Community_Nm__c,PRM_Status_Nm__c from PRM_Partner_Community_Enrollment_Request__c where PRM_Contact_Id__c in :ContactIds ]){
                if(comEnrolReqMap.containsKey(parComEnrReq.PRM_Contact_Id__c)){
                    comEnrolReqMap.get(parComEnrReq.PRM_Contact_Id__c).add(parComEnrReq);
                }else{
                    comEnrolReqMap.put(parComEnrReq.PRM_Contact_Id__c,new List<PRM_Partner_Community_Enrollment_Request__c>{parComEnrReq});  
                }
            }
            
            
            if(PRM_partnerComEnrReqUtility.requestedInitiatedByCommunity==false && isExecuted == true){
                checkCommunityRequestAvail(contactIdCommunitymap, comEnrolReqMap);
                isExecuted = false;
            }
            
            for(PRM_Partner_Community_Enrollment_Request__c parComEnrReq : [Select Id,PRM_Contact_Id__c,PRM_Partner_Community_Nm__c,PRM_Status_Nm__c from PRM_Partner_Community_Enrollment_Request__c where PRM_Status_Nm__c ='Rejected' and PRM_Contact_Id__c in :ContactIds]){
                if(OptOutcontactParComMap.containsKey(parComEnrReq.PRM_Contact_Id__c)){
                    OptOutcontactParComMap.get(parComEnrReq.PRM_Contact_Id__c).add(parComEnrReq.PRM_Partner_Community_Nm__c);
                }else{
                    OptOutcontactParComMap.put(parComEnrReq.PRM_Contact_Id__c,new List<String>{parComEnrReq.PRM_Partner_Community_Nm__c});  
                }
            }
            
            //Logic ending for userstory TWC729-2033
            
            /****************************** Create Contact Subscription starts - TWC729-2258 *************************************/
            if(contactIdCommunitymap.size()>0 || noComOptOut.size()>0){
                //get values from Subscription MetaData            
                for(PRM_Partner_Subscription__c PSub :[select id,Name,PRM_Community__c from PRM_Partner_Subscription__c where PRM_Community__c in :communitiesAvailable and PRM_InActive_Ind__c = false]){
                    subMap.put(PSub.PRM_Community__c, string.valueof(PSub.Id));
                }
                list<PRM_ContactSubscriptionAssociation__c> CSubList =new list<PRM_ContactSubscriptionAssociation__c>([select id,Name,PRM_Contact_Id__c,PRM_Partner_Subscription_Id__r.Name,PRM_Partner_Subscription_Id__r.PRM_Subscription_Cd__c,PRM_Partner_Subscription_Id__r.PRM_InActive_Ind__c,PRM_Partner_Subscription_Id__r.PRM_Community__c,PRM_Status_Nm__c from PRM_ContactSubscriptionAssociation__c where PRM_Partner_Subscription_Id__r.PRM_Community__c in :communitiesAvailable and PRM_Contact_Id__c in :ContactIds]);
                //TWC729-2258
                //fetch all Contact Subscriptions
                if(CSubList.size()>0){
                    for(PRM_ContactSubscriptionAssociation__c CSub :CSubList)
                    {
                        if(contactIdCommunitymap.containskey(CSub.PRM_Contact_Id__c)  ){
                            if(contactIdCommunitymap.get(CSub.PRM_Contact_Id__c).contains(CSub.PRM_Partner_Subscription_Id__r.PRM_Community__c)){
                                if(CSub.PRM_Status_Nm__c=='Inactive')
                                {
                                    CSub.PRM_Status_Nm__c='Active';
                                    UpsertConSub.add(CSub); 
                                }         
                            }else{
                                if(CSub.PRM_Status_Nm__c=='Active')
                                {
                                    CSub.PRM_Status_Nm__c='Inactive';
                                    UpsertConSub.add(CSub); 
                                }     
                            }
                            list<string> newComValues= newConComMap.get(CSub.PRM_Contact_Id__c);
                            integer subindex=newComValues.indexOf(CSub.PRM_Partner_Subscription_Id__r.PRM_Community__c);
                            if(subindex != -1){
                                newComValues.remove(subindex);
                            }
                            //newConComMap - This will have all the contacts with newly opted in communities. 
                            newConComMap.put(CSub.PRM_Contact_Id__c, newComValues);
                        }
                        if(noComOptOut.size() >0){
                            if(CSub.PRM_Status_Nm__c=='Active')
                            {
                                CSub.PRM_Status_Nm__c='Inactive';
                                UpsertConSub.add(CSub); 
                            }     
                        }
                    }
                    if(!newConComMap.isEmpty()){
                        for(Id CommId: newConComMap.keyset() ){
                            List<String> NewaddedComms =  newConComMap.get(CommId);
                            Integer LenComm = NewaddedComms.size() ;
                            for(Integer i=0 ; i < LenComm ; i ++){
                                if(communitiesAvailable.contains(NewaddedComms[i]) && subMap != null  && subMap.containskey(NewaddedComms[i])) {
                                    PRM_ContactSubscriptionAssociation__c subs = new PRM_ContactSubscriptionAssociation__c();
                                    subs.PRM_Contact_Id__c = CommId ;
                                    subs.PRM_Partner_Subscription_Id__c = subMap.get(NewaddedComms[i])  ;
                                    subs.PRM_Status_Nm__c='Active';
                                    UpsertConSub.add(subs); 
                                }
                            } 
                        }
                    }
                }
                else{
                    for(Id CommId: ContactIds ){
                        if(!contactIdCommunitymap.isEmpty()){
                            List<String> NewaddedComms =  contactIdCommunitymap.get(CommId);
                            if(NewaddedComms.size() > 0){
                                Integer LenComm = NewaddedComms.size() ;
                                for(Integer i=0 ; i < LenComm ; i ++){
                                    if(communitiesAvailable.contains(NewaddedComms[i]) && subMap != null  && subMap.containskey(NewaddedComms[i])) {   
                                        PRM_ContactSubscriptionAssociation__c subs = new PRM_ContactSubscriptionAssociation__c();
                                        subs.PRM_Contact_Id__c = CommId ;
                                        subs.PRM_Partner_Subscription_Id__c = subMap.get(NewaddedComms[i])  ;
                                        subs.PRM_Status_Nm__c='Active';
                                        UpsertConSub.add(subs); 
                                    }
                                } 
                            }
                            
                        }
                    }
                }
                if(!UpsertConSub.IsEmpty()) {
                    upsert UpsertConSub;
                }
            }
            
            /****************************** Create Contact Subscription Ends -TWC729-2258*************************************/   
            
            
            //Logic ending for userstory TWC729-2033
            
            // get contact Entitlement records 
            if(contactIdCommunitymap!=Null && contactIdCommunitymap.size()>0 && contactIdCommunitymap.keySet()!=null){      
                Map<id, Map<String,Core_Contact_Entitlement__c>> contactIdEntitlementsMap = new Map<Id, Map<String,Core_Contact_Entitlement__c>>();        
                for(Core_Contact_Entitlement__c ce : [Select ID,Core_Contact_Id__c,Core_Selected__c,Core_Entitlement_Id__c,Core_Entitlement_Id__r.Name,Core_Status__c  from Core_Contact_Entitlement__c where Core_Entitlement_Id__r.Name in :Label.PRM_Commuinty_Entitlements.split(';') and Core_Contact_Id__c in :contactIdCommunitymap.keySet()]){
                    contactEntilementList.add(ce);
                    if(contactIdEntitlementsMap.size()>0 && contactIdEntitlementsMap.containsKey(ce.Core_Contact_Id__c)){
                        contactIdEntitlementsMap.get(ce.Core_Contact_Id__c).put(ce.Core_Entitlement_Id__r.Name,ce);
                    }else{
                        contactIdEntitlementsMap.put(ce.Core_Contact_Id__c, new Map<String,Core_Contact_Entitlement__c>{ce.Core_Entitlement_Id__r.Name=>ce});
                    }
                }
                
                //get entitlement matrix records
                Map<String, PRM_VXEnttlmntMatrix__c> communityVXEntMat = new Map<String, PRM_VXEnttlmntMatrix__c>();
                Map<String, String> entitlementNameCommnityName = new Map<String, String>();
                for(PRM_VXEnttlmntMatrix__c eachEntitleMatrix : [Select Id,Communities__c,PRM_Entitlement_Id__c,PRM_Entitlement_Id__r.name from PRM_VXEnttlmntMatrix__c where recordType.developerName = 'Community_Entitlements' and PRM_IsActive_Ind__c = true]){
                    communityVXEntMat.put(eachEntitleMatrix.Communities__c, eachEntitleMatrix);
                    entitlementNameCommnityName.put(eachEntitleMatrix.Communities__c, eachEntitleMatrix.PRM_Entitlement_Id__r.name);
                }
                
                // upsert entitltments
                
                List<String> autoApprovePartCom = LabelConfiguration__mdt.getInstance('Auto_Approve_Partner_Communities').Value__c.split(';');
                for(Id contactId :contactIdCommunitymap.keySet()){
                    for(String community : contactIdCommunitymap.get(contactId)){
                        //Checking current contact community values matched with Custom Metadata values
                        if(!autoApprovePartCom.isEmpty() && autoApprovePartCom.contains(community)){
                            String communityEntitlement;
                            if(entitlementNameCommnityName.size()>0 && entitlementNameCommnityName.containsKey(community)){
                                communityEntitlement = entitlementNameCommnityName.get(community);
                            }
                            Core_Contact_Entitlement__c ce = new Core_Contact_Entitlement__c();
                            ce.Core_Selected__c = true;
                            ce.Core_Status__c='Pending';   // Changed it to pending after consultaiton with draco team. While inserting/updating, entitlement should have status as pending.
                            ce.Core_Data_Loaded__c = true;
                            if(contactIdEntitlementsMap.size()>0 && contactIdEntitlementsMap.containsKey(contactId)){                   
                                if(contactIdEntitlementsMap.get(contactId).containsKey(communityEntitlement)){
                                    if(!contactIdEntitlementsMap.get(contactId).get(communityEntitlement).Core_Selected__c){
                                        Core_Contact_Entitlement__c ced = new Core_Contact_Entitlement__c();
                                        ced.Id = contactIdEntitlementsMap.get(contactId).get(communityEntitlement).Id;
                                        if(!ceRecordsToDelete.contains(ced)){
                                        ceRecordsToDelete.add(ced);
                                        }
                                        ce.Core_Contact_Id__c = contactIdEntitlementsMap.get(contactId).get(communityEntitlement).Core_Contact_Id__c;
                                        ce.Core_Entitlement_Id__c = contactIdEntitlementsMap.get(contactId).get(communityEntitlement).Core_Entitlement_Id__c; 
                                        if(!ceRecordsToInsert.contains(ce)){
                                            ceRecordsToInsert.add(ce);}                     
                                    }
                                }else{
                                    if (communityVXEntMat.containsKey(community)){
                                    ce.Core_Contact_Id__c = contactId;
                                    ce.Core_Entitlement_Id__c = communityVXEntMat.get(community).PRM_Entitlement_Id__c;   
                                    if(!ceRecordsToInsert.contains(ce)){
                                        ceRecordsToInsert.add(ce);}
                                }        
                                }        
                            }else{                    
                                if(communityVXEntMat.containsKey(community)){
                                ce.Core_Contact_Id__c = contactId;
                                ce.Core_Entitlement_Id__c = communityVXEntMat.get(community).PRM_Entitlement_Id__c;   
                                if(!ceRecordsToInsert.contains(ce)){
                                    ceRecordsToInsert.add(ce);}
                            }
                        }
                        }
                        
                        
                        if(OptOutcontactParComMap.size() > 0 && OptOutcontactParComMap.containsKey(contactId)){
                            List<String> optOutCom = OptOutcontactParComMap.get(contactId);
                            for(String s:optOutCom ){
                                if(communitiesAvailable.contains(s)){
                                    String communityEntitlement;
                                    if(entitlementNameCommnityName.size()>0 && entitlementNameCommnityName.containsKey(s)){
                                        communityEntitlement = entitlementNameCommnityName.get(s);
                                    }
                                    
                                    if(contactIdEntitlementsMap.containsKey(contactId) && contactIdEntitlementsMap.get(contactId).get(communityEntitlement) != null){
                                        Core_Contact_Entitlement__c ce = new Core_Contact_Entitlement__c();
                                        ce.Core_Contact_Id__c = contactId;
                                        Core_Contact_Entitlement__c ced1 = new Core_Contact_Entitlement__c();
                                        ced1.Id = contactIdEntitlementsMap.get(contactId).get(communityEntitlement).Id;
                                        if(!ceRecordsToDelete.contains(ced1)){
                                            ceRecordsToDelete.add(ced1);  
                                        }
                                        ce.Core_Selected__c = false;
                                        ce.Core_Status__c='Pending';
                                        ce.Core_Data_Loaded__c = true;
                                        ce.Core_Contact_Id__c = contactIdEntitlementsMap.get(contactId).get(communityEntitlement).Core_Contact_Id__c;
                                        ce.Core_Entitlement_Id__c = contactIdEntitlementsMap.get(contactId).get(communityEntitlement).Core_Entitlement_Id__c;   
                                        if(!ceRecordsToInsert.contains(ce)){
                                            ceRecordsToInsert.add(ce);  
                                        }
                                    }
                                    
                                    
                                }
                                
                                
                            }
                            
                        }
                        
                    }
                }        
                
            }
            
            if(conList.size()>0 && !conList.isEmpty()){
                
                for (Core_Contact_Entitlement__c conEnt : [Select ID,Core_Contact_Id__c,Core_Selected__c,Core_Entitlement_Id__c,Core_Entitlement_Id__r.Name,Core_Status__c  from Core_Contact_Entitlement__c where Core_Entitlement_Id__r.Name in :Label.PRM_Commuinty_Entitlements.split(';') and Core_Contact_Id__c in :conList]){
                    if(noComOptOut.contains(conEnt.Core_Contact_Id__c)){
                        conEnt.Core_Selected__c = false;
                        conEnt.Core_Status__c='Pending';
                        conEnt.Core_Data_Loaded__c = true;
                        if(!ceRecordsToDelete.contains(conEnt)){
                        ceRecordsToDelete.add(conEnt);
                        }

                        Core_Contact_Entitlement__c cei = new Core_Contact_Entitlement__c();
                        cei.Core_Contact_Id__c = conEnt.Core_Contact_Id__c;
                        cei.Core_Selected__c = false;
                        cei.Core_Status__c='Pending';
                        cei.Core_Entitlement_Id__c = conEnt.Core_Entitlement_Id__c;
                        cei.Core_Data_Loaded__c = true;
                        if(!ceRecordsToInsert.contains(cei)){
                            ceRecordsToInsert.add(cei);}
                        
                    }
                    
                }
            }
            
            if(ceRecordsToDelete.size() > 0){
                //Added By Ankit Sharma : code scan 13-07-2023
                //Removed By Ankit Sharma : 18-10-2023
               // if (Account.sObjectType.getDescribe().isDeletable()){
                    Database.delete(ceRecordsToDelete,false);
                //}
            }
            if(ceRecordsToInsert.size() > 0){
                database.insert(ceRecordsToInsert,false);
            }
        }
    }
    
    //Below code is added as part of userstory TWC729-2033, This will create enrollment request record when contact IPA Community is updated
    public static PRM_Partner_Community_Enrollment_Request__c createEnrollmentRequest(Id conId, String ctcomm, String Status){
        PRM_Partner_Community_Enrollment_Request__c newRequest = new PRM_Partner_Community_Enrollment_Request__c();
        newRequest.PRM_Contact_Id__c = conId;
        newRequest.PRM_Partner_Community_Nm__c = ctcomm;
        newRequest.PRM_Status_Nm__c = Status;
        newRequest.PRM_Start_Date_Dt__c = System.now();
        return newRequest;
    }
    
    public static void checkCommunityRequestAvail(Map<id, List<String>> contactIdCommunitymap, map<id, List<PRM_Partner_Community_Enrollment_Request__c>> comEnrolReqMap){
        List<PRM_Partner_Community_Enrollment_Request__c> enrolReqToUpsert = new List<PRM_Partner_Community_Enrollment_Request__c>();
        if(!contactIdCommunitymap.isEmpty() && contactIdCommunitymap.size()>0){
            for(Id conId : contactIdCommunitymap.keySet()){
                for(String ctcomm : contactIdCommunitymap.get(conId)){
                    if(ctcomm != NAval){
                        if(comEnrolReqMap.size() > 0){
                            boolean isCommunityAvailable = false;
                            for(PRM_Partner_Community_Enrollment_Request__c comRequest : comEnrolReqMap.get(conId)){
                                if(!(contactIdCommunitymap.get(conId).contains(comRequest.PRM_Partner_Community_Nm__c)) && PRM_partnerComEnrReqUtility.requestedInitiatedByCommunity == false){
                                    if(comRequest.PRM_Status_Nm__c == 'Approved'){
                                        comRequest.PRM_Status_Nm__c ='Rejected';
                                        if(userInfo.getName() == 'Integration User' || userInfo.getName() == 'ERPM.OBM Integration' || userInfo.getName() == 'IPA Registration Integration User'){
                                            comRequest.PRM_Community_Change_Agent__c = comRequest.PRM_Contact_Id__r.Email;}
                                        else{
                                            comRequest.PRM_Community_Change_Agent__c = userInfo.getUserEmail();
                                        }
                                        comRequest.PRM_End_Date_Dt__c = System.now();
                                        enrolReqToUpsert.add(comRequest);
                                    }
                                }
                                if(comRequest.PRM_Partner_Community_Nm__c== ctcomm && comRequest.PRM_Status_Nm__c !=approvedStatusVal){
                                    comRequest.PRM_Status_Nm__c = approvedStatusVal;
                                    comRequest.PRM_Start_Date_Dt__c =System.now();
                                    comRequest.PRM_End_Date_Dt__c = null;
                                    enrolReqToUpsert.add(comRequest);
                                    isCommunityAvailable = true;
                                }else if(comRequest.PRM_Partner_Community_Nm__c== ctcomm){
                                    isCommunityAvailable = true;
                                } 
                            } 
                            if(isCommunityAvailable == false){
                                enrolReqToUpsert.add(createEnrollmentRequest(conId,ctcomm,approvedStatusVal));
                            }
                        } else{
                            enrolReqToUpsert.add(createEnrollmentRequest(conId,ctcomm,approvedStatusVal));
                        } 
                    } 
                }
            }
        }
        else if(contactIdCommunitymap.isEmpty() && comEnrolReqMap.size()>0 && PRM_partnerComEnrReqUtility.requestedInitiatedByCommunity==false && isExecuted == true){         //If all Communities are rejected
            Map<id, Contact> mapIdToContact  = new Map<id, Contact>([select id,Core_IPA_Partner_Community__c from Contact where id in: comEnrolReqMap.keySet() ]);
            for(Id conId : comEnrolReqMap.keySet()){
                if(mapIdToContact.get(conId).Core_IPA_Partner_Community__c == null){
                    for(PRM_Partner_Community_Enrollment_Request__c comRequest : comEnrolReqMap.get(conId) ){
                        if(comRequest.PRM_Status_Nm__c == approvedStatusVal){
                            comRequest.PRM_Status_Nm__c = 'Rejected';
                            if(userInfo.getName() == 'Integration User' || userInfo.getName() == 'ERPM.OBM Integration' || userInfo.getName() == 'IPA Registration Integration User'){
                                comRequest.PRM_Community_Change_Agent__c = comRequest.PRM_Contact_Id__r.Email;}
                            else{
                                comRequest.PRM_Community_Change_Agent__c = userInfo.getUserEmail();
                            }
                            comRequest.PRM_End_Date_Dt__c = System.now();
                            enrolReqToUpsert.add(comRequest);
                        }
                    }
                }
            } 
        }
        try{
            if(enrolReqToUpsert.size() > 0){
                PRM_partnerComEnrReqUtility.isTriggerExecuted = false;
                upsert enrolReqToUpsert;
            }
        }catch(Exception exp){
            Core_Log_Entry.logEntryWithDetails('Core_ContactHandler', 'IPA','checkCommunityRequestAvail', 'exception','Exception occured while processing',exp.getMessage()+';;;'+exp.getStackTraceString() , ' ', ' ', ' ');
        }
        
    }
    //Logic ending for userstory TWC729-2033
    public static void trackCommunityChanges(map<Id, Contact> mapOld, List<Contact> mapNew){        
        for(Contact newCon:mapNew)
        {
            if(mapOld == null || (mapOld != null && newCon.Core_IPA_Partner_Community__c != mapOld.get(newCon.Id).Core_IPA_Partner_Community__c))
            {
                newCon.PRM_Community_History__c = newCon.Core_IPA_Partner_Community__c;
                if(userInfo.getName() == 'Integration User' || userInfo.getName() == 'ERPM.OBM Integration' || userInfo.getName() == 'IPA Registration Integration User')
                    newCon.PRM_Community_Change_Agent__c = newCon.Email;
                else{
                    newCon.PRM_Community_Change_Agent__c = userInfo.getUserEmail();
                }
                Core_MergeContactHandler.isRecurssive = true;
            }
        }
    }
    
    // create tracker record when External User State field is changed
    // this will be called only from After update of contact
    public static void checkExternalUserState(Map<Id,Contact> newContactsMap, Map<Id, Contact> oldContactMp){
        
        Map<String, Id> contactIdRegReqMp = new Map<String, Id>();
        Map<String, String> updatedContactsMap = new Map<String, String>();
        for(Contact ct : newContactsMap.values()){
            if(ct.External_User_State__c!=null && oldContactMp.get(ct.Id).External_User_State__c != ct.External_User_State__c){
                updatedContactsMap.put(ct.Email.toLowerCase(),ct.Id );
            }
        }
        // get the registration record for this contacts
        if(updatedContactsMap!=null && !updatedContactsMap.isEmpty()){
            for(PRM_Registration_Request__c regrec : [select id, PRM_Email_ID__c, RecordType.DeveloperName from PRM_Registration_Request__c where PRM_Channel_Program_Level_txt__c = 'Intel Partner Alliance' and PRM_Email_ID__c in :updatedContactsMap.keySet() order by createddate desc]){
                if(!contactIdRegReqMp.containsKey(regrec.PRM_Email_ID__c.toLowerCase())){
                    contactIdRegReqMp.put(regrec.PRM_Email_ID__c.toLowerCase(),regrec.Id);
                }
            }
        }
        
        Set<String> existingContactRecrds = new Set<String>();
        // get existing tracker records
        List<PRM_Registration_Tracker__c> trackerRecordsToUpdate = new List<PRM_Registration_Tracker__c>();  
        if(!contactIdRegReqMp.isEmpty() || !updatedContactsMap.isEmpty()){
        for(PRM_Registration_Tracker__c regTracker : [select id, Stage__c,PRM_contact__c, PRM_Email__c from PRM_Registration_Tracker__c where stage__c in ('52','53') AND IsActive__c = true and ((PRM_contact__c in :updatedContactsMap.values() or PRM_Email__c in :updatedContactsMap.keySet() or PRM_Registration__c in :contactIdRegReqMp.values()))]){
            existingContactRecrds.add(regTracker.PRM_Email__c);
            if(regTracker.PRM_contact__c==null && (regTracker.PRM_Email__c!=null)){
                if(!contactIdRegReqMp.isEmpty() && contactIdRegReqMp.containsKey(regTracker.PRM_Email__c.toLowerCase()) && newContactsMap.get(contactIdRegReqMp.get(regTracker.PRM_Email__c.toLowerCase())).External_User_State__c=='Accepted'){
                    regTracker.Stage__c='52';
                    regTracker.PRM_Current_Step__c = 52.0;
                                                                                  }else{
                    regTracker.Stage__c='53';
                    regTracker.PRM_Current_Step__c = 53.0;}
                regTracker.PRM_Registration__c =!contactIdRegReqMp.isEmpty() && contactIdRegReqMp.containsKey(regTracker.PRM_Email__c)?contactIdRegReqMp.get(regTracker.PRM_Email__c):null;
                                                                                  }else{                    
                if(newContactsMap.containsKey(regTracker.PRM_contact__c) && newContactsMap.get(regTracker.PRM_contact__c).External_User_State__c=='Accepted'){
                    regTracker.Stage__c='52';
                    regTracker.PRM_Current_Step__c = 52.0;
                                                                                                                                                                                                                                   }else{
                    regTracker.Stage__c='53';
                    regTracker.PRM_Current_Step__c = 53.0;
                                                                                                                                                                                                                                   }
                                                                                      regTracker.PRM_Registration__c =!contactIdRegReqMp.isEmpty() && contactIdRegReqMp.containsKey(regTracker.PRM_Email__c)?contactIdRegReqMp.get(regTracker.PRM_Email__c):null;
                                                                                  }
            trackerRecordsToUpdate.add(regTracker);
        } 
    }       
        // add entries for newly updated contacts
        Map<String,PRM_Registration_Tracker__c> emailforACRToTracker = new Map<String,PRM_Registration_Tracker__c>();
        for(String email : updatedContactsMap.keySet()){
            email=email.toLowerCase();
            PRM_Registration_Tracker__c rt = new PRM_Registration_Tracker__c();
            if(!existingContactRecrds.contains(email)){
                rt.PRM_Email__c = email;
                rt.PRM_contact__c = updatedContactsMap.get(email);
                rt.PRM_Registration__c = contactIdRegReqMp.get(email);
                rt.Stage__c = newContactsMap.get(updatedContactsMap.get(email)).External_User_State__c=='Accepted'? '52':'53';
                rt.PRM_Account__c = newContactsMap.get(updatedContactsMap.get(email)).AccountId;
                rt.PRM_Current_Step__c=rt.Stage__c=='52'?52.0:53.0;
                rt.PRM_Step_Number__c =14.0;
                emailforACRToTracker.put(rt.PRM_Email__c,rt);
            }
            
        }
        if(!emailforACRToTracker.isEmpty()){
            if(PRM_Contact_Bulk_DataLoad_Utility.contactBulkLoad){
                Map<String, PRM_Bulk_Data_Upload__c> emailTOblkRec = new Map<String, PRM_Bulk_Data_Upload__c>();
                for(PRM_Bulk_Data_Upload__c bulkRec : [
                    SELECT Id,
                    PRM_Upload_Type__c,
                    PRM_ContactEmail__c
                    FROM PRM_Bulk_Data_Upload__c 
                    WHERE PRM_ContactEmail__c IN :emailforACRToTracker.keySet()
                    ORDER BY Createddate desc]
                ){
                    if(!emailTOblkRec.containsKey(bulkRec.PRM_ContactEmail__c)){
                        emailTOblkRec.put(bulkRec.PRM_ContactEmail__c,bulkRec);
                    }
                }
                for(PRM_Registration_Tracker__c  rt : emailforACRToTracker.values()){
                    if(emailTOblkRec.containskey(rt.PRM_Email__c)){
                        rt.PRM_Registration_Type__c =  emailTOblkRec.get(rt.PRM_Email__c).PRM_Upload_Type__c;
                trackerRecordsToUpdate.add(rt);
            }
                }
            }else {
                Map<String, PRM_Account_Contact_Relationship__c> emailTOACR = new Map<String, PRM_Account_Contact_Relationship__c>();
                for (PRM_Account_Contact_Relationship__c acr : [Select id,PRM_Contact_Id__r.Email,PRM_Source_Agent__c from PRM_Account_Contact_Relationship__c where PRM_InActive_Ind__c = false and PRM_Contact_Id__r.Email in :emailforACRToTracker.keySet()]) {
                    emailTOACR.put(acr.PRM_Contact_Id__r.Email,acr);
                }
                for(PRM_Registration_Tracker__c  rt : emailforACRToTracker.values()){
                    if(emailTOACR.containskey(rt.PRM_Email__c)){
                        rt.PRM_Registration_Type__c =  emailTOACR.get(rt.PRM_Email__c).PRM_Source_Agent__c;
                        trackerRecordsToUpdate.add(rt);
                    }
                }
            }
            
        }
        if(!trackerRecordsToUpdate.isEmpty()){
            Database.upsert(trackerRecordsToUpdate);
        }
        
    }
    
    /*
    * Method name  : checkForDuplicateContact
    * Description  : Method to restrict duplicate contacts creation at the same time interval 
    * Return Type  : void
    * Parameter    : List<contact>
    */
    public static void checkForDuplicateContact(List<Contact> contactRecords){
        List<String> newEmails=new List<String>();
        try{
            for(Contact con : contactRecords){
                if(con.Email!=null){
                    if(newEmails.contains(con.Email)){
                        con.addError('A contact with this email already exist. Please use the existing contact.');
                    }
                    else{
                        newEmails.add(con.Email);
                    }
                }
            }
        }
        catch(Exception ex) {
            UCD_ACM_Logger.error('Core_ContactHandler','checkForDuplicateContact','Message: '+ex.getMessage()+'. StackTrace: '+ex.getStackTraceString(),NULL);
        } 
        finally {
            UCD_ACM_Logger.setLogDetails();
        }
    }
}