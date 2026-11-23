/*********************************************************************************************************************
Class Name    : Sales_AutomatedLicGenerationProcess
Version       : 1.0
Created Date  : Jul 2021
Function      :  
Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------
* Srishty Sharma           Jul-2021             US972949:Generate license file for corporate license renewals .This will called from Order Trigger handler 
*                                                   This will call LicenseGenIntegrationUtility for callout to License Generation system whenever renewal order is shipped.
* ************************************************************************************************************************************************/
@isTest
public without sharing class Sales_AutomatedLicGenerationProcess {
    /*private static final String STATUS_ORDER_CREATED_SUCCESSFULLY = 'Order created successfully'; 
    public static void getHostIdFromShippedOrder(List<Order> shippedOrderList,Set<Id> quoteIdSet){
        Set<Id> orderRenewalSet =new Set<Id>();
        List<OrderItem> orderItemFrmContractList =new List<OrderItem>();
        Set<Id> hostIdsToSend = new Set<Id>();
        Map<Id,SBQQ__Quote__c> renewalQuoteMap=new Map<Id,SBQQ__Quote__c>([Select Id from SBQQ__Quote__c where SBQQ__Type__c='Renewal' AND Id IN:quoteIdSet]);
        for(Order order:shippedOrderList){
            if(renewalQuoteMap.containsKey(order.SBQQ__Quote__c )){
                orderRenewalSet.add(order.Id);
            }
        }
        if(orderRenewalSet.isEmpty()){
            return;
        }
        for(Sales_License__c licOnOrderProduct : [Select Id,Sales_License_Host_Node_Id__c from Sales_License__c 
                                                  where Sales_License_Order__c IN :orderRenewalSet 
                                                  AND Sales_License_Status__c='Licensed' 
                                                  AND Sales_License_Host_Node_Id__c!=null]){
                                                      hostIdsToSend.add(licOnOrderProduct.Sales_License_Host_Node_Id__c);
                                                  }
        for(Contract cont:[Select Id,(Select Id,OrderId,Order.Sales_status__c,SBQQ__Contract__c from SBQQ__OrderProducts__r) 
                           from Contract where Id IN (Select SBQQ__Contract__c from OrderItem where OrderId IN:orderRenewalSet)]){
                               if(cont.SBQQ__OrderProducts__r.size()>0){
                                   orderItemFrmContractList.addAll(cont.SBQQ__OrderProducts__r);
                               }
                           }
        for(Sales_License_Order_Product__c licOnOrderProduct : [Select Id,Sales_License__c,Sales_Order_Product__c,Sales_Order_Product__r.OrderId,
                                                                Sales_Order_Product__r.Order.Sales_status__c,Sales_License__r.Sales_License_Host_Node_Id__c,
                                                                Sales_License__r.Sales_License_Status__c, Sales_Order_Product__r.Order.Type From Sales_License_Order_Product__c 
                                                                where Sales_Order_Product__c  IN: orderItemFrmContractList  
                                                                AND Sales_License__r.Sales_License_Status__c='Licensed' AND Sales_License__r.Sales_License_Host_Node_Id__c!=null]){
                                                                    if(!orderRenewalSet.contains(licOnOrderProduct.Sales_Order_Product__r.OrderId)){
                                                                        if((licOnOrderProduct.Sales_Order_Product__r.Order.Type=='Non Commercial Order' && licOnOrderProduct.Sales_Order_Product__r.Order.Sales_status__c!=STATUS_ORDER_CREATED_SUCCESSFULLY) 
                                                                            ||(licOnOrderProduct.Sales_Order_Product__r.Order.Type!='Non Commercial Order' && licOnOrderProduct.Sales_Order_Product__r.Order.Sales_status__c!='SAP Order Shipped')){
                                                                            hostIdsToSend.remove(licOnOrderProduct.Sales_License__r.Sales_License_Host_Node_Id__c);
                                                                        }
                                                                    }
                                                                }
        if(!hostIdsToSend.isEmpty()){
            //2 min delay added in license file generation for maintenance expiration fix - US- TWC3133-5745
            System.enqueueJob(new Sales_BulkHostProcessLicGenQueueable(hostIdsToSend,'isOrderTrigger'),Integer.valueOf(System.Label.Sales_Lic_gen_delay_in_min));        
        }
    }*/
}