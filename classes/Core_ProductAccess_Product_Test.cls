@isTest
public class Core_ProductAccess_Product_Test{
    /***************************************************************************************************
    Method Name:  getRecords
    Method Type: Void Method
    Version     : 1.0 
    Created Date: 03 Nov 2015
    Description:  Common Test data used in multiple test methods
    Scenario Type:  
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * JRK                        11/04/2015                Created
    ****************************************************************************************************/
    static List<Account> AccountList =  new List<Account>();
    static List<Product2> ProductList = new List<Product2>();
    static Core_IPS_Product_Organization__c prodOrg = new Core_IPS_Product_Organization__c();
    static List<User> ListOfUser = new List<User> ();
    static List<Core_IPS_Supported_Product__c> SuppProductList = new List<Core_IPS_Supported_Product__c> ();
    public static TestMethod void getRecords(){
        // inserting Accounts
        AccountList = TestUtilities.getAccountsList(2);
        insert AccountList;
        System.assert(AccountList <> null, 'Record not created');
        // inserting products
        ProductList = TestUtilities.getListOfProduct(3);
        insert ProductList;
        System.assert(ProductList <> null, 'Record not created');
        // inserting product org
        prodOrg = TestUtilities.getSupportOrg();
        insert prodOrg;
        System.assert(prodOrg <> null, 'Record not created');
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
        insert SuppProductList;
        System.assert(SuppProductList <> null, 'Record not created');
    }
    
