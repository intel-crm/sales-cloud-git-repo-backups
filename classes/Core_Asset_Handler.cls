public with sharing class Core_Asset_Handler{
    /***************************************************************************************************
Method Name:  shareAssetMethod
Version     : 1.0 
Created Date: 29 Oct 2015
Function    : This method does the sharing of Asset with associated Account and Project.
Input Parameters: Asset List
Output Parameters: None
Description:   This method takes list of Asset and share the Asset to related Account and Project.
Used in     : 
Number of Queries Within this Method: 0
Number of Queries in Loop: 0
Number of Queries from Called methods:  5
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* JRK                        10/29/2015              Created
****************************************************************************************************/
    public static void changeAssetOwner(List<Asset> newList){
        // Venrublity Fix - Refering query to service class 
        // User U = [Select Id, Name, isActive from User where alias IN ('iowne')];
        //added by sabira 24-07-2026  
        User U = ((List<User>) Core_IPS_QueryService.queryRecords('Select Id, Name, isActive from User where alias IN :aliases', new Map<String,Object>{'aliases' => new List<String>{'iowne'}}))[0];
        for(Asset ast: newList){
            if(U.isActive <> false)
                ast.ownerid = U.Id;
        }
    }  
    
    
    
    /***************************************************************************************************
Method Name:  grantAssetAccesstoFAEs
Version     : 1.0 
Created Date: 29 Oct 2015
Function    : This method does the sharing of Asset with associated Account and Project.
Input Parameters: Asset List
Output Parameters: None
Description:   This method takes list of Asset and share the Asset to related Account and Project.
Used in     : 
Number of Queries Within this Method: 0
Number of Queries in Loop: 0
Number of Queries from Called methods:  5
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Abhishek Arya              10/29/2015              Created
****************************************************************************************************/ 
    @future
    public static void grantAssetAccesstoFAEs(String oldSerializedList,String serializedList){
        
        //[To create list of Active Assets Only.]
        
        List<Asset> newAssetList = (List<Asset>)JSON.deserialize(serializedList, List<Asset>.class);
        
        List<Asset> newActiveAssetList = new List<Asset>();
        if(newAssetList <> null && newAssetList.size() > 0){
            for(Asset astObj:newAssetList){
                //added by Aayushi for US113701
                if(astObj.Status == 'Active' && !astObj.Core_IPS_Private_Project__c){
                    newActiveAssetList.add(astObj);
                }
            }
        }
        
        //[Verifying if Active Assets List is not empty.]
        if(newActiveAssetList.size() > 0){
            
            //[Logic Below : To get the map of Account Id as key and UserList as values for FAEs.]        
            Map<Id,List<Id>> assetByAccount = new Map<Id,List<Id>>();    
            
            //[Calling the Utility method to get the map of AccountId and related List of AssetId.]
            assetByAccount = Core_IPS_Helper_Utility.getAssetsByAccount(newActiveAssetList);
            
            Map<Id, Set<id>> allFAEUsersByAccount;
            Map<Id, Set<id>> faesByAccount;
            If(assetByAccount <> null && assetByAccount.size() > 0 && assetByAccount.keyset() <> null){
                allFAEUsersByAccount = new Map<Id,Set<Id>>();                         
                faesByAccount = new Map<Id,Set<Id>>();
                
                //[Calling the Utility method to get the map of AccountId and related List of FAE UserIds.]
                faesByAccount = Core_IPS_Helper_Utility.getFAEsByAccount(assetByAccount.keyset());
                
                //[Verifying if Map has any key-vaue pair. If Yes, Then adding all key-value pair in Map.]
                if(faesByAccount.size() > 0){
                    allFAEUsersByAccount.putall(faesByAccount);
                }                             
            }        
            
            //[Logic to get all FAEs Info related to associated Project.]        
            Map<Id,Set<Id>> assetByProject = new Map<Id,Set<Id>>();
            
            //[Calling the Utility method to get the map of ProjectId and related List of AssetId.]
            assetByProject = Core_IPS_Helper_Utility.listAssetsByProject(newActiveAssetList);
            
            Map<Id, Set<id>> allFAEUsersByProject;
            Map<Id, Set<id>> faesByProject;
            If(assetByProject <> null && assetByProject.size() > 0 && assetByProject.keyset() <> null){
                allFAEUsersByProject = new Map<Id,Set<id>>();
                faesByProject = new Map<Id,Set<id>>();
                
                //[Calling the Utility method to get the map of ProjectId and related List of FAE UserIds.]
                faesByProject = Core_IPS_Helper_Utility.getFAEsByProject(assetByProject.keyset());
                
                //[Verifying if Map has any key-vaue pair. If Yes, Then adding all key-value pair in Map.]
                if(faesByProject.size() > 0)
                    allFAEUsersByProject.putAll(faesByProject);                        
            }         
            
            //[Initializing the map of Asset Id as key and Set Of related Users as pair.]
            Map<Id,Set<Id>> assetShareMap = new Map<Id,Set<Id>>();
            Map<Id,Asset> oldMap = new Map<Id,Asset>();         
            List<Asset> oldAssetList = (List<Asset>)JSON.deserialize(oldSerializedList, List<Asset>.class);
            for(Asset asst: oldAssetList){
                oldMap.put(asst.id,asst);
            }
            
            //[Below logic is to get the assetId v/s set of UserIds via Account and Project.]
            Set<Id> userSetId;
            for(Asset assetObj: newActiveAssetList){
                userSetId = new Set<Id>();
                if((oldMap == null && allFAEUsersByAccount <> null && allFAEUsersByAccount.size() > 0 && allFAEUsersByAccount.get(assetObj.AccountId) <> null) || (oldMap <> null && assetObj <> null && oldMap.get(assetObj.Id).Status <> assetObj.Status && assetObj.Status == 'Active' && allFAEUsersByAccount <> null && allFAEUsersByAccount.size() > 0 && allFAEUsersByAccount.get(assetObj.AccountId) <> null)){                
                    for(Id userId : allFAEUsersByAccount.get(assetObj.AccountId)){
                        userSetId.add(userId);
                    }                 
                }                        
                if((oldMap == null && allFAEUsersByProject <> null && allFAEUsersByProject.size() > 0 && allFAEUsersByProject.get(assetObj.Core_IPS_Project__c) <> null) || (oldMap <> null && assetObj <> null && oldMap.get(assetObj.Id).Status <> assetObj.Status && assetObj.Status == 'Active' && allFAEUsersByProject <> null && allFAEUsersByProject.size() > 0 && allFAEUsersByProject.get(assetObj.Core_IPS_Project__c) <> null)){                
                    for(Id userId : allFAEUsersByProject.get(assetObj.Core_IPS_Project__c)){
                        userSetId.add(userId);
                    }                 
                }
                assetShareMap.put(assetObj.Id,userSetId);
            }              
            
            //[Calling the sharing method to grant the Access to all Users based on AssetIds.]
            if(assetShareMap <> null && assetShareMap.size() > 0){                        
                Core_SharingUtility.provideAccess('Asset','assetshare','read',assetShareMap);
            }
        }        
    }
    
    /***************************************************************************************************
Method Name:  grantAssetAccesstoFAEs
Version     : 1.0 
Created Date: 29 Oct 2015
Function    : This method does the sharing of Asset with associated Account and Project.
Input Parameters: Asset List
Output Parameters: None
Description:   This method takes list of Asset and share the Asset to related Account and Project.
Used in     : 
Number of Queries Within this Method: 0
Number of Queries in Loop: 0
Number of Queries from Called methods:  5
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Abhishek Arya              10/29/2015              Created
****************************************************************************************************/ 
    @future
    public static void grantAssetAccesstoFAEs(String serializedList){
        
        //[To create list of Active Assets Only.]
        
        List<Asset> newAssetList = (List<Asset>)JSON.deserialize(serializedList, List<Asset>.class);
        
        List<Asset> newActiveAssetList = new List<Asset>();
        if(newAssetList <> null && newAssetList.size() > 0){
            for(Asset astObj:newAssetList){
                //added by Aayushi Us113701
                if(astObj.Status == 'Active' && !astObj.Core_IPS_Private_Project__c){
                    newActiveAssetList.add(astObj);
                }
            }
        }
        
        //[Verifying if Active Assets List is not empty.]
        if(newActiveAssetList.size() > 0){
            
            //[Logic Below : To get the map of Account Id as key and UserList as values for FAEs.]        
            Map<Id,List<Id>> assetByAccount = new Map<Id,List<Id>>();    
            
            //[Calling the Utility method to get the map of AccountId and related List of AssetId.]
            assetByAccount = Core_IPS_Helper_Utility.getAssetsByAccount(newActiveAssetList);
            
            Map<Id, Set<id>> allFAEUsersByAccount;
            Map<Id, Set<id>> faesByAccount;
            If(assetByAccount <> null && assetByAccount.size() > 0 && assetByAccount.keyset() <> null){
                allFAEUsersByAccount = new Map<Id,Set<Id>>();                         
                faesByAccount = new Map<Id,Set<Id>>();
                
                //[Calling the Utility method to get the map of AccountId and related List of FAE UserIds.]
                faesByAccount = Core_IPS_Helper_Utility.getFAEsByAccount(assetByAccount.keyset());
                
                //[Verifying if Map has any key-vaue pair. If Yes, Then adding all key-value pair in Map.]
                if(faesByAccount.size() > 0){
                    allFAEUsersByAccount.putall(faesByAccount);
                }                             
            }        
            
            //[Logic to get all FAEs Info related to associated Project.]        
            Map<Id,Set<Id>> assetByProject = new Map<Id,Set<Id>>();
            
            //[Calling the Utility method to get the map of ProjectId and related List of AssetId.]
            assetByProject = Core_IPS_Helper_Utility.listAssetsByProject(newActiveAssetList);
            
            Map<Id, Set<id>> allFAEUsersByProject;
            Map<Id, Set<id>> faesByProject;
            If(assetByProject <> null && assetByProject.size() > 0 && assetByProject.keyset() <> null){
                allFAEUsersByProject = new Map<Id,Set<id>>();
                faesByProject = new Map<Id,Set<id>>();
                
                //[Calling the Utility method to get the map of ProjectId and related List of FAE UserIds.]
                faesByProject = Core_IPS_Helper_Utility.getFAEsByProject(assetByProject.keyset());
                
                //[Verifying if Map has any key-vaue pair. If Yes, Then adding all key-value pair in Map.]
                if(faesByProject.size() > 0)
                    allFAEUsersByProject.putAll(faesByProject);                        
            }         
            
            //[Initializing the map of Asset Id as key and Set Of related Users as pair.]
            Map<Id,Set<Id>> assetShareMap = new Map<Id,Set<Id>>();
            Map<Id,Asset> oldMap = new Map<Id,Asset>(); 
            
            
            //[Below logic is to get the assetId v/s set of UserIds via Account and Project.]
            Set<Id> userSetId;
            for(Asset assetObj: newActiveAssetList){
                userSetId = new Set<Id>();
                if(allFAEUsersByAccount <> null && allFAEUsersByAccount.size() > 0 && allFAEUsersByAccount.get(assetObj.AccountId) <> null){                
                    for(Id userId : allFAEUsersByAccount.get(assetObj.AccountId)){
                        userSetId.add(userId);
                    }                 
                }                        
                if(allFAEUsersByProject <> null && allFAEUsersByProject.size() > 0 && allFAEUsersByProject.get(assetObj.Core_IPS_Project__c) <> null){                
                    for(Id userId : allFAEUsersByProject.get(assetObj.Core_IPS_Project__c)){
                        userSetId.add(userId);
                    }                 
                }
                assetShareMap.put(assetObj.Id,userSetId);
            }              
            
            //[Calling the sharing method to grant the Access to all Users based on AssetIds.]
            if(assetShareMap <> null && assetShareMap.size() > 0){                        
                Core_SharingUtility.provideAccess('Asset','assetshare','read',assetShareMap);
            }
        }        
    }
    /***************************************************************************************************
Method Name:  grantAssetAccesstoCustomers
Version     : 1.0 
Created Date: Jan 09 2016
Function    : This method does the sharing of Asset with associated Account and Project(Only For Customers) as
well as Intel Support Team.
Input Parameters: Asset List
Output Parameters: None
Description:   This method takes list of Asset and share the Asset to related Account and Project(Customer Only) & Intel Support Team.
Used in     : 
Number of Queries Within this Method: 3
Number of Queries in Loop: 0
Number of Queries from Called methods: 0
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Abhishek Arya              01/09/2016              Created
****************************************************************************************************/
    @future
    public static void grantAssetAccesstoCustomers(String serializedList){
        List<Asset> newAssetList = (List<Asset>)JSON.deserialize(serializedList, List<Asset>.class);
        //[To create list of Active Assets Only.]
        List<Asset> newActiveAssetList = new List<Asset>();
        if(newAssetList <> null && newAssetList.size() > 0){
            for(Asset astObj:newAssetList){
                if(astObj.Status == 'Active'){
                    newActiveAssetList.add(astObj);
                }
            }
        }
        
        //[Verifying if Active Assets List is not empty.]
        if(newActiveAssetList.size() > 0){ 
            
            //[Initializing Set of AccountId and ProjectId.]
            Set<Id> accountIdSet = new Set<Id>();
            Set<Id> projectIdSet = new Set<Id>();
            
            //[Bifurcating the Assets into ProjectId and AccountId Set.]
            for(Asset astObj:newActiveAssetList){                
                if(astObj.Core_IPS_Project__c <> null){
                    projectIdSet.add(astObj.Core_IPS_Project__c);
                }
                if(astObj.AccountId <> null && astObj.Core_IPS_Project__c == null){
                    accountIdSet.add(astObj.AccountId);
                }
            }
            
            //[Creating Map to add all Project Specific Assets and grant access.]
            Map<Id,Id> grantAccessToProjectBasedAsset = new Map<Id,Id>();        
            Map<Id,Id> grantInternalAccessToProjectBasedAsset = new Map<Id,Id>();   //added by Aayushi US102838
            
            //[Creating Map to add all Account Specific Assets and grant access.]    
            Map<Id,Set<Id>> grantAccessToAccountBasedAsset = new Map<Id,Set<Id>>();
            Map<Id,Core_IPS_Project__c> projectById = new Map<Id,Core_IPS_Project__c>();
            //[Processing Project specific Assets only.]
            if(projectIdSet.size() > 0){
                //FLS check added-Venugopal
                if(Core_IPS_Project__c.SObjectType.getDescribe().isAccessible()){
                    projectById = new Map<Id,Core_IPS_Project__c>([Select id, Core_IPS_GroupId__c,Core_IPS_InternalGroupId__c from Core_IPS_Project__c where id IN: projectIdSet]); //modified by Aayushi to share assets with Intel Support Team US102838
                }
                for(Asset ast: newActiveAssetList){
                    if(ast.Core_IPS_Project__c!=null && projectById.get(ast.Core_IPS_Project__c)!=null){
                        grantAccessToProjectBasedAsset.put(ast.Id,projectById.get(ast.Core_IPS_Project__c).Core_IPS_GroupId__c);
                        //start added by Aayushi to share assets with Intel Support Team US102838
                        if(projectById.get(ast.Core_IPS_Project__c).Core_IPS_InternalGroupId__c!=null){
                            grantInternalAccessToProjectBasedAsset.put(ast.Id,projectById.get(ast.Core_IPS_Project__c).Core_IPS_InternalGroupId__c);    
                        } //end    
                    }
                }
            }
            //[Processing Account specific Assets only.]
            if(accountIdSet.size() > 0){
                Map<Id,Set<Id>> custUserRoleIdsByAccountId = Core_SharingUtility.getCustomerUserRoleIdsByAccountId(accountIdSet);
                if(custUserRoleIdsByAccountId <> null && custUserRoleIdsByAccountId.size() > 0){
                    List<Id> userRolesList = new List<Id>();
                    for(Id accId:custUserRoleIdsByAccountId.keyset()){
                        userRolesList.addAll(custUserRoleIdsByAccountId.get(accId));    
                    }
                    Map<id,Set<id>> groupIdsByRole = Core_SharingUtility.getGroupIdsByRoleId(userRolesList);
                    for(Asset astObj:newActiveAssetList){
                        if(astObj.accountId!=null && custUserRoleIdsByAccountId.get(astObj.AccountId)!=null){
                            Set<Id> groupIdSet = new Set<Id>();
                            for(Id userRoleId:custUserRoleIdsByAccountId.get(astObj.AccountId)){                                
                                for(Id groupId:groupIdsByRole.get(userRoleId)){
                                    groupIdSet.add(groupId);
                                }                                    
                            }   
                            grantAccessToAccountBasedAsset.put(astObj.Id,groupIdSet);   
                        }
                    }
                }
            }                                    
            
            //[Verifying if Project based Map is empty or not. If not empty then calling the provide access method.]
            if(grantAccessToProjectBasedAsset.size() > 0){
                Core_SharingUtility.provideAccess('Asset', 'AssetShare','Read',grantAccessToProjectBasedAsset);                
            }
            if(grantInternalAccessToProjectBasedAsset.size() > 0){
                Core_SharingUtility.provideAccess('Asset', 'AssetShare','Read',grantInternalAccessToProjectBasedAsset);                
            }
            //[Verifying if Account based Map is empty or not. If not empty then calling the provide access method.]
            if(grantAccessToAccountBasedAsset.size() > 0){
                Core_SharingUtility.provideAccess('Asset', 'AssetShare','Read',grantAccessToAccountBasedAsset);                
            }                                              
        }        
    }
    
    /***************************************************************************************************
Method Name:  LItemUpdate
Version     : 1.0 
Created Date: 29 Aug 2015
Function    : This method is used to update the Asset lookup on Product Access Line Item.
Input Parameters: Asset List
Output Parameters: None
Description:   This method takes a list of Assets and updates the Asset lookup of the Line Items associated with.
Used in     : 
Number of Queries Within this Method: 1
Number of Queries in Loop: 0
Number of Queries from Called methods:  0
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* JRK                        08/29/2015              Created
****************************************************************************************************/
    @future
    public static void LItemUpdate(String serializedList){
        List<Core_IPS_Map_Par_Line_Item__c> LineItemList = new List<Core_IPS_Map_Par_Line_Item__c>();
        List<Asset> assets = (List<Asset>)JSON.deserialize(serializedList, List<Asset>.class);
        if(assets!=null && assets.size()>0 ){
            List<String> AllMapList = new List<String>();            
            for(Asset ast1:assets){
                if(ast1.Core_Map_List__c!=null){
                    Integer MapListSize = ast1.Core_Map_List__c.split(';').size();
                    String MapList = ast1.Core_Map_List__c.split(';').get(MapListSize-1);
                    AllMapList.add(MapList);
                }
            }
            if(AllMapList.size()>0 && AllMapList!=null){
                //FLS check added -Venugopal
                if(Core_IPS_Map_Par_Line_Item__c.SObjectType.getDescribe().isAccessible()){
                    LineItemList = [Select id,Core_Account__c,Core_Supported_Product__r.Core_Supported_Product_Name__c,Core_Supported_Product__c,Core_Status__c,Core_MAP_PAR__c,Core_MAP_PAR__r.Core_Product_Organization__c from Core_IPS_Map_Par_Line_Item__c where Core_MAP_PAR__c IN:AllMapList];
                }
                Map<id,Core_IPS_Map_Par_Line_Item__c> updatelItemMap = new Map<id,Core_IPS_Map_Par_Line_Item__c>();
                for(Core_IPS_Map_Par_Line_Item__c LItem: LineItemList){                         
                    for(Asset ast: assets){
                        if(LItem.Core_Account__c == ast.Accountid && LItem.Core_Supported_Product__c == ast.Core_Supported_Product__c && LItem.Core_MAP_PAR__r.Core_Product_Organization__c == ast.Core_Product_Organization__c){
                            LItem.Core_Intel_Product__c = ast.id;                                                        
                            updatelItemMap.put(LItem.id,LItem);
                            Core_Asset_Dispatcher.Assetfieldupdated=true;
                        }
                    }  
                }
                update updatelItemMap.values(); 
            }
        }
    }  
    
    /***************************************************************************************************
Method Name:  UpdateProjProduct
Version     : 1.0 
Created Date: 06 Dec 2015
Function    : This method is used to update the Asset lookup on Product Access Line Item.
Input Parameters: Asset List
Output Parameters: None
Description:   This method takes a list of Assets and updates the Asset lookup of the Line Items associated with.
Used in     : 
Number of Queries Within this Method: 1
Number of Queries in Loop: 0
Number of Queries from Called methods:  0
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* JRK                        12/06/2015              Created
****************************************************************************************************/
    @future
    public static void UpdateProjProduct(String serializedList){
        List<Asset> AssetList = (List<Asset>)JSON.deserialize(serializedList, List<Asset>.class);
        Map<Id,Id> ProjectsandAssets = new Map<Id,Id>();
        Map<Id,Id> SupProdsandAssets = new Map<Id,Id>();
        Map<Id,Set<Id>> ProjectsandAssetsMap = new Map<Id,Set<Id>>();
        List<Core_IPS_Product__c> ProjProducts = new List<Core_IPS_Product__c>();
        List<Core_IPS_Product__c> ProjProductList = new List<Core_IPS_Product__c>();
        if(AssetList <> null && AssetList.size()>0){
            for(Asset ast: AssetList){
                //Added by Gourav: Mapping logic to take care of multiple Project Products associated to a Project
                if(ProjectsandAssetsMap.containsKey(ast.Core_IPS_Project__c)){
                    Set<Id> assetSet = ProjectsandAssetsMap.get(ast.Core_IPS_Project__c);
                    assetSet.add(ast.Id);
                    ProjectsandAssetsMap.put(ast.Core_IPS_Project__c,assetSet);
                }else{
                    ProjectsandAssetsMap.put(ast.Core_IPS_Project__c,new Set<Id> {ast.id});
                }   
                SupProdsandAssets.put(ast.Core_Supported_Product__c,ast.id);
            }
            if(ProjectsandAssetsMap <> null && ProjectsandAssetsMap.size()>0 && SupProdsandAssets <> null && SupProdsandAssets.size()>0){
                //FLS check added-Venugopal
                if(Core_IPS_Product__c.SObjectType.getDescribe().isAccessible()){
                    // Venrublity Fix - Refering query to service class
                    // ProjProductList = [Select id,Core_Supported_Product__c,Core_Intel_Product__c,Core_Intel_Product_Status__c,Core_IPS_Project__c from Core_IPS_Product__c 
                    //                                          where Core_IPS_Project__c IN: ProjectsandAssetsMap.keyset() and Core_Supported_Product__c IN: SupProdsandAssets.keyset()];
                    ProjProductList = (List<Core_IPS_Product__c>)Core_IPS_QueryService.queryRecords('Select id,Core_Supported_Product__c,Core_Intel_Product__c,Core_Intel_Product_Status__c,Core_IPS_Project__c from Core_IPS_Product__c where Core_IPS_Project__c IN: ProjectsandAssetsMap and Core_Supported_Product__c IN: SupProdsandAssets', new Map<String,Object>{'ProjectsandAssetsMap'=>ProjectsandAssetsMap.keyset(),'SupProdsandAssets'=>SupProdsandAssets.keyset()});
                }
                if(ProjProductList <> null && ProjProductList.size()>0){
                    for(Core_IPS_Product__c ProjProduct: ProjProductList){
                        //Getting Asset Id based on ProjectProduct.SupportedProduct value
                        ProjProduct.Core_Intel_Product__c = SupProdsandAssets.get(ProjProduct.Core_Supported_Product__c);
                        ProjProducts.add(ProjProduct);
                    }
                    System.debug('sab'+ProjProducts);//added by sabira
                    if(ProjProducts <> null && ProjProducts.size()>0)
                        //update ProjProducts; 
                        Core_IPS_QueryService.updateRecords(ProjProducts);      
                }
            }
        }
    }
    
    /***************************************************************************************************
Version     : 1.0 
Created Date: 27 Oct 2015
Function    : This method updates product information on asset from Product Hierarchy Table
Input Parameters: Asset List
Output Parameters: None
Transactions: Before Insert
Description: This method updates product information on asset from Product Hierarchy Table and codename, 
alias from supported product object
Used in     : Core_Asset_Dispatcher
Number of Queries Within this Method: 1
Number of Queries in Loop: 0
Number of Queries from internal method calls:2
Number of times called: Once for trigger execution
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Jayaprakash T              10/27/2015              Created
* Jayaprakash T              10/28/2015              added code for updating codename and alias on Asset from Supported product.
* Yogesh Sharma              19/03/2018              Added code for updating Search/Reporting tag Field on Asset from Supported Product. 
* Aayushi Singhal			 22/06/2018				Modified by Aayushi for DE40248   
****************************************************************************************************/     
    //commented future by Aayushi DE40248
    // @future
    public static void updateProductInformationOnAsset(/*String serializedList*/ List<Asset> newList ){
        List<Core_IPS_Supported_Product__c> spList = new List<Core_IPS_Supported_Product__c>();   
        // List<Asset> newList = (List<Asset>)JSON.deserialize(serializedList, List<Asset>.class);		//commented by Aayushi DE40248
        if(newList <> null && newList.size() > 0){   
            List<Id> supportedProductIdList = new List<Id>();
            for(Asset asset:newList){
                supportedProductIdList.add(asset.core_supported_product__c);
            }
            /*Start -- Tushar -- 12/06/2026 --- CRUD Added as part of vulnerability fix. */
            if (Core_IPS_Supported_Product__c.SObjectType.getDescribe().isAccessible()) {
                if (!Schema.SObjectType.Core_IPS_Supported_Product__c
                    .fields.Core_Code_Name__c.isAccessible()) {
                        spList = [select Id, Core_Supported_Product_Alias__c, 
                                  Core_Supported_Product_Tag__c 
                                  from Core_IPS_Supported_Product__c 
                                  where Id in :supportedProductIdList];
                    } else {
                        spList = [select Id, Core_Supported_Product_Alias__c, 
                                  Core_Code_Name__c, Core_Supported_Product_Tag__c 
                                  from Core_IPS_Supported_Product__c 
                                  where Id in :supportedProductIdList];
                    }
            }
            /*End -- Tushar -- 12/06/2026 --- added as part of vulnerability fix. */
            if(supportedProductIdList <> null && supportedProductIdList.size()>0){
                Map<String,Set<String>> platformByProduct=Core_IPS_Caseutility.getPlatform(supportedProductIdList);
                String platform;
                //if(platformByProduct!=null && platformByProduct.size()>0){ 
                for(Asset asset:newList){
                    //platform='';
                    if(platformByProduct!=null && platformByProduct.size()>0 && platformByProduct.get(asset.core_supported_product__c)!=null){
                        platform='';
                        for(String platformName:platformByProduct.get(asset.core_supported_product__c)){
                            //[Nov/27 - Abhishek Arya(Defect# DE9627) - Commented the below line and put 4 new lines below. Since The final result was observed with comma as postfix.]
                            //platform=platform+platformName+','; 
                            if(platform == '')
                                platform = platformName;            
                            else
                                platform = platform + ', ' + platformName;                              
                        }                       
                        asset.Core_Platform__c=platform;
                    }
                    //asset.Core_Platform__c=platform;                    
                    if(spList <> null && spList.size() > 0){
                        for(Core_IPS_Supported_Product__c sp:spList){
                            if(sp.id==asset.core_supported_product__c){
                                asset.core_alias__c=sp.Core_Supported_Product_Alias__c;
                                asset.core_code_name__c=sp.Core_Code_Name__c;
                                //Added By Yogesh Sharma For I8 - US97152
                                asset.Core_IPS_Search_Reporting_Tag__c = sp.Core_Supported_Product_Tag__c; 
                                break;
                            }
                        }
                    }
                }
                //}
            }
        }
    }
    
    /***************************************************************************************************
Version     : 1.0 
Created Date: 02 July 2018
Function    : This method updates information on Asset from Project
Input Parameters: Asset List
Output Parameters: None
Transactions: Before Insert
Description: This method updates Project information on asset 
Used in     : Core_Asset_Dispatcher
Number of Queries Within this Method: 
Number of Queries in Loop: 0
Number of Queries from internal method calls:
Number of times called: Once for trigger execution
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Aayushi Singhal			 02/11/2018				Created for US113701  
****************************************************************************************************/
    public static void updateProjectInformationOnAsset(List<Asset> newList ){
        if(!Core_IPS_Helper_Utility.isHandlerMethodExecutionEnabled('updatePrivateProjectSharing')) {return;} 
        
        if(newList <> null && newList.size() > 0){   
            List<Id> projectIdList = new List<Id>();
            for(Asset asset:newList){
                if(asset.Core_IPS_Project__c!=null){
                    projectIdList.add(asset.Core_IPS_Project__c);
                }
            }
            
            Map<Id,Core_IPS_Project__C> projMap=new Map<Id,Core_IPS_Project__C>([Select Id, core_IPS_Private__C from Core_IPS_Project__C where Id In: projectIdList]);
            for(Asset asset:newList){
                if(projMap!=null && projMap.size()>0 && asset.Core_IPS_Project__c!=null){
                    asset.Core_IPS_Private_Project__c=projMap.get(asset.Core_IPS_Project__c).core_IPS_Private__C;
                }
                
            }
        }
        
    }
    
}