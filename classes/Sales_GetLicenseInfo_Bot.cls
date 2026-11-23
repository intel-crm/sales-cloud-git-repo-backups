public without sharing class Sales_GetLicenseInfo_Bot {
    public class ContactInput {
        @InvocableVariable
        public String scontId;
        @InvocableVariable
        public String activationCode;
    }
    @InvocableMethod(label='Get License Info')
    public static List<List<wrapperClass>> getLicenseDetails(List<ContactInput> contactId){
        List<List<wrapperClass>> listLic = new List<List<wrapperClass>>();
        Set<String> primaryAdminIdSet = new Set<String>();
        Set<String> activatioCodeSet = new Set<String>();
        String activationCode;
        Id inputcontactid;
        Set<String> contactIdSet = new Set<String>();
        List<Sales_License__c> lsLict= new List<Sales_License__c>();
        for(ContactInput c : contactId ){
            contactIdSet.add(c.scontId);
            inputcontactid = c.scontId;
            if(c.activationCode!=null){
                activatioCodeSet.add(c.activationCode);
                activationCode = c.activationCode;
            }
        }
        for(Sales_License_Admin_Delegate__c licAdmin : [Select Id,Sales_License_PrimaryAdmin_Contact__c,Sales_License_DlgAdmin_Contact__c from Sales_License_Admin_Delegate__c where Sales_License_DlgAdmin_Contact__c IN:contactIdSet and Sales_License_isActive__c=true]){
            primaryAdminIdSet.add(licAdmin.Sales_License_PrimaryAdmin_Contact__c); 
        }
        if(activatioCodeSet.size() > 0){
            Sales_License__c licRecord = new Sales_License__c();
            licRecord.Sales_License_Primary_Admin_Contact__c=inputcontactid;
            licRecord.Sales_License_Activation_Code__c = activationCode;
            List<Sales_GenLicByActivationCondeController.wrapperforActivationLicense> wrapperfromController = Sales_GenLicByActivationCondeController.validateLicenses(licRecord);
            Set<id> licenseIds = new Set<id>();
            for(Sales_GenLicByActivationCondeController.wrapperforActivationLicense lc: wrapperfromController){licenseIds.add(lc.licenserecordId);
                                                                                                              }
            lsLict = [SELECT Id,Name,Sales_License_Activation_Code__c,Sales_Tool_License_Type__c,Sales_License_Primary_Admin_Contact__c,
                      Sales_License_Lic_User_Contact_ID__c, Sales_License_Product__r.Name,Sales_License_Maintenance_Exp_Dt__c,Sales_License_Expiration_Date_Dt__c,
                      Sales_License_Quantity__c FROM Sales_License__c
                      WHERE Id IN : licenseIds and Sales_License_Web_Display_Flag__c = true and Sales_License_Type__c!='Optional'];
        }
        else{
            lsLict = [SELECT Id,Name,Sales_License_Activation_Code__c,Sales_Tool_License_Type__c,Sales_License_Primary_Admin_Contact__c,Sales_License_Quantity__c,
                      Sales_License_Lic_User_Contact_ID__c, Sales_License_Product__r.Name,Sales_License_Maintenance_Exp_Dt__c,Sales_License_Expiration_Date_Dt__c FROM Sales_License__c WHERE Sales_License_Status__c='Unlicensed' and 
                      Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_Prod_Tool_Type_Nm__c != 'ADD SEAT' and Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_Prod_Tool_Type_Nm__c != 'RENEWAL' 
                      and Sales_License_Activation_Code__c!=null and (Sales_License_Primary_Admin_Contact__c IN:contactIdSet OR Sales_License_Lic_User_Contact_ID__c IN:contactIdSet
                                                                      OR(Sales_License_Primary_Admin_Contact__c IN : primaryAdminIdSet)) and Sales_License_Web_Display_Flag__c = true and Sales_License_Type__c!='Optional' order by CreatedDate desc ];
        }
        List<wrapperClass> lstLic =new List<wrapperClass>();
        for(Sales_License__c lc : lsLict){
            wrapperClass lst = new wrapperClass();
            lst.salesLicenseActivationCode = lc.Sales_License_Activation_Code__c;
            lst.productName = lc.Sales_License_Product__r.Name;
            lst.salesLicenseType = lc.Sales_Tool_License_Type__c;
            lst.licenseName = lc.Name;
            lst.noofSeats = lc.Sales_License_Quantity__c==null ?' ': String.valueof(lc.Sales_License_Quantity__c);
            lst.Id = lc.Id;
            lst.salesLicenseMaintenanceExpDt = (String.valueOf(lc.Sales_License_Maintenance_Exp_Dt__c)==null || String.valueOf(lc.Sales_License_Maintenance_Exp_Dt__c)=='')?' ':String.valueOf(lc.Sales_License_Maintenance_Exp_Dt__c);
            lst.salesLicenseExpDt = (String.valueOf(lc.Sales_License_Expiration_Date_Dt__c)==null || String.valueOf(lc.Sales_License_Expiration_Date_Dt__c)=='')?' ':String.valueOf(lc.Sales_License_Expiration_Date_Dt__c);
            if(lst.noofSeats==null){lst.noofSeats='';}
            lstLic.add(lst);
        }
        listLic.add(lstLic);
        return listLic;
    }
    public with sharing class wrapperClass{
        @InvocableVariable public  String licenseName;
        @InvocableVariable public  String salesLicenseActivationCode;
        @InvocableVariable public  String productName;
        @InvocableVariable public  String noofSeats;
        @InvocableVariable public  String salesLicenseMaintenanceExpDt;
        @InvocableVariable public  String salesLicenseExpDt;
        @InvocableVariable public  String salesLicenseType;
        @InvocableVariable public  String Id;
    }
}