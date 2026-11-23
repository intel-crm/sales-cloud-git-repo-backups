public class SEL_core_cpq_list_price extends fflib_SObjectSelector {
	/**
     * Creates a new instance of the selector via the application class. This is here to allow unit tests to override
	 * and inject a mock instead of this class or to switch out this class for a new version.
     *
     */
    public static SEL_core_cpq_list_price newInstance() {
        return (SEL_core_cpq_list_price) Sales_Application.selector.newInstance(core_cpq_list_price__c.SObjectType);
    }
    
    public Schema.SObjectType getSObjectType(){
        return core_cpq_list_price__c.sObjectType;
    }
    
    public List<Schema.SObjectField> getSObjectFieldList() {
        return null;
    }
    
    public List<core_cpq_list_price__c> selectByPriceBookEntryAndProductIds(Set<String> priceBookEntrys, Set<Id> productIdSet) {
        return [select id, core_cpq_list_price_amt__c, core_cpq_lowerbound_qty__c, core_cpq_upperbound_qty__c, core_cpq_product_name__c, Pricebookentry__c from core_cpq_list_price__c where Pricebookentry__c in: priceBookEntrys And core_cpq_product_name__c in: productIdSet ];
    }
}