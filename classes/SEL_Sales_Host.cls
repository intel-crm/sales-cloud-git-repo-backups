public class SEL_Sales_Host extends fflib_SObjectSelector {
	/**
     * Creates a new instance of the selector via the application class. This is here to allow unit tests to override
	 * and inject a mock instead of this class or to switch out this class for a new version.
     *
     */
    public static SEL_Sales_Host newInstance() {
        return (SEL_Sales_Host) Sales_Application.selector.newInstance(Sales_Host__c.SObjectType);
    }
    
    public Schema.SObjectType getSObjectType(){
        return Sales_Host__c.sObjectType;
    }
    
    public List<Schema.SObjectField> getSObjectFieldList() {
        return null;
    }
    
    public List<Sales_Host__c> selectByHostIds(Set<Id> productIdsSet, Set<Id> hostIds){
        return [Select Id, (Select Id From Licenses__r where Sales_License_Product__c IN: productIdsSet) from Sales_Host__c Where Id IN :hostIds];
    }
    
    public List<Sales_Host__c> selectByHostIdsAndLimit(Set<Id> hostIds){
        return  [Select Id, (Select Id From Licenses__r limit 1) from Sales_Host__c Where Id IN :hostIds];
    }
    
    public List<Sales_Host__c> selectByContactId(Id fromPrimayAdmin){
        return [SELECT Id,Name,Sales_Contact__c FROM Sales_Host__c WHERE Sales_Contact__c=:fromPrimayAdmin];
    }

}