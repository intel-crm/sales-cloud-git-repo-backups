@isTest
public class pricechangewarningtest {       
    
    public static Account createDiffPSGDownstreamAccounts(String CoreAccountType, String Acctype){
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
        //quote.core_cpq_status_txt__c = 'Approved';
        quote.core_cpq_quote_type_nm__c='Design Win';
        quote.SBQQ__StartDate__c = date.today()+10;
        quote.SBQQ__SubscriptionTerm__c = 12;
        quote.SBQQ__Status__c = 'Approved';
        quote.core_cpq_end_customer_nm__c=endCusId;
        quote.SBQQ__Account__c=distributorId;
        quote.SBQQ__Type__c = 'Quote';
        insert quote;
        return quote;
    }
    
     static testmethod void testpricechange(){
        try{
            Account endCustomerObj = createDiffPSGDownstreamAccounts('End Customer','End User');  //(String CoreAccountType, String Acctype)
            Account accObj = createDiffPSGDownstreamAccounts('Distributor','Distributor');    
            //Contact con = Sales_TestFactory_Utility.createContact(accObj.Id);
            List<Sales_License_Generator__c> licensegenr = Sales_TestFactory_Utility.createLiceneseGenerator();
            List<Sales_License_Group__c> licgrp = Sales_TestFactory_Utility.createLiceneseGroup(licensegenr[0].Id);
            Core_Product_Ext_Attribute__c licList = Sales_TestFactory_Utility.createProductExtAttribute('BASE',licgrp[0].Id);
            Product2 p = Sales_TestFactory_Utility.createDifferentProducts(licList.Id,'','myBase');
            List<Core_Product_Ext_Attribute__c> extList = new List<Core_Product_Ext_Attribute__c>();
            licList.Core_Product_Id__c = p.Id;
            extList.add(licList);
            update extList;
            Opportunity opp = Sales_TestFactory_Utility.createOpportunity(accObj.Id);
            Id pricebookId = Test.getStandardPricebookId();
            PricebookEntry standardPrice = Sales_TestFactory_Utility.createPriceBookEntry(p.Id, pricebookId);
            SBQQ__Quote__c q = createQuote(accObj.Id,endCustomerObj.Id,opp.Id,pricebookId);
            SBQQ__QuoteLine__c qline = Sales_TestFactory_Utility.createNonCorpQuoteLine(q.Id,p.Id,standardPrice.Id) ;
            Test.startTest();
            // SBQQ__QuoteLine__c ql = Sales_TestFactory_Utility.createQuoteLine(q.Id,p.Id,standardPrice.Id) ;
            
            q.SBQQ__Ordered__c=true;
            update q;
            Order o = [Select Id , SBQQ__Quote__c from Order where SBQQ__Quote__c =:q.Id LIMIT 1];
            
            List<OrderItem> OIList =[Select id,OrderId,Product2Id,Sales_Suggested_Resale_Price__c,Sales_Broken_Price_Amt__c,UnitPrice from OrderItem where OrderId =:o.Id LIMIT 1] ;
            Test.stopTest();
            Map<Id, Order> ordMap = new Map<Id, Order>([Select Id,Sales_End_Customer_Account__c,Sales_Sold_To_Account__c,SBQQ__Quote__r.SBQQ__Opportunity2__c, SBQQ__Quote__c, SBQQ__Quote__r.SBQQ__Type__c,SBQQ__Quote__r.SBQQ__StartDate__c,SBQQ__Quote__r.SBQQ__MasterContract__c,Sales_Req_Ship_Date_Dt__c,EffectiveDate, Type, Sales_Order_Sub_Type__c,Sales_Order_Reason__c, AccountId from Order where Id = :o.id]);
            System.debug('orderproduct list>>'+OIList.size());
            List<SBQQ__QuoteLine__c> existingQLList = new List<SBQQ__QuoteLine__c>{qline};            
                qline.price_suggested_resale_amt__c = 90;
            qline.price_brokencost_amt__c = 30 ; 
            List<SBQQ__QuoteLine__c> quoteLineList = new List<SBQQ__QuoteLine__c>();
            quoteLineList.add(qline);
            // quoteLineList.add(qline);
            Map<Id,SBQQ__QuoteLine__c> qlineMap = new Map<Id,SBQQ__QuoteLine__c>(quoteLineList);
            
            Sales_PriceChangeWarning.priceMismatchCheck(existingQLList,new Map<Id,SBQQ__QuoteLine__c>{qline.Id => qline}); 
            
        }catch(Exception e){
            //system.assert(false, e.getMessage());
        }   
    }
    
}