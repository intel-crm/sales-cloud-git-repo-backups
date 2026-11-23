/*********************************************************************************************************************
Class Name    : Sales_CancelOrderController_Test
Version       : 1.0
Created Date  : Mar 2021  
Function      :  
Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------
* Shivam Vishwakarma        27-Mar-2021              Test class for Sales_CancelOrderController
* *********************************************************************************************************************/
@isTest 
public class Sales_CancelOrderController_Test {
    /*@isTest
    static void testDraftOrderCancellation(){	
        try{
            Id pricebookId = Test.getStandardPricebookId();
            Product2 p1 = Sales_TestFactory_Utility.createNEWProduct();
            PricebookEntry standardPrice1 = Sales_TestFactory_Utility.createPriceBookEntry(p1.Id, pricebookId);
            Account accObj = Sales_TestFactory_Utility.createAccount(); 
            Order o = Sales_TestFactory_Utility.createOrders(accObj.Id, pricebookId,'Licensed Tool Order');
            Id OrderId=o.Id;
            test.startTest();
            String currentReasonFieldValue = 'Cancelled Check';
            Sales_CancelOrderController.setStatusOrderCancelled(OrderId,currentReasonFieldValue);
            test.stopTest();
            String status = [SELECT Sales_status__c FROM Order WHERE Id=:OrderId].Sales_status__c;
            System.assertEquals('Order Cancelled',status);
        }
        catch(Exception e){
            
        }
    }
    @isTest
    static void testException(){	
        try{
            Id OrderId=null;
            test.startTest();
            String currentReasonFieldValue = 'Cancelled Check';
            Sales_CancelOrderController.setStatusOrderCancelled(OrderId,currentReasonFieldValue);
            test.stopTest();
        }
        catch(Exception e){
            Boolean expectedExceptionThrown =  (e.getMessage() != null) ? true : false;
            System.assert(expectedExceptionThrown);
        }
    }
    @isTest
    static void testDraftOrderCancellationFailure(){
        try{
            Id pricebookId = Test.getStandardPricebookId();
            Product2 p1 = Sales_TestFactory_Utility.createNEWProduct();
            PricebookEntry standardPrice1 = Sales_TestFactory_Utility.createPriceBookEntry(p1.Id, pricebookId);
            Account accObj = Sales_TestFactory_Utility.createAccount(); 
            Order o = Sales_TestFactory_Utility.createOrders(accObj.Id, pricebookId,'Licensed Tool Order');
            Id OrderId=o.Id;
            test.startTest();
            Sales_CancelOrderController.setStatusOrderCancelled(OrderId,'');
            test.stopTest();
        }
        catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('Script-thrown exception') ? true : false;
            System.assert(expectedExceptionThrown);
        }
    }
    @isTest
    static void testAuraExceptionMessageParser(){
        String systemExceptionMessageString = 'System.DmlException: Update failed. First exception on row 0; first error: FIELD_CUSTOM_VALIDATION_EXCEPTION,Cannot cancel order without providing Cancellation reason.: []';
        String pureErrorMessage;        
        test.startTest();
        pureErrorMessage=Sales_CancelOrderController.apexExceptionMessageParser(systemExceptionMessageString);
        test.stopTest();        
        System.assertEquals('Cannot cancel order without providing Cancellation reason.', pureErrorMessage);        
    }
    @isTest
    static void validateCancelReason(){
        String cancelCode = '02';   
        test.startTest();
        test.stopTest();        
    }
    @isTest
    static void testDraftOrderCancellationFailure3(){
        try{
            Id pricebookId = Test.getStandardPricebookId();
            Product2 p1 = Sales_TestFactory_Utility.createNEWProduct();
            PricebookEntry standardPrice1 = Sales_TestFactory_Utility.createPriceBookEntry(p1.Id, pricebookId);
            Account accObj = Sales_TestFactory_Utility.createAccount(); 
            Order o = Sales_TestFactory_Utility.createOrders(accObj.Id, pricebookId,'Licensed Tool Order');
            Id OrderId=o.Id;
            test.startTest();
            Sales_CancelOrderController.setStatusOrderCancelled(OrderId,'test');
            update o;
            test.stopTest();
        }
        catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('Cannot cancel order without providing Cancellation reason') ? true : false;
        }
    }
    @isTest
    static void testDraftOrderCancellationFailure4(){
        try{
            Id pricebookId = Test.getStandardPricebookId();
            Product2 p1 = Sales_TestFactory_Utility.createNEWProduct();
            PricebookEntry standardPrice1 = Sales_TestFactory_Utility.createPriceBookEntry(p1.Id, pricebookId);
            Account accObj = Sales_TestFactory_Utility.createAccount(); 
            Order o = Sales_TestFactory_Utility.createOrders(accObj.Id, pricebookId,'Licensed Tool Order');
            Id OrderId=o.Id;
            test.startTest();
            Sales_CancelOrderController.setStatusOrderCancelled(OrderId,'test');
            test.stopTest();
        }
        catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('Cannot cancel order without providing Cancellation reason') ? true : false;
        }
    }*/
}