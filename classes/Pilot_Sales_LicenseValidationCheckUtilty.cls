/*********************************************************************************************************************
Class Name    : Pilot_Sales_LicenseValidationCheckUtilty
Version       : 1.0
Created Date  : Sep 2021
Function      : This class will handle license vendor validation check for both Order and Order Product trigger .

Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------
* Subhanku Ghosh 			1/9/2021               Pilot Project for testing framework.
* Shalini Kumari 			21/9/2021              Pilot Project for testing framework.
* *********************************************************************************************************************/
public without sharing class Pilot_Sales_LicenseValidationCheckUtilty {
    
    private static final String ORDER_TYPE_NONCOMM='Non Commercial Order';
    private static final String ORDER_SUBTYPE_PARTNER='Partner license order';
    private static final String ORDER_REASON_STOCKING='Stocking Order';
    //This method will return map of License Control Vendor record
    public static Map<Id,Set<String>> checkLicenseVendor(Set<Id> endCustIdSet){
        Map<Id,Set<String>> salesLicenseControlMap =new Map<Id,Set<String>>();//Map of Sales License Control record
       // for(Sales_License_Control__c controlList:[Select Id ,Sales_Account_Competitor__c,Sales_OPN__c from Sales_License_Control__c where Sales_Account_Competitor__c IN:endCustIdSet AND Sales_InActive_Ind__c=false]){//loop start here..
        for(Sales_License_Control__c controlList:SEL_Sales_License_Control.newInstance().selectByEndCustIdSet(endCustIdSet)){
            if(salesLicenseControlMap.containsKey(controlList.Sales_Account_Competitor__c)){//Adding the vendor against existing account in map.
                Set<String> existingOPNValues=salesLicenseControlMap.get(controlList.Sales_Account_Competitor__c);
                existingOPNValues.add(controlList.Sales_OPN__c); 
                salesLicenseControlMap.put(controlList.Sales_Account_Competitor__c,existingOPNValues);
            }
            else{//Adding the vendor against account in map for first time.
                Set<String> opnSet = new Set<String>();
                opnSet.add(controlList.Sales_OPN__c);
                salesLicenseControlMap.put(controlList.Sales_Account_Competitor__c,opnSet);
            }
            
        }//loop ends here..
        return salesLicenseControlMap;
    }
    
    //This method will be called from OrderItem trigger to add error
    public static void addErrorOnOrderItem(List<OrderItem> orderItemList){
        Set<Id> orderIdSet = new Set<Id>();
        Map<Id,accountWrapper> orderToCustomerMap =new Map<Id,accountWrapper>();
        Set<Id> accountIdsSet = new Set<Id>();
        for(OrderItem item:orderItemList){
            orderIdSet.add(item.OrderId);
        }
        //for(Order order:[Select Id, Sales_End_Customer_Account__c,AccountId,Type,Sales_Order_Sub_Type__c,Sales_Order_Reason__c from Order where Id IN:orderIdSet And Status='Draft']){
        for(Order order:SEL_Order.newInstance().selectByIdsAndDraftStatus(orderIdSet)){
            if(order.Sales_End_Customer_Account__c !=null || order.AccountId!=null){
                accountWrapper accWrapper = new accountWrapper(order.AccountId, order.Sales_End_Customer_Account__c);
                orderToCustomerMap.put(order.Id,accWrapper);
                //if((order.Type==ORDER_TYPE_NONCOMM && order.Sales_Order_Sub_Type__c==ORDER_SUBTYPE_PARTNER)|| order.Sales_Order_Reason__c==ORDER_REASON_STOCKING){
                     
                //}
                accountIdsSet.add(order.AccountId); 
                accountIdsSet.add(order.Sales_End_Customer_Account__c);
            }
        }
        accountIdsSet.remove(null);
        Map<Id,Set<String>> salesLicenseControlMap=checkLicenseVendor(accountIdsSet);
        for(OrderItem item:orderItemList){
            if(orderToCustomerMap.containsKey(item.OrderId)){
                String opn = item.Sales_OPN__c;
                Id accountId=orderToCustomerMap.get(item.OrderId).accountId;
                Id endCustomerId=orderToCustomerMap.get(item.OrderId).endCustomerId;
                Set<String> opnSalesControlSet= new Set<String>();
                if(endCustomerId!=null && salesLicenseControlMap.containsKey(endCustomerId)){
                    opnSalesControlSet.addAll(salesLicenseControlMap.get(endCustomerId));
                }//adding error on order record
                if(accountId!=null && salesLicenseControlMap.containsKey(accountId)){
                    opnSalesControlSet.addAll(salesLicenseControlMap.get(accountId));
                }
                if(opnSalesControlSet.contains(opn)){
                    //PRM_Execution_Controls__c  skipValidation= PRM_Execution_Controls__c.getInstance(UserInfo.getUserId());//added check to bypass validation for integration user.
                    
                    //if(!skipValidation.Skip_ValidationRule_Order_Status__c){
                        item.addError(System.Label.Sales_LicenseVendorError);//Adding error on record
                    //}
                }
            }
        }
        
    }
    
    //This method will be called from Order trigger to add error
    public static void addErrorOnOrder(List<Order> orderList,Map<Id,Order> orderOldMap){
        Set<Id> orderErrorSet = new Set<Id>();
        Set<Id> orderIdSet = new Set<Id>();
        Map<Id,accountWrapper> orderToCustomerMap =new Map<Id,accountWrapper>();
        Set<Id> accountIdsSet = new Set<Id>();
        //loop start here
        for(Order order:orderList){
            if((order.Status=='Draft')|| (orderOldMap!=null && order.Status!=orderOldMap.get(order.Id).Status && order.Status=='Activated') || (order.Sales_Is_Verified__c!=orderOldMap.get(order.Id).Sales_Is_Verified__c && order.Sales_Is_Verified__c)){
                   if(order.Sales_End_Customer_Account__c!=null || order.AccountId!=null){
                       if(orderOldMap!=null){
                           if((order.Sales_End_Customer_Account__c !=orderOldMap.get(order.Id).Sales_End_Customer_Account__c) || (order.AccountId !=orderOldMap.get(order.Id).AccountId) || (order.Sales_Is_Verified__c==true)){
                               System.debug('inside if old Id'+orderOldMap.get(order.Id).AccountId );
                               orderIdSet.add(order.Id);
                               accountWrapper accWrapper = new accountWrapper(order.AccountId, order.Sales_End_Customer_Account__c);
                               orderToCustomerMap.put(order.Id,accWrapper);
                               /*if((order.Type==ORDER_TYPE_NONCOMM && order.Sales_Order_Sub_Type__c==ORDER_SUBTYPE_PARTNER)|| order.Sales_Order_Reason__c==ORDER_REASON_STOCKING){      
}*/
                               accountIdsSet.add(order.Sales_End_Customer_Account__c);
                               accountIdsSet.add(order.AccountId); 
                           }
                       }
                       else{
                           orderIdSet.add(order.Id);
                           accountWrapper accWrapper = new accountWrapper(order.AccountId, order.Sales_End_Customer_Account__c);
                           orderToCustomerMap.put(order.Id,accWrapper);
                           accountIdsSet.add(order.Sales_End_Customer_Account__c);
                           accountIdsSet.add(order.AccountId);
                       }
                   }
               }
        }
    //loop ends here...
    
    accountIdsSet.remove(null);
    
    Map<Id,Set<String>> salesLicenseControlMap=checkLicenseVendor(accountIdsSet);
    //for(OrderItem item:[Select Id,Product2Id ,OrderId,Product2.Core_OPN__c from OrderItem where OrderId IN:orderIdSet]){//loop start here...
    for(OrderItem item:SEL_OrderItem.newInstance().selectByOrderIds(orderIdSet)){
        if(orderToCustomerMap.containsKey(item.OrderId)){               
            String opn =item.Product2.Core_OPN__c;	
            Id accountId=orderToCustomerMap.get(item.OrderId).accountId;
            Id endCustomerId=orderToCustomerMap.get(item.OrderId).endCustomerId;
            Set<String> vendorsSalesControl= new Set<String>();
            if(endCustomerId!=null && salesLicenseControlMap.containsKey(endCustomerId)){
                vendorsSalesControl.addAll(salesLicenseControlMap.get(endCustomerId));
            }
            if(accountId!=null && salesLicenseControlMap.containsKey(accountId)){
                vendorsSalesControl.addAll(salesLicenseControlMap.get(accountId));
            }
            if(vendorsSalesControl.contains(opn)){ 
                orderErrorSet.add(item.OrderId);	//Adding error on Order
            }
        }
    }//loop ends here...
    
    for(Order orderError:orderList){
        if(orderErrorSet.contains(orderError.Id)){
            //PRM_Execution_Controls__c  skipValidation= PRM_Execution_Controls__c.getInstance(UserInfo.getUserId());//added check to bypass validation for integration user.
            
            //if(!skipValidation.Skip_ValidationRule_Order_Status__c){
                orderError.addError(System.Label.Sales_LicenseVendorError);
            //}
        }
    }
}

public class accountWrapper{
    public Id accountId;
    public Id endCustomerId;
    public accountWrapper(Id accountId, Id endCustomerId){
        this.accountId = accountId;
        this.endCustomerId = endCustomerId;
    }
}
}