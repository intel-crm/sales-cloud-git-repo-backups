/*********************************************************************************************************************
Class Name    : Sales_PriceBookOverrideController_Test
Version       : 1.0
Created Date  : April 2021  
Function      :  
Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------
* Puja Ingale        15-April-2021              Test class for Sales_PriceBookOverrideController
* *********************************************************************************************************************/
@isTest 
public class Sales_PriceBookOverrideController_Test {
    /*@isTest
    static void testSetPricebook(){	
        try{
            Id pricebookId = Test.getStandardPricebookId();
            Account accObj = Sales_TestFactory_Utility.createAccount(); 
            Order o = Sales_TestFactory_Utility.createOrders(accObj.Id, pricebookId,'Licensed Tool Order');
            Id OrderId=o.Id;
            test.startTest();
            Sales_PriceBookOverrideController.setPricebook(OrderId,pricebookId);
            test.stopTest();
            Id priceBook = [SELECT Pricebook2Id FROM Order WHERE Id=:OrderId].Pricebook2Id;
            System.assertEquals(pricebookId,priceBook);
        }
        catch(Exception e){
            System.assert(false);    
        }
    }
    @isTest
    static void testInactivePriceBook(){
        try{
            Account accObj = Sales_TestFactory_Utility.createAccount(); 
            Id pricebookId = Test.getStandardPricebookId();
            PriceBook2 pId = new PriceBook2(name = 'Test PriceBook',isActive=false);
            insert pId;
            Order o = Sales_TestFactory_Utility.createOrders(accObj.Id,pricebookId,'Sample Order');
            test.startTest();
            Sales_PriceBookOverrideController.setPricebook(o.Id,pId.Id);
            test.stopTest();
        }
        catch(Exception e){
            /*String systemExceptionMessageString = 'System.DmlException: Update failed. First exception on row 0; first error: FIELD_CUSTOM_VALIDATION_EXCEPTION,Can not select an Inactive Pricebook: []';     
System.Assert(true);*/
            /*Boolean expectedExceptionThrown =  e.getMessage().contains('Script-thrown exception') ? true : false;
            System.assert(expectedExceptionThrown);
        }
    }
    @isTest
    static void testPriceBook(){
        try{
            Account accObj = Sales_TestFactory_Utility.createAccount(); 
            Id pricebookId = Test.getStandardPricebookId();
            Order o = Sales_TestFactory_Utility.createOrders(accObj.Id, pricebookId,'Licensed Tool Order');
            PriceBook2 pId = new PriceBook2(name = 'Test PriceBook',isActive=true);
            insert pId;
            test.startTest();
            Sales_PriceBookOverrideController.setPricebook(null,pricebookId);
            test.stopTest();
        }
        catch(Exception e){   
            Boolean expectedExceptionThrown =  (e.getMessage() != null) ? true : false;
            System.assert(expectedExceptionThrown); 
        }
    }*/
}