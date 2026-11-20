Public without sharing class Core_IPS_SupportedProduct_Handler{
    
    
    /***************************************************************************************************
Version     : 1.0 
Created Date: 08 Dec 2015
Function    : This method executes when a supported product is inserted 
Input Parameters: Old Map, New Map, Old List, New List
Output Parameters: None
Transactions: After Insert
Description: This method executes When supported product is inserted:
After Insert: Checks if the supported product EOIS is true and modifies status of asses to Obsolete.
Used in    : Core_CaseTrigger_Dispatcher
Number of Queries Within this Method: 2(one per transaction)
Number of Queries in Loop: 0
Number of Queries from Called methods:0
Number of times called: Once for trigger execution
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* JRK                        12/08/2015              Created
* Sugandha                   09/11/2017              Modified Iteration#-2 User story#-US72182
****************************************************************************************************/
    public static void updatedEOIStrue(List<Core_IPS_Supported_Product__c> newList, Map<Id,Core_IPS_Supported_Product__c> oldMap){
    Map<Id,Core_IPS_Supported_Product__c> SupProdMap;
    List<Core_IPS_Product__c> ProjProductList = new List<Core_IPS_Product__c>();
        //Iteration#-2 User story#-US72182 DeveloperName-Sugandha Description- added functionality for public product
        if(!Core_IPS_Helper_Utility.isHandlerMethodExecutionEnabled('updatedEOIStrue'))
          return;
        if(newList <> null && newList.size()>0){
            List<Core_IPS_Supported_Product__c> SupProducts = new List<Core_IPS_Supported_Product__c>();
            List<Id> SupProductIds = new List<Id>();
            //Iteration#-2 User story#-US72182 DeveloperName-Sugandha Description- added functionality for public product
            Set<Id> setPublicSupProdIds = new Set<Id>();
            List<Asset> GlobalAssetLst = new List<Asset>();
            //End
            for(Core_IPS_Supported_Product__c SupProduct: newList){
                if(oldMap.get(SupProduct.id).Core_EOIS__c <> SupProduct.Core_EOIS__c && SupProduct.Core_EOIS__c <> false){
                    SupProducts.add(SupProduct);
                    SupProductIds.add(SupProduct.id);
                }
                //Iteration#-2 User story#-US72182 DeveloperName-Sugandha Description- added functionality for public product
                if(oldMap.get(SupProduct.id).Core_EOIS__c <> SupProduct.Core_EOIS__c && SupProduct.Core_EOIS__c && SupProduct.Core_IPS_Public_Product__c){
                    setPublicSupProdIds.add(SupProduct.Id);
                }
                //End
            }
            
            //Iteration#-2 User story#-US72182 DeveloperName-Sugandha Description- added functionality for public product 
            if(!setPublicSupProdIds.isEmpty())
	    if(Asset.SObjectType.getDescribe().isAccessible()){   // FLS check already added - Adity
            for(Asset assetRec: [Select id,Status,Core_IPS_Global_Assets__c from Asset where Core_Supported_Product__r.Id IN:setPublicSupProdIds]){
                Asset assetObj = new Asset(Id = assetRec.Id, Status = 'Inactive', UsageEndDate = Date.Today());
                GlobalAssetLst.add(assetObj);
		
            }
	}
            if(!GlobalAssetLst.isEmpty()){   
                Update GlobalAssetLst;
            }               
            //End
            
            if(SupProductIds <> null && SupProductIds.size()>0 /*&& SupProducts <> null && SupProducts.size()>0*/){
                if(Core_IPS_Supported_Product__c.SObjectType.getDescribe().isAccessible()){ //FLS check already added - Aditya
                SupProdMap = new Map<Id,Core_IPS_Supported_Product__c>([Select id,Core_EOIS__c,(Select id,Core_MAP_PAR__c from Map_Par_Line_Items__r where Core_Status__c = 'ACTIVE'),(Select id,Status,UsageEndDate from Assets__r where Core_IPS_Project__c <> null) from Core_IPS_Supported_Product__c where id IN: SupProductIds]);
                }
		if(Core_IPS_Product__c.SObjectType.getDescribe().isAccessible()){ //FLS check added - Aditya
                	ProjProductList = [Select id,Status__c from Core_IPS_Product__c where Core_Supported_Product__c IN: SupProducts];
		}
                List<Core_IPS_Product__c> ProjProducts = new List<Core_IPS_Product__c>();
                List<Core_IPS_Map_Par_Line_Item__c> ProdAccessLineItems = new List<Core_IPS_Map_Par_Line_Item__c>();
                
                if(ProjProductList <> null && ProjProductList.size()>0){
                    for(Core_IPS_Product__c ProjProduct: ProjProductList){
                        ProjProduct.Core_IPS_Product_Status__c = 'Inactive';
                        ProjProducts.add(ProjProduct);
                    }
                    update ProjProducts;
                }
                
                if(SupProdMap<> null && SupProdMap.size()>0){
                    for(Core_IPS_Supported_Product__c SupProduct: SupProdMap.values()){
                        for(Core_IPS_Map_Par_Line_Item__c ProdAccessLineItem: SupProdMap.get(SupProduct.id).Map_Par_Line_Items__r){
                            ProdAccessLineItem.Core_Status__c = 'INACTIVE';
                            ProdAccessLineItems.add(ProdAccessLineItem);
                        }
                    }
                    update ProdAccessLineItems;
                }
            }
        }   
    }
    
    
    /***************************************************************************************************
Version     : 1.0 
Created Date: 09 Oct 2015
Function    : This method executes when a supported product is inserted 
Input Parameters: Old Map, New Map, Old List, New List
Output Parameters: None
Transactions: After Insert
Description: This method executes When supported product is inserted:
After Insert: Checks if the supported product EOIS is true and modifies status of asses to Obsolete.
Used in    : Core_CaseTrigger_Dispatcher
Number of Queries Within this Method: 1(one per transaction)
Number of Queries in Loop: 0
Number of Queries from Called methods:0
Number of times called: Once for trigger execution
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Jayaprakash T              10/09/2015              Created
****************************************************************************************************/  
    public static void updatePlatformName(List<core_IPS_supported_product__c> newList){
        List<core_IPS_supported_product__c> spList = new List<core_IPS_supported_product__c>();
        List<Id> supportedProductIdList = new List<Id>();
        for(core_IPS_supported_product__c sp:newList){
            supportedProductIdList.add(sp.id);
        }
        if(core_IPS_supported_product__c.SObjectType.getDescribe().isAccessible()){ //FLS check already added - Aditya
             spList = [select id, Core_Platform_Name__c from core_IPS_supported_product__c where id in:supportedProductIdList];
        }
            if(supportedProductIdList.size()>0){
            Map<String,Set<String>> platformByProduct=Core_IPS_Caseutility.getPlatform(supportedProductIdList);
            String platform;
            if(platformByProduct!=null && platformByProduct.size()>0){
                for(core_IPS_supported_product__c sp:spList){
                    platform='';
                    if(platformByProduct.get(sp.id)!=null){
                        for(String platformName:platformByProduct.get(sp.id)){
                            //[Nov/27 - Abhishek Arya(Defect# DE9627) - Commented the below line and put 4 new lines below. Since The final result was observed with comma as postfix.]
                            //platform=platform+platformName+','; 
                            if(platform == '')
                                platform = platformName;           
                            else
                                platform = platform + ', ' + platformName;                            
                        }
                    }
                    sp.Core_Platform_Name__c=platform;
                    //spList.add(sp);
                }
            }
        }
        if(spList.size()>0){
            Database.update(spList);
        }
    }
    
    /***************************************************************************************************
Function    : This method executes when a supported product is updated
Input Parameters: Old Map, New Map, Old List, New List
Output Parameters: None
Transactions: IsUpdate
Description: This method executes When supported product is updated:
After/Before: During this method update, asset trigger's shouldn't execute and all the asset records should update with alias name as like as alias name on the supported product.
Used in    : Core_IPS_SupportedProduct_Dispatcher
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Kishore Chandolu              05/05/2016              Created
* Yogesh Sharma                 19/03/2018              Added code for updating Search/Reporting tag Field on Asset from Supported Product.
****************************************************************************************************/  
    public static void updateAliasName(List<core_IPS_supported_product__c> newList) {
        List<asset> asList = new List<asset>();
        List<asset> updateAssetList=new List<asset> ();
        List<id> supportedProductIdList = new List<id>();
        for(core_IPS_supported_product__c sp:newList){
            supportedProductIdList.add(sp.id);
            //supportedProductIdList.add(sp.Core_Supported_Product_Alias__c);   
            
        }  
        if(Asset.SObjectType.getDescribe().isAccessible()){ //FLS check already added - Aditya
            asList=[SELECT Core_IPS_Project_Name__c,Core_Alias__c,Core_IPS_Project__c,Core_Supported_Product__c,
                            Core_Support_Org_Name__c,Id,Core_Supported_Product__r.Core_Supported_Product_Alias__c,Core_IPS_Search_Reporting_Tag__c,Core_Supported_Product__r.Core_Supported_Product_Tag__c FROM Asset where Core_Supported_Product__c in:supportedProductIdList];
        }
        Set<Id> dupecheck = new Set<Id>();
        if(asList.size()>0){
            for(asset a:asList){
                a.Core_Alias__c =a.Core_Supported_Product__r.Core_Supported_Product_Alias__c; 
                
                //Added By Yogesh Sharma For I8 - US97152
                a.Core_IPS_Search_Reporting_Tag__c = a.Core_Supported_Product__r.Core_Supported_Product_Tag__c;
                
                if (!dupecheck.contains(a.id)) { 
                    updateAssetList.add(a);
                    dupecheck.add(a.id);
                }   
                
            }
            
        }
        // Update the asset records.            
        Database.update(updateAssetList);
    }
/***************************************************************************************************
Function    : This method creates a global asset when public product checkbox is true
Input Parameters:  newList,oldMap
Output Parameters: None
Transactions: 
No: of SOQL queries:2
No: of DML statements:1
Description: This method executes When public product checkbox on Asset object is checked
Used in    : Core_IPS_SupportedProduct_Dispatcher
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
*  Sugandha                16th Nov, 2017            Created Iteration#-2 User story#-US72182
****************************************************************************************************/   
    public static void createGlobalAsset(List<core_IPS_supported_product__c> newList,Map<ID,core_IPS_supported_product__c> oldMap) {   
        try{
            if(!Core_IPS_Helper_Utility.isHandlerMethodExecutionEnabled('createGlobalAsset'))
              return;              
            if(!String.isBlank(Core_IPS_Helper_Utility.getIPSLabel('Core_IPS_Global_Asset_RT'))){
                RecordType RT = [SELECT Id 
                                    FROM RecordType 
                                    WHERE developerName = :Core_IPS_Helper_Utility.getIPSLabel('Core_IPS_Global_Asset_RT')];           
                List<Asset> globalAsset = new List<Asset>();
                Map<Id,Product2> mapProduct = new Map<Id,Product2>();         
                for(core_IPS_supported_product__c publicProduct: newList){               
                    if(oldMap==null && newList!=null){
                        if(publicProduct.Core_IPS_Public_Product__c == true)
                            mapProduct.put(publicProduct.Core_Product__c,null);              
                    }
                    else if(oldMap!=null && newList!=null){
                        if(publicProduct.Core_IPS_Public_Product__c != oldMap.get(publicProduct.id).Core_IPS_Public_Product__c )
                        {
                            mapProduct.put(publicProduct.Core_Product__c,null); 
                        }            
                    }
                }
                         
                if(mapProduct.size()>0){
                    mapProduct = new Map<Id,Product2>([SELECT Id,Name FROM Product2 WHERE Id IN: mapProduct.keySet()]);
                    
                    for(core_IPS_supported_product__c publicProduct: newList){                   
                       /* if(RT!=null && (publicProduct.Core_Flag_Status__c.equals('Auto Approve') || oldMap == null) )*/  
                        if(RT!=null && (publicProduct.Core_Flag_Status__c.equals('General (ALL Access!)') || oldMap == null) )   //modified by Aayushi US105154
                        
                        {
                            globalAsset.Add(new Asset (Name=mapProduct.get(publicProduct.Core_Product__c).Name,
                                                       RecordTypeId=RT.Id,
                                                       Core_Supported_Product__c=publicProduct.Id,
                                                       Core_Product_Organization__c=publicProduct.Core_Product_Organization__c,
                                                       Product2Id=publicProduct.Core_Product__c,
                                                       Core_IPS_Asset__c=true,
                                                       Core_Project_Asset_Status__c='Active',
                                                       InstallDate = Date.Today(), 
                                                       Status= 'Active'));
                        }            
                    }
                    
                    if(!globalAsset.isEmpty())
                        database.insert (globalAsset,false);
                } 
            }
        }
        catch(Exception e){ }
        
    }
   
    /***************************************************************************************************
Version     : 1.0 
Created Date: 09 Nov 2017
Function    : This method executes when a supported product is Updated 
Input Parameters: New List
Output Parameters: None
Transactions: After Update
Description: This method executes When supported product is Updated:
After Update: Checks if the supported product Public Produc is true and modifies status of Account related assets to Inactive.
Used in    : Core_CaseTrigger_Dispatcher
Number of Queries Within this Method: 1(one per transaction)
Number of Queries in Loop: 0
Number of Queries from Called methods:0
Number of times called: Once for trigger execution
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Sugandha              11/09/2017              Created Iteration#-2 User story#-US72182 
****************************************************************************************************/  
    public static void updateGlobalAssetStatus(List<core_IPS_supported_product__c> newList){
        try{
            if(!Core_IPS_Helper_Utility.isHandlerMethodExecutionEnabled('updateGlobalAssetStatus'))
              return;          
            Set<Id> suppProdIds = new Set<Id>();//Set of all public products
            List<Asset> assetUpdateLst = new List<Asset>(); //List of asset to update status to Inactive        
            for(core_IPS_supported_product__c sp : newList){
                if(sp.Core_IPS_Public_Product__c ){
                    suppProdIds.add(sp.Id);
                }
            }
            //adding all eligible asset in asset update list      
            if(!suppProdIds.isEmpty())
                if(Asset.SObjectType.getDescribe().isAccessible()){ //FLS check already added - Aditya
            for(Asset assetRec : [Select id, Status from Asset where AccountId != NULL and Core_Supported_Product__r.Id IN :suppProdIds]){
                Asset assetObj   = new Asset(Status = 'Inactive',Id = assetRec.Id);
                assetUpdateLst.add(assetObj);
            }
            }
            
            if(!assetUpdateLst.isEmpty()){
                database.update(assetUpdateLst);
            }
        }
        catch(Exception e){}
        
        
    }    
    
/***************************************************************************************************
Version     : 1.0 
Created Date: 25 Sept 2020
Function    : This method executes when a supported product is Inserted
Input Parameters: New List
Output Parameters: None
Transactions: After Insert
Description: This method executes When supported product is Inserted:
After Update: Creates a new MAP record when a new supported product is created/Inserted.
Used in    : Core_IPS_SupportedProduct_Dispatcher
Number of Queries Within this Method: 1(one per transaction)
Number of Queries in Loop: 0
Number of Queries from Called methods:0
Number of times called: Once for trigger execution
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Sumukh                   25/09/2020           Created for User US747410 
****************************************************************************************************/  
public static void createNewMapRecord(List<core_IPS_supported_product__c> newList){
    List<core_IPS_supported_product__c> spList = new List<core_IPS_supported_product__c>();
    List<Id> supportedProductIdList = new List<Id>();
    String supOrgName;
    String supProdName;
    Boolean isMapInserted = false;
    for(core_IPS_supported_product__c sp:newList){
      supportedProductIdList.add(sp.id);
    }
    if(core_IPS_supported_product__c.SObjectType.getDescribe().isAccessible()){ //FLS check added - Aditya
         spList = [select id, Core_Platform_Name__c,Core_Product_Organization__c,Core_Flag_Status__c,Core_Supported_Product_Name__c,Core_Support_Org_Name__c, Core_Product__c, Core_Product__r.name from core_IPS_supported_product__c where id in:supportedProductIdList];
    }
        if(spList.size() > 0){
        supOrgName = spList[0].Core_Support_Org_Name__c;
        supProdName = spList[0].Core_Product__r.name;
        if(supportedProductIdList.size()>0){    
            Core_IPS_MAP_PAR__c map1  = new Core_IPS_MAP_PAR__c();
            List<Core_IPS_Map_Par_Line_Item__c> mapLineItems = new List<Core_IPS_Map_Par_Line_Item__c>();        
            List<Core_IPS_MAP_Product__c> coreMapPrdToInsert = new List<Core_IPS_MAP_Product__c>();       
            map1.Core_Product_Organization__c = spList[0].Core_Product_Organization__c;       
            map1.core_name__c = supProdName + '  [  ' + supOrgName + '  ]  ';
            map1.RecordTypeId = schema.sobjecttype.Core_IPS_MAP_PAR__c.getrecordtypeinfosbyname().get('MAP').getRecordTypeId();
            map1.Core_Submitter_Comments__c = 'test MAP';
            
            if(spList[0].Core_Flag_Status__c == 'Par Hidden' || spList[0].Core_Flag_Status__c == 'Approval Required' || spList[0].Core_Flag_Status__c == 'Auto Approve'){
                insert map1;
                isMapInserted = true;            
            }        
            if(isMapInserted == true){
                Core_IPS_MAP_Product__c corePrd = new Core_IPS_MAP_Product__c();
                corePrd.Core_MAP_PAR__c = map1.id;
                corePrd.Core_MAP_Supported_Product__c = spList[0].id;            
                insert corePrd;            
            }
         }
     }
 }

    
}