/*********************************************************************************************************************
Class Name    : Sales_OrderCreationValidUtility_Test
Version       : 1.0
Created Date  : May 2021
Function      :  
Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------
* Jasmine Narula           18-May-2021             Test class for Sales_OrderCreationValidUtility_Test 
* *********************************************************************************************************************/
@isTest
public class Sales_OrderCreationValidUtility_Test {
    public static Account createDiffPSGDownstreamAccounts(String CoreAccountType, String Acctype){
        Account acc = new Account();
        acc.RecordTypeId=Pricing_Tender_Utility.getRecordTypeId('Account',Label.Pricing_Tender_Account_RecordType_IntelAccount);  
        acc.Core_PSG_Account__c=true;   
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
    public static SBQQ__Quote__c createQuote(Id distributorId, Id endCusId,Id oppId, Id pbId){
        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        quote.RecordTypeId= SBQQ__Quote__c.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('PSG_Quote_New').getRecordTypeId();
        quote.core_cpq_active_cb__c = true;
        quote.SBQQ__Opportunity2__c = oppId;
        quote.SBQQ__Primary__c = true;
        quote.SBQQ__PriceBook__c = pbId;
        quote.core_cpq_business_unit_nm__c = 'Military';
        quote.core_cpq_quote_type_nm__c='Design Win';
        quote.SBQQ__StartDate__c = date.today()+10;
        quote.SBQQ__SubscriptionTerm__c = 12;
        quote.SBQQ__Status__c = 'Approved';
        quote.core_cpq_end_customer_nm__c=endCusId;
        quote.SBQQ__Account__c=distributorId;
        insert quote;
        return quote;
    }
    public static List<Order> createListofOrderswithQUote(Id accId, Id pricebookId, Id qId){
        List<Account> accList = new List<Account>();
        Account intelSoldto = Sales_TestFactory_Utility.createIntelSoldAccount();
        Account intelShipAcc = Sales_TestFactory_Utility.createIntelShipAccount();
        accList.add(intelSoldto);
        accList.add(intelShipAcc);
        insert accList;				
        List<Account> accList2 = new List<Account>();
        accList2.add(Sales_TestFactory_Utility.createSoldToAccount());
        accList2.add(Sales_TestFactory_Utility.createShipToAccount());
        insert accList2;
        Account accSoldTo = accList2[0];
        Account accShipTo = accList2[1];
        List<Order> orList = new List<Order>();
        Order o = new Order();
        o.Sales_PO_Number_Txt__c = '687900077999898';
        o.Sales_Header_Special_Instructions_Dsc__c = 'abc';
        o.Sales_Ship_To_Account__c = accShipTo.Id;
        o.Name = 'Test Order ';
        o.Status = 'Draft';
        o.Sales_status__c = 'Draft Order'; 
        o.EffectiveDate = system.today();
        o.EndDate = system.today() + 4;
        o.AccountId = accId;
        o.Sales_Sold_To_Account__c=accSoldTo.Id;
        o.Type='Licensed Tool Order';
        o.Sales_Order_Reason__c='Non Stocking Order';
        o.Pricebook2Id = pricebookId ;
        o.SBQQ__Quote__c=qId;
        orList.add(o);
        insert orList;
        return orList;
    }
    public static List<Order> createListofOrders(Id accId, Id pricebookId, String sType){
        List<Account> accList = new List<Account>();
        Account intelSoldto = Sales_TestFactory_Utility.createIntelSoldAccount();
        Account intelShipAcc = Sales_TestFactory_Utility.createIntelShipAccount();
        accList.add(intelSoldto);
        accList.add(intelShipAcc);
        insert accList;				
        List<Account> accList2 = new List<Account>();
        accList2.add(Sales_TestFactory_Utility.createSoldToAccount());
        accList2.add(Sales_TestFactory_Utility.createShipToAccount());
        insert accList2;
        Account accSoldTo = accList2[0];
        Account accShipTo = accList2[1];
        List<Order> orList = new List<Order>();
        Order o = new Order();
        o.Sales_PO_Number_Txt__c = '687900077999898';
        o.Sales_Header_Special_Instructions_Dsc__c = 'abc';
        o.Sales_Ship_To_Account__c = accShipTo.Id;
        o.Sales_Shipping_Condition_Txt__c = accShipTo.Core_Direct_Shipping_Condition_Nm__c; 
        o.Name = 'Test Order ';
        o.Status = 'Draft';
        o.Sales_status__c = 'Draft Order'; 
        o.EffectiveDate = system.today();
        o.EndDate = system.today() + 4;
        o.AccountId = accId;
        o.Sales_Sold_To_Account__c = accSoldTo.Id;
        o.Type=sType;
        o.Sales_Order_Reason__c='Non Stocking Order';
        o.Pricebook2Id = pricebookId ;
        orList.add(o);
        insert orList;
        return orList;
    }
    public static Account createQuoteEndCustomer(String CoreAccountType, String Acctype){
        Account acc = new Account();
        acc.RecordTypeId=Pricing_Tender_Utility.getRecordTypeId('Account',Label.Pricing_Tender_Account_RecordType_IntelAccount);
        acc.Core_PSG_Account__c=true; 
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
        Account pricingParent = Sales_TestFactory_Utility.createEndCustAccount();
        acc.Core_Direct_Pricing_Parent_Id__c = pricingParent.Id;
        insert acc;
        return acc;
    }
    static testmethod void validateNonCommericalOrder(){
        Order o = Sales_TestFactory_Utility.createNonCommOrder();
        List<Order> ordList = new List<Order>();
        ordList.add(o);
        List<Sales_License_Generator__c> licensegenr = Sales_TestFactory_Utility.createLiceneseGenerator();
        List<Sales_License_Group__c> licgrp = Sales_TestFactory_Utility.createLiceneseGroup(licensegenr[0].Id);
        Core_Product_Ext_Attribute__c licList = Sales_TestFactory_Utility.createProductExtAttribute('BASE',licgrp[0].Id);
        Id pricebookId = Test.getStandardPricebookId();
        Account accObj = [Select id from Account limit 1];
        Contact con = Sales_TestFactory_Utility.createContact(accObj.Id);
        Product2 p = Sales_TestFactory_Utility.createDifferentProducts(licList.Id, 'SV', 'myARM');
        p.Core_Item_Orderable_Ind__c = true;
        update p;
        PricebookEntry standardPrice = Sales_TestFactory_Utility.createPriceBookEntry(p.Id, pricebookId);
        test.startTest();    
        List<OrderItem> oi = Sales_TestFactory_Utility.createOrderProductList1(o.Id, p.Id, standardPrice.Id, con.id);
        o.Sales_status__c = 'Activated';
        update o;
        Sales_OrderCreationValidationUtility.checksubOrderType(ordList);
        test.stopTest();
    }
    static testmethod void checkdevKit(){
        List<OrderItem> orderItemList = new List<OrderItem>();
        List<Order> ordList = new List<Order>();
        Map<Id,Id> orderToEndCustomerMap =new Map<Id,Id>();
        Map<Id,Order> orderOldMap=new Map<Id,Order>();
        Map<Id,Set<String>> salesLicenseControlMap =new Map<Id,Set<String>>();
        List<Sales_License_Generator__c> licensegenr = Sales_TestFactory_Utility.createLiceneseGenerator();
        List<Sales_License_Group__c> licgrp = Sales_TestFactory_Utility.createLiceneseGroup(licensegenr[0].Id);
        Core_Product_Ext_Attribute__c licList = Sales_TestFactory_Utility.createProductExtAttribute('BASE',licgrp[0].Id);
        Product2 p = Sales_TestFactory_Utility.createDifferentProducts(licList.Id, 'BD', 'myCorp');
        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry standardPrice = Sales_TestFactory_Utility.createPriceBookEntry(p.Id, pricebookId);
        Account endCustomerAcc = Sales_TestFactory_Utility.createEndCustomerAccount();
        try{
            Order order = Sales_TestFactory_Utility.createOrders(endCustomerAcc.Id,pricebookId, 'Sample Order');
            OrderItem oi = Sales_TestFactory_Utility.createOrderProduct(order.Id, p.Id, standardPrice.Id);
            orderItemList.add(oi);
            Test.startTest();
            Sales_OrderCreationValidationUtility.validateOrderProducts(orderItemList);
        }
        catch(Exception e){
        }
    }
    static testmethod void validateSoftwarePRoduct(){
        Order o = Sales_TestFactory_Utility.createNonCommOrder();
        List<Order> ordList = new List<Order>();
        ordList.add(o);
        List<Sales_License_Generator__c> licensegenr = Sales_TestFactory_Utility.createLiceneseGenerator();
        List<Sales_License_Group__c> licgrp = Sales_TestFactory_Utility.createLiceneseGroup(licensegenr[0].Id);
        Core_Product_Ext_Attribute__c licList = Sales_TestFactory_Utility.createProductExtAttribute('SOFTWARE',licgrp[0].Id);
        Id pricebookId = Test.getStandardPricebookId();
        Account accObj = [Select id from Account limit 1];
        Contact con = Sales_TestFactory_Utility.createContact(accObj.Id);
        Product2 p = Sales_TestFactory_Utility.createDifferentProducts(licList.Id, 'SV', 'myARM');
        p.Core_Item_Orderable_Ind__c = true;
        update p;
        PricebookEntry standardPrice = Sales_TestFactory_Utility.createPriceBookEntry(p.Id, pricebookId);
        test.startTest();    
        List<OrderItem> oi = Sales_TestFactory_Utility.createOrderProductList1(o.Id, p.Id, standardPrice.Id, con.id);
        o.Sales_status__c = 'Activated';
        update o;
        Sales_OrderCreationValidationUtility.checksubOrderType(ordList);
        test.stopTest();
    }
    static testmethod void validateIPProduct(){
        Order o = Sales_TestFactory_Utility.createNonCommOrder();
        List<Order> ordList = new List<Order>();
        ordList.add(o);
        List<Sales_License_Generator__c> licensegenr = Sales_TestFactory_Utility.createLiceneseGenerator();
        List<Sales_License_Group__c> licgrp = Sales_TestFactory_Utility.createLiceneseGroup(licensegenr[0].Id);
        Core_Product_Ext_Attribute__c lc = Sales_TestFactory_Utility.createProductExtAttribute('IP',licgrp[0].Id);
        lc.Core_SW_Prod_Avail_To_TL_ORD_ENBLMT_Ind__c = true;
        update lc;
        Id pricebookId = Test.getStandardPricebookId();
        Account accObj = [Select id from Account limit 1];
        Contact con = Sales_TestFactory_Utility.createContact(accObj.Id);
        Product2 p = Sales_TestFactory_Utility.createDifferentProducts(lc.Id, 'SV', 'myARM');
        p.Core_Item_Orderable_Ind__c = true;
        update p;
        PricebookEntry standardPrice = Sales_TestFactory_Utility.createPriceBookEntry(p.Id, pricebookId);
        test.startTest();    
        List<OrderItem> oi = Sales_TestFactory_Utility.createOrderProductList1(o.Id, p.Id, standardPrice.Id, con.id);
        o.Sales_status__c = 'Activated';
        update o;
        Sales_OrderCreationValidationUtility.checksubOrderType(ordList);
        test.stopTest();
    }
    static testmethod void validatStandaloneProduct(){
        Order o = Sales_TestFactory_Utility.createNonCommOrder();
        List<Order> ordList = new List<Order>();
        ordList.add(o);
        List<Sales_License_Generator__c> licensegenr = Sales_TestFactory_Utility.createLiceneseGenerator();
        List<Sales_License_Group__c> licgrp = Sales_TestFactory_Utility.createLiceneseGroup(licensegenr[0].Id);
        Core_Product_Ext_Attribute__c lc = Sales_TestFactory_Utility.createProductExtAttribute('IP',licgrp[0].Id);
        lc.Core_SW_Prod_Avail_To_TL_ORD_ENBLMT_Ind__c = true;
        update lc;
        Id pricebookId = Test.getStandardPricebookId();
        Account accObj = [Select id from Account limit 1];
        Contact con = Sales_TestFactory_Utility.createContact(accObj.Id);
        Product2 p = Sales_TestFactory_Utility.createDifferentProducts(lc.Id, '', 'myARM');
        p.Core_Item_Orderable_Ind__c = true;
        update p;
        PricebookEntry standardPrice = Sales_TestFactory_Utility.createPriceBookEntry(p.Id, pricebookId);
        test.startTest();    
        List<OrderItem> oi = Sales_TestFactory_Utility.createOrderProductList1(o.Id, p.Id, standardPrice.Id, con.id);
        o.Sales_status__c = 'Activated';
        update o;
        Sales_OrderCreationValidationUtility.checksubOrderType(ordList);
        test.stopTest();
    }
}