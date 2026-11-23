@isTest
public class Sales_FetchLicenseActivationCode {
    /*public class LicenseActivationCodeInput {
        @InvocableVariable
        public Sales_License__c LicenseData ;
    }
    public class Result {
        @InvocableVariable
        public String LicenseId ;
        @InvocableVariable
        public String LicenseType ;
    }
    @InvocableMethod(label='Get Activation Code of License')
    public static List<Result> getActivationCode(List<LicenseActivationCodeInput> licenseInputs) {
        List<Result> res = new List<Result>();
        for (LicenseActivationCodeInput licActivationInput : licenseInputs) {
            Result r = new Result();
            r.LicenseId = licActivationInput.LicenseData.Id;
            r.LicenseType = licActivationInput.LicenseData.Sales_Tool_License_Type__c;
            res.add(r); 
        } 
        return res;
    }
    public with sharing class wrapperClass{
        @InvocableVariable public  String salesLicenseActivationCode;
        @InvocableVariable public  String productName;
        @InvocableVariable public  Integer salesQuantity;
        @InvocableVariable public  String salesLicenseMaintenanceExpDt;
        @InvocableVariable public  String salesLicenseType;
    }*/
}