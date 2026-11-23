@isTest
public with sharing class Sales_GetComputerDetails {
    /*public class ContactInput {
        @InvocableVariable
        public String scontId;
        @InvocableVariable
        public String activationCode;
    }
    @InvocableMethod(label='Find License Details')
    public static List<List<wrapperClass>> getLicenseDetails(List<ContactInput> contactId){
        List<List<wrapperClass>> listLic = new List<List<wrapperClass>>();
        Set<String> primaryAdminIdSet = new Set<String>();
        Set<String> activatioCodeSet = new Set<String>();
        Set<String> contactIdSet = new Set<String>();
        List<Sales_License__c> lsLic= new List<Sales_License__c>();
        for(ContactInput c : contactId ){
            contactIdSet.add(c.scontId);
            if(c.activationCode!=null){
                activatioCodeSet.add(c.activationCode);
            }
        }
        for(Sales_License_Admin_Delegate__c licAdmin : [Select Id,Sales_License_PrimaryAdmin_Contact__c,Sales_License_DlgAdmin_Contact__c from Sales_License_Admin_Delegate__c where Sales_License_DlgAdmin_Contact__c IN:contactIdSet and Sales_License_isActive__c=true]){
            primaryAdminIdSet.add(licAdmin.Sales_License_PrimaryAdmin_Contact__c); 
        }
        lsLic = [SELECT Id,Name, Sales_License_Activation_Code__c,Sales_Tool_License_Type__c,Sales_License_Primary_Admin_Contact__c,Sales_License_Quantity__c,
                 Sales_License_Lic_User_Contact_ID__c, Sales_License_Product__r.Name,Sales_License_Maintenance_Exp_Dt__c,Sales_License_Avbl_Qty_Nbr__c,Sales_License_Expiration_Date_Dt__c
                 FROM Sales_License__c WHERE Sales_License_Status__c='Unlicensed' and  Sales_License_Type__c!='Optional' and
                 Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_Prod_Tool_Type_Nm__c != 'ADD SEAT' 
                 and Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_Prod_Tool_Type_Nm__c != 'RENEWAL' 
                 and (Sales_License_Primary_Admin_Contact__c IN:contactIdSet OR Sales_License_Lic_User_Contact_ID__c IN:contactIdSet
                      OR(Sales_License_Primary_Admin_Contact__c IN : primaryAdminIdSet))
                 and Sales_License_Web_Display_Flag__c = true  and Sales_License_Type__c!='Optional' order by CreatedDate desc ];
        if(activatioCodeSet.size() > 0){
            lsLic = [SELECT Id,Name,Sales_License_Activation_Code__c,Sales_Tool_License_Type__c,Sales_License_Primary_Admin_Contact__c,
                     Sales_License_Lic_User_Contact_ID__c, Sales_License_Product__r.Name,Sales_License_Maintenance_Exp_Dt__c, Sales_License_Avbl_Qty_Nbr__c,Sales_License_Expiration_Date_Dt__c,
                     Sales_License_Quantity__c FROM Sales_License__c
                     WHERE Sales_License_Activation_Code__c IN : activatioCodeSet and Sales_License_Web_Display_Flag__c = true  and Sales_License_Type__c!='Optional'];
        }
        List<wrapperClass> lstLic =new List<wrapperClass>();
        for(Sales_License__c lc : lsLic){
            wrapperClass lst = new wrapperClass();
            lst.salesLicenseActivationCode = lc.Sales_License_Activation_Code__c==null ? ' ' : lc.Sales_License_Activation_Code__c;
            lst.productName = lc.Sales_License_Product__r.Name==null? ' ':lc.Sales_License_Product__r.Name;
            lst.salesQuantity =String.valueOf(lc.Sales_License_Avbl_Qty_Nbr__c)==null? ' ': String.valueOf(lc.Sales_License_Avbl_Qty_Nbr__c);
            lst.salesLicenseType = lc.Sales_Tool_License_Type__c;
            lst.noofSeats = String.valueof(lc.Sales_License_Quantity__c)==null?' ' : String.valueof(lc.Sales_License_Quantity__c);
            lst.Id = lc.Id;
            lst.Name = lc.Name;
            lst.LicenseMaintenanceExpDt = (String.valueOf(lc.Sales_License_Maintenance_Exp_Dt__c)==null || String.valueOf(lc.Sales_License_Maintenance_Exp_Dt__c)=='')?' ':String.valueOf(lc.Sales_License_Maintenance_Exp_Dt__c);
            lst.LicExpDt = (String.valueOf(lc.Sales_License_Expiration_Date_Dt__c)==null || String.valueOf(lc.Sales_License_Expiration_Date_Dt__c)=='')?' ':String.valueOf(lc.Sales_License_Expiration_Date_Dt__c);
            if(lst.noofSeats==null){
                lst.noofSeats='';
            }
            lstLic.add(lst);
        }
        listLic.add(lstLic);
        return listLic;
    }
    public with sharing class wrapperClass{
        @InvocableVariable public  String salesLicenseActivationCode;
        @InvocableVariable public  String productName;
        @InvocableVariable public  String salesQuantity;
        @InvocableVariable public  String noofSeats;
        @InvocableVariable public  String LicenseMaintenanceExpDt;
        @InvocableVariable public  String LicExpDt;
        @InvocableVariable public  String salesLicenseType;
        @InvocableVariable public  String Id;
        @InvocableVariable public  String Name;
    }*/
}