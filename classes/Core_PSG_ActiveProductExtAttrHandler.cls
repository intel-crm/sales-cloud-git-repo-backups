/****************************************************************************************************
Apex Class Name : PSG_ActiveProductExtAttrHandler
Version         : 1.0 
Created Date    : 08/30/2021
Function        : This class is used used as part of Product trigger for all the PSG functionalities
Modifications   :
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Sandhya D                    08/30/2021               Created
*****************************************************************************************************/
@isTest
public without sharing class Core_PSG_ActiveProductExtAttrHandler {   
    /************************************************************************************************************
	*Method Name : updateExtAttributesOnActiveProduct
	*Created Date: 08/30/2021
	*Author: Sandhya D 
	*Description : Updates Core_Product_Ext_Attribute__c records..
	************************************************************************************************************/
    /*public static void updateExtAttributesOnActiveProduct(List<Product2> newList,Map<Id,Product2> oldMap,Boolean IsInsert){
      
        List<Product2> releaseProdList=new List<Product2>();
        Map<String,String> recentActiveProdMap =new Map<String,String>();
        Set<String> opnSet=new Set<String>();
        Map<String,Product2> opnProdMap=new Map<String,Product2>();
        Map<String,List<Core_Product_Ext_Attribute__c>> existingPreReleaseExtAttrMap=new Map<String,List<Core_Product_Ext_Attribute__c>>();
        Map<String,List<SBQQ__ProductOption__c>> existingPreReleaseProdOptMap=new Map<String,List<SBQQ__ProductOption__c>>(); 
        List<Core_Product_Ext_Attribute__c> extAttrListToInsert=new List<Core_Product_Ext_Attribute__c>();
        List<SBQQ__ProductOption__c> ProdOptListToInsert=new List<SBQQ__ProductOption__c>(); 
        List<Product2> preReleaseProdList=new List<Product2>();
       List<Core_Log_Entry__c> captureQueryErr = new List<Core_Log_Entry__c>();
        if(newList != null ){
            for(Product2 prod : newList){ 
                if(IsInsert){
                    if(prod.Core_Product_Type__c == Label.PSG_Product_Type_Identifier && prod.isActive && prod.Core_Product_Org__c=='Sales' ){
                        releaseProdList.add(prod);
                    	opnSet.add(prod.core_OPN__c);
                    }
                }else{
                    if((prod.Core_Product_Type__c == Label.PSG_Product_Type_Identifier && prod.Core_Product_Org__c=='Sales') && ((oldMap.get(prod.Id).isActive != prod.isActive && prod.isActive) || (oldMap.get(prod.Id).core_OPN__c != prod.Core_OPN__c && oldMap.get(prod.Id).core_OPN__c == null && prod.Core_OPN__c!=null)) ){
                     //if((prod.Core_Product_Type__c == Label.PSG_Product_Type_Identifier && prod.Core_Product_Org__c=='Sales') && ((oldMap.get(prod.Id).isActive != prod.isActive && prod.isActive) || (oldMap.get(prod.Id).core_OPN__c != prod.Core_OPN__c )) ){
               			releaseProdList.add(prod);
                    	opnSet.add(prod.core_OPN__c);
                    }
                }
            }
            }               
        
        if(!opnSet.isEmpty() || opnSet!=null){
            //take the Active latest pre release product based on Createddate. There could be multiple inactive, hence added Order By createdDate
          // Map<String,String>
           //recentActiveProdMap = PSG_ProductBusinessLogic.getRecentActivatedProduct(opnSet,releaseProdList);
            for(Product2 prodRec: [SELECT Id,core_OPN__c from Product2 WHERE Id in :recentActiveProdMap.values()]){  	
            preReleaseProdList.add(prodRec);
                if(!opnProdMap.containsKey(prodRec.Core_OPN__c)){
                    opnProdMap.put(prodRec.core_OPN__c,prodRec);
                }
            }
        }
        
        if(!opnProdMap.isEmpty()){ 
            List<Product2> extendedAttributeList = opnProdMap.values();
            String ExtAttributequery = 'Select ' +String.escapeSingleQuotes(label.PSG_ProductExtAttribute) + ' from Core_Product_Ext_Attribute__c where Core_Product_Id__c in:extendedAttributeList ';
            for(Core_Product_Ext_Attribute__c preReleaseExtAttr:(List<Core_Product_Ext_Attribute__c>)Database.query(ExtAttributequery) ){
                List<Core_Product_Ext_Attribute__c> preReleaseExtAttrList=existingPreReleaseExtAttrMap.containsKey(preReleaseExtAttr.Core_Product_Id__c)?existingPreReleaseExtAttrMap.get(preReleaseExtAttr.Core_Product_Id__c):new List<Core_Product_Ext_Attribute__c>();
                preReleaseExtAttrList.add(preReleaseExtAttr);
                existingPreReleaseExtAttrMap.put(preReleaseExtAttr.Core_Product_Id__c,preReleaseExtAttrList); 
            }
            String ProductOptionquery = 'Select ' +String.escapeSingleQuotes(label.PSG_ProductOptionFields) +' from SBQQ__ProductOption__c  where SBQQ__ConfiguredSKU__c in:extendedAttributeList ';
            for(SBQQ__ProductOption__c PreReleaseProdOpt: (List<SBQQ__ProductOption__c>)Database.query(ProductOptionquery)){
                List<SBQQ__ProductOption__c> preReleaseOptList=existingPreReleaseProdOptMap.containsKey(PreReleaseProdOpt.SBQQ__ConfiguredSKU__c)?existingPreReleaseProdOptMap.get(PreReleaseProdOpt.SBQQ__ConfiguredSKU__c):new List<SBQQ__ProductOption__c>();
                preReleaseOptList.add(PreReleaseProdOpt);
                existingPreReleaseProdOptMap.put(PreReleaseProdOpt.SBQQ__ConfiguredSKU__c,preReleaseOptList);
            }
            
        }
        for(Product2 prod:releaseProdList){ 
            if(opnProdMap.containsKey(prod.Core_OPN__c) && existingPreReleaseExtAttrMap.containsKey(opnProdMap.get(prod.Core_OPN__c).Id)){                               
                //Clone the extended Attributes from Pre release to release products
                for(Core_Product_Ext_Attribute__c prodExtAttrAct:existingPreReleaseExtAttrMap.get(opnProdMap.get(prod.Core_OPN__c).Id)){                  
                    Core_Product_Ext_Attribute__c extAttrToInsert=prodExtAttrAct.clone(false,false,false,false);
                    extAttrToInsert.Core_Product_Id__c =prod.Id;
                    extAttrListToInsert.add(extAttrToInsert);
                }     
            }
            if(opnProdMap.containsKey(prod.Core_OPN__c) && existingPreReleaseProdOptMap.containsKey(opnProdMap.get(prod.Core_OPN__c).Id)){ 
                for(SBQQ__ProductOption__c ProdOptAct:existingPreReleaseProdOptMap.get(opnProdMap.get(prod.Core_OPN__c).Id)){
                    SBQQ__ProductOption__c ProdOptToInsert=ProdOptAct.clone(false,false,false,false);
                    ProdOptToInsert.SBQQ__ConfiguredSKU__c =prod.Id;
                    ProdOptListToInsert.add(ProdOptToInsert);
                }
            }
            
        }       
        if(!extAttrListToInsert.isEmpty()){
            List<Core_Product_Ext_Attribute__c> failedRec=new List<Core_Product_Ext_Attribute__c>();            
            Database.SaveResult[] result=Database.insert(extAttrListToInsert,false);
            for(Integer i=0;i<result.size();i++){
                if (!result[i].isSuccess()) {
                    failedRec.add(extAttrListToInsert[i]);
                }
            }
            if(failedRec.size()>0){
                captureQueryErr.add(new Core_Log_Entry__c(Core_Details__c = 'Error while Copying Signal Code and Product Class records to Active Products:'+failedRec, Core_Message__c = 'Failed', Core_Severity__c = 'High',Core_Project__c='PIR', Core_Origin__c='Core_PSG_ActiveProductExtAttrHandler', Core_When__c = System.now())); 
            }
        }
        if(!ProdOptListToInsert.isEmpty()){
            List<SBQQ__ProductOption__c> failedOptionRec=new List<SBQQ__ProductOption__c>();            
            Database.SaveResult[] result=Database.insert(ProdOptListToInsert,false);
            for(Integer i=0;i<result.size();i++){
                if (!result[i].isSuccess()) {
                    failedOptionRec.add(ProdOptListToInsert[i]);
                }
            }
            if(failedOptionRec.size()>0){
                captureQueryErr.add(new Core_Log_Entry__c(Core_Details__c = 'Error while Copying Signal Code and Product Class records to Active Products:'+failedOptionRec, Core_Message__c = 'Failed', Core_Severity__c = 'High',Core_Project__c='PIR', Core_Origin__c='Core_PSG_ActiveProductExtAttrHandler', Core_When__c = System.now())); 
            }
        }
        updateSignalCodeOnAllProducts( newList,oldMap,  recentActiveProdMap);
        
    } 
    
    
    
    /************************************************************************************************************
	*Method Name : updateSignalCodeOnAllProducts
	*Created Date: 09/16/2021
	*Author: Sandhya D 
	*Description : Updates Signal Code and Product Class from Pre release to Release products records.
	************************************************************************************************************/   
    //Changed the Scope -- Private to Public 
    /*public static void updateSignalCodeOnAllProducts(List<Product2> newList,Map<Id,Product2> oldMap, Map<String,String> recentActiveProdMap){
          system.debug('Before Update called -- updateSignalCodeOnAllProducts start');
        Map<String,List<Product2>> opnSignalCodeMap=new Map<String,List<Product2>>();
        Set<String> opnSet=new Set<String>();
        List<Product2> preReleaseSignalCodeList=new List<Product2>();
        List<Core_Log_Entry__c> captureQueryErr = new List<Core_Log_Entry__c>();
        Map<String,String> releasedProdSignalCode=new Map<String,String>();
        List<Product2> prodListToUpdate = new List<Product2>();
        List<Product2> releaseProdList=new List<Product2>();
        List<Product2> preReleaseProdList=new List<Product2>();
        Map<String,Product2> opnProdMap=new Map<String,Product2>();       
        
        if(newList != null && oldMap!= null){
            for(Product2 prod : newList){   
                
            	//if(prod.Core_Product_Type__c == Label.PSG_Product_Type_Identifier && prod.core_OPN__c!=null && prod.isActive && oldMap.get(prod.Id).Core_Item_Signal_Cd__c != prod.Core_Item_Signal_Cd__c && (prod.Core_Hierarchy_ID__c =='43'|| prod.Core_Hierarchy_ID__c =='59') && prod.Core_Product_Org__c=='Sales' ){
                if(prod.Core_Product_Type__c == Label.PSG_Product_Type_Identifier && prod.core_OPN__c!=null && prod.isActive &&  prod.Core_Product_Org__c=='Sales' ){
                    opnSet.add(prod.core_OPN__c);
                    releaseProdList.add(prod);
                    releasedProdSignalCode.put(prod.core_OPN__c,prod.Core_Item_Signal_Cd__c);
                }
            } 
        }
      	
         if(!opnSet.isEmpty() || opnSet!=null){
            //take the Active latest pre release product based on Createddate. There could be multiple inactive, hence added Order By createdDate
           //Map<String,String> 
              // recentActiveProdMap = PSG_ProductBusinessLogic.getRecentActivatedProduct(opnSet,releaseProdList);
            for(Product2 prodRec: [SELECT Id,core_OPN__c, Core_Item_Class_Nm__c,Core_Item_Signal_Cd__c, Core_Sales_Visible_Flag__c, Core_Sales_Visible_Flag_User_Edit__c  from Product2 WHERE Id in :recentActiveProdMap.values()]){  	
            preReleaseProdList.add(prodRec);
                if(!opnProdMap.containsKey(prodRec.Core_OPN__c)){
                    opnProdMap.put(prodRec.core_OPN__c,prodRec);
                }
            }
        }
		
    
          for(Product2 prod:releaseProdList){ 
           if(opnProdMap.containsKey(prod.Core_OPN__c)){ 
             
               Product2 prodNew = new Product2();
               prodNew.Id = prod.Id;
               //prodNew.Core_Item_Class_Nm__c = opnProdMap.get(prod.Core_OPN__c).Core_Item_Class_Nm__c;
               prodNew.Core_Item_Signal_Cd__c = opnProdMap.get(prod.Core_OPN__c).Core_Item_Signal_Cd__c; 
                 
               prodNew.Core_Sales_Visible_Flag__c = opnProdMap.get(prod.Core_OPN__c).Core_Sales_Visible_Flag__c;
               prodNew.Core_Sales_Visible_Flag_User_Edit__c = opnProdMap.get(prod.Core_OPN__c).Core_Sales_Visible_Flag_User_Edit__c;              
               prodListToUpdate.add(prodNew); 
            }
        }
		try{
        update prodListToUpdate;
        }catch(Exception e){
            captureQueryErr.add(new Core_Log_Entry__c(Core_Details__c = 'Error while Copying Signal Code and Product Class records to All Products' + e.getStackTraceString() + e.getMessage(), Core_Message__c = 'Failed', Core_Severity__c = 'High',Core_Project__c='PIR', Core_Origin__c='Core_PSG_ActiveProductExtAttrHandler', Core_When__c = System.now())); 
        }
        finally
        {
       // insert captureQueryErr;
        }
        
    } 
    //Sandhya
    public static void removeSignalCodeUpdatedProducts(List<Product2> newProductList, Map<Id,Product2> oldProductMap){
	
        List<Product2> signalCodeUnchangedProdList = new List<Product2>();
        for (Product2 prod : newProductList){
            if(!(prod.Core_Item_Signal_Cd__c != oldProductMap.get(prod.Id).Core_Item_Signal_Cd__c)){
              
            signalCodeUnchangedProdList.add(prod);
            }
        }
        
        if(!signalCodeUnchangedProdList.isEmpty()){
            Core_PSG_ActiveProductExtAttrHandler.updateSignalCodeOnAllProducts(signalCodeUnchangedProdList,oldProductMap,new Map<String,String>()); 
        }
       
	}
    
    
    public static void updateProductsWithoutSignalCode(List<Product2> newList,Map<Id,Product2> oldMap,Boolean IsInsert){
       
        Map<String,Product2> prodWithoutSignalCodeMap = new Map<String,Product2>();
        Map<String,Product2> existingProdWithSignalCodeMap = new Map<String,Product2>();
        List<Product2> prodWithoutSignalCodeMapUpdate = new List<Product2>();
    
        Boolean recursiveCheckSignalCode = true;
        if(recursiveCheckSignalCode){
        if(newList != null){
            for(Product2 prodWithoutSignalCode : newList){
                if(IsInsert){
                if(String.isEmpty(prodWithoutSignalCode.Core_Item_Signal_Cd__c ) || prodWithoutSignalCode.Core_Item_Signal_Cd__c==null){
                    prodWithoutSignalCodeMap.put(prodWithoutSignalCode.Core_OPN__c,prodWithoutSignalCode);
                 
                }
                }else{
                    if((String.isEmpty(prodWithoutSignalCode.Core_Item_Signal_Cd__c ) || prodWithoutSignalCode.Core_Item_Signal_Cd__c==null)&& oldMap.get(prodWithoutSignalCode.Id).Core_Item_Signal_Cd__c !=prodWithoutSignalCode.Core_Item_Signal_Cd__c ){
                    prodWithoutSignalCodeMap.put(prodWithoutSignalCode.Core_OPN__c,prodWithoutSignalCode);
                    }
                }
                
            }
        }
           
        for(Product2 existingProdWithSignalCode : [select id,name,Core_Item_Quotable_Ind__c,Core_Item_Shippable_Ind__c,Core_Item_Orderable_Ind__c,Core_Item_Price_Authorization_Ind__c,Core_Item_Signal_Cd__c,Core_OPN__c,Core_Item_Class_Nm__c from Product2 where Core_OPN__c IN :prodWithoutSignalCodeMap.keySet() and Core_Product_Type__c = :Label.PSG_Product_Type_Identifier and Core_Product_Org__c='Sales' and Core_Item_Signal_Cd__c!=null]){
            existingProdWithSignalCodeMap.put(existingProdWithSignalCode.Core_OPN__c,existingProdWithSignalCode);
           
            
        }
        
        for(Product2 prodRecSignalCode : prodWithoutSignalCodeMap.values()){
            if(existingProdWithSignalCodeMap.containskey(prodRecSignalCode.Core_OPN__c)){
           
                //prodRecSignalCode.Core_Item_Class_Nm__c = existingProdWithSignalCodeMap.get(prodRecSignalCode.Core_OPN__c).Core_Item_Class_Nm__c;
                prodRecSignalCode.Core_Item_Signal_Cd__c = existingProdWithSignalCodeMap.get(prodRecSignalCode.Core_OPN__c).Core_Item_Signal_Cd__c;
                prodRecSignalCode.Core_Item_Quotable_Ind__c = existingProdWithSignalCodeMap.get(prodRecSignalCode.Core_OPN__c).Core_Item_Quotable_Ind__c;
                prodRecSignalCode.Core_Item_Shippable_Ind__c = existingProdWithSignalCodeMap.get(prodRecSignalCode.Core_OPN__c).Core_Item_Shippable_Ind__c;
                prodRecSignalCode.Core_Item_Orderable_Ind__c = existingProdWithSignalCodeMap.get(prodRecSignalCode.Core_OPN__c).Core_Item_Orderable_Ind__c;
                prodRecSignalCode.Core_Item_Price_Authorization_Ind__c = existingProdWithSignalCodeMap.get(prodRecSignalCode.Core_OPN__c).Core_Item_Price_Authorization_Ind__c;
              prodWithoutSignalCodeMapUpdate.add(prodRecSignalCode);
            }
        }
           
           // update prodWithoutSignalCodeMapUpdate;
     recursiveCheckSignalCode = false;   
    }
        
    }*/
   
}