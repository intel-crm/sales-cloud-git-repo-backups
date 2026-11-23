/*********************************************************************************************************************
Class Name    : Sales_PriceChangeWarning
Version       : 1.0
Created Date  : April 2021  
Function      :  
Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------
* Nilesh Mithapelli           23-Apr-2021              Updating the field on Order in case of price mismatch with orderproduct
* *********************************************************************************************************************/
public without sharing class Sales_PriceChangeWarning {
    public static void priceMismatchCheck(List<SBQQ__QuoteLine__c> quoteLineList,Map<Id,SBQQ__QuoteLine__c> oldMap){
        if(quoteLineList!=null && !quoteLineList.isEmpty()){
            Set<Id> quoteIds = new Set<Id>();
            Map<Id,Id> quotelineToQuoteMap = new Map<Id,Id>();
            Map<Id,Id> orderToQuote = new  Map<Id,Id>();
            Map<Id,Id> orderToAccountMap = new Map<Id,Id>();
            Map<Id,Account> accMap= new Map<Id,Account>();
            Map<Id,Id> orderToOrderItem = new Map<Id,Id>();
            Map<Id,Order> orderMap = new Map<Id,Order>();
            Map<Id,Core_Product_Ext_Attribute__c> psgToProductMap = new Map<Id,Core_Product_Ext_Attribute__c>();
            Map<Id,SBQQ__QuoteLine__c> qlineMap = new Map<Id,SBQQ__QuoteLine__c>();
            List<Order> ordList = new List<Order>();
            Set<Id> productIdSet = new Set<Id>();        
            for(SBQQ__QuoteLine__c qline : quoteLineList){
                if(qline.SBQQ__Quote__c != null){
                    productIdSet.add(qline.SBQQ__Product__c);
                    quoteIds.add(qline.SBQQ__Quote__c);
                    quotelineToQuoteMap.put(qline.Id,qline.SBQQ__Quote__c);
                    qlineMap.put(qline.Id,qline);
                }
            }
            for(Order ord : [Select Id , SBQQ__Quote__c,Type,AccountId,Sales_Sold_To_Account__c from Order where SBQQ__Quote__c IN:quotelineToQuoteMap.values() and Status='Draft']){
                orderToQuote.put(ord.Id,ord.SBQQ__Quote__c);
                orderToAccountMap.put(ord.Id,ord.Sales_Sold_To_Account__c);
                orderMap.put(ord.Id,ord);
            }
            for(Account acc :[Select Id,type,Core_Direct_Distributor_Channel_Nm__c from Account where Id IN:orderToAccountMap.values()]){
                accMap.put(acc.Id,acc);
            }
            for(OrderItem oi : [Select Id ,Product2Id,Sales_Broken_Price_Amt__c,Sales_Suggested_Resale_Price__c,UnitPrice,SBQQ__QuoteLine__c,OrderId,UnitPriceForceOverride__c from OrderItem where SBQQ__QuoteLine__c IN:quotelineToQuoteMap.keySet() and OrderId IN:orderToQuote.keySet() and Product2Id IN:productIdSet]){
                Id accountId =  orderToAccountMap.get(oi.OrderId);
                Account accRecord = accMap.get(accountId); 
                if(orderMap.get(oi.OrderId).Sales_Sold_To_Account__c!=null && orderMap.get(oi.OrderId).type!='Non Commercial Order' && oi.UnitPriceForceOverride__c==null && (accRecord.Core_Direct_Distributor_Channel_Nm__c=='02' && (oi.UnitPrice!=qlineMap.get(oi.SBQQ__QuoteLine__c).price_brokencost_amt__c)) || (accRecord.Core_Direct_Distributor_Channel_Nm__c=='01' && oi.UnitPrice!=qlineMap.get(oi.SBQQ__QuoteLine__c).price_suggested_resale_amt__c)){
                    orderToOrderItem.put(oi.Id,oi.OrderId);
                }
            }
            for(Order ord :[Select Id,Sales_IsPriceChanged__c,Sales_Req_Ship_Date_Dt__c from Order where Id IN:orderToOrderItem.values() and Status='Draft']){
                if(ord.Sales_Req_Ship_Date_Dt__c < Date.today()){
                    ord.Sales_Req_Ship_Date_Dt__c = Date.today();
                }
                ord.Sales_IsPriceChanged__c = true;
                ordList.add(ord);
            }
            if(ordList.size()>0){
                update ordList;
            }
        }
    }
}