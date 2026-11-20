/******************************************************
*Class Name:  Core_IPS_MapCreationController_LWC 
*Version     : 1.0 
*Description:  Controller for Core_IPS_Create_MAP Page
*Modification Log :
* Developer: Minhaj Ameen   Date    22/06/2022      Description: Apex controller for core_IPS_SupportOrg_ProductAccess
* ----------------------------------------------------------------------------                 
******************************************************/
public with sharing class Core_IPS_MapCreationController_LWC {
    
    public static String AccountListQuery;
    public static Core_IPS_Product_Organization__c prodOrg{get;set;}
    public static Core_IPS_Product_Organization__c prodOrgQuery{get;set;}
    public static List<wrapAccount> wrapAccountList {get; set;}
    public static List<Account> aclst;
    public static List<Core_IPS_Supported_Product__c> supProds;
    public static List<Product2> prodList;  
    public static string MapNameText{get;set;} 
    public static String submitterComments{get;set;}  
    public static Map<Id,Core_IPS_Supported_Product__c> mapProdToSupProd = new Map<Id,Core_IPS_Supported_Product__c>();
    
    public static List<Id> prodIdList;
    Public static List<WrapLineItem> ListReqLineItem {get;set;}
    public static List<WrapLineItem> LineItemlist{get;set;}  
    public static List<SelectedProduct> productList;
    
    public static Core_IPS_MAP_PAR__c map1;
    public static Core_IPS_MAP_PAR__c map2;
    
    @AuraEnabled(cacheable=false)
    public static List<Account> searchAccounts(String searchText,Integer limitSize, Integer offset){
        // Wrapaccountlist = new List<wrapAccount>(); //-changes made nov 24
        String searchTxt = '%'+searchText+'%';
        String fieldSetFields='select ';
        for(Schema.FieldSetMember f : SObjectType.Account.FieldSets.Core_Mapacc_Field_Set.getFields()) {
            fieldSetFields += f.getFieldPath() + ', ';
        }
        if(Label.Core_IPS_UCD_Toggle_Switch == 'CIM_ID') {
            fieldSetFields = fieldSetFields.replace('Core_Business_Party_Id__c', 'Core_CIM_ID__c');
        }
        // SOQL Injection Fix  - Start- Shipra
        Map<String, Object> bindMap = new Map<String, Object>{'cndaNumber' => '','searchText'  => searchTxt };
        AccountListQuery =fieldSetFields+'Phone, Owner.Name from Account where (Core_CNDA_Number__c != :cndaNumber OR Core_CNDA_Number__c != Null) and Core_IPS_Active__c=true and name like :searchText ORDER BY Account.Name ASC NULLS LAST LIMIT ' +limitSize + ' OFFSET '+ offset; 
        aclst = new List<Account>();
        aclst = Database.queryWithBinds(AccountListQuery,bindMap,AccessLevel.USER_MODE);
        // SOQL Injection Fix  - ENd - Shipra
        return aclst;
    }
    @AuraEnabled(cacheable=false)
    public static boolean errormessage(Id orgID){
        if(Core_IPS_Product_Organization__c.SObjectType.getDescribe().isAccessible()){
            prodOrgQuery = [select id,name,Core_IPS_Support_Org_Name__c,OwnerId from Core_IPS_Product_Organization__c where id = :orgID];
        }
        List<Core_IPS_Product_Organization__c> ProdOrgs = new List<Core_IPS_Product_Organization__c>();
        ProdOrgs.add(prodOrgQuery); 
        boolean userPresent = Core_IPS_Helper_Utility.getOrgAdminsByOrg(ProdOrgs);
        return userPresent;
    }
    @AuraEnabled(cacheable=false)
    public static ProductAndMapProdToSupProd searchProducts(String id, String searchTextProd,Integer limitSize, Integer offset){
        //  mapProdToSupProd = 
        prodIdList=new List<Id>();
        String searchTxt = '%'+searchTextProd+'%';
        
        String recId = id;     
        
        if(Core_IPS_Supported_Product__c.SObjectType.getDescribe().isAccessible()){          
            supProds = [select id,name, Core_Product__c, Core_Product_Organization__c,Core_Product__r.name, Core_Product__r.description, Core_Product__r.id,Core_Flag_Status__c,Core_Supported_Product_Name__c from Core_IPS_Supported_Product__c where Core_Product__r.name like :searchTxt and Core_Product_Organization__c = :recId and Core_EOIS__c = false and core_IPS_public_product__c = false LIMIT :limitSize OFFSET :offset /*limit 100*/];    
        }
        
        
        for(Core_IPS_Supported_Product__c sp:supProds){
            
            
            prodIdList.add(sp.Core_Product__r.id);
            
            
            if(!mapProdToSupProd.containsKey(sp.core_Product__r.id)){
                mapProdToSupProd.put(sp.core_Product__r.id,sp); //Core_IPS_Supported_Product__c mapProdToSupProd contains.
            }
            
        }
         // SOQL Injection Fix  - Start- Shipra
         Map<String, Object> bindMap = new Map<String, Object>{'prodIdList' =>prodIdList };
        
        String prodQuery='Select ';
        for(Schema.FieldSetMember f : SObjectType.Product2.FieldSets.Map_Prod_FieldSet.getFields()) {
            prodQuery += f.getFieldPath() + ', ';
        }
        prodQuery +=' id,name from Product2 where id in:prodIdList ORDER BY Product2.Name ASC NULLS LAST';
        prodList = Database.queryWithBinds(prodQuery,bindMap,AccessLevel.USER_MODE);
        // SOQL Injection Fix  - ENd - Shipra
        
        ProductAndMapProdToSupProd prodAndMap = new ProductAndMapProdToSupProd();
        prodAndMap.searchProducts = prodList;
        prodAndMap.mapProdToSupProd1 = mapProdToSupProd;
        
        return prodAndMap;
    }
    
     @AuraEnabled(cacheable=false)
    public static void getProductList(List<Product2> pageSelectedProductList){ 
        
        productList = new List<SelectedProduct>(); 
        if(pageSelectedProductList <> null){
            for(Product2 prod : pageSelectedProductList){
                
                SelectedProduct selProd = new SelectedProduct();
                selProd.selected=true;
                selProd.prod=prod;
                selProd.SupProduct = mapProdToSupProd.get(prod.id);
                selProd.selectedProductOrganization = prod.id;
                
                if(mapProdToSupProd.get(prod.id)!=null ){
                    selProd.relatedSupProduct = mapProdToSupProd.get(prod.id).Core_Supported_Product_Name__c ;
                }
                
                productList.add(selProd);
                
            }
        }
        
        
    }
    
    
     @AuraEnabled(cacheable=false)
    public static List<WrapLineItem> getLineItemsmethod(List<Account> accountsselected, List<Product2> prodselected, String prodOrgRecId, Map<Id,Core_IPS_Supported_Product__c> mapProdToSupProd1 ){
        
        
        
        
        
        getProductList(prodselected);
        
        prodOrg = new Core_IPS_Product_Organization__c();
        
        
        LineItemlist = new List<WrapLineItem>();   
        List<Core_IPS_Product_Organization__c> ProdOrgList = new List<Core_IPS_Product_Organization__c>();
        
        
        prodOrg = [select id,name,Core_IPS_Support_Org_Name__c,OwnerId from Core_IPS_Product_Organization__c where id = :prodOrgRecId];
        
        List<String> ProdOrgIds = new List<String>();
        
        
        for(SelectedProduct OrgIds: productList){
            ProdOrgIds.add(OrgIds.selectedProductOrganization);  //selectedProductOrganization contains Core_Product_Organization__c.id
        }
        
        
        ProdOrgList = [Select id,name,Core_IPS_Support_Org_Name__c from Core_IPS_Product_Organization__c where id IN:ProdOrgIds];
        
        
        
        Map<String,Core_IPS_Product_Organization__c> MapProdOrgNames =  new Map<String,Core_IPS_Product_Organization__c>();
        
        for(Core_IPS_Product_Organization__c ProdOrgs: ProdOrgList){
            
            MapProdOrgNames.put(ProdOrgs.id, ProdOrgs);          
        }
        
        List<Asset> assetlist= [select id,name,accountid,product2id,product2.name, account.name,Core_Product_Organization__c from asset where Status!='Inactive' and accountid IN: accountsselected and product2id IN: prodselected];        
        
        for(Account acc:accountsselected){
            for(SelectedProduct prod:productList){
                if(prod.selected){
                    WrapLineItem litem = new WrapLineItem();
                    litem.acc=acc;
                    litem.prod=prod.prod;
                    litem.SupProduct = prod.SupProduct;
                    litem.selected=true;
                    litem.prodOrgId = prodOrg.id;  //prod.selectedProductOrganization
                    litem.prodOrgName = prodOrg.Core_IPS_Support_Org_Name__c;
                    
                    litem.FlagStatus = mapProdToSupProd1.get(prod.prod.id).Core_Flag_Status__c;
                    for(Asset a: assetlist){                   
                        if(a.accountid==acc.id && a.product2id==prod.prod.id && a.Core_Product_Organization__c == prodOrg.id ){                        
                            litem.color='background-color:gold';
                        }           
                    }
                    //Start POC by OM - Taurus
                    
                    //   litem.supportTierList = supportTierList;
                    
                    //litem.enabledForSubscriptions = mapProdToSupProd1.get(prod.prod.id).IPS_Enabled_For_Subscriptions__c;
                    //End POC by OM - Taurus
                    LineItemlist.add(litem);   
                }
            }
        }   
        
        
        return LineItemlist;
    }   
    
    
    //create a new map;
    //--------------------------------------------------------------------------------------------------------------------------------------------------
     @AuraEnabled(cacheable=false)
    public static Core_IPS_MAP_PAR__c createMapNew(List<WrapLineItem> lineItemsList1, Map<Id,Core_IPS_Supported_Product__c> mapProdToSupProd2, String searchMapNameText, String prodOrgRecId){ //pass line items, pass maptosup map, MapNameText, prodorgid recid of page
        
        
        
        
        
        
        
            
            List<Account> selectedAccountList = new List<Account>();
            List<Core_IPS_Map_Par_Line_Item__c> mapLineItems = new List<Core_IPS_Map_Par_Line_Item__c>();
            List<Core_IPS_MAP_Account__c> coreMapAccToInsert = new List<Core_IPS_MAP_Account__c >();
            List<Core_IPS_MAP_Product__c> coreMapPrdToInsert = new List<Core_IPS_MAP_Product__c>();
            Set<Id> distinctProductIds = new Set<Id>();
            Set<ID> distinctAccountIds = new Set<ID>();
            
            map1 = new Core_IPS_MAP_PAR__c();
            
            
            map1.Core_Product_Organization__c = prodOrgRecId;
            
            map1.core_name__c = searchMapNameText;
            
            map1.RecordTypeId = schema.sobjecttype.Core_IPS_MAP_PAR__c.getrecordtypeinfosbyname().get('MAP').getRecordTypeId();
            
            map1.Core_Submitter_Comments__c=submitterComments;
            
            insert map1;
            
            for(WrapLineItem wl : lineItemsList1){
                if(wl.selected){
                    
                    Core_IPS_Map_Par_Line_Item__c lineItem = new Core_IPS_Map_Par_Line_Item__c();
				           
                    lineItem.Core_Account__c = wl.acc.id;
                    
                    lineItem.Core_Supported_Product__c=mapProdToSupProd2.get(wl.prod.id).id;  
                    
                    lineItem.Core_MAP_PAR__c = map1.id;
                    
                    lineItem.RecordTypeId = schema.sobjecttype.Core_IPS_Map_Par_Line_Item__c.getrecordtypeinfosbyname().get('MAP').getRecordTypeId();
                    
                    // 
                    //  
                    
                    // if(wl.selectedTier != null){
                    //        lineItem.Support_Tier__c = wl.selectedTier;    
                    // }
                    
                    // if(wl.subscriptionExpDate != null){
                    //         lineItem.Subscription_Expiration_Date__c = wl.subscriptionExpDate;
                    //  }
                    
                    mapLineItems.add(lineItem);
                    
                    distinctProductIds.add(wl.prod.id);
                    distinctAccountIds.add(wl.acc.id);
                }
            }
            
            
            
            
            
            for(Id prodId : distinctProductIds){
                Core_IPS_MAP_Product__c corePrd= new Core_IPS_MAP_Product__c();
                
                corePrd.Core_MAP_PAR__c = map1.id;
                
                corePrd.Core_MAP_Supported_Product__c = mapProdToSupProd2.get(prodid).id;
                
                coreMapPrdToInsert.add(corePrd); 
            }
            for(Id accId : distinctAccountIds){
                Core_IPS_MAP_Account__c mapAcc = new Core_IPS_MAP_Account__c();           
                mapAcc.Core_MAP_PAR__c = map1.id;
                mapAcc.Core_Account__c = accid;
                coreMapAccToInsert.add(mapAcc);
            }
            
            
            insert mapLineItems;
            Core_IPS_MAPAccount_Dispatcher.DontExecuteTrigger=true;
            insert coreMapAccToInsert;
            insert coreMapPrdToInsert;
            Core_IPS_MAPAccount_Dispatcher.DontExecuteTrigger=false;
            
            
            return map1;  
      
    }      
    
    
    // -------------------------------------------------------------------------------------------------------------------------------------------------------------  
    
    
    public class wrapAccount {
        @AuraEnabled
        public Account acc {get; set;}
        @AuraEnabled
        public Boolean selected {get; set;}
    }
    
    public class SelectedProduct{
        @AuraEnabled
        public boolean selected{get;set;}
        @AuraEnabled
        public product2 prod{set;get;}
        @AuraEnabled
        public String relatedSupProduct{get;set;}
        @AuraEnabled
        public String selectedProductOrganization{get;set;}
        @AuraEnabled
        public String supProdId{get;set;}
        @AuraEnabled
        public List<SelectOption> prodOrgs{get;set;}
        @AuraEnabled
        public Core_IPS_Supported_Product__c SupProduct{get;set;}
    }
    
    public class WrapLineItem{
        @AuraEnabled
        public boolean selected{get;set;}
        @AuraEnabled
        public product2 prod{set;get;}
        @AuraEnabled
        public Account acc {get; set;}
        @AuraEnabled
        public String color{get;set;}
        @AuraEnabled
        public String prodOrgId{get;set;}
        @AuraEnabled
        public String prodOrgName{get;set;}
        @AuraEnabled
        public String FlagStatus{get;set;}
        @AuraEnabled
        public Core_IPS_Supported_Product__c SupProduct{get;set;}
        
        
        //Start POC by OM - Taurus
        // @AuraEnabled
        // public List<SelectOption> supportTierList{get;set;}
        //  @AuraEnabled
        // public string selectedTier{get;set;}
        @AuraEnabled
        public  boolean enabledForSubscriptions{get;set;}
        // @AuraEnabled
        // public  Date subscriptionExpDate{get;Set;}
        //End POC by OM - Taurus
    }
    
    public class ProductAndMapProdToSupProd{
        @AuraEnabled
        public List<Product2> searchProducts{get;set;}
        @AuraEnabled
        public  Map<Id,Core_IPS_Supported_Product__c> mapProdToSupProd1{get;set;}
    }
    
}