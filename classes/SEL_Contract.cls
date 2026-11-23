public class SEL_Contract extends fflib_SObjectSelector {
	/**
     * Creates a new instance of the selector via the application class. This is here to allow unit tests to override
	 * and inject a mock instead of this class or to switch out this class for a new version.
     *
     */
    public static SEL_Contract newInstance() {
        return (SEL_Contract) Sales_Application.selector.newInstance(Contract.SObjectType);
    }
    
    public Schema.SObjectType getSObjectType(){
        return Contract.sObjectType;
    }
    
    public List<Schema.SObjectField> getSObjectFieldList() {
        return null;
    }
    
    public List<Contract> selectByIdAndStatus(Set<Id> contractIds, String status) {
        return [Select Id ,Status,SBQQ__Quote__c,Sales_Is_Amendment_Completed__c from Contract where Id IN: contractIds And Status =: status];
    }
}