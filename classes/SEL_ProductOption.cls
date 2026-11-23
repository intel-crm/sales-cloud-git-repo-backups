public class SEL_ProductOption extends fflib_SObjectSelector {
	/**
     * Creates a new instance of the selector via the application class. This is here to allow unit tests to override
	 * and inject a mock instead of this class or to switch out this class for a new version.
     *
     */
    public static SEL_ProductOption newInstance() {
        return (SEL_ProductOption) Sales_Application.selector.newInstance(SBQQ__ProductOption__c.SObjectType);
    }
    
    public Schema.SObjectType getSObjectType(){
        return SBQQ__ProductOption__c.sObjectType;
    }
    
    public List<Schema.SObjectField> getSObjectFieldList() {
        return null;
    }
    
    public List<SBQQ__ProductOption__c> selectByProductIdAndType(Set<Id> prodIdSet, String PRODUCT_OPTION_TYPE_COMPONENT,String PRODUCT_OPTION_TYPE_ACCESSORY){
        return [Select Id,SBQQ__ConfiguredSKU__c,SBQQ__OptionalSKU__c,SBQQ__Type__c,SBQQ__OptionalSKU__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Lic_Type_Nm__c,SBQQ__OptionalSKU__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Prod_Expiration_Duration_Nbr__c,SBQQ__OptionalSKU__r.Core_Product_Ext_Attribute_Id__r.Core_Prod_Tool_Type_Nm__c from SBQQ__ProductOption__c where SBQQ__ConfiguredSKU__c IN:prodIdSet And SBQQ__Type__c IN(:PRODUCT_OPTION_TYPE_COMPONENT,:PRODUCT_OPTION_TYPE_ACCESSORY)];
    }
    
    public List<SBQQ__ProductOption__c> selectByConfiguredSKU(Set<Id> foundProdIdSet){
        return [Select Id,SBQQ__Type__c, SBQQ__ConfiguredSKU__c, SBQQ__OptionalSKU__c 
               from SBQQ__ProductOption__c 
               where SBQQ__Type__c ='Accessory'  AND SBQQ__ConfiguredSKU__c IN:foundProdIdSet AND SBQQ__Bundled__c=true];
    }

}