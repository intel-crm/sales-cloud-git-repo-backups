@isTest
Public class Core_IPS_MapCreationController_Test
{
    public static Core_IPS_MapCreationController mapController{get;set;}
    public static List<Core_IPS_MapCreationController.wrapAccount> wraplist{get;set;}
    public static List<Core_IPS_MapCreationController.SelectedProduct> spList{get;set;}
    public static List<Core_IPS_MapCreationController.WrapLineItem> wpList{get;set;}
    public static Core_IPS_Product_Organization__c ProdOrg;
    static public void getRecords(){
        // Insert IPS Labels
        List<Core_IPS_Labels__c> IPSLabels = TestUtilities.getIPSLabel();
        insert IPSLabels;
        
        ProdOrg = TestUtilities.getSupportOrg();
        insert ProdOrg;
        PageReference PageRef = Page.Core_IPS_Create_MAP;
        Test.setCurrentPage(PageRef);
        ApexPages.currentPage().getParameters().put('id', ProdOrg.id);
        ApexPages.currentPage().getParameters().put('eType','Map');
        mapController = new Core_IPS_MapCreationController();
        //Account acc = [Select Name from Account limit 1];
        mapController.searchTextProd = 'Haswell';
    }
    
    static testMethod void AllMethods_Test(){        
        getRecords();                
        mapController.searchAccounts();  
        mapController.refreshPageSize();
        mapController.processSelected();        
        wraplist = mapController.getpaginated();    
        
        mapController.accFirstPage();
        mapController.accNextPage();
        mapController.accPrevPage();
        mapController.accLastPage();     
        
        mapController.processSelectedProducts();
        spList = mapController.getProductList();
        mapController.searchProducts();               
        mapController.refreshPageSize1();       
        mapController.prodFirstPage();
        mapController.prodNextPage();
        mapController.prodPrevPage();
        mapController.prodLastPage();
        mapController.getProductList();
        
        ApexPages.currentPage().getParameters().put('eType','Par');
        mapController.processSelectedProducts();
        spList = mapController.getProductList();
        mapController.searchProducts();
        
        mapController.getLineItemsmethod();
        
        mapController.showLineItemPage();
        mapController.productspage();
        mapController.createMapNew();
        mapController.backToAccountScreen();
        
    }
    
    static List<Product2> ProductList = new List<Product2>();
    static List<Core_IPS_Supported_Product__c> SuppProductList = new List<Core_IPS_Supported_Product__c> ();
    static List<User> ListOfUser = new List<User> ();
    static testMethod void CallAllMethods_Test()
    {
        getRecords();
        // Query Profiles
        Map<String,ID> profiles = new Map<String,ID>();
        List<Profile> ProfileList = [select id, name from Profile where name = 'System Administrator'];
        for(Profile prf : ProfileList){
            profiles.put(prf.name, prf.id);
        }
        // Create Users
        ListOfUser = TestUtilities.getListOfUser(2);
        for(User Usr : ListOfUser){
            Usr.ProfileID =  profiles.get('System Administrator');
        }
        insert ListOfUser;
        // inserting products
        ProductList = TestUtilities.getListOfProduct(3);
        insert ProductList;
        // inserting Supported Product 
        SuppProductList = TestUtilities.getListOfSupportedProduct(3);
        Integer i = 0;
        for(Core_IPS_Supported_Product__c SupportedProductRecord: SuppProductList){                
                SupportedProductRecord.Core_Product__c = ProductList.get(i).id;
                SupportedProductRecord.Core_Product_Organization__c = prodOrg.id;
                 i++;                     
            // SuppProductList.add(SupportedProductRecord);
        }
        system.debug('test ### '+SuppProductList);
        System.runAs(ListOfUser[0]){
        insert SuppProductList;
        }
        //Map<Id,Account> accMap = new Map<Id,Account>([Select id,name from Account where Core_IPS_Active__c = true limit 2]);
        List<Account> acctList= TestUtilities.getAccountsList(1);
        acctList[0].Core_CNDA_Number__c = 'test';
        System.runAs(ListOfUser[1]){
        insert acctList;
        }
        // acc selection
        for(Account acct: acctList){
            Core_IPS_MapCreationController.wrapAccount  accWrap = new Core_IPS_MapCreationController.wrapAccount();
            accWrap.acc = acct;
            accWrap.selected = true;
            mapController.wrapAccountList.add(accWrap);
            mapController.selectedAccounts.add(acct);
            //added by naresh related to the Test Coverage Story US41854 on 6/7/16
            Core_IPS_MapCreationController coremapclr1=new Core_IPS_MapCreationController();
            coremapclr1.selectedAccounts.add(acct);
            coremapclr1.getpaginated();
            //end
        }
        //supp prod selection
        List<id> plist = new List<id>();
        for(Core_IPS_Supported_Product__c cp : SuppProductList){
            plist.add(cp.Core_Product__c);
        }
    
        //List<Product2> prodlist= [select id,name from Product2 where id in :plist];
        Map<Id,Product2> prodMap = new Map<Id,Product2>(ProductList);
        if(SuppProductList.size()>0){
            for(Core_IPS_Supported_Product__c cp : SuppProductList){
                Core_IPS_MapCreationController.SelectedProduct sp = new Core_IPS_MapCreationController.SelectedProduct();
                sp.prod = prodMap.get(cp.Core_Product__c);
                sp.selectedProductOrganization =cp.Core_Product_Organization__c;
                sp.SupProduct = cp;
                sp.selected = true;
               //added by naresh related to the Test Coverage Story US41854 on 6/7/16
                sp.relatedSupProduct='';
                sp.supProdId='';
                sp.prodOrgs=Null;
                //end
                system.debug('prod list'+sp);
                mapController.productList.add(sp);
                mapController.mapProdToSupProd.put(cp.Core_Product__c,cp);
                mapController.pageSelectedProductList.add(prodMap.get(cp.Core_Product__c));
             //added by naresh related to the Test Coverage Story US41854 on 6/7/16
                Core_IPS_MapCreationController coremapclr=new Core_IPS_MapCreationController();
            coremapclr.pageSelectedProductList.add(prodMap.get(cp.Core_Product__c));
                coremapclr.productList.add(sp); 
                 coremapclr.getProductList();
                coremapclr.processSelectedProducts();
                }
              Core_IPS_MapCreationController coremapclr=new Core_IPS_MapCreationController();
              Core_IPS_MapCreationController.SelectedProduct sp1 = new Core_IPS_MapCreationController.SelectedProduct();
            coremapclr.productList.add(sp1); 
                 coremapclr.processSelectedProducts();
        }    
        Core_IPS_MapCreationController.WrapLineItem  wrapline1 = new Core_IPS_MapCreationController.WrapLineItem();
        wrapline1.color ='';
        //end
        mapController.showLineItemPage();
        wpList = mapController.getLineItemsmethod();
        mapController.productspage();
        mapController.backToAccountScreen();
        mapController.createMapNew();
        //added by sugandha US83354
        mapController.selectengagementType = new List<String>();
        mapController.productTypes = new List<SelectOption>();
        mapController.OrgTypes = new List<SelectOption>();
        mapController.list_size = 2;
        mapController.lineItemLast();
        mapController.lineItemPrev();
        mapController.lineItemFirst();
        mapController.getShowPrevious();    
        mapController.getShowNext();   
        mapController.getShowFirst();
        mapController.getShowLast();
        mapController.list_size = 3;
        mapController.lineItemLast();
        //end
    }
    static testMethod void getproductList_Test(){
        getRecords();
        Test.startTest();
        Core_IPS_MapCreationController coremapclr=new Core_IPS_MapCreationController();
        Set<Product2> pagecontrollist=coremapclr.pageSelectedProductList;
        coremapclr.getProductList();
        Test.stopTest();
        
    }
}