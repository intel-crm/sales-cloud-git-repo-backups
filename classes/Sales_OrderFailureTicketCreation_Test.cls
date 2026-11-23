@isTest
public class Sales_OrderFailureTicketCreation_Test {
   
@isTest
    public static  void createTicketOnExcpetion_Test(){
        //  Test.setMock(HttpCalloutMock.class, new Sales_SapIntegrationUtilityCalloutMock(401,'Failure')); 
         Order ord = Sales_TestFactory_Utility.createOrders(null, Test.getStandardPricebookId(), 'Licensed Tool Order');
        Product2 prod1 = Sales_TestFactory_Utility.createProductWithDifferentLicenseType('Fixed',null);
        //Product2 prod2 = Sales_TestFactory_Utility.createProductWithDifferentLicenseType('Float',null);
        Account acc = [Select Id from account limit 1];
        List<Contract> contList = Sales_TestFactory_Utility.createContract(acc.id);
        Pricebookentry pbEntry = new Pricebookentry();
        pbEntry.UnitPrice = 240;
        pbEntry.Pricebook2Id = Test.getStandardPricebookId();
        pbEntry.Product2Id = prod1.id;
        insert pbEntry;
         OrderItem ordItm1 = Sales_TestFactory_Utility.createOrderProduct(ord.id, prod1.id, pbEntry.id);
        Order ord1 = [Select OrderNumber from Order limit 1];
         List<string> OrdNum = new List <string>();
        OrdNum.add(ord1.OrderNumber);
        String errormsg='error';
         String shipmenterror='error';
        /*Pricebookentry pbEntry2 = new Pricebookentry();
        pbEntry2.UnitPrice = 240;
        pbEntry2.Pricebook2Id = Test.getStandardPricebookId();
        pbEntry2.Product2Id = prod2.id;
        insert pbEntry2;*/
 Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Sales_OrderFailureTicketCreationCallout(201,'Success')); 
        Sales_SAP_Token_Detail__c connectSettingRecord = new Sales_SAP_Token_Detail__c();
        connectSettingRecord.Sales_Access_Token__c='TestToken';
        connectSettingRecord.Sales_Expires_In_Seconds__c=3599;
        connectSettingRecord.Sales_Expires_In_Time__c=System.now().addSeconds(Integer.valueOf(3599));
        connectSettingRecord.Name ='SAP License Token Details';
        insert connectSettingRecord;
        //String input= String.valueOf(host.Id);
        //System.debug('input>>>'+input);
        String exceptionMsg='';
        Blob var1=Blob.valueOf('Test');
        System.enqueueJob(new Sales_OrderFailureTicketCreation.ItsmTicketCreation(OrdNum,errormsg,shipmenterror));
          //Sales_OrderFailureTicketCreation.createTicketOnExcpetion(ord1.OrderNumber,errormsg);
         Test.stopTest();
    }
       /* @isTest public static void testServiceCallout(){
            String errormsg='error';
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
        //global String OrderLicenseNumber;
        salesOrderLicense.OrderItemLineNumber = '1'; 
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/sales/v1/postSubscriptions'; 
        req.httpMethod = 'Post';
        req.addHeader('Content-Type', 'application/json'); 
        RestContext.request = req;
        RestContext.response = res; 
        Test.startTest();
            //Sales_SAP_Subs_Dets_Service.postSubscriptions(shippingInfoObject);
            Sales_OrderFailureTicketCreation.createTicketOnExcpetion(ord.OrderNumber,errormsg);
        Test.stopTest();  
    }*/
    @isTest
    public static  void createTicketOnExcpetion_Test1(){
        //  Test.setMock(HttpCalloutMock.class, new Sales_SapIntegrationUtilityCalloutMock(401,'Failure')); 
         Order ord = Sales_TestFactory_Utility.createOrders(null, Test.getStandardPricebookId(), 'Licensed Tool Order');
        Product2 prod1 = Sales_TestFactory_Utility.createProductWithDifferentLicenseType('Fixed',null);
        //Product2 prod2 = Sales_TestFactory_Utility.createProductWithDifferentLicenseType('Float',null);
        Account acc = [Select Id from account limit 1];
        List<Contract> contList = Sales_TestFactory_Utility.createContract(acc.id);
        Pricebookentry pbEntry = new Pricebookentry();
        pbEntry.UnitPrice = 240;
        pbEntry.Pricebook2Id = Test.getStandardPricebookId();
        pbEntry.Product2Id = prod1.id;
        insert pbEntry;
         OrderItem ordItm1 = Sales_TestFactory_Utility.createOrderProduct(ord.id, prod1.id, pbEntry.id);
        Order ord1 = [Select OrderNumber from Order limit 1];
         List<string> OrdNum = new List <string>();
        OrdNum.add(ord1.OrderNumber);
        String errormsg='error';
         String shipmenterror='error';
        /*Pricebookentry pbEntry2 = new Pricebookentry();
        pbEntry2.UnitPrice = 240;
        pbEntry2.Pricebook2Id = Test.getStandardPricebookId();
        pbEntry2.Product2Id = prod2.id;
        insert pbEntry2;*/
 Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Sales_OrderFailureTicketCreationCallout(200,'Success')); 
        Sales_SAP_Token_Detail__c connectSettingRecord = new Sales_SAP_Token_Detail__c();
        connectSettingRecord.Sales_Access_Token__c='TestToken';
        connectSettingRecord.Sales_Expires_In_Seconds__c=3599;
        connectSettingRecord.Sales_Expires_In_Time__c=System.now().addSeconds(Integer.valueOf(3599));
        connectSettingRecord.Name ='SAP Order Failure Token Details';
        insert connectSettingRecord;
        //String input= String.valueOf(host.Id);
        //System.debug('input>>>'+input);
        String exceptionMsg='';
        Blob var1=Blob.valueOf('Test');
        System.enqueueJob(new Sales_OrderFailureTicketCreation.ItsmTicketCreation(OrdNum,errormsg,shipmenterror));
          //Sales_OrderFailureTicketCreation.createTicketOnExcpetion(ord1.OrderNumber,errormsg);
         Test.stopTest();
    }
       @isTest
    public static  void createTicketOnExcpetion_Test2(){
        Test.setMock(HttpCalloutMock.class, new Sales_SapIntegrationUtilityCalloutMock(401,'Failure')); 
         Order ord = Sales_TestFactory_Utility.createOrders(null, Test.getStandardPricebookId(), 'Licensed Tool Order');
        Product2 prod1 = Sales_TestFactory_Utility.createProductWithDifferentLicenseType('Fixed',null);
        //Product2 prod2 = Sales_TestFactory_Utility.createProductWithDifferentLicenseType('Float',null);
        Account acc = [Select Id from account limit 1];
        List<Contract> contList = Sales_TestFactory_Utility.createContract(acc.id);
        Pricebookentry pbEntry = new Pricebookentry();
        pbEntry.UnitPrice = 240;
        pbEntry.Pricebook2Id = Test.getStandardPricebookId();
        pbEntry.Product2Id = prod1.id;
        insert pbEntry;
         OrderItem ordItm1 = Sales_TestFactory_Utility.createOrderProduct(ord.id, prod1.id, pbEntry.id);
        Order ord1 = [Select OrderNumber from Order limit 1];
         List<string> OrdNum = new List <string>();
        OrdNum.add(ord1.OrderNumber);
        String errormsg='error';
         String shipmenterror='error';
        /*Pricebookentry pbEntry2 = new Pricebookentry();
        pbEntry2.UnitPrice = 240;
        pbEntry2.Pricebook2Id = Test.getStandardPricebookId();
        pbEntry2.Product2Id = prod2.id;
        insert pbEntry2;*/
 Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Sales_OrderFailureTicketCreationCallout(401,'Failure')); 
        Sales_SAP_Token_Detail__c connectSettingRecord = new Sales_SAP_Token_Detail__c();
        connectSettingRecord.Sales_Access_Token__c='TestToken';
        connectSettingRecord.Sales_Expires_In_Seconds__c=3599;
        connectSettingRecord.Sales_Expires_In_Time__c=System.now().addSeconds(Integer.valueOf(3599));
        connectSettingRecord.Name ='SAP Order Failure Token Details';
        insert connectSettingRecord;
        //String input= String.valueOf(host.Id);
        //System.debug('input>>>'+input);
        String exceptionMsg='';
        Blob var1=Blob.valueOf('Test');
        System.enqueueJob(new Sales_OrderFailureTicketCreation.ItsmTicketCreation(OrdNum,errormsg,shipmenterror));
          //Sales_OrderFailureTicketCreation.createTicketOnExcpetion(ord1.OrderNumber,errormsg);
         Test.stopTest();
    }
   
   
 
}