@isTest
Public class Core_IPS_PARCreationController_Test{
    public static Core_IPS_PARCreationController PARCreationController{get;set;}
    public static List<Core_IPS_PARCreationController.SelectedProduct> spList{get;set;}
    public static List<Core_IPS_PARCreationController.WrapLineItem> wpList{get;set;} 
    public static Account accnt;
    static ApexPages.StandardController accountController;    
    
    static List<Product2> ProductList = new List<Product2>();
    static Core_IPS_Product_Organization__c prodOrg = new Core_IPS_Product_Organization__c();
    static List<User> ListOfUser = new List<User> ();
    static List<Core_IPS_Supported_Product__c> SuppProductList1 = new List<Core_IPS_Supported_Product__c> ();
    static public void getRecords(integer tid){
         // Insert IPS Labels
        List<Core_IPS_Labels__c> IPSLabels = TestUtilities.getIPSLabel();
        insert IPSLabels;
        // inserting product org
        prodOrg = TestUtilities.getSupportOrg();
        insert prodOrg;
        System.assert(prodOrg <> null, 'Record not created');
        accnt = TestUtilities.getAccountRecord();
        insert accnt; 
        
        PageReference PageRef = Page.Core_IPS_Create_PAR;
        Test.setCurrentPage(PageRef);
        ApexPages.currentPage().getParameters().put('orgid', prodOrg.id); 
        ApexPages.currentPage().getParameters().put('id', accnt.id); 
        if(tid==1){
            ApexPages.currentPage().getParameters().put('eType','Par');
        }
        else if(tid==2){
            ApexPages.currentPage().getParameters().put('eType','Map');
        }
         // inserting products
        ProductList = TestUtilities.getListOfProduct(3);
        Integer j= 0;
        for(Product2 prod2: ProductList){
            prod2.Core_Product_Name_EPM_ID__c = '1243'+j;
            j++;
        }
        insert ProductList;
        System.assert(ProductList <> null, 'Record not created');

        // inserting Supported Product 
        SuppProductList1 = TestUtilities.getListOfSupportedProduct(3);       
        Integer i = 0;
        for(Core_IPS_Supported_Product__c SupportedProductRecord: SuppProductList1){                
            string prodorgid = prodOrg.id;
            SupportedProductRecord.Core_Product__c = ProductList.get(i).id;
            SupportedProductRecord.Core_Product_Organization__c = prodOrg.id;
            SupportedProductRecord.Core_EOIS__c = false;
            SupportedProductRecord.Core_Flag_Status__c = 'Approval Required';
            SupportedProductRecord.Core_Product_EPM_ID__c = ProductList.get(i).Core_Unique_ID__c ;
            SupportedProductRecord.Core_Unique_Supported_Product__c = (prodorgid.substring(0,15)+ProductList.get(i).Core_Unique_ID__c);
            i++;                     
        }
        
        insert SuppProductList1;
        System.assert(SuppProductList1 <> null, 'Record not created');

        accountController = new ApexPages.StandardController(accnt);
        PARCreationController = new Core_IPS_PARCreationController(accountController);
        
    }
    
    static testMethod void callNoConditionMethods(){
        test.starttest();        
        getRecords(1); 
     
        Core_IPS_PARCreationController.SelectedProduct sp = new Core_IPS_PARCreationController.SelectedProduct();
        sp.prod = ProductList[0];
        if(SuppProductList1[0] != null) 
        {
            sp.selectedProductOrganization = SuppProductList1[0].Core_Product_Organization__c;
            sp.SupProduct = SuppProductList1[0];
            sp.ProductEPMId = SuppProductList1[0].Core_Product_EPM_ID__c;
            PARCreationController.mapProdToSupProd.put(SuppProductList1[0].Core_Product__c,SuppProductList1[0]);
        }    
        
        sp.selected = true;
        
        PARCreationController.productList.add(sp);              
        PARCreationController.searchProducts(); 
        PARCreationController.refreshPageSize(); 
        PARCreationController.processSelectedProducts();
        PARCreationController.prodFirstPage();
        PARCreationController.prodNextPage();
        PARCreationController.prodPrevPage();
        PARCreationController.prodLastPage(); 
        spList = PARCreationController.getProductList();
         
        PARCreationController.createParRequest_New();  
        test.stoptest();   
    }    
    
     static testMethod void getProductListTest(){
        test.starttest();        
        getRecords(1); 
        Core_IPS_PARCreationController.SelectedProduct sp = new Core_IPS_PARCreationController.SelectedProduct();
        sp.prod = ProductList[0];
        if(SuppProductList1[0] != null) {
            sp.selectedProductOrganization = SuppProductList1[0].Core_Product_Organization__c;
            sp.SupProduct = SuppProductList1[0];
            sp.ProductEPMId = SuppProductList1[0].Core_Product_EPM_ID__c;
            sp.UniqueOrgEPMId = SuppProductList1[0].Core_Product_Organization__c+SuppProductList1[0].Core_Product_EPM_ID__c;
            PARCreationController.mapProdToSupProd.put(SuppProductList1[0].Core_Product__c,SuppProductList1[0]);
        }            
        sp.selected = true;
        //adding Supp Prod to Product List
        PARCreationController.productList.add(sp);
        //Calling Methods
        PARCreationController.processSelectedProducts();
        PARCreationController.searchTextProd = 'Haswell';    
        PARCreationController.searchProducts(); 
        PARCreationController.refreshPageSize();          
        spList = PARCreationController.getProductList();
        
        test.stoptest();   
    } 
    
    static testMethod void getLineItemsmethodTest(){
        //Setting the engagement type to 'PAR'
        getRecords(1);
        test.starttest(); 
        Core_IPS_PARCreationController.SelectedProduct sp = new Core_IPS_PARCreationController.SelectedProduct();
        sp.prod = ProductList[0];
        if(SuppProductList1[0] != null) {
            sp.selectedProductOrganization = SuppProductList1[0].Core_Product_Organization__c;
            sp.SupProduct = SuppProductList1[0];
            sp.ProductEPMId = SuppProductList1[0].Core_Product_EPM_ID__c;
            sp.UniqueOrgEPMId = SuppProductList1[0].Core_Product_Organization__c+SuppProductList1[0].Core_Product_EPM_ID__c;
            PARCreationController.mapProdToSupProd.put(SuppProductList1[0].Core_Product__c,SuppProductList1[0]);
        }           
        sp.selected = true;
        //adding Supp Prod to Product List
        PARCreationController.productList.add(sp);
        //Calling Methods
        PARCreationController.showLineItemPage();
        wpList = PARCreationController.getLineItemsmethod();
        PARCreationController.productspage();
        PARCreationController.backToProductScreen();
        PARCreationController.submitterCommentsText='Teststring';
        PARCreationController.createParRequest_New(); 
        test.stoptest();        
    }
}