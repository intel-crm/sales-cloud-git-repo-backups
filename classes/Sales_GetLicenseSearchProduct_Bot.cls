public with sharing class Sales_GetLicenseSearchProduct_Bot {
    public class ProductInput {
        @InvocableVariable
        public String sproductName;
        @InvocableVariable
        public String contactId;
    }
    @InvocableMethod(label='Find Unlicensed Product Details')
    public static List<List<Sales_GetComputerDetails.wrapperClass>> getLicenseDetails(List<ProductInput> productInput) {
        Set<String> contactIdSet = new Set<String>();
        Set<id> primaryAdminIdSet = new Set<Id>();
        List<List<Sales_GetComputerDetails.wrapperClass>> licenseObjList = new List<List<Sales_GetComputerDetails.wrapperClass>>();
        String searchName='';
        for (ProductInput lcInput : productInput) {
            searchName= '%'+lcInput.sproductName+'%';
            contactIdSet.add(lcInput.contactId);
        }
        for(Sales_License_Admin_Delegate__c licAdmin : [Select Id,Sales_License_PrimaryAdmin_Contact__c,Sales_License_DlgAdmin_Contact__c from Sales_License_Admin_Delegate__c where Sales_License_DlgAdmin_Contact__c IN:contactIdSet and Sales_License_isActive__c=true ]){
            primaryAdminIdSet.add(licAdmin.Sales_License_PrimaryAdmin_Contact__c); 
        }
        List<Sales_License__c> productList = [SELECT Id, Name,Sales_License_Product__r.Name,Sales_License_Activation_Code__c,Sales_Tool_License_Type__c,Sales_License_Quantity__c,Sales_License_Maintenance_Exp_Dt__c ,Sales_License_Expiration_Date_Dt__c,Sales_License_Avbl_Qty_Nbr__c
                                              FROM Sales_License__c WHERE Sales_License_Status__c='Unlicensed' and Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_Prod_Tool_Type_Nm__c != 'ADD SEAT' 
                                              and Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_Prod_Tool_Type_Nm__c != 'RENEWAL'
                                              and Sales_License_Web_Display_Flag__c = true and Sales_License_Type__c!='Optional' and Sales_License_Maintenance_Exp_Dt__c != null and Sales_License_Quantity__c>0 and Sales_License_Type__c!='Optional'
                                              AND (Sales_License_Primary_Admin_Contact__c IN:contactIdSet OR Sales_License_Lic_User_Contact_ID__c IN:contactIdSet
                                                   OR(Sales_License_Primary_Admin_Contact__c IN : primaryAdminIdSet)) and (Sales_License_Product__r.Name LIKE :searchName) LIMIT 25];
        List<Sales_GetComputerDetails.wrapperClass> lstLic =new List<Sales_GetComputerDetails.wrapperClass>();
        for(Sales_License__c lc : productList){
            Sales_GetComputerDetails.wrapperClass lst = new Sales_GetComputerDetails.wrapperClass();
            lst.salesLicenseActivationCode = lc.Sales_License_Activation_Code__c;
            lst.productName = lc.Sales_License_Product__r.Name;
            lst.Name= lc.Name;
            lst.salesQuantity =String.valueOf(lc.Sales_License_Avbl_Qty_Nbr__c)==null? ' ': String.valueOf(lc.Sales_License_Avbl_Qty_Nbr__c);
            lst.salesLicenseType = lc.Sales_Tool_License_Type__c;
            lst.noofSeats = String.valueof(lc.Sales_License_Quantity__c);
            lst.Id = lc.Id;
            lst.LicenseMaintenanceExpDt = (String.valueOf(lc.Sales_License_Maintenance_Exp_Dt__c)==null || String.valueOf(lc.Sales_License_Maintenance_Exp_Dt__c)=='')?' ':String.valueOf(lc.Sales_License_Maintenance_Exp_Dt__c);
            lst.LicExpDt = (String.valueOf(lc.Sales_License_Expiration_Date_Dt__c)==null || String.valueOf(lc.Sales_License_Expiration_Date_Dt__c)=='')?' ':String.valueOf(lc.Sales_License_Expiration_Date_Dt__c);
            lstLic.add(lst);
        }
        licenseObjList.add(lstLic);
        return licenseObjList;
    }
}