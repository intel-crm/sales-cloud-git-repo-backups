@isTest
public with sharing class Sales_UpdateLicenseRenewalRecords {
/*    
    private static final String STATUS_RENEWAL = 'Renewal';
    private static final String STATUS_ADDSEAT = 'Add seat';
    
    @AuraEnabled(cacheable=true)//called from LWC  (Sales_LicenseRecordUpdates) to show the related records as per US1084460
    public static List<Sales_License__c> getLicenseParameter(Id recordId){
        List<Id> lic=new List<Id>();
        Sales_License__c license = [Select Id,Sales_License_Product__c,Sales_License_Type__c from Sales_License__c where Id=:recordId LIMIT 1];
        //Id recordsProductId = license.Sales_License_Product__c;
        if(license.Sales_License_Type__c==STATUS_RENEWAL || license.Sales_License_Type__c==STATUS_ADDSEAT){//validating for addseat/renewal
            lic=getAddseatRenewallicenses(recordId);//calling add seat/renewal method to fetch related base records
        } 
        else{//validating for other license types (Original)
            lic=getOriginallicenses(recordId);//calling original method to fetch related base records
        }
        return [Select Id,Sales_License_Primary_Admin_Contact_Txt__c,Sales_License_Type__c,Sales_License_Product__c,Sales_License_Product_OPN__c,Sales_License_Product_Name_Txt__c,
                Name,Sales_License_Quantity__c,Sales_License_Avbl_Qty_Nbr__c,Sales_License_Status__c,Sales_License_Order_Product__c,Sales_License_Order_Product__r.OrderItemNumber,Sales_License_Maintenance_Exp_Dt__c,Sales_License_Product__r.Name 
                from Sales_License__c where Sales_License_Type__c !='Evaluation' and Sales_License_Type__c !='Employee' and Sales_License_Type__c!='Optional' and Id IN:lic Order By Name];//returning realted records
    }
    
    public static List<Id> getAddseatRenewallicenses(Id recordId){ //method to fetch related licenses for add seat/renewal records
        Set<Id> addSeatlicSet2=new Set<Id>();
        List<Id> lic3=new List<Id>();
        if(recordId!=NULL){
            
            for(Sales_License_Order_Product__c licordprod : [Select id,Sales_Renewable_license__c,Sales_License__r.Sales_License_Type__c,Sales_License__r.Sales_License_Product__c from 
                                                             Sales_License_Order_Product__c where Sales_Renewable_license__c =: recordId]){//fetching records from junction object
                                                                // if(licordprod.Sales_License__r.Sales_License_Product__c == recordsProductId)
                                                                     addSeatlicSet2.add(licordprod.Sales_License__c);
                                                             }
        }
        lic3.addAll(addSeatlicSet2); 
        return lic3;
    }
    
    public static List<Id> getOriginallicenses(Id recordId){//method to fetch related licenses for original type license records
        Boolean flag=false;
        List<Id> licList=new List<Id>();
        if(recordId!=NULL){
            for(Sales_License_Order_Product__c licordprod : [Select id,Sales_Renewable_license__c,Sales_License__r.Sales_License_Type__c,Sales_License__c from Sales_License_Order_Product__c
                                                             WHERE Sales_Renewable_license__c!=null]){//fetching records from junction object
                                                                 if(licordprod.Sales_Renewable_license__c == recordId && licordprod.Sales_License__r.Id!=recordId){
                                                                     if(!licList.contains(licordprod.Sales_License__c)){
                                                                         licList.add(licordprod.Sales_License__c);
                                                                     }
                                                                 }
                                                                 if(licordprod.Sales_License__c==recordId){
                                                                     if(!licList.contains(licordprod.Sales_Renewable_license__c)){
                                                                         licList.add(licordprod.Sales_Renewable_license__c);
                                                                     }
                                                                 }
                                                             }
        }
        return licList;          
    }
*/
}