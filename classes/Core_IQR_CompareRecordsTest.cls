@isTest
public class Core_IQR_CompareRecordsTest {
    
    @testSetup static void setup(){
        insertCustomSettings();
        Product2 product2Obj = new Product2 (
            Core_Product_Name_EPM_ID__c = 'test value', 
            Core_Product_Org__c ='Sales', 
            Core_Sales_Visible_Flag__c = TRUE, 
            Core_Max_TDP__c = 'test value', 
            Core_CoreCount__c = 'test value', 
            Name = 'test value'
        );
        insert product2Obj;
        
    }
    
    @isTest static void testMethod2() {
        Test.startTest(); 
      
         List<Product2> products= new List<Product2>();
        products=  [Select id,Core_Is_Custom_Ind__c, Core_Mem_Amt__c, Core_Hierarchy_ID__c, Core_Hierarchy_Name__c, Core_Product_Type_EPM_ID__c,Core_Product_Type__c,Core_Product_Family_EPM_ID__c,Core_Product_Family__c,Core_Product_Series_EPM_ID__c,Core_Product_Series__c,Core_Product_Group_EPM_ID__c,Core_Product_Group__c,Core_Code_Name_EPM_ID__c,Core_Code_Name__c,Core_Processor_Number_Ta_Nm__c, Core_Processor_Number_Nm__c,Core_Product_Status__c,Core_Item_Id__c,Core_Division_Code_Short_Name__c,Core_Division_Code__c,Core_Group_Code_Short_Name__c,Core_Group_Code__c,Core_Product_Name_EPM_ID__c,Core_BU_Operation_Code__c,Core_Unique_ID__c,Core_Family_Nm__c,Core_Forecast_Product_Name__c from Product2 where isActive=True and Core_IQR_Visible__c=True and Core_Product_Org__c='Sales' and Core_Hierarchy_ID__c = '43' and Core_Hierarchy_Name__c = 'Valid Product Hierarchy' and Core_Product_Name_EPM_ID__c!=null];
        
        system.debug('products cnt-----'+ products.size());
        Core_IQR_CompareRecords cr = New Core_IQR_CompareRecords();

        Database.QueryLocator ql = cr.start(null);
        cr.execute(null,products);
        cr.Finish(null);
       
        
      //  Database.executeBatch(new Core_IQR_CompareRecords()); 
        Core_IQR_CompareRecordsScheduler.Core_IQR_CompareRecordsScheduler();
        
        Test.stopTest();
    }  

    
      

