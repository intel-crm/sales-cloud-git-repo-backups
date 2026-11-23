public class SEL_Core_Product_Ext_Attribute extends fflib_SObjectSelector {
	/**
     * Creates a new instance of the selector via the application class. This is here to allow unit tests to override
	 * and inject a mock instead of this class or to switch out this class for a new version.
     *
     */
    public static SEL_Core_Product_Ext_Attribute newInstance() {
        return (SEL_Core_Product_Ext_Attribute) Sales_Application.selector.newInstance(Core_Product_Ext_Attribute__c.SObjectType);
    }
    
    public Schema.SObjectType getSObjectType(){
        return Core_Product_Ext_Attribute__c.sObjectType;
    }
    
    public List<Schema.SObjectField> getSObjectFieldList() {
        return null;
    }
    
    public List<Core_Product_Ext_Attribute__c> selectByProductIds(Set<Id> productIdSet){
        return [Select Id ,Core_Prod_Tool_Type_Nm__c,Core_Product_Id__c from Core_Product_Ext_Attribute__c where Core_Product_Id__c IN: productIdSet AND Core_Prod_Tool_Type_Nm__c='CORPORATE'];
    }
    
    public List<Core_Product_Ext_Attribute__c> selectByRenewalToolType(Set<Id> toBeInsertedOP_ProdIDs){
        return [SELECT Id, Core_Product_Id__c, Core_Foundation_Product_Id__c, Core_SW_Lic_Type_Nm__c, Core_Prod_Tool_Type_Nm__c FROM Core_Product_Ext_Attribute__c WHERE Core_Product_Id__c In: toBeInsertedOP_ProdIDs and Core_Prod_Tool_Type_Nm__c= 'RENEWAL' and Core_Foundation_Product_Id__c != null];
    }

}