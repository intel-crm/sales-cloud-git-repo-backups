public with sharing class Core_IPS_PARCreation_Controller_Lex {
    
    public static Map<String, Boolean> prodIdentifierToSubsMap = new Map<String, Boolean>();
    public static List<Id> prodIdList = new List<Id>();
    public static Map<Id,Core_IPS_Supported_Product__c> mapProdToSupProd = new Map<Id,Core_IPS_Supported_Product__c>();
    public static List<Product2> prodList;
    public static Map<Id, Set<CustomSelectOptions>> prodOrgsMap;
    public static Account acc;
    public static Account selectedacc;
    public static List<WrapLineItem> LineItemList;
    public static Set<Product2> pageSelectedProductList = new Set<Product2>();
    public static List<String> pageselectedOrg;
    public static List<Core_IPS_Product_Organization__c> ProdOrgList;
    public static Map<String,Core_IPS_Supported_Product__c> OrgbySupProd;
    public static List<Core_IPS_Supported_Product__c> selectedSupProds;
    public static Map<Id, Set<CustomSelectOptions>> selectedProdOrgsMap;
    public static List<String> pageselectedEPMId;
    
    @AuraEnabled(cacheable=true)
    public static String getAccount(String accId){
        Account accnt;
        if(Account.SObjectType.getDescribe().isAccessible()){
            accnt = [Select Id, Name From Account Where Id =: accId];
        }
        String AccName = accnt.Name;
        acc = accnt;
        selectedacc = accnt;
        return AccName;
    }
    @AuraEnabled
    public static CheckFAEWrapper checkAccounts(String accId){
        checkFAEWrapper wrapper = new CheckFAEWrapper();
        
        List<Account> accountRecordList = [SELECT Id, Name, Core_IPS_Active__c, OwnerId, Core_CNDA_Number__c FROM Account WHERE Id = :accId];
        if(accountRecordList.size()>0)
        {            
            List<String> UserIDPAR = new List<String>();
            UserIDPAR.add(UserInfo.getUserid());
            Boolean userpresent = Core_IPS_Helper_Utility.getFAEsofAccount(accountRecordList[0], UserIDPAR);
            if(userPresent == null) {
                userPresent = false;
            }
            wrapper.accountRecord = accountRecordList[0];
            wrapper.userPresent = userPresent;
        }
        return wrapper;
    }
    
    @AuraEnabled(cacheable=false)
    public static List<SelectedProduct> getSupportedProducts(String searchText, Integer limitSize, Integer offset) {
        
        List<SelectedProduct> productList  = new List<SelectedProduct>(); 
        List<Core_IPS_Supported_Product__c> supProds;
        prodIdList=new List<Id>();
        String text = '%'+ searchText +'%';
        if(Core_IPS_Supported_Product__c.SObjectType.getDescribe().isAccessible()){
            supProds = [select id,name, Core_Flag_Status__c,Core_Supported_Product_Name__c,Core_Product__c,core_Product__r.id ,Core_Product_Organization__c,Core_Product__r.Name,Core_Product_Organization__r.Core_IPS_Support_Org_Name__c, Core_Product_Organization__r.Core_Organization_Description__c,Core_Product_EPM_ID__c,Core_IPS_Code_Name__c,Core_Product_Application__c from Core_IPS_Supported_Product__c where Core_Flag_Status__c!='Par Hidden' and Core_EOIS__c = false and core_IPS_public_product__c = false and Core_Product__r.name like :text AND Core_Flag_Status__c != 'General (ALL Access!)' and Core_Product_EPM_ID__c <> null order by Core_Product__r.name LIMIT :limitSize OFFSET :offset];
        }
        for(Core_IPS_Supported_Product__c sp:supProds) {
            prodIdList.add(sp.Core_Product__r.id);
            if(!mapProdToSupProd.containsKey(sp.core_Product__r.id))
                mapProdToSupProd.put(sp.core_Product__r.id,sp);
        }
        // SOQL Injection Fix  - Start - Shipra
            Map<String, Object> bindMap = new Map<String, Object>{'prodIdList' =>prodIdList };   
        String prodQuery='Select ';
        for(Schema.FieldSetMember f : SObjectType.Product2.FieldSets.Map_Prod_FieldSet.getFields()) {
            prodQuery += f.getFieldPath() + ', ';
        }
        prodQuery +=' id,name from Product2 where id in:prodIdList ORDER BY Product2.Name ASC NULLS LAST ';
        prodList = Database.queryWithBinds(prodQuery,bindMap,AccessLevel.USER_MODE);
        // SOQL Injection Fix  - ENd - Shipra
        
        
        if(prodOrgsMap==null)
            prodOrgsMap = new Map<Id, Set<CustomSelectOptions>>();
        for(integer i=0;i<supProds.size();){
            Set<CustomSelectOptions> selOptList = new Set<CustomSelectOptions>();
            if(supProds[i].Core_Product_Organization__c!=null)
                selOptList.add(new CustomSelectOptions(supProds[i].Core_Product_Organization__r.id,supProds[i].Core_Product_Organization__r.Core_Organization_Description__c));
            integer j = i+1;
            for(;j<supProds.size();j++){
                if(supProds[i].Core_Product__r.id==supProds[j].Core_Product__r.id){
                    selOptList.add(new CustomSelectOptions(supProds[j].Core_Product_Organization__r.id,supProds[j].Core_Product_Organization__r.Core_Organization_Description__c));
                    continue;
                }
                break;
            }
            if(!prodOrgsMap.containsKey(supProds[i].Core_Product__r.id))
                prodOrgsMap.put(supProds[i].Core_Product__r.id,selOptList);
            i=j;
            
        }
        if(prodlist!=null){
            for(product2 prod:prodlist){
                
                if(!pageSelectedProductList.contains(prod)){
                    SelectedProduct selProd = new SelectedProduct();
                    selProd.prod=prod;
                    selProd.selectedProductOrganization = mapProdToSupProd.get(prod.id).Core_Product_Organization__c;
                    selProd.relatedSupProduct = mapProdToSupProd.get(prod.id).Core_Supported_Product_Name__c;
                    selProd.SupProduct = mapProdToSupProd.get(prod.id);
                    selProd.ProductEPMId = mapProdToSupProd.get(prod.id).Core_Product_EPM_ID__c;
                    if( prodOrgsMap!=null){
                        Set<CustomSelectOptions> prodOrgsSet = new Set<CustomSelectOptions>();
                        prodOrgsSet= prodOrgsMap.get(prod.id);
                        List<CustomSelectOptions> progOrgsList = new List<CustomSelectOptions>();
                        if(prodOrgsSet!=null)
                            progOrgsList.addAll(prodOrgsSet);
                        if(progOrgsList.size() == 1){
                            selProd.ProductOrgOneSize=true;                                
                        }
                        else{
                            selProd.ProductOrgOneSize=false;
                        }
                        selProd.prodOrgs = progOrgsList;
                    }
                    productList.add(selProd);
                }
            }
        }
        
        
        return productList;
    }
    
    @AuraEnabled(cacheable=false)
    public static List<Asset> getProducts(String accountId, String productIds) {
        List<Asset> assetsList;
        List<String> productIdsList = (List<String>)JSON.deserialize(productIds, List<String>.class);
        if(Asset.SObjectType.getDescribe().isAccessible()){
            assetsList = [SELECT Core_Supported_Product__c FROM Asset WHERE Status != 'Inactive' and AccountId = :accountId AND Product2Id IN :productIdsList];
        }
        return assetsList;
        
    }
    @AuraEnabled(cacheable=false)
    public static void pushProducts(List<WrapLineItem> productsToAdd, String accountId, String submitterCommentsText){
        Set<Id> distinctProductOrgIds = new Set<Id>();
        Set<Id> distinctProductIds = new Set<Id>();
        Set<String> distinctOrgEPMIds = new Set<String>();
        Set<ID> distinctAccountIds = new Set<ID>();
        Core_IPS_MAP_PAR__c map2;
        Map<Id,ID> mapIdbyPO = new Map<ID,ID>();
        List<Core_IPS_Map_Par_Line_Item__c> lineItems=new List<Core_IPS_Map_Par_Line_Item__c>();
        List<Core_IPS_MAP_Account__c> coreMapAccToInsert = new List<Core_IPS_MAP_Account__c >();
        List<Core_IPS_MAP_Product__c> coreMapPrdToInsert = new List<Core_IPS_MAP_Product__c>();
        Map<ID,List<WrapLineItem>> orgItWithLineItems = new Map<ID,List<WrapLineItem>>();
        OrgbySupProd =  new Map<String,Core_IPS_Supported_Product__c>();
        
        for(WrapLineItem wl : productsToAdd){
            if(!orgItWithLineItems.containsKey(wl.prodOrgId)){
                List<WrapLineItem> lwi = new List<WrapLineItem>();
                lwi.add(wl);
                orgItWithLineItems.put(wl.SupProduct.Core_Product_Organization__r.Id,lwi);
            }
            else{
                orgItWithLineItems.get(wl.SupProduct.Core_Product_Organization__r.Id).add(wl);
            }
            distinctProductOrgIds.add(wl.prodOrgId);
            OrgbySupProd.put((wl.SupProduct.id+wl.UniqueOrgEPMId),wl.SupProduct);
        }
        List<Core_IPS_MAP_PAR__c> mapParListObj = new List<Core_IPS_MAP_PAR__c>();
        for(Id orgId : orgItWithLineItems.KeySet()){
            map2 = new Core_IPS_MAP_PAR__c();
            map2.Core_Product_Organization__c= orgId;
            map2.Core_isPARRequest__c= true;
            map2.RecordTypeId = schema.sobjecttype.Core_IPS_MAP_PAR__c.getrecordtypeinfosbyname().get('PAR').getRecordTypeId(); 
            map2.Core_Submitter_Comments__c=submitterCommentsText;
            
            mapParListObj.add(map2);
        }
        // Performing a single insert outside the loop
        if (!mapParListObj.isEmpty()) {
            insert mapParListObj;

            // populating the mapIdbyPO after the insert
            for (Integer i = 0; i < mapParListObj.size(); i++) {
                mapIdbyPO.put(mapParListObj[i].Core_Product_Organization__c, mapParListObj[i].Id);
            }
        }     
        for(Id orgId : orgItWithLineItems.KeySet()){
            distinctProductIds = new Set<Id>();
            distinctOrgEPMIds = new Set<String>();
            distinctAccountIds = new Set<Id>();
            for(WrapLineItem wl : orgItWithLineItems.get(orgId)){
                Core_IPS_Map_Par_Line_Item__c lineItem = new Core_IPS_Map_Par_Line_Item__c();
                lineItem.Core_Account__c = accountId;
                lineItem.Core_isPARRequest__c=true; 
                lineItem.Core_Approval_Type__c= wl.SupProduct.Core_Flag_Status__c;
                lineItem.Core_Supported_Product__c = wl.SupProduct.id;
                if(wl.SupProduct.Core_Flag_Status__c == 'Auto Approve'){
                    lineItem.Core_Status__c='ACTIVE';
                }else{
                    lineItem.Core_Status__c='PENDING';
                }
                lineItem.Core_MAP_PAR__c = mapIdbyPO.get(orgId);
                lineItem.Core_Submitter_Comments__c=submitterCommentsText;
                lineItem.RecordTypeId = schema.sobjecttype.Core_IPS_Map_Par_Line_Item__c.getrecordtypeinfosbyname().get('PAR').getRecordTypeId();
                lineItems.add(lineItem);
                distinctOrgEPMIds.add(wl.SupProduct.id+wl.UniqueOrgEPMId);
                distinctAccountIds.add(accountId);
            }
            for(String OrgEPMId : distinctOrgEPMIds){
                Core_IPS_MAP_Product__c corePrd= new Core_IPS_MAP_Product__c();
                corePrd.Core_MAP_PAR__c = mapIdbyPO.get(orgId);               
                corePrd.Core_MAP_Supported_Product__c = OrgbySupProd.get(OrgEPMId).id;
                coreMapPrdToInsert.add(corePrd); 
                
            }
            Core_IPS_MAP_Account__c mapAcc = new Core_IPS_MAP_Account__c();
            mapAcc.Core_MAP_PAR__c = mapIdbyPO.get(orgId);
            mapAcc.Core_Account__c = accountId;
            coreMapAccToInsert.add(mapAcc);
            
        }
        if(lineItems <> null && lineItems.size()>0){
            Core_IPS_AdminUtility.insertLineItems(lineItems);
        }
        Core_IPS_MAPAccount_Dispatcher.DontExecuteTrigger=true;
        Core_IPS_AdminUtility.insertProdAccessAccJOs(coreMapAccToInsert);
        if(!Test.isRunningTest())
            Core_IPS_AdminUtility.insertProdAccessProdJOs(coreMapPrdToInsert);
        Core_IPS_MAPAccount_Dispatcher.DontExecuteTrigger=false;
        
    }
    @AuraEnabled(cacheable=false)
    public static List<WrapLineItem> getLineItemsmethod(List<SelectedProduct> productList){
        LineItemList = new List<WrapLineItem>();
        List<Product2> prodselected = new List<Product2>();
        if(productList!=null && productList.size()>0)
        {
            for(SelectedProduct selectedProd:productList){
                
                prodselected.add(selectedProd.prod);
                
            }
        }   
        List<String> ProdOrgIds = new List<String>();
        List<String> ProductEPMIds = new List<String>();
        List<String> UnqOrgEPMId= new List<String>();
        Map<String,String> EPMIdsbyOrg = new Map<String,String>();
        for(SelectedProduct prodWrapper: productList){
            
            ProdOrgIds.add(prodWrapper.selectedProductOrganization);
            ProductEPMIds.add(prodWrapper.ProductEPMId);
            UnqOrgEPMId.add(prodWrapper.selectedProductOrganization+prodWrapper.ProductEPMId);
            
            
            
        }
        if(Core_IPS_Product_Organization__c.SObjectType.getDescribe().isAccessible()){
            ProdOrgList = [Select id,name,Core_IPS_Support_Org_Name__c,Core_Organization_Description__c,(Select id, name,Core_Supported_Product_Name__c, Core_Product_Organization__r.id,Core_Product_EPM_ID__c,Core_Flag_Status__c from Supported_Products__r where Core_Product_EPM_ID__c IN: ProductEPMIds) from Core_IPS_Product_Organization__c where id IN:ProdOrgIds];
        }
        Map<String,Core_IPS_Product_Organization__c> MapProdOrgNames =  new Map<String,Core_IPS_Product_Organization__c>();
        OrgbySupProd =  new Map<String,Core_IPS_Supported_Product__c>();
        
        for(Core_IPS_Product_Organization__c ProdOrgs: ProdOrgList){
            MapProdOrgNames.put(ProdOrgs.id,ProdOrgs);
            for(Core_IPS_Supported_Product__c SupProd: ProdOrgs.Supported_Products__r){                
                OrgbySupProd.put((SupProd.Core_Product_Organization__r.id+SupProd.Core_Product_EPM_ID__c),SupProd);
            }
        }
        
        List<Asset> assetlist=new List<Asset>();
        
        for(SelectedProduct prod: productList){                             
            WrapLineItem litem = new WrapLineItem();
            litem.acc=selectedAcc;
            litem.prod=prod.prod;                
            litem.prodEPMId = prod.ProductEPMId;
            litem.UniqueOrgEPMId = (prod.selectedProductOrganization+prod.ProductEPMId);
            litem.SupProduct = OrgbySupProd.get((prod.selectedProductOrganization+prod.ProductEPMId));
            litem.selected=true;
            litem.prodOrgId = prod.selectedProductOrganization;
            litem.prodOrgName = MapProdOrgNames.get(prod.selectedProductOrganization).Core_IPS_Support_Org_Name__c;
            litem.prodOrgDescription = MapProdOrgNames.get(prod.selectedProductOrganization).Core_Organization_Description__c;
            litem.FlagStatus = OrgbySupProd.get((prod.selectedProductOrganization+prod.ProductEPMId)).Core_Flag_Status__c;   
            LineItemlist.add(litem);  
            
        }
        
        if(LineItemlist.size()>0){
            
            return LineItemList;
        }    
        return null;
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
        public Boolean colorvalue{get;set;}
        @AuraEnabled
        public String prodOrgName{get;set;}
        @AuraEnabled
        public String prodEPMId{get;set;}
        @AuraEnabled
        public String UniqueOrgEPMId{get;set;}
        @AuraEnabled
        public String prodOrgDescription{get;set;}
        @AuraEnabled
        public String FlagStatus{get;set;}
        @AuraEnabled
        public Core_IPS_Supported_Product__c SupProduct{get;set;}
    }
    
    public class SelectedProduct{
        // public boolean selected{get;set;}
        @AuraEnabled
        public product2 prod{set;get;}
        @AuraEnabled
        public String relatedSupProduct{get;set;}
        @AuraEnabled
        public String selectedProductOrganization{get;set;}
        @AuraEnabled
        public String ProductEPMId{get;set;}
        @AuraEnabled
        public String UniqueOrgEPMId{get;set;}
        @AuraEnabled
        public String supProdId{get;set;}
        @AuraEnabled
        public List<CustomSelectOptions> prodOrgs{get;set;}
        @AuraEnabled
        public boolean productOrgoneSize{get;set;}
        // public string color{get;set;}
        @AuraEnabled
        public Core_IPS_Supported_Product__c SupProduct{get;set;}
    }
    public class CustomSelectOptions{
        @AuraEnabled public String label {get;set;}
        @AuraEnabled public String value {get;set;}
        
        public CustomSelectOptions() {
            this.label = '';
            this.value = '';
        }
        
        public CustomSelectOptions(String lab, String val) {
            this.label = lab;
            this.value = val;
        }
    }
    public class CheckFAEWrapper {
        @AuraEnabled public Account accountRecord;
        @AuraEnabled public Boolean userPresent; 
    }
    
}