/*********************************************************************************************************************
Class Name    : Sales_DisplayWarningTest
Version       : 1.0
Created Date  : Jan 2021
Function      :  
Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------
* Shalini Kumari          27-Jan-2021             Display Warning Test Class
* *********************************************************************************************************************/
@isTest
public class Sales_DisplayWarningTest {
    /*public static Account createDiffPSGDownstreamAccounts(String CoreAccountType, String Acctype){
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
    public static Account createAccount(){
        Account acc = new Account();
        acc.RecordTypeId= Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Mastered_Account').getRecordTypeId();
        acc.Name = 'Test Account'+System.now();
        acc.Core_Account_Type__c = 'Distributor;End Customer';
        acc.Industry = 'Banking';
        acc.BillingCity = 'Texas';
        acc.BillingCountry = 'USA';
        acc.BillingStreet = 'G-2101'; 
        acc.Core_Sales_Groups__c = 'CCG Sales Group'; 
        acc.Core_Geo__c = 'APJ';
        acc.Core_Sub_Geo__c = 'IJKK';
        acc.Core_PSG_Account__c = true;
        acc.Core_Account_Tier__c ='PSG-Tier 4';
        acc.Core_Partner_Alliance_Program__c ='PSG Demand Creation - PSG';
        acc.Core_Account_BU_Focus__c='PSG-CM;PSG-DISTI';
        insert acc;
        System.assert(acc.Id!=null,'New Account created sucessfully');
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
        quote.SBQQ__Type__c = 'Quote';
        quote.core_cpq_quote_type_nm__c='Design Win';
        quote.SBQQ__StartDate__c = date.today();
        quote.SBQQ__SubscriptionTerm__c = 12;
        quote.SBQQ__Status__c = 'Approved';
        quote.core_cpq_end_customer_nm__c=endCusId;
        quote.SBQQ__Account__c=distributorId;
        insert quote;
        return quote;
    }
    public static Account createDirectAccount(){
        Account directacc = new Account();
        directacc.RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Core_Direct_Account').getRecordTypeId();      
        directacc.Name = 'Test Account'+System.now();
        directacc.Core_Account_Type__c = 'Distributor;End Customer';
        directacc.Industry = 'Banking';
        directacc.BillingCity = 'Texas';
        directacc.BillingCountry = 'USA';
        directacc.BillingStreet = 'G-2101'; 
        directacc.Core_Sales_Groups__c = 'CCG Sales Group'; 
        directacc.Core_Geo__c = 'APJ';
        directacc.Core_Sub_Geo__c = 'IJKK';
        directacc.Core_PSG_Account__c = true;
        directacc.Core_Account_Tier__c ='PSG-Tier 4';
        directacc.Core_Direct_Account_Type_Nm__c = 'End Customer Parent';
        directacc.Core_Is_Pricing_Parent_ChkBox__c=true;
        insert directacc;
        System.assert(directacc.Id!=null,'New Account created sucessfully');
        return directacc;   
    }
    public static Account createSoldToAccount(Id acc,String type){        
        Account ac2 = new Account();
        ac2.RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Core_Direct_Account').getRecordTypeId();
        ac2.Name = 'CREATESoldtoAcc'+Integer.valueOf(Math.random()*1000);
        ac2.ParentId = acc;
        ac2.Core_Direct_Account_Active_Ind__c=true;
        ac2.Core_Account_Type__c = 'Distributor';
        ac2.BillingCity = 'Billing City Test Nasr Billing City CD';
        ac2.BillingState = 'MT';
        ac2.BillingCountry = 'EGY';
        ac2.BillingStreet = 'CYASt. No. 16, Free ZoneXYZ '; 
        ac2.Core_Direct_Account_Type_Nm__c='Sold To';
        ac2.Type='End User';
        ac2.Core_Direct_Payment_Term_Nm__c = 'U';
        ac2.Core_PSG_Account__c=true;
        ac2.Core_Sales_Groups__c = 'PRC Sales Group';    
        ac2.Core_Direct_Sales_Organization_Nm__c='AM03';
        ac2.Core_Direct_Distributor_Channel_Nm__c=type;
        ac2.Core_Geo__c='ASMO';
        insert ac2;
        return ac2;
    }
    public static List<core_cpq_list_price__c> createCPQListPrice(Id prod,Id pbEntry){
        core_cpq_list_price__c cpqlist = new core_cpq_list_price__c();
        cpqlist.core_cpq_list_price_amt__c = 200;
        cpqlist.core_cpq_lowerbound_qty__c = 0;
        cpqlist.core_cpq_upperbound_qty__c = 10;
        cpqlist.core_cpq_product_name__c  =  prod;
        cpqlist.Pricebookentry__c = pbEntry;
        insert cpqlist;
        core_cpq_list_price__c cpqlist2 = new core_cpq_list_price__c();
        cpqlist2.core_cpq_list_price_amt__c = 300;
        cpqlist2.core_cpq_lowerbound_qty__c = 11;
        cpqlist2.core_cpq_upperbound_qty__c = 20;
        cpqlist2.core_cpq_product_name__c  =  prod;
        cpqlist2.Pricebookentry__c = pbEntry;
        insert cpqlist2;
        List<core_cpq_list_price__c> cpList = new List<core_cpq_list_price__c>();
        cpList.add(cpqlist);
        cplist.add(cpqlist2);
        return cpList;   
    } 
    public static Core_Product_Ext_Attribute__c createProdExtAtt_withFoundationProdFLoat(String toolType, Id lcGroupid, String LicType){
        Core_Product_Ext_Attribute__c l1 = new Core_Product_Ext_Attribute__c();
        l1.Core_SW_Lic_Enforcement_Method_Nm__c = 'File';
        l1.Core_Prod_Tool_Type_Nm__c = toolType;
        l1.Core_SW_Lic_Type_Nm__c = LicType ;
        l1.Core_SW_Prod_Max_Rehost_Cnt__c = 1;
        l1.Core_SW_Prod_Web_Dsc__c='Test';
        l1.Core_SW_Lic_File_Data_Encryption_Std_Cd__c = '1DES' ;
        l1.Core_SW_Prod_Avail_To_TL_ORD_ENBLMT_Ind__c = true;
        l1.Core_SW_Lic_Group_Id__c = lcGroupid;
        l1.Core_SW_Lic_Generator_Parameter_Txt__c = 'testing';
        insert l1;
        return l1;
    }
    public static Core_Product_Ext_Attribute__c createProdExtAtt_withFoundationProd(String toolType, Id lcGroupid, Id foundationProdId ){
        Core_Product_Ext_Attribute__c l1 = new Core_Product_Ext_Attribute__c();
        l1.Core_SW_Lic_Enforcement_Method_Nm__c = 'File';
        l1.Core_Prod_Tool_Type_Nm__c = toolType;
        l1.Core_Foundation_Product_Id__c=foundationProdId;
        l1.Core_SW_Lic_Type_Nm__c = 'FIXED' ; 
        l1.Core_SW_Prod_Max_Rehost_Cnt__c = 1;
        l1.Core_SW_Prod_Web_Dsc__c='Test';
        l1.Core_SW_Lic_File_Data_Encryption_Std_Cd__c = '1DES' ;
        l1.Core_SW_Prod_Avail_To_TL_ORD_ENBLMT_Ind__c = true;
        l1.Core_SW_Lic_Group_Id__c = lcGroupid;
        l1.Core_SW_Lic_Generator_Parameter_Txt__c = 'testing';
        insert l1;
        return l1;
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
    public static SBQQ__QuoteLine__c createQuoteLinewithSpecificQuantity(Id quoteId, Id productId, Id pricebookEntryId, Integer specQty){
        SBQQ__QuoteLine__c quoteLine = new SBQQ__QuoteLine__c(); 
        quoteLine.SBQQ__Product__c = productId;
        quoteLine.Pricing_OEM_System_Model_Nm__c = 'Test OEM System Model';
        quoteline.SBQQ__PricebookEntryId__c = pricebookEntryId;
        quoteLine.Pricing_Systems_qty__c = 10; 
        quoteline.SBQQ__Quantity__c = specQty;
        quoteline.core_cpq_quote_line_type_txt__c = 'AVP';
        quoteline.SBQQ__DefaultSubscriptionTerm__c= 12;
        quoteLine.Pricing_pm_approval_comments_nm__c = 'Test Comment';
        quoteLine.Pricing_CPUs_per_system_qty__c = 1;
        quoteLine.Pricing_Single_System_Price_Amt__c = 4;
        quoteLine.Pricing_OEM_Standard_Unit_Price_Amt__c = 2;
        quoteLine.Pricing_Req_Discounted_Unit_Price__c = 1;
        quoteLine.Pricing_Additional_OEM_Discount_Amt__c = 1;
        quoteLine.Pricing_Other_Competitor_Product_Nm__c = 'Test Tender Prod';
        quoteLine.Pricing_Market_Segment_Nm__c = 'Non Embedded';   
        quoteLine.SBQQ__Quote__c = quoteId;
        quoteLine.SBQQ__StartDate__c = date.today();
        quoteLine.SBQQ__EndDate__c = date.today()+375;
        quoteline.price_brokencost_amt__c = 67;
        quoteline.price_requested_resale_amt__c=55;
        quoteline.price_suggested_resale_amt__c=89;
        insert quoteLine;
        return quoteLine;
    }
    static testmethod void testRenewalOrderDate(){
        Account accObj = Sales_TestFactory_Utility.createAccount(); 
        Contact con = Sales_TestFactory_Utility.createContact(accObj.Id);
        List<Sales_License_Generator__c> gen = Sales_TestFactory_Utility.createLiceneseGenerator();
        List<Sales_License_Group__c> lcgrp = Sales_TestFactory_Utility.createLiceneseGroup(gen[0].id);
        Core_Product_Ext_Attribute__c lc = Sales_TestFactory_Utility.createProductExtAttribute('BASE',lcgrp[0].id);
        Product2 baseProd = Sales_TestFactory_Utility.createDifferentProducts(lc.id, '', 'myBase');
        baseProd.Core_Sales_Visible_Flag__c=false;
        update baseProd;
        Core_Product_Ext_Attribute__c foundationlc = createProdExtAtt_withFoundationProd('RENEWAL',lcgrp[0].id, baseProd.Id);
        Product2 renewalProd = Sales_TestFactory_Utility.createDifferentProducts(foundationlc.id, '', 'myRenewal');
        renewalProd.Core_Sales_Visible_Flag__c=false;
        update renewalProd;
        PricebookEntry standardPrice = Sales_TestFactory_Utility.createPriceBookEntry(baseProd.Id, Test.getStandardPricebookId());
        Order o1 = Sales_TestFactory_Utility.createOrders(accObj.Id, Test.getStandardPricebookId(),'Licensed Tool Order');
        List<OrderItem> baseoiList = Sales_TestFactory_Utility.createOrderProductList1(o1.id, baseProd.id, standardPrice.id,con.Id);
        test.startTest();
        Map<Id,OrderItem> orderItemMap =new Map<Id,OrderItem>();
        orderItemMap.put(baseoiList[0].Id,baseoiList[0]);
        List<Sales_License__c> licensesList = new List<Sales_License__c>();
        for(Sales_License__c lic : [ SELECT Id,Sales_License_Order_Product__c, Sales_License_Maintenance_Exp_Dt__c, Sales_License_Primary_Admin_Contact__c,Sales_License_Type__c FROM Sales_License__c WHERE Sales_License_Order_Product__c IN:orderItemMap.keyset() ]){
            lic.Sales_License_Maintenance_Exp_Dt__c = System.today()-90;
            lic.Sales_License_Type__c='Original';
            licensesList.add(lic);
        }
        update licensesList;
        PricebookEntry standardPrice2 = Sales_TestFactory_Utility.createPriceBookEntry(renewalProd.Id, Test.getStandardPricebookId());
        Order o2 = Sales_TestFactory_Utility.createOrders(accObj.Id, Test.getStandardPricebookId(),'Licensed Tool Order');
        List<OrderItem> oiList = Sales_TestFactory_Utility.createOrderProductList(o2.id, renewalProd.id, standardPrice2.id);
        Sales_DisplayWarning.validateMaintainenceDate(o2.id);
        test.stopTest();
    }    
    static testmethod void testRenewalOrder(){
        Account accObj = Sales_TestFactory_Utility.createAccount(); 
        Contact con = Sales_TestFactory_Utility.createContact(accObj.Id);
        List<Sales_License_Generator__c> gen = Sales_TestFactory_Utility.createLiceneseGenerator();
        List<Sales_License_Group__c> lcgrp = Sales_TestFactory_Utility.createLiceneseGroup(gen[0].id);
        Core_Product_Ext_Attribute__c lc = Sales_TestFactory_Utility.createProductExtAttribute('BASE',lcgrp[0].id);
        Product2 baseProd = Sales_TestFactory_Utility.createDifferentProducts(lc.id, '', 'myBase');
        baseProd.Core_Sales_Visible_Flag__c=false;
        update baseProd;
        Core_Product_Ext_Attribute__c foundationlc = createProdExtAtt_withFoundationProd('RENEWAL',lcgrp[0].id, baseProd.Id);
        Product2 renewalProd = Sales_TestFactory_Utility.createDifferentProducts(foundationlc.id, '', 'myRenewal');
        renewalProd.Core_Sales_Visible_Flag__c=false;
        update renewalProd;
        PricebookEntry standardPrice = Sales_TestFactory_Utility.createPriceBookEntry(baseProd.Id, Test.getStandardPricebookId());
        Order o1 = Sales_TestFactory_Utility.createOrders(accObj.Id, Test.getStandardPricebookId(),'Licensed Tool Order');
        List<OrderItem> baseoiList = Sales_TestFactory_Utility.createOrderProductList1(o1.id, baseProd.id, standardPrice.id,con.Id);
        test.startTest();
        Map<Id,OrderItem> orderItemMap =new Map<Id,OrderItem>();
        orderItemMap.put(baseoiList[0].Id,baseoiList[0]);
        List<Sales_License__c> licensesList = new List<Sales_License__c>();
        for(Sales_License__c lic : [ SELECT Id,Sales_License_Order_Product__c, Sales_License_Maintenance_Exp_Dt__c, Sales_License_Primary_Admin_Contact__c,Sales_License_Type__c FROM Sales_License__c WHERE Sales_License_Order_Product__c IN:orderItemMap.keyset() ]){
            lic.Sales_License_Maintenance_Exp_Dt__c =null;
            lic.Sales_License_Type__c='Original';
            lic.Sales_License_Product__c=renewalProd.id;
            lic.Sales_License_Primary_Admin_Contact__c=con.Id;
            licensesList.add(lic);
        }
        update licensesList;
        PricebookEntry standardPrice2 = Sales_TestFactory_Utility.createPriceBookEntry(renewalProd.Id, Test.getStandardPricebookId());
        Order o2 = Sales_TestFactory_Utility.createOrders(accObj.Id, Test.getStandardPricebookId(),'Licensed Tool Order');
        List<OrderItem> oiList = Sales_TestFactory_Utility.createOrderProductList(o2.id, renewalProd.id, standardPrice2.id);
        Sales_DisplayWarning.validateMaintainenceDate(o2.id);
        test.stopTest();
    }    
    static testmethod void testRenewalQuantity(){
        List<Id> contactName = new List<Id>();
        Account accObj = Sales_TestFactory_Utility.createAccount(); 
        Contact con = Sales_TestFactory_Utility.createContact(accObj.Id);
        List<Sales_License_Generator__c> gen = Sales_TestFactory_Utility.createLiceneseGenerator();
        List<Sales_License_Group__c> lcgrp = Sales_TestFactory_Utility.createLiceneseGroup(gen[0].id);
        Core_Product_Ext_Attribute__c lc = Sales_TestFactory_Utility.createProductExtAttribute('BASE',lcgrp[0].id);
        Product2 baseProd = Sales_TestFactory_Utility.createDifferentProducts(lc.id, '', 'myBase');
        baseProd.Core_Sales_Visible_Flag__c=false;
        update baseProd;
        Core_Product_Ext_Attribute__c foundationlc = createProdExtAtt_withFoundationProd('RENEWAL',lcgrp[0].id, baseProd.Id);
        Product2 renewalProd = Sales_TestFactory_Utility.createDifferentProducts(foundationlc.id, '', 'myRenewal');
        renewalProd.Core_Sales_Visible_Flag__c=false;
        update renewalProd;
        PricebookEntry standardPrice = Sales_TestFactory_Utility.createPriceBookEntry(baseProd.Id, Test.getStandardPricebookId());
        Order o1 = Sales_TestFactory_Utility.createOrders(accObj.Id, Test.getStandardPricebookId(),'Licensed Tool Order');
        List<OrderItem> baseoiList = Sales_TestFactory_Utility.createOrderProductList1(o1.id, baseProd.id, standardPrice.id,con.Id);
        test.startTest();
        Map<Id,OrderItem> orderItemMap =new Map<Id,OrderItem>();
        orderItemMap.put(baseoiList[0].Id,baseoiList[0]);
        PricebookEntry standardPrice2 = Sales_TestFactory_Utility.createPriceBookEntry(renewalProd.Id, Test.getStandardPricebookId());
        Order o2 = Sales_TestFactory_Utility.createOrders(accObj.Id, Test.getStandardPricebookId(),'Licensed Tool Order');
        List<OrderItem> oiList = Sales_TestFactory_Utility.createOrderProductList1(o2.id, renewalProd.id, standardPrice2.id,con.Id);
        String warnMsg=Sales_DisplayWarning.validateQuantity(o2.Id,'Display');
        test.stopTest();
        Boolean warnMsgNotBlank =  (warnMsg != '') ? true : false;
    }    
    static testmethod void addSeatOrderDate(){
        Account accObj = Sales_TestFactory_Utility.createAccount(); 
        Contact con = Sales_TestFactory_Utility.createContact(accObj.Id);
        List<Sales_License_Generator__c> gen = Sales_TestFactory_Utility.createLiceneseGenerator();
        List<Sales_License_Group__c> lcgrp = Sales_TestFactory_Utility.createLiceneseGroup(gen[0].id);
        Core_Product_Ext_Attribute__c lc = Sales_TestFactory_Utility.createProductExtAttribute('BASE',lcgrp[0].id);
        Product2 baseProd = Sales_TestFactory_Utility.createDifferentProducts(lc.id, '', 'myBase');
        baseProd.Core_Sales_Visible_Flag__c=false;
        update baseProd;
        PricebookEntry standardPrice = Sales_TestFactory_Utility.createPriceBookEntry(baseProd.Id, Test.getStandardPricebookId());
        TriggerHandler.bypass('Sales_OrderProductTriggerHandler');
        TriggerHandler.bypass('Sales_OrderTriggerHandler');
        Order o1 = Sales_TestFactory_Utility.createOrders(accObj.Id, Test.getStandardPricebookId(),'Licensed Tool Order');
        List<OrderItem> baseoiList = Sales_TestFactory_Utility.createOrderProductList1(o1.id, baseProd.id, standardPrice.id,con.Id);
        OrderItem oi = Sales_TestFactory_Utility.createOrderProduct(o1.Id, baseProd.Id, standardPrice.Id);
        TriggerHandler.bypass('Sales_LicenseTriggerHandler');
        Core_Product_Ext_Attribute__c foundationlc = createProdExtAtt_withFoundationProd('ADD SEAT',lcgrp[0].id, baseProd.Id);
        Sales_License__c lic = Sales_TestDataFactory.createLicenseRecord(new Map<String,String>{
            'Sales_License_Product__c' => baseProd.Id ,
                'Sales_License_Account__c' => accObj.Id , 'Sales_License_Primary_Admin_Contact__c' => con.Id ,
                'Sales_License_Order__c'=>o1.Id,'Sales_License_Order_Product__c'=>oi.Id
                });
        insert lic;
        Product2 addSeatProd = Sales_TestFactory_Utility.createDifferentProducts(foundationlc.id, '', 'myAddSeat');
        Sales_License__c lic1 = Sales_TestDataFactory.createLicenseRecord(new Map<String,String>{
            'Sales_License_Product__c' => addSeatProd.Id ,
                'Sales_License_Account__c' => accObj.Id , 'Sales_License_Primary_Admin_Contact__c' => con.Id,
                'Sales_License_Type__c'=>'Add Seat'
                });
        insert lic1;
        addSeatProd.Core_Sales_Visible_Flag__c=false;
        update addSeatProd;
        Map<Id,OrderItem> orderItemMap =new Map<Id,OrderItem>();
        orderItemMap.put(baseoiList[0].Id,baseoiList[0]);
        test.startTest();       
        PricebookEntry standardPrice2 = Sales_TestFactory_Utility.createPriceBookEntry(addSeatProd.Id, Test.getStandardPricebookId());
        TriggerHandler.bypass('Sales_OrderProductTriggerHandler');
        TriggerHandler.bypass('Sales_OrderTriggerHandler');
        Order o2 = Sales_TestFactory_Utility.createOrders(accObj.Id, Test.getStandardPricebookId(),'Licensed Tool Order');
        List<OrderItem> oiList = Sales_TestFactory_Utility.createOrderProductList1(o2.id, addSeatProd.id, standardPrice2.id,con.Id);
        String warnMsg=Sales_DisplayWarning.validateQuantity(o2.Id,'Display');
        test.stopTest();
        Boolean warnMsgNotBlank =  (warnMsg != '') ? true : false;
        TriggerHandler.clearAllBypasses();
    }    
    static testmethod void testRenewal_withOptions_OrderDate(){
        Id pricebookId = Test.getStandardPricebookId();
        Account accObj = Sales_TestFactory_Utility.createAccount(); 
        Contact con = Sales_TestFactory_Utility.createContact(accObj.Id);
        List<Sales_License_Generator__c> gen = Sales_TestFactory_Utility.createLiceneseGenerator();
        List<Sales_License_Group__c> lcgrp = Sales_TestFactory_Utility.createLiceneseGroup(gen[0].id);
        Core_Product_Ext_Attribute__c lc = Sales_TestFactory_Utility.createProductExtAttribute('BASE',lcgrp[0].id);
        Product2 baseProd = Sales_TestFactory_Utility.createDifferentProducts(lc.id, '', 'myBase1');
        baseProd.Core_Sales_Visible_Flag__c=false;
        update baseProd;
        Product2 baseProd2 = Sales_TestFactory_Utility.createDifferentProducts(lc.id, '', 'myBase2');
        baseProd2.Core_Sales_Visible_Flag__c=false;
        update baseProd2;
        Core_Product_Ext_Attribute__c foundationlc = createProdExtAtt_withFoundationProd('RENEWAL',lcgrp[0].id, baseProd.Id);
        Product2 renewalProd = Sales_TestFactory_Utility.createDifferentProducts(foundationlc.id, '', 'myRenewal');
        renewalProd.Core_Sales_Visible_Flag__c=false;
        update renewalProd;
        SBQQ__ProductOption__c prod_with_options = createoption(baseProd.Id, baseProd2.Id);  
        PricebookEntry standardPrice = Sales_TestFactory_Utility.createPriceBookEntry(baseProd2.Id, pricebookId);
        TriggerHandler.bypass('Sales_OrderTriggerHandler');
        TriggerHandler.bypass('Sales_OrderProductTriggerHandler');
        Order o1 = Sales_TestFactory_Utility.createOrders(accObj.Id, pricebookId,'Licensed Tool Order');
        List<OrderItem> baseoiList = Sales_TestFactory_Utility.createOrderProductList1(o1.id, baseProd2.id, standardPrice.id, con.id);
        Map<Id,OrderItem> orderItemMap =new Map<Id,OrderItem>(baseoiList);
        test.startTest();
        TriggerHandler.clearAllBypasses();
        PricebookEntry standardPrice2 = Sales_TestFactory_Utility.createPriceBookEntry(renewalProd.Id, pricebookId);
        TriggerHandler.bypass('Sales_OrderTriggerHandler');
        TriggerHandler.bypass('Sales_OrderProductTriggerHandler');
        Order o2 = Sales_TestFactory_Utility.createOrders(accObj.Id, pricebookId,'Licensed Tool Order');
        List<OrderItem> oiList = Sales_TestFactory_Utility.createOrderProductList1(o2.id, renewalProd.id, standardPrice2.id, con.Id);        
        String warnMsg=Sales_DisplayWarning.validateQuantity(o2.Id,'Display');
        test.stopTest();
        Boolean warnMsgNotBlank =  (warnMsg != '') ? true : false;        
    }    
    static testmethod void populateListpriceBasedOnQuantity(){
        Account accObj = Sales_TestFactory_Utility.createAccount();
        Account soldTo = createSoldToAccount(accObj.Id,'01');
        List<Sales_License_Generator__c> gen = Sales_TestFactory_Utility.createLiceneseGenerator();
        List<Sales_License_Group__c> lcgrp = Sales_TestFactory_Utility.createLiceneseGroup(gen[0].id);
        Core_Product_Ext_Attribute__c lc = Sales_TestFactory_Utility.createProductExtAttribute('BASE',lcgrp[0].id);
        lc.Core_SW_Prod_Avail_To_TL_ORD_ENBLMT_Ind__c = true;
        update lc;
        Product2 prodct = Sales_TestFactory_Utility.createDifferentProducts(lc.id, 'SV', 'myARM');
        prodct.Core_Item_Orderable_Ind__c = true;
        prodct.Core_Sales_Visible_Flag__c=false;
        update prodct;
        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry standardPrice = Sales_TestFactory_Utility.createPriceBookEntry(prodct.Id, pricebookId);
        List<Order> ord1 = new  List<Order>();
        order o= Sales_TestFactory_Utility.createOrders(accObj.Id, pricebookId,'Licensed Tool Order');
        ord1.add(o);
        try{
            Test.startTest();
            List<core_cpq_list_price__c> cpq = createCPQListPrice(prodct.Id,standardPrice.Id);
            List<OrderItem> oi1 = Sales_TestFactory_Utility.createOrderProductList(ord1[0].id, prodct.id,standardPrice.Id);
            String warnMsg=Sales_DisplayWarning.validateQuantity(ord1[0].id,'Recalculate');
            Boolean warnMsgNotBlank =  (warnMsg != '') ? true : false; 
            Test.stopTest();
        } 
        catch(exception e){
        }
    }
    static testmethod void displayWarningAndRecalculate(){
        SBQQ.TriggerControl.disable();
        Account accObj = Sales_TestFactory_Utility.createAccount(); 
        Account intelSoldto = Sales_TestFactory_Utility.createIntelSoldAccount();
        Account intelShipto = Sales_TestFactory_Utility.createIntelShipAccount();
        List<Account> acList = new List<Account>();
        acList.add(intelSoldto);
        acList.add(intelShipto);
        insert acList;        
        List<Account> accList2 = new list<Account>();
        Account soldTo = Sales_TestFactory_Utility.createSoldToAccount();
        Account shipTo = Sales_TestFactory_Utility.createShipToAccount();
        Account intelAccount = Sales_TestFactory_Utility.createAccount();
        accList2.add(soldTo);
        accList2.add(shipTo);
        Account parentEndCustomerAccount = Sales_TestDataFactory.createParentEndCustomerAccount();
        parentEndCustomerAccount.Core_Sub_Industry__c = null;
        accList2.add(parentEndCustomerAccount);
        Account accEndPricing = Sales_TestDataFactory.createDirectEndCustomerPricingParentAccount();
        accList2.add(accEndPricing);
        insert accList2;               
        Account endCustomerObj = Sales_TestFactory_Utility.createDiffPSGDownstreamAccounts('End Customer','End User');  
        endCustomerObj.Core_Sales_Group__c = 'PSG Sales';
        Account endCustomer = Sales_TestDataFactory.createDefaultAccount();
        endCustomer.Core_PSG_Account__c = true;
        endCustomer.Core_Account_Type__c = 'End Customer';
        endCustomer.Core_Direct_Pricing_Parent_Id__c = accEndPricing.Id;
        endCustomer.Core_Direct_Legal_Parent_Id__c = accEndPricing.Id;
        Account endCustForOrder = Sales_TestDataFactory.createEndCustomerAccount();
        endCustForOrder.ParentId = parentEndCustomerAccount.Id;
        List<Account> endCustAccList = new List<Account>();
        endCustAccList.add(endCustForOrder);
        endCustAccList.add(endCustomer);
        endCustAccList.add(endCustomerObj);
        insert endCustAccList;                       
        TriggerHandler.clearAllBypasses();
        Core_Product_Ext_Attribute__c prodExt1 = Sales_TestDataFactory.createProductExternalAttributes();
        prodExt1.put('Core_SW_Lic_Type_Nm__c','FLOAT');
        prodExt1.put('Core_Prod_Tool_Type_Nm__c','CORPORATE');        
        insert prodExt1 ;
        Product2 prod1 = Sales_TestDataFactory.createProduct();
        prod1.put('Core_Product_Ext_Attribute_Id__c',prodExt1.Id);
        insert prod1;
        PriceBookEntry pbEntry = Sales_TestDataFactory.createPriceBookEntry();
        pbEntry.Pricebook2Id = Test.getStandardPricebookId();
        pbEntry.Product2Id = prod1.Id;
        insert pbEntry;
        TriggerHandler.bypass('QuoteTriggerHandler');
        TriggerHandler.clearAllBypasses();
        Core_Account_SoldTo_ShipTo_Rel__c relation_Ship_Sold = Sales_TestDataFactory.accSoldToShipToRelationshipRecord(new Map<String,String>{
            'Core_Sold_To_Account__c'  =>  soldTo.Id,
                'Core_Ship_To_Account__c'  =>  shipTo.Id
                });
        insert relation_Ship_Sold;
        SBQQ__Quote__c q = Sales_TestDataFactory.createQuoteRecord(); 
        q.SBQQ__Account__c = accObj.Id;
        q.SBQQ__Status__c = 'Approved';
        q.core_cpq_quote_type_nm__c = 'Tools';
        TriggerHandler.bypass('QuoteTriggerHandler');
        insert q;
        SBQQ__QuoteLine__c ql = Sales_TestDataFactory.createQuoteLineRecord();
        ql.SBQQ__Quote__c = q.Id;
        ql.SBQQ__Product__c = prod1.Id;
        TriggerHandler.bypass('QuoteTriggerHandler');
        TriggerHandler.bypass('QuoteLineTriggerHandler');
        insert ql;
        TriggerHandler.clearAllBypasses();
        Order o1 = Sales_ContractTriggerUtility_Test.createOrdersWithAllAccAndQuote(intelAccount.Id, Test.getStandardPricebookId(),'Licensed Tool Order',null, soldTo, shipTo, endCustForOrder); 
        o1.Sales_Cancelled_Quote_No__c = q.id;
        o1.SBQQ__Quote__c=q.id;
        TriggerHandler.bypass('Sales_OrderTriggerHandler');
        update o1;
        TriggerHandler.clearAllBypasses();
        Test.startTest();
        q.SBQQ__Ordered__c=true;
        OrderItem oi = Sales_TestDataFactory.createOrderItem(); 
        TriggerHandler.bypass('Sales_OrderProductTriggerHandler');
        TriggerHandler.bypass('Sales_OrderTriggerHandler');
        oi.OrderId = o1.Id;
        oi.Quantity = 2;
        oi.UnitPrice = 240;
        oi.Product2Id = prod1.Id;
        oi.PricebookEntryId = pbEntry.Id;
        oi.SBQQ__QuoteLine__c = ql.Id;
        insert oi;
        List<OrderItem> OIList =[Select id,OrderId,OrderItemNumber,Quantity,Product2Id,Sales_Suggested_Resale_Price__c,Sales_Broken_Price_Amt__c,UnitPrice,SBQQ__QuoteLine__c,UnitPriceForceOverride__c from OrderItem where OrderId =:o1.Id and 
                                 SBQQ__QuoteLine__c = :ql.Id LIMIT 1] ;
        List<String> ordList=new List<String>();
        List<String> Orditm= new List<String>();
        Orditm.add(OIList[0].OrderItemNumber);
        Set<Id> productIdSet= new Set<Id>();
        productIdSet.add(OIList[0].Product2Id);
        ordList.add(o1.id);
        Map<Id,Order> ordMap=new Map<Id,Order>();
        ordMap.put(o1.Id, o1);
        TriggerHandler.clearAllBypasses();
        Test.stopTest();
        try{
            String msg = Sales_DisplayWarning.validatePriceChange(ordList,'Trigger',ordMap);
            String ordItemMsg=Sales_DisplayWarning.recalculateOrderProduct(Orditm,productIdSet,ordMap);
            String warnMsg=Sales_DisplayWarning.validateQuantity(o1.id,'Recalculate');
            Boolean warnMsgNotBlank =  (warnMsg != '') ? true : false;
        }
        catch(Exception e)
        { }
    }
    public static Opportunity createOpportunity(Id accId){
        Opportunity opp = new Opportunity();
        opp.name = 'test opp';        
        opp.AccountId = accId;
        opp.StageName = 'Qualification';
        opp.CloseDate = System.today();
        opp.Core_Technical_Owner__c = userInfo.getUserId();
        insert opp;
        System.assert(opp.Id!=null,' opportunity inserted sucessfully');
        return opp;
    }
    static testmethod void displayWarningAndRecalculatefornoncomm(){
        SBQQ.TriggerControl.disable();
        Account intelSoldto = Sales_TestFactory_Utility.createIntelSoldAccount();
        Account intelShipto = Sales_TestFactory_Utility.createIntelShipAccount();
        List<Account> acList = new List<Account>();
        acList.add(intelSoldto);
        acList.add(intelShipto);
        insert acList;        
        List<Account> accList2 = new list<Account>();
        Account soldTo = Sales_TestFactory_Utility.createSoldToAccount();
        Account shipTo = Sales_TestFactory_Utility.createShipToAccount();
        Account intelAccount = Sales_TestFactory_Utility.createAccount();
        accList2.add(soldTo);
        accList2.add(shipTo);
        Account parentEndCustomerAccount = Sales_TestDataFactory.createParentEndCustomerAccount();
        parentEndCustomerAccount.Core_Sub_Industry__c = null;
        accList2.add(parentEndCustomerAccount);
        Account accEndPricing = Sales_TestDataFactory.createDirectEndCustomerPricingParentAccount();
        accList2.add(accEndPricing);
        insert accList2;               
        Account endCustomerObj = Sales_TestFactory_Utility.createDiffPSGDownstreamAccounts('End Customer','End User');  
        endCustomerObj.Core_Sales_Group__c = 'PSG Sales';
        Account endCustomer = Sales_TestDataFactory.createDefaultAccount();
        endCustomer.Core_PSG_Account__c = true;
        endCustomer.Core_Account_Type__c = 'End Customer';
        endCustomer.Core_Direct_Pricing_Parent_Id__c = accEndPricing.Id;
        endCustomer.Core_Direct_Legal_Parent_Id__c = accEndPricing.Id;
        Account endCustForOrder = Sales_TestDataFactory.createEndCustomerAccount();
        endCustForOrder.ParentId = parentEndCustomerAccount.Id;
        List<Account> endCustAccList = new List<Account>();
        endCustAccList.add(endCustForOrder);
        endCustAccList.add(endCustomer);
        endCustAccList.add(endCustomerObj);
        insert endCustAccList;                       
        TriggerHandler.clearAllBypasses();
        Core_Product_Ext_Attribute__c prodExt1 = Sales_TestDataFactory.createProductExternalAttributes();
        prodExt1.put('Core_SW_Lic_Type_Nm__c','FLOAT');
        prodExt1.put('Core_Prod_Tool_Type_Nm__c','CORPORATE');        
        insert prodExt1 ;
        Product2 prod1 = Sales_TestDataFactory.createProduct();
        prod1.put('Core_Product_Ext_Attribute_Id__c',prodExt1.Id);
        insert prod1;
        PriceBookEntry pbEntry = Sales_TestDataFactory.createPriceBookEntry();
        pbEntry.Pricebook2Id = Test.getStandardPricebookId();
        pbEntry.Product2Id = prod1.Id;
        insert pbEntry;
        TriggerHandler.bypass('QuoteTriggerHandler');
        TriggerHandler.clearAllBypasses();
        Core_Account_SoldTo_ShipTo_Rel__c relation_Ship_Sold = Sales_TestDataFactory.accSoldToShipToRelationshipRecord(new Map<String,String>{
            'Core_Sold_To_Account__c'  =>  soldTo.Id,
                'Core_Ship_To_Account__c'  =>  shipTo.Id
                });
        insert relation_Ship_Sold;
        SBQQ__Quote__c q = Sales_TestDataFactory.createQuoteRecord();
        q.core_cpq_quote_type_nm__c = 'Tools';
        insert q;
        TriggerHandler.bypass('QuoteTriggerHandler');
        TriggerHandler.bypass('QuoteLineTriggerHandler');
        TriggerHandler.clearAllBypasses();
        SBQQ__QuoteLine__c ql = Sales_TestDataFactory.createQuoteLineRecord();
        TriggerHandler.bypass('QuoteLineTriggerHandler');
        ql.SBQQ__Quote__c = q.Id;
        ql.SBQQ__PricebookEntryId__c = pbEntry.Id;
        ql.SBQQ__Product__c = prod1.Id;
        TriggerHandler.bypass('QuoteTriggerHandler');
        TriggerHandler.bypass('QuoteLineTriggerHandler');
        insert ql;
        TriggerHandler.clearAllBypasses();
        Order o1 = Sales_ContractTriggerUtility_Test.createOrdersWithAllAccAndQuote(intelAccount.Id, Test.getStandardPricebookId(),'Licensed Tool Order',null, soldTo, shipTo, endCustForOrder); 
        o1.Sales_Cancelled_Quote_No__c = q.id;
        update o1;
        Test.startTest();
        q.SBQQ__Ordered__c=true;
        TriggerHandler.bypass('QuoteTriggerHandler');
        TriggerHandler.clearAllBypasses();
        List<OrderItem> OIList =Sales_TestFactory_Utility.createOrderProductListWithQuoteline(o1.id, prod1.id, pbEntry.id,null);
        List<String> ordList=new List<String>();
        List<String> Orditm= new List<String>();
        Orditm.add(OIList[0].OrderItemNumber);
        Set<Id> productIdSet= new Set<Id>();
        productIdSet.add(OIList[0].Product2Id);
        ordList.add(o1.id);
        Map<Id,Order> ordMap=new Map<Id,Order>();
        ordMap.put(o1.Id, o1);
        TriggerHandler.clearAllBypasses();
        Test.stopTest();
        String warnMsg=Sales_DisplayWarning.validateQuantity(o1.id,'Recalculate');
        Boolean warnMsgNotBlank =  (warnMsg != '') ? true : false;
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
    public static void recalculateOrderProductTest()
    {
        Order o = [Select Id , SBQQ__Quote__c from Order];
        List<OrderItem> OIList =[Select id,OrderId,OrderItemNumber,Product2Id,Sales_Suggested_Resale_Price__c,Sales_Broken_Price_Amt__c,UnitPrice,Sales_IsRecalculated__c,UnitPriceForceOverride__c from OrderItem where OrderId =:o.Id  LiMIT 1] ;
        List<String> ordList=new List<String>();
        List<String> Orditm= new List<String>();
        Orditm.add(OIList[0].OrderItemNumber);
        Set<Id> productIdSet= new Set<Id>();
        productIdSet.add(OIList[0].Product2Id);
        ordList.add(o.id);
        o.Status = 'Draft';
        o.Sales_Order_Reason__c = 'Non Stocking Order';
        o.Type='Licensed Tool Order';
        o.Sales_Order_Sub_Type__c='Corporate Order';
        o.Sales_SoldTo_Account_2_Txt__c='Dell';
        TriggerHandler.bypass('Sales_OrderTriggerHandler');
        update o;
        Map<Id,Order> ordMap=new Map<Id,Order>();
        ordMap.put(o.Id, o);
        TriggerHandler.clearAllBypasses();
        Test.startTest();     
        String ordItemMsg=Sales_DisplayWarning.recalculateOrderProduct(Orditm,productIdSet,ordMap);
        String ordItemMsgNegative=Sales_DisplayWarning.recalculateOrderProduct(Orditm,null,ordMap);
        Test.stopTest();
    }*/
}