    @istest static void executeMethodTest() {
        Test.startTest(); 
        List<Core_Log_Entry__c> captureQueryErr = new List<Core_Log_Entry__c>();
        try
        {
            Id jobId=Database.executeBatch(new Core_IQR_PIM_IntelProductData());
        }
        catch(Exception e){
            captureQueryErr.add(new Core_Log_Entry__c(Core_Details__c = 'Exception    '+ e.getMessage() + e.getStackTraceString() , Core_Message__c = 'PIM products update MaxTDP and CoreCount ', Core_Severity__c = 'High',Core_Project__c='IQR', Core_Origin__c='Core_IQR_PIM_IntelProductData', Core_When__c = System.now()));
        }
        finally {
            
        }
        Test.stopTest();
    }
   
    
    @isTest static void Core_IQR_PIM_IntelProductDataTest200(){
        Test.startTest(); 
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        HTTPResponse res1 = getInfoFromExternalService('https://apis-sandbox.intel.com/pim/v1/services/products?localeGeoId=en-US&categoryId=873&includeAttributes=true&limit=1&offset=1');
        StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name = 'Product_PIM_Integration_IQR' LIMIT 1];
        String body = sr.Body.toString();
        System.assertEquals(body, res1.getBody());
        System.assertEquals(200, res1.getStatusCode());  
        
        
        Database.executeBatch(new Core_IQR_PIM_IntelProductData());
        Core_IQRPIMIntelProductDataScheduler.Core_IQRPIMIntelProductDataScheduler();
        //List<Product2> upd_Products = new List<Product2>();
        // Database.executeBatch(new Core_IQR_PIM_UpdateProducts(upd_Products),200);
        Test.stopTest();
    }
    
    
    @isTest static void Core_IQR_PIM_UpdateProducts400(){
        Test.startTest(); 
        
        List<Product2> upd_Products =new List<Product2>();
        Database.executeBatch(new Core_IQR_PIM_UpdateProducts(upd_Products),1);
        Test.stopTest();
    }


    public static HttpResponse PostInfoFromExternalService(String endpoint) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('POST');
        req.setTimeout(60000);   
        Http h = new Http();
        HttpResponse res = h.send(req);
        system.debug('httpMock:'+res);
        return res;
    } 
    
    public static HttpResponse getInfoFromExternalService(String endpoint) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('GET');
        req.setTimeout(60000);   
        Http h = new Http();
        HttpResponse res = h.send(req);
        system.debug('httpMock:'+res);
        return res;
    } 
    
    
    public static void insertCustomSettings(){
        List<Core_IQR_Endpoints__c> endPointList = new List<Core_IQR_Endpoints__c>();
        Core_IQR_Endpoints__c e1 = new Core_IQR_Endpoints__c();
        boolean customAPILoadFlag= true;
        DateTime todaysDate = System.today()-1; 
        
        DateTime   customAPILoaddate =System.today()-2;   
        
        String todaysDateStr='';
        if (customAPILoadFlag)
        {
            todaysDateStr = customAPILoaddate.format('yyyy-MM-dd');
            todaysDateStr =todaysDateStr + 'T00:00:00Z';
        }
        else
        {
            todaysDateStr = todaysDate.format('yyyy-MM-dd');
            todaysDateStr =todaysDateStr + 'T00:00:00Z';
        }
        
        e1.name = 'authtoken';
        e1.Endpoint__c='client_id=ec3dc7a0-5f81-4846-8b34-d288386dc520&client_secret=6Cr7Q~j1Zbsw3psK8K_xlqcSll7CZlx0n7a7l&grant_type=client_credentials';
        
        Core_IQR_Endpoints__c e2 = new Core_IQR_Endpoints__c();
        e2.name = 'authtokenURL';
        e2.Endpoint__c='https://apis.intel.com/v1/auth/token';
        
        Core_IQR_Endpoints__c e3 = new Core_IQR_Endpoints__c();
        e3.name = 'Product_PIM_Integration_IQR';
        e3.Endpoint__c='https://apis-sandbox.intel.com/pim/v1/services/products?localeGeoId=en-US&categoryId=873&includeAttributes=true&limit=1';
        e3.IQR_PIM_Custom_DataLoad__c= true;
        e3.IQR_PIM_Custom_DataLoad_Date__c= System.today()-2;   
        
        Core_IQR_Endpoints__c e4 = new Core_IQR_Endpoints__c();
        e4.name = 'Product_PIM_Integration_IQR1';
        e4.Endpoint__c='https://apis-sandbox.intel.com/pim/v1/services/products?localeGeoId=en-US&categoryId=873&includeAttributes=true&limit=1&offset=2&filters=updatedDateTime gt '+ todaysDateStr;
        
        
        endPointList.add(e1);
        endPointList.add(e2);
        endPointList.add(e3);
        endPointList.add(e4);
        
        insert endPointList;
        
        Product2 p = new Product2();
        p.Name='Intel® Xeon® Gold 6142 Processor (22M Cache, 2.60 GHz)';
        p.Core_Product_Org__c = 'Sales';
        p.Core_Unique_ID__c='120458;122573;122570;86065;35125';
        p.Core_Product_Name_EPM_ID__c='120458';
        p.isActive=True;
        p.Core_CoreCount__c='123';
        p.Core_Max_TDP__c='12';
        p.Core_VerticalSegment__c='Test';
        insert p;
        
        Product2 p1 = new Product2();
        p1.Name='Intel® Xeon® Gold 6142 Processor (22M Cache, 2.60 GHz)1';
        p1.Core_Product_Org__c = 'IPS';
        p1.Core_Unique_ID__c='123808;122573;122570;86065;35125';
        p1.Core_Product_Name_EPM_ID__c='123808';
        p1.isActive=True;
        p1.Core_CoreCount__c='1234';
        p1.Core_Max_TDP__c='123';
        p1.Core_VerticalSegment__c='Test1';
        insert p1;
        
        Product2 p2 = new Product2();
        p2.Name='Intel® Xeon® Gold 6142 Processor (22M Cache, 2.60 GHz)1';
        p2.Core_Product_Org__c = 'Sales';
        p2.Core_Unique_ID__c='1239292929;122573;122570;86065;35125';
        p2.Core_Product_Name_EPM_ID__c='1239292929';
        p2.isActive=True;
        p2.Core_CoreCount__c='12345';
        p2.Core_Max_TDP__c='1231';
        p2.Core_VerticalSegment__c='Test11';
        insert p2;
        
        Product2 p3 = new Product2();
        p3.Name='Intel® Xeon® Gold 6142 Processor (22M Cache, 2.60 GHz)1';
        p3.Core_Product_Org__c = 'Sales';
        p3.Core_Unique_ID__c='1239292929;122573;122570;86065;35125';
        p3.Core_Product_Name_EPM_ID__c='1239292929';
        p3.isActive=True;
        p3.Core_Hierarchy_Name__c ='Valid Product Hierarchy';
        p3.Core_Hierarchy_ID__c = '43';
        p3.Core_CoreCount__c='134';
        p3.Core_Max_TDP__c='13';
        p3.Core_VerticalSegment__c='Test1.';
        insert p3;
    }
    
    public static void recordInsertSetUp(){
        List<Core_IQR_Endpoints__c> endPointList = new List<Core_IQR_Endpoints__c>();
        Core_IQR_Endpoints__c e11 = new Core_IQR_Endpoints__c();
        e11.name = 'authtoken';
        e11.Endpoint__c='client_id=ec3dc7a0-5f81-4846-8b34-d288386dc520&client_secret=6Cr7Q~j1Zbsw3psK8K_xlqcSll7CZlx0n7a7l&grant_type=client_credentials';
        
        Core_IQR_Endpoints__c e22 = new Core_IQR_Endpoints__c();
        e22.name = 'authtokenURL';
        e22.Endpoint__c='https://apis.intel.com/v1/auth/token';
        
        
        
        Core_IQR_Endpoints__c e33 = new Core_IQR_Endpoints__c();
        e33.name = 'Product_PIM_Integration_IQR';
        e33.Endpoint__c='https://apis-sandbox.intel.com/pim/v1/services/products?localeGeoId=en-US&categoryId=873&includeAttributes=true&limit=1&offset=1';
        
        
        endPointList.add(e11);
        endPointList.add(e22);
        endPointList.add(e33);
        
        
        insert endPointList;
        
        Product2 p = new Product2();
        p.Name='Intel® Xeon® Gold 6142 Processor (22M Cache, 2.60 GHz)';
        p.Core_Product_Org__c = 'Sales';
        p.Core_Unique_ID__c='120458;122573;122570;86065;35125';
        p.Core_Product_Name_EPM_ID__c='120458';
        p.isActive=True;
        p.Core_CoreCount__c='1234';
        p.Core_Max_TDP__c='123';
        p.Core_VerticalSegment__c='Test1';
        insert p;
        
        Product2 p1 = new Product2();
        p1.Name='Intel® Xeon® Gold 6142 Processor (22M Cache, 2.60 GHz)1';
        p1.Core_Product_Org__c = 'IPS';
        p1.Core_Unique_ID__c='123808;122573;122570;86065;35125';
        p1.Core_Product_Name_EPM_ID__c='123808';
        p1.isActive=True;
        p1.Core_CoreCount__c='1234';
        p1.Core_Max_TDP__c='123';
        p1.Core_VerticalSegment__c='Test1';
        insert p1;
        
        Product2 p2 = new Product2();
        p2.Name='Intel® Xeon® Gold 6142 Processor (22M Cache, 2.60 GHz)1';
        p2.Core_Product_Org__c = 'Sales';
        p2.Core_Unique_ID__c='1239292929;122573;122570;86065;35125';
        p2.Core_Product_Name_EPM_ID__c='1239292929';
        p2.isActive=True;
        p2.Core_CoreCount__c='12345';
        p2.Core_Max_TDP__c='1234';
        p2.Core_VerticalSegment__c='Test11';
        insert p2;
        
        Product2 p3 = new Product2();
        p3.Name='Intel® Xeon® Gold 6142 Processor (22M Cache, 2.60 GHz)1';
        p3.Core_Product_Org__c = 'Sales';
        p3.Core_Unique_ID__c='1239292929;122573;122570;86065;35125';
        p3.Core_Product_Name_EPM_ID__c='1239292929';
        p3.isActive=True;
        p3.Core_Hierarchy_Name__c ='Valid Product Hierarchy';
        p3.Core_Hierarchy_ID__c = '43';
        p3.Core_CoreCount__c='12341';
        p3.Core_Max_TDP__c='1231';
        p3.Core_VerticalSegment__c='Test12';
        insert p3;
        
        
        HTTPResponse res = getInfoFromExternalService('https://apis.intel.com/v1/auth/token');
        HTTPResponse res1 = getInfoFromExternalService('https://apis-sandbox.intel.com/pim/v1/services/products?localeGeoId=en-US&categoryId=873&includeAttributes=true&limit=1&offset=1');
        HTTPResponse res2 = getInfoFromExternalService('https://apis-sandbox.intel.com/pim/v1/services/products?localeGeoId=en-US&categoryId=873&includeAttributes=true&limit=1&offset=2');
        HTTPResponse res3 = getInfoFromExternalService('https://apis-sandbox.intel.com/pim/v1/services/products?localeGeoId=en-US&categoryId=873&includeAttributes=true&limit=1&offset=3');
        HTTPResponse res4 = getInfoFromExternalService('https://apis-sandbox.intel.com/pim/v1/services/products?localeGeoId=en-US&categoryId=873&includeAttributes=true&limit=1&offset=4');
        HTTPResponse res5 = getInfoFromExternalService('https://apis-sandbox.intel.com/pim/v1/services/products?localeGeoId=en-US&categoryId=873&includeAttributes=true&limit=1&offset=5');
        
    }
    
    public class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name = 'Product_PIM_Integration_IQR' LIMIT 1];
            res.setBody(sr.Body.toString());
            res.setStatusCode(200);
            System.assert(res != null);
            return res;
        }
    }
    
    
}