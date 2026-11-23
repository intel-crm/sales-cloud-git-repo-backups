@isTest
public class Sales_SAP_Subs_Dets_Service_Test {
/*
    @testSetup
    public static void setupData(){
        Order ord = Sales_TestFactory_Utility.createOrders(null, Test.getStandardPricebookId(), 'Licensed Tool Order');
        Product2 prod1 = Sales_TestFactory_Utility.createProductWithDifferentLicenseType('Fixed',null);
        Account acc = [Select Id from account limit 1];
        List<Contract> contList = Sales_TestFactory_Utility.createContract(acc.id);
        Pricebookentry pbEntry = new Pricebookentry();
        pbEntry.UnitPrice = 240;
        pbEntry.Pricebook2Id = Test.getStandardPricebookId();
        pbEntry.Product2Id = prod1.id;
        insert pbEntry;
        OrderItem ordItm1 = Sales_TestFactory_Utility.createOrderProduct(ord.id, prod1.id, pbEntry.id);
    }
    @isTest public static void testServiceCallout(){
        Order ord = [Select Id, OrderNumber from Order limit 1];
        Sales_SAP_Subs_Dets_Service.Sales_Orders Sales_Orders = new Sales_SAP_Subs_Dets_Service.Sales_Orders();
        Sales_SAP_Subs_Dets_Service.Shipping_Info shippingInfoObject = new Sales_SAP_Subs_Dets_Service.Shipping_Info();
        Sales_Orders.shippingInfo = null;
        shippingInfoObject.ShipmentDate = String.valueOf(Date.today());     
        shippingInfoObject.SAPOrderNum = '7389220'; 
        shippingInfoObject.ShipmentNum = '7678990'; 
        shippingInfoObject.OrderNumber = ord.OrderNumber; 
        shippingInfoObject.AirBillNum = '676878';
        shippingInfoObject.Status = 'SAP Order Shipped';        
        Sales_SAP_Subs_Dets_Service.Sales_ListOfOrder_LineItems ListOfOrder_LineItems = new Sales_SAP_Subs_Dets_Service.Sales_ListOfOrder_LineItems();        
        List<Sales_SAP_Subs_Dets_Service.Sales_Order_LineItems> sales_Order_LicensesList = new List<Sales_SAP_Subs_Dets_Service.Sales_Order_LineItems>();
        shippingInfoObject.ListOfOrder_LineItems = ListOfOrder_LineItems;
        ListOfOrder_LineItems.Order_LineItems = sales_Order_LicensesList;
        Sales_SAP_Subs_Dets_Service.Sales_Order_LineItems ordLineItem = new Sales_SAP_Subs_Dets_Service.Sales_Order_LineItems();
        sales_Order_LicensesList.add(ordLineItem);
        ordLineItem.RUGuardId  = 'hd8393j';     
        ordLineItem.DueDate = String.valueOf(Date.today()); 
        ordLineItem.LineNumber = '1'; 
        ordLineItem.PartNumber = 'hdhksdhk'; 
        ordLineItem.Status = 'Verified';         
        Sales_SAP_Subs_Dets_Service.Sales_ListOfOrder_Line_Licenses ListOfOrder_Line_Licenses =  new Sales_SAP_Subs_Dets_Service.Sales_ListOfOrder_Line_Licenses();
        ordLineItem.ListOfOrder_Line_Licenses = ListOfOrder_Line_Licenses;
        Sales_SAP_Subs_Dets_Service.Sales_Order_Licenses salesOrderLicense = new Sales_SAP_Subs_Dets_Service.Sales_Order_Licenses();
        List<Sales_SAP_Subs_Dets_Service.Sales_Order_Licenses> olderLicList = new List<Sales_SAP_Subs_Dets_Service.Sales_Order_Licenses>();
        olderLicList.add(salesOrderLicense);
        ListOfOrder_Line_Licenses.Order_Lines_Licenses = olderLicList;
        salesOrderLicense.LRASerialNum = '79djw839'; 
        salesOrderLicense.OrderItemLineNumber = '1'; 
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/sales/v1/postSubscriptions'; 
        req.httpMethod = 'Post';
        req.addHeader('Content-Type', 'application/json'); 
        RestContext.request = req;
        RestContext.response = res; 
        Test.startTest();
        Sales_SAP_Subs_Dets_Service.postSubscriptions(shippingInfoObject);
        Test.stopTest();  
    }
    @isTest public static void testServiceCalloutFailedCheck(){
        Order ord = [Select Id, OrderNumber from Order limit 1];
        Sales_SAP_Subs_Dets_Service.Sales_Orders Sales_Orders = new Sales_SAP_Subs_Dets_Service.Sales_Orders();
        Sales_SAP_Subs_Dets_Service.Shipping_Info shippingInfoObject = new Sales_SAP_Subs_Dets_Service.Shipping_Info();
        Sales_Orders.shippingInfo = shippingInfoObject;
        shippingInfoObject.ShipmentDate = '';     
        shippingInfoObject.SAPOrderNum = ''; 
        shippingInfoObject.ShipmentNum = ''; 
        shippingInfoObject.OrderNumber = ''; 
        shippingInfoObject.AirBillNum = '';
        shippingInfoObject.Status = '';        
        Sales_SAP_Subs_Dets_Service.Sales_ListOfOrder_LineItems ListOfOrder_LineItems = new Sales_SAP_Subs_Dets_Service.Sales_ListOfOrder_LineItems();        
        List<Sales_SAP_Subs_Dets_Service.Sales_Order_LineItems> sales_Order_LicensesList = new List<Sales_SAP_Subs_Dets_Service.Sales_Order_LineItems>();
        shippingInfoObject.ListOfOrder_LineItems = ListOfOrder_LineItems;
        ListOfOrder_LineItems.Order_LineItems = sales_Order_LicensesList;
        Sales_SAP_Subs_Dets_Service.Sales_Order_LineItems ordLineItem = new Sales_SAP_Subs_Dets_Service.Sales_Order_LineItems();
        sales_Order_LicensesList.add(ordLineItem);
        ordLineItem.RUGuardId  = 'hd8393j';     
        ordLineItem.DueDate = String.valueOf(Date.today()); 
        ordLineItem.LineNumber = '1'; 
        ordLineItem.PartNumber = 'hdhksdhk'; 
        ordLineItem.Status = 'Verified';         
        Sales_SAP_Subs_Dets_Service.Sales_ListOfOrder_Line_Licenses ListOfOrder_Line_Licenses =  new Sales_SAP_Subs_Dets_Service.Sales_ListOfOrder_Line_Licenses();
        ordLineItem.ListOfOrder_Line_Licenses = ListOfOrder_Line_Licenses;
        Sales_SAP_Subs_Dets_Service.Sales_Order_Licenses salesOrderLicense = new Sales_SAP_Subs_Dets_Service.Sales_Order_Licenses();
        List<Sales_SAP_Subs_Dets_Service.Sales_Order_Licenses> olderLicList = new List<Sales_SAP_Subs_Dets_Service.Sales_Order_Licenses>();
        olderLicList.add(salesOrderLicense);
        ListOfOrder_Line_Licenses.Order_Lines_Licenses = olderLicList;
        salesOrderLicense.LRASerialNum = '79djw839'; 
        salesOrderLicense.OrderItemLineNumber = '1'; 
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/sales/v1/postSubscriptions'; 
        req.httpMethod = 'Post';
        req.addHeader('Content-Type', 'application/json'); 
        RestContext.request = req;
        RestContext.response = res; 
        try{
            Test.startTest();
            Sales_SAP_Subs_Dets_Service.postSubscriptions(null);
            Test.stopTest();  
        }
        Catch(Exception e){
        }
    }
    @isTest public static void testServiceCalloutOrderFailedCheck(){
        Order ord = [Select Id, OrderNumber from Order limit 1];
        Sales_SAP_Subs_Dets_Service.Sales_Orders Sales_Orders = new Sales_SAP_Subs_Dets_Service.Sales_Orders();
        Sales_SAP_Subs_Dets_Service.Shipping_Info shippingInfoObject = new Sales_SAP_Subs_Dets_Service.Shipping_Info();
        Sales_Orders.shippingInfo = null;
        shippingInfoObject.ShipmentDate = '2021-02-30T00:00:00.000Z';     
        shippingInfoObject.SAPOrderNum = '7389220'; 
        shippingInfoObject.ShipmentNum = '7678990'; 
        shippingInfoObject.OrderNumber = ord.OrderNumber; 
        shippingInfoObject.AirBillNum = '676878';
        shippingInfoObject.Status = 'SAP Order Shipped';        
        Sales_SAP_Subs_Dets_Service.Sales_ListOfOrder_LineItems ListOfOrder_LineItems = new Sales_SAP_Subs_Dets_Service.Sales_ListOfOrder_LineItems();        
        List<Sales_SAP_Subs_Dets_Service.Sales_Order_LineItems> sales_Order_LicensesList = new List<Sales_SAP_Subs_Dets_Service.Sales_Order_LineItems>();
        shippingInfoObject.ListOfOrder_LineItems = ListOfOrder_LineItems;
        ListOfOrder_LineItems.Order_LineItems = sales_Order_LicensesList;
        Sales_SAP_Subs_Dets_Service.Sales_Order_LineItems ordLineItem = new Sales_SAP_Subs_Dets_Service.Sales_Order_LineItems();
        sales_Order_LicensesList.add(ordLineItem);
        ordLineItem.RUGuardId  = 'hd8393j';     
        ordLineItem.DueDate = String.valueOf(Date.today()); 
        ordLineItem.LineNumber = '1'; 
        ordLineItem.PartNumber = 'hdhksdhk'; 
        ordLineItem.Status = 'Verified';         
        Sales_SAP_Subs_Dets_Service.Sales_ListOfOrder_Line_Licenses ListOfOrder_Line_Licenses =  new Sales_SAP_Subs_Dets_Service.Sales_ListOfOrder_Line_Licenses();
        ordLineItem.ListOfOrder_Line_Licenses = ListOfOrder_Line_Licenses;
        Sales_SAP_Subs_Dets_Service.Sales_Order_Licenses salesOrderLicense = new Sales_SAP_Subs_Dets_Service.Sales_Order_Licenses();
        List<Sales_SAP_Subs_Dets_Service.Sales_Order_Licenses> olderLicList = new List<Sales_SAP_Subs_Dets_Service.Sales_Order_Licenses>();
        olderLicList.add(salesOrderLicense);
        ListOfOrder_Line_Licenses.Order_Lines_Licenses = olderLicList;
        salesOrderLicense.LRASerialNum = '79djw839'; 
        salesOrderLicense.OrderItemLineNumber = '1'; 
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/sales/v1/postSubscriptions'; 
        req.httpMethod = 'Post';
        req.addHeader('Content-Type', 'application/json'); 
        RestContext.request = req;
        RestContext.response = res; 
        Test.startTest();
        Sales_SAP_Subs_Dets_Service.postSubscriptions(shippingInfoObject);
        Test.stopTest();  
    }
    public static testMethod void testEmailsOnSAPSyncException(){ 
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        User dummyUsr = new User(Alias = 'Dummy', Email='dummyUserTest@intel.com',
                                 EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                                 LocaleSidKey='en_US', ProfileId = p.Id,
                                 TimeZoneSidKey='America/Los_Angeles', UserName= 'dummySalesCreat@testorg.com');
        dummyUsr.ProfileId = p.Id;
        insert dummyUsr;
        Test.startTest();
        System.runAs(dummyUsr) {
            PRM_Execution_Controls__c  skipValidation= PRM_Execution_Controls__c.getInstance(UserInfo.getUserId());
            skipValidation.Skip_ValidationRule_Order_Status__c = true;
            try{
                Order ord = [SELECT Id, OrderNumber, CreatedBy.Email, AccountId, Account.Name FROM Order WHERE Status = 'Activated' AND Sales_status__c = 'Order created successfully' LIMIT 1];
                Sales_SAP_Subs_Dets_Service.Sales_Orders Sales_Orders = new Sales_SAP_Subs_Dets_Service.Sales_Orders();
                Sales_SAP_Subs_Dets_Service.Shipping_Info shippingInfoObject = new Sales_SAP_Subs_Dets_Service.Shipping_Info();
                Sales_Orders.shippingInfo = null;
                shippingInfoObject.ShipmentDate = String.valueOf(Date.today()-10);     
                shippingInfoObject.SAPOrderNum = '7389220'; 
                shippingInfoObject.ShipmentNum = '7678990'; 
                shippingInfoObject.OrderNumber = ord.OrderNumber; 
                shippingInfoObject.AirBillNum = '676878';
                shippingInfoObject.Status = 'SAP Order Shipped';        
                Sales_SAP_Subs_Dets_Service.Sales_ListOfOrder_LineItems ListOfOrder_LineItems = new Sales_SAP_Subs_Dets_Service.Sales_ListOfOrder_LineItems();        
                List<Sales_SAP_Subs_Dets_Service.Sales_Order_LineItems> sales_Order_LicensesList = new List<Sales_SAP_Subs_Dets_Service.Sales_Order_LineItems>();
                shippingInfoObject.ListOfOrder_LineItems = ListOfOrder_LineItems;
                ListOfOrder_LineItems.Order_LineItems = sales_Order_LicensesList;
                Sales_SAP_Subs_Dets_Service.Sales_Order_LineItems ordLineItem = new Sales_SAP_Subs_Dets_Service.Sales_Order_LineItems();
                sales_Order_LicensesList.add(ordLineItem);
                ordLineItem.RUGuardId  = 'hd8393j';     
                ordLineItem.DueDate = String.valueOf(Date.today()); 
                ordLineItem.LineNumber = '1'; 
                ordLineItem.PartNumber = 'hdhksdhk'; 
                ordLineItem.Status = 'Verified';         
                Sales_SAP_Subs_Dets_Service.Sales_ListOfOrder_Line_Licenses ListOfOrder_Line_Licenses =  new Sales_SAP_Subs_Dets_Service.Sales_ListOfOrder_Line_Licenses();
                ordLineItem.ListOfOrder_Line_Licenses = ListOfOrder_Line_Licenses;
                Sales_SAP_Subs_Dets_Service.Sales_Order_Licenses salesOrderLicense = new Sales_SAP_Subs_Dets_Service.Sales_Order_Licenses();
                List<Sales_SAP_Subs_Dets_Service.Sales_Order_Licenses> olderLicList = new List<Sales_SAP_Subs_Dets_Service.Sales_Order_Licenses>();
                olderLicList.add(salesOrderLicense);
                ListOfOrder_Line_Licenses.Order_Lines_Licenses = olderLicList;
                salesOrderLicense.LRASerialNum = '79djw839'; 
                salesOrderLicense.OrderItemLineNumber = '1'; 
                RestRequest req = new RestRequest(); 
                RestResponse res = new RestResponse();
                req.requestURI = '/services/apexrest/sales/v1/postSubscriptions'; 
                req.httpMethod = 'Post';
                req.addHeader('Content-Type', 'application/json'); 
                RestContext.request = req;
                RestContext.response = res;             
                Sales_SAP_Subs_Dets_Service.postSubscriptions(shippingInfoObject);             
            }catch(Exception e){
            }
        }
        Test.stopTest();
    }    
*/
}