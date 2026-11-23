/*********************************************************************************************************************
Class Name    : Sales_SequenceGenerator_Test
Version       : 1.0
Created Date  : Apr 2021  
Function      :  
Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------
* Shivam Vishwakarma        05-Apr-2021              Test class for Sales_SequenceGenerator (sequenceGenerator method is called in Before Insert trigger event)
* *********************************************************************************************************************/
@isTest 
public class Sales_SequenceGenerator_Test {
/*
    @isTest
    static void testException(){	
        try{
            test.startTest();
            Sales_SequenceGenerator.sequenceGenerator(null,'OrderItem');
            test.stopTest();
        }
        catch(Exception e){
            Boolean expectedExceptionThrown =  (e.getMessage() != null) ? true : false;
            System.assert(expectedExceptionThrown);
        }
    }
    @isTest
    static void testSAPLineNo_ForOneNew_OrderItem_License(){	
        try{
            Id pricebookId = Test.getStandardPricebookId();
            Account accObj = Sales_TestFactory_Utility.createAccount(); 
            List<Sales_License_Generator__c> gen = Sales_TestFactory_Utility.createLiceneseGenerator();
            List<Sales_License_Group__c> lcgrp = Sales_TestFactory_Utility.createLiceneseGroup(gen[0].id);
            Core_Product_Ext_Attribute__c lc = Sales_TestFactory_Utility.createProductExtAttribute('BASE',lcgrp[0].id);
            Product2 armprodct = Sales_TestFactory_Utility.createDifferentProducts(lc.id, 'SV', 'myARM');
            armprodct.Core_Item_Orderable_Ind__c=true;
            update armprodct;
            PricebookEntry standardPrice = Sales_TestFactory_Utility.createPriceBookEntry(armprodct.Id, pricebookId);
            Order o = Sales_TestFactory_Utility.createOrders(accObj.Id, pricebookId,'Sample Order');
            List<OrderItem> oiList = Sales_TestFactory_Utility.createOrderProductList(o.id, armprodct.id, standardPrice.id);
            test.startTest();
            Map<Id,OrderItem> orderItemMap =new Map<Id,OrderItem>(oiList);
            List<Integer> OPsapLineNoList = new List<Integer>();
            List<Integer> LICsapLineNoList = new List<Integer>();
            oiList[0].Quantity=oiList[0].Quantity+1;
            update oiList[0];
            if(!orderItemMap.isEmpty()){
                for(orderItem oi : [ SELECT Id,Sales_SAPLine_Nbr__c FROM OrderItem WHERE Id IN:orderItemMap.keyset() ]){
                    OPsapLineNoList.add(Integer.valueOf(oi.Sales_SAPLine_Nbr__c));
                }
                Boolean OPSAPLineNogeneratedCheck = ( OPsapLineNoList.size() != 0 ) ? true : false;
                system.assert(OPSAPLineNogeneratedCheck);
                for(Sales_License__c lic : [ SELECT Id,Sales_License_Order_Product__c,Sales_License_SAPLine_Nbr__c FROM Sales_License__c WHERE Sales_License_Order_Product__c IN:orderItemMap.keyset() ]){
                    LICsapLineNoList.add(Integer.valueOf(lic.Sales_License_SAPLine_Nbr__c));
                }
                Boolean LicSAPLineNogeneratedCheck = ( LICsapLineNoList.size() != 0 ) ? true : false;
                system.assert(LicSAPLineNogeneratedCheck);
            }            
            test.stopTest();
        }
        catch(Exception e){
            Boolean expectedExceptionThrown =  (e.getMessage() != null) ? false : true;
        }
    }
    @isTest
    static void testSAPLineNo_ForExistingandNew_OrderItem_License(){	
        try{
            Id pricebookId = Test.getStandardPricebookId();
            Account accObj = Sales_TestFactory_Utility.createAccount(); 
            List<Sales_License_Generator__c> gen = Sales_TestFactory_Utility.createLiceneseGenerator();
            List<Sales_License_Group__c> lcgrp = Sales_TestFactory_Utility.createLiceneseGroup(gen[0].id);
            Core_Product_Ext_Attribute__c lc = Sales_TestFactory_Utility.createProductExtAttribute('BASE',lcgrp[0].id);
            Product2 armprodct = Sales_TestFactory_Utility.createDifferentProducts(lc.id, 'SV', 'myARM');
            armprodct.Core_Item_Orderable_Ind__c=true;
            update armprodct;
            PricebookEntry standardPrice = Sales_TestFactory_Utility.createPriceBookEntry(armprodct.Id, pricebookId);
            Order o = Sales_TestFactory_Utility.createOrders(accObj.Id, pricebookId,'Sample Order');
            List<OrderItem> oiList = Sales_TestFactory_Utility.createOrderProductList(o.id, armprodct.id, standardPrice.id);
            test.startTest();
            List<OrderItem> oiList2 = Sales_TestFactory_Utility.createOrderProductList(o.id, armprodct.id, standardPrice.id);
            oiList2[0].Quantity =4;
            update oiList2;
            Map<Id,OrderItem> orderItemMap =new Map<Id,OrderItem>(oiList);
            orderItemMap.putAll(oiList2);
            List<Integer> OPsapLineNoList = new List<Integer>();            
            List<Integer> LICsapLineNoList = new List<Integer>();
            if(!orderItemMap.isEmpty()){
                for(orderItem oi : [ SELECT Id,Sales_SAPLine_Nbr__c FROM OrderItem WHERE Id IN:orderItemMap.keyset() ]){
                    OPsapLineNoList.add(Integer.valueOf(oi.Sales_SAPLine_Nbr__c));
                }
                Boolean OPSAPLineNogeneratedCheck = ( OPsapLineNoList.size() != 0 ) ? true : false;
                system.assert(OPSAPLineNogeneratedCheck);
                for(Sales_License__c lic : [ SELECT Id,Sales_License_Order_Product__c,Sales_License_SAPLine_Nbr__c,Sales_License_Product__c FROM Sales_License__c WHERE Sales_License_Order_Product__c IN:orderItemMap.keyset() ]){
                    LICsapLineNoList.add(Integer.valueOf(lic.Sales_License_SAPLine_Nbr__c));
                }
                Boolean LicSAPLineNogeneratedCheck = ( LICsapLineNoList.size() != 0 ) ? true : false;
                system.assert(LicSAPLineNogeneratedCheck);
            }            
            test.stopTest();
        }
        catch(Exception e){
            Boolean expectedExceptionThrown =  (e.getMessage() != null) ? false : true;
        }
    } 
    @isTest
    static void testSeqNoAfterLicDelete(){
        try{
            Id pricebookId = Test.getStandardPricebookId();
            Account accObj = Sales_TestFactory_Utility.createAccount(); 
            List<Sales_License_Generator__c> gen = Sales_TestFactory_Utility.createLiceneseGenerator();
            List<Sales_License_Group__c> lcgrp = Sales_TestFactory_Utility.createLiceneseGroup(gen[0].id);
            Core_Product_Ext_Attribute__c lc = Sales_TestFactory_Utility.createProductExtAttribute('BASE',lcgrp[0].id);
            Product2 armprodct = Sales_TestFactory_Utility.createDifferentProducts(lc.id, 'SV', 'myARM');
            armprodct.Core_Item_Orderable_Ind__c=true;
            update armprodct;
            PricebookEntry standardPrice = Sales_TestFactory_Utility.createPriceBookEntry(armprodct.Id, pricebookId);
            Order o = Sales_TestFactory_Utility.createOrders(accObj.Id, pricebookId,'Sample Order');
            List<OrderItem> oiList = Sales_TestFactory_Utility.createOrderProductList(o.id, armprodct.id, standardPrice.id);
            test.startTest();
            List<OrderItem> oiList2 = Sales_TestFactory_Utility.createOrderProductList(o.id, armprodct.id, standardPrice.id);
            Map<Id,OrderItem> orderItemMap =new Map<Id,OrderItem>(oiList);
            orderItemMap.putAll(oiList2);
            List<Integer> OPsapLineNoList = new List<Integer>();            
            List<Integer> LICsapLineNoList = new List<Integer>();
            List<Sales_License_Order_Product__c> jucntionLicList=new List<Sales_License_Order_Product__c>([Select Id ,Sales_Order_Product__c,Sales_License__c,Sales_License__r.Sales_License_SAPLine_Nbr__c,Sales_License__r.Name from Sales_License_Order_Product__c where Sales_Order_Product__c IN:orderItemMap.keySet() order by Sales_License__r.Sales_License_SAPLine_Nbr__c ASC]);
            List<Sales_License_Order_Product__c> deleteJunLicRec= new List<Sales_License_Order_Product__c>();
            List<Sales_License__c> deleteLicRec= new List<Sales_License__c>();
            deleteJunLicRec.add(jucntionLicList[0]);
            deleteLicRec.add([Select Id from Sales_License__c where Id =:jucntionLicList[0].Sales_License__c]);
            delete deleteJunLicRec;
            delete deleteLicRec;
            test.stopTest();
        }  
        catch(Exception e){
            Boolean expectedExceptionThrown =  (e.getMessage() != null) ? false : true;
        }
    }    
*/
}