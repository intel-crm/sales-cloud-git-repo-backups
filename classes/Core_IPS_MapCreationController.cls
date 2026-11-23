/******************************************************
*Class Name:  Core_IPS_MapCreationController 
*Version     : 1.0 
*Description:  Controller for Core_IPS_Create_MAP Page
*Modification Log :
* Developer                   Date                        Description
* ----------------------------------------------------------------------------                 
* Sugandha                    16/11/2017                  Modified (Iteration#-2 User story#-US72182)
* Sugandha                    14/02/2018                  Modified (Iteration#-7 User story#-US80366)
* Sugandha                    03/04/2018                  Modified (Iteration#-9 User story#-US83354)
******************************************************/
public with sharing class Core_IPS_MapCreationController {
    
    //public Boolean productListvalue{get;set;}
    public boolean productlistvisible{get;set;}
    public Boolean lineItemvalue{get;set;}
    public boolean Userpresent{get;set;}
    public Boolean accsearchstart{get;set;} 
    public Boolean prodsearchstart{get;set;} // used to show the no search results found value
    public boolean disablebutton{get;set;}
    public boolean showProductFlag{get;set;}
    public boolean showAccountFlag{get;set;}
    public boolean showLineItemFlag{get;set;}
    public boolean accountsList{get;set;}
    public boolean showProductButton{get;set;}
    //commented for coverage
    //public Boolean flag{get;set;}
    public Core_IPS_MAP_PAR__c map1;
    public Core_IPS_MAP_PAR__c map2;
    public Core_IPS_Product_Organization__c prodOrg{get;set;}
    public Core_IPS_MAP_PAR__c reqField{get;set;}
    public Integer size{get;set;}   
    public Integer noOfRecords{get;set;}
    public Integer noOfpRecords{get;set;}
    public List<wrapAccount> wrapAccountList {get; set;}
    public List<SelectedProduct> productList;
    public List<WrapLineItem> LineItemlist{get;set;}    
    public List<String> selectengagementType {get;set;}
    public List<SelectOption> productTypes{get;set;}    
    public List<SelectOption>OrgTypes{get;set;}    
    public List<SelectOption> paginationSizeOptions{get;set;}
    public List<SelectOption> paginationpSizeOptions{get;set;}
    public List<Product2> prodList;  
    public List<Id> prodIdList = new List<Id>();
    public List<Core_IPS_Supported_Product__c> supProds;
    public List<id> eProdIdList= new List<Id>();
    public Map<Id, Set<SelectOption>> prodOrgsMap; 
    public Map<Id,Core_IPS_Supported_Product__c> mapProdToSupProd;
    public Set<Account> selectedAccounts{get;set;}
    public Set<Product2> pageSelectedProductList;
    //public String mapName{get;set;}
    public String submitterComments{get;set;}   
    public String selectedOrg{get;set;}
    public String engagementType{get;set;}    
    public String searchTextProd{get;set;}
    //public String selectedProductOrganization{get;set;}
    public String searchTxt;
    public String AccountListQuery;
    public string MapNameText{get;set;} 
    public transient String searchText{get;set;}
    //added by Sugandha for US83354
    Public integer count{get;set;}
    Public integer pageNo{get;set;}
    public integer list_size{get;set;} 
    public integer total_size{get;set;} 
    Public List<WrapLineItem> ListReqLineItem {get;set;}
    //end
    
    public Core_IPS_MapCreationController(){       
        if(mapProdToSupProd==null)
        mapProdToSupProd = new Map<Id,Core_IPS_Supported_Product__c>();    
                
        showAccountFlag=true;
        showLineItemFlag=false;
        showProductButton=false;
        lineItemvalue=false;
        prodsearchstart = false;
        
        selectedAccounts = new Set<Account>();   
        pageSelectedProductList = new Set<Product2>();
        paginationSizeOptions = new List<SelectOption>();
        wrapAccountList = new List<wrapAccount>();
        productList = new List<SelectedProduct>(); 
        reqField = new Core_IPS_MAP_PAR__c();
        paginationpSizeOptions = new List<SelectOption>();
        
        engagementType = ApexPages.currentPage().getParameters().get('eType');
        String userId = UserInfo.getUserId();
        
        if(ApexPages.currentPage().getParameters().get('id')!=null){
            prodOrg = [select id,name,Core_IPS_Support_Org_Name__c,OwnerId from Core_IPS_Product_Organization__c where id = :ApexPages.currentPage().getParameters().get('id')];
            selectedOrg= prodOrg.Core_IPS_Support_Org_Name__c;
        }
     
        List<Core_IPS_Product_Organization__c> ProdOrgs = new List<Core_IPS_Product_Organization__c>();
        ProdOrgs.add(prodOrg);        
        Userpresent =  Core_IPS_Helper_Utility.getOrgAdminsByOrg(ProdOrgs);  
        
   
        // size=25;        
        size = integer.valueof(System.Label.Core_MAP_Page_Size.split(';')[0]);
        List<String> listofSizes = System.Label.Core_MAP_Page_Size.split(';');
        // List<String> listofpSizes = System.Label.Core_IPS_MAP_Products_PageSize.split(';');
        for(String s : listofSizes){
            paginationSizeOptions.add(new SelectOption(s,s));
        }
        for(String s1 : listofSizes){
            paginationpSizeOptions.add(new SelectOption(s1,s1));
        }
        //added by Sugandha for US83354
        list_size = Integer.ValueOf(System.Label.Core_IPS_MapScreen_RecordLimit); 
        ListReqLineItem = new List<WrapLineItem>();
        count=0;
        pageNo=0;
        //end
    }
   
    //Changes the size of pagination
    public PageReference refreshPageSize() {
         processSelected();
         standardSetCon.setPageSize(size);
         // searchAccounts(); //-changes made Nov 24
         return null;
    }
    
    public PageReference refreshPageSize1() {
         processSelectedProducts();
         standardSetproduct.setPageSize(size);
         return null;
    }
    
    public void searchAccounts(){
        // Wrapaccountlist = new List<wrapAccount>(); //-changes made nov 24
        searchTxt = '%'+searchText+'%';
        String fieldSetFields='select ';
        for(Schema.FieldSetMember f : SObjectType.Account.FieldSets.Core_Mapacc_Field_Set.getFields()) {
            fieldSetFields += f.getFieldPath() + ', ';
        }
        // added a condition Core_CNDA_Number__c != '' to restrict Non NDA accounts by Sugandha for US80366 Iteration 7
        //AccountListQuery =fieldSetFields+'Phone from Account where Core_IPS_Active__c=true and name like \''+searchTxt+'\' ORDER BY Account.Name ASC NULLS LAST  limit 9999'; 
        AccountListQuery =fieldSetFields+'Phone from Account where (Core_CNDA_Number__c != \'\' OR Core_CNDA_Number__c != Null) and Core_IPS_Active__c=true and name like \''+searchTxt+'\' ORDER BY Account.Name ASC NULLS LAST  limit 9999'; 
        standardSetCon =null;
        accsearchstart= true; 
        processSelected();        
    }
    
    
        
    public List<wrapAccount> getpaginated(){ 
        Wrapaccountlist = new List<wrapAccount>();          
        if(selectedAccounts!=null){
            for(Account a : selectedAccounts){
              wrapAccount wAct = new wrapAccount();
              wAct.selected=true;
              wAct.acc=a;
              wrapAccountList.add(wAct);
            }
        }
        if(standardsetcon <> null){
            for(Account a: (List<Account>)standardsetcon.getrecords()){ 
                if(!selectedAccounts.contains(a)){
                    wrapAccount wAct = new wrapAccount();
                    wAct.selected=false;
                    wAct.acc=a;
                    wrapAccountList.add(wAct);
                }                               
            }
        }       
        if(wrapAccountList.size()>0){
            accountsList =true;
            disablebutton = false;
            return wrapAccountList;
        }else{
            disablebutton = true;
            if(accsearchstart == true)
            accountsList = false;
            else
            accountsList = true;
            return null;
        }
    }

    public ApexPages.StandardSetController standardSetCon {
        get {
            if(standardSetCon == null && AccountListQuery!=null) {                
                standardSetCon = new ApexPages.StandardSetController(Database.getQueryLocator(AccountListQuery)); 
                standardSetCon.setPageSize(size);                
                noOfRecords = standardSetCon.getResultSize();           
            }
            return standardSetCon;
        }
        set;
    }
 
    public void processSelected() {
        if(wrapAccountList <> null && wrapAccountList.size()>0){
            for(wrapAccount wrapAccountObj: wrapAccountList){
                if(wrapAccountObj.selected == true) {
                    selectedAccounts.add(wrapAccountObj.acc);
                }
                else{
                    if(selectedAccounts.contains(wrapAccountObj.acc))
                       selectedAccounts.remove(wrapAccountObj.acc);
                    }
            }
        }
    }
    
    // Products Section 
    
    public void searchProducts(){
        // productList = new List<SelectedProduct>(); //-change made dec 4 
        if(pageSelectedProductList!=null)
        processSelectedProducts();
        prodIdList=new List<Id>();
        String searchTxt = '%'+searchTextProd+'%';
    
        if(engagementType =='Map')
            supProds = new List<Core_IPS_Supported_Product__c>(); //added by sugandha for US83354
            //Iteration#-2 User story#-US72182 DeveloperName-Sugandha Description- added where clouse condition and core_IPS_public_product__c = false for public product           
           supProds = [select id,name, Core_Product__c, Core_Product_Organization__c,Core_Product__r.name, Core_Product__r.description, Core_Product__r.id,Core_Flag_Status__c,Core_Supported_Product_Name__c from Core_IPS_Supported_Product__c where Core_Product__r.name like :searchTxt and Core_Product_Organization__c = :prodOrg.id and Core_EOIS__c = false and core_IPS_public_product__c = false /*limit 100*/];    
             /*else
            supProds = [select id,name, Core_Product__c, Core_Product_Organization__c,Core_Product_Organization__r.id, Core_Product_Organization__r.Name,Core_Product__r.name, Core_Product__r.description, Core_Product__r.id,Core_Flag_Status__c,Core_Supported_Product_Name__c from Core_IPS_Supported_Product__c where Core_Flag_Status__c!='Par Hidden' and Core_EOIS__c = false and Core_Product__r.name like :searchTxt  order by Core_Product__r.name /*limit 100 */

            for(Core_IPS_Supported_Product__c sp:supProds){
                prodIdList.add(sp.Core_Product__r.id);
                if(!mapProdToSupProd.containsKey(sp.core_Product__r.id))
                mapProdToSupProd.put(sp.core_Product__r.id,sp);
                system.debug('sup prod and product map***'+mapProdToSupProd);
            }
            String prodQuery='Select ';
            for(Schema.FieldSetMember f : SObjectType.Product2.FieldSets.Map_Prod_FieldSet.getFields()) {
                prodQuery += f.getFieldPath() + ', ';
            }
            prodQuery +=' id,name from Product2 where id in:prodIdList ORDER BY Product2.Name ASC NULLS LAST';
            prodList = Database.query(prodQuery);
           
        /*if(engagementType =='Par'){
            prodOrgsMap = new Map<Id, Set<SelectOption>>();
            for(integer i=0;i<supProds.size();){
                Set<SelectOption> selOptList = new Set<SelectOption>();
                selOptList.add(new SelectOption(supProds[i].Core_Product_Organization__r.id,supProds[i].Core_Product_Organization__r.Name));
                integer j = i+1;
                for(;j<supProds.size();j++){
                    if(supProds[i].Core_Product__r.id==supProds[j].Core_Product__r.id){
                        selOptList.add(new SelectOption(supProds[j].Core_Product_Organization__r.id,supProds[j].Core_Product_Organization__r.Name));
                        continue;
                    }
                    break;
               }
               prodOrgsMap.put(supProds[i].Core_Product__r.id,selOptList);
               i=j;
              
            }
        }*/
        standardSetproduct=null;
        prodsearchstart=true;
    }
   
    public List<SelectedProduct> getProductList(){ 
        productList = new List<SelectedProduct>(); 
        if(pageSelectedProductList <> null){
            for(Product2 prod : pageSelectedProductList){
                SelectedProduct selProd = new SelectedProduct();
                    selProd.selected=true;
                    selProd.prod=prod;
                    selProd.SupProduct = mapProdToSupProd.get(prod.id);
                    if(mapProdToSupProd.get(prod.id)!=null )
                        selProd.relatedSupProduct = mapProdToSupProd.get(prod.id).Core_Supported_Product_Name__c ;
                    if(engagementType =='Par' && prodOrgsMap!=null){
                        Set<SelectOption> prodOrgsSet = new Set<SelectOption>();
                        prodOrgsSet= prodOrgsMap.get(prod.id);
                        List<SelectOption> progOrgsList = new List<SelectOption>();
                        if(prodOrgsSet!=null)
                        progOrgsList.addAll(prodOrgsSet);
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
                    selProd.SupProduct = mapProdToSupProd.get(prod.id);
                    selProd.relatedSupProduct = mapProdToSupProd.get(prod.id).Core_Supported_Product_Name__c ;
                    if(engagementType =='Par' && prodOrgsMap!=null){
                        Set<SelectOption> prodOrgsSet = new Set<SelectOption>();
                        prodOrgsSet= prodOrgsMap.get(prod.id);
                        List<SelectOption> progOrgsList = new List<SelectOption>();
                        if(prodOrgsSet!=null)
                        progOrgsList.addAll(prodOrgsSet);
                        selProd.prodOrgs = progOrgsList;
                    }   
                productList.add(selProd);
                }
            }
        }   
        if(productList <> null && productList.size()>0){
            system.debug('coming here!@#');
            // productListvalue=true;
            productlistvisible = true;
            disablebutton = false;
            system.debug('b val'+productlistvisible);
            return productList;
        }else{
            system.debug('coming here!@#2');
            disablebutton = true;
            system.debug('SS'+prodsearchstart);
            if(prodsearchstart == true)
            productlistvisible = false;
            if(prodsearchstart == null || prodsearchstart == false)
            productlistvisible =true;                
            system.debug('3PL'+productlistvisible);
            return null;
        }
    }
    
    public Void processSelectedProducts(){
        if(productList <> null && productList.size()>0){
            for(SelectedProduct selProd : productList){
                if(selProd.selected == true) {
                    pageSelectedProductList.add(selProd.prod);
                }
                else{
                    if(pageSelectedProductList.contains(selProd.prod))
                       pageSelectedProductList.remove(selProd.prod);
                    }
            }
        }
    }
         
    public ApexPages.StandardSetController standardSetproduct{
        get {
            if(standardSetproduct  == null && prodList!=null){
                standardSetproduct = new ApexPages.StandardSetController(prodList);
                standardSetproduct.setPageSize(size);
                noOfpRecords = standardSetproduct.getResultSize();
               
            }
            return standardSetproduct;
        }
        set;
    }
    
    public Pagereference createMapNew(){
        
        List<Account> selectedAccountList = new List<Account>();
        List<Core_IPS_Map_Par_Line_Item__c> mapLineItems = new List<Core_IPS_Map_Par_Line_Item__c>();
        List<Core_IPS_MAP_Account__c> coreMapAccToInsert = new List<Core_IPS_MAP_Account__c >();
        List<Core_IPS_MAP_Product__c> coreMapPrdToInsert = new List<Core_IPS_MAP_Product__c>();
        Set<Id> distinctProductIds = new Set<Id>();
        Set<ID> distinctAccountIds = new Set<ID>();

        map1 = new Core_IPS_MAP_PAR__c();
        map1.Core_Product_Organization__c = prodOrg.Id;
        // map1.core_name__c = reqField.Core_Name__c;
        map1.core_name__c = MapNameText;
        map1.RecordTypeId = schema.sobjecttype.Core_IPS_MAP_PAR__c.getrecordtypeinfosbyname().get('MAP').getRecordTypeId();
        map1.Core_Submitter_Comments__c=submitterComments;
        insert map1;

        for(WrapLineItem wl : LineItemlist){
            if(wl.selected){
                Core_IPS_Map_Par_Line_Item__c lineItem = new Core_IPS_Map_Par_Line_Item__c();
                lineItem.Core_Account__c = wl.acc.id;
                lineItem.Core_Supported_Product__c=mapProdToSupProd.get(wl.prod.id).id;                
                lineItem.Core_MAP_PAR__c = map1.id;
                lineItem.RecordTypeId = schema.sobjecttype.Core_IPS_Map_Par_Line_Item__c.getrecordtypeinfosbyname().get('MAP').getRecordTypeId();
                mapLineItems.add(lineItem);
                distinctProductIds.add(wl.prod.id);
                distinctAccountIds.add(wl.acc.id);
            }
        }
        
        for(Id prodId : distinctProductIds){
            Core_IPS_MAP_Product__c corePrd= new Core_IPS_MAP_Product__c();
            corePrd.Core_MAP_PAR__c = map1.id;
            corePrd.Core_MAP_Supported_Product__c = mapProdToSupProd.get(prodid).id;
            coreMapPrdToInsert.add(corePrd); 
        }
        for(Id accId : distinctAccountIds){
            Core_IPS_MAP_Account__c mapAcc = new Core_IPS_MAP_Account__c();
            mapAcc.Core_MAP_PAR__c = map1.id;
            mapAcc.Core_Account__c = accid;
            coreMapAccToInsert.add(mapAcc);
        }

        if(engagementType =='Map'){
            insert mapLineItems;
            Core_IPS_MAPAccount_Dispatcher.DontExecuteTrigger=true;
            insert coreMapAccToInsert;
            insert coreMapPrdToInsert;
            Core_IPS_MAPAccount_Dispatcher.DontExecuteTrigger=false;
            
        }else{
        }
        return new PageReference('/'+map1.id);
        return null;
    }      
    

    public List<WrapLineItem> getLineItemsmethod(){
        LineItemlist = new List<WrapLineItem>();       
        List<Account> accountsselected = new List<Account>();
        if(wrapAccountList!=null && wrapAccountList.size()>0){
            for(wrapAccount selectedAct:wrapAccountList){
                if(selectedAct.selected){
                    accountsselected.add(selectedAct.acc);
                }
            }
        }
        
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
        for(SelectedProduct OrgIds: productList){
            ProdOrgIds.add(OrgIds.selectedProductOrganization);
        }
        
        List<Core_IPS_Product_Organization__c> ProdOrgList = [Select id,name,Core_IPS_Support_Org_Name__c from Core_IPS_Product_Organization__c where id IN:ProdOrgIds];
        Map<String,Core_IPS_Product_Organization__c> MapProdOrgNames =  new Map<String,Core_IPS_Product_Organization__c>();
        
        for(Core_IPS_Product_Organization__c ProdOrgs: ProdOrgList){
            MapProdOrgNames.put(ProdOrgs.id,ProdOrgs);          
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
                    litem.prodOrgId = prodOrg.id;//prod.selectedProductOrganization
                    litem.prodOrgName = prodOrg.Core_IPS_Support_Org_Name__c;
                    litem.FlagStatus = mapProdToSupProd.get(prod.prod.id).Core_Flag_Status__c;
                    for(Asset a: assetlist){                   
                        if(a.accountid==acc.id && a.product2id==prod.prod.id && a.Core_Product_Organization__c == prodOrg.id ){                        
                            litem.color='background-color:gold';
                        }           
                    }
                    LineItemlist.add(litem);   
                }
            }
        }       
        if(LineItemlist.size()>0){
            lineItemvalue=true;
            // added by sugandha US83354
            total_size = LineItemlist.size();
            getlineItemNext(); 
            //end
        }else{
            lineItemvalue=false;
            total_size = 0;// added by sugandha US83354
        }
        return LineItemlist;
    }   
    

    
    public void productspage(){
        // processSelected();
        showAccountFlag=false;
        showProductFlag=true;
        showLineItemFlag=false;
    }
    public void showLineItemPage(){        
        showAccountFlag=false;
        showProductFlag=false;
        getLineItemsmethod();
        //processSelectedProducts();
        processSelected();
        showLineItemFlag=true;    
    }
    public class wrapAccount {
        public Account acc {get; set;}
        public Boolean selected {get; set;}
    }

    public class SelectedProduct{
        public boolean selected{get;set;}
        public product2 prod{set;get;}
        public String relatedSupProduct{get;set;}
        public String selectedProductOrganization{get;set;}
        public String supProdId{get;set;}
        public List<SelectOption> prodOrgs{get;set;}
        public Core_IPS_Supported_Product__c SupProduct{get;set;}
    }

    public class WrapLineItem{
        public boolean selected{get;set;}
        public product2 prod{set;get;}
        public Account acc {get; set;}
        public String color{get;set;}
        public String prodOrgId{get;set;}
        public String prodOrgName{get;set;}
        public String FlagStatus{get;set;}
        public Core_IPS_Supported_Product__c SupProduct{get;set;}
    }
    public void backToAccountScreen(){
        //added by Sugandha for US83354
        count = 0;
        pageNo = 0;
        //end
        showAccountFlag=true;
        showProductFlag=false;
        showLineItemFlag=false;
    }
    
    public void accFirstPage(){
        processSelected();
        standardsetcon.first();
    }
    
    public void accNextPage(){
        processSelected();
        standardsetcon.next();
    }
    public void accPrevPage(){
        processSelected();
        standardsetcon.previous();
    }
    
    public void accLastPage(){
        processSelected();
        standardsetcon.last();
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
    
/***************************************************************************************************
Method Name:  getlineItemNext
Method Type: Action Method 
Version     : 1.0 
Created Date: 03-04-2018
Function    : This method displays next set of Line Items for Review.
Input Parameters: None
Output Parameters: None 
Used in     : Core_IPS_Create_MAP
Modification Log :               
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Sugandha                   03/04/2018                 Created(UserStory US83354 Iteration 9)
****************************************************************************************************/ 
    public void getlineItemNext(){
        ListReqLineItem = new List<WrapLineItem>(); 
        Integer lstSizeLimit = list_size+count; 
        pageNo = pageNo+1;
        if(lstSizeLimit >= total_size){
            lstSizeLimit = total_size;
        }
        for(integer start = count; start < lstSizeLimit ; start++){
           ListReqLineItem.add(LineItemlist[start]);
           count++;
        }
    }
/***************************************************************************************************
Method Name:  lineItemPrev
Method Type: Action Method 
Version     : 1.0 
Created Date: 03-04-2018
Function    : This method displays previous set of Line Items for Review.
Input Parameters: None
Output Parameters: None 
Used in     : Core_IPS_Create_MAP
Modification Log :               
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Sugandha                   03/04/2018                 Created(UserStory US83354 Iteration 9)
****************************************************************************************************/     
    public void lineItemPrev(){
       ListReqLineItem = new List<WrapLineItem>(); 
       pageNo = pageNo -1;
       count = (pageNo * list_size)-list_size;
       Integer lstSizeLimit = count+ List_size;
       for(integer start = count ; start < lstSizeLimit; start++){
           ListReqLineItem.add(LineItemlist[start]);
           count++;
       }
    }
/***************************************************************************************************
Method Name:  lineItemFirst
Method Type: Action Method 
Version     : 1.0 
Created Date: 03-04-2018
Function    : This method displays previous set of Line Items for Review.
Input Parameters: None
Output Parameters: None 
Used in     : Core_IPS_Create_MAP
Modification Log :               
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Sugandha                   03/04/2018                 Created(UserStory US83354 Iteration 9)
****************************************************************************************************/    
    public void lineItemFirst(){
        ListReqLineItem = new List<WrapLineItem>();
        Count = 0;
        pageNo =0;
        Integer lstSizeLimit = list_size+count; 
        pageNo = pageNo+1;
        for(integer start = count; start < lstSizeLimit ; start++){
           ListReqLineItem.add(LineItemlist[start]);
           count++;
        }
        
    }
/***************************************************************************************************
Method Name:  lineItemLast
Method Type: Action Method 
Version     : 1.0 
Created Date: 03-04-2018
Function    : This method displays last set of Line Items for Review.
Input Parameters: None
Output Parameters: None 
Used in     : Core_IPS_Create_MAP
Modification Log :               
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Sugandha                   03/04/2018                 Created(UserStory US83354 Iteration 9)
****************************************************************************************************/    
    public void lineItemLast(){
        ListReqLineItem = new List<WrapLineItem>();
        Integer remainder = math.mod(total_size, list_size);
        if(remainder > 0)
        PageNo = (total_size/list_size) + 1;
        else
        PageNo = (total_size/list_size);
        
        count = (pageNo * list_size)-list_size;
        system.debug('count last::'+count);
        
        for(integer start = count; start < total_size; start++){
           ListReqLineItem.add(LineItemlist[start]);
           count++;
        }
        
    }
    
    //added by Sugandha for US83354
    public Boolean getShowFirst() { 
     if (PageNo<=1) return false; else return true;
    }
    public Boolean getShowPrevious() { 
     if (count<=list_size ) return false; else return true;
    }
    public Boolean getShowNext() {
      if (count < total_size) return true; else return false;
    }
    public Boolean getShowLast() { 
        Integer remainder = math.mod(total_size, list_size);
        system.debug('remainder ::'+remainder +'PageNo::'+PageNo );
        if(remainder > 0 && PageNo == (total_size/list_size) + 1) return false;
        else if(remainder == 0 && PageNo == (total_size/list_size)) return false;
        else return true;
    }
    //end here
}