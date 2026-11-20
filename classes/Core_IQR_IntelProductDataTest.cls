@isTest
global class Core_IQR_IntelProductDataTest {
    
      @isTest static void CoreIQRIntelProductDataTest(){
        Test.startTest();
        
		insertCustomSettings();
        MultiStaticResourceCalloutMock multimock = new MultiStaticResourceCalloutMock();
        multimock.setStaticResource('https://apis.intel.com/v1/auth/token', 'IQR_authtoken');
        multimock.setStaticResource('https://apis-sandbox.intel.com/pim/v1/services/hierarchies?localeGeoId=en-US&hierarchyName=ARK_Hierarchy&limit=1000&offset=1&fields=id,parentId,rawName,name', 'IQR_hierarchies');
        multimock.setStaticResource('https://apis-sandbox.intel.com/pim/v1/services/products?localeGeoId=en-US&limit=1000&categoryId=35125,36773&offset=1', 'IQR_products');
        multimock.setStaticResource('https://apis-sandbox.intel.com/pim/v1/services/products?localeGeoId=en-US&limit=1000&categoryId=35125,36773&offset=2', 'IQR_products');
        multimock.setStaticResource('https://apis-sandbox.intel.com/pim/v1/services/products?localeGeoId=en-US&limit=1000&categoryId=35125,36773&offset=3', 'IQR_products');
        multimock.setStaticResource('https://apis-sandbox.intel.com/pim/v1/services/products?localeGeoId=en-US&limit=1000&categoryId=35125,36773&offset=4', 'IQR_products');
        multimock.setStaticResource('https://apis-sandbox.intel.com/pim/v1/services/products/120487?localeGeoId=en-US', 'IQR_productsId');
        multimock.setStaticResource('https://apis-sandbox.intel.com/pim/v1/services/products/125900?localeGeoId=en-US', 'IQR_productsId2');
        multimock.setStatusCode(200);
        multimock.setHeader('Content-Type', 'application/json');
        
        // Set the mock callout mode
        Test.setMock(HttpCalloutMock.class, multimock);
        
        // Call the method for the first endpoint
        HTTPResponse res = getInfoFromExternalService('https://apis.intel.com/v1/auth/token');
        HTTPResponse res2 = getInfoFromExternalService('https://apis-sandbox.intel.com/pim/v1/services/hierarchies?localeGeoId=en-US&hierarchyName=ARK_Hierarchy&limit=1000&offset=1&fields=id,parentId,rawName,name');
        HTTPResponse res3 = getInfoFromExternalService('https://apis-sandbox.intel.com/pim/v1/services/products?localeGeoId=en-US&limit=1000&categoryId=35125,36773&offset=1');
        HTTPResponse res4 = getInfoFromExternalService('https://apis-sandbox.intel.com/pim/v1/services/products?localeGeoId=en-US&limit=1000&categoryId=35125,36773&offset=2');
        HTTPResponse res5 = getInfoFromExternalService('https://apis-sandbox.intel.com/pim/v1/services/products?localeGeoId=en-US&limit=1000&categoryId=35125,36773&offset=3');
        HTTPResponse res6 = getInfoFromExternalService('https://apis-sandbox.intel.com/pim/v1/services/products?localeGeoId=en-US&limit=1000&categoryId=35125,36773&offset=4');
        HTTPResponse res7 = getInfoFromExternalService('https://apis-sandbox.intel.com/pim/v1/services/products/120487?localeGeoId=en-US');
        HTTPResponse res8 = getInfoFromExternalService('https://apis-sandbox.intel.com/pim/v1/services/products/125900?localeGeoId=en-US');
        
        //insert endPointList;
        Database.executeBatch(new Core_IQR_IntelProductData());
          Core_IQR_IntelProductDataScheduler.Core_IQR_IntelProductDataScheduler();
          recordInsertSetUp();
            Test.stopTest();
    }
    
    public static HttpResponse getInfoFromExternalService(String endpoint) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('GET');
        Http h = new Http();
        HttpResponse res = h.send(req);
        system.debug('httpMock:'+res);
        return res;
    }
    
    @future
    public static void insertCustomSettings(){
        List<Core_IQR_Endpoints__c> endPointList = new List<Core_IQR_Endpoints__c>();
        Core_IQR_Endpoints__c e1 = new Core_IQR_Endpoints__c();
        e1.name = 'authtoken';
        e1.Endpoint__c='client_id=ec3dc7a0-5f81-4846-8b34-d288386dc520&client_secret=6Cr7Q~j1Zbsw3psK8K_xlqcSll7CZlx0n7a7l&grant_type=client_credentials';
        
        Core_IQR_Endpoints__c e2 = new Core_IQR_Endpoints__c();
        e2.name = 'authtokenURL';
        e2.Endpoint__c='https://apis.intel.com/v1/auth/token';
        
        Core_IQR_Endpoints__c e3 = new Core_IQR_Endpoints__c();
        e3.name = 'hierarchies';
        e3.Endpoint__c='https://apis-sandbox.intel.com/pim/v1/services/hierarchies?localeGeoId=en-US&hierarchyName=ARK_Hierarchy&limit=1000&offset=1&fields=id,parentId,rawName,name';
        
        Core_IQR_Endpoints__c e4 = new Core_IQR_Endpoints__c();
        e4.name = 'products';
        e4.Endpoint__c='https://apis-sandbox.intel.com/pim/v1/services/products?localeGeoId=en-US&limit=1000';
        
        Core_IQR_Endpoints__c e5 = new Core_IQR_Endpoints__c();
        e5.name = 'products_id';
        e5.Endpoint__c='https://apis-sandbox.intel.com/pim/v1/services/products/';
        
        endPointList.add(e1);
        endPointList.add(e2);
        endPointList.add(e3);
        endPointList.add(e4);
        endPointList.add(e5);
        
        insert endPointList;
        
        Product2 p = new Product2();
        p.Name='Intel® Xeon® Gold 6142 Processor (22M Cache, 2.60 GHz)';
        p.Core_Product_Org__c = 'Sales';
        p.Core_Unique_ID__c='120458;122573;122570;86065;35125';
        p.Core_Product_Name_EPM_ID__c='120458';
        p.isActive=True;
        insert p;
        
        Product2 p1 = new Product2();
        p1.Name='Intel® Xeon® Gold 6142 Processor (22M Cache, 2.60 GHz)1';
        p1.Core_Product_Org__c = 'IPS';
        p1.Core_Unique_ID__c='123808;122573;122570;86065;35125';
        p1.Core_Product_Name_EPM_ID__c='123808';
        p1.isActive=True;
        insert p1;
        
        Product2 p2 = new Product2();
        p2.Name='Intel® Xeon® Gold 6142 Processor (22M Cache, 2.60 GHz)1';
        p2.Core_Product_Org__c = 'Sales';
        p2.Core_Unique_ID__c='1239292929;122573;122570;86065;35125';
        p2.Core_Product_Name_EPM_ID__c='1239292929';
        p2.isActive=True;
        insert p2;
        
         Product2 p3 = new Product2();
        p3.Name='Intel® Xeon® Gold 6142 Processor (22M Cache, 2.60 GHz)1';
        p3.Core_Product_Org__c = 'Sales';
        p3.Core_Unique_ID__c='1239292929;122573;122570;86065;35125';
        p3.Core_Product_Name_EPM_ID__c='1239292929';
        p3.isActive=True;
        p3.Core_Hierarchy_Name__c ='Valid Product Hierarchy';
        p3.Core_Hierarchy_ID__c = '43';
        insert p3;
       
        
        Core_IQR_Products_Staging__c stagingRec = new Core_IQR_Products_Staging__c();
        stagingRec.Core_Product_Name_EPM_ID__c = '12345';
        stagingRec.Core_IsLatest__c=True;
        stagingRec.Core_BU_Operation_Code__c = 'HJ';
        stagingRec.Core_Code_Name__c = 'Code';
        stagingRec.Core_Code_Name_EPM_ID__c = '1234';
        stagingRec.Core_Division_Code__c='8787';
        stagingRec.Core_Division_Code_Short_Name__c='er';
        stagingRec.Core_Family_Nm__c='Intel';
        stagingRec.Core_Group_Code__c='ER';
        stagingRec.Core_Group_Code_Short_Name__c='UI';
        stagingRec.Core_Is_Custom_Ind__c='N';
        stagingRec.Core_Is_IQR_Visible__c=true;
        stagingRec.Core_IsActive__c = true;
        stagingRec.Core_IsLatest__c = true;
        stagingRec.Core_Item_Id__c='98787';
        stagingRec.Core_Mem_Amt__c='45';
        stagingRec.Core_Processing_Status__c='New';
        stagingRec.Core_Product_Name__c='Intel Optane';
        stagingRec.Core_Product_Family__c='Intel';
        stagingRec.Core_Product_Family_EPM_ID__c='35124';
        stagingRec.Core_Product_Series__c='Series';
        stagingRec.Core_Product_Group_EPM_ID__c='786';
        stagingRec.Core_Product_Type_EPM_ID__c='980';
        stagingRec.Core_Product_Series_EPM_ID__c='098';
        stagingRec.Core_Product_Type__c='Memory and Storage';
        stagingRec.Core_Product_Group__c='Intel Group';
        stagingRec.Core_Processor_Number_Nm__c='123';
        stagingRec.Core_Product_Status__c='AC';
        stagingRec.Core_Family_Nm__c ='Xeon';
        stagingRec.Core_Forecast_Product_Name__c='Xeon Optane';
        stagingRec.Core_Mem_Amt__c ='56';
        
        stagingRec.Core_Unique_ID__c ='1239292929;122573;122570;86065;35125';
        insert stagingRec;
        
        Product2 p4 = new Product2();
        p4.Id=p3.Id;
        p4.Name='Intel® Xeon® Gold 6142 Processor (22M Cache, 2.60 GHz)120';
        p4.Core_Product_Name_EPM_ID__c=stagingRec.Core_Product_Name_EPM_ID__c;
       
        p4.Core_BU_Operation_Code__c=stagingRec.Core_BU_Operation_Code__c;
        p4.Core_Code_Name__c=stagingRec.Core_Code_Name__c;
        p4.Core_Code_Name_EPM_ID__c=stagingRec.Core_Code_Name_EPM_ID__c;
        p4.Core_Division_Code__c=stagingRec.Core_Division_Code__c;
        p4.Core_Division_Code_Short_Name__c=stagingRec.Core_Division_Code_Short_Name__c;
        p4.Core_Family_Nm__c=stagingRec.Core_Family_Nm__c;
        p4.Core_Group_Code__c=stagingRec.Core_Group_Code__c;
        p4.Core_Group_Code_Short_Name__c=stagingRec.Core_Group_Code_Short_Name__c;
        p4.Core_Is_Custom_Ind__c=stagingRec.Core_Is_Custom_Ind__c;
        p4.Core_IQR_Visible__c=stagingRec.Core_Is_IQR_Visible__c;
        p4.IsActive=stagingRec.Core_IsActive__c;
      
        p4.Core_Item_Id__c=stagingRec.Core_Item_Id__c;
        p4.Core_Mem_Amt__c=stagingRec.Core_Mem_Amt__c;
        
        p4.Name=stagingRec.Core_Product_Name__c;
        p4.Core_Product_Family__c=stagingRec.Core_Product_Family__c;
        p4.Core_Product_Family_EPM_ID__c=stagingRec.Core_Product_Family_EPM_ID__c;
        p4.Core_Product_Series__c=stagingRec.Core_Product_Series__c;
        p4.Core_Product_Group_EPM_ID__c=stagingRec.Core_Product_Group_EPM_ID__c;
        p4.Core_Product_Type_EPM_ID__c=stagingRec.Core_Product_Type_EPM_ID__c;
        p4.Core_Product_Series_EPM_ID__c=stagingRec.Core_Product_Series_EPM_ID__c;
        p4.Core_Product_Type__c=stagingRec.Core_Product_Type__c;
        p4.Core_Product_Group__c=stagingRec.Core_Product_Group__c;
        p4.Core_Processor_Number_Nm__c=stagingRec.Core_Processor_Number_Nm__c;
        p4.Core_Product_Status__c=stagingRec.Core_Product_Status__c;
        p4.Core_Family_Nm__c=stagingRec.Core_Family_Nm__c;
        p4.Core_Forecast_Product_Name__c=stagingRec.Core_Forecast_Product_Name__c;
        p4.Core_Mem_Amt__c=stagingRec.Core_Mem_Amt__c;
        
        p4.Core_Unique_ID__c=stagingRec.Core_Unique_ID__c;
        p4.Core_Hierarchy_Name__c ='Valid Product Hierarchy';
        p4.Core_Hierarchy_ID__c = '43';
        update p4;
        
        
    }
    
    public static void recordInsertSetUp(){
        List<Core_IQR_Endpoints__c> endPointList = new List<Core_IQR_Endpoints__c>();
        Core_IQR_Endpoints__c e1 = new Core_IQR_Endpoints__c();
        e1.name = 'authtoken';
        e1.Endpoint__c='client_id=ec3dc7a0-5f81-4846-8b34-d288386dc520&client_secret=6Cr7Q~j1Zbsw3psK8K_xlqcSll7CZlx0n7a7l&grant_type=client_credentials';
        
        Core_IQR_Endpoints__c e2 = new Core_IQR_Endpoints__c();
        e2.name = 'authtokenURL';
        e2.Endpoint__c='https://apis.intel.com/v1/auth/token';
        
        Core_IQR_Endpoints__c e3 = new Core_IQR_Endpoints__c();
        e3.name = 'hierarchies';
        e3.Endpoint__c='https://apis-sandbox.intel.com/pim/v1/services/hierarchies?localeGeoId=en-US&hierarchyName=ARK_Hierarchy&limit=1000&offset=1&fields=id,parentId,rawName,name';
        
        Core_IQR_Endpoints__c e4 = new Core_IQR_Endpoints__c();
        e4.name = 'products';
        e4.Endpoint__c='https://apis-sandbox.intel.com/pim/v1/services/products?localeGeoId=en-US&limit=1000';
        
        Core_IQR_Endpoints__c e5 = new Core_IQR_Endpoints__c();
        e5.name = 'products_id';
        e5.Endpoint__c='https://apis-sandbox.intel.com/pim/v1/services/products/';
        
        endPointList.add(e1);
        endPointList.add(e2);
        endPointList.add(e3);
        endPointList.add(e4);
        endPointList.add(e5);
        
        insert endPointList;
        
        Product2 p = new Product2();
        p.Name='Intel® Xeon® Gold 6142 Processor (22M Cache, 2.60 GHz)';
        p.Core_Product_Org__c = 'Sales';
        p.Core_Unique_ID__c='120458;122573;122570;86065;35125';
        p.Core_Product_Name_EPM_ID__c='120458';
        p.isActive=True;
        insert p;
        
        Product2 p1 = new Product2();
        p1.Name='Intel® Xeon® Gold 6142 Processor (22M Cache, 2.60 GHz)1';
        p1.Core_Product_Org__c = 'IPS';
        p1.Core_Unique_ID__c='123808;122573;122570;86065;35125';
        p1.Core_Product_Name_EPM_ID__c='123808';
        p1.isActive=True;
        insert p1;
        
        Product2 p2 = new Product2();
        p2.Name='Intel® Xeon® Gold 6142 Processor (22M Cache, 2.60 GHz)1';
        p2.Core_Product_Org__c = 'Sales';
        p2.Core_Unique_ID__c='1239292929;122573;122570;86065;35125';
        p2.Core_Product_Name_EPM_ID__c='1239292929';
        p2.isActive=True;
        insert p2;
        
         Product2 p3 = new Product2();
        p3.Name='Intel® Xeon® Gold 6142 Processor (22M Cache, 2.60 GHz)1';
        p3.Core_Product_Org__c = 'Sales';
        p3.Core_Unique_ID__c='1239292929;122573;122570;86065;35125';
        p3.Core_Product_Name_EPM_ID__c='1239292929';
        p3.isActive=True;
        p3.Core_Hierarchy_Name__c ='Valid Product Hierarchy';
        p3.Core_Hierarchy_ID__c = '43';
        insert p3;
       
        
        Core_IQR_Products_Staging__c stagingRec = new Core_IQR_Products_Staging__c();
        stagingRec.Core_Product_Name_EPM_ID__c = '12345989898';
        stagingRec.Core_IsLatest__c=True;
        stagingRec.Core_BU_Operation_Code__c = 'HJ';
        stagingRec.Core_Code_Name__c = 'Code';
        stagingRec.Core_Code_Name_EPM_ID__c = '1234';
        stagingRec.Core_Division_Code__c='8787';
        stagingRec.Core_Division_Code_Short_Name__c='er';
        stagingRec.Core_Family_Nm__c='Intel';
        stagingRec.Core_Group_Code__c='ER';
        stagingRec.Core_Group_Code_Short_Name__c='UI';
        stagingRec.Core_Is_Custom_Ind__c='N';
        stagingRec.Core_Is_IQR_Visible__c=true;
        stagingRec.Core_IsActive__c = true;
        stagingRec.Core_IsLatest__c = true;
        stagingRec.Core_Item_Id__c='98787';
        stagingRec.Core_Mem_Amt__c='45';
        stagingRec.Core_Processing_Status__c='New';
        stagingRec.Core_Product_Name__c='Intel Optane';
        stagingRec.Core_Product_Family__c='Intel';
        stagingRec.Core_Product_Family_EPM_ID__c='35124';
        stagingRec.Core_Product_Series__c='Series';
        stagingRec.Core_Product_Group_EPM_ID__c='786';
        stagingRec.Core_Product_Type_EPM_ID__c='980';
        stagingRec.Core_Product_Series_EPM_ID__c='098';
        stagingRec.Core_Product_Type__c='Memory and Storage';
        stagingRec.Core_Product_Group__c='Intel Group';
        stagingRec.Core_Processor_Number_Nm__c='123';
        stagingRec.Core_Product_Status__c='AC';
        stagingRec.Core_Family_Nm__c ='Xeon';
        stagingRec.Core_Forecast_Product_Name__c='Xeon Optane';
        stagingRec.Core_Mem_Amt__c ='56';
        
        stagingRec.Core_Unique_ID__c ='1239292929;122573;122570;86065;35125';
        insert stagingRec;
        
        Product2 p4 = new Product2();
        p4.Id=p3.Id;
        p4.Name='Intel® Xeon® Gold 6142 Processor (22M Cache, 2.60 GHz)120';
        p4.Core_Product_Name_EPM_ID__c='65';
       
        p4.Core_BU_Operation_Code__c=stagingRec.Core_BU_Operation_Code__c;
        p4.Core_Code_Name__c=stagingRec.Core_Code_Name__c;
        p4.Core_Code_Name_EPM_ID__c=stagingRec.Core_Code_Name_EPM_ID__c;
        p4.Core_Division_Code__c=stagingRec.Core_Division_Code__c;
        p4.Core_Division_Code_Short_Name__c=stagingRec.Core_Division_Code_Short_Name__c;
        p4.Core_Family_Nm__c=stagingRec.Core_Family_Nm__c;
        p4.Core_Group_Code__c=stagingRec.Core_Group_Code__c;
        p4.Core_Group_Code_Short_Name__c=stagingRec.Core_Group_Code_Short_Name__c;
        p4.Core_Is_Custom_Ind__c=stagingRec.Core_Is_Custom_Ind__c;
        p4.Core_IQR_Visible__c=stagingRec.Core_Is_IQR_Visible__c;
        p4.IsActive=stagingRec.Core_IsActive__c;
      
        p4.Core_Item_Id__c=stagingRec.Core_Item_Id__c;
        p4.Core_Mem_Amt__c=stagingRec.Core_Mem_Amt__c;
        
        p4.Name=stagingRec.Core_Product_Name__c;
        p4.Core_Product_Family__c=stagingRec.Core_Product_Family__c;
        p4.Core_Product_Family_EPM_ID__c=stagingRec.Core_Product_Family_EPM_ID__c;
        p4.Core_Product_Series__c=stagingRec.Core_Product_Series__c;
        p4.Core_Product_Group_EPM_ID__c=stagingRec.Core_Product_Group_EPM_ID__c;
        p4.Core_Product_Type_EPM_ID__c=stagingRec.Core_Product_Type_EPM_ID__c;
        p4.Core_Product_Series_EPM_ID__c=stagingRec.Core_Product_Series_EPM_ID__c;
        p4.Core_Product_Type__c=stagingRec.Core_Product_Type__c;
        p4.Core_Product_Group__c=stagingRec.Core_Product_Group__c;
        p4.Core_Processor_Number_Nm__c=stagingRec.Core_Processor_Number_Nm__c;
        p4.Core_Product_Status__c=stagingRec.Core_Product_Status__c;
        p4.Core_Family_Nm__c=stagingRec.Core_Family_Nm__c;
        p4.Core_Forecast_Product_Name__c=stagingRec.Core_Forecast_Product_Name__c;
        p4.Core_Mem_Amt__c=stagingRec.Core_Mem_Amt__c;
        
        p4.Core_Unique_ID__c=stagingRec.Core_Unique_ID__c;
        p4.Core_Hierarchy_Name__c ='Valid Product Hierarchy';
        p4.Core_Hierarchy_ID__c = '43';
        update p4;
         
       
        
    }
    


}