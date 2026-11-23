/*********************************************************************************************************************
Class Name    : Sales_ContractTriggerUtility_Test
Version       : 1.0
Created Date  : April 2021
Function      :  

Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------
* Shivam Vishwakarma        April 2021              Sales_ContractTriggerUtility test class
* *********************************************************************************************************************/
@isTest
public class Sales_ContractTriggerUtility_Test_New {
    
    public static Order createOrdersWithAllAccAndQuote(Id accId, Id pricebookId, String OrderType, Id quoteId, Account soldToAcc, Account shipto, Account endCustmer){                                      
        Account accSoldTo = soldToAcc;//[Select id, ParentId from account where Type='End User' limit 1]; 
        Order o = new Order();
        o.Type= OrderType;//'Licensed Tool Order'
        o.RecordTypeId= Order.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('Sales_Order_Record').getRecordTypeId();
        o.Name = 'Test Order ';
        o.Status = 'Draft';
        o.Sales_status__c = 'Draft Order';  //Previously    o.status__c = 'New'; - US919632 
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
        System.debug('accSoldTo.Id'+accSoldTo.Id);
        System.debug('accShipTo.Id'+accShipTo.Id);
        o.Sales_Shipping_Condition_Txt__c = '1Q';
        o.Sales_Incoterms_Txt__c = 'FCA';
        o.Sales_Shipping_Instructions_Dsc__c = 'xyz';
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
        Account endCustAccount = endCustmer;//Sales_TestFactory_Utility.createEndCustomerAccount();
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
    
    public static List<Contract> createContractAssociatedwithQuoteOrder(Id accId, Id orderId, Id quoteId){
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
    Public static List<Sales_License_Order_Product__c> createSalesLicenseOrdProd(Id licenseId,Id ContractId,Id OrderProductId){
        List<Sales_License_Order_Product__c> licOrdProdList = new List<Sales_License_Order_Product__c>();
        Sales_License_Order_Product__c licOrdProd = new Sales_License_Order_Product__c();
        licOrdProd.Sales_License__c = licenseId;
        licOrdProd.Sales_License_ContractId__c = ContractId;
        licOrdProd.Sales_Order_Product__c = OrderProductId;
        licOrdProd.Sales_License_Expiration_Date_Dt__c = System.Today()+10;
        licOrdProd.Sales_Quantity__c = 1;
        licOrdProdList.add(licOrdProd);
        insert licOrdProdList;
        return licOrdProdList;
    }
    
    public static SBQQ__Quote__c createQuote(Id distributorId,Id oppId, Id endCusId,Id pbId){
        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        quote.RecordTypeId= SBQQ__Quote__c.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('PSG_Quote_New').getRecordTypeId();
        quote.core_cpq_active_cb__c = true;
        quote.SBQQ__Primary__c = true;
        quote.SBQQ__PriceBook__c = pbId;
        quote.core_cpq_business_unit_nm__c = 'Military';
        quote.SBQQ__Type__c = 'Quote';
        quote.core_cpq_status_txt__c = 'Approved';
        quote.SBQQ__Opportunity2__c = oppId;
        quote.core_cpq_quote_type_nm__c='Design Win';
        quote.SBQQ__StartDate__c = date.today()+10;
        quote.SBQQ__SubscriptionTerm__c = 12;
        quote.SBQQ__Status__c = 'Approved';
        quote.core_cpq_end_customer_nm__c=endCusId;
        quote.SBQQ__Account__c=distributorId;
        insert quote;
        return quote;
    }
    
    public static Core_Product_Ext_Attribute__c createProductExtAttributeWithLicTypeExpDuration(String toolType, Id lcGroupid, String licType, Integer expDuration){
        Core_Product_Ext_Attribute__c l1 = new Core_Product_Ext_Attribute__c();
        l1.Core_SW_Lic_Enforcement_Method_Nm__c = 'File';
        l1.Core_Prod_Tool_Type_Nm__c = toolType;
        l1.Core_SW_Lic_Type_Nm__c = licType ; 
        l1.Core_SW_Prod_Max_Rehost_Cnt__c = 1;
        l1.Core_SW_Prod_Web_Dsc__c='Test';
        l1.Core_SW_Lic_File_Data_Encryption_Std_Cd__c = '1DES' ;
        l1.Core_SW_Prod_Avail_To_TL_ORD_ENBLMT_Ind__c = true;
        
        l1.Core_SW_Lic_Generator_Parameter_Txt__c = 'testing';
        l1.Core_SW_Prod_Expiration_Duration_Nbr__c = expDuration;
        
        insert l1;
        return l1;
    }
    
    @isTest public static void testUpdateStartDateOnLicenses(){
        List<Sales_License_Generator__c> gen = Sales_TestFactory_Utility.createLiceneseGenerator();
        List<Sales_License_Group__c> lcgrp = Sales_TestFactory_Utility.createLiceneseGroup(gen[0].id);
        Core_Product_Ext_Attribute__c lc = createProductExtAttributeWithLicTypeExpDuration('BASE',lcgrp[0].id,'Fixed',45);
        Product2 prod = Sales_TestFactory_Utility.createDifferentProducts(lc.id, '', 'myCorp');
        PricebookEntry standardPrice = Sales_TestFactory_Utility.createPriceBookEntry(prod.Id, Test.getStandardPricebookId());        
        Account intelSoldto = Sales_TestFactory_Utility.createIntelSoldAccount();
        Account intelShipto = Sales_TestFactory_Utility.createIntelShipAccount();
        List<Account> acList = new List<Account>();
        acList.add(intelSoldto);
        acList.add(intelShipto);
        insert acList;        
        Test.startTest();
        List<Account> accList2 = new list<Account>();
        Account soldTo = Sales_TestFactory_Utility.createSoldToAccount();
        Account shipTo = Sales_TestFactory_Utility.createShipToAccount();
        Account intelAccount = Sales_TestFactory_Utility.createAccount();
        accList2.add(soldTo);
        accList2.add(shipTo);
        //  insert accList2;
        // Opportunity opp = Sales_TestFactory_Utility.createOpportunity(soldTo.Id);
        // SBQQ__Quote__c q = createQuote(intelSoldto.Id,opp.Id,endCustomerObj.Id, Test.getStandardPricebookId());
        //  SBQQ__QuoteLine__c ql = Sales_TestFactory_Utility.createQuoteLine(q.Id,prod.Id,standardPrice.Id);        
        Order o1 = Sales_TestFactory_Utility.createOrders(soldTo.Id, Test.getStandardPricebookId(),'Licensed Tool Order');
        List<OrderItem> oiList = Sales_TestFactory_Utility.createOrderProductListWithQuoteline(o1.id, prod.id, standardPrice.id,null);
        List<Contract> newContractList = createContractAssociatedwithQuoteOrder(intelSoldto.Id, o1.id, null);
        Contract cont = new Contract();
        cont.id =    newContractList[0].id;
        //cont.Status = 'Activated';
        update cont;
        // newContractList[0].Status = 'Activated';
        //     update newContractList[0];
        Test.stopTest();
        
    }
    /*
@isTest static void updateStartDateOnLicensesCheck(){        
List<License_Generator__c> gen = Sales_TestFactory_Utility.createLiceneseGenerator();
List<License_Group__c> lcgrp = Sales_TestFactory_Utility.createLiceneseGroup(gen[0].id);
Core_Product_Ext_Attribute__c lc = createProductExtAttributeWithLicTypeExpDuration('CORPORATE',lcgrp[0].id,'Float',45);
Product2 prod = Sales_TestFactory_Utility.createDifferentProducts(lc.id, '', 'myCorp');
PricebookEntry standardPrice = Sales_TestFactory_Utility.createPriceBookEntry(prod.Id, Test.getStandardPricebookId());        
Account intelSoldto = Sales_TestFactory_Utility.createIntelSoldAccount();
Account intelShipto = Sales_TestFactory_Utility.createIntelShipAccount();
List<Account> acList = new List<Account>();
acList.add(intelSoldto);
acList.add(intelShipto);
insert acList;
Test.startTest();
Account endCustomerObj = Sales_TestFactory_Utility.createDiffPSGDownstreamAccounts('End Customer','End User');  //(String CoreAccountType, String Acctype)
Account accObj = Sales_TestFactory_Utility.createAccount();    
List<Account> accList2 = new List<Account>();        
//Account soldTo = Sales_TestFactory_Utility.createSoldToAccount();
//Account shipTo = Sales_TestFactory_Utility.createShipToAccount();
//Account intelAccount = Sales_TestFactory_Utility.createAccount();
//accList2.add(soldTo);
//accList2.add(shipTo);

//accList2.add(endCustomerObj);
//accList2.add(accObj);
insert accList2;
Opportunity opp = Sales_TestFactory_Utility.createOpportunity(accObj.Id);
SBQQ__Quote__c q = createQuote(accObj.Id,opp.Id,endCustomerObj.Id, Test.getStandardPricebookId());
SBQQ__QuoteLine__c ql = Sales_TestFactory_Utility.createQuoteLine(q.Id,prod.Id,standardPrice.Id);        
Order o1 = Sales_TestFactory_Utility.createOrders(accObj.Id, Test.getStandardPricebookId(),'Licensed Tool Order');
//Order o1 = createOrdersWithAllAccAndQuote(accObj.Id, Test.getStandardPricebookId(),'Licensed Tool Order',q.Id, soldTo, shipTo, endCustomerObj); 
// o1.Type = 'Licensed Tool Order';
//o1.Sales_Order_Sub_Type__c = 'Corporate Order';
//update o1;

try{            

System.debug('##Order Details: '+o1);

system.debug('###Inside Test.startTest');

List<OrderItem> oiList = Sales_TestFactory_Utility.createOrderProductListWithQuoteline(o1.id, prod.id, standardPrice.id,ql.Id);

//Update Contact on Order Item
//List<OrderItem> oiList = [SELECT Id,Sales_Contact__c,OrderId,SBQQ__QuoteLine__c FROM OrderItem WHERE OrderId =: o1.Id ]; 

Map<Id, Order> orderMap = new Map<Id, Order>();
Contact con = Sales_TestFactory_Utility.createContact(accObj.Id);
oiList[0].Sales_Contact__c = con.Id;
update oiList;
insert new PRM_Execution_Controls__c(SetupOwnerId=UserInfo.getUserId(), Skip_ValidationRule_Order_Status__c=true);

o1.Sales_status__c='Order created successfully';
//o1.Status='Activated';
o1.SBQQ__ContractingMethod__c='Single Contract';
o1.Sales_Order_Sub_Type__c = 'Corporate Order';
//o1.SBQQ__Contracted__c=true;
update o1;

//orderMap.putAll(new List<Order>{o1});
orderMap.put(o1.Id, o1);
System.debug('@@##OrderMap: '+orderMap);
//Contract newContract = [select id, SBQQ__Order__c from Contract where SBQQ__Order__c=:o1.Id limit 1];
List<Contract> newContractList = createContractAssociatedwithQuoteOrder(accObj.Id, o1.id, q.Id);
System.debug('@@##Contract: '+newContractList);              

List<Sales_License__c> licensesList = new List<Sales_License__c>();
//Map<Id,OrderItem> orderItemMap =new Map<Id,OrderItem>(oiList); 
//licensesList.addAll([ SELECT Id,Sales_License_Order_Product__c FROM Sales_License__c WHERE Sales_License_Order_Product__c IN:orderItemMap.keySet()]);
licensesList = createSalesLicense(o1.Sales_End_Customer_Account__c, o1.id, oiList[0].Id, prod.id, newContractList[0].id );  //(Id accId, Id orderId, Id ordProdId, Id prodId ,Id ContractId)
System.debug('@@##Licenses: '+licensesList);  

List<Sales_License_Order_Product__c> licensesOrdProdObjList = createSalesLicenseOrdProd(licensesList[0].Id, newContractList[0].Id, oiList[0].Id );  //(Id licenseId,Id ContractId,Id OrderProductId)
System.debug('@@##Licenses ord prod obj: '+licensesOrdProdObjList);  


Sales_ContractTriggerUtility.updateStartDateOnLicenses(newContractList,orderMap);
Test.stopTest();
}catch(Exception e){
//System.assert(false, e.getMessage());
}

}

*/
    @isTest static void deleteRenewalOppCheck(){
        
        system.debug('Limits Time==>'+Limits.getCpuTime()+';;Queries==>'+Limits.getQueries());
        Account accObj = Sales_TestFactory_Utility.createAccount(); 
        //Account endCustomerObj = Sales_TestFactory_Utility.createDiffPSGDownstreamAccounts('End Customer','End User');  
        
        List<Account> accListToInsert = new List<Account>();
        Account parentShipToAccount = Sales_TestDataFactory.createPartnerIntelShipToAccount();
        accListToInsert.add(parentShipToAccount);
        
        Account parentSoldToAccount = Sales_TestDataFactory.createDefaultAccount();
        accListToInsert.add(parentSoldToAccount);
        
        Account parentEndCustomerAccount = Sales_TestDataFactory.createParentEndCustomerAccount();
        parentEndCustomerAccount.Core_Sub_Industry__c = null;
        accListToInsert.add(parentEndCustomerAccount);
        
        insert accListToInsert;
        
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
        
        insert accListToInsert;
        
        Core_Account_SoldTo_ShipTo_Rel__c relation_Ship_Sold = Sales_TestDataFactory.accSoldToShipToRelationshipRecord(new Map<String,String>{
            'Core_Sold_To_Account__c'  =>  soldToAccount.Id,
                'Core_Ship_To_Account__c'  =>  shipToAccount.Id
                });
        insert relation_Ship_Sold;
        
        List<Sales_License_Generator__c> gen = Sales_TestFactory_Utility.createLiceneseGenerator();
        List<Sales_License_Group__c> lcgrp = Sales_TestFactory_Utility.createLiceneseGroup(gen[0].id);
        /*Core_Product_Ext_Attribute__c lc = Sales_TestFactory_Utility.createProductExtAttribute('CORPORATE',lcgrp[0].id);

Product2 prod = Sales_TestFactory_Utility.createDifferentProducts(lc.id, '', 'myCorp');
PricebookEntry standardPrice = Sales_TestFactory_Utility.createPriceBookEntry(prod.Id, Test.getStandardPricebookId());
Opportunity opp = Sales_TestFactory_Utility.createOpportunity(accObj.Id);

//Test.startTest();  
SBQQ__Quote__c q = Sales_TestDataFactory.createQuoteRecord();
insert q;
System.debug('testttt'+q.core_cpq_active_cb__c);
System.debug('testttt1'+q.SBQQ__Status__c);
System.debug('testttt2'+q);
SBQQ__QuoteLine__c ql = Sales_TestDataFactory.createQuoteLineRecord(); */
        //insert ql;
        //Test.startTest();  
        
        // Order o1 = createOrdersWithAllAccAndQuote(accObj.Id, Test.getStandardPricebookId(),'Licensed Tool Order',q.Id, soldTo, shipTo);
        
        system.debug('Limits Time 111==>'+Limits.getCpuTime()+';;Queries==>'+Limits.getQueries());
        Opportunity oppRenewal = Sales_TestFactory_Utility.createOpportunity(accObj.Id);  
        //Test.startTest();
        // Account endCustomerObj = Sales_TestFactory_Utility.createDiffPSGDownstreamAccounts('End Customer','End User');
        //Order o1 = Sales_TestFactory_Utility.createNonCommOrder();
        system.debug('Limits Time 222==>'+Limits.getCpuTime()+';;Queries==>'+Limits.getQueries());
        
        Core_Product_Ext_Attribute__c prodExt1 = Sales_TestDataFactory.createProductExternalAttributes();
        prodExt1.put('Core_SW_Lic_Type_Nm__c','FLOAT');
        prodExt1.put('Core_Prod_Tool_Type_Nm__c','CORPORATE');
        insert prodExt1 ;
        Product2 prod1 = Sales_TestDataFactory.createProduct();
        prod1.put('Core_Product_Ext_Attribute_Id__c',prodExt1.Id);
        insert prod1;
        Opportunity opp = Sales_TestDataFactory.createOpportunityRecord();
        opp.put('AccountId',accObj.Id);
        insert opp;
        system.debug('Limits Time 333==>'+Limits.getCpuTime()+';;Queries==>'+Limits.getQueries());
        PriceBookEntry pbEntry = Sales_TestDataFactory.createPriceBookEntry();
        pbEntry.Pricebook2Id = Test.getStandardPricebookId();
        pbEntry.Product2Id = prod1.Id;
        insert pbEntry;
        system.debug('Limits Time 444==>'+Limits.getCpuTime()+';;Queries==>'+Limits.getQueries());
        TriggerHandler.bypass('QuoteTriggerHandler');
        SBQQ__Quote__c q = Sales_TestDataFactory.createQuoteRecord();
        q.SBQQ__Account__c = accObj.Id;
        q.SBQQ__Status__c = 'Approved';
        //q.core_cpq_end_customer_nm__c = endCustomerAcc.Id;
        q.SBQQ__Opportunity2__c = opp.Id;
        insert q;
        TriggerHandler.clearBypass('QuoteTriggerHandler');
        
        Test.startTest();
        
        system.debug('Limits Time 555==>'+Limits.getCpuTime()+';;Queries==>'+Limits.getQueries());
        SBQQ__QuoteLine__c ql = Sales_TestDataFactory.createQuoteLineRecord();
        ql.SBQQ__Quote__c = q.Id;
        ql.SBQQ__PricebookEntryId__c = pbEntry.Id;
        ql.SBQQ__Product__c = prod1.Id;
        insert ql;
		
        system.debug('Limits Time 555 000==>'+Limits.getCpuTime()+';;Queries==>'+Limits.getQueries());
        //q.SBQQ__Status__c = 'Approved';
        //update q;
        system.debug('Limits Time 666==>'+Limits.getCpuTime()+';;Queries==>'+Limits.getQueries());
        system.debug('Quote Details ==>Active==>'+q.core_cpq_active_cb__c+';;Status==>'+q.SBQQ__Status__c);
        system.debug('Quote Details 11==>'+ [SELECT id,core_cpq_active_cb__c,SBQQ__Status__c FROM SBQQ__Quote__c WHERE Id=:q.Id]);
        //Order o1 = Sales_TestFactory_Utility.createNonCommOrder();
        //public static Order createOrdersWithAllAccAndQuote(Id accId, Id pricebookId, String OrderType, Id quoteId, Account soldToAcc, Account shipto, Account endCustmer){                                      
		TriggerHandler.bypass('Sales_OrderTriggerHandler');
        Order o1 = createOrdersWithAllAccAndQuote(accObj.Id, Test.getStandardPricebookId(), 'Non Commercial Order', q.Id, soldToAccount, shipToAccount, endCustomer);                                    
        OrderItem op1 = Sales_TestDataFactory.createOrderItem();        
        op1.OrderId = o1.Id;
        op1.Product2Id = prod1.Id;
        op1.PricebookEntryId = pbEntry.Id;
        op1.SBQQ__QuoteLine__c = ql.Id;
        //op1.Sales_Contact__c = con2.Id;
        
        //TriggerHandler.bypass('Sales_OrderProductTriggerHandler');
        // insert op1;
        //TriggerHandler.clearAllBypasses();
        o1.Sales_Order_Sub_Type__c='Corporate Order';
        o1.Sales_status__c='SAP Order Shipped';
        o1.Sales_Order_Reason__c='Non Stocking Order';
        o1.SBQQ__ContractingMethod__c ='Single Contract';
        o1.Status='Activated';
        o1.SBQQ__Quote__c=q.id;
        //o1.Sales_End_Customer_Account__c=endCustomerObj.Id;
        //TriggerHandler.bypass('Sales_OrderTriggerHandler');
        update o1;
        TriggerHandler.clearAllBypasses(); 
        system.debug('Limits Time 777==>'+Limits.getCpuTime()+';;Queries==>'+Limits.getQueries());
        List<Contract> newContractList = createContractAssociatedwithQuoteOrder(accObj.Id, o1.id, q.Id);
        
        newContractList[0].Sales_Program__c = 'PSG';
        newContractList[0].SBQQ__RenewalOpportunity__c = oppRenewal.Id;
        newContractList[0].StartDate = system.today();
        //wContractList[0].Status = 'Activated';
        update newContractList;
        newContractList[0].SBQQ__RenewalQuoted__c= true;
        newContractList[0].SBQQ__RenewalForecast__c= true;           
        //update newContractList;
        System.debug('@@##Contract: '+newContractList);    
        //QQ__Quote__c renewalQuote = Sales_TestFactory_Utility.createQuote(accObj.Id,null,opp.Id,Test.getStandardPricebookId());
        //newalQuote.SBQQ__Opportunity2__c = oppRenewal.Id;
        //enewalQuote.SBQQ__Type__c = 'Renewal' ;
        //date renewalQuote;
        OrderItem oiList = Sales_TestDataFactory.createOrderItem();
        insert oiList;
        oiList.SBQQ__Contract__c= newContractList[0].id;
        oiList.OrderId =o1.id;
        update oiList;
        system.debug('Limits Time 888==>'+Limits.getCpuTime()+';;Queries==>'+Limits.getQueries());
        Map<Id, Contract> onMap = new Map<Id, Contract>([Select Id,Sales_Program__c,Status from Contract Order where Id = :newContractList[0].id]);                       
        //Sales_ContractTriggerUtility.updateStartDateOnLicenses(onMap);          
        Sales_ContractTriggerUtility.deleteRenewalOpportunity(newContractList);
        system.debug('Limits Time 999==>'+Limits.getCpuTime()+';;Queries==>'+Limits.getQueries());
        // Sales_ContractTriggerUtility.updateContractStatusToActivated(newContractList);
        
        Test.stopTest();
        
        
    }
    
}//End of class