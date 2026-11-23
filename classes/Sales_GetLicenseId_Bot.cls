public without sharing class Sales_GetLicenseId_Bot {
    public class LicenseOutput {
        @InvocableVariable
        public Id licenseId;
        @InvocableVariable
        public String computerName;
        @InvocableVariable
        public String Sales_ProductName;
        @InvocableVariable
        public String SalesMaintainenceExpDate;
        @InvocableVariable
        public String Sales_LicenseExpirationDate;
        @InvocableVariable
        public String licenseType;
    }
    public class LicenseInput {
        @InvocableVariable
        public Sales_GetLicenseInfo_Bot.wrapperClass licenseObject;
        @InvocableVariable
        public Id contactId;
    }    
    @InvocableMethod(label='Get Id License')
    public static List<LicenseOutput> getLicenseId(List<LicenseInput> input){
        List<LicenseOutput> outputList = new List<LicenseOutput>();
        Id loggedinContactId;
        Id LicenseId;
        LicenseOutput output = new LicenseOutput();
        Set<Id> licenseIds = new Set<Id>();
        for(LicenseInput lcinput : input){
            loggedinContactId = lcinput.contactId;
            if(lcinput.licenseObject!=null){
                licenseIds.add(lcinput.licenseObject.Id);
            }
        }
        Map<Id, Sales_License__c> licenseRecordMap = new Map<Id, Sales_License__c>(); 
        for (Sales_License__c licItem : [SELECT Id, Sales_License_Product__r.Name, Sales_License_Maintenance_Exp_Dt__c, Sales_License_Host_Node_Id__r.Sales_Computer_Name_Txt__c, Sales_License_Order__r.Sales_Order_Reason__c, 
                                         Sales_License_Primary_Admin_Contact__c, Sales_License_Web_Display_Flag__c, Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_Prod_Tool_Type_Nm__c,
                                         Sales_License_Expiration_Date_Dt__c, Sales_License_Lic_User_Contact_ID__c, Sales_Tool_License_Type__c FROM Sales_License__c where Id IN:licenseIds and Sales_License_Web_Display_Flag__c=true and Sales_License_Type__c!='Optional' ]){
                                             licenseRecordMap.put(licItem.Id, licItem);
                                         }
        for(LicenseInput lcinput : input){
            if (licenseRecordMap.containsKey(lcinput.licenseObject.Id)){
                output.computerName = licenseRecordMap.get(lcinput.licenseObject.Id).Sales_License_Host_Node_Id__r.Sales_Computer_Name_Txt__c;
                output.licenseId = LicenseId= lcinput.licenseObject.Id;
                output.Sales_ProductName = licenseRecordMap.get(lcinput.licenseObject.Id).Sales_License_Product__r.Name;
                output.Sales_LicenseExpirationDate= String.valueOf(licenseRecordMap.get(lcinput.licenseObject.Id).Sales_License_Expiration_Date_Dt__c);
                Date expirationDate = licenseRecordMap.get(lcinput.licenseObject.Id).Sales_License_Maintenance_Exp_Dt__c;
                output.SalesMaintainenceExpDate   = String.valueOf(expirationDate);
                String licType = licenseRecordMap.get(lcinput.licenseObject.Id).Sales_Tool_License_Type__c;
                output.licenseType = licType;
                if(output.Sales_ProductName ==null){output.Sales_ProductName = ' ';
                                                   }
                if(output.SalesMaintainenceExpDate ==null){ output.SalesMaintainenceExpDate = ' ';
                                                          }if(output.Sales_LicenseExpirationDate ==null){output.Sales_LicenseExpirationDate = ' ';
                                                                                                        }
                outputList.add(output);
            }
        }
        Boolean successmsg = Sales_GenLicByActivationCondeController.updateLiceseRecord(LicenseId, loggedinContactId);
        return outputList; 
    }
}