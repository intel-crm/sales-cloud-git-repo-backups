public class SEL_Sales_License_Control extends fflib_SObjectSelector{
	/**
     * Creates a new instance of the selector via the application class. This is here to allow unit tests to override
	 * and inject a mock instead of this class or to switch out this class for a new version.
     *
     */
    public static SEL_Sales_License_Control newInstance() {
        return (SEL_Sales_License_Control) Sales_Application.selector.newInstance(Sales_License_Control__c.SObjectType);
    }
    
    public Schema.SObjectType getSObjectType(){
        return Sales_License_Control__c.sObjectType;
    }
    
    public List<Schema.SObjectField> getSObjectFieldList() {
        return null;
    }
    
    public List<Sales_License_Control__c> selectByEndCustIdSet(Set<Id> endCustIdSet) {
        return [Select Id ,Sales_Account_Competitor__c,Sales_OPN__c from Sales_License_Control__c where Sales_Account_Competitor__c IN: endCustIdSet AND Sales_InActive_Ind__c=false];
    } 
}