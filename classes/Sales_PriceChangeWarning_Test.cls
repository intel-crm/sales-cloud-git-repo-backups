/*********************************************************************************************************************
Class Name    : Sales_PriceChangeWarning_Test
Version       : 1.0
Created Date  : April 2021  
Function      :  
Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------
* Nilesh Mithapelli           23-Apr-2021              Updating the field on Order in case of price mismatch with orderproduct
* *********************************************************************************************************************/
@isTest
public class Sales_PriceChangeWarning_Test {       
/*
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
        acc.Core_Sales_Groups__c = 'PRC Sales Group';       
        insert acc;
        return acc;
    }
    public static SBQQ__ProductOption__c createoption(Id configSKUProdId, Id optionalSKUProdId){
        SBQQ__ProductOption__c prodoption = new SBQQ__ProductOption__c();
        prodoption.SBQQ__Number__c = 5;
        prodoption.SBQQ__ConfiguredSKU__c = configSKUProdId;
        prodoption.SBQQ__OptionalSKU__c = optionalSKUProdId ;
        prodoption.SBQQ__Bundled__c = true;
        prodoption.SBQQ__Type__c ='Accessory';
        insert prodoption;
        return prodoption;
    }
    public static Contract createContractAssociatedwithQuoteOrder(Id accId, Id orderId, Id quoteId){
        Contract con = new Contract(); 
        con.AccountId = accId;
        con.SBQQ__Order__c = orderId;
        con.SBQQ__Quote__c = quoteId;
        con.StartDate = System.today();
        con.Status = 'Draft';
        con.ContractTerm = 12; 
        insert con;
        return con;
    }
    Public static List<Sales_License__c> createSalesLicense(Id accId, Id orderId, Id ordProdId, Id prodId ,Id ContractId){
        List<Sales_License__c> liclist = new List<Sales_License__c>();
        Sales_License__c licobj = new Sales_License__c();
        licobj.Sales_License_Account__c = accId;
        licobj.Sales_License_Order__c = orderId;
        licobj.Sales_License_Order_Product__c=ordProdId;
        licobj.Sales_License_Contract__c = ContractId;
        licobj.Sales_License_Start_Date_Dt__c = System.Today();
        licobj.Sales_License_Status__c = 'Licensed';
        licobj.Sales_License_Product__c = prodId;
        licobj.Sales_License_Type__c = 'Original';
        liclist.add(licobj);
        insert liclist;
        return liclist;
    }
    public static Sales_License_Order_Product__c createLicenseOrderProduct(Id licId,Id ContractId){
        Sales_License_Order_Product__c licProd = new  Sales_License_Order_Product__c();
        licProd.Sales_License__c = licId;
        licProd.Sales_License_ContractId__c = ContractId;
        insert licProd;
        return licProd;
    }
    static testmethod void testUnitPriceDistiType(){
        SBQQ.TriggerControl.disable();
        List<SBQQ__QuoteLine__c> quoteLineList = new List<SBQQ__QuoteLine__c>();
        Map<Id,SBQQ__QuoteLine__c> quotemap = New Map<Id,SBQQ__QuoteLine__c>();
        Account accObj = createDiffPSGDownstreamAccounts('Distributor','Distributor');     
        TriggerHandler.bypass('Core_AccountHandler');
        TriggerHandler.bypass('Core_DirectAccount_Handler');
        TriggerHandler.bypass('Core_IPS_Account_Trigger_Handler');
        Contact con = Sales_TestFactory_Utility.createContact(accObj.Id);
        Account acc = Sales_TestDataFactory.createDefaultAccount();
        insert acc;
        Account accEndPricing = Sales_TestDataFactory.createDirectEndCustomerPricingParentAccount();
        insert accEndPricing;
        Account endCustomerAcc = Sales_TestDataFactory.createDefaultAccount();
        endCustomerAcc.Core_PSG_Account__c = true;
        endCustomerAcc.Core_Account_Type__c = 'End Customer';
        endCustomerAcc.Core_Direct_Pricing_Parent_Id__c = accEndPricing.Id;
        endCustomerAcc.Core_Direct_Legal_Parent_Id__c = accEndPricing.Id;
        insert endCustomerAcc;
        TriggerHandler.clearAllBypasses();
        if (SBQQ.TriggerControl.isEnabled()) {
        }
        List<Sales_License_Generator__c> licensegenr = Sales_TestFactory_Utility.createLiceneseGenerator();
        List<Sales_License_Group__c> licgrp = Sales_TestFactory_Utility.createLiceneseGroup(licensegenr[0].Id);
        Core_Product_Ext_Attribute__c licList = Sales_TestFactory_Utility.createProductExtAttribute('BASE',licgrp[0].Id);
        Product2 p = Sales_TestFactory_Utility.createDifferentProducts(licList.Id,'','Sample');
        p.IsActive = true;
        p.Core_Item_Quotable_Ind__c = true;
        p.Core_Product_Org__c = 'Sales';
        update p;
        Set<Id> prodId = new Set<Id>();
        prodId.add(p.Id);
        Opportunity opp = Sales_TestDataFactory.createOpportunityRecord();
        SBQQ.TriggerControl.disable();
        TriggerHandler.bypass('QuoteTriggerHandler');
        opp.put('AccountId',endCustomerAcc.Id);
        insert opp;
        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry standardPrice = Sales_TestFactory_Utility.createPriceBookEntry(p.Id, pricebookId);
        createoption(p.id,p.id);
        SBQQ.TriggerControl.disable();
        TriggerHandler.bypass('QuoteTriggerHandler');
        SBQQ__Quote__c q = Sales_TestDataFactory.createQuoteRecord();
        TriggerHandler.bypass('QuoteTriggerHandler');
        q.SBQQ__Account__c = accObj.Id;
        q.SBQQ__Status__c = 'Approved';
        q.core_cpq_end_customer_nm__c = endCustomerAcc.Id;
        q.SBQQ__Opportunity2__c = opp.Id;
        q.SBQQ__Type__c='Quote';
        SBQQ.TriggerControl.disable();
        TriggerHandler.bypass('QuoteTriggerHandler');
        insert q;
        TriggerHandler.clearBypass('QuoteTriggerHandler');
        SBQQ__QuoteLine__c ql = Sales_TestDataFactory.createQuoteLineRecord();
        SBQQ.TriggerControl.disable();
        TriggerHandler.bypass('QuoteTriggerHandler');
        ql.SBQQ__Quote__c = q.Id;
        ql.SBQQ__PricebookEntryId__c = standardPrice.Id;
        ql.SBQQ__Product__c = p.Id;
        SBQQ.TriggerControl.disable();
        TriggerHandler.bypass('QuoteTriggerHandler');
        TriggerHandler.bypass('QuoteLineTriggerHandler');
        insert ql;
        quoteLineList.add(ql);
        quotemap.put(ql.id,ql);
        TriggerHandler.clearBypass('QuoteTriggerHandler');
        SBQQ.TriggerControl.disable();
        TriggerHandler.bypass('Sales_OrderProductTriggerHandler');
        TriggerHandler.bypass('Sales_OrderTriggerHandler');
        Test.startTest();
        Order o = Sales_TestFactory_Utility.createNonCommOrder();
        o.SBQQ__Quote__c = q.id;
        o.Type='Licensed Tool Order';
        o.Sales_Order_Sub_Type__c='	Standalone license order';
        o.Status='Draft';
        SBQQ.TriggerControl.disable();
        TriggerHandler.bypass('Sales_OrderProductTriggerHandler');
        TriggerHandler.bypass('Sales_OrderTriggerHandler');
        update o;
        TriggerHandler.clearBypass('Sales_OrderTriggerHandler');
        OrderItem oi = Sales_TestDataFactory.createOrderItem(); 
        TriggerHandler.bypass('Sales_OrderProductTriggerHandler');
        TriggerHandler.bypass('Sales_OrderTriggerHandler');
        oi.OrderId = o.Id;
        oi.Quantity = 2;
        oi.UnitPrice = 240;
        oi.Product2Id = p.Id;
        oi.PricebookEntryId = standardPrice.Id;
        oi.SBQQ__QuoteLine__c = ql.Id;
        oi.Sales_Contact__c = con.Id;
        insert oi;    
        q.core_cpq_active_cb__c = true;
        q.SBQQ__Status__c = 'Approved';
        SBQQ.TriggerControl.disable();
        TriggerHandler.clearBypass('QuoteTriggerHandler');
        TriggerHandler.bypass('Sales_OrderTriggerHandler');
        q.SBQQ__Ordered__c=true;
        update q;
        TriggerHandler.clearAllBypasses();
        Test.stopTest(); 
        Map<Id, Order> ordMap = new Map<Id, Order>([Select Id,Sales_End_Customer_Account__c,Sales_Sold_To_Account__c,SBQQ__Quote__r.SBQQ__Opportunity2__c, SBQQ__Quote__c, SBQQ__Quote__r.SBQQ__Type__c,SBQQ__Quote__r.SBQQ__StartDate__c,SBQQ__Quote__r.SBQQ__MasterContract__c,Sales_Req_Ship_Date_Dt__c,EffectiveDate, Type, Sales_Order_Sub_Type__c,Sales_Order_Reason__c, AccountId,SBQQ__Quote__r.Sales_Renewed_from_Contract_Id__c ,Status from Order where Id = :o.id]);
        List<OrderItem> OIList =[Select id,OrderId,Quantity,Product2Id,Sales_Suggested_Resale_Price__c,Sales_Broken_Price_Amt__c,UnitPrice,SBQQ__QuoteLine__c,UnitPriceForceOverride__c from OrderItem where  
                                 OrderId = :o.Id and SBQQ__QuoteLine__c = :ql.Id LIMIT 1] ;
        Sales_PriceChangeWarning.priceMismatchCheck(quoteLineList, quotemap);
    }
*/
}