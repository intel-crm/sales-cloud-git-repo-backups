public class SEL_Sales_License_Order_Product extends fflib_SObjectSelector{
	/**
     * Creates a new instance of the selector via the application class. This is here to allow unit tests to override
	 * and inject a mock instead of this class or to switch out this class for a new version.
     *
     */
    private static final String LICENSE_STATUS_CANCELLED = 'Cancelled';
    private static final String LICENSE_TYPE_RENEWAL = 'Renewal';
    private static final String LICENSE_TYPE_AMEND = 'Amend';
    //private static final String PRODUCT_TOOL_TYPE_CORPORATE = 'CORPORATE';
    private static final String LICENSE_TYPE_ORIGINAL = 'Original';
    private static final String PRODUCT_TOOLTYPE_ADDSEAT = 'ADD SEAT';
    private static final String PRODUCT_TOOLTYPE_RENEWAL = 'RENEWAL';
    
    public static SEL_Sales_License_Order_Product newInstance() {
        return (SEL_Sales_License_Order_Product) Sales_Application.selector.newInstance(Sales_License_Order_Product__c.SObjectType);
    }
    
    public Schema.SObjectType getSObjectType(){
        return Sales_License_Order_Product__c.sObjectType;
    }
    
    public List<Schema.SObjectField> getSObjectFieldList() {
        return null;
    }
    
    public List<Sales_License_Order_Product__c> selectByEndCustIdSet(Set<Id> orderIds) {
        return [Select Id,Sales_License__r.Sales_License_Type__c, Sales_License__c,Sales_License__r.Sales_License_Product__r.Core_Item_Class_Nm__c,Sales_License__r.Sales_License_Product__r.Core_Item_Sub_Component_Category_Nm__c,Sales_License__r.Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Lic_Rehostable_Ind__c ,Sales_License__r.Sales_License_Web_Display_Flag__c,
                                                        Sales_License__r.Sales_License_Avbl_Rehost_Nbr__c,Sales_License__r.Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Prod_Max_Rehost_Cnt__c,Sales_License__r.Sales_License_Quantity__c,Sales_License__r.Sales_License_Order__c,Sales_Order_Product__r.Quantity,Sales_License__r.Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Prod_Expiration_Duration_Nbr__c,
                                                        Sales_License__r.Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Lic_Web_Displayable_Ind__c,Sales_Order_Product__c, Sales_Order_Product__r.OrderId, Sales_Order_Product__r.Order.SBQQ__Quote__r.SBQQ__Type__c, 
                                                        Sales_License__r.Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Prod_Temporary_Lic_Allowed_Ind__c,Sales_License__r.Sales_License_Start_Date_Dt__c, Sales_Order_Product__r.Order.SBQQ__Quote__r.SBQQ__MasterContract__r.StartDate,Sales_License__r.Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Lic_Type_Nm__c, 
                                                        Sales_Order_Product__r.Order.SBQQ__Quote__r.SBQQ__MasterContract__c, Sales_Order_Product__r.SBQQ__Contract__c, Sales_Order_Product__r.SBQQ__Contract__r.Status, Sales_Order_Product__r.SBQQ__Contract__r.EndDate, Sales_Order_Product__r.SBQQ__Contract__r.StartDate,Sales_License__r.Sales_License_Order_Product__r.Sales_Contact__c
                                                        from Sales_License_Order_Product__c where Sales_Order_Product__r.OrderId IN:orderIds and (Sales_License__r.Sales_License_Type__c =: LICENSE_TYPE_ORIGINAL or (Sales_License__r.Sales_License_Type__c =:(System.Label.Sales_Licencse_Add_Seat_record_type) and Sales_License__r.Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_Prod_Tool_Type_Nm__c =: PRODUCT_TOOLTYPE_ADDSEAT) or (Sales_License__r.Sales_License_Type__c =:LICENSE_TYPE_RENEWAL and Sales_License__r.Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_Prod_Tool_Type_Nm__c =: PRODUCT_TOOLTYPE_RENEWAL))];
    } 
                                                                                                          
    public List<Sales_License_Order_Product__c> selectByLicenseSet(Set<Id> licSetToExcludeFromContract) {
        return [Select id, Sales_Order_Product__r.OrderId,Sales_Order_Product__c, Sales_License_ContractId__c,Sales_License_ContractId__r.StartDate, Sales_License__c from Sales_License_Order_Product__c where Sales_License__c IN: licSetToExcludeFromContract and Sales_License_ContractId__c != null and Sales_License__r.Sales_License_Status__c!=:LICENSE_STATUS_CANCELLED order by Sales_License_ContractId__r.enddate desc];
    }
    
    public List<Sales_License_Order_Product__c> selectByOrderItemProductIds(List<OrderItem> orderItmIds){
        return [Select id, Sales_License__c,Sales_Order_Product__c, Sales_License__r.Sales_License_Order_Product__c from Sales_License_Order_Product__c where Sales_Order_Product__c IN: orderItmIds];
    }
    
    public List<Sales_License_Order_Product__c> selectByOrderItemIdOrderByDate(Set<Id> orderItemId){
        return  [Select Id,Sales_Quantity__c,Sales_order_Product__r.Order.SBQQ__Quote__r.Sales_Renewed_from_Contract_Id__c, Sales_License__c,Sales_License__r.Sales_License_Type__c,Sales_License__r.Sales_License_Order_Product__c, Sales_Order_Product__c, Sales_Order_Product__r.Product2Id,Sales_License__r.Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Lic_Type_Nm__c from Sales_License_Order_Product__c where Sales_Order_Product__c IN: orderItemId order by Sales_License__r.CreatedDate desc];
    }
}