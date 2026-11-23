/*********************************************************************************************************************
Class Name    : Pilot_Sales_CancelOrderController
Version       : 1.0
Created Date  : Sep 2021

Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------
* Shalini Kumari 			20/9/2021               Pilot Project for testing framework.
* *********************************************************************************************************************/
public class Pilot_Sales_CancelOrderController {
    @AuraEnabled
    public static void setStatusOrderCancelled(Id objId, String cancelReason) {
        try{
            Order orderObj = [SELECT Id, Sales_status__c,SBQQ__Quote__c,Sales_SAP_OrderCancelledReason__c,Sales_Cancelled_Quote_No__c, Status,Sales_Cancelled_Reason_Dsc__c FROM Order WHERE Id=:objId];
            if(orderObj.Status=='Draft'){
                orderObj.Sales_status__c='Order Cancelled';    
                orderObj.Sales_Cancelled_Reason_Dsc__c = cancelReason;
                 if(String.isEmpty(orderObj.Sales_Cancelled_Quote_No__c)){
                    orderObj.Sales_Cancelled_Quote_No__c = orderObj.SBQQ__Quote__c;//update Cancelled Quote field
                    orderObj.SBQQ__Quote__c=null; //remove Quote from the Cancelled Order 
                }
            }
            update orderObj;
        }catch(Exception e){
            System.debug('Error Caused at Line: '+String.valueOf(e.getLineNumber())+' & Error Message :'+e.getMessage());
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