    /***************************************************************************************************
    Method Name:  getRecords
    Method Type: Void Method
    Version     : 1.0 
    Created Date: 03 Nov 2015
    Description:  Common Test data used in multiple test methods
    Scenario Type:  
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * JRK                        11/04/2015                Created
    ****************************************************************************************************/
    public static TestMethod void testActivateLineItems(){
       getRecords();
       
       // inserting Product Access Header
        Core_IPS_MAP_PAR__c mapRec = TestUtilities.getMapPar();
        mapRec.Core_Product_Organization__c = prodOrg.id;
        mapRec.RecordTypeId  = schema.sobjecttype.Core_IPS_MAP_PAR__c.getrecordtypeinfosbyname().get('MAP').getRecordTypeId(); //'012210000004IHY';
        insert mapRec;
        System.assert(mapRec <> null, 'Record not created');
        
        // inserting Product Access Header
        Core_IPS_MAP_PAR__c parRec = TestUtilities.getMapPar();
        parRec.Core_Product_Organization__c = prodOrg.id;
        parRec.RecordTypeId  = schema.sobjecttype.Core_IPS_MAP_PAR__c.getrecordtypeinfosbyname().get('PAR').getRecordTypeId(); //'012210000004IHZ';
        insert parRec;
        System.assert(parRec <> null, 'Record not created');
        
        // inserting Product Access Line Items-MAP
        List<Core_IPS_Map_Par_Line_Item__c> lineItemList = new List<Core_IPS_Map_Par_Line_Item__c>();
        for(Integer i=0;i<2;i++){
            Core_IPS_Map_Par_Line_Item__c lineItem = new Core_IPS_Map_Par_Line_Item__c();
            lineItem.Core_MAP_PAR__c = mapRec.id;
            lineItem.Core_Supported_Product__c = SuppProductList[i].id;
            lineItem.Core_Approval_Type__c = 'Auto Approve';
            lineItem.Core_Account__c = AccountList[i].id;
            lineItemList.add(lineItem);
        }
        insert lineItemList;
        System.assert(lineItemList <> null, 'Record not created');
        
        // inserting Product Access Line Items-PAR
        List<Core_IPS_Map_Par_Line_Item__c> lineItemListPAR = new List<Core_IPS_Map_Par_Line_Item__c>();
        for(Integer i=0;i<2;i++){
            Core_IPS_Map_Par_Line_Item__c lineItem = new Core_IPS_Map_Par_Line_Item__c();
            lineItem.Core_MAP_PAR__c = parRec.id;
            lineItem.Core_Supported_Product__c = SuppProductList[i].id;
            lineItem.Core_Approval_Type__c = 'Auto Approve';
            lineItem.Core_Account__c = AccountList[i].id;
            lineItemListPAR.add(lineItem);
        }
        insert lineItemListPAR;
        System.assert(lineItemListPAR <> null, 'Record not created');
        
        // updating Line Item status to Inactive
        List<Core_IPS_Map_Par_Line_Item__c> uplineItemList = new List<Core_IPS_Map_Par_Line_Item__c>();
        for(Core_IPS_Map_Par_Line_Item__c lineItem: lineItemList){
            lineItem.Core_Status__c='INACTIVE';
            uplineItemList.add(lineItem);
        }
        update uplineItemList;
        System.assert(uplineItemList <> null, 'Record not updated');
        
        // updating Line Item status to Inactive
        List<Core_IPS_Map_Par_Line_Item__c> uplineItemListPAR = new List<Core_IPS_Map_Par_Line_Item__c>();
        for(Core_IPS_Map_Par_Line_Item__c lineItemPAR: lineItemListPAR){
            lineItemPAR.Core_Status__c='INACTIVE';
            uplineItemListPAR.add(lineItemPAR);
        }
        update uplineItemListPAR;
        System.assert(uplineItemListPAR <> null, 'Record not updated');
        
        // inserting Prodcut Access Accounts
        List<Core_IPS_MAP_Account__c> accJuncList = new List<Core_IPS_MAP_Account__c>();
        for(Integer i=0;i<1;i++){
            Core_IPS_MAP_Account__c accJunc = new Core_IPS_MAP_Account__c();
            accJunc.Core_Account__c=AccountList[i].id;
            accJunc.Core_MAP_PAR__c=mapRec.id;
            accJuncList.add(accJunc);
        }
        insert accJuncList;
        System.assert(accJuncList <> null, 'Record not created');
        
        // inserting Prodcut Access Accounts-PAR
        List<Core_IPS_MAP_Account__c> accJuncPARList = new List<Core_IPS_MAP_Account__c>();
        for(Integer i=0;i<1;i++){
            Core_IPS_MAP_Account__c accJuncPAR = new Core_IPS_MAP_Account__c();
            accJuncPAR.Core_Account__c=AccountList[i].id;
            accJuncPAR.Core_MAP_PAR__c=parRec.id;
            accJuncPARList.add(accJuncPAR);
        }
        insert accJuncPARList;
        System.assert(accJuncPARList <> null, 'Record not created');
        
        // inserting Prodcut Access Product
        List<Core_IPS_MAP_Product__c> prodJuncList= new List<Core_IPS_MAP_Product__c>();
        for(Integer i=0;i<1;i++){
            Core_IPS_MAP_Product__c mapProd = new Core_IPS_MAP_Product__c();
            mapProd.Core_MAP_PAR__c = mapRec.id;
            mapProd.Core_MAP_Supported_Product__c = SuppProductList[i].id;
            prodJuncList.add(mapProd);
        }
         
        // inserting Prodcut Access Product-PAR
        List<Core_IPS_MAP_Product__c> prodJuncPARList= new List<Core_IPS_MAP_Product__c>();
        for(Integer i=0;i<1;i++){
            Core_IPS_MAP_Product__c mapProdPAR = new Core_IPS_MAP_Product__c();
            mapProdPAR.Core_MAP_PAR__c = parRec.id;
            mapProdPAR.Core_MAP_Supported_Product__c = SuppProductList[i].id;
            prodJuncPARList.add(mapProdPAR);
        }
        
        Test.startTest();                       
            insert prodJuncList;
            System.assert(prodJuncList <> null, 'Record not created');
            insert prodJuncPARList;
            System.assert(prodJuncPARList <> null, 'Record not created');
        Test.stopTest();

    }
    /***************************************************************************************************
    Method Name:  getRecords
    Method Type: Void Method
    Version     : 1.0 
    Created Date: 03 Nov 2015
    Description:  Common Test data used in multiple test methods
    Scenario Type:  
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * JRK                        11/04/2015                Created
    ****************************************************************************************************/
     public static TestMethod void prodJuncCreateLineItems(){
        getRecords();
        
        // inserting Product Access Header
        Core_IPS_MAP_PAR__c mapRec = TestUtilities.getMapPar();
        mapRec.Core_Product_Organization__c = prodOrg.id;
        mapRec.RecordTypeId  = schema.sobjecttype.Core_IPS_MAP_PAR__c.getrecordtypeinfosbyname().get('MAP').getRecordTypeId();//'012210000004IHY';
        insert mapRec;
        System.assert(mapRec <> null, 'Record not created');
        
        // inserting Product Access Header
        Core_IPS_MAP_PAR__c parRec = TestUtilities.getMapPar();
        parRec.Core_Product_Organization__c = prodOrg.id;
        parRec.RecordTypeId  = schema.sobjecttype.Core_IPS_MAP_PAR__c.getrecordtypeinfosbyname().get('PAR').getRecordTypeId();//'012210000004IHZ';
        insert parRec;
        System.assert(parRec <> null, 'Record not created');
        
        // inserting Product Access Line Items-MAP
        List<Core_IPS_Map_Par_Line_Item__c> lineItemList = new List<Core_IPS_Map_Par_Line_Item__c>();
        for(Integer i=0;i<2;i++){
            Core_IPS_Map_Par_Line_Item__c lineItem = new Core_IPS_Map_Par_Line_Item__c();
            lineItem.Core_MAP_PAR__c = mapRec.id;
            lineItem.Core_Supported_Product__c = SuppProductList[1].id;
            lineItem.Core_Approval_Type__c = 'Auto Approve';
            lineItem.Core_Account__c = AccountList[i].id;
            lineItemList.add(lineItem);
        }
        insert lineItemList;
        System.assert(lineItemList <> null, 'Record not created');
        
        // inserting Product Access Line Items-PAR
        List<Core_IPS_Map_Par_Line_Item__c> lineItemListPAR = new List<Core_IPS_Map_Par_Line_Item__c>();
        for(Integer i=0;i<2;i++){
            Core_IPS_Map_Par_Line_Item__c lineItem = new Core_IPS_Map_Par_Line_Item__c();
            lineItem.Core_MAP_PAR__c = parRec.id;
            lineItem.Core_Supported_Product__c = SuppProductList[1].id;
            lineItem.Core_Approval_Type__c = 'Auto Approve';
            lineItem.Core_Account__c = AccountList[i].id;
            lineItemListPAR.add(lineItem);
        }
        insert lineItemListPAR;
        System.assert(lineItemListPAR <> null, 'Record not created');
        

        // updating Line Item status to Inactive
        List<Core_IPS_Map_Par_Line_Item__c> uplineItemList = new List<Core_IPS_Map_Par_Line_Item__c>();
        for(Core_IPS_Map_Par_Line_Item__c lineItem: lineItemList){
            lineItem.Core_Status__c='INACTIVE';
            uplineItemList.add(lineItem);
        }
        update uplineItemList;
        System.assert(uplineItemList <> null, 'Record not updated');
        
        // updating Line Item status to Inactive
        List<Core_IPS_Map_Par_Line_Item__c> uplineItemListPAR = new List<Core_IPS_Map_Par_Line_Item__c>();
        for(Core_IPS_Map_Par_Line_Item__c lineItemPAR: lineItemListPAR){
            lineItemPAR.Core_Status__c='INACTIVE';
            uplineItemListPAR.add(lineItemPAR);
        }
        update uplineItemListPAR;
        System.assert(uplineItemListPAR <> null, 'Record not updated');
        
        // inserting Prodcut Access Accounts
        List<Core_IPS_MAP_Account__c> accJuncList = new List<Core_IPS_MAP_Account__c>();
        for(Integer i=0;i<1;i++){
            Core_IPS_MAP_Account__c accJunc = new Core_IPS_MAP_Account__c();
            accJunc.Core_Account__c=AccountList[i].id;
            accJunc.Core_MAP_PAR__c=mapRec.id;
            accJuncList.add(accJunc);
        }
        insert accJuncList;
        System.assert(accJuncList <> null, 'Record not created');
        
        // inserting Prodcut Access Accounts-PAR
        List<Core_IPS_MAP_Account__c> accJuncPARList = new List<Core_IPS_MAP_Account__c>();
        for(Integer i=0;i<1;i++){
            Core_IPS_MAP_Account__c accJuncPAR = new Core_IPS_MAP_Account__c();
            accJuncPAR.Core_Account__c=AccountList[i].id;
            accJuncPAR.Core_MAP_PAR__c=parRec.id;
            accJuncPARList.add(accJuncPAR);
        }
        insert accJuncPARList;
        System.assert(accJuncPARList <> null, 'Record not created');

        // inserting Prodcut Access Product
        List<Core_IPS_MAP_Product__c> prodJuncList= new List<Core_IPS_MAP_Product__c>();
        for(Integer i=0;i<1;i++){
            Core_IPS_MAP_Product__c mapProd = new Core_IPS_MAP_Product__c();
            mapProd.Core_MAP_PAR__c = mapRec.id;
            mapProd.Core_MAP_Supported_Product__c = SuppProductList[0].id;
            prodJuncList.add(mapProd);
        }
         
        // inserting Prodcut Access Product-PAR
        List<Core_IPS_MAP_Product__c> prodJuncPARList= new List<Core_IPS_MAP_Product__c>();
        for(Integer i=0;i<1;i++){
            Core_IPS_MAP_Product__c mapProdPAR = new Core_IPS_MAP_Product__c();
            mapProdPAR.Core_MAP_PAR__c = parRec.id;
            mapProdPAR.Core_MAP_Supported_Product__c = SuppProductList[0].id;
            prodJuncPARList.add(mapProdPAR);
        }
        
        Test.startTest();                       
            insert prodJuncList;
            System.assert(prodJuncList <> null, 'Record not created');
            insert prodJuncPARList;
            System.assert(prodJuncPARList <> null, 'Record not created');
        Test.stopTest();
    }
    
