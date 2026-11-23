/*************************************************************************************************************
Class Name    : Sales_QuoteUtility_Test
Version       : 1.0
Created Date  : Jan 2021  
Function      :  
Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------
* Mitesh Dedhia           18-June-2021              Test class for Sales_QuoteUtility
*************************************************************************************************************/
@isTest
public class Sales_QuoteUtility_Test{
    /*public static SBQQ__Quote__c createQuote(Id distributorId, Id endCusId,Id oppId, Id pbId){
        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        quote.RecordTypeId= SBQQ__Quote__c.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('PSG_Quote_New').getRecordTypeId();
        quote.core_cpq_active_cb__c = true;
        quote.SBQQ__Primary__c = true;
        quote.SBQQ__PriceBook__c = pbId;
        quote.core_cpq_business_unit_nm__c = 'Military'; 
        quote.core_cpq_quote_type_nm__c='Design Win';
        quote.SBQQ__StartDate__c = date.today()+10;
        quote.SBQQ__SubscriptionTerm__c = 12;
        quote.SBQQ__Status__c = 'Approved';
        quote.core_cpq_end_customer_nm__c=endCusId;
        quote.SBQQ__Account__c=distributorId;
        quote.SBQQ__Type__c = 'Amendment';
        quote.Pricing_Quote_Program_Nm__c = 'PSG';
        insert quote;
        return quote;
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
        acc.Core_Sales_Groups__c = 'undefiend'; 
        Id recordtypeId=[SELECT Id,name,developername from RecordType where sobjecttype='Account' and Developername='Core_Direct_Account' LIMIT 1].Id;
            Account a1=PSG_Test_Utility.createDirectAccount();
            a1.RecordTypeId=recordtypeId;
            a1.Core_Direct_Account_Type_Nm__c='End Customer Parent';
            a1.Core_Is_Pricing_Parent_ChkBox__c=true;
            a1.Core_Direct_Account_Active_Ind__c=true;
            update a1;
            Account a2=PSG_Test_Utility.createDirectAccount();
            a2.RecordTypeId=recordtypeId;
            a2.Core_Direct_Account_Type_Nm__c='End Customer Parent';
            a2.Core_Is_Pricing_Parent_ChkBox__c=true;
            a2.Core_Direct_Legal_Parent_Id__c=a1.Id;
            a2.Core_Direct_Account_Active_Ind__c=true;
            update a2;
            acc.Core_Direct_Pricing_Parent_Id__c=a2.id;
            acc.Core_Direct_Legal_Parent_Id__c=a1.Id;
        insert acc;
        return acc;
    }
    public static Account createDiffPSGDownstreamAccounts(String CoreAccountType, String Acctype){
    Core_Opp_Bypass_Validation_Rule__c bypass = new Core_Opp_Bypass_Validation_Rule__c();
    bypass.Bypass__c=TRUE;
    insert bypass;
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
        acc.Core_Sales_Groups__c = 'Undefined';   
        Id recordtypeId=[SELECT Id,name,developername from RecordType where sobjecttype='Account' and Developername='Core_Direct_Account' LIMIT 1].Id;
            Account a1=PSG_Test_Utility.createDirectAccount();
            a1.RecordTypeId=recordtypeId;
            a1.Core_Direct_Account_Type_Nm__c='End Customer Parent';
            a1.Core_Is_Pricing_Parent_ChkBox__c=true;
            a1.Core_Direct_Account_Active_Ind__c=true;
            update a1;
            Account a2=PSG_Test_Utility.createDirectAccount();
            a2.RecordTypeId=recordtypeId;
            a2.Core_Direct_Account_Type_Nm__c='End Customer Parent';
            a2.Core_Is_Pricing_Parent_ChkBox__c=true;
            a2.Core_Direct_Legal_Parent_Id__c=a1.Id;
            a2.Core_Direct_Account_Active_Ind__c=true;
            update a2;
            acc.Core_Direct_Pricing_Parent_Id__c=a2.id;
            acc.Core_Direct_Legal_Parent_Id__c=a1.Id;
        acc.Core_Direct_Pricing_Parent_Id__c = a2.Id;    
        acc.Core_Direct_Legal_Parent_Id__c = a1.Id;
        insert acc;
        return acc;
    }
    static testmethod void testFirstAmendQuote(){
        Account accObj = Sales_TestFactory_Utility.createAccount();
        Account endCustomerObj = createDiffPSGDownstreamAccounts('End Customer','End User'); 
        List<Sales_License_Generator__c> licensegenr = Sales_TestFactory_Utility.createLiceneseGenerator();
        List<Sales_License_Group__c> licgrp = Sales_TestFactory_Utility.createLiceneseGroup(licensegenr[0].Id);
        Core_Product_Ext_Attribute__c licList = Sales_TestFactory_Utility.createProductExtAttribute('BASE',licgrp[0].Id);
        Product2 p = Sales_TestFactory_Utility.createDifferentProducts(licList.Id,'','Sample');
        Set<Id> prodId = new Set<Id>();
        prodId.add(p.Id);
        Opportunity opp = Sales_TestFactory_Utility.createOpportunity(accObj.Id);
        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry standardPrice = Sales_TestFactory_Utility.createPriceBookEntry(p.Id, pricebookId);
        Contract contractRecord = createContractAssociatedwithQuoteOrder(accObj.Id, null, null);        
        test.starttest();
         SBQQ__Quote__c q1 = createQuote(accObj.Id,endCustomerObj.id,opp.Id,pricebookId);      
        q1.SBQQ__Type__c = 'Quote';
        q1.SBQQ__MasterContract__c =  contractRecord.id;
        update q1;
        SBQQ__Quote__c q = createQuote(accObj.Id,endCustomerObj.id,opp.Id,pricebookId);       
        contractRecord.Sales_Amended_Quote_Id__c = q.id;
        contractRecord.Sales_Amendment_Opportunity_Id__c = opp.Id;
        contractRecord.SBQQ__Quote__c = q1.Id;
        update contractRecord;
        q.SBQQ__MasterContract__c =  contractRecord.id;
        update q;
        test.stoptest();       
    }
    static testmethod void testMultipleAmendQuote(){
        Account accObj = Sales_TestFactory_Utility.createAccount();
        Account endCustomerObj = createDiffPSGDownstreamAccounts('End Customer','End User'); 
        List<Sales_License_Generator__c> licensegenr = Sales_TestFactory_Utility.createLiceneseGenerator();
        List<Sales_License_Group__c> licgrp = Sales_TestFactory_Utility.createLiceneseGroup(licensegenr[0].Id);
        Core_Product_Ext_Attribute__c licList = Sales_TestFactory_Utility.createProductExtAttribute('BASE',licgrp[0].Id);
        Product2 p = Sales_TestFactory_Utility.createDifferentProducts(licList.Id,'','Sample');
        Set<Id> prodId = new Set<Id>();
        prodId.add(p.Id);
        Opportunity opp = Sales_TestFactory_Utility.createOpportunity(accObj.Id);
        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry standardPrice = Sales_TestFactory_Utility.createPriceBookEntry(p.Id, pricebookId);
        Contract contractRecord = createContractAssociatedwithQuoteOrder(accObj.Id, null, null);        
        test.starttest();
         SBQQ__Quote__c q1 = createQuote(accObj.Id,endCustomerObj.id,opp.Id,pricebookId);      
        q1.SBQQ__Type__c = 'Quote';
        update q1;
        SBQQ__Quote__c q = createQuote(accObj.Id,endCustomerObj.id,opp.Id,pricebookId);       
        contractRecord.Sales_Amended_Quote_Id__c = q.id;
        contractRecord.Sales_Amendment_Opportunity_Id__c = opp.Id;
        contractRecord.SBQQ__Quote__c = q1.Id;
        update contractRecord;
        q.SBQQ__MasterContract__c =  contractRecord.id;
        update q;
        test.stoptest();       
    }*/
}