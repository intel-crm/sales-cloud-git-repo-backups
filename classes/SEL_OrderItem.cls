public class SEL_OrderItem extends fflib_SObjectSelector {
	/**
     * Creates a new instance of the selector via the application class. This is here to allow unit tests to override
	 * and inject a mock instead of this class or to switch out this class for a new version.
     *
     */
    public static SEL_OrderItem newInstance() {
        return (SEL_OrderItem) Sales_Application.selector.newInstance(OrderItem.SObjectType);
    }
    
    public Schema.SObjectType getSObjectType(){
        return OrderItem.sObjectType;
    }
    
    public List<Schema.SObjectField> getSObjectFieldList() {
        return null;
    }
    
    public List<OrderItem> selectByOrderIds(Set<Id> orderIds) {
        return [Select Id,
                Sales_Contact__c,
                Product2Id,
                Product2.Core_Item_Class_Nm__c,
                OrderId,
                Product2.Core_OPN__c,
                Product2.Core_Item_Sub_Component_Category_Nm__c,
                Product2.Core_Product_Ext_Attribute_Id__r.Core_Prod_Tool_Type_Nm__c,
                Order.Sales_IsRenewal__c,
                Product2.Core_Product_Ext_Attribute_Id__c,
                Product2.Core_Product_Ext_Attribute_Id__r.Core_SW_Prod_Avail_To_TL_ORD_ENBLMT_Ind__c,
                Product2.Core_Item_Orderable_Ind__c,
                OrderItemNumber,
                PricebookEntryId,
                UnitPrice,
                UnitPriceForceOverride__c,
                SBQQ__QuoteLine__c, 
                Sales_Cancelled_Quoteline_No__c, 
                SBQQ__Status__c
                from OrderItem where OrderId IN: orderIds and id!=null];
    }
    
    public List<OrderItem> selectAndOrderByOrderIds(Set<Id> orderIdsWithQuote){
        return [Select OrderId,Product2Id from OrderItem where OrderId IN:orderIdsWithQuote order by OrderId];
    }
    
    public List<OrderItem> selectByOrderForProductOrOPN(Set<Id> orderIdsfororderProducts, Set<Id> orderIdsfornonCorporateOPN) {
        return [Select Id,OrderId,Sales_Contact__c,Product2.Core_Product_Ext_Attribute_Id__r.Core_Prod_Tool_Type_Nm__c from OrderItem where Sales_Contact__c=null and (OrderId IN: orderIdsfororderProducts or OrderId IN: orderIdsfornonCorporateOPN)];
    }
    
    public List<OrderItem> selectByQLIProductAndOrderIds(Set<Id> orderIds,Set<Id> quotelineIds,Set<Id> productIdSet) {
        return [ Select Id ,OrderItemNumber,Sales_Broken_Price_Amt__c,Sales_Suggested_Resale_Price__c,UnitPrice,SBQQ__QuoteLine__c,OrderId,UnitPriceForceOverride__c,Product2Id from OrderItem where SBQQ__QuoteLine__c IN: quotelineIds and OrderId IN:orderIds and Product2Id IN: productIdSet ];
    }
    
    public List<OrderItem> selectByPricebookEntryProductAndOrderIds(Set<Id> orderIds,Set<Id> pricebookEntryIds,Set<Id> productIdSet) {
        return [ Select Id , OrderItemNumber,PricebookEntryId,Product2Id,UnitPrice,OrderId,UnitPriceForceOverride__c,SBQQ__QuoteLine__c,Quantity from OrderItem where PricebookEntryId IN: pricebookEntryIds and Product2Id IN: productIdSet and OrderId IN: orderIds ];
    } 
    
    public List<OrderItem> selectByOrderIdAndOrderItemIds( Set<Id> orderIdSet, List<OrderItem> orderItemList){
        return [Select Id,Product2Id,Product2.Core_Item_Class_Nm__c,OrderId from OrderItem where OrderId IN:orderIdSet and Id NOT IN:orderItemList];
    }
    
    public List<OrderItem> selectByOrderItemIds(List<OrderItem> orderItmList){
        return [select id ,Product2Id,  Product2.Core_Product_Ext_Attribute_Id__r.Core_Foundation_Product_Id__c, Quantity  from OrderItem where Id IN : orderItmList];
    }
    
    public List<OrderItem> selectByOrderItemAndProductId(List<OrderItem> orderItmList, Set<Id> prod_ExtAttributeMapIDS ){
        return [select id , Quantity , Sales_Contact__c, Product2Id , Product2.Core_Product_Ext_Attribute_Id__r.Core_Foundation_Product_Id__c from orderitem where id in: orderItmList AND  Product2Id In: prod_ExtAttributeMapIDS ];
    }
    
    public List<OrderItem> selectByOrderIdAndQuoteLineIds(Set<Id> quotelineIds, Set<Id> orderIds){
        return [Select Id ,OrderItemNumber,Sales_Broken_Price_Amt__c,Sales_Suggested_Resale_Price__c,UnitPrice,SBQQ__QuoteLine__c,OrderId from OrderItem where SBQQ__QuoteLine__c IN:quotelineIds and OrderId IN:orderIds];
    }
    
    public List<OrderItem> selectByProductAndContractIds(Set<Id> productIdSet, Set<Id> contractIdSet){
        return [Select id, Product2Id, Quantity from OrderItem where Product2Id IN :productIdSet and SBQQ__Contract__c IN: contractIdSet];
    }
}