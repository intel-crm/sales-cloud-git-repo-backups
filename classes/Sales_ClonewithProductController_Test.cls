/*********************************************************************************************************************
Class Name    : Sales_ClonewithProductController_Test
Version       : 1.0
Created Date  : Feb 2021  
Function      :  

Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------
* Jasmine Narula           25-Feb-2021              Test class for Sales_CloneOrderwithProductController
* *********************************************************************************************************************/
@isTest
public class Sales_ClonewithProductController_Test {
    
    /*public static Account createDiffPSGDownstreamAccounts(String CoreAccountType, String Acctype){
        Account acc = new Account();
        acc.RecordTypeId=Pricing_Tender_Utility.getRecordTypeId('Account',Label.Pricing_Tender_Account_RecordType_IntelAccount);  
        acc.Core_PSG_Account__c=true;   // PSG Downstream true
        acc.Name = 'AccName - '+String.valueof((Math.random() * 1000));
        acc.Core_Account_Type__c = CoreAccountType;
        acc.Industry = 'Education';
        acc.Core_Sub_Industry__c = 'Student';
        acc.BillingCity = 'New york';
        acc.BillingState='ME';
        acc.BillingCountry = 'USA';
        acc.BillingStreet = 'New U';
        acc.BillingPostalCode='04685';
        acc.Type = Acctype;
        acc.Core_Sales_Groups__c = 'CCG Sales Group';       
        insert acc;
        return acc;
    }
    
    
    static testmethod void testCloneOrderProduct(){

            Account endCustomerObj = createDiffPSGDownstreamAccounts('End Customer','End User');  //(String CoreAccountType, String Acctype)
            Account accObj = createDiffPSGDownstreamAccounts('Distributor','Distributor');     
            Contact con = Sales_TestFactory_Utility.createContact(accObj.Id);
            List<Sales_License_Generator__c> licensegenr = Sales_TestFactory_Utility.createLiceneseGenerator();
            List<Sales_License_Group__c> licgrp = Sales_TestFactory_Utility.createLiceneseGroup(licensegenr[0].Id);
            Core_Product_Ext_Attribute__c licList = Sales_TestFactory_Utility.createProductExtAttribute('BASE',licgrp[0].Id);
            Product2 p = Sales_TestFactory_Utility.createDifferentProducts(licList.Id,'','myBase');           
            Id pricebookId = Test.getStandardPricebookId();
            PricebookEntry standardPrice = Sales_TestFactory_Utility.createPriceBookEntry(p.Id, pricebookId);
                
            Order o = Sales_TestFactory_Utility.createOrders(endCustomerObj.Id, pricebookId,'Licensed Tool Order');
            Test.startTest();
            OrderItem OI = Sales_TestFactory_Utility.createOrderProductAllFields(o.Id, p.Id, standardPrice.id);//[Select id,OrderId from OrderItem where OrderId =:o.Id];
            Test.stopTest();
            /*o.Sales_status__c='Order Cancelled';
o.Sales_Cancelled_Reason_Dsc__c='test';
update o;*/
            
            //Order o1 = Sales_TestFactory_Utility.createOrders(endCustomerObj.Id, pricebookId, 'Licensed Tool Order');//[Select Id , SBQQ__Quote__c from Order];
            /*String isReturnMsg = 'success';
            Sales_CloneOrderwithProductController.insertOrderProducts(null, o.Id);
            
        }
        /*catch(Exception e){
            System.debug('e=>'+e.getMessage());
            //Boolean expectedExceptionThrown =  e.getMessage().contains('Cannot Activate Order Manually In case of \'Draft Order\' or \'SAP order Creation Failed') ? true : false;
            //System.assert(expectedExceptionThrown);
}*/
    
   /* static testmethod void testfailedCloneOrderProduct(){
        try{
            // Account accObj = Sales_TestFactory_Utility.createAccountTypeDirect();  
            Account endCustomerObj = createDiffPSGDownstreamAccounts('End Customer','End User');  //(String CoreAccountType, String Acctype)
            Account accObj = createDiffPSGDownstreamAccounts('Distributor','Distributor');     
            Contact con = Sales_TestFactory_Utility.createContact(accObj.Id);
            List<Sales_License_Generator__c> licensegenr = Sales_TestFactory_Utility.createLiceneseGenerator();
            List<Sales_License_Group__c> licgrp = Sales_TestFactory_Utility.createLiceneseGroup(licensegenr[0].Id);
            Core_Product_Ext_Attribute__c licList = Sales_TestFactory_Utility.createProductExtAttribute('BASE',licgrp[0].Id);
            Product2 p = Sales_TestFactory_Utility.createDifferentProducts(licList.Id,'','myBase');           
            
            Id pricebookId = Test.getStandardPricebookId();
            PricebookEntry standardPrice = Sales_TestFactory_Utility.createPriceBookEntry(p.Id, pricebookId);
            Order o = Sales_TestFactory_Utility.createOrders(endCustomerObj.Id, pricebookId, 'Licensed Tool Order');//[Select Id , SBQQ__Quote__c from Order];
            Test.startTest();
            OrderItem OI = Sales_TestFactory_Utility.createOrderProductAllFields(o.Id, p.Id, standardPrice.id);//[Select id,OrderId from OrderItem where OrderId =:o.Id];
            o.Sales_status__c='Order Cancelled';
            o.Sales_Cancelled_Reason_Dsc__c='test';
            update o;

            Order o1 = Sales_TestFactory_Utility.createOrders(endCustomerObj.Id, pricebookId, 'Licensed Tool Order');//[Select Id , SBQQ__Quote__c from Order];
            //OrderItem OIList1 = Sales_TestFactory_Utility.createOrderProduct(o1.Id, p.Id, standardPrice.id);//[Select id,OrderId from OrderItem where OrderId =:o1.Id];
            Test.stopTest();
            Sales_CloneOrderwithProductController.insertOrderProducts(o1.Id, o.Id); 
        }catch(Exception e){
            System.debug('e=>'+e.getMessage());
            //Boolean expectedExceptionThrown =  e.getMessage().contains('Cannot Activate Order Manually In case of \'Draft Order\' or \'SAP order Creation Failed') ? true : false;
            //System.assert(expectedExceptionThrown);
        }
    }*/
}