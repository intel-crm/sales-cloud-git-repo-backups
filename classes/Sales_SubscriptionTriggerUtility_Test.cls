/*********************************************************************************************************************
Class Name    : Sales_SubscriptionTriggerUtility_Test
Version       : 1.0
Created Date  : 14 Jan 2021
Function      :  

Modification Log :
* Developer                     Date                    Description
* ---------------------------------------------------------------------------------------------------------
* Nilesh Mithapelli           14-Jan-2021              Test class for Sales_SubscriptionTriggerUtility
* *********************************************************************************************************************/
@isTest
public class Sales_SubscriptionTriggerUtility_Test { 
    static testmethod void testCreateSubsc(){
        Account accObj = Sales_TestFactory_Utility.createAccount();    
        Contact con = Sales_TestFactory_Utility.createContact(accObj.Id);
        //Product2 p = Sales_TestFactory_Utility.createProductWithDEVKit();
        Id pricebookId = Test.getStandardPricebookId();
        //PricebookEntry standardPrice = Sales_TestFactory_Utility.createPriceBookEntry(p.Id, pricebookId);
        //Order o = Sales_TestFactory_Utility.createOrders(accObj.Id, pricebookId);
        List<Contract> cont = Sales_TestFactory_Utility.createContract(accObj.Id);
        //List<OrderItem> OIList = Sales_TestFactory_Utility.createOrderProductList(o.Id, p.Id, standardPrice.Id);
        //List<SBQQ__Subscription__c> subsList = Sales_TestFactory_Utility.createSubscriptions(cont[0].Id, p.Id, accObj.Id, o.Id,OIList[0].Id);
        
        Test.startTest();
       // Sales_SubscriptionTriggerUtility.createOrderActCode(subsList);  
        Test.stopTest(); 
        
    }
    
    static testmethod void testSubscriptionStartDate(){
        Account accObj = Sales_TestFactory_Utility.createAccount();    
        Contact con = Sales_TestFactory_Utility.createContact(accObj.Id);
        //Product2 p = Sales_TestFactory_Utility.createProduct();
        Id pricebookId = Test.getStandardPricebookId();
        //PricebookEntry standardPrice = Sales_TestFactory_Utility.createPriceBookEntry(p.Id, pricebookId);
        //Order o = Sales_TestFactory_Utility.createOrders(accObj.Id, pricebookId);
        List<Contract> cont = Sales_TestFactory_Utility.createContract(accObj.Id);
        //List<OrderItem> OIList = Sales_TestFactory_Utility.createOrderProductList(o.Id, p.Id, standardPrice.Id);
        //List<SBQQ__Subscription__c> subsList = Sales_TestFactory_Utility.createSubs(cont[0].Id, p.Id, accObj.Id, o.Id,OIList[0].Id);
        
        Test.startTest();
        //Sales_SubscriptionTriggerUtility.updateSubscriptionStartEndDate(subsList);  
        Test.stopTest(); 
    }   
}