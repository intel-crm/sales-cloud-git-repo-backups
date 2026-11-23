/*********************************************************************************************************************
Class Name    : Sales_ApplyRenewal_Chatbot
Version       : 1.0
Created Date  : May 2021
Function      :  
Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------
* Jasmine Narula           May-2021				 CHATBOT 
* ************************************************************************************************************************************************/
public without sharing class Sales_ShowRenewalLicense_Bot {
    public class LicenseInput {
        @InvocableVariable
        public Id sContactId;
    }
    @InvocableMethod(label='Show Renewal Licenses')
    public static List<List<licensewrapper>> showRenewalLicenses(List<LicenseInput> inputs){
        Set<Id> contactIdSet = new Set<Id>();
        Set<String> primaryAdminIdSet = new Set<String>();
        List<List<licensewrapper>> licListofLists= new List<List<licensewrapper>>();        
        for(LicenseInput input : inputs){
            contactIdSet.add(input.sContactId);
        }
        for(Sales_License_Admin_Delegate__c licAdmin : [Select Id,Sales_License_PrimaryAdmin_Contact__c,Sales_License_DlgAdmin_Contact__c from Sales_License_Admin_Delegate__c where Sales_License_DlgAdmin_Contact__c IN:contactIdSet and Sales_License_isActive__c=true]){
            primaryAdminIdSet.add(licAdmin.Sales_License_PrimaryAdmin_Contact__c); 
        }
        Set<Id> foundationProdIds = new Set<Id>();
        for(Product2 prod : [SELECT Core_Product_Ext_Attribute_Id__r.Core_Foundation_Product_Id__c from Product2 WHERE Core_Product_Ext_Attribute_Id__r.Core_Foundation_Product_Id__c!=null]){
            if(!foundationProdIds.contains(prod.Core_Product_Ext_Attribute_Id__r.Core_Foundation_Product_Id__c)){
                foundationProdIds.add(prod.Core_Product_Ext_Attribute_Id__r.Core_Foundation_Product_Id__c);
            }    
        }
        List<Sales_License__c> licList = [SELECT Id,Name,Sales_License_Activation_Code__c,Sales_Tool_License_Type__c,Sales_License_Primary_Admin_Contact__c,Sales_License_Quantity__c,
                                          Sales_License_Lic_User_Contact_ID__c, Sales_License_Product__r.Name,Sales_License_Product__r.Core_OPN__c,Sales_License_Order_Product__r.Product2.Core_Product_Ext_Attribute_Id__r.Core_Prod_Tool_Type_Nm__c,
                                          Sales_License_Maintenance_Exp_Dt__c,Sales_License_Avbl_Rehost_Nbr__c,Sales_License_Avbl_Qty_Nbr__c,Sales_License_Expiration_Date_Dt__c,
                                          Sales_License_Host_Node_Id__r.Name, Sales_License_Host_Node_Id__r.Sales_Computer_Name_Txt__c,Sales_License_Web_Display_Flag__c
                                          FROM Sales_License__c WHERE Sales_License_Status__c='Unlicensed' 
                                          and (Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_Prod_Tool_Type_Nm__c = 'RENEWAL' 
                                               or Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_Prod_Tool_Type_Nm__c = 'BASE')
                                          and Sales_License_Avbl_Qty_Nbr__c> 0 and Sales_License_Product__c NOT IN : foundationProdIds
                                          and Sales_License_Type__c!='Optional'and Sales_License_Maintenance_Exp_Dt__c > :Date.today() and Sales_License_Host_Node_Id__c=null 
                                          and Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_Prod_Tool_Type_Nm__c != 'ADD SEAT'and Sales_License_Web_Display_Flag__c =true
                                          and (Sales_License_Primary_Admin_Contact__c IN:contactIdSet OR Sales_License_Lic_User_Contact_ID__c IN:contactIdSet OR Sales_License_Primary_Admin_Contact__c IN : primaryAdminIdSet)];
        List<licensewrapper> lcList = new List<licensewrapper>();
        for(Sales_License__c lc : licList){
            licensewrapper lcWrapper = new licensewrapper();
            lcWrapper.Id = lc.Id;	
            lcWrapper.ProductName = lc.Sales_License_Product__r.Name==null ? ' ' : lc.Sales_License_Product__r.Name; 
            lcWrapper.MaintainenceExpDate = lc.Sales_License_Maintenance_Exp_Dt__c==null ? ' ': String.valueof(lc.Sales_License_Maintenance_Exp_Dt__c);
            lcWrapper.licenseName = lc.Name==null ? ' ' : lc.Name;
            lcWrapper.OPN = lc.Sales_License_Product__r.Core_OPN__c==null ? ' ' : lc.Sales_License_Product__r.Core_OPN__c;		
            lcWrapper.Qty = lc.Sales_License_Quantity__c==null ? ' ' : String.valueof(lc.Sales_License_Quantity__c);	
            lcWrapper.avlbleQty = lc.Sales_License_Avbl_Qty_Nbr__c==null ? ' ' : String.valueof(lc.Sales_License_Avbl_Qty_Nbr__c);
            lcWrapper.CName = lc.Sales_License_Host_Node_Id__r.Sales_Computer_Name_Txt__c==null ? ' ' : lc.Sales_License_Host_Node_Id__r.Sales_Computer_Name_Txt__c;
            lcWrapper.CId = lc.Sales_License_Host_Node_Id__r.Name==null ? ' ' : lc.Sales_License_Host_Node_Id__r.Name;
            lcWrapper.LicExpDt = (String.valueOf(lc.Sales_License_Expiration_Date_Dt__c)==null || String.valueOf(lc.Sales_License_Expiration_Date_Dt__c)=='')?' ':String.valueOf(lc.Sales_License_Expiration_Date_Dt__c);
            lcList.add(lcWrapper);
        }
        licListofLists.add(lcList);
        return licListofLists;
    }
    public class licensewrapper{
        @InvocableVariable public String Id;
        @InvocableVariable public String ProductName;
        @InvocableVariable public String MaintainenceExpDate;
        @InvocableVariable public  String LicExpDt;
        @InvocableVariable public String OPN;
        @InvocableVariable public String Qty;
        @InvocableVariable public String avlbleQty;
        @InvocableVariable public String licenseName;
        @InvocableVariable public String CName;
        @InvocableVariable public String CId;
    }
}