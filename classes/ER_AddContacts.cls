/******************************************************************************************************************************************
Class Name  : ER_AddContacts
Test Class Name : ER_AddContactsTest, Coverage:98%
Version     : 1.0 
Created Date: 19 April 2024
Function    : This apex class is called from new registration after flow to create contacts for the new registrations
Note: Leveraging Apex customization approach because when multiple registrations records of multiple 
entitlements for same user are created in a single transaction, flow is creating multiple contacts for 
same user. To overcome this limitation we are going with apex customization.
Modification Log :
* Developer                 Date                    Description
* ----------------------------------------------------------------------------      
* Narahari		            19/04/2024              Original version
*	****************************************************************************************************************************************/

public without sharing class ER_AddContacts {
    public static Id conRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Intel Contact').getRecordTypeId();
    public static string case_Origin = 'SFDC';
    public static string case_Project = 'Registration';
    public static string case_Scope = 'Error in ER_AddContacts';
    public static string case_Severity = 'error';
    //Called from Apex class 'EBR Framework Reg Request After Flow' to create contacts
    @invocableMethod(label='ER_Contact_Bulk_Creation' description='This method is used to create contacts in bulk')
    public static List<newRegFlowInput> setContacts(List<newRegFlowInput> flowInputs){
        Map<String,Contact> emailContactcreationMap = New Map<String,Contact>();
        Map<String,String> countryCodeMap= New Map<String,String>();
        List<PRM_Registration_Request__c> newRegsList = New List<PRM_Registration_Request__c>();
        List<String> countryCodeList = New List<String>();
        for(newRegFlowInput flowInput : flowInputs){
            newRegsList.add(flowInput.newRegistration);
            countryCodeList.add(flowInput.countryCode);
        }
        if(countryCodeList.size() > 0){
            for(Core_Country_Code_Mapping__c countryCode : [Select Id,Country_Code__c,ISO_Code__c FROM Core_Country_Code_Mapping__c WHERE Country_Code__c IN : countryCodeList]){
                countryCodeMap.put(countryCode.Country_Code__c,countryCode.ISO_Code__c);
            }
        }
        for(PRM_Registration_Request__c newReg : newRegsList){
            if(!emailContactcreationMap.containsKey(newReg.PRM_Email_ID__c)){
                emailContactcreationMap.put(newReg.PRM_Email_ID__c,assignContactValues( newReg, countryCodeMap));
            }/*else if(newReg.PRM_Source__c == 'PSG' || newReg.PRM_Source__c == 'IQR'){
emailContactcreationMap.put(newReg.PRM_Email_ID__c,assignContactValues(emailContactcreationMap.get(newReg.PRM_Email_ID__c), newReg, countryCodeMap));
} */
        }
        if(emailContactcreationMap.values().size() > 0){
            List<Database.SaveResult> insertResults = database.insert(emailContactcreationMap.values(),false);
            List<Core_Log_Entry__c> logEntryInsertList = new List<Core_Log_Entry__c>();
            for (Database.SaveResult sr : insertResults) {
                if (!sr.isSuccess()){                
                    for(Database.Error ex : sr.getErrors()) {
                        system.debug('Error Message '+ex.message);
                        Core_Log_Entry__c objCLE = new Core_Log_Entry__c(
                            Core_Origin__c = case_Origin,
                            Core_Project__c = case_Project,
                            Core_Scope__c = case_Scope,
                            Core_Severity__c = case_Severity,
                            Core_Message__c = 'Error in line 36 in ER_Contact_Bulk_Creation '+ex.Message,
                            Core_When__c = system.now(),
                            Core_Details__c = ex.Message
                        );
                        logEntryInsertList.add(objCLE);
                    }
                }
            }
            database.insert(logEntryInsertList,false);
        }
        return flowInputs;
    }
    //Reusable Apex Method used to assign values to new contact
    public static Contact assignContactValues(PRM_Registration_Request__c newReg, Map<String, String> countryCodeMap){
        Contact newCon = New Contact();
        newCon.firstName = newReg.PRM_First_Name__c;
        newCon.LastName = newReg.PRM_Last_Name__c;
        newCon.Email = newReg.PRM_Email_ID__c;
        newCon.Phone = newReg.PRM_Person_Phone_Number__c;
        newCon.Core_Profession__c = newReg.PRM_Profession__c;
        newCon.AccountId = newReg.PRM_Salesforce_ID__c;
        newCon.RecordTypeId = conRecordTypeId;
        newCon.Core_Enterprise_Id__c = newReg.PRM_Enterprise_ID__c;
        newCon.MailingCountry = newReg.PRM_Contact_Country__c;
        newCon.MailingCountryCode = newReg.PRM_Contact_Country__c;
        if(countryCodeMap.containsKey(newReg.PRM_Contact_Country__c)){
            newCon.MailingCountry = countryCodeMap.get(newReg.PRM_Contact_Country__c);
            newCon.MailingCountryCode = countryCodeMap.get(newReg.PRM_Contact_Country__c);  
        }
        newCon.Core_Preferred_Language__c = newReg.PRM_Preferred_Language__c != null ? newReg.PRM_Preferred_Language__c : 'ENG';
        /*  if(newReg.PRM_Source__c == 'PSG'){
newCon.AccountId = label.PRM_PSG_Account_id;
}
if(newReg.PRM_Source__c == 'IQR'){
//newCon.Core_Login_Id__c = newReg.PRM_Contact_Login_ID__c;
//newCon.Core_IPA_PartnerRole__c = newReg.PRM_Partner_Role__c;
newCon.Core_IPS_Intel_Support_Owner__c = label.PRM_IPARegistration_Integration_UserId;
} */
        return newCon;
    }
    //Wrapper class used as parameter to send values from flow.
    public class newRegFlowInput {
        @InvocableVariable(required=true)
        public PRM_Registration_Request__c newRegistration;
        
        @InvocableVariable(required=true)
        public string countryCode;
    }
}