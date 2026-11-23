/*********************************************************************************************************************
Class Name    : Sales_SequenceGenerator
Version       : 1.0
Created Date  : Apr 2021  
Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------
* Shivam Vishwakarma        05-Apr-2021             US951064: Sequence No (SAP Line#) Generator for Order Product & License
* *********************************************************************************************************************/
public with sharing class Sales_SequenceGenerator{
    public static void sequenceGenerator (List<sObject> objList ,String ObjectAPI){      
        try{
            if(ObjectAPI == 'OrderItem'){
                orderItemSequenceGeneration((List<OrderItem>)objList);
            }
            else if(ObjectAPI == 'Sales_License__c'){
                licenseSequenceGeneration((List<Sales_License__c>)objList);
            }
        }catch(Exception e){
            throw new AuraHandledException( e.getMessage() );
        }
    }
    public static void orderItemSequenceGeneration(List<OrderItem> orderItemsList){
        Set<Id> orderIDS = new Set<Id>();
        Map<Id,Integer> order_OPMaxSequenceNoUsedMap = new Map<Id,Integer>();	
        for(OrderItem o : orderItemsList){
            orderIDS.add(o.OrderId);
        }
        for(AggregateResult queryResult: [SELECT OrderId, MAX(Sales_SAPLine_Nbr__c) OPMAXLINENO FROM OrderItem where OrderId IN: orderIDS GROUP BY OrderId ] ){
            order_OPMaxSequenceNoUsedMap.put( (Id)queryResult.get('OrderId'), Integer.valueOf(queryResult.get('OPMAXLINENO')) );
        }
        for(OrderItem oItem : orderItemsList ){
            if(order_OPMaxSequenceNoUsedMap.get(oItem.OrderId) != null )
                oItem.Sales_SAPLine_Nbr__c = order_OPMaxSequenceNoUsedMap.get(oItem.OrderId) + 1;
            else
                oItem.Sales_SAPLine_Nbr__c = 1;
            order_OPMaxSequenceNoUsedMap.put(oItem.OrderId,(Integer)oItem.Sales_SAPLine_Nbr__c);
        }   
    }
    public static void licenseSequenceGeneration(List<Sales_License__c> licensesList){
        Set<Id> orderProductIds = new Set<Id>();
        Map<String,Integer> productCountMap = new Map<String,Integer>();
        for(Sales_License__c lic : licensesList){
            if(lic.Sales_License_Order_Product__c != null){
                orderProductIds.add(lic.Sales_License_Order_Product__c);
            }
        }
        for(Sales_License__c existingLicense : [Select Id,Sales_License_Order_Product__c,Sales_License_Product__c 
                                                from Sales_License__c where Sales_License_Order_Product__c IN:orderProductIds 
                                                AND Sales_Parent_License__c=null]){
                                                    String key = existingLicense.Sales_License_Order_Product__c+'-'
                                                        +existingLicense.Sales_License_Product__c;
                                                    Integer count=1;
                                                    if(productCountMap.containsKey(key)){
                                                        count = productCountMap.get(key);
                                                        productCountMap.put(key,count+1);
                                                    }
                                                    else{
                                                        productCountMap.put(key,count);
                                                    }
                                                }
        for(Sales_License__c lic : licensesList){
            if(lic.Sales_Parent_License__c==null){
                String key = lic.Sales_License_Order_Product__c+'-'+lic.Sales_License_Product__c;
                if(productCountMap.containsKey(key)){
                    Integer count = productCountMap.get(key);
                    lic.Sales_License_SAPLine_Nbr__c=count+1;
                    productCountMap.put(key,count+1);
                }
                else{
                    lic.Sales_License_SAPLine_Nbr__c=1;
                    productCountMap.put(key,1);
                }
            }
        }
    }
    public static void licSeqGenerationForDelete(List<Sales_License__c> deletedLicensesList){
        Set<Id> orderProductIds = new Set<Id>();
        Set<Id> orderId =new Set<Id>();
        Map<String,Integer> productCountMap = new Map<String,Integer>();
        List<Sales_License__c> updateLicenseList=new List<Sales_License__c>();
        try{
            for(Sales_License__c lic : deletedLicensesList){
                if(lic.Sales_Parent_License__c==null){
                    orderProductIds.add(lic.Sales_License_Order_Product__c);
                    orderId.add(lic.Sales_License_Order__c);
                }
            }
            List<Order> draftOrderList=new List<Order>([Select Id from Order where Id IN:orderId AND Status='Draft']);
            for(Sales_License__c existingLicense : [Select Id,Sales_License_Order_Product__c,Sales_License_Product__c,Sales_License_SAPLine_Nbr__c
                                                    from Sales_License__c where Sales_License_Order_Product__c IN:orderProductIds AND Sales_License_Order__c IN:draftOrderList AND Id NOT IN:deletedLicensesList]){
                                                        String key = existingLicense.Sales_License_Order_Product__c+'-'
                                                            +existingLicense.Sales_License_Product__c;
                                                        Integer count=1;
                                                        if(productCountMap.containsKey(key)){
                                                            count = productCountMap.get(key);
                                                            productCountMap.put(key,count+1);
                                                        }
                                                        else{
                                                            productCountMap.put(key,count);
                                                        }
                                                        existingLicense.Sales_License_SAPLine_Nbr__c=productCountMap.get(key);
                                                        updateLicenseList.add(existingLicense);
                                                    }
            if(updateLicenseList.size()>0){
                Database.update(updateLicenseList,true);
            }
        }
        catch(Exception e){
            throw new AuraHandledException( e.getMessage() );
        }
    }
}