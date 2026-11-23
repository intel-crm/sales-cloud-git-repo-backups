@isTest
public without sharing class Sales_fetchActivationCode_Bot {
    /*public class LicenseInput {
        @InvocableVariable
        public Sales_License__c licenseObject;
    }
    public class LicenseOutput {
        @InvocableVariable
        public String sActivationCode;
        @InvocableVariable
        public String licenseType;
    }
    @InvocableMethod(label='Get Activation Code')
    public static List<LicenseOutput> getHostDetails(List<LicenseInput> inputs) {
        //List<LicenseOutput> outputList = new List<LicenseOutput>();-- unused Variable
        Set<Id> licenseIds = new Set<Id>();
        for(LicenseInput input : inputs){
            licenseIds.add(input.licenseObject.id);
        }
        LicenseOutput output = new LicenseOutput();
        List<LicenseOutput> liclst = new List<LicenseOutput>();
        for(Sales_License__c lcObj : [Select Id,Sales_Tool_License_Type__c,Sales_License_Activation_Code__c from Sales_License__c WHERE id IN : licenseIds and Sales_License_Web_Display_Flag__c=true and Sales_License_Type__c!='Optional']){
            output.sActivationCode = lcObj.Sales_License_Activation_Code__c;
            output.licenseType = lcObj.Sales_Tool_License_Type__c;
            liclst.add(output);
        }
        return liclst;
    }*/
}