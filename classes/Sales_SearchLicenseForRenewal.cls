@isTest
public with sharing class Sales_SearchLicenseForRenewal {
    /*public class LicenseInput {
        @InvocableVariable
        public String Sales_ContactId;
        @InvocableVariable
        public String Sales_renewLicId;
        @InvocableVariable
        public String Sales_computerName;
    }
    @InvocableMethod(label='Search License For Renewal')
    public static List<List<licensewrapper>> getRenewalLicense(List<LicenseInput> inputs){       
        Set<Id> contactId = new Set<Id>();
        Set<Id> renewLicIds = new Set<Id>();
        Set<Id> prodIdsSet = new Set<Id>();
        Set<String> searchComputerName = new Set<String>();
        List<List<licensewrapper>> listOfLicenses = new List<List<licensewrapper>>();
        List<Sales_License__c> baseLicList = new List<Sales_License__c>();
        Set<Id> foundProdIdSet = new Set<Id>();
        Set<Id> licenseIDs = new Set<Id>();
        Set<Id> conIdSet = new Set<Id>();
        Map<Id,Set<Id>> delPrimaryContactMap = new Map<Id,Set<Id>>();
        for (LicenseInput lcInput : inputs) {
            renewLicIds.add(lcInput.Sales_renewLicId);
            if(lcInput.Sales_ContactId!=null){
                contactId.add(lcInput.Sales_ContactId);
            }
            if(!String.isBlank(lcInput.Sales_computerName)){
                String searchName= '%'+lcInput.Sales_computerName+'%';
                searchComputerName.add(searchName);
            }
        }
        if(contactId.size()>0){
            delPrimaryContactMap = Sales_LicenseGenerationGenericFunctions.validateDelegateUsers(contactId);
        }
        for(Id conId1 : delPrimaryContactMap.keySet()) {
            conIdSet.addAll(delPrimaryContactMap.get(conId1));
        }
        List<Sales_License__c> renewalLicList = [SELECT Id,Name,Sales_License_Activation_Code__c,Sales_Tool_License_Type__c,Sales_License_Primary_Admin_Contact__c,Sales_License_Lic_User_Contact_ID__c, Sales_License_Product__r.Name,Sales_License_Product__r.Core_OPN__c,
                                                 Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_Foundation_Product_Id__c,Sales_License_Product__c,Sales_License_Order_Product__c,Sales_License_Order_Product__r.Product2.Core_Product_Ext_Attribute_Id__r.Core_Prod_Tool_Type_Nm__c,
                                                 Sales_License_Quantity__c,Sales_License_Maintenance_Exp_Dt__c,Sales_License_Avbl_Rehost_Nbr__c,Sales_License_Avbl_Qty_Nbr__c FROM Sales_License__c WHERE Id IN :renewLicIds and Sales_License_Web_Display_Flag__c=true and Sales_License_Type__c!='Optional' AND Sales_License_Type__c !='Employee' AND Sales_License_Type__c !='Evaluation'];
        if(renewalLicList.size()>0){
            for(Sales_License__c renewalLicItem:renewalLicList){
                if(renewalLicItem.Sales_License_Order_Product__r.Product2.Core_Product_Ext_Attribute_Id__r.Core_Prod_Tool_Type_Nm__c == 'RENEWAL'){foundProdIdSet.add(renewalLicItem.Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_Foundation_Product_Id__c);
                                                                                                                                                  }else if(renewalLicItem.Sales_License_Order_Product__r.Product2.Core_Product_Ext_Attribute_Id__r.Core_Prod_Tool_Type_Nm__c == 'BASE'){
                                                                                                                                                      licenseIDs.add(renewalLicItem.Id);
                                                                                                                                                      prodIdsSet.add(renewalLicItem.Sales_License_Product__c);
                                                                                                                                                  }
            }
        }
        baseLicList = [SELECT Id, Name, Sales_License_Account__c,Sales_License_Status__c, Sales_License_Expiration_Date_Dt__c,Sales_License_Maintenance_Exp_Dt__c,Sales_License_Product__r.Name,
                       Sales_License_Primary_Admin_Contact__c,Sales_License_Type__c,Sales_License_Lic_User_Contact_ID__c, Sales_License_Quantity__c,Sales_License_Avbl_Qty_Nbr__c,Sales_License_Web_Display_Flag__c,
                       Sales_License_Product__c,Sales_License_Avbl_Rehost_Nbr__c, Sales_License_Product__r.Core_OPN__c,Sales_License_Order_Product__r.OrderItemNumber,Sales_License_Order_Product__c, Sales_Tool_License_Type__c ,
                       Sales_License_Host_Node_Id__r.Name, Sales_License_Host_Node_Id__r.Sales_Computer_Name_Txt__c
                       FROM Sales_License__c where (Sales_License_Product__c IN:foundProdIdSet or (Sales_License_Product__c IN:prodIdsSet and Id NOT IN: licenseIDs))
                       AND (Sales_License_Primary_Admin_Contact__c IN:contactId OR Sales_License_Lic_User_Contact_ID__c IN:contactId OR(Sales_License_Primary_Admin_Contact__c IN : conIdSet))
                       AND Sales_License_Type__c ='ORIGINAL' AND (Sales_License_Host_Node_Id__r.Name LIKE :searchComputerName or Sales_License_Host_Node_Id__r.Sales_Computer_Name_Txt__c LIKE :searchComputerName) 
                       AND Sales_License_Type__c != 'Evaluation' AND Sales_License_Type__c !='Employee' AND Sales_License_Status__c ='Licensed' AND Sales_License_Web_Display_Flag__c =true and Sales_License_Type__c!='Optional'];
        List<licensewrapper> lcList = new List<licensewrapper>();
        for(Sales_License__c lc : baseLicList){
            licensewrapper wrapper = new licensewrapper();
            wrapper.Id = lc.Id;
            wrapper.ProductName = lc.Sales_License_Product__r.Name==null ? ' ' : lc.Sales_License_Product__r.Name;
            wrapper.MaintainenceExpDate = lc.Sales_License_Maintenance_Exp_Dt__c==null ? ' ': String.valueof(lc.Sales_License_Maintenance_Exp_Dt__c);
            wrapper.OPN = lc.Sales_License_Product__r.Core_OPN__c==null ? ' ' : lc.Sales_License_Product__r.Core_OPN__c;
            wrapper.Qty = lc.Sales_License_Quantity__c==null ? ' ' : String.valueof(lc.Sales_License_Quantity__c);
            wrapper.avlbleQty = lc.Sales_License_Avbl_Qty_Nbr__c==null ? ' ' : String.valueof(lc.Sales_License_Avbl_Qty_Nbr__c);
            wrapper.licenseName = lc.Name==null ? ' ' : lc.Name;
            wrapper.CName = lc.Sales_License_Host_Node_Id__r.Sales_Computer_Name_Txt__c==null ? ' ' : lc.Sales_License_Host_Node_Id__r.Sales_Computer_Name_Txt__c;
            wrapper.CId = lc.Sales_License_Host_Node_Id__r.Name==null ? ' ' : lc.Sales_License_Host_Node_Id__r.Name;
            wrapper.LicExpDt = (String.valueOf(lc.Sales_License_Expiration_Date_Dt__c)==null || String.valueOf(lc.Sales_License_Expiration_Date_Dt__c)=='')?' ':String.valueOf(lc.Sales_License_Expiration_Date_Dt__c);
            lcList.add(wrapper);
        }
        listOfLicenses.add(lcList);
        return listOfLicenses;
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
    }*/
}