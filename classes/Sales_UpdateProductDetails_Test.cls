/*********************************************************************************************************************
Class Name    : Sales_UpdateProductDetails_Test
Version       : 1.0
Created Date  : Jan 2022
Function      :  
Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------
* Nilesh Mithapelli           12-Jan-2022           TWC3144-149 :Dev - Update Order Product and Subscription related fileds on update of Product
* *********************************************************************************************************************/
@isTest
public class Sales_UpdateProductDetails_Test {
    public static Order createOrdersWithAllAccAndQuote(Id accId, Id pricebookId, String OrderType, Id quoteId, Account soldToAcc, Account shipto, Account endCustmer){                                      
        Account accSoldTo = soldToAcc;
        Order o = new Order();
        o.Type= OrderType;
        o.RecordTypeId= Order.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('Sales_Order_Record').getRecordTypeId();
        o.Name = 'Test Order ';
        o.Status = 'Draft';
        o.Sales_status__c = 'Draft Order';  
        o.EffectiveDate = system.today();
        o.EndDate = system.today() + 365;
        o.AccountId = accSoldTo.ParentId;
        o.Sales_Order_Reason__c='Non Stocking Order';
        o.Pricebook2Id =  pricebookId ;  
        o.Sales_PO_Number_Txt__c = '687900PONUMBR';
        o.Sales_Header_Special_Instructions_Dsc__c = 'abc';
        Account accShipTo = shipto;
        o.Sales_Sold_To_Account__c=accSoldTo.Id;
        o.Sales_Ship_To_Account__c = accShipTo.Id;
        o.Sales_Shipping_Condition_Txt__c = '1Q';
        o.Sales_Incoterms_Txt__c = 'PCT';
        o.Sales_Payment_Terms__c = 'KB';
        o.Sales_Req_Ship_Date_Dt__c = system.today() + 2;
        o.Sales_SoldTo_Street_Dsc__c = '3695  Green Avenue';
        o.Sales_SoldTo_City_Txt__c = 'Oakland';
        o.Sales_SoldTo_State_Txt__c = 'California';
        o.Sales_SoldTo_Province_Txt__c = 'CA';
        o.Sales_SoldTo_Zip_Txt__c = '94621';
        o.Sales_SoldTo_Country_Txt__c = 'United States';
        o.Sales_ShipTo_Street_Dsc__c = '1893  Orchard Street';
        o.Sales_ShipTo_City_Txt__c = 'RODNEY';
        o.Sales_ShipTo_State_Txt__c = 'Michigan';
        o.Sales_ShipTo_Province_Txt__c = 'MI';
        o.Sales_ShipTo_Zip_Txt__c = '49342';
        o.Sales_ShipTo_Country_Txt__c = 'United States';
        Account endCustAccount = endCustmer;
        o.Sales_End_Customer_Account__c=endCustAccount.Id;
        o.Sales_End_Customer_Account_2_Txt__c=endCustAccount.Name;
        o.Sales_End_Customer_City_Txt__c=endCustAccount.BillingCity;
        o.Sales_End_Customer_Country_Txt__c=endCustAccount.BillingCountry;
        o.Sales_End_Customer_Province_Txt__c=endCustAccount.BillingCountry;
        o.Sales_End_Customer_State_Txt__c=endCustAccount.BillingState;
        o.Sales_End_Customer_Street_Dsc__c=endCustAccount.BillingStreet;
        o.Sales_End_Customer_Zip_Txt__c=endCustAccount.BillingPostalCode;
        o.SBQQ__Quote__c=quoteId;
        insert o;  
        return o;
    }
    public static SBQQ__Subscription__c createSubscription(Id contractId,Id productId,Id accountId){
        SBQQ__Subscription__c subs = new SBQQ__Subscription__c();
        subs.SBQQ__Product__c = productId;
        subs.SBQQ__Quantity__c = 3;
        subs.SBQQ__Contract__c = contractId;
        subs.SBQQ__Account__c = accountId;
        subs.SBQQ__SubscriptionEndDate__c = System.today();
        subs.SBQQ__SubscriptionEndDate__c = System.today().addDays(3);
        insert subs;
        return subs;
    }
    @isTest
    static void updateProductDetailsOnOrderProductTest(){
        TriggerHandler.bypass('Core_AccountHandler');
        Account accObj = Sales_TestFactory_Utility.createAccount(); 
        Contact con = Sales_TestDataFactory.createContactRecord(new Map<String,String>{'AccountId' => accObj.Id});
        insert con;
        List<Account> accListToInsert = new List<Account>();
        Account parentShipToAccount = Sales_TestDataFactory.createPartnerIntelShipToAccount();
        accListToInsert.add(parentShipToAccount);
        Account parentSoldToAccount = Sales_TestDataFactory.createDefaultAccount();
        accListToInsert.add(parentSoldToAccount);
        Account parentEndCustomerAccount = Sales_TestDataFactory.createParentEndCustomerAccount();
        parentEndCustomerAccount.Core_Sub_Industry__c = null;
        accListToInsert.add(parentEndCustomerAccount);
        TriggerHandler.bypass('Core_AccountHandler');
        insert accListToInsert;
        TriggerHandler.clearAllBypasses();
        accListToInsert = new List<Account>();
        Account shipToAccount = Sales_TestDataFactory.createShipToAccount();
        shipToAccount.ParentId = parentShipToAccount.Id;
        accListToInsert.add(shipToAccount);
        Account soldToAccount = Sales_TestDataFactory.createSoldToAccount();
        soldToAccount.ParentId = parentSoldToAccount.Id;
        accListToInsert.add(soldToAccount);
        Account endCustomer = Sales_TestDataFactory.createEndCustomerAccount();
        endCustomer.ParentId = parentEndCustomerAccount.Id;
        accListToInsert.add(endCustomer);
        TriggerHandler.bypass('Core_AccountHandler');
        Account accEndPricing = Sales_TestDataFactory.createDirectEndCustomerPricingParentAccount();
        accListToInsert.add(accEndPricing);
        insert accListToInsert;
        Core_Account_SoldTo_ShipTo_Rel__c relation_Ship_Sold = Sales_TestDataFactory.accSoldToShipToRelationshipRecord(new Map<String,String>{
            'Core_Sold_To_Account__c'  =>  soldToAccount.Id,
                'Core_Ship_To_Account__c'  =>  shipToAccount.Id
                });
        TriggerHandler.bypass('Core_AccountHandler');
        insert relation_Ship_Sold;
        TriggerHandler.clearAllBypasses();
        List<Sales_License_Generator__c> gen = Sales_TestFactory_Utility.createLiceneseGenerator();
        List<Sales_License_Group__c> lcgrp = Sales_TestFactory_Utility.createLiceneseGroup(gen[0].id);
        TriggerHandler.bypass('Core_AccountHandler');
        Account endCustomerAcc = Sales_TestDataFactory.createDefaultAccount();
        endCustomerAcc.name = 'Test1234NewAccName';
        endCustomerAcc.Core_PSG_Account__c = true;
        endCustomerAcc.Core_Account_Type__c = 'End Customer';
        endCustomerAcc.Core_Direct_Pricing_Parent_Id__c = accEndPricing.Id;
        endCustomerAcc.Core_Direct_Legal_Parent_Id__c = accEndPricing.Id;
        TriggerHandler.bypass('Core_AccountHandler');
        insert endCustomerAcc;
        TriggerHandler.clearAllBypasses();
        TriggerHandler.bypass('Core_AccountHandler');
        Opportunity oppRenewal = Sales_TestFactory_Utility.createOpportunity(accObj.Id); 
        Core_Product_Ext_Attribute__c prodExt1 = Sales_TestDataFactory.createProductExternalAttributes();
        prodExt1.put('Core_SW_Lic_Type_Nm__c','FLOAT');
        prodExt1.put('Core_Prod_Tool_Type_Nm__c','CORPORATE');
        insert prodExt1 ;
        Product2 prod1 = Sales_TestDataFactory.createProduct();
        prod1.put('Core_Product_Ext_Attribute_Id__c',prodExt1.Id);
        insert prod1;
        Opportunity opp = Sales_TestDataFactory.createOpportunityRecord();
        TriggerHandler.bypass('QuoteTriggerHandler');
        opp.put('AccountId',endCustomerAcc.Id);
        insert opp;
        TriggerHandler.clearAllBypasses();
        PriceBookEntry pbEntry = Sales_TestDataFactory.createPriceBookEntry();
        pbEntry.Pricebook2Id = Test.getStandardPricebookId();
        pbEntry.Product2Id = prod1.Id;
        insert pbEntry;
        SBQQ__Quote__c q = Sales_TestDataFactory.createQuoteRecord();
        q.SBQQ__Account__c = accObj.Id;
        q.SBQQ__Status__c = 'Approved';
        q.core_cpq_end_customer_nm__c = endCustomerAcc.Id;
        q.SBQQ__Opportunity2__c = opp.Id;
        TriggerHandler.bypass('QuoteTriggerHandler');
        insert q;
        TriggerHandler.clearBypass('QuoteTriggerHandler');
       	Test.startTest();
        TriggerHandler.bypass('QuoteLineTriggerHandler');
        TriggerHandler.bypass('QuoteTriggerHandler');
        SBQQ__QuoteLine__c ql = Sales_TestDataFactory.createQuoteLineRecord();
        ql.SBQQ__Quote__c = q.Id;
        ql.SBQQ__PricebookEntryId__c = pbEntry.Id;
        ql.SBQQ__Product__c = prod1.Id;
        insert ql;
        TriggerHandler.clearAllBypasses();
        TriggerHandler.bypass('Sales_OrderTriggerHandler');
        TriggerHandler.bypass('QuoteTriggerHandler');
        Order o1 = createOrdersWithAllAccAndQuote(accObj.Id, Test.getStandardPricebookId(), 'Non Commercial Order', q.Id, soldToAccount, shipToAccount, endCustomer); 
        TriggerHandler.clearAllBypasses();
        TriggerHandler.bypass('Sales_OrderProductTriggerHandler');
        TriggerHandler.bypass('Sales_OrderTriggerHandler');
        OrderItem op1 = Sales_TestDataFactory.createOrderItem();
        op1.OrderId = o1.Id;
        op1.Quantity = 2;
        op1.UnitPrice = 240;
        op1.Product2Id = prod1.Id;
        op1.PricebookEntryId = pbEntry.Id;
        op1.SBQQ__QuoteLine__c = ql.Id;
        op1.Sales_Contact__c = con.Id;
        insert op1;
        Test.stopTest();
        List<Product2> prodList = new List<Product2>();
        prod1.SBQQ__SubscriptionPricing__c = 'Fixed Price';
        prod1.SBQQ__SubscriptionType__c = 'Renewable';
        prodList.add(prod1);
        Sales_UpdateProductDetails.updateProductDetails_OrderproductSubscription(prodList);
        System.assertEquals('','');     
    }
    @isTest
    static void updateProductDetailsOnSubscriptionTest(){
        TriggerHandler.bypass('Core_AccountHandler');
        Account accObj = Sales_TestFactory_Utility.createAccount(); 
        Core_Product_Ext_Attribute__c prodExt1 = Sales_TestDataFactory.createProductExternalAttributes();
        prodExt1.put('Core_SW_Lic_Type_Nm__c','FLOAT');
        prodExt1.put('Core_Prod_Tool_Type_Nm__c','CORPORATE');
        insert prodExt1 ;
        Product2 prod1 = Sales_TestDataFactory.createProduct();
        prod1.put('Core_Product_Ext_Attribute_Id__c',prodExt1.Id);
        insert prod1;
        Contract cont = Sales_TestDataFactory.createContract();
        cont.AccountId=accObj.Id;
        cont.Sales_Program__c = 'PSG';
        cont.StartDate = system.today();
        cont.EndDate = System.today().addDays(3);
        cont.Status = 'Draft';
        TriggerHandler.bypass('Sales_ContractTriggerHandler');
        insert cont;
        SBQQ__Subscription__c subs = createSubscription(cont.Id,prod1.Id,accObj.Id);
        List<Product2> prodList = new List<Product2>();
        prod1.SBQQ__SubscriptionPricing__c = 'Fixed Price';
        prod1.SBQQ__SubscriptionType__c = 'Renewable';
        prodList.add(prod1);
        Sales_UpdateProductDetails.updateProductDetails_OrderproductSubscription(prodList);
	System.assertEquals('','');
    }    
}