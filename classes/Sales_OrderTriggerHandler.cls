/********************************************************************************************************************
Class Name    : Sales_OrderTriggerHandler
Version       : 1.0
Created Date  : Jan 2021
Function      :  

Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------
* Jasmine Narula           20-Jan-2021             Order Trigger Utility  
* *********************************************************************************************************************/
@isTest
public class Sales_OrderTriggerHandler {
    /*extends TriggerHandler{
    public static boolean isRun = false;
    boolean isafterupdaterun = false;
    private static final String ORDER_STATUS_ACTIVATED='Activated';
    private static final String ORDER_STATUS_SHIPPED='SAP Order Shipped';
    private static final String ORDER_TYPE_PARTNER_LICENSE_ORDER = 'Partner license order';
    private static final String STATUS_ORDER_CREATED_SUCCESSFULLY = 'Order created successfully';  
    private static final String ORDER_CANCELLED = 'Order Cancelled';
    private static final String ORDER_STATUS_CANCELLED_BY_SAP= 'Order Cancelled by SAP';
    
    public override void beforeInsert() {
        if(isActive('PSG_Order_Before_Trigger')){
            Sales_OrderTriggerUtility.createOrdersfromQuote((List<Order>)Trigger.new,null);  
            Sales_OrderTriggerUtility.updatePriceBook((List<Order>)Trigger.new,null);
            // added as part of POC
            // Sales_OrderTriggerUtility.checkStage(null, (List<Order>) Trigger.new);
            //Sales_OrderTriggerUtility.AccountshipTosoldTo((List<Order>)Trigger.new);
        }
    }
    
    public override void afterInsert(){
        Sales_OrderTriggerUtility.checkAccountCompetitorVendor((List<Order>)Trigger.new, null);
    }
    
    public override void beforeUpdate(){
        if(isActive('Sales_Order_Before_Update_Trigger')){        
            for(Order ord: (List<Order>)Trigger.new){
                if(ord.Status=='Draft'){
                Sales_OrderTriggerUtility.checkOrderTypeandSubType((List<Order>)Trigger.new);
                Sales_OrderTriggerUtility.updateAddressAndAccount((List<Order>)Trigger.new,(Map<Id,Order>)Trigger.oldMap);
            }
        }
            Sales_OrderTriggerUtility.validateOrder((Map<Id,Order>)Trigger.newMap, (Map<Id,Order>)Trigger.oldMap); 
			 Set<Id> orderIdSet= new Set<Id>();
            //Sales_OrderTriggerUtility.checkReadOnlyLayoutRecordType((List<Order>)Trigger.new,(Map<Id,Order>)Trigger.oldMap);    //US925238: This will call method to set layout to Readonly if Order Stage is Activated with Status as Order Activated
           for(Order ordernew: (List<Order>)Trigger.new){
               if(ordernew.Sales_status__c != ORDER_STATUS_SHIPPED){
				   orderIdSet.add(ordernew.Id);
			   }
			  
           }
		    if(orderIdSet.size()>0){
                Sales_OrderTriggerUtility.updatePriceBook((List<Order>)Trigger.new, (Map<Id,Order>)Trigger.oldMap);
               }
            //Sales_OrderTriggerUtility.checkContractsisCreated((List<Order>)Trigger.new);
            //Sales_OrderTriggerUtility.updatePriceForNoncommercial((List<Order>)Trigger.new);
            //Sales_OrderTriggerUtility.checkStage((Map<id, Order>) Trigger.oldMap, (List<Order>) Trigger.new); 
            //Sales_OrderTriggerUtility.AccountshipTosoldTo((List<Order>)Trigger.new,Set<Id>);
        }        
    }
    
    public override void afterUpdate(){
        if(isActive('Sales_Order_After_Update_Trigger')){
            Map<Id, Order> ordIdsForLicenseUpdate = new Map<Id, Order>();
            Map<Id, Order> oldOrderMap = (Map<Id, Order>)Trigger.oldMap;            
            Map<Id, boolean> ordWithAccountUpdateMap = new Map<Id, boolean>();
            List<Order> orderListForAutomateRenewals = new List<Order>();
            Set<Id> quoteIds = new Set<Id>();
            Set<Id> quoteIdsForAutomatedLicGenProc = new Set<Id>();
            Set<Id> contractIds = new Set<Id>();
            Set<Id> orderIdSet= new Set<Id>();
            String orderStatusMsg ;
            List<Order> ordersListForEmailNotification = new List<Order>();
            List<Order> orderListForAutomatedLicGenProc = new List<Order>();
            for(Order ord: (List<Order>)Trigger.new){
                if((ord.Status == ORDER_STATUS_ACTIVATED) && (oldOrderMap.get(ord.Id).Sales_status__c != ord.Sales_status__c)){
                    orderListForAutomateRenewals.add(ord);
                }
                if(((ord.Status == ORDER_STATUS_ACTIVATED)&& (oldOrderMap.get(ord.Id).Status != ord.Status))
                   || (ord.Sales_Ship_Date_Dt__c != null && oldOrderMap.get(ord.Id).Sales_Ship_Date_Dt__c != ord.Sales_Ship_Date_Dt__c)){   
                       ordIdsForLicenseUpdate.put(ord.Id, ord);
                   }
                //If order is updated with end customer account, update related license records
                if(ord.AccountId != oldOrderMap.get(ord.Id).AccountId || ord.Type!=oldOrderMap.get(ord.Id).Type || ord.Sales_Order_Reason__c != oldOrderMap.get(ord.Id).Sales_Order_Reason__c ){
                    ordIdsForLicenseUpdate.put(ord.Id, ord);
                    ordWithAccountUpdateMap.put(ord.Id, true);
                }
                 //Nilesh Added for TWC3144-40 - Amend Contract status
                if((oldOrderMap.get(ord.Id).Sales_status__c != ord.Sales_status__c) && ord.SBQQ__Quote__c!=null && ord.Sales_Amend_Contract__c!=null){//ord.Status == ORDER_STATUS_ACTIVATED && 
                    quoteIds.add(ord.SBQQ__Quote__c);
                    contractIds.add(ord.Sales_Amend_Contract__c);
                    orderStatusMsg = ord.Sales_status__c;
                }
                 //Nilesh Added for TWC3144-40 - Amend Contract status
                if(((ord.Sales_status__c == ORDER_CANCELLED) || (ord.Sales_status__c == ORDER_STATUS_CANCELLED_BY_SAP)) && (oldOrderMap.get(ord.Id).Sales_status__c != ord.Sales_status__c) && ord.Sales_Cancelled_Quote_No__c!=null && ord.Sales_Amend_Contract__c!=null){
                    quoteIds.add(ord.Sales_Cancelled_Quote_No__c);
                    contractIds.add(ord.Sales_Amend_Contract__c);
                    orderStatusMsg = ord.Sales_status__c;
                }
                
                if((oldOrderMap.get(ord.Id).Status != ord.Status)){
                    if((ord.Sales_Order_Sub_Type__c == ORDER_TYPE_PARTNER_LICENSE_ORDER) && (ord.Sales_status__c == STATUS_ORDER_CREATED_SUCCESSFULLY)){
                        ordersListForEmailNotification.add(ord);
                    } 
                }
                if(((ord.Type != 'Non Commercial Order' && ord.Sales_status__c == ORDER_STATUS_SHIPPED) || (ord.Type=='Non Commercial Order' && ord.Sales_status__c == STATUS_ORDER_CREATED_SUCCESSFULLY)) && (oldOrderMap.get(ord.Id).Sales_status__c != ord.Sales_status__c) && ord.SBQQ__Quote__c!=null){
                    quoteIdsForAutomatedLicGenProc.add(ord.SBQQ__Quote__c);
                    orderListForAutomatedLicGenProc.add(ord);
                }
            }
            if(isActive('Sales_AutomateRenewals') && orderListForAutomateRenewals.size()>0){
                Sales_LicenseTriggerUtility.automateRenewals(orderListForAutomateRenewals);
            }
            
            if(ordIdsForLicenseUpdate.size() > 0){
                //This method updates the related license records on order update
                Sales_OrderTriggerUtility.updateLicenseRecords(ordIdsForLicenseUpdate, ordWithAccountUpdateMap);
            }
             //Nilesh Added for TWC3144-40 - Amend Contract status
            if(quoteIds.size() > 0 && contractIds.size() > 0){
                Sales_OrderTriggerUtility.updateContractStatus(orderStatusMsg,contractIds,quoteIds);
            }
            
            if(ordersListForEmailNotification.size()>0){
                Sales_OrderTriggerUtility.sendEmailNotification(ordersListForEmailNotification);
            }
            
            if(isActive('Core_PSG_LicenseVendor_Order')){
                 for(Order ordernew: (List<Order>)Trigger.new){
				if(ordernew.Sales_status__c != ORDER_STATUS_SHIPPED){
				   orderIdSet.add(ordernew.Id);
			   }
			  
             }
			  if(orderIdSet.size()>0){
                Sales_OrderTriggerUtility.checkAccountCompetitorVendor((List<Order>)Trigger.new, (Map<Id,Order>) Trigger.oldMap);
               }
            }
            
            /*if(isActive('Sales_Order_After_Update_Trigger')){
                Sales_OrderTriggerUtility.updateCancelledOrderProducts((List<Order>) Trigger.new);
            }*/
        
            /*if(!isafterupdaterun){
                Sales_OrderTriggerUtility.checkContractsisCreated((List<Order>)Trigger.new,(Map<Id, Order>)Trigger.oldMap); 
                isafterupdaterun = true;
            }
            
            /*if(isActive('Sales_Automated_Lic_Generation_Switch') && orderListForAutomatedLicGenProc.size()>0){
                Sales_AutomatedLicGenerationProcess.getHostIdFromShippedOrder(orderListForAutomatedLicGenProc,quoteIdsForAutomatedLicGenProc);
            }*/
        //}
    //}
}