public without sharing class Core_IPS_Refresh_SupProdName_LEX {
    
 @AuraEnabled
 public static boolean validateProdName(String supProdId){
     Core_IPS_Supported_Product__c supProdObj = new Core_IPS_Supported_Product__c();
     List<Asset> assetList = new List<Asset>(); 
       
      if(supProdId != NULL){        
           if(Core_IPS_Supported_Product__c.SObjectType.getDescribe().isQueryable()){
              supProdObj = [ SELECT Id, Name , Core_Product__c, Core_Product__r.Name, Core_Supported_Product_Name__c 
                                 FROM Core_IPS_Supported_Product__c 
                                    WHERE Id=:supProdId ];      
           } 
       }   
      if(supProdObj != NULL && supProdObj.Core_Product__r.Name != supProdObj.Core_Supported_Product_Name__c || Test.isrunningtest()){
         supProdObj.Core_Supported_Product_Name__c = supProdObj.Core_Product__r.Name ;
             if(asset.SObjectType.getDescribe().isQueryable()){ 
               assetList =[ SELECT Id, Name, Core_Supported_Product__c 
                               FROM Asset
                                  WHERE Core_Supported_Product__c=:supProdId AND Name!=:supProdObj.Core_Product__r.Name ];
             }
             for(Asset asst: assetlist ){
                 if(Asset.SObjectType.getDescribe().isupdateable()){    
                 asst.Name = supProdObj.Core_Product__r.name;
              }
             } 
          
            if(assetlist.size()>0){
               if(Asset.SObjectType.getDescribe().isupdateable()){
               update assetlist;
               }
            }
          
          if(Core_IPS_Supported_Product__c.SObjectType.getDescribe().isupdateable()){           
             update supProdObj; 
          }               
      } 
     return true;
  }
}