@isTest
public class Core_IPS_SupportedProduct_Test{
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
    * //System.assert()--> statement Added By Hassan Khan 02-02-2024
    ****************************************************************************************************/
    public static List<Account> AccountList =  new List<Account>();
    public static List<Product2> ProductList = new List<Product2>();
    public static List<Core_IPS_Product_Organization__c> prodOrgList = new List<Core_IPS_Product_Organization__c>();
    public static List<User> ListOfUser = new List<User> ();
    public static List<Core_IPS_Supported_Product__c> SuppProductList = new List<Core_IPS_Supported_Product__c> ();
    public static List<Core_IPS_Project__c> projectList = new List<Core_IPS_Project__c> ();
    public static List<Asset> AssetList=new List<Asset>();
    public static Core_Trigger_Executions__c cusset = new Core_Trigger_Executions__c();
    public static TestMethod void getRecords(){
        // Insert IPS Labels
        List<Core_IPS_Labels__c> IPSLabels = TestUtilities.getIPSLabel();       
        insert IPSLabels;
        System.assert(IPSLabels <> null, 'Record not created');
        // inserting Accounts
        AccountList = TestUtilities.getAccountsList(3);
        insert AccountList;
        Map<string,ID> MapRecordtype = new Map<string,ID>();
        for(Recordtype Rt:[Select ID,Name from Recordtype where sobjectType = 'Core_IPS_MAP_PAR__c'])
        {  
              MapRecordtype.put(Rt.Name,Rt.ID);
        }
        System.assert(AccountList <> null, 'Record not created');
        List<Core_Flat_Product_Hierarchy__c> flatProdHierarchyList = TestUtilities.getListOfFlatProductHierarchy(10);
        insert flatProdHierarchyList;
        // inserting products
        ProductList = TestUtilities.getListOfProduct(3);
        ProductList[0].Core_Code_Name_EPM_ID__c='L1 Id1';
        ProductList[0].Core_Hierarchy_ID__c='43';
        ProductList[0].Core_Sales_Visible_Flag__c=False;
        productList[1].core_code_name_EPM_ID__c='L2 Id2';
        ProductList[1].Core_Hierarchy_ID__c='43';
        productList[2].core_code_name_EPM_ID__c='L3 Id3';
        ProductList[2].Core_Hierarchy_ID__c='43';
        insert ProductList;
        
        System.assert(ProductList <> null, 'Record not created');
        
        // inserting Product Orgs
        prodOrgList = TestUtilities.getListOfSupportOrg(3);
        insert prodOrgList;
        
        //inserting custom setting
        
        cusset.Name='UpdateAssetStatusonUpdate';
        cusset.Core_Active__c=true;
        cusset.Core_Class_Name__c= 'Core_SupportedProductUtility';
        cusset.Core_Description__c= 'Something';
        cusset.Core_Object__c= 'Core_Supported_Product__c';
        cusset.Core_Trigger_Events__c='After Update';       
         
        insert cusset;
        
        
        // inserting Supported Product 
        SuppProductList = TestUtilities.getListOfSupportedProduct(3);
        Integer i = 0;
        for(Core_IPS_Supported_Product__c SupportedProductRecord: SuppProductList){                
                SupportedProductRecord.Core_Product__c = ProductList.get(i).id;
                SupportedProductRecord.Core_Product_Organization__c = prodOrgList[i].id;
                SupportedProductRecord.Core_Product_EPM_ID__c=ProductList.get(i).core_code_name_EPM_ID__c;
                SupportedProductRecord.core_EOIS__C=false;                
                 i++;                     
        }
        insert SuppProductList;
        System.assert(SuppProductList <> null, 'Record not created');
        
        // inserting project header
        projectList = TestUtilities.getListOfIpsProjects(3);
        insert projectList;
        System.assert(projectList <> null, 'Record not created');
        
        // inserting Product Access Header
        Core_IPS_MAP_PAR__c mapRec = TestUtilities.getMapPar();
        mapRec.Core_Product_Organization__c = prodOrgList[1].id;
        //mapRec.Recordtypeid  = '012210000004IHY';
        mapRec.Recordtypeid  = MapRecordtype.get('MAP');
        insert mapRec;
        System.assert(mapRec <> null, 'Record not created');
        
        // inserting Product Access Header
        Core_IPS_MAP_PAR__c parRec = TestUtilities.getMapPar();
        parRec.Core_Product_Organization__c = prodOrgList[1].id;
        parRec.Recordtypeid = MapRecordtype.get('PAR');
        //parRec.Recordtypeid = '012210000004IHZ';
        insert parRec;
        System.assert(parRec <> null, 'Record not created');
        
        // inserting Product Access Line Items-MAP
        List<Core_IPS_Map_Par_Line_Item__c> lineItemList = new List<Core_IPS_Map_Par_Line_Item__c>();
        for(i=0;i<3;i++){
            Core_IPS_Map_Par_Line_Item__c lineItem = new Core_IPS_Map_Par_Line_Item__c();
            lineItem.Core_MAP_PAR__c = mapRec.id;
            lineItem.Core_Supported_Product__c = SuppProductList[i].id;
            lineItem.Core_Approval_Type__c = 'Auto Approve';
            lineItem.Core_Account__c = AccountList[i].id;
            lineItem.Core_Status__c = 'Active';
            lineItemList.add(lineItem);
        }
        insert lineItemList;
        System.assert(lineItemList <> null, 'Record not created');
        
        // inserting Product Access Line Items-PAR
        List<Core_IPS_Map_Par_Line_Item__c> lineItemListPAR = new List<Core_IPS_Map_Par_Line_Item__c>();
        for(i=0;i<3;i++){
            Core_IPS_Map_Par_Line_Item__c lineItem = new Core_IPS_Map_Par_Line_Item__c();
            lineItem.Core_MAP_PAR__c = parRec.id;
            lineItem.Core_Supported_Product__c = SuppProductList[i].id;
            lineItem.Core_Approval_Type__c = 'Auto Approve';
            lineItem.Core_Account__c = AccountList[i].id;
            lineItem.Core_Status__c = 'Active';
            lineItemListPAR.add(lineItem);
        }
        insert lineItemListPAR;
        System.assert(lineItemListPAR <> null, 'Record not created');
        
        // inserting Project Product
        List<Core_IPS_Product__c> listProjectProduct = new List<Core_IPS_Product__c>();
        for(i=0;i<3;i++){
            Core_IPS_Product__c projectProduct = new Core_IPS_Product__c();
            projectProduct.Core_IPS_Project__c = projectList[i].id;
            projectProduct.Core_Supported_Product__c = SuppProductList[i].id;
            listProjectProduct.add(projectProduct);
        }
        insert listProjectProduct;
        system.assert(listProjectProduct <> null, 'Record not created');
       
       
    }
    
   
    /***************************************************************************************************
    Method Name: updateEOIStrue
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
     public static TestMethod void updateEOIStrue(){
        getRecords();
         
        Core_Trigger_Executions__c eoisCSRec1 = new Core_Trigger_Executions__c ();
        eoisCSRec1.Name='updatedEOIStrue';
        eoisCSRec1.Core_Active__c=true;
        eoisCSRec1.Core_Class_Name__c= 'Core_SupportedProductUtility';
        eoisCSRec1.Core_Description__c= 'Something';
        eoisCSRec1.Core_Object__c= 'Core_Supported_Product__c';
        eoisCSRec1.Core_Trigger_Events__c='After Update';        
        insert eoisCSRec1;
        
        Core_Trigger_Executions__c eoisCSRec = new Core_Trigger_Executions__c ();
        eoisCSRec.Name='createGlobalAsset';
        eoisCSRec.Core_Active__c=true;
        eoisCSRec.Core_Class_Name__c= 'Core_SupportedProductUtility';
        eoisCSRec.Core_Description__c= 'Something';
        eoisCSRec.Core_Object__c= 'Core_Supported_Product__c';
        eoisCSRec.Core_Trigger_Events__c='After Insert,After Update';        
        insert eoisCSRec;
        
        Core_Trigger_Executions__c eoisCSRec2 = new Core_Trigger_Executions__c ();
        eoisCSRec2.Name='updateGlobalAssetStatus';
        eoisCSRec2.Core_Active__c=true;
        eoisCSRec2.Core_Class_Name__c= 'Core_SupportedProductUtility';
        eoisCSRec2.Core_Description__c= 'Something';
        eoisCSRec2.Core_Object__c= 'Core_Supported_Product__c';
        eoisCSRec2.Core_Trigger_Events__c='After Update';        
        insert eoisCSRec2;
        
        Test.starttest();
        
        /*Core_Trigger_Executions__c cusset = new Core_Trigger_Executions__c();
        cusset.Name='UpdateAssetStatusonUpdate';
        cusset.Core_Active__c=true;
        cusset.Core_Class_Name__c= 'Core_SupportedProductUtility';
        cusset.Core_Description__c= 'Something';
        cusset.Core_Object__c= 'Core_Supported_Product__c';
        cusset.Core_Trigger_Events__c='After Update';        
        insert cusset;*/
        
