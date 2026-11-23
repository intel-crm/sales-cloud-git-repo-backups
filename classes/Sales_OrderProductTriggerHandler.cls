/*********************************************************************************************************************
Class Name    : Sales_OrderProductTriggerHandler
Version       : 1.0
Created Date  : Dec 2020
Function      :  
Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------
* Srishty Sharma           30-Dec-2020              Order Product Trigger Utility 
* *********************************************************************************************************************/
public without sharing class Sales_OrderProductTriggerHandler extends TriggerHandler {
    private static final String ORDER_TYPE_NONCOMMERCIAL='Non Commercial Order';
    private static final String ORDER_SUBTYPE_CORPORATEORDER='Corporate Order';
    private static final String ORDER_STATUS_SHIPPED='SAP Order Shipped';
    public override void afterInsert() {
        if(isActive('PSG_OrderProduct_After_Trigger')) { 
            Set<Id> orderIdSet = new Set<Id>();
            Set<Id> productIdSet = new Set<Id>();
            for(OrderItem ordProduct: (List<OrderItem>)Trigger.new){
                productIdSet.add(ordProduct.Product2Id);
                orderIdSet.add(ordProduct.OrderId);
            }
            Map<Id, Order> ordMap = new Map<Id, Order>([Select Id,Status, AccountId,Sales_End_Customer_Account__c,Sales_Sold_To_Account__c,SBQQ__Quote__r.SBQQ__Opportunity2__c,SBQQ__Quote__r.SBQQ__EndDate__c, SBQQ__Quote__c,SBQQ__Quote__r.Sales_Renewed_from_Contract_Id__c, SBQQ__Quote__r.SBQQ__Type__c,SBQQ__Quote__r.SBQQ__StartDate__c,SBQQ__Quote__r.SBQQ__MasterContract__c,Sales_Req_Ship_Date_Dt__c,EffectiveDate, Type, Sales_Order_Sub_Type__c,Sales_Order_Reason__c,SBQQ__Quote__r.SBQQ__SubscriptionTerm__c from Order where Id IN:orderIdSet]);
            Sales_OrderProductTriggerUtility.renewalProductValidation((List<OrderItem>)Trigger.new); 
            Sales_OrderProductTriggerUtility.createSalesLicense((List<OrderItem>)Trigger.new, ordMap,productIdSet,false,false,null,null);
        }       
    }
    public override void beforeInsert(){
        if(isActive('PSG_Order_Product_Trigger_Execution')) {
            Set<id> orderIds = new Set<id>();
            for(OrderItem ordItm: (List<OrderItem>) Trigger.new){
                orderIds.add(ordItm.OrderId);    
            }
            Map<Id, Order> ordMap = new Map<Id, Order>([Select Id,SBQQ__Quote__c, Status,Sales_Sold_To_Account__c,Sales_Order_Sub_Type__c,Sales_Sold_To_Account__r.Core_Direct_Distributor_Channel_Nm__c,type from Order where Id In:orderIds]);
            Sales_SequenceGenerator.sequenceGenerator((List<OrderItem>)Trigger.new , 'OrderItem');
            Sales_OrderProductTriggerUtility.populateSAPLACRule((List<OrderItem>)Trigger.new);
            Sales_OrderProductTriggerUtility.restrictOrderProductCreation((List<OrderItem>) Trigger.new, ordMap);
            Sales_OrderProductTriggerUtility.populateListPriceBasedonQty((List<OrderItem>) Trigger.new, ordMap);
            Sales_OrderProductTriggerUtility.checkOrderProductsFromQuoteLines((List<OrderItem>)Trigger.new);
           Sales_OrderProductTriggerUtility.beforeInsertOrderProductUtility((List<OrderItem>) Trigger.new, ordMap);
        }
         if(isActive('Core_PSG_LicenseVendor_OrderProduct')){
            Sales_OrderProductTriggerUtility.checkCompetitorAccountVsProduct((List<OrderItem>) Trigger.new);
        }
    }
    public override void beforeUpdate(){
         Set<Id> orderIdSet= new Set<Id>();
         Set<id> orderIds = new Set<id>();
        if(isActive('PSG_Order_Product_Trigger_Execution') && Sales_UpdateProductDetails.BypassTriggerForProductUpdate==false) { 
           for(OrderItem ordItm: (List<OrderItem>) Trigger.new){
                orderIds.add(ordItm.OrderId);    
            }
            Map<Id, Order> ordMap = new Map<Id, Order>([Select Id,Sales_status__c,SBQQ__Quote__c, Status,Sales_Sold_To_Account__c,Sales_Order_Sub_Type__c,Sales_Sold_To_Account__r.Core_Direct_Distributor_Channel_Nm__c,type from Order where Id In:orderIds]);
		   Sales_OrderProductTriggerUtility.populateSAPLACRule((List<OrderItem>)Trigger.new);
            for(Order ordernew:ordMap.values()){
               if(ordernew.Sales_status__c != ORDER_STATUS_SHIPPED){
			     orderIdSet.add(ordernew.Id);
               }
            }
			if(orderIdSet.size()>0){ 
			     Sales_OrderProductTriggerUtility.checkOrderProductsFromQuoteLines((List<OrderItem>)Trigger.new);
                 Sales_OrderProductTriggerUtility.beforeUpdateOrderProductUtility((List<OrderItem>) Trigger.new,(Map<Id, OrderItem>)Trigger.oldMap, ordMap);
                 Sales_OrderProductTriggerUtility.populateListPriceBasedonQty((List<OrderItem>)Trigger.new, ordMap);
			}
        }
         if(isActive('Core_PSG_LicenseVendor_OrderProduct')){
            if(orderIdSet.size()>0){
            Sales_OrderProductTriggerUtility.checkCompetitorAccountVsProduct((List<OrderItem>) Trigger.new);
               }
         }
    }
    public override void beforeDelete(){
        if(isActive('PSG_Order_Product_Trigger_Execution')) {
            Sales_OrderProductTriggerUtility.validateOrderProductForDeletion((Map<Id, OrderItem>) trigger.oldMap);
            Sales_OrderProductTriggerUtility.deleteLicensesOnOrderProductDeletion((Map<Id, OrderItem>) trigger.oldMap);
        }
    }     
    public override void afterUpdate(){    
      if(isActive('PSG_OrderProduct_After_Trigger') && Sales_UpdateProductDetails.BypassTriggerForProductUpdate==false) { 
           Sales_OrderProductTriggerUtility.renewalProductValidation((List<OrderItem>)Trigger.new);
         Map<Id, OrderItem> oldOrdProdMap = (Map<Id, OrderItem>)Trigger.oldMap; 
          Set<Id> orderIdSet = new Set<Id>();
          Map<Id, OrderItem> ordProdMap = new Map<Id,OrderItem>();
          Set<id> orderIdsForLicUpdate = new Set<Id>();           
          for(OrderItem ordItm: (List<OrderItem>)Trigger.New){
              if(ordItm.Quantity != oldOrdProdMap.get(ordItm.Id).Quantity){                  
                  ordProdMap.put(ordItm.id, ordItm);
                  orderIdSet.add(ordItm.orderid);
              }  
              if(ordItm.SBQQ__Contract__c != null && oldOrdProdMap.get(ordItm.Id).SBQQ__Contract__c != ordItm.SBQQ__Contract__c){
                orderIdsForLicUpdate.add(ordItm.OrderId);       
              }
          }
          Map<Id, boolean> ordWithAccountUpdateMap = new Map<Id, boolean>();
          if(!orderIdsForLicUpdate.isEmpty()){
            Map<Id, Order> ordMap = new Map<Id, Order>([Select id,Status, Sales_Order_Reason__c,  AccountId, Type, Sales_Order_Sub_Type__c, ActivatedDate,Sales_Ship_Date_Dt__c from Order where Id IN: orderIdsForLicUpdate and Status = 'Activated' and Type = :ORDER_TYPE_NONCOMMERCIAL and Sales_Order_Sub_Type__c = :ORDER_SUBTYPE_CORPORATEORDER]);       
              if(!ordMap.IsEmpty()){
                  Sales_OrderTriggerUtility.updateLicenseRecords(ordMap, ordWithAccountUpdateMap); 
              }
          }
          Map<Id, Order> ordMap = new Map<Id, Order>([Select Id,Sales_status__c,Status,Sales_Is_Verified__c,Sales_End_Customer_Account__c,Sales_Sold_To_Account__c,SBQQ__Quote__r.SBQQ__Opportunity2__c, SBQQ__Quote__c, SBQQ__Quote__r.SBQQ__Type__c,SBQQ__Quote__r.SBQQ__StartDate__c,SBQQ__Quote__r.SBQQ__MasterContract__c,Sales_Req_Ship_Date_Dt__c,EffectiveDate, Type, Sales_Order_Sub_Type__c,Sales_Order_Reason__c, AccountId from Order where Id IN:orderIdSet]);
          if(!ordProdMap.isEmpty()){                    
            Sales_OrderProductTriggerUtility.updateLicenseRecordsOnUpdatingQty(ordProdMap,oldOrdProdMap,ordMap);
          }
		  Set<Id> orderIdSetNew= new Set<Id>();
           for(Order ordernew:ordMap.values()){
               if(ordernew.Sales_status__c != ORDER_STATUS_SHIPPED){
			   orderIdSetNew.add(ordernew.Id);
              }
           }
		   if(orderIdSetNew.size()>0)
			  {
			   Sales_OrderProductTriggerUtility.updatePriceChangedOnOrder((List<OrderItem>)Trigger.New,(Map<Id, OrderItem>)Trigger.oldMap, ordMap.values());  
              }
         }
    }
    }