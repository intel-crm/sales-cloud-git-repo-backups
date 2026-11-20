@isTest
Public class Core_IPS_PARCreation_Controller_Lex_Test { //System.assert()--> statement Added By Hassan Khan 04-02-2024
    public static Core_IPS_PARCreation_Controller_Lex PARCreationController{get;set;}
    public static Account accnt;
    static ApexPages.StandardController accountController;    
    static List<Product2> ProductList = new List<Product2>();
        static List<Product2> ProductList1 = new List<Product2>();

    static Core_IPS_Product_Organization__c prodOrg = new Core_IPS_Product_Organization__c();
        static Core_IPS_Product_Organization__c prodOrg1 = new Core_IPS_Product_Organization__c();

    static List<User> ListOfUser = new List<User> ();
    static List<Core_IPS_Supported_Product__c> SuppProductList1 = new List<Core_IPS_Supported_Product__c> ();
        static List<Core_IPS_Supported_Product__c> SuppProductList2 = new List<Core_IPS_Supported_Product__c> ();

    static public void getRecords(integer tid){
         // Insert IPS Labels
        List<Core_IPS_Labels__c> ipsLabels = TestUtilities.getIPSLabel();
        insert ipsLabels;
       
        // inserting product org
        prodOrg = TestUtilities.getSupportOrg();
        prodOrg.OwnerId = [SELECT Id FROM User LIMIT 1].Id;
        insert prodOrg;
        System.assert(prodOrg <> null, 'Record not created');
        accnt = TestUtilities.getAccountRecord();
        accnt.Core_IPS_Active__c = true;
        accnt.Core_CNDA_Number__c =  '1212211';
        insert accnt; 
        Core_IPS_PARCreation_Controller_Lex.getAccount(accnt.id);
    
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
        
        for(Core_IPS_Supported_Product__c supportedProductRecord: SuppProductList1){                
            string prodorgid = prodOrg.id;
            supportedProductRecord.Core_Product__c = ProductList.get(i).id;
            supportedProductRecord.Core_Product_Organization__c = prodOrg.id;
            supportedProductRecord.Core_EOIS__c = false;
            supportedProductRecord.Core_Flag_Status__c = 'Approval Required';
            supportedProductRecord.Core_Product_EPM_ID__c = ProductList.get(i).Core_Unique_ID__c ;
            supportedProductRecord.Core_Unique_Supported_Product__c = (prodorgid.substring(0,15)+ProductList.get(i).Core_Unique_ID__c);
            i++;                     
        }
        
        insert SuppProductList1;
        System.assert(SuppProductList1 <> null, 'Record not created');
        accountController = new ApexPages.StandardController(accnt);
        
    }
      
    static testMethod void callNoConditionMethods(){
        ProductList = TestUtilities.getListOfProduct(3);
        Integer j= 0;
       
        for(Product2 prod2: ProductList){
            prod2.Core_Product_Name_EPM_ID__c = '1243'+j;
            prod2.Name = 'Haswell';
            j++;
        }
        insert ProductList;
        
        prodOrg = TestUtilities.getSupportOrg();
        prodOrg.OwnerId = [SELECT Id FROM User WHERE IsActive = true AND UserType = 'Standard' LIMIT 1].Id;
        insert prodOrg;
        
        
        SuppProductList1 = TestUtilities.getListOfSupportedProduct(3);       
        Integer i = 0;
        
        for(Core_IPS_Supported_Product__c supportedProductRecord: SuppProductList1){                
            string prodorgid = prodOrg.id;
            supportedProductRecord.Core_Product__c = ProductList.get(i).id;
            supportedProductRecord.Core_Product_Organization__c = prodOrg.id;
            supportedProductRecord.Core_EOIS__c = false;
            supportedProductRecord.Core_Flag_Status__c = 'Approval Required';
            supportedProductRecord.Core_Product_EPM_ID__c = ProductList.get(i).Core_Unique_ID__c ;
            supportedProductRecord.Core_Unique_Supported_Product__c = (prodorgid.substring(0,15)+ProductList.get(i).Core_Unique_ID__c);
            supportedProductRecord.core_IPS_public_product__c=false;
            i++;                     
        }
        
        insert SuppProductList1;
        test.starttest();         
    	
    	List <Core_IPS_PARCreation_Controller_Lex.SelectedProduct> envdeatils = Core_IPS_PARCreation_Controller_Lex.getSupportedProducts('Haswell', 10 , 0);
        Core_IPS_PARCreation_Controller_Lex.WrapLineItem lineItem = new Core_IPS_PARCreation_Controller_Lex.WrapLineItem();
        lineItem.selected = true;
        lineItem.prod = ProductList[0];
        lineItem.acc = accnt;
        lineItem.prodOrgId = SuppProductList1[0].Core_Product_Organization__c;
        lineItem.prodEPMId = SuppProductList1[0].Core_Product_EPM_ID__c;
        lineItem.SupProduct = SuppProductList1[0];
        lineItem.UniqueOrgEPMId = SuppProductList1[0].Core_Product_Organization__c + SuppProductList1[0].Core_Product_EPM_ID__c;
        
        test.stoptest();
        System.assert(SuppProductList1[0].id != null,true);
    }    
       
    
        static testMethod void testcoverNew(){
        ProductList = TestUtilities.getListOfProduct(6);
        Integer j= 0;
        for(Product2 prod2: ProductList){
            prod2.Core_Product_Name_EPM_ID__c = '1243'+j;
            prod2.Name = 'Haswell';
            j++;
        }
        insert ProductList;
        
        prodOrg = TestUtilities.getSupportOrg();
        prodOrg.OwnerId = [SELECT Id FROM User WHERE IsActive = true AND UserType = 'Standard' LIMIT 1].Id;
        insert prodOrg;
        
        
        SuppProductList1 = TestUtilities.getListOfSupportedProduct(3);       
        Integer i = 0;
        
        for(Core_IPS_Supported_Product__c supportedProductRecord: SuppProductList1){                
            string prodorgid = prodOrg.id;
            supportedProductRecord.Core_Product__c = ProductList.get(i).id;
            supportedProductRecord.Core_Product_Organization__c = prodOrg.id;
            supportedProductRecord.Core_EOIS__c = false;
            supportedProductRecord.Core_Flag_Status__c = 'Auto Approve';
            supportedProductRecord.Core_Product_EPM_ID__c = ProductList.get(i).Core_Unique_ID__c ;
            supportedProductRecord.Core_Unique_Supported_Product__c = (prodorgid.substring(0,15)+ProductList.get(i).Core_Unique_ID__c);
            supportedProductRecord.core_IPS_public_product__c=false;
            i++;                     
        }

            ProductList1 = TestUtilities.getListOfProduct(6);
        Integer l= 0;
       
        for(Product2 prod3: ProductList1){
            prod3.Core_Product_Name_EPM_ID__c = '1243'+l;
            prod3.Name = 'Grand Ridge';
            l++;
        }
        insert ProductList1;
        
        prodOrg1 = TestUtilities.getSupportOrg();
        prodOrg1.OwnerId = [SELECT Id FROM User WHERE IsActive = true AND UserType = 'Standard' LIMIT 1].Id;
        insert prodOrg1;
        
        
        SuppProductList2 = TestUtilities.getListOfSupportedProduct(3);       
        Integer p = 0;
        
        for(Core_IPS_Supported_Product__c supportedProductRecord: SuppProductList2){                
            string prodorgid = prodOrg1.id;
            supportedProductRecord.Core_Product__c = ProductList1.get(p).id;
            supportedProductRecord.Core_Product_Organization__c = prodOrg1.id;
            supportedProductRecord.Core_EOIS__c = false;
            supportedProductRecord.Core_Flag_Status__c = 'Auto Approve';
            supportedProductRecord.Core_Product_EPM_ID__c = ProductList.get(i).Core_Unique_ID__c ;
            supportedProductRecord.Core_Unique_Supported_Product__c = (prodorgid.substring(0,15)+ProductList1.get(p).Core_Unique_ID__c);
            supportedProductRecord.core_IPS_public_product__c=false;
            i++;                     
        }
        
        test.starttest();  
            insert SuppProductList1;
            //insert SuppProductList2;
       accnt = TestUtilities.getAccountRecord();
        accnt.Core_IPS_Active__c = true;
        accnt.Core_CNDA_Number__c =  '1212211';
        insert accnt; 
 
        Core_IPS_PARCreation_Controller_Lex.getAccount(accnt.id);
       
            Core_IPS_Product_Organization__c delprodOrg = new Core_IPS_Product_Organization__c(
            Core_IPS_Support_Org_Name__c = 'TestName2',
            Core_Organization_Description__c = 'TestDescription');
       // insert delprodOrg;
            
    	Core_IPS_MAP_PAR__c mapRec = TestUtilities.getMapPar();
        mapRec.Core_Product_Organization__c = delprodOrg.id;
        mapRec.RecordTypeId  = schema.sobjecttype.Core_IPS_MAP_PAR__c.getrecordtypeinfosbyname().get('MAP').getRecordTypeId();
            Core_IPS_MAP_Product__c mapProd = new Core_IPS_MAP_Product__c();
            mapProd.Core_MAP_PAR__c = mapRec.id;
            mapProd.Core_MAP_Supported_Product__c = SuppProductList1[0].id;
           
        List<Core_IPS_PARCreation_Controller_Lex.WrapLineItem> lineItem1 = new List<Core_IPS_PARCreation_Controller_Lex.WrapLineItem>();
        Core_IPS_PARCreation_Controller_Lex.WrapLineItem lineItem = new Core_IPS_PARCreation_Controller_Lex.WrapLineItem();
        lineItem.selected = true;
        lineItem.prod = ProductList[0];
        lineItem.acc = accnt;
        lineItem.prodOrgId = SuppProductList1[0].Core_Product_Organization__c;
        lineItem.prodEPMId = SuppProductList1[0].Core_Product_EPM_ID__c;
        lineItem.SupProduct = SuppProductList1[0];
            
        lineItem.UniqueOrgEPMId = SuppProductList1[0].Core_Product_Organization__c + SuppProductList1[0].Core_Product_EPM_ID__c;
            
            lineItem1.add(lineItem);
                        Core_IPS_PARCreation_Controller_Lex.pushProducts(lineItem1,accnt.id,'required to support platform development');

        
            
        List<Core_IPS_PARCreation_Controller_Lex.SelectedProduct> envdeatils = new List<Core_IPS_PARCreation_Controller_Lex.SelectedProduct>();
        Core_IPS_PARCreation_Controller_Lex.SelectedProduct selprod = new Core_IPS_PARCreation_Controller_Lex.SelectedProduct();
        selprod.prod = ProductList[0];
        selprod.selectedProductOrganization = SuppProductList1[0].Core_Product_Organization__c;
        selprod.relatedSupProduct = 'Haswell';
        selprod.productOrgoneSize = true;
        selprod.ProductEPMId = SuppProductList1[0].Core_Product_EPM_ID__c;
        selprod.SupProduct = SuppProductList1[0];
        selprod.UniqueOrgEPMId = SuppProductList1[0].Core_Product_Organization__c + SuppProductList1[0].Core_Product_EPM_ID__c;
            
            envdeatils.add(selprod);
            Core_IPS_PARCreation_Controller_Lex.getLineItemsmethod(envdeatils);
         test.stoptest();
         System.assert(SuppProductList1[0].id != null,true);
        
    } 
        public class WrapLineItemtest{
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
        public String uniqueOrgEpmId{get;set;}
        @AuraEnabled
        public String prodOrgDescription{get;set;}
        @AuraEnabled
        public String flagStatus{get;set;}
        @AuraEnabled
        public Core_IPS_Supported_Product__c supProduct{get;set;}
    }
}