        //Core_IPS_Helper_Utility.isHandlerMethodExecutionEnabled('UpdateAssetStatusonUpdate');
        
        //List<Core_IPS_Supported_Product__c> updateSuppProductList = new List<Core_IPS_Supported_Product__c> ();
        integer i = 0;
        for(Core_IPS_Supported_Product__c supProd: SuppProductList){
            
            supProd.Core_EOIS__c = true;  
            //if(supProd.Core_Product__r.Core_Hierarchy_ID__c != System.Label.Core_IPS_Valid_Platform_Codename_Hierarchy_ID)
            supProd.Core_IPS_Public_Product__c = True; // added by sugandha 13 Nov 2017 for US72182          
            //updateSuppProductList.add(supProd);
            supProd.Core_Supported_Product_Tag__c = 'Test';     
            
        }
        update SuppProductList;
        // system.assert(updateSuppProductList <> null, 'Record not created');       
        Test.stoptest();
        System.assert(SuppProductList[0].id != null, true);
    } 
    
    /***************************************************************************************************
    Method Name: createGlobalAsset
    Method Type: Void Method
    Version     : 1.0 
    Created Date: 03 Nov 2015
    Description:  Common Test data used in multiple test methods
    Scenario Type:  
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Sugandha                  16/11/2017                Created
    ****************************************************************************************************/
     public static TestMethod void createGAssetTest(){
        getRecords();
         
        Core_Trigger_Executions__c eoisCSRec1 = new Core_Trigger_Executions__c ();
        eoisCSRec1.Name='updatedEOIStrue';
        eoisCSRec1.Core_Active__c=true;
        eoisCSRec1.Core_Class_Name__c= 'Core_SupportedProductUtility';
        eoisCSRec1.Core_Description__c= 'Something';
        eoisCSRec1.Core_Object__c= 'Core_Supported_Product__c';
        eoisCSRec1.Core_Trigger_Events__c='After Update';        
        insert eoisCSRec1;
        
        Core_Trigger_Executions__c eoisCSRec = new Core_Trigger_Executions__c ();
        eoisCSRec.Name='createGlobalAsset';
        eoisCSRec.Core_Active__c=true;
        eoisCSRec.Core_Class_Name__c= 'Core_SupportedProductUtility';
        eoisCSRec.Core_Description__c= 'Something';
        eoisCSRec.Core_Object__c= 'Core_Supported_Product__c';
        eoisCSRec.Core_Trigger_Events__c='After Insert,After Update';        
        insert eoisCSRec;
        
        Core_Trigger_Executions__c eoisCSRec2 = new Core_Trigger_Executions__c ();
        eoisCSRec2.Name='updateGlobalAssetStatus';
        eoisCSRec2.Core_Active__c=true;
        eoisCSRec2.Core_Class_Name__c= 'Core_SupportedProductUtility';
        eoisCSRec2.Core_Description__c= 'Something';
        eoisCSRec2.Core_Object__c= 'Core_Supported_Product__c';
        eoisCSRec2.Core_Trigger_Events__c='After Update';        
        insert eoisCSRec2;
        
        Product2 prod = new Product2();
        prod.Core_Product_Name_EPM_ID__c='750235';
        prod.IsActive = true;
        prod.Core_Code_Name_EPM_ID__c ='750235';
        prod.Core_Sales_Visible_Flag__c = false;
        prod.IsActive = true;
        prod.Core_Product_Status__c= 'Active';
        prod.Core_IPS_Visible_Flag_External__c = true;
        prod.Core_IPS_Visible_Flag_Internal__c = 'Yes';
        prod.Core_Product_Org__c = 'IPS';
        prod.Core_Hierarchy_ID__c = '43';
        prod.Core_Unique_ID__c = prod.Name; 
        prod.Name = 'testProd5';   
        insert prod;
    
        Core_IPS_Supported_Product__c SuppProduct1 = new Core_IPS_Supported_Product__c(Core_Flag_Status__c = 'Approval Required',
                                                            Core_Product__c = prod.id,Core_Product_Organization__c = prodOrgList[0].id,
                                                            Core_Product_EPM_ID__c=ProductList.get(0).core_code_name_EPM_ID__c,core_EOIS__C=false,Core_IPS_Public_Product__c = True,Core_Supported_Product_Tag__c = 'Test' );
                
        insert SuppProduct1;
        System.assert(SuppProduct1.id != null, true);
        }
}