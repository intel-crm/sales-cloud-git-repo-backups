public class SEL_Account extends fflib_SObjectSelector {
	/**
     * Creates a new instance of the selector via the application class. This is here to allow unit tests to override
	 * and inject a mock instead of this class or to switch out this class for a new version.
     *
     */
    public static SEL_Account newInstance() {
        return (SEL_Account) Sales_Application.selector.newInstance(Account.SObjectType);
    }
    
    public Schema.SObjectType getSObjectType(){
        return Account.sObjectType;
    }
    
    public List<Schema.SObjectField> getSObjectFieldList() {
        return null;
    }
    
    public List<Account> selectBySoldShipOrEndIds(Set<Id> soldIds, Set<Id> shipIds, Set<Id> endIds) {
        return [SELECT Id, Name,Core_Direct_Account_Id__c,ParentId,BillingStreet,BillingState, BillingCountry, BillingCity, BillingPostalCode, Tolabel(BillingStateCode),ToLabel(BillingCountryCode), Core_Direct_Shipping_Condition_Nm__c,Core_Direct_Sales_Organization_Nm__c,Core_Direct_Payment_Term_Nm__c,Core_Direct_Distributor_Channel_Nm__c,Core_Direct_Shipping_Instruction_Txt__c,Core_Direct_Incoterm_Dsc__c from Account where Id IN: soldIds or Id IN: shipIds or Id IN: endIds];
    }
    
    //line 450 orderproduct, check if above method can be used
    public List<Account> selectBySoldIds(List<Id> soldIds){
        return [Select id,Type,Core_Account_Type__c,Core_Direct_Distributor_Channel_Nm__c from Account where Id IN:soldIds];
    }
}