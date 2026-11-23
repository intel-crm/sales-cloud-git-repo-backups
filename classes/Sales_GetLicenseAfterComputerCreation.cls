public without sharing class Sales_GetLicenseAfterComputerCreation {
    public class LicenseOutput {
        @InvocableVariable
        public String Computer_Name;
        @InvocableVariable
        public String Sales_ProductName;
        @InvocableVariable
        public String SalesMaintainenceExpDate;
        @InvocableVariable
        public String Sales_LicenseExpirationDate;
        @InvocableVariable
        public String primarycomputerId;
    }
    public class LicenseInput {
        @InvocableVariable
        public String Sales_Activation_Code;            
    }
    @InvocableMethod(label='Get After License Details')
    public static List<LicenseOutput> getLicenseDetails(List<LicenseInput> licenseInputs) {
        Set<String> licenseActivationCodeSet = new Set<String>();
        for (LicenseInput lcInput : licenseInputs) {
            licenseActivationCodeSet.add(lcInput.Sales_Activation_Code);
        }
        List<Sales_License__c> licenseList = [SELECT Id,Sales_License_Host_Node_Id__c, Sales_License_Activation_Code__c,Sales_License_Product__c,Sales_License_Product__r.Name,Sales_License_Maintenance_Exp_Dt__c,
                                              Sales_License_Host_Node_Id__r.Sales_Computer_Name_Txt__c,Sales_License_Order__r.Sales_Order_Reason__c, Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_Prod_Tool_Type_Nm__c,
                                              Sales_License_Primary_Admin_Contact__c,Sales_License_Expiration_Date_Dt__c, Sales_License_Lic_User_Contact_ID__c,Sales_License_Web_Display_Flag__c,Sales_License_Status__c,
                                              Sales_License_Order_Product__r.Product2.Core_Product_Ext_Attribute_Id__r.Core_SW_Prod_Expiration_Duration_Nbr__c,Sales_License_Host_Node_Id__r.Name,
                                              Sales_License_Order_Product__r.Product2.SBQQ__SubscriptionTerm__c,Sales_License_Order__r.Type
                                              FROM Sales_License__c where Id in :licenseActivationCodeSet];
        Map<String, Sales_License__c> licenseRecordMap = new Map<String, Sales_License__c>(); 
        if (licenseList.size() > 0) {
            for (Sales_License__c licItem : licenseList) {
                licenseRecordMap.put(licItem.Id, licItem);
            }
        }
        List<LicenseOutput> licenseOutputs = new List<LicenseOutput>();
        LicenseOutput licenseOutput = new LicenseOutput();
        for (LicenseInput licnseInput : licenseInputs) {
            if (licenseRecordMap.containsKey(licnseInput.Sales_Activation_Code)) {
                licenseOutput.Computer_Name = licenseRecordMap.get(licnseInput.Sales_Activation_Code).Sales_License_Host_Node_Id__r.Sales_Computer_Name_Txt__c;
                licenseOutput.Sales_ProductName = licenseRecordMap.get(licnseInput.Sales_Activation_Code).Sales_License_Product__r.Name;
                licenseOutput.Sales_LicenseExpirationDate= String.valueOf(licenseRecordMap.get(licnseInput.Sales_Activation_Code).Sales_License_Expiration_Date_Dt__c);
                Date expirationDate = licenseRecordMap.get(licnseInput.Sales_Activation_Code).Sales_License_Maintenance_Exp_Dt__c;
                licenseOutput.SalesMaintainenceExpDate   = String.valueOf(expirationDate);
                licenseOutput.primarycomputerId=licenseRecordMap.get(licnseInput.Sales_Activation_Code).Sales_License_Host_Node_Id__r.Name; 
                if(licenseOutput.Sales_ProductName ==null){
                    licenseOutput.Sales_ProductName = ' ';
                }
                if(licenseOutput.SalesMaintainenceExpDate ==null){
                    licenseOutput.SalesMaintainenceExpDate = ' ';
                }if(licenseOutput.Sales_LicenseExpirationDate ==null){
                    licenseOutput.Sales_LicenseExpirationDate = ' ';
                } 
                licenseOutputs.add(licenseOutput);
            }
        }
        return licenseOutputs;    
    }
}