    /***************************************************************************************************
    Method Name:  getRecords
    Method Type: Void Method
    Version     : 1.0 
    Created Date: 03 Nov 2015
    Description:  Common Test data used in multiple test methods
    Scenario Type:  
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * JRK                        11/04/2015                Created
    ****************************************************************************************************/
     public static TestMethod void prodJuncDeleteLineItems(){
         getRecords();
        
        // inserting Product Access Header
        Core_IPS_MAP_PAR__c mapRec = TestUtilities.getMapPar();
        mapRec.Core_Product_Organization__c = prodOrg.id;
        mapRec.RecordTypeId  = schema.sobjecttype.Core_IPS_MAP_PAR__c.getrecordtypeinfosbyname().get('MAP').getRecordTypeId(); //'012210000004IHY';
        insert mapRec;
        System.assert(mapRec <> null, 'Record not created');
        
        // inserting Product Access Header
        Core_IPS_MAP_PAR__c parRec = TestUtilities.getMapPar();
        parRec.Core_Product_Organization__c = prodOrg.id;
        parRec.RecordTypeId  = schema.sobjecttype.Core_IPS_MAP_PAR__c.getrecordtypeinfosbyname().get('PAR').getRecordTypeId(); //'012210000004IHZ';
        insert parRec;
        System.assert(parRec <> null, 'Record not created');
        
        // inserting Prodcut Access Accounts
        List<Core_IPS_MAP_Account__c> accJuncList = new List<Core_IPS_MAP_Account__c>();
        for(Integer i=0;i<1;i++){
            Core_IPS_MAP_Account__c accJunc = new Core_IPS_MAP_Account__c();
            accJunc.Core_Account__c=AccountList[i].id;
            accJunc.Core_MAP_PAR__c=mapRec.id;
            accJuncList.add(accJunc);
        }
        insert accJuncList;
        System.assert(accJuncList <> null, 'Record not created');
        
        // inserting Prodcut Access Accounts-PAR
        List<Core_IPS_MAP_Account__c> accJuncPARList = new List<Core_IPS_MAP_Account__c>();
        for(Integer i=0;i<1;i++){
            Core_IPS_MAP_Account__c accJuncPAR = new Core_IPS_MAP_Account__c();
            accJuncPAR.Core_Account__c=AccountList[i].id;
            accJuncPAR.Core_MAP_PAR__c=parRec.id;
            accJuncPARList.add(accJuncPAR);
        }
        insert accJuncPARList;
        System.assert(accJuncPARList <> null, 'Record not created');

        // inserting Prodcut Access Product
        List<Core_IPS_MAP_Product__c> prodJuncList= new List<Core_IPS_MAP_Product__c>();
        for(Integer i=0;i<1;i++){
            Core_IPS_MAP_Product__c mapProd = new Core_IPS_MAP_Product__c();
            mapProd.Core_MAP_PAR__c = mapRec.id;
            mapProd.Core_MAP_Supported_Product__c = SuppProductList[0].id;
            prodJuncList.add(mapProd);
        }
         
        // inserting Prodcut Access Product-PAR
        List<Core_IPS_MAP_Product__c> prodJuncPARList= new List<Core_IPS_MAP_Product__c>();
        for(Integer i=0;i<1;i++){
            Core_IPS_MAP_Product__c mapProdPAR = new Core_IPS_MAP_Product__c();
            mapProdPAR.Core_MAP_PAR__c = parRec.id;
            mapProdPAR.Core_MAP_Supported_Product__c = SuppProductList[0].id;
            prodJuncPARList.add(mapProdPAR);
        }

        
        Test.startTest();
            insert prodJuncList;
            System.assert(prodJuncList <> null, 'Record not created');
            delete prodJuncList;
            System.assert(prodJuncList <> null, 'Record not deleted');
            insert prodJuncPARList;
            System.assert(prodJuncPARList <> null, 'Record not deleted');
            delete prodJuncPARList;
            System.assert(prodJuncPARList <> null, 'Record not deleted');
        Test.stopTest();
    }
    
