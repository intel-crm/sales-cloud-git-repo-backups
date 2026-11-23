public class SEL_Core_Account_SoldTo_ShipTo_Rel extends fflib_SObjectSelector{
	/**
     * Creates a new instance of the selector via the application class. This is here to allow unit tests to override
	 * and inject a mock instead of this class or to switch out this class for a new version.
     *
     */
    public static SEL_Core_Account_SoldTo_ShipTo_Rel newInstance() {
        return (SEL_Core_Account_SoldTo_ShipTo_Rel) Sales_Application.selector.newInstance(Core_Account_SoldTo_ShipTo_Rel__c.SObjectType);
    }
    
    public Schema.SObjectType getSObjectType(){
        return Core_Account_SoldTo_ShipTo_Rel__c.sObjectType;
    }
    
    public List<Schema.SObjectField> getSObjectFieldList() {
        return null;
    }
    
    public List<Core_Account_SoldTo_ShipTo_Rel__c> selectBySoldToOrderSet(Set<Id> soldToOrderSet) {
        return [select id,Core_Sold_To_Account__c,Core_Ship_To_Account__c,Core_Is_Deactivated_Ind__c from Core_Account_SoldTo_ShipTo_Rel__c where Core_Sold_To_Account__c IN : soldToOrderSet and Core_Is_Deactivated_Ind__c=false];
    } 
}