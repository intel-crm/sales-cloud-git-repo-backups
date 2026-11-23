/*********************************************************************************************************************
Class Name    : Core_PSG_DisplayWarning
Version       : 1.0
Created Date  : Dec 2020
Function      : Controller class for corePSGDisplayWrning.cmp

Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------
* Srishty Sharma           22-Jan-2020              US862469:Price & Quantity Logic of a Order Product for different types of orders
* *********************************************************************************************************************/
public with sharing class Core_PSG_DisplayWarning {
    @AuraEnabled
    public static String validateQuantity(String orderId){
        Map<Id,Map<Id,Decimal>> orderToProductQuanityMapOnOrderItem = new Map<Id,Map<Id,Decimal>>();
        Map<Id,Map<Id,Decimal>> quoteToProductQuanityMapOnQuoteLine = new Map<Id,Map<Id,Decimal>>();
        Order orderRecord = [Select Id,SBQQ__Quote__c from Order where Id=:orderId Limit 1];
        if(orderRecord.SBQQ__Quote__c==null){
            return null;
        }
        
        for(OrderItem orderLine:[Select OrderId,Product2Id,Quantity from OrderItem where OrderId=:orderId order by OrderId]){
            Map<Id,Decimal> productQuantityMap = new Map<Id,Decimal>();
            if(orderToProductQuanityMapOnOrderItem.containsKey(orderLine.OrderId)){
                productQuantityMap = orderToProductQuanityMapOnOrderItem.get(orderLine.OrderId);
                if(productQuantityMap.containsKey(orderLine.Product2Id)){
                    Decimal productQuantity = productQuantityMap.get(orderLine.Product2Id);
                    productQuantity+=orderLine.Quantity;
                    productQuantityMap.put(orderLine.Product2Id,productQuantity);//Adding product and its qunatity from order ite,
                }
                else{
                    productQuantityMap.put(orderLine.Product2Id,orderLine.Quantity);
                }
                orderToProductQuanityMapOnOrderItem.put(orderLine.OrderId,productQuantityMap);//map of order with map of product and quanity.
            }
            else{
                productQuantityMap.put(orderLine.Product2Id,orderLine.Quantity);
                orderToProductQuanityMapOnOrderItem.put(orderLine.OrderId,productQuantityMap); //map of order with map of product and quanity added for first time.
            }
        }
        
        for(SBQQ__QuoteLine__c quoteLine:[Select SBQQ__Quote__c,SBQQ__Product__c,SBQQ__Quantity__c from SBQQ__QuoteLine__c where SBQQ__Quote__c =:orderRecord.SBQQ__Quote__c order by SBQQ__Quote__c]){
            Map<Id,Decimal> productQuantityMap = new Map<Id,Decimal>();
            if(quoteToProductQuanityMapOnQuoteLine.containsKey(quoteLine.SBQQ__Quote__c)){
                productQuantityMap = quoteToProductQuanityMapOnQuoteLine.get(quoteLine.SBQQ__Quote__c);
                if(productQuantityMap.containsKey(quoteLine.SBQQ__Product__c)){
                    Decimal productQuantity = productQuantityMap.get(quoteLine.SBQQ__Product__c);
                    Decimal quoteLineQuantity = quoteLine.SBQQ__Quantity__c!=null?quoteLine.SBQQ__Quantity__c:0;
                    productQuantity+=quoteLineQuantity;
                    productQuantityMap.put(quoteLine.SBQQ__Product__c,productQuantity);//Map of Quoteline and its quantity
                }
                else{
                    productQuantityMap.put(quoteLine.SBQQ__Product__c,quoteLine.SBQQ__Quantity__c);
                }
                quoteToProductQuanityMapOnQuoteLine.put(quoteLine.SBQQ__Quote__c,productQuantityMap);//Map of Qoute and correponding map of Quoteline and its quantity
            }
            else{
                Decimal quantity = quoteLine.SBQQ__Quantity__c!=null?quoteLine.SBQQ__Quantity__c:0;
                productQuantityMap.put(quoteLine.SBQQ__Product__c,quantity);
                quoteToProductQuanityMapOnQuoteLine.put(quoteLine.SBQQ__Quote__c,productQuantityMap); //Map of Qoute and correponding map of Quoteline and its quantity for first time
            }
        }
        Map<Id,Decimal> productQuantityOnOrderMap = new Map<Id,Decimal>();
        Map<Id,Decimal> productQuantityOnQuoteMap = new Map<Id,Decimal>();
        productQuantityOnOrderMap = orderToProductQuanityMapOnOrderItem.get(orderId);
        productQuantityOnQuoteMap = quoteToProductQuanityMapOnQuoteLine.get(orderRecord.SBQQ__Quote__c);
        if(!compareMaps(productQuantityOnOrderMap,productQuantityOnQuoteMap)){
            return System.label.Core_PSG_OrderQtyNotMatch;//Message displayed on LWC component
        }
        else{
            return null;
        }
        
    }
    //This method compare Order product and Quote line product on quantity
    private static Boolean compareMaps(Map<Id,Decimal> firstMap, Map<Id,Decimal> secondMap) {
        if(firstMap!=null){
            if (firstMap.size() > secondMap.size()){
                return false;
            }
            for (Id key: firstMap.keySet()){
                if(!secondMap.containsKey(key)){
                    return false;
                }
                if (firstMap.get(key) > secondMap.get(key)){
                    return false;
                }
            }
            return true;  
        }
        else{
            return true;
        }
    }
}