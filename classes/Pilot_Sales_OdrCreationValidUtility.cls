/*********************************************************************************************************************
Class Name    : Pilot_Sales_OrderCreationValidationUtility
Version       : 1.0
Created Date  : Sep 2021
Function      :  

Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------
* Subhanku Ghosh           15/09/2021             Pilot Project for testing framework.  
* *********************************************************************************************************************/
public class Pilot_Sales_OdrCreationValidUtility{
    private static final String ORDER_SUBTYPE_ARMORDER='ARM standalone license order';
    private static final String ORDER_SUBTYPE_CORPORATEORDER='Corporate Order';
    private static final String ORDER_SUBTYPE_DEVKITORDER='Dev Kit/PAC ES with license (Quartus and/or ARM) order';
    private static final String ORDER_SUBTYPE_STANDALONEORDER='Standalone license order';
    private static final String ORDER_SUBTYPE_RENEWALORDER='Renewal order';
    
    //checking SubOrder Type when OrderType is Updated
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
            for(OrderItem existingOrderItem : SEL_OrderItem.newInstance().selectByOrderIds(orderIds)){
                                                   
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
        System.debug('## Sub Order type Queries Used'+Limits.getQueries());
        System.debug('## Sub Order type Total Allowed Queries'+Limits.getLimitQueries());
        return mapOfOrderSubType;
    }
    
    
    public static Map<Id, Boolean> isRenewalProduct(List<Order> orderList){
        Map<Id, Boolean> renewCheck = new Map<Id, Boolean>();
        Boolean isRenewal=false;
        Set<id> orderIds = new Set<id>();
        for(Order ord : orderList){
            orderIds.add(ord.Id);
        }
        if(orderList.size()>0){//checking the orderList size 
            //List <OrderItem> ordList= [Select Id, OrderId,Product2.Core_Product_Ext_Attribute_Id__r.Core_Prod_Tool_Type_Nm__c from OrderItem where OrderId IN:orderIds];//querying OrderProducts
            for(OrderItem oi : SEL_OrderItem.newInstance().selectByOrderIds(orderIds)){
                                    if(oi.Product2.Core_Product_Ext_Attribute_Id__r.Core_Prod_Tool_Type_Nm__c=='RENEWAL'){
                                        isRenewal=true;//if any of the orderItem is Renewal then set to true
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
        Set<Id> ordrIdsProcessed = new Set<Id>();
        List<OrderItem> tempOrderItemList;
        List<OrderItem> tempOrderItemList1;
        for(OrderItem newOrderItem:orderItemList){
            productIdSet.add(newOrderItem.Product2Id);//set of Product from order which is going to be added in order product.
            orderIdSet.add(newOrderItem.OrderId);//Set of Order Product which is coming from trigger New list.
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
    
    //Checking New order products List from Quote
    public static void checkOrderProductsInsertion(List<OrderItem> orderItemList, Map<Id,Product2> productMap, Map<Id, List<OrderItem>> newOrderItemMap, Id OrderId){
        String subStatus;
        Integer devkitcount=0;
        Integer ipcount=0;
        Integer armcount=0;
        Integer swcount=0;
        Integer corporate=0;
        Integer standalone=0;
        Integer svProduct=0;
        List<Id> prodIds =  new List<Id>();
        Product2 prod;               
        
        String errMsg = '';
        for(OrderItem oi : orderItemList){
            prod = productMap.get(oi.Product2Id);
            if(prod!= null && prod.Core_Item_Class_Nm__c == 'SV'){
                if(prod.Core_Product_Ext_Attribute_Id__r.Core_Prod_Tool_Type_Nm__c=='SOFTWARE'){
                    swcount=swcount+1;//for Software
                }else if(prod.Core_Product_Ext_Attribute_Id__r.Core_Prod_Tool_Type_Nm__c=='IP'){
                    ipcount=ipcount+1;//for IP
                }else if(prod.Core_Item_Sub_Component_Category_Nm__c=='A'){
                    armcount=armcount+1;//for ARM
                }else{
                    svProduct = svProduct+1;
                }
            }
            else if(prod != null && prod.Core_Item_Class_Nm__c == 'BD'){ 
                devkitcount=devkitcount+1;//for DEVKIT
            }else if(prod != null && prod.Core_Product_Ext_Attribute_Id__r.Core_Prod_Tool_Type_Nm__c=='CORPORATE'){
                corporate=corporate+1;//for CORPORATE
            }else{
                standalone=standalone+1;//for standalone
            }
        }  
       PRM_Execution_Controls__c skipValidation= PRM_Execution_Controls__c.getInstance(UserInfo.getUserId());
        if(devkitcount > 1 || (devkitcount==1 && (standalone >0 || armcount >0 || ipcount >0 || swcount>0 || corporate>0 || svProduct>0))){//Devkit with Devkit/Others not allowed
                if(!skipValidation.Skip_ValidationRule_Order_Status__c){

            errMsg = System.Label.Sales_devkitErr_Msg;//errMsg = 'Can\'t Combine other product With Dev Kit Product';
                                                                       }
        }
        else if(armcount >0 && (ipcount >0 || swcount>0 || svProduct>0 || standalone >0 || corporate>0)){//ARM with IP and Software not allowed
            errMsg = System.Label.Sales_ARMErr_Msg; //  errMsg = 'Can\'t add intel product, for ARM License Order Type';
        }                       
        
        if(String.IsNotBlank(errMsg)){
            List<OrderItem> ordItmsLst = newOrderItemMap.get(OrderId);
            for(OrderItem oi: ordItmsLst){               
                oi.addError(errMsg);
            }
        }
    }
}