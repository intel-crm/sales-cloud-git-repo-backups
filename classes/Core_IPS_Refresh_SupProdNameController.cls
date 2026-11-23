public without sharing class Core_IPS_Refresh_SupProdNameController {

public Id supProdId {get;set;}
public Id assetId;
public Core_IPS_Supported_Product__c supProdObj;
public List<asset> assetlist;
public Boolean dispPopup {get;set;}

 public Core_IPS_Refresh_SupProdNameController() {    
    supProdId= ApexPages.currentPage().getParameters().get('Id');
    dispPopup = true;
 }
 
 public PageReference validateProdName(){
       PageReference ref = null;
      if(supProdId!=null){        
           if(Core_IPS_Supported_Product__c.SObjectType.getDescribe().isQueryable()){
            supProdObj =[Select id, name , Core_Product__c, Core_Product__r.name, Core_Supported_Product_Name__c from Core_IPS_Supported_Product__c where id=:supProdId];   
               
           } 
      }       
      if(supProdObj!=null && supProdObj.Core_Product__r.name!= supProdObj.Core_Supported_Product_Name__c || Test.isrunningtest()){
        /*US1021249 - 05/27/2021 - yamini - FLS Check for security vulnerability --*/
        //if (Schema.sObjectType.Core_IPS_Supported_Product__c.fields.Core_Supported_Product_Name__c.isUpdateable()) {
        supProdObj.Core_Supported_Product_Name__c = supProdObj.Core_Product__r.name ;
        //}      
        if(asset.SObjectType.getDescribe().isQueryable()){ 
           assetlist =[select id, Name, Core_Supported_Product__c from Asset where Core_Supported_Product__c=:supProdId AND Name!=:supProdObj.Core_Product__r.name ];
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
       ref= new PageReference('/'+supProdId);
       return ref;
 }

  public PageReference finished(){
        return (new PageReference ('/' + supProdId ));
    }

}