public class SEL_Product extends fflib_SObjectSelector {
	/**
     * Creates a new instance of the selector via the application class. This is here to allow unit tests to override
	 * and inject a mock instead of this class or to switch out this class for a new version.
     *
     */
    public static SEL_Product newInstance() {
        return (SEL_Product) Sales_Application.selector.newInstance(Product2.SObjectType);
    }
    
    public Schema.SObjectType getSObjectType(){
        return Product2.sObjectType;
    }
    
    public List<Schema.SObjectField> getSObjectFieldList() {
        return null;
    }
    
    public List<Product2> selectByProductIds(Set<Id> productIdSet){
        return [Select Id,Core_Item_Class_Nm__c,Core_Item_Sub_Component_Category_Nm__c,Core_Product_Ext_Attribute_Id__r.Core_Prod_Tool_Type_Nm__c, Core_Product_Ext_Attribute_Id__r.Core_SW_Lic_Type_Nm__c from Product2 where Id IN:productIdSet];
    }
    
    public List<Product2> selectByProductIdAndType(Set<Id> productIdSet, String TOOL_LICENSE_TYPE_CORPORATE_BUNDLE, String PRODUCT_OPTION_TYPE_COMPONENT, String PRODUCT_OPTION_TYPE_ACCESSORY){
        return [Select Id,Core_Product_Ext_Attribute_Id__r.Core_Prod_Tool_Type_Nm__c,Core_Product_Ext_Attribute_Id__r.Core_SW_Lic_Type_Nm__c ,Core_Product_Ext_Attribute_Id__r.Core_SW_Prod_Expiration_Duration_Nbr__c,
               (Select Id,SBQQ__ConfiguredSKU__c,SBQQ__OptionalSKU__c,SBQQ__Type__c,SBQQ__Bundled__c,SBQQ__OptionalSKU__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Lic_Type_Nm__c,SBQQ__OptionalSKU__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Prod_Expiration_Duration_Nbr__c from SBQQ__Options__r where SBQQ__Type__c IN(:PRODUCT_OPTION_TYPE_COMPONENT,:PRODUCT_OPTION_TYPE_ACCESSORY))
               from Product2 where Id IN:productIdSet 
               AND Core_Product_Ext_Attribute_Id__r.Core_Prod_Tool_Type_Nm__c!=:TOOL_LICENSE_TYPE_CORPORATE_BUNDLE];
    }
    

}