public with sharing class Sales_UpdateRenewalController {
   /* public Sales_UpdateRenewalController() {

    }
    @AuraEnabled
    public static void updaterenewalLicense(String newLicenseId,List<Sales_License__c> baseLicense){
        System.debug('newLicenseId@@@'+newLicenseId);
        System.debug('baseLicense@@@'+baseLicense);
        Set<Sales_License__c> licList=new Set<Sales_License__c>();
        list<Sales_License_Order_Product__c> licordprodlist=new list<Sales_License_Order_Product__c>();
        for(Sales_License_Order_Product__c licordprod :[Select Id,Sales_Renewable_license__c,Sales_License__c from Sales_License_Order_Product__c where Sales_License__c IN: baseLicense]){
            
            licordprod.Sales_Renewable_license__c=newLicenseId;
            
            licordprodlist.add(licordprod);
            licList.add(licordprod.Sales_Renewable_license__c);
        }  
        if(licordprodlist.size()>0)
        {
            update licordprodlist;
            System.debug(licordprodlist);
        }
    

        
    }*/
   /* @AuraEnabled
    public static void updaterenewal(Id recordId)
    { //Set<Sales_Renewable_license__c> licList=new Set<Sales_Renewable_license__c>();
        Set<Id> renewlicList=new Set<Id>();
        Set<Id> baseLicenseselected=new Set<Id>();
        if(recordId!=NULL){
        for(Sales_License_Order_Product__c licordprod : [Select id,Sales_Renewable_license__c,Sales_License__r.Sales_License_Type__c from Sales_License_Order_Product__c where Sales_License__r.Sales_License_Type__c='Renewal'])
        {
            baseLicenseselected.add(licordprod.Sales_License__c);
        }
    }
        else if (recordId!=NULL){
        
        for(Sales_License_Order_Product__c licordprod : [Select id,Sales_Renewable_license__c,Sales_License__c from Sales_License_Order_Product__c where Sales_Renewable_license__c != NULL])
        {
            renewlicList.add(licordprod.Sales_Renewable_license__c);
        }
       
    }
  
}  */
}