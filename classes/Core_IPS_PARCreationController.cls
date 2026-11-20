/******************************************************
*Class Name:  Core_IPS_PARCreationController
*Version     : 1.0 
*Description:  Controller for Core_IPS_Create_PAR Page
*Modification Log :
* Developer                   Date                        Description
* ----------------------------------------------------------------------------                 
* Sugandha                    16/11/2017                  Modified (Iteration#-2 User story#-US72182)
******************************************************/
public with sharing class Core_IPS_PARCreationController{
    public Account selectedAcc{get;set;}
    Public Integer size{get;set;} 
    public List<SelectOption> paginationSizeOptions{get;set;}
    public boolean productListvalue{get;set;}
    public boolean lineItemListvalue{get;set;}
    public boolean Listsizeone{get;set;}
    public boolean ListSizeNOTone{get;set;}
    public Integer noOfpRecords{get;set;}
    public boolean Userpresent{get;set;}
    public boolean IPSActiveAccount{get;set;}
    public Set<Account> selectedAccounts{get;set;}
    public boolean showProductFlag{get;set;}
    public boolean showAccountFlag{get;set;}
    public boolean showLineItemFlag{get;set;}
    public Core_IPS_MAP_PAR__c reqField{get;set;}
    public Core_IPS_Map_Par_Line_Item__c reqField1{get;set;}
    public Core_IPS_Map_Par_Line_Item__c submitterCommentsfield{get;set;}
    public String mapName{get;set;}
    public String submitterComments{get;set;}
    public String submitterComments1{get;set;}
    public transient String searchText{get;set;}
    public String selectedOrg{get;set;}
    public String accname{get;set;}
    public String engagementType{get;set;}
    public Core_IPS_Product_Organization__c prodOrg{get;set;}
    public Account acc{get;set;}
    public String searchTextProd{get;set;}
    public List<SelectedProduct> productList;
    public List<WrapLineItem> LineItemlist{get;set;}
    public Core_IPS_MAP_PAR__c map1;
    public Core_IPS_MAP_PAR__c map2;
    public List<String> selectengagementType {get;set;}
    public String searchTxt;
    public String AccountListQuery;
    public List<Contact> conList;
    public List<SelectOption> productTypes{get;set;}
    public List<SelectOption>OrgTypes{get;set;}
    //public Boolean flag{get;set;}
    public Boolean searchstart{get;set;} // used to show the no search results found value
    public string submitterCommentsText{get;set;}
    public boolean disablebutton{get;set;}
    
    public Core_IPS_PARCreationController(ApexPages.StandardController controller) {
        reqField = new Core_IPS_MAP_PAR__c();
        reqField1 = new Core_IPS_Map_Par_Line_Item__c();
        submitterCommentsfield = new Core_IPS_Map_Par_Line_Item__c();
        showAccountFlag=true;
        showLineItemFlag=false;
        productListvalue = true;
        lineItemListvalue=false;
        Listsizeone=false;
        ListSizeNOTone=false;
        IPSActiveAccount = false;
        selectedAccounts = new Set<Account>();
        paginationSizeOptions = new List<SelectOption>();
        if(mapProdToSupProd == null)
        mapProdToSupProd = new Map<Id,Core_IPS_Supported_Product__c>();
        if(ApexPages.currentPage().getParameters().get('eType')!=null)
            engagementType = ApexPages.currentPage().getParameters().get('eType');
        else
            engagementType ='Par';
        
        if(engagementType == 'Par'){
            showAccountFlag = false;
            showProductFlag = true;
            selectedAcc = (Account)controller.getRecord();
        }
        
        String userId = UserInfo.getUserId();
            if(ApexPages.currentPage().getParameters().get('orgid')!=null){
                //Fix already applied
		prodOrg = new Core_IPS_Product_Organization__c();
                if(Core_IPS_Product_Organization__c.SObjectType.getDescribe().isAccessible()){
                prodOrg = [select id,name from Core_IPS_Product_Organization__c where id = :ApexPages.currentPage().getParameters().get('orgid')];
                }
                selectedOrg= prodOrg.name;
                }
            if(ApexPages.currentPage().getParameters().get('id')!=null){
	    	acc = new Account();
                if(Account.SObjectType.getDescribe().isAccessible()){
                acc = [select id,name,Core_IPS_Active__c,ownerId from Account where id = :ApexPages.currentPage().getParameters().get('id')];
                }
                accname= acc.name;
                if(acc.Core_IPS_Active__c){
                    IPSActiveAccount = true;
                }
                
            }
            
        /*Code for vf page validation*/
            
        List<String> UserIDPAR = new List<String>();
        UserIDPAR.add(UserInfo.getUserid());
        Userpresent = Core_IPS_Helper_Utility.getFAEsofAccount(acc,UserIDPAR);
        
        LineItemlist = new List<WrapLineItem>();
        productList = new List<SelectedProduct>();
        //wrapAccountList = new List<wrapAccount>();    
        pageSelectedProductList = new Set<Product2>();
        pageselectedOrg = new List<String>();
        pageselectedEPMId = new List<String>();

        size = integer.valueof(System.Label.Core_PAR_Page_Size.split(';')[0]);
        List<String> listofPageSizes = System.Label.Core_PAR_Page_Size.split(';');
        for(String s : listofPageSizes){
            paginationSizeOptions.add(new SelectOption(s,s));
        }
    }

    
    public void prodFirstPage(){
        processSelectedProducts();
        standardSetproduct.first();
    }
    
    public void prodNextPage(){
        processSelectedProducts();
        standardSetproduct.next();
    }
    public void prodPrevPage(){
        processSelectedProducts();
        standardSetproduct.previous();
    }
    
    public void prodLastPage(){
        processSelectedProducts();
        standardSetproduct.last();
    }
    
    
   public Set<Product2> pageSelectedProductList;
   public List<String> pageselectedOrg;
   public List<String> pageselectedEPMId;
   public Void processSelectedProducts(){
       for(SelectedProduct selProd : productList){
            if(selProd.selected == true) {
                pageSelectedProductList.add(selProd.prod);
                pageselectedOrg.add(selProd.selectedProductOrganization);
                pageselectedEPMId.add((selProd.selectedProductOrganization.substring(0,15)+selProd.ProductEPMId));
            }
            else{
                if(pageSelectedProductList.contains(selProd.prod))
                   pageSelectedProductList.remove(selProd.prod);
                }
        }
   }
  
    
    
    //Changes the size of pagination
    public PageReference refreshPageSize() {
        processSelectedProducts();
         standardSetproduct.setPageSize(size);
         return null;
    } 
    
    public ApexPages.StandardSetController standardSetproduct{
        get {
            if(standardSetproduct  == null && prodList!=null){
                standardSetproduct = new ApexPages.StandardSetController(prodList);
                standardSetproduct.setPageSize(5);
                standardSetproduct.setPageSize(size);
                noOfpRecords = standardSetproduct.getResultSize();               
            }
            return standardSetproduct;
        }
        set;
    } 
    
            
    public List<Product2> prodList;  
    public List<Id> prodIdList = new List<Id>();
    public List<Core_IPS_Supported_Product__c> supProds;
    public List<Core_IPS_Supported_Product__c> selectedSupProds;
    public List<id> eProdIdList= new List<Id>();
    public Map<Id, Set<SelectOption>> prodOrgsMap;
    public Map<Id, Set<SelectOption>> selectedProdOrgsMap;  
    public Map<Id,Core_IPS_Supported_Product__c> mapProdToSupProd;
    
    public void searchProducts(){
        if(pageSelectedProductList!=null)
        processSelectedProducts();
        prodIdList=new List<Id>();
        String searchTxt = '%'+searchTextProd+'%';
        if(engagementType =='Map'){
            //Iteration#-2 User story#-US72182 DeveloperName-Sugandha Description- added where clouse condition core_IPS_public_product__c = false
            if(Core_IPS_Supported_Product__c.SObjectType.getDescribe().isAccessible()){
            supProds = [select id,name, Core_Product__c,Core_Product_Organization__c,Core_Product__r.name, Core_Product__r.description, Core_Product__r.id,Core_Flag_Status__c,Core_Supported_Product_Name__c, Core_Product_EPM_ID__c  from Core_IPS_Supported_Product__c where Core_Product__r.name like :searchTxt and Core_Product_Organization__c = :prodOrg.id and Core_EOIS__c = false and core_IPS_public_product__c = false  /*limit 100*/]; 
            }
        } else 
            //Iteration#-2 User story#-US72182 DeveloperName-Sugandha Description- added where clouse condition core_IPS_public_product__c = false
            supProds = [select id,name, Core_Product__c, Core_Product_Organization__c,Core_Product_Organization__r.id, Core_Product_Organization__r.Core_IPS_Support_Org_Name__c, Core_Product_Organization__r.Core_Organization_Description__c, Core_Product_EPM_ID__c, Core_Product__r.name, Core_Product__r.description, Core_Product__r.id,Core_Flag_Status__c,Core_Supported_Product_Name__c from Core_IPS_Supported_Product__c where Core_Flag_Status__c!='Par Hidden' and Core_EOIS__c = false and core_IPS_public_product__c = false and Core_Product__r.name like :searchTxt and Core_Product_EPM_ID__c <> null order by Core_Product__r.name  /*limit 100*/]; 
            for(Core_IPS_Supported_Product__c sp:supProds){
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
            prodQuery +=' id,name from Product2 where id in:prodIdList ORDER BY Product2.Name ASC NULLS LAST';
            prodList = Database.queryWithBinds(prodQuery,bindMap,AccessLevel.USER_MODE);
            // SOQL Injection Fix  - ENd - Shipra
        
            
        if(engagementType =='Par'){
            if(prodOrgsMap==null)
                prodOrgsMap = new Map<Id, Set<SelectOption>>();
            for(integer i=0;i<supProds.size();){
                Set<SelectOption> selOptList = new Set<SelectOption>();
                if(supProds[i].Core_Product_Organization__c!=null)
                selOptList.add(new SelectOption(supProds[i].Core_Product_Organization__r.id,supProds[i].Core_Product_Organization__r.Core_Organization_Description__c));
                integer j = i+1;
                for(;j<supProds.size();j++){
                    if(supProds[i].Core_Product__r.id==supProds[j].Core_Product__r.id){
                        selOptList.add(new SelectOption(supProds[j].Core_Product_Organization__r.id,supProds[j].Core_Product_Organization__r.Core_Organization_Description__c));
                        continue;
                    }
                    break;
               }
               if(!prodOrgsMap.containsKey(supProds[i].Core_Product__r.id))
               prodOrgsMap.put(supProds[i].Core_Product__r.id,selOptList);
               i=j;
              
            }
        }
               
   standardSetproduct=null;
   searchstart = true; 
   }
   
    public List<SelectedProduct> getProductList()
    {  
        productList = new List<SelectedProduct>();     
        if(pageSelectedProductList!=null){
            selectedSupProds = [select id,name, Core_Product__c, Core_Product_Organization__c,Core_Product_Organization__r.id, Core_Product_Organization__r.Core_IPS_Support_Org_Name__c, Core_Product_Organization__r.Core_Organization_Description__c, Core_Product_EPM_ID__c, Core_Product__r.name, Core_Product__r.description, Core_Product__r.id,Core_Flag_Status__c,Core_Supported_Product_Name__c from Core_IPS_Supported_Product__c where Core_Flag_Status__c!='Par Hidden' and Core_EOIS__c = false and Core_Product__c IN: pageSelectedProductList and Core_Product_Organization__c IN: pageselectedOrg and Core_Unique_Supported_Product__c IN: pageselectedEPMId];             
            if(selectedSupProds <> null){
                selectedProdOrgsMap = new Map<Id, Set<SelectOption>>();
                for(integer i=0;i<selectedSupProds.size();){
                    Set<SelectOption> selOptList = new Set<SelectOption>();
                    if(selectedSupProds[i].Core_Product_Organization__c!=null)
                    selOptList.add(new SelectOption(selectedSupProds[i].Core_Product_Organization__r.id,selectedSupProds[i].Core_Product_Organization__r.Core_Organization_Description__c));
                    integer j = i+1;
                    for(;j<selectedSupProds.size();j++){
                        if(selectedSupProds[i].Core_Product__r.id==selectedSupProds[j].Core_Product__r.id){
                            selOptList.add(new SelectOption(selectedSupProds[j].Core_Product_Organization__r.id,selectedSupProds[j].Core_Product_Organization__r.Core_Organization_Description__c));
                            continue;
                        }
                        break;
                   }
                   if(!selectedProdOrgsMap.containsKey(selectedSupProds[i].Core_Product__r.id))
                   selectedProdOrgsMap.put(selectedSupProds[i].Core_Product__r.id,selOptList);
                   i=j;
                  
                }
            }
            for(Product2 prod : pageSelectedProductList){
                SelectedProduct selProd = new SelectedProduct();
                    selProd.selected=true;
                    selProd.prod=prod;
                    selProd.SupProduct = mapProdToSupProd.get(prod.id);                
                    selProd.relatedSupProduct = mapProdToSupProd.get(prod.id).Core_Supported_Product_Name__c ;
                    selProd.ProductEPMId = mapProdToSupProd.get(prod.id).Core_Product_EPM_ID__c;
                    if(engagementType =='Par' && selectedProdOrgsMap != null){
                        Set<SelectOption> prodOrgsSet = new Set<SelectOption>();
                        prodOrgsSet= selectedProdOrgsMap.get(prod.id);
                        List<SelectOption> progOrgsList = new List<SelectOption>();
                        if(prodOrgsSet!=null)
                        progOrgsList.addAll(prodOrgsSet);
                            if(progOrgsList.size() == 1){
                                selProd.ProductOrgOneSize=true; 
                            }
                            else{
                                selProd.ProductOrgOneSize=false;
                                selProd.color='background-color: #F3D54E;font-weight:bold'; 
                            }                               
                        selProd.prodOrgs = progOrgsList;
                    }   
                productList.add(selProd);
            }
        }
        if(standardSetproduct!=null){
            for(product2 prod:(List<product2>)standardSetproduct.getRecords()){
                if(!pageSelectedProductList.contains(prod)){
                    SelectedProduct selProd = new SelectedProduct();
                    selProd.selected=false;
                    selProd.prod=prod;
                    selProd.relatedSupProduct = mapProdToSupProd.get(prod.id).Core_Supported_Product_Name__c;
                    selProd.SupProduct = mapProdToSupProd.get(prod.id);
                    selProd.ProductEPMId = mapProdToSupProd.get(prod.id).Core_Product_EPM_ID__c;
                    if(engagementType =='Par' && prodOrgsMap!=null){
                        Set<SelectOption> prodOrgsSet = new Set<SelectOption>();
                        prodOrgsSet= prodOrgsMap.get(prod.id);
                        List<SelectOption> progOrgsList = new List<SelectOption>();
                        if(prodOrgsSet!=null)
                        progOrgsList.addAll(prodOrgsSet);
                        if(progOrgsList.size() == 1){
                            selProd.ProductOrgOneSize=true;                                
                        }
                        else{
                            selProd.ProductOrgOneSize=false;
                            selProd.color='background-color: #F3D54E; font-weight:bold';
                        }
                        selProd.prodOrgs = progOrgsList;
                    }   
                productList.add(selProd);
                }
            }
        }

        if(productList.size()>0){
            productListvalue=true;
            disablebutton = false;
            return productList;
        }else{
            disablebutton = true;
            if(searchstart == true) 
            productListvalue=false;
            return null;
        }
        
       
       
    }
          
    public PageReference createParRequest_New(){
    
        // Added by Sumukh as per US61023
        if((!String.isBlank(submitterCommentsText) && submitterCommentsText.containsIgnoreCase(System.Label.Core_IPS_PAR_SubmitterComments_Required) ) || String.isBlank(submitterCommentsText) ){
          ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,System.Label.Core_IPS_PAR_SubmitterComments_Validation_Error);
            ApexPages.addMessage(myMsg);
            return null;
        }// END
        else
        {
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
        for(WrapLineItem wl : LineItemlist){
            if(wl.selected){
                if(!orgItWithLineItems.containsKey(wl.prodOrgId)){
                    List<WrapLineItem> lwi = new List<WrapLineItem>();
                    lwi.add(wl);
                    orgItWithLineItems.put(wl.prodOrgId,lwi);
                }
                else{
                    orgItWithLineItems.get(wl.prodOrgId).add(wl);
                }
                distinctProductOrgIds.add(wl.prodOrgId);
            }
        }
        List<Core_IPS_MAP_PAR__c> mapParListObj = new List<Core_IPS_MAP_PAR__c>();
        for(Id orgId : orgItWithLineItems.KeySet()){
            map2 = new Core_IPS_MAP_PAR__c();
            /*US1021249 - 05/27/2021 - yamini - FLS Check for security vulnerability --*/
            if (Schema.sObjectType.Core_IPS_MAP_PAR__c.fields.Core_Product_Organization__c.isCreateable()) {
            map2.Core_Product_Organization__c= orgId;
            }
            if (Schema.sObjectType.Core_IPS_MAP_PAR__c.fields.Core_isPARRequest__c.isCreateable()) {
            map2.Core_isPARRequest__c= true;
            }
            if (Schema.sObjectType.Core_IPS_MAP_PAR__c.fields.Core_Name__c.isCreateable()) {
            map2.Core_Name__c = mapName;
            }
            if (Schema.sObjectType.Core_IPS_MAP_PAR__c.fields.RecordTypeId.isCreateable()) {
            map2.RecordTypeId = schema.sobjecttype.Core_IPS_MAP_PAR__c.getrecordtypeinfosbyname().get('PAR').getRecordTypeId(); 
            }
            if (Schema.sObjectType.Core_IPS_MAP_PAR__c.fields.Core_Submitter_Comments__c.isCreateable()) {
            map2.Core_Submitter_Comments__c=submitterCommentsText;
            }
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
                if (Schema.sObjectType.Core_IPS_Map_Par_Line_Item__c.fields.Core_Account__c.isCreateable()) {
                lineItem.Core_Account__c = wl.acc.id;
                }
                if (Schema.sObjectType.Core_IPS_Map_Par_Line_Item__c.fields.Core_isPARRequest__c.isCreateable()) {
                lineItem.Core_isPARRequest__c=true;    
                }
                if (Schema.sObjectType.Core_IPS_Map_Par_Line_Item__c.fields.Core_Approval_Type__c.isCreateable()) {            
                lineItem.Core_Approval_Type__c= OrgbySupProd.get(wl.UniqueOrgEPMId).Core_Flag_Status__c;
                }
                if (Schema.sObjectType.Core_IPS_Map_Par_Line_Item__c.fields.Core_Supported_Product__c.isCreateable()) {
                lineItem.Core_Supported_Product__c=OrgbySupProd.get(wl.UniqueOrgEPMId).id;
                }
                if(OrgbySupProd.get(wl.UniqueOrgEPMId).Core_Flag_Status__c == 'Auto Approve'){
                    if (Schema.sObjectType.Core_IPS_Map_Par_Line_Item__c.fields.Core_Status__c.isCreateable()) {
                    lineItem.Core_Status__c='ACTIVE';
                    }
                }else{
                    if (Schema.sObjectType.Core_IPS_Map_Par_Line_Item__c.fields.Core_Status__c.isCreateable()) {
                    lineItem.Core_Status__c='PENDING';
                    }
                }
                if (Schema.sObjectType.Core_IPS_Map_Par_Line_Item__c.fields.Core_MAP_PAR__c.isCreateable()) {
                lineItem.Core_MAP_PAR__c = mapIdbyPO.get(orgId);
                }
                if (Schema.sObjectType.Core_IPS_Map_Par_Line_Item__c.fields.Core_Submitter_Comments__c.isCreateable()) {
                lineItem.Core_Submitter_Comments__c=submitterCommentsText;
                }
                if (Schema.sObjectType.Core_IPS_Map_Par_Line_Item__c.fields.RecordTypeId.isCreateable()) {
                lineItem.RecordTypeId = schema.sobjecttype.Core_IPS_Map_Par_Line_Item__c.getrecordtypeinfosbyname().get('PAR').getRecordTypeId();                
                }
                lineItems.add(lineItem);
                distinctOrgEPMIds.add(wl.UniqueOrgEPMId);
                distinctAccountIds.add(wl.acc.id);
            }
            for(String OrgEPMId : distinctOrgEPMIds){
                Core_IPS_MAP_Product__c corePrd= new Core_IPS_MAP_Product__c();
                if (Schema.sObjectType.Core_IPS_MAP_Product__c.fields.Core_MAP_PAR__c.isCreateable()) {
                corePrd.Core_MAP_PAR__c = mapIdbyPO.get(orgId);  
                }
                if (Schema.sObjectType.Core_IPS_MAP_Product__c.fields.Core_MAP_Supported_Product__c.isCreateable()) {             
                corePrd.Core_MAP_Supported_Product__c = OrgbySupProd.get(OrgEPMId).id;
                }
                coreMapPrdToInsert.add(corePrd); 
            }
                Core_IPS_MAP_Account__c mapAcc = new Core_IPS_MAP_Account__c();
                if (Schema.sObjectType.Core_IPS_MAP_Account__c.fields.Core_MAP_PAR__c.isCreateable()) {
                mapAcc.Core_MAP_PAR__c = mapIdbyPO.get(orgId);
                }
                if (Schema.sObjectType.Core_IPS_MAP_Account__c.fields.Core_Account__c.isCreateable()) {
                mapAcc.Core_Account__c = selectedAcc.id;
                }
                coreMapAccToInsert.add(mapAcc);
            
        }
            if(lineItems <> null && lineItems.size()>0){
        		Core_IPS_AdminUtility.insertLineItems(lineItems);
            }
        Core_IPS_MAPAccount_Dispatcher.DontExecuteTrigger=true;
            Core_IPS_AdminUtility.insertProdAccessAccJOs(coreMapAccToInsert);
            Core_IPS_AdminUtility.insertProdAccessProdJOs(coreMapPrdToInsert);
        Core_IPS_MAPAccount_Dispatcher.DontExecuteTrigger=false;
        return new Pagereference('/'+acc.id);
        // return null;
    }
    }
    
    public Map<String,Core_IPS_Supported_Product__c> OrgbySupProd;
    List<Core_IPS_Product_Organization__c> ProdOrgList = new List<Core_IPS_Product_Organization__c>();
    public List<WrapLineItem> getLineItemsmethod(){
        LineItemlist = new List<WrapLineItem>();
                
        List<Product2> prodselected = new List<Product2>();
        if(productList!=null && productList.size()>0)
        {
            for(SelectedProduct selectedProd:productList){
                if(selectedProd.selected){
                    prodselected.add(selectedProd.prod);
                }
            }
        }   
        List<String> ProdOrgIds = new List<String>();
        List<String> ProductEPMIds = new List<String>();
        List<String> UnqOrgEPMId= new List<String>();
        Map<String,String> EPMIdsbyOrg = new Map<String,String>();
        for(SelectedProduct prodWrapper: productList){
            if(prodWrapper.selected){
                ProdOrgIds.add(prodWrapper.selectedProductOrganization);
                ProductEPMIds.add(prodWrapper.ProductEPMId);
                UnqOrgEPMId.add(prodWrapper.selectedProductOrganization+prodWrapper.ProductEPMId);
            }
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
        //Fix applied by - T Nishitha
        if(Core_IPS_Labels__c.SObjectType.getDescribe().isAccessible()){ 
         assetlist= [select id,name,accountid,product2id,product2.name, account.name,Core_Product_Organization__c,Core_Supported_Product__c from asset where Status != 'Inactive' and accountid =: acc.id and product2id IN: prodselected];   
        }
        //and accountid =: acc.id and product2id IN: prodselected 

            for(SelectedProduct prod: productList){
                if(prod.selected){                                       
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
                    for(Asset a: assetlist){                   
                        if(a.accountid==selectedacc.id && a.product2id==prod.prod.id && a.Core_Product_Organization__c == prod.selectedProductOrganization && a.Core_Supported_Product__c == OrgbySupProd.get((prod.selectedProductOrganization+prod.ProductEPMId)).id ){                        
                            litem.color='background-color:gold';
                            litem.colorvalue=true;
                            litem.selected=false;
                        }           
                    }
                    LineItemlist.add(litem);  
                }
            }
              
        if(LineItemlist.size()>0){
            lineItemListvalue=true;
            return LineItemlist;
        }else{
            lineItemListvalue=false;
            return null;
        }
        
        
    }   
    
    public void productspage(){
        showAccountFlag=false;
        showProductFlag=true;
        showLineItemFlag=false;    
    }
    public void showLineItemPage(){
        processSelectedProducts();
        showAccountFlag=false;
        showProductFlag=false;
        getLineItemsmethod();
        showLineItemFlag=true; 
            
    }


    public class SelectedProduct{
        public boolean selected{get;set;}
        public product2 prod{set;get;}
        public String relatedSupProduct{get;set;}
        public String selectedProductOrganization{get;set;}
        public String ProductEPMId{get;set;}
        public String UniqueOrgEPMId{get;set;}
        public String supProdId{get;set;}
        public List<SelectOption> prodOrgs{get;set;}
        public boolean productOrgoneSize{get;set;}
        public string color{get;set;}
        public Core_IPS_Supported_Product__c SupProduct{get;set;}
    }

    public class WrapLineItem{
        public boolean selected{get;set;}
        public product2 prod{set;get;}
        public Account acc {get; set;}
        public String color{get;set;}
        public String prodOrgId{get;set;}
        public Boolean colorvalue{get;set;}
        public String prodOrgName{get;set;}
        public String prodEPMId{get;set;}
        public String UniqueOrgEPMId{get;set;}
        public String prodOrgDescription{get;set;}
        public String FlagStatus{get;set;}
        public Core_IPS_Supported_Product__c SupProduct{get;set;}
    }


    public void backToProductScreen(){
        showAccountFlag=false;
        showProductFlag=true;
        showLineItemFlag=false;
        
    }
}