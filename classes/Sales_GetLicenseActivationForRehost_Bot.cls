public without sharing class Sales_GetLicenseActivationForRehost_Bot {
    public class LicenseInput {
        @InvocableVariable
        public Sales_License__c licenseObject;
        @InvocableVariable
        public String contactId;
    }
    public class LicenseOutput {
        @InvocableVariable
        public String sActivationCode;
        @InvocableVariable
        public String licenseType;
        @InvocableVariable
        public String primaryAdminContact;
        @InvocableVariable
        public String licenseId;
    }
    @InvocableMethod(label='Get License Activation Code for Rehost')
    public static List<LicenseOutput> getHostDetails(List<LicenseInput> inputs) {
        //List<LicenseOutput> outputList = new List<LicenseOutput>();-- Unused Variable
        String loggedIndContactId='';
        Set<Id> licenseIds = new Set<Id>();
        for(LicenseInput input : inputs){
            licenseIds.add(input.licenseObject.id);
            loggedIndContactId=input.contactId; 
        }
        LicenseOutput output = new LicenseOutput();
        List<LicenseOutput> liclst = new List<LicenseOutput>();
        for(Sales_License__c lcObj : [Select Id,Sales_Tool_License_Type__c,Sales_License_Activation_Code__c,Sales_License_Primary_Admin_Contact__c from Sales_License__c WHERE id IN : licenseIds and Sales_License_Web_Display_Flag__c=true and Sales_License_Type__c!='Optional' ]){
            output.sActivationCode = lcObj.Sales_License_Activation_Code__c;
            output.licenseType = lcObj.Sales_Tool_License_Type__c;
            output.primaryAdminContact = loggedIndContactId;
            output.licenseId = lcObj.Id;
            liclst.add(output);
        }
        return liclst;
    }
}