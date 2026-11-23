/*********************************************************************************************************************
Class Name    : testing
Version       : 1.0
Created Date  : Jan 2021  
Function      :  

Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------
* Jasmine Narula           14-Jan-2021              Test class for Sales_OrderProductTriggerUtility
* *********************************************************************************************************************/
@isTest
public class testClass_Test {
    
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
    
    
    
    public static SBQQ__Quote__c createQuote(Id distributorId, Id endCusId,Id oppId, Id pbId){
        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        quote.RecordTypeId= SBQQ__Quote__c.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('PSG_Quote_New').getRecordTypeId();
        quote.core_cpq_active_cb__c = true;
        quote.SBQQ__Opportunity2__c = oppId;
        quote.SBQQ__Primary__c = true;
        quote.SBQQ__PriceBook__c = pbId;
        quote.core_cpq_business_unit_nm__c = 'Military';
        quote.core_cpq_status_txt__c = 'Approved';
        quote.core_cpq_quote_type_nm__c='Design Win';
        quote.SBQQ__StartDate__c = date.today()+10;
        quote.SBQQ__SubscriptionTerm__c = 12;
        quote.SBQQ__Status__c = 'Approved';
        quote.core_cpq_end_customer_nm__c=endCusId;
        quote.SBQQ__Account__c=distributorId;
        insert quote;
        return quote;
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
        //l1.Core_SW_Lic_Group_Id__c = lcGroupid;
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
    
    testmethod static void testtestRenewalCreateOrderProducts1(){
        Order o = Sales_TestFactory_Utility.createOrders(null, Test.getStandardPricebookId(), 'Sample Order');
        List<Sales_License_Generator__c> licensegenr = Sales_TestFactory_Utility.createLiceneseGenerator();
        List<Sales_License_Group__c> licgrp = Sales_TestFactory_Utility.createLiceneseGroup(licensegenr[0].Id);
        Core_Product_Ext_Attribute__c lc = Sales_TestFactory_Utility.createProductExtAttribute('BASE',licgrp[0].id);
        Product2 baseProd = Sales_TestFactory_Utility.createDifferentProducts(lc.id, '', 'myBase');
        Core_Product_Ext_Attribute__c foundationlc = createProdExtAtt_withFoundationProd('RENEWAL',licgrp[0].id, baseProd.Id);
        Product2 renewalProd = Sales_TestFactory_Utility.createDifferentProducts(foundationlc.id, '', 'myRenewal');
        PricebookEntry standardPrice = Sales_TestFactory_Utility.createPriceBookEntry(renewalProd.Id, Test.getStandardPricebookId());
        OrderItem oi = Sales_TestFactory_Utility.createOrderProduct(o.Id, renewalProd.Id, standardPrice.Id);
    }
    
    testmethod static void testtestRenewalCreateOrderProducts2(){
        Order o = Sales_TestFactory_Utility.createOrders(null, Test.getStandardPricebookId(), 'Sample Order');
        List<Sales_License_Generator__c> licensegenr = Sales_TestFactory_Utility.createLiceneseGenerator();
        List<Sales_License_Group__c> licgrp = Sales_TestFactory_Utility.createLiceneseGroup(licensegenr[0].Id);
        Core_Product_Ext_Attribute__c lc = Sales_TestFactory_Utility.createProductExtAttribute('BASE',licgrp[0].id);
        Product2 baseProd = Sales_TestFactory_Utility.createDifferentProducts(lc.id, '', 'myBase');
        Core_Product_Ext_Attribute__c foundationlc = createProdExtAtt_withFoundationProd('ADD SEAT',licgrp[0].id, baseProd.Id);
        Product2 addSeatProd = Sales_TestFactory_Utility.createDifferentProducts(foundationlc.id, '', 'myRenewal');
        PricebookEntry standardPrice = Sales_TestFactory_Utility.createPriceBookEntry(addSeatProd.Id, Test.getStandardPricebookId());
        OrderItem oi = Sales_TestFactory_Utility.createOrderProduct(o.Id, addSeatProd.Id, standardPrice.Id);
    }
    
    testmethod static void testtestRenewalCreateOrderProducts3(){
        Order o = Sales_TestFactory_Utility.createOrders(null, Test.getStandardPricebookId(), 'Sample Order');
        List<Sales_License_Generator__c> licensegenr = Sales_TestFactory_Utility.createLiceneseGenerator();
        List<Sales_License_Group__c> licgrp = Sales_TestFactory_Utility.createLiceneseGroup(licensegenr[0].Id);
        Core_Product_Ext_Attribute__c lc = Sales_TestFactory_Utility.createProductExtAttribute('BASE',licgrp[0].id);
        Product2 baseProd = Sales_TestFactory_Utility.createDifferentProducts(lc.id, '', 'myBase');
        Core_Product_Ext_Attribute__c optionProdLc = Sales_TestFactory_Utility.createProductExtAttribute('BASE',licgrp[0].id);
        Product2 optionProd = Sales_TestFactory_Utility.createDifferentProducts(optionProdLc.id, '', 'myRenewal');
        PricebookEntry standardPrice = Sales_TestFactory_Utility.createPriceBookEntry(optionProd.Id, Test.getStandardPricebookId());
        Sales_TestFactory_Utility.createoption(baseProd.id, optionProd.id);
        OrderItem oi = Sales_TestFactory_Utility.createOrderProduct(o.Id, baseProd.Id, standardPrice.Id);
    }
    /*
    static testmethod void testRenewalCreateOrderProducts(){
        //Test.startTest();
        Account endCustomerObj = createDiffPSGDownstreamAccounts('End Customer','End User');  //(String CoreAccountType, String Acctype)
        //  Account accObj = createDiffPSGDownstreamAccounts('Distributor','Distributor');    
        
        //Account accObj = createDiffPSGDownstreamAccounts('Distributor','Distributor');     
        List<License_Generator__c> licensegenr = Sales_TestFactory_Utility.createLiceneseGenerator();
        List<License_Group__c> licgrp = Sales_TestFactory_Utility.createLiceneseGroup(licensegenr[0].Id);
        Core_Product_Ext_Attribute__c licList = Sales_TestFactory_Utility.createProductExtAttribute('BASE',licgrp[0].Id);
        
        Product2 p = Sales_TestFactory_Utility.createDifferentProducts(licList.Id,'','Sample');
        p.Core_Item_Orderable_Ind__c = true;
        //update p;        
        
        //Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry standardPrice = Sales_TestFactory_Utility.createPriceBookEntry(p.Id, Test.getStandardPricebookId()); 
        
        Order o = Sales_TestFactory_Utility.createOrders(null, Test.getStandardPricebookId(),'Licensed Tool Order');
        Test.startTest();
        List<OrderItem> OIList = Sales_TestFactory_Utility.createOrderProductList(o.Id, p.Id, standardPrice.Id);
        
        List<Contract> contList = Sales_TestFactory_Utility.createContract(endCustomerObj.Id);
        
        for(OrderItem ordItm: OIList){
            ordItm.SBQQ__Contract__c = contList[0].id;
        } 
        System.debug('Before start test');        
        System.debug('Inside start test');
        Test.stopTest();
        Opportunity opp = Sales_TestFactory_Utility.createOpportunity(endCustomerObj.Id);
        
        SBQQ__Quote__c qt = createQuote(endCustomerObj.Id,endCustomerObj.Id,opp.id, Test.getStandardPricebookId());
        
        qt.Sales_Renewed_from_Contract_Id__c = contList[0].id;
        update qt;
        
        update OIList;
        
        // Order o1 = Sales_TestFactory_Utility.createOrders(null, Test.getStandardPricebookId(),'Licensed Tool Order');
        Order o1 = new Order();
        o1.Type= 'Licensed Tool Order';
        o1.Name = 'Test Order 2';
        o1.Status = 'Draft';
        o1.Sales_status__c = 'Draft Order';  //Previously    o.status__c = 'New'; - US919632 
        o1.EffectiveDate = system.today();
        o1.EndDate = system.today() + 4;
        o1.AccountId = o.Sales_Sold_To_Account__c;
        o1.Sales_Order_Reason__c='Stocking Order';//US919632 o.Core_PSG_Order_Reason__c='Stocking Order';
        o1.Pricebook2Id =  Test.getStandardPricebookId();  
        o1.Sales_PO_Number_Txt__c = '687900077999898';
        o1.Sales_Header_Special_Instructions_Dsc__c = 'abc'; 
        o1.Sales_Sold_To_Account__c=o.Sales_Sold_To_Account__c;
        o1.Sales_Ship_To_Account__c = o.Sales_Ship_To_Account__c;
        //  System.debug('accSoldTo.Id'+accSoldTo.Id);
        //  System.debug('accShipTo.Id'+accShipTo.Id);
        o1.Sales_Shipping_Condition_Txt__c = '1Q';
        o1.Sales_Incoterms_Txt__c = 'FCA';
        o1.Sales_Shipping_Instructions_Dsc__c = 'xyz';
        o1.Sales_Payment_Terms__c = 'KB';
        o1.Sales_Req_Ship_Date_Dt__c = system.today() + 5;
        o1.Sales_SoldTo_Street_Dsc__c = '3695  Green Avenue';
        o1.Sales_SoldTo_City_Txt__c = 'Oakland';
        o1.Sales_SoldTo_State_Txt__c = 'California';
        o1.Sales_SoldTo_Province_Txt__c = 'CA';
        o1.Sales_SoldTo_Zip_Txt__c = '94621';
        o1.Sales_SoldTo_Country_Txt__c = 'United States';
        o1.Sales_ShipTo_Street_Dsc__c = '1893  Orchard Street';
        o1.Sales_ShipTo_City_Txt__c = 'RODNEY';
        o1.Sales_ShipTo_State_Txt__c = 'Michigan';
        o1.Sales_ShipTo_Province_Txt__c = 'MI';
        o1.Sales_ShipTo_Zip_Txt__c = '49342';
        o1.Sales_ShipTo_Country_Txt__c = 'United States';
        o1.SBQQ__Quote__c = qt.id;
        insert o1; 
        
        List<OrderItem> OIList2 = Sales_TestFactory_Utility.createOrderProductList(o1.Id, p.Id, standardPrice.Id);
    } */
    /*
@isTest static void testRenewalCreateOrderProducts(){
//Account intelSoldto = Sales_TestFactory_Utility.createIntelSoldAccount();
//Account intelShipto = Sales_TestFactory_Utility.createIntelShipAccount();
//List<Account> acList = new List<Account>();
//acList.add(intelSoldto);
//acList.add(intelShipto);
//insert acList;
//Id pricebookId = Test.getStandardPricebookId();
Account accObj = Sales_TestFactory_Utility.createAccount(); 
Account endCustomerObj = Sales_TestFactory_Utility.createDiffPSGDownstreamAccounts('End Customer','End User');  //(String CoreAccountType, String Acctype)
//Account accObj = Sales_TestFactory_Utility.createDiffPSGDownstreamAccounts('Distributor','Distributor');    
List<Account> accList = new List<Account>();
//Account soldTo = Sales_TestFactory_Utility.createSoldToAccount();
//Account shipTo = Sales_TestFactory_Utility.createShipToAccount();
accList.add(soldTo);
accList.add(shipTo);
accList.add(endCustomerObj);
accList.add(accObj);
insert accList;
Contact con = Sales_TestFactory_Utility.createContact(accObj.Id);        
List<License_Generator__c> gen = Sales_TestFactory_Utility.createLiceneseGenerator();
List<License_Group__c> lcgrp = Sales_TestFactory_Utility.createLiceneseGroup(gen[0].id);
Core_Product_Ext_Attribute__c lc = Sales_TestFactory_Utility.createProductExtAttribute('CORPORATE',lcgrp[0].id);

Product2 prod = Sales_TestFactory_Utility.createDifferentProducts(lc.id, '', 'myCorp');
PricebookEntry standardPrice = Sales_TestFactory_Utility.createPriceBookEntry(prod.Id, Test.getStandardPricebookId());
Opportunity opp = Sales_TestFactory_Utility.createOpportunity(accObj.Id);
Opportunity oppRenewal = Sales_TestFactory_Utility.createOpportunity(accObj.Id);

SBQQ__Quote__c q = Sales_TestFactory_Utility.createQuote(accObj.Id,endCustomerObj.Id,opp.Id,Test.getStandardPricebookId());
SBQQ__QuoteLine__c ql = Sales_TestFactory_Utility.createQuoteLine(q.Id,prod.Id,standardPrice.Id);              

Order o1 = Sales_TestFactory_Utility.createOrders(accObj.Id, Test.getStandardPricebookId(),'Licensed Tool Order');
// Order o1 = createOrdersWithAllAccAndQuote(accObj.Id, Test.getStandardPricebookId(),'Licensed Tool Order',q.Id, soldTo, shipTo);

try{            

system.debug('###Inside Test.startTest');
Test.startTest(); 
List<Contract> newContractList = createContractAssociatedwithQuoteOrder(accObj.Id, o1.id, q.Id);
System.debug('@@##Contract: '+newContractList);              

newContractList[0].Sales_Program__c = 'PSG';
newContractList[0].SBQQ__RenewalOpportunity__c = oppRenewal.Id;
newContractList[0].StartDate = system.today();
newContractList[0].Status = 'Activated';
update newContractList;
newContractList[0].SBQQ__RenewalQuoted__c= true;
newContractList[0].SBQQ__RenewalForecast__c= true;           
//update newContractList;
System.debug('@@##Contract: '+newContractList);    
SBQQ__Quote__c renewalQuote = Sales_TestFactory_Utility.createQuote(accObj.Id,endCustomerObj.Id,opp.Id,Test.getStandardPricebookId());
renewalQuote.SBQQ__Opportunity2__c = oppRenewal.Id;
renewalQuote.SBQQ__Type__c = 'Renewal' ;
update renewalQuote;

//Sales_ContractTriggerUtility.deleteRenewalOpportunity(newContractList);
Test.stopTest();
}catch(Exception e){
//System.assert(false, e.getMessage());
}

}
*/
    
    /*public static List<Contract> createContractAssociatedwithQuoteOrder(Id accId, Id orderId, Id quoteId){
        List<Contract> conList = new List<Contract>();
        Contract con = new Contract(); 
        con.AccountId = accId;
        con.SBQQ__Order__c = orderId;
        con.SBQQ__Quote__c = quoteId;
        con.StartDate = System.today();
        con.Status = 'Draft';
        con.ContractTerm = 12; 
        
        conList.add(con);
        insert conList;
        return conList;
    }
    
    static testmethod void testCreateOrderProducts(){
        Account accObj = Sales_TestFactory_Utility.createAccount();    
        Contact con = Sales_TestFactory_Utility.createContact(accObj.Id);
        List<Sales_License_Generator__c> licensegenr = Sales_TestFactory_Utility.createLiceneseGenerator();
        List<Sales_License_Group__c> licgrp = Sales_TestFactory_Utility.createLiceneseGroup(licensegenr[0].Id);
        Core_Product_Ext_Attribute__c licList = Sales_TestFactory_Utility.createProductExtAttribute('BASE',licgrp[0].Id);
        
        
        
        //Core_Product_Ext_Attribute__c lc1 = Sales_TestFactory_Utility.createProductExtAttribute('CORPORATE',licgrp[0].id);
        Product2 p = Sales_TestFactory_Utility.createDifferentProducts(licList.Id,'','Sample');
        p.Core_Item_Orderable_Ind__c = true;
        update p;
        Product2 ARMprodct = Sales_TestFactory_Utility.createDifferentProducts(licList.id, 'SV', 'myARM'); 
        ARMprodct.Core_Item_Orderable_Ind__c = true;
        update ARMprodct;
        Opportunity createOps =  Sales_TestFactory_Utility.createOpportunity(accObj.Id);
        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry standardPrice = Sales_TestFactory_Utility.createPriceBookEntry(p.Id, pricebookId);
        PricebookEntry standardARMPrice = Sales_TestFactory_Utility.createPriceBookEntry(ARMprodct.Id, pricebookId); 
        Order o = Sales_TestFactory_Utility.createOrders(accObj.Id, pricebookId,'Licensed Tool Order');
        
        List<OrderItem> OIList = Sales_TestFactory_Utility.createOrderProductList(o.Id, p.Id, standardARMPrice.Id);         
        Test.startTest();
        //Sales_OrderProductTriggerUtility.beforeInsertOrderProductUtility(OIList);
        Test.stopTest();
        
        /*   Account EndCustomer = Sales_TestFactory_Utility.createEndCustomerAccount();
Id pricebookId = Test.getStandardPricebookId();

List<License_Generator__c> gen = Sales_TestFactory_Utility.createLiceneseGenerator();
List<License_Group__c> lcgrp = Sales_TestFactory_Utility.createLiceneseGroup(gen[0].id);
//Core_Product_Ext_Attribute__c lc = Sales_TestFactory_Utility.createLicense('BASE', lcgrp.id);
Core_Product_Ext_Attribute__c lc = Sales_TestFactory_Utility.createProductExtAttribute('BASE',lcgrp[0].id);

Product2 armprodct = Sales_TestFactory_Utility.createDifferentProducts(lc.id, 'BD', 'myDevkit');
PricebookEntry standardPrice = Sales_TestFactory_Utility.createPriceBookEntry(armprodct.Id, pricebookId);

Order ord1 = Sales_TestFactory_Utility.createOrders(EndCustomer.id, pricebookId,'Licensed Tool Order');
List<OrderItem> oi1 = Sales_TestFactory_Utility.createOrderProductList(ord1.id, armprodct.id, standardPrice.id);

Test.startTest();
Sales_OrderProductTriggerUtility.restrictOrderProductCreation(oi1);      
// Sales_SequenceGenerator.sequenceGenerator();
Test.stopTest();*/
    /*}
    
    static testmethod void testUnitPriceInsert(){
        Account accObj = Sales_TestFactory_Utility.createAccount();    
        Contact con = Sales_TestFactory_Utility.createContact(accObj.Id);
        List<Sales_License_Generator__c> licensegenr = Sales_TestFactory_Utility.createLiceneseGenerator();
        List<Sales_License_Group__c> licgrp = Sales_TestFactory_Utility.createLiceneseGroup(licensegenr[0].Id);
        Core_Product_Ext_Attribute__c licList = Sales_TestFactory_Utility.createProductExtAttribute('BASE',licgrp[0].Id);
        Core_Product_Ext_Attribute__c lc1 = Sales_TestFactory_Utility.createProductExtAttribute('CORPORATE',licgrp[0].id);
        Product2 p = Sales_TestFactory_Utility.createDifferentProducts(licList.Id,'','Sample');
        Product2 CORPprodct = Sales_TestFactory_Utility.createDifferentProducts(licList.id, '', 'myDevkit'); 
        Opportunity createOps =  Sales_TestFactory_Utility.createOpportunity(accObj.Id);
        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry standardPrice = Sales_TestFactory_Utility.createPriceBookEntry(p.Id, pricebookId);
        PricebookEntry standardCorpPrice = Sales_TestFactory_Utility.createPriceBookEntry(CORPprodct.Id, pricebookId); 
        /* SBQQ__Quote__c quoteId = Sales_TestFactory_Utility.createQuote(accObj.Id,createOps.Id,pricebookId); 
SBQQ__QuoteLine__c qline = Sales_TestFactory_Utility.createQuoteLine(quoteId.Id,p.Id,standardPrice.Id) ;
SBQQ__QuoteLine__c ql = Sales_TestFactory_Utility.createQuoteLine(quoteId.Id,CORPprodct.Id,standardCorpPrice.Id) ; 
quoteId.SBQQ__Ordered__c=true;
update quoteId; 
Order o = [Select Id , SBQQ__Quote__c from Order where SBQQ__Quote__c =:quoteId.Id];
Order o = Sales_TestFactory_Utility.createOrderswithQUote(accObj.Id, pricebookId,quoteId.Id);
List<OrderItem> OIList = Sales_TestFactory_Utility.createOrderProductListWithQuoteline(o.Id, p.Id, standardPrice.Id,qline.Id);
*/
       /*Order o = Sales_TestFactory_Utility.createOrders(accObj.Id, pricebookId,'Licensed Tool Order');
        
        List<OrderItem> OIList = Sales_TestFactory_Utility.createOrderProductList(o.Id, p.Id, standardPrice.Id);         
        Test.startTest();
        //Sales_OrderProductTriggerUtility.beforeInsertOrderProductUtility(OIList);
        Test.stopTest();
    }
    /*
    static testmethod void testUnitPriceDirectType(){
        // Account accObj = Sales_TestFactory_Utility.createAccountTypeDirect();  
        Account endCustomerObj = createDiffPSGDownstreamAccounts('End Customer','End User');  //(String CoreAccountType, String Acctype)
        Account accObj = createDiffPSGDownstreamAccounts('Distributor','Distributor');     
        
        
        Contact con = Sales_TestFactory_Utility.createContact(accObj.Id);
        List<License_Generator__c> licensegenr = Sales_TestFactory_Utility.createLiceneseGenerator();
        List<License_Group__c> licgrp = Sales_TestFactory_Utility.createLiceneseGroup(licensegenr[0].Id);
        Core_Product_Ext_Attribute__c licList = Sales_TestFactory_Utility.createProductExtAttribute('BASE',licgrp[0].Id);
        Core_Product_Ext_Attribute__c lc1 = Sales_TestFactory_Utility.createProductExtAttribute('CORPORATE',licgrp[0].id);
        Product2 p = Sales_TestFactory_Utility.createDifferentProducts(licList.Id,'','Sample');
        Product2 CORPprodct = Sales_TestFactory_Utility.createDifferentProducts(lc1.id, '', 'myDevkit'); 
        Opportunity opp = Sales_TestFactory_Utility.createOpportunity(accObj.Id);
        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry standardPrice = Sales_TestFactory_Utility.createPriceBookEntry(p.Id, pricebookId);
        PricebookEntry standardCorpPrice = Sales_TestFactory_Utility.createPriceBookEntry(CORPprodct.Id, pricebookId); 
        // SBQQ__Quote__c quoteId = Sales_TestFactory_Utility.createQuoteWithDistiEnd(accObj.Id,createOps.Id,pricebookId); 
        SBQQ__Quote__c q = createQuote(accObj.Id,endCustomerObj.Id,opp.Id,pricebookId);
        System.debug('Before start test');
        
        System.debug('Inside start test');
        SBQQ__QuoteLine__c qline = Sales_TestFactory_Utility.createNoncorpQuoteLine(q.Id,p.Id,standardPrice.Id) ;
        SBQQ__QuoteLine__c ql = Sales_TestFactory_Utility.createQuoteLine(q.Id,CORPprodct.Id,standardCorpPrice.Id) ; 
        
        q.SBQQ__Ordered__c=true;
        
        update q;
        Order o = [Select Id , SBQQ__Quote__c from Order where SBQQ__Quote__c =:q.Id];
        Test.startTest();
        List<OrderItem> OIList =[Select id,OrderId,Product2Id,Sales_Suggested_Resale_Price__c,Sales_Broken_Price_Amt__c,UnitPrice from OrderItem where OrderId =:o.Id] ;
        Sales_OrderProductTriggerUtility.beforeInsertOrderProductUtility(OIList);
        Test.stopTest();
    } */
    
    /*static testmethod void testUnitPriceDistiType(){
        // Account accObj = Sales_TestFactory_Utility.createAccountTypeDirect();  
        //   Account endCustomerObj = createDiffPSGDownstreamAccounts('End Customer','End User');  //(String CoreAccountType, String Acctype)
        Account accObj = createDiffPSGDownstreamAccounts('Distributor','Distributor');     
        Account disti = createDiffPSGDownstreamAccounts('End Customer','Distributor');
        
        Contact con = Sales_TestFactory_Utility.createContact(accObj.Id);
        List<Sales_License_Generator__c> licensegenr = Sales_TestFactory_Utility.createLiceneseGenerator();
        List<Sales_License_Group__c> licgrp = Sales_TestFactory_Utility.createLiceneseGroup(licensegenr[0].Id);
        Core_Product_Ext_Attribute__c licList = Sales_TestFactory_Utility.createProductExtAttribute('BASE',licgrp[0].Id);
        //  Core_Product_Ext_Attribute__c lc1 = Sales_TestFactory_Utility.createProductExtAttribute('CORPORATE',licgrp[0].id);
        Product2 p = Sales_TestFactory_Utility.createDifferentProducts(licList.Id,'','Sample');
        //  Product2 CORPprodct = Sales_TestFactory_Utility.createDifferentProducts(licList.id, '', 'myDevkit'); 
        Opportunity opp = Sales_TestFactory_Utility.createOpportunity(accObj.Id);
        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry standardPrice = Sales_TestFactory_Utility.createPriceBookEntry(p.Id, pricebookId);
        //  PricebookEntry standardCorpPrice = Sales_TestFactory_Utility.createPriceBookEntry(CORPprodct.Id, pricebookId); 
        // SBQQ__Quote__c quoteId = Sales_TestFactory_Utility.createQuoteWithDistiEnd(accObj.Id,createOps.Id,pricebookId); 
        SBQQ__Quote__c q = createQuote(accObj.Id,disti.Id,opp.Id,pricebookId);
        SBQQ__QuoteLine__c qline = Sales_TestFactory_Utility.createNoncorpQuoteLine(q.Id,p.Id,standardPrice.Id) ;
        // SBQQ__QuoteLine__c ql = Sales_TestFactory_Utility.createQuoteLine(q.Id,CORPprodct.Id,standardCorpPrice.Id) ; 
        Test.startTest();
        q.SBQQ__Ordered__c=true;
        update q;
        Order o = [Select Id , SBQQ__Quote__c from Order where SBQQ__Quote__c =:q.Id];
        List<OrderItem> OIList =[Select id,OrderId,Product2Id,Sales_Suggested_Resale_Price__c,Sales_Broken_Price_Amt__c,UnitPrice from OrderItem where OrderId =:o.Id] ;
        //Sales_OrderProductTriggerUtility.beforeInsertOrderProductUtility(OIList);
        Test.stopTest();
    }
    
    /*  static testmethod void testOrderProductsfromQuotelines(){
Account accObj = Sales_TestFactory_Utility.createAccount();    
Contact con = Sales_TestFactory_Utility.createContact(accObj.Id);
List<License_Generator__c> licensegenr = Sales_TestFactory_Utility.createLiceneseGenerator();
List<License_Group__c> licgrp = Sales_TestFactory_Utility.createLiceneseGroup(licensegenr[0].Id);
Core_Product_Ext_Attribute__c licList = Sales_TestFactory_Utility.createProductExtAttribute('BASE',licgrp[0].Id);
Product2 p = Sales_TestFactory_Utility.createDifferentProducts(licList.Id,'SV','Sample');
Id pricebookId = Test.getStandardPricebookId();
PricebookEntry standardPrice = Sales_TestFactory_Utility.createPriceBookEntry(p.Id, pricebookId);
Order o = Sales_TestFactory_Utility.createOrders(accObj.Id, pricebookId,'Licensed Tool Order');

List<OrderItem> OIList = Sales_TestFactory_Utility.createOrderProductList(o.Id, p.Id, standardPrice.Id);
Test.startTest();
Sales_OrderProductTriggerUtility.checkOrderProductsFromQuoteLines(OIList);      
//  Sales_SequenceGenerator.sequenceGenerator(OIList,'OrderItem');
Test.stopTest();
}

static testmethod void testrestrictOrderProductCreation(){
Account accObj = Sales_TestFactory_Utility.createAccount();    
Contact con = Sales_TestFactory_Utility.createContact(accObj.Id);
List<License_Generator__c> licensegenr = Sales_TestFactory_Utility.createLiceneseGenerator();
List<License_Group__c> licgrp = Sales_TestFactory_Utility.createLiceneseGroup(licensegenr[0].Id);
Core_Product_Ext_Attribute__c licList = Sales_TestFactory_Utility.createProductExtAttribute('BASE',licgrp[0].Id);
Product2 p = Sales_TestFactory_Utility.createDifferentProducts(licList.Id,'SV','Sample');
Id pricebookId = Test.getStandardPricebookId();
PricebookEntry standardPrice = Sales_TestFactory_Utility.createPriceBookEntry(p.Id, pricebookId);
Order o = Sales_TestFactory_Utility.createOrders(accObj.Id, pricebookId,'Licensed Tool Order');

List<OrderItem> OIList = Sales_TestFactory_Utility.createOrderProductList(o.Id, p.Id, standardPrice.Id);
Test.startTest();
Sales_OrderProductTriggerUtility.restrictOrderProductCreation(OIList);      
//  Sales_SequenceGenerator.sequenceGenerator(OIList,'OrderItem');
Test.stopTest();
}*/
    
}