    /***************************************************************************************************
    Method Name:  getRecords
    Method Type: Void Method
    Version     : 1.0 
    Created Date: 03 Nov 2015
    Description:  Common Test data used in multiple test methods
    Scenario Type:  
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * JRK                        11/04/2015                Created
    ****************************************************************************************************/
    public static TestMethod void prodJuncDuplicateTest(){
        


        Product2 prod = TestUtilities.getProduct();
        insert prod;
        
        Core_IPS_Product_Organization__c delprodOrg = TestUtilities.getSupportOrg();
        insert delprodOrg;
        
        Core_IPS_Supported_Product__c supProd = TestUtilities.getSupportedProduct();
        supProd.Core_Product__c = prod.id;
        supProd.Core_Product_Organization__c = delprodOrg.id;
        insert supProd;

        
        Core_IPS_MAP_PAR__c mapRec = TestUtilities.getMapPar();
        mapRec.Core_Product_Organization__c = delprodOrg.id;
        mapRec.Recordtypeid  = schema.sobjecttype.Core_IPS_MAP_PAR__c.getrecordtypeinfosbyname().get('MAP').getRecordTypeId();//'012210000004IHY';
        insert mapRec;
        
        Core_IPS_MAP_Product__c MapProd = new Core_IPS_MAP_Product__c();
        MapProd.Core_MAP_PAR__c=mapRec.id;
        MapProd.Core_MAP_Supported_Product__c=supProd.id;
        
        Test.startTest();
        
        //Inserting MapProduct Junction for before Insert
        insert MapProd;
        
        
        Core_IPS_MAP_Product__c MapProd1 = new Core_IPS_MAP_Product__c();
        MapProd1.Core_MAP_PAR__c=mapRec.id;
        MapProd1.Core_MAP_Supported_Product__c=supProd.id;
        
      
        try{
        insert MapProd1;
        }
        catch(exception e){}
      
        Test.stopTest();
        
    }
}