/*********************************************************************************************************
Apex Class Name:Product_Variant_Utility  
Version     : 1.0 
Created Date: 04 Oct 2017
Description : This method is used for showing product variant values based on selected product Id on Supported product
Developer: Geeta Arkadu, sumukh (US79871) - Iteration 7  - Release 4
Developer : Sumukh , US-107484 -Iteration 13 - Release 4.3
**********************************************************************************************************/
public without sharing class Product_Variant_Utility {
    public static Boolean blnShowVariant{get;set;}
    public static Boolean blnShowVariant_NAC{get;set;}
    //public static String selectedProductId{get;set;}
    Public static List<Asset> assetList{get;set;}
    public static List<SelectOption> variants{get;set;}
    Public static List<Core_Flat_Product_Hierarchy__c > flatIdsList{get;set;}
    Public static List<Core_IPS_Supported_Product__c> supportedProdList{get;set;}
    
    Public static List<SelectOption> displayProductVariant(String selectedProductId){ 
        blnShowVariant = false;
        if(selectedProductId!=null && selectedProductId!=''){
            //Query on Asset
            assetList = database.Query('select id, Name,Core_Product_Organization__c,core_supported_product__c,core_supported_product__r.Core_IPS_Is_Show_Variant__c,Core_IPS_Project__c,Core_Product_EPM_ID__c from asset where id=:selectedProductId'); 
            System.debug('List of asset records====='+assetList);
            
            if(!assetList.isEmpty() && assetList.size()>0){
                if(assetList[0].core_supported_product__r.Core_IPS_Is_Show_Variant__c== true){
                    //Query on FlatProductHierarchy
                    String strQuery = 'select id,Core_EPM_Hierarchy_Name__c, Core_L1_EPM_ID__c,Core_L1_EPM_Name__c,Core_L2_EPM_ID__c,Core_L2_EPM_Name__c,Core_Unique_ID__c from Core_Flat_Product_Hierarchy__c where Core_Unique_ID__c like \'%;'+assetList[0].Core_Product_EPM_ID__c+';%\'' +'OR Core_Unique_ID__c like'+ '\'%;'+assetList[0].Core_Product_EPM_ID__c+'\'';
                    
                    flatIdsList= database.Query(strQuery);
                    set<String> ids=new set<String>();
                    System.debug('FLATProd Data'+ flatIdsList);
                    if(!flatIdsList.isEmpty() && flatIdsList.size()>0){
                        
                        for(Core_Flat_Product_Hierarchy__c fph :flatIdsList){
                            String data=fph.Core_Unique_ID__c;
                            System.debug('data===='+data);
                            List<String> recorddata=data.split(';');
                            System.debug('recorddata==='+recorddata);
                            for(integer i=0;i<recorddata.size();i++){
                                if(recorddata[i]==assetList[0].Core_Product_EPM_ID__c){
                                    if(i>0)
                                        ids.add(recorddata.get(i-1));
                                }
                            }  
                        }
                    }          
                    ids.remove(assetList[0].Core_Product_EPM_ID__c);
                    
                    List<Product2> Productlist = new List<Product2>();
                    String strIPS = 'IPS';
                    
                    //Query on Product for showing the product variant names based on EPM ID 
                    if(ids!=null && ids.size()>0){
                        Productlist = database.Query('select id, Name FROM Product2 where Core_Product_Org__c = :strIPS  and Core_Product_Name_EPM_ID__c IN  :ids order by Name');     
                    }
                    
                    variants = new List<SelectOption>();
                    variants.add(new SelectOption('','--Select--'));//Geetha
                    for(Product2 prod:Productlist)
                    {
                        variants.add(new SelectOption(prod.name,prod.name));
                    }
                    if(variants.size()>1){
                        blnShowVariant = true;
                    }
                    return variants;
                }
            }
        }
        return null;
    }

//This method is written for displaying product varints for NAC (No assigned contact cases) 
//Added by sumukh for US107484 for Iteration - 13 , Release - 4.3

  Public static List<SelectOption> displayProductVariant_NAC(String selectedProductId){ 
        blnShowVariant_NAC = false;   
        
        system.debug('Inside NAC Block');   
        system.debug('selectedProductId' + selectedProductId);
        if(selectedProductId!=null && selectedProductId!=''){ 
        
            system.debug('Inside NAC Prod block');        
            supportedProdList=database.Query('select id, Name,Core_IPS_Is_Show_Variant__c,Core_Product__c,Core_Product_EPM_ID__c from Core_IPS_Supported_Product__c where id=:selectedProductId');         
            system.debug('supportedProdList' + supportedProdList);
            if(!supportedProdList.isEmpty() && supportedProdList.size()>0){
             
                if(supportedProdList[0].Core_IPS_Is_Show_Variant__c== true){
                   
                    //Query on FlatProductHierarchy
                    String strQuery = 'select id,Core_EPM_Hierarchy_Name__c, Core_L1_EPM_ID__c,Core_L1_EPM_Name__c,Core_L2_EPM_ID__c,Core_L2_EPM_Name__c,Core_Unique_ID__c from Core_Flat_Product_Hierarchy__c where Core_Unique_ID__c like \'%;'+supportedProdList[0].Core_Product_EPM_ID__c+';%\'' +'OR Core_Unique_ID__c like'+ '\'%;'+supportedProdList[0].Core_Product_EPM_ID__c+'\'';
                    
                    flatIdsList= database.Query(strQuery);
                    set<String> ids=new set<String>();                   
                    if(!flatIdsList.isEmpty() && flatIdsList.size()>0){
                        
                        for(Core_Flat_Product_Hierarchy__c fph :flatIdsList){
                            String data=fph.Core_Unique_ID__c;
                            
                            List<String> recorddata=data.split(';');
                           
                            for(integer i=0;i<recorddata.size();i++){
                                if(recorddata[i]==supportedProdList[0].Core_Product_EPM_ID__c){
                                    if(i>0)
                                        ids.add(recorddata.get(i-1));
                                }
                            }  
                        }
                    }
                    ids.remove(supportedProdList[0].Core_Product_EPM_ID__c);
                    
                    List<Product2> Productlist = new List<Product2>();
                    String strIPS = 'IPS';
                    
                    //Query on Product for showing the product variant names based on EPM ID 
                    if(ids!=null && ids.size()>0){
                        Productlist = database.Query('select id, Name FROM Product2 where Core_Product_Org__c = :strIPS  and Core_Product_Name_EPM_ID__c IN  :ids order by Name');     
                    }
                    
                    variants = new List<SelectOption>();
                    variants.add(new SelectOption('','--Select--'));
                    for(Product2 prod:Productlist)
                    {
                        variants.add(new SelectOption(prod.name,prod.name));
                    }
                    if(variants.size()>1){
                      blnShowVariant_NAC = true;
                    }
                   
                    System.debug('variants'+variants);
                    return variants; 
                    
            }
        }         
   }return null; 
  }          
            
  // end By Sumukh for US 107484            
    /***************************************************************************************************
Method Name:  getplatform_Options
Method Type: Action Helper Method 
Version     : 1.0 
Created Date: 03-12-2018
Function    : Constructs the Platform options based on supported Product selected
Input Parameters: List of Supported Product/Asset Ids 
Output Parameters: List of select options
Description:   Constructs the Platform options based on supp prod/Asset
Used in     : Case Creation
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Popcorn Apps              03-12-2018              Created
****************************************************************************************************/     
    public static List<SelectOption> getplatform_Options(List<Id> idList){ 
        List<SelectOption> platformOptions = new List<SelectOption>();  
        platformOptions.add(new SelectOption('', 'Select Platform'));
        List<Asset> astList = new List<Asset>();
        List<Core_IPS_Supported_Product__c> suppProdList = new List<Core_IPS_Supported_Product__c>();
        astList = [select Id,core_supported_product__c from Asset where Id in:idList];  
        suppProdList = [select Id from Core_IPS_Supported_Product__c where Id in:idList];      
        List<Id> supportedProductIdList = new List<Id>();
        if(astList <> null && astList.size() > 0){
            for(Asset asset:astList){
                supportedProductIdList.add(asset.core_supported_product__c);
            }
        }    
        if(suppProdList <> null && suppProdList.size() > 0){
            for(Core_IPS_Supported_Product__c suppProdObj:suppProdList){
                supportedProductIdList.add(suppProdObj.Id);
            }
        }      
        if(supportedProductIdList <> null && supportedProductIdList.size()>0){
            Map<String,Set<String>> platformByProduct=Product_Variant_Utility.getPlatform(supportedProductIdList);
            if(platformByProduct!=null && platformByProduct.size()>0){
                if(astList <> null && astList.size() > 0){
                    for(Asset asset:astList){
                        if(asset <> null && asset.core_supported_product__c <> null && platformByProduct.get(asset.core_supported_product__c) <> null){
                            for(String pltfrmString:platformByProduct.get(asset.core_supported_product__c)){
                                system.debug('inside for '+pltfrmString);
                                if(pltfrmString != null && pltfrmString != ''){
                                    platformOptions.add(new SelectOption(pltfrmString, pltfrmString));
                                    system.debug('inside for and if'+platformOptions);
                                }
                            }
                        }
                    }        
                }
                if(suppProdList <> null && suppProdList.size() > 0){
                    for(Core_IPS_Supported_Product__c suppProdObj:suppProdList){
                        if(platformByProduct.get(suppProdObj.Id) <> null){
                            for(String pltfrmString:platformByProduct.get(suppProdObj.Id)){
                                system.debug('inside for '+pltfrmString);
                                if(pltfrmString != null && pltfrmString != ''){
                                    platformOptions.add(new SelectOption(pltfrmString, pltfrmString));
                                    system.debug('inside for and if'+platformOptions);
                                }
                            }
                        }
                    }        
                }
                system.debug('#####platformOptions before sorting#####'+platformOptions);
                if(platformOptions <> null && platformOptions.size() > 0){
                    platformOptions.sort();
                }
                system.debug('#####platformOptions after sorting#####'+platformOptions); 
            }          
        }    
        return platformOptions;
    } 
    
    
    /***************************************************************************************************
Method Name:  getPlatform
Method Type: Helper Method 
Version     : 1.0 
Created Date: 03-12-2018
Function    : Returns Map of Supp Prod Id and related Platform Names.
Input Parameters: List of SupportedProduct Id.
Output Parameters: Returns Map of Supp Prod Id and related Platform Names based on SupportedProduct passed.
Description:   This method will return Map of Supp Prod Id and related Platform Names based on Supported Product passed inside.
Used in     : Case Creation
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Popcorn Apps              03-12-2018              Created
****************************************************************************************************/      
    public static Map<String,Set<String>> getPlatform(List<Id> suppProductIdList){
        String platformNames = '';                                
        List<String> epmIdList;
        Set<String> platfomSet;
        List<Core_IPS_Supported_Product__c> suppPrdList;
        List<Core_Flat_Product_Hierarchy__c> fphList = new List<Core_Flat_Product_Hierarchy__c>();
        If(suppProductIdList <> null && suppProductIdList.size() > 0){
            suppPrdList = new List<Core_IPS_Supported_Product__c>();
            suppPrdList = [select Id,Core_Flag_Status__c,Core_Code_Name__c,Core_EOIS__c,Core_Prod_EPM_Id__c,Core_Product__r.Core_Sales_Visible_Flag__c,Core_Product__r.Core_Hierarchy_ID__c from Core_IPS_Supported_Product__c where Id in:suppProductIdList AND Core_Product__r.Core_Sales_Visible_Flag__c =:FALSE AND Core_Product__r.Core_Hierarchy_ID__c=:'59'];
            
        }   
        
        If(suppPrdList <> null && suppPrdList.size() > 0){
            epmIdList = new List<String>();
            for(Core_IPS_Supported_Product__c suppProdObj:suppPrdList){
                if(suppProdObj <> null && suppProdObj.Core_Prod_EPM_Id__c <> null && suppProdObj.Core_Prod_EPM_Id__c <> ''){
                    epmIdList.add(suppProdObj.Core_Prod_EPM_Id__c); 
                }
            }
        }                                      
        if(epmIdList <> null && epmIdList.size() > 0){
            fphList = [select Core_L1_EPM_ID__c,Core_L1_EPM_Name__c,Core_L2_EPM_ID__c,Core_L2_EPM_Name__c,Core_L3_EPM_ID__c,Core_L3_EPM_Name__c,Core_L4_EPM_ID__c,Core_L4_EPM_Name__c,Core_L5_EPM_ID__c,Core_L5_EPM_Name__c from Core_Flat_Product_Hierarchy__c where Core_L5_EPM_ID__c in:epmIdList OR Core_L4_EPM_ID__c in:epmIdList OR Core_L2_EPM_ID__c in:epmIdList];        
            system.debug('RAZZIProdVariantClass'+fphList);
        }
        Map<String, Set<String>> prodHierarchyBySupProd;
        Set<String> platformNameList;
        If(suppPrdList <> null && suppPrdList.size() > 0 && fphList <> null && fphList.size() > 0){
            prodHierarchyBySupProd = new Map<String, Set<String>>();
            for(Core_IPS_Supported_Product__c sp:suppPrdList){ 
                platformNameList = new Set<String>();
                for(Core_Flat_Product_Hierarchy__c fphObj:fphList){
                    if(sp.Core_Prod_EPM_Id__c <> null && sp.Core_Prod_EPM_Id__c <> '' && fphObj.Core_L5_EPM_ID__c <> null && fphObj.Core_L5_EPM_ID__c <> '' && sp.Core_Prod_EPM_Id__c==fphObj.Core_L5_EPM_ID__c && fphObj.Core_L1_EPM_Name__c <> null && fphObj.Core_L1_EPM_Name__c <> ''){
                        platformNameList.add(fphObj.Core_L1_EPM_Name__c);
                    }else if(sp.Core_Prod_EPM_Id__c <> null && sp.Core_Prod_EPM_Id__c <> '' && fphObj.Core_L4_EPM_ID__c <> null && fphObj.Core_L4_EPM_ID__c <> '' && sp.Core_Prod_EPM_Id__c==fphObj.Core_L4_EPM_ID__c && fphObj.Core_L1_EPM_Name__c <> null && fphObj.Core_L1_EPM_Name__c <> ''){
                        platformNameList.add(fphObj.Core_L1_EPM_Name__c);
                    }else if(sp.Core_Prod_EPM_Id__c <> null && sp.Core_Prod_EPM_Id__c <> '' && fphObj.Core_L2_EPM_ID__c <> null && fphObj.Core_L2_EPM_ID__c <> '' && sp.Core_Prod_EPM_Id__c==fphObj.Core_L2_EPM_ID__c && fphObj.Core_L1_EPM_Name__c <> null && fphObj.Core_L1_EPM_Name__c <> ''){
                        platformNameList.add(fphObj.Core_L1_EPM_Name__c);
                    }               
                }                
                prodHierarchyBySupProd.put(sp.id,platformNameList);
            }
        }        
        return prodHierarchyBySupProd;
    }
}