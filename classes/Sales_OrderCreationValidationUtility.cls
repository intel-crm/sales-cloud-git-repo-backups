/*********************************************************************************************************************
Class Name    : Sales_OrderCreationValidationUtility
Version       : 1.0
Created Date  : Feb 2021
Function      :  
Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------
* Jasmine Narula           10-Feb-2021             Sales_OrderCreationValidationUtility  
* *********************************************************************************************************************/
@isTest
public without sharing class Sales_OrderCreationValidationUtility{
    /*private static final String ORDER_SUBTYPE_ARMORDER='ARM standalone license order';
    private static final String ORDER_SUBTYPE_CORPORATEORDER='Corporate Order';
    private static final String ORDER_SUBTYPE_DEVKITORDER='Dev Kit/PAC ES with license (Quartus and/or ARM) order';
    private static final String ORDER_SUBTYPE_STANDALONEORDER='Standalone license order';
    private static final String ORDER_SUBTYPE_RENEWALORDER='Renewal order';
    public static Map<Id, String> checksubOrderType(List<Order> orderList){
        String isDEvKit;
        String isARM;
        String isCorp;
        String isStandalone;
        List<String> typeList = new List<String>();
        Map<Id, List<String>> mapOfSubOrderValues = new Map<Id, List<String>>();
        Set<id> orderIds = new Set<id>();
        Map<Id, String> mapofOrderIdToolType = new Map<Id, String>();
        for(Order ord : orderList){
            orderIds.add(ord.Id);
        }
        if(orderIds.size()>0){    
            for(OrderItem existingOrderItem : [Select Id,Product2Id,Product2.Core_Item_Class_Nm__c,OrderId,Product2.Core_Item_Sub_Component_Category_Nm__c,Product2.Core_Product_Ext_Attribute_Id__r.Core_Prod_Tool_Type_Nm__c,Order.Sales_IsRenewal__c from OrderItem where 
                                               OrderId IN:orderIds and id!=null]){
                                                   if(existingOrderItem.Product2.Core_Item_Class_Nm__c=='BD'){
                                                       typeList.add('isDEvKit');
                                                   }
                                                   else if(existingOrderItem.Product2.Core_Product_Ext_Attribute_Id__r.Core_Prod_Tool_Type_Nm__c=='CORPORATE'){
                                                       typeList.add('isCorp');
                                                   }
                                                   else if(existingOrderItem.Product2.Core_Item_Class_Nm__c=='SV' && existingOrderItem.Product2.Core_Item_Sub_Component_Category_Nm__c=='A'){
                                                       typeList.add('isARM');
                                                   }
                                                   else{typeList.add('isStandalone');
                                                       }
                                                   mapOfSubOrderValues.put(existingOrderItem.OrderId, typeList);    
                                               }
        }
        mapofOrderIdToolType = validateSubType(mapOfSubOrderValues);                                                   
        return mapofOrderIdToolType;
    }
    public static Map<Id, String> validateSubType(Map<Id, List<String>> mapOfSubOrderValues){
        String subOrderType;
        String isDEvKit;
        String isARM;
        Boolean isCorporateOrder=false;
        Boolean isStandaloneOrder = false;
        Boolean isARMOrder = false;
        Boolean isDevkitOrder = false;
        String isCorp;
        String isStandalone;
        Map<Id, String> mapOfOrderSubType = new Map<Id, String>();
        for(Id ordId : mapOfSubOrderValues.keyset()){
            for(String typeList : mapOfSubOrderValues.get(ordId)){
                if(typeList.contains('isDEvKit')){
                    subOrderType = ORDER_SUBTYPE_DEVKITORDER;
                    isDevkitOrder = true;
                }else if(typeList.contains('isARM')){
                    if(typeList.contains('isCorp')){
                        subOrderType = ORDER_SUBTYPE_CORPORATEORDER;
                        isCorporateOrder=true;
                    }
                    else{
                        subOrderType = ORDER_SUBTYPE_ARMORDER;
                        isARMOrder = true;
                    }
                }else if(typeList.contains('isCorp')){
                    subOrderType = ORDER_SUBTYPE_CORPORATEORDER;
                    isCorporateOrder=true;
                    break;
                }
                else if(!typeList.contains('isARM') && !typeList.contains('isCorp') && !typeList.contains('isDEvKit')){                       
                    subOrderType = ORDER_SUBTYPE_STANDALONEORDER;
                    isStandaloneOrder= true;
                }
            }
            if(isCorporateOrder){
                if(isARMOrder){
                    subOrderType = ORDER_SUBTYPE_CORPORATEORDER;
                }
            }
            else if(isARMOrder==true && isCorporateOrder==false && isDevkitOrder==false){
                if(isStandaloneOrder){
                    subOrderType = ORDER_SUBTYPE_ARMORDER;    
                }
            }else if(isStandaloneOrder){
                if(isCorporateOrder){
                    subOrderType = ORDER_SUBTYPE_CORPORATEORDER;
                }else if(isARMOrder){
                    subOrderType = ORDER_SUBTYPE_ARMORDER; 
                }else{
                    subOrderType = ORDER_SUBTYPE_STANDALONEORDER;        
                }
            }
            mapOfOrderSubType.put(ordId, subOrderType);
        }
        return mapOfOrderSubType;
    }
    public static Map<Id, Boolean> isRenewalProduct(List<Order> orderList){
        Map<Id, Boolean> renewCheck = new Map<Id, Boolean>();
        Boolean isRenewal=false;
        Set<id> orderIds = new Set<id>();
        for(Order ord : orderList){
            orderIds.add(ord.Id);
        }
        if(orderList.size()>0){
            for(OrderItem oi : [Select Id,Sales_Contact__c, OrderId,Product2.Core_Product_Ext_Attribute_Id__r.Core_Prod_Tool_Type_Nm__c
                                from OrderItem where OrderId IN:orderIds]){
                                    if(oi.Product2.Core_Product_Ext_Attribute_Id__r.Core_Prod_Tool_Type_Nm__c=='RENEWAL'){
                                        isRenewal=true;
                                    }
                                    if(!renewCheck.containsKey(oi.OrderId)){
                                        renewCheck.put(oi.OrderId, isRenewal);
                                    }   
                                }
        }
        return renewCheck;
    }
    public static void validateOrderProducts(List<OrderItem> orderItemList){        
        Set<Id> productIdSet = new Set<Id>();
        Set<Id> orderIdSet = new Set<Id>();     
        Map<Id, List<OrderItem>> allOrderItemMap = new Map<Id, List<OrderItem>>();
        Map<Id, List<OrderItem>> newOrderItemMap = new Map<Id, List<OrderItem>>();		
        //Set<Id> ordrIdsProcessed = new Set<Id>(); --Unused
        List<OrderItem> tempOrderItemList;
        List<OrderItem> tempOrderItemList1;
        for(OrderItem newOrderItem:orderItemList){
            productIdSet.add(newOrderItem.Product2Id);
            orderIdSet.add(newOrderItem.OrderId);
            if(allOrderItemMap.containsKey(newOrderItem.OrderId)){                
                allOrderItemMap.get(newOrderItem.OrderId).add(newOrderItem);                   
            }else{
                tempOrderItemList = new List<OrderItem>();
                tempOrderItemList.add(newOrderItem);
                allOrderItemMap.put(newOrderItem.OrderId,tempOrderItemList);                      
            }
            if(newOrderItemMap.containsKey(newOrderItem.OrderId)){                
                newOrderItemMap.get(newOrderItem.OrderId).add(newOrderItem);                   
            }else{
                tempOrderItemList1 = new List<OrderItem>();
                tempOrderItemList1.add(newOrderItem);
                newOrderItemMap.put(newOrderItem.OrderId,tempOrderItemList1);                      
            }
        }        
        for(OrderItem existingOrderItem : [Select Id,Product2Id,Product2.Core_Item_Class_Nm__c,OrderId
                                           from OrderItem where OrderId IN:orderIdSet and Id NOT IN:orderItemList]){                                                
                                               productIdSet.add(existingOrderItem.Product2Id);
                                               if(allOrderItemMap.containsKey(existingOrderItem.OrderId)){
                                                   allOrderItemMap.get(existingOrderItem.OrderId).add(existingOrderItem); 
                                               }else{
                                                   tempOrderItemList = new List<OrderItem>();
                                                   tempOrderItemList.add(existingOrderItem);
                                                   allOrderItemMap.put(existingOrderItem.OrderId,tempOrderItemList);
                                               }		 
                                           }
        Map<Id,Product2> productMap = new Map<Id,Product2>([Select Id,Core_Item_Class_Nm__c,Core_Item_Sub_Component_Category_Nm__c,Core_Product_Ext_Attribute_Id__r.Core_Prod_Tool_Type_Nm__c from Product2 where Id IN:productIdSet]);  
        for(Id orderId: allOrderItemMap.keyset()){
            checkOrderProductsInsertion(allOrderItemMap.get(orderId), productMap, newOrderItemMap, orderId);
        }
    }
    public static void checkOrderProductsInsertion(List<OrderItem> orderItemList, Map<Id,Product2> productMap, Map<Id, List<OrderItem>> newOrderItemMap, Id OrderId){
        String subStatus;
        Integer devkitcount=0;
        Integer ipcount=0;
        Integer armcount=0;
        Integer swcount=0;
        Integer corporate=0;
        Integer standalone=0;
        Integer svProduct=0;
        //List<Id> prodIds =  new List<Id>();--Unused
        Product2 prod;               
        String errMsg = '';
        for(OrderItem oi : orderItemList){
            prod = productMap.get(oi.Product2Id);
            if(prod!= null && prod.Core_Item_Class_Nm__c == 'SV'){
                if(prod.Core_Product_Ext_Attribute_Id__r.Core_Prod_Tool_Type_Nm__c=='SOFTWARE'){
                    swcount=swcount+1;
                }else if(prod.Core_Product_Ext_Attribute_Id__r.Core_Prod_Tool_Type_Nm__c=='IP'){
                    ipcount=ipcount+1;
                }else if(prod.Core_Item_Sub_Component_Category_Nm__c=='A'){
                    armcount=armcount+1;
                }else{
                    svProduct = svProduct+1;
                }
            }
            else if(prod != null && prod.Core_Item_Class_Nm__c == 'BD'){ 
                devkitcount=devkitcount+1;
            }else if(prod != null && prod.Core_Product_Ext_Attribute_Id__r.Core_Prod_Tool_Type_Nm__c=='CORPORATE'){
                corporate=corporate+1;
            }else{
                standalone=standalone+1;
            }
        }  
        if(devkitcount > 1 || (devkitcount==1 && (standalone >0 || armcount >0 || ipcount >0 || swcount>0 || corporate>0 || svProduct>0))){
            errMsg = System.Label.Sales_devkitErr_Msg;
        }
        else if(armcount >0 && (ipcount >0 || swcount>0 || svProduct>0 || standalone >0 || corporate>0)){
            errMsg = System.Label.Sales_ARMErr_Msg; 
        }                       
        if(String.IsNotBlank(errMsg)){
            List<OrderItem> ordItmsLst = newOrderItemMap.get(OrderId);
            for(OrderItem oi: ordItmsLst){               
                oi.addError(errMsg);
            }
        }
    }*/
}