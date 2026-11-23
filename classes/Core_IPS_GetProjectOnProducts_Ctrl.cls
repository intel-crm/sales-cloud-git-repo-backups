public with sharing class Core_IPS_GetProjectOnProducts_Ctrl {
    
    @AuraEnabled
     public static List<sObject> getIPSProjListBasedOnSelectedProd(String selectedProductId, String searchTxt){
         String searchKey  = '%' + searchTxt + '%';
        List<Asset> objAssetSupported=new List<Asset>();
       List<Asset> assignedProjectList = new List<Asset>();
            objAssetSupported = [SELECT Id,Core_Supported_Product__c,Core_IPS_Project__c  FROM Asset where Id=:selectedProductId ];//Added by Mahendra per US79769 start
         if(objAssetSupported.size()>0){
                assignedProjectList = [select id, name,Core_IPS_Project__c,Core_IPS_Project__r.Name,Core_IPS_Project__r.Core_IPS_Project_ID__c from Asset where Core_IPS_Project__r.core_status__c !='Inactive' and Status !='Inactive' and Core_Supported_Product__c =:objAssetSupported[0].Core_Supported_Product__c and Core_IPS_Project__r.Name like :searchKey ORDER BY Core_IPS_Project__r.Core_IPS_Project_ID__c  DESC ];
      	 }       
     	Set<sObject> projectList = new Set<sObject>();
           for(Asset astObj:assignedProjectList){
               if(astObj.Core_IPS_Project__c <> null && astObj.Core_IPS_Project__r <> null && astObj.Core_IPS_Project__r.Name <> null) { 
                   //projectList.add(new SelectOption(astObj.Core_IPS_Project__c,astObj.Core_IPS_Project__r.Core_IPS_Project_ID__c+': '+astObj.Core_IPS_Project__r.Name));
                   projectList.add(astObj.Core_IPS_Project__r);
               }
            }
         List<sObject> projectNewList = new List<sObject>(projectList);  
       return projectNewList;
    }
}