/*********************************************************************************************************************
Class Name    : Sales_LicenseOrderProductTriggerUtility
Version       : 1.0
Created Date  : Apr 2021
Function      :  

Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------
* Saba Husain            April 2021              
* *********************************************************************************************************************/
@isTest
public without sharing class Sales_LicenseOrderProductTriggerUtility{
    /*public static void updateExpiryDate(List<Sales_License_Order_Product__c> licOrdProdList){
        Map<Id, Sales_License_Order_Product__c> licIdOrdProdMap = new Map<Id, Sales_License_Order_Product__c>();
        for(Sales_License_Order_Product__c newLicOrdProd: licOrdProdList){
            licIdOrdProdMap.put(newLicOrdProd.Sales_License__c, newLicOrdProd);                
        }    
        
        for(Sales_License__c lic: [Select Id, Sales_License_Expiration_Date_Dt__c, Sales_License_Maintenance_Exp_Dt__c from Sales_license__c where Id IN: licIdOrdProdMap.keyset()]){
            Sales_License_Order_Product__c licOrdProd = licIdOrdProdMap.get(lic.id); 
            if(licOrdProd.Sales_License_Expiration_Date_Dt__c == null){
            	licOrdProd.Sales_License_Expiration_Date_Dt__c = lic.Sales_License_Expiration_Date_Dt__c;
            }
            if(licOrdProd.Sales_License_Order_Prod_Maint_Exp_Dt__c == null){
            	licOrdProd.Sales_License_Order_Prod_Maint_Exp_Dt__c = lic.Sales_License_Maintenance_Exp_Dt__c;
            }
        }
    }*/
}