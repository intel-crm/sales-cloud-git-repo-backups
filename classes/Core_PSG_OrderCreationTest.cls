/*********************************************************************************************************************
Class Name    : Core_PSG_OrderCreationTest
Version       : 1.0
Created Date  : Jan 2021
Function      :  

Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------
* Nilesh Mithapelli           11-Jan-2021             Order Creation test class
* *********************************************************************************************************************/
@isTest
public class Core_PSG_OrderCreationTest {
    
    /*static testmethod void testOrderCreation(){
        try{
            test.startTest();
            //Account accObj = Core_PSG_TestFactory_Utility.createAccount();    
            Order o = new Order();
           // o.AccountId = accObj.Id;
            o.Type='Corporate License Order';
            o.Sales_Order_Reason__c='Stocking Order';  //US 919632: Previously was o.Core_PSG_Order_Reason__c='Stocking Order';
            o.EffectiveDate = system.today();
            o.Status = 'New';
            Core_PSG_OrderCreation.createOrder(o);
            System.assertEquals('Corporate License Order', o.Type);
            test.stopTest();
        }
        catch(Exception e){
            System.debug(e.getMessage());
        }
        
    }
    
    static testmethod void testOrderCreationNew(){
        try{
            test.startTest();
           // Account accObj = Core_PSG_TestFactory_Utility.createAccount();  
            //Contact con = Core_PSG_TestFactory_Utility.createContact(accObj.Id);
            Product2 p = Core_PSG_TestFactory_Utility.createProductWithDEVKit();
            Id pricebookId = Test.getStandardPricebookId();
            PricebookEntry standardPrice = Core_PSG_TestFactory_Utility.createPriceBookEntry(p.Id, pricebookId);
            Order o = Core_PSG_TestFactory_Utility.createOrders(accObj.Id, pricebookId);
            o.type = 'ABC';
            update o;
            Order odd = Core_PSG_OrderCreation.createOrder(o); 
        }
        catch(Exception e){
            System.debug(e.getMessage());
        }
    }*/
}