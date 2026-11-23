/*********************************************************************************************************************
Class Name    : Sales_LicenseValidationCheckTest
Version       : 1.0
Created Date  : Dec 2020
Function      : Test  class for Core_PSG_LicenseValidationCheckUtility  
Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------
* Srishty Sharma           01-Feb-2020             US862284: Validation rule to prevent  Products that involve license generator from Mentor graphics from being bought by Mentor graphics' competitors.
**********************************************************************************************************************/
@isTest
public class Sales_LicenseValidationCheckTest {
    /*@TestSetup
    public static void testData(){
        Product2 p = Sales_TestFactory_Utility.createProductWithDifferentLicenseType('Float',null);
        p.Core_OPN__c='TESTFLOAT';
        update p;
        Account accObj = Sales_TestFactory_Utility.createAccount(); 
        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry standardPrice = Sales_TestFactory_Utility.createPriceBookEntry(p.Id, pricebookId);
        Account endCustomerAcc = Sales_TestFactory_Utility.createShipToAccount();
        TriggerHandler.bypass('Sales_OrderTriggerHandler');
        TriggerHandler.bypass('Sales_OrderProductTriggerHandler');
        Order order = Sales_TestFactory_Utility.createOrders(endCustomerAcc.Id,pricebookId, 'Licensed Tool Order');
        OrderItem oi = Sales_TestFactory_Utility.createOrderProduct(order.Id, p.Id, standardPrice.Id);
    }
    static testmethod void checkLicenseVendorTest(){
        List<OrderItem> orderItemList = new List<OrderItem>();
        List<Order> ordList = new List<Order>();
        Map<Id,Id> orderToEndCustomerMap =new Map<Id,Id>();
        Map<Id,Order> orderOldMap=new Map<Id,Order>();
        List<String> opnList = new List<String>();
        Set<Id> endCustIdSet=new Set<Id>();
        Set<Id> orderIdSet = new Set<Id>();
        Map<Id,Set<String>> salesLicenseControlMap =new Map<Id,Set<String>>();
        Product2 p = [Select id,Core_OPN__c from Product2 where Core_OPN__c='TESTFLOAT' Limit 1];
        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry standardPrice = [Select id from PricebookEntry Limit 1];
        Account endCustomerAcc = Sales_TestFactory_Utility.createEndCustomerAccount();
        Set<String> opnSet = new Set<String>();
        Test.startTest();
        List<Sales_License_Control__c> salesLicenseList =new List<Sales_License_Control__c>(); 
        Sales_License_Control__c salesLicense = new Sales_License_Control__c();
        salesLicense.Sales_Account_Competitor__c =endCustomerAcc.Id;
        salesLicense.Sales_Product__c=p.Id;
        salesLicense.Sales_InActive_Ind__c=false;
        salesLicenseList.add(salesLicense);
        insert salesLicenseList;
        try{
            opnSet.add(salesLicense.Sales_OPN__c);
            salesLicenseControlMap.put(salesLicense.Sales_Account_Competitor__c,opnSet);
            Order order = Sales_TestFactory_Utility.createOrders(endCustomerAcc.Id,pricebookId, 'Licensed Tool Order');
            order.Sales_End_Customer_Account__c=endCustomerAcc.Id;
            order.Sales_End_Customer_Account_2_Txt__c=endCustomerAcc.Name;
            order.Sales_End_Customer_City_Txt__c=endCustomerAcc.BillingCity;
            order.Sales_End_Customer_Country_Txt__c=endCustomerAcc.BillingCountry;
            order.Sales_End_Customer_Province_Txt__c=endCustomerAcc.BillingCountry;
            order.Sales_End_Customer_State_Txt__c=endCustomerAcc.BillingState;
            order.Sales_End_Customer_Street_Dsc__c=endCustomerAcc.BillingStreet;
            order.Sales_End_Customer_Zip_Txt__c=endCustomerAcc.BillingPostalCode;
            update order;
            endCustIdSet.add(order.Sales_End_Customer_Account__c);
            ordList.add(order);
            orderIdSet.add(order.id);
            OrderItem oi = Sales_TestFactory_Utility.createOrderProduct(order.Id, p.Id, standardPrice.Id);
            orderToEndCustomerMap.put(order.Id,order.Sales_End_Customer_Account__c);
            orderItemList.add(oi);
            opnList.add(oi.Sales_OPN__c);
            Sales_LicenseValidationCheckUtilty.checkLicenseVendor(endCustIdSet);
            Sales_LicenseValidationCheckUtilty.addErrorOnOrderItem(orderItemList);
            salesLicense.Sales_Account_Competitor__c =endCustomerAcc.Id;
            update salesLicense;
            orderOldMap.put(order.Id, order);
            Sales_LicenseValidationCheckUtilty.addErrorOnOrder(ordList,orderOldMap);
            Test.stopTest();
        }
        catch(Exception e){
            Boolean expectedExceptionThrown = e.getMessage().contains(System.Label.Sales_LicenseVendorError) ? true : false;
        }
    }
    @isTest
    private static void testUpdateOrder(){
        Product2 p = [Select id,Core_OPN__c from Product2 where Core_OPN__c='TESTFLOAT' Limit 1];
        String OPN = p.Core_OPN__c;
        Map<Id,Order> orderOldMap=new Map<Id,Order>();
        Test.startTest();
        Order order = [Select id,Sales_End_Customer_Account__c from Order Limit 1]; 
        List<Order> ordList=new List<Order>();
        PricebookEntry standardPrice = [Select Id from PricebookEntry Limit 1];
        Account endCustomerAcc = [Select id from Account Limit 1];
        OrderItem oi = [Select id,Product2.Core_OPN__c from OrderItem];
        String exceptionMessage='';
        orderOldMap.put(order.Id, order);
        Sales_TestFactory_Utility.createOrderProduct(order.Id,p.Id,standardPrice.Id);
        order.Sales_End_Customer_Account__c = endCustomerAcc.Id;
        try{
            update order;
        }
        catch(Exception e){
            exceptionMessage = e.getMessage();
        }
        Test.stopTest();
    }*/
}