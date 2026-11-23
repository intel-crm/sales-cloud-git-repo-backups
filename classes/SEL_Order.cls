public class SEL_Order extends fflib_SObjectSelector {
	/**
     * Creates a new instance of the selector via the application class. This is here to allow unit tests to override
	 * and inject a mock instead of this class or to switch out this class for a new version.
     *
     */
    public static SEL_Order newInstance() {
        return (SEL_Order) Sales_Application.selector.newInstance(Order.SObjectType);
    }
    
    public Schema.SObjectType getSObjectType(){
        return Order.sObjectType;
    }
    
    public List<Schema.SObjectField> getSObjectFieldList() {
        return null;
    }
    
    public List<Order> selectByIds(List<Order> orderIds) {
        return [Select Id,SBQQ__Quote__c, SBQQ__Quote__r.SBQQ__Type__c, SBQQ__Quote__r.SBQQ__StartDate__c from Order where Id IN:orderIds];
    }
    
    public List<Order> selectByOrderId (List<Id> objId){
        return [SELECT Id, Pricebook2Id, Sales_Order_Reason__c  FROM Order WHERE Id IN:objId];
    }
    
    public List<Order> selectByPoNumberAndStatus(Set<Id> poNumbers, String status) {
        return [Select Sales_PO_Number_Txt__c from Order where Sales_PO_Number_Txt__c!=null and Sales_status__c!=: status and Sales_PO_Number_Txt__c IN: poNumbers];
    }
    
    public List<Order> selectByIdsAndDraftStatus(Set<Id> orderIds) {
        return [Select Id,Type,SBQQ__Quote__c,AccountId,Sales_Sold_To_Account__c,Sales_Sold_To_Account__r.Core_Direct_Distributor_Channel_Nm__c, Status,Sales_Req_Ship_Date_Dt__c,OrderItemCount__c,Pricebook2Id, Sales_IsPriceChanged__c, Sales_End_Customer_Account__c,Sales_Order_Sub_Type__c,Sales_Order_Reason__c from Order where Id IN:orderIds and Status='Draft' ];
    }
    
   
}