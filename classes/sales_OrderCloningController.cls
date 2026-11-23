public with sharing class sales_OrderCloningController {
        @AuraEnabled(cacheable=true)
        public static Order fetchOrder(Id orderId){
            return [SELECT Id,Sales_Order_Reason__c,AccountId FROM Order where id=:orderId LIMIT  1];
    //}
    }
}