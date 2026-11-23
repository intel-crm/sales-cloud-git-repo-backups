/*********************************************************************************************************************
Class Name    : Sales_CancelOrderController
Version       : 1.0
Created Date  : Mar 2021
Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------
* Shivam Vishwakarma        24-Mar-2021             Sales_CancelOrderController  
* ---------------------------------------------------------------------------------------------------------
* Comments  : 
* Used in Aura Component Sales_CancelOrderComponent
*----------------------------------------------------------------------------------------------------------*/
public with sharing class Sales_CancelOrderController {
    @AuraEnabled
    public static void setStatusOrderCancelled(Id objId, String cancelReason) {
        try{
            Order orderObj = [SELECT Id, Sales_status__c,SBQQ__Quote__c,Sales_SAP_OrderCancelledReason__c,Sales_Cancelled_Quote_No__c, Status,Sales_Cancelled_Reason_Dsc__c FROM Order WHERE Id=:objId];
            if(orderObj.Status=='Draft'){
                orderObj.Sales_status__c='Order Cancelled';    
                orderObj.Sales_Cancelled_Reason_Dsc__c = cancelReason;
                if(String.isEmpty(orderObj.Sales_Cancelled_Quote_No__c)){
                    orderObj.Sales_Cancelled_Quote_No__c = orderObj.SBQQ__Quote__c;
                    orderObj.SBQQ__Quote__c=null; 
                }
            }
            update orderObj;
            Sales_OrderTriggerUtility.contractStatusToUpdate(orderObj);
        }catch(Exception e){
            String pureErrorMsg ;
            if(e.getMessage().contains('_EXCEPTION')){
                pureErrorMsg=e.getMessage().substringAfter('_EXCEPTION,').substringBeforeLast(': [');
                throw new AuraHandledException(pureErrorMsg);
            }
            else{
                throw new AuraHandledException(e.getMessage());}}
    }
    @AuraEnabled
    public static String apexExceptionMessageParser(String errorMsg){
        String actualErrorMsg ;
        actualErrorMsg=errorMsg.substringAfter('_EXCEPTION,').substringBeforeLast(': [');
        return actualErrorMsg;